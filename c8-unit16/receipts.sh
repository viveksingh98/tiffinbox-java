#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 8 · Pub/Sub and Streams - this unit's receipts. Section 3's third anchor change (C3): before/ is a link to ../c8-unit15/after
# (unit 15's tree), after/ is this unit's tree and ../c8-tiffinbox equals it from this unit's commit on. Under the profile "dev" only:
# KitchenEvents.java (new, @Component @Profile("dev"), a @TransactionalEventListener on CustomerAdded that writes one entry to the
# stream tiffinbox:kitchen-events - XADD, its fields type, name and mealType from a LinkedHashMap), compose.yaml's Redis note (the
# stream, which a new container loses) and RedisDatastoreIT's third test; the anchor README's unit 16 section.
# Two witnesses for every Redis number (R.398): Java's answer and redis-cli inside the Redis container (docker exec, the image's own
# client), run while a JVM waits at a pause; MONITOR (a second docker exec) shows the listener container's commands.
# Whose write: KITCHENEVENTS' (TiffinBox's application class under "dev", probe.u16.U16, one POST /customers per start - anchor) or
# the HARNESS's (probe.u16.H16: the publisher, the subscriber, consumers c1 / c2, the listener container c3, the trim - pubsub,
# dropped, group, pending, trim, persist). Pub/Sub, the group, the SIGINT'd consumer, the claim and the container are never TiffinBox's.
# Captures (the JVM ones run three times and hashed; exercise once per run of record - its 3/3 is across the runs; the tests once per
# run of record too, folded into anchor):
#   exercise   exercise/README.md's lines, then SOLUTION.md's, as written, in ONE env -i shell - bash, then zsh -f (Redis by the digest)
#   anchor     the tests; the libraries; after/ under "dev" on PostgreSQL + Redis, three starts in a row against one Redis (a fresh
#              database each): the stream after the start, after one add, after a refused add, by Java, redis-cli and psql; SIGINT
#   pubsub     PUBLISH and convertAndSend with no subscriber (0), a subscriber connects (NUMSUB 1), two more (1 each): heard 2
#   dropped    the event published before any subscriber: 0 receivers, not in the subscriber's list, nothing in Redis - beside a stream
#              entry written in the same window, XLEN 1
#   group      XGROUP CREATE; ten XADDs; c1 reads 5, acknowledges 2, the harness holds, SIGINT; XPENDING 3; c2 claims 3 and acknowledges
#              them (0); the listener container c3 reads and acknowledges the other 5 (MONITOR); XLEN 10 throughout
#   pending    c1 SIGINT'd mid-batch (the planted hold): XPENDING 3 read ten times with the harness holding between, XINFO CONSUMERS
#   trim       a thousand XADDs, MAXLEN ~ 100: XLEN 100 (stream-node-max-entries read)
#   persist    the group's ten entries: CONFIG GET save / appendonly; docker restart -> XLEN 10 and the log's lines; a new container -> 0
#   default    after/ with no profile on H2, no Docker, Redis absent: health 200, /leaderboard 404, no KitchenEvents bean, an add 201
#   seven      the comparison set on before/'s and after/'s jars (H2; after/ on 20550, before/ on 20553); Hibernate's script
# Every tree is COPIED under .harness/ and built there, offline (-o, from .m2-demo, a copy of the course's seed, maven.repo.local
# absolute), every module from the tree's own sources (-pl tiffinbox-web -am, R.391). Every JVM and Maven run under an alarm (R.247),
# every JVM with SIGINT reset to its default (R.410). Every docker call names its socket (dk, R.344), --pull never; every container is
# removed with its volume (rm -fv, R.387). A receipt waits on a count it polls (R.412), never on a settle sleep.
# Ports (20550-20559): 20550 TiffinBox after/ (the harness's web server; the seven) · 20551 the PostgreSQL container · 20552 the Redis
# container (the exercise's own Redis runs on it before, persist's new container after its rm -fv) · 20553 TiffinBox before/ for the
# seven (a second port, so the two jars never share one) · 20559 the port "Redis absent" points at on the default run, asserted
# unbound · 20554-20558 spare, never bound.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
RIMG=redis@sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3
CN=c8u16-pg; RN=c8u16-redis; EN=c8u16-ex
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
pid=""; mpid=""; xpid=""; rpid=""; CSTARTED=""; RSTARTED=""; TC0=""; INTR=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.u16.") || index($0, "probe.x.") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "curlset.sh") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || $3 ~ /(^|\/)javac$/ || index($0, "ex-drive.sh") || index($0, " Pending ") || index($0, "redis-cli MONITOR")) { print $1 }' | paste -sd' ' -) || l=""
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
trap 'trap "" INT TERM; [ -z "$rpid" ] || { [ -z "$RSTARTED" ] || monkill > /dev/null 2>&1; killtree "$rpid"; }; for p in "$mpid" "$xpid" "$pid" "$rpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid" "$rpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; tcrm; ctrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git javap unzip /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|FLYWAY_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|REDIS[A-Z_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT|COMPOSE_[A-Z_]*)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"

