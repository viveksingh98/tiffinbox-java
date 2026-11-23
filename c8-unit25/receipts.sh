#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 8 · The Spring Data Commons Layer - this unit's receipts. Section 5's first unit, and NO anchor change: before/ and after/ are
# both links to ../c8-unit24/after (unit 24's tree, which ../c8-tiffinbox equals) - every capture here runs on that one tree.
# What TiffinBox's six shipped repositories share - Commons' interfaces, Commons' method-name parser, Commons' one factory key - read
# twice: off the jars (javap, unzip) and off the run (the harness, probe.u25.H25, joined to TiffinBox under "dev" on the unit's four
# stores by --spring.main.sources; every line it prints says "the harness's"). Each module turns one parsed name into its own store's
# request, each request read by that store's own witness: PostgreSQL's log (log_statement=all), Redis's MONITOR, MongoDB's profiler,
# the Elasticsearch client's trace logger. Where the shared layer ends: one name on two stores, the harness's own repositories built
# through each module's RepositoryFactorySupport (never a scan), each call between its own markers, and each count read twice - the
# harness's Java and the store's own tool (redis-cli, mongosh) after the JVM is gone.
# Captures (the JVM ones three times and hashed; exercise, saveall, seven and verify once per run of record - their 3/3 is across runs):
#   exercise   exercise/README.md's lines, then SOLUTION.md's, as written, in ONE env -i shell - bash, then zsh -f; then two wrong
#              "solutions" (another method's name; another number) through exercise/check.sh - each must fail the check
#   jars       the eight Spring Data jars by path off .m2-demo (size, md5); javap -p of Commons' interfaces and each module's; the
#              factory key in each jar's META-INF/spring.factories; each module's query creator's class line; Commons' domain types
#   hierarchy  the harness, facts: Commons' Repositories over the dev context - the six, their factory beans, base classes, fragments,
#              chains; the harness's two repositories built by the factories first, the six still six; who injects each (grep)
#   parse      the harness, facts: PartTree on every query method's name and on findByMealType for all six domain types; each shipped
#              derived method called once between its own markers, by its store's witness
#   strict     the facts starts' own lines: strict mode, "Could not safely identify store assignment", each module's Found line
#   types      the harness, facts: Window's and ScrollPosition's jar; the shipped keyset method's first window and its SQL
#   hole       the harness, hole: one name on Spring Data Redis and Spring Data MongoDB, per call; redis-cli and mongosh after; the
#              Elasticsearch container's sockets at the end (S8.92)
#   saveall    the harness, saveall: Commons' saveAll on five modules, three new entities each, by each store's witness
#   seven      the comparison set on after/'s jar (H2, 20640) - before/ is the same tree, so one run
#   verify     mvn verify on .harness/tests = after/ + harness/it-bindings.patch (five test files: the three older ITs bound to
#              127.0.0.1, every IT printing its own container's bindings) - the tests' counts and the five IT BINDINGS lines
# Every tree is COPIED under .harness/ and built there, offline (-o, from .m2-demo, a copy of the course's seed, maven.repo.local
# absolute), -pl tiffinbox-web -am (R.391). Every JVM and Maven run under an alarm (R.247), every JVM with SIGINT reset to its default
# (R.410). Every docker call names its socket (dk, R.344), --pull never; every container is removed with its volumes (rm -fv, R.387) and
# the volume count asserted back. No harness JVM is polled while it runs: the receipt starts it and waits for its exit (R.412).
# Ports (20640-20649): 20640 TiffinBox (24/after under dev, the harness joined; the seven's default run) · 20641 PostgreSQL c8u25-pg ·
# 20642 Redis c8u25-redis · 20643 MongoDB c8u25-mongo (a standalone) · 20644 Elasticsearch c8u25-es · 20645 the exercise's TiffinBox ·
# 20646-20648 spare (asserted free) · 20649 never bound. During mvn verify only: Testcontainers' own containers on 127.0.0.1:<random>,
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
CN=c8u25-pg; RN=c8u25-redis; MN=c8u25-mongo; EN=c8u25-es; XC="c8u25-ex-pg c8u25-ex-redis c8u25-ex-mongo c8u25-ex-es"
ESSET="-e discovery.type=single-node -e xpack.security.enabled=false -e xpack.ml.enabled=false -e ingest.geoip.downloader.enabled=false -e xpack.inference.elastic.authorization.enabled=false"
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
pid=""; mpid=""; xpid=""; monp=""; TC0=""; INTR=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.u25.") || index($0, "lab25.Lab25") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "curlset.sh") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "redis-cli MONITOR") || $3 ~ /(^|\/)javac$/ || index($0, "ex-drive")) { print $1 }' | paste -sd' ' -) || l=""
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
trap 'trap "" INT TERM; for p in "$monp" "$mpid" "$xpid" "$pid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid" "$monp"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; tcrm; ctrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff patch find curl openssl docker git unzip javap /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|FLYWAY_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|REDIS[A-Z_]*|MONGO[A-Z_]*|ES_[A-Z_]*|ELASTIC[A-Z_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT|COMPOSE_[A-Z_]*)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"

