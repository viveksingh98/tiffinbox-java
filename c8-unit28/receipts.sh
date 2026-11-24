#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 8 · What's Next: The API Other People Will Use - this unit's receipts, the course's last. No anchor change: anchor is the link
# to ../c8-unit27/after (= ../c8-tiffinbox, Course 8's final anchor and the tree the next course starts from; its tree pinned by
# harness/tree28.py against receipts.md5's anchor-tree line, = ../c8-unit27/receipts.md5's after-tree line). No store, no container of
# this unit's own, ONE TiffinBox JVM per api run (the default run, H2 in memory). This unit's commit is the course's one change to the
# repository's root README.md (contract §5, R.176, R.327) and, in the same commit, pins Course 7's finale's three live readers of it
# (../c7-unit40/receipts.sh's readmecap40 and its part 4's input, ../c7-unit40/harness/chk40.py) to the commit they measured, 70ad921.
# Three captures, each run three times and hashed; a hash that differs from receipts.md5 stops the run; every number the video may say
# is re-derived right after its capture by harness/chk28.py from the capture's own lines and a second witness it reads itself:
#   readme  (1) c7-unit40's readmecap40 AS SHIPPED (cut out of git show e65298c:c7-unit40/receipts.sh) on the README as e65298c had it,
#           in a scratch clone (.harness/wt, git clone --shared): its md5 against the published one; (2) the same function on the README
#           as this commit has it - the md5 moves, the lines that differ printed, and the shipped chk40.py's FAIL lines on it (the
#           failure receipt, labelled); (3) the PINNED readmecap40 (this commit's c7-unit40/receipts.sh) on both READMEs: one md5,
#           = the republished c7-unit40/receipts.md5 line, and the lines it differs from the published capture by; (4) the pinned
#           chk40.py on (3) before and after (exit 0, its output against the shipped chk40.py's on (1)) and on (2) (exit 1, the
#           control); (5) c6-unit32's and c5-unit30's pinned functions inside (3) against their receipts.md5; (6) the README as it
#           is now, read live by this unit (Course 9's finale pins this read: C9-1); the reads of the README counted before and after
#   counts  every number the finale says, read off files: the registry (java8_series.py), the c8-unitNN/after directories, the tests
#           at the course's start and end, the captures per section, the pinned sentences, the contract's last rule, Course 9's
#           registry and the roadmap's lines, Course 7's finale's promise (C8-14), the advisories' grep on the anchor
#   api     the anchor's jar, the default run on 20670 with one exposure flag (mappings, never shipped): the handler methods, the
#           405s with their Allow headers, the two 404s, the callers of the routes; the pinned sentence's facts
# The prose gate harness/s828.py judges README.md and the root README's Course 8 section per sentence. Ports: 20670 TiffinBox;
# 20671-20679 asserted free (nothing else of this unit's binds). Nothing leaves the machine: the build is offline from .m2-demo.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
pid=""; mpid=""; hpid=""; INTR=""
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "tiffinbox-web-1.0.0.jar") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "harness/chk28.py") || index($0, "harness/chk40.py")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
trap 'trap "" INT TERM; for p in "$pid" "$mpid" "$hpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$hpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl git sed awk unzip; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|GIT_DIR|GIT_WORK_TREE|GIT_INDEX_FILE)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
# the files outside the repository this unit reads (the registries, the roadmap, the contract, the briefs, Course 7's finale's script):
# beside the repository, two folders up, as on the author's Mac - TRACK_DIR names that folder when the repository is a clone elsewhere
TRACK="${TRACK_DIR:-$UP/../..}"; REGD="$HOME/Desktop/PromptVidya-Automation"
C8D="$TRACK/spring-data-beyond-jpa"; RM="$TRACK/_briefs/TRACK-ROADMAP.md"; S740="$TRACK/data-jpa-hibernate/scripts-and-decks/40-whats-next-not-everything-is-a-relation.md"
for f in "$REGD/java8_series.py" "$REGD/java9_series.py" "$RM" "$S740" "$C8D/_briefs/STYLE-CONTRACT.md" "$C8D/_briefs/SETUP-BRIEF-2026-11-17.md"; do [ -f "$f" ] || die "a file this unit reads beside the repository is missing: $(printf '%s' "$f" | sed "s#$HOME#~#") - set TRACK_DIR to the folder that holds _briefs/ and spring-data-beyond-jpa/"; done
BASE=e65298c                                         # the commit before this unit's: the README and c7-unit40 as they shipped
PIN7=$(sed -n 's/^PIN7=\([0-9a-f]*\) .*/\1/p' ../c7-unit40/receipts.sh)
[ "$PIN7" = 70ad921 ] || die "../c7-unit40/receipts.sh must set PIN7=70ad921 (the commit Course 7's finale measured) - this commit pins it"
for c in $BASE $PIN7 828e395 0458d2b 06ae5dd; do git -C .. rev-parse --verify -q "$c^{commit}" > /dev/null || die "the repository's history must hold $c: a full clone, not a shallow one"; done

