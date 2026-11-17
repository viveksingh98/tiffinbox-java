#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 8 · Aggregates, Not Entities - this unit's receipts. Course 8's first change to the anchor (C1): before/ is a frozen copy
# of ../c8-tiffinbox at the set-up commit 50d64ac (Course 7's final anchor plus a README header - no earlier Course 8 unit changed
# it), after/ is this unit's tree, and ../c8-tiffinbox equals after/ from this unit's commit on. tiffinbox-core gains spring-data-jdbc
# and com.tiffinbox.jdbc (CustomerRow, PauseRow, CustomerAggregates, JdbcNames); tiffinbox-web gains Spring Data JDBC's starter;
# TiffinBoxApp gains @EnableJdbcRepositories("com.tiffinbox.jdbc") and @Import(JdbcNames.class). Seven captures, each run three
# times and hashed; a hash that differs from receipts.md5 stops the run; every number and string the video says is asserted right
# after its capture by harness/chk02.py, against another witness of the same run - psql in this run's container, JdbcTemplate on H2,
# Surefire's two report folders, Hibernate's own counter beside the statement witness - never against a typed figure.
#   anchor    C1 file by file; the jar's libraries; Hibernate's schema script (xcheck); TiffinBox after/ on H2 in memory (20410) and
#             on PostgreSQL through the config tree's URL (20410) - strict mode, both modules' Found lines, GET /dashboard; the
#             harness on both databases (the repository beans and their factories, the transaction manager, findAll()'s SQL under
#             JdbcNames); mvn package with Maven's DOCKER_HOST pointed at nothing, then mvn verify under the Testcontainers recipe
#   quote     a COPY of after/ without JdbcNames: H2 refuses the quoted names, PostgreSQL reads them (the quoted form, labelled);
#             then after/ (JdbcNames) on both
#   dup       a COPY of after/ whose JDBC repository is named CustomerEntityRepository: the start stops (20414); the simple-name
#             check passes on after/ and fails on the copy
#   dirty     no dirty checking: B (JDBC, no save) - A (JPA, no save) - A' (JDBC, save), each a labelled window of the witness, the
#             row read back by psql after each on PostgreSQL and by JdbcTemplate on H2; the version column across both modules;
#             updated_at; RE-MEASURE 3 - Spring Data JDBC's own auditing on a COPY
#   lazy      after the call, outside any transaction: the aggregate's pauses, then the entity's - on both databases
#   seven     the comparison set on before/ and after/ over H2 (20415), and on after/ on PostgreSQL (20416)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# Every tree is COPIED under .harness/ and built there, never in place, offline. Every JVM and every Maven run runs under an alarm
# (perl -e 'alarm N; exec ...'; R.247). Every docker call names its socket (docker -H "$DH"); the container is removed with its
# volume (rm -fv) and the volume count is asserted unchanged (R.322). Ports (20410-20419): 20410 TiffinBox A (after/) · 20411 this
# run's PostgreSQL container · 20414 the dup copy's TiffinBox (refused before it binds) · 20415 the seven on H2 · 20416 the seven on
# PostgreSQL; 20412 and 20413 (the B and quote copies) are never bound - the harness runs with no web server - and 20417-20419 are
# spare, never bound. Nothing leaves the machine.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c8u02-pg
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
pid=""; mpid=""; xpid=""; CSTARTED=""; TC0=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.u02.") || index($0, "probe.x.") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "curlset.sh") || index($0, "surefirebooter") || $3 ~ /(^|\/)javac$/ || index($0, "jdk.compiler/com.sun.tools.javac") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "exec c8u02-pg") || index($0, "--name c8u02-pg") || index($0, "ex-drive.sh")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
# pgrm: docker rm -fv - the container AND its anonymous volume (R.322) - again until docker ps -a names it no more
pgrm() { local i=0; [ -n "$CSTARTED" ] || return 0
  while [ $i -lt 20 ]; do dk rm -fv "$CN" > /dev/null 2>&1 || true
    [ $i -ge 2 ] && [ -z "$(dk ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] && break
    sleep 0.5; i=$((i + 1)); done; CSTARTED=""; }
# tcrm: Testcontainers' own containers (label org.testcontainers=true) - Ryuk is off, so a killed test JVM leaves its container; rm -fv
tcrm() { local c n=0; [ -n "$TC0" ] || return 0
  for c in $(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null); do dk rm -fv "$c" > /dev/null 2>&1 && n=$((n + 1)); done
  [ "$n" = 0 ] || echo "  the trap: $n Testcontainers container(s) (label org.testcontainers=true) removed with their volumes (rm -fv)" >&3; }
trap 'trap "" INT TERM; exec 4>&- 2> /dev/null; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; pgrm; tcrm; find .harness -path "*/secrets/tiffinbox/jdbc-url" -delete 2> /dev/null || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp find curl openssl docker git unzip tar /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY FLYWAY_CANARY TESTCONTAINERS_CANARY PGPASSWORD PGOPTIONS PGHOST PGUSER DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS MAVEN_OPTS DOCKER_HOST DOCKER_CONTEXT; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|FLYWAY_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - the token and the password live under .harness/ only"
# ---- docker: the pinned socket and non-empty baselines (R.344, R.352), the volume count (R.322), Ryuk (R.318) ---------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that socket? (R.344: every docker call names its socket)"
IMGS0=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -); NI0=$(printf '%s\n' "$IMGS0" | wc -w | tr -d ' ')
VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI0" -ge 1 ] && [ "$VOL0" -ge 1 ] || die "the baselines must not be empty - images $NI0, volumes $VOL0 on $DH (an empty list compares equal to anything)"
dk image inspect "$IMG" > /dev/null 2>&1 || die "the image $IMG is not on this machine - pull it once yourself (this script never pulls)"
RY0=$(dk images --format '{{.Repository}}' 2> /dev/null | $G -c ryuk || true)
[ "$RY0" = 0 ] || die "R.318: an image named ryuk is on this machine ($RY0) - this unit asserts none before and after (Ryuk stays off)"
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container (label org.testcontainers=true) exists before the run - an interrupted run's? remove it with its volume: docker -H \"\$DH\" rm -fv <id>"
TC0=1
[ ! -e "$HOME/.testcontainers.properties" ] || die "R.318: ~/.testcontainers.properties exists - this unit's Testcontainers JVMs read a receipt home under .harness/ only; move yours aside for the run"
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · info exit 0 · images $NI0 · volumes $VOL0 (the baselines, both non-empty) · the image: $IMG is present (never pulled) · images named ryuk: $RY0 · Testcontainers containers: 0 · ~/.testcontainers.properties: absent"
# ---- the trees ------------------------------------------------------------------------------------------------------------
[ -d before ] && [ ! -L before ] || die "before/ must be a frozen copy of ../c8-tiffinbox at 50d64ac, not a link (no earlier Course 8 unit changed the anchor)"
[ -d after ] && [ ! -L after ] || die "after/ must be this unit's own tree, not a link"
for t in before after; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] || die "the tree $t (its pom.xml or README.md) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/hibernate-ddl.sql" ] && die "$t holds a secrets/, a target/ or a hibernate-ddl.sql - it is a frozen copy, never built in place"
  true; done
rm -rf .harness; mkdir -p .harness/run .harness/hc .harness/secrets .harness/home .harness/b50
git rev-parse -q --verify '50d64ac^{commit}' > /dev/null 2>&1 || die "the set-up commit 50d64ac is not in this repository's history - before/ is checked against it"
git -C "$UP" archive 50d64ac c8-tiffinbox 2> /dev/null | tar -x -C .harness/b50 || die "git archive 50d64ac c8-tiffinbox failed"
beforetree() { local d; d=$(diff -rq before .harness/b50/c8-tiffinbox 2>&1 || true)
  [ -z "$d" ] || die "R.211: before/ is not ../c8-tiffinbox at 50d64ac (git archive): $(printf '%s\n' "$d" | head -2 | paste -sd';' -)"
  echo "  before/ ($1): diff -rq before/ against git archive 50d64ac c8-tiffinbox: empty - the anchor at the set-up commit, $(find before -type f | wc -l | tr -d ' ') files"; }
