#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 12 "Versioning Strategies" - this unit's receipts. Course 9's NINTH anchor change, Section 2's sixth and last, the
# anchor's first change to tiffinbox-web/src/main since unit 09 and its first change to how a request is routed: before is a link to
# ../c9-unit11/after (U11's after); after/ is a frozen copy of ../c9-tiffinbox after this unit's change - one WebMvcConfigurer,
# TiffinBoxApiVersioning (usePathSegment(1) under /api/ only, setVersionRequired(false), addSupportedVersions("1.0")), one test class,
# ApiVersionTest (two methods), the README's card. The five literal /api/v1/ mappings are not touched.
# The harness (never in the jar or the module): the statement and request witnesses, Routes, the ShallowEtag plant - copied from U11's
# harness; U10's runner probe.u10.Caller (byte-equal); probe.u12.U12Probe (U11Probe, renamed; the second client); probe.u12.Versioning12
# (the S2 probe's Versioning2 with a named diff: the carrier mirror's one configurer per JVM); probe.u12.U12Routes (the harness's route
# pair /api/{v}/u12/handler, 1.0 and 2.0); four mirror patches (harness/mirror: nover, required, deprecate, retire), each applied to a
# scratch copy of after/ only. Every line they print is "the harness's". No Chrome, no NetLog. No PostgreSQL capture (callpg dropped:
# H2 only).
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5):
#   choose    D2 on /api/ first: fourteen requests on before (21016) and after/ (21010), the seven in each JVM, then the same on the
#             planted required mirror (21014) - every old route 400, the seven moved - and ApiVersionTest red on it
#   tests     the whole reactor at package, its Docker-free twin, verify (the ITs), the web-only form; 50 + the new ones
#   change    the parent's <modules>, the module table, the new class whole, the changed list, spring-webmvc in the jar
#   four      the carrier mirror (nover: the shipped class deleted, the harness's Versioning12 joined): H, Q, M, P on 21013, one at a time
#   required  H's lines and the shipped-class twin (choose's planted mirror), side by side
#   default   HD: trap 4 (a media-type client asking for two answered by version one), both ways
#   newest    HN: no version, no default
#   deprecate the deprecate mirror: which answers carry Deprecation, Sunset and Link; the Sunset day's digits; the harness's pair
#   retire    the retire mirror (the PATH carrier, 2.0 only) and HR (the HEADER carrier) once; the retired handler still mapped
#   type      the Nobody 404 under /api/v1/ on before and after/, and on the retired mirror
#   client    U10's generated client (probe.u10.Caller) against after/ and the retired mirror
#   restdocs  U11's TiffinBoxRestDocsTest alone on after/ and before: the eight snippets compared
#   replay    the key's replay under /api/v1/ and under the other spelling /api/1.0/ (harness-joined, 21015)
#   committed the committed file, the served document, info.version beside the path keys, the versioned harness route's document
#   moved     U11's nineteen requests on before and after/; the web jar per entry
#   seven     the seven's md5s as choose's JVMs printed them, the expected beside
#   surface   the old surface by count on before and after/
#   inert     the key header and the key table across every capture of the run
#   exercise  break.sh, check.sh on the retired copy, the solution (apply.sh) and the refused answers, bash and zsh -f, H2
# Ports (U12's band, 21010-21019): 21010 after/ on H2, no harness · 21013 every mirror JVM, one at a time · 21014 the planted required
# mirror · 21015 the harness-joined starts · 21016 before · 21018 the exercise · 21011, 21012 (callpg dropped), 21017 (no Chrome), 21019
# never bound. During mvn verify only: 21280-21284, one per IT. Every store on 127.0.0.1; every curl --noproxy '*'. The key header is
# sent only by replay's named requests (KEYH).
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
RUNNO=${RUNNO:-0}                                     # the run of record's number (1, 2, 3); 0 = development
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
PIDS=""; TC0=""; INTR=""; mpid=""; pollpid=""
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "curlset.sh") || index($0, "check.sh") || index($0, "apply.sh") || index($0, "probe.u10.Caller") || $3 ~ /(^|\/)javac$/) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
tcrm() { local c n=0 i=0; [ -n "$TC0" ] || return 0
  while [ $i -lt 10 ]; do
    for c in $(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null); do dk rm -fv "$c" > /dev/null 2>&1 && n=$((n + 1)); done
    [ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] && break; sleep 0.5; i=$((i + 1)); done
  [ "$n" = 0 ] || echo "  the trap: $n Testcontainers container(s) removed with their volumes (rm -fv)" >&3; }
trap 'trap "" INT TERM; for p in $pollpid $mpid $PIDS; do [ -z "$p" ] || killtree "$p"; done; for p in $pollpid $mpid $PIDS; do if kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; tcrm; rm -rf exercise/check.run; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.body.json exercise/check.h; [ -z "$INTR" ] || rm -f .r-*.new; rmdir .r-lock 2> /dev/null || rm -rf .r-lock; true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git unzip patch /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|SPRINGDOC_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT|BLUE_RUN)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit12 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }') · run $RUNNO"