# ---- gates before anything is written: the folder, the links, the pins, the prose, the change, R.250, the notes ------------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh xcheck.sql' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk16.py dur8.py logback.xml s816.py src surefire.py tree16.py variants.py' ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe/u16/H16.java probe/u16/U16.java probe/x/XMain.java' ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'Pending.java README.md SOLUTION.md' ] || die "exercise/ holds another file, or misses one"
cmp -s harness/dur8.py ../c8-unit02/harness/dur8.py || die "harness/dur8.py is not the builders' dur8.py as unit 02 shipped it, byte for byte"
cmp -s harness/surefire.py ../c8-unit02/harness/surefire.py || die "harness/surefire.py is not unit 02's, byte for byte"
cmp -s harness/logback.xml ../c8-unit07/harness/logback.xml || die "harness/logback.xml is not unit 07's, byte for byte"
cmp -s harness/src/probe/x/XMain.java ../c7-unit29/harness/src/probe/x/XMain.java || die "harness/src/probe/x/XMain.java is not Course 7 unit 29's, byte for byte"
cmp -s xcheck.sql ../c7-unit39/xcheck.sql || die "xcheck.sql must be Course 7's capstone's, byte for byte (unit 16 moves no JPA mapping)"
[ -L before ] && [ "$(readlink before)" = ../c8-unit15/after ] || die "R.211: before must be a link to ../c8-unit15/after (it points at: $(readlink before 2> /dev/null || echo 'not a link'))"
[ -d after ] && [ ! -L after ] || die "after/ must be this unit's own tree, not a link"
for t in after before; do [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] && die "$t holds a secrets/ or a target/ - never built in place"; true; done
git rev-parse -q --verify '93bf2f1^{commit}' > /dev/null 2>&1 || die "unit 15's commit 93bf2f1 is not in this repository's history"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree16.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/ ($3): python3 -I harness/tree16.py $dir/ -> $got = receipts.md5's $nm line"; }
pin before-tree before start; pin after-tree after start
U15P=$(awk '$1 == "after-tree" { print $2, $3 }' ../c8-unit15/receipts.md5)
[ "$U15P" = "$(awk '$1 == "before-tree" { print $2, $3 }' receipts.md5)" ] || die "before/'s pin is not unit 15's after-tree line ($U15P)"
echo "  before/'s pin = ../c8-unit15/receipts.md5's after-tree line ($U15P), re-derived by harness/tree16.py"
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c8-tiffinbox 2>&1 || true)
echo "  after/ against ../c8-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor' || echo 'they differ - a later unit moved the anchor; this unit measures after/')"
echo "  after/ against before/ (diff -rq, the files C3 changed):"; diff -rq before/ after/ 2>&1 | sed -E 's#^Files before/(.*) and after/.* differ$#    changed: \1#; s#^Only in after/(.*): (.*)$#    new: \1/\2#; s#^Only in before/(.*): (.*)$#    gone: \1/\2#'
W16=tiffinbox-web/src/main/java/com/tiffinbox/web
for f in $W16/RedisCaching.java $W16/TiffinBoxApp.java $W16/KitchenMetrics.java $W16/Leaderboard.java $W16/KitchenHealthIndicator.java $W16/CustomerFeed.java $W16/TiffinBoxServer.java $W16/KitchenOrder.java $W16/KitchenOrders.java $W16/RedisDatastore.java tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java tiffinbox-core/src/main/java/com/tiffinbox/CustomerAdded.java tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java tiffinbox-core/src/main/java/com/tiffinbox/Dashboard.java tiffinbox-web/src/main/resources/application.yaml tiffinbox-web/src/main/resources/application-dev.yaml tiffinbox-web/src/test/java/slice/RedisSlice.java pom.xml tiffinbox-core/pom.xml tiffinbox-web/pom.xml; do
  [ "$(md5 -q "after/$f")" = "$(md5 -q "before/$f")" ] || die "C3 leaves $f untouched: after/'s differs from before/'s"
  echo "  after/$f: md5 $(md5 -q "after/$f") = before/'s (untouched)"; done
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s816.py harness/dur8.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -2 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
YC=$(for f in compose.yaml tiffinbox-web/src/test/java/com/tiffinbox/web/RedisDatastoreIT.java; do diff "before/$f" "after/$f" | $G '^>' || true; done; cat after/$W16/KitchenEvents.java)
YD=$(printf '%s\n' "$YC" | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
[ "$YD" = 0 ] || die "R.402: dur8 finds $YD duration word(s) in the lines C3 added (the Javadoc, the comments, the new class)"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
DN=$($G -rniwE -- "$DISH" README.md exercise harness 2> /dev/null | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|VALUES-PENDING|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or harness: $PH"
for t2 in 'Spring Data Redis Repositories' 'Pub/Sub and Streams' 'Distributed Locks and Rate Counters' 'Choosing a Broker' 'Delivery Guarantees'; do $G -qF -- "*$t2*" README.md || die "R.224/R.405: README.md calls the unit or course back by its title: $t2"; done
! $G -q '^```java$' README.md || die "README.md holds a java block - the code is the anchor's files and the harness's"
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
EXQ="Your turn: a consumer died holding three kitchen events, and XPENDING still lists them. Have a second consumer take them and acknowledge them."
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
DK=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -nE '\bdocker (run|exec|rm|ps|port|info|images|volume|image|pull|events|compose|network|restart|logs)\b' | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.344: receipts.sh calls docker without the pinned socket (every call is dk): $DK"
RMF=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) rm( +-[a-z]+)*' | sort -u | paste -sd'|' -)
[ "$RMF" = 'dk rm -fv' ] || die "R.387/R.322: receipts.sh removes a container without its volume - every removal is dk rm -fv (found: ${RMF:-none})"
RUNP=$($G -v '^ *#' receipts.sh | $G -oE '(dk|docker) run -[^"]*' | $G -vcF -- '--pull never' || true)
[ "$RUNP" = 0 ] || die "R.344: a dk run without --pull never"
MVA=$($G -v '^ *#' receipts.sh | $G -F 'clean ' | $G -F '$MV' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am"
ST=$(python3 -I -B harness/chk16.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
R250=$(python3 -I -B harness/chk16.py r250 after before) || die "R.250: $(printf '%s\n' "$R250" | $G '^FAIL' | head -2 | paste -sd';' -)"
printf '%s\n' "$R250" | $G -v '^VALUES ' | sed 's/^/  /'
echo "  prose, per sentence (s816, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test): refused 0 over $PROSE · the lines C3 added (Javadoc, comments, the new class): dur8 0 · dish names 0 · placeholders 0 · called back by title · no java block"
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
    gsub(/DB loaded from disk: [0-9.]+ seconds/, "DB loaded from disk: <t>")
    gsub(/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]+/, "<id>")
    gsub(/<t>-[0-9]+/, "<id>")
    gsub(/"BLOCK" "[0-9]+"/, "\"BLOCK\" \"<n>\"")
    gsub(/ BLOCK [0-9]+/, " BLOCK <n>")
    gsub(/ idle [0-9]+/, " idle <n>")
    gsub(/ inactive -?[0-9]+/, " inactive <n>")
    while (match($0, /<id> c[0-9] [0-9]+ [0-9]+/)) { e = substr($0, RSTART, RLENGTH); n = split(e, a, " "); $0 = substr($0, 1, RSTART - 1) a[1] " " a[2] " <idle> " a[4] substr($0, RSTART + RLENGTH) }
    gsub(/polled [0-9]+ times/, "polled <k> times")
    gsub(/pid [0-9]+/, "pid <n>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxWebTest in 3.1 seconds (process running for 4.2)' 'Tests run: 2, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 3.982 s' 'Finished Spring Data repository scanning in 23 ms. Found 0 Redis repository interfaces.' 'Root WebApplicationContext: initialization completed in 812 ms' 'Successfully applied 3 migrations (execution time 00:00.026s)' 'Container redis@sha256:7958 started in PT0.6S' 'Total time:  12.345 s' 'PROBE hold: pid 41231' '"XREADGROUP" "GROUP" "kitchen" "c3" "BLOCK" "100" "STREAMS" "tiffinbox:kitchen-events" ">"' 'XPENDING: 3 1795083337520-0 1795083337523-1 c1 3' 'XPENDING ext: 1795083337520-0 c1 568 1 1795083337522-0 c1 569 1' 'name c1 pending 3 idle 614 inactive 614' 'DB loaded from disk: 0.000 seconds' 'ids [<t>-0, <t>-1]' 'PING polled 14 times' "$U/x $HOME/y" | mask)
printf '%s\n' "$MP" | python3 -I -B -c 'import importlib.util,sys,re; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=sys.stdin.read(); sys.exit(1 if m.DUR.search(t) or "PT0" in t or "3.982" in t or "00:00.026" in t or "812" in t or "12.345" in t or "41231" in t or "\"100\"" in t or "1795" in t or "568" in t or "614" in t or "0.000" in t or "<t>-" in t or "14 times" in t else 0)' || die "R.402: the mask's self-test - a planted duration line passed it unmasked: $(printf '%s\n' "$MP" | head -2 | paste -sd';' -)"
[ "$(printf '%s\n' "$MP" | tail -1)" = '…/x ~/y' ] || die "the mask's self-test: the folders and the home must be masked"
echo "  mask: its self-test refused the planted Started-in-seconds, Time elapsed, scanning, initialization, execution-time, started-in-PT, Total time, pid, MONITOR's BLOCK, the stream ids (both parts), XPENDING's idle column, XINFO's idle and inactive, Redis's DB-loaded time and a poll count unmasked (R.402); folders and home masked"
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
RVOL=$(dk image inspect --format '{{json .Config.Volumes}}' "$RIMG" 2> /dev/null)
RY0=$(dk images --format '{{.Repository}}' 2> /dev/null | $G -c ryuk || true)
[ "$RY0" = 0 ] || die "R.318: an image named ryuk is on this machine ($RY0) - Ryuk stays off and none is pulled"
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run - remove it with its volume: docker -H \"\$DH\" rm -fv <id>"
for c in $CN $RN $EN; do [ -z "$(dk ps -aq --filter name=^/$c\$ 2> /dev/null)" ] || die "a container named $c exists before the run - an interrupted run's? docker -H \"\$DH\" rm -fv $c"; done
TC0=1
[ ! -e "$HOME/.testcontainers.properties" ] || die "R.318: ~/.testcontainers.properties exists - this unit's Testcontainers JVMs read a receipt home under .harness/ only"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 20550 20551 20552 20553 20554 20555 20556 20557 20558 20559"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
[ "$(pgrep -x java | wc -l | tr -d ' ')" = 0 ] || die "a java process is running before this script starts one - not this script's; stop it first"
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · $IMG present, id $IID · $RIMG present, id $RID, its declared volumes: $RVOL · nothing pulled, ever · images named ryuk $RY0 · Testcontainers containers 0 · ports 20550-20559 (and 18425, 8080) free · java processes 0"

# ---- the trees, copied; the builds; the harness -------------------------------------------------------------------------------
rm -rf .harness; mkdir -p .harness/run-h2/secrets/tiffinbox .harness/run-pg/secrets/tiffinbox .harness/run-h .harness/hc .harness/hcx .harness/home .harness/run
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
  bg "cd .harness/$t && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$t.log
  [ "$RE" = 0 ] || die ".harness/$t: the jar's extract failed"; done
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*\" harness/src/probe/u16/*.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/: $(head -5 .harness/javac.log)"
mkdir -p .harness/lib-nofly
for j in $(ls .harness/after/$XD/lib); do case $j in flyway-*|spring-boot-flyway-*) ;; *) ln -s ../after/$XD/lib/$j .harness/lib-nofly/$j ;; esac; done
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -parameters -d .harness/hcx -cp \".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*\" harness/src/probe/x/XMain.java" .harness/javac-x.log
[ "$RE" = 0 ] || die "Hibernate's schema probe did not compile: $(head -5 .harness/javac-x.log)"
TF=secrets/tiffinbox/shutdown-token
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/run-h2/$TF) || die "the token was not written"
for d in run-pg after before; do mkdir -p .harness/$d/secrets/tiffinbox; (umask 077 && cp .harness/run-h2/$TF .harness/$d/$TF) || die "the token was not copied"; done
TOKEN=$(head -1 .harness/run-h2/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
PW=$(openssl rand -hex 16); (umask 077 && printf 'POSTGRES_USER=tiffinbox\nPOSTGRES_PASSWORD=%s\n' "$PW" > .harness/pg.env) || die "the password file was not written"
echo "  built before/'s and after/'s trees offline (mvn -o package -DskipTests -pl tiffinbox-web -am, exit 0, 'Downloaded from' 0), extracted their jars, compiled the harness against after/'s; Hibernate's schema probe compiled; a shutdown token and a PostgreSQL password generated (0600, never printed)"
printf '%s\n' "  every capture of record runs the anchor's own tree, after/ (or before/ for the seven); KitchenEvents' entries are the anchor's (one POST /customers per start, anchor); the harness's publisher, subscriber, consumers c1 / c2, listener container c3 and its trim entries (entry-1 … entry-10, t1 … t1000) are labelled where they print; the exercise's program is the exercise's" > .harness/gate.out

# ---- helpers -------------------------------------------------------------------------------------------------------------------
pingup() { local i=0; while [ "$(dk exec "$RN" redis-cli PING 2> /dev/null | tr -d '\r')" != PONG ]; do i=$((i + 1)); [ $i -lt 200 ] || die "Redis did not answer PING (200 reads)"; sleep 0.1; done; PINGS=$i; }
runredis() { RSTARTED=1
  bg "dk run -d --pull never --name $RN -p 127.0.0.1:20552:6379 $RIMG" .harness/docker-run-redis.log
  [ "$RE" = 0 ] || die "the Redis container did not start: $(tail -2 .harness/docker-run-redis.log)"
  pingup
  DR=$(dk port "$RN" 2> /dev/null | paste -sd'|' -)
  [ "$DR" = '6379/tcp -> 127.0.0.1:20552' ] || die "the Redis container must publish 6379 on 127.0.0.1:20552 alone: $DR"; }
startdb() {
  CSTARTED=1
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:20551:5432 --env-file .harness/pg.env $IMG" .harness/docker-run.log
  [ "$RE" = 0 ] || die "the PostgreSQL container did not start: $(tail -2 .harness/docker-run.log)"
  runredis
  local i=0; while ! dk exec "$CN" pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 120 ] || die "PostgreSQL did not accept connections (120 tries)"; sleep 0.5; done
  DP=$(dk port "$CN" 2> /dev/null | paste -sd'|' -)
  [ "$DP" = '5432/tcp -> 127.0.0.1:20551' ] || die "the PostgreSQL container must publish 5432 on 127.0.0.1:20551 alone: $DP"
  echo "  the containers: $CN from $IMG (--pull never), published $DP, user tiffinbox, its password from a 0600 file; $RN from $RIMG (--pull never), published $DR, no password - 127.0.0.1 only; pg_isready and PING (a count of reads, capped)"; }
