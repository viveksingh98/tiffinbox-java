#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 8 · Custom Repository Fragments - this unit's receipts. Section 5's first anchor change: before/ is the link to
# ../c8-unit25/after (unit 25's tree, itself unit 24's), after/ is ../c8-tiffinbox after this unit's change - OrderTotals, OrderTotalsImpl
# and CustomerTotal beside OrderDocuments, which extends OrderTotals; Revenue's route reads orders.totalsByCustomer(); MongoDatastoreIT's
# fourth test. What the repository holds, read off Spring Data Commons' own RepositoryInformation and the call's stack (the harness,
# probe.u26.H26, joined to TiffinBox under "dev" by --spring.main.sources; every line it prints says "the harness's"); the class misnamed,
# loud (a copy of after/ that fails to start) and silent (the harness's variant, a method whose name also parses); a JPA fragment with and
# without its own @Transactional (the harness's variant). Each count read twice where a store answers: the harness's Java and the
# store's own tool - MongoDB's profiler and mongosh, PostgreSQL's psql.
# Captures (the JVM ones three times and hashed unless said; exercise, lookup, why, jpatx, seven and verify once per run of record):
#   exercise    exercise/README.md's lines, then SOLUTION.md's, as written, in ONE env -i shell - bash, then zsh -f; then a wrong
#               "solution" (the class's method deleted) three times through exercise/check.sh - each must fail the check
#   anchor      the change (before/ against after/), the trees, the builds, the postfix's default (javap -v), who reads OrderDocuments;
#               after/ under dev on 20650 and before/ under dev on 20655: the start's lines, GET /revenue/by-customer byte for byte
#   composition the harness: Commons' composition of OrderDocuments, isCustomMethod / isQueryMethod, the six and their five factory beans;
#               totalsByCustomer() and findByMealType("VEG") each in its own profiler window; the call's stack; mongosh after
#   misnamed    a copy of after/ with OrderTotalsImpl renamed OrderTotalsImplementation, under dev on 20656: its exit and its failure text
#   silent      the harness's variant OrderLookup.findByCustomer: its class named OrderLookupImpl, then OrderLookupImplementation
#   lookup      (a) the harness's variant OrderTotalsImpl with @Component; (b) a copy of after/ with OrderTotalsImpl in com.tiffinbox
#   why         the harness's repository with the same pipeline as @Aggregation strings, built by Spring Data MongoDB's own factory
#   jpatx       the harness's variant CustomerWrites on CustomerEntityRepository: no @Transactional (three times), then @Transactional
#   seven       the comparison set on after/'s jar (H2, 20650) and on before/'s (H2, 20655)
#   verify      mvn verify on .harness/tests = after/ + harness/it-bindings.patch (five test files: the three older ITs bound to
#               127.0.0.1, every IT printing its own container's bindings) - the tests' counts and the five IT BINDINGS lines
# Every tree is COPIED under .harness/ and built there, offline (-o, from .m2-demo, a copy of the course's seed, maven.repo.local
# absolute), -pl tiffinbox-web -am (R.391). Every JVM and Maven run under an alarm (R.247), every JVM with SIGINT reset to its default
# (R.410). Every docker call names its socket (dk, R.344), --pull never; every container is removed with its volumes (rm -fv, R.387) and
# the volume count asserted back. No harness JVM is polled while it runs: the receipt starts it and waits for its exit (R.412).
# Ports (20650-20659): 20650 TiffinBox (after/ under dev, the harness joined; the seven on after/) · 20651 PostgreSQL c8u26-pg ·
# 20652 Redis c8u26-redis · 20653 MongoDB c8u26-mongo (a standalone) · 20654 Elasticsearch c8u26-es · 20655 TiffinBox (before/ under
# dev; the seven on before/) · 20656 the exercise's TiffinBox, and the misnamed copy's and the package copy's starts, one at a time ·
# 20657-20658 spare (asserted free) · 20659 never bound. During mvn verify only: Testcontainers' own containers on 127.0.0.1:<random>,
# and the two pinned ITs' 20578 (MongoDB) and 20615 (Elasticsearch). 18881-18884 free throughout (Compose stays off).
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
RIMG=redis@sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3
MIMG=mongo@sha256:05b334b0a7a78fe913caac0cd2e1ecccf4da515d9a3a44be911b6ea3734c17cd
EIMG=docker.elastic.co/elasticsearch/elasticsearch@sha256:fb7f2d0df199b3ea14a700e88a0b701d502cb44409ece3e1540b1dc1c5d5c403
ETAG=docker.elastic.co/elasticsearch/elasticsearch:9.4.8
GT=glibc.pthread.rseq=1
CN=c8u26-pg; RN=c8u26-redis; MN=c8u26-mongo; EN=c8u26-es; XC="c8u26-ex-pg c8u26-ex-redis c8u26-ex-mongo c8u26-ex-es"
ESSET="-e discovery.type=single-node -e xpack.security.enabled=false -e xpack.ml.enabled=false -e ingest.geoip.downloader.enabled=false -e xpack.inference.elastic.authorization.enabled=false"
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
pid=""; mpid=""; xpid=""; TC0=""; INTR=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.u26.") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "curlset.sh") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || $3 ~ /(^|\/)javac$/ || index($0, "ex-drive")) { print $1 }' | paste -sd' ' -) || l=""
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
ctrm() { local c; [ -n "$TC0" ] || return 0
  for c in $CN $RN $MN $EN $XC; do [ -z "$(dk ps -aq --filter name=^/$c\$ 2> /dev/null)" ] || dk rm -fv "$c" > /dev/null 2>&1 || true; done; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid" "$pid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; tcrm; ctrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff patch find curl openssl docker git unzip javap /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|FLYWAY_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|REDIS[A-Z_]*|MONGO[A-Z_]*|ES_[A-Z_]*|ELASTIC[A-Z_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT|COMPOSE_[A-Z_]*)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"

# ---- gates before anything is written: the folder, the links, the pins, the prose, the exercise ------------------------------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk26.py dur8.py it-bindings.patch logback.xml s826.py src tree26.py variants' ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe/u26/H26.java' ] || die "harness/ holds another file, or misses one"
[ "$(cd harness/variants && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'comp/com/tiffinbox/web/OrderTotalsImpl.java jpa/com/tiffinbox/CustomerEntityRepository.java jpa/com/tiffinbox/CustomerWrites.java jpa/com/tiffinbox/CustomerWritesImpl.java jpatx/com/tiffinbox/CustomerWritesImpl.java silent/com/tiffinbox/web/OrderDocuments.java silent/com/tiffinbox/web/OrderLookup.java silent/com/tiffinbox/web/OrderLookupImpl.java silentbad/com/tiffinbox/web/OrderDocuments.java silentbad/com/tiffinbox/web/OrderLookup.java silentbad/com/tiffinbox/web/OrderLookupImplementation.java' ] || die "harness/variants holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'OrderTotalsImplementation.java README.md SOLUTION.md check.sh' ] || die "exercise/ holds another file, or misses one"
cmp -s harness/dur8.py ../c8-unit02/harness/dur8.py || die "harness/dur8.py is not the builders' dur8.py as unit 02 shipped it, byte for byte"
cmp -s harness/logback.xml ../c8-unit07/harness/logback.xml || die "harness/logback.xml is not unit 07's, byte for byte"
[ -L before ] && [ "$(readlink before)" = ../c8-unit25/after ] || die "R.250/RED #28: before must be a link whose text is ../c8-unit25/after (it is: $(readlink before 2> /dev/null || echo 'not a link'))"
[ -d after ] && [ ! -L after ] || die "after/ must be this unit's own tree, not a link"
for t in after; do [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] && die "$t holds a secrets/ or a target/ - never built in place"; true; done
git rev-parse -q --verify '8acdd4b^{commit}' > /dev/null 2>&1 || die "unit 25's commit 8acdd4b is not in this repository's history"
U25P=$(awk '$1 == "after-tree" { print $2, $3 }' ../c8-unit25/receipts.md5)
[ -n "$U25P" ] || die "../c8-unit25/receipts.md5 has no after-tree line"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree26.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  if [ "$nm" = before-tree ]; then [ "$want" = "$U25P" ] || die "R.250: receipts.md5's before-tree line ($want) is not ../c8-unit25/receipts.md5's after-tree line ($U25P)"
  else [ "$want" != "$U25P" ] || die "after-tree equals unit 25's - this unit changes the anchor"; fi
  echo "  $dir/ ($3): python3 -I harness/tree26.py $dir/ -> $got = receipts.md5's $nm line$( [ "$nm" = before-tree ] && echo " = ../c8-unit25/receipts.md5's after-tree line")"; }
pin before-tree before start; pin after-tree after start
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c8-tiffinbox 2>&1 || true)
[ -z "$AD" ] || die "flag 5: ../c8-tiffinbox is not after/ (diff -rq: $(printf '%s\n' "$AD" | head -2 | paste -sd';' -))"
echo "  after/ against ../c8-tiffinbox (diff -rq, .m2-demo target secrets .harness left out): empty - the anchor is this unit's after/"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s826.py harness/dur8.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -2 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S5 12 families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
DN=$($G -rniwE -- "$DISH" README.md exercise harness/src harness/variants 2> /dev/null | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|VALUES-PENDING|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md exercise harness/src harness/variants 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
! $G -q '^```java$' README.md || die "README.md holds a java block - the code is the anchor's files, the harness's and the exercise's"
GLOSS="A repository fragment: an interface of your own, and a class named after it, whose method the repository hands to that class."
[ "$($G -cxF -- "$GLOSS" README.md)" = 1 ] || die "the gloss (SECTION SHAPE 26) must stand in README.md once, as a line of its own, byte for byte"
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
EXQ="Your turn: TiffinBox stops at the start, no property totalsByCustomer found for type OrderDocument. Make the repository find the class that holds that method."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SETUP=$(block exercise/README.md); SOL=$(block exercise/SOLUTION.md)
[ -n "$SETUP" ] && [ -n "$SOL" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
[ "$(diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G -c '^[<>]')" = 2 ] || die "R.196: SOLUTION.md's block must be the README's with one line changed"
CPL='cp exercise/OrderTotalsImplementation.java "$EX/tb/$W/OrderTotalsImplementation.java"'
[ "$(printf '%s\n' "$SETUP" | $G -cxF "$CPL")" = 1 ] || die "R.196: the README's block copies exercise/OrderTotalsImplementation.java as shipped"
DELP=$(printf '%s\n' "$SETUP" | awk -v c="$CPL" '$0 == c { print "perl -0pe '"'"'s/\\n    \\/\\*\\* One aggregate.*?\\n    \\}\\n//s'"'"' exercise/OrderTotalsImplementation.java > \"$EX/tb/$W/OrderTotalsImplementation.java\""; next } { print }')
[ "$(diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$DELP") | $G -c '^[<>]')" = 2 ] || die "the wrong \"solution\" must be the README's block with one line changed"
printf '%s\n' "$SETUP" | $G -E '(^|[ (])(mvn|java|javac) ' | $G -vqF "perl -e '" && die "exercise/README.md's Java and Maven runs must run under their alarm (R.247)"
printf '%s\n' "$SETUP" | $G -E 'mvn ' | $G -vqF -- '-pl tiffinbox-web -am' && die "R.391: exercise/README.md builds without -pl tiffinbox-web -am"
printf '%s\n' "$SETUP" | $G -E '(^|[ ;&(])docker ' | $G -vqF 'docker -H "$DH" ' && die "R.344: exercise/README.md calls docker without its socket (docker -H \"\$DH\")"
printf '%s\n' "$SETUP" | $G -qxF "docker -H \"\$DH\" rm -fv $XC > /dev/null" || die "R.387: the exercise's four containers are removed with their volumes (rm -fv)"
printf '%s\n' "$SETUP" | $G -E 'docker -H "\$DH" run .*mongo:8' | $G -qF "GLIBC_TUNABLES=$GT" || die "R.421: the exercise's MongoDB runs with GLIBC_TUNABLES"
printf '%s\n' "$SETUP" | $G -E 'docker -H "\$DH" run .*elasticsearch:9\.4\.8' | $G -qF -- "$ESSET -e \"ES_JAVA_OPTS=-Xms512m -Xmx512m\"" || die "R.437: the exercise's Elasticsearch runs with the six settings"
printf '%s\n' "$SETUP" | $G -qxF 'bash exercise/check.sh "$EX"' || die "R.196: the exercise is checked by exercise/check.sh (the start's line and the route's totals), never by the exit"
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
WP=tiffinbox-web/src/main/java/com/tiffinbox/web
[ "$(sed 's/^public class OrderTotalsImplementation implements/public class OrderTotalsImpl implements/; s/^    OrderTotalsImplementation(MongoTemplate/    OrderTotalsImpl(MongoTemplate/' exercise/OrderTotalsImplementation.java | md5 -q)" = "$(md5 -q after/$WP/OrderTotalsImpl.java)" ] && [ "$($G -c OrderTotalsImplementation exercise/OrderTotalsImplementation.java)" = 2 ] || die "exercise/OrderTotalsImplementation.java must be after/'s OrderTotalsImpl.java with its class and constructor renamed, nothing else"
[ "$(sed 's/OrderTotalsImplementation/OrderTotalsImpl/' exercise/OrderTotalsImplementation.java | md5 -q)" = "$(md5 -q after/$WP/OrderTotalsImpl.java)" ] || die "SOLUTION.md's sed must give after/'s OrderTotalsImpl.java back, byte for byte"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket (docker -H \"\$DH\")"
DK=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -vF 'echo "' | $G -nE '\bdocker (run|exec|rm|ps|port|info|images|volume|image|pull|events|compose|network|restart|logs|stop|start|inspect|stats)\b' | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.344: receipts.sh calls docker without the pinned socket (every call is dk): $DK"
RMF=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) rm( +-[a-z]+)*' | sort -u | paste -sd'|' -)
[ "$RMF" = 'dk rm -fv' ] || die "R.387: receipts.sh removes a container without its volumes - every removal is dk rm -fv (found: ${RMF:-none})"
RUNP=$($G -v '^ *#' receipts.sh | $G -oE '(dk|docker) run -[^"]*' | $G -vcF -- '--pull never' || true)
[ "$RUNP" = 0 ] || die "R.344: a dk run without --pull never"
MRUN=$($G -v '^ *#' receipts.sh | $G -E '(dk|docker) run ' | $G -F '$MIMG' | $G -vcF 'GLIBC_TUNABLES=$GT' || true)
[ "$MRUN" = 0 ] || die "R.421: a MongoDB container run without GLIBC_TUNABLES"
ERUN=$($G -v '^ *#' receipts.sh | $G -E '(dk|docker) run ' | $G -F '$EIMG' | awk '!(index($0, "$ESSET") && index($0, "ES_JAVA_OPTS=-Xms512m -Xmx512m"))' | wc -l | tr -d ' ')
[ "$ERUN" = 0 ] || die "R.437: an Elasticsearch container run without the six settings"
XE=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) exec [$"][^ ]+ [a-z_-]+( /proc/[a-z_/$]+)?' | awk '{ print $4 ($5 ? " " $5 : "") }' | sort -u | paste -sd'|' -)
[ "$XE" = 'cat /proc/net/$t|cat /proc/net/dev|mongosh|pg_isready|psql|redis-cli' ] || die "every exec into a container here reads a /proc file by cat, or is the store's own client - never a shell (found: $XE)"
[ -z "$($G -v '^ *#' receipts.sh | $G -E '(dk|docker) run ' | $G -oE -- ' -p [^ ]+' | $G -v '^ -p 127\.0\.0\.1:' || true)" ] && [ -z "$(printf '%s\n' "$SETUP" | $G -E 'docker -H "\$DH" run ' | $G -oE -- ' -p [^ ]+' | $G -v '^ -p 127\.0\.0\.1:' || true)" ] || die "S8.94: a port published on every interface (-p without 127.0.0.1)"
MVA=$($G -v '^ *#' receipts.sh | $G -F 'clean ' | $G -F '$MV' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am"
[ -z "$($G -rhE --include='*.java' '@Enable[A-Za-z]*Repositories' harness/src harness/variants exercise | $G -vE '^[[:space:]]*(\*|//|/\*)' || true)" ] || die "S8.101: an @Enable...Repositories in the harness or the exercise - it would switch Boot's scan off"
ST=$(python3 -I -B harness/chk26.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
echo "  prose, per sentence (s826, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test, XFAM_S5's 12 families among them): refused 0 over $PROSE · dish names 0 · placeholders 0 · no java block · the gloss once, byte for byte"
echo "  the exercise: the spoken line $EXW words (wc -w); SOLUTION.md's block = the README's with one line changed; the wrong \"solution\" = the README's block with one other line changed; the two \"What it prints\" blocks differ (R.196); checked by exercise/check.sh, never the exit; its containers on 127.0.0.1:20651-20654, removed with their volumes; its MongoDB with GLIBC_TUNABLES, its Elasticsearch with the six settings; its build -pl tiffinbox-web -am; its docker calls on the socket; its class = after/'s OrderTotalsImpl renamed, and SOLUTION.md's sed gives that file back byte for byte"
echo "  static: no kill by name; every docker call on the pinned socket, every dk run --pull never, every MongoDB container with GLIBC_TUNABLES and every Elasticsearch container with the six settings; no exec into a container but cat of a /proc file and the stores' own clients; no port on every interface (S8.94); every removal dk rm -fv (R.387); every Maven build -pl tiffinbox-web -am (R.391); no @Enable...Repositories in the harness, its variants or the exercise (S8.101)"
mask() { awk -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(PE, "…"); gsub(P, "…"); gsub(QE, "…/.."); gsub(Q, "…/.."); gsub(H, "~")
    gsub(/ in [0-9.]+ seconds \(process running for [0-9.]+\)/, " in <t> (process running for <t>)")
    gsub(/\(execution time [0-9:.]+s\)/, "(execution time <t>)")
    gsub(/scanning in [0-9]+ ms/, "scanning in <t>")
    gsub(/initialization completed in [0-9]+ ms/, "initialization completed in <t>")
    gsub(/Total time: +[0-9.:]+ [a-z]+/, "Total time: <t>")
    gsub(/Time elapsed: [0-9.]+ s/, "Time elapsed: <t>")
    gsub(/started in PT[0-9HMS.]+/, "started in <t>")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/pid [0-9]+/, "pid <n>")
    gsub(/"lsid":\{[^}]*\}\}?/, "\"lsid\":<session>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    gsub(/\.\.\. [0-9]+ common frames omitted/, "... <n> common frames omitted")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'Finished Spring Data repository scanning in 23 ms. Found 1 JPA repository interface.' 'Root WebApplicationContext: initialization completed in 812 ms' 'Successfully applied 4 migrations (execution time 00:00.026s)' 'Total time:  12.345 s' 'Tests run: 2, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 84.22 s' 'Container docker.elastic.co/elasticsearch/elasticsearch started in PT1M34.764508S' 'the receipt: pid 41231' "$U/x $HOME/y" | mask)
printf '%s\n' "$MP" | python3 -I -B -c 'import importlib.util,sys,re; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=sys.stdin.read(); sys.exit(1 if m.DUR.search(t) or "3.1 sec" in t or "00:00.026" in t or "812" in t or "12.345" in t or "41231" in t or "23 ms" in t or "84.22" in t or "PT1M34" in t else 0)' || die "R.432: the mask's self-test - a planted duration or pid passed it unmasked: $(printf '%s\n' "$MP" | head -2 | paste -sd';' -)"
[ "$(printf '%s\n' "$MP" | tail -1)" = '…/x ~/y' ] || die "the mask's self-test: the folders and the home must be masked"
echo "  mask: its self-test refused the planted Started-in-seconds, scanning, initialization, execution-time, Total time, Time elapsed, started in PT…S and pid readings unmasked (R.432, TIMEPAT_S5's members); folders and home masked"
CURLSET=../c5-unit11/curlset.sh
[ -x "$CURLSET" ] || die "$CURLSET is missing - the comparison set the seven runs"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"

# ---- docker and ports: the baselines -------------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that socket? (R.344)"
IMGS0=$(dk images -q --no-trunc 2> /dev/null | sort -u | paste -sd' ' -); NI0=$(printf '%s\n' "$IMGS0" | wc -w | tr -d ' ')
VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI0" -ge 1 ] && [ "$VOL0" -ge 1 ] || die "the baselines must not be empty - images $NI0, volumes $VOL0"
iid() { dk image inspect --format '{{.Id}}' "$1" 2> /dev/null | cut -c8-19; }
[ "$(iid $IMG)" = 77f585114c32 ] || die "the image $IMG is not on this machine - this script never pulls; docker -H \"\$DH\" pull $IMG is yours to run"
[ "$(iid $RIMG)" = 7958cfbb9d15 ] || die "the image $RIMG is not on this machine - this script never pulls; docker -H \"\$DH\" pull $RIMG is yours to run"
[ "$(iid $MIMG)" = 05b334b0a7a7 ] || die "the image $MIMG is not on this machine - this script never pulls; docker -H \"\$DH\" pull $MIMG is yours to run"
[ "$(iid $EIMG)" = fb7f2d0df199 ] || die "the image $EIMG is not on this machine - this script never pulls; docker -H \"\$DH\" pull $EIMG is yours to run"
[ "$(iid mongo:8) $(iid postgres:18-alpine) $(iid redis:8-alpine) $(iid $ETAG)" = '05b334b0a7a7 77f585114c32 7958cfbb9d15 fb7f2d0df199' ] || die "the tags the exercise names (mongo:8, postgres:18-alpine, redis:8-alpine, $ETAG) are not on this machine at the course's digests - its containers would be pulled; this script never pulls"
RY0=$(dk images --format '{{.Repository}}' 2> /dev/null | $G -c ryuk || true)
[ "$RY0" = 0 ] || die "R.318: an image named ryuk is on this machine ($RY0) - Ryuk stays off and none is pulled"
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run - remove it with its volumes: docker -H \"\$DH\" rm -fv <id>"
for c in $CN $RN $MN $EN $XC; do [ -z "$(dk ps -aq --filter name=^/$c\$ 2> /dev/null)" ] || die "a container named $c exists before the run - an interrupted run's? docker -H \"\$DH\" rm -fv $c"; done
TC0=1
[ ! -e "$HOME/.testcontainers.properties" ] || die "R.318: ~/.testcontainers.properties exists - this unit's Testcontainers JVMs read a receipt home under .harness/ only"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18881 18882 18883 18884 20578 20615 20650 20651 20652 20653 20654 20655 20656 20657 20658 20659"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
[ "$(pgrep -x java | wc -l | tr -d ' ')" = 0 ] || die "a java process is running before this script starts one - not this script's; stop it first"
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · the four digests present ($IMG, $RIMG, $MIMG, $EIMG) · mongo:8, postgres:18-alpine, redis:8-alpine and $ETAG on those digests · nothing pulled, ever · images named ryuk $RY0 · Testcontainers containers 0 · ports 20650-20659, 20578, 20615, 18881-18884 free · java processes 0"

# ---- the trees, copied; the builds; the tests' copy; the harness and its variants, compiled ---------------------------------------
rm -rf .harness; mkdir -p .harness/run-dev/secrets/tiffinbox .harness/home
M2="$PWD/.m2-demo"
[ -d "$M2" ] || die ".m2-demo (a copy of the course's seed, _research/m2-seed-c8-s4b) is missing - README.md, The repository"
NF0=$(find "$M2" -type f | wc -l | tr -d ' ')
echo "  .m2-demo's files $NF0 (the seed's 7,265 - no new artifact: this unit adds no dependency)"
printf '%s\n' 'checks.disable=true' "tinyimage.container.image=$IMG" > .harness/home/.testcontainers.properties
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy after .harness/after; copy before .harness/before; copy after .harness/tests; copy after .harness/misnamed; copy after .harness/pkg
(cd .harness/tests && patch -s -p1 < ../../harness/it-bindings.patch) || die "harness/it-bindings.patch did not apply to the tests' copy"
# the misnamed copy: after/ with exercise/OrderTotalsImplementation.java in place of OrderTotalsImpl.java (the exercise's broken tree)
rm .harness/misnamed/$WP/OrderTotalsImpl.java && cp exercise/OrderTotalsImplementation.java .harness/misnamed/$WP/OrderTotalsImplementation.java || die "the misnamed copy"
# the package copy: after/ with OrderTotalsImpl moved to com.tiffinbox, above the repository's package (its package line and its import)
mkdir -p .harness/pkg/tiffinbox-web/src/main/java/com/tiffinbox && perl -pe 's/^package com\.tiffinbox\.web;$/package com.tiffinbox;/; s/^(import org\.springframework\.data\.mongodb\.core\.MongoTemplate;)$/import com.tiffinbox.web.CustomerTotal;\nimport com.tiffinbox.web.OrderDocument;\nimport com.tiffinbox.web.OrderTotals;\n$1/' after/$WP/OrderTotalsImpl.java > .harness/pkg/tiffinbox-web/src/main/java/com/tiffinbox/OrderTotalsImpl.java && rm .harness/pkg/$WP/OrderTotalsImpl.java || die "the package copy"
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE '^\[INFO\] Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 900; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
AL="-DargLine=$JL -Dstdout.encoding=UTF-8 -Duser.home=../../home"
for t in after before misnamed pkg; do
  bg "cd .harness/$t && $MV clean package -DskipTests -pl tiffinbox-web -am" .harness/build-$t.log
  [ "$RE" = 0 ] || { tail -20 .harness/build-$t.log | mask >&3; die ".harness/$t did not build offline (exit $RE)"; }; offl .harness/build-$t.log
  bg "cd .harness/$t && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$t.log
  [ "$RE" = 0 ] || die ".harness/$t: the jar's extract failed"; done
CPA=".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \"$CPA\" harness/src/probe/u26/H26.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/'s jar: $(head -5 .harness/javac.log)"
for v in silent silentbad comp jpa; do
  bg "cd harness/variants/$v && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -d ../../../.harness/v/$v -cp \"../../../.harness/after/$XD/tiffinbox-web-1.0.0.jar:../../../.harness/after/$XD/lib/*\" \$(find . -name '*.java' | sort)" .harness/javac-$v.log
  [ "$RE" = 0 ] || die "the harness's variant $v did not compile: $(head -5 .harness/javac-$v.log)"; done
bg "cd harness/variants && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -d ../../.harness/v/jpatx -cp \"../../.harness/after/$XD/tiffinbox-web-1.0.0.jar:../../.harness/after/$XD/lib/*\" jpa/com/tiffinbox/CustomerEntityRepository.java jpa/com/tiffinbox/CustomerWrites.java jpatx/com/tiffinbox/CustomerWritesImpl.java" .harness/javac-jpatx.log
[ "$RE" = 0 ] || die "the harness's variant jpatx did not compile: $(head -5 .harness/javac-jpatx.log)"
TF=secrets/tiffinbox/shutdown-token
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/run-dev/$TF) || die "the token was not written"
for t in after before; do mkdir -p .harness/$t/secrets/tiffinbox && (umask 077 && cp .harness/run-dev/$TF .harness/$t/$TF) || die "the token was not copied"; done
TOKEN=$(head -1 .harness/run-dev/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
echo "  built after/, before/, the misnamed copy and the package copy offline (mvn -o package -DskipTests -pl tiffinbox-web -am, exit 0 each, 'Downloaded from' 0) and extracted each jar; compiled the harness (harness/src/probe/u26/H26.java, javac 25 -cp \"<after/'s jar>:<its lib/*>\", $(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes) and its five variants (silent, silentbad, comp, jpa, jpatx: $(find .harness/v -name '*.class' | wc -l | tr -d ' ') classes, each compiled against after/'s jar, each first on its JVM's class path); the tests' copy .harness/tests = after/ + harness/it-bindings.patch; a shutdown token generated (0600, never printed)"

# ---- helpers -------------------------------------------------------------------------------------------------------------------
vols() { dk volume ls -q 2> /dev/null | wc -l | tr -d ' '; }
pgready() { local i=0; while ! dk exec "$1" pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 240 ] || die "PostgreSQL ($1) did not accept connections (240 tries)"; sleep 0.5; done; }
psq() { dk exec "$CN" psql -U tiffinbox -d "$1" -qAt -v ON_ERROR_STOP=1 -c "$2" 2>&1 || die "psql failed on $CN/$1: $2"; }
ms() { dk exec "$MN" mongosh --quiet 'mongodb://127.0.0.1:27017/tiffinbox' --eval "$1" 2>&1 | tail -1; }
rc() { dk exec "$RN" redis-cli "$@" 2>&1 | tr -d '\r'; }
eq() { curl -s --noproxy '*' -X "$1" "http://127.0.0.1:20654$2" 2> /dev/null; }
esup() { local i=0 c; while :; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:20654/_cluster/health" 2> /dev/null || true); [ "$c" = 200 ] && break
    i=$((i + 1)); [ $i -lt 960 ] || die "Elasticsearch on 20654 did not answer _cluster/health 200 (960 reads)"; sleep 0.25; done; }
mkmongo() { local i=0
  bg "dk run -d --pull never --name $MN -p 127.0.0.1:20653:27017 -e GLIBC_TUNABLES=$GT $MIMG --unixSocketPrefix /data/db" .harness/docker-run-mongo.log
  [ "$RE" = 0 ] || die "the MongoDB container did not start: $(tail -2 .harness/docker-run-mongo.log)"
  while [ "$(ms 'print(db.runCommand({ping: 1}).ok)')" != 1 ]; do i=$((i + 1)); [ $i -lt 240 ] || die "MongoDB did not answer mongosh's ping (240 reads)"; sleep 0.25; done
  [ "$(dk port $MN | paste -sd'|' -)" = '27017/tcp -> 127.0.0.1:20653' ] || die "$MN publishes on another address than 127.0.0.1:20653"; }
stores() {
  echo "\$ docker -H \"\$DH\" run -d --pull never --name $CN -p 127.0.0.1:20651:5432 -e POSTGRES_DB=tiffinbox -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust $IMG -c log_statement=all"
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:20651:5432 -e POSTGRES_DB=tiffinbox -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust $IMG -c log_statement=all" .harness/docker-run-pg.log
  [ "$RE" = 0 ] || die "the PostgreSQL container did not start: $(tail -2 .harness/docker-run-pg.log)"
  echo "\$ docker -H \"\$DH\" run -d --pull never --name $RN -p 127.0.0.1:20652:6379 $RIMG"
  bg "dk run -d --pull never --name $RN -p 127.0.0.1:20652:6379 $RIMG" .harness/docker-run-redis.log
  [ "$RE" = 0 ] || die "the Redis container did not start: $(tail -2 .harness/docker-run-redis.log)"
  echo "\$ docker -H \"\$DH\" run -d --pull never --name $MN -p 127.0.0.1:20653:27017 -e GLIBC_TUNABLES=$GT $MIMG --unixSocketPrefix /data/db   (a fresh one before every TiffinBox JVM)"
  echo "\$ docker -H \"\$DH\" run -d --pull never --name $EN --hostname $EN -p 127.0.0.1:20654:9200 $ESSET -e \"ES_JAVA_OPTS=-Xms512m -Xmx512m\" $EIMG"
  bg "dk run -d --pull never --name $EN --hostname $EN -p 127.0.0.1:20654:9200 $ESSET -e \"ES_JAVA_OPTS=-Xms512m -Xmx512m\" $EIMG" .harness/docker-run-es.log
  [ "$RE" = 0 ] || die "the Elasticsearch container did not start: $(tail -2 .harness/docker-run-es.log)"
  pgready $CN; esup
  local i=0; while [ "$(rc PING)" != PONG ]; do i=$((i + 1)); [ $i -lt 200 ] || die "Redis did not answer PING"; sleep 0.1; done
  [ "$(dk port $CN | paste -sd'|' -)" = '5432/tcp -> 127.0.0.1:20651' ] && [ "$(dk port $RN | paste -sd'|' -)" = '6379/tcp -> 127.0.0.1:20652' ] && [ "$(dk port $EN | paste -sd'|' -)" = '9200/tcp -> 127.0.0.1:20654' ] || die "a store publishes on another address than 127.0.0.1:<its port>"
  echo "  the unit's stores: $CN (PostgreSQL $(psq tiffinbox 'show server_version'), log_statement $(psq tiffinbox 'show log_statement')), $RN ($(rc INFO server | $G '^redis_version:')), $EN (version.number $(eq GET / | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["version"]["number"])'), 9300 not published), each on 127.0.0.1 alone (dk port); volumes now $(vols) (the machine's $VOL0 + PostgreSQL's one)"
  echo "  $EN's environment, the six (dk inspect): $(dk inspect -f '{{json .Config.Env}}' $EN | python3 -I -c 'import json,sys; print(" · ".join(sorted(e for e in json.load(sys.stdin) if e.split("=")[0] in ("discovery.type","xpack.security.enabled","xpack.ml.enabled","ingest.geoip.downloader.enabled","xpack.inference.elastic.authorization.enabled","ES_JAVA_OPTS"))))')"; }
# fresh: before every TiffinBox JVM - a new tiffinbox database, Redis emptied, a new MongoDB container, the dishes index gone
fresh() { local v
  psq postgres "drop database if exists tiffinbox with (force)" > /dev/null; psq postgres "create database tiffinbox" > /dev/null
  [ "$(rc FLUSHALL)" = OK ] || die "redis-cli FLUSHALL failed"
  [ -z "$(dk ps -aq --filter name=^/$MN\$)" ] || dk rm -fv $MN > /dev/null 2>&1 || die "the MongoDB container could not be removed"
  mkmongo
  v=$(eq DELETE /dishes | python3 -I -c 'import json,sys; d=json.load(sys.stdin); print("acknowledged" if d.get("acknowledged") else d.get("error", {}).get("type", "?"))')
  echo "  fresh stores: database tiffinbox dropped and created (psql) · redis-cli FLUSHALL OK · DBSIZE $(rc DBSIZE) · a new $MN (mongosh ping 1, db.orders.countDocuments() $(ms 'print(db.orders.countDocuments())')) · DELETE /dishes -> $v"; }
DEV="--spring.profiles.active=dev --spring.docker.compose.enabled=false --tiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:20651/tiffinbox?user=tiffinbox --spring.datasource.username=tiffinbox --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20652 --spring.mongodb.uri=mongodb://127.0.0.1:20653/tiffinbox --spring.elasticsearch.uris=http://127.0.0.1:20654"
DEVP="--spring.profiles.active=dev --spring.docker.compose.enabled=false <the four stores' addresses by property, 127.0.0.1:20651-20654>"
# h26 OUT VARIANT ARGS..: TiffinBox (after/'s jar) under dev on the unit's four stores, the harness joined and the variant's classes (if
# any) first on the class path, from .harness/run-dev, under its alarm; no polling while it runs - the receipt waits for its exit
h26() { local o=$1 v=$2 e=0 xc=""; shift 2
  mkdir -p "$o"; [ "$v" = none ] || xc="../v/$v:"
  (cd .harness/run-dev && exec perl -e '$SIG{INT}="DEFAULT"; alarm 300; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -Duser.home=../home -cp "$xc../hc:../after/$XD/tiffinbox-web-1.0.0.jar:../after/$XD/lib/*" com.tiffinbox.web.TiffinBoxServer --logging.config=../../harness/logback.xml --tiffinbox.port=20650 $DEV --spring.main.sources=probe.u26.H26 "$@") > "$o/jvm.log" 2>&1 < /dev/null & pid=$!
  wait "$pid" || e=$?; pid=""
  echo "$e" > "$o/exit"; }
h26cl() { local v=$1; shift; echo "\$ cd .harness/run-dev && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 300; exec @ARGV' java $JL -cp \"$( [ "$v" = none ] || echo "../v/$v:")../hc:<after/'s jar>:<its lib/*>\" com.tiffinbox.web.TiffinBoxServer --logging.config=../../harness/logback.xml --tiffinbox.port=20650 $DEVP --spring.main.sources=probe.u26.H26 $*"; }
# tbfail OUT TREE PORT: a copy's jar under dev on PORT with Boot's own logging (its failure report whole), waited for (it stops by itself)
tbfail() { local o=$1 t=$2 port=$3 e=0
  mkdir -p "$o"
  (cd .harness/run-dev && exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -Duser.home=../home -jar ../$t/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port $DEV) > "$o/jvm.log" 2>&1 < /dev/null & pid=$!
  wait "$pid" || e=$?; pid=""
  echo "$e" > "$o/exit"; }
# tbroute OUT TREE PORT: a tree's jar under dev on PORT (the harness's logback), readiness polled - no witness window is open here -
# then GET /revenue/by-customer and GET /kitchen, then POST /shutdown with the token; waited for its exit
tbroute() { local o=$1 t=$2 port=$3 e=0 i=0 c=""
  mkdir -p "$o"
  (cd .harness/run-dev && exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -Duser.home=../home -jar ../$t/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --logging.config=../../harness/logback.xml --tiffinbox.port=$port $DEV) > "$o/jvm.log" 2>&1 < /dev/null & pid=$!
  while [ $i -lt 480 ]; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 "$o/jvm.log" | mask >&3; die "TiffinBox ($t) exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $port"
  lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' - > "$o/listen"
  curl -s --noproxy '*' "http://127.0.0.1:$port/revenue/by-customer" > "$o/rbc.json"; curl -s --noproxy '*' "http://127.0.0.1:$port/kitchen" > "$o/kitchen.json"
  printf 'X-Shutdown-Token: %s\n' "$TOKEN" | curl -s --noproxy '*' -o "$o/shutdown.json" -H @- -X POST "http://127.0.0.1:$port/shutdown"
  wait "$pid" || e=$?; pid=""
  [ "$(listeners $port)" = 0 ] || die "something still listens on $port"
  echo "$e" > "$o/exit"; }
NCAP=3
unpub=""; CAPRUN=0; CAPNM=""
cap() { local nm=$1 i n=$NCAP; shift
  i=1; while [ $i -le $n ]; do CAPRUN=$i; CAPNM=$nm; "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    $G -q '^  \*\*\* ' .harness/cap.raw && { cat .harness/cap.raw >&3; die "$nm stopped (above)"; }
    ! $G -qE 'localhost:[0-9]{5}|127\.0\.0\.1:(3|4|5|6)[0-9]{4}' .harness/cap.raw || die "R.319: $nm printed a container's port raw"
    mask < .harness/cap.raw > ".r-$nm.$i"; cp .harness/cap.raw ".harness/raw-$nm.$i"; i=$((i + 1)); done
  CHH=$(md5 -q ".r-$nm.1")
  i=2; while [ $i -le $n ]; do [ "$CHH" = "$(md5 -q ".r-$nm.$i")" ] || die "$nm drifts across $n runs (diff .r-$nm.1 .r-$nm.$i)"; i=$((i + 1)); done
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; CAPN=$n; }
pub() { local nm=$1 h p; h=$(md5 -q ".r-$nm.out"); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-11s md5 %s  %s/%s  (no published hash)\n' "$nm" "$h" "$CAPN" "$CAPN"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-11s md5 %s  %s/%s  = published\n' "$nm" "$h" "$CAPN" "$CAPN"
  else printf '  %-11s md5 %s  %s/%s  DIFFERS from the published %s\n' "$nm" "$h" "$CAPN" "$CAPN" "$p"; die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
VALS=""
chk() { local nm=$1 o e=0; shift
  o=$(python3 -I -B harness/chk26.py "$nm" "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk26 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -5 >&3; die "$nm: its check failed (harness/chk26.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }

# ---- the captures --------------------------------------------------------------------------------------------------------------
JMON=.m2-demo/org/springframework/data/spring-data-mongodb/5.1.2/spring-data-mongodb-5.1.2.jar
startlines() { $G -E 'Multiple Spring Data modules found|Could not safely identify store assignment|Finished Spring Data repository scanning|Successfully applied [0-9]+ migrations' "$1" | sed -E 's/^[A-Z]+ +\[[^]]*\] [^ ]+ : //' | mask | sort | uniq -c | sed -E 's/^ +([0-9]+) /    (x\1) /'; }
anchor() { local A=.harness/anchor-$CAPRUN B=.harness/anchorb-$CAPRUN f
  echo "-- anchor: the change - before/ (the link ../c8-unit25/after, unit 25's tree) against after/ (diff -rq; then each file's changed lines, diff -u):"
  diff -rq before/ after/ 2>&1 | sed -E 's#^Files before/+(.*) and after/+.* differ$#  changed: \1#; s#^Only in after/+(.*): (.*)$#  new: \1/\2#; s#^Only in before/+(.*): (.*)$#  gone: \1/\2#' | sort
  for f in $(diff -rq before/ after/ 2>&1 | sed -nE 's#^Files before/+(.*) and after/+.* differ$#\1#p' | sort); do
    printf '    %s: +%s -%s\n' "$f" "$(diff -u before/$f after/$f | $G -cE '^\+[^+]|^\+$' || true)" "$(diff -u before/$f after/$f | $G -cE '^-[^-]|^-$' || true)"; done
  for f in $(diff -rq before/ after/ 2>&1 | sed -nE 's#^Only in after/+(.*): (.*)$#\1/\2#p' | sort); do printf '    %s: %s lines, new\n' "$f" "$(wc -l < after/$f | tr -d ' ')"; done
  echo "  the trees (python3 -I harness/tree26.py, links followed): before/ $(python3 -I harness/tree26.py before/) · after/ $(python3 -I harness/tree26.py after/)"
  echo "  the builds: after/ 'Downloaded from' $($G -cE '^\[INFO\] Download(ing|ed) from ' .harness/build-after.log || true) · before/ $($G -cE '^\[INFO\] Download(ing|ed) from ' .harness/build-before.log || true) · BOOT-INF/lib: after/ $(ls .harness/after/$XD/lib | wc -l | tr -d ' ') jars, before/ $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') jars, the same names: $( [ "$(ls .harness/after/$XD/lib | md5 -q)" = "$(ls .harness/before/$XD/lib | md5 -q)" ] && echo yes || echo no)"
  echo "  @EnableMongoRepositories' repositoryImplementationPostfix, its default (javap -v, $JMON): $(javap -v -cp $JMON org.springframework.data.mongodb.repository.config.EnableMongoRepositories | awk '/ repositoryImplementationPostfix\(\);/ { f = 1 } f && /default_value:/ { g = 1; next } g { gsub(/^ +/, ""); print; exit }')"
  echo "  who names each repository in after/'s src/main and src/test (harness/chk26.py inject: after/'s Java, comments stripped, the repository's own file left out):"
  python3 -I -B harness/chk26.py inject after
  fresh > /dev/null; tbroute $A after 20650
  fresh > /dev/null; tbroute $B before 20655
  echo "-- after/'s jar under dev on 20650 (java -jar, the harness's logback, the unit's four stores): exit $(cat $A/exit) · listening on: $(cat $A/listen)"
  echo "\$ cd .harness/run-dev && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -jar ../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --logging.config=../../harness/logback.xml --tiffinbox.port=20650 $DEVP"
  echo "  its start's repository and Flyway lines, whole, each counted (the logger's prefix cut):"; startlines $A/jvm.log
  echo "-- before/'s jar under dev on 20655 (the same shape): exit $(cat $B/exit) · listening on: $(cat $B/listen)"
  echo "  its start's repository and Flyway lines, whole, each counted:"; startlines $B/jvm.log
  echo "  GET /revenue/by-customer on 20650 (after/): $(cat $A/rbc.json)"
  echo "  GET /revenue/by-customer on 20655 (before/): $(cat $B/rbc.json)"
  echo "  the two bodies: md5 after/ $(md5 -q $A/rbc.json) · before/ $(md5 -q $B/rbc.json) · cmp: $(cmp -s $A/rbc.json $B/rbc.json && echo 'byte-equal' || echo 'DIFFER')"
  echo "  GET /kitchen on 20650 (after/): $(cat $A/kitchen.json) · on 20655 (before/): $(cat $B/kitchen.json)"
  echo "  POST /shutdown (the token): after/ $(cat $A/shutdown.json) · before/ $(cat $B/shutdown.json)"; }
SOCKPY='import sys
st={"01":"ESTABLISHED","02":"SYN_SENT","03":"SYN_RECV","04":"FIN_WAIT1","05":"FIN_WAIT2","06":"TIME_WAIT","07":"CLOSE","08":"CLOSE_WAIT","09":"LAST_ACK","0A":"LISTEN","0B":"LISTENING"}
L={"tcp":[],"udp":[]}
for f in sys.argv[1:]:
    k="udp" if "udp" in f else "tcp"
    for l in open(f).read().splitlines()[1:]:
        p=l.split()
        if len(p) > 3: L[k].append((int(p[1].split(":")[1], 16), int(p[2].split(":")[1], 16), st.get(p[3], p[3])))
ls=sorted({a for a, b, s in L["tcp"] if s == "LISTEN"}); out=[x for x in L["tcp"] if x[2] != "LISTEN" and x[0] not in (9200, 9300)]
print("listening (TCP) on " + ", ".join(map(str, ls)) + " · connections from another local port (outbound): " + str(len(out)) + " · UDP sockets: " + str(len(L["udp"])))'
composition() { local F=.harness/comp-$CAPRUN t
  fresh > /dev/null; h26 $F none --h26.mode=composition
  echo "-- composition: TiffinBox (after/'s jar) under dev on the unit's four stores, the harness joined (composition); the JVM's exit $(cat $F/exit)"
  h26cl none --h26.mode=composition
  $G "^the harness's " $F/jvm.log
  echo "  the stores' own tools after the JVM is gone:"
  echo "    mongosh: db.orders.aggregate([{\$group: {_id: '\$customer', total: {\$sum: '\$value'}}}, {\$sort: {total: -1}}]) -> $(ms 'print(db.orders.aggregate([{$group: {_id: "$customer", total: {$sum: "$value"}}}, {$sort: {total: -1}}]).toArray().map(d => d._id + " " + d.total).join(", "))')"
  echo "    mongosh: db.orders.countDocuments() -> $(ms 'print(db.orders.countDocuments())') · countDocuments({mealType: 'VEG'}) -> $(ms 'print(db.orders.countDocuments({mealType: "VEG"}))')"
  echo "  $EN's sockets at the end (S8.92, folded here as unit 25 folded them into hole), its /proc/net/tcp, tcp6, udp and udp6 read by cat (dk exec - a file, never a shell):"
  echo "    its interfaces (/proc/net/dev): $(dk exec $EN cat /proc/net/dev | sed 1,2d | cut -d: -f1 | tr -d ' ' | sort | paste -sd',' -)"
  for t in tcp tcp6 udp udp6; do dk exec $EN cat /proc/net/$t > $F/net-$t.txt 2> /dev/null || : > $F/net-$t.txt; done
  echo "    the sockets: $(python3 -I -c "$SOCKPY" $F/net-tcp.txt $F/net-tcp6.txt $F/net-udp.txt $F/net-udp6.txt)"; }
failtext() { echo "  its exit $(cat $1/exit) · 'Started TiffinBoxServer' $($G -c 'Started TiffinBoxServer' $1/jvm.log || true) · 'APPLICATION FAILED TO START' $($G -c 'APPLICATION FAILED TO START' $1/jvm.log || true) · 'Application run failed' $($G -c 'Application run failed' $1/jvm.log || true) · its MongoDB Found line: $($G -oE 'Found [0-9]+ MongoDB repository interfaces?\.' $1/jvm.log | head -1)"
  echo "  the exception, whole - the line after 'Application run failed', then every 'Caused by:' line (Boot's own log, unmasked but for the folder):"
  awk '/Application run failed/ { getline; getline; print; f = 1; next } f && /^Caused by: / { print }' $1/jvm.log | mask | sed 's/^/    /'; }
misnamed() { local F=.harness/mis-$CAPRUN
  fresh > /dev/null; tbfail $F misnamed 20656
  echo "-- misnamed: a copy of after/ with OrderTotalsImpl.java replaced by exercise/OrderTotalsImplementation.java (the same class, renamed - the exercise's broken tree), built offline under .harness/misnamed, its jar under dev on 20656 (Boot's own logging):"
  echo "  the copy against after/ (diff -rq, target and secrets left out): $(diff -rq -x target -x secrets after .harness/misnamed 2>&1 | sed -E 's#^Only in after/(.*): (.*)$#gone \2#; s#^Only in \.harness/misnamed/(.*): (.*)$#new \2#' | sort | paste -sd' ' -)"
  echo "\$ cd .harness/run-dev && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -jar ../misnamed/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20656 $DEVP"
  failtext $F; }
silent() { local F1=.harness/sil-$CAPRUN F2=.harness/silbad-$CAPRUN
  fresh > /dev/null; h26 $F1 silent --h26.mode=composition --h26.method=findByCustomer --h26.arg=Ravi
  echo "-- silent: the harness's variant (harness/variants/silent, first on the class path): OrderDocuments extends OrderTotals AND OrderLookup, whose findByCustomer's class is OrderLookupImpl; the JVM's exit $(cat $F1/exit) · ERROR lines $($G -c '^ERROR ' $F1/jvm.log || true)"
  h26cl silent --h26.mode=composition --h26.method=findByCustomer --h26.arg=Ravi
  $G "^the harness's " $F1/jvm.log | $G -vE "^the harness's   OrderDocument\[|^the harness's   STACK " || true
  echo "  the harness's variant's results, each one's id in the order returned: $($G -oE "^the harness's   OrderDocument\[id=[^,]+" $F1/jvm.log | sed 's/.*id=//' | paste -sd' ' -)"
  echo "  mongosh after: db.orders.find({customer: 'Ravi'}).sort({day: -1}).limit(7) -> $(ms 'print(db.orders.find({customer: "Ravi"}).sort({day: -1}).limit(7).toArray().map(d => d._id).join(" "))') · countDocuments({customer: 'Ravi'}) -> $(ms 'print(db.orders.countDocuments({customer: "Ravi"}))')"
  fresh > /dev/null; h26 $F2 silentbad --h26.mode=composition --h26.method=findByCustomer --h26.arg=Ravi
  echo "-- silent, misnamed: the harness's variant (harness/variants/silentbad): the same, its class named OrderLookupImplementation; the JVM's exit $(cat $F2/exit) · ERROR lines $($G -c '^ERROR ' $F2/jvm.log || true) · exception lines $($G -cE 'Exception' $F2/jvm.log || true)"
  h26cl silentbad --h26.mode=composition --h26.method=findByCustomer --h26.arg=Ravi
  $G "^the harness's " $F2/jvm.log | $G -vE "^the harness's   OrderDocument\[|^the harness's   STACK " || true
  echo "  the harness's variant's results, each one's id in the order returned: $($G -oE "^the harness's   OrderDocument\[id=[^,]+" $F2/jvm.log | sed 's/.*id=//' | paste -sd' ' -)"
  echo "  mongosh after: countDocuments({customer: 'Ravi'}) -> $(ms 'print(db.orders.countDocuments({customer: "Ravi"}))') · find({customer: 'Ravi'}).limit(7) -> $(ms 'print(db.orders.find({customer: "Ravi"}).limit(7).toArray().length)') documents"; }
lookup() { local F1=.harness/look-a F2=.harness/look-b
  fresh > /dev/null; h26 $F1 comp --h26.mode=composition
  echo "-- lookup (a): the harness's variant (harness/variants/comp): the shipped OrderTotalsImpl with @Component, first on the class path; the JVM's exit $(cat $F1/exit)"
  h26cl comp --h26.mode=composition
  $G -E "^the harness's (repository |  composition |  OrderTotals\.|beans whose class|CALL totalsByCustomer)" $F1/jvm.log
  fresh > /dev/null; tbfail $F2 pkg 20656
  echo "-- lookup (b): a copy of after/ with OrderTotalsImpl moved to com.tiffinbox (its package line, three imports), above the repository's package, built offline under .harness/pkg, its jar under dev on 20656 (Boot's own logging):"
  echo "  the copy against after/ (diff -rq, target and secrets left out): $(diff -rq -x target -x secrets after .harness/pkg 2>&1 | sed -E 's#^Only in after/(.*): (.*)$#gone \1/\2#; s#^Only in \.harness/pkg/(.*): (.*)$#new \1/\2#' | sort | paste -sd' ' -)"
  failtext $F2; }
why() { local F=.harness/why
  fresh > /dev/null; h26 $F none --h26.mode=why
  echo "-- why: the harness's repository OrderTotalsAsStrings (H26.java), the same pipeline as two @Aggregation strings, built by Spring Data MongoDB's own factory (never a scan); the JVM's exit $(cat $F/exit)"
  h26cl none --h26.mode=why
  $G "^the harness's " $F/jvm.log; }
jpatx() { local n F
  for n in 1 2 3; do F=.harness/jpa-$n; fresh > /dev/null; h26 $F jpa --h26.mode=jpatx
    echo "-- jpatx, run $n: the harness's variant (harness/variants/jpa): CustomerEntityRepository extends CustomerWrites, CustomerWritesImpl's persist with NO @Transactional; the JVM's exit $(cat $F/exit)"
    h26cl jpa --h26.mode=jpatx
    $G "^the harness's " $F/jvm.log
    echo "  psql after: select count(*) from customer where name = 'the-harness-26' -> $(psq tiffinbox "select count(*) from customer where name = 'the-harness-26'")"; done
  F=.harness/jpatx; fresh > /dev/null; h26 $F jpatx --h26.mode=jpatx
  echo "-- jpatx, its control: the harness's variant (harness/variants/jpatx): the same, CustomerWritesImpl's method @Transactional; the JVM's exit $(cat $F/exit)"
  h26cl jpatx --h26.mode=jpatx
  $G "^the harness's " $F/jvm.log
  echo "  psql after: select count(*) from customer where name = 'the-harness-26' -> $(psq tiffinbox "select count(*) from customer where name = 'the-harness-26'")"; }
seven1() { local t=$1 port=$2 i=0 e=0 c a
  echo "-- the seven: $t/'s jar, java -jar, H2 in memory (a fresh JVM), port $port:"
  echo "\$ cd .harness/$t && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port"
  (cd .harness/$t && DOCKER_HOST=tcp://127.0.0.1:1 exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port) > .harness/seven-run-$t.log 2>&1 < /dev/null & pid=$!
  while [ $i -lt 480 ]; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/seven-run-$t.log | mask >&3; die "TiffinBox exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $port"
  a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
  echo "  GET /actuator/health/readiness -> 200 · listens on: $a"
  echo "\$ \$CURLSET $port .harness/$t/$TF"
  "$CURLSET" $port .harness/$t/$TF | $G ' -> ' | awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' > .harness/seven-$t.txt || true
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 480 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && die "TiffinBox on $port was still running after POST /shutdown"
  wait "$pid" || e=$?; pid=""
  [ "$(listeners $port)" = 0 ] || die "something still listens on $port"
  echo "  exit $e · the seven responses: $(wc -l < .harness/seven-$t.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven-$t.txt) · listening on $port now: 0"
  ! $G -qF -- "$TOKEN" .harness/seven-run-$t.log || die "TiffinBox's log held the token"; }
seven() { seven1 after 20650; seven1 before 20655; }
dockeq() { local v i c n
  i=$(dk images -q --no-trunc 2> /dev/null | sort -u | paste -sd' ' -); v=$(vols)
  c=$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null | wc -l | tr -d ' ')
  n=$(find "$M2" -type f | wc -l | tr -d ' ')
  [ "$i" = "$IMGS0" ] || die "$1: the images moved - nothing may be pulled"
  [ "$v" = "$2" ] || die "R.322: $1: the volume count is $v, not $2"
  [ "$c" = 0 ] || die "$1: a Testcontainers container is still there after the run ($c)"
  [ "$n" = "$NF0" ] || die "$1: .m2-demo gained files ($NF0 -> $n) - offline: no"
  echo "  after it: images $NI0 (the same list) · volumes $v (the count before it) · Testcontainers containers 0 · .m2-demo's files unchanged"; }
tcpoll() { local i=0 l; : > .harness/tc-ports.txt; : > .harness/tc-compose.txt
  while kill -0 "$1" 2> /dev/null && [ $i -lt 9000 ]; do
    dk ps --filter label=org.testcontainers=true --format '{{.Image}} {{.Ports}}' 2> /dev/null | $G -F -- '->' >> .harness/tc-ports.txt || true
    l=$(( $(listeners 18881) + $(listeners 18882) + $(listeners 18883) + $(listeners 18884) )); [ "$l" = 0 ] || echo "$l" >> .harness/tc-compose.txt
    sleep 0.2; i=$((i + 1)); done; }
verify() { local e=0 n v0
  echo "-- verify: mvn verify on .harness/tests - a copy of after/ with harness/it-bindings.patch applied (the three older tests' containers bound to 127.0.0.1, U27 ships that change; every IT prints its own container's bindings):"
  echo "  the copy against after/ (diff -rq, target and secrets left out): $(diff -rq -x target -x secrets after .harness/tests 2>&1 | sed -E 's#^Files after/(.*) and \.harness/tests/.* differ$#\1#' | sort | paste -sd' ' -)"
  echo "  the diff (diff -ru after/ .harness/tests/, the five files): $(diff -ru -x target -x secrets after .harness/tests | $G -E '^[-+][^-+]' | md5 -q) (md5 of its changed lines) · lines added $(diff -ru -x target -x secrets after .harness/tests | $G -cE '^\+[^+]' || true) · removed $(diff -ru -x target -x secrets after .harness/tests | $G -cE '^-[^-]' || true) · under src/main: $(diff -rq -x target -x secrets after .harness/tests | $G -c '/src/main/' || true)"
  echo "  the modifier, per IT file (grep -c withCreateContainerCmdModifier): $(for f in CustomerEntityRepositoryIT jdbc/CustomerAggregatesIT web/RedisDatastoreIT web/MongoDatastoreIT web/ElasticsearchIT; do printf '%s %s · ' "${f##*/}" "$($G -c withCreateContainerCmdModifier .harness/tests/tiffinbox-web/src/test/java/com/tiffinbox/$f.java)"; done | sed 's/ · $//')"
  [ "$(listeners 20578)" = 0 ] && [ "$(listeners 20615)" = 0 ] || die "20578 or 20615 (the ITs' pinned bindings) is bound before mvn verify"
  echo "  before it: listening on 20578 (MongoDatastoreIT's pinned binding): 0 · on 20615 (ElasticsearchIT's): 0 · on 18881-18884: 0"
  v0=$(vols)
  echo "\$ cd .harness/tests && DOCKER_HOST=\$DH TESTCONTAINERS_RYUK_DISABLED=true $MV \"$AL\" clean verify -pl tiffinbox-web -am   (its alarm's cap: 900, R.247 - five ITs and an Elasticsearch start)"
  (cd .harness/tests && export DOCKER_HOST="$DH" TESTCONTAINERS_RYUK_DISABLED=true && eval "$MV \"$AL\" clean verify -pl tiffinbox-web -am") > .harness/verify.log 2>&1 < /dev/null & mpid=$!
  tcpoll "$mpid"; wait "$mpid" || e=$?; mpid=""
  [ "$e" != 142 ] || die "verify: Maven's alarm fired (exit 142, cap 900 - R.247)"
  n=$($G -cE '^\[INFO\] Download(ing|ed) from ' .harness/verify.log || true)
  echo "  exit $e · $($G -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/verify.log || echo 'no BUILD line') · offline: $( [ "$n" = 0 ] && echo yes || echo "no - $n lines say Maven downloaded")"
  [ "$n" = 0 ] || die "verify: Maven downloaded"
  dockeq verify "$v0"
  $G -E '^\[(INFO|WARNING|ERROR)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' .harness/verify.log | sed -E 's/^\[[A-Z]+\] /  the Results line: /'
  $G -E '^\[(INFO|WARNING|ERROR)\] Tests run: [0-9]+, .* -- in com\.tiffinbox\.web\.MongoDatastoreIT$' .harness/verify.log | sed -E 's/^\[[A-Z]+\] /  MongoDatastoreIT: /; s/, Time elapsed: [^ ]+ s//'
  echo "  the new test's own line: $($G -ho 'MONGO IT the fragment.s totalsByCustomer(), through OrderDocuments: .*' .harness/verify.log .harness/tests/tiffinbox-web/target/failsafe-reports/*-output.txt 2> /dev/null | sort -u | head -1)"
  echo "  the IT BINDINGS lines (each IT's own container, Docker's inspect, sorted; the host port masked):"
  $G -ho 'IT BINDINGS .*' .harness/verify.log .harness/tests/tiffinbox-web/target/failsafe-reports/*-output.txt 2> /dev/null | sort -u | sed -E 's/:[0-9]+\]/:<port>]/; s/:[0-9]+,/:<port>,/g' | sed 's/^/    /'
  echo "  the Testcontainers containers' ports while verify ran (dk ps, polled), each distinct host address: $($G -oE '[0-9.]+:[0-9]+->' .harness/tc-ports.txt | sed -E 's/:[0-9]+->$//' | sort -u | paste -sd' ' -) · their images: $(awk '{ print $1 }' .harness/tc-ports.txt | sed 's/@sha256:.*//' | sort -u | paste -sd' ' -) · 18881-18884 bound during it: $( [ -s .harness/tc-compose.txt ] && echo yes || echo no)"
  echo "  ElasticsearchIT: 'Timed out waiting' lines $($G -c 'Timed out waiting' .harness/verify.log || true) · its container started: $($G -cE 'elasticsearch.*started in' .harness/verify.log || true) · 'Creating container for image' $($G -c 'Creating container for image: ' .harness/verify.log || true) · 'Pulling' $($G -c 'Pulling' .harness/verify.log || true) · Testcontainers containers after it: $(dk ps -aq --filter label=org.testcontainers=true | $G -c . || true) · listening on 20578 and 20615 after it: $(( $(listeners 20578) + $(listeners 20615) ))"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exrun() { local nm=$1 sh=$2 i=0
  printf '%s\n' 'cd "$1" || exit 1' '. "$1/.harness/ex-'"$nm"'.sh" > "$1/.harness/ex-'"$nm"'.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-'"$nm"'.st"' > .harness/ex-drive-$nm.sh
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive-$nm.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive-$nm.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 4800 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after its cap"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-$nm.st ] || { cat .harness/ex-shell.out .harness/ex-$nm.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of the $nm block"; }; }
exafter() { echo "  listening on 20651-20656 afterwards: $(( $(listeners 20651) + $(listeners 20652) + $(listeners 20653) + $(listeners 20654) + $(listeners 20655) + $(listeners 20656) )) · the exercise's containers afterwards: $(dk ps -aq --filter name=^/c8u26-ex- | $G -c . || true) · volumes $(vols) (before the shell: $1) · java processes of the exercise: $(ps -axo command= | $G -c '[.]harness/ex/x/tiffinbox-web' || true) · images afterwards: the same list $( [ "$(dk images -q --no-trunc 2> /dev/null | sort -u | paste -sd' ' -)" = "$IMGS0" ] && echo yes || echo no)"; }
exsh() { local sh=$1 e1 d1 e2 d2 v1
  rm -rf .harness/ex; rm -f .harness/ex-*.st .harness/ex-*.out
  v1=$(vols)
  printf '%s\n' 'cd "$1" || exit 1' '. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-readme.st"' 'cd "$1" || exit 1' '. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-sol.st"' > .harness/ex-drive-both.sh
  local i=0
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive-both.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive-both.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 4800 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after its cap"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines, the block's exit $e1:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "  then the solution's lines, in the same shell - the block's exit $e2:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") ·$(exafter "$v1" | sed 's/^ //')"; }
exercise() { local e d k v1
  printf '%s\n' "$SETUP" > .harness/ex-readme.sh; printf '%s\n' "$SOL" > .harness/ex-sol.sh; printf '%s\n' "$DELP" > .harness/ex-del.sh
  echo "exercise/README.md's $(printf '%s\n' "$SETUP" | $G -c .) lines, then exercise/SOLUTION.md's, as written, one after the other in ONE env -i shell (HOME and the PATH this script was started with), started in this folder:"
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh
  echo "a wrong \"solution\" - the class's method deleted (the README's block, the copy's totalsByCustomer() removed by perl), three times, each in a fresh env -i bash, through exercise/check.sh:"
  diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$DELP") | $G '^>' | sed 's/^> /  $ /'
  for k in 1 2 3; do v1=$(vols); rm -rf .harness/ex; rm -f .harness/ex-del.st .harness/ex-del.out; exrun del bash; read -r e d < .harness/ex-del.st
    echo "  run $k - the block's exit $e:"; $G -E '^(check:|built:)' .harness/ex-del.out | sed 's/^/    /'; exafter "$v1"; done; }

# ---- the runs ------------------------------------------------------------------------------------------------------------------
echo "-- exercise (once per run of record; its four stores are its own, on 20651-20654, before the unit's):"
NCAP=1; cap exercise exercise; chk exercise .r-exercise.out "$EXW" "$EXQ"
for f in exercise/README.md exercise/SOLUTION.md; do
  w=$(python3 -I -B harness/chk26.py wib .r-exercise.out "$f"); [ "$(wib "$f")" = "$w" ] || die "$f's \"What it prints\" block is not what its lines printed: $(diff <(wib "$f") <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"; done
echo "  exercise: each file's \"What it prints\" block = what its lines printed (bash's; zsh's the same - chk26)"
pub exercise
[ "$(vols)" = "$VOL0" ] || die "R.322: after the exercise the volume count is $(vols), not $VOL0"
echo "-- the unit's four stores:"
stores > .harness/stores.out 2>&1 || true; [ -z "$pid$mpid" ] || die "the stores' window left a process running"
$G -q '^  \*\*\* ' .harness/stores.out && { cat .harness/stores.out >&3; die "the stores' window stopped (above)"; }
mask < .harness/stores.out | sed 's/^/  /'
fresh > .harness/fresh-1.txt; mask < .harness/fresh-1.txt | sed 's/^/  /'
echo "  (fresh, as above, before every TiffinBox JVM below: a new database, FLUSHALL, a new MongoDB, the dishes index deleted)"
NCAP=3
cap anchor anchor; chk anchor .r-anchor.out; pub anchor
cap composition composition; chk composition .r-composition.out; pub composition
cap misnamed misnamed; chk misnamed .r-misnamed.out; pub misnamed
cap silent silent; chk silent .r-silent.out; pub silent
NCAP=1
cap lookup lookup; chk lookup .r-lookup.out .r-misnamed.out; pub lookup
cap why why; chk why .r-why.out .r-composition.out; pub why
cap jpatx jpatx; chk jpatx .r-jpatx.out; pub jpatx
dk rm -fv $CN $RN $MN $EN > /dev/null 2>&1 || die "the unit's stores could not be removed"
[ "$(vols)" = "$VOL0" ] || die "R.322: after the stores' window the volume count is $(vols), not $VOL0"
echo "  $CN, $RN, $MN and $EN removed (rm -fv) · volumes $(vols)"
cap seven seven; chk seven .r-seven.out "$S466"; pub seven
cap verify verify; chk verify .r-verify.out; pub verify
echo "  the values (chk26's, every capture's): $(printf '%s\n' "$VALS" | wc -l | tr -d ' ') lines"
printf '%s\n' "$VALS" > .harness/values.txt
python3 -I -B harness/chk26.py readme README.md .harness/values.txt > .harness/chk-readme.out 2>&1 || { $G '^FAIL' .harness/chk-readme.out | head -5 >&3; die "README.md: its values block or a text block is not what the runs printed (R.302)"; }
echo "  R.302: README.md's $($G -c '^```text$' README.md) text blocks - every line one the runs printed; the values block = the captures' (chk26 readme: $($G -c '^ok ' .harness/chk-readme.out) checks)"
HY=$(cat .r-*.out | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
[ "$HY" = 0 ] || die "R.432: dur8 finds $HY duration word(s) in the captures"
! cat .r-*.out | $G -qE '[0-9]+\.[0-9]+ seconds|PT[0-9]|pid [0-9]|0\.0\.0\.0:[0-9]|\[::\]:[0-9]' || die "a time, a pid or an all-interfaces binding in a capture"
! cat .r-*.out | $G -qF -- "$TOKEN" || die "the token in a capture"
echo "  hygiene: dur8 over the captures 0 words; no time, pid, all-interfaces binding or token in any capture; every JVM and Maven under its alarm"
# ---- the end -------------------------------------------------------------------------------------------------------------------
for c in $CN $RN $MN $EN $XC; do [ -z "$(dk ps -aq --filter name=^/$c\$)" ] || die "the container $c is still there"; done
tcrm; [ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container is still there"
VOL1=$(vols); [ "$VOL1" = "$VOL0" ] || die "R.322: volumes $VOL0 -> $VOL1"
[ "$(dk images -q --no-trunc | sort -u | paste -sd' ' -)" = "$IMGS0" ] || die "the images moved - nothing may be pulled"
[ "$(find "$M2" -type f | wc -l | tr -d ' ')" = "$NF0" ] || die ".m2-demo gained files - offline: no"
echo "  docker at the end: $CN, $RN, $MN, $EN, the exercise's four and every Testcontainers container removed with their volumes (rm -fv); volumes $VOL0 -> $VOL1; images $NI0, the same list (nothing pulled); .m2-demo's files unchanged ($NF0)"
pin before-tree before end; pin after-tree after end
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c8-tiffinbox 2>&1 || true)
[ -z "$AD" ] || die "flag 5: ../c8-tiffinbox moved during the run"
echo "  ../c8-tiffinbox against after/ at the end: diff -rq empty"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
echo "  ports: nothing listens on 20650-20659, 20578, 20615 or 18881-18884 at the end - the unit's stores bound 20651-20654, TiffinBox 20650 and 20655, the exercise's TiffinBox and the copies 20656 (the exercise's stores 20651-20654), mvn verify's pinned ITs 20578 and 20615; 20657-20658 and 20659 were never bound"
[ -z "$unpub" ] || { echo "c8-unit26: captures without a published hash:$unpub - write them into receipts.md5 from this run's output"; exit 0; }
echo "c8-unit26: every capture = published (anchor, composition, misnamed and silent 3/3 in this run; exercise, lookup, why, jpatx, seven and verify once per run); every number re-derived by chk26.py; before/ = unit 25's after-tree, after/ = this unit's; the volume count and the images unchanged"
