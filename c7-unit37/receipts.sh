#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Liquibase, and Choosing - this unit's receipts. A harness unit with no anchor change (brief flag 5): anchor is the link to
# ../c7-unit36/after (= c7-tiffinbox until unit 38 moves it; its tree's hash pinned). TiffinBox keeps Flyway; Liquibase runs only in the
# harness's JVMs, over the anchor's libraries + the harness's Liquibase jars (+ the harness's driver on PostgreSQL), on the same V1 + V2
# restated as a changelog (harness/db/changelog/, on the class path, named classpath:db/changelog/... - R.328). Every JVM that may load
# Liquibase runs behind a loopback proxy trap (harness/trap.py on 127.0.0.1:20166: it logs the request line, answers 403 and forwards
# nothing) and carries spring.liquibase.analytics-enabled=false (or -Dliquibase.analytics.enabled=false) - except the ONE labelled default
# run of the analytics capture; the trap's lines are counted per JVM (R.317). Seven captures, each run three times and hashed; a hash that
# differs from receipts.md5 stops the run; every number and string the video says is asserted right after its capture by harness/chk37.py
# against another witness of the same run (psql or H2's Shell as a second connection, beside the tools' own lines), never a typed figure.
#   formats    the changelog in SQL, YAML and XML - three labelled JVMs, PostgreSQL, each on a fresh database
#   analytics  the network at start: no key (the labelled default run), the key, and a Flyway JVM - the trap's lines each
#   lock       the failure receipt: B a start killed (kill -9) mid-changeset, the lock left, the next start refused; A the lock released by
#              Liquibase's API and the start run; A' the same on a fresh database; Boot's keys read off its metadata
#   fail       a failed changeset on PostgreSQL and H2 over TCP; the path as identity; rollback right and wrong; the checksum; both tools
#              on one class path; Flyway Community's undo
#   compare    the comparison table - every cell a line this capture prints, read off the captures above (R.261)
#   xcheck     Hibernate's DDL script over the anchor's libraries, against the Flyway lesson's xcheck.sql
#   exercise   exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i shell -
#              /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# The anchor is COPIED under .harness/ and built there, never in place, offline, its tests skipped (this unit runs none). Every JVM runs
# under an alarm (perl -e 'alarm N; exec ...'; R.247). Every docker call names its socket (docker -H "$DH", R.332); the container is
# removed with its volume (rm -fv) and the volume count is asserted unchanged (R.322). Ports (20160-20169): 20166 the trap · 20167 the H2
# TCP server · 20168 the container · 20160-20165 and 20169 never bound (the harness JVMs bind none). Nothing leaves the machine.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c7u37-pg
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.332): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
pid=""; mpid=""; xpid=""; spid=""; tpid=""; CSTARTED=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.l.") || index($0, "probe.x.") || index($0, "org.h2.tools.") || index($0, "harness/trap.py") || $3 ~ /(^|\/)javac$/ || index($0, "jdk.compiler/com.sun.tools.javac") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "exec c7u37-pg") || index($0, "--name c7u37-pg")) { print $1 }' | paste -sd' ' -) || l=""
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
trap 'trap "" INT TERM; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid" "$spid" "$tpid"; do if [ -n "$p" ] && kill -9 "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; pgrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp find docker unzip hostname /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY LIQUIBASE_CANARY FLYWAY_CANARY PGPASSWORD PGOPTIONS PGHOST PGUSER DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|LIQUIBASE_[A-Za-z0-9_]*|FLYWAY_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
[ -e secrets ] && die "this folder holds a secrets/ - the password lives under .harness/ only"
# ---- docker: the pinned socket and non-empty baselines before any comparison (R.332), the volume count (R.322) ----------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that socket? (R.332: every docker call names its socket)"
IMGS0=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -); NI0=$(printf '%s\n' "$IMGS0" | wc -w | tr -d ' ')
VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI0" -ge 1 ] && [ "$VOL0" -ge 1 ] || die "R.332: the baselines must not be empty - images $NI0, volumes $VOL0 on $DH (an empty list compares equal to anything)"
dk image inspect "$IMG" > /dev/null 2>&1 || die "the image $IMG is not on this machine - pull it once yourself (this script never pulls)"
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · info exit 0 · images $NI0 · volumes $VOL0 (the baselines, both non-empty) · the image: $IMG is present (never pulled)"
# ---- the anchor: the link, its tree pinned, the live folder's note (R.211), its YAML's ddl-auto (R.330) ----------------------
[ -L anchor ] && [ "$(readlink anchor)" = ../c7-unit36/after ] || die "anchor must be the link to ../c7-unit36/after - the Flyway lesson's frozen tree"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "the anchor's pom.xml or README.md is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/hibernate-ddl.sql ] && die "anchor/ holds a secrets/, a target/ or a hibernate-ddl.sql - it is a frozen tree, never built in place"
T36='44 ae7b6ac3a74b7c2a852ffee039d96619'            # unit 36's after/ at its commit 877936e: 44 files (harness/tree37.py)
anchortree() { local t; t=$(python3 -I harness/tree37.py anchor/) || die "anchor/'s tree could not be hashed"
  [ "$t" = "$T36" ] || die "R.211: anchor/ (../c7-unit36/after, a shipped unit's frozen tree) is not the tree this unit stands on: $t, pinned $T36"
  echo "  anchor/'s tree ($1): python3 -I harness/tree37.py anchor/ -> $t = pinned (unit 36's after/, the Flyway lesson's tree)"; }
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox: empty - anchor/ = ../c7-tiffinbox"
  else echo "  note ($1): the live anchor moved on after this unit (unit 38 moves it next); this unit stands on c7-unit36/after, pinned - diff -rq anchor/ ../c7-tiffinbox: $(printf '%s\n' "$d" | wc -l | tr -d ' ') lines ($(printf '%s\n' "$d" | head -2 | sed "s#$UP/##g" | paste -sd';' -))"; fi; }