psq() { dk exec "$CN" psql -U tiffinbox -d "$1" -qAt -v ON_ERROR_STOP=1 -c "$2" 2>&1 || die "psql failed on $1: $2"; }
pgdb() { psq postgres "drop database if exists $1 with (force)" > /dev/null; psq postgres "create database $1" > /dev/null
  (umask 077 && printf 'jdbc:postgresql://127.0.0.1:20551/%s?user=tiffinbox&password=%s\n' "$1" "$PW" > .harness/run-pg/secrets/tiffinbox/jdbc-url) || die "the URL was not written"
  PGD=$1; echo "  a fresh database: $1 (psql) · its URL in the config tree (0600, never printed)"; }
pgdrop() { psq postgres "drop database $1 with (force)" > /dev/null; echo "  dropped: $1"; }
rc() { dk exec "$RN" redis-cli "$@" 2>&1 | tr -d '\r'; }
flush() { [ "$(rc FLUSHALL)" = OK ] || die "redis-cli FLUSHALL failed"; echo "  redis-cli FLUSHALL -> OK · --scan: $(rc --scan | $G -c . || true) keys"; }
K=tiffinbox:kitchen-events; CH=tiffinbox:kitchen
DEV="--spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20552 --logging.level.tiffinbox=INFO"
HX=0; PH=""
# hj TREE DB PORT STEPS [ARG...]: one TiffinBox harness JVM (probe.u16.U16) over TREE's jar, its web server on PORT, on H2 (DB=h2,
# .harness/run-h2) or on PostgreSQL (DB=pg, .harness/run-pg, whose config tree holds the URL); ARG more Spring arguments; at each of
# the JVM's pauses the function named by PH runs (with the pause's number) and its lines are printed after the JVM's own; its exit = $HX
hj() { local tr=$1 db=$2 port=$3 steps=$4 c k=1; shift 4
  c="cd .harness/run-$db && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../$tr/$XD/tiffinbox-web-1.0.0.jar:../$tr/$XD/lib/*\" probe.u16.U16 $steps --tiffinbox.port=$port${1:+ $*} --logging.config=../../harness/logback.xml --spring.main.banner-mode=off"
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
# hh STEPS: one Redis harness JVM (probe.u16.H16: Lettuce's factory and a StringRedisTemplate, no TiffinBox, no web server, no database)
# on Redis at 127.0.0.1:20552; pauses as hj's; its exit = $HX. Its log is Logback's own default layout, the root at WARN (H16 sets
# it): an exception's class and its stack print in full, so the R.410 count below reads every one there is

HCMD() { printf '%s' "cd .harness/run-h && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -Dh16.port=20552 -cp \"../hc:../after/$XD/tiffinbox-web-1.0.0.jar:../after/$XD/lib/*\" probe.u16.H16 $1"; }
hh() { local steps=$1 c k=1; c=$(HCMD "$steps")
  echo "\$ $c" | sed 's#\.\./\.\./harness#…/harness#' | mask
  rm -f .harness/run-h/go; : > .harness/pause.out
  RE=0; (eval "$c") > .harness/h.log 2>&1 < /dev/null & mpid=$!
  while kill -0 "$mpid" 2> /dev/null; do
    if $G -q "^PROBE pause $k: the receipt reads now" .harness/h.log; then
      if [ -n "$PH" ]; then "$PH" $k >> .harness/pause.out 2>&1; fi
      : > .harness/run-h/go; k=$((k + 1)); fi
    sleep 0.1; done
  wait "$mpid" || RE=$?; mpid=""
  [ "$RE" != 142 ] || die "the harness JVM's alarm fired (exit 142, cap 240 - R.247)"
  hlog2 .harness/h.log
  sed 's/^/  /' .harness/pause.out
  cat .harness/h.log >> .harness/h-all.log
  [ "$RE" = "$HX" ] || die "the Redis harness JVM exited $RE, not $HX ($steps): $($G '^PROBE' .harness/h.log | tail -2 | paste -sd';' -)"; }
# pubj MSG: the harness's publisher JVM, run inside a pause of another (its pid in xpid for the trap), in the foreground
pubj() { local c e=0; c=$(HCMD "pub=$1")
  echo "the receipt: \$ $c" | sed 's#\.\./\.\./harness#…/harness#' | mask
  (eval "$c") > .harness/p.log 2>&1 < /dev/null & xpid=$!; wait "$xpid" || e=$?; xpid=""
  [ "$e" = 0 ] || die "the publisher JVM exited $e"
  $G '^PROBE ' .harness/p.log | $G -v '<<< exit' | sed 's/^/  /'
  echo "  the publisher's exit $e · its log: ERROR $($G -c '^ERROR ' .harness/p.log || true) · lines naming an Exception $($G -v '^PROBE ' .harness/p.log | $G -cE '[A-Za-z]+(Exception|Error)\b' || true)"
  cat .harness/p.log >> .harness/h-all.log; }
NETTY='io.netty.resolver.dns.DnsServerAddressStreamProviders'
hlog() {
  $G -oE 'Multiple Spring Data modules found, entering strict repository configuration mode|Found [0-9]+ (JPA|JDBC|Redis) repository interfaces?|HHH000001: Hibernate ORM core version [^ ]+|FlywayExecutor : Database: .*|tiffinbox : (orders cooked|kitchen value): +[0-9]+' "$1" | sed -E 's/FlywayExecutor : //; s/tiffinbox : /tiffinbox: /; s#127\.0\.0\.1:20551/[a-z0-9]+#127.0.0.1:<port>/<db>#' | sed 's/^/  log: /'
  $G -E '^PROBE ' "$1" | mask
  logline "$1"; }
hlog2() { $G -E '^PROBE ' "$1" | mask; logline "$1"; }
logline() { echo "  exit $RE · its log, every line but the harness's own PROBE lines: WARN $($G -c 'WARN ' "$1" || true) (Netty's DNS line on macOS: $($G -c "WARN .*$NETTY" "$1" || true)) · ERROR $($G -c 'ERROR ' "$1" || true) · lines naming an Exception or an Error class $($G -v '^PROBE ' "$1" | $G -cE '[A-Za-z]+(Exception|Error)\b' || true) · RedisConnectionFailureException $($G -c RedisConnectionFailureException "$1" || true)"
  $G 'WARN ' "$1" | $G -v "$NETTY" | sed -E 's/^.*WARN +/  its other WARN line: /' | cut -c1-160 | sort; }
NCAP=3
unpub=""; CAPRUN=0
cap() { local nm=$1 i n=$NCAP; shift
  i=1; while [ $i -le $n ]; do CAPRUN=$i; "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid$rpid" ] || die "$nm left a process running"
    $G -q '^  \*\*\* ' .harness/cap.raw && { cat .harness/cap.raw >&3; die "$nm stopped (above)"; }
    ! $G -qE 'localhost:[0-9]+|127\.0\.0\.1:(3|4|5|6)[0-9]{4}' .harness/cap.raw || die "R.319: $nm printed a container's port raw"
    ! $G -qF -- "$PW" .harness/cap.raw || die "$nm printed the PostgreSQL password"
    mask < .harness/cap.raw > ".r-$nm.$i"; i=$((i + 1)); done
  CHH=$(md5 -q ".r-$nm.1")
  i=2; while [ $i -le $n ]; do [ "$CHH" = "$(md5 -q ".r-$nm.$i")" ] || die "$nm drifts across $n runs (diff .r-$nm.1 .r-$nm.$i)"; i=$((i + 1)); done
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; CAPN=$n; }
pub() { local nm=$1 h p; h=$(md5 -q ".r-$nm.out"); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-9s md5 %s  %s/%s  (no published hash)\n' "$nm" "$h" "$CAPN" "$CAPN"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-9s md5 %s  %s/%s  = published\n' "$nm" "$h" "$CAPN" "$CAPN"
  else printf '  %-9s md5 %s  %s/%s  DIFFERS from the published %s\n' "$nm" "$h" "$CAPN" "$CAPN" "$p"; die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
VALS=""
chk() { local nm=$1 o e=0; shift
  o=$(python3 -I -B harness/chk16.py "$nm" "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk16 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -5 >&3; die "$nm: its check failed (harness/chk16.py)"; }
  VALS="$VALS${VALS:+ · }$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }
dockeq() { local v i c n
  i=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -); v=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
  c=$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null | wc -l | tr -d ' ')
  n=$(find "$M2" -type f | wc -l | tr -d ' ')
  [ "$i" = "$IMGS0" ] || die "$1: the images moved - nothing may be pulled"
  [ "$v" = "$VOL0" ] || die "R.322: $1: the volume count is $v, not $VOL0"
  [ "$c" = 0 ] || die "$1: a Testcontainers container is still there after the run ($c)"
  [ "$n" = "$NF0" ] || die "$1: .m2-demo gained files ($NF0 -> $n) - offline: no"
  echo "  after it: images $NI0 (the same list) · volumes $VOL0 · Testcontainers containers 0 · .m2-demo's files unchanged"; }
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
# pollq WHAT WANT CMD...: read redis-cli's answer to CMD until it is WANT - a count condition, never a settle (R.412); the number of
# reads it took is printed (masked <k> in the capture: it varies run to run; .harness/polls.txt keeps each), cap 300 reads
pollq() { local what=$1 want=$2 i=0 v; shift 2
  while :; do v=$(rc "$@" | paste -sd' ' -); [ "$v" = "$want" ] && break; i=$((i + 1)); [ $i -lt 300 ] || die "a poll did not reach $want in 300 reads: redis-cli $*"; sleep 0.1; done
  printf '%s %s\n' "$CAPNM" "$i" >> .harness/polls.txt
  echo "  poll: $what -> $want, polled $i times (a count condition, cap 300 reads, under the receipt's alarm)"; }
CAPNM=""
xr() { rc XRANGE "$K" - + | paste -sd' ' - | sed -E 's/ ([0-9]{13}-[0-9]+)/ | \1/g'; }
xp() { rc XPENDING "$K" kitchen | $G . | paste -sd' ' -; }
xpx() { rc XPENDING "$K" kitchen - + 10 | paste -sd' ' -; }
xic() { rc XINFO CONSUMERS "$K" kitchen | paste -sd' ' - | sed -E 's/ (name c[0-9])/ | \1/g'; }
xig() { rc XINFO GROUPS "$K" | awk 'NR % 2 == 1 { k = $0; next } { v[k] = $0 } END { printf "name %s · consumers %s · pending %s · entries-read %s", v["name"], v["consumers"], v["pending"], (v["entries-read"] == "" ? "(nil)" : v["entries-read"]) }'; }
phsig() { local p; p=$(sed -n -E 's/^PROBE hold \(.*\): pid ([0-9]+)$/\1/p' .harness/h.log | head -1)
  [ -n "$p" ] || { echo "the receipt at pause $1: no pid line"; return 0; }
  kill -INT "$p" 2> /dev/null && echo "the receipt at pause $1: kill -INT sent to the harness JVM (its pid, read off its own line)"; }
monid() { rc CLIENT LIST | $G -E ' flags=O ' | sed -E 's/^id=([0-9]+) .*/\1/' | head -1; }
monkill() { local m; m=$(monid); [ -n "$m" ] && rc CLIENT KILL ID "$m"; }


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
pha() { echo "the receipt at pause $1, redis-cli (the container's own client) and psql - KitchenEvents' stream beside the table:"
  echo "  XLEN $K: $(rc XLEN $K) · TYPE $K: $(rc TYPE $K) · XRANGE $K - +: $(xr)"
  echo "  psql: customer rows $(psq "$PGD" 'select count(*) from customer') · rows named Asha $(psq "$PGD" "select count(*) from customer where name = 'Asha'")"
  [ "$1" != 1 ] || echo "  SCARD kitchen-order $(rc SCARD kitchen-order) · ZCARD tiffinbox:leaderboard $(rc ZCARD tiffinbox:leaderboard) (unit 14's and 15's, unchanged by unit 16)"; }
pha3() { case $1 in 4) phsig "$1" ;; *) pha "$1" ;; esac; }
anchor() { local n
  cat .harness/anchor-tests.out
  echo "-- the jar's libraries (ls lib | wc -l), before/ and after/, and the jars after/ gained or lost (comm, by name):"
  for t in before after; do echo "  $t/: $(ls .harness/$t/$XD/lib | wc -l | tr -d ' ') libraries · spring-data-redis and lettuce in lib/: $(ls .harness/$t/$XD/lib | $G -E '^(spring-data-redis|lettuce-core)-' | paste -sd' ' -)"; done
  echo "  gained: $(comm -13 <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c . || true) · lost: $(comm -23 <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c . || true)"
  echo "  the five classes in lib/spring-data-redis-4.1.2.jar (unzip -l): $(unzip -l .harness/after/$XD/lib/spring-data-redis-4.1.2.jar | awk '{ print $4 }' | $G -xE 'org/springframework/data/redis/(core/StreamOperations|stream/StreamMessageListenerContainer|listener/RedisMessageListenerContainer|listener/ChannelTopic|connection/stream/StreamOffset)\.class' | sed -E 's#^.*/##; s#\.class$##' | sort | paste -sd' ' -)"
  echo "-- after/ under the profile dev, on PostgreSQL 18.6 + Redis 8.10.3 (both containers, by the digest), three starts in a row against one Redis, a fresh database each - KitchenEvents' writes:"
  echo "  the overrides on every dev JVM: $DEV (Compose off: no Compose run; the datasource from the config tree, the password never on a command line)"
  echo "  the Redis container's own client: $(rc --version) · INFO server: $(rc INFO server | $G '^redis_version:')"
  flush
  for n in 1 2 3; do echo "-- start $n of 3:"; pgdb u16a$n
    if [ $n = 3 ]; then PH=pha3; HX=130; hj after pg 20550 http,stream,add=Asha,stream,add=Asha,stream,hold $DEV; PH=""; HX=0
    elif [ $n = 1 ]; then PH=pha; hj after pg 20550 info,http,stream,add=Asha,stream,add=Asha,stream $DEV; PH=""
    else PH=pha; hj after pg 20550 http,stream,add=Asha,stream,add=Asha,stream $DEV; PH=""; fi
    pgdrop u16a$n; done
  echo "  after the third JVM, redis-cli: XLEN $K $(rc XLEN $K) (TiffinBox stopped; the stream stays in Redis)"; }
