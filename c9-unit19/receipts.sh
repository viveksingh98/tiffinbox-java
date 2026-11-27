#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 19 "Rate Limiting" - this unit's receipts. Course 9's FIFTEENTH anchor change, Section 4's first:
# before is a link to ../c9-unit18/after (U18's after); after/ is a frozen copy of ../c9-tiffinbox after this unit's change - RateLimitFilter
# (a token bucket per client address on /api/v1/*, Bucket4j 8.23.0) and RateLimiting (its registration, the bucket in the JVM on the default
# run and in Redis under "dev"), bucket4j.version in the parent POM and the two Bucket4j artifacts in tiffinbox-web's, the two settings in
# application.yaml, RateLimitFilterTest, the anchor's README card.
# The harness's things, labelled on every capture that uses one: the run flags (--tiffinbox.rate-limit.capacity=5: cap=5; the harness's short
# refill period: period=short; --server.forward-headers-strategy=framework: flag=on), the harness's header-keyed copy (break.sh's edit on a
# scratch copy: "a made-up key"), the plant copy (application.yaml's capacity 5, never after/), the dev stores (four containers by digest).
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5; lines starting "  ~" are run-variant and
# left out of the hash - the refill's poll count, the exercise's refused variants of run 1):
#   advisory  the S9.36 read filed for this section (ADV4), verified, before any build; the new pins against it
#   before    seven reads on before (21086): no limit; the settings absent; the mappings; the counts the hand-off names
#   change    the modules, the POM diffs, the new files whole, the derived changed list, the registrations' patterns and orders, greps
#   census    the controllers on before and after/ by unit 15's printed rule
#   limit     seven reads on after/ (21080, cap=5): statuses, the refusal's headers and body, three byte witnesses, the access log, the log
#             line; the metrics scrape after it
#   forge     the forged headers after the address's refusal - on after/ (21080) and on the harness's header-keyed copy (21085); flag=on (xff)
#   refill    the refusal's Retry-After waited out by condition on the harness's short period (21080), then the next refusal
#   scope     what the filter counts and what it never touches, after the address's refusal (21080, cap=5)
#   twojvm    the profile "dev" with its four stores by digest: two JVMs (21080, 21085) on one Redis bucket, the key by redis-cli, the
#             key table on PostgreSQL; then Course 8's Lua counter on the same Redis (lua)
#   defaults  the web suite at the default (after/'s own build) and the plant at 5 (a scratch copy): the refusals counted
#   spec      the committed spec against the served one: unchanged, byte for byte; the refusal named as a filter's answer
#   moved     U18's requests on before (21086) and after/ (21080), the default capacity; the web jar's entries
#   api       every GET of the committed spec's /api/v1/ paths on before and after/, per-start values masked
#   seven     c5-unit11's seven on before and after/ · surface: the old surface by count on both - not witnesses for the limiter
#   inert     the key header across this run's captures
#   tests     package, the Docker-free twin, verify (Surefire on H2, the five ITs in Testcontainers), the web-only form, the lib lists
#   harness   the folder's files, the copied and adapted instruments with their named diffs, the static check (flag 31)
#   exercise  break.sh, check.sh, apply.sh on 21088, bash and zsh -f, H2; the refused variants (run 1)
# Ports (U19's band, 21080-21089): 21080 after/ (H2) and dev JVM A · 21081 PostgreSQL · 21082 Redis · 21083 MongoDB · 21084 Elasticsearch
# (the four dev stores, c9u19-*) · 21085 the second TiffinBox (dev JVM B; the header-keyed copy) · 21086 before · 21088 the exercise · 21087
# and 21089 never bound. During mvn verify only: 21280-21284. Every store on 127.0.0.1; every curl --noproxy '*'.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
C9R=${C9R:-"/Users/$ME/Downloads/Youtube Content/LearnProgrammingWithVivek/rest-apis-done-right"}   # the course's folder (briefs, research)
SEED=${SEED:-"$C9R/_research/m2-seed-c9-s4"}   # the course's Section 4 seed
PK4="$C9R/_research/s4-probe-2026-11-27"; BK4="$C9R/_research/s4-blue-2026-11-27"; ADV="$C9R/_research/docs-2026-11-27/advisories-s4probe"
S4B="$C9R/_briefs/UNIT-BRIEFS-S4-OPERATING.md"
export C9R
RUNNO=${RUNNO:-0}                                     # the run of record's number (1, 2, 3); 0 = development
SHORT=2s                                              # the harness's short refill period (period=short): a label, never voiced
H18=c5406fc                                           # unit 18's commit: the static check reads its objects, never the live anchor
PIMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
RIMG=redis@sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3
MIMG=mongo@sha256:05b334b0a7a78fe913caac0cd2e1ecccf4da515d9a3a44be911b6ea3734c17cd
EIMG=docker.elastic.co/elasticsearch/elasticsearch@sha256:fb7f2d0df199b3ea14a700e88a0b701d502cb44409ece3e1540b1dc1c5d5c403
GT=glibc.pthread.rseq=1                               # MongoDB's container setting (c8-unit22's)
ESSET="-e discovery.type=single-node -e xpack.security.enabled=false -e xpack.ml.enabled=false -e ingest.geoip.downloader.enabled=false -e xpack.inference.elastic.authorization.enabled=false"
CN=c9u19-pg; RN=c9u19-redis; MN=c9u19-mongo; EN=c9u19-es
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
export DOCKER_HOST="$DH"
PIDS=""; INTR=""; mpid=""; CTRS=""
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in $mpid $PIDS; do [ -z "$p" ] || killtree "$p"; done; for p in $mpid $PIDS; do if kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; for c in $CTRS; do dk rm -fv "$c" > /dev/null 2>&1; done; for c in $(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null); do dk rm -fv "$c" > /dev/null 2>&1; done; rm -rf exercise/check.run; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.h; [ -z "$INTR" ] || rm -f .r-*.new; rmdir .r-lock 2> /dev/null || rm -rf .r-lock; true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git unzip /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|SPRINGDOC_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|AWS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit19 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · $(curl --version | head -1 | cut -d' ' -f1-2) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }') · run $RUNNO"

