#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 8 · Capstone: TiffinBox, Cached and Searchable - this unit's receipts. Section 5's second anchor change: before/ is the link to
# ../c8-unit26/after (unit 26's tree), after/ is ../c8-tiffinbox after this unit's change - five test files and the README: the three
# older ITs (CustomerEntityRepositoryIT, CustomerAggregatesIT, RedisDatastoreIT) bound to 127.0.0.1 by bindIp, and all five ITs printing
# their own container's bindings (IT BINDINGS); tiffinbox-core and tiffinbox-web/src/main byte-equal, the jar the same jar. One jar, two
# runs: the default run (H2, Caffeine) and "dev" (PostgreSQL, Redis, MongoDB, Elasticsearch). The harness, probe.u27.CacheBeans (the
# CacheManager beans, the customers cache's writer, the listeners for a committed transaction, read off the running context) and
# probe.u27.TwoCaches (a second CacheManager bean), joined by --spring.main.sources; every line they print says "the harness's". Each
# count read twice where a store answers: the JVM's own log or the harness's Java, and the store's own tool - PostgreSQL's
# log_statement=all, Redis's MONITOR, MongoDB's profiler read per call by mongosh, the Elasticsearch client's own trace.
# Captures (runs, tour, copies and default three times inside each run and hashed; the rest once per run of record):
#   exercise    exercise/README.md's lines, then SOLUTION.md's, as written, in ONE env -i shell - bash, then zsh -f; then a wrong
#               "solution" (the dev cache type switched to caffeine, the class kept) three times through exercise/check.sh
#   runs        after/'s jar twice: under dev on 20660 and in the default run on 20665, the harness's CacheBeans joined to both, each JVM's
#               own -Xlog:class+load file: the CacheManager beans, the Caffeine classes loaded
#   tour        dev's routes, one request at a time between markers: status · PostgreSQL · Redis · MongoDB · Elasticsearch · answer
#   copies      the same dev JVM after the tour: POST /customers and POST /dishes - what each witness saw, in its own order
#   default     the default run's JVM: the customer list on H2 and Caffeine, the dev-only routes' 404s, the 405s
#   absent      after/'s jar under dev on 20666 with one store's address moved to 20669 (nothing listens), four starts
#   twocaches   after/'s jar under dev on 20666 with the harness's TwoCaches (dynamic names, then names=menu); javap of Boot's
#               CacheAutoConfiguration from after/'s own BOOT-INF/lib
#   seven       the comparison set on after/'s jar (H2, 20665)
#   bound       the change (before/ against after/), the static check, mvn verify on .harness/tests = a plain copy of after/: the tests'
#               counts and the five IT BINDINGS lines
# Every tree is COPIED under .harness/ and built there, offline (-o, from .m2-demo, a copy of the course's seed, maven.repo.local
# absolute), -pl tiffinbox-web -am (R.391). Every JVM and Maven run under an alarm (R.247), every JVM with SIGINT reset to its default
# (R.410). Every docker call names its socket (dk, R.344), --pull never; every container is removed with its volumes (rm -fv, R.387) and
# the volume count asserted back. No JVM is polled while a witness window is open: readiness is read before the first marker (R.412).
# Ports (20660-20669): 20660 TiffinBox (after/ under dev, the harness joined) · 20661 PostgreSQL c8u27-pg · 20662 Redis c8u27-redis ·
# 20663 MongoDB c8u27-mongo (a standalone) · 20664 Elasticsearch c8u27-es · 20665 TiffinBox (the default run; the seven) · 20666 the
# exercise's TiffinBox, and absent's and twocaches' starts, one at a time · 20667-20668 spare (asserted free) · 20669 never bound
# (absent's target). During mvn verify only: Testcontainers' own containers on 127.0.0.1:<random>, and the two pinned ITs' 20578
# (MongoDB) and 20615 (Elasticsearch). 18881-18884 free throughout (Compose stays off).
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
CN=c8u27-pg; RN=c8u27-redis; MN=c8u27-mongo; EN=c8u27-es; XC="c8u27-ex-pg c8u27-ex-redis c8u27-ex-mongo c8u27-ex-es"
ESSET="-e discovery.type=single-node -e xpack.security.enabled=false -e xpack.ml.enabled=false -e ingest.geoip.downloader.enabled=false -e xpack.inference.elastic.authorization.enabled=false"
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
pid=""; mpid=""; xpid=""; monpid=""; TC0=""; INTR=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.u27.") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "curlset.sh") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "redis-cli MONITOR") || $3 ~ /(^|\/)javac$/ || index($0, "ex-drive")) { print $1 }' | paste -sd' ' -) || l=""
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
trap 'trap "" INT TERM; for p in "$monpid" "$mpid" "$xpid" "$pid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid" "$monpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; tcrm; ctrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git unzip javap /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|FLYWAY_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|REDIS[A-Z_]*|MONGO[A-Z_]*|ES_[A-Z_]*|ELASTIC[A-Z_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT|COMPOSE_[A-Z_]*)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"

# ---- gates before anything is written: the folder, the links, the pins, the prose, the exercise ------------------------------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk27.py dur8.py logback.xml s827.py src tree27.py' ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe/u27/CacheBeans.java probe/u27/TwoCaches.java' ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'LocalCacheConfig.java README.md SOLUTION.md check.sh' ] || die "exercise/ holds another file, or misses one"
cmp -s harness/dur8.py ../c8-unit02/harness/dur8.py || die "harness/dur8.py is not the builders' dur8.py as unit 02 shipped it, byte for byte"
cmp -s harness/logback.xml ../c8-unit07/harness/logback.xml || die "harness/logback.xml is not unit 07's, byte for byte"
[ -L before ] && [ "$(readlink before)" = ../c8-unit26/after ] || die "R.250/RED #28: before must be a link whose text is ../c8-unit26/after (it is: $(readlink before 2> /dev/null || echo 'not a link'))"
[ -d after ] && [ ! -L after ] || die "after/ must be this unit's own tree, not a link"
for t in after; do [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] && die "$t holds a secrets/ or a target/ - never built in place"; true; done
git rev-parse -q --verify '88c3aca^{commit}' > /dev/null 2>&1 || die "unit 26's commit 88c3aca is not in this repository's history"
U26P=$(awk '$1 == "after-tree" { print $2, $3 }' ../c8-unit26/receipts.md5)
[ -n "$U26P" ] || die "../c8-unit26/receipts.md5 has no after-tree line"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree27.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  if [ "$nm" = before-tree ]; then [ "$want" = "$U26P" ] || die "R.250: receipts.md5's before-tree line ($want) is not ../c8-unit26/receipts.md5's after-tree line ($U26P)"
  else [ "$want" != "$U26P" ] || die "after-tree equals unit 26's - this unit changes the anchor"; fi
  echo "  $dir/ ($3): python3 -I harness/tree27.py $dir/ -> $got = receipts.md5's $nm line$( [ "$nm" = before-tree ] && echo " = ../c8-unit26/receipts.md5's after-tree line")"; }
