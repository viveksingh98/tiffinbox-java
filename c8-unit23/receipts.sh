#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 8 · Which Database, Honestly - this unit's receipts. NO anchor change (flag 10): before/ and after/ are both links to
# ../c8-unit22/after, one tree, and ../c8-tiffinbox equals it. The unit is a table, table.md: five stores this course ran (rows) by
# five failure modes (columns); every body cell names a capture of an earlier unit and the number that capture printed, or says
# unmeasured. harness/u23check.py reads every cell (S8.86, S8.97); five cells are RE-RUN here, one per store, on 22/after's tree.
# Whose: the CHECKER's (rule, feature, exercise: Python alone, no Docker, no JVM), the shipped READMEs' (honest: three capture blocks
# read by their section's name), the ANCHOR's (22/after's jar: replay 2's TiffinBox with no profile, replay 3's and the dev start's
# TiffinBox under dev, the seven) and the HARNESSES of earlier units, copied from their folders into .harness/ and compiled against
# 22/after's jar (unit 12's probe.u12.U12 - replay 2; unit 18's probe.u18.H18 - replay 1's INSERTs; unit 19's probe.u19.H19 - replay 4),
# and curl's alone on a scratch index (replay 5's dishes_std).
# Captures (rule, honest, feature, replay and the seven run three times and are hashed; exercise once per run of record):
#   exercise   exercise/README.md's lines, then SOLUTION.md's, as written, in ONE env -i shell - bash, then zsh -f; and the two
#              refusals the brief names (unmeasured in that cell; a feature word in another cell)
#   rule       u23check.py --derive on the shipped table.md: every cell, its capture, its README line, its md5 line, its numbers
#   honest     PostgreSQL's cost cell: the numbers read off c8-unit01 statements, c8-unit18 oneread and rename, by section name
#   feature    the failure receipt: a scratch copy of table.md with one feature word - exit 1, bad 1 - beside the shipped table, exit 0
#   replay     five cells re-run on 22/after: 1 PostgreSQL unit18/rename's three tables · 2 Caffeine unit12/stale · 3 Redis
#              unit14/absent · 4 MongoDB unit19/silent · 5 Elasticsearch unit21/nohit (REST, a scratch index dishes_std); the
#              Elasticsearch container's sockets at its tail (S8.92)
#   seven      the comparison set on the one tree (H2, no Docker, 20620)
# Every tree is COPIED under .harness/ and built there, offline (-o, from .m2-demo, a copy of the course's seed, maven.repo.local
# absolute), every module from the tree's own sources (-pl tiffinbox-web -am, R.391). Every JVM and Maven run under an alarm (R.247),
# every JVM with SIGINT reset to its default (R.410). Every docker call names its socket (dk, R.344), --pull never; every container is
# removed with its volumes (rm -fv, R.387) and the volume count asserted back. A receipt waits on a count it polls (R.412). The
# Elasticsearch container runs with the six settings (compose.yaml's).
# Ports (20620-20629): 20620 TiffinBox (replays 2, 3 and the dev start; the seven) · 20621 the unit's PostgreSQL · 20622 the unit's
# Redis · 20623 the unit's MongoDB, a standalone, fresh per dev start · 20624 the unit's Elasticsearch · 20625 never bound (Redis
# absent) · 20626 the harness's PostgreSQL (replay 1's three tables) · 20627-20629 spare, asserted free.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
RIMG=redis@sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3
MIMG=mongo@sha256:05b334b0a7a78fe913caac0cd2e1ecccf4da515d9a3a44be911b6ea3734c17cd
EIMG=docker.elastic.co/elasticsearch/elasticsearch@sha256:fb7f2d0df199b3ea14a700e88a0b701d502cb44409ece3e1540b1dc1c5d5c403
GT=glibc.pthread.rseq=1
CN=c8u23-pg; RN=c8u23-redis; MN=c8u23-mongo; EN=c8u23-es; HN=c8u23-pg-h
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
pid=""; mpid=""; xpid=""; TC0=""; INTR=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.u12.") || index($0, "probe.u18.") || index($0, "probe.u19.") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "curlset.sh") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || $3 ~ /(^|\/)javac$/ || index($0, "u23check.py") || index($0, "ex-drive.sh")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
# the scratch index replay 5 makes on the unit's Elasticsearch, deleted by the trap (printed when it ran)
ixrm() { [ -n "$TC0" ] || return 0
  [ -n "$(dk ps -q --filter name=^/$EN\$ 2> /dev/null)" ] || return 0
  curl -s --noproxy '*' -o /dev/null -X DELETE "http://127.0.0.1:20624/dishes_std" 2> /dev/null || true
  [ -z "$INTR" ] || echo "  the trap: the scratch index dishes_std deleted - _cat/indices now: $(curl -s --noproxy '*' 'http://127.0.0.1:20624/_cat/indices?h=index' 2> /dev/null | sort | paste -sd' ' -)" >&3; }
ctrm() { local c; [ -n "$TC0" ] || return 0
  for c in $HN $EN $MN $RN $CN; do [ -z "$(dk ps -aq --filter name=^/$c\$ 2> /dev/null)" ] || dk rm -fv "$c" > /dev/null 2>&1 || true; done
  [ -z "$INTR" ] || echo "  the trap: the unit's containers removed with their volumes (rm -fv) - c8u23-* now: $(dk ps -aq --filter name=^/c8u23- 2> /dev/null | $G -c . || true) · volumes $(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')" >&3; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid" "$pid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; ixrm; ctrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harnesses are compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|FLYWAY_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|REDIS[A-Z_]*|MONGO[A-Z_]*|ES_[A-Z_]*|ELASTIC[A-Z_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT|COMPOSE_[A-Z_]*)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"

# ---- gates before anything is run: the folder, the links, the pins, the prose, the table, the checker -------------------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh table.md' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk23.py dur8.py logback.xml s823.py tree23.py u23check.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md check.sh table.md' ] || die "exercise/ holds another file, or misses one"
cmp -s harness/dur8.py ../c8-unit02/harness/dur8.py || die "harness/dur8.py is not the builders' dur8.py as unit 02 shipped it, byte for byte"
cmp -s harness/logback.xml ../c8-unit07/harness/logback.xml || die "harness/logback.xml is not unit 07's, byte for byte"
for t in before after; do [ -L $t ] && [ "$(readlink $t)" = ../c8-unit22/after ] || die "R.250/flag 10: $t must be a link to ../c8-unit22/after (it points at: $(readlink $t 2> /dev/null || echo 'not a link'))"; done
for t in after before; do [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] && die "$t holds a secrets/ or a target/ - never built in place"; true; done
git rev-parse -q --verify 'c83793f^{commit}' > /dev/null 2>&1 || die "unit 22's commit c83793f is not in this repository's history"
rm -rf .harness; mkdir -p .harness/run-h2/secrets/tiffinbox .harness/run-pg/secrets/tiffinbox .harness/run-h .harness/src
U22P=$(awk '$1 == "after-tree" { print $2, $3 }' ../c8-unit22/receipts.md5)
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree23.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  [ "$want" = "$U22P" ] || die "flag 10: $nm's pin ($want) is not ../c8-unit22/receipts.md5's after-tree line ($U22P)"
  echo "  $dir/ ($3): python3 -I harness/tree23.py $dir/ -> $got = receipts.md5's $nm line = ../c8-unit22/receipts.md5's after-tree line"; }
