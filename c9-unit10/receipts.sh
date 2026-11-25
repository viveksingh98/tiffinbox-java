#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 10 "Code Generation From the Contract" - this unit's receipts. Course 9's SEVENTH anchor change, Section 2's fourth, and
# the anchor's first new module: before is a link to ../c9-unit09/after (U09's after: the documented errors, the committed file 20,306 B);
# after/ is a frozen copy of ../c9-tiffinbox after this unit's change - the parent's <modules> gains tiffinbox-client and one property
# (openapi-generator.version 7.27.0); the new module has no src/main: openapi-generator (generator spring, library spring-http-interface)
# writes it at generate-sources from the committed file, read in place; one test binds the generated interface to MockRestServiceServer.
# The harness (never in the jar or the module): the statement and request witnesses, Routes, the ShallowEtag plant - copied from U09's
# harness; unit 10's second client (probe.u10.U10Probe, /probe/u10/**) and the runner probe.u10.Caller, which drives the GENERATED
# interfaces (compiled into the client's jar) against a running TiffinBox with a RestClient it builds itself; BLUE's specwire9.py and
# loc9.py, byte-equal. Every line they print is "the harness's". No browser in this unit; no PostgreSQL capture (callpg dropped: H2 only).
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5):
#   tests     the whole reactor at package (three modules), its Docker-free twin, verify (the ITs), the web-only form; 49 + the client's
#   census    /actuator/mappings on after/ (one flag start): 17 handlers -> 13 operations; the generated methods beside them; the jar
#   modules   the parent's <modules> on before and after/; which modules each anchor commit touched (git, no JVM)
#   generate  the generator's run alone (no application started), its input's identity, FILES, the masked sources' md5; two mirrors
#   jackson   the client's resolved dependencies, the generated imports, the compiled models' constant pools, the web jar's 157
#   committed the committed file unchanged, = the served document, OpenApiSpecTest in the package run
#   call      the generated one(Ravi) against after/ on 20990 (H2, no harness), curl beside; Nobody; HttpClient 5 on the runner's class path
#   pause     the generated pause call (no key parameter) -> the wire's 400, its body against the spec's example; the key table
#   mock      the package run's mock test lines; the same interface bytes as call's; three plants (scratch mirrors)
#   default   the generator's default library (java/restclient) on a scratch mirror only: Jackson 2, the removal warnings, its counts
#   counts    loc9.py over four roots: the shipped generated sources, the loser's, the web module's own, an empty root (refused)
#   location  the generated create and pause calls' return types; one create through the generated call beside curl's
#   diff      specwire9.py (a) and (b) on H2, (b) with THIS run's generated sources
#   moved     U09's nineteen requests on before and after/; the web jar's md5 before and after
#   seven     c5-unit11/curlset.sh on before and after/ (each its own JVM)
#   surface   the old surface by count on before and after/, and the S9.14 plant
#   inert     the key header and the key table across every capture of the run
#   exercise  break.sh, check.sh on the broken copy, the solution (apply.sh) and the refused "solutions", bash and zsh -f, H2
# Ports (U10's band, 20990-20999): 20990 after/ on H2, no harness · 20993 the flag start, the harness-joined JVMs (pause's companion,
# location, diff), each its own start · 20994 the S9.14 plant · 20996 before · 20997 the scratch mirrors' starts and the wrong-body stub ·
# 20998 the exercise · 20991, 20992, 20995, 20999 never bound. During mvn verify only: 21280-21284, one per IT. Every store on
# 127.0.0.1; every curl --noproxy '*'. The key header is sent only by specwire9.py's pause-key request and the printed alternative (KEYH).
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
C9R=${C9R:-"/Users/$ME/Downloads/Youtube Content/LearnProgrammingWithVivek/rest-apis-done-right"}   # the course's folder (briefs, research)
SEED=${SEED:-"$C9R/_research/m2-seed-c9-s2"}   # the course's Section 2 seed
PK="$C9R/_research/s2-probe-2026-11-24"; BK="$C9R/_research/s2-blue-2026-11-24"; ADV="$C9R/_research/docs-2026-11-24/advisories"
S2B="$C9R/_briefs/UNIT-BRIEFS-S2-CONTRACTS.md"
export C9R
RUNNO=${RUNNO:-0}                                     # the run of record's number (1, 2, 3): specwire9.py's BLUE_RUN; 0 = development
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
PIDS=""; TC0=""; INTR=""; mpid=""; pollpid=""; STUB=""
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "probe.u10.Caller") || index($0, "curlset.sh") || index($0, "check.sh") || index($0, "apply.sh") || index($0, "Call.java") || index($0, "stub10") || $3 ~ /(^|\/)javac$/) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
tcrm() { local c n=0 i=0; [ -n "$TC0" ] || return 0
  while [ $i -lt 10 ]; do
    for c in $(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null); do dk rm -fv "$c" > /dev/null 2>&1 && n=$((n + 1)); done
    [ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] && break; sleep 0.5; i=$((i + 1)); done
  [ "$n" = 0 ] || echo "  the trap: $n Testcontainers container(s) removed with their volumes (rm -fv)" >&3; }
trap 'trap "" INT TERM; for p in $pollpid $mpid $STUB $PIDS; do [ -z "$p" ] || killtree "$p"; done; for p in $pollpid $mpid $STUB $PIDS; do if kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; tcrm; rm -rf exercise/check.run exercise/apply.run; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.spec.json exercise/check.call.txt exercise/check.cp exercise/apply.build.log exercise/apply.jvm.log exercise/apply.spec.json; [ -z "$INTR" ] || rm -f .r-*.new; rmdir .r-lock 2> /dev/null || rm -rf .r-lock; true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git unzip javap shasum /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|SPRINGDOC_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT|BLUE_RUN)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit10 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }') · run $RUNNO"

