#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 8 · Relationships Without an ORM - this unit's receipts. A harness unit: NO anchor change. anchor/ is a link to
# ../c8-unit02/after (both Spring Data modules, Q imported; pinned by harness/tree03.py against receipts.md5's anchor-tree line).
# Seven captures, each run three times and hashed; a hash that differs from receipts.md5 stops the run; every number the video may
# say is asserted right after its capture by harness/chk03.py against another witness of the same run - psql in this run's
# container, JdbcTemplate (a second client, and its DEBUG log: a second count of the statements), the data line - never against a
# typed figure. The statement witness is unit 02's (datasource-proxy 1.11.1, the harness's alone).
#   reinsert  Sunil's aggregate + one 1-day pause, save(): the statements (witness and log), his pause ids, version and the pause
#             identity before and after (psql on PostgreSQL 18.6; JdbcTemplate on H2 in memory)
#   same      Sunil's aggregate saved unchanged, then Ravi's (no pauses): the statements, the ids and versions before and after
#   load      findById, findAll(), findAll(Sort.by("name")), findAllById - single-query loading off (the anchor's), then on (the
#             harness's SingleQuery, -Du03.sq=true, never the anchor) - PostgreSQL and H2, one window per method
#   noid      a COPY of anchor/ with @MappedCollection and no idColumn: findAll() on H2 and PostgreSQL (the error texts), and
#             anchor/'s own read on each, beside it
#   ref       AggregateReference<CustomerRow, Long> on a sketch class (harness/src, PauseRef): a read and an insert, read back
#   seven     the comparison set on anchor/'s jar (java -jar, H2 in memory, port 20420): its md5 = Course 7's 466c20ed...
#   exercise  exercise/README.md's lines, then SOLUTION.md's, as written, in ONE env -i shell - bash, then zsh -f
# Every tree is COPIED under .harness/ and built there, offline. Every JVM and every Maven run runs under an alarm (perl -e
# 'alarm N; exec ...'; R.247). Every docker call names its socket (docker -H "$DH"); the container is removed with its volume
# (rm -fv) and the volume count is asserted unchanged. Ports (20420-20429): 20420 TiffinBox for the seven only · 20421 this run's
# PostgreSQL container · 20422 (the noid copy) and 20423 (single-query loading) never bound - the harness runs with no web server ·
# 20424-20429 spare, never bound. Nothing leaves the machine.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c8u03-pg
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
for t in python3 perl rsync lsof mvn md5 cmp diff find openssl docker git curl /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PG[A-Z]*|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"

