#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Capstone: TiffinBox on Postgres - this unit's receipts. Section 7's capstone and Course 7's last change to the anchor
# (brief flag 1, C3): before is the link to ../c7-unit38/after (its tree's hash pinned), after/ is this unit's tree - Course 7's
# final anchor - and ../c7-tiffinbox equals after/ from this unit's commit on. tiffinbox-web gains PostgreSQL's driver at run time,
# the data slice's test starter and Testcontainers in test scope, a second Surefire execution (container-tests, at
# integration-test) for the *IT classes, slice/DataSlice and CustomerEntityRepositoryIT (three tests on PostgreSQL in a container);
# CustomerEntityRepository gains findFirst10ByOrderByNameAsc(ScrollPosition). Six captures, each run three times and hashed; a hash
# that differs from receipts.md5 stops the run; every number and string the video says is asserted right after its capture by
# harness/chk39.py, against another witness of the same run - psql in this run's container, Surefire's two report folders, the
# test's own JdbcTemplate - never against a typed figure.
#   anchor    TiffinBox on PostgreSQL with its own driver (the harness adds none): B = before/'s jar on the config tree's URL
#             (20180, refused: no driver), A = after/'s jar on a fresh database, two JVMs in turn (20181, 20182) with psql between
#             them, its EntityManagerFactory's ddl-auto; A' = the default java -jar on H2 in memory, two JVMs (20183)
#   dev       the dev profile on a COPY of after/compose.yaml (project c7u39-dev, PostgreSQL on 127.0.0.1:20187), TiffinBox from
#             Maven's class path (20186), two JVMs, then the copy's project down -v
#   tests     mvn verify under the Testcontainers recipe (18 + 3, two report folders), mvn package and mvn verify with Maven's
#             DOCKER_HOST pointed at nothing, and the two counter plants on scratch copies of the IT
#   seven     the comparison set on before/ and after/ over H2's TCP server (20184), and on after/ on PostgreSQL (20185)
#   xcheck    Hibernate's DDL script over after/'s libraries without Flyway's three jars, against ../c7-unit38/xcheck.sql
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# Every tree is COPIED under .harness/ and built there, never in place, offline. Every JVM and every Maven run runs under an alarm
# (perl -e 'alarm N; exec ...'; R.247). Every docker call names its socket (docker -H "$DH", R.332); a container is removed with
# its volume (rm -fv, compose down -v) and the volume count is asserted unchanged (R.322). Testcontainers: DOCKER_HOST and
# TESTCONTAINERS_RYUK_DISABLED exported after the pre-flight, user.home a folder under .harness/ (R.318). Ports (20180-20189):
# 20180 B · 20181-20182 A · 20183 A' · 20184 the H2 TCP server · 20185 the seven's TiffinBox · 20186 the dev profile's TiffinBox ·
# 20187 the compose copy's PostgreSQL · 20188 this run's container · 20189 never bound; Testcontainers' port is OrbStack's, read
# off each run and masked. Nothing leaves the machine.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c7u39-pg
DPJ=c7u39-dev
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.332): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
pid=""; tpid=""; mpid=""; xpid=""; spid=""; CSTARTED=""; DSTARTED=""; TC0=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.u.") || index($0, "probe.x.") || index($0, "org.h2.tools.") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "curlset.sh") || index($0, "surefirebooter") || $3 ~ /(^|\/)javac$/ || index($0, "jdk.compiler/com.sun.tools.javac") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "exec c7u39-pg") || index($0, "--name c7u39-pg") || index($0, "compose")) { print $1 }' | paste -sd' ' -) || l=""
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
# dcdown: the compose copy's project, with its named volume
dcdown() { [ -n "$DSTARTED" ] || return 0
  dk compose -p "$DPJ" -f "$U/.harness/dev/compose.yaml" down -v > /dev/null 2>&1 || true
  echo "  the trap: the compose copy's project $DPJ taken down with its volumes (down -v)" >&3; DSTARTED=""; }
trap 'trap "" INT TERM; exec 4>&- 2> /dev/null; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$tpid" "$mpid" "$xpid" "$spid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; pgrm; tcrm; dcdown; find .harness -path "*/secrets/tiffinbox/jdbc-url" -delete 2> /dev/null || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp find curl openssl docker git unzip /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY FLYWAY_CANARY TESTCONTAINERS_CANARY PGPASSWORD PGOPTIONS PGHOST PGUSER DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS MAVEN_OPTS DOCKER_HOST DOCKER_CONTEXT; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|FLYWAY_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - the token and the password live under .harness/ only"
# ---- docker: the pinned socket and non-empty baselines before any comparison (R.332), the volume count (R.322), Ryuk (R.318) -----
dk info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that socket? (R.332: every docker call names its socket)"
IMGS0=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -); NI0=$(printf '%s\n' "$IMGS0" | wc -w | tr -d ' ')
VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI0" -ge 1 ] && [ "$VOL0" -ge 1 ] || die "R.332: the baselines must not be empty - images $NI0, volumes $VOL0 on $DH (an empty list compares equal to anything)"
dk image inspect "$IMG" > /dev/null 2>&1 || die "the image $IMG is not on this machine - pull it once yourself (this script never pulls)"
RY0=$(dk images --format '{{.Repository}}' 2> /dev/null | $G -c ryuk || true)
[ "$RY0" = 0 ] || die "R.318: an image named ryuk is on this machine ($RY0) - this unit asserts none before and after (Ryuk stays off)"
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container (label org.testcontainers=true) exists before the run - an interrupted run's? remove it with its volume: docker -H \"\$DH\" rm -fv <id>"
TC0=1
[ ! -e "$HOME/.testcontainers.properties" ] || die "R.318: ~/.testcontainers.properties exists - this unit's Testcontainers JVMs read a receipt home under .harness/ only; move yours aside for the run"
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · info exit 0 · images $NI0 · volumes $VOL0 (the baselines, both non-empty) · the image: $IMG is present (never pulled) · images named ryuk: $RY0 · Testcontainers containers: 0 · ~/.testcontainers.properties: absent"
# ---- the trees ------------------------------------------------------------------------------------------------------------
[ -L before ] && [ "$(readlink before)" = ../c7-unit38/after ] || die "before must be the link to ../c7-unit38/after - the anchor before this change"
[ -d after ] && [ ! -L after ] || die "after/ must be this unit's own tree, not a link"
for t in before after; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] || die "the tree $t (its pom.xml or README.md) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/hibernate-ddl.sql" ] && die "$t holds a secrets/, a target/ or a hibernate-ddl.sql - it is a frozen copy, never built in place"
  true; done
T38='45 852102f50b6e4827c18d5e88540e9721'            # unit 38's after/ at its commit 5266441: 45 files (harness/tree39.py)
beforetree() { local t; t=$(python3 -I harness/tree39.py before/) || die "before/'s tree could not be hashed"
  [ "$t" = "$T38" ] || die "R.211: before/ (../c7-unit38/after, a shipped unit's frozen tree) is not the tree this unit changed: $t, pinned $T38"
  echo "  before/'s tree ($1): python3 -I harness/tree39.py before/ -> $t = pinned (unit 38's after/, Section 6's last anchor)"; }
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c7-tiffinbox: empty - after/ = ../c7-tiffinbox"
  else echo "  (after/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit froze: $(printf '%s\n' "$d" | head -3 | paste -sd';' -))" >&3
    echo "  the anchor ($1): after/ is this unit's tree (C3) - a later change has moved ../c7-tiffinbox on"; fi; }
beforetree start; anchornote start
M2="$PWD/.m2-demo"
TH="$PWD/.harness/home"                               # the receipt home: the user.home of every Testcontainers JVM (R.318), given to
                                                      # Maven as ../home and to Surefire's fork as ../../home (each JVM's own folder): a
                                                      # path with a space survives neither MAVEN_OPTS nor argLine