anchortree start; anchornote start
YM=tiffinbox-web/src/main/resources/application.yaml
DA=$(sed -n -E 's/^ +ddl-auto: *([a-z-]+) *$/\1/p' anchor/$YM | paste -sd' ' -)
[ "$DA" = validate ] || die "R.330: anchor/'s application.yaml ships ddl-auto: ${DA:-nothing} - 36/after ships validate"
VAL=--spring.jpa.hibernate.ddl-auto=$DA
echo "  R.330: anchor/$YM ships ddl-auto: $DA (read off the file) - every harness JVM here is given $VAL (the harness's class path holds the anchor's libraries, not its web module's YAML)"
M2="$PWD/.m2-demo"
XD=tiffinbox-web/target/extracted
MG=tiffinbox-core/src/main/resources/db/migration
PGJ=org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar
LQJ='org/springframework/boot/spring-boot-liquibase/4.1.2/spring-boot-liquibase-4.1.2.jar org/liquibase/liquibase-core/5.0.4/liquibase-core-5.0.4.jar com/opencsv/opencsv/5.12.0/opencsv-5.12.0.jar org/apache/commons/commons-text/1.15.0/commons-text-1.15.0.jar org/apache/commons/commons-collections4/4.6.0/commons-collections4-4.6.0.jar org/apache/commons/commons-lang3/3.20.0/commons-lang3-3.20.0.jar commons-io/commons-io/2.22.0/commons-io-2.22.0.jar'
HFILES='chk37.py db dur7.py logback.xml s37.py src trap.py tree37.py'
SFILES='probe/l/FUndo.java probe/l/LApi.java probe/l/LMain.java probe/l/Run.java probe/l/V.java probe/l/ex/Ex.java probe/x/XMain.java'
CFILES='changelog.sql changelog.xml changelog.yaml ex/diner.sql fail/changelog.sql lock/changelog.sql lockok/changelog.sql sum/changelog.sql'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5 xcheck.sql; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] && [ "$(cd harness/db/changelog && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$CFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
cmp -s harness/src/probe/x/XMain.java ../c7-unit29/harness/src/probe/x/XMain.java || die "harness/src/probe/x/XMain.java is not unit 29's, byte for byte"
cmp -s harness/tree37.py ../c7-unit33/harness/tree33.py || die "harness/tree37.py is unit 33's tree33.py, byte for byte"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="20160 20161 20162 20163 20164 20165 20166 20167 20168 20169"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
[ -z "$(dk ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "a container named $CN exists - an interrupted run's? remove it with its volume (rm -fv, on the pinned socket)"
rm -rf .harness; mkdir -p .harness/run .harness/hc .harness/secrets .harness/v
echo "  ports: 20160-20169 free at the start"

# ---- the changelogs: V1 + V2 restated (R.302: their lines counted by wc -l, never typed) ------------------------------------------
CL=harness/db/changelog
[ "$($G -v -E '^--|^$' $CL/changelog.sql)" = "$( (sed 1d anchor/$MG/V1__customer_and_pause.sql; sed 1d anchor/$MG/V2__seed.sql) )" ] || die "harness/db/changelog/changelog.sql's statements must be anchor/'s V1 and V2, byte for byte (comments and blank lines aside)"
[ "$(diff $CL/changelog.sql $CL/fail/changelog.sql | $G -c '^>')" = 4 ] && [ "$(diff $CL/changelog.sql $CL/fail/changelog.sql | $G -c '^<')" = 0 ] && $G -qxF 'ALTER TABLE customer ADD COLUM email VARCHAR(80);' $CL/fail/changelog.sql || die "fail/changelog.sql must be changelog.sql + a changeset 3 whose second statement is misspelt (ADD COLUM)"
[ "$(diff $CL/changelog.sql $CL/lock/changelog.sql | $G '^>' | paste -sd'|' -)" = '> |> --changeset tiffinbox:3|> SELECT pg_sleep(30);' ] || die "lock/changelog.sql must be changelog.sql + a changeset 3 that sleeps in the server"
[ "$(diff $CL/changelog.sql $CL/lockok/changelog.sql | $G '^>' | paste -sd'|' -)" = '> |> --changeset tiffinbox:3|> SELECT 1;' ] || die "lockok/changelog.sql must be changelog.sql + a changeset 3 that does nothing"
[ "$(diff $CL/changelog.sql $CL/sum/changelog.sql | $G -c '^[<>]')" = 2 ] && $G -q 'customer_id); -- edited after it ran$' $CL/sum/changelog.sql || die "sum/changelog.sql must be changelog.sql with one comment added to changeset 1's index line"
echo "  the changelogs (harness/db/changelog/): changelog.sql's statements = anchor/'s V1 + V2 (comments aside); fail/ adds changeset 3 (ADD COLUMN, then ADD COLUM); lock/ adds changeset 3 = a pg_sleep, lockok/ = SELECT 1; sum/ = changelog.sql + one comment on changeset 1"

# ---- the prose gates ----------------------------------------------------------------------------------------------------------
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s37.py harness/dur7.py $PROSE) || die "the prose gate did not run (or its self-test failed)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
echo "  prose, per sentence (s37, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test): dur7 words 0 · S4.7's and R.310's families 0 · R.301's family 0 but beside a printed count · R.317 a Liquibase run without its key or \"offline by default\" 0 · R.328 a rollback read off its done, or a changelog named outside the class path 0 · R.314 a failure unscoped or on the wrong database 0 · R.312 the refusal as the control 0 · an adjective in the comparison 0 · R.302 a typed count 0 · R.190 tests as a witness 0 · R.287 0 · R.224 a call-back without its title 0 · \"Hibernate generates\" 0 - over README.md and exercise/"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
dishes() { $G -rniwE -- "$DISH" "$@" 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true; }
DN=$(dishes README.md exercise harness)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, any case, over README.md, exercise/ and harness/)"
PH=$($G -rnE 'EXERCISE-[A-Z-]*OUTPUT|[A-Z]+-OUTPUT\b|[A-Z]+-PARAGRAPH\b|TODO|TBD|PLACEHOLDER' README.md exercise 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder line in this unit's prose: $PH"
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f" | $G -v '^ *$' || true)" ] || die "$f must hold one \"What it prints\" line and, under it, a block that is not empty"; done
echo "  placeholders: 0 · each exercise file's \"What it prints\" block not empty"
prose() { awk -v f="$1" '/^<!-- (values|compare table): begin -->$/ { v = 1; next } /^<!-- (values|compare table): end -->$/ { v = 0; next } /^```/ { b = !b; next } !v && !b { print f ":" NR ": " $0 }' "$1"; }
SQLRE='create table (customer|pause|diner|databasechangelog)|insert into (customer|pause|databasechangeloglock)|alter table customer add|select pg_sleep|pg_terminate_backend\(|drop database|select count|update databasechangeloglock'
TS=$(for f in $PROSE; do prose "$f"; done | $G -iE "$SQLRE" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string in the prose (R.225): $TS"
TC=$($G -nE '7f69''42f0|ae7b''6ac3a7' harness/chk37.py harness/src/probe/l/*.java 2> /dev/null | cut -c1-120 | head -3 | paste -sd';' - || true)
[ -z "$TC" ] || die "R.302: a printed md5 typed in the harness: $TC"
echo "  typed SQL strings 0 in the prose (outside printed blocks, the values line and the compare table) · R.302: no printed md5 typed in chk37.py or the harness's sources"

# ---- static checks of this script and the harness - before anything runs --------------------------------------------------
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
DK=$($G -v '^ *#' receipts.sh | $G -nE '\bdocker (run|exec|rm|ps|port|info|images|volume|image|pull|events)\b' | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.332: receipts.sh calls docker without the pinned socket (every call is dk, or a README line with -H \"\$DH\"): $DK"
! $G -v '^ *#' receipts.sh | $G -qE 'rm -f'' "?\$CN|rm -f'' c7u37' || die "R.322: receipts.sh removes the container without its volume (rm -fv)"
! $G -rqE 'Thread\.sleep|while *\(true\)|TimeUnit\.[A-Z]+\.sleep|LockSupport\.park' harness/src || die "a harness sleeps or polls (S4.18)"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
echo "  static: no kill by name; every docker call on the pinned socket (R.332); the container removed with its volume, rm -fv (R.322); no sleep in the harness (grep: 0 Thread.sleep); no harness class in com.tiffinbox"

# ---- the commands: read from anchor/README.md, the anchor's own, and from this README ---------------------------------------
readme() { $G -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 240; exec @ARGV'"
TRAPO='-Dhttp.proxyHost=127.0.0.1 -Dhttp.proxyPort=20166 -Dhttps.proxyHost=127.0.0.1 -Dhttps.proxyPort=20166 -Dhttp.nonProxyHosts='
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/after/$XD/lib/*:.harness/lq/*\" harness/src/probe/l/V.java harness/src/probe/l/Run.java harness/src/probe/l/LMain.java harness/src/probe/l/LApi.java harness/src/probe/l/FUndo.java harness/src/probe/x/XMain.java")
L_H=$(mine "$AL java $JL $TRAPO -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc\$CPC:../after/$XD/lib/*\$CPX\" \$MC \"\${A[@]}\"")
L_TRAP=$(mine "cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' python3 -I ../../harness/trap.py 20166 ../trap.log")
L_H2S=$(mine "cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' java $JL -Dh2.bindAddress=127.0.0.1 -cp \"../after/$XD/lib/h2-2.5.250.jar\" org.h2.tools.Server -tcp -tcpPort 20167 -ifNotExists")
L_SHELL=$(mine "$AL java $JL -cp \"../after/$XD/lib/h2-2.5.250.jar\" org.h2.tools.Shell -url \"jdbc:h2:tcp://127.0.0.1:20167/mem:\$DB\" -user sa -password '' -sql \"\$Q\"")
L_RUN=$(mine "docker -H \"\$DH\" run -d --pull never --name $CN -p 127.0.0.1:20168:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v \"\$U/.harness/secrets/pgpw:/run/pgpw:ro\" $IMG")
L_READY=$(mine "docker -H \"\$DH\" exec $CN pg_isready -U sa -h 127.0.0.1 -q")
L_DB=$(mine "docker -H \"\$DH\" exec $CN psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c \"drop database if exists \$DB with (force)\" -c \"create database \$DB\"")
L_DROP=$(mine "docker -H \"\$DH\" exec $CN psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c \"drop database \$DB with (force)\" -c \"select coalesce(string_agg(datname, ', ' order by datname), '(none)') from pg_database where datname like 'u37%'\"")
L_PSQL=$(mine "docker -H \"\$DH\" exec $CN psql -U sa -d \"\$DB\" -qAt -v ON_ERROR_STOP=1 -c \"\$Q\"")
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s -DskipTests\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
[ "$(off .harness/after "$R_PLAIN" package)" = 'cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" clean package -DskipTests' ] || die "off(): the build line is not the README's package line, offline"
RM="$UP/../../_briefs/TRACK-ROADMAP.md"            # the roadmap's line for this unit (R.224's form) - outside the repository: read when present
if [ -f "$RM" ]; then RL=$($G -n -F -- '37 **Liquibase, and Choosing**' "$RM" || true); [ "${RL%%:*}" = 315 ] && printf '%s\n' "$RL" | $G -qF 'the honest comparison' || die "the roadmap's line for this unit moved or changed: ${RL:-none}"
  echo "  the roadmap (grep -n, ../../_briefs/TRACK-ROADMAP.md): line ${RL%%:*} - ${RL#*:}"
else echo "  note: the roadmap (../../_briefs/TRACK-ROADMAP.md) is not beside this clone - its line is read where it is"; fi
echo "  the commands: anchor/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"

# ---- build: before the captures -------------------------------------------------------------------------------------------
NOPLUG='No plugin'' found for prefix'
mbuild() { local how=yes ec=0 c=$1
  (eval "$c") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
  if [ $ec != 0 ] && $G -qE "offline mode|Could not resolve|could not be resolved|Cannot access|$NOPLUG" "$2"; then
    tail -20 "$2" >&3; die "build failed offline: $3 - the offline build could not resolve an artifact from .m2-demo (this script never goes online: seed .m2-demo from the course's seed)"; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3; die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec · 'Downloaded from' lines in its log: $($G -c '^\[INFO\] Downloaded from ' "$2" || true) · 'Tests run:' lines: $($G -c 'Tests run:' "$2" || true) (0 tests: this unit runs none)"; }
JE=""
jc() { local ec=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""; JE=$ec; }
rsync -a --exclude target --exclude secrets --exclude .m2-demo anchor/ .harness/after/
mbuild "$(off .harness/after "$R_PLAIN" package)" .harness/build-after.log ".harness/after (anchor/ copied, the README's package line, -DskipTests)"
[ "$($G -c 'Tests run:' .harness/build-after.log || true)" = 0 ] || die "the build ran tests - this unit runs none"
(cd .harness/after && eval "$R_EXTRACT") > .harness/extract.log 2>&1 < /dev/null || die "the extract failed: $(tail -3 .harness/extract.log)"
for a in org/springframework/boot/spring-boot-dependencies/4.1.2/spring-boot-dependencies-4.1.2.pom com/h2database/h2/2.5.250/h2-2.5.250.jar "$PGJ" $LQJ; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
LIB=.harness/after/$XD/lib; NL=$(ls $LIB | wc -l | tr -d ' ')
# R.335: the PostgreSQL driver and Liquibase are the harness's - the anchor's lib/ holds neither
NPG=$(ls $LIB | $G -cE '^postgresql-.*\.jar$' || true); NLQ=$(ls $LIB | $G -ci liquibase || true); NFL=$(ls $LIB | $G -cE '^(spring-boot-)?flyway' || true)
[ "$NPG" = 0 ] || die "R.335: the anchor's lib/ holds a PostgreSQL driver - 36/after holds none; the harness adds it from .m2-demo"
[ "$NLQ" = 0 ] || die "R.335: the anchor's lib/ holds a Liquibase jar - 36/after holds none; the harness adds them from .m2-demo"
[ "$NFL" = 3 ] || die "the anchor's lib/ must hold Flyway's three jars (flyway-core, flyway-database-postgresql, spring-boot-flyway): $NFL"
mkdir -p .harness/lq; for a in $LQJ; do ln -s "$M2/$a" .harness/lq/; done
SNK=$(ls $LIB | $G -E '^snakeyaml-' | paste -sd' ' -); [ -n "$SNK" ] || die "the anchor's lib/ holds no snakeyaml - the YAML changelog's claim needs it named"
[ -z "$(ls .harness/lq | $G -i yaml || true)" ] || die "the harness's Liquibase jars hold a YAML jar - the claim is that the YAML changelog needs none of its own"
echo "  the anchor's jar extracted: lib/ holds $NL libraries (ls | wc -l); grep -ci liquibase: $NLQ; postgresql-*.jar: $NPG (R.335: 36/after's lib/ holds neither) · Flyway's jars: $(ls $LIB | $G -E '^(spring-boot-)?flyway' | paste -sd' ' -)"
echo "  the harness's Liquibase jars (.harness/lq, links into .m2-demo - ls): $(ls .harness/lq | paste -sd' ' -) · $(ls .harness/lq | wc -l | tr -d ' ') jars (ls | wc -l): every Liquibase JVM below runs + the harness's Liquibase jars"
echo "  YAML: the anchor's lib/ already holds $SNK (Boot's); the harness's Liquibase jars hold no YAML jar (ls | grep -i yaml: 0) - the YAML changelog needs no extra jar"
echo "  the PostgreSQL driver: every PostgreSQL JVM below adds .m2-demo/$PGJ: + the harness's driver"
# the changelogs on the class path: one folder per variant, each holding db/changelog/ - the name is the same, classpath:db/changelog/...
for v in base fail lock lockok sum; do mkdir -p .harness/cp/$v/db/changelog; done
cp $CL/changelog.sql $CL/changelog.yaml $CL/changelog.xml .harness/cp/base/db/changelog/
for v in fail lock lockok sum; do cp $CL/$v/changelog.sql .harness/cp/$v/db/changelog/; done
mkdir -p .harness/files .harness/moved; cp $CL/changelog.sql .harness/files/; cp $CL/changelog.sql .harness/moved/
jc "$L_JAVAC" .harness/javac.log; [ "$JE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/l/ex ] || die "the exercise's class compiled into the harness's folder"
echo "  the harness compiled once (.harness/hc, $(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes; the exercise's class is compiled by its own lines)"
# the trap: one process for this run, loopback only (R.317)
: > .harness/trap.log
echo "\$ $L_TRAP" >&3
(eval "$L_TRAP") > .harness/trap.out 2>&1 < /dev/null & tpid=$!
i=0; while [ $i -lt 120 ] && [ "$(listeners 20166)" = 0 ]; do kill -0 "$tpid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
[ "$(listeners 20166)" = 1 ] || { cat .harness/trap.out >&3; die "the trap never listened on 20166"; }
[ "$(lsof -nP -a -p "$tpid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)" = '127.0.0.1:20166' ] || die "the trap must listen on 127.0.0.1:20166 alone"
echo "  the trap: $(head -1 .harness/trap.out) - listens on 127.0.0.1:20166 alone"
# the H2 TCP server: one JVM for this run, loopback only
echo "\$ $L_H2S" >&3
(eval "$L_H2S") > .harness/h2server.log 2>&1 < /dev/null & spid=$!
i=0; while [ $i -lt 120 ] && [ "$(listeners 20167)" = 0 ]; do kill -0 "$spid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
[ "$(listeners 20167)" = 1 ] || { cat .harness/h2server.log >&3; die "the H2 server never listened on 20167"; }
[ "$(lsof -nP -a -p "$spid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)" = '127.0.0.1:20167' ] || die "the H2 server must listen on 127.0.0.1:20167 alone"
H2SL=$($G -m1 'TCP server running at' .harness/h2server.log || true); [ "$H2SL" = 'TCP server running at tcp://localhost:20167 (only local connections)' ] || die "the H2 server's line: ${H2SL:-none}"
echo "  the H2 server: $H2SL - listens on 127.0.0.1:20167 alone"
# the container: PostgreSQL 18 from the pinned image, loopback only, a generated password in a 0600 file (R.214)
(umask 077 && LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom 2> /dev/null | head -c 24 > .harness/secrets/pgpw) || true
[ "$(wc -c < .harness/secrets/pgpw | tr -d ' ')" = 24 ] && [ "$(stat -f '%Lp' .harness/secrets/pgpw)" = 600 ] || die "the password file was not written, 24 characters, mode 0600"
PW=$(cat .harness/secrets/pgpw)
CSTARTED=1
(eval "$L_RUN") > .harness/docker-run.log 2>&1 < /dev/null || die "the container did not start: $(tail -2 .harness/docker-run.log)"
i=0; while ! (eval "$L_READY") > /dev/null 2>&1 < /dev/null; do i=$((i + 1)); [ $i -lt 120 ] || die "the container did not accept connections within its cap (120 tries, 0.5 apart)"; sleep 0.5; done
DP=$(dk port "$CN" 2> /dev/null | paste -sd'|' -)
[ "$DP" = '5432/tcp -> 127.0.0.1:20168' ] || die "the container must publish 5432 on 127.0.0.1:20168 alone: $DP"
CIP=$(dk inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CN" 2> /dev/null || true)
echo "  the container: $CN from $IMG (--pull never); its published port: $DP; user sa, the password generated into .harness/secrets/pgpw (24 characters, mode 0600, never printed); pg_isready after $i tries (cap 120)"

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C $G -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; PGJVM=0; LQJVM=0; FLJVM=0
HN=$(hostname); HS=${HN%%.*}
# lockedby (Liquibase's host name and address), the host name, the container's address: masked wherever they print
mask() { awk -v pw="$PW" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v hn="$HN" -v hs="$HS" -v cip="$CIP" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { W = lit(pw); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(W, "<pw>"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    while (match($0, /(^|[ |])[^ (|]+ \(([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|[0-9a-fA-F]*:[0-9a-fA-F:%]+)\)/)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, 1)
      if (s == " " || s == "|") pre = pre s; $0 = pre "<host> (<ip>)" substr($0, RSTART + RLENGTH) }
    if (hn != "") gsub(lit(hn), "<host>"); if (hs != "") gsub(lit(hs), "<host>"); if (cip != "") gsub(lit(cip), "<ip>")
    gsub(/ since [0-9][^|]*$/, " since <time>")
    gsub(/PROBE version: Java [0-9][0-9.]+/, "PROBE version: Java <version>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    gsub(/ran successfully in [0-9]+ms/, "ran successfully in <n>ms")
    gsub(/Using deploymentId: [0-9]+/, "Using deploymentId: <n>"); gsub(/\(execution time [0-9:.]+s\)/, "(execution time <t>)")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'PROBE version: Java 25.0.4.1' "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' "url jdbc:postgresql://127.0.0.1:20168/u37?user=sa&password=$PW" 'PROBE lock: id 1 · granted true · by some-host.local (192.168.1.7)' 'lockedby t|some-host.local (fe80:0:0:0:1%1)' 'Currently locked by h (10.0.0.1) since 11/17/26, 3:30 AM' 'ran successfully in 31ms' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'PROBE version: Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'url jdbc:postgresql://127.0.0.1:20168/u37?user=sa&password=<pw>' 'PROBE lock: id 1 · granted true · by <host> (<ip>)' 'lockedby t|<host> (<ip>)' 'Currently locked by <host> (<ip>) since <time>' 'ran successfully in <n>ms')" ] || die "mask: the planted JDK version, folders, home, identity hash, password, lockedby host and address, the lock's time and a run time must be masked: $(mask < .harness/p1 | paste -sd'|' -)"
echo "  mask: its self-test passed (the password, folders, home, identities, the JDK's version, lockedby's host and address, the lock's time, Liquibase's run time); raw password copies after mask: $(mask < .harness/p1 | $G -cF -- "$PW" || true)"
rm -f .harness/p1
CORE=--logging.level.org.hibernate.orm.core=info
HQ=(--logging.config=../../harness/logback.xml "$CORE" --spring.jpa.open-in-view=false --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false "$VAL")
LQOFF=--spring.liquibase.analytics-enabled=false
NOFLY=--spring.flyway.enabled=false
HE=""; MC=""; CPX=""; CPC=""; LV=""; TRAPN=0; DEFRUN=""; KILLAT=""
# hrun LABEL: one harness JVM, its stdout and stderr to .harness/h.log; the trap's log marked before and after it, its lines counted
# (R.317: 0 for every JVM but the labelled default run). KILLAT=TEXT: the JVM is killed (kill -9) once its log shows TEXT.
hrun() { local L=$1 c i=0 e=0 n k=""
  c=$(printf 'cd .harness/run && %s\n' "$L_H")
  echo "  JVM $L"
  echo "\$ CPC=$CPC; CPX=$CPX; MC=$MC; V=($(printf '%s ' "${V[@]}" | sed 's/ $//')); A=($(printf '%q ' "${A[@]}" | sed 's/ $//'))"
  echo "#trap $L start" >> .harness/trap.log
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 1000 ]; do
    if [ -n "$KILLAT" ] && [ -z "$k" ] && $G -qF -- "$KILLAT" .harness/h.log; then kill -9 "$pid"; k=1; fi
    sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running after 250 s - its alarm should have stopped it"; }
  wait "$pid" 2> /dev/null || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1))
  echo "#trap $L end" >> .harness/trap.log
  [ "$HE" != 142 ] || die "the harness JVM's alarm fired (exit 142) - a run that does not end by itself is a failed receipt (R.247)"
  [ -z "$KILLAT" ] || [ -n "$k" ] || die "$L: the JVM ended before its log showed: $KILLAT"
  TRAPN=$(awk -v a="#trap $L start" -v b="#trap $L end" '$0 == a { f = 1; n = 0; next } $0 == b { f = 0 } f { n++ } END { print n + 0 }' .harness/trap.log)
  # R.329: a JVM that loads Liquibase prints its version line, one that loads Flyway its own
  if [ -n "$CPC$CPX" ] && [ "${CPX#*lq}" != "$CPX" ]; then LQJVM=$((LQJVM + 1)); $G -qxF 'PROBE version: Liquibase 5.0.4' .harness/h.log || die "R.329: $L loaded Liquibase and printed no Liquibase version line"
    # R.317: every Liquibase JVM carries the key, but the one labelled default run
    if [ "$L" != "$DEFRUN" ]; then case " ${A[*]:-} ${V[*]:-} " in *" $LQOFF "*|*" -Dliquibase.analytics.enabled=false "*) ;; *) die "R.317: $L is a Liquibase JVM without spring.liquibase.analytics-enabled=false" ;; esac; fi; fi
  if $G -q 'org\.flywaydb' .harness/h.log; then FLJVM=$((FLJVM + 1)); $G -qxF 'PROBE version: Flyway 12.4.0' .harness/h.log || die "R.329: $L loaded Flyway and printed no Flyway version line"; fi
  [ "$L" = "$DEFRUN" ] || [ "$TRAPN" = 0 ] || die "R.317: the trap caught $TRAPN request line(s) during $L - a JVM that is not the labelled default run called the network: $($G -v '^#' .harness/trap.log | tail -1)"
  case " ${V[*]:-} " in *" -Dpg.db="*) PGJVM=$((PGJVM + 1)); n=$(raw "$PW" .harness/h.log); [ "$n" = 0 ] || die "a harness log held the password, raw ($n)" ;; esac; }
# hview: the lines a capture shows of a JVM's log - the version lines, HHH000001, Liquibase's and Flyway's own lines (each once, the
# summary's padding squeezed), what the harness printed (PROBE); then its exit, its WARN lines and the trap's request lines
hview() { awk '/^PROBE / || /^INFO +\[main\] org\.hibernate\.orm\.core : HHH000001/ || /^(INFO|WARN|ERROR|SEVERE) +\[main\] (liquibase|org\.flywaydb)\./ || /^LQ / || /^Rolling Back Changeset: / { sub(/[ \t]+$/, ""); gsub(/  +/, " "); if (!s[$0]++) print "    " $0 }' .harness/h.log | mask
  echo "  exit $HE · WARN lines: $($G -c '^WARN ' .harness/h.log || true) · the trap's request lines during this JVM: $TRAPN"; }
pgdb() { local DB=$1; echo "  \$ DB=$DB; $L_DB"; (eval "$L_DB") > .harness/pgdb.log 2>&1 < /dev/null || die "the fresh database $DB was not made: $(tail -2 .harness/pgdb.log)"; echo "  a fresh database: $DB"; }
pgdrop() { local DB=$1; echo "  the database dies with its run (R.178): drop database $DB with (force) · the databases named u37… now: $( (eval "$L_DROP") 2>&1 < /dev/null | tail -1)"; }
psq() { local DB=$1 Q=$2; (eval "$L_PSQL") 2>&1 < /dev/null | mask || true; }
pq() { local DB=$1 Q=$2; echo "  \$ DB=$DB; Q=\"$Q\"; $L_PSQL" | sed "s#$U#…#g"; psq "$DB" "$Q" | sed 's/^/    /'; }
HQL="select id, author, filename, orderexecuted, exectype, md5sum, description from databasechangelog order by orderexecuted"
LKQ="select id, locked, lockgranted is not null as granted, lockedby from databasechangeloglock"
hist() { pq "$1" "$HQL"; }
lockrow() { pq "$1" "$LKQ"; }
rows() { pq "$1" "select 'customers ' || (select count(*) from customer) || ' · pauses ' || (select count(*) from pause)"; }
tabs() { pq "$1" "select coalesce(string_agg(tablename, ', ' order by tablename), '(none)') from pg_tables where schemaname = 'public'"; }
cols() { pq "$1" "select table_name || ': ' || string_agg(column_name, ', ' order by ordinal_position) from information_schema.columns where table_schema = 'public' and table_name in ('databasechangelog', 'databasechangeloglock') group by table_name order by table_name"; }
custcols() { pq "$1" "select string_agg(column_name, ', ' order by ordinal_position) from information_schema.columns where table_schema = 'public' and table_name = 'customer'"; }
h2q() { local DB=$1 Q=$2 c e=0; c=$(printf 'cd .harness/run && %s\n' "$L_SHELL"); echo "  \$ DB=$DB; Q='$Q'"; echo "  \$ $c"
  (eval "$(exe "$c")") > .harness/h2q.out 2>&1 < /dev/null & pid=$!; wait "$pid" || e=$?; pid=""
  [ "$e" = 0 ] || { cat .harness/h2q.out >&3; die "H2's Shell failed (exit $e)"; }
  sed -E 's/[[:space:]]+$//; s/, [0-9]+ ms\)$/)/; s/^/    /' .harness/h2q.out | mask; }
# a Boot JVM over the anchor's libraries + the harness's Liquibase jars on PostgreSQL: LABEL DB CPVARIANT CHANGELOG [ARGS...]
lq() { local L=$1 DB=$2 CV=$3 CLG=$4; shift 4
  MC=probe.l.LMain; CPC=":../cp/$CV"; CPX=":../lq/*:../../.m2-demo/$PGJ"; V=(-Dpg.db=$DB -Dpg.pwfile=../secrets/pgpw ${LV:+"$LV"})
  A=("${HQ[@]}" "--spring.liquibase.change-log=$CLG" "$NOFLY" "$@"); hrun "$L"; hview > .harness/v/$L; cat .harness/v/$L; }
# Liquibase's Java API (probe.l.LApi) on PostgreSQL: LABEL DB CPVARIANT CHANGELOG COMMAND...
api() { local L=$1 DB=$2 CV=$3; shift 3
  MC=probe.l.LApi; CPC=":../cp/$CV"; CPX=":../lq/*:../../.m2-demo/$PGJ"; V=(-Dpg.db=$DB -Dpg.pwfile=../secrets/pgpw -Dliquibase.analytics.enabled=false)
  A=("$@"); hrun "$L"; hview > .harness/v/$L; cat .harness/v/$L; }
unpub=""
cap() { local nm=$1 i; shift
  for i in 1 2 3; do CAPRUN=$i; "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    raw "$PW" .harness/cap.raw > ".harness/rawpw-$nm.$i"
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
  o=$(python3 -I -B harness/chk37.py "$nm" "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' | tee .harness/chk-$nm.out || true
  [ $e = 0 ] || die "$nm: its check failed (harness/chk37.py, above)"
  VALS="$VALS${VALS:+ · }$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }

# ---- the captures --------------------------------------------------------------------------------------------------------
formats() { local f
  echo "formats - V1 + V2 as ONE changelog (two changesets, tiffinbox:1 the tables and the index, tiffinbox:2 the four customers and the two pauses), in three formats; each its own JVM on a fresh PostgreSQL database, Liquibase on (the anchor's Flyway off: $NOFLY), $LQOFF, $VAL:"
  echo "  the files (wc -l): $(cd $CL && wc -l changelog.sql changelog.yaml changelog.xml | $G -v total | awk '{ print $2 " " $1 }' | paste -sd',' - | sed 's/,/ · /g') · Flyway's two files in the anchor (wc -l): $(cd anchor/$MG && wc -l V1__customer_and_pause.sql V2__seed.sql | awk '{ print $2 " " $1 }' | sed 's/^total /total /' | paste -sd',' - | sed 's/,/ · /g')"
  for f in sql yaml xml; do
    echo "-- u37f$f · PostgreSQL · classpath:db/changelog/changelog.$f"
    pgdb u37f$f; lq u37f$f u37f$f base classpath:db/changelog/changelog.$f "$LQOFF"
    echo "  the second connection (psql in the container):"; tabs u37f$f; rows u37f$f; hist u37f$f; lockrow u37f$f; cols u37f$f
    pgdrop u37f$f; done
  echo "the checksums of the two changesets, side by side (the md5sum column above, per format):"
  for f in sql yaml xml; do echo "  $f: $($G -A3 "^  \\\$ DB=u37f$f; Q=\"$HQL\"" .harness/cap.raw | $G -oE '\|9:[0-9a-f]{32}\|' | tr -d '|' | paste -sd' ' -)"; done; }
analytics() {
  echo "analytics - the network at start (R.317): three labelled JVMs on fresh PostgreSQL databases, each behind the trap (127.0.0.1:20166, 403, nothing forwarded)"
  echo "  Boot 4.1's key, read off spring-boot-liquibase's metadata (unzip -p META-INF/spring-configuration-metadata.json | grep):"
  unzip -p .harness/lq/spring-boot-liquibase-4.1.2.jar META-INF/spring-configuration-metadata.json | $G -A2 '"name": "spring.liquibase.analytics-enabled"' | sed -E 's/^ +/    /; s/,$//'
  echo "-- u37adef · PostgreSQL · the labelled default run: Liquibase with NO analytics setting"
  pgdb u37adef; DEFRUN=u37adef; MC=probe.l.LMain; CPC=":../cp/base"; CPX=":../lq/*:../../.m2-demo/$PGJ"; V=(-Dpg.db=u37adef -Dpg.pwfile=../secrets/pgpw)
  A=("${HQ[@]}" --spring.liquibase.change-log=classpath:db/changelog/changelog.sql "$NOFLY"); hrun u37adef; DEFRUN=""; hview
  echo "  the trap's log for this JVM (the time masked):"; awk '$0 == "#trap u37adef start" { f = 1; n = 0; next } $0 == "#trap u37adef end" { f = 0 } f { sub(/^[0-9:]+ /, ""); l[++n] = "    <time> " $0 } END { for (i = 1; i <= n; i++) print l[i] }' .harness/trap.log
  rows u37adef; pgdrop u37adef
  echo "-- u37akey · PostgreSQL · the same, with $LQOFF"
  pgdb u37akey; lq u37akey u37akey base classpath:db/changelog/changelog.sql "$LQOFF"; rows u37akey; pgdrop u37akey
  echo "-- u37afly · PostgreSQL · a Flyway JVM: the anchor's libraries alone (no Liquibase jar), its Flyway on, the anchor's own V1 and V2"
  pgdb u37afly; MC=probe.l.LMain; CPC=""; CPX=":../../.m2-demo/$PGJ"; V=(-Dpg.db=u37afly -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}"); hrun u37afly; hview
  pq u37afly "select count(*) || ' rows in flyway_schema_history' from flyway_schema_history"; rows u37afly; pgdrop u37afly
  echo "the three, side by side - the trap's request lines: default $($G -oE 'the trap.s request lines during this JVM: [0-9]+' .harness/cap.raw | sed -n 1p | sed 's/.*: //') · the key $($G -oE 'the trap.s request lines during this JVM: [0-9]+' .harness/cap.raw | sed -n 2p | sed 's/.*: //') · Flyway $($G -oE 'the trap.s request lines during this JVM: [0-9]+' .harness/cap.raw | sed -n 3p | sed 's/.*: //')"; }
LOCKQ="select count(*) from pg_stat_activity where datname = '\$DB' and query like 'SELECT pg_sleep%'"
term() { local DB=$1 Q
  Q="select count(*) || ' backend(s) running pg_sleep' from pg_stat_activity where datname = '$DB' and query like 'SELECT pg_sleep%' and pid <> pg_backend_pid()"; pq "$DB" "$Q"
  Q="select count(*) || ' terminated' from (select pg_terminate_backend(pid) from pg_stat_activity where datname = '$DB' and query like 'SELECT pg_sleep%' and pid <> pg_backend_pid()) t"; pq "$DB" "$Q"
  Q="select count(*) || ' backend(s) running pg_sleep' from pg_stat_activity where datname = '$DB' and query like 'SELECT pg_sleep%' and pid <> pg_backend_pid()"
  local j=0; while [ "$(psq "$DB" "$Q")" != '0 backend(s) running pg_sleep' ] && [ $j -lt 40 ]; do sleep 0.25; j=$((j + 1)); done; pq "$DB" "$Q"; }
killb() { local DB=$1
  echo "  B: the lock/ changelog (changeset 3 sleeps in the server); the receipt kills the JVM (kill -9) once its log shows the third changeset running - its alarm (240) is not what stops it:"
  KILLAT='Running Changeset: db/changelog/changelog.sql::3::tiffinbox'; lq ${DB}k $DB lock classpath:db/changelog/changelog.sql "$LQOFF"; KILLAT=""
  echo "  the second connection, after the kill:"; lockrow $DB; hist $DB
  echo "  the killed JVM's statement lives on in the server - terminated before the next step:"; term $DB; }
lock() { local k
  echo "lock - the failure receipt is B: a Liquibase start killed while it holds its lock; PostgreSQL, the harness over the anchor's libraries + the harness's Liquibase jars + the harness's driver"
  echo "-- u37lock · PostgreSQL · B, then A"
  pgdb u37lock; killb u37lock 2> /dev/null            # bash 3.2 reports the killed job on stderr, with its pid: kept out of the capture
  echo "  B: the next start, the lock wait set to 0 by its system property (-Dliquibase.changelogLockWaitTimeInMinutes=0):"
  LV=-Dliquibase.changelogLockWaitTimeInMinutes=0; lq u37lockr u37lock lock classpath:db/changelog/changelog.sql "$LQOFF"; LV=""
  echo "  the second connection:"; lockrow u37lock
  echo "  the lock wait's default, read off Liquibase's GlobalConfiguration by the API (a configured wait - never waited out here), then A: listLocks() and forceReleaseLocks():"
  api u37locka u37lock lockok db/changelog/changelog.sql wait locks release
  echo "  the second connection:"; lockrow u37lock
  echo "  A: the next start - the lockok/ changelog (the same name; changeset 3 = SELECT 1):"
  lq u37lockb u37lock lockok classpath:db/changelog/changelog.sql "$LQOFF"
  echo "  the second connection:"; lockrow u37lock; hist u37lock; rows u37lock; pgdrop u37lock
  echo "-- u37lockp · PostgreSQL · A' - the same on a fresh database"
  pgdb u37lockp; killb u37lockp 2> /dev/null
  api u37lockpa u37lockp lockok db/changelog/changelog.sql locks release
  echo "  the second connection:"; lockrow u37lockp
  lq u37lockpb u37lockp lockok classpath:db/changelog/changelog.sql "$LQOFF"
  echo "  the second connection:"; lockrow u37lockp; hist u37lockp; pgdrop u37lockp
  echo "Boot 4.1's Liquibase keys, read off spring-boot-liquibase's metadata (unzip -p META-INF/spring-configuration-metadata.json):"
  k=$(unzip -p .harness/lq/spring-boot-liquibase-4.1.2.jar META-INF/spring-configuration-metadata.json | $G -oE '"name": "spring\.liquibase\.[a-z-]+"' | sed -E 's/.*"spring\.liquibase\.([a-z-]+)"/\1/' | sort -u)
  echo "  $(printf '%s\n' "$k" | paste -sd' ' -)"
  echo "  keys: $(printf '%s\n' "$k" | wc -l | tr -d ' ') · grep -c release: $(printf '%s\n' "$k" | $G -c release || true) · grep -c lock: $(printf '%s\n' "$k" | $G -c lock || true)"; }
fail() {
  echo "fail - a failed changeset, the path as identity, rollback, the checksum, both tools on one class path, Flyway's undo"
  echo "(i) the fail/ changelog: changeset 3 = two statements, the second misspelt:"; tail -3 $CL/fail/changelog.sql | sed 's/^/    /'
  echo "-- u37fail · PostgreSQL · classpath:db/changelog/changelog.sql (fail/)"
  pgdb u37fail; lq u37fail u37fail fail classpath:db/changelog/changelog.sql "$LQOFF"
  echo "  the second connection:"; hist u37fail; custcols u37fail; lockrow u37fail; pgdrop u37fail
  local H=jdbc:h2:tcp://127.0.0.1:20167/mem:u37fail
  echo "-- u37failh2 · H2 over TCP (mem:u37fail on the H2 server) · classpath:db/changelog/changelog.sql (fail/) - emptied first (a database on the server lives as long as the server), then run 1:"
  h2q u37fail 'DROP ALL OBJECTS'
  MC=probe.l.LMain; CPC=":../cp/fail"; CPX=":../lq/*"; V=()
  A=("--spring.datasource.url=$H;DB_CLOSE_DELAY=-1" --spring.datasource.username=sa "${HQ[@]}" --spring.liquibase.change-log=classpath:db/changelog/changelog.sql "$NOFLY" "$LQOFF"); hrun u37failh2; hview
  echo "  the second connection (H2's Shell):"
  h2q u37fail 'SELECT ID, AUTHOR, FILENAME, ORDEREXECUTED, EXECTYPE FROM DATABASECHANGELOG ORDER BY ORDEREXECUTED'
  h2q u37fail "SELECT LISTAGG(COLUMN_NAME, ', ') WITHIN GROUP (ORDER BY ORDINAL_POSITION) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'CUSTOMER'"
  h2q u37fail "SELECT LISTAGG(COLUMN_NAME || ' ' || DATA_TYPE || CASE WHEN IS_NULLABLE = 'NO' THEN ' NOT NULL' ELSE '' END, ', ') WITHIN GROUP (ORDER BY ORDINAL_POSITION) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DATABASECHANGELOGLOCK'"
  h2q u37fail 'SELECT ID, LOCKED FROM DATABASECHANGELOGLOCK'
  echo "-- u37failh2b · H2 over TCP · run 2, the same files:"; hrun u37failh2b; hview
  h2q u37fail 'SELECT COUNT(*) FROM DATABASECHANGELOG'
  h2q u37fail 'SHUTDOWN'
  echo "(ii) the path as identity - PostgreSQL: the changelog named by a file: path (the one labelled file: run of this unit), then the same file copied to another folder"
  echo "-- u37path · PostgreSQL · file:../files/changelog.sql"
  pgdb u37path; lq u37path u37path base file:../files/changelog.sql "$LQOFF"
  echo "  the second connection:"; pq u37path "select id, filename from databasechangelog order by orderexecuted"
  echo "-- u37pathm · PostgreSQL · the same database, the same bytes in another folder: file:../moved/changelog.sql (cmp: $(cmp -s .harness/files/changelog.sql .harness/moved/changelog.sql && echo 'the same bytes' || echo differ))"
  lq u37pathm u37path base file:../moved/changelog.sql "$LQOFF"
  echo "  the second connection:"; pq u37path "select count(*) || ' rows' from databasechangelog"; rows u37path
  echo "(iii) rollback, wrong - the same database (its rows named by the file: path); Liquibase's API given the class path's name, rollback(1):"
  api u37rbw u37path base db/changelog/changelog.sql rollback:1
  echo "  the second connection - the witness is the table, never the command's done (R.328):"; pq u37path "select count(*) || ' rows' from databasechangelog"; rows u37path; pgdrop u37path
  echo "(iv) rollback, right - a fresh database, Boot and the API both on the class path's name:"
  echo "-- u37rb · PostgreSQL · classpath:db/changelog/changelog.sql"
  pgdb u37rb; lq u37rb u37rb base classpath:db/changelog/changelog.sql "$LQOFF"
  echo "  the second connection:"; pq u37rb "select id, filename from databasechangelog order by orderexecuted"; rows u37rb
  api u37rbr u37rb base db/changelog/changelog.sql rollback:1
  echo "  the second connection - the witness (R.328):"; pq u37rb "select count(*) || ' rows' from databasechangelog"; rows u37rb; pgdrop u37rb
  echo "(v) the checksum - a fresh database: changelog.sql runs, then sum/ (the same name; one comment added to changeset 1's index line):"
  diff $CL/changelog.sql $CL/sum/changelog.sql | sed 's/^/    /'
  echo "-- u37sum · PostgreSQL · classpath:db/changelog/changelog.sql"
  pgdb u37sum; lq u37sum u37sum base classpath:db/changelog/changelog.sql "$LQOFF"
  lq u37sumb u37sum sum classpath:db/changelog/changelog.sql "$LQOFF"
  echo "  the second connection:"; pq u37sum "select id, md5sum from databasechangelog order by orderexecuted"; pgdrop u37sum
  echo "(vi) both tools on one class path - a fresh database, Liquibase on and the anchor's Flyway on (its V1 and V2):"
  echo "-- u37both · PostgreSQL"
  pgdb u37both; MC=probe.l.LMain; CPC=":../cp/base"; CPX=":../lq/*:../../.m2-demo/$PGJ"; V=(-Dpg.db=u37both -Dpg.pwfile=../secrets/pgpw)
  A=("${HQ[@]}" --spring.liquibase.change-log=classpath:db/changelog/changelog.sql "$LQOFF"); hrun u37both; hview
  echo "  the second connection:"; tabs u37both; pq u37both "select count(*) || ' rows' from databasechangelog"; pgdrop u37both
  echo "(vii) Flyway Community's undo - Flyway's own API (probe.l.FUndo) over the anchor's libraries, a fresh database: migrate() V1 and V2, then undo():"
  echo "-- u37undo · PostgreSQL"
  pgdb u37undo; MC=probe.l.FUndo; CPC=""; CPX=":../../.m2-demo/$PGJ"; V=(-Dpg.db=u37undo -Dpg.pwfile=../secrets/pgpw); A=(); hrun u37undo; hview
  echo "  the second connection:"; pq u37undo "select version || ' ' || success from flyway_schema_history order by installed_rank"; pgdrop u37undo; }
# compare: the table - every cell read off the captures above (their .r-*.out, masked and published) or this unit's files; nothing typed
compare() { local F=.r-formats.out N=.r-analytics.out K=.r-lock.out X=.r-fail.out R36=../c7-unit36/README.md
  g1() { $G -m1 -oE -- "$1" "$2" | head -1; }
  sec() { awk -v a="$1" -v b="$2" 'index($0, a) == 1 { f = 1 } f && b != "" && index($0, b) == 1 && index($0, a) != 1 { f = 0 } f' "$3"; }
  echo "compare - the comparison table; every cell a line read off this unit's captures (formats, analytics, lock, fail), the anchor's files, or - for three Flyway cells this unit does not re-run - the Flyway lesson's README text blocks (its captures fail and traps, $(awk '$1 == "fail" || $1 == "traps" { print $1 " " $2 }' ../c7-unit36/receipts.md5 | paste -sd',' - | sed 's/,/ · /')) (R.261):"
  echo "cell Boot 4.1 pieces | flyway | $(ls $LIB | $G -E '^(spring-boot-)?flyway' | sed 's/-[0-9.]*\.jar$//' | paste -sd' ' - | sed 's/ / + /g') (in the anchor's lib/)"
  echo "cell Boot 4.1 pieces | liquibase | $(ls .harness/lq | sed 's/-[0-9.]*\.jar$//' | paste -sd' ' - | sed 's/ / + /g') (the harness's)"
  echo "cell files · lines | flyway | $(cd anchor/$MG && ls | wc -l | tr -d ' ') files · $(cat anchor/$MG/*.sql | wc -l | tr -d ' ') lines (plain SQL)"
  echo "cell files · lines | liquibase | 1 file · $(g1 'changelog\.sql [0-9]+' $F | sed 's/.* //') (SQL) / $(g1 'changelog\.yaml [0-9]+' $F | sed 's/.* //') (YAML) / $(g1 'changelog\.xml [0-9]+' $F | sed 's/.* //') (XML) lines"
  echo "cell tables it adds | flyway | $(g1 '^ +[0-9]+ rows in flyway_schema_history' $N | sed 's/^ *[0-9]* rows in //')"
  echo "cell tables it adds | liquibase | $(g1 '^ +customer, databasechangelog, databasechangeloglock, pause$' $F | sed 's/^ *customer, //; s/, pause$//')"
  echo "cell history rows after V1 + seed | flyway | $(g1 '^ +[0-9]+ rows in flyway_schema_history' $N | awk '{ print $1 }') (PostgreSQL)"
  echo "cell history rows after V1 + seed | liquibase | $(sec '-- u37fsql ' '-- u37fyaml ' $F | $G -cE '^    [0-9]+[|]tiffinbox[|]') (PostgreSQL)"
  echo "cell a failed script on PostgreSQL | flyway | $(g1 'failed! Changes successfully rolled back\.' $R36) (the Flyway lesson's fail)"
  echo "cell a failed script on PostgreSQL | liquibase | $(g1 'Migration failed for changeset [^ :]+::[0-9]+::[a-z]+' $X) · rows $(sec '-- u37fail ' '-- u37failh2 ' $X | $G -E '^    [0-9]+[|]tiffinbox[|]' | cut -d'|' -f1 | tr -d ' ' | paste -sd',' -) · phone $(sec '-- u37fail ' '-- u37failh2 ' $X | $G -qE '^    id, name, .*phone' && echo present || echo absent)"
  echo "cell a failed script on H2 | flyway | $(g1 'Detected failed migration to version [0-9]+ \([a-z ]+\)' $R36) (the Flyway lesson's fail)"
  echo "cell a failed script on H2 | liquibase | $(g1 'Unknown data type: "EMAIL"' $X) · rows $(sec '-- u37failh2 ' '-- u37failh2b ' $X | $G -E '^    [0-9]+ +[|] tiffinbox' | awk '{ print $1 }' | paste -sd',' -) · PHONE $(sec '-- u37failh2 ' '-- u37failh2b ' $X | $G -qE '^    ID, NAME, .*PHONE' && echo present || echo absent) · the next start: $(g1 'Duplicate column name "PHONE"' $X)"
  echo "cell an edited script | flyway | $(g1 'Migration checksum mismatch for migration version [0-9]+' $R36) (the Flyway lesson's traps)"
  echo "cell an edited script | liquibase | $(g1 '[0-9]+ changesets? check sum' $X) · $(g1 'was: 9:[0-9a-f]+ but is now: 9:[0-9a-f]+' $X)"
  echo "cell a killed run | flyway | no lock table (its tables: $(g1 '^ +[0-9]+ rows in flyway_schema_history' $N | sed 's/^ *[0-9]* rows in //')); a killed Flyway start not run here"
  echo "cell a killed run | liquibase | locked=$(sec '  the second connection, after the kill:' '  the killed JVM' $K | $G -m1 -oE '^    1[|][tf][|]' | cut -d'|' -f2) after kill -9 · the next start: $(g1 'Could not acquire change log lock' $K) · until $(g1 'forceReleaseLocks\(\)' $K)"
  echo "cell undo / rollback | flyway | undo(): $(g1 'Flyway Redgate Edition Required: [^.]*' $X)"
  echo "cell undo / rollback | liquibase | rollback(1) by the API: $(sec '(iv) rollback, right' '(v) the checksum' $X | awk '/the witness \(R\.328\)/ { f = 1 } f' | $G -oE '^    [0-9]+ rows?$|^    customers [0-9]+ · pauses [0-9]+$' | sed 's/^ *//' | paste -sd',' - | sed 's/,/ · /') after it; Boot runs update only (Boot's keys: $(g1 'keys: [0-9]+ · grep -c release: [0-9]+' $K | sed 's/^keys: //'))"
  echo "cell network at start (the trap) | flyway | $(g1 'the trap.s request lines: default [0-9]+ · the key [0-9]+ · Flyway [0-9]+' $N | sed 's/.*Flyway //') lines"
  echo "cell network at start (the trap) | liquibase | $(g1 'the trap.s request lines: default [0-9]+' $N | sed 's/.*default //') ($(g1 'CONNECT [a-z.]+:[0-9]+' $N)) with no key · $(g1 '· the key [0-9]+' $N | sed 's/.*the key //') with $(g1 'spring\.liquibase\.analytics-enabled' $N)=false"
  echo "cell identity of an applied script | flyway | version + checksum ($(g1 'Migration checksum mismatch for migration version [0-9]+' $R36 | sed 's/ for migration / for /'))"
  echo "cell identity of an applied script | liquibase | $($G -m1 -oE '^    databasechangelog: [a-z0-9_, ]+' $F | sed 's/^ *databasechangelog: //' | tr ',' '\n' | tr -d ' ' | $G -xE 'id|author|filename|md5sum' | paste -sd'+' - | sed 's/+/ + /g') · the same file moved: $(g1 'relation "customer" already exists' $X)"
  echo "cell both on one class path | both | Liquibase $(sec '-- u37both ' '(vii)' $X | $G -m1 -oE 'Run: [0-9]+') · then Flyway: $(g1 'Found non-empty schema\(s\) "public" but no schema history table' $X)"; }
