#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 8 · Spring Data Elasticsearch - this unit's receipts. Section 4 Part B's second anchor change: before/ is a link to
# ../c8-unit21/after (unit 21's tree), after/ is this unit's tree and ../c8-tiffinbox equals it from this unit's commit on. The change
# adds the WRITE PATH to the dish index under the profile "dev": Dishes.searchByName with @Highlight, GET /dishes/search's hits with
# the fragment the index marked, POST /dishes (DishWrite -> DishService: a dish row saved in a transaction of JPA's manager, DishSaved
# published), DishIndexSync (an AFTER_COMMIT listener that saves the row's copy through the repository), a second ElasticsearchIT test.
# No second manager, no sync inside JPA's transaction in the anchor: the two drifts are the HARNESS's (probe.u22.H22, labelled "the
# harness plants a failure"), on the harness's own PostgreSQL and its own index.
# Two witnesses for every Elasticsearch number (S8.78): Java's answer (TiffinBox's routes, the start's log line, the client's own
# request lines by its trace logger, the IT's lines, the harness's lines, the exercise's program) and the store's own REST API by curl
# on the loopback port from this Mac (_search, _count, _mapping, _settings, _cat/indices, _doc) - never docker exec ... curl; every
# row count is PostgreSQL's own answer (psql). The docker exec calls here read a file each (cat /proc/sys/vm/max_map_count, /proc/net/*)
# or run PostgreSQL's and Redis's own clients - never a shell into the store.
# Whose: the ANCHOR's (after/ under "dev" or the default run: anchor, mapping, sync, default, absent, the seven), the HARNESS's
# (probe.u22.H22 on after/'s jar: requests, highlight, nrt's Spring half, stale, drift) or curl's alone on a scratch index (nrt's REST half).
# Captures (the JVM ones run three times and hashed; exercise once per run of record - its 3/3 is across the runs; the tests once per
# run of record too, folded into anchor):
#   exercise   exercise/README.md's lines, then SOLUTION.md's, as written, in ONE env -i shell - bash, then zsh -f (a fresh Elasticsearch each)
#   anchor     the tests; the libraries; after/ under "dev" on PostgreSQL + Redis + MongoDB + Elasticsearch: the re-index, veg with its
#              fragment, POST /dishes -> rows 11 = documents 11 and the listener's two requests, a second start on the same database;
#              ONE Compose window on the shipped compose.yaml (four services, POST /dishes there too)
#   mapping    _mapping, _settings and _doc/1 of the shipped index dishes, beside Dish.java's annotations
#   requests   the three ways to ask (derived finder, CriteriaQuery, NativeQuery) and a prefix, by the harness, each request by the trace logger; curl re-sends each body
#   highlight  Dishes.searchByName for veg, vegetarian and lunch, by the harness; curl's _search with a highlight block
#   nrt        REST by curl on a scratch index dishes_nrt (at once, wait_for, true); the Spring side by the harness on dishes_nrt_j (three saves)
#   stale      the template's save then a count, beside the repository's save then a count (the harness, dishes_nrt_j)
#   sync       the anchor's shape: rows and documents after the start, a POST, another POST, and a second start on the same database
#   drift      "the harness plants a failure": intx, listener, control - the harness's PostgreSQL (20616) and the index dishes_drift
#   default    after/ with no profile on H2, no Docker: 200, 404s, 0 Elasticsearch lines, POST /dishes 404
#   absent     after/ under "dev" with Elasticsearch absent: exit 1, the client's exception, the one URI
#   seven      the comparison set on before/'s and after/'s jars (H2; after/ on 20610, before/ on 20617)
#   sockets    the unit's Elasticsearch container's sockets, read at the end of the receipt (S8.92)
# Every tree is COPIED under .harness/ and built there, offline (-o, from .m2-demo, a copy of the course's seed, maven.repo.local
# absolute), every module from the tree's own sources (-pl tiffinbox-web -am, R.391). Every JVM and Maven run under an alarm (R.247),
# every JVM with SIGINT reset to its default (R.410). Every docker call names its socket (dk, R.344), --pull never; every container is
# removed with its volumes (rm -fv, R.387) and the volume count asserted back. A receipt waits on a count it polls (R.412). Every
# Elasticsearch container runs with the six settings (compose.yaml's).
# Ports (20610-20619): 20610 TiffinBox after/ · 20611 the unit's PostgreSQL · 20612 the unit's Redis · 20613 the unit's MongoDB, a
# standalone · 20614 the unit's Elasticsearch · 20615 the IT's Elasticsearch, pinned, during mvn verify only · 20616 the harness's
# PostgreSQL (drift) · 20617 TiffinBox before/ for the seven · 20618 the exercise's Elasticsearch · 20619 never bound ("Elasticsearch
# absent"). 20578: the Mongo IT's pinned binding (during mvn verify). 18881-18884 only inside anchor's Compose window.
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
CN=c8u22-pg; RN=c8u22-redis; MN=c8u22-mongo; EN=c8u22-es; HN=c8u22-pg-h; EX=c8u22-es-ex; PROJ=tiffinbox-dev
NEWD='Mushroom Noodle Bowl'; NEWD2='Tomato Basil Soup'
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
pid=""; mpid=""; xpid=""; CMPW=""; CMPV=""; TC0=""; INTR=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.u22.") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "SaveLab.java") || index($0, "curlset.sh") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || $3 ~ /(^|\/)javac$/ || index($0, "ex-drive.sh")) { print $1 }' | paste -sd' ' -) || l=""
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
# anonymous volumes by the names its container listed (a down -v after a down does not remove them - unit 18 measured it)
cmprm() { local v
  [ -n "$TC0" ] || return 0
  if [ -n "$(dk ps -aq --filter name=^/${PROJ}-mongo-1\$ 2> /dev/null)" ]; then CMPV="$CMPV $(dk inspect -f '{{range .Mounts}}{{.Name}} {{end}}' ${PROJ}-mongo-1 2> /dev/null)"; fi
  if [ -n "$CMPW" ] || [ -n "$(dk ps -aq --filter label=com.docker.compose.project=$PROJ 2> /dev/null)" ] || dk network inspect ${PROJ}_default > /dev/null 2>&1; then
    (cd .harness/compose-run 2> /dev/null && dk compose -p $PROJ down -v > /dev/null 2>&1) || true; fi
  for v in $CMPV; do dk volume inspect "$v" > /dev/null 2>&1 && dk volume rm "$v" > /dev/null 2>&1; done
  dk volume inspect ${PROJ}_data > /dev/null 2>&1 && [ -n "$CMPW" ] && dk volume rm ${PROJ}_data > /dev/null 2>&1
  CMPW=""; CMPV=""; return 0; }
# the scratch indices this receipt and its harness make on the unit's Elasticsearch, deleted by the trap (printed when it ran)
ixrm() { local x; [ -n "$TC0" ] || return 0
  [ -n "$(dk ps -q --filter name=^/$EN\$ 2> /dev/null)" ] || return 0
  for x in dishes_nrt dishes_nrt_j dishes_drift; do curl -s --noproxy '*' -o /dev/null -X DELETE "http://127.0.0.1:20614/$x" 2> /dev/null || true; done
  [ -z "$INTR" ] || echo "  the trap: the scratch indices dishes_nrt, dishes_nrt_j, dishes_drift deleted - _cat/indices now: $(curl -s --noproxy '*' 'http://127.0.0.1:20614/_cat/indices?h=index' 2> /dev/null | sort | paste -sd' ' -)" >&3; }
