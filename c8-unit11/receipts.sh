#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 8 · Redis as a Cache - this unit's receipts. Section 2's THIRD anchor change (C3): before/ is a link to ../c8-unit10/after (unit
# 10's tree, Caffeine in the JVM), after/ is this unit's tree and ../c8-tiffinbox equals it from this unit's commit on. tiffinbox-web gains
# spring-boot-starter-data-redis and RedisCaching.java (the cache writer TiffinBox gives Redis, and the JSON serializer built from Boot's
# CacheProperties); CustomerRepository.findAll() collects into an ArrayList; application.yaml keeps the default run on Caffeine with
# Redis's health indicator off; application-dev.yaml gives the profile "dev" Redis; compose.yaml gains a redis service. Two witnesses in
# every counted window (R.375): harness/src/probe/u11/Counter (unit 08's class: calls that reach Spring Data JPA's repository, a
# MethodInterceptor at position 0 of its proxy - outside the cached bean) and Hibernate's getPrepareStatementCount(); a window whose two
# per-call lists differ fails. redis-cli, the Redis image's own client, is the second client for the store (GET, SET, --scan, TYPE, TTL);
# psql for PostgreSQL's rows.
# Captures (the JVM ones run three times and hashed; nodocker and exercise once per run of record - their 3/3 is across the runs):
#   exercise  exercise/README.md's lines, then SOLUTION.md's, as written, in ONE env -i shell - bash, then zsh -f (its own Redis)
#   nodocker  mvn -o package with Maven's DOCKER_HOST at nothing (18), then mvn -o verify with Docker (18 + 5), Surefire per folder
#   anchor    after/ on H2 in memory with NO Redis (the default run), then after/ dev-shaped on PostgreSQL + Redis (both by the digest)
#   compose   the anchor's compose.yaml read by docker compose config; a labelled copy run by Boot's Compose support under "dev"
#   jdk       a copy without RedisCaching's configuration bean: Java's serialization, Boot's default - loud at put
#   json      the anchor's JSON: the bytes by redis-cli beside the classes read back; a copy with findAll back to toList(); a null
#   renamed   old bytes planted by redis-cli SET: a renamed String field (silent), a renamed int field and class (loud); javap
#   strict    a copy whose serializer fails on unknown properties: the same old bytes loud, an added field loud too; a key prefix
#   writer    a copy without RedisCaching's writer (Boot's own) beside the anchor's: evict then read, ten rounds; javap
#   ttlbean   a copy whose configuration bean ignores CacheProperties beside the anchor's: TTL read back by redis-cli
#   health    after/ on H2 with Redis's indicator on and no Redis: health 503; the cache type redis with no Redis: the call throws
#   seven     the comparison set on before/'s and after/'s jars (H2; after/ on 20500, before/ on 20505); Hibernate's script = xcheck.sql
# Every tree is COPIED under .harness/ and built there, offline (-o, from .m2-demo, a copy of the course's seed, maven.repo.local
# absolute), every module from the tree's own sources (-pl tiffinbox-web -am, R.391). Every JVM and Maven run under an alarm (R.247).
# Every docker call names its socket (dk, R.344; Boot's own Compose calls get DOCKER_HOST=$DH), --pull never / pull_policy: never; every
# container is removed with its volume (rm -fv), the Compose project with down -v (R.387).
# Ports (20500-20509): 20500 TiffinBox after/ (the harness's web server; the seven; the exercise) · 20501 the PostgreSQL container ·
# 20502 the Redis container (and the exercise's own Redis, never at the same time) · 20503 the Compose copy's Redis · 20504 the Compose
# copy's PostgreSQL · 20505 TiffinBox before/ for the seven · 20506 the port the health capture's no-Redis runs are pointed at - nothing
# listens there, asserted, never bound · 20507-20509 spare, never bound.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
RIMG=redis@sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3
CN=c8u11-pg; RN=c8u11-redis; EXN=c8u11-ex-redis; PROJ=c8-unit11
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
pid=""; mpid=""; xpid=""; CSTARTED=""; RSTARTED=""; CMP=""; TC0=""; INTR=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.u11.") || index($0, "probe.x.") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "curlset.sh") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || $3 ~ /(^|\/)javac$/ || index($0, "ex-drive.sh") || index($0, "javap")) { print $1 }' | paste -sd' ' -) || l=""
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
  [ -z "$(dk ps -aq --filter name=^/$EXN\$ 2> /dev/null)" ] || dk rm -fv "$EXN" > /dev/null 2>&1 || true
  [ -z "$RSTARTED" ] || { dk rm -fv "$RN" > /dev/null 2>&1 || true; RSTARTED=""; }
  [ -z "$CSTARTED" ] || { dk rm -fv "$CN" > /dev/null 2>&1 || true; CSTARTED=""; }
  if [ -n "$CMP" ] || [ -n "$(dk ps -aq --filter label=com.docker.compose.project=$PROJ 2> /dev/null)" ] || dk network inspect ${PROJ}_default > /dev/null 2>&1; then
    (cd .harness/compose-run 2> /dev/null && dk compose -p $PROJ down -v > /dev/null 2>&1) || dk compose -p $PROJ -f harness/compose/compose.yaml down -v > /dev/null 2>&1 || true; CMP=""; fi; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid" "$pid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; tcrm; ctrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git javap /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|FLYWAY_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|REDIS[A-Z_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT|COMPOSE_[A-Z_]*)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"

# ---- gates before anything is written: the folder, the links, the pins, the prose, the change, R.250 ---------------------------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh xcheck.sql' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk11.py compose dur8.py logback.xml s811.py src surefire.py tree11.py variants.py' ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe/u11/Counter.java probe/u11/HarnessNull.java probe/u11/U11.java probe/x/XMain.java' ] && [ "$(ls harness/compose | paste -sd' ' -)" = 'compose.yaml' ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file, or misses one"
cmp -s harness/dur8.py ../c8-unit02/harness/dur8.py || die "harness/dur8.py is not the builders' dur8.py as unit 02 shipped it, byte for byte"
cmp -s harness/surefire.py ../c8-unit02/harness/surefire.py || die "harness/surefire.py is not unit 02's, byte for byte"
cmp -s harness/logback.xml ../c8-unit07/harness/logback.xml || die "harness/logback.xml is not unit 07's, byte for byte"
cmp -s harness/src/probe/x/XMain.java ../c7-unit29/harness/src/probe/x/XMain.java || die "harness/src/probe/x/XMain.java is not Course 7 unit 29's, byte for byte"
cmp -s xcheck.sql ../c7-unit39/xcheck.sql || die "xcheck.sql must be Course 7's capstone's, byte for byte (unit 11 moves no JPA mapping)"
[ -L before ] && [ "$(readlink before)" = ../c8-unit10/after ] || die "R.211: before must be a link to ../c8-unit10/after (it points at: $(readlink before 2> /dev/null || echo 'not a link'))"
[ -d after ] && [ ! -L after ] || die "after/ must be this unit's own tree, not a link"
for t in after before; do [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] && die "$t holds a secrets/ or a target/ - never built in place"; true; done
git rev-parse -q --verify 'd1e4cf9^{commit}' > /dev/null 2>&1 || die "unit 10's commit d1e4cf9 is not in this repository's history"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree11.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/ ($3): python3 -I harness/tree11.py $dir/ -> $got = receipts.md5's $nm line"; }
pin before-tree before start; pin after-tree after start
U10P=$(awk '$1 == "after-tree" { print $2, $3 }' ../c8-unit10/receipts.md5)
[ "$U10P" = "$(awk '$1 == "before-tree" { print $2, $3 }' receipts.md5)" ] || die "before/'s pin is not unit 10's after-tree line ($U10P)"
echo "  before/'s pin = ../c8-unit10/receipts.md5's after-tree line ($U10P), re-derived by harness/tree11.py"
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c8-tiffinbox 2>&1 || true)
echo "  after/ against ../c8-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor' || echo 'they differ - a later unit moved the anchor; this unit measures after/')"
echo "  after/ against before/ (diff -rq, the files C3 changed):"; diff -rq before/ after/ 2>&1 | sed -E 's#^Files before/(.*) and after/.* differ$#    changed: \1#; s#^Only in after/(.*): (.*)$#    new: \1/\2#; s#^Only in before/(.*): (.*)$#    gone: \1/\2#'
for f in tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenHealthIndicator.java tiffinbox-core/src/main/java/com/tiffinbox/Dashboard.java tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java; do
  [ "$(md5 -q "after/$f")" = "$(md5 -q "before/$f")" ] || die "C3 leaves $f untouched: after/'s differs from before/'s"
  echo "  after/$f: md5 $(md5 -q "after/$f") = before/'s (untouched)"; done
