#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 17 "Bulk Operations and 202 Accepted" - this unit's receipts. Course 9's THIRTEENTH anchor change, Section 3's fifth:
# before is a link to ../c9-unit16/after (U16's after); after/ is a frozen copy of ../c9-tiffinbox after this unit's change - BillingRuns
# (POST /api/v1/billing-runs answers 202 with Location and Retry-After; GET /api/v1/billing-runs/{id} is the status resource; the store an
# in-JVM map), BillingRunsTest, the committed spec regenerated, the anchor's README card.
# The harness's delay (C1 (a)): the run flag --tiffinbox.billing-runs.harness-pause-ms=$PAUSE on the command line, labelled delay=on; the
# shipped default is no pause (delay=off). No harness class, no Chrome.
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5; lines starting "  ~" are run-variant
# and left out of the hash - each poll's line, the exercise's refused variants of run 1):
#   advisory  the S9.36 read filed for the batch day (ADV3), verified, before any build; the shipped tree's coordinates
#   before    the new routes and the old ones on before (21066), the mappings, the spec's counts, the lib
#   change    the modules, the new files whole, the derived changed list, the greps, the handler names, application.yaml's keys
#   census    the controllers on before and after/ by unit 15's printed rule
#   accept    the 202 on the wire (21060, delay=on, then delay=off): status line, Location, Retry-After (masked), the body, the access log
#   poll      the status resource polled by its condition (Retry-After's own value slept), the states in order, Retry-After present then gone
#   bills     the final body's four bills beside V2's rows and monthlyBill's arithmetic
#   restart   the failure receipt: JVM-1 (21060) stopped with a run RUNNING, JVM-2 (21065): the old ids 404, a new run there (the control)
#   double    two key-less POSTs; one keyed POST and the same key again (C4: the route is not in the filter's table)
#   refuse    every refusal form of the two routes, each status, type and detail; Framework's and Boot's with no type named
#   specwire  the new routes' served entries against their wires
#   spec      the committed spec against the served one, the diff, the counter, the client rebuilt on it
#   moved     U16's requests on before (21066) and after/ (21060)
#   seven     c5-unit11's seven on before and after/
#   surface   the old surface by count on before and after/
#   tests     package, the Docker-free twin, verify (Surefire on H2, the five ITs on PostgreSQL), the web-only form, the slice
#   exercise  break.sh, check.sh, apply.sh on 21068, bash and zsh -f, H2; the refused variants (run 1)
#   inert     the key header across this run's captures
# Ports (U17's band, 21060-21069): 21060 after/ on H2 · 21065 the restarted JVM · 21066 before · 21068 the exercise · 21061-21064, 21067
# and 21069 never bound (bills-pg and the S9.14 plant slot not captured; no harness-joined start: C1 (a)). During mvn verify only:
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
PAUSE=400                                             # the harness's pause between two customers (ms), delay=on: a label, never voiced
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
export DOCKER_HOST="$DH"
PIDS=""; INTR=""; mpid=""
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in $mpid $PIDS; do [ -z "$p" ] || killtree "$p"; done; for p in $mpid $PIDS; do if kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; for c in $(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null); do dk rm -fv "$c" > /dev/null 2>&1; done; rm -rf exercise/check.run; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.b exercise/check.h exercise/check.polls; [ -z "$INTR" ] || rm -f .r-*.new; rmdir .r-lock 2> /dev/null || rm -rf .r-lock; true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git unzip /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|SPRINGDOC_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit17 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }') · run $RUNNO"