# ---- gates before anything is built: the folder, the link, the pins, the anchor, the static check, the prose, the exercise ----------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk12.py dur9.py mirror s912.py specwire9.py src tree12.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
[ "$(ls harness/mirror | paste -sd' ' -)" = 'deprecate.diff nover.diff required.diff retire.diff' ] || die "harness/mirror holds another file, or misses one"
HSRC='probe/Etag.java probe/Http.java probe/Routes.java probe/Witness.java probe/u10/Caller.java probe/u12/U12Probe.java probe/u12/U12Routes.java probe/u12/Versioning12.java'
[ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$HSRC" ] || die "harness/src holds another file, or misses one"
for f in loc9.py seal9.py cdp.mjs cdp9.mjs mirror/default.diff mirror/hc5.diff mirror/fail.diff mirror/accept.diff mirror/driven.diff mirror/html.diff; do [ ! -e harness/$f ] || die "harness/$f: an earlier unit's instrument this unit does not carry"; done
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md apply.sh break.sh check.sh' ] || die "exercise/ holds another file, or misses one"
[ -L before ] && [ "$(readlink before)" = ../c9-unit11/after ] || die "before must be a link whose text is exactly ../c9-unit11/after (found: $( [ -L before ] && readlink before || echo 'not a link'))"
[ -d after ] && [ ! -L after ] || die "after/ is this unit's own frozen tree, a directory, not a link"
for t in before after; do [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-client/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/ - never built in place"; true; done
echo "  before -> $(readlink before) (a link, the text exact) · after/ a directory (the frozen copy) · no secrets/, target/ or .m2-demo/ in either"
$G -v '^ *#' harness/src/probe/*.java harness/src/probe/u1*/*.java | $G -q 'Thread\.sleep' && die "R.412: a Thread.sleep in the harness"
for f in Witness Http Etag Routes; do w=$(awk -v n="harness/src/probe/$f.java" '$1 == "file" && $2 == n { print $3 }' ../c9-unit11/receipts.md5)
  [ -n "$w" ] && [ "$(md5 -q harness/src/probe/$f.java)" = "$w" ] || die "harness/src/probe/$f.java is not U11's published file (../c9-unit11/receipts.md5)"; done
CW=$(awk '$1 == "file" && $2 == "harness/src/probe/u10/Caller.java" { print $3 }' ../c9-unit10/receipts.md5)
[ -n "$CW" ] && [ "$(md5 -q harness/src/probe/u10/Caller.java)" = "$CW" ] || die "harness/src/probe/u10/Caller.java is not U10's published file (../c9-unit10/receipts.md5)"
echo "  harness/src/probe: Witness, Http, Etag, Routes = ../c9-unit11/receipts.md5's file lines · u10/Caller.java = ../c9-unit10/receipts.md5's ($CW) · u12/U12Probe (U11Probe, renamed), u12/Versioning12 (the probe's Versioning2, a named diff), u12/U12Routes = this unit's"
V2="$PK/instruments/src/probe/Versioning2.java"
VD=$(diff "$V2" harness/src/probe/u12/Versioning12.java | md5 -q)
echo "  Versioning12.java against the probe's Versioning2.java (md5 $(md5 -q "$V2")): the named diff md5 $VD, $(diff "$V2" harness/src/probe/u12/Versioning12.java | $G -c '^[<>]') lines"
diff "$V2" harness/src/probe/u12/Versioning12.java | $G '^[<>]' | cut -c1-170 | sed 's/^/  Versioning12 diff | /'
UPD=$(diff ../c9-unit11/harness/src/probe/u11/U11Probe.java harness/src/probe/u12/U12Probe.java | $G -c '^[<>]')
echo "  U12Probe.java against U11Probe.java: $UPD lines differ (the package, the class, the route prefix, the docstring)"
SW9=$(awk '$2 ~ /instruments\/specwire9\.py$/ { print $1 }' "$BK/MD5SUMS")
[ -n "$SW9" ] && [ "$(md5 -q harness/specwire9.py)" = "$SW9" ] || die "harness/specwire9.py is not BLUE's instrument (its MD5SUMS line: ${SW9:-none})"
[ "$(sed -n '5,$p' harness/tree12.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit11/harness/tree11.py | md5 -q)" ] || die "harness/tree12.py's code is not tree11.py's"
for u in 01 02 03 04 05 06 07 08 09 10 11; do [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit$u/harness/dur9.py)" ] || die "harness/dur9.py is not ../c9-unit$u's copy (dur9 as shipped)"; done
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"
  [ ! -f "$C9R/_builders/dur9.py" ] || [ "$(md5 -q "$C9R/_builders/dur9.py")" = "$D9" ] || die "harness/dur9.py is not C9/_builders/dur9.py"
else D9N="(the registry is not on this machine: U01-U11's copies are the pin)"; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit01-11's copies $D9N · harness/specwire9.py = BLUE's ($SW9; copied, not run by a capture of this unit) · tree12.py's code = tree11.py's"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit11/receipts.md5)
[ -n "$UA" ] || die "../c9-unit11/receipts.md5 has no after-tree line"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree12.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$nm" = after-tree ] || [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit11/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree12.py $dir/ -> $got = receipts.md5's $nm line$( [ "$nm" = before-tree ] && echo " = ../c9-unit11/receipts.md5's after-tree line")"; }
pin before-tree before; pin after-tree after
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true)
echo "  after/ against ../c9-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures its own frozen after/' )"
HF="harness/chk12.py harness/s912.py harness/tree12.py harness/dur9.py harness/specwire9.py harness/mirror/nover.diff harness/mirror/required.diff harness/mirror/deprecate.diff harness/mirror/retire.diff $(for f in $HSRC; do printf 'harness/src/%s ' $f; done)exercise/check.sh exercise/apply.sh exercise/break.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's scripts: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
for f in nover required deprecate retire; do echo "  harness/mirror/$f.diff: md5 $(md5 -q harness/mirror/$f.diff) · $($G -cE '^[-+][^-+]' harness/mirror/$f.diff) changed lines"; done
ST=$(python3 -I -B harness/chk12.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
STV=$(printf '%s\n' "$ST" | sed -n 's/^VALUES //p')
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s912.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U12 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s912, per sentence): /'
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b|<measure>' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
GL=$(python3 -I -B harness/chk12.py gloss README.md) || die "the gloss: $(printf '%s\n' "$GL" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$GL" | $G -v '^VALUES ' | sed 's/^/  /'
GLV=$(printf '%s\n' "$GL" | sed -n 's/^VALUES //p')
HOOK=$(python3 -I -B harness/chk12.py hook); EXQ=$(python3 -I -B harness/chk12.py exq); GLS=$(python3 -I -B harness/chk12.py gloss-line)
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S2B's Unit 12 Hook line), byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SP=$(python3 -I -B harness/chk12.py spoken "$HOOK" "$EXQ") || die "the spoken lines: $(printf '%s\n' "$SP" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$SP" | $G -v '^VALUES ' | sed 's/^/  /'
SPV=$(printf '%s\n' "$SP" | sed -n 's/^VALUES //p')
printf '%s\n\n%s\n\n%s\n' "$HOOK" "$EXQ" "$GLS" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s912.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
printf '%s\n' "$SW" | tail -1 | $G -qE ' refused: 0$' || die "a refused reading in a spoken line: $(printf '%s\n' "$SW" | $G ' line ' | head -3 | paste -sd';' -)"
echo "  the hook, the exercise's line and the gloss through s912.py (every family, the carried base and dur9 inside it): refused 0"; rm -f .r-lock/spoken.md
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
MVL=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -F '$MV ')
MVA=$(printf '%s\n' "$MVL" | $G -vF -- '-pl tiffinbox-web -am' | $G -vF -- '-pl tiffinbox-client -am' | $G -cF -- '-pl ' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh with a -pl form other than '-pl tiffinbox-web -am' or '-pl tiffinbox-client -am'"
MVB=$(printf '%s\n' "$MVL" | $G -F '.harness/before' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVB" = 0 ] || die "R.391: before is built only with -pl tiffinbox-web -am"
echo "  R.391 (flag 23's forms): Maven builds -pl tiffinbox-web -am $(printf '%s\n' "$MVL" | $G -cF -- '-pl tiffinbox-web -am') · -pl tiffinbox-client -am $(printf '%s\n' "$MVL" | $G -cF -- '-pl tiffinbox-client -am' || true) · the whole reactor (no -pl) $(printf '%s\n' "$MVL" | $G -vcF -- '-pl ' || true) · another form 0 · before only with -pl tiffinbox-web -am"
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
    gsub(/Deprecation: @[0-9]+/, "Deprecation: @<masked>")
    gsub(/Sunset: [A-Z][a-z][a-z], [0-9]+ [A-Z][a-z][a-z] [0-9]+ [0-9:]+ GMT/, "Sunset: <masked>")
    gsub(/[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?( ?[A-Z]{3,4}|Z|[+-][0-9:]+)?(\[[A-Za-z_\/]+\])?/, "<time>")
    gsub(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/, "<uuid>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'took 812 ms' '"timestamp":"2026-11-24T07:12:01.123+01:00"' "$U/x $HOME/y" 'Deprecation: @1790812800' 'Sunset: Thu, 01 Apr 2027 00:00:00 GMT' '[INFO] TiffinBox Web ...... SUCCESS [ 11.955 s]' | mask)
[ "$(printf '%s\n' "$MP" | paste -sd'|' -)" = 'Started TiffinBoxServer in <t> (process running for <t>)|took <t>|"timestamp":"<time>"|…/x ~/y|Deprecation: @<masked>|Sunset: <masked>|[INFO] TiffinBox Web ...... SUCCESS [<t>]' ] || die "the mask's self-test: $(printf '%s\n' "$MP" | paste -sd'|' -)"
maskh() { tr -d '\r' < "$1" | sed -E 's/^(Date|date): .*/\1: <masked>/; s/(JSESSIONID=)[^;]*/\1<masked>/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/^(Expires): .*/\1: <masked>/; s/^(Keep-Alive): .*/\1: <masked>/; s/^(Deprecation): @[0-9]+/\1: @<masked>/; s/^(Sunset): .*/\1: <masked>/'; }
MH=$(printf 'Date: Tue, 24 Nov 2026 08:00:00 GMT\r\nSet-Cookie: JSESSIONID=ABC123; Path=/; HttpOnly\r\nLocation: http://127.0.0.1:21010/dashboard\r\nExpires: Tue, 24 Nov 2027 08:00:00 GMT\r\nKeep-Alive: timeout=60\r\nDeprecation: @1790812800\r\nSunset: Thu, 01 Apr 2027 00:00:00 GMT\r\n' > .r-lock/mh; maskh .r-lock/mh | paste -sd'|' -; rm -f .r-lock/mh)
[ "$MH" = 'Date: <masked>|Set-Cookie: JSESSIONID=<masked>; Path=/; HttpOnly|Location: http://127.0.0.1:<port>/dashboard|Expires: <masked>|Keep-Alive: <masked>|Deprecation: @<masked>|Sunset: <masked>' ] || die "the header mask's self-test: $MH"
echo "  masks: the log mask masked a Started line's times, a millisecond count, Boot's /error timestamp, the folders, the home, a Deprecation and a Sunset value and a reactor line's time; the header mask a planted Date, session cookie, port, Expires, Keep-Alive, Deprecation and Sunset"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
$G -qF 'S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)' ../c9-unit11/receipts.sh || die "../c9-unit11/receipts.sh no longer reads the seven's md5 off ../c7-unit31/receipts.sh"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SURF=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh)
[ ${#U4SURF} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh (SURF=)"
U11V=$(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit11/README.md | $G -oE '(^| )(seven|surface)=[0-9a-f]{8}( |$)' | sed 's/^ *//; s/ *$//' | paste -sd' ' -)
[ "$U11V" = "seven=$(echo $S466 | cut -c1-8) surface=$(echo $U4SURF | cut -c1-8)" ] || die "U11's README values block ($U11V) is not the seven and the surface read off the receipts"
S7D=$(md5 -q "$PK/captures/ver/H.seven")
echo "  the seven: expected $S466 (../c7-unit31/receipts.sh's S466= line) · the old surface: expected $U4SURF (../c9-unit04/receipts.sh's SURF= line) · both = U11's README values block ($U11V) · the probe's required-variant seven (read, not produced here): $S7D ($PK/captures/ver/H.seven)"
for v in H HD HN HR M P Q; do echo "  probe | ver/$v.seven | $(md5 -q "$PK/captures/ver/$v.seven") (its md5 - an expectation, 1 run)"; done
echo "  probe | ver.log md5 $(md5 -q "$PK/captures/ver.log") · ver.sh $(md5 -q "$PK/instruments/ver.sh") · Versioning2.java $(md5 -q "$V2") (read, not copied)"
FA=$(cat "$ADV/fetched-at.txt" 2> /dev/null | head -1); [ -n "$FA" ] || die "the advisories' fetched-at line is missing ($ADV)"
FAE=$(python3 -I -c 'import datetime,sys; t = datetime.datetime.strptime(sys.argv[1], "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=datetime.timezone.utc); print(int((datetime.datetime.now(datetime.timezone.utc) - t).total_seconds() // 3600))' "$FA")
[ "$FAE" -lt 24 ] || die "S9.36 (flag 22): the filed advisory read is $FAE hours old - more than a day; a re-read is the orchestrator's act"
echo "  S9.36: today's filed read ($ADV), fetched at $FA ($FAE h before this run; not re-read: no network) · Spring's index rows $(wc -l < "$ADV/spring-index-rows.txt" | tr -d ' '), naming Spring Framework $($G -c 'Spring Framework' "$ADV/spring-index-rows.txt" || true) · $(head -1 "$ADV/tomcat-11.0.30-section.txt")"

# ---- docker, ports, the guard: the baselines ----------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that socket? (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run"
TC0=1
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
BAND="21010 21011 21012 21013 21014 21015 21016 21017 21018 21019"
PORTS="18425 18881 18882 18883 18884 20578 20615 $BAND 21280 21281 21282 21283 21284"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
for p in $BAND 21280 21281 21282 21283 21284; do [ -z "$(lsof -nP -iUDP:$p 2> /dev/null)" ] || die "UDP $p is bound"; done
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
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · nothing pulled, ever (no image is run by this script; the ITs' containers are Testcontainers', from images present) · no Testcontainers container · ports $PORTS free (TCP; the band and 21280-21284 UDP too)"

# ---- the trees, copied and built offline: before (through the link), after/; the mirrors; the harness, compiled -----------------------
M2="$PWD/.m2-demo"
if [ ! -d "$M2" ]; then [ -d "$SEED" ] || die "the seed $SEED is missing (README.md, The repository)"; cp -cR "$SEED" "$M2" 2> /dev/null || cp -R "$SEED" "$M2" || die "the seed could not be copied"; fi
NF0=$(find "$M2" -type f | wc -l | tr -d ' '); NB0=$(find "$M2" -type f -print0 | xargs -0 stat -f %z | awk '{ s += $1 } END { printf "%d", s }')
CO=$(find "$M2" -name _remote.repositories -print0 | xargs -0 $G -l 'central-only' 2> /dev/null | wc -l | tr -d ' ')
[ "$CO" = 0 ] || die "S2.4: $CO _remote.repositories files in the seed copy still name central-only - the seed is not the rewritten one"
ART="org/springframework/boot/spring-boot-starter-parent/4.1.3 org/springframework/spring-webmvc/7.0.11 org/springframework/spring-web/7.0.11"
for a in $ART; do [ -n "$(ls "$M2/$a" 2> /dev/null | $G -E '\.(jar|pom)$')" ] || die ".m2-demo holds no $a - it is not the Section 2 seed (no seed act here: report the coordinates)"; done
echo "  .m2-demo (a copy of the seed m2-seed-c9-s2): files $NF0 · bytes $NB0 · _remote.repositories naming central-only: $CO · no artifact this unit adds (Framework's versioning is spring-webmvc's)"
for a in $ART; do echo "  seed | $a | $(ls "$M2/$a" | $G -E '\.(jar|pom)$' | paste -sd' ' -)"; done
mkdir -p .harness; rm -rf .harness/before .harness/after .harness/pkg .harness/twin .harness/tests .harness/webonly .harness/run .harness/work .harness/hc .harness/hcc .harness/nover .harness/required .harness/deprecate .harness/retire .harness/rd-after .harness/rd-before .harness/exercise
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
extract() { bg "cd .harness/$1 && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$1.log
  [ "$RE" = 0 ] || die ".harness/$1: the jar's extract failed"; }
guard "the build of before"
bg "cd .harness/before && $MV -DskipTests clean package -pl tiffinbox-web -am" .harness/build-before.log
[ "$RE" = 0 ] || { tail -30 .harness/build-before.log | mask >&3; die ".harness/before did not build offline (exit $RE)"; }; offl .harness/build-before.log
echo "  built before offline (mvn -o -DskipTests clean package -pl tiffinbox-web -am; exit 0, Downloading/Downloaded from: 0)"
guard "the build of after"
bg "cd .harness/after && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package" .harness/build-after.log
[ "$RE" = 0 ] || { tail -30 .harness/build-after.log | mask >&3; die ".harness/after did not build offline (exit $RE)"; }; offl .harness/build-after.log
echo "  built after/ offline WITH its tests (mvn -o clean package, the whole reactor: $($G -E '^\[INFO\] TiffinBox[A-Za-z ]* \.+ SUCCESS' .harness/build-after.log | sed -E 's/^\[INFO\] (TiffinBox[A-Za-z ]*) \.+ SUCCESS.*/\1/' | paste -sd, -); exit 0, Downloading/Downloaded from: 0) - the jars come from this build"
extract before; extract after
# a scratch mirror: a fresh copy of after/ with ONE patch of harness/mirror applied, built -DskipTests -pl tiffinbox-web -am, its jar extracted
mirror() { local k=$1; rm -rf .harness/$k; copy after .harness/$k
  patch -s -E -p1 -d .harness/$k < harness/mirror/$k.diff || die "harness/mirror/$k.diff did not apply to a copy of after/"
  guard "the $k mirror's build"
  bg "cd .harness/$k && $MV -DskipTests clean package -pl tiffinbox-web -am" .harness/build-$k.log
  [ "$RE" = 0 ] || { tail -20 .harness/build-$k.log | mask >&3; die "the $k mirror did not build"; }; offl .harness/build-$k.log
  extract $k
  echo "  the $k mirror (.harness/$k, a copy of after/; the harness's, never TiffinBox's): harness/mirror/$k.diff md5 $(md5 -q harness/mirror/$k.diff) · built offline (mvn -o -DskipTests clean package -pl tiffinbox-web -am, exit 0) · TiffinBoxApiVersioning.java $( [ -f .harness/$k/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApiVersioning.java ] && echo "md5 $(md5 -q .harness/$k/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApiVersioning.java)" || echo ABSENT)"; }
for k in nover required deprecate retire; do mirror $k; done
CPA=".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*"
DSP="$M2/net/ttddyy/datasource-proxy/1.11.1/datasource-proxy-1.11.1.jar"
CJ="$U/.harness/after/tiffinbox-client/target/tiffinbox-client-1.0.0.jar"
GR=.harness/after/tiffinbox-client/target/generated-sources/openapi
bg "cd .harness/after && $MV -q dependency:build-classpath -DincludeScope=runtime -Dmdep.outputFile=\"$U/.harness/client-cp.txt\" -pl tiffinbox-client -am" .harness/client-cp.log
[ "$RE" = 0 ] && [ -s .harness/client-cp.txt ] || die "the client's run-time class path could not be read offline (exit $RE)"
CCP="$CJ:$(cat .harness/client-cp.txt)"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \"$CPA:$DSP\" harness/src/probe/*.java harness/src/probe/u12/*.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/'s jar: $(head -5 .harness/javac.log)"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hcc -cp \"$CCP\" harness/src/probe/u10/Caller.java" .harness/javac-caller.log
[ "$RE" = 0 ] || die "the runner did not compile against the client's jar: $(head -5 .harness/javac-caller.log)"
echo "  the harness compiled against after/'s web jar ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes, -parameters; datasource-proxy 1.11.1 on the harness's class path only) · the runner probe.u10.Caller against the client's jar and its run-time class path ($(tr ':' '\n' < .harness/client-cp.txt | wc -l | tr -d ' ') jars, mvn -o dependency:build-classpath -DincludeScope=runtime, U10's form) - never in either jar"
B() { echo "http://127.0.0.1:$1"; }
J=.harness/work
acount() { wc -l < ".harness/run/$1/access/access.log" 2> /dev/null | tr -d ' '; }
# tb LABEL PORT DB HCX [args]: TiffinBox (the extracted jar of TREE=after unless TREE is set), from its own run folder with a generated token
# (a config tree, 0600, never printed), Tomcat's access log on (unbuffered, no time field: %m %U%q %s %b, S9.27); waited for by its Started line
tb() { local label=$1 port=$2 db=$3 hcx=$4 t=${TREE:-after} run=.harness/run/$1 src="" i=0; shift 4
  guard "TiffinBox $label"
  for q in 21011 21012 21017 21019; do [ "$(listeners $q)" = 0 ] && [ -z "$(lsof -nP -iUDP:$q 2> /dev/null)" ] || die "$q must stay free (TCP and UDP)"; done
  [ "$(listeners $port)" = 0 ] && [ -z "$(lsof -nP -iUDP:$port 2> /dev/null)" ] || die "$port is bound before $label"
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox" "$run/access"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  local x="$U/.harness/$t/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  if [ -n "$hcx" ]; then cp="$hcx:$cp:$U/.harness/hc:$DSP"; src="--spring.main.sources=${SRC:-probe.Witness,probe.Http,probe.Routes,probe.u12.U12Probe}"; fi
  (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -cp "$cp" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port="$port" $src \
     --server.tomcat.accesslog.enabled=true --server.tomcat.accesslog.directory="$U/$run/access" --server.tomcat.accesslog.prefix=access --server.tomcat.accesslog.suffix=.log \
     --server.tomcat.accesslog.file-date-format= --server.tomcat.accesslog.rotate=false "--server.tomcat.accesslog.pattern=%m %U%q %s %b" --server.tomcat.accesslog.buffered=false "$@" > jvm.log 2>&1) &
  local p=$!; echo $p > "$run/pid"; PIDS="$PIDS $p"; MINE="${MINE:-} $port"
  while ! $G -q -E 'Started TiffinBox(App|Server) in' "$run/jvm.log" 2> /dev/null; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before its Started line"; }; i=$((i + 1)); [ $i -lt 900 ] || die "$label: no Started line"; sleep 0.1; done
  echo "  $label up on $port ($db, tree $t$( [ -n "$hcx" ] && echo ", the harness joined: ${SRC:-probe.Witness,probe.Http,probe.Routes,probe.u12.U12Probe}" || echo ", no harness")) · waited for its Started line · $($G -o -E 'Successfully applied [0-9]+ migrations[^(]*' "$run/jvm.log" | head -1 | sed 's/ *$//')$($G -o 'VER12 variant [A-Z]*' "$run/jvm.log" | head -1 | sed 's/^/ · /')"; }
tbstop() { local label=$1 port=$2 run=.harness/run/$1 p i=0 how="POST /shutdown"; p=$(cat "$run/pid")
  if kill -0 "$p" 2> /dev/null; then printf 'X-Shutdown-Token: %s\n' "$(head -1 "$run/secrets/tiffinbox/shutdown-token")" | $CURL -s -o /dev/null --max-time 5 -H @- -X POST "$(B $port)/shutdown" || true; fi
  while kill -0 "$p" 2> /dev/null; do i=$((i + 1)); [ $i = 80 ] && { kill "$p" 2> /dev/null; how="its recorded pid (SIGTERM): POST /shutdown did not stop it"; }; [ $i -lt 400 ] || { kill -9 "$p" 2> /dev/null; break; }; sleep 0.05; done
  wait "$p" 2> /dev/null || true; PIDS=$(echo " $PIDS " | sed "s/ $p / /g"); MINE=$(echo " ${MINE:-} " | sed "s/ $port / /g")
  [ "$(listeners $port)" = 0 ] || die "$label: something still listens on $port"
  [ -z "${QUIET:-}" ] && echo "  $label stopped by $how"; true; }
health() { echo "  one GET /actuator/health (a counted step of its own): $($CURL -s -o /dev/null -w '%{http_code}' "$(B $1)/actuator/health")"; }
NCAPS=0; unpub=""; VALS=""
cap() { local nm=$1; shift
  if [ -n "${DEVCAPS:-}" ] && ! echo " $DEVCAPS " | $G -qF " $nm "; then return 0; fi   # development only: a run of record sets no DEVCAPS
  "$@" > .harness/cap-$nm.raw 2>&1 || true
  $G -q '^  \*\*\* ' .harness/cap-$nm.raw && { cat .harness/cap-$nm.raw >&3; die "$nm stopped (above)"; }
  mask < .harness/cap-$nm.raw > .r-$nm.new
  sed 's/^/  | /' .r-$nm.new | cut -c1-260
  local o e=0; o=$(python3 -I -B harness/chk12.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk12 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  $G -v '^ok \|^FAIL ' .harness/chk-$nm.out | sed 's/^/  chk12 /' || true
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; [ -n "${DEVCAPS:-}" ] && { echo "  (development: $nm's check failed, the run goes on)"; unpub="$unpub $nm"; } || die "$nm: its check failed (harness/chk12.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk12.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-11s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-11s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff its block in README.md against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }
alog() { cat ".harness/run/$1/access/access.log" 2> /dev/null || true; }
ck() { python3 -I -B harness/chk12.py "$@"; }
pollband() { : > "$1"; ( while :; do band20400 >> "$1"; sleep 0.2; done ) & pollpid=$!; }
pollstop() { kill $pollpid 2> /dev/null; wait $pollpid 2> /dev/null; pollpid=""; }

# ---- the captures --------------------------------------------------------------------------------------------------------------------
API=/api/v1/customers
JSON='Content-Type: application/json'; MPT='Content-Type: application/merge-patch+json'; JPT='Content-Type: application/json-patch+json'
KEYH='Idempotency-Key'          # the key header's name: sent only by replay's two named requests
THREE="/v3/api-docs /v3/api-docs.yaml /v3/api-docs/swagger-config"
SPECF=after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json
VT=tiffinbox-web/src/test/java/com/tiffinbox/web/ApiVersionTest.java
VC=tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApiVersioning.java
# rq SIDE PORT METHOD PATH [curl args]: one request; its status, Content-Type, size, the three deprecation headers as found (values
# masked by the capture's mask), and the body (Boot's timestamp and any port masked) - printed whole up to 330 bytes, else its md5
rq() { local side=$1 port=$2 m=$3 p=$4 w o=$J/rq; shift 4; : > $o.h; : > $o.b
  if [ "$m" = HEAD ]; then w=$($CURL --http1.1 -sS -I -D $o.h -o /dev/null -w '%{http_code} %{content_type} %{size_download}' --max-time 10 "$@" "$(B $port)$p" 2> /dev/null)
  else w=$($CURL --http1.1 -sS -D $o.h -o $o.b -w '%{http_code} %{content_type} %{size_download}' --max-time 10 -X "$m" "$@" "$(B $port)$p" 2> /dev/null); fi
  local ex=""; for a in "$@"; do case "$a" in -H) ;; *) ex="$ex [$a]" ;; esac; done
  local dh; dh=$(tr -d '\r' < $o.h | $G -iE '^(Deprecation|Sunset|Link|Allow):' | sed -E 's/^Deprecation: @[0-9]+/Deprecation: @<epoch>/' | awk -F': ' '$1 == "Allow" { n = split($2, a, ","); for (i = 1; i <= n; i++) for (j = i + 1; j <= n; j++) if (a[j] < a[i]) { x = a[i]; a[i] = a[j]; a[j] = x }; s = a[1]; for (i = 2; i <= n; i++) s = s "," a[i]; print "Allow (sorted): " s; next } { print }' | paste -sd'|' -)
  local n; n=$(wc -c < $o.b | tr -d ' ')
  local bd; if [ "$n" -le 330 ] && [ "$n" -gt 0 ]; then bd=$(tr -d '\r' < $o.b | tr '\n' '~' | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/"timestamp":"[^"]*"/"timestamp":"<masked>"/'); else bd="$n B md5 $(sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' $o.b | md5 -q)"; fi
  echo "  $side | $m $p$ex -> $w · headers {$dh} · body $bd"; }
CHOOSE() { local s=$1 port=$2
  rq $s $port GET $API/Ravi
  rq $s $port GET /api/1.0/customers/Ravi
  rq $s $port GET /api/v3/customers/Ravi
  rq $s $port GET /api/2.0/customers/Ravi
  rq $s $port GET /api/customers/Ravi
  rq $s $port GET /api/v1/nowhere
  rq $s $port GET /api
  rq $s $port GET /api/
  rq $s $port GET $API/Ravi -H 'API-Version: 2.0'
  rq $s $port GET $API/Ravi -H 'Accept: application/json;version=2.0'
  rq $s $port GET "$API/Ravi?version=2.0"
  rq $s $port OPTIONS $API/Ravi
  rq $s $port HEAD $API/Ravi
  rq $s $port GET /customers/Ravi; }
# the seven in a JVM: c5-unit11/curlset.sh (no key header); its POST /shutdown stops a healthy JVM, a required-version JVM is stopped by pid
seven() { local lab=$1 port=$2 i=0
  sh $CURLSET $port .harness/run/$lab/secrets/tiffinbox/shutdown-token > $J/seven-$lab.txt 2>&1
  while kill -0 "$(cat .harness/run/$lab/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 60 ] || break; sleep 0.05; done
  echo "  $lab: the seven $(md5 -q $J/seven-$lab.txt) ($(wc -l < $J/seven-$lab.txt | tr -d ' ') lines) · the seven's requests (the access log): $(alog $lab | tail -7 | awk '{ print $1, $2, $3 }' | paste -sd'|' -)"
  QUIET=1 tbstop $lab $port; echo "  $lab stopped: $( [ $i -lt 60 ] && echo "by the seven's own POST /shutdown" || echo 'by its recorded pid (the seven'"'"'s POST /shutdown did not stop it)')"; }
c_choose() { local s
  echo "== D2 on /api/ (the path's second segment under /api/, not required, 1.0 supported): the fourteen requests, then the seven, each tree its own JVM, H2, no harness"
  for s in before after; do local port; [ $s = before ] && port=21016 || port=21010
    TREE=$s tb choose-$s $port h2 ""
    CHOOSE $s $port
    seven choose-$s $port; done
  echo "== the planted variant (the shipped class with setVersionRequired(false) removed: harness/mirror/required.diff), 21014, H2, no harness - the check that can fail"
  TREE=required tb choose-required 21014 h2 ""
  CHOOSE required 21014
  seven choose-required 21014
  echo "  the expected seven $S466 · the probe's required-variant seven $S7D"
  echo "== ApiVersionTest alone on the planted mirror (mvn -o clean test -pl tiffinbox-web -am -Dtest=ApiVersionTest, Docker-free; MockMvc: no socket, no HTTP client)"
  guard "ApiVersionTest on the required mirror"
  bg "cd .harness/required && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean test -pl tiffinbox-web -am -Dtest=ApiVersionTest -Dsurefire.failIfNoSpecifiedTests=false" .harness/required-test.log
  offl .harness/required-test.log
  echo "  ApiVersionTest on the required mirror: exit $RE"; ck junit .harness/required/tiffinbox-web/target/surefire-reports ApiVersionTest
  $G -E '^ApiVersionTest: ' .harness/required-test.log | sed 's/^/  printed | /'; }

surefire() { local f; for f in "$1"/TEST-*.xml; do ck surefire "$f"; done; }
reactor() { $G -E '^\[INFO\] (Reactor Summary|TiffinBox[A-Za-z ]* \.+ (SUCCESS|FAILURE|SKIPPED))' "$1" | sed -E 's/ \.+ / ... /; s/\[ *[0-9.:]+ (s|min)\]//; s/^\[INFO\] /  reactor: /; s/ *$//'; }
c_tests() { local p
  echo "== mvn -o clean package (tests on) on a copy of after/ (.harness/pkg): the whole reactor, three modules, Docker reachable"
  guard "mvn package"
  copy after .harness/pkg; copy after .harness/twin; copy after .harness/tests; copy after .harness/webonly
  bg "cd .harness/pkg && DOCKER_HOST=\"$DH\" $MV \"$AL\" clean package" .harness/pkg.log
  echo "  mvn package exit $RE · Downloading/Downloaded from: $($G -cE 'Download(ing|ed) from ' .harness/pkg.log || true)"; reactor .harness/pkg.log
  echo "  the page step's line (package): $($G -oE 'asciidoctor:[0-9.]+:process-asciidoc \([a-z]+\) @ [a-z-]+' .harness/pkg.log | head -1)"
  echo "== Surefire's XML, per module and class (package)"
  for p in tiffinbox-web tiffinbox-client; do surefire .harness/pkg/$p/target/surefire-reports | sed "s/^  /  $p | /"; done
  ck junit .harness/pkg/tiffinbox-web/target/surefire-reports ApiVersionTest
  $G -E '^ApiVersionTest: ' .harness/pkg.log | sed 's/^/  printed | /'
  echo "== the Docker-free twin: the same, DOCKER_HOST=unix:///nonexistent/docker.sock (.harness/twin)"
  guard "the Docker-free twin"
  bg "cd .harness/twin && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package" .harness/twin.log
  echo "  mvn package (Docker-free) exit $RE · Downloading/Downloaded from: $($G -cE 'Download(ing|ed) from ' .harness/twin.log || true)"; reactor .harness/twin.log
  for p in tiffinbox-web tiffinbox-client; do surefire .harness/twin/$p/target/surefire-reports | sed "s/^  /  twin $p | /"; done
  echo "== the web module's tests before this change, and the @Test lines the change adds (after/ against before)"
  echo "  unit 11's values block: $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit11/README.md | $G -E '^tests: ' | $G -oE 'web_tests=[0-9]+')"
  echo "  new @Test | ApiVersionTest | $($G -cE '^ +@Test$' after/$VT) | $($G -A1 -E '^ +@Test$' after/$VT | $G -oE 'void [A-Za-z]+' | sed 's/^void //' | paste -sd, -) | before/$VT: $( [ -e before/$VT ] && echo present || echo absent)"
  for p in $(cd before && find tiffinbox-web/src/test tiffinbox-core/src -type f | sort); do cmp -s before/$p after/$p || echo "  MOVED existing test or core file: $p"; done
  echo "  existing tests (tiffinbox-web/src/test, tiffinbox-core/src) before -> after/: $(for p in $(cd before && find tiffinbox-web/src/test tiffinbox-core/src -type f); do cmp -s before/$p after/$p || echo x; done | wc -l | tr -d ' ') files differ"
  echo "  the test classes that send /api/v1/ (grep -l, counted): $( (cd after && $G -rl '/api/v1/' tiffinbox-web/src/test/java) | sed 's#.*/##; s#\.java$##' | sort | paste -sd, -)"
  for p in $( (cd after && $G -rl '/api/v1/' tiffinbox-web/src/test/java) | sed 's#.*/##; s#\.java$##' | sort); do ck surefire .harness/pkg/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.$p.xml | sed 's/^  /  sends \/api\/v1\/ | /'; done
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
  echo "  Testcontainers containers after: $(dk ps -aq --filter label=org.testcontainers=true | wc -l | tr -d ' ') · listeners on 21280-21284 after: $(for p in 21280 21281 21282 21283 21284; do listeners $p; done | paste -sd+ - | bc)"
  echo "== the hand-built form: mvn -o clean package -pl tiffinbox-web -am on a copy of after/ (.harness/webonly), Docker-free"
  guard "the web-only form"
  bg "cd .harness/webonly && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package -pl tiffinbox-web -am" .harness/webonly.log
  echo "  exit $RE · Downloading/Downloaded from: $($G -cE 'Download(ing|ed) from ' .harness/webonly.log || true)"; reactor .harness/webonly.log; offl .harness/webonly.log
  surefire .harness/webonly/tiffinbox-web/target/surefire-reports | sed "s/^  /  webonly tiffinbox-web | /"
  echo "== BOOT-INF/lib before -> after"
  for t in before after; do echo "  $t: $(ls .harness/$t/$XD/lib | wc -l | tr -d ' ') jars · $(ls .harness/$t/$XD/lib | $G -E '^(spring-boot-[0-9]|spring-webmvc-|spring-web-[0-9]|tomcat-embed-core-|springdoc-openapi-starter-webmvc-ui-)' | sort | paste -sd' ' -)"; done
  echo "  the jars' names moved before -> after: $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c '^[<>]' || true)"; }

c_change() {
  ck modtable "$UP" after before
  echo "== the pom diffs (after/ against before)"
  for p in pom.xml tiffinbox-web/pom.xml tiffinbox-core/pom.xml tiffinbox-client/pom.xml; do echo "  $p before -> after: $(cmp -s before/$p after/$p && echo byte-identical || echo DIFFERENT)"; done
  echo "== the new class, whole ($VC, md5 $(md5 -q after/$VC))"
  sed 's/^/  | /' after/$VC
  echo "== spring-webmvc and spring-web in after/'s web jar (BOOT-INF/lib, the version the configurer runs on)"
  echo "  $(ls .harness/after/$XD/lib | $G -E '^spring-web(mvc)?-[0-9]' | sort | paste -sd' ' -)"
  echo "== the literal mappings under src/main (grep, after/): every @...Mapping string under /api/, and any version attribute or {version}"
  (cd after/tiffinbox-web/src/main/java/com/tiffinbox/web && $G -nE '@(Get|Post|Patch|Put|Delete|Request)Mapping\((path = )?"/api/' *.java) | sed 's/^/  mapping | /'
  echo "  mappings with a version attribute or {version}: $( (cd after/tiffinbox-web/src/main/java && $G -rnE '@(Get|Post|Patch|Put|Delete|Request)Mapping\(.*(version *=|\{version\})' .) | wc -l | tr -d ' ')"
  echo "  the five mapping files before -> after: $(for f in CustomerReads CustomerPauses CustomerPatches IdempotencyKeyFilter TiffinBoxOpenApi TiffinBoxErrors; do cmp -s before/tiffinbox-web/src/main/java/com/tiffinbox/web/$f.java after/tiffinbox-web/src/main/java/com/tiffinbox/web/$f.java && echo "$f=" || echo "$f MOVED"; done | paste -sd' ' -)"
  echo "  the committed file: md5 $(md5 -q $SPECF) · $(cmp -s before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json $SPECF && echo byte-identical || echo DIFFERENT) to before's"; }

# the carrier mirror (nover: the shipped class deleted), one JVM per variant on 21013, the harness's Versioning12 and its route pair joined
QV() { local v=$1 p=21013
  rq $v $p GET /vapi/customers
  rq $v $p GET /vapi/customers -H 'API-Version: 1.0'
  rq $v $p GET /vapi/customers -H 'API-Version: 2.0'
  rq $v $p GET /vapi/customers -H 'API-Version: 3.0'
  rq $v $p GET "/vapi/customers?version=1.0"
  rq $v $p GET "/vapi/customers?version=2.0"
  rq $v $p GET /vapi/customers -H 'Accept: application/json;version=1.0'
  rq $v $p GET /vapi/customers -H 'Accept: application/json;version=2.0'
  rq $v $p GET /vapi/customers -H 'Content-Type: application/json;version=2.0'
  rq $v $p GET /vapi/1.0/customers
  rq $v $p GET /vapi/2.0/customers
  rq $v $p GET /customers/Ravi
  rq $v $p GET $API/Ravi; }
variant() { local v=$1
  SRC='probe.u12.Versioning12,probe.u12.Versioning12$Routes' TREE=nover tb var-$v 21013 h2 "$U/.harness/hc" --probe.ver=$v
  echo "  VER12 line: $($G -o 'VER12 variant [A-Z]*' .harness/run/var-$v/jvm.log | head -1)"
  QV $v
  seven var-$v 21013; }
c_four() { local v
  echo "== the carrier mirror: after/ with TiffinBoxApiVersioning deleted (harness/mirror/nover.diff), the harness's probe.u12.Versioning12 the JVM's one configurer, its route pair /vapi/customers (1.0, 2.0) and /vapi/{v}/customers - the harness's routes"
  for v in H Q M P; do echo "== variant $v (the harness's mirror)"; variant $v; done
  echo "  the probe's sevens (expectation lines, 1 run): H $(md5 -q "$PK/captures/ver/H.seven") · Q $(md5 -q "$PK/captures/ver/Q.seven") · M $(md5 -q "$PK/captures/ver/M.seven") · P $(md5 -q "$PK/captures/ver/P.seven")"
  echo "== two configurers in one JVM (the shipped class left beside the harness's): after/'s own jar with Versioning12 joined, variant H, shown once"
  SRC='probe.u12.Versioning12,probe.u12.Versioning12$Routes' TREE=after tb two 21013 h2 "$U/.harness/hc" --probe.ver=H
  rq two 21013 GET $API/Ravi; rq two 21013 GET /customers/Ravi; rq two 21013 GET /vapi/customers -H 'API-Version: 1.0'
  QUIET=1 tbstop two 21013; echo "  two stopped"; }
c_required() {
  echo "== required: the carrier mirror's H (a required header, the harness's route) beside the planted shipped-class twin (choose's required mirror, TiffinBox's own routes)"
  $G -E '^  H \| GET (/customers/Ravi|/api/v1/customers/Ravi|/vapi/customers) ->' .r-four.new | head -3
  $G -E '^  var-H: the seven ' .r-four.new
  $G -E '^  required \| GET (/customers/Ravi|/api/v1/customers/Ravi) ->' .r-choose.new
  $G -E '^  choose-required: the seven ' .r-choose.new
  echo "  (both lines are read off this run's four and choose captures, printed above them)"; }
c_default() {
  echo "== default: variant HD (a required header with a default, setDefaultVersion(\"1.0\")) on the carrier mirror - trap 4"
  variant HD
  echo "== the trap's request alone, read by python (the body's handler beside the echoed Content-Type)"
  SRC='probe.u12.Versioning12,probe.u12.Versioning12$Routes' TREE=nover tb trap 21013 h2 "$U/.harness/hc" --probe.ver=HD
  $CURL --http1.1 -sS -D $J/trap.h -o $J/trap.b -H 'Accept: application/json;version=2.0' "$(B 21013)/vapi/customers" > /dev/null
  python3 -I -c 'import json,sys; h = open(sys.argv[1]).read().replace("\r", "").split("\n"); ct = next((l.split(": ", 1)[1] for l in h if l.lower().startswith("content-type:")), "-"); b = json.load(open(sys.argv[2])); print("  trap 4 | request Accept: application/json;version=2.0 | status %s | Content-Type %s | body handler %s | the body says %s; the header says %s" % (h[0].split(" ")[1], ct, b.get("handler"), b.get("handler"), ct.split("version=")[1] if "version=" in ct else "-"))' $J/trap.h $J/trap.b
  QUIET=1 tbstop trap 21013; echo "  trap stopped"
  echo "== both ways (read off this run's four capture): the same Accept against H, the header client against M"
  $G -E '^  H \| GET /vapi/customers \[Accept: application/json;version=2.0\] ->' .r-four.new
  $G -E '^  M \| GET /vapi/customers \[API-Version: 2.0\] ->' .r-four.new
  echo "  the probe's HD seven (expectation, 1 run): $(md5 -q "$PK/captures/ver/HD.seven")"; }
c_newest() {
  echo "== newest: variant HN (a header, not required, no default) on the carrier mirror"
  variant HN
  echo "  the probe's HN seven (expectation, 1 run): $(md5 -q "$PK/captures/ver/HN.seven")"; }
DEPREQ() { local s=$1 port=$2
  rq $s $port GET $API/Ravi
  rq $s $port GET /api/1.0/customers/Ravi
  rq $s $port GET /customers/Ravi
  rq $s $port GET /customers
  rq $s $port GET /revenue
  rq $s $port GET /nowhere; }
c_deprecate() {
  echo "== deprecate: the shipped class with a deprecation handler for 1.0 (harness/mirror/deprecate.diff, the probe's deprecations() shape), H2"
  $G -E '^[-+] ' harness/mirror/deprecate.diff | sed 's/^/  deprecate.diff | /'
  TREE=deprecate tb dep 21013 h2 ""
  DEPREQ dep 21013
  $CURL --http1.1 -sS -D $J/dep.h -o /dev/null "$(B 21013)$API/Ravi"
  python3 -I -c 'import re,sys; h = open(sys.argv[1]).read().replace("\r", "").split("\n"); s = next((l.split(": ", 1)[1] for l in h if l.startswith("Sunset:")), ""); m = re.match(r"^[A-Z][a-z]{2}, (\d+) ", s); print("  the Sunset value read by python: its day field holds %s digits (RFC 9110 day = 2DIGIT)" % (len(m.group(1)) if m else "no"))' $J/dep.h
  tr -d '\r' < $J/dep.h | $G -E '^(Deprecation|Sunset|Link):' | sed 's/^/  as written (masked by the capture mask) | /'
  seven dep 21013
  echo "== the harness's route pair on the same jar, harness-joined (21015): /api/1.0/u12/handler, /api/v1/u12/handler, /api/2.0/u12/handler, /u12/plain"
  SRC=probe.u12.U12Routes TREE=deprecate tb depj 21015 h2 "$U/.harness/hc"
  rq depj 21015 GET /api/1.0/u12/handler; rq depj 21015 GET /api/v1/u12/handler; rq depj 21015 GET /api/2.0/u12/handler; rq depj 21015 GET /u12/plain; rq depj 21015 GET $API/Ravi
  tbstop depj 21015
  echo "  the anchor (after/) names Deprecation, Sunset, StandardApiVersionDeprecationHandler: $($G -rcE 'Deprecation|Sunset|StandardApiVersionDeprecationHandler' after/tiffinbox-web/src/main | awk -F: '{ s += $2 } END { print s + 0 }') times under src/main"; }
c_retire() {
  echo "== retire, the PATH carrier: the shipped class with 2.0 supported and 1.0 not (harness/mirror/retire.diff), H2; the harness's mappings exposure flag on"
  $G -E '^[-+] ' harness/mirror/retire.diff | sed 's/^/  retire.diff | /'
  TREE=retire tb ret 21013 h2 "" --management.endpoints.web.exposure.include=health,mappings
  rq ret 21013 GET $API/Ravi
  rq ret 21013 GET /api/2.0/customers/Ravi
  rq ret 21013 GET /customers/Ravi
  rq ret 21013 GET $API/Nobody
  $CURL -s "$(B 21013)/actuator/mappings" > $J/mappings.json
  python3 -I -c 'import json,sys; d = json.load(open(sys.argv[1])); ps = sorted({p for c in d["contexts"].values() for ds in c["mappings"]["dispatcherServlets"].values() for x in ds for p in (x.get("details") or {}).get("requestMappingConditions", {}).get("patterns", []) if p.startswith("/api/")}); print("  /actuator/mappings (the harness exposure flag): handler patterns under /api/ still mapped: %s" % " ".join(ps))' $J/mappings.json
  seven ret 21013
  echo "== retire, the HEADER carrier (HR, the carrier mirror: header API-Version, 2.0 only, detectSupportedVersions(false)), once"
  variant HR
  echo "  the probe's HR seven (expectation, 1 run): $(md5 -q "$PK/captures/ver/HR.seven") · ver.log's HR line for header 1.0 (expectation): $(awk '/^== variant HR/{ w = 1 } w && /header 1\.0 ->/ { sub(/^ +/, ""); print; exit }' "$PK/captures/ver.log" | cut -c1-200)"; }
TYPEREQ() { local s=$1 port=$2
  rq $s $port GET $API/Nobody
  rq $s $port GET /customers/Nobody
  rq $s $port PATCH $API/Nobody -H "$MPT" --data-binary '{"mealsPerDay":2}'; }
c_type() { local s
  echo "== the Nobody not-found under the versioned route, each tree its own JVM, H2, no harness; bodies read by python"
  for s in before after; do local port; [ $s = before ] && port=21016 || port=21010
    TREE=$s tb type-$s $port h2 ""
    TYPEREQ $s $port
    $CURL -s -o $J/type-$s.b "$(B $port)$API/Nobody"
    python3 -I -c 'import json,sys; b = json.load(open(sys.argv[1])); print("  %s | members %s | type %s | instance %s | status %s | title %s | name %s" % (sys.argv[2], ",".join(b), b.get("type"), b.get("instance"), b.get("status"), b.get("title"), b.get("name")))' $J/type-$s.b $s
    tbstop type-$s $port; done
  echo "  the two trees' Nobody bodies: $(cmp -s $J/type-before.b $J/type-after.b && echo equal || echo DIFFER)"
  python3 -I -c 'import json,sys; d = json.load(open(sys.argv[1])); ex = d["paths"]["/api/v1/customers/{name}"]["get"]["responses"]["404"]["content"]["application/problem+json"]["examples"]; print("  the committed file'"'"'s example type(s): %s" % ",".join(sorted({v["value"].get("type", "-") for v in ex.values()})))' $SPECF
  echo "== the same Nobody request on the retired mirror (retire.diff), H2"
  TREE=retire tb type-ret 21013 h2 ""
  rq retired 21013 GET $API/Nobody
  $CURL -s -o $J/type-ret.b "$(B 21013)$API/Nobody"
  python3 -I -c 'import json,sys; b = json.load(open(sys.argv[1])); print("  retired | members %s | type %s | status %s | detail %s" % (",".join(b), b.get("type", "absent (about:blank by default)"), b.get("status"), b.get("detail")))' $J/type-ret.b
  tbstop type-ret 21013; }
caller() { local o=$J/caller.out; guard "the runner ($1)"
  perl -e '$SIG{INT}="DEFAULT"; alarm 120; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -cp "$U/.harness/hcc:$CCP" probe.u10.Caller "$@" > $o 2>&1; local rc=$?
  echo "  caller $1 (exit $rc):"; sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/^/    /' $o | cut -c1-240; }
c_client() { local f
  echo "== U10's generated client: its sources not regenerated, not edited (the reactor's build of after/)"
  echo "  .openapi-generator/FILES: $(find $GR -name FILES -path '*.openapi-generator*' | head -1 | xargs md5 -q) · $(find $GR -name FILES -path '*.openapi-generator*' | head -1 | xargs $G -c '\.java$') Java files"
  f=$GR/src/main/java/com/tiffinbox/client/api/ApiApi.java
  echo "  ApiApi.java: lines naming \"/api/v1/: $($G -c '"/api/v1/' $f) · distinct /api/ strings: $($G -oE '"/api/[^"]*"' $f | sort -u | paste -sd' ' -) · containing {version}: $($G -c '{version}' $f || true)"
  echo "== the runner against after/ on 21010 (H2, no harness): the RestClient is the runner's (U10's Caller, byte-equal)"
  TREE=after tb client-after 21010 h2 ""
  caller call "$(B 21010)"; caller nobody "$(B 21010)"; caller pause "$(B 21010)"
  echo "  the access log (no time field): $(alog client-after | paste -sd'|' -)"
  tbstop client-after 21010
  echo "== the same calls against the retired mirror (retire.diff) on 21013"
  TREE=retire tb client-ret 21013 h2 ""
  caller call "$(B 21013)"; caller nobody "$(B 21013)"
  echo "  the access log (no time field): $(alog client-ret | paste -sd'|' -)"
  tbstop client-ret 21013; }
c_restdocs() { local t f
  echo "== U11's TiffinBoxRestDocsTest alone on a copy of after/ and on a copy of before, each built in this shell (mvn -o clean test -pl tiffinbox-web -am -Dtest=TiffinBoxRestDocsTest, Docker-free; MockMvc: no socket, no HTTP client)"
  for t in after before; do copy $t .harness/rd-$t; guard "REST Docs on $t"
    pollband .harness/poll-rd-$t.txt
    bg "cd .harness/rd-$t && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean test -pl tiffinbox-web -am -Dtest=TiffinBoxRestDocsTest -Dsurefire.failIfNoSpecifiedTests=false" .harness/rd-$t.log
    pollstop; offl .harness/rd-$t.log
    echo "  $t: exit $RE · listeners 20400-21299 during the MockMvc run: $(sort -n .harness/poll-rd-$t.txt | tail -1)"; ck junit .harness/rd-$t/tiffinbox-web/target/surefire-reports TiffinBoxRestDocsTest
    for f in $(ls .harness/rd-$t/tiffinbox-web/target/generated-snippets/customer-read); do echo "  snippet | $t | $f | $(md5 -q .harness/rd-$t/tiffinbox-web/target/generated-snippets/customer-read/$f)"; done; done
  for f in $(ls .harness/rd-after/tiffinbox-web/target/generated-snippets/customer-read); do echo "  compare | $f | $(cmp -s .harness/rd-after/tiffinbox-web/target/generated-snippets/customer-read/$f .harness/rd-before/tiffinbox-web/target/generated-snippets/customer-read/$f && echo equal || echo differ)"; done
  echo "  the test file before -> after: $(cmp -s before/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxRestDocsTest.java after/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxRestDocsTest.java && echo byte-identical || echo DIFFERENT)"
  echo "  U11's own pass capture on this disk: $( [ -f ../c9-unit11/.r-pass.out ] && echo "present (an ignored file - an expectation only): $($G -E 'snip customer-read \|' ../c9-unit11/.r-pass.out | awk -F'|' '{ gsub(/ /, "", $2); gsub(/ /, "", $4); print $2 "=" substr($4, 1, 8) }' | paste -sd' ' -)" || echo 'not in a clone')"
  echo "== http-request.adoc and path-parameters.adoc, whole (after/'s run)"
  sed 's/^/  http-request | /' .harness/rd-after/tiffinbox-web/target/generated-snippets/customer-read/http-request.adoc; echo
  sed 's/^/  path-parameters | /' .harness/rd-after/tiffinbox-web/target/generated-snippets/customer-read/path-parameters.adoc; echo
  echo "  http-response.adoc's Content-Type: $(sed -n 's/^Content-Type: //p' .harness/rd-after/tiffinbox-web/target/generated-snippets/customer-read/http-response.adoc)"; }
c_replay() {
  echo "== the replay under /api/v1/ (harness-joined, 21015, a fresh database; the key table read by the second client)"
  TREE=after tb replay 21015 h2 "$U/.harness/hc"
  health 21015
  local k='"u12-key-1"'
  echo "  key table | replay-start | $($CURL -s "$(B 21015)/probe/u12/keys" | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])')"
  for i in 1 2; do $CURL --http1.1 -sS -D $J/rp$i.h -o $J/rp$i.b -X POST -H "$KEYH: $k" "$(B 21015)$API/Ravi/pauses?days=1" > /dev/null
    echo "  step $i | POST $API/Ravi/pauses?days=1 [the key $k] -> $(tr -d '\r' < $J/rp$i.h | head -1 | cut -d' ' -f2) · headers {$(tr -d '\r' < $J/rp$i.h | $G -vE '^(HTTP|Date|Keep-Alive|Connection|$)' | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' | paste -sd'|' -)} · body $(cat $J/rp$i.b)"
    echo "  key table | after-step-$i | $($CURL -s "$(B 21015)/probe/u12/keys" | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])')"; done
  python3 -I - $J/rp1.h $J/rp1.b $J/rp2.h $J/rp2.b <<'PY'
import json, sys
def parts(h, b):
    ls = open(h).read().replace("\r", "").split("\n"); hd = {l.split(": ", 1)[0].lower(): l.split(": ", 1)[1] for l in ls[1:] if ": " in l}
    return {"status": ls[0].split(" ")[1], "location": hd.get("location"), "content-type": hd.get("content-type"), "body": json.load(open(b))}
a, c = parts(sys.argv[1], sys.argv[2]), parts(sys.argv[3], sys.argv[4])
print("  the four parts (status, Location, Content-Type, body), step 1 against step 2: %s" % " ".join("%s=%s" % (k, "equal" if a[k] == c[k] else "DIFFER") for k in a))
PY
  echo "  Ravi's customer row after the two steps (the second client): $($CURL -s "$(B 21015)/probe/u12/row/Ravi" | head -c 200)"
  $CURL --http1.1 -sS -D $J/rp3.h -o $J/rp3.b -X POST -H "$KEYH: $k" "$(B 21015)/api/1.0/customers/Ravi/pauses?days=1" > /dev/null
  echo "  step 3 | POST /api/1.0/customers/Ravi/pauses?days=1 [the key $k, the other spelling] -> $(tr -d '\r' < $J/rp3.h | head -1 | cut -d' ' -f2) · $(tr -d '\r' < $J/rp3.h | $G -i '^Content-Type:' ) · body $(sed -E 's/"timestamp":"[^"]*"/"timestamp":"<masked>"/' $J/rp3.b | head -c 300)"
  echo "  key table | after-step-3 | $($CURL -s "$(B 21015)/probe/u12/keys" | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])')"
  echo "  the filter's guarded table (IdempotencyKeyFilter.java, after/): $($G -oE '"POST /api[^"]*"' after/tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java | paste -sd' ' -)"
  tbstop replay 21015; }
c_committed() {
  echo "== (i) the committed file: $SPECF"
  echo "  bytes $(wc -c < $SPECF | tr -d ' ') (wc -c) · md5 $(md5 -q $SPECF) · before's (U11's) md5 $(md5 -q before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json) · $(cmp -s before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json $SPECF && echo byte-identical || echo DIFFERENT) · servers member: $(python3 -I -c 'import json,sys; print("present" if "servers" in json.load(open(sys.argv[1])) else "absent")' $SPECF) · git diff 197ff80 on it: $(git -C "$UP" diff 197ff80 -- c9-tiffinbox/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | wc -l | tr -d ' ') lines"
  echo "== (ii) the file against the served document on after/ (21010, H2, no harness), servers removed"
  TREE=after tb cm 21010 h2 ""
  $CURL -s "$(B 21010)/v3/api-docs" > $J/spec-h2.raw
  python3 -I -c 'import io,json,sys; d = json.load(open(sys.argv[1], encoding="utf-8")); d.pop("servers", None); b = io.StringIO(); json.dump(d, b, indent=2, ensure_ascii=False); b.write("\n"); open(sys.argv[2], "w", encoding="utf-8").write(b.getvalue())' $J/spec-h2.raw $J/spec-h2.json
  tbstop cm 21010
  echo "  the served document, servers removed (the fixed rule): md5 $(md5 -q $J/spec-h2.json) · = the committed file: $(cmp -s $J/spec-h2.json $SPECF && echo byte-identical || echo DIFFERENT)"
  python3 -I -c 'import json,sys; d = json.load(open(sys.argv[1])); ks = sorted(k for k in d["paths"] if k.startswith("/api/")); print("  info.version %s · the path keys under /api/ (%d): %s · the version token in the keys: %s · info.version and the keys'"'"' token the same string: %s" % (d["info"]["version"], len(ks), " ".join(ks), ",".join(sorted({k.split("/")[2] for k in ks})), "yes" if {k.split("/")[2] for k in ks} == {d["info"]["version"]} else "no"))' $SPECF
  echo "== (iii) OpenApiSpecTest in the tests capture's package and its Docker-free twin (Surefire's XML)"
  ck surefire .harness/pkg/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.OpenApiSpecTest.xml | sed 's/^/  package:/'
  ck surefire .harness/twin/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.OpenApiSpecTest.xml | sed 's/^/  twin:/'
  echo "== (iv) the document with versioned routes: after/ harness-joined with the harness's route pair (probe.u12.U12Routes), 21015 - the harness's routes"
  SRC=probe.u12.U12Routes TREE=after tb cmj 21015 h2 "$U/.harness/hc"
  local w; w=$($CURL -s -o $J/spec-j.json -w '%{http_code} %{content_type}' "$(B 21015)/v3/api-docs")
  echo "  GET /v3/api-docs -> $w"
  python3 -I -c 'import json,sys
try: d = json.load(open(sys.argv[1]))
except ValueError as e: print("  the document is not JSON (%s)" % e); sys.exit(0)
print("  openapi %s · paths %d" % (d.get("openapi"), len(d.get("paths", {}))))
for p, v in sorted(d.get("paths", {}).items()):
    if "u12" in p: print("  versioned path | %s | operations %d | operationIds %s" % (p, len(v), ",".join(o.get("operationId", "-") for o in v.values())))' $J/spec-j.json
  echo "  the JVM's log: exceptions $($G -cE 'Exception|ERROR' .harness/run/cmj/jvm.log || true)"
  rq cmj 21015 GET /api/1.0/u12/handler; rq cmj 21015 GET /api/v1/u12/handler; rq cmj 21015 GET /api/2.0/u12/handler; rq cmj 21015 GET /api/v2/u12/handler; rq cmj 21015 GET /api/3.0/u12/handler; rq cmj 21015 GET /api/u12/handler
  tbstop cmj 21015; }
movedone() { local port=$1 m=$2 p=$3 w; shift 3; : > $J/mv.h; : > $J/mv.b
  w=$($CURL --http1.1 -sS -D $J/mv.h -o $J/mv.b -w '%{http_code} %{content_type} %{size_download}' --max-time 5 -X "$m" "$@" "$(B $port)$p" 2> /dev/null)
  local bm; bm=$(sed -E 's/"timestamp":"[^"]*"/"timestamp":"<masked>"/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' $J/mv.b | md5 -q | cut -c1-12)
  w=$(echo "$w" | awk '{ print $1, $2 }')
  echo "  $SIDE | $m $p$( [ -n "${TAG:-}" ] && echo " [$TAG]") -> $w $(sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' $J/mv.b | wc -c | tr -d ' ') · Allow {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Aa]llow: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)} · Accept-Patch {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Aa]ccept-[Pp]atch: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)} · Location {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Ll]ocation: //p' | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/')} · body $bm"; }
movedside() { local side=$1 port=$2 a
  TREE=$side tb moved-$side $port h2 ""
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
c_moved() { echo "== U11's nineteen requests (its movedside list, copied) on before (21016) and after/ (21010), H2, each its own JVM, no harness; bodies hashed (and sized) with Boot's /error timestamp and any port masked"
  movedside before 21016; movedside after 21010
  echo "== the build-level witnesses: the web jar before and after, per entry (unzip -lv: every entry's name and CRC, python over both lists)"
  echo "  web jar md5: before $(md5 -q .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar) · after $(md5 -q .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar)"
  for t in before after; do unzip -lv .harness/$t/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | awk 'NF >= 8 && $1 ~ /^[0-9]+$/ { print $7, $8 }' | sort -k2 > $J/jar-$t.txt; done
  python3 -I - $J/jar-before.txt $J/jar-after.txt <<'PY'
import sys
a = dict(l.split(" ", 1)[::-1] for l in open(sys.argv[1]).read().splitlines()); b = dict(l.split(" ", 1)[::-1] for l in open(sys.argv[2]).read().splitlines())
print("  entries before %d · after %d · BOOT-INF/lib names before %d · after %d" % (len(a), len(b), sum(1 for k in a if k.startswith("BOOT-INF/lib/")), sum(1 for k in b if k.startswith("BOOT-INF/lib/"))))
print("  entry names only after has: %s" % (",".join(sorted(set(b) - set(a))) or "none"))
print("  entry names only before has: %s" % (",".join(sorted(set(a) - set(b))) or "none"))
mv = [k for k in sorted(set(a) & set(b)) if a[k] != b[k]]
print("  shared entries whose CRC moved: %s" % (",".join(mv) or "none"))
PY
  echo "  entries named restdocs, asciidoctor, jruby or generated-docs: before $($G -ciE 'restdocs|asciidoctor|jruby|generated-docs' $J/jar-before.txt || true) · after $($G -ciE 'restdocs|asciidoctor|jruby|generated-docs' $J/jar-after.txt || true)"; }
c_seven() {
  echo "== the seven (c5-unit11/curlset.sh, no key header), as choose's JVMs printed it after its fourteen requests (each tree its own JVM, H2, no harness): the expected $S466"
  $G -E '^  choose-(before|after|required): the seven ' .r-choose.new | sed -E 's/ · the seven.s requests.*//'
  $G -E '^  (before|after) \| ' .r-choose.new | awk '{ print $3, $4 }' | sort -u | sed 's/^/  choose sent | /' | head -20
  echo "  the seven sends no request under /api/ (its paths, read off curlset.sh): $($G -oE '^req [A-Z]+ /[a-z]*' $CURLSET | awk '{ print $3 }' | paste -sd' ' -) and POST /shutdown"; }
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
c_surface() { local side port
  echo "== the old surface by count (U11's reader, copied), each tree its own JVM, H2, no harness: the expected $U4SURF"
  for side in before after; do [ $side = before ] && port=21016 || port=21010
    TREE=$side tb surface-$side $port h2 ""
    oldsurface2 $port $J/surface-$side.txt
    tbstop surface-$side $port
    echo "  $side: the old surface $(md5 -q $J/surface-$side.txt) ($($G -c '^== ' $J/surface-$side.txt) requests, $(wc -l < $J/surface-$side.txt | tr -d ' ') lines)"; done
  echo "  before -> after/: $(cmp -s $J/surface-before.txt $J/surface-after.txt && echo equal || echo DIFFER)"
  diff $J/surface-before.txt $J/surface-after.txt | sed 's/^/    moved: /'; }
c_inert() { local f
  echo "== every request line of this run's captures, and the key header"
  for f in .r-choose.new .r-four.new .r-deprecate.new .r-retire.new .r-type.new .r-moved.new .r-default.new .r-newest.new .r-committed.new; do [ -f $f ] || continue; echo "  $f: request lines $($G -cE '^  [A-Za-z0-9-]+ \| [A-Z]+ /' $f || true) · naming the key header $($G -ciF "$KEYH" $f || true)"; done
  echo "  .r-replay.new: requests carrying the key $($G -cF '[the key ' .r-replay.new || true) (steps 1, 2 and 3: the named ones)"
  echo "== the key table, read by the second client on the harness-joined JVM that sent the key"
  $G -hE '^  key table \| ' .r-replay.new
  echo "  the other harness-joined JVMs (four's, default's, newest's and retire's variants, deprecate's and committed's route-pair starts) send no POST and no key"
  echo "  MockMvc runs: key header sent 0 (ApiVersionTest and TiffinBoxRestDocsTest send GETs)"
  echo "  the harness-free JVMs are not read after the fact: H2 in memory ends with its JVM; their witness is the access log"; }
exrun() { local v=$1 sh=$2 o cmd
  guard "the exercise, $v, $sh"
  rm -rf .harness/exercise/tree; copy after .harness/exercise/tree
  case $v in broken) cmd='sh break.sh "$0" && sh check.sh "$0"' ;; solved) cmd='sh break.sh "$0" > /dev/null && sh apply.sh "$0" && sh check.sh "$0"' ;; none) cmd='sh break.sh "$0" > /dev/null && sh check.sh "$0"' ;; *) cmd="sh break.sh \"\$0\" > /dev/null && HOW=$v sh apply.sh \"\$0\" && sh check.sh \"\$0\"" ;; esac
  echo "== the exercise, h2, $v, $sh (env -i, from the exercise's folder; the tree a fresh copy of after/; built offline from the receipt's seed copy, its jar alone on 21018):"
  if [ $sh = bash ]; then o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21018 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock bash -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1)
  else o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21018 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock /bin/zsh -f -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1); fi
  printf '%s\n' "$o" | sed -E 's/127\.0\.0\.1:21018/127.0.0.1:<port>/g; s/^/  /'
  [ ! -f exercise/check.build.log ] || offl exercise/check.build.log
  if [ $v = solved ] && [ $sh = bash ]; then echo "  the written answer.http md5 $(md5 -q .harness/exercise/tree/answer.http) · its lines:"; sed 's/^/    | /' .harness/exercise/tree/answer.http; fi
  [ "$(listeners 21018)" = 0 ] || die "the exercise left something listening on 21018"; }
c_exercise() { local v sh
  rm -rf .harness/exercise; mkdir -p .harness/exercise
  for v in broken solved; do for sh in bash zsh; do exrun $v $sh; done; done
  for v in typed404 pasted200 v2request nodetail fixedtree; do exrun $v bash; done
  rm -rf exercise/check.run; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.body.json exercise/check.h
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures${DEVCAPS:+ (DEVELOPMENT: only $DEVCAPS - not a run of record)}"
cap choose c_choose
cap tests c_tests
cap change c_change
cap four c_four
cap required c_required
cap default c_default
cap newest c_newest
cap deprecate c_deprecate
cap retire c_retire
cap type c_type
cap client c_client
cap restdocs c_restdocs
cap replay c_replay
cap committed c_committed
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
MDB=$(find . ../c9-tiffinbox ../c9-unit11 -name '*.mv.db' -not -path './.harness/*' -not -path '../c9-unit11/.harness/*' 2> /dev/null | wc -l | tr -d ' ')
[ "$MDB" = 0 ] || die "an H2 file outside .harness/"
[ -z "$(ls exercise | $G -v -xE 'README.md|SOLUTION.md|apply.sh|break.sh|check.sh')" ] || die "the exercise left a file in exercise/"
VALS="$VALS
static: $STV
gloss: $GLV
spoken: $SPV
build: seed_files=$NF0 seed_bytes=$NB0 central_only=$CO"
[ -n "${DEVCAPS:-}" ] && { printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'; echo "c9-unit12: DEVELOPMENT run ($DEVCAPS) - nothing published"; exit 2; }
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
VO=$(ck values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; die "README.md's values block is not this run's (harness/chk12.py values)"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM of this run, ports free, no container left, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1 · the anchor against after/ as at the start · the tree pins · *.mv.db outside .harness 0 · the values block = this run's"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit12: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit12: every capture = published ($NCAPS) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"
