#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 8 · Why Another Data Module - this unit's receipts. A harness unit: NO anchor change. anchor/ is a link to
# ../c8-unit02/after (both Spring Data modules; pinned by harness/tree01.py against receipts.md5's anchor-tree line), jpa-only/ a
# link to ../c8-unit02/before (Spring Data JPA alone - the set-up commit 50d64ac's c8-tiffinbox, checked against git archive).
# Six captures, each run three times and hashed; a hash that differs from receipts.md5 stops the run; every number the video may say
# is asserted right after its capture by harness/chk01.py against another witness of the same run - psql in this run's container,
# JdbcTemplate, Hibernate's getPrepareStatementCount() beside the statement witness (datasource-proxy 1.11.1, the harness's alone),
# the data line, the other JVM - never against a typed figure.
#   data        the data line, built before any count: V2's rows + 36 customers with one 2-day pause each (JdbcTemplate), read back
#               by psql (PostgreSQL 18.6)
#   context     ONE transaction: A = Spring Data JPA's read, B = Spring Data JDBC's read in the same transaction, A' = A again - the
#               persistence context's counts after each window, the commit's flush (flushCount, findDirty calls), then readOnly =
#               true; two JVMs on PostgreSQL (three rounds each), the same on H2 in memory
#   statements  the dashboard's page three ways from one JVM, a witness window per side: Spring Data JPA, Spring Data JDBC, JdbcClient
#               - PostgreSQL, then H2
#   tree        mvn -o dependency:tree on anchor/ and jpa-only/ (the version lines); Boot's BOM for the Spring Data train; the
#               set-up's sweep file for 4.2.0 (read from disk, never online)
#   alone       a COPY of anchor/ without Spring Data JPA's starter: mvn package, then java -jar (20402) - never the anchor
#   exercise    exercise/README.md's lines, then SOLUTION.md's, as written, in ONE env -i shell - bash, then zsh -f; then the other
#               solution SOLUTION.md names (read through CustomerAggregates), a sed on a copy
# Every tree is COPIED under .harness/ and built there, offline. Every JVM and every Maven run runs under an alarm (perl -e
# 'alarm N; exec ...'; R.247). Every docker call names its socket (docker -H "$DH"); the container is removed with its volume
# (rm -fv) and the volume count is asserted unchanged. Ports (20400-20409): 20401 this run's PostgreSQL container · 20402 the alone
# copy's TiffinBox (it stops before it binds); 20400 is never bound - the harness runs with no web server, no page is fetched over
# HTTP - and 20403-20409 are spare, never bound. Nothing leaves the machine.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c8u01-pg
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
pid=""; CSTARTED=""; INTR=""
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d i=0; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true
  while [ $i -lt 40 ] && { kill -0 "$1" 2> /dev/null || for x in $d; do kill -0 "$x" 2> /dev/null && break; done; }; do sleep 0.25; i=$((i + 1)); done
  kill -9 "$1" $d 2> /dev/null || true; }