phpub() { echo "the receipt at pause $1, redis-cli and the publisher JVM - the subscriber up:"
  pollq "PUBSUB NUMSUB $CH (until the subscriber is counted)" "$CH 1" PUBSUB NUMSUB $CH
  echo "  redis-cli PUBLISH $CH late-cli -> $(rc PUBLISH $CH late-cli)"
  pubj late-java; }
pubsub() {
  echo "-- Pub/Sub, the harness's (a publisher JVM and a subscriber JVM on the channel $CH; nothing of TiffinBox's):"
  flush
  echo "  redis-cli PUBSUB NUMSUB $CH: $(rc PUBSUB NUMSUB $CH | paste -sd' ' -) · redis-cli PUBLISH $CH early-cli -> $(rc PUBLISH $CH early-cli)"
  pubj early-java
  echo "-- the subscriber JVM, started after both early messages:"
  PH=phpub; hh sub=2; PH=""
  echo "  then redis-cli: --scan $(rc --scan | $G -c . || true) keys · PUBSUB NUMSUB $CH: $(rc PUBSUB NUMSUB $CH | paste -sd' ' -)"; }
phdrop() { echo "the receipt at pause $1, redis-cli - the subscriber up, nothing published since it connected:"
  pollq "PUBSUB NUMSUB $CH (until the subscriber is counted)" "$CH 1" PUBSUB NUMSUB $CH
  echo "  XLEN $K: $(rc XLEN $K) · XRANGE $K - +: $(xr) · --scan, sorted: $(rc --scan | sort | paste -sd' ' -)"; }