echo "  before -> $(readlink before) · after -> $(readlink after): one tree, two names (flag 10, R.250)" | tee .harness/gate.out
P1=$(pin before-tree before start) || exit 1; P2=$(pin after-tree after start) || exit 1; printf '%s\n' "$P1" "$P2" | tee -a .harness/gate.out
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness ../c8-unit22/after ../c8-tiffinbox 2>&1 || true)
[ -z "$AD" ] || die "flag 10: ../c8-tiffinbox is not ../c8-unit22/after - this unit changes no anchor file: $(printf '%s\n' "$AD" | head -2 | paste -sd';' -)"
echo "  ../c8-tiffinbox against ../c8-unit22/after: diff -rq empty - the anchor, unchanged by this unit" | tee -a .harness/gate.out
# the prose gate: README and the exercise whole; table.md's prose without its rows (the rows are u23check's, and chk23 static's)
$G -v '^|' table.md > .harness/table-prose.md
PROSE='README.md exercise/README.md exercise/SOLUTION.md .harness/table-prose.md'
DW=$(python3 -I -B harness/s823.py harness/dur8.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -2 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
ST=$(python3 -I -B harness/chk23.py static) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /' | tee -a .harness/gate.out
CK=$(python3 -I -B harness/u23check.py table.md) || die "u23check.py refuses the shipped table: $(printf '%s\n' "$CK" | $G -E '^(BAD|self-test FAILED|malformed)' | head -3 | paste -sd';' -)"
sed -E 's/^(FEATURE = re\.compile\().*$/\1r"(?!x)x")/' harness/u23check.py > .harness/u23cf.py
CF=$(python3 -I -B .harness/u23cf.py table.md); CFE=$?
[ "$CFE" = 3 ] && printf '%s\n' "$CF" | $G -q '^self-test FAILED: a feature word in a cell that names its capture and its number' || die "R.276/R.374: the checker with its feature list emptied did not fail its self-test (exit $CFE)"
echo "  the cannot-fail detector (R.276, R.374): u23check.py with its feature list emptied -> exit $CFE · $(printf '%s\n' "$CF" | head -1 | cut -c1-120)" | tee -a .harness/gate.out
rm -f .harness/u23cf.py
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
DN=$($G -rniwE -- "$DISH" README.md table.md exercise 2> /dev/null | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|VALUES-PENDING|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md table.md exercise 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose, table or exercise: $PH"
! $G -q '^```java$' README.md || die "README.md holds a java block - this unit has no code of its own but its checker"
VEC='a vector index is a kind of index this course does not build'
[ "$($G -ciwE 'vector' table.md README.md exercise/*.md | awk -F: '{ s += $2 } END { print s }')" = "$($G -cF "$VEC" table.md README.md exercise/*.md | awk -F: '{ s += $2 } END { print s }')" ] && $G -qF "$VEC" table.md || die "flag 10: every line naming a vector is the one sentence, byte for byte, and table.md holds it"
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
EXQ="Your turn: the Elasticsearch row's silent-wrong-answer cell says powerful full-text search. Replace it with the capture that failed and its number."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
[ "$EXW" = 21 ] || die "the exercise's spoken line is $EXW words, the brief's is 21"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
EQ=$(printf '%s\n' "$EXQ" | python3 -I -B -c 'import importlib.util,sys,io,contextlib; t=sys.stdin.read(); sys.argv=["x","harness/dur8.py"]; s=importlib.util.spec_from_file_location("g","harness/s823.py"); g=importlib.util.module_from_spec(s)
with contextlib.redirect_stdout(io.StringIO()): s.loader.exec_module(g)
print(len(g.m.DUR.findall(t)), len(g.s4b(t, t)))')
[ "$EQ" = '0 0' ] || die "the exercise's spoken line: dur8 and XFAM_S4B must find 0 ($EQ)"
EF=$(printf '%s\n' 'Your turn: the Elasticsearch row says fast full-text search.' | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
[ "$EF" = 1 ] || die "dur8's own check: the planted word fast in the exercise's line must be found once ($EF)"
SETUP=$(block exercise/README.md); SOL=$(block exercise/SOLUTION.md)
[ -n "$SETUP" ] && [ -n "$SOL" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
[ "$(diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G -c '^[<>]')" = 2 ] || die "R.196: SOLUTION.md's block must be the README's with one line changed"
[ "$(printf '%s\n' "$SETUP" | $G -cxF 'bash exercise/check.sh "$EX/table.md"')" = 1 ] && [ "$(printf '%s\n' "$SOL" | $G -cxF 'bash exercise/check.sh "$EX/table.md"')" = 1 ] || die "R.196: both blocks are checked by exercise/check.sh, never by an exit alone"
[ "$(diff table.md exercise/table.md | $G -c '^[<>]')" = 2 ] && diff table.md exercise/table.md | $G -qxF '> | Elasticsearch | powerful full-text search | `unit22/absent`: the JVM'"'"'s exit 1, Connection refused | `unit22/drift`: intx, rows 0 / index 1 | `unit22/stale`: the template'"'"'s save, the count that follows it -> 0 | `unit21/sayso`: edge_ngram, _analyze "Vegetarian" -> 9 tokens |' || die "exercise/table.md must be table.md with the Elasticsearch silent-wrong-answer cell alone changed, to powerful full-text search"
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
ESR=$($G -v '^ *#' receipts.sh | $G -E '(dk|docker) run ' | $G -F '$EIMG' | $G -vcF '$ESSET' || true)
[ "$ESR" = 0 ] || die "flag 4: an Elasticsearch container run without the six settings (\$ESSET)"
[ -z "$($G -v '^ *#' receipts.sh | $G -E '(dk|docker) run ' | $G -oE -- ' -p [^ ]+' | $G -v '^ -p 127\.0\.0\.1:' || true)" ] || die "S8.94: a port published on every interface (-p without 127.0.0.1)"
MVA=$($G -v '^ *#' receipts.sh | $G -F 'clean ' | $G -F '$MV' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am"
! $G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -qE '\bverify\b.*\$MV|\$MV.*\bverify\b' || die "this unit runs no mvn verify - its 18 + 13 is unit 22's, read"
echo "  prose, per sentence (s823, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test): refused 0 over README.md, exercise/README.md, exercise/SOLUTION.md and table.md's prose · dish names 0 · placeholders 0 · no java block · the one vector sentence, byte for byte, in table.md" | tee -a .harness/gate.out
echo "  u23check.py on the shipped table: $(printf '%s\n' "$CK" | tail -1) · its self-test: $(printf '%s\n' "$CK" | head -1 | sed 's/^self-test: //')" | tee -a .harness/gate.out
echo "  the exercise: the spoken line $EXW words (wc -w), dur8 and XFAM_S4B on it 0 and 0 (a planted fast in its place: dur8 1); exercise/table.md = table.md with the one cell changed; SOLUTION.md's block = the README's with one line changed; both checked by exercise/check.sh; the two \"What it prints\" blocks differ (R.196)" | tee -a .harness/gate.out
echo "  static: no kill by name; every docker call on the pinned socket, every dk run --pull never, the MongoDB container with GLIBC_TUNABLES, the Elasticsearch container with the six settings; no exec into a container to run curl (§BUILDERS 9); no port on every interface (S8.94); every container removal dk rm -fv (R.387); every Maven build -pl tiffinbox-web -am (R.391); no mvn verify"
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
S22=$(python3 -I -B -c 'import re,sys
t=open("../c8-unit22/README.md",encoding="utf-8").read().split("\n"); i=[n for n,l in enumerate(t) if re.match(r"^### \d+ · seven\b",l)][0]; b=[]
for l in t[i+1:]:
    if l.startswith(("### ","## ")): break
    b+=re.findall(r"the seven responses: 7 lines · md5 ([0-9a-f]{32})",l)
print(b[0] if len(b)==2 and b[0]==b[1] else "")')
[ ${#S22} = 32 ] || die "the seven's md5 could not be read off ../c8-unit22/README.md's seven block (its two lines, one md5)"
echo "  the seven's md5, read off ../c8-unit22/README.md's seven capture block (before/ and after/ there, one md5): $S22" | tee -a .harness/gate.out
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
for c in $CN $RN $MN $EN $HN; do [ -z "$(dk ps -aq --filter name=^/$c\$ 2> /dev/null)" ] || die "a container named $c exists before the run - an interrupted run's? docker -H \"\$DH\" rm -fv $c"; done
TC0=1
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 20620 20621 20622 20623 20624 20625 20626 20627 20628 20629"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
[ "$(pgrep -x java | wc -l | tr -d ' ')" = 0 ] || die "a java process is running before this script starts one - not this script's; stop it first"
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · the four digests present ($IMG, $RIMG, $MIMG, $EIMG) · nothing pulled, ever · no c8u23-* container · ports 20620-20629 (and 18425, 8080) free · java processes 0"

# ---- the captures that need no Docker and no JVM: the exercise, the rule, honest, feature ----------------------------------------
vols() { dk volume ls -q 2> /dev/null | wc -l | tr -d ' '; }
NCAP=3
unpub=""; CAPRUN=0; CAPNM=""
cap() { local nm=$1 i n=$NCAP; shift
  i=1; while [ $i -le $n ]; do CAPRUN=$i; CAPNM=$nm; "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    $G -q '^  \*\*\* ' .harness/cap.raw && { cat .harness/cap.raw >&3; die "$nm stopped (above)"; }
    ! $G -qE 'localhost:[0-9]{5}|127\.0\.0\.1:(3|4|5|6)[0-9]{4}' .harness/cap.raw || die "R.319: $nm printed a container's port raw"
    [ -z "$PW" ] || ! $G -qF -- "$PW" .harness/cap.raw || die "$nm printed the PostgreSQL password"
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
  o=$(python3 -I -B harness/chk23.py "$nm" "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk23 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -5 >&3; die "$nm: its check failed (harness/chk23.py)"; }
  VALS="$VALS${VALS:+ · }$(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
ckline() { $G -E '^(BAD|cells) ' "$1" | sed -E 's/[[:space:]]+$//' | paste -sd'|' - | sed 's/|/ · /g'; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2
  rm -f .harness/ex-*.st .harness/ex-*.out
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 1200 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after its cap"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines, the block's exit $e1:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "  then the solution's lines, in the same shell - the block's exit $e2:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the README's lines: exit $($G -oE '^check: exit [0-9]+' .harness/ex-readme.out | sed 's/^check: exit //') · $($G -E '^cells ' .harness/ex-readme.out)"
  echo "  SOLUTION.md's lines: exit $($G -oE '^check: exit [0-9]+' .harness/ex-sol.out | sed 's/^check: exit //') · $($G -E '^cells ' .harness/ex-sol.out)"
  echo "  the shell is now in: $(where "$d2") · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines · java processes 0: $( [ "$(pgrep -x java | wc -l | tr -d ' ')" = 0 ] && echo yes || echo no)"; }
exercise() { local e
  printf '%s\n' "$SETUP" > .harness/ex-readme.sh; printf '%s\n' "$SOL" > .harness/ex-sol.sh
  printf '%s\n' 'cd "$1" || exit 1' '. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-readme.st"' 'cd "$1" || exit 1' '. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-sol.st"' > .harness/ex-drive.sh
  echo "exercise/README.md's $(printf '%s\n' "$SETUP" | $G -c .) lines, then exercise/SOLUTION.md's, as written, one after the other in ONE env -i shell (HOME and the PATH this script was started with), started in this folder; no Docker, no JVM:"
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh
  echo "-- the brief's rule, shown: the same cell with the word unmeasured (the checker's list holds unit21/nohit for it), and a feature word in another cell:"
  sed 's/| Elasticsearch | powerful full-text search |/| Elasticsearch | unmeasured |/' exercise/table.md > .harness/ex-unm.md
  bash exercise/check.sh .harness/ex-unm.md > .harness/ex-unm.out 2>&1; e=$?
  echo "  \"unmeasured\" in that cell: exit $e · bad $($G -oE 'bad [0-9]+$' .harness/ex-unm.out | sed 's/^bad //') · $($G '^BAD ' .harness/ex-unm.out)"
  sed 's/| Elasticsearch | powerful full-text search |/| Elasticsearch | `unit21\/nohit`: veg, 0 hits |/; s/`unit20\/noindex`: getIndexes \["_id_"\], COLLSCAN, totalDocsExamined 120/`unit20\/noindex`: getIndexes ["_id_"], COLLSCAN, totalDocsExamined 120, a flexible schema/' exercise/table.md > .harness/ex-fw.md
  bash exercise/check.sh .harness/ex-fw.md > .harness/ex-fw.out 2>&1; e=$?
  echo "  a feature word elsewhere (the solved cell, and flexible in MongoDB's default cell): exit $e · bad $($G -oE 'bad [0-9]+$' .harness/ex-fw.out | sed 's/^bad //') · $($G '^BAD ' .harness/ex-fw.out)"
  rm -f .harness/ex-unm.md .harness/ex-fw.md; }
rule() { local e
  echo "-- rule: the checker on the shipped table (python3 -I -B harness/u23check.py --derive table.md) - every cell, every capture it names, the README section and the receipts.md5 line that resolve it, and each number beside the capture line that printed it:"
  python3 -I -B harness/u23check.py --derive table.md > .harness/rule.txt 2>&1; e=$?
  cat .harness/rule.txt
  echo "  the checker's exit: $e"; }
honest() { python3 -I -B harness/chk23.py honestread; }
feature() { local e f
  echo "-- feature (the failure receipt, R.312's negation with its control): a scratch copy of table.md, the Elasticsearch silent-wrong-answer cell replaced by a feature word; the checker on it, then on the shipped table, the same run:"
  sed 's/| Elasticsearch | `unit21\/nohit`: match name veg -> 0 \[\] |/| Elasticsearch | `unit21\/nohit`: match name veg -> 0 [], powerful full-text search |/' table.md > .harness/table-feature.md
  echo "  the copy's one change (diff table.md against it):"; diff table.md .harness/table-feature.md | $G '^[<>]' | sed 's/^/    /'
  python3 -I -B harness/u23check.py .harness/table-feature.md > .harness/feature.txt 2>&1; e=$?
  $G '^BAD ' .harness/feature.txt
  echo "  the copy with the feature word: the checker's exit $e · $($G '^cells ' .harness/feature.txt)"
  python3 -I -B harness/u23check.py table.md > .harness/feature0.txt 2>&1; f=$?
  echo "  the shipped table, the same run: the checker's exit $f · $($G '^cells ' .harness/feature0.txt)"
  rm -f .harness/table-feature.md; echo "  the copy removed: $( [ -e .harness/table-feature.md ] && echo no || echo yes)"; }
NCAP=1; cap exercise exercise; chk exercise .r-exercise.out
for f in exercise/README.md exercise/SOLUTION.md; do
  case $f in *README.md) w=$(awk '/^in bash / { f = 1; next } f && /^  then the solution/ { exit } f' .r-exercise.out | sed 's/^    //') ;; *) w=$(awk '/^  then the solution/ { f = 1; next } f && /^  the README.s lines: exit/ { exit } f' .r-exercise.out | sed 's/^    //') ;; esac
  [ "$(wib "$f")" = "$w" ] || die "$f's \"What it prints\" block is not what its lines printed: $(diff <(wib "$f") <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"; done
echo "  exercise: each file's \"What it prints\" block = what its lines printed (bash's; zsh's the same - chk23)"
pub exercise
NCAP=3
cap rule rule; chk rule .r-rule.out; pub rule
cap honest honest; chk honest .r-honest.out; pub honest
cap feature feature; chk feature .r-feature.out; pub feature

# ---- the tree, copied; the build; the earlier units' harnesses, copied and compiled -----------------------------------------------
M2="$PWD/.m2-demo"
[ -d "$M2" ] || die ".m2-demo (a copy of the course's seed, _research/m2-seed-c8-s4b) is missing - README.md, The repository"
NF0=$(find "$M2" -type f | wc -l | tr -d ' ')
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy after .harness/after
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
bg "cd .harness/after && $MV clean package -DskipTests -pl tiffinbox-web -am" .harness/build-after.log
[ "$RE" = 0 ] || { tail -20 .harness/build-after.log >&3; die ".harness/after did not build offline (exit $RE)"; }
DL=$($G -cE '^\[INFO\] Download(ing|ed) from ' .harness/build-after.log || true)
[ "$DL" = 0 ] || die "Maven's log says it downloaded (offline: no)"
bg "cd .harness/after && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-after.log
[ "$RE" = 0 ] || die ".harness/after: the jar's extract failed"
NLIB=$(ls .harness/after/$XD/lib | wc -l | tr -d ' ')
[ "$(find "$M2" -type f | wc -l | tr -d ' ')" = "$NF0" ] || die ".m2-demo gained files - offline: no"
cp ../c8-unit12/harness/src/probe/u12/*.java ../c8-unit18/harness/src/probe/u18/H18.java ../c8-unit19/harness/src/probe/u19/*.java .harness/src/
for f in ../c8-unit12/harness/src/probe/u12/*.java ../c8-unit18/harness/src/probe/u18/H18.java ../c8-unit19/harness/src/probe/u19/*.java; do cmp -s "$f" ".harness/src/${f##*/}" || die "$f was not copied byte for byte"; done
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*\" .harness/src/*.java" .harness/javac.log
[ "$RE" = 0 ] || die "the earlier units' harnesses did not compile against after/: $(head -5 .harness/javac.log)"
TF=secrets/tiffinbox/shutdown-token
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/run-h2/$TF) || die "the token was not written"
for d in run-pg after; do mkdir -p .harness/$d/secrets/tiffinbox; (umask 077 && cp .harness/run-h2/$TF .harness/$d/$TF) || die "the token was not copied"; done
TOKEN=$(head -1 .harness/run-h2/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
PW=$(openssl rand -hex 16); (umask 077 && printf 'POSTGRES_USER=tiffinbox\nPOSTGRES_PASSWORD=%s\n' "$PW" > .harness/pg.env) || die "the password file was not written"
echo "  built after/'s tree offline from a copy (mvn -o package -DskipTests -pl tiffinbox-web -am, exit 0, offline: yes, 'Downloaded from' $DL, .m2-demo's files $NF0 unchanged), extracted its jar ($NLIB libraries); copied the earlier units' harnesses byte for byte (../c8-unit12/harness/src/probe/u12: $(ls ../c8-unit12/harness/src/probe/u12 | paste -sd' ' -) · ../c8-unit18/harness/src/probe/u18/H18.java · ../c8-unit19/harness/src/probe/u19: $(ls ../c8-unit19/harness/src/probe/u19 | paste -sd' ' -)) and compiled them (javac 25) against after/'s jar and its libraries; a shutdown token and a PostgreSQL password generated (0600, never printed)" | tee -a .harness/gate.out

# ---- helpers -------------------------------------------------------------------------------------------------------------------
pgready() { local i=0; while ! dk exec "$1" pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 120 ] || die "PostgreSQL ($1) did not accept connections (120 tries)"; sleep 0.5; done; }
eq() { local p=$1 m=$2 u=$3; shift 3
  if [ $# -gt 0 ]; then curl -s --noproxy '*' -H 'Content-Type: application/json' -X "$m" "http://127.0.0.1:$p$u" --data-binary "$1" 2> /dev/null; else curl -s --noproxy '*' -X "$m" "http://127.0.0.1:$p$u" 2> /dev/null; fi; }
esup() { local i=0 c; while :; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/_cluster/health" 2> /dev/null || true); [ "$c" = 200 ] && break
    i=$((i + 1)); [ $i -lt 480 ] || die "Elasticsearch on $1 did not answer _cluster/health 200 (480 reads)"; sleep 0.25; done; }
PYH='import json,sys
d=json.load(sys.stdin)
if "error" in d: print("error " + d["error"]["type"] + ": " + d["error"]["reason"]); sys.exit(0)
i=sorted(h["_id"] for h in d["hits"]["hits"]); print(str(d["hits"]["total"]["value"]) + " [" + ", ".join(i) + "]")'
hits() { eq "$1" POST "/$2/_search" "$3" | python3 -I -c "$PYH"; }
ack() { python3 -I -c 'import json,sys; d=json.load(sys.stdin); print("error " + d["error"]["type"] if "error" in d else "acknowledged " + str(d.get("acknowledged")).lower())'; }
catix() { eq "$1" GET "/_cat/indices/$2?h=index,health,status,pri,rep,docs.count&s=index" | sed -E 's/ +/ /g; s/ $//' | paste -sd'|' - | sed 's/|/ · /g'; }
mkmongo() {
  bg "dk run -d --pull never --name $MN -p 127.0.0.1:20623:27017 -e GLIBC_TUNABLES=$GT $MIMG --unixSocketPrefix /data/db" .harness/docker-run-mongo.log
  [ "$RE" = 0 ] || die "the MongoDB container did not start: $(tail -2 .harness/docker-run-mongo.log)"
  local i=0; while [ "$(dk logs $MN 2>&1 | $G -c 'Waiting for connections' || true)" = 0 ]; do i=$((i + 1)); [ $i -lt 240 ] || die "MongoDB's log never said Waiting for connections (240 reads)"; sleep 0.25; done
  [ "$(dk port $MN | paste -sd'|' -)" = '27017/tcp -> 127.0.0.1:20623' ] || die "$MN publishes on another address than 127.0.0.1:20623"; }
# a FRESH MongoDB for every dev start, as unit 20 found its start's witness drifts on a reused one
freshmongo() { dk rm -fv $MN > /dev/null 2>&1 || die "$MN could not be removed"; mkmongo; echo "  a fresh MongoDB ($MN, removed with its volumes and started again, 127.0.0.1:20623)"; }
startstores() {
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:20621:5432 --env-file .harness/pg.env $IMG" .harness/docker-run-pg.log
  [ "$RE" = 0 ] || die "the PostgreSQL container did not start: $(tail -2 .harness/docker-run-pg.log)"
  bg "dk run -d --pull never --name $HN -p 127.0.0.1:20626:5432 --env-file .harness/pg.env $IMG" .harness/docker-run-pg-h.log
  [ "$RE" = 0 ] || die "the harness's PostgreSQL did not start: $(tail -2 .harness/docker-run-pg-h.log)"
  bg "dk run -d --pull never --name $RN -p 127.0.0.1:20622:6379 $RIMG" .harness/docker-run-redis.log
  [ "$RE" = 0 ] || die "the Redis container did not start: $(tail -2 .harness/docker-run-redis.log)"
  mkmongo
  bg "dk run -d --pull never --name $EN --hostname $EN -p 127.0.0.1:20624:9200 $ESSET $EIMG" .harness/docker-run-es.log
  [ "$RE" = 0 ] || die "the Elasticsearch container did not start: $(tail -2 .harness/docker-run-es.log)"
  esup 20624; pgready $CN; pgready $HN
  local i=0; while [ "$(dk exec $RN redis-cli PING 2> /dev/null | tr -d '\r')" != PONG ]; do i=$((i + 1)); [ $i -lt 200 ] || die "Redis did not answer PING"; sleep 0.1; done
  [ "$(dk port $CN | paste -sd'|' -)" = '5432/tcp -> 127.0.0.1:20621' ] && [ "$(dk port $HN | paste -sd'|' -)" = '5432/tcp -> 127.0.0.1:20626' ] && [ "$(dk port $RN | paste -sd'|' -)" = '6379/tcp -> 127.0.0.1:20622' ] && [ "$(dk port $EN | paste -sd'|' -)" = '9200/tcp -> 127.0.0.1:20624' ] || die "a store publishes on another address than 127.0.0.1:<its port>"
  echo "  the stores: $CN (PostgreSQL, 127.0.0.1:20621, TiffinBox's) and $HN (PostgreSQL, 127.0.0.1:20626, the harness's tables) from $IMG; $RN (Redis, 127.0.0.1:20622, no password) from $RIMG; $MN (MongoDB, a standalone, 127.0.0.1:20623, no auth, -e GLIBC_TUNABLES=$GT, --unixSocketPrefix /data/db) from $MIMG; $EN (Elasticsearch, 127.0.0.1:20624, 9300 not published, the six settings) from $EIMG; all --pull never, 127.0.0.1 only; the password from a 0600 file, never printed · volumes now $(vols)"
  echo "  $EN: GET / (curl) -> version.number $(eq 20624 GET / | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["version"]["number"])') · its environment, the six (dk inspect): $(dk inspect -f '{{json .Config.Env}}' $EN | python3 -I -c 'import json,sys; print(" · ".join(sorted(e for e in json.load(sys.stdin) if e.split("=")[0] in ("discovery.type","xpack.security.enabled","xpack.ml.enabled","ingest.geoip.downloader.enabled","xpack.inference.elastic.authorization.enabled","ES_JAVA_OPTS"))))')"; }
psq() { dk exec "$1" psql -U tiffinbox -d "$2" -qAt -v ON_ERROR_STOP=1 -c "$3" 2>&1 || die "psql failed on $1/$2: $3"; }
pgdb() { psq $CN postgres "drop database if exists $1 with (force)" > /dev/null; psq $CN postgres "create database $1" > /dev/null
  (umask 077 && printf 'jdbc:postgresql://127.0.0.1:20621/%s?user=tiffinbox&password=%s\n' "$1" "$PW" > .harness/run-pg/secrets/tiffinbox/jdbc-url) || die "the URL was not written"
  PGD=$1; echo "  a fresh database on $CN: $1 (psql) · its URL in the config tree (0600, never printed)"; }
pgdrop() { psq $1 postgres "drop database $2 with (force)" > /dev/null; }
flush() { [ "$(dk exec $RN redis-cli FLUSHALL | tr -d '\r')" = OK ] || die "redis-cli FLUSHALL failed"; echo "  redis-cli FLUSHALL (the unit's Redis) -> OK"; }
DEVB="--spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.mongodb.uri=mongodb://127.0.0.1:20623/tiffinbox --spring.elasticsearch.uris=http://127.0.0.1:20624"
cu() { curl -s --noproxy '*' -o .harness/body -w '%{http_code}' "http://127.0.0.1:$1$2" 2> /dev/null || true; }
# tb RUN PORT ARG...: TiffinBox's jar of after/ (java -jar, under its alarm, SIGINT at its default), from .harness/RUN (its config
# tree), in the background (pid); the receipt polls readiness on PORT until 200, or until the JVM is gone (TBUP = 1 or 0)
tb() { local run=$1 port=$2 i=0 c; shift 2
  echo "\$ cd .harness/$run && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -jar ../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port $*" | mask
  (cd .harness/$run && exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -jar ../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port "$@") > .harness/tb.log 2>&1 < /dev/null & pid=$!
  TBUP=0; while [ $i -lt 960 ]; do c=$(cu $port /actuator/health/readiness); [ "$c" = 200 ] && { TBUP=1; break; }
    kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  if [ "$TBUP" = 0 ] && kill -0 "$pid" 2> /dev/null; then die "TiffinBox neither answered readiness nor stopped (960 reads)"; fi; }
tbstop() { local c; c=$(printf 'X-Shutdown-Token: %s\n' "$(head -1 .harness/$1/$TF)" | curl -s --noproxy '*' -o /dev/null -w '%{http_code}' -H @- -X POST "http://127.0.0.1:$2/shutdown" 2> /dev/null || true)
  TBX=0; wait "$pid" || TBX=$?; pid=""
  [ "$(listeners $2)" = 0 ] || die "something still listens on $2 after TiffinBox stopped"
  echo "  POST /shutdown (the token on curl's standard input) -> $c · the JVM's exit $TBX · listening on $2: 0"; }
cellof() { echo "  the cell it replays (table.md, $1 · $2): $(python3 -I -B harness/chk23.py cellof "$1" "$2")"; }
HCP="../hc:../after/$XD/tiffinbox-web-1.0.0.jar:../after/$XD/lib/*"
# hj RUN PORT CLASS ARG...: one harness JVM from .harness/RUN, under its alarm, SIGINT at its default; at each "pause N: the receipt
# reads now" the function named by PH runs (its lines printed after the JVM's own) and ./go is written; its PROBE lines printed
hj() { local run=$1 k=1 e=0; shift
  echo "\$ cd .harness/$run && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -cp \"$HCP\" $*" | sed 's#\.\./\.\./harness#…/harness#'
  rm -f .harness/$run/go; : > .harness/pause.out
  (cd .harness/$run && exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -cp "$HCP" "$@") > .harness/h.log 2>&1 < /dev/null & mpid=$!
  while kill -0 "$mpid" 2> /dev/null; do
    if $G -q "^PROBE pause $k: the receipt reads now" .harness/h.log; then
      if [ -n "$PH" ]; then "$PH" $k >> .harness/pause.out 2>&1; fi
      : > .harness/$run/go; k=$((k + 1)); fi
    sleep 0.1; done
  wait "$mpid" || e=$?; mpid=""
  [ "$e" != 142 ] || die "the harness JVM's alarm fired (exit 142, cap 240 - R.247)"
  HE=$e; cat .harness/h.log >> .harness/h-all.log; }
PH=""
phpsql() { echo "the receipt at pause $1, psql (a second client, PostgreSQL): Ravi's row says $(psq $CN $PGD "select meals_per_day from customer where name = 'Ravi'")"; }
UPD="UPDATE f3.item_allergen SET allergen = 'soya' WHERE allergen = 'soy'"
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
STDS=$(python3 -I -B -c 'import ast,sys
t=ast.parse(open("../c8-unit21/harness/variants.py",encoding="utf-8").read())
for n in ast.walk(t):
    if isinstance(n,ast.Dict):
        for k,v in zip(n.keys,n.values):
            if isinstance(k,ast.Constant) and k.value=="std": print(v.elts[0].elts[1].value); print(v.elts[0].elts[2].value)')
[ "$(printf '%s\n' "$STDS" | wc -l | tr -d ' ')" = 2 ] || die "unit 21's std variant could not be read off ../c8-unit21/harness/variants.py"
STDJ=$(python3 -I -B -c 'import json,sys
old,new=sys.argv[1],sys.argv[2]; s=open(sys.argv[3],encoding="utf-8").read()
assert s.count(old)==1
print(json.dumps({"settings":json.loads(s.replace(old,new)),"mappings":{"properties":{"name":{"type":"text","analyzer":"dish"},"mealType":{"type":"keyword"},"price":{"type":"integer"}}}}))' "$(printf '%s\n' "$STDS" | sed -n 1p)" "$(printf '%s\n' "$STDS" | sed -n 2p)" after/tiffinbox-web/src/main/resources/dish-settings.json) || die "the std settings could not be made from after/'s dish-settings.json"

# ---- replay: five cells, one per store, on after/'s tree (RE-MEASURE 8) ----------------------------------------------------------
replay() { local n e
  echo "-- replay: five cells, one per store, each re-run on after/'s tree (= before/'s: ../c8-unit22/after, one tree), after/'s jar built offline from a copy; each prints the number its cell holds, beside the cell"
  echo "-- replay 1 · PostgreSQL · a cost that grows · unit18/rename, the three tables (labelled): the harness's PostgreSQL ($HN, 20626), a fresh database u23ren"
  cellof PostgreSQL 'a cost that grows'
  psq $HN postgres "drop database if exists u23ren with (force)" > /dev/null; psq $HN postgres "create database u23ren" > /dev/null
  (cd .harness/run-h && exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -Dlogback.configurationFile=../../harness/logback.xml -Dh18.port=20623 -cp "$HCP" probe.u18.H18 sql3) > .harness/sql3.sql 2> .harness/sql3.err < /dev/null & mpid=$!; e=0; wait "$mpid" || e=$?; mpid=""
  [ "$e" = 0 ] || die "probe.u18.H18 sql3 exited $e: $(tail -2 .harness/sql3.err | paste -sd';' -)"
  echo "\$ cd .harness/run-h && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -Dlogback.configurationFile=…/harness/logback.xml -Dh18.port=20623 -cp \"$HCP\" probe.u18.H18 sql3 -> its exit $e · INSERT lines $($G -c '^INSERT' .harness/sql3.sql) · other lines $($G -vc '^INSERT' .harness/sql3.sql || true) (unit 18's H18, copied; MenuDay.forDays(30), 22/after's)"
  cat ../c8-unit18/harness/pg3.sql .harness/sql3.sql | dk exec -i $HN psql -U tiffinbox -d u23ren -q -v ON_ERROR_STOP=1 > .harness/pgload.log 2>&1 || die "the three tables did not load: $(tail -2 .harness/pgload.log)"
  echo "  ../c8-unit18/harness/pg3.sql (read by path, md5 $(md5 -q ../c8-unit18/harness/pg3.sql)), then those INSERTs, into u23ren · rows: f3.menu $(psq $HN u23ren 'select count(*) from f3.menu') · f3.menu_item $(psq $HN u23ren 'select count(*) from f3.menu_item') · f3.item_allergen $(psq $HN u23ren 'select count(*) from f3.item_allergen') · of them soy $(psq $HN u23ren "select count(*) from f3.item_allergen where allergen = 'soy'")"
  echo "  the three tables, labelled: \$ psql -c \"$UPD\" -> $(dk exec $HN psql -U tiffinbox -d u23ren -v ON_ERROR_STOP=1 -c "$UPD" 2>&1 | tr -d '\r')"
  echo "    the menus that list soya now (count(DISTINCT m.id)): $(psq $HN u23ren "SELECT count(DISTINCT m.id) FROM f3.menu m JOIN f3.menu_item i ON i.menu_id = m.id JOIN f3.item_allergen ia ON ia.item_id = i.id WHERE ia.allergen = 'soya'") · rows that say soy: $(psq $HN u23ren "select count(*) from f3.item_allergen where allergen = 'soy'")"
  echo "  MongoDB's half of unit18/rename, as read (not replayed here - the capture's own line, ../c8-unit18/README.md): $(python3 -I -B -c 'import re; t=open("../c8-unit18/README.md",encoding="utf-8").read(); print(re.search(r"op update · ns tiffinbox\.menu · nMatched \d+ · nModified \d+", t).group(0))')"
  pgdrop $HN u23ren; echo "  dropped: u23ren"
  echo "-- replay 2 · Caffeine · a silent wrong answer · unit12/stale: after/'s jar with no profile (Caffeine in the JVM, the profile unit 12 used) on the unit's PostgreSQL ($CN, 20621), unit 12's harness probe.u12.U12 (copied, compiled against after/'s jar), its web server on 20620"
  cellof Caffeine 'a silent wrong answer'
  pgdb u23s; PH=phpsql
  hj run-pg probe.u12.U12 stale --tiffinbox.port=20620 --logging.config=../../harness/logback.xml --spring.main.banner-mode=off --spring.jpa.properties.hibernate.generate_statistics=true
  PH=""
  $G -E '^PROBE ' .harness/h.log | $G -v '^PROBE pause ' | mask | sed 's/^/  /'
  sed 's/^/  /' .harness/pause.out
  echo "  its exit $HE · its log, every line but its PROBE lines: ERROR $($G -c '^ERROR ' .harness/h.log || true) · lines naming an Exception $($G -v '^PROBE ' .harness/h.log | $G -cE '[A-Za-z]+Exception\b' || true) · listening on 20620: $(listeners 20620)"
  [ "$HE" = 0 ] || die "unit 12's harness exited $HE"
  pgdrop $CN u23s; echo "  dropped: u23s"
  echo "-- replay 3 · Redis · the store absent at start · unit14/absent: after/ under dev, PostgreSQL (20621), a fresh MongoDB (20623) and Elasticsearch (20624) up, spring.data.redis.port 20625, where nothing listens"
  cellof Redis 'the store absent at start'
  [ "$(listeners 20625)" = 0 ] || die "20625 is bound - replay 3 needs nothing there"
  echo "  listening on 20625 (lsof): 0"
  freshmongo; pgdb u23absent
  tb run-pg 20620 $DEVB --spring.data.redis.port=20625
  [ "$TBUP" = 0 ] || die "after/ under dev started with Redis absent"
  TBX=0; wait "$pid" || TBX=$?; pid=""
  echo "  the JVM's exit: $TBX · then curl /actuator/health on 20620: $(cu 20620 /actuator/health) · listening on 20620: $(listeners 20620)"
  echo "  its log: \"Error creating bean with name 'tiffinBoxServer'\" $($G -c "Error creating bean with name 'tiffinBoxServer'" .harness/tb.log || true) lines · \"RedisConnectionFailureException: Unable to connect to Redis\" $($G -c 'RedisConnectionFailureException: Unable to connect to Redis' .harness/tb.log || true) · \"Application run failed\" $($G -c 'Application run failed' .harness/tb.log || true) · \"Started TiffinBoxApp\" $($G -c 'Started TiffinBoxApp' .harness/tb.log || true) · 'dishes re-indexed' $($G -c 'dishes re-indexed' .harness/tb.log || true)"
  echo "  its first exception line: $($G -m1 -oE "Error creating bean with name '[a-zA-Z]+'[^;]*" .harness/tb.log | sed -E 's/ +$//' | cut -c1-160)"
  pgdrop $CN u23absent; echo "  dropped: u23absent"
  echo "-- the dev start replays 4 and 5 read: after/ under dev on the unit's four stores - PostgreSQL (20621), Redis (20622), a fresh MongoDB (20623), Elasticsearch (20624) - a fresh database u23dev, the shipped index dishes deleted first"
  echo "  curl DELETE /dishes on 20624 -> $(eq 20624 DELETE /dishes | python3 -I -c 'import json,sys; d=json.load(sys.stdin); print("acknowledged true" if d.get("acknowledged") else "none there" if d.get("status") == 404 else "error")') · _cat/indices dishes* -> $(x=$(eq 20624 GET '/_cat/indices/dishes*?h=index' | paste -sd' ' -); echo "${x:-none}")"
  freshmongo; flush; pgdb u23dev
  tb run-pg 20620 $DEVB --spring.data.redis.port=20622
  [ "$TBUP" = 1 ] || { tail -20 .harness/tb.log | mask >&3; die "after/ under dev did not start"; }
  echo "  the start: $($G -oE 'Successfully applied [0-9]+ migrations?' .harness/tb.log | head -1) · $($G -oE 'dishes re-indexed: .*' .harness/tb.log | head -1)"
  echo "-- replay 4 · MongoDB · a silent wrong answer · unit19/silent: unit 19's harness probe.u19.H19 (copied, compiled against after/'s jar) on the unit's MongoDB (20623), the orders the dev start wrote; the summeal step and its control pipeline, one JVM"
  cellof MongoDB 'a silent wrong answer'
  hj run-h -Dlogback.configurationFile=../../harness/logback.xml -Dh19.port=20623 probe.u19.H19 summeal,pipeline
  $G -E '^PROBE ' .harness/h.log | $G -v 'the order the server returned' | sed 's/^/  /'
  echo "  its exit $HE · its log, every line but its PROBE lines: $($G -vc '^PROBE ' .harness/h.log || true) · lines naming an Exception $($G -cE '[A-Za-z]+Exception\b' .harness/h.log || true) · the order the server returned groups that tie (every total 0): not printed, it is the server's"
  [ "$HE" = 0 ] || die "unit 19's harness exited $HE"
  echo "-- replay 5 · Elasticsearch · a silent wrong answer · unit21/nohit, its index half by REST: a labelled scratch index dishes_std on the unit's Elasticsearch (20624), unit 21's std variant of dish-settings.json (the analyzer dish without its synonym), the ten rows of the dev start's dish table"
  cellof Elasticsearch 'a silent wrong answer'
  echo "  the std variant, read off ../c8-unit21/harness/variants.py, as its diff on after/'s dish-settings.json:"
  python3 -I -B -c 'import difflib,sys
s=open(sys.argv[3],encoding="utf-8").read(); t=s.replace(sys.argv[1],sys.argv[2])
for l in difflib.unified_diff(s.splitlines(),t.splitlines(),"after/dish-settings.json","std/dish-settings.json",lineterm="",n=0):
    if not l.startswith(("@@","---","+++")): print("    "+l)' "$(printf '%s\n' "$STDS" | sed -n 1p)" "$(printf '%s\n' "$STDS" | sed -n 2p)" after/tiffinbox-web/src/main/resources/dish-settings.json
  psq $CN u23dev "select id, name, meal_type, price from dish order by id" | tr -d '\r' > .harness/dish-rows.txt
  echo "  the rows (psql, $CN, the dev start's V4): $(wc -l < .harness/dish-rows.txt | tr -d ' ') · ids $(cut -d'|' -f1 .harness/dish-rows.txt | paste -sd',' -)"
  python3 -I -c 'import json,sys
for l in open(sys.argv[1],encoding="utf-8"):
    i,n,m,p=l.rstrip("\n").split("|"); print(json.dumps({"index":{"_id":i}})); print(json.dumps({"name":n,"mealType":m,"price":int(p)}))' .harness/dish-rows.txt > .harness/bulk.ndjson
  echo "  curl PUT /dishes_std (the std settings, the mapping Dish.java names: name text by dish, mealType keyword, price integer) -> $(eq 20624 PUT /dishes_std "$STDJ" | ack)"
  echo "  curl POST /dishes_std/_bulk?refresh=true (the ten rows) -> $(curl -s --noproxy '*' -H 'Content-Type: application/x-ndjson' -X POST 'http://127.0.0.1:20624/dishes_std/_bulk?refresh=true' --data-binary @.harness/bulk.ndjson 2> /dev/null | python3 -I -c 'import json,sys; d=json.load(sys.stdin); print("errors " + str(d["errors"]).lower() + " · items " + str(len(d["items"])))') · _cat/indices dishes_std -> $(catix 20624 dishes_std)"
  echo "  curl on 20624: _analyze {analyzer dish, \"Vegetarian Lunch Box\"} on dishes_std -> $(eq 20624 POST /dishes_std/_analyze '{"analyzer":"dish","text":"Vegetarian Lunch Box"}' | python3 -I -c 'import json,sys; t=[x["token"] for x in json.load(sys.stdin)["tokens"]]; print(str(len(t)) + " [" + ", ".join(t) + "]")') · on dishes -> $(eq 20624 POST /dishes/_analyze '{"analyzer":"dish","text":"Vegetarian Lunch Box"}' | python3 -I -c 'import json,sys; t=[x["token"] for x in json.load(sys.stdin)["tokens"]]; print(str(len(t)) + " [" + ", ".join(t) + "]")')"
  echo "  curl on 20624: dishes_std match name veg -> $(hits 20624 dishes_std '{"query":{"match":{"name":"veg"}}}')"
  echo "  curl on 20624: dishes_std match name vegetarian -> $(hits 20624 dishes_std '{"query":{"match":{"name":"vegetarian"}}}') · the shipped dishes match name veg -> $(hits 20624 dishes '{"query":{"match":{"name":"veg"}}}')"
  echo "  GET /dishes/search?q=veg (TiffinBox, 20620) -> $(cu 20620 '/dishes/search?q=veg') $(tr -d '\n' < .harness/body)"
  echo "  DELETE /dishes_std -> $(eq 20624 DELETE /dishes_std | ack) · _cat/indices now: $(eq 20624 GET '/_cat/indices?h=index&s=index' | paste -sd' ' -)"
  tbstop run-pg 20620
  pgdrop $CN u23dev; echo "  dropped: u23dev"
  echo "-- the unit's Elasticsearch container's sockets (S8.92), at the end of the replays: /proc/net/tcp, tcp6, udp and udp6 read by cat (dk exec - a file, never a shell)"
  echo "  its interfaces (/proc/net/dev): $(dk exec $EN cat /proc/net/dev | sed 1,2d | cut -d: -f1 | tr -d ' ' | sort | paste -sd',' -)"
  echo "  the sockets: $(sockread $EN)"; }
seven() { local i e a c port=20620
  echo "-- the seven: after/'s jar (= before/'s: one tree, run once - flag 10), java -jar, H2 in memory (a fresh JVM), no Docker, port $port:"
  echo "\$ cd .harness/after && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port"
  i=0; e=0
  (cd .harness/after && DOCKER_HOST=tcp://127.0.0.1:1 exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port) > .harness/seven-run.log 2>&1 < /dev/null & pid=$!
  while [ $i -lt 480 ]; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/seven-run.log | mask >&3; die "TiffinBox exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $port"
  a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
  echo "  GET /actuator/health/readiness -> 200 · GET /actuator/health -> $(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/actuator/health") · GET /dishes/search?q=veg -> $(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/dishes/search?q=veg") · listens on: $a"
  echo "\$ \$CURLSET $port .harness/after/$TF"
  "$CURLSET" $port .harness/after/$TF | $G ' -> ' | awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' > .harness/seven-after.txt || true
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 480 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && die "TiffinBox on $port was still running after POST /shutdown"
  wait "$pid" || e=$?; pid=""
  [ "$(listeners $port)" = 0 ] || die "something still listens on $port"
  echo "  its log: lines naming 9200 $($G -c 9200 .harness/seven-run.log || true) · naming elasticsearch, any case $($G -ci elasticsearch .harness/seven-run.log || true) · naming 27017 $($G -c 27017 .harness/seven-run.log || true)"
  echo "  exit $e · the seven responses: $(wc -l < .harness/seven-after.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven-after.txt) · listening on $port now: 0"
  ! $G -qF -- "$TOKEN" .harness/seven-run.log || die "TiffinBox's log held the token"; }
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p before the stores start"; done
startstores
cap replay replay; chk replay .r-replay.out; pub replay
for c in $HN $EN $MN $RN $CN; do dk rm -fv "$c" > /dev/null 2>&1 || die "the container $c could not be removed"; done
echo "  $HN, $EN, $MN, $RN and $CN removed (rm -fv) · volumes $(vols)"
cap seven seven; chk seven .r-seven.out "$S22"; pub seven
NUM=$(python3 -I -B harness/chk23.py numbers README.md .r-rule.out) || die "S8.95: $(printf '%s\n' "$NUM" | $G '^FAIL' | head -3 | paste -sd';' -)"
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
DR=$(cat README.md table.md exercise/README.md exercise/SOLUTION.md | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
[ "$DC" = 0 ] && [ "$DR" = 0 ] || die "R.432: dur8 finds $DC word(s) in the captures and $DR in README.md, table.md and the exercise - 0 is the rule"
[ -z "$(find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness (R.195)"
echo "  hygiene: dur8 over the captures, README.md, table.md and the exercise 0 words; no path, time, took, @timestamp, time setting, log time, stack frame, H2 database name, raw port, all-interfaces binding, token or password in any capture; every JVM and Maven under its alarm"
# ---- the end: the containers, the volumes, the images, the trees, the ports, the anchor ------------------------------------------
for c in $CN $RN $MN $EN $HN; do [ -z "$(dk ps -aq --filter name=^/$c\$ 2> /dev/null)" ] || die "the container $c is still there"; done
VOL1=$(vols); IMGS1=$(dk images -q --no-trunc 2> /dev/null | sort -u | paste -sd' ' -)
[ "$VOL1" = "$VOL0" ] || die "R.322: the volume count moved, $VOL0 -> $VOL1"
[ "$IMGS1" = "$IMGS0" ] || die "the images moved over this run - nothing may be pulled"
echo "  docker at the end: $CN, $HN, $RN, $MN and $EN gone (rm -fv); volumes $VOL0 -> $VOL1; images $NI0, the same list (nothing pulled)"
pin before-tree before end; pin after-tree after end
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness ../c8-unit22/after ../c8-tiffinbox 2>&1 || true)
[ -z "$AD" ] || die "flag 10: ../c8-tiffinbox moved during the run"
echo "  ../c8-tiffinbox against ../c8-unit22/after at the end: diff -rq empty"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 20620-20629 at the end - the containers bound 20621-20624 and 20626 and are gone; TiffinBox and the harness JVMs bound 20620 and stopped; 20625 was never bound; 20627-20629 spare"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c8-unit23: every capture = published (rule, honest, feature, replay and the seven 3/3 in this run; exercise once per run); every number re-derived by chk23.py; before/ and after/ = unit 22's after-tree; the anchor unchanged; the volume count and the images unchanged"