# ---- gates before anything is built: the folder, the link, the pins, the anchor note, the static check, the prose, the exercise --------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk19.py dur9.py ops9s3.py s919.py tree19.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
for f in src presign seal9.py cdp.mjs cdp9.mjs loc9.py walk.py follow.py Presign.java; do [ ! -e harness/$f ] || die "harness/$f: an earlier unit's instrument this unit does not carry"; done
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md apply.sh break.sh check.sh' ] || die "exercise/ holds another file, or misses one"
[ -L before ] && [ "$(readlink before)" = ../c9-unit18/after ] || die "before must be a link whose text is exactly ../c9-unit18/after"
[ -d after ] && [ ! -L after ] || die "after/ is this unit's own frozen tree, a directory, not a link"
for t in before after; do [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-client/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/"; true; done
echo "  before -> $(readlink before) (a link, the text exact) · after/ a directory (the frozen copy) · no secrets/, target/ or .m2-demo/ in either · harness/: no Java, no seal9.py, cdp.mjs, cdp9.mjs, loc9.py, presign/ or src/"
[ "$(md5 -q harness/ops9s3.py)" = "$(md5 -q ../c9-unit18/harness/ops9s3.py)" ] || die "harness/ops9s3.py is not unit 18's copy, byte for byte"
[ "$(sed -n '5,$p' harness/tree19.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit18/harness/tree18.py | md5 -q)" ] || die "harness/tree19.py's code is not tree18.py's"
for u in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18; do [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit$u/harness/dur9.py)" ] || die "harness/dur9.py is not ../c9-unit$u's copy"; done
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; J8="$HOME/Desktop/PromptVidya-Automation/java8_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"
  [ ! -f "$C9R/_builders/dur9.py" ] || [ "$(md5 -q "$C9R/_builders/dur9.py")" = "$D9" ] || die "harness/dur9.py is not C9/_builders/dur9.py"
  TT=$(python3 -I -c '
import re,sys; t=open(sys.argv[1]).read().split("TITLES",1)[1]; u=open(sys.argv[2]).read().split("TITLES",1)[1]
for k in ("04","07","18","19","20"):
    m=re.search(r"\"%s\": *\"([^\"]+)\"" % k, t); print("%s=%s" % (k, m.group(1) if m else ""))
m=re.search(r"\"17\": *\"([^\"]+)\"", u); print("c8-17=%s" % (m.group(1) if m else ""))' "$J9" "$J8" | paste -sd'|' -)
  echo "  the titles, read off the registries (the call-backs, by title only, R.224): $TT"
else D9N="(the registry is not on this machine: U01-U18's copies are the pin)"; TT=""; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit01-18's copies $D9N · tree19.py's code = tree18.py's · ops9s3.py = unit 18's (md5 $(md5 -q harness/ops9s3.py))"
XS1=$(sed -n '/^# --- XFAM_S9S1 begin ---$/,/^# --- XFAM_S9S1 end ---$/p' harness/s919.py | md5 -q); XS1U=$(sed -n '/^# --- XFAM_S9S1 begin ---$/,/^# --- XFAM_S9S1 end ---$/p' ../c9-unit18/harness/s918.py | md5 -q)
[ "$XS1" = "$XS1U" ] || die "s919.py's XFAM_S9S1 slice is not U18's s918.py's"
echo "  s919.py: XFAM_S9S1's slice md5 $XS1 = ../c9-unit18/harness/s918.py's · its XU19C9 family this unit's (the carried base holds Course 8 unit 19's XU19) · lines outside XU19 differing from s918.py's (but for the names): $(diff <(sed '/^XU18 = {/,/^u04 = u18$/d' ../c9-unit18/harness/s918.py | sed 1d) <(sed '/^XU19C9 = {/,/^u04 = u19c9$/d' harness/s919.py | sed 1d) | $G -c '^[<>]')"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit18/receipts.md5)
[ "$UA" = "119 76acb633a6c6a530234c97ea495dc4f4" ] || die "../c9-unit18/receipts.md5's after-tree line is not 119 76acb633 ($UA)"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree19.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || { [ -n "${NOPIN:-}" ] && { echo "  $dir/: $got (NOPIN: no pin yet)"; return 0; }; die "receipts.md5 has no $nm line"; }
  [ "$nm" = after-tree ] || [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit18/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree19.py $dir/ -> $got = receipts.md5's $nm line$( [ "$nm" = before-tree ] && echo " = ../c9-unit18/receipts.md5's after-tree line")"; }
pin before-tree before; pin after-tree after
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true)
echo "  after/ against the live anchor (the start note): $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures its own frozen after/' )"
HF="harness/chk19.py harness/s919.py harness/tree19.py harness/dur9.py harness/ops9s3.py exercise/check.sh exercise/apply.sh exercise/break.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's scripts: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
ST=$(python3 -I -B harness/chk19.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
STMD5=$(printf '%s\n' "$ST" | md5 -q)
echo "  static (harness/chk19.py static after before; reads after/, before and git show $H18:… only - flag 31): $(printf '%s\n' "$ST" | $G -c '^ok ') checks, FAIL 0 · its output md5 $STMD5"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s919.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U19 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s919, per sentence): /'
PH=$($G -rnE 'PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b|<measure>' README.md exercise 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
GL=$(python3 -I -B harness/chk19.py gloss README.md) || die "the gloss: $(printf '%s\n' "$GL" | $G '^FAIL' | head -3 | paste -sd';' -)"
echo "  the gloss: $(printf '%s\n' "$GL" | $G -c '^ok ') checks, FAIL 0 ($(python3 -I -B harness/chk19.py gloss-line))"
HOOK=$(python3 -I -B harness/chk19.py hook) || die "the hook could not be extracted"; EXQ=$(python3 -I -B harness/chk19.py exq) || die "the exercise line could not be extracted"; GLS=$(python3 -I -B harness/chk19.py gloss-line)
IL=$(python3 -I -B harness/chk19.py interleaved) || die "the brief's interleaved hooks and exercises: $IL"
echo "  $IL"
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S4B's Unit 19 Hook line), byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
HW=$(printf '%s\n' "$HOOK" | wc -w | tr -d ' '); EW=$(printf '%s\n' "${EXQ#Your turn: }" | wc -w | tr -d ' '); GW=$(printf '%s\n' "$GLS" | wc -w | tr -d ' ')
HSW=$(printf '%s\n' "$HOOK" | python3 -I -c 'import re,sys; print(max(len(s.split()) for s in re.split(r"(?<=[.!?:])\s+", sys.stdin.read().strip()) if s))')
[ "$EW" -le 25 ] && [ "$GW" -le 25 ] && [ "$HSW" -le 25 ] || die "a spoken line over 25 words (exercise $EW, gloss $GW, the hook's longest sentence $HSW)"
echo "  the hook ($HW words, C14b: its longest sentence $HSW <= 25), the exercise's line ($EW words after 'Your turn:') and the gloss ($GW words), byte for byte; the hook and the line extracted from S4B's Unit 19 (md5 $(md5 -q "$S4B"))"
printf '%s\n\n%s\n\n%s\n' "$HOOK" "$EXQ" "$GLS" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s919.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
SWR=$(printf '%s\n' "$SW" | $G ' line ' | sed 's#.*spoken.md ##' | sort -u | paste -sd';' -)
echo "  the hook, the exercise's line and the gloss through s919.py: $(printf '%s\n' "$SW" | tail -1 | sed 's/.* refused: /refused /')$( [ -n "$SWR" ] && echo " - $SWR (handed to RED: the hook is the brief's, never edited)")"; rm -f .r-lock/spoken.md
TS="Spring Boot Rate Limiting with Bucket4j: 429 and Retry-After"
$G -qF "$TS" "$S4B" || die "the title for search is not S4B's"
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
DRL=$($G -v '^ *#' receipts.sh | $G -F 'dk run ' | $G -vF -- '--pull never' | wc -l | tr -d ' ')
[ "$DRL" = 0 ] || die "a dk run line without --pull never"
MVL=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -F '$MV ')
MVA=$(printf '%s\n' "$MVL" | $G -vF -- '-pl tiffinbox-web -am' | $G -vF -- '-pl tiffinbox-client -am' | $G -cF -- '-pl ' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh with a -pl form other than '-pl tiffinbox-web -am' or '-pl tiffinbox-client -am'"
MVS=$(printf '%s\n' "$MVL" | $G -cE -- ' -s | --settings ' || true); [ "$MVS" = 0 ] || die "RED4 #27: a Maven line with -s (the central-only settings fail offline)"
KW='idempotency''-key'; KH=$($G -v '^ *#' receipts.sh exercise/check.sh exercise/apply.sh exercise/break.sh | $G -iF "$KW" | $G -vcF 'KEYPOST' || true)
[ "$KH" = 0 ] || die "S9.21: a line of receipts.sh or the exercise names the key header outside scope (c)'s one request (KEYPOST)"
LA=$($G -nF 'c9-tiffinbox' receipts.sh exercise/check.sh exercise/apply.sh exercise/break.sh harness/tree19.py harness/chk19.py | $G -v ':[0-9]*: *#' | $G -vF 'AD=$(diff -rq' | $G -vF 'AD1=$(diff -rq' | $G -vF 'MDB=$(find' | $G -vF "\$G -nF 'c9-tiffinbox'" | $G -vF 'LIVE_ANCHOR_PLANT' | wc -l | tr -d ' ')
[ "$LA" = 0 ] || die "flag 31: a line of the receipts, the exercise or the harness reads the live anchor outside the start note, the end check and the H2-file sweep"
echo "  static: no kill by name; every docker call on the pinned socket, every removal rm -fv, every run --pull never; R.391's Maven forms only, no -s; the key header named by scope (c)'s one request only; the live anchor read only by the start note, the end check and the H2-file sweep (flag 31)"
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
    gsub(/127\.0\.0\.1:2108[0-9]/, "127.0.0.1:<port>")
    gsub(/expires=[0-9]+/, "expires=<masked>")
    gsub(/sig=[A-Za-z0-9_-]+/, "sig=<masked>")
    gsub(/[Rr]etry-[Aa]fter: [0-9]+/, "Retry-After: <n>")
    gsub(/PTTL [0-9]+/, "PTTL <n>"); gsub(/TTL [0-9]+/, "TTL <n>")
    gsub(/PT[0-9]+[HMS.0-9]*/, "PT<n>")
    gsub(/nanosToRefill=[0-9]+/, "nanosToRefill=<n>")
    gsub(/refill-period=[0-9]+[smh]/, "refill-period=<period>")
    gsub(/refill period [0-9]+[smh]/, "refill period <period>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'took 812 ms' '"timestamp":"2026-11-01T08:09:00.123Z"' "$U/x $HOME/y" 'Retry-After: 60 · retry-after: 2' 'GET http://127.0.0.1:21080/x · PTTL 119302 · PT1M · nanosToRefill=59000' '--tiffinbox.rate-limit.refill-period=2s · rate limit: capacity 5 per refill period 1m, the' | mask)
[ "$(printf '%s\n' "$MP" | paste -sd'|' -)" = 'Started TiffinBoxServer in <t> (process running for <t>)|took <t>|"timestamp":"<time>"|…/x ~/y|Retry-After: <n> · Retry-After: <n>|GET http://127.0.0.1:<port>/x · PTTL <n> · PT<n> · nanosToRefill=<n>|--tiffinbox.rate-limit.refill-period=<period> · rate limit: capacity 5 per refill period <period>, the' ] || die "the mask's self-test: $(printf '%s\n' "$MP" | paste -sd'|' -)"
echo "  masks: the log mask masked a Started line's times, a millisecond count, a timestamp, the folders, the home, Retry-After's value (both cases), a band port, Redis's PTTL, a PT duration, nanosToRefill, the period on a command line and in the start's line (self-test)"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh); [ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SURF=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh); [ ${#U4SURF} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh (SURF=)"
U18V=$(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit18/README.md | $G -E '^(seven|surface): ' | $G -oE '(seven|surface)=[0-9a-f]{8}' | paste -sd' ' -)
[ "$U18V" = "seven=$(echo $S466 | cut -c1-8) surface=$(echo $U4SURF | cut -c1-8)" ] || die "U18's README values block ($U18V) is not the seven and the surface read off the receipts"
echo "  the seven: expected $S466 (../c7-unit31/receipts.sh's S466= line) · the old surface: expected $U4SURF (../c9-unit04/receipts.sh's SURF= line) · both = U18's values block ($U18V)"
echo "  the probe's limiter captures (PK4/captures/h41, h41redis - read, not copied: the expectation on the probe's class, 1 run): $(ls "$PK4/captures/h41" 2> /dev/null | wc -l | tr -d ' ') + $(ls "$PK4/captures/h41redis" 2> /dev/null | wc -l | tr -d ' ') files · BLUE's s-default.mvn.log md5 $(md5 -q "$BK4/out/s-default.mvn.log") · s-plant5.mvn.log md5 $(md5 -q "$BK4/out/s-plant5.mvn.log") · BlueRateLimits.java md5 $(md5 -q "$BK4/instruments/BlueRateLimits.java") (read for its shape, not copied)"

# ---- docker, ports, the guard: the baselines ----------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run"
[ -z "$(dk ps -aq --filter name=^/c9u19- 2> /dev/null)" ] || die "a c9u19-* container exists before the run"
for im in "$PIMG" "$RIMG" "$MIMG" "$EIMG"; do [ -n "$(dk images --digests --format '{{.Repository}}@{{.Digest}}' 2> /dev/null | $G -xF "$im")" ] || die "an image is not on the daemon by its digest (no pull here - a STOP): $im"; done
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
BAND="21080 21081 21082 21083 21084 21085 21086 21087 21088 21089"
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
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · nothing pulled · the four dev images on the daemon by digest · no Testcontainers or c9u19-* container · ports free (21087, 21089 and 21110-21119 included, never bound)"

# ---- the trees, copied and built offline: before (through the link), after/; the header-keyed copy; the plant copy --------------------------
M2="$PWD/.m2-demo"
if [ ! -d "$M2" ]; then [ -d "$SEED" ] || die "the seed $SEED is missing"; cp -cR "$SEED" "$M2" 2> /dev/null || cp -R "$SEED" "$M2" || die "the seed could not be copied"; fi
NF0=$(find "$M2" -type f | wc -l | tr -d ' '); NB0=$(find "$M2" -type f -print0 | xargs -0 stat -f %z | awk '{ s += $1 } END { printf "%d", s }')
CO=$(find "$M2" -name _remote.repositories -print0 | xargs -0 $G -l 'central-only' 2> /dev/null | wc -l | tr -d ' ')
[ "$CO" = 0 ] || die "$CO _remote.repositories files in the seed copy still name central-only"
ART="org/springframework/boot/spring-boot-starter-parent/4.1.3 com/bucket4j/bucket4j_jdk17-core/8.23.0 com/bucket4j/bucket4j_jdk17-lettuce/8.23.0 com/bucket4j/bucket4j_jdk17-redis-common/8.23.0 io/lettuce/lettuce-core/7.5.2.RELEASE"
for a in $ART; do [ -n "$(ls "$M2/$a" 2> /dev/null | $G -E '\.(jar|pom)$')" ] || die ".m2-demo holds no $a (no seed act here: report the coordinates)"; done
echo "  .m2-demo (a copy of the seed m2-seed-c9-s4): files $NF0 · bytes $NB0 · _remote.repositories naming central-only: $CO"
for a in $ART; do echo "  seed | $a | $(ls "$M2/$a" | $G -E '\.(jar|pom)$' | paste -sd' ' -)"; done
mkdir -p .harness; for d in before after pkg tests webonly exercise run work need-forge plant-cap5 dev; do rm -rf .harness/$d; done
mkdir -p .harness/home .harness/run .harness/work .harness/dev
printf '%s\n' 'checks.disable=true' > .harness/home/.testcontainers.properties
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy before .harness/before; copy after .harness/after; copy after .harness/need-forge; copy after .harness/plant-cap5
JL=(-Duser.language=en -Duser.country=US)
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE 'Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" HOME=\"$U/.harness/home\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 900; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
AL="-DargLine=-Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Duser.home=../../home"
extract() { bg "cd .harness/$1 && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$1.log
  [ "$RE" = 0 ] || die ".harness/$1: the jar's extract failed"; }
guard "the build of before"
bg "cd .harness/before && $MV -DskipTests clean package -pl tiffinbox-web -am" .harness/build-before.log
[ "$RE" = 0 ] || { tail -30 .harness/build-before.log | mask >&3; die ".harness/before did not build offline (exit $RE)"; }; offl .harness/build-before.log
echo "  built before offline (mvn -o -DskipTests clean package -pl tiffinbox-web -am; exit 0, Downloading/Downloaded from: 0)"
guard "the build of after"
bg "cd .harness/after && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package" .harness/build-after.log
[ "$RE" = 0 ] || { tail -30 .harness/build-after.log | mask >&3; die ".harness/after did not build offline (exit $RE)"; }; offl .harness/build-after.log
echo "  built after/ offline WITH its tests, Docker-free (mvn -o clean package, the whole reactor: $($G -E '^\[INFO\] TiffinBox[A-Za-z ]* \.+ SUCCESS' .harness/build-after.log | sed -E 's/^\[INFO\] (TiffinBox[A-Za-z ]*) \.+ SUCCESS.*/\1/' | paste -sd, -); exit 0) - the jars come from this build; it is the tests capture's Docker-free twin and defaults' run at the default"
BRK=$(cd exercise && sh break.sh ../.harness/need-forge) || die "break.sh did not edit the header-keyed copy"
guard "the build of the header-keyed copy"
bg "cd .harness/need-forge && $MV -DskipTests clean package -pl tiffinbox-web -am" .harness/build-need-forge.log
[ "$RE" = 0 ] || die "the harness's header-keyed copy did not build offline (exit $RE)"; offl .harness/build-need-forge.log
echo "  the harness's header-keyed copy (.harness/need-forge, a made-up key): $BRK · built offline (-DskipTests -pl tiffinbox-web -am, exit 0)"
extract before; extract after
B() { echo "http://127.0.0.1:$1"; }
J=.harness/work
ALP='%m %U%q %s %b'
# tb LABEL PORT [args]: TiffinBox (the extracted jar of TREE=after unless TREE is set; TREE=need-forge: the header-keyed copy's jar), from its
# own run folder with a generated token (0600, never printed), H2 in memory (fresh per JVM) unless DEVRUN=1, waited for by its Started line.
# ACC=1: Tomcat's access log. DEVRUN=1: the datasource from the run folder's config tree (the URL file 0600, never printed).
tb() { local label=$1 port=$2 t=${TREE:-after} run=.harness/run/$1 i=0; shift 2
  guard "TiffinBox $label"
  for q in 21087 21089; do [ "$(listeners $q)" = 0 ] && [ -z "$(lsof -nP -iUDP:$q 2> /dev/null)" ] || die "$q must stay free (TCP and UDP)"; done
  [ "$(listeners $port)" = 0 ] && [ -z "$(lsof -nP -iUDP:$port 2> /dev/null)" ] || die "$port is bound before $label"
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  [ -z "${DEVRUN:-}" ] || (umask 077 && printf 'jdbc:postgresql://127.0.0.1:21081/tiffinbox?user=tiffinbox&password=%s\n' "$PW" > "$run/secrets/tiffinbox/jdbc-url") || die "the URL was not written"
  local x="$U/.harness/$t/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  local ax=(); [ -n "${ACC:-}" ] && ax=(--server.tomcat.accesslog.enabled=true "--server.tomcat.accesslog.directory=$U/$run" --server.tomcat.accesslog.prefix=access --server.tomcat.accesslog.suffix=.log --server.tomcat.accesslog.rotate=false --server.tomcat.accesslog.buffered=false "--server.tomcat.accesslog.pattern=$ALP")
  local main=com.tiffinbox.web.TiffinBoxServer
  echo "java -cp <tree $t> $main --tiffinbox.port=$port $( [ -n "${ACC:-}" ] && echo '<the access log>') $*" > "$run/cmd"
  if [ "$t" = after ] || [ "$t" = before ]; then
    (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java "${JL[@]}" -Dstdout.encoding=UTF-8 -cp "$cp" $main --tiffinbox.port="$port" "${ax[@]}" "$@" > jvm.log 2>&1) &
  else
    (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java "${JL[@]}" -Dstdout.encoding=UTF-8 -jar "$U/.harness/$t/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" --tiffinbox.port="$port" "${ax[@]}" "$@" > jvm.log 2>&1) &
  fi
  local p=$!; echo $p > "$run/pid"; PIDS="$PIDS $p"; MINE="${MINE:-} $port"
  while ! $G -q -E 'Started TiffinBox(App|Server) in' "$run/jvm.log" 2> /dev/null; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before its Started line"; }; i=$((i + 1)); [ $i -lt 1200 ] || die "$label: no Started line"; sleep 0.1; done
  local dup; dup=$(tr ' ' '\n' < "$run/cmd" | $G -E '^--' | sed 's/=.*//' | sort | uniq -d | paste -sd, -); [ -z "$dup" ] || die "R.444: a flag twice on $label's command line ($dup)"
  SETL=$($G -F 'rate limit: capacity' "$run/jvm.log" | sed -E 's/^.*tiffinbox\.ratelimit +: //' | head -1)
  echo "  $label up on $port ($( [ -n "${DEVRUN:-}" ] && echo 'profile dev, PostgreSQL' || echo H2), tree $t$( [ "$t" = need-forge ] && echo " - the harness's header-keyed copy, a made-up key")$( [ -n "${ACC:-}" ] && echo ", the access log on") · the setting read back by its start line: $SETL · $(sed 's/ *$//' "$run/cmd")"; }
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
  mask < .harness/cap-$nm.raw > .r-$nm.new
  sed 's/^/  | /' .r-$nm.new | cut -c1-260
  local o e=0; o=$(python3 -I -B harness/chk19.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk19 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; [ -n "${DEVCAPS:-}${NOPIN:-}" ] && { echo "  (development: $nm's check failed, the run goes on)"; unpub="$unpub $nm"; } || die "$nm: its check failed (harness/chk19.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk19.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-11s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-11s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff .r-$nm.new against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }
CB=/api/v1/customers; BR=/api/v1/billing-runs; OR=/api/v1/orders; RV=/api/v1/customers/Ravi
# req LABEL PORT [curl args] URI: one request; prints the status line, Content-Type, Content-Length, Retry-After (masked by the mask), the
# body's bytes (curl's count and the file's) and, for a problem, its members (python). Leaves $J/r.h and $J/r.b.
req() { local lab=$1 port=$2 w; shift 2; local u="${@: -1}"; set -- "${@:1:$(($# - 1))}"; : > $J/r.h; : > $J/r.b
  w=$($CURL --http1.1 -sS -D $J/r.h -o $J/r.b -w '%{http_code} %{size_download}' --max-time 30 "$@" "$(B $port)$u")
  python3 -I - "$lab" "$w" $J/r.h $J/r.b <<'PY'
import sys, json, os
lab, w, hf, bf = sys.argv[1:5]
st, sz = w.split()
hs = [l.rstrip("\r\n") for l in open(hf, encoding="latin-1")]
h = {}
for l in hs[1:]:
    if ":" in l: k, v = l.split(":", 1); h[k.strip().lower()] = v.strip()
fb = os.path.getsize(bf)
out = "  %s | %s -> %s · Content-Type %s · Content-Length %s · curl %s B · file %d B" % (lab, sys.argv[1] and hs[0].strip() if hs else "", st, h.get("content-type", "-"), h.get("content-length", "-"), sz, fb)
if "retry-after" in h:
    v = h["retry-after"]
    out += " · Retry-After: %s (an integer: %s)" % (v, "yes" if v.isdigit() else "no")
if h.get("content-type", "").startswith("application/problem+json"):
    try:
        d = json.load(open(bf, encoding="utf-8")); out += " · members %s · type %s · title %s · status %s · instance %s" % (",".join(d), d.get("type"), d.get("title"), d.get("status"), d.get("instance"))
    except Exception: out += " · not JSON"
print(out)
PY
}
st() { $CURL --http1.1 -s -o /dev/null -w '%{http_code}' --max-time 30 "$@"; }
acclog() { cat .harness/run/$1/access*.log 2> /dev/null | sed -E 's/^([A-Z]+ [^ ]*)- /\1 /; s/ +$//'; }   # %q prints - for no query: dropped
refusals() { $G -c 'rate limit: refused' .harness/run/$1/jvm.log || true; }
raval() { tr -d '\r' < $J/r.h | sed -n 's/^[Rr]etry-[Aa]fter: *//p' | head -1; }
spend() { local port=$1 n=0 s; while :; do s=$(st "$(B $port)$RV"); n=$((n + 1)); [ "$s" = 429 ] && break; [ $n -lt 20 ] || die "no refusal after 20 requests on $port"; done; echo "$n"; }
CAP5=--tiffinbox.rate-limit.capacity=5

# ---- the captures ----------------------------------------------------------------------------------------------------------------------
c_advisory() {
  echo "== S9.36: the read filed for Section 4 (ADV4 = _research/docs-2026-11-27/advisories-s4probe, the S4 probe's dated act; not re-read: no network), before any capture"
  echo "  fetched-at $(head -1 "$ADV/fetched-at.txt" | cut -c1-10) (the hour masked) · run date $(date '+%Y-%m-%d') · the batch day's other read (advisories/) fetched-at $(head -1 "$ADV/../advisories/fetched-at.txt" | cut -c1-10)"
  local d n=0 v=0 f h; for d in "$ADV" "$ADV/../advisories"; do n=0; v=0; while read -r h f; do n=$((n + 1)); [ "$(md5 -q "$d/$f" 2> /dev/null)" = "$h" ] && v=$((v + 1)); done < <($G -vE '^\s*$' "$d/MD5SUMS.txt" | awk '$2 != "MD5SUMS.txt" { print $1, $2 }')
    echo "  $(basename "$d")/MD5SUMS.txt: $n lines, $v verified (its own line left out)"; done
  echo "  spring index: CVE ids on its first page $($G -oE 'CVE-[0-9]{4}-[0-9]+' "$ADV/spring-security-index.html" | sort -u | wc -l | tr -d ' ') · the dates on the page: $($G -oE '(January|February|March|April|May|June|July|August|September|October|November|December) [0-9]{1,2}, 2026' "$ADV/spring-security-index.html" | sort | uniq -c | sed -E 's/^ +//' | paste -sd'|' -)"
  echo "  tomcat page md5 $(md5 -q "$ADV/tomcat-security-11.html") (the 11-24, 11-26 and 11-27 00:51 reads: a1a756d985225fb5143eefd9aae3183c)"
  local a; for a in spring-boot spring-web spring-webmvc tomcat-embed-core lettuce-core bucket4j_jdk17-core bucket4j_jdk17-lettuce bucket4j_jdk17-redis-common; do
    echo "  shipped | $a $(ls .harness/after/$XD/lib | $G -E "^$a-[0-9]" | sed -E "s/^$a-//; s/\.jar$//" | paste -sd, -)"; done
  python3 -I - "$ADV/osv-query.json" "$ADV/osv-result.json" <<'PY'
import json, sys
q = json.load(open(sys.argv[1]))["queries"]; r = json.load(open(sys.argv[2])).get("results", [])
print("  osv (second witness only, S2.8): %d coordinates queried, %d results, %d with vulns" % (len(q), len(r), sum(1 for x in r if x.get("vulns"))))
for x in q:
    if x["package"]["name"].startswith(("com.bucket4j", "io.lettuce")): print("  osv | queried %s %s" % (x["package"]["name"], x["version"]))
PY
  local l; for l in bucket4j_jdk17-core bucket4j_jdk17-lettuce bucket4j_jdk17-redis-common; do echo "  licence | $l 8.23.0: $(sed -n '/<licenses>/,/<\/licenses>/p' "$C9R/_research/sweep-2026-11-27/licences/$l-8.23.0.pom" | $G -oE '<name>[^<]*' | sed 's/<name>//' | paste -sd'|' -)"; done
  echo "  lib names before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ')"
  echo "  verdict: no pin affected; evidence may proceed (the read is the batch day's: run date = fetched-at date); nothing else was read from the network"; }
mappings() { $CURL -s "$(B $1)/actuator/mappings" | python3 -I -c '
import json,sys
d=json.load(sys.stdin); ps=[]
for c in d["contexts"].values():
    for m in c["mappings"]["dispatcherServlets"]["dispatcherServlet"]:
        rc=(m.get("details") or {}).get("requestMappingConditions")
        if rc: ps += [p for p in rc.get("patterns", [])]
print("  %s | mappings %d · under /api/v1/ %d (rule: the request-mapping patterns of the dispatcher servlet)" % (sys.argv[1], len(ps), sum(1 for p in ps if p.startswith("/api/v1/"))))
fl=[]
for c in d["contexts"].values():
    for f in c["mappings"].get("servletFilters", []): fl.append("%s %s" % (f.get("name"), ",".join(f.get("urlPatternMappings", []))))
print("  %s | servlet filters: %s" % (sys.argv[1], " · ".join(sorted(fl))))' "$2"; }
c_before() {
  echo "== before (21086, U18's after, H2; the setting does not exist there; the harness's exposure flag for /actuator/mappings), seven reads"
  TREE=before ACC=1 tb before 21086 --management.endpoints.web.exposure.include=health,prometheus,mappings
  local i; for i in 1 2 3 4 5 6 7; do req "before #$i" 21086 $RV; done
  echo "  before | the access log: $(acclog before | wc -l | tr -d ' ') lines · statuses $(acclog before | awk '{ print $3 }' | sort | uniq -c | sed -E 's/^ +//' | paste -sd' ' -)"
  acclog before | sed 's/^/  before | access /'
  echo "  before | refusal lines in the JVM's log: $(refusals before) · the setting's line in the start's log: $($G -c 'rate limit: capacity' .harness/run/before/jvm.log || true) · rate-limit keys in before's application.yaml: $($G -c 'rate-limit' before/tiffinbox-web/src/main/resources/application.yaml || true)"
  mappings 21086 before
  echo "  before | the committed spec: $(python3 -I harness/ops9s3.py ops before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tail -1) · $(wc -c < before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tr -d ' ') B md5 $(md5 -q before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json)"
  echo "  before | BOOT-INF/lib names $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · bucket4j jars $(ls .harness/before/$XD/lib | $G -c bucket4j || true)"
  QUIET=1 tbstop before 21086; }
census() { python3 -I - "$1/tiffinbox-web/src/main/java/com/tiffinbox/web" "$2" <<'PY'
import os, re, sys
d, side = sys.argv[1], sys.argv[2]
print("  census %s | rule (unit 15's, copied off unit 18's receipts): a class whose annotation lines (the lines between the Javadoc's end and its declaration) include exactly @RestController or @Controller; its final modifier; @Profile(\"dev\") among those lines" % side)
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
        elif m.group(4) in ("RateLimitFilter", "RateLimiting"):
            print("  census %s | not a controller by the rule: %s (%s:%d) - annotations %s" % (side, m.group(4), f, i + 1, sorted(names) or "none"))
        break
for r in rows:
    print("  census %s | %-16s final %-3s dev-only %-3s %s:%d" % (side, r[0], "yes" if r[1] else "no", "yes" if r[2] else "no", r[3], r[4]))
for e in excl:
    print("  census %s | excluded by the rule: %s (%s:%d) - annotated @RestControllerAdvice" % ((side,) + e))
fd = sum(1 for r in rows if r[1] and not r[2]); nd = sum(1 for r in rows if not r[1] and r[2]); nf = sum(1 for r in rows if not r[1] and not r[2])
print("  census %s | controllers %d · final, default-run %d · not final, default-run %d · not final, dev-only %d · other %d" % (side, len(rows), fd, nf, nd, len(rows) - fd - nd - nf))
PY
}
c_census() { echo "== the controllers on before and after/ (R.527: each derived on its own tree)"; census before before; census after after
  echo "  the spec's counts (ops9s3.py, each tree's own committed file): before $(python3 -I harness/ops9s3.py ops before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tail -1) · after $(python3 -I harness/ops9s3.py ops after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tail -1)"; }
RLF=tiffinbox-web/src/main/java/com/tiffinbox/web/RateLimitFilter.java; RLC=tiffinbox-web/src/main/java/com/tiffinbox/web/RateLimiting.java; RLT=tiffinbox-web/src/test/java/com/tiffinbox/web/RateLimitFilterTest.java
c_change() {
  echo "== the modules, the change file by file"
  echo "  modules: $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' before/pom.xml | paste -sd' ' -) ($($G -c '<module>' before/pom.xml)) -> $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' after/pom.xml | paste -sd' ' -) ($($G -c '<module>' after/pom.xml))"
  echo "  changed (derived: diff -rq before after/, the frozen trees - git status --short gave the same list before the commit): $(diff -rq before/ after/ | sed -E 's#^Files before/(.*) and after/.* differ$#M \1#; s#^Only in after/(.*): (.*)$#A \1/\2#; s#^Only in after/: (.*)$#A \1#; s#^Only in before/(.*): (.*)$#D \1/\2#' | sort | paste -sd'~' - | sed 's/~/ · /g')"
  local f; for f in pom.xml tiffinbox-web/pom.xml tiffinbox-web/src/main/resources/application.yaml; do echo "== $f: the diff against before's (whole)"; diff before/$f after/$f | sed 's/^/    /'; done
  for f in $RLF $RLC $RLT; do echo "== $f (whole, md5 $(md5 -q after/$f))"; sed 's/^/    /' after/$f; done
  echo "  bucket4j.version in the parent POM: $($G -c '<bucket4j.version>' after/pom.xml) line(s) · the literal 8.23.0 in tiffinbox-web/pom.xml: $($G -c '8\.23\.0' after/tiffinbox-web/pom.xml || true) · \${bucket4j.version} in it: $($G -c 'bucket4j.version' after/tiffinbox-web/pom.xml)"
  echo "  RateLimitFilter: $($G -E '^public final class' after/$RLF) · header reads (getHeader( / getHeaders(): $($G -cE 'getHeaders?\(' after/$RLF || true) · getWriter(: $($G -c 'getWriter(' after/$RLF || true) · getOutputStream(): $($G -c 'getOutputStream()' after/$RLF)"
  echo "  src/main: X-Api-Key $(cd after && $G -rhF 'X-Api-Key' tiffinbox-web/src/main | wc -l | tr -d ' ') lines · X-Forwarded-For $(cd after && $G -rhF 'X-Forwarded-For' tiffinbox-web/src/main | wc -l | tr -d ' ') · X-Forwarded in the two new classes $($G -hF 'X-Forwarded' after/$RLF after/$RLC | wc -l | tr -d ' ') · Probe/R4/probe.s4 $(cd after && $G -rhE '(^|[^A-Za-z])Probe|probe\.s4|(^|[^A-Za-z0-9])R4([^A-Za-z0-9]|$)' tiffinbox-web/src/main | wc -l | tr -d ' ') · @Component in the two new classes $($G -c '@Component' after/$RLF after/$RLC | awk -F: '{ s += $2 } END { print s }')"
  echo "  the registrations' patterns and orders (the source): $($G -E 'addUrlPatterns|static final int ORDER' after/$RLC after/tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeys.java | sed -E 's#^after/tiffinbox-web/src/main/java/com/tiffinbox/web/##; s/ +/ /g' | paste -sd'|' -)"
  for n in TiffinBoxErrors TiffinBoxOpenApi TiffinBoxApiVersioning IdempotencyKeys IdempotencyKeyFilter CustomerBills CustomerReads RedisDatastore; do echo "  $n.java byte-equal to before's: $(cmp -s before/tiffinbox-web/src/main/java/com/tiffinbox/web/$n.java after/tiffinbox-web/src/main/java/com/tiffinbox/web/$n.java && echo yes || echo no)"; done
  for f in Dockerfile compose.yaml tiffinbox-web/src/main/resources/application-dev.yaml tiffinbox-core/pom.xml tiffinbox-client/pom.xml; do echo "  $f byte-equal to before's: $(cmp -s before/$f after/$f && echo yes || echo no)"; done
  echo "  handler names added: $(diff <(cd before && $G -rhE -A3 '@(Get|Post|Put|Patch|Delete|Request)Mapping' tiffinbox-web/src/main/java | $G -oE ' [a-z][A-Za-z]*\(' | sort -u) <(cd after && $G -rhE -A3 '@(Get|Post|Put|Patch|Delete|Request)Mapping' tiffinbox-web/src/main/java | $G -oE ' [a-z][A-Za-z]*\(' | sort -u) | $G -c '^>' || true) (U19 adds no route)"
  echo "  the web jar: bucket4j and lettuce entries in BOOT-INF/lib: $(unzip -l .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | $G -oE 'BOOT-INF/lib/(bucket4j|lettuce)[^ ]*' | sed 's#BOOT-INF/lib/##' | paste -sd' ' -)"
  echo "  mvn dependency:tree (the web module, -o, filtered to bucket4j and lettuce):"
  bg "cd .harness/after && $MV dependency:tree -pl tiffinbox-web -am" .harness/deptree.log; offl .harness/deptree.log
  $G -E 'bucket4j|lettuce' .harness/deptree.log | sed -E 's/^\[INFO\] //; s/^/    /'; }
c_limit() {
  echo "== limit: seven reads of $RV on after/ (21080, H2, cap=5 - the run flag $CAP5; the default read back by the yaml line), then one metrics scrape on the same JVM"
  echo "  application.yaml | $($G -E '^  rate-limit:|^    capacity:|^    refill-period:' after/tiffinbox-web/src/main/resources/application.yaml | sed 's/^ *//' | paste -sd' ' -)"
  ACC=1 tb limit 21080 $CAP5
  local i; for i in 1 2 3 4 5 6 7; do req "limit #$i" 21080 $RV; [ $i = 6 ] && { cp $J/r.h $J/limit6.h; cp $J/r.b $J/limit6.b; }; done
  echo "  limit | the sixth answer, its headers in full:"; tr -d '\r' < $J/limit6.h | sed -E 's/^Date: .*/Date: <masked>/' | $G -v '^$' | sed 's/^/    /'
  echo "  limit | its body: $(cat $J/limit6.b)"
  python3 -I - $J/limit6.h $J/limit6.b <<'PY'
import sys, re
h = open(sys.argv[1], encoding="latin-1").read(); b = open(sys.argv[2], "rb").read()
ct = re.search(r"(?im)^content-type: *(.*?)\r?$", h).group(1); cs = re.search(r"charset=([^;\s]+)", ct)
ra = re.search(r"(?im)^retry-after: *(\d+)\r?$", h)
print("  limit | python: Content-Type %s · a charset other than UTF-8: %s · Retry-After an integer >= 1 and <= the period's seconds (60, read off application.yaml's 1m): %s · Content-Length = the body's bytes: %s · chunked: %s" % (
    ct, "yes" if cs and cs.group(1).upper() != "UTF-8" else "no", "yes" if ra and 1 <= int(ra.group(1)) <= 60 else "no",
    "yes" if re.search(r"(?im)^content-length: *%d\r?$" % len(b), h) else "no", "yes" if re.search(r"(?im)^transfer-encoding: *chunked", h) else "no"))
PY
  echo "  limit | the access log: $(acclog limit | wc -l | tr -d ' ') lines · statuses $(acclog limit | awk '{ print $3 }' | paste -sd' ' -) · the refusals' %b $(acclog limit | awk '$3 == 429 { print $4 }' | sort -u | paste -sd, -)"
  acclog limit | sed 's/^/  limit | access /'
  echo "  limit | refusal lines in the JVM's log: $(refusals limit) · their form: $($G -F 'rate limit: refused' .harness/run/limit/jvm.log | head -1 | sed -E 's/^.*tiffinbox\.ratelimit +: //') · the address named in them: $($G -F 'rate limit: refused' .harness/run/limit/jvm.log | $G -c '127\.0\.0\.1' || true)"
  echo "  limit | Redis connection lines in the default run's log (Lettuce, RedisClient, redis://): $($G -ciE 'lettuce|RedisClient|redis://' .harness/run/limit/jvm.log || true)"
  echo "  limit | server.forward-headers-strategy on the command line or in application.yaml: $($G -c 'forward-headers' .harness/run/limit/cmd after/tiffinbox-web/src/main/resources/application.yaml | awk -F: '{ s += $2 } END { print s }') (Boot's default)"
  echo "== metrics: one scrape of /actuator/prometheus on the same JVM after the seven (the counts and their tags; no _sum, no _max, no duration)"
  $CURL -s "$(B 21080)/actuator/prometheus" > $J/prom.txt
  python3 -I - $J/prom.txt <<'PY'
import sys, re
for l in open(sys.argv[1], encoding="utf-8"):
    if l.startswith("http_server_requests_seconds_count{") and ('uri="/api/v1/customers/{name}"' in l or 'status="429"' in l):
        tags = dict(re.findall(r'(\w+)="([^"]*)"', l[:l.rindex("}")])); n = l.rsplit(" ", 1)[1].strip()
        print("  metrics | count %s · method %s · outcome %s · status %s · uri %s" % (n, tags.get("method"), tags.get("outcome"), tags.get("status"), tags.get("uri")))
PY
  QUIET=1 tbstop limit 21080; }
c_forge() {
  echo "== forge: the forged headers after the address's refusal - on after/ (21080, H2, cap=5) at Boot's default (server.forward-headers-strategy unset)"
  ACC=1 tb forge-anchor 21080 $CAP5
  echo "  anchor | requests until the first refusal: $(spend 21080)"
  req "anchor X-Api-Key forged-1" 21080 -H 'X-Api-Key: forged-1' $RV
  req "anchor X-Api-Key forged-2" 21080 -H 'X-Api-Key: forged-2' $RV
  req "anchor X-Forwarded-For 10.0.0.1" 21080 -H 'X-Forwarded-For: 10.0.0.1' $RV
  echo "  anchor | the access log's statuses: $(acclog forge-anchor | awk '{ print $3 }' | paste -sd' ' -) · refusals logged $(refusals forge-anchor)"
  QUIET=1 tbstop forge-anchor 21080
  echo "== forge: the harness's header-keyed copy (break.sh's edit, .harness/need-forge, a made-up key) on 21085, H2, cap=5"
  TREE=need-forge ACC=1 tb forge-copy 21085 $CAP5
  echo "  copy (a made-up key) | requests until the first refusal, no header: $(spend 21085)"
  req "copy (a made-up key) X-Api-Key forged-1" 21085 -H 'X-Api-Key: forged-1' $RV
  req "copy (a made-up key) X-Api-Key forged-2" 21085 -H 'X-Api-Key: forged-2' $RV
  req "copy (a made-up key) no header again" 21085 $RV
  echo "  copy (a made-up key) | the access log's statuses: $(acclog forge-copy | awk '{ print $3 }' | paste -sd' ' -)"
  QUIET=1 tbstop forge-copy 21085
  echo "== xff: after/ (21080, H2, cap=5) with the run flag --server.forward-headers-strategy=framework (flag=on, never the yaml)"
  ACC=1 tb xff 21080 $CAP5 --server.forward-headers-strategy=framework
  echo "  xff (flag=on) | requests until the first refusal, no header: $(spend 21080)"
  local a; for a in 10.0.0.1 10.0.0.2 10.0.0.3; do req "xff (flag=on) X-Forwarded-For $a" 21080 -H "X-Forwarded-For: $a" $RV; done
  local i; for i in 1 2 3 4 5; do st -H 'X-Forwarded-For: 10.0.0.1' "$(B 21080)$RV" > /dev/null; done
  req "xff (flag=on) X-Forwarded-For 10.0.0.1, its seventh" 21080 -H "X-Forwarded-For: 10.0.0.1" $RV
  echo "  xff (flag=on) | the access log's statuses: $(acclog xff | awk '{ print $3 }' | paste -sd' ' -) · the filters' orders: ForwardedHeaderFilter registered $($G -c 'forwardedHeaderFilter' .harness/run/xff/jvm.log || true) log lines (Boot registers it at the highest precedence; the limiter at -95)"
  QUIET=1 tbstop xff 21080; }
c_refill() {
  echo "== refill: after/ (21080, H2, cap=5, period=short - the harness's short refill period on the command line), the refusal's Retry-After waited out by condition"
  ACC=1 tb refill 21080 $CAP5 --tiffinbox.rate-limit.refill-period=$SHORT
  local i; for i in 1 2 3 4 5 6; do req "refill #$i" 21080 $RV; done
  local ra; ra=$(raval); case "$ra" in ''|*[!0-9]*) die "refill: the refusal's Retry-After is not an integer";; esac
  local per; per=$(python3 -I -c 'import re,sys; m=re.fullmatch(r"(\d+)([smh])",sys.argv[1]); print(int(m.group(1))*{"s":1,"m":60,"h":3600}[m.group(2)])' "$SHORT")
  local polls=$(( (ra + per) * 20 + 20 )) n=0 s
  echo "  refill | the poll's bound, derived: (the Retry-After read back + the period read back, in seconds) x 20 polls a second + 20 = a count, never a time; Retry-After within the period: $( [ "$ra" -le "$per" ] && echo yes || echo no)"
  while :; do s=$(st "$(B 21080)$RV"); n=$((n + 1)); [ "$s" = 200 ] && break; [ "$s" = 429 ] || die "refill: a poll answered $s"; [ $n -lt $polls ] || die "refill: no 200 within the derived bound"; sleep 0.05; done
  echo "  ~ refill | polls until the first 200: $n (run-variant)"
  echo "  refill | the first request after the wait: 200"
  local k=1; while :; do s=$(st "$(B 21080)$RV"); [ "$s" = 200 ] || break; k=$((k + 1)); [ $k -lt 50 ] || break; done
  echo "  refill | 200s after the wait, the first included, before the next refusal: $k · the next answer: $s"
  req "refill the next refusal" 21080 $RV
  QUIET=1 tbstop refill 21080; }
c_scope() {
  echo "== scope: what the filter counts and what it never touches, each request after the address's refusal (21080, H2, cap=5)"
  ACC=1 tb scope 21080 $CAP5
  echo "  scope | requests until the first refusal: $(spend 21080)"
  local p; for p in "$OR?size=5" $RV/bill /api/v1/nosuch/route /customers/Ravi /revenue /dashboard /v3/api-docs /actuator/health /api/1.0/customers/Ravi; do
    echo "  scope | GET $p -> $(st "$(B 21080)$p")"; done
  echo "  scope | POST $RV/pauses?days=1 with a key (KEYPOST, scope (c)'s one keyed request) -> $(st -X POST -H 'Idempotency-Key: c9u19-scope-1' "$(B 21080)$RV/pauses?days=1")"
  for p in HEAD OPTIONS PATCH; do echo "  scope | $p $RV -> $(st -X $p "$(B 21080)$RV")"; done
  echo "  scope | the access log: $(acclog scope | wc -l | tr -d ' ') lines · refusals logged $(refusals scope)"
  acclog scope | sed 's/^/  scope | access /'
  QUIET=1 tbstop scope 21080; }
psq() { dk exec "$CN" psql -U tiffinbox -d tiffinbox -qAt -v ON_ERROR_STOP=1 -c "$1" 2>&1 || die "psql failed: $1"; }
c_twojvm() {
  echo "== twojvm: the profile \"dev\" with its four stores by digest (--pull never, 127.0.0.1 only), two TiffinBox JVMs on one Redis bucket (cap=5 on both)"
  PW=$(openssl rand -hex 12); (umask 077 && printf 'POSTGRES_USER=tiffinbox\nPOSTGRES_PASSWORD=%s\nPOSTGRES_DB=tiffinbox\n' "$PW" > .harness/dev/pg.env)
  CTRS="$CN $RN $MN $EN"; MINE="${MINE:-} 21081 21082 21083 21084"
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:21081:5432 --env-file .harness/dev/pg.env $PIMG" .harness/dev/run-pg.log; [ "$RE" = 0 ] || die "PostgreSQL did not start"
  bg "dk run -d --pull never --name $RN -p 127.0.0.1:21082:6379 $RIMG" .harness/dev/run-redis.log; [ "$RE" = 0 ] || die "Redis did not start"
  bg "dk run -d --pull never --name $MN -p 127.0.0.1:21083:27017 -e GLIBC_TUNABLES=$GT $MIMG --unixSocketPrefix /data/db" .harness/dev/run-mongo.log; [ "$RE" = 0 ] || die "MongoDB did not start"
  bg "dk run -d --pull never --name $EN --hostname $EN -p 127.0.0.1:21084:9200 $ESSET -e ES_JAVA_OPTS=-Xms512m\ -Xmx512m $EIMG" .harness/dev/run-es.log; [ "$RE" = 0 ] || die "Elasticsearch did not start"
  local i=0 c; while :; do c=$($CURL -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:21084/_cluster/health" 2> /dev/null || true); [ "$c" = 200 ] && break; i=$((i + 1)); [ $i -lt 600 ] || die "Elasticsearch did not answer _cluster/health 200"; sleep 0.25; done
  i=0; while ! dk exec $CN pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 120 ] || die "PostgreSQL did not accept connections"; sleep 0.5; done
  i=0; while [ "$(dk exec $RN redis-cli PING 2> /dev/null | tr -d '\r')" != PONG ]; do i=$((i + 1)); [ $i -lt 200 ] || die "Redis did not answer PING"; sleep 0.1; done
  i=0; while [ "$(dk logs $MN 2>&1 | $G -c 'Waiting for connections' || true)" = 0 ]; do i=$((i + 1)); [ $i -lt 240 ] || die "MongoDB never said Waiting for connections"; sleep 0.25; done
  echo "  stores | $(for c in $CN $RN $MN $EN; do printf '%s %s · ' "$c" "$(dk port $c | paste -sd'|' -)"; done) the images by digest: $(for c in $CN $RN $MN $EN; do dk inspect -f '{{.Config.Image}}' $c | sed -E 's/@sha256:(.{8}).*/@\1/'; done | paste -sd' ' -)"
  echo "  stores | PostgreSQL $(psq 'show server_version') · Redis $(dk exec $RN redis-cli INFO server | tr -d '\r' | sed -n 's/^redis_version://p') · Elasticsearch $($CURL -s http://127.0.0.1:21084/ | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["version"]["number"])')"
  echo "  redis | FLUSHALL before the leg: $(dk exec $RN redis-cli FLUSHALL | tr -d '\r') · keys $(dk exec $RN redis-cli DBSIZE | tr -d '\r')"
  local DEV=(--spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=21082 --spring.mongodb.uri=mongodb://127.0.0.1:21083/tiffinbox --spring.elasticsearch.uris=http://127.0.0.1:21084 $CAP5)
  DEVRUN=1 ACC=1 tb dev-a 21080 "${DEV[@]}"
  DEVRUN=1 ACC=1 tb dev-b 21085 "${DEV[@]}"
  local l; for l in dev-a dev-b; do echo "  $l | $($G -oE 'The following 1 profile is active: "dev"' .harness/run/$l/jvm.log) · $($G -F 'rate limit: capacity' .harness/run/$l/jvm.log | sed -E 's/^.*tiffinbox\.ratelimit +: //')"; done
  local seq=""; for p in 21080 21080 21080 21085 21085 21085 21080; do seq="$seq $( [ $p = 21080 ] && echo A || echo B)$(st "$(B $p)$RV")"; done
  echo "  twojvm | the sequence (A = 21080, B = 21085):$seq"
  echo "  redis | the keys under tiffinbox:api-rate:* (--scan, inside the container): $(dk exec $RN redis-cli --scan --pattern 'tiffinbox:api-rate:*' | tr -d '\r' | paste -sd' ' -) · other tiffinbox:* keys: $(dk exec $RN redis-cli --scan --pattern 'tiffinbox:*' | tr -d '\r' | $G -v '^tiffinbox:api-rate:' | sort | paste -sd' ' -)"
  local k=tiffinbox:api-rate:127.0.0.1
  echo "  redis | $k: TYPE $(dk exec $RN redis-cli TYPE $k | tr -d '\r') · STRLEN $(dk exec $RN redis-cli STRLEN $k | tr -d '\r') · PTTL positive: $(dk exec $RN redis-cli PTTL $k | tr -d '\r' | python3 -I -c 'import sys; print("yes" if int(sys.stdin.read()) > 0 else "no")')"
  echo "  postgres | idempotency_key rows before the keyed POST: $(psq 'select count(*) from idempotency_key')"
  echo "  twojvm | POST $RV/pauses?days=1 with a key (KEYPOST) on B after the refusal -> $(st -X POST -H 'Idempotency-Key: c9u19-dev-1' "$(B 21085)$RV/pauses?days=1") · idempotency_key rows after: $(psq 'select count(*) from idempotency_key')"
  echo "  twojvm | refusals logged: A $(refusals dev-a) · B $(refusals dev-b)"
  QUIET=1 tbstop dev-a 21080; QUIET=1 tbstop dev-b 21085
  echo "== lua: Course 8's counter (Distributed Locks and Rate Counters: INCR, then EXPIRE on the first) on the same Redis, key tiffinbox:rate:lua, six calls"
  local r="" n; for n in 1 2 3 4 5 6; do r="$r $(dk exec $RN redis-cli EVAL "local c = redis.call('INCR', KEYS[1]); if c == 1 then redis.call('EXPIRE', KEYS[1], ARGV[1]) end; return c" 1 tiffinbox:rate:lua 60 | tr -d '\r')"; done
  echo "  lua | the six replies:$r · GET $(dk exec $RN redis-cli GET tiffinbox:rate:lua | tr -d '\r') · TTL positive: $(dk exec $RN redis-cli TTL tiffinbox:rate:lua | tr -d '\r' | python3 -I -c 'import sys; print("yes" if int(sys.stdin.read()) > 0 else "no")') · a wait in any reply: none (an integer count only)"
  for c in $CN $RN $MN $EN; do dk rm -fv $c > /dev/null 2>&1 || die "$c could not be removed"; done; CTRS=""
  for p in 21081 21082 21083 21084; do MINE=$(echo " ${MINE:-} " | sed "s/ $p / /g"); [ "$(listeners $p)" = 0 ] || die "$p still listens after the stores were removed"; done
  echo "  stores | the four containers removed (rm -fv) · volumes now $(dk volume ls -q | wc -l | tr -d ' ') (the start's $VOL0)"; }
byclass() { awk '/\[INFO\] Running com\./ { c = $NF; sub(/.*\./, "", c) } /rate limit: refused/ { n[c]++ } END { o = ""; for (k in n) o = o (o == "" ? "" : " ") k "=" n[k]; print (o == "" ? "none" : o) }' "$1" | tr ' ' '\n' | sort | paste -sd' ' -; }
c_defaults() {
  echo "== defaults (R.555): the web suite at the DEFAULT capacity - after/'s own build (Docker-free, the run's first build) - and the plant at 5 on a scratch copy"
  python3 -I - .harness/after/tiffinbox-web/target/surefire-reports default <<'PY'
import sys, glob, os, xml.etree.ElementTree as E
t = [0, 0, 0, 0]; bad = {}
for f in glob.glob(sys.argv[1] + "/TEST-*.xml"):
    r = E.parse(f).getroot()
    for i, k in enumerate(("tests", "failures", "errors", "skipped")): t[i] += int(r.get(k) or 0)
    n = int(r.get("failures") or 0) + int(r.get("errors") or 0)
    if n: bad[r.get("name").split(".")[-1]] = n
print("  %s | tiffinbox-web tests %d failures %d errors %d skipped %d · failing classes %s" % ((sys.argv[2],) + tuple(t) + (sorted(bad.items()) or "none",)))
PY
  echo "  default | refusal lines in the build's log, by the test class Surefire was running: $(byclass .harness/build-after.log) · outside RateLimitFilterTest (its own capacity of three): $(byclass .harness/build-after.log | tr ' ' '\n' | $G -v '^RateLimitFilterTest=' | $G -v '^none$' | awk -F= '{ s += $2 } END { print s + 0 }') · the settings' start lines (one per test context): $($G -c 'rate limit: capacity' .harness/build-after.log || true) · their forms: $($G -F 'rate limit: capacity' .harness/build-after.log | sed -E 's/^.*tiffinbox\.ratelimit +: //' | sort | uniq -c | sed -E 's/^ +//' | paste -sd'|' -)"
  python3 -I - .harness/plant-cap5/tiffinbox-web/src/main/resources/application.yaml <<'PY' || die "the plant could not be made"
import sys
f = sys.argv[1]; s = open(f, encoding="utf-8").read()
if s.count("    capacity: 1000\n") != 1: sys.exit("no capacity line")
open(f, "w", encoding="utf-8").write(s.replace("    capacity: 1000\n", "    capacity: 5\n"))
PY
  echo "  plant | .harness/plant-cap5 (a copy of after/): application.yaml's capacity 1000 -> 5 (the plant; after/ untouched: $($G -c '    capacity: 1000' after/tiffinbox-web/src/main/resources/application.yaml))"
  guard "the plant's tests"
  bg "cd .harness/plant-cap5 && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" -Dsurefire.failIfNoSpecifiedTests=false clean test -pl tiffinbox-web -am" .harness/plant-cap5.log; local pre=$RE; offl .harness/plant-cap5.log
  python3 -I - .harness/plant-cap5/tiffinbox-web/target/surefire-reports "plant (cap 5)" <<'PY'
import sys, glob, os, xml.etree.ElementTree as E
t = [0, 0, 0, 0]; bad = {}
for f in glob.glob(sys.argv[1] + "/TEST-*.xml"):
    r = E.parse(f).getroot()
    for i, k in enumerate(("tests", "failures", "errors", "skipped")): t[i] += int(r.get(k) or 0)
    n = int(r.get("failures") or 0) + int(r.get("errors") or 0)
    if n: bad[r.get("name").split(".")[-1]] = n
print("  %s | tiffinbox-web tests %d failures %d errors %d skipped %d · failing classes %d %s" % ((sys.argv[2],) + tuple(t) + (len(bad), " ".join("%s=%d" % kv for kv in sorted(bad.items())) or "none")))
PY
  echo "  plant | the build's exit: $pre (non-zero = the plant turned the suite red) · refusal lines in its log, by class: $(byclass .harness/plant-cap5.log)"; }
c_spec() {
  echo "== spec: the committed file against the served document (after/, 21080, harness-free, the default capacity) - unchanged by this unit (C7 (a))"
  tb spec 21080 > /dev/null
  local SF=after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json BF=before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json
  $CURL -s "$(B 21080)/v3/api-docs" > $J/served.json
  echo "  the committed file against the served document (servers removed, json.dump indent 2, ensure_ascii False, a final newline): $(python3 -I -c '
import json,sys
d=json.load(open(sys.argv[1])); d.pop("servers",None)
print("equal" if json.dumps(d,indent=2,ensure_ascii=False)+"\n" == open(sys.argv[2],encoding="utf-8").read() else "differ")' $J/served.json $SF)"
  echo "  committed md5 before $(md5 -q $BF) · after $(md5 -q $SF) · bytes before $(wc -c < $BF | tr -d ' ') · after $(wc -c < $SF | tr -d ' ') · byte-equal: $(cmp -s $BF $SF && echo yes || echo no)"
  python3 -I harness/ops9s3.py ops $BF > $J/ops-before.txt; python3 -I harness/ops9s3.py ops $SF > $J/ops-after.txt
  echo "  before: $(tail -1 $J/ops-before.txt) · after: $(tail -1 $J/ops-after.txt) · the operations' ids before -> after: $(cmp -s $J/ops-before.txt $J/ops-after.txt && echo equal || echo differ)"
  printf '{}' > $J/empty.json; python3 -I harness/ops9s3.py ops $J/empty.json > /dev/null 2>&1; echo "  ops9s3.py on an empty spec: exit $? (refused)"
  echo "  the served document's 429 responses: $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(sum(1 for v in d["paths"].values() for o in v.values() if "429" in o.get("responses", {})))' $J/served.json) · Retry-After named: $($G -c 'Retry-After' $J/served.json || true) - the refusal is a filter's answer no operation documents; the served spec and the committed one both say nothing of it"
  echo "  OpenApiSpecTest on the committed file: $(python3 -I -c '
import sys,xml.etree.ElementTree as E
r=E.parse(sys.argv[1]).getroot(); print("tests %s failures %s errors %s" % (r.get("tests"), r.get("failures"), r.get("errors")))' .harness/after/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.OpenApiSpecTest.xml) (after/'s build)"
  echo "  the client: tiffinbox-client byte-equal before -> after/: $(diff -rq before/tiffinbox-client after/tiffinbox-client > /dev/null && echo yes || echo no) · its generated FILES (after/'s build): $($G -c '\.java$' .harness/after/tiffinbox-client/target/generated-sources/openapi/.openapi-generator/FILES) · PATH_* (ops9s3.py paths): $(python3 -I harness/ops9s3.py paths .harness/after/tiffinbox-client/target/generated-sources/openapi 2>&1 | tail -1)"
  QUIET=1 tbstop spec 21080; }
movedone() { local port=$1 m=$2 p=$3 w; shift 3; : > $J/mv.h; : > $J/mv.b
  w=$($CURL --http1.1 -sS -D $J/mv.h -o $J/mv.b -w '%{http_code} %{content_type} %{size_download}' --max-time 5 -X "$m" "$@" "$(B $port)$p" 2> /dev/null)
  local bm; bm=$(sed -E 's/"timestamp":"[^"]*"/"timestamp":"<masked>"/; s/"next":"[^"]*"/"next":"<cursor>"/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/<uuid>/g; s/expires=[0-9]+/expires=<masked>/g; s/sig=[A-Za-z0-9_-]+/sig=<masked>/g' $J/mv.b | md5 -q | cut -c1-12)
  w=$(echo "$w" | awk '{ print $1, $2 }'); case "$p" in /api/v1/*) MVN=$((MVN + 1));; esac
  local hd; hd=$(tr -d '\r' < $J/mv.h | sed -n '2,$p' | $G -v '^$' | sed -E 's/:.*//' | tr 'A-Z' 'a-z' | $G -vxE 'date|keep-alive|connection|content-length|transfer-encoding|set-cookie|expires' | sort | paste -sd, -)
  echo "  $SIDE | $m $p$( [ -n "${TAG:-}" ] && echo " [$TAG]") -> $w · Allow {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Aa]llow: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)} · headers {$hd} · body $bm"; }
MPT='Content-Type: application/merge-patch+json'; JPT='Content-Type: application/json-patch+json'; CAPI=/api/v1/customers
movedside() { local side=$1 port=$2 a p
  TREE=$side tb moved-$side $port > /dev/null
  SIDE=$side; MVN=0
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
  movedone $port GET $CAPI/Ravi/bill
  movedone $port GET $CAPI/Ravi/bill-link
  movedone $port GET "$CAPI/Ravi/bill/signed?expires=1&sig=x"
  echo "  $SIDE | requests sent to /api/v1/ by this JVM (counted by the list): $MVN - the setting read back by its start line: ${SETL:-none (before has no limiter)}"
  QUIET=1 tbstop moved-$side $port; }
c_moved() { echo "== moved: U18's requests (its movedside list, copied, its bill requests included; the headers' names beside Allow - the limiter adds none to an answer it lets through) on before (21086) and after/ (21080), H2, each its own JVM, the default capacity"
  movedside before 21086; movedside after 21080
  echo "  BOOT-INF/lib names: before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ') · added: $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G '^>' | sed 's/^> //' | paste -sd' ' -) · removed: $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c '^<' || true)"
  python3 -I - .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar <<'PY'
import sys, zipfile
a = {i.filename: i.CRC for i in zipfile.ZipFile(sys.argv[1]).infolist()}; b = {i.filename: i.CRC for i in zipfile.ZipFile(sys.argv[2]).infolist()}
add = sorted(set(b) - set(a)); rem = sorted(set(a) - set(b)); mv = sorted(k for k in a if k in b and a[k] != b[k])
print("  jar | the web jar's entries: added %d %s · removed %d · shared entries whose CRC moved %d %s" % (len(add), add, len(rem), len(mv), mv))
PY
}
apiside() { local side=$1 port=$2
  TREE=$side tb api-$side $port > /dev/null
  python3 -I - "$side" "$port" after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json > $J/api-$side.txt <<'PY'
import sys, json, re, urllib.request, hashlib
side, port, spec = sys.argv[1], sys.argv[2], sys.argv[3]
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
op = urllib.request.build_opener(urllib.request.ProxyHandler({}))
for u in urls:
    req = urllib.request.Request("http://127.0.0.1:%s%s" % (port, u))
    try: r = op.open(req, timeout=10); st, h, b = r.status, r.headers, r.read()
    except urllib.error.HTTPError as e: st, h, b = e.code, e.headers, e.read()
    hs = ",".join(sorted(k.lower() for k in h.keys() if k.lower() not in ("date", "keep-alive", "connection", "content-length", "transfer-encoding")))
    print("  api | GET %s -> %s %s · headers {%s} · body %s" % (u, st, h.get("Content-Type"), hs, hashlib.md5(mask(b).encode()).hexdigest()[:12]))
PY
  QUIET=1 tbstop api-$side $port; }
c_api() { echo "== api: every GET of the committed spec's /api/v1/ paths (filled: name Ravi, id 1; the run id zeros; the signed link expired) and two old refusals, on before (21086) and after/ (21080), H2, the default capacity, each its own JVM"
  apiside before 21086; apiside after 21080
  sed 's/^  api |/  api before |/' $J/api-before.txt; echo "  api | before -> after/: $(cmp -s $J/api-before.txt $J/api-after.txt && echo byte-identical || echo DIFFER) ($(wc -l < $J/api-after.txt | tr -d ' ') requests each)"
  diff $J/api-before.txt $J/api-after.txt | $G '^[<>]' | sed 's/^/  api | moved /'; }
c_seven() {
  echo "== the seven (c5-unit11/curlset.sh, no key header), each tree its own JVM, H2, the default capacity - not a witness for the limiter: it sends nothing to /api/v1/"
  echo "  expected $S466"
  local s port i; for s in before after; do [ $s = before ] && port=21086 || port=21080
    TREE=$s tb seven-$s $port > /dev/null
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
  echo "== the old surface by count (U18's reader, copied), each tree its own JVM, H2, the default capacity - not a witness for the limiter"
  echo "  expected $U4SURF"
  for side in before after; do [ $side = before ] && port=21086 || port=21080
    TREE=$side tb surface-$side $port > /dev/null
    oldsurface2 $port $J/surface-$side.txt
    QUIET=1 tbstop surface-$side $port
    echo "  $side: the old surface $(md5 -q $J/surface-$side.txt) ($($G -c '^== ' $J/surface-$side.txt) requests, $(wc -l < $J/surface-$side.txt | tr -d ' ') lines)"; done
  echo "  before -> after/: $(cmp -s $J/surface-before.txt $J/surface-after.txt && echo equal || echo DIFFER)"
  echo "  the S9.14 plant slot (21085): not captured this unit (dropped first by the prompt's order; not said)"; }
c_inert() {
  echo "== the key header across this run's captures (request lines)"
  echo "  keyed requests in this run's captures: $(ls .r-*.new 2> /dev/null | $G -vxF .r-inert.new | xargs cat 2> /dev/null | $G -cF 'KEYPOST' || true) (scope (c)'s and twojvm's, each named KEYPOST)"
  echo "  IdempotencyKeyFilter's table: $($G -oE 'parse\("[^"]*"\)' after/tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java | paste -sd' ' -) - unchanged (byte-equal to before's: $(cmp -s before/tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java after/tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java && echo yes || echo no))"; }
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
reactor() { $G -E '^\[INFO\] TiffinBox[A-Za-z ]* \.+ (SUCCESS|FAILURE|SKIPPED)' "$1" | sed -E 's/ \.+ / ... /; s/\[ *[0-9.:]+ (s|min)\]//; s/^\[INFO\] /  reactor: /; s/ *$//'; }
c_tests() { local p c
  echo "== mvn -o clean package (tests on) on a copy of after/ (.harness/pkg): the whole reactor, Docker reachable"
  copy after .harness/pkg; copy after .harness/tests; copy after .harness/webonly
  guard "mvn package"
  bg "cd .harness/pkg && $MV \"$AL\" clean package" .harness/pkg.log; local pre=$RE
  echo "  mvn package exit $pre"; reactor .harness/pkg.log
  for p in web client; do surefire .harness/pkg/tiffinbox-$p/target/surefire-reports "package | tiffinbox-$p"; done
  python3 -I - .harness/pkg/tiffinbox-web/target/surefire-reports "$U/.harness/before-reports" <<'PY'
import sys, glob, os, xml.etree.ElementTree as E
n = {E.parse(f).getroot().get("name").split(".")[-1]: E.parse(f).getroot() for f in glob.glob(sys.argv[1] + "/TEST-*.xml")}
for k in sorted(n): print("  package | class %s | tests %s failures %s errors %s skipped %s" % (k, n[k].get("tests"), n[k].get("failures"), n[k].get("errors"), n[k].get("skipped")))
PY
  echo "  web tests before (unit 18's values block): $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit18/README.md | $G -oE 'web_tests=[0-9]+' | head -1 | cut -d= -f2) · RateLimitFilterTest's @Test lines $($G -cE '^ +@Test$' after/$RLT)"
  local nps; nps=$(sed -E 's/"[^"]*"/""/g' after/$RLT | $G -cE 'RANDOM_PORT|DEFINED_PORT|LocalServerPort|Socket|[^0-9.][0-9]{4,5}[^0-9.]' || true)
  echo "  RateLimitFilterTest: disabling or conditional annotations $($G -cE '@(org\.junit\.jupiter\.api\.(condition\.)?)?(Disabled|EnabledIf|DisabledIf|EnabledOn|DisabledOn|EnabledFor|DisabledFor)' after/$RLT || true) · ports or sockets (string literals removed) $nps · its printed lines in the build: $($G -cE '^RateLimitFilterTest: ' .harness/pkg.log)"
  $G -E '^RateLimitFilterTest: ' .harness/pkg.log | sed 's/^/  package | /'
  echo "  test files moved before -> after: $(for p in $(cd before && find tiffinbox-web/src/test -type f | sort); do cmp -s before/$p after/$p || basename $p; done | paste -sd, -) · new: $(cd after && for p in $(find tiffinbox-web/src/test -type f | sort); do [ -e ../before/$p ] || basename $p; done | paste -sd, -)"
  echo "  the test classes that send /api/v1/ (grep -l): $( (cd after && $G -rl '/api/v1/' tiffinbox-web/src/test/java) | sed 's#.*/##; s#\.java$##' | sort | paste -sd, -) · the ITs among them: $( (cd after && $G -rl '/api/v1/' tiffinbox-web/src/test/java tiffinbox-core/src/test/java 2> /dev/null) | $G -c 'IT\.java$' || true)"
  echo "  the slice (TiffinBoxWebTest, @WebMvcTest): byte-equal to before's: $(cmp -s before/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java after/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java && echo yes || echo no) · slice/WebSlice.java byte-equal: $(cmp -s before/tiffinbox-web/src/test/java/slice/WebSlice.java after/tiffinbox-web/src/test/java/slice/WebSlice.java && echo yes || echo no) - measured: green unedited (RateLimiting is a @Configuration the slice does not scan; RateLimitFilter is no @Component)"
  echo "== the Docker-free twin: after/'s own build (DOCKER_HOST=unix:///nonexistent/docker.sock, the run's first build)"
  for p in web client; do surefire .harness/after/tiffinbox-$p/target/surefire-reports "twin | tiffinbox-$p"; done
  echo "== mvn -o clean verify on a copy of after/ (.harness/tests): Surefire's tests on H2 in memory, then the five ITs in Testcontainers containers (21280-21284)"
  for p in 21280 21281 21282 21283 21284 18881 18882 18883 18884; do [ "$(listeners $p)" = 0 ] || die "$p is bound before verify"; done
  guard "mvn verify"
  bg "cd .harness/tests && DOCKER_HOST=\"$DH\" TESTCONTAINERS_RYUK_DISABLED=true $MV \"$AL\" clean verify" .harness/verify.log; local vre=$RE
  reactor .harness/verify.log
  surefire .harness/tests/tiffinbox-web/target/surefire-reports "verify | tiffinbox-web"
  python3 -I - .harness/tests/tiffinbox-web/target/surefire-reports-it .harness/tests/tiffinbox-web/target/failsafe-reports $vre <<'PY'
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
  $G -E '^IT BINDINGS ' .harness/verify.log | sed -E 's/:[0-9]{4,5}/:<port>/g; s/^/  /' | sort -u
  echo "  Testcontainers containers after: $(dk ps -aq --filter label=org.testcontainers=true | wc -l | tr -d ' ') · images pulled: $($G -ciE 'Pulling image|pull(ed|ing) ' .harness/verify.log || true)"
  echo "== the hand-built form: mvn -o clean package -pl tiffinbox-web -am on a copy of after/ (.harness/webonly), Docker-free"
  guard "the web-only form"
  bg "cd .harness/webonly && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package -pl tiffinbox-web -am" .harness/webonly.log
  surefire .harness/webonly/tiffinbox-web/target/surefire-reports "webonly | tiffinbox-web"
  echo "  downloads across the builds: $(cat .harness/pkg.log .harness/verify.log .harness/webonly.log .harness/build-after.log .harness/build-before.log .harness/build-need-forge.log .harness/plant-cap5.log .harness/deptree.log 2> /dev/null | $G -cE 'Download(ing|ed) from ' || true)"
  echo "  BOOT-INF/lib: before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ') · added $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G '^>' | sed 's/^> //' | paste -sd' ' -) · removed $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c '^<' || true)"; }
c_harness() {
  echo "== harness: the folder's files and the instruments (copied byte-equal, adapted with a named diff, new)"
  echo "  harness/: $(ls harness | paste -sd' ' -) · exercise/: $(ls exercise | paste -sd' ' -) · harness Java files: $(find harness -name '*.java' | wc -l | tr -d ' ')"
  echo "  copied | dur9.py md5 $(md5 -q harness/dur9.py) · ops9s3.py md5 $(md5 -q harness/ops9s3.py) (unit 18's, byte for byte)"
  echo "  adapted | tree19.py from tree18.py: $(diff ../c9-unit18/harness/tree18.py harness/tree19.py | $G -c '^[<>]') lines (the docstring only) · s919.py from s918.py: $(diff ../c9-unit18/harness/s918.py harness/s919.py | $G -c '^[<>]') lines (XU18 -> XU19, four carried cases dropped), the diff's md5 $(diff ../c9-unit18/harness/s918.py harness/s919.py | md5 -q)"
  echo "  new | chk19.py md5 $(md5 -q harness/chk19.py) · exercise: break.sh $(md5 -q exercise/break.sh) · apply.sh $(md5 -q exercise/apply.sh) · check.sh $(md5 -q exercise/check.sh)"
  echo "  not used (absent from harness/): seal9.py cdp.mjs cdp9.mjs loc9.py presign/ src/ - $(for f in seal9.py cdp.mjs cdp9.mjs loc9.py presign src; do [ -e harness/$f ] && echo $f; done | wc -l | tr -d ' ') present"
  echo "  static (i), as written: output md5 $STMD5"
  local SC=.harness/static-copy; rm -rf $SC; mkdir -p $SC; cp -R after $SC/after; ln -s "$U/before" $SC/before; printf 'x' >> $SC/after/compose.yaml
  echo "  static on a scratch copy with a byte appended to after/compose.yaml (a path this unit did not change; the frozen tree untouched): $(python3 -I -B harness/chk19.py static $SC/after $SC/before > $J/st2.txt 2>&1; echo "exit $?") · a FAIL names it: $($G -c '^FAIL' $J/st2.txt || true)"
  echo "  static plants (flag 31): a static assertion reading the live anchor (its folder name assembled) -> $(python3 -I -B harness/chk19.py static-plant live > /dev/null 2>&1; echo "exit $?") · the same path from two pieces -> $(python3 -I -B harness/chk19.py static-plant pieces > /dev/null 2>&1; echo "exit $?")"; }
exrun() { local v=$1 sh=$2 o cmd
  guard "the exercise, $v, $sh"
  rm -rf .harness/exercise/tree; copy after .harness/exercise/tree
  case $v in broken) cmd='sh break.sh "$0" > /dev/null && sh check.sh "$0"' ;; solved) cmd='sh break.sh "$0" > /dev/null && sh apply.sh "$0" > /dev/null && sh check.sh "$0"' ;; *) cmd="sh break.sh \"\$0\" > /dev/null && HOW=$v sh apply.sh \"\$0\" > /dev/null && sh check.sh \"\$0\"" ;; esac
  if [ $sh = bash ]; then o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21088 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock bash -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1)
  else o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21088 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock /bin/zsh -f -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1); fi
  local pre="  $v $sh |"; [ $v = broken ] || [ $v = solved ] || pre="  ~ $v $sh |"
  printf '%s\n' "$o" | sed -E "s/127\.0\.0\.1:21088/127.0.0.1:<port>/g; s/^/$pre /"
  [ ! -f exercise/check.build.log ] || offl exercise/check.build.log
  [ "$(listeners 21088)" = 0 ] || die "the exercise left something listening on 21088"; }
c_exercise() { local v sh
  rm -rf .harness/exercise; mkdir -p .harness/exercise
  for v in broken solved; do for sh in bash zsh; do echo "  == $v, $sh"; exrun $v $sh; done; done
  if [ "$RUNNO" = 1 ] || [ "$RUNNO" = 0 ]; then for v in trustxff headerlast fixedelsewhere; do exrun $v bash; done; fi
  rm -rf exercise/check.run; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.h
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures${DEVCAPS:+ (DEVELOPMENT: only $DEVCAPS - not a run of record)}"
cap advisory c_advisory
cap before c_before
cap change c_change
cap census c_census
cap limit c_limit
cap forge c_forge
cap refill c_refill
cap scope c_scope
cap twojvm c_twojvm
cap defaults c_defaults
cap spec c_spec
cap moved c_moved
cap api c_api
cap seven c_seven
cap surface c_surface
cap tests c_tests
cap harness c_harness
cap exercise c_exercise
cap inert c_inert
echo "== plants (each made to FAIL first on a copy of this run's capture; harness/chk19.py plants)"
PL=$(python3 -I -B harness/chk19.py plants .) || die "a plant was not caught: $(printf '%s\n' "$PL" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$PL" | $G '^ok ' | sed 's/^ok /  /'
PLV=$(printf '%s\n' "$PL" | sed -n 's/^VALUES //p')

# ---- the end: the sweep, the values, the published hashes -------------------------------------------------------------------------------
[ -z "$(echo $PIDS)" ] || die "a JVM of this run is still running: $PIDS"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
[ -z "$(dk ps -aq --filter label=org.testcontainers=true)" ] || die "a Testcontainers container of this run is left"
[ -z "$(dk ps -aq --filter name=^/c9u19-)" ] || die "a c9u19-* container is left"
NI1=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI1" = "$NI0" ] && [ "$VOL1" = "$VOL0" ] || die "R.322: images $NI0 -> $NI1, volumes $VOL0 -> $VOL1"
AD1=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true); [ "$AD1" = "$AD" ] || die "the anchor moved during the run"
pin before-tree before; pin after-tree after
MDB=$(find . ../c9-tiffinbox ../c9-unit18 -name '*.mv.db' -not -path './.harness/*' -not -path '../c9-unit18/.harness/*' 2> /dev/null | wc -l | tr -d ' ')
[ "$MDB" = 0 ] || die "an H2 file outside .harness/"
[ -z "$(ls exercise | $G -v -xE 'README.md|SOLUTION.md|apply.sh|break.sh|check.sh')" ] || die "the exercise left a file in exercise/"
VALS="$VALS
plants: $PLV
build: seed_files=$NF0 seed_bytes=$NB0 central_only=$CO"
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
[ -n "${DEVCAPS:-}" ] && { echo "c9-unit19: DEVELOPMENT run ($DEVCAPS) - nothing published"; exit 2; }
VO=$(python3 -I -B harness/chk19.py values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; [ -n "${NOPIN:-}" ] || die "README.md's values block is not this run's"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM of this run, ports free, no container left, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1 · the anchor against after/ as at the start · the tree pins · *.mv.db outside .harness 0"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit19: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit19: $NCAPS captures checked; every capture = published ($NCAPS)"
