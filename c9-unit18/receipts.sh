#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 18 "Binary Payloads" - this unit's receipts. Course 9's FOURTEENTH anchor change, Section 3's sixth and last:
# before is a link to ../c9-unit17/after (U17's after); after/ is a frozen copy of ../c9-tiffinbox after this unit's change - CustomerBills
# (GET /api/v1/customers/{name}/bill streams the bill, text/csv, chunked; GET .../bill-link mints a signed link; GET .../bill/signed checks
# it before it streams), the lifetime key in application.yaml, CustomerBillsTest, the committed spec regenerated, the anchor's README card.
# The harness's things, labelled on every capture that uses one: the harness's short lifetime (the shipped setting given on a run's command
# line, lifetime=short), the harness's blob route (probe.u18.U18Config, joined on 21077 only), the harness's presigner (harness/presign,
# built offline from the seed copy, run in a sealed --network none container by digest), a fake test credential (in Presign.java only).
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5; lines starting "  ~" are run-variant
# and left out of the hash - the poll lines of the waited-out expiry, the exercise's refused variants of run 1):
#   advisory  the S9.36 read filed for this unit (ADV), verified, before any build; the shipped and the harness's coordinates against it
#   before    the new routes and the old ones on before (21076), the mappings, the spec's counts, the lib, the census inputs
#   change    the modules, the new files whole, the derived changed list, the greps, the handler names, application.yaml's keys
#   census    the controllers on before and after/ by unit 15's printed rule
#   harness   the presigner's build (offline), its class path, the named diffs of the adapted harness files, the blob classes compiled
#   proxy     the bill on the wire (21070): status line, headers, bytes by three witnesses, lines, md5, Course 6's rows; the 8 MiB blob (21077)
#   declared  the failure receipt: the signed download declared ResponseEntity<?> on a scratch copy (21073) against after/'s own (21070)
#   signed    the link: valid, the name changed, expires raised, tampered, the lifetime read back, ttlSeconds planted, the expiry waited out
#             (21075, lifetime=short), the open mint, a link from another start (21075)
#   presign   the sealed container's three prints, then the harness's presigner with a fake test credential: the URL's keys
#   defaults  the sealed container, then the SDK's defaults: the credentials chain and the region chain, each as printed
#   expect    Expect: 100-continue on the old POST /customers/import (21070): the order of four events in curl's trace
#   refuse    every refusal of the three routes, each status, type and detail; Framework's and Boot's with no type named
#   specwire  the three routes' served entries against their wires
#   spec      the committed spec against the served one, the diff, the counter, the client rebuilt on it
#   moved     U17's requests on before (21076) and after/ (21070)
#   seven     c5-unit11's seven on before and after/
#   surface   the old surface by count on before and after/
#   inert     the key header across this run's captures
#   tests     package, the Docker-free twin, verify (Surefire on H2, the five ITs on PostgreSQL), the web-only form, the slice
#   exercise  break.sh, check.sh, apply.sh on 21078, bash and zsh -f, H2; the refused variants (run 1)
#   section   Section 3's six units: their commits, the committed spec's counts at each after, the next title
# Ports (U18's band, 21070-21079): 21070 after/ on H2 · 21073 the scratch copy · 21075 the second TiffinBox (lifetime=short; the other
# start) · 21076 before · 21077 the harness-joined start (the blob) · 21078 the exercise · 21079 never bound: the presigner's endpoint
# override, inside a container with no network · 21071, 21072 and 21074 never bound (bill-pg and the S9.14 plant slot not captured).
# During mvn verify only: 21280-21284. Every store on 127.0.0.1; every curl --noproxy '*'.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
C9R=${C9R:-"/Users/$ME/Downloads/Youtube Content/LearnProgrammingWithVivek/rest-apis-done-right"}   # the course's folder (briefs, research)
SEED=${SEED:-"$C9R/_research/m2-seed-c9-s3"}   # the course's Section 3 seed
PK3="$C9R/_research/s3-probe-2026-11-26"; BK3="$C9R/_research/s3-blue-2026-11-26"; ADV="$C9R/_research/docs-2026-11-27/advisories"
export C9R
RUNNO=${RUNNO:-0}                                     # the run of record's number (1, 2, 3); 0 = development
SHORT=2s                                              # the harness's short lifetime (lifetime=short): a label, never voiced
IMG="eclipse-temurin:25-jre@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636"   # the presigner's image, by digest (S3N §0)
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
export DOCKER_HOST="$DH"
PIDS=""; INTR=""; mpid=""; CTRS=""
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in $mpid $PIDS; do [ -z "$p" ] || killtree "$p"; done; for p in $mpid $PIDS; do if kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; for c in $CTRS; do dk rm -fv "$c" > /dev/null 2>&1; done; for c in $(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null); do dk rm -fv "$c" > /dev/null 2>&1; done; rm -rf exercise/check.run; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.b exercise/check.h exercise/check.bill; [ -z "$INTR" ] || rm -f .r-*.new; rmdir .r-lock 2> /dev/null || rm -rf .r-lock; true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness's blob classes are compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git unzip /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|SPRINGDOC_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|AWS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit18 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · $(curl --version | head -1 | cut -d' ' -f1-2) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }') · run $RUNNO"

