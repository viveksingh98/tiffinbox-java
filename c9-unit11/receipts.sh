#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 11 "Spring REST Docs" - this unit's receipts. Course 9's EIGHTH anchor change, Section 2's fifth, and the anchor's first
# change to test scope and to the build's documentation step: before is a link to ../c9-unit10/after (U10's after: three modules, the
# committed file 20,306 B); after/ is a frozen copy of ../c9-tiffinbox after this unit's change - the parent gains one property
# (asciidoctor-maven-plugin.version 3.2.0); the web module gains spring-restdocs-mockmvc and spring-boot-starter-restdocs in test scope,
# Asciidoctor's build step at prepare-package, src/docs/asciidoc (index.adoc, tiffinbox-docs.css) and one test, TiffinBoxRestDocsTest.
# The harness (never in the jar or the module): the statement and request witnesses, Routes, the ShallowEtag plant - copied from U10's
# harness; unit 11's second client (probe.u11.U11Probe, /probe/u11/**); BLUE's specwire9.py and seal9.py, U08's cdp.mjs and cdp9.mjs,
# byte-equal; four mirror patches (harness/mirror: fail, accept, driven, html), each applied to a scratch copy of after/ only. Every line
# they print is "the harness's". Chrome: headless, sealed (a dead proxy, the resolver rules, a throwaway profile), the generated pages read
# as file://. No PostgreSQL capture (callpg dropped: H2 only).
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5):
#   tests     the whole reactor at package, its Docker-free twin, verify (the ITs), the web-only form, the -DskipTests form; 49 + the new one
#   change    the parent's <modules>, the module table, the pom diffs, the test scope resolved, the build step's effective version
#   pass      the shipped test alone: its eight snippets with md5s, http-response.adoc, the socket twin on 21000 (H2, no harness)
#   status    the fail mirror's run: the two status tests (check first, document first), each listing; the package build on that mirror
#   field     the same run's four field tests (never sent, left undocumented; each order)
#   accept    the accept mirror: the public read under three Accepts, MockMvc's Content-Type beside the socket's
#   driven    the driven mirror: the Nobody 404 documented with and without name (a candidate, not shipped); the wire on 21005
#   html      the shipped page, the nofonts and default pages (the html mirror): host census per page, the generator, the footer masked
#   sealed    the three pages in sealed headless Chrome (DevTools 21007): the judge per page, the NetLogs as found, the plants
#   compare   REST Docs' directories and snippets against spring doc's operations; specwire9 (a) and (b); the two socket tests
#   committed the committed file unchanged, = the served document, OpenApiSpecTest in the package run
#   moved     U10's nineteen requests on before and after/; the web jar per entry
#   seven     c5-unit11/curlset.sh on before and after/ (each its own JVM)
#   surface   the old surface by count on before and after/, and the S9.14 plant
#   inert     the key header and the key table across every capture of the run
#   exercise  break.sh, check.sh on the broken copy, the solution (apply.sh) and the refused "solutions", bash and zsh -f, H2
# Ports (U11's band, 21000-21009): 21000 after/ on H2, no harness · 21003 the harness-joined JVM (compare's specwire9 send) · 21004 the
# S9.14 plant · 21005 the mirrors' wire (driven) · 21006 before · 21007 Chrome's DevTools · 21008 the exercise · 21001, 21002, 21009
# never bound (callpg dropped). During mvn verify only: 21280-21284, one per IT. The dead proxy 127.0.0.1:9 is a connect target, never
# bound. Every store on 127.0.0.1; every curl --noproxy '*'. The key header is sent only by specwire9.py's pause-key request (KEYH).
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
C9R=${C9R:-"/Users/$ME/Downloads/Youtube Content/LearnProgrammingWithVivek/rest-apis-done-right"}   # the course's folder (briefs, research)
SEED=${SEED:-"$C9R/_research/m2-seed-c9-s2"}   # the course's Section 2 seed
PK="$C9R/_research/s2-probe-2026-11-24"; BK="$C9R/_research/s2-blue-2026-11-24"; ADV="$C9R/_research/docs-2026-11-24/advisories"
S2B="$C9R/_briefs/UNIT-BRIEFS-S2-CONTRACTS.md"
C6U=${C6U:-"$UP/c6-unit23/harness"}                    # Course 6 unit 23's harness: netlog.py, read in place (never copied)
CHROME=${CHROME:-"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"}
export C9R
RUNNO=${RUNNO:-0}                                     # the run of record's number (1, 2, 3): specwire9.py's BLUE_RUN; 0 = development
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
PIDS=""; TC0=""; INTR=""; mpid=""; pollpid=""; CPID=""
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "curlset.sh") || index($0, "check.sh") || index($0, "apply.sh") || index($0, "cdp.mjs") || index($0, "cdp9.mjs") || index($0, "c9-unit11/.harness/chrome-") || $3 ~ /(^|\/)javac$/) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
tcrm() { local c n=0 i=0; [ -n "$TC0" ] || return 0
  while [ $i -lt 10 ]; do
    for c in $(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null); do dk rm -fv "$c" > /dev/null 2>&1 && n=$((n + 1)); done
    [ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] && break; sleep 0.5; i=$((i + 1)); done
  [ "$n" = 0 ] || echo "  the trap: $n Testcontainers container(s) removed with their volumes (rm -fv)" >&3; }
trap 'trap "" INT TERM; [ -z "$CPID" ] || killtree "$CPID"; for p in $pollpid $mpid $PIDS; do [ -z "$p" ] || killtree "$p"; done; for p in $pollpid $mpid $PIDS $CPID; do if kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; tcrm; rm -rf .harness/chrome-* exercise/check.run; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.body.json; [ -z "$INTR" ] || rm -f .r-*.new; rmdir .r-lock 2> /dev/null || rm -rf .r-lock; true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git unzip patch node shasum /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|SPRINGDOC_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT|BLUE_RUN)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit11 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }') · run $RUNNO"