# ---- gates before anything is written: the folder, the link, the pins, the prose ------------------------------------------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md anchor harness pinned.txt receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -) (no exercise: the finales' precedent)"
[ "$(ls harness | paste -sd' ' -)" = 'chk28.py dur8.py s828.py tree28.py' ] || die "harness/ holds another file, or misses one"
cmp -s harness/dur8.py ../c8-unit02/harness/dur8.py || die "harness/dur8.py is not the builders' dur8.py as unit 02 shipped it, byte for byte"
[ -L anchor ] && [ "$(readlink anchor)" = ../c8-unit27/after ] || die "anchor must be the link whose text is ../c8-unit27/after - this unit changes nothing in the anchor (it is: $(readlink anchor 2> /dev/null || echo 'not a link'))"
for t in anchor; do [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] && die "$t holds a secrets/ or a target/ - a frozen tree, never built in place"; true; done
U27P=$(awk '$1 == "after-tree" { print $2, $3 }' ../c8-unit27/receipts.md5)
AP=$(awk '$1 == "anchor-tree" { print $2, $3 }' receipts.md5)
[ -n "$U27P" ] && [ -n "$AP" ] || die "../c8-unit27/receipts.md5's after-tree line or receipts.md5's anchor-tree line is missing"
[ "$AP" = "$U27P" ] || die "R.250: receipts.md5's anchor-tree line ($AP) is not ../c8-unit27/receipts.md5's after-tree line ($U27P)"
anchortree() { local t; t=$(python3 -I harness/tree28.py anchor/) || die "anchor/'s tree could not be hashed"
  [ "$t" = "$AP" ] || die "R.211: anchor/'s tree is $t, the pin is $AP - the tree moved"
  echo "  anchor/ ($1): python3 -I harness/tree28.py anchor/ -> $t = receipts.md5's anchor-tree line = ../c8-unit27/receipts.md5's after-tree line"; }
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c8-tiffinbox 2>&1 || true)
  [ -z "$d" ] || die "../c8-tiffinbox is not anchor/ (diff -rq: $(printf '%s\n' "$d" | head -2 | sed "s#$UP/##g" | paste -sd';' -)) - this unit writes no file of it"
  echo "  anchor/ against ../c8-tiffinbox ($1; diff -rq, .m2-demo target secrets .harness left out): empty"; }