# ---- gates before anything is written: the folder, the links, the pin, the prose, the exercise ------------------------------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk25.py dur8.py it-bindings.patch logback.xml s825.py src tree25.py' ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe/u25/H25.java probe/u25/K25.java' ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'KitchenOrder.java Lab25.java README.md SOLUTION.md check.sh' ] || die "exercise/ holds another file, or misses one"
cmp -s harness/dur8.py ../c8-unit02/harness/dur8.py || die "harness/dur8.py is not the builders' dur8.py as unit 02 shipped it, byte for byte"
cmp -s harness/logback.xml ../c8-unit07/harness/logback.xml || die "harness/logback.xml is not unit 07's, byte for byte"
for t in before after; do [ -L $t ] && [ "$(readlink $t)" = ../c8-unit24/after ] || die "R.250: $t must be a link to ../c8-unit24/after (it points at: $(readlink $t 2> /dev/null || echo 'not a link'))"; done
[ -d ../c8-unit24/after ] && [ ! -L ../c8-unit24/after ] || die "unit 24's after/ must be its own tree"
for t in after; do [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] && die "$t holds a secrets/ or a target/ - never built in place"; true; done
git rev-parse -q --verify 'ad1220b^{commit}' > /dev/null 2>&1 || die "unit 24's commit ad1220b is not in this repository's history"
U24P=$(awk '$1 == "after-tree" { print $2, $3 }' ../c8-unit24/receipts.md5)
[ -n "$U24P" ] || die "../c8-unit24/receipts.md5 has no after-tree line"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree25.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  [ "$want" = "$U24P" ] || die "R.250: receipts.md5's $nm line ($want) is not ../c8-unit24/receipts.md5's after-tree line ($U24P)"
  echo "  $dir/ ($3): python3 -I harness/tree25.py $dir/ -> $got = receipts.md5's $nm line = ../c8-unit24/receipts.md5's after-tree line"; }