[ -d ../c8-tiffinbox ] || die "../c8-tiffinbox is missing"
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c8-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c8-tiffinbox: empty - after/ = ../c8-tiffinbox"
  else echo "  (after/ and ../c8-tiffinbox differ - the anchor has moved past the tree this unit froze: $(printf '%s\n' "$d" | head -3 | paste -sd';' -))" >&3
    echo "  the anchor ($1): after/ is this unit's tree (C1) - a later change has moved ../c8-tiffinbox on"; fi; }
beforetree start; anchornote start
M2="$PWD/.m2-demo"
DSP="$M2/net/ttddyy/datasource-proxy/1.11.1/datasource-proxy-1.11.1.jar"   # the statement witness: datasource-proxy 1.11.1, the harness's alone
TH="$PWD/.harness/home"
CJ=tiffinbox-core/src/main/java/com/tiffinbox
JJ=$CJ/jdbc
APP=tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java
TJ=tiffinbox-web/src/test/java
MG=tiffinbox-core/src/main/resources/db/migration
SR=tiffinbox-web/target/surefire-reports
SRI=tiffinbox-web/target/surefire-reports-it
XD=tiffinbox-web/target/extracted
TF=secrets/tiffinbox/shutdown-token
UF=secrets/tiffinbox/jdbc-url
CURLSET=../c5-unit11/curlset.sh
[ -x "$CURLSET" ] || die "$CURLSET is missing - the comparison set the seven runs"
HFILES='chk02.py dur8.py logback.xml s802.py src surefire.py'
SFILES='probe/u02/U2.java probe/u02/Witness.java probe/x/XMain.java'
for f in exercise/README.md exercise/SOLUTION.md exercise/CustomerEntityRepository.java README.md receipts.md5 xcheck.sql; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'CustomerEntityRepository.java README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur8.py)" = 1ae45ade6730a321cbda96ecfbf6ac9a ] || die "harness/dur8.py is not the builders' dur8.py (md5 1ae45ade…)"
cmp -s harness/src/probe/x/XMain.java ../c7-unit29/harness/src/probe/x/XMain.java || die "harness/src/probe/x/XMain.java is not Course 7 unit 29's, byte for byte"
cmp -s harness/surefire.py ../c6-unit28/harness/surefire.py || die "harness/surefire.py is not the testing lesson's, byte for byte"
cmp -s xcheck.sql ../c7-unit39/xcheck.sql || die "xcheck.sql must be Course 7's capstone's, byte for byte (C1 moves no JPA mapping)"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 20410 20411 20412 20413 20414 20415 20416 20417 20418 20419"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
[ -z "$(dk ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "a container named $CN exists - an interrupted run's? remove it with its volume (rm -fv, on the pinned socket)"
echo "  ports: 20410-20419 free at the start (and 18425, 8080)"

# ---- the prose gates ----------------------------------------------------------------------------------------------------------
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s802.py harness/dur8.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -2 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
echo "  prose, per sentence (s802, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test): dur8 words 0 · a cost or size word without a count 0 · the row said to change, read off the Java object 0 · a version or stamp sentence without the read-back 0 · a SQL line without its database 0 · \"2 / 2 / 2\" 0 · single-query loading claimed 0 · a call-back without its title 0 · \"Hibernate generates\" 0 · R.302 a typed count or hash 0 - over README.md and exercise/"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
dishes() { $G -rniwE -- "$DISH" "$@" 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true; }
DN=$(dishes README.md exercise harness after/$MG after/$JJ)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, any case, over README.md, exercise/, harness/, the migrations and com.tiffinbox.jdbc)"
PH=$($G -rnE 'EXERCISE-[A-Z-]*OUTPUT|[A-Z]+-OUTPUT\b|[A-Z]+-PARAGRAPH\b|TODO|TBD|PLACEHOLDER|\bRESUME\b' README.md exercise after/$JJ after/$APP 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder line in this unit's prose or tree: $PH"
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f" | $G -v '^ *$' || true)" ] || die "$f must hold one \"What it prints\" line and, under it, a block that is not empty"; done
echo "  placeholders: 0 · each exercise file's \"What it prints\" block not empty"
prose() { awk -v f="$1" '/^<!-- (values|cells): begin -->$/ { v = 1; next } /^<!-- (values|cells): end -->$/ { v = 0; next } /^```/ { b = !b; next } !v && !b { print f ":" NR ": " $0 }' "$1"; }
SQLRE='SELECT customer\.|FROM pause WHERE|update customer set|UPDATE customer SET|DELETE FROM pause|from customer ce1_0|"customer"\."'
TS=$(for f in $PROSE; do prose "$f"; done | $G -E "$SQLRE" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string in the prose (R.225, R.365): $TS"
TNRE='\b[0-9]+ (statements?|libraries|jars|repository interfaces?|words|tests in all|SQL lines|aggregates|prepares)\b|466c''20ed|[0-9a-f]{32}|\b2 / 2 / 2\b'
TN=$(for f in $PROSE; do prose "$f"; done | $G -E "$TNRE" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TN" ] || die "R.302: a count or a printed md5 typed in the prose, outside a block a run printed and the values block: $TN"
TC=$($G -nE '466c''20ed' receipts.sh harness/chk02.py harness/src/probe/*/*.java 2> /dev/null | cut -c1-120 | head -3 | paste -sd';' - || true)
[ -z "$TC" ] || die "R.302: a printed md5 typed in this script or the harness: $TC"
echo "  typed SQL strings 0 · R.302: statement, library, repository, word and test counts and md5s typed 0 times in the prose (outside printed blocks and the values block), and 0 md5s in receipts.sh, chk02.py and the harness's sources"

# ---- static checks - before anything runs ---------------------------------------------------------------------------------------
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket (docker -H \"\$DH\")"
DK=$($G -v '^ *#' receipts.sh | $G -nE '\bdocker (run|exec|rm|ps|port|info|images|volume|image|pull|events|compose)\b' | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.344: receipts.sh calls docker without the pinned socket (every call is dk, or a README line with -H \"\$DH\"): $DK"
! $G -v '^ *#' receipts.sh | $G -qE 'rm -f'' "?(\$CN|\$c\b)|rm -f'' c8u02' || die "R.322: receipts.sh removes a container without its volume (rm -fv)"
! $G -rqE 'Thread\.sleep|while *\(true\)|TimeUnit\.[A-Z]+\.sleep|LockSupport\.park' harness/src || die "a harness sleeps or polls"
! $G -rqE 'probe\.[a-z]|\bPROBE\b|\bRED ' after/tiffinbox-web after/tiffinbox-core || die "the anchor's code names the course's harness, a probe or RED"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
! $G -rq 'datasource-proxy\|ttddyy' after/pom.xml after/tiffinbox-core/pom.xml after/tiffinbox-web/pom.xml after/tiffinbox-core/src after/tiffinbox-web/src || die "R.357: the witness (datasource-proxy) is named in the anchor - it is the harness's alone"
ST=$(python3 -I -B harness/chk02.py static after) || die "static: $(printf '%s\n' "$ST" | $G -v '^ok' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | sed 's/^/  /'
NA=$(python3 -I -B harness/chk02.py names after) || die "R.354 on after/: $(printf '%s\n' "$NA" | tail -2 | paste -sd';' -)"
printf '%s\n' "$NA" | sed 's/^/  /'
echo "  static: no kill by name; every docker call on the pinned socket; containers removed with their volumes; no sleep in the harness; no harness name, probe or RED in the anchor; the witness absent from the anchor's poms and sources (R.357)"
# ---- R.250: C1 and every sentence it makes false - a gate before any build --------------------------------------------------------
R250=$(python3 -I -B harness/chk02.py r250 after before) || die "R.250: $(printf '%s\n' "$R250" | $G -v '^ok' | head -3 | paste -sd';' -)"
printf '%s\n' "$R250" | sed 's/^/  /'

# ---- the commands: read from after/README.md, the anchor's own, and from this README ----------------------------------------
readme() { $G -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_VERIFY=$(readme 'mvn -B verify')
R_DH=$(readme 'export DOCKER_HOST=unix://$HOME/.orbstack/run/docker.sock')
R_RYUK=$(readme 'export TESTCONTAINERS_RYUK_DISABLED=true')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_TOKEN=$(readme 'mkdir -p secrets/tiffinbox && (umask 077 && printf '"'"'%s\n'"'"' "$(openssl rand -hex 16)" > secrets/tiffinbox/shutdown-token)')
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 240; exec @ARGV'"
ML="perl -e 'alarm 600; exec @ARGV'"
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*:\$DSP\" harness/src/probe/u02/U2.java harness/src/probe/u02/Witness.java harness/src/probe/x/XMain.java")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:$XD/tiffinbox-web-1.0.0.jar:$XD/lib/*:\$DSP\" probe.u02.U2 \$STEPS --logging.config=../../harness/logback.xml --spring.main.banner-mode=off --spring.jpa.properties.hibernate.generate_statistics=true")
L_X=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../lib-nofly/*\" probe.x.XMain \"\${XA[@]}\"")
L_RUN=$(mine "docker -H \"\$DH\" run -d --pull never --name $CN -p 127.0.0.1:20411:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v \"\$U/.harness/secrets/pgpw:/run/pgpw:ro\" $IMG")
L_READY=$(mine "docker -H \"\$DH\" exec $CN pg_isready -U sa -h 127.0.0.1 -q")
L_DB=$(mine "docker -H \"\$DH\" exec $CN psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c \"drop database if exists \$DB with (force)\" -c \"create database \$DB\"")
L_DROP=$(mine "docker -H \"\$DH\" exec $CN psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c \"drop database \$DB with (force)\"")
L_PSQL=$(mine "docker -H \"\$DH\" exec $CN psql -U sa -d \"\$DB\" -qAt -v ON_ERROR_STOP=1 -c \"\$Q\"")
L_SQL=$(mine "$R_RUN --logging.level.org.hibernate.SQL=debug --logging.level.org.springframework.jdbc.core.JdbcTemplate=debug")
L_MVNTC=$(mine "env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" $ML mvn -o -B -Dmaven.repo.local=\"\$M2\" \"-DargLine=$JL -Dstdout.encoding=UTF-8 -Duser.home=../../home\" clean verify")
L_NODH=$(mine "env DOCKER_HOST=tcp://127.0.0.1:1 \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" $ML mvn -o -B -Dmaven.repo.local=\"\$M2\" \"-DargLine=$JL -Dstdout.encoding=UTF-8 -Duser.home=../../home\" clean package")
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java '*) l="$AL java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
[ "$(off .harness/after "$R_PLAIN" package)" = 'cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "off(): the build line is not the README's package line, offline"
[ "${L_MVNTC##*clean }" = verify ] && [ "${L_NODH##*clean }" = package ] || die "the tests' Maven lines are not the README's verify and package lines, offline"
echo "  the commands: after/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"

# ---- build: before the captures -------------------------------------------------------------------------------------------
NOPLUG='No plugin'' found for prefix'
mbuild() { local how=yes ec=0 c=$1 miss
  (eval "$c") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
  if [ $ec != 0 ] && $G -qE "offline mode|Could not resolve|could not be resolved|Cannot access|$NOPLUG" "$2"; then
    miss=$($G -oE "Could not find artifact [^ ]+|$NOPLUG [^ ]+|the artifact [^ ]+ has not been downloaded" "$2" | head -1)
    how="no - the offline build could not resolve ${miss:-an artifact} from .m2-demo (this script never goes online: seed .m2-demo from the course's seed)"
    tail -20 "$2" >&3; die "build failed offline: $3 - $how"; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3; die "build failed: $3"; }
  [ "$($G -c '^\[INFO\] Download' "$2" || true)" = 0 ] || die "build $3: Maven's log says it downloaded"
  echo "  built $3 · offline: $how · exit $ec · 'Downloaded from' lines in its log: $($G -c '^\[INFO\] Downloaded from ' "$2" || true)"; }
summ4() { $G -E '^\[(INFO|WARNING|ERROR)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | sed -E 's/.*Tests run: ([0-9]+), Failures: ([0-9]+), Errors: ([0-9]+), Skipped: ([0-9]+)$/\1 \2 \3 \4/' | awk '{ a += $1; b += $2; c += $3; d += $4 } END { print a + 0, b + 0, c + 0, d + 0 }'; }
JE=""
jc() { local ec=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""; JE=$ec; }
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
[ -e "$DSP" ] || die "datasource-proxy 1.11.1 is not in .m2-demo - the harness's witness (README.md, The repository)"
for a in org/springframework/boot/spring-boot-dependencies/4.1.2/spring-boot-dependencies-4.1.2.pom org/springframework/data/spring-data-jdbc/4.1.2/spring-data-jdbc-4.1.2.jar org/springframework/data/spring-data-relational/4.1.2/spring-data-relational-4.1.2.jar org/springframework/boot/spring-boot-data-jdbc/4.1.2/spring-boot-data-jdbc-4.1.2.jar org/springframework/boot/spring-boot-starter-data-jdbc/4.1.2/spring-boot-starter-data-jdbc-4.1.2.jar org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar org/testcontainers/testcontainers/2.0.5/testcontainers-2.0.5.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
[ ! -e "$M2/org/apache/maven/plugins/maven-failsafe-plugin" ] || die "maven-failsafe-plugin is in .m2-demo - the course's seed holds none"
copy before .harness/before; copy after .harness/after
# the three copies, each made from after/ here and described in its capture
copy after .harness/quote; rm -f .harness/quote/$JJ/JdbcNames.java
sed -i '' -e '/^import com\.tiffinbox\.jdbc\.JdbcNames;$/d' -e '/^@Import(JdbcNames\.class)$/d' -e '/^import org\.springframework\.context\.annotation\.Import;$/d' .harness/quote/$APP
copy after .harness/quote0
sed -i '' -e '/^import com\.tiffinbox\.jdbc\.JdbcNames;$/d' -e '/^@Import(JdbcNames\.class)$/d' -e '/^import org\.springframework\.context\.annotation\.Import;$/d' .harness/quote0/$APP
copy after .harness/dup; rm -f .harness/dup/$JJ/CustomerAggregates.java; cp exercise/CustomerEntityRepository.java .harness/dup/$JJ/CustomerEntityRepository.java
copy after .harness/audit
sed -i '' -e 's/^@EnableJpaAuditing$/@EnableJpaAuditing\
@EnableJdbcAuditing/' -e 's/^import org\.springframework\.data\.jdbc\.repository\.config\.EnableJdbcRepositories;$/import org.springframework.data.jdbc.repository.config.EnableJdbcAuditing;\
import org.springframework.data.jdbc.repository.config.EnableJdbcRepositories;/' .harness/audit/$APP
awk '{ print } /^    private Long version;$/ { print ""; print "    @LastModifiedDate"; print "    private Instant updatedAt;" } /^import org\.springframework\.data\.annotation\.Id;$/ { print "import org.springframework.data.annotation.LastModifiedDate;" } /^import com\.tiffinbox\.MealType;$/ { print "import java.time.Instant;" }' after/$JJ/CustomerRow.java > .harness/audit/$JJ/CustomerRow.java
for t in before after quote quote0 dup audit; do
  mbuild "$(off .harness/$t "$R_PLAIN" package) -DskipTests" .harness/build-$t.log ".harness/$t ($t, the README's package line, -DskipTests: the anchor capture runs the tests)"
  [ "$(summ4 .harness/build-$t.log)" = '0 0 0 0' ] || die "$t: tests ran in a -DskipTests build"
  (cd .harness/$t && eval "$R_EXTRACT") > .harness/extract-$t.log 2>&1 < /dev/null || die "the extract of $t failed: $(tail -3 .harness/extract-$t.log)"; done
LIB=after/$XD/lib
mkdir -p .harness/lib-nofly
for j in $(ls .harness/$LIB); do case $j in flyway-*|spring-boot-flyway-*) ;; *) ln -s ../$LIB/$j .harness/lib-nofly/$j ;; esac; done
(cd .harness/after && eval "$R_TOKEN") || die "the token was not written"
TOKEN=$(head -n 1 .harness/after/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
for t in before quote quote0 dup audit; do mkdir -p .harness/$t/secrets/tiffinbox && (umask 077 && cp .harness/after/$TF .harness/$t/$TF); done
for t in before after quote quote0 dup audit; do [ "$(stat -f '%Lp' .harness/$t/$TF)" = 600 ] || die "the token's file in $t must be mode 0600"; done
jc "$L_JAVAC" .harness/javac.log; [ "$JE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
echo "  extracted six jars; xcheck's class path: after/'s lib/ without Flyway's three jars; the harness compiled once against after/'s jar and the witness (.harness/hc, $(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes); the token generated (the README's line), copied into the other trees' $TF, mode 0600, never printed"
# the container: PostgreSQL 18 from the pinned image, loopback only, a generated password in a 0600 file (R.214)
(umask 077 && LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom 2> /dev/null | head -c 24 > .harness/secrets/pgpw) || true
[ "$(wc -c < .harness/secrets/pgpw | tr -d ' ')" = 24 ] && [ "$(stat -f '%Lp' .harness/secrets/pgpw)" = 600 ] || die "the password file was not written, 24 characters, mode 0600"
PW=$(cat .harness/secrets/pgpw)
CSTARTED=1
(eval "$L_RUN") > .harness/docker-run.log 2>&1 < /dev/null || die "the container did not start: $(tail -2 .harness/docker-run.log)"
i=0; while ! (eval "$L_READY") > /dev/null 2>&1 < /dev/null; do i=$((i + 1)); [ $i -lt 120 ] || die "the container did not accept connections within its cap (120 tries, 0.5 apart)"; sleep 0.5; done
DP=$(dk port "$CN" 2> /dev/null | paste -sd'|' -)
[ "$DP" = '5432/tcp -> 127.0.0.1:20411' ] || die "the container must publish 5432 on 127.0.0.1:20411 alone: $DP"
echo "  the container: $CN from $IMG (--pull never); its published port: $DP; user sa, the password generated into .harness/secrets/pgpw (24 characters, mode 0600, never printed); pg_isready after $i tries (cap 120)"
printf '%s\n' 'checks.disable=true' "tinyimage.container.image=$IMG" > .harness/home/.testcontainers.properties

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C $G -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; PGDBS=0
mask() { awk -v t="$TOKEN" -v pw="$PW" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); W = lit(pw); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the token]"); gsub(W, "<pw>"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/\(execution time [0-9:.]+s\)/, "(execution time <t>)")
    gsub(/repository scanning in [0-9]+ ms/, "repository scanning in <t> ms")
    gsub(/ started in PT[0-9.]+S/, " started in PT<t>S")
    gsub(/\$\$Lambda\/0x[0-9a-f]+/, "$$Lambda/<n>")
    gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"<time>\"")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting Main using Java 25.0.4.1' "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' "token $TOKEN" "url jdbc:postgresql://127.0.0.1:20411/u02?user=sa&password=$PW" 'Successfully applied 3 migrations to schema "public", now at version v3 (execution time 00:00.026s)' 'Finished Spring Data repository scanning in 23 ms. Found 1 JPA repository interface.' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting Main using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'token [masked: the token]' 'url jdbc:postgresql://127.0.0.1:20411/u02?user=sa&password=<pw>' 'Successfully applied 3 migrations to schema "public", now at version v3 (execution time <t>)' 'Finished Spring Data repository scanning in <t> ms. Found 1 JPA repository interface.')" ] || die "mask: the planted JDK version, folders, home, identity hash, the token, the password, Flyway's execution time and Spring Data's scan time must be masked"
echo "  mask: its self-test passed (the token, the password, folders, home, identities, Flyway's execution time and Spring Data's scan time - dur8's masks); raw password copies after mask: $(mask < .harness/p1 | $G -cF -- "$PW" || true)"
rm -f .harness/p1
pgdb() { local DB=$1; echo "\$ DB=$DB; $L_DB"; (eval "$L_DB") > .harness/pgdb.log 2>&1 < /dev/null || die "the fresh database $DB was not made: $(tail -2 .harness/pgdb.log)"
  PGDBS=$((PGDBS + 1)); echo "  a fresh database: $DB"; }
pgdrop() { local DB=$1; (eval "$L_DROP") > .harness/pgdb.log 2>&1 < /dev/null || die "the database $DB was not dropped: $(tail -2 .harness/pgdb.log)"
  echo "  dropped: $DB · the u02 databases left: $(dk exec "$CN" psql -U sa -d postgres -qAt -c "select coalesce(string_agg(datname, ', '), '(none)') from pg_database where datname like 'u02%'" 2> /dev/null)"; }
PDB=""
rd() { local Q=$1 DB=$PDB e=0; (eval "$L_PSQL") > .harness/rd.out 2>&1 < /dev/null || e=$?
  [ "$e" = 0 ] || { cat .harness/rd.out >&3; die "psql failed (exit $e)"; }
  sed 's/^/    /' .harness/rd.out; }
pgurl() { (umask 077 && printf '%s' "jdbc:postgresql://127.0.0.1:20411/$2?user=sa&password=$PW" > .harness/$1/$UF); }
unpub=""
cap() { local nm=$1 i; shift
  for i in 1 2 3; do CAPRUN=$i; "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; raw "$PW" .harness/cap.raw > ".harness/rawpw-$nm.$i"
    mask < .harness/cap.raw > ".r-$nm.$i"; done
  CH=$(md5 -q ".r-$nm.1")
  [ "$CH" = "$(md5 -q ".r-$nm.2")" ] && [ "$CH" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; }
pub() { local nm=$1 h pub; h=$(md5 -q ".r-$nm.out")
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-10s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-10s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-10s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
VALS=""
chk() { local nm=$1 o e=0; shift
  o=$(python3 -I -B harness/chk02.py "$nm" "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' | tee .harness/chk-$nm.out || true
  [ $e = 0 ] || die "$nm: its check failed (harness/chk02.py, above)"
  VALS="$VALS${VALS:+ · }$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }

# ---- the harness JVM: one line of steps, its own folder's config tree -------------------------------------------------------------
HE=""
REPO_RE='Multiple Spring Data modules found|Bootstrapping Spring Data|Could not safely identify store assignment|Finished Spring Data repository scanning'
repolines() { $G -E "$REPO_RE" "$1" | sed -E 's/^[0-9T:.+-]+ +(INFO|WARN) +[0-9]+ --- \[[^]]*\] [^:]+: //; s/^(INFO|WARN) +\[[^]]*\] [^ ]+ : //; s/(Could not safely identify store assignment for repository candidate interface [A-Za-z.]+);.*/\1; …/; s/[[:space:]]+$//' | mask | sed 's/^/  log: /'; }
hj() { local t=$1 STEPS=$2 c e=0
  c=$(printf 'cd .harness/%s && %s\n' "$t" "$L_H"); echo "\$ STEPS=$STEPS; $c"
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!; wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1))
  [ "$e" != 142 ] || die "the harness JVM's alarm fired (exit 142, cap 240 - R.247)"
  repolines .harness/h.log
  $G -E 'HHH000001|FlywayExecutor : Database: ' .harness/h.log | sed -E 's/^[A-Z]+ +\[[^]]*\] [^ ]+ : //' | mask | sed 's/^/  log: /'
  $G -E '^PROBE ' .harness/h.log | sed 's/^PROBE /  /' | mask
  echo "  exit $e · its log: org.hibernate.SQL lines $($G -cE ' org\.hibernate\.SQL : ' .harness/h.log || true) · JdbcTemplate's SQL lines (Executing prepared SQL statement) $($G -c 'org.springframework.jdbc.core.JdbcTemplate : Executing prepared SQL statement' .harness/h.log || true) · ERROR lines $($G -c '^ERROR ' .harness/h.log || true) · the token $(raw "$TOKEN" .harness/h.log) times, the password $(raw "$PW" .harness/h.log) times (raw)"; }
# ---- TiffinBox: start, wait, ask, stop ---------------------------------------------------------------------------------------
dir() { printf '%s\n' "$1" | sed -n 's/^cd \([^ ]*\) && .*/\1/p'; }
start() { [ "$(listeners "$2")" = 0 ] || die "something listens on $2 before the start"; echo "\$ $1"; : > .harness/run.out; (eval "$(exe "$1")") >> .harness/run.out 2>&1 < /dev/null & pid=$!; }
addrs() { lsof -nP -a -p "$1" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
up() { local a="" i=0
  while [ $i -lt 480 ]; do a=$(addrs "$pid"); case " $a " in *":$1 "*) break ;; esac; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  case " $a " in *":$1 "*) ;; *) tail -20 .harness/run.out | mask >&3; die "it never listened on $1" ;; esac
  echo "  listens on: $a"; }
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out | mask >&3; die "it exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"; echo "  GET /actuator/health/readiness -> 200"; }
LASTE=""
stopit() { local i=0 e=0; kill "$pid" 2> /dev/null || true
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 160 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill -9 "$pid"; die "the server on $1 was still running after its SIGTERM"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; echo "  stopped by its pid (SIGTERM): exit $LASTE · listening on $1 now: 0"; }
gone() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 480 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; }
logtok() { local t w; t=$(raw "$TOKEN" .harness/run.out); w=$(raw "$PW" .harness/run.out); LOGS=$((LOGS + 1)); [ "$t" = 0 ] || die "a TiffinBox log held the token ($t)"; [ "$w" = 0 ] || die "a TiffinBox log held the password, raw ($w)"; echo "  its log: the token 0 times, the password 0 times (raw, before the mask)"; }
lines() { wc -l < .harness/run.out | tr -d ' '; }
settle() { local a b i=0; a=$(lines); while [ $i -lt 20 ]; do sleep 0.25; b=$(lines); [ "$a" = "$b" ] && break; a=$b; i=$((i + 1)); done; }
U02M=U02MARK
mark() { printf '%s %s\n' "$U02M" "$1" >> .harness/run.out; }
seg() { awk -v a="$U02M $1 start" -v b="$U02M $1 end" '$0 == a { f = 1; next } $0 == b { f = 0 } f' .harness/run.out; }
rq() { local l=$1 p=$3 ac=$4 code
  mark "$l start"; echo "\$ curl -s --noproxy '*' -H 'Accept: $ac' http://127.0.0.1:$p$2"
  code=$(curl -s --noproxy '*' -o .harness/body-$l -w '%{http_code}' -H "Accept: $ac" "http://127.0.0.1:$p$2" 2> /dev/null || true)
  settle; mark "$l end"; seg "$l" > .harness/seg-$l.log
  echo "  -> $code · the request's org.hibernate.SQL lines, between its two markers: $($G -cE ' org\.hibernate\.SQL +: ' .harness/seg-$l.log || true) · JdbcTemplate's SQL lines: $($G -c 'Executing prepared SQL statement' .harness/seg-$l.log || true) · ERROR lines: $($G -cE '^[^ ]+ +ERROR ' .harness/seg-$l.log || true)"; }
