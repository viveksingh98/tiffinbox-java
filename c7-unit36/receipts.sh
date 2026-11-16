#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Flyway: Versioned Migrations - this unit's receipts. Section 6's first change to the anchor (brief flag 1, C1): before is
# the link to ../c7-unit34/after (its tree's hash pinned), after/ is this unit's tree, and ../c7-tiffinbox equals after/ from this
# unit's commit on. TiffinBox's schema and seed become two Flyway migrations (V1, V2 - derived from the retired Database class by
# harness/mkv.py and compared byte for byte), Database.java is deleted, and the YAML's ddl-auto is validate. Nine captures, each run
# three times and hashed; a hash that differs from receipts.md5 stops the run; every number and string the video says is asserted
# right after its capture by harness/chk36.py, against another witness of the same run - the history table read by a second
# connection (psql in the container, H2's Shell over TCP) beside Flyway's own lines (R.313) - never against a typed figure.
#   guard     step 36.0 (R.331): the four shipped builders that compare a file against the live anchor - their guard read, their
#             comparison step run as shipped on the live anchor (exit 0, a note for Database.java), and once each with the guard
#             taken out (FileNotFoundError). Needs the course's _builders folder beside this repository (or C7_BUILDERS): without it
#             the capture is skipped, said, and not hashed - it is the author's tooling, not TiffinBox's
#   jars      PostgreSQL, the harness: (i) flyway-core and Flyway's PostgreSQL module WITHOUT Boot's Flyway module; (ii) Boot's
#             module and flyway-core WITHOUT the PostgreSQL module (a filed refusal); (iii) all three; (iv) all three on H2
#   anchor    TiffinBox on PostgreSQL + the harness's driver (after/'s lib/ holds none, asserted): B (before/, 20150, twice in turn),
#             A (after/, 20151 then 20152), A' (after/ copied and built again, 20153 twice), the flyway.enabled=false refusal (20155)
#   fail      a third migration whose second statement is misspelt: PostgreSQL, then H2 over TCP - the history table after each run
#   traps     PostgreSQL: a checksum mismatch, a non-empty schema with no history, baseline-on-migrate, out of order, clean
#   seven     the comparison set on before/ and after/ (20154), TiffinBox's database on the H2 server (20157)
#   tests     TiffinBox's tests on after/, offline, read from Surefire's reports, and its log's Flyway lines
#   xcheck    Hibernate's DDL script over after/'s libraries without Flyway's three jars, against V1 (R.80)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# Every tree is COPIED under .harness/ and built there, never in place, offline. Every JVM runs under an alarm (perl -e 'alarm N;
# exec ...'; R.247). Every docker call names its socket (docker -H "$DH", R.332); the container is removed with its volume (rm -fv)
# and the volume count is asserted unchanged (R.322). Ports (20150-20159): 20150 B · 20151-20152 A · 20153 A' · 20154 the seven ·
# 20155 the refusal · 20157 the H2 TCP server · 20158 the container · 20156 and 20159 never bound. Nothing leaves the machine.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c7u36-pg
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.332): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
pid=""; tpid=""; mpid=""; xpid=""; spid=""; CSTARTED=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.f.") || index($0, "probe.f0.") || index($0, "probe.x.") || index($0, "org.h2.tools.") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "curlset.sh") || index($0, "surefirebooter") || $3 ~ /(^|\/)javac$/ || index($0, "jdk.compiler/com.sun.tools.javac") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "exec c7u36-pg") || index($0, "--name c7u36-pg")) { print $1 }' | paste -sd' ' -) || l=""
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
trap 'trap "" INT TERM; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$tpid" "$mpid" "$xpid" "$spid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; pgrm; find .harness -path "*/secrets/tiffinbox/jdbc-url" -delete 2> /dev/null || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp find curl openssl docker git unzip /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY FLYWAY_CANARY PGPASSWORD PGOPTIONS PGHOST PGUSER DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|FLYWAY_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - the token and the password live under .harness/ only"
# ---- docker: the pinned socket and non-empty baselines before any comparison (R.332), the volume count (R.322) ----------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that socket? (R.332: every docker call names its socket)"
IMGS0=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -); NI0=$(printf '%s\n' "$IMGS0" | wc -w | tr -d ' ')
VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI0" -ge 1 ] && [ "$VOL0" -ge 1 ] || die "R.332: the baselines must not be empty - images $NI0, volumes $VOL0 on $DH (an empty list compares equal to anything)"
dk image inspect "$IMG" > /dev/null 2>&1 || die "the image $IMG is not on this machine - pull it once yourself (this script never pulls)"
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · info exit 0 · images $NI0 · volumes $VOL0 (the baselines, both non-empty) · the image: $IMG is present (never pulled)"
# ---- the trees ------------------------------------------------------------------------------------------------------------
[ -L before ] && [ "$(readlink before)" = ../c7-unit34/after ] || die "before must be the link to ../c7-unit34/after - the anchor before this change"
[ -d after ] && [ ! -L after ] || die "after/ must be this unit's own tree, not a link"
for t in before after; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] || die "the tree $t (its pom.xml or README.md) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/hibernate-ddl.sql" ] && die "$t holds a secrets/, a target/ or a hibernate-ddl.sql - it is a frozen copy, never built in place"
  true; done
T34='43 ff5f470f9dbd5774164212b85c1ea32e'            # unit 34's after/ at its commit 298c26e: 43 files (harness/tree36.py)
beforetree() { local t; t=$(python3 -I harness/tree36.py before/) || die "before/'s tree could not be hashed"
  [ "$t" = "$T34" ] || die "R.211: before/ (../c7-unit34/after, a shipped unit's frozen tree) is not the tree this unit changed: $t, pinned $T34"
  echo "  before/'s tree ($1): python3 -I harness/tree36.py before/ -> $t = pinned (unit 34's after/, Section 5's frozen anchor)"; }
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c7-tiffinbox: empty - after/ = ../c7-tiffinbox"
  else echo "  (after/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit froze: $(printf '%s\n' "$d" | head -3 | paste -sd';' -))" >&3
    echo "  the anchor ($1): after/ is this unit's tree (C1) - a later anchor change has moved ../c7-tiffinbox on"; fi; }
