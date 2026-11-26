#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 16 "Spring HATEOAS in Practice" - this unit's receipts. Course 9's TWELFTH anchor change, Section 3's fourth:
# before is a link to ../c9-unit14/after (U14's after; U15 made no anchor change); after/ is a frozen copy of ../c9-tiffinbox after this
# unit's change - the Spring HATEOAS starter in tiffinbox-web's pom, the non-final OrderResources GET /api/v1/orders/{id} (the order as
# HAL), one by-id read on OrderEntityRepository (tiffinbox-core), OrderResourcesTest, the committed spec regenerated.
# The harness (never in the jar or the module): probe.u16.* - the final census's link forms and the twenty orders as one HAL collection
# (U16Hal), the list's next as a link (U16Next) - joined on a harness-joined start only (21055). No Chrome.
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5; lines starting "  ~" are run-variant
# and left out of the hash - the exercise's refused variants of run 1):
#   advisory  the S9.36 read filed for the batch day (ADV3), verified, before any build
#   before    GET /api/v1/orders/1 and the old routes on before, the mappings, the spec's counts, the lib
#   change    the modules, the new files whole, the derived changed list, the greps, the handler names, application.yaml's keys
#   starter   the pom diff, the lib name lists, the jar per entry
#   jackson   the HAL classes and which Jackson their bytes name, by the printed rule; the BOM line
#   hal       the order as HAL on the wire, its bytes with the host its links carry, following customer (21050)
#   accept    seven Accept values on the new route; three on four old routes (the starter's effect on old answers)
#   refuse    every refusal form of the new route, each status, type and detail; Framework's with no type named
#   final     the census on before and after/; methodOn on the final CustomerReads, the Method form, methodOn on OrderResources (21055)
#   next      the list's next as a link on the harness's page route (21055); the shipped list unmoved (see moved)
#   forwarded X-Forwarded-Host/-Proto at Boot's default and with the run flag --server.forward-headers-strategy=framework (21050)
#   halgz     Boot's compression metadata read back; the shipped route and the harness's HAL collection, gzip asked, flag on
#   specwire  the new route's served entry against its wire
#   spec      the committed spec against the served one, the diff, the counter, the client rebuilt on it
#   moved     U14's requests and the new route on before (21056) and after/ (21050); the jars per entry
#   seven     c5-unit11's seven on before and after/
#   surface   the old surface by count on before and after/, the S9.14 plant (21054)
#   tests     package, the Docker-free twin, verify (Surefire on H2, the five ITs on PostgreSQL), the web-only form, the slice
#   exercise  break.sh, check.sh, apply.sh on 21058, bash and zsh -f, H2; the refused variants (run 1)
#   inert     the key header across this run's captures
# Ports (U16's band, 21050-21059): 21050 after/ on H2, no harness · 21054 the S9.14 plant · 21055 the harness-joined starts · 21056 before
# · 21058 the exercise · 21051, 21052, 21053, 21057 and 21059 never bound (order-pg not captured; no Chrome). During mvn verify only:
# 21280-21284. Every store on 127.0.0.1; every curl --noproxy '*'.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
C9R=${C9R:-"/Users/$ME/Downloads/Youtube Content/LearnProgrammingWithVivek/rest-apis-done-right"}   # the course's folder (briefs, research)
SEED=${SEED:-"$C9R/_research/m2-seed-c9-s3"}   # the course's Section 3 seed
PK3="$C9R/_research/s3-probe-2026-11-26"; BK3="$C9R/_research/s3-blue-2026-11-26"; ADV="$C9R/_research/docs-2026-11-26/advisories"
export C9R
RUNNO=${RUNNO:-0}                                     # the run of record's number (1, 2, 3); 0 = development
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
export DOCKER_HOST="$DH"
PIDS=""; INTR=""; mpid=""
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in $mpid $PIDS; do [ -z "$p" ] || killtree "$p"; done; for p in $mpid $PIDS; do if kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; for c in $(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null); do dk rm -fv "$c" > /dev/null 2>&1; done; rm -rf exercise/check.run; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.b exercise/check.h; [ -z "$INTR" ] || rm -f .r-*.new; rmdir .r-lock 2> /dev/null || rm -rf .r-lock; true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git unzip gunzip /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|SPRINGDOC_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit16 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }') · run $RUNNO"