# xcheck: Hibernate's DDL script over the anchor's libraries (R.252: Hibernate's schema generation writes it), the anchor's Flyway off
XA=('--spring.datasource.url=jdbc:h2:mem:x37;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml "$CORE" --spring.jpa.hibernate.ddl-auto=none "$NOFLY" --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
X36=$(md5 -q ../c7-unit36/xcheck.sql)
xcheck() {
  echo "Hibernate's DDL over the anchor's libraries - probe.x.XMain, scripts.action=create (a file, never run), the anchor's Flyway off ($NOFLY):"
  rm -f .harness/run/hibernate-ddl.sql; CPC=""; CPX=""; MC=probe.x.XMain; V=(); A=("${XA[@]}"); hrun x37
  echo "  exit $HE · HHH000001: $($G -c 'HHH000001: Hibernate ORM core version 7.4.13.Final' .harness/h.log || true) · the trap's request lines: $TRAPN"
  [ -f .harness/run/hibernate-ddl.sql ] || die "xcheck: no script"
  mv .harness/run/hibernate-ddl.sql .harness/ddl-anchor.sql
  echo "  .harness/ddl-anchor.sql - every line:"; sed -E 's/FK[0-9a-z]{20,}/FK<name>/g; s/^/    /' .harness/ddl-anchor.sql
  echo "  the anchor's md5: $(md5 -q .harness/ddl-anchor.sql) · the filed xcheck.sql: $(md5 -q xcheck.sql) · cmp: $(cmp -s .harness/ddl-anchor.sql xcheck.sql && echo 'the same, byte for byte' || echo differ) · the Flyway lesson's xcheck.sql: $X36 · diff: $(diff ../c7-unit36/xcheck.sql .harness/ddl-anchor.sql | $G -c '^[<>]' || true) lines"; }
# exercise: the README's commands, then the solution's - in ONE shell, bash, then zsh; the shell's JVMs behind the trap through
# JDK_JAVA_OPTIONS (the java launcher reads it; its NOTE line goes to the log the block greps), their trap lines counted
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2 n
  rm -rf .harness/ex; rm -f .harness/ex-*.st .harness/ex-*.out .harness/mine.log
  echo "#trap ex-$sh start" >> .harness/trap.log
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" JDK_JAVA_OPTIONS="$TRAPO" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" JDK_JAVA_OPTIONS="$TRAPO" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 1200 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after 300 s"; }
  wait "$xpid" || true; xpid=""
  echo "#trap ex-$sh end" >> .harness/trap.log
  n=$(awk -v a="#trap ex-$sh start" -v b="#trap ex-$sh end" '$0 == a { f = 1; next } $0 == b { f = 0 } f { n++ } END { print n + 0 }' .harness/trap.log)
  [ "$n" = 0 ] || die "R.317: the exercise's JVMs called the network ($n trap lines in $sh)"
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines:"
  echo "  the block's exit $e1 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "  the shell is now in: $(where "$d1") · broken's md5 (what it printed): $(sed -E 's/[[:space:]]+$//' .harness/ex-readme.out | md5 -q)"
  echo "  then the solution's lines, in the same shell - the block's exit $e2 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · solved's md5 (what it printed): $(sed -E 's/[[:space:]]+$//' .harness/ex-sol.out | md5 -q) · the classes it compiled: $(cd .harness/ex/classes 2> /dev/null && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -) · the trap's request lines during this shell: $n · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines"; }