dropped() {
  echo "-- the event published before any subscriber, on the channel AND on a stream, in one window (the harness's; redis-cli writes both):"
  flush
  echo "  redis-cli PUBLISH $CH early-cli -> $(rc PUBLISH $CH early-cli) · redis-cli XADD $K * type harness-entry name early-cli mealType VEG -> $(rc XADD $K '*' type harness-entry name early-cli mealType VEG)"
  echo "  --scan, sorted: $(rc --scan | sort | paste -sd' ' -) (no key named $CH)"
  echo "-- the subscriber JVM, started after the early event (it reads its list once the receipt's go comes; no message follows):"
  PH=phdrop; hh sub=0; PH=""
  echo "  then redis-cli: XLEN $K $(rc XLEN $K) · --scan, sorted: $(rc --scan | sort | paste -sd' ' -)"; }
phc1() { echo "the receipt at pause $1, redis-cli - c1 held mid-batch by the harness (planted):"
  echo "  XPENDING $K kitchen: $(xp) · XLEN $K: $(rc XLEN $K)"
  phsig "$1"; }
groupup() {
  flush
  echo "  redis-cli XGROUP CREATE $K kitchen \$ MKSTREAM -> $(rc XGROUP CREATE $K kitchen '$' MKSTREAM) · XLEN $K: $(rc XLEN $K) · XINFO GROUPS: $(xig)"
  hh add10
  echo "  redis-cli XLEN $K: $(rc XLEN $K) · XRANGE's first entry: $(rc XRANGE $K - + COUNT 1 | paste -sd' ' -)"
  echo "-- c1 (the harness's consumer): reads 5, acknowledges 2, then the harness holds it (planted) and the receipt sends SIGINT:"
  PH=phc1; HX=130; hh c1; PH=""; HX=0
  echo "  java processes of this script after it: $(pgrep -x java | $G -c . || true)"; }
