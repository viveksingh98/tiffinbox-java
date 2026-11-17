#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Never Use ddl-auto in Production - this unit's receipts. A harness unit with no anchor change (brief flag 1): anchor is
# the link to ../c7-unit34/after, Section 5's frozen anchor (its tree's hash pinned). Hibernate's schema step (spring.jpa.hibernate.
# ddl-auto) is run against TiffinBox's real tables - the shipped Database class's own DDL and seed - on throwaway databases: per run a
# fresh database, the seed, the catalogue and the rows read by a second connection, ONE harness JVM with the value, the catalogue and
# the rows again, and the database dropped (R.178: each database dies with its run). Five captures, each run three times and hashed; a
# hash that differs from receipts.md5 stops the run; every number and string the video says is asserted right after its capture by
# harness/chk35.py, against another witness of the same run (the second connection beside the SQL logger), never against a typed figure.
#   default   Boot's default - no ddl-auto key - three labelled JVMs: PostgreSQL, H2 over TCP, H2 in the JVM's memory
#   values    create, create-drop, update and validate with the anchor's own entities, PostgreSQL then H2 over TCP
#   changes   four entity changes (the harness's variants, each mapping the anchor's customer table): a rename (int and Integer), a
#             length of 40 on the name (and again with a name longer than that in the table), a dropped field, a field as text -
#             update and validate each, both databases; the table of cells and the failure receipt (B, A, A')
#   xcheck    Hibernate's DDL script over the anchor's libraries, against the index lesson's xcheck.sql
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# The anchor is COPIED under .harness/ and built there, never in place, offline, its tests skipped (this unit runs none). Every JVM
# runs under an alarm (perl -e 'alarm N; exec ...'; R.247). Every docker call names its socket (docker -H "$DH", R.332); the container
# is removed with its volume (rm -fv) and the volume count is asserted unchanged (R.322). Ports (20140-20149): 20147 the H2 TCP server
# · 20148 the container · 20140-20146 and 20149 never bound (the harness JVMs bind none). Nothing leaves the machine.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c7u35-pg
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.332): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
pid=""; mpid=""; xpid=""; spid=""; CSTARTED=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.d.") || index($0, "probe.v.") || index($0, "probe.x.") || index($0, "org.h2.tools.") || $3 ~ /(^|\/)javac$/ || index($0, "jdk.compiler/com.sun.tools.javac") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "exec c7u35-pg") || index($0, "--name c7u35-pg")) { print $1 }' | paste -sd' ' -) || l=""
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
trap 'trap "" INT TERM; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid" "$spid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; pgrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp find docker unzip /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY PGPASSWORD PGOPTIONS PGHOST PGUSER DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
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
[ -L anchor ] && [ "$(readlink anchor)" = ../c7-unit34/after ] || die "anchor must be the link to ../c7-unit34/after - Section 5's frozen anchor"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "the anchor's pom.xml or README.md is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/hibernate-ddl.sql ] && die "anchor/ holds a secrets/, a target/ or a hibernate-ddl.sql - it is a frozen tree, never built in place"
T34='43 ff5f470f9dbd5774164212b85c1ea32e'            # unit 34's after/ at its commit 298c26e: 43 files (harness/tree35.py)
anchortree() { local t; t=$(python3 -I harness/tree35.py anchor/) || die "anchor/'s tree could not be hashed"
  [ "$t" = "$T34" ] || die "R.211: anchor/ (../c7-unit34/after, a shipped unit's frozen tree) is not the tree this unit stands on: $t, pinned $T34"
  echo "  anchor/'s tree ($1): python3 -I harness/tree35.py anchor/ -> $t = pinned (unit 34's after/, Section 5's frozen anchor)"; }
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox: empty - anchor/ = ../c7-tiffinbox"
  else echo "  note ($1): the live anchor moved on in unit 36; this unit stands on c7-unit34/after, pinned - diff -rq anchor/ ../c7-tiffinbox: $(printf '%s\n' "$d" | wc -l | tr -d ' ') lines ($(printf '%s\n' "$d" | head -2 | sed "s#$UP/##g" | paste -sd';' -))"; fi; }
