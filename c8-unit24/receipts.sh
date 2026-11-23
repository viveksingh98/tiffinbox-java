#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 8 · Polyglot Persistence in One App - this unit's receipts. Section 4 Part B's last unit: before/ is a link to
# ../c8-unit23/after (unit 23's tree, which is unit 22's), after/ is this unit's tree, and ../c8-tiffinbox equals it from this unit's
# commit on. The change is the anchor's README ONLY (the unit 24 card: which manager each shipped write runs under, and the hand-off
# sentence) - no line of src/main, no test, no compose.yaml; the jar after/ builds is the jar before/ builds, byte for byte.
# The two transaction managers are the HARNESS's (probe.u24.H24, every line it prints says "the harness's"), on the harness's own
# stores: a single-node MongoDB replica set (c8u24-mongo-rs, 127.0.0.1:20635, initiated through the driver, one seed, no replicaSet=)
# and a PostgreSQL (c8u24-pg-h, 127.0.0.1:20636, the anchor's V1-V4 migrations applied by the harness JVM's Boot start).
# Two witnesses for every count: the harness's Java counts (JdbcTemplate's count(*) and MongoTemplate's count, by name, after the
# method returned) and the stores' own tools after the JVM is gone - psql in the PostgreSQL container, and mongosh in a container with
# NO network (--network none --volumes-from the replica set, its unix socket).
# Captures (the JVM ones run three times and hashed; exercise and footprint once per run of record - their 3/3 is across the runs):
#   exercise   exercise/README.md's lines, then SOLUTION.md's, as written, in ONE env -i shell - bash, then zsh -f; then the rename
#              "solution" three times through exercise/check.sh (it must fail the check each time)
#   jars       javap -v of JpaBaseConfiguration.transactionManager (spring-boot-jpa-4.1.2.jar), ChainedTransactionManager in
#              spring-data-commons-4.1.2.jar (its size, Deprecated)
#   handoff    the hand-off sentence in after/README.md and ../c8-tiffinbox/README.md, its md5; the roadmap's lines; the ledger row C8-20
#   mtm        the harness, profile mtm: Mongo's manager alone - the bean list, the plain @Transactional call refused, rows 0 / documents 0
#   mtmnamed   the harness, profile mtmnamed: the same bean named transactionManager - the plain call, no plant: rows 0 / documents 1,
#              no exception; with the plant: 0 / 0
#   both       the harness, profile both: the bean list, each manager's class, each method's @Transactional value
#   dual       the harness, profile both: eight methods, each planted and its control; psql and mongosh by name
#   scoped     the harness, profile both: the document by an AFTER_COMMIT listener calling the Mongo-managed bean; planted and control
#   sockets    the replica set container's sockets, read at the end of the harness window (S8.92)
#   footprint  ONE Compose window on the shipped compose.yaml + after/ under dev on 20630: docker stats once (the reading is masked in
#              the capture and printed in this log), the VM's total, TiffinBox's RSS
#   default    after/ with no profile on H2, no Docker: 200, 404s, 0 Elasticsearch and 0 MongoDB lines; the two jars' md5
#   seven      the comparison set on before/'s and after/'s jars (H2; after/ on 20630, before/ on 20637)
# Every tree is COPIED under .harness/ and built there, offline (-o, from .m2-demo, a copy of the course's seed, maven.repo.local
# absolute), -pl tiffinbox-web -am (R.391). Every JVM and Maven run under an alarm (R.247), every JVM with SIGINT reset to its default
# (R.410). Every docker call names its socket (dk, R.344), --pull never; every container is removed with its volumes (rm -fv, R.387) and
# the volume count asserted back.
# Ports (20630-20639): 20630 TiffinBox after/ (default, seven, footprint) · 20635 the harness's replica set (and the exercise's) · 20636
# the harness's PostgreSQL (and the exercise's) · 20637 TiffinBox before/ for the seven · 20631-20634, 20638, 20639 spare (asserted
# free: this unit's dev stores are Compose's, 18881-18884, during footprint only).
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
MR=c8u24-mongo-rs; HN=c8u24-pg-h; XR=c8u24-ex-rs; XP=c8u24-ex-pg; PROJ=tiffinbox-dev
HANDOFF='Course 13, Messaging and Integration, comes back to this dual write with an outbox, in its section on patterns that matter.'
HMD5=a6581dab7e33c458146b1f0e9cb114bc
# the roadmap and the promise ledger handoff reads: beside this repository on the author's Mac (a sealed clone elsewhere reads the
# author's copies there - point LPW at yours)
LPW="$(cd ../../.. 2> /dev/null && pwd)"; [ -f "$LPW/_briefs/TRACK-ROADMAP.md" ] || LPW="$HOME/Downloads/Youtube Content/LearnProgrammingWithVivek"
ROADMAP="$LPW/_briefs/TRACK-ROADMAP.md"
LEDGER="$LPW/spring-data-beyond-jpa/_briefs/PROMISE-LEDGER-2026-11-17.md"
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
pid=""; mpid=""; xpid=""; CMPW=""; CMPV=""; TC0=""; INTR=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.u24.") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "Lab24") || index($0, "curlset.sh") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || $3 ~ /(^|\/)javac$/ || index($0, "ex-drive.sh")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
# the Compose window's own cleanup: the project's containers and network down with their volumes, and the mongo service's two
# anonymous volumes by the names its container listed (a down -v after a down does not remove them - unit 18 measured it)
cmprm() { local v
  [ -n "$TC0" ] || return 0
  if [ -n "$(dk ps -aq --filter name=^/${PROJ}-mongo-1\$ 2> /dev/null)" ]; then CMPV="$CMPV $(dk inspect -f '{{range .Mounts}}{{.Name}} {{end}}' ${PROJ}-mongo-1 2> /dev/null)"; fi
  if [ -n "$CMPW" ] || [ -n "$(dk ps -aq --filter label=com.docker.compose.project=$PROJ 2> /dev/null)" ] || dk network inspect ${PROJ}_default > /dev/null 2>&1; then
    (cd .harness/compose-run 2> /dev/null && dk compose -p $PROJ down -v > /dev/null 2>&1) || true; fi
  for v in $CMPV; do dk volume inspect "$v" > /dev/null 2>&1 && dk volume rm "$v" > /dev/null 2>&1; done
  CMPW=""; CMPV=""; return 0; }