ctrm() { local c; [ -n "$TC0" ] || return 0
  for c in $EX $HN $EN $MN $RN $CN; do [ -z "$(dk ps -aq --filter name=^/$c\$ 2> /dev/null)" ] || dk rm -fv "$c" > /dev/null 2>&1 || true; done; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid" "$pid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; tcrm; cmprm; ixrm; ctrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git unzip /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|FLYWAY_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|REDIS[A-Z_]*|MONGO[A-Z_]*|ES_[A-Z_]*|ELASTIC[A-Z_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT|COMPOSE_[A-Z_]*)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"

# ---- gates before anything is written: the folder, the links, the pins, the prose, the change, R.250 ---------------------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk22.py dur8.py logback.xml s822.py src surefire.py tree22.py' ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe/u22/H22.java' ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md SaveLab.java check.sh' ] || die "exercise/ holds another file, or misses one"
cmp -s harness/dur8.py ../c8-unit02/harness/dur8.py || die "harness/dur8.py is not the builders' dur8.py as unit 02 shipped it, byte for byte"
cmp -s harness/surefire.py ../c8-unit02/harness/surefire.py || die "harness/surefire.py is not unit 02's, byte for byte"
cmp -s harness/logback.xml ../c8-unit07/harness/logback.xml || die "harness/logback.xml is not unit 07's, byte for byte"
[ -L before ] && [ "$(readlink before)" = ../c8-unit21/after ] || die "R.211: before must be a link to ../c8-unit21/after (it points at: $(readlink before 2> /dev/null || echo 'not a link'))"
[ -d after ] && [ ! -L after ] || die "after/ must be this unit's own tree, not a link"
for t in after before; do [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] && die "$t holds a secrets/ or a target/ - never built in place"; true; done
git rev-parse -q --verify 'e9c3977^{commit}' > /dev/null 2>&1 || die "unit 21's commit e9c3977 is not in this repository's history"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree22.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/ ($3): python3 -I harness/tree22.py $dir/ -> $got = receipts.md5's $nm line"; }
pin before-tree before start; pin after-tree after start
U21P=$(awk '$1 == "after-tree" { print $2, $3 }' ../c8-unit21/receipts.md5)
[ "$U21P" = "$(awk '$1 == "before-tree" { print $2, $3 }' receipts.md5)" ] || die "before/'s pin is not unit 21's after-tree line ($U21P)"
echo "  before/'s pin = ../c8-unit21/receipts.md5's after-tree line ($U21P), re-derived by harness/tree22.py"
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c8-tiffinbox 2>&1 || true)
echo "  after/ against ../c8-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor' || echo 'they differ - a later unit moved the anchor; this unit measures after/')"
rm -f .r-gate.tmp
echo "  after/ against before/ (diff -rq, the files the change added or changed):"; diff -rq before/ after/ 2>&1 | sed -E 's#^Files before/(.*) and after/.* differ$#    changed: \1#; s#^Only in after/(.*): (.*)$#    new: \1/\2#; s#^Only in before/(.*): (.*)$#    gone: \1/\2#' | sort | tee -a .r-gate.tmp
[ -z "$(diff -rq before/ after/ 2>&1 | $G '^Only in before' || true)" ] || die "the change deletes no file - a file is only in before/"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s822.py harness/dur8.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -2 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
JD=$(python3 -I -B harness/chk22.py javadoc after before) || die "the Javadoc gate: $(printf '%s\n' "$JD" | $G '^FAIL' | head -3 | paste -sd';' -)"
YD=$(diff -r before/ after/ 2>&1 | $G '^>' | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
[ "$YD" = 0 ] || die "R.432: dur8 finds $YD duration word(s) in the lines the change added (Javadoc, YAML, compose and README lines)"
NEWF=$(diff -rq before/ after/ 2>&1 | sed -n -E 's#^Only in after/(.*): (.*)$#after/\1/\2#p')
YN=$(for f in $NEWF; do if [ -d "$f" ]; then find "$f" -type f -exec cat {} +; else cat "$f"; fi; done | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
[ "$YN" = 0 ] || die "R.432: dur8 finds $YN duration word(s) in the files the change added"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
DN=$($G -rniwE -- "$DISH" README.md exercise harness/src after/tiffinbox-web/src/main/java/com/tiffinbox/web/Dish*.java 2> /dev/null | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|VALUES-PENDING|WIB-README|WIB-SOLUTION|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
! $G -q '^```java$' README.md || die "README.md holds a java block - the code is the anchor's files and the exercise's"
! $G -rqE 'Course 13' README.md exercise after/tiffinbox-web/src/main/java/com/tiffinbox/web/Dish*.java || die "flag 12: this unit never names Course 13 - the dual write is named and handed to unit 24"
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
EXQ="Your turn: the template saves a dish and the count that follows it reads zero. Make that count read one without a second write."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SETUP=$(block exercise/README.md); SOL=$(block exercise/SOLUTION.md)
[ -n "$SETUP" ] && [ -n "$SOL" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
[ "$(diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G -c '^[<>]')" = 2 ] || die "R.196: SOLUTION.md's block must be the README's with one line changed"
[ "$(printf '%s\n' "$SETUP" | $G -cxF 'cp exercise/SaveLab.java "$EX/SaveLab.java"')" = 1 ] && [ "$(printf '%s\n' "$SOL" | $G -cF "perl -pe 's/ops\.save\(dish\);/ops.withRefreshPolicy(RefreshPolicy.IMMEDIATE).save(dish);/' exercise/SaveLab.java > \"\$EX/SaveLab.java\"")" = 1 ] || die "R.196: the README's block runs SaveLab as shipped, SOLUTION.md's with its one line changed (the template withRefreshPolicy(IMMEDIATE))"
printf '%s\n' "$SETUP" | $G -E '(^|[ (])(mvn|java|javac) ' | $G -vqF "perl -e '" && die "exercise/README.md's Java and Maven runs must run under their alarm (R.247)"
printf '%s\n' "$SETUP" | $G -E 'mvn ' | $G -vqF -- '-pl tiffinbox-web -am' && die "R.391: exercise/README.md builds without -pl tiffinbox-web -am"
printf '%s\n' "$SETUP" | $G -E '(^|[ ;&(])docker ' | $G -vqF 'docker -H "$DH" ' && die "R.344: exercise/README.md calls docker without its socket (docker -H \"\$DH\")"
printf '%s\n' "$SETUP" | $G -qF 'docker -H "$DH" rm -fv c8u22-es-ex' || die "R.387: the exercise's container is removed with its volumes (rm -fv)"
for s in discovery.type=single-node xpack.security.enabled=false xpack.ml.enabled=false ingest.geoip.downloader.enabled=false xpack.inference.elastic.authorization.enabled=false '"ES_JAVA_OPTS=-Xms512m -Xmx512m"'; do printf '%s\n' "$SETUP" | $G -qF -- "-e $s" || die "⚑4: the exercise's Elasticsearch runs without $s"; done
printf '%s\n' "$SETUP" | $G -qF "docker -H \"\$DH\" run -d --name c8u22-es-ex -p 127.0.0.1:20618:9200 " || die "S8.76: the exercise starts its own fresh Elasticsearch container, on 127.0.0.1:20618"
printf '%s\n' "$SETUP" | $G -qF "$ETAG > /dev/null" || die "R.387's split: the viewer's line names the image by its tag, $ETAG"
EXT="curl -s --noproxy '*' -X PUT -H 'Content-Type: application/json' http://127.0.0.1:20618/_index_template/c8u22-ex --data-binary '{\"index_patterns\":[\"dishes\"],\"template\":{\"settings\":{\"index\":{\"refresh_interval\":\"-1\"}}}}' > /dev/null"
for b in "$SETUP" "$SOL"; do [ "$(printf '%s\n' "$b" | $G -cxF -- "$EXT")" = 1 ] && [ "$(printf '%s\n' "$b" | awk -v t="$EXT" '/_cluster\/health/ { h = NR } $0 == t { x = NR } /SaveLab\.java" > / { j = NR } END { print (h && x == h + 1 && j == x + 1) ? "ok" : "no" }')" = ok ] || die "S8.76: the exercise's index refreshes only on request - refresh_interval -1 by the index template c8u22-ex, one curl line after the health wait and before the program, in both blocks"; done
printf '%s\n' "$SETUP" | $G -qxF 'bash exercise/check.sh "$EX/run.log"' || die "R.196: the exercise is checked by exercise/check.sh (the store's own count and the program's own requests), never by the exit"
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket (docker -H \"\$DH\")"
DK=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -nE '\bdocker (run|exec|rm|ps|port|info|images|volume|image|pull|events|compose|network|restart|logs|stop|start|inspect|stats)\b' | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.344: receipts.sh calls docker without the pinned socket (every call is dk): $DK"
RMF=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) rm( +-[a-z]+)*' | sort -u | paste -sd'|' -)
[ "$RMF" = 'dk rm -fv' ] || die "R.387: receipts.sh removes a container without its volumes - every removal is dk rm -fv (found: ${RMF:-none})"
RUNP=$($G -v '^ *#' receipts.sh | $G -oE '(dk|docker) run -[^"]*' | $G -vcF -- '--pull never' || true)
[ "$RUNP" = 0 ] || die "R.344: a dk run without --pull never"
MRUN=$($G -v '^ *#' receipts.sh | $G -E '(dk|docker) run ' | $G -F '$MIMG' | $G -vcF 'GLIBC_TUNABLES=$GT' || true)
[ "$MRUN" = 0 ] || die "R.421: a MongoDB container run without GLIBC_TUNABLES"
XC=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -cE '(dk|docker)( -H [^ ]+)? exec [^|;]*\bcurl\b' || true)
[ "$XC" = 0 ] || die "§BUILDERS 9: receipts.sh reads Elasticsearch by an exec into its container and curl there - curl runs on this Mac, on the loopback port"
XE=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) exec [$"][^ ]+ [a-z_-]+( /proc/[a-z_/$]+)?' | awk '{ print $4 ($5 ? " " $5 : "") }' | sort -u | paste -sd'|' -)
[ "$XE" = 'cat /proc/net/$t|cat /proc/net/dev|cat /proc/sys/vm/max_map_count|pg_isready|psql|redis-cli' ] || die "every exec into a container here reads a /proc file by cat, or is PostgreSQL's or Redis's own client - never a shell (found: $XE)"
ESR=$($G -v '^ *#' receipts.sh | $G -E '(dk|docker) run ' | $G -F '$EIMG' | $G -vcF '$ESSET' || true)
[ "$ESR" = 0 ] || die "⚑4: an Elasticsearch container run without the six settings (\$ESSET)"
[ -z "$($G -v '^ *#' receipts.sh | $G -E '(dk|docker) run ' | $G -oE -- ' -p [^ ]+' | $G -v '^ -p 127\.0\.0\.1:' || true)" ] && [ -z "$($G -rlE '0\.0\.0\.0:[0-9]|\[::\]:[0-9]|bindIpAndPort\("0' after/compose.yaml after/tiffinbox-web/src || true)" ] || die "S8.94: a port published on every interface (-p without 127.0.0.1, or 0.0.0.0 in after/)"
[ -z "$($G -rlE 'withReplicaSet|--replSet|replSetInitiate' after/ exercise || true)" ] || die "S8.62: a replica set in after/ or the exercise"
MVA=$($G -v '^ *#' receipts.sh | $G -F 'clean ' | $G -F '$MV' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am"
[ "$($G -v '^ *#' receipts.sh | $G -E '^(DEV|DEVB)=' | $G -o -- '--spring.elasticsearch.uris' | $G -c . || true)" = 1 ] || die "S8.84: the key spring.elasticsearch.uris must stand once in DEV and never in DEVB"
ST=$(python3 -I -B harness/chk22.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
R250=$(python3 -I -B harness/chk22.py r250 after before) || die "R.250: $(printf '%s\n' "$R250" | $G '^FAIL' | head -2 | paste -sd';' -)"
printf '%s\n' "$R250" | $G -v '^VALUES ' | sed 's/^/  /'
printf '%s\n' "$JD" | $G -v '^VALUES ' | sed 's/^/  /'
printf '%s\n' "$ST" "$R250" "$JD" | $G -v '^VALUES ' >> .r-gate.tmp
echo "  prose, per sentence (s822, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test): refused 0 over $PROSE · the lines the change added: dur8 0 · dish names 0 · placeholders 0 · no java block"
echo "  the exercise: the spoken line $EXW words (wc -w); SOLUTION.md's block = the README's with one line changed - SaveLab with the template's save made withRefreshPolicy(IMMEDIATE); the two \"What it prints\" blocks differ (R.196); checked by exercise/check.sh, never the exit; a fresh container on 127.0.0.1:20618 by the tag, with the six settings, removed with its volumes; its build -pl tiffinbox-web -am; its docker calls on the socket"
echo "  static: no kill by name; every docker call on the pinned socket, every dk run --pull never, every MongoDB container with GLIBC_TUNABLES, every Elasticsearch container with the six settings; no exec into a container to run curl (curl on the loopback port, §BUILDERS 9); no port on every interface (S8.94); every container removal dk rm -fv (R.387); no replica set; every Maven build -pl tiffinbox-web -am (R.391); spring.elasticsearch.uris once on a command line (S8.84)"
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
    gsub(/"took" ?: ?[0-9]+/, "\"took\":<n>")
    gsub(/took\[[0-9.]+[a-z]*\]/, "took[<n>]")
    gsub(/"@timestamp" ?: ?"[^"]*"/, "\"@timestamp\":\"<t>\"")
    gsub(/polled [0-9]+ times/, "polled <k> times")
    gsub(/pid [0-9]+/, "pid <n>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxWebTest in 3.1 seconds (process running for 4.2)' 'Tests run: 2, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 3.982 s' 'Finished Spring Data repository scanning in 23 ms. Found 1 Elasticsearch repository interface.' 'Root WebApplicationContext: initialization completed in 812 ms' 'Successfully applied 4 migrations (execution time 00:00.026s)' 'Container elasticsearch@sha256:fb7f started in PT0.6S' 'Total time:  12.345 s' 'PROBE hold: pid 41231' '{"took":17,"timed_out":false}' '"@timestamp":"2026-11-23T00:01:02.003Z"' 'took[31ms]' "$U/x $HOME/y" | mask)
printf '%s\n' "$MP" | python3 -I -B -c 'import importlib.util,sys,re; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=sys.stdin.read(); sys.exit(1 if m.DUR.search(t) or "PT0" in t or "3.982" in t or "00:00.026" in t or "812" in t or "12.345" in t or "41231" in t or "23 ms" in t or "\"took\":17" in t or "2026-11-23T00" in t or "31ms" in t else 0)' || die "R.432: the mask's self-test - a planted duration line, took or @timestamp passed it unmasked: $(printf '%s\n' "$MP" | head -2 | paste -sd';' -)"
[ "$(printf '%s\n' "$MP" | tail -1)" = '…/x ~/y' ] || die "the mask's self-test: the folders and the home must be masked"
echo "  mask: its self-test refused the planted Started-in-seconds, Time elapsed, scanning, initialization, execution-time, started-in-PT, Total time, pid, took, took[...] and @timestamp unmasked (R.432, TIMEPAT_S4B); folders and home masked"
CURLSET=../c5-unit11/curlset.sh
[ -x "$CURLSET" ] || die "$CURLSET is missing - the comparison set the seven runs"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
ESSET="-e discovery.type=single-node -e xpack.security.enabled=false -e xpack.ml.enabled=false -e ingest.geoip.downloader.enabled=false -e xpack.inference.elastic.authorization.enabled=false -e ES_JAVA_OPTS=-Xms512m\ -Xmx512m"

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
[ "$(iid mongo:8) $(iid postgres:18-alpine) $(iid redis:8-alpine) $(iid $ETAG)" = '05b334b0a7a7 77f585114c32 7958cfbb9d15 fb7f2d0df199' ] || die "the tags compose.yaml names (mongo:8, postgres:18-alpine, redis:8-alpine, $ETAG) are not on this machine at the course's digests - a Compose up would pull; this script never pulls"
RY0=$(dk images --format '{{.Repository}}' 2> /dev/null | $G -c ryuk || true)
[ "$RY0" = 0 ] || die "R.318: an image named ryuk is on this machine ($RY0) - Ryuk stays off and none is pulled"
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run - remove it with its volumes: docker -H \"\$DH\" rm -fv <id>"
for c in $CN $RN $MN $EN $HN $EX; do [ -z "$(dk ps -aq --filter name=^/$c\$ 2> /dev/null)" ] || die "a container named $c exists before the run - an interrupted run's? docker -H \"\$DH\" rm -fv $c"; done
[ -z "$(dk ps -aq --filter label=com.docker.compose.project=$PROJ 2> /dev/null)" ] && [ -z "$(dk network ls -q --filter name=^${PROJ} 2> /dev/null)" ] && [ -z "$(dk volume ls -q --filter name=^${PROJ} 2> /dev/null)" ] || die "a $PROJ container, network or volume exists before the run - anchor's Compose window needs none (docker -H \"\$DH\" compose -p $PROJ down, and its volumes by name)"
TC0=1
[ ! -e "$HOME/.testcontainers.properties" ] || die "R.318: ~/.testcontainers.properties exists - this unit's Testcontainers JVMs read a receipt home under .harness/ only"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 18881 18882 18883 18884 20578 20610 20611 20612 20613 20614 20615 20616 20617 20618 20619"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
[ "$(pgrep -x java | wc -l | tr -d ' ')" = 0 ] || die "a java process is running before this script starts one - not this script's; stop it first"
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · the four digests present ($IMG, $RIMG, $MIMG, $EIMG) · mongo:8, postgres:18-alpine, redis:8-alpine and $ETAG on those digests · nothing pulled, ever · images named ryuk $RY0 · Testcontainers containers 0 · no $PROJ container, network or volume · ports 20578, 20610-20619, 18881-18884 (and 18425, 8080) free · java processes 0"

# ---- the trees, copied; the builds; the harness, compiled -----------------------------------------------------------------------
rm -rf .harness; mkdir -p .harness/run-h2/secrets/tiffinbox .harness/run-pg/secrets/tiffinbox .harness/run-h .harness/home .harness/compose-run
M2="$PWD/.m2-demo"
[ -d "$M2" ] || die ".m2-demo (a copy of the course's seed, _research/m2-seed-c8-s4b) is missing - README.md, The repository"
for a in co/elastic/clients/elasticsearch-java/9.4.8 co/elastic/clients/elasticsearch-rest5-client/9.4.8 org/springframework/data/spring-data-elasticsearch/6.1.2 org/springframework/boot/spring-boot-starter-data-elasticsearch/4.1.2 org/springframework/boot/spring-boot-elasticsearch/4.1.2 org/springframework/boot/spring-boot-data-elasticsearch/4.1.2 org/testcontainers/testcontainers-elasticsearch/2.0.5; do
  [ -d "$M2/$a" ] || die "$a is not in .m2-demo - the seed lacks it (README.md, The repository)"; done
NF0=$(find "$M2" -type f | wc -l | tr -d ' ')
SDE="$M2/org/springframework/data/spring-data-elasticsearch/6.1.2/spring-data-elasticsearch-6.1.2.jar"
echo "  .m2-demo's files $NF0 · spring-data-elasticsearch 6.1.2's jar holds (unzip -l, by class): $(for c in annotations/Highlight annotations/HighlightField client/elc/NativeQuery core/query/CriteriaQuery core/RefreshPolicy; do unzip -l "$SDE" "org/springframework/data/elasticsearch/$c.class" > /dev/null 2>&1 && printf '%s ' "${c##*/}"; done)· spring-tx's TransactionalEventListener: $(unzip -l "$M2/org/springframework/spring-tx/"*/spring-tx-*.jar org/springframework/transaction/event/TransactionalEventListener.class > /dev/null 2>&1 && echo present || echo absent) - no new artifact" | tee -a .r-gate.tmp
printf '%s\n' 'checks.disable=true' "tinyimage.container.image=$IMG" > .harness/home/.testcontainers.properties
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy before .harness/before; copy after .harness/after; copy after .harness/tests
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE '^\[INFO\] Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
AL="-DargLine=$JL -Dstdout.encoding=UTF-8 -Duser.home=../../home"
for t in before after; do
  XG=""; [ $t = after ] && XG=" dependency:build-classpath -Dmdep.outputFile=target/classpath.txt -Dmdep.includeScope=runtime"
  bg "cd .harness/$t && $MV clean package -DskipTests -pl tiffinbox-web -am$XG" .harness/build-$t.log
  [ "$RE" = 0 ] || { tail -20 .harness/build-$t.log >&3; die ".harness/$t did not build offline (exit $RE)"; }; offl .harness/build-$t.log
  bg "cd .harness/$t && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$t.log
  [ "$RE" = 0 ] || die ".harness/$t: the jar's extract failed"; done
$G -q 'spring-boot-docker-compose-4.1.2.jar' .harness/after/tiffinbox-web/target/classpath.txt || die "Maven's class path for after/ lacks spring-boot-docker-compose (the Compose window needs it)"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*\" harness/src/probe/u22/H22.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/: $(head -5 .harness/javac.log)"
TF=secrets/tiffinbox/shutdown-token
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/run-h2/$TF) || die "the token was not written"
rsync -a after/ .harness/compose-run/ && mkdir -p .harness/compose-run/secrets/tiffinbox
for d in run-pg after before compose-run; do mkdir -p .harness/$d/secrets/tiffinbox; (umask 077 && cp .harness/run-h2/$TF .harness/$d/$TF) || die "the token was not copied"; done
cmp -s .harness/compose-run/compose.yaml after/compose.yaml || die "the Compose window's compose.yaml is not after/'s"
mv .r-gate.tmp .harness/gate.out 2> /dev/null || true
TOKEN=$(head -1 .harness/run-h2/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
PW=$(openssl rand -hex 16); (umask 077 && printf 'POSTGRES_USER=tiffinbox\nPOSTGRES_PASSWORD=%s\n' "$PW" > .harness/pg.env) || die "the password file was not written"
echo "  built before/'s and after/'s trees offline (mvn -o package -DskipTests -pl tiffinbox-web -am, exit 0, 'Downloaded from' 0; after/'s with Maven's runtime class path written beside it, for the Compose window), extracted their jars; compiled the harness (harness/src/probe/u22/H22.java, javac 25) against after/'s jar and its libraries; a shutdown token and a PostgreSQL password generated (0600, never printed)"

# ---- helpers -------------------------------------------------------------------------------------------------------------------
vols() { dk volume ls -q 2> /dev/null | wc -l | tr -d ' '; }
mounts() { dk inspect -f '{{range .Mounts}}{{.Type}} {{.Destination}}{{println}}{{end}}' "$1" 2> /dev/null | $G . | sort | paste -sd'|' - | sed 's/|/ · /g'; }
pgready() { local i=0; while ! dk exec "$1" pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 120 ] || die "PostgreSQL ($1) did not accept connections (120 tries)"; sleep 0.5; done; }
# Elasticsearch: curl on the loopback port from this Mac, never inside the container
eq() { local p=$1 m=$2 u=$3; shift 3
  if [ $# -gt 0 ]; then curl -s --noproxy '*' -H 'Content-Type: application/json' -X "$m" "http://127.0.0.1:$p$u" --data-binary "$1" 2> /dev/null; else curl -s --noproxy '*' -X "$m" "http://127.0.0.1:$p$u" 2> /dev/null; fi; }
esup() { local i=0 c; while :; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/_cluster/health" 2> /dev/null || true); [ "$c" = 200 ] && break
    i=$((i + 1)); [ $i -lt 480 ] || die "Elasticsearch on $1 did not answer _cluster/health 200 (480 reads)"; sleep 0.25; done; }
mkes() { local n=$1 p=$2
  bg "dk run -d --pull never --name $n --hostname $n -p 127.0.0.1:$p:9200 $ESSET $EIMG" .harness/docker-run-$n.log
  [ "$RE" = 0 ] || die "the Elasticsearch container $n did not start: $(tail -2 .harness/docker-run-$n.log)"
  esup $p
  [ "$(dk port $n | paste -sd'|' -)" = "9200/tcp -> 127.0.0.1:$p" ] || die "$n publishes on another address than 127.0.0.1:$p"; }
PYH='import json,sys
d=json.load(sys.stdin)
if "error" in d: print("error " + d["error"]["type"] + ": " + d["error"]["reason"]); sys.exit(0)
i=sorted(h["_id"] for h in d["hits"]["hits"]); print(str(d["hits"]["total"]["value"]) + " [" + ", ".join(i) + "]")'
PYHL='import json,sys
d=json.load(sys.stdin)
if "error" in d: print("error " + d["error"]["type"] + ": " + d["error"]["reason"]); sys.exit(0)
h=sorted(d["hits"]["hits"], key=lambda x: x["_id"]); print(str(d["hits"]["total"]["value"]) + " [" + ", ".join(x["_id"] for x in h) + "] · " + " · ".join(x["_id"] + " " + x["_source"]["mealType"] + " highlight.name " + json.dumps(x.get("highlight", {}).get("name")) for x in h))'
hits() { eq "$1" POST "/$2/_search" "$3" | python3 -I -c "$PYH"; }
hlits() { eq "$1" POST "/$2/_search" "$3" | python3 -I -c "$PYHL"; }
cnt() { eq "$1" GET "/$2/_count" | python3 -I -c 'import json,sys; d=json.load(sys.stdin); print(d.get("count", "error " + str(d.get("error", {}).get("type"))))'; }
ack() { python3 -I -c 'import json,sys; d=json.load(sys.stdin); print("error " + d["error"]["type"] if "error" in d else "acknowledged " + str(d.get("acknowledged")).lower())'; }
catix() { eq "$1" GET "/_cat/indices/$2?h=index,health,status,pri,rep,docs.count&s=index" | sed -E 's/ +/ /g; s/ $//' | paste -sd'|' - | sed 's/|/ · /g'; }
startstores() {
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:20611:5432 --env-file .harness/pg.env $IMG" .harness/docker-run-pg.log
  [ "$RE" = 0 ] || die "the PostgreSQL container did not start: $(tail -2 .harness/docker-run-pg.log)"
  bg "dk run -d --pull never --name $RN -p 127.0.0.1:20612:6379 $RIMG" .harness/docker-run-redis.log
  [ "$RE" = 0 ] || die "the Redis container did not start: $(tail -2 .harness/docker-run-redis.log)"
  mkmongo; mkes $EN 20614; pgready $CN
  local i=0; while [ "$(dk exec $RN redis-cli PING 2> /dev/null | tr -d '\r')" != PONG ]; do i=$((i + 1)); [ $i -lt 200 ] || die "Redis did not answer PING"; sleep 0.1; done
  [ "$(dk port $CN | paste -sd'|' -)" = '5432/tcp -> 127.0.0.1:20611' ] && [ "$(dk port $RN | paste -sd'|' -)" = '6379/tcp -> 127.0.0.1:20612' ] || die "a store publishes on another address than 127.0.0.1:<its port>"
  echo "  the unit's stores: $CN (PostgreSQL, 127.0.0.1:20611) from $IMG; $RN (Redis, 127.0.0.1:20612, no password) from $RIMG; $MN (MongoDB, a standalone, 127.0.0.1:20613, no auth, -e GLIBC_TUNABLES=$GT, --unixSocketPrefix /data/db) from $MIMG; $EN (Elasticsearch, 127.0.0.1:20614, 9300 not published, the six settings, --hostname $EN) from $EIMG; all --pull never, 127.0.0.1 only; the password from a 0600 file, never printed · volumes now $(vols) (the machine's $VOL0 + PostgreSQL's one + MongoDB's two; Elasticsearch's container: $(m=$(mounts $EN); echo "${m:-no mount}"))"
  echo "  $EN: GET / (curl) -> version.number $(eq 20614 GET / | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["version"]["number"])') · its environment, the six (dk inspect): $(dk inspect -f '{{json .Config.Env}}' $EN | python3 -I -c 'import json,sys; print(" · ".join(sorted(e for e in json.load(sys.stdin) if e.split("=")[0] in ("discovery.type","xpack.security.enabled","xpack.ml.enabled","ingest.geoip.downloader.enabled","xpack.inference.elastic.authorization.enabled","ES_JAVA_OPTS"))))') · /proc/sys/vm/max_map_count (dk exec, cat) $(dk exec $EN cat /proc/sys/vm/max_map_count | tr -d '\r')"; }
mkmongo() {
  bg "dk run -d --pull never --name $MN -p 127.0.0.1:20613:27017 -e GLIBC_TUNABLES=$GT $MIMG --unixSocketPrefix /data/db" .harness/docker-run-mongo.log
  [ "$RE" = 0 ] || die "the MongoDB container did not start: $(tail -2 .harness/docker-run-mongo.log)"
  local i=0; while [ "$(dk logs $MN 2>&1 | $G -c 'Waiting for connections' || true)" = 0 ]; do i=$((i + 1)); [ $i -lt 240 ] || die "MongoDB's log never said Waiting for connections (240 reads)"; sleep 0.25; done
  [ "$(dk port $MN | paste -sd'|' -)" = '27017/tcp -> 127.0.0.1:20613' ] || die "$MN publishes on another address than 127.0.0.1:20613"; }
# a FRESH MongoDB for every dev start, as unit 20 found its start's witness drifts on a reused one (this unit reads no MongoDB profile; the shape is kept)
freshmongo() { dk rm -fv $MN > /dev/null 2>&1 || die "$MN could not be removed"; mkmongo; }
psq() { dk exec "$1" psql -U tiffinbox -d "$2" -qAt -v ON_ERROR_STOP=1 -c "$3" 2>&1 || die "psql failed on $1/$2: $3"; }
pgdb() { psq $CN postgres "drop database if exists $1 with (force)" > /dev/null; psq $CN postgres "create database $1" > /dev/null
  (umask 077 && printf 'jdbc:postgresql://127.0.0.1:20611/%s?user=tiffinbox&password=%s\n' "$1" "$PW" > .harness/run-pg/secrets/tiffinbox/jdbc-url) || die "the URL was not written"
  echo "  a fresh database on $CN: $1 (psql) · its URL in the config tree (0600, never printed)"; }
flush() { [ "$(dk exec $RN redis-cli FLUSHALL | tr -d '\r')" = OK ] || die "redis-cli FLUSHALL failed"; echo "  redis-cli FLUSHALL (the unit's Redis) -> OK"; }
TRL=--logging.level.co.elastic.clients.transport.rest5_client.low_level.Request=TRACE
DEVB="--spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20612 --spring.mongodb.uri=mongodb://127.0.0.1:20613/tiffinbox $TRL"
ESURI=http://127.0.0.1:20614
DEV="$DEVB --spring.elasticsearch.uris=$ESURI"
cu() { curl -s --noproxy '*' -o .harness/body -w '%{http_code}' "http://127.0.0.1:$1$2" 2> /dev/null || true; }
post() { curl -s --noproxy '*' -o .harness/body -w '%{http_code}' -H 'Content-Type: application/json' -X POST "http://127.0.0.1:$1/dishes" --data-binary "{\"name\":\"$2\",\"mealType\":\"$3\",\"price\":$4}" 2> /dev/null || true; }
# tb TREE RUN PORT ARG...: TiffinBox's jar of TREE (java -jar, under its alarm, SIGINT at its default), from .harness/RUN (its config
# tree), in the background (pid); the receipt polls readiness on PORT until 200, or until the JVM is gone (TBUP = 1 or 0)
tb() { local tr=$1 run=$2 port=$3 i=0 c; shift 3
  echo "\$ cd .harness/$run && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -jar ../$tr/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port $*" | mask
  TBCL="$*"
  (cd .harness/$run && exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -jar ../$tr/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port "$@") > .harness/tb.log 2>&1 < /dev/null & pid=$!
  TBUP=0; while [ $i -lt 960 ]; do c=$(cu $port /actuator/health/readiness); [ "$c" = 200 ] && { TBUP=1; break; }
    kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  if [ "$TBUP" = 0 ] && kill -0 "$pid" 2> /dev/null; then die "TiffinBox neither answered readiness nor stopped (960 reads)"; fi; }
tbstop() { local c; c=$(printf 'X-Shutdown-Token: %s\n' "$(head -1 .harness/$1/$TF)" | curl -s --noproxy '*' -o /dev/null -w '%{http_code}' -H @- -X POST "http://127.0.0.1:$2/shutdown" 2> /dev/null || true)
  TBX=0; wait "$pid" || TBX=$?; pid=""
  [ "$(listeners $2)" = 0 ] || die "something still listens on $2 after TiffinBox stopped"
  echo "  POST /shutdown (the token on curl's standard input) -> $c · the JVM's exit $TBX · listening on $2: 0"; }
# the start's own lines: strict mode, Flyway, the client's requests (method and path, counted), the re-index line
STRICT='Multiple Spring Data modules found|Could not safely identify store assignment|Finished Spring Data repository scanning|Bootstrapping Spring Data'
startlines() { local f=$1
  echo "  the start's repository lines, whole, as printed (each counted; the logger's prefix cut, the candidate's advice after its first clause cut):"
  $G -E "$STRICT" "$f" | sed -E 's/^.*\] [^ ]+ +: //; s/(candidate interface [A-Za-z.]+);.*$/\1/' | mask | sort | uniq -c | sed -E 's/^ +([0-9]+) /    (x\1) /'
  echo "  of them \"Could not safely identify\": $($G -c 'Could not safely identify store assignment' "$f" || true) · naming Dishes: $($G 'Could not safely identify store assignment' "$f" | $G -c 'interface com.tiffinbox.web.Dishes;' || true) - by module: $($G 'Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.Dishes;' "$f" | sed -E 's/^.*: (Spring Data [A-Za-z ]+) - Could not.*$/\1/' | sort | paste -sd',' - | sed 's/,/, /g') · \"Multiple Spring Data modules found\": $($G -c 'Multiple Spring Data modules found' "$f" || true)"
  echo "  the start's other lines:"
  $G -oE 'HHH000001: Hibernate ORM core version [^ ]+|Successfully applied [0-9]+ migrations?|tiffinbox +: (dishes re-indexed: .*|kitchen value: +[0-9]+)' "$f" | sed -E 's/^tiffinbox +: /tiffinbox: /' | sort | uniq -c | sed -E 's/^ +([0-9]+) /    (x\1) /'
  echo "  the client's requests, by its trace logger (co.elastic.clients.transport.rest5_client.low_level.Request at TRACE), method and path, in order, each run of the same counted:"
  $G -oE "Request +: curl -iX [A-Z]+ 'http://127\.0\.0\.1:[0-9]+/[^'?]*" "$f" | sed -E "s/^Request +: curl -iX //; s#'http://127\.0\.0\.1:[0-9]+#<es>#" | uniq -c | sed -E 's/^ +([0-9]+) /    (x\1) /'
  echo "  the hosts those requests went to: $($G -oE "Request +: curl -iX [A-Z]+ 'http://127\.0\.0\.1:[0-9]+" "$f" | sed -E 's/^.*(127\.0\.0\.1:[0-9]+)$/\1/' | sort -u | paste -sd' ' -)"
  echo "  the index creation, as the client sent it (PUT /dishes, the body whole): $($G -oE "curl -iX PUT 'http://127\.0\.0\.1:[0-9]+/dishes' -d '.*'$" "$f" | sed -E "s/^.* -d '//; s/'$//" | head -1)"
  echo "  the wait lines (\"Waiting\"/\"retry\" naming Elasticsearch): $($G -iE 'elasticsearch' "$f" | $G -ciE 'waiting|retry' || true)"; }
# the requests a TiffinBox JVM's client sent after line N0 of its log: method and path (the document's path whole), in order
reqsince() { tail -n +$(($2 + 1)) "$1" | $G -oE "Request +: curl -iX [A-Z]+ 'http://127\.0\.0\.1:[0-9]+/[^']*'" | sed -E "s/^Request +: curl -iX //; s#'http://127\.0\.0\.1:[0-9]+#'<es>#; s/\?search_type=query_then_fetch&typed_keys=true//" | paste -sd'|' - | sed 's/|/ · /g'; }
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
  o=$(python3 -I -B harness/chk22.py "$nm" "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk22 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -5 >&3; die "$nm: its check failed (harness/chk22.py)"; }
  VALS="$VALS${VALS:+ · }$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }
dockeq() { local v i c n
  i=$(dk images -q --no-trunc 2> /dev/null | sort -u | paste -sd' ' -); v=$(vols)
  c=$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null | wc -l | tr -d ' ')
  n=$(find "$M2" -type f | wc -l | tr -d ' ')
  [ "$i" = "$IMGS0" ] || die "$1: the images moved - nothing may be pulled"
  [ "$v" = "$2" ] || die "R.322: $1: the volume count is $v, not $2"
  [ "$c" = 0 ] || die "$1: a Testcontainers container is still there after the run ($c)"
  [ "$n" = "$NF0" ] || die "$1: .m2-demo gained files ($NF0 -> $n) - offline: no"
  echo "  after it: images $NI0 (the same list) · volumes $v (the count before it) · Testcontainers containers 0 · .m2-demo's files unchanged"; }
MPRE=""
mvnrun() { local d=$1 l=$2 a=$3 e=0 n v0
  v0=$(vols)
  echo "\$ cd $d && ${MPRE:+$MPRE }$MV $a"
  (cd "$d" && eval "${MPRE:+$MPRE }$MV $a") > .harness/$l.log 2>&1 < /dev/null & mpid=$!; wait "$mpid" || e=$?; mpid=""
  [ "$e" != 142 ] || die "$l: Maven's alarm fired (exit 142, cap 600 - R.247)"
  n=$($G -cE '^\[INFO\] Download(ing|ed) from ' .harness/$l.log || true)
  echo "  exit $e · $($G -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/$l.log || echo 'no BUILD line') · offline: $( [ "$n" = 0 ] && echo yes || echo "no - $n lines say Maven downloaded") · its alarm's cap: 600 (R.247)"
  [ "$n" = 0 ] || die "$l: Maven downloaded"
  dockeq "$l" "$v0"; }
results() { $G -E '^\[(INFO|WARNING|ERROR)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | sed -E 's/^\[[A-Z]+\] /  Surefire'"'"'s Results line: /'; }
SR=tiffinbox-web/target/surefire-reports; SRI=tiffinbox-web/target/surefire-reports-it
pgr() { python3 -I harness/surefire.py "$1" | sed 's/^/  /'; }
# the ITs' containers, while mvn verify runs: Docker's own list of each, polled on a count (R.412) - the pinned bindings 20615 and 20578
tcpoll() { local i=0 l m; : > .harness/tc-es.txt; : > .harness/tc-mongo.txt
  while kill -0 "$1" 2> /dev/null && [ $i -lt 4800 ]; do
    if [ ! -s .harness/tc-es.txt ]; then l=$(dk ps --filter label=org.testcontainers=true --filter ancestor=$EIMG --format '{{.Ports}}' 2> /dev/null | sed -n 1p); case "$l" in *9200*) printf '%s\n' "$l" > .harness/tc-es.txt ;; esac; fi
    if [ ! -s .harness/tc-mongo.txt ]; then m=$(dk ps --filter label=org.testcontainers=true --filter ancestor=$MIMG --format '{{.Ports}}' 2> /dev/null | sed -n 1p); case "$m" in *27017*) printf '%s\n' "$m" > .harness/tc-mongo.txt ;; esac; fi
    [ -s .harness/tc-es.txt ] && [ -s .harness/tc-mongo.txt ] && break; sleep 0.1; i=$((i + 1)); done; }
# h22 MODE...: the harness JVM (probe.u22.H22) on after/'s jar, from .harness/run-h; its lines: PROBE, the client's requests (TRACE,
# method and path, and the body where the request is the subject), the transaction's ERROR line, Hibernate's insert
h22() { local e=0
  echo "\$ cd .harness/run-h && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -Dlogback.configurationFile=../../harness/logback.xml -Dh22.es=20614${H22DB:+ -Dh22.jdbc=jdbc-url} -cp \"../hc:../after/$XD/tiffinbox-web-1.0.0.jar:../after/$XD/lib/*\" probe.u22.H22 $*"
  (cd .harness/run-h && exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -Dlogback.configurationFile=../../harness/logback.xml -Dh22.es=20614 ${H22DB:+-Dh22.jdbc=jdbc-url} -cp "../hc:../after/$XD/tiffinbox-web-1.0.0.jar:../after/$XD/lib/*" probe.u22.H22 "$@") > .harness/h22.log 2>&1 < /dev/null & pid=$!
  wait "$pid" || e=$?; pid=""
  $G -E "^PROBE |^TRACE \[main\] co\.elastic\.clients\.transport\.rest5_client\.low_level\.Request : curl |^ERROR |^DEBUG \[main\] org\.hibernate\.SQL : insert " .harness/h22.log | sed -E "s/^TRACE \[main\] [^ ]+ : curl -iX /  request: /; s/^DEBUG \[main\] org\.hibernate\.SQL : /  Hibernate's SQL: /; s/^ERROR \[main\] ([^ ]+) : /  ERROR \1: /; s#'http://127\.0\.0\.1:20614#'<es>#; s/\?search_type=query_then_fetch&typed_keys=true//" | sed -E "s/^(  request: [A-Z]+ '[^']*')( -d '.*')?$/\1\2/" | eval "$H22F"
  echo "  the harness JVM's exit $e"; }
H22F=cat

# ---- the captures --------------------------------------------------------------------------------------------------------------
tests() { local e=0 n v0
  echo "-- the tests: after/ copied to .harness/tests; mvn package with Maven's DOCKER_HOST pointed at nothing (tcp://127.0.0.1:1), offline:"
  rm -rf .harness/tests/tiffinbox-web/target .harness/tests/tiffinbox-core/target
  MPRE="env DOCKER_HOST=tcp://127.0.0.1:1"; mvnrun .harness/tests package "\"$AL\" clean package -pl tiffinbox-web -am"; MPRE=""
  echo "  Surefire's reports, $SR:"; pgr .harness/tests/$SR; echo "  $SRI: $( [ -d .harness/tests/$SRI ] && echo present || echo 'absent - no container test ran')"
  results .harness/package.log
  echo "  the package log: lines naming 9200 $($G -c 9200 .harness/package.log || true) · lines naming 27017 $($G -c 27017 .harness/package.log || true)"
  echo "-- then mvn verify, the anchor's recipe (DOCKER_HOST on the pinned socket, Ryuk off - TESTCONTAINERS_RYUK_DISABLED=true, a receipt home), offline:"
  [ "$(listeners 20578)" = 0 ] && [ "$(listeners 20615)" = 0 ] || die "20578 or 20615 (the ITs' pinned bindings) is bound before mvn verify"
  echo "  before it: listening on 20578 (the Mongo IT's pinned binding): 0 · on 20615 (the Elasticsearch IT's): 0"
  rm -rf .harness/tests/tiffinbox-web/target .harness/tests/tiffinbox-core/target
  v0=$(vols)
  echo "\$ cd .harness/tests && $MV \"$AL\" clean verify -pl tiffinbox-web -am"
  (cd .harness/tests && eval "$MV \"$AL\" clean verify -pl tiffinbox-web -am") > .harness/verify.log 2>&1 < /dev/null & mpid=$!
  tcpoll "$mpid"; wait "$mpid" || e=$?; mpid=""
  [ "$e" != 142 ] || die "verify: Maven's alarm fired (exit 142, cap 600 - R.247)"
  n=$($G -cE '^\[INFO\] Download(ing|ed) from ' .harness/verify.log || true)
  echo "  exit $e · $($G -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/verify.log || echo 'no BUILD line') · offline: $( [ "$n" = 0 ] && echo yes || echo "no - $n lines say Maven downloaded") · its alarm's cap: 600 (R.247)"
  [ "$n" = 0 ] || die "verify: Maven downloaded"
  dockeq verify "$v0"
  echo "  the Elasticsearch IT's container while verify ran, Docker's own list (dk ps, polled on a count): Ports $(sed 's/[[:space:]]*$//' .harness/tc-es.txt) · listening on 20615 after it: $(listeners 20615)"
  echo "  the Mongo IT's container while verify ran: Ports $(sed 's/[[:space:]]*$//' .harness/tc-mongo.txt) · listening on 20578 after it: $(listeners 20578)"
  echo "  Surefire's reports, $SR:"; pgr .harness/tests/$SR
  echo "  Surefire's reports, $SRI:"; pgr .harness/tests/$SRI
  results .harness/verify.log
  $G -E '^ES IT ' .harness/verify.log | sed 's/^/  /'
  echo "  the verify log: 'Creating container for image' $($G -c 'Creating container for image: ' .harness/verify.log || true) · 'Pulling' $($G -c 'Pulling' .harness/verify.log || true) · Testcontainers containers after it: $(dk ps -aq --filter label=org.testcontainers=true | $G -c . || true)"
  local J=.m2-demo/org/testcontainers/testcontainers-elasticsearch/2.0.5/testcontainers-elasticsearch-2.0.5.jar
  echo "  Testcontainers' own ElasticsearchContainer, read off its jar (unzip -p): the memory file elasticsearch-default-memory-vm.options -> $(unzip -p $J elasticsearch-default-memory-vm.options | $G -v '^#' | $G . | paste -sd' ' -) · the class file's strings, each present or not: $(unzip -p $J org/testcontainers/elasticsearch/ElasticsearchContainer.class | python3 -I -c 'import sys; b=sys.stdin.buffer.read(); print(" · ".join(s + (" present" if s.encode() in b else " absent") for s in ("ELASTIC_PASSWORD", "changeme", "xpack.security.enabled", "cluster.routing.allocation.disk.threshold_enabled", "discovery.type")))')"; }
compose() { local vb
  vb=$(vols)
  echo "-- the Compose window: after/ under dev, Boot's Docker Compose support on, the shipped compose.yaml (cmp: after/'s), from .harness/compose-run; no spring.* address key - Boot hands them over:"
  for p in 18881 18882 18883 18884; do [ "$(listeners $p)" = 0 ] || die "$p is bound before the Compose window"; done
  [ -z "$(dk volume ls -q --filter name=^$PROJ)" ] && [ -z "$(dk network ls -q --filter name=^$PROJ)" ] || die "a $PROJ volume or network exists before the window"
  echo "  before it: listening on 18881-18884 0 · $PROJ volumes 0 · $PROJ networks 0 · volumes $(vols) (the machine's $VOL0 + the unit's containers') · the four tags present, on the digests (checked at the start)"
  echo "\$ cd .harness/compose-run && DOCKER_HOST=\$DH perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -cp \"<after/'s classes>:<Maven's runtime class path for after/>\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=20610 --spring.profiles.active=dev $TRL"
  CMPW=1
  (cd .harness/compose-run && DOCKER_HOST="$DH" exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -cp "../after/tiffinbox-web/target/classes:$(cat ../after/tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=20610 --spring.profiles.active=dev $TRL) > .harness/compose.log 2>&1 < /dev/null & pid=$!
  local i=0 c TBUP=0 n0; while [ $i -lt 1200 ]; do c=$(cu 20610 /actuator/health/readiness); [ "$c" = 200 ] && { TBUP=1; break; }; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  [ "$TBUP" = 1 ] || { tail -20 .harness/compose.log | mask >&3; die "after/ under dev with Compose did not start"; }
  CMPV=$(dk inspect -f '{{range .Mounts}}{{.Name}} {{end}}' ${PROJ}-mongo-1 2> /dev/null)
  echo "  the project's containers: $(dk ps --filter label=com.docker.compose.project=$PROJ --format '{{.Names}} {{.Ports}}' | sort | paste -sd'|' -)"
  echo "  the elasticsearch service's container: its Mounts: $(m=$(mounts ${PROJ}-elasticsearch-1); echo "${m:-none}") · the mongo service's: $(mounts ${PROJ}-mongo-1) · volumes now $(vols)"
  echo "  the start's lines: $($G -oE 'Successfully applied [0-9]+ migrations?|tiffinbox +: (dishes re-indexed: .*|kitchen value: +[0-9]+)' .harness/compose.log | sed -E 's/^tiffinbox +: /tiffinbox: /' | sort | uniq -c | sed -E 's/^ +//' | paste -sd'|' -)"
  echo "  the hosts the client's requests went to (its trace logger): $($G -oE "Request +: curl -iX [A-Z]+ 'http://127\.0\.0\.1:[0-9]+" .harness/compose.log | sed -E 's/^.*(127\.0\.0\.1:[0-9]+)$/\1/' | sort -u | paste -sd' ' -) · the Compose service's own published port (dk port): $(dk port ${PROJ}-elasticsearch-1 | paste -sd'|' -)"
  echo "  curl on 18884 (the elasticsearch service): _cat/indices dishes -> $(catix 18884 dishes) · match name veg -> $(hits 18884 dishes '{"query":{"match":{"name":"veg"}}}')"
  n0=$(wc -l < .harness/compose.log)
  echo "  POST /dishes {\"name\":\"$NEWD\",\"mealType\":\"VEG\",\"price\":110} (TiffinBox) -> $(post 20610 "$NEWD" VEG 110) $(tr -d '\n' < .harness/body)"
  echo "  the rows (psql, Compose's PostgreSQL, the postgres service's own client): select count(*) from dish -> $(psq ${PROJ}-postgres-1 tiffinbox 'select count(*) from dish') · the index (curl on 18884): _count -> $(cnt 18884 dishes) · the listener's requests: $(reqsince .harness/compose.log $n0)"
  tbstop compose-run 20610
  echo "  after TiffinBox stopped (Boot's own compose stop): the project's containers $(dk ps -a --filter label=com.docker.compose.project=$PROJ --format '{{.Names}} {{.State}}' | sort | paste -sd'|' -) · volumes $(vols)"
  echo "\$ cd .harness/compose-run && docker -H \"\$DH\" compose -p $PROJ down"
  (cd .harness/compose-run && dk compose -p $PROJ down) > .harness/compose-down.log 2>&1 || die "compose down failed: $(tail -2 .harness/compose-down.log)"
  echo "  then: the project's containers $(dk ps -aq --filter label=com.docker.compose.project=$PROJ | $G -c . || true) · its networks $(dk network ls -q --filter name=^$PROJ | $G -c . || true) · volumes $(vols) · $PROJ volumes by name: $(dk volume ls -q --filter name=^$PROJ | paste -sd' ' -) · the mongo service's two: $(for v in $CMPV; do dk volume inspect $v > /dev/null 2>&1 && echo present || echo gone; done | paste -sd' ' -)"
  echo "\$ cd .harness/compose-run && docker -H \"\$DH\" compose -p $PROJ down -v"
  (cd .harness/compose-run && dk compose -p $PROJ down -v) > .harness/compose-downv.log 2>&1 || die "compose down -v failed: $(tail -2 .harness/compose-downv.log)"
  echo "  then: volumes $(vols) · $PROJ volumes by name: $(dk volume ls -q --filter name=^$PROJ | $G -c . || true) · the mongo service's two: $(for v in $CMPV; do dk volume inspect $v > /dev/null 2>&1 && echo present || echo gone; done | paste -sd' ' -)"
  for v in $CMPV; do dk volume rm "$v" > /dev/null 2>&1 || die "the volume could not be removed"; done
  CMPW=""; CMPV=""
  [ "$(vols)" = "$vb" ] || die "after the Compose window the volume count is $(vols), not $vb (the count before it)"
  echo "  the receipt removes the mongo service's two by the names its container listed (dk volume rm): volumes $(vols) = before the window · listening on 18881-18884: $(( $(listeners 18881) + $(listeners 18882) + $(listeners 18883) + $(listeners 18884) ))"; }
anchor() { local n0
  cat .harness/anchor-tests.out
  echo "-- the jar's libraries (ls lib | wc -l), before/ and after/, and the jars after/ gained or lost (comm, by name):"
  for t in before after; do echo "  $t/: $(ls .harness/$t/$XD/lib | wc -l | tr -d ' ') libraries"; done
  echo "  gained: $(comm -13 <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c . || true) · lost: $(comm -23 <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c . || true)"
  echo "  the version lines off the jar names: $(ls .harness/after/$XD/lib | $G -xE 'spring-boot-4\.1\.2\.jar|spring-data-elasticsearch-6\.1\.2\.jar|elasticsearch-java-9\.4\.8\.jar|elasticsearch-rest5-client-9\.4\.8\.jar|spring-tx-[0-9.]+\.jar' | sort | paste -sd' ' -)"
  echo "-- after/ under the profile dev, on PostgreSQL + Redis + MongoDB + Elasticsearch (the four containers, by the digest), a fresh database, an emptied Redis, a fresh MongoDB, Compose off; the index dishes removed first:"
  eq 20614 DELETE /dishes > /dev/null
  echo "  curl DELETE /dishes on 20614, then _cat/indices dishes* -> $(m=$(catix 20614 'dishes*'); echo "${m:-none}")"
  echo "  the overrides: $DEV --management.endpoints.web.exposure.include=health,prometheus,beans (the datasource from the config tree, the password never on a command line; /actuator/beans for this run only)"
  freshmongo; flush; pgdb u22anchor
  tb after run-pg 20610 $DEV --management.endpoints.web.exposure.include=health,prometheus,beans
  [ "$TBUP" = 1 ] || { tail -20 .harness/tb.log | mask >&3; die "after/ under dev did not start"; }
  echo "  S8.84: the key spring.elasticsearch.uris on that command line: $(printf '%s\n' "$TBCL" | $G -o -- '--spring.elasticsearch.uris=' | $G -c .) - the one URI $(printf '%s\n' "$TBCL" | $G -oE -- '--spring.elasticsearch.uris=[^ ]+' | sed 's/^--spring.elasticsearch.uris=//')"
  startlines .harness/tb.log
  echo "  the rows (psql, the unit's PostgreSQL): select count(*) from dish -> $(psq $CN u22anchor 'select count(*) from dish') · the index (curl on 20614): _cat/indices dishes -> $(catix 20614 dishes)"
  echo "  GET /dishes/search?q=veg (TiffinBox) -> $(cu 20610 '/dishes/search?q=veg') $(tr -d '\n' < .harness/body)"
  echo "  curl: POST /dishes/_search match name veg, highlight name -> $(hlits 20614 dishes '{"query":{"match":{"name":"veg"}},"highlight":{"fields":{"name":{}}}}')"
  n0=$(wc -l < .harness/tb.log)
  echo "  POST /dishes {\"name\":\"$NEWD\",\"mealType\":\"VEG\",\"price\":110} (TiffinBox) -> $(post 20610 "$NEWD" VEG 110) $(tr -d '\n' < .harness/body)"
  echo "  the listener's requests, by the client's trace logger (after the POST, before any other request): $(reqsince .harness/tb.log $n0)"
  echo "  then the rows (psql): select count(*) from dish -> $(psq $CN u22anchor 'select count(*) from dish') · select id from dish where name = the new dish -> $(psq $CN u22anchor "select id from dish where name = '$NEWD'") · the index (curl): _count -> $(cnt 20614 dishes) · _doc/11's _source -> $(eq 20614 GET /dishes/_doc/11 | python3 -I -c 'import json,sys; print(json.dumps(json.load(sys.stdin).get("_source"), sort_keys=True))')"
  echo "  GET /dishes/search?q=mushroom (TiffinBox) -> $(cu 20610 '/dishes/search?q=mushroom') $(tr -d '\n' < .harness/body) · curl: match name mushroom -> $(hits 20614 dishes '{"query":{"match":{"name":"mushroom"}}}')"
  for l in /revenue/by-customer /kitchen /menu/day-19 /actuator/health; do f=$(cu 20610 $l)
    case $l in /menu/day-19) echo "  GET $l -> $f $(tr -d '\n' < .harness/body | cut -c1-60)…" ;; *) echo "  GET $l -> $f $(tr -d '\n' < .harness/body | cut -c1-300)" ;; esac; done
  cu 20610 /actuator/beans > /dev/null
  echo "  /actuator/beans (this run's override): the beans by name (1 present, 0 absent): $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); k={n for c in d["contexts"].values() for n in c["beans"]}; print(" · ".join(n + " " + ("1" if n in k else "0") for n in ("dishes", "dishSearch", "dishWrite", "dishService", "dishIndexSync", "elasticsearchClient")))' .harness/body) · the PlatformTransactionManager beans: $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(sorted(k + " " + b["type"].split(".")[-1] for c in d["contexts"].values() for k, b in c["beans"].items() if b["type"].endswith("TransactionManager")))' .harness/body)"
  [ "$CAPRUN" != 1 ] || dk stats --no-stream --format '{{.Name}} {{.MemUsage}}' $CN $RN $MN $EN > .harness/stats-four.txt 2>&1 || true
  echo "  dk stats --no-stream with the four stores alive: read into the receipt's log, never this capture (resident sizes move)"
  tbstop run-pg 20610
  echo "-- a second dev start of after/ on the SAME database (u22anchor: its 11 rows), an emptied Redis, a fresh MongoDB: the start deletes and re-saves:"
  echo "  curl: _count dishes before it -> $(cnt 20614 dishes)"
  freshmongo; flush
  tb after run-pg 20610 $DEV
  [ "$TBUP" = 1 ] || { tail -20 .harness/tb.log | mask >&3; die "after/'s second dev start did not start"; }
  echo "  the start's re-index line: $($G -oE 'dishes re-indexed: .*' .harness/tb.log)"
  echo "  the rows (psql): $(psq $CN u22anchor 'select count(*) from dish') · the index (curl): _count -> $(cnt 20614 dishes) · match name mushroom -> $(hits 20614 dishes '{"query":{"match":{"name":"mushroom"}}}')"
  tbstop run-pg 20610
  psq $CN postgres "drop database u22anchor with (force)" > /dev/null
  compose; }
mapping() {
  echo "-- mapping: the shipped index dishes on 20614 (as anchor's starts left it), by curl, beside Dish.java's annotations:"
  echo "  Dish.java's annotation lines, by line number (after/):"; $G -nE '^@Document|^@Setting|^ +@Field|record Dish\(@Id' after/tiffinbox-web/src/main/java/com/tiffinbox/web/Dish.java | sed -E 's/^ *//; s/^([0-9]+):/    line \1: /'
  echo "  curl: GET /dishes/_mapping -> $(eq 20614 GET /dishes/_mapping | python3 -I -c 'import json,sys; p=json.load(sys.stdin)["dishes"]["mappings"]["properties"]; print(" · ".join(k + " " + json.dumps(p[k], sort_keys=True) for k in sorted(p)))')"
  echo "  curl: GET /dishes/_settings (flat; its analysis and replicas) -> $(eq 20614 GET '/dishes/_settings?flat_settings=true' | python3 -I -c 'import json,sys; s=json.load(sys.stdin)["dishes"]["settings"]; print(" · ".join(k + " " + json.dumps(s[k]) for k in sorted(s) if k.startswith("index.analysis") or k in ("index.number_of_replicas", "index.number_of_shards")))')"
  echo "  curl: GET /dishes/_doc/1 -> _source $(eq 20614 GET /dishes/_doc/1 | python3 -I -c 'import json,sys; print(json.dumps(json.load(sys.stdin)["_source"], sort_keys=True))')"
  echo "  the Java side: the index creation the client sent at anchor's start (PUT /dishes, its body) - anchor's capture prints it whole (\"the index creation, as the client sent it\")"; }
requests() { local b
  echo "-- requests: the three ways to ask, by the harness on the unit's index dishes (20614), each request by the client's trace logger; then curl re-sends each body to _search:"
  h22 requests
  for b in '{"query":{"bool":{"must":[{"query_string":{"default_operator":"and","fields":["name"],"query":"veg"}}]}},"size":1}' '{"query":{"bool":{"must":[{"query_string":{"default_operator":"and","fields":["name"],"query":"veg"}}]}},"size":10000}' '{"query":{"match":{"name":{"query":"veg"}}},"size":10}' '{"query":{"prefix":{"name":{"value":"veg"}}},"size":10}'; do
    p=$(hits 20614 dishes "$b"); echo "  curl: POST /dishes/_search $b -> $p"; done; }
highlight() {
  echo "-- highlight: Dishes.searchByName, the shipped repository's highlighted search, by the harness on the unit's index dishes (20614); then curl's _search with a highlight block on name:"
  h22 highlight
  for q in veg vegetarian lunch; do echo "  curl: match name $q, highlight name -> $(hlits 20614 dishes '{"query":{"match":{"name":"'$q'"}},"highlight":{"fields":{"name":{}}}}')"; done
  echo "  the route's half (GET /dishes/search with the fragment, TiffinBox): anchor's capture prints it (\"GET /dishes/search?q=veg (TiffinBox)\")"; }
nrt() { local d='{"name":"Vegetarian Lunch Box","mealType":"VEG","price":110}'
  echo "-- nrt, the REST half: curl alone, on a scratch index dishes_nrt of the unit's Elasticsearch (20614), made and deleted here; one document, then a count and a search - the three requests in one curl:"
  for r in none wait_for true; do
    eq 20614 DELETE /dishes_nrt > /dev/null
    echo "  PUT /dishes_nrt (number_of_replicas 0) -> $(eq 20614 PUT /dishes_nrt '{"settings":{"number_of_replicas":0}}' | ack)"
    case $r in none) u=/dishes_nrt/_doc/1 ;; *) u="/dishes_nrt/_doc/1?refresh=$r" ;; esac
    # the write, the count and the search in ONE curl (--next): three requests one after the other on one connection, no process between
    echo "  PUT $u -> $(curl -s --noproxy '*' -H 'Content-Type: application/json' -X PUT "http://127.0.0.1:20614$u" --data-binary "$d" -w '\n' --next -s --noproxy '*' -w '\n' "http://127.0.0.1:20614/dishes_nrt/_count" --next -s --noproxy '*' -H 'Content-Type: application/json' -X POST "http://127.0.0.1:20614/dishes_nrt/_search" --data-binary '{"query":{"match_all":{}}}' -w '\n' 2> /dev/null | python3 -I -c 'import json,sys; w,c,s=[json.loads(l) for l in sys.stdin if l.strip()]; i=sorted(h["_id"] for h in s["hits"]["hits"]); print("result " + str(w.get("result")) + " · forced_refresh " + str(w.get("forced_refresh", False)).lower() + " · then _count -> " + str(c.get("count")) + " · _search match_all -> " + str(s["hits"]["total"]["value"]) + " [" + ", ".join(i) + "]")')"; done
  echo "  DELETE /dishes_nrt -> $(eq 20614 DELETE /dishes_nrt | ack)"
  echo "-- nrt, the Spring half: the harness on its own scratch index dishes_nrt_j (the shipped Dish's settings and analyzer, a harness record NrtDish), three saves, a fresh index for each:"
  h22 nrt
  echo "  curl: _cat/indices dishes_nrt* after it -> $(m=$(catix 20614 'dishes_nrt*'); echo "${m:-none}")"; }
stale() {
  echo "-- stale: the search that misses the document just saved - the template's save, then a count; the control, the repository's save, then a count; each on a fresh dishes_nrt_j (the harness):"
  h22 stale
  echo "  curl: _cat/indices dishes_nrt* after it -> $(m=$(catix 20614 'dishes_nrt*'); echo "${m:-none}")"; }
sync() { local n0
  echo "-- sync: the anchor's shape on the unit's stores - after/ under dev, a fresh database (u22sync), then POST /dishes twice, then a second start on the same database; rows (psql) beside documents (curl's _count) at each step:"
  eq 20614 DELETE /dishes > /dev/null
  freshmongo; flush; pgdb u22sync
  tb after run-pg 20610 $DEV
  [ "$TBUP" = 1 ] || { tail -20 .harness/tb.log | mask >&3; die "after/ under dev did not start (sync)"; }
  echo "  after the start: $($G -oE 'dishes re-indexed: .*' .harness/tb.log) · rows $(psq $CN u22sync 'select count(*) from dish') · documents $(cnt 20614 dishes)"
  n0=$(wc -l < .harness/tb.log)
  echo "  POST /dishes $NEWD -> $(post 20610 "$NEWD" VEG 110) $(tr -d '\n' < .harness/body) · the listener's requests: $(reqsince .harness/tb.log $n0) · rows $(psq $CN u22sync 'select count(*) from dish') · documents $(cnt 20614 dishes)"
  n0=$(wc -l < .harness/tb.log)
  echo "  POST /dishes $NEWD2 -> $(post 20610 "$NEWD2" VEGAN 130) $(tr -d '\n' < .harness/body) · the listener's requests: $(reqsince .harness/tb.log $n0) · rows $(psq $CN u22sync 'select count(*) from dish') · documents $(cnt 20614 dishes)"
  echo "  POST /dishes $NEWD again (the name is the table's unique key) -> $(post 20610 "$NEWD" VEG 110) · rows $(psq $CN u22sync 'select count(*) from dish') · documents $(cnt 20614 dishes)"
  tbstop run-pg 20610
  freshmongo; flush
  tb after run-pg 20610 $DEV
  [ "$TBUP" = 1 ] || { tail -20 .harness/tb.log | mask >&3; die "after/'s second dev start did not start (sync)"; }
  echo "  the second start on u22sync: $($G -oE 'dishes re-indexed: .*' .harness/tb.log) · rows $(psq $CN u22sync 'select count(*) from dish') · documents $(cnt 20614 dishes) · ids (psql) $(psq $CN u22sync 'select id from dish order by id' | paste -sd',' -) · ids (curl, match_all) $(hits 20614 dishes '{"query":{"match_all":{}},"size":20}')"
  tbstop run-pg 20610
  psq $CN postgres "drop database u22sync with (force)" > /dev/null; }
drift() { local m
  echo "-- drift: the harness plants a failure - probe.u22.H22 on after/'s jar, JPA's manager only, the HARNESS's PostgreSQL $HN (127.0.0.1:20616; a fresh database per mode, Flyway V1-V4 run by the harness), the harness's own index dishes_drift on the unit's Elasticsearch (20614), made by the harness and deleted after each mode:"
  for m in intx listener control; do
    psq $HN postgres "drop database if exists h22$m with (force)" > /dev/null; psq $HN postgres "create database h22$m" > /dev/null
    (umask 077 && printf 'jdbc:postgresql://127.0.0.1:20616/h22%s?user=tiffinbox&password=%s\n' "$m" "$PW" > .harness/run-h/jdbc-url) || die "the URL was not written"
    echo "-- mode $m (a fresh database h22$m on $HN):"
    H22DB=1; h22 drift $m; H22DB=""
    echo "  rows, PostgreSQL's own answer (psql on $HN, h22$m): the new dish ($(sed -n 's/^    static final String NEW_NAME = "\(.*\)";$/\1/p' harness/src/probe/u22/H22.java)) $(psq $HN h22$m "select count(*) from dish where name = 'Garden Pea Soup'") · all rows $(psq $HN h22$m 'select count(*) from dish') · the index, curl's _count on dishes_drift -> $(cnt 20614 dishes_drift)"
    echo "  DELETE /dishes_drift -> $(eq 20614 DELETE /dishes_drift | ack)"
    psq $HN postgres "drop database h22$m with (force)" > /dev/null; done; }
default() {
  echo "-- after/ with no profile (TiffinBox's default run): H2 in memory, Docker at nothing (DOCKER_HOST=tcp://127.0.0.1:1), no Elasticsearch, no MongoDB; one JVM; /actuator/beans exposed for this run (a command-line override, the one beside the port):"
  DOCKER_HOST=tcp://127.0.0.1:1 tb after run-h2 20610 --management.endpoints.web.exposure.include=health,prometheus,beans
  [ "$TBUP" = 1 ] || { tail -20 .harness/tb.log | mask >&3; die "after/'s default run did not start"; }
  echo "  GET /actuator/health -> $(cu 20610 /actuator/health) $(tr -d '\n' < .harness/body | cut -c1-200)"
  echo "  GET /dishes/search?q=veg -> $(cu 20610 '/dishes/search?q=veg') · GET /revenue/by-customer -> $(cu 20610 /revenue/by-customer) · GET /menu/day-19 -> $(cu 20610 /menu/day-19) · GET /revenue -> $(cu 20610 /revenue) $(tr -d '\n' < .harness/body) · GET /kitchen -> $(cu 20610 /kitchen) $(tr -d '\n' < .harness/body)"
  echo "  POST /dishes {\"name\":\"$NEWD\",...} -> $(post 20610 "$NEWD" VEG 110)"
  cu 20610 /actuator/beans > /dev/null
  echo "  /actuator/beans: the beans by name (1 present, 0 absent): $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); k={n for c in d["contexts"].values() for n in c["beans"]}; print(" · ".join(n + " " + ("1" if n in k else "0") for n in ("dishes", "dishSearch", "dishWrite", "dishService", "dishIndexSync", "elasticsearchClient")))' .harness/body) · a bean whose type names Elasticsearch $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(sum(1 for c in d["contexts"].values() for b in c["beans"].values() if "lasticsearch" in b["type"]))' .harness/body)"
  tbstop run-h2 20610
  echo "  its log: lines naming 9200 $($G -c 9200 .harness/tb.log || true) · naming elasticsearch, any case $($G -ci elasticsearch .harness/tb.log || true) · naming 27017 $($G -c 27017 .harness/tb.log || true) · naming mongo, any case $($G -ci mongo .harness/tb.log || true) · Flyway: $($G -oE 'Successfully applied [0-9]+ migrations?' .harness/tb.log)"
  echo "-- the 18 under mvn -o package with Docker at nothing (anchor's tests, the same run's package log):"
  results .harness/package.log; }
absent() {
  echo "-- absent: after/ under dev with PostgreSQL, Redis and a fresh MongoDB up and Elasticsearch absent - spring.elasticsearch.uris on 127.0.0.1:20619, where nothing listens:"
  [ "$(listeners 20619)" = 0 ] || die "20619 is bound - absent needs nothing there"
  echo "  listening on 20619: 0"
  freshmongo; flush; pgdb u22absent
  tb after run-pg 20610 $DEVB --spring.elasticsearch.uris=http://127.0.0.1:20619
  [ "$TBUP" = 0 ] || die "after/ under dev started with Elasticsearch absent"
  TBX=0; wait "$pid" || TBX=$?; pid=""
  echo "  S8.84: the key spring.elasticsearch.uris on that command line: $(printf '%s\n' "$TBCL" | $G -o -- '--spring.elasticsearch.uris=' | $G -c .) - the one URI $(printf '%s\n' "$TBCL" | $G -oE -- '--spring.elasticsearch.uris=[^ ]+' | sed 's/^--spring.elasticsearch.uris=//')"
  echo "  readiness never answered 200 · the JVM's exit $TBX · listening on 20610: $(listeners 20610)"
  echo "  the failure, as printed (its first lines naming the bean and the cause; the logger's prefix cut):"
  $G -oE "Error creating bean with name '[a-zA-Z]+'[^:]*|DataAccessResourceFailureException: [^;]*|Connection refused[^;]*" .harness/tb.log | sed -E 's/ +$//' | sort -u | mask | sed 's/^/    /'
  echo "  its log: lines naming 20619 $($G -c 20619 .harness/tb.log || true) · the hosts its client tried (Connect to ...): $($G -oE 'Connect to http://127\.0\.0\.1:[0-9]+' .harness/tb.log | sort -u | paste -sd' ' -) · 'dishes re-indexed' $($G -c 'dishes re-indexed' .harness/tb.log || true)"
  psq $CN postgres "drop database u22absent with (force)" > /dev/null; }
seven() { local t i c e a port
  for t in before after; do i=0; e=0; [ $t = after ] && port=20610 || port=20617
    echo "-- the seven: $t/'s jar, java -jar, H2 in memory (a fresh JVM), port $port:"
    echo "\$ cd .harness/$t && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port"
    (cd .harness/$t && DOCKER_HOST=tcp://127.0.0.1:1 exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port) > .harness/seven-run.log 2>&1 < /dev/null & pid=$!
    while [ $i -lt 480 ]; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
      kill -0 "$pid" 2> /dev/null || { tail -20 .harness/seven-run.log | mask >&3; die "TiffinBox exited before readiness answered 200"; }
      sleep 0.25; i=$((i + 1)); done
    [ "$c" = 200 ] || die "readiness never answered 200 on $port"
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    echo "  GET /actuator/health/readiness -> 200 · GET /actuator/health -> $(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/actuator/health") · GET /dishes/search?q=veg -> $(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/dishes/search?q=veg") · listens on: $a"
    echo "\$ \$CURLSET $port .harness/$t/$TF"
    "$CURLSET" $port .harness/$t/$TF | $G ' -> ' | awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' > .harness/seven-$t.txt || true
    i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 480 ]; do sleep 0.25; i=$((i + 1)); done
    kill -0 "$pid" 2> /dev/null && die "TiffinBox on $port was still running after POST /shutdown"
    wait "$pid" || e=$?; pid=""
    [ "$(listeners $port)" = 0 ] || die "something still listens on $port"
    echo "  GET /revenue: $($G -E '^GET +/revenue ' .harness/seven-$t.txt | cut -d' ' -f2- | sed -E 's/^ +//')"
    echo "  exit $e · the seven responses: $(wc -l < .harness/seven-$t.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven-$t.txt) · listening on $port now: 0"
    ! $G -qF -- "$TOKEN" .harness/seven-run.log || die "TiffinBox's log held the token"; done
  echo "  the seven, after/ against before/: lines that differ: $(diff .harness/seven-before.txt .harness/seven-after.txt | $G -c '^[<>]' || true)"; }
# the unit's Elasticsearch container's sockets at the end of the receipt (S8.92): /proc/net/{tcp,tcp6,udp,udp6} read by cat, the
# listeners' ports, the connections by their local port (9200 or 9300 = incoming; any other = outbound), the UDP lines
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
sockread() { local t; for t in tcp tcp6 udp udp6; do dk exec $1 cat /proc/net/$t > .harness/net-$t.txt 2> /dev/null || : > .harness/net-$t.txt; done
  python3 -I -c "$SOCKPY" .harness/net-tcp.txt .harness/net-tcp6.txt .harness/net-udp.txt .harness/net-udp6.txt; }
sockets() {
  echo "-- sockets: $EN (the unit's Elasticsearch, alive since the stores started), its /proc/net/tcp, tcp6, udp and udp6 read by cat at the end of the receipt (dk exec - a file, never a shell):"
  echo "  its interfaces (/proc/net/dev): $(dk exec $EN cat /proc/net/dev | sed 1,2d | cut -d: -f1 | tr -d ' ' | sort | paste -sd',' -)"
  echo "  the sockets: $(sockread $EN)"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2 v1
  rm -rf .harness/ex; rm -f .harness/ex-*.st .harness/ex-*.out
  v1=$(vols)
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 4800 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after its cap"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines, the block's exit $e1:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "  then the solution's lines, in the same shell - the block's exit $e2:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines · listening on 20618 afterwards: $(listeners 20618) · the container $EX afterwards: $(dk ps -aq --filter name=^/$EX\$ | $G -c . || true) · volumes $(vols) (before the shell: $v1) · java processes of the exercise: $(ps -axo command= | $G -c '[S]aveLab.java' || true) · images afterwards: the same list $( [ "$(dk images -q --no-trunc 2> /dev/null | sort -u | paste -sd' ' -)" = "$IMGS0" ] && echo yes || echo no)"; }
exercise() {
  printf '%s\n' "$SETUP" > .harness/ex-readme.sh; printf '%s\n' "$SOL" > .harness/ex-sol.sh
  printf '%s\n' 'cd "$1" || exit 1' '. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-readme.st"' 'cd "$1" || exit 1' '. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-sol.st"' > .harness/ex-drive.sh
  echo "exercise/README.md's $(printf '%s\n' "$SETUP" | $G -c .) lines, then exercise/SOLUTION.md's, as written, one after the other in ONE env -i shell (HOME and the PATH this script was started with), started in this folder:"
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh; }

NCAP=1; cap exercise exercise; chk exercise .r-exercise.out "$EXW" "$EXQ"
for f in exercise/README.md exercise/SOLUTION.md; do
  w=$(python3 -I -B harness/chk22.py wib .r-exercise.out "$f"); [ "$(wib "$f")" = "$w" ] || die "$f's \"What it prints\" block is not what its lines printed: $(diff <(wib "$f") <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"; done
echo "  exercise: each file's \"What it prints\" block = what its lines printed (bash's; zsh's the same - chk22)"
pub exercise
NCAP=3
export DOCKER_HOST="$DH" TESTCONTAINERS_RYUK_DISABLED=true; tests > .harness/anchor-tests.raw 2>&1 || true; unset DOCKER_HOST TESTCONTAINERS_RYUK_DISABLED
$G -q '^  \*\*\* ' .harness/anchor-tests.raw && { cat .harness/anchor-tests.raw >&3; die "the tests stopped (above)"; }
mask < .harness/anchor-tests.raw > .harness/anchor-tests.out
echo "  the tests (anchor's Maven half): run once in this run of record - their 3/3 is across the runs; the three anchor captures each carry these lines"
startstores
cap anchor anchor; chk anchor .r-anchor.out; pub anchor
echo "  dk stats --no-stream with the four stores alive (anchor's first, read into this log, not a capture): $(paste -sd'|' .harness/stats-four.txt 2> /dev/null | sed 's/|/ · /g')"
echo "  _cat/indices dishes with docs.deleted (read into this log, not a capture - a merge moves it): $(eq 20614 GET '/_cat/indices/dishes?h=index,docs.count,docs.deleted' | sed -E 's/ +/ /g')"
cap mapping mapping; chk mapping .r-mapping.out; pub mapping
for c in requests highlight nrt stale; do cap $c $c; chk $c ".r-$c.out"; pub $c; done
NN=$(python3 -I -B harness/chk22.py same .r-nrt.out .r-stale.out) || die "stale: the template's and the repository's lines are not nrt's (harness/chk22.py same)"
echo "  $NN"
cap sync sync; chk sync .r-sync.out; pub sync
bg "dk run -d --pull never --name $HN -p 127.0.0.1:20616:5432 --env-file .harness/pg.env $IMG" .harness/docker-run-pg-h.log
[ "$RE" = 0 ] || die "the harness's PostgreSQL did not start: $(tail -2 .harness/docker-run-pg-h.log)"
pgready $HN
echo "  the harness's PostgreSQL: $HN, 127.0.0.1:20616 (dk port: $(dk port $HN | paste -sd'|' -)), $IMG, --pull never, the same 0600 password file · volumes now $(vols)"
cap drift drift; chk drift .r-drift.out; pub drift
dk rm -fv $HN > /dev/null 2>&1 || die "$HN could not be removed"
echo "  $HN removed (rm -fv) · volumes $(vols)"
cap absent absent; chk absent .r-absent.out; pub absent
for c in $MN $RN $CN; do dk rm -fv "$c" > /dev/null 2>&1 || die "the container $c could not be removed"; done
echo "  $MN, $RN and $CN removed (rm -fv) · volumes $(vols)"
cap default default; chk default .r-default.out; pub default
cap seven seven; chk seven .r-seven.out "$S466"; pub seven
cap sockets sockets; chk sockets .r-sockets.out; pub sockets
NUM=$(python3 -I -B harness/chk22.py numbers README.md .r-anchor.out .r-requests.out .r-highlight.out .r-nrt.out .r-stale.out .r-sync.out .r-drift.out) || die "S8.95: $(printf '%s\n' "$NUM" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$NUM" | $G -v '^VALUES ' | sed 's/^/  /' > .harness/chk-numbers.out; cat .harness/chk-numbers.out
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
  ! $G -qE '"took" ?: ?[0-9]|took\[[0-9]|"@timestamp" ?: ?"2|refresh_interval|search\.idle\.after|connection-timeout|socket-timeout|start_time_in_millis|uptime_in_millis|request_interval|request_jitter|poll\.interval|index\.creation_date|"timestamp":"20' "$f" || die "TIMEPAT_S4B: $f holds a took, a timestamp or a time setting"
  ! $G -qE '^ *[0-9]{4}-[0-9]{2}-[0-9]{2}[T ][0-9]|[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9]' "$f" || die "$f holds a log time"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'jdbc:h2:mem:[0-9a-f]{8}' "$f" || die "$f holds H2's generated database name, unmasked"
  ! $G -qE '0\.0\.0\.0:[0-9]+->|\[::\]:[0-9]+->' "$f" || die "S8.94: $f shows a port published on every interface"
  ! $G -E '^ *(the receipt: )?\$ .*(^|[ (])(java|mvn) ' "$f" | $G -vF -- "perl -e '" > /dev/null || die "$f starts a JVM or Maven without its alarm (R.247)"
  ! $G -qF -- "$TOKEN" "$f" || die "$f holds the shutdown token"
  ! $G -qF -- "$PW" "$f" || die "$f holds the PostgreSQL password"; done
DC=$(cat .r-*.out | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
DR=$(awk '/^```text$/ { b = 1; next } b && /^```$/ { b = 0; next } b' README.md | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
[ "$DC" = 0 ] && [ "$DR" = 0 ] || die "R.432: dur8 finds $DC word(s) in the captures and $DR in README.md's text blocks - 0 is the rule"
[ -z "$(find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness (R.195)"
echo "  hygiene: dur8 over the captures and README.md's text blocks 0 words; no path, time, took, @timestamp, time setting, log time, stack frame, H2 database name, raw port, all-interfaces binding, pid, token or password in any capture; every JVM and Maven under its alarm"
# ---- the end: the containers, Testcontainers, the volumes, the images, the trees, the ports -------------------------------------
echo "  _cat/indices on $EN at the end (the scratch indices gone): $(eq 20614 GET '/_cat/indices?h=index&s=index' | paste -sd' ' -)"
dk rm -fv $EN > /dev/null 2>&1 || die "the container $EN could not be removed"
tcrm; [ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container is still there"
for c in $CN $RN $MN $EN $HN $EX; do [ -z "$(dk ps -aq --filter name=^/$c\$ 2> /dev/null)" ] || die "the container $c is still there"; done
[ -z "$(dk ps -aq --filter label=com.docker.compose.project=$PROJ 2> /dev/null)" ] && [ -z "$(dk volume ls -q --filter name=^$PROJ)" ] && [ -z "$(dk network ls -q --filter name=^$PROJ)" ] || die "a container, volume or network of this run is still there"
VOL1=$(vols); IMGS1=$(dk images -q --no-trunc 2> /dev/null | sort -u | paste -sd' ' -)
[ "$VOL1" = "$VOL0" ] || die "R.322: the volume count moved, $VOL0 -> $VOL1"
[ "$IMGS1" = "$IMGS0" ] || die "the images moved over this run - nothing may be pulled"
[ ! -e "$HOME/.testcontainers.properties" ] || die "R.318: ~/.testcontainers.properties appeared over this run"
echo "  docker at the end: $EN removed with its volumes (rm -fv), $HN, $EX, $CN, $RN, $MN and the $PROJ project gone; Testcontainers containers 0; volumes $VOL0 -> $VOL1; images $NI0, the same list (nothing pulled)"
pin before-tree before end; pin after-tree after end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 20578, 20610-20619 or 18881-18884 at the end - the containers bound 20611-20614, 20616 and 20618 and are gone; TiffinBox bound 20610 (after/) and 20617 (before/, the seven), the ITs' containers 20615 and 20578, Compose's 18881-18884; 20619 was never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c8-unit22: every capture = published (JVM captures 3/3 in this run; exercise and the tests once per run); every spoken number asserted by chk22.py; before/ and after/ = their pins; the volume count and the images unchanged"
