#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 8 · MongoDB: Documents, Not Rows - this unit's receipts. Section 4's first anchor change (D1): before/ is a link to
# ../c8-unit17/after (unit 17's tree), after/ is this unit's tree and ../c8-tiffinbox equals it from this unit's commit on. D1 adds
# Spring Data MongoDB under the profile "dev": the starter (and, test scope, its slice and Testcontainers' module), application.yaml's
# three-class exclude and application-dev.yaml's clear, compose.yaml's mongo service, MenuDay (a document per day, its items inside)
# and Menus (GET /menu/{day}, MongoTemplate), TiffinBoxServer.start()'s menu fill (a delete, then thirty inserts), MongoSlice and
# MongoDatastoreIT, and the anchor README's unit 18 section.
# Two witnesses for every MongoDB number (R.423): Java's answer (TiffinBox's routes, the harness's MongoTemplate, the IT) and mongosh's
# view of the stored document or of system.profile - mongosh ONLY in a second container of the same digest with no network
# (--network none, --volumes-from the mongod container, over mongod's unix socket - ms below, R.422); never docker exec ... mongosh.
# PostgreSQL's side of oneread and rename: the harness's OWN PostgreSQL container on 20576 (log_statement=all), never the unit's.
# Whose: the ANCHOR's (after/'s jar under "dev" or the default run: anchor, absent, default, twice's two starts, the seven), the
# HARNESS's (probe.u18.H18: MongoTemplate.findById, the refill, the rename, the null id; the four and three PostgreSQL tables) or a
# LABELLED COPY's (variants.py starteronly / healthkey / noreset - default's and twice's copies).
# Captures (the JVM ones run three times and hashed; exercise once per run of record - its 3/3 is across the runs; the tests once per
# run of record too, folded into anchor):
#   exercise  exercise/README.md's lines, then SOLUTION.md's, as written, in ONE env -i shell - bash, then zsh -f (no Docker, no Mongo)
#   image     the digest's facts; a container without the variable (exit 1, the kernel line); the unit's container with it (8.3.17, lo)
#   anchor    the tests; the libraries; after/ under "dev" on PostgreSQL + Redis + MongoDB: the start's lines, the menu, health; and ONE
#             Compose window on the shipped compose.yaml (Boot's Compose support): the database by the store, then stop / down / down -v
#   document  mongosh's findOne(day-19) beside the harness's findById; a null id (the harness's insert) -> an ObjectId, 24 characters
#   oneread   system.profile around ONE findById beside PostgreSQL's one statement (the harness's four tables, and three, labelled)
#   rename    one updateMulti over thirty documents beside PostgreSQL's UPDATE on four tables (1 row) and on three (30 rows, the tie)
#   absent    after/ under "dev", MongoDB absent: the start stops, exit 1, the driver's exception named; nothing listens
#   default   after/ with no profile on H2, no Docker: health 200, /menu 404, 0 log lines naming 27017 or mongo; two labelled copies
#   twice     two dev starts in a row, the same thirty; the copy without the reset - the store's answer to the second start
#   seven     the comparison set on before/'s and after/'s jars (H2; after/ on 20570, before/ on 20575); Hibernate's script
# Every tree is COPIED under .harness/ and built there, offline (-o, from .m2-demo, a copy of the course's seed, maven.repo.local
# absolute), every module from the tree's own sources (-pl tiffinbox-web -am, R.391). Every JVM and Maven run under an alarm (R.247),
# every JVM with SIGINT reset to its default (R.410). Every docker call names its socket (dk, R.344), --pull never; every container is
# removed with its volumes (rm -fv, R.387 / R.421) and the volume count asserted back. A receipt waits on a count it polls (R.412).
# Ports (20570-20579): 20570 TiffinBox after/ · 20571 the unit's PostgreSQL · 20572 the unit's Redis · 20573 the unit's MongoDB (and the
# no-variable container's one failed start) · 20574 reserved (Elasticsearch, Part B - never bound) · 20575 TiffinBox before/ for the
# seven · 20576 the harness's PostgreSQL · 20577 the port "MongoDB absent" points at, asserted unbound · 20578 the IT's MongoDB container
# (R.454's binding, 127.0.0.1 only) · 20579 the exercise's TiffinBox. 18881-18883 only inside anchor's Compose window.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
RIMG=redis@sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3
MIMG=mongo@sha256:05b334b0a7a78fe913caac0cd2e1ecccf4da515d9a3a44be911b6ea3734c17cd
GT=glibc.pthread.rseq=1
CN=c8u18-pg; RN=c8u18-redis; MN=c8u18-mongo; MNV=c8u18-mongo-nov; HN=c8u18-pg-h; PROJ=tiffinbox-dev
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
pid=""; mpid=""; xpid=""; CMPW=""; CMPV=""; TC0=""; INTR=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.u18.") || index($0, "probe.x.") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "curlset.sh") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || $3 ~ /(^|\/)javac$/ || index($0, "ex-drive.sh")) { print $1 }' | paste -sd' ' -) || l=""
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
# the Compose window's own cleanup: the project's containers and network down with their volumes, and the mongo service's two
# anonymous volumes by the names its container listed (a down -v after a down does not remove them - anchor's window measures it)
cmprm() { local v
  [ -n "$TC0" ] || return 0
  if [ -n "$(dk ps -aq --filter name=^/${PROJ}-mongo-1\$ 2> /dev/null)" ]; then CMPV="$CMPV $(dk inspect -f '{{range .Mounts}}{{.Name}} {{end}}' ${PROJ}-mongo-1 2> /dev/null)"; fi
  if [ -n "$CMPW" ] || [ -n "$(dk ps -aq --filter label=com.docker.compose.project=$PROJ 2> /dev/null)" ] || dk network inspect ${PROJ}_default > /dev/null 2>&1; then
    (cd .harness/compose-run 2> /dev/null && dk compose -p $PROJ down -v > /dev/null 2>&1) || true; fi
  for v in $CMPV; do dk volume inspect "$v" > /dev/null 2>&1 && dk volume rm "$v" > /dev/null 2>&1; done
  dk volume inspect ${PROJ}_data > /dev/null 2>&1 && [ -n "$CMPW" ] && dk volume rm ${PROJ}_data > /dev/null 2>&1
  CMPW=""; CMPV=""; return 0; }