CMPV=$(mkdir -p "${TMPDIR:-/tmp}/c8u11.$$" && cp after/compose.yaml "${TMPDIR:-/tmp}/c8u11.$$/compose.yaml" && python3 -I -B harness/variants.py compose "${TMPDIR:-/tmp}/c8u11.$$" && cmp -s "${TMPDIR:-/tmp}/c8u11.$$/compose.yaml" harness/compose/compose.yaml && echo same) || true
rm -rf "${TMPDIR:-/tmp}/c8u11.$$"
[ "$(printf '%s\n' "$CMPV" | tail -1)" = same ] || die "harness/compose/compose.yaml is not harness/variants.py's compose copy of after/compose.yaml, byte for byte"
echo "  harness/compose/compose.yaml = harness/variants.py compose over after/compose.yaml, byte for byte - the lines it changes:"; printf '%s\n' "$CMPV" | sed '$d' | sed 's/^/  /'
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s811.py harness/dur8.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -2 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
DN=$($G -rniwE -- "$DISH" README.md exercise harness 2> /dev/null | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
PH=$($G -rnE 'PENDING|PLACEHOLDER|VALUES-PENDING|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or harness: $PH"
for t2 in 'Docker Compose for Development' 'N+1, Measured' '@Cacheable, @CacheEvict, @CachePut' 'Caffeine' 'Redis as a Cache'; do $G -qF -- "*$t2*" README.md || die "R.224: README.md calls the unit back by its title: $t2"; done
! $G -q '^```java$' README.md || die "README.md holds a java block - the code is the anchor's files and the harness's"
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
EXQ="Your turn: the cached customer list comes back once, then the second read from Redis throws. Make the second read a hit."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SETUP=$(block exercise/README.md); SOL=$(block exercise/SOLUTION.md)
[ -n "$SETUP" ] && [ -n "$SOL" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
[ "$(diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G -c '^[<>]')" = 2 ] || die "R.196: SOLUTION.md's block must be the README's with one line changed"
printf '%s\n' "$SETUP" | $G -E '(^|[ (])(mvn|java|javac) ' | $G -vqF "perl -e 'alarm " && die "exercise/README.md's Java and Maven runs must run under their alarm (R.247)"
printf '%s\n' "$SETUP" | $G -E 'mvn ' | $G -vqF -- '-pl tiffinbox-web -am' && die "R.391: exercise/README.md builds without -pl tiffinbox-web -am"
printf '%s\n' "$SETUP" | $G -E '\bdocker ' | $G -vqF -- 'docker -H "$DH"' && die "R.344: exercise/README.md calls docker without the socket it names"
[ "$(printf '%s\n' "$SETUP" | $G -oE 'docker -H "\$DH" rm( +-[a-z]+)*' | sort -u | paste -sd'|' -)" = 'docker -H "$DH" rm -fv' ] || die "R.387: exercise/README.md removes its container without its volume"
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket (docker -H \"\$DH\")"
DK=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -nE '\bdocker (run|exec|rm|ps|port|info|images|volume|image|pull|events|compose|network)\b' | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.344: receipts.sh calls docker without the pinned socket (every call is dk): $DK"
RMF=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) rm( +-[a-z]+)*' | sort -u | paste -sd'|' -)
[ "$RMF" = 'dk rm -fv' ] || die "R.387/R.322: receipts.sh removes a container without its volume - every removal is dk rm -fv (found: ${RMF:-none})"
DNV=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE 'compose -p [$A-Za-z0-9_-]+( -f [^ ]+)? down( +-[a-z]+)*' | sed -E 's/ -f [^ ]+//' | sort -u | paste -sd'|' -)
[ "$DNV" = 'compose -p $PROJ down -v' ] || die "R.387: receipts.sh takes a Compose project down without its volumes - every one is down -v (found: ${DNV:-none})"
RUNP=$($G -v '^ *#' receipts.sh | $G -oE '(dk|docker) run -[^"]*' | $G -vcF -- '--pull never' || true)
[ "$RUNP" = 0 ] || die "R.344: a dk run without --pull never"
MVA=$($G -v '^ *#' receipts.sh | $G -F 'clean ' | $G -F '$MV' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am"
ST=$(python3 -I -B harness/chk11.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
R250=$(python3 -I -B harness/chk11.py r250 after before) || die "R.250: $(printf '%s\n' "$R250" | $G '^FAIL' | head -2 | paste -sd';' -)"
printf '%s\n' "$R250" | $G -v '^VALUES ' | sed 's/^/  /'
echo "  the callers of findAll() (RED #9, the shared ArrayList), on after/'s sources:"; (cd after && $G -rn '\.findAll()\|::findAll' tiffinbox-core/src/main/java tiffinbox-web/src/main/java | $G -v 'CustomerEntityRepository.java' | sed 's/^/    /')
echo "  prose, per sentence (s811, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test): refused 0 over $PROSE · dish names 0 · placeholders 0 · called back by title · no java block"
echo "  the exercise: the spoken line $EXW words (wc -w); SOLUTION.md's block = the README's with one line changed; the two \"What it prints\" blocks differ (R.196); its builds -pl tiffinbox-web -am; its docker calls name their socket, its removal rm -fv"
echo "  static: no kill by name; every docker call on the pinned socket, every dk run --pull never; every container removal dk rm -fv, every Compose down -v (R.387); every Maven build -pl tiffinbox-web -am (R.391)"
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
    gsub(/PT[0-9.]+S/, "PT<t>S")
    gsub(/Total time: +[0-9.:]+ [a-z]+/, "Total time: <t>")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/totalLoadTime=[0-9]+/, "totalLoadTime=<masked>")
    gsub(/time-to-live=[0-9]+s/, "time-to-live=<n>s")
    gsub(/TTL [0-9]+/, "TTL <n>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxWebTest in 3.1 seconds (process running for 4.2)' 'Tests run: 2, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 3.982 s' 'Finished Spring Data repository scanning in 23 ms. Found 0 Redis repository interfaces.' 'Root WebApplicationContext: initialization completed in 812 ms' 'Successfully applied 3 migrations (execution time 00:00.026s)' 'Container redis@sha256:7958 started in PT0.6S' 'ttl PT2S' '--spring.cache.redis.time-to-live=2s' 'redis-cli TTL 2' 'Total time:  12.345 s' 'CacheStats{hitCount=4, missCount=1, totalLoadTime=3833000, evictionCount=0}' "$U/x $HOME/y" | mask)
printf '%s\n' "$MP" | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=sys.stdin.read(); sys.exit(1 if m.DUR.search(t) or "PT0" in t or "PT2" in t or "3.982" in t or "00:00.026" in t or "812" in t or "12.345" in t or "3833000" in t or "live=2s" in t or "TTL 2" in t or "totalLoadTime=<masked>" not in t else 0)' || die "R.388: the mask's self-test - a planted duration line passed it unmasked: $(printf '%s\n' "$MP" | head -2 | paste -sd';' -)"
[ "$(printf '%s\n' "$MP" | tail -1)" = '…/x ~/y' ] || die "the mask's self-test: the folders and the home must be masked"
echo "  mask: its self-test refused the planted Started-in-seconds, Time elapsed, scanning, initialization, execution-time, started-in-PT, ttl PT, time-to-live=, TTL, Total time and totalLoadTime= lines unmasked (R.366, R.388); folders and home masked"
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
TID=$(dk image inspect --format '{{.Id}}' redis:8-alpine 2> /dev/null | cut -c8-19)
[ "$TID" = "$RID" ] || die "the tag redis:8-alpine (the viewer's line, the exercise's) is not the digest's image here (${TID:-absent}) - docker -H \"\$DH\" pull redis:8-alpine is yours to run"
RVOL=$(dk image inspect --format '{{json .Config.Volumes}}' "$RIMG" 2> /dev/null)
RY0=$(dk images --format '{{.Repository}}' 2> /dev/null | $G -c ryuk || true)
[ "$RY0" = 0 ] || die "R.318: an image named ryuk is on this machine ($RY0) - Ryuk stays off and none is pulled"
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run - remove it with its volume: docker -H \"\$DH\" rm -fv <id>"
for c in $CN $RN $EXN; do [ -z "$(dk ps -aq --filter name=^/$c\$ 2> /dev/null)" ] || die "a container named $c exists before the run - an interrupted run's? docker -H \"\$DH\" rm -fv $c"; done
[ -z "$(dk ps -aq --filter label=com.docker.compose.project=$PROJ 2> /dev/null)" ] && ! dk network inspect ${PROJ}_default > /dev/null 2>&1 || die "the Compose project $PROJ (a container or its network) exists before the run - docker -H \"\$DH\" compose -p $PROJ down -v"
TC0=1
[ ! -e "$HOME/.testcontainers.properties" ] || die "R.318: ~/.testcontainers.properties exists - this unit's Testcontainers JVMs read a receipt home under .harness/ only"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 18881 18882 20500 20501 20502 20503 20504 20505 20506 20507 20508 20509"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
[ "$(pgrep -x java | wc -l | tr -d ' ')" = 0 ] || die "a java process is running before this script starts one - not this script's; stop it first"
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · $IMG present, id $IID · $RIMG present, id $RID, the tag redis:8-alpine the same id, its declared volumes (Config.Volumes) $RVOL · nothing pulled, ever · images named ryuk $RY0 · Testcontainers containers 0 · the Compose project $PROJ absent · ports 20500-20509 (and 18425, 8080, 18881, 18882) free · java processes 0"

# ---- the trees, copied; the builds; the harness ----------------------------------------------------------------------------------
rm -rf .harness; mkdir -p .harness; mkdir -p .harness/run-h2/secrets/tiffinbox .harness/run-pg/secrets/tiffinbox .harness/hc .harness/hcx .harness/home .harness/run .harness/compose-run/secrets/tiffinbox
M2="$PWD/.m2-demo"
[ -d "$M2" ] || die ".m2-demo (a copy of the course's seed, _research/m2-seed-c8-s2) is missing - README.md, The repository"
for a in org/springframework/boot/spring-boot-starter-data-redis/4.1.2/spring-boot-starter-data-redis-4.1.2.jar org/springframework/data/spring-data-redis/4.1.2/spring-data-redis-4.1.2.jar io/lettuce/lettuce-core/7.5.2.RELEASE/lettuce-core-7.5.2.RELEASE.jar tools/jackson/core/jackson-databind/3.1.7/jackson-databind-3.1.7.jar org/springframework/boot/spring-boot-docker-compose/4.1.2/spring-boot-docker-compose-4.1.2.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - the seed lacks it (README.md, The repository)"; done
NF0=$(find "$M2" -type f | wc -l | tr -d ' ')
printf '%s\n' 'checks.disable=true' "tinyimage.container.image=$IMG" > .harness/home/.testcontainers.properties
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
VARS="jdk tolist strict writer ttlbean"
copy before .harness/before; copy after .harness/after; copy after .harness/tests
for v in $VARS; do copy after .harness/$v
  VAR=$(python3 -I -B harness/variants.py $v .harness/$v) || die "the $v copy could not be derived: $VAR"
  printf '%s\n' "$VAR" > .harness/variant-$v.txt
  F=$(printf '%s\n' "$VAR" | head -1 | sed 's/ - from after.*//')
  [ "$(diff -rq .harness/after .harness/$v | paste -sd' ' -)" = "Files .harness/after/$F and .harness/$v/$F differ" ] || die "the $v copy differs from after/ beyond $F"; done
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE '^\[INFO\] Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" perl -e 'alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
AL="-DargLine=$JL -Dstdout.encoding=UTF-8 -Duser.home=../../home"
for t in before after $VARS; do
  XG=""; [ $t = after ] && XG=" dependency:build-classpath -Dmdep.outputFile=target/classpath.txt -Dmdep.includeScope=runtime"
  bg "cd .harness/$t && $MV clean package -DskipTests$XG -pl tiffinbox-web -am" .harness/build-$t.log
  [ "$RE" = 0 ] || { tail -20 .harness/build-$t.log >&3; die ".harness/$t did not build offline (exit $RE)"; }; offl .harness/build-$t.log
  bg "cd .harness/$t && perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$t.log
  [ "$RE" = 0 ] || die ".harness/$t: the jar's extract failed"; done
bg "javac -parameters -d .harness/hc -cp \".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*\" harness/src/probe/u11/*.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/: $(head -5 .harness/javac.log)"
for v in $VARS; do cmp -s .harness/after/$XD/lib/spring-data-redis-4.1.2.jar .harness/$v/$XD/lib/spring-data-redis-4.1.2.jar && [ "$(ls .harness/after/$XD/lib | md5 -q)" = "$(ls .harness/$v/$XD/lib | md5 -q)" ] || die "the $v copy's libraries are not after/'s"; done
$G -q 'spring-boot-docker-compose-4.1.2.jar' .harness/after/tiffinbox-web/target/classpath.txt || die "Maven's class path for after/ lacks spring-boot-docker-compose"
mkdir -p .harness/lib-nofly
for j in $(ls .harness/after/$XD/lib); do case $j in flyway-*|spring-boot-flyway-*) ;; *) ln -s ../after/$XD/lib/$j .harness/lib-nofly/$j ;; esac; done
bg "javac -parameters -d .harness/hcx -cp \".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*\" harness/src/probe/x/XMain.java" .harness/javac-x.log
[ "$RE" = 0 ] || die "Hibernate's schema probe did not compile: $(head -5 .harness/javac-x.log)"
TF=secrets/tiffinbox/shutdown-token
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/run-h2/$TF) || die "the token was not written"
for d in run-pg after before compose-run; do mkdir -p .harness/$d/secrets/tiffinbox; (umask 077 && cp .harness/run-h2/$TF .harness/$d/$TF) || die "the token was not copied"; done
TOKEN=$(head -1 .harness/run-h2/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
PW=$(openssl rand -hex 16); (umask 077 && printf 'POSTGRES_USER=tiffinbox\nPOSTGRES_PASSWORD=%s\n' "$PW" > .harness/pg.env) || die "the password file was not written"
cp harness/compose/compose.yaml .harness/compose-run/compose.yaml
echo "  built before/'s, after/'s and the five copies' trees offline (mvn -o package -DskipTests -pl tiffinbox-web -am, exit 0, 'Downloaded from' 0; after/'s also wrote Maven's runtime class path), extracted their jars (each copy's libraries = after/'s), compiled the harness against after/'s; Hibernate's schema probe compiled; a shutdown token and a PostgreSQL password generated (0600, never printed)"
for v in $VARS; do echo "  the $v copy (.harness/$v), derived from after/'s file by harness/variants.py - diff -rq against after/: that file alone:"; sed 's/^/    /' .harness/variant-$v.txt; done
NOTES=$(printf '%s\n' "  the copies: $(for v in $VARS; do printf '%s ' "$v=$(md5 -q .harness/variant-$v.txt | cut -c1-8)"; done)")
printf '%s\n' "$NOTES" > .harness/gate.out

# ---- helpers -------------------------------------------------------------------------------------------------------------------
startdb() {
  CSTARTED=1
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:20501:5432 --env-file .harness/pg.env $IMG" .harness/docker-run.log
  [ "$RE" = 0 ] || die "the PostgreSQL container did not start: $(tail -2 .harness/docker-run.log)"
  RSTARTED=1
  bg "dk run -d --pull never --name $RN -p 127.0.0.1:20502:6379 $RIMG" .harness/docker-run-redis.log
  [ "$RE" = 0 ] || die "the Redis container did not start: $(tail -2 .harness/docker-run-redis.log)"
  local i=0; while ! dk exec "$CN" pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 120 ] || die "PostgreSQL did not accept connections (120 tries)"; sleep 0.5; done
  i=0; while [ "$(dk exec "$RN" redis-cli PING 2> /dev/null)" != PONG ]; do i=$((i + 1)); [ $i -lt 120 ] || die "Redis did not answer PING (120 tries)"; sleep 0.5; done
  DP=$(dk port "$CN" 2> /dev/null | paste -sd'|' -); DR=$(dk port "$RN" 2> /dev/null | paste -sd'|' -)
  [ "$DP" = '5432/tcp -> 127.0.0.1:20501' ] || die "the PostgreSQL container must publish 5432 on 127.0.0.1:20501 alone: $DP"
  [ "$DR" = '6379/tcp -> 127.0.0.1:20502' ] || die "the Redis container must publish 6379 on 127.0.0.1:20502 alone: $DR"
  echo "  the containers: $CN from $IMG (--pull never), published $DP, user tiffinbox, its password from a 0600 file; $RN from $RIMG (--pull never), published $DR, no password - 127.0.0.1 only; pg_isready and PING (cap 120 tries each)"
  echo "  $(dk exec "$RN" redis-cli --version) · INFO server: $(dk exec "$RN" redis-cli INFO server | tr -d '\r' | $G '^redis_version:')"; }
psq() { dk exec "$CN" psql -U tiffinbox -d "$1" -qAt -v ON_ERROR_STOP=1 -c "$2" 2>&1 || die "psql failed on $1: $2"; }
pgdb() { psq postgres "drop database if exists $1 with (force)" > /dev/null; psq postgres "create database $1" > /dev/null
  (umask 077 && printf 'jdbc:postgresql://127.0.0.1:20501/%s?user=tiffinbox&password=%s\n' "$1" "$PW" > .harness/run-pg/secrets/tiffinbox/jdbc-url) || die "the URL was not written"
  echo "  a fresh database: $1 (psql) · its URL in the config tree (0600, never printed)"; }
pgdrop() { psq postgres "drop database $1 with (force)" > /dev/null; echo "  dropped: $1"; }
rc() { dk exec "$RN" redis-cli "$@" 2>&1 | tr -d '\r'; }
KEY='customers::SimpleKey []'
flush() { [ "$(rc FLUSHALL)" = OK ] || die "redis-cli FLUSHALL failed"; echo "  redis-cli FLUSHALL -> OK · --scan: $(rc --scan | $G -c . || true) keys"; }
scan() { echo "  redis-cli --scan: $(rc --scan | sort | paste -sd'|' -)"; }
RS="--spring.cache.type=redis --management.health.redis.enabled=true --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20502"
HX=0
# hj TREE DB PORT STEPS [ARG...]: one harness JVM over TREE's jar (after or a copy), its web server on PORT, on H2 (DB=h2,
# .harness/run-h2) or on PostgreSQL (DB=pg, .harness/run-pg, whose config tree holds the URL); ARG more Spring arguments (the Redis
# settings RS, a flag); its exit asserted = $HX; its log kept as .harness/h-<TREE>-<DB>.log
hj() { local tr=$1 db=$2 port=$3 steps=$4 c; shift 4
  c="cd .harness/run-$db && perl -e 'alarm 240; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../$tr/$XD/tiffinbox-web-1.0.0.jar:../$tr/$XD/lib/*\" probe.u11.U11 $steps --tiffinbox.port=$port${1:+ $*} --logging.config=../../harness/logback.xml --spring.main.banner-mode=off --spring.jpa.properties.hibernate.generate_statistics=true --management.endpoint.health.show-components=always"
  echo "\$ $c" | sed 's#\.\./\.\./harness#…/harness#'
  bg "$c" .harness/h.log
  [ "$RE" != 142 ] || die "the harness JVM's alarm fired (exit 142, cap 240 - R.247)"
  hlog .harness/h.log
  [ "$(listeners $port)" = 0 ] || die "something still listens on $port after the harness JVM stopped"
  cp .harness/h.log ".harness/h-$tr-$db.log"; $G '^U11-RAW ' .harness/h.log >> .harness/raw.txt || true
  [ "$RE" = "$HX" ] || die "the harness JVM exited $RE, not $HX ($tr, $db, $steps): $($G '^PROBE' .harness/h.log | tail -2 | paste -sd';' -)"; }
hlog() {
  $G -oE 'Multiple Spring Data modules found, entering strict repository configuration mode|Found [0-9]+ (JPA|JDBC|Redis) repository interfaces?|HHH000001: Hibernate ORM core version [^ ]+|FlywayExecutor : Database: .*' "$1" | sed -E 's/FlywayExecutor : //; s#127\.0\.0\.1:(20501|20504)/[a-z0-9]+#127.0.0.1:<port>/<db>#' | sed 's/^/  log: /'
  $G -E '^PROBE ' "$1" | mask
  echo "  exit $RE · its log, every line but the harness's own PROBE lines: WARN $($G -c '^WARN ' "$1" || true) · ERROR $($G -c '^ERROR ' "$1" || true) · exception class names $($G -v '^PROBE ' "$1" | $G -vF 'Exception encountered during' | $G -cE '[A-Za-z]+(Exception|Error)\b' || true)"
  $G '^WARN ' "$1" | sed -E 's/^WARN +\[[^]]*\] /  its WARN line: /' | cut -c1-160 | sort; }
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
  o=$(python3 -I -B harness/chk11.py "$nm" "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk11 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -5 >&3; die "$nm: its check failed (harness/chk11.py)"; }
  VALS="$VALS${VALS:+ · }$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }
VEXP=0
dockeq() { local v i c n
  i=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -); v=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
  c=$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null | wc -l | tr -d ' ')
  n=$(find "$M2" -type f | wc -l | tr -d ' ')
  [ "$i" = "$IMGS0" ] || die "$1: the images moved - nothing may be pulled"
  [ "$v" = "$((VOL0 + VEXP))" ] || die "R.322: $1: the volume count is $v, not $VOL0 + $VEXP (this script's PostgreSQL container's own)"
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
LIBS=".harness/after/$XD/lib"
plant() { python3 -I -B -c '
import sys
b = open(sys.argv[1], encoding="utf-8").read().rstrip("\n")
old, new = sys.argv[2], sys.argv[3]
if b.count(old) != 1: print("the plant'"'"'s source text is not in the bytes once: " + old); sys.exit(1)
sys.stdout.write(b.replace(old, new))' "$@"; }
PRIYA='{"@class":"com.tiffinbox.Customer","name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"}'

# ---- the captures --------------------------------------------------------------------------------------------------------------
anchor() { local t
  echo "-- the jar's libraries (ls lib | wc -l), before/ and after/, and the jars after/ gained (comm, by name):"
  for t in before after; do echo "  $t/: $(ls .harness/$t/$XD/lib | wc -l | tr -d ' ') libraries · Redis's client in lib/: $(ls .harness/$t/$XD/lib | $G -iE '^(lettuce|jedis)-' | paste -sd' ' - || true) · spring-data-redis in lib/: $(ls .harness/$t/$XD/lib | $G -E '^spring-data-redis-' || echo none)"; done
  comm -13 <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | sed 's/^/  gained: /'
  comm -23 <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | sed 's/^/  lost: /'
  echo "  Jackson's databind in after/'s lib/: $(ls $LIBS | $G -E '^jackson-databind-' | paste -sd' ' -) (tools.jackson's, Jackson 3) · jedis in lib/: $(ls $LIBS | $G -ic '^jedis-' || true)"
  echo "-- after/ on H2 in memory, NO Redis (TiffinBox's default run: no Redis setting given, no Redis container asked), one JVM, its web server on 20500:"
  hj after h2 20500 info,reads,http
  echo "-- after/ dev-shaped, on PostgreSQL 18.6 + Redis 8.10.3 (both containers, by the digest; the Redis settings from the harness's command line), one JVM, its web server on 20500:"
  echo "  the Redis container's own client: $(rc --version) · INFO server: $(rc INFO server | $G '^redis_version:')"
  flush; pgdb u11a; hj after pg 20500 info,reads,http $RS; scan; pgdrop u11a; }
compose() { local e=0 l
  echo "-- the anchor's compose.yaml, read by Compose (its config command, on the pinned socket - nothing started, nothing pulled): its image and published-port lines"
  (cd after && dk compose -f compose.yaml config 2> /dev/null) | $G -E '^  [a-z]+:$|image:|published:' | sed 's/^/  /'
  echo "-- the receipts' labelled copy, harness/compose/compose.yaml, in .harness/compose-run (its folder, with secrets/): after/ with --spring.profiles.active=dev on Maven's class path (spring-boot-docker-compose on it), Boot's Compose calls on the pinned socket (DOCKER_HOST), one JVM, its web server on 20500:"
  echo "  keys spring.data.redis.* in after/'s YAML files: $(python3 -I -B harness/chk11.py yamlkeys after | $G -c '^spring\.data\.redis\.' || true)"
  CMP=1
  echo "\$ cd .harness/compose-run && DOCKER_HOST=\$DH perl -e 'alarm 300; exec @ARGV' java $JL -cp \"../hc:<Maven's class path for after/>:../after/tiffinbox-web/target/classes\" probe.u11.U11 info,reads,pause,http --tiffinbox.port=20500 --spring.profiles.active=dev …"
  (cd .harness/compose-run && DOCKER_HOST="$DH" exec perl -e 'alarm 300; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -cp "../hc:$(cat ../after/tiffinbox-web/target/classpath.txt):../after/tiffinbox-web/target/classes" probe.u11.U11 info,reads,pause,http --tiffinbox.port=20500 --logging.config=../../harness/logback.xml --spring.main.banner-mode=off --spring.jpa.properties.hibernate.generate_statistics=true --management.endpoint.health.show-components=always --spring.profiles.active=dev --logging.level.org.springframework.boot.docker.compose=info) > .harness/compose.log 2>&1 < /dev/null & pid=$!
  rm -f .harness/compose-scan.txt .harness/compose-run/go; local k=0
  while kill -0 "$pid" 2> /dev/null && ! $G -q '^PROBE pause: the receipt reads the store now' .harness/compose.log; do k=$((k + 1)); [ $k -lt 1200 ] || break; sleep 0.25; done
  if $G -q '^PROBE pause: the receipt reads the store now' .harness/compose.log; then
    echo "--scan $(dk exec ${PROJ}-redis-1 redis-cli --scan 2> /dev/null | tr -d '\r' | paste -sd'|' -) · TYPE $(dk exec ${PROJ}-redis-1 redis-cli TYPE "$KEY" 2> /dev/null | tr -d '\r')" > .harness/compose-scan.txt; fi
  : > .harness/compose-run/go; wait "$pid" || e=$?; pid=""; RE=$e
  [ "$e" != 142 ] || die "the Compose JVM's alarm fired (exit 142)"
  SCANC=$(cat .harness/compose-scan.txt 2> /dev/null || echo 'not read')
  $G -oE 'Using Docker Compose file .*' .harness/compose.log | sed -E 's#file .*/compose-run/#file …/compose-run/#' | sed 's/^/  /'
  for l in "Network ${PROJ}_default" "Volume ${PROJ}_data" "Container ${PROJ}-postgres-1" "Container ${PROJ}-redis-1"; do
    echo "  $l: $($G -F "DockerCli :  $l " .harness/compose.log | sed -E "s/.*DockerCli :  $l //; s/ +$//" | paste -sd' ' -)"; done
  hlog .harness/compose.log
  echo "  redis-cli in the copy's Redis container (${PROJ}-redis-1), after the five reads, TiffinBox paused: $SCANC"
  [ "$(listeners 20500)" = 0 ] || die "something still listens on 20500 after the Compose JVM stopped"
  echo "  after TiffinBox stopped (Boot's own stop): the project's containers $(dk ps -a --filter label=com.docker.compose.project=$PROJ --format '{{.Names}} {{.Status}}' | sed -E 's/ (Exited \([0-9]+\)).*/ \1/' | sort | paste -sd'|' -) · its network $(dk network ls --filter name=^${PROJ}_default\$ --format '{{.Name}}' | paste -sd' ' -) · its volume $(dk volume ls -q --filter name=^${PROJ}_data\$ | paste -sd' ' -)"
  echo "\$ cd .harness/compose-run && docker -H \"\$DH\" compose -p $PROJ down -v"
  (cd .harness/compose-run && dk compose -p $PROJ down -v) > .harness/compose-down.log 2>&1 || die "compose down -v failed: $(tail -2 .harness/compose-down.log)"
  CMP=""
  $G -E 'Removed$|Removed *$' .harness/compose-down.log | sed -E 's/^ +//; s/ +$//' | sort | sed 's/^/  /'
  echo "  then: the project's containers $(dk ps -aq --filter label=com.docker.compose.project=$PROJ | $G -c . || true) · its network $(dk network ls -q --filter name=^${PROJ}_default\$ | $G -c . || true) · volumes $(dk volume ls -q | wc -l | tr -d ' ') ($VOL0 + this script's PostgreSQL container's $VEXP)"
  [ "$RE" = 0 ] || die "the Compose JVM exited $RE"; }
jdk() {
  echo "-- the jdk copy (no RedisCaching configuration bean: Boot's own - Java's serialization), PostgreSQL + Redis, one JVM:"
  flush; pgdb u11j; hj jdk pg 20500 info,two $RS; scan; pgdrop u11j
  echo "  Customer.java (tiffinbox-core, unchanged): $(cd after && $G -n '^public record Customer' tiffinbox-core/src/main/java/com/tiffinbox/Customer.java) · 'Serializable' in it: $($G -c Serializable after/tiffinbox-core/src/main/java/com/tiffinbox/Customer.java || true)"; }
json() {
  echo "-- after/ (the anchor's JSON serializer), PostgreSQL + Redis, one JVM, the harness's own cache named beside the anchor's (customers,h11):"
  flush; pgdb u11s; hj after pg 20500 info,reads,nullv $RS --spring.cache.cache-names=customers,h11
  echo "  redis-cli GET \"$KEY\" (raw bytes):"; rc GET "$KEY" | sed 's/^/    /'
  echo "  redis-cli TYPE \"$KEY\": $(rc TYPE "$KEY") · TTL: $(rc TTL "$KEY")"
  echo "  redis-cli --no-raw GET \"h11::SimpleKey []\" (the harness's null, its bytes escaped): $(rc --no-raw GET 'h11::SimpleKey []')"
  scan; pgdrop u11s
  echo "-- the tolist copy (findAll back to Stream.toList()), PostgreSQL + Redis, one JVM:"
  flush; pgdb u11t; hj tolist pg 20500 info,two $RS
  echo "  redis-cli GET \"$KEY\" (raw bytes):"; rc GET "$KEY" | sed 's/^/    /'
  pgdrop u11t; }
renamed() {
  echo "-- after/, PostgreSQL + Redis: one JVM writes the list; redis-cli reads its bytes; a Python edit renames one element's field; redis-cli SET writes them back; a second JVM reads"
  flush; pgdb u11r; hj after pg 20500 one $RS
  rc GET "$KEY" | tr -d '\n' > .harness/today.json
  echo "  redis-cli GET: $(wc -c < .harness/today.json | tr -d ' ') bytes · Priya's element: $($G -oF -- "$PRIYA" .harness/today.json)"
  plant .harness/today.json '"mealType":"VEGAN"}' '"type":"VEGAN"}' > .harness/old-string.json || die "the String plant failed"
  echo "  the planted bytes (an earlier build's: Priya's mealType written as type) - the edit's diff: $(diff <(tr ',' '\n' < .harness/today.json) <(tr ',' '\n' < .harness/old-string.json) | $G '^[<>]' | paste -sd' ' -)"
  echo "  redis-cli SET \"$KEY\" <the planted bytes>: $(rc SET "$KEY" "$(cat .harness/old-string.json)")"
  echo "-- the second JVM, after/, the renamed String field:"
  hj after pg 20500 one $RS
  echo "  psql (a second client, PostgreSQL): $(psq u11r "select name || ' ' || meal_type from customer where name = 'Priya'")"
  plant .harness/today.json '"name":"Priya","mealsPerDay":1' '"name":"Priya","meals":1' > .harness/old-int.json || die "the int plant failed"
  echo "  redis-cli SET (Priya's mealsPerDay written as meals): $(rc SET "$KEY" "$(cat .harness/old-int.json)")"
  echo "-- a third JVM, after/, the renamed int field:"; hj after pg 20500 one $RS
  plant .harness/today.json '{"@class":"com.tiffinbox.Customer","name":"Priya"' '{"@class":"com.tiffinbox.CustomerV0","name":"Priya"' > .harness/old-class.json || die "the class plant failed"
  echo "  redis-cli SET (Priya's @class written as com.tiffinbox.CustomerV0): $(rc SET "$KEY" "$(cat .harness/old-class.json)")"
  echo "-- a fourth JVM, after/, the renamed class:"; hj after pg 20500 one $RS
  pgdrop u11r
  echo "-- who makes the String field silent, read off the jars (javap -c):"
  echo "  jackson-databind-3.1.7.jar, tools.jackson.databind.DeserializationFeature's static initialiser - FAIL_ON_UNKNOWN_PROPERTIES's default:"
  javap -c -cp $LIBS/jackson-databind-3.1.7.jar tools.jackson.databind.DeserializationFeature | $G -A2 'String FAIL_ON_UNKNOWN_PROPERTIES$' | sed -E 's/#[0-9]+ +//; s/ +/ /g; s/^/    /'
  echo "  spring-data-redis-4.1.2.jar, GenericJacksonJsonRedisSerializer's builder - the mapper it builds:"
  javap -c -p -cp $LIBS/spring-data-redis-4.1.2.jar 'org.springframework.data.redis.serializer.GenericJacksonJsonRedisSerializer$GenericJacksonJsonRedisSerializerBuilder' | $G -A2 'Field tools/jackson/databind/DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES:' | sed -E 's/#[0-9]+ +//; s/ +/ /g; s/^/    /'; }
strict() {
  echo "-- the strict copy (its serializer: Jackson's FAIL_ON_UNKNOWN_PROPERTIES enabled), PostgreSQL + Redis: today's bytes, two calls, one JVM:"
  flush; pgdb u11x; hj strict pg 20500 two $RS
  rc GET "$KEY" | tr -d '\n' > .harness/strict-today.json
  echo "  redis-cli GET: the strict copy's bytes = the anchor's shape: $(plant .harness/strict-today.json "$PRIYA" "$PRIYA" > /dev/null && echo "Priya's element as the anchor writes it")"
  plant .harness/strict-today.json '"mealType":"VEGAN"}' '"type":"VEGAN"}' > .harness/strict-old.json || die "the plant failed"
  echo "  redis-cli SET (the same planted bytes: Priya's mealType written as type): $(rc SET "$KEY" "$(cat .harness/strict-old.json)")"
  echo "-- the strict copy, a second JVM, the renamed String field:"; hj strict pg 20500 one $RS
  plant .harness/strict-today.json '"mealType":"VEGAN"}' '"mealType":"VEGAN","phone":"none"}' > .harness/strict-added.json || die "the plant failed"
  echo "  redis-cli SET (an earlier build's bytes with a field this build lacks: Priya's phone): $(rc SET "$KEY" "$(cat .harness/strict-added.json)")"
  echo "-- the strict copy, a third JVM, the added field (the trade-off):"; hj strict pg 20500 one $RS
  echo "  redis-cli SET (the renamed-String bytes again, under the old key): $(rc SET "$KEY" "$(cat .harness/strict-old.json)")"
  echo "-- after/ itself with a versioned key prefix (--spring.cache.redis.key-prefix=v2: - Boot's own property, read by RedisCaching from CacheProperties), a fourth JVM:"
  hj after pg 20500 info,one $RS --spring.cache.redis.key-prefix=v2:
  scan; pgdrop u11x; }
writer() {
  echo "-- the writer copy (no RedisCacheManagerBuilderCustomizer: the writer Boot builds over Lettuce), PostgreSQL + Redis, one JVM:"
  flush; pgdb u11w; hj writer pg 20500 info,evict $RS
  echo "  psql (a second client): customers $(psq u11w 'select count(*) from customer')"; pgdrop u11w
  echo "-- after/ (the cache writer TiffinBox gives Redis), the same rounds, one JVM:"
  flush; pgdb u11v; hj after pg 20500 info,evict $RS
  echo "  psql (a second client): customers $(psq u11v 'select count(*) from customer')"; pgdrop u11v
  echo "-- the switches, read off the jars (javap -p):"
  javap -p -cp $LIBS/spring-data-redis-4.1.2.jar org.springframework.data.redis.cache.DefaultRedisCacheWriter | $G -E 'asynchronousWrites|writeAsynchronously|supportsAsyncRetrieve|REACTIVE_REDIS_CONNECTION_FACTORY_PRESENT' | sed -E 's/^ +/  DefaultRedisCacheWriter: /'
  javap -p -cp $LIBS/spring-data-redis-4.1.2.jar 'org.springframework.data.redis.cache.RedisCacheWriter$RedisCacheWriterConfigurer' | $G -E ' (immediateWrites|enableLocking)\(\);' | sed -E 's/^ +/  RedisCacheWriter.RedisCacheWriterConfigurer: /'
  echo "  Redis clients in after/'s lib/: $(ls $LIBS | $G -iE '^(lettuce-core|jedis)-' | paste -sd' ' -) - Lettuce only"; }
ttlbean() {
  echo "-- the ttlbean copy (its RedisCacheConfiguration bean ignores CacheProperties), PostgreSQL + Redis, spring.cache.redis.time-to-live set on the command line, one JVM:"
  flush; pgdb u11l; hj ttlbean pg 20500 info,one $RS --spring.cache.redis.time-to-live=600s
  echo "  redis-cli TTL \"$KEY\": $(rc TTL "$KEY")"
  echo "-- after/ (the anchor's bean, from CacheProperties), the same setting, one JVM:"
  flush; hj after pg 20500 info,one $RS --spring.cache.redis.time-to-live=600s
  local n; n=$(rc TTL "$KEY")
  echo "  redis-cli TTL \"$KEY\": TTL $n · a positive count, at most the configured value: $( [ "$n" -gt 0 ] 2> /dev/null && [ "$n" -le 600 ] && echo yes || echo no)"
  echo "-- after/, no time-to-live given, one JVM:"
  flush; hj after pg 20500 one $RS
  echo "  redis-cli TTL \"$KEY\": $(rc TTL "$KEY")"
  pgdrop u11l; }
health() {
  echo "-- after/ on H2 in memory, NO Redis, Redis's health indicator switched on by the harness's flag (the anchor's YAML unchanged), Lettuce pointed at 20506 (nothing listens there), one JVM:"
  echo "  listening on 20506: $(listeners 20506)"
  hj after h2 20500 info,http --management.health.redis.enabled=true --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20506
  echo "-- after/ on H2, NO Redis, the cache's type redis (the flag), Lettuce pointed at 20506, one JVM:"
  hj after h2 20500 two --spring.cache.type=redis --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20506
  echo "  listening on 20506: $(listeners 20506)"; }
nodocker() { echo "-- after/ copied to .harness/tests; mvn package with Maven's DOCKER_HOST pointed at nothing (tcp://127.0.0.1:1), offline:"
  rm -rf .harness/tests/tiffinbox-web/target .harness/tests/tiffinbox-core/target
  MPRE="env DOCKER_HOST=tcp://127.0.0.1:1"; mvnrun .harness/tests package "\"$AL\" clean package -pl tiffinbox-web -am"; MPRE=""
  echo "  Surefire's reports, $SR:"; pgr .harness/tests/$SR; echo "  $SRI: $( [ -d .harness/tests/$SRI ] && echo present || echo 'absent - no container test ran')"
  results .harness/package.log
  echo "-- then mvn verify, the anchor's recipe (DOCKER_HOST on the pinned socket, Ryuk off, a receipt home), offline:"
  rm -rf .harness/tests/tiffinbox-web/target .harness/tests/tiffinbox-core/target
  mvnrun .harness/tests verify "\"$AL\" clean verify -pl tiffinbox-web -am"
  echo "  Surefire's reports, $SR:"; pgr .harness/tests/$SR
  echo "  Surefire's reports, $SRI:"; pgr .harness/tests/$SRI
  results .harness/verify.log
  echo "  the verify log: 'Found 1 JPA repository interface' $($G -c 'Found 1 JPA repository interface' .harness/verify.log || true) · 'Found 0 Redis repository interfaces' $($G -c 'Found 0 Redis repository interfaces' .harness/verify.log || true) · 'Creating container for image' $($G -c 'Creating container for image: ' .harness/verify.log || true) · 'Pulling' $($G -c 'Pulling' .harness/verify.log || true) · 'RedisConnectionFailure' $($G -c 'RedisConnectionFailure' .harness/verify.log || true)"; }
XA=('--spring.datasource.url=jdbc:h2:mem:x11;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --logging.level.org.hibernate.orm.core=info --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
seven() { local t i c e a port
  echo "-- Hibernate's schema script over after/'s libraries without Flyway's jars (Course 7's probe.x.XMain, scripts.action=create, a file, never run):"
  rm -f .harness/run/hibernate-ddl.sql
  echo "\$ cd .harness/run && perl -e 'alarm 240; exec @ARGV' java $JL -cp \"../hcx:../lib-nofly/*\" probe.x.XMain \"\${XA[@]}\""
  (cd .harness/run && exec perl -e 'alarm 240; exec @ARGV' java $JL -cp "../hcx:../lib-nofly/*" probe.x.XMain "${XA[@]}") > .harness/x.log 2>&1 < /dev/null & pid=$!; e=0; wait "$pid" || e=$?; pid=""
  [ -f .harness/run/hibernate-ddl.sql ] || { tail -5 .harness/x.log >&3; die "xcheck: no script"; }
  echo "  exit $e · cmp with xcheck.sql (= Course 7's capstone's): $(cmp -s .harness/run/hibernate-ddl.sql xcheck.sql && echo 'the same, byte for byte' || echo differ)"
  for t in before after; do i=0; e=0; [ $t = after ] && port=20500 || port=20505
    echo "-- the seven: $t/'s jar, java -jar, H2 in memory (a fresh JVM), port $port:"
    echo "\$ cd .harness/$t && perl -e 'alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port"
    (cd .harness/$t && exec perl -e 'alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port) > .harness/seven-run.log 2>&1 < /dev/null & pid=$!
    while [ $i -lt 480 ]; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
      kill -0 "$pid" 2> /dev/null || { tail -20 .harness/seven-run.log | mask >&3; die "TiffinBox exited before readiness answered 200"; }
      sleep 0.25; i=$((i + 1)); done
    [ "$c" = 200 ] || die "readiness never answered 200 on $port"
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    echo "  GET /actuator/health/readiness -> 200 · GET /actuator/health -> $(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/actuator/health") · listens on: $a"
    $G -oE 'Found [0-9]+ (JPA|JDBC|Redis) repository interfaces?\.' .harness/seven-run.log | sed 's/^/  log: /'
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
  [ -z "$(dk ps -aq --filter name=^/$EXN\$ 2> /dev/null)" ] || die "the exercise's $sh left its Redis container ($EXN)"
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines, the block's exit $e1:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "  then the solution's lines, in the same shell - the block's exit $e2:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines · the exercise's Redis container afterwards: none"; }
exercise() {
  printf '%s\n' "$SETUP" > .harness/ex-readme.sh; printf '%s\n' "$SOL" > .harness/ex-sol.sh
  printf '%s\n' 'cd "$1" || exit 1' '. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-readme.st"' 'cd "$1" || exit 1' '. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-sol.st"' > .harness/ex-drive.sh
  echo "exercise/README.md's $(printf '%s\n' "$SETUP" | $G -c .) lines, then exercise/SOLUTION.md's, as written, one after the other in ONE env -i shell (HOME and the PATH this script was started with), started in this folder:"
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh; }

VEXP=0
NCAP=1; cap exercise exercise; chk exercise .r-exercise.out "$EXW" "$EXQ"
for f in exercise/README.md exercise/SOLUTION.md; do
  w=$(python3 -I -B harness/chk11.py wib .r-exercise.out "$f"); [ "$(wib "$f")" = "$w" ] || die "$f's \"What it prints\" block is not what its lines printed: $(diff <(wib "$f") <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"; done
echo "  exercise: each file's \"What it prints\" block = what its lines printed (bash's; zsh's the same - chk11)"
pub exercise
NCAP=1; export DOCKER_HOST="$DH" TESTCONTAINERS_RYUK_DISABLED=true; cap nodocker nodocker; unset DOCKER_HOST TESTCONTAINERS_RYUK_DISABLED; chk nodocker .r-nodocker.out; pub nodocker
startdb; VEXP=1
NCAP=3
cap anchor anchor; chk anchor .r-anchor.out; pub anchor
cap compose compose; chk compose .r-compose.out; pub compose
cap jdk jdk; chk jdk .r-jdk.out; pub jdk
cap json json; chk json .r-json.out; pub json
cap renamed renamed; chk renamed .r-renamed.out; pub renamed
cap strict strict; chk strict .r-strict.out; pub strict
cap writer writer; chk writer .r-writer.out; pub writer
cap ttlbean ttlbean; chk ttlbean .r-ttlbean.out; pub ttlbean
cap health health; chk health .r-health.out; pub health
cap seven seven; chk seven .r-seven.out "$S466"; pub seven
echo "  the reads right after a put through the writer Boot builds over Lettuce - not in any capture, they vary run to run: $($G -c 'Redis): reads right after a put' .harness/raw.txt || true) JVM lines in .harness/raw.txt"
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
  ! $G -qE ' (with PID|started by) | in [0-9.]+ seconds|Time elapsed: [0-9]|Total time: +[0-9]|execution time [0-9]|[0-9] ms\b|PT[0-9]|TTL [1-9]|time-to-live=[0-9]' "$f" || die "R.366: $f holds a time, unmasked"
  ! $G -qE '^ *[0-9]{4}-[0-9]{2}-[0-9]{2}[T ][0-9]|[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9]' "$f" || die "$f holds a log time"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'jdbc:h2:mem:[0-9a-f]{8}' "$f" || die "$f holds H2's generated database name, unmasked"
  ! $G -E '^ *\$ .*(^|[ (])(java|mvn) ' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM or Maven without its alarm (R.247)"
  ! $G -qF -- "$TOKEN" "$f" || die "$f holds the shutdown token"
  ! $G -qF -- "$PW" "$f" || die "$f holds the PostgreSQL password"; done
DC=$(cat .r-*.out | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
DR=$(awk '/^```text$/ { b = 1; next } b && /^```$/ { b = 0; next } b' README.md | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
[ "$DC" = 0 ] && [ "$DR" = 0 ] || die "R.388: dur8 finds $DC word(s) in the captures and $DR in README.md's text blocks - 0 is the rule"
[ -z "$(find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness (R.195)"
echo "  hygiene: dur8 over the captures and README.md's text blocks 0 words; no path, time, TTL count, log time, stack frame, H2 database name, raw port, token or password in any capture; every JVM and Maven under its alarm; no H2 file outside .harness"
# ---- the end: the containers, Compose, Testcontainers, the volumes, the images, the trees, the ports ---------------------------------
dk rm -fv "$RN" > /dev/null 2>&1 || die "the Redis container could not be removed"; RSTARTED=""
dk rm -fv "$CN" > /dev/null 2>&1 || die "the PostgreSQL container could not be removed"; CSTARTED=""
tcrm; [ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container is still there"
[ -z "$(dk ps -aq --filter label=com.docker.compose.project=$PROJ 2> /dev/null)" ] && ! dk network inspect ${PROJ}_default > /dev/null 2>&1 || die "the Compose project $PROJ is still there"
VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' '); IMGS1=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -)
[ "$VOL1" = "$VOL0" ] || die "R.322: the volume count moved, $VOL0 -> $VOL1"
[ "$IMGS1" = "$IMGS0" ] || die "the images moved over this run - nothing may be pulled"
[ ! -e "$HOME/.testcontainers.properties" ] || die "R.318: ~/.testcontainers.properties appeared over this run"
echo "  docker at the end: $CN and $RN removed with their volumes (rm -fv); the Compose project $PROJ gone (down -v); Testcontainers containers 0; volumes $VOL0 -> $VOL1; images $NI0, the same list (nothing pulled)"
pin before-tree before end; pin after-tree after end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 20500-20509 at the end - the containers bound 20501 and 20502, the Compose copy 20503 and 20504, and are gone; TiffinBox bound 20500 (after/, the copies, the exercise) and 20505 (before/, the seven) and stopped; 20506 was pointed at, never bound; 20507-20509 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c8-unit11: every capture = published (JVM captures 3/3 in this run; nodocker and exercise once per run); every spoken number asserted by chk11.py; before/ and after/ = their pins; the volume count and the images unchanged"