# ---- gates before anything is written: the folder, the link, the pin, the prose, the static checks -----------------------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md anchor exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk03.py dur8.py logback.xml s803.py src tree03.py' ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe/u03/PauseRef.java probe/u03/SingleQuery.java probe/u03/U3.java probe/u03/Witness.java' ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'Ex03.java README.md SOLUTION.md' ] || die "exercise/ holds another file, or misses one"
cmp -s harness/dur8.py ../c8-unit02/harness/dur8.py || die "harness/dur8.py is not the builders' dur8.py as unit 02 shipped it, byte for byte"
[ "$(diff ../c8-unit02/harness/src/probe/u02/Witness.java harness/src/probe/u03/Witness.java | $G -c '^[<>]')" = 2 ] && diff ../c8-unit02/harness/src/probe/u02/Witness.java harness/src/probe/u03/Witness.java | $G -qx '> package probe.u03;' || die "R.357: harness/src/probe/u03/Witness.java must be unit 02's witness with its package line alone changed"
[ -L anchor ] && [ "$(readlink anchor)" = ../c8-unit02/after ] || die "anchor must be a link to ../c8-unit02/after (it points at: $(readlink anchor 2> /dev/null || echo 'not a link'))"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree03.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/ ($3): python3 -I harness/tree03.py $dir/ -> files and md5 = receipts.md5's $nm line"; }
pin anchor-tree anchor start
CR=tiffinbox-core/src/main/java/com/tiffinbox/jdbc/CustomerRow.java
[ "$($G -cxF '    @MappedCollection(idColumn = "customer_id")' "anchor/$CR")" = 1 ] || die "anchor/$CR must hold the one line the noid copy edits: @MappedCollection(idColumn = \"customer_id\")"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s803.py harness/dur8.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -2 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|naan|sabzi|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|raita|korma|tikka|masala|samosa|pakora|halwa|kheer|jalebi|ladoo|vada|bhaji|aloo|gobi|jain'
DN=$($G -rniwE -- "$DISH" README.md exercise harness 2> /dev/null | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
PH=$($G -nE 'PLACEHOLDER|VALUES-PENDING|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose: $PH"
$G -qF 'Aggregates, Not Entities' README.md || die "R.68: README.md calls unit 02 back by its title (the aggregate's gloss is unit 02's)"
$G -qF '@OneToMany/@ManyToOne and the Owning Side' README.md || die "R.224: README.md calls Course 7's owning side back by its title"
# the exercise's shape: one spoken line, two blocks one line apart, each with its alarm
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
EXQ="Your turn: saving Sunil unchanged still deletes his pauses. Make the test print the statement count, then explain each statement in the log."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SETUP=$(block exercise/README.md); SOL=$(block exercise/SOLUTION.md)
[ -n "$SETUP" ] && [ -n "$SOL" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
[ "$(diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G -c '^[<>]')" = 2 ] || die "R.196: SOLUTION.md's block must be the README's with one line changed (it is $(diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G -c '^[<>]') lines apart)"
printf '%s\n' "$SETUP" | $G -E '(^|[ (])(mvn|java) ' | $G -vqF "perl -e 'alarm " && die "exercise/README.md's Java runs must run under their alarm (R.247)"
! printf '%s\n' "$SETUP" | $G -q 'DOCKER_HOST\|docker ' || die "the exercise needs no Docker: its block names DOCKER_HOST or docker"
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
# static: the docker socket, the container's volume, no sleep in the harness, the witness the harness's alone, the flag the harness's alone
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket (docker -H \"\$DH\")"
DK=$($G -v '^ *#' receipts.sh | $G -nE '\bdocker (run|exec|rm|ps|port|info|images|volume|image|pull|events)\b' | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.344: receipts.sh calls docker without the pinned socket (every call is dk): $DK"
! $G -v '^ *#' receipts.sh | $G -qE 'rm -f'' "?\$CN|rm -f'' c8u03' || die "R.322: receipts.sh removes a container without its volume (rm -fv)"
$G -q 'dk rm -fv "$CN"' receipts.sh || die "R.322: the container is removed with its volume (dk rm -fv)"
! $G -rqE 'Thread\.sleep|while *\(true\)|TimeUnit\.[A-Z]+\.sleep|jcmd|GC\.class_histogram' harness/src exercise/Ex03.java || die "a harness class sleeps, polls or attaches jcmd"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
! $G -rq 'datasource-proxy\|ttddyy' anchor/pom.xml anchor/tiffinbox-core anchor/tiffinbox-web || die "R.357: the witness is named in the anchor - it is the harness's alone"
! $G -rq 'setSingleQueryLoadingEnabled' anchor/tiffinbox-core anchor/tiffinbox-web || die "S8.26: the anchor switches single-query loading on - it is the harness's alone (SingleQuery)"
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
CURLSET=../c5-unit11/curlset.sh
[ -x "$CURLSET" ] || die "$CURLSET is missing - the comparison set the seven runs"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
echo "  gates before any write: the folder's files; dur8.py = unit 02's; the witness = unit 02's but its package line (R.357); the link anchor -> ../c8-unit02/after; the one line the noid copy edits, present once"
echo "  prose, per sentence (s803, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test): refused 0 over $PROSE · dish names 0 · unit 02 and Course 7's owning side called back by title"
echo "  the exercise: the spoken line $EXW words; SOLUTION.md's block = the README's with one line changed; the two \"What it prints\" blocks differ (R.196); no Docker"
echo "  static: every docker call on the pinned socket; the container removed with its volume; no sleep, poll or jcmd in the harness; the witness and single-query loading absent from the anchor; the mask's self-test refused the planted Started-in-seconds line (R.366)"

# ---- docker and ports: the baselines ---------------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that socket? (R.344)"
IMGS0=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -); NI0=$(printf '%s\n' "$IMGS0" | wc -w | tr -d ' ')
VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI0" -ge 1 ] && [ "$VOL0" -ge 1 ] || die "the baselines must not be empty - images $NI0, volumes $VOL0"
dk image inspect "$IMG" > /dev/null 2>&1 || die "the image $IMG is not on this machine - this script never pulls"
[ -z "$(dk ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "a container named $CN exists - an interrupted run's? remove it with its volume (docker -H \"\$DH\" rm -fv $CN)"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 20420 20421 20422 20423 20424 20425 20426 20427 20428 20429"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · the image $IMG present (never pulled) · ports 20420-20429 (and 18425, 8080) free"

# ---- the trees, copied; the builds; the harness --------------------------------------------------------------------------------
rm -rf .harness; mkdir -p .harness/run/secrets/tiffinbox .harness/hc
M2="$PWD/.m2-demo"
DSP="$M2/net/ttddyy/datasource-proxy/1.11.1/datasource-proxy-1.11.1.jar"   # the statement witness, the harness's alone
[ -d "$M2" ] && [ -e "$DSP" ] || die ".m2-demo (a copy of the course's seed, _research/m2-seed-c8-s1) or datasource-proxy 1.11.1 in it is missing - README.md, The repository"
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c8-tiffinbox 2>&1 || true)
echo "  anchor/ against ../c8-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures anchor/')"
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy anchor .harness/after; copy anchor .harness/noid
# the noid copy: ONE named edit - idColumn removed from @MappedCollection, nothing else
perl -pi -e 's/^    \@MappedCollection\(idColumn = "customer_id"\)$/    \@MappedCollection/' ".harness/noid/$CR"
ND=$(diff -r -x target -x secrets anchor .harness/noid || true)
[ "$(printf '%s\n' "$ND" | $G -c '^[<>]')" = 2 ] && [ "$(diff -rq -x target -x secrets anchor .harness/noid | wc -l | tr -d ' ')" = 1 ] || die "the noid copy must differ from anchor/ by its one edited line: $(printf '%s\n' "$ND" | head -4 | paste -sd';' -)"
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & pid=$!; wait "$pid" || RE=$?; pid=""; }
offl() { [ "$($G -cE '^\[INFO\] Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
for t in after noid; do
  bg "cd .harness/$t && perl -e 'alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\" clean package -DskipTests" .harness/build-$t.log
  [ "$RE" = 0 ] || { tail -20 .harness/build-$t.log >&3; die "the $t copy did not build offline (exit $RE)"; }; offl .harness/build-$t.log
  bg "cd .harness/$t && perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$t.log
  [ "$RE" = 0 ] || die "the $t jar's extract failed"; done
DRV=$(ls .harness/after/$XD/lib | $G -E '^postgresql-.*\.jar$' || true)
[ -n "$DRV" ] || die "the anchor's jar holds no PostgreSQL driver"
bg "javac -parameters -d .harness/hc -cp \".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*:\$DSP\" harness/src/probe/u03/*.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/run/secrets/tiffinbox/shutdown-token) || die "the token was not written"
mkdir -p .harness/after/secrets/tiffinbox && (umask 077 && cp .harness/run/secrets/tiffinbox/shutdown-token .harness/after/secrets/tiffinbox/shutdown-token)
echo "  built anchor/'s copy and the noid copy offline (mvn -o package -DskipTests, exit 0 each, 'Downloaded from' 0); extracted both jars ($(ls .harness/after/$XD/lib | wc -l | tr -d ' ') libraries each side; the driver $DRV); the harness compiled ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes) against anchor/'s jar and the witness; a shutdown token generated (0600, never printed)"
# the container: PostgreSQL 18 from the pinned image, loopback only, trust on loopback (compose.yaml's own choice; no password anywhere)
CSTARTED=1
bg "dk run -d --pull never --name $CN -p 127.0.0.1:20421:5432 -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust $IMG" .harness/docker-run.log
[ "$RE" = 0 ] || die "the container did not start: $(tail -2 .harness/docker-run.log)"
i=0; while ! dk exec "$CN" pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 120 ] || die "the container did not accept connections (120 tries)"; sleep 0.5; done
DP=$(dk port "$CN" 2> /dev/null | paste -sd'|' -)
[ "$DP" = '5432/tcp -> 127.0.0.1:20421' ] || die "the container must publish 5432 on 127.0.0.1:20421 alone: $DP"
echo "  the container: $CN from $IMG (--pull never), published $DP, user tiffinbox, trust on loopback; pg_isready (cap 120 tries)"

# ---- helpers -------------------------------------------------------------------------------------------------------------------
psq() { dk exec "$CN" psql -U tiffinbox -d "$1" -qAt -v ON_ERROR_STOP=1 -c "$2" 2>&1 || die "psql failed on $1: $2"; }
pgdb() { psq postgres "drop database if exists $1 with (force)" > /dev/null; psq postgres "create database $1" > /dev/null; echo "  a fresh database: $1 (psql)"; }
pgdrop() { psq postgres "drop database $1 with (force)" > /dev/null; echo "  dropped: $1"; }
DLQ="select (select count(*) from customer) || ' customers · ' || (select count(*) from pause) || ' pauses · ' || (select sum(days) from pause) || ' paused days'"
rowq() { printf "select '%s pauses ' || coalesce((select string_agg(p.id || ':' || p.days, ' ' order by p.id) from pause p join customer c on c.id = p.customer_id where c.name = '%s'), '(none)') || ' · version ' || (select version from customer where name = '%s')" "$1" "$1" "$1"; }
SEQQ="select 'pause identity (pg_sequences, pause_id_seq) last_value ' || coalesce(last_value::text, 'null') from pg_sequences where sequencename = 'pause_id_seq'"
L_H="perl -e 'alarm 240; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 \$HSQ -cp \"../hc:../\$HT/$XD/tiffinbox-web-1.0.0.jar:../\$HT/$XD/lib/*:\$DSP\" probe.u03.U3 \$STEPS --logging.config=../../harness/logback.xml --spring.main.banner-mode=off"
HT=after; HX=0; HSQ=""
# hj STEPS [URL]: one harness JVM over the jar of .harness/$HT (anchor/'s copy, or the noid copy), its exit asserted = $HX
hj() { local STEPS=$1 url=${2:-} c
  c="cd .harness/run && $L_H${url:+ --tiffinbox.jdbc-url='$url'}"; echo "\$ HT=$HT; HSQ=${HSQ:-(none)}; STEPS=$STEPS; $c"
  bg "$c" .harness/h.log
  [ "$RE" != 142 ] || die "the harness JVM's alarm fired (exit 142, cap 240 - R.247)"
  $G -E 'Found [0-9]+ J[A-Z]+ repository interface|HHH000001|FlywayExecutor : Database: ' .harness/h.log | sed -E 's/^[A-Z]+ +\[[^]]*\] [^ ]+ : //' | mask | sed 's/^/  log: /'
  $G -E '^PROBE ' .harness/h.log | mask
  echo "  exit $RE · its log: ERROR lines $($G -c '^ERROR ' .harness/h.log || true)"
  [ "$RE" = "$HX" ] || die "the harness JVM exited $RE, not $HX (HT=$HT STEPS=$STEPS): $($G '^PROBE' .harness/h.log | tail -2 | paste -sd';' -)"; }
# logsql LABEL DB: JdbcTemplate's DEBUG lines inside one labelled window of the last JVM's log - counted, sorted (count, never order)
logsql() { local w
  w=$(awk -v o="PROBE window $1 open" '$0 == o { f = 1; next } f && /^PROBE window .* close$/ { exit } f && / org\.springframework\.jdbc\.core\.JdbcTemplate : Executing (prepared SQL statement|SQL batch update) \[/ { sub(/^.* org\.springframework\.jdbc\.core\.JdbcTemplate : /, ""); print }' .harness/h.log)
  echo "  log $1 ($2, JdbcTemplate DEBUG): 'Executing prepared SQL statement' $(printf '%s\n' "$w" | $G -c '^Executing prepared SQL statement' || true) · 'Executing SQL batch update' $(printf '%s\n' "$w" | $G -c '^Executing SQL batch update' || true)"
  [ -z "$w" ] || printf '%s\n' "$w" | sort | uniq -c | sed -E 's/^ *([0-9]+) /  log '"$1"' x\1: /'; }
PGU() { printf 'jdbc:postgresql://127.0.0.1:20421/%s?user=tiffinbox' "$1"; }
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
  o=$(python3 -I -B harness/chk03.py "$nm" "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk03 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -5 >&3; die "$nm: its check failed (harness/chk03.py)"; }
  VALS="$VALS${VALS:+ · }$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }

# ---- the captures --------------------------------------------------------------------------------------------------------------
reinsert() { echo "-- PostgreSQL 18.6 (the container), a fresh database u03r: the data line, then Sunil's save with one pause added:"
  pgdb u03r; hj seed "$(PGU u03r)"
  echo "  psql (a second client, PostgreSQL): $(psq u03r "$DLQ")"
  echo "  psql before (a second client, PostgreSQL): $(psq u03r "$(rowq Sunil)") · $(psq u03r "$SEQQ")"
  hj reinsert "$(PGU u03r)"; logsql reinsert PostgreSQL
  echo "  psql after (a second client, PostgreSQL): $(psq u03r "$(rowq Sunil)") · $(psq u03r "$SEQQ")"
  pgdrop u03r
  echo "-- H2 in memory, one JVM (JdbcTemplate the second client): the data line, then the same save:"
  hj seed,ids,reinsert,ids; logsql reinsert H2; }
same() { echo "-- PostgreSQL 18.6, a fresh database u03m: the data line, then Sunil saved unchanged, then Ravi (no pauses) saved unchanged:"
  pgdb u03m; hj seed "$(PGU u03m)"
  echo "  psql (a second client, PostgreSQL): $(psq u03m "$DLQ")"
  echo "  psql before (a second client, PostgreSQL): $(psq u03m "$(rowq Sunil)") · $(psq u03m "$(rowq Ravi)") · $(psq u03m "$SEQQ")"
  hj same "$(PGU u03m)"; logsql 'same Sunil' PostgreSQL; logsql 'same Ravi' PostgreSQL
  echo "  psql after (a second client, PostgreSQL): $(psq u03m "$(rowq Sunil)") · $(psq u03m "$(rowq Ravi)") · $(psq u03m "$SEQQ")"
  pgdrop u03m
  echo "-- H2 in memory, one JVM (JdbcTemplate the second client): the data line, then the same two saves:"
  hj seed,ids,same,ids; logsql 'same Sunil' H2; logsql 'same Ravi' H2; }
loadw() { local w; for w in 'load findById' 'load findAll()' 'load findAll(Sort)' 'load findAllById'; do logsql "$w" "$1"; done; }
load() { echo "-- PostgreSQL 18.6, a fresh database u03l, single-query loading off (anchor/ as it is): the data line, then four reads:"
  pgdb u03l; hj seed,load "$(PGU u03l)"; loadw PostgreSQL
  echo "  psql (a second client, PostgreSQL): $(psq u03l "$DLQ")"
  echo "-- PostgreSQL, the same database, a second JVM - single-query loading on (-Du03.sq=true: the harness's SingleQuery, never the anchor):"
  HSQ=-Du03.sq=true; hj load "$(PGU u03l)"; HSQ=""; loadw PostgreSQL; pgdrop u03l
  echo "-- H2 in memory, single-query loading off: the data line, then four reads:"
  hj seed,load; loadw H2
  echo "-- H2 in memory, a second JVM - single-query loading on (-Du03.sq=true):"
  HSQ=-Du03.sq=true; hj seed,load; HSQ=""; loadw H2; }
noid() { echo "-- noid: a COPY of anchor/ (.harness/noid), never the anchor - one line edited (diff -r anchor .harness/noid):"
  printf '%s\n' "$ND" | $G '^[<>]' | sed 's/^/  /'
  echo "-- H2 in memory, the noid copy's jar: the data line, then findAll():"
  HT=noid; HX=1; hj seed,read; HT=after; HX=0; logsql 'read findAll()' H2
  echo "-- H2 in memory, anchor/'s jar (idColumn = \"customer_id\"): the data line, then findAll():"
  hj seed,read
  echo "-- PostgreSQL 18.6, a fresh database u03n, the noid copy's jar: the data line, then findAll():"
  pgdb u03n; HT=noid; HX=1; hj seed,read "$(PGU u03n)"; HT=after; HX=0; logsql 'read findAll()' PostgreSQL
  echo "-- PostgreSQL, the same database, anchor/'s jar:"
  hj read "$(PGU u03n)"; pgdrop u03n; }
ref() { echo "-- H2 in memory, one JVM - PauseRef, a sketch class in harness/src (never the anchor): its customer held as AggregateReference<CustomerRow, Long>:"
  hj seed,ref
  echo "-- PostgreSQL 18.6, a fresh database u03f, one JVM - the same:"
  pgdb u03f; hj seed,ref "$(PGU u03f)"
  echo "  psql (a second client, PostgreSQL): the newest pause row: $(psq u03f "select c.name || ' · days ' || p.days || ' · customer_id = Ravi''s id: ' || case when p.customer_id = (select id from customer where name = 'Ravi') then 'yes' else 'no' end from pause p join customer c on c.id = p.customer_id where p.id = (select max(id) from pause)")"
  pgdrop u03f; }
seven() { local i=0 e=0 a=""
  echo "-- the seven: anchor/'s jar (.harness/after), java -jar, H2 in memory (a fresh JVM), port 20420:"
  echo "\$ cd .harness/after && perl -e 'alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20420"
  (cd .harness/after && exec perl -e 'alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20420) > .harness/seven-run.log 2>&1 < /dev/null & pid=$!
  while [ $i -lt 480 ]; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:20420/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/seven-run.log | mask >&3; die "TiffinBox exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on 20420"
  a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
  echo "  GET /actuator/health/readiness -> 200 · listens on: $a"
  echo "\$ \$CURLSET 20420 .harness/after/secrets/tiffinbox/shutdown-token"
  "$CURLSET" 20420 .harness/after/secrets/tiffinbox/shutdown-token | $G ' -> ' | awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' > .harness/seven.txt || true
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 480 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && die "TiffinBox on 20420 was still running after POST /shutdown"
  wait "$pid" || e=$?; pid=""
  [ "$(listeners 20420)" = 0 ] || die "something still listens on 20420"
  echo "  exit $e · the seven responses: $(wc -l < .harness/seven.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven.txt) · listening on 20420 now: 0"
  ! $G -qF -- "$(head -1 .harness/run/secrets/tiffinbox/shutdown-token)" .harness/seven-run.log || die "TiffinBox's log held the token"
  echo "  its log: the token 0 times"; }
exsh() { local sh=$1
  rm -f .harness/ex-*.out .harness/ex-*.st
  case $sh in bash) bg "env -i HOME=\"\$HOME\" PATH=\"\$XPATH\" /bin/bash --noprofile --norc .harness/ex-drive.sh \"\$U\"" .harness/ex-shell.out ;;
              zsh) bg "env -i HOME=\"\$HOME\" PATH=\"\$XPATH\" /bin/zsh -f .harness/ex-drive.sh \"\$U\"" .harness/ex-shell.out ;; esac
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  echo "in $sh - the README's lines (the block's exit $(cat .harness/ex-readme.st)):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "in $sh - the solution's lines (the block's exit $(cat .harness/ex-sol.st)):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out; }
exercise() {
  printf '%s\n' "$SETUP" > .harness/ex-readme.sh; printf '%s\n' "$SOL" > .harness/ex-sol.sh
  printf '%s\n' 'cd "$1" || exit 1' '. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null' 'echo "$?" > "$1/.harness/ex-readme.st"' 'cd "$1" || exit 1' '. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null' 'echo "$?" > "$1/.harness/ex-sol.st"' > .harness/ex-drive.sh
  echo "exercise/README.md's $(printf '%s\n' "$SETUP" | $G -c .) lines, then exercise/SOLUTION.md's, as written, one after the other in ONE env -i shell (HOME and the PATH this script was started with), started in this folder; H2 in memory, no Docker:"
  echo "the solution's line that differs:"; diff .harness/ex-readme.sh .harness/ex-sol.sh | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh; }

cap reinsert reinsert; chk reinsert .r-reinsert.out; pub reinsert
cap same same; chk same .r-same.out; pub same
cap load load; chk load .r-load.out; pub load
cap noid noid; chk noid .r-noid.out; pub noid
cap ref ref; chk ref .r-ref.out; pub ref
cap seven seven; chk seven .r-seven.out "$S466"; pub seven
cap exercise exercise; chk exercise .r-exercise.out "$EXW" .r-same.out; pub exercise
for f in exercise/README.md exercise/SOLUTION.md; do
  w=$(python3 -I -B harness/chk03.py wib .r-exercise.out "$f"); [ "$(wib "$f")" = "$w" ] || die "$f's \"What it prints\" block is not what its lines printed: $(diff <(wib "$f") <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"; done
echo "  exercise: each file's \"What it prints\" block = what its lines printed (bash's; zsh's the same - chk03)"
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
  ! $G -E '^ *\$ .*(^|[ (])(java|mvn) ' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM or Maven without its alarm (R.247)"; done
[ -z "$(find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness (R.195)"
TOK=$(head -1 .harness/run/secrets/tiffinbox/shutdown-token)
! cat .r-*.out | $G -qF -- "$TOK" || die "a capture holds the shutdown token"
echo "  hygiene: no path, time, log time, stack frame or token in any capture; every JVM and Maven under its alarm; no H2 file outside .harness"
# ---- the end: the container and its volume, the images, the tree, the ports ----------------------------------------------------
pgrm; [ -z "$(dk ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "the container $CN is still there"
VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' '); IMGS1=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -)
[ "$VOL1" = "$VOL0" ] || die "R.322: the volume count moved, $VOL0 -> $VOL1"
[ "$IMGS1" = "$IMGS0" ] || die "the images moved over this run - nothing may be pulled"
echo "  docker at the end: the container removed with its volume (rm -fv); volumes $VOL0 -> $VOL1; images $NI0, the same list (nothing pulled)"
pin anchor-tree anchor end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 20420-20429 at the end - the container bound 20421 and is gone; TiffinBox bound 20420 for the seven and stopped; 20422-20429 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c8-unit03: every capture 3/3 and = published; every spoken number asserted by chk03.py; the anchor untouched (anchor/ = its pin); the volume count unchanged"