# ---- gates before anything is built: the folder, the link, the pins, the anchor, the static check, the prose, the exercise ----------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk16.py dur9.py ops9s3.py s916.py src tree16.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
HSRC='probe/u16/U16Config.java probe/u16/U16Hal.java probe/u16/U16Next.java'
[ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$HSRC" ] || die "harness/src holds another file, or misses one"
for f in walk.py follow.py loc9.py seal9.py cdp.mjs cdp9.mjs specwire9.py mirror src/probe/u12 src/probe/u13 src/probe/u14 src/probe/u15 src/probe/u10/Caller.java; do [ ! -e harness/$f ] || die "harness/$f: an earlier unit's instrument this unit does not carry"; done
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md apply.sh break.sh check.sh' ] || die "exercise/ holds another file, or misses one"
[ -L before ] && [ "$(readlink before)" = ../c9-unit14/after ] || die "before must be a link whose text is exactly ../c9-unit14/after"
[ -d after ] && [ ! -L after ] || die "after/ is this unit's own frozen tree, a directory, not a link"
for t in before after; do [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-client/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/"; true; done
echo "  before -> $(readlink before) (a link, the text exact) · after/ a directory (the frozen copy) · no secrets/, target/ or .m2-demo/ in either · harness/: no walk.py, follow.py, seal9.py, cdp.mjs, cdp9.mjs, loc9.py, specwire9.py, mirror/, U12's-U15's harness classes or Caller.java"
$G -v '^ *#' harness/src/probe/u16/*.java | $G -q 'Thread\.sleep' && die "R.412: a Thread.sleep in the harness"
UH=$(md5 -q ../c9-unit15/harness/src/probe/u15/U15Hal.java); [ "${UH:0:8}" = c1ac7e25 ] || die "unit 15's U15Hal.java is not c1ac7e25 (its md5 $UH)"
OP=$(md5 -q "$BK3/instruments/ops9s3.py"); [ "$OP" = 8f062a0e5e872c478579756a8426c012 ] || die "BLUE's ops9s3.py is not 8f062a0e"
[ "$(md5 -q harness/ops9s3.py)" = "$OP" ] || die "harness/ops9s3.py is not BLUE's instrument, byte for byte"
echo "  U16Hal.java against unit 15's U15Hal.java (md5 $UH): the named diff md5 $(diff ../c9-unit15/harness/src/probe/u15/U15Hal.java harness/src/probe/u16/U16Hal.java | md5 -q), $(diff ../c9-unit15/harness/src/probe/u15/U15Hal.java harness/src/probe/u16/U16Hal.java | $G -c '^[<>]') lines (the package, the class, the routes under /probe/u16/, OrderResources tried by methodOn, the twenty orders as one collection; U15's customer routes left out)"
echo "  U16Config.java against unit 15's U15Config.java (md5 $(md5 -q ../c9-unit15/harness/src/probe/u15/U15Config.java)): the named diff md5 $(diff ../c9-unit15/harness/src/probe/u15/U15Config.java harness/src/probe/u16/U16Config.java | md5 -q) · U16Next.java md5 $(md5 -q harness/src/probe/u16/U16Next.java) (new: the probe has no page route)"
echo "  ops9s3.py = BLUE's (md5 $OP, byte for byte; it refuses an empty spec) · the probe's ProbeHal.java md5 $(md5 -q "$PK3/instruments/probe-src/ProbeHal.java") (read for its shapes, not copied)"
[ "$(sed -n '5,$p' harness/tree16.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit15/harness/tree15.py | md5 -q)" ] || die "harness/tree16.py's code is not tree15.py's"
for u in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15; do [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit$u/harness/dur9.py)" ] || die "harness/dur9.py is not ../c9-unit$u's copy"; done
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"
  [ ! -f "$C9R/_builders/dur9.py" ] || [ "$(md5 -q "$C9R/_builders/dur9.py")" = "$D9" ] || die "harness/dur9.py is not C9/_builders/dur9.py"
  TT=$(python3 -I -c '
import re,sys; t=open(sys.argv[1]).read().split("TITLES",1)[1]
for k in ("07","09","10","12","13","14","15","16"):
    m=re.search(r"\"%s\": *\"([^\"]+)\"" % k, t); print("%s=%s" % (k, m.group(1) if m else ""))' "$J9" | paste -sd'|' -)
  [ "$TT" = '07=OpenAPI: The Contract|09=Documenting Errors, Examples and Security|10=Code Generation From the Contract|12=Versioning Strategies|13=Pagination, Filtering and Sorting as an API Concern|14=Sparse Fieldsets and Compression|15=HATEOAS: The Argument|16=Spring HATEOAS in Practice' ] || die "java9_series.TITLES differ from the call-backs (C11: the live title wins - a finding): $TT"
  echo "  the titles, read off the registry (the call-backs, by title only, R.224): $TT"
else D9N="(the registry is not on this machine: U01-U15's copies are the pin)"; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit01-15's copies $D9N · tree16.py's code = tree15.py's"
XS1=$(sed -n '/^# --- XFAM_S9S1 begin ---$/,/^# --- XFAM_S9S1 end ---$/p' harness/s916.py | md5 -q); XS1U=$(sed -n '/^# --- XFAM_S9S1 begin ---$/,/^# --- XFAM_S9S1 end ---$/p' ../c9-unit15/harness/s915.py | md5 -q)
[ "$XS1" = "$XS1U" ] || die "s916.py's XFAM_S9S1 slice is not U15's s915.py's"
echo "  s916.py: XFAM_S9S1's slice md5 $XS1 = ../c9-unit15/harness/s915.py's · its XU16 family this unit's · lines outside XU16 = s915.py's but for the names: $(diff <(sed '/^XU15 = {/,/^u04 = u15$/d' ../c9-unit15/harness/s915.py | sed 1d) <(sed '/^XU16 = {/,/^u04 = u16$/d' harness/s916.py | sed 1d) | $G -c '^[<>]') lines differ"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit14/receipts.md5)
[ -n "$UA" ] || die "../c9-unit14/receipts.md5 has no after-tree line"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree16.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || { [ -n "${NOPIN:-}" ] && { echo "  $dir/: $got (NOPIN: no pin yet)"; return 0; }; die "receipts.md5 has no $nm line"; }
  [ "$nm" = after-tree ] || [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit14/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree16.py $dir/ -> $got = receipts.md5's $nm line$( [ "$nm" = before-tree ] && echo " = ../c9-unit14/receipts.md5's after-tree line")"; }
pin before-tree before; pin after-tree after
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true)
echo "  after/ against ../c9-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures its own frozen after/' )"
HF="harness/chk16.py harness/s916.py harness/tree16.py harness/dur9.py harness/ops9s3.py $(for f in $HSRC; do printf 'harness/src/%s ' $f; done)exercise/check.sh exercise/apply.sh exercise/break.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's scripts: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
ST=$(python3 -I -B harness/chk16.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
echo "  static (harness/chk16.py static after before): $(printf '%s\n' "$ST" | $G -c '^ok ') checks, FAIL 0"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s916.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U16 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s916, per sentence): /'
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b|<measure>' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
GL=$(python3 -I -B harness/chk16.py gloss README.md) || die "the gloss: $(printf '%s\n' "$GL" | $G '^FAIL' | head -3 | paste -sd';' -)"
echo "  the gloss: $(printf '%s\n' "$GL" | $G -c '^ok ') checks, FAIL 0 ($(python3 -I -B harness/chk16.py gloss-line))"
HOOK=$(python3 -I -B harness/chk16.py hook); EXQ=$(python3 -I -B harness/chk16.py exq); GLS=$(python3 -I -B harness/chk16.py gloss-line)
IL=$(python3 -I -B harness/chk16.py interleaved) || die "the brief's interleaved hooks and exercises: $IL"
echo "  $IL"
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S3B's Unit 16 Hook line), byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
HW=$(printf '%s\n' "$HOOK" | wc -w | tr -d ' '); EW=$(printf '%s\n' "${EXQ#Your turn: }" | wc -w | tr -d ' ')
[ "$HW" -le 25 ] && [ "$EW" -le 25 ] || die "a spoken line over 25 words (hook $HW, exercise $EW)"
echo "  the hook ($HW words) and the exercise's line ($EW words after 'Your turn:') byte for byte, extracted from S3B's Unit 16 (md5 $(md5 -q "$C9R/_briefs/UNIT-BRIEFS-S3-PAYLOADS.md"))"
printf '%s\n\n%s\n\n%s\n' "$HOOK" "$EXQ" "$GLS" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s916.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
SWR=$(printf '%s\n' "$SW" | $G ' line ' | sed 's#.*spoken.md ##' | sort -u | paste -sd';' -)
echo "  the hook, the exercise's line and the gloss through s916.py: $(printf '%s\n' "$SW" | tail -1 | sed 's/.* refused: /refused /')$( [ -n "$SWR" ] && echo " - $SWR (the brief's hook names Spring HATEOAS bare: the spoken form is the scripts' call, BUILDERS 5; handed to RED)")"; rm -f .r-lock/spoken.md
TS="Spring HATEOAS: EntityModel, WebMvcLinkBuilder and HAL"
$G -qF "$TS" "$C9R/_briefs/UNIT-BRIEFS-S3-PAYLOADS.md" || die "the title for search is not S3B's"
TL=$(python3 -I -c 'import sys; print(len(sys.argv[1]))' "$TS"); [ "$TL" -le 60 ] || die "the title for search is over 60 characters"
echo "  the title for search: \"$TS\" ($TL characters by len(), <= 60; printed, not edited)"
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
! $G -qE '(^|[^A-Za-z0-9_.-])path=|[$][{]?path([^A-Za-z0-9_]|$)' exercise/check.sh exercise/apply.sh exercise/break.sh || die "an exercise script names a variable path (zsh): rpath"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh exercise/check.sh exercise/apply.sh exercise/break.sh | $G -qwE "$K1|$K2" || die "a script names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket"
RMF=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) rm( +-[a-z]+)*' | sort -u | paste -sd'|' -)
[ -z "$RMF" ] || [ "$RMF" = 'dk rm -fv' ] || die "R.387: receipts.sh removes a container without its volumes (found: $RMF)"
MVL=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -F '$MV ')
MVA=$(printf '%s\n' "$MVL" | $G -vF -- '-pl tiffinbox-web -am' | $G -vF -- '-pl tiffinbox-client -am' | $G -cF -- '-pl ' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh with a -pl form other than '-pl tiffinbox-web -am' or '-pl tiffinbox-client -am'"
KW='idempotency''-key'; KH=$($G -v '^ *#' receipts.sh exercise/check.sh exercise/apply.sh exercise/break.sh | $G -ciF "$KW" || true)
[ "$KH" = 0 ] || die "S9.21: a line of receipts.sh or the exercise names the key header"
echo "  static: no kill by name; every docker call on the pinned socket, every removal rm -fv; R.391's Maven forms only; no Thread.sleep in the harness; the key header named by no line"
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
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'took 812 ms' '"timestamp":"2026-11-01T08:09:00.123Z"' "$U/x $HOME/y" '[INFO] TiffinBox Web ...... SUCCESS [ 11.955 s]' | mask)
[ "$(printf '%s\n' "$MP" | paste -sd'|' -)" = 'Started TiffinBoxServer in <t> (process running for <t>)|took <t>|"timestamp":"<time>"|…/x ~/y|[INFO] TiffinBox Web ...... SUCCESS [<t>]' ] || die "the mask's self-test: $(printf '%s\n' "$MP" | paste -sd'|' -)"
# the cursor mask: a signed cursor (base64url payload '.' base64url HMAC) keeps its first 12 characters and its length
cmask() { sed -E 's/(cursor=|"next":")([A-Za-z0-9_-]{12})[A-Za-z0-9_.-]*/\1\2<cursor>/g'; }
CM=$(printf '%s\n' '"next":"eyJzIjoibmV3ZXN0IiwiZiI6bnVsbC.aFlgkpSMCNZ"' 'cursor=eyJzIjoibmV3ZXN0Iiwi.abc{&mealType,size}' | cmask | paste -sd'|' -)
[ "$CM" = '"next":"eyJzIjoibmV3<cursor>"|cursor=eyJzIjoibmV3<cursor>{&mealType,size}' ] || die "the cursor mask's self-test: $CM"
echo "  masks: the log mask masked a Started line's times, a millisecond count, a timestamp, the folders, the home and a reactor line's time; the cursor mask kept a cursor's first 12 characters (self-tests)"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh); [ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SURF=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh); [ ${#U4SURF} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh (SURF=)"
U15V=$(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit15/README.md | $G -E '^(seven|surface): ' | $G -oE '(seven|surface)=[0-9a-f]{8}' | paste -sd' ' -)
[ "$U15V" = "seven=$(echo $S466 | cut -c1-8) surface=$(echo $U4SURF | cut -c1-8)" ] || die "U15's README values block ($U15V) is not the seven and the surface read off the receipts"
echo "  the seven: expected $S466 (../c7-unit31/receipts.sh's S466= line) · the old surface: expected $U4SURF (../c9-unit04/receipts.sh's SURF= line) · both = U15's values block ($U15V)"
echo "  the probe's HATEOAS captures (PK3/captures/h35/, read, not copied: the expectation on the probe's routes, 1 run): $(ls "$PK3/captures/h35" | wc -l | tr -d ' ') files, their md5 list $(cd "$PK3/captures/h35" && for f in $(ls | sort); do printf '%s %s\n' "$(md5 -q "$f")" "$f"; done | md5 -q) · BLUE's captures: $(ls "$BK3/captures" | wc -l | tr -d ' ') files"

# ---- docker, ports, the guard: the baselines ----------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run"
[ -z "$(dk ps -aq --filter name=^/c9u16- 2> /dev/null)" ] || die "a c9u16-* container exists before the run"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
BAND="21050 21051 21052 21053 21054 21055 21056 21057 21058 21059"
PORTS="18425 18881 18882 18883 18884 20578 20615 $BAND 21280 21281 21282 21283 21284"
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
  for p in $BAND; do case " ${MINE:-} " in *" $p "*) continue ;; esac; [ "$(listeners $p)" = 0 ] || die "guard before $1: something listens on $p that this run did not start"; done
  echo "  guard before $1: no other receipt · load1 $l1 (< 20)$( [ $w = 0 ] || echo " after $w checks at or above 20 (waited, never killed)") · the band free" >&3; }
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · nothing pulled · no Testcontainers or c9u16-* container · ports $PORTS free"

# ---- the trees, copied and built offline: before (through the link), after/; the harness, compiled -------------------------------------
M2="$PWD/.m2-demo"
if [ ! -d "$M2" ]; then [ -d "$SEED" ] || die "the seed $SEED is missing"; cp -cR "$SEED" "$M2" 2> /dev/null || cp -R "$SEED" "$M2" || die "the seed could not be copied"; fi
NF0=$(find "$M2" -type f | wc -l | tr -d ' '); NB0=$(find "$M2" -type f -print0 | xargs -0 stat -f %z | awk '{ s += $1 } END { printf "%d", s }')
CO=$(find "$M2" -name _remote.repositories -print0 | xargs -0 $G -l 'central-only' 2> /dev/null | wc -l | tr -d ' ')
[ "$CO" = 0 ] || die "$CO _remote.repositories files in the seed copy still name central-only"
ART="org/springframework/boot/spring-boot-starter-parent/4.1.3 org/springframework/hateoas/spring-hateoas/3.1.4 org/springframework/boot/spring-boot-starter-hateoas/4.1.3 tools/jackson/core/jackson-databind/3.1.8"
for a in $ART; do [ -n "$(ls "$M2/$a" 2> /dev/null | $G -E '\.(jar|pom)$')" ] || die ".m2-demo holds no $a (no seed act here: report the coordinates)"; done
echo "  .m2-demo (a copy of the seed m2-seed-c9-s3): files $NF0 · bytes $NB0 · _remote.repositories naming central-only: $CO"
for a in $ART; do echo "  seed | $a | $(ls "$M2/$a" | $G -E '\.(jar|pom)$' | paste -sd' ' -)"; done
mkdir -p .harness; for d in before after pkg tests webonly exercise run work hc client-before; do rm -rf .harness/$d; done
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
echo "  built after/ offline WITH its tests, Docker-free (mvn -o clean package, the whole reactor: $($G -E '^\[INFO\] TiffinBox[A-Za-z ]* \.+ SUCCESS' .harness/build-after.log | sed -E 's/^\[INFO\] (TiffinBox[A-Za-z ]*) \.+ SUCCESS.*/\1/' | paste -sd, -); exit 0) - the jars come from this build; it is the tests capture's Docker-free twin"
extract before; extract after
CPA=".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \"$CPA\" harness/src/probe/u16/*.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/'s jar: $(head -5 .harness/javac.log)"
echo "  the harness compiled against after/'s web jar ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes, -parameters) - never in either jar"
B() { echo "http://127.0.0.1:$1"; }
J=.harness/work
ALP='%m %U%q %s %b "%{Accept}i" "%{Content-Type}o" "%{Accept-Encoding}i" "%{Content-Encoding}o"'
# tb LABEL PORT FLAG HARNESS [args]: TiffinBox (the extracted jar of TREE=after unless TREE is set), from its own run folder with a
# generated token (0600, never printed), H2 in memory (fresh per JVM), waited for by its Started line. FLAG: on = the run flag
# --server.compression.enabled=true on the command line, off = none. HARNESS: 1 joins probe.u16.U16Config. ACC=1: Tomcat's access log.
tb() { local label=$1 port=$2 flag=$3 hx=$4 t=${TREE:-after} run=.harness/run/$1 src="" i=0; shift 4
  guard "TiffinBox $label"
  for q in 21051 21052 21053 21057 21059; do [ "$(listeners $q)" = 0 ] && [ -z "$(lsof -nP -iUDP:$q 2> /dev/null)" ] || die "$q must stay free (TCP and UDP)"; done
  [ "$(listeners $port)" = 0 ] && [ -z "$(lsof -nP -iUDP:$port 2> /dev/null)" ] || die "$port is bound before $label"
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  local x="$U/.harness/$t/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  local fx=(); [ "$flag" = on ] && fx=(--server.compression.enabled=true)
  local ax=(); [ -n "${ACC:-}" ] && ax=(--server.tomcat.accesslog.enabled=true "--server.tomcat.accesslog.directory=$U/$run" --server.tomcat.accesslog.prefix=access --server.tomcat.accesslog.suffix=.log --server.tomcat.accesslog.rotate=false --server.tomcat.accesslog.buffered=false "--server.tomcat.accesslog.pattern=$ALP")
  if [ -n "$hx" ]; then cp="$cp:$U/.harness/hc"; src="--spring.main.sources=probe.u16.U16Config"; fi
  echo "java -cp <tree $t> com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=$port $src ${fx[*]:-} $( [ -n "${ACC:-}" ] && echo '<the access log>') $*" > "$run/cmd"
  (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -cp "$cp" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port="$port" $src "${fx[@]}" "${ax[@]}" "$@" > jvm.log 2>&1) &
  local p=$!; echo $p > "$run/pid"; PIDS="$PIDS $p"; MINE="${MINE:-} $port"
  while ! $G -q -E 'Started TiffinBox(App|Server) in' "$run/jvm.log" 2> /dev/null; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before its Started line"; }; i=$((i + 1)); [ $i -lt 900 ] || die "$label: no Started line"; sleep 0.1; done
  if [ -n "$hx" ]; then i=0; while ! $G -q '^U16 harness: joined' "$run/jvm.log"; do i=$((i + 1)); [ $i -lt 100 ] || die "$label: no U16 harness line"; sleep 0.05; done; fi
  local dup; dup=$(tr ' ' '\n' < "$run/cmd" | $G -E '^--' | sed 's/=.*//' | sort | uniq -d | paste -sd, -); [ -z "$dup" ] || die "R.444: a flag twice on $label's command line ($dup)"
  echo "  $label up on $port (H2, tree $t, flag=$flag$( [ -n "$hx" ] && echo ", the harness joined (its U16 harness line printed)" || echo ", no harness")$( [ -n "${ACC:-}" ] && echo ", the access log on")) · $(sed 's/ *$//' "$run/cmd")"; }
tbstop() { local label=$1 port=$2 run=.harness/run/$1 p i=0 how="POST /shutdown"; p=$(cat "$run/pid")
  if kill -0 "$p" 2> /dev/null; then printf 'X-Shutdown-Token: %s\n' "$(head -1 "$run/secrets/tiffinbox/shutdown-token")" | $CURL -s -o /dev/null --max-time 5 -H @- -X POST "$(B $port)/shutdown" || true; fi
  while kill -0 "$p" 2> /dev/null; do i=$((i + 1)); [ $i = 80 ] && { kill "$p" 2> /dev/null; how="its recorded pid (SIGTERM)"; }; [ $i -lt 400 ] || { kill -9 "$p" 2> /dev/null; break; }; sleep 0.05; done
  wait "$p" 2> /dev/null || true; PIDS=$(echo " $PIDS " | sed "s/ $p / /g"); MINE=$(echo " ${MINE:-} " | sed "s/ $port / /g")
  [ "$(listeners $port)" = 0 ] || die "$label: something still listens on $port"
  [ -z "${QUIET:-}" ] && echo "  $label stopped by $how"; true; }
NCAPS=0; unpub=""; VALS=""
cap() { local nm=$1; shift
  if [ -n "${DEVCAPS:-}" ] && ! echo " $DEVCAPS " | $G -qF " $nm "; then return 0; fi   # development only: a run of record sets no DEVCAPS
  "$@" > .harness/cap-$nm.raw 2>&1 || true
  $G -q '^  \*\*\* ' .harness/cap-$nm.raw && { cat .harness/cap-$nm.raw >&3; die "$nm stopped (above)"; }
  mask < .harness/cap-$nm.raw | cmask > .r-$nm.new
  sed 's/^/  | /' .r-$nm.new | cut -c1-260
  local o e=0; o=$(python3 -I -B harness/chk16.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk16 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; [ -n "${DEVCAPS:-}${NOPIN:-}" ] && { echo "  (development: $nm's check failed, the run goes on)"; unpub="$unpub $nm"; } || die "$nm: its check failed (harness/chk16.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk16.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-11s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-11s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff .r-$nm.new against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }
ck() { python3 -I -B harness/chk16.py "$@"; }
OR=/api/v1/orders
# one LABEL PORT PATH [curl args]: one GET; prints status, type, curl's size, the saved file's bytes and md5, Content-Length,
# Content-Encoding, Transfer-Encoding and Vary (none when absent), and the members when the body is JSON
hv() { local v; v=$(tr -d '\r' < $J/o.h | $G -i "^$1:" | head -1 | sed -E "s/^[^:]*: *//"); echo "${v:-none}"; }
one() { local lab=$1 port=$2 p=$3 w; shift 3; : > $J/o.h; : > $J/o.b
  w=$($CURL --http1.1 -sS -D $J/o.h -o $J/o.b -w '%{http_code} %{content_type} %{size_download}' --max-time 10 "$@" "$(B $port)$p")
  echo "  $lab | GET $p$( [ -n "${ACCEPT:-}" ] && echo " [Accept: $ACCEPT]") -> $w · file $(wc -c < $J/o.b | tr -d ' ') B md5 $(sed -E 's/"timestamp":"[^"]*"/"timestamp":"<masked>"/; s/"next":"[^"]*"/"next":"<cursor>"/' $J/o.b | md5 -q) · Content-Length $(hv Content-Length) · Content-Encoding $(hv Content-Encoding) · Transfer-Encoding $(hv Transfer-Encoding) · Vary $(hv Vary)$(python3 -I -c '
import json,sys
try:
    d=json.load(open(sys.argv[1],encoding="utf-8"))
    if isinstance(d,list): print(" · a list of %d · members %s" % (len(d), list(d[0]) if d else []))
    else: print(" · members %s%s" % (list(d), "" if "_links" not in d else " · links %s" % ["%s=%s" % (k, v.get("href")) for k, v in d["_links"].items()]))
except Exception: print("")' $J/o.b)"; }
# ask LABEL PORT ACCEPT PATH: one GET with that Accept (none = no Accept header at all)
ask() { local lab=$1 port=$2 a=$3 p=$4; if [ "$a" = none ]; then ACCEPT=none one "$lab" "$port" "$p" -H 'Accept:'; else ACCEPT="$a" one "$lab" "$port" "$p" -H "Accept: $a"; fi; }
# prq LABEL PATH: a refused (or not) request to 21050; its members read by python
prq() { local lab=$1 q=$2 w
  w=$($CURL --http1.1 -sS -o $J/pr.b -w '%{http_code} %{content_type}' --max-time 10 "$(B 21050)$q")
  echo "  refuse | $lab ($q) -> $w | $(python3 -I -c '
import json,sys
try:
    d=json.load(open(sys.argv[1],encoding="utf-8"))
    if "timestamp" in d: d["timestamp"]="<masked>"
    print(" · ".join("%s=%s" % (k, d[k]) for k in ("type","title","detail","instance","status","error","path") if k in d) + (" · type absent (no type of TiffinBox'"'"'s)" if "type" not in d else "") if "_links" not in d else "HAL, members %s" % list(d))
except Exception as e: print("not JSON")' $J/pr.b)"; }
acclog() { cat .harness/run/$1/access*.log 2> /dev/null | sed -E 's/^([A-Z]+ [^ ]*)- /\1 /; s/ +$//'; }   # %q prints - for no query: dropped

# ---- the captures ----------------------------------------------------------------------------------------------------------------------
c_advisory() {
  echo "== S9.36: the read filed for the batch day (ADV3; not re-read: no network), before any capture"
  echo "  fetched-at $(head -1 "$ADV/fetched-at.txt" | cut -c1-10) (the hour masked) · run date $(date '+%Y-%m-%d')"
  sed -n '2,$p' "$ADV/fetched-at.txt" | sed 's/^/  fetched | /'
  local n=0 v=0 f h; while read -r h f; do n=$((n + 1)); [ "$(md5 -q "$ADV/$f" 2> /dev/null)" = "$h" ] && v=$((v + 1)); done < <($G -vE '^\s*$' "$ADV/MD5SUMS.txt" | awk '$2 != "MD5SUMS.txt" { print $1, $2 }')
  echo "  MD5SUMS.txt: $n lines, $v verified (its own line left out)"
  echo "  spring rows $($G -c . "$ADV/spring-index-rows-2026-11-24.txt") · naming Spring Framework $($G -c 'Spring Framework' "$ADV/spring-index-rows-2026-11-24.txt" || true) · naming HATEOAS $($G -ci 'hateoas' "$ADV/spring-index-rows-2026-11-24.txt" || true)"
  echo "  tomcat page md5 $(md5 -q "$ADV/tomcat-security-11.html")"
  local a; for a in org.springframework.hateoas:spring-hateoas org.springframework.boot:spring-boot-starter-hateoas org.springframework.boot:spring-boot-hateoas com.jayway.jsonpath:json-path net.minidev:json-smart net.minidev:accessors-smart org.ow2.asm:asm org.apache.tomcat.embed:tomcat-embed-core tools.jackson.core:jackson-databind org.springframework:spring-web org.springframework.data:spring-data-jpa org.hibernate.orm:hibernate-core org.postgresql:postgresql com.h2database:h2; do
    echo "  t3 tree | $a $($G -E "^$(echo $a | sed 's/\./\\./g'):jar:" "$ADV/probe-tree-t3-dependency-list.txt" | head -1 | awk -F: '{ print $4 }')"; done
  echo "  osv (second witness only, S2.8): $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); r=d.get("results",[]); print("%d results, %d with vulns" % (len(r), sum(1 for x in r if x.get("vulns"))))' "$ADV/osv-result.json")"
  echo "  verdict: no pin affected; evidence may proceed"; }
mappings() { $CURL -s "$(B $1)/actuator/mappings" | python3 -I -c '
import json,sys
d=json.load(sys.stdin); ps=[]
for c in d["contexts"].values():
    for m in c["mappings"]["dispatcherServlets"]["dispatcherServlet"]:
        rc=(m.get("details") or {}).get("requestMappingConditions")
        if rc: ps += [p for p in rc.get("patterns", [])]
print("  %s | mappings %d · with orders in the path %d: %s (rule: the request-mapping patterns of the dispatcher servlet)" % (sys.argv[1], len(ps), sum(1 for p in ps if "orders" in p), sorted(p for p in ps if "orders" in p)))' "$2"; }
c_before() {
  echo "== before (21056, U14's after, H2, no harness, flag=off; the harness's exposure flag for /actuator/mappings)"
  TREE=before tb before 21056 off "" --management.endpoints.web.exposure.include=health,prometheus,mappings
  one before 21056 $OR/1; one before 21056 $OR; one before 21056 /api/v1/customers/Ravi; one before 21056 /customers; one before 21056 /api/v1/customers
  mappings 21056 before
  echo "  before | the committed spec: $(python3 -I harness/ops9s3.py ops before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tail -1) · $(wc -c < before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tr -d ' ') B md5 $(md5 -q before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json)"
  echo "  before | BOOT-INF/lib names $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · naming hateoas $(ls .harness/before/$XD/lib | $G -ci hateoas || true)"
  local V6=before/tiffinbox-core/src/main/resources/db/migration/V6__tiffin_order.sql
  echo "  before | V6's orders: $($G -c '^INSERT INTO tiffin_order' $V6) rows · by customer $($G -oE "^INSERT INTO tiffin_order .* VALUES \('[A-Za-z]+'" $V6 | sed -E "s/.*\('//; s/'$//" | sort | uniq -c | awk '{ print $2 "=" $1 }' | paste -sd' ' -) · the first row $($G -m1 '^INSERT INTO tiffin_order' $V6 | sed 's/.* VALUES //')"
  tbstop before 21056; }
census() { python3 -I - "$1/tiffinbox-web/src/main/java/com/tiffinbox/web" "$2" <<'PY'
import os, re, sys
d, side = sys.argv[1], sys.argv[2]
print("  census %s | rule (unit 15's, copied): a class whose annotation lines (the lines between the Javadoc's end and its declaration) include exactly @RestController or @Controller; its final modifier; @Profile(\"dev\") among those lines" % side)
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
for r in rows:
    print("  census %s | %-16s final %-3s dev-only %-3s %s:%d" % (side, r[0], "yes" if r[1] else "no", "yes" if r[2] else "no", r[3], r[4]))
for e in excl:
    print("  census %s | excluded by the rule: %s (%s:%d) - annotated @RestControllerAdvice, not a controller the link builder proxies" % ((side,) + e))
fd = sum(1 for r in rows if r[1] and not r[2]); nd = sum(1 for r in rows if not r[1] and r[2]); nf = sum(1 for r in rows if not r[1] and not r[2])
print("  census %s | controllers %d · final, default-run %d · not final, default-run %d · not final, dev-only %d · other %d" % (side, len(rows), fd, nf, nd, len(rows) - fd - nd - nf))
PY
}
c_change() {
  echo "== the modules, the change file by file"
  echo "  modules: $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' before/pom.xml | paste -sd' ' -) ($($G -c '<module>' before/pom.xml)) -> $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' after/pom.xml | paste -sd' ' -) ($($G -c '<module>' after/pom.xml))"
  local pm; pm=$(for p in pom.xml tiffinbox-core/pom.xml tiffinbox-web/pom.xml tiffinbox-client/pom.xml; do cmp -s before/$p after/$p || echo $p; done | paste -sd' ' -)
  echo "  poms before -> after/: ${pm:-equal}"
  echo "  changed (derived: diff -rq before after/, the frozen trees - git status --short c9-tiffinbox gave the same list before the commit): $(diff -rq before/ after/ | sed -E 's#^Files before/(.*) and after/.* differ$#M \1#; s#^Only in after/(.*): (.*)$#A \1/\2#; s#^Only in after/: (.*)$#A \1#; s#^Only in before/(.*): (.*)$#D \1/\2#' | sort | paste -sd'~' - | sed 's/~/ · /g')"
  local f; for f in tiffinbox-web/src/main/java/com/tiffinbox/web/OrderResources.java tiffinbox-web/src/test/java/com/tiffinbox/web/OrderResourcesTest.java; do
    echo "== $f (whole, md5 $(md5 -q after/$f))"; sed 's/^/    /' after/$f; done
  echo "== the core diff (OrderEntityRepository.java) and the web pom's diff"
  diff before/tiffinbox-core/src/main/java/com/tiffinbox/OrderEntityRepository.java after/tiffinbox-core/src/main/java/com/tiffinbox/OrderEntityRepository.java | sed 's/^/  core | /'
  diff before/tiffinbox-web/pom.xml after/tiffinbox-web/pom.xml | sed 's/^/  pom | /'
  echo "  the order's record components (OrderPages.OrderView): $($G -oE 'record OrderView\([^)]*\)' after/tiffinbox-web/src/main/java/com/tiffinbox/web/OrderPages.java)"
  for k in JsonView MappingJacksonValue Pageable 'offset(' Probe /probe/ 'methodOn(CustomerReads' 'methodOn(OrderPages'; do echo "  src/main grep $k: $(cd after && $G -rhF "$k" tiffinbox-web/src/main tiffinbox-core/src/main | $G -vcE '^[[:space:]]*(\*|//|/\*)' || true) code lines"; done
  echo "  OrderResources final: $($G -cE '^final class OrderResources|^public final class OrderResources' after/tiffinbox-web/src/main/java/com/tiffinbox/web/OrderResources.java || true) · its declaration: $($G -E '^(public )?(final )?class OrderResources' after/tiffinbox-web/src/main/java/com/tiffinbox/web/OrderResources.java)"
  for f in OrderPages CustomerReads CustomerFields; do echo "  $f: $($G -E "^(public )?(final )?class $f" after/tiffinbox-web/src/main/java/com/tiffinbox/web/$f.java) · byte-equal to before's: $(cmp -s before/tiffinbox-web/src/main/java/com/tiffinbox/web/$f.java after/tiffinbox-web/src/main/java/com/tiffinbox/web/$f.java && echo yes || echo no)"; done
  for k in compression forward-headers 'hateoas'; do echo "  application.yaml $k keys: before $($G -c "$k" before/tiffinbox-web/src/main/resources/application.yaml || true) · after $($G -c "$k" after/tiffinbox-web/src/main/resources/application.yaml || true)"; done
  echo "  handler orderResource: $(cd after && $G -rhE -A3 '@(Get|Post|Put|Patch|Delete|Request)Mapping' tiffinbox-web/src/main/java | $G -cE ' orderResource\(') occurrence(s) among the mapped handlers"
  echo "  ProblemDetail.forStatus calls in src/main (unit 03's instance view greps them): before $(cd before && $G -rc 'ProblemDetail\.forStatus' tiffinbox-web/src/main | awk -F: '{ s += $2 } END { print s }') · after $(cd after && $G -rc 'ProblemDetail\.forStatus' tiffinbox-web/src/main | awk -F: '{ s += $2 } END { print s }')"; }
c_starter() {
  echo "== starter: the web pom's edit, the lib name lists of the two built jars, the jars per entry"
  diff before/tiffinbox-web/pom.xml after/tiffinbox-web/pom.xml | sed 's/^/  edit | /'
  echo "  edit | the diff's md5 $(diff before/tiffinbox-web/pom.xml after/tiffinbox-web/pom.xml | md5 -q) · lines added $(diff before/tiffinbox-web/pom.xml after/tiffinbox-web/pom.xml | $G -c '^>') removed $(diff before/tiffinbox-web/pom.xml after/tiffinbox-web/pom.xml | $G -c '^<' || true) · a <version> on the starter: $(python3 -I -c 'import re,sys; s=open(sys.argv[1]).read(); m=re.search(r"<dependency>\s*<groupId>org.springframework.boot</groupId>\s*<artifactId>spring-boot-starter-hateoas</artifactId>(.*?)</dependency>", s, re.S); print("absent" if m and "<version>" not in m.group(1) else "PRESENT")' after/tiffinbox-web/pom.xml)"
  local bom; bom=$(ls "$M2/org/springframework/boot/spring-boot-dependencies/4.1.3/"*.pom)
  echo "  bom | spring-boot-dependencies-4.1.3.pom: $($G -E '<spring-hateoas\.version>' "$bom" | sed 's/^ *//')"
  echo "  lib | before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') names · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ') names"
  diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -E '^[<>]' | sed 's/^>/  lib | added/; s/^</  lib | removed/'
  echo "  lib | the coordinates the shipped lib now names (S9.36's read): $(ls .harness/after/$XD/lib | $G -E '^(spring-hateoas|spring-boot-hateoas|spring-plugin-core|json-path|json-smart|accessors-smart|asm|tomcat-embed-core|jackson-databind|spring-web|spring-data-jpa|spring-data-commons|hibernate-core|postgresql|h2)-[0-9]' | sed 's/\.jar$//' | paste -sd' ' -)"
  python3 -I - .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar <<'PY'
import sys, zipfile
a = {i.filename: i.CRC for i in zipfile.ZipFile(sys.argv[1]).infolist()}; b = {i.filename: i.CRC for i in zipfile.ZipFile(sys.argv[2]).infolist()}
only_b = sorted(n for n in b if n not in a); only_a = sorted(n for n in a if n not in b)
crc = sorted(n for n in a if n in b and a[n] != b[n] and not n.endswith("/"))
print("  jar | entries: before %d · after %d · only after: %d (in BOOT-INF/lib/ %d) · only before %d" % (len(a), len(b), len(only_b), sum(1 for n in only_b if n.startswith("BOOT-INF/lib/")), len(only_a)))
print("  jar | only after, outside BOOT-INF/lib/: %s" % (", ".join(n for n in only_b if not n.startswith("BOOT-INF/lib/")) or "none"))
print("  jar | shared entries whose CRC differs: %s" % (", ".join(crc) or "none"))
PY
  python3 -I - .harness/before/tiffinbox-core/target/tiffinbox-core-1.0.0.jar .harness/after/tiffinbox-core/target/tiffinbox-core-1.0.0.jar <<'PY'
import sys, zipfile
a = {i.filename: i.CRC for i in zipfile.ZipFile(sys.argv[1]).infolist()}; b = {i.filename: i.CRC for i in zipfile.ZipFile(sys.argv[2]).infolist()}
crc = sorted(n for n in a if n in b and a[n] != b[n] and not n.endswith("/"))
print("  core jar | entries before %d · after %d · only after %s · only before %s · CRC differs: %s" % (len(a), len(b), sorted(set(b) - set(a)) or "none", sorted(set(a) - set(b)) or "none", ", ".join(crc) or "none"))
PY
}
c_jackson() {
  echo "== jackson: Spring HATEOAS's HAL writer and the Jackson its bytes name (unit 15's rule, copied), after/'s lib"
  python3 -I - ".harness/after/$XD/lib" <<'PY'
import os, re, sys, zipfile
L = sys.argv[1]
j = [f for f in os.listdir(L) if f.startswith("spring-hateoas-")]
z = zipfile.ZipFile(os.path.join(L, j[0]))
mf = z.read("META-INF/MANIFEST.MF").decode()
print("  jackson | %s MANIFEST Implementation-Version %s" % (j[0], re.search(r"Implementation-Version: (\S+)", mf).group(1)))
pre = "org/springframework/hateoas/mediatype/hal/"
cls = [n for n in z.namelist() if n.startswith(pre) and n.endswith(".class") and "/" not in n[len(pre):]]
t3 = sum(1 for n in cls if b"tools/jackson/databind" in z.read(n)); t2 = sum(1 for n in cls if b"com/fasterxml/jackson/databind" in z.read(n))
print("  jackson | rule: the .class entries directly in %s; a class references a Jackson when its bytes hold the package's internal name" % pre)
print("  jackson | HAL classes %d · referencing tools/jackson/databind %d · referencing com/fasterxml/jackson/databind %d" % (len(cls), t3, t2))
print("  jackson | jackson-databind in lib/: %s" % " ".join(sorted(f for f in os.listdir(L) if f.startswith("jackson-databind"))))
PY
  echo "  jackson | the app's JsonMapper: OrderPages imports $($G -oE '^import tools\.jackson\.databind\.json\.JsonMapper' after/tiffinbox-web/src/main/java/com/tiffinbox/web/OrderPages.java | sed 's/^import //')"; }
c_hal() {
  echo "== hal: the order as HAL on the wire (after/, 21050, H2, no harness, flag=off, strategy=default, the access log on); host 127.0.0.1:<port>"
  local i; for i in 1 20; do ask hal 21050 application/hal+json $OR/$i; cp $J/o.b $J/hal-$i.b; done
  echo "  hal | order 1's body: $(cat $J/hal-1.b)"
  echo "  hal | curl's size, the file's bytes and Content-Length agree for order 1: $(python3 -I -c 'import os,sys; print(os.path.getsize(sys.argv[1]))' $J/hal-1.b)"
  echo "  hal | the same order without _links (python: the body less its _links member, Jackson's compact form): $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); d.pop("_links"); print(len(json.dumps(d,separators=(",",":")).encode()))' $J/hal-1.b) B (a control computed from the wire bytes, not a request: the route has no form without links)"
  local cu; cu=$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1]))["_links"]["customer"]["href"])' $J/hal-1.b)
  echo "  hal | following customer: GET $(echo "$cu" | sed -E 's#127\.0\.0\.1:[0-9]+#127.0.0.1:<port>#') -> $($CURL --http1.1 -sS -o $J/f.b -w '%{http_code} %{content_type} %{size_download}' "$cu") · $(cat $J/f.b)"
  echo "  hal | the access log: $(acclog hal | paste -sd'|' -)"; }
c_accept() {
  echo "== accept: seven Accept values on the new route (21050, the same JVM as hal), then three on four old routes on before (21056) and after/ (21050)"
  local a; for a in application/hal+json application/json '*/*' none application/prs.hal-forms+json text/html application/xml; do ask accept 21050 "$a" $OR/1; done
  echo "  accept | the 406's body: $($CURL --http1.1 -s -H 'Accept: application/prs.hal-forms+json' "$(B 21050)$OR/1")"
  echo "  accept | the setting that writes HAL under application/json, read off spring-boot-hateoas-4.1.3.jar's metadata: $(unzip -p .harness/after/$XD/lib/spring-boot-hateoas-4.1.3.jar META-INF/spring-configuration-metadata.json | python3 -I -c 'import json,sys; d=json.load(sys.stdin); print("; ".join("%s default %s" % (p["name"], json.dumps(p.get("defaultValue"))) for p in d["properties"]))')"
  local s port p; for s in before after; do [ $s = before ] && port=21056 || port=21050
    [ $s = before ] && TREE=before tb accept-before 21056 off "" > /dev/null
    for p in /api/v1/customers/Ravi /customers /api/v1/customers $OR; do for a in application/hal+json application/json '*/*'; do ask "old $s" $port "$a" $p; done; done
    [ $s = before ] && QUIET=1 tbstop accept-before 21056; done; true; }
c_refuse() {
  echo "== refuse: every refusal form of the new route (21050, the same JVM)"
  prq "an id no order has" $OR/21; prq "id zero" $OR/0; prq "a negative id" $OR/-1; prq "not a number" $OR/abc
  prq "a query parameter" "$OR/1?x=1"; prq "a trailing slash" $OR/1/; prq "a decimal id" $OR/1.5; prq "an id past Long" $OR/99999999999999999999
  echo "  refuse | POST $OR/1 -> $($CURL --http1.1 -s -o /dev/null -w '%{http_code} %{content_type}' -X POST "$(B 21050)$OR/1") · Allow {$($CURL --http1.1 -s -D - -o /dev/null -X POST "$(B 21050)$OR/1" | tr -d '\r' | sed -n 's/^[Aa]llow: //p' | tr -d ' ')}"
  echo "  refuse | the JVM log's exceptions (by the pattern 'Resolved \[|Exception'): $($G -cE 'Resolved \[|Exception' .harness/run/hal/jvm.log || true)"; }
c_final() {
  echo "== final: the census on before's and after/'s tiffinbox-web (src/main), by unit 15's printed rule; the three link forms on the app's classes (21055, harness-joined)"
  census before before; census after after
  echo "  source | $($G -n 'final class CustomerReads' after/tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerReads.java) (CustomerReads.java)"
  tb final 21055 off 1
  one final 21055 /probe/u16/final
  python3 -I -c 'import json,sys
d=json.load(open(sys.argv[1]))
for k in ("methodOnFinal","methodOnFinalRoot","methodFormFinal","methodOnNonFinal","finalModifier"): print("  final | %s: %s" % (k, d.get(k, "absent")))' $J/o.b | sed -E 's#127\.0\.0\.1:21055#127.0.0.1:<port>#g'
  echo "  final | the JVM log (the pattern '^U16 harness: '): $($G -E '^U16 harness: (methodOn|its root)' .harness/run/final/jvm.log | paste -sd'|' -)"; }
c_next() {
  echo "== next: the list's next as a link, on the harness's page route (21055, the same JVM as final) - not shipped"
  $CURL --http1.1 -s -o $J/n.b "$(B 21055)/probe/u16/orders"
  python3 -I -c 'import json,sys
d=json.load(open(sys.argv[1])); n=d["next"]
print("  next | page one ids %s · the cursor %d characters" % (d["ids"], d["cursorLength"]))
print("  next | href %s · templated %s · percent signs in it %d" % (n["href"], n["templated"], n["href"].count("%")))
print("  next | expanded %s" % n["expanded"])' $J/n.b | sed -E 's#127\.0\.0\.1:21055#127.0.0.1:<port>#g'
  local ex raw; ex=$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1]))["next"]["expanded"])' $J/n.b); raw=$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1]))["next"]["href"])' $J/n.b)
  echo "  next | following the expanded href -> $($CURL --http1.1 -sS -o $J/n2.b -w '%{http_code} %{content_type}' "$ex") · ids $(python3 -I -c 'import json,sys; print([o["id"] for o in json.load(open(sys.argv[1]))["items"]])' $J/n2.b)"
  echo "  next | following the raw href, its template unexpanded (curl -g) -> $($CURL --http1.1 -g -sS -o $J/n3.b -w '%{http_code} %{content_type}' "$raw")"
  tbstop final 21055; }