tblines() { repolines .harness/run.out
  $G -E 'HHH000001|FlywayExecutor +: Database: ' .harness/run.out | sed -E 's/^.* : //; s/[[:space:]]+$//' | mask | sed 's/^/  log: /'
  echo "  its log, read off: 'Database JDBC URL [jdbc:h2:mem:tiffinbox' $($G -c 'Database JDBC URL \[jdbc:h2:mem:tiffinbox' .harness/run.out || true) · 'Database JDBC URL [jdbc:postgresql://127.0.0.1:20411/' $($G -c 'Database JDBC URL \[jdbc:postgresql://127.0.0.1:20411/' .harness/run.out || true) · 'Successfully applied 3 migrations' $($G -c 'Successfully applied 3 migrations' .harness/run.out || true) · ERROR lines $($G -cE '^[^ ]+ +ERROR ' .harness/run.out || true)"; }

# ---- the captures --------------------------------------------------------------------------------------------------------
RQ="select name || ' meals ' || meals_per_day || ' version ' || version || ' updated_at ' || case when updated_at is null then 'null' else 'set' end from customer where name = 'Ravi'"
UQ="select coalesce(cast(updated_at as text), 'null') from customer where name = 'Ravi'"
XA=('--spring.datasource.url=jdbc:h2:mem:x02;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --logging.level.org.hibernate.orm.core=info --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
same5() { diff -rq before/tiffinbox-web/src/main/resources after/tiffinbox-web/src/main/resources > /dev/null 2>&1 && diff -rq before/$MG after/$MG > /dev/null 2>&1 && diff -rq before/$TJ after/$TJ > /dev/null 2>&1 && cmp -s before/$CJ/CustomerEntity.java after/$CJ/CustomerEntity.java && cmp -s before/$CJ/PauseEntity.java after/$CJ/PauseEntity.java && cmp -s before/$CJ/CustomerEntityRepository.java after/$CJ/CustomerEntityRepository.java && echo 'the same, byte for byte' || echo differ; }
anchor() { local d n
  echo "C1 - after/ against before/ (diff -rq, the file names):"
  diff -rq before after | sed -E 's#^Files before/(.*) and after/.* differ$#  changed: \1#; s#^Only in before/(.*): (.*)$#  deleted: \1/\2#; s#^Only in after/(.*): (.*)$#  new: \1/\2#' | sort
  echo "  the YAML, Flyway's migrations, the three JPA files and the tests, after/ against before/: $(same5)"
  for t in before after; do n=$(ls .harness/$t/$XD/lib | wc -l | tr -d ' ')
    echo "  .harness/$t's jar, extracted - lib/ (ls lib | wc -l): $n libraries · postgresql-*.jar: $(ls .harness/$t/$XD/lib | $G -E '^postgresql-.*\.jar$' || echo none) · spring-data-jdbc-*.jar: $(ls .harness/$t/$XD/lib | $G -cE '^spring-data-jdbc-' || true)"; done
  d=$(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | sed -n 's/^< //p' | paste -sd' ' -)
  echo "  the libraries after/'s jar adds: $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | sed -n 's/^> //p' | paste -sd' ' -) · removes: ${d:-none}"
  echo "Hibernate's DDL over after/'s libraries without Flyway's three jars (.harness/lib-nofly) - probe.x.XMain, scripts.action=create (a file, never run):"
  rm -f .harness/run/hibernate-ddl.sql
  local c e=0; c=$(printf 'cd .harness/run && %s\n' "$L_X"); echo "\$ XA=($(printf '%q ' "${XA[@]}" | sed 's/ $//'))"; echo "\$ $c"
  (eval "$(exe "$c")") > .harness/x.log 2>&1 < /dev/null & pid=$!; wait "$pid" || e=$?; pid=""; LOGS=$((LOGS + 1))
  [ -f .harness/run/hibernate-ddl.sql ] || { tail -5 .harness/x.log >&3; die "xcheck: no script"; }
  mv .harness/run/hibernate-ddl.sql .harness/ddl-after.sql
  echo "  exit $e · its org.flywaydb lines: $($G -c 'org\.flywaydb' .harness/x.log || true) · the script's md5: $(md5 -q .harness/ddl-after.sql) · the filed xcheck.sql (= Course 7's capstone's): $(md5 -q xcheck.sql) · cmp: $(cmp -s .harness/ddl-after.sql xcheck.sql && echo 'the same, byte for byte' || echo differ)"
  echo "A - TiffinBox after/'s jar, the default: java -jar, H2 in memory (application.yaml's tiffinbox.jdbc-url), port 20410:"
  start "$(at .harness/after 20410 "$L_SQL")" 20410; up 20410; ready 20410; tblines
  rq dash /dashboard 20410 text/html; stopit 20410; logtok
  echo "A - the same jar on PostgreSQL: a fresh database u02a, its URL in after/'s own config tree (secrets/tiffinbox/jdbc-url, mode 0600), its own driver from lib/, port 20410:"
  pgdb u02a; PDB=u02a; pgurl after u02a
  start "$(at .harness/after 20410 "$L_SQL") --logging.level.org.hibernate.orm.connections.pooling=warn" 20410; up 20410; ready 20410; tblines
  rq dash /dashboard 20410 text/html; stopit 20410; logtok
  echo "  psql - the tables and the history: $(Q="select string_agg(table_name, ', ' order by table_name) from information_schema.tables where table_schema = 'public'"; rd "$Q" | sed 's/^ *//') · $(Q="select count(*) || ' rows, success ' || bool_and(success) from flyway_schema_history"; rd "$Q" | sed 's/^ *//')"
  rm -f .harness/after/$UF; pgdrop u02a
  echo "the harness on after/ - H2 in memory (the second client is JdbcTemplate), the data line built first:"
  hj after seed,beans
  echo "the harness on after/ - PostgreSQL, a fresh database u02b, its URL in after/'s config tree:"
  pgdb u02b; PDB=u02b; pgurl after u02b
  hj after seed,beans
  echo "  psql - the data line, a second client: $(Q="select (select count(*) from customer) || ' customers · ' || (select count(*) from pause) || ' pauses · ' || (select sum(days) from pause) || ' paused days'"; rd "$Q" | sed 's/^ *//')"
  rm -f .harness/after/$UF; pgdrop u02b
  echo "tests - after/ copied to .harness/tests: mvn package with Maven's DOCKER_HOST pointed at nothing (Maven's env alone; the README's package line), then mvn verify under the README's two export lines and a receipt home:"
  rm -rf .harness/tests; copy after .harness/tests
  mvnrun .harness/tests package "$L_NODH"
  python3 -I harness/surefire.py .harness/tests/$SR | sed 's/^/  /'; echo "  $SRI: $( [ -d .harness/tests/$SRI ] && echo present || echo 'absent - no container test ran')"; results .harness/package.log
  echo "\$ $R_DH"; echo "\$ $R_RYUK"; preflight
  mvnrun .harness/tests verify "$L_MVNTC"; ryuk3 verify
  echo "  Surefire's reports, $SR:"; python3 -I harness/surefire.py .harness/tests/$SR | sed 's/^/  /'
  echo "  Surefire's reports, $SRI:"; python3 -I harness/surefire.py .harness/tests/$SRI | sed 's/^/  /'
  results .harness/verify.log
  echo "  the verify log: strict mode lines $($G -c 'Multiple Spring Data modules found, entering strict repository configuration mode' .harness/verify.log || true) · 'Found 1 JDBC repository interface' $($G -c 'Found 1 JDBC repository interface' .harness/verify.log || true) · Testcontainers 2.0.5 $($G -c 'Testcontainers version: 2.0.5' .harness/verify.log || true) · the token and the password: $(raw "$TOKEN" .harness/verify.log) / $(raw "$PW" .harness/verify.log) times"; }
preflight() { local n
  [ "$(curl -s --unix-socket "${DH#unix://}" http://localhost/_ping 2> /dev/null)" = OK ] || die "the OrbStack socket ${DH#unix://} does not answer /_ping - is OrbStack running? (Testcontainers needs it)"
  [ "${TESTCONTAINERS_RYUK_DISABLED:-}" = true ] || die "R.318 pre-flight: TESTCONTAINERS_RYUK_DISABLED is '${TESTCONTAINERS_RYUK_DISABLED:-unset}' - Maven not started"
  n=$($G -c '^ryuk\.' "$TH/.testcontainers.properties" || true)
  [ "$n" = 0 ] || die "R.318 pre-flight: $n ryuk.* key(s) in the receipt home's .testcontainers.properties; Maven not started"
  echo "  pre-flight (R.318): /_ping OK on $(printf '%s' "$DH" | sed "s#$HOME#~#") · TESTCONTAINERS_RYUK_DISABLED=true · the receipt home's .testcontainers.properties: $(sed 's/=.*//' "$TH/.testcontainers.properties" | paste -sd' ' -), ryuk.* keys 0"; }
MVE=""
mvnrun() { local d=$1 l=$2 c=$3 t0 t1 e=0 n im
  echo "\$ cd $d && $c"
  t0=$(date +%s); (cd "$d" && eval "$c") > .harness/$l.log 2>&1 < /dev/null & mpid=$!; wait "$mpid" || e=$?; mpid=""; t1=$(date +%s); MVE=$e
  sleep 1; dk events --since "$t0" --until "$((t1 + 1))" --filter type=image --filter type=container --format '{{.Type}} {{.Action}} {{.Actor.Attributes.image}}' > .harness/$l.events 2> /dev/null || true
  [ "$e" != 142 ] || die "$l: Maven's alarm fired (exit 142, cap 600 - R.247)"
  n=$($G -cE '^\[INFO\] Download(ing|ed) from ' .harness/$l.log || true)
  echo "  exit $e · $($G -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/$l.log || echo 'no BUILD line') · offline: $( [ "$n" = 0 ] && echo yes || echo "no - $n lines say Maven downloaded") · its alarm's cap: 600 (R.247)"
  im=$($G '^container create ' .harness/$l.events | awk '{ print $3 }' | sort -u | paste -sd' ' -)
  echo "  the engine's events over its window (the pinned CLI): image pull $($G -c '^image pull' .harness/$l.events || true) · container create $($G -c '^container create ' .harness/$l.events || true) (${im:-none}) · Testcontainers containers left: $(dk ps -aq --filter label=org.testcontainers=true | wc -l | tr -d ' ')"; }
ryuk3() { local l=$1 c o p n
  n=$($G -c 'Ryuk has been disabled' .harness/$l.log || true)
  [ "$n" = 1 ] || die "R.318 (the log): 'Ryuk has been disabled' lines $n in $l (want 1)"
  c=$($G -c '^container create ' .harness/$l.events || true); o=$($G '^container create ' .harness/$l.events | $G -vc " $IMG\$" || true); p=$($G -c '^image pull' .harness/$l.events || true)
  [ "$c" = 1 ] && [ "$o" = 0 ] && [ "$p" = 0 ] || die "R.318 (the events): container creates $c, not the digest $o, pulls $p in $l (want 1, 0, 0)"
  echo "  Ryuk's three checks (R.318): pre-flight PASS · the log: 'Ryuk has been disabled' 1 · the events: $c container create of the digest, 0 others, 0 image pulls"; }
results() { $G -E '^\[(INFO|WARNING|ERROR)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | sed -E 's/^\[[A-Z]+\] /  Surefire'"'"'s Results line: /'; }
quote() {
  echo "the quote copy - after/ without JdbcNames (.harness/quote): its lines that differ from after/:"
  diff -r after .harness/quote -x target -x secrets 2>&1 | sed -E 's#^Only in after/(.*): (.*)$#  deleted: \1/\2#' | $G -E '^  deleted|^[<>]' | sed -E 's/^([<>]) /  \1 /'
  echo "quote0 - a second COPY, after/ with only the @Import line and its two imports removed (.harness/quote0), H2 in memory:"
  diff -r after .harness/quote0 -x target -x secrets 2>&1 | $G -E '^[<>]' | sed -E 's/^([<>]) /  \1 /'
  hj quote0 read
  echo "  (TiffinBoxApp's @ComponentScan(\"com.tiffinbox\") still finds JdbcNames in com.tiffinbox.jdbc: the quote copy deletes the class)"
  echo "quote - H2 in memory (labelled: the failure receipt; the copy):"
  hj quote read
  echo "quote - PostgreSQL, a fresh database u02q (labelled: the quoted form, failure receipt only; the copy):"
  pgdb u02q; PDB=u02q; pgurl quote u02q; hj quote read; rm -f .harness/quote/$UF; pgdrop u02q
  echo "Q - after/ (JdbcNames imported) on H2 in memory:"
  hj after read
  echo "Q - after/ on PostgreSQL, a fresh database u02r:"
  pgdb u02r; PDB=u02r; pgurl after u02r; hj after read; rm -f .harness/after/$UF; pgdrop u02r; }
dup() {
  echo "the dup copy - after/ whose Spring Data JDBC repository is named CustomerEntityRepository (.harness/dup: exercise/CustomerEntityRepository.java in place of CustomerAggregates.java):"
  diff -rq after .harness/dup -x target -x secrets 2>&1 | sed -E 's#^Only in after/(.*): (.*)$#  deleted: \1/\2#; s#^Only in \.harness/dup/(.*): (.*)$#  new: \1/\2#' | sort
  echo "R.354 - the repository interfaces' simple names across the two modules (harness/chk02.py names):"
  local e=0; echo "  after/:"; python3 -I -B harness/chk02.py names after > .harness/names-after.out 2>&1 || e=$?; sed 's/^/  /' .harness/names-after.out; echo "  exit $e"
  e=0; echo "  the dup copy:"; python3 -I -B harness/chk02.py names .harness/dup > .harness/names-dup.out 2>&1 || e=$?; sed 's/^/  /' .harness/names-dup.out | sed 's#\.harness/dup#the copy#'; echo "  exit $e"
  echo "dup - TiffinBox's jar from the copy, java -jar, H2 in memory, port 20414:"
  start "$(at .harness/dup 20414 "$R_RUN")" 20414; gone 20414
  echo "  exit $LASTE · it listened on: nothing · 'APPLICATION FAILED TO START' $($G -c 'APPLICATION FAILED TO START' .harness/run.out || true)"
  repolines .harness/run.out
  echo "  the exception (cut at its first ':' after the bean name): $($G -m1 -oE "BeanDefinitionOverrideException: Invalid bean definition with name '[A-Za-z]+' defined in [A-Za-z.]+ defined in @Enable[A-Za-z]+ declared on [A-Za-z]+" .harness/run.out)"
  echo "  Boot's failure analysis:"; awk '/^Description:$/ { f = 1; next } /^Action:$/ { f = 0 } f && NF' .harness/run.out | sed 's/^/    /' | mask
  logtok; }
dirty() { local u1 u2
  echo "dirty - PostgreSQL, a fresh database u02d, after/'s config tree; one JVM per step, psql between them (the second client):"
  pgdb u02d; PDB=u02d; pgurl after u02d
  hj after seed
  echo "  psql, before any window: $(rd "$RQ" | sed 's/^ *//')"
  hj after B
  echo "  psql, after B: $(rd "$RQ" | sed 's/^ *//')"
  hj after A
  echo "  psql, after A: $(rd "$RQ" | sed 's/^ *//')"; u1=$(rd "$UQ")
  hj after A2
  echo "  psql, after A': $(rd "$RQ" | sed 's/^ *//')"; u2=$(rd "$UQ")
  echo "  psql - updated_at after A' against after A: $( [ "$u1" = "$u2" ] && echo 'the same value' || echo 'a new value') (the values themselves not printed: times)"
  echo "  psql - the pause rows, untouched by A' (Ravi has none): $(Q="select count(*) || ' pauses · ' || coalesce(sum(days), 0) || ' days' from pause"; rd "$Q" | sed 's/^ *//')"
  rm -f .harness/after/$UF; pgdrop u02d
  echo "dirty - H2 in memory, one JVM: the windows in the same order, JdbcTemplate the second client:"
  hj after seed,back,B,back,A,back,A2,back
  echo "RE-MEASURE 3 - Spring Data JDBC's own auditing, on a COPY (.harness/audit, never after/): its lines that differ from after/:"
  diff -r after .harness/audit -x target -x secrets 2>&1 | $G -E '^[<>]' | sed -E 's/^([<>]) /  \1 /'
  echo "audit copy - H2 in memory:"
  hj audit back,A2,back
  echo "audit copy - PostgreSQL, a fresh database u02e:"
  pgdb u02e; PDB=u02e; pgurl audit u02e
  hj audit back,A2,back
  echo "  psql, after it: $(rd "$RQ" | sed 's/^ *//')"
  rm -f .harness/audit/$UF; pgdrop u02e; }
lazy() {
  echo "lazy - H2 in memory, after/:"
  hj after lazy
  echo "lazy - PostgreSQL, a fresh database u02l, after/'s config tree:"
  pgdb u02l; PDB=u02l; pgurl after u02l; hj after lazy; rm -f .harness/after/$UF; pgdrop u02l
  echo "  application.yaml's open-in-view, after/: $($G -E '^    open-in-view: ' after/tiffinbox-web/src/main/resources/application.yaml | sed 's/^ *//')"; }
sqlseg() { sed -n "${1},\$p" .harness/run.out | $G -cE "$2" || true; }
seven2() { local t n0
  for t in before after; do
    echo "the seven - $t/'s jar, java -jar, H2 in memory (a fresh JVM), port 20415, the SQL loggers on:"
    start "$(at .harness/$t 20415 "$L_SQL")" 20415; up 20415; ready 20415; n0=$(lines)
    echo "\$ \$CURLSET 20415 .harness/$t/$TF"
    "$CURLSET" 20415 ".harness/$t/$TF" | $G ' -> ' > .harness/responses.txt || true
    awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' .harness/responses.txt > .harness/seven-$t.txt
    gone 20415
    echo "  exit $LASTE · the seven responses: $(wc -l < .harness/seven-$t.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven-$t.txt)"
    echo "  its log during the seven: org.hibernate.SQL lines $(sqlseg "$((n0 + 1))" ' org\.hibernate\.SQL +: ') · JdbcTemplate's SQL lines $(sqlseg "$((n0 + 1))" 'Executing prepared SQL statement')"
    logtok; done
  echo "the seven - after/'s jar on PostgreSQL (its own driver), a fresh database u02s, its URL in after/'s config tree, port 20416:"
  pgdb u02s; PDB=u02s; pgurl after u02s
  start "$(at .harness/after 20416 "$L_SQL") --logging.level.org.hibernate.orm.connections.pooling=warn" 20416; up 20416; ready 20416; n0=$(lines)
  echo "\$ \$CURLSET 20416 .harness/after/$TF"
  "$CURLSET" 20416 ".harness/after/$TF" | $G ' -> ' > .harness/responses.txt || true
  awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' .harness/responses.txt > .harness/seven-pg.txt
  gone 20416
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/seven-pg.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven-pg.txt)"
  echo "  its log during the seven: org.hibernate.SQL lines $(sqlseg "$((n0 + 1))" ' org\.hibernate\.SQL +: ') · JdbcTemplate's SQL lines $(sqlseg "$((n0 + 1))" 'Executing prepared SQL statement')"
  logtok; rm -f .harness/after/$UF; pgdrop u02s
  echo "  the seven, after/ against before/ (H2): lines that differ: $(diff .harness/seven-before.txt .harness/seven-after.txt | $G -c '^[<>]' || true) · after/ on PostgreSQL against after/ on H2: $(diff .harness/seven-after.txt .harness/seven-pg.txt | $G -c '^[<>]' || true)"; }
# exercise: the README's commands, then the solution's - in ONE shell, bash, then zsh
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
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
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines:"
  echo "  the block's exit $e1 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "  the shell is now in: $(where "$d1")"
  echo "  then the solution's lines, in the same shell - the block's exit $e2 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines · DOCKER_HOST in its environment: $(env -i HOME="$HOME" PATH="$XPATH" /usr/bin/env | $G -c '^DOCKER_HOST=' || true) · listening on 20417-20419: $(for p in 20417 20418 20419; do listeners $p; done | awk '{ n += $1 } END { print n + 0 }')"; }
exercise() { local setup sol
  setup=$(block exercise/README.md); sol=$(block exercise/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  printf '%s\n' "$sol" | sed -n 1p | $G -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  [ "$(diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | $G -c '^[<>]')" = 2 ] || die "SOLUTION.md's block must be the README's with one line changed"
  printf '%s\n' "$setup" | $G -E ' mvn | java ' | $G -vqF "perl -e 'alarm " && die "exercise/README.md's Maven and Java runs must run under their alarm (R.247)"
  ! printf '%s\n' "$setup" | $G -q 'DOCKER_HOST\|docker ' || die "the exercise must need no Docker: its block names DOCKER_HOST or docker"
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-readme.st"
cd "$1" || exit 1
. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-sol.st"
DRV
  echo "exercise/README.md's $(printf '%s\n' "$setup" | $G -c .) lines, then exercise/SOLUTION.md's, exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), started in this folder; H2 in memory, no Docker:"
  echo "the README's lines:"; printf '%s\n' "$setup" | sed 's/^/  $ /'
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh; }
EXQ="Your turn: TiffinBox's second repository refuses to start. Rename one interface so both Spring Data modules register their repositories."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
export DOCKER_HOST="$DH" TESTCONTAINERS_RYUK_DISABLED=true    # the README's two export lines, after the baselines (the package run sets DOCKER_HOST on Maven's env alone)
cap exercise exercise; chk exercise .r-exercise.out "$EXW" "$EXQ"
for f in exercise/README.md exercise/SOLUTION.md; do
  w=$(python3 -I -B harness/chk02.py wib .r-exercise.out "$f"); [ "$(wib "$f")" = "$w" ] || die "$f's \"What it prints\" block is not what its lines printed: $(diff <(wib "$f") <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "exercise: broken and solved print the same (R.196)"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
echo "  exercise: each file's What it prints = the run (bash's), the two differ (R.196); the spoken line $EXW words (wc -w)"
pub exercise
cap anchor anchor; chk anchor .r-anchor.out after/README.md; pub anchor
cap quote quote; chk quote .r-quote.out; pub quote
cap dup dup; chk dup .r-dup.out; pub dup
cap dirty dirty; chk dirty .r-dirty.out; pub dirty
cap lazy lazy; chk lazy .r-lazy.out; pub lazy
cap seven seven2; chk seven .r-seven.out "$S466"; pub seven
# R.302: every line of README.md's ```text blocks is a line a run printed
cat .r-*.out .harness/chk-*.out 2> /dev/null | sed -E 's/^ +//' > .harness/printed.txt
TX=$(awk '/^```text$/ { b = 1; next } b && /^```$/ { b = 0; next } b && NF { sub(/^ +/, ""); print }' README.md | while IFS= read -r l; do $G -qxF -- "$l" .harness/printed.txt || printf '%s\n' "$l"; done | head -3 | cut -c1-160 | paste -sd';' -)
[ "$($G -c '^```text$' README.md)" -gt 0 ] && [ -z "$TX" ] || die "R.302: README.md's text blocks must be lines the runs printed - not printed: ${TX:-no text block}"
echo "  R.302: README.md's $($G -c '^```text$' README.md) text blocks - every line one the runs printed"
VS="the values the video may say: on PostgreSQL 18.6 and H2 2.5.250, Spring Boot 4.1.2, Spring Framework 7.0.10, Spring Data JDBC 4.1.2, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final, Flyway 12.4.0 - $VALS"
printf '%s\n' "$VS" > .harness/values.txt
$G -qF -- "$VS" README.md || die "README.md does not state the values these captures give - a typed value (the line is in .harness/values.txt): $($G -oE 'the values the video may say: [^*`]*' README.md | head -1 | cut -c1-200)"
echo "  README.md states the captures' values (.harness/values.txt, $(wc -c < .harness/values.txt | tr -d ' ') bytes)"
# hygiene
for f in .harness/raw-* .harness/rawpw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the token or the password ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/SOLUTION.md receipts.md5 .harness/*.log; do [ "$(raw "$TOKEN" "$f")" = 0 ] && [ "$(raw "$PW" "$f")" = 0 ] || die "$f holds the token or the password, raw"; done
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$LOGS" -gt 0 ] && [ "$PGDBS" -gt 0 ] || die "no JVM ran, or no PostgreSQL database was made"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -vE '^    [-+<>]' "$f" | $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) |Time elapsed|time="| in [0-9.]+ seconds|Total time' "$f" || die "$f holds Boot's process line, a time or Boot's seconds"
  ! $G -qE '^ *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][T ]|"timestamp":"?[0-9]|[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9]|(exec|handler|task)-[0-9]|started on [A-Z]' "$f" || die "$f holds a log time, a timestamp or a thread number"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64|musl|Debian|pgdg' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'execution time [0-9]|[0-9] ms\b|[0-9]+ ms\)|PT[0-9]' "$f" || die "$f holds Flyway's execution time, a scan time or a millisecond figure, unmasked"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'password=[^<*]' "$f" || die "$f holds a password in a URL"
  ! $G -oE 'https?://[^ /]*' "$f" | $G -qvxE 'http://127\.0\.0\.1:2041[0-9]|http://localhost' || die "$f holds a URL (only TiffinBox's own loopback ports may appear)"; done
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ (])java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned"
  ! $G -E '^ *\$ .*(^|[ (])java -D' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM without its alarm (R.247)"
  ! $G -E '^ *\$ .*(^|[ (])mvn ' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a Maven without its alarm (R.247)"
  ! $G -E '^ *\$ .*docker ' "$f" | $G -vF -- 'docker -H "$DH" ' > /dev/null || die "$f calls docker without the pinned socket (R.344)"; done
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness (R.195)"
echo "  hygiene: raw token and password copies after mask: 0 in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, $(ls .r-*.out | wc -l | tr -d ' ') captures and every log ($LOGS JVM logs; $PGDBS fresh PostgreSQL databases, each dropped after its JVMs); no path, unit number, time, millisecond figure, execution time, thread number, OS token, password, URL or stack frame in any capture; every JVM pinned and under its alarm; no H2 file"
# ---- the end: the container and its volume, Testcontainers, the anchor, the ports ----------------------------------------------
pgrm; [ -z "$(dk ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "the container $CN is still there"
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container is still there"
VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' '); IMGS1=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -); RY1=$(dk images --format '{{.Repository}}' 2> /dev/null | $G -c ryuk || true)
[ "$VOL1" = "$VOL0" ] || die "R.322: the volume count moved, $VOL0 -> $VOL1 - a container left its volume (an rm -f without -v)"
[ "$IMGS1" = "$IMGS0" ] && [ "$RY1" = 0 ] || die "the images moved over this run, or an image named ryuk appeared ($RY1) - nothing may be pulled"
[ ! -e "$HOME/.testcontainers.properties" ] || die "R.318: ~/.testcontainers.properties appeared over this run"
echo "  docker at the end: the container removed with its volume (rm -fv), Testcontainers containers 0; volumes $VOL0 -> $VOL1 (R.322); images $NI0, the same list, images named ryuk $RY1 (nothing pulled); ~/.testcontainers.properties absent"
beforetree end; anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 20410-20419 at the end - TiffinBox bound 20410, 20415 and 20416 in turn and stopped, the container 20411 and removed; the dup copy stopped before binding 20414; 20412, 20413 and 20417-20419 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c8-unit02: every capture 3/3 and = published; every spoken number asserted; 0 raw tokens, 0 raw passwords; the volume count unchanged; no port bound but 20410, 20411, 20415 and 20416"