# ---- gates before anything is built: the folder, the link, the pins, the anchor, the static check, the prose, the exercise ----------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk17.py dur9.py ops9s3.py s917.py tree17.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
for f in walk.py follow.py loc9.py seal9.py cdp.mjs cdp9.mjs specwire9.py mirror src Gzip14.java U16Hal.java U16Next.java; do [ ! -e harness/$f ] || die "harness/$f: an earlier unit's instrument this unit does not carry"; done
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md apply.sh break.sh check.sh' ] || die "exercise/ holds another file, or misses one"
[ -L before ] && [ "$(readlink before)" = ../c9-unit16/after ] || die "before must be a link whose text is exactly ../c9-unit16/after"
[ -d after ] && [ ! -L after ] || die "after/ is this unit's own frozen tree, a directory, not a link"
for t in before after; do [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-client/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/"; true; done
echo "  before -> $(readlink before) (a link, the text exact) · after/ a directory (the frozen copy) · no secrets/, target/ or .m2-demo/ in either · harness/: no Java (C1 (a)), no walk.py, follow.py, seal9.py, cdp.mjs, cdp9.mjs, loc9.py, Gzip14.java, U16Hal.java, U16Next.java"
OP=$(md5 -q "$BK3/instruments/ops9s3.py"); [ "$OP" = 8f062a0e5e872c478579756a8426c012 ] || die "BLUE's ops9s3.py is not 8f062a0e"
[ "$(md5 -q harness/ops9s3.py)" = "$OP" ] || die "harness/ops9s3.py is not BLUE's instrument, byte for byte"
echo "  ops9s3.py = BLUE's (md5 $OP, byte for byte; it refuses an empty spec) · the probe's ProbeJobsAndBills.java md5 $(md5 -q "$PK3/instruments/probe-src/ProbeJobsAndBills.java") (read for its shapes, not copied)"
[ "$(sed -n '5,$p' harness/tree17.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit16/harness/tree16.py | md5 -q)" ] || die "harness/tree17.py's code is not tree16.py's"
for u in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16; do [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit$u/harness/dur9.py)" ] || die "harness/dur9.py is not ../c9-unit$u's copy"; done
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"
  [ ! -f "$C9R/_builders/dur9.py" ] || [ "$(md5 -q "$C9R/_builders/dur9.py")" = "$D9" ] || die "harness/dur9.py is not C9/_builders/dur9.py"
  TT=$(python3 -I -c '
import re,sys; t=open(sys.argv[1]).read().split("TITLES",1)[1]
for k in ("07","09","10","12","13","16","17"):
    m=re.search(r"\"%s\": *\"([^\"]+)\"" % k, t); print("%s=%s" % (k, m.group(1) if m else ""))' "$J9" | paste -sd'|' -)
  [ "$TT" = '07=OpenAPI: The Contract|09=Documenting Errors, Examples and Security|10=Code Generation From the Contract|12=Versioning Strategies|13=Pagination, Filtering and Sorting as an API Concern|16=Spring HATEOAS in Practice|17=Bulk Operations and 202 Accepted' ] || die "java9_series.TITLES differ from the call-backs (C11: the live title wins - a finding): $TT"
  echo "  the titles, read off the registry (the call-backs, by title only, R.224): $TT"
else D9N="(the registry is not on this machine: U01-U16's copies are the pin)"; fi
RM="$C9R/../TRACK-ROADMAP.md"; [ -f "$RM" ] || RM="$(dirname "$C9R")/TRACK-ROADMAP.md"
if [ -f "$RM" ]; then for t in 'Spring Batch & Scheduling' 'Messaging & Integration'; do $G -qF "$t" "$RM" || die "the roadmap does not name $t"; done; echo "  the roadmap titles (by title only, once): Spring Batch & Scheduling, Messaging & Integration - both in $(basename "$RM") · its row 17: $($G -cF 'Bulk Operations and 202 Accepted' "$RM") line(s)"; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit01-16's copies $D9N · tree17.py's code = tree16.py's"
XS1=$(sed -n '/^# --- XFAM_S9S1 begin ---$/,/^# --- XFAM_S9S1 end ---$/p' harness/s917.py | md5 -q); XS1U=$(sed -n '/^# --- XFAM_S9S1 begin ---$/,/^# --- XFAM_S9S1 end ---$/p' ../c9-unit16/harness/s916.py | md5 -q)
[ "$XS1" = "$XS1U" ] || die "s917.py's XFAM_S9S1 slice is not U16's s916.py's"
echo "  s917.py: XFAM_S9S1's slice md5 $XS1 = ../c9-unit16/harness/s916.py's · its XU17 family this unit's · lines outside XU17 = s916.py's but for the names: $(diff <(sed '/^XU16 = {/,/^u04 = u16$/d' ../c9-unit16/harness/s916.py | sed 1d) <(sed '/^XU17 = {/,/^u04 = u17$/d' harness/s917.py | sed 1d) | $G -c '^[<>]') lines differ"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit16/receipts.md5)
[ "$UA" = "115 9bf666a402b728a21258a466b1a44579" ] || die "../c9-unit16/receipts.md5's after-tree line is not 115 9bf666a4 ($UA)"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree17.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || { [ -n "${NOPIN:-}" ] && { echo "  $dir/: $got (NOPIN: no pin yet)"; return 0; }; die "receipts.md5 has no $nm line"; }
  [ "$nm" = after-tree ] || [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit16/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree17.py $dir/ -> $got = receipts.md5's $nm line$( [ "$nm" = before-tree ] && echo " = ../c9-unit16/receipts.md5's after-tree line")"; }
pin before-tree before; pin after-tree after
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true)
echo "  after/ against the live anchor (the start note): $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures its own frozen after/' )"
HF="harness/chk17.py harness/s917.py harness/tree17.py harness/dur9.py harness/ops9s3.py exercise/check.sh exercise/apply.sh exercise/break.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's scripts: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
ST=$(python3 -I -B harness/chk17.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
echo "  static (harness/chk17.py static after before; reads after/, before and git show c3bc1b2:… only - flag 31): $(printf '%s\n' "$ST" | $G -c '^ok ') checks, FAIL 0"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s917.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U17 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s917, per sentence): /'
PH=$($G -rnE 'PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b|<measure>' README.md exercise 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
GL=$(python3 -I -B harness/chk17.py gloss README.md) || die "the gloss: $(printf '%s\n' "$GL" | $G '^FAIL' | head -3 | paste -sd';' -)"
echo "  the gloss: $(printf '%s\n' "$GL" | $G -c '^ok ') checks, FAIL 0 ($(python3 -I -B harness/chk17.py gloss-line))"
HOOK=$(python3 -I -B harness/chk17.py hook); EXQ=$(python3 -I -B harness/chk17.py exq); GLS=$(python3 -I -B harness/chk17.py gloss-line)
IL=$(python3 -I -B harness/chk17.py interleaved) || die "the brief's interleaved hooks and exercises: $IL"
echo "  $IL"
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S3B's Unit 17 Hook line), byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
HW=$(printf '%s\n' "$HOOK" | wc -w | tr -d ' '); EW=$(printf '%s\n' "${EXQ#Your turn: }" | wc -w | tr -d ' ')
[ "$HW" -le 25 ] && [ "$EW" -le 25 ] || die "a spoken line over 25 words (hook $HW, exercise $EW)"
echo "  the hook ($HW words) and the exercise's line ($EW words after 'Your turn:') byte for byte, extracted from S3B's Unit 17 (md5 $(md5 -q "$C9R/_briefs/UNIT-BRIEFS-S3-PAYLOADS.md"))"
printf '%s\n\n%s\n\n%s\n' "$HOOK" "$EXQ" "$GLS" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s917.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
SWR=$(printf '%s\n' "$SW" | $G ' line ' | sed 's#.*spoken.md ##' | sort -u | paste -sd';' -)
echo "  the hook, the exercise's line and the gloss through s917.py: $(printf '%s\n' "$SW" | tail -1 | sed 's/.* refused: /refused /')$( [ -n "$SWR" ] && echo " - $SWR (handed to RED)")"; rm -f .r-lock/spoken.md
TS="HTTP 202 Accepted in Spring Boot: Location, Retry-After"
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
[ "$KH" = 0 ] || die "S9.21: a line of receipts.sh or the exercise names the key header (the double capture builds it from two halves)"
LA=$($G -nF 'c9-tiffinbox' receipts.sh exercise/check.sh exercise/apply.sh exercise/break.sh | $G -v ':[0-9]*: *#' | $G -vF 'AD=$(diff -rq' | $G -vF 'AD1=$(diff -rq' | $G -vF 'MDB=$(find' | $G -vF 'git status --short tiffinbox-client' | $G -vF "\$G -nF 'c9-tiffinbox'" | $G -vF 'tracked files under tiffinbox-client' | wc -l | tr -d ' ')
[ "$LA" = 0 ] || die "flag 31: a line of the receipts or the exercise reads the live anchor outside the start note, the end check, the H2-file sweep and the client's git status"
echo "  static: no kill by name; every docker call on the pinned socket, every removal rm -fv; R.391's Maven forms only; the key header named by no line; the live anchor read only by the start note, the end check, the H2-file sweep and the client's git status (flag 31)"
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
    gsub(/127\.0\.0\.1:2106[0-9]/, "127.0.0.1:<port>")
    gsub(/[Rr]etry-[Aa]fter: [0-9]+/, "Retry-After: <masked>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'took 812 ms' '"timestamp":"2026-11-01T08:09:00.123Z"' "$U/x $HOME/y" 'Location: http://127.0.0.1:21060/api/v1/billing-runs/eee5359d-c35d-49d5-91ac-5e34975395a8' 'Retry-After: 1' | mask)
[ "$(printf '%s\n' "$MP" | paste -sd'|' -)" = 'Started TiffinBoxServer in <t> (process running for <t>)|took <t>|"timestamp":"<time>"|…/x ~/y|Location: http://127.0.0.1:<port>/api/v1/billing-runs/<uuid>|Retry-After: <masked>' ] || die "the mask's self-test: $(printf '%s\n' "$MP" | paste -sd'|' -)"
echo "  masks: the log mask masked a Started line's times, a millisecond count, a timestamp, the folders, the home, a band port, the run's uuid and Retry-After's value (self-test)"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh); [ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SURF=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh); [ ${#U4SURF} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh (SURF=)"
U16V=$(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit16/README.md | $G -E '^(seven|surface): ' | $G -oE '(seven|surface)=[0-9a-f]{8}' | paste -sd' ' -)
[ "$U16V" = "seven=$(echo $S466 | cut -c1-8) surface=$(echo $U4SURF | cut -c1-8)" ] || die "U16's README values block ($U16V) is not the seven and the surface read off the receipts"
echo "  the seven: expected $S466 (../c7-unit31/receipts.sh's S466= line) · the old surface: expected $U4SURF (../c9-unit04/receipts.sh's SURF= line) · both = U16's values block ($U16V)"
echo "  the probe's 202 captures (PK3/captures/h36/, read, not copied: the expectation on the probe's route, 1 run): $(ls "$PK3/captures/h36" | wc -l | tr -d ' ') files, their md5 list $(cd "$PK3/captures/h36" && for f in $(ls | sort); do printf '%s %s\n' "$(md5 -q "$f")" "$f"; done | md5 -q) · BLUE's captures: $(ls "$BK3/captures" | wc -l | tr -d ' ') files"

# ---- docker, ports, the guard: the baselines ----------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run"
[ -z "$(dk ps -aq --filter name=^/c9u17- 2> /dev/null)" ] || die "a c9u17-* container exists before the run"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
BAND="21060 21061 21062 21063 21064 21065 21066 21067 21068 21069"
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
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · nothing pulled · no Testcontainers or c9u17-* container · ports free (21110-21119 included, never bound)"

# ---- the trees, copied and built offline: before (through the link), after/ ---------------------------------------------------------
M2="$PWD/.m2-demo"
if [ ! -d "$M2" ]; then [ -d "$SEED" ] || die "the seed $SEED is missing"; cp -cR "$SEED" "$M2" 2> /dev/null || cp -R "$SEED" "$M2" || die "the seed could not be copied"; fi
NF0=$(find "$M2" -type f | wc -l | tr -d ' '); NB0=$(find "$M2" -type f -print0 | xargs -0 stat -f %z | awk '{ s += $1 } END { printf "%d", s }')
CO=$(find "$M2" -name _remote.repositories -print0 | xargs -0 $G -l 'central-only' 2> /dev/null | wc -l | tr -d ' ')
[ "$CO" = 0 ] || die "$CO _remote.repositories files in the seed copy still name central-only"
ART="org/springframework/boot/spring-boot-starter-parent/4.1.3 org/springframework/hateoas/spring-hateoas/3.1.4 tools/jackson/core/jackson-databind/3.1.8"
for a in $ART; do [ -n "$(ls "$M2/$a" 2> /dev/null | $G -E '\.(jar|pom)$')" ] || die ".m2-demo holds no $a (no seed act here: report the coordinates)"; done
echo "  .m2-demo (a copy of the seed m2-seed-c9-s3): files $NF0 · bytes $NB0 · _remote.repositories naming central-only: $CO"
for a in $ART; do echo "  seed | $a | $(ls "$M2/$a" | $G -E '\.(jar|pom)$' | paste -sd' ' -)"; done
mkdir -p .harness; for d in before after pkg tests webonly exercise run work client-before; do rm -rf .harness/$d; done
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
B() { echo "http://127.0.0.1:$1"; }
J=.harness/work
ALP='%m %U%q %s %b "%{Content-Type}o"'
# tb LABEL PORT DELAY [args]: TiffinBox (the extracted jar of TREE=after unless TREE is set), from its own run folder with a generated
# token (0600, never printed), H2 in memory (fresh per JVM), waited for by its Started line. DELAY: on = the harness's pause on the
# command line (--tiffinbox.billing-runs.harness-pause-ms=$PAUSE), off = none (the shipped default). ACC=1: Tomcat's access log.
tb() { local label=$1 port=$2 delay=$3 t=${TREE:-after} run=.harness/run/$1 i=0; shift 3
  guard "TiffinBox $label"
  for q in 21061 21062 21063 21064 21067 21069; do [ "$(listeners $q)" = 0 ] && [ -z "$(lsof -nP -iUDP:$q 2> /dev/null)" ] || die "$q must stay free (TCP and UDP)"; done
  [ "$(listeners $port)" = 0 ] && [ -z "$(lsof -nP -iUDP:$port 2> /dev/null)" ] || die "$port is bound before $label"
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  local x="$U/.harness/$t/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  local fx=(); [ "$delay" = on ] && fx=(--tiffinbox.billing-runs.harness-pause-ms=$PAUSE)
  local ax=(); [ -n "${ACC:-}" ] && ax=(--server.tomcat.accesslog.enabled=true "--server.tomcat.accesslog.directory=$U/$run" --server.tomcat.accesslog.prefix=access --server.tomcat.accesslog.suffix=.log --server.tomcat.accesslog.rotate=false --server.tomcat.accesslog.buffered=false "--server.tomcat.accesslog.pattern=$ALP")
  echo "java -cp <tree $t> com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=$port ${fx[*]:-} $( [ -n "${ACC:-}" ] && echo '<the access log>') $*" > "$run/cmd"
  (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -cp "$cp" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port="$port" "${fx[@]}" "${ax[@]}" "$@" > jvm.log 2>&1) &
  local p=$!; echo $p > "$run/pid"; PIDS="$PIDS $p"; MINE="${MINE:-} $port"
  while ! $G -q -E 'Started TiffinBox(App|Server) in' "$run/jvm.log" 2> /dev/null; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before its Started line"; }; i=$((i + 1)); [ $i -lt 900 ] || die "$label: no Started line"; sleep 0.1; done
  local dup; dup=$(tr ' ' '\n' < "$run/cmd" | $G -E '^--' | sed 's/=.*//' | sort | uniq -d | paste -sd, -); [ -z "$dup" ] || die "R.444: a flag twice on $label's command line ($dup)"
  [ "$delay" = off ] || $G -qF -- "--tiffinbox.billing-runs.harness-pause-ms=" "$run/cmd" || die "$label: delay=on without its flag on the command line"
  echo "  $label up on $port (H2, tree $t, delay=$delay$( [ -n "${ACC:-}" ] && echo ", the access log on")) · $(sed 's/ *$//' "$run/cmd")"; }
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
  local o e=0; o=$(python3 -I -B harness/chk17.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk17 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; [ -n "${DEVCAPS:-}${NOPIN:-}" ] && { echo "  (development: $nm's check failed, the run goes on)"; unpub="$unpub $nm"; } || die "$nm: its check failed (harness/chk17.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk17.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-11s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-11s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff .r-$nm.new against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }
ck() { python3 -I -B harness/chk17.py "$@"; }
BR=/api/v1/billing-runs; OR=/api/v1/orders
hv() { local v; v=$(tr -d '\r' < "$1" | $G -i "^$2:" | head -1 | sed -E "s/^[^:]*: *//"); echo "${v:-}"; }
st() { python3 -I -c 'import json,sys
try: print(json.load(open(sys.argv[1]))["state"])
except Exception: print("none")' "$1"; }
bl() { python3 -I -c 'import json,sys
try: print(" ".join("%s=%s" % kv for kv in sorted((json.load(open(sys.argv[1])).get("bills") or {}).items())))
except Exception: print("none")' "$1"; }
# post PORT TAG [curl args]: one POST to the billing runs; leaves $J/p.h and $J/p.b; sets LOC and PW (status content-type size)
post() { local port=$1; shift; : > $J/p.h; : > $J/p.b
  PW=$($CURL --http1.1 -sS -D $J/p.h -o $J/p.b -w '%{http_code} %{content_type} %{size_download}' --max-time 10 -X POST "$@" "$(B $port)$BR"); LOC=$(hv $J/p.h Location); }
# pollto LOC LABEL: GET LOC by its condition (state not RUNNING ends it), sleeping Retry-After's own value; a 30 s alarm is a guard
pollto() { local loc=$1 lab=$2 end ra s w seq="" runra=yes; end=$(( $(date +%s) + 30 )); ALARM=not-hit
  while :; do : > $J/g.h; w=$($CURL --http1.1 -sS -D $J/g.h -o $J/g.b -w '%{http_code}' --max-time 10 "$loc"); ra=$(hv $J/g.h Retry-After); s=$(st $J/g.b)
    echo "  ~ poll | $lab | $s · Retry-After $( [ -n "$ra" ] && echo present || echo absent) · $w"
    case " $seq " in *" $s "*) ;; *) seq="$seq $s" ;; esac
    if [ "$s" != RUNNING ]; then FIRSTTERM=$( [ -n "$ra" ] && echo yes || echo no); break; fi
    [ -n "$ra" ] || runra=no
    [ "$(date +%s)" -lt "$end" ] || { ALARM=hit; FIRSTTERM=none; break; }
    case "$ra" in ''|*[!0-9]*) sleep 0.2 ;; *) sleep "$ra" ;; esac; done
  SEQ=${seq# }; RUNRA=$runra; LASTB=$J/g.b; }
acclog() { cat .harness/run/$1/access*.log 2> /dev/null | sed -E 's/^([A-Z]+ [^ ]*)- /\1 /; s/ +$//'; }   # %q prints - for no query: dropped

# ---- the captures ----------------------------------------------------------------------------------------------------------------------
c_advisory() {
  echo "== S9.36: the read filed for the batch day (ADV3; not re-read: no network), before any capture"
  echo "  fetched-at $(head -1 "$ADV/fetched-at.txt" | cut -c1-10) (the hour masked) · run date $(date '+%Y-%m-%d')"
  local n=0 v=0 f h; while read -r h f; do n=$((n + 1)); [ "$(md5 -q "$ADV/$f" 2> /dev/null)" = "$h" ] && v=$((v + 1)); done < <($G -vE '^\s*$' "$ADV/MD5SUMS.txt" | awk '$2 != "MD5SUMS.txt" { print $1, $2 }')
  echo "  MD5SUMS.txt: $n lines, $v verified (its own line left out)"
  echo "  spring rows $($G -c . "$ADV/spring-index-rows-2026-11-24.txt") · naming Spring Framework $($G -c 'Spring Framework' "$ADV/spring-index-rows-2026-11-24.txt" || true) · naming HATEOAS $($G -ci 'hateoas' "$ADV/spring-index-rows-2026-11-24.txt" || true)"
  echo "  tomcat page md5 $(md5 -q "$ADV/tomcat-security-11.html")"
  local a; for a in spring-hateoas spring-boot-hateoas spring-plugin-core json-path json-smart accessors-smart asm tomcat-embed-core jackson-databind spring-web spring-data-jpa spring-data-commons hibernate-core postgresql h2; do
    echo "  shipped | $a $(ls .harness/after/$XD/lib | $G -E "^$a-[0-9]" | sed -E "s/^$a-//; s/\.jar$//" | paste -sd, -)"; done
  echo "  osv (second witness only, S2.8): $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); r=d.get("results",[]); print("%d results, %d with vulns" % (len(r), sum(1 for x in r if x.get("vulns"))))' "$ADV/osv-result.json")"
  echo "  lib names before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ') · name lists $(cmp -s <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) && echo equal || echo differ)"
  echo "  verdict: no pin affected; evidence may proceed; this unit adds no jar"; }
mappings() { $CURL -s "$(B $1)/actuator/mappings" | python3 -I -c '
import json,sys
d=json.load(sys.stdin); ps=[]
for c in d["contexts"].values():
    for m in c["mappings"]["dispatcherServlets"]["dispatcherServlet"]:
        rc=(m.get("details") or {}).get("requestMappingConditions")
        if rc: ps += [p for p in rc.get("patterns", [])]
print("  %s | mappings %d · with billing in the path %d: %s (rule: the request-mapping patterns of the dispatcher servlet)" % (sys.argv[1], len(ps), sum(1 for p in ps if "billing" in p), sorted(p for p in ps if "billing" in p)))' "$2"; }
gone() { local lab=$1 port=$2 m=$3 p=$4 w; w=$($CURL --http1.1 -sS -D $J/b.h -o $J/b.b -w '%{http_code} %{content_type}' --max-time 10 -X "$m" "$(B $port)$p")
  echo "  $lab | $m $(echo "$p" | sed -E 's/[0-9a-f-]{36}$/<uuid>/') -> $w · Allow {$(tr -d '\r' < $J/b.h | sed -n 's/^[Aa]llow: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)}"; }
c_before() {
  echo "== before (21066, U16's after, H2, delay=off - the setting does not exist there; the harness's exposure flag for /actuator/mappings)"
  TREE=before tb before 21066 off --management.endpoints.web.exposure.include=health,prometheus,mappings
  gone before 21066 POST $BR; gone before 21066 GET $BR/00000000-0000-0000-0000-000000000000
  local p w; for p in $OR/1 $OR /api/v1/customers/Ravi; do w=$($CURL --http1.1 -sS -o $J/o.b -w '%{http_code} %{content_type} %{size_download}' "$(B 21066)$p"); echo "  before | GET $p -> $w · file $(wc -c < $J/o.b | tr -d ' ') B"; done
  mappings 21066 before
  echo "  before | the committed spec: $(python3 -I harness/ops9s3.py ops before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tail -1) · $(wc -c < before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tr -d ' ') B md5 $(md5 -q before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json)"
  echo "  before | BOOT-INF/lib names $(ls .harness/before/$XD/lib | wc -l | tr -d ' ')"
  QUIET=1 tbstop before 21066; }
census() { python3 -I - "$1/tiffinbox-web/src/main/java/com/tiffinbox/web" "$2" <<'PY'
import os, re, sys
d, side = sys.argv[1], sys.argv[2]
print("  census %s | rule (unit 15's, copied off unit 16's receipts): a class whose annotation lines (the lines between the Javadoc's end and its declaration) include exactly @RestController or @Controller; its final modifier; @Profile(\"dev\") among those lines" % side)
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
c_change() {
  echo "== the modules, the change file by file"
  echo "  modules: $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' before/pom.xml | paste -sd' ' -) ($($G -c '<module>' before/pom.xml)) -> $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' after/pom.xml | paste -sd' ' -) ($($G -c '<module>' after/pom.xml))"
  local pm; pm=$(for p in pom.xml tiffinbox-core/pom.xml tiffinbox-web/pom.xml tiffinbox-client/pom.xml; do cmp -s before/$p after/$p || echo $p; done | paste -sd' ' -)
  echo "  poms before -> after/: ${pm:-equal}"
  echo "  changed (derived: diff -rq before after/, the frozen trees - git status --short gave the same list before the commit): $(diff -rq before/ after/ | sed -E 's#^Files before/(.*) and after/.* differ$#M \1#; s#^Only in after/(.*): (.*)$#A \1/\2#; s#^Only in after/: (.*)$#A \1#; s#^Only in before/(.*): (.*)$#D \1/\2#' | sort | paste -sd'~' - | sed 's/~/ · /g')"
  local f; for f in tiffinbox-web/src/main/java/com/tiffinbox/web/BillingRuns.java tiffinbox-web/src/test/java/com/tiffinbox/web/BillingRunsTest.java; do
    echo "== $f (whole, md5 $(md5 -q after/$f))"; sed 's/^/    /' after/$f; done
  for k in JsonView MappingJacksonValue Pageable 'offset(' Probe /probe/ msPerCustomer; do echo "  src/main grep $k: $(cd after && $G -rhF "$k" tiffinbox-web/src/main tiffinbox-core/src/main | $G -vcE '^[[:space:]]*(\*|//|/\*)' || true) code lines"; done
  echo "  BillingRuns: $($G -E '^(public )?(final )?class BillingRuns' after/tiffinbox-web/src/main/java/com/tiffinbox/web/BillingRuns.java)"
  echo "  IdempotencyKeyFilter byte-equal to before's: $(cmp -s before/tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java after/tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java && echo yes || echo no)"
  for k in compression forward-headers hateoas billing pause; do echo "  application.yaml $k keys: before $($G -c "$k" before/tiffinbox-web/src/main/resources/application.yaml || true) · after $($G -c "$k" after/tiffinbox-web/src/main/resources/application.yaml || true)"; done
  for h in startBillingRun billingRun; do echo "  handler $h: $(cd after && $G -rhE -A3 '@(Get|Post|Put|Patch|Delete|Request)Mapping' tiffinbox-web/src/main/java | $G -cE " $h\(") occurrence(s) among the mapped handlers"; done
  echo "  the picks as the code shows them: C1 $($G -oE '@Value\("[^"]*"\)' after/tiffinbox-web/src/main/java/com/tiffinbox/web/BillingRuns.java) · C6 $($G -oE 'record BillingRunView\([^)]*\)' after/tiffinbox-web/src/main/java/com/tiffinbox/web/BillingRuns.java | sed 's/@Schema(nullable = true) //') $($G -oE 'enum State \{[^}]*\}' after/tiffinbox-web/src/main/java/com/tiffinbox/web/BillingRuns.java) · C8 $($G -oE 'new ConcurrentHashMap<>\(\)|Thread\.ofVirtual\(\)' after/tiffinbox-web/src/main/java/com/tiffinbox/web/BillingRuns.java | paste -sd' ' -)"
  echo "  ProblemDetail.forStatus calls in src/main (unit 03's instance view greps them): before $(cd before && $G -rc 'ProblemDetail\.forStatus' tiffinbox-web/src/main | awk -F: '{ s += $2 } END { print s }') · after $(cd after && $G -rc 'ProblemDetail\.forStatus' tiffinbox-web/src/main | awk -F: '{ s += $2 } END { print s }')"; }
c_accept() {
  echo "== accept: the 202 on the wire (after/, 21060, H2, delay=on, the access log on; then delay=off, its own JVM)"
  ACC=1 tb accept 21060 on
  post 21060
  echo "  accept | delay=on | POST $BR -> $PW · file $(wc -c < $J/p.b | tr -d ' ') B · status line $(head -1 $J/p.h | tr -d '\r' | sed -E 's/^(HTTP\/1\.1 [0-9]{3}) *$/\1 <none>/') · Location $LOC · Retry-After $( [ -n "$(hv $J/p.h Retry-After)" ] && echo '<masked>' || echo absent) · state $(st $J/p.b)"
  tr -d '\r' < $J/p.h | $G -v '^$' | sed -E 's/^(Date): .*/\1: <masked>/; s/^/  accept | header /'
  echo "  accept | body members $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(list(d), "bills", d.get("bills"))' $J/p.b)"
  local w; w=$($CURL --http1.1 -sS -o $J/f.b -w '%{http_code} %{content_type}' "$LOC"); echo "  accept | delay=on | following Location -> $w · state $(st $J/f.b)"
  pollto "$LOC" "accept" > /dev/null
  sleep 0.2; acclog accept | sed 's/^/  accept | access log: /; s/^  accept | access log: GET /  ~ accept | access log: GET /'
  QUIET=1 tbstop accept 21060
  tb accept-off 21060 off > /dev/null
  post 21060
  echo "  ~ accept | delay=off | POST $BR -> $PW · state $(st $J/p.b) · Retry-After $( [ -n "$(hv $J/p.h Retry-After)" ] && echo present || echo absent) (the 202's own body: observed in the 202's body, a race at delay=off)"
  QUIET=1 tbstop accept-off 21060; }
c_poll() {
  echo "== poll: the status resource by its condition (after/, 21060, H2, delay=on; each poll sleeps Retry-After's own value; a 30 s alarm, a guard)"
  tb poll 21060 on > /dev/null; post 21060
  pollto "$LOC" "delay=on"
  echo "  poll | delay=on | states observed in order: $SEQ · every RUNNING poll carried Retry-After: $RUNRA · the first terminal poll carried Retry-After: $FIRSTTERM · alarm $ALARM"
  cp $LASTB $J/poll-final.b
  QUIET=1 tbstop poll 21060; }
c_bills() {
  echo "== bills: the poll capture's final body (H2, delay=on) beside V2's rows and Customer.monthlyBill()"
  echo "  bills | delay=on | the final body's bills: $(bl $J/poll-final.b)"
  echo "  bills | monthlyBill(): $($G -A1 'public int monthlyBill()' after/tiffinbox-core/src/main/java/com/tiffinbox/Customer.java | tail -1 | sed 's/^ *//')"
  $G "^INSERT INTO customer" after/tiffinbox-core/src/main/resources/db/migration/V2__seed.sql | sed -E "s/.*VALUES \('([A-Za-z]+)', ([0-9]+), ([0-9]+), .*/\1 \2 \3/" | sort | while read -r n m p; do echo "  bills | V2 row: $n meals $m price $p -> $((m * p * 30))"; done
  echo "  bills | the read: CustomerRepository.findAll (cached since Course 8): a fresh JVM per capture, so the run's read is the cache's first, cold"; }
c_restart() {
  echo "== restart: the failure receipt - JVM-1 (21060, delay=on) with a finished run and a RUNNING one, stopped; JVM-2 = the same jar, fresh (21065, H2, a fresh database), delay=on"
  tb restart-1 21060 on > /dev/null
  post 21060; local L2=$LOC; pollto "$L2" "JVM-1 id-2" > /dev/null; echo "  restart | JVM-1 | id-2 state: $(st $LASTB)"
  post 21060; local L1=$LOC; $CURL --http1.1 -sS -o $J/r1.b "$L1"; echo "  restart | JVM-1 | id-1 state at the stop: $(st $J/r1.b)"
  QUIET=1 tbstop restart-1 21060; echo "  restart | JVM-1 stopped by $STOPHOW"
  tb restart-2 21065 on > /dev/null; echo "  restart | JVM-2 port 21065"
  local i u w; for i in id-1 id-2; do [ $i = id-1 ] && u=${L1##*/} || u=${L2##*/}
    w=$($CURL --http1.1 -sS -o $J/r.b -w '%{http_code} %{content_type}' "$(B 21065)$BR/$u")
    echo "  restart | JVM-2 | GET $i -> $w · type $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d.get("type","none"), "· detail", d.get("detail"))' $J/r.b)"; done
  post 21065; local P2=$PW; pollto "$LOC" "JVM-2 control" > /dev/null
  echo "  restart | JVM-2 | the control: POST -> ${P2%% *} · polled to $(st $LASTB) · bills $(bl $LASTB)"
  QUIET=1 tbstop restart-2 21065; }
c_double() {
  echo "== double: C4 - the route is not in IdempotencyKeyFilter's table (after/, 21060, H2, delay=off, its own JVM)"
  tb double 21060 off > /dev/null
  post 21060; local a=${PW%% *} la=$LOC; post 21060; local b=${PW%% *} lb=$LOC
  local fa fb; fa=$($CURL -s -o /dev/null -w '%{http_code}' "$la"); fb=$($CURL -s -o /dev/null -w '%{http_code}' "$lb")
  echo "  double | two key-less POSTs -> $a $b · distinct ids $( [ "${la##*/}" != "${lb##*/}" ] && echo yes || echo no) · each followed -> $fa $fb"
  local KH; KH="Idempotency""-Key: u17-double-1"
  post 21060 -H "$KH"; local k1=${PW%% *} l1=$LOC; post 21060 -H "$KH"; local k2=${PW%% *} l2=$LOC
  echo "  double | one keyed POST -> $k1 · the same key again -> $k2 · distinct ids $( [ "${l1##*/}" != "${l2##*/}" ] && echo yes || echo no)"
  echo "  double | the filter's table: $($G -cE '^ +new Guarded\(' after/tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java) rows - $($G -oE 'parse\("[^"]*"\)' after/tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java | paste -sd' ' -); the key table's rows are not read by this harness-free JVM (no SQL client): the filter's table is the witness"
  QUIET=1 tbstop double 21060; }
prq() { local lab=$1 m=$2 q=$3 w
  w=$($CURL --http1.1 -sS -D $J/pr.h -o $J/pr.b -w '%{http_code} %{content_type}' --max-time 10 -X "$m" "$(B 21060)$q")
  echo "  refuse | $lab ($m $(echo "$q" | sed -E 's/[0-9a-f]{8}-[0-9a-f-]{27}/<uuid>/')) -> $w | $(python3 -I -c '
import json,sys
try:
    d=json.load(open(sys.argv[1],encoding="utf-8"))
    if "timestamp" in d: d["timestamp"]="<masked>"
    print(" · ".join("%s=%s" % (k, d[k]) for k in ("type","title","detail","instance","status","error","path") if k in d) + (" · type absent (no type of TiffinBox'"'"'s)" if "type" not in d else ""))
except Exception as e: print("not JSON · type absent")' $J/pr.b) · Allow {$(tr -d '\r' < $J/pr.h | sed -n 's/^[Aa]llow: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)}"; }
c_refuse() {
  echo "== refuse: every refusal form of the two routes (after/, 21060, H2, delay=off)"
  tb refuse 21060 off > /dev/null
  post 21060; local id=${LOC##*/}
  prq "an unknown id" GET $BR/00000000-0000-0000-0000-000000000000
  prq "a non-UUID id" GET $BR/abc
  prq "a query parameter on the POST" POST "$BR?x=1"
  prq "a query parameter on the status resource" GET "$BR/$id?x=1"
  prq "no list route" GET $BR
  prq "PUT on the status resource" PUT $BR/$id
  prq "DELETE on the status resource" DELETE $BR/$id
  prq "a trailing slash" GET $BR/$id/
  QUIET=1 tbstop refuse 21060; }
c_specwire() {
  echo "== specwire: the new routes' served entries against their wires (after/, 21060, harness-free, delay=on)"
  tb sw 21060 on > /dev/null
  $CURL -s "$(B 21060)/v3/api-docs" > $J/served.json
  python3 -I - $J/served.json <<'PY'
import json, sys
d = json.load(open(sys.argv[1])); p = d["paths"]["/api/v1/billing-runs"]["post"]; g = d["paths"]["/api/v1/billing-runs/{id}"]["get"]
print("  spec | POST /api/v1/billing-runs responses %s · operationId %s · parameters %s" % (sorted(p["responses"]), p["operationId"], [x["name"] for x in p.get("parameters", [])]))
print("  spec | GET /api/v1/billing-runs/{id} responses %s · operationId %s · parameters %s" % (sorted(g["responses"]), g["operationId"], [(x["name"], x["in"], x["schema"].get("type")) for x in g.get("parameters", [])]))
print("  spec | 202 headers %s · 202 content %s" % (sorted(p["responses"]["202"].get("headers", {})), list(p["responses"]["202"].get("content", {}))))
print("  spec | 200 headers %s · 200 content %s" % (sorted(g["responses"]["200"].get("headers", {})), list(g["responses"]["200"].get("content", {}))))
s = d["components"]["schemas"]["BillingRun"]
print("  spec | BillingRun properties %s · state enum %s · bills type %s · required %s" % (list(s["properties"]), s["properties"]["state"].get("enum"), s["properties"]["bills"].get("type"), s.get("required", [])))
PY
  post 21060
  echo "  wire | POST -> ${PW%% *} $(echo $PW | awk '{ print $2 }') members $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(list(d), "bills", d.get("bills"))' $J/p.b) · headers $(tr -d '\r' < $J/p.h | sed -n 's/^\([A-Za-z-]*\):.*/\1/p' | $G -vE '^(Date|Transfer-Encoding|Content-Length|Connection|Keep-Alive)$' | sort | paste -sd, -)"
  pollto "$LOC" sw > /dev/null
  echo "  wire | GET terminal -> 200 members $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(list(d))' $LASTB) · Retry-After $(hv $J/g.h Retry-After | sed 's/.\{1,\}/present/')$( [ -z "$(hv $J/g.h Retry-After)" ] && echo absent)"
  python3 -I - $J/served.json $J/p.b <<'PY'
import json, sys
d = json.load(open(sys.argv[1])); w = json.load(open(sys.argv[2])); s = d["components"]["schemas"]["BillingRun"]
gaps = []
if s.get("required", []) == []: gaps.append("required: the schema marks no member required; the wire always sends id, state and bills")
if "null" in (s["properties"]["bills"].get("type") or []): gaps.append("bills: documented as object or null; the wire sends null until SUCCEEDED - the spec cannot say which state carries which")
g = d["paths"]["/api/v1/billing-runs/{id}"]["get"]
if g["parameters"][0]["schema"].get("format") != "uuid": gaps.append("id: documented as a plain string; the route's ids are UUIDs, and a non-UUID id is the route's own four oh four")
gaps.append("Retry-After: documented as a string header on the 202 and the 200; the wire sends it only while RUNNING (the description says so, the schema cannot)")
p = d["paths"]["/api/v1/billing-runs"]["post"]
if "405" not in p["responses"] and "405" not in g["responses"]: gaps.append("the method refusals (PUT and DELETE on the status resource) are Framework's and not documented")
for x in gaps: print("  gap | " + x)
print("  gap | named: %d" % len(gaps))
PY
  QUIET=1 tbstop sw 21060; }
c_spec() {
  echo "== the committed spec: regenerated in this commit; read here against the served document (after/, 21060, harness-free, delay=off)"
  tb spec 21060 off > /dev/null
  local SF=after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json BF=before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json
  $CURL -s "$(B 21060)/v3/api-docs" > $J/served.json
  echo "  the committed file against the served document (servers removed, json.dump indent 2, ensure_ascii False, a final newline): $(python3 -I -c '
import json,sys
d=json.load(open(sys.argv[1])); d.pop("servers",None)
print("equal" if json.dumps(d,indent=2,ensure_ascii=False)+"\n" == open(sys.argv[2],encoding="utf-8").read() else "differ")' $J/served.json $SF)"
  echo "  committed md5 before $(md5 -q $BF) · after $(md5 -q $SF) · bytes before $(wc -c < $BF | tr -d ' ') · after $(wc -c < $SF | tr -d ' ')"
  echo "  the diff against before's (c3bc1b2's) file: $(diff $BF $SF | $G -c '^>') lines added, $(diff $BF $SF | $G -c '^<') removed"
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
  QUIET=1 tbstop spec 21060
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
  local bm; bm=$(sed -E 's/"timestamp":"[^"]*"/"timestamp":"<masked>"/; s/"next":"[^"]*"/"next":"<cursor>"/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/<uuid>/g' $J/mv.b | md5 -q | cut -c1-12)
  w=$(echo "$w" | awk '{ print $1, $2 }')
  echo "  $SIDE | $m $p$( [ -n "${TAG:-}" ] && echo " [$TAG]") -> $w · Allow {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Aa]llow: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)} · body $bm"; }
MPT='Content-Type: application/merge-patch+json'; JPT='Content-Type: application/json-patch+json'; CAPI=/api/v1/customers
movedside() { local side=$1 port=$2 a p
  TREE=$side tb moved-$side $port off > /dev/null
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
  TAG="the new routes" movedone $port GET $BR/00000000-0000-0000-0000-000000000000
  QUIET=1 tbstop moved-$side $port; }
c_moved() { echo "== U16's requests (its movedside list, copied; the order list's page one with its cursor masked; /v3/api-docs left out: the spec capture reads it), U16's route and the new status route, on before (21066) and after/ (21060), H2, each its own JVM, delay=off"
  movedside before 21066; movedside after 21060
  echo "  BOOT-INF/lib names: before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ')"
  python3 -I - .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar <<'PY'
import sys, zipfile
a = {i.filename: i.CRC for i in zipfile.ZipFile(sys.argv[1]).infolist()}; b = {i.filename: i.CRC for i in zipfile.ZipFile(sys.argv[2]).infolist()}
add = sorted(set(b) - set(a)); rem = sorted(set(a) - set(b)); mv = sorted(k for k in a if k in b and a[k] != b[k])
print("  jar | the web jar's entries: added %d %s · removed %d · shared entries whose CRC moved %d %s" % (len(add), add, len(rem), len(mv), mv))
PY
}
c_seven() {
  echo "== the seven (c5-unit11/curlset.sh, no key header), each tree its own JVM, H2, delay=off - not a witness for the new routes: it sends nothing to /api/v1/billing-runs"
  echo "  expected $S466"
  local s port i; for s in before after; do [ $s = before ] && port=21066 || port=21060
    TREE=$s tb seven-$s $port off > /dev/null
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
  echo "== the old surface by count (U16's reader, copied), each tree its own JVM, H2, delay=off - not a witness for the new routes"
  echo "  expected $U4SURF"
  for side in before after; do [ $side = before ] && port=21066 || port=21060
    TREE=$side tb surface-$side $port off > /dev/null
    oldsurface2 $port $J/surface-$side.txt
    QUIET=1 tbstop surface-$side $port
    echo "  $side: the old surface $(md5 -q $J/surface-$side.txt) ($($G -c '^== ' $J/surface-$side.txt) requests, $(wc -l < $J/surface-$side.txt | tr -d ' ') lines)"; done
  echo "  before -> after/: $(cmp -s $J/surface-before.txt $J/surface-after.txt && echo equal || echo DIFFER)"
  echo "  the S9.14 plant slot (21064): not captured this unit (dropped first by the prompt's order; not said)"; }
c_inert() {
  echo "== the key header across this run's captures (request lines and bodies)"
  echo "  key header outside the double capture: $(ls .r-*.new 2> /dev/null | $G -v '\.r-double\.new' | xargs cat 2> /dev/null | $G -v '^  double |' | $G -v 'IdempotencyKeyFilter' | $G -ciF "$KW" || true)"
  echo "  MockMvc runs carry the key header: $($G -ciF "$KW" after/tiffinbox-web/src/test/java/com/tiffinbox/web/BillingRunsTest.java || true)"
  echo "  IdempotencyKeyFilter's table: $($G -oE 'parse\("[^"]*"\)' after/tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java | paste -sd' ' -) - the new POST is not among them (C4 (a))"; }
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
  for c in BillingRunsTest OrderResourcesTest CustomerFieldsTest OrderPagesTest ApiVersionTest TiffinBoxRestDocsTest OpenApiSpecTest TiffinBoxWebTest; do cls .harness/pkg/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.$c.xml package $c; done
  echo "  ~ BillingRunsTest (MockMvc: no socket, no HTTP client; host localhost): $($G -cE '^BillingRunsTest: ' .harness/pkg.log) printed request lines (the polls vary in number: not said)"
  echo "== the Docker-free twin: after/'s own build (DOCKER_HOST=unix:///nonexistent/docker.sock, the run's first build)"
  for p in web client; do surefire .harness/after/tiffinbox-$p/target/surefire-reports "twin | tiffinbox-$p"; done
  echo "  slice TiffinBoxWebTest: after $(python3 -I -c 'import xml.etree.ElementTree as E,sys; print(E.parse(sys.argv[1]).getroot().get("tests"))' .harness/pkg/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.TiffinBoxWebTest.xml) tests · the slice's file byte-equal to before's: $(cmp -s before/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java after/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java && echo yes || echo no) - measured: no slice edit needed, CustomerRepository is already mocked ($($G -cE '@MockitoBean CustomerRepository' after/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java) line)"
  echo "  web tests before (unit 16's values): $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit16/README.md | $G -oE 'web_tests=[0-9]+' | head -1 | cut -d= -f2) · new @Test lines $($G -cE '^ +@Test$' after/tiffinbox-web/src/test/java/com/tiffinbox/web/BillingRunsTest.java)"
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
  if [ $sh = bash ]; then o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21068 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock bash -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1)
  else o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21068 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock /bin/zsh -f -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1); fi
  local pre="  $v $sh |"; [ $v = broken ] || [ $v = solved ] || pre="  ~ $v $sh |"
  printf '%s\n' "$o" | sed -E "s/127\.0\.0\.1:21068/127.0.0.1:<port>/g; s/^/$pre /"
  [ ! -f exercise/check.build.log ] || offl exercise/check.build.log
  [ "$(listeners 21068)" = 0 ] || die "the exercise left something listening on 21068"; }
c_exercise() { local v sh
  rm -rf .harness/exercise; mkdir -p .harness/exercise
  for v in broken solved; do for sh in bash zsh; do echo "  == $v, $sh"; exrun $v $sh; done; done
  if [ "$RUNNO" = 1 ] || [ "$RUNNO" = 0 ]; then for v in always never fixedelsewhere statehardcoded; do exrun $v bash; done; fi
  rm -rf exercise/check.run; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.b exercise/check.h exercise/check.polls
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures${DEVCAPS:+ (DEVELOPMENT: only $DEVCAPS - not a run of record)}"
cap advisory c_advisory
cap before c_before
cap change c_change
cap census c_census
cap accept c_accept
cap poll c_poll
cap bills c_bills
cap restart c_restart
cap double c_double
cap refuse c_refuse
cap specwire c_specwire
cap spec c_spec
cap moved c_moved
cap seven c_seven
cap surface c_surface
cap tests c_tests
cap exercise c_exercise
cap inert c_inert
echo "== plants (each made to FAIL first on a copy of this run's capture; harness/chk17.py plants)"
PL=$(ck plants .) || die "a plant was not caught: $(printf '%s\n' "$PL" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$PL" | $G '^ok ' | sed 's/^ok /  /'
PLV=$(printf '%s\n' "$PL" | sed -n 's/^VALUES //p')

# ---- the end: the sweep, the values, the published hashes -------------------------------------------------------------------------------
[ -z "$(echo $PIDS)" ] || die "a JVM of this run is still running: $PIDS"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
[ -z "$(dk ps -aq --filter label=org.testcontainers=true)" ] || die "a Testcontainers container of this run is left"
[ -z "$(dk ps -aq --filter name=^/c9u17-)" ] || die "a c9u17-* container is left"
NI1=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI1" = "$NI0" ] && [ "$VOL1" = "$VOL0" ] || die "R.322: images $NI0 -> $NI1, volumes $VOL0 -> $VOL1"
AD1=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true); [ "$AD1" = "$AD" ] || die "the anchor moved during the run"
pin before-tree before; pin after-tree after
MDB=$(find . ../c9-tiffinbox ../c9-unit16 -name '*.mv.db' -not -path './.harness/*' -not -path '../c9-unit16/.harness/*' 2> /dev/null | wc -l | tr -d ' ')
[ "$MDB" = 0 ] || die "an H2 file outside .harness/"
[ -z "$(ls exercise | $G -v -xE 'README.md|SOLUTION.md|apply.sh|break.sh|check.sh')" ] || die "the exercise left a file in exercise/"
VALS="$VALS
plants: $PLV
build: seed_files=$NF0 seed_bytes=$NB0 central_only=$CO"
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
[ -n "${DEVCAPS:-}" ] && { echo "c9-unit17: DEVELOPMENT run ($DEVCAPS) - nothing published"; exit 2; }
VO=$(ck values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; [ -n "${NOPIN:-}" ] || die "README.md's values block is not this run's"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM of this run, ports free, no container left, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1 · the anchor against after/ as at the start · the tree pins · *.mv.db outside .harness 0"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit17: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit17: every capture = published ($NCAPS) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"