c_forwarded() {
  echo "== forwarded: GET $OR/1 with X-Forwarded-Host: api.tiffinbox.example and X-Forwarded-Proto: https (after/, 21050, H2, no harness, flag=off), a fresh JVM per strategy"
  local s; for s in default framework; do
    if [ $s = default ]; then tb fwd-$s 21050 off "" > /dev/null; else tb fwd-$s 21050 off "" --server.forward-headers-strategy=framework > /dev/null; fi
    echo "  forwarded | strategy=$s · $(sed 's/ *$//' .harness/run/fwd-$s/cmd)"
    $CURL --http1.1 -s -o $J/fw.b -H 'X-Forwarded-Host: api.tiffinbox.example' -H 'X-Forwarded-Proto: https' "$(B 21050)$OR/1"
    echo "  forwarded | strategy=$s · with the headers -> $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1]))["_links"]; print("self %s · customer %s" % (d["self"]["href"], d["customer"]["href"]))' $J/fw.b) · $(wc -c < $J/fw.b | tr -d ' ') B" | sed -E 's#127\.0\.0\.1:21050#127.0.0.1:<port>#g'
    $CURL --http1.1 -s -o $J/fw.b "$(B 21050)$OR/1"
    echo "  forwarded | strategy=$s · without them (the control) -> $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1]))["_links"]; print("self %s · customer %s" % (d["self"]["href"], d["customer"]["href"]))' $J/fw.b)" | sed -E 's#127\.0\.0\.1:21050#127.0.0.1:<port>#g'
    QUIET=1 tbstop fwd-$s 21050; done
  echo "  forwarded | forward-headers in after/'s committed source and configuration files (*.java, *.yaml, *.yml, *.properties, *.xml): $($G -rl --include='*.java' --include='*.yaml' --include='*.yml' --include='*.properties' --include='*.xml' 'forward-headers' after | wc -l | tr -d ' ') files (the anchor README names the run flag in prose)"; }
