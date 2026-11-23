#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 8 · Full-Text Search: The Analyzer Explained - this unit's receipts. Section 4 Part B's first anchor change: before/ is a link
# to ../c8-unit20/after (unit 20's tree), after/ is this unit's tree and ../c8-tiffinbox equals it from this unit's commit on. The change
# adds Elasticsearch under the profile "dev": the starter, a V4 migration of ten dish rows (PostgreSQL's under dev, the source), Dish
# and its analyzer "dish" (dish-settings.json), Dishes, GET /dishes/search, the dev start's re-index (the index a copy of the rows),
# the seven Elasticsearch auto-configurations excluded on the default run, compose.yaml's fourth service, ElasticsearchIT.
# Two witnesses for every Elasticsearch number (S8.78): Java's answer (TiffinBox's routes, the start's log line, the client's own
# request lines by its trace logger, the IT's lines, the exercise's program) and the store's own REST API by curl on the loopback port
# from this Mac (_analyze, _search, _mapping, _settings, _cat/indices, _explain, _cluster/settings, GET /) - never docker exec ... curl.
# The two docker exec calls here read a file each (cat /proc/sys/vm/max_map_count and /proc/net/*, /proc/sys/kernel/osrelease), never a
# shell into the store.
# Whose: the ANCHOR's (after/ under "dev" or the default run: anchor, tokens, explain, default, absent, the seven), a LABELLED COPY's
# (variants.py std - "a copy with the standard analyzer", its own Elasticsearch on 20605: nohit, sayso, fuzzy, late; variants.py
# healthkey - the health key alone, in default) or the image's own (image: the default heap on a labelled container).
# Captures (the JVM ones run three times and hashed; exercise once per run of record - its 3/3 is across the runs; the tests once per
# run of record too, folded into anchor):
#   exercise   exercise/README.md's lines, then SOLUTION.md's, as written, in ONE env -i shell - bash, then zsh -f (a fresh Elasticsearch each)
#   image      the image's record; its default heap on a labelled container; the unit's Elasticsearch with the six settings, each read back
#   anchor     the tests; the libraries; after/ under "dev" on PostgreSQL + Redis + MongoDB + Elasticsearch: the re-index, the index,
#              veg by both witnesses; a second start; ONE Compose window on the shipped compose.yaml (four services)
#   tokens     _analyze standard and dish; term on the text field and on the keyword field; the IT's _analyze (the Java side)
#   nohit      the copy with the standard analyzer under "dev": veg 0 by both witnesses, vegetarian 1, prefix 4; the shipped 1
#   sayso      the ways to say so, each on its own index of the same ten documents: prefix, phrase prefix, wildcard, fuzziness, english,
#              edge_ngram, the synonym; yellow and green
#   fuzzy      fuzziness 2 beside AUTO and the shipped analyzer
#   late       the analyzer refused on a mapped field; a search_analyzer accepted, no re-index
#   explain    the score of the vegetarian box for vegetarian, read off _explain
#   default    after/ with no profile on H2, no Docker; the health key alone (the labelled copy healthkey)
#   absent     after/ under "dev" with Elasticsearch absent: exit 1, the client's exception
#   seven      the comparison set on before/'s and after/'s jars (H2; after/ on 20600, before/ on 20607)
#   sockets    the unit's Elasticsearch container's sockets, read at the end of the receipt (S8.92)
# Every tree is COPIED under .harness/ and built there, offline (-o, from .m2-demo, a copy of the course's seed, maven.repo.local
# absolute), every module from the tree's own sources (-pl tiffinbox-web -am, R.391). Every JVM and Maven run under an alarm (R.247),
# every JVM with SIGINT reset to its default (R.410). Every docker call names its socket (dk, R.344), --pull never; every container is
# removed with its volumes (rm -fv, R.387) and the volume count asserted back. A receipt waits on a count it polls (R.412). Every
# Elasticsearch container runs with the six settings (compose.yaml's), but the one labelled the image's default heap (five, no heap).
# Ports (20600-20609): 20600 TiffinBox after/ (and the copies) · 20601 the unit's PostgreSQL · 20602 the unit's Redis · 20603 the unit's
# MongoDB, a standalone · 20604 the unit's Elasticsearch · 20605 the copy's Elasticsearch · 20606 the IT's Elasticsearch, pinned, during
# mvn verify only · 20607 TiffinBox before/ for the seven · 20608 the exercise's Elasticsearch · 20609 never bound ("Elasticsearch
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
CN=c8u21-pg; RN=c8u21-redis; MN=c8u21-mongo; EN=c8u21-es; ES=c8u21-es-std; ED=c8u21-es-default; EX=c8u21-es-ex; PROJ=tiffinbox-dev
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
pid=""; mpid=""; xpid=""; CMPW=""; CMPV=""; TC0=""; INTR=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "DishLab.java") || index($0, "curlset.sh") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || $3 ~ /(^|\/)javac$/ || index($0, "ex-drive.sh")) { print $1 }' | paste -sd' ' -) || l=""
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
ctrm() { local c; [ -n "$TC0" ] || return 0
  for c in $EX $ED $ES $EN $MN $RN $CN; do [ -z "$(dk ps -aq --filter name=^/$c\$ 2> /dev/null)" ] || dk rm -fv "$c" > /dev/null 2>&1 || true; done; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid" "$pid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; tcrm; cmprm; ctrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git unzip /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|FLYWAY_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|REDIS[A-Z_]*|MONGO[A-Z_]*|ES_[A-Z_]*|ELASTIC[A-Z_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT|COMPOSE_[A-Z_]*)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"

# ---- gates before anything is written: the folder, the links, the pins, the prose, the change, R.250 ---------------------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk21.py dur8.py logback.xml s821.py surefire.py tree21.py variants.py' ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'DishLab.java README.md SOLUTION.md check.sh dish-settings-standard.json dish-settings.json' ] || die "exercise/ holds another file, or misses one"
cmp -s harness/dur8.py ../c8-unit02/harness/dur8.py || die "harness/dur8.py is not the builders' dur8.py as unit 02 shipped it, byte for byte"
cmp -s harness/surefire.py ../c8-unit02/harness/surefire.py || die "harness/surefire.py is not unit 02's, byte for byte"
cmp -s harness/logback.xml ../c8-unit07/harness/logback.xml || die "harness/logback.xml is not unit 07's, byte for byte"
cmp -s exercise/dish-settings.json after/tiffinbox-web/src/main/resources/dish-settings.json || die "exercise/dish-settings.json must be after/'s dish-settings.json, byte for byte"
[ -L before ] && [ "$(readlink before)" = ../c8-unit20/after ] || die "R.211: before must be a link to ../c8-unit20/after (it points at: $(readlink before 2> /dev/null || echo 'not a link'))"
[ -d after ] && [ ! -L after ] || die "after/ must be this unit's own tree, not a link"
for t in after before; do [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] && die "$t holds a secrets/ or a target/ - never built in place"; true; done
git rev-parse -q --verify 'e1b4a67^{commit}' > /dev/null 2>&1 || die "unit 20's commit e1b4a67 is not in this repository's history"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree21.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/ ($3): python3 -I harness/tree21.py $dir/ -> $got = receipts.md5's $nm line"; }
pin before-tree before start; pin after-tree after start
U20P=$(awk '$1 == "after-tree" { print $2, $3 }' ../c8-unit20/receipts.md5)
[ "$U20P" = "$(awk '$1 == "before-tree" { print $2, $3 }' receipts.md5)" ] || die "before/'s pin is not unit 20's after-tree line ($U20P)"
echo "  before/'s pin = ../c8-unit20/receipts.md5's after-tree line ($U20P), re-derived by harness/tree21.py"
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c8-tiffinbox 2>&1 || true)
echo "  after/ against ../c8-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor' || echo 'they differ - a later unit moved the anchor; this unit measures after/')"
rm -f .r-gate.tmp
echo "  after/ against before/ (diff -rq, the files the change added or changed):"; diff -rq before/ after/ 2>&1 | sed -E 's#^Files before/(.*) and after/.* differ$#    changed: \1#; s#^Only in after/(.*): (.*)$#    new: \1/\2#; s#^Only in before/(.*): (.*)$#    gone: \1/\2#' | sort | tee -a .r-gate.tmp
[ -z "$(diff -rq before/ after/ 2>&1 | $G '^Only in before' || true)" ] || die "the change deletes no file - a file is only in before/"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s821.py harness/dur8.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -2 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
YD=$(diff -r before/ after/ 2>&1 | $G '^>' | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
[ "$YD" = 0 ] || die "R.432: dur8 finds $YD duration word(s) in the lines the change added (Javadoc, YAML, compose and README lines)"
NEWF=$(diff -rq before/ after/ 2>&1 | sed -n -E 's#^Only in after/(.*): (.*)$#after/\1/\2#p')
YN=$(for f in $NEWF; do if [ -d "$f" ]; then find "$f" -type f -exec cat {} +; else cat "$f"; fi; done | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
[ "$YN" = 0 ] || die "R.432: dur8 finds $YN duration word(s) in the files the change added"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
DN=$($G -rniwE -- "$DISH" README.md exercise after/tiffinbox-core/src/main/resources/db/migration/V4__dish.sql after/tiffinbox-web/src/main/java/com/tiffinbox/web/Dish.java after/compose.yaml 2> /dev/null | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|VALUES-PENDING|WIB-README|WIB-SOLUTION|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md exercise 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
! $G -q '^```java$' README.md || die "README.md holds a java block - the code is the anchor's files and the exercise's"
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
EXQ="Your turn: veg finds zero dishes, and a prefix finds four, one of them the vegan box. Make veg find only the vegetarian one."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SETUP=$(block exercise/README.md); SOL=$(block exercise/SOLUTION.md)
[ -n "$SETUP" ] && [ -n "$SOL" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
[ "$(diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G -c '^[<>]')" = 2 ] || die "R.196: SOLUTION.md's block must be the README's with one line changed"
[ "$(printf '%s\n' "$SETUP" | $G -c 'DishLab.java exercise/dish-settings-standard.json')" = 1 ] && [ "$(printf '%s\n' "$SOL" | $G -c 'DishLab.java exercise/dish-settings.json')" = 1 ] || die "R.196: the README's block runs DishLab on the standard settings, SOLUTION.md's on the shipped settings (exercise/dish-settings.json)"
printf '%s\n' "$SETUP" | $G -E '(^|[ (])(mvn|java|javac) ' | $G -vqF "perl -e '" && die "exercise/README.md's Java and Maven runs must run under their alarm (R.247)"
printf '%s\n' "$SETUP" | $G -E 'mvn ' | $G -vqF -- '-pl tiffinbox-web -am' && die "R.391: exercise/README.md builds without -pl tiffinbox-web -am"
printf '%s\n' "$SETUP" | $G -E '(^|[ ;&(])docker ' | $G -vqF 'docker -H "$DH" ' && die "R.344: exercise/README.md calls docker without its socket (docker -H \"\$DH\")"
printf '%s\n' "$SETUP" | $G -qF 'docker -H "$DH" rm -fv c8u21-es-ex' || die "R.387: the exercise's container is removed with its volumes (rm -fv)"
for s in discovery.type=single-node xpack.security.enabled=false xpack.ml.enabled=false ingest.geoip.downloader.enabled=false xpack.inference.elastic.authorization.enabled=false '"ES_JAVA_OPTS=-Xms512m -Xmx512m"'; do printf '%s\n' "$SETUP" | $G -qF -- "-e $s" || die "⚑4: the exercise's Elasticsearch runs without $s"; done
printf '%s\n' "$SETUP" | $G -qF "docker -H \"\$DH\" run -d --name c8u21-es-ex -p 127.0.0.1:20608:9200 " || die "S8.76: the exercise starts its own fresh Elasticsearch container, on 127.0.0.1:20608"
printf '%s\n' "$SETUP" | $G -qF "$ETAG > /dev/null" || die "R.387's split: the viewer's line names the image by its tag, $ETAG"
printf '%s\n' "$SETUP" | $G -qxF 'bash exercise/check.sh' || die "R.196: the exercise is checked by exercise/check.sh (the store's own REST API), never by the exit"
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
[ "$XE" = 'cat /proc/net/$t|cat /proc/net/dev|cat /proc/sys/kernel/osrelease|cat /proc/sys/vm/max_map_count|pg_isready|psql|redis-cli' ] || die "every exec into a container here reads a /proc file by cat, or is PostgreSQL's or Redis's own client - never a shell (found: $XE)"
ESR=$($G -v '^ *#' receipts.sh | $G -E '(dk|docker) run ' | $G -F '$EIMG' | $G -vF '$ESSET' | $G -vcF '$ESDEF' || true)
[ "$ESR" = 0 ] || die "⚑4: an Elasticsearch container run without the six settings (\$ESSET) - or the labelled default (\$ESDEF)"
[ -z "$($G -v '^ *#' receipts.sh | $G -E '(dk|docker) run ' | $G -oE -- ' -p [^ ]+' | $G -v '^ -p 127\.0\.0\.1:' || true)" ] && [ -z "$($G -rlE '0\.0\.0\.0:[0-9]|\[::\]:[0-9]|bindIpAndPort\("0' after/compose.yaml after/tiffinbox-web/src || true)" ] || die "S8.94: a port published on every interface (-p without 127.0.0.1, or 0.0.0.0 in after/)"
[ -z "$($G -rlE 'withReplicaSet|--replSet|replSetInitiate' after/ exercise || true)" ] || die "S8.62: a replica set in after/ or the exercise"
MVA=$($G -v '^ *#' receipts.sh | $G -F 'clean ' | $G -F '$MV' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am"
ST=$(python3 -I -B harness/chk21.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
R250=$(python3 -I -B harness/chk21.py r250 after before) || die "R.250: $(printf '%s\n' "$R250" | $G '^FAIL' | head -2 | paste -sd';' -)"
printf '%s\n' "$R250" | $G -v '^VALUES ' | sed 's/^/  /'
printf '%s\n' "$ST" "$R250" | $G -v '^VALUES ' >> .r-gate.tmp
echo "  prose, per sentence (s821, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test): refused 0 over $PROSE · the lines the change added: dur8 0 · dish names 0 · placeholders 0 · no java block"
echo "  the exercise: the spoken line $EXW words (wc -w); SOLUTION.md's block = the README's with one line changed - DishLab on the shipped settings instead of the standard ones; the two \"What it prints\" blocks differ (R.196); checked by exercise/check.sh, never the exit; a fresh container on 127.0.0.1:20608 by the tag, with the six settings, removed with its volumes; its build -pl tiffinbox-web -am; its docker calls on the socket"
echo "  static: no kill by name; every docker call on the pinned socket, every dk run --pull never, every MongoDB container with GLIBC_TUNABLES, every Elasticsearch container with the six settings but the labelled default heap; no exec into a container to run curl (curl on the loopback port, §BUILDERS 9); no port on every interface (S8.94); every container removal dk rm -fv (R.387); no replica set; every Maven build -pl tiffinbox-web -am (R.391)"
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
ESDEF="-e discovery.type=single-node -e xpack.security.enabled=false -e xpack.ml.enabled=false -e ingest.geoip.downloader.enabled=false -e xpack.inference.elastic.authorization.enabled=false"

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
# the four tags the shipped compose.yaml names (and the exercise's), present on the digests above - else a Compose up (or the exercise) would pull
[ "$(iid mongo:8) $(iid postgres:18-alpine) $(iid redis:8-alpine) $(iid $ETAG)" = '05b334b0a7a7 77f585114c32 7958cfbb9d15 fb7f2d0df199' ] || die "the tags compose.yaml names (mongo:8, postgres:18-alpine, redis:8-alpine, $ETAG) are not on this machine at the course's digests - a Compose up would pull; this script never pulls"
RY0=$(dk images --format '{{.Repository}}' 2> /dev/null | $G -c ryuk || true)
[ "$RY0" = 0 ] || die "R.318: an image named ryuk is on this machine ($RY0) - Ryuk stays off and none is pulled"
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run - remove it with its volumes: docker -H \"\$DH\" rm -fv <id>"
for c in $CN $RN $MN $EN $ES $ED $EX; do [ -z "$(dk ps -aq --filter name=^/$c\$ 2> /dev/null)" ] || die "a container named $c exists before the run - an interrupted run's? docker -H \"\$DH\" rm -fv $c"; done
[ -z "$(dk ps -aq --filter label=com.docker.compose.project=$PROJ 2> /dev/null)" ] && [ -z "$(dk network ls -q --filter name=^${PROJ} 2> /dev/null)" ] && [ -z "$(dk volume ls -q --filter name=^${PROJ} 2> /dev/null)" ] || die "a $PROJ container, network or volume exists before the run - anchor's Compose window needs none (docker -H \"\$DH\" compose -p $PROJ down, and its volumes by name)"
TC0=1
[ ! -e "$HOME/.testcontainers.properties" ] || die "R.318: ~/.testcontainers.properties exists - this unit's Testcontainers JVMs read a receipt home under .harness/ only"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 18881 18882 18883 18884 20578 20600 20601 20602 20603 20604 20605 20606 20607 20608 20609"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
[ "$(pgrep -x java | wc -l | tr -d ' ')" = 0 ] || die "a java process is running before this script starts one - not this script's; stop it first"
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · the four digests present ($IMG, $RIMG, $MIMG, $EIMG) · mongo:8, postgres:18-alpine, redis:8-alpine and $ETAG on those digests · nothing pulled, ever · images named ryuk $RY0 · Testcontainers containers 0 · no $PROJ container, network or volume · ports 20578, 20600-20609, 18881-18884 (and 18425, 8080) free · java processes 0"

# ---- the trees, copied; the builds ----------------------------------------------------------------------------------------------
rm -rf .harness; mkdir -p .harness/run-h2/secrets/tiffinbox .harness/run-pg/secrets/tiffinbox .harness/run-std/secrets/tiffinbox .harness/run-hk/secrets/tiffinbox .harness/home .harness/compose-run
M2="$PWD/.m2-demo"
[ -d "$M2" ] || die ".m2-demo (a copy of the course's seed, _research/m2-seed-c8-s4b) is missing - README.md, The repository"
for a in co/elastic/clients/elasticsearch-java/9.4.8 co/elastic/clients/elasticsearch-rest5-client/9.4.8 org/springframework/data/spring-data-elasticsearch/6.1.2 org/springframework/boot/spring-boot-starter-data-elasticsearch/4.1.2 org/springframework/boot/spring-boot-data-elasticsearch/4.1.2 org/springframework/boot/spring-boot-elasticsearch/4.1.2 org/springframework/boot/spring-boot-starter-data-elasticsearch-test/4.1.2 org/springframework/boot/spring-boot-data-elasticsearch-test/4.1.2 org/testcontainers/testcontainers-elasticsearch/2.0.5 com/fasterxml/jackson/core/jackson-databind/2.21.7 com/fasterxml/jackson/core/jackson-core/2.21.7; do
  [ -d "$M2/$a" ] || die "$a is not in .m2-demo - the seed lacks it (README.md, The repository)"; done
NF0=$(find "$M2" -type f | wc -l | tr -d ' ')
BE="$M2/org/springframework/boot"
IMP=$(for j in spring-boot-elasticsearch spring-boot-data-elasticsearch; do unzip -p "$BE/$j/4.1.2/$j-4.1.2.jar" META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports | $G -v '^#' | $G .; done)
echo "  .m2-demo's files $NF0 · the artifacts the change needs, by path: elasticsearch-java and elasticsearch-rest5-client 9.4.8, spring-data-elasticsearch 6.1.2, Boot's spring-boot-starter-data-elasticsearch, spring-boot-data-elasticsearch, spring-boot-elasticsearch, spring-boot-starter-data-elasticsearch-test, spring-boot-data-elasticsearch-test 4.1.2, testcontainers-elasticsearch 2.0.5, jackson-databind and jackson-core 2.21.7 - present"
echo "  the two jars' AutoConfiguration.imports (unzip -p off .m2-demo), $(printf '%s\n' "$IMP" | $G -c .) names: $(printf '%s\n' "$IMP" | sed 's/^org\.springframework\.boot\.//' | paste -sd' ' - | sed 's/ / · /g')" | tee -a .r-gate.tmp
printf '%s\n' "$IMP" > .harness/imports.txt
printf '%s\n' 'checks.disable=true' "tinyimage.container.image=$IMG" > .harness/home/.testcontainers.properties
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy before .harness/before; copy after .harness/after; copy after .harness/tests
echo "  the labelled copies of after/ (harness/variants.py), printed as their diffs:"
for v in std healthkey; do python3 -I -B harness/variants.py $v after .harness/$v > .harness/variant-$v.txt || die "variants.py $v failed: $(cat .harness/variant-$v.txt)"
  echo "    $v: $($G -c '^[-+] ' .harness/variant-$v.txt) lines changed:"; $G -E '^[-+] ' .harness/variant-$v.txt | cut -c1-140 | sed 's/^/      /'; done
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE '^\[INFO\] Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
AL="-DargLine=$JL -Dstdout.encoding=UTF-8 -Duser.home=../../home"
for t in before after std healthkey; do
  XG=""; [ $t = after ] && XG=" dependency:build-classpath -Dmdep.outputFile=target/classpath.txt -Dmdep.includeScope=runtime"
  bg "cd .harness/$t && $MV clean package -DskipTests -pl tiffinbox-web -am$XG" .harness/build-$t.log
  [ "$RE" = 0 ] || { tail -20 .harness/build-$t.log >&3; die ".harness/$t did not build offline (exit $RE)"; }; offl .harness/build-$t.log
  bg "cd .harness/$t && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$t.log
  [ "$RE" = 0 ] || die ".harness/$t: the jar's extract failed"; done
$G -q 'spring-boot-docker-compose-4.1.2.jar' .harness/after/tiffinbox-web/target/classpath.txt || die "Maven's class path for after/ lacks spring-boot-docker-compose (the Compose window needs it)"
TF=secrets/tiffinbox/shutdown-token
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/run-h2/$TF) || die "the token was not written"
rsync -a after/ .harness/compose-run/ && mkdir -p .harness/compose-run/secrets/tiffinbox
for d in run-pg run-std run-hk after before compose-run; do mkdir -p .harness/$d/secrets/tiffinbox; (umask 077 && cp .harness/run-h2/$TF .harness/$d/$TF) || die "the token was not copied"; done
cmp -s .harness/compose-run/compose.yaml after/compose.yaml || die "the Compose window's compose.yaml is not after/'s"
mv .r-gate.tmp .harness/gate.out 2> /dev/null || true
TOKEN=$(head -1 .harness/run-h2/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
PW=$(openssl rand -hex 16); (umask 077 && printf 'POSTGRES_USER=tiffinbox\nPOSTGRES_PASSWORD=%s\n' "$PW" > .harness/pg.env) || die "the password file was not written"
python3 -I -B - after/tiffinbox-core/src/main/resources/db/migration/V4__dish.sql > .harness/dishes.ndjson << 'PYEOF' || die "V4__dish.sql's rows could not be read"
import json, re, sys
rows = re.findall(r"VALUES \('([^']+)', '(\w+)', (\d+)\)", open(sys.argv[1], encoding="utf-8").read())
for i, (n, t, p) in enumerate(rows, 1):
    print(json.dumps({"index": {"_id": str(i)}})); print(json.dumps({"name": n, "mealType": t, "price": int(p)}))
PYEOF
echo "  built before/'s, after/'s and the two labelled copies' trees offline (mvn -o package -DskipTests -pl tiffinbox-web -am, exit 0, 'Downloaded from' 0; after/'s with Maven's runtime class path written beside it, for the Compose window), extracted their jars; a shutdown token and a PostgreSQL password generated (0600, never printed); V4__dish.sql's $(( $(wc -l < .harness/dishes.ndjson) / 2 )) rows read into a bulk body (ids 1 to $(( $(wc -l < .harness/dishes.ndjson) / 2 )) in the file's order), for the copies' scratch indices"

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
PYT='import json,sys
d=json.load(sys.stdin); t=[x["token"] for x in d["tokens"]]; print(str(len(t)) + " [" + ", ".join(t) + "]")'
hits() { eq "$1" POST "/$2/_search" "$3" | python3 -I -c "$PYH"; }
toks() { eq "$1" POST "$2/_analyze" "$3" | python3 -I -c "$PYT"; }
ack() { python3 -I -c 'import json,sys; d=json.load(sys.stdin); print("error " + d["error"]["type"] + ": " + " ".join(d["error"]["reason"].split()) if "error" in d else "acknowledged " + str(d.get("acknowledged")).lower())'; }
BKPY='import json,sys; d=json.load(sys.stdin); print("errors " + str(d["errors"]).lower() + " · items " + str(len(d["items"])))'
bulk() { curl -s --noproxy '*' -H 'Content-Type: application/x-ndjson' -X POST "http://127.0.0.1:$1/$2/_bulk?refresh=true" --data-binary @.harness/dishes.ndjson 2> /dev/null | python3 -I -c "$BKPY"; }
mtypes() { python3 -I -c 'import json,sys
v={}
for l in open(sys.argv[2]):
    d=json.loads(l)
    if "index" in d: k=d["index"]["_id"]
    else: v[k]=d["mealType"] + " " + d["name"]
ids=[x.strip() for x in sys.argv[1].split("[")[1].rstrip("]").split(",") if x.strip()]
print(" · ".join(i + " " + v[i] for i in ids) if ids else "none")' "$1" .harness/dishes.ndjson; }
catix() { eq "$1" GET "/_cat/indices/$2?h=index,health,status,pri,rep,docs.count&s=index" | sed -E 's/ +/ /g; s/ $//' | paste -sd'|' - | sed 's/|/ · /g'; }
startstores() {
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:20601:5432 --env-file .harness/pg.env $IMG" .harness/docker-run-pg.log
  [ "$RE" = 0 ] || die "the PostgreSQL container did not start: $(tail -2 .harness/docker-run-pg.log)"
  bg "dk run -d --pull never --name $RN -p 127.0.0.1:20602:6379 $RIMG" .harness/docker-run-redis.log
  [ "$RE" = 0 ] || die "the Redis container did not start: $(tail -2 .harness/docker-run-redis.log)"
  mkmongo; pgready $CN
  local i=0; while [ "$(dk exec $RN redis-cli PING 2> /dev/null | tr -d '\r')" != PONG ]; do i=$((i + 1)); [ $i -lt 200 ] || die "Redis did not answer PING"; sleep 0.1; done
  [ "$(dk port $CN | paste -sd'|' -)" = '5432/tcp -> 127.0.0.1:20601' ] && [ "$(dk port $RN | paste -sd'|' -)" = '6379/tcp -> 127.0.0.1:20602' ] || die "a store publishes on another address than 127.0.0.1:<its port>"
  echo "  the stores beside $EN: $CN (PostgreSQL, 127.0.0.1:20601) from $IMG; $RN (Redis, 127.0.0.1:20602, no password) from $RIMG; $MN (MongoDB, a standalone, 127.0.0.1:20603, no auth, -e GLIBC_TUNABLES=$GT, --unixSocketPrefix /data/db) from $MIMG; all --pull never, 127.0.0.1 only; the password from a 0600 file, never printed · volumes now $(vols) (the machine's $VOL0 + PostgreSQL's one + MongoDB's two; Elasticsearch's none)"; }
mkmongo() {
  bg "dk run -d --pull never --name $MN -p 127.0.0.1:20603:27017 -e GLIBC_TUNABLES=$GT $MIMG --unixSocketPrefix /data/db" .harness/docker-run-mongo.log
  [ "$RE" = 0 ] || die "the MongoDB container did not start: $(tail -2 .harness/docker-run-mongo.log)"
  local i=0; while [ "$(dk logs $MN 2>&1 | $G -c 'Waiting for connections' || true)" = 0 ]; do i=$((i + 1)); [ $i -lt 240 ] || die "MongoDB's log never said Waiting for connections (240 reads)"; sleep 0.25; done
  [ "$(dk port $MN | paste -sd'|' -)" = '27017/tcp -> 127.0.0.1:20603' ] || die "$MN publishes on another address than 127.0.0.1:20603"; }
# a FRESH MongoDB for every dev start, as unit 20 found its start's witness drifts on a reused one (this unit reads no MongoDB profile; the shape is kept)
freshmongo() { dk rm -fv $MN > /dev/null 2>&1 || die "$MN could not be removed"; mkmongo; }
psq() { dk exec "$1" psql -U tiffinbox -d "$2" -qAt -v ON_ERROR_STOP=1 -c "$3" 2>&1 || die "psql failed on $1/$2: $3"; }
pgdb() { psq $CN postgres "drop database if exists $1 with (force)" > /dev/null; psq $CN postgres "create database $1" > /dev/null
  local d; for d in run-pg run-std; do (umask 077 && printf 'jdbc:postgresql://127.0.0.1:20601/%s?user=tiffinbox&password=%s\n' "$1" "$PW" > .harness/$d/secrets/tiffinbox/jdbc-url) || die "the URL was not written"; done
  echo "  a fresh database on $CN: $1 (psql) · its URL in the config tree (0600, never printed)"; }
flush() { [ "$(dk exec $RN redis-cli FLUSHALL | tr -d '\r')" = OK ] || die "redis-cli FLUSHALL failed"; echo "  redis-cli FLUSHALL (the unit's Redis) -> OK"; }
TRL=--logging.level.co.elastic.clients.transport.rest5_client.low_level.Request=TRACE
DEVB="--spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20602 --spring.mongodb.uri=mongodb://127.0.0.1:20603/tiffinbox $TRL"
DEV="$DEVB --spring.elasticsearch.uris=http://127.0.0.1:20604"
cu() { curl -s --noproxy '*' -o .harness/body -w '%{http_code}' "http://127.0.0.1:$1$2" 2> /dev/null || true; }
# tb TREE RUN PORT ARG...: TiffinBox's jar of TREE (java -jar, under its alarm, SIGINT at its default), from .harness/RUN (its config
# tree), in the background (pid); the receipt polls readiness on PORT until 200, or until the JVM is gone (TBUP = 1 or 0)
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
# the start's own lines: strict mode, Flyway, the client's requests (method and path, counted), the re-index line
STRICT='Multiple Spring Data modules found|Could not safely identify store assignment|Finished Spring Data repository scanning|Bootstrapping Spring Data'
startlines() { local f=$1
  echo "  the start's repository lines, whole, as printed (each counted; the logger's prefix cut, the candidate's advice after its first clause cut):"
  $G -E "$STRICT" "$f" | sed -E 's/^.*\] [^ ]+ +: //; s/(candidate interface [A-Za-z.]+);.*$/\1/' | mask | sort | uniq -c | sed -E 's/^ +([0-9]+) /    (x\1) /'
  echo "  of them \"Could not safely identify\": $($G -c 'Could not safely identify store assignment' "$f" || true) · naming Dishes: $($G 'Could not safely identify store assignment' "$f" | $G -c 'interface com.tiffinbox.web.Dishes;' || true) - by module: $($G 'Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.Dishes;' "$f" | sed -E 's/^.*: (Spring Data [A-Za-z ]+) - Could.*$/\1/' | sort | paste -sd',' - | sed 's/,/, /g')"
  echo "  the start's other lines:"
  $G -oE 'HHH000001: Hibernate ORM core version [^ ]+|Successfully applied [0-9]+ migrations?|tiffinbox +: (dishes re-indexed: .*|kitchen value: +[0-9]+)' "$f" | sed -E 's/^tiffinbox +: /tiffinbox: /' | sort | uniq -c | sed -E 's/^ +([0-9]+) /    (x\1) /'
  echo "  the client's requests, by its trace logger (co.elastic.clients.transport.rest5_client.low_level.Request at TRACE), method and path, in order, each run of the same counted:"
  $G -oE "Request +: curl -iX [A-Z]+ 'http://127\.0\.0\.1:[0-9]+/[^'?]*" "$f" | sed -E "s/^Request +: curl -iX //; s#'http://127\.0\.0\.1:[0-9]+#<es>#" | uniq -c | sed -E 's/^ +([0-9]+) /    (x\1) /'
  echo "  the hosts those requests went to: $($G -oE "Request +: curl -iX [A-Z]+ 'http://127\.0\.0\.1:[0-9]+" "$f" | sed -E 's/^.*(127\.0\.0\.1:[0-9]+)$/\1/' | sort -u | paste -sd' ' -)"
  echo "  the index creation, as the client sent it (PUT /dishes, the body whole): $($G -oE "curl -iX PUT 'http://127\.0\.0\.1:[0-9]+/dishes' -d '.*'$" "$f" | sed -E "s/^.* -d '//; s/'$//" | head -1)"
  echo "  the bulk request's action lines (index, one per document): $(awk '/Request +: curl -iX POST .*\/_bulk/ { b = 1 } b { n += gsub(/\{"index":\{/, "&") } b && /^# / { b = 0 } END { print n + 0 }' "$f") · refresh=false on the bulk: $($G -c "_bulk?refresh=false'" "$f" || true) · then POST /dishes/_refresh: $(awk '/_bulk\?refresh=false/ { b = 1 } b && /Request +: curl -iX POST .*\/dishes\/_refresh/ { n++; b = 0 } END { print n + 0 }' "$f")"; }
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
  o=$(python3 -I -B harness/chk21.py "$nm" "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk21 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -5 >&3; die "$nm: its check failed (harness/chk21.py)"; }
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
# the ITs' containers, while mvn verify runs: Docker's own list of each, polled on a count (R.412) - the pinned bindings 20606 and 20578
tcpoll() { local i=0 l m; : > .harness/tc-es.txt; : > .harness/tc-mongo.txt
  while kill -0 "$1" 2> /dev/null && [ $i -lt 4800 ]; do
    if [ ! -s .harness/tc-es.txt ]; then l=$(dk ps --filter label=org.testcontainers=true --filter ancestor=$EIMG --format '{{.Ports}}' 2> /dev/null | sed -n 1p); case "$l" in *9200*) printf '%s\n' "$l" > .harness/tc-es.txt ;; esac; fi
    if [ ! -s .harness/tc-mongo.txt ]; then m=$(dk ps --filter label=org.testcontainers=true --filter ancestor=$MIMG --format '{{.Ports}}' 2> /dev/null | sed -n 1p); case "$m" in *27017*) printf '%s\n' "$m" > .harness/tc-mongo.txt ;; esac; fi
    [ -s .harness/tc-es.txt ] && [ -s .harness/tc-mongo.txt ] && break; sleep 0.1; i=$((i + 1)); done; }

# ---- the captures --------------------------------------------------------------------------------------------------------------
tests() { local e=0 n v0
  echo "-- the tests: after/ copied to .harness/tests; mvn package with Maven's DOCKER_HOST pointed at nothing (tcp://127.0.0.1:1), offline:"
  rm -rf .harness/tests/tiffinbox-web/target .harness/tests/tiffinbox-core/target
  MPRE="env DOCKER_HOST=tcp://127.0.0.1:1"; mvnrun .harness/tests package "\"$AL\" clean package -pl tiffinbox-web -am"; MPRE=""
  echo "  Surefire's reports, $SR:"; pgr .harness/tests/$SR; echo "  $SRI: $( [ -d .harness/tests/$SRI ] && echo present || echo 'absent - no container test ran')"
  results .harness/package.log
  echo "  the package log: lines naming 9200 $($G -c 9200 .harness/package.log || true) · lines naming 27017 $($G -c 27017 .harness/package.log || true)"
  echo "-- then mvn verify, the anchor's recipe (DOCKER_HOST on the pinned socket, Ryuk off - TESTCONTAINERS_RYUK_DISABLED=true, a receipt home), offline:"
  [ "$(listeners 20578)" = 0 ] && [ "$(listeners 20606)" = 0 ] || die "20578 or 20606 (the ITs' pinned bindings) is bound before mvn verify"
  echo "  before it: listening on 20578 (the Mongo IT's pinned binding): 0 · on 20606 (the Elasticsearch IT's): 0"
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
  echo "  the Elasticsearch IT's container while verify ran, Docker's own list (dk ps, polled on a count): Ports $(sed 's/[[:space:]]*$//' .harness/tc-es.txt) · listening on 20606 after it: $(listeners 20606)"
  echo "  the Mongo IT's container while verify ran: Ports $(sed 's/[[:space:]]*$//' .harness/tc-mongo.txt) · listening on 20578 after it: $(listeners 20578)"
  echo "  Surefire's reports, $SR:"; pgr .harness/tests/$SR
  echo "  Surefire's reports, $SRI:"; pgr .harness/tests/$SRI
  results .harness/verify.log
  $G -E '^ES IT ' .harness/verify.log | sed 's/^/  /'
  echo "  the verify log's Elasticsearch repository line (the slice's scan): $($G -oE 'Found [0-9]+ Elasticsearch repository interfaces?' .harness/verify.log | sort | uniq -c | sed -E 's/^ +([0-9]+) /(x\1) /' | paste -sd' ' -)"
  echo "  the verify log: 'Creating container for image' $($G -c 'Creating container for image: ' .harness/verify.log || true) · 'Pulling' $($G -c 'Pulling' .harness/verify.log || true) · lines naming docker compose $($G -ci 'docker compose' .harness/verify.log || true) · Testcontainers containers after it: $(dk ps -aq --filter label=org.testcontainers=true | $G -c . || true)"
  local J=.m2-demo/org/testcontainers/testcontainers-elasticsearch/2.0.5/testcontainers-elasticsearch-2.0.5.jar
  echo "  Testcontainers' own ElasticsearchContainer, read off its jar (unzip -p; its constants by the class file's strings): the memory file elasticsearch-default-memory-vm.options -> $(unzip -p $J elasticsearch-default-memory-vm.options | $G . | paste -sd' ' -) · the class file's strings, each present or not: $(unzip -p $J org/testcontainers/elasticsearch/ElasticsearchContainer.class | python3 -I -c 'import sys; b=sys.stdin.buffer.read(); print(" · ".join(w + " " + ("yes" if w.encode() in b else "no") for w in ("ELASTIC_PASSWORD", "changeme", "discovery.type", "single-node", "cluster.routing.allocation.disk.threshold_enabled", "xpack.security.enabled")))')"; }
image() { local v0 v1
  dk rm -fv $EN > /dev/null 2>&1 || true
  echo "-- the image, by its digest (dk image inspect, no container):"
  echo "  $(dk image inspect --format 'Id {{.Id}} · RepoDigests {{json .RepoDigests}} · Architecture {{.Architecture}} · Entrypoint {{json .Config.Entrypoint}} · Cmd {{json .Config.Cmd}}' $EIMG)"
  echo "  its declared volumes (Config.Volumes): $(dk image inspect --format '{{json .Config}}' $EIMG | python3 -I -c 'import json,sys; v=json.load(sys.stdin).get("Volumes") or {}; print(len(v), sorted(v))')"
  echo "  its environment (Config.Env): $(dk image inspect --format '{{json .Config.Env}}' $EIMG)"
  v0=$(vols)
  echo "-- the image's default on this VM: a labelled container $ED, five of the six settings - no ES_JAVA_OPTS, so the heap is the image's own choice:"
  bg "dk run -d --pull never --name $ED --hostname $ED -p 127.0.0.1:20604:9200 $ESDEF $EIMG" .harness/docker-run-$ED.log
  [ "$RE" = 0 ] || die "the labelled default container did not start: $(tail -2 .harness/docker-run-$ED.log)"
  esup 20604
  echo "  GET /_nodes/jvm (curl, 127.0.0.1) -> $(eq 20604 GET /_nodes/jvm | python3 -I -c 'import json,sys; n=list(json.load(sys.stdin)["nodes"].values())[0]["jvm"]; print("version " + n["version"] + " · mem.heap_max_in_bytes " + str(n["mem"]["heap_max_in_bytes"]) + " · mem.heap_init_in_bytes " + str(n["mem"]["heap_init_in_bytes"]))')"
  dk stats --no-stream --format '{{.MemUsage}}' $ED > .harness/stats-default-$CAPRUN.txt 2>&1 || true
  echo "  dk stats --no-stream, once: read into the receipt's log, never this capture (a resident size moves between runs)"
  echo "  volumes with it alive: $(vols) (before it: $v0)"
  dk rm -fv $ED > /dev/null 2>&1 || die "$ED could not be removed"
  echo "  $ED removed (rm -fv) · volumes $(vols)"
  echo "-- the unit's Elasticsearch: $EN, by the digest, --pull never, the six settings, published on 127.0.0.1:20604 only (9300 not published), a fixed --hostname:"
  echo "\$ docker -H \"\$DH\" run -d --pull never --name $EN --hostname $EN -p 127.0.0.1:20604:9200 $(printf '%s' "$ESSET" | sed 's/\\ / /') $EIMG"
  mkes $EN 20604
  v1=$(vols)
  echo "  Docker's port list for $EN (dk port) -> $(dk port $EN | paste -sd'|' -) · its Mounts: $(m=$(mounts $EN); echo "${m:-none}") · volumes $v1 (before it: $v0)"
  echo "  its environment as run, the six (dk inspect): $(dk inspect -f '{{json .Config.Env}}' $EN | python3 -I -c 'import json,sys; print(" · ".join(sorted(e for e in json.load(sys.stdin) if e.split("=")[0] in ("discovery.type","xpack.security.enabled","xpack.ml.enabled","ingest.geoip.downloader.enabled","xpack.inference.elastic.authorization.enabled","ES_JAVA_OPTS"))))')"
  echo "  GET / (curl, 127.0.0.1, no credentials) -> $(eq 20604 GET / | python3 -I -c 'import json,sys; d=json.load(sys.stdin); v=d["version"]; print("name " + d["name"] + " · version.number " + v["number"] + " · build_flavor " + v["build_flavor"] + " · lucene_version " + v["lucene_version"] + " · tagline " + d["tagline"])')"
  echo "  curl -i GET /: status $(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' http://127.0.0.1:20604/) · its header names: $(curl -s --noproxy '*' -D - -o /dev/null http://127.0.0.1:20604/ | tr -d '\r' | sed -n 's/^\([A-Za-z-]*\):.*/\1/p' | sort | paste -sd' ' -) · a Warning header: $(curl -s --noproxy '*' -D - -o /dev/null http://127.0.0.1:20604/ | tr -d '\r' | $G -ci '^warning:' || true)"
  echo "  GET /_nodes/jvm -> $(eq 20604 GET /_nodes/jvm | python3 -I -c 'import json,sys; n=list(json.load(sys.stdin)["nodes"].values())[0]["jvm"]; print("version " + n["version"] + " · vm_vendor " + n["vm_vendor"] + " · mem.heap_max_in_bytes " + str(n["mem"]["heap_max_in_bytes"]) + " · mem.heap_init_in_bytes " + str(n["mem"]["heap_init_in_bytes"]))')"
  echo "  GET /_cluster/settings?include_defaults&flat_settings (the six's keys, read back): $(eq 20604 GET '/_cluster/settings?include_defaults=true&flat_settings=true' | python3 -I -c 'import json,sys; d=json.load(sys.stdin); a={}; [a.update(d[k]) for k in ("defaults","persistent","transient")]; print(" · ".join(k + " " + str(a.get(k)) for k in ("discovery.type","xpack.security.enabled","xpack.ml.enabled","ingest.geoip.downloader.enabled","xpack.inference.elastic.authorization.enabled","cluster.routing.allocation.disk.threshold_enabled")))')"
  echo "  GET /_cluster/health -> $(eq 20604 GET /_cluster/health | python3 -I -c 'import json,sys; d=json.load(sys.stdin); print("status " + d["status"] + " · number_of_nodes " + str(d["number_of_nodes"]))')"
  echo "  the files read inside it (dk exec, cat - a file, never a shell into the store): /proc/sys/vm/max_map_count $(dk exec $EN cat /proc/sys/vm/max_map_count | tr -d '\r') · /proc/sys/kernel/osrelease (uname -r's) $(dk exec $EN cat /proc/sys/kernel/osrelease | tr -d '\r') · /proc/net/dev's interfaces $(dk exec $EN cat /proc/net/dev | sed 1,2d | cut -d: -f1 | tr -d ' ' | sort | paste -sd',' -)"
  dk logs $EN > .harness/es-log.txt 2>&1 || true
  echo "  its log (dk logs), lines: 'Security is disabled' $($G -c 'Security is disabled' .harness/es-log.txt || true) · 'Starting authorization task executor' $($G -c 'Starting authorization task executor' .harness/es-log.txt || true) · the ML controller ('controller (64 bit)') $($G -c 'controller (64 bit)' .harness/es-log.txt || true) · 'bound or publishing to a non-loopback address' $($G -c 'bound or publishing to a non-loopback address' .harness/es-log.txt || true) · 'heap size [' $($G -oE 'heap size \[[^]]*\]' .harness/es-log.txt | sort -u | paste -sd' ' -)"; }
compose() { local vb
  vb=$(vols)
  echo "-- the Compose window: after/ under dev, Boot's Docker Compose support on, the shipped compose.yaml (cmp: after/'s), from .harness/compose-run; no spring.* address key - Boot hands them over:"
  for p in 18881 18882 18883 18884; do [ "$(listeners $p)" = 0 ] || die "$p is bound before the Compose window"; done
  [ -z "$(dk volume ls -q --filter name=^$PROJ)" ] && [ -z "$(dk network ls -q --filter name=^$PROJ)" ] || die "a $PROJ volume or network exists before the window"
  echo "  before it: listening on 18881-18884 0 · $PROJ volumes 0 · $PROJ networks 0 · volumes $(vols) (the machine's $VOL0 + the unit's containers') · the four tags present, on the digests (checked at the start)"
  echo "\$ cd .harness/compose-run && DOCKER_HOST=\$DH perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -cp \"<after/'s classes>:<Maven's runtime class path for after/>\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=20600 --spring.profiles.active=dev $TRL"
  CMPW=1
  (cd .harness/compose-run && DOCKER_HOST="$DH" exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -cp "../after/tiffinbox-web/target/classes:$(cat ../after/tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=20600 --spring.profiles.active=dev $TRL) > .harness/compose.log 2>&1 < /dev/null & pid=$!
  local i=0 c TBUP=0; while [ $i -lt 1200 ]; do c=$(cu 20600 /actuator/health/readiness); [ "$c" = 200 ] && { TBUP=1; break; }; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  [ "$TBUP" = 1 ] || { tail -20 .harness/compose.log | mask >&3; die "after/ under dev with Compose did not start"; }
  CMPV=$(dk inspect -f '{{range .Mounts}}{{.Name}} {{end}}' ${PROJ}-mongo-1 2> /dev/null)
  echo "  the project's containers: $(dk ps --filter label=com.docker.compose.project=$PROJ --format '{{.Names}} {{.Ports}}' | sort | paste -sd'|' -)"
  echo "  the elasticsearch service's container: its Mounts: $(m=$(mounts ${PROJ}-elasticsearch-1); echo "${m:-none}") · the mongo service's: $(mounts ${PROJ}-mongo-1) · volumes now $(vols)"
  echo "  the start's lines: $($G -oE 'Successfully applied [0-9]+ migrations?|tiffinbox +: (dishes re-indexed: .*|kitchen value: +[0-9]+)' .harness/compose.log | sed -E 's/^tiffinbox +: /tiffinbox: /' | sort | uniq -c | sed -E 's/^ +//' | paste -sd'|' -)"
  echo "  the hosts the client's requests went to (its trace logger): $($G -oE "Request +: curl -iX [A-Z]+ 'http://127\.0\.0\.1:[0-9]+" .harness/compose.log | sed -E 's/^.*(127\.0\.0\.1:[0-9]+)$/\1/' | sort -u | paste -sd' ' -) · the Compose service's own published port (dk port): $(dk port ${PROJ}-elasticsearch-1 | paste -sd'|' -)"
  echo "  curl on 18884 (the elasticsearch service): _cat/indices dishes -> $(catix 18884 dishes) · match name veg -> $(hits 18884 dishes '{"query":{"match":{"name":"veg"}}}')"
  echo "  GET /dishes/search?q=veg (TiffinBox) -> $(cu 20600 '/dishes/search?q=veg') $(tr -d '\n' < .harness/body)"
  tbstop compose-run 20600
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
anchor() { local f l
  cat .harness/anchor-tests.out
  echo "-- the jar's libraries (ls lib | wc -l), before/ and after/, and the jars after/ gained or lost (comm, by name):"
  for t in before after; do echo "  $t/: $(ls .harness/$t/$XD/lib | wc -l | tr -d ' ') libraries"; done
  echo "  gained: $(comm -13 <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c . || true) - $(comm -13 <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | paste -sd' ' -) · lost: $(comm -23 <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c . || true)"
  echo "  the Jackson jars in after/'s lib: $(ls .harness/after/$XD/lib | $G -i jackson | paste -sd' ' -) · in before/'s: $(ls .harness/before/$XD/lib | $G -i jackson | paste -sd' ' -)"
  echo "  the version lines off the jar names: $(ls .harness/after/$XD/lib | $G -xE 'spring-boot-4\.1\.2\.jar|spring-data-elasticsearch-6\.1\.2\.jar|elasticsearch-java-9\.4\.8\.jar|elasticsearch-rest5-client-9\.4\.8\.jar|hibernate-core-[0-9.]+Final\.jar' | paste -sd' ' -)"
  echo "  Boot's own metadata for the key the receipt sets (spring-boot-elasticsearch-4.1.2.jar's spring-configuration-metadata.json): $(unzip -p "$BE/spring-boot-elasticsearch/4.1.2/spring-boot-elasticsearch-4.1.2.jar" META-INF/spring-configuration-metadata.json | python3 -I -c 'import json,sys; d=json.load(sys.stdin); print(" · ".join(p["name"] + " " + p["type"] + " default " + json.dumps(p.get("defaultValue")) for p in d["properties"] if p["name"] in ("spring.elasticsearch.uris", "management.health.elasticsearch.enabled")))')"
  echo "-- after/ under the profile dev, on PostgreSQL + Redis + MongoDB + Elasticsearch (the four containers, by the digest), a fresh database, an emptied Redis, a fresh MongoDB, Compose off; the index dishes removed first (curl DELETE), so the start meets none:"
  eq 20604 DELETE /dishes > /dev/null
  echo "  curl DELETE /dishes on 20604, then _cat/indices dishes* -> $(m=$(catix 20604 'dishes*'); echo "${m:-none}")"
  echo "  the overrides: $DEV --management.endpoints.web.exposure.include=health,prometheus,beans (the datasource from the config tree, the password never on a command line; /actuator/beans for this run only)"
  freshmongo; flush; pgdb u21anchor
  tb after run-pg 20600 $DEV --management.endpoints.web.exposure.include=health,prometheus,beans
  [ "$TBUP" = 1 ] || { tail -20 .harness/tb.log | mask >&3; die "after/ under dev did not start"; }
  startlines .harness/tb.log
  echo "  the rows (psql, the unit's PostgreSQL): select count(*) from dish -> $(psq $CN u21anchor 'select count(*) from dish') · select id, meal_type from dish order by id -> $(psq $CN u21anchor 'select id || $$ $$ || meal_type from dish order by id' | paste -sd',' - | sed 's/,/, /g')"
  echo "  curl on 20604: _cat/indices dishes -> $(catix 20604 dishes)"
  echo "  curl: GET /dishes/_mapping -> $(eq 20604 GET /dishes/_mapping | python3 -I -c 'import json,sys; p=json.load(sys.stdin)["dishes"]["mappings"]["properties"]; print(" · ".join(k + " " + json.dumps(p[k], sort_keys=True) for k in sorted(p)))')"
  echo "  curl: GET /dishes/_settings (flat; its analysis and replicas) -> $(eq 20604 GET '/dishes/_settings?flat_settings=true' | python3 -I -c 'import json,sys; s=json.load(sys.stdin)["dishes"]["settings"]; print(" · ".join(k + " " + json.dumps(s[k]) for k in sorted(s) if k.startswith("index.analysis") or k in ("index.number_of_replicas","index.number_of_shards")))')"
  echo "  curl: GET /dishes/_doc/1 -> _source $(eq 20604 GET /dishes/_doc/1 | python3 -I -c 'import json,sys; print(json.dumps(json.load(sys.stdin)["_source"], sort_keys=True))')"
  echo "  curl: POST /dishes/_analyze {analyzer dish, \"Vegetarian Lunch Box\"} -> $(toks 20604 /dishes '{"analyzer":"dish","text":"Vegetarian Lunch Box"}')"
  echo "  curl: POST /dishes/_search match name veg -> $(hits 20604 dishes '{"query":{"match":{"name":"veg"}}}') · match name vegetarian -> $(hits 20604 dishes '{"query":{"match":{"name":"vegetarian"}}}')"
  local n0; n0=$(wc -l < .harness/tb.log)
  echo "  GET /dishes/search?q=veg (TiffinBox) -> $(cu 20600 '/dishes/search?q=veg') $(tr -d '\n' < .harness/body) · q=vegetarian -> $(cu 20600 '/dishes/search?q=vegetarian') $(tr -d '\n' < .harness/body)"
  echo "  the requests the finder sent for q=veg, by the client's trace logger (the two, whole bodies): "
  tail -n +$((n0 + 1)) .harness/tb.log | $G -oE "curl -iX POST 'http://127\.0\.0\.1:[0-9]+/dishes/_search[^']*' -d '.*\"query\":\"veg\".*'$" | sed -E "s#'http://127\.0\.0\.1:[0-9]+#'<es>#" | sed 's/^/    /'
  for l in /revenue/by-customer /revenue /kitchen /menu/day-19 /actuator/health /dashboard; do f=$(cu 20600 $l)
    case $l in /dashboard) echo "  GET $l -> $f" ;; /menu/day-19) echo "  GET $l -> $f $(tr -d '\n' < .harness/body | cut -c1-60)…" ;; *) echo "  GET $l -> $f $(tr -d '\n' < .harness/body | cut -c1-300)" ;; esac; done
  cu 20600 /actuator/beans > /dev/null
  echo "  /actuator/beans (this run's override): dishes $($G -o '"dishes"' .harness/body | $G -c . || true) · dishSearch $($G -o '"dishSearch"' .harness/body | $G -c . || true) · dishEntityRepository $($G -o '"dishEntityRepository"' .harness/body | $G -c . || true) · elasticsearchClient $($G -o '"elasticsearchClient"' .harness/body | $G -c . || true) · Spring MVC's JSON converters, by their beans' types: $(python3 -I -c 'import json,sys,re; d=json.load(open(sys.argv[1])); t=sorted({b["type"] for c in d["contexts"].values() for b in c["beans"].values() if re.search(r"Jackson.*HttpMessageConverter|HttpMessageConverters$", b["type"])}); print(" · ".join(t) or "none")' .harness/body)"
  echo "  the response header of /dishes/search: $(curl -s --noproxy '*' -D - -o /dev/null 'http://127.0.0.1:20600/dishes/search?q=veg' | tr -d '\r' | $G -i '^content-type:')"
  dk stats --no-stream --format '{{.Name}} {{.MemUsage}}' $CN $RN $MN $EN > .harness/stats-four-$CAPRUN.txt 2>&1 || true
  echo "  dk stats --no-stream with the four stores alive: read into the receipt's log, never this capture (resident sizes move)"
  tbstop run-pg 20600
  psq $CN postgres "drop database u21anchor with (force)" > /dev/null
  echo "-- a second dev start of after/ on the same Elasticsearch (a fresh database, an emptied Redis, a fresh MongoDB): the re-index meets the ten documents the first left:"
  echo "  curl: _cat/indices dishes before it -> $(catix 20604 dishes)"
  freshmongo; flush; pgdb u21anchor2
  tb after run-pg 20600 $DEV
  [ "$TBUP" = 1 ] || { tail -20 .harness/tb.log | mask >&3; die "after/'s second dev start did not start"; }
  echo "  the start's re-index line: $($G -oE 'dishes re-indexed: .*' .harness/tb.log)"
  echo "  the client's requests (method and path, in order): $($G -oE "Request +: curl -iX [A-Z]+ 'http://127\.0\.0\.1:[0-9]+/[^'?]*" .harness/tb.log | sed -E "s/^Request +: curl -iX //; s#'http://127\.0\.0\.1:[0-9]+#<es>#" | uniq -c | sed -E 's/^ +([0-9]+) /(x\1) /' | paste -sd'|' - | sed 's/|/ · /g')"
  echo "  curl: _cat/indices dishes after it -> $(catix 20604 dishes) · match name veg -> $(hits 20604 dishes '{"query":{"match":{"name":"veg"}}}')"
  tbstop run-pg 20600
  psq $CN postgres "drop database u21anchor2 with (force)" > /dev/null
  compose; }
tokens() {
  echo "-- tokens: the analyzers, by curl on 20604 (the unit's Elasticsearch, the shipped index dishes that anchor's start left):"
  echo "  POST /_analyze {analyzer standard, \"Vegetarian Lunch Box\"} -> $(toks 20604 '' '{"analyzer":"standard","text":"Vegetarian Lunch Box"}')"
  echo "  POST /dishes/_analyze {analyzer dish, \"Vegetarian Lunch Box\"} -> $(toks 20604 /dishes '{"analyzer":"dish","text":"Vegetarian Lunch Box"}')"
  echo "  POST /dishes/_analyze {field name, \"veg\"} (the field's own analyzer, at search) -> $(toks 20604 /dishes '{"field":"name","text":"veg"}')"
  echo "  the shipped mapping's fields (no keyword sub-field on name): $(eq 20604 GET /dishes/_mapping | python3 -I -c 'import json,sys; p=json.load(sys.stdin)["dishes"]["mappings"]["properties"]; print(" · ".join(k + " " + p[k]["type"] + (" fields " + ",".join(p[k]["fields"]) if "fields" in p[k] else "") for k in sorted(p)))')"
  echo "  term name (text) \"Vegetarian Lunch Box\" -> $(hits 20604 dishes '{"query":{"term":{"name":"Vegetarian Lunch Box"}}}') · term name \"vegetarian\" -> $(hits 20604 dishes '{"query":{"term":{"name":"vegetarian"}}}')"
  local v; v=$(hits 20604 dishes '{"query":{"term":{"mealType":"VEG"}}}')
  echo "  term mealType (keyword) \"VEG\" -> $v · term mealType \"veg\" -> $(hits 20604 dishes '{"query":{"term":{"mealType":"veg"}}}')"
  echo "  the ids' rows (V4__dish.sql's order): $(mtypes "${v% ·*}")"
  echo "  the Java side, the same run: $($G -E '^ES IT _analyze on dishes' .harness/verify.log | head -1)"; }
nohit() { local p
  echo "-- nohit: the labelled copy std (dish-settings.json's analyzer dish without its synonym - the standard tokenizer and lowercase), under dev, on its own Elasticsearch ($ES, 127.0.0.1:20605) and the unit's PostgreSQL, Redis and a fresh MongoDB:"
  echo "  the copy's one change (harness/variants.py std), as its diff:"; $G -E '^[-+] ' .harness/variant-std.txt | sed 's/^/    /'
  eq 20605 DELETE /dishes > /dev/null   # the copy's index from the run before (if any) removed - its answer is not printed: it moves between the three runs (2026-11-23)
  echo "  curl DELETE /dishes on 20605, then _cat/indices dishes* -> $(m=$(catix 20605 'dishes*'); echo "${m:-none}")"
  freshmongo; flush; pgdb u21std
  tb std run-std 20600 $DEVB --spring.elasticsearch.uris=http://127.0.0.1:20605
  [ "$TBUP" = 1 ] || { tail -20 .harness/tb.log | mask >&3; die "the copy under dev did not start"; }
  echo "  the copy's start: $($G -oE 'Successfully applied [0-9]+ migrations?|dishes re-indexed: .*' .harness/tb.log | paste -sd'|' - | sed 's/|/ · /g') · the hosts its client's requests went to: $($G -oE "Request +: curl -iX [A-Z]+ 'http://127\.0\.0\.1:[0-9]+" .harness/tb.log | sed -E 's/^.*(127\.0\.0\.1:[0-9]+)$/\1/' | sort -u | paste -sd' ' -)"
  echo "  curl on 20605: _cat/indices dishes -> $(catix 20605 dishes) · _analyze {analyzer dish, \"Vegetarian Lunch Box\"} -> $(toks 20605 /dishes '{"analyzer":"dish","text":"Vegetarian Lunch Box"}') · beside _analyze {analyzer standard} -> $(toks 20605 '' '{"analyzer":"standard","text":"Vegetarian Lunch Box"}')"
  echo "  GET /dishes/search?q=veg (the copy's TiffinBox) -> $(cu 20600 '/dishes/search?q=veg') $(tr -d '\n' < .harness/body) · its JVM still running: $(kill -0 "$pid" 2> /dev/null && echo yes || echo no) · lines naming an Exception in its log: $($G -cE '[A-Za-z]+Exception\b' .harness/tb.log || true)"
  echo "  GET /dishes/search?q=vegetarian (the control, the same JVM) -> $(cu 20600 '/dishes/search?q=vegetarian') $(tr -d '\n' < .harness/body)"
  echo "  curl on 20605: match name veg -> $(hits 20605 dishes '{"query":{"match":{"name":"veg"}}}') · curl's exit $(curl -s --noproxy '*' -o /dev/null -H 'Content-Type: application/json' -X POST http://127.0.0.1:20605/dishes/_search -d '{"query":{"match":{"name":"veg"}}}'; echo $?)"
  echo "  curl on 20605: match name vegetarian -> $(hits 20605 dishes '{"query":{"match":{"name":"vegetarian"}}}')"
  p=$(hits 20605 dishes '{"query":{"prefix":{"name":"veg"}}}')
  echo "  curl on 20605: prefix name veg -> $p · the ids' rows: $(mtypes "${p% ·*}")"
  echo "  the shipped analyzer, the same run - curl on 20604: match name veg -> $(hits 20604 dishes '{"query":{"match":{"name":"veg"}}}')"
  tbstop run-std 20600
  psq $CN postgres "drop database u21std with (force)" > /dev/null; }
SX='dishes_en dishes_ngram dishes_syn dishes_default'
sayso() { local x p f s
  echo "-- sayso: the ways to say so, on the copy's Elasticsearch (20605): its index dishes (the standard analyzer's tokens), and scratch indices of the same ten documents (V4__dish.sql's rows, ids 1-10), each named, each removed at the end:"
  for x in $SX; do eq 20605 DELETE /$x > /dev/null; done
  p=$(hits 20605 dishes '{"query":{"prefix":{"name":"veg"}}}'); echo "  dishes (standard): prefix name veg -> $p · the ids' rows: $(mtypes "${p% ·*}")"
  p=$(hits 20605 dishes '{"query":{"match_phrase_prefix":{"name":"veg"}}}'); echo "  dishes (standard): match_phrase_prefix name veg -> $p"
  p=$(hits 20605 dishes '{"query":{"wildcard":{"name":"veg*"}}}'); echo "  dishes (standard): wildcard name veg* -> $p"
  p=$(hits 20605 dishes '{"query":{"match":{"name":{"query":"veg","fuzziness":"AUTO"}}}}'); echo "  dishes (standard): match name veg fuzziness AUTO -> $p"
  echo "  dishes_en (name analysed by english, number_of_replicas 0): PUT -> $(eq 20605 PUT /dishes_en '{"settings":{"number_of_replicas":0},"mappings":{"properties":{"name":{"type":"text","analyzer":"english"}}}}' | ack) · bulk -> $(bulk 20605 dishes_en)"
  echo "    _analyze {analyzer english, \"vegetarian vegetable vegan veg\"} -> $(toks 20605 '' '{"analyzer":"english","text":"vegetarian vegetable vegan veg"}') · match name veg -> $(hits 20605 dishes_en '{"query":{"match":{"name":"veg"}}}')"
  echo "  dishes_ngram (name analysed by edge_ngram 2-15 on letters at index time, standard at search, number_of_replicas 0): PUT -> $(eq 20605 PUT /dishes_ngram '{"settings":{"number_of_replicas":0,"analysis":{"tokenizer":{"edge":{"type":"edge_ngram","min_gram":2,"max_gram":15,"token_chars":["letter"]}},"analyzer":{"autocomplete":{"type":"custom","tokenizer":"edge","filter":["lowercase"]}}}},"mappings":{"properties":{"name":{"type":"text","analyzer":"autocomplete","search_analyzer":"standard"}}}}' | ack) · bulk -> $(bulk 20605 dishes_ngram)"
  p=$(hits 20605 dishes_ngram '{"query":{"match":{"name":"veg"}}}')
  echo "    _analyze {analyzer autocomplete, \"Vegetarian\"} -> $(toks 20605 /dishes_ngram '{"analyzer":"autocomplete","text":"Vegetarian"}') · match name veg -> $p · the ids' rows: $(mtypes "${p% ·*}")"
  s=$(python3 -I -c 'import json,sys; print(json.dumps({"settings": json.load(open(sys.argv[1])), "mappings": {"properties": {"name": {"type": "text", "analyzer": "dish"}}}}))' after/tiffinbox-web/src/main/resources/dish-settings.json)
  echo "  dishes_syn (after/'s dish-settings.json as its settings, read off the file; name analysed by dish): PUT -> $(eq 20605 PUT /dishes_syn "$s" | ack) · bulk -> $(bulk 20605 dishes_syn)"
  p=$(hits 20605 dishes_syn '{"query":{"match":{"name":"veg"}}}')
  echo "    _analyze {analyzer dish, \"Vegetarian Lunch Box\"} -> $(toks 20605 /dishes_syn '{"analyzer":"dish","text":"Vegetarian Lunch Box"}') · match name veg -> $p · the ids' rows: $(mtypes "${p% ·*}")"
  echo "  dishes_default (no settings: the default replica, one): PUT -> $(eq 20605 PUT /dishes_default '{"mappings":{"properties":{"name":{"type":"text"}}}}' | ack)"
  echo "  _cat/indices on 20605 (index, health, status, pri, rep, docs.count): $(catix 20605 'dishes*')"
  echo "  _cluster/health on 20605 with dishes_default there: $(eq 20605 GET /_cluster/health | python3 -I -c 'import json,sys; d=json.load(sys.stdin); print("status " + d["status"] + " · unassigned_shards " + str(d["unassigned_shards"]))')"
  for x in $SX; do echo "  DELETE /$x -> $(eq 20605 DELETE /$x | ack)"; done
  echo "  _cluster/health on 20605 after: $(eq 20605 GET /_cluster/health | python3 -I -c 'import json,sys; d=json.load(sys.stdin); print("status " + d["status"] + " · unassigned_shards " + str(d["unassigned_shards"]))')"; }
fuzzy() { local p
  echo "-- fuzzy: fuzziness on the copy's index dishes (20605, the standard analyzer's tokens), beside the shipped analyzer on 20604:"
  p=$(hits 20605 dishes '{"query":{"match":{"name":{"query":"veg","fuzziness":2}}}}')
  echo "  match name veg fuzziness 2 -> $p · the ids' rows: $(mtypes "${p% ·*}")"
  echo "  match name veg fuzziness AUTO -> $(hits 20605 dishes '{"query":{"match":{"name":{"query":"veg","fuzziness":"AUTO"}}}}')"
  echo "  _analyze standard \"Egg Fried Rice\" -> $(toks 20605 '' '{"analyzer":"standard","text":"Egg Fried Rice"}') · \"Vegan Lunch Box\" -> $(toks 20605 '' '{"analyzer":"standard","text":"Vegan Lunch Box"}')"
  p=$(hits 20604 dishes '{"query":{"match":{"name":"veg"}}}')
  echo "  the shipped analyzer (20604, dishes): match name veg -> $p · the ids' rows: $(mtypes "${p% ·*}")"; }
late() {
  echo "-- late: a synonym after the documents are in - a scratch index dishes_late on the copy's Elasticsearch (20605), name analysed by the default (standard), the ten documents:"
  eq 20605 DELETE /dishes_late > /dev/null
  echo "  PUT /dishes_late -> $(eq 20605 PUT /dishes_late '{"settings":{"number_of_replicas":0},"mappings":{"properties":{"name":{"type":"text"}}}}' | ack) · bulk -> $(bulk 20605 dishes_late) · match name veg -> $(hits 20605 dishes_late '{"query":{"match":{"name":"veg"}}}')"
  echo "  POST /dishes_late/_close -> $(eq 20605 POST /dishes_late/_close | ack)"
  echo "  PUT /dishes_late/_settings {the analyzer dish: standard, lowercase, the synonym veg, vegetarian} -> $(eq 20605 PUT /dishes_late/_settings '{"analysis":{"filter":{"veg_syn":{"type":"synonym","synonyms":["veg, vegetarian"]}},"analyzer":{"dish":{"type":"custom","tokenizer":"standard","filter":["lowercase","veg_syn"]}}}}' | ack)"
  echo "  POST /dishes_late/_open -> $(eq 20605 POST /dishes_late/_open | ack)"
  local i=0; while [ "$(eq 20605 GET '/_cluster/health/dishes_late' | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["status"])')" != green ]; do i=$((i + 1)); [ $i -lt 240 ] || die "dishes_late did not turn green after _open"; sleep 0.25; done
  echo "  PUT /dishes_late/_mapping {name: text, analyzer dish} -> $(eq 20605 PUT /dishes_late/_mapping '{"properties":{"name":{"type":"text","analyzer":"dish"}}}' | ack) · curl's exit $(curl -s --noproxy '*' -o /dev/null -H 'Content-Type: application/json' -X PUT http://127.0.0.1:20605/dishes_late/_mapping -d '{"properties":{"name":{"type":"text","analyzer":"dish"}}}'; echo $?) · its HTTP status $(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' -H 'Content-Type: application/json' -X PUT http://127.0.0.1:20605/dishes_late/_mapping -d '{"properties":{"name":{"type":"text","analyzer":"dish"}}}')"
  echo "  PUT /dishes_late/_mapping {name: text, search_analyzer dish} -> $(eq 20605 PUT /dishes_late/_mapping '{"properties":{"name":{"type":"text","search_analyzer":"dish"}}}' | ack)"
  echo "  GET /dishes_late/_mapping, name -> $(eq 20605 GET /dishes_late/_mapping | python3 -I -c 'import json,sys; print(json.dumps(json.load(sys.stdin)["dishes_late"]["mappings"]["properties"]["name"], sort_keys=True))')"
  echo "  match name veg, no document indexed again -> $(hits 20605 dishes_late '{"query":{"match":{"name":"veg"}}}') · _analyze {field name, \"veg\"} -> $(toks 20605 /dishes_late '{"field":"name","text":"veg"}') · docs.count $(eq 20605 GET '/_cat/indices/dishes_late?h=docs.count' | tr -d ' \n')"
  echo "  DELETE /dishes_late -> $(eq 20605 DELETE /dishes_late | ack)"; }
explain() {
  echo "-- explain: the score of the vegetarian box (id 1) for match name vegetarian, on the shipped index dishes (20604), read off _explain:"
  eq 20604 GET /dishes/_explain/1 '{"query":{"match":{"name":"vegetarian"}}}' | python3 -I -c '
import json,sys
d=json.load(sys.stdin); print("  matched " + str(d["matched"]).lower())
def w(e, dep):
    print("  " + "  " * dep + repr(e["value"]) + " " + e["description"])
    for c in e.get("details", []): w(c, dep + 1)
w(d["explanation"], 0)'
  echo "  _cat/indices dishes (its documents, deleted ones included): $(eq 20604 GET '/_cat/indices/dishes?h=docs.count,docs.deleted' | sed -E 's/ +/ /g; s/ $//')"; }
default() { local h
  echo "-- after/ with no profile (TiffinBox's default run): H2 in memory, Docker at nothing (DOCKER_HOST=tcp://127.0.0.1:1), no Elasticsearch, no MongoDB; one JVM; /actuator/beans exposed for this run (a command-line override, the one beside the port):"
  DOCKER_HOST=tcp://127.0.0.1:1 tb after run-h2 20600 --management.endpoints.web.exposure.include=health,prometheus,beans
  [ "$TBUP" = 1 ] || { tail -20 .harness/tb.log | mask >&3; die "after/'s default run did not start"; }
  echo "  GET /actuator/health -> $(cu 20600 /actuator/health) $(tr -d '\n' < .harness/body | cut -c1-200)"
  echo "  GET /dishes/search?q=veg -> $(cu 20600 '/dishes/search?q=veg') · GET /revenue/by-customer -> $(cu 20600 /revenue/by-customer) · GET /menu/day-19 -> $(cu 20600 /menu/day-19) · GET /revenue -> $(cu 20600 /revenue) $(tr -d '\n' < .harness/body) · GET /kitchen -> $(cu 20600 /kitchen) $(tr -d '\n' < .harness/body) · GET /dashboard -> $(cu 20600 /dashboard)"
  cu 20600 /actuator/beans > /dev/null
  echo "  /actuator/beans: dishes $($G -o '"dishes"' .harness/body | $G -c . || true) · dishSearch $($G -o '"dishSearch"' .harness/body | $G -c . || true) · elasticsearchClient $($G -o '"elasticsearchClient"' .harness/body | $G -c . || true) · a bean whose type names Elasticsearch $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(sum(1 for c in d["contexts"].values() for b in c["beans"].values() if "lasticsearch" in b["type"]))' .harness/body) · dishEntityRepository $($G -o '"dishEntityRepository"' .harness/body | $G -c . || true) · tiffinBoxServer $($G -o '"tiffinBoxServer"' .harness/body | $G -c . || true)"
  tbstop run-h2 20600
  echo "  its log: lines naming 9200 $($G -c 9200 .harness/tb.log || true) · naming elasticsearch, any case $($G -ci elasticsearch .harness/tb.log || true) · naming 27017 $($G -c 27017 .harness/tb.log || true) · naming mongo, any case $($G -ci mongo .harness/tb.log || true) · Flyway: $($G -oE 'Successfully applied [0-9]+ migrations?' .harness/tb.log) on $($G -oE 'Database: jdbc:h2:mem:[^ ]* \(H2 [0-9.]+' .harness/tb.log | sed -E 's/jdbc:h2:mem:[^ ]*/jdbc:h2:mem:<name>/') · its repository lines: $($G -oE 'Found [0-9]+ [A-Za-z ]+ repository interfaces?' .harness/tb.log | paste -sd'|' -)"
  echo "-- the refused shape, labelled: the copy healthkey (application.yaml without the seven Elasticsearch names, management.health.elasticsearch.enabled: false instead), the default run again:"
  echo "  the copy's change (harness/variants.py healthkey), as its diff:"; $G -E '^[-+] ' .harness/variant-healthkey.txt | sed 's/^/    /'
  DOCKER_HOST=tcp://127.0.0.1:1 tb healthkey run-hk 20600
  if [ "$TBUP" = 1 ]; then
    echo "  GET /actuator/health -> $(cu 20600 /actuator/health) $(tr -d '\n' < .harness/body | cut -c1-200) · GET /dishes/search?q=veg -> $(cu 20600 '/dishes/search?q=veg')"
    tbstop run-hk 20600
  else TBX=0; wait "$pid" || TBX=$?; pid=""; echo "  readiness never answered 200 · the JVM's exit $TBX · listening on 20600: $(listeners 20600)"; fi
  echo "  its log: lines naming 9200 $($G -c 9200 .harness/tb.log || true) · naming elasticsearch, any case $($G -ci elasticsearch .harness/tb.log || true) · its repository lines naming Elasticsearch: $($G -oE 'Found [0-9]+ (Reactive )?Elasticsearch repository interfaces?' .harness/tb.log | paste -sd'|' - | sed 's/|/ · /g')"
  echo "  the failure's own lines, as printed (the bean and the cause, each once):"
  $G -oE "Error creating bean with name '(dishes|tiffinBoxServer)'|DataAccessResourceFailureException: Connect to http://localhost:9200 [^;]*" .harness/tb.log | sed -E 's/ +$//' | sort -u | mask | sed 's/^/    /'
  echo "-- the 18 under mvn -o package with Docker at nothing (anchor's tests, the same run's package log):"
  results .harness/package.log; }
absent() {
  echo "-- absent: after/ under dev with PostgreSQL, Redis and a fresh MongoDB up and Elasticsearch absent - spring.elasticsearch.uris on 127.0.0.1:20609, where nothing listens:"
  [ "$(listeners 20609)" = 0 ] || die "20609 is bound - absent needs nothing there"
  echo "  listening on 20609: 0"
  freshmongo; flush; pgdb u21absent
  tb after run-pg 20600 $DEVB --spring.elasticsearch.uris=http://127.0.0.1:20609
  [ "$TBUP" = 0 ] || die "after/ under dev started with Elasticsearch absent"
  TBX=0; wait "$pid" || TBX=$?; pid=""
  echo "  readiness never answered 200 · the JVM's exit $TBX · listening on 20600: $(listeners 20600)"
  echo "  the failure, as printed (its first lines naming the bean and the cause; the logger's prefix cut):"
  $G -oE "Error creating bean with name '[a-zA-Z]+'[^:]*|Failed to instantiate \[[^]]+\]: Constructor threw exception|DataAccessResourceFailureException: [^;]*|Connection refused[^;]*" .harness/tb.log | sed -E 's/ +$//' | sort -u | mask | sed 's/^/    /'
  echo "  its log: lines naming 20609 $($G -c 20609 .harness/tb.log || true) · the hosts its client tried (Connect to ...): $($G -oE 'Connect to http://127\.0\.0\.1:[0-9]+' .harness/tb.log | sort -u | paste -sd' ' -) · 'dishes re-indexed' $($G -c 'dishes re-indexed' .harness/tb.log || true) · Flyway: $($G -oE 'Successfully applied [0-9]+ migrations?' .harness/tb.log | head -1)"
  psq $CN postgres "drop database u21absent with (force)" > /dev/null; }
seven() { local t i c e a port
  for t in before after; do i=0; e=0; [ $t = after ] && port=20600 || port=20607
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
ls=sorted({a for a, b, s in L["tcp"] if s == "LISTEN"}); inc=[x for x in L["tcp"] if x[2] != "LISTEN" and x[0] in (9200, 9300)]; out=[x for x in L["tcp"] if x[2] != "LISTEN" and x[0] not in (9200, 9300)]
print("listening (TCP) on " + ", ".join(map(str, ls)) + " · connections from another local port (outbound): " + str(len(out)) + " · UDP sockets: " + str(len(L["udp"])))'
sockread() { local t; for t in tcp tcp6 udp udp6; do dk exec $1 cat /proc/net/$t > .harness/net-$t.txt 2> /dev/null || : > .harness/net-$t.txt; done
  python3 -I -c "$SOCKPY" .harness/net-tcp.txt .harness/net-tcp6.txt .harness/net-udp.txt .harness/net-udp6.txt; }
sockets() {
  echo "-- sockets: $EN (the unit's Elasticsearch, alive since image), its /proc/net/tcp, tcp6, udp and udp6 read by cat at the end of the receipt (dk exec - a file, never a shell):"
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
  echo "  the shell is now in: $(where "$d2") · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines · listening on 20608 afterwards: $(listeners 20608) · the container $EX afterwards: $(dk ps -aq --filter name=^/$EX\$ | $G -c . || true) · volumes $(vols) (before the shell: $v1) · java processes of the exercise: $(ps -axo command= | $G -c '[D]ishLab.java' || true) · images afterwards: $(dk images -q --no-trunc | sort -u | paste -sd' ' - | md5 -q | cut -c1-8) (at the start: $(printf '%s\n' "$IMGS0" | md5 -q | cut -c1-8))"; }
exercise() {
  printf '%s\n' "$SETUP" > .harness/ex-readme.sh; printf '%s\n' "$SOL" > .harness/ex-sol.sh
  printf '%s\n' 'cd "$1" || exit 1' '. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-readme.st"' 'cd "$1" || exit 1' '. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-sol.st"' > .harness/ex-drive.sh
  echo "exercise/README.md's $(printf '%s\n' "$SETUP" | $G -c .) lines, then exercise/SOLUTION.md's, as written, one after the other in ONE env -i shell (HOME and the PATH this script was started with), started in this folder:"
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh; }


NCAP=1; cap exercise exercise; chk exercise .r-exercise.out "$EXW" "$EXQ"
for f in exercise/README.md exercise/SOLUTION.md; do
  w=$(python3 -I -B harness/chk21.py wib .r-exercise.out "$f"); [ "$(wib "$f")" = "$w" ] || die "$f's \"What it prints\" block is not what its lines printed: $(diff <(wib "$f") <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"; done
echo "  exercise: each file's \"What it prints\" block = what its lines printed (bash's; zsh's the same - chk21)"
pub exercise
NCAP=3
cap image image; chk image .r-image.out; pub image
echo "  dk stats --no-stream, the labelled default container (each run of image, read into this log, not a capture): $(cat .harness/stats-default-[123].txt 2> /dev/null | paste -sd'|' - | sed 's/|/ · /g')"
export DOCKER_HOST="$DH" TESTCONTAINERS_RYUK_DISABLED=true; tests > .harness/anchor-tests.raw 2>&1 || true; unset DOCKER_HOST TESTCONTAINERS_RYUK_DISABLED
$G -q '^  \*\*\* ' .harness/anchor-tests.raw && { cat .harness/anchor-tests.raw >&3; die "the tests stopped (above)"; }
mask < .harness/anchor-tests.raw > .harness/anchor-tests.out
echo "  the tests (anchor's Maven half): run once in this run of record - their 3/3 is across the runs; the three anchor captures each carry these lines"
startstores
cap anchor anchor; chk anchor .r-anchor.out; pub anchor
echo "  dk stats --no-stream with the four stores alive (each run of anchor, read into this log, not a capture): $(cat .harness/stats-four-[123].txt 2> /dev/null | paste -sd'|' - | sed 's/|/ · /g')"
cap tokens tokens; chk tokens .r-tokens.out; pub tokens
mkes $ES 20605
echo "  the copy's Elasticsearch: $ES, by the digest, --pull never, the six settings, 127.0.0.1:20605 · volumes $(vols)"
for c in nohit sayso fuzzy late; do cap $c $c; case $c in fuzzy) chk $c ".r-$c.out" .r-sayso.out ;; *) chk $c ".r-$c.out" ;; esac; pub $c; done
dk rm -fv $ES > /dev/null 2>&1 || die "$ES could not be removed"
echo "  $ES removed (rm -fv) · volumes $(vols)"
for c in explain absent; do cap $c $c; chk $c ".r-$c.out"; pub $c; done
for c in $MN $RN $CN; do dk rm -fv "$c" > /dev/null 2>&1 || die "the container $c could not be removed"; done
echo "  $MN, $RN and $CN removed (rm -fv) · volumes $(vols)"
cap default default; chk default .r-default.out; pub default
cap seven seven; chk seven .r-seven.out "$S466"; pub seven
cap sockets sockets; chk sockets .r-sockets.out; pub sockets
NUM=$(python3 -I -B harness/chk21.py numbers .r-nohit.out .r-sayso.out .r-fuzzy.out README.md exercise/README.md exercise/SOLUTION.md) || die "S8.95: $(printf '%s\n' "$NUM" | $G '^FAIL' | head -3 | paste -sd';' -)"
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
  ! $G -qE '"took" ?: ?[0-9]|took\[[0-9]|"@timestamp" ?: ?"2|refresh_interval|search\.idle\.after|connection-timeout|socket-timeout|start_time_in_millis|uptime_in_millis|request_interval|request_jitter|poll\.interval|index\.creation_date|"timestamp":"20' "$f" || die "R.432 / TIMEPAT_S4B: $f holds an Elasticsearch time, a client wait or a date"
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
echo "  hygiene: dur8 over the captures and README.md's text blocks 0 words; no path, time, took, @timestamp, client wait, log time, stack frame, H2 database name, raw port, all-interfaces binding, pid, token or password in any capture; every JVM and Maven under its alarm; no H2 file outside .harness"
# ---- the end: the containers, Testcontainers, the volumes, the images, the trees, the ports -------------------------------------
dk rm -fv $EN > /dev/null 2>&1 || die "the container $EN could not be removed"
tcrm; [ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container is still there"
for c in $CN $RN $MN $EN $ES $ED $EX; do [ -z "$(dk ps -aq --filter name=^/$c\$ 2> /dev/null)" ] || die "the container $c is still there"; done
[ -z "$(dk ps -aq --filter label=com.docker.compose.project=$PROJ 2> /dev/null)" ] && [ -z "$(dk volume ls -q --filter name=^$PROJ)" ] && [ -z "$(dk network ls -q --filter name=^$PROJ)" ] || die "a container, volume or network of this run is still there"
VOL1=$(vols); IMGS1=$(dk images -q --no-trunc 2> /dev/null | sort -u | paste -sd' ' -)
[ "$VOL1" = "$VOL0" ] || die "R.322: the volume count moved, $VOL0 -> $VOL1"
[ "$IMGS1" = "$IMGS0" ] || die "the images moved over this run - nothing may be pulled"
[ ! -e "$HOME/.testcontainers.properties" ] || die "R.318: ~/.testcontainers.properties appeared over this run"
echo "  docker at the end: $EN removed with its volumes (rm -fv), $ES, $ED, $EX, $CN, $RN, $MN and the $PROJ project gone; Testcontainers containers 0; volumes $VOL0 -> $VOL1; images $NI0, the same list (nothing pulled)"
pin before-tree before end; pin after-tree after end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 20578, 20600-20609 or 18881-18884 at the end - the containers bound 20601-20605 and 20608 and are gone; TiffinBox bound 20600 (after/ and the copies) and 20607 (before/, the seven), the ITs' containers 20606 and 20578, Compose 18881-18884 inside anchor's window, and all stopped; 20609 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c8-unit21: every capture = published (JVM captures 3/3 in this run; exercise and the tests once per run); every spoken number asserted by chk21.py; before/ and after/ = their pins; the volume count and the images unchanged"