# ---- gates before anything is built: the folder, the link, the pins, the anchor, the static check, the prose, the exercise ----------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'cdp.mjs cdp9.mjs chk11.py dur9.py mirror s911.py seal9.py specwire9.py src tree11.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
[ "$(ls harness/mirror | paste -sd' ' -)" = 'accept.diff driven.diff fail.diff html.diff' ] || die "harness/mirror holds another file, or misses one"
HSRC='probe/Etag.java probe/Http.java probe/Routes.java probe/Witness.java probe/u11/U11Probe.java'
[ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$HSRC" ] || die "harness/src holds another file, or misses one"
for f in loc9.py src/probe/u09/SchemeCopy.java src/probe/u10/Caller.java mirror/default.diff mirror/hc5.diff; do [ ! -e harness/$f ] || die "harness/$f: a U09/U10 instrument this unit does not carry"; done
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md apply.sh break.sh check.sh' ] || die "exercise/ holds another file, or misses one"
[ -L before ] && [ "$(readlink before)" = ../c9-unit10/after ] || die "before must be a link whose text is exactly ../c9-unit10/after (found: $( [ -L before ] && readlink before || echo 'not a link'))"
[ -d after ] && [ ! -L after ] || die "after/ is this unit's own frozen tree, a directory, not a link"
for t in before after; do [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-client/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/ - never built in place"; true; done
echo "  before -> $(readlink before) (a link, the text exact) · after/ a directory (the frozen copy) · no secrets/, target/ or .m2-demo/ in either"
$G -v '^ *#' harness/src/probe/*.java harness/src/probe/u11/*.java | $G -q 'Thread\.sleep' && die "R.412: a Thread.sleep in the harness"
for f in Witness Http Etag Routes; do w=$(awk -v n="harness/src/probe/$f.java" '$1 == "file" && $2 == n { print $3 }' ../c9-unit10/receipts.md5)
  [ -n "$w" ] && [ "$(md5 -q harness/src/probe/$f.java)" = "$w" ] || die "harness/src/probe/$f.java is not U10's published file (../c9-unit10/receipts.md5)"; done
echo "  harness/src/probe: Witness, Http, Etag, Routes = ../c9-unit10/receipts.md5's file lines (copied from U10's harness) · u11/U11Probe = this unit's (U10Probe, renamed)"
SW9=$(awk '$2 ~ /instruments\/specwire9\.py$/ { print $1 }' "$BK/MD5SUMS"); SL9=$(awk '$2 ~ /instruments\/seal9\.py$/ { print $1 }' "$BK/MD5SUMS")
[ -n "$SW9" ] && [ "$(md5 -q harness/specwire9.py)" = "$SW9" ] && [ "$(md5 -q "$BK/instruments/specwire9.py")" = "$SW9" ] || die "harness/specwire9.py is not BLUE's instrument (its MD5SUMS line: ${SW9:-none})"
[ -n "$SL9" ] && [ "$(md5 -q harness/seal9.py)" = "$SL9" ] && [ "$(md5 -q "$BK/instruments/seal9.py")" = "$SL9" ] || die "harness/seal9.py is not BLUE's instrument (its MD5SUMS line: ${SL9:-none})"
W10=$(awk '$1 == "file" && $2 == "harness/specwire9.py" { print $3 }' ../c9-unit10/receipts.md5); [ "$(md5 -q harness/specwire9.py)" = "$W10" ] || die "harness/specwire9.py is not U10's copy"
for f in seal9.py cdp.mjs cdp9.mjs; do w=$(awk -v n="harness/$f" '$1 == "file" && $2 == n { print $3 }' ../c9-unit08/receipts.md5)
  [ -n "$w" ] && [ "$(md5 -q harness/$f)" = "$w" ] || die "harness/$f is not U08's published file (../c9-unit08/receipts.md5)"; done
echo "  harness/specwire9.py: BLUE's (md5 $SW9 = its MD5SUMS line = U10's copy) · harness/seal9.py: BLUE's (md5 $SL9 = its MD5SUMS line = U08's copy) · harness/cdp.mjs, cdp9.mjs = U08's file lines (cdp9.mjs's version mode only, and its rendered mode once as the proof it finds no file:// tab)"
[ "$(sed -n '5,$p' harness/tree11.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit10/harness/tree10.py | md5 -q)" ] || die "harness/tree11.py's code is not tree10.py's"
for u in 01 02 03 04 05 06 07 08 09 10; do [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit$u/harness/dur9.py)" ] || die "harness/dur9.py is not ../c9-unit$u's copy (dur9 as shipped)"; done
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"
  [ ! -f "$C9R/_builders/dur9.py" ] || [ "$(md5 -q "$C9R/_builders/dur9.py")" = "$D9" ] || die "harness/dur9.py is not C9/_builders/dur9.py"
else D9N="(the registry is not on this machine: U01-U10's copies are the pin)"; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit01-10's copies $D9N · tree11.py's code = tree10.py's"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit10/receipts.md5)
[ -n "$UA" ] || die "../c9-unit10/receipts.md5 has no after-tree line"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree11.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$nm" = after-tree ] || [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit10/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree11.py $dir/ -> $got = receipts.md5's $nm line$( [ "$nm" = before-tree ] && echo " = ../c9-unit10/receipts.md5's after-tree line")"; }
pin before-tree before; pin after-tree after
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true)
echo "  after/ against ../c9-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures its own frozen after/' )"
HF="harness/chk11.py harness/s911.py harness/tree11.py harness/dur9.py harness/specwire9.py harness/seal9.py harness/cdp.mjs harness/cdp9.mjs harness/mirror/fail.diff harness/mirror/accept.diff harness/mirror/driven.diff harness/mirror/html.diff $(for f in $HSRC; do printf 'harness/src/%s ' $f; done)exercise/check.sh exercise/apply.sh exercise/break.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's scripts: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
for f in fail accept driven html; do echo "  harness/mirror/$f.diff: md5 $(md5 -q harness/mirror/$f.diff) · $(head -1 harness/mirror/$f.diff | cut -c3-140)"; done
ST=$(python3 -I -B harness/chk11.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
STV=$(printf '%s\n' "$ST" | sed -n 's/^VALUES //p')
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s911.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U11 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s911, per sentence): /'
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b|<measure>' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
GL=$(python3 -I -B harness/chk11.py gloss README.md) || die "the gloss: $(printf '%s\n' "$GL" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$GL" | $G -v '^VALUES ' | sed 's/^/  /'
GLV=$(printf '%s\n' "$GL" | sed -n 's/^VALUES //p')
HOOK=$(python3 -I -B harness/chk11.py hook); EXQ=$(python3 -I -B harness/chk11.py exq); GLS=$(python3 -I -B harness/chk11.py gloss-line)
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S2B's Unit 11 Hook line), byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SP=$(python3 -I -B harness/chk11.py spoken "$HOOK" "$EXQ") || die "the spoken lines: $(printf '%s\n' "$SP" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$SP" | $G -v '^VALUES ' | sed 's/^/  /'
SPV=$(printf '%s\n' "$SP" | sed -n 's/^VALUES //p')
printf '%s\n\n%s\n\n%s\n' "$HOOK" "$EXQ" "$GLS" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s911.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
printf '%s\n' "$SW" | tail -1 | $G -qE ' refused: 0$' || die "a refused reading in a spoken line: $(printf '%s\n' "$SW" | $G ' line ' | head -3 | paste -sd';' -)"
echo "  the hook, the exercise's line and the gloss through s911.py (every family, the carried base and dur9 inside it): refused 0"; rm -f .r-lock/spoken.md
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
$G -qE '^rm -f check\.' exercise/check.sh || die "exercise/check.sh must remove its saved files before it builds"
! $G -qE '(^|[^A-Za-z0-9_.-])path=|[$][{]?path([^A-Za-z0-9_]|$)' exercise/check.sh exercise/apply.sh exercise/break.sh || die "an exercise script names a variable path - under zsh that is the PATH array (BLUE C9-U06's finding): rpath"
$G -qF 'sh apply.sh' exercise/SOLUTION.md || die "SOLUTION.md must give the solution as apply.sh's run"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh exercise/check.sh exercise/apply.sh exercise/break.sh | $G -qwE "$K1|$K2" || die "a script names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket"
DK=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -vF 'echo "' | $G -nE '(^|[ ;(])docker (run|exec|rm|ps|port|info|images|volume|image|pull|logs|inspect)\b' | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.344: receipts.sh calls docker without the pinned socket: $DK"
RMF=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) rm( +-[a-z]+)*' | sort -u | paste -sd'|' -)
[ "$RMF" = 'dk rm -fv' ] || die "R.387: receipts.sh removes a container without its volumes (found: ${RMF:-none})"
# R.391 (flag 15's forms): every Maven build names the module its claim is about with -am, or is the whole reactor
MVL=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -F '$MV ')
MVA=$(printf '%s\n' "$MVL" | $G -vF -- '-pl tiffinbox-web -am' | $G -vF -- '-pl tiffinbox-client -am' | $G -cF -- '-pl ' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh with a -pl form other than '-pl tiffinbox-web -am' or '-pl tiffinbox-client -am'"
MVB=$(printf '%s\n' "$MVL" | $G -F '.harness/before' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVB" = 0 ] || die "R.391: before is built only with -pl tiffinbox-web -am"
echo "  R.391 (flag 15's forms): Maven builds -pl tiffinbox-web -am $(printf '%s\n' "$MVL" | $G -cF -- '-pl tiffinbox-web -am') · -pl tiffinbox-client -am $(printf '%s\n' "$MVL" | $G -cF -- '-pl tiffinbox-client -am' || true) · the whole reactor (no -pl) $(printf '%s\n' "$MVL" | $G -vcF -- '-pl ' || true) · another form 0 · before only with -pl tiffinbox-web -am"
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
    gsub(/\[ *[0-9.:]+ (s|min)\]/, "[<t>]")
    gsub(/[0-9]+ ms/, "<t>")
    gsub(/pid [0-9]+/, "pid <n>")
    gsub(/Last updated [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} [+-][0-9]{4}/, "Last updated <masked>")
    gsub(/[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?( ?[A-Z]{3,4}|Z|[+-][0-9:]+)?(\[[A-Za-z_\/]+\])?/, "<time>")
    gsub(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/, "<uuid>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'took 812 ms' '"timestamp":"2026-11-24T07:12:01.123+01:00"' "$U/x $HOME/y" 'Last updated 2026-11-25 06:58:03 +0100' '[INFO] TiffinBox Web ...... SUCCESS [ 11.955 s]' | mask)
[ "$(printf '%s\n' "$MP" | paste -sd'|' -)" = 'Started TiffinBoxServer in <t> (process running for <t>)|took <t>|"timestamp":"<time>"|…/x ~/y|Last updated <masked>|[INFO] TiffinBox Web ...... SUCCESS [<t>]' ] || die "the mask's self-test: $(printf '%s\n' "$MP" | paste -sd'|' -)"
maskh() { tr -d '\r' < "$1" | sed -E 's/^(Date|date): .*/\1: <masked>/; s/(JSESSIONID=)[^;]*/\1<masked>/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/^(Expires): .*/\1: <masked>/; s/^(Keep-Alive): .*/\1: <masked>/'; }
MH=$(printf 'Date: Tue, 24 Nov 2026 08:00:00 GMT\r\nSet-Cookie: JSESSIONID=ABC123; Path=/; HttpOnly\r\nLocation: http://127.0.0.1:21000/dashboard\r\nExpires: Tue, 24 Nov 2027 08:00:00 GMT\r\nKeep-Alive: timeout=60\r\n' > .r-lock/mh; maskh .r-lock/mh | paste -sd'|' -; rm -f .r-lock/mh)
[ "$MH" = 'Date: <masked>|Set-Cookie: JSESSIONID=<masked>; Path=/; HttpOnly|Location: http://127.0.0.1:<port>/dashboard|Expires: <masked>|Keep-Alive: <masked>' ] || die "the header mask's self-test: $MH"
HM=$(printf '%s\n' '<div id="footer-text">' 'Last updated 2026-11-25 06:58:03 +0100' '</div>' > .r-lock/hm.html; python3 -I -B harness/chk11.py maskhtml .r-lock/hm.html | paste -sd'|' -; rm -f .r-lock/hm.html)
[ "$HM" = '<div id="footer-text">|Last updated <masked>|</div>' ] || die "the HTML mask's self-test: $HM"
echo "  masks: the log mask masked a Started line's times, a millisecond count, Boot's /error timestamp, the folders, the home, the page's Last updated line and a reactor line's time; the header mask a planted Date, session cookie, port, Expires and Keep-Alive; the HTML mask a planted footer clock"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
$G -qF 'S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)' ../c9-unit10/receipts.sh || die "../c9-unit10/receipts.sh no longer reads the seven's md5 off ../c7-unit31/receipts.sh"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SURF=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh)
[ ${#U4SURF} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh (SURF=)"
U10V=$(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit10/README.md | $G -oE '(^| )(seven|surface)=[0-9a-f]{8}( |$)' | sed 's/^ *//; s/ *$//' | paste -sd' ' -)
[ "$U10V" = "seven=$(echo $S466 | cut -c1-8) surface=$(echo $U4SURF | cut -c1-8)" ] || die "U10's README values block ($U10V) is not the seven and the surface read off the receipts"
echo "  the seven: expected $S466 (../c7-unit31/receipts.sh's S466= line, as ../c9-unit10/receipts.sh reads it) · the old surface: expected $U4SURF (../c9-unit04/receipts.sh's SURF= line) · both = U10's README values block ($U10V)"
FA=$(cat "$ADV/fetched-at.txt" 2> /dev/null | head -1); [ -n "$FA" ] || die "the advisories' fetched-at line is missing ($ADV)"
FAE=$(python3 -I -c 'import datetime,sys; t = datetime.datetime.strptime(sys.argv[1], "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=datetime.timezone.utc); print(int((datetime.datetime.now(datetime.timezone.utc) - t).total_seconds() // 3600))' "$FA")
[ "$FAE" -lt 24 ] || die "S9.36 (flag 29): the filed advisory read is $FAE hours old - more than a day; a re-read is the orchestrator's act"
echo "  S9.36: today's filed read ($ADV), fetched at $FA ($FAE h before this run; not re-read: no network) · $(head -1 "$ADV/tomcat-11.0.30-section.txt") · OSV for REST Docs: $($G -i restdocs "$ADV/osv-summary.txt" | paste -sd';' - || true) · the Asciidoctor Maven build step, asciidoctorj 3.0.0 and JRuby: not read (never \"clear\")"

# ---- docker, ports, the guard: the baselines ----------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that socket? (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run"
TC0=1
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
BAND="21000 21001 21002 21003 21004 21005 21006 21007 21008 21009"
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
[ -x "$CHROME" ] || die "no Chrome at $CHROME - this script uses no other browser"
VCH0=$(pgrep -x 'Google Chrome' 2> /dev/null | sort | paste -sd' ' - || true)
echo "  the browser: $("$CHROME" --version 2> /dev/null | head -1) · node $(node --version) · the Chrome processes already running (Vivek's own, never touched): $( [ -n "$VCH0" ] && echo "$(echo $VCH0 | wc -w | tr -d ' ') pids" || echo none)"
deadproxy() { [ "$(listeners 9)" = 0 ] || die "the seal's precondition: something listens on 127.0.0.1:9 - the dead proxy must refuse; the run stops before Chrome"
  local rc=0; $CURL -s -o /dev/null --max-time 3 http://127.0.0.1:9/ || rc=$?
  [ "$rc" = 7 ] || die "the seal's precondition: a connect to 127.0.0.1:9 did not fail with curl exit 7 (exit $rc)"
  echo "  the dead proxy: nothing listens on 127.0.0.1:9 · curl exit 7 (refused)"; }

# ---- the trees, copied and built offline: before (through the link), after/; the harness, compiled -----------------------------------
M2="$PWD/.m2-demo"
if [ ! -d "$M2" ]; then [ -d "$SEED" ] || die "the seed $SEED is missing (README.md, The repository)"; cp -cR "$SEED" "$M2" 2> /dev/null || cp -R "$SEED" "$M2" || die "the seed could not be copied"; fi
NF0=$(find "$M2" -type f | wc -l | tr -d ' '); NB0=$(find "$M2" -type f -print0 | xargs -0 stat -f %z | awk '{ s += $1 } END { printf "%d", s }')
CO=$(find "$M2" -name _remote.repositories -print0 | xargs -0 $G -l 'central-only' 2> /dev/null | wc -l | tr -d ' ')
[ "$CO" = 0 ] || die "S2.4: $CO _remote.repositories files in the seed copy still name central-only - the seed is not the rewritten one"
ART="org/springframework/boot/spring-boot-starter-parent/4.1.3 org/asciidoctor/asciidoctor-maven-plugin/3.2.0 org/asciidoctor/asciidoctorj/3.0.0 org/jruby/jruby/9.4.12.0 org/jruby/jruby-base/9.4.12.0 org/jruby/jruby-stdlib/9.4.12.0 org/springframework/restdocs/spring-restdocs-mockmvc/4.0.3 org/springframework/restdocs/spring-restdocs-core/4.0.3 org/springframework/restdocs/spring-restdocs-asciidoctor/4.0.3 org/springframework/boot/spring-boot-starter-restdocs/4.1.3 org/springframework/boot/spring-boot-restdocs/4.1.3 org/apache/maven/plugins/maven-dependency-plugin/3.11.0 org/apache/maven/plugins/maven-help-plugin/3.5.1"
for a in $ART; do [ -n "$(ls "$M2/$a" 2> /dev/null | $G -E '\.(jar|pom)$')" ] || die ".m2-demo holds no $a - it is not the Section 2 seed (no seed act here: report the coordinates)"; done
echo "  .m2-demo (a copy of the seed m2-seed-c9-s2): files $NF0 · bytes $NB0 · _remote.repositories naming central-only: $CO"
for a in $ART; do echo "  seed | $a | $(ls "$M2/$a" | $G -E '\.(jar|pom)$' | paste -sd' ' -)"; done
echo "  Asciidoctor + JRuby jars in the copy: $(for a in org/asciidoctor/asciidoctorj/3.0.0 org/jruby/jruby-base/9.4.12.0 org/jruby/jruby-stdlib/9.4.12.0; do stat -f %z "$M2/$a/"*.jar; done | awk '{ s += $1 } END { print s }') B (asciidoctorj 3.0.0, jruby-base, jruby-stdlib)"
mkdir -p .harness; rm -rf .harness/before .harness/after .harness/pkg .harness/twin .harness/tests .harness/webonly .harness/skip .harness/run .harness/work .harness/hc .harness/alone .harness/fail .harness/accept .harness/driven .harness/html .harness/dep .harness/exercise .harness/chrome-*
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
echo "  built before offline (mvn -o -DskipTests clean package -pl tiffinbox-web -am; the page step does not exist in this tree; exit 0, Downloading/Downloaded from: 0)"
guard "the build of after"
bg "cd .harness/after && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package" .harness/build-after.log
[ "$RE" = 0 ] || { tail -30 .harness/build-after.log | mask >&3; die ".harness/after did not build offline (exit $RE)"; }; offl .harness/build-after.log
echo "  built after/ offline WITH its tests (mvn -o clean package, the whole reactor: $($G -E '^\[INFO\] TiffinBox[A-Za-z ]* \.+ SUCCESS' .harness/build-after.log | sed -E 's/^\[INFO\] (TiffinBox[A-Za-z ]*) \.+ SUCCESS.*/\1/' | paste -sd, -); exit 0, Downloading/Downloaded from: 0) - the jars, the snippets and the page come from this build"
for t in before after; do
  bg "cd .harness/$t && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$t.log
  [ "$RE" = 0 ] || die ".harness/$t: the jar's extract failed"; done
CPA=".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*"
DSP="$M2/net/ttddyy/datasource-proxy/1.11.1/datasource-proxy-1.11.1.jar"
GR=.harness/after/tiffinbox-client/target/generated-sources/openapi
SNIP=.harness/after/tiffinbox-web/target/generated-snippets
PAGE=.harness/after/tiffinbox-web/target/generated-docs/index.html
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \"$CPA:$DSP\" harness/src/probe/*.java harness/src/probe/u11/U11Probe.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/'s jar: $(head -5 .harness/javac.log)"
echo "  the harness compiled against after/'s web jar ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes; datasource-proxy 1.11.1 on the harness's class path only) - never in the jar"
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
probe() { $CURL -s "$(B $P)/probe/u11/$1"; }
row() { echo "$(probe row/$1 | python3 -I -c 'import json,sys; r = [{k.lower(): v for k, v in x.items()} for x in json.load(sys.stdin)]; print(" ".join("%s %s %s %s v%s" % (x["name"], x["meals_per_day"], x["price_per_meal"], x["meal_type"], x["version"]) for x in r) or "no row")') (the harness's JdbcTemplate route /probe/u11/row/$1, the second client)"; }
count() { echo "$(probe count | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])') (the harness's JdbcTemplate route /probe/u11/count, the second client)"; }
keyrows() { echo "$(probe keys | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])') (the harness's JdbcTemplate route /probe/u11/keys, the second client)"; }
# tb LABEL PORT DB HCX [args]: TiffinBox (the extracted jar of TREE=after unless TREE is set), from its own run folder with a generated token
# (a config tree, 0600, never printed), Tomcat's access log on (unbuffered, no time field: %m %U%q %s %b, S9.27; ALP replaces the pattern
# for a JVM whose capture names the request headers it logs - the harness's pattern); waited for by its Started line
tb() { local label=$1 port=$2 db=$3 hcx=$4 t=${TREE:-after} run=.harness/run/$1 src="" i=0; shift 4
  guard "TiffinBox $label"
  for q in 21001 21002 21009; do [ "$(listeners $q)" = 0 ] && [ -z "$(lsof -nP -iUDP:$q 2> /dev/null)" ] || die "$q must stay free (TCP and UDP)"; done
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox" "$run/access"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  local x="$U/.harness/$t/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  if [ -n "$hcx" ]; then cp="$hcx:$cp:$U/.harness/hc:$DSP"; src="--spring.main.sources=${SRC:-probe.Witness,probe.Http,probe.Routes,probe.u11.U11Probe}"; fi
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
NCAPS=0; unpub=""; VALS=""
cap() { local nm=$1; shift
  if [ -n "${DEVCAPS:-}" ] && ! echo " $DEVCAPS " | $G -qF " $nm "; then return 0; fi   # development only: a run of record sets no DEVCAPS
  "$@" > .harness/cap-$nm.raw 2>&1 || true
  $G -q '^  \*\*\* ' .harness/cap-$nm.raw && { cat .harness/cap-$nm.raw >&3; die "$nm stopped (above)"; }
  mask < .harness/cap-$nm.raw > .r-$nm.new
  sed 's/^/  | /' .r-$nm.new | cut -c1-260
  local o e=0; o=$(python3 -I -B harness/chk11.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk11 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  $G -v '^ok \|^FAIL ' .harness/chk-$nm.out | sed 's/^/  chk11 /' || true
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; [ -n "${DEVCAPS:-}" ] && { echo "  (development: $nm's check failed, the run goes on)"; unpub="$unpub $nm"; } || die "$nm: its check failed (harness/chk11.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk11.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-11s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-11s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff its block in README.md against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }
alog() { cat ".harness/run/$1/access/access.log" 2> /dev/null || true; }
ck() { python3 -I -B harness/chk11.py "$@"; }
# a poll of 20400-21299 while a MockMvc run builds (a background loop of lsof counts, stopped by its pid)
pollband() { : > "$1"; ( while :; do band20400 >> "$1"; sleep 0.2; done ) & pollpid=$!; }
pollstop() { kill $pollpid 2> /dev/null; wait $pollpid 2> /dev/null; pollpid=""; }
# a scratch mirror: a fresh copy of after/ with ONE patch of harness/mirror applied (printed: the patch's md5 and the files it adds)
mirror() { local k=$1; rm -rf .harness/$k; copy after .harness/$k
  patch -s -p1 -d .harness/$k < harness/mirror/$k.diff || die "harness/mirror/$k.diff did not apply to a copy of after/"
  echo "  the $k mirror (.harness/$k, a copy of after/; the harness's, never TiffinBox's): harness/mirror/$k.diff md5 $(md5 -q harness/mirror/$k.diff) adds $($G -E '^\+\+\+ b/' harness/mirror/$k.diff | sed 's#^+++ b/##' | paste -sd' ' -)"; }
furi() { python3 -I -c 'import pathlib,sys; print(pathlib.Path(sys.argv[1]).resolve().as_uri())' "$1"; }

# ---- the captures --------------------------------------------------------------------------------------------------------------------
API=/api/v1/customers
JSON='Content-Type: application/json'; MPT='Content-Type: application/merge-patch+json'; JPT='Content-Type: application/json-patch+json'
KEYH='Idempotency-Key'          # the key header's name: sent only by specwire9.py's pause-key request
THREE="/v3/api-docs /v3/api-docs.yaml /v3/api-docs/swagger-config"
SPECF=after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json
TT=tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxRestDocsTest.java
DEF6="curl-request.adoc http-request.adoc http-response.adoc httpie-request.adoc request-body.adoc response-body.adoc"

surefire() { local f; for f in "$1"/TEST-*.xml; do ck surefire "$f"; done; }
reactor() { $G -E '^\[INFO\] (Reactor Summary|TiffinBox[A-Za-z ]* \.+ (SUCCESS|FAILURE|SKIPPED))' "$1" | sed -E 's/ \.+ / ... /; s/\[ *[0-9.:]+ (s|min)\]//; s/^\[INFO\] /  reactor: /; s/ *$//'; }
c_tests() { local p
  echo "== mvn -o clean package (tests on) on a copy of after/ (.harness/pkg): the whole reactor, three modules, Docker reachable"
  guard "mvn package"
  copy after .harness/pkg; copy after .harness/twin; copy after .harness/tests; copy after .harness/webonly; copy after .harness/skip
  bg "cd .harness/pkg && DOCKER_HOST=\"$DH\" $MV \"$AL\" clean package" .harness/pkg.log
  echo "  mvn package exit $RE · Downloading/Downloaded from: $($G -cE 'Download(ing|ed) from ' .harness/pkg.log || true)"; reactor .harness/pkg.log
  $G -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' .harness/pkg.log | sed -E 's/^\[[A-Z]+\] /  results: /'
  echo "  the build step's line (package): $($G -oE 'asciidoctor:[0-9.]+:process-asciidoc \([a-z]+\) @ [a-z-]+' .harness/pkg.log | head -1)"
  echo "  its phase (the web pom): $(python3 -I -c 'import re,sys; t = open(sys.argv[1]).read(); m = re.search(r"<id>docs</id>\s*<phase>([^<]+)</phase>", t); print(m.group(1) if m else "-")' after/tiffinbox-web/pom.xml)"
  echo "  package: target/generated-docs/index.html $( [ -f .harness/pkg/tiffinbox-web/target/generated-docs/index.html ] && echo present || echo absent) · target/generated-snippets/customer-read $(ls .harness/pkg/tiffinbox-web/target/generated-snippets/customer-read 2> /dev/null | wc -l | tr -d ' ') files"
  echo "== Surefire's XML, per module and class (package)"
  for p in tiffinbox-web tiffinbox-client; do surefire .harness/pkg/$p/target/surefire-reports | sed "s/^  /  $p | /"; done
  echo "== the Docker-free twin: the same, DOCKER_HOST=unix:///nonexistent/docker.sock (.harness/twin)"
  guard "the Docker-free twin"
  bg "cd .harness/twin && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package" .harness/twin.log
  echo "  mvn package (Docker-free) exit $RE · Downloading/Downloaded from: $($G -cE 'Download(ing|ed) from ' .harness/twin.log || true)"; reactor .harness/twin.log
  for p in tiffinbox-web tiffinbox-client; do surefire .harness/twin/$p/target/surefire-reports | sed "s/^  /  twin $p | /"; done
  echo "== the web module's tests before this change, and the @Test lines the change adds (after/ against before)"
  echo "  unit 10's values block: $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit10/README.md | $G -E '^tests: ' | $G -oE 'web_tests=[0-9]+')"
  echo "  new @Test | TiffinBoxRestDocsTest | $($G -cE '^ +@Test$' after/$TT) | $($G -A1 -E '^ +@Test$' after/$TT | $G -oE 'void [A-Za-z]+' | sed 's/^void //' | paste -sd, -) | before/$TT: $( [ -e before/$TT ] && echo present || echo absent)"
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
  echo "== Failsafe's XML, per class (the ITs)"; surefire .harness/tests/tiffinbox-web/target/surefire-reports-it
  $G -E '^IT BINDINGS ' .harness/verify.log | sort | sed 's/^/  /'
  echo "  Testcontainers' containers while verify ran (docker ps Ports, beside, never the witness): $(tr ', ' '\n\n' < .harness/tcps.txt | $G -oE '^[0-9.]+:[0-9]+' | sort -u | paste -sd' ' -)"
  echo "  Testcontainers containers after: $(dk ps -aq --filter label=org.testcontainers=true | wc -l | tr -d ' ') · listeners on 21280-21284 after: $(for p in 21280 21281 21282 21283 21284; do listeners $p; done | paste -sd+ - | bc)"
  echo "== the hand-built form U01-U10 run: mvn -o clean package -pl tiffinbox-web -am on a copy of after/ (.harness/webonly), Docker-free"
  guard "the web-only form"
  bg "cd .harness/webonly && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package -pl tiffinbox-web -am" .harness/webonly.log
  echo "  exit $RE · Downloading/Downloaded from: $($G -cE 'Download(ing|ed) from ' .harness/webonly.log || true)"; reactor .harness/webonly.log; offl .harness/webonly.log
  surefire .harness/webonly/tiffinbox-web/target/surefire-reports | sed "s/^  /  webonly tiffinbox-web | /"
  echo "== the -DskipTests form (flag 13) on a scratch copy (.harness/skip): mvn -o -DskipTests clean package -pl tiffinbox-web -am"
  guard "the -DskipTests form"
  bg "cd .harness/skip && $MV -DskipTests clean package -pl tiffinbox-web -am" .harness/skip.log; offl .harness/skip.log
  local sp=.harness/skip/tiffinbox-web/target/generated-docs/index.html
  echo "  -DskipTests on a scratch copy: exit $RE · include-not-found lines in the log $($G -c 'include file not found' .harness/skip.log || true) · target/generated-docs/index.html $( [ -f $sp ] && echo present || echo absent) · unresolved-include markers in it $( [ -f $sp ] && $G -c 'Unresolved directive' $sp || echo 0)"
  echo "  the build step's lines in that log (grep -c asciidoctor): $($G -c 'asciidoctor' .harness/skip.log || true) · the snippets folder: $( [ -d .harness/skip/tiffinbox-web/target/generated-snippets ] && echo present || echo absent) - the receipts' JVM builds keep their -DskipTests form; their jar is the same (moved's per-entry comparison)"
  echo "== BOOT-INF/lib before -> after"
  for t in before after; do echo "  $t: $(ls .harness/$t/$XD/lib | wc -l | tr -d ' ') jars · $(ls .harness/$t/$XD/lib | $G -E '^(spring-boot-[0-9]|spring-core-|tomcat-embed-core-|jackson-databind-|springdoc-openapi-starter-webmvc-ui-)' | sort | paste -sd' ' -)"; done
  echo "  the jars' names moved before -> after: $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c '^[<>]' || true)"; }

c_change() {
  ck modtable "$UP" after before
  echo "== the pom diffs (after/ against before)"
  echo "  the parent pom before -> after: $(diff before/pom.xml after/pom.xml | $G -c '^>' || true) lines added, $(diff before/pom.xml after/pom.xml | $G -c '^<' || true) removed"
  echo "  the web pom before -> after: $(diff before/tiffinbox-web/pom.xml after/tiffinbox-web/pom.xml | $G -c '^>' || true) lines added, $(diff before/tiffinbox-web/pom.xml after/tiffinbox-web/pom.xml | $G -c '^<' || true) removed"
  diff before/pom.xml after/pom.xml | $G '^>' | sed 's/^/  parent | /'
  echo "  the probe's draft (read, not applied): $PK/instruments/t11-pom.diff md5 $(md5 -q "$PK/instruments/t11-pom.diff") - its version inline (RED #19's defect); this tree's: the parent's property and the comments"
  echo "== the test scope the build resolved (mvn -o -DskipTests package dependency:list -DincludeScope=test -pl tiffinbox-web -am, on .harness/dep)"
  guard "the dependency list"
  copy after .harness/dep
  bg "cd .harness/dep && $MV -q -DskipTests package dependency:list -DincludeScope=test -DoutputFile=\"$U/.harness/deps.txt\" -pl tiffinbox-web -am" .harness/dep.log
  echo "  exit $RE"; offl .harness/dep.log
  $G -iE 'restdocs|asciidoctor|jruby' .harness/deps.txt | sed -E 's/^ +//; s/ -- .*//' | awk -F: '{ print "  resolved | " $1 ":" $2 " | " $4 ":" $5 }' | sort -u
  echo "== the build step's effective version (mvn -o help:effective-pom -pl tiffinbox-web -am)"
  bg "cd .harness/dep && $MV -q help:effective-pom -Doutput=\"$U/.harness/eff.xml\" -pl tiffinbox-web -am" .harness/eff.log
  echo "  the build step's effective version (help:effective-pom): $(python3 -I -c 'import re,sys; t = open(sys.argv[1]).read(); m = re.search(r"<artifactId>asciidoctor-maven-plugin</artifactId>\s*<version>([^<]+)</version>", t); print(m.group(1) if m else "-")' .harness/eff.xml)"
  echo "  the committed file: md5 $(md5 -q $SPECF) · $(cmp -s before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json $SPECF && echo byte-identical || echo DIFFERENT) to before's"
  echo "  the image (Dockerfile) copies: $($G -E '^COPY ' after/Dockerfile | paste -sd';' -) - target/generated-docs is never copied"; }

c_pass() { local f
  echo "== the shipped test ALONE on a copy of after/ (.harness/alone): mvn -o clean test -pl tiffinbox-web -am -Dtest=TiffinBoxRestDocsTest, Docker-free; MockMvc: no socket, no HTTP client"
  guard "the shipped test alone"
  copy after .harness/alone
  pollband .harness/poll-alone.txt
  bg "cd .harness/alone && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean test -pl tiffinbox-web -am -Dtest=TiffinBoxRestDocsTest -Dsurefire.failIfNoSpecifiedTests=false" .harness/alone.log
  pollstop; offl .harness/alone.log
  echo "  exit $RE"; ck junit .harness/alone/tiffinbox-web/target/surefire-reports TiffinBoxRestDocsTest
  echo "  listeners 20400-21299 during the MockMvc run: $(sort -n .harness/poll-alone.txt | tail -1) · after: $(band20400)"
  ck listing .harness/alone/tiffinbox-web/target/generated-snippets customer-read
  echo "  the same eight in the reactor's build of after/ (.harness/after): $(for f in $(ls $SNIP/customer-read); do cmp -s $SNIP/customer-read/$f .harness/alone/tiffinbox-web/target/generated-snippets/customer-read/$f && echo y || echo n; done | sort | uniq -c | awk '{ printf "%s %s ", $2, $1 }')(y = byte-equal)"
  echo "== BLUE's filed run (expectation lines: $BK/captures/rd/snippets-run1.txt, md5 $(md5 -q "$BK/captures/rd/snippets-run1.txt"))"
  awk '/^customer-read: /{ w = 1; next } w && /^  [a-z-]+\.adoc [0-9a-f]{32}$/ { print "  BLUE | " $1 " | " $2; next } w { exit }' "$BK/captures/rd/snippets-run1.txt"
  echo "== http-response.adoc, whole (the shipped test's)"
  sed 's/^/  | /' .harness/alone/tiffinbox-web/target/generated-snippets/customer-read/http-response.adoc; echo
  ck resp .harness/alone/tiffinbox-web/target/generated-snippets/customer-read/http-response.adoc
  echo "== the socket twin: after/ on 21000 (H2, no harness) - the same request, curl -D, Tomcat answering"
  P=21000; L=PASS; DB=h2; tb PASS 21000 h2 ""
  health
  for a in none json; do local mk a0 w; a0=$(acount PASS)
    if [ $a = none ]; then w=$($CURL --http1.1 -sS -D $J/pass-$a.h -o $J/pass-$a.b -w '%{http_code} %{content_type} %{size_download}' "$(B 21000)$API/Ravi"); echo "-- socket | GET $API/Ravi (no Accept) -> $w"
    else w=$($CURL --http1.1 -sS -D $J/pass-$a.h -o $J/pass-$a.b -w '%{http_code} %{content_type} %{size_download}' -H 'Accept: application/json' "$(B 21000)$API/Ravi"); echo "-- socket | GET $API/Ravi (Accept: application/json) -> $w"; fi
    maskh $J/pass-$a.h | $G -iE '^(Content-Type|Content-Length):' | sed 's/^/     header: /'
    srv PASS x $a0
    echo "  the snippet's body against the socket's ($( [ $a = none ] && echo 'no Accept' || echo 'Accept: application/json')): $(ck eqbody .harness/alone/tiffinbox-web/target/generated-snippets/customer-read/http-response.adoc $J/pass-$a.b | sed 's/^ *//')"; done
  tbstop PASS 21000
  echo "  the snippet is what MockMvc's DispatcherServlet answered; the socket is what Tomcat answered - the documentation is a second witness beside the wire"; }

c_status() {
  echo "== the fail mirror's run (once per run of record): mvn -o clean test -pl tiffinbox-web -am -Dtest=FailureKindsProbeTest,TiffinBoxRestDocsTest, Docker-free"
  mirror fail
  guard "the fail mirror"
  pollband .harness/poll-fail.txt
  bg "cd .harness/fail && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean test -pl tiffinbox-web -am -Dtest=FailureKindsProbeTest,TiffinBoxRestDocsTest -Dsurefire.failIfNoSpecifiedTests=false" .harness/fail.log
  pollstop; offl .harness/fail.log
  echo "  the failing run: exit $RE · $($G -E '^\[(ERROR|INFO|WARNING)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' .harness/fail.log | tail -1 | sed -E 's/^\[[A-Z]+\] //')"
  echo "  listeners 20400-21299 during the MockMvc run: $(sort -n .harness/poll-fail.txt | tail -1) · after: $(band20400)"
  echo "== the listing, filed in this shell before any later build in that folder (R.506)"
  ck listing .harness/fail/tiffinbox-web/target/generated-snippets status-a status-b never-sent-a never-sent-b undocumented-a undocumented-b customer-read > $J/fail-listing.txt
  ck junit .harness/fail/tiffinbox-web/target/surefire-reports FailureKindsProbeTest > $J/fail-junit.txt
  ck junit .harness/fail/tiffinbox-web/target/surefire-reports TiffinBoxRestDocsTest >> $J/fail-junit.txt
  $G -E '^  (listing|snip (status-a|status-b|customer-read))' $J/fail-listing.txt
  $G -E '^  (junit|case FailureKindsProbeTest\.status|case TiffinBoxRestDocsTest)' $J/fail-junit.txt
  echo "  the passing test's http-response.adoc md5 $(md5 -q .harness/fail/tiffinbox-web/target/generated-snippets/customer-read/http-response.adoc)"
  echo "  BLUE's status B http-response.adoc (an expectation line): $(awk '/^customer-read-wrong-status-b: /{ w = 1; next } w && /http-response/ { print $2; exit }' "$BK/captures/rd/snippets-run1.txt")"
  echo "== the package build on the SAME mirror (the failing tests stop the build at test)"
  guard "the fail mirror's package"
  bg "cd .harness/fail && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package -pl tiffinbox-web -am -Dtest=FailureKindsProbeTest,TiffinBoxRestDocsTest -Dsurefire.failIfNoSpecifiedTests=false" .harness/fail-pkg.log
  offl .harness/fail-pkg.log
  echo "  package on the failing mirror: exit $RE · target/generated-docs $( [ -e .harness/fail/tiffinbox-web/target/generated-docs ] && echo present || echo ABSENT) · the last phase line: $($G -oE '^\[INFO\] --- [a-z:.0-9-]+ \([a-z-]+\) @ tiffinbox-web ---' .harness/fail-pkg.log | tail -1 | sed 's/^\[INFO\] //')"; }
c_field() {
  echo "== the fail mirror's four field tests (the same run as status's; its listing filed before the package build)"
  $G -E '^  snip (never-sent|undocumented)' $J/fail-listing.txt
  $G -E '^  case FailureKindsProbeTest\.(neverSent|undocumented)' $J/fail-junit.txt
  echo "== the passing test's six defaults, beside (the same run)"
  for f in $DEF6; do echo "  passing | $f | $(md5 -q .harness/alone/tiffinbox-web/target/generated-snippets/customer-read/$f)"; done; }

c_accept() { local a k f
  echo "== the generated client's Accept for the public read, read off its generated source (never typed)"
  f=$GR/src/main/java/com/tiffinbox/client/api/ApiApi.java
  local ln; ln=$(awk '/value = ApiApi\.PATH_ONE,/{ getline; if ($0 ~ /accept = /) { print NR; exit } }' $f)
  local acc; acc=$(sed -n "${ln}p" $f | sed -E 's/.*accept = \{ (.*) \}.*/\1/; s/"//g')
  echo "  the generated client's Accept (read off ${f#.harness/after/}:$ln): $acc"
  mirror accept
  mkdir -p .harness/accept/tiffinbox-web/src/test/resources; printf '%s\n' "$acc" > .harness/accept/tiffinbox-web/src/test/resources/u11-accept.txt
  echo "  the harness's file u11-accept.txt (the mirror's test resources): $(cat .harness/accept/tiffinbox-web/src/test/resources/u11-accept.txt)"
  guard "the accept mirror"
  pollband .harness/poll-accept.txt
  bg "cd .harness/accept && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean test -pl tiffinbox-web -am -Dtest=AcceptProbeTest -Dsurefire.failIfNoSpecifiedTests=false" .harness/accept.log
  pollstop; offl .harness/accept.log
  echo "  exit $RE"; ck junit .harness/accept/tiffinbox-web/target/surefire-reports AcceptProbeTest
  echo "  listeners 20400-21299 during the MockMvc run: $(sort -n .harness/poll-accept.txt | tail -1) · after: $(band20400)"
  for k in none generated json; do $G -E '^Accept: ' .harness/accept/tiffinbox-web/target/generated-snippets/accept-$k/http-request.adoc | sed "s/^/  request accept-$k | /" || echo "  request accept-$k | no Accept line (MockMvc's default)"; ck resp .harness/accept/tiffinbox-web/target/generated-snippets/accept-$k/http-response.adoc; done
  echo "== the socket's twin per Accept: after/ on 21000 (H2, no harness)"
  P=21000; L=ACC; DB=h2; tb ACC 21000 h2 ""
  for k in none generated json; do local w ms mc
    case $k in none) w=$($CURL --http1.1 -sS -o /dev/null -w '%{http_code} %{content_type}' "$(B 21000)$API/Ravi") ;; generated) w=$($CURL --http1.1 -sS -o /dev/null -w '%{http_code} %{content_type}' -H "Accept: $acc" "$(B 21000)$API/Ravi") ;; json) w=$($CURL --http1.1 -sS -o /dev/null -w '%{http_code} %{content_type}' -H 'Accept: application/json' "$(B 21000)$API/Ravi") ;; esac
    ms=$(sed -n 's/^HTTP\/1\.1 \([0-9]*\) .*/\1/p' .harness/accept/tiffinbox-web/target/generated-snippets/accept-$k/http-response.adoc); mc=$(sed -n 's/^Content-Type: //p' .harness/accept/tiffinbox-web/target/generated-snippets/accept-$k/http-response.adoc)
    echo "  accept | $k | MockMvc: $ms $mc | socket: $w"; done
  echo "  the access log (no time field): $(alog ACC | paste -sd'|' -)"
  tbstop ACC 21000
  echo "  no HTTP client runs on the MockMvc side (S9.19: none - MockMvc); curl on the socket side"; }

c_driven() { local f
  echo "== the wire's Nobody 404 first: after/ on 21005 (H2, no harness - a harness copy's JVM on the mirrors' port)"
  P=21005; L=DRV; DB=h2; tb DRV 21005 h2 ""
  echo "-- GET $API/Nobody -> $($CURL --http1.1 -sS -o $J/nobody.b -w '%{http_code} %{content_type}' "$(B 21005)$API/Nobody")"
  echo "  members the wire carries: $(python3 -I -c 'import json,sys; print(",".join(json.load(open(sys.argv[1]))))' $J/nobody.b)"
  tbstop DRV 21005
  ck example $SPECF $J/nobody.b
  mirror driven
  guard "the driven mirror"
  bg "cd .harness/driven && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean test -pl tiffinbox-web -am -Dtest=DrivenErrorProbeTest -Dsurefire.failIfNoSpecifiedTests=false" .harness/driven.log
  offl .harness/driven.log
  echo "  exit $RE (one test fails on purpose: name left out)"; ck junit .harness/driven/tiffinbox-web/target/surefire-reports DrivenErrorProbeTest
  ck listing .harness/driven/tiffinbox-web/target/generated-snippets nobody-with-name nobody-without-name
  ck resp .harness/driven/tiffinbox-web/target/generated-snippets/nobody-with-name/http-response.adoc
  echo "  the snippet's body against the wire's: $(ck eqbody .harness/driven/tiffinbox-web/target/generated-snippets/nobody-with-name/http-response.adoc $J/nobody.b | sed 's/^ *//')"
  echo "  FILED as a candidate for the scripts stage: measured on a scratch mirror, not in TiffinBox (the anchor ships one test)"; }

c_html() { local f
  echo "== the html mirror: after/ with two more pages beside index.adoc (the probe's index.adoc as index-default.adoc, its index-nofonts.adoc), mvn -o clean package -pl tiffinbox-web -am -Dtest=TiffinBoxRestDocsTest"
  mirror html
  guard "the html mirror"
  bg "cd .harness/html && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package -pl tiffinbox-web -am -Dtest=TiffinBoxRestDocsTest -Dsurefire.failIfNoSpecifiedTests=false" .harness/html.log
  offl .harness/html.log; echo "  exit $RE · pages: $(ls .harness/html/tiffinbox-web/target/generated-docs | paste -sd' ' -)"
  mkdir -p $J/pages; cp $PAGE $J/pages/shipped.html; cp .harness/html/tiffinbox-web/target/generated-docs/index-nofonts.html $J/pages/nofonts.html; cp .harness/html/tiffinbox-web/target/generated-docs/index-default.html $J/pages/default.html
  echo "  the shipped page = the reactor's build of after/ ($PAGE); the html mirror's own index.html is the same page: $(ck maskhtml $PAGE | md5 -q) / $(ck maskhtml .harness/html/tiffinbox-web/target/generated-docs/index.html | md5 -q) (masked md5s)"
  echo "== the byte census per page: grep -oE 'https?://[A-Za-z0-9.-]+' FILE | sort | uniq -c (python, the same pattern)"
  for f in shipped nofonts default; do ck hosts $J/pages/$f.html; echo "  $f.html masked md5 $(ck maskhtml $J/pages/$f.html | md5 -q)"; done
  echo "== the probe's three filed pages (read, not produced here; a probe number, 1 run)"
  for f in index index-nofonts index-local; do echo "  probe $f.html: $(wc -c < "$PK/captures/generated-docs/$f.html" | tr -d ' ') B · md5 $(md5 -q "$PK/captures/generated-docs/$f.html") · host references $(/usr/bin/grep -oE 'https?://[A-Za-z0-9.-]+' "$PK/captures/generated-docs/$f.html" | wc -l | tr -d ' ')"; done
  echo "  generator: $($G -oE '<meta name="generator" content="[^"]+">' $PAGE)"
  echo "  footer (masked): $(ck maskhtml $PAGE | $G -oE 'Last updated .*' | head -1)"
  echo "  the mask's self-test: $( [ "$(printf 'Last updated 2026-11-25 06:58:03 +0100\n' > $J/mt.html; ck maskhtml $J/mt.html)" = 'Last updated <masked>' ] && echo ok || echo FAILED)"
  echo "  the page's stylesheet: inline (Asciidoctor embeds it - linkcss is not set): $($G -c '<link rel="stylesheet"' $PAGE || true) link elements · @import lines $($G -c '@import' $PAGE || true)"
  echo "  the -DskipTests page (tests's scratch copy): unresolved-include markers $($G -c 'Unresolved directive' .harness/skip/tiffinbox-web/target/generated-docs/index.html 2> /dev/null || echo 0)"
  echo "  the jar's entries named generated-docs or index.html: $(unzip -l .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | $G -cE 'generated-docs|index\.html' || true)"
  echo "  git check-ignore: $(git -C "$UP" check-ignore -v c9-tiffinbox/tiffinbox-web/target/generated-docs/index.html)"
  echo "  git check-ignore (the snippets): $(git -C "$UP" check-ignore -v c9-tiffinbox/tiffinbox-web/target/generated-snippets/)"; }

# chromeup LABEL: one headless Chrome, sealed with Course 6 U23's flags (c6-unit23/receipts.sh), its own profile, DevTools on 21007
chromeup() { local lab=$1 i=0; guard "Chrome $lab"; deadproxy
  [ "$(listeners 21007)" = 0 ] && [ -z "$(lsof -nP -iUDP:21007 2> /dev/null)" ] || die "21007 is bound before Chrome $lab"
  rm -rf ".harness/chrome-$lab" ".harness/netlog-$lab.json"
  CHF=(--headless=new "--user-data-dir=$U/.harness/chrome-$lab" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 "--host-resolver-rules=MAP * ~NOTFOUND, EXCLUDE 127.0.0.1" --remote-debugging-address=127.0.0.1 --remote-debugging-port=21007 "--log-net-log=$U/.harness/netlog-$lab.json" about:blank)
  "$CHROME" "${CHF[@]}" > ".harness/chrome-$lab.log" 2>&1 < /dev/null & CPID=$!
  echo "  Chrome $lab: headless, the flags: $(printf '%s ' "${CHF[@]}" | sed "s#$U#…#g")"
  while ! $CURL -s -o /dev/null --max-time 1 http://127.0.0.1:21007/json/version; do kill -0 $CPID 2> /dev/null || die "Chrome $lab exited before its DevTools answered"; i=$((i + 1)); [ $i -lt 300 ] || die "Chrome $lab: no DevTools"; sleep 0.1; done
  MINE="${MINE:-} 21007"; echo "  Chrome $lab up: its DevTools answered on 127.0.0.1:21007 (pid recorded at launch)"; }
chromedown() { local lab=$1 i=0
  node harness/cdp.mjs 21007 close > /dev/null 2>&1 || true
  while kill -0 $CPID 2> /dev/null; do i=$((i + 1)); [ $i -lt 100 ] || { killtree $CPID; echo "  Chrome $lab: still there after Browser.close - stopped by its recorded pid tree"; break; }; sleep 0.1; done
  wait $CPID 2> /dev/null || true; kill -0 $CPID 2> /dev/null && die "Chrome $lab: its pid is still alive"
  CPID=""; MINE=$(echo " ${MINE:-} " | sed "s/ 21007 / /g"); rm -rf ".harness/chrome-$lab"
  local j=0; while [ "$(listeners 21007)" != 0 ]; do j=$((j + 1)); [ $j -lt 100 ] || die "21007 still bound after Chrome $lab"; sleep 0.1; done
  echo "  Chrome $lab stopped by Browser.close (cdp.mjs close): its pid gone, its profile folder removed, 21007 free"; }
c_sealed() { local f
  for f in shipped default nofonts; do
    echo "== the $f page in sealed headless Chrome, read as file:// (DevTools 21007)"
    chromeup $f
    [ $f = shipped ] && echo "  Chrome version: $(node harness/cdp9.mjs 21007 version)"
    node harness/cdp.mjs 21007 open "$(furi $J/pages/$f.html)" $J/ev-$f.json | sed -E 's#its address: [^ ]+#its address: <the page>#; s/^/  /'
    if [ $f = shipped ]; then local rc=0; node harness/cdp9.mjs 21007 rendered 1000 > $J/rendered.txt 2>&1 || rc=$?; echo "  cdp9.mjs rendered on a file:// page: exit $rc ($(head -1 $J/rendered.txt))"; fi
    python3 -I harness/seal9.py cdp $J/ev-$f.json | sed "s/^ */  $f: /"; echo "  seal9.py cdp ($f) exit ${PIPESTATUS[0]}"
    chromedown $f
    python3 -I harness/seal9.py netlog .harness/netlog-$f.json | sed "s/^ */  netlog $f: /"; echo "  seal9.py netlog ($f) exit ${PIPESTATUS[0]}"; done
  echo "== the judge's other answers (BLUE's seal9.py, read beside)"
  local pe; pe=$(awk '$2 ~ /captures\/rdchrome\/index-events\.json$/ { print $1 }' "$PK/MD5SUMS"); cp "$PK/captures/rdchrome/index-events.json" $J/ev-probe.json
  echo "  the probe's filed events ($PK/captures/rdchrome/index-events.json): md5 $(md5 -q $J/ev-probe.json) = its MD5SUMS line: $( [ "$(md5 -q $J/ev-probe.json)" = "$pe" ] && echo yes || echo NO)"
  python3 -I harness/seal9.py cdp $J/ev-probe.json > /dev/null 2>&1; echo "  seal9.py cdp (probe) exit $?"
  echo "[]" > $J/ev-empty.json; python3 -I harness/seal9.py cdp $J/ev-empty.json > /dev/null 2>&1; echo "  seal9.py cdp (empty) exit $?"
  python3 -I harness/seal9.py cdp $J/ev-shipped.json 21000 > /dev/null 2>&1; echo "  a port named that the page never asked: exit $?"
  python3 -I - .harness/netlog-shipped.json $J/netlog-plant.json <<'PY'
import json, sys
d = json.load(open(sys.argv[1])); t = {v: k for k, v in d["constants"]["logEventTypes"].items()}
e = next((x for x in d["events"] if t.get(x.get("type")) in ("TCP_CONNECT_ATTEMPT", "TCP_CONNECT") and "params" in x and "address" in x["params"]), None)
if e: c = json.loads(json.dumps(e)); c["params"]["address"] = "8.8.8.8:443"; d["events"].append(c)
json.dump(d, open(sys.argv[2], "w"))
PY
  echo "  a non-loopback TCP connect planted in a NetLog copy: $(python3 -I harness/seal9.py netlog $J/netlog-plant.json 2>&1 | $G -E 'verdict' | sed 's/^ *//')"
  echo "  netlog.py (Course 6) on the default page's NetLog: exit $(python3 -I "$C6U/netlog.py" .harness/netlog-default.json > $J/c6.txt 2>&1; echo $?) (md5 $(md5 -q "$C6U/netlog.py"), read in place; it reads TCP only, so it cannot fail here: shown once)"
  echo "  Chrome profiles left: $(ls -d .harness/chrome-* 2> /dev/null | $G -vc '\.log$' || true)"; }

c_compare() { local d n
  echo "== REST Docs: what the real build (.harness/after) wrote"
  echo "  REST Docs: identifier directories under target/generated-snippets: $(find $SNIP -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ') ($(ls $SNIP | paste -sd, -))"
  echo "  REST Docs: snippets in them: $(find $SNIP -type f -name '*.adoc' | wc -l | tr -d ' ')"
  ck resp $SNIP/customer-read/http-response.adoc
  echo "== spring doc: /v3/api-docs on 21000 (H2, no harness), read by python"
  P=21000; L=CMP; DB=h2; tb CMP 21000 h2 ""
  $CURL -s "$(B 21000)/v3/api-docs" > $J/spec-cmp.json; tbstop CMP 21000
  ck springdoc $J/spec-cmp.json
  echo "== specwire9 (BLUE's) on its own harness-joined JVM (21003, a fresh database): send, then diff (a) and (b)"
  P=21003; L=SW; DB=h2; tb SW 21003 h2 "$U/.harness/hc"
  health
  echo "  key table | diff-before | $(probe keys | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])')"
  rm -rf $J/wire; mkdir -p $J/wire
  (cd $J && BLUE_RUN=$RUNNO python3 -I "$U/harness/specwire9.py" send 21003 wire) 2>&1 | sed 's/^/  sent: /'
  echo "  key table | diff-after | $(probe keys | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])')"
  tbstop SW 21003
  python3 -I harness/specwire9.py diff $SPECF $J/wire 2>&1 | sed 's/^/  (a) /'; echo "  (a) exit ${PIPESTATUS[0]}"
  python3 -I harness/specwire9.py diff $SPECF $J/wire "$GR" 2>&1 | sed 's/^/  (b) /'; echo "  (b) exit ${PIPESTATUS[0]}"
  echo "  unit 10's values block (before's rows): $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit10/README.md | $G -E '^diff: ' | $G -oE 'kinds_a=[0-9]+ rows_a=[0-9]+ kinds_b=[0-9]+ rows_b=[0-9]+')"
  echo "== the two socket tests and the MockMvc tests, by grep"
  (cd after && $G -rn 'WebEnvironment.RANDOM_PORT' tiffinbox-web/src/test/java) | sed -E 's#^tiffinbox-web/src/test/java/com/tiffinbox/web/#  RANDOM_PORT | #'
  for f in OpenApiSpecTest TiffinBoxRestDocsTest; do echo "  MockMvc | $f.java:$($G -n 'webAppContextSetup' after/tiffinbox-web/src/test/java/com/tiffinbox/web/$f.java | cut -d: -f1): $($G -c 'MockMvc' after/tiffinbox-web/src/test/java/com/tiffinbox/web/$f.java) lines name MockMvc · RANDOM_PORT $($G -c 'RANDOM_PORT' after/tiffinbox-web/src/test/java/com/tiffinbox/web/$f.java || true)"; done
  echo "  the hand-off (S1B Q-d) names two socket tests, CustomerPatchesTest and CustomerReadsTest; the grep finds $( (cd after && $G -rl 'WebEnvironment.RANDOM_PORT' tiffinbox-web/src/test/java) | wc -l | tr -d ' ') test classes on a real socket in all"
  echo "  the sentence the two prints give: the tests that send over a real socket stay tests of their own; a MockMvc test, REST Docs' included, runs the DispatcherServlet with no socket"; }

c_committed() {
  echo "== (i) the committed file: $SPECF"
  echo "  bytes $(wc -c < $SPECF | tr -d ' ') (wc -c) · md5 $(md5 -q $SPECF) · before's (U10's) md5 $(md5 -q before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json) · $(cmp -s before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json $SPECF && echo byte-identical || echo DIFFERENT) · servers member: $(python3 -I -c 'import json,sys; print("present" if "servers" in json.load(open(sys.argv[1])) else "absent")' $SPECF) · git diff 221465c on it: $(git -C "$UP" diff 221465c -- c9-tiffinbox/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | wc -l | tr -d ' ') lines"
  echo "== (ii) the file against the served document on after/ (21000, H2, no harness), servers removed"
  P=21000; L=CM; DB=h2; tb CM 21000 h2 ""
  health
  $CURL -s "$(B 21000)/v3/api-docs" > $J/spec-h2.raw
  python3 -I -c 'import io,json,sys; d = json.load(open(sys.argv[1], encoding="utf-8")); d.pop("servers", None); b = io.StringIO(); json.dump(d, b, indent=2, ensure_ascii=False); b.write("\n"); open(sys.argv[2], "w", encoding="utf-8").write(b.getvalue())' $J/spec-h2.raw $J/spec-h2.json
  tbstop CM 21000
  echo "  the served document, servers removed (the fixed rule): md5 $(md5 -q $J/spec-h2.json) · = the committed file: $(cmp -s $J/spec-h2.json $SPECF && echo byte-identical || echo DIFFERENT)"
  echo "== (iii) OpenApiSpecTest in the tests capture's package and its Docker-free twin (Surefire's XML); the new test writes none of the file"
  ck surefire .harness/pkg/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.OpenApiSpecTest.xml | sed 's/^/  package:/'
  ck surefire .harness/twin/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.OpenApiSpecTest.xml | sed 's/^/  twin:/'; }
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
c_moved() { echo "== U10's nineteen requests (its c_moved list, copied) on before (21006) and after/ (21000), H2, each its own JVM, no harness; bodies hashed (and sized) with Boot's /error timestamp and any port masked"
  movedside before 21006; movedside after 21000
  echo "== the build-level witnesses: the web jar before and after, per entry (unzip -lv: every entry's name and CRC, python over both lists)"
  echo "  web jar md5: before $(md5 -q .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar) · after $(md5 -q .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar)"
  for t in before after; do unzip -lv .harness/$t/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | awk 'NF >= 8 && $1 ~ /^[0-9]+$/ { print $7, $8 }' | sort -k2 > $J/jar-$t.txt; done
  python3 -I - $J/jar-before.txt $J/jar-after.txt <<'PY'
import sys
a = dict(l.split(" ", 1)[::-1] for l in open(sys.argv[1]).read().splitlines()); b = dict(l.split(" ", 1)[::-1] for l in open(sys.argv[2]).read().splitlines())
print("  entries before %d · after %d · BOOT-INF/lib names before %d · after %d" % (len(a), len(b), sum(1 for k in a if k.startswith("BOOT-INF/lib/")), sum(1 for k in b if k.startswith("BOOT-INF/lib/"))))
print("  entry names before -> after: %s" % ("equal" if set(a) == set(b) else "DIFFERENT (%s)" % ",".join(sorted(set(a) ^ set(b)))))
for k in sorted(set(a) & set(b)):
    if a[k] != b[k]: print("  entry CRC moved: %s" % k)
PY
  echo "  entries named restdocs, asciidoctor, jruby or generated-docs: before $($G -ciE 'restdocs|asciidoctor|jruby|generated-docs' $J/jar-before.txt || true) · after $($G -ciE 'restdocs|asciidoctor|jruby|generated-docs' $J/jar-after.txt || true)"; }
c_seven() { local side tree port i
  echo "== the seven (c5-unit11/curlset.sh, no key header), each tree its own JVM, H2, no harness: the expected $S466"
  for side in before after; do [ $side = before ] && port=21006 || port=21000
    P=$port; L=seven-$side; DB=h2; TREE=$side tb seven-$side $port h2 ""
    sh $CURLSET $port .harness/run/seven-$side/secrets/tiffinbox/shutdown-token > $J/seven-$side.txt 2>&1
    i=0; while kill -0 "$(cat .harness/run/seven-$side/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 400 ] || die "seven-$side: the seven's POST /shutdown did not stop it"; sleep 0.05; done
    echo "  $side: the seven's requests (the access log, a harness-free start): $(alog seven-$side | awk '{ print $1, $2, $3 }' | paste -sd'|' -)"
    tbstop seven-$side $port
    echo "  $side: the seven $(md5 -q $J/seven-$side.txt) ($(wc -l < $J/seven-$side.txt | tr -d ' ') lines)"; done
  echo "  before -> after/: $(cmp -s $J/seven-before.txt $J/seven-after.txt && echo equal || echo DIFFER) · not a witness for the test scope - a witness only for \"adding REST Docs moved no answer of TiffinBox\""; }
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
  echo "== the old surface by count (U10's reader, copied), each tree its own JVM, H2, no harness: the expected $U4SURF"
  for side in before after; do [ $side = before ] && port=21006 || port=21000
    P=$port; L=surface-$side; DB=h2; TREE=$side tb surface-$side $port h2 ""
    oldsurface2 $port $J/surface-$side.txt
    tbstop surface-$side $port
    echo "  $side: the old surface $(md5 -q $J/surface-$side.txt) ($($G -c '^== ' $J/surface-$side.txt) requests, $(wc -l < $J/surface-$side.txt | tr -d ' ') lines)"; done
  echo "  before -> after/: $(cmp -s $J/surface-before.txt $J/surface-after.txt && echo equal || echo DIFFER)"
  diff $J/surface-before.txt $J/surface-after.txt | sed 's/^/    moved: /'
  echo "== the self-test (S9.14, the harness's plant - LABELLED, not a finding about TiffinBox): a ShallowEtagHeaderFilter on /* (probe.Etag, U10's copy), after/, on 21004"
  P=21004; L=seven-etag; SRC=probe.Etag tb seven-etag 21004 h2 "$U/.harness/hc"
  sh $CURLSET 21004 .harness/run/seven-etag/secrets/tiffinbox/shutdown-token > $J/seven-etag.txt 2>&1
  i=0; while kill -0 "$(cat .harness/run/seven-etag/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 400 ] || die "seven-etag did not stop"; sleep 0.05; done; tbstop seven-etag 21004
  P=21004; L=surface-etag; SRC=probe.Etag tb surface-etag 21004 h2 "$U/.harness/hc"; oldsurface2 21004 $J/surface-etag.txt; tbstop surface-etag 21004
  echo "  planted: the seven $(md5 -q $J/seven-etag.txt) (unchanged: $(cmp -s $J/seven-etag.txt $J/seven-after.txt && echo yes || echo NO)) · the old surface $(md5 -q $J/surface-etag.txt) (moved: $(cmp -s $J/surface-etag.txt $J/surface-after.txt && echo NO || echo yes)) · the feed's line: $($G '^== GET /customers/feed' $J/surface-etag.txt | sed -E 's/^== //')"; }


c_inert() { local f
  echo "== every curl request block of this run that says whether it sent the key header, by capture"
  for f in .r-pass.new .r-accept.new .r-driven.new .r-compare.new .r-moved.new; do [ -f $f ] || continue; echo "  $f: sent the key: $($G -ciF "$KEYH:" $f || true) · did not: $($G -cE '^(-- socket|  accept \||  (before|after) \|)' $f || true)"; done
  f=$J/wire; echo "  wire: $(python3 -I -c 'import json,os,sys; d = sys.argv[1]; r = [json.load(open(os.path.join(d, x))) for x in sorted(os.listdir(d))]; print("requests %d · with the key: %s" % (len(r), ",".join(x["name"] for x in r if any(k.lower() == sys.argv[2].lower() for k in x["request"]["headers"])) or "none"))' $f "$KEYH")"
  echo "== the key table, read by the second client on every harness-joined JVM of the run"
  $G -hE '^  key table \| ' .r-compare.new | sed 's/^/ /' | sed 's/^ //'
  echo "  MockMvc runs: key header sent 0 · key table read 0 (no POST is driven by REST Docs here)"
  echo "  the harness-free JVMs (pass, accept, driven, compare's document, committed, moved, seven, surface, the exercise) are not read after the fact: H2 in memory ends with its JVM; their witness is the access log"; }

# the exercise: break.sh then check.sh on a copy of after/ (.harness/exercise/tree), TiffinBox's jar alone on 21008, from the exercise's
# folder, env -i, under bash then zsh -f; the solution = apply.sh on the broken copy, then check.sh; the refused "solutions" each their own copy
exrun() { local v=$1 sh=$2 o cmd
  guard "the exercise, $v, $sh"
  rm -rf .harness/exercise/tree; copy after .harness/exercise/tree
  case $v in broken) cmd='sh break.sh "$0" && sh check.sh "$0"' ;; solved) cmd='sh break.sh "$0" > /dev/null && sh apply.sh "$0" > /dev/null && sh check.sh "$0"' ;; none) cmd='sh break.sh "$0" > /dev/null && sh check.sh "$0"' ;; *) cmd="sh break.sh \"\$0\" > /dev/null && HOW=$v sh apply.sh \"\$0\" > /dev/null && sh check.sh \"\$0\"" ;; esac
  echo "== the exercise, h2, $v, $sh (env -i, from the exercise's folder; the tree a fresh copy of after/; built offline from the receipt's seed copy, its jar alone on 21008):"
  if [ $sh = bash ]; then o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21008 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock bash -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1)
  else o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21008 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock /bin/zsh -f -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1); fi
  printf '%s\n' "$o" | sed -E 's/127\.0\.0\.1:21008/127.0.0.1:<port>/g; s/^/  /'
  offl exercise/check.build.log
  if [ $v = solved ] && [ $sh = bash ]; then echo "  the solved test against ../after's: $(cmp -s .harness/exercise/tree/$TT after/$TT && echo equal || echo differ) (md5 $(md5 -q .harness/exercise/tree/$TT) / $(md5 -q after/$TT))"; fi
  [ "$(listeners 21008)" = 0 ] || die "the exercise left something listening on 21008"; }