CJ=tiffinbox-core/src/main/java/com/tiffinbox
TJ=tiffinbox-web/src/test/java
IT=$TJ/com/tiffinbox/CustomerEntityRepositoryIT.java
MG=tiffinbox-core/src/main/resources/db/migration
YM=tiffinbox-web/src/main/resources/application.yaml
SR=tiffinbox-web/target/surefire-reports
SRI=tiffinbox-web/target/surefire-reports-it
XD=tiffinbox-web/target/extracted
TF=secrets/tiffinbox/shutdown-token
UF=secrets/tiffinbox/jdbc-url
CURLSET=../c5-unit11/curlset.sh
[ -x "$CURLSET" ] || die "$CURLSET is missing - the comparison set the seven runs"
HFILES='chk39.py dur7.py logback.xml s39.py src surefire.py tree39.py'
SFILES='probe/u/Db.java probe/u/Emf.java probe/u/U.java probe/x/XMain.java'
for f in exercise/README.md exercise/SOLUTION.md exercise/CountersTest.java README.md receipts.md5 xcheck.sql pinned.txt; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'CountersTest.java README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
cmp -s harness/src/probe/x/XMain.java ../c7-unit29/harness/src/probe/x/XMain.java || die "harness/src/probe/x/XMain.java is not unit 29's, byte for byte"
cmp -s harness/surefire.py ../c6-unit28/harness/surefire.py || die "harness/surefire.py is not the testing lesson's, byte for byte"
cmp -s harness/tree39.py ../c7-unit33/harness/tree33.py || die "harness/tree39.py is unit 33's tree33.py, byte for byte"
cmp -s xcheck.sql ../c7-unit38/xcheck.sql || die "xcheck.sql must be unit 38's, byte for byte (C3 moves no mapping)"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 20180 20181 20182 20183 20184 20185 20186 20187 20188 20189"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
[ -z "$(dk ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "a container named $CN exists - an interrupted run's? remove it with its volume (rm -fv, on the pinned socket)"
[ -z "$(dk ps -aq --filter "label=com.docker.compose.project=$DPJ" 2> /dev/null)$(dk volume ls -q --filter "name=^${DPJ}_" 2> /dev/null)" ] || die "the compose copy's project $DPJ has a container or a volume - an interrupted run's? docker -H \"\$DH\" compose -p $DPJ down -v"
rm -rf .harness; mkdir -p .harness/run .harness/hc .harness/secrets .harness/home .harness/dev
echo "  ports: 20180-20189 free at the start (and 18425, 8080, 35729)"

# ---- the prose gates ----------------------------------------------------------------------------------------------------------
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s39.py harness/dur7.py $PROSE) || die "the prose gate did not run (or its self-test failed)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
echo "  prose, per sentence (s39, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test): dur7 words 0 · S4.7's family 0 · R.301's family 0 but beside a printed count · R.190 the tests as a witness 0 · R.224 a call-back without its title 0 · R.335 TiffinBox on PostgreSQL unscoped 0 · RED #1807 Kavya stays, unscoped, 0 · R.334 the tests said to need Docker, unscoped, 0 · R.321 a typed test count 0 · R.320 the query counter shipped 0 · R.319 a raw port 0 · R.325 tiffinbox.jdbc-url said to be the database used 0 · \"Hibernate generates\" 0 · R.302 a typed count, hash or jar count 0 - over README.md and exercise/"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
dishes() { $G -rniwE -- "$DISH" "$@" 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true; }
DN=$(dishes README.md exercise harness after/$MG after/$TJ)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, any case, over README.md, exercise/, harness/, the migrations and the tests)"
PH=$($G -rnE 'EXERCISE-[A-Z-]*OUTPUT|[A-Z]+-OUTPUT\b|[A-Z]+-PARAGRAPH\b|TODO|TBD|PLACEHOLDER|\bPROBE U39\b|\bRESUME\b' README.md exercise after 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder line in this unit's prose or tree: $PH"
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f" | $G -v '^ *$' || true)" ] || die "$f must hold one \"What it prints\" line and, under it, a block that is not empty"; done
echo "  placeholders: 0 · each exercise file's \"What it prints\" block not empty"
prose() { awk -v f="$1" '/^<!-- (values|cells): begin -->$/ { v = 1; next } /^<!-- (values|cells): end -->$/ { v = 0; next } /^```/ { b = !b; next } !v && !b { print f ":" NR ": " $0 }' "$1"; }
SQLRE='where ce1_0\.name>\?|fetch first \? rows|select ce1_0\.|create table customer|from customer ce1_0'
TS=$(for f in $PROSE; do prose "$f"; done | $G -E "$SQLRE" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string in the prose (R.225): $TS"
TNRE='\b[0-9]+ (history rows|rows in the history|migrations applied|SQL lines|libraries|jars|rows|words|tests in all|windows)\b|f4f1''5b9c|466c''20ed|[0-9a-f]{32}|\b3[0-9]{4}\b'
TN=$(for f in $PROSE; do prose "$f"; done | $G -E "$TNRE" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TN" ] || die "R.302/R.319: a count, a printed md5 or a port number typed in the prose, outside a block a run printed and the values block: $TN"
TC=$($G -nE 'f4f1''5b9c|466c''20ed' receipts.sh harness/chk39.py harness/src/probe/*/*.java 2> /dev/null | cut -c1-120 | head -3 | paste -sd';' - || true)
[ -z "$TC" ] || die "R.302: a printed md5 typed in this script or the harness: $TC"
echo "  typed SQL strings 0 · R.302/R.319: history-row, migration, SQL-line, library, row, word and window counts, md5s and five-digit port numbers typed 0 times in the prose (outside printed blocks and the values block), and 0 md5s in receipts.sh, chk39.py and the harness's sources"

# ---- static checks of this script, the harness and the shipped tests - before anything runs -------------------------------------
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
DK=$($G -v '^ *#' receipts.sh | $G -nE '\bdocker (run|exec|rm|ps|port|info|images|volume|image|pull|events|compose)\b' | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.332: receipts.sh calls docker without the pinned socket (every call is dk, or a README line with -H \"\$DH\"): $DK"
! $G -v '^ *#' receipts.sh | $G -qE 'rm -f'' "?(\$CN|\$c\b)|rm -f'' c7u39|down( -p [^ ]+)?$' || die "R.322: receipts.sh removes a container without its volume (rm -fv, down -v)"
! $G -rqE 'Thread\.sleep|while *\(true\)|TimeUnit\.[A-Z]+\.sleep|LockSupport\.park' harness/src || die "a harness sleeps or polls (S4.18)"
! $G -rqE 'probe\.[a-z]|\bPROBE\b|\bRED ' after/tiffinbox-web after/tiffinbox-core || die "the anchor's code names the course's harness, a probe or RED"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
ST=$(python3 -I -B harness/chk39.py static after ../c7-unit30/pinned.txt pinned.txt ../c7-unit06/README.md ../c7-unit36/README.md) || die "the shipped test or its pom: $(printf '%s\n' "$ST" | $G -v '^ok' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | sed 's/^/  /'
echo "  static: no kill by name; every docker call on the pinned socket (R.332); containers removed with their volumes (R.322); no sleep in the harness; no harness name, probe or RED in the anchor"

# ---- R.250: C3 and every sentence it makes false - a gate before any build --------------------------------------------------------
R250=$(python3 -I -B harness/chk39.py r250 after before) || die "R.250: $(printf '%s\n' "$R250" | $G -v '^ok' | head -3 | paste -sd';' -)"
printf '%s\n' "$R250" | sed 's/^/  /'

# ---- the commands: read from after/README.md, the anchor's own, and from this README ----------------------------------------
readme() { $G -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_VERIFY=$(readme 'mvn -B verify')
R_DH=$(readme 'export DOCKER_HOST=unix://$HOME/.orbstack/run/docker.sock')
R_RYUK=$(readme 'export TESTCONTAINERS_RYUK_DISABLED=true')
R_CPB=$(readme 'mvn -B package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt')
R_DEV=$(readme 'java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.profiles.active=dev')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_TOKEN=$(readme 'mkdir -p secrets/tiffinbox && (umask 077 && printf '"'"'%s\n'"'"' "$(openssl rand -hex 16)" > secrets/tiffinbox/shutdown-token)')
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 240; exec @ARGV'"
ML="perl -e 'alarm 600; exec @ARGV'"
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*\" harness/src/probe/u/U.java harness/src/probe/u/Db.java harness/src/probe/u/Emf.java harness/src/probe/x/XMain.java")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../\$LIBS/*\" \$MC \"\${A[@]}\"")
L_EMF=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:$XD/tiffinbox-web-1.0.0.jar:$XD/lib/*\" probe.u.Emf --logging.config=../../harness/logback.xml --logging.level.org.hibernate.orm.core=info --spring.main.banner-mode=off")
L_H2S=$(mine "cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' java $JL -Dh2.bindAddress=127.0.0.1 -cp \"../after/$XD/lib/h2-2.5.250.jar\" org.h2.tools.Server -tcp -tcpPort 20184 -ifNotExists")
L_H2Q=$(mine "$AL java $JL -cp \"../hc:../after/$XD/lib/h2-2.5.250.jar\" probe.u.Db \"jdbc:h2:tcp://127.0.0.1:20184/mem:\$DB;DB_CLOSE_DELAY=-1\" \$OP \"\$Q\"")
L_RUN=$(mine "docker -H \"\$DH\" run -d --pull never --name $CN -p 127.0.0.1:20188:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v \"\$U/.harness/secrets/pgpw:/run/pgpw:ro\" $IMG")
L_READY=$(mine "docker -H \"\$DH\" exec $CN pg_isready -U sa -h 127.0.0.1 -q")
L_DB=$(mine "docker -H \"\$DH\" exec $CN psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c \"drop database if exists \$DB with (force)\" -c \"create database \$DB\"")
L_DROP=$(mine "docker -H \"\$DH\" exec $CN psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c \"drop database \$DB with (force)\"")
L_PSQL=$(mine "docker -H \"\$DH\" exec $CN psql -U sa -d \"\$DB\" -qAt -v ON_ERROR_STOP=1 -c \"\$Q\"")
L_SQL=$(mine "$R_RUN --logging.level.org.hibernate.SQL=debug")
L_MVNTC=$(mine "env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" $ML mvn -o -B -Dmaven.repo.local=\"\$M2\" \"-DargLine=$JL -Dstdout.encoding=UTF-8 -Duser.home=../../home\" clean verify")
L_NODH=$(mine "env DOCKER_HOST=tcp://127.0.0.1:1 \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" $ML mvn -o -B -Dmaven.repo.local=\"\$M2\" \"-DargLine=$JL -Dstdout.encoding=UTF-8 -Duser.home=../../home\" clean \$GOAL")
L_DCDOWN=$(mine "docker -H \"\$DH\" compose -p $DPJ -f .harness/dev/compose.yaml down -v")
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java '*) l="$AL java $JL ${l#java }" ;; esac; l=${l/java $JL $JL /java $JL }; printf 'cd %s && %s\n' "$1" "$l"; }
[ "$(off .harness/after "$R_PLAIN" package)" = 'cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "off(): the build line is not the README's package line, offline"
[ "$(off .harness/tests "$R_VERIFY" verify)" = 'cd .harness/tests && mvn -o -B -Dmaven.repo.local="$M2" clean verify' ] && [ "${L_MVNTC##*clean }" = verify ] || die "the tests' Maven line is not the README's verify line, offline"
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
copy before .harness/before; copy after .harness/after
mbuild "$(off .harness/before "$R_PLAIN" package) -DskipTests" .harness/build-before.log ".harness/before (before/, the README's package line, -DskipTests: unit 38 counted its tests)"
mbuild "$(off .harness/after "$R_CPB" package) -DskipTests" .harness/build-after.log ".harness/after (after/, Course 5's package + build-classpath line - the dev capture's class path -, -DskipTests: the tests capture runs them)"
for t in before after; do [ "$(summ4 .harness/build-$t.log)" = '0 0 0 0' ] || die "$t: tests ran in a -DskipTests build"; done
[ -s .harness/after/tiffinbox-web/target/classpath.txt ] || die "Maven's class path for the dev profile was not written"
for t in before after; do (cd .harness/$t && eval "$R_EXTRACT") > .harness/extract-$t.log 2>&1 < /dev/null || die "the extract of $t failed: $(tail -3 .harness/extract-$t.log)"; done
for a in org/springframework/boot/spring-boot-dependencies/4.1.2/spring-boot-dependencies-4.1.2.pom org/flywaydb/flyway-core/12.4.0/flyway-core-12.4.0.jar com/h2database/h2/2.5.250/h2-2.5.250.jar org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar org/testcontainers/testcontainers/2.0.5/testcontainers-2.0.5.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
[ ! -e "$M2/org/apache/maven/plugins/maven-failsafe-plugin" ] || die "maven-failsafe-plugin is in .m2-demo - the course's seed holds none (this unit uses Surefire's second execution)"
LIB=after/$XD/lib
mkdir -p .harness/lib-nofly
for j in $(ls .harness/$LIB); do case $j in flyway-*|spring-boot-flyway-*) ;; *) ln -s ../$LIB/$j .harness/lib-nofly/$j ;; esac; done
(cd .harness/after && eval "$R_TOKEN") || die "the token was not written"
TOKEN=$(head -n 1 .harness/after/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
for t in before dev; do mkdir -p .harness/$t/secrets/tiffinbox && (umask 077 && cp .harness/after/$TF .harness/$t/$TF); done
for t in before after dev; do [ "$(stat -f '%Lp' .harness/$t/$TF)" = 600 ] || die "the token's file in $t must be mode 0600"; done
jc "$L_JAVAC" .harness/javac.log; [ "$JE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
echo "  extracted two jars; xcheck's class path: after/'s lib/ without Flyway's three jars; the harness compiled once (.harness/hc, $(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes); the token generated (the README's line), copied into before's and dev's $TF, mode 0600, never printed"
# the H2 TCP server: one JVM for this run, loopback only
echo "\$ $L_H2S" >&3
(eval "$L_H2S") > .harness/h2server.log 2>&1 < /dev/null & spid=$!
i=0; while [ $i -lt 120 ] && [ "$(listeners 20184)" = 0 ]; do kill -0 "$spid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
[ "$(listeners 20184)" = 1 ] || { cat .harness/h2server.log >&3; die "the H2 server never listened on 20184"; }
[ "$(lsof -nP -a -p "$spid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)" = '127.0.0.1:20184' ] || die "the H2 server must listen on 127.0.0.1:20184 alone"
H2SL=$($G -m1 'TCP server running at' .harness/h2server.log || true); [ "$H2SL" = 'TCP server running at tcp://localhost:20184 (only local connections)' ] || die "the H2 server's line: ${H2SL:-none}"
echo "  the H2 server: $H2SL - listens on 127.0.0.1:20184 alone"
# the container: PostgreSQL 18 from the pinned image, loopback only, a generated password in a 0600 file (R.214)
(umask 077 && LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom 2> /dev/null | head -c 24 > .harness/secrets/pgpw) || true
[ "$(wc -c < .harness/secrets/pgpw | tr -d ' ')" = 24 ] && [ "$(stat -f '%Lp' .harness/secrets/pgpw)" = 600 ] || die "the password file was not written, 24 characters, mode 0600"
PW=$(cat .harness/secrets/pgpw)
CSTARTED=1
(eval "$L_RUN") > .harness/docker-run.log 2>&1 < /dev/null || die "the container did not start: $(tail -2 .harness/docker-run.log)"
i=0; while ! (eval "$L_READY") > /dev/null 2>&1 < /dev/null; do i=$((i + 1)); [ $i -lt 120 ] || die "the container did not accept connections within its cap (120 tries, 0.5 apart)"; sleep 0.5; done
DP=$(dk port "$CN" 2> /dev/null | paste -sd'|' -)
[ "$DP" = '5432/tcp -> 127.0.0.1:20188' ] || die "the container must publish 5432 on 127.0.0.1:20188 alone: $DP"
echo "  the container: $CN from $IMG (--pull never); its published port: $DP; user sa, the password generated into .harness/secrets/pgpw (24 characters, mode 0600, never printed); pg_isready after $i tries (cap 120)"
# the receipt home for Testcontainers (R.318): two keys, no ryuk.* key
printf '%s\n' 'checks.disable=true' "tinyimage.container.image=$IMG" > .harness/home/.testcontainers.properties

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C $G -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; PGDBS=0; TCJVM=0
: > .harness/tcports
mask() { awk -v t="$TOKEN" -v pw="$PW" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v pf="$U/.harness/tcports" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); W = lit(pw); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)"
          np = 0; while ((getline l < pf) > 0) if (l ~ /^[0-9]+$/) tp[++np] = l; close(pf) }
  { gsub(T, "[masked: the token]"); gsub(W, "<pw>"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    for (k = 1; k <= np; k++) { gsub("localhost:" tp[k], "localhost:<port>"); gsub("127\\.0\\.0\\.1:" tp[k], "127.0.0.1:<port>") }
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>"); gsub(/PROBE version: Java [0-9][0-9.]+/, "PROBE version: Java <version>")
    gsub(/\(execution time [0-9:.]+s\)/, "(execution time <t>)")
    gsub(/ started in PT[0-9.]+S/, " started in PT<t>S")
    gsub(/\$\$Lambda\/0x[0-9a-f]+/, "$$Lambda/<n>")
    gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"<time>\"")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 54321 > .harness/tcports
printf '%s\n' 'Starting Main using Java 25.0.4.1' "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' "token $TOKEN" "url jdbc:postgresql://127.0.0.1:20188/u39?user=sa&password=$PW" 'Successfully applied 3 migrations to schema "public", now at version v3 (execution time 00:00.026s)' 'IT the database: jdbc:postgresql://localhost:54321/test?loggerLevel=OFF' 'Container postgres started in PT3.48S' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting Main using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'token [masked: the token]' 'url jdbc:postgresql://127.0.0.1:20188/u39?user=sa&password=<pw>' 'Successfully applied 3 migrations to schema "public", now at version v3 (execution time <t>)' 'IT the database: jdbc:postgresql://localhost:<port>/test?loggerLevel=OFF' 'Container postgres started in PT<t>S')" ] || die "mask: the planted JDK version, folders, home, identity hash, the token, the password, Flyway's execution time, a Testcontainers port and its start time must be masked"
echo "  mask: its self-test passed (the token, the password, folders, home, identities, Flyway's execution time - R.264 -, a Testcontainers port read off a run - R.319 - and its start time); raw password copies after mask: $(mask < .harness/p1 | $G -cF -- "$PW" || true)"
: > .harness/tcports; rm -f .harness/p1
pgdb() { local DB=$1; echo "\$ DB=$DB; $L_DB"; (eval "$L_DB") > .harness/pgdb.log 2>&1 < /dev/null || die "the fresh database $DB was not made: $(tail -2 .harness/pgdb.log)"
  PGDBS=$((PGDBS + 1)); echo "  a fresh database: $DB"; }
pgdrop() { local DB=$1; echo "\$ DB=$DB; $L_DROP"; (eval "$L_DROP") > .harness/pgdb.log 2>&1 < /dev/null || die "the database $DB was not dropped: $(tail -2 .harness/pgdb.log)"
  echo "  dropped: $DB · the u39 databases left: $(dk exec "$CN" psql -U sa -d postgres -qAt -c "select coalesce(string_agg(datname, ', '), '(none)') from pg_database where datname like 'u39%'" 2> /dev/null)"; }
PDB=""
rd() { local Q=$1 DB=$PDB e=0; (eval "$L_PSQL") > .harness/rd.out 2>&1 < /dev/null || e=$?
  [ "$e" = 0 ] || { cat .harness/rd.out >&3; die "psql failed (exit $e)"; }
  sed 's/^/    /' .harness/rd.out; }
h2drop() { local DB=$1 OP=drop Q="" c e=0; c=$(printf 'cd .harness/run && %s\n' "$L_H2Q"); echo "\$ DB=$DB; OP=drop; $c"
  (eval "$(exe "$c")") > .harness/rd.out 2>&1 < /dev/null & xpid=$!; wait "$xpid" || e=$?; xpid=""
  [ "$e" = 0 ] || { cat .harness/rd.out >&3; die "the H2 database $DB could not be shut down"; }
  sed 's/^/  /' .harness/rd.out; }
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
  o=$(python3 -I -B harness/chk39.py "$nm" "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' | tee .harness/chk-$nm.out || true
  [ $e = 0 ] || die "$nm: its check failed (harness/chk39.py, above)"
  VALS="$VALS${VALS:+ · }$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }

# ---- TiffinBox: start, wait, ask, stop ---------------------------------------------------------------------------------------
first() { $G -m1 -E ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//; s/ using Java [0-9][0-9.]*/ using Java <version>/'; }
sec() { local s; s=$(cd "$1/secrets" 2> /dev/null && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)
  [ "$s" = "${2:-tiffinbox/shutdown-token}" ] || die "$1/secrets holds other files than expected (${s:-nothing})"
  echo "  secrets/ before the start: $s (mode $(cd "$1/secrets" && find . -type f | sort | while read -r f; do stat -f '%Lp' "$f"; done | paste -sd' ' -))"; }
dir() { printf '%s\n' "$1" | sed -n 's/^cd \([^ ]*\) && .*/\1/p'; }
start() { [ "$(listeners "$2")" = 0 ] || die "something listens on $2 before the start"; sec "$(dir "$1")" "${3:-}"; echo "\$ $1"; : > .harness/run.out; (eval "$(exe "$1")") >> .harness/run.out 2>&1 < /dev/null & pid=$!; }
addrs() { lsof -nP -a -p "$1" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
up() { local a="" i=0
  while [ $i -lt 480 ]; do a=$(addrs "$pid"); case " $a " in *":$1 "*) break ;; esac; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  case " $a " in *":$1 "*) ;; *) tail -20 .harness/run.out | mask >&3; die "it never listened on $1" ;; esac
  echo "  listens on: $a"; echo "  Boot's first line: $(first .harness/run.out)"; }
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
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 240 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; }
logtok() { local t w; t=$(raw "$TOKEN" .harness/run.out); w=$(raw "$PW" .harness/run.out); LOGS=$((LOGS + 1)); [ "$t" = 0 ] || die "a TiffinBox log held the token ($t)"; [ "$w" = 0 ] || die "a TiffinBox log held the password, raw ($w)"; echo "  its log: the token 0 times, the password 0 times (raw, before the mask)"; }
flylines() { $G -E ' o\.f\.[A-Za-z.]+ +: ' .harness/run.out | sed -E 's/^.* (INFO|WARN|ERROR) .* o\.f\.[A-Za-z.]+ +: /\1 /; s/[[:space:]]+$//' | mask | sed 's/^/  Flyway: /'
  echo "  its log, read off: org.flywaydb lines $($G -cE ' o\.f\.[A-Za-z.]+ +: ' .harness/run.out || true) · HHH000001 lines $($G -c 'HHH000001: Hibernate ORM core version 7.4.13.Final' .harness/run.out || true) · ERROR lines $($G -cE '^[^ ]+ +ERROR ' .harness/run.out || true)"; }