anchortree start; anchornote start
PIN=$(cat pinned.txt)
[ "$(wc -l < pinned.txt | tr -d ' ')" = 1 ] && [ "$(tail -c 1 pinned.txt | od -An -tx1 | tr -d ' ')" = 0a ] && [ "$(tail -c 1 ../c8-unit01/pinned.txt | od -An -tx1 | tr -d ' ')" = 0a ] || die "pinned.txt must hold one line ending in a newline, as ../c8-unit01/pinned.txt does"
PROSE='README.md'
awk '/^## Course 8 — /{ f = 1 } f && /^Videos publish/ { exit } f { print }' ../README.md > .r-c8sec.tmp
[ -s .r-c8sec.tmp ] || die "the root README has no ## Course 8 section"
DW=$(python3 -I -B harness/s828.py harness/dur8.py $PROSE .r-c8sec.tmp 2>&1) || { rm -f .r-c8sec.tmp; die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -2 | paste -sd';' -)"; }
rm -f .r-c8sec.tmp
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S5 12 families · U28 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose or the root README's Course 8 section: $(printf '%s\n' "$DW" | $G ' line ' | sed 's#^ *[^ ]*\.r-c8sec\.tmp#  ../README.md'"'"'s Course 8 section#' | head -4 | paste -sd';' -)"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
DN=$($G -rniwE -- "$DISH" README.md pinned.txt 2> /dev/null | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
PH=$( { $G -nE '\bPENDING\b|PLACEHOLDER|VALUES-PENDING|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md pinned.txt; awk '/^## Course 8 — /{ f = 1 } f && /^Videos publish/ { exit } f' ../README.md | $G -nE '\bPENDING\b|PLACEHOLDER|\bTODO\b|\bTBD\b|\bFIXME\b' | sed 's#^#../README.md (its Course 8 section):#'; } 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or the root README: $PH"
! $G -q '^```java$' README.md || die "README.md holds a java block - the code is the anchor's files"
GLOSS="An API: the routes, methods and bodies a program that is not TiffinBox can call."
[ "$($G -cxF -- "$GLOSS" README.md)" = 1 ] || die "the gloss (SECTION SHAPE 28) must stand in README.md once, as a line of its own, byte for byte"
[ "$($G -cxF -- "$PIN" README.md)" = 1 ] || die "the pinned sentence must stand in README.md once, as a line of its own, byte for byte (pinned.txt)"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
[ "$($G -v '^ *#' receipts.sh | $G -ciE '\bdock''er (run|exec|rm|ps|compose|pull)\b' || true)" = 0 ] || die "receipts.sh calls a container engine - this unit runs none"
ST=$(python3 -I -B harness/chk28.py static 2>&1) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | sed 's/^/  /'
echo "  prose, per sentence (s828, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test, XFAM_S5's 12 families and U28's among them): refused 0 over README.md and the root README's Course 8 section · dish names 0 · placeholders 0 · no java block · the gloss once and the pinned sentence once, byte for byte · no container engine called · no kill by name"
mask() { awk -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  BEGIN { P = lit(u); Q = lit(up); H = lit(hm); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(P, "…"); gsub(Q, "…/.."); gsub(H, "~")
    gsub(/ in [0-9.]+ seconds \(process running for [0-9.]+\)/, " in <t> (process running for <t>)")
    gsub(/[0-9]+ ms/, "<t>")
    gsub(/pid [0-9]+/, "pid <n>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'initialization completed in 812 ms' 'the receipt: pid 41231' "$U/x $HOME/y" | mask)
printf '%s\n' "$MP" | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=sys.stdin.read(); sys.exit(1 if m.DUR.search(t) or "3.1 sec" in t or "812" in t or "41231" in t else 0)' || die "R.432: the mask's self-test - a planted duration or pid passed it unmasked"
[ "$(printf '%s\n' "$MP" | tail -1)" = '…/x ~/y' ] || die "the mask's self-test: the folders and the home must be masked"
echo "  mask: its self-test refused the planted Started-in-seconds, the milliseconds and a pid unmasked (R.432); folders and home masked"
CURLSET=../c5-unit11/curlset.sh
[ -f "$CURLSET" ] || die "$CURLSET is missing - the comparison set the api capture greps"

# ---- ports, the machine, the seed --------------------------------------------------------------------------------------------------
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="20670 20671 20672 20673 20674 20675 20676 20677 20678 20679"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports 20670-20679 must be free"; done
echo "  ports: 20670-20679 free at the start (this unit binds 20670 alone, one JVM at a time)"
rm -rf .harness; mkdir -p .harness/home
M2="$PWD/.m2-demo"
[ -d "$M2" ] || die ".m2-demo (a copy of the course's seed, spring-data-beyond-jpa/_research/m2-seed-c8-s4b) is missing - README.md, The repository"
NF0=$(find "$M2" -type f | wc -l | tr -d ' ')
echo "  .m2-demo's files $NF0 (the seed's 7,265 - this unit adds no dependency)"

# ---- the anchor's jar: copied, built offline -----------------------------------------------------------------------------------
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
rsync -a --exclude target --exclude secrets --exclude .m2-demo anchor/ .harness/after/
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 900; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
bg "cd .harness/after && $MV clean package -DskipTests -pl tiffinbox-web -am" .harness/build.log
[ "$RE" = 0 ] || { tail -20 .harness/build.log | mask >&3; die ".harness/after did not build offline (exit $RE)"; }
[ "$($G -cE '^\[INFO\] Download(ing|ed) from ' .harness/build.log || true)" = 0 ] || die ".harness/build.log: Maven's log says it downloaded (offline: no)"
JAR=.harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar; [ -f "$JAR" ] || die "the build left no jar"
TF=secrets/tiffinbox/shutdown-token
mkdir -p .harness/after/secrets/tiffinbox && (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/after/$TF) || die "the token was not written"
TOKEN=$(head -1 .harness/after/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
[ "$(find "$M2" -type f | wc -l | tr -d ' ')" = "$NF0" ] || die "the build added a file to .m2-demo"
echo "  built the anchor's copy offline (mvn -o -B clean package -DskipTests -pl tiffinbox-web -am, exit 0, 'Downloaded from' 0, .m2-demo's files still $NF0); a shutdown token generated (0600, never printed)"

# ---- helpers -------------------------------------------------------------------------------------------------------------------
unpub=""
cap() { local nm=$1 h p i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid" ] || die "$nm left a process running"
    $G -q '^  \*\*\* ' .harness/cap.raw && { cat .harness/cap.raw >&3; die "$nm stopped (above)"; }
    mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' ".r-$nm.1" || die "$nm holds an absolute path"
  chk "$nm" ".r-$nm.1"
  p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-7s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-7s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-7s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$p"; die "$nm is not the published capture - suspect an edited README, an edited c7-unit40, a moved file, another JDK or Boot; diff .r-$nm.1 against its block in README.md"; fi
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; }
chk() { local nm=$1 e=0; python3 -I -B harness/chk28.py "$@" > .harness/chk-$nm.out 2>&1 & hpid=$!; wait "$hpid" || e=$?; hpid=""
  printf '  chk28 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; die "$nm: its check failed (harness/chk28.py)"; }; }

# ---- readme: the front page, and the three readers of it this commit pins --------------------------------------------------------
WT=.harness/wt
# fns40 FILE: c7-unit40's view() .. the end of readmecap40, cut out of a receipts.sh whole (the S5 probe's u28.sh form)
fns40() { local a b; a=$($G -n '^view() {' "$1" | cut -d: -f1); b=$($G -n '^  rm -rf .harness/unp; }$' "$1" | cut -d: -f1)
  [ -n "$a" ] && [ -n "$b" ] || { echo "  *** the functions could not be cut out of $1 ***"; return 1; }; sed -n "${a},${b}p" "$1"; }
# run40 FUNCS OUT: the cut-out functions run in the scratch clone's c7-unit40, with the variables c7-unit40's script sets for them
run40() { ( cd $WT/c7-unit40 && rm -rf .harness && mkdir -p .harness && U="$PWD" && UP="$(cd .. && pwd)" && G=/usr/bin/grep && C6=../c6-unit32 && C5=../c5-unit30 && PIN6=828e395 && PIN5=0458d2b && WAS=06ae5dd && PIN7=$PIN7 && die() { echo "  *** $* ***"; exit 1; } && eval "$(cat "$1")" && readmecap40 ) > "$2" 2>&1
  rm -rf $WT/c7-unit40/.harness $WT/c6-unit32/.harness $WT/c5-unit30/.harness; }
# k40 CHECKER CAPTURE OUT: a chk40.py run on a capture from the scratch clone's c7-unit40 (its git -C .. and ../ reads are the clone's)
k40() { local e=0; ( cd $WT/c7-unit40 && exec python3 -I -B "$1" readme "$2" ) > "$3" 2>&1 & hpid=$!; wait "$hpid" || e=$?; hpid=""; echo "exit $e" >> "$3"; }
view28() { echo "  line 1: $(sed -n 1p "$1")"
  echo "  the folders its opening maps (lines 1-5): $(sed -n 1,5p "$1" | $G -oE '`(c[0-9]-)?unitNN/`' | tr -d '`' | paste -sd' ' -)"
  echo "  its course sections: $($G -E '^## Course [0-9]+ — ' "$1" | sed 's/^## Course \([0-9]*\) — .*/\1/' | paste -sd' ' -)"
  echo "  its roadmap line: $($G -n '^Videos publish' "$1")"; }
readme() { local f h0 h1 h2 h3 h4 p r
  rm -rf $WT; git clone -q --shared --no-checkout "$UP" $WT 2> /dev/null || { echo "  *** git clone --shared of the repository failed ***"; return 1; }
  git -C $WT checkout -q $BASE -- README.md c7-unit40 c6-unit32 c5-unit30 || { echo "  *** git checkout $BASE of the four paths failed ***"; return 1; }
  git -C .. show $BASE:c7-unit40/receipts.sh > .harness/rs-shipped.sh; fns40 .harness/rs-shipped.sh > .harness/fns-shipped.sh || return 1
  fns40 ../c7-unit40/receipts.sh > .harness/fns-pinned.sh || return 1
  cp $WT/README.md .harness/readme-before.md; cp ../README.md .harness/readme-after.md
  p=$(git -C .. show $BASE:c7-unit40/receipts.md5 | awk '$1 == "readme" { print $2 }'); r=$(awk '$1 == "readme" { print $2 }' ../c7-unit40/receipts.md5)
  echo "the scratch clone: git clone --shared --no-checkout .. .harness/wt; git -C .harness/wt checkout $BASE -- README.md c7-unit40 c6-unit32 c5-unit30"
  echo "  the README before this commit (git show $BASE:README.md): md5 $(md5 -q .harness/readme-before.md) · $(wc -l < .harness/readme-before.md | tr -d ' ') lines"
  echo "  the README this commit leaves (../README.md): md5 $(md5 -q .harness/readme-after.md) · $(wc -l < .harness/readme-after.md | tr -d ' ') lines · git diff --numstat $BASE -- README.md: $(git -C .. diff --numstat $BASE -- README.md | awk '{ print "+" $1 " -" $2 }')"
  echo "  the published readme md5 (git show $BASE:c7-unit40/receipts.md5): $p · the republished (../c7-unit40/receipts.md5): $r"
  echo "  c7-unit40/receipts.md5's other lines, against $BASE's: $(diff <(git -C .. show $BASE:c7-unit40/receipts.md5 | $G -v '^readme ') <($G -v '^readme ' ../c7-unit40/receipts.md5) > /dev/null && echo the same || echo DIFFERENT)"
  echo "the reads of the README, counted:"
  echo "  readmecap40 + its part 4, as shipped: grep -o '../README.md' -> $(sed -n '/^readmecap40() {/,$p' .harness/fns-shipped.sh | $G -o '\.\./README\.md' | wc -l | tr -d ' ') · pinned (this commit): $(sed -n '/^readmecap40() {/,$p' .harness/fns-pinned.sh | $G -o '\.\./README\.md' | wc -l | tr -d ' ') ($(sed -n '/^readmecap40() {/,$p' .harness/fns-pinned.sh | $G '\.\./README\.md' | $G -c 'reads of \.\./README\.md inside its readmecap' || true) of them the label) · git -C .. show \$PIN7:README.md: $(sed -n '/^readmecap40() {/,$p' .harness/fns-pinned.sh | $G -o 'show \$PIN7:README\.md' | wc -l | tr -d ' ')"
  echo "  chk40.py's reads of the README (open(\"../README.md\") and its \"\$ cat ../README.md\" block), as shipped: $(git -C .. show $BASE:c7-unit40/harness/chk40.py | $G -oE 'open\("\.\./README\.md"|block\("\$ cat \.\./README\.md"' | wc -l | tr -d ' ') · pinned: $($G -oE 'open\("\.\./README\.md"|block\("\$ cat \.\./README\.md"' ../c7-unit40/harness/chk40.py | wc -l | tr -d ' ') · its reads of 70ad921: $($G -o '70ad921' ../c7-unit40/harness/chk40.py | wc -l | tr -d ' ')"
  echo "1 · c7-unit40's readmecap40 AS SHIPPED, on the README before this commit:"
  run40 "$U/.harness/fns-shipped.sh" .harness/r1.out; h1=$(md5 -q .harness/r1.out)
  echo "  md5 $h1 · lines $(wc -l < .harness/r1.out | tr -d ' ') · = the published $p: $([ "$h1" = "$p" ] && echo yes || echo no)"
  k40 "$U/.harness/rs-chk40-shipped.py" "$U/.harness/r1.out" .harness/k1.out 2> /dev/null || true
  echo "2 · the same function on the README this commit leaves (the failure receipt, labelled):"
  cp .harness/readme-after.md $WT/README.md
  run40 "$U/.harness/fns-shipped.sh" .harness/r2.out; h2=$(md5 -q .harness/r2.out)
  echo "  md5 $h2 · = the published: $([ "$h2" = "$p" ] && echo yes || echo no) · the lines that differ from (1):"
  diff .harness/r1.out .harness/r2.out | sed 's/^/    /'
  k40 "$U/.harness/rs-chk40-shipped.py" "$U/.harness/r2.out" .harness/k2.out
  echo "  the shipped chk40.py on it: $(tail -1 .harness/k2.out) · its FAIL lines $($G -c '^  FAIL' .harness/k2.out || true):"
  $G '^  FAIL' .harness/k2.out | sed 's/^/  /'
  echo "3 · the PINNED readmecap40 (this commit's c7-unit40/receipts.sh), on the README before and after this commit:"
  cp .harness/readme-before.md $WT/README.md; run40 "$U/.harness/fns-pinned.sh" .harness/r3a.out; h3=$(md5 -q .harness/r3a.out)
  cp .harness/readme-after.md $WT/README.md; run40 "$U/.harness/fns-pinned.sh" .harness/r3b.out; h4=$(md5 -q .harness/r3b.out)
  echo "  before: md5 $h3 · after: md5 $h4 · one md5: $([ "$h3" = "$h4" ] && echo yes || echo no) · = the republished $r: $([ "$h4" = "$r" ] && echo yes || echo no) · = the published: $([ "$h4" = "$p" ] && echo yes || echo no)"
  echo "  the lines it differs from the published capture (1) by:"
  diff .harness/r1.out .harness/r3b.out | sed 's/^/    /'
  echo "4 · the pinned chk40.py (this commit's) on (3) before and after, against the shipped chk40.py on (1); and on (2), the control:"
  cp .harness/readme-before.md $WT/README.md; k40 "$UP/c7-unit40/harness/chk40.py" "$U/.harness/r3a.out" .harness/k3a.out
  cp .harness/readme-after.md $WT/README.md; k40 "$UP/c7-unit40/harness/chk40.py" "$U/.harness/r3b.out" .harness/k3b.out
  k40 "$UP/c7-unit40/harness/chk40.py" "$U/.harness/r2.out" .harness/k4.out
  h0=$(md5 -q .harness/k1.out)
  echo "  the shipped chk40.py on (1), the README before: $(tail -1 .harness/k1.out) · FAIL lines $($G -c '^  FAIL' .harness/k1.out || true) · output md5 $h0"
  echo "  the pinned chk40.py on (3), the README before: $(tail -1 .harness/k3a.out) · FAIL lines $($G -c '^  FAIL' .harness/k3a.out || true) · output md5 $(md5 -q .harness/k3a.out) · = the shipped one's on (1): $(cmp -s .harness/k1.out .harness/k3a.out && echo yes || echo no)"
  echo "  the pinned chk40.py on (3), the README after: $(tail -1 .harness/k3b.out) · FAIL lines $($G -c '^  FAIL' .harness/k3b.out || true) · output md5 $(md5 -q .harness/k3b.out) · = the shipped one's on (1): $(cmp -s .harness/k1.out .harness/k3b.out && echo yes || echo no)"
  echo "  the pinned chk40.py on (2), the README after (the control): $(tail -1 .harness/k4.out) · FAIL lines $($G -c '^  FAIL' .harness/k4.out || true):"
  $G '^  FAIL' .harness/k4.out | sed 's/^/  /'
  echo "5 · the two older finales' pinned functions, inside (3) after, against their receipts.md5:"
  echo "  c6-unit32: $($G 'its readme function, run in its own folder' .harness/r3b.out | sed -n 1p | sed 's/^ *//') · ../c6-unit32/receipts.md5's readme $(awk '$1 == "readme" { print $2 }' ../c6-unit32/receipts.md5)"
  echo "  c5-unit30: $($G 'its readme function, run in its own folder' .harness/r3b.out | sed -n 2p | sed 's/^ *//') · ../c5-unit30/receipts.md5's readme $(awk '$1 == "readme" { print $2 }' ../c5-unit30/receipts.md5)"
  echo "  c7-unit40/README.md's readme block (the lines under its heading): md5 $(awk -v a="\`.r-readme.out\` · md5 " 'index($0, a) == 1 { f = 1; next } f == 1 && /^```$/ { f = 2; next } f == 2 && /^```$/ { exit } f == 2 { print }' ../c7-unit40/README.md | md5 -q) · its heading: $($G -c "^\`.r-readme.out\` · md5 \`$r\` · 3 of 3\$" ../c7-unit40/README.md || true) line naming the republished md5"
  echo "6 · the README as it is now, read live by this unit (Course 9's finale pins this read):"
  echo "\$ cat ../README.md"; view28 ../README.md
  echo "its Course 8 section, whole:"
  awk '/^## Course 8 — /{ f = 1 } f && /^Videos publish/ { exit } f && NF { print "  " $0 }' ../README.md
  rm -rf $WT; }
git -C .. show $BASE:c7-unit40/harness/chk40.py > .harness/rs-chk40-shipped.py
CHH=""; cap readme readme

# ---- counts: every number the finale says, read off files ------------------------------------------------------------------------
reg() { python3 -I -B -c 'import sys; sys.path.insert(0, sys.argv[1]); import java8_series as j8, java9_series as j9; exec(sys.argv[2])' "$REGD" "$@"; }
counts() { local f n s a b t u k l
  echo "the registry: ~/Desktop/PromptVidya-Automation/java8_series.py - len(TITLES), len(SECTIONS), SECTION_OF as bounds, TITLES[28]:"
  reg 'import itertools
print("  java8_series: len(TITLES) %d · len(SECTIONS) %d" % (len(j8.TITLES), len(j8.SECTIONS)))
for k in sorted(j8.SECTIONS): print("  section %d: %s" % (k, j8.SECTIONS[k]))
print("  SECTION_OF as bounds: " + " ".join("%d:%s-%s" % (s, g[0], g[-1]) for s, g in ((s, list(g)) for s, g in itertools.groupby(sorted(j8.SECTION_OF), key=lambda k: j8.SECTION_OF[k]))))
print("  TITLES[28]: %s · SLUGS[28]: %s" % (j8.TITLES["28"], j8.SLUGS["28"]))'
  echo "the anchor changes - the c8-unitNN/after entries that are directories, not links:"
  c="find ../c8-unit[0-9][0-9] -maxdepth 1 -name after -type d | wc -l | tr -d ' '"; echo "\$ $c"; (eval "$c") | sed 's/^/  /'
  echo "  the units: $(find ../c8-unit[0-9][0-9] -maxdepth 1 -name after -type d | sed 's#^\.\./c8-unit\([0-9]*\)/after$#\1#' | sort | paste -sd' ' -)"
  echo "  after/ as a link (not counted): $(find ../c8-unit[0-9][0-9] -maxdepth 1 -name after -type l | sed 's#^\.\./c8-unit\([0-9]*\)/after$#\1#' | sort | paste -sd' ' -) · the unit folders: $(ls -d ../c8-unit[0-9][0-9] | wc -l | tr -d ' ') ($(ls -d ../c8-unit[0-9][0-9] | sed -n '1p;$p' | sed 's#^\.\./##' | paste -sd' ' -))"
  echo "the tests - at the course's start (the tree it started from, Course 7's last anchor) and at its end (its last anchor change):"
  c="grep -o 'surefire-reports [0-9]* ([^)]*) + surefire-reports-it [A-Za-z]* [0-9]* = [0-9]*' ../c7-unit39/README.md"; echo "\$ $c"; (eval "$c" || true) | sed 's/^/  /'
  echo "\$ sed -n 35p ../../spring-data-beyond-jpa/_briefs/SETUP-BRIEF-2026-11-17.md | grep -o 'tests 18 + 3 IT'"; sed -n 35p "$C8D/_briefs/SETUP-BRIEF-2026-11-17.md" | $G -o 'tests 18 + 3 IT' | sed 's/^/  /'
  c="grep -n '^bound: ' ../c8-unit27/README.md | grep -o 'tests [0-9]* + [0-9]*, [0-9]* failures'"; echo "\$ $c"; (eval "$c" || true) | sed 's/^/  /'
  echo "the captures - receipts.md5 lines that are not a tree line, in c8-unit01..27, per section (the registry's SECTION_OF):"
  reg 'import os, re
t = 0; u = 0
for s in sorted(j8.SECTIONS):
    us = sorted(k for k in j8.SECTION_OF if j8.SECTION_OF[k] == s and k != "28"); n = 0; m = 0
    for k in us:
        f = "../c8-unit%s/receipts.md5" % k
        if not os.path.exists(f): continue
        n += sum(1 for l in open(f, encoding="utf-8") if l.split() and not l.split()[0].endswith("-tree")); m += 1
    t += n; u += m; print("  section %d (%s-%s): %d units · %d captures" % (s, us[0], us[-1], m, n))
print("  in all: %d units · %d captures (unit 28 aside: this unit)" % (u, t))'
  echo "the pinned sentences - Course 8's call-backs as their units pinned them:"
  for k in 01 12; do echo "\$ md5 -q ../c8-unit$k/pinned.txt; grep -cF \"\$(cat ../c8-unit$k/pinned.txt)\" ../c8-unit$k/README.md"
    echo "  $(md5 -q ../c8-unit$k/pinned.txt) · lines $(wc -l < ../c8-unit$k/pinned.txt | tr -d ' ') · in its README: $($G -cF -- "$(cat ../c8-unit$k/pinned.txt)" ../c8-unit$k/README.md || true) lines"; done
  echo "\$ printf '%s' \"\$HANDOFF\" | md5   (unit 24's C8-20 sentence: HANDOFF= in ../c8-unit24/receipts.sh, against its README's record)"
  f=$(sed -n "s/^HANDOFF='\(.*\)'$/\1/p" ../c8-unit24/receipts.sh)
  echo "  $(printf '%s' "$f" | md5 -q) · its README's record: $($G -c "printf '%s' \"\$HANDOFF\" | md5 -> $(printf '%s' "$f" | md5 -q)" ../c8-unit24/README.md || true) line · ../c8-tiffinbox/README.md holds it: $($G -cxF -- "$f" ../c8-tiffinbox/README.md || true) line"
  echo "\$ md5 -q pinned.txt   (this unit's, for Course 9's Resources, URIs and the Method Table)"
  echo "  $(md5 -q pinned.txt) · lines $(wc -l < pinned.txt | tr -d ' ')"
  echo "the rules - the contract's Course 8 rules, read on the day:"
  echo "\$ grep -nE '^- \*\*R\.[0-9]+\*\*' ../../spring-data-beyond-jpa/_briefs/STYLE-CONTRACT.md - the first, the last, how many:"
  $G -nE '^- \*\*R\.[0-9]+\*\*' "$C8D/_briefs/STYLE-CONTRACT.md" | sed -E 's/^([0-9]+):- \*\*R\.([0-9]+)\*\*.*/\1 \2/' > .harness/rules.txt
  echo "  first R.$(head -1 .harness/rules.txt | cut -d' ' -f2) (line $(head -1 .harness/rules.txt | cut -d' ' -f1)) · last R.$(sort -k2 -n .harness/rules.txt | tail -1 | cut -d' ' -f2) (line $(sort -k2 -n .harness/rules.txt | tail -1 | cut -d' ' -f1)) · rules $(wc -l < .harness/rules.txt | tr -d ' ') · the numbers consecutive: $(awk 'NR == 1 { p = $2; next } $2 != p + 1 { b = 1 } { p = $2 } END { print (b ? "no" : "yes") }' .harness/rules.txt)"
  echo "the next course - ~/Desktop/PromptVidya-Automation/java9_series.py, and the roadmap (../../_briefs/TRACK-ROADMAP.md), each line read by number AND found by grep:"
  reg 'print("  java9_series: len(TITLES) %d · len(SECTIONS) %d" % (len(j9.TITLES), len(j9.SECTIONS)))
for n in ("01", "02", "03"): print("  TITLES[%s]: %s" % (n, j9.TITLES[n]))'
  for k in '48:**19 courses · ' '366:### COURSE 9 — REST APIs Done Right (' '369:- 01 **What REST Actually Says**' '370:- 02 **Resources, URIs and the Method Table**' '371:- 03 **Status Codes That Mean Something**' '362:- 28 **What'"'"'s Next: The API Other People Will Use**'; do
    n=${k%%:*}; s=${k#*:}; l=$($G -n -F -- "$s" "$RM" | head -1 | cut -d: -f1)
    echo "  :$n grep -n: ${l:-none} · the same: $([ "$l" = "$n" ] && [ "$($G -c -F -- "$s" "$RM")" = 1 ] && echo yes || echo no) · $(sed -n "${n}p" "$RM" | cut -c1-110)"; done
  reg 'import re, sys
rm = open(sys.argv[3], encoding="utf-8").read().split("\n")
got = [re.match(r"- 0\d \*\*(.+?)\*\*", rm[i]).group(1) for i in (368, 369, 370)]
c9 = re.match(r"### COURSE 9 — (.+) \((\d+) units · (\d+) sections\)", rm[365])
print("  the roadmap :369-371 = java9_series TITLES 01-03: " + ("yes" if got == [j9.TITLES[n] for n in ("01", "02", "03")] else "NO: %s" % got))
print("  the roadmap :366 = java9_series: %s · %s units · %s sections · equal: %s" % (c9.group(1), c9.group(2), c9.group(3), "yes" if (int(c9.group(2)), int(c9.group(3))) == (len(j9.TITLES), len(j9.SECTIONS)) else "no"))
print("  the track (:48): " + re.match(r"\*\*(\d+) courses", rm[47]).group(1) + " courses")' "$RM"
  echo "the dev run's handler methods: c8-unit27 captured none - grep -c over its README and its receipts.md5 for a mappings capture:"
  echo "  ../c8-unit27/receipts.md5 lines naming mappings: $($G -ci 'mapping' ../c8-unit27/receipts.md5 || true) · ../c8-unit27/README.md's line on the flag runs: $($G -c '^- \*\*The flag runs, dropped\.\*\*' ../c8-unit27/README.md || true) · not captured in 27, not said"
  echo "C8-14 - what Course 7's finale said (../../data-jpa-hibernate/scripts-and-decks/40-…md :134 and :141), against the registry today:"
  reg 'import re, sys
L = open(sys.argv[3], encoding="utf-8").read().split("\n"); a, b = L[133], L[140]
norm = lambda s: re.sub(r"[:,]", "", re.sub(r"\b([A-Z])-([A-Z])-([A-Z])(?:-([A-Z]))?\b", lambda m: "".join(x for x in m.groups() if x), s)).lower().strip()
said = [("01", "Why Another Data Module"), ("02", "Aggregates, Not Entities"), ("07", "Testing the J-D-B-C Layer"), ("18", "MongoDB, Documents, Not Rows")]
ok = True
for n, t in said:
    found = t in a or t in b; eq = norm(t) == norm(j8.TITLES[n]); ok = ok and found and eq
    print("  said %s (%s) · TITLES[%s]: %s · equal (case, colons, commas and spelt letters aside): %s" % (t, "found" if found else "NOT FOUND", n, j8.TITLES[n], "yes" if eq else "no"))
for k, t in ((3, "Redis as a datastore"), (4, "Document and search")):
    found = t in b; eq = t.lower() == j8.SECTIONS[k].lower(); ok = ok and found and eq
    print("  said section %s (%s) · SECTIONS[%d]: %s · equal (case aside): %s" % (t, "found" if found else "NOT FOUND", k, j8.SECTIONS[k], "yes" if eq else "no"))
m = re.search(r"Course eight of nineteen, Spring Data beyond J-P-A, twenty-eight lessons in five sections", a)
print("  said: Course eight of nineteen, twenty-eight lessons in five sections: %s · the registry %d lessons, %d sections" % ("found" if m else "NOT FOUND", len(j8.TITLES), len(j8.SECTIONS)))
ok = ok and bool(m) and (len(j8.TITLES), len(j8.SECTIONS)) == (28, 5)
print("  C8-14: " + ("every title, section and count the last finale said equals the registry now - nothing to correct" if ok else "a title, a section or a count changed - correct it on camera"))' "$S740"
  echo "the advisories' shape (⚑17) on the anchor: files importing a string annotation from Spring Data MongoDB's or Elasticsearch's repository packages:"
  c="grep -rlE 'org\.springframework\.data\.(mongodb\.repository\.(Query|Aggregation)|elasticsearch\.annotations\.Query)' --include='*.java' anchor/ | wc -l | tr -d ' '"; echo "\$ $c"; (eval "$c") | sed 's/^/  /'
  echo "  the anchor's @Query lines, all JPQL or SQL sums with no parameter: $($G -rhE '@Query\(' --include='*.java' anchor/ | wc -l | tr -d ' ') · with a parameter (:name or ?1): $($G -rhE '@Query\(' --include='*.java' anchor/ | $G -cE ':[a-z]|\?[0-9]' || true)"
  echo "  the jar's module versions (unzip -l, BOOT-INF/lib): $(unzip -l "$JAR" | $G -oE 'spring-data-(mongodb|elasticsearch)-[0-9.]+\.jar' | sort | paste -sd' ' -) · Spring Boot (the anchor's pom.xml parent): $(sed -n '/<parent>/,/<\/parent>/p' anchor/pom.xml | $G -oE '<version>[^<]*' | sed 's/<version>//')"; }
cap counts counts

# ---- api: the routes Course 9 starts from - the default run, one exposure flag ---------------------------------------------------
FLAG="--management.endpoints.web.exposure.include=health,prometheus,mappings"
areq() { local o=$1 l=$2 m=$3 p=$4 c
  c=$(curl -s --noproxy '*' -D "$o/$l.hdr" -o "$o/$l.body" -w '%{http_code}' -X "$m" "http://127.0.0.1:20670$p" 2> /dev/null || true); echo "$c" > "$o/$l.code"; }
api() { local o=.harness/api i=0 c="" e=0
  rm -rf $o; mkdir -p $o
  echo "\$ cd .harness/after && DOCKER_HOST=tcp://127.0.0.1:1 perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20670 $FLAG"
  (cd .harness/after && DOCKER_HOST=tcp://127.0.0.1:1 exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -Duser.home=../home -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20670 $FLAG) > $o/jvm.log 2>&1 < /dev/null & pid=$!
  while [ $i -lt 480 ]; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:20670/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { echo "  *** TiffinBox exited before readiness answered 200 on 20670 ***"; tail -5 $o/jvm.log; pid=""; return 1; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || { echo "  *** readiness never answered 200 on 20670 ***"; killtree "$pid"; wait "$pid" 2> /dev/null; pid=""; return 1; }
  lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' - > $o/listen
  curl -s --noproxy '*' "http://127.0.0.1:20670/actuator/mappings" > $o/mappings.json 2> /dev/null || true
  areq $o patch PATCH /customers; areq $o delete DELETE /customers/Ravi; areq $o apidocs GET /v3/api-docs; areq $o swagger GET /swagger-ui.html
  areq $o actuator GET /actuator
  printf 'X-Shutdown-Token: %s\n' "$TOKEN" | curl -s --noproxy '*' -o $o/shutdown.json -H @- -X POST "http://127.0.0.1:20670/shutdown" 2> /dev/null || true
  wait "$pid" || e=$?; pid=""; echo "$e" > $o/exit
  echo "  readiness 200 · TiffinBox listened on: $(cat $o/listen) · stopped by POST /shutdown: $(cat $o/shutdown.json) · exit $e · listening on 20670 now: $(listeners 20670)"
  ! $G -qF -- "$TOKEN" $o/jvm.log || echo "  *** TiffinBox's log held the token ***"
  python3 -I -B harness/chk28.py show api $o
  echo "the callers of TiffinBox's routes - its pages, its tests, the course's comparison requests:"
  echo "\$ grep -rnoE '@\\{/[a-z/]+\\}' anchor/tiffinbox-web/src/main/resources/templates"
  $G -rnoE '@\{/[a-z/]+\}' anchor/tiffinbox-web/src/main/resources/templates | sed 's#^anchor/tiffinbox-web/src/main/resources/templates/#  #' | sort
  echo "\$ grep -cE '\"/(customers|dashboard|kitchen|revenue|shutdown)' anchor/tiffinbox-web/src/test/java/com/tiffinbox/web/*.java (files with a hit)"
  $G -cE '"/(customers|dashboard|kitchen|revenue|shutdown)' anchor/tiffinbox-web/src/test/java/com/tiffinbox/web/*.java | $G -v ':0$' | sed 's#^anchor/tiffinbox-web/src/test/java/com/tiffinbox/web/#  #'
  echo "\$ grep -nE '^req |\"\\\$B/shutdown\"' ../c5-unit11/curlset.sh   (the seven)"
  $G -nE '^req |"\$B/shutdown"' "$CURLSET" | sed 's/^/  /'
  echo "the pinned sentence (pinned.txt), against this capture:"
  echo "  $(cat pinned.txt)"
  echo "  md5 -q pinned.txt: $(md5 -q pinned.txt)"; }
cap api api

anchortree end; anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: 20670-20679 free at the end"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c8-unit28: every capture 3/3 and = published; every number re-derived by harness/chk28.py; the anchor unchanged"
