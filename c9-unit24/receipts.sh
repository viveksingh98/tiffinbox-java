#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 24 "Retiring an Endpoint Without Breaking Anyone" - this unit's receipts. AN ANCHOR CHANGE, the course's one named
# break: GET /customers/{name} answers 410 Gone (a problem type, route-retired, and a Link to its successor). before is a link whose
# text is ../c9-unit23/after (itself a link to ../c9-unit22/after, U22's frozen tree); after/ is the frozen copy of the changed anchor.
# H2 only on every JVM; no store, no container but the five ITs' Testcontainers during verify (run 1), no browser.
# The scratch copies, labelled on every capture that uses one (R.397, N3): "the timeline's first step" (before + harness/mirror/
# announce.diff, 21135) and "the harness's copy" of the bare removal (before + harness/mirror/remove.diff, 21136 after the gate's JVM).
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5; lines starting "  ~" are run-variant
# and left out of the hash):
#   advisory  the S9.36 read of the evidence's start day (ADVU), verified, before any build; the day rule (USTART, a file)
#   before    the link and its hops, the counters re-derived on before (R.527)
#   census    the controllers on before and after (unit 15's rule)
#   count     the gate: the old route's rows on a fresh before JVM (21136) after a derived request list; the internal-callers grep
#   announce  the timeline's first step (21135, scratch jar): the three headers, the dates in order by epoch, the 200 body
#   remove    the loser, the harness's copy of the bare removal (21136, scratch jar): its 404 and a typo's
#   compat    THE COMPAT GUARD: before (21136) vs after (21130), every request class; the moved lines named; the HOLD rule
#   gone      the 410 on after (21130): status, type, Link, HEAD, the 410 counted, the successor; U12 called back
#   tests     the need-measure (after's handler + before's tests), after's whole build, the handler-removed plant, verify (run 1)
#   spec      the served document = the regenerated committed file; the one moved operation; spec vs wire for the 410
#   client    the generated client built and tested on both specs; CustomersApi.customer printed from each
#   api seven surface moved inert change stale frozen exercise title (see each function)
# Ports (U24's band, 21130-21139, §P: 20900 + 10·23): 21130 after · 21135 the announce copy · 21136 before, then the loser's copy ·
# 21138 the exercise · 21131-21134, 21137, 21139 never bound; 21280-21284 the anchor's five ITs (verify, run 1). Every curl --noproxy '*'.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
C9R=${C9R:-"/Users/$ME/Downloads/Youtube Content/LearnProgrammingWithVivek/rest-apis-done-right"}   # the course's folder (briefs, research)
SEED=${SEED:-"$C9R/_research/m2-seed-c9-s4"}   # the course's Section 4 seed
S4B="$C9R/_briefs/UNIT-BRIEFS-S4-OPERATING.md"
export C9R
RUNNO=${RUNNO:-0}                                     # the run of record's number (1, 2, 3); 0 = development
H22=d7e0663                                           # unit 22's commit: the last that changed the anchor; every "untouched" diff is against it
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): counted, and the ITs' Testcontainers in verify
dk() { docker -H "$DH" "$@"; }
export DOCKER_HOST="$DH"
PIDS=""; INTR=""; mpid=""
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in $mpid $PIDS; do [ -z "$p" ] || killtree "$p"; done; for p in $mpid $PIDS; do if kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; for f in exercise/.servers/*/pid; do [ -f "$f" ] && kill "$(cat "$f")" 2> /dev/null; done; rm -rf exercise/.servers exercise/.work exercise/check.run exercise/check.build.log; [ -z "$INTR" ] || rm -f .r-*.new; rmdir .r-lock 2> /dev/null || rm -rf .r-lock; true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git unzip patch /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|SPRINGDOC_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|AWS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit24 receipts · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · $(curl --version | head -1 | cut -d' ' -f1-2) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }') · run $RUNNO"
echo "  ~ run date $(date '+%Y-%m-%d %H:%M %Z') · uptime: $(uptime | sed 's/^ *//')"

# ---- the day rule (C10, flag 1): USTART is read from a file the first run of the day wrote, never typed here ---------------------------
mkdir -p .harness
[ -s .harness/ustart ] || date +%Y-%m-%d > .harness/ustart
USTART=$(head -1 .harness/ustart)
echo "$USTART" | $G -qE '^20[0-9]{2}-[0-9]{2}-[0-9]{2}$' || die "the start day in .harness/ustart is not a date"
TODAY=$(date +%Y-%m-%d); NEXT=$(date -j -v+1d -f %Y-%m-%d "$USTART" +%Y-%m-%d)
[ "$TODAY" = "$USTART" ] || [ "$TODAY" = "$NEXT" ] || die "the day rule: this run's date $TODAY is neither the evidence's start day $USTART nor the next ($NEXT)"
ADVU="$C9R/_research/docs-$USTART/advisories-u24"
[ -s "$ADVU/fetched-at.txt" ] || die "no advisory read filed for the start day ($ADVU)"
[ "$(head -1 "$ADVU/fetched-at.txt" | cut -c1-10)" = "$USTART" ] || die "the advisory read's day ($(head -1 "$ADVU/fetched-at.txt" | cut -c1-10)) is not the start day $USTART"
echo "  ~ the day rule: USTART $USTART (read off .harness/ustart) · this run $TODAY · allowed $USTART or $NEXT"