exercise() { local setup sol
  setup=$(block exercise/README.md); sol=$(block exercise/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  printf '%s\n' "$sol" | sed -n 1p | $G -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  [ "$(diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | $G -c '^[<>]')" = 2 ] || die "SOLUTION.md's block must be the README's with one line changed"
  printf '%s\n' "$setup" | $G -qF -- '"${A[@]}"' && printf '%s\n' "$setup" | $G -qE '^A=\(' || die "exercise/README.md must pass its arguments as an array, A"
  printf '%s\n' "$setup" | $G -E ' java ' | $G -qF "perl -e 'alarm " || die "exercise/README.md's JVM must run under its alarm (R.247)"
  printf '%s\n' "$setup" | $G -E ' java ' | $G -qF -- '-Dliquibase.analytics.enabled=false' && printf '%s\n' "$sol" | $G -E ' java ' | $G -qF -- '-Dliquibase.analytics.enabled=false' || die "R.317: the exercise's JVM must carry -Dliquibase.analytics.enabled=false, in both files"
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-readme.st"
cd "$1" || exit 1
. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-sol.st"
DRV
  echo "exercise/README.md's $(printf '%s\n' "$setup" | $G -c .) lines, then exercise/SOLUTION.md's, exactly as written, one after the other in ONE shell - env -i (HOME, the PATH this script was started with, and JDK_JAVA_OPTIONS = the trap's proxy options), started in this folder:"
  echo "the README's lines:"; printf '%s\n' "$setup" | sed 's/^/  $ /'
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh; }
EXQ="Your turn: the README's Liquibase start was killed while it held its lock, and the next start cannot get it. Release the lock, then update."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
cap formats formats; chk formats .r-formats.out "$CL"; pub formats
cap analytics analytics; chk analytics .r-analytics.out; pub analytics
cap lock lock; chk lock .r-lock.out; pub lock
cap fail fail; chk fail .r-fail.out; pub fail
cap compare compare; chk compare .r-compare.out; pub compare
python3 -I -B harness/chk37.py table .r-compare.out README.md > .harness/table.out || { cat .harness/table.out; die "R.261: README.md's comparison table is not the table the cell lines build"; }
cat .harness/table.out
cap xcheck xcheck; chk xcheck .r-xcheck.out "$X36" "$(md5 -q xcheck.sql)"; pub xcheck
cap exercise exercise; chk exercise .r-exercise.out "$EXW" .r-fail.out; pub exercise
for f in exercise/README.md exercise/SOLUTION.md; do
  w=$(python3 -I -B harness/chk37.py wib .r-exercise.out "$f"); [ "$(wib "$f")" = "$w" ] || die "$f's \"What it prints\" block is not what its lines printed: $(diff <(wib "$f") <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "exercise: broken and solved print the same (R.196)"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
echo "  exercise: each file's What it prints = the run (bash's), the two differ (R.196); the spoken line $EXW words (wc -w)"
# R.302: every line of README.md's ```text blocks is a line a run printed
cat .r-*.out .harness/chk-*.out .harness/table.out 2> /dev/null | sed -E 's/^ +//' > .harness/printed.txt
TX=$(awk '/^```text$/ { b = 1; next } b && /^```$/ { b = 0; next } b && NF { sub(/^ +/, ""); print }' README.md | while IFS= read -r l; do $G -qxF -- "$l" .harness/printed.txt || printf '%s\n' "$l"; done | head -3 | cut -c1-160 | paste -sd';' -)
[ "$($G -c '^```text$' README.md)" -gt 0 ] && [ -z "$TX" ] || die "R.302: README.md's text blocks must be lines the runs printed - not printed: ${TX:-no text block}"
echo "  R.302: README.md's $($G -c '^```text$' README.md) text blocks - every line one the runs printed"
VS="the values the video may say: on PostgreSQL 18.6 (+ the harness's driver) and H2 2.5.250, Spring Boot 4.1.2, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final, Liquibase 5.0.4 (+ the harness's Liquibase jars), Flyway 12.4.0 (the anchor's), tests run: 0 - $VALS"
printf '%s\n' "$VS" > .harness/values.txt
$G -qxF -- "$VS" README.md || die "README.md does not state the values these captures give - a typed value (the line is in .harness/values.txt): $($G -oE 'the values the video may say: [^*`]*' README.md | head -1 | cut -c1-200)"
echo "  README.md states the captures' values (.harness/values.txt, $(wc -c < .harness/values.txt | tr -d ' ') bytes)"
# hygiene
for f in .harness/rawpw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the password ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/SOLUTION.md receipts.md5 .harness/*.log; do [ "$(raw "$PW" "$f")" = 0 ] || die "$f holds the password, raw"; done
LBY=$($G -h -oE '[^ |(]+ \([0-9a-fA-F.:%]+\)' .harness/v/u37lockk .harness/v/u37lockpk 2> /dev/null | head -1 || true)
RH=0; for t in "$HN" "$HS" "$CIP"; do [ -z "$t" ] || RH=$((RH + $(raw "$t" .r-*.out README.md exercise/README.md exercise/SOLUTION.md))); done
[ "$RH" = 0 ] || die "a capture or the README holds the host name or the container's address raw ($RH) - lockedby must be masked"
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$LOGS" -gt 0 ] && [ "$PGJVM" -gt 0 ] && [ "$LQJVM" -gt 0 ] && [ "$FLJVM" -gt 0 ] || die "no JVM ran, or none on PostgreSQL, or none with Liquibase or Flyway"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) |Time elapsed| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a time or Boot's seconds"
  ! $G -qE '^ *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][T ]|(exec|handler|task)-[0-9]' "$f" || die "$f holds a log time or a thread number"
  ! $G -qE 'using Java [0-9]|PROBE version: Java [0-9]|Darwin|arm64|aarch64|musl|Debian|pgdg' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE '[0-9] ?ms\b|[0-9]+ ms\)' "$f" || die "$f holds a millisecond figure (R.264)"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'password=[^<*]' "$f" || die "$f holds a password in a URL"
  ! $G -qE 'https?://' "$f" || die "$f holds a URL"; done
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ (])java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned"
  ! $G -E '^ *\$ .*(^|[ (])java -D' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM without its alarm (R.247)"
  ! $G -E '^ *\$ .*docker ' "$f" | $G -vF -- 'docker -H "$DH" ' > /dev/null || die "$f calls docker without the pinned socket (R.332)"; done
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness (R.195)"
echo "  hygiene: raw password copies after mask: 0 in $(ls .harness/rawpw-* | wc -l | tr -d ' ') raw capture runs, $(ls .r-*.out | wc -l | tr -d ' ') captures and every log ($LOGS harness JVM logs, $PGJVM on PostgreSQL, $LQJVM with Liquibase, $FLJVM with Flyway); raw host name / container address copies: 0; no path, unit number, time, millisecond figure, thread number, OS token, password, URL or stack frame in any capture; every JVM pinned and under its alarm; no H2 file"
echo "  the trap over the whole run: $($G -vc '^#' .harness/trap.log || true) request lines, all $($G -v '^#' .harness/trap.log | $G -c 'CONNECT config.liquibase.com:443' || true) of them CONNECT config.liquibase.com:443 in the labelled default runs (one per capture run); it answered 403 to each and forwarded nothing"
# ---- the end: the trap, the H2 server, the container and its volume, the anchor, the ports ---------------------------------
for p in "$tpid" "$spid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; tpid=""; spid=""
pgrm; [ -z "$(dk ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "the container $CN is still there"
VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' '); IMGS1=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -)
[ "$VOL1" = "$VOL0" ] || die "R.322: the volume count moved, $VOL0 -> $VOL1 - a container left its volume (an rm -f without -v)"
[ "$IMGS1" = "$IMGS0" ] || die "the images moved over this run - nothing may be pulled"
echo "  docker at the end: the container removed with its volume (rm -fv); volumes $VOL0 -> $VOL1 (R.322); images $NI0, the same list (nothing pulled)"
anchortree end; anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 20160-20169 at the end - the trap bound 20166, the H2 server 20167 and the container 20168, each stopped or removed; 20160-20165 and 20169 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit37: every capture 3/3 and = published; every spoken number asserted; 0 raw passwords; every Liquibase JVM behind the trap with its key but the labelled default run; every database dropped; the volume count unchanged; no port bound but 20166, 20167 and 20168"