c_halgz() {
  echo "== halgz: Boot 4.1.3's compression metadata read back (META-INF/spring-configuration-metadata.json of the jar that holds server.compression), taken again on this tree"
  local j MJ; for j in .harness/after/$XD/lib/spring-boot-*.jar; do unzip -p "$j" META-INF/spring-configuration-metadata.json 2> /dev/null | $G -q '"server.compression' && { MJ=$j; break; }; done
  echo "  halgz | the jar: $(basename "$MJ")"
  unzip -p "$MJ" META-INF/spring-configuration-metadata.json | python3 -I -c '
import json,sys
d=json.load(sys.stdin); ps=[p for p in d["properties"] if p["name"].startswith("server.compression.")]
print("  halgz | keys %d: %s" % (len(ps), ", ".join(sorted(p["name"] for p in ps))))
for p in sorted(ps, key=lambda p: p["name"]):
    if "defaultValue" in p and not isinstance(p["defaultValue"], list): print("  halgz | %s default %s" % (p["name"], json.dumps(p["defaultValue"])))
mt=[p for p in ps if p["name"]=="server.compression.mime-types"][0]["defaultValue"]
print("  halgz | mime-types default: %d entries: %s" % (len(mt), " ".join(mt)))
print("  halgz | application/json in the list: %s · application/hal+json: %s · application/problem+json: %s" % tuple("yes" if x in mt else "no" for x in ("application/json","application/hal+json","application/problem+json")))'
  echo "== the shipped route, gzip asked, flag=on (21050, a fresh harness-free JVM)"
  tb gz 21050 on "" > /dev/null; echo "  halgz | $(sed 's/ *$//' .harness/run/gz/cmd)"
  ask halgz 21050 application/hal+json $OR/1 -H 'Accept-Encoding: gzip'
  ACCEPT=application/hal+json one halgz 21050 $OR/21 -H 'Accept: application/hal+json' -H 'Accept-Encoding: gzip'
  QUIET=1 tbstop gz 21050
  echo "== the harness's twenty-order HAL collection (21055, harness-joined, flag=on), gzip asked and not"
  tb gzh 21055 on 1 > /dev/null; echo "  halgz | $(sed 's/ *$//' .harness/run/gzh/cmd)"
  local a; for a in application/hal+json application/json; do
    ACCEPT=$a one halgz-harness 21055 /probe/u16/hal-all -H "Accept: $a"; cp $J/o.b $J/all-plain.b
    ACCEPT=$a one halgz-harness 21055 /probe/u16/hal-all -H "Accept: $a" -H 'Accept-Encoding: gzip'
    if [ "$(hv Content-Encoding)" = gzip ]; then echo "  halgz-harness | [Accept: $a] gunzip of the gzipped body: $(gunzip -c < $J/o.b | wc -c | tr -d ' ') B md5 $(gunzip -c < $J/o.b | md5 -q) · the plain body md5 $(md5 -q $J/all-plain.b)"; else echo "  halgz-harness | [Accept: $a] not compressed: the body md5 $(md5 -q $J/o.b) = the plain one's $(md5 -q $J/all-plain.b)"; fi; done
  QUIET=1 tbstop gzh 21055; }
