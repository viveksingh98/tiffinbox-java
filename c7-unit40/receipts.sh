#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac - only for ../c6-unit32/receipts.sh, which builds and checks it
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · What's Next: Not Everything Is a Relation - this unit's receipts, the course's last. No anchor change: anchor is the link to
# ../c7-unit39/after (= c7-tiffinbox, Course 7's final anchor and the tree the next course starts from; its tree's hash pinned by
# harness/tree40.py, R.211's diff printed at the start and the end). No database, no JVM of TiffinBox's, no container of this unit's own.
# This unit's commit is the course's one change to the repository's root README.md (contract §5, R.176) and, in the same commit, pins
# Course 6's finale's readme capture (../c6-unit32/receipts.sh, its readmecap) to the commit it measured, 828e395 (S6.15). So, first:
#   c6-unit32  Course 6's finale's receipt, re-run from its own folder, whole (its own build into its own .m2-demo, its own ports
#              19610-19612, its own checks): exit 0 and both its captures = its receipts.md5 - the pinned readme republished
# Then two captures, each run three times and hashed; a hash that differs from receipts.md5 stops the run; every number and line the
# video may say is asserted right after its capture by harness/chk40.py, never a typed figure:
#   readme  (1) ../README.md read live - its title, the folders its opening maps, its course sections, its roadmap line - beside the
#           same lines of the README as commit 828e395 (Course 6's finale's) left it, the two compared; its Course 7 section, whole.
#           (2) Course 6's finale's readmecap, PINNED by this commit, re-run from its own folder from its shipped receipts.sh: its reads
#           counted, its md5 against its receipts.md5. (3) Course 5's finale's readmecap the same way (unchanged since b50b410).
#           (4) The failure receipt, labelled: Course 6's readmecap UNPINNED - its receipts.sh as commit 06ae5dd had it, from git - on
#           the README as it is now, then that file's own readme checks on what it printed: the FAIL lines, and its md5
#   counts  every number the finale says, read off files: the c7-unitNN/after folders, the unit folders, the DDL scripts' md5s grouped,
#           the tests from units 36's and 39's READMEs, the pinned sentences, unit 20's API line, the captures per section; then,
#           OUTSIDE the repository and read only when they sit beside it (else a note per file - the capture then differs from the
#           published one, and only there; README.md, "The repository"): the registry (java7_series.py), the roadmap's Course 8 lines,
#           Course 6's finale's script (C7-12), and the 34 scripts' grep (the retirement)
# The prose gate harness/s40.py judges README.md per sentence. This script runs git, sed, awk, grep, md5, wc, readlink, lsof, cmp, diff and
# python3 - and bash, for c6-unit32's receipt. Ports: none of its own; 20190-20199 asserted free at the start and the end, and c6-unit32's
# 19610-19612 and 19619 free before and after its run. Nothing leaves the machine.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; G=/usr/bin/grep
c6pid=""; hpid=""
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
# sweep(): anything of this run still alive in its process group - c6-unit32's TiffinBox JVMs, its Maven build, H2's shell, the check -
# is stopped (c6-unit32's receipt itself is stopped by its pid, with its children, before: its own trap sweeps its own)
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "org.h2.tools.Shell") || index($0, "harness/chk40.py")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
# graceful: c6-unit32's receipt gets up to 30 s after the TERM to run its own trap (its JVMs, its sweep, its .r-lock) before any kill -9
graceful() { local i=0; [ -n "$c6pid" ] || return 0; while kill -0 "$c6pid" 2> /dev/null && [ $i -lt 120 ]; do sleep 0.25; i=$((i + 1)); done; }
trap 'trap "" INT TERM; for p in "$c6pid" "$hpid"; do [ -z "$p" ] || killtree "$p"; done; graceful; for p in "$c6pid" "$hpid"; do if [ -n "$p" ] && kill -9 "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
for t in git sed awk md5 wc readlink lsof cmp diff python3 bash; do command -v $t > /dev/null || die "$t is needed"; done
[ "$($G -ci 'dock''er' receipts.sh || true)" = 0 ] || die "this script names a container engine - it calls none (self-check)"
echo "  self-check: the word for the container engine in this script: 0 times (it calls none)"
C6=../c6-unit32; C5=../c5-unit30
PIN6=828e395                                         # the commit Course 6's finale measured: the README as it left it
PIN5=0458d2b                                         # the commit Course 5's finale's capture is pinned to (c6-unit32's PIN)
WAS=06ae5dd                                          # the commit before this unit's: c6-unit32/receipts.sh unpinned, as it shipped
for c in $PIN6 $PIN5 53379bd $WAS; do git -C .. rev-parse --verify -q "$c^{commit}" > /dev/null || die "the repository's history must hold $c: a full clone, not a shallow one"; done
# ---- the anchor: the link, its tree pinned, the live folder's note (R.211) ---------------------------------------------------
[ -L anchor ] && [ "$(readlink anchor)" = ../c7-unit39/after ] || die "anchor must be the link to ../c7-unit39/after - this unit changes nothing in the anchor"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "the anchor's pom.xml or README.md is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] && die "anchor/ holds a secrets/ or a target/ - it is a frozen tree, never built in place"
T39='47 3978284c6e4594662569f5d37128e8db'            # unit 39's after/ at its commit 06ae5dd: 47 files (harness/tree40.py)
anchortree() { local t; t=$(python3 -I harness/tree40.py anchor/) || die "anchor/'s tree could not be hashed"
  [ "$t" = "$T39" ] || die "R.211: anchor/ (../c7-unit39/after, a shipped unit's frozen tree) is not the tree this unit stands on: $t, pinned $T39"
  echo "  anchor/'s tree ($1): python3 -I harness/tree40.py anchor/ -> $t = pinned (unit 39's after/, Course 7's final anchor)"; }
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox: empty - anchor/ = ../c7-tiffinbox"
  else echo "  note ($1): the live anchor moved on after this unit; this unit stands on c7-unit39/after, pinned - diff -rq anchor/ ../c7-tiffinbox: $(printf '%s\n' "$d" | wc -l | tr -d ' ') lines ($(printf '%s\n' "$d" | head -2 | sed "s#$UP/##g" | paste -sd';' -))"; fi; }