ctrm() { local c; [ -n "$TC0" ] || return 0
  for c in $XR $XP $MR $HN; do [ -z "$(dk ps -aq --filter name=^/$c\$ 2> /dev/null)" ] || dk rm -fv "$c" > /dev/null 2>&1 || true; done
  for c in $(dk ps -aq --filter label=c8u24.ms=1 2> /dev/null) $(dk ps -aq --filter label=c8u24.ex=1 2> /dev/null); do dk rm -fv "$c" > /dev/null 2>&1 || true; done; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid" "$pid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; cmprm; ctrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git unzip javap /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|FLYWAY_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|REDIS[A-Z_]*|MONGO[A-Z_]*|ES_[A-Z_]*|ELASTIC[A-Z_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT|COMPOSE_[A-Z_]*)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"

# ---- gates before anything is written: the folder, the links, the pins, the prose, the change, the hand-off -----------------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk24.py dur8.py logback.xml s824.py src tree24.py' ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe/u24/H24.java' ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'Lab24.java README.md SOLUTION.md check.sh' ] || die "exercise/ holds another file, or misses one"
cmp -s harness/dur8.py ../c8-unit02/harness/dur8.py || die "harness/dur8.py is not the builders' dur8.py as unit 02 shipped it, byte for byte"
cmp -s harness/logback.xml ../c8-unit07/harness/logback.xml || die "harness/logback.xml is not unit 07's, byte for byte"
[ -L before ] && [ "$(readlink before)" = ../c8-unit23/after ] || die "R.211: before must be a link to ../c8-unit23/after (it points at: $(readlink before 2> /dev/null || echo 'not a link'))"
[ -L ../c8-unit23/after ] && [ "$(readlink ../c8-unit23/after)" = ../c8-unit22/after ] || die "unit 23's after must be its link to ../c8-unit22/after"
[ -d after ] && [ ! -L after ] || die "after/ must be this unit's own tree, not a link"
for t in after before; do [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] && die "$t holds a secrets/ or a target/ - never built in place"; true; done
git rev-parse -q --verify '44ae1b0^{commit}' > /dev/null 2>&1 || die "unit 23's commit 44ae1b0 is not in this repository's history"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree24.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/ ($3): python3 -I harness/tree24.py $dir/ -> $got = receipts.md5's $nm line"; }
pin before-tree before start; pin after-tree after start
U22P=$(awk '$1 == "after-tree" { print $2, $3 }' ../c8-unit22/receipts.md5); U23P=$(awk '$1 == "after-tree" { print $2, $3 }' ../c8-unit23/receipts.md5)
[ "$U22P" = "$U23P" ] && [ "$U23P" = "$(awk '$1 == "before-tree" { print $2, $3 }' receipts.md5)" ] || die "before/'s pin is not unit 23's after-tree line ($U23P) = unit 22's ($U22P)"
echo "  before/'s pin = ../c8-unit23/receipts.md5's after-tree line = ../c8-unit22/receipts.md5's ($U23P), re-derived by harness/tree24.py (before -> ../c8-unit23/after -> ../c8-unit22/after)"
[ "$(awk '$1 == "before-tree" { print $2 }' receipts.md5)" = "$(awk '$1 == "after-tree" { print $2 }' receipts.md5)" ] && [ "$(awk '$1 == "before-tree" { print $3 }' receipts.md5)" != "$(awk '$1 == "after-tree" { print $3 }' receipts.md5)" ] || die "before-tree and after-tree must hold the same file count and different hashes (the README differs)"
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c8-tiffinbox 2>&1 || true)
echo "  after/ against ../c8-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor' || echo 'they differ - the anchor is not this unit'"'"'s after/ (before the commit, or a later unit moved it); this unit measures after/')"
CH=$(diff -rq before/ after/ 2>&1 | sed -E 's#^Files before/(.*) and after/.* differ$#changed: \1#; s#^Only in after/(.*): (.*)$#new: \1/\2#; s#^Only in before/(.*): (.*)$#gone: \1/\2#' | sort | paste -sd'|' -)
[ "$CH" = 'changed: README.md' ] || die "flag 11: after/ differs from before/ in README.md alone - diff -rq says: $CH"
echo "  after/ against before/ (diff -rq): $CH - the one path (flag 11: no src/main, no test, no compose.yaml)"
for f in after/README.md ../c8-tiffinbox/README.md; do
  [ "$($G -cxF -- "$HANDOFF" "$f")" = 1 ] || [ "$f" = ../c8-tiffinbox/README.md ] || die "S8.89: $f must hold the hand-off sentence as a line of its own, once"; done