c_specwire() {
  echo "== specwire: the new route's served entry against its wire (after/, 21050, harness-free, flag=off)"
  tb sw 21050 off "" > /dev/null
  $CURL -s "$(B 21050)/v3/api-docs" > $J/served.json
  python3 -I - $J/served.json <<'PY'
import json, sys
d = json.load(open(sys.argv[1])); op = d["paths"]["/api/v1/orders/{id}"]["get"]
print("  spec | operationId %s · tags %s · parameters %s" % (op["operationId"], op["tags"], [(p["name"], p["in"], p["schema"].get("type"), p["schema"].get("format"), p.get("required")) for p in op["parameters"]]))
for code, r in sorted(op["responses"].items()):
    for mt, c in r.get("content", {}).items():
        print("  spec | %s %s schema %s" % (code, mt, c.get("schema", {}).get("$ref", "none").split("/")[-1]))
s = d["components"]["schemas"]
print("  spec | EntityModelOrderView properties %s · required %s" % (list(s["EntityModelOrderView"]["properties"]), s["EntityModelOrderView"].get("required", [])))
print("  spec | Links %s · Link properties %s" % (json.dumps(s["Links"]), list(s["Link"]["properties"])))
PY
  local a; for a in application/hal+json application/json; do
    $CURL --http1.1 -s -D $J/sw.h -o $J/sw.b -H "Accept: $a" "$(B 21050)$OR/1"
    echo "  wire | 200 [Accept: $a] $(tr -d '\r' < $J/sw.h | sed -n 's/^Content-Type: //p') members $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(list(d), "· a link holds", sorted(set(k for v in d["_links"].values() for k in v)))' $J/sw.b)"; done
  echo "  wire | 404 $($CURL -s -o /dev/null -w '%{content_type}' "$(B 21050)$OR/21") · 400 (?x=1) $($CURL -s -o /dev/null -w '%{content_type}' "$(B 21050)$OR/1?x=1") · 400 (abc, Framework's) $($CURL -s -o /dev/null -w '%{content_type}' "$(B 21050)$OR/abc") · 406 (hal-forms) $($CURL -s -o /dev/null -w '%{http_code}' -H 'Accept: application/prs.hal-forms+json' "$(B 21050)$OR/1")"
  python3 -I - $J/served.json $J/sw.b <<'PY'
import json, sys
d = json.load(open(sys.argv[1])); w = json.load(open(sys.argv[2])); s = d["components"]["schemas"]
gaps = []
if list(s["EntityModelOrderView"]["properties"]) != list(w): gaps.append("member order: the schema lists %s, the wire sends %s (JSON Schema's properties carry no order)" % (list(s["EntityModelOrderView"]["properties"]), list(w)))
lp = list(s["Link"]["properties"]); wl = sorted(set(k for v in w["_links"].values() for k in v))
if lp != wl: gaps.append("a link: the schema's Link lists %s, each link on the wire holds %s" % (lp, wl))
if "Links" in s and "additionalProperties" in s["Links"]: gaps.append("_links: the schema allows any relation name (additionalProperties), the wire sends self and customer")
op = d["paths"]["/api/v1/orders/{id}"]["get"]
if "406" not in op["responses"]: gaps.append("the 406 (hal-forms, text/html, application/xml) is not documented")
if "400" in op["responses"]: gaps.append("the 400 documents the route's own refusal; Framework's 400 for a non-numeric id (no type) is the same status, not told apart")
for g in gaps: print("  gap | " + g)
print("  gap | named: %d" % len(gaps))
PY
  QUIET=1 tbstop sw 21050; }