lines() { wc -l < .harness/run.out | tr -d ' '; }
settle() { local a b i=0; a=$(lines); while [ $i -lt 20 ]; do sleep 0.25; b=$(lines); [ "$a" = "$b" ] && break; a=$b; i=$((i + 1)); done; }
U39M=U39MARK
mark() { printf '%s %s\n' "$U39M" "$1" >> .harness/run.out; }
seg() { awk -v a="$U39M $1 start" -v b="$U39M $1 end" '$0 == a { f = 1; next } $0 == b { f = 0 } f' .harness/run.out; }
rq() { local l=$1 p=$3 ac=$4 code
  mark "$l start"; echo "\$ curl -s --noproxy '*' -H 'Accept: $ac' http://127.0.0.1:$p$2"
  code=$(curl -s --noproxy '*' -o .harness/body-$l -w '%{http_code}' -H "Accept: $ac" "http://127.0.0.1:$p$2" 2> /dev/null || true)
  settle; mark "$l end"; seg "$l" > .harness/seg-$l.log
  echo "  -> $code · the request's org.hibernate.SQL lines, between its two markers: $($G -cE ' org\.hibernate\.SQL +: ' .harness/seg-$l.log || true) · WARN lines: $($G -cE '^[^ ]+ +WARN ' .harness/seg-$l.log || true) · ERROR lines: $($G -cE '^[^ ]+ +ERROR ' .harness/seg-$l.log || true)"; }