group() {
  echo "-- the consumer group on the anchor's stream key, the harness's entries and consumers (no TiffinBox):"
  groupup
  echo "  redis-cli XPENDING $K kitchen: $(xp)"
  echo "  redis-cli XPENDING $K kitchen - + 10: $(xpx)"
  echo "  redis-cli XINFO CONSUMERS $K kitchen: $(xic) · XLEN $K: $(rc XLEN $K)"
  echo "-- c2 (the harness's consumer) claims c1's pending entries and acknowledges them:"
  hh c2
  echo "  redis-cli XPENDING $K kitchen: $(xp) · XLEN $K: $(rc XLEN $K)"
  echo "-- c3 (the harness's StreamMessageListenerContainer), a MONITOR client up (dk exec, the container's own redis-cli, a second client):"
  local i=0; rm -f .harness/mon.txt; dk exec "$RN" redis-cli MONITOR > .harness/mon.txt 2>&1 < /dev/null & rpid=$!
  while [ "$(tr -d '\r' < .harness/mon.txt | head -1)" != OK ]; do i=$((i + 1)); [ $i -lt 100 ] || die "MONITOR did not answer OK"; sleep 0.1; done
  echo "  MONITOR answered OK"
  hh c3
  i=0; while ! $G -qF '"ECHO" "h16:c3-end"' .harness/mon.txt; do i=$((i + 1)); [ $i -lt 100 ] || die "MONITOR never printed the harness's end marker"; sleep 0.1; done
  echo "  CLIENT KILL ID <the MONITOR client's id, read off CLIENT LIST, flags O> -> $(monkill)"; wait "$rpid" 2> /dev/null || true; rpid=""
  echo "  MONITOR clients left (CLIENT LIST, flags O): $(rc CLIENT LIST | $G -c ' flags=O ' || true)"
  tr -d '\r' < .harness/mon.txt | sed -E 's/^[0-9]+\.[0-9]+ \[[0-9]+ [^]]*\] //' | awk '/^"ECHO" "h16:c3-start"$/ { f = 1 } f { print } /^"ECHO" "h16:c3-end"$/ { exit }' > .harness/mon-c3.txt
  echo "  MONITOR's lines between the two markers, each line's unix-time prefix and [0 <client>] stripped: XREADGROUP lines, their distinct forms: $($G '^"XREADGROUP"' .harness/mon-c3.txt | mask | sort -u | paste -sd'|' -) · XACK lines $($G -c '^"XACK"' .harness/mon-c3.txt || true), their form: $($G '^"XACK"' .harness/mon-c3.txt | mask | sort -u | paste -sd'|' -)"
  echo "  redis-cli XPENDING $K kitchen: $(xp) · XINFO GROUPS: $(xig) · XLEN $K: $(rc XLEN $K)"; }