anchortree start; anchornote start
YM=tiffinbox-web/src/main/resources/application.yaml
DA=$(sed -n -E 's/^ +ddl-auto: *([a-z-]+) *$/\1/p' anchor/$YM | paste -sd' ' -)
[ "$DA" = none ] || die "R.330: anchor/'s application.yaml ships ddl-auto: ${DA:-nothing} - 34/after ships none (36/after ships validate)"
echo "  R.330: anchor/$YM ships ddl-auto: $DA (read off the file: 34/after's, Section 5's; 36/after ships validate) - this unit's ddl-auto runs are the harness's, on databases that die with their run"
M2="$PWD/.m2-demo"
XD=tiffinbox-web/target/extracted
PGJ=org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar
HFILES='chk35.py dur7.py logback.xml s35.py src tree35.py'
SFILES='probe/d/Db.java probe/d/Main.java probe/d/Run.java probe/d/V.java probe/d/ex/Ex.java probe/v/drop/VMain.java probe/v/len40/VMain.java probe/v/rename/VMain.java probe/v/rename2/VMain.java probe/v/type/VMain.java probe/x/XMain.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5 xcheck.sql; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
cmp -s harness/src/probe/x/XMain.java ../c7-unit29/harness/src/probe/x/XMain.java || die "harness/src/probe/x/XMain.java is not unit 29's, byte for byte"
cmp -s harness/tree35.py ../c7-unit33/harness/tree33.py || die "harness/tree35.py is unit 33's tree33.py, byte for byte"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="20140 20141 20142 20143 20144 20145 20146 20147 20148 20149"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
[ -z "$(dk ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "a container named $CN exists - an interrupted run's? remove it with its volume (rm -fv, on the pinned socket)"
rm -rf .harness; mkdir -p .harness/run .harness/hc .harness/secrets .harness/v
echo "  ports: 20140-20149 free at the start"

# ---- the prose gates ----------------------------------------------------------------------------------------------------------
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s35.py harness/dur7.py $PROSE) || die "the prose gate did not run (or its self-test failed)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
echo "  prose, per sentence (s35, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test): dur7 words 0 · S4.7's family 0 · R.301's family 0 but beside a printed count · R.315 update said as adding only, or a WARN said as a stop, 0 · R.316 validate said to check every mismatch or a length, 0 · R.178 a ddl-auto run on a kept database 0 · R.302 a typed count (the brief's numbers, a length, letters or characters) 0 · R.190 tests as a witness 0 · R.287 Hibernate 5/6 wordings 0 · R.224 a call-back without its title 0 · \"Hibernate generates\" 0 - over README.md and exercise/"
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
prose() { awk -v f="$1" '/^<!-- (values|changes table): begin -->$/ { v = 1; next } /^<!-- (values|changes table): end -->$/ { v = 0; next } /^```/ { b = !b; next } !v && !b { print f ":" NR ": " $0 }' "$1"; }
SQLRE='alter table if exists|alter column [a-z_]+ set data type|add column [a-z_]+ integer|drop table if exists|create table (customer|pause|diner)|create index pause|insert into customer|drop database|select count'
TS=$(for f in $PROSE; do prose "$f"; done | $G -iE "$SQLRE" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string in the prose (R.225): $TS"
TC=$($G -nE '7f69''42f0|ff5f''470f9dbd' harness/chk35.py harness/src/probe/d/*.java 2> /dev/null | cut -c1-120 | head -3 | paste -sd';' - || true)
[ -z "$TC" ] || die "R.302: a printed md5 typed in the harness: $TC"
echo "  typed SQL strings 0 in the prose (outside printed blocks, the values block and the changes table) · R.302: no printed md5 typed in chk35.py or the harness's sources"

# ---- static checks of this script and the harness - before anything runs --------------------------------------------------
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
DK=$($G -v '^ *#' receipts.sh | $G -nE '\bdocker (run|exec|rm|ps|port|info|images|volume|image|pull|events)\b' | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.332: receipts.sh calls docker without the pinned socket (every call is dk, or a README line with -H \"\$DH\"): $DK"
! $G -v '^ *#' receipts.sh | $G -qE 'rm -f'' "?\$CN|rm -f'' c7u35' || die "R.322: receipts.sh removes the container without its volume (rm -fv)"
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
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/$XD/lib/*\" harness/src/probe/d/V.java harness/src/probe/d/Run.java harness/src/probe/d/Main.java harness/src/probe/d/Db.java harness/src/probe/v/*/VMain.java harness/src/probe/x/XMain.java")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../anchor/$XD/lib/*\$CPX\" \$MC \"\${A[@]}\"")
L_H2S=$(mine "cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' java $JL -Dh2.bindAddress=127.0.0.1 -cp \"../anchor/$XD/lib/h2-2.5.250.jar\" org.h2.tools.Server -tcp -tcpPort 20147 -ifNotExists")
L_RUN=$(mine "docker -H \"\$DH\" run -d --pull never --name $CN -p 127.0.0.1:20148:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v \"\$U/.harness/secrets/pgpw:/run/pgpw:ro\" $IMG")
L_READY=$(mine "docker -H \"\$DH\" exec $CN pg_isready -U sa -h 127.0.0.1 -q")
L_DB=$(mine "docker -H \"\$DH\" exec $CN psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c \"drop database if exists \$DB with (force)\" -c \"create database \$DB\"")
L_DROP=$(mine "docker -H \"\$DH\" exec $CN psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c \"drop database \$DB with (force)\" -c \"select coalesce(string_agg(datname, ', ' order by datname), '(none)') from pg_database where datname like 'u35%'\"")
L_PSQL=$(mine "docker -H \"\$DH\" exec $CN psql -U sa -d \"\$DB\" -qAt -v ON_ERROR_STOP=1 -c \"\$Q\"")
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s -DskipTests\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
[ "$(off .harness/anchor "$R_PLAIN" package)" = 'cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" clean package -DskipTests' ] || die "off(): the build line is not the README's package line, offline"
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
rsync -a --exclude target --exclude secrets --exclude .m2-demo anchor/ .harness/anchor/
mbuild "$(off .harness/anchor "$R_PLAIN" package)" .harness/build-anchor.log ".harness/anchor (anchor/ copied, the README's package line, -DskipTests)"
[ "$($G -c 'Tests run:' .harness/build-anchor.log || true)" = 0 ] || die "the build ran tests - this unit runs none"
(cd .harness/anchor && eval "$R_EXTRACT") > .harness/extract.log 2>&1 < /dev/null || die "the extract failed: $(tail -3 .harness/extract.log)"
for a in org/springframework/boot/spring-boot-dependencies/4.1.2/spring-boot-dependencies-4.1.2.pom com/h2database/h2/2.5.250/h2-2.5.250.jar "$PGJ"; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
LIB=.harness/anchor/$XD/lib; NL=$(ls $LIB | wc -l | tr -d ' ')
# R.335's form: the PostgreSQL driver is the harness's - the anchor's lib/ holds none; R.329: no Flyway, Liquibase or Testcontainers jar
NPG=$(ls $LIB | $G -cE '^postgresql-.*\.jar$' || true); NFL=$(ls $LIB | $G -c -i 'flyway\|liquibase\|testcontainers' || true)
[ "$NPG" = 0 ] || die "R.335: the anchor's lib/ holds a PostgreSQL driver - 34/after holds none; the harness adds it from .m2-demo"
[ "$NFL" = 0 ] || die "R.329: the anchor's lib/ holds a Flyway, Liquibase or Testcontainers jar ($NFL) - this unit loads none"
echo "  the anchor's jar extracted: lib/ holds $NL libraries (ls | wc -l), postgresql-*.jar among them: $NPG - every PostgreSQL JVM below adds .m2-demo/$PGJ: + the harness's driver (R.335's form) · ls lib | grep -c -i 'flyway\\|liquibase\\|testcontainers': $NFL - no Flyway, Liquibase or Testcontainers jar on this unit's class path (R.329 asks nothing of it)"
jc "$L_JAVAC" .harness/javac.log; [ "$JE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/d/ex ] || die "the exercise's class compiled into the harness's folder"
echo "  the harness compiled once (.harness/hc, $(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes; the exercise's class is compiled by its own lines)"
# the H2 TCP server: one JVM for this run, loopback only
echo "\$ $L_H2S" >&3
(eval "$L_H2S") > .harness/h2server.log 2>&1 < /dev/null & spid=$!
i=0; while [ $i -lt 120 ] && [ "$(listeners 20147)" = 0 ]; do kill -0 "$spid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
[ "$(listeners 20147)" = 1 ] || { cat .harness/h2server.log >&3; die "the H2 server never listened on 20147"; }
[ "$(lsof -nP -a -p "$spid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)" = '127.0.0.1:20147' ] || die "the H2 server must listen on 127.0.0.1:20147 alone"
H2SL=$($G -m1 'TCP server running at' .harness/h2server.log || true); [ "$H2SL" = 'TCP server running at tcp://localhost:20147 (only local connections)' ] || die "the H2 server's line: ${H2SL:-none}"
echo "  the H2 server: $H2SL - listens on 127.0.0.1:20147 alone"
# the container: PostgreSQL 18 from the pinned image, loopback only, a generated password in a 0600 file (R.214)
(umask 077 && LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom 2> /dev/null | head -c 24 > .harness/secrets/pgpw) || true
[ "$(wc -c < .harness/secrets/pgpw | tr -d ' ')" = 24 ] && [ "$(stat -f '%Lp' .harness/secrets/pgpw)" = 600 ] || die "the password file was not written, 24 characters, mode 0600"
PW=$(cat .harness/secrets/pgpw)
CSTARTED=1
(eval "$L_RUN") > .harness/docker-run.log 2>&1 < /dev/null || die "the container did not start: $(tail -2 .harness/docker-run.log)"
i=0; while ! (eval "$L_READY") > /dev/null 2>&1 < /dev/null; do i=$((i + 1)); [ $i -lt 120 ] || die "the container did not accept connections within its cap (120 tries, 0.5 apart)"; sleep 0.5; done
DP=$(dk port "$CN" 2> /dev/null | paste -sd'|' -)
[ "$DP" = '5432/tcp -> 127.0.0.1:20148' ] || die "the container must publish 5432 on 127.0.0.1:20148 alone: $DP"
echo "  the container: $CN from $IMG (--pull never); its published port: $DP; user sa, the password generated into .harness/secrets/pgpw (24 characters, mode 0600, never printed); pg_isready after $i tries (cap 120)"

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C $G -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; PGJVM=0
mask() { awk -v pw="$PW" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { W = lit(pw); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(W, "<pw>"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/PROBE version: Java [0-9][0-9.]+/, "PROBE version: Java <version>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'PROBE version: Java 25.0.4.1' "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' "url jdbc:postgresql://127.0.0.1:20148/u35?user=sa&password=$PW" > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'PROBE version: Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'url jdbc:postgresql://127.0.0.1:20148/u35?user=sa&password=<pw>')" ] || die "mask: the planted JDK version, folders, home, identity hash and the password must be masked"
echo "  mask: its self-test passed (the password, folders, home, identities, the JDK's version); raw password copies after mask: $(mask < .harness/p1 | $G -cF -- "$PW" || true)"
rm -f .harness/p1
CORE=--logging.level.org.hibernate.orm.core=info
HQ=(--logging.config=../../harness/logback.xml "$CORE" --spring.jpa.open-in-view=false --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false)
HE=""; MC=""; CPX=""
# hrun: one harness JVM, its stdout and stderr to .harness/h.log
hrun() { local c i=0 e=0 n
  c=$(printf 'cd .harness/run && %s\n' "$L_H")
  echo "  \$ CPX=$CPX; MC=$MC; V=($(printf '%s ' "${V[@]}" | sed 's/ $//')); A=($(printf '%q ' "${A[@]}" | sed 's/ $//'))"
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 1000 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running after 250 s - its alarm should have stopped it"; }
  wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1))
  [ "$HE" != 142 ] || die "the harness JVM's alarm fired (exit 142) - a run that does not end by itself is a failed receipt (R.247)"
  case " ${V[*]:-} " in *" -Dpg.db="*) PGJVM=$((PGJVM + 1)); n=$(raw "$PW" .harness/h.log); [ "$n" = 0 ] || die "a harness log held the password, raw ($n)" ;; esac; }
# hview: the lines a capture shows of a JVM's log - the version lines, HHH000001, every SQL line Hibernate logged (its statement text),
# the schema step's WARN lines and what the harness printed (PROBE); then the counts, before and after the closing marker
hview() { awk '/^PROBE / || /^INFO +\[main\] org\.hibernate\.orm\.core : HHH000001/ || /^DEBUG \[main\] org\.hibernate\.SQL : / || /^WARN +\[main\] org\.hibernate\.tool\.schema\./ { sub(/[ \t]+$/, ""); print "    " $0 }' .harness/h.log | mask
  awk -v e="$HE" '/^PROBE >>> closing the context$/ { c = 1 } /^DEBUG \[main\] org\.hibernate\.SQL : / { if (c) a++; else b++ } /GenerationTarget encountered exception/ { w++ } /^WARN / { x++ }
    END { printf "  exit %s · SQL lines before closing: %d · after closing: %d · GenerationTarget WARN lines: %d · WARN lines: %d\n", e, b, a, w, x }' .harness/h.log; }
# the PostgreSQL side: a fresh database per run, psql in the container as the second connection, the database dropped at the end
pgdb() { local DB=$1; (eval "$L_DB") > .harness/pgdb.log 2>&1 < /dev/null || die "the fresh database $DB was not made: $(tail -2 .harness/pgdb.log)"; }
psq() { local DB=$1 Q=$2; (eval "$L_PSQL") 2>&1 < /dev/null || true; }
PGCAT=("select 'tables: ' || coalesce(string_agg(table_name, ', ' order by table_name), '(none)') from information_schema.tables where table_schema = 'public'"
  "select 'col ' || table_name || '.' || column_name || ' ' || data_type || coalesce('(' || character_maximum_length || ')', '') || case when is_nullable = 'NO' then ' not null' else '' end || coalesce(' default ' || column_default, '') from information_schema.columns where table_schema = 'public' order by table_name, ordinal_position"
  "select 'constraint ' || conrelid::regclass || ' ' || conname || ' ' || pg_get_constraintdef(oid) from pg_constraint where connamespace = 'public'::regnamespace and contype <> 'n' order by conrelid::regclass::text, conname"
  "select 'index ' || tablename || ' ' || indexname from pg_indexes where schemaname = 'public' order by tablename, indexname")
pgcat() { local DB=$1 q c
  for q in "${PGCAT[@]}"; do psq "$DB" "$q" | sed 's/^/    /'; done
  if [ "$(psq "$DB" "select count(*) from information_schema.tables where table_schema = 'public' and table_name in ('customer', 'pause')")" = 2 ]; then
    psq "$DB" "select 'rows customer ' || (select count(*) from customer) || ' · pause ' || (select count(*) from pause)" | sed 's/^/    /'
    psq "$DB" "select 'customers: ' || string_agg(id || ' ' || name, ', ' order by id) from customer" | $G -v '^customers: $' | sed 's/^/    /' || true
    psq "$DB" "select 'meals_per_day: ' || string_agg(meals_per_day::text, ' ' order by id) from customer" | $G -v '^meals_per_day: $' | sed 's/^/    /' || true
    psq "$DB" "select 'price_per_meal: ' || string_agg(price_per_meal::text, ' ' order by id) from customer" | $G -v '^price_per_meal: $' | sed 's/^/    /' || true
    c=$(psq "$DB" "select count(*) from information_schema.columns where table_schema = 'public' and table_name = 'customer' and column_name = 'meals_daily'")
    [ "$c" = 0 ] || psq "$DB" "select 'meals_daily: ' || string_agg(coalesce(meals_daily::text, 'null'), ' ' order by id) from customer" | sed 's/^/    /'
  else echo "    rows: (no table)"; fi; }
# h2 OPS: the run's H2 database over TCP - the seed, the second connection, the drop (probe.d.Db, its own JVM each time)
h2() { local c e=0; c="cd .harness/run && $AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../anchor/$XD/lib/*\" probe.d.Db \"\$H2U\" $*"
  echo "  \$ $c"
  (eval "$(exe "$c")") > .harness/db.out 2>&1 < /dev/null & pid=$!; wait "$pid" || e=$?; pid=""
  [ "$e" = 0 ] || { cat .harness/db.out >&3; die "probe.d.Db on H2 failed (exit $e)"; }
  sed 's/^/    /' .harness/db.out; }
pgseed() { local c e=0; c="cd .harness/run && $AL java $JL -Dstdout.encoding=UTF-8 -Dpg.db=$1 -Dpg.pwfile=../secrets/pgpw -cp \"../hc:../anchor/$XD/lib/*:../../.m2-demo/$PGJ\" probe.d.Db pg seed"
  echo "  \$ $c"
  (eval "$(exe "$c")") > .harness/db.out 2>&1 < /dev/null & pid=$!; wait "$pid" || e=$?; pid=""
  [ "$e" = 0 ] || { mask < .harness/db.out >&3; die "the seed on PostgreSQL failed (exit $e)"; }
  [ "$(raw "$PW" .harness/db.out)" = 0 ] || die "the seed's output held the password, raw"
  sed 's/^/    /' .harness/db.out; }
LONG=""
# one LABEL DB MC [ARGS...]: one run of record - a fresh database, the shipped seed, the second connection, ONE JVM, the second
# connection again, the database dropped. PRE (a function name) runs on the seeded database before the JVM.
PRE=""
one() { local L=$1 D=$2; MC=$3; shift 3; local DB=$L H2U="jdbc:h2:tcp://127.0.0.1:20147/mem:$L;DB_CLOSE_DELAY=-1"
  echo "-- $L · $( [ $D = pg ] && echo PostgreSQL || echo 'H2 over TCP') · $MC${*:+ $*}"
  if [ $D = pg ]; then
    echo "  \$ DB=$L; $L_DB"; pgdb "$L"; echo "  a fresh database: $L"; pgseed "$L"
    echo "  the second connection (psql in the container), before:"; pgcat "$L"
    [ -z "$PRE" ] || $PRE pg "$L"
    CPX=":../../.m2-demo/$PGJ"; V=(-Dpg.db=$L -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}" "$@"); hrun; hview > .harness/v/$L-pg; cat .harness/v/$L-pg
    echo "  the second connection (psql in the container), after the JVM exited:"; pgcat "$L"
    echo "  \$ DB=$L; $L_DROP"
    echo "  the database dies with its run (R.178): drop database $L with (force) · the databases named u35… now: $( (eval "$L_DROP") 2>&1 < /dev/null | tail -1)"
  else
    echo "  H2U=$H2U"; h2 seed cat
    [ -z "$PRE" ] || $PRE h2 "$L"
    CPX=""; V=(); A=("--spring.datasource.url=$H2U" --spring.datasource.username=sa "${HQ[@]}" "$@"); hrun; hview > .harness/v/$L-h2; cat .harness/v/$L-h2
    echo "  the second connection (probe.d.Db over TCP), after the JVM exited - then the database dies with its run (R.178):"; h2 cat drop
  fi; }
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
  o=$(python3 -I -B harness/chk35.py "$nm" "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' | tee .harness/chk-$nm.out || true
  [ $e = 0 ] || die "$nm: its check failed (harness/chk35.py, above)"
  VALS="$VALS${VALS:+ · }$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }

# ---- the captures --------------------------------------------------------------------------------------------------------
# default: no ddl-auto key - Boot's default, read off the EMF's property (R.188), three labelled JVMs
default() { echo "default - no ddl-auto key: Boot's default, read off the EntityManagerFactory's own properties (R.188); the anchor's two entities (probe.d.Main):"
  one u35dpg pg probe.d.Main
  one u35dtcp h2 probe.d.Main
  echo "-- u35dmem · H2 in the JVM's memory (jdbc:h2:mem:, Boot's embedded database) · probe.d.Main - no seed, no second connection: the database lives and dies in this JVM"
  CPX=""; V=(); A=('--spring.datasource.url=jdbc:h2:mem:u35dmem;DB_CLOSE_DELAY=-1' "${HQ[@]}"); hrun; hview > .harness/v/u35dmem-mem; cat .harness/v/u35dmem-mem; }
# values: create, create-drop, update, validate - the anchor's own entities over Database's seeded tables
values() { local v d
  echo "values - the anchor's own entities (probe.d.Main) over the shipped Database's seeded tables, one value per run:"
  for d in pg h2; do for v in create create-drop update validate; do one "u35v${v//-/}$d" $d probe.d.Main --spring.jpa.hibernate.ddl-auto=$v; done; done; }
# changes: the harness's variants - each its own package and @Entity, each mapping the anchor's customer table with one change
long() { local db=$1 L=$2 q
  q="insert into customer (name, meals_per_day, price_per_meal, meal_type) values ('$LONG', 2, 110, 'VEG')"; local qp="with i as ($q returning 1) select 'rows ' || count(*) from i"
  echo "  the over-long name, built by this script (one name repeated, printf): $LONG"
  echo "  length: ${#LONG} characters (\${#LONG})"
  echo "  inserted by the second connection: insert into customer (name, meals_per_day, price_per_meal, meal_type) values ('<the name>', 2, 110, 'VEG')"
  if [ "$db" = pg ]; then echo "    $(psq "$L" "$qp")"
  else local H2U="jdbc:h2:tcp://127.0.0.1:20147/mem:$L;DB_CLOSE_DELAY=-1"; c="cd .harness/run && $AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../anchor/$XD/lib/*\" probe.d.Db \"\$H2U\" exec \"\$q\""
    (eval "$(exe "$c")") > .harness/db.out 2>&1 < /dev/null & pid=$!; wait "$pid" || true; pid=""; sed 's/^/    /' .harness/db.out; fi; }
changes() { local d v
  echo "changes - four changes to the entity, each a variant of the harness's (probe.v.<name>.VMain: its own @Entity, mapping the anchor's customer table with one change), update then validate, over a freshly seeded table each:"
  for d in pg h2; do
    one u35rename${d}u $d probe.v.rename.VMain --spring.jpa.hibernate.ddl-auto=update
    one u35rename${d}v $d probe.v.rename.VMain --spring.jpa.hibernate.ddl-auto=validate
    one u35renametwo${d}u $d probe.v.rename2.VMain --spring.jpa.hibernate.ddl-auto=update
    one u35len${d}u $d probe.v.len40.VMain --spring.jpa.hibernate.ddl-auto=update
    PRE=long; one u35lenlong${d}u $d probe.v.len40.VMain --spring.jpa.hibernate.ddl-auto=update; PRE=""
    one u35len${d}v $d probe.v.len40.VMain --spring.jpa.hibernate.ddl-auto=validate
    one u35drop${d}u $d probe.v.drop.VMain --spring.jpa.hibernate.ddl-auto=update
    one u35drop${d}v $d probe.v.drop.VMain --spring.jpa.hibernate.ddl-auto=validate
    one u35type${d}u $d probe.v.type.VMain --spring.jpa.hibernate.ddl-auto=update
    one u35type${d}v $d probe.v.type.VMain --spring.jpa.hibernate.ddl-auto=validate
  done
  echo "the failure receipt - three labelled runs, side by side (PostgreSQL; each a step above):"
  echo "  B  len40 · update:   $($G -m1 -oE 'alter table if exists customer alter column name set data type varchar\([0-9]+\)' .harness/v/u35lenpgu-pg || echo none) · $($G -m1 -oE 'exit [0-9]+' .harness/v/u35lenpgu-pg)"
  echo "  A  len40 · validate: $($G -m1 -oE 'PROBE ready: [a-z]+' .harness/v/u35lenpgv-pg) · $($G -m1 -oE 'exit [0-9]+' .harness/v/u35lenpgv-pg) · SQL lines $($G -m1 -oE 'before closing: [0-9]+' .harness/v/u35lenpgv-pg | sed 's/.*: //')"
  echo "  A' type · validate:  $($G -m1 -oE 'PROBE ready: [a-z]+' .harness/v/u35typepgv-pg) · $($G -m1 -oE 'exit [0-9]+' .harness/v/u35typepgv-pg) · $($G -m1 -oE 'Schema validation: wrong column type [^;]*' .harness/v/u35typepgv-pg || echo none)"
  echo "the exception chain of one refusal (rename · validate on PostgreSQL, its PROBE cause lines, grep -o):"
  $G -oE 'PROBE cause: [a-z.]+\.[A-Za-z]+' .harness/v/u35renamepgv-pg | sed 's/PROBE cause: //' | paste -sd'|' - | sed 's/|/ <- /g; s/^/  /'; }
# xcheck: Hibernate's DDL script over the anchor's libraries (R.252: Hibernate's schema generation writes it)
XA=('--spring.datasource.url=jdbc:h2:mem:x35;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml "$CORE" --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
X34=$(md5 -q ../c7-unit34/xcheck.sql)
xcheck() {
  echo "Hibernate's DDL over the anchor's libraries - probe.x.XMain, scripts.action=create (a file, never run):"
  rm -f .harness/run/hibernate-ddl.sql; CPX=""; MC=probe.x.XMain; V=(); A=("${XA[@]}"); hrun
  echo "  exit $HE · HHH000001: $($G -c 'HHH000001: Hibernate ORM core version 7.4.13.Final' .harness/h.log || true)"
  [ -f .harness/run/hibernate-ddl.sql ] || die "xcheck: no script"
  mv .harness/run/hibernate-ddl.sql .harness/ddl-anchor.sql
  echo "  .harness/ddl-anchor.sql - every line:"; sed -E 's/FK[0-9a-z]{20,}/FK<name>/g; s/^/    /' .harness/ddl-anchor.sql
  echo "  the anchor's md5: $(md5 -q .harness/ddl-anchor.sql) · the filed xcheck.sql: $(md5 -q xcheck.sql) · cmp: $(cmp -s .harness/ddl-anchor.sql xcheck.sql && echo 'the same, byte for byte' || echo differ) · the index lesson's xcheck.sql: $X34 · diff: $(diff ../c7-unit34/xcheck.sql .harness/ddl-anchor.sql | $G -c '^[<>]' || true) lines"; }
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
  echo "  the shell is now in: $(where "$d1") · broken's md5 (what it printed): $(sed -E 's/[[:space:]]+$//' .harness/ex-readme.out | md5 -q)"
  echo "  then the solution's lines, in the same shell - the block's exit $e2 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · solved's md5 (what it printed): $(sed -E 's/[[:space:]]+$//' .harness/ex-sol.out | md5 -q) · the classes it compiled: $(cd .harness/ex/classes 2> /dev/null && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -) · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines"; }
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
EXQ="Your turn: the README's entity reads meals a day as text, and update turns the integer column into text. Make the start refuse the change instead."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
LONG=$(printf 'Kavya%.0s' 1 2 3 4 5 6 7 8 9)
cap default default; chk default .r-default.out; pub default
cap values values; chk values .r-values.out; pub values
cap changes changes; chk changes .r-changes.out; pub changes
python3 -I -B harness/chk35.py table .r-changes.out README.md > .harness/table.out || { cat .harness/table.out; die "R.261: README.md's changes table is not the table the cell lines build"; }
cat .harness/table.out
cap xcheck xcheck; chk xcheck .r-xcheck.out "$X34" "$(md5 -q xcheck.sql)"; pub xcheck
cap exercise exercise; chk exercise .r-exercise.out "$EXW"; pub exercise
for f in exercise/README.md exercise/SOLUTION.md; do
  w=$(python3 -I -B harness/chk35.py wib .r-exercise.out "$f"); [ "$(wib "$f")" = "$w" ] || die "$f's \"What it prints\" block is not what its lines printed: $(diff <(wib "$f") <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "exercise: broken and solved print the same (R.196)"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
echo "  exercise: each file's What it prints = the run (bash's), the two differ (R.196); the spoken line $EXW words (wc -w)"
# R.302: every line of README.md's ```text blocks is a line a run printed
cat .r-*.out .harness/chk-*.out .harness/table.out 2> /dev/null | sed -E 's/^ +//' > .harness/printed.txt
TX=$(awk '/^```text$/ { b = 1; next } b && /^```$/ { b = 0; next } b && NF { sub(/^ +/, ""); print }' README.md | while IFS= read -r l; do $G -qxF -- "$l" .harness/printed.txt || printf '%s\n' "$l"; done | head -3 | cut -c1-160 | paste -sd';' -)
[ "$($G -c '^```text$' README.md)" -gt 0 ] && [ -z "$TX" ] || die "R.302: README.md's text blocks must be lines the runs printed - not printed: ${TX:-no text block}"
echo "  R.302: README.md's $($G -c '^```text$' README.md) text blocks - every line one the runs printed"
VS="the values the video may say: on PostgreSQL 18.6 and H2 2.5.250, Spring Boot 4.1.2, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final, no Flyway, Liquibase or Testcontainers jar on the class path, tests run: 0 - $VALS"
printf '%s\n' "$VS" > .harness/values.txt
$G -qxF -- "$VS" README.md || die "README.md does not state the values these captures give - a typed value (the line is in .harness/values.txt): $($G -oE 'the values the video may say: [^*`]*' README.md | head -1 | cut -c1-200)"
echo "  README.md states the captures' values (.harness/values.txt, $(wc -c < .harness/values.txt | tr -d ' ') bytes)"
# hygiene
for f in .harness/rawpw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the password ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/SOLUTION.md receipts.md5 .harness/*.log; do [ "$(raw "$PW" "$f")" = 0 ] || die "$f holds the password, raw"; done
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$LOGS" -gt 0 ] && [ "$PGJVM" -gt 0 ] || die "no JVM ran, or none on PostgreSQL"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) |Time elapsed| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a time or Boot's seconds"
  ! $G -qE '^ *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][T ]|(exec|handler|task)-[0-9]' "$f" || die "$f holds a log time or a thread number"
  ! $G -qE 'using Java [0-9]|PROBE version: Java [0-9]|Darwin|arm64|aarch64|musl|Debian|pgdg' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE '[0-9] ms\b|[0-9]+ ms\)' "$f" || die "$f holds a millisecond figure (R.264)"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'password=[^<*]' "$f" || die "$f holds a password in a URL"
  ! $G -qE 'https?://' "$f" || die "$f holds a URL"; done
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ (])java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned"
  ! $G -E '^ *\$ .*(^|[ (])java -D' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM without its alarm (R.247)"
  ! $G -E '^ *\$ .*docker ' "$f" | $G -vF -- 'docker -H "$DH" ' > /dev/null || die "$f calls docker without the pinned socket (R.332)"; done
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness (R.195)"
echo "  hygiene: raw password copies after mask: 0 in $(ls .harness/rawpw-* | wc -l | tr -d ' ') raw capture runs, $(ls .r-*.out | wc -l | tr -d ' ') captures and every log ($LOGS harness JVM logs, $PGJVM on PostgreSQL); no path, unit number, time, millisecond figure, thread number, OS token, password, URL or stack frame in any capture; every JVM pinned and under its alarm; no H2 file"
# ---- the end: the H2 server, the container and its volume, the anchor, the ports ----------------------------------------------
if [ -n "$spid" ] && kill "$spid" 2> /dev/null; then wait "$spid" 2> /dev/null || true; fi; spid=""
pgrm; [ -z "$(dk ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "the container $CN is still there"
VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' '); IMGS1=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -)
[ "$VOL1" = "$VOL0" ] || die "R.322: the volume count moved, $VOL0 -> $VOL1 - a container left its volume (an rm -f without -v)"
[ "$IMGS1" = "$IMGS0" ] || die "the images moved over this run - nothing may be pulled"
echo "  docker at the end: the container removed with its volume (rm -fv); volumes $VOL0 -> $VOL1 (R.322); images $NI0, the same list (nothing pulled)"
anchortree end; anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 20140-20149 at the end - the H2 server bound 20147 and stopped, the container 20148 and was removed; 20140-20146 and 20149 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit35: every capture 3/3 and = published; every spoken number asserted; 0 raw passwords; every ddl-auto run's database dropped; the volume count unchanged; no port bound but 20147 and 20148"