anchortree start; anchornote start
# ---- the files: this unit's, and the two finales' it re-runs -----------------------------------------------------------------
HFILES='chk40.py dur7.py s40.py tree40.py'
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] || die "harness/ holds another file, or misses one ($HFILES)"
[ "$(ls -A | $G -vE '^\.(harness|r-.*|m2-demo)$' | paste -sd' ' -)" = 'README.md anchor harness receipts.md5 receipts.sh' ] || die "this folder holds another file (no xcheck.sql, no exercise: the finale's precedent, c6-unit32)"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
cmp -s harness/tree40.py ../c7-unit33/harness/tree33.py || die "harness/tree40.py is unit 33's tree33.py, byte for byte"
for f in ../README.md README.md receipts.md5 $C6/receipts.sh $C6/receipts.md5 $C6/README.md $C5/receipts.sh $C5/receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="20190 20191 20192 20193 20194 20195 20196 20197 20198 20199"; P6="19610 19611 19612 19619"
for p in $PORTS $P6; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - 20190-20199 and c6-unit32's 19610-19612, 19619 must be free"; done
echo "  ports: 20190-20199 free at the start (this unit binds none) · c6-unit32's 19610 19611 19612 19619 free"
rm -rf .harness; mkdir -p .harness
# ---- the published blocks: README.md's capture blocks = receipts.md5 (the prose gate reads the counts block's numbers) ---------
pubof() { awk -v n="$1" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true; }
rblock() { awk -v a="\`.r-$1.out\` · md5 " 'index($0, a) == 1 { f = 1; next } f == 1 && /^```$/ { f = 2; next } f == 2 && /^```$/ { exit } f == 2 { print }' README.md; }
for n in readme counts; do rblock $n > .harness/block-$n.txt
  p=$(pubof $n); [ -n "$p" ] || { echo "  README.md's $n block: no published hash yet"; continue; }
  [ "$(md5 -q .harness/block-$n.txt)" = "$p" ] || die "README.md's $n block is not the published capture ($(md5 -q .harness/block-$n.txt), receipts.md5 $p)"
  $G -qF "\`.r-$n.out\` · md5 \`$p\` · 3 of 3" README.md || die "README.md's $n block's heading must name its md5 $p"
  echo "  README.md's $n block: md5 $p = receipts.md5's ($(wc -l < .harness/block-$n.txt | tr -d ' ') lines)"; done