pin before-tree before start; pin after-tree after start
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c8-tiffinbox 2>&1 || true)
[ -z "$AD" ] || die "flag 5: ../c8-tiffinbox is not after/ (diff -rq: $(printf '%s\n' "$AD" | head -2 | paste -sd';' -))"
echo "  after/ against ../c8-tiffinbox (diff -rq, .m2-demo target secrets .harness left out): empty - the anchor is this unit's after/"
SM=$(diff -rq before/tiffinbox-core after/tiffinbox-core 2>&1; diff -rq before/tiffinbox-web/src/main after/tiffinbox-web/src/main 2>&1; diff -q before/pom.xml after/pom.xml 2>&1; diff -q before/tiffinbox-web/pom.xml after/tiffinbox-web/pom.xml 2>&1) || true
[ -z "$SM" ] || die "the jar's sources moved: tiffinbox-core, tiffinbox-web/src/main or a pom.xml differs between before/ and after/ ($(printf '%s\n' "$SM" | head -2 | paste -sd';' -))"
echo "  before/ against after/: tiffinbox-core/, tiffinbox-web/src/main/ and both pom.xml byte-equal (diff -rq empty) - the jar's sources are unit 26's"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s827.py harness/dur8.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -2 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S5 12 families · U27 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
DN=$($G -rniwE -- "$DISH" README.md exercise harness/src 2> /dev/null | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|VALUES-PENDING|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
! $G -q '^```java$' README.md || die "README.md holds a java block - the code is the anchor's files, the harness's and the exercise's"
GLOSS="A system of record: the store a change is written to first; a copy or a cache in another store is written from it, after the commit."
[ "$($G -cxF -- "$GLOSS" README.md)" = 1 ] || die "the gloss (SECTION SHAPE 27) must stand in README.md once, as a line of its own, byte for byte"
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
EXQ="Your turn: TiffinBox's dev start stops, no bean of type CacheProperties. Remove the bean that made Boot's cache configuration back off."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SETUP=$(block exercise/README.md); SOL=$(block exercise/SOLUTION.md)
[ -n "$SETUP" ] && [ -n "$SOL" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
[ "$(diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G -c '^[<>]')" = 2 ] || die "R.196: SOLUTION.md's block must be the README's with one line changed"
CPL='cp exercise/LocalCacheConfig.java "$EX/tb/$W/LocalCacheConfig.java"'
[ "$(printf '%s\n' "$SETUP" | $G -cxF "$CPL")" = 1 ] || die "R.196: the README's block copies exercise/LocalCacheConfig.java as shipped"
WRONG="$CPL; printf 'spring.cache.type=caffeine\\n' > \"\$EX/run/application-dev.properties\""
DELP=$(printf '%s\n' "$SETUP" | XC_C="$CPL" XC_W="$WRONG" awk '$0 == ENVIRON["XC_C"] { print ENVIRON["XC_W"]; next } { print }')
[ "$(diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$DELP") | $G -c '^[<>]')" = 2 ] || die "the wrong \"solution\" must be the README's block with one line changed"
printf '%s\n' "$SETUP" | $G -E '(^|[ (])(mvn|java|javac) ' | $G -vqF "perl -e '" && die "exercise/README.md's Java and Maven runs must run under their alarm (R.247)"
printf '%s\n' "$SETUP" | $G -E 'mvn ' | $G -vqF -- '-pl tiffinbox-web -am' && die "R.391: exercise/README.md builds without -pl tiffinbox-web -am"
printf '%s\n' "$SETUP" | $G -E '(^|[ ;&(])docker ' | $G -vqF 'docker -H "$DH" ' && die "R.344: exercise/README.md calls docker without its socket (docker -H \"\$DH\")"
printf '%s\n' "$SETUP" | $G -qxF "docker -H \"\$DH\" rm -fv $XC > /dev/null" || die "R.387: the exercise's four containers are removed with their volumes (rm -fv)"
printf '%s\n' "$SETUP" | $G -E 'docker -H "\$DH" run .*mongo:8' | $G -qF "GLIBC_TUNABLES=$GT" || die "R.421: the exercise's MongoDB runs with GLIBC_TUNABLES"
printf '%s\n' "$SETUP" | $G -E 'docker -H "\$DH" run .*elasticsearch:9\.4\.8' | $G -qF -- "$ESSET -e \"ES_JAVA_OPTS=-Xms512m -Xmx512m\"" || die "R.437: the exercise's Elasticsearch runs with the six settings"
printf '%s\n' "$SETUP" | $G -qF 'bash exercise/check.sh "$EX" "$DH"' || die "R.196: the exercise is checked by exercise/check.sh (the start's line, the store's statements and the Redis key), never by the exit"
$G -qF "redis-cli DEL 'customers::SimpleKey []'" exercise/check.sh && $G -qF 'DEL' exercise/README.md || die "RED #3: the exercise's check deletes the list's key first, and its README says so"
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
WP=tiffinbox-web/src/main/java/com/tiffinbox/web
[ ! -e after/$WP/LocalCacheConfig.java ] || die "after/ holds the exercise's class - the anchor never ships it"
$G -qx '@Profile("dev")' exercise/LocalCacheConfig.java && $G -qF 'CaffeineCacheManager localCaches()' exercise/LocalCacheConfig.java || die "exercise/LocalCacheConfig.java: a dev-only configuration class with @Bean CaffeineCacheManager localCaches()"
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
XE=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) exec [$"][^ ]+ [a-z_-]+' | awk '{ print $4 }' | sort -u | paste -sd'|' -)
[ "$XE" = 'mongosh|pg_isready|psql|redis-cli' ] || die "every exec into a container here is the store's own client - never a shell (found: $XE)"
[ -z "$($G -v '^ *#' receipts.sh | $G -E '(dk|docker) run ' | $G -oE -- ' -p [^ ]+' | $G -v '^ -p 127\.0\.0\.1:' || true)" ] && [ -z "$(printf '%s\n' "$SETUP" | $G -E 'docker -H "\$DH" run ' | $G -oE -- ' -p [^ ]+' | $G -v '^ -p 127\.0\.0\.1:' || true)" ] || die "S8.94: a port published on every interface (-p without 127.0.0.1)"
MVA=$($G -v '^ *#' receipts.sh | $G -F 'clean ' | $G -F '$MV' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am"
[ -z "$($G -rhE --include='*.java' '@Enable[A-Za-z]*Repositories' harness/src exercise | $G -vE '^[[:space:]]*(\*|//|/\*)' || true)" ] || die "S8.101: an @Enable...Repositories in the harness or the exercise - it would switch Boot's scan off"
ST=$(python3 -I -B harness/chk27.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
echo "  prose, per sentence (s827, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test, XFAM_S5's 12 families and U27's among them): refused 0 over $PROSE · dish names 0 · placeholders 0 · no java block · the gloss once, byte for byte"
echo "  the exercise: the spoken line $EXW words (wc -w); SOLUTION.md's block = the README's with one line changed; the wrong \"solution\" (the dev cache type switched to caffeine) = the README's block with that line changed otherwise; the two \"What it prints\" blocks differ (R.196); checked by exercise/check.sh - the start, then the list's key deleted, two reads counted in PostgreSQL's log and the key read back in Redis - never the exit; its containers on 127.0.0.1:20661-20664, removed with their volumes; its MongoDB with GLIBC_TUNABLES, its Elasticsearch with the six settings; its build -pl tiffinbox-web -am; its docker calls on the socket"
echo "  static: no kill by name; every docker call on the pinned socket, every dk run --pull never, every MongoDB container with GLIBC_TUNABLES and every Elasticsearch container with the six settings; no exec into a container but the stores' own clients; no port on every interface (S8.94); every removal dk rm -fv (R.387); every Maven build -pl tiffinbox-web -am (R.391); no @Enable...Repositories in the harness or the exercise (S8.101)"
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
    gsub(/after [0-9]+ ms/, "after <t>")
    gsub(/[0-9]+ ms/, "<t>")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/pid [0-9]+/, "pid <n>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    gsub(/\.\.\. [0-9]+ common frames omitted/, "... <n> common frames omitted")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'Finished Spring Data repository scanning in 23 ms. Found 1 JPA repository interface.' 'Root WebApplicationContext: initialization completed in 812 ms' 'Successfully applied 4 migrations (execution time 00:00.026s)' 'Total time:  12.345 s' 'Tests run: 2, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 84.22 s' 'Container docker.elastic.co/elasticsearch/elasticsearch started in PT1M34.764508S' 'Timed out after 30000 ms while waiting for a server' 'the receipt: pid 41231' "$U/x $HOME/y" | mask)
printf '%s\n' "$MP" | python3 -I -B -c 'import importlib.util,sys,re; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=sys.stdin.read(); sys.exit(1 if m.DUR.search(t) or "3.1 sec" in t or "00:00.026" in t or "812" in t or "12.345" in t or "41231" in t or "23 ms" in t or "84.22" in t or "PT1M34" in t or "30000" in t else 0)' || die "R.432: the mask's self-test - a planted duration or pid passed it unmasked: $(printf '%s\n' "$MP" | head -2 | paste -sd';' -)"
[ "$(printf '%s\n' "$MP" | tail -1)" = '…/x ~/y' ] || die "the mask's self-test: the folders and the home must be masked"
echo "  mask: its self-test refused the planted Started-in-seconds, scanning, initialization, execution-time, Total time, Time elapsed, started in PT…S, the driver's wait and pid readings unmasked (R.432, TIMEPAT_S5's members); folders and home masked"
CURLSET=../c5-unit11/curlset.sh
[ -x "$CURLSET" ] || die "$CURLSET is missing - the comparison set the seven runs"
$G -qF 'S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)' ../c8-unit26/receipts.sh || die "../c8-unit26/receipts.sh no longer reads the seven's md5 off ../c7-unit31/receipts.sh"
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
PORTS="18881 18882 18883 18884 20578 20615 20660 20661 20662 20663 20664 20665 20666 20667 20668 20669"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
[ "$(pgrep -x java | wc -l | tr -d ' ')" = 0 ] || die "a java process is running before this script starts one - not this script's; stop it first"
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · the four digests present ($IMG, $RIMG, $MIMG, $EIMG) · mongo:8, postgres:18-alpine, redis:8-alpine and $ETAG on those digests · nothing pulled, ever · images named ryuk $RY0 · Testcontainers containers 0 · ports 20660-20669, 20578, 20615, 18881-18884 free · java processes 0"

# ---- the tree, copied; the build; the tests' copy; the harness, compiled -----------------------------------------------------------
rm -rf .harness; mkdir -p .harness/run-dev/secrets/tiffinbox .harness/home
M2="$PWD/.m2-demo"
[ -d "$M2" ] || die ".m2-demo (a copy of the course's seed, _research/m2-seed-c8-s4b) is missing - README.md, The repository"
NF0=$(find "$M2" -type f | wc -l | tr -d ' ')
echo "  .m2-demo's files $NF0 (the seed's 7,265 - no new artifact: this unit adds no dependency)"
printf '%s\n' 'checks.disable=true' "tinyimage.container.image=$IMG" > .harness/home/.testcontainers.properties
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy after .harness/after; copy after .harness/tests
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE '^\[INFO\] Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 900; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
AL="-DargLine=$JL -Dstdout.encoding=UTF-8 -Duser.home=../../home"
bg "cd .harness/after && $MV clean package -DskipTests -pl tiffinbox-web -am" .harness/build-after.log
[ "$RE" = 0 ] || { tail -20 .harness/build-after.log | mask >&3; die ".harness/after did not build offline (exit $RE)"; }; offl .harness/build-after.log
bg "cd .harness/after && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-after.log
[ "$RE" = 0 ] || die ".harness/after: the jar's extract failed"
JAR=.harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar; JMD5=$(md5 -q $JAR)
CPA=".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \"$CPA\" harness/src/probe/u27/CacheBeans.java harness/src/probe/u27/TwoCaches.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/'s jar: $(head -5 .harness/javac.log)"
TF=secrets/tiffinbox/shutdown-token
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/run-dev/$TF) || die "the token was not written"
mkdir -p .harness/after/secrets/tiffinbox && (umask 077 && cp .harness/run-dev/$TF .harness/after/$TF) || die "the token was not copied"
TOKEN=$(head -1 .harness/run-dev/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
echo "  built after/ offline (mvn -o package -DskipTests -pl tiffinbox-web -am, exit 0, 'Downloaded from' 0) and extracted its jar; compiled the harness (harness/src/probe/u27/CacheBeans.java and TwoCaches.java, javac 25 -cp \"<after/'s jar>:<its lib/*>\", $(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes); the tests' copy .harness/tests = after/, a plain copy (the change is shipped - no patch); a shutdown token generated (0600, never printed)"

# ---- helpers -------------------------------------------------------------------------------------------------------------------
vols() { dk volume ls -q 2> /dev/null | wc -l | tr -d ' '; }
pgready() { local i=0; while ! dk exec "$1" pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 240 ] || die "PostgreSQL ($1) did not accept connections (240 tries)"; sleep 0.5; done; }
psq() { dk exec "$CN" psql -U tiffinbox -d "$1" -qAt -v ON_ERROR_STOP=1 -c "$2" 2>&1 || die "psql failed on $CN/$1: $2"; }
ms() { dk exec "$MN" mongosh --quiet 'mongodb://127.0.0.1:27017/tiffinbox' --eval "$1" 2>&1 | tail -1; }
rc() { dk exec "$RN" redis-cli "$@" 2>&1 | tr -d '\r'; }
eq() { curl -s --noproxy '*' -X "$1" "http://127.0.0.1:20664$2" 2> /dev/null; }
esup() { local i=0 c; while :; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:20664/_cluster/health" 2> /dev/null || true); [ "$c" = 200 ] && break
    i=$((i + 1)); [ $i -lt 960 ] || die "Elasticsearch on 20664 did not answer _cluster/health 200 (960 reads)"; sleep 0.25; done; }
mkmongo() { local i=0
  bg "dk run -d --pull never --name $MN -p 127.0.0.1:20663:27017 -e GLIBC_TUNABLES=$GT $MIMG --unixSocketPrefix /data/db" .harness/docker-run-mongo.log
  [ "$RE" = 0 ] || die "the MongoDB container did not start: $(tail -2 .harness/docker-run-mongo.log)"
  while [ "$(ms 'print(db.runCommand({ping: 1}).ok)')" != 1 ]; do i=$((i + 1)); [ $i -lt 240 ] || die "MongoDB did not answer mongosh's ping (240 reads)"; sleep 0.25; done
  [ "$(dk port $MN | paste -sd'|' -)" = '27017/tcp -> 127.0.0.1:20663' ] || die "$MN publishes on another address than 127.0.0.1:20663"; }
stores() {
  echo "\$ docker -H \"\$DH\" run -d --pull never --name $CN -p 127.0.0.1:20661:5432 -e POSTGRES_DB=tiffinbox -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust $IMG -c log_statement=all"
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:20661:5432 -e POSTGRES_DB=tiffinbox -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust $IMG -c log_statement=all" .harness/docker-run-pg.log
  [ "$RE" = 0 ] || die "the PostgreSQL container did not start: $(tail -2 .harness/docker-run-pg.log)"
  echo "\$ docker -H \"\$DH\" run -d --pull never --name $RN -p 127.0.0.1:20662:6379 $RIMG"
  bg "dk run -d --pull never --name $RN -p 127.0.0.1:20662:6379 $RIMG" .harness/docker-run-redis.log
  [ "$RE" = 0 ] || die "the Redis container did not start: $(tail -2 .harness/docker-run-redis.log)"
  echo "\$ docker -H \"\$DH\" run -d --pull never --name $MN -p 127.0.0.1:20663:27017 -e GLIBC_TUNABLES=$GT $MIMG --unixSocketPrefix /data/db   (a fresh one before every TiffinBox JVM)"
  echo "\$ docker -H \"\$DH\" run -d --pull never --name $EN --hostname $EN -p 127.0.0.1:20664:9200 $ESSET -e \"ES_JAVA_OPTS=-Xms512m -Xmx512m\" $EIMG"
  bg "dk run -d --pull never --name $EN --hostname $EN -p 127.0.0.1:20664:9200 $ESSET -e \"ES_JAVA_OPTS=-Xms512m -Xmx512m\" $EIMG" .harness/docker-run-es.log
  [ "$RE" = 0 ] || die "the Elasticsearch container did not start: $(tail -2 .harness/docker-run-es.log)"
  pgready $CN; esup
  local i=0; while [ "$(rc PING)" != PONG ]; do i=$((i + 1)); [ $i -lt 200 ] || die "Redis did not answer PING"; sleep 0.1; done
  [ "$(dk port $CN | paste -sd'|' -)" = '5432/tcp -> 127.0.0.1:20661' ] && [ "$(dk port $RN | paste -sd'|' -)" = '6379/tcp -> 127.0.0.1:20662' ] && [ "$(dk port $EN | paste -sd'|' -)" = '9200/tcp -> 127.0.0.1:20664' ] || die "a store publishes on another address than 127.0.0.1:<its port>"
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
A_PG="--tiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:20661/tiffinbox?user=tiffinbox"; A_RP="--spring.data.redis.port=20662"
A_MO="--spring.mongodb.uri=mongodb://127.0.0.1:20663/tiffinbox"; A_ES="--spring.elasticsearch.uris=http://127.0.0.1:20664"
DEVB="--spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.datasource.username=tiffinbox --spring.data.redis.host=127.0.0.1"
DEV="$DEVB $A_PG $A_RP $A_MO $A_ES"
DEVP="--spring.profiles.active=dev --spring.docker.compose.enabled=false <the four stores' addresses by property, 127.0.0.1:20661-20664>"
ESTRACE="--logging.level.co.elastic.clients.transport.rest5_client.low_level.Request=TRACE"
ready() { local port=$1 o=$2 i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 "$o/jvm.log" | mask >&3; die "TiffinBox exited before readiness answered 200 on $port"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $port"
  i=0; while ! $G -q "^the harness's listeners for a committed transaction" "$o/jvm.log"; do i=$((i + 1)); [ $i -lt 120 ] || die "the harness's CacheBeans printed nothing on $port"; sleep 0.25; done
  lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' - > "$o/listen"; }
stop() { local port=$1 o=$2 e=0
  printf 'X-Shutdown-Token: %s\n' "$TOKEN" | curl -s --noproxy '*' -o "$o/shutdown.json" -H @- -X POST "http://127.0.0.1:$port/shutdown"
  wait "$pid" || e=$?; pid=""
  [ "$(listeners $port)" = 0 ] || die "something still listens on $port"
  echo "$e" > "$o/exit"; }
NCAP=3
unpub=""; CAPRUN=0; CAPNM=""
cap() { local nm=$1 i n=$NCAP; shift
  i=1; while [ $i -le $n ]; do CAPRUN=$i; CAPNM=$nm; "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid$monpid" ] || die "$nm left a process running"
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
  o=$(python3 -I -B harness/chk27.py "$nm" "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk27 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -5 >&3; die "$nm: its check failed (harness/chk27.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }

# ---- the JVMs the captures read ------------------------------------------------------------------------------------------------
# req DIR LABEL METHOD PATH [JSON]: one request to the dev JVM on 20660 between its markers - redis-cli ECHO and psql's select, begin and
# end; MongoDB's profiler on for this call alone (level 2 after a drop, read back and off after it, by mongosh); the JVM log's lines
# for this call (the Elasticsearch client's trace) by their line numbers. No request is sent while another's window is open.
req() { local o=$1 l=$2 m=$3 p=$4 j=$5 a b c
  rc ECHO "S27MARK-$l-begin" > /dev/null; psq tiffinbox "select 'S27MARK-$l-begin'" > /dev/null
  [ "$(ms 'db.setProfilingLevel(0); db.system.profile.drop(); db.setProfilingLevel(2); print(db.getProfilingStatus().was)')" = 2 ] || die "MongoDB's profiler did not turn on for $l"
  a=$(wc -l < "$o/jvm.log" | tr -d ' ')
  if [ -n "$j" ]; then c=$(curl -s --noproxy '*' -D "$o/$l.hdr" -o "$o/$l.body" -w '%{http_code}' -X "$m" -H 'Content-Type: application/json' -d "$j" "http://127.0.0.1:20660$p" 2> /dev/null || true)
  else c=$(curl -s --noproxy '*' -D "$o/$l.hdr" -o "$o/$l.body" -w '%{http_code}' -X "$m" "http://127.0.0.1:20660$p" 2> /dev/null || true); fi
  b=$(wc -l < "$o/jvm.log" | tr -d ' ')
  ms 'print(EJSON.stringify(db.system.profile.find({ns: {$in: ["tiffinbox.menu", "tiffinbox.orders", "tiffinbox.customer", "tiffinbox.dishes"]}}).sort({ts: 1}).toArray().map(d => ({op: d.op, ns: d.ns, cmd: Object.keys(d.command || {})[0], nreturned: d.nreturned, docsExamined: d.docsExamined}))))' > "$o/$l.prof"
  [ "$(ms 'db.setProfilingLevel(0); print(db.getProfilingStatus().was)')" = 0 ] || die "MongoDB's profiler did not turn off after $l"
  psq tiffinbox "select 'S27MARK-$l-end'" > /dev/null; rc ECHO "S27MARK-$l-end" > /dev/null
  sed -n "$((a + 1)),${b}p" "$o/jvm.log" | $G -E 'low_level\.Request' > "$o/$l.es" || true
  echo "$l $m $p $c" >> "$o/reqs.txt"; }
# devrun N: after/'s jar under dev on 20660 (Boot's own logging, the client's trace at TRACE), the harness's CacheBeans joined, its own
# class-load file; readiness read BEFORE the first window; then the tour's requests and the copies' writes, one window each
devrun() { local n=$1 o=.harness/dev-$1 PG0 i=0
  rm -rf $o; mkdir -p $o; fresh > $o/fresh.txt
  ms 'db.setProfilingLevel(0); db.system.profile.drop(); print(1)' > /dev/null
  PG0=$(dk logs $CN 2>&1 | wc -l | tr -d ' ')
  (cd .harness/run-dev && exec perl -e '$SIG{INT}="DEFAULT"; alarm 400; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -Duser.home=../home "-Xlog:class+load=info:file=../dev-$n/classload.txt" -cp "../hc:../after/$XD/tiffinbox-web-1.0.0.jar:../after/$XD/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=20660 $DEV --spring.main.sources=probe.u27.CacheBeans $ESTRACE) > $o/jvm.log 2>&1 < /dev/null & pid=$!
  ready 20660 $o
  dk exec $RN redis-cli MONITOR > $o/monitor.txt 2>&1 < /dev/null & monpid=$!
  while ! $G -q '^OK' $o/monitor.txt 2> /dev/null; do i=$((i + 1)); [ $i -lt 120 ] || die "redis-cli MONITOR did not answer OK"; sleep 0.25; done
  rc DEL 'customers::SimpleKey []' > $o/del.txt
  req $o c1 GET /customers; req $o c2 GET /customers; req $o lb GET /leaderboard; req $o menu GET /menu/day-19
  req $o rev GET /revenue/by-customer; req $o search GET '/dishes/search?q=veg'; req $o kitchen GET /kitchen
  req $o patch PATCH /customers; req $o delete DELETE /customers/Ravi
  req $o addc POST /customers "{\"name\":\"Probe$n\",\"mealsPerDay\":1,\"pricePerMeal\":100,\"mealType\":\"VEG\"}"
  req $o c3 GET /customers
  req $o addd POST /dishes "{\"name\":\"Probe Dish $n\",\"mealType\":\"VEG\",\"price\":110}"
  req $o search2 GET '/dishes/search?q=probe'
  kill $monpid 2> /dev/null; wait $monpid 2> /dev/null || true; monpid=""
  stop 20660 $o
  dk logs $CN 2>&1 | sed -n "$((PG0 + 1)),\$p" > $o/pg.log; }
dreq() { local o=$1 l=$2 m=$3 p=$4 j=$5 a b c
  a=$(wc -l < "$o/jvm.log" | tr -d ' ')
  if [ -n "$j" ]; then c=$(curl -s --noproxy '*' -D "$o/$l.hdr" -o "$o/$l.body" -w '%{http_code}' -X "$m" -H 'Content-Type: application/json' -d "$j" "http://127.0.0.1:20665$p" 2> /dev/null || true)
  else c=$(curl -s --noproxy '*' -D "$o/$l.hdr" -o "$o/$l.body" -w '%{http_code}' -X "$m" "http://127.0.0.1:20665$p" 2> /dev/null || true); fi
  b=$(wc -l < "$o/jvm.log" | tr -d ' ')
  echo "$l $m $p $c $(sed -n "$((a + 1)),${b}p" "$o/jvm.log" | $G -c 'org\.hibernate\.SQL' || true)" >> "$o/reqs.txt"; }
prom() { curl -s --noproxy '*' "http://127.0.0.1:20665/actuator/prometheus" 2> /dev/null | $G -E '^cache_gets_total\{' | $G -F 'cache="customers"' | sort > "$1" || true; }
# defrun N: after/'s jar, the default run (no profile, H2 in memory, Caffeine; no Docker reachable) on 20665, the harness's CacheBeans
# joined, the harness's logback (Hibernate's SQL logger at DEBUG), its own class-load file
defrun() { local n=$1 o=.harness/def-$1
  rm -rf $o; mkdir -p $o
  (cd .harness/after && DOCKER_HOST=tcp://127.0.0.1:1 exec perl -e '$SIG{INT}="DEFAULT"; alarm 300; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -Duser.home=../home "-Xlog:class+load=info:file=../def-$n/classload.txt" -cp "../hc:$XD/tiffinbox-web-1.0.0.jar:$XD/lib/*" com.tiffinbox.web.TiffinBoxServer --logging.config=../../harness/logback.xml --tiffinbox.port=20665 --spring.main.sources=probe.u27.CacheBeans) > $o/jvm.log 2>&1 < /dev/null & pid=$!
  ready 20665 $o
  dreq $o addc POST /customers "{\"name\":\"Probe$n\",\"mealsPerDay\":1,\"pricePerMeal\":100,\"mealType\":\"VEG\"}"
  prom $o/prom-before.txt
  dreq $o c1 GET /customers; dreq $o c2 GET /customers
  prom $o/prom-after.txt
  dreq $o lb GET /leaderboard; dreq $o menu GET /menu/day-19; dreq $o rev GET /revenue/by-customer; dreq $o search GET '/dishes/search?q=veg'
  dreq $o addd POST /dishes "{\"name\":\"Probe Dish $n\",\"mealType\":\"VEG\",\"price\":110}"
  dreq $o patch PATCH /customers; dreq $o delete DELETE /customers/Ravi; dreq $o cust GET /customers/Ravi
  dreq $o apidocs GET /v3/api-docs; dreq $o swagger GET /swagger-ui.html
  stop 20665 $o; }

# ---- the captures --------------------------------------------------------------------------------------------------------------
pr() { sed -E 's/(Probe|<\/em>) Dish [123]/\1 Dish <run>/g; s/Probe[123]/Probe<run>/g'; }
runs() { local D=.harness/dev-$CAPRUN F=.harness/def-$CAPRUN
  devrun $CAPRUN; defrun $CAPRUN
  echo "-- runs: one jar, two runs - after/'s jar (tiffinbox-web-1.0.0.jar, md5 $JMD5), started twice, the harness's CacheBeans joined to both:"
  echo "\$ cd .harness/run-dev && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 400; exec @ARGV' java $JL -Xlog:class+load=info:file=<capture dir>/classload.txt -cp \"../hc:<after/'s jar>:<its lib/*>\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=20660 $DEVP --spring.main.sources=probe.u27.CacheBeans $ESTRACE"
  echo "\$ cd .harness/after && DOCKER_HOST=tcp://127.0.0.1:1 perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 300; exec @ARGV' java $JL -Xlog:class+load=info:file=<capture dir>/classload.txt -cp \"../hc:<the jar>:<its lib/*>\" com.tiffinbox.web.TiffinBoxServer --logging.config=../../harness/logback.xml --tiffinbox.port=20665 --spring.main.sources=probe.u27.CacheBeans"
  python3 -I -B harness/chk27.py show runs $D $F | pr; }
tour() { python3 -I -B harness/chk27.py show tour .harness/dev-$CAPRUN | pr; }
copies() { python3 -I -B harness/chk27.py show copies .harness/dev-$CAPRUN | pr; }
default() { python3 -I -B harness/chk27.py show default .harness/def-$CAPRUN | pr; }
# tbfail OUT PORT CP ARGS...: after/'s jar (or the harness first on its class path) under dev on PORT with Boot's own logging, waited for
tbfail() { local o=$1 port=$2 cp=$3 e=0; shift 3
  mkdir -p "$o"
  (cd .harness/run-dev && exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -Duser.home=../home -cp "$cp../after/$XD/tiffinbox-web-1.0.0.jar:../after/$XD/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=$port "$@") > "$o/jvm.log" 2>&1 < /dev/null & pid=$!
  wait "$pid" || e=$?; pid=""
  [ "$(listeners $port)" = 0 ] || die "something still listens on $port"
  echo "$e" > "$o/exit"; }
absent() { local s o
  echo "-- absent: after/'s jar under dev on 20666 (Boot's own logging), one store's address moved to 127.0.0.1:20669 - nothing listens there - the other three up, one start each:"
  for s in pg redis es mongo; do o=.harness/absent-$s; rm -rf $o; fresh > /dev/null
    [ "$(listeners 20669)" = 0 ] || die "something listens on 20669 - absent's target must be free"
    case $s in
      pg) tbfail $o 20666 "" $DEVB "--tiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:20669/tiffinbox?user=tiffinbox" $A_RP $A_MO $A_ES ;;
      redis) tbfail $o 20666 "" $DEVB $A_PG --spring.data.redis.port=20669 $A_MO $A_ES ;;
      es) tbfail $o 20666 "" $DEVB $A_PG $A_RP $A_MO --spring.elasticsearch.uris=http://127.0.0.1:20669 ;;
      mongo) tbfail $o 20666 "" $DEVB $A_PG $A_RP --spring.mongodb.uri=mongodb://127.0.0.1:20669/tiffinbox $A_ES ;; esac
    echo "== absent $s: listening on 20669 before the start: 0 (lsof) · each key once on the command line: $(for k in tiffinbox.jdbc-url spring.data.redis.port spring.mongodb.uri spring.elasticsearch.uris; do printf '%s ' "$( { [ $s = pg ] && [ $k = tiffinbox.jdbc-url ]; } || { [ $s = redis ] && [ $k = spring.data.redis.port ]; } || { [ $s = mongo ] && [ $k = spring.mongodb.uri ]; } || { [ $s = es ] && [ $k = spring.elasticsearch.uris ]; } && echo "$k=<20669>" || echo "$k=<its store>")"; done | sed 's/ $//')"
    python3 -I -B harness/chk27.py show absent $o; done; }
twocaches() { local v o
  echo "-- twocaches: after/'s jar under dev on 20666 (Boot's own logging), the harness's CacheBeans and TwoCaches joined - a second CacheManager bean, localCaches:"
  for v in dynamic menu; do o=.harness/two-$v; rm -rf $o; fresh > /dev/null
    if [ $v = dynamic ]; then tbfail $o 20666 "../hc:" $DEV --spring.main.sources=probe.u27.CacheBeans,probe.u27.TwoCaches
    else tbfail $o 20666 "../hc:" $DEV --spring.main.sources=probe.u27.CacheBeans,probe.u27.TwoCaches --probe.twocaches.names=menu; fi
    echo "== twocaches, $v names$( [ $v = menu ] && echo ' (--probe.twocaches.names=menu)'):"
    echo "\$ cd .harness/run-dev && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -cp \"../hc:<after/'s jar>:<its lib/*>\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=20666 $DEVP --spring.main.sources=probe.u27.CacheBeans,probe.u27.TwoCaches$( [ $v = menu ] && echo ' --probe.twocaches.names=menu')"
    python3 -I -B harness/chk27.py show twocaches $o; done
  local CJ; CJ=$(ls .harness/after/$XD/lib/ | $G -E '^spring-boot-cache-[0-9.]+\.jar$')
  echo "  Boot's CacheAutoConfiguration, its class-level conditions (javap -v, after/'s own BOOT-INF/lib/$CJ):"
  javap -v -cp .harness/after/$XD/lib/$CJ org.springframework.boot.cache.autoconfigure.CacheAutoConfiguration 2> /dev/null | awk '/^RuntimeVisibleAnnotations:/ { f = 1; next } f && /^[^ ]/ { f = 0 } f && /condition\.ConditionalOnMissingBean\(|EnableConfigurationProperties\(/ { g = 1 } f && g { print } g && /^ +\)$/ { g = 0 }' | sed -E 's/^ +/    /'; }
seven() { local i=0 e=0 c a port=20665
  echo "-- the seven: after/'s jar, java -jar, H2 in memory (a fresh JVM), port $port:"
  echo "\$ cd .harness/after && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port"
  (cd .harness/after && DOCKER_HOST=tcp://127.0.0.1:1 exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port) > .harness/seven-run.log 2>&1 < /dev/null & pid=$!
  while [ $i -lt 480 ]; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/seven-run.log | mask >&3; die "TiffinBox exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $port"
  a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
  echo "  GET /actuator/health/readiness -> 200 · listens on: $a"
  echo "\$ \$CURLSET $port .harness/after/$TF"
  "$CURLSET" $port .harness/after/$TF | $G ' -> ' | awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' > .harness/seven.txt || true
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 480 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && die "TiffinBox on $port was still running after POST /shutdown"
  wait "$pid" || e=$?; pid=""
  [ "$(listeners $port)" = 0 ] || die "something still listens on $port"
  echo "  exit $e · the seven responses: $(wc -l < .harness/seven.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven.txt) · listening on $port now: 0"
  ! $G -qF -- "$TOKEN" .harness/seven-run.log || die "TiffinBox's log held the token"; }
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
ITS="CustomerEntityRepositoryIT jdbc/CustomerAggregatesIT web/RedisDatastoreIT web/MongoDatastoreIT web/ElasticsearchIT"
TD=tiffinbox-web/src/test/java/com/tiffinbox
bound() { local e=0 n v0 f m
  echo "-- bound: the change - before/ (the link ../c8-unit26/after, unit 26's tree) against after/ (diff -rq; then each file's changed lines, diff -u):"
  diff -rq before/ after/ 2>&1 | sed -E 's#^Files before/+(.*) and after/+.* differ$#  changed: \1#; s#^Only in after/+(.*): (.*)$#  new: \1/\2#; s#^Only in before/+(.*): (.*)$#  gone: \1/\2#' | sort
  for f in $(diff -rq before/ after/ 2>&1 | sed -nE 's#^Files before/+(.*) and after/+.* differ$#\1#p' | sort); do
    printf '    %s: +%s -%s\n' "$f" "$(diff -u before/$f after/$f | $G -cE '^\+[^+]|^\+$' || true)" "$(diff -u before/$f after/$f | $G -cE '^-[^-]|^-$' || true)"; done
  echo "  the trees (python3 -I harness/tree27.py, links followed): before/ $(python3 -I harness/tree27.py before/) · after/ $(python3 -I harness/tree27.py after/)"
  echo "  under tiffinbox-core/ and tiffinbox-web/src/main/: $(diff -rq before/tiffinbox-core after/tiffinbox-core | wc -l | tr -d ' ') + $(diff -rq before/tiffinbox-web/src/main after/tiffinbox-web/src/main | wc -l | tr -d ' ') files differ - the jar's sources byte-equal"
  echo "  before/'s three older ITs, their modifier (grep -c withCreateContainerCmdModifier): $(for f in CustomerEntityRepositoryIT jdbc/CustomerAggregatesIT web/RedisDatastoreIT; do printf '%s %s · ' "${f##*/}" "$($G -c withCreateContainerCmdModifier before/$TD/$f.java || true)"; done | sed 's/ · $//') - Testcontainers' default, read off MongoDatastoreIT's Javadoc in before/: $($G -o 'Testcontainers 2.0.5 publishes a container.s port on every interface' before/$TD/web/MongoDatastoreIT.java)"
  printf '  the static check (grep -c, after/'"'"'s five IT files - the address named, and the line):'
  m=""; for f in $ITS; do case $f in web/MongoDatastoreIT|web/ElasticsearchIT) n=$($G -c 'bindIpAndPort("127.0.0.1"' after/$TD/$f.java || true) ;; *) n=$($G -c 'bindIp("127.0.0.1")' after/$TD/$f.java || true) ;; esac
    k=$($G -cF 'System.out.println("IT BINDINGS ' after/$TD/$f.java || true); printf ' %s %s/%s ·' "${f##*/}" "$n" "$k"; [ "$k" = 1 ] || n=0; m="$m $n"; done
  echo " ->$m"
  echo "-- bound: mvn verify on .harness/tests, a plain copy of after/ (the change is shipped - no patch):"
  echo "  the copy against after/ (diff -rq, target and secrets left out): $(diff -rq -x target -x secrets after .harness/tests 2>&1 | wc -l | tr -d ' ') files differ"
  [ "$(listeners 20578)" = 0 ] && [ "$(listeners 20615)" = 0 ] || die "20578 or 20615 (the ITs' pinned bindings) is bound before mvn verify"
  echo "  before it: listening on 20578 (MongoDatastoreIT's pinned binding): 0 · on 20615 (ElasticsearchIT's): 0 · on 18881-18884: 0"
  v0=$(vols)
  echo "\$ cd .harness/tests && DOCKER_HOST=\$DH TESTCONTAINERS_RYUK_DISABLED=true $MV \"$AL\" clean verify -pl tiffinbox-web -am   (its alarm's cap: 900, R.247 - five ITs and an Elasticsearch start)"
  (cd .harness/tests && export DOCKER_HOST="$DH" TESTCONTAINERS_RYUK_DISABLED=true && eval "$MV \"$AL\" clean verify -pl tiffinbox-web -am") > .harness/verify.log 2>&1 < /dev/null & mpid=$!
  tcpoll "$mpid"; wait "$mpid" || e=$?; mpid=""
  [ "$e" != 142 ] || die "bound: Maven's alarm fired (exit 142, cap 900 - R.247)"
  n=$($G -cE '^\[INFO\] Download(ing|ed) from ' .harness/verify.log || true)
  echo "  exit $e · $($G -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/verify.log || echo 'no BUILD line') · offline: $( [ "$n" = 0 ] && echo yes || echo "no - $n lines say Maven downloaded")"
  [ "$n" = 0 ] || die "bound: Maven downloaded"
  dockeq bound "$v0"
  $G -E '^\[(INFO|WARNING|ERROR)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' .harness/verify.log | sed -E 's/^\[[A-Z]+\] /  the Results line: /'
  $G -E '^\[(INFO|WARNING|ERROR)\] Tests run: [0-9]+, .* -- in com\.tiffinbox\.web\.MongoDatastoreIT$' .harness/verify.log | sed -E 's/^\[[A-Z]+\] /  MongoDatastoreIT: /; s/, Time elapsed: [^ ]+ s//'
  echo "  the IT BINDINGS lines (each IT's own container, Docker's inspect, sorted; the host port masked):"
  $G -ho 'IT BINDINGS .*' .harness/verify.log .harness/tests/tiffinbox-web/target/failsafe-reports/*-output.txt .harness/tests/tiffinbox-web/target/surefire-reports/*-output.txt 2> /dev/null | sort -u | sed -E 's/:[0-9]+\]/:<port>]/; s/:[0-9]+,/:<port>,/g' | sed 's/^/    /'
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
exafter() { echo "  listening on 20661-20666 afterwards: $(( $(listeners 20661) + $(listeners 20662) + $(listeners 20663) + $(listeners 20664) + $(listeners 20665) + $(listeners 20666) )) · the exercise's containers afterwards: $(dk ps -aq --filter name=^/c8u27-ex- | $G -c . || true) · volumes $(vols) (before the shell: $1) · java processes of the exercise: $(ps -axo command= | $G -c '[.]harness/ex/x/tiffinbox-web' || true) · images afterwards: the same list $( [ "$(dk images -q --no-trunc 2> /dev/null | sort -u | paste -sd' ' -)" = "$IMGS0" ] && echo yes || echo no)"; }
exsh() { local sh=$1 e1 d1 e2 d2 v1 i=0
  rm -rf .harness/ex; rm -f .harness/ex-*.st .harness/ex-*.out
  v1=$(vols)
  printf '%s\n' 'cd "$1" || exit 1' '. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-readme.st"' 'cd "$1" || exit 1' '. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-sol.st"' > .harness/ex-drive-both.sh
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
  echo "a wrong \"solution\" - the class kept and the dev cache type switched to caffeine (the README's block, one line changed), three times, each in a fresh env -i bash, through exercise/check.sh:"
  diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$DELP") | $G '^>' | sed 's/^> /  $ /'
  for k in 1 2 3; do v1=$(vols); rm -rf .harness/ex; rm -f .harness/ex-del.st .harness/ex-del.out; exrun del bash; read -r e d < .harness/ex-del.st
    echo "  run $k - the block's exit $e:"; $G -E '^(check:|built:)' .harness/ex-del.out | sed 's/^/    /'; exafter "$v1"; done; }

# ---- the runs ------------------------------------------------------------------------------------------------------------------
echo "-- exercise (once per run of record; its four stores are its own, on 20661-20664, before the unit's):"
NCAP=1; cap exercise exercise; chk exercise .r-exercise.out "$EXW" "$EXQ"
for f in exercise/README.md exercise/SOLUTION.md; do
  w=$(python3 -I -B harness/chk27.py wib .r-exercise.out "$f"); [ "$(wib "$f")" = "$w" ] || die "$f's \"What it prints\" block is not what its lines printed: $(diff <(wib "$f") <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"; done
echo "  exercise: each file's \"What it prints\" block = what its lines printed (bash's; zsh's the same - chk27)"
pub exercise
[ "$(vols)" = "$VOL0" ] || die "R.322: after the exercise the volume count is $(vols), not $VOL0"
echo "-- the unit's four stores:"
stores > .harness/stores.out 2>&1 || true; [ -z "$pid$mpid" ] || die "the stores' window left a process running"
$G -q '^  \*\*\* ' .harness/stores.out && { cat .harness/stores.out >&3; die "the stores' window stopped (above)"; }
mask < .harness/stores.out | sed 's/^/  /'
fresh > .harness/fresh-1.txt; mask < .harness/fresh-1.txt | sed 's/^/  /'
echo "  (fresh, as above, before every TiffinBox JVM below: a new database, FLUSHALL, a new MongoDB, the dishes index deleted)"
echo "  one dev JVM per round served runs' first half, tour and copies; one default JVM per round served runs' second half and default"
NCAP=3
cap runs runs; chk runs .r-runs.out; pub runs
cap tour tour; chk tour .r-tour.out; pub tour
cap copies copies; chk copies .r-copies.out; pub copies
cap default default; chk default .r-default.out; pub default
NCAP=1
cap absent absent; chk absent .r-absent.out; pub absent
cap twocaches twocaches; chk twocaches .r-twocaches.out; pub twocaches
dk rm -fv $CN $RN $MN $EN > /dev/null 2>&1 || die "the unit's stores could not be removed"
[ "$(vols)" = "$VOL0" ] || die "R.322: after the stores' window the volume count is $(vols), not $VOL0"
echo "  $CN, $RN, $MN and $EN removed (rm -fv) · volumes $(vols)"
cap seven seven; chk seven .r-seven.out "$S466"; pub seven
cap bound bound; chk bound .r-bound.out 127.0.0.1; pub bound
echo "  the values (chk27's, every capture's): $(printf '%s\n' "$VALS" | wc -l | tr -d ' ') lines"
printf '%s\n' "$VALS" > .harness/values.txt
python3 -I -B harness/chk27.py readme README.md .harness/values.txt > .harness/chk-readme.out 2>&1 || { $G '^FAIL' .harness/chk-readme.out | head -5 >&3; die "README.md: its values block or a text block is not what the runs printed (R.302)"; }
echo "  R.302: README.md's $($G -c '^```text$' README.md) text blocks - every line one the runs printed; the values block = the captures' (chk27 readme: $($G -c '^ok ' .harness/chk-readme.out) checks)"
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
echo "  ports: nothing listens on 20660-20669, 20578, 20615 or 18881-18884 at the end - the unit's stores bound 20661-20664, TiffinBox 20660 (dev) and 20665 (the default run, the seven), the exercise's TiffinBox, absent's and twocaches' starts 20666 (the exercise's stores 20661-20664), mvn verify's pinned ITs 20578 and 20615; 20667-20668 and 20669 were never bound"
[ -z "$unpub" ] || { echo "c8-unit27: captures without a published hash:$unpub - write them into receipts.md5 from this run's output"; exit 0; }
echo "c8-unit27: every capture = published (runs, tour, copies and default 3/3 in this run; exercise, absent, twocaches, seven and bound once per run); every number re-derived by chk27.py; before/ = unit 26's after-tree, after/ = this unit's; the volume count and the images unchanged"