# pgrm: docker rm -fv - the container AND its anonymous volume (R.322) - again until docker ps -a names it no more
pgrm() { local i=0; [ -n "$CSTARTED" ] || return 0
  while [ $i -lt 20 ]; do dk rm -fv "$CN" > /dev/null 2>&1 || true
    [ -z "$(dk ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] && break
    sleep 0.5; i=$((i + 1)); done; CSTARTED=""; }
trap 'trap "" INT TERM; if [ -n "$pid" ]; then killtree "$pid"; wait "$pid" 2> /dev/null || true; fi; pgrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find openssl docker git tar unzip /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PG[A-Z]*|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"

# ---- gates before anything is written: the folder, the links, the pins, the prose, the static checks ---------------------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md anchor exercise harness jpa-only pinned.txt receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk01.py dur8.py logback.xml s801.py src tree01.py' ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe/u01/DirtyCount.java probe/u01/U1.java probe/u01/Witness.java' ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'Ex01.java README.md SOLUTION.md' ] || die "exercise/ holds another file, or misses one"
cmp -s harness/dur8.py ../c8-unit02/harness/dur8.py || die "harness/dur8.py is not the builders' dur8.py as unit 02 shipped it, byte for byte"
[ "$(diff ../c8-unit02/harness/src/probe/u02/Witness.java harness/src/probe/u01/Witness.java | $G -c '^[<>]')" = 2 ] && diff ../c8-unit02/harness/src/probe/u02/Witness.java harness/src/probe/u01/Witness.java | $G -qx '> package probe.u01;' || die "R.357: harness/src/probe/u01/Witness.java must be unit 02's witness with its package line alone changed"
[ -L anchor ] && [ "$(readlink anchor)" = ../c8-unit02/after ] || die "anchor must be a link to ../c8-unit02/after (it points at: $(readlink anchor 2> /dev/null || echo 'not a link'))"
[ -L jpa-only ] && [ "$(readlink jpa-only)" = ../c8-unit02/before ] || die "jpa-only must be a link to ../c8-unit02/before (it points at: $(readlink jpa-only 2> /dev/null || echo 'not a link'))"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree01.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/ ($3): python3 -I harness/tree01.py $dir/ -> files and md5 = receipts.md5's $nm line"; }
pin anchor-tree anchor start; pin jpa-only-tree jpa-only start
PIN=$(cat pinned.txt)
[ "$(wc -l < pinned.txt | tr -d ' ')" = 1 ] && [ -n "$PIN" ] || die "pinned.txt must hold one line: Course 7's definition sentence"
$G -qF -- "$PIN" README.md || die "C8-8: README.md does not quote pinned.txt's sentence byte for byte"
LPV="$UP/../.."; [ -d "$LPV/spring-data-beyond-jpa" ] || LPV="$HOME/Downloads/Youtube Content/LearnProgrammingWithVivek"   # the course folders (a clone elsewhere: the author's)
C704="$LPV/data-jpa-hibernate/scripts-and-decks/04-the-persistence-context.md"
SW="$LPV/spring-data-beyond-jpa/_research/sweep-2026-11-17"
if [ -f "$C704" ]; then $G -qF -- "$PIN" "$C704" || die "C8-8: pinned.txt's sentence is not in Course 7's script The Persistence Context, byte for byte"; C7NOTE="found in Course 7's script The Persistence Context, byte for byte"
else C7NOTE="Course 7's script is not beside this repository here (a clone elsewhere) - the pin is checked against README.md only"; fi
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s801.py harness/dur8.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -2 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line \|⚑1' | head -4 | paste -sd';' -)"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|naan|sabzi|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|raita|korma|tikka|masala|samosa|pakora|halwa|kheer|jalebi|ladoo|vada|bhaji|aloo|gobi|jain'
DN=$($G -rniwE -- "$DISH" README.md exercise harness 2> /dev/null | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
for n in 'Spring Data J-P-A' 'Spring Data J-D-B-C' 'Spring Data Commons'; do $G -qF -- "$n" README.md || die "C8-7: README.md does not gloss \"$n\" at first use"; done
# the exercise's shape: one spoken line, two blocks one line apart, each with its alarm
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
EXQ="Your turn: the count says seventy-eight. Change one customer inside that transaction without calling save, and make the commit write nothing."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SETUP=$(block exercise/README.md); SOL=$(block exercise/SOLUTION.md)
[ -n "$SETUP" ] && [ -n "$SOL" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
[ "$(diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G -c '^[<>]')" = 2 ] || die "R.196: SOLUTION.md's block must be the README's with one line changed (it is $(diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G -c '^[<>]') lines apart)"
printf '%s\n' "$SETUP" | $G -E '(^|[ (])(mvn|java) ' | $G -vqF "perl -e 'alarm " && die "exercise/README.md's Java runs must run under their alarm (R.247)"
! printf '%s\n' "$SETUP" | $G -q 'DOCKER_HOST\|docker ' || die "the exercise needs no Docker: its block names DOCKER_HOST or docker"
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
# static: the docker socket, the container's volume, no sleep in the harness, the witness the harness's alone
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket (docker -H \"\$DH\")"
DK=$($G -v '^ *#' receipts.sh | $G -nE '\bdocker (run|exec|rm|ps|port|info|images|volume|image|pull|events)\b' | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.344: receipts.sh calls docker without the pinned socket (every call is dk): $DK"
! $G -v '^ *#' receipts.sh | $G -qE 'rm -f'' "?\$CN|rm -f'' c8u01' || die "R.322: receipts.sh removes a container without its volume (rm -fv)"
$G -q 'dk rm -fv "$CN"' receipts.sh || die "R.322: the container is removed with its volume (dk rm -fv)"
! $G -rqE 'Thread\.sleep|while *\(true\)|TimeUnit\.[A-Z]+\.sleep|jcmd|GC\.class_histogram' harness/src exercise/Ex01.java || die "a harness class sleeps, polls or attaches jcmd (R.361: jcmd refused)"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
! $G -rq 'datasource-proxy\|ttddyy' anchor/pom.xml anchor/tiffinbox-core anchor/tiffinbox-web || die "R.357: the witness is named in the anchor - it is the harness's alone"
# mask: the duration words a builder must never pass on (R.366) - its self-test feeds the planted lines
mask() { awk -v u="$U" -v up="$UP" -v hm="$HOME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  BEGIN { P = lit(u); Q = lit(up); H = lit(hm) }
  { gsub(P, "…"); gsub(Q, "…/.."); gsub(H, "~")
    gsub(/ in [0-9.]+ seconds \(process running for [0-9.]+\)/, " in <t> (process running for <t>)")
    gsub(/Time elapsed: [0-9.]+ s/, "Time elapsed: <t>")
    gsub(/\(execution time [0-9:.]+s\)/, "(execution time <t>)")
    gsub(/scanning in [0-9]+ ms/, "scanning in <t>")
    gsub(/Total time: +[0-9.:]+ [a-z]+/, "Total time: <t>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxWebTest in 3.1 seconds (process running for 4.2)' 'Tests run: 2, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 3.982 s' 'Finished Spring Data repository scanning in 23 ms. Found 1 JPA repository interface.' 'Successfully applied 3 migrations (execution time 00:00.026s)' "$U/x $HOME/y" | mask)
printf '%s\n' "$MP" | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=sys.stdin.read(); sys.exit(1 if m.DUR.search(t) else 0)' || die "R.366: the mask's self-test - a planted duration line passed it unmasked: $(printf '%s\n' "$MP" | head -2 | paste -sd';' -)"
[ "$(printf '%s\n' "$MP" | tail -1)" = '…/x ~/y' ] || die "the mask's self-test: the folders and the home must be masked"
echo "  gates before any write: the folder's files; dur8.py = unit 02's; the witness = unit 02's but its package line (R.357); the links anchor -> ../c8-unit02/after, jpa-only -> ../c8-unit02/before"
echo "  C8-8: pinned.txt's sentence in README.md, byte for byte; $C7NOTE"
echo "  prose, per sentence (s801, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test): refused 0 over $PROSE · dish names 0 · the three names glossed (C8-7)"
echo "  the exercise: the spoken line $EXW words; SOLUTION.md's block = the README's with one line changed; the two \"What it prints\" blocks differ (R.196); no Docker"
echo "  static: every docker call on the pinned socket; the container removed with its volume; no sleep, poll or jcmd in the harness; the witness absent from the anchor; the mask's self-test refused the planted Started-in-seconds line (R.366)"

# ---- docker and ports: the baselines ---------------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that socket? (R.344)"
IMGS0=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -); NI0=$(printf '%s\n' "$IMGS0" | wc -w | tr -d ' ')
VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI0" -ge 1 ] && [ "$VOL0" -ge 1 ] || die "the baselines must not be empty - images $NI0, volumes $VOL0"
dk image inspect "$IMG" > /dev/null 2>&1 || die "the image $IMG is not on this machine - this script never pulls"
[ -z "$(dk ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "a container named $CN exists - an interrupted run's? remove it with its volume (docker -H \"\$DH\" rm -fv $CN)"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 20400 20401 20402 20403 20404 20405 20406 20407 20408 20409"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · the image $IMG present (never pulled) · ports 20400-20409 (and 18425, 8080) free"

# ---- the trees, copied; the builds; the harness --------------------------------------------------------------------------------
rm -rf .harness; mkdir -p .harness/run/secrets/tiffinbox .harness/b50 .harness/hc
M2="$PWD/.m2-demo"
DSP="$M2/net/ttddyy/datasource-proxy/1.11.1/datasource-proxy-1.11.1.jar"   # the statement witness, the harness's alone
[ -d "$M2" ] && [ -e "$DSP" ] || die ".m2-demo (a copy of the course's seed, _research/m2-seed-c8-s1) or datasource-proxy 1.11.1 in it is missing - README.md, The repository"
git -C "$UP" rev-parse -q --verify '50d64ac^{commit}' > /dev/null 2>&1 || die "the set-up commit 50d64ac is not in this repository's history - jpa-only/ is checked against it"
git -C "$UP" archive 50d64ac c8-tiffinbox 2> /dev/null | tar -x -C .harness/b50 || die "git archive 50d64ac c8-tiffinbox failed"
JD=$(diff -rq jpa-only/ .harness/b50/c8-tiffinbox 2>&1 || true); [ -z "$JD" ] || die "jpa-only/ is not c8-tiffinbox at 50d64ac: $(printf '%s\n' "$JD" | head -2 | paste -sd';' -)"
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c8-tiffinbox 2>&1 || true)
echo "  jpa-only/: diff -rq against git archive 50d64ac c8-tiffinbox: empty - the JPA-only tree (RED #8) · anchor/ against ../c8-tiffinbox: $( [ -z "$AD" ] && echo 'empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures anchor/')"
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy anchor .harness/after; copy jpa-only .harness/before; copy anchor .harness/alone
perl -0pi -e 's#    <dependency>\n      <groupId>org.springframework.boot</groupId>\n      <artifactId>spring-boot-starter-data-jpa</artifactId>\n    </dependency>\n##' .harness/alone/tiffinbox-web/pom.xml
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & pid=$!; wait "$pid" || RE=$?; pid=""; }
offl() { [ "$($G -cE '^\[INFO\] Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
bg "cd .harness/after && perl -e 'alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\" clean package -DskipTests" .harness/build-after.log
[ "$RE" = 0 ] || { tail -20 .harness/build-after.log >&3; die "anchor/'s copy did not build offline (exit $RE)"; }; offl .harness/build-after.log
XD=tiffinbox-web/target/extracted
bg "cd .harness/after && perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract.log
[ "$RE" = 0 ] || die "the extract failed"
DRV=$(ls .harness/after/$XD/lib | $G -E '^postgresql-.*\.jar$' || true)
[ -n "$DRV" ] || die "the anchor's jar holds no PostgreSQL driver"
bg "javac -parameters -d .harness/hc -cp \".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*:\$DSP\" harness/src/probe/u01/*.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/run/secrets/tiffinbox/shutdown-token) || die "the token was not written"
echo "  built anchor/'s copy offline (mvn -o package -DskipTests, exit 0, 'Downloaded from' 0); extracted its jar ($(ls .harness/after/$XD/lib | wc -l | tr -d ' ') libraries; its own driver $DRV); the harness compiled ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes) against it and the witness; a shutdown token generated into .harness/run (0600, never printed)"
# the container: PostgreSQL 18 from the pinned image, loopback only, trust on loopback (compose.yaml's own choice; no password anywhere)
CSTARTED=1
bg "dk run -d --pull never --name $CN -p 127.0.0.1:20401:5432 -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust $IMG" .harness/docker-run.log
[ "$RE" = 0 ] || die "the container did not start: $(tail -2 .harness/docker-run.log)"
i=0; while ! dk exec "$CN" pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 120 ] || die "the container did not accept connections (120 tries)"; sleep 0.5; done
DP=$(dk port "$CN" 2> /dev/null | paste -sd'|' -)
[ "$DP" = '5432/tcp -> 127.0.0.1:20401' ] || die "the container must publish 5432 on 127.0.0.1:20401 alone: $DP"
echo "  the container: $CN from $IMG (--pull never), published $DP, user tiffinbox, trust on loopback; pg_isready (cap 120 tries)"

# ---- helpers -------------------------------------------------------------------------------------------------------------------
psq() { dk exec "$CN" psql -U tiffinbox -d "$1" -qAt -v ON_ERROR_STOP=1 -c "$2" 2>&1 || die "psql failed on $1: $2"; }
pgdb() { psq postgres "drop database if exists $1 with (force)" > /dev/null; psq postgres "create database $1" > /dev/null; echo "  a fresh database: $1 (psql)"; }
pgdrop() { psq postgres "drop database $1 with (force)" > /dev/null; echo "  dropped: $1"; }
L_H="perl -e 'alarm 240; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../after/$XD/tiffinbox-web-1.0.0.jar:../after/$XD/lib/*:\$DSP\" probe.u01.U1 \$STEPS --logging.config=../../harness/logback.xml --spring.main.banner-mode=off --spring.jpa.properties.hibernate.generate_statistics=true --spring.jpa.properties.hibernate.session_factory.interceptor=probe.u01.DirtyCount"
hj() { local STEPS=$1 url=${2:-} c
  c="cd .harness/run && $L_H${url:+ --tiffinbox.jdbc-url='$url'}"; echo "\$ STEPS=$STEPS; $c"
  bg "$c" .harness/h.log
  [ "$RE" != 142 ] || die "the harness JVM's alarm fired (exit 142, cap 240 - R.247)"
  $G -E 'Found [0-9]+ J[A-Z]+ repository interface|HHH000001|FlywayExecutor : Database: ' .harness/h.log | sed -E 's/^[A-Z]+ +\[[^]]*\] [^ ]+ : //' | mask | sed 's/^/  log: /'
  $G -E '^PROBE ' .harness/h.log | mask
  echo "  exit $RE · its log: ERROR lines $($G -c '^ERROR ' .harness/h.log || true)"
  [ "$RE" = 0 ] || die "the harness JVM exited $RE (STEPS=$STEPS): $($G '^PROBE' .harness/h.log | tail -2 | paste -sd';' -)"; }
PGU() { printf 'jdbc:postgresql://127.0.0.1:20401/%s?user=tiffinbox' "$1"; }
unpub=""
cap() { local nm=$1 i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] || die "$nm left a process running"
    $G -q '^  \*\*\* ' .harness/cap.raw && { cat .harness/cap.raw >&3; die "$nm stopped (above)"; }
    mask < .harness/cap.raw > ".r-$nm.$i"; done
  CH=$(md5 -q ".r-$nm.1")
  [ "$CH" = "$(md5 -q ".r-$nm.2")" ] && [ "$CH" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; }
pub() { local nm=$1 h p; h=$(md5 -q ".r-$nm.out"); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-10s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-10s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-10s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$p"; die "$nm is not the published capture - diff .r-$nm.out against its block in README.md"; fi; }
VALS=""
chk() { local nm=$1 o e=0; shift
  o=$(python3 -I -B harness/chk01.py "$nm" "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk01 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -5 >&3; die "$nm: its check failed (harness/chk01.py)"; }
  VALS="$VALS${VALS:+ · }$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }

# ---- the captures --------------------------------------------------------------------------------------------------------------
data() { echo "-- PostgreSQL 18.6 (the container), a fresh database, the data line before any count:"
  pgdb u01d; hj seed "$(PGU u01d)"
  echo "  psql (a second client, PostgreSQL): $(psq u01d "select (select count(*) from customer) || ' customers · ' || (select count(*) from pause) || ' pauses · ' || (select sum(days) from pause) || ' paused days'")"
  pgdrop u01d; }
context() { local j
  for j in 1 2; do echo "-- PostgreSQL, JVM $j - a fresh database u01c$j, seed then context:"
    pgdb u01c$j; hj seed,context "$(PGU u01c$j)"; $G -E '^PROBE ' .harness/h.log > .harness/ctx-$j.txt; pgdrop u01c$j; done
  echo "the two PostgreSQL JVMs' PROBE lines, diff: $(diff .harness/ctx-1.txt .harness/ctx-2.txt | $G -c '^[<>]' || true) lines differ"
  echo "-- H2, one JVM - H2 in memory (application.yaml's tiffinbox.jdbc-url), seed then context:"
  hj seed,context; }
statements() { echo "-- PostgreSQL - a fresh database u01s, seed then the page three ways:"
  pgdb u01s; hj seed,statements "$(PGU u01s)"; pgdrop u01s
  echo "-- H2 - in memory, seed then the page three ways:"
  hj seed,statements; }
tree1() { local t
  for t in after before; do
    if [ $t = after ]; then echo "-- anchor/ (both modules) - its copy, mvn -o dependency:tree, every module:"; else echo "-- jpa-only/ (Spring Data JPA alone) - its copy, mvn -o dependency:tree, every module:"; fi
    echo "\$ cd .harness/$t && perl -e 'alarm 300; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\" dependency:tree"
    bg "cd .harness/$t && perl -e 'alarm 300; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\" dependency:tree" .harness/tree-$t.log; offl .harness/tree-$t.log
    echo "  exit $RE · $($G -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/tree-$t.log) · offline: yes"
    sed -n -E 's/^\[INFO\] [-+|\\ ]*([a-z.]+:(spring-data-[a-z]+|spring-boot|hibernate-core|flyway-core):jar:[^ ]+)$/  tree: \1/p' .harness/tree-$t.log | sort -u; done
  echo "-- the Spring Data train and the sweep (files on disk, read - never online):"
  BV=$(sed -n -E 's/^\[INFO\] [-+|\\ ]*org\.springframework\.boot:spring-boot:jar:([^:]+):compile$/\1/p' .harness/tree-after.log | head -1)
  [ -n "$BV" ] && [ -f "$M2/org/springframework/boot/spring-boot-dependencies/$BV/spring-boot-dependencies-$BV.pom" ] || die "Boot's BOM for the tree's spring-boot ($BV) is not in .m2-demo"
  echo "  spring-boot-dependencies-$BV.pom: $($G -m1 -oE '<spring-data-bom\.version>[^<]+</spring-data-bom\.version>' "$M2/org/springframework/boot/spring-boot-dependencies/$BV/spring-boot-dependencies-$BV.pom")"
  [ -f "$SW/spring-boot.xml" ] && [ -f "$SW/swept-at.txt" ] || die "the set-up's sweep (spring-data-beyond-jpa/_research/sweep-2026-11-17) is not on this machine"
  echo "  the sweep, spring-boot.xml: $($G -m1 -oE '<release>[^<]+</release>' "$SW/spring-boot.xml") · swept-at.txt: $(cat "$SW/swept-at.txt")"; }
alone() { local mx=0 n i=0 e
  echo "-- alone: a COPY of anchor/ (.harness/alone), never the anchor - Spring Data JPA's starter removed from tiffinbox-web/pom.xml:"
  echo "  removed from tiffinbox-web/pom.xml: $(diff anchor/tiffinbox-web/pom.xml .harness/alone/tiffinbox-web/pom.xml | $G -oE '<artifactId>[^<]+</artifactId>')"
  echo "  the copy's diff against anchor/: $(diff -r -x target -x secrets anchor .harness/alone | $G -c '^[<>]') lines, all in $(diff -rq -x target -x secrets anchor .harness/alone | sed -E 's#^Files anchor/([^ ]+) and .*#\1#' | paste -sd' ' -)"
  echo "\$ cd .harness/alone && perl -e 'alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\" clean package"
  bg "cd .harness/alone && perl -e 'alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\" \"-DargLine=$JL\" clean package" .harness/alone-pkg.log; offl .harness/alone-pkg.log
  echo "  mvn package: exit $RE · $($G -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/alone-pkg.log) · Surefire's Results line: $($G -E '^\[(INFO|WARNING|ERROR)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' .harness/alone-pkg.log | tail -1 | sed -E 's/^\[[A-Z]+\] //')"
  echo "  the IT compiled at test-compile: $( [ -f .harness/alone/tiffinbox-web/target/test-classes/com/tiffinbox/CustomerEntityRepositoryIT.class ] && echo yes || echo no) (tiffinbox-web/target/test-classes/com/tiffinbox/CustomerEntityRepositoryIT.class; mvn package does not run it - verify does, in the container-tests execution)"
  rm -rf .harness/alone-x; mkdir -p .harness/alone-x; (cd .harness/alone-x && unzip -q ../alone/tiffinbox-web/target/tiffinbox-web-1.0.0.jar 'BOOT-INF/lib/*')
  n=$(ls .harness/alone-x/BOOT-INF/lib | wc -l | tr -d ' ')
  echo "  the copy's jar: lib/ $n libraries (anchor/'s $(ls .harness/after/$XD/lib | wc -l | tr -d ' ')) · hibernate-core-*.jar: $(ls .harness/alone-x/BOOT-INF/lib | $G -qE '^hibernate-core-' && echo present || echo absent) · spring-data-jpa-*.jar: $(ls .harness/alone-x/BOOT-INF/lib | $G -qE '^spring-data-jpa-' && echo present || echo absent) · spring-data-jdbc-*.jar: $(ls .harness/alone-x/BOOT-INF/lib | $G -qE '^spring-data-jdbc-' && echo present || echo absent)"
  mkdir -p .harness/alone/secrets/tiffinbox && (umask 077 && cp .harness/run/secrets/tiffinbox/shutdown-token .harness/alone/secrets/tiffinbox/shutdown-token)
  echo "\$ cd .harness/alone && perl -e 'alarm 120; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20402"
  (cd .harness/alone && exec perl -e 'alarm 120; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20402) > .harness/alone-run.log 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 480 ]; do [ "$(listeners 20402)" = 0 ] || mx=1; sleep 0.25; i=$((i + 1)); done
  e=0; wait "$pid" || e=$?; pid=""
  $G -oE 'Found [0-9]+ J[A-Z]+ repository interfaces?' .harness/alone-run.log | sed 's/^/  log: /'
  echo "  java -jar: exit $e · listening on 20402: $mx · 'Application run failed' $($G -c 'Application run failed' .harness/alone-run.log || true)"
  echo "  the cause: $($G -m1 -oE 'Could not configure Spring Data JPA auditing-feature because spring-aspects\.jar is not on the classpath;' .harness/alone-run.log)"; }
exsh() { local sh=$1
  rm -f .harness/ex-*.out .harness/ex-*.st
  case $sh in bash) bg "env -i HOME=\"\$HOME\" PATH=\"\$XPATH\" /bin/bash --noprofile --norc .harness/ex-drive.sh \"\$U\"" .harness/ex-shell.out ;;
              zsh) bg "env -i HOME=\"\$HOME\" PATH=\"\$XPATH\" /bin/zsh -f .harness/ex-drive.sh \"\$U\"" .harness/ex-shell.out ;; esac
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  echo "in $sh - the README's lines (the block's exit $(cat .harness/ex-readme.st)):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "in $sh - the solution's lines (the block's exit $(cat .harness/ex-sol.st)):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out; }
exercise() {
  printf '%s\n' "$SETUP" > .harness/ex-readme.sh; printf '%s\n' "$SOL" > .harness/ex-sol.sh
  printf '%s\n' "$SETUP" | sed 's#^cp exercise/Ex01.java .harness/ex/src/probe/ex/Ex01.java$#sed '"'"'s/jpa.findAllByOrderByNameAsc()/agg.findAll(Sort.by("name"))/'"'"' exercise/Ex01.java > .harness/ex/src/probe/ex/Ex01.java#' > .harness/ex-agg.sh
  [ "$(diff .harness/ex-readme.sh .harness/ex-agg.sh | $G -c '^[<>]')" = 2 ] || die "the other solution's block must be the README's with one line changed"
  printf '%s\n' 'cd "$1" || exit 1' '. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null' 'echo "$?" > "$1/.harness/ex-readme.st"' 'cd "$1" || exit 1' '. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null' 'echo "$?" > "$1/.harness/ex-sol.st"' > .harness/ex-drive.sh
  echo "exercise/README.md's $(printf '%s\n' "$SETUP" | $G -c .) lines, then exercise/SOLUTION.md's, as written, one after the other in ONE env -i shell (HOME and the PATH this script was started with), started in this folder; H2 in memory, no Docker:"
  echo "the solution's line that differs:"; diff .harness/ex-readme.sh .harness/ex-sol.sh | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh
  echo "the other solution, named in SOLUTION.md (read through CustomerAggregates - its line that differs, on a copy):"
  diff .harness/ex-readme.sh .harness/ex-agg.sh | $G '^>' | sed 's/^> /  $ /'
  bg "cd \"\$U\" && env -i HOME=\"\$HOME\" PATH=\"\$XPATH\" /bin/bash --noprofile --norc .harness/ex-agg.sh" .harness/ex-agg.out
  sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-agg.out; }

cap data data; chk data .r-data.out; pub data
cap context context; chk context .r-context.out; pub context
cap statements statements; chk statements .r-statements.out; pub statements
cap tree tree1; chk tree .r-tree.out; pub tree
cap alone alone; chk alone .r-alone.out; pub alone
cap exercise exercise; chk exercise .r-exercise.out "$EXW"; pub exercise
for f in exercise/README.md exercise/SOLUTION.md; do
  w=$(python3 -I -B harness/chk01.py wib .r-exercise.out "$f"); [ "$(wib "$f")" = "$w" ] || die "$f's \"What it prints\" block is not what its lines printed: $(diff <(wib "$f") <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"; done
echo "  exercise: each file's \"What it prints\" block = what its lines printed (bash's; zsh's the same - chk01)"
# R.302: every line of README.md's ```text blocks is a line a run printed; the values line is the captures'
cat .r-*.out .harness/chk-*.out 2> /dev/null | sed -E 's/^ +//' > .harness/printed.txt
TX=$(awk '/^```text$/ { b = 1; next } b && /^```$/ { b = 0; next } b && NF { sub(/^ +/, ""); print }' README.md | while IFS= read -r l; do $G -qxF -- "$l" .harness/printed.txt || printf '%s\n' "$l"; done | head -3 | cut -c1-160 | paste -sd';' -)
[ "$($G -c '^```text$' README.md)" -gt 0 ] && [ -z "$TX" ] || die "R.302: README.md's text blocks must be lines the runs printed - not printed: ${TX:-no text block}"
VS="the values the video may say - $VALS"
printf '%s\n' "$VS" > .harness/values.txt
$G -qxF -- "$VS" README.md || die "README.md does not state the values these captures give (the line is in .harness/values.txt)"
echo "  R.302: README.md's $($G -c '^```text$' README.md) text blocks - every line one the runs printed; the values line = the captures' ($(wc -c < .harness/values.txt | tr -d ' ') bytes)"
# hygiene
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -qE ' (with PID|started by) | in [0-9.]+ seconds|Time elapsed: [0-9]|Total time: +[0-9]|execution time [0-9]|[0-9] ms\b' "$f" || die "R.366: $f holds a time, unmasked"
  ! $G -qE '^ *[0-9]{4}-[0-9]{2}-[0-9]{2}[T ][0-9]' "$f" || die "$f holds a log time"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qiE '[0-9][0-9,]* ?(bytes|KiB)\b|EntityEntryImpl' "$f" || die "R.361: $f holds a heap figure"
  ! $G -E '^ *\$ .*(^|[ (])(java|mvn) ' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM or Maven without its alarm (R.247)"; done
[ -z "$(find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness (R.195)"
TOK=$(head -1 .harness/run/secrets/tiffinbox/shutdown-token)
! cat .r-*.out | $G -qF -- "$TOK" || die "a capture holds the shutdown token"
echo "  hygiene: no path, time, log time, stack frame, heap figure or token in any capture; every JVM and Maven under its alarm; no H2 file outside .harness"
# ---- the end: the container and its volume, the images, the trees, the ports ----------------------------------------------------
pgrm; [ -z "$(dk ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "the container $CN is still there"
VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' '); IMGS1=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -)
[ "$VOL1" = "$VOL0" ] || die "R.322: the volume count moved, $VOL0 -> $VOL1"
[ "$IMGS1" = "$IMGS0" ] || die "the images moved over this run - nothing may be pulled"
echo "  docker at the end: the container removed with its volume (rm -fv); volumes $VOL0 -> $VOL1; images $NI0, the same list (nothing pulled)"
pin anchor-tree anchor end; pin jpa-only-tree jpa-only end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 20400-20409 at the end - the container bound 20401 and is gone; the alone copy stopped before binding 20402; 20400 and 20403-20409 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c8-unit01: every capture 3/3 and = published; every spoken number asserted by chk01.py; the anchor untouched (anchor/ and jpa-only/ = their pins); the volume count unchanged"