kavya() { local p=$1 code
  echo "\$ curl -s --noproxy '*' -H 'Content-Type: application/json' -d '{\"name\":\"Kavya\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:$p/customers"
  code=$(curl -s --noproxy '*' -o .harness/body-k -w '%{http_code}' -H 'Content-Type: application/json' -d '{"name":"Kavya","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' "http://127.0.0.1:$p/customers" 2> /dev/null || true)
  echo "  -> $code $(cat .harness/body-k)"; }
see() { local p=$1 code
  echo "\$ curl -s --noproxy '*' -H 'Accept: application/json' http://127.0.0.1:$p/customers/Kavya"
  code=$(curl -s --noproxy '*' -o .harness/body-s -w '%{http_code}' -H 'Accept: application/json' "http://127.0.0.1:$p/customers/Kavya" 2> /dev/null || true)
  echo "  -> $code $(sed -E 's/"timestamp":"[^"]*"/"timestamp":"…"/' .harness/body-s)"
  code=$(curl -s --noproxy '*' -o .harness/body-l -w '%{http_code}' -H 'Accept: application/json' "http://127.0.0.1:$p/customers" 2> /dev/null || true)
  echo "\$ curl -s --noproxy '*' -H 'Accept: application/json' http://127.0.0.1:$p/customers"
  echo "  -> $code · customers listed: $($G -o '"name":"[A-Za-z]*"' .harness/body-l | wc -l | tr -d ' ') ($($G -o '"name":"[A-Za-z]*"' .harness/body-l | sed 's/"name":"//; s/"$//' | paste -sd' ' -))"; }
pgurl() { (umask 077 && printf '%s' "jdbc:postgresql://127.0.0.1:20188/$2?user=sa&password=$PW" > .harness/$1/$UF); }
causes() { $G -E '^Caused by: ' .harness/run.out | sed -E 's/ defined in class path resource \[[^]]*\]//g' | awk '!s[$0]++' | cut -c1-230 | mask | sed 's/^/  /'; }

# ---- the captures --------------------------------------------------------------------------------------------------------
HQH='select installed_rank, version, description, type, script, installed_by, success from flyway_schema_history order by installed_rank'
NQ="select id || ' ' || name from customer order by id"
IQ="select column_name || ' ' || is_identity || ' ' || coalesce(identity_generation, '-') from information_schema.columns where table_name in ('customer', 'pause') and column_name = 'id' order by table_name"
anchor() { local d n
  echo "the change - after/ against before/ (diff -rq, the file names):"
  diff -rq before after | sed -E 's#^Files before/(.*) and after/.* differ$#  changed: \1#; s#^Only in before/(.*): (.*)$#  deleted: \1/\2#; s#^Only in after/(.*): (.*)$#  new: \1/\2#' | sort
  echo "  the YAML's lines, after/: $($G -E '^ +ddl-auto: |^  jdbc-url: ' after/$YM | sed 's/^ *//' | paste -sd' ' - | sed 's/ /; /2')"
  for t in before after; do n=$(ls .harness/$t/$XD/lib | wc -l | tr -d ' ')
    echo "  .harness/$t's jar, extracted - lib/: $n libraries · postgresql-*.jar: $(ls .harness/$t/$XD/lib | $G -cE '^postgresql-.*\.jar$' || true) ($(ls .harness/$t/$XD/lib | $G -E '^postgresql-.*\.jar$' || echo none)) · checker-qual-*.jar: $(ls .harness/$t/$XD/lib | $G -cE '^checker-qual-' || true) · testcontainers-*.jar: $(ls .harness/$t/$XD/lib | $G -cE '^testcontainers' || true)"; done
  d=$(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | sed -n 's/^< //p' | paste -sd' ' -)
  echo "  the libraries after/'s jar adds: $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | sed -n 's/^> //p' | paste -sd' ' -) · removes: ${d:-none}"
  echo "B - before/'s jar (the anchor before this change: no PostgreSQL driver in its lib/) on a fresh database u39b, its URL in its own config tree, secrets/tiffinbox/jdbc-url (mode 0600), port 20180 - java -jar, nothing added to its class path:"
  pgdb u39b; PDB=u39b; pgurl before u39b
  start "$(at .harness/before 20180 "$L_SQL") --logging.level.org.hibernate.orm.connections.pooling=warn" 20180 "tiffinbox/jdbc-url tiffinbox/shutdown-token"; gone 20180
  echo "  exit $LASTE · it listened on: nothing · ready: no · 'Failed to load driver class org.postgresql.Driver' lines in its log: $($G -c 'Failed to load driver class org.postgresql.Driver' .harness/run.out || true) · 'Application run failed': $($G -c 'Application run failed' .harness/run.out || true)"
  echo "  its log's Caused by lines, each once, in order (a bean's class path resource cut):"; causes
  echo "  psql - the database it was given: tables $(Q="select count(*) from information_schema.tables where table_schema = 'public'"; rd "$Q" | tr -d ' ')"
  logtok; rm -f .harness/before/$UF; pgdrop u39b
  echo "A - after/'s jar (its own driver: lib/ holds postgresql-42.7.14.jar) on a fresh database u39a, its URL in its own config tree, java -jar, nothing added to its class path - JVM 1, port 20181:"
  pgdb u39a; PDB=u39a; pgurl after u39a
  start "$(at .harness/after 20181 "$L_SQL") --logging.level.org.hibernate.orm.connections.pooling=warn" 20181 "tiffinbox/jdbc-url tiffinbox/shutdown-token"; up 20181; ready 20181; flylines
  echo "  psql - the history table:"; rd "$HQH"
  echo "  psql - the id columns (information_schema):"; rd "$IQ"
  kavya 20181
  rq html /dashboard 20181 text/html; rq json /dashboard 20181 application/json; echo "  its JSON: $(cat .harness/body-json)"
  stopit 20181; logtok
  echo "A - between the two JVMs, nothing running on u39a: psql - the customers:"; rd "$NQ"
  echo "A - JVM 2, the same jar, the same database, port 20182:"
  start "$(at .harness/after 20182 "$L_SQL") --logging.level.org.hibernate.orm.connections.pooling=warn" 20182 "tiffinbox/jdbc-url tiffinbox/shutdown-token"; up 20182; ready 20182; flylines
  see 20182
  stopit 20182; logtok
  echo "A - the anchor's own ddl-auto, read off its EntityManagerFactory: probe.u.Emf (TiffinBoxApp, no web server) in .harness/after, the same database (R.330):"
  start "$(printf 'cd .harness/after && %s\n' "$L_EMF")" 20182 "tiffinbox/jdbc-url tiffinbox/shutdown-token"; gone 20182; LOGS=$((LOGS + 1))
  awk '/^PROBE / || /^INFO +\[main\] org\.hibernate\.orm\.core : HHH000001/ || /^(INFO|WARN|ERROR) +\[main\] org\.flywaydb\./ { sub(/[ \t]+$/, ""); print "  " $0 }' .harness/run.out | mask
  echo "  exit $LASTE · its WARN lines: $($G -c '^WARN ' .harness/run.out || true) · its ERROR lines: $($G -c '^ERROR ' .harness/run.out || true)"; logtok
  echo "  psql - the history table at the end:"; rd "$HQH"
  rm -f .harness/after/$UF; pgdrop u39a
  echo "A' - the default: after/'s jar, java -jar, no URL in its config tree (application.yaml's tiffinbox.jdbc-url, H2 in memory), port 20183 - JVM 1:"
  start "$(at .harness/after 20183 "$R_RUN")" 20183; up 20183; ready 20183
  kavya 20183; stopit 20183; logtok
  echo "A' - JVM 2, the same jar, the same command, port 20183:"
  start "$(at .harness/after 20183 "$R_RUN")" 20183; up 20183; ready 20183
  see 20183; stopit 20183; logtok
  echo "C7-3, cited - the identity line in after/'s V1 ($MG/V1__customer_and_pause.sql, grep -c): GENERATED BY DEFAULT AS IDENTITY $($G -c 'GENERATED BY DEFAULT AS IDENTITY' after/$MG/V1__customer_and_pause.sql || true) · AUTO_INCREMENT $($G -c 'AUTO_INCREMENT' after/$MG/V1__customer_and_pause.sql || true)"
  echo "  the line PostgreSQL refused before it, quoted from the README of *Ids and Generation Strategies* (its pgstart capture): $($G -oE 'Caused by: org\.postgresql\.util\.PSQLException: ERROR: syntax error at or near' ../c7-unit06/README.md | head -1) \"AUTO_INCREMENT\""
  echo "  Flyway's failed V3, quoted from the README of *Flyway: Versioned Migrations* (its fail capture): PostgreSQL - $($G -oE 'failed! Changes successfully rolled back\.' ../c7-unit36/README.md | head -1) · H2 - $($G -oE 'Duplicate column name "PHONE"' ../c7-unit36/README.md | head -1), the half-applied column"
  echo "Flyway's version in TiffinBox's JVMs (R.329): Boot prints none; the jar on their class path, the file VersionPrinter.getVersion() reads (unzip -p flyway-core-12.4.0.jar org/flywaydb/core/internal/version.txt): $(unzip -p .harness/$LIB/flyway-core-12.4.0.jar org/flywaydb/core/internal/version.txt | tr -d '\r\n')"; }
dev() { local d
  echo "dev - the dev profile on a COPY of after/compose.yaml in .harness/dev (labelled: a copy, never tiffinbox-dev, never 18881), the copy's lines that differ:"
  sed -e "s/^name: tiffinbox-dev\$/name: $DPJ/" -e 's/"127\.0\.0\.1:18881:5432"/"127.0.0.1:20187:5432"/' after/compose.yaml > .harness/dev/compose.yaml
  diff after/compose.yaml .harness/dev/compose.yaml | $G -E '^[<>]' | sed 's/^/  /'
  echo "  the YAML's tiffinbox.jdbc-url, after/ (no flag here changes it): $($G -E '^  jdbc-url: ' after/$YM | sed 's/^ *//')"
  local c; c=$(printf 'cd .harness/dev && env DOCKER_HOST=%s %s\n' "$DH" "$(printf '%s\n' "$R_DEV" | sed 's#tiffinbox-web/target/#../after/tiffinbox-web/target/#g; s/--tiffinbox.port=18431/--tiffinbox.port=20186/')")
  c=$(printf '%s\n' "$c" | sed "s#&& env DOCKER_HOST=[^ ]* java #\&\& env DOCKER_HOST=$DH $AL java $JL #")
  for d in 1 2; do
    echo "dev - JVM $d, TiffinBox from Maven's class path (it holds spring-boot-docker-compose; Boot's docker CLI calls on the pinned socket, DOCKER_HOST), port 20186:"
    DSTARTED=1; start "$c --logging.level.org.hibernate.SQL=debug" 20186; up 20186; ready 20186
    $G -E 'Using Docker Compose file|Container [a-z0-9-]+ (Created|Starting|Started|Waiting|Healthy|Running)' .harness/run.out | sed -E 's/^.* : //; s/[[:space:]]+$//' | mask | sed 's/^/  compose: /'
    flylines
    echo "  HHH10001005 - the database Hibernate connected to: $($G -A1 'HHH10001005' .harness/run.out | $G -oE 'Database JDBC URL \[[^]]*\]' | head -1)"
    echo "  Hikari's first connection: $($G -oE 'Added connection [A-Za-z.]+' .harness/run.out | head -1)"
    [ $d = 1 ] && kavya 20186
    [ $d = 2 ] && see 20186
    stopit 20186; logtok
    echo "  the copy's container after the stop: $(dk ps -a --filter "label=com.docker.compose.project=$DPJ" --format '{{.Names}} {{.Status}}' | sed -E 's/(Exited \([0-9]+\)).*/\1/') · its named volume: $(dk volume ls -q --filter "name=^${DPJ}_" | paste -sd' ' -)"; done
  echo "\$ $L_DCDOWN"
  (eval "$L_DCDOWN") > .harness/dcdown.log 2>&1 < /dev/null || die "compose down -v failed: $(tail -2 .harness/dcdown.log)"; DSTARTED=""
  echo "  left of project $DPJ: containers $(dk ps -aq --filter "label=com.docker.compose.project=$DPJ" | wc -l | tr -d ' ') · volumes $(dk volume ls -q --filter "name=^${DPJ}_" | wc -l | tr -d ' ') · networks $(dk network ls -q --filter "name=^${DPJ}_" | wc -l | tr -d ' ') (the volume count is asserted at the end of the run, R.322)"; }
# preflight: R.318's first check, before any Maven run that may start Testcontainers - the env, the receipt home's keys
preflight() { local n
  [ "$(curl -s --unix-socket "${DH#unix://}" http://localhost/_ping 2> /dev/null)" = OK ] || die "the OrbStack socket ${DH#unix://} does not answer /_ping - is OrbStack running? (Testcontainers needs it)"
  [ "${TESTCONTAINERS_RYUK_DISABLED:-}" = true ] || die "R.318 pre-flight: TESTCONTAINERS_RYUK_DISABLED is '${TESTCONTAINERS_RYUK_DISABLED:-unset}' - Ryuk would start and pull its image; Maven not started"
  n=$($G -c '^ryuk\.' "$TH/.testcontainers.properties" || true)
  [ "$n" = 0 ] || die "R.318 pre-flight: $n ryuk.* key(s) in the receipt home's .testcontainers.properties (Testcontainers ignores them; only the env disables Ryuk); Maven not started"
  [ ! -e "$HOME/.testcontainers.properties" ] || die "R.318: ~/.testcontainers.properties appeared"
  echo "  pre-flight (R.318): /_ping OK on $(printf '%s' "$DH" | sed "s#$HOME#~#") · TESTCONTAINERS_RYUK_DISABLED=true · the receipt home's .testcontainers.properties: $(sed 's/=.*//' "$TH/.testcontainers.properties" | paste -sd' ' -), ryuk.* keys 0 · ~/.testcontainers.properties absent"; }
# mvnrun DIR LABEL CMD: one Maven run under its alarm, the docker events of its window kept (image and container)
MVE=""; TPN=""
mvnrun() { local d=$1 l=$2 c=$3 t0 t1 e=0
  echo "\$ cd $d && $c"
  t0=$(date +%s); (cd "$d" && eval "$c") > .harness/$l.log 2>&1 < /dev/null & mpid=$!; wait "$mpid" || e=$?; mpid=""; t1=$(date +%s); MVE=$e
  sleep 1; dk events --since "$t0" --until "$((t1 + 1))" --filter type=image --filter type=container --format '{{.Type}} {{.Action}} {{.Actor.Attributes.image}}' > .harness/$l.events 2> /dev/null || true
  [ "$e" != 142 ] || die "$l: Maven's alarm fired (exit 142, cap 600 - R.247)"
  local n; n=$($G -cE '^\[INFO\] Download(ing|ed) from ' .harness/$l.log || true)
  echo "  exit $e · $($G -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/$l.log || echo 'no BUILD line') · offline: $( [ "$n" = 0 ] && echo yes || echo "no - $n lines say Maven downloaded") · its alarm's cap: 600 (R.247)"
  local im; im=$($G '^container create ' .harness/$l.events | awk '{ print $3 }' | sort -u | paste -sd' ' -)
  echo "  the engine's events over its window (the pinned CLI): image pull $($G -c '^image pull' .harness/$l.events || true) · container create $($G -c '^container create ' .harness/$l.events || true) (${im:-none}) · Testcontainers containers left: $(dk ps -aq --filter label=org.testcontainers=true | wc -l | tr -d ' ')"; }
# tclog LABEL: what a Testcontainers JVM's log says - its version, its Docker, Ryuk, the mapped port (read off, masked)
tclog() { local l=$1 p q
  p=$(sed -nE 's#.*Container is started \(JDBC URL: jdbc:postgresql://localhost:([0-9]+)/test.*#\1#p' .harness/$l.log | head -1)
  q=$(sed -nE 's#^IT the database: jdbc:postgresql://localhost:([0-9]+)/test.*#\1#p' .harness/$l.log | head -1)
  [ -n "$p" ] && [ "$p" = "$q" ] || die "$l: the mapped port could not be read off the run (Testcontainers' line ${p:-none}, the test's URL ${q:-none})"
  printf '%s\n' "$p" >> .harness/tcports; TPN=$p; TCJVM=$((TCJVM + 1))
  echo "  Testcontainers in its log: 'Testcontainers version: 2.0.5' $($G -c 'Testcontainers version: 2.0.5' .harness/$l.log || true) · 'Found Docker environment with Environment variables' $($G -c 'Found Docker environment with Environment variables' .harness/$l.log || true) · $($G -oE 'Resolved dockerHost=[^ ]+' .harness/$l.log | head -1 | mask) · 'Ryuk has been disabled' $($G -c 'Ryuk has been disabled' .harness/$l.log || true) · $($G -oE 'Creating container for image: [^ ]+' .harness/$l.log | head -1)"
  echo "  the mapped port: read off the run (Testcontainers' JDBC URL line and the test's own URL agree), masked: $(printf 'localhost:%s' "$p" | mask)"; }
ryuk3() { local l=$1 c o p n
  n=$($G -c 'Ryuk has been disabled' .harness/$l.log || true)
  [ "$n" = 1 ] || die "R.318 (the log): 'Ryuk has been disabled' lines $n in $l (want 1)"
  c=$($G -c '^container create ' .harness/$l.events || true); o=$($G '^container create ' .harness/$l.events | $G -vc " $IMG\$" || true); p=$($G -c '^image pull' .harness/$l.events || true)
  [ "$c" = "${2:-1}" ] && [ "$o" = 0 ] && [ "$p" = 0 ] || die "R.318 (the events): container creates $c, not the digest $o, pulls $p in $l (want ${2:-1}, 0, 0)"
  echo "  Ryuk's three checks (R.318): pre-flight PASS · the log: 'Ryuk has been disabled' 1 · the events: $c container create of the digest, 0 others, 0 image pulls"; }
reports() { local d=$1
  echo "  Surefire's reports, $SR (read by harness/surefire.py):"; python3 -I harness/surefire.py "$d/$SR" | sed 's/^/  /'
  echo "  Surefire's reports, $SRI (read by harness/surefire.py):"; python3 -I harness/surefire.py "$d/$SRI" | sed 's/^/  /'; }
results() { $G -E '^\[(INFO|WARNING|ERROR)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | sed -E 's/^\[[A-Z]+\] /  Surefire'"'"'s Results line: /'; }
plantit() { local n=$1 f=.harness/plant/$TJ/com/tiffinbox/$1.java
  sed -e "s/class CustomerEntityRepositoryIT /class $n /" -e 's/var all = customers.findAllByOrderByNameAsc();/var all = customers.findAll(Sort.by("name"));/' \
      -e 's/^import org.springframework.data.domain.ScrollPosition;$/import org.springframework.data.domain.ScrollPosition;\nimport org.springframework.data.domain.Sort;/' after/$IT > "$f"
  [ "$n" = WrongCounterIT ] && sed -i '' 's/assertThat(stats.getPrepareStatementCount()).isEqualTo(1L);/assertThat(stats.getQueryExecutionCount()).isEqualTo(1L);/' "$f"
  echo "  $n - the shipped IT copied, its lines that differ:"; diff after/$IT "$f" | $G -E '^[<>]' | sed 's/^ *\([<>]\) */    \1 /' | sed -E 's/^    ([<>]) +/    \1 /'; }
tests() { local c f
  echo "tests - TiffinBox's tests, after/ copied to .harness/tests, offline: the Testcontainers recipe - the README's two export lines, a receipt home - and the README's verify line:"
  echo "\$ $R_DH"; echo "\$ $R_RYUK"; preflight
  rm -rf .harness/tests; copy after .harness/tests
  mvnrun .harness/tests verify "$L_MVNTC"; ryuk3 verify; tclog verify
  reports .harness/tests; results .harness/verify.log
  echo "  the test's own lines (IT, its stdout):"; $G -E '^IT ' .harness/verify.log | mask | sed 's/^/    /'
  echo "  HHH10001005 in the container tests' JVM - the database Hibernate connected to: $($G -A1 'HHH10001005' .harness/verify.log | $G -oE 'Database JDBC URL \[jdbc:postgresql:[^]]*\]' | head -1 | mask)"
  echo "  the keyset read's SQL (Hibernate's, the slice's show-sql) - the first of its lines: $($G -m1 -E '^Hibernate: select .* where ce1_0\.name>\? or ' .harness/verify.log | sed 's/^Hibernate: //') · such lines: $($G -cE '^Hibernate: select .* where ce1_0\.name>\? or ' .harness/verify.log || true) · the first window's read (no WHERE): $($G -cE '^Hibernate: select .* from customer ce1_0 order by ce1_0\.name,ce1_0\.id fetch first \? rows only$' .harness/verify.log || true)"
  echo "  version lines in its log (R.329): HHH000001 7.4.13.Final $($G -c 'HHH000001: Hibernate ORM core version 7.4.13.Final' .harness/verify.log || true) · Boot's banner (v4.1.2) $($G -cF ':: Spring Boot ::                (v4.1.2)' .harness/verify.log || true) · Testcontainers 2.0.5 $($G -c 'Testcontainers version: 2.0.5' .harness/verify.log || true) · Flyway: the jar on the tests' class path, its version.txt: $(unzip -p "$M2/org/flywaydb/flyway-core/12.4.0/flyway-core-12.4.0.jar" org/flywaydb/core/internal/version.txt | tr -d '\r\n')"
  echo "  the token and the password in its log and every report: $(raw "$TOKEN" .harness/verify.log .harness/tests/$SR/* .harness/tests/$SRI/*) / $(raw "$PW" .harness/verify.log .harness/tests/$SR/* .harness/tests/$SRI/*) times"
  echo "tests - mvn package with Maven's DOCKER_HOST pointed at nothing (env, Maven alone - R.332; the README's package line; the Dockerfile's mvn -B package the same):"
  GOAL=package; mvnrun .harness/tests package "$L_NODH"
  echo "  the pinned CLI meanwhile: info exit $(dk info > /dev/null 2>&1 && echo 0 || echo 1) · images $(dk images -q | wc -l | tr -d ' ') (non-empty)"
  python3 -I harness/surefire.py .harness/tests/$SR | sed 's/^/  /'; echo "  $SRI: $( [ -d .harness/tests/$SRI ] && echo present || echo 'absent - no container test ran')"; results .harness/package.log
  echo "tests - R.179: mvn verify with Maven's DOCKER_HOST pointed at nothing:"
  GOAL=verify; mvnrun .harness/tests verify-nodocker "$L_NODH"
  echo "  'Could not find a valid Docker environment' lines in its log: $($G -c 'Could not find a valid Docker environment' .harness/verify-nodocker.log || true)"
  reports .harness/tests; results .harness/verify-nodocker.log
  echo "tests - the two counter plants (R.320), each on a scratch copy of after/ whose web tests are the plant alone, mvn verify under the recipe; never shipped:"
  rm -rf .harness/plant; copy after .harness/plant; rm -f .harness/plant/$TJ/com/tiffinbox/web/*.java .harness/plant/$IT
  for f in NPlusOneIT WrongCounterIT; do
    plantit $f
    mvnrun .harness/plant $f "$L_MVNTC"; ryuk3 $f; tclog $f
    python3 -I harness/surefire.py .harness/plant/$SRI | sed 's/^/  /'
    echo "  its count line: $($G -E '^IT customers ' .harness/$f.log | head -1)"
    rm -f .harness/plant/$TJ/com/tiffinbox/$f.java; done
  echo "  the shipped IT's counter (grep): getPrepareStatementCount() asserted $($G -c 'assertThat(stats.getPrepareStatementCount()).isEqualTo(1L);' after/$IT || true) · getQueryExecutionCount() $($G -c 'getQueryExecutionCount' after/$IT || true)"; }
tb() { local t=$1 p=$2 d=$3; printf '%s %s\n' "$(at .harness/$t $p "$L_SQL")" "'--tiffinbox.jdbc-url=jdbc:h2:tcp://127.0.0.1:20184/mem:$d;DB_CLOSE_DELAY=-1' --spring.datasource.username=sa"; }
sqlseg() { sed -n "${1},${2}p" .harness/run.out | $G -cE ' org\.hibernate\.SQL +: ' || true; }
seven7() { local t n0 OP Q
  for t in before after; do
    echo "the seven - $t/'s jar, port 20185, a fresh JVM, its database mem:u39s7$t on the H2 server, Hibernate's SQL logger on:"
    start "$(tb $t 20185 u39s7$t)" 20185; up 20185; ready 20185; n0=$(lines)
    echo "  its log before the seven: 'Successfully applied 3 migrations' $($G -c 'Successfully applied 3 migrations' .harness/run.out || true)"
    echo "\$ \$CURLSET 20185 .harness/$t/$TF"
    "$CURLSET" 20185 ".harness/$t/$TF" | $G ' -> ' > .harness/responses.txt || true
    awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' .harness/responses.txt > .harness/seven-$t.txt
    gone 20185
    echo "  exit $LASTE · the seven responses: $(wc -l < .harness/seven-$t.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven-$t.txt)"
    echo "  its log's org.hibernate.SQL lines during the seven: $(sqlseg "$((n0 + 1))" '$')"
    logtok; rm -f .harness/run.out; h2drop u39s7$t; done
  echo "the seven - after/'s jar on PostgreSQL (its own driver), a fresh database u39s7, its URL in its own config tree, port 20185:"
  pgdb u39s7; PDB=u39s7; pgurl after u39s7
  start "$(at .harness/after 20185 "$L_SQL") --logging.level.org.hibernate.orm.connections.pooling=warn" 20185 "tiffinbox/jdbc-url tiffinbox/shutdown-token"; up 20185; ready 20185; n0=$(lines)
  echo "  its log before the seven: 'Successfully applied 3 migrations' $($G -c 'Successfully applied 3 migrations to schema "public"' .harness/run.out || true)"
  echo "\$ \$CURLSET 20185 .harness/after/$TF"
  "$CURLSET" 20185 ".harness/after/$TF" | $G ' -> ' > .harness/responses.txt || true
  awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' .harness/responses.txt > .harness/seven-pg.txt
  gone 20185
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/seven-pg.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven-pg.txt)"
  echo "  its log's org.hibernate.SQL lines during the seven: $(sqlseg "$((n0 + 1))" '$')"
  logtok; rm -f .harness/after/$UF; pgdrop u39s7
  echo "  the seven, after/ against before/ (H2): lines that differ: $(diff .harness/seven-before.txt .harness/seven-after.txt | $G -c '^[<>]' || true) · after/ on PostgreSQL against after/ on H2: $(diff .harness/seven-after.txt .harness/seven-pg.txt | $G -c '^[<>]' || true)"; }
X38=$(md5 -q ../c7-unit38/xcheck.sql)
XA=('--spring.datasource.url=jdbc:h2:mem:x39;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --logging.level.org.hibernate.orm.core=info --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
xcheck() {
  echo "Hibernate's DDL over after/'s libraries without Flyway's three jars (.harness/lib-nofly: no Flyway in this JVM) - probe.x.XMain, scripts.action=create (a file, never run):"
  rm -f .harness/run/hibernate-ddl.sql; LIBS=lib-nofly; MC=probe.x.XMain; A=("${XA[@]}")
  local c e=0; c=$(printf 'cd .harness/run && %s\n' "$L_H"); echo "\$ LIBS=$LIBS; MC=$MC; A=($(printf '%q ' "${A[@]}" | sed 's/ $//'))"; echo "\$ $c"
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!; wait "$pid" || e=$?; pid=""; LOGS=$((LOGS + 1))
  awk '/^INFO +\[main\] org\.hibernate\.orm\.core : HHH000001/ || /^(INFO|WARN|ERROR) +\[main\] org\.flywaydb\./ { sub(/[ \t]+$/, ""); print "  " $0 }' .harness/h.log
  echo "  exit $e · its WARN lines: $($G -c '^WARN ' .harness/h.log || true) · its org.flywaydb lines: $($G -c 'org\.flywaydb' .harness/h.log || true) · Flyway's jar on its class path: $(ls .harness/lib-nofly | $G -c '^flyway' || true)"
  [ -f .harness/run/hibernate-ddl.sql ] || die "xcheck: no script"
  mv .harness/run/hibernate-ddl.sql .harness/ddl-after.sql
  echo "  .harness/ddl-after.sql - every line:"; sed -E 's/FK[0-9a-z]{20,}/FK<name>/g; s/^/    /' .harness/ddl-after.sql
  echo "  after/'s md5: $(md5 -q .harness/ddl-after.sql) · the filed xcheck.sql: $(md5 -q xcheck.sql) · cmp: $(cmp -s .harness/ddl-after.sql xcheck.sql && echo 'the same, byte for byte' || echo differ) · the auditing lesson's xcheck.sql: $X38 · diff: $(diff ../c7-unit38/xcheck.sql .harness/ddl-after.sql | $G -c '^[<>]' || true) lines"; }
# exercise: the README's commands, then the solution's - in ONE shell, bash, then zsh
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2
  rm -rf .harness/ex; rm -f .harness/ex-*.st .harness/ex-*.out .harness/mine.log
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 2400 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after 600 s"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines:"
  echo "  the block's exit $e1 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "  the shell is now in: $(where "$d1")"
  echo "  then the solution's lines, in the same shell - the block's exit $e2 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines · DOCKER_HOST in its environment: $(env -i HOME="$HOME" PATH="$XPATH" /usr/bin/env | $G -c '^DOCKER_HOST=' || true)"; }
exercise() { local setup sol
  setup=$(block exercise/README.md); sol=$(block exercise/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  printf '%s\n' "$sol" | sed -n 1p | $G -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  [ "$(diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | $G -c '^[<>]')" = 2 ] || die "SOLUTION.md's block must be the README's with one line changed"
  printf '%s\n' "$setup" | $G -E ' mvn ' | $G -qF "perl -e 'alarm " || die "exercise/README.md's Maven run must run under its alarm (R.247)"
  ! printf '%s\n' "$setup" | $G -q 'DOCKER_HOST' || die "the exercise must need no Docker (R.196): its block names DOCKER_HOST"
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-readme.st"
cd "$1" || exit 1
. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-sol.st"
DRV
  echo "exercise/README.md's $(printf '%s\n' "$setup" | $G -c .) lines, then exercise/SOLUTION.md's, exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), started in this folder:"
  echo "the README's lines:"; printf '%s\n' "$setup" | sed 's/^/  $ /'
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh; }
EXQ="Your turn: the README's test counts the queries, and it passes while the page runs one statement per customer. Make it catch the extra statements."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
export DOCKER_HOST="$DH" TESTCONTAINERS_RYUK_DISABLED=true    # the README's two export lines, after the baselines (R.332: the plants set DOCKER_HOST on Maven's env alone)
cap anchor anchor; chk anchor .r-anchor.out; pub anchor
cap dev dev; chk dev .r-dev.out; pub dev
cap tests tests; chk tests .r-tests.out; pub tests
cap seven seven7; chk seven .r-seven.out "$S466"; pub seven
cap xcheck xcheck; chk xcheck .r-xcheck.out "$X38" "$(md5 -q xcheck.sql)"; pub xcheck
cap exercise exercise; chk exercise .r-exercise.out "$EXW" "$EXQ"; pub exercise
for f in exercise/README.md exercise/SOLUTION.md; do
  w=$(python3 -I -B harness/chk39.py wib .r-exercise.out "$f"); [ "$(wib "$f")" = "$w" ] || die "$f's \"What it prints\" block is not what its lines printed: $(diff <(wib "$f") <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "exercise: broken and solved print the same (R.196)"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
echo "  exercise: each file's What it prints = the run (bash's), the two differ (R.196); the spoken line $EXW words (wc -w)"
# R.302: every line of README.md's ```text blocks is a line a run printed
cat .r-*.out .harness/chk-*.out 2> /dev/null | sed -E 's/^ +//' > .harness/printed.txt
TX=$(awk '/^```text$/ { b = 1; next } b && /^```$/ { b = 0; next } b && NF { sub(/^ +/, ""); print }' README.md | while IFS= read -r l; do $G -qxF -- "$l" .harness/printed.txt || printf '%s\n' "$l"; done | head -3 | cut -c1-160 | paste -sd';' -)
[ "$($G -c '^```text$' README.md)" -gt 0 ] && [ -z "$TX" ] || die "R.302: README.md's text blocks must be lines the runs printed - not printed: ${TX:-no text block}"
echo "  R.302: README.md's $($G -c '^```text$' README.md) text blocks - every line one the runs printed"
VS="the values the video may say: on PostgreSQL 18.6 and H2 2.5.250, Testcontainers 2.0.5, Flyway 12.4.0, Spring Boot 4.1.2, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - $VALS"
printf '%s\n' "$VS" > .harness/values.txt
$G -qF -- "$VS" README.md || die "README.md does not state the values these captures give - a typed value (the line is in .harness/values.txt): $($G -oE 'the values the video may say: [^*`]*' README.md | head -1 | cut -c1-200)"
echo "  README.md states the captures' values (.harness/values.txt, $(wc -c < .harness/values.txt | tr -d ' ') bytes)"
# hygiene
for f in .harness/raw-* .harness/rawpw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the token or the password ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/SOLUTION.md receipts.md5 .harness/*.log; do [ "$(raw "$TOKEN" "$f")" = 0 ] && [ "$(raw "$PW" "$f")" = 0 ] || die "$f holds the token or the password, raw"; done
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$LOGS" -gt 0 ] && [ "$PGDBS" -gt 0 ] && [ "$TCJVM" -gt 0 ] || die "no JVM ran, or no PostgreSQL database was made, or no Testcontainers JVM ran"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -vE '^    [-+<>]' "$f" | $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) |Time elapsed|time="| in [0-9.]+ seconds|Total time' "$f" || die "$f holds Boot's process line, a time or Boot's seconds"
  ! $G -qE '^ *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][T ]|"timestamp":"?[0-9]|[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9]|(exec|handler|task)-[0-9]|started on [A-Z]' "$f" || die "$f holds a log time, a timestamp or a thread number"
  ! $G -qE 'using Java [0-9]|PROBE version: Java [0-9]|Darwin|arm64|aarch64|musl|Debian|pgdg' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'execution time [0-9]|[0-9] ms\b|[0-9]+ ms\)|PT[0-9]' "$f" || die "$f holds Flyway's execution time, Testcontainers' start time or a millisecond figure, unmasked (R.264)"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'password=[^<*]' "$f" || die "$f holds a password in a URL"
  ! $G -oE 'https?://[^ /]*' "$f" | $G -qvxE 'http://127\.0\.0\.1:201(8[0-9])|http://localhost' || die "$f holds a URL (only TiffinBox's own loopback ports may appear)"; done
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ (])java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned"
  ! $G -E '^ *\$ .*(^|[ (])java -D' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM without its alarm (R.247)"
  ! $G -E '^ *\$ .*(^|[ (])mvn ' "$f" | $G -vF -- "perl -e 'alarm " | $G -v ' -DskipTests' > /dev/null || die "$f starts a test-running Maven without its alarm (R.247)"
  ! $G -E '^ *\$ .*docker ' "$f" | $G -vF -- 'docker -H "$DH" ' > /dev/null || die "$f calls docker without the pinned socket (R.332)"; done
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness (R.195)"
echo "  hygiene: raw token and password copies after mask: 0 in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, $(ls .r-*.out | wc -l | tr -d ' ') captures and every log ($LOGS JVM logs, $TCJVM Testcontainers JVMs - each with its version line, R.329; $PGDBS fresh PostgreSQL databases, each dropped after its JVM - R.178); no path, unit number, time, millisecond figure, execution time, thread number, OS token, password, URL or stack frame in any capture; every JVM pinned and under its alarm; no H2 file"
# ---- the end: the H2 server, the container and its volume, Testcontainers, the anchor, the ports ------------------------------------
if [ -n "$spid" ] && kill "$spid" 2> /dev/null; then wait "$spid" 2> /dev/null || true; fi; spid=""
pgrm; [ -z "$(dk ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "the container $CN is still there"
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container is still there"
[ -z "$(dk ps -aq --filter "label=com.docker.compose.project=$DPJ" 2> /dev/null)$(dk volume ls -q --filter "name=^${DPJ}_" 2> /dev/null)" ] || die "the compose copy's project $DPJ left a container or a volume"
VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' '); IMGS1=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -); RY1=$(dk images --format '{{.Repository}}' 2> /dev/null | $G -c ryuk || true)
[ "$VOL1" = "$VOL0" ] || die "R.322: the volume count moved, $VOL0 -> $VOL1 - a container left its volume (an rm -f without -v)"
[ "$IMGS1" = "$IMGS0" ] && [ "$RY1" = 0 ] || die "the images moved over this run, or an image named ryuk appeared ($RY1) - nothing may be pulled"
[ ! -e "$HOME/.testcontainers.properties" ] || die "R.318: ~/.testcontainers.properties appeared over this run"
echo "  docker at the end: the container removed with its volume (rm -fv), Testcontainers containers 0, the compose copy's project gone (down -v); volumes $VOL0 -> $VOL1 (R.322); images $NI0, the same list, images named ryuk $RY1 (nothing pulled); ~/.testcontainers.properties absent"
beforetree end; anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 20180-20189 at the end - TiffinBox bound 20180-20183, 20185 and 20186 in turn and stopped, the H2 server 20184 and stopped, the compose copy 20187 and taken down, the container 20188 and removed; 20189 never bound"
# R.319: the LAST check - no capture holds a Testcontainers port this run read off, raw
TPR=$(for p in $(sort -u .harness/tcports); do $G -lE "(^|[^0-9a-f])$p([^0-9a-f]|$)" .r-*.out 2> /dev/null | sed "s/\$/: $p/"; done | head -3 | paste -sd';' -)
[ -s .harness/tcports ] && [ -z "$TPR" ] || die "R.319: a capture holds a Testcontainers port raw: ${TPR:-no port was read off}"
echo "  R.319: the Testcontainers ports this run read off ($(sort -u .harness/tcports | wc -l | tr -d ' ') runs) appear in no capture, raw"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit39: every capture 3/3 and = published; every spoken number asserted; 0 raw tokens, 0 raw passwords, 0 raw Testcontainers ports; the volume count unchanged; no port bound but 20180-20188"