c_spec() {
  echo "== the committed spec: regenerated in this commit; read here against the served document (after/, 21050, no harness, flag=off)"
  tb spec 21050 off "" > /dev/null
  local SF=after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json
  $CURL -s "$(B 21050)/v3/api-docs" > $J/served.json
  echo "  the committed file against the served document (servers removed, json.dump indent 2, ensure_ascii False, a final newline): $(python3 -I -c '
import json,sys
d=json.load(open(sys.argv[1])); d.pop("servers",None)
print("equal" if json.dumps(d,indent=2,ensure_ascii=False)+"\n" == open(sys.argv[2],encoding="utf-8").read() else "differ")' $J/served.json $SF)"
  local BF=before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json
  echo "  committed md5 before $(md5 -q $BF) · after $(md5 -q $SF) · bytes before $(wc -c < $BF | tr -d ' ') · after $(wc -c < $SF | tr -d ' ')"
  echo "  the diff against before's (c7e5118's) file: $(diff $BF $SF | $G -c '^>') lines added, $(diff $BF $SF | $G -c '^<') removed"
  diff $BF $SF | $G '^[0-9]' | sed 's/^/  hunk /'
  echo "  the paths added: $(python3 -I -c 'import json,sys; A=json.load(open(sys.argv[1])); B=json.load(open(sys.argv[2])); a=A["paths"]; b=B["paths"]; print(sorted(set(b)-set(a)), "removed", sorted(set(a)-set(b)), "other paths moved", [k for k in a if k in b and a[k]!=b[k]], "schemas added", sorted(set(B["components"]["schemas"])-set(A["components"]["schemas"])), "schemas moved", [k for k in A["components"]["schemas"] if k in B["components"]["schemas"] and A["components"]["schemas"][k]!=B["components"]["schemas"][k]])' $BF $SF)"
  python3 -I harness/ops9s3.py ops $BF > $J/ops-before.txt; python3 -I harness/ops9s3.py ops $SF > $J/ops-after.txt
  echo "  before: $(tail -1 $J/ops-before.txt) · after: $(tail -1 $J/ops-after.txt)"
  echo "  the old operations' ids before -> after: $( [ -z "$(diff <($G -E '^  [A-Z]+ ' $J/ops-before.txt) <($G -E '^  [A-Z]+ ' $J/ops-after.txt) | $G '^<')" ] && echo equal || echo differ)"
  diff <($G -E '^  [A-Z]+ ' $J/ops-before.txt) <($G -E '^  [A-Z]+ ' $J/ops-after.txt) | $G '^[<>]' | sed 's/^/  ops moved | /'
  printf '{}' > $J/empty.json; python3 -I harness/ops9s3.py ops $J/empty.json > /dev/null 2>&1; echo "  ops9s3.py on an empty spec: exit $? (refused)"
  echo "  operationIds unique: $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); i=[o.get("operationId") for v in d["paths"].values() for o in v.values()]; print("yes" if len(i)==len(set(i)) else "no")' $SF)"
  echo "  OpenApiSpecTest on the regenerated file: $(python3 -I -c '
import sys,xml.etree.ElementTree as E
r=E.parse(sys.argv[1]).getroot(); print("tests %s failures %s errors %s" % (r.get("tests"), r.get("failures"), r.get("errors")))' .harness/after/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.OpenApiSpecTest.xml) (after/'s build)"
  QUIET=1 tbstop spec 21050
  echo "== the client rebuilt on the regenerated spec: before's client (-pl tiffinbox-client -am on a copy of before) and after/'s (its build)"
  copy before .harness/client-before; guard "before's client"
  bg "cd .harness/client-before && $MV -DskipTests clean package -pl tiffinbox-client -am" .harness/build-client-before.log; offl .harness/build-client-before.log
  local GB=.harness/client-before/tiffinbox-client/target/generated-sources/openapi GA=.harness/after/tiffinbox-client/target/generated-sources/openapi
  echo "  the client: FILES $($G -c '\.java$' $GB/.openapi-generator/FILES) -> $($G -c '\.java$' $GA/.openapi-generator/FILES) · build exit $RE (before's) / 0 (after/'s, its reactor) · tracked files under tiffinbox-client in the anchor: $(cd .. && git ls-files c9-tiffinbox/tiffinbox-client | sed 's#c9-tiffinbox/tiffinbox-client/##' | paste -sd' ' -)"
  diff <($G '\.java$' $GB/.openapi-generator/FILES) <($G '\.java$' $GA/.openapi-generator/FILES) | $G '^[<>]' | sed 's/^/  the client: files /'
  local f s ne=0 nd=0 nn=0 nm=0 ng=0; for f in $(cd $GA && $G '\.java$' .openapi-generator/FILES); do
    if [ -f $GB/$f ]; then if cmp -s $GB/$f $GA/$f; then s=equal; ne=$((ne + 1)); elif [ "$($G -v '^@Generated(' $GB/$f | md5 -q)" = "$($G -v '^@Generated(' $GA/$f | md5 -q)" ]; then s="date line only"; nd=$((nd + 1)); elif [ -z "$(diff <($G -v '^@Generated(' $GB/$f) <($G -v '^@Generated(' $GA/$f) | $G '^<')" ]; then s="lines added only (the new operation), the date line aside"; ng=$((ng + 1)); else s=moved; nm=$((nm + 1)); fi; else s=added; nn=$((nn + 1)); fi
    echo "  the client: $f $s"; done
  echo "  the client: counts - equal $ne · date line only $nd · lines added only $ng · moved $nm · added $nn"
  diff $GB/src/main/java/com/tiffinbox/client/api/ApiApi.java $GA/src/main/java/com/tiffinbox/client/api/ApiApi.java | $G '^[<>]' | $G -v '@Generated(' | head -14 | sed 's/^/  the client: ApiApi diff /'
  echo "  the client: the PATH_* constants (ops9s3.py paths, a CHECK): before $(python3 -I harness/ops9s3.py paths $GB 2>&1 | tail -1) · after $(python3 -I harness/ops9s3.py paths $GA 2>&1 | tail -1)"
  echo "  the client: its test in after/'s build: $(python3 -I -c '
import sys,glob,xml.etree.ElementTree as E
t=[0,0,0,0]
for f in glob.glob(sys.argv[1]+"/TEST-*.xml"):
    r=E.parse(f).getroot()
    for i,k in enumerate(("tests","failures","errors","skipped")): t[i]+=int(r.get(k) or 0)