c_exercise() { local v sh
  rm -rf .harness/exercise; mkdir -p .harness/exercise
  for v in broken solved; do for sh in bash zsh; do exrun $v $sh; done; done
  for v in none delall optional disabled handsnippet; do exrun $v bash; done
  rm -rf exercise/check.run; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.body.json
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures${DEVCAPS:+ (DEVELOPMENT: only $DEVCAPS - not a run of record)}"
cap tests c_tests
cap change c_change
cap pass c_pass
cap status c_status
cap field c_field
cap accept c_accept
cap driven c_driven
cap html c_html
cap sealed c_sealed
cap compare c_compare
cap committed c_committed
cap moved c_moved
cap seven c_seven
cap surface c_surface
cap inert c_inert
cap exercise c_exercise

# ---- the end: the sweep, the values, the published hashes -------------------------------------------------------------------------------
[ -z "$(echo $PIDS)" ] || die "a JVM of this run is still running: $PIDS"
[ -z "$CPID" ] || die "a Chrome of this run is still running: $CPID"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
[ -z "$(dk ps -aq --filter label=org.testcontainers=true)" ] || die "a container of this run is left"
NI1=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI1" = "$NI0" ] && [ "$VOL1" = "$VOL0" ] || die "R.322: images $NI0 -> $NI1, volumes $VOL0 -> $VOL1"
AD1=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true); [ "$AD1" = "$AD" ] || die "the anchor moved during the run"
pin before-tree before; pin after-tree after
MDB=$(find . ../c9-tiffinbox ../c9-unit10 -name '*.mv.db' -not -path './.harness/*' -not -path '../c9-unit10/.harness/*' 2> /dev/null | wc -l | tr -d ' ')
[ "$MDB" = 0 ] || die "an H2 file outside .harness/"
[ -z "$(ls exercise | $G -v -xE 'README.md|SOLUTION.md|apply.sh|break.sh|check.sh')" ] || die "the exercise left a file in exercise/"
[ -z "$(ls -d .harness/chrome-* 2> /dev/null | $G -v '\.log$')" ] || die "a Chrome profile folder is left"
VALS="$VALS
static: $STV
gloss: $GLV
spoken: $SPV
build: seed_files=$NF0 seed_bytes=$NB0 central_only=$CO"
[ -n "${DEVCAPS:-}" ] && { printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'; echo "c9-unit11: DEVELOPMENT run ($DEVCAPS) - nothing published"; exit 2; }
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
VO=$(ck values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; die "README.md's values block is not this run's (harness/chk11.py values)"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM or Chrome of this run, ports free, no container left, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1 · the anchor against after/ as at the start · the tree pins · *.mv.db outside .harness 0 · no Chrome profile · the values block = this run's"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit11: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit11: every capture = published ($NCAPS) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"