# ---- gates before anything is built: the folder, the link, the pins, the anchor, the static check, the prose, the exercise ----------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk10.py dur9.py loc9.py mirror s910.py specwire9.py src tree10.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
[ "$(ls harness/mirror | paste -sd' ' -)" = 'default.diff' ] || die "harness/mirror holds another file, or misses one"
HSRC='probe/Etag.java probe/Http.java probe/Routes.java probe/Witness.java probe/u10/Caller.java probe/u10/U10Probe.java'
[ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$HSRC" ] || die "harness/src holds another file, or misses one"
for f in cdp.mjs cdp9.mjs seal9.py src/probe/u09/SchemeCopy.java; do [ ! -e harness/$f ] || die "harness/$f: a browser or scheme instrument in a unit with neither"; done
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md apply.sh break.sh check.sh' ] || die "exercise/ holds another file, or misses one"
[ -L before ] && [ "$(readlink before)" = ../c9-unit09/after ] || die "before must be a link whose text is exactly ../c9-unit09/after (found: $( [ -L before ] && readlink before || echo 'not a link'))"
[ -d after ] && [ ! -L after ] || die "after/ is this unit's own frozen tree, a directory, not a link"
for t in before after; do [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-client/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/ - never built in place"; true; done
echo "  before -> $(readlink before) (a link, the text exact) · after/ a directory (the frozen copy) · no secrets/, target/ or .m2-demo/ in either"
$G -v '^ *#' harness/src/probe/*.java harness/src/probe/u10/*.java | $G -q 'Thread\.sleep' && die "R.412: a Thread.sleep in the harness"
for f in Witness Http Etag Routes; do w=$(awk -v n="harness/src/probe/$f.java" '$1 == "file" && $2 == n { print $3 }' ../c9-unit09/receipts.md5)
  [ -n "$w" ] && [ "$(md5 -q harness/src/probe/$f.java)" = "$w" ] || die "harness/src/probe/$f.java is not U09's published file (../c9-unit09/receipts.md5)"; done
echo "  harness/src/probe: Witness, Http, Etag, Routes = ../c9-unit09/receipts.md5's file lines (copied from U09's harness) · u10/U10Probe, u10/Caller = this unit's"
SW9=$(awk '$2 ~ /instruments\/specwire9\.py$/ { print $1 }' "$BK/MD5SUMS"); L9=$(awk '$2 ~ /instruments\/loc9\.py$/ { print $1 }' "$BK/MD5SUMS")
[ -n "$SW9" ] && [ "$(md5 -q harness/specwire9.py)" = "$SW9" ] && [ "$(md5 -q "$BK/instruments/specwire9.py")" = "$SW9" ] || die "harness/specwire9.py is not BLUE's instrument (its MD5SUMS line: ${SW9:-none})"
[ -n "$L9" ] && [ "$(md5 -q harness/loc9.py)" = "$L9" ] && [ "$(md5 -q "$BK/instruments/loc9.py")" = "$L9" ] || die "harness/loc9.py is not BLUE's instrument (its MD5SUMS line: ${L9:-none})"
W9=$(awk '$1 == "file" && $2 == "harness/specwire9.py" { print $3 }' ../c9-unit09/receipts.md5); [ "$(md5 -q harness/specwire9.py)" = "$W9" ] || die "harness/specwire9.py is not U09's copy"
echo "  harness/specwire9.py: BLUE's instrument, byte-equal (md5 $SW9 = $BK's MD5SUMS line, = the filed copy, = U09's copy) · harness/loc9.py: BLUE's (md5 $L9 = its MD5SUMS line, = the filed copy)"
[ "$(sed -n '5,$p' harness/tree10.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit09/harness/tree09.py | md5 -q)" ] || die "harness/tree10.py's code is not tree09.py's"
for u in 01 02 03 04 05 06 07 08 09; do [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit$u/harness/dur9.py)" ] || die "harness/dur9.py is not ../c9-unit$u's copy (dur9 as shipped)"; done
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"
  [ ! -f "$C9R/_builders/dur9.py" ] || [ "$(md5 -q "$C9R/_builders/dur9.py")" = "$D9" ] || die "harness/dur9.py is not C9/_builders/dur9.py"
else D9N="(the registry is not on this machine: U01-U09's copies are the pin)"; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit01-09's copies $D9N · tree10.py's code = tree09.py's"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit09/receipts.md5)
[ -n "$UA" ] || die "../c9-unit09/receipts.md5 has no after-tree line"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree10.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$nm" = after-tree ] || [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit09/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree10.py $dir/ -> $got = receipts.md5's $nm line$( [ "$nm" = before-tree ] && echo " = ../c9-unit09/receipts.md5's after-tree line")"; }
pin before-tree before; pin after-tree after
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true)
echo "  after/ against ../c9-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures its own frozen after/' )"
HF="harness/chk10.py harness/s910.py harness/tree10.py harness/dur9.py harness/loc9.py harness/specwire9.py harness/mirror/default.diff $(for f in $HSRC; do printf 'harness/src/%s ' $f; done)exercise/check.sh exercise/apply.sh exercise/break.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's scripts: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
ST=$(python3 -I -B harness/chk10.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
STV=$(printf '%s\n' "$ST" | sed -n 's/^VALUES //p')
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s910.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U10 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s910, per sentence): /'
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b|<measure>' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
GL=$(python3 -I -B harness/chk10.py gloss README.md) || die "the gloss: $(printf '%s\n' "$GL" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$GL" | $G -v '^VALUES ' | sed 's/^/  /'
GLV=$(printf '%s\n' "$GL" | sed -n 's/^VALUES //p')
HOOK=$(python3 -I -B harness/chk10.py hook); EXQ=$(python3 -I -B harness/chk10.py exq); GLS=$(python3 -I -B harness/chk10.py gloss-line)
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S2B's Unit 10 Hook line), byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SP=$(python3 -I -B harness/chk10.py spoken "$HOOK" "$EXQ") || die "the spoken lines: $(printf '%s\n' "$SP" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$SP" | $G -v '^VALUES ' | sed 's/^/  /'
SPV=$(printf '%s\n' "$SP" | sed -n 's/^VALUES //p')
printf '%s\n\n%s\n\n%s\n' "$HOOK" "$EXQ" "$GLS" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s910.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
printf '%s\n' "$SW" | tail -1 | $G -qE ' refused: 0$' || die "a refused reading in a spoken line: $(printf '%s\n' "$SW" | $G ' line ' | head -3 | paste -sd';' -)"
echo "  the hook, the exercise's line and the gloss through s910.py (every family, the carried base and dur9 inside it): refused 0"; rm -f .r-lock/spoken.md
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
$G -qE '^rm -f check\.' exercise/check.sh || die "exercise/check.sh must remove its saved files before it builds"
! $G -qwE 'path' exercise/check.sh exercise/apply.sh exercise/break.sh || die "an exercise script names a variable path - under zsh that is the PATH array (BLUE C9-U06's finding): rpath"
$G -qF 'sh apply.sh' exercise/SOLUTION.md || die "SOLUTION.md must give the solution as apply.sh's run"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh exercise/check.sh exercise/apply.sh exercise/break.sh | $G -qwE "$K1|$K2" || die "a script names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket"
DK=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -vF 'echo "' | $G -nE '(^|[ ;(])docker (run|exec|rm|ps|port|info|images|volume|image|pull|logs|inspect)\b' | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.344: receipts.sh calls docker without the pinned socket: $DK"
RMF=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) rm( +-[a-z]+)*' | sort -u | paste -sd'|' -)
[ "$RMF" = 'dk rm -fv' ] || die "R.387: receipts.sh removes a container without its volumes (found: ${RMF:-none})"
# R.391 as unit 10 rewrites it (flag 19): every Maven build names the module its claim is about with -am, or is the whole reactor
MVL=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -F '$MV ')
MVA=$(printf '%s\n' "$MVL" | $G -vF -- '-pl tiffinbox-web -am' | $G -vF -- '-pl tiffinbox-client -am' | $G -cF -- '-pl ' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh with a -pl form other than '-pl tiffinbox-web -am' or '-pl tiffinbox-client -am'"
MVB=$(printf '%s\n' "$MVL" | $G -F '.harness/before' | $G -vF -- ' validate' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVB" = 0 ] || die "R.391: before (two modules, no client) is built only with -pl tiffinbox-web -am"
echo "  R.391 (flag 19's two forms): Maven builds -pl tiffinbox-web -am $(printf '%s\n' "$MVL" | $G -cF -- '-pl tiffinbox-web -am') · -pl tiffinbox-client -am $(printf '%s\n' "$MVL" | $G -cF -- '-pl tiffinbox-client -am') · the whole reactor (no -pl) $(printf '%s\n' "$MVL" | $G -vcF -- '-pl ' || true) · another form 0 · before only with -pl tiffinbox-web -am (and once -pl tiffinbox-client -am validate, the proof it has no client)"
KW='idempotency''-key'; KH=$($G -v '^ *#' receipts.sh exercise/check.sh exercise/apply.sh exercise/break.sh | $G -iF "$KW" | $G -vcF 'KEYH=' || true)
[ "$KH" = 0 ] || die "S9.21: a line of receipts.sh or the exercise names the key header ($KH) - the named requests send it through \$KEYH"
echo "  the exercise: check.sh removes its saved files first, names no variable path; SOLUTION.md runs apply.sh; the two What-it-prints blocks differ · the hook and the exercise's line byte for byte · placeholders 0"
echo "  static: no kill by name; every docker call on the pinned socket, every removal rm -fv; no Thread.sleep in the harness; the key header named by no line of receipts.sh or the exercise"
mask() { awk -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(PE, "…"); gsub(P, "…"); gsub(QE, "…/.."); gsub(Q, "…/.."); gsub(H, "~")
    gsub(/ in [0-9.]+ seconds \(process running for [0-9.]+\)/, " in <t> (process running for <t>)")
    gsub(/\(execution time [0-9:.]+s\)/, "(execution time <t>)")
    gsub(/Total time: +[0-9.:]+ [a-z]+/, "Total time: <t>")
    gsub(/Time elapsed: [0-9.]+ s/, "Time elapsed: <t>")
    gsub(/\[ *[0-9.]+ (s|min)\]/, "[<t>]")
    gsub(/[0-9]+ ms/, "<t>")
    gsub(/pid [0-9]+/, "pid <n>")
    gsub(/date = "[^"]*"/, "date = \"<generated-date>\"")
    gsub(/[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?( ?[A-Z]{3,4}|Z|[+-][0-9:]+)?(\[[A-Za-z_\/]+\])?/, "<time>")
    gsub(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/, "<uuid>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'took 812 ms' '"timestamp":"2026-11-24T07:12:01.123+01:00"' "$U/x $HOME/y" '@Generated(value = "x", date = "2026-11-25T05:12:51.236758+01:00[Europe/Rome]", comments = "y")' '[INFO] TiffinBox Web ...... SUCCESS [ 11.955 s]' | mask)
[ "$(printf '%s\n' "$MP" | paste -sd'|' -)" = 'Started TiffinBoxServer in <t> (process running for <t>)|took <t>|"timestamp":"<time>"|…/x ~/y|@Generated(value = "x", date = "<generated-date>", comments = "y")|[INFO] TiffinBox Web ...... SUCCESS [<t>]' ] || die "the mask's self-test: $(printf '%s\n' "$MP" | paste -sd'|' -)"
maskh() { tr -d '\r' < "$1" | sed -E 's/^(Date|date): .*/\1: <masked>/; s/(JSESSIONID=)[^;]*/\1<masked>/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/^(Expires): .*/\1: <masked>/; s/^(Keep-Alive): .*/\1: <masked>/'; }
MH=$(printf 'Date: Tue, 24 Nov 2026 08:00:00 GMT\r\nSet-Cookie: JSESSIONID=ABC123; Path=/; HttpOnly\r\nLocation: http://127.0.0.1:20970/dashboard\r\nExpires: Tue, 24 Nov 2027 08:00:00 GMT\r\nKeep-Alive: timeout=60\r\n' > .r-lock/mh; maskh .r-lock/mh | paste -sd'|' -; rm -f .r-lock/mh)
[ "$MH" = 'Date: <masked>|Set-Cookie: JSESSIONID=<masked>; Path=/; HttpOnly|Location: http://127.0.0.1:<port>/dashboard|Expires: <masked>|Keep-Alive: <masked>' ] || die "the header mask's self-test: $MH"
GM=$(printf '%s\n' '@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", date = "2026-11-25T05:12:51.236758+01:00[Europe/Rome]", comments = "Generator version: 7.27.0")' > .r-lock/gm.java; python3 -I -B harness/chk10.py genmask .r-lock/gm.java; rm -f .r-lock/gm.java)
[ "$GM" = '@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", date = "<generated-date>", comments = "Generator version: 7.27.0")' ] || die "the generated-date mask's self-test: $GM"
echo "  masks: the log mask masked a Started line's times, a millisecond count, Boot's /error timestamp, the folders, the home, a @Generated date and a reactor line's time; the header mask a planted Date, session cookie, port, Expires and Keep-Alive; the generated-sources mask a @Generated date"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
$G -qF 'S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)' ../c9-unit09/receipts.sh || die "../c9-unit09/receipts.sh no longer reads the seven's md5 off ../c7-unit31/receipts.sh"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SURF=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh)
[ ${#U4SURF} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh (SURF=)"
U9V=$(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit09/README.md | $G -oE '(^| )(seven|surface)=[0-9a-f]{8}( |$)' | sed 's/^ *//; s/ *$//' | paste -sd' ' -)
[ "$U9V" = "seven=$(echo $S466 | cut -c1-8) surface=$(echo $U4SURF | cut -c1-8)" ] || die "U09's README values block ($U9V) is not the seven and the surface read off the receipts"
echo "  the seven: expected $S466 (../c7-unit31/receipts.sh's S466= line, as ../c9-unit09/receipts.sh reads it) · the old surface: expected $U4SURF (../c9-unit04/receipts.sh's SURF= line) · both = U09's README values block ($U9V)"
FA=$(cat "$ADV/fetched-at.txt" 2> /dev/null | head -1); [ -n "$FA" ] || die "the advisories' fetched-at line is missing ($ADV)"
FAE=$(python3 -I -c 'import datetime,sys; t = datetime.datetime.strptime(sys.argv[1], "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=datetime.timezone.utc); print(int((datetime.datetime.now(datetime.timezone.utc) - t).total_seconds() // 3600))' "$FA")
[ "$FAE" -lt 48 ] || die "S9.36: the filed advisory read is $FAE hours old - a re-read is the orchestrator's act"
echo "  S9.36: today's filed read ($ADV), fetched at $FA ($FAE h before this run; not re-read: no network) · $(head -1 "$ADV/tomcat-11.0.30-section.txt") · OSV for springdoc: $($G -i springdoc "$ADV/osv-summary.txt" | sed 's/^org.springdoc://' | paste -sd';' -) · the generator 7.27.0, jackson-databind-nullable 0.2.13 and Boot's client modules: not read (never \"clear\")"

# ---- docker, ports, the guard: the baselines ----------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that socket? (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run"
TC0=1
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
BAND="20990 20991 20992 20993 20994 20995 20996 20997 20998 20999"
PORTS="18425 18881 18882 18883 18884 20578 20615 $BAND 21280 21281 21282 21283 21284"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
for p in $BAND 21280 21281 21282 21283 21284; do [ -z "$(lsof -nP -iUDP:$p 2> /dev/null)" ] || die "UDP $p is bound"; done
[ "$(pgrep -x java | wc -l | tr -d ' ')" = 0 ] || die "a java process is running before this script starts one - not this script's; stop it first"
band20400() { lsof -nP -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { n = split($9, a, ":"); p = a[n] + 0; if (p >= 20400 && p <= 21299) c++ } END { print c + 0 }'; }
guard() { local r; r=$(pgrep -fl "^/bin/(ba)?sh (\./|.*/)(receipts|runrec)[.]sh" 2> /dev/null | $G -v "^$$ " || true)
  local l1; l1=$(sysctl -n vm.loadavg | awk '{ print $2 }')
  [ -z "$r" ] || die "S9.17: another receipt runs ($r) before $1 - this run stops; wait for it, never kill it"
  local w=0; while ! awk -v l="$l1" 'BEGIN { exit !(l < 20) }'; do
    [ -n "${GUARD0:-}" ] || die "R.480: load1 $l1 is not below 20 at the launch - a run of record launches only below 20; launch again when it is"
    w=$((w + 1)); [ $w -lt 900 ] || die "R.480: load1 stayed at or above 20 for 900 checks before $1"; sleep 1; l1=$(sysctl -n vm.loadavg | awk '{ print $2 }'); done
  GUARD0=1
  for p in $BAND; do case " ${MINE:-} " in *" $p "*) continue ;; esac; [ "$(listeners $p)" = 0 ] || die "guard before $1: something listens on $p that this run did not start"; done
  echo "  guard before $1: no other receipt · load1 $l1 (< 20)$( [ $w = 0 ] || echo " after $w checks at or above 20 (waited, never killed)") · the band free"; }
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · nothing pulled, ever (no image is run by this script; the ITs' containers are Testcontainers', from images present) · no Testcontainers container · ports $PORTS free (TCP; the band and 21280-21284 UDP too) · no java process"

# ---- the trees, copied and built offline: before (through the link), after/; the harness, compiled -----------------------------------
M2="$PWD/.m2-demo"
if [ ! -d "$M2" ]; then [ -d "$SEED" ] || die "the seed $SEED is missing (README.md, The repository)"; cp -cR "$SEED" "$M2" 2> /dev/null || cp -R "$SEED" "$M2" || die "the seed could not be copied"; fi
NF0=$(find "$M2" -type f | wc -l | tr -d ' '); NB0=$(find "$M2" -type f -print0 | xargs -0 stat -f %z | awk '{ s += $1 } END { printf "%d", s }')
CO=$(find "$M2" -name _remote.repositories -print0 | xargs -0 $G -l 'central-only' 2> /dev/null | wc -l | tr -d ' ')
[ "$CO" = 0 ] || die "S2.4: $CO _remote.repositories files in the seed copy still name central-only - the seed is not the rewritten one"
GENA=org/openapitools/openapi-generator-maven-plugin/7.27.0/openapi-generator-maven-plugin-7.27.0.jar
for a in org/springframework/boot/spring-boot-starter-parent/4.1.3/spring-boot-starter-parent-4.1.3.pom org/apache/tomcat/embed/tomcat-embed-core/11.0.29/tomcat-embed-core-11.0.29.jar \
         $GENA org/openapitools/openapi-generator/7.27.0/openapi-generator-7.27.0.jar org/openapitools/jackson-databind-nullable/0.2.13/jackson-databind-nullable-0.2.13.jar \
         org/springframework/boot/spring-boot-starter-restclient/4.1.3/spring-boot-starter-restclient-4.1.3.jar org/springframework/boot/spring-boot-restclient/4.1.3/spring-boot-restclient-4.1.3.jar \
         org/springframework/boot/spring-boot-restclient-test/4.1.3/spring-boot-restclient-test-4.1.3.jar net/ttddyy/datasource-proxy/1.11.1/datasource-proxy-1.11.1.jar; do
  [ -f "$M2/$a" ] || die ".m2-demo holds no $a - it is not the Section 2 seed (no seed act here: report the coordinates)"; done
echo "  .m2-demo (a copy of the seed m2-seed-c9-s2): files $NF0 · bytes $NB0 · _remote.repositories naming central-only: $CO · the 4.1.3 parent, tomcat-embed-core 11.0.29, the generator's Maven build step 7.27.0 and openapi-generator-7.27.0.jar ($(stat -f %z "$M2/org/openapitools/openapi-generator/7.27.0/openapi-generator-7.27.0.jar") B), jackson-databind-nullable 0.2.13, Boot 4.1.3's starter-restclient, restclient and restclient-test, datasource-proxy 1.11.1 present"
mkdir -p .harness; rm -rf .harness/before .harness/after .harness/pkg .harness/twin .harness/tests .harness/webonly .harness/run .harness/work .harness/hc .harness/hcc .harness/gen* .harness/default .harness/mock-* .harness/exercise .harness/copyspec
mkdir -p .harness/home .harness/run .harness/work
printf '%s\n' 'checks.disable=true' > .harness/home/.testcontainers.properties
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy before .harness/before; copy after .harness/after
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE 'Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" HOME=\"$U/.harness/home\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 900; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
AL="-DargLine=$JL -Dstdout.encoding=UTF-8 -Duser.home=../../home"
guard "the build of before"
bg "cd .harness/before && $MV -DskipTests clean package -pl tiffinbox-web -am" .harness/build-before.log
[ "$RE" = 0 ] || { tail -30 .harness/build-before.log | mask >&3; die ".harness/before did not build offline (exit $RE)"; }; offl .harness/build-before.log
echo "  built before offline (mvn -o -DskipTests clean package -pl tiffinbox-web -am - two modules, no client; exit 0, Downloading/Downloaded from: 0)"
guard "the build of after"
bg "cd .harness/after && $MV -DskipTests clean package" .harness/build-after.log
[ "$RE" = 0 ] || { tail -30 .harness/build-after.log | mask >&3; die ".harness/after did not build offline (exit $RE)"; }; offl .harness/build-after.log
echo "  built after/ offline (mvn -o -DskipTests clean package, the whole reactor: $($G -E '^\[INFO\] TiffinBox[A-Za-z ]* \.+ SUCCESS' .harness/build-after.log | sed -E 's/^\[INFO\] (TiffinBox[A-Za-z ]*) \.+ SUCCESS.*/\1/' | paste -sd, -); exit 0, Downloading/Downloaded from: 0)"
for t in before after; do
  bg "cd .harness/$t && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$t.log
  [ "$RE" = 0 ] || die ".harness/$t: the jar's extract failed"; done
bg "cd .harness/before && $MV -pl tiffinbox-client -am -q validate" .harness/before-client.log
echo "  the before tree has two modules: mvn -o -pl tiffinbox-client -am validate on it exits $RE ($($G -m1 -oE 'Could not find the selected project in the reactor: [a-z-]+' .harness/before-client.log || echo 'no such line'))"
[ "$RE" != 0 ] || die "before accepted -pl tiffinbox-client: it is not U09's two-module tree"
CPA=".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*"
DSP="$M2/net/ttddyy/datasource-proxy/1.11.1/datasource-proxy-1.11.1.jar"
CJ="$U/.harness/after/tiffinbox-client/target/tiffinbox-client-1.0.0.jar"
GR=.harness/after/tiffinbox-client/target/generated-sources/openapi
bg "cd .harness/after && $MV -q dependency:build-classpath -DincludeScope=runtime -Dmdep.outputFile=\"$U/.harness/client-cp.txt\" -pl tiffinbox-client -am" .harness/client-cp.log
[ "$RE" = 0 ] && [ -s .harness/client-cp.txt ] || die "the client's run-time class path could not be read offline (exit $RE)"
CCP="$CJ:$(cat .harness/client-cp.txt)"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \"$CPA:$DSP\" harness/src/probe/*.java harness/src/probe/u10/U10Probe.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/'s jar: $(head -5 .harness/javac.log)"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hcc -cp \"$CCP\" harness/src/probe/u10/Caller.java" .harness/javac-caller.log
[ "$RE" = 0 ] || die "the runner did not compile against the client's jar: $(head -5 .harness/javac-caller.log)"
echo "  the harness compiled against after/'s web jar ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes; datasource-proxy 1.11.1 on the harness's class path only) · the runner probe.u10.Caller against the client's jar and its run-time class path ($(tr ':' '\n' < .harness/client-cp.txt | wc -l | tr -d ' ') jars, mvn -o dependency:build-classpath -DincludeScope=runtime) - never in either jar"

# ---- helpers ---------------------------------------------------------------------------------------------------------------------------
B() { echo "http://127.0.0.1:$1"; }
J=.harness/work
mark() { wc -l < ".harness/run/$1/jvm.log" | tr -d ' '; }
acount() { wc -l < ".harness/run/$1/access/access.log" 2> /dev/null | tr -d ' '; }
srv() { local lab=$1 m=$2 a0=$3 i=0
  while [ "$(acount $lab)" -le "$a0" ]; do i=$((i + 1)); [ $i -lt 400 ] || { echo "     access: NO LINE"; break; }; sleep 0.02; done
  [ $i -ge 400 ] || echo "     access: $(sed -n "$(( a0 + 1 ))p" ".harness/run/$lab/access/access.log")"; }
HSEL='^(Location|Allow|Accept-Patch|Content-Length|Content-Type):'
ask() { local lab=$1 m=$2 p=$3 o=$J/$DB-$1 w rc mk a0 x; shift 3
  : > "$o.h"; : > "$o.b"; mk=$(mark $L); a0=$(acount $L)
  w=$($CURL --http1.1 -sS -D "$o.h" -o "$o.b" -w '%{http_code} %{content_type} %{size_download}' --max-time 20 -X "$m" "$@" "$(B $P)$p" 2> "$o.err"); rc=$?
  echo "-- $lab | $m $p -> $w (curl exit $rc)"
  x=no; for a in "$@"; do case "$a" in [Ii]dempotency-[Kk]ey:*) x=yes ;; esac; done; echo "     sent: key header $x"
  tr -d '\r' < "$o.h" | $G -iE "$HSEL" | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' | while IFS= read -r h; do echo "     header: $h"; done
  srv $L $mk $a0
  local n; n=$(wc -c < "$o.b" | tr -d ' ')
  if [ "$n" -le 330 ] && [ "$n" -gt 0 ]; then echo "     body: $(tr -d '\r' < "$o.b" | tr '\n' '~' | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/"timestamp":"[^"]*"/"timestamp":"<masked>"/')"; else echo "     body: $n B md5 $(sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' "$o.b" | md5 -q) (the port masked)"; fi; }
probe() { $CURL -s "$(B $P)/probe/u10/$1"; }
row() { echo "$(probe row/$1 | python3 -I -c 'import json,sys; r = [{k.lower(): v for k, v in x.items()} for x in json.load(sys.stdin)]; print(" ".join("%s %s %s %s v%s" % (x["name"], x["meals_per_day"], x["price_per_meal"], x["meal_type"], x["version"]) for x in r) or "no row")') (the harness's JdbcTemplate route /probe/u10/row/$1, the second client)"; }
count() { echo "$(probe count | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])') (the harness's JdbcTemplate route /probe/u10/count, the second client)"; }
keyrows() { echo "$(probe keys | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])') (the harness's JdbcTemplate route /probe/u10/keys, the second client)"; }
# tb LABEL PORT DB HCX [args]: TiffinBox (the extracted jar of TREE=after unless TREE is set), from its own run folder with a generated token
# (a config tree, 0600, never printed), Tomcat's access log on (unbuffered, no time field: %m %U%q %s %b, S9.27; ALP replaces the pattern
# for a JVM whose capture names the request headers it logs - the harness's pattern); waited for by its Started line
tb() { local label=$1 port=$2 db=$3 hcx=$4 t=${TREE:-after} run=.harness/run/$1 src="" i=0; shift 4
  guard "TiffinBox $label"
  for q in 20991 20992 20995 20999; do [ "$(listeners $q)" = 0 ] && [ -z "$(lsof -nP -iUDP:$q 2> /dev/null)" ] || die "$q must stay free (TCP and UDP)"; done
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox" "$run/access"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  local x="$U/.harness/$t/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  if [ -n "$hcx" ]; then cp="$hcx:$cp:$U/.harness/hc:$DSP"; src="--spring.main.sources=${SRC:-probe.Witness,probe.Http,probe.Routes,probe.u10.U10Probe}"; fi
  (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -cp "$cp" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port="$port" $src \
     --server.tomcat.accesslog.enabled=true --server.tomcat.accesslog.directory="$U/$run/access" --server.tomcat.accesslog.prefix=access --server.tomcat.accesslog.suffix=.log \
     --server.tomcat.accesslog.file-date-format= --server.tomcat.accesslog.rotate=false "--server.tomcat.accesslog.pattern=${ALP:-%m %U%q %s %b}" --server.tomcat.accesslog.buffered=false "$@" > jvm.log 2>&1) &
  local p=$!; echo $p > "$run/pid"; PIDS="$PIDS $p"; MINE="${MINE:-} $port"
  while ! $G -q -E 'Started TiffinBox(App|Server) in' "$run/jvm.log" 2> /dev/null; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before its Started line"; }; i=$((i + 1)); [ $i -lt 900 ] || die "$label: no Started line"; sleep 0.1; done
  echo "  $label up on $port ($db, tree $t$( [ -n "$hcx" ] && echo ", the harness joined" || echo ", no harness")) · cap: alarm 900 (perl) · waited for its Started line · $($G -o -E 'Successfully applied [0-9]+ migrations[^(]*|Schema "[^"]*" is up to date[^.(]*' "$run/jvm.log" | head -1 | sed 's/ *$//')"; }
tbstop() { local label=$1 port=$2 run=.harness/run/$1 p i=0; p=$(cat "$run/pid")
  if kill -0 "$p" 2> /dev/null; then printf 'X-Shutdown-Token: %s\n' "$(head -1 "$run/secrets/tiffinbox/shutdown-token")" | $CURL -s -o /dev/null --max-time 5 -H @- -X POST "$(B $port)/shutdown" || true; fi
  while kill -0 "$p" 2> /dev/null; do i=$((i + 1)); [ $i = 80 ] && kill "$p" 2> /dev/null; [ $i -lt 400 ] || { kill -9 "$p" 2> /dev/null; break; }; sleep 0.05; done
  wait "$p" 2> /dev/null || true; PIDS=$(echo " $PIDS " | sed "s/ $p / /g"); MINE=$(echo " ${MINE:-} " | sed "s/ $port / /g")
  [ "$(listeners $port)" = 0 ] || die "$label: something still listens on $port"; }
health() { echo "  one GET /actuator/health (a counted step of its own): $($CURL -s -o /dev/null -w '%{http_code}' "$(B $P)/actuator/health")"; }
# run the harness's runner (the generated interfaces, the runner's RestClient) - CALLCP adds jars to the runner's class path
caller() { local o=$J/caller.out; guard "the runner ($1)"
  perl -e '$SIG{INT}="DEFAULT"; alarm 120; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -cp "$U/.harness/hcc:${CALLCP:+$CALLCP:}$CCP" probe.u10.Caller "$@" > $o 2>&1; local rc=$?
  $G -E '^CLIENT ' $o | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/^/  /'
  $G -E '^Exception in thread|^Caused by' $o | head -2 | cut -c1-200 | sed 's/^/  runner: /'
  echo "  the runner's exit: $rc"; }
NCAPS=0; unpub=""; VALS=""
cap() { local nm=$1; shift
  if [ -n "${DEVCAPS:-}" ] && ! echo " $DEVCAPS " | $G -qF " $nm "; then return 0; fi   # development only: a run of record sets no DEVCAPS
  "$@" > .harness/cap-$nm.raw 2>&1 || true
  $G -q '^  \*\*\* ' .harness/cap-$nm.raw && { cat .harness/cap-$nm.raw >&3; die "$nm stopped (above)"; }
  mask < .harness/cap-$nm.raw > .r-$nm.new
  sed 's/^/  | /' .r-$nm.new | cut -c1-260
  local o e=0; o=$(python3 -I -B harness/chk10.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk10 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  $G -v '^ok \|^FAIL ' .harness/chk-$nm.out | sed 's/^/  chk10 /' || true
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; [ -n "${DEVCAPS:-}" ] && { echo "  (development: $nm's check failed, the run goes on)"; unpub="$unpub $nm"; } || die "$nm: its check failed (harness/chk10.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk10.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-11s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-11s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff its block in README.md against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }
alog() { cat ".harness/run/$1/access/access.log" 2> /dev/null || true; }
ck() { python3 -I -B harness/chk10.py "$@"; }

# ---- the captures --------------------------------------------------------------------------------------------------------------------
JSON='Content-Type: application/json'; MPT='Content-Type: application/merge-patch+json'; JPT='Content-Type: application/json-patch+json'
API=/api/v1/customers
KEYH='Idempotency-Key'          # the key header's name: sent only by specwire9.py's pause-key and the printed alternative (the runner's keyed mode)
THREE="/v3/api-docs /v3/api-docs.yaml /v3/api-docs/swagger-config"
SPECF=after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json
WEBM=tiffinbox-web/src/main/java/com/tiffinbox/web

surefire() { local f; for f in "$1"/TEST-*.xml; do ck surefire "$f"; done; }
reactor() { $G -E '^\[INFO\] (Reactor Summary|TiffinBox[A-Za-z ]* \.+ (SUCCESS|FAILURE|SKIPPED))' "$1" | sed -E 's/ \.+ / ... /; s/\[ *[0-9.]+ (s|min)\]//; s/^\[INFO\] /  reactor: /; s/ *$//'; }
c_tests() { local p
  echo "== mvn -o clean package (tests on) on a copy of after/ (.harness/pkg): the whole reactor, three modules, Docker reachable"
  guard "mvn package"
  copy after .harness/pkg; copy after .harness/twin; copy after .harness/tests; copy after .harness/webonly
  bg "cd .harness/pkg && DOCKER_HOST=\"$DH\" $MV \"$AL\" clean package" .harness/pkg.log
  echo "  mvn package exit $RE · Downloading/Downloaded from: $($G -cE 'Download(ing|ed) from ' .harness/pkg.log || true)"; reactor .harness/pkg.log
  $G -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' .harness/pkg.log | sed -E 's/^\[[A-Z]+\] /  results: /'
  echo "== Surefire's XML, per module and class (package)"
  for p in tiffinbox-web tiffinbox-client; do surefire .harness/pkg/$p/target/surefire-reports | sed "s/^  /  $p | /"; done
  echo "== the Docker-free twin: the same, DOCKER_HOST=unix:///nonexistent/docker.sock (.harness/twin)"
  guard "the Docker-free twin"
  bg "cd .harness/twin && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package" .harness/twin.log
  echo "  mvn package (Docker-free) exit $RE · Downloading/Downloaded from: $($G -cE 'Download(ing|ed) from ' .harness/twin.log || true)"; reactor .harness/twin.log
  for p in tiffinbox-web tiffinbox-client; do surefire .harness/twin/$p/target/surefire-reports | sed "s/^  /  twin $p | /"; done
  echo "== the client's tests: the @Test lines the change adds (after/ against before; before has no client module)"
  for p in $(cd after && find tiffinbox-client/src/test -name '*.java' | sort); do echo "  new @Test | $(basename $p .java) | $($G -cE '^ +@Test$' after/$p) | $($G -oE '^ +void [A-Za-z]+' after/$p | sed 's/^ *void //' | paste -sd, -) | before/$p: $( [ -e before/$p ] && echo present || echo absent)"; done
  for p in $(cd before && find tiffinbox-web/src/test tiffinbox-core/src -type f | sort); do cmp -s before/$p after/$p || echo "  MOVED existing test or core file: $p"; done
  echo "  existing tests (tiffinbox-web/src/test, tiffinbox-core/src) before -> after/: $(for p in $(cd before && find tiffinbox-web/src/test tiffinbox-core/src -type f); do cmp -s before/$p after/$p || echo x; done | wc -l | tr -d ' ') files differ"
  echo "== mvn -o clean verify on a copy of after/ (.harness/tests): the whole reactor - Surefire's tests, then the five ITs; 21280-21284 and 18881-18884 asserted free before"
  for p in 21280 21281 21282 21283 21284 18881 18882 18883 18884; do [ "$(listeners $p)" = 0 ] && [ -z "$(lsof -nP -iUDP:$p 2> /dev/null)" ] || die "$p is bound before verify"; done
  guard "mvn verify"
  : > .harness/tcps.txt
  ( while :; do dk ps --filter label=org.testcontainers=true --format '{{.Ports}}' >> .harness/tcps.txt 2> /dev/null; sleep 1; done ) & pollpid=$!
  bg "cd .harness/tests && DOCKER_HOST=\"$DH\" TESTCONTAINERS_RYUK_DISABLED=true $MV \"$AL\" clean verify" .harness/verify.log
  kill $pollpid 2> /dev/null; wait $pollpid 2> /dev/null; pollpid=""
  local vre=$RE; offl .harness/pkg.log; offl .harness/twin.log; offl .harness/verify.log
  $G -q 'Timed out waiting' .harness/verify.log && echo "  an IT's wait TIMED OUT (S9.32: this run of record fails)"
  echo "  mvn verify exit $vre · Downloading/Downloaded from: 0"; reactor .harness/verify.log
  echo "== Failsafe's XML, per class (the ITs; the client has none)"; surefire .harness/tests/tiffinbox-web/target/surefire-reports-it
  echo "  the client's ITs: $(ls .harness/tests/tiffinbox-client/target/surefire-reports-it 2> /dev/null | $G -c 'TEST-' || true) (the module has no IT)"
  $G -E '^IT BINDINGS ' .harness/verify.log | sort | sed 's/^/  /'
  echo "  the Elasticsearch IT's wait: $($G -cE 'Timed out waiting' .harness/verify.log || true) timed out (S9.32)"
  echo "  Testcontainers' containers while verify ran (docker ps Ports, beside, never the witness): $(tr ', ' '\n\n' < .harness/tcps.txt | $G -oE '^[0-9.]+:[0-9]+' | sort -u | paste -sd' ' -)"
  echo "  Testcontainers containers after: $(dk ps -aq --filter label=org.testcontainers=true | wc -l | tr -d ' ') · listeners on 21280-21284 after: $(for p in 21280 21281 21282 21283 21284; do listeners $p; done | paste -sd+ - | bc)"
  echo "== the hand-built form U01-U09 run: mvn -o clean package -pl tiffinbox-web -am on a copy of after/ (.harness/webonly), Docker-free"
  guard "the web-only form"
  bg "cd .harness/webonly && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package -pl tiffinbox-web -am" .harness/webonly.log
  echo "  exit $RE · Downloading/Downloaded from: $($G -cE 'Download(ing|ed) from ' .harness/webonly.log || true) · tiffinbox-client/target after it: $( [ -e .harness/webonly/tiffinbox-client/target ] && echo present || echo absent)"; reactor .harness/webonly.log; offl .harness/webonly.log
  surefire .harness/webonly/tiffinbox-web/target/surefire-reports | sed "s/^  /  webonly tiffinbox-web | /"
  echo "== BOOT-INF/lib before -> after"
  for t in before after; do echo "  $t: $(ls .harness/$t/$XD/lib | wc -l | tr -d ' ') jars · $(ls .harness/$t/$XD/lib | $G -E '^(spring-boot-[0-9]|spring-core-|tomcat-embed-core-|jackson-databind-|jackson-annotations-|springdoc-openapi-starter-webmvc-ui-|httpclient5-)' | sort | paste -sd' ' -)"; done
  echo "  the jars' names moved before -> after: $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c '^[<>]' || true)"; }

c_census() { local f n
  echo "== the handler methods on after/ (one flag start on 20993, H2, no harness: --management.endpoints.web.exposure.include=health,prometheus,mappings, once, never shipped)"
  P=20993; L=FLAGA; DB=h2; tb FLAGA 20993 h2 "" --management.endpoints.web.exposure.include=health,prometheus,mappings
  $CURL -s "$(B 20993)/actuator/mappings" > $J/map-after.json; $CURL -s "$(B 20993)/v3/api-docs" > $J/spec-flag.json
  ck mapjson after < $J/map-after.json
  tbstop FLAGA 20993
  echo "== the handlers against the document's operations (the flag start's /v3/api-docs, read by python; servers removed)"
  ck opsmap $J/map-after.json $J/spec-flag.json
  echo "== the generated methods (an anchored count of @HttpExchange( over this run's generated interfaces), beside the 13 operations"
  ck genops $GR $SPECF
  echo "== the handlers the document lacks, against the generated path constants (grep -c over the PATH_ lines)"
  for p in '"/customers/new"' '"/dashboard"'; do echo "  generated PATH_ constants naming $p: $(cat $GR/src/main/java/com/tiffinbox/client/api/*.java | $G -E '^ +String PATH_' | $G -cF "$p" || true)"; done
  echo "  generated methods sending application/x-www-form-urlencoded (DashboardPage's form POST): $(cat $GR/src/main/java/com/tiffinbox/client/api/*.java | $G -c 'application/x-www-form-urlencoded' || true) · json-patch+json: $(cat $GR/src/main/java/com/tiffinbox/client/api/*.java | $G -c 'application/json-patch+json' || true) · merge-patch+json: $(cat $GR/src/main/java/com/tiffinbox/client/api/*.java | $G -c 'application/merge-patch+json' || true)"
  echo "== the web jar: entries named com/tiffinbox/client (unzip -l; the client is not on the web module's class path)"
  for t in before after; do echo "  $t's web jar: $(unzip -l .harness/$t/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | awk '{ print $4 }' | $G -c 'com/tiffinbox/client' || true) entries named com/tiffinbox/client · $(unzip -l .harness/$t/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | awk '{ print $4 }' | $G -cE '(^|/)probe/' || true) named probe/"; done
  cp .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar $J/plant.jar; python3 -I -c 'import sys,zipfile; z = zipfile.ZipFile(sys.argv[1], "a"); z.write(sys.argv[2], "BOOT-INF/classes/com/tiffinbox/client/api/ApiApi.class"); z.close()' $J/plant.jar .harness/after/tiffinbox-client/target/classes/com/tiffinbox/client/api/ApiApi.class
  echo "  plant (one client class added to a scratch copy of the web jar): $(unzip -l $J/plant.jar | awk '{ print $4 }' | $G -c 'com/tiffinbox/client' || true) entries named com/tiffinbox/client - the census check FAILS on it (the harness's plant)"; rm -f $J/plant.jar
  echo "  the image: the Dockerfile's COPY lines: $($G -E '^COPY ' after/Dockerfile | paste -sd'|' -)"; }

c_modules() { ck modtable "$UP" after before; }

c_generate() { local f
  echo "== the generator's run alone: mvn -o clean generate-sources -pl tiffinbox-client -am on a copy of after/ (.harness/gen) - no application built or started"
  copy after .harness/gen
  echo "  listeners 20400-21299 before: $(band20400)"
  guard "the generator's run"
  bg "cd .harness/gen && $MV clean generate-sources -pl tiffinbox-client -am" .harness/gen.log
  echo "  exit $RE · Downloading/Downloaded from: $($G -cE 'Download(ing|ed) from ' .harness/gen.log || true) · listeners 20400-21299 after: $(band20400) · tiffinbox-web/target: $( [ -e .harness/gen/tiffinbox-web/target ] && echo present || echo absent) · java started by it: none (the reactor holds the parent and the client only)"; offl .harness/gen.log
  reactor .harness/gen.log
  echo "  the build step's line: $($G -m1 -oE 'openapi-generator(-maven-plugin)?:7\.[0-9.]+:generate \([a-z-]+\) @ tiffinbox-client' .harness/gen.log)"
  echo "  the generator's own warnings and banner (named by their first words, fenced in the README, never spoken):"
  $G -E 'OpenAPI 3\.1 support is still in beta|Thanks for using OpenAPI Generator|servers. \(OAS 3\.0\) not defined|not generated since it.s marked as unused' .harness/gen.log | sed -E 's/^\[[A-Z]+\] //' | cut -c1-90 | sort | uniq -c | sed -E 's/^ +/  banner x/'
  f=.harness/gen/tiffinbox-client/target/generated-sources/openapi
  echo "== the input: the committed file, read in place"
  echo "  inputSpec (the pom): $($G -oE '<inputSpec>[^<]+' after/tiffinbox-client/pom.xml | sed 's/<inputSpec>//') · resolved: $(cd .harness/gen/tiffinbox-client && python3 -I -c 'import os; print(os.path.relpath(os.path.realpath("../tiffinbox-web/src/test/resources/openapi/tiffinbox.json"), os.path.realpath("..")))')"
  echo "  the committed file: $(wc -c < .harness/gen/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tr -d ' ') B · md5 $(md5 -q .harness/gen/tiffinbox-web/src/test/resources/openapi/tiffinbox.json) · sha256 $(shasum -a 256 .harness/gen/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | cut -c1-64)"
  echo "  the generator's own record ($(ls $f/.openapi-generator | $G sha256)): $(cat $f/.openapi-generator/*.sha256)"
  echo "  .openapi-generator/VERSION: $(cat $f/.openapi-generator/VERSION) · the parent's property: $($G -oE '<openapi-generator.version>[^<]+' after/pom.xml | sed 's/.*>//')"
  echo "== .openapi-generator/FILES (the generator's list; the *.java ones are counted, the rest named)"
  sed 's/^/  FILES | /' $f/.openapi-generator/FILES
  echo "  the generated folder's files, the record files beside: $(cd $f && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)"
  echo "== the generated sources, @Generated(date = ...) masked: md5 per file and of the whole set (python)"
  ck genmd5 $f/src/main/java
  echo "  the same set from after/'s own build (.harness/after): $(ck genmd5 $GR/src/main/java | tail -1)"
  echo "== the panel: the interface that holds the public read (ApiApi.java, its public-read method; date masked)"
  ck panel $f/src/main/java/com/tiffinbox/client/api/ApiApi.java one
  echo "== the coupling: one description byte changed in a scratch mirror's committed file (.harness/gen1b), generated again"
  copy after .harness/gen1b
  python3 -I -c 'import sys; f = sys.argv[1]; s = open(f, encoding="utf-8").read(); a = "Customer not found"; print("  the edit: %r x%d -> %r" % (a, s.count(a), a[:-5] + "Found")); open(f, "w", encoding="utf-8").write(s.replace(a, a[:-5] + "Found"))' .harness/gen1b/tiffinbox-web/src/test/resources/openapi/tiffinbox.json
  guard "the one-byte mirror"
  bg "cd .harness/gen1b && $MV clean generate-sources -pl tiffinbox-client -am" .harness/gen1b.log
  echo "  exit $RE"; offl .harness/gen1b.log
  ck gendiff $f/src/main/java .harness/gen1b/tiffinbox-client/target/generated-sources/openapi/src/main/java "Customer not Found"
  echo "== the refused design: a second COPY of the file inside tiffinbox-client, inputSpec pointed at it (.harness/copyspec; measured, not shipped)"
  copy after .harness/copyspec
  mkdir -p .harness/copyspec/tiffinbox-client/src/main/openapi; cp .harness/copyspec/tiffinbox-web/src/test/resources/openapi/tiffinbox.json .harness/copyspec/tiffinbox-client/src/main/openapi/tiffinbox.json
  sed -i '' 's#<inputSpec>${project.baseUri}../tiffinbox-web/src/test/resources/openapi/tiffinbox.json</inputSpec>#<inputSpec>${project.baseUri}src/main/openapi/tiffinbox.json</inputSpec>#' .harness/copyspec/tiffinbox-client/pom.xml
  python3 -I -c 'import sys; f = sys.argv[1]; s = open(f, encoding="utf-8").read(); a = "\"title\": \"TiffinBox\""; assert s.count(a) == 1; open(f, "w", encoding="utf-8").write(s.replace(a, "\"title\": \"TiffinBox2\""))' .harness/copyspec/tiffinbox-web/src/test/resources/openapi/tiffinbox.json
  echo "  the copy's inputSpec: $($G -oE '<inputSpec>[^<]+' .harness/copyspec/tiffinbox-client/pom.xml | sed 's/<inputSpec>//') · then the web module's file edited (info.title TiffinBox -> TiffinBox2), the copy not"
  guard "the second-copy mirror"
  bg "cd .harness/copyspec && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package -Dtest=OpenApiSpecTest -Dsurefire.failIfNoSpecifiedTests=false -Dmaven.test.failure.ignore=true" .harness/copyspec.log
  echo "  exit $RE · $(surefire .harness/copyspec/tiffinbox-web/target/surefire-reports | sed 's/^ *//')"; reactor .harness/copyspec.log; offl .harness/copyspec.log
  echo "  the client generated from the stale copy: $(ck genmd5 .harness/copyspec/tiffinbox-client/target/generated-sources/openapi/src/main/java | tail -1) (= the shipped set above: the web test is red, the client never knew)"; }

c_jackson() { local c n
  echo "== the client's resolved dependencies: mvn -o dependency:list -pl tiffinbox-client -am on after/'s copy (offline, from the seed copy)"
  guard "dependency:list"
  bg "cd .harness/after && $MV dependency:list -pl tiffinbox-client -am" .harness/deplist.log
  echo "  exit $RE · Downloading/Downloaded from: $($G -cE 'Download(ing|ed) from ' .harness/deplist.log || true)"; offl .harness/deplist.log
  $G -E '^\[INFO\]    [a-z]' .harness/deplist.log | sed -E 's/^\[INFO\]    //; s/ -- module .*//' | $G -E ':(compile|runtime)$' | sort | sed 's/^/  dep (compile, runtime) | /'
  echo "  test scope: $($G -E '^\[INFO\]    [a-z]' .harness/deplist.log | sed -E 's/ -- module .*//' | $G -cE ':test$' || true) artifacts"
  echo "  com.fasterxml.jackson.core:jackson-databind (Jackson 2): $($G -cE 'com\.fasterxml\.jackson\.core:jackson-databind:' .harness/deplist.log || true) · org.openapitools:jackson-databind-nullable: $($G -cE 'org\.openapitools:jackson-databind-nullable:' .harness/deplist.log || true) · httpclient5: $($G -cE 'httpclient5:' .harness/deplist.log || true) · tools.jackson.core:jackson-databind (Jackson 3): $($G -cE 'tools\.jackson\.core:jackson-databind:' .harness/deplist.log || true) · com.fasterxml.jackson.core:jackson-annotations (shared, kept by Jackson 3): $($G -cE 'com\.fasterxml\.jackson\.core:jackson-annotations:' .harness/deplist.log || true)"
  echo "== the generated sources' imports (grep -c over $GR/src/main/java)"
  for c in 'import com.fasterxml.jackson.databind' 'import tools.jackson' 'import com.fasterxml.jackson.annotation' 'import org.openapitools.jackson.nullable'; do echo "  imports '$c': $(cat $(find $GR/src/main/java -name '*.java') | $G -cF "$c" || true)"; done
  echo "== the compiled generated classes' constant pools (javap -v; U07's jackson read's form): references to com/fasterxml/jackson/databind and tools/jackson"
  n=0; for c in $(cd .harness/after/tiffinbox-client/target/classes && find . -name '*.class' | sort); do
    echo "  javap | ${c#./} | com/fasterxml/jackson/databind $(javap -v .harness/after/tiffinbox-client/target/classes/$c | $G -c 'com/fasterxml/jackson/databind' || true) | tools/jackson $(javap -v .harness/after/tiffinbox-client/target/classes/$c | $G -c 'tools/jackson' || true) | com/fasterxml/jackson/annotation $(javap -v .harness/after/tiffinbox-client/target/classes/$c | $G -c 'com/fasterxml/jackson/annotation' || true)"; done
  echo "== the web jar's BOOT-INF/lib (157 on U09's tree): its Jackson jars, before and after"
  for t in before after; do echo "  $t: $(ls .harness/$t/$XD/lib | wc -l | tr -d ' ') jars · $(ls .harness/$t/$XD/lib | $G -E '^jackson-' | sort | paste -sd' ' -)"; done
  echo "  the jars' names moved before -> after: $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c '^[<>]' || true) (Jackson 2's databind there is U07's finding, through the Elasticsearch client; the module adds none)"; }

c_committed() {
  echo "== (i) the committed file: $SPECF"
  echo "  bytes $(wc -c < $SPECF | tr -d ' ') (wc -c) · md5 $(md5 -q $SPECF) · before's (U09's) md5 $(md5 -q before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json) · $(cmp -s before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json $SPECF && echo byte-identical || echo DIFFERENT) · servers member: $(python3 -I -c 'import json,sys; print("present" if "servers" in json.load(open(sys.argv[1])) else "absent")' $SPECF)"
  echo "  U09's values block: $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit09/README.md | $G -oE 'spec_bytes=[0-9]+|spec_md5=[0-9a-f]+' | head -2 | paste -sd' ' -)"
  echo "== (ii) the file against the served document on after/ (20990, H2, no harness), servers removed"
  P=20990; L=CM; DB=h2; tb CM 20990 h2 ""
  health
  $CURL -s "$(B 20990)/v3/api-docs" > $J/spec-h2.raw
  python3 -I -c 'import io,json,sys; d = json.load(open(sys.argv[1], encoding="utf-8")); d.pop("servers", None); b = io.StringIO(); json.dump(d, b, indent=2, ensure_ascii=False); b.write("\n"); open(sys.argv[2], "w", encoding="utf-8").write(b.getvalue())' $J/spec-h2.raw $J/spec-h2.json
  tbstop CM 20990
  echo "  the served document, servers removed (the fixed rule): md5 $(md5 -q $J/spec-h2.json) · = the committed file: $(cmp -s $J/spec-h2.json $SPECF && echo byte-identical || echo DIFFERENT)"
  echo "== (iii) OpenApiSpecTest in the tests capture's package and its Docker-free twin (Surefire's XML)"
  ck surefire .harness/pkg/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.OpenApiSpecTest.xml | sed 's/^/  package:/'
  ck surefire .harness/twin/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.OpenApiSpecTest.xml | sed 's/^/  twin:/'
  echo "  the client reads the file the web test guards: inputSpec $($G -oE '<inputSpec>[^<]+' after/tiffinbox-client/pom.xml | sed 's/<inputSpec>//')"; }

c_call() {
  echo "== the generated one(Ravi) against after/ on 20990 (H2, no harness; the harness's access-log pattern for this JVM: %m %U%q %s %b ua=%{User-Agent}i accept=%{Accept}i)"
  P=20990; L=CALL; DB=h2; ALP='%m %U%q %s %b ua=%{User-Agent}i accept=%{Accept}i' tb CALL 20990 h2 ""
  health
  caller call "$(B 20990)"; cp $J/caller.out $J/call.out
  echo "  the access log's line for it: $(alog CALL | $G -E "^GET $API/Ravi" | tail -1)"
  ask "curl-default" GET $API/Ravi
  ask "curl-generated-accept" GET $API/Ravi -H 'Accept: */*, application/problem+json'
  ask "curl-json" GET $API/Ravi -H 'Accept: application/json'
  echo "  the runner's members against curl's body (python, key for key): $(ck members $J/call.out $J/h2-curl-default.b)"
  echo "== Nobody through the generated call"
  caller nobody "$(B 20990)"
  echo "  the access log's line for it: $(alog CALL | $G -E "^GET $API/Nobody" | tail -1)"
  echo "== HttpClient 5 on the runner's class path (the harness's; measured, not shipped - the module names no httpclient5): the same call"
  CALLCP="$(ls "$M2"/org/apache/httpcomponents/client5/httpclient5/5.6.5/httpclient5-5.6.5.jar):$(ls "$M2"/org/apache/httpcomponents/core5/httpcore5/*/httpcore5-[0-9]*.jar | tail -1):$(ls "$M2"/org/apache/httpcomponents/core5/httpcore5-h2/*/httpcore5-h2-[0-9]*.jar | tail -1)"
  echo "  added: $(echo "$CALLCP" | tr ':' '\n' | sed 's#.*/##' | paste -sd' ' -)"
  CALLCP=$CALLCP caller call "$(B 20990)"
  echo "  the access log's line for it: $(alog CALL | $G -E "^GET $API/Ravi" | tail -1)"
  tbstop CALL 20990
  echo "== plant: nothing listening on 20997, the same call (the check that the call reaches a server)"
  [ "$(listeners 20997)" = 0 ] || die "20997 is bound before the plant"
  caller call "$(B 20997)"
  echo "== plant: a stub on 20997 (the harness's, python) answering two hundred with another customer's body"
  python3 -I -c 'import http.server,sys
class H(http.server.BaseHTTPRequestHandler):
    def do_GET(s):
        b = b"{\"name\":\"Ravi\",\"mealsPerDay\":3,\"pricePerMeal\":120,\"mealType\":\"VEG\"}"; s.send_response(200); s.send_header("Content-Type", "application/json"); s.send_header("Content-Length", str(len(b))); s.end_headers(); s.wfile.write(b)
    def log_message(s, *a): pass
http.server.HTTPServer(("127.0.0.1", 20997), H).serve_forever()' stub10 > $J/stub.log 2>&1 & STUB=$!; MINE="${MINE:-} 20997"
  local i=0; while [ "$(listeners 20997)" = 0 ]; do i=$((i + 1)); [ $i -lt 100 ] || die "the stub did not listen"; sleep 0.05; done
  caller call "$(B 20997)"; cp $J/caller.out $J/stub.out
  echo "  the stub's members against the wire's (curl's body on after/): $(ck members $J/stub.out $J/h2-curl-default.b)"
  kill $STUB 2> /dev/null; wait $STUB 2> /dev/null; STUB=""; MINE=$(echo " $MINE " | sed "s/ 20997 / /g")
  [ "$(listeners 20997)" = 0 ] || die "20997 still bound after the stub"; }

c_pause() {
  echo "== the generated pause call: its signature (reflection on the generated interface) and the generated source"
  caller signature
  echo "  the generated pause method in the source: $($G -B1 -A3 -E 'ResponseEntity<Map<String, Object>> add1\(' $GR/src/main/java/com/tiffinbox/client/api/ApiApi.java | $G -E '@(PathVariable|RequestParam|RequestHeader)' | sed 's/^ *//' | paste -sd' ' -)"
  echo "  the whole generated root: lines naming idempotency (grep -c -i): $(cat $(find $GR/src/main/java -name '*.java') | $G -ci 'idempotency' || true) · of them in comment lines (^ *\\*): $(cat $(find $GR/src/main/java -name '*.java') | $G -i 'idempotency' | $G -cE '^ *\*' || true) · @RequestHeader: $(cat $(find $GR/src/main/java -name '*.java') | $G -c '@RequestHeader' || true) ($(cat $(find $GR/src/main/java -name '*.java') | $G -oE '@RequestHeader\(value = "[^"]+"' | sed 's/.*"\(.*\)"/\1/' | paste -sd, -)) · naming the key header: $(cat $(find $GR/src/main/java -name '*.java') | $G -oE '@RequestHeader\(value = "[^"]+"' | $G -ci 'idempotency' || true)"
  for c in 400 404 409 422; do echo "  the generated sources' comment lines naming status code $c: $(cat $(find $GR/src/main/java -name '*.java') | $G -c "(status code $c)" || true)"; done
  echo "  the pause method's accept list: $($G -A4 -E 'value = ApiApi\.PATH_ADD1' $GR/src/main/java/com/tiffinbox/client/api/ApiApi.java | $G -oE 'accept = \{[^}]*\}')"
  echo "  the spec's pause POST: $(ck specop $SPECF post '/api/v1/customers/{name}/pauses')"
  echo "== the call on a fresh H2 JVM (after/, 20990, no harness): Ravi, days 2, no key header"
  P=20990; L=PAUSE; DB=h2; tb PAUSE 20990 h2 ""
  health
  caller pause "$(B 20990)"; cp $J/caller.out $J/pause.out
  echo "  the access log's line for it: $(alog PAUSE | $G -E "^POST $API/Ravi/pauses" | tail -1)"
  echo "  the wire's body against the spec's key-missing example (python, key for key and value): $(ck example $J/pause.out $SPECF)"
  tbstop PAUSE 20990
  echo "== the key table: the same refused call on a harness-joined companion (20993), the second client reads it"
  P=20993; L=PKEY; DB=h2k; tb PKEY 20993 h2 "$U/.harness/hc"
  health
  echo "  before: keys $(keyrows) · Ravi $(row Ravi) · customers $(count)"
  caller pause "$(B 20993)"
  echo "  after the refused call: keys $(keyrows) · Ravi $(row Ravi) · customers $(count)"
  echo "== the printed alternative (1/1, NOT shipped, NOT a test): the RestClient's builder carries the key as a default header (the runner's keyed mode)"
  caller keyed "$(B 20993)" '"u10-keyed-1"'
  echo "  after the keyed call: keys $(keyrows) · customers $(count)"
  echo "  the access log's pause lines on this JVM: $(alog PKEY | $G -E "^POST $API/Ravi/pauses" | paste -sd'|' -)"
  tbstop PKEY 20993; }

c_mock() { local k
  echo "== the package run's mock test (tiffinbox-client, TiffinBoxClientTest#readsRaviThroughTheMockServer)"
  ck surefire .harness/pkg/tiffinbox-client/target/surefire-reports/TEST-com.tiffinbox.client.TiffinBoxClientTest.xml
  $G -E '^CLIENT mock ' .harness/pkg.log | sed 's/^/  package: /'
  $G -E '^CLIENT mock ' .harness/twin.log | sed 's/^/  twin: /'
  echo "  the call capture's interface line: $($G -E '^CLIENT interface ' $J/call.out | head -1)"
  echo "  the jar's ApiApi.class: md5 $(unzip -p "$CJ" com/tiffinbox/client/api/ApiApi.class | md5 -q)"
  for k in wrongpath unmet noverify; do
    copy after .harness/mock-$k
    f=.harness/mock-$k/tiffinbox-client/src/test/java/com/tiffinbox/client/TiffinBoxClientTest.java
    case $k in
      wrongpath) python3 -I -c 'import sys; f = sys.argv[1]; s = open(f, encoding="utf-8").read(); a = "requestTo(\"http://tiffinbox.test/api/v1/customers/Ravi\")"; assert s.count(a) == 1; open(f, "w", encoding="utf-8").write(s.replace(a, "requestTo(\"http://tiffinbox.test/customers/Ravi\")"))' $f
        echo "== plant (the harness's, scratch .harness/mock-wrongpath): the expectation on the old path /customers/Ravi" ;;
      unmet) python3 -I -c 'import sys; f = sys.argv[1]; s = open(f, encoding="utf-8").read(); a = "        ResponseEntity<Customer> answer"; assert s.count(a) == 1; open(f, "w", encoding="utf-8").write(s.replace(a, "        server.expect(requestTo(\"http://tiffinbox.test/api/v1/customers/Meera\")).andRespond(withSuccess(RAVI, MediaType.APPLICATION_JSON));\n" + a))' $f
        echo "== plant (scratch .harness/mock-unmet): a second expectation the call never meets, verify() kept" ;;
      noverify) python3 -I -c 'import sys; f = sys.argv[1]; s = open(f, encoding="utf-8").read(); a = "        ResponseEntity<Customer> answer"; v = "        server.verify();\n"; assert s.count(a) == 1 and s.count(v) == 1; s = s.replace(a, "        server.expect(requestTo(\"http://tiffinbox.test/api/v1/customers/Meera\")).andRespond(withSuccess(RAVI, MediaType.APPLICATION_JSON));\n" + a); open(f, "w", encoding="utf-8").write(s.replace(v, ""))' $f
        echo "== plant (scratch .harness/mock-noverify): the same unmet expectation, verify() removed" ;;
    esac
    diff after/tiffinbox-client/src/test/java/com/tiffinbox/client/TiffinBoxClientTest.java $f | $G '^[<>]' | sed 's/^/  diff: /' | cut -c1-200
    guard "the mock plant $k"
    bg "cd .harness/mock-$k && $MV \"$AL\" clean test -pl tiffinbox-client -am" .harness/mock-$k.log
    offl .harness/mock-$k.log
    echo "  mvn test exit $RE · $(ck surefire .harness/mock-$k/tiffinbox-client/target/surefire-reports/TEST-com.tiffinbox.client.TiffinBoxClientTest.xml | sed 's/^ *//')"
    echo "  the mock server's own message: $($G -m1 -oE '(java\.lang\.AssertionError|AssertionError): [^~]{0,120}' .harness/mock-$k/tiffinbox-client/target/surefire-reports/com.tiffinbox.client.TiffinBoxClientTest.txt | head -1 || true)"
  done; }

c_default() {
  echo "== the generator's default library (java / restclient) on a scratch mirror only (.harness/default = after/ + harness/mirror/default.diff; never shipped)"
  copy after .harness/default
  (cd .harness/default && patch -s -p1 < "$U/harness/mirror/default.diff") || die "harness/mirror/default.diff did not apply"
  echo "  the patch: harness/mirror/default.diff md5 $(md5 -q harness/mirror/default.diff) · $($G -cE '^\+[^+]' harness/mirror/default.diff) lines added, $($G -cE '^-[^-]' harness/mirror/default.diff) removed · the mirror's test sources removed (they call the shipped ApiApi, which this library does not write)"
  rm -rf .harness/default/tiffinbox-client/src/test
  guard "the default library's build"
  bg "cd .harness/default && $MV -Dmaven.test.skip=true clean package -pl tiffinbox-client -am" .harness/default.log
  echo "  mvn -o clean package -pl tiffinbox-client -am exit $RE · Downloading/Downloaded from: $($G -cE 'Download(ing|ed) from ' .harness/default.log || true)"; offl .harness/default.log
  echo "  the compile's removal warnings (grep -c 'marked for removal'): $($G -c 'marked for removal' .harness/default.log || true)"
  $G 'marked for removal' .harness/default.log | sed -E 's#^\[WARNING\] .*/(src/main/java/[^:]+):\[([0-9]+),[0-9]+\] #  removal | \1:\2 | #'
  local r=.harness/default/tiffinbox-client/target/generated-sources/openapi
  echo "  the loser's .openapi-generator/FILES (*.java): $($G -c '\.java$' $r/.openapi-generator/FILES) · its api classes: $(ls $r/src/main/java/com/tiffinbox/client/api | sed 's/\.java$//' | paste -sd' ' -)"
  for c in 'import com.fasterxml.jackson.databind' 'import com.fasterxml.jackson.core' 'import com.fasterxml.jackson.datatype' 'import org.openapitools.jackson.nullable' 'import tools.jackson'; do echo "  the loser's imports '$c': $(cat $(find $r/src/main/java -name '*.java') | $G -cF "$c" || true)"; done
  echo "  the loser's ApiClient: $($G -nE 'new MappingJackson2HttpMessageConverter|messageConverters\(' $r/src/main/java/com/tiffinbox/client/ApiClient.java | sed -E 's/^([0-9]+):[[:space:]]*/\1 /' | cut -c1-120 | paste -sd'|' -)"
  echo "  its new ApiClient()'s factory on two class paths: NOT measured in this run (dropped at the cap's order - the probe's NOTES §7 holds 1 run of it)"
  echo "== the anchor's poms: the loser's names (git grep -c over c9-tiffinbox's pom.xml files, the working tree)"
  echo "  $(cd after && cat pom.xml tiffinbox-client/pom.xml tiffinbox-web/pom.xml tiffinbox-core/pom.xml | $G -cE 'restclient</library>|jackson-databind-nullable|<generatorName>java<' || true) lines name the restclient library, jackson-databind-nullable or generatorName java"; }

c_counts() {
  echo "== loc9.py (BLUE's counter, its rule in its header) over four roots in one call: the shipped generated sources, the loser's, TiffinBox's own web module, an empty root"
  mkdir -p $J/emptyroot
  (cd "$U/.harness" && python3 -I "$U/harness/loc9.py" after/tiffinbox-client/target/generated-sources/openapi/src/main/java default/tiffinbox-client/target/generated-sources/openapi/src/main/java after/tiffinbox-web/src/main/java work/emptyroot; echo "  loc9.py exit $?") 2>&1 | sed 's/^/  /'
  echo "  loc9.py's rule (its header): $(sed -n '2p' harness/loc9.py | sed 's/^# //')"
  echo "== plant: a root one level too deep (the shipped generated sources' com/tiffinbox/client/api only)"
  (cd "$U/.harness" && python3 -I "$U/harness/loc9.py" after/tiffinbox-client/target/generated-sources/openapi/src/main/java/com/tiffinbox/client/api) 2>&1 | head -1 | sed 's/^/  plant: /'
  echo "== the operations, the handlers and the generated methods (census's, re-read here)"
  ck genops $GR $SPECF | $G -E 'generated methods|operations' | sed 's/^ *//; s/^/  /'; }

c_location() {
  echo "== the generated create and pause calls' return types (this run's ApiApi.java and CustomersApi.java)"
  echo "  create: $($G -E 'ResponseEntity<[^>]*(<[^>]*>)?> add\(' $GR/src/main/java/com/tiffinbox/client/api/CustomersApi.java | sed 's/^ *//') · pause: $($G -E 'ResponseEntity<[^>]*(<[^>]*>)?> add1\(' $GR/src/main/java/com/tiffinbox/client/api/ApiApi.java | sed 's/^ *//')"
  echo "  the spec's success status for each: $(ck specop $SPECF post /customers | $G -oE 'responses [^ ]+') (create) · $(ck specop $SPECF post '/api/v1/customers/{name}/pauses' | $G -oE 'responses [^ ]+') (pause)"
  echo "== one create through the generated call, beside curl's create of another name (after/, its own JVM on 20993, harness-joined: the second client counts)"
  P=20993; L=LOC; DB=h2l; tb LOC 20993 h2 "$U/.harness/hc"
  health
  echo "  customers before: $(count)"
  caller create "$(B 20993)"
  ask "loc-curl" POST /customers -H "$JSON" --data-binary '{"name":"Curl10","mealsPerDay":1,"pricePerMeal":100,"mealType":"VEG"}'
  echo "  customers after: $(count) · Gen10 $(row Gen10) · Curl10 $(row Curl10)"
  tbstop LOC 20993
  echo "  R1 (API Design Review): the pause's Location renamed away - reachable from the generated client only if its pause call can add a pause; pause's capture prints whether it can"; }

c_diff() { DB=h2; P=20993; L=DH2; tb DH2 20993 h2 "$U/.harness/hc"
  echo "== h2: the spec against the wire on H2 (TiffinBox after/ on 20993, the harness joined, a fresh database)"
  health
  $CURL -s "$(B 20993)/v3/api-docs" > $J/spec-d.raw
  python3 -I -c 'import io,json,sys; d = json.load(open(sys.argv[1], encoding="utf-8")); d.pop("servers", None); b = io.StringIO(); json.dump(d, b, indent=2, ensure_ascii=False); b.write("\n"); open(sys.argv[2], "w", encoding="utf-8").write(b.getvalue())' $J/spec-d.raw $J/spec-d.json
  echo "  the document diff reads: the committed file (= the served document: committed's line); this JVM's (harness-joined) document is not the claim"
  echo "  the second client before: count $(count) · keys $(keyrows) · Ravi $(row Ravi)"
  rm -rf $J/wire-h2; mkdir -p $J/wire-h2
  echo "== h2: python3 -I harness/specwire9.py send $P (BLUE_RUN=$RUNNO; the request set is BLUE's, its names its own; each request and answer filed as JSON)"
  (cd $J && BLUE_RUN=$RUNNO python3 -I "$U/harness/specwire9.py" send $P wire-h2) 2>&1 | sed 's/^/  sent: /'
  echo "  the second client after: count $(count) · keys $(keyrows) · Ravi $(row Ravi)"
  tbstop DH2 20993
  echo "== diff (a): the committed file against the wire, no third argument"
  python3 -I harness/specwire9.py diff $SPECF $J/wire-h2 2>&1 | sed 's/^/  (a) /'; echo "  (a) exit ${PIPESTATUS[0]}"
  echo "== diff (b): the third argument = THIS run's generated sources ($GR)"
  python3 -I harness/specwire9.py diff $SPECF $J/wire-h2 "$GR" 2>&1 | sed 's/^/  (b) /'; echo "  (b) exit ${PIPESTATUS[0]}"
  echo "== the plant: the file with mealType renamed meal_type (one sed), diff (a) and (b)"
  sed 's/"mealType"/"meal_type"/g' $SPECF > $J/spec-plant.json
  python3 -I harness/specwire9.py diff $J/spec-plant.json $J/wire-h2 2>&1 | $G -E '^(KINDS|DISAGREEMENTS)' | sed 's/^/  plant (a) /'
  python3 -I harness/specwire9.py diff $J/spec-plant.json $J/wire-h2 "$GR" 2>&1 | $G -E '^(KINDS|DISAGREEMENTS)' | sed 's/^/  plant (b) /'
  rm -rf $J/wire-empty $J/gen-empty; mkdir -p $J/wire-empty $J/gen-empty
  python3 -I harness/specwire9.py diff $SPECF $J/wire-empty 2>&1 | sed 's/^/  empty wire: /'; echo "  empty wire: exit ${PIPESTATUS[0]}"
  python3 -I harness/specwire9.py diff $SPECF $J/wire-h2 $J/gen-empty 2>&1 | $G -E '^(KINDS|DISAGREEMENTS)|refused|empty' | sed 's/^/  empty generated root: /'; echo "  empty generated root: exit ${PIPESTATUS[0]}"
  echo "  U09's values block (before's rows): $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit09/README.md | $G -E '^diff: ' | $G -oE 'kinds_a=[0-9]+ rows_a=[0-9]+ kinds_b=[0-9]+ rows_b=[0-9]+|kinds_b=[0-9]+ rows_b=[0-9]+ kinds_a=[0-9]+ rows_a=[0-9]+')"
  echo "  the key header named: the spec $(python3 -I -c 'import json,sys; d = json.load(open(sys.argv[1])); print(sum(1 for v in d["paths"].values() for o in v.values() for x in o.get("parameters", []) if x.get("in") == "header"))' $SPECF) header parameters · the generated sources @RequestHeader $(cat $(find $GR/src/main/java -name '*.java') | $G -c '@RequestHeader' || true)"; }

movedone() { local port=$1 m=$2 p=$3 w; shift 3; : > $J/mv.h; : > $J/mv.b
  w=$($CURL --http1.1 -sS -D $J/mv.h -o $J/mv.b -w '%{http_code} %{content_type} %{size_download}' --max-time 5 -X "$m" "$@" "$(B $port)$p" 2> /dev/null)
  local bm; bm=$(sed -E 's/"timestamp":"[^"]*"/"timestamp":"<masked>"/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' $J/mv.b | md5 -q | cut -c1-12)
  w=$(echo "$w" | awk '{ print $1, $2 }')
  echo "  $SIDE | $m $p$( [ -n "${TAG:-}" ] && echo " [$TAG]") -> $w $(sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' $J/mv.b | wc -c | tr -d ' ') · Allow {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Aa]llow: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)} · Accept-Patch {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Aa]ccept-[Pp]atch: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)} · Location {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Ll]ocation: //p' | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/')} · body $bm"; }
movedside() { local side=$1 port=$2 a
  P=$port; L=moved-$side; DB=h2; TREE=$side tb moved-$side $port h2 ""
  SIDE=$side
  movedone $port GET /customers/Ravi
  movedone $port GET $API/Ravi
  TAG=merge movedone $port PATCH $API/Meera -H "$MPT" --data-binary '{"mealsPerDay":2}'
  TAG=json-patch movedone $port PATCH $API/Sunil -H "$JPT" --data-binary '[{"op":"replace","path":"/mealsPerDay","value":2}]'
  movedone $port PATCH /customers
  movedone $port OPTIONS /customers/Ravi
  movedone $port GET /nowhere
  movedone $port GET /dashboard -H 'Accept: text/html'
  movedone $port GET /customers/new -H 'Accept: text/html'
  for a in $THREE /swagger-ui.html /swagger-ui/index.html; do movedone $port GET $a; done
  movedone $port GET /customers/Nobody
  movedone $port GET $API/Nobody
  TAG=merge movedone $port PATCH $API/Nobody -H "$MPT" --data-binary '{"mealsPerDay":2}'
  movedone $port POST "$API/Nobody/pauses?days=1"
  movedone $port GET $API/Nobody/pauses/1
  tbstop moved-$side $port; }
c_moved() { echo "== U09's nineteen requests (its c_moved list, copied) on before (20996) and after/ (20990), H2, each its own JVM, no harness; bodies hashed (and sized) with Boot's /error timestamp and any port masked"
  movedside before 20996; movedside after 20990
  echo "== the build-level witnesses: the web jar before and after (the parent's project.build.outputTimestamp makes it reproducible)"
  echo "  web jar md5: before $(md5 -q .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar) · after $(md5 -q .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar)"
  diff <(unzip -lv .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | awk 'NF >= 8 && $1 ~ /^[0-9]+$/ { print $7, $8 }' | sort -k2) <(unzip -lv .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | awk 'NF >= 8 && $1 ~ /^[0-9]+$/ { print $7, $8 }' | sort -k2) | $G '^[<>]' | sed 's/^/  entry moved: /' | head -20
  echo "  entries whose CRC moved before -> after: $(diff <(unzip -lv .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | awk 'NF >= 8 && $1 ~ /^[0-9]+$/ { print $7, $8 }' | sort -k2) <(unzip -lv .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | awk 'NF >= 8 && $1 ~ /^[0-9]+$/ { print $7, $8 }' | sort -k2) | $G -c '^>' || true)"; }
c_seven() { local side tree port i
  echo "== the seven (c5-unit11/curlset.sh, no key header), each tree its own JVM, H2, no harness: the expected $S466"
  for side in before after; do [ $side = before ] && port=20996 || port=20990
    P=$port; L=seven-$side; DB=h2; TREE=$side tb seven-$side $port h2 ""
    sh $CURLSET $port .harness/run/seven-$side/secrets/tiffinbox/shutdown-token > $J/seven-$side.txt 2>&1
    i=0; while kill -0 "$(cat .harness/run/seven-$side/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 400 ] || die "seven-$side: the seven's POST /shutdown did not stop it"; sleep 0.05; done
    echo "  $side: the seven's requests (the access log, a harness-free start): $(alog seven-$side | awk '{ print $1, $2, $3 }' | paste -sd'|' -)"
    tbstop seven-$side $port
    echo "  $side: the seven $(md5 -q $J/seven-$side.txt) ($(wc -l < $J/seven-$side.txt | tr -d ' ') lines)"; done
  echo "  before -> after/: $(cmp -s $J/seven-before.txt $J/seven-after.txt && echo equal || echo DIFFER) · not a witness for the client - a witness only for \"adding the module moved no answer of TiffinBox\""; }
oldsurface2() { local port=$1 out=$2 BB="http://127.0.0.1:$1" t=$U/$J/os
  printf 'name,mealsPerDay,pricePerMeal,mealType\nChitra,1,130,VEGAN\n' > "$t.csv"; : > "$out"
  one() { local label=$1; shift; local w rc
    w=$($CURL --http1.1 -sS -D "$t.h" -o "$t.b" -w '%{http_code} %{content_type} %{size_download}' --max-time 10 "$@" 2>"$t.e"); rc=$?
    { echo "== $label -> $w (curl exit $rc)"; maskh "$t.h" | $G -v '^$'
      local n; n=$(wc -c < "$t.b" | tr -d ' ')
      if [ "$n" -le 700 ]; then echo "body: $(tr -d '\r' < "$t.b" | tr '\n' '~' | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g')"; else echo "body: $n B md5 $(md5 -q "$t.b")"; fi; } >> "$out"; }
  one "GET /customers" "$BB/customers"
  one "GET /customers/Ravi" "$BB/customers/Ravi"
  one "POST /customers (JSON, a fresh name)" -X POST -H 'Content-Type: application/json' --data-binary '{"name":"Asha","mealsPerDay":1,"pricePerMeal":110,"mealType":"VEG"}' "$BB/customers"
  one "GET /revenue" "$BB/revenue"
  one "GET /dashboard (Accept: application/json)" -H 'Accept: application/json' "$BB/dashboard"
  one "GET /dashboard (Accept: text/html)" -H 'Accept: text/html' "$BB/dashboard"
  one "GET /customers/new" -H 'Accept: text/html' "$BB/customers/new"
  one "POST /customers (the form)" -X POST -H 'Content-Type: application/x-www-form-urlencoded' --data-binary 'name=Bina&mealsPerDay=2&pricePerMeal=100&mealType=VEGAN' "$BB/customers"
  one "POST /customers/import (a two-line CSV)" -X POST -F "file=@$t.csv;type=text/csv;filename=two.csv" "$BB/customers/import"
  : > "$t.h"; : > "$t.b"
  perl -e '$SIG{ALRM}=sub{kill "TERM",$pid; exit 3}; alarm 10; $pid=open(my $c,"-|",@ARGV) or die; $s=0; while(defined($l=<$c>)){print $l; if($l=~/^\r?\n$/){last if $s} else {$s=1}} kill "TERM",$pid; exit 0' \
     curl --noproxy '*' --http1.1 -sS -N -D "$t.h" -H 'Accept: text/event-stream' "$BB/customers/feed" > "$t.b" 2>"$t.e"; local frc=$?
  { echo "== GET /customers/feed (by count: headers + the first event, to its blank line, alarm 10 s) -> $(tr -d '\r' < "$t.h" | head -1 | cut -d' ' -f2) $(tr -d '\r' < "$t.h" | $G -i '^Content-Type:' | cut -d' ' -f2) $(wc -c < "$t.b" | tr -d ' ') (reader exit $frc)"
    maskh "$t.h" | $G -v '^$'; echo "body: $(tr -d '\r' < "$t.b" | tr '\n' '~')"; } >> "$out"
  one "GET /kitchen" "$BB/kitchen"
  one "GET /nowhere" "$BB/nowhere"
  one "POST /shutdown (no token, last)" -X POST "$BB/shutdown"
  rm -f "$t".*; }
c_surface() { local side port i
  echo "== the old surface by count (U09's reader, copied), each tree its own JVM, H2, no harness: the expected $U4SURF"
  for side in before after; do [ $side = before ] && port=20996 || port=20990
    P=$port; L=surface-$side; DB=h2; TREE=$side tb surface-$side $port h2 ""
    oldsurface2 $port $J/surface-$side.txt
    tbstop surface-$side $port
    echo "  $side: the old surface $(md5 -q $J/surface-$side.txt) ($($G -c '^== ' $J/surface-$side.txt) requests, $(wc -l < $J/surface-$side.txt | tr -d ' ') lines)"; done
  echo "  before -> after/: $(cmp -s $J/surface-before.txt $J/surface-after.txt && echo equal || echo DIFFER)"
  diff $J/surface-before.txt $J/surface-after.txt | sed 's/^/    moved: /'
  echo "== the self-test (S9.14, the harness's plant - LABELLED, not a finding about TiffinBox): a ShallowEtagHeaderFilter on /* (probe.Etag, U09's copy), after/, on 20994"
  P=20994; L=seven-etag; SRC=probe.Etag tb seven-etag 20994 h2 "$U/.harness/hc"
  sh $CURLSET 20994 .harness/run/seven-etag/secrets/tiffinbox/shutdown-token > $J/seven-etag.txt 2>&1
  i=0; while kill -0 "$(cat .harness/run/seven-etag/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 400 ] || die "seven-etag did not stop"; sleep 0.05; done; tbstop seven-etag 20994
  P=20994; L=surface-etag; SRC=probe.Etag tb surface-etag 20994 h2 "$U/.harness/hc"; oldsurface2 20994 $J/surface-etag.txt; tbstop surface-etag 20994
  echo "  planted: the seven $(md5 -q $J/seven-etag.txt) (unchanged: $(cmp -s $J/seven-etag.txt $J/seven-after.txt && echo yes || echo NO)) · the old surface $(md5 -q $J/surface-etag.txt) (moved: $(cmp -s $J/surface-etag.txt $J/surface-after.txt && echo NO || echo yes)) · the feed's line: $($G '^== GET /customers/feed' $J/surface-etag.txt | sed -E 's/^== //')"; }

c_inert() { local f
  echo "== every request block of this run that says whether it sent the key header, by capture"
  for f in .r-call.new .r-pause.new .r-location.new .r-diff.new; do [ -f $f ] || continue; echo "  $f: sent the key: $($G -c '^     sent: key header yes' $f || true) · did not: $($G -c '^     sent: key header no' $f || true)"; done
  echo "  the runner's requests with the key (its keyed mode, the printed alternative): $($G -c '^  CLIENT add1(Ravi, 2) -> 201' .r-pause.new || true) in pause · the runner's modes run in this run: $(cat .r-call.new .r-pause.new .r-location.new 2> /dev/null | $G -cE '^  CLIENT builder ' || true)"
  f=$J/wire-h2; echo "  $(basename $f): $(python3 -I -c 'import json,os,sys; d = sys.argv[1]; r = [json.load(open(os.path.join(d, x))) for x in sorted(os.listdir(d))]; print("requests %d · with the key: %s" % (len(r), ",".join(x["name"] for x in r if any(k.lower() == sys.argv[2].lower() for k in x["request"]["headers"])) or "none"))' $f "$KEYH")"
  echo "== the key table, read by the second client on every harness-joined JVM of the run"
  $G -hE '^  (before|after the refused call|after the keyed call): keys|^  the second client (before|after)' .r-pause.new .r-diff.new | sed 's/^/  /'
  echo "  location's JVM: $($G -E '^  customers (before|after)' .r-location.new | sed 's/^ *//' | paste -sd'|' -)"
  echo "  the harness-free JVMs (census, committed, call, pause's first, moved, seven, surface, the exercise) are not read after the fact: H2 in memory ends with its JVM; their witness is the access log"; }

# the exercise: break.sh then check.sh on a copy of after/ (.harness/exercise/tree), TiffinBox's jar alone on 20998, from the exercise's
# folder, env -i, under bash then zsh -f; the solution = apply.sh on the broken copy, then check.sh; the refused "solutions" each their own copy
exrun() { local v=$1 sh=$2 o cmd
  guard "the exercise, $v, $sh"
  rm -rf .harness/exercise/tree; copy after .harness/exercise/tree
  case $v in broken) cmd='sh break.sh "$0" && sh check.sh "$0"' ;; solved) cmd='sh break.sh "$0" > /dev/null && sh apply.sh "$0" > /dev/null && sh check.sh "$0"' ;; *) cmd="sh break.sh \"\$0\" > /dev/null && HOW=$v sh apply.sh \"\$0\" > /dev/null && sh check.sh \"\$0\"" ;; esac
  echo "== the exercise, h2, $v, $sh (env -i, from the exercise's folder; the tree a fresh copy of after/; built offline from the receipt's seed copy, its jar alone on 20998):"
  if [ $sh = bash ]; then o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=20998 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" bash -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1)
  else o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=20998 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" /bin/zsh -f -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1); fi
  printf '%s\n' "$o" | sed -E 's/127\.0\.0\.1:20998/127.0.0.1:<port>/g; s/^/  /'
  offl exercise/check.build.log
  [ "$(listeners 20998)" = 0 ] || die "the exercise left something listening on 20998"; }
c_exercise() { local v sh
  rm -rf .harness/exercise; mkdir -p .harness/exercise
  for v in broken solved; do for sh in bash zsh; do exrun $v $sh; done; done
  for v in none genedit movedserver; do exrun $v bash; done
  rm -rf exercise/check.run exercise/apply.run; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.spec.json exercise/check.call.txt exercise/check.cp exercise/apply.build.log exercise/apply.jvm.log exercise/apply.spec.json
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures${DEVCAPS:+ (DEVELOPMENT: only $DEVCAPS - not a run of record)}"
cap tests c_tests
cap census c_census
cap modules c_modules
cap generate c_generate
cap jackson c_jackson
cap committed c_committed
cap call c_call
cap pause c_pause
cap mock c_mock
cap default c_default
cap counts c_counts
cap location c_location
cap diff c_diff
cap moved c_moved
cap seven c_seven
cap surface c_surface
cap inert c_inert
cap exercise c_exercise

# ---- the end: the sweep, the values, the published hashes -------------------------------------------------------------------------------
[ -z "$(echo $PIDS)" ] || die "a JVM of this run is still running: $PIDS"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
[ -z "$(dk ps -aq --filter label=org.testcontainers=true)" ] || die "a container of this run is left"
NI1=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI1" = "$NI0" ] && [ "$VOL1" = "$VOL0" ] || die "R.322: images $NI0 -> $NI1, volumes $VOL0 -> $VOL1"
AD1=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true); [ "$AD1" = "$AD" ] || die "the anchor moved during the run"
pin before-tree before; pin after-tree after
MDB=$(find . ../c9-tiffinbox ../c9-unit09 -name '*.mv.db' -not -path './.harness/*' -not -path '../c9-unit09/.harness/*' 2> /dev/null | wc -l | tr -d ' ')
[ "$MDB" = 0 ] || die "an H2 file outside .harness/"
[ -z "$(ls exercise | $G -v -xE 'README.md|SOLUTION.md|apply.sh|break.sh|check.sh')" ] || die "the exercise left a file in exercise/"
VALS="$VALS
static: $STV
gloss: $GLV
spoken: $SPV
build: seed_files=$NF0 seed_bytes=$NB0 central_only=$CO"
[ -n "${DEVCAPS:-}" ] && { printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'; echo "c9-unit10: DEVELOPMENT run ($DEVCAPS) - nothing published"; exit 2; }
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
VO=$(ck values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; die "README.md's values block is not this run's (harness/chk10.py values)"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM of this run, ports free, no container left, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1 · the anchor against after/ as at the start · the tree pins · *.mv.db outside .harness 0 · the values block = this run's"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit10: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit10: every capture = published ($NCAPS) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"