print("tests %d failures %d errors %d skipped %d" % tuple(t))' .harness/after/tiffinbox-client/target/surefire-reports) · git status --short tiffinbox-client: $(cd ../c9-tiffinbox && git status --short tiffinbox-client | wc -l | tr -d ' ') lines"; }
movedone() { local port=$1 m=$2 p=$3 w; shift 3; : > $J/mv.h; : > $J/mv.b
  w=$($CURL --http1.1 -sS -D $J/mv.h -o $J/mv.b -w '%{http_code} %{content_type} %{size_download}' --max-time 5 -X "$m" "$@" "$(B $port)$p" 2> /dev/null)
  local bm; bm=$(sed -E 's/"timestamp":"[^"]*"/"timestamp":"<masked>"/; s/"next":"[^"]*"/"next":"<cursor>"/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' $J/mv.b | md5 -q | cut -c1-12)
  w=$(echo "$w" | awk '{ print $1, $2 }')
  echo "  $SIDE | $m $p$( [ -n "${TAG:-}" ] && echo " [$TAG]") -> $w · Allow {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Aa]llow: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)} · Accept-Patch {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Aa]ccept-[Pp]atch: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)} · body $bm"; }
MPT='Content-Type: application/merge-patch+json'; JPT='Content-Type: application/json-patch+json'; CAPI=/api/v1/customers
movedside() { local side=$1 port=$2 a p
  TREE=$side tb moved-$side $port off ""
  SIDE=$side
  movedone $port GET /customers/Ravi
  movedone $port GET $CAPI/Ravi
  TAG=merge movedone $port PATCH $CAPI/Meera -H "$MPT" --data-binary '{"mealsPerDay":2}'
  TAG=json-patch movedone $port PATCH $CAPI/Sunil -H "$JPT" --data-binary '[{"op":"replace","path":"/mealsPerDay","value":2}]'
  movedone $port PATCH /customers
  movedone $port OPTIONS /customers/Ravi
  movedone $port GET /nowhere
  movedone $port GET /dashboard -H 'Accept: text/html'
  movedone $port GET /customers/new -H 'Accept: text/html'
  for a in /v3/api-docs.yaml /v3/api-docs/swagger-config /swagger-ui.html /swagger-ui/index.html; do movedone $port GET $a; done
  movedone $port GET /customers/Nobody
  movedone $port GET $CAPI/Nobody
  TAG=merge movedone $port PATCH $CAPI/Nobody -H "$MPT" --data-binary '{"mealsPerDay":2}'
  movedone $port POST "$CAPI/Nobody/pauses?days=1"
  movedone $port GET $CAPI/Nobody/pauses/1
  movedone $port GET /api/v1/customers/Ravi/orders
  movedone $port GET $OR
  movedone $port GET $CAPI
  movedone $port GET "$CAPI?fields=name"
  movedone $port GET "$CAPI?fields=nickname"
  movedone $port OPTIONS $CAPI
  for p in /api/v1/customers/Ravi /customers $CAPI $OR; do for a in application/hal+json application/json '*/*'; do TAG="Accept: $a" movedone $port GET $p -H "Accept: $a"; done; done
  TAG="the new route" movedone $port GET $OR/1
  QUIET=1 tbstop moved-$side $port; }
c_moved() { echo "== U14's requests (its movedside list, copied; the order list's page one with its cursor masked; /v3/api-docs left out: the spec capture reads it), the Accept class and the new route, on before (21056) and after/ (21050), H2, each its own JVM, no harness, flag=off"
  movedside before 21056; movedside after 21050
  echo "  BOOT-INF/lib names: before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ')"; }
c_seven() {
  echo "== the seven (c5-unit11/curlset.sh, no key header), each tree its own JVM, H2, no harness, flag=off - not a witness for the new route: it sends nothing to /api/v1/orders/{id}"
  echo "  expected $S466"
  local s port i; for s in before after; do [ $s = before ] && port=21056 || port=21050
    TREE=$s tb seven-$s $port off "" > /dev/null
    sh $CURLSET $port .harness/run/seven-$s/secrets/tiffinbox/shutdown-token > $J/seven-$s.txt 2>&1
    i=0; while kill -0 "$(cat .harness/run/seven-$s/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 60 ] || break; sleep 0.05; done
    QUIET=1 tbstop seven-$s $port
    echo "  $s: the seven $(md5 -q $J/seven-$s.txt) ($(wc -l < $J/seven-$s.txt | tr -d ' ') lines)"; done
  echo "  the seven's paths (read off curlset.sh): $($G -oE '^req [A-Z]+ /[a-z]*' $CURLSET | awk '{ print $3 }' | paste -sd' ' -) and POST /shutdown - none under /api/"; }
oldsurface2() { local port=$1 out=$2 BB="http://127.0.0.1:$1" t=$U/$J/os
  printf 'name,mealsPerDay,pricePerMeal,mealType\nChitra,1,130,VEGAN\n' > "$t.csv"; : > "$out"
  one1() { local label=$1; shift; local w rc
    w=$($CURL --http1.1 -sS -D "$t.h" -o "$t.b" -w '%{http_code} %{content_type} %{size_download}' --max-time 10 "$@" 2>"$t.e"); rc=$?
    { echo "== $label -> $w (curl exit $rc)"; tr -d '\r' < "$t.h" | sed -E 's/^(Date|date): .*/\1: <masked>/; s/(JSESSIONID=)[^;]*/\1<masked>/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/^(Expires): .*/\1: <masked>/; s/^(Keep-Alive): .*/\1: <masked>/' | $G -v '^$'
      local n; n=$(wc -c < "$t.b" | tr -d ' ')
      if [ "$n" -le 700 ] && ! tr -d '\r' < "$t.h" | $G -qi '^Content-Encoding: gzip'; then echo "body: $(tr -d '\r' < "$t.b" | tr '\n' '~' | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g')"; else echo "body: $n B md5 $(md5 -q "$t.b")"; fi; } >> "$out"; }
  one1 "GET /customers" "$BB/customers"
  one1 "GET /customers/Ravi" "$BB/customers/Ravi"
  one1 "POST /customers (JSON, a fresh name)" -X POST -H 'Content-Type: application/json' --data-binary '{"name":"Asha","mealsPerDay":1,"pricePerMeal":110,"mealType":"VEG"}' "$BB/customers"
  one1 "GET /revenue" "$BB/revenue"
  one1 "GET /dashboard (Accept: application/json)" -H 'Accept: application/json' "$BB/dashboard"
  one1 "GET /dashboard (Accept: text/html)" -H 'Accept: text/html' "$BB/dashboard"
  one1 "GET /customers/new" -H 'Accept: text/html' "$BB/customers/new"
  one1 "POST /customers (the form)" -X POST -H 'Content-Type: application/x-www-form-urlencoded' --data-binary 'name=Bina&mealsPerDay=2&pricePerMeal=100&mealType=VEGAN' "$BB/customers"
  one1 "POST /customers/import (a two-line CSV)" -X POST -F "file=@$t.csv;type=text/csv;filename=two.csv" "$BB/customers/import"
  : > "$t.h"; : > "$t.b"
  perl -e '$SIG{ALRM}=sub{kill "TERM",$pid; exit 3}; alarm 10; $pid=open(my $c,"-|",@ARGV) or die; $s=0; while(defined($l=<$c>)){print $l; if($l=~/^\r?\n$/){last if $s} else {$s=1}} kill "TERM",$pid; exit 0' \
     curl --noproxy '*' --http1.1 -sS -N -D "$t.h" -H 'Accept: text/event-stream' "$BB/customers/feed" > "$t.b" 2>"$t.e"; local frc=$?
  { echo "== GET /customers/feed (by count: headers + the first event, to its blank line, alarm 10 s) -> $(tr -d '\r' < "$t.h" | head -1 | cut -d' ' -f2) $(tr -d '\r' < "$t.h" | $G -i '^Content-Type:' | cut -d' ' -f2) $(wc -c < "$t.b" | tr -d ' ') (reader exit $frc)"
    tr -d '\r' < "$t.h" | sed -E 's/^(Date|date): .*/\1: <masked>/; s/(JSESSIONID=)[^;]*/\1<masked>/; s/^(Keep-Alive): .*/\1: <masked>/' | $G -v '^$'; echo "body: $(tr -d '\r' < "$t.b" | tr '\n' '~')"; } >> "$out"
  one1 "GET /kitchen" "$BB/kitchen"
  one1 "GET /nowhere" "$BB/nowhere"
  one1 "POST /shutdown (no token, last)" -X POST "$BB/shutdown"
  rm -f "$t".*; }
c_surface() { local side port
  echo "== the old surface by count (U14's reader, copied), each tree its own JVM, H2, no harness, flag=off - not a witness for the new route"
  echo "  expected $U4SURF"
  for side in before after; do [ $side = before ] && port=21056 || port=21050
    TREE=$side tb surface-$side $port off "" > /dev/null
    oldsurface2 $port $J/surface-$side.txt
    QUIET=1 tbstop surface-$side $port
    echo "  $side: the old surface $(md5 -q $J/surface-$side.txt) ($($G -c '^== ' $J/surface-$side.txt) requests, $(wc -l < $J/surface-$side.txt | tr -d ' ') lines)"; done
  echo "  before -> after/: $(cmp -s $J/surface-before.txt $J/surface-after.txt && echo equal || echo DIFFER)"
  echo "== the S9.14 plant (1/1 per run): after/ with Spring MVC's problem details off (--spring.mvc.problemdetails.enabled=false), 21054 - the check that can fail"
  tb surface-plant 21054 off "" --spring.mvc.problemdetails.enabled=false > /dev/null
  oldsurface2 21054 $J/surface-plant.txt; QUIET=1 tbstop surface-plant 21054
  echo "  ~ plant (21054, the S9.14 slot): the old surface $(md5 -q $J/surface-plant.txt) - $(cmp -s $J/surface-plant.txt $J/surface-after.txt && echo 'EQUAL (the plant was not seen)' || echo 'moved, as planted')"; }
c_inert() {
  echo "== the key header across this run's captures (request lines and bodies)"
  echo "  request lines naming the key header across the captures: $(cat .r-*.new 2> /dev/null | $G -ciF "$KW" || true)"
  echo "  IdempotencyKeyFilter's table names POST /api/v1/customers/{name}/pauses only (read): $($G -c 'POST' after/tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java) POST lines in the filter; the new route is a GET"
  echo "  MockMvc runs: OrderResourcesTest sends GETs only; no request of this unit carries the key"; }