pending() { local i r=""
  echo "-- the pending list a consumer leaves when it stops mid-batch (the harness's consumers on the anchor's stream key; no claim follows here - group's c2 is the control):"
  groupup
  echo "  redis-cli XPENDING $K kitchen: $(xp)"
  i=1; while [ $i -le 10 ]; do r="$r$(rc XPENDING $K kitchen | head -1)"; [ $i = 10 ] || sleep 0.3; i=$((i + 1)); done
  echo "  the harness holds, no consumer running: XPENDING's count, ten reads with a pause of the receipt's between each: $r"
  echo "  redis-cli XPENDING $K kitchen - + 10: $(xpx)"
  echo "  redis-cli XINFO CONSUMERS $K kitchen: $(xic) · XLEN $K: $(rc XLEN $K)"; }
trim() {
  echo "-- MAXLEN ~ 100, the harness's thousand entries on the anchor's stream key (FLUSHALL first, so the key holds them alone):"
  flush
  echo "  redis-cli CONFIG GET stream-node-max-entries: $(rc CONFIG GET stream-node-max-entries | paste -sd' ' -) · CONFIG GET stream-node-max-bytes: $(rc CONFIG GET stream-node-max-bytes | paste -sd' ' -)"
  hh trim
  echo "  redis-cli XLEN $K: $(rc XLEN $K) · TYPE $K: $(rc TYPE $K)"; }
persist() { local n0
  echo "-- the stream across a restart of its container and across a new container, on the image's own settings (the harness's ten entries and its group):"
  flush
  echo "  redis-cli XGROUP CREATE $K kitchen \$ MKSTREAM -> $(rc XGROUP CREATE $K kitchen '$' MKSTREAM)"
  hh add10
  echo "  redis-cli CONFIG GET save: $(rc CONFIG GET save | sed -n 2p) · CONFIG GET appendonly: $(rc CONFIG GET appendonly | sed -n 2p) · INFO persistence: $(rc INFO persistence | $G -E '^rdb_changes_since_last_save:') · XLEN $K: $(rc XLEN $K) · DBSIZE: $(rc DBSIZE)"
  n0=$(dk logs "$RN" 2>&1 | wc -l | tr -d ' ')
  echo "-- dk restart $RN (docker -H, a clean stop: SIGTERM, then the same container starts again):"
  bg "dk restart $RN" .harness/docker-restart.log; [ "$RE" = 0 ] || die "dk restart failed: $(tail -2 .harness/docker-restart.log)"
  pollq "PING (until Redis answers)" PONG PING
  echo "  redis-cli XLEN $K: $(rc XLEN $K) · DBSIZE: $(rc DBSIZE) · XPENDING $K kitchen: $(xp) · INFO persistence: $(rc INFO persistence | $G -E '^rdb_changes_since_last_save:')"
  dk logs "$RN" 2>&1 | tail -n +$((n0 + 1)) | tr -d '\r' > .harness/restart-log.txt
  echo "  the container's log since the restart: 'Received SIGTERM' $($G -c 'Received SIGTERM' .harness/restart-log.txt || true) · 'Saving the final RDB snapshot before exiting.' $($G -c 'Saving the final RDB snapshot before exiting.' .harness/restart-log.txt || true) · 'DB saved on disk' $($G -c 'DB saved on disk' .harness/restart-log.txt || true) · 'DB loaded from disk' $($G -c 'DB loaded from disk' .harness/restart-log.txt || true) · 'Ready to accept connections' $($G -c 'Ready to accept connections' .harness/restart-log.txt || true)"
  $G -oE 'DB loaded from disk: [0-9.]+ seconds' .harness/restart-log.txt | sed 's/^/  its line: /'
  echo "-- a NEW container from the same digest on the same port (rm -fv, then run --pull never):"
  dk rm -fv "$RN" > /dev/null 2>&1 || die "the Redis container could not be removed"; RSTARTED=""
  echo "  $RN removed with its volumes (rm -fv) · listening on 20552: $(listeners 20552)"
  runredis
  echo "  $RN: a new container, published $DR · redis-cli XLEN $K: $(rc XLEN $K) · DBSIZE: $(rc DBSIZE) · EXISTS $K: $(rc EXISTS $K) · its log: 'DB loaded from disk' $(dk logs "$RN" 2>&1 | $G -c 'DB loaded from disk' || true)"; }
default() {
  echo "-- after/ with no profile (TiffinBox's default run): H2 in memory, Docker at nothing (DOCKER_HOST=tcp://127.0.0.1:1), Redis absent (--spring.data.redis.port=20559, nothing listens: $(listeners 20559)); one JVM:"
  DOCKER_HOST=tcp://127.0.0.1:1 hj after h2 20550 info,http,noevents,add=Asha --spring.data.redis.port=20559
  echo "  the docker CLI, pinned, with DOCKER_HOST at nothing: still on the socket - images $(DOCKER_HOST=tcp://127.0.0.1:1 dk images -q 2> /dev/null | wc -l | tr -d ' ') (R.344)"
  echo "-- the 18 under mvn -o package with Docker at nothing (anchor's tests, the same run's package log):"
  results .harness/package.log; }