ctrm() { local c; [ -n "$TC0" ] || return 0
  for c in $MNV $MN $RN $CN $HN; do [ -z "$(dk ps -aq --filter name=^/$c\$ 2> /dev/null)" ] || dk rm -fv "$c" > /dev/null 2>&1 || true; done; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid" "$pid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; tcrm; cmprm; ctrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git javap unzip /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|FLYWAY_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|REDIS[A-Z_]*|MONGO[A-Z_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT|COMPOSE_[A-Z_]*)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"

# ---- gates before anything is written: the folder, the links, the pins, the prose, the change, R.250 ---------------------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh xcheck.sql' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk18.py dur8.py logback.xml pg3.sql pg4.sql s818.py src surefire.py tree18.py variants.py' ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe/u18/H18.java probe/x/XMain.java' ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md application.yaml' ] || die "exercise/ holds another file, or misses one"
cmp -s harness/dur8.py ../c8-unit02/harness/dur8.py || die "harness/dur8.py is not the builders' dur8.py as unit 02 shipped it, byte for byte"
cmp -s harness/surefire.py ../c8-unit02/harness/surefire.py || die "harness/surefire.py is not unit 02's, byte for byte"
cmp -s harness/logback.xml ../c8-unit07/harness/logback.xml || die "harness/logback.xml is not unit 07's, byte for byte"
cmp -s harness/src/probe/x/XMain.java ../c7-unit29/harness/src/probe/x/XMain.java || die "harness/src/probe/x/XMain.java is not Course 7 unit 29's, byte for byte"
cmp -s xcheck.sql ../c7-unit39/xcheck.sql || die "xcheck.sql must be Course 7's capstone's, byte for byte (unit 18 moves no JPA mapping)"
[ -L before ] && [ "$(readlink before)" = ../c8-unit17/after ] || die "R.211: before must be a link to ../c8-unit17/after (it points at: $(readlink before 2> /dev/null || echo 'not a link'))"
[ -d after ] && [ ! -L after ] || die "after/ must be this unit's own tree, not a link"
for t in after before; do [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] && die "$t holds a secrets/ or a target/ - never built in place"; true; done
git rev-parse -q --verify '4bc1d1b^{commit}' > /dev/null 2>&1 || die "unit 17's commit 4bc1d1b is not in this repository's history"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree18.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/ ($3): python3 -I harness/tree18.py $dir/ -> $got = receipts.md5's $nm line"; }
pin before-tree before start; pin after-tree after start
U17P=$(awk '$1 == "after-tree" { print $2, $3 }' ../c8-unit17/receipts.md5)
[ "$U17P" = "$(awk '$1 == "before-tree" { print $2, $3 }' receipts.md5)" ] || die "before/'s pin is not unit 17's after-tree line ($U17P)"
echo "  before/'s pin = ../c8-unit17/receipts.md5's after-tree line ($U17P), re-derived by harness/tree18.py"
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c8-tiffinbox 2>&1 || true)
echo "  after/ against ../c8-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor' || echo 'they differ - a later unit moved the anchor; this unit measures after/')"
echo "  after/ against before/ (diff -rq, the files D1 changed or added):"; diff -rq before/ after/ 2>&1 | sed -E 's#^Files before/(.*) and after/.* differ$#    changed: \1#; s#^Only in after/(.*): (.*)$#    new: \1/\2#; s#^Only in before/(.*): (.*)$#    gone: \1/\2#' | sort
[ -z "$(diff -rq before/ after/ 2>&1 | $G '^Only in before/' || true)" ] || die "D1 deletes nothing - a file of before/ is gone from after/"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s818.py harness/dur8.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -2 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
YD=$(diff -r before/ after/ 2>&1 | $G '^>' | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
[ "$YD" = 0 ] || die "R.432: dur8 finds $YD duration word(s) in the lines D1 added (Javadoc, YAML, compose and README lines)"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
DN=$($G -rniwE -- "$DISH" README.md exercise harness after/tiffinbox-web/src/main/java/com/tiffinbox/web/MenuDay.java 2> /dev/null | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|VALUES-PENDING|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or harness: $PH"
! $G -q '^```java$' README.md || die "README.md holds a java block - the code is the anchor's files and the harness's"
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
EXQ="Your turn: the default run keeps no Mongo, yet its log still tries localhost 27017. Make the default run build no MongoClient."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SETUP=$(block exercise/README.md); SOL=$(block exercise/SOLUTION.md)
[ -n "$SETUP" ] && [ -n "$SOL" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
[ "$(diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G -c '^[<>]')" = 2 ] || die "R.196: SOLUTION.md's block must be the README's with one line changed"
printf '%s\n' "$SETUP" | $G -E '(^|[ (])(mvn|java|javac) ' | $G -vqF "perl -e '" && die "exercise/README.md's Java and Maven runs must run under their alarm (R.247)"
printf '%s\n' "$SETUP" | $G -E 'mvn ' | $G -vqF -- '-pl tiffinbox-web -am' && die "R.391: exercise/README.md builds without -pl tiffinbox-web -am"
! printf '%s\n' "$SETUP" | $G -qE '\bdocker\b' || die "the exercise needs no Docker - its block names docker"
printf '%s\n' "$SETUP" | $G -qF 'grep -c 27017' || die "R.196: the exercise is checked by grep -c 27017 on the run's log (and health 200), never by the exit"
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket (docker -H \"\$DH\")"
DK=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -nE '\bdocker (run|exec|rm|ps|port|info|images|volume|image|pull|events|compose|network|restart|logs|stop|start|inspect)\b' | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.344: receipts.sh calls docker without the pinned socket (every call is dk): $DK"
RMF=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) rm( +-[a-z]+)*' | sort -u | paste -sd'|' -)
[ "$RMF" = 'dk rm -fv' ] || die "R.387/R.421: receipts.sh removes a container without its volumes - every removal is dk rm -fv (found: ${RMF:-none})"
RUNP=$($G -v '^ *#' receipts.sh | $G -oE '(dk|docker) run -[^"]*' | $G -vcF -- '--pull never' || true)
[ "$RUNP" = 0 ] || die "R.344: a dk run without --pull never"
MRUN=$($G -v '^ *#' receipts.sh | $G -E '(dk|docker) run ' | $G -F '$MIMG' | $G -vF 'name $MNV ' | $G -vcF 'GLIBC_TUNABLES=$GT' || true)
[ "$MRUN" = 0 ] || die "R.421: a MongoDB container run without GLIBC_TUNABLES (only the labelled no-variable container $MNV may)"
XM=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -cE '(dk|docker)( -H [^ ]+)? exec [^|;]*mongosh' || true)
[ "$XM" = 0 ] || die "R.422: receipts.sh runs mongosh inside a networked container (an exec into the mongod container)"
[ "$($G -v '^ *#' receipts.sh | $G -F 'entrypoint mongosh' | $G -vcF -- '--network none' || true)" = 0 ] || die "R.422: a mongosh container with a network"
[ -z "$($G -rlE 'dropCollection|\.drop\(\)' after/tiffinbox-web/src harness/src || true)" ] || die "R.431: a dropCollection or a drop() - the fill and every reset delete, never drop"
MVA=$($G -v '^ *#' receipts.sh | $G -F 'clean ' | $G -F '$MV' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am"
ST=$(python3 -I -B harness/chk18.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
R250=$(python3 -I -B harness/chk18.py r250 after before) || die "R.250: $(printf '%s\n' "$R250" | $G '^FAIL' | head -2 | paste -sd';' -)"
printf '%s\n' "$R250" | $G -v '^VALUES ' | sed 's/^/  /'
C15=$(python3 -I -B harness/chk18.py c815 README.md "$UP/../../spring-data-beyond-jpa/_briefs/PROMISE-LEDGER-2026-11-17.md") || die "C8-15: $(printf '%s\n' "$C15" | $G '^FAIL' | head -2 | paste -sd';' -)"
printf '%s\n' "$C15" | $G -v '^VALUES ' | sed 's/^/  /'
printf '%s\n' "$ST" "$R250" "$C15" | $G -v '^VALUES ' > .r-gate.tmp
echo "  prose, per sentence (s818, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test): refused 0 over $PROSE · the lines D1 added: dur8 0 · dish names 0 · placeholders 0 · no java block"
echo "  the exercise: the spoken line $EXW words (wc -w); SOLUTION.md's block = the README's with one line changed; the two \"What it prints\" blocks differ (R.196); checked by grep -c 27017 and health; its build -pl tiffinbox-web -am; no docker"
echo "  static: no kill by name; every docker call on the pinned socket, every dk run --pull never, every MongoDB container with GLIBC_TUNABLES but the labelled one; mongosh only with --network none, never an exec into mongod's container (R.422); every container removal dk rm -fv (R.387); no dropCollection (R.431); every Maven build -pl tiffinbox-web -am (R.391)"
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
    gsub(/PT[0-9.]+[SMH]/, "PT<t>")
    gsub(/Total time: +[0-9.:]+ [a-z]+/, "Total time: <t>")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/ObjectId\(.[0-9a-f]+.\)/, "ObjectId(<objectid>)")
    gsub(/polled [0-9]+ times/, "polled <k> times")
    gsub(/pid [0-9]+/, "pid <n>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxWebTest in 3.1 seconds (process running for 4.2)' 'Tests run: 2, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 3.982 s' 'Finished Spring Data repository scanning in 23 ms. Found 0 MongoDB repository interfaces.' 'Root WebApplicationContext: initialization completed in 812 ms' 'Successfully applied 3 migrations (execution time 00:00.026s)' 'Container mongo@sha256:05b3 started in PT0.6S' 'Total time:  12.345 s' 'PROBE hold: pid 41231' "  _id: ObjectId('6aff8b7764dd9c4a7e6e71b9')," "$U/x $HOME/y" | mask)
printf '%s\n' "$MP" | python3 -I -B -c 'import importlib.util,sys,re; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=sys.stdin.read(); sys.exit(1 if m.DUR.search(t) or "PT0" in t or "3.982" in t or "00:00.026" in t or "812" in t or "12.345" in t or "41231" in t or "6aff8b77" in t else 0)' || die "R.432: the mask's self-test - a planted duration line or ObjectId passed it unmasked: $(printf '%s\n' "$MP" | head -2 | paste -sd';' -)"
[ "$(printf '%s\n' "$MP" | tail -1)" = '…/x ~/y' ] || die "the mask's self-test: the folders and the home must be masked"
echo "  mask: its self-test refused the planted Started-in-seconds, Time elapsed, scanning, initialization, execution-time, started-in-PT, Total time, pid and an ObjectId's hex unmasked (R.432, R.430); folders and home masked"
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
# the three tags the shipped compose.yaml names, for anchor's Compose window: present, and on the digests above - else a Compose up would pull
[ "$(iid mongo:8) $(iid postgres:18-alpine) $(iid redis:8-alpine)" = '05b334b0a7a7 77f585114c32 7958cfbb9d15' ] || die "the tags compose.yaml names (mongo:8, postgres:18-alpine, redis:8-alpine) are not on this machine at the course's digests - a Compose up would pull; this script never pulls"
RY0=$(dk images --format '{{.Repository}}' 2> /dev/null | $G -c ryuk || true)
[ "$RY0" = 0 ] || die "R.318: an image named ryuk is on this machine ($RY0) - Ryuk stays off and none is pulled"
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run - remove it with its volumes: docker -H \"\$DH\" rm -fv <id>"
for c in $CN $RN $MN $MNV $HN; do [ -z "$(dk ps -aq --filter name=^/$c\$ 2> /dev/null)" ] || die "a container named $c exists before the run - an interrupted run's? docker -H \"\$DH\" rm -fv $c"; done
[ -z "$(dk ps -aq --filter label=com.docker.compose.project=$PROJ 2> /dev/null)" ] && [ -z "$(dk network ls -q --filter name=^${PROJ} 2> /dev/null)" ] && [ -z "$(dk volume ls -q --filter name=^${PROJ} 2> /dev/null)" ] || die "a $PROJ container, network or volume exists before the run - anchor's Compose window needs none (docker -H \"\$DH\" compose -p $PROJ down, and its volumes by name)"
TC0=1
[ ! -e "$HOME/.testcontainers.properties" ] || die "R.318: ~/.testcontainers.properties exists - this unit's Testcontainers JVMs read a receipt home under .harness/ only"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 18881 18882 18883 20570 20571 20572 20573 20574 20575 20576 20577 20578 20579"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
[ "$(pgrep -x java | wc -l | tr -d ' ')" = 0 ] || die "a java process is running before this script starts one - not this script's; stop it first"
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · $IMG, $RIMG and $MIMG present · mongo:8, postgres:18-alpine and redis:8-alpine on those digests · nothing pulled, ever · images named ryuk $RY0 · Testcontainers containers 0 · no $PROJ container, network or volume · ports 20570-20579, 18881-18883 (and 18425, 8080) free · java processes 0"

# ---- the trees, copied; the builds; the harness -------------------------------------------------------------------------------
rm -rf .harness; mkdir -p .harness/run-h2/secrets/tiffinbox .harness/run-pg/secrets/tiffinbox .harness/hc .harness/hcx .harness/home .harness/run .harness/run-h .harness/compose-run
M2="$PWD/.m2-demo"
[ -d "$M2" ] || die ".m2-demo (a copy of the course's seed, _research/m2-seed-c8-s4) is missing - README.md, The repository"
for a in org/springframework/boot/spring-boot-starter-data-mongodb/4.1.2 org/springframework/boot/spring-boot-starter-data-mongodb-test/4.1.2 org/springframework/data/spring-data-mongodb/5.1.2 org/mongodb/mongodb-driver-sync/5.8.1 org/testcontainers/testcontainers-mongodb/2.0.5; do
  [ -d "$M2/$a" ] || die "$a is not in .m2-demo - the seed lacks it (README.md, The repository)"; done
NF0=$(find "$M2" -type f | wc -l | tr -d ' ')
echo "  the five the change needs, in .m2-demo (ls): spring-boot-starter-data-mongodb 4.1.2 · spring-boot-starter-data-mongodb-test 4.1.2 · spring-data-mongodb 5.1.2 · mongodb-driver-sync 5.8.1 · testcontainers-mongodb 2.0.5 · .m2-demo's files $NF0"
for j in spring-boot-mongodb spring-boot-data-mongodb; do unzip -p "$M2/org/springframework/boot/$j/4.1.2/$j-4.1.2.jar" META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports | $G -E '\.(MongoAutoConfiguration|DataMongoAutoConfiguration|DataMongoRepositoriesAutoConfiguration)$' | sed "s/^/  $j-4.1.2.jar's AutoConfiguration.imports: /"; done
printf '%s\n' 'checks.disable=true' "tinyimage.container.image=$IMG" > .harness/home/.testcontainers.properties
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy before .harness/before; copy after .harness/after; copy after .harness/tests
echo "  the labelled copies of after/ (harness/variants.py), each printed as its diff:"
for v in starteronly healthkey noreset; do python3 -I -B harness/variants.py $v after .harness/$v > .harness/variant-$v.txt || die "variants.py $v failed: $(cat .harness/variant-$v.txt)"
  echo "    $v: $($G -c '^[-+] ' .harness/variant-$v.txt) lines changed:"; $G -E '^[-+] ' .harness/variant-$v.txt | cut -c1-130 | sed 's/^/      /'; done
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE '^\[INFO\] Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
AL="-DargLine=$JL -Dstdout.encoding=UTF-8 -Duser.home=../../home"
for t in before after starteronly healthkey noreset; do
  XG=""; [ $t = after ] && XG=" dependency:build-classpath -Dmdep.outputFile=target/classpath.txt -Dmdep.includeScope=runtime"
  bg "cd .harness/$t && $MV clean package -DskipTests -pl tiffinbox-web -am$XG" .harness/build-$t.log
  [ "$RE" = 0 ] || { tail -20 .harness/build-$t.log >&3; die ".harness/$t did not build offline (exit $RE)"; }; offl .harness/build-$t.log
  bg "cd .harness/$t && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$t.log
  [ "$RE" = 0 ] || die ".harness/$t: the jar's extract failed"; done
$G -q 'spring-boot-docker-compose-4.1.2.jar' .harness/after/tiffinbox-web/target/classpath.txt || die "Maven's class path for after/ lacks spring-boot-docker-compose (the Compose window needs it)"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*\" harness/src/probe/u18/H18.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/: $(head -5 .harness/javac.log)"
mkdir -p .harness/lib-nofly
for j in $(ls .harness/after/$XD/lib); do case $j in flyway-*|spring-boot-flyway-*) ;; *) ln -s ../after/$XD/lib/$j .harness/lib-nofly/$j ;; esac; done
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -parameters -d .harness/hcx -cp \".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*\" harness/src/probe/x/XMain.java" .harness/javac-x.log
[ "$RE" = 0 ] || die "Hibernate's schema probe did not compile: $(head -5 .harness/javac-x.log)"
TF=secrets/tiffinbox/shutdown-token
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/run-h2/$TF) || die "the token was not written"
rsync -a after/ .harness/compose-run/ && mkdir -p .harness/compose-run/secrets/tiffinbox
for d in run-pg after before compose-run; do mkdir -p .harness/$d/secrets/tiffinbox; (umask 077 && cp .harness/run-h2/$TF .harness/$d/$TF) || die "the token was not copied"; done
cmp -s .harness/compose-run/compose.yaml after/compose.yaml || die "the Compose window's compose.yaml is not after/'s"
mv .r-gate.tmp .harness/gate.out 2> /dev/null || true
TOKEN=$(head -1 .harness/run-h2/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
PW=$(openssl rand -hex 16); (umask 077 && printf 'POSTGRES_USER=tiffinbox\nPOSTGRES_PASSWORD=%s\n' "$PW" > .harness/pg.env) || die "the password file was not written"
echo "  built before/'s, after/'s and the three labelled copies' trees offline (mvn -o package -DskipTests -pl tiffinbox-web -am, exit 0, 'Downloaded from' 0; after/'s with Maven's runtime class path written beside it, for the Compose window), extracted their jars, compiled the harness against after/'s; a shutdown token and a PostgreSQL password generated (0600, never printed)"

# ---- helpers -------------------------------------------------------------------------------------------------------------------
vols() { dk volume ls -q 2> /dev/null | wc -l | tr -d ' '; }
mounts() { dk inspect -f '{{range .Mounts}}{{.Type}} {{.Destination}}{{println}}{{end}}' "$1" 2> /dev/null | $G . | sort | paste -sd'|' - | sed 's/|/ · /g'; }
# ms CONTAINER JS: mongosh in a second container of the digest with NO network, sharing CONTAINER's volumes, over mongod's socket (R.422)
ms() { dk run --rm --pull never --network none --volumes-from "$1" -e GLIBC_TUNABLES=$GT --entrypoint mongosh $MIMG --quiet 'mongodb://%2Fdata%2Fdb%2Fmongodb-27017.sock/tiffinbox' --eval "$2" 2>&1; }
mup() { local c=$1 i=0; while [ "$(ms "$c" 'db.version()' | tail -1)" != 8.3.17 ]; do i=$((i + 1)); [ $i -lt 120 ] || die "mongod ($c) did not answer mongosh's db.version() (120 reads)"; sleep 0.25; done; }
startmongo() {
  bg "dk run -d --pull never --name $MN -p 127.0.0.1:20573:27017 -e GLIBC_TUNABLES=$GT $MIMG --unixSocketPrefix /data/db" .harness/docker-run-mongo.log
  [ "$RE" = 0 ] || die "the MongoDB container did not start: $(tail -2 .harness/docker-run-mongo.log)"
  mup $MN
  [ "$(dk port $MN 2> /dev/null | paste -sd'|' -)" = '27017/tcp -> 127.0.0.1:20573' ] || die "the MongoDB container must publish 27017 on 127.0.0.1:20573 alone"; }
rmmongo() { dk rm -fv "$1" > /dev/null 2>&1 || die "the container $1 could not be removed"; }
pgready() { local i=0; while ! dk exec "$1" pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 120 ] || die "PostgreSQL ($1) did not accept connections (120 tries)"; sleep 0.5; done; }
startstores() {
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:20571:5432 --env-file .harness/pg.env $IMG" .harness/docker-run-pg.log
  [ "$RE" = 0 ] || die "the PostgreSQL container did not start: $(tail -2 .harness/docker-run-pg.log)"
  bg "dk run -d --pull never --name $HN -p 127.0.0.1:20576:5432 --env-file .harness/pg.env $IMG -c log_statement=all" .harness/docker-run-pgh.log
  [ "$RE" = 0 ] || die "the harness's PostgreSQL container did not start: $(tail -2 .harness/docker-run-pgh.log)"
  bg "dk run -d --pull never --name $RN -p 127.0.0.1:20572:6379 $RIMG" .harness/docker-run-redis.log
  [ "$RE" = 0 ] || die "the Redis container did not start: $(tail -2 .harness/docker-run-redis.log)"
  startmongo; pgready $CN; pgready $HN
  local i=0; while [ "$(dk exec $RN redis-cli PING 2> /dev/null | tr -d '\r')" != PONG ]; do i=$((i + 1)); [ $i -lt 200 ] || die "Redis did not answer PING"; sleep 0.1; done
  [ "$(dk port $CN | paste -sd'|' -)" = '5432/tcp -> 127.0.0.1:20571' ] && [ "$(dk port $HN | paste -sd'|' -)" = '5432/tcp -> 127.0.0.1:20576' ] && [ "$(dk port $RN | paste -sd'|' -)" = '6379/tcp -> 127.0.0.1:20572' ] || die "a store publishes on another address than 127.0.0.1:<its port>"
  echo "  the stores: $CN (PostgreSQL, 127.0.0.1:20571, TiffinBox's) and $HN (PostgreSQL, 127.0.0.1:20576, the harness's tables, -c log_statement=all) from $IMG; $RN (Redis, 127.0.0.1:20572, no password) from $RIMG; $MN (MongoDB, 127.0.0.1:20573, no auth, -e GLIBC_TUNABLES=$GT, --unixSocketPrefix /data/db) from $MIMG; all --pull never, 127.0.0.1 only; the password from a 0600 file, never printed · volumes now $(vols)"; }
psq() { dk exec "$1" psql -U tiffinbox -d "$2" -qAt -v ON_ERROR_STOP=1 -c "$3" 2>&1 || die "psql failed on $1/$2: $3"; }
pgdb() { psq $CN postgres "drop database if exists $1 with (force)" > /dev/null; psq $CN postgres "create database $1" > /dev/null
  (umask 077 && printf 'jdbc:postgresql://127.0.0.1:20571/%s?user=tiffinbox&password=%s\n' "$1" "$PW" > .harness/run-pg/secrets/tiffinbox/jdbc-url) || die "the URL was not written"
  PGD=$1; echo "  a fresh database on $CN: $1 (psql) · its URL in the config tree (0600, never printed)"; }
flush() { [ "$(dk exec $RN redis-cli FLUSHALL | tr -d '\r')" = OK ] || die "redis-cli FLUSHALL failed"; echo "  redis-cli FLUSHALL (the unit's Redis) -> OK"; }
DEV="--spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20572 --spring.mongodb.uri=mongodb://127.0.0.1:20573/tiffinbox --logging.level.org.mongodb.driver.protocol.command=DEBUG"
cu() { curl -s --noproxy '*' -o .harness/body -w '%{http_code}' "http://127.0.0.1:$1$2" 2> /dev/null || true; }
# tb TREE RUN PORT ARG...: TiffinBox's jar of TREE (java -jar, under its alarm, SIGINT at its default), from .harness/RUN (its config
# tree), in the background (pid); the receipt polls readiness on PORT until 200, or until the JVM is gone (TBUP = 1 or 0)
tb() { local tr=$1 run=$2 port=$3 i=0 c; shift 3
  echo "\$ cd .harness/$run && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -jar ../$tr/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port $*" | mask
  (cd .harness/$run && exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -jar ../$tr/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port "$@") > .harness/tb.log 2>&1 < /dev/null & pid=$!
  TBUP=0; while [ $i -lt 960 ]; do c=$(cu $port /actuator/health/readiness); [ "$c" = 200 ] && { TBUP=1; break; }
    kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  if [ "$TBUP" = 0 ] && kill -0 "$pid" 2> /dev/null; then die "TiffinBox neither answered readiness nor stopped (960 reads)"; fi; }
# tbstop RUN PORT: POST /shutdown with the token (on curl's standard input, never a command line); the JVM's exit = $TBX
tbstop() { local c; c=$(printf 'X-Shutdown-Token: %s\n' "$(head -1 .harness/$1/$TF)" | curl -s --noproxy '*' -o /dev/null -w '%{http_code}' -H @- -X POST "http://127.0.0.1:$2/shutdown" 2> /dev/null || true)
  TBX=0; wait "$pid" || TBX=$?; pid=""
  [ "$(listeners $2)" = 0 ] || die "something still listens on $2 after TiffinBox stopped"
  echo "  POST /shutdown (the token on curl's standard input) -> $c · the JVM's exit $TBX · listening on $2: 0"; }
tbwait() { TBX=0; wait "$pid" || TBX=$?; pid=""; }
NCAP=3
unpub=""; CAPRUN=0
cap() { local nm=$1 i n=$NCAP; shift
  i=1; while [ $i -le $n ]; do CAPRUN=$i; "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    $G -q '^  \*\*\* ' .harness/cap.raw && { cat .harness/cap.raw >&3; die "$nm stopped (above)"; }
    ! $G -qE 'localhost:[0-9]{5}|127\.0\.0\.1:(3|4|5|6)[0-9]{4}' .harness/cap.raw || die "R.319: $nm printed a container's port raw"
    ! $G -qF -- "$PW" .harness/cap.raw || die "$nm printed the PostgreSQL password"
    mask < .harness/cap.raw > ".r-$nm.$i"; cp .harness/cap.raw ".harness/raw-$nm.$i"; i=$((i + 1)); done
  CHH=$(md5 -q ".r-$nm.1")
  i=2; while [ $i -le $n ]; do [ "$CHH" = "$(md5 -q ".r-$nm.$i")" ] || die "$nm drifts across $n runs (diff .r-$nm.1 .r-$nm.$i)"; i=$((i + 1)); done
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; CAPN=$n; }
pub() { local nm=$1 h p; h=$(md5 -q ".r-$nm.out"); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-9s md5 %s  %s/%s  (no published hash)\n' "$nm" "$h" "$CAPN" "$CAPN"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-9s md5 %s  %s/%s  = published\n' "$nm" "$h" "$CAPN" "$CAPN"
  else printf '  %-9s md5 %s  %s/%s  DIFFERS from the published %s\n' "$nm" "$h" "$CAPN" "$CAPN" "$p"; die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
VALS=""
chk() { local nm=$1 o e=0; shift
  o=$(python3 -I -B harness/chk18.py "$nm" "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk18 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -5 >&3; die "$nm: its check failed (harness/chk18.py)"; }
  VALS="$VALS${VALS:+ · }$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }
dockeq() { local v i c n
  i=$(dk images -q --no-trunc 2> /dev/null | sort -u | paste -sd' ' -); v=$(vols)
  c=$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null | wc -l | tr -d ' ')
  n=$(find "$M2" -type f | wc -l | tr -d ' ')
  [ "$i" = "$IMGS0" ] || die "$1: the images moved - nothing may be pulled"
  [ "$v" = "$VOL0" ] || die "R.322: $1: the volume count is $v, not $VOL0"
  [ "$c" = 0 ] || die "$1: a Testcontainers container is still there after the run ($c)"
  [ "$n" = "$NF0" ] || die "$1: .m2-demo gained files ($NF0 -> $n) - offline: no"
  echo "  after it: images $NI0 (the same list) · volumes $VOL0 · Testcontainers containers 0 · .m2-demo's files unchanged"; }
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
# the IT's container, while mvn verify runs: Docker's own list of it, polled on a count (R.412) - the binding R.454 asks about
tcpoll() { local i=0 l=""; : > .harness/tc-ports.txt
  while kill -0 "$1" 2> /dev/null && [ $i -lt 2400 ]; do
    l=$(dk ps --no-trunc --filter label=org.testcontainers=true --filter ancestor=$MIMG --format '{{.Ports}} · its command {{.Command}}' 2> /dev/null | sed -n 1p)
    [ -n "$l" ] && { printf '%s\n' "$l" > .harness/tc-ports.txt; break; }; sleep 0.1; i=$((i + 1)); done; }

# ---- the captures --------------------------------------------------------------------------------------------------------------
tests() { echo "-- the tests: after/ copied to .harness/tests; mvn package with Maven's DOCKER_HOST pointed at nothing (tcp://127.0.0.1:1), offline:"
  rm -rf .harness/tests/tiffinbox-web/target .harness/tests/tiffinbox-core/target
  MPRE="env DOCKER_HOST=tcp://127.0.0.1:1"; mvnrun .harness/tests package "\"$AL\" clean package -pl tiffinbox-web -am"; MPRE=""
  echo "  Surefire's reports, $SR:"; pgr .harness/tests/$SR; echo "  $SRI: $( [ -d .harness/tests/$SRI ] && echo present || echo 'absent - no container test ran')"
  results .harness/package.log
  echo "  the package log (RE-MEASURE 13): lines naming 27017 $($G -c 27017 .harness/package.log || true) · lines naming mongo (any case) $($G -ci mongo .harness/package.log || true)"
  echo "-- then mvn verify, the anchor's recipe (DOCKER_HOST on the pinned socket, Ryuk off - TESTCONTAINERS_RYUK_DISABLED=true, a receipt home), offline:"
  rm -rf .harness/tests/tiffinbox-web/target .harness/tests/tiffinbox-core/target
  local e=0 n
  echo "\$ cd .harness/tests && $MV \"$AL\" clean verify -pl tiffinbox-web -am"
  (cd .harness/tests && eval "$MV \"$AL\" clean verify -pl tiffinbox-web -am") > .harness/verify.log 2>&1 < /dev/null & mpid=$!
  tcpoll "$mpid"; wait "$mpid" || e=$?; mpid=""
  [ "$e" != 142 ] || die "verify: Maven's alarm fired (exit 142, cap 600 - R.247)"
  n=$($G -cE '^\[INFO\] Download(ing|ed) from ' .harness/verify.log || true)
  echo "  exit $e · $($G -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/verify.log || echo 'no BUILD line') · offline: $( [ "$n" = 0 ] && echo yes || echo "no - $n lines say Maven downloaded") · its alarm's cap: 600 (R.247)"
  [ "$n" = 0 ] || die "verify: Maven downloaded"
  dockeq verify
  echo "  the IT's MongoDB container while verify ran, Docker's own list (dk ps, polled on a count): Ports $(sed 's/[[:space:]]*$//' .harness/tc-ports.txt)"
  echo "  Surefire's reports, $SR:"; pgr .harness/tests/$SR
  echo "  Surefire's reports, $SRI:"; pgr .harness/tests/$SRI
  results .harness/verify.log
  $G -E '^MONGO IT ' .harness/verify.log | sed 's/^/  /'
  echo "  the verify log: 'Creating container for image' $($G -c 'Creating container for image: ' .harness/verify.log || true) · 'Pulling' $($G -c 'Pulling' .harness/verify.log || true) · lines naming docker compose $($G -ci 'docker compose' .harness/verify.log || true) · Testcontainers containers after it: $(dk ps -aq --filter label=org.testcontainers=true | $G -c . || true)"
  echo "  mongosh named in the verify log: $($G -c mongosh .harness/verify.log || true) · --replSet named in the IT container's command: $($G -c -- '--replSet' .harness/tc-ports.txt || true)"; }
image() { local i=0 s
  echo "-- the image, by its digest, on this machine (dk image inspect):"
  dk image inspect --format '  Id {{.Id}} · Size {{.Size}} · Volumes {{json .Config.Volumes}} · Cmd {{json .Config.Cmd}} · Entrypoint {{json .Config.Entrypoint}}' $MIMG
  echo "  images on this machine: $(dk images -q --no-trunc | sort -u | wc -l | tr -d ' ') · the digest among them: $(dk images -q --no-trunc | $G -c "${MIMG#mongo@}" || true)"
  echo "-- a container WITHOUT the variable, labelled ($MNV, 127.0.0.1:20573, --pull never, --unixSocketPrefix /data/db): volumes before it $(vols)"
  bg "dk run -d --pull never --name $MNV -p 127.0.0.1:20573:27017 $MIMG --unixSocketPrefix /data/db" .harness/docker-run-nov.log
  [ "$RE" = 0 ] || die "the no-variable container could not be created: $(tail -2 .harness/docker-run-nov.log)"
  while [ "$(dk inspect -f '{{.State.Status}}' $MNV 2> /dev/null)" != exited ]; do i=$((i + 1)); [ $i -lt 400 ] || die "$MNV did not stop"; sleep 0.1; done
  echo "  its state: $(dk inspect -f '{{.State.Status}}, exit code {{.State.ExitCode}}' $MNV) · volumes now $(vols) · its Mounts: $(mounts $MNV)"
  echo "  its fatal line (\"s\":\"F\"), every field but the time:"
  dk logs $MNV 2>&1 | $G '"s":"F"' | python3 -I -c 'import sys,json
for l in sys.stdin:
    d = json.loads(l); d.pop("t", None); print("   ", json.dumps(d, ensure_ascii=False))'
  rmmongo $MNV; echo "  dk rm -fv $MNV · volumes $(vols)"
  echo "-- the unit's container, WITH -e GLIBC_TUNABLES=$GT (--pull never, 127.0.0.1:20573, --unixSocketPrefix /data/db):"
  startmongo
  echo "  its state: $(dk inspect -f '{{.State.Status}}' $MN) · volumes now $(vols) · its Mounts: $(mounts $MN)"
  echo "  its startup warning id 8718500, the message whole:"
  dk logs $MN 2>&1 | $G '"id":8718500' | python3 -I -c 'import sys,json
for l in sys.stdin:
    d = json.loads(l); print("    \"s\":\"%s\" \"c\":\"%s\" \"id\":%s \"msg\":\"%s\"" % (d["s"], d["c"], d["id"], d["msg"]))'
  echo "  mongosh, in a container of the digest with no network (--network none, --volumes-from $MN, mongod's socket):"
  echo "    db.version() -> $(ms $MN 'db.version()')"
  echo "    that container's interfaces (its /proc/net/dev, read by mongosh): $(ms $MN 'print(require("fs").readFileSync("/proc/net/dev","utf8").split("\n").slice(2).map(l=>l.split(":")[0].trim()).filter(x=>x).join(","))')"
  echo "    listDatabases -> $(ms $MN 'db.adminCommand({listDatabases:1}).databases.map(d=>d.name).join(",")')"
  echo "  mongod --version, in a container of the digest with no network: $(dk run --rm --pull never --network none -e GLIBC_TUNABLES=$GT --entrypoint mongod $MIMG --version 2>&1 | sed -n 1p)"
  rmmongo $MN; echo "  dk rm -fv $MN · volumes $(vols)"; }
anchor() { local f l
  cat .harness/anchor-tests.out
  echo "-- the jar's libraries (ls lib | wc -l), before/ and after/, and the jars after/ gained or lost (comm, by name):"
  for t in before after; do echo "  $t/: $(ls .harness/$t/$XD/lib | wc -l | tr -d ' ') libraries"; done
  echo "  gained: $(comm -13 <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | paste -sd' ' -) · lost: $(comm -23 <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c . || true)"
  echo "  the version lines off the jar names: $(ls .harness/after/$XD/lib | $G -xE 'spring-boot-4\.1\.2\.jar|spring-data-mongodb-5\.1\.2\.jar|mongodb-driver-sync-5\.8\.1\.jar|spring-data-redis-4\.1\.2\.jar|spring-data-jpa-4\.1\.2\.jar' | paste -sd' ' -)"
  echo "-- after/ under the profile dev, on PostgreSQL 18.6 + Redis 8.10.3 + MongoDB 8.3.17 (the three containers, by the digest), one start on a fresh database and an emptied Redis, Compose off:"
  echo "  the overrides: $DEV (the datasource from the config tree, the password never on a command line)"
  flush; pgdb u18anchor
  echo "  mongosh (no network): db.setProfilingLevel(0); db.system.profile.drop(); db.setProfilingLevel(2) -> $(ms $MN 'db.setProfilingLevel(0); db.system.profile.drop(); print(db.setProfilingLevel(2).ok)')"
  tb after run-pg 20570 $DEV
  [ "$TBUP" = 1 ] || { tail -20 .harness/tb.log | mask >&3; die "after/ under dev did not start"; }
  echo "  the start's lines:"
  $G -oE 'Multiple Spring Data modules found, entering strict repository configuration mode|Found [0-9]+ (JPA|JDBC|Redis|MongoDB) repository interfaces?|HHH000001: Hibernate ORM core version [^ ]+|Database: jdbc:postgresql://[^ ]+ \(PostgreSQL [0-9.]+\)|tiffinbox +: (orders cooked|kitchen value): +[0-9]+|Command "[a-zA-Z]+" started on database "[a-z]+"' .harness/tb.log | sed -E 's#jdbc:postgresql://127\.0\.0\.1:20571/[a-z0-9]+#jdbc:postgresql://<the unit'"'"'s>/<db>#; s/^tiffinbox +: /tiffinbox: /' | sort | uniq -c | sed -E 's/^ +([0-9]+) /    (x\1) /'
  echo "  the MongoClient line Boot logs (its settings, masked whole - the dur8 list): $($G -c 'MongoClient with metadata' .harness/tb.log || true) line"
  echo "  system.profile on tiffinbox.menu after the start (mongosh, no network) - the ops in order, each with its count of documents:"
  ms $MN 'db.system.profile.find({ns:"tiffinbox.menu"}).sort({$natural:1}).toArray().forEach(d=>print("    op " + d.op + (d.ninserted !== undefined ? ", ninserted " + d.ninserted : "") + (d.op === "remove" ? ", the filter " + JSON.stringify(d.command.q) : "")))'
  echo "  mongosh: db.setProfilingLevel(0) -> $(ms $MN 'print(db.setProfilingLevel(0).ok)') · db.menu.countDocuments() -> $(ms $MN 'db.menu.countDocuments()') · listDatabases -> $(ms $MN 'db.adminCommand({listDatabases:1}).databases.map(d=>d.name).join(",")')"
  for l in /menu/day-19 /menu/day-31 /actuator/health /dashboard /kitchen /leaderboard; do f=$(cu 20570 $l)
    case $l in /dashboard) echo "  GET $l -> $f" ;; *) echo "  GET $l -> $f $(tr -d '\n' < .harness/body | cut -c1-400)" ;; esac; done
  echo "  the stores' own versions: mongosh db.version() $(ms $MN 'db.version()') · redis-cli INFO server $(dk exec $RN redis-cli INFO server | tr -d '\r' | $G '^redis_version:') · psql show server_version $(psq $CN postgres 'show server_version')"
  tbstop run-pg 20570
  psq $CN postgres "drop database u18anchor with (force)" > /dev/null
  compose; }
# the Compose window (RE-MEASURE 2, 3, 14): after/ under "dev" with Boot's Docker Compose support ON, the shipped compose.yaml, project tiffinbox-dev
compose() { local v mv e=0 vb
  vb=$(vols)
  echo "-- the Compose window: after/ under dev, Boot's Docker Compose support on, the shipped compose.yaml (cmp: after/'s), from .harness/compose-run; no spring.* address key - Boot hands them over:"
  for p in 18881 18882 18883; do [ "$(listeners $p)" = 0 ] || die "$p is bound before the Compose window"; done
  [ -z "$(dk volume ls -q --filter name=^$PROJ)" ] && [ -z "$(dk network ls -q --filter name=^$PROJ)" ] || die "a $PROJ volume or network exists before the window"
  echo "  before it: listening on 18881-18883 0 · $PROJ volumes 0 · $PROJ networks 0 · volumes $(vols) · mongo:8 postgres:18-alpine redis:8-alpine present, on the digests (checked at the start)"
  echo "\$ cd .harness/compose-run && DOCKER_HOST=\$DH perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -cp \"<after/'s classes>:<Maven's runtime class path for after/>\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=20570 --spring.profiles.active=dev --logging.level.org.mongodb.driver.protocol.command=DEBUG"
  CMPW=1
  (cd .harness/compose-run && DOCKER_HOST="$DH" exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -cp "../after/tiffinbox-web/target/classes:$(cat ../after/tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=20570 --spring.profiles.active=dev --logging.level.org.mongodb.driver.protocol.command=DEBUG) > .harness/compose.log 2>&1 < /dev/null & pid=$!
  local i=0 c TBUP=0; while [ $i -lt 960 ]; do c=$(cu 20570 /actuator/health/readiness); [ "$c" = 200 ] && { TBUP=1; break; }; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  [ "$TBUP" = 1 ] || { tail -20 .harness/compose.log | mask >&3; die "after/ under dev with Compose did not start"; }
  CMPV=$(dk inspect -f '{{range .Mounts}}{{.Name}} {{end}}' ${PROJ}-mongo-1 2> /dev/null)
  echo "  the project's containers: $(dk ps --filter label=com.docker.compose.project=$PROJ --format '{{.Names}} {{.Ports}}' | sort | paste -sd'|' -)"
  echo "  the mongo service's container: GLIBC_TUNABLES $(dk inspect -f '{{range .Config.Env}}{{println .}}{{end}}' ${PROJ}-mongo-1 | $G -c '^GLIBC_TUNABLES=glibc.pthread.rseq=1$') · MONGO_INITDB_DATABASE=tiffinbox $(dk inspect -f '{{range .Config.Env}}{{println .}}{{end}}' ${PROJ}-mongo-1 | $G -c '^MONGO_INITDB_DATABASE=tiffinbox$') · its command $(dk inspect -f '{{json .Config.Cmd}}' ${PROJ}-mongo-1) · its Mounts: $(mounts ${PROJ}-mongo-1) · volumes now $(vols)"
  echo "  the start's lines: $($G -oE 'Command "(delete|insert)" started on database "[a-z]+"|tiffinbox +: orders cooked: +[0-9]+' .harness/compose.log | sed -E 's/^tiffinbox +: /tiffinbox: /' | sort | uniq -c | sed -E 's/^ +//' | paste -sd'|' -)"
  echo "  GET /menu/day-19 -> $(cu 20570 /menu/day-19) $(tr -d '\n' < .harness/body | cut -c1-80)…"
  echo "  mongosh (no network, --volumes-from ${PROJ}-mongo-1): listDatabases -> $(ms ${PROJ}-mongo-1 'db.adminCommand({listDatabases:1}).databases.map(d=>d.name).join(",")') · db.menu.countDocuments() on tiffinbox -> $(ms ${PROJ}-mongo-1 'db.menu.countDocuments()') · on test -> $(ms ${PROJ}-mongo-1 'db.getSiblingDB("test").menu.countDocuments()')"
  tbstop compose-run 20570
  echo "  after TiffinBox stopped (Boot's own compose stop): the project's containers $(dk ps -a --filter label=com.docker.compose.project=$PROJ --format '{{.Names}} {{.State}}' | sort | paste -sd'|' -) · volumes $(vols) · $PROJ volumes by name: $(dk volume ls -q --filter name=^$PROJ | paste -sd' ' -) · the mongo service's two (by its Mounts): $(for v in $CMPV; do dk volume inspect $v > /dev/null 2>&1 && echo present || echo gone; done | paste -sd' ' -)"
  echo "\$ cd .harness/compose-run && docker -H \"\$DH\" compose -p $PROJ down"
  (cd .harness/compose-run && dk compose -p $PROJ down) > .harness/compose-down.log 2>&1 || die "compose down failed: $(tail -2 .harness/compose-down.log)"
  echo "  then: the project's containers $(dk ps -aq --filter label=com.docker.compose.project=$PROJ | $G -c . || true) · its networks $(dk network ls -q --filter name=^$PROJ | $G -c . || true) · volumes $(vols) · $PROJ volumes by name: $(dk volume ls -q --filter name=^$PROJ | paste -sd' ' -) · the mongo service's two: $(for v in $CMPV; do dk volume inspect $v > /dev/null 2>&1 && echo present || echo gone; done | paste -sd' ' -)"
  echo "\$ cd .harness/compose-run && docker -H \"\$DH\" compose -p $PROJ down -v"
  (cd .harness/compose-run && dk compose -p $PROJ down -v) > .harness/compose-downv.log 2>&1 || die "compose down -v failed: $(tail -2 .harness/compose-downv.log)"
  echo "  then: volumes $(vols) · $PROJ volumes by name: $(dk volume ls -q --filter name=^$PROJ | $G -c . || true) · the mongo service's two: $(for v in $CMPV; do dk volume inspect $v > /dev/null 2>&1 && echo present || echo gone; done | paste -sd' ' -)"
  for v in $CMPV; do dk volume rm "$v" > /dev/null 2>&1 || die "the volume could not be removed"; done
  CMPW=""; CMPV=""
  [ "$(vols)" = "$vb" ] || die "after the Compose window the volume count is $(vols), not $vb (the count before it)"
  echo "  the receipt removes the mongo service's two by the names its container listed (dk volume rm): volumes $(vols) = before the window · listening on 18881-18883: $(( $(listeners 18881) + $(listeners 18882) + $(listeners 18883) ))"; }
document() {
  echo "-- the shipped menu, read off after/'s MenuDay by the harness (RE-MEASURE 4):"
  h18 days
  echo "-- the stored document, mongosh (no network) - day-19 as after/'s start inserted it under dev:"
  ms $MN 'printjson(db.menu.findOne({_id: "day-19"}))' | sed 's/^/    /'
  echo "  mongosh: its keys $(ms $MN 'print(Object.keys(db.menu.findOne({_id: "day-19"})).join(","))') · typeof _id $(ms $MN 'print(typeof db.menu.findOne({_id: "day-19"})._id)') · _class $(ms $MN 'print(db.menu.findOne({_id: "day-19"})._class)')"
  echo "-- beside it, Java - the harness's MongoTemplate (probe.u18.H18) over the same MongoDB:"
  h18 read
  echo "-- a null id, the harness's (probe.u18.H18 nullid - labelled; the collection holds $(ms $MN 'db.menu.countDocuments()') before it):"
  h18 nullid
  echo "  mongosh: the document whose _id is an ObjectId: $(ms $MN 'const d=db.menu.findOne({_id:{$type:"objectId"}}); print("typeof _id " + typeof d._id + " · an ObjectId " + (d._id instanceof ObjectId) + " · its keys " + Object.keys(d).join(",") + " · _class " + d._class)')"
  echo "    printjson(_id): $(ms $MN 'printjson(db.menu.findOne({_id:{$type:"objectId"}})._id)')"
  echo "  mongosh: db.menu.deleteMany({_id: {\$type: \"objectId\"}}) -> deletedCount $(ms $MN 'print(db.menu.deleteMany({_id:{$type:"objectId"}}).deletedCount)') · countDocuments() $(ms $MN 'db.menu.countDocuments()')"; }
HJ() { printf '%s' "cd .harness/run-h && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -Dlogback.configurationFile=../../harness/logback.xml -Dh18.port=20573 -cp \"../hc:../after/$XD/tiffinbox-web-1.0.0.jar:../after/$XD/lib/*\" probe.u18.H18 $1"; }
h18() { local c e=0; c=$(HJ "$1")
  (eval "$c") > .harness/h.log 2>&1 < /dev/null & mpid=$!; wait "$mpid" || e=$?; mpid=""
  [ "$1" = sql4 ] || [ "$1" = sql3 ] || { echo "\$ $c" | sed 's#\.\./\.\./harness#…/harness#' | mask; $G '^PROBE ' .harness/h.log | sed 's/^/  /'
    echo "  its exit $e · its log, every line but its PROBE lines: $($G -vc '^PROBE ' .harness/h.log || true) · lines naming an Exception $($G -cE '[A-Za-z]+Exception\b' .harness/h.log || true)"; }
  cat .harness/h.log >> .harness/h-all.log
  [ "$e" = 0 ] || die "the harness JVM exited $e ($1): $(tail -3 .harness/h.log | paste -sd';' -)"; }
pgload() { local db=$1
  psq $HN postgres "drop database if exists $db with (force)" > /dev/null; psq $HN postgres "create database $db" > /dev/null
  h18 sql4; cp .harness/h.log .harness/sql4.sql; h18 sql3; cp .harness/h.log .harness/sql3.sql
  cat harness/pg4.sql .harness/sql4.sql harness/pg3.sql .harness/sql3.sql | dk exec -i $HN psql -U tiffinbox -d $db -q -v ON_ERROR_STOP=1 > .harness/pgload.log 2>&1 || die "the harness's tables did not load: $(tail -2 .harness/pgload.log)"
  echo "  the harness's PostgreSQL ($HN, 20576), a fresh database $db: harness/pg4.sql and harness/pg3.sql, then the INSERTs probe.u18.H18 printed from MenuDay.forDays(30) (sql4 $($G -c '^INSERT' .harness/sql4.sql) lines, sql3 $($G -c '^INSERT' .harness/sql3.sql) lines) · rows: f4.menu $(psq $HN $db 'select count(*) from f4.menu') · f4.menu_item $(psq $HN $db 'select count(*) from f4.menu_item') · f4.allergen $(psq $HN $db 'select count(*) from f4.allergen') · f4.item_allergen $(psq $HN $db 'select count(*) from f4.item_allergen') · f3.item_allergen $(psq $HN $db 'select count(*) from f3.item_allergen')"; }
Q4="SELECT m.id, i.name, i.price, a.name FROM f4.menu m JOIN f4.menu_item i ON i.menu_id = m.id JOIN f4.item_allergen ia ON ia.item_id = i.id JOIN f4.allergen a ON a.id = ia.allergen_id WHERE m.id = 'day-19' ORDER BY i.id, a.name"
Q3="SELECT m.id, i.name, i.price, ia.allergen FROM f3.menu m JOIN f3.menu_item i ON i.menu_id = m.id JOIN f3.item_allergen ia ON ia.item_id = i.id WHERE m.id = 'day-19' ORDER BY i.id, ia.allergen"
# marked DB TAG SQL: SQL between two marker statements; PostgreSQL's own log between them: the statement lines, counted
marked() { local db=$1 tag=$2 q=$3
  psq $HN $db "SELECT 'MARK-A-$tag-$CAPRUN'" > /dev/null
  dk exec $HN psql -U tiffinbox -d $db -At -v ON_ERROR_STOP=1 -c "$q" > .harness/q.out 2>&1 || die "psql: $q"
  psq $HN $db "SELECT 'MARK-B-$tag-$CAPRUN'" > /dev/null
  dk logs $HN 2>&1 | awk -v a="'MARK-A-$tag-$CAPRUN'" -v b="'MARK-B-$tag-$CAPRUN'" 'index($0, a) { f = 1; next } index($0, b) { exit } f' > .harness/pglog.txt
  MST=$($G -c 'statement: ' .harness/pglog.txt || true); MJ=$($G 'statement: ' .harness/pglog.txt | $G -o '\bJOIN\b' | $G -c . || true); }
oneread() {
  echo "-- one read of one whole menu, MongoDB (the store after/'s start filled under dev):"
  echo "  mongosh (no network): db.setProfilingLevel(0); db.system.profile.drop(); db.setProfilingLevel(2) -> $(ms $MN 'db.setProfilingLevel(0); db.system.profile.drop(); print(db.setProfilingLevel(2).ok)')"
  h18 read
  echo "  system.profile, mongosh (no network) - every op on tiffinbox.menu since the reset:"
  ms $MN 'const p=db.system.profile.find({ns:"tiffinbox.menu"}).toArray(); print("    ops " + p.length); p.forEach(d=>print("    op " + d.op + " · ns " + d.ns + " · command " + Object.keys(d.command)[0] + " · filter " + JSON.stringify(d.command.filter) + " · nreturned " + d.nreturned))'
  echo "  mongosh: db.setProfilingLevel(0) -> $(ms $MN 'print(db.setProfilingLevel(0).ok)')"
  echo "-- the same menu in PostgreSQL - the harness's tables, labelled, from the same thirty menus:"
  pgload u18read
  echo "  the four tables (menu, menu_item, allergen, item_allergen) - day-19, between two marker statements (log_statement=all):"
  echo "    \$ psql -At -c \"$Q4\""
  marked u18read four "$Q4"
  sed 's/^/      /' .harness/q.out
  echo "    rows (psql -At | wc -l): $(wc -l < .harness/q.out | tr -d ' ') · PostgreSQL's log between the markers: statements $MST · JOIN in it $MJ"
  echo "  the three tables, labelled (menu, menu_item, item_allergen with the allergen as text) - the same read:"
  echo "    \$ psql -At -c \"$Q3\""
  marked u18read three "$Q3"
  sed 's/^/      /' .harness/q.out
  echo "    rows (psql -At | wc -l): $(wc -l < .harness/q.out | tr -d ' ') · PostgreSQL's log between the markers: statements $MST · JOIN in it $MJ"
  psq $HN postgres "drop database u18read with (force)" > /dev/null; }
rename() { local q
  echo "-- the rename, MongoDB: soy -> soya on every item of every menu (the allergen every VEGAN item carries):"
  h18 refill
  echo "  mongosh (no network): db.setProfilingLevel(0); db.system.profile.drop(); db.setProfilingLevel(2) -> $(ms $MN 'db.setProfilingLevel(0); db.system.profile.drop(); print(db.setProfilingLevel(2).ok)') · countDocuments({\"items.allergens\": \"soy\"}) before -> $(ms $MN 'db.menu.countDocuments({"items.allergens":"soy"})')"
  h18 rename=soy:soya
  echo "  system.profile, mongosh (no network) - every op on tiffinbox.menu since the reset:"
  ms $MN 'const p=db.system.profile.find({ns:"tiffinbox.menu", op:{$ne:"command"}}).toArray(); print("    ops " + p.length); p.forEach(d=>print("    op " + d.op + " · ns " + d.ns + " · nMatched " + d.nMatched + " · nModified " + d.nModified))'
  echo "  mongosh: db.setProfilingLevel(0) -> $(ms $MN 'print(db.setProfilingLevel(0).ok)') · countDocuments({\"items.allergens\": \"soya\"}) -> $(ms $MN 'db.menu.countDocuments({"items.allergens":"soya"})') · countDocuments({\"items.allergens\": \"soy\"}) -> $(ms $MN 'db.menu.countDocuments({"items.allergens":"soy"})') · countDocuments() -> $(ms $MN 'db.menu.countDocuments()')"
  echo "-- the same rename in PostgreSQL - the harness's tables, labelled:"
  pgload u18ren
  q="UPDATE f4.allergen SET name = 'soya' WHERE name = 'soy'"
  echo "  the four tables: \$ psql -c \"$q\" -> $(dk exec $HN psql -U tiffinbox -d u18ren -v ON_ERROR_STOP=1 -c "$q" 2>&1 | tr -d '\r')"
  echo "    the menus that list soya now, through the joins (count(DISTINCT m.id)): $(psq $HN u18ren "SELECT count(DISTINCT m.id) FROM f4.menu m JOIN f4.menu_item i ON i.menu_id = m.id JOIN f4.item_allergen ia ON ia.item_id = i.id JOIN f4.allergen a ON a.id = ia.allergen_id WHERE a.name = 'soya'") · that list soy: $(psq $HN u18ren "SELECT count(DISTINCT m.id) FROM f4.menu m JOIN f4.menu_item i ON i.menu_id = m.id JOIN f4.item_allergen ia ON ia.item_id = i.id JOIN f4.allergen a ON a.id = ia.allergen_id WHERE a.name = 'soy'")"
  q="UPDATE f3.item_allergen SET allergen = 'soya' WHERE allergen = 'soy'"
  echo "  the three tables, labelled (one row per item and allergen, the name as text): \$ psql -c \"$q\" -> $(dk exec $HN psql -U tiffinbox -d u18ren -v ON_ERROR_STOP=1 -c "$q" 2>&1 | tr -d '\r')"
  echo "    the menus that list soya now (count(DISTINCT m.id)): $(psq $HN u18ren "SELECT count(DISTINCT m.id) FROM f3.menu m JOIN f3.menu_item i ON i.menu_id = m.id JOIN f3.item_allergen ia ON ia.item_id = i.id WHERE ia.allergen = 'soya'")"
  psq $HN postgres "drop database u18ren with (force)" > /dev/null
  echo "  no exception anywhere: lines naming an Exception or ERROR in the harness JVM's log $($G -cE 'Exception|ERROR' .harness/h.log || true) · in PostgreSQL's psql answers $($G -cE 'ERROR' .harness/pgload.log || true)"
  echo "-- the harness puts the shipped menu back (soy):"
  h18 refill; }
absent() {
  echo "-- after/ under the profile dev, PostgreSQL up (20571), Redis up (20572), MongoDB ABSENT - the address points at 20577, where nothing listens: $(listeners 20577)"
  echo "  the key's name, off Boot 4.1.2's metadata (spring-boot-mongodb-4.1.2.jar): $(unzip -p .harness/after/$XD/lib/spring-boot-mongodb-4.1.2.jar META-INF/spring-configuration-metadata.json | python3 -I -c 'import json,sys; d=json.load(sys.stdin); print(" · ".join(p["name"] + (" (deprecated, replacement " + p["deprecation"].get("replacement","none") + ")" if "deprecation" in p else "") for p in d["properties"] if p["name"] in ("spring.mongodb.uri","spring.data.mongodb.uri")))')"
  flush; pgdb u18absent
  tb after run-pg 20570 $(printf '%s\n' "$DEV" | sed 's#mongodb://127.0.0.1:20573/#mongodb://127.0.0.1:20577/#')
  [ "$TBUP" = 0 ] || die "after/ under dev started with MongoDB absent"
  tbwait
  echo "  the JVM's exit: $TBX · GET /actuator/health on 20570 -> $(cu 20570 /actuator/health) · listening on 20570: $(listeners 20570)"
  echo "  the log's phrases, each counted: Error creating bean with name 'tiffinBoxServer' $($G -c "Error creating bean with name 'tiffinBoxServer'" .harness/tb.log || true) · DataAccessResourceFailureException $($G -c DataAccessResourceFailureException .harness/tb.log || true) · MongoTimeoutException $($G -c MongoTimeoutException .harness/tb.log || true) · Application run failed $($G -c 'Application run failed' .harness/tb.log || true)"
  echo "  the bean the log names first: $($G -oE "Error creating bean with name '[A-Za-z]+'" .harness/tb.log | head -1) · the driver's server-selection lines: masked whole, never printed (the dur8 list)"
  psq $CN postgres "drop database u18absent with (force)" > /dev/null; }
dfl() { local tr=$1
  DOCKER_HOST=tcp://127.0.0.1:1 tb $tr run-h2 20570 --management.endpoints.web.exposure.include=health,prometheus,beans
  [ "$TBUP" = 1 ] || { tail -20 .harness/tb.log | mask >&3; die "$tr's default run did not start"; }
  echo "  GET /actuator/health -> $(cu 20570 /actuator/health) $(tr -d '\n' < .harness/body | cut -c1-200)"
  echo "  GET /menu/day-19 -> $(cu 20570 /menu/day-19) · GET /dashboard -> $(cu 20570 /dashboard) · /actuator/beans: a bean named menus $(cu 20570 /actuator/beans > /dev/null; $G -o '"menus"' .harness/body | $G -c . || true) · a MongoClient bean $($G -oE '"(mongo|mongoClient)"' .harness/body | $G -c . || true)"
  tbstop run-h2 20570
  local n7 nm; n7=$($G -c 27017 .harness/tb.log || true); nm=$($G -ci mongo .harness/tb.log || true); echo "$tr $n7 $nm" >> .harness/n27017.txt
  if [ "$tr" != after ]; then [ "$n7" -gt 0 ] && n7='more than 0'; [ "$nm" -gt 0 ] && nm='more than 0'; fi
  echo "  its log: lines naming 27017 $n7 · lines naming mongo, any case $nm · of them, Boot's MongoClient settings line (its settings masked whole, the dur8 list) $( [ "$($G 27017 .harness/tb.log | $G -c 'MongoClient with metadata' || true)" = 0 ] && echo 0 || echo 'one or more') and the driver's monitor line (Exception in monitor thread while connecting to server localhost, port 27017) $( [ "$($G -c 'Exception in monitor thread while connecting to server localhost:27017' .harness/tb.log || true)" = 0 ] && echo 0 || echo 'one or more')"; }
default() {
  echo "-- after/ with no profile (TiffinBox's default run): H2 in memory, Docker at nothing (DOCKER_HOST=tcp://127.0.0.1:1), MongoDB absent; one JVM; /actuator/beans exposed for this run (a command-line override, the one beside the port):"
  dfl after
  echo "-- the labelled copy starteronly (harness/variants.py: after/ without application.yaml's exclude), the same run:"
  dfl starteronly
  echo "-- the labelled copy healthkey (harness/variants.py: after/ without the exclude, with management.health.mongodb.enabled: false), the same run:"
  dfl healthkey
  echo "-- the 18 under mvn -o package with Docker at nothing (anchor's tests, the same run's package log):"
  results .harness/package.log; }
start2() { local tr=$1 n=$2
  pgdb u18twice$n; flush
  tb $tr run-pg 20570 $DEV
  if [ "$TBUP" = 1 ]; then tbstop run-pg 20570; else tbwait; echo "  the JVM stopped by itself: exit $TBX · listening on 20570: $(listeners 20570)"; fi
  echo "  its log: Command \"delete\" started $($G -c 'Command "delete" started on database "tiffinbox"' .harness/tb.log || true) · Command \"insert\" started $($G -c 'Command "insert" started on database "tiffinbox"' .harness/tb.log || true) · DuplicateKeyException $($G -c 'DuplicateKeyException' .harness/tb.log || true) · E11000 $($G -c 'E11000' .harness/tb.log || true) · Application run failed $($G -c 'Application run failed' .harness/tb.log || true)"
  echo "  mongosh (no network): countDocuments() $(ms $MN 'db.menu.countDocuments()') · day-19 as stored, its md5 $(ms $MN 'print(EJSON.stringify(db.menu.findOne({_id:"day-19"})))' | md5 -q)"
  psq $CN postgres "drop database u18twice$n with (force)" > /dev/null; }
twice() {
  echo "-- two starts in a row of after/ under dev on the same MongoDB (nothing emptied between; a fresh PostgreSQL database and an emptied Redis each):"
  echo "-- start 1:"; start2 after 1
  echo "-- start 2:"; start2 after 2
  echo "-- the labelled copy noreset (harness/variants.py: start() without menus.reset()), on an emptied collection:"
  echo "  mongosh (no network): db.menu.deleteMany({}) -> deletedCount $(ms $MN 'print(db.menu.deleteMany({}).deletedCount)')"
  echo "-- the copy's start 1:"; start2 noreset 1
  echo "-- the copy's start 2:"; start2 noreset 2; }
XA=('--spring.datasource.url=jdbc:h2:mem:x18;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --logging.level.org.hibernate.orm.core=info --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql --spring.jpa.properties.hibernate.format_sql=false --tiffinbox.port=0 --spring.flyway.enabled=false)
seven() { local t i c e a port
  echo "-- Hibernate's schema script over after/'s libraries without Flyway's jars (Course 7's probe.x.XMain, scripts.action=create, a file, never run):"
  rm -f .harness/run/hibernate-ddl.sql
  echo "\$ cd .harness/run && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -cp \"../hcx:../lib-nofly/*\" probe.x.XMain \"\${XA[@]}\""
  (cd .harness/run && exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -cp "../hcx:../lib-nofly/*" probe.x.XMain "${XA[@]}") > .harness/x.log 2>&1 < /dev/null & pid=$!; e=0; wait "$pid" || e=$?; pid=""
  [ -f .harness/run/hibernate-ddl.sql ] || { tail -5 .harness/x.log >&3; die "xcheck: no script"; }
  echo "  exit $e · cmp with xcheck.sql (= Course 7's capstone's): $(cmp -s .harness/run/hibernate-ddl.sql xcheck.sql && echo 'the same, byte for byte' || echo differ)"
  for t in before after; do i=0; e=0; [ $t = after ] && port=20570 || port=20575
    echo "-- the seven: $t/'s jar, java -jar, H2 in memory (a fresh JVM), port $port:"
    echo "\$ cd .harness/$t && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port"
    (cd .harness/$t && exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port) > .harness/seven-run.log 2>&1 < /dev/null & pid=$!
    while [ $i -lt 480 ]; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
      kill -0 "$pid" 2> /dev/null || { tail -20 .harness/seven-run.log | mask >&3; die "TiffinBox exited before readiness answered 200"; }
      sleep 0.25; i=$((i + 1)); done
    [ "$c" = 200 ] || die "readiness never answered 200 on $port"
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    echo "  GET /actuator/health/readiness -> 200 · GET /actuator/health -> $(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/actuator/health") · GET /menu/day-19 -> $(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/menu/day-19") · listens on: $a"
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
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines, the block's exit $e1:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "  then the solution's lines, in the same shell - the block's exit $e2:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines · listening on 20579 afterwards: $(listeners 20579) · java processes of the exercise: $(ps -axo command= | $G -c '[e]xercise-run' || true)"; }
exercise() {
  printf '%s\n' "$SETUP" > .harness/ex-readme.sh; printf '%s\n' "$SOL" > .harness/ex-sol.sh
  printf '%s\n' 'cd "$1" || exit 1' '. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-readme.st"' 'cd "$1" || exit 1' '. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-sol.st"' > .harness/ex-drive.sh
  echo "exercise/README.md's $(printf '%s\n' "$SETUP" | $G -c .) lines, then exercise/SOLUTION.md's, as written, one after the other in ONE env -i shell (HOME and the PATH this script was started with), started in this folder:"
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh; }


: > .harness/h-all.log
NCAP=1; cap exercise exercise; chk exercise .r-exercise.out "$EXW" "$EXQ"
for f in exercise/README.md exercise/SOLUTION.md; do
  w=$(python3 -I -B harness/chk18.py wib .r-exercise.out "$f"); [ "$(wib "$f")" = "$w" ] || die "$f's \"What it prints\" block is not what its lines printed: $(diff <(wib "$f") <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"; done
echo "  exercise: each file's \"What it prints\" block = what its lines printed (bash's; zsh's the same - chk18)"
pub exercise
export DOCKER_HOST="$DH" TESTCONTAINERS_RYUK_DISABLED=true; tests > .harness/anchor-tests.raw 2>&1 || true; unset DOCKER_HOST TESTCONTAINERS_RYUK_DISABLED
$G -q '^  \*\*\* ' .harness/anchor-tests.raw && { cat .harness/anchor-tests.raw >&3; die "the tests stopped (above)"; }
mask < .harness/anchor-tests.raw > .harness/anchor-tests.out
echo "  the tests (anchor's Maven half): run once in this run of record - their 3/3 is across the runs; the three anchor captures each carry these lines"
NCAP=3
cap image image; chk image .r-image.out; pub image
startstores
for c in anchor document oneread rename absent default twice; do cap $c $c; chk $c ".r-$c.out"; pub $c; done
cap seven seven; chk seven .r-seven.out "$S466"; pub seven
echo "  default's counts in each JVM's log, every run (printed here; the copies' said in the capture as more than 0) - tree, lines naming 27017, naming mongo: $(paste -sd'|' .harness/n27017.txt 2> /dev/null)"
echo "  the harness JVMs' logs, every run of every capture together: lines naming an Exception $($G -cE '[A-Za-z]+Exception\b' .harness/h-all.log || true) · ERROR $($G -c 'ERROR' .harness/h-all.log || true)"
[ "$($G -cE '[A-Za-z]+Exception\b' .harness/h-all.log || true)" = 0 ] || die "an exception in the harness JVMs' logs"
# R.302: every line of README.md's ```text blocks is a line a run printed; the values line is the captures'
cat .r-*.out .harness/chk-*.out .harness/gate.out 2> /dev/null | sed -E 's/^ +//' > .harness/printed.txt
VS="the values the video may say - $VALS"
printf '%s\n' "$VS" > .harness/values.txt
TX=$(awk '/^```text$/ { b = 1; next } b && /^```$/ { b = 0; next } b && NF { sub(/^ +/, ""); print }' README.md | while IFS= read -r l; do $G -qxF -- "$l" .harness/printed.txt || printf '%s\n' "$l"; done | head -3 | cut -c1-160 | paste -sd';' -)
[ "$($G -c '^```text$' README.md)" -gt 0 ] && [ -z "$TX" ] || die "R.302: README.md's text blocks must be lines the runs printed - not printed: ${TX:-no text block}"
$G -qxF -- "$VS" README.md || die "README.md does not state the values these captures give (the line is in .harness/values.txt)"
echo "  R.302: README.md's $($G -c '^```text$' README.md) text blocks - every line one the runs printed; the values line = the captures' ($(wc -c < .harness/values.txt | tr -d ' ') bytes)"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -qE ' (with PID|started by) | in [0-9.]+ seconds|Time elapsed: [0-9]|Total time: +[0-9]|execution time [0-9]|[0-9] ms\b|PT[0-9]|polled [0-9]' "$f" || die "R.432: $f holds a time or a poll count, unmasked"
  ! $G -qE 'executionTimeMillis|millis|"ts"|\$date|Remaining time|serverSelectionTimeout|[A-Za-z]+MS=[0-9]|MongoClient with metadata|Timed out' "$f" || die "R.432: $f holds a MongoDB time, a driver wait or Boot's settings line (the dur8 list)"
  ! $G -qE "ObjectId\('[0-9a-f]+'\)|\b[0-9a-f]{24}\b" "$f" || die "R.430: $f holds an ObjectId unmasked"
  ! $G -qE '^ *[0-9]{4}-[0-9]{2}-[0-9]{2}[T ][0-9]|[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9]' "$f" || die "$f holds a log time"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'jdbc:h2:mem:[0-9a-f]{8}' "$f" || die "$f holds H2's generated database name, unmasked"
  ! $G -E '^ *(the receipt: )?\$ .*(^|[ (])(java|mvn) ' "$f" | $G -vF -- "perl -e '" > /dev/null || die "$f starts a JVM or Maven without its alarm (R.247)"
  ! $G -qF -- "$TOKEN" "$f" || die "$f holds the shutdown token"
  ! $G -qF -- "$PW" "$f" || die "$f holds the PostgreSQL password"; done
DC=$(cat .r-*.out | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
DR=$(awk '/^```text$/ { b = 1; next } b && /^```$/ { b = 0; next } b' README.md | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
[ "$DC" = 0 ] && [ "$DR" = 0 ] || die "R.432: dur8 finds $DC word(s) in the captures and $DR in README.md's text blocks - 0 is the rule"
[ -z "$(find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness (R.195)"
echo "  hygiene: dur8 over the captures and README.md's text blocks 0 words; no path, time, MongoDB time or driver wait, Boot's MongoClient settings line, ObjectId's hex, log time, stack frame, H2 database name, raw port, pid, token or password in any capture; every JVM and Maven under its alarm; no H2 file outside .harness"
# ---- the end: the containers, Testcontainers, the volumes, the images, the trees, the ports -------------------------------------
for c in $MN $RN $CN $HN; do dk rm -fv "$c" > /dev/null 2>&1 || die "the container $c could not be removed"; done
tcrm; [ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container is still there"
[ -z "$(dk ps -aq --filter name=^/$MNV\$ 2> /dev/null)" ] && [ -z "$(dk ps -aq --filter label=com.docker.compose.project=$PROJ 2> /dev/null)" ] && [ -z "$(dk volume ls -q --filter name=^$PROJ)" ] && [ -z "$(dk network ls -q --filter name=^$PROJ)" ] || die "a container, volume or network of this run is still there"
VOL1=$(vols); IMGS1=$(dk images -q --no-trunc 2> /dev/null | sort -u | paste -sd' ' -)
[ "$VOL1" = "$VOL0" ] || die "R.322: the volume count moved, $VOL0 -> $VOL1"
[ "$IMGS1" = "$IMGS0" ] || die "the images moved over this run - nothing may be pulled"
[ ! -e "$HOME/.testcontainers.properties" ] || die "R.318: ~/.testcontainers.properties appeared over this run"
echo "  docker at the end: $MN, $RN, $CN and $HN removed with their volumes (rm -fv); $MNV and the $PROJ project gone; Testcontainers containers 0; volumes $VOL0 -> $VOL1; images $NI0, the same list (nothing pulled)"
pin before-tree before end; pin after-tree after end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 20570-20579 or 18881-18883 at the end - the containers bound 20571, 20572, 20573 and 20576 and are gone; TiffinBox bound 20570 (after/ and the copies) and 20575 (before/, the seven), the exercise's 20579, the IT's container 20578, Compose 18881-18883 inside anchor's window, and all stopped; 20577 never bound (MongoDB absent points there); 20574 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c8-unit18: every capture = published (JVM captures 3/3 in this run; exercise and the tests once per run); every spoken number asserted by chk18.py; before/ and after/ = their pins; the volume count and the images unchanged"