[ "$(printf '%s' "$HANDOFF" | md5 -q)" = $HMD5 ] || die "S8.89: the hand-off sentence's md5 is not $HMD5"
[ "$($G -xF -- "$HANDOFF" after/README.md | tr -d '\n' | md5 -q)" = $HMD5 ] || die "S8.89: after/README.md's hand-off line is not byte-equal to the pinned sentence"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s824.py harness/dur8.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -2 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
diff before/README.md after/README.md | $G '^>' | sed 's/^> //' > .harness-card.tmp || true
CW=$(python3 -I -B harness/s824.py harness/dur8.py .harness-card.tmp) || { rm -f .harness-card.tmp; die "the card's prose gate did not run"; }
rm -f .harness-card.tmp
printf '%s\n' "$CW" | tail -1 | $G -qE 'refused: 0$' || die "a refused word or reading in the lines the card added to the anchor's README: $(printf '%s\n' "$CW" | $G ' line ' | head -3 | paste -sd';' -)"
YD=$(diff before/README.md after/README.md | $G '^>' | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
[ "$YD" = 0 ] || die "R.432: dur8 finds $YD duration word(s) in the lines the card added"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
DN=$($G -rniwE -- "$DISH" README.md exercise harness/src 2> /dev/null | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|VALUES-PENDING|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
! $G -q '^```java$' README.md || die "README.md holds a java block - the code is the harness's files and the exercise's"
C13=$($G -nE 'Course 13' README.md exercise/README.md exercise/SOLUTION.md | $G -vF -- "$HANDOFF" | $G -vE 'the hand-off sentence|S8\.89|Course 13'"'"'s|ledger|roadmap|`:?[0-9]' | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$C13" ] || die "S8.89: Course 13 is named only by the pinned sentence (or where this README speaks of that sentence): $C13"
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
EXQ="Your turn: adding Mongo's transaction manager made the row's save fail, no bean named transactionManager. Bring JPA's manager back beside it."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SETUP=$(block exercise/README.md); SOL=$(block exercise/SOLUTION.md)
[ -n "$SETUP" ] && [ -n "$SOL" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
[ "$(diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G -c '^[<>]')" = 2 ] || die "R.196: SOLUTION.md's block must be the README's with one line changed"
[ "$(printf '%s\n' "$SETUP" | $G -cxF 'cp exercise/Lab24.java "$EX/Lab24.java"')" = 1 ] || die "R.196: the README's block runs Lab24 as shipped"
RENAME=$(printf '%s\n' "$SETUP" | sed 's#^cp exercise/Lab24.java "$EX/Lab24.java"$#perl -pe '"'"'s/MongoTransactionManager mongoTransactionManager\\(/MongoTransactionManager transactionManager(/'"'"' exercise/Lab24.java > "$EX/Lab24.java"#')
[ "$(diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$RENAME") | $G -c '^[<>]')" = 2 ] || die "the rename plant must be the README's block with one line changed"
printf '%s\n' "$SETUP" | $G -E '(^|[ (])(mvn|java|javac) ' | $G -vqF "perl -e '" && die "exercise/README.md's Java and Maven runs must run under their alarm (R.247)"
printf '%s\n' "$SETUP" | $G -E 'mvn ' | $G -vqF -- '-pl tiffinbox-web -am' && die "R.391: exercise/README.md builds without -pl tiffinbox-web -am"
printf '%s\n' "$SETUP" | $G -E '(^|[ ;&(])docker ' | $G -vqF 'docker -H "$DH" ' && die "R.344: exercise/README.md calls docker without its socket (docker -H \"\$DH\")"
printf '%s\n' "$SETUP" | $G -qF "docker -H \"\$DH\" rm -fv $XR $XP" || die "R.387: the exercise's containers are removed with their volumes (rm -fv)"
printf '%s\n' "$SETUP" | $G -qF -- "--name $XR --hostname $XR -p 127.0.0.1:20635:27017 -e GLIBC_TUNABLES=$GT mongo:8 --replSet rs0 --unixSocketPrefix /data/db --bind_ip_all" || die "R.421/R.428: the exercise's replica set on 127.0.0.1:20635, GLIBC_TUNABLES, by the tag mongo:8"
printf '%s\n' "$SETUP" | $G -qF -- "--name $XP -p 127.0.0.1:20636:5432 " || die "the exercise's PostgreSQL on 127.0.0.1:20636"
printf '%s\n' "$SETUP" | $G -qxF 'bash exercise/check.sh "$EX/run.log"' || die "R.196: the exercise is checked by exercise/check.sh (the bean list and both stores' own counts), never by the exit"
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
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
XE=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) exec [$"][^ ]+ [a-z_-]+( /proc/[a-z_/$]+)?' | awk '{ print $4 ($5 ? " " $5 : "") }' | sort -u | paste -sd'|' -)
[ "$XE" = 'cat /proc/net/$t|cat /proc/net/dev|pg_isready|psql' ] || die "every exec into a container here reads a /proc file by cat, or is PostgreSQL's own client - never a shell (found: $XE)"
[ -z "$($G -v '^ *#' receipts.sh | $G -E '(dk|docker) run ' | $G -oE -- ' -p [^ ]+' | $G -v '^ -p 127\.0\.0\.1:' || true)" ] && [ -z "$(printf '%s\n' "$SETUP" | $G -E 'docker -H "\$DH" run ' | $G -oE -- ' -p [^ ]+' | $G -v '^ -p 127\.0\.0\.1:' || true)" ] || die "S8.94: a port published on every interface (-p without 127.0.0.1)"
[ -z "$($G -rlE 'withReplicaSet|--replSet|replSetInitiate|MongoTransactionManager|ChainedTransactionManager' after/tiffinbox-web/src after/tiffinbox-core/src after/compose.yaml || true)" ] || die "flag 11: a replica set or a second transaction manager in after/'s sources"
$G -E '(dk|docker) run .*\$MIMG.*--replSet' receipts.sh | $G -v '^ *#' | $G -qF -- "-p 127.0.0.1:20635:27017" || die "R.428: the harness's replica set published on 127.0.0.1:20635"
! $G -rqE 'mongodb://[^ "]*replicaSet=' receipts.sh exercise harness/src || die "R.428: replicaSet= in a URI - one seed, no replicaSet="
MVA=$($G -v '^ *#' receipts.sh | $G -F 'clean ' | $G -F '$MV' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am"
ST=$(python3 -I -B harness/chk24.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
echo "  prose, per sentence (s824, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test): refused 0 over $PROSE and over the lines the card added to the anchor's README · dur8 0 there · dish names 0 · placeholders 0 · no java block · Course 13 only in the pinned sentence"
echo "  the hand-off (S8.89): printf '%s' <the sentence> | md5 -> $HMD5 = the pin; after/README.md holds it as one line, byte for byte"
echo "  the exercise: the spoken line $EXW words (wc -w); SOLUTION.md's block = the README's with one line changed; the rename plant = the README's with one other line changed; the two \"What it prints\" blocks differ (R.196); checked by exercise/check.sh, never the exit; its containers on 127.0.0.1:20635 and :20636, removed with their volumes; its build -pl tiffinbox-web -am; its docker calls on the socket"
echo "  static: no kill by name; every docker call on the pinned socket, every dk run --pull never, every MongoDB container with GLIBC_TUNABLES; no exec into a container but cat of a /proc file and PostgreSQL's own clients; no port on every interface (S8.94); every container removal dk rm -fv (R.387); the replica set on 127.0.0.1:20635, no replicaSet= anywhere (R.428); no replica set and no second manager in after/'s sources (flag 11); every Maven build -pl tiffinbox-web -am (R.391)"
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
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/polled [0-9]+ times/, "polled <k> times")
    gsub(/pid [0-9]+/, "pid <n>")
    gsub(/[0-9.]+ ?MiB \/ [0-9.]+ ?GiB/, "<MiB> / <GiB>")
    gsub(/ [0-9.]+(MiB|GiB|KiB|kB)/, " <mem>")
    gsub(/rss [0-9]+ kB/, "rss <kB> kB")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started H24 in 3.1 seconds (process running for 4.2)' 'Finished Spring Data repository scanning in 23 ms. Found 1 JPA repository interface.' 'Root WebApplicationContext: initialization completed in 812 ms' 'Successfully applied 4 migrations (execution time 00:00.026s)' 'Total time:  12.345 s' 'the receipt: pid 41231' 'tiffinbox-dev-postgres-1 41.15MiB / 7.818GiB' 'TiffinBox rss 400912 kB' "$U/x $HOME/y" | mask)
printf '%s\n' "$MP" | python3 -I -B -c 'import importlib.util,sys,re; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=sys.stdin.read(); sys.exit(1 if m.DUR.search(t) or "3.1 sec" in t or "00:00.026" in t or "812" in t or "12.345" in t or "41231" in t or "23 ms" in t or "41.15" in t or "400912" in t else 0)' || die "R.432: the mask's self-test - a planted duration, pid or one-shot memory reading passed it unmasked: $(printf '%s\n' "$MP" | head -2 | paste -sd';' -)"
[ "$(printf '%s\n' "$MP" | tail -1)" = '…/x ~/y' ] || die "the mask's self-test: the folders and the home must be masked"
echo "  mask: its self-test refused the planted Started-in-seconds, scanning, initialization, execution-time, Total time, pid and the one-shot memory readings (MiB / GiB, rss kB) unmasked (R.432); folders and home masked"
CURLSET=../c5-unit11/curlset.sh
[ -x "$CURLSET" ] || die "$CURLSET is missing - the comparison set the seven runs"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
[ -f "$ROADMAP" ] && [ -f "$LEDGER" ] || die "the roadmap ($ROADMAP) or the ledger ($LEDGER) is not beside this repository - handoff reads them"

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
[ "$(iid mongo:8) $(iid postgres:18-alpine) $(iid redis:8-alpine) $(iid $ETAG)" = '05b334b0a7a7 77f585114c32 7958cfbb9d15 fb7f2d0df199' ] || die "the tags compose.yaml and the exercise name (mongo:8, postgres:18-alpine, redis:8-alpine, $ETAG) are not on this machine at the course's digests - a Compose up would pull; this script never pulls"
for c in $MR $HN $XR $XP; do [ -z "$(dk ps -aq --filter name=^/$c\$ 2> /dev/null)" ] || die "a container named $c exists before the run - an interrupted run's? docker -H \"\$DH\" rm -fv $c"; done
[ -z "$(dk ps -aq --filter label=c8u24.ms=1 2> /dev/null)$(dk ps -aq --filter label=c8u24.ex=1 2> /dev/null)" ] || die "a mongosh witness container of this unit (or of its exercise's check) exists before the run"
[ -z "$(dk ps -aq --filter label=com.docker.compose.project=$PROJ 2> /dev/null)" ] && [ -z "$(dk network ls -q --filter name=^${PROJ} 2> /dev/null)" ] && [ -z "$(dk volume ls -q --filter name=^${PROJ} 2> /dev/null)" ] || die "a $PROJ container, network or volume exists before the run - footprint's Compose window needs none"
TC0=1
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18881 18882 18883 18884 20630 20631 20632 20633 20634 20635 20636 20637 20638 20639"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
[ "$(pgrep -x java | wc -l | tr -d ' ')" = 0 ] || die "a java process is running before this script starts one - not this script's; stop it first"
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · the four digests present ($IMG, $RIMG, $MIMG, $EIMG) · mongo:8, postgres:18-alpine, redis:8-alpine and $ETAG on those digests · nothing pulled, ever · no $PROJ container, network or volume · ports 20630-20639 and 18881-18884 free · java processes 0"

# ---- the trees, copied; the builds; the harness, compiled -----------------------------------------------------------------------
rm -rf .harness; mkdir -p .harness/run-h2/secrets/tiffinbox .harness/run-h .harness/home .harness/compose-run
M2="$PWD/.m2-demo"
[ -d "$M2" ] || die ".m2-demo (a copy of the course's seed, _research/m2-seed-c8-s4b) is missing - README.md, The repository"
NF0=$(find "$M2" -type f | wc -l | tr -d ' ')
echo "  .m2-demo's files $NF0 (the seed's 7,265 - no new artifact: this unit adds no dependency)"
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy before .harness/before; copy after .harness/after
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE '^\[INFO\] Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
echo "-- the builds (logged): $(date '+%T' | sed 's/.*/the receipt is at the build/')"
for t in before after; do
  XG=""; [ $t = after ] && XG=" dependency:build-classpath -Dmdep.outputFile=target/classpath.txt -Dmdep.includeScope=runtime"
  bg "cd .harness/$t && $MV clean package -DskipTests -pl tiffinbox-web -am$XG" .harness/build-$t.log
  [ "$RE" = 0 ] || { tail -20 .harness/build-$t.log >&3; die ".harness/$t did not build offline (exit $RE)"; }; offl .harness/build-$t.log
  bg "cd .harness/$t && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$t.log
  [ "$RE" = 0 ] || die ".harness/$t: the jar's extract failed"; done
$G -q 'spring-boot-docker-compose-4.1.2.jar' .harness/after/tiffinbox-web/target/classpath.txt || die "Maven's class path for after/ lacks spring-boot-docker-compose (the Compose window needs it)"
JB=$(md5 -q .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar); JA=$(md5 -q .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar)
LB=$(ls .harness/before/$XD/lib | wc -l | tr -d ' '); LA=$(ls .harness/after/$XD/lib | wc -l | tr -d ' ')
[ "$JB" = "$JA" ] || die "flag 11: after/'s jar is not before/'s, byte for byte ($JB / $JA) - the change must touch no byte of the jar"
CPH=".harness/hc:.harness/after/$XD/lib/*"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \".harness/after/$XD/lib/*\" harness/src/probe/u24/H24.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/'s libraries: $(head -5 .harness/javac.log)"
TF=secrets/tiffinbox/shutdown-token
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/run-h2/$TF) || die "the token was not written"
rsync -a after/ .harness/compose-run/ && mkdir -p .harness/compose-run/secrets/tiffinbox
for d in after before compose-run; do mkdir -p .harness/$d/secrets/tiffinbox; (umask 077 && cp .harness/run-h2/$TF .harness/$d/$TF) || die "the token was not copied"; done
cmp -s .harness/compose-run/compose.yaml after/compose.yaml || die "the Compose window's compose.yaml is not after/'s"
TOKEN=$(head -1 .harness/run-h2/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
PW=$(openssl rand -hex 16); (umask 077 && printf 'POSTGRES_USER=tiffinbox\nPOSTGRES_PASSWORD=%s\n' "$PW" > .harness/pg.env) || die "the password file was not written"
echo "  built before/'s and after/'s trees offline (mvn -o package -DskipTests -pl tiffinbox-web -am, exit 0, 'Downloaded from' 0; after/'s with Maven's runtime class path written beside it, for the Compose window), extracted their jars; the two jars: md5 equal ($( [ "$JB" = "$JA" ] && echo yes)) · BOOT-INF/lib before/ $LB, after/ $LA; compiled the harness (harness/src/probe/u24/H24.java, javac 25 -cp \"<after/'s jar's lib/*>\" - compiled, not source-launched); a shutdown token and a PostgreSQL password generated (0600, never printed)"
printf '%s\n' "jar-md5 $JA $JB" "libs $LA $LB" > .harness/jars.txt

# ---- helpers -------------------------------------------------------------------------------------------------------------------
vols() { dk volume ls -q 2> /dev/null | wc -l | tr -d ' '; }
mounts() { dk inspect -f '{{range .Mounts}}{{.Type}} {{.Destination}}{{println}}{{end}}' "$1" 2> /dev/null | $G . | sort | paste -sd'|' - | sed 's/|/ · /g'; }
pgready() { local i=0; while ! dk exec "$1" pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 120 ] || die "PostgreSQL ($1) did not accept connections (120 tries)"; sleep 0.5; done; }
# mongosh in a container with no network, on the replica set's unix socket (--volumes-from): the store's own count, no TCP at all
ms() { dk run --rm --pull never --label c8u24.ms=1 --network none --volumes-from "$1" -e GLIBC_TUNABLES=$GT --entrypoint mongosh $MIMG --quiet 'mongodb://%2Fdata%2Fdb%2Fmongodb-27017.sock/tiffinbox?directConnection=true' --eval "$2" 2>&1; }
mup() { local c=$1 i=0; while [ "$(ms "$c" 'print(db.version())' | tail -1)" != 8.3.17 ]; do i=$((i + 1)); [ $i -lt 120 ] || die "mongod ($c) did not answer mongosh's db.version() (120 reads)"; sleep 0.25; done; }
psq() { dk exec "$1" psql -U tiffinbox -d "$2" -qAt -v ON_ERROR_STOP=1 -c "$3" 2>&1 || die "psql failed on $1/$2: $3"; }
cu() { curl -s --noproxy '*' -o .harness/body -w '%{http_code}' "http://127.0.0.1:$1$2" 2> /dev/null || true; }
XES=org.springframework.boot.elasticsearch.autoconfigure.ElasticsearchClientAutoConfiguration,org.springframework.boot.elasticsearch.autoconfigure.ElasticsearchRestClientAutoConfiguration,org.springframework.boot.elasticsearch.autoconfigure.health.ElasticsearchRestHealthContributorAutoConfiguration,org.springframework.boot.data.elasticsearch.autoconfigure.DataElasticsearchAutoConfiguration,org.springframework.boot.data.elasticsearch.autoconfigure.DataElasticsearchRepositoriesAutoConfiguration,org.springframework.boot.data.elasticsearch.autoconfigure.DataElasticsearchReactiveRepositoriesAutoConfiguration,org.springframework.boot.data.elasticsearch.autoconfigure.health.DataElasticsearchReactiveHealthContributorAutoConfiguration
# the harness's stores: its replica set (a fixed --hostname; --bind_ip_all inside the container, the host side 127.0.0.1:20635 only)
# initiated by the harness JVM through the driver, and its PostgreSQL
rsup() {
  echo "\$ docker -H \"\$DH\" run -d --pull never --name $MR --hostname $MR -p 127.0.0.1:20635:27017 -e GLIBC_TUNABLES=$GT $MIMG --replSet rs0 --unixSocketPrefix /data/db --bind_ip_all"
  bg "dk run -d --pull never --name $MR --hostname $MR -p 127.0.0.1:20635:27017 -e GLIBC_TUNABLES=$GT $MIMG --replSet rs0 --unixSocketPrefix /data/db --bind_ip_all" .harness/docker-run-rs.log
  [ "$RE" = 0 ] || die "the replica set's container did not start: $(tail -2 .harness/docker-run-rs.log)"
  echo "\$ docker -H \"\$DH\" run -d --pull never --name $HN -p 127.0.0.1:20636:5432 --env-file .harness/pg.env $IMG"
  bg "dk run -d --pull never --name $HN -p 127.0.0.1:20636:5432 --env-file .harness/pg.env $IMG" .harness/docker-run-pg.log
  [ "$RE" = 0 ] || die "the harness's PostgreSQL did not start: $(tail -2 .harness/docker-run-pg.log)"
  mup $MR; pgready $HN
  [ "$(dk port $MR | paste -sd'|' -)" = '27017/tcp -> 127.0.0.1:20635' ] && [ "$(dk port $HN | paste -sd'|' -)" = '5432/tcp -> 127.0.0.1:20636' ] || die "a harness store publishes on another address than 127.0.0.1:<its port>"
  echo "  Docker's port lists (dk port): $MR $(dk port $MR | paste -sd'|' -) · $HN $(dk port $HN | paste -sd'|' -) (--bind_ip_all is inside the container; the host side is 127.0.0.1 alone) · $MR's Mounts: $(mounts $MR) · volumes now $(vols) (the machine's $VOL0 + the replica set's two + PostgreSQL's one)"
  echo "  mongosh (no network, --volumes-from $MR, its unix socket): db.hello().isWritablePrimary before the initiation -> $(ms $MR 'print(db.hello().isWritablePrimary)' | tail -1) · setName $(ms $MR 'print(db.hello().setName)' | tail -1)"
  H24DB=u24init; pgdb u24init
  h24 "" init
  echo "  mongosh (--volumes-from $MR): db.hello() -> $(ms $MR 'const h=db.hello(); print("me " + h.me + " · hosts " + JSON.stringify(h.hosts) + " · setName " + h.setName + " · isWritablePrimary " + h.isWritablePrimary)' | tail -1) · rs.status().members.length $(ms $MR 'print(rs.status().members.length)' | tail -1)"
  echo "  the harness's URI: mongodb://127.0.0.1:20635/tiffinbox - one seed, no replicaSet= (R.428)"
  echo "  that container's interfaces (its /proc/net/dev, read by cat): $(dk exec $MR cat /proc/net/dev | sed 1,2d | cut -d: -f1 | tr -d ' ' | sort | paste -sd',' -)"; }
pgdb() { psq $HN postgres "drop database if exists $1 with (force)" > /dev/null; psq $HN postgres "create database $1" > /dev/null
  echo "  a fresh database on $HN (psql): $1"; }
# h24 PROFILE MODE: the harness JVM (probe.u24.H24) on after/'s libraries, from .harness/run-h, under its alarm; the password in its
# environment (never on a command line); its lines that say "the harness's", the start's Flyway line and every WARN and ERROR line
h24() { local e=0 prof=$1 mode=$2
  echo "\$ cd .harness/run-h && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -cp \"../hc:../after/$XD/lib/*\" probe.u24.H24 --logging.config=../../harness/logback.xml --spring.main.web-application-type=none --spring.datasource.url=jdbc:postgresql://127.0.0.1:20636/$H24DB --spring.mongodb.uri=mongodb://127.0.0.1:20635/tiffinbox --spring.autoconfigure.exclude=<Elasticsearch's seven> ${prof:+--spring.profiles.active=$prof }--u24.mode=$mode" | mask
  (cd .harness/run-h && SPRING_DATASOURCE_USERNAME=tiffinbox SPRING_DATASOURCE_PASSWORD="$PW" exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -cp "../hc:../after/$XD/lib/*" probe.u24.H24 --logging.config=../../harness/logback.xml --spring.main.web-application-type=none --spring.main.banner-mode=off --spring.datasource.url=jdbc:postgresql://127.0.0.1:20636/$H24DB --spring.jpa.hibernate.ddl-auto=none --spring.jpa.open-in-view=false --spring.mongodb.uri=mongodb://127.0.0.1:20635/tiffinbox --spring.autoconfigure.exclude=$XES ${prof:+--spring.profiles.active=$prof} --u24.mode=$mode) > .harness/h24.log 2>&1 < /dev/null & pid=$!
  wait "$pid" || e=$?; pid=""
  $G -oE 'Successfully applied [0-9]+ migrations?' .harness/h24.log | sed 's/^/  the start: /'
  $G -E "^the harness's " .harness/h24.log | sed 's/^/  /'
  echo "  its WARN and ERROR lines: $($G -cE '^(WARN|ERROR) ' .harness/h24.log || true)"; $G -E '^(WARN|ERROR) ' .harness/h24.log | cut -c1-200 | sed 's/^/    /'
  echo "  the harness JVM's exit $e"; }
# the two stores' own counts after the JVM is gone: psql (the harness's PostgreSQL, in its container) and mongosh (no network), by name
NAMESJS='db.u24_notes.aggregate([{$group:{_id:"$name",n:{$sum:1}}},{$sort:{_id:1}}]).toArray().forEach(d=>print(d._id + " " + d.n))'
witness() {
  echo "  psql (the harness's PostgreSQL, $HN, database $H24DB): select count(*) from dish -> $(psq $HN $H24DB 'select count(*) from dish') · the harness's rows (id > 10), by name:"
  psq $HN $H24DB "select name || ' ' || count(*) from dish where id > 10 group by name order by name collate \"C\"" | sed 's/^/    psql rows: /'
  echo "  mongosh (no network, --volumes-from $MR): db.u24_notes.countDocuments() -> $(ms $MR 'print(db.u24_notes.countDocuments())' | tail -1) · by name:"
  ms $MR "$NAMESJS" | LC_ALL=C sort | sed 's/^/    mongosh documents: /'; }
mclear() { echo "  mongosh (no network): db.u24_notes.deleteMany({}) -> deletedCount $(ms $MR 'print(db.u24_notes.deleteMany({}).deletedCount)' | tail -1)"; }
NCAP=3
unpub=""; CAPRUN=0; CAPNM=""
cap() { local nm=$1 i n=$NCAP; shift
  i=1; while [ $i -le $n ]; do CAPRUN=$i; CAPNM=$nm; "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    $G -q '^  \*\*\* ' .harness/cap.raw && { cat .harness/cap.raw >&3; die "$nm stopped (above)"; }
    ! $G -qE 'localhost:[0-9]{5}|127\.0\.0\.1:(3|4|5|6)[0-9]{4}' .harness/cap.raw || die "R.319: $nm printed a container's port raw"
    ! $G -qF -- "$PW" .harness/cap.raw || die "$nm printed the PostgreSQL password"
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
  o=$(python3 -I -B harness/chk24.py "$nm" "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk24 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -5 >&3; die "$nm: its check failed (harness/chk24.py)"; }
  VALS="$VALS${VALS:+ · }$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }
# tb TREE RUN PORT ARG...: TiffinBox's jar of TREE (java -jar, under its alarm), from .harness/RUN (its config tree), in the background
tb() { local tr=$1 run=$2 port=$3 i=0 c; shift 3
  echo "\$ cd .harness/$run && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -jar ../$tr/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port $*" | mask
  (cd .harness/$run && exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -jar ../$tr/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port "$@") > .harness/tb.log 2>&1 < /dev/null & pid=$!
  TBUP=0; while [ $i -lt 960 ]; do c=$(cu $port /actuator/health/readiness); [ "$c" = 200 ] && { TBUP=1; break; }
    kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  if [ "$TBUP" = 0 ] && kill -0 "$pid" 2> /dev/null; then die "TiffinBox neither answered readiness nor stopped (960 reads)"; fi; }
tbstop() { local c; c=$(printf 'X-Shutdown-Token: %s\n' "$(head -1 .harness/$1/$TF)" | curl -s --noproxy '*' -o /dev/null -w '%{http_code}' -H @- -X POST "http://127.0.0.1:$2/shutdown" 2> /dev/null || true)
  TBX=0; wait "$pid" || TBX=$?; pid=""
  [ "$(listeners $2)" = 0 ] || die "something still listens on $2 after TiffinBox stopped"
  echo "  POST /shutdown (the token on curl's standard input) -> $c · the JVM's exit $TBX · listening on $2: 0"; }

# ---- the captures --------------------------------------------------------------------------------------------------------------
jars() { local L=.harness/after/$XD/lib j1 j2
  j1=$(cd .harness/after/$XD/lib && ls spring-boot-jpa-*.jar); j2=$(cd .harness/after/$XD/lib && ls spring-data-commons-*.jar)
  echo "-- jars: the two jars, by name off after/'s BOOT-INF/lib (ls): $j1 · $j2 · BOOT-INF/lib holds $(ls $L | wc -l | tr -d ' ') jars"
  echo "  unzip -l $j1 | grep JpaBaseConfiguration.class -> $(unzip -l $L/$j1 | awk '$4 == "org/springframework/boot/jpa/autoconfigure/JpaBaseConfiguration.class" { print $4 " " $1 " B" }')"
  echo "\$ javap -v -cp $j1 org.springframework.boot.jpa.autoconfigure.JpaBaseConfiguration   (the method transactionManager and its RuntimeVisibleAnnotations, whole)"
  javap -v -cp $L/$j1 org.springframework.boot.jpa.autoconfigure.JpaBaseConfiguration | awk '/^  public .* transactionManager\(/ { f = 1; print; next } f && /RuntimeVisibleAnnotations:/ { a = 1; print; next } a && /^ +[0-9]+: #/ { print; next } a && /^ {8}[a-z]/ { print; next } a && /^ {10}value=/ { print; next } a && /^ {8}\)/ { print; next } a { exit }' | sed -E 's/#[0-9]+(\(|=)/#n\1/g; s/\[c#[0-9]+\]/[c#n]/g; s/^/  /'
  echo "  unzip -l $j2 | grep ChainedTransactionManager.class -> $(unzip -l $L/$j2 | awk '$4 == "org/springframework/data/transaction/ChainedTransactionManager.class" { print $4 " " $1 " B" }')"
  echo "  javap -v -cp $j2 org.springframework.data.transaction.ChainedTransactionManager: $(javap -v -cp $L/$j2 org.springframework.data.transaction.ChainedTransactionManager | $G -E '^(public class |Deprecated: true)' | sed -E 's/ implements .*//' | paste -sd'|' - | sed 's/|/ · /') · its class annotation: $(javap -v -cp $L/$j2 org.springframework.data.transaction.ChainedTransactionManager | awk '/^RuntimeVisibleAnnotations:/ { a = 1; next } a && /^ +[a-z]/ { print $1; exit }')"
  echo "  Boot's own MongoDB jars, entries naming MongoTransactionManager (unzip -l): $(for j in spring-boot-mongodb spring-boot-data-mongodb; do printf '%s %s · ' "$j" "$(unzip -l $L/$j-4.1.2.jar | $G -c MongoTransactionManager || true)"; done | sed 's/ · $//') - Boot makes no Mongo manager (Part A's reading, unit 20)"; }
handoff() { local r
  echo "-- handoff (S8.89): the sentence, its md5, where it stands, and what it rests on:"
  echo "  printf '%s' \"\$HANDOFF\" | md5 -> $(printf '%s' "$HANDOFF" | md5 -q)"
  for f in after/README.md ../c8-tiffinbox/README.md; do echo "  $f: lines equal to it (grep -cxF) $($G -cxF -- "$HANDOFF" "$f" || true) · that line's md5 (no newline) $($G -xF -- "$HANDOFF" "$f" | head -1 | tr -d '\n' | md5 -q)"; done
  echo "  the roadmap (_briefs/TRACK-ROADMAP.md), the lines it rests on, cut at 160 characters:"
  for r in 64 552 580 581 922; do echo "    :$r $(sed -n ${r}p "$ROADMAP" | cut -c1-160)"; done
  echo "  the promise ledger's row C8-20 (PROMISE-LEDGER-2026-11-17.md, its first 150 characters): $($G -E '^\| C8-20 \|' "$LEDGER" | cut -c1-150)"; }
# each capture leaves the collection empty (mclear after its witnesses), so the next starts from 0 documents - the harness prints it
mtm() { H24DB=u24mtm; pgdb u24mtm; h24 mtm mtm; witness; mclear; }
mtmnamed() { H24DB=u24named; pgdb u24named; h24 mtmnamed mtmnamed; witness; mclear; }
both() { H24DB=u24both; pgdb u24both; h24 both beans; }
dual() { H24DB=u24dual; pgdb u24dual; h24 both dual; witness; mclear; }
scoped() { H24DB=u24scoped; pgdb u24scoped; h24 both scoped
  echo "  the start's log: TransactionSynchronization.afterCompletion threw exception lines $($G -c 'TransactionSynchronizationUtils : TransactionSynchronization.afterCompletion threw exception' .harness/h24.log || true)"
  witness; mclear; }
SOCKPY='import sys
st={"01":"ESTABLISHED","02":"SYN_SENT","03":"SYN_RECV","04":"FIN_WAIT1","05":"FIN_WAIT2","06":"TIME_WAIT","07":"CLOSE","08":"CLOSE_WAIT","09":"LAST_ACK","0A":"LISTEN","0B":"LISTENING"}
L={"tcp":[],"udp":[]}
for f in sys.argv[1:]:
    k="udp" if "udp" in f else "tcp"
    for l in open(f).read().splitlines()[1:]:
        p=l.split()
        if len(p) > 3: L[k].append((int(p[1].split(":")[1], 16), int(p[2].split(":")[1], 16), st.get(p[3], p[3])))
ls=sorted({a for a, b, s in L["tcp"] if s == "LISTEN"}); out=[x for x in L["tcp"] if x[2] != "LISTEN" and x[0] != 27017]
print("listening (TCP) on " + ", ".join(map(str, ls)) + " · connections from another local port (outbound): " + str(len(out)) + " · UDP sockets: " + str(len(L["udp"])))'
sockets() { local t
  echo "-- sockets: $MR (the harness's replica set, alive since the harness window opened), its /proc/net/tcp, tcp6, udp and udp6 read by cat at the end of the window (dk exec - a file, never a shell):"
  echo "  its interfaces (/proc/net/dev): $(dk exec $MR cat /proc/net/dev | sed 1,2d | cut -d: -f1 | tr -d ' ' | sort | paste -sd',' -)"
  for t in tcp tcp6 udp udp6; do dk exec $MR cat /proc/net/$t > .harness/net-$t.txt 2> /dev/null || : > .harness/net-$t.txt; done
  echo "  the sockets: $(python3 -I -c "$SOCKPY" .harness/net-tcp.txt .harness/net-tcp6.txt .harness/net-udp.txt .harness/net-udp6.txt)"; }
# footprint (flag 5, RE-MEASURE 11): the shipped compose.yaml's four services started by Boot's Compose support for after/ under dev,
# the dishes index built by the start, one search; docker stats ONCE; the reading masked in the capture (a one-shot reading, never
# hashed), printed whole into this log; the window torn down down -v and the mongo service's two anonymous volumes by name
footprint() { local vb i=0 c TBUP=0
  vb=$(vols)
  echo "-- footprint: after/ under dev on 20630, Boot's Docker Compose support on, the shipped compose.yaml (cmp: after/'s), from .harness/compose-run:"
  for c in 18881 18882 18883 18884; do [ "$(listeners $c)" = 0 ] || die "$c is bound before the Compose window"; done
  echo "\$ cd .harness/compose-run && DOCKER_HOST=\$DH perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 300; exec @ARGV' java $JL -cp \"<after/'s classes>:<Maven's runtime class path for after/>\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=20630 --spring.profiles.active=dev"
  CMPW=1
  (cd .harness/compose-run && DOCKER_HOST="$DH" exec perl -e '$SIG{INT}="DEFAULT"; alarm 300; exec @ARGV' java $JL -cp "../after/tiffinbox-web/target/classes:$(cat ../after/tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=20630 --spring.profiles.active=dev) > .harness/compose.log 2>&1 < /dev/null & pid=$!
  while [ $i -lt 1200 ]; do c=$(cu 20630 /actuator/health/readiness); [ "$c" = 200 ] && { TBUP=1; break; }; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  [ "$TBUP" = 1 ] || { tail -20 .harness/compose.log | mask >&3; die "after/ under dev with Compose did not start"; }
  CMPV=$(dk inspect -f '{{range .Mounts}}{{.Name}} {{end}}' ${PROJ}-mongo-1 2> /dev/null)
  echo "  the project's containers: $(dk ps --filter label=com.docker.compose.project=$PROJ --format '{{.Names}} {{.Ports}}' | sort | paste -sd'|' - | sed 's/|/ · /g')"
  echo "  the mongo service (a standalone, Part A's flag 6): its command $(dk inspect -f '{{json .Config.Cmd}}' ${PROJ}-mongo-1) · no --replSet"
  echo "  the start's lines: $($G -oE 'Successfully applied [0-9]+ migrations?|tiffinbox +: dishes re-indexed: .*' .harness/compose.log | sed -E 's/^tiffinbox +: /tiffinbox: /' | sort | uniq -c | sed -E 's/^ +//' | paste -sd'|' - | sed 's/|/ · /g')"
  echo "  GET /dishes/search?q=veg (TiffinBox, 20630) -> $(cu 20630 '/dishes/search?q=veg') $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(len(d), "hit(s), ids [" + ", ".join(str(h["id"]) for h in d) + "]")' .harness/body 2> /dev/null)"
  dk stats --no-stream --format '{{.Name}} {{.MemUsage}}' > .harness/stats.txt 2>&1 || die "the stats read failed"
  TM=$(dk info --format '{{.MemTotal}}'); RSS=$(ps -o rss= -p "$pid" | tr -d ' ')
  python3 -I -c '
import re,sys
rows=[l.split(" ",1) for l in open(sys.argv[1]).read().splitlines() if l.startswith("tiffinbox-dev-")]
def mib(s):
    v,u=re.match(r"([0-9.]+)\s*([KMG]i?B)",s).groups(); return float(v)*{"KiB":1/1024,"MiB":1,"GiB":1024,"kB":1/1024,"MB":1,"GB":1024}[u]
tot=sum(mib(r[1].split("/")[0].strip()) for r in rows)
print("FOOTPRINT " + " · ".join(r[0] + " " + r[1].split("/")[0].strip() for r in sorted(rows)) + " · the four together %.1f MiB · the VM total %.3f GiB (MemTotal of the engine %s B) · TiffinBox rss %s kB" % (tot, int(sys.argv[2])/1024**3, sys.argv[2], sys.argv[3]))' .harness/stats.txt "$TM" "$RSS" > .harness/footprint.txt
  cat .harness/footprint.txt >> .harness/footprint-readings.txt
  echo "  docker stats --no-stream ONCE, the project's four containers by name (the reading is a one-shot value: masked here, printed whole in the receipt's log): $(sed -E 's/^FOOTPRINT //; s/ [0-9.]+(MiB|GiB|KiB|kB)/ <mem>/g; s/ [0-9.]+ MiB/ <MiB> MiB/; s/ [0-9.]+ GiB/ <GiB> GiB/; s/MemTotal [0-9]+ B/MemTotal <n> B/; s/rss [0-9]+ kB/rss <kB> kB/' .harness/footprint.txt)"
  echo "  the containers docker stats listed: $($G -c '^tiffinbox-dev-' .harness/stats.txt || true) of the project's · others (not this unit's, never summed): $($G -vc '^tiffinbox-dev-' .harness/stats.txt || true)"
  tbstop compose-run 20630
  (cd .harness/compose-run && dk compose -p $PROJ down -v) > .harness/compose-downv.log 2>&1 || die "compose down -v failed: $(tail -2 .harness/compose-downv.log)"
  echo "\$ cd .harness/compose-run && docker -H \"\$DH\" compose -p $PROJ down -v"
  echo "  then: the project's containers $(dk ps -aq --filter label=com.docker.compose.project=$PROJ | $G -c . || true) · the mongo service's two anonymous volumes: $(for v in $CMPV; do dk volume inspect $v > /dev/null 2>&1 && echo present || echo gone; done | paste -sd' ' -)"
  for v in $CMPV; do dk volume inspect "$v" > /dev/null 2>&1 && { dk volume rm "$v" > /dev/null 2>&1 || die "the volume could not be removed"; }; done
  CMPW=""; CMPV=""
  [ "$(vols)" = "$vb" ] || die "after the Compose window the volume count is $(vols), not $vb (the count before it)"
  echo "  the receipt removes the mongo service's two by the names its container listed (dk volume rm): volumes back to the count before the window · listening on 18881-18884: $(( $(listeners 18881) + $(listeners 18882) + $(listeners 18883) + $(listeners 18884) ))"; }
default() {
  echo "-- after/ with no profile (TiffinBox's default run): H2 in memory, Docker at nothing (DOCKER_HOST=tcp://127.0.0.1:1), no Elasticsearch, no MongoDB; one JVM:"
  DOCKER_HOST=tcp://127.0.0.1:1 tb after run-h2 20630
  [ "$TBUP" = 1 ] || { tail -20 .harness/tb.log | mask >&3; die "after/'s default run did not start"; }
  echo "  GET /actuator/health -> $(cu 20630 /actuator/health) $(tr -d '\n' < .harness/body | cut -c1-200)"
  echo "  GET /dishes/search?q=veg -> $(cu 20630 '/dishes/search?q=veg') · GET /revenue/by-customer -> $(cu 20630 /revenue/by-customer) · GET /menu/day-19 -> $(cu 20630 /menu/day-19) · GET /revenue -> $(cu 20630 /revenue) · GET /kitchen -> $(cu 20630 /kitchen)"
  tbstop run-h2 20630
  echo "  its log: lines naming 9200 $($G -c 9200 .harness/tb.log || true) · naming elasticsearch, any case $($G -ci elasticsearch .harness/tb.log || true) · naming 27017 $($G -c 27017 .harness/tb.log || true) · naming mongo, any case $($G -ci mongo .harness/tb.log || true) · Flyway: $($G -oE 'Successfully applied [0-9]+ migrations?' .harness/tb.log)"
  echo "  the jar it ran (after/'s) and before/'s, md5 (flag 11 - the README is not in the jar): $(awk '$1 == "jar-md5" { print ($2 == $3 ? "equal" : "DIFFERENT") }' .harness/jars.txt) · BOOT-INF/lib $(awk '$1 == "libs" { print $2 " and " $3 }' .harness/jars.txt)"; }
seven() { local t i c e a port
  for t in before after; do i=0; e=0; [ $t = after ] && port=20630 || port=20637
    echo "-- the seven: $t/'s jar, java -jar, H2 in memory (a fresh JVM), port $port:"
    echo "\$ cd .harness/$t && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port"
    (cd .harness/$t && DOCKER_HOST=tcp://127.0.0.1:1 exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port) > .harness/seven-run.log 2>&1 < /dev/null & pid=$!
    while [ $i -lt 480 ]; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
      kill -0 "$pid" 2> /dev/null || { tail -20 .harness/seven-run.log | mask >&3; die "TiffinBox exited before readiness answered 200"; }
      sleep 0.25; i=$((i + 1)); done
    [ "$c" = 200 ] || die "readiness never answered 200 on $port"
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    echo "  GET /actuator/health/readiness -> 200 · listens on: $a"
    echo "\$ \$CURLSET $port .harness/$t/$TF"
    "$CURLSET" $port .harness/$t/$TF | $G ' -> ' | awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' > .harness/seven-$t.txt || true
    i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 480 ]; do sleep 0.25; i=$((i + 1)); done
    kill -0 "$pid" 2> /dev/null && die "TiffinBox on $port was still running after POST /shutdown"
    wait "$pid" || e=$?; pid=""
    [ "$(listeners $port)" = 0 ] || die "something still listens on $port"
    echo "  exit $e · the seven responses: $(wc -l < .harness/seven-$t.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven-$t.txt) · listening on $port now: 0"
    ! $G -qF -- "$TOKEN" .harness/seven-run.log || die "TiffinBox's log held the token"; done
  echo "  the seven, after/ against before/: lines that differ: $(diff .harness/seven-before.txt .harness/seven-after.txt | $G -c '^[<>]' || true)"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exblk() { local nm=$1 sh=$2 i=0
  printf '%s\n' 'cd "$1" || exit 1' '. "$1/.harness/ex-'"$nm"'.sh" > "$1/.harness/ex-'"$nm"'.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-'"$nm"'.st"' > .harness/ex-drive-$nm.sh
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive-$nm.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive-$nm.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 4800 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after its cap"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-$nm.st ] || { cat .harness/ex-shell.out .harness/ex-$nm.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of the $nm block"; }; }
exsh() { local sh=$1 e1 d1 e2 d2 v1
  rm -rf .harness/ex; rm -f .harness/ex-*.st .harness/ex-*.out
  v1=$(vols)
  printf '%s\n' 'cd "$1" || exit 1' '. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-readme.st"' 'cd "$1" || exit 1' '. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-sol.st"' > .harness/ex-drive.sh
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  local i=0; while kill -0 "$xpid" 2> /dev/null && [ $i -lt 4800 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after its cap"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines, the block's exit $e1:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "  then the solution's lines, in the same shell - the block's exit $e2:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · listening on 20635 and 20636 afterwards: $(( $(listeners 20635) + $(listeners 20636) )) · the containers $XR, $XP afterwards: $(dk ps -aq --filter name=^/c8u24-ex- | $G -c . || true) · volumes $(vols) (before the shell: $v1) · java processes of the exercise: $(ps -axo command= | $G -c '[L]ab24' || true) · images afterwards: the same list $( [ "$(dk images -q --no-trunc 2> /dev/null | sort -u | paste -sd' ' -)" = "$IMGS0" ] && echo yes || echo no)"; }
exercise() { local k e d
  printf '%s\n' "$SETUP" > .harness/ex-readme.sh; printf '%s\n' "$SOL" > .harness/ex-sol.sh; printf '%s\n' "$RENAME" > .harness/ex-rename.sh
  echo "exercise/README.md's $(printf '%s\n' "$SETUP" | $G -c .) lines, then exercise/SOLUTION.md's, as written, one after the other in ONE env -i shell (HOME and the PATH this script was started with), started in this folder:"
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh
  echo "the rename \"solution\" (Mongo's bean renamed transactionManager - the README's block with this one line changed), three times, each in a fresh env -i bash, through exercise/check.sh:"
  diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$RENAME") | $G '^>' | sed 's/^> /  $ /'
  for k in 1 2 3; do rm -f .harness/ex-rename.st .harness/ex-rename.out; exblk rename bash; read -r e d < .harness/ex-rename.st
    echo "  rename run $k - the block's exit $e:"; $G -E "^(check:|the lab's (transaction managers|plain call|plain:))" .harness/ex-rename.out | sed 's/^/    /'; done; }

# ---- the runs ------------------------------------------------------------------------------------------------------------------
echo "-- exercise (once per run of record; its stores are its own, on 20635 and 20636, before the harness's):"
NCAP=1; cap exercise exercise; chk exercise .r-exercise.out "$EXW" "$EXQ"
for f in exercise/README.md exercise/SOLUTION.md; do
  w=$(python3 -I -B harness/chk24.py wib .r-exercise.out "$f"); [ "$(wib "$f")" = "$w" ] || die "$f's \"What it prints\" block is not what its lines printed: $(diff <(wib "$f") <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"; done
echo "  exercise: each file's \"What it prints\" block = what its lines printed (bash's; zsh's the same - chk24)"
pub exercise
[ "$(vols)" = "$VOL0" ] || die "R.322: after the exercise the volume count is $(vols), not $VOL0"
NCAP=3
cap jars jars; chk jars .r-jars.out; pub jars
cap handoff handoff; chk handoff .r-handoff.out "$HMD5"; pub handoff
echo "-- the harness window: its replica set and its PostgreSQL ($(date '+%T' | sed 's/.*/opened/')):"
rsup > .harness/rs-window.out 2>&1 || true; [ -z "$pid$mpid" ] || die "the replica set's window left a process running"
$G -q '^  \*\*\* ' .harness/rs-window.out && { cat .harness/rs-window.out >&3; die "the harness window stopped (above)"; }
mask < .harness/rs-window.out | sed 's/^/  /'
$G -q "^  the harness's hello: isWritablePrimary true · me localhost:27017 · hosts \[localhost:27017\] · setName rs0$" .harness/rs-window.out || die "R.428: the replica set never answered hello as the writable primary through the driver"
cap mtm mtm; chk mtm .r-mtm.out; pub mtm
cap mtmnamed mtmnamed; chk mtmnamed .r-mtmnamed.out; pub mtmnamed
cap both both; chk both .r-both.out; pub both
cap dual dual; chk dual .r-dual.out; pub dual
cap scoped scoped; chk scoped .r-scoped.out; pub scoped
cap sockets sockets; chk sockets .r-sockets.out; pub sockets
dk rm -fv $MR $HN > /dev/null 2>&1 || die "the harness's stores could not be removed"
[ "$(vols)" = "$VOL0" ] || die "R.322: after the harness window the volume count is $(vols), not $VOL0"
echo "  $MR and $HN removed (rm -fv) · volumes $(vols)"
NCAP=1; cap footprint footprint; chk footprint .r-footprint.out; pub footprint
echo "  the footprint's reading (this run's, one-shot - the README's numbers are a run of record's): $(sed 's/^FOOTPRINT //' .harness/footprint.txt)"
NCAP=3
cap default default; chk default .r-default.out; pub default
cap seven seven; chk seven .r-seven.out "$S466"; pub seven
echo "  the values (chk24's, every capture's): $(printf '%s' "$VALS" | wc -c | tr -d ' ') bytes"
printf '%s\n' "$VALS" > .harness/values.txt
python3 -I -B harness/chk24.py readme README.md .harness/values.txt > .harness/chk-readme.out 2>&1 || { $G '^FAIL' .harness/chk-readme.out | head -5 >&3; die "README.md: its values block or a text block is not what the runs printed (R.302)"; }
echo "  R.302: README.md's $($G -c '^```text$' README.md) text blocks - every line one the runs printed; the values block = the captures' (chk24 readme: $($G -c '^ok ' .harness/chk-readme.out) checks)"
HY=$(cat .r-*.out | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
[ "$HY" = 0 ] || die "R.432: dur8 finds $HY duration word(s) in the captures"
! cat .r-*.out | $G -qE '[0-9]+\.[0-9]+ seconds|PT[0-9]|pid [0-9]|0\.0\.0\.0:[0-9]|\[::\]:[0-9]' || die "a time, a pid or an all-interfaces binding in a capture"
! cat .r-*.out | $G -qF -- "$PW" || die "the password in a capture"
! cat .r-*.out | $G -qF -- "$TOKEN" || die "the token in a capture"
echo "  hygiene: dur8 over the captures 0 words; no time, pid, all-interfaces binding, token or password in any capture; every JVM and Maven under its alarm"
# ---- the end -------------------------------------------------------------------------------------------------------------------
for c in $MR $HN $XR $XP; do [ -z "$(dk ps -aq --filter name=^/$c\$)" ] || die "the container $c is still there"; done
[ -z "$(dk ps -aq --filter label=c8u24.ms=1)" ] || die "a mongosh witness container is still there"
[ -z "$(dk ps -aq --filter label=com.docker.compose.project=$PROJ)" ] && [ -z "$(dk volume ls -q --filter name=^$PROJ)" ] || die "the $PROJ project left a container or a volume"
VOL1=$(vols); [ "$VOL1" = "$VOL0" ] || die "R.322: volumes $VOL0 -> $VOL1"
[ "$(dk images -q --no-trunc | sort -u | paste -sd' ' -)" = "$IMGS0" ] || die "the images moved - nothing may be pulled"
[ "$(find "$M2" -type f | wc -l | tr -d ' ')" = "$NF0" ] || die ".m2-demo gained files - offline: no"
echo "  docker at the end: $MR, $HN, $XR, $XP and every mongosh witness container removed with their volumes (rm -fv), the $PROJ project gone; volumes $VOL0 -> $VOL1; images $NI0, the same list (nothing pulled); .m2-demo's files unchanged ($NF0)"
pin before-tree before end; pin after-tree after end
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c8-tiffinbox 2>&1 || true)
echo "  ../c8-tiffinbox against after/ at the end: $( [ -z "$AD" ] && echo 'diff -rq empty' || echo 'they differ (the anchor is not this unit'"'"'s after/ yet)')"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
echo "  ports: nothing listens on 20630-20639 or 18881-18884 at the end - the harness's stores bound 20635 and 20636 (the exercise's too), TiffinBox 20630 (after/) and 20637 (before/), Compose's four 18881-18884; 20631-20634, 20638 and 20639 were never bound"
[ -z "$unpub" ] || { echo "c8-unit24: captures without a published hash:$unpub - write them into receipts.md5 from this run's output"; exit 0; }
echo "c8-unit24: every capture = published (jars, handoff, mtm, mtmnamed, both, dual, scoped, sockets, default and the seven 3/3 in this run; exercise and footprint once per run); every number re-derived by chk24.py; before/ and after/ = their pins; the volume count and the images unchanged"