# ---- gates before anything is built: the folder, the link, the pins, the anchor note, the static check, the prose, the exercise ----------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk24.py dur9.py mirror norm.py ops9s3.py s924.py scrape.py tree24.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
[ "$(ls harness/mirror | paste -sd' ' -)" = 'announce.diff compat0.diff remove.diff' ] || die "harness/mirror holds another file, or misses one"
NOTUSED="Bind.java Rec.java Limits.java Boom.java Stub.java Caller21.java bind.py rec.py reach.py seal9.py cdp.mjs cdp9.mjs chrome20.py loc9.py walk.py"
for f in $NOTUSED; do [ -z "$(find harness -name "$f")" ] || die "harness/: $f is an instrument this unit does not carry"; done
[ "$(ls exercise | $G -vxE '\.servers|\.work|check\.run|check\.build\.log' | paste -sd' ' -)" = 'README.md SOLUTION.md apply.sh break.sh check.sh' ] || die "exercise/ holds another file, or misses one: $(ls exercise | paste -sd' ' -)"
[ -L before ] && [ "$(readlink before)" = ../c9-unit23/after ] || die "before must be a link whose text is exactly ../c9-unit23/after (C11)"
[ -L ../c9-unit23/after ] && [ "$(readlink ../c9-unit23/after)" = ../c9-unit22/after ] || die "../c9-unit23/after must be a link whose text is ../c9-unit22/after (the second hop)"
[ -d after ] && [ ! -L after ] || die "after must be a folder (the frozen copy of the changed anchor), not a link"
for t in before after; do [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-client/target" ] || [ -e "$t/.m2-demo" ] || [ -e "$t/.harness" ] && die "$t holds a secrets/, a target/, a .m2-demo/ or a .harness/"; true; done
echo "  before -> $(readlink before) -> $(readlink ../c9-unit23/after) (two hops; pwd -P: …/$(cd before && pwd -P | sed 's#.*/##; s#^#c9-unit22/#')) · after/ a folder · no secrets/, target/, .m2-demo/ or .harness/ in either · none of: $NOTUSED"
for f in ops9s3.py norm.py scrape.py dur9.py; do [ "$(md5 -q harness/$f)" = "$(md5 -q ../c9-unit23/harness/$f)" ] || die "harness/$f is not unit 23's copy, byte for byte"; done
[ "$(sed -n '5,$p' harness/tree24.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit23/harness/tree23.py | md5 -q)" ] || die "harness/tree24.py's code is not tree23.py's"
for u in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23; do [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit$u/harness/dur9.py)" ] || die "harness/dur9.py is not ../c9-unit$u's copy"; done
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"
else D9N="(the registry is not on this machine: U01-U23's copies are the pin)"; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit01-23's copies $D9N · tree24.py's code = tree23.py's · ops9s3.py, norm.py, scrape.py = unit 23's"
S23=$(md5 -q ../c9-unit23/harness/s923.py); [ "$S23" = "$(awk '$1 == "file" && $2 == "harness/s923.py" { print $3 }' ../c9-unit23/receipts.md5)" ] || die "U23's s923.py is not its receipts.md5 file line"
[ ! -f "$C9R/_builders/s924.py" ] || cmp -s harness/s924.py "$C9R/_builders/s924.py" || die "harness/s924.py is not _builders/s924.py"
NS=$(diff ../c9-unit23/harness/s923.py harness/s924.py | $G -c '^<' || true)
echo "  s924.py: U23's s923.py ($(echo $S23 | cut -c1-8), = ../c9-unit23/receipts.md5's file line) with XU24C9 added - lines of s923.py's not in s924.py: $NS (the glue lines) · lines added $(diff ../c9-unit23/harness/s923.py harness/s924.py | $G -c '^>') · the diff's md5 $(diff ../c9-unit23/harness/s923.py harness/s924.py | md5 -q)"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit23/receipts.md5)
[ -n "$UA" ] || die "../c9-unit23/receipts.md5 has no after-tree line"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree24.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || { [ -n "${NOPIN:-}" ] && { echo "  $dir/: $got (NOPIN: no $nm line yet)"; return 0; }; die "receipts.md5 has no $nm line"; }
  if [ "$nm" = before-tree ]; then [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit23/receipts.md5's after-tree line ($UA)"; fi
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree24.py $dir/ -> $got = receipts.md5's $nm line$( [ "$nm" = before-tree ] && echo " = ../c9-unit23/receipts.md5's after-tree line")"; }
pin before-tree before; pin after-tree after
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true)
echo "  after/ against the live anchor (the start note): $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ, or the anchor is not beside this folder - this unit pins its own frozen trees' )"
HF="harness/chk24.py harness/s924.py harness/tree24.py harness/dur9.py harness/ops9s3.py harness/norm.py harness/scrape.py harness/mirror/announce.diff harness/mirror/remove.diff harness/mirror/compat0.diff exercise/break.sh exercise/check.sh exercise/apply.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's files: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
ST=$(python3 -I -B harness/chk24.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
STMD5=$(printf '%s\n' "$ST" | md5 -q)
echo "  static (harness/chk24.py static after before; reads before/, after/, this folder and git show $H22:… only - flag 14): $(printf '%s\n' "$ST" | $G -c '^ok ') checks, FAIL 0 · its output md5 $STMD5"
SPT=$(python3 -I -B harness/scrape.py selftest) || die "scrape.py's self-test: $SPT"
echo "  $SPT"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s924.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U19 [0-9]+ families · U20 [0-9]+ families · U21 [0-9]+ families · U22 [0-9]+ families · U23 [0-9]+ families · U24 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s924, per sentence): /'
PH=$($G -rnE 'PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b|<measure>' README.md exercise/README.md exercise/SOLUTION.md | cut -c1-100 | head -2 | paste -sd';' -)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
GL=$(python3 -I -B harness/chk24.py gloss README.md) || die "the gloss: $(printf '%s\n' "$GL" | $G '^FAIL' | head -3 | paste -sd';' -)"
echo "  the gloss: $(printf '%s\n' "$GL" | $G -c '^ok ') checks, FAIL 0 ($(printf '%s\n' "$GL" | $G '^GLOSS ' | sed 's/^GLOSS //'))"
HOOK=$(python3 -I -B harness/chk24.py hook) || die "the hook could not be extracted"; EXQ=$(python3 -I -B harness/chk24.py exq) || die "the exercise line could not be extracted"
IL=$(python3 -I -B harness/chk24.py interleaved) || die "the brief's interleaved hooks and exercises: $IL"
echo "  $IL"
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S4B's Unit 24 Hook line), byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
HW=$(printf '%s\n' "$HOOK" | wc -w | tr -d ' '); EW=$(printf '%s\n' "${EXQ#Your turn: }" | wc -w | tr -d ' ')
[ "$EW" -le 25 ] && [ "$HW" -le 25 ] || die "a spoken line over 25 words (exercise $EW, the hook $HW)"
echo "  the hook ($HW words) and the exercise's line ($EW words after 'Your turn:', $(printf '%s\n' "$EXQ" | wc -w | tr -d ' ') with it), byte for byte; both extracted from S4B's Unit 24"
printf '%s\n\n%s\n' "$HOOK" "$EXQ" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s924.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
SWR=$(printf '%s\n' "$SW" | $G ' line ' | sed 's#.*spoken.md ##' | sort -u | paste -sd';' -)
echo "  the hook and the exercise's line through s924.py: $(printf '%s\n' "$SW" | tail -1 | sed 's/.* refused: /refused /')$( [ -n "$SWR" ] && echo " - $SWR (handed to RED: the hook and the exercise are the brief's, never edited)")"; rm -f .r-lock/spoken.md
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
! $G -qE '(^|[^A-Za-z0-9_.-])path=|[$][{]?path([^A-Za-z0-9_]|$)' exercise/break.sh exercise/check.sh exercise/apply.sh || die "an exercise script names a variable path (zsh): rpath"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh exercise/break.sh exercise/check.sh exercise/apply.sh | $G -qwE "$K1|$K2" || die "a script names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket"
DRL=$($G -v '^ *#' receipts.sh | $G -cE 'dk (run|pull|create|start) ' || true); [ "$DRL" = 0 ] || die "a docker run, pull, create or start line: this unit starts no container of its own"
MVL=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -F '$MV ')
MVA=$(printf '%s\n' "$MVL" | $G -vE -- '-pl tiffinbox-(web|client) -am' | $G -cF -- '-pl ' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh with a -pl form other than '-pl tiffinbox-web -am' or '-pl tiffinbox-client -am'"
MVS=$(printf '%s\n%s\n' "$MVL" "$($G -F 'mvn ' exercise/check.sh)" | $G -cE -- ' -s | --settings ' || true); [ "$MVS" = 0 ] || die "RED4 #27: a Maven line with -s (the central-only settings fail offline)"
GNU=$($G -v '^ *#' receipts.sh exercise/break.sh exercise/check.sh exercise/apply.sh | $G -vF 'GNUFORM' | $G -cE "sed [^|]*[0-9]~[0-9]|sed -i( |$)|sed -i ''" || true)   # GNUFORM: this line and the plant's name the forms
[ "$GNU" = 0 ] || die "R.564: a GNU-only sed form or a bare sed -i ($GNU lines)"   # GNUFORM
HID=$($G -v '^ *#' receipts.sh | $G -E '> "?\$J/[A-Za-z0-9_.-]+\.txt' | $G -cE '\|\| true|2> /dev/null' || true)
[ "$HID" = 0 ] || die "R.564: a capture-writing line hides its failure ($HID lines)"
LA=$($G -nF 'c9-tiffinbox' receipts.sh exercise/break.sh exercise/check.sh exercise/apply.sh harness/tree24.py harness/chk24.py harness/scrape.py harness/norm.py | $G -v ':[0-9]*: *#' | $G -vF 'AD=$(diff -rq' | $G -vF 'AD1=$(diff -rq' | $G -vF 'MDB=$(find' | $G -vF "\$G -nF 'c9-tiffinbox'" | $G -vF 'LIVE_ANCHOR_PLANT' | $G -vF 'GITDIFF' | $G -vF 'ENDCHECK' | wc -l | tr -d ' ')
[ "$LA" = 0 ] || die "flag 14: a line of the receipts, the exercise or the harness reads the live anchor outside the start note, the end check, the git diff and the H2-file sweep"
echo "  static: no kill by name; every docker call on the pinned socket, no container started by this script; R.391's Maven forms only, no -s; R.564: no GNU sed form, no hidden capture step; the live anchor read only by the start note, the end check, the git diff and the H2-file sweep (flag 14)"
mask() { awk -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(PE, "…"); gsub(P, "…"); gsub(QE, "…/.."); gsub(Q, "…/.."); gsub(H, "~")
    gsub(/ in [0-9.]+ seconds \(process running for [0-9.]+\)/, " in <t> (process running for <t>)")
    gsub(/\(execution time [0-9:.]+s\)/, "(execution time <t>)")
    gsub(/Total time: +[0-9.:]+ [a-z]+/, "Total time: <t>")
    gsub(/Time elapsed: [0-9.]+ s/, "Time elapsed: <t>")
    gsub(/\[ *[0-9.:]+ (s|min)\]/, "[<t>]")
    gsub(/[0-9]+ ms/, "<t>")
    gsub(/pid [0-9]+/, "pid <n>")
    gsub(/[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}(:[0-9]{2}(\.[0-9]+)?)?( ?[A-Z]{3,4}|Z|[+-][0-9:]+)?(\[[A-Za-z_\/]+\])?/, "<time>")
    gsub(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/, "<uuid>")
    gsub(/127\.0\.0\.1:21[0-9][0-9][0-9]/, "127.0.0.1:<port>")
    gsub(/\$\$SpringCGLIB\$\$[0-9]+/, "$$SpringCGLIB$$N")
    gsub(/[Dd]eprecation: @[0-9]+/, "Deprecation: @<epoch>")
    gsub(/deprecation=.@[0-9]+./, "deprecation=\047@<epoch>\047")
    gsub(/[Ss]unset: [A-Z][a-z][a-z], [0-9][0-9] [A-Z][a-z][a-z] [0-9][0-9][0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9] GMT/, "Sunset: <date>")
    gsub(/[A-Z][a-z][a-z], [0-9][0-9] [A-Z][a-z][a-z] [0-9][0-9][0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9] GMT/, "<date>")
    gsub(/epoch [0-9]{9,10}/, "epoch <n>")
    gsub(/[Rr]etry-[Aa]fter: [0-9]+/, "Retry-After: <s>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'took 812 ms' '"timestamp":"2026-11-01T08:09:00.123Z"' "$U/x $HOME/y" 'Retry-After: 42' 'Date: Fri, 27 Nov 2026 10:00:00 GMT · key 62cd547a-8da7-4f2c-ac9b-e4db970ce097' 'Deprecation: @1798761600 · Sunset: Thu, 01 Jul 2027 00:00:00 GMT · epoch 1814400000' "deprecation='@1798761600'" | mask)
[ "$(printf '%s\n' "$MP" | paste -sd'|' -)" = 'Started TiffinBoxServer in <t> (process running for <t>)|took <t>|"timestamp":"<time>"|…/x ~/y|Retry-After: <s>|Date: <date> · key <uuid>|Deprecation: @<epoch> · Sunset: <date> · epoch <n>|deprecation='"'"'@<epoch>'"'"'' ] || die "the mask's self-test: $(printf '%s\n' "$MP" | paste -sd'|' -)"
echo "  masks: the log mask masked a Started line's times, a millisecond count, a timestamp, the folders, the home, a Retry-After value, an HTTP date, a uuid, the Deprecation epoch, the Sunset date and a printed epoch (self-test)"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh); [ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SURF=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh); [ ${#U4SURF} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh (SURF=)"
U23V=$(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit23/README.md | $G -E '^(seven|surface): ' | $G -oE '(seven|surface)=[0-9a-f]{8}' | paste -sd' ' -)
[ "$U23V" = "seven=$(echo $S466 | cut -c1-8) surface=$(echo $U4SURF | cut -c1-8)" ] || die "U23's README values block ($U23V) is not the seven and the surface read off the receipts"
echo "  the seven: expected $S466 (../c7-unit31/receipts.sh's S466= line) · the old surface on before: expected $U4SURF (../c9-unit04/receipts.sh's SURF= line) · both = U23's values block ($U23V)"

# ---- docker (counted only), ports, the guard: the baselines ---------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' '); CT0=$(dk ps -a --format '{{.Names}}' 2> /dev/null | sort | paste -sd, -)
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
BAND="21130 21131 21132 21133 21134 21135 21136 21137 21138 21139"
NEVER="21131 21132 21133 21134 21137 21139 21110 21111 21112 21113 21114 21115 21116 21117 21118 21119 21120 21121 21122 21123 21124 21125 21126 21127 21128 21129"
ITP="21280 21281 21282 21283 21284"
PORTS="18425 18881 18882 18883 18884 20578 20615 $BAND $NEVER $ITP"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
for p in $BAND $ITP; do [ -z "$(lsof -nP -iUDP:$p 2> /dev/null)" ] || die "UDP $p is bound"; done
guard() { local r; r=$(pgrep -fl "^/bin/(ba)?sh (\./|.*/)(receipts|runrec)[.]sh" 2> /dev/null | $G -v "^$$ " || true)
  [ -z "$(pgrep -fl "^/opt/homebrew/bin/bash (\./|.*/)?receipts[.]sh" 2> /dev/null | $G -v "^$$ " || true)" ] || r="$r a bash 5 receipt"
  local l1; l1=$(sysctl -n vm.loadavg | awk '{ print $2 }')
  [ -z "$r" ] || die "S9.17: another receipt runs ($r) before $1 - this run stops; wait for it, never kill it"
  local w=0; while ! awk -v l="$l1" 'BEGIN { exit !(l < 20) }'; do
    [ -n "${GUARD0:-}" ] || die "R.480: load1 $l1 is not below 20 at the launch"
    w=$((w + 1)); [ $w -lt 900 ] || die "R.480: load1 stayed at or above 20 before $1"; sleep 1; l1=$(sysctl -n vm.loadavg | awk '{ print $2 }'); done
  GUARD0=1
  for p in $BAND; do if echo " ${MINE:-} " | $G -qF " $p "; then continue; fi; [ "$(listeners $p)" = 0 ] || die "guard before $1: something listens on $p that this run did not start"; done
  echo "  guard before $1: no other receipt · load1 below 20$( [ $w = 0 ] || echo " after $w checks at or above 20 (waited, never killed)") · the band free" >&3; }
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · containers [$CT0] · no Testcontainers container · ports free (21131-21134, 21137, 21139, 21110-21129 and 21280-21284 included)"
ANCP=""; ANX=":(exclude)c9-tiffinbox"; [ -d ../c9-tiffinbox ] && { ANCP=c9-tiffinbox; ANX=""; }   # GITDIFF: run 3 moves the clone's anchor aside; then the pathspec leaves it out
GD0=$(git -C "$UP" diff --stat $H22 -- c9-unit01 c9-unit02 c9-unit03 c9-unit04 c9-unit05 c9-unit06 c9-unit07 c9-unit08 c9-unit09 c9-unit10 c9-unit11 c9-unit12 c9-unit13 c9-unit14 c9-unit15 c9-unit16 c9-unit17 c9-unit18 c9-unit19 c9-unit20 c9-unit21 c9-unit22 '*pom.xml' $ANX | wc -l | tr -d ' ')   # GITDIFF
GD23=$(git -C "$UP" diff --stat HEAD -- c9-unit23 | wc -l | tr -d ' ')   # GITDIFF
[ "$GD0" = 0 ] && [ "$GD23" = 0 ] || die "git diff --stat $H22 over c9-unit01..22 and every pom ($GD0 lines), or HEAD over c9-unit23 ($GD23 lines), is not empty"
echo "  git diff --stat $H22 -- c9-unit01..22 '*pom.xml': empty · git diff --stat HEAD -- c9-unit23: empty (the start; ${ANCP:-the anchor moved aside})"

# ---- the trees copied and built offline: before WITH its tests, after WITH its tests, the scratch jars ------------------------------------
M2="$PWD/.m2-demo"
if [ ! -d "$M2" ]; then [ -d "$SEED" ] || die "the seed $SEED is missing"; cp -cR "$SEED" "$M2" 2> /dev/null || cp -R "$SEED" "$M2" || die "the seed could not be copied"; fi
NF0=$(find "$M2" -type f | wc -l | tr -d ' '); NB0=$(find "$M2" -type f -print0 | xargs -0 stat -f %z | awk '{ s += $1 } END { printf "%d", s }')
CO=$(find "$M2" -name _remote.repositories -print0 | xargs -0 $G -l 'central-only' | wc -l | tr -d ' ')
[ "$CO" = 0 ] || die "$CO _remote.repositories files in the seed copy still name central-only"
echo "  .m2-demo (a copy of the seed m2-seed-c9-s4): files $NF0 · bytes $NB0 · _remote.repositories naming central-only: $CO"
for d in before after need plantx ann rem cspec tests run work hc static-copy; do rm -rf .harness/$d; done
mkdir -p .harness/home .harness/run .harness/work
printf '%s\n' 'checks.disable=true' > .harness/home/.testcontainers.properties
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
JL=(-Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8)
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE 'Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" HOME=\"$U/.harness/home\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 900; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
AL="-DargLine=-Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Duser.home=../../home"
WEB=tiffinbox-web/src/main/java/com/tiffinbox/web
SPEC=tiffinbox-web/src/test/resources/openapi/tiffinbox.json
SRV=$WEB/TiffinBoxServer.java
extract() { bg "cd .harness/$1 && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$1.log
  [ "$RE" = 0 ] || die ".harness/$1: the jar's extract failed"; }
copy before .harness/before; copy after .harness/after
guard "the build of before"
bg "cd .harness/before && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package" .harness/build-before.log
[ "$RE" = 0 ] || { tail -30 .harness/build-before.log | mask >&3; die ".harness/before did not build offline (exit $RE)"; }; offl .harness/build-before.log; extract before
guard "the build of after"
bg "cd .harness/after && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package" .harness/build-after.log
[ "$RE" = 0 ] || { tail -30 .harness/build-after.log | mask >&3; die ".harness/after did not build offline (exit $RE)"; }; offl .harness/build-after.log; extract after
echo "  built before and after offline WITH their tests, Docker-free (mvn -o clean package, the whole reactor, exit 0 each, Downloading/Downloaded from: 0) - the JVMs run these builds' jars"
for s in ann rem; do copy before .harness/$s; if [ $s = ann ]; then df=harness/mirror/announce.diff; else df=harness/mirror/remove.diff; fi
  patch -s -p1 -d .harness/$s < $df || die "$df did not apply to a copy of before"
  guard "the scratch build $s"
  bg "cd .harness/$s && DOCKER_HOST=unix:///nonexistent/docker.sock $MV -DskipTests clean package -pl tiffinbox-web -am" .harness/build-$s.log
  [ "$RE" = 0 ] || { tail -20 .harness/build-$s.log | mask >&3; die "the scratch copy $s did not build"; }; offl .harness/build-$s.log; extract $s; done
echo "  the scratch jars: before + harness/mirror/announce.diff (the timeline's first step) and before + harness/mirror/remove.diff (the harness's copy of the bare removal), -DskipTests clean package -pl tiffinbox-web -am, exit 0 each"
B() { echo "http://127.0.0.1:$1"; }
J=.harness/work
ALP='%m %U%q %s %b'
CAP5=--tiffinbox.rate-limit.capacity=5   # the harness's short capacity (the cap5 starts only, label cap=5)
# tb LABEL PORT TREE [args]: TiffinBox from TREE's extracted jar (before, after, ann, rem), from its own run folder with a generated token
# (0600, never printed), H2 in memory (fresh per JVM); waited for by its Started line; Tomcat's access log on.
tb() { local label=$1 port=$2 tree=$3 run=.harness/run/$1 i=0; shift 3
  guard "TiffinBox $label"
  for q in $NEVER; do [ "$(listeners $q)" = 0 ] || die "$q must stay free (TCP)"; done
  [ "$(listeners $port)" = 0 ] && [ -z "$(lsof -nP -iUDP:$port 2> /dev/null)" ] || die "$port is bound before $label"
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  local x="$U/.harness/$tree/$XD"
  local ax=(--server.tomcat.accesslog.enabled=true "--server.tomcat.accesslog.directory=$U/$run" --server.tomcat.accesslog.prefix=access --server.tomcat.accesslog.suffix=.log --server.tomcat.accesslog.rotate=false --server.tomcat.accesslog.buffered=false "--server.tomcat.accesslog.pattern=$ALP")
  local main=com.tiffinbox.web.TiffinBoxServer
  echo "java -cp <$tree's jar> $main --tiffinbox.port=$port <the access log> $*" > "$run/cmd"
  (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java "${JL[@]}" -cp "$x/tiffinbox-web-1.0.0.jar:$x/lib/*" $main --tiffinbox.port="$port" "${ax[@]}" "$@" > jvm.log 2>&1) &
  local p=$!; echo $p > "$run/pid"; PIDS="$PIDS $p"; MINE="${MINE:-} $port"
  while ! $G -q -E 'Started TiffinBox(App|Server) in' "$run/jvm.log" 2> /dev/null; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before its Started line"; }; i=$((i + 1)); [ $i -lt 1200 ] || die "$label: no Started line"; sleep 0.1; done
  local lab="harness-free"; if [ "$tree" = ann ]; then lab="the timeline's first step (a scratch jar)"; elif [ "$tree" = rem ]; then lab="the harness's copy of the bare removal (a scratch jar)"; fi
  echo "  $label up on $port (H2, $tree's jar, $lab, the access log on) · $($G -oE 'rate limit: capacity [0-9]+ per refill period [A-Za-z0-9]+' "$run/jvm.log" | head -1)"; }
tbstop() { local label=$1 port=$2 run=.harness/run/$1 p i=0 how="POST /shutdown"; p=$(cat "$run/pid")
  if kill -0 "$p" 2> /dev/null; then printf 'X-Shutdown-Token: %s\n' "$(head -1 "$run/secrets/tiffinbox/shutdown-token")" | $CURL -s -o /dev/null --max-time 5 -H @- -X POST "$(B $port)/shutdown" || true; fi
  while kill -0 "$p" 2> /dev/null; do i=$((i + 1)); [ $i = 80 ] && { kill "$p" 2> /dev/null; how="its recorded pid (SIGTERM)"; }; [ $i -lt 400 ] || { kill -9 "$p" 2> /dev/null; break; }; sleep 0.05; done
  wait "$p" 2> /dev/null || true; PIDS=$(echo " $PIDS " | sed "s/ $p / /g"); MINE=$(echo " ${MINE:-} " | sed "s/ $port / /g")
  [ "$(listeners $port)" = 0 ] || die "$label: something still listens on $port"
  echo "  budget | $label: requests under /api/v1/ (its access log): $(cat $run/access*.log | $G -cE '^[A-Z]+ /api/v1/' || true) · refusal lines: $($G -c 'rate limit: refused' $run/jvm.log || true) · $($G -oE 'rate limit: capacity [0-9]+' $run/jvm.log | head -1)"
  [ -z "${QUIET:-}" ] && echo "  $label stopped by $how"; true; }
NCAPS=0; unpub=""; VALS=""
must() { local f; for f in "$@"; do test -s "$f" || die "R.564: $f is empty or missing"; done; }
cap() { local nm=$1; shift
  if [ -n "${DEVCAPS:-}" ] && ! echo " $DEVCAPS " | $G -qF " $nm "; then return 0; fi   # development only: a run of record sets no DEVCAPS
  "$@" > .harness/cap-$nm.raw 2>&1 || true
  $G -q '^  \*\*\* ' .harness/cap-$nm.raw && { cat .harness/cap-$nm.raw >&3; die "$nm stopped (above)"; }
  mask < .harness/cap-$nm.raw > .r-$nm.new
  sed 's/^/  | /' .r-$nm.new | cut -c1-260
  local o e=0; o=$(python3 -I -B harness/chk24.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk24 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  if [ $e != 0 ] && $G -q '^FAIL HOLD' .harness/chk-$nm.out; then $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; die "THE HOLD RULE: a moved line outside the retired route's own requests - no anchor write; captures to C9/_held/"; fi
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; [ -n "${DEVCAPS:-}${NOPIN:-}" ] && { echo "  (development: $nm's check failed, the run goes on)"; unpub="$unpub $nm"; } || die "$nm: its check failed (harness/chk24.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk24.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-12s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-12s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-12s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff .r-$nm.new against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }
surefire() { python3 -I - "$1" "$2" <<'PY'
import sys, glob, xml.etree.ElementTree as E
t = [0, 0, 0, 0]
fs = glob.glob(sys.argv[1] + "/TEST-*.xml")
if not fs: print("  %s | REFUSED: no Surefire XML in %s" % (sys.argv[2], sys.argv[1])); sys.exit(1)
for f in fs:
    r = E.parse(f).getroot()
    for i, k in enumerate(("tests", "failures", "errors", "skipped")):
        t[i] += int(r.get(k) or 0)
print("  %s | tests %d failures %d errors %d skipped %d" % ((sys.argv[2],) + tuple(t)))
for f in sorted(fs):
    r = E.parse(f).getroot()
    print("  %s | class %s | tests %s failures %s errors %s skipped %s" % (sys.argv[2], r.get("name").split(".")[-1], r.get("tests"), r.get("failures"), r.get("errors"), r.get("skipped")))
PY
}
redlist() { python3 -I - "$1" "$2" <<'PY'
import sys, glob, xml.etree.ElementTree as E
red = []
for f in glob.glob(sys.argv[1] + "/TEST-*.xml"):
    r = E.parse(f).getroot()
    for tc in r.iter("testcase"):
        if tc.find("failure") is not None or tc.find("error") is not None: red.append("%s.%s" % (r.get("name").split(".")[-1], tc.get("name")))
classes = sorted(set(x.split(".")[0] for x in red))
print("  %s | red %d in %d classes" % (sys.argv[2], len(red), len(classes)))
for x in sorted(red): print("  %s | red %s" % (sys.argv[2], x))
PY
}
reactor() { $G -E '^\[INFO\] TiffinBox[A-Za-z ]* \.+ (SUCCESS|FAILURE|SKIPPED)' "$1" | sed -E 's/ \.+ / ... /; s/\[ *[0-9.:]+ (s|min)\]//; s/^\[INFO\] /  reactor: /; s/ *$//'; }
# send LABEL PORT FILE: the requests of FILE (one per line: METHOD PATH [accept=X]), each with its status, Content-Type, header names,
# the headers this unit reads (Link, Deprecation, Sunset, Allow, ETag) by bytes, its body's md5 and its problem members; also $J/sent-LABEL.txt
send() { python3 -I - "$2" "$3" "$J/sent-$1.txt" "$J/bodies-$1" <<'PY'
import sys, json, re, hashlib, http.client, os
port, f, sent, bd = int(sys.argv[1]), sys.argv[2], sys.argv[3], sys.argv[4]
os.makedirs(bd, exist_ok=True)
with open(sent, "a") as S:
    for n, l in enumerate(x for x in open(f).read().splitlines() if x.strip() and not x.startswith("#")):
        p = l.split(); m, u, opts = p[0], p[1], p[2:]
        h = {}
        for o in opts:
            if o.startswith("accept="): h["Accept"] = o[7:]
        c = http.client.HTTPConnection("127.0.0.1", port, timeout=10); c.request(m, u, headers=h); r = c.getresponse(); b = r.read() if m != "HEAD" else b""
        hh = [(k.lower(), v) for k, v in r.getheaders()]; hd = dict(hh); c.close()
        open(os.path.join(bd, "r%02d.b" % (n + 1)), "wb").write(b)
        try:
            j = json.loads(b.decode("utf-8")) if b else {}
        except ValueError:
            j = {}
        if not isinstance(j, dict): j = {}
        names = ",".join(sorted(set(k for k, _ in hh if k not in ("date", "keep-alive", "connection"))))
        fr = "chunked" if hd.get("transfer-encoding", "").lower() == "chunked" else ("length" if "content-length" in hd else "none")
        rd = " · ".join("%s=%r" % (k, v) for k, v in hh if k in ("link", "deprecation", "sunset", "allow", "etag"))
        esc = lambda v: v.encode("unicode_escape").decode("ascii") if isinstance(v, str) else v
        j = {k: esc(v) for k, v in j.items()}
        S.write("%s %s %d\n" % (m, u, r.status))
        print("  req | %02d %s %s%s -> %d %s · headers {%s} · %s · framing %s · %d B md5 %s · type %s · title %s · instance %s · detail %s" % (n + 1, m, u, (" Accept=" + h["Accept"]) if "Accept" in h else "", r.status, hd.get("content-type", "none"), names, rd or "-", fr, len(b), hashlib.md5(b).hexdigest()[:12], j.get("type", "-"), j.get("title", "-"), j.get("instance", "-"), j.get("detail", "-")))
PY
}
scrapeto() { local port=$2 out=$3 a=$J/sc-$1-a.txt b=$J/sc-$1-b.txt i=0 st
  st=$($CURL --http1.1 -s -o $a -w '%{http_code}' "$(B $port)/actuator/prometheus")
  while :; do sleep 0.5; $CURL --http1.1 -s -o $b "$(B $port)/actuator/prometheus"
    if [ "$(python3 -I harness/scrape.py rows $a | $G -v ' /actuator/' | md5 -q)" = "$(python3 -I harness/scrape.py rows $b | $G -v ' /actuator/' | md5 -q)" ]; then break; fi
    i=$((i + 1)); [ $i -lt 20 ] || die "the scrape of $1 did not settle"; cp $b $a; done
  cp $a $out; must $out
  echo "  scrape $1 | GET /actuator/prometheus -> $st · read until two reads half a second apart agreed on the rows outside /actuator/ ($((i + 2)) reads); only _count rows are read here, no _sum, _max or bucket value"; }
oldrows() { python3 -I harness/scrape.py rows "$1" | $G -E ' /customers/\{name\} | /api/v1/customers/\{name\} | /\*\* ' | sed -E 's/ error=[^ ]+ exception=[^ ]+ count=/ count=/; s/ keys=.*//' | sed "s/^/  $2 | /"; }
alog() { awk '{ print $1, $2, $3 }' .harness/run/$1/access*.log | sort | uniq -c | awk -v l="$1" '{ printf "  access %s | %s %s %s ×%d\n", l, $2, $3, $4, $1 }'; }
census() { python3 -I - "$1/tiffinbox-web/src/main/java/com/tiffinbox/web" "$2" <<'PY'
import os, re, sys
d, side = sys.argv[1], sys.argv[2]
rows = []
for f in sorted(os.listdir(d)):
    ls = open(os.path.join(d, f), encoding="utf-8").read().splitlines()
    for i, l in enumerate(ls):
        m = re.match(r"^(public )?(final )?(abstract )?class (\w+)", l)
        if not m: continue
        ann, j = [], i - 1
        while j >= 0 and ls[j].strip().startswith("@"):
            ann.append(ls[j].strip()); j -= 1
        names = {re.match(r"@(\w+)", a).group(1) for a in ann}
        if names & {"RestController", "Controller"}: rows.append((m.group(4), bool(m.group(2)), '@Profile("dev")' in ann))
        break
if not rows: print("  census %s | REFUSED: no controller found (an empty input)" % side); sys.exit(1)
fd = sum(1 for r in rows if r[1] and not r[2]); nd = sum(1 for r in rows if not r[1] and r[2]); nf = sum(1 for r in rows if not r[1] and not r[2])
print("  census %s | controllers %d · final, default-run %d · not final, default-run %d · not final, dev-only %d · names %s" % (side, len(rows), fd, nf, nd, " ".join(sorted(r[0] for r in rows))))
PY
}

# ---- the captures ----------------------------------------------------------------------------------------------------------------------
c_advisory() {
  echo "== S9.36: the read of the evidence's start day (ADVU = _research/docs-$USTART/advisories-u24, the evidence agent's first act, delegated by the orchestrator), before any capture"
  echo "  fetched-at $(head -1 "$ADVU/fetched-at.txt" | cut -c1-10) (the hour masked) · USTART $USTART (.harness/ustart) · read day = start day: $( [ "$(head -1 "$ADVU/fetched-at.txt" | cut -c1-10)" = "$USTART" ] && echo yes || echo NO)"
  echo "  ~ run date $TODAY (the day rule: a run of record on $USTART or the next day; a later day stops)"
  local n=0 v=0 f h; while read -r h f; do n=$((n + 1)); [ "$(md5 -q "$ADVU/$f")" = "$h" ] && v=$((v + 1)); done < <($G -vE '^\s*$' "$ADVU/MD5SUMS.txt" | awk '$2 != "MD5SUMS.txt" { print $1, $2 }')
  echo "  advisories-u24/MD5SUMS.txt: $n lines, $v verified (its own line left out)"
  echo "  tomcat page md5 $(md5 -q "$ADVU/tomcat-security-11.html") (the 11-24, 11-26 and 11-27 reads: a1a756d985225fb5143eefd9aae3183c)"
  python3 -I - "$ADVU/spring-security-index.html" "$C9R/_research/docs-2026-11-27/advisories-s4probe/spring-security-index.html" <<'PY'
import re, sys
f = lambda p: list(dict.fromkeys(re.findall(r"CVE-\d{4}-\d+", open(p, encoding="utf-8", errors="replace").read())))
a, b = f(sys.argv[1]), f(sys.argv[2])
d = re.findall(r"((?:January|February|March|April|May|June|July|August|September|October|November|December) \d{1,2}, 20\d\d)", open(sys.argv[1], encoding="utf-8", errors="replace").read())
print("  spring.io/security | %d ids on the first page · its dates: %s · against the 2026-11-27 S4-probe read: new %d, gone %d" % (len(a), ", ".join(sorted(set(d))), len([x for x in a if x not in b]), len([x for x in b if x not in a])))
PY
  local a; for a in spring-boot spring-web spring-webmvc tomcat-embed-core jackson-databind micrometer-core springdoc-openapi-starter-webmvc-api swagger-core opentelemetry-api; do
    echo "  shipped | $a $(ls "$XB/lib" | $G -E "^$a-[0-9]" | sed -E "s/^$a-//; s/\.jar$//" | paste -sd, -)"; done
  echo "  shipped | the client's generator: openapi-generator-maven-plugin $(sed -n 's#.*<openapi-generator.version>\(.*\)</openapi-generator.version>.*#\1#p' before/pom.xml)"
  python3 -I - "$ADVU/osv-query.json" "$ADVU/osv-result.json" <<'PY'
import json, sys
q = json.load(open(sys.argv[1]))["queries"]; r = json.load(open(sys.argv[2])).get("results", [])
hit = [(x["package"]["name"], x["version"], [v["id"] for v in y["vulns"]]) for x, y in zip(q, r) if y.get("vulns")]
print("  osv (second witness only): %d coordinates queried, %d results, %d with vulns: %s" % (len(q), len(r), len(hit), "; ".join("%s %s %s" % (a, b, ",".join(c)) for a, b, c in hit) or "none"))
PY
  local nref; nref=$(cd "$XB/lib" && for j in *.jar; do [ "$j" = opentelemetry-api-1.62.0.jar ] && continue; unzip -p "$j" '*.class' 2> /dev/null | $G -a -c 'W3CTraceContextPropagator' || true; done | awk '{ s += $1 } END { print s + 0 }')
  echo "  reach | jars other than opentelemetry-api whose classes name W3CTraceContextPropagator (the method the advisory names): $nref of $(($(ls "$XB/lib" | wc -l) - 1))"
  local r; for r in rfc8594 rfc9745 rfc8288 rfc5829; do echo "  rfc | $r.txt $(wc -c < "$ADVU/$r.txt" | tr -d ' ') B md5 $(md5 -q "$ADVU/$r.txt") · its title line: $(sed -n '1,30p' "$ADVU/$r.txt" | $G -E '^ +[A-Z][A-Za-z ():-]+$' | $G -vE 'Abstract|Status|Copyright|Category|ISSN|Request|Internet|Obsoletes|Updates' | head -1 | sed 's/^ *//')"; done
  echo "  rfc | the IANA link-relations registry: the successor-version row $($G -c '^successor-version,' "$ADVU/iana-link-relations.csv") (names $(sed -n 's/^successor-version,[^,]*,\([^,]*\),.*/\1/p' "$ADVU/iana-link-relations.csv" | tr -d '"[]' | head -1))"
  echo "  the unit adds no artifact: BOOT-INF/lib names $(ls "$XB/lib" | wc -l | tr -d ' ') on before = $(ls "$XA/lib" | wc -l | tr -d ' ') on after"
  echo "  verdict (VERDICT.txt's Verdict line, read): $($G '^Verdict:' "$ADVU/VERDICT.txt" | cut -c1-90)"; }
c_before() {
  echo "== before (a link: ../c9-unit23/after -> ../c9-unit22/after): the counters re-derived on it (R.527), each beside U23's value"
  echo "  before | readlink before: $(readlink before) · readlink ../c9-unit23/after: $(readlink ../c9-unit23/after) · the tree $(python3 -I harness/tree24.py before/)"
  echo "  before | BOOT-INF/lib names $(ls "$XB/lib" | wc -l | tr -d ' ') · modules $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' before/pom.xml | paste -sd' ' -)"
  echo "  before | the committed spec: $(python3 -I harness/ops9s3.py ops before/$SPEC | tail -1) · $(wc -c < before/$SPEC | tr -d ' ') B md5 $(md5 -q before/$SPEC)"
  census before before
  for p in web client; do surefire .harness/before/tiffinbox-$p/target/surefire-reports "before | tiffinbox-$p" | head -1; done
  echo "  before | the IT classes (*IT.java, by source, every module): $(find before/ -name '*IT.java' | wc -l | tr -d ' ') ($(find before/ -name '*IT.java' | sed 's#.*/##; s#\.java$##' | sort | paste -sd' ' -))"
  echo "  before | U23's values block (read, the expectation): $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit23/README.md | $G -oE '(web|client)=[0-9]+|lib=[0-9]+|spec=[0-9]+|census=[0-9/]+|old=[0-9]+' | paste -sd' ' -)"; }
c_census() { echo "== census: the controllers on before and after (unit 15's rule) - a handler body adds no controller"
  census before before; census after after
  mkdir -p $J/empty/tiffinbox-web/src/main/java/com/tiffinbox/web
  echo "  census plant | the counter on an empty source folder: $(census $J/empty plant > /dev/null 2>&1; echo "exit $?") (1 = REFUSED)"; }
c_count() {
  echo "== count: the gate - the old route's rows on a fresh before JVM (21136, harness-free, H2), after a derived request list (D9: a count of what this receipt sent)"
  printf 'GET /customers/Ravi\nGET /customers/Ravi\nGET /customers/Ravi\nGET /customers/Nobody\nGET /api/v1/customers/Ravi\nGET /api/v1/customers/Ravi\n' > $J/count.txt
  echo "  the list (method path · expected): $(awk '{ print $1, $2 }' $J/count.txt | paste -sd';' -) · expected 200 ×3, 404 ×1 under /customers/{name}, 200 ×2 under /api/v1/customers/{name}"
  tb count 21136 before
  send count 21136 $J/count.txt
  scrapeto count 21136 $J/scrape-count.raw
  oldrows $J/scrape-count.raw count
  alog count
  python3 -I harness/scrape.py rows $J/scrape-count.raw > $J/count-rows.txt; must $J/count-rows.txt
  echo "  count | _sum, _max or bucket lines printed by this capture: 0 (the reader prints _count rows only)"
  QUIET=1 tbstop count 21136
  echo "  count | U23's value (its values block, read): $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit23/README.md | $G -oE 'old=[0-9]+' | head -1) - a count of one request of its own run"
  echo "  callers | git grep -n '/customers/' over before's tiffinbox-*/src/main (the specs left out), each hit classified:"
  local gr=0; (cd before && $G -rn '/customers/' tiffinbox-core/src/main tiffinbox-web/src/main | $G -v 'openapi') > $J/callers.txt || gr=$?; [ $gr -le 1 ] || die "the callers grep could not run (exit $gr)"
  must $J/callers.txt
  python3 -I - $J/callers.txt <<'PY'
import re, sys, collections
k = collections.Counter(); calls = []
for l in open(sys.argv[1]).read().splitlines():
    f, n, t = l.split(":", 2)
    s = t.strip()
    if re.search(r'@(Get|Post|Put|Patch|Delete|Request)Mapping\(', s): c = "a route mapping"
    elif re.search(r'@ApiResponse|@ExampleObject|examples = ', s): c = "a documentation annotation (an example's instance)"
    elif s.startswith(("*", "/**", "//")): c = "a comment or Javadoc sentence"
    elif "/api/v1/customers/" in s: c = "a link under /api/v1/ (the successor)"
    elif "/customers/new" in s or "/customers/feed" in s or "/customers/import" in s: c = "another mapping (new, feed or import)"
    else: c = "a CALL of the old route"; calls.append("%s:%s" % (f, n))
    k[c] += 1
for c in sorted(k): print("  callers | %s: %d" % (c, k[c]))
print("  callers | calls of GET /customers/{name} inside src/main: %d%s" % (len(calls), (" - " + ", ".join(calls)) if calls else ""))
PY
  echo "  callers | the tests that call it are the need-measure's red list (the tests capture)"; }
c_announce() {
  echo "== announce: the timeline's first step (21135, a scratch jar: before + harness/mirror/announce.diff, md5 $(md5 -q harness/mirror/announce.diff | cut -c1-12)) - never said of the shipped tree"
  sed -n '/^+/p' harness/mirror/announce.diff | $G -v '^+++' | sed 's/^/  diff | /'
  tb announce 21135 ann
  printf 'GET /customers/Ravi\nGET /api/v1/customers/Ravi\nGET /customers/Nobody\n' > $J/announce.txt
  send announce 21135 $J/announce.txt
  $CURL --http1.1 -s -D $J/ann.h -o $J/ann.b "$(B 21135)/customers/Ravi"; must $J/ann.h
  echo "GET /customers/Ravi 200" >> $J/sent-announce.txt
  echo "  the timeline's first step | the answer's headers (read back): $(tr -d '\r' < $J/ann.h | $G -iE '^(HTTP/|content-type|deprecation|sunset|link):' | paste -sd' ' -)"
  echo "  the timeline's first step | body = the successor's body on the same JVM, byte for byte: $(cmp -s $J/bodies-announce/r01.b $J/bodies-announce/r02.b && echo yes || echo NO) ($(wc -c < $J/bodies-announce/r01.b | tr -d ' ') B)"
  python3 -I - $J/ann.h <<'PY'
import re, sys, calendar, email.utils
h = {}
for l in open(sys.argv[1]).read().replace("\r", "").splitlines():
    if ":" in l: k, v = l.split(":", 1); h[k.strip().lower()] = v.strip()
dep = h.get("deprecation", ""); sun = h.get("sunset", "")
m = re.fullmatch(r"@(\d+)", dep)
de = int(m.group(1)) if m else None
st = email.utils.parsedate_tz(sun) if sun else None
se = calendar.timegm(st[:9]) - (st[9] or 0) if st else None
print("  dates | Deprecation as epoch (python, off the @ form): epoch %s · Sunset as epoch (python calendar.timegm of the HTTP date): epoch %s · Deprecation before Sunset: %s" % (de, se, "ok" if de is not None and se is not None and de < se else "NO"))
PY
  scrapeto announce 21135 $J/scrape-announce.raw
  oldrows $J/scrape-announce.raw announce
  QUIET=1 tbstop announce 21135; }
c_remove() {
  echo "== remove: the loser - the harness's copy of the bare removal (21136, a scratch jar: before + harness/mirror/remove.diff, md5 $(md5 -q harness/mirror/remove.diff | cut -c1-12)) - never said of the shipped tree"
  tb remove 21136 rem
  printf 'GET /customers/Ravi\nGET /customers/typo-xyz\nGET /api/v1/customers/Ravi\n' > $J/remove.txt
  send remove 21136 $J/remove.txt
  python3 -I - $J/bodies-remove <<'PY'
import json, sys, os
a = json.load(open(os.path.join(sys.argv[1], "r01.b"))); b = json.load(open(os.path.join(sys.argv[1], "r02.b")))
na = {k: (v.replace("Ravi", "<name>") if isinstance(v, str) else v) for k, v in a.items()}
nb = {k: (v.replace("typo-xyz", "<name>") if isinstance(v, str) else v) for k, v in b.items()}
print("  the harness's copy | Ravi's 404 and a typo's 404 differ only in the name: %s · the detail of each: %r / %r · type %s" % ("yes" if na == nb else "NO", a.get("detail"), b.get("detail"), a.get("type", "absent (about:blank)")))
PY
  scrapeto remove 21136 $J/scrape-remove.raw
  oldrows $J/scrape-remove.raw remove
  QUIET=1 tbstop remove 21136; }
REACH=$J/reach.txt
printf '%s\n' 'GET /customers/Ravi' 'GET /customers/Nobody' 'HEAD /customers/Ravi' 'OPTIONS /customers/Ravi' 'PUT /customers/Ravi' 'DELETE /customers/Ravi' 'POST /customers/Ravi' \
  'GET /customers/new accept=application/json' 'GET /customers/new accept=text/html' 'GET /customers/Meera%20Joshi' 'GET /customers/a%3Eb' 'GET /customers/x%0D%0Ay' 'GET /api/v1/customers/Ravi' 'GET /api/v1/customers/Meera%20Joshi' > .harness/reach-list.txt
compatside() { local side=$1 port=$2
  tb seven-$side $port $side > /dev/null
  sh $CURLSET $port .harness/run/seven-$side/secrets/tiffinbox/shutdown-token > $J/seven-$side.txt 2>&1
  must $J/seven-$side.txt
  local i=0; while kill -0 "$(cat .harness/run/seven-$side/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 60 ] || break; sleep 0.05; done
  QUIET=1 tbstop seven-$side $port > $J/budget-seven-$side.txt
  tb compat-$side $port $side > /dev/null
  oldsurface2 $port $J/surface-$side.txt; must $J/surface-$side.txt
  apicensus $port $J/api-$side.txt
  send reach-$side $port .harness/reach-list.txt > $J/reach-$side.txt; must $J/reach-$side.txt
  QUIET=1 tbstop compat-$side $port > $J/budget-compat-$side.txt
  tb cap5-$side $port $side "$CAP5" > /dev/null
  printf 'GET /api/v1/customers/Ravi\n%.0s' 1 2 3 4 5 6 > $J/cap5.txt; printf 'GET /customers/Ravi\n' >> $J/cap5.txt
  send cap5-$side $port $J/cap5.txt > $J/cap5-$side.txt; must $J/cap5-$side.txt
  QUIET=1 tbstop cap5-$side $port > $J/budget-cap5-$side.txt; }
apicensus() { python3 -I - "$1" before/$SPEC > "$2" <<'PY'
import sys, json, re, hashlib, http.client
port, spec = sys.argv[1], sys.argv[2]
d = json.load(open(spec))
fill = {"name": "Ravi", "id": "1"}
urls = []
for p, v in sorted(d["paths"].items()):
    if not p.startswith("/api/v1/") or "get" not in v: continue
    u = re.sub(r"\{(\w+)\}", lambda m: fill.get(m.group(1), "1"), p)
    if p == "/api/v1/billing-runs/{id}": u = "/api/v1/billing-runs/00000000-0000-0000-0000-000000000000"
    if p.endswith("/bill/signed"): u += "?expires=1&sig=x"
    urls.append(u)
urls += ["/api/v1/customers/Nobody", "/api/v1/customers?nosuch=1"]
def mask(b):
    s = b.decode("utf-8", "replace")
    s = re.sub(r'"timestamp":"[^"]*"', '"timestamp":"<masked>"', s); s = re.sub(r'"next":"[^"]*"', '"next":"<cursor>"', s)
    s = re.sub(r"(127\.0\.0\.1|localhost):\d{4,5}", r"\1:<port>", s); s = re.sub(r"expires=\d+", "expires=<masked>", s); s = re.sub(r"sig=[A-Za-z0-9_-]+", "sig=<masked>", s)
    return s
for u in urls:
    c = http.client.HTTPConnection("127.0.0.1", int(port), timeout=10); c.request("GET", u); r = c.getresponse(); b = r.read(); st = r.status
    h = {k.lower(): v for k, v in r.getheaders()}; c.close()
    et = h.get("etag"); et = "none" if et is None else (et if re.fullmatch(r'"v\d+"', et) else "<shallow tag>")
    hs = ",".join(sorted(k for k in h if k not in ("date", "keep-alive", "connection", "content-length", "transfer-encoding")))
    print("  api | GET %s -> %s %s · headers {%s} · etag %s · body %s" % (u, st, h.get("content-type"), hs, et, hashlib.md5(mask(b).encode()).hexdigest()[:12]))
PY
must "$2"; }
eval "$(sed -n '/^oldsurface2() {/,/^  rm -f "\$t".\*; }$/p' ../c9-unit21/receipts.sh)"
type oldsurface2 > /dev/null 2>&1 || die "oldsurface2 could not be read off ../c9-unit21/receipts.sh"
compatrun() { compatside before 21136; compatside after 21130; }
c_compat() {
  echo "== compat: THE COMPAT GUARD - every request class sent to before (21136) and to after (21130), harness-free, H2, one JVM at a time; the moved lines named (S9.2, R.553; the HOLD rule)"
  echo "  the reader of the old surface: U18's, sourced off ../c9-unit21/receipts.sh byte for byte (md5 $(sed -n '/^oldsurface2() {/,/^  rm -f "\$t".\*; }$/p' ../c9-unit21/receipts.sh | md5 -q | cut -c1-12))"
  echo "  (i) the seven (curlset.sh) - not a witness for the retirement: it sends no /customers/{name} read ($($G -c '/customers/' $CURLSET || true) lines of curlset.sh name /customers/)"
  echo "  seven | before $(md5 -q $J/seven-before.txt) · after $(md5 -q $J/seven-after.txt) · expected $S466"
  echo "  (ii) the old surface - the witness: each request's block, before -> after"
  python3 -I - $J/surface-before.txt $J/surface-after.txt <<'PY'
import sys, re
def blocks(f):
    out, cur = [], None
    for l in open(f, encoding="utf-8").read().splitlines():
        if l.startswith("== "):
            cur = [l]; out.append(cur)
        elif cur is not None: cur.append(l)
    return out
a, b = blocks(sys.argv[1]), blocks(sys.argv[2])
if len(a) != len(b): print("  surface | REFUSED: %d blocks before, %d after" % (len(a), len(b))); sys.exit(0)
for x, y in zip(a, b):
    lab = re.sub(r" -> .*", "", x[0][3:])
    st = lambda bl: re.search(r" -> (\d{3}) ", bl[0]).group(1)
    print("  surface | %-48s %s -> %s · %s" % (lab, st(x), st(y), "unmoved" if x == y else "MOVED"))
PY
  echo "  surface | before $(md5 -q $J/surface-before.txt) (expected $U4SURF) · after $(md5 -q $J/surface-after.txt)"
  echo "  (iii) the /api/v1/ census (every GET of the committed spec's /api/v1/ paths): before -> after $(cmp -s $J/api-before.txt $J/api-after.txt && echo identical || echo DIFFER) ($(wc -l < $J/api-before.txt | tr -d ' ') requests each)"
  echo "  (iv) the reach of the retired route, each request on both trees:"
  python3 -I - $J/reach-before.txt $J/reach-after.txt <<'PY'
import sys, re
a = open(sys.argv[1]).read().splitlines(); b = open(sys.argv[2]).read().splitlines()
for x, y in zip(a, b):
    rq = re.match(r"^  req \| \d+ (\S+ \S+(?: Accept=\S+)?) -> ", x).group(1)
    sx = re.sub(r"^  req \| \d+ ", "", x); sy = re.sub(r"^  req \| \d+ ", "", y)
    m = "unmoved" if sx == sy else "MOVED"
    print("  reach | %s" % rq)
    print("  reach |   before: %s" % sx.split(" -> ", 1)[1])
    print("  reach |   after:  %s" % sy.split(" -> ", 1)[1])
    print("  reach |   %s" % m)
PY
  echo "  (v) the other layers (cap=5: the harness's short capacity, a run flag): six /api/v1/ reads, then the old route"
  sed 's/^  req |/  cap5 before |/' $J/cap5-before.txt; sed 's/^  req |/  cap5 after |/' $J/cap5-after.txt
  cat $J/budget-*-before.txt $J/budget-*-after.txt
  echo "  layers | the 410 carries an ETag (U20's filter is /api/v1/ only): $($G -F ' 01 GET /customers/Ravi -> 410 ' $J/reach-after.txt | $G -c 'etag=' || true)"; }
c_gone() {
  echo "== gone: the shipped tree's answer - after/ on 21130, harness-free, H2"
  tb gone 21130 after
  printf 'GET /customers/Ravi\nHEAD /customers/Ravi\nGET /customers/Nobody\nGET /customers/Meera%%20Joshi\nGET /api/v1/customers/Ravi\nGET /customers/Ravi\nGET /customers/Ravi\n' > $J/gone.txt
  send gone 21130 $J/gone.txt
  $CURL --http1.1 -s -D $J/gone.h -o $J/gone.b "$(B 21130)/customers/Ravi"; must $J/gone.h; echo "GET /customers/Ravi 410" >> $J/sent-gone.txt
  echo "  gone | the answer's status line and headers read back: $(tr -d '\r' < $J/gone.h | $G -iE '^(HTTP/|content-type|link|deprecation|sunset):' | paste -sd' ' -)"
  echo "  gone | the body: $(cat $J/gone.b)"
  python3 -I - $J/gone.h $J/gone.b "$U/after/$WEB/TiffinBoxErrors.java" <<'PY'
import sys, json, re
h = {}
for l in open(sys.argv[1]).read().replace("\r", "").splitlines():
    if ":" in l: k, v = l.split(":", 1); h[k.strip().lower()] = v.strip()
b = json.load(open(sys.argv[2]))
c = re.search(r'ROUTE_RETIRED = URI\.create\("([^"]+)"\)', open(sys.argv[3]).read()).group(1)
print("  gone | members %s · type = the constant ROUTE_RETIRED (read off after's TiffinBoxErrors.java): %s · status member %s" % (",".join(sorted(b)), "yes" if b.get("type") == c else "NO", b.get("status")))
print("  gone | Deprecation present: %s · Sunset present: %s (C1 (a): the 410 names no date; the announce copy's carry both)" % ("yes" if "deprecation" in h else "no", "yes" if "sunset" in h else "no"))
PY
  $CURL --http1.1 -s -o $J/served.json "$(B 21130)/v3/api-docs"; must $J/served.json
  scrapeto gone 21130 $J/scrape-gone.raw
  oldrows $J/scrape-gone.raw gone
  alog gone
  QUIET=1 tbstop gone 21130
  echo "  gone | the same requests' counterparts on before: the compat capture's reach rows (GET /customers/Ravi 200, /customers/Nobody 404)"
  echo "  U12, on its own tree (../c9-unit12/README.md, frozen, read): a retired VERSION -"
  $G -nE "Invalid API version|rel=\\\\?\"deprecation|rel=.deprecation" ../c9-unit12/README.md | head -3 | cut -c1-220 | sed 's/^/  U12 | /'; }
c_tests() {
  echo "== tests (0) the need-measure: after's main sources + before's tests, unedited (.harness/need), mvn -o clean package, failures recorded, Docker-free"
  copy after .harness/need; rm -rf .harness/need/tiffinbox-web/src/test .harness/need/tiffinbox-client/src/test; cp -R before/tiffinbox-web/src/test .harness/need/tiffinbox-web/src/test; cp -R before/tiffinbox-client/src/test .harness/need/tiffinbox-client/src/test
  guard "the need-measure"
  bg "cd .harness/need && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" -Dmaven.test.failure.ignore=true clean package" .harness/need.log; local nre=$RE; offl .harness/need.log
  echo "  need | mvn exit $nre"
  surefire .harness/need/tiffinbox-web/target/surefire-reports "need | tiffinbox-web" | head -1
  redlist .harness/need/tiffinbox-web/target/surefire-reports "need"
  echo "  need | the brief's number: 6 tests in 5 classes - the probe's, on c5406fc (U18's tree), never this tree's"
  echo "== tests (a) after's own build (mvn -o clean package, the whole reactor, its tests on, Docker-free - the twin of verify without Docker)"
  reactor .harness/build-after.log
  for p in web client; do surefire .harness/after/tiffinbox-$p/target/surefire-reports "package | tiffinbox-$p"; done
  echo "  refusal lines of the limiter in the build log, outside RateLimitFilterTest (its own context refuses by design): $(awk '/\[INFO\] Running com\./ { c = $NF } /rate limit: refused/ && c !~ /RateLimitFilterTest/ { n++ } END { print n + 0 }' .harness/build-after.log)"
  echo "  the test methods edited, before -> after (python over both trees' test sources, by method body):"
  python3 -I - before after <<'PY'
import os, re, sys
def methods(root):
    out = {}
    base = os.path.join(root, "tiffinbox-web/src/test/java/com/tiffinbox/web")
    for f in sorted(os.listdir(base)):
        if not f.endswith(".java"): continue
        s = open(os.path.join(base, f), encoding="utf-8").read(); cls = f[:-5]
        for m in re.finditer(r"\n    @Test\n(?:    @[^\n]*\n)*    void (\w+)\(\)[^{]*\{(.*?)\n    \}\n", s, re.S):
            out["%s.%s" % (cls, m.group(1))] = m.group(2)
    return out
a, b = methods(sys.argv[1]), methods(sys.argv[2])
for k in sorted(set(a) & set(b)):
    if a[k] != b[k]: print("  edited | %s" % k)
for k in sorted(set(b) - set(a)): print("  added  | %s" % k)
for k in sorted(set(a) - set(b)): print("  gone   | %s" % k)
print("  edited | test methods before %d, after %d" % (len(a), len(b)))
PY
  echo "  test files moved before -> after: $(for p in $(cd before && find tiffinbox-web/src/test tiffinbox-client/src/test -type f | sort); do cmp -s before/$p after/$p || basename $p; done | paste -sd, -) · new: $(cd after && for p in $(find tiffinbox-web/src/test tiffinbox-client/src/test -type f | sort); do [ -e ../before/$p ] || basename $p; done | paste -sd, -)"
  local T=tiffinbox-web/src/test/java/com/tiffinbox/web/RetiredRouteTest.java nps
  nps=$(sed -E 's/"[^"]*"/""/g' after/$T | $G -cE 'RANDOM_PORT|DEFINED_PORT|LocalServerPort|Socket|Thread\.sleep|[^0-9.A-Za-z_][0-9]{4,5}[^0-9.]' || true)
  echo "  RetiredRouteTest: @Test lines $($G -cE '^ +@Test$' after/$T) · disabling annotations $($G -cE '@(Disabled|EnabledIf|DisabledIf)' after/$T || true) · ports, sockets, sleeps or 4-5 digit literals (strings removed) $nps · header-name literals (\"Link\", \"Deprecation\", \"Sunset\", \"Content-Type\") $($G -cE '"(Link|Deprecation|Sunset|Content-Type)"' after/$T || true)"
  echo "== tests (e) the plant of R.555's class: after with before's TiffinBoxServer.java (the handler removed), RetiredRouteTest alone"
  copy after .harness/plantx; cp before/$SRV .harness/plantx/$SRV
  guard "the handler-removed plant"
  bg "cd .harness/plantx && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" -Dtest=RetiredRouteTest -Dsurefire.failIfNoSpecifiedTests=false clean test -pl tiffinbox-web -am" .harness/plantx.log; local pre=$RE; offl .harness/plantx.log
  echo "  plant | mvn exit $pre (expected non-zero)"
  redlist .harness/plantx/tiffinbox-web/target/surefire-reports "plant"
  if [ "$RUNNO" = 1 ] || [ -n "${VERIFY:-}" ]; then
    echo "  ~ tests (c) mvn -o clean verify on a copy of after/ (.harness/tests): Surefire on H2 in memory, then the five ITs in Testcontainers containers (21280-21284)"
    copy after .harness/tests
    for p in $ITP 18881 18882 18883 18884; do [ "$(listeners $p)" = 0 ] || die "$p is bound before verify"; done
    guard "mvn verify"
    bg "cd .harness/tests && DOCKER_HOST=\"$DH\" TESTCONTAINERS_RYUK_DISABLED=true $MV \"$AL\" clean verify" .harness/verify.log; local vre=$RE
    reactor .harness/verify.log | sed 's/^  reactor:/  ~ verify reactor:/'
    python3 -I - .harness/tests/tiffinbox-web/target/surefire-reports-it .harness/tests/tiffinbox-web/target/failsafe-reports $vre <<'PY'
import sys, glob, xml.etree.ElementTree as E
fs = glob.glob(sys.argv[1] + "/TEST-*.xml") + glob.glob(sys.argv[2] + "/TEST-*.xml")
t = [0, 0, 0]
for f in fs:
    r = E.parse(f).getroot()
    for i, k in enumerate(("tests", "failures", "errors")): t[i] += int(r.get(k) or 0)
print("  ~ verify exit %s · ITs tests %d failures %d errors %d · classes %d" % (sys.argv[3], t[0], t[1], t[2], len(fs)))
PY
    echo "  ~ IT bindings: $($G -cE '^IT BINDINGS ' .harness/verify.log) lines · not 127.0.0.1: $($G -E '^IT BINDINGS ' .harness/verify.log | $G -oE -- '-> [0-9.]+:' | $G -vc -- '-> 127\.0\.0\.1:' || true) · Testcontainers containers after: $(dk ps -aq --filter label=org.testcontainers=true | wc -l | tr -d ' ') · images pulled: $($G -ciE 'Pulling image|pull(ed|ing) ' .harness/verify.log || true) · Downloading from: $($G -cE 'Download(ing|ed) from ' .harness/verify.log || true)"
  else echo "  ~ verify: run 1 only (this run $RUNNO)"; fi
  echo "  downloads across the builds: $(cat .harness/build-before.log .harness/build-after.log .harness/need.log .harness/plantx.log | $G -cE 'Download(ing|ed) from ' || true)"; }
c_spec() {
  echo "== spec: the document after/ serves (GET /v3/api-docs on 21130, read in the gone capture) against the regenerated committed file, and before's"
  python3 -I - $J/served.json after/$SPEC before/$SPEC $J/regen.json <<'PY'
import json, sys, hashlib
s = json.load(open(sys.argv[1], encoding="utf-8")); s.pop("servers", None)
w = open(sys.argv[4], "w", encoding="utf-8"); json.dump(s, w, indent=2, ensure_ascii=False); w.write("\n"); w.close()
g = open(sys.argv[4], "rb").read(); c = open(sys.argv[2], "rb").read(); o = open(sys.argv[3], "rb").read()
print("  spec | the served document, servers removed, json.dump(indent=2, ensure_ascii=False) + a newline: %d B md5 %s · after's committed file %d B md5 %s · equal byte for byte: %s" % (len(g), hashlib.md5(g).hexdigest(), len(c), hashlib.md5(c).hexdigest(), "yes" if g == c else "NO"))
print("  spec | before's committed file %d B md5 %s" % (len(o), hashlib.md5(o).hexdigest()))
A, B = json.loads(o), json.loads(c)
ops = lambda d: {(p, m): v for p, pv in d["paths"].items() for m, v in pv.items()}
oa, ob = ops(A), ops(B)
print("  spec | operations before %d after %d · paths before %d after %d · operationIds equal as a set: %s" % (len(oa), len(ob), len(A["paths"]), len(B["paths"]), "yes" if sorted(v.get("operationId") for v in oa.values()) == sorted(v.get("operationId") for v in ob.values()) else "NO"))
mv = [k for k in sorted(set(oa) | set(ob)) if oa.get(k) != ob.get(k)]
print("  spec | operations that moved: %d (%s) · byte-equal (as JSON): %d of %d" % (len(mv), "; ".join("%s %s operationId %s" % (m.upper(), p, ob.get((p, m), {}).get("operationId")) for p, m in mv), len(oa) - len(mv), len(oa)))
print("  spec | components equal: %s · info equal: %s" % ("yes" if A.get("components") == B.get("components") else "NO", "yes" if A.get("info") == B.get("info") else "NO"))
for p, m in mv:
    x, y = oa.get((p, m), {}), ob.get((p, m), {})
    print("  spec | %s %s before: responses %s · deprecated %s" % (m.upper(), p, ",".join(sorted(x.get("responses", {}))), x.get("deprecated", "absent")))
    print("  spec | %s %s after:  responses %s · deprecated %s" % (m.upper(), p, ",".join(sorted(y.get("responses", {}))), y.get("deprecated", "absent")))
PY
  echo "  spec | ops9s3.py: before $(python3 -I harness/ops9s3.py ops before/$SPEC | tail -1) · after $(python3 -I harness/ops9s3.py ops after/$SPEC | tail -1)"
  echo "  spec vs wire (R.528) for the 410, the entry against the gone capture's answer:"
  python3 -I - after/$SPEC $J/gone.h $J/gone.b <<'PY'
import json, sys
d = json.load(open(sys.argv[1])); e = d["paths"]["/customers/{name}"]["get"]["responses"]
h = {}
for l in open(sys.argv[2]).read().replace("\r", "").splitlines():
    if ":" in l: k, v = l.split(":", 1); h[k.strip().lower()] = v.strip()
st = open(sys.argv[2]).read().split()[1]
b = json.load(open(sys.argv[3]))
r = e.get(st, {}); ct = list(r.get("content", {}))
ex = [v["value"] for v in r.get("content", {}).get(h.get("content-type", ""), {}).get("examples", {}).values()]
ref = r.get("content", {}).get(h.get("content-type", ""), {}).get("schema", {}).get("$ref")
bn = dict(b); bn["instance"] = "/customers/Nobody"
print("  wire | status %s · the entry's response keys %s · documented: %s" % (st, ",".join(sorted(e)), "yes" if st in e else "NO"))
print("  wire | Content-Type %s · the entry's media types %s · equal: %s · schema %s" % (h.get("content-type"), ",".join(ct), "yes" if h.get("content-type") in ct else "NO", ref))
print("  wire | the example (Nobody) = the answer this route sent for Ravi with its instance set to /customers/Nobody: %s" % ("yes" if ex and ex[0] == bn else "NO"))
PY
  : > $J/empty.json; echo "  spec plant | ops9s3.py on an empty spec: $(python3 -I harness/ops9s3.py ops $J/empty.json > /dev/null 2>&1; echo "exit $?") (non-zero = refused)"; }
gendiff() { python3 -I - "$1" "$2" <<'PY'
import os, sys, re
a, b = sys.argv[1], sys.argv[2]; out = []
for d, ds, fs in os.walk(b):
    for f in fs:
        if not f.endswith(".java"): continue
        q = os.path.join(d, f); p = os.path.join(a, os.path.relpath(q, b))
        n = lambda x: [l for l in open(x, encoding="utf-8").read().splitlines() if "@Generated" not in l and "date =" not in l] if os.path.exists(x) else None
        if n(p) != n(q): out.append(f)
print(",".join(sorted(out)) or "none")
PY
}
c_client() {
  echo "== client: the generated client built and its tests run on both specs - the regenerated one (after's own build) and the committed one at $H22 (a copy of after with before's spec)"
  copy after .harness/cspec; cp before/$SPEC .harness/cspec/$SPEC
  guard "the client on before's spec"
  bg "cd .harness/cspec && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package -pl tiffinbox-client -am" .harness/build-cspec.log; local cre=$RE; offl .harness/build-cspec.log
  echo "  client | on before's spec: mvn -o clean package -pl tiffinbox-client -am exit $cre · on after's spec: the whole reactor's build exit 0 (the tests capture)"
  surefire .harness/cspec/tiffinbox-client/target/surefire-reports "client on before's spec" | head -1
  surefire .harness/after/tiffinbox-client/target/surefire-reports "client on after's spec" | head -1
  local g=tiffinbox-client/target/generated-sources/openapi
  for s in cspec after; do local f; f=$(find .harness/$s/$g -name CustomersApi.java | head -1)
    if [ -n "$f" ]; then echo "  client | $s: CustomersApi.customer: $($G -E '^ +ResponseEntity<[A-Za-z]+> customer\($' "$f" | sed -E 's/^ +//' | head -1)$( [ -z "$($G -E '^ +ResponseEntity<[A-Za-z]+> customer\($' "$f")" ] && echo absent) · @Deprecated on it: $($G -B12 -E '^ +ResponseEntity<[A-Za-z]+> customer\($' "$f" | $G -c '@Deprecated' || true) · its accept: $($G -B3 -E '^ +ResponseEntity<[A-Za-z]+> customer\($' "$f" | $G -oE 'accept = \{[^}]*\}' | head -1)"; else echo "  client | $s: no CustomersApi.java"; fi
    echo "  client | $s: the generated FILES list $(wc -l < .harness/$s/$g/.openapi-generator/FILES | tr -d ' ') lines md5 $(md5 -q .harness/$s/$g/.openapi-generator/FILES | cut -c1-12)"; done
  echo "  client | generated sources that differ between the two specs, their @Generated date lines left out: $(gendiff .harness/cspec/$g .harness/after/$g)"
  printf '%s\n' 'client.customer("Ravi"); // GET /customers/{name}' > $J/client-control.java
  echo "  client | the client's test sources naming /customers/{name} or customer(: $(cat after/tiffinbox-client/src/test/java/com/tiffinbox/client/*.java | $G -cE '/customers/\{name\}|[^A-Za-z]customer\(' || true) · the same grep on a planted control line: $($G -cE '/customers/\{name\}|[^A-Za-z]customer\(' $J/client-control.java) (R.566)"; }
c_api() { echo "== api: the /api/v1/ census (every GET of the committed spec's /api/v1/ paths, filled: name Ravi, id 1) on before (21136) and after (21130), from the compat capture's JVMs"
  sed 's/^  api |/  api before |/' $J/api-before.txt
  echo "  api | before -> after: $(cmp -s $J/api-before.txt $J/api-after.txt && echo identical || echo DIFFER) ($(wc -l < $J/api-before.txt | tr -d ' ') requests each) · U23's: $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit23/README.md | $G -oE '^api: .*')"; }
c_seven() { echo "== the seven (c5-unit11/curlset.sh) on before and after, each its own JVM - not a witness for the retirement: it sends no old-route read"
  echo "  expected $S466"
  echo "  before: the seven $(md5 -q $J/seven-before.txt) ($(wc -l < $J/seven-before.txt | tr -d ' ') lines) · after: the seven $(md5 -q $J/seven-after.txt)"; }
c_surface() { echo "== the old surface by count (U18's reader) on before and after - the witness: it holds the moved line, named"
  echo "  expected on before $U4SURF"
  echo "  before: the old surface $(md5 -q $J/surface-before.txt) ($($G -c '^== ' $J/surface-before.txt) requests) · after: $(md5 -q $J/surface-after.txt) ($($G -c '^== ' $J/surface-after.txt) requests)"
  echo "  the moved block, whole, before and after:"
  python3 -I - $J/surface-before.txt $J/surface-after.txt <<'PY'
import sys
def blocks(f):
    out, cur = [], None
    for l in open(f, encoding="utf-8").read().splitlines():
        if l.startswith("== "): cur = [l]; out.append(cur)
        elif cur is not None: cur.append(l)
    return out
for x, y in zip(blocks(sys.argv[1]), blocks(sys.argv[2])):
    if x != y:
        for l in x: print("  before | " + l)
        for l in y: print("  after  | " + l)
PY
}
jarcmp() { python3 -I - "$1" "$2" "$3" <<'PY'
import sys, zipfile
a, b, lab = zipfile.ZipFile(sys.argv[1]), zipfile.ZipFile(sys.argv[2]), sys.argv[3]
A = {i.filename: i.CRC for i in a.infolist() if not i.filename.endswith("/")}; B = {i.filename: i.CRC for i in b.infolist() if not i.filename.endswith("/")}
add = sorted(set(B) - set(A)); rem = sorted(set(A) - set(B)); mv = sorted(k for k in set(A) & set(B) if A[k] != B[k])
print("  moved | %s: entries %d -> %d · added %d · removed %d · moved %d%s" % (lab, len(A), len(B), len(add), len(rem), len(mv), (" (" + ", ".join(x.split("/")[-1] for x in mv) + ")") if mv else ""))
for x in add: print("  moved | %s added %s" % (lab, x))
for x in rem: print("  moved | %s removed %s" % (lab, x))
PY
}
c_moved() { echo "== moved: the jars the two builds make, before -> after (entry by entry, CRC)"
  jarcmp .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar "the web jar"
  jarcmp .harness/before/tiffinbox-core/target/tiffinbox-core-1.0.0.jar .harness/after/tiffinbox-core/target/tiffinbox-core-1.0.0.jar "the core jar"
  jarcmp .harness/before/tiffinbox-client/target/tiffinbox-client-1.0.0.jar .harness/after/tiffinbox-client/target/tiffinbox-client-1.0.0.jar "the client jar"
  echo "  build | BOOT-INF/lib names before $(ls "$XB/lib" | wc -l | tr -d ' ') after $(ls "$XA/lib" | wc -l | tr -d ' ') · added $(comm -13 <(ls "$XB/lib") <(ls "$XA/lib") | wc -l | tr -d ' ') · removed $(comm -23 <(ls "$XB/lib") <(ls "$XA/lib") | wc -l | tr -d ' ')"
  echo "  build | the web jar's lib by name: $(ls "$XA/lib" | $G -E '^(spring-web|spring-webmvc|jackson-databind|micrometer-core|springdoc-openapi-starter-webmvc-api|tomcat-embed-core)-[0-9]' | sed 's/\.jar$//' | paste -sd' ' -)"; }
c_inert() { echo "== inert: the exact list of requests this run sent to a TiffinBox JVM with an Idempotency-Key or an extra body member"
  local f; for f in $J/sent-*.txt; do echo "  inert | $(basename $f .txt | sed 's/^sent-//'): requests $(wc -l < $f | tr -d ' ')"; done
  echo "  inert | this receipt's sender sets no Idempotency-Key and sends no body: $($G -c 'Idempotency' receipts.sh | awk '{ print ($1 <= 2) ? "yes" : "NO" }') · the seven (curlset.sh) and the old surface name no Idempotency-Key: $($G -ci 'idempotency' $CURLSET || true) · $(sed -n '/^oldsurface2() {/,/^  rm -f "\$t".\*; }$/p' ../c9-unit21/receipts.sh | $G -ci 'idempotency' || true)"; }
c_change() { echo "== change: the paths this unit moves, derived (after/ against before/, file by file - never typed), and the guards"
  python3 -I - before after <<'PY'
import os, hashlib, sys
def walk(r):
    out = {}
    for d, ds, fs in os.walk(r):
        for f in fs: p = os.path.join(d, f); out[os.path.relpath(p, r)] = hashlib.md5(open(p, "rb").read()).hexdigest()
    return out
a, b = walk(sys.argv[1]), walk(sys.argv[2])
ch = sorted(k for k in set(a) | set(b) if a.get(k) != b.get(k))
for k in ch: print("  change | %s %s" % ("A" if k not in a else ("D" if k not in b else "M"), k))
print("  change | paths moved %d · added %d · removed %d · poms moved %d · core or client sources moved %d · application*.yaml moved %d" % (len(ch), sum(1 for k in ch if k not in a), sum(1 for k in ch if k not in b), sum(1 for k in ch if k.endswith("pom.xml")), sum(1 for k in ch if k.startswith(("tiffinbox-core/", "tiffinbox-client/src/"))), sum(1 for k in ch if "application" in k and k.endswith(".yaml"))))
PY
  echo "  change | modules before $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' before/pom.xml | paste -sd' ' -) · after $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' after/pom.xml | paste -sd' ' -)"
  echo "  change | the handler, before -> after (diff of TiffinBoxServer.java):"
  diff before/$SRV after/$SRV | sed 's/^/    /'
  echo "  change | the constant, before -> after (diff of TiffinBoxErrors.java):"
  diff before/$WEB/TiffinBoxErrors.java after/$WEB/TiffinBoxErrors.java | sed 's/^/    /'
  echo "  change | route-retired named, per file of after/: $(cd after && $G -rlF 'route-retired' . | sort | while read -r f; do echo "$f=$($G -cF 'route-retired' "$f")"; done | paste -sd' ' -)"
  echo "  change | @GetMapping(\"/customers/{name}\") in after's sources: $($G -rcF '@GetMapping("/customers/{name}")' after/$WEB | awk -F: '{ s += $2 } END { print s }') · its method name: $($G -A1 -F '@GetMapping("/customers/{name}")' after/$SRV | tail -1 | $G -oE '[a-z]+\(@PathVariable' | sed 's/(.*//') · methods named customer( in TiffinBoxServer: $($G -cE ' customer\(@PathVariable' after/$SRV)"
  echo "  change | probe, blue or harness named in a changed source, test or spec of after/ (the README's older cards name their own units' harnesses; its unit 24 card is counted apart): $(cd after && for f in $(find . -type f -name '*.java' -o -type f -name '*.json' | sort); do cmp -s "$f" "../before/$f" 2> /dev/null || $G -ciE 'probe|\bblue\b|harness' "$f" || true; done | awk '{ s += $1 } END { print s + 0 }') · in the unit 24 card: $(awk '/^## Course 9 · unit 24 /,/^## Course 9 · unit 22 /' after/README.md | $G -ciE 'probe|\bblue\b|harness' || true)"
  echo "  change | the test class path of tiffinbox-web and tiffinbox-client (jar names in the two builds' test runs): before -> after the same: $( [ "$(ls .harness/before/tiffinbox-web/target/surefire-reports | wc -l)" -gt 0 ] && cmp -s <(unzip -l .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | $G -oE 'BOOT-INF/lib/[^ ]+' | sort) <(unzip -l .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | $G -oE 'BOOT-INF/lib/[^ ]+' | sort) && echo yes || echo NO)"; }
c_stale() { echo "== stale: the sentences the retirement makes false, in after/ (README, the Javadoc of the files this unit touches), each with its disposition"
  local gr=0; (cd after && $G -n -i -E 'customers/\{name\}|old address|old route|unchanged and untagged|nothing is deprecated|still reads the cache|throws it' README.md $WEB/CustomerNotFound.java $WEB/CustomerReads.java $WEB/TiffinBoxErrors.java) > $J/stale.txt || gr=$?; [ $gr -le 1 ] || die "the stale grep could not run (exit $gr)"
  must $J/stale.txt
  python3 -I - $J/stale.txt after <<'PY'
import re, sys, os
card = None
rd = open(os.path.join(sys.argv[2], "README.md"), encoding="utf-8").read().splitlines()
a = next(i for i, l in enumerate(rd, 1) if l.startswith("## Course 9 · unit 24 "))
b = next(i for i, l in enumerate(rd, 1) if i > a and l.startswith("## "))
note = next(i for i, l in enumerate(rd, 1) if l.startswith("*Course 9, unit 24:"))
for l in open(sys.argv[1]).read().splitlines():
    f, n, t = l.split(":", 2); n = int(n); t = t.strip()
    if f == "README.md":
        if a <= n < b: d = "unit 24's own card"
        elif note <= n <= note + 5 or "unit 24" in t: d = "written or noted by unit 24"
        elif "customers/{name}" in t and "/customers/{name}" not in t.replace("/api/v1/customers/{name}", ""): d = "names the successor (untouched)"
        else: d = "an older unit's sentence of its own tree, left; the dated unit 24 note at :%d covers it" % note
    else:
        src = open(os.path.join(sys.argv[2], f), encoding="utf-8").read()
        d = "noted by the file's own dated unit 24 sentence" if "Course 9, unit 24" in src else "UNDISPOSED"
    print("  stale | %s:%d | %s | %s" % (f.split("/")[-1], n, d, t[:150]))
PY
  echo "  stale | the README sentence 'nothing is deprecated or retired here' left unrewritten: $($G -c 'nothing is deprecated or retired here' after/README.md | awk '{ print ($1 == 0) ? "no" : "YES" }')"
  echo "  stale | the frozen folders' stale lines, named, never edited: ../c9-unit12/README.md /customers/Ravi lines $($G -c '/customers/Ravi' ../c9-unit12/README.md)"; }
c_frozen() { echo "== frozen: the receipts of older units that read the live anchor (flag 31's class, D17) - printed, never re-run"
  local f n; for f in ../c9-unit10/receipts.sh:611 ../c9-unit13/receipts.sh:334 ../c9-unit15/receipts.sh:396; do n=${f##*:}; echo "  frozen | ${f#../}: $(sed -n "${n}p" "${f%%:*}" | cut -c1-160)"; done
  echo "  frozen | c9-unit15/harness/chk15.py:398-399: $(sed -n '398,399p' ../c9-unit15/harness/chk15.py | cut -c1-140 | paste -sd'|' -)"
  echo "  frozen | poms this unit moves (after/ against before/): $(cd after && for p in $(find . -name pom.xml | sort); do cmp -s "$p" "../before/$p" || echo "$p"; done | wc -l | tr -d ' ') · the committed spec moved: $(cmp -s before/$SPEC after/$SPEC && echo no || echo yes) · the old route moved: yes (the compat capture)"
  echo "  frozen | this unit's own files naming the live anchor outside the start note, the end check, the git diff and the H2 sweep: $LA (the static gate above)"; }
annsame() { rm -rf $J/annchk; copy after $J/annchk; sh exercise/break.sh $J/annchk > /dev/null || { echo "NO (break.sh failed)"; return 0; }
  python3 -I - .harness/ann/$SRV $J/annchk/$SRV <<'PY'
import sys, re
rx = re.compile(r"    // Course 9, unit 24 - the timeline's first step.*?\n    \}\n", re.S)
a = rx.search(open(sys.argv[1], encoding="utf-8").read()); b = rx.search(open(sys.argv[2], encoding="utf-8").read())
print("yes" if a and b and a.group(0) == b.group(0) else "NO")
PY
}
c_exercise() { local sh o
  rm -rf exercise/.servers exercise/.work; mkdir -p exercise/.work
  for sh in bash zsh; do
    guard "the exercise, $sh"
    local envs=(env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21138 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock)
    copy after exercise/.work/$sh
    if [ $sh = bash ]; then o=$(cd exercise && "${envs[@]}" bash -c 'sh break.sh .work/bash; sh check.sh .work/bash; echo "broken: check exit $?"; sh apply.sh .work/bash; sh check.sh .work/bash; echo "solved: check exit $?"' 2>&1)
    else o=$(cd exercise && "${envs[@]}" /bin/zsh -f -c 'sh break.sh .work/zsh; sh check.sh .work/zsh; echo "broken: check exit $?"; sh apply.sh .work/zsh; sh check.sh .work/zsh; echo "solved: check exit $?"' 2>&1); fi
    printf '%s\n' "$o" | sed "s/^/  $sh | /"
    [ "$(listeners 21138)" = 0 ] || die "the exercise left something listening on 21138"; done
  echo "  the broken copy's method = the announce copy's method (break.sh on a fresh copy of after against before + announce.diff, the method's text): $(annsame)"
  if [ "$RUNNO" = 1 ] || [ "$RUNNO" = 0 ]; then local v
    for v in remove json notype successor broken; do copy after exercise/.work/$v; o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21138 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock bash -c "sh break.sh .work/$v > /dev/null; HOW=$v sh apply.sh .work/$v; sh check.sh .work/$v; echo \"check exit \$?\"" 2>&1); printf '%s\n' "$o" | sed "s/^/  ~ $v bash | /"; done
  else echo "  ~ the refused variants: run 1 only"; fi
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'
  rm -rf exercise/.servers exercise/.work; }
c_title() {
  local TS; TS=$(python3 -I -B harness/chk24.py title-line)
  echo "== the title for search (S4B's Unit 24, printed, not edited - the copy step's): \"$TS\" ($(python3 -I -c 'import sys; print(len(sys.argv[1]))' "$TS") characters by len())"
  echo "  the registry: TITLES[\"24\"] = $(sed -n 's/^ *"24": *"\([^"]*\)".*/\1/p' "$J9" | head -1) · SEARCH_TITLES rows naming 410 or Deprecation in java*_series.py: $(cat "$HOME"/Desktop/PromptVidya-Automation/java*_series.py | $G -ciE '410 Gone|Deprecation and' || true)"; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
XB="$U/.harness/before/$XD"; XA="$U/.harness/after/$XD"
echo "### the captures${DEVCAPS:+ (DEVELOPMENT: only $DEVCAPS - not a run of record)}"
cap advisory c_advisory
cap before c_before
cap census c_census
cap count c_count
cap announce c_announce
cap remove c_remove
if [ -z "${DEVCAPS:-}" ] || echo " $DEVCAPS " | $G -qE ' (compat|api|seven|surface|inert|spec|gone) '; then compatrun > $J/compat-run.txt 2>&1 || die "the compat JVMs: $(tail -3 $J/compat-run.txt)"; fi
cap compat c_compat
cap gone c_gone
cap tests c_tests
cap spec c_spec
cap client c_client
cap api c_api
cap seven c_seven
cap surface c_surface
cap moved c_moved
cap inert c_inert
cap change c_change
cap stale c_stale
cap frozen c_frozen
cap exercise c_exercise
cap title c_title
echo "== plants (each made to FAIL first on a copy of this run's capture; harness/chk24.py plants)"
if [ -z "${DEVCAPS:-}" ]; then
PL=$(python3 -I -B harness/chk24.py plants .) || die "a plant was not caught: $(printf '%s\n' "$PL" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$PL" | $G '^ok ' | sed 's/^ok /  /'
PLV=$(printf '%s\n' "$PL" | sed -n 's/^VALUES //p')
fi
echo "  static (i), as written: output md5 $STMD5"
SC=.harness/static-copy; rm -rf $SC; mkdir -p $SC/u $SC/c9-unit23; cp -R harness exercise README.md receipts.sh receipts.md5 $SC/u/; cp -R after $SC/u/after; ln -s "$UP/c9-unit22/after" $SC/c9-unit23/after; ln -s ../c9-unit23/after $SC/u/before
copy after $SC/c9-""tiffinbox; printf 'x' >> $SC/c9-""tiffinbox/compose.yaml
S2=$(cd $SC/u && REPO="$UP" C9R="$C9R" python3 -I -B harness/chk24.py static after before 2>&1 | md5 -q)
echo "  static (ii) beside a scratch copy of the anchor with a byte appended to its compose.yaml (the real anchor untouched): output md5 = (i): $( [ "$S2" = "$STMD5" ] && echo yes || echo NO)"
[ "$S2" = "$STMD5" ] || die "static (ii) differs from (i)"
echo "  ~ static (iii) of this run: the anchor folder beside this unit's folder: $( [ -d "../c9-""tiffinbox" ] && echo 'present (runs 1, 2: static (i) is the as-written run)' || echo 'MOVED ASIDE (the sealed clone, run 3: static (i) of this run is (iii))')"
echo "  static plants (flag 14): a static assertion reading the live anchor -> $(python3 -I -B harness/chk24.py static-plant live > /dev/null 2>&1; echo "exit $?") · the same path from two pieces -> $(python3 -I -B harness/chk24.py static-plant pieces > /dev/null 2>&1; echo "exit $?") (1 = caught)"
printf '%s\n' 'paste a b | sed -E '"'"'1~2s/^/x/'"'"' > $J/side.txt' > $J/gnu-plant.sh   # GNUFORM (the plant)
echo "  R.564 plant: a GNU-only sed line counted by the receipts' own GNU-form grep: $($G -cE "sed [^|]*[0-9]~[0-9]|sed -i( |$)|sed -i ''" $J/gnu-plant.sh || true) (1 = caught)"   # GNUFORM

# ---- the end: the sweep, the values, the published hashes -------------------------------------------------------------------------------
[ -z "$(echo $PIDS)" ] || die "a JVM of this run is still running: $PIDS"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
[ -z "$(dk ps -aq --filter label=org.testcontainers=true)" ] || die "a Testcontainers container is left"
NI1=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' '); CT1=$(dk ps -a --format '{{.Names}}' 2> /dev/null | sort | paste -sd, -)
[ "$NI1" = "$NI0" ] && [ "$VOL1" = "$VOL0" ] && [ "$CT1" = "$CT0" ] || die "R.322: images $NI0 -> $NI1, volumes $VOL0 -> $VOL1, containers [$CT0] -> [$CT1]"
AD1=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true); [ "$AD1" = "$AD" ] || die "the anchor moved during the run"
if [ -d ../c9-tiffinbox ] && [ -n "${ENDCHECK:-}" ]; then [ -z "$AD1" ] || die "the end check: after/ is not the changed anchor ($AD1)"; fi   # ENDCHECK
GD1=$(git -C "$UP" diff --stat $H22 -- c9-unit01 c9-unit02 c9-unit03 c9-unit04 c9-unit05 c9-unit06 c9-unit07 c9-unit08 c9-unit09 c9-unit10 c9-unit11 c9-unit12 c9-unit13 c9-unit14 c9-unit15 c9-unit16 c9-unit17 c9-unit18 c9-unit19 c9-unit20 c9-unit21 c9-unit22 '*pom.xml' $ANX | wc -l | tr -d ' ')   # GITDIFF
[ "$GD1" = 0 ] || die "git diff --stat against $H22 moved during the run ($GD1 lines)"
pin before-tree before; pin after-tree after
MDB=$(find . ../c9-tiffinbox -name '*.mv.db' -not -path './.harness/*' 2> /dev/null | wc -l | tr -d ' ')
[ "$MDB" = 0 ] || die "an H2 file outside .harness/"
[ -z "$(ls -A exercise | $G -v -xE 'README.md|SOLUTION.md|apply.sh|break.sh|check.sh')" ] || die "the exercise left a file in exercise/"
VALS="$VALS
plants: $PLV
build: seed_files=$NF0 seed_bytes=$NB0 central_only=$CO"
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
[ -n "${DEVCAPS:-}" ] && { echo "c9-unit24: DEVELOPMENT run ($DEVCAPS) - nothing published"; exit 2; }
VO=$(python3 -I -B harness/chk24.py values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; [ -n "${NOPIN:-}" ] || die "README.md's values block is not this run's"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM of this run, ports free, no container left (images $NI0 -> $NI1, volumes $VOL0 -> $VOL1, containers as at the start) · the anchor against after/ as at the start · git diff --stat empty · the tree pins · *.mv.db outside .harness 0"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit24: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit24: $NCAPS captures checked; every capture = published ($NCAPS)"