# ---- the prose gate -------------------------------------------------------------------------------------------------------------
DW=$(python3 -I -B harness/s40.py harness/dur7.py .harness/block-counts.txt README.md) || die "the prose gate did not run (or its self-test failed)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
echo "  prose, per sentence (s40, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test): dur7 words 0 · S4.7's family 0 · a typed count 0 (every count before its noun is one the counts block prints) · \"Hibernate generates\" outside its two sites 0 · \"nothing to correct\" only beside C7-12's line · a typed md5 0 · refused: 0"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
DN=$($G -rniwE -- "$DISH" README.md harness 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
PH=$($G -nE 'TODO|TBD|PLACEHOLDER|[A-Z]+-OUTPUT\b' README.md 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder line in this unit's prose: $PH"
echo "  dish names: 0 · placeholders: 0"

# ---- c6-unit32: Course 6's finale's receipt, re-run whole from its own folder (the pin's proof, S6.15) --------------------------
echo "  c6-unit32's receipt, re-run from its own folder (its build, its ports 19610-19612, its checks) - a minute:"
( cd $C6 && exec ./receipts.sh ) > .harness/c6run.log 2>&1 < /dev/null & c6pid=$!; e=0; wait "$c6pid" || e=$?; c6pid=""
[ $e = 0 ] || { tail -15 .harness/c6run.log >&3; die "c6-unit32/receipts.sh exited $e - its log: c7-unit40/.harness/c6run.log"; }
for n in memory readme; do p=$(awk -v n=$n '$1 == n { print $2 }' $C6/receipts.md5)
  $G -qE "^  $n +md5 $p  3/3  = published$" .harness/c6run.log || die "c6-unit32: $n is not 3/3 = its published $p"; done
$G -qxF 'c6-unit32: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture and every run'"'"'s log' .harness/c6run.log || die "c6-unit32's last line is missing"
echo "    exit 0 · memory $(awk '$1 == "memory" { print $2 }' $C6/receipts.md5) 3/3 = published · readme $(awk '$1 == "readme" { print $2 }' $C6/receipts.md5) 3/3 = published · its builds: $($G -c '^  built .* offline: yes' .harness/c6run.log) offline: yes, $($G -c '^  built .* offline: no' .harness/c6run.log) offline: no · grep: lines 0: $($G -cE '^(/[^ ]*/)?grep: |^usage: grep' .harness/c6run.log || true)"
for p in $P6; do [ "$(listeners $p)" = 0 ] || die "c6-unit32's run left a listener on $p"; done
echo "    c6-unit32's ports 19610 19611 19612 19619 free after it"

# ---- helpers ----------------------------------------------------------------------------------------------------------------
unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > ".r-$nm.$i" 2>&1 || true; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' ".r-$nm.1" || die "$nm holds an absolute path"
  chk "$nm" ".r-$nm.1" ${CHKARG:-}                   # the checks first: a failed check leaves .r-NAME.1-3 for the diff, .r-NAME.out untouched
  pub=$(pubof "$nm")
  if [ -z "$pub" ]; then printf '  %-8s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-8s md5 %s  3/3  = published\n' "$nm" "$h"
  elif [ "$nm" = counts ] && [ "$OUTSIDE" = absent ]; then printf '  %-8s md5 %s  3/3  differs from the published %s - expected here: the files outside the repository are not beside this clone (README.md, "The repository")\n' "$nm" "$h" "$pub"
  else printf '  %-8s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect an edited README, an edited receipts.sh of c6-unit32 or c5-unit30, a moved file; diff .r-$nm.1 against its block in README.md"; fi
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; }
chk() { python3 -I -B harness/chk40.py "$@" > .harness/chk.out 2>&1 & hpid=$!; e=0; wait "$hpid" || e=$?; hpid=""
  sed 's/^/    /' .harness/chk.out; [ $e = 0 ] || die "harness/chk40.py $1: a check failed (above)"; }

# ---- readme: the front page, and the two finales' captures of it ------------------------------------------------------------------
view() { awk '{ print }' > .harness/view.md
  echo "  line 1: $(sed -n 1p .harness/view.md)"
  echo "  the folders its opening maps (lines 1-5): $(sed -n 1,5p .harness/view.md | $G -oE '`(c[0-9]-)?unitNN/`' | tr -d '`' | paste -sd' ' -)"
  echo "  its course sections: $($G -E '^## Course [0-9]+ — ' .harness/view.md | sed 's/^## Course \([0-9]*\) — .*/\1/' | paste -sd' ' -)"
  echo "  its roadmap line: $($G -n '^Videos publish' .harness/view.md)"; }
# fns FILE: a shipped receipts.sh's view() and readmecap(), cut out of it whole (c6-unit32's own form for c5-unit30's)
fns() { sed -n '/^view() {/,/; }$/p' "$1"; sed -n '/^readmecap() {/,/; }$/p' "$1"; }
# runcap FOLDER FUNCS OUT: the cut-out functions run in FOLDER, with the variables that unit's script sets for them
runcap() { ( cd "$1" && mkdir -p .harness && PIN=$PIN5 C5=../c5-unit30 U="$PWD" && die() { echo "  *** $* ***"; exit 1; } && eval "$(cat "$2")" && readmecap ) > "$3" 2>&1; }
readmecap40() { local c f
  echo "1 · the repository's README as it is now, read live:"
  echo "\$ cat ../README.md"; view < ../README.md
  echo "and as Course 6's finale's commit left it:"
  echo "\$ git -C .. show $PIN6:README.md"; git -C .. show $PIN6:README.md | view
  git -C .. show $PIN6:README.md | $G '^Videos publish' > .harness/road-was.txt; $G '^Videos publish' ../README.md > .harness/road-now.txt
  echo "  the roadmap line, the same in both: $(cmp -s .harness/road-was.txt .harness/road-now.txt && echo yes || echo no)"
  git -C .. show $PIN6:README.md > .harness/readme-$PIN6.md
  echo "  lines the README gained: $(diff .harness/readme-$PIN6.md ../README.md | $G -c '^>' || true) · lines it lost: $(diff .harness/readme-$PIN6.md ../README.md | $G -c '^<' || true)"
  echo "its Course 7 section, whole:"
  awk '/^## Course 7 — /{ f = 1 } f && /^$/ { exit } f { print "  " $0 }' ../README.md
  echo "2 · Course 6's finale's readme function (\$C6), PINNED to $PIN6 by this commit - its reads, and the function re-run from its own folder:"
  c="grep -c 'git -C \.\. show $PIN6:README.md' \$C6/receipts.sh"; echo "\$ $c"; (eval "$c" || true) | sed 's/^/  /'
  c="grep -o 'git -C \.\. show $PIN6:README.md' \$C6/receipts.sh | wc -l | tr -d ' '"; echo "\$ $c"; (eval "$c" || true) | sed 's/^/  /'
  c="sed -n '/^readmecap() {/,/; }\$/p' \$C6/receipts.sh | grep -c '\.\./README\.md'"; echo "\$ $c"; (eval "$c" || true) | sed 's/^/  /'
  fns $C6/receipts.sh > .harness/c6-pinned.sh
  runcap $C6 "$U/.harness/c6-pinned.sh" .harness/c6-pinned.out || echo "  *** its readme function failed: $(tail -2 .harness/c6-pinned.out | paste -sd' ' -) ***"
  f=$(awk '$1 == "readme" { print $2 }' $C6/receipts.md5)
  echo "  its readme function, run in its own folder: $(wc -l < .harness/c6-pinned.out | tr -d ' ') lines · md5 $(md5 -q .harness/c6-pinned.out) · its receipts.md5's readme: $f · the same: $([ "$(md5 -q .harness/c6-pinned.out)" = "$f" ] && echo yes || echo no)"
  echo "  its line under \"and as it is now:\": $($G -A1 -xF 'and as it is now:' .harness/c6-pinned.out | sed -n 2p)"
  echo "  its title line now, as it reads it: $($G -A2 -xF 'and as it is now:' .harness/c6-pinned.out | sed -n 3p | sed 's/^ *//')"
  echo "3 · Course 5's finale's readme function (\$C5), pinned since Course 6's finale - its reads, and the function re-run from its own folder:"
  c="sed -n '/^readmecap() {/,/; }\$/p' \$C5/receipts.sh | grep -c '\.\./README\.md'"; echo "\$ $c"; (eval "$c" || true) | sed 's/^/  /'
  sed -n '/^readmecap() {/,/; }$/p' $C5/receipts.sh > .harness/c5.sh
  runcap $C5 "$U/.harness/c5.sh" .harness/c5.out || echo "  *** its readme function failed: $(tail -2 .harness/c5.out | paste -sd' ' -) ***"
  f=$(awk '$1 == "readme" { print $2 }' $C5/receipts.md5)
  echo "  its readme function, run in its own folder: $(wc -l < .harness/c5.out | tr -d ' ') lines · md5 $(md5 -q .harness/c5.out) · its receipts.md5's readme: $f · the same: $([ "$(md5 -q .harness/c5.out)" = "$f" ] && echo yes || echo no)"
  echo "4 · the failure receipt (labelled): Course 6's finale's readme function UNPINNED - its receipts.sh as commit $WAS had it - on the README as it is now:"
  echo "\$ git -C .. show $WAS:c6-unit32/receipts.sh"
  git -C .. show $WAS:c6-unit32/receipts.sh > .harness/c6-$WAS.sh
  echo "  that file: md5 $(md5 -q .harness/c6-$WAS.sh) · reads of ../README.md inside its readmecap: $(sed -n '/^readmecap() {/,/; }$/p' .harness/c6-$WAS.sh | $G -o '\.\./README\.md' | wc -l | tr -d ' ')"
  fns .harness/c6-$WAS.sh > .harness/c6-unpinned.sh
  runcap $C6 "$U/.harness/c6-unpinned.sh" .harness/c6-unpinned.out || echo "  *** its readme function failed: $(tail -2 .harness/c6-unpinned.out | paste -sd' ' -) ***"
  f=$(git -C .. show $WAS:c6-unit32/receipts.md5 | awk '$1 == "readme" { print $2 }')
  echo "  its readme function, run in its own folder: $(wc -l < .harness/c6-unpinned.out | tr -d ' ') lines · md5 $(md5 -q .harness/c6-unpinned.out) · the readme $WAS's receipts.md5 published: $f · the same: $([ "$(md5 -q .harness/c6-unpinned.out)" = "$f" ] && echo yes || echo no)"
  echo "  its line under \"and as it is now:\": $($G -A1 -xF 'and as it is now:' .harness/c6-unpinned.out | sed -n 2p)"
  # that file's own readme checks (its lines from 'RW=$(blk readme' to its readme-function line), cut out and run on what it printed;
  # each check that would have stopped it prints its FAIL line here instead
  sed -n "/^RW=\$(blk readme /,/^x readme '\^  its readme function/p" .harness/c6-$WAS.sh > .harness/c6-checks.sh
  echo "  its own readme checks ($(wc -l < .harness/c6-checks.sh | tr -d ' ') lines of that file), on what it printed:"
  rm -rf .harness/unp; mkdir -p .harness/unp; cp .harness/c6-unpinned.out .harness/unp/.r-readme.out
  ( cd .harness/unp && PIN=$PIN5 && F=0
    die() { echo "    FAIL $*"; F=$((F + 1)); }
    x() { $G -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
    has() { printf '%s\n' "$1" | $G -qxF -- "$2" || die "$3: expected the line: $2"; }
    blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
    eval "$(cat ../c6-checks.sh)"; echo "    FAIL lines: $F" )
  rm -rf .harness/unp; }

# ---- counts: every number the finale says, read off files ------------------------------------------------------------------------
REG="$HOME/Desktop/PromptVidya-Automation/java7_series.py"; REGD="$(dirname "$REG")"
RM="$UP/../../_briefs/TRACK-ROADMAP.md"
S632="$UP/../../spring-web-mvc/scripts-and-decks/32-whats-next-where-the-data-lives.md"
SCR="$UP/../../data-jpa-hibernate/scripts-and-decks"
OUTSIDE=present; for f in "$REG" "$RM" "$S632"; do [ -f "$f" ] || OUTSIDE=absent; done; [ -d "$SCR" ] || OUTSIDE=absent
# the sections' unit bounds: the registry's SECTION_OF, typed here so a clone without the registry prints the same counts - asserted
# equal to the registry's when it sits beside the repository
BOUNDS='1:01-05 2:06-14 3:15-22 4:23-28 5:29-34 6:35-38 7:39-40'
reg() { python3 -I -B -c 'import sys; sys.path.insert(0, sys.argv[1]); import java7_series as js; exec(sys.argv[2])' "$REGD" "$@"; }
counts40() { local c n u s a b t l k
  echo "the anchor changes - the c7-unitNN/after folders, counted:"
  c="ls -d ../c7-unit*/after | wc -l | tr -d ' '"; echo "\$ $c"; (eval "$c") | sed 's/^/  /'
  echo "  the folders: $(ls -d ../c7-unit*/after | sed 's#^\.\./c7-unit\([0-9]*\)/after$#\1#' | paste -sd' ' -)"
  echo "  before Section 6 (units 01-34): $(ls -d ../c7-unit*/after | sed 's#^\.\./c7-unit\([0-9]*\)/after$#\1#' | awk '$1 + 0 <= 34' | wc -l | tr -d ' ') · in Sections 6 and 7 (35-40): $(ls -d ../c7-unit*/after | sed 's#^\.\./c7-unit\([0-9]*\)/after$#\1#' | awk '$1 + 0 >= 35' | wc -l | tr -d ' ')"
  echo "the course's unit folders:"
  c="ls -d ../c7-unit[0-9][0-9] | wc -l | tr -d ' '"; echo "\$ $c"; (eval "$c") | sed 's/^/  /'
  echo "  first and last: $(ls -d ../c7-unit[0-9][0-9] | sed -n '1p;$p' | sed 's#^\.\./##' | paste -sd' ' -)"
  echo "the DDL script's lineage - Hibernate's script over each anchor's libraries, md5 -q c7-unitNN/xcheck.sql, grouped:"
  c="md5 -q ../c7-unit*/xcheck.sql"; echo "\$ $c"
  for f in ../c7-unit*/xcheck.sql; do printf '%s %s\n' "$(md5 -q "$f")" "$(printf '%s\n' "$f" | sed 's#^\.\./c7-unit\([0-9]*\)/xcheck\.sql$#\1#')"; done > .harness/ddl.txt
  awk '{ if ($1 != h) { if (h != "") print "  " h " units " u; h = $1; u = $2 } else u = u " " $2 } END { if (h != "") print "  " h " units " u }' .harness/ddl.txt
  echo "  files: $(wc -l < .harness/ddl.txt | tr -d ' ') · distinct hashes: $(awk '{ print $1 }' .harness/ddl.txt | sort -u | wc -l | tr -d ' ') · the hash changed between units: $(awk '{ if (h != "" && $1 != h) printf "%s%s->%s", (n++ ? " " : ""), p, $2; h = $1; p = $2 } END { print "" }' .harness/ddl.txt)"
  echo "the tests - the Flyway lesson's published report total, and the capstone's:"
  c="grep -n '^in all: [0-9]* reports · tests ' ../c7-unit36/README.md"; echo "\$ $c"; (eval "$c" || true) | sed 's/^/  /'
  c="grep -o 'surefire-reports [0-9]* ([^)]*) + surefire-reports-it [A-Za-z]* [0-9]* = [0-9]*' ../c7-unit39/README.md"; echo "\$ $c"; (eval "$c" || true) | sed 's/^/  /'
  echo "the pinned sentences - the call-backs later courses make, as their units pinned them:"
  for u in 30 32 33; do c="cat ../c7-unit$u/pinned.txt"; echo "\$ $c"; sed 's/^/  /' ../c7-unit$u/pinned.txt; echo "  lines: $(wc -l < ../c7-unit$u/pinned.txt | tr -d ' ')"; done
  echo "the paging API names the next courses call back (unit 20's README, its ledger line, read by its text):"
  c="grep -n -A1 'The call-backs Course 8 and 9 make, by API name' ../c7-unit20/README.md"; echo "\$ $c"; (eval "$c" || true) | sed 's/^/  /'
  echo "the captures - receipts.md5 lines in c7-unit01..39, per section (the bounds: the registry's SECTION_OF, $BOUNDS):"
  t=0; for k in $BOUNDS; do s=${k%%:*}; a=${k#*:}; b=${a#*-}; a=${a%-*}; n=0; u=0
    for f in ../c7-unit*/receipts.md5; do l=$(printf '%s\n' "$f" | sed 's#^\.\./c7-unit\([0-9]*\)/receipts\.md5$#\1#'); [ "$l" = 40 ] && continue
      if [ $((10#$l)) -ge $((10#$a)) ] && [ $((10#$l)) -le $((10#$b)) ]; then n=$((n + $(wc -l < "$f"))); u=$((u + 1)); fi; done
    t=$((t + n)); echo "  section $s ($a-$b): $u units · $n captures"; done
  echo "  in all: $(ls ../c7-unit*/receipts.md5 | $G -vc 'unit40/' ) units · $t captures"
  echo "OUTSIDE the repository - read when the file sits beside it:"
  if [ "$OUTSIDE" = present ]; then
    echo "\$ python3: java7_series (~/Desktop/PromptVidya-Automation/java7_series.py) - len(TITLES), len(SECTIONS), the sections, TITLES 01-03 and 40"
    reg 'print("  len(TITLES) %d · len(SECTIONS) %d" % (len(js.TITLES), len(js.SECTIONS)))
for k in sorted(js.SECTIONS): print("  section %d: %s" % (k, js.SECTIONS[k]))
for n in ("01", "02", "03", "40"): print("  TITLES[%s]: %s" % (n, js.TITLES[n]))'
    reg 'import itertools, sys
b = " ".join("%d:%s-%s" % (s, g[0], g[-1]) for s, g in ((s, list(g)) for s, g in itertools.groupby(sorted(js.SECTION_OF), key=lambda k: js.SECTION_OF[k])))
print("  SECTION_OF as bounds: " + b + " · the bounds above: " + ("the same" if b == sys.argv[3] else "DIFFERENT"))' "$BOUNDS"
  else echo "  note: the registry (~/Desktop/PromptVidya-Automation/java7_series.py) is not read here - the four files outside the repository are read together, and not all of them sit beside this clone"; fi
  if [ "$OUTSIDE" = present ]; then
    echo "\$ sed -n '<N>p' ../../_briefs/TRACK-ROADMAP.md, and grep -n for the same text - each line read by number AND found, the two equal:"
    for k in '324:### COURSE 8 — Spring Data beyond JPA (' '327:- 01 **Why Another Data Module**' '328:- 02 **Aggregates, Not Entities**' '333:- 07 **Testing the JDBC Layer**' '343:**S3 · Redis as a datastore' '349:**S4 · Document and search' '350:- 18 **MongoDB: Documents, Not Rows**'; do
      n=${k%%:*}; s=${k#*:}; l=$($G -n -F -- "$s" "$RM" | head -1 | cut -d: -f1)
      echo "  :$n grep -n: ${l:-none} · the same: $([ "$l" = "$n" ] && [ "$($G -c -F -- "$s" "$RM")" = 1 ] && echo yes || echo no) · $(sed -n "${n}p" "$RM")"; done
    echo "  Course 8: $(sed -n '324p' "$RM" | sed -n 's/^### COURSE 8 — \(.*\) (\([0-9]*\) units · \([0-9]*\) sections)$/\1 · \2 units · \3 sections/p')"
  else echo "  note: the roadmap (../../_briefs/TRACK-ROADMAP.md) is not read here - its lines are read where the four files sit"; fi
  if [ "$OUTSIDE" = present ]; then
    echo "\$ sed -n '129,132p' ../../spring-web-mvc/scripts-and-decks/32-whats-next-where-the-data-lives.md (C7-12: what Course 6's finale said), against the registry:"
    sed -n '129,132p' "$S632" | sed 's/^/  /'
    reg 'import re, sys
t = open(sys.argv[3], encoding="utf-8").read().split("\n")[128:132]; L = "\n".join(t)
m = re.search(r"(\d+) lessons · (\d+) sections", t[0]); it = re.findall(r"\*([^*]+)\*", t[0].split("its first titles", 1)[1].split("; its section", 1)[0])
sec = re.search(r"its section \*([^*]+)\*", t[0]).group(1); norm = lambda s: s.replace("`", "")
r = [("lessons", int(m.group(1)), len(js.TITLES)), ("sections", int(m.group(2)), len(js.SECTIONS))]
print("  said %s %d · the registry %d · equal: %s" % (r[0][0], r[0][1], r[0][2], "yes" if r[0][1] == r[0][2] else "no"))
print("  said %s %d · the registry %d · equal: %s" % (r[1][0], r[1][1], r[1][2], "yes" if r[1][1] == r[1][2] else "no"))
eq = [norm(a) == js.TITLES[n] for a, n in zip(it, ("01", "02", "03"))]
for a, n, e in zip(it, ("01", "02", "03"), eq): print("  said title %s: %s · the registry: %s · equal (backticks aside): %s" % (n, a, js.TITLES[n], "yes" if e else "no"))
s6 = sec.lower() == js.SECTIONS[6].lower(); print("  said section: %s · the registry section 6: %s · equal (case aside): %s" % (sec, js.SECTIONS[6], "yes" if s6 else "no"))
ok = len(it) == 3 and all(eq) and s6 and all(a == b for _, a, b in r)
print("  C7-12: " + ("every count and title the last finale said equals the registry now - nothing to correct" if ok else "a count or a title changed - correct it on camera"))' "$S632"
  else echo "  note: Course 6's finale's script (../../spring-web-mvc/scripts-and-decks/32-…md) is not read here - C7-12 is compared where the four files sit"; fi
  if [ "$OUTSIDE" = present ]; then
    echo "\$ ls ../../data-jpa-hibernate/scripts-and-decks/[0-9][0-9]-*.md | wc -l; grep -il 'hibernate generat' …/[0-9][0-9]-*.md | wc -l (the retirement):"
    echo "  scripts: $(ls "$SCR"/[0-9][0-9]-*.md | wc -l | tr -d ' ') · scripts holding it: $($G -il 'hibernate generat' "$SCR"/[0-9][0-9]-*.md | wc -l | tr -d ' ')"
  else echo "  note: the course's scripts (../../data-jpa-hibernate/scripts-and-decks/) are not read here - the retirement's grep runs where the four files sit"; fi; }

CHKARG=""; cap readme readmecap40
CHKARG=$OUTSIDE; cap counts counts40

anchortree end; anchornote end
for p in $PORTS $P6; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: 20190-20199 and 19610 19611 19612 19619 free at the end"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit40: c6-unit32 re-run exit 0, both = published; every capture 3/3 and = published$([ "$OUTSIDE" = absent ] && echo ' (counts: the outside files absent here, noted)'); every number asserted by harness/chk40.py; the anchor unchanged"