surefire() { python3 -I - "$1" "$2" <<'PY'
import sys, glob, xml.etree.ElementTree as E
t = [0, 0, 0, 0]
for f in glob.glob(sys.argv[1] + "/TEST-*.xml"):
    r = E.parse(f).getroot()
    for i, k in enumerate(("tests", "failures", "errors", "skipped")):
        t[i] += int(r.get(k) or 0)
print("  %s | tests %d failures %d errors %d skipped %d" % ((sys.argv[2],) + tuple(t)))
PY
}
cls() { python3 -I -c '
import sys,xml.etree.ElementTree as E
r=E.parse(sys.argv[1]).getroot(); print("  %s | class %s | tests %s failures %s errors %s skipped %s" % (sys.argv[2], sys.argv[3], r.get("tests"), r.get("failures"), r.get("errors"), r.get("skipped")))' "$1" "$2" "$3"; }
reactor() { $G -E '^\[INFO\] TiffinBox[A-Za-z ]* \.+ (SUCCESS|FAILURE|SKIPPED)' "$1" | sed -E 's/ \.+ / ... /; s/\[ *[0-9.:]+ (s|min)\]//; s/^\[INFO\] /  reactor: /; s/ *$//'; }
c_tests() { local p c
  echo "== mvn -o clean package (tests on) on a copy of after/ (.harness/pkg): the whole reactor, Docker reachable"
  copy after .harness/pkg; copy after .harness/tests; copy after .harness/webonly
  guard "mvn package"
  bg "cd .harness/pkg && $MV \"$AL\" clean package" .harness/pkg.log; local pre=$RE
  echo "  mvn package exit $pre"; reactor .harness/pkg.log
  for p in web client; do surefire .harness/pkg/tiffinbox-$p/target/surefire-reports "package | tiffinbox-$p"; done
  for c in OrderResourcesTest CustomerFieldsTest OrderPagesTest ApiVersionTest TiffinBoxRestDocsTest OpenApiSpecTest TiffinBoxWebTest; do cls .harness/pkg/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.$c.xml package $c; done
  $G -E '^OrderResourcesTest: ' .harness/pkg.log | sed 's/^/  printed | /'
  echo "== the Docker-free twin: after/'s own build (DOCKER_HOST=unix:///nonexistent/docker.sock, the run's first build)"
  for p in web client; do surefire .harness/after/tiffinbox-$p/target/surefire-reports "twin | tiffinbox-$p"; done
  echo "  slice TiffinBoxWebTest: before $(python3 -I -c 'import re,sys; print(len(re.findall(r"^\s+@Test\b", open(sys.argv[1]).read(), re.M)))' before/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java) · after $(python3 -I -c 'import xml.etree.ElementTree as E,sys; print(E.parse(sys.argv[1]).getroot().get("tests"))' .harness/pkg/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.TiffinBoxWebTest.xml) (before: its @Test lines; after: Surefire's XML) · the slice's file byte-equal to before's: $(cmp -s before/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java after/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java && echo yes || echo no) - measured: no slice edit needed, OrderEntityRepository is already mocked ($($G -cE '@MockitoBean.*OrderEntityRepository' after/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java) line)"
  echo "  web tests before (unit 14's values): $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit14/README.md | $G -oE 'web_tests=[0-9]+' | head -1 | cut -d= -f2) · new @Test lines $($G -cE '^ +@Test$' after/tiffinbox-web/src/test/java/com/tiffinbox/web/OrderResourcesTest.java)"
  echo "  test files moved before -> after: $(for p in $(cd before && find tiffinbox-web/src/test -type f | sort); do cmp -s before/$p after/$p || basename $p; done | paste -sd, -) · new: $(cd after && for p in $(find tiffinbox-web/src/test -type f | sort); do [ -e ../before/$p ] || basename $p; done | paste -sd, -)"
  echo "  the test classes that send /api/v1/ (grep -l): $( (cd after && $G -rl '/api/v1/' tiffinbox-web/src/test/java) | sed 's#.*/##; s#\.java$##' | sort | paste -sd, -)"
  echo "== mvn -o clean verify on a copy of after/ (.harness/tests): Surefire's tests on H2 in memory, then the five ITs on PostgreSQL 18.6 in Testcontainers containers (21280-21284)"
  for p in 21280 21281 21282 21283 21284 18881 18882 18883 18884; do [ "$(listeners $p)" = 0 ] || die "$p is bound before verify"; done
  guard "mvn verify"
  bg "cd .harness/tests && DOCKER_HOST=\"$DH\" TESTCONTAINERS_RYUK_DISABLED=true $MV \"$AL\" clean verify" .harness/verify.log; local vre=$RE
  reactor .harness/verify.log
  surefire .harness/tests/tiffinbox-web/target/surefire-reports "verify | tiffinbox-web"
  python3 -I - .harness/tests/tiffinbox-web/target/failsafe-reports .harness/tests/tiffinbox-web/target/surefire-reports-it $vre <<'PY'
import sys, glob, xml.etree.ElementTree as E
fs = glob.glob(sys.argv[1] + "/TEST-*.xml") + glob.glob(sys.argv[2] + "/TEST-*.xml")
t = [0, 0, 0]
for f in fs:
    r = E.parse(f).getroot()
    for i, k in enumerate(("tests", "failures", "errors")):
        t[i] += int(r.get(k) or 0)
print("  verify exit %s · ITs tests %d failures %d errors %d · classes %d" % (sys.argv[3], t[0], t[1], t[2], len(fs)))
for f in sorted(fs):
    r = E.parse(f).getroot(); print("  IT class %s | tests %s failures %s errors %s" % (r.get("name").split(".")[-1], r.get("tests"), r.get("failures"), r.get("errors")))
PY
  echo "  IT bindings: $($G -cE '^IT BINDINGS ' .harness/verify.log) lines · not 127.0.0.1: $($G -E '^IT BINDINGS ' .harness/verify.log | $G -oE -- '-> [0-9.]+:' | $G -vc -- '-> 127\.0\.0\.1:' || true)"
  echo "  Testcontainers containers after: $(dk ps -aq --filter label=org.testcontainers=true | wc -l | tr -d ' ') · images pulled: $($G -ciE 'Pulling image|pull(ed|ing) ' .harness/verify.log || true)"
  echo "== the hand-built form: mvn -o clean package -pl tiffinbox-web -am on a copy of after/ (.harness/webonly), Docker-free"
  guard "the web-only form"
  bg "cd .harness/webonly && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package -pl tiffinbox-web -am" .harness/webonly.log
  surefire .harness/webonly/tiffinbox-web/target/surefire-reports "webonly | tiffinbox-web"
  echo "  downloads across the builds: $(cat .harness/pkg.log .harness/verify.log .harness/webonly.log .harness/build-after.log .harness/build-before.log .harness/build-client-before.log 2> /dev/null | $G -cE 'Download(ing|ed) from ' || true)"
  echo "  BOOT-INF/lib: before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ')"; }
exrun() { local v=$1 sh=$2 o cmd
  guard "the exercise, $v, $sh"
  rm -rf .harness/exercise/tree; copy after .harness/exercise/tree
  case $v in broken) cmd='sh break.sh "$0" > /dev/null && sh check.sh "$0"' ;; solved) cmd='sh break.sh "$0" > /dev/null && sh apply.sh "$0" > /dev/null && sh check.sh "$0"' ;; *) cmd="sh break.sh \"\$0\" > /dev/null && HOW=$v sh apply.sh \"\$0\" > /dev/null && sh check.sh \"\$0\"" ;; esac
  if [ $sh = bash ]; then o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21058 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock bash -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1)
  else o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21058 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock /bin/zsh -f -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1); fi
  local pre="  $v $sh |"; [ $v = broken ] || [ $v = solved ] || pre="  ~ $v $sh |"
  printf '%s\n' "$o" | sed -E "s/127\.0\.0\.1:21058/127.0.0.1:<port>/g; s/^/$pre /"
  [ ! -f exercise/check.build.log ] || offl exercise/check.build.log
  [ "$(listeners 21058)" = 0 ] || die "the exercise left something listening on 21058"; }
c_exercise() { local v sh
  rm -rf .harness/exercise; mkdir -p .harness/exercise
  for v in broken solved; do for sh in bash zsh; do echo "  == $v, $sh"; exrun $v $sh; done; done
  if [ "$RUNNO" = 1 ] || [ "$RUNNO" = 0 ]; then for v in unfinal literal dropped fixedelsewhere; do exrun $v bash; done; fi
  rm -rf exercise/check.run; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.b exercise/check.h
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures${DEVCAPS:+ (DEVELOPMENT: only $DEVCAPS - not a run of record)}"
cap advisory c_advisory
cap before c_before
cap change c_change
cap starter c_starter
cap jackson c_jackson
ACC=1 tb hal 21050 off "" > .harness/hal.up; cat .harness/hal.up
cap hal c_hal
cap accept c_accept
cap refuse c_refuse
QUIET=1 tbstop hal 21050
cap final c_final
cap next c_next
cap forwarded c_forwarded
cap halgz c_halgz
cap specwire c_specwire
cap spec c_spec
cap moved c_moved
cap seven c_seven
cap surface c_surface
cap tests c_tests
cap exercise c_exercise
cap inert c_inert
echo "== plants (each made to FAIL first on a copy of this run's capture; harness/chk16.py plants)"
PL=$(ck plants .) || die "a plant was not caught: $(printf '%s\n' "$PL" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$PL" | $G '^ok ' | sed 's/^ok /  /'
PLV=$(printf '%s\n' "$PL" | sed -n 's/^VALUES //p')

# ---- the end: the sweep, the values, the published hashes -------------------------------------------------------------------------------
[ -z "$(echo $PIDS)" ] || die "a JVM of this run is still running: $PIDS"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
[ -z "$(dk ps -aq --filter label=org.testcontainers=true)" ] || die "a Testcontainers container of this run is left"
[ -z "$(dk ps -aq --filter name=^/c9u16-)" ] || die "a c9u16-* container is left"
NI1=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI1" = "$NI0" ] && [ "$VOL1" = "$VOL0" ] || die "R.322: images $NI0 -> $NI1, volumes $VOL0 -> $VOL1"
AD1=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true); [ "$AD1" = "$AD" ] || die "the anchor moved during the run"
pin before-tree before; pin after-tree after
MDB=$(find . ../c9-tiffinbox ../c9-unit14 -name '*.mv.db' -not -path './.harness/*' -not -path '../c9-unit14/.harness/*' 2> /dev/null | wc -l | tr -d ' ')
[ "$MDB" = 0 ] || die "an H2 file outside .harness/"
[ -z "$(ls exercise | $G -v -xE 'README.md|SOLUTION.md|apply.sh|break.sh|check.sh')" ] || die "the exercise left a file in exercise/"
VALS="$VALS
plants: $PLV
build: seed_files=$NF0 seed_bytes=$NB0 central_only=$CO"
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
[ -n "${DEVCAPS:-}" ] && { echo "c9-unit16: DEVELOPMENT run ($DEVCAPS) - nothing published"; exit 2; }
VO=$(ck values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; [ -n "${NOPIN:-}" ] || die "README.md's values block is not this run's"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM of this run, ports free, no container left, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1 · the anchor against after/ as at the start · the tree pins · *.mv.db outside .harness 0"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit16: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit16: every capture = published ($NCAPS) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"