# ---- gates before anything is built: the folder, the link, the pins, the anchor, the static check, the prose, the exercise ----------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk18.py dur9.py ops9s3.py presign s918.py src tree18.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
[ "$(ls harness/presign | paste -sd' ' -)" = 'Presign.java pom.xml' ] && [ "$(cd harness/src && find . -type f | sort | paste -sd' ' -)" = './probe/u18/U18Blob.java ./probe/u18/U18Config.java' ] || die "harness/presign or harness/src holds another file"
for f in walk.py follow.py loc9.py seal9.py cdp.mjs cdp9.mjs specwire9.py mirror Gzip14.java U16Hal.java U16Next.java src/probe/u16 src/probe/u17; do [ ! -e harness/$f ] || die "harness/$f: an earlier unit's instrument this unit does not carry"; done
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md apply.sh break.sh check.sh' ] || die "exercise/ holds another file, or misses one"
[ -L before ] && [ "$(readlink before)" = ../c9-unit17/after ] || die "before must be a link whose text is exactly ../c9-unit17/after"
[ -d after ] && [ ! -L after ] || die "after/ is this unit's own frozen tree, a directory, not a link"
for t in before after; do [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-client/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/"; true; done
echo "  before -> $(readlink before) (a link, the text exact) · after/ a directory (the frozen copy) · no secrets/, target/ or .m2-demo/ in either · harness/: presign/ (the harness's presigner), src/probe/u18 (the harness's blob route); no walk.py, follow.py, seal9.py, cdp.mjs, cdp9.mjs, loc9.py, Gzip14.java, U16Hal.java, U16Next.java"
OP=$(md5 -q "$BK3/instruments/ops9s3.py"); [ "$OP" = 8f062a0e5e872c478579756a8426c012 ] || die "BLUE's ops9s3.py is not 8f062a0e"
[ "$(md5 -q harness/ops9s3.py)" = "$OP" ] || die "harness/ops9s3.py is not BLUE's instrument, byte for byte"
echo "  ops9s3.py = BLUE's (md5 $OP, byte for byte; it refuses an empty spec) · the probe's ProbeJobsAndBills.java md5 $(md5 -q "$PK3/instruments/probe-src/ProbeJobsAndBills.java") (read for its shapes, not copied)"
[ "$(sed -n '5,$p' harness/tree18.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit17/harness/tree17.py | md5 -q)" ] || die "harness/tree18.py's code is not tree17.py's"
for u in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17; do [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit$u/harness/dur9.py)" ] || die "harness/dur9.py is not ../c9-unit$u's copy"; done
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; J6="$HOME/Desktop/PromptVidya-Automation/java6_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"
  [ ! -f "$C9R/_builders/dur9.py" ] || [ "$(md5 -q "$C9R/_builders/dur9.py")" = "$D9" ] || die "harness/dur9.py is not C9/_builders/dur9.py"
  TT=$(python3 -I -c '
import re,sys; t=open(sys.argv[1]).read().split("TITLES",1)[1]; u=open(sys.argv[2]).read().split("TITLES",1)[1]
for k in ("07","09","10","12","16","17","18","19"):
    m=re.search(r"\"%s\": *\"([^\"]+)\"" % k, t); print("%s=%s" % (k, m.group(1) if m else ""))
m=re.search(r"\"20\": *\"([^\"]+)\"", u); print("c6-20=%s" % (m.group(1) if m else ""))' "$J9" "$J6" | paste -sd'|' -)
  [ "$TT" = '07=OpenAPI: The Contract|09=Documenting Errors, Examples and Security|10=Code Generation From the Contract|12=Versioning Strategies|16=Spring HATEOAS in Practice|17=Bulk Operations and 202 Accepted|18=Binary Payloads|19=Rate Limiting|c6-20=File Upload and Download' ] || die "the series' TITLES differ from the call-backs (the live title wins - a finding): $TT"
  echo "  the titles, read off the registries (the call-backs, by title only, R.224): $TT"
else D9N="(the registry is not on this machine: U01-U17's copies are the pin)"; fi
RM="$(dirname "$C9R")/_briefs/TRACK-ROADMAP.md"
if [ -f "$RM" ]; then
  [ "$(sed -n 390p "$RM")" = '- 18 **Binary Payloads** — presigned URLs vs proxying bytes.' ] || die "TRACK-ROADMAP.md:390 is not unit 18's row"
  sed -n 393p "$RM" | $G -qF -- '- 19 **Rate Limiting**' || die "TRACK-ROADMAP.md:393 is not Rate Limiting"
  sed -n 411p "$RM" | $G -qF -- '**The Threat Model First**' || die "TRACK-ROADMAP.md:411 is not The Threat Model First"
  echo "  the roadmap (by title only): :390 unit 18's row, :393 Rate Limiting (Section 4's first), :411 The Threat Model First (Course 10) - each read, equal"; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit01-17's copies $D9N · tree18.py's code = tree17.py's"
XS1=$(sed -n '/^# --- XFAM_S9S1 begin ---$/,/^# --- XFAM_S9S1 end ---$/p' harness/s918.py | md5 -q); XS1U=$(sed -n '/^# --- XFAM_S9S1 begin ---$/,/^# --- XFAM_S9S1 end ---$/p' ../c9-unit17/harness/s917.py | md5 -q)
[ "$XS1" = "$XS1U" ] || die "s918.py's XFAM_S9S1 slice is not U17's s917.py's"
echo "  s918.py: XFAM_S9S1's slice md5 $XS1 = ../c9-unit17/harness/s917.py's · its XU18 family this unit's · lines outside XU18 = s917.py's but for the names: $(diff <(sed '/^XU17 = {/,/^u04 = u17$/d' ../c9-unit17/harness/s917.py | sed 1d) <(sed '/^XU18 = {/,/^u04 = u18$/d' harness/s918.py | sed 1d) | $G -c '^[<>]') lines differ"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit17/receipts.md5)
[ "$UA" = "117 1a0f22bb4d4fbe455b10b6b8081b65c8" ] || die "../c9-unit17/receipts.md5's after-tree line is not 117 1a0f22bb ($UA)"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree18.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || { [ -n "${NOPIN:-}" ] && { echo "  $dir/: $got (NOPIN: no pin yet)"; return 0; }; die "receipts.md5 has no $nm line"; }
  [ "$nm" = after-tree ] || [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit17/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree18.py $dir/ -> $got = receipts.md5's $nm line$( [ "$nm" = before-tree ] && echo " = ../c9-unit17/receipts.md5's after-tree line")"; }
pin before-tree before; pin after-tree after
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true)
echo "  after/ against the live anchor (the start note): $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures its own frozen after/' )"
HF="harness/chk18.py harness/s918.py harness/tree18.py harness/dur9.py harness/ops9s3.py harness/presign/pom.xml harness/presign/Presign.java harness/src/probe/u18/U18Config.java harness/src/probe/u18/U18Blob.java exercise/check.sh exercise/apply.sh exercise/break.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's scripts: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
ST=$(python3 -I -B harness/chk18.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
echo "  static (harness/chk18.py static after before; reads after/, before and git show 13b1967:… only - flag 31): $(printf '%s\n' "$ST" | $G -c '^ok ') checks, FAIL 0 · its output md5 $(printf '%s\n' "$ST" | md5 -q)"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s918.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U18 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s918, per sentence): /'
PH=$($G -rnE 'PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b|<measure>' README.md exercise 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
GL=$(python3 -I -B harness/chk18.py gloss README.md) || die "the gloss: $(printf '%s\n' "$GL" | $G '^FAIL' | head -3 | paste -sd';' -)"
echo "  the gloss: $(printf '%s\n' "$GL" | $G -c '^ok ') checks, FAIL 0 ($(python3 -I -B harness/chk18.py gloss-line))"
HOOK=$(python3 -I -B harness/chk18.py hook); EXQ=$(python3 -I -B harness/chk18.py exq); GLS=$(python3 -I -B harness/chk18.py gloss-line)
IL=$(python3 -I -B harness/chk18.py interleaved) || die "the brief's interleaved hooks and exercises: $IL"
echo "  $IL"
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S3B's Unit 18 Hook line), byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
HW=$(printf '%s\n' "$HOOK" | wc -w | tr -d ' '); EW=$(printf '%s\n' "${EXQ#Your turn: }" | wc -w | tr -d ' ')
[ "$HW" -le 25 ] && [ "$EW" -le 25 ] || die "a spoken line over 25 words (hook $HW, exercise $EW)"
echo "  the hook ($HW words) and the exercise's line ($EW words after 'Your turn:') byte for byte, extracted from S3B's Unit 18 (md5 $(md5 -q "$C9R/_briefs/UNIT-BRIEFS-S3-PAYLOADS.md"))"
printf '%s\n\n%s\n\n%s\n' "$HOOK" "$EXQ" "$GLS" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s918.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
SWR=$(printf '%s\n' "$SW" | $G ' line ' | sed 's#.*spoken.md ##' | sort -u | paste -sd';' -)
echo "  the hook, the exercise's line and the gloss through s918.py: $(printf '%s\n' "$SW" | tail -1 | sed 's/.* refused: /refused /')$( [ -n "$SWR" ] && echo " - $SWR (handed to RED)")"; rm -f .r-lock/spoken.md
TS="Presigned URLs vs StreamingResponseBody in Spring Boot"
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
DRL=$($G -v '^ *#' receipts.sh | $G -F 'dk run ' | $G -vF -- '--network none' | wc -l | tr -d ' ')
[ "$DRL" = 0 ] || die "a dk run line without --network none"
MVL=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -F '$MV ')
MVA=$(printf '%s\n' "$MVL" | $G -vF -- '-pl tiffinbox-web -am' | $G -vF -- '-pl tiffinbox-client -am' | $G -cF -- '-pl ' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh with a -pl form other than '-pl tiffinbox-web -am' or '-pl tiffinbox-client -am'"
KW='idempotency''-key'; KH=$($G -v '^ *#' receipts.sh exercise/check.sh exercise/apply.sh exercise/break.sh | $G -ciF "$KW" || true)
[ "$KH" = 0 ] || die "S9.21: a line of receipts.sh or the exercise names the key header"
LA=$($G -nF 'c9-tiffinbox' receipts.sh exercise/check.sh exercise/apply.sh exercise/break.sh harness/tree18.py | $G -v ':[0-9]*: *#' | $G -vF 'AD=$(diff -rq' | $G -vF 'AD1=$(diff -rq' | $G -vF 'MDB=$(find' | $G -vF 'git status --short tiffinbox-client' | $G -vF "\$G -nF 'c9-tiffinbox'" | $G -vF 'tracked files under tiffinbox-client' | wc -l | tr -d ' ')
[ "$LA" = 0 ] || die "flag 31: a line of the receipts or the exercise reads the live anchor outside the start note, the end check, the H2-file sweep and the client's git status"
echo "  static: no kill by name; every docker call on the pinned socket, every removal rm -fv, every run --network none; R.391's Maven forms only; the key header named by no line; the live anchor read only by the start note, the end check, the H2-file sweep and the client's git status (flag 31)"
FK=$(sed -n 's/.*AwsBasicCredentials.create("\([^"]*\)", "\([^"]*\)").*/\1|\2/p' harness/presign/Presign.java); [ -n "$FK" ] && [ "$(printf '%s' "$FK" | tr '|' '\n' | wc -l | tr -d ' ')" = 1 ] || die "the fake test credential could not be read off Presign.java"
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
    gsub(/127\.0\.0\.1:2107[0-9]/, "127.0.0.1:<port>")
    gsub(/expires=[0-9]+/, "expires=<masked>")
    gsub(/sig=[A-Za-z0-9_-]+/, "sig=<masked>")
    gsub(/X-Amz-(Expires|Date|Signature|Credential)=[^ &·]+/, "X-Amz-&=<masked>"); gsub(/X-Amz-X-Amz-/, "X-Amz-"); gsub(/=[^ &·=]*=<masked>/, "=<masked>")
    gsub(/bill-link-lifetime=[0-9]+[smh]/, "bill-link-lifetime=<lifetime>")
    gsub(/lifetime: PT[0-9HMS.]+/, "lifetime: <lifetime>")
    gsub(/[Rr]etry-[Aa]fter: [0-9]+/, "Retry-After: <masked>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'took 812 ms' '"timestamp":"2026-11-01T08:09:00.123Z"' "$U/x $HOME/y" 'href /api/v1/customers/Ravi/bill/signed?expires=1795737696&sig=_ng4hlR66KmLgkQeLOdaY8SKuKPeR12fz6X7uQQ_aV0' 'GET http://127.0.0.1:21070/x X-Amz-Expires=300 · X-Amz-Date=20261127T000000Z' '--tiffinbox.bill-link-lifetime=2s · the bill link'"'"'s lifetime: PT5M (tiffinbox' | mask)
[ "$(printf '%s\n' "$MP" | paste -sd'|' -)" = 'Started TiffinBoxServer in <t> (process running for <t>)|took <t>|"timestamp":"<time>"|…/x ~/y|href /api/v1/customers/Ravi/bill/signed?expires=<masked>&sig=<masked>|GET http://127.0.0.1:<port>/x X-Amz-Expires=<masked> · X-Amz-Date=<masked>|--tiffinbox.bill-link-lifetime=<lifetime> · the bill link'"'"'s lifetime: <lifetime> (tiffinbox' ] || die "the mask's self-test: $(printf '%s\n' "$MP" | paste -sd'|' -)"
echo "  masks: the log mask masked a Started line's times, a millisecond count, a timestamp, the folders, the home, a band port, a link's expires and sig, the X-Amz-* values, the lifetime on a command line and in the log (self-test)"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh); [ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SURF=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh); [ ${#U4SURF} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh (SURF=)"
U17V=$(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit17/README.md | $G -E '^(seven|surface): ' | $G -oE '(seven|surface)=[0-9a-f]{8}' | paste -sd' ' -)
[ "$U17V" = "seven=$(echo $S466 | cut -c1-8) surface=$(echo $U4SURF | cut -c1-8)" ] || die "U17's README values block ($U17V) is not the seven and the surface read off the receipts"
echo "  the seven: expected $S466 (../c7-unit31/receipts.sh's S466= line) · the old surface: expected $U4SURF (../c9-unit04/receipts.sh's SURF= line) · both = U17's values block ($U17V)"
echo "  the probe's binary captures (PK3/captures/h37/, read, not copied: the expectation on the probe's routes, 1 run): $(ls "$PK3/captures/h37" | wc -l | tr -d ' ') files, their md5 list $(cd "$PK3/captures/h37" && for f in $(ls | sort); do printf '%s %s\n' "$(md5 -q "$f")" "$f"; done | md5 -q) · presign.txt $(md5 -q "$PK3/captures/h37/presign.txt") · RED's sealed ×5 $(md5 -q "$BK3/red-out/presign-sealed.txt") · BLUE's captures: $(ls "$BK3/captures" | wc -l | tr -d ' ') files"

# ---- docker, ports, the guard: the baselines ----------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run"
[ -z "$(dk ps -aq --filter name=^/c9u18- 2> /dev/null)" ] || die "a c9u18-* container exists before the run"
IMGD=$(dk images --digests --format '{{.Repository}}:{{.Tag}}@{{.Digest}}' 2> /dev/null | $G -xF "$IMG" || true)
[ "$IMGD" = "$IMG" ] || die "the presigner's image is not on the daemon by its digest (no pull here - a STOP): $IMG"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
BAND="21070 21071 21072 21073 21074 21075 21076 21077 21078 21079"
PORTS="18425 18881 18882 18883 18884 20578 20615 $BAND 21110 21111 21112 21113 21114 21115 21116 21117 21118 21119 21280 21281 21282 21283 21284"
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
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · nothing pulled · the presigner's image on the daemon by digest · no Testcontainers or c9u18-* container · ports free (21110-21119 included, never bound; 21079 free TCP and UDP)"

# ---- the trees, copied and built offline: before (through the link), after/; the harness's presigner; the blob classes -------------
M2="$PWD/.m2-demo"
if [ ! -d "$M2" ]; then [ -d "$SEED" ] || die "the seed $SEED is missing"; cp -cR "$SEED" "$M2" 2> /dev/null || cp -R "$SEED" "$M2" || die "the seed could not be copied"; fi
NF0=$(find "$M2" -type f | wc -l | tr -d ' '); NB0=$(find "$M2" -type f -print0 | xargs -0 stat -f %z | awk '{ s += $1 } END { printf "%d", s }')
CO=$(find "$M2" -name _remote.repositories -print0 | xargs -0 $G -l 'central-only' 2> /dev/null | wc -l | tr -d ' ')
[ "$CO" = 0 ] || die "$CO _remote.repositories files in the seed copy still name central-only"
ART="org/springframework/boot/spring-boot-starter-parent/4.1.3 org/springframework/hateoas/spring-hateoas/3.1.4 tools/jackson/core/jackson-databind/3.1.8 software/amazon/awssdk/s3/2.59.10 org/apache/maven/plugins/maven-dependency-plugin/3.10.0"
for a in $ART; do [ -n "$(ls "$M2/$a" 2> /dev/null | $G -E '\.(jar|pom)$')" ] || die ".m2-demo holds no $a (no seed act here: report the coordinates)"; done
echo "  .m2-demo (a copy of the seed m2-seed-c9-s3): files $NF0 · bytes $NB0 · _remote.repositories naming central-only: $CO"
for a in $ART; do echo "  seed | $a | $(ls "$M2/$a" | $G -E '\.(jar|pom)$' | paste -sd' ' -)"; done
mkdir -p .harness; for d in before after pkg tests webonly exercise run work client-before need-declared presign hc; do rm -rf .harness/$d; done
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
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \"$CPA\" harness/src/probe/u18/*.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness's blob classes did not compile against after/'s jar: $(head -5 .harness/javac.log)"
mkdir -p .harness/presign; cp harness/presign/pom.xml harness/presign/Presign.java .harness/presign/
guard "the harness's presigner build"
bg "cd .harness/presign && $MV -f pom.xml -DskipTests package" .harness/build-presign.log
[ "$RE" = 0 ] || { tail -30 .harness/build-presign.log | mask >&3; die "the harness's presigner did not build offline (exit $RE) - no seed act here: report the coordinates above"; }; offl .harness/build-presign.log
PRE=$RE
python3 -I - "$M2" .harness/presign/target/cp.txt .harness/presign/cp-container.txt <<'PY' || die "the presigner's class path could not be rewritten to /seed"
import sys
m2, src, dst = sys.argv[1:4]
es = open(src).read().strip().split(":")
out = []
for e in es:
    if not e.startswith(m2 + "/"):
        sys.exit("an entry outside the seed copy: " + e)
    out.append("/seed/" + e[len(m2) + 1:])
open(dst, "w").write(":".join(out) + "\n")
PY
echo "  the harness's presigner built offline (mvn -o -B -f harness/presign/pom.xml, exit $PRE, Downloading/Downloaded from: 0) · its class path rewritten to the container's /seed mount · the blob classes compiled against after/'s jar ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes) - never in either jar"
B() { echo "http://127.0.0.1:$1"; }
J=.harness/work
ALP='%m %U%q %s %b "%{Content-Type}o"'
# tb LABEL PORT LIFE [args]: TiffinBox (the extracted jar of TREE=after unless TREE is set), from its own run folder with a generated
# token (0600, never printed), H2 in memory (fresh per JVM), waited for by its Started line. LIFE: short = the harness's short lifetime
# on the command line (--tiffinbox.bill-link-lifetime=$SHORT), default = none (application.yaml's). ACC=1: Tomcat's access log. HX=1: the
# harness joined (--spring.main.sources=probe.u18.U18Config, its U18 harness line waited for).
tb() { local label=$1 port=$2 life=$3 t=${TREE:-after} run=.harness/run/$1 i=0; shift 3
  guard "TiffinBox $label"
  for q in 21071 21072 21074 21079; do [ "$(listeners $q)" = 0 ] && [ -z "$(lsof -nP -iUDP:$q 2> /dev/null)" ] || die "$q must stay free (TCP and UDP)"; done
  [ "$(listeners $port)" = 0 ] && [ -z "$(lsof -nP -iUDP:$port 2> /dev/null)" ] || die "$port is bound before $label"
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  local x="$U/.harness/$t/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  [ "$t" = after ] || [ "$t" = before ] || cp="$U/.harness/$t/tiffinbox-web/target/tiffinbox-web-1.0.0.jar"
  local fx=(); [ "$life" = short ] && fx=(--tiffinbox.bill-link-lifetime=$SHORT)
  local hx=(); [ -n "${HX:-}" ] && { cp="$cp:$U/.harness/hc"; hx=(--spring.main.sources=probe.u18.U18Config); }
  local ax=(); [ -n "${ACC:-}" ] && ax=(--server.tomcat.accesslog.enabled=true "--server.tomcat.accesslog.directory=$U/$run" --server.tomcat.accesslog.prefix=access --server.tomcat.accesslog.suffix=.log --server.tomcat.accesslog.rotate=false --server.tomcat.accesslog.buffered=false "--server.tomcat.accesslog.pattern=$ALP")
  local main=com.tiffinbox.web.TiffinBoxServer
  echo "java -cp <tree $t$( [ -n "${HX:-}" ] && echo ' + the harness classes')> $main --tiffinbox.port=$port ${fx[*]:-} ${hx[*]:-} $( [ -n "${ACC:-}" ] && echo '<the access log>') $*" > "$run/cmd"
  if [ "$t" = after ] || [ "$t" = before ]; then
    (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -cp "$cp" $main --tiffinbox.port="$port" "${fx[@]}" "${hx[@]}" "${ax[@]}" "$@" > jvm.log 2>&1) &
  else
    (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -jar "$cp" --tiffinbox.port="$port" "${fx[@]}" "${ax[@]}" "$@" > jvm.log 2>&1) &
  fi
  local p=$!; echo $p > "$run/pid"; PIDS="$PIDS $p"; MINE="${MINE:-} $port"
  while ! $G -q -E 'Started TiffinBox(App|Server) in' "$run/jvm.log" 2> /dev/null; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before its Started line"; }; i=$((i + 1)); [ $i -lt 900 ] || die "$label: no Started line"; sleep 0.1; done
  if [ -n "${HX:-}" ]; then i=0; while ! $G -q '^U18 harness: joined' "$run/jvm.log"; do i=$((i + 1)); [ $i -lt 100 ] || die "$label: no U18 harness line"; sleep 0.05; done; fi
  local dup; dup=$(tr ' ' '\n' < "$run/cmd" | $G -E '^--' | sed 's/=.*//' | sort | uniq -d | paste -sd, -); [ -z "$dup" ] || die "R.444: a flag twice on $label's command line ($dup)"
  [ "$life" = default ] || $G -qF -- "--tiffinbox.bill-link-lifetime=" "$run/cmd" || die "$label: lifetime=short without its flag on the command line"
  echo "  $label up on $port (H2, tree $t, lifetime=$life$( [ "$life" = short ] && echo " (the harness's)")$( [ -n "${HX:-}" ] && echo ", the harness joined (its U18 harness line printed)" || echo ", no harness class")$( [ -n "${ACC:-}" ] && echo ", the access log on")) · $(sed 's/ *$//' "$run/cmd")"; }
tbstop() { local label=$1 port=$2 run=.harness/run/$1 p i=0 how="POST /shutdown"; p=$(cat "$run/pid")
  if kill -0 "$p" 2> /dev/null; then printf 'X-Shutdown-Token: %s\n' "$(head -1 "$run/secrets/tiffinbox/shutdown-token")" | $CURL -s -o /dev/null --max-time 5 -H @- -X POST "$(B $port)/shutdown" || true; fi
  while kill -0 "$p" 2> /dev/null; do i=$((i + 1)); [ $i = 80 ] && { kill "$p" 2> /dev/null; how="its recorded pid (SIGTERM)"; }; [ $i -lt 400 ] || { kill -9 "$p" 2> /dev/null; break; }; sleep 0.05; done
  wait "$p" 2> /dev/null || true; PIDS=$(echo " $PIDS " | sed "s/ $p / /g"); MINE=$(echo " ${MINE:-} " | sed "s/ $port / /g")
  [ "$(listeners $port)" = 0 ] || die "$label: something still listens on $port"
  STOPHOW=$how; [ -z "${QUIET:-}" ] && echo "  $label stopped by $how"; true; }
NCAPS=0; unpub=""; VALS=""
cap() { local nm=$1; shift
  if [ -n "${DEVCAPS:-}" ] && ! echo " $DEVCAPS " | $G -qF " $nm "; then return 0; fi   # development only: a run of record sets no DEVCAPS
  "$@" > .harness/cap-$nm.raw 2>&1 || true
  $G -q '^  \*\*\* ' .harness/cap-$nm.raw && { cat .harness/cap-$nm.raw >&3; die "$nm stopped (above)"; }
  mask < .harness/cap-$nm.raw > .r-$nm.new
  sed 's/^/  | /' .r-$nm.new | cut -c1-260
  local o e=0; o=$(python3 -I -B harness/chk18.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk18 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; [ -n "${DEVCAPS:-}${NOPIN:-}" ] && { echo "  (development: $nm's check failed, the run goes on)"; unpub="$unpub $nm"; } || die "$nm: its check failed (harness/chk18.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk18.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-11s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-11s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff .r-$nm.new against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }
ck() { python3 -I -B harness/chk18.py "$@"; }
CB=/api/v1/customers; BR=/api/v1/billing-runs; OR=/api/v1/orders
hv() { local v; v=$(tr -d '\r' < "$1" | $G -i "^$2:" | head -1 | sed -E "s/^[^:]*: *//"); echo "${v:-}"; }
href() { python3 -I -c 'import json,sys
try: print(json.load(open(sys.argv[1]))["href"])
except Exception: print("")' "$1"; }
pj() { python3 -I -c '
import json,sys
try:
    d=json.load(open(sys.argv[1],encoding="utf-8"))
    if "timestamp" in d: d["timestamp"]="<masked>"
    print(" · ".join("%s=%s" % (k, d[k]) for k in ("type","title","detail","instance","status","error","path") if k in d) + (" · type absent (no type of TiffinBox'"'"'s)" if "type" not in d else ""))
except Exception as e: print("not JSON · type absent")' "$1"; }
# get PORT URI [curl args]: one GET; leaves $J/g.h and $J/g.b; sets GW (status content-type size)
get() { local port=$1 u=$2; shift 2; : > $J/g.h; : > $J/g.b
  GW=$($CURL --http1.1 -sS -D $J/g.h -o $J/g.b -w '%{http_code} %{content_type} %{size_download}' --max-time 30 "$@" "$(B $port)$u"); }
mintl() { get $1 "$CB/$2/bill-link"; LINK=$(href $J/g.b); MW=$GW; }
acclog() { cat .harness/run/$1/access*.log 2> /dev/null | sed -E 's/^([A-Z]+ [^ ]*)- /\1 /; s/ +$//'; }   # %q prints - for no query: dropped

# ---- the captures ----------------------------------------------------------------------------------------------------------------------
c_advisory() {
  echo "== S9.36: the read filed for this unit (ADV = _research/docs-2026-11-27/advisories, the orchestrator's dated act; not re-read: no network), before any capture"
  echo "  fetched-at $(head -1 "$ADV/fetched-at.txt" | cut -c1-10) (the hour masked) · run date $(date '+%Y-%m-%d')"
  local n=0 v=0 f h; while read -r h f; do n=$((n + 1)); [ "$(md5 -q "$ADV/$f" 2> /dev/null)" = "$h" ] && v=$((v + 1)); done < <($G -vE '^\s*$' "$ADV/MD5SUMS.txt" | awk '$2 != "MD5SUMS.txt" { print $1, $2 }')
  echo "  MD5SUMS.txt: $n lines, $v verified (its own line left out)"
  echo "  spring index: CVE ids on its first page $($G -oE 'CVE-[0-9]{4}-[0-9]+' "$ADV/spring-security-index.html" | sort -u | wc -l | tr -d ' ')"
  echo "  tomcat page md5 $(md5 -q "$ADV/tomcat-security-11.html")"
  echo "  verdict file: $(tail -1 "$ADV/VERDICT.txt")"
  local a; for a in spring-hateoas tomcat-embed-core jackson-databind spring-web spring-data-jpa spring-data-commons hibernate-core postgresql h2 httpclient5 httpcore5; do
    echo "  shipped | $a $(ls .harness/after/$XD/lib | $G -E "^$a-[0-9]" | sed -E "s/^$a-//; s/\.jar$//" | paste -sd, -)"; done
  echo "  shipped | awssdk jars in after/'s lib: $(ls .harness/after/$XD/lib | $G -cE '^(s3|sdk-core|aws-core|apache5-client|netty-nio-client)-2\.' || true)"
  python3 -I - "$ADV/osv-query.json" .harness/presign/target/cp.txt <<'PY'
import json, sys, os, re
q = json.load(open(sys.argv[1]))["queries"]
held = {(x["package"]["name"].split(":")[-1], x["version"]) for x in q}
cp = open(sys.argv[2]).read().strip().split(":")
co = []
for e in cp:
    v = os.path.basename(os.path.dirname(e)); a = os.path.basename(os.path.dirname(os.path.dirname(e)))
    co.append((a, v))
print("  harness | the presigner's class path: %d jars" % len(co))
for a, v in co:
    print("  harness | %s %s · in the read: %s" % (a, v, "yes" if (a, v) in held else "no"))
miss = [("%s %s" % c) for c in co if c not in held]
print("  harness | not in the read's %d coordinates: %d - %s (not read, not said)" % (len(q), len(miss), ", ".join(miss)))
PY
  echo "  osv (second witness only, S2.8): $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); r=d.get("results",[]); print("%d results, %d with vulns" % (len(r), sum(1 for x in r if x.get("vulns"))))' "$ADV/osv-result.json")"
  echo "  lib names before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ') · name lists $(cmp -s <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) && echo equal || echo differ)"
  echo "  verdict: no pin affected; evidence may proceed; this unit adds no jar; the harness's coordinates not in the read are named, not said"; }
mappings() { $CURL -s "$(B $1)/actuator/mappings" | python3 -I -c '
import json,sys
d=json.load(sys.stdin); ps=[]
for c in d["contexts"].values():
    for m in c["mappings"]["dispatcherServlets"]["dispatcherServlet"]:
        rc=(m.get("details") or {}).get("requestMappingConditions")
        if rc: ps += [p for p in rc.get("patterns", [])]
print("  %s | mappings %d · with bill in the path %d: %s (rule: the request-mapping patterns of the dispatcher servlet)" % (sys.argv[1], len(ps), sum(1 for p in ps if "bill" in p and "billing" not in p), sorted(p for p in ps if "bill" in p and "billing" not in p)))' "$2"; }
gone() { local lab=$1 port=$2 m=$3 p=$4 w; w=$($CURL --http1.1 -sS -D $J/b.h -o $J/b.b -w '%{http_code} %{content_type}' --max-time 10 -X "$m" "$(B $port)$p")
  echo "  $lab | $m $(echo "$p" | sed -E 's/[0-9a-f-]{36}$/<uuid>/') -> $w · Allow {$(tr -d '\r' < $J/b.h | sed -n 's/^[Aa]llow: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)}"; }
c_before() {
  echo "== before (21076, U17's after, H2, lifetime=default - the setting does not exist there; the harness's exposure flag for /actuator/mappings)"
  TREE=before tb before 21076 default --management.endpoints.web.exposure.include=health,prometheus,mappings
  gone before 21076 GET $CB/Ravi/bill; gone before 21076 GET $CB/Ravi/bill-link; gone before 21076 GET "$CB/Ravi/bill/signed?expires=1&sig=x"
  local p w; for p in $OR/1 /api/v1/customers/Ravi $BR/00000000-0000-0000-0000-000000000000; do w=$($CURL --http1.1 -sS -o $J/o.b -w '%{http_code} %{content_type} %{size_download}' "$(B 21076)$p"); echo "  before | GET $(echo "$p" | sed -E 's/[0-9a-f-]{36}$/<uuid>/') -> $w · file $(wc -c < $J/o.b | tr -d ' ') B$(echo "$p" | $G -q billing && echo " · $(pj $J/o.b | cut -d' ' -f1)")"; done
  mappings 21076 before
  echo "  before | the committed spec: $(python3 -I harness/ops9s3.py ops before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tail -1) · $(wc -c < before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tr -d ' ') B md5 $(md5 -q before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json)"
  echo "  before | BOOT-INF/lib names $(ls .harness/before/$XD/lib | wc -l | tr -d ' ')"
  QUIET=1 tbstop before 21076; }
census() { python3 -I - "$1/tiffinbox-web/src/main/java/com/tiffinbox/web" "$2" <<'PY'
import os, re, sys
d, side = sys.argv[1], sys.argv[2]
print("  census %s | rule (unit 15's, copied off unit 17's receipts): a class whose annotation lines (the lines between the Javadoc's end and its declaration) include exactly @RestController or @Controller; its final modifier; @Profile(\"dev\") among those lines" % side)
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
    print("  census %s | excluded by the rule: %s (%s:%d) - annotated @RestControllerAdvice" % ((side,) + e))
fd = sum(1 for r in rows if r[1] and not r[2]); nd = sum(1 for r in rows if not r[1] and r[2]); nf = sum(1 for r in rows if not r[1] and not r[2])
print("  census %s | controllers %d · final, default-run %d · not final, default-run %d · not final, dev-only %d · other %d" % (side, len(rows), fd, nf, nd, len(rows) - fd - nd - nf))
PY
}
c_census() { echo "== the controllers on before and after/ (R.527: each derived on its own tree)"; census before before; census after after; }
CBJ=tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerBills.java
c_change() {
  echo "== the modules, the change file by file"
  echo "  modules: $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' before/pom.xml | paste -sd' ' -) ($($G -c '<module>' before/pom.xml)) -> $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' after/pom.xml | paste -sd' ' -) ($($G -c '<module>' after/pom.xml))"
  local pm; pm=$(for p in pom.xml tiffinbox-core/pom.xml tiffinbox-web/pom.xml tiffinbox-client/pom.xml; do cmp -s before/$p after/$p || echo $p; done | paste -sd' ' -)
  echo "  poms before -> after/: ${pm:-equal}"
  echo "  changed (derived: diff -rq before after/, the frozen trees - git status --short gave the same list before the commit): $(diff -rq before/ after/ | sed -E 's#^Files before/(.*) and after/.* differ$#M \1#; s#^Only in after/(.*): (.*)$#A \1/\2#; s#^Only in after/: (.*)$#A \1#; s#^Only in before/(.*): (.*)$#D \1/\2#' | sort | paste -sd'~' - | sed 's/~/ · /g')"
  local f; for f in $CBJ tiffinbox-web/src/test/java/com/tiffinbox/web/CustomerBillsTest.java; do
    echo "== $f (whole, md5 $(md5 -q after/$f))"; sed 's/^/    /' after/$f; done
  echo "== application.yaml: the diff against before's"
  diff before/tiffinbox-web/src/main/resources/application.yaml after/tiffinbox-web/src/main/resources/application.yaml | sed 's/^/    /'
  for k in 'ResponseEntity<?>' 'ResponseEntity<Object>'; do echo "  CustomerBills grep $k: $($G -cF "$k" after/$CBJ || true) lines · src/main before $(cd before && $G -rhF "$k" tiffinbox-web/src/main | wc -l | tr -d ' ') · after $(cd after && $G -rhF "$k" tiffinbox-web/src/main | wc -l | tr -d ' ') (the old routes' own)"; done
  for k in JsonView MappingJacksonValue Pageable 'offset(' Probe /probe/ ttlSeconds awssdk; do echo "  src/main grep $k: $(cd after && $G -rhF "$k" tiffinbox-web/src/main tiffinbox-core/src/main | $G -vcE '^[[:space:]]*(\*|//|/\*)' || true) code lines"; done
  echo "  CustomerBills: $($G -E '^(public )?(final )?class CustomerBills' after/$CBJ)"
  echo "  the declared types of the shipped handlers: $($G -oE '^    [A-Za-z<>]+ (bill|billLink|signedBill)\(' after/$CBJ | sed 's/^ *//; s/($//' | paste -sd'|' -)"
  echo "  the checks' order in signedBill: $(awk '/signedBill\(/,/^    }$/' after/$CBJ | $G -oE 'refuseParameters|link-malformed|MessageDigest\.isEqual|link-expired|csv\(customer' | paste -sd' ' -)"
  for n in BillingRuns OrderResources OrderPages CustomerReads CustomerFields CustomerNotFound CustomerImport TiffinBoxErrors IdempotencyKeyFilter; do echo "  $n.java byte-equal to before's: $(cmp -s before/tiffinbox-web/src/main/java/com/tiffinbox/web/$n.java after/tiffinbox-web/src/main/java/com/tiffinbox/web/$n.java && echo yes || echo no)"; done
  for k in compression forward-headers hateoas billing pause bill-link-lifetime bill-link-key; do echo "  application.yaml $k keys: before $($G -c "$k" before/tiffinbox-web/src/main/resources/application.yaml || true) · after $($G -c "$k" after/tiffinbox-web/src/main/resources/application.yaml || true)"; done
  for h in bill billLink signedBill startBillingRun billingRun; do echo "  handler $h: $(cd after && $G -rhE -A3 '@(Get|Post|Put|Patch|Delete|Request)Mapping' tiffinbox-web/src/main/java | $G -cE " $h\(") occurrence(s) among the mapped handlers"; done
  echo "  the bill's rows: $($G -cE '^        r\[' after/$CBJ) row writers · DAYS = $($G -oE 'static final int DAYS = [0-9]+' after/$CBJ | awk '{ print $NF }') · monthlyBill(): $($G -A1 'public int monthlyBill()' after/tiffinbox-core/src/main/java/com/tiffinbox/Customer.java | tail -1 | sed 's/^ *//') · application.yaml's tiffinbox.days $($G -E '^  days:' after/tiffinbox-web/src/main/resources/application.yaml | awk '{ print $2 }') (the dev fill's, not read by the bill)"
  $G "^INSERT INTO customer" after/tiffinbox-core/src/main/resources/db/migration/V2__seed.sql | sed -E "s/.*VALUES \('([A-Za-z]+)', ([0-9]+), ([0-9]+), .*/\1 \2 \3/" | sort | while read -r n m p; do echo "  V2 row: $n meals $m price $p -> $((m * p * 30))"; done
  echo "  ProblemDetail.forStatus calls in src/main (unit 03's instance view greps them): before $(cd before && $G -rc 'ProblemDetail\.forStatus' tiffinbox-web/src/main | awk -F: '{ s += $2 } END { print s }') · after $(cd after && $G -rc 'ProblemDetail\.forStatus' tiffinbox-web/src/main | awk -F: '{ s += $2 } END { print s }')"
  echo "  routes that throw CustomerNotFound (R.510): before $(cd before && $G -rlF 'new CustomerNotFound' tiffinbox-web/src/main | sed 's#.*/##' | sort | paste -sd, -) · after $(cd after && $G -rlF 'new CustomerNotFound' tiffinbox-web/src/main | sed 's#.*/##' | sort | paste -sd, -)"; }
c_harness() {
  echo "== the harness: the presigner (harness/presign) and the blob route (harness/src/probe/u18) - never in a tiffinbox pom, module or jar"
  echo "  presign | build: mvn -o -B -f harness/presign/pom.xml -DskipTests package (a copy under .harness/presign) · exit 0 · Downloading from: $($G -cE 'Download(ing|ed) from ' .harness/build-presign.log || true)"
  echo "  presign | the POM's parent: $(sed -n '/<parent>/,/<\/parent>/p' harness/presign/pom.xml | $G -oE '<(artifactId|version)>[^<]*' | sed 's/<[a-zA-Z]*>//' | paste -sd' ' -) · awssdk.version $(sed -n 's#.*<awssdk.version>\(.*\)</awssdk.version>.*#\1#p' harness/presign/pom.xml) · its R.515 comment names the parent line: $($G -c 'spring-boot-starter-parent 4.1.3' harness/presign/pom.xml) · the measured surface: $($G -c 'X-Amz-\* query keys' harness/presign/pom.xml) · the word compatible: $($G -ci 'compatible' harness/presign/pom.xml || true)"
  echo "  presign | the class path: $(python3 -I -c 'import sys; print(len(open(sys.argv[1]).read().strip().split(":")))' .harness/presign/target/cp.txt) jars · rewritten to /seed: $(python3 -I -c 'import sys; print(sum(1 for e in open(sys.argv[1]).read().strip().split(":") if e.startswith("/seed/")))' .harness/presign/cp-container.txt) · the SDK: $(tr ':' '\n' < .harness/presign/target/cp.txt | $G -oE '/(s3|apache5-client|netty-nio-client|apache-client)-[0-9.]+\.jar' | sed 's#^/##; s#\.jar$##' | paste -sd' ' -) · httpclient5 $(tr ':' '\n' < .harness/presign/target/cp.txt | $G -oE 'httpclient5-[0-9.]+\.jar' | sed 's/httpclient5-//; s/\.jar//')"
  echo "  presign | Presign.java against the probe's (PK3/instruments/Presign.java md5 $(md5 -q "$PK3/instruments/Presign.java")): the named diff, md5 $(diff "$PK3/instruments/Presign.java" harness/presign/Presign.java | md5 -q), $(diff "$PK3/instruments/Presign.java" harness/presign/Presign.java | $G -c '^[<>]') lines"
  diff "$PK3/instruments/Presign.java" harness/presign/Presign.java | $G '^[<>]' | sed -E 's/create\("[^"]*", "[^"]*"\)/create("<a fake test credential>", "<a fake test credential>")/' | cut -c1-200 | sed 's/^/  presign | diff /'
  echo "  blob | U18Config.java against unit 16's U16Config.java (md5 $(md5 -q ../c9-unit16/harness/src/probe/u16/U16Config.java)): the named diff md5 $(diff ../c9-unit16/harness/src/probe/u16/U16Config.java harness/src/probe/u18/U18Config.java | md5 -q), $(diff ../c9-unit16/harness/src/probe/u16/U16Config.java harness/src/probe/u18/U18Config.java | $G -c '^[<>]') lines"
  echo "  blob | U18Blob's route: $($G -oE '@GetMapping\("[^"]*"\)' harness/src/probe/u18/U18Blob.java) · compiled by javac against after/'s extracted lib: $(find .harness/hc -name '*.class' | sed 's#.*/##' | sort | paste -sd' ' -)"
  echo "  jar | SDK classes in after/'s web jar: $(unzip -l .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | $G -cE 'software/amazon|awssdk' || true) · probe classes: $(unzip -l .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | $G -cE 'probe/' || true) · the anchor's poms naming awssdk: $(cd after && $G -l awssdk pom.xml */pom.xml | wc -l | tr -d ' ')"; }
c_proxy() {
  echo "== proxy: the bill on the wire (after/, 21070, H2, lifetime=default, the access log on; the host 127.0.0.1:<port>)"
  ACC=1 tb proxy 21070 default
  get 21070 $CB/Ravi/bill
  echo "  proxy | GET $CB/Ravi/bill -> $GW · status line $(head -1 $J/g.h | tr -d '\r' | sed -E 's/^(HTTP\/1\.1 [0-9]{3}) *$/\1 <none>/')"
  tr -d '\r' < $J/g.h | $G -v '^$' | sed -E 's/^(Date): .*/\1: <masked>/; s/^/  proxy | header /'
  echo "  proxy | Content-Length: $( [ -n "$(hv $J/g.h Content-Length)" ] && echo present || echo absent) · Transfer-Encoding: $(hv $J/g.h Transfer-Encoding)"
  cp $J/g.b $J/bill-Ravi.csv
  echo "  proxy | the saved file: $(wc -c < $J/bill-Ravi.csv | tr -d ' ') B · $(wc -l < $J/bill-Ravi.csv | tr -d ' ') lines · md5 $(md5 -q $J/bill-Ravi.csv)"
  echo "  proxy | first lines: $(head -2 $J/bill-Ravi.csv | paste -sd'|' -) · last line: $(tail -1 $J/bill-Ravi.csv)"
  python3 -I - $J/bill-Ravi.csv after/tiffinbox-core/src/main/resources/db/migration/V2__seed.sql > $J/c6.txt <<'PY'
import re, sys
# Course 6 unit 20's rows(), rebuilt by python from ../c6-unit20/harness/probe/web/Files.java's lines 82-90 (read, never copied into the jar)
v2 = {m.group(1): (int(m.group(2)), int(m.group(3))) for m in re.finditer(r"VALUES \('([A-Za-z]+)', (\d+), (\d+),", open(sys.argv[2]).read())}
m, p = v2["Ravi"]
r = ["day,customer,meals,price per meal,amount"] + ["%d,Ravi,%d,%d,%d" % (d, m, p, m * p) for d in range(1, 31)] + ["month,Ravi,%d,%d,%d" % (m * 30, p, m * p * 30)]
s = "".join(x + "\n" for x in r)
w = open(sys.argv[1], encoding="utf-8").read()
print("  proxy | Course 6's rows for Ravi (rows(), rebuilt from V2's row %s %s): %d B, %d lines · diff against the wire's file: %s" % (m, p, len(s.encode()), len(r), "empty" if s == w else "DIFFERS"))
print("  proxy | the total row against monthlyBill(): %s = %d * %d * 30 = %d" % (w.strip().splitlines()[-1].split(",")[-1], m, p, m * p * 30))
PY
  cat $J/c6.txt
  sleep 0.2; acclog proxy | sed 's/^/  proxy | access log: /'
  echo "  proxy | the three byte witnesses: curl's size_download $(echo $GW | awk '{ print $3 }') · the saved file's wc -c $(wc -c < $J/bill-Ravi.csv | tr -d ' ') · the access log's %b $(acclog proxy | $G -F "$CB/Ravi/bill" | awk '{ print $4 }')"
  echo "  proxy | Course 6's own capture (../c6-unit20/README.md, read): $($G -oE 'one chunk of [0-9]+ bytes' ../c6-unit20/README.md | head -1)"
  QUIET=1 tbstop proxy 21070
  echo "== proxy: the harness's blob route (21077, the harness joined - a harness-joined start; no claim about the shipped routes is read from it)"
  HX=1 ACC=1 tb blob 21077 default
  get 21077 "/probe/u18/blob?mib=8"
  echo "  blob | the harness's blob route GET /probe/u18/blob?mib=8 -> $GW · Transfer-Encoding: $(hv $J/g.h Transfer-Encoding) · Content-Length: $( [ -n "$(hv $J/g.h Content-Length)" ] && echo present || echo absent) · the saved file's wc -c $(wc -c < $J/g.b | tr -d ' ') · the access log's %b $(acclog blob | $G -F '/probe/u18/blob' | awk '{ print $4 }') · host 127.0.0.1:<port>"
  echo "  blob | the JVM log (the pattern '^U18 harness: '): $($G -E '^U18 harness: ' .harness/run/blob/jvm.log | paste -sd'|' -)"
  QUIET=1 tbstop blob 21077; }
c_declared() {
  echo "== declared: the failure receipt - a scratch copy of after/ with the exercise's break.sh (the signed download declared ResponseEntity<?>), built, started on 21073 (H2, lifetime=default); then after/ itself on 21070"
  copy after .harness/need-declared
  sh exercise/break.sh .harness/need-declared
  guard "the declared copy's build"
  bg "cd .harness/need-declared && $MV -DskipTests clean package -pl tiffinbox-web -am" .harness/build-declared.log; offl .harness/build-declared.log
  echo "  declared | built the scratch copy (mvn -o -DskipTests clean package -pl tiffinbox-web -am): exit $RE"
  echo "  declared | the copy's declaration: $($G -oE '^    [A-Za-z<>?]+ signedBill\(' .harness/need-declared/$CBJ | sed 's/^ *//; s/($//') · after/'s: $($G -oE '^    [A-Za-z<>?]+ signedBill\(' after/$CBJ | sed 's/^ *//; s/($//')"
  TREE=need-declared tb declared 21073 default
  local n0; n0=$(wc -l < .harness/run/declared/jvm.log | tr -d ' ')
  mintl 21073 Ravi; echo "  declared | the copy | mint -> ${MW%% *} · href $LINK"
  get 21073 "$LINK"; echo "  declared | the copy | the signed download -> $GW · $(pj $J/g.b)"
  sleep 0.3; echo "  declared | the copy | JVM log lines after the start (a printed grep 'Failed to write|HttpMessageNotWritable|No converter'): $(sed -n "$((n0 + 1)),\$p" .harness/run/declared/jvm.log | $G -cE 'Failed to write|HttpMessageNotWritable|No converter' || true)"
  sed -n "$((n0 + 1)),\$p" .harness/run/declared/jvm.log | $G -E 'WARN|ERROR' | $G -v 'SpringDocAppInitializer' | sed -E 's/^[^ ]+ +//; s/^([A-Z]+) [0-9]+ /\1 <n> /' | cut -c1-220 | sed 's/^/  declared | the copy | log: /'
  get 21073 $CB/Ravi/bill; echo "  declared | the copy | the bill route on the same JVM -> $GW"
  QUIET=1 tbstop declared 21073
  tb declared-after 21070 default > /dev/null
  mintl 21070 Ravi; get 21070 "$LINK"; echo "  declared | after/ | its own freshly minted link (each start its own key: the same requests, not the same link) -> $GW"
  QUIET=1 tbstop declared-after 21070; }
c_signed() {
  echo "== signed: TiffinBox's own link (after/, 21070, H2, lifetime=default, anonymous: no cookie, no credential)"
  tb signed 21070 default
  local t0 t1 L1 e; t0=$(python3 -I -c 'import time; print(repr(time.time()))'); mintl 21070 Ravi; t1=$(python3 -I -c 'import time; print(repr(time.time()))'); L1=$LINK
  echo "  signed | (i) mint Ravi -> $MW · href $L1 · body members $(python3 -I -c 'import json,sys; print(list(json.load(open(sys.argv[1]))))' $J/g.b) · the href a path: $(echo "$L1" | $G -q '^/api/' && echo yes || echo no)"
  get 21070 "$L1"; cp $J/g.b $J/signed-Ravi.csv; local cd1; cd1=$(hv $J/g.h Content-Disposition)
  get 21070 $CB/Ravi/bill; local cd2; cd2=$(hv $J/g.h Content-Disposition)
  get 21070 "$L1"; echo "  signed | (i) open it -> $GW · body md5 $(md5 -q $J/signed-Ravi.csv) · the bill route's body md5 $(md5 -q $J/g.b) · equal: $(cmp -s $J/signed-Ravi.csv $J/g.b && echo yes || echo no) · Content-Disposition equal: $( [ "$cd1" = "$cd2" ] && echo yes || echo no)"
  get 21070 "$(echo "$L1" | sed 's#/customers/Ravi/#/customers/Sunil/#')"; echo "  signed | (ii) the name changed (Ravi -> Sunil, expires and sig kept) -> $GW · $(pj $J/g.b)"
  e=$(echo "$L1" | sed -E 's/.*expires=([0-9]+)&.*/\1/')
  get 21070 "$(echo "$L1" | sed "s/expires=$e/expires=$((e + 86400))/")"; echo "  signed | (iii) expires raised by a day's seconds, the old sig kept -> $GW · $(pj $J/g.b)"
  local sg; sg=$(echo "$L1" | sed -E 's/.*sig=//'); local sx; sx=$(python3 -I -c 'import sys; s=sys.argv[1]; print(s[:-1] + ("A" if s[-1] != "A" else "B"))' "$sg")
  get 21070 "${L1%sig=*}sig=$sx"; echo "  signed | (iv) one character of sig changed -> $GW · $(pj $J/g.b)"
  python3 -I - "$e" "$t0" "$t1" after/tiffinbox-web/src/main/resources/application.yaml .harness/run/signed/jvm.log <<'PY'
import re, sys, math
e, t0, t1 = int(sys.argv[1]), float(sys.argv[2]), float(sys.argv[3])
y = re.search(r"^  bill-link-lifetime: (\d+)([smh])$", open(sys.argv[4]).read(), re.M)
ly = int(y.group(1)) * {"s": 1, "m": 60, "h": 3600}[y.group(2)] if y else -1
g = re.search(r"the bill link's lifetime: PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)? \(tiffinbox\.bill-link-lifetime\)", open(sys.argv[5]).read())
lg = (int(g.group(1) or 0) * 3600 + int(g.group(2) or 0) * 60 + int(g.group(3) or 0)) if g else -2
inb = math.floor(t0) + ly <= e <= math.floor(t1) + ly
print("  signed | (v) the lifetime read back: application.yaml's line <masked> · the start's log line <masked> · the mint's expires within [the harness's clock before + it, after + it]: %s · the three equal: %s" % ("yes" if inb else "no", "yes" if (ly == lg and inb) else "no"))
print("  signed | (v) the start's log lines: %s" % re.sub(r"PT[0-9HMS.]+", "<lifetime>", " | ".join(l.split(" : ", 1)[-1].strip() for l in open(sys.argv[5]) if "the bill link's" in l)))
PY
  get 21070 "$CB/Ravi/bill-link?ttlSeconds=315360000"; echo "  signed | (vi) the planted client lifetime (ttlSeconds, the BLUE value) on the same JVM -> $GW · $(pj $J/g.b) · a minted href in the answer: $( [ -n "$(href $J/g.b)" ] && echo yes || echo no)"
  mintl 21070 Sunil; local L8=$LINK; get 21070 "$L8"; echo "  signed | (viii) the mint is open: no credential minted Sunil's link -> ${MW%% *} · opening it -> $GW"
  QUIET=1 tbstop signed 21070
  echo "== signed: the expiry waited out (21075, lifetime=short - the harness's short lifetime, the shipped setting on the command line)"
  tb signed-short 21075 short
  mintl 21075 Ravi; local LS=$LINK; get 21075 "$LS"; echo "  signed | (vii) minted -> ${MW%% *} · opened at once after the mint -> ${GW%% *} (valid when minted)"
  local end s n=0; end=$(( $(date +%s) + 30 )); ALARM=not-hit
  while :; do get 21075 "$LS"; s=${GW%% *}; n=$((n + 1)); echo "  ~ signed | (vii) poll -> $s"; [ "$s" = 200 ] || break
    [ "$(date +%s)" -lt "$end" ] || { ALARM=hit; break; }; sleep 0.5; done
  echo "  signed | (vii) polled by its condition (status not 200 ends it; a 30 s alarm, a guard; the guard interval slept between polls) -> the first refusal $GW · $(pj $J/g.b) · alarm $ALARM"
  get 21075 "$LS"; echo "  signed | (vii) the same link once more -> $GW · $(pj $J/g.b | cut -d' ' -f1)"
  local st; st=$(echo "$LS" | sed -E 's/.*sig=//'); local sy; sy=$(python3 -I -c 'import sys; s=sys.argv[1]; print(s[:-1] + ("A" if s[-1] != "A" else "B"))' "$st")
  get 21075 "${LS%sig=*}sig=$sy"; echo "  signed | (iv) tampered AND expired -> $GW · $(pj $J/g.b | cut -d' ' -f1)"
  QUIET=1 tbstop signed-short 21075
  echo "== signed: a link from another start (C3 (a): the key is this start's) - minted on 21070, that JVM stopped, the same link on a fresh start of the same jar (21075, lifetime=default)"
  tb restart-1 21070 default > /dev/null; mintl 21070 Ravi; local LR=$LINK; get 21070 "$LR"; echo "  signed | (ix) JVM-1 mint -> ${MW%% *} · open -> ${GW%% *}"; QUIET=1 tbstop restart-1 21070
  tb restart-2 21075 default > /dev/null; get 21075 "$LR"; echo "  signed | (ix) JVM-2 the same link -> $GW · $(pj $J/g.b | cut -d' ' -f1)"; QUIET=1 tbstop restart-2 21075
  echo "  signed | the link key and the fake test credential in this run's captures so far: $(cat .harness/cap-*.raw 2> /dev/null | $G -cF -e "$(printf '%s' "$FK" | cut -d'|' -f1)" -e "$(printf '%s' "$FK" | cut -d'|' -f2)" || true) lines (the key is never logged: the JVM logs' key lines $(cat .harness/run/*/jvm.log | $G -c "the bill link's key: defaulted" || true), each 'defaulted')"; }
sealed() { local mode=$1 nm=c9u18-presign-$1 rc
  for q in 21079; do [ "$(listeners $q)" = 0 ] && [ -z "$(lsof -nP -iUDP:$q 2> /dev/null)" ] || die "21079 is bound before the sealed run"; done
  guard "the sealed presigner, $mode"
  echo "  $SIDE | docker run line: dk run --name $nm --network none --pull never -v <the seed copy>:/seed:ro -v <the harness's classes>:/h:ro -v <the class path file>:/r:ro --entrypoint sh $IMG -c '<the three prints, then java>' $mode (no published port)"
  CTRS="$CTRS $nm"
  dk run --name $nm --network none --pull never -v "$M2:/seed:ro" -v "$U/.harness/presign/target/classes:/h:ro" -v "$U/.harness/presign/cp-container.txt:/r/cp.txt:ro" --entrypoint sh "$IMG" -c 'echo "== /proc/net/dev"; cat /proc/net/dev; echo "== /proc/net/route"; cat /proc/net/route; echo "== the presigner"; exec java -cp "/h:$(cat /r/cp.txt)" probe.u18.Presign "$0"' $mode > $J/sealed-$mode.txt 2>&1; rc=$?
  dk inspect -f '{{.HostConfig.NetworkMode}} {{.HostConfig.PublishAllPorts}} {{len .NetworkSettings.Ports}}' $nm 2> /dev/null | sed "s/^/  $SIDE | inspect: network mode, publish-all, ports: /"
  dk rm -fv $nm > /dev/null 2>&1; CTRS=$(echo " $CTRS " | sed "s/ $nm / /g")
  echo "  $SIDE | container exit $rc · removed: dk rm -fv $nm · left: $(dk ps -aq --filter name=^/$nm\$ | wc -l | tr -d ' ')"
  sed -E 's/^/  '"$SIDE"' | /' $J/sealed-$mode.txt | sed -E 's/[Ii]nstanceProfileRegionProvider@[0-9a-f]+/InstanceProfileRegionProvider@<id>/g; s/(Provider|Chain)@[0-9a-f]+/\1@<id>/g' | cut -c1-2400
  python3 -I - $J/sealed-$mode.txt "$SIDE" <<'PY'
import sys
t = open(sys.argv[1]).read().split("== ")
dev = [s for s in t if s.startswith("/proc/net/dev")][0].splitlines()[3:]
route = [s for s in t if s.startswith("/proc/net/route")][0].splitlines()[2:]
ifs = [l.split(":")[0].strip() for l in dev if ":" in l]
print("  %s | before any Java: interfaces %s · route rows %d · the presigner's line after both: %s" % (sys.argv[2], ifs, len([r for r in route if r.strip()]), "yes" if t[-1].startswith("the presigner") else "no"))
PY
  [ "$(listeners 21079)" = 0 ] && [ -z "$(lsof -nP -iUDP:21079 2> /dev/null)" ] || die "21079 is bound after the sealed run"; }
c_presign() {
  echo "== presign: the harness's presigner with a fake test credential, inside a container with no network (by digest, pull never, the seed copy read-only) - fresh per mode"
  SIDE=presign sealed static; }
c_defaults() {
  echo "== defaults: the harness's presigner left to the SDK's defaults, inside a container with no network - fresh per mode"
  SIDE=defaults sealed regiononly; SIDE=defaults sealed default; }
c_expect() {
  echo "== expect: Expect: 100-continue on the OLD route POST /customers/import (after/, 21070, H2, lifetime=default) - not a witness for the new routes"
  tb expect 21070 default > /dev/null
  python3 -I -c '
import sys
with open(sys.argv[1], "w") as f:
    f.write("name,mealsPerDay,pricePerMeal,mealType\n"); i = 0
    while f.tell() < 2 * 1024 * 1024: f.write("C%07d,1,100,VEG\n" % i); i += 1' $J/big.csv
  echo "  expect | the harness's CSV: $(wc -c < $J/big.csv | tr -d ' ') B · curl $(curl --version | head -1 | cut -d' ' -f2)"
  local w; w=$($CURL --http1.1 -sS -v --trace-ascii $J/trace.txt -D $J/e.h -o $J/e.b -w '%{http_code} %{content_type} %{size_upload} %{size_request}' -F "file=@$J/big.csv;type=text/csv;filename=big.csv" "$(B 21070)/customers/import" 2> /dev/null)
  echo "  expect | POST /customers/import -> $(echo $w | awk '{ print $1, $2 }') · host 127.0.0.1:<port>"
  python3 -I - $J/trace.txt "$(echo $w | awk '{ print $3 }')" "$(wc -c < $J/big.csv | tr -d ' ')" <<'PY'
import sys, re
ls = open(sys.argv[1], encoding="latin-1").read().splitlines()
ev = []; sent = 0; first_data = None; cur = None; hdr = None
for i, l in enumerate(ls):
    if l.startswith("=> Send header"): cur = "sh"
    elif l.startswith("<= Recv header"): cur = "rh"
    elif l.startswith("=> Send data"):
        cur = "sd"; n = int(re.search(r"(\d+) bytes", l).group(1)); sent += n
        if first_data is None: first_data = len(ev); ev.append("the first body bytes sent")
    elif l.startswith("<= Recv data") or l.startswith("== Info"): cur = None
    elif cur == "sh" and re.search(r"Expect: 100-continue", l): ev.append("the request's Expect: 100-continue header")
    elif cur == "rh" and re.search(r": HTTP/1\.1 (\d{3})", l):
        ev.append("curl's receipt of HTTP/1.1 " + re.search(r": HTTP/1\.1 (\d{3})", l).group(1))
print("  expect | the order of the events in curl's trace (--trace-ascii, no time): " + " -> ".join(ev))
print("  ~ expect | curl's size_upload %s · the trace's Send data bytes %d · the CSV's %s B · the whole body sent before the 413: %s" % (sys.argv[2], sent, sys.argv[3], "yes" if sent > int(sys.argv[3]) else "no"))
PY
  echo "  expect | the 413's body: $(pj $J/e.b) · Content-Type $(hv $J/e.h Content-Type | tail -1)"
  local w2; w2=$($CURL --http1.1 -sS -v --trace-ascii $J/trace2.txt -o /dev/null -w '%{http_code}' -H 'Expect:' -F "file=@$J/big.csv;type=text/csv;filename=big.csv" "$(B 21070)/customers/import" 2> /dev/null)
  echo "  expect | the same with -H 'Expect:' (no Expect header) -> $w2 · an HTTP/1.1 100 in its trace: $($G -c ': HTTP/1.1 100' $J/trace2.txt || true)"
  python3 -I - .harness/after/$XD/lib after/tiffinbox-web/src/main/resources/application.yaml <<'PY'
import sys, os, zipfile, json
d = sys.argv[1]; hit = []
for f in sorted(os.listdir(d)):
    if not f.startswith("spring-boot"): continue
    try:
        z = zipfile.ZipFile(os.path.join(d, f)); m = json.loads(z.read("META-INF/spring-configuration-metadata.json"))
    except Exception: continue
    for p in m.get("properties", []):
        if p.get("name") == "spring.servlet.multipart.max-file-size": hit.append((f, p.get("defaultValue")))
print("  expect | the limit read back: spring.servlet.multipart.max-file-size in Boot's metadata: %s · application.yaml overrides it: %s" % (hit or "not found", "yes" if "multipart" in open(sys.argv[2]).read() else "no"))
PY
  QUIET=1 tbstop expect 21070; }
prq() { local lab=$1 m=$2 q=$3 w; shift 3
  w=$($CURL --http1.1 -sS -D $J/pr.h -o $J/pr.b -w '%{http_code} %{content_type}' --max-time 10 -X "$m" "$@" "$(B 21070)$q")
  echo "  refuse | $lab ($m $(echo "$q" | sed -E 's/expires=[0-9]+/expires=<masked>/; s/sig=[A-Za-z0-9_-]+/sig=<masked>/')) -> $w | $(pj $J/pr.b) · Allow {$(tr -d '\r' < $J/pr.h | sed -n 's/^[Aa]llow: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)}"; }
c_refuse() {
  echo "== refuse: every refusal of the three routes (after/, 21070, H2, lifetime=default)"
  tb refuse 21070 default > /dev/null
  mintl 21070 Ravi; local L=$LINK e; e=$(echo "$L" | sed -E 's/.*expires=([0-9]+)&.*/\1/'); local sg; sg=$(echo "$L" | sed -E 's/.*sig=//')
  prq "an unknown customer on the bill" GET $CB/Nobody/bill
  prq "an unknown customer on the mint" GET $CB/Nobody/bill-link
  prq "an unknown customer on the signed download, its own link's sig" GET "$CB/Nobody/bill/signed?expires=$e&sig=$sg"
  prq "a query parameter on the bill" GET "$CB/Ravi/bill?x=1"
  prq "a query parameter on the mint" GET "$CB/Ravi/bill-link?x=1"
  prq "ttlSeconds on the mint" GET "$CB/Ravi/bill-link?ttlSeconds=315360000"
  prq "a query parameter on the signed download" GET "$L&x=1"
  prq "the name changed in the link" GET "$(echo "$L" | sed 's#/customers/Ravi/#/customers/Sunil/#')"
  prq "expires raised" GET "$(echo "$L" | sed "s/expires=$e/expires=$((e + 86400))/")"
  prq "a missing sig" GET "${L%&sig=*}"
  prq "a missing expires" GET "$CB/Ravi/bill/signed?sig=$sg"
  prq "a non-numeric expires" GET "$CB/Ravi/bill/signed?expires=soon&sig=$sg"
  prq "a sig of the wrong length" GET "${L%sig=*}sig=abc"
  local a m; for a in "$CB/Ravi/bill" "$CB/Ravi/bill-link" "$CB/Ravi/bill/signed"; do for m in POST PUT DELETE; do prq "$m on $(echo $a | sed 's#.*/Ravi/##')" $m "$a"; done; done
  local w; w=$($CURL --http1.1 -sS -D $J/pr.h -o $J/pr.b -w '%{http_code} %{content_type} %{size_download}' -H 'Accept: application/json' "$(B 21070)$CB/Ravi/bill"); echo "  refuse | Accept: application/json on the bill (GET) -> $w (the print decides: not a refusal)"
  w=$($CURL --http1.1 -sS -I -o /dev/null -w '%{http_code} %{content_type}' "$(B 21070)$CB/Ravi/bill"); echo "  refuse | HEAD on the bill -> $w"
  prq "a trailing slash on the bill" GET "$CB/Ravi/bill/"
  QUIET=1 tbstop refuse 21070; }
c_specwire() {
  echo "== specwire: the three routes' served entries against their wires (after/, 21070, harness-free, lifetime=default)"
  tb sw 21070 default > /dev/null
  $CURL -s "$(B 21070)/v3/api-docs" > $J/served.json
  mintl 21070 Ravi; local L=$LINK; cp $J/g.b $J/mint.b; cp $J/g.h $J/mint.h
  get 21070 $CB/Ravi/bill; cp $J/g.h $J/bill.h; cp $J/g.b $J/bill.b
  get 21070 "$L"; cp $J/g.h $J/signed.h
  python3 -I - $J/served.json $J/bill.h $J/mint.h $J/signed.h $J/mint.b <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
def hdr(f):
    h = {}
    for l in open(f, encoding="latin-1").read().replace("\r", "").splitlines()[1:]:
        if ":" in l: k, v = l.split(":", 1); h[k.strip().lower()] = v.strip()
    return h
gaps = []
for lab, p, hf in (("bill", "/api/v1/customers/{name}/bill", sys.argv[2]), ("mint", "/api/v1/customers/{name}/bill-link", sys.argv[3]), ("signed", "/api/v1/customers/{name}/bill/signed", sys.argv[4])):
    g = d["paths"][p]["get"]; r200 = g["responses"]["200"]; h = hdr(hf)
    media = list(r200.get("content", {}))
    print("  spec | %s | GET %s · operationId %s · responses %s · 200 media %s · 200 schema %s · 200 headers %s · parameters %s" % (lab, p, g["operationId"], sorted(g["responses"]), media,
          [v.get("schema") for v in r200.get("content", {}).values()], sorted(r200.get("headers", {})), [(x["name"], x["in"], x["schema"].get("type"), x.get("required", False)) for x in g.get("parameters", [])]))
    print("  wire | %s | Content-Type %s · Transfer-Encoding %s · Content-Disposition %s · Content-Length %s" % (lab, h.get("content-type"), h.get("transfer-encoding", "absent"), "present" if "content-disposition" in h else "absent", "present" if "content-length" in h else "absent"))
    wt = (h.get("content-type") or "").split(";")[0]
    if wt not in media: gaps.append("%s: the wire's %s is not among the documented media %s" % (lab, h.get("content-type"), media))
    if (h.get("content-type") or "") not in media and wt in media: gaps.append("%s: the wire's charset (%s) is not in the documented media type %s" % (lab, h.get("content-type"), wt))
    if h.get("transfer-encoding") == "chunked": gaps.append("%s: chunked on the wire - a spec cannot say so" % lab)
    if "content-disposition" in h and "Content-Disposition" not in r200.get("headers", {}): gaps.append("%s: Content-Disposition on the wire, not documented" % lab)
    if "content-disposition" in h and "Content-Disposition" in r200.get("headers", {}): gaps.append("%s: Content-Disposition documented as a plain string - its form (attachment; filename=...; filename*=UTF-8''...) is the description's, not the schema's" % lab)
    if lab != "mint" and any((v.get("schema") or {}).get("type") == "string" and "format" not in (v.get("schema") or {}) for v in r200.get("content", {}).values()):
        gaps.append("%s: the CSV body documented as a string - its columns are not in the spec" % lab)
    if "405" not in g["responses"]: gaps.append("%s: the method refusals (POST, PUT, DELETE) are Framework's and not documented" % lab)
s = d["paths"]["/api/v1/customers/{name}/bill/signed"]["get"]
for x in s.get("parameters", []):
    if x["name"] in ("expires", "sig") and not x.get("required"): gaps.append("signed: %s documented optional (required=false in the code, so the route's own four hundred answers its absence)" % x["name"])
    if x["name"] == "expires" and x["schema"].get("type") == "string": gaps.append("signed: expires documented as a string; the route takes a whole number of the epoch's seconds")
m = d["components"]["schemas"].get("BillLink", {})
w = json.load(open(sys.argv[5]))
print("  spec | BillLink properties %s · required %s · the wire's members %s" % (list(m.get("properties", {})), m.get("required", []), list(w)))
if not m.get("required"): gaps.append("mint: BillLink marks no member required; the wire always sends href")
for x in gaps: print("  gap | " + x)
print("  gap | named: %d" % len(gaps))
PY
  QUIET=1 tbstop sw 21070; }
c_spec() {
  echo "== the committed spec: regenerated in this commit; read here against the served document (after/, 21070, harness-free, lifetime=default)"
  tb spec 21070 default > /dev/null
  local SF=after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json BF=before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json
  $CURL -s "$(B 21070)/v3/api-docs" > $J/served.json
  echo "  the committed file against the served document (servers removed, json.dump indent 2, ensure_ascii False, a final newline): $(python3 -I -c '
import json,sys
d=json.load(open(sys.argv[1])); d.pop("servers",None)
print("equal" if json.dumps(d,indent=2,ensure_ascii=False)+"\n" == open(sys.argv[2],encoding="utf-8").read() else "differ")' $J/served.json $SF)"
  echo "  committed md5 before $(md5 -q $BF) · after $(md5 -q $SF) · bytes before $(wc -c < $BF | tr -d ' ') · after $(wc -c < $SF | tr -d ' ')"
  echo "  the diff against before's (13b1967's) file: $(diff $BF $SF | $G -c '^>') lines added, $(diff $BF $SF | $G -c '^<') removed"
  diff $BF $SF | $G '^[0-9]' | sed 's/^/  hunk /'
  echo "  the paths added: $(python3 -I -c 'import json,sys; A=json.load(open(sys.argv[1])); B=json.load(open(sys.argv[2])); a=A["paths"]; b=B["paths"]; print(sorted(set(b)-set(a)), "removed", sorted(set(a)-set(b)), "other paths moved", [k for k in a if k in b and a[k]!=b[k]], "schemas added", sorted(set(B["components"]["schemas"])-set(A["components"]["schemas"])), "schemas moved", [k for k in A["components"]["schemas"] if k in B["components"]["schemas"] and A["components"]["schemas"][k]!=B["components"]["schemas"][k]])' $BF $SF)"
  python3 -I harness/ops9s3.py ops $BF > $J/ops-before.txt; python3 -I harness/ops9s3.py ops $SF > $J/ops-after.txt
  echo "  before: $(tail -1 $J/ops-before.txt) · after: $(tail -1 $J/ops-after.txt)"
  echo "  the old operations' ids before -> after: $( [ -z "$(diff <($G -E '^  [A-Z]+ ' $J/ops-before.txt) <($G -E '^  [A-Z]+ ' $J/ops-after.txt) | $G '^<')" ] && echo equal || echo differ)"
  diff <($G -E '^  [A-Z]+ ' $J/ops-before.txt) <($G -E '^  [A-Z]+ ' $J/ops-after.txt) | $G '^[<>]' | sed 's/^/  ops added | /'
  printf '{}' > $J/empty.json; python3 -I harness/ops9s3.py ops $J/empty.json > /dev/null 2>&1; echo "  ops9s3.py on an empty spec: exit $? (refused)"
  echo "  operationIds unique: $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); i=[o.get("operationId") for v in d["paths"].values() for o in v.values()]; print("yes" if len(i)==len(set(i)) else "no")' $SF)"
  echo "  OpenApiSpecTest on the regenerated file: $(python3 -I -c '
import sys,xml.etree.ElementTree as E
r=E.parse(sys.argv[1]).getroot(); print("tests %s failures %s errors %s" % (r.get("tests"), r.get("failures"), r.get("errors")))' .harness/after/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.OpenApiSpecTest.xml) (after/'s build)"
  QUIET=1 tbstop spec 21070
  echo "== the client rebuilt on the regenerated spec: before's client (-pl tiffinbox-client -am on a copy of before) and after/'s (its build)"
  copy before .harness/client-before; guard "before's client"
  bg "cd .harness/client-before && $MV -DskipTests clean package -pl tiffinbox-client -am" .harness/build-client-before.log; offl .harness/build-client-before.log
  local GB=.harness/client-before/tiffinbox-client/target/generated-sources/openapi GA=.harness/after/tiffinbox-client/target/generated-sources/openapi
  echo "  the client: FILES $($G -c '\.java$' $GB/.openapi-generator/FILES) -> $($G -c '\.java$' $GA/.openapi-generator/FILES) · build exit $RE (before's) / 0 (after/'s, its reactor) · tracked files under tiffinbox-client in the anchor: $(cd .. && git ls-files c9-tiffinbox/tiffinbox-client | sed 's#c9-tiffinbox/tiffinbox-client/##' | paste -sd' ' -)"
  diff <($G '\.java$' $GB/.openapi-generator/FILES) <($G '\.java$' $GA/.openapi-generator/FILES) | $G '^[<>]' | sed 's/^/  the client: files /'
  local f s ne=0 nd=0 nn=0 nm=0 ng=0; for f in $(cd $GA && $G '\.java$' .openapi-generator/FILES); do
    if [ -f $GB/$f ]; then if cmp -s $GB/$f $GA/$f; then s=equal; ne=$((ne + 1)); elif [ "$($G -v '^@Generated(' $GB/$f | md5 -q)" = "$($G -v '^@Generated(' $GA/$f | md5 -q)" ]; then s="date line only"; nd=$((nd + 1)); elif [ -z "$(diff <($G -v '^@Generated(' $GB/$f) <($G -v '^@Generated(' $GA/$f) | $G '^<')" ]; then s="lines added only (the new operations), the date line aside"; ng=$((ng + 1)); else s=moved; nm=$((nm + 1)); fi; else s=added; nn=$((nn + 1)); fi
    echo "  the client: $f $s"; done
  echo "  the client: counts - equal $ne · date line only $nd · lines added only $ng · moved $nm · added $nn"
  echo "  the client: the new methods in ApiApi: $($G -oE '(public )?[A-Za-z<>]+ (bill|billLink|signedBill)\(' $GA/src/main/java/com/tiffinbox/client/api/ApiApi.java 2> /dev/null | sed -E 's/^(public )?//' | sort -u | paste -sd'|' -)"
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
  local bm; bm=$(sed -E 's/"timestamp":"[^"]*"/"timestamp":"<masked>"/; s/"next":"[^"]*"/"next":"<cursor>"/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/<uuid>/g; s/expires=[0-9]+/expires=<masked>/g; s/sig=[A-Za-z0-9_-]+/sig=<masked>/g' $J/mv.b | md5 -q | cut -c1-12)
  w=$(echo "$w" | awk '{ print $1, $2 }')
  echo "  $SIDE | $m $p$( [ -n "${TAG:-}" ] && echo " [$TAG]") -> $w · Allow {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Aa]llow: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)} · body $bm"; }
MPT='Content-Type: application/merge-patch+json'; JPT='Content-Type: application/json-patch+json'; CAPI=/api/v1/customers
movedside() { local side=$1 port=$2 a p
  TREE=$side tb moved-$side $port default > /dev/null
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
  movedone $port GET $OR/1
  movedone $port GET $OR/21
  movedone $port GET $BR/00000000-0000-0000-0000-000000000000
  movedone $port GET "$BR/00000000-0000-0000-0000-000000000000?x=1"
  TAG="the new routes" movedone $port GET $CAPI/Ravi/bill
  TAG="the new routes" movedone $port GET $CAPI/Ravi/bill-link
  QUIET=1 tbstop moved-$side $port; }
c_moved() { echo "== U17's requests (its movedside list, copied, with its own billing-runs requests; the order list's page one with its cursor masked; /v3/api-docs left out: the spec capture reads it) and the new routes, on before (21076) and after/ (21070), H2, each its own JVM, lifetime=default"
  movedside before 21076; movedside after 21070
  echo "  BOOT-INF/lib names: before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ')"
  python3 -I - .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar <<'PY'
import sys, zipfile
a = {i.filename: i.CRC for i in zipfile.ZipFile(sys.argv[1]).infolist()}; b = {i.filename: i.CRC for i in zipfile.ZipFile(sys.argv[2]).infolist()}
add = sorted(set(b) - set(a)); rem = sorted(set(a) - set(b)); mv = sorted(k for k in a if k in b and a[k] != b[k])
print("  jar | the web jar's entries: added %d %s · removed %d · shared entries whose CRC moved %d %s" % (len(add), add, len(rem), len(mv), mv))
PY
}
c_seven() {
  echo "== the seven (c5-unit11/curlset.sh, no key header), each tree its own JVM, H2, lifetime=default - not a witness for the new routes: it sends nothing to /api/v1/customers/{name}/bill..."
  echo "  expected $S466"
  local s port i; for s in before after; do [ $s = before ] && port=21076 || port=21070
    TREE=$s tb seven-$s $port default > /dev/null
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
  echo "== the old surface by count (U17's reader, copied), each tree its own JVM, H2, lifetime=default - not a witness for the new routes"
  echo "  expected $U4SURF"
  for side in before after; do [ $side = before ] && port=21076 || port=21070
    TREE=$side tb surface-$side $port default > /dev/null
    oldsurface2 $port $J/surface-$side.txt
    QUIET=1 tbstop surface-$side $port
    echo "  $side: the old surface $(md5 -q $J/surface-$side.txt) ($($G -c '^== ' $J/surface-$side.txt) requests, $(wc -l < $J/surface-$side.txt | tr -d ' ') lines)"; done
  echo "  before -> after/: $(cmp -s $J/surface-before.txt $J/surface-after.txt && echo equal || echo DIFFER)"
  echo "  the S9.14 plant slot (21074): not captured this unit (dropped first by the prompt's order; not said)"; }
c_inert() {
  echo "== the key header across this run's captures (request lines and bodies)"
  echo "  key header in this run's captures: $(ls .r-*.new 2> /dev/null | xargs cat 2> /dev/null | $G -v 'IdempotencyKeyFilter' | $G -viF "no $KW handling" | $G -ciF "$KW" || true)"
  echo "  MockMvc runs carry the key header: $($G -ciF "$KW" after/tiffinbox-web/src/test/java/com/tiffinbox/web/CustomerBillsTest.java || true)"
  echo "  IdempotencyKeyFilter's table: $($G -oE 'parse\("[^"]*"\)' after/tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java | paste -sd' ' -) - the new routes are GETs, none among them (C1 (a))"; }
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
  for c in CustomerBillsTest BillingRunsTest OrderResourcesTest CustomerFieldsTest OrderPagesTest ApiVersionTest TiffinBoxRestDocsTest OpenApiSpecTest TiffinBoxWebTest; do cls .harness/pkg/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.$c.xml package $c; done
  echo "  web classes other than CustomerBillsTest (the classes before has): $(python3 -I - .harness/pkg/tiffinbox-web/target/surefire-reports <<'PY'
import sys, glob, os, xml.etree.ElementTree as E
n = {os.path.basename(f): E.parse(f).getroot().get("tests") for f in glob.glob(sys.argv[1] + "/TEST-*.xml")}
print(len([k for k in n if "CustomerBillsTest" not in k]), "classes,", sum(int(v) for k, v in n.items() if "CustomerBillsTest" not in k), "tests")
PY
)"
  echo "  ~ CustomerBillsTest (MockMvc: no socket, no HTTP client; host localhost): $($G -cE '^CustomerBillsTest: ' .harness/pkg.log) printed request lines (the waiting polls vary in number: not said)"
  echo "== the Docker-free twin: after/'s own build (DOCKER_HOST=unix:///nonexistent/docker.sock, the run's first build)"
  for p in web client; do surefire .harness/after/tiffinbox-$p/target/surefire-reports "twin | tiffinbox-$p"; done
  echo "  slice TiffinBoxWebTest: after $(python3 -I -c 'import xml.etree.ElementTree as E,sys; print(E.parse(sys.argv[1]).getroot().get("tests"))' .harness/pkg/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.TiffinBoxWebTest.xml) tests · the slice's file byte-equal to before's: $(cmp -s before/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java after/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java && echo yes || echo no) - measured: no slice edit needed, CustomerRepository is already mocked ($($G -cE '@MockitoBean CustomerRepository' after/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java) line)"
  echo "  web tests before (unit 17's values): $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit17/README.md | $G -oE 'web_tests=[0-9]+' | head -1 | cut -d= -f2) · new @Test lines $($G -cE '^ +@Test$' after/tiffinbox-web/src/test/java/com/tiffinbox/web/CustomerBillsTest.java)"
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
  echo "  downloads across the builds: $(cat .harness/pkg.log .harness/verify.log .harness/webonly.log .harness/build-after.log .harness/build-before.log .harness/build-client-before.log .harness/build-presign.log .harness/build-declared.log 2> /dev/null | $G -cE 'Download(ing|ed) from ' || true)"
  echo "  BOOT-INF/lib: before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ') · name lists $(cmp -s <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) && echo equal || echo differ)"; }
exrun() { local v=$1 sh=$2 o cmd
  guard "the exercise, $v, $sh"
  rm -rf .harness/exercise/tree; copy after .harness/exercise/tree
  case $v in broken) cmd='sh break.sh "$0" > /dev/null && sh check.sh "$0"' ;; solved) cmd='sh break.sh "$0" > /dev/null && sh apply.sh "$0" > /dev/null && sh check.sh "$0"' ;; *) cmd="sh break.sh \"\$0\" > /dev/null && HOW=$v sh apply.sh \"\$0\" > /dev/null && sh check.sh \"\$0\"" ;; esac
  if [ $sh = bash ]; then o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21078 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock bash -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1)
  else o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21078 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock /bin/zsh -f -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1); fi
  local pre="  $v $sh |"; [ $v = broken ] || [ $v = solved ] || pre="  ~ $v $sh |"
  printf '%s\n' "$o" | sed -E "s/127\.0\.0\.1:21078/127.0.0.1:<port>/g; s/^/$pre /"
  [ ! -f exercise/check.build.log ] || offl exercise/check.build.log
  [ "$(listeners 21078)" = 0 ] || die "the exercise left something listening on 21078"; }
c_exercise() { local v sh
  rm -rf .harness/exercise; mkdir -p .harness/exercise
  for v in broken solved; do for sh in bash zsh; do echo "  == $v, $sh"; exrun $v $sh; done; done
  if [ "$RUNNO" = 1 ] || [ "$RUNNO" = 0 ]; then for v in object fixedelsewhere hardcoded nosignature; do exrun $v bash; done; fi
  rm -rf exercise/check.run; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.b exercise/check.h exercise/check.bill
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }
c_section() {
  echo "== section: Section 3 closes here - its six units (git log, the pinned hashes), the committed spec's counts at each after/ (ops9s3.py on each unit's own frozen file)"
  local h; for h in fd06e77 f3724ca c7e5118 c3bc1b2 13b1967; do echo "  section | $(cd .. && git log -1 --format='%h %s' $h | cut -c1-60)"; done
  local u; for u in 12 13 14 16 17; do echo "  section | unit $u's after/: $(python3 -I harness/ops9s3.py ops ../c9-unit$u/after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tail -1)"; done
  echo "  section | unit 15's after/: $( [ -d ../c9-unit15/after ] && cmp -s ../c9-unit15/after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json ../c9-unit14/after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json && echo "its spec = unit 14's (no spec change)" || echo "no frozen spec of its own")"
  echo "  section | unit 18's after/: $(python3 -I harness/ops9s3.py ops after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tail -1)"
  echo "  section | up next, by title only: $(python3 -I -c 'import re,sys; t=open(sys.argv[1]).read().split("TITLES",1)[1]; print(re.search(r"\"19\": *\"([^\"]+)\"", t).group(1))' "$J9") = TRACK-ROADMAP.md:393's: $(sed -n 393p "$RM" | $G -qF 'Rate Limiting' && echo yes || echo no)"; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures${DEVCAPS:+ (DEVELOPMENT: only $DEVCAPS - not a run of record)}"
cap advisory c_advisory
cap before c_before
cap change c_change
cap census c_census
cap harness c_harness
cap proxy c_proxy
cap declared c_declared
cap signed c_signed
cap presign c_presign
cap defaults c_defaults
cap expect c_expect
cap refuse c_refuse
cap specwire c_specwire
cap spec c_spec
cap moved c_moved
cap seven c_seven
cap surface c_surface
cap tests c_tests
cap exercise c_exercise
cap inert c_inert
cap section c_section
echo "  captures: the fake test credential and the link key in every capture: $(cat .r-*.new 2> /dev/null | $G -cF -e "$(printf '%s' "$FK" | cut -d'|' -f1)" -e "$(printf '%s' "$FK" | cut -d'|' -f2)" || true) lines"
[ "$(cat .r-*.new 2> /dev/null | $G -cF -e "$(printf '%s' "$FK" | cut -d'|' -f1)" -e "$(printf '%s' "$FK" | cut -d'|' -f2)" || true)" = 0 ] || die "the fake test credential appears in a capture"
echo "== plants (each made to FAIL first on a copy of this run's capture; harness/chk18.py plants)"
PL=$(ck plants .) || die "a plant was not caught: $(printf '%s\n' "$PL" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$PL" | $G '^ok ' | sed 's/^ok /  /'
PLV=$(printf '%s\n' "$PL" | sed -n 's/^VALUES //p')

# ---- the end: the sweep, the values, the published hashes -------------------------------------------------------------------------------
[ -z "$(echo $PIDS)" ] || die "a JVM of this run is still running: $PIDS"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
[ -z "$(dk ps -aq --filter label=org.testcontainers=true)" ] || die "a Testcontainers container of this run is left"
[ -z "$(dk ps -aq --filter name=^/c9u18-)" ] || die "a c9u18-* container is left"
NI1=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI1" = "$NI0" ] && [ "$VOL1" = "$VOL0" ] || die "R.322: images $NI0 -> $NI1, volumes $VOL0 -> $VOL1"
AD1=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true); [ "$AD1" = "$AD" ] || die "the anchor moved during the run"
pin before-tree before; pin after-tree after
MDB=$(find . ../c9-tiffinbox ../c9-unit17 -name '*.mv.db' -not -path './.harness/*' -not -path '../c9-unit17/.harness/*' 2> /dev/null | wc -l | tr -d ' ')
[ "$MDB" = 0 ] || die "an H2 file outside .harness/"
[ -z "$(ls exercise | $G -v -xE 'README.md|SOLUTION.md|apply.sh|break.sh|check.sh')" ] || die "the exercise left a file in exercise/"
VALS="$VALS
plants: $PLV
build: seed_files=$NF0 seed_bytes=$NB0 central_only=$CO"
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
[ -n "${DEVCAPS:-}" ] && { echo "c9-unit18: DEVELOPMENT run ($DEVCAPS) - nothing published"; exit 2; }
VO=$(ck values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; [ -n "${NOPIN:-}" ] || die "README.md's values block is not this run's"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM of this run, ports free, no container left, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1 · the anchor against after/ as at the start · the tree pins · *.mv.db outside .harness 0"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit18: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit18: every capture = published ($NCAPS) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"