beforetree start; anchornote start
M2="$PWD/.m2-demo"
CJ=tiffinbox-core/src/main/java/com/tiffinbox
MG=tiffinbox-core/src/main/resources/db/migration
YM=tiffinbox-web/src/main/resources/application.yaml
SR=tiffinbox-web/target/surefire-reports
XD=tiffinbox-web/target/extracted
TF=secrets/tiffinbox/shutdown-token
UF=secrets/tiffinbox/jdbc-url
PGJ=org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar
CURLSET=../c5-unit11/curlset.sh
[ -x "$CURLSET" ] || die "$CURLSET is missing - the comparison set the seven runs"
HFILES='chk36.py dur7.py guard.py logback.xml mig mkv.py s36.py src surefire.py tree36.py'
SFILES='probe/f/FApi.java probe/f/FMain.java probe/f/Run.java probe/f/V.java probe/f/ex/Ex.java probe/f0/F0Main.java probe/x/XMain.java'
MFILES='edited/V1__customer_and_pause.sql fail/V3__add_phone.sql fixed/V3__add_phone.sql ooo/V1_5__note.sql'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5 xcheck.sql; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] && [ "$(cd harness/mig && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$MFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
cmp -s harness/src/probe/x/XMain.java ../c7-unit29/harness/src/probe/x/XMain.java || die "harness/src/probe/x/XMain.java is not unit 29's, byte for byte"
cmp -s harness/surefire.py ../c6-unit28/harness/surefire.py || die "harness/surefire.py is not the testing lesson's, byte for byte"
cmp -s harness/tree36.py ../c7-unit33/harness/tree33.py || die "harness/tree36.py is unit 33's tree33.py, byte for byte"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 20150 20151 20152 20153 20154 20155 20156 20157 20158 20159"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
[ -z "$(dk ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "a container named $CN exists - an interrupted run's? remove it with its volume (rm -fv, on the pinned socket)"
rm -rf .harness; mkdir -p .harness/run .harness/hc .harness/secrets .harness/mig
echo "  ports: 20150-20159 free at the start (and 18425, 8080, 35729)"

# ---- the prose gates ----------------------------------------------------------------------------------------------------------
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s36.py harness/dur7.py $PROSE) || die "the prose gate did not run (or its self-test failed)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
echo "  prose, per sentence (s36, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test): dur7 words 0 · S4.7's family 0 · R.301's family 0 but beside a printed count · R.190 the tests as a witness 0 · R.224 a call-back without its title 0 · R.313 a migration claim without the history table 0 · R.314 a failed-migration claim without its database 0 · R.335 TiffinBox on PostgreSQL unsaid or without the harness's driver 0 · \"Hibernate generates\" 0 · R.302 a typed hash or jar count 0 - over README.md and exercise/"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
dishes() { $G -rniwE -- "$DISH" "$@" 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true; }
DN=$(dishes README.md exercise harness after/$MG)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, any case, over README.md, exercise/, harness/ and the migrations)"
PH=$($G -rnE 'EXERCISE-[A-Z-]*OUTPUT|[A-Z]+-OUTPUT\b|[A-Z]+-PARAGRAPH\b|TODO|TBD|PLACEHOLDER' README.md exercise 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder line in this unit's prose: $PH"
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f" | $G -v '^ *$' || true)" ] || die "$f must hold one \"What it prints\" line and, under it, a block that is not empty"; done
echo "  placeholders: 0 · each exercise file's \"What it prints\" block not empty"
prose() { awk -v f="$1" '/^<!-- values: begin -->$/ { v = 1; next } /^<!-- values: end -->$/ { v = 0; next } /^```/ { b = !b; next } !v && !b { print f ":" NR ": " $0 }' "$1"; }
SQLRE='select ce1_0|from customer ce1_0|from pause p1_0|create table customer \(meals|alter table if exists pause add constraint|INSERT INTO customer \(name|ALTER TABLE customer ADD COLUM '
TS=$(for f in $PROSE; do prose "$f"; done | $G -E "$SQLRE" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string in the prose (R.225): $TS"
TNRE='\b[0-9]+ (history rows|rows in the history|migrations applied|SQL lines|libraries|jars)\b|7f69''42f0|466c''20ed|[0-9a-f]{32}|\b1851''893479\b'
TN=$(for f in $PROSE; do prose "$f"; done | $G -E "$TNRE" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TN" ] || die "R.302: a count or a printed md5 typed in the prose, outside a block a run printed and the values block: $TN"
TC=$($G -nE '7f69''42f0|466c''20ed|1851''893479|1527''763366' receipts.sh harness/chk36.py harness/src/probe/f/*.java 2> /dev/null | cut -c1-120 | head -3 | paste -sd';' - || true)
[ -z "$TC" ] || die "R.302: a printed md5 or checksum typed in this script or the harness: $TC"
echo "  typed SQL strings 0 · R.302: history-row, migration, SQL-line and jar counts and md5s typed 0 times in the prose (outside printed blocks and the values block), and 0 in receipts.sh, chk36.py and the harness's sources"

# ---- static checks of this script and the harness - before anything runs --------------------------------------------------
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
DK=$($G -v '^ *#' receipts.sh | $G -nE '\bdocker (run|exec|rm|ps|port|info|images|volume|image|pull|events)\b' | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.332: receipts.sh calls docker without the pinned socket (every call is dk, or a README line with -H \"\$DH\"): $DK"
! $G -v '^ *#' receipts.sh | $G -qE 'rm -f'' "?\$CN|rm -f'' c7u36' || die "R.322: receipts.sh removes the container without its volume (rm -fv)"
! $G -rqE 'Thread\.sleep|while *\(true\)|TimeUnit\.[A-Z]+\.sleep|LockSupport\.park' harness/src || die "a harness sleeps or polls (S4.18)"
! $G -rq 'probe\.f' after/tiffinbox-web after/tiffinbox-core || die "the anchor's code names the course's harness"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
echo "  static: no kill by name; every docker call on the pinned socket (R.332); the container removed with its volume, rm -fv (R.322); no sleep in the harness; no harness name in the anchor, no harness class in com.tiffinbox"

# ---- R.250 and R.330: C1 and every sentence it makes false - a gate before any build -------------------------------------------
R250=$(python3 -I -B harness/chk36.py r250 after) || die "R.250/R.330: $(printf '%s\n' "$R250" | $G -v '^ok' | head -3 | paste -sd';' -)"
printf '%s\n' "$R250" | sed 's/^/  /'
for v in v1:V1__customer_and_pause.sql v2:V2__seed.sql; do
  python3 -I harness/mkv.py before/$CJ/Database.java ${v%%:*} > .harness/mkv.sql || die "harness/mkv.py could not read before/'s Database.java"
  cmp -s .harness/mkv.sql after/$MG/${v#*:} || die "after/$MG/${v#*:} is not what harness/mkv.py derives from before/'s Database.java (never retyped): $(diff .harness/mkv.sql after/$MG/${v#*:} | head -3 | paste -sd' ' -)"; done
echo "  the migrations: after/'s V1__customer_and_pause.sql and V2__seed.sql = python3 -I harness/mkv.py before/'s Database.java v1 / v2, byte for byte (its CREATE statements and its seed, never retyped); after/ holds no Database.java: $( [ -e after/$CJ/Database.java ] && echo 'it does' || echo 'none')"
[ ! -e after/$CJ/Database.java ] || die "C1: after/ still holds Database.java"

# ---- the commands: read from after/README.md, the anchor's own, and from this README ----------------------------------------
readme() { $G -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_TEST=$(readme 'mvn -B clean test')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_TOKEN=$(readme 'mkdir -p secrets/tiffinbox && (umask 077 && printf '"'"'%s\n'"'"' "$(openssl rand -hex 16)" > secrets/tiffinbox/shutdown-token)')
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 240; exec @ARGV'"
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/after/$XD/lib/*\" harness/src/probe/f/V.java harness/src/probe/f/Run.java harness/src/probe/f/FMain.java harness/src/probe/f/FApi.java harness/src/probe/f0/F0Main.java harness/src/probe/x/XMain.java")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../\$LIBS/*:../../.m2-demo/$PGJ\" \$MC \"\${A[@]}\"")
L_TPG=$(mine "java $JL -cp \"$XD/tiffinbox-web-1.0.0.jar:$XD/lib/*:../../.m2-demo/$PGJ\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.datasource.username=sa --logging.level.org.hibernate.SQL=debug")
L_H2S=$(mine "cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' java $JL -Dh2.bindAddress=127.0.0.1 -cp \"../after/$XD/lib/h2-2.5.250.jar\" org.h2.tools.Server -tcp -tcpPort 20157 -ifNotExists")
L_SHELL=$(mine "$AL java $JL -cp \"../after/$XD/lib/h2-2.5.250.jar\" org.h2.tools.Shell -url \"jdbc:h2:tcp://127.0.0.1:20157/mem:\$DB\" -user sa -password '' -sql \"\$Q\"")
L_RUN=$(mine "docker -H \"\$DH\" run -d --pull never --name $CN -p 127.0.0.1:20158:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v \"\$U/.harness/secrets/pgpw:/run/pgpw:ro\" $IMG")
L_READY=$(mine "docker -H \"\$DH\" exec $CN pg_isready -U sa -h 127.0.0.1 -q")
L_DB=$(mine "docker -H \"\$DH\" exec $CN psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c \"drop database if exists \$DB with (force)\" -c \"create database \$DB\"")
L_PSQL=$(mine "docker -H \"\$DH\" exec $CN psql -U sa -d \"\$DB\" -qAt -v ON_ERROR_STOP=1 -c \"\$Q\"")
L_SQL=$(mine "$R_RUN --logging.level.org.hibernate.SQL=debug")
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java '*) l="$AL java $JL ${l#java }" ;; esac; l=${l/java $JL $JL /java $JL }; printf 'cd %s && %s\n' "$1" "$l"; }
tb() { local t=$1 p=$2 d=$3; printf '%s %s\n' "$(at .harness/$t $p "$L_SQL")" "'--tiffinbox.jdbc-url=jdbc:h2:tcp://127.0.0.1:20157/mem:$d;DB_CLOSE_DELAY=-1' --spring.datasource.username=sa"; }
[ "$(off .harness/after "$R_PLAIN" package)" = 'cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "off(): the build line is not the README's package line, offline"
echo "  the commands: after/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"

# ---- build: before the captures -------------------------------------------------------------------------------------------
NOPLUG='No plugin'' found for prefix'
mbuild() { local how=yes ec=0 c=$1 miss got web
  (eval "$c") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
  if [ $ec != 0 ] && $G -qE "offline mode|Could not resolve|could not be resolved|Cannot access|$NOPLUG" "$2"; then
    miss=$($G -oE "Could not find artifact [^ ]+|$NOPLUG [^ ]+|the artifact [^ ]+ has not been downloaded" "$2" | head -1)
    how="no - the offline build could not resolve ${miss:-an artifact} from .m2-demo (this script never goes online: seed .m2-demo from the course's seed)"
    tail -20 "$2" >&3; die "build failed offline: $3 - $how"; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3; die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec · 'Downloaded from' lines in its log: $($G -c '^\[INFO\] Downloaded from ' "$2" || true)"; }
summ4() { $G -E '^\[(INFO|WARNING|ERROR)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | sed -E 's/.*Tests run: ([0-9]+), Failures: ([0-9]+), Errors: ([0-9]+), Skipped: ([0-9]+)$/\1 \2 \3 \4/' | awk '{ a += $1; b += $2; c += $3; d += $4 } END { print a + 0, b + 0, c + 0, d + 0 }'; }
JE=""
jc() { local ec=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""; JE=$ec; }
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy before .harness/before; copy after .harness/after; copy after .harness/after2
mbuild "$(off .harness/before "$R_PLAIN" package)" .harness/build-before.log ".harness/before (before/, the README's package line; its tests ran - a guard on B)"
[ "$(summ4 .harness/build-before.log)" = '18 0 0 0' ] || die "before/'s tests: $(summ4 .harness/build-before.log) - expected 18 0 0 0 (a guard)"
mbuild "$(off .harness/after "$R_PLAIN" package)" .harness/build-after.log ".harness/after (after/, the README's package line; its tests ran)"
[ "$(summ4 .harness/build-after.log)" = '18 0 0 0' ] || die "after/'s tests: $(summ4 .harness/build-after.log) - expected 18 0 0 0 (a guard)"
mbuild "$(off .harness/after2 "$R_PLAIN" package) -DskipTests" .harness/build-after2.log ".harness/after2 (after/ copied again for A', the same line, -DskipTests)"
echo "  the tests as a guard (R.190): before/ $(summ4 .harness/build-before.log | awk '{ print $1 }') run, $(summ4 .harness/build-before.log | awk '{ print $2 + $3 }') failed · after/ $(summ4 .harness/build-after.log | awk '{ print $1 }') run, $(summ4 .harness/build-after.log | awk '{ print $2 + $3 }') failed - neither is a witness of the restart"
for t in before after after2; do (cd .harness/$t && eval "$R_EXTRACT") > .harness/extract-$t.log 2>&1 < /dev/null || die "the extract of $t failed: $(tail -3 .harness/extract-$t.log)"; done
for a in org/springframework/boot/spring-boot-dependencies/4.1.2/spring-boot-dependencies-4.1.2.pom org/flywaydb/flyway-core/12.4.0/flyway-core-12.4.0.jar org/flywaydb/flyway-database-postgresql/12.4.0/flyway-database-postgresql-12.4.0.jar org/springframework/boot/spring-boot-flyway/4.1.2/spring-boot-flyway-4.1.2.jar com/h2database/h2/2.5.250/h2-2.5.250.jar "$PGJ"; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
# R.335: the PostgreSQL driver is the harness's - no tree under test holds one
for t in before after after2; do [ ! -e .harness/$t/$XD/lib/postgresql-42.7.14.jar ] && [ -z "$(cd .harness/$t/$XD/lib && ls | $G -E '^postgresql-.*\.jar$' || true)" ] || die "R.335: .harness/$t's lib/ holds a PostgreSQL driver - before 39 no TiffinBox tree does; the harness adds it from .m2-demo"; done
echo "  R.335: the PostgreSQL driver - .harness/before, .harness/after and .harness/after2: lib/ holds no postgresql-*.jar (asserted, each); every PostgreSQL run below adds .m2-demo/$PGJ to the class path: + the harness's driver"
# the class paths of the jars capture: after/'s lib/ with one or two of Flyway's jars left out, as links
LIB=after/$XD/lib
mkdir -p .harness/lib-core .harness/lib-nopg .harness/lib-nofly
for j in $(ls .harness/$LIB); do
  case $j in spring-boot-flyway-*) ;; *) ln -s ../$LIB/$j .harness/lib-core/$j ;; esac
  case $j in flyway-database-postgresql-*) ;; *) ln -s ../$LIB/$j .harness/lib-nopg/$j ;; esac
  case $j in flyway-*|spring-boot-flyway-*) ;; *) ln -s ../$LIB/$j .harness/lib-nofly/$j ;; esac; done
NL=$(ls .harness/$LIB | wc -l | tr -d ' '); NB=$(ls .harness/before/$XD/lib | wc -l | tr -d ' ')
(cd .harness/after && eval "$R_TOKEN") || die "the token was not written"
TOKEN=$(head -n 1 .harness/after/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
for t in before after2; do mkdir -p .harness/$t/secrets/tiffinbox && (umask 077 && cp .harness/after/$TF .harness/$t/$TF); done
for t in before after after2; do [ "$(stat -f '%Lp' .harness/$t/$TF)" = 600 ] || die "the token's file in $t must be mode 0600"; done
jc "$L_JAVAC" .harness/javac.log; [ "$JE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/f/ex ] || die "the exercise's class compiled into the harness's folder"
for s in base:after/$MG/V1__customer_and_pause.sql base:after/$MG/V2__seed.sql fail:after/$MG/V1__customer_and_pause.sql fail:after/$MG/V2__seed.sql fixed:after/$MG/V1__customer_and_pause.sql fixed:after/$MG/V2__seed.sql edited:after/$MG/V2__seed.sql ooo:after/$MG/V1__customer_and_pause.sql ooo:after/$MG/V2__seed.sql; do
  mkdir -p .harness/mig/${s%%:*}; cp "${s#*:}" .harness/mig/${s%%:*}/; done
for f in $MFILES; do mkdir -p .harness/mig/$(dirname $f); cp harness/mig/$f .harness/mig/$f; done
[ "$(diff after/$MG/V1__customer_and_pause.sql harness/mig/edited/V1__customer_and_pause.sql | $G -c '^[<>]')" = 2 ] && [ "$(sed 1d after/$MG/V1__customer_and_pause.sql | md5 -q)" = "$(sed 1d harness/mig/edited/V1__customer_and_pause.sql | md5 -q)" ] || die "harness/mig/edited's V1 must differ from after/'s V1 in its first line, the comment, alone"
echo "  extracted three jars ($NB/$NL/$(ls .harness/after2/$XD/lib | wc -l | tr -d ' ') libraries: before/after/A'); the jars capture's class paths: after/'s lib/ without spring-boot-flyway ($(ls .harness/lib-core | wc -l | tr -d ' ')), without flyway-database-postgresql ($(ls .harness/lib-nopg | wc -l | tr -d ' ')), without all three Flyway jars for xcheck ($(ls .harness/lib-nofly | wc -l | tr -d ' ')); the harness compiled once (.harness/hc, $(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes); the token generated (the README's line), copied into before's and after2's $TF, mode 0600, never printed; the migration sets under .harness/mig: base, fail, fixed, edited, ooo (V1 and V2 copied from after/, the rest from harness/mig)"
# the H2 TCP server: one JVM for this run, loopback only
echo "\$ $L_H2S" >&3
(eval "$L_H2S") > .harness/h2server.log 2>&1 < /dev/null & spid=$!
i=0; while [ $i -lt 120 ] && [ "$(listeners 20157)" = 0 ]; do kill -0 "$spid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
[ "$(listeners 20157)" = 1 ] || { cat .harness/h2server.log >&3; die "the H2 server never listened on 20157"; }
[ "$(lsof -nP -a -p "$spid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)" = '127.0.0.1:20157' ] || die "the H2 server must listen on 127.0.0.1:20157 alone"
H2SL=$($G -m1 'TCP server running at' .harness/h2server.log || true); [ "$H2SL" = 'TCP server running at tcp://localhost:20157 (only local connections)' ] || die "the H2 server's line: ${H2SL:-none}"
echo "  the H2 server: $H2SL - listens on 127.0.0.1:20157 alone"
# the container: PostgreSQL 18 from the pinned image, loopback only, a generated password in a 0600 file (R.214)
(umask 077 && LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom 2> /dev/null | head -c 24 > .harness/secrets/pgpw) || true
[ "$(wc -c < .harness/secrets/pgpw | tr -d ' ')" = 24 ] && [ "$(stat -f '%Lp' .harness/secrets/pgpw)" = 600 ] || die "the password file was not written, 24 characters, mode 0600"
PW=$(cat .harness/secrets/pgpw)
CSTARTED=1
(eval "$L_RUN") > .harness/docker-run.log 2>&1 < /dev/null || die "the container did not start: $(tail -2 .harness/docker-run.log)"
i=0; while ! (eval "$L_READY") > /dev/null 2>&1 < /dev/null; do i=$((i + 1)); [ $i -lt 120 ] || die "the container did not accept connections within its cap (120 tries, 0.5 apart)"; sleep 0.5; done
DP=$(dk port "$CN" 2> /dev/null | paste -sd'|' -)
[ "$DP" = '5432/tcp -> 127.0.0.1:20158' ] || die "the container must publish 5432 on 127.0.0.1:20158 alone: $DP"
echo "  the container: $CN from $IMG (--pull never); its published port: $DP; user sa, the password generated into .harness/secrets/pgpw (24 characters, mode 0600, never printed); pg_isready after $i tries (cap 120)"

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C $G -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; PGJVM=0; FLYJVM=0
mask() { awk -v t="$TOKEN" -v pw="$PW" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); W = lit(pw); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the token]"); gsub(W, "<pw>"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>"); gsub(/PROBE version: Java [0-9][0-9.]+/, "PROBE version: Java <version>")
    gsub(/\(execution time [0-9:.]+s\)/, "(execution time <t>)")
    gsub(/, [0-9]+ ms\)/, ")")
    gsub(/\$\$Lambda\/0x[0-9a-f]+/, "$$Lambda/<n>")
    gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"<time>\"")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting Main using Java 25.0.4.1' "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' "token $TOKEN" "url jdbc:postgresql://127.0.0.1:20158/u36?user=sa&password=$PW" 'Successfully applied 2 migrations to schema "public", now at version v2 (execution time 00:00.026s)' '(4 rows, 3 ms)' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting Main using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'token [masked: the token]' 'url jdbc:postgresql://127.0.0.1:20158/u36?user=sa&password=<pw>' 'Successfully applied 2 migrations to schema "public", now at version v2 (execution time <t>)' '(4 rows)')" ] || die "mask: the planted JDK version, folders, home, identity hash, the token, the password, Flyway's execution time and H2 Shell's row line must be masked"
echo "  mask: its self-test passed (the token, the password, folders, home, identities, Flyway's execution time - R.264 - and the Shell's milliseconds); raw password copies after mask: $(mask < .harness/p1 | $G -cF -- "$PW" || true)"
rm -f .harness/p1
CORE=--logging.level.org.hibernate.orm.core=info
HQ=(--logging.config=../../harness/logback.xml "$CORE" --spring.jpa.open-in-view=false --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false)
VAL=--spring.jpa.hibernate.ddl-auto=validate
HE=""; LIBS=""; MC=""
# hrun: one harness JVM, its stdout and stderr to .harness/h.log
hrun() { local c i=0 e=0 n
  c=$(printf 'cd .harness/run && %s\n' "$L_H")
  echo "\$ LIBS=$LIBS; MC=$MC; V=($(printf '%s ' "${V[@]}" | sed 's/ $//')); A=($(printf '%q ' "${A[@]}" | sed 's/ $//'))"
  echo "\$ $c"
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 1000 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running after 250 s - its alarm should have stopped it"; }
  wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1))
  [ "$HE" != 142 ] || die "the harness JVM's alarm fired (exit 142) - a run that does not end by itself is a failed receipt (R.247)"
  # R.329: a JVM that loads Flyway prints Flyway's version line
  if $G -q 'org\.flywaydb' .harness/h.log; then FLYJVM=$((FLYJVM + 1)); $G -qxF 'PROBE version: Flyway 12.4.0' .harness/h.log || die "R.329: a JVM loaded Flyway and printed no Flyway version line"; fi
  case " ${V[*]:-} " in *" -Dpg.db="*) PGJVM=$((PGJVM + 1)); n=$(raw "$PW" .harness/h.log); [ "$n" = 0 ] || die "a harness log held the password, raw ($n)" ;; esac; }
# hview: the lines a capture shows of a JVM's log - the version lines, Flyway's lines (Flyway's own logger), HHH000001, what the
# harness printed (PROBE), and the refusal's own lines; each once, in order (Boot repeats a refusal's message in every cause)
hview() { awk '/^(INFO|WARN|ERROR) +\[main\] org\.flywaydb\./ || /^INFO +\[main\] org\.hibernate\.orm\.core : HHH000001/ || /^PROBE / || /^(SQL State|Message|Detected|-> |Validate failed|Please remove|Unable to|Migration checksum mismatch)/ { sub(/[ \t]+$/, ""); if (!s[$0]++) print "  " $0 }' .harness/h.log
  echo "  exit $HE · its WARN lines: $($G -c '^WARN ' .harness/h.log || true) · its org.flywaydb lines: $($G -c '^[A-Z]* *\[main\] org\.flywaydb\.' .harness/h.log || true)"; }
pgdb() { local DB=$1; echo "\$ DB=$DB; $L_DB"; (eval "$L_DB") > .harness/pgdb.log 2>&1 < /dev/null || die "the fresh database $DB was not made: $(tail -2 .harness/pgdb.log)"
  echo "  a fresh database: $DB"; }
# psq DB Q: the second connection on PostgreSQL - psql in the container
psq() { local DB=$1 Q=$2; echo "\$ DB=$DB; Q=\"$Q\"; $L_PSQL"; (eval "$L_PSQL") > .harness/psql.out 2>&1 < /dev/null || true; sed 's/^/    /' .harness/psql.out; }
HQS='select installed_rank, version, description, type, script, checksum, installed_by, success from flyway_schema_history order by installed_rank'
hist() { psq "$1" "$HQS"; }
tables() { psq "$1" "select coalesce(string_agg(tablename, ', ' order by tablename), '(none)') from pg_tables where schemaname = 'public'"; }
cols() { psq "$1" "select string_agg(column_name, ', ' order by ordinal_position) from information_schema.columns where table_schema = 'public' and table_name = 'customer'"; }
# h2q DB Q: the second connection on H2 - H2's own Shell over TCP, its own JVM
h2q() { local DB=$1 Q=$2 c e=0; c=$(printf 'cd .harness/run && %s\n' "$L_SHELL"); echo "\$ DB=$DB; Q='$Q'"; echo "\$ $c"
  (eval "$(exe "$c")") > .harness/shell.out 2>&1 < /dev/null & pid=$!; wait "$pid" || e=$?; pid=""
  [ "$e" = 0 ] || { cat .harness/shell.out >&3; die "H2's Shell failed (exit $e)"; }
  sed -E 's/[[:space:]]+$//; s/^/    /' .harness/shell.out; }
H2HQ='SELECT "installed_rank", "version", "description", "type", "script", "installed_by", "success" FROM "flyway_schema_history" ORDER BY 1'
H2CQ="SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'CUSTOMER' ORDER BY ORDINAL_POSITION"
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
  o=$(python3 -I -B harness/chk36.py "$nm" "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' | tee .harness/chk-$nm.out || true
  [ $e = 0 ] || die "$nm: its check failed (harness/chk36.py, above)"
  VALS="$VALS${VALS:+ · }$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }

# ---- the captures --------------------------------------------------------------------------------------------------------
# guard: step 36.0, the four builders read (never written) and their comparison step run on the live anchor
BLD=${C7_BUILDERS:-$UP/../../data-jpa-hibernate/_builders}
guard() { echo "guard - step 36.0 (R.331): the four shipped builders that compare a file against the live anchor, read by harness/guard.py (never written):"
  python3 -I -B harness/guard.py "$BLD" "$UP" 2>&1 | sed 's/^/  /'
  echo "  exit of guard.py: ${PIPESTATUS[0]}"; }
# jars: which jars run Flyway in Boot 4.1 - the harness on PostgreSQL (three JVMs) and on H2 (one)
jars() { echo "jars - Boot 4.1 runs Flyway through its own module; the harness over after/'s libraries, $NL of them (ls | wc -l), Flyway's three:"
  (cd .harness/$LIB && ls | $G -E '^(spring-boot-)?flyway' | sed 's/^/  /')
  echo "(i) flyway-core and flyway-database-postgresql WITHOUT spring-boot-flyway (Boot's Flyway module) - a labelled run, PostgreSQL:"
  pgdb u36j1; LIBS=lib-core; MC=probe.f0.F0Main; V=(-Dpg.db=u36j1 -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}" --spring.jpa.hibernate.ddl-auto=none); hrun; hview
  echo "  the second connection - the tables in public:"; tables u36j1
  echo "  the history check (R.313): $(psq u36j1 'select count(*) from flyway_schema_history' | $G -c 'does not exist' || true) refusal - no flyway_schema_history: \"Flyway ran\" is refused for this run"
  echo "(ii) spring-boot-flyway and flyway-core WITHOUT flyway-database-postgresql - PostgreSQL, a filed refusal (R.303):"
  pgdb u36j2; LIBS=lib-nopg; MC=probe.f.FMain; V=(-Dpg.db=u36j2 -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}" $VAL); hrun; hview
  echo "  the refusal's step - exit $HE · its lines (grep -o, this step's log): $($G -m1 -oE 'FlywayException: Unsupported Database: PostgreSQL [0-9.]+' .harness/h.log || echo none) ← $($G -m1 -oE "Error creating bean with name 'flywayInitializer'" .harness/h.log || echo none) ← $($G -m1 -oE "Failed to initialize dependency 'flywayInitializer' of LoadTimeWeaverAware bean 'entityManagerFactory'" .harness/h.log || echo none)"
  echo "  the second connection - the tables in public:"; tables u36j2
  echo "(iii) all three - PostgreSQL, ddl-auto validate:"
  pgdb u36j3; LIBS=$LIB; MC=probe.f.FMain; V=(-Dpg.db=u36j3 -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}" $VAL); hrun; hview
  echo "  the order (line numbers in its log): the first org.flywaydb line $($G -n -m1 'org\.flywaydb' .harness/h.log | cut -d: -f1) · the last $($G -n 'org\.flywaydb' .harness/h.log | tail -1 | cut -d: -f1) · HHH000001 $($G -n -m1 'HHH000001' .harness/h.log | cut -d: -f1)"
  echo "  the second connection - the history table:"; hist u36j3
  echo "  the second connection - the tables in public:"; tables u36j3
  echo "  the second connection - the foreign key's name on pause:"; psq u36j3 "select conname from pg_constraint where conrelid = 'pause'::regclass and contype = 'f'"
  echo "(iv) all three - H2, in the harness JVM's memory, ddl-auto validate:"
  LIBS=$LIB; MC=probe.f.FMain; V=(); A=('--spring.datasource.url=jdbc:h2:mem:u36j4;DB_CLOSE_DELAY=-1' "${HQ[@]}" $VAL); hrun; hview; }
# anchor: TiffinBox on PostgreSQL + the harness's driver - B, A, A', the refusal
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
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 120 ]; do sleep 0.25; i=$((i + 1)); done
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
U36M=U36MARK
mark() { printf '%s %s\n' "$U36M" "$1" >> .harness/run.out; }
seg() { awk -v a="$U36M $1 start" -v b="$U36M $1 end" '$0 == a { f = 1; next } $0 == b { f = 0 } f' .harness/run.out; }
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
  echo "  -> $code"
  code=$(curl -s --noproxy '*' -o .harness/body-l -w '%{http_code}' -H 'Accept: application/json' "http://127.0.0.1:$p/customers" 2> /dev/null || true)
  echo "\$ curl -s --noproxy '*' -H 'Accept: application/json' http://127.0.0.1:$p/customers"
  echo "  -> $code · customers listed: $($G -o '"name":"[A-Za-z]*"' .harness/body-l | wc -l | tr -d ' ') ($($G -o '"name":"[A-Za-z]*"' .harness/body-l | sed 's/"name":"//; s/"$//' | paste -sd' ' -))"; }
tbpg() { local t=$1 p=$2 d=$3; shift 3
  (umask 077 && printf '%s' "jdbc:postgresql://127.0.0.1:20158/$d?user=sa&password=$PW" > .harness/$t/$UF)
  start "$(at .harness/$t $p "$L_TPG") --logging.level.org.hibernate.orm.connections.pooling=warn $*" $p "tiffinbox/jdbc-url tiffinbox/shutdown-token"; }
treeis() { case $1 in before) echo "before/, the anchor before this change" ;; after) echo "after/'s jar" ;; *) echo "after/ copied again and built again" ;; esac; }
anchor() { local f t p q d L
  echo "the change - after/ against before/ (diff -rq, the file names):"
  diff -rq before after | sed -E 's#^Files before/(.*) and after/.* differ$#  changed: \1#; s#^Only in before/(.*): (.*)$#  deleted: \1/\2#; s#^Only in after/(.*): (.*)$#  new: \1/\2#' | sort
  echo "  the YAML's ddl-auto line, after/: $($G -E '^ +ddl-auto: ' after/$YM | sed 's/^ *//')"
  for f in before:20150:20150:u36b:B after:20151:20152:u36a:A after2:20153:20153:u36a2:A2; do t=${f%%:*}; p=$(echo "$f" | cut -d: -f2); q=$(echo "$f" | cut -d: -f3); d=$(echo "$f" | cut -d: -f4); L=${f##*:}
    echo "$L - TiffinBox on PostgreSQL + the harness's driver (.m2-demo/$PGJ on its class path; its lib/ holds none), from .harness/$t ($(treeis $t)), a fresh database $d; its URL in its own config tree, secrets/tiffinbox/jdbc-url (mode 0600):"
    pgdb $d
    echo "$L, JVM 1 of 2 - port $p:"
    tbpg $t $p $d; up $p; ready $p; flylines
    kavya $p
    echo "  the second connection - customers: $(psq $d 'select count(*) from customer' | sed -n 's/^    //p' | tail -1) rows · the history table:"; hist $d
    stopit $p; logtok
    echo "$L, JVM 2 of 2 - the restart, port $q, the same database:"
    tbpg $t $q $d; up $q; ready $q; flylines
    see $q
    [ $t != after ] || { rq html /dashboard $q text/html; rq json /dashboard $q application/json; echo "  its JSON: $(sed -E 's/"timestamp":"[^"]*"/"timestamp":"…"/' .harness/body-json)"; }
    echo "  the second connection - customers: $(psq $d 'select count(*) from customer' | sed -n 's/^    //p' | tail -1) rows · the history table:"; hist $d
    stopit $q; logtok; rm -f .harness/$t/$UF; done
  echo "the refusal - after/ with --spring.flyway.enabled=false on a fresh database, port 20155 (R.303, a filed step):"
  pgdb u36off; tbpg after 20155 u36off --spring.flyway.enabled=false; gone 20155
  echo "  it never listened; exit $LASTE · its line (grep -o): $($G -m1 -oE 'Schema validation: missing table \[customer\]' .harness/run.out || echo none) · org.flywaydb lines: $($G -cE ' o\.f\.[A-Za-z.]+ +: ' .harness/run.out || true)"
  logtok; rm -f .harness/after/$UF
  echo "Flyway's version in TiffinBox's JVMs (R.329): Boot prints none; the jar on their class path, the file VersionPrinter.getVersion() reads (unzip -p flyway-core-12.4.0.jar org/flywaydb/core/internal/version.txt): $(unzip -p .harness/$LIB/flyway-core-12.4.0.jar org/flywaydb/core/internal/version.txt | tr -d '\r\n')"; }
# fail: V3's second statement misspelt - PostgreSQL, then H2 over TCP
FL=--spring.flyway.locations=filesystem:../mig
fail() { echo "fail - V1, V2 and a V3 whose second statement is misspelt (ADD COLUM), the harness over after/'s libraries, migrations from a folder:"
  echo "  .harness/mig/fail/V3__add_phone.sql:"; sed 's/^/    /' .harness/mig/fail/V3__add_phone.sql
  echo "on PostgreSQL - run 1:"
  pgdb u36f; LIBS=$LIB; MC=probe.f.FMain; V=(-Dpg.db=u36f -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}" $VAL $FL/fail); hrun; hview
  echo "  the second connection - the history table:"; hist u36f; echo "  customer's columns:"; cols u36f
  echo "on PostgreSQL - run 2, the same files:"; hrun; hview
  echo "  the second connection - the history table:"; hist u36f
  echo "on PostgreSQL - the file fixed (.harness/mig/fixed), no repair:"
  A=("${HQ[@]}" $VAL $FL/fixed); hrun; hview
  echo "  the second connection - the history table:"; hist u36f; echo "  customer's columns:"; cols u36f
  local H=jdbc:h2:tcp://127.0.0.1:20157/mem:u36f
  echo "on H2 over TCP (the H2 server, mem:u36f) - emptied first (a database on the server lives as long as the server), then run 1:"
  h2q u36f 'DROP ALL OBJECTS'
  V=(); A=("--spring.datasource.url=$H;DB_CLOSE_DELAY=-1" --spring.datasource.username=sa "${HQ[@]}" $VAL $FL/fail); hrun; hview
  echo "  the second connection - the history table:"; h2q u36f "$H2HQ"; echo "  customer's columns:"; h2q u36f "$H2CQ"
  echo "on H2 - run 2, the same files:"; hrun; hview
  echo "on H2 - the file fixed alone (.harness/mig/fixed), no repair:"
  A=("--spring.datasource.url=$H;DB_CLOSE_DELAY=-1" --spring.datasource.username=sa "${HQ[@]}" $VAL $FL/fixed); hrun; hview
  echo "on H2 - the file fixed + repair(): a FlywayMigrationStrategy bean (harness/src/probe/f/FMain.java), repair() then migrate():"
  $G -A6 '^    @Bean$' harness/src/probe/f/FMain.java | sed 's/^/    /'
  A=("--spring.datasource.url=$H;DB_CLOSE_DELAY=-1" --spring.datasource.username=sa "${HQ[@]}" $VAL $FL/fixed --probe.repair=true); hrun; hview
  echo "  the second connection - the history table:"; h2q u36f "$H2HQ"; echo "  customer's columns:"; h2q u36f "$H2CQ"
  echo "on H2 - the half-applied column dropped by the second connection, then repair() and migrate() again:"
  h2q u36f 'ALTER TABLE customer DROP COLUMN phone'
  hrun; hview
  echo "  the second connection - the history table:"; h2q u36f "$H2HQ"; echo "  customer's columns:"; h2q u36f "$H2CQ"; }
# traps: PostgreSQL, the harness
traps() { echo "traps - PostgreSQL, the harness over after/'s libraries:"
  LIBS=$LIB; MC=probe.f.FMain
  echo "(i) a checksum mismatch - V1 and V2 applied, then V1's first line (its comment) edited (.harness/mig/edited):"
  pgdb u36c; V=(-Dpg.db=u36c -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}" $VAL $FL/base); hrun; hview
  echo "  the edit (diff, V1 applied against V1 edited):"; diff .harness/mig/base/V1__customer_and_pause.sql .harness/mig/edited/V1__customer_and_pause.sql | $G -E '^[<>]' | sed 's/^/    /' || true
  A=("${HQ[@]}" $VAL $FL/edited); hrun; hview
  echo "  the second connection - V1's checksum in the history table: $(psq u36c 'select checksum from flyway_schema_history where version = '"'1'" | sed -n 's/^    //p' | tail -1)"
  echo "(ii) a schema seeded without Flyway (V1 and V2 run by psql), then Flyway with its defaults:"
  pgdb u36n
  for s in V1__customer_and_pause.sql V2__seed.sql; do echo "\$ docker -H \"\$DH\" exec -i $CN psql -U sa -d u36n -q -v ON_ERROR_STOP=1 < .harness/mig/base/$s"; dk exec -i "$CN" psql -U sa -d u36n -q -v ON_ERROR_STOP=1 < .harness/mig/base/$s > .harness/psql.out 2>&1 || die "psql could not apply $s"; done
  echo "  the second connection - the tables in public:"; tables u36n
  V=(-Dpg.db=u36n -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}" $VAL $FL/base); hrun; hview
  echo "(iii) the same database, --spring.flyway.baseline-on-migrate=true (the baseline at version 1, Boot's default):"
  A=("${HQ[@]}" $VAL $FL/base --spring.flyway.baseline-on-migrate=true); hrun; hview
  echo "  the second connection - the history table:"; hist u36n
  echo "(iv) a fresh database seeded the same way, the baseline at version 2 (--spring.flyway.baseline-version=2):"
  pgdb u36n2
  for s in V1__customer_and_pause.sql V2__seed.sql; do dk exec -i "$CN" psql -U sa -d u36n2 -q -v ON_ERROR_STOP=1 < .harness/mig/base/$s > .harness/psql.out 2>&1 || die "psql could not apply $s"; done
  V=(-Dpg.db=u36n2 -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}" $VAL $FL/base --spring.flyway.baseline-on-migrate=true --spring.flyway.baseline-version=2); hrun; hview
  echo "  the second connection - the history table:"; hist u36n2
  echo "(v) out of order - V1 and V2 applied, then a V1_5 added (.harness/mig/ooo):"
  pgdb u36o; V=(-Dpg.db=u36o -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}" $VAL $FL/base); hrun; hview
  A=("${HQ[@]}" $VAL $FL/ooo); hrun; hview
  echo "  and with --spring.flyway.out-of-order=true:"
  A=("${HQ[@]}" $VAL $FL/ooo --spring.flyway.out-of-order=true); hrun; hview
  echo "  the second connection - the history table:"; hist u36o
  echo "(vi) clean - Flyway's own API (probe.f.FApi, no Spring), the same database:"
  MC=probe.f.FApi; V=(-Dpg.db=u36o -Dpg.pwfile=../secrets/pgpw); A=(filesystem:../mig/ooo); hrun; hview
  echo "  the second connection - the tables in public:"; tables u36o; MC=probe.f.FMain; }
sqlseg() { sed -n "${1},${2}p" .harness/run.out | $G -cE ' org\.hibernate\.SQL +: ' || true; }
seven7() { local t n0
  for t in before after; do
    echo "the seven - $t/'s jar, port 20154, a fresh JVM, its database mem:u36s7$t on the H2 server, Hibernate's SQL logger on:"
    h2q u36s7$t 'DROP ALL OBJECTS'
    start "$(tb $t 20154 u36s7$t)" 20154; up 20154; ready 20154; n0=$(lines)
    echo "  its log before the seven: Migrating lines $($G -c 'Migrating schema "PUBLIC" to version' .harness/run.out || true) · 'Successfully applied 2 migrations' $($G -c 'Successfully applied 2 migrations' .harness/run.out || true) · Flyway's H2 WARN $($G -c 'newer than the version Flyway has been verified with' .harness/run.out || true)"
    echo "\$ \$CURLSET 20154 .harness/$t/$TF"
    "$CURLSET" 20154 ".harness/$t/$TF" | $G ' -> ' > .harness/responses.txt || true
    awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' .harness/responses.txt > .harness/seven-$t.txt
    gone 20154
    echo "  exit $LASTE · the seven responses: $(wc -l < .harness/seven-$t.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven-$t.txt)"
    echo "  its log's org.hibernate.SQL lines during the seven: $(sqlseg "$((n0 + 1))" '$')"
    logtok; rm -f .harness/run.out; done
  echo "  the seven, after/ against before/: lines that differ: $(diff .harness/seven-before.txt .harness/seven-after.txt | $G -c '^[<>]' || true)"; }
summ() { $G -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | tail -1 | sed -E 's/.*Tests run: ([0-9]+), Failures: ([0-9]+), Errors: ([0-9]+), Skipped: ([0-9]+)$/tests \1 · failures \2 · errors \3 · skipped \4/'; }
tests() { local c e=0 n s t
  echo "TiffinBox's tests - after/ copied to .harness/tests, the README's line, offline:"
  rm -rf .harness/tests; copy after .harness/tests
  c=$(off .harness/tests "$R_TEST"); echo "\$ $c"
  (eval "$c") > .harness/tests.log 2>&1 < /dev/null & mpid=$!; wait "$mpid" || e=$?; mpid=""
  n=$($G -cE '^\[INFO\] Download(ing|ed) from ' .harness/tests.log || true)
  echo "  exit $e · $($G -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/tests.log || echo 'no BUILD line') · offline: $( [ "$n" = 0 ] && echo yes || echo "no - $n lines say Maven downloaded")"
  echo "  Surefire's reports ($SR, read by harness/surefire.py):"; python3 -I harness/surefire.py .harness/tests/$SR | sed 's/^/  /'
  s=$(summ .harness/tests.log); t=$(python3 -I harness/surefire.py .harness/tests/$SR | sed -n 's/^  in all: [0-9]* reports · //p')
  echo "  Surefire's console summary (its Results line): ${s:-none} · the reports' sum the same: $( [ -n "$s" ] && [ "$s" = "$t" ] && echo yes || echo no)"
  echo "  its log's Flyway lines - 'Successfully applied 2 migrations': $($G -c 'Successfully applied 2 migrations to schema "PUBLIC", now at version v2' .harness/tests.log || true) · 'is up to date. No migration necessary': $($G -c 'Schema "PUBLIC" is up to date. No migration necessary.' .harness/tests.log || true) · Flyway's H2 WARN ('newer than the version Flyway has been verified with'): $($G -c 'Using H2 2.5.250 which is newer than the version Flyway has been verified with. The latest verified version of H2 is 2.3.232.' .harness/tests.log || true)"
  echo "  the token in its log and every report: $(raw "$TOKEN" .harness/tests.log .harness/tests/$SR/*) times"; }
X34=$(md5 -q ../c7-unit34/xcheck.sql)
XA=('--spring.datasource.url=jdbc:h2:mem:x36;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml "$CORE" --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
xcheck() {
  echo "Hibernate's DDL over after/'s libraries without Flyway's three jars (.harness/lib-nofly: no Flyway in this JVM) - probe.x.XMain, scripts.action=create (a file, never run):"
  rm -f .harness/run/hibernate-ddl.sql; LIBS=lib-nofly; MC=probe.x.XMain; V=(); A=("${XA[@]}"); hrun; hview
  [ -f .harness/run/hibernate-ddl.sql ] || die "xcheck: no script"
  mv .harness/run/hibernate-ddl.sql .harness/ddl-after.sql
  echo "  .harness/ddl-after.sql - every line:"; sed -E 's/FK[0-9a-z]{20,}/FK<name>/g; s/^/    /' .harness/ddl-after.sql
  echo "  after/'s md5: $(md5 -q .harness/ddl-after.sql) · the filed xcheck.sql: $(md5 -q xcheck.sql) · cmp: $(cmp -s .harness/ddl-after.sql xcheck.sql && echo 'the same, byte for byte' || echo differ) · the index lesson's xcheck.sql: $X34 · diff: $(diff ../c7-unit34/xcheck.sql .harness/ddl-after.sql | $G -c '^[<>]' || true) lines"
  echo "  V1 (after/$MG/V1__customer_and_pause.sql), every line:"; sed 's/^/    /' after/$MG/V1__customer_and_pause.sql
  echo "  R.80 - V1 against Hibernate's script, read off the two files (python3 -I harness/chk36.py r80):"
  python3 -I -B harness/chk36.py r80 after/$MG/V1__customer_and_pause.sql .harness/ddl-after.sql | sed 's/^/    /'; }
# exercise: the README's commands, then the solution's - in ONE shell, bash, then zsh
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2
  rm -rf .harness/ex; rm -f .harness/ex-*.st .harness/ex-*.out .harness/mine.log
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 1200 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after 300 s"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines:"
  echo "  the block's exit $e1 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "  the shell is now in: $(where "$d1")"
  echo "  then the solution's lines, in the same shell - the block's exit $e2 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the classes it compiled: $(cd .harness/ex/classes 2> /dev/null && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -) · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines"; }
exercise() { local setup sol
  setup=$(block exercise/README.md); sol=$(block exercise/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  printf '%s\n' "$sol" | sed -n 1p | $G -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  [ "$(diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | $G -c '^[<>]')" = 2 ] || die "SOLUTION.md's block must be the README's with one line changed"
  printf '%s\n' "$setup" | $G -qF -- '"${A[@]}"' && printf '%s\n' "$setup" | $G -qE '^A=\(' || die "exercise/README.md must pass its arguments as an array, A"
  printf '%s\n' "$setup" | $G -E ' java ' | $G -qF "perl -e 'alarm " || die "exercise/README.md's JVM must run under its alarm (R.247)"
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
EXQ="Your turn: the README's third migration failed halfway on H2, and every migrate since refuses. Make it apply."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
if [ -f "$BLD/s703.py" ]; then cap guard guard; chk guard .r-guard.out; pub guard
else echo "  guard: the course's _builders folder is not beside this repository ($BLD) - the capture is the author's tooling; skipped, not hashed" >&3; fi
cap jars jars; chk jars .r-jars.out "$NL"; pub jars
cap anchor anchor; chk anchor .r-anchor.out; pub anchor
cap fail fail; chk fail .r-fail.out; pub fail
cap traps traps; chk traps .r-traps.out; pub traps
cap seven seven7; chk seven .r-seven.out "$S466"; pub seven
cap tests tests; chk tests .r-tests.out; pub tests
cap xcheck xcheck; chk xcheck .r-xcheck.out "$X34" "$(md5 -q xcheck.sql)"; pub xcheck
cap exercise exercise; chk exercise .r-exercise.out "$EXW"; pub exercise
for f in exercise/README.md exercise/SOLUTION.md; do
  w=$(python3 -I -B harness/chk36.py wib .r-exercise.out "$f"); [ "$(wib "$f")" = "$w" ] || die "$f's \"What it prints\" block is not what its lines printed: $(diff <(wib "$f") <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "exercise: broken and solved print the same (R.196)"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
echo "  exercise: each file's What it prints = the run (bash's), the two differ (R.196); the spoken line $EXW words (wc -w)"
# R.302: every line of README.md's ```text blocks is a line a run printed
cat .r-*.out .harness/chk-*.out 2> /dev/null | sed -E 's/^ +//' > .harness/printed.txt
TX=$(awk '/^```text$/ { b = 1; next } b && /^```$/ { b = 0; next } b && NF { sub(/^ +/, ""); print }' README.md | while IFS= read -r l; do $G -qxF -- "$l" .harness/printed.txt || printf '%s\n' "$l"; done | head -3 | cut -c1-160 | paste -sd';' -)
[ "$($G -c '^```text$' README.md)" -gt 0 ] && [ -z "$TX" ] || die "R.302: README.md's text blocks must be lines the runs printed - not printed: ${TX:-no text block}"
echo "  R.302: README.md's $($G -c '^```text$' README.md) text blocks - every line one the runs printed"
VS="the values the video may say: on PostgreSQL 18.6 and H2 2.5.250, Flyway 12.4.0, Spring Boot 4.1.2, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - $VALS"
printf '%s\n' "$VS" > .harness/values.txt
$G -qF -- "$VS" README.md || die "README.md does not state the values these captures give - a typed value (the line is in .harness/values.txt): $($G -oE 'the values the video may say: [^*`]*' README.md | head -1 | cut -c1-200)"
echo "  README.md states the captures' values (.harness/values.txt, $(wc -c < .harness/values.txt | tr -d ' ') bytes)"
# hygiene
for f in .harness/raw-* .harness/rawpw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the token or the password ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/SOLUTION.md receipts.md5 .harness/*.log; do [ "$(raw "$TOKEN" "$f")" = 0 ] && [ "$(raw "$PW" "$f")" = 0 ] || die "$f holds the token or the password, raw"; done
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$LOGS" -gt 0 ] && [ "$PGJVM" -gt 0 ] && [ "$FLYJVM" -gt 0 ] || die "no JVM ran, or none on PostgreSQL, or none loaded Flyway"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  [ "$f" = .r-guard.out ] || ! $G -vE '^    [-+]' "$f" | $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) |Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a time or Boot's seconds"
  ! $G -qE '^ *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][T ]|"timestamp":"?[0-9]|(exec|handler|task)-[0-9]|started on [A-Z]' "$f" || die "$f holds a log time, a timestamp or a thread number"
  ! $G -qE 'using Java [0-9]|PROBE version: Java [0-9]|Darwin|arm64|aarch64|musl|Debian|pgdg' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'execution time [0-9]|[0-9] ms\b|[0-9]+ ms\)' "$f" || die "$f holds Flyway's execution time or a millisecond figure, unmasked (R.264)"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'password=[^<*]' "$f" || die "$f holds a password in a URL"
  ! $G -oE 'https?://[^ /]*' "$f" | $G -qvxE 'http://127\.0\.0\.1:2015[0-5]' || die "$f holds a URL (only TiffinBox's own loopback ports may appear)"; done
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ (])java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned"
  ! $G -E '^ *\$ .*(^|[ (])java -D' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM without its alarm (R.247)"
  ! $G -E '^ *\$ .*docker ' "$f" | $G -vF -- 'docker -H "$DH" ' > /dev/null || die "$f calls docker without the pinned socket (R.332)"; done
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness (R.195)"
echo "  hygiene: raw token and password copies after mask: 0 in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, $(ls .r-*.out | wc -l | tr -d ' ') captures and every log ($LOGS JVM logs, $PGJVM of the harness's on PostgreSQL, $FLYJVM that loaded Flyway - each with its version line, R.329); no path, unit number (guard's builder notes aside), time, millisecond figure, execution time, thread number, OS token, password, URL or stack frame in any capture; every JVM pinned and under its alarm; no H2 file"
# ---- the end: the H2 server, the container and its volume, the anchor, the ports ----------------------------------------------
if [ -n "$spid" ] && kill "$spid" 2> /dev/null; then wait "$spid" 2> /dev/null || true; fi; spid=""
pgrm; [ -z "$(dk ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "the container $CN is still there"
VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' '); IMGS1=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -)
[ "$VOL1" = "$VOL0" ] || die "R.322: the volume count moved, $VOL0 -> $VOL1 - a container left its volume (an rm -f without -v)"
[ "$IMGS1" = "$IMGS0" ] || die "the images moved over this run - nothing may be pulled"
echo "  docker at the end: the container removed with its volume (rm -fv); volumes $VOL0 -> $VOL1 (R.322); images $NI0, the same list (nothing pulled)"
beforetree end; anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 20150-20159 at the end - TiffinBox bound 20150-20155 in turn and stopped, the H2 server 20157 and stopped, the container 20158 and removed; 20156 and 20159 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit36: every capture 3/3 and = published; every spoken number asserted; 0 raw tokens, 0 raw passwords; the volume count unchanged; no port bound but 20150-20155, 20157 and 20158"