pin before-tree before start; pin after-tree after start
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c8-tiffinbox 2>&1 || true)
[ -z "$AD" ] || die "flag 3: ../c8-tiffinbox is not ../c8-unit24/after (diff -rq: $(printf '%s\n' "$AD" | head -2 | paste -sd';' -)) - this unit changes no anchor file"
echo "  after/ against ../c8-tiffinbox (diff -rq, .m2-demo target secrets .harness left out): empty - the anchor is unit 24's tree, unchanged (flag 3)"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s825.py harness/dur8.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -2 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S5 12 families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
DN=$($G -rniwE -- "$DISH" README.md exercise harness/src 2> /dev/null | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|VALUES-PENDING|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
! $G -q '^```java$' README.md || die "README.md holds a java block - the code is the harness's files and the exercise's"
GLOSS="The Commons layer: the interfaces, the method-name parser and the factory key that TiffinBox's five Spring Data modules share."
[ "$($G -cxF -- "$GLOSS" README.md)" = 1 ] || die "the gloss (SECTION SHAPE 25) must stand in README.md once, as a line of its own, byte for byte"
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
EXQ="Your turn: the harness's Redis repository finds zero orders worth two hundred forty, and MongoDB finds thirty. Make Redis find the thirty."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SETUP=$(block exercise/README.md); SOL=$(block exercise/SOLUTION.md)
[ -n "$SETUP" ] && [ -n "$SOL" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
[ "$(diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G -c '^[<>]')" = 2 ] || die "R.196: SOLUTION.md's block must be the README's with one line changed"
[ "$(printf '%s\n' "$SETUP" | $G -cxF 'cp exercise/KitchenOrder.java "$EX/KitchenOrder.java"')" = 1 ] && [ "$(printf '%s\n' "$SETUP" | $G -cxF 'cp exercise/Lab25.java "$EX/Lab25.java"')" = 1 ] || die "R.196: the README's block copies KitchenOrder and Lab25 as shipped"
NAMEP=$(printf '%s\n' "$SETUP" | sed 's#^cp exercise/Lab25.java "$EX/Lab25.java"$#perl -pe '"'"'s/findByValue\\(int value\\)/findByCustomer(String value)/; s/repo\\.findByValue\\(v\\)/repo.findByCustomer("Ravi")/'"'"' exercise/Lab25.java > "$EX/Lab25.java"#')
NUMP=$(printf '%s\n' "$SOL" | sed 's#^cp exercise/Lab25.java "$EX/Lab25.java"$#perl -pe '"'"'s/int v = 240;/int v = 480;/'"'"' exercise/Lab25.java > "$EX/Lab25.java"#')
[ "$(diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$NAMEP") | $G -c '^[<>]')" = 2 ] && [ "$(diff <(printf '%s\n' "$SOL") <(printf '%s\n' "$NUMP") | $G -c '^[<>]')" = 2 ] || die "the two wrong \"solutions\" must each be a block with one line changed"
printf '%s\n' "$SETUP" | $G -E '(^|[ (])(mvn|java|javac) ' | $G -vqF "perl -e '" && die "exercise/README.md's Java and Maven runs must run under their alarm (R.247)"
printf '%s\n' "$SETUP" | $G -E 'mvn ' | $G -vqF -- '-pl tiffinbox-web -am' && die "R.391: exercise/README.md builds without -pl tiffinbox-web -am"
printf '%s\n' "$SETUP" | $G -E '(^|[ ;&(])docker ' | $G -vqF 'docker -H "$DH" ' && die "R.344: exercise/README.md calls docker without its socket (docker -H \"\$DH\")"
printf '%s\n' "$SETUP" | $G -qxF "docker -H \"\$DH\" rm -fv $XC > /dev/null" || die "R.387: the exercise's four containers are removed with their volumes (rm -fv)"
printf '%s\n' "$SETUP" | $G -E 'docker -H "\$DH" run .*mongo:8' | $G -qF "GLIBC_TUNABLES=$GT" || die "R.421: the exercise's MongoDB runs with GLIBC_TUNABLES"
printf '%s\n' "$SETUP" | $G -E 'docker -H "\$DH" run .*elasticsearch:9\.4\.8' | $G -qF -- "$ESSET -e \"ES_JAVA_OPTS=-Xms512m -Xmx512m\"" || die "R.437: the exercise's Elasticsearch runs with the six settings"
printf '%s\n' "$SETUP" | $G -qxF 'bash exercise/check.sh "$EX/run.log"' || die "R.196: the exercise is checked by exercise/check.sh (the lab's line and redis-cli SCARD), never by the exit"
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
cmp -s exercise/KitchenOrder.java after/tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenOrder.java || die "exercise/KitchenOrder.java must be after/'s KitchenOrder.java, byte for byte (the broken copy)"
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
! $G -rqE '@Enable[A-Za-z]*Repositories' harness/src exercise || die "S8.101: an @Enable...Repositories in the harness or the exercise - it would switch Boot's scan off"
ST=$(python3 -I -B harness/chk25.py static after) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
echo "  prose, per sentence (s825, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test, XFAM_S5's 12 families among them): refused 0 over $PROSE · dish names 0 · placeholders 0 · no java block · the gloss once, byte for byte"
echo "  the exercise: the spoken line $EXW words (wc -w); SOLUTION.md's block = the README's with one line changed; each wrong \"solution\" = a block with one other line changed; the two \"What it prints\" blocks differ (R.196); checked by exercise/check.sh, never the exit; its containers on 127.0.0.1:20641-20644, removed with their volumes; its MongoDB with GLIBC_TUNABLES, its Elasticsearch with the six settings; its build -pl tiffinbox-web -am; its docker calls on the socket"
echo "  static: no kill by name; every docker call on the pinned socket, every dk run --pull never, every MongoDB container with GLIBC_TUNABLES and every Elasticsearch container with the six settings; no exec into a container but cat of a /proc file and the stores' own clients; no port on every interface (S8.94); every removal dk rm -fv (R.387); every Maven build -pl tiffinbox-web -am (R.391); no @Enable...Repositories in the harness or the exercise (S8.101)"
mask() { awk -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
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
PORTS="18881 18882 18883 18884 20578 20615 20640 20641 20642 20643 20644 20645 20646 20647 20648 20649"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
[ "$(pgrep -x java | wc -l | tr -d ' ')" = 0 ] || die "a java process is running before this script starts one - not this script's; stop it first"
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · the four digests present ($IMG, $RIMG, $MIMG, $EIMG) · mongo:8, postgres:18-alpine, redis:8-alpine and $ETAG on those digests · nothing pulled, ever · images named ryuk $RY0 · Testcontainers containers 0 · ports 20640-20649, 20578, 20615, 18881-18884 free · java processes 0"

# ---- the tree, copied; the build; the tests' copy; the harness, compiled ---------------------------------------------------------
rm -rf .harness; mkdir -p .harness/run-dev/secrets/tiffinbox .harness/run-h2/secrets/tiffinbox .harness/home
M2="$PWD/.m2-demo"
[ -d "$M2" ] || die ".m2-demo (a copy of the course's seed, _research/m2-seed-c8-s4b) is missing - README.md, The repository"
NF0=$(find "$M2" -type f | wc -l | tr -d ' ')
echo "  .m2-demo's files $NF0 (the seed's 7,265 - no new artifact: this unit adds no dependency)"
printf '%s\n' 'checks.disable=true' "tinyimage.container.image=$IMG" > .harness/home/.testcontainers.properties
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy after .harness/after; copy after .harness/tests
(cd .harness/tests && patch -s -p1 < ../../harness/it-bindings.patch) || die "harness/it-bindings.patch did not apply to the tests' copy"
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE '^\[INFO\] Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 900; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
AL="-DargLine=$JL -Dstdout.encoding=UTF-8 -Duser.home=../../home"
bg "cd .harness/after && $MV clean package -DskipTests -pl tiffinbox-web -am" .harness/build-after.log
[ "$RE" = 0 ] || { tail -20 .harness/build-after.log >&3; die ".harness/after did not build offline (exit $RE)"; }; offl .harness/build-after.log
bg "cd .harness/after && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-after.log
[ "$RE" = 0 ] || die ".harness/after: the jar's extract failed"
CPJ="../after/$XD/tiffinbox-web-1.0.0.jar:../after/$XD/lib/*"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*\" harness/src/probe/u25/H25.java harness/src/probe/u25/K25.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/'s jar: $(head -5 .harness/javac.log)"
TF=secrets/tiffinbox/shutdown-token
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/run-h2/$TF && cp .harness/run-h2/$TF .harness/run-dev/$TF) || die "the token was not written"
mkdir -p .harness/after/secrets/tiffinbox && (umask 077 && cp .harness/run-h2/$TF .harness/after/$TF) || die "the token was not copied"
TOKEN=$(head -1 .harness/run-h2/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
echo "  built after/'s tree offline (mvn -o package -DskipTests -pl tiffinbox-web -am, exit 0, 'Downloaded from' 0) and extracted its jar (BOOT-INF/lib $(ls .harness/after/$XD/lib | wc -l | tr -d ' ') jars); compiled the harness (harness/src/probe/u25/H25.java and K25.java, javac 25 -cp \"<after/'s jar>:<its lib/*>\" - compiled, not source-launched, $(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes); the tests' copy .harness/tests = after/ + harness/it-bindings.patch; a shutdown token generated (0600, never printed)"

# ---- helpers -------------------------------------------------------------------------------------------------------------------
vols() { dk volume ls -q 2> /dev/null | wc -l | tr -d ' '; }
pgready() { local i=0; while ! dk exec "$1" pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 240 ] || die "PostgreSQL ($1) did not accept connections (240 tries)"; sleep 0.5; done; }
psq() { dk exec "$CN" psql -U tiffinbox -d "$1" -qAt -v ON_ERROR_STOP=1 -c "$2" 2>&1 || die "psql failed on $CN/$1: $2"; }
ms() { dk exec "$MN" mongosh --quiet 'mongodb://127.0.0.1:27017/tiffinbox' --eval "$1" 2>&1 | tail -1; }
rc() { dk exec "$RN" redis-cli "$@" 2>&1 | tr -d '\r'; }
eq() { curl -s --noproxy '*' -X "$1" "http://127.0.0.1:20644$2" 2> /dev/null; }
esup() { local i=0 c; while :; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:20644/_cluster/health" 2> /dev/null || true); [ "$c" = 200 ] && break
    i=$((i + 1)); [ $i -lt 960 ] || die "Elasticsearch on 20644 did not answer _cluster/health 200 (960 reads)"; sleep 0.25; done; }
mkmongo() { local i=0
  bg "dk run -d --pull never --name $MN -p 127.0.0.1:20643:27017 -e GLIBC_TUNABLES=$GT $MIMG --unixSocketPrefix /data/db" .harness/docker-run-mongo.log
  [ "$RE" = 0 ] || die "the MongoDB container did not start: $(tail -2 .harness/docker-run-mongo.log)"
  while [ "$(ms 'print(db.runCommand({ping: 1}).ok)')" != 1 ]; do i=$((i + 1)); [ $i -lt 240 ] || die "MongoDB did not answer mongosh's ping (240 reads)"; sleep 0.25; done
  [ "$(dk port $MN | paste -sd'|' -)" = '27017/tcp -> 127.0.0.1:20643' ] || die "$MN publishes on another address than 127.0.0.1:20643"; }
stores() {
  echo "\$ docker -H \"\$DH\" run -d --pull never --name $CN -p 127.0.0.1:20641:5432 -e POSTGRES_DB=tiffinbox -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust $IMG -c log_statement=all"
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:20641:5432 -e POSTGRES_DB=tiffinbox -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust $IMG -c log_statement=all" .harness/docker-run-pg.log
  [ "$RE" = 0 ] || die "the PostgreSQL container did not start: $(tail -2 .harness/docker-run-pg.log)"
  echo "\$ docker -H \"\$DH\" run -d --pull never --name $RN -p 127.0.0.1:20642:6379 $RIMG"
  bg "dk run -d --pull never --name $RN -p 127.0.0.1:20642:6379 $RIMG" .harness/docker-run-redis.log
  [ "$RE" = 0 ] || die "the Redis container did not start: $(tail -2 .harness/docker-run-redis.log)"
  echo "\$ docker -H \"\$DH\" run -d --pull never --name $MN -p 127.0.0.1:20643:27017 -e GLIBC_TUNABLES=$GT $MIMG --unixSocketPrefix /data/db   (a fresh one before every harness JVM)"
  echo "\$ docker -H \"\$DH\" run -d --pull never --name $EN --hostname $EN -p 127.0.0.1:20644:9200 $ESSET -e \"ES_JAVA_OPTS=-Xms512m -Xmx512m\" $EIMG"
  bg "dk run -d --pull never --name $EN --hostname $EN -p 127.0.0.1:20644:9200 $ESSET -e \"ES_JAVA_OPTS=-Xms512m -Xmx512m\" $EIMG" .harness/docker-run-es.log
  [ "$RE" = 0 ] || die "the Elasticsearch container did not start: $(tail -2 .harness/docker-run-es.log)"
  pgready $CN; esup
  local i=0; while [ "$(rc PING)" != PONG ]; do i=$((i + 1)); [ $i -lt 200 ] || die "Redis did not answer PING"; sleep 0.1; done
  [ "$(dk port $CN | paste -sd'|' -)" = '5432/tcp -> 127.0.0.1:20641' ] && [ "$(dk port $RN | paste -sd'|' -)" = '6379/tcp -> 127.0.0.1:20642' ] && [ "$(dk port $EN | paste -sd'|' -)" = '9200/tcp -> 127.0.0.1:20644' ] || die "a store publishes on another address than 127.0.0.1:<its port>"
  echo "  the unit's stores: $CN (PostgreSQL $(psq tiffinbox 'show server_version'), log_statement $(psq tiffinbox 'show log_statement')), $RN ($(rc INFO server | $G '^redis_version:')), $EN (version.number $(eq GET / | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["version"]["number"])'), 9300 not published), each on 127.0.0.1 alone (dk port); volumes now $(vols) (the machine's $VOL0 + PostgreSQL's one)"
  echo "  $EN's environment, the six (dk inspect): $(dk inspect -f '{{json .Config.Env}}' $EN | python3 -I -c 'import json,sys; print(" · ".join(sorted(e for e in json.load(sys.stdin) if e.split("=")[0] in ("discovery.type","xpack.security.enabled","xpack.ml.enabled","ingest.geoip.downloader.enabled","xpack.inference.elastic.authorization.enabled","ES_JAVA_OPTS"))))')"; }
# fresh: before every harness JVM - a new tiffinbox database, Redis emptied, a new MongoDB container, the dishes index gone; the stores'
# own answers printed
fresh() { local v
  psq postgres "drop database if exists tiffinbox with (force)" > /dev/null; psq postgres "create database tiffinbox" > /dev/null
  [ "$(rc FLUSHALL)" = OK ] || die "redis-cli FLUSHALL failed"
  [ -z "$(dk ps -aq --filter name=^/$MN\$)" ] || dk rm -fv $MN > /dev/null 2>&1 || die "the MongoDB container could not be removed"
  mkmongo
  v=$(eq DELETE /dishes | python3 -I -c 'import json,sys; d=json.load(sys.stdin); print("acknowledged" if d.get("acknowledged") else d.get("error", {}).get("type", "?"))')
  echo "  fresh stores: database tiffinbox dropped and created (psql) · redis-cli FLUSHALL OK · DBSIZE $(rc DBSIZE) · a new $MN (mongosh ping 1, db.orders.countDocuments() $(ms 'print(db.orders.countDocuments())')) · DELETE /dishes -> $v"; }
# h25 MODE DIR: TiffinBox under dev on the unit's four stores, the harness joined, from .harness/run-dev, under its alarm; no readiness
# polling while it runs - the receipt waits for its exit. MONITOR on Redis around it; PostgreSQL's log lines it caused, sliced after.
DEV="--spring.profiles.active=dev --spring.docker.compose.enabled=false --tiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:20641/tiffinbox?user=tiffinbox --spring.datasource.username=tiffinbox --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20642 --spring.mongodb.uri=mongodb://127.0.0.1:20643/tiffinbox --spring.elasticsearch.uris=http://127.0.0.1:20644"
TRL=--logging.level.co.elastic.clients.transport.rest5_client.low_level.Request=TRACE
h25() { local mode=$1 o=$2 e=0 p0
  mkdir -p "$o"
  p0=$(dk logs $CN 2>&1 | wc -l | tr -d ' ')
  dk exec $RN redis-cli MONITOR > "$o/monitor.txt" 2>&1 < /dev/null & monp=$!
  local i=0; while ! $G -q '^OK' "$o/monitor.txt" 2> /dev/null; do i=$((i + 1)); [ $i -lt 200 ] || die "redis-cli MONITOR did not answer OK"; sleep 0.05; done
  (cd .harness/run-dev && exec perl -e '$SIG{INT}="DEFAULT"; alarm 300; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -Duser.home=../home -cp "../hc:$CPJ" com.tiffinbox.web.TiffinBoxServer --logging.config=../../harness/logback.xml --tiffinbox.port=20640 $DEV --spring.main.sources=probe.u25.H25 --h25.mode=$mode $TRL) > "$o/jvm.log" 2>&1 < /dev/null & pid=$!
  wait "$pid" || e=$?; pid=""
  kill "$monp" 2> /dev/null; wait "$monp" 2> /dev/null || true; monp=""
  dk logs $CN 2>&1 | sed -n "$((p0 + 1)),\$p" > "$o/pg.log"
  echo "$e" > "$o/exit"; }
H25CL="\$ cd .harness/run-dev && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 300; exec @ARGV' java $JL -cp \"../hc:<after/'s jar>:<its lib/*>\" com.tiffinbox.web.TiffinBoxServer --logging.config=../../harness/logback.xml --tiffinbox.port=20640 --spring.profiles.active=dev --spring.docker.compose.enabled=false <the four stores' addresses by property, 127.0.0.1:20641-20644> --spring.main.sources=probe.u25.H25 --h25.mode="
NCAP=3
unpub=""; CAPRUN=0; CAPNM=""
cap() { local nm=$1 i n=$NCAP; shift
  i=1; while [ $i -le $n ]; do CAPRUN=$i; CAPNM=$nm; "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid$monp" ] || die "$nm left a process running"
    $G -q '^  \*\*\* ' .harness/cap.raw && { cat .harness/cap.raw >&3; die "$nm stopped (above)"; }
    ! $G -qE 'localhost:[0-9]{5}|127\.0\.0\.1:(3|4|5|6)[0-9]{4}' .harness/cap.raw || die "R.319: $nm printed a container's port raw"
    mask < .harness/cap.raw > ".r-$nm.$i"; cp .harness/cap.raw ".harness/raw-$nm.$i"; i=$((i + 1)); done
  CHH=$(md5 -q ".r-$nm.1")
  i=2; while [ $i -le $n ]; do [ "$CHH" = "$(md5 -q ".r-$nm.$i")" ] || die "$nm drifts across $n runs (diff .r-$nm.1 .r-$nm.$i)"; i=$((i + 1)); done
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; CAPN=$n; }
pub() { local nm=$1 h p; h=$(md5 -q ".r-$nm.out"); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-10s md5 %s  %s/%s  (no published hash)\n' "$nm" "$h" "$CAPN" "$CAPN"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-10s md5 %s  %s/%s  = published\n' "$nm" "$h" "$CAPN" "$CAPN"
  else printf '  %-10s md5 %s  %s/%s  DIFFERS from the published %s\n' "$nm" "$h" "$CAPN" "$CAPN" "$p"; die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
VALS=""
chk() { local nm=$1 o e=0; shift
  o=$(python3 -I -B harness/chk25.py "$nm" "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk25 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -5 >&3; die "$nm: its check failed (harness/chk25.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }

# ---- the captures --------------------------------------------------------------------------------------------------------------
B=.m2-demo/org/springframework/data   # relative: this folder's path may hold a space (the sealed clone's does)
JCM=$B/spring-data-commons/4.1.2/spring-data-commons-4.1.2.jar; JJPA=$B/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar
JJDBC=$B/spring-data-jdbc/4.1.2/spring-data-jdbc-4.1.2.jar; JREL=$B/spring-data-relational/4.1.2/spring-data-relational-4.1.2.jar
JRED=$B/spring-data-redis/4.1.2/spring-data-redis-4.1.2.jar; JKV=$B/spring-data-keyvalue/4.1.2/spring-data-keyvalue-4.1.2.jar
JMON=$B/spring-data-mongodb/5.1.2/spring-data-mongodb-5.1.2.jar; JES=$B/spring-data-elasticsearch/6.1.2/spring-data-elasticsearch-6.1.2.jar
jars() { local j c
  echo "-- jars: the eight Spring Data jars, by path under .m2-demo (the seed's copy), each with its size and md5:"
  for j in $JCM $JJPA $JJDBC $JREL $JRED $JKV $JMON $JES; do printf '  %s %s B md5 %s\n' "$j" "$(stat -f %z $j)" "$(md5 -q $j)"; done
  echo "  the same jars in after/'s BOOT-INF/lib, md5 equal to the seed's: $(for j in $JCM $JJPA $JJDBC $JREL $JRED $JKV $JMON $JES; do [ "$(md5 -q $j)" = "$(md5 -q .harness/after/$XD/lib/$(basename $j))" ] && printf 'y' || printf 'n'; done)"
  echo "== Commons' repository interfaces (javap -p -cp spring-data-commons-4.1.2.jar):"
  for c in Repository CrudRepository ListCrudRepository PagingAndSortingRepository ListPagingAndSortingRepository query.QueryByExampleExecutor; do
    echo "-- org.springframework.data.repository.$c"; javap -p -cp $JCM org.springframework.data.repository.$c | $G -v '^Compiled from' | sed 's/^/   /'; done
  echo "== each module's own repository interface (javap -p, the module's jar + Commons'):"
  echo "-- spring-data-jpa-4.1.2.jar"; javap -p -cp $JJPA:$JCM org.springframework.data.jpa.repository.JpaRepository | $G -v '^Compiled from' | sed 's/^/   /'
  echo "-- spring-data-mongodb-5.1.2.jar"; javap -p -cp $JMON:$JCM org.springframework.data.mongodb.repository.MongoRepository | $G -v '^Compiled from' | sed 's/^/   /'
  echo "-- spring-data-elasticsearch-6.1.2.jar"; javap -p -cp $JES:$JCM org.springframework.data.elasticsearch.repository.ElasticsearchRepository | $G -v '^Compiled from' | sed 's/^/   /'
  echo "-- spring-data-keyvalue-4.1.2.jar (Spring Data Redis's repositories' base)"; javap -p -cp $JKV:$JCM org.springframework.data.keyvalue.repository.KeyValueRepository | $G -v '^Compiled from' | sed 's/^/   /'
  echo "== TiffinBox's six repository interfaces, their extends lines (grep -n, after/'s sources):"
  for f in tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntityRepository.java tiffinbox-core/src/main/java/com/tiffinbox/DishEntityRepository.java tiffinbox-core/src/main/java/com/tiffinbox/jdbc/CustomerAggregates.java tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenOrders.java tiffinbox-web/src/main/java/com/tiffinbox/web/OrderDocuments.java tiffinbox-web/src/main/java/com/tiffinbox/web/Dishes.java; do
    printf '  %s:%s\n' "${f##*/}" "$($G -nE '^public interface .* extends ' after/$f | sed 's/ {$//')"; done
  echo "== META-INF/spring.factories, the key org.springframework.data.repository.core.support.RepositoryFactorySupport (unzip -p), each jar:"
  for j in $JCM $JJPA $JJDBC $JREL $JRED $JKV $JMON $JES; do printf '  %-40s %s\n' "$(basename $j)" "$(v=$(unzip -p $j META-INF/spring.factories 2> /dev/null | $G '^org.springframework.data.repository.core.support.RepositoryFactorySupport=' | cut -d= -f2); echo "${v:-none}")"; done
  echo "== each module's query creator, its class line (javap):"
  javap -cp $JJPA:$JCM org.springframework.data.jpa.repository.query.JpaQueryCreator 2> /dev/null | $G -m1 'class ' | sed 's/^/  /'
  javap -cp $JREL:$JCM org.springframework.data.relational.repository.query.RelationalQueryCreator 2> /dev/null | $G -m1 'class ' | sed 's/^/  /'
  javap -cp $JRED:$JKV:$JCM org.springframework.data.redis.repository.query.RedisQueryCreator 2> /dev/null | $G -m1 'class ' | sed 's/^/  /'
  javap -cp $JMON:$JCM org.springframework.data.mongodb.repository.query.MongoQueryCreator 2> /dev/null | $G -m1 'class ' | sed 's/^/  /'
  javap -cp $JES:$JCM org.springframework.data.elasticsearch.repository.query.parser.ElasticsearchQueryCreator 2> /dev/null | $G -m1 'class ' | sed 's/^/  /'
  echo "== Commons' domain types (unzip -l spring-data-commons-4.1.2.jar org/springframework/data/domain/):"
  unzip -l $JCM | awk '{ print $4 }' | $G -E '^org/springframework/data/domain/(Window|ScrollPosition|KeysetScrollPosition|OffsetScrollPosition|Page|Slice|Sort|Pageable|PageRequest|Example)\.class$' | sed 's/^/  /'
  echo "== Redis's refusal, the string in RedisQueryCreator.class (unzip -p | strings): $(unzip -p $JRED org/springframework/data/redis/repository/query/RedisQueryCreator.class | strings | $G 'not supported for Redis query derivation')"
  echo "== Boot's Docker Compose support, skip.in-tests (.m2-demo's spring-boot-docker-compose-4.1.2.jar, its metadata - the jar is not in after/'s BOOT-INF/lib): $(unzip -p .m2-demo/org/springframework/boot/spring-boot-docker-compose/4.1.2/spring-boot-docker-compose-4.1.2.jar META-INF/spring-configuration-metadata.json | python3 -I -c 'import json,sys; d=json.load(sys.stdin); print(" · ".join(p["name"] + " default " + str(p.get("defaultValue")).lower() for p in d.get("properties", []) if p["name"] == "spring.docker.compose.skip.in-tests"))')"; }
# the facts JVMs: run three times before the four captures that read them (hierarchy, parse, strict, types)
facts_runs() { local n
  for n in 1 2 3; do fresh > .harness/fresh-facts-$n.txt; h25 facts .harness/facts-$n
    [ "$(cat .harness/facts-$n/exit)" = 0 ] || { tail -20 .harness/facts-$n/jvm.log | mask >&3; die "the harness's facts run $n did not exit 0"; }; done; }
hierarchy() { local F=.harness/facts-$CAPRUN
  echo "-- hierarchy: TiffinBox (after/) under dev on the unit's four stores, the harness joined (facts); the JVM's exit $(cat $F/exit)"
  echo "${H25CL}facts"
  $G -E "^the harness's (repositories|REPO |  chain |  query methods |  composition's )" $F/jvm.log
  echo "  who names each in src/main and in src/test (harness/chk25.py inject: after/'s Java, comments stripped, the repository's own file left out):"
  python3 -I -B harness/chk25.py inject after; }
parse() { local F=.harness/facts-$CAPRUN
  echo "-- parse: Commons' PartTree on each query method's name (the harness, facts), and on findByMealType for all six domain types:"
  $G -E "^the harness's (  PartTree|PARSE )" $F/jvm.log
  echo "-- each shipped derived method, called once between its own markers; the store's witness for the window (PostgreSQL's log - non-empty statements, the markers left out, the raw count beside; Redis's MONITOR - the markers left out; MongoDB's profiler; the Elasticsearch client's trace):"
  python3 -I -B harness/chk25.py windows $F jpa-findByName jdbc-findByName redis-findByMealType redis-findByCustomerAndMealType mongo-findByMealType es-findByName
  $G -E "^the harness's (CALL |  the profiler )" $F/jvm.log; }
strict() { local F=.harness/facts-$CAPRUN
  echo "-- strict: the start's repository lines (facts), whole, as printed, each counted (the logger's prefix cut):"
  $G -E 'Multiple Spring Data modules found|Could not safely identify store assignment|Finished Spring Data repository scanning|Bootstrapping Spring Data' $F/jvm.log | sed -E 's/^[A-Z]+ +\[[^]]*\] [^ ]+ : //' | mask | sort | uniq -c | sed -E 's/^ +([0-9]+) /  (x\1) /'; }
types() { local F=.harness/facts-$CAPRUN
  echo "-- types: Commons' shared types (the harness, facts):"
  $G -E "^the harness's TYPES " $F/jvm.log
  python3 -I -B harness/chk25.py windows $F keyset-jpa; }
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
hole_runs() { local n o
  for n in 1 2 3; do o=.harness/hole-$n; fresh > .harness/fresh-hole-$n.txt; h25 hole $o
    [ "$(cat $o/exit)" = 0 ] || { tail -20 $o/jvm.log | mask >&3; die "the harness's hole run $n did not exit 0"; }
    { echo "  the stores' own tools after the JVM is gone:"
      echo "    redis-cli EXISTS kitchen-order:value:240 -> $(rc EXISTS kitchen-order:value:240) · SCARD kitchen-order:value:240 -> $(rc SCARD kitchen-order:value:240) · SCARD kitchen-order:mealType:VEG -> $(rc SCARD kitchen-order:mealType:VEG) · SCARD kitchen-order -> $(rc SCARD kitchen-order)"
      echo "    redis-cli KEYS 'kitchen-order:*:*' (the per-order :idx sets left out) -> $(rc KEYS 'kitchen-order:*:*' | $G -v ':idx$' | sort | paste -sd' ' -)"
      echo "    mongosh: db.orders.countDocuments() -> $(ms 'print(db.orders.countDocuments())') · countDocuments({value: 240}) -> $(ms 'print(db.orders.countDocuments({value: 240}))') · countDocuments({value: {\$gt: 200}}) -> $(ms 'print(db.orders.countDocuments({value: {$gt: 200}}))')"
      echo "  $EN's sockets at the end of the window (S8.92), its /proc/net/tcp, tcp6, udp and udp6 read by cat (dk exec - a file, never a shell):"
      echo "    its interfaces (/proc/net/dev): $(dk exec $EN cat /proc/net/dev | sed 1,2d | cut -d: -f1 | tr -d ' ' | sort | paste -sd',' -)"
      for t in tcp tcp6 udp udp6; do dk exec $EN cat /proc/net/$t > $o/net-$t.txt 2> /dev/null || : > $o/net-$t.txt; done
      echo "    the sockets: $(python3 -I -c "$SOCKPY" $o/net-tcp.txt $o/net-tcp6.txt $o/net-udp.txt $o/net-udp6.txt)"; } > $o/witness.txt; done; }
HOLEW="RValue RValueGt RTypo RNot RIn RStart RIgnore ROrder RCount RExists RFirst ROr MValue MValueGt MNot MStart"
hole() { local F=.harness/hole-$CAPRUN w ws=""
  echo "-- hole: one name on two modules - the harness's repositories, built by Spring Data Redis's and Spring Data MongoDB's own factories over TiffinBox's 120 kitchen orders (the JVM's exit $(cat $F/exit)):"
  echo "${H25CL}hole"
  $G -E "^the harness's (Spring Data Redis's factory|HOLE |  the profiler |Redis index sets)" $F/jvm.log
  echo "  each call's own window (a marker before it and after it), the commands Redis's MONITOR saw in it, the markers left out:"
  for w in $HOLEW; do case $w in R*) ws="$ws call-redis-$w" ;; M*) ws="$ws call-mongo-$w" ;; esac; done
  python3 -I -B harness/chk25.py windows $F $ws
  cat $F/witness.txt; }
saveall() { local F=.harness/saveall-1
  fresh > .harness/fresh-saveall.txt; h25 saveall $F
  [ "$(cat $F/exit)" = 0 ] || { tail -20 $F/jvm.log | mask >&3; die "the harness's saveall run did not exit 0"; }
  echo "-- saveall: Commons' saveAll, three new entities per module (the harness's ids and names, removed after; the stores are fresh before every harness JVM anyway):"
  echo "${H25CL}saveall"
  python3 -I -B harness/chk25.py windows $F saveall-jpa saveall-jdbc saveall-redis saveall-mongo-repository saveall-mongo-template saveall-es
  $G -E "^the harness's (  the profiler |MongoDB documents|saveall done)" $F/jvm.log; }
seven() { local i=0 e=0 c a port=20640
  echo "-- the seven: after/'s jar, java -jar, H2 in memory (a fresh JVM), port $port - before/ is the same tree (one link target), so it runs once:"
  echo "\$ cd .harness/after && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port"
  (cd .harness/after && DOCKER_HOST=tcp://127.0.0.1:1 exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port) > .harness/seven-run.log 2>&1 < /dev/null & pid=$!
  while [ $i -lt 480 ]; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/seven-run.log | mask >&3; die "TiffinBox exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $port"
  a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
  echo "  GET /actuator/health/readiness -> 200 · listens on: $a"
  echo "\$ \$CURLSET $port .harness/after/$TF"
  "$CURLSET" $port .harness/after/$TF | $G ' -> ' | awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' > .harness/seven-after.txt || true
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 480 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && die "TiffinBox on $port was still running after POST /shutdown"
  wait "$pid" || e=$?; pid=""
  [ "$(listeners $port)" = 0 ] || die "something still listens on $port"
  echo "  exit $e · the seven responses: $(wc -l < .harness/seven-after.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven-after.txt) · listening on $port now: 0"
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
# the ITs' containers while mvn verify runs: Docker's own list of each, polled on a count (R.412), and 18881-18884 polled free
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
exsh() { local sh=$1 e1 d1 e2 d2 v1 i=0
  rm -rf .harness/ex; rm -f .harness/ex-*.st .harness/ex-*.out
  v1=$(vols)
  printf '%s\n' 'cd "$1" || exit 1' '. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-readme.st"' 'cd "$1" || exit 1' '. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-sol.st"' > .harness/ex-drive.sh
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 4800 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after its cap"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines, the block's exit $e1:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "  then the solution's lines, in the same shell - the block's exit $e2:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · listening on 20641-20645 afterwards: $(( $(listeners 20641) + $(listeners 20642) + $(listeners 20643) + $(listeners 20644) + $(listeners 20645) )) · the exercise's containers afterwards: $(dk ps -aq --filter name=^/c8u25-ex- | $G -c . || true) · volumes $(vols) (before the shell: $v1) · java processes of the exercise: $(ps -axo command= | $G -c '[l]ab25.Lab25' || true) · images afterwards: the same list $( [ "$(dk images -q --no-trunc 2> /dev/null | sort -u | paste -sd' ' -)" = "$IMGS0" ] && echo yes || echo no)"; }
exercise() { local e d k
  printf '%s\n' "$SETUP" > .harness/ex-readme.sh; printf '%s\n' "$SOL" > .harness/ex-sol.sh; printf '%s\n' "$NAMEP" > .harness/ex-name.sh; printf '%s\n' "$NUMP" > .harness/ex-num.sh
  echo "exercise/README.md's $(printf '%s\n' "$SETUP" | $G -c .) lines, then exercise/SOLUTION.md's, as written, one after the other in ONE env -i shell (HOME and the PATH this script was started with), started in this folder:"
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh
  for k in name num; do
    case $k in name) echo "a wrong \"solution\" - another method's name (the README's block, the lab's call renamed to findByCustomer(\"Ravi\"), which finds thirty), in a fresh env -i bash, through exercise/check.sh:"; diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$NAMEP") | $G '^>' | sed 's/^> /  $ /' ;;
               num) echo "a wrong \"solution\" - another number (SOLUTION.md's block, the lab's number 480), in a fresh env -i bash, through exercise/check.sh:"; diff <(printf '%s\n' "$SOL") <(printf '%s\n' "$NUMP") | $G '^>' | sed 's/^> /  $ /' ;; esac
    rm -f .harness/ex-$k.st .harness/ex-$k.out; exrun $k bash; read -r e d < .harness/ex-$k.st
    echo "  the block's exit $e:"; $G -E "^(check:|the lab's)" .harness/ex-$k.out | sed 's/^/    /'; done; }

# ---- the runs ------------------------------------------------------------------------------------------------------------------
echo "-- exercise (once per run of record; its four stores are its own, on 20641-20644, before the unit's):"
NCAP=1; cap exercise exercise; chk exercise .r-exercise.out "$EXW" "$EXQ"
for f in exercise/README.md exercise/SOLUTION.md; do
  w=$(python3 -I -B harness/chk25.py wib .r-exercise.out "$f"); [ "$(wib "$f")" = "$w" ] || die "$f's \"What it prints\" block is not what its lines printed: $(diff <(wib "$f") <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"; done
echo "  exercise: each file's \"What it prints\" block = what its lines printed (bash's; zsh's the same - chk25)"
pub exercise
[ "$(vols)" = "$VOL0" ] || die "R.322: after the exercise the volume count is $(vols), not $VOL0"
NCAP=3
cap jars jars; chk jars .r-jars.out; pub jars
echo "-- the unit's four stores ($(date '+%T' | sed 's/.*/opened/')):"
stores > .harness/stores.out 2>&1 || true; [ -z "$pid$mpid" ] || die "the stores' window left a process running"
$G -q '^  \*\*\* ' .harness/stores.out && { cat .harness/stores.out >&3; die "the stores' window stopped (above)"; }
mask < .harness/stores.out | sed 's/^/  /'
facts_runs
echo "  the harness's facts JVM, three times, each on fresh stores (a new database, FLUSHALL, a new MongoDB, the dishes index deleted): exits $(cat .harness/facts-1/exit) $(cat .harness/facts-2/exit) $(cat .harness/facts-3/exit)"
mask < .harness/fresh-facts-1.txt | sed 's/^/  /'
cap hierarchy hierarchy; chk hierarchy .r-hierarchy.out; pub hierarchy
cap parse parse; chk parse .r-parse.out; pub parse
cap strict strict; chk strict .r-strict.out; pub strict
cap types types; chk types .r-types.out; pub types
hole_runs
cap hole hole; chk hole .r-hole.out; pub hole
NCAP=1; cap saveall saveall; chk saveall .r-saveall.out; pub saveall
dk rm -fv $CN $RN $MN $EN > /dev/null 2>&1 || die "the unit's stores could not be removed"
[ "$(vols)" = "$VOL0" ] || die "R.322: after the stores' window the volume count is $(vols), not $VOL0"
echo "  $CN, $RN, $MN and $EN removed (rm -fv) · volumes $(vols)"
cap seven seven; chk seven .r-seven.out "$S466"; pub seven
cap verify verify; chk verify .r-verify.out; pub verify
echo "  the values (chk25's, every capture's): $(printf '%s\n' "$VALS" | wc -l | tr -d ' ') lines"
printf '%s\n' "$VALS" > .harness/values.txt
python3 -I -B harness/chk25.py readme README.md .harness/values.txt > .harness/chk-readme.out 2>&1 || { $G '^FAIL' .harness/chk-readme.out | head -5 >&3; die "README.md: its values block or a text block is not what the runs printed (R.302)"; }
echo "  R.302: README.md's $($G -c '^```text$' README.md) text blocks - every line one the runs printed; the values block = the captures' (chk25 readme: $($G -c '^ok ' .harness/chk-readme.out) checks)"
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
[ -z "$AD" ] || die "flag 3: ../c8-tiffinbox moved during the run"
echo "  ../c8-tiffinbox against after/ at the end: diff -rq empty (flag 3: no anchor change)"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
echo "  ports: nothing listens on 20640-20649, 20578, 20615 or 18881-18884 at the end - the unit's stores bound 20641-20644, TiffinBox 20640, the exercise's TiffinBox 20645 (its stores 20641-20644), mvn verify's pinned ITs 20578 and 20615; 20646-20648 and 20649 were never bound"
[ -z "$unpub" ] || { echo "c8-unit25: captures without a published hash:$unpub - write them into receipts.md5 from this run's output"; exit 0; }
echo "c8-unit25: every capture = published (jars, hierarchy, parse, strict, types and hole 3/3 in this run; exercise, saveall, seven and verify once per run); every number re-derived by chk25.py; before/ and after/ = unit 24's after-tree; the volume count and the images unchanged"
