#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 23 "Observability for APIs" - this unit's receipts. NO anchor change: before and after are both links whose text is
# ../c9-unit22/after (U22's frozen tree, pinned by ../c9-unit22/receipts.md5's after-tree line). Nothing shipped moves; the unit reads what
# the shipped tree already answers on /actuator/prometheus (exposed since Course 5: health,prometheus) - http.server.requests by route
# and status - on the extracted jar of before, H2 only (no store, no container, no browser).
# The harness's things, labelled on every capture that uses one (R.397): the harness's short capacity (--tiffinbox.rate-limit.capacity=5,
# a run flag), the harness's histogram flag, the harness's exposure flag (health,prometheus,mappings,metrics) and the harness's failing
# route (harness/src/probe23/Boom.java, joined only by --spring.main.sources=probe23.Boom on 21126).
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5; lines starting "  ~" are run-variant and
# left out of the hash - the exercise's refused variants of run 1, the families table, the run's date):
#   advisory  the S9.36 read filed for this section (ADV4), verified, before any build
#   before    the two links, the counters re-derived on before (lib, spec, the filters' orders)
#   pin       Micrometer's version off the jar, the outcome rule off javap, the exposure (yaml + the default JVM), the greps with controls
#   census    the controllers by unit 15's printed rule · spec: the committed spec's size, md5 and counts
#   scrape    /actuator/prometheus on the nine's JVM (21120): the families, the http_server_requests rows, the masked scrape
#   tags      the tag keys and their values on the nine
#   known     the nine (rebuilt from the probe's bodies), their rows against the sent list, the access log and the probe's series.txt;
#             the second set (a conditional GET, a 405, the key filter's three) and the diff scrape1 -> scrape2
#   404       the 404 rows by uri, each body's kind
#   unknown   the limiter's refusal on the harness's short capacity (21125) and the 405 (21120)
#   filters   the key filter's replay and refusal (21120): their uri; the sources' observe() lines with controls
#   errors    E of RED computed off outcome; the harness's failing route (21126)
#   duration  the duration families by NAME; _bucket lines 0 with a planted control; the harness's histogram flag (21125)
#   api       every GET of the committed spec's /api/v1/ paths, two passes (21125) · seven · surface - not witnesses for the scrape
#   inert     the exact list of requests that carried an Idempotency-Key
#   tests     mvn -o clean package of before WITH its tests (web, client), Docker-free; no verify (no anchor change)
#   harness   the folder's files, the instruments, the static check (three runs)
#   exercise  run.sh + check.sh on 21128, bash and zsh -f; the refused variants (run 1)
#   title     the title for search
# Ports (U23's band, 21120-21129, §P: 20900 + 10·22): 21120 the nine's JVM · 21125 the scratch JVMs, one at a time · 21126 the
# harness-joined, exposure-flagged JVM · 21128 the exercise · 21121-21124, 21127, 21129 and 21110-21119 never bound; 21280-21284 not bound
# (no verify). Every JVM on 127.0.0.1; every curl --noproxy '*'.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
C9R=${C9R:-"/Users/$ME/Downloads/Youtube Content/LearnProgrammingWithVivek/rest-apis-done-right"}   # the course's folder (briefs, research)
SEED=${SEED:-"$C9R/_research/m2-seed-c9-s4"}   # the course's Section 4 seed
PK4="$C9R/_research/s4-probe-2026-11-27"; ADV="$C9R/_research/docs-2026-11-27/advisories-s4probe"
S4B="$C9R/_briefs/UNIT-BRIEFS-S4-OPERATING.md"
export C9R
RUNNO=${RUNNO:-0}                                     # the run of record's number (1, 2, 3); 0 = development
USTART=2026-11-27   # the day this unit's evidence STARTED (FACTORY-NEXT: "21:46 CET - EVIDENCE 23: STARTED"): the S9.36 day rule is applied to it (D15)
H22=d7e0663                                           # unit 22's commit = this unit's HEAD at its start: the static check reads its objects
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): only counted here, nothing is started
dk() { docker -H "$DH" "$@"; }
export DOCKER_HOST="$DH"
PIDS=""; INTR=""; mpid=""
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in $mpid $PIDS; do [ -z "$p" ] || killtree "$p"; done; for p in $mpid $PIDS; do if kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; for f in exercise/.servers/*/pid; do [ -f "$f" ] && kill "$(cat "$f")" 2> /dev/null; done; rm -rf exercise/.servers exercise/.work; [ -z "$INTR" ] || rm -f .r-*.new; rmdir .r-lock 2> /dev/null || rm -rf .r-lock; true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git unzip javac javap /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|SPRINGDOC_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|AWS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit23 receipts · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · $(curl --version | head -1 | cut -d' ' -f1-2) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }') · run $RUNNO"
echo "  ~ run date $(date '+%Y-%m-%d %H:%M %Z')"

# ---- gates before anything is built: the folder, the links, the pins, the anchor note, the static check, the prose, the exercise --------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk23.py dur9.py norm.py ops9s3.py s923.py scrape.py src tree23.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
[ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe23/Boom.java' ] || die "harness/src holds another file, or misses one"
NOTUSED="Bind.java Rec.java Limits.java bind.py rec.py reach.py seal9.py cdp.mjs cdp9.mjs chrome20.py loc9.py walk.py Stub.java Caller21.java"
for f in $NOTUSED; do [ -z "$(find harness -name "$f")" ] || die "harness/: $f is an instrument this unit does not carry"; done
[ "$(ls exercise | $G -vxE '\.servers|\.work' | paste -sd' ' -)" = 'README.md SOLUTION.md apply.sh check.sh mappings.txt requests.txt run.sh' ] || die "exercise/ holds another file, or misses one: $(ls exercise | paste -sd' ' -)"
for t in before after; do [ -L $t ] && [ "$(readlink $t)" = ../c9-unit22/after ] || die "$t must be a link whose text is exactly ../c9-unit22/after"; done
for t in before after; do [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-client/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/"; true; done
echo "  before -> $(readlink before) · after -> $(readlink after) (two links, the text exact: no anchor change) · no secrets/, target/ or .m2-demo/ through either · none of: $NOTUSED"
[ "$(md5 -q harness/ops9s3.py)" = "$(md5 -q ../c9-unit22/harness/ops9s3.py)" ] || die "harness/ops9s3.py is not unit 22's copy, byte for byte"
[ "$(md5 -q harness/norm.py)" = "$(md5 -q ../c9-unit22/harness/norm.py)" ] || die "harness/norm.py is not unit 22's copy, byte for byte"
[ "$(sed -n '5,$p' harness/tree23.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit22/harness/tree22.py | md5 -q)" ] || die "harness/tree23.py's code is not tree22.py's"
for u in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22; do [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit$u/harness/dur9.py)" ] || die "harness/dur9.py is not ../c9-unit$u's copy"; done
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"
else D9N="(the registry is not on this machine: U01-U22's copies are the pin)"; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit01-22's copies $D9N · tree23.py's code = tree22.py's · ops9s3.py, norm.py = unit 22's (md5 $(md5 -q harness/ops9s3.py | cut -c1-8), $(md5 -q harness/norm.py | cut -c1-8))"
S22=$(md5 -q ../c9-unit22/harness/s922.py); [ "$S22" = "$(awk '$1 == "file" && $2 == "harness/s922.py" { print $3 }' ../c9-unit22/receipts.md5)" ] || die "U22's s922.py is not its receipts.md5 file line"
[ ! -f "$C9R/_builders/s923.py" ] || cmp -s harness/s923.py "$C9R/_builders/s923.py" || die "harness/s923.py is not _builders/s923.py"
NS=$(diff ../c9-unit22/harness/s922.py harness/s923.py | $G -c '^<' || true)
echo "  s923.py: U22's s922.py ($(echo $S22 | cut -c1-8), = ../c9-unit22/receipts.md5's file line) with XU23C9 added - lines of s922.py's not in s923.py: $NS (the glue lines) · lines added $(diff ../c9-unit22/harness/s922.py harness/s923.py | $G -c '^>') · the diff's md5 $(diff ../c9-unit22/harness/s922.py harness/s923.py | md5 -q)"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit22/receipts.md5)
[ -n "$UA" ] || die "../c9-unit22/receipts.md5 has no after-tree line"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree23.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line"
  [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit22/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree23.py $dir/ -> $got = receipts.md5's $nm line = ../c9-unit22/receipts.md5's after-tree line"; }
pin before-tree before; pin after-tree after
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true)
echo "  after/ against the live anchor (the start note): $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ, or the anchor is not beside this folder - this unit measures ../c9-unit22/after through its links' )"
HF="harness/chk23.py harness/s923.py harness/tree23.py harness/dur9.py harness/ops9s3.py harness/norm.py harness/scrape.py harness/src/probe23/Boom.java exercise/run.sh exercise/check.sh exercise/apply.sh exercise/requests.txt exercise/mappings.txt"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's files: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
ST=$(python3 -I -B harness/chk23.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
STMD5=$(printf '%s\n' "$ST" | md5 -q)
echo "  static (harness/chk23.py static after before; reads the links' tree, this folder and git show $H22:… only - flag 19): $(printf '%s\n' "$ST" | $G -c '^ok ') checks, FAIL 0 · its output md5 $STMD5"
SPT=$(python3 -I -B harness/scrape.py selftest) || die "scrape.py's self-test: $SPT"
echo "  $SPT"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s923.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U19 [0-9]+ families · U20 [0-9]+ families · U21 [0-9]+ families · U22 [0-9]+ families · U23 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s923, per sentence): /'
PH=$($G -rnE 'PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b|<measure>' README.md exercise/README.md exercise/SOLUTION.md | cut -c1-100 | head -2 | paste -sd';' -)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
GL=$(python3 -I -B harness/chk23.py gloss README.md) || die "the gloss: $(printf '%s\n' "$GL" | $G '^FAIL' | head -3 | paste -sd';' -)"
echo "  the gloss: $(printf '%s\n' "$GL" | $G -c '^ok ') checks, FAIL 0 ($(printf '%s\n' "$GL" | $G '^GLOSS ' | sed 's/^GLOSS //'))"
HOOK=$(python3 -I -B harness/chk23.py hook) || die "the hook could not be extracted"; EXQ=$(python3 -I -B harness/chk23.py exq) || die "the exercise line could not be extracted"
IL=$(python3 -I -B harness/chk23.py interleaved) || die "the brief's interleaved hooks and exercises: $IL"
echo "  $IL"
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S4B's Unit 23 Hook line), byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
HW=$(printf '%s\n' "$HOOK" | wc -w | tr -d ' '); EW=$(printf '%s\n' "${EXQ#Your turn: }" | wc -w | tr -d ' ')
HSW=$(printf '%s\n' "$HOOK" | python3 -I -c 'import re,sys; print(max(len(s.split()) for s in re.split(r"(?<=[.!?:])\s+", sys.stdin.read().strip()) if s))')
[ "$EW" -le 25 ] && [ "$HW" -le 25 ] || die "a spoken line over 25 words (exercise $EW, the hook $HW)"
echo "  the hook ($HW words, its longest sentence $HSW) and the exercise's line ($EW words after 'Your turn:', $(printf '%s\n' "$EXQ" | wc -w | tr -d ' ') with it), byte for byte; both extracted from S4B's Unit 23"
printf '%s\n\n%s\n' "$HOOK" "$EXQ" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s923.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
SWR=$(printf '%s\n' "$SW" | $G ' line ' | sed 's#.*spoken.md ##' | sort -u | paste -sd';' -)
echo "  the hook and the exercise's line through s923.py: $(printf '%s\n' "$SW" | tail -1 | sed 's/.* refused: /refused /')$( [ -n "$SWR" ] && echo " - $SWR (handed to RED: the hook is the brief's, never edited)")"; rm -f .r-lock/spoken.md
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
! $G -qE '(^|[^A-Za-z0-9_.-])path=|[$][{]?path([^A-Za-z0-9_]|$)' exercise/run.sh exercise/check.sh exercise/apply.sh || die "an exercise script names a variable path (zsh): rpath"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh exercise/run.sh exercise/check.sh exercise/apply.sh | $G -qwE "$K1|$K2" || die "a script names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket"
DRL=$($G -v '^ *#' receipts.sh | $G -cE 'dk (run|pull|create|start) ' || true); [ "$DRL" = 0 ] || die "a docker run, pull, create or start line: this unit starts no container"
MVL=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -F '$MV ')
MVA=$(printf '%s\n' "$MVL" | $G -vF -- '-pl tiffinbox-web -am' | $G -cF -- '-pl ' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh with a -pl form other than '-pl tiffinbox-web -am'"
MVS=$(printf '%s\n%s\n' "$MVL" "$($G -F 'mvn ' exercise/run.sh)" | $G -cE -- ' -s | --settings ' || true); [ "$MVS" = 0 ] || die "RED4 #27: a Maven line with -s (the central-only settings fail offline)"
GNU=$($G -v '^ *#' receipts.sh exercise/run.sh exercise/check.sh exercise/apply.sh | $G -vF 'GNUFORM' | $G -cE "sed [^|]*[0-9]~[0-9]|sed -i( |$)|sed -i ''" || true)   # GNUFORM: this line and the plant's name the forms
[ "$GNU" = 0 ] || die "R.564: a GNU-only sed form or a bare sed -i ($GNU lines)"   # GNUFORM
HID=$($G -v '^ *#' receipts.sh | $G -E '> "?\$J/[A-Za-z0-9_.-]+\.txt' | $G -cE '\|\| true|2> /dev/null' || true)
[ "$HID" = 0 ] || die "R.564: a capture-writing line hides its failure ($HID lines)"
LA=$($G -nF 'c9-tiffinbox' receipts.sh exercise/run.sh exercise/check.sh exercise/apply.sh harness/tree23.py harness/chk23.py harness/scrape.py harness/norm.py | $G -v ':[0-9]*: *#' | $G -vF 'AD=$(diff -rq' | $G -vF 'AD1=$(diff -rq' | $G -vF 'MDB=$(find' | $G -vF "\$G -nF 'c9-tiffinbox'" | $G -vF 'LIVE_ANCHOR_PLANT' | $G -vF 'GITDIFF' | wc -l | tr -d ' ')
[ "$LA" = 0 ] || die "flag 19: a line of the receipts, the exercise or the harness reads the live anchor outside the start note, the end check, the git diff and the H2-file sweep"
echo "  static: no kill by name; every docker call on the pinned socket, no container started; R.391's Maven form only, no -s; R.564: no GNU sed form, no hidden capture step; the live anchor read only by the start note, the end check, the git diff and the H2-file sweep (flag 19)"
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
    gsub(/[A-Z][a-z][a-z], [0-9][0-9] [A-Z][a-z][a-z] [0-9][0-9][0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9] GMT/, "<date>")
    gsub(/[Rr]etry-[Aa]fter: [0-9]+/, "Retry-After: <s>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'took 812 ms' '"timestamp":"2026-11-01T08:09:00.123Z"' "$U/x $HOME/y" 'Retry-After: 42' 'Date: Fri, 27 Nov 2026 10:00:00 GMT · key 62cd547a-8da7-4f2c-ac9b-e4db970ce097' | mask)
[ "$(printf '%s\n' "$MP" | paste -sd'|' -)" = 'Started TiffinBoxServer in <t> (process running for <t>)|took <t>|"timestamp":"<time>"|…/x ~/y|Retry-After: <s>|Date: <date> · key <uuid>' ] || die "the mask's self-test: $(printf '%s\n' "$MP" | paste -sd'|' -)"
echo "  masks: the log mask masked a Started line's times, a millisecond count, a timestamp, the folders, the home, a Retry-After value, an HTTP date and a uuid (self-test)"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh); [ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SURF=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh); [ ${#U4SURF} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh (SURF=)"
U22V=$(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit22/README.md | $G -E '^(seven|surface): ' | $G -oE '(seven|surface)=[0-9a-f]{8}' | paste -sd' ' -)
[ "$U22V" = "seven=$(echo $S466 | cut -c1-8) surface=$(echo $U4SURF | cut -c1-8)" ] || die "U22's README values block ($U22V) is not the seven and the surface read off the receipts"
echo "  the seven: expected $S466 (../c7-unit31/receipts.sh's S466= line) · the old surface: expected $U4SURF (../c9-unit04/receipts.sh's SURF= line) · both = U22's values block ($U22V)"
SER=$PK4/captures/h45/series.txt
[ "$(md5 -q "$SER")" = 1a6ae5cdf98664ee79197c469bdaf7d3 ] || die "the probe's series.txt is not 1a6ae5cd (its md5 as read when this receipt was written)"
echo "  the probe's filed captures (read, not copied: the expectation, never the sentence): h45/series.txt $(md5 -q "$SER" | cut -c1-8) ($(wc -l < "$SER" | tr -d ' ') rows) · h45/prom.b $(md5 -q "$PK4/captures/h45/prom.b" | cut -c1-8) · h41/prom.b $(md5 -q "$PK4/captures/h41/prom.b" | cut -c1-8)"

# ---- docker (counted only), ports, the guard: the baselines ---------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' '); CT0=$(dk ps -a --format '{{.Names}}' 2> /dev/null | sort | paste -sd, -)
[ -z "$(dk ps -aq --filter name=^/c9u23- 2> /dev/null)" ] || die "a c9u23-* container exists before the run"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
BAND="21120 21121 21122 21123 21124 21125 21126 21127 21128 21129"
NEVER="21121 21122 21123 21124 21127 21129 21110 21111 21112 21113 21114 21115 21116 21117 21118 21119 21160 21161 21162 21163 21164 21165 21166 21167 21168 21169 21280 21281 21282 21283 21284"
PORTS="18425 18881 18882 18883 18884 20578 20615 $BAND $NEVER"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
for p in $BAND 21280 21281 21282 21283 21284; do [ -z "$(lsof -nP -iUDP:$p 2> /dev/null)" ] || die "UDP $p is bound"; done
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
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned, counted only) · images $NI0 · volumes $VOL0 · containers [$CT0] · no c9u23-* container · ports free (21121-21124, 21127, 21129, 21110-21119, 21160-21169 and 21280-21284 included, never bound)"
ANCP=""; ANX=":(exclude)c9-tiffinbox"; [ -d ../c9-tiffinbox ] && { ANCP=c9-tiffinbox; ANX=""; }   # GITDIFF: run 3 moves the clone's anchor aside; then the pathspec leaves it out
GD0=$(git -C "$UP" diff --stat $H22 -- $ANCP c9-unit01 c9-unit02 c9-unit03 c9-unit04 c9-unit05 c9-unit06 c9-unit07 c9-unit08 c9-unit09 c9-unit10 c9-unit11 c9-unit12 c9-unit13 c9-unit14 c9-unit15 c9-unit16 c9-unit17 c9-unit18 c9-unit19 c9-unit20 c9-unit21 c9-unit22 '*pom.xml' $ANX | wc -l | tr -d ' ')   # GITDIFF
echo "  git diff --stat $H22 -- ${ANCP:-(the anchor moved aside: left out)} c9-unit01..22 and every pom: $GD0 lines (the start)"

# ---- the tree copied and built offline WITH its tests (the tests capture's package run); the harness's class ----------------------------
M2="$PWD/.m2-demo"
if [ ! -d "$M2" ]; then [ -d "$SEED" ] || die "the seed $SEED is missing"; cp -cR "$SEED" "$M2" 2> /dev/null || cp -R "$SEED" "$M2" || die "the seed could not be copied"; fi
NF0=$(find "$M2" -type f | wc -l | tr -d ' '); NB0=$(find "$M2" -type f -print0 | xargs -0 stat -f %z | awk '{ s += $1 } END { printf "%d", s }')
CO=$(find "$M2" -name _remote.repositories -print0 | xargs -0 $G -l 'central-only' | wc -l | tr -d ' ')
[ "$CO" = 0 ] || die "$CO _remote.repositories files in the seed copy still name central-only"
for a in io/micrometer/micrometer-core/1.17.3 io/micrometer/micrometer-registry-prometheus org/springframework/boot/spring-boot-starter-parent/4.1.3; do [ -n "$(ls -R "$M2/$a" 2> /dev/null | $G -E '\.(jar|pom)$')" ] || die ".m2-demo holds no $a (no seed act here: report the coordinates)"; done
echo "  .m2-demo (a copy of the seed m2-seed-c9-s4): files $NF0 · bytes $NB0 · _remote.repositories naming central-only: $CO · micrometer-core/1.17.3: $(ls "$M2/io/micrometer/micrometer-core/1.17.3" | $G -c '\.jar$') jar · micrometer-registry-prometheus: $(ls "$M2/io/micrometer/micrometer-registry-prometheus" | paste -sd, -)"
mkdir -p .harness; for d in before run work hc static-copy iii; do rm -rf .harness/$d; done
mkdir -p .harness/home .harness/run .harness/work .harness/hc
printf '%s\n' 'checks.disable=true' > .harness/home/.testcontainers.properties
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy before .harness/before
JL=(-Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8)
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE 'Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" HOME=\"$U/.harness/home\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 900; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
AL="-DargLine=-Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Duser.home=../../home"
guard "the build of before"
bg "cd .harness/before && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package" .harness/build-before.log
[ "$RE" = 0 ] || { tail -30 .harness/build-before.log | mask >&3; die ".harness/before did not build offline (exit $RE)"; }; offl .harness/build-before.log
echo "  built before offline WITH its tests, Docker-free (mvn -o clean package, the whole reactor: $($G -E '^\[INFO\] TiffinBox[A-Za-z ]* \.+ SUCCESS' .harness/build-before.log | sed -E 's/^\[INFO\] (TiffinBox[A-Za-z ]*) \.+ SUCCESS.*/\1/' | paste -sd, -); exit 0, Downloading/Downloaded from: 0) - the JVMs run this build's jar"
bg "cd .harness/before && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-before.log
[ "$RE" = 0 ] || die ".harness/before: the jar's extract failed"
XB="$U/.harness/before/$XD"; CPB="$XB/tiffinbox-web-1.0.0.jar:$XB/lib/*"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \"$CPB\" harness/src/probe23/Boom.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
echo "  the harness compiled (javac -nowarn -parameters) against before's extracted web jar and BOOT-INF/lib: probe23.Boom (the harness's failing route) - joined only by --spring.main.sources"
B() { echo "http://127.0.0.1:$1"; }
J=.harness/work
ALP='%m %U%q %s %b'
EXPO=--management.endpoints.web.exposure.include=health,prometheus,mappings,metrics   # the harness's exposure flag (21126 only)
CAP5=--tiffinbox.rate-limit.capacity=5                                                 # the harness's short capacity (the cap5 start only)
HIST=--management.metrics.distribution.percentiles-histogram.http.server.requests=true  # the harness's histogram flag (the hist start only)
BOOMSRC=--spring.main.sources=probe23.Boom                                             # the harness's failing route (21126 only)
# tb LABEL PORT [args]: TiffinBox (before's extracted jar), from its own run folder with a generated token (0600, never printed), H2 in
# memory (fresh per JVM); HJ=1 joins the harness's classes; waited for by its Started line; Tomcat's access log on.
tb() { local label=$1 port=$2 run=.harness/run/$1 i=0; shift 2
  guard "TiffinBox $label"
  for q in $NEVER; do [ "$(listeners $q)" = 0 ] || die "$q must stay free (TCP)"; done
  [ "$(listeners $port)" = 0 ] && [ -z "$(lsof -nP -iUDP:$port 2> /dev/null)" ] || die "$port is bound before $label"
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  local cp="$CPB"
  if [ -n "${HJ:-}" ]; then cp="$cp:$U/.harness/hc"; fi
  local ax=(--server.tomcat.accesslog.enabled=true "--server.tomcat.accesslog.directory=$U/$run" --server.tomcat.accesslog.prefix=access --server.tomcat.accesslog.suffix=.log --server.tomcat.accesslog.rotate=false --server.tomcat.accesslog.buffered=false "--server.tomcat.accesslog.pattern=$ALP")
  local main=com.tiffinbox.web.TiffinBoxServer
  echo "java -cp <before's jar>${HJ:+ + the harness} $main --tiffinbox.port=$port <the access log> $*" > "$run/cmd"
  (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java "${JL[@]}" -cp "$cp" $main --tiffinbox.port="$port" "${ax[@]}" "$@" > jvm.log 2>&1) &
  local p=$!; echo $p > "$run/pid"; PIDS="$PIDS $p"; MINE="${MINE:-} $port"
  while ! $G -q -E 'Started TiffinBox(App|Server) in' "$run/jvm.log" 2> /dev/null; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before its Started line"; }; i=$((i + 1)); [ $i -lt 1200 ] || die "$label: no Started line"; sleep 0.1; done
  echo "  $label up on $port (H2, before's jar, $( [ -n "${HJ:-}" ] && echo 'harness-joined' || echo 'harness-free'), the access log on) · $($G -oE 'rate limit: capacity [0-9]+ per refill period [A-Za-z0-9]+' "$run/jvm.log" | head -1)"; }
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
  local o e=0; o=$(python3 -I -B harness/chk23.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk23 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; [ -n "${DEVCAPS:-}${NOPIN:-}" ] && { echo "  (development: $nm's check failed, the run goes on)"; unpub="$unpub $nm"; } || die "$nm: its check failed (harness/chk23.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk23.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-12s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-12s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-12s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff .r-$nm.new against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }
surefire() { python3 -I - "$1" "$2" <<'PY'
import sys, glob, xml.etree.ElementTree as E
t = [0, 0, 0, 0]
for f in glob.glob(sys.argv[1] + "/TEST-*.xml"):
    r = E.parse(f).getroot()
    for i, k in enumerate(("tests", "failures", "errors", "skipped")):
        t[i] += int(r.get(k) or 0)
print("  %s | tests %d failures %d errors %d skipped %d" % ((sys.argv[2],) + tuple(t)))
for f in sorted(glob.glob(sys.argv[1] + "/TEST-*.xml")):
    r = E.parse(f).getroot()
    print("  %s | class %s | tests %s skipped %s" % (sys.argv[2], r.get("name").split(".")[-1], r.get("tests"), r.get("skipped")))
PY
}
reactor() { $G -E '^\[INFO\] TiffinBox[A-Za-z ]* \.+ (SUCCESS|FAILURE|SKIPPED)' "$1" | sed -E 's/ \.+ / ... /; s/\[ *[0-9.:]+ (s|min)\]//; s/^\[INFO\] /  reactor: /; s/ *$//'; }
YML=tiffinbox-web/src/main/resources/application.yaml
WEB=tiffinbox-web/src/main/java/com/tiffinbox/web
SPEC=tiffinbox-web/src/test/resources/openapi/tiffinbox.json
# send LABEL PORT FILE: the requests of FILE (one per line: METHOD URL [key=K|key=none] [inm=prev]), each with its status, its
# Content-Type, its header names, its body's md5 and its instance/detail; every request is also written to $J/sent-LABEL.txt
send() { python3 -I - "$2" "$3" "$J/sent-$1.txt" "$J/bodies-$1" <<'PY'
import sys, json, re, hashlib, http.client, os
port, f, sent, bd = int(sys.argv[1]), sys.argv[2], sys.argv[3], sys.argv[4]
os.makedirs(bd, exist_ok=True)
etag = None
with open(sent, "a") as S:
    for n, l in enumerate(x for x in open(f).read().splitlines() if x.strip() and not x.startswith("#")):
        p = l.split(); m, u, opts = p[0], p[1], p[2:]
        h = {}
        key = "none"
        for o in opts:
            if o.startswith("key="): key = o[4:]
            if o == "inm=prev" and etag: h["If-None-Match"] = etag
        if key != "none": h["Idempotency-Key"] = key
        c = http.client.HTTPConnection("127.0.0.1", port, timeout=10); c.request(m, u, headers=h); r = c.getresponse(); b = r.read()
        hh = {k.lower(): v for k, v in r.getheaders()}; c.close()
        if hh.get("etag"): etag = hh["etag"]
        open(os.path.join(bd, "r%02d.b" % (n + 1)), "wb").write(b)
        try:
            j = json.loads(b.decode("utf-8")) if b else {}
        except ValueError:
            j = {}
        inst = j.get("instance", "-") if isinstance(j, dict) else "-"
        det = j.get("detail", "-") if isinstance(j, dict) else "-"
        names = ",".join(sorted(k for k in hh if k not in ("date", "keep-alive", "connection")))
        S.write("%s %s %d key=%s\n" % (m, u, r.status, "yes" if key != "none" else "no"))
        print("  req | %02d %s %s%s%s -> %d %s · headers {%s} · allow %s · instance %s · detail %s" % (n + 1, m, u, " Idempotency-Key=<generated>" if key != "none" else "",
              " If-None-Match=<the first answer's tag>" if "If-None-Match" in h else "", r.status, hh.get("content-type", "none"), names, ", ".join(sorted(x.strip() for x in hh["allow"].split(","))) if "allow" in hh else "-", inst, det))
PY
}
# scrape LABEL PORT OUT: /actuator/prometheus read until two reads half a second apart agree on the _count rows outside /actuator/ (N9);
# OUT = the first read of the agreeing pair (raw, under .harness/ only)
scrapeto() { local port=$2 out=$3 a=$J/sc-$1-a.txt b=$J/sc-$1-b.txt i=0 st
  st=$($CURL --http1.1 -s -o $a -D $J/sc-$1.h -w '%{http_code}' "$(B $port)/actuator/prometheus")
  while :; do sleep 0.5; $CURL --http1.1 -s -o $b "$(B $port)/actuator/prometheus"
    if [ "$(python3 -I harness/scrape.py rows $a | $G -v ' /actuator/' | md5 -q)" = "$(python3 -I harness/scrape.py rows $b | $G -v ' /actuator/' | md5 -q)" ]; then break; fi
    i=$((i + 1)); [ $i -lt 20 ] || die "the scrape of $1 did not settle"; cp $b $a; done
  cp $a $out; must $out
  echo "  scrape $1 | GET /actuator/prometheus -> $st · Content-Type $(tr -d '\r' < $J/sc-$1.h | $G -i '^content-type:' | cut -d' ' -f2-) · Content-Length = the file's bytes: $( [ "$(tr -d '\r' < $J/sc-$1.h | $G -i '^content-length:' | awk '{ print $2 }')" = "$(wc -c < $out | tr -d ' ')" ] && echo yes || echo 'no (chunked)') · read until two reads half a second apart agreed on the rows outside /actuator/ ($((i + 2)) reads)"; }
rowsof() { python3 -I harness/scrape.py rows "$1" | sed "s/^/  $2 | /"; }
alog() { awk '{ print $1, $2, $3 }' .harness/run/$1/access*.log | sort | uniq -c | awk -v l="$1" '{ printf "  access %s | %s %s %s ×%d\n", l, $2, $3, $4, $1 }'; }

# ---- the captures ----------------------------------------------------------------------------------------------------------------------
c_advisory() {
  echo "== S9.36: the read filed for Section 4 (ADV4 = _research/docs-2026-11-27/advisories-s4probe, the S4 probe's dated act; not re-read: no network), before any capture"
  echo "  fetched-at $(head -1 "$ADV/fetched-at.txt" | cut -c1-10) (the hour masked) · the unit's evidence started $USTART · the batch day's other read (advisories/) fetched-at $(head -1 "$ADV/../advisories/fetched-at.txt" | cut -c1-10)"
  echo "  ~ run date $(date '+%Y-%m-%d') (the day rule is the start's, D15: a run of record on the start day or the day after it, the start's session resumed; a later day stops)"
  local d n=0 v=0 f h; for d in "$ADV" "$ADV/../advisories"; do n=0; v=0; while read -r h f; do n=$((n + 1)); [ "$(md5 -q "$d/$f")" = "$h" ] && v=$((v + 1)); done < <($G -vE '^\s*$' "$d/MD5SUMS.txt" | awk '$2 != "MD5SUMS.txt" { print $1, $2 }')
    echo "  $(basename "$d")/MD5SUMS.txt: $n lines, $v verified (its own line left out)"; done
  echo "  tomcat page md5 $(md5 -q "$ADV/tomcat-security-11.html") (the 11-24, 11-26 and 11-27 00:51 reads: a1a756d985225fb5143eefd9aae3183c)"
  local a; for a in spring-boot spring-web spring-context tomcat-embed-core jackson-databind micrometer-core micrometer-observation micrometer-registry-prometheus; do
    echo "  shipped | $a $(ls "$XB/lib" | $G -E "^$a-[0-9]" | sed -E "s/^$a-//; s/\.jar$//" | paste -sd, -)"; done
  python3 -I - "$ADV/osv-query.json" "$ADV/osv-result.json" <<'PY'
import json, sys
q = json.load(open(sys.argv[1]))["queries"]; r = json.load(open(sys.argv[2])).get("results", [])
print("  osv (second witness only, S2.8): %d coordinates queried, %d results, %d with vulns" % (len(q), len(r), sum(1 for x in r if x.get("vulns"))))
names = sorted(x.get("package", {}).get("name", "") + "@" + x.get("version", "") for x in q)
print("  osv | queried coordinates naming micrometer: %s" % (", ".join(n for n in names if "micrometer" in n) or "none (the unit adds no coordinate; Micrometer is a Boot-managed pin already in the tree)"))
PY
  echo "  the unit adds no artifact: BOOT-INF/lib names $(ls "$XB/lib" | wc -l | tr -d ' ') = U22's (the same tree through a link)"
  echo "  verdict: no pin affected; evidence may proceed (the read is the batch day's: fetched-at = the day the unit's evidence started); nothing else was read from the network"; }
c_before() {
  echo "== before (= after = ../c9-unit22/after, U22's frozen tree): the counters re-derived on it (R.527)"
  echo "  before | readlink before: $(readlink before) · readlink after: $(readlink after) · the two trees' hashes equal: $( [ "$(python3 -I harness/tree23.py before/)" = "$(python3 -I harness/tree23.py after/)" ] && echo yes || echo NO) ($(python3 -I harness/tree23.py before/))"
  echo "  before | BOOT-INF/lib names $(ls "$XB/lib" | wc -l | tr -d ' ') · modules $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' before/pom.xml | paste -sd' ' -)"
  echo "  before | the committed spec: $(python3 -I harness/ops9s3.py ops before/$SPEC | tail -1) · $(wc -c < before/$SPEC | tr -d ' ') B md5 $(md5 -q before/$SPEC)"
  echo "  before | the filters' orders off the sources: RateLimiting $($G -oE 'static final int ORDER = -?[0-9]+' before/$WEB/RateLimiting.java | awk '{ print $NF }') · IdempotencyKeys $($G -oE 'static final int ORDER = -?[0-9]+' before/$WEB/IdempotencyKeys.java | awk '{ print $NF }') · ConditionalGets $($G -oE 'static final int ORDER = -?[0-9]+' before/$WEB/ConditionalGets.java | awk '{ print $NF }')"
  echo "  before | the limiter's keys (application.yaml): $($G -A2 '^  rate-limit:' before/$YML | $G -E 'capacity|refill' | sed -E 's/^ +//' | paste -sd' ' -)"
  echo "  before | U22's values block (read, the expectation): $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit22/README.md | $G -oE '(web|client|its)=[0-9>-]+|census=[0-9/]+|spec=[0-9]+' | paste -sd' ' -)"; }
c_pin() {
  echo "== pin: Micrometer off the jar, the outcome rule off javap, the exposure, the greps (each with its planted control, R.566)"
  local mc mp; mc=$(ls "$XB/lib" | $G -E '^micrometer-core-[0-9]'); mp=$(ls "$XB/lib" | $G -E '^micrometer-registry-prometheus-[0-9]')
  echo "  pin | $mc Implementation-Version $(unzip -p "$XB/lib/$mc" META-INF/MANIFEST.MF | tr -d '\r' | sed -n 's/^Implementation-Version: //p') · $mp $(unzip -p "$XB/lib/$mp" META-INF/MANIFEST.MF | tr -d '\r' | sed -n 's/^Implementation-Version: //p') · the Prometheus client jars: $(ls "$XB/lib" | $G -E '^prometheus-metrics-' | sed -E 's/\.jar$//' | paste -sd' ' -)"
  echo "  pin | javap -p -c io.micrometer.core.instrument.binder.http.Outcome.forStatus (the rule, read off the jar, never an RFC reading):"
  javap -p -c -cp "$XB/lib/$mc" io.micrometer.core.instrument.binder.http.Outcome > $J/outcome.txt
  must $J/outcome.txt
  python3 -I - $J/outcome.txt <<'PY'
import re, sys
t = open(sys.argv[1]).read()
m = re.search(r"public static io\.micrometer\.core\.instrument\.binder\.http\.Outcome forStatus\(int\);\n    Code:\n(.*?)\n\n", t, re.S)
if not m: print("  pin | forStatus: NOT FOUND"); sys.exit(0)
ins = [l.strip() for l in m.group(1).splitlines()]
consts, rule, cur = [], [], []
for l in ins:
    c = re.search(r"(?:bipush|sipush|iconst_)\s*(-?\d+)?", l)
    f = re.search(r"getstatic .*// Field (\w+):", l)
    if c and ("bipush" in l or "sipush" in l): cur.append(int(c.group(1)))
    if f: rule.append((tuple(cur), f.group(1))); cur = []
for k, (b, o) in enumerate(rule):
    print("  pin | forStatus branch %d: compares against %s -> %s" % (k + 1, ",".join(str(x) for x in b) or "-", o))
PY
  echo "  pin | the exposure in application.yaml: $($G -A1 '^      exposure:' before/$YML | $G -oE 'include: .*')"
  local pv; pv=$(printf '%s\n' "$(cat before/$YML before/tiffinbox-web/src/main/resources/application-*.yaml 2> /dev/null)" | $G -cE 'percentiles-histogram|distribution' || true)
  printf 'management:\n  metrics:\n    distribution:\n      percentiles-histogram:\n        http.server.requests: true\n' > $J/hist-control.yaml
  echo "  pin | lines naming percentiles-histogram or distribution in before's application*.yaml: $pv · the same grep on a scratch yaml holding the key: $($G -cE 'percentiles-histogram' $J/hist-control.yaml) (the control)"
  local nr ni; nr=$($G -cE 'setPathPattern|findObservationContext' before/$WEB/RateLimitFilter.java || true); ni=$($G -cE 'setPathPattern|findObservationContext' before/$WEB/IdempotencyKeyFilter.java || true)
  cp before/$WEB/RateLimitFilter.java $J/rlf-control.java; printf '%s\n' '        ServerHttpObservationFilter.findObservationContext(req).ifPresent(c -> c.setPathPattern("/x"));' >> $J/rlf-control.java
  echo "  pin | lines naming setPathPattern or findObservationContext: RateLimitFilter.java $nr · IdempotencyKeyFilter.java $ni · a scratch copy of RateLimitFilter.java with one such line added: $($G -cE 'setPathPattern|findObservationContext' $J/rlf-control.java) (the control)"
  echo "  pin | the key filter's observe() and its call sites:"; $G -nE 'observe\(req, op\)|private static void observe|setPathPattern|An answer that never reaches' before/$WEB/IdempotencyKeyFilter.java | sed 's/^/    IdempotencyKeyFilter.java:/'
  echo "  pin | the key filter's guarded routes: $($G -oE 'new Guarded\("[A-Z]+", PathPatternParser\.defaultInstance\.parse\("[^"]+"\), (true|false)' before/$WEB/IdempotencyKeyFilter.java | sed -E 's/new Guarded\("([A-Z]+)", PathPatternParser\.defaultInstance\.parse\("([^"]+)"\), (true|false)/\1 \2 required=\3/' | paste -sd'; ' -)"
  QUIET=1 tb pin 21125 > /dev/null
  echo "  pin | GET /actuator on the default exposure (21125, harness-free) -> $($CURL --http1.1 -s -o $J/actuator.json -w '%{http_code}' "$(B 21125)/actuator") · links: $(python3 -I -c 'import json,sys; print(" ".join(sorted(json.load(open(sys.argv[1]))["_links"])))' $J/actuator.json)"
  echo "  pin | GET /actuator/metrics on the default exposure -> $($CURL --http1.1 -s -o /dev/null -w '%{http_code}' "$(B 21125)/actuator/metrics") · GET /actuator/mappings -> $($CURL --http1.1 -s -o /dev/null -w '%{http_code}' "$(B 21125)/actuator/mappings")"
  QUIET=1 tbstop pin 21125; }
census() { python3 -I - "$1/tiffinbox-web/src/main/java/com/tiffinbox/web" "$2" <<'PY'
import os, re, sys
d, side = sys.argv[1], sys.argv[2]
print("  census %s | rule (unit 15's, copied off unit 22's receipts): a class whose annotation lines include exactly @RestController or @Controller; its final modifier; @Profile(\"dev\") among those lines" % side)
rows, excl = [], []
for f in sorted(os.listdir(d)):
    ls = open(os.path.join(d, f), encoding="utf-8").read().splitlines()
    for i, l in enumerate(ls):
        m = re.match(r"^(public )?(final )?(abstract )?class (\w+)", l)
        if not m: continue
        ann, j = [], i - 1
        while j >= 0 and ls[j].strip().startswith("@"):
            ann.append(ls[j].strip()); j -= 1
        names = {re.match(r"@(\w+)", a).group(1) for a in ann}
        if names & {"RestController", "Controller"}:
            rows.append((m.group(4), bool(m.group(2)), '@Profile("dev")' in ann, f, i + 1))
        elif "RestControllerAdvice" in names:
            excl.append((m.group(4), f, i + 1))
        break
if not rows: print("  census %s | REFUSED: no controller found (an empty input)" % side); sys.exit(1)
for r in rows:
    print("  census %s | %-16s final %-3s dev-only %-3s %s:%d" % (side, r[0], "yes" if r[1] else "no", "yes" if r[2] else "no", r[3], r[4]))
for e in excl:
    print("  census %s | excluded by the rule: %s (%s:%d) - annotated @RestControllerAdvice" % ((side,) + e))
fd = sum(1 for r in rows if r[1] and not r[2]); nd = sum(1 for r in rows if not r[1] and r[2]); nf = sum(1 for r in rows if not r[1] and not r[2])
print("  census %s | controllers %d · final, default-run %d · not final, default-run %d · not final, dev-only %d · other %d" % (side, len(rows), fd, nf, nd, len(rows) - fd - nd - nf))
PY
}
c_census() { echo "== the controllers on before (R.527: derived on its own tree) - the unit adds no route"; census before before
  mkdir -p $J/empty/tiffinbox-web/src/main/java/com/tiffinbox/web
  echo "  census plant | the counter on an empty source folder: $(census $J/empty plant > /dev/null 2>&1; echo "exit $?") (1 = REFUSED)"; }
c_spec() { echo "== spec: the committed spec at the start (before's file) - this unit writes no spec byte"
  echo "  spec | $(wc -c < before/$SPEC | tr -d ' ') B · md5 $(md5 -q before/$SPEC) · $(python3 -I harness/ops9s3.py ops before/$SPEC | tail -1)"
  : > $J/empty.json; echo "  spec plant | ops9s3.py on an empty spec: $(python3 -I harness/ops9s3.py ops $J/empty.json > /dev/null 2>&1; echo "exit $?") (non-zero = refused)"; }
NINE=$J/nine.txt
jvma() {   # the nine's JVM (21120): the nine, scrape1, the second set, scrape2 - nothing else is ever sent to it
  python3 -I - "$PK4/captures/h45" > $J/nine-derivation.txt <<'PY'
import json, os, sys
d = sys.argv[1]
# the probe filed each answer's headers and body, not its request line (D4): each request is rebuilt from its status and its body
urls = {"a1": "GET /api/v1/customers/Ravi", "a2": "GET /api/v1/customers/Ravi", "a3": "GET /api/v1/customers/Nobody", "a4": "GET /api/v1/nosuch/route",
        "a5": "GET /customers/Ravi", "a6": "GET /api/v1/orders?size=2", "a7": "GET /api/v1/orders?bogus=1", "a8": "GET /api/v1/customers/Nobody/bill", "a9": "GET /nowhere"}
for k in sorted(urls):
    st = open(os.path.join(d, k + ".h"), encoding="utf-8").readline().split()[1]
    b = json.loads(open(os.path.join(d, k + ".b"), encoding="utf-8").read())
    why = "instance %s" % b["instance"] if isinstance(b, dict) and "instance" in b else ("items %d + next" % len(b["items"]) if isinstance(b, dict) and "items" in b else "name %s (the %s read)" % (b.get("name"), "old" if k == "a5" else "public"))
    print("  nine | %s %s <- the probe's %s: %s, %s" % (k, urls[k], k, st, why))
PY
  must $J/nine-derivation.txt
  sed -E 's/^  nine \| a[0-9] (GET [^ ]+) .*/\1/' $J/nine-derivation.txt > $NINE
  tb jvma 21120 > $J/jvma-up.txt
  send jvma 21120 $NINE > $J/nine-answers.txt; must $J/nine-answers.txt
  scrapeto s1 21120 $J/scrape1.raw > $J/scrape1-read.txt
  local k1; k1=$(openssl rand -hex 8)
  printf 'GET /api/v1/customers/Ravi\nGET /api/v1/customers/Ravi inm=prev\nDELETE /api/v1/customers/Ravi\nPOST /api/v1/customers/Ravi/pauses?days=2 key=%s\nPOST /api/v1/customers/Ravi/pauses?days=2 key=%s\nPOST /api/v1/customers/Ravi/pauses?days=2\n' "\"u23-$k1\"" "\"u23-$k1\"" > $J/second.txt
  send jvma2 21120 $J/second.txt > $J/second-answers.txt; must $J/second-answers.txt
  scrapeto s2 21120 $J/scrape2.raw > $J/scrape2-read.txt
  QUIET=1 tbstop jvma 21120 > $J/jvma-stop.txt
  cp .harness/run/jvma/jvm.log $J/jvma.log; }
c_scrape() { echo "== scrape: GET /actuator/prometheus as exposed (health,prometheus) on the nine's JVM (21120, harness-free, H2, the default capacity), after the nine and before anything else"
  cat $J/jvma-up.txt $J/scrape1-read.txt
  echo "  ~ families (python over the raw scrape: family · TYPE · series lines) - $(python3 -I harness/scrape.py families $J/scrape1.raw | wc -l | tr -d ' ') families:"
  python3 -I harness/scrape.py families $J/scrape1.raw | sed 's/^/  ~   /'
  echo "  families | the http_server_requests families: $(python3 -I harness/scrape.py families $J/scrape1.raw | $G '^http_server_requests' | sed -E 's/ · [0-9]+$//' | paste -sd';' -)"
  echo "  families | _bucket lines in scrape1: $(python3 -I harness/scrape.py buckets $J/scrape1.raw)"
  python3 -I harness/scrape.py mask $J/scrape1.raw > $J/scrape1.masked; must $J/scrape1.masked
  echo "  the masked scrape (the filed form): the http_server_requests lines whole, values of every line but _count masked <v>:"
  $G -E '^(# (HELP|TYPE) )?http_server_requests' $J/scrape1.masked | sed 's/^/    /'
  echo "  masked | digits left after a _sum or _max label set in the masked text: $($G -cE '_(sum|max)\{[^}]*\} [0-9]' $J/scrape1.masked || true) · in the raw text, more than 0: $( [ "$($G -cE '_(sum|max)\{[^}]*\} [0-9]' $J/scrape1.raw)" -gt 0 ] && echo yes || echo NO) (the raw scrape stays under .harness/)"; }
c_tags() { echo "== tags: the label keys of the _count rows on the nine and each key's values (python over scrape1)"
  python3 -I - $J/scrape1.raw <<'PY'
import re, sys, subprocess
rows = subprocess.run([sys.executable, "-I", "harness/scrape.py", "rows", sys.argv[1]], capture_output=True, text=True).stdout.splitlines()
keys = set(); vals = {}
for l in rows:
    m = re.match(r"^(\S+) (\S+) (\S+) (\S+) error=(\S+) exception=(\S+) count=\d+ keys=(\S+)$", l)
    if not m: print("  tags | UNPARSED %s" % l); continue
    ks = m.group(7).split(","); keys.update(ks)
    for k, v in zip(("method", "status", "outcome", "uri", "error", "exception"), m.groups()[:6]):
        if m.group(4).startswith("/actuator/"): continue
        vals.setdefault(k, set()).add(v)
print("  tags | keys %d: %s" % (len(keys), " ".join(sorted(keys))))
for k in sorted(vals): print("  tags | %s: %s" % (k, " ".join(sorted(vals[k]))))
PY
  echo "  tags | the error tag is not the E of RED: it reads none on every row above, the 404s and the 400 included"; }
c_known() { echo "== known: the nine of the probe's sequence, rebuilt (D4), sent in order to the nine's JVM (21120); their rows against the sent list, the access log and the probe's series.txt"
  cat $J/nine-derivation.txt; cat $J/nine-answers.txt
  rowsof $J/scrape1.raw scrape1
  python3 -I - $J/scrape1.raw "$SER" $J/sent-jvma.txt <<'PY'
import re, sys, subprocess, collections
rows = subprocess.run([sys.executable, "-I", "harness/scrape.py", "rows", sys.argv[1]], capture_output=True, text=True).stdout.splitlines()
mine = {}
act = []
for l in rows:
    m = re.match(r"^(\S+) (\S+) (\S+) (\S+) error=\S+ exception=\S+ count=(\d+)", l)
    if m.group(4).startswith("/actuator/"): act.append("%s %s %s" % (m.group(1), m.group(2), m.group(4))); continue
    mine[(m.group(1), m.group(2), m.group(3), m.group(4))] = int(m.group(5))
probe = {}
for l in open(sys.argv[2]).read().splitlines():
    lab = dict(re.findall(r'(\w+)="([^"]*)"', l)); c = int(l.split()[-1])
    probe[(lab["method"], lab["status"], lab["outcome"], lab["uri"])] = c
print("  known | rows outside /actuator/: %d · their counts' sum %d · the probe's series.txt rows %d, sum %d · equal (labels and counts): %s" % (len(mine), sum(mine.values()), len(probe), sum(probe.values()), "yes" if mine == probe else "NO"))
for k in sorted(set(mine) ^ set(probe)): print("  known | DIFFERS %s scrape %s probe %s" % (" ".join(k), mine.get(k), probe.get(k)))
print("  known | the actuator's own rows in scrape1: %s (the first read of the JVM: its own row is not in it yet)" % (", ".join(act) or "none"))
sent = collections.Counter()
for l in open(sys.argv[3]).read().splitlines():
    m, u, st, _ = l.split(); sent[(m, st)] += 1
sc = collections.Counter()
for k, v in mine.items(): sc[(k[0], k[1])] += v
print("  known | the sent list per (method, status) %s · the scrape's %s · equal: %s" % (dict(sorted(sent.items())), dict(sorted(sc.items())), "yes" if sent == sc else "NO"))
under = sum(v for k, v in mine.items() if k[3] == "/**"); tmpl = sum(v for k, v in mine.items() if k[3] != "/**")
print("  known | of the nine: under a route template %d · under /** (the pattern that catches every path) %d" % (tmpl, under))
old = mine.get(("GET", "200", "SUCCESS", "/customers/{name}"))
print("  known | old=GET 200 /customers/{name} count %s (the old read of Ravi: the row U24's gate reads)" % old)
PY
  alog jvma
  echo "== known, the second set (the same JVM, after scrape1): a GET, the conditional GET with the first answer's tag, a 405, the key filter's three"
  cat $J/second-answers.txt
  cat $J/scrape2-read.txt
  echo "  diff scrape1 -> scrape2 (python over the _count rows: added rows, changed counts):"
  python3 -I harness/scrape.py diff $J/scrape1.raw $J/scrape2.raw | sed 's/^/    /'
  echo "  known | the scrape's own row in scrape2: $(python3 -I harness/scrape.py rows $J/scrape2.raw | $G ' /actuator/prometheus ' | sed -E 's/ error=.* count=/ count /; s/ keys=.*//') (the reads of scrape1 and its agreement read)"
  $G -E 'REPLAY|KEY |rate limit: refused' $J/jvma.log | sed -E 's/^.*(REPLAY|KEY |rate limit)/  jvm log | \1/' | mask
  cat $J/jvma-stop.txt; }
c_404() { echo "== 404: the 404 rows of scrape1 by uri, and each 404 body's kind (the nine's answers)"
  python3 -I harness/scrape.py rows $J/scrape1.raw | awk '$2 == "404" { sub(/ error=.* count=/, " count "); sub(/ keys=.*/, ""); print "  404 | " $4 " " $5 " " $6 }'
  python3 -I - $NINE $J/bodies-jvma <<'PY'
import json, sys, os
reqs = [l for l in open(sys.argv[1]).read().splitlines() if l.strip()]
for i, r in enumerate(reqs):
    b = open(os.path.join(sys.argv[2], "r%02d.b" % (i + 1)), "rb").read()
    try: j = json.loads(b)
    except ValueError: j = {}
    if isinstance(j, dict) and j.get("status") == 404:
        kind = "TiffinBox's own problem (type %s)" % j.get("type") if j.get("type") else "Spring's static-resource problem (no type: about:blank)"
        print("  404 body | %s -> %s · title %s · detail %s" % (r, kind, j.get("title"), j.get("detail")))
PY
  echo "  404 | the 404 rows' uri values that are mapped route templates and the one that is the catch-all pattern: see the exercise's mappings.txt (the harness's exposure flag, 21126)"; }
c_unknown() { echo "== unknown (i): the limiter's refusal - the harness's short capacity (21125, $CAP5, a run flag, label cap=5), harness-free, H2"
  tb cap5 21125 "$CAP5"
  printf 'GET /api/v1/customers/Ravi\n%.0s' 1 2 3 4 5 6 7 > $J/cap5.txt
  send cap5 21125 $J/cap5.txt
  $CURL --http1.1 -s -D $J/cap5-429.h -o $J/cap5-429.b "$(B 21125)/api/v1/customers/Ravi" > /dev/null
  echo "  cap5 | an eighth read's headers (read back, the Retry-After value masked): $(tr -d '\r' < $J/cap5-429.h | $G -iE '^(HTTP/|content-type|retry-after)' | paste -sd' ' -) · body $(cat $J/cap5-429.b)"
  echo "GET /api/v1/customers/Ravi 429 key=no" >> $J/sent-cap5.txt
  scrapeto cap5 21125 $J/scrape-cap5.raw
  rowsof $J/scrape-cap5.raw cap5
  alog cap5
  echo "  cap5 | refusal lines in its log: $($G -c 'rate limit: refused' .harness/run/cap5/jvm.log)"
  QUIET=1 tbstop cap5 21125
  echo "== unknown (ii): the 405 on the nine's JVM (21120, the second set): its request, status and Allow, and its row in scrape2"
  $G -F ' DELETE ' $J/second-answers.txt
  python3 -I harness/scrape.py rows $J/scrape2.raw | $G '^DELETE ' | sed 's/^/  jvma | /'; }
c_filters() { echo "== filters: two filters, two answers - the key filter's replay and its missing-key refusal on the nine's JVM (21120), and the limiter's refusal (cap=5)"
  $G -F ' POST ' $J/second-answers.txt
  python3 -I harness/scrape.py rows $J/scrape2.raw | $G '^POST ' | sed 's/^/  jvma | /'
  local kl; kl=$($G -c 'KEY filter: phase 2' $J/jvma.log)
  echo "  jvm log | the key filter's start line (KEY filter: phase 2 ...): $kl · lines naming REPLAY: $($G -c 'REPLAY' $J/jvma.log || true)"
  echo "  filters | the replay's witnesses: its body = the first answer's byte for byte: $(cmp -s $J/bodies-jvma2/r04.b $J/bodies-jvma2/r05.b && echo yes || echo NO) · the key filter's REPLAY line is logged at DEBUG (IdempotencyKeyFilter.log: $($G -c 'System.Logger.Level.DEBUG, "KEY "' before/$WEB/IdempotencyKeyFilter.java)), not on the default run: $($G -c 'REPLAY' $J/jvma.log) lines"
  python3 -I harness/scrape.py rows $J/scrape-cap5.raw | $G ' 429 ' | sed 's/^/  cap5 | /'
  echo "  filters | rows with uri UNKNOWN on the nine's JVM after the key filter's three: $(python3 -I harness/scrape.py rows $J/scrape2.raw | $G -c ' UNKNOWN ' || true) ($(python3 -I harness/scrape.py rows $J/scrape2.raw | $G ' UNKNOWN ' | awk '{ print $1, $2 }' | paste -sd, -))"; }
c_errors() { echo "== errors: E of RED computed off outcome (CLIENT_ERROR + SERVER_ERROR), never off the error tag"
  python3 -I - $J/scrape2.raw $J/scrape-cap5.raw <<'PY'
import re, sys, subprocess
for f, lab in ((sys.argv[1], "jvma scrape2"), (sys.argv[2], "cap5")):
    rows = subprocess.run([sys.executable, "-I", "harness/scrape.py", "rows", f], capture_output=True, text=True).stdout.splitlines()
    inn, out = [], []
    for l in rows:
        m = re.match(r"^(\S+) (\S+) (\S+) (\S+) error=(\S+) exception=(\S+) count=(\d+)", l)
        if m.group(4).startswith("/actuator/"): continue
        (inn if m.group(3) in ("CLIENT_ERROR", "SERVER_ERROR") else out).append(m)
    for m in inn: print("  errors %s | in  %s %s %s %s · error=%s · count %s" % (lab, m.group(1), m.group(2), m.group(3), m.group(4), m.group(5), m.group(7)))
    for m in out: print("  errors %s | out %s %s %s %s · error=%s · count %s" % (lab, m.group(1), m.group(2), m.group(3), m.group(4), m.group(5), m.group(7)))
    print("  errors %s | E (the sum of the in rows' counts) %d · rows in %d · rows out %d · an error tag other than none: %d" % (lab, sum(int(m.group(7)) for m in inn), len(inn), len(out), sum(1 for m in inn + out if m.group(5) != "none")))
PY
  echo "== errors, the SERVER_ERROR half: the harness's failing route (21126, harness-joined: $BOOMSRC, with the harness's exposure flag)"
  HJ=1 tb boom 21126 "$BOOMSRC" "$EXPO"
  local w=0; while ! $G -q '^U23 harness: ' .harness/run/boom/jvm.log; do w=$((w + 1)); [ $w -lt 100 ] || break; sleep 0.1; done
  echo "  boom | the harness's line: $($G -c '^U23 harness: ' .harness/run/boom/jvm.log) ($($G '^U23 harness: ' .harness/run/boom/jvm.log | head -1))"
  printf 'GET /probe23/boom\nGET /api/v1/customers/Ravi\n' > $J/boom.txt
  send boom 21126 $J/boom.txt > $J/boom-answers.txt; must $J/boom-answers.txt; cat $J/boom-answers.txt
  echo "  boom | the shipped route on the harness-joined JVM against the nine's JVM (N3): status $(sed -n 2p $J/sent-boom.txt | awk '{ print $3 }') vs $(sed -n 1p $J/sent-jvma.txt | awk '{ print $3 }') · body md5 equal: $(cmp -s $J/bodies-boom/r02.b $J/bodies-jvma/r01.b && echo yes || echo NO) · header names equal: $( [ "$($G -F ' 02 GET ' $J/boom-answers.txt | $G -oE 'headers \{[^}]*\}')" = "$($G -F ' 01 GET ' $J/nine-answers.txt | $G -oE 'headers \{[^}]*\}')" ] && echo yes || echo NO)"
  $CURL --http1.1 -s -o $J/mappings.json "$(B 21126)/actuator/mappings"; must $J/mappings.json
  $CURL --http1.1 -s -o $J/metrics.json -w '  boom | GET /actuator/metrics/http.server.requests (the harness'"'"'s exposure flag) -> %{http_code}\n' "$(B 21126)/actuator/metrics/http.server.requests"
  python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print("  boom | its availableTags: " + " · ".join("%s=%s" % (t["tag"], ",".join(sorted(t["values"]))) for t in sorted(d.get("availableTags", []), key=lambda t: t["tag"])))' $J/metrics.json
  python3 -I - $J/mappings.json > $J/mappings.txt <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
routes, res = set(), set()
for ctx in d["contexts"].values():
    for m in ctx["mappings"]["dispatcherServlets"].get("dispatcherServlet", []):
        det = m.get("details") or {}
        rc = det.get("requestMappingConditions")
        if det.get("handlerMethod") and rc:
            for p in rc.get("patterns", []): routes.add(p)
        elif "ResourceHttpRequestHandler" in m.get("handler", "") or "ResourceHttpRequestHandler" in str(det):
            res.add(m.get("predicate"))
for p in sorted(routes): print("route " + p)
for p in sorted(res): print("resource " + p)
PY
  must $J/mappings.txt
  echo "  boom | mappings (the harness's exposure flag): $($G -c '^route ' $J/mappings.txt) route patterns of handler methods · resource handlers: $($G '^resource ' $J/mappings.txt | cut -d' ' -f2- | paste -sd' ' -) · /probe23/boom among the routes: $($G -cxF 'route /probe23/boom' $J/mappings.txt) (the harness's)"
  $G -v '^route /probe23/' $J/mappings.txt > $J/mappings-shipped.txt
  echo "  boom | exercise/mappings.txt = this read without the harness's route: $(cmp -s $J/mappings-shipped.txt exercise/mappings.txt && echo yes || echo NO)"
  scrapeto boom 21126 $J/scrape-boom.raw
  python3 -I harness/scrape.py rows $J/scrape-boom.raw | $G -E ' /probe23/| 5[0-9][0-9] ' | sed 's/^/  boom | /'
  QUIET=1 tbstop boom 21126; }
c_duration() { echo "== duration: the duration-bearing families by NAME only (scrape1 of the nine's JVM) - no value is printed (R.552)"
  python3 -I harness/scrape.py families $J/scrape1.raw | $G '^http_server_requests' | sed -E 's/ · [0-9]+$//; s/^/  duration | family /'
  $G -E '^http_server_requests_seconds_(sum|max)\{' $J/scrape1.masked | head -2 | sed 's/^/  duration | series name (value masked) /'
  printf '%s\n' 'http_server_requests_seconds_bucket{le="0.1",method="GET",status="200",uri="/x"} 1' > $J/bucket-plant.txt
  cat $J/scrape1.raw >> $J/bucket-plant.txt
  echo "  duration | _bucket lines in scrape1: $(python3 -I harness/scrape.py buckets $J/scrape1.raw) · the same count on scrape1 with one planted _bucket line: $(python3 -I harness/scrape.py buckets $J/bucket-plant.txt) (the control, R.566)"
  echo "== duration: the harness's histogram flag (21125, $HIST, a run flag, label hist) - the positive control for 0 by default"
  tb hist 21125 "$HIST"
  printf 'GET /api/v1/customers/Ravi\n' > $J/hist.txt; send hist 21125 $J/hist.txt
  scrapeto hist 21125 $J/scrape-hist.raw
  echo "  hist | _bucket lines with the harness's histogram flag: more than 0: $( [ "$(python3 -I harness/scrape.py buckets $J/scrape-hist.raw)" -gt 0 ] && echo yes || echo NO) (the count and the values are not printed)"
  QUIET=1 tbstop hist 21125
  echo "  duration | handed to the course Ship It & Observe by title: the third letter, where it lives and how to read it"; }
c_api() { echo "== api: every GET of the committed spec's /api/v1/ paths (filled: name Ravi, id 1; the run id zeros; the signed link expired) and two old refusals, two passes on one JVM (21125, H2, the default capacity) - not a witness for the scrape (it sends nothing to /actuator/prometheus)"
  tb api 21125 > /dev/null
  local k; for k in 1 2; do python3 -I - 21125 before/$SPEC > $J/api-$k.txt <<'PY'
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
    fr = "chunked" if h.get("transfer-encoding", "").lower() == "chunked" else ("Content-Length" if "content-length" in h else "none")
    et = h.get("etag")
    et = "none" if et is None else (et if re.fullmatch(r'"v\d+"', et) else "<shallow tag>")
    hs = ",".join(sorted(k for k in h if k not in ("date", "keep-alive", "connection", "content-length", "transfer-encoding")))
    print("  api | GET %s -> %s %s · headers {%s} · etag %s · framing %s · body %s" % (u, st, h.get("content-type"), hs, et, fr, hashlib.md5(mask(b).encode()).hexdigest()[:12]))
PY
    must $J/api-$k.txt; done
  sed 's/^  api |/  api pass 1 |/' $J/api-1.txt
  echo "  api | pass 1 -> pass 2: $(cmp -s $J/api-1.txt $J/api-2.txt && echo identical || echo DIFFER) ($(wc -l < $J/api-1.txt | tr -d ' ') requests each)"
  echo "  api | U22's census (its values block): $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit22/README.md | $G -oE '^api: .*')"
  tbstop api 21125; }
c_seven() {
  echo "== the seven (c5-unit11/curlset.sh), its own JVM (21125), H2, the default capacity - not a witness for the scrape: none of the seven reads /actuator/prometheus"
  echo "  expected $S466"
  local i=0
  tb seven 21125 > /dev/null
  sh $CURLSET 21125 .harness/run/seven/secrets/tiffinbox/shutdown-token > $J/seven.txt 2>&1
  must $J/seven.txt
  while kill -0 "$(cat .harness/run/seven/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 60 ] || break; sleep 0.05; done
  QUIET=1 tbstop seven 21125
  echo "  before: the seven $(md5 -q $J/seven.txt) ($(wc -l < $J/seven.txt | tr -d ' ') lines)"; }
eval "$(sed -n '/^oldsurface2() {/,/^  rm -f "\$t".\*; }$/p' ../c9-unit21/receipts.sh)"
type oldsurface2 > /dev/null 2>&1 || die "oldsurface2 could not be read off ../c9-unit21/receipts.sh"
c_surface() {
  echo "== the old surface by count (U18's reader, sourced off U21's receipts byte for byte), its own JVM (21125), H2, the default capacity - not a witness for the scrape"
  echo "  expected $U4SURF · the reader's md5 $(sed -n '/^oldsurface2() {/,/^  rm -f "\$t".\*; }$/p' ../c9-unit21/receipts.sh | md5 -q)"
  tb surface 21125 > /dev/null
  oldsurface2 21125 $J/surface.txt
  must $J/surface.txt
  QUIET=1 tbstop surface 21125
  echo "  before: the old surface $(md5 -q $J/surface.txt) ($($G -c '^== ' $J/surface.txt) requests, $(wc -l < $J/surface.txt | tr -d ' ') lines)"
  tb surfplant 21125 --spring.mvc.problemdetails.enabled=false > /dev/null
  oldsurface2 21125 $J/surface-plant.txt
  QUIET=1 tbstop surfplant 21125 > /dev/null
  echo "  surface plant | the S9.14 slot: problem details off (a run flag on a scratch JVM): the old surface moved: $(cmp -s $J/surface.txt $J/surface-plant.txt && echo NO || echo yes) (the check can fail)"
  echo "  ~ surface plant | its md5 this run $(md5 -q $J/surface-plant.txt | cut -c1-8) (its non-problem bodies carry the run's own values)"; }
c_inert() { echo "== inert: the exact list of requests this run sent to a TiffinBox JVM with an Idempotency-Key (every sent list of the receipts' own sender)"
  local f; for f in $J/sent-*.txt; do echo "  inert | $(basename $f .txt | sed 's/^sent-//'): requests $(wc -l < $f | tr -d ' ') · with a key $($G -c ' key=yes$' $f || true)"; done
  $G -h ' key=yes$' $J/sent-*.txt | sed 's/^/  inert | keyed: /'
  echo "  inert | the seven (curlset.sh) and the old surface name no Idempotency-Key: $($G -ci 'idempotency' $CURLSET || true) · $(sed -n '/^oldsurface2() {/,/^  rm -f "\$t".\*; }$/p' ../c9-unit21/receipts.sh | $G -ci 'idempotency' || true)"
  cp $J/sent-cap5.txt $J/inert-plant.txt; echo "GET /api/v1/customers/Ravi 200 key=yes" >> $J/inert-plant.txt
  echo "  inert plant | a scratch sent list with one keyed request added outside the key filter's leg: keyed $($G -c ' key=yes$' $J/inert-plant.txt)"; }
c_tests() {
  echo "== tests: before's own build (mvn -o clean package, the whole reactor, its tests on, Docker-free - the run's one build); no verify"
  reactor .harness/build-before.log
  for p in web client; do surefire .harness/before/tiffinbox-$p/target/surefire-reports "package | tiffinbox-$p"; done
  echo "  refusal lines of the limiter in the build log (the suite at the default; RateLimitFilterTest's own context refuses by design): outside RateLimitFilterTest $(awk '/\[INFO\] Running com\./ { c = $NF } /rate limit: refused/ && c !~ /RateLimitFilterTest/ { n++ } END { print n + 0 }' .harness/build-before.log)"
  echo "  tests | no test is added (no route; no test pins a scrape) · no verify: no anchor change, no IT reaches a path this unit touches (U22's tests leg ran the 14 ITs on this tree)"
  echo "  downloads across the builds: $(cat .harness/build-before.log | $G -cE 'Download(ing|ed) from ' || true)"; }
c_harness() {
  echo "== harness: the folder's files and the instruments (copied byte-equal, adapted with a named diff, new)"
  echo "  harness/: $(ls harness | paste -sd' ' -) · harness/src: $(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -) · exercise/: $(ls exercise | $G -vxE '\.servers|\.work' | paste -sd' ' -)"
  echo "  copied | dur9.py md5 $(md5 -q harness/dur9.py) · ops9s3.py md5 $(md5 -q harness/ops9s3.py) · norm.py md5 $(md5 -q harness/norm.py) (unit 22's)"
  echo "  adapted | tree23.py from tree22.py: $(diff ../c9-unit22/harness/tree22.py harness/tree23.py | $G -c '^[<>]') lines (the docstring only) · s923.py from s922.py: lines removed $(diff ../c9-unit22/harness/s922.py harness/s923.py | $G -c '^<'), added $(diff ../c9-unit22/harness/s922.py harness/s923.py | $G -c '^>'), the diff's md5 $(diff ../c9-unit22/harness/s922.py harness/s923.py | md5 -q)"
  echo "  new | chk23.py md5 $(md5 -q harness/chk23.py) · scrape.py $(md5 -q harness/scrape.py) · Boom.java $(md5 -q harness/src/probe23/Boom.java) · exercise: run.sh $(md5 -q exercise/run.sh) · check.sh $(md5 -q exercise/check.sh) · apply.sh $(md5 -q exercise/apply.sh)"
  echo "  not used (absent from harness/): $NOTUSED - $(for f in $NOTUSED; do find harness -name $f; done | wc -l | tr -d ' ') present"
  echo "  Boom named in the tree's jar entries: $(unzip -l .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | $G -c 'probe23' || true) · in before's files: $($G -rl 'probe23' before/ | wc -l | tr -d ' ')"
  echo "  static (i), as written: output md5 $STMD5"
  local SC=.harness/static-copy; rm -rf $SC; mkdir -p $SC/u $SC/c9-unit22; cp -R harness exercise README.md receipts.sh receipts.md5 $SC/u/; ln -s "$UP/c9-unit22/after" $SC/c9-unit22/after; ln -s ../c9-unit22/after $SC/u/before; ln -s ../c9-unit22/after $SC/u/after
  copy before $SC/c9-""tiffinbox; printf 'x' >> $SC/c9-""tiffinbox/compose.yaml
  local s2; s2=$(cd $SC/u && REPO="$UP" C9R="$C9R" python3 -I -B harness/chk23.py static after before 2>&1 | md5 -q)
  echo "  static (ii) beside a scratch copy of the anchor with a byte appended to its compose.yaml (the real anchor untouched): output md5 = (i): $( [ "$s2" = "$STMD5" ] && echo yes || echo NO)"
  echo "  ~ static (iii) of this run: the anchor folder beside this unit's folder: $( [ -d "../c9-""tiffinbox" ] && echo 'present (runs 1, 2: static (i) is the as-written run)' || echo 'MOVED ASIDE (the sealed clone, run 3: static (i) of this run is (iii))')"
  echo "  static plants (flag 19): a static assertion reading the live anchor (its folder name assembled) -> $(python3 -I -B harness/chk23.py static-plant live > /dev/null 2>&1; echo "exit $?") · the same path from two pieces -> $(python3 -I -B harness/chk23.py static-plant pieces > /dev/null 2>&1; echo "exit $?")"
  printf '%s\n' 'paste a b | sed -E '"'"'1~2s/^/x/'"'"' > $J/side.txt' > $J/gnu-plant.sh   # GNUFORM (the plant)
  echo "  R.564 plant: a GNU-only sed line counted by the receipts' own GNU-form grep: $($G -cE "sed [^|]*[0-9]~[0-9]|sed -i( |$)|sed -i ''" $J/gnu-plant.sh || true) (1 = caught)"   # GNUFORM
  echo "  the frozen receipts that read the live anchor's poms (the orchestrator's flag-31 class, read, not edited): $(for f in ../c9-unit10/receipts.sh:611 ../c9-unit13/receipts.sh:334 ../c9-unit15/receipts.sh:396; do n=${f##*:}; sed -n "${n}p" "${f%%:*}" | $G -cF "c9-""tiffinbox" | sed "s#^#${f#../}=#"; done | paste -sd' ' -) (1 = the line names the live anchor)"
  echo "  the derived changed list (no anchor change): git diff --stat against $H22 over the anchor, c9-unit01..22 and every pom: $GD0 lines - the plant 'a restored die on a changed path' has no path to fire on"
  echo "  ~ the pathspec of this run's git diff: ${ANCP:-the anchor moved aside, left out (run 3)} c9-unit01..22 *pom.xml"; }
c_exercise() { local sh o
  rm -rf exercise/.servers exercise/.work; mkdir -p exercise/.work
  for sh in bash zsh; do
    guard "the exercise, $sh"
    local envs=(env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21128 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock)
    mkdir -p exercise/.work/$sh
    if [ $sh = bash ]; then o=$(cd exercise && "${envs[@]}" bash -c 'sh run.sh .work/bash > .work/bash/run.out 2>&1; echo "run exit $?"; sh check.sh .work/bash/answer.txt; echo "broken: check exit $?"; sh apply.sh .work/bash; sh check.sh .work/bash/answer.txt; echo "solved: check exit $?"' 2>&1)
    else o=$(cd exercise && "${envs[@]}" /bin/zsh -f -c 'sh run.sh .work/zsh > .work/zsh/run.out 2>&1; echo "run exit $?"; sh check.sh .work/zsh/answer.txt; echo "broken: check exit $?"; sh apply.sh .work/zsh; sh check.sh .work/zsh/answer.txt; echo "solved: check exit $?"' 2>&1); fi
    printf '%s\n' "$o" | sed "s/^/  $sh | /"
    $G -E '^(built|up|sent|404 rows|stopped)' exercise/.work/$sh/run.out | sed "s/^/  $sh run | /"
    [ "$(listeners 21128)" = 0 ] || die "the exercise left something listening on 21128"; done
  [ ! -f exercise/.servers/build.log ] || offl exercise/.servers/build.log
  echo "  the two shells' scrapes, 404 rows: $(cmp -s <($G ' status="404"' exercise/.work/bash/scrape.txt) <($G ' status="404"' exercise/.work/zsh/scrape.txt) && echo equal || echo DIFFER)"
  echo "  solved = SOLUTION.md's answer block: $(cmp -s exercise/.work/bash/answer.txt <(awk '/^The answer/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' exercise/SOLUTION.md) && echo yes || echo NO)"
  if [ "$RUNNO" = 1 ] || [ "$RUNNO" = 0 ]; then
    python3 -I - exercise/.work/bash/answer.txt exercise/.work <<'PY'
import sys, os
key = open(sys.argv[1]).read().splitlines(); d = sys.argv[2]
rows = [l for l in key if not l.startswith("not a route:")]
import re
tot = {}
for l in open(os.path.join(os.path.dirname(sys.argv[1]), "scrape.txt")).read().splitlines():
    if l.startswith("http_server_requests_seconds_count{") and 'uri="/actuator/' not in l:
        u = re.search(r'uri="([^"]*)"', l).group(1); tot[u] = tot.get(u, 0) + int(float(l.rsplit(" ", 1)[1]))
var = {"none": [], "all": ["%s %d" % (u, tot[u]) for u in sorted(tot)] + [l for l in key if l.startswith("not a route:")], "template": rows + ["not a route: /api/v1/customers/{name}"],
       "unknown": rows + ["not a route: UNKNOWN"], "short": rows[1:] + [l for l in key if l.startswith("not a route:")]}
for k, v in var.items():
    os.makedirs(os.path.join(d, k), exist_ok=True); open(os.path.join(d, k, "answer.txt"), "w").write("".join(x + "\n" for x in v))
PY
    local v; for v in none all template unknown short; do cp exercise/.work/bash/scrape.txt exercise/.work/$v/; o=$(cd exercise && sh check.sh .work/$v/answer.txt 2>&1; echo "check exit $?"); printf '%s\n' "$o" | sed "s/^/  ~ $v bash | /"; done; fi
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'
  rm -rf exercise/.servers exercise/.work; }
c_title() {
  local TS; TS=$(python3 -I -B harness/chk23.py title-line)
  echo "== the title for search (S4B's Unit 23, printed, not edited - the copy step's): \"$TS\" ($(python3 -I -c 'import sys; print(len(sys.argv[1]))' "$TS") characters by len())"
  echo "  the registry: TITLES[\"23\"] = $(sed -n 's/^ *"23": *"\([^"]*\)".*/\1/p' "$J9" | head -1) · lines of java*_series.py naming http.server, per-endpoint or prometheus: $(cat "$HOME"/Desktop/PromptVidya-Automation/java*_series.py | $G -ciE 'http\.server|per-endpoint|prometheus' || true)"; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures${DEVCAPS:+ (DEVELOPMENT: only $DEVCAPS - not a run of record)}"
cap advisory c_advisory
cap before c_before
cap pin c_pin
cap census c_census
cap spec c_spec
jvma
cap scrape c_scrape
cap tags c_tags
cap known c_known
cap 404 c_404
cap unknown c_unknown
cap filters c_filters
cap errors c_errors
cap duration c_duration
cap api c_api
cap seven c_seven
cap surface c_surface
cap inert c_inert
cap tests c_tests
cap harness c_harness
cap exercise c_exercise
cap title c_title
echo "== plants (each made to FAIL first on a copy of this run's capture; harness/chk23.py plants)"
if [ -z "${DEVCAPS:-}" ]; then
PL=$(python3 -I -B harness/chk23.py plants .) || die "a plant was not caught: $(printf '%s\n' "$PL" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$PL" | $G '^ok ' | sed 's/^ok /  /'
PLV=$(printf '%s\n' "$PL" | sed -n 's/^VALUES //p')
fi

# ---- the end: the sweep, the values, the published hashes -------------------------------------------------------------------------------
[ -z "$(echo $PIDS)" ] || die "a JVM of this run is still running: $PIDS"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
[ -z "$(dk ps -aq --filter name=^/c9u23-)" ] || die "a c9u23-* container is left"
NI1=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' '); CT1=$(dk ps -a --format '{{.Names}}' 2> /dev/null | sort | paste -sd, -)
[ "$NI1" = "$NI0" ] && [ "$VOL1" = "$VOL0" ] && [ "$CT1" = "$CT0" ] || die "R.322: images $NI0 -> $NI1, volumes $VOL0 -> $VOL1, containers [$CT0] -> [$CT1]"
AD1=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true); [ "$AD1" = "$AD" ] || die "the anchor moved during the run"
GD1=$(git -C "$UP" diff --stat $H22 -- $ANCP c9-unit01 c9-unit02 c9-unit03 c9-unit04 c9-unit05 c9-unit06 c9-unit07 c9-unit08 c9-unit09 c9-unit10 c9-unit11 c9-unit12 c9-unit13 c9-unit14 c9-unit15 c9-unit16 c9-unit17 c9-unit18 c9-unit19 c9-unit20 c9-unit21 c9-unit22 '*pom.xml' $ANX | wc -l | tr -d ' ')   # GITDIFF
[ "$GD1" = "$GD0" ] || die "git diff --stat against $H22 moved during the run ($GD0 -> $GD1 lines)"
pin before-tree before; pin after-tree after
[ "$(wc -c < before/$SPEC | tr -d ' ') $(md5 -q before/$SPEC)" = "36164 aa8cb98f4ff16d75d073026f0c618328" ] || die "the committed spec moved"
MDB=$(find . ../c9-tiffinbox -name '*.mv.db' -not -path './.harness/*' 2> /dev/null | wc -l | tr -d ' ')
[ "$MDB" = 0 ] || die "an H2 file outside .harness/"
[ -z "$(ls -A exercise | $G -v -xE 'README.md|SOLUTION.md|apply.sh|check.sh|mappings.txt|requests.txt|run.sh')" ] || die "the exercise left a file in exercise/"
VALS="$VALS
plants: $PLV
build: seed_files=$NF0 seed_bytes=$NB0 central_only=$CO"
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
[ -n "${DEVCAPS:-}" ] && { echo "c9-unit23: DEVELOPMENT run ($DEVCAPS) - nothing published"; exit 2; }
VO=$(python3 -I -B harness/chk23.py values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; [ -n "${NOPIN:-}" ] || die "README.md's values block is not this run's"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM of this run, ports free, no container started (images $NI0 -> $NI1, volumes $VOL0 -> $VOL1, containers as at the start) · the anchor against after/ as at the start · git diff --stat as at the start ($GD1 lines) · the tree pins · the spec · *.mv.db outside .harness 0"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit23: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit23: $NCAPS captures checked; every capture = published ($NCAPS)"