XA=('--spring.datasource.url=jdbc:h2:mem:x16;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --logging.level.org.hibernate.orm.core=info --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
seven() { local t i c e a port
  echo "-- Hibernate's schema script over after/'s libraries without Flyway's jars (Course 7's probe.x.XMain, scripts.action=create, a file, never run):"
  rm -f .harness/run/hibernate-ddl.sql
  echo "\$ cd .harness/run && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -cp \"../hcx:../lib-nofly/*\" probe.x.XMain \"\${XA[@]}\""
  (cd .harness/run && exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -cp "../hcx:../lib-nofly/*" probe.x.XMain "${XA[@]}") > .harness/x.log 2>&1 < /dev/null & pid=$!; e=0; wait "$pid" || e=$?; pid=""
  [ -f .harness/run/hibernate-ddl.sql ] || { tail -5 .harness/x.log >&3; die "xcheck: no script"; }
  echo "  exit $e · cmp with xcheck.sql (= Course 7's capstone's): $(cmp -s .harness/run/hibernate-ddl.sql xcheck.sql && echo 'the same, byte for byte' || echo differ)"
  for t in before after; do i=0; e=0; [ $t = after ] && port=20550 || port=20553
    echo "-- the seven: $t/'s jar, java -jar, H2 in memory (a fresh JVM), port $port:"
    echo "\$ cd .harness/$t && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port"
    (cd .harness/$t && exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port) > .harness/seven-run.log 2>&1 < /dev/null & pid=$!
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
  echo "  the shell is now in: $(where "$d2") · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines · listening on 20552 afterwards: $(listeners 20552) · a container named $EN: $(dk ps -aq --filter name=^/$EN\$ | $G -c . || true)"; }
exercise() {
  printf '%s\n' "$SETUP" > .harness/ex-readme.sh; printf '%s\n' "$SOL" > .harness/ex-sol.sh
  printf '%s\n' 'cd "$1" || exit 1' '. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-readme.st"' 'cd "$1" || exit 1' '. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-sol.st"' > .harness/ex-drive.sh
  echo "exercise/README.md's $(printf '%s\n' "$SETUP" | $G -c .) lines, then exercise/SOLUTION.md's, as written, one after the other in ONE env -i shell (HOME and the PATH this script was started with), started in this folder:"
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh; }


: > .harness/polls.txt; : > .harness/h-all.log
NCAP=1; CAPNM=exercise; cap exercise exercise; chk exercise .r-exercise.out "$EXW" "$EXQ"
for f in exercise/README.md exercise/SOLUTION.md; do
  w=$(python3 -I -B harness/chk16.py wib .r-exercise.out "$f"); [ "$(wib "$f")" = "$w" ] || die "$f's \"What it prints\" block is not what its lines printed: $(diff <(wib "$f") <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"; done
echo "  exercise: each file's \"What it prints\" block = what its lines printed (bash's; zsh's the same - chk16)"
pub exercise
export DOCKER_HOST="$DH" TESTCONTAINERS_RYUK_DISABLED=true; tests > .harness/anchor-tests.raw 2>&1 || true; unset DOCKER_HOST TESTCONTAINERS_RYUK_DISABLED
$G -q '^  \*\*\* ' .harness/anchor-tests.raw && { cat .harness/anchor-tests.raw >&3; die "the tests stopped (above)"; }
mask < .harness/anchor-tests.raw > .harness/anchor-tests.out
echo "  the tests (anchor's Maven half): run once in this run of record - their 3/3 is across the runs; the three anchor captures each carry these lines"
startdb
echo "  $(rc --version) · INFO server: $(rc INFO server | $G '^redis_version:')"
NCAP=3
for c in anchor pubsub dropped group pending trim persist default; do
  CAPNM=$c; cap $c $c; chk $c ".r-$c.out"; pub $c; done
CAPNM=seven; cap seven seven; chk seven .r-seven.out "$S466"; pub seven
echo "  the polls (R.412), each a count condition - reads it took, per capture, this run (3 runs each; masked <k> in the captures): $(awk '{ a[$1] = a[$1] (a[$1] ? "," : "") $2 } END { for (k in a) printf "%s %s; ", k, a[k] }' .harness/polls.txt | sed 's/; $//')"
echo "  the Redis harness JVMs' logs, every run of every capture together (R.410): ERROR $($G -c 'ERROR ' .harness/h-all.log || true) · RedisConnectionFailureException $($G -c RedisConnectionFailureException .harness/h-all.log || true) · 'Connection closed prematurely' $($G -c 'Connection closed prematurely' .harness/h-all.log || true) · WARN $($G -c 'WARN ' .harness/h-all.log || true), each Netty's DNS line: $($G -c "WARN .*$NETTY" .harness/h-all.log || true)"
[ "$($G -c RedisConnectionFailureException .harness/h-all.log || true)" = 0 ] && [ "$($G -c 'ERROR ' .harness/h-all.log || true)" = 0 ] || die "R.410: a RedisConnectionFailureException or an ERROR in the harness JVMs' logs"
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
  ! $G -qE ' (with PID|started by) | in [0-9.]+ seconds|Time elapsed: [0-9]|Total time: +[0-9]|execution time [0-9]|[0-9] ms\b|PT[0-9]|"BLOCK" "[0-9]| BLOCK [0-9]| idle [0-9]| inactive [0-9]|disk: [0-9]|[0-9]{13}-[0-9]|<t>-[0-9]|polled [0-9]' "$f" || die "R.402: $f holds a time, an id's time part or a block setting, unmasked"
  ! $G -qE '^[0-9]{10}\.[0-9]+ \[' "$f" || die "R.402: $f holds MONITOR's unix-time prefix"
  ! $G -qE '^ *[0-9]{4}-[0-9]{2}-[0-9]{2}[T ][0-9]|[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9]' "$f" || die "$f holds a log time"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'jdbc:h2:mem:[0-9a-f]{8}' "$f" || die "$f holds H2's generated database name, unmasked"
  ! $G -E '^ *(the receipt: )?\$ .*(^|[ (])(java|mvn) ' "$f" | $G -vF -- "perl -e '" > /dev/null || die "$f starts a JVM or Maven without its alarm (R.247)"
  ! $G -qF -- "$TOKEN" "$f" || die "$f holds the shutdown token"
  ! $G -qF -- "$PW" "$f" || die "$f holds the PostgreSQL password"; done
DC=$(cat .r-*.out | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
DR=$(awk '/^```text$/ { b = 1; next } b && /^```$/ { b = 0; next } b' README.md | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
[ "$DC" = 0 ] && [ "$DR" = 0 ] || die "R.402: dur8 finds $DC word(s) in the captures and $DR in README.md's text blocks - 0 is the rule"
[ -z "$(find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness (R.195)"
echo "  hygiene: dur8 over the captures and README.md's text blocks 0 words; no path, time, id time part, block setting, idle count, MONITOR prefix, log time, stack frame, H2 database name, raw port, pid, token or password in any capture; every JVM and Maven under its alarm; no H2 file outside .harness"
# ---- the end: the containers, Testcontainers, the volumes, the images, the trees, the ports -------------------------------------
dk rm -fv "$RN" > /dev/null 2>&1 || die "the Redis container could not be removed"; RSTARTED=""
dk rm -fv "$CN" > /dev/null 2>&1 || die "the PostgreSQL container could not be removed"; CSTARTED=""
tcrm; [ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container is still there"
[ -z "$(dk ps -aq --filter name=^/$EN\$ 2> /dev/null)" ] || die "the container $EN is still there"
VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' '); IMGS1=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -)
[ "$VOL1" = "$VOL0" ] || die "R.322: the volume count moved, $VOL0 -> $VOL1"
[ "$IMGS1" = "$IMGS0" ] || die "the images moved over this run - nothing may be pulled"
[ ! -e "$HOME/.testcontainers.properties" ] || die "R.318: ~/.testcontainers.properties appeared over this run"
echo "  docker at the end: $CN and $RN removed with their volumes (rm -fv); the exercise's $EN gone; Testcontainers containers 0; volumes $VOL0 -> $VOL1; images $NI0, the same list (nothing pulled)"
pin before-tree before end; pin after-tree after end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 20550-20559 at the end - the containers bound 20551 and 20552 (the exercise's Redis 20552 before them, persist's new container after its rm -fv) and are gone; TiffinBox bound 20550 (after/) and 20553 (before/, the seven) and stopped; 20559 never bound (Redis absent points there); 20554-20558 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c8-unit16: every capture = published (JVM captures 3/3 in this run; exercise and the tests once per run); every spoken number asserted by chk16.py; before/ and after/ = their pins; the volume count and the images unchanged"
