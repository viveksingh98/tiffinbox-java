#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 20 "ETags and Conditional GET" - this unit's receipts. Course 9's SIXTEENTH anchor change, Section 4's second:
# before is a link to ../c9-unit19/after (U19's after); after/ is a frozen copy of ../c9-tiffinbox after this unit's change - ConditionalGets
# (Spring Web's ShallowEtagHeaderFilter on /api/v1/* only, the two streamed bill routes excluded, order -80), CustomerReads' deep tag
# "v<version>" through one core read (CustomerRepository.findVersioned), If-Match on both PATCH routes (CustomerPatches), ConditionalGetTest,
# the anchor's README card.
# The harness's things, labelled on every capture that uses one: the witness (probe.Witness + probe.Http, U12's, byte for byte: a
# harness-joined start prints PROBE-REQ / PROBE-SQL lines), the adapted probe.Etag (its patterns a run flag: the /* copy, the
# unfiltered-bill copy, Chrome leg B's page copy), the run flags (--tiffinbox.rate-limit.capacity=5 in limiter only; Chrome leg B's two
# resource flags; the actuator exposure flag), PostgreSQL 18.6 by digest (c9u20-pg), sealed headless Chrome (the app on disk).
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5; lines starting "  ~" are run-variant and
# left out of the hash - the exercise's refused variants of run 1, Chrome's own counts):
#   advisory  the S9.36 read filed for this section (ADV4), verified, before any build
#   before    before (21096): no ETag, the framing; the warm read's statements (harness-joined)
#   change    the modules, the diffs, the new files whole, the derived changed list, the registration's patterns from the context, greps
#   census    the controllers on before and after/ by unit 15's printed rule
#   shallow   a cached and an uncached /api/v1/ read: 200 + tag, 304, handler and statements (H2 and PostgreSQL); the /* copy's old pair
#   paths     the feed, the old routes, the bill's framing on both trees; the harness's /* copy and unfiltered-bill copy; the limiter
#   weak      If-None-Match variants on the shallow list and the deep route; the tags the server writes
#   deep      the deep tag, its 304, statements (H2 and PostgreSQL), the tag moving with a PATCH; identity (a re-created name)
#   ifmatch   both PATCH routes: current, stale, weak, none, *, a list, unknown, malformed, media type - H2 and PostgreSQL
#   cache     Course 6 U23's stylesheet: its weak tag alone, its date alone, both; javap of the static handler
#   chrome    sealed headless Chrome: leg A the shipped read reloaded; leg B the harness's page copy (the stylesheet)
#   metrics   one scrape after a 200, a 304 and a 412
#   spec      the committed spec against the served one: unchanged; the new answers named as undocumented
#   moved     U18's requests on before and after/ (header names, the tag added); the web jar's entries
#   api       every GET of the committed spec's /api/v1/ paths on before and after/, the framing and the header names printed
#   seven     c5-unit11's seven · surface: the old surface by count - not witnesses for the filter
#   moving    three starts of after/ on one port: the distinct tags per route
#   inert     the key header across this run's captures
#   tests     package, the Docker-free twin, verify (Surefire on H2, the five ITs in Testcontainers), the web-only form, the lib lists
#   harness   the folder's files, the copied and adapted instruments with their named diffs, the static check (flag 31)
#   exercise  break.sh, check.sh, apply.sh on 21098, bash and zsh -f, H2; the refused variants (run 1)
# Ports (U20's band, 21090-21099): 21090 after/ · 21091 PostgreSQL (c9u20-pg) · 21095 the second TiffinBox (the harness's copies) ·
# 21096 before · 21097 Chrome's DevTools · 21098 the exercise · 21092-21094 and 21099 never bound. During mvn verify only: 21280-21284.
# Every store on 127.0.0.1; every curl --noproxy '*'.
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
H19=0609870                                           # unit 19's commit: the static check reads its objects, never the live anchor
PIMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c9u20-pg
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"   # the app on disk, never a download: point it at yours
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
export DOCKER_HOST="$DH"
PIDS=""; INTR=""; mpid=""; CTRS=""; CPID=""
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; [ -z "$CPID" ] || killtree "$CPID"; for p in $mpid $PIDS; do [ -z "$p" ] || killtree "$p"; done; for p in $mpid $PIDS; do if kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; for c in $CTRS; do dk rm -fv "$c" > /dev/null 2>&1; done; for c in $(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null); do dk rm -fv "$c" > /dev/null 2>&1; done; rm -rf exercise/check.run .harness/chrome-a .harness/chrome-b; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.h; [ -z "$INTR" ] || rm -f .r-*.new; rmdir .r-lock 2> /dev/null || rm -rf .r-lock; true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git unzip node javac javap /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
[ -x "$CHROME" ] || die "Chrome is needed on disk at $CHROME (never a download)"
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|SPRINGDOC_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|AWS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit20 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · $(curl --version | head -1 | cut -d' ' -f1-2) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }') · run $RUNNO"

# ---- gates before anything is built: the folder, the link, the pins, the anchor note, the static check, the prose, the exercise --------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'cdp.mjs cdp9.mjs chk20.py chrome20.py dur9.py ops9s3.py s920.py seal9.py src tree20.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
HSRC='probe/Etag.java probe/Http.java probe/Witness.java'
[ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$HSRC" ] || die "harness/src holds another file, or misses one"
for f in presign loc9.py walk.py follow.py Presign.java net.py netlog.py src/probe/Routes.java; do [ ! -e harness/$f ] || die "harness/$f: an instrument this unit does not carry"; done
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md apply.sh break.sh check.sh' ] || die "exercise/ holds another file, or misses one"
[ -L before ] && [ "$(readlink before)" = ../c9-unit19/after ] || die "before must be a link whose text is exactly ../c9-unit19/after"
[ -d after ] && [ ! -L after ] || die "after/ is this unit's own frozen tree, a directory, not a link"
for t in before after; do [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-client/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/"; true; done
echo "  before -> $(readlink before) (a link, the text exact) · after/ a directory (the frozen copy) · no secrets/, target/ or .m2-demo/ in either · harness/src: U12's three probe classes only (Routes.java not needed: Http.java compiles without it); no loc9.py or presign/; net.py and netlog.py read in place"
[ "$(md5 -q harness/src/probe/Http.java)" = aac9acc077572e5c6aad1043c8b6cd55 ] && [ "$(md5 -q harness/src/probe/Http.java)" = "$(awk '$2 == "harness/src/probe/Http.java" { print $3 }' ../c9-unit12/receipts.md5)" ] && cmp -s harness/src/probe/Http.java ../c9-unit11/harness/src/probe/Http.java || die "harness/src/probe/Http.java is not U12's (and U11's) copy"
[ "$(md5 -q harness/src/probe/Witness.java)" = ee8d933cd8f46afac621e4ea63c01510 ] && [ "$(md5 -q harness/src/probe/Witness.java)" = "$(awk '$2 == "harness/src/probe/Witness.java" { print $3 }' ../c9-unit12/receipts.md5)" ] && cmp -s harness/src/probe/Witness.java ../c9-unit11/harness/src/probe/Witness.java || die "harness/src/probe/Witness.java is not U12's (and U11's) copy"
[ "$(md5 -q ../c9-unit12/harness/src/probe/Etag.java)" = 0c518b8fd1f63014970bf0df96bc9e5a ] || die "U12's Etag.java is not 0c518b8f (asserted before the diff)"
ETD=$(diff ../c9-unit12/harness/src/probe/Etag.java harness/src/probe/Etag.java | md5 -q)
for f in cdp.mjs cdp9.mjs seal9.py; do cmp -s harness/$f ../c9-unit11/harness/$f && cmp -s harness/$f ../c9-unit08/harness/$f || die "harness/$f is not U08's and U11's copy"; done
[ "$(md5 -q harness/cdp.mjs)" = 481f48365d9aca78f621acd4fb061039 ] && [ "$(md5 -q harness/cdp9.mjs)" = 5b1816ab518b853ebde4499c9609a756 ] && [ "$(md5 -q harness/seal9.py)" = d34433abf2b5f2c29f9d879876f129d8 ] || die "cdp.mjs / cdp9.mjs / seal9.py: not the pinned copies"
NETPY=../c6-unit23/harness/net.py; NETLOG=../c6-unit23/harness/netlog.py
[ "$(md5 -q $NETPY)" = 7b4727b64f70279864a7102635ef99e6 ] && [ "$(md5 -q $NETLOG)" = 869caa7daf2a2971f58c2de07cbfa2ac ] || die "Course 6 U23's net.py / netlog.py moved"
echo "  instruments: Http.java aac9acc0 and Witness.java ee8d933c = U12's and U11's, byte for byte · Etag.java adapted from U12's 0c518b8f, the named diff's md5 $ETD · cdp.mjs 481f4836, cdp9.mjs 5b1816ab, seal9.py d34433ab = U08's and U11's · Course 6 U23's net.py 7b4727b6 and netlog.py 869caa7d read in place"
[ "$(md5 -q harness/ops9s3.py)" = "$(md5 -q ../c9-unit19/harness/ops9s3.py)" ] || die "harness/ops9s3.py is not unit 19's copy, byte for byte"
[ "$(sed -n '5,$p' harness/tree20.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit19/harness/tree19.py | md5 -q)" ] || die "harness/tree20.py's code is not tree19.py's"
for u in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19; do [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit$u/harness/dur9.py)" ] || die "harness/dur9.py is not ../c9-unit$u's copy"; done
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; J8="$HOME/Desktop/PromptVidya-Automation/java6_series.py"; J7="$HOME/Desktop/PromptVidya-Automation/java7_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"
  [ ! -f "$C9R/_builders/dur9.py" ] || [ "$(md5 -q "$C9R/_builders/dur9.py")" = "$D9" ] || die "harness/dur9.py is not C9/_builders/dur9.py"
  TT=$(python3 -I -c '
import re,sys; t=open(sys.argv[1]).read().split("TITLES",1)[1]; u=open(sys.argv[2]).read(); w=open(sys.argv[3]).read()
for k in ("01","04","05","18","19","20","21"):
    m=re.search(r"\"%s\": *\"([^\"]+)\"" % k, t); print("%s=%s" % (k, m.group(1) if m else ""))
print("c6=%s" % ("Static Resources and Cache Headers" if "Static Resources and Cache Headers" in u else "")); print("c7=%s" % ("Optimistic Locking with @Version" if "Optimistic Locking with @Version" in w else ""))' "$J9" "$J8" "$J7" | paste -sd'|' -)
  echo "  the titles, read off the registries (the call-backs, by title only, R.224): $TT"
else D9N="(the registry is not on this machine: U01-U19's copies are the pin)"; TT=""; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit01-19's copies $D9N · tree20.py's code = tree19.py's · ops9s3.py = unit 19's (md5 $(md5 -q harness/ops9s3.py))"
XS1=$(sed -n '/^# --- XFAM_S9S1 begin ---$/,/^# --- XFAM_S9S1 end ---$/p' harness/s920.py | md5 -q); XS1U=$(sed -n '/^# --- XFAM_S9S1 begin ---$/,/^# --- XFAM_S9S1 end ---$/p' ../c9-unit19/harness/s919.py | md5 -q)
[ "$XS1" = "$XS1U" ] || die "s920.py's XFAM_S9S1 slice is not U19's s919.py's"
[ "$(md5 -q ../c9-unit19/harness/s919.py)" = 137a2acd4be965341f536c8e679a259a ] && { [ ! -f "$C9R/_builders/s919.py" ] || cmp -s ../c9-unit19/harness/s919.py "$C9R/_builders/s919.py"; } || die "U19's s919.py is not 137a2acd (or not C9/_builders/s919.py)"
echo "  s920.py: XFAM_S9S1's slice md5 $XS1 = ../c9-unit19/harness/s919.py's (137a2acd) · XU19C9 kept, this unit's XU20C9 added (the carried base holds Course 8 unit 20's u20) · lines of s919.py's not in s920.py: $(diff ../c9-unit19/harness/s919.py harness/s920.py | $G -c '^<') · the diff's md5 $(diff ../c9-unit19/harness/s919.py harness/s920.py | md5 -q)"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit19/receipts.md5)
[ "$UA" = "122 0e9ff689e6596232a123ebbe57518af1" ] || die "../c9-unit19/receipts.md5's after-tree line is not 122 0e9ff689 ($UA)"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree20.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || { [ -n "${NOPIN:-}" ] && { echo "  $dir/: $got (NOPIN: no pin yet)"; return 0; }; die "receipts.md5 has no $nm line"; }
  [ "$nm" = after-tree ] || [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit19/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree20.py $dir/ -> $got = receipts.md5's $nm line$( [ "$nm" = before-tree ] && echo " = ../c9-unit19/receipts.md5's after-tree line")"; }
pin before-tree before; pin after-tree after
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true)
echo "  after/ against the live anchor (the start note): $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures its own frozen after/' )"
HF="harness/chk20.py harness/s920.py harness/tree20.py harness/dur9.py harness/ops9s3.py harness/chrome20.py harness/cdp.mjs harness/cdp9.mjs harness/seal9.py harness/src/probe/Etag.java harness/src/probe/Http.java harness/src/probe/Witness.java exercise/check.sh exercise/apply.sh exercise/break.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's scripts: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
ST=$(python3 -I -B harness/chk20.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
STMD5=$(printf '%s\n' "$ST" | md5 -q)
echo "  static (harness/chk20.py static after before; reads after/, before and git show $H19:… only - flag 31): $(printf '%s\n' "$ST" | $G -c '^ok ') checks, FAIL 0 · its output md5 $STMD5"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s920.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U19 [0-9]+ families · U20 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s919, per sentence): /'
PH=$($G -rnE 'PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b|<measure>' README.md exercise 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
GL=$(python3 -I -B harness/chk20.py gloss README.md) || die "the gloss: $(printf '%s\n' "$GL" | $G '^FAIL' | head -3 | paste -sd';' -)"
echo "  the gloss: $(printf '%s\n' "$GL" | $G -c '^ok ') checks, FAIL 0 ($(python3 -I -B harness/chk20.py gloss-line))"
HOOK=$(python3 -I -B harness/chk20.py hook) || die "the hook could not be extracted"; EXQ=$(python3 -I -B harness/chk20.py exq) || die "the exercise line could not be extracted"; GLS=$(python3 -I -B harness/chk20.py gloss-line)
IL=$(python3 -I -B harness/chk20.py interleaved) || die "the brief's interleaved hooks and exercises: $IL"
echo "  $IL"
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S4B's Unit 20 Hook line), byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
HW=$(printf '%s\n' "$HOOK" | wc -w | tr -d ' '); EW=$(printf '%s\n' "${EXQ#Your turn: }" | wc -w | tr -d ' '); GW=$(printf '%s\n' "$GLS" | wc -w | tr -d ' ')
HSW=$(printf '%s\n' "$HOOK" | python3 -I -c 'import re,sys; print(max(len(s.split()) for s in re.split(r"(?<=[.!?:])\s+", sys.stdin.read().strip()) if s))')
[ "$EW" -le 25 ] && [ "$GW" -le 25 ] && [ "$HSW" -le 25 ] || die "a spoken line over 25 words (exercise $EW, gloss $GW, the hook's longest sentence $HSW)"
echo "  the hook ($HW words, D12: its longest sentence $HSW <= 25), the exercise's line ($EW words after 'Your turn:') and the gloss ($GW words), byte for byte; the hook and the line extracted from S4B's Unit 20 (md5 $(md5 -q "$S4B"))"
printf '%s\n\n%s\n\n%s\n' "$HOOK" "$EXQ" "$GLS" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s920.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
SWR=$(printf '%s\n' "$SW" | $G ' line ' | sed 's#.*spoken.md ##' | sort -u | paste -sd';' -)
echo "  the hook, the exercise's line and the gloss through s920.py: $(printf '%s\n' "$SW" | tail -1 | sed 's/.* refused: /refused /')$( [ -n "$SWR" ] && echo " - $SWR (handed to RED: the hook is the brief's, never edited)")"; rm -f .r-lock/spoken.md
TS="ShallowEtagHeaderFilter vs @Version ETags: 304 and 412"
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
KW='idempotency''-key'; KH=$($G -v '^ *#' receipts.sh exercise/check.sh exercise/apply.sh exercise/break.sh | $G -ciF "$KW" || true)
[ "$KH" = 0 ] || die "S9.21: a line of receipts.sh or the exercise names the key header - no request of this unit carries it"
LA=$($G -nF 'c9-tiffinbox' receipts.sh exercise/check.sh exercise/apply.sh exercise/break.sh harness/tree20.py harness/chk20.py harness/chrome20.py | $G -v ':[0-9]*: *#' | $G -vF 'AD=$(diff -rq' | $G -vF 'AD1=$(diff -rq' | $G -vF 'MDB=$(find' | $G -vF "\$G -nF 'c9-tiffinbox'" | $G -vF 'LIVE_ANCHOR_PLANT' | wc -l | tr -d ' ')
[ "$LA" = 0 ] || die "flag 31: a line of the receipts, the exercise or the harness reads the live anchor outside the start note, the end check and the H2-file sweep"
echo "  static: no kill by name; every docker call on the pinned socket, every removal rm -fv, every run --pull never; R.391's Maven forms only, no -s; the key header named by no request; the live anchor read only by the start note, the end check and the H2-file sweep (flag 31)"
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
    gsub(/127\.0\.0\.1:2109[0-9]/, "127.0.0.1:<port>")
    gsub(/W\/"[0-9a-f]{32}"/, "W/\"<css md5>\""); gsub(/"0[0-9a-f]{32}"/, "\"<shallow tag>\""); gsub(/tiffinbox-[0-9a-f]{32}\.css/, "tiffinbox-<md5>.css")
    gsub(/max-age=[0-9]+/, "max-age=<masked>")
    gsub(/[A-Z][a-z][a-z], [0-9][0-9] [A-Z][a-z][a-z] [0-9][0-9][0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9] GMT/, "<date>")
    gsub(/(HeadlessChrome|Chrome)\/[0-9.]+/, "Chrome/<version>"); gsub(/Mozilla\/5\.0 \([^)]*\)/, "Mozilla/5.0 (<platform>)")
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
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'took 812 ms' '"timestamp":"2026-11-01T08:09:00.123Z"' "$U/x $HOME/y" 'GET http://127.0.0.1:21090/x · ETag: "0539abcdef0123456789abcdef0123456" · ETag: "v0"' 'ETag: W/"0123456789abcdef0123456789abcdef" · /css/tiffinbox-0123456789abcdef0123456789abcdef.css · Cache-Control: max-age=31536000' 'Last-Modified: Fri, 27 Nov 2026 10:00:00 GMT' 'HeadlessChrome/158.0.1.2 · Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) x' 'rate limit: capacity 1000 per refill period 1m, the' | mask)
[ "$(printf '%s\n' "$MP" | paste -sd'|' -)" = 'Started TiffinBoxServer in <t> (process running for <t>)|took <t>|"timestamp":"<time>"|…/x ~/y|GET http://127.0.0.1:<port>/x · ETag: "<shallow tag>" · ETag: "v0"|ETag: W/"<css md5>" · /css/tiffinbox-<md5>.css · Cache-Control: max-age=<masked>|Last-Modified: <date>|Chrome/<version> · Mozilla/5.0 (<platform>) x|rate limit: capacity 1000 per refill period <period>, the' ] || die "the mask's self-test: $(printf '%s\n' "$MP" | paste -sd'|' -)"
echo "  masks: the log mask masked a Started line's times, a millisecond count, a timestamp, the folders, the home, a band port, every shallow tag (the deep tag kept raw), the stylesheet's weak tag and versioned name, max-age, an HTTP date, Chrome's version and platform, the period in the start's line (self-test)"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh); [ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SURF=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh); [ ${#U4SURF} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh (SURF=)"
U19V=$(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit19/README.md | $G -E '^(seven|surface): ' | $G -oE '(seven|surface)=[0-9a-f]{8}' | paste -sd' ' -)
[ "$U19V" = "seven=$(echo $S466 | cut -c1-8) surface=$(echo $U4SURF | cut -c1-8)" ] || die "U19's README values block ($U19V) is not the seven and the surface read off the receipts"
echo "  the seven: expected $S466 (../c7-unit31/receipts.sh's S466= line) · the old surface: expected $U4SURF (../c9-unit04/receipts.sh's SURF= line) · both = U19's values block ($U19V)"
echo "  the probe's ETag captures (PK4/captures/h42*, read, not copied: the expectation on the probe's class, 1 run): $(for d in h42 h42b h42deep h42pg h42static h42chrome; do printf '%s %s · ' $d "$(ls "$PK4/captures/$d" 2> /dev/null | wc -l | tr -d ' ')"; done)RED's Chrome capture BK4/red-out/c1/C.txt md5 $(md5 -q "$BK4/red-out/c1/C.txt" 2> /dev/null || echo absent) · ProbeS4.java md5 $(md5 -q "$PK4/instruments/probe-src/ProbeS4.java" 2> /dev/null || echo absent) (read for its shape, not copied)"

# ---- docker, ports, the guard: the baselines ----------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run"
[ -z "$(dk ps -aq --filter name=^/c9u20- 2> /dev/null)" ] || die "a c9u20-* container exists before the run"
for im in "$PIMG"; do [ -n "$(dk images --digests --format '{{.Repository}}@{{.Digest}}' 2> /dev/null | $G -xF "$im")" ] || die "an image is not on the daemon by its digest (no pull here - a STOP): $im"; done
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
BAND="21090 21091 21092 21093 21094 21095 21096 21097 21098 21099"
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
CHR0=$(pgrep -x 'Google Chrome' | wc -l | tr -d ' ')
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · nothing pulled · PostgreSQL 18's image on the daemon by digest · no Testcontainers or c9u20-* container · ports free (21092-21094, 21099 and 21110-21119 included, never bound) · the author's own Chrome: $CHR0 main process(es), never touched"

# ---- the trees, copied and built offline: before (through the link), after/; the header-keyed copy; the plant copy --------------------------
M2="$PWD/.m2-demo"
if [ ! -d "$M2" ]; then [ -d "$SEED" ] || die "the seed $SEED is missing"; cp -cR "$SEED" "$M2" 2> /dev/null || cp -R "$SEED" "$M2" || die "the seed could not be copied"; fi
NF0=$(find "$M2" -type f | wc -l | tr -d ' '); NB0=$(find "$M2" -type f -print0 | xargs -0 stat -f %z | awk '{ s += $1 } END { printf "%d", s }')
CO=$(find "$M2" -name _remote.repositories -print0 | xargs -0 $G -l 'central-only' 2> /dev/null | wc -l | tr -d ' ')
[ "$CO" = 0 ] || die "$CO _remote.repositories files in the seed copy still name central-only"
ART="org/springframework/boot/spring-boot-starter-parent/4.1.3 org/springframework/spring-web/7.0.11 org/springframework/spring-webmvc/7.0.11 net/ttddyy/datasource-proxy/1.11.1"
for a in $ART; do [ -n "$(ls "$M2/$a" 2> /dev/null | $G -E '\.(jar|pom)$')" ] || die ".m2-demo holds no $a (no seed act here: report the coordinates)"; done
echo "  .m2-demo (a copy of the seed m2-seed-c9-s4): files $NF0 · bytes $NB0 · _remote.repositories naming central-only: $CO"
for a in $ART; do echo "  seed | $a | $(ls "$M2/$a" | $G -E '\.(jar|pom)$' | paste -sd' ' -)"; done
mkdir -p .harness; for d in before after pkg tests webonly exercise run work hc pg chrome-a chrome-b static-copy; do rm -rf .harness/$d; done
mkdir -p .harness/home .harness/run .harness/work .harness/pg
printf '%s\n' 'checks.disable=true' > .harness/home/.testcontainers.properties
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy before .harness/before; copy after .harness/after
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
echo "  built after/ offline WITH its tests, Docker-free (mvn -o clean package, the whole reactor: $($G -E '^\[INFO\] TiffinBox[A-Za-z ]* \.+ SUCCESS' .harness/build-after.log | sed -E 's/^\[INFO\] (TiffinBox[A-Za-z ]*) \.+ SUCCESS.*/\1/' | paste -sd, -); exit 0) - the jars come from this build; it is the tests capture's Docker-free twin and the suite at the default capacity"
extract before; extract after
DSP="$M2/net/ttddyy/datasource-proxy/1.11.1/datasource-proxy-1.11.1.jar"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*:$DSP\" harness/src/probe/*.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/'s jar: $(head -5 .harness/javac.log)"
echo "  the harness compiled against after/'s web jar ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes, javac -nowarn -parameters; datasource-proxy 1.11.1 on the harness's class path only, never in either jar)"
B() { echo "http://127.0.0.1:$1"; }
J=.harness/work
ALP='%m %U%q %s %b'
# tb LABEL PORT [args]: TiffinBox (the extracted jar of TREE=after unless TREE is set), from its
# own run folder with a generated token (0600, never printed), H2 in memory (fresh per JVM) unless PGRUN=1, waited for by its Started line.
# ACC=1: Tomcat's access log (APAT: its pattern). WIT=1: harness-joined (ETAGS=1 adds probe.Etag). PGRUN=1: the datasource from the run folder's config tree (the URL file 0600, never printed).
tb() { local label=$1 port=$2 t=${TREE:-after} run=.harness/run/$1 i=0 src=""; shift 2
  guard "TiffinBox $label"
  for q in 21092 21093 21094 21099; do [ "$(listeners $q)" = 0 ] && [ -z "$(lsof -nP -iUDP:$q 2> /dev/null)" ] || die "$q must stay free (TCP and UDP)"; done
  [ "$(listeners $port)" = 0 ] && [ -z "$(lsof -nP -iUDP:$port 2> /dev/null)" ] || die "$port is bound before $label"
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  [ -z "${PGRUN:-}" ] || (umask 077 && printf 'jdbc:postgresql://127.0.0.1:21091/tiffinbox?user=tiffinbox&password=%s\n' "$PW" > "$run/secrets/tiffinbox/jdbc-url") || die "the URL was not written"
  local x="$U/.harness/$t/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  local jx=(); [ -z "${WIT:-}" ] || { cp="$cp:$U/.harness/hc:$DSP"; src="--spring.main.sources=probe.Witness,probe.Http${ETAGS:+,probe.Etag}"; jx=(-Dprobe.sql=true); }
  local ax=(); [ "${ACC:-1}" = 1 ] && ax=(--server.tomcat.accesslog.enabled=true "--server.tomcat.accesslog.directory=$U/$run" --server.tomcat.accesslog.prefix=access --server.tomcat.accesslog.suffix=.log --server.tomcat.accesslog.rotate=false --server.tomcat.accesslog.buffered=false "--server.tomcat.accesslog.pattern=${APAT:-$ALP}")
  local main=com.tiffinbox.web.TiffinBoxServer
  echo "java -cp <tree $t$( [ -n "${WIT:-}" ] && echo ' + the harness')> $main --tiffinbox.port=$port $src <the access log> $*" > "$run/cmd"
  (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java "${JL[@]}" "${jx[@]}" -Dstdout.encoding=UTF-8 -cp "$cp" $main --tiffinbox.port="$port" ${src:+"$src"} "${ax[@]}" "$@" > jvm.log 2>&1) &
  local p=$!; echo $p > "$run/pid"; PIDS="$PIDS $p"; MINE="${MINE:-} $port"
  while ! $G -q -E 'Started TiffinBox(App|Server) in' "$run/jvm.log" 2> /dev/null; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before its Started line"; }; i=$((i + 1)); [ $i -lt 1200 ] || die "$label: no Started line"; sleep 0.1; done
  local dup; dup=$(tr ' ' '\n' < "$run/cmd" | $G -E '^--' | sed 's/=.*//' | sort | uniq -d | paste -sd, -); [ -z "$dup" ] || die "R.444: a flag twice on $label's command line ($dup)"
  SETL=$($G -F 'rate limit: capacity' "$run/jvm.log" | sed -E 's/^.*tiffinbox\.ratelimit +: //' | head -1)
  echo "  $label up on $port ($( [ -n "${PGRUN:-}" ] && echo 'PostgreSQL 18.6, the URL from the config tree' || echo 'H2'), tree $t$( [ -n "${WIT:-}" ] && echo ", harness-joined (the witness)" || echo ", harness-free")$( [ -n "${ETAGS:-}" ] && echo " + the harness's probe.Etag"), the access log on · the setting read back by its start line: $SETL · $(sed 's/ *$//' "$run/cmd")"; }
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
  local o e=0; o=$(python3 -I -B harness/chk20.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk20 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; [ -n "${DEVCAPS:-}${NOPIN:-}" ] && { echo "  (development: $nm's check failed, the run goes on)"; unpub="$unpub $nm"; } || die "$nm: its check failed (harness/chk20.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk20.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-11s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-11s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff .r-$nm.new against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }
CB=/api/v1/customers; BR=/api/v1/billing-runs; OR=/api/v1/orders; RV=/api/v1/customers/Ravi
MPT='Content-Type: application/merge-patch+json'; JPT='Content-Type: application/json-patch+json'; CAPI=/api/v1/customers
# rq LABEL PORT [curl args] URI: one request; prints the status, ETag (raw - the mask hides every shallow tag), Content-Type, the framing
# (chunked or Content-Length), the body's bytes and its md5 (the first 12), and for a problem its members (python). Leaves $J/r.h, $J/r.b.
rq() { local lab=$1 port=$2 w; shift 2; local u="${@: -1}"; set -- "${@:1:$(($# - 1))}"; : > $J/r.h; : > $J/r.b
  local hq=no; case " $* " in *" -I "*) hq=yes;; esac
  w=$($CURL --http1.1 -sS -D $J/r.h -o $J/r.b -w '%{http_code} %{size_download}' --max-time 30 "$@" "$(B $port)$u")
  [ $hq = no ] || : > $J/r.b   # HEAD: curl -I writes the headers where a body would go; a HEAD answer has none
  python3 -I - "$lab" "$w" $J/r.h $J/r.b <<'PY'
import sys, json, os, hashlib
lab, w, hf, bf = sys.argv[1:5]
st, sz = w.split()
hs = [l.rstrip("\r\n") for l in open(hf, encoding="latin-1")]
h = {}
for l in hs[1:]:
    if ":" in l: k, v = l.split(":", 1); h[k.strip().lower()] = v.strip()
b = open(bf, "rb").read()
import re
bm = re.sub(rb'"timestamp":"[^"]*"', b'"timestamp":"<masked>"', b); bm = re.sub(rb'"next":"[^"]*"', b'"next":"<cursor>"', bm)
bm = re.sub(rb"(127\.0\.0\.1|localhost):\d{4,5}", rb"\1:<port>", bm); bm = re.sub(rb"expires=\d+", b"expires=<masked>", bm); bm = re.sub(rb"sig=[A-Za-z0-9_-]+", b"sig=<masked>", bm)
fr = "chunked" if h.get("transfer-encoding", "").lower() == "chunked" else ("Content-Length: " + h["content-length"] if "content-length" in h else "no framing header")
out = "  %s -> %s · ETag %s · Content-Type %s · %s · body %d B md5 %s" % (lab, st, h.get("etag", "none"), h.get("content-type", "-"), fr, len(b), hashlib.md5(bm).hexdigest()[:12] if b else "-")
if h.get("content-type", "").startswith("application/problem+json"):
    try:
        d = json.loads(b.decode("utf-8")); out += " · members %s · title %s · status %s · type %s" % (",".join(d), d.get("title"), d.get("status"), d.get("type", "none"))
    except Exception: out += " · not JSON"
print(out)
PY
}
tagof() { tr -d '\r' < $J/r.h | sed -n 's/^[Ee][Tt][Aa][Gg]: //p' | head -1; }
st() { $CURL --http1.1 -s -o /dev/null -w '%{http_code}' --max-time 30 "$@"; }
acclog() { cat .harness/run/$1/access*.log 2> /dev/null | sed -E 's/^([A-Z]+ [^ ]*)- /\1 /; s/ +$//'; }   # %q prints - for no query: dropped
refusals() { $G -c 'rate limit: refused' .harness/run/$1/jvm.log || true; }
# probes LABEL: the witness's lines for that JVM (PROBE-REQ: handler, post-handle count, statements; PROBE-SQL: the statement's text),
# the request number kept (one per request, in order).
probes() { $G -E '^PROBE-(REQ|SQL) ' .harness/run/$1/jvm.log | sed -E 's/^/  witness | /'; }
apicount() { echo "  budget | $1: requests under /api/v1/ (its access log): $(acclog $1 | $G -cE '^[A-Z]+ /api/v1/' || true) · refusal lines: $(refusals $1) · the setting: ${SETL:-none}"; }
CAP5=--tiffinbox.rate-limit.capacity=5
EXPO=--management.endpoints.web.exposure.include=health,prometheus,mappings
PSQ() { dk exec "$CN" psql -U tiffinbox -d tiffinbox -qAt -v ON_ERROR_STOP=1 -c "$1" 2>&1 || die "psql failed: $1"; }
pgup() { PW=$(openssl rand -hex 12); (umask 077 && printf 'POSTGRES_USER=tiffinbox\nPOSTGRES_PASSWORD=%s\nPOSTGRES_DB=tiffinbox\n' "$PW" > .harness/pg/pg.env)
  guard "PostgreSQL"; CTRS="$CN"; MINE="${MINE:-} 21091"
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:21091:5432 --env-file .harness/pg/pg.env $PIMG" .harness/pg/run.log; [ "$RE" = 0 ] || die "PostgreSQL did not start"
  local i=0; while ! dk exec $CN pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 120 ] || die "PostgreSQL did not accept connections"; sleep 0.5; done
  echo "  postgres | $CN $(dk port $CN | paste -sd'|' -) · the image by digest $(dk inspect -f '{{.Config.Image}}' $CN | sed -E 's/@sha256:(.{8}).*/@\1/') · server_version $(PSQ 'show server_version') · ready by pg_isready (the container's own answer)"; }
pgfresh() { PSQ 'drop schema public cascade' > /dev/null; PSQ 'create schema public' > /dev/null; echo "  postgres | a fresh schema for the next JVM (drop schema public cascade; create schema public)"; }
pgdown() { dk rm -fv $CN > /dev/null 2>&1 || die "$CN could not be removed"; CTRS=""; MINE=$(echo " ${MINE:-} " | sed "s/ 21091 / /g")
  [ "$(listeners 21091)" = 0 ] || die "21091 still listens after $CN was removed"; echo "  postgres | $CN removed (rm -fv) · volumes $(dk volume ls -q | wc -l | tr -d ' ') (the start's $VOL0)"; }
mappings() { $CURL -s "$(B $1)/actuator/mappings" | python3 -I -c '
import json,sys
d=json.load(sys.stdin); fl=[]
for c in d["contexts"].values():
    for f in c["mappings"].get("servletFilters", []): fl.append("%s %s" % (f.get("name"), ",".join(f.get("urlPatternMappings", []))))
print("  %s | servlet filters: %s" % (sys.argv[1], " · ".join(sorted(fl))))' "$2"; }

# ---- the captures ----------------------------------------------------------------------------------------------------------------------
c_advisory() {
  echo "== S9.36: the read filed for Section 4 (ADV4 = _research/docs-2026-11-27/advisories-s4probe, the S4 probe's dated act; not re-read: no network), before any capture"
  echo "  fetched-at $(head -1 "$ADV/fetched-at.txt" | cut -c1-10) (the hour masked) · run date $(date '+%Y-%m-%d') · the batch day's other read (advisories/) fetched-at $(head -1 "$ADV/../advisories/fetched-at.txt" | cut -c1-10)"
  local d n=0 v=0 f h; for d in "$ADV" "$ADV/../advisories"; do n=0; v=0; while read -r h f; do n=$((n + 1)); [ "$(md5 -q "$d/$f" 2> /dev/null)" = "$h" ] && v=$((v + 1)); done < <($G -vE '^\s*$' "$d/MD5SUMS.txt" | awk '$2 != "MD5SUMS.txt" { print $1, $2 }')
    echo "  $(basename "$d")/MD5SUMS.txt: $n lines, $v verified (its own line left out)"; done
  echo "  spring index: CVE ids on its first page $($G -oE 'CVE-[0-9]{4}-[0-9]+' "$ADV/spring-security-index.html" | sort -u | wc -l | tr -d ' ') · the dates on the page: $($G -oE '(January|February|March|April|May|June|July|August|September|October|November|December) [0-9]{1,2}, 2026' "$ADV/spring-security-index.html" | sort | uniq -c | sed -E 's/^ +//' | paste -sd'|' -)"
  echo "  tomcat page md5 $(md5 -q "$ADV/tomcat-security-11.html") (the 11-24, 11-26 and 11-27 00:51 reads: a1a756d985225fb5143eefd9aae3183c)"
  local a; for a in spring-boot spring-web spring-webmvc tomcat-embed-core bucket4j_jdk17-core; do
    echo "  shipped | $a $(ls .harness/after/$XD/lib | $G -E "^$a-[0-9]" | sed -E "s/^$a-//; s/\.jar$//" | paste -sd, -)"; done
  python3 -I - "$ADV/osv-query.json" "$ADV/osv-result.json" <<'PY'
import json, sys
q = json.load(open(sys.argv[1]))["queries"]; r = json.load(open(sys.argv[2])).get("results", [])
print("  osv (second witness only, S2.8): %d coordinates queried, %d results, %d with vulns" % (len(q), len(r), sum(1 for x in r if x.get("vulns"))))
PY
  echo "  lib names before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ') · by name: $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) > /dev/null && echo equal || echo DIFFER) (flag 34: no new artifact - the filter is Spring Web's)"
  echo "  verdict: no pin affected; evidence may proceed (the read is the batch day's: run date = fetched-at date); nothing else was read from the network"; }
c_before() {
  echo "== before (21096, U19's after, H2, harness-free, the default capacity): no validator on the public API"
  TREE=before ACC=1 tb before 21096 $EXPO
  rq "before GET $RV" 21096 $RV
  rq "before GET $RV If-None-Match \"v0\"" 21096 -H 'If-None-Match: "v0"' $RV
  rq "before GET $CB" 21096 $CB
  rq "before GET $OR/1" 21096 $OR/1
  rq "before GET $RV/bill" 21096 $RV/bill
  mappings 21096 before
  apicount before
  QUIET=1 tbstop before 21096
  echo "== before, harness-joined (21096, the witness): the cached public read, cold then warm"
  TREE=before WIT=1 tb before-w 21096
  rq "before-w GET $RV #1" 21096 $RV; rq "before-w GET $RV #2" 21096 $RV
  probes before-w | $G -v 'PROBE-SQL'
  QUIET=1 tbstop before-w 21096
  echo "  before | the committed spec: $(python3 -I harness/ops9s3.py ops before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tail -1) · $(wc -c < before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tr -d ' ') B md5 $(md5 -q before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json)"
  echo "  before | BOOT-INF/lib names $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · web tests (before's own Surefire XML, U19's values block): $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit19/README.md | $G -oE 'web=[0-9]+' | head -1)"; }
census() { python3 -I - "$1/tiffinbox-web/src/main/java/com/tiffinbox/web" "$2" <<'PY'
import os, re, sys
d, side = sys.argv[1], sys.argv[2]
print("  census %s | rule (unit 15's, copied off unit 19's receipts): a class whose annotation lines include exactly @RestController or @Controller; its final modifier; @Profile(\"dev\") among those lines" % side)
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
        elif m.group(4) == "ConditionalGets":
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
  echo "  the spec's counts (ops9s3.py, each tree's own committed file): before $(python3 -I harness/ops9s3.py ops before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tail -1) · after $(python3 -I harness/ops9s3.py ops after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tail -1)"
  echo "  the generated client's files (after/'s build): $($G -c '\.java$' .harness/after/tiffinbox-client/target/generated-sources/openapi/.openapi-generator/FILES) · PATH_* (ops9s3.py paths): $(python3 -I harness/ops9s3.py paths .harness/after/tiffinbox-client/target/generated-sources/openapi 2>&1 | tail -1)"; }
WEB=tiffinbox-web/src/main/java/com/tiffinbox/web; CGF=$WEB/ConditionalGets.java; CGT=tiffinbox-web/src/test/java/com/tiffinbox/web/ConditionalGetTest.java; CRP=tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java
c_change() {
  echo "== the modules, the change file by file"
  echo "  modules: $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' before/pom.xml | paste -sd' ' -) ($($G -c '<module>' before/pom.xml)) -> $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' after/pom.xml | paste -sd' ' -) ($($G -c '<module>' after/pom.xml))"
  echo "  changed (derived: diff -rq before after/, the frozen trees - git status --short gave the same list before the commit): $(diff -rq before/ after/ | sed -E 's#^Files before/(.*) and after/.* differ$#M \1#; s#^Only in after/(.*): (.*)$#A \1/\2#; s#^Only in after/: (.*)$#A \1#; s#^Only in before/(.*): (.*)$#D \1/\2#' | sort | paste -sd'~' - | sed 's/~/ · /g')"
  local f; for f in $WEB/CustomerReads.java $WEB/CustomerPatches.java $CRP; do echo "== $f: the diff against before's (whole)"; diff before/$f after/$f | sed 's/^/    /'; done
  for f in $CGF $CGT; do echo "== $f (whole, md5 $(md5 -q after/$f))"; sed 's/^/    /' after/$f; done
  echo "  the core change: diff hunks $(diff before/$CRP after/$CRP | $G -cE '^[0-9]') · public methods added $(diff before/$CRP after/$CRP | $G -cE '^> +public Optional<' ) · records added $(diff before/$CRP after/$CRP | $G -cE '^> +public record ')"
  echo "  ConditionalGets: $($G -E 'static final class ApiEtags extends ShallowEtagHeaderFilter' after/$CGF | sed 's/^ *//') · the patterns in its source: $($G -oE 'addUrlPatterns\([^)]*\)' after/$CGF | paste -sd' ' -) · the \"/*\" literal: $($G -cF '"/*"' after/$CGF || true) · its exclusion: $($G -oE 'Pattern.compile\("[^"]*"\)' after/$CGF) · header reads (getHeader): $($G -c 'getHeader' after/$CGF || true) · @Component: $($G -c '@Component' after/$CGF || true)"
  echo "  src/main: getHeader(\"If- $(cd after && $G -rhF 'getHeader("If-' tiffinbox-web/src/main | wc -l | tr -d ' ') · checkNotModified $(cd after && $G -rhF 'checkNotModified(' tiffinbox-web/src/main/java | $G -v '^ *\*' | wc -l | tr -d ' ') · Probe/probe.s4//probe/ $(cd after && $G -rhE '(^|[^A-Za-z])Probe|probe\.s4|/probe/' tiffinbox-web/src/main tiffinbox-core/src/main | wc -l | tr -d ' ')"
  echo "  the orders (the source's constants): RateLimiting $($G -oE 'ORDER = -?[0-9]+' after/$WEB/RateLimiting.java) · IdempotencyKeys $($G -oE 'ORDER = -?[0-9]+' after/$WEB/IdempotencyKeys.java) · ConditionalGets $($G -oE 'ORDER = -?[0-9]+' after/$CGF)"
  for n in CustomerBills CustomerFeed RateLimitFilter RateLimiting IdempotencyKeys IdempotencyKeyFilter TiffinBoxErrors TiffinBoxOpenApi TiffinBoxApiVersioning OrderResources; do echo "  $n.java byte-equal to before's: $(cmp -s before/$WEB/$n.java after/$WEB/$n.java && echo yes || echo no)"; done
  for f in pom.xml tiffinbox-web/pom.xml tiffinbox-core/pom.xml tiffinbox-client/pom.xml tiffinbox-web/src/main/resources/application.yaml tiffinbox-web/src/main/resources/application-dev.yaml Dockerfile compose.yaml tiffinbox-web/src/test/resources/openapi/tiffinbox.json; do echo "  $f byte-equal to before's: $(cmp -s before/$f after/$f && echo yes || echo no)"; done
  echo "  handler names added: $(diff <(cd before && $G -rhE -A3 '@(Get|Post|Put|Patch|Delete|Request)Mapping' tiffinbox-web/src/main/java | $G -oE ' [a-z][A-Za-z]*\(' | sort -u) <(cd after && $G -rhE -A3 '@(Get|Post|Put|Patch|Delete|Request)Mapping' tiffinbox-web/src/main/java | $G -oE ' [a-z][A-Za-z]*\(' | sort -u) | $G -c '^>' || true) (U20 adds no route)"
  echo "== the registration, read from the running context (after/, 21090, harness-free; the harness's exposure flag for /actuator/mappings, this one start)"
  tb change 21090 $EXPO > /dev/null
  mappings 21090 after
  QUIET=1 tbstop change 21090
  echo "  mvn dependency:tree (the web module, -o, filtered to spring-web):"
  bg "cd .harness/after && $MV dependency:tree -pl tiffinbox-web -am" .harness/deptree.log; offl .harness/deptree.log
  $G -E 'spring-web:jar|spring-webmvc:jar' .harness/deptree.log | sed -E 's/^\[INFO\] //; s/^/    /' | sort -u; }
SHR() { local lab=$1 port=$2; local t
  rq "$lab GET $CB (cold)" $port $CB; rq "$lab GET $CB (warm)" $port $CB; t=$(tagof)
  rq "$lab GET $CB If-None-Match <its tag>" $port -H "If-None-Match: $t" $CB
  rq "$lab GET $CB If-None-Match another tag" $port -H 'If-None-Match: "0nottheone"' $CB
  rq "$lab HEAD $CB" $port -I $CB
  rq "$lab GET $OR/1 #1" $port $OR/1; rq "$lab GET $OR/1 #2" $port $OR/1; t=$(tagof)
  rq "$lab GET $OR/1 If-None-Match <its tag>" $port -H "If-None-Match: $t" $OR/1
  rq "$lab GET $OR/1 If-None-Match <its tag> again" $port -H "If-None-Match: $t" $OR/1; }
c_shallow() {
  echo "== shallow: a cached read (GET $CB: CustomerFields through CustomerRepository.findAll, cached in \"customers\") and an uncached one (GET $OR/1: OrderResources, no cache) on after/ (21090), H2"
  echo "-- harness-free (the headers)"; tb sh-free 21090 > /dev/null; SHR free 21090 | tee $J/sh-free.txt; apicount sh-free; QUIET=1 tbstop sh-free 21090
  echo "-- harness-joined (the witness: handler and statements)"; WIT=1 tb sh-wit 21090 > /dev/null; SHR wit 21090 | tee $J/sh-wit.txt; probes sh-wit | $G -v PROBE-SQL; QUIET=1 tbstop sh-wit 21090
  echo "  N3 | the two starts' answers (status, ETag, Content-Type, framing, body md5) equal: $(diff <(sed -E 's/^  (free|wit) /  /' $J/sh-free.txt) <(sed -E 's/^  (free|wit) /  /' $J/sh-wit.txt) > /dev/null && echo yes || echo NO)"
  echo "-- PostgreSQL 18.6 (c9u20-pg), harness-joined"; pgfresh; PGRUN=1 WIT=1 tb sh-pg 21090 > /dev/null; SHR pg 21090 | tee $J/sh-pg.txt; probes sh-pg | $G -v PROBE-SQL | sed 's/witness |/witness pg |/'; QUIET=1 tbstop sh-pg 21090
  echo "  H2 and PostgreSQL: the answers equal: $(diff <(sed -E 's/^  (wit|pg) /  /' $J/sh-wit.txt) <(sed -E 's/^  (wit|pg) /  /' $J/sh-pg.txt) > /dev/null && echo yes || echo NO) · the witness's handler and statement columns equal: $(diff <($G -E '^PROBE-REQ' .harness/run/sh-wit/jvm.log | sed -E 's/^PROBE-REQ [0-9]+ //') <($G -E '^PROBE-REQ' .harness/run/sh-pg/jvm.log | sed -E 's/^PROBE-REQ [0-9]+ //') > /dev/null && echo yes || echo NO)"
  echo "== shallow on the harness's /* copy (21095: before's jar + the harness's probe.Etag on /* and the witness) - the probe's old-surface pair; an old route under a filter the anchor never registers"
  TREE=before WIT=1 ETAGS=1 tb star-wit 21095 > /dev/null
  local t; rq "star GET /revenue #1" 21095 /revenue; rq "star GET /revenue #2" 21095 /revenue; t=$(tagof); rq "star GET /revenue If-None-Match <its tag>" 21095 -H "If-None-Match: $t" /revenue
  rq "star GET /customers/Ravi #1" 21095 /customers/Ravi; rq "star GET /customers/Ravi #2" 21095 /customers/Ravi; t=$(tagof); rq "star GET /customers/Ravi If-None-Match <its tag>" 21095 -H "If-None-Match: $t" /customers/Ravi
  probes star-wit | $G -v PROBE-SQL | sed 's/witness |/witness star |/'; QUIET=1 tbstop star-wit 21095; }
feed() { local port=$1 lab=$2 t=$U/$J/feed-$2; : > "$t.h"; : > "$t.b"
  perl -e '$SIG{ALRM}=sub{kill "TERM",$pid; exit 3}; alarm 10; $pid=open(my $c,"-|",@ARGV) or die; $s=0; while(defined($l=<$c>)){print $l; if($l=~/^\r?\n$/){last if $s} else {$s=1}} kill "TERM",$pid; exit 0' \
     curl --noproxy '*' --http1.1 -sS -N -D "$t.h" -H 'Accept: text/event-stream' "$(B $port)/customers/feed" > "$t.b" 2>/dev/null; local frc=$?
  echo "  $lab GET /customers/feed (by count: headers + the first event, alarm 10) -> reader exit $frc · status $(tr -d '\r' < "$t.h" | head -1 | cut -d' ' -f2) · $(tr -d '\r' < "$t.h" | $G -i '^Content-Type:' | cut -d' ' -f2) · ETag $(tr -d '\r' < "$t.h" | $G -ic '^ETag:' || true) · chunked $(tr -d '\r' < "$t.h" | $G -ic '^Transfer-Encoding: chunked' || true) · body $(wc -c < "$t.b" | tr -d ' ') B: $(tr -d '\r' < "$t.b" | tr '\n' '~')"; }
c_paths() {
  echo "== paths: what the filter reaches on after/ (21090, H2, harness-free) beside before (21096)"
  local s port lnk; for s in before after; do [ $s = before ] && port=21096 || port=21090
    TREE=$s tb paths-$s $port $EXPO > /dev/null
    [ $s = after ] && mappings $port after
    feed $port $s
    for p in /revenue /actuator/health /v3/api-docs /customers/Ravi; do rq "$s GET $p" $port $p; done
    rq "$s GET $RV/bill" $port $RV/bill
    rq "$s GET $RV/bill-link" $port $RV/bill-link; lnk=$(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d.get("href") or d.get("url") or d.get("link") or "")' $J/r.b 2> /dev/null | sed -E 's#^https?://[^/]+##')
    [ -n "$lnk" ] && rq "$s GET <the signed link, opened inside its lifetime>" $port "$lnk"
    apicount paths-$s
    QUIET=1 tbstop paths-$s $port; done
  echo "== the LOSER, the harness's /* copy (21095: before's jar + the harness's probe.Etag on /*, harness-joined for the filter only - no witness lines read here)"
  TREE=before ETAGS=1 WIT=1 tb star 21095 > /dev/null
  feed 21095 star
  rq "star GET /dashboard (Accept: text/html)" 21095 -H 'Accept: text/html' /dashboard
  rq "star POST /customers (JSON, a fresh name)" 21095 -X POST -H 'Content-Type: application/json' --data-binary '{"name":"Asha","mealsPerDay":1,"pricePerMeal":110,"mealType":"VEG"}' /customers
  QUIET=1 tbstop star 21095
  echo "  the old surface by count on before (21096) and on the /* copy (21095) - the S9.14 self-test: the detector moves"
  TREE=before tb os-before 21096 > /dev/null; oldsurface2 21096 $J/os-before.txt; QUIET=1 tbstop os-before 21096
  TREE=before ETAGS=1 WIT=1 tb os-star 21095 > /dev/null; oldsurface2 21095 $J/os-star.txt; QUIET=1 tbstop os-star 21095
  echo "  star | the old surface: before $(md5 -q $J/os-before.txt) · the /* copy $(md5 -q $J/os-star.txt) · differ: $(cmp -s $J/os-before.txt $J/os-star.txt && echo no || echo yes) · diff lines $(diff $J/os-before.txt $J/os-star.txt | $G -c '^[<>]') · answers that gained an ETag $(diff $J/os-before.txt $J/os-star.txt | $G -c '^> ETag:' || true) · lost chunked $(diff $J/os-before.txt $J/os-star.txt | $G -ci '^< Transfer-Encoding: chunked' || true)"
  diff $J/os-before.txt $J/os-star.txt | $G -E '^[<>] (ETag|Transfer-Encoding|Content-Length|== )' | sed 's/^/  star | moved /'
  echo "== the unfiltered-bill copy (21095: before's jar + the harness's probe.Etag on /api/v1/* with no exclusion) - the move a filter without the exclusion makes on a public route"
  TREE=before ETAGS=1 WIT=1 tb nobill 21095 '--probe.etag.paths=/api/v1/*' > /dev/null
  rq "nobill GET $RV/bill" 21095 $RV/bill
  QUIET=1 tbstop nobill 21095
  echo "== limiter (after/, 21090, H2, cap=5 - the labelled run flag $CAP5): five reads of $CB, then the sixth"
  tb lim 21090 $CAP5 > /dev/null; local i; for i in 1 2 3 4 5 6; do rq "lim GET $CB #$i" 21090 $CB; done; apicount lim; QUIET=1 tbstop lim 21090; }
c_weak() {
  echo "== weak: If-None-Match variants on after/ (21090, H2, harness-free); the tags the server writes"
  tb weak 21090 > /dev/null
  local t; rq "weak GET $CB" 21090 $CB; t=$(tagof)
  rq "weak $CB INM the tag" 21090 -H "If-None-Match: $t" $CB
  rq "weak $CB INM W/ + the tag" 21090 -H "If-None-Match: W/$t" $CB
  rq "weak $CB INM another" 21090 -H 'If-None-Match: "0other"' $CB
  rq "weak $CB INM *" 21090 -H 'If-None-Match: *' $CB
  rq "weak $CB INM a list (another, the tag)" 21090 -H "If-None-Match: \"0other\", $t" $CB
  rq "weak GET $RV" 21090 $RV
  rq "weak $RV INM \"v0\"" 21090 -H 'If-None-Match: "v0"' $RV
  rq "weak $RV INM W/\"v0\"" 21090 -H 'If-None-Match: W/"v0"' $RV
  rq "weak $RV INM \"v7\"" 21090 -H 'If-None-Match: "v7"' $RV
  rq "weak $RV INM *" 21090 -H 'If-None-Match: *' $RV
  rq "weak $RV INM a list (\"v7\", \"v0\")" 21090 -H 'If-None-Match: "v7", "v0"' $RV
  apicount weak; QUIET=1 tbstop weak 21090
  }
DEEP() { local lab=$1 port=$2
  rq "$lab GET $RV #1" $port $RV; rq "$lab GET $RV #2" $port $RV
  rq "$lab GET $RV If-None-Match \"v0\"" $port -H 'If-None-Match: "v0"' $RV
  rq "$lab GET $RV If-None-Match \"v7\"" $port -H 'If-None-Match: "v7"' $RV
  rq "$lab HEAD $RV" $port -I $RV
  rq "$lab PATCH $RV (merge, no If-Match)" $port -X PATCH -H "$MPT" --data-binary '{"mealsPerDay":3}' $RV
  rq "$lab GET $RV after the PATCH" $port $RV
  rq "$lab GET $RV If-None-Match \"v0\" (the old tag)" $port -H 'If-None-Match: "v0"' $RV
  rq "$lab GET /customers/Ravi #1 (the old address)" $port /customers/Ravi; rq "$lab GET /customers/Ravi #2" $port /customers/Ravi; }
c_deep() {
  echo "== deep: the row's version as the tag on GET $RV (after/, 21090), H2 and PostgreSQL 18.6; harness-free for the headers, harness-joined for the counts"
  echo "-- before's body for the same read (21096, harness-free)"; TREE=before tb deep-before 21096 > /dev/null; rq "before GET $RV" 21096 $RV
  echo "  deep | the tag a bare shallow filter would write on that body (\"0\" + its md5, as ShallowEtagHeaderFilter writes): $(printf '"0%s"' "$(md5 -q $J/r.b)") - not the handler's tag"; QUIET=1 tbstop deep-before 21096
  echo "-- H2, harness-free"; tb deep-free 21090 > /dev/null; DEEP free 21090 | tee $J/deep-free.txt; QUIET=1 tbstop deep-free 21090
  echo "-- H2, harness-joined"; WIT=1 tb deep-wit 21090 > /dev/null; DEEP wit 21090 | tee $J/deep-wit.txt; probes deep-wit; QUIET=1 tbstop deep-wit 21090
  echo "  N3 | the two starts' answers equal: $(diff <(sed -E 's/^  (free|wit) /  /' $J/deep-free.txt) <(sed -E 's/^  (free|wit) /  /' $J/deep-wit.txt) > /dev/null && echo yes || echo NO)"
  echo "-- PostgreSQL 18.6 (c9u20-pg), harness-joined"; pgfresh; PGRUN=1 WIT=1 tb deep-pg 21090 > /dev/null; DEEP pg 21090 | tee $J/deep-pg.txt; probes deep-pg | sed 's/witness |/witness pg |/'; QUIET=1 tbstop deep-pg 21090
  echo "  H2 and PostgreSQL: the answers equal: $(diff <(sed -E 's/^  (wit|pg) /  /' $J/deep-wit.txt) <(sed -E 's/^  (wit|pg) /  /' $J/deep-pg.txt) > /dev/null && echo yes || echo NO) · the witness's handler and statement columns equal: $(diff <($G -E '^PROBE-REQ' .harness/run/deep-wit/jvm.log | sed -E 's/^PROBE-REQ [0-9]+ //') <($G -E '^PROBE-REQ' .harness/run/deep-pg/jvm.log | sed -E 's/^PROBE-REQ [0-9]+ //') > /dev/null && echo yes || echo NO)"
  echo "== identity: a re-created name (after/, 21090, H2, harness-free, 1/1 per run)"
  tb ident 21090 > /dev/null
  rq "ident POST /customers Zed" 21090 -X POST -H 'Content-Type: application/json' --data-binary '{"name":"Zed","mealsPerDay":1,"pricePerMeal":100,"mealType":"VEG"}' /customers
  rq "ident GET $CAPI/Zed (the first row)" 21090 $CAPI/Zed
  rq "ident PATCH $CAPI/Zed rename to Zed-old (no If-Match)" 21090 -X PATCH -H "$MPT" --data-binary '{"name":"Zed-old"}' $CAPI/Zed
  rq "ident GET $CAPI/Zed-old (the first row, renamed)" 21090 $CAPI/Zed-old
  rq "ident POST /customers Zed again (a new row)" 21090 -X POST -H 'Content-Type: application/json' --data-binary '{"name":"Zed","mealsPerDay":3,"pricePerMeal":150,"mealType":"VEGAN"}' /customers
  rq "ident GET $CAPI/Zed (the new row)" 21090 $CAPI/Zed
  rq "ident GET $CAPI/Zed If-None-Match \"v0\" (the first row's tag)" 21090 -H 'If-None-Match: "v0"' $CAPI/Zed
  apicount ident; QUIET=1 tbstop ident 21090; }
IFM() { local lab=$1 port=$2 r n=0 name
  for r in merge json; do n=$((n + 1)); name="Ifm-$r"
    rq "$lab POST /customers $name" $port -X POST -H 'Content-Type: application/json' --data-binary "{\"name\":\"$name\",\"mealsPerDay\":2,\"pricePerMeal\":100,\"mealType\":\"VEG\"}" /customers
    pp() { if [ $r = merge ]; then rq "$lab $r $1" $port -X PATCH -H "$MPT" ${2:+-H "If-Match: $2"} --data-binary "{\"mealsPerDay\":$3}" $CAPI/$name; else rq "$lab $r $1" $port -X PATCH -H "$JPT" ${2:+-H "If-Match: $2"} --data-binary "[{\"op\":\"replace\",\"path\":\"/mealsPerDay\",\"value\":$3}]" $CAPI/$name; fi; }
    rq "$lab $r GET (the tag)" $port $CAPI/$name
    pp "(1) If-Match \"v0\" (current)" '"v0"' 3
    rq "$lab $r GET after (1)" $port $CAPI/$name
    pp "(2) If-Match \"v0\" again (stale)" '"v0"' 1
    rq "$lab $r GET after (2)" $port $CAPI/$name
    pp "(3) If-Match W/\"v1\" (weak, current)" 'W/"v1"' 1
    rq "$lab $r GET after (3)" $port $CAPI/$name
    pp "(4) no If-Match" '' 1
    rq "$lab $r GET after (4)" $port $CAPI/$name
    pp "(5) If-Match *" '*' 2
    pp "(5) If-Match a list \"v0\", \"v3\"" '"v0", "v3"' 3
    rq "$lab $r GET after (5)" $port $CAPI/$name
    if [ $r = merge ]; then
      rq "$lab $r (6) an unknown customer, If-Match stale" $port -X PATCH -H "$MPT" -H 'If-Match: "v0"' --data-binary '{"mealsPerDay":1}' $CAPI/Nobody
      rq "$lab $r (6) If-Match stale, a body that is not JSON" $port -X PATCH -H "$MPT" -H 'If-Match: "v0"' --data-binary 'not json' $CAPI/$name
      rq "$lab $r (6) If-Match stale, text/plain" $port -X PATCH -H 'Content-Type: text/plain' -H 'If-Match: "v0"' --data-binary '{}' $CAPI/$name
    fi; done; }
c_ifmatch() {
  echo "== ifmatch: both PATCH routes (merge patch, JSON Patch) on after/ (21090), each case's customer its own (POST /customers), harness-joined - H2 then PostgreSQL 18.6"
  echo "-- H2"; WIT=1 tb ifm-h2 21090 > /dev/null; IFM h2 21090 | tee $J/ifm-h2.txt; probes ifm-h2; apicount ifm-h2; QUIET=1 tbstop ifm-h2 21090
  echo "-- PostgreSQL 18.6 (c9u20-pg)"; pgfresh; PGRUN=1 WIT=1 tb ifm-pg 21090 > /dev/null; IFM pg 21090 | tee $J/ifm-pg.txt; probes ifm-pg | sed 's/witness |/witness pg |/'
  echo "  postgres | the two rows read back by psql inside $CN: $(PSQ "select name || ' meals ' || meals_per_day || ' version ' || version from customer where name like 'Ifm-%' order by name" | paste -sd'|' -)"
  echo "  postgres | the version column: $(PSQ "select column_name || ' ' || data_type || ' ' || is_nullable || ' default ' || coalesce(column_default,'none') from information_schema.columns where table_name='customer' and column_name='version'")"
  QUIET=1 tbstop ifm-pg 21090
  echo "  H2 and PostgreSQL: the answers equal: $(diff <(sed -E 's/^  (h2|pg) /  /' $J/ifm-h2.txt) <(sed -E 's/^  (h2|pg) /  /' $J/ifm-pg.txt) > /dev/null && echo yes || echo NO) · the witness's handler and statement columns equal: $(diff <($G -E '^PROBE-REQ' .harness/run/ifm-h2/jvm.log | sed -E 's/^PROBE-REQ [0-9]+ //') <($G -E '^PROBE-REQ' .harness/run/ifm-pg/jvm.log | sed -E 's/^PROBE-REQ [0-9]+ //') > /dev/null && echo yes || echo NO)"
  echo "  Course 7's names (D15), re-read on after/: $($G -nE '@Version|public Long getVersion' after/tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntity.java | sed 's/  */ /g' | paste -sd'|' -) · the migration: $($G -rhiE 'version +BIGINT' after/tiffinbox-core/src/main/resources/db/migration | head -1 | sed 's/^ *//') · the exception class named in the source: $($G -rlF 'ObjectOptimisticLockingFailureException' after/tiffinbox-web/src/main after/tiffinbox-core/src/main | wc -l | tr -d ' ') file(s) - not provoked here (a stale tag is refused before the write; no race is run)"; }
c_cache() {
  echo "== cache: Course 6 U23's stylesheet on after/ (21090, H2, harness-free; the static handler reads no database) - Framework $(ls .harness/after/$XD/lib | $G -E '^spring-webmvc-' | sed 's/^spring-webmvc-//; s/\.jar$//')"
  tb cache 21090 > /dev/null
  rq "cache GET /dashboard (Accept: text/html)" 21090 -H 'Accept: text/html' /dashboard
  local css; css=$($G -oE '/css/tiffinbox[^"]*\.css' $J/r.b | head -1)
  echo "  cache | the page's stylesheet link: $css"
  rq "cache GET /css/tiffinbox.css" 21090 /css/tiffinbox.css
  echo "  cache | its headers: $(tr -d '\r' < $J/r.h | $G -iE '^(Last-Modified|Cache-Control|ETag):' | paste -sd'|' -)"
  rq "cache GET $css (the versioned name)" 21090 "$css"
  local tag lm; tag=$(tagof); lm=$(tr -d '\r' < $J/r.h | sed -n 's/^[Ll]ast-[Mm]odified: //p')
  echo "  cache | its headers: $(tr -d '\r' < $J/r.h | $G -iE '^(Last-Modified|Cache-Control|ETag):' | paste -sd'|' -)"
  rq "cache $css If-None-Match its own tag alone" 21090 -H "If-None-Match: $tag" "$css"
  rq "cache $css If-Modified-Since its own date alone" 21090 -H "If-Modified-Since: $lm" "$css"
  rq "cache $css both headers" 21090 -H "If-None-Match: $tag" -H "If-Modified-Since: $lm" "$css"
  QUIET=1 tbstop cache 21090
  local wj; wj=$(ls "$M2"/org/springframework/spring-webmvc/7.0.11/spring-webmvc-7.0.11.jar)
  echo "  javap -c -p org.springframework.web.servlet.resource.ResourceHttpRequestHandler (the pinned spring-webmvc-7.0.11.jar in the seed copy), its checkNotModified calls:"
  javap -c -p -cp "$wj" org.springframework.web.servlet.resource.ResourceHttpRequestHandler | $G -F 'checkNotModified' | sed -E 's/^ +[0-9]+: //; s/^/    /' | sort -u; }
chromeup() { local lab=$1 i=0; guard "Chrome $lab"
  [ "$(listeners 21097)" = 0 ] && [ -z "$(lsof -nP -iUDP:21097 2> /dev/null)" ] || die "21097 is bound before Chrome $lab"
  rm -rf ".harness/chrome-$lab" ".harness/netlog-$lab.json"
  CHF=(--headless=new "--user-data-dir=$U/.harness/chrome-$lab" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 "--host-resolver-rules=MAP * ~NOTFOUND, EXCLUDE 127.0.0.1" --remote-debugging-address=127.0.0.1 --remote-debugging-port=21097 "--log-net-log=$U/.harness/netlog-$lab.json" about:blank)
  "$CHROME" "${CHF[@]}" > ".harness/chrome-$lab.log" 2>&1 < /dev/null & CPID=$!
  echo "  Chrome $lab: headless, the flags: $(printf '%s ' "${CHF[@]}" | sed "s#$U#…#g")"
  while ! $CURL -s -o /dev/null --max-time 1 http://127.0.0.1:21097/json/version; do kill -0 $CPID 2> /dev/null || die "Chrome $lab exited before its DevTools answered"; i=$((i + 1)); [ $i -lt 300 ] || die "Chrome $lab: no DevTools"; sleep 0.1; done
  MINE="${MINE:-} 21097"; echo "  Chrome $lab up: its DevTools answered on 127.0.0.1:21097 (its pid recorded at launch)"; }
chromedown() { local lab=$1 i=0
  node harness/cdp.mjs 21097 close > /dev/null 2>&1 || true
  while kill -0 $CPID 2> /dev/null; do i=$((i + 1)); [ $i -lt 100 ] || { killtree $CPID; echo "  Chrome $lab: still there after Browser.close - stopped by its recorded pid tree"; break; }; sleep 0.1; done
  wait $CPID 2> /dev/null || true; kill -0 $CPID 2> /dev/null && die "Chrome $lab: its pid is still alive"
  CPID=""; MINE=$(echo " ${MINE:-} " | sed "s/ 21097 / /g"); rm -rf ".harness/chrome-$lab"
  local j=0; while [ "$(listeners 21097)" != 0 ]; do j=$((j + 1)); [ $j -lt 100 ] || die "21097 still bound after Chrome $lab"; sleep 0.1; done
  echo "  Chrome $lab stopped by Browser.close (cdp.mjs close): its pid gone, its profile folder removed, 21097 free"; }
CAPAT='%m %U%q %s %b "%{If-None-Match}i" "%{ETag}o" "%{User-Agent}i"'
visit() { local lab=$1 port=$2 url=$3
  chromeup $lab
  node harness/cdp.mjs 21097 open "$url" $J/open-$lab.json | sed -E 's/^/  ~ cdp open | /'
  node harness/cdp.mjs 21097 reload $J/reload-$lab.json | sed -E 's/^/  ~ cdp reload | /'
  echo "  -- $lab: the open, Chrome's events (chrome20.py)"; python3 -I harness/chrome20.py $J/open-$lab.json $port | sed "s/chrome20 |/chrome20 $lab open |/"
  echo "  -- $lab: the reload, Chrome's events (chrome20.py)"; python3 -I harness/chrome20.py $J/reload-$lab.json $port | sed "s/chrome20 |/chrome20 $lab reload |/"; echo "  chrome20 ($lab reload) exit ${PIPESTATUS[0]}"
  python3 -I $NETPY $J/reload-$lab.json $port | sed "s/^ */  net.py $lab reload | /"
  python3 -I harness/seal9.py cdp $J/reload-$lab.json $port > /dev/null 2>&1; echo "  seal9.py cdp ($lab reload) exit $?"
  chromedown $lab
  python3 -I harness/seal9.py netlog .harness/netlog-$lab.json | sed "s/^ */  ~ netlog $lab: /"; echo "  seal9.py netlog ($lab) exit ${PIPESTATUS[0]}"
  python3 -I $NETLOG .harness/netlog-$lab.json 2>&1 | tail -3 | sed "s/^ */  ~ netlog.py $lab | /"
  python3 -I - .harness/netlog-$lab.json $lab <<'PY'
import json, sys
d = json.load(open(sys.argv[1])); t = {v: k for k, v in d["constants"]["logEventTypes"].items()}
tcp = [e["params"]["address"] for e in d["events"] if t.get(e["type"]) in ("TCP_CONNECT_ATTEMPT", "TCP_CONNECT") and "address" in e.get("params", {})]
src = {}
for e in d["events"]: src.setdefault(e.get("source", {}).get("id"), []).append(e)
udp, fails, errs = 0, 0, set()
for sid, evs in src.items():
    for i, e in enumerate(evs):
        if t.get(e["type"]) == "UDP_CONNECT" and "address" in e.get("params", {}) and not e["params"]["address"].startswith(("127.", "[::1]")):
            udp += 1
            nxt = [x for x in evs[i + 1:] if t.get(x["type"]) == "UDP_CONNECT" and "net_error" in x.get("params", {})]
            if nxt: fails += 1; errs.add(str(nxt[0]["params"]["net_error"]))
sent = sum(1 for e in d["events"] if t.get(e["type"]) in ("UDP_BYTES_SENT", "UDP_SEND_ERROR"))
print("  ~ udp %s | TCP connects not to 127.0.0.1: %d · UDP connects not to loopback: %d, each failed: %s (net_error %s) · UDP bytes sent: %d" % (sys.argv[2], sum(1 for a in tcp if not a.startswith("127.0.0.1:")), udp, "yes" if fails == udp else "no", ",".join(sorted(errs)) or "none", sent))
PY
}
c_chrome() {
  echo "== chrome: sealed headless Chrome (the app on disk, Course 6 U23's flags), DevTools on 127.0.0.1:21097; Chrome's version: $("$CHROME" --version 2> /dev/null | sed -E 's/[0-9][0-9.]+/<version>/')"
  echo "-- leg A, the shipped route: after/ (21090, H2, harness-free, the access log with the request's If-None-Match, the answer's ETag and the agent)"
  APAT="$CAPAT" ACC=1 tb chrome-a 21090 > /dev/null
  visit a 21090 "http://127.0.0.1:21090$RV"
  echo "  -- a: TiffinBox's access log"; acclog chrome-a | sed 's/^/  access a | /'
  QUIET=1 tbstop chrome-a 21090
  echo "-- leg B, the harness's page copy: after/'s jar + the harness's probe.Etag on /dashboard only + the two run flags (the plain stylesheet answers no-cache), 21095"
  ETAGS=1 WIT=1 APAT="$CAPAT" ACC=1 tb chrome-b 21095 --probe.etag.paths=/dashboard --spring.web.resources.chain.strategy.content.enabled=false --spring.web.resources.cache.cachecontrol.no-cache=true > /dev/null
  visit b 21095 "http://127.0.0.1:21095/dashboard"
  echo "  -- b: TiffinBox's access log"; acclog chrome-b | sed 's/^/  access b | /'
  QUIET=1 tbstop chrome-b 21095
  echo "  ~ the author's own Chrome: $(pgrep -x 'Google Chrome' | wc -l | tr -d ' ') main process(es) after (before the run: $CHR0)"
  echo '[]' > $J/ev-empty.json; python3 -I harness/chrome20.py $J/ev-empty.json 21090 > /dev/null 2>&1; echo "  chrome20.py on an empty event file: exit $?"; }
c_metrics() {
  echo "== metrics: after/ (21090, H2, harness-free; the harness's exposure flag), a 200, a 304 and a 412, then one scrape"
  tb met 21090 $EXPO > /dev/null
  echo "  met | GET $RV -> $(st "$(B 21090)$RV") · If-None-Match \"v0\" -> $(st -H 'If-None-Match: "v0"' "$(B 21090)$RV") · PATCH merge If-Match \"v9\" -> $(st -X PATCH -H "$MPT" -H 'If-Match: "v9"' --data-binary '{"mealsPerDay":1}' "$(B 21090)$RV")"
  $CURL -s "$(B 21090)/actuator/prometheus" | $G -E '^http_server_requests_seconds_count\{' | $G -F 'uri="/api/v1/customers/{name}"' | sed -E 's/\} .*/} <count>/; s/^/  met | /'
  $CURL -s "$(B 21090)/actuator/prometheus" | $G -E '^http_server_requests_seconds_count\{' | $G -F 'uri="/api/v1/customers/{name}"' | python3 -I -c '
import sys, re
for l in sys.stdin:
    m = re.search(r"method=\"(\w+)\".*?outcome=\"(\w+)\".*?status=\"(\d+)\".*\} ([0-9.]+)", l)
    if m: print("  met | %s %s %s: count %d" % (m.group(1), m.group(3), m.group(2), int(float(m.group(4)))))'
  QUIET=1 tbstop met 21090; }
c_spec() {
  echo "== spec: the committed file against the served document (after/, 21090, harness-free) - unchanged by this unit (C6 (a))"
  tb spec 21090 > /dev/null
  local SF=after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json BF=before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json
  $CURL -s "$(B 21090)/v3/api-docs" > $J/served.json
  echo "  the committed file against the served document (servers removed, json.dump indent 2, ensure_ascii False, a final newline): $(python3 -I -c '
import json,sys
d=json.load(open(sys.argv[1])); d.pop("servers",None)
print("equal" if json.dumps(d,indent=2,ensure_ascii=False)+"\n" == open(sys.argv[2],encoding="utf-8").read() else "differ")' $J/served.json $SF)"
  echo "  committed md5 before $(md5 -q $BF) · after $(md5 -q $SF) · bytes before $(wc -c < $BF | tr -d ' ') · after $(wc -c < $SF | tr -d ' ') · byte-equal: $(cmp -s $BF $SF && echo yes || echo no)"
  python3 -I harness/ops9s3.py ops $BF > $J/ops-before.txt; python3 -I harness/ops9s3.py ops $SF > $J/ops-after.txt
  echo "  before: $(tail -1 $J/ops-before.txt) · after: $(tail -1 $J/ops-after.txt) · the operations' ids before -> after: $(cmp -s $J/ops-before.txt $J/ops-after.txt && echo equal || echo differ)"
  printf '{}' > $J/empty.json; python3 -I harness/ops9s3.py ops $J/empty.json > /dev/null 2>&1; echo "  ops9s3.py on an empty spec: exit $? (refused)"
  echo "  the served document: 304 responses $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(sum(1 for v in d["paths"].values() for o in v.values() if "304" in o.get("responses", {})))' $J/served.json) · 412 responses $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(sum(1 for v in d["paths"].values() for o in v.values() if "412" in o.get("responses", {})))' $J/served.json) · ETag named $($G -c 'ETag' $J/served.json || true) · If-Match named $($G -c 'If-Match' $J/served.json || true) - the ETag header on the two hundreds, If-Match on the two PATCH operations, 304 on the GET operations and 412 on the PATCH operations are answers no operation documents; the served spec and the committed one both say nothing of them"
  echo "  OpenApiSpecTest on the committed file: $(python3 -I -c '
import sys,xml.etree.ElementTree as E
r=E.parse(sys.argv[1]).getroot(); print("tests %s failures %s errors %s" % (r.get("tests"), r.get("failures"), r.get("errors")))' .harness/after/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.OpenApiSpecTest.xml) (after/'s build)"
  echo "  the client: tiffinbox-client byte-equal before -> after/: $(diff -rq before/tiffinbox-client after/tiffinbox-client > /dev/null && echo yes || echo no) · its generated FILES (after/'s build): $($G -c '\.java$' .harness/after/tiffinbox-client/target/generated-sources/openapi/.openapi-generator/FILES) · PATH_* (ops9s3.py paths): $(python3 -I harness/ops9s3.py paths .harness/after/tiffinbox-client/target/generated-sources/openapi 2>&1 | tail -1)"
  QUIET=1 tbstop spec 21090; }
movedone() { local port=$1 m=$2 p=$3 w; shift 3; : > $J/mv.h; : > $J/mv.b
  w=$($CURL --http1.1 -sS -D $J/mv.h -o $J/mv.b -w '%{http_code} %{content_type} %{size_download}' --max-time 5 -X "$m" "$@" "$(B $port)$p" 2> /dev/null)
  local bm; bm=$(sed -E 's/"timestamp":"[^"]*"/"timestamp":"<masked>"/; s/"next":"[^"]*"/"next":"<cursor>"/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/<uuid>/g; s/expires=[0-9]+/expires=<masked>/g; s/sig=[A-Za-z0-9_-]+/sig=<masked>/g' $J/mv.b | md5 -q | cut -c1-12)
  w=$(echo "$w" | awk '{ print $1, $2 }'); case "$p" in /api/v1/*) MVN=$((MVN + 1));; esac
  local hd; hd=$(tr -d '\r' < $J/mv.h | sed -n '2,$p' | $G -v '^$' | sed -E 's/:.*//' | tr 'A-Z' 'a-z' | $G -vxE 'date|keep-alive|connection|content-length|transfer-encoding|set-cookie|expires' | sort | paste -sd, -)
  echo "  $SIDE | $m $p$( [ -n "${TAG:-}" ] && echo " [$TAG]") -> $w · Allow {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Aa]llow: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)} · headers {$hd} · body $bm"; }
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
  echo "  $SIDE | requests sent to /api/v1/ by this JVM (counted by the list): $MVN - the setting read back by its start line: ${SETL:-none}"
  QUIET=1 tbstop moved-$side $port; }
c_moved() { echo "== moved: U18's requests (U19's movedside list, copied; the headers' names beside Allow) on before (21096) and after/ (21090), H2, each its own JVM, the default capacity"
  movedside before 21096; movedside after 21090
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
import sys, json, re, hashlib, http.client
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
for u in urls:
    c = http.client.HTTPConnection("127.0.0.1", int(port), timeout=10); c.request("GET", u); r = c.getresponse(); b = r.read(); st = r.status
    h = {k.lower(): v for k, v in r.getheaders()}; c.close()
    fr = "chunked" if h.get("transfer-encoding", "").lower() == "chunked" else ("Content-Length" if "content-length" in h else "none")
    et = h.get("etag")
    et = "none" if et is None else (et if re.fullmatch(r'"v\d+"', et) else "<shallow tag>")
    hs = ",".join(sorted(k for k in h if k not in ("date", "keep-alive", "connection", "content-length", "transfer-encoding")))
    print("  api | GET %s -> %s %s · headers {%s} · etag %s · framing %s · body %s" % (u, st, h.get("content-type"), hs, et, fr, hashlib.md5(mask(b).encode()).hexdigest()[:12]))
PY
  QUIET=1 tbstop api-$side $port; }
c_api() { echo "== api: every GET of the committed spec's /api/v1/ paths (filled: name Ravi, id 1; the run id zeros; the signed link expired) and two old refusals, on before (21096) and after/ (21090), H2, the default capacity, each its own JVM - with the header names, the tag (shallow masked, deep raw) and the framing"
  apiside before 21096; apiside after 21090
  sed 's/^  api |/  api before |/' $J/api-before.txt; sed 's/^  api |/  api after |/' $J/api-after.txt
  echo "  api | before -> after/: $(cmp -s $J/api-before.txt $J/api-after.txt && echo identical || echo "differ") ($(wc -l < $J/api-after.txt | tr -d ' ') requests each)"
  python3 -I - $J/api-before.txt $J/api-after.txt <<'PY'
import sys, re
rx = re.compile(r"^  api \| GET (\S+) -> (\d+) (\S+) · headers \{([^}]*)\} · etag (.*?) · framing (\S+) · body (\S+)$")
a = [rx.match(l).groups() for l in open(sys.argv[1]) if l.strip()]; b = [rx.match(l).groups() for l in open(sys.argv[2]) if l.strip()]
other = 0
for x, y in zip(a, b):
    if x == y: continue
    hx, hy = set(filter(None, x[3].split(","))), set(filter(None, y[3].split(",")))
    added = sorted(hy - hx); removed = sorted(hx - hy)
    note = "  api | moved %s: headers +%s -%s · etag %s -> %s · framing %s -> %s · status %s -> %s · body %s" % (y[0], ",".join(added) or "none", ",".join(removed) or "none", x[4], y[4], x[5], y[5], x[1], y[1], "equal" if x[6] == y[6] else "MOVED")
    print(note)
    if not (added in ([], ["etag"]) and not removed and x[1] == y[1] and x[2] == y[2] and x[6] == y[6]): other += 1
print("  api | additive: %s · lines moved %d · tagged after %d (deep %d) · untagged after %d · moved other than the tag and the framing: %d" % ("yes" if other == 0 else "NO", sum(1 for x, y in zip(a, b) if x != y), sum(1 for y in b if y[4] != "none"), sum(1 for y in b if y[4].startswith('"v')), sum(1 for y in b if y[4] == "none"), other))
PY
}
c_seven() {
  echo "== the seven (c5-unit11/curlset.sh, no key header), each tree its own JVM, H2, the default capacity - not a witness for the filter: it sends nothing to /api/v1/"
  echo "  expected $S466"
  local s port i; for s in before after; do [ $s = before ] && port=21096 || port=21090
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
  echo "== the old surface by count (U18's reader, copied), each tree its own JVM, H2, the default capacity - not a witness for the filter"
  echo "  expected $U4SURF"
  for side in before after; do [ $side = before ] && port=21096 || port=21090
    TREE=$side tb surface-$side $port > /dev/null
    oldsurface2 $port $J/surface-$side.txt
    QUIET=1 tbstop surface-$side $port
    echo "  $side: the old surface $(md5 -q $J/surface-$side.txt) ($($G -c '^== ' $J/surface-$side.txt) requests, $(wc -l < $J/surface-$side.txt | tr -d ' ') lines)"; done
  echo "  before -> after/: $(cmp -s $J/surface-before.txt $J/surface-after.txt && echo equal || echo DIFFER)"
  echo "  the S9.14 plant slot: the harness's /* copy in paths (21095) - its old surface differs from before's (the detector works)"; }
c_moving() {
  echo "== moving (R.558): three fresh starts of after/ on one port (21090, H2, harness-free, the default capacity), the tag of five routes each"
  local k r; : > $J/moving.txt
  for k in 1 2 3; do tb mov-$k 21090 > /dev/null
    for r in $OR $RV/bill-link $RV $CB $OR/1; do printf '%s %s\n' "$r" "$($CURL --http1.1 -s -D - -o /dev/null "$(B 21090)$r" | tr -d '\r' | sed -n 's/^[Ee][Tt][Aa][Gg]: //p')" >> $J/moving.txt; done
    QUIET=1 tbstop mov-$k 21090; done
  for r in $OR $RV/bill-link $RV $CB $OR/1; do echo "  moving | $r: distinct tags over three starts $(awk -v r="$r" '$1 == r { print $2 }' $J/moving.txt | sort -u | wc -l | tr -d ' ') · masked in hashed lines: $(if [ "$r" = "$RV" ]; then echo 'no (the deep tag, raw)'; else echo yes; fi)"; done; }
c_inert() {
  echo "== the key header across this run's captures (request lines)"
  echo "  keyed requests in this run's captures: $(ls .r-*.new 2> /dev/null | $G -vxF .r-inert.new | xargs cat 2> /dev/null | $G -ciF 'Idempotency''-Key:' || true)"
  echo "  IdempotencyKeyFilter byte-equal to before's: $(cmp -s before/$WEB/IdempotencyKeyFilter.java after/$WEB/IdempotencyKeyFilter.java && echo yes || echo no)"; }
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
  python3 -I - .harness/pkg/tiffinbox-web/target/surefire-reports ../c9-unit19/README.md <<'PY'
import sys, glob, xml.etree.ElementTree as E
n = {E.parse(f).getroot().get("name").split(".")[-1]: E.parse(f).getroot() for f in glob.glob(sys.argv[1] + "/TEST-*.xml")}
for k in sorted(n): print("  package | class %s | tests %s failures %s errors %s skipped %s" % (k, n[k].get("tests"), n[k].get("failures"), n[k].get("errors"), n[k].get("skipped")))
PY
  echo "  web tests before (unit 19's values block): $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit19/README.md | $G -oE 'web=[0-9]+' | head -1 | cut -d= -f2) · ConditionalGetTest's @Test lines $($G -cE '^ +@Test$' after/$CGT)"
  local nps; nps=$(sed -E 's/"[^"]*"/""/g' after/$CGT | $G -cE 'RANDOM_PORT|DEFINED_PORT|LocalServerPort|Socket|[^0-9.][0-9]{4,5}[^0-9.]' || true)
  echo "  ConditionalGetTest: disabling or conditional annotations $($G -cE '@(org\.junit\.jupiter\.api\.(condition\.)?)?(Disabled|EnabledIf|DisabledIf|EnabledOn|DisabledOn|EnabledFor|DisabledFor)' after/$CGT || true) · ports or sockets (string literals removed) $nps · its printed lines in the build: $($G -cE '^ConditionalGetTest: ' .harness/pkg.log)"
  $G -E '^ConditionalGetTest: ' .harness/pkg.log | sed 's/^/  package | /'
  echo "  refusal lines of the limiter in the build log (the suite at the default; RateLimitFilterTest's own context refuses by design): outside RateLimitFilterTest $(awk '/\[INFO\] Running com\./ { c = $NF } /rate limit: refused/ && c !~ /RateLimitFilterTest/ { n++ } END { print n + 0 }' .harness/pkg.log)"
  echo "  test files moved before -> after: $(for p in $(cd before && find tiffinbox-web/src/test -type f | sort); do cmp -s before/$p after/$p || basename $p; done | paste -sd, -) · new: $(cd after && for p in $(find tiffinbox-web/src/test -type f | sort); do [ -e ../before/$p ] || basename $p; done | paste -sd, -)"
  echo "  the test classes that send /api/v1/customers/ (grep -l): $( (cd after && $G -rl '/api/v1/customers/' tiffinbox-web/src/test/java) | sed 's#.*/##; s#\.java$##' | sort | paste -sd, -) · the ITs among them: $( (cd after && $G -rl '/api/v1/' tiffinbox-web/src/test/java 2> /dev/null) | $G -c 'IT\.java$' || true)"
  echo "  the slice (TiffinBoxWebTest, @WebMvcTest): byte-equal to before's: $(cmp -s before/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java after/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java && echo yes || echo no) · slice/WebSlice.java byte-equal: $(cmp -s before/tiffinbox-web/src/test/java/slice/WebSlice.java after/tiffinbox-web/src/test/java/slice/WebSlice.java && echo yes || echo no) · TiffinBoxWebTest green unedited: $(python3 -I -c 'import sys,xml.etree.ElementTree as E; r=E.parse(sys.argv[1]).getroot(); print("yes" if r.get("failures")=="0" and r.get("errors")=="0" else "no")' .harness/pkg/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.TiffinBoxWebTest.xml)"
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
  echo "  downloads across the builds: $(cat .harness/pkg.log .harness/verify.log .harness/webonly.log .harness/build-after.log .harness/build-before.log .harness/deptree.log 2> /dev/null | $G -cE 'Download(ing|ed) from ' || true)"
  echo "  BOOT-INF/lib: before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ') · added $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c '^>' || true) · removed $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c '^<' || true) · the core jar's md5 before -> after: $(cmp -s .harness/before/$XD/lib/tiffinbox-core-1.0.0.jar .harness/after/$XD/lib/tiffinbox-core-1.0.0.jar && echo equal || echo moved)"; }
c_harness() {
  echo "== harness: the folder's files and the instruments (copied byte-equal, adapted with a named diff, new)"
  echo "  harness/: $(ls harness | paste -sd' ' -) · harness/src: $(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -) · exercise/: $(ls exercise | paste -sd' ' -)"
  echo "  copied | dur9.py md5 $(md5 -q harness/dur9.py) · ops9s3.py md5 $(md5 -q harness/ops9s3.py) (unit 19's) · Http.java $(md5 -q harness/src/probe/Http.java) · Witness.java $(md5 -q harness/src/probe/Witness.java) (U12's) · cdp.mjs $(md5 -q harness/cdp.mjs) · cdp9.mjs $(md5 -q harness/cdp9.mjs) · seal9.py $(md5 -q harness/seal9.py) (U08's and U11's)"
  echo "  adapted | tree20.py from tree19.py: $(diff ../c9-unit19/harness/tree19.py harness/tree20.py | $G -c '^[<>]') lines (the docstring only) · s920.py from s919.py: lines removed $(diff ../c9-unit19/harness/s919.py harness/s920.py | $G -c '^<'), added $(diff ../c9-unit19/harness/s919.py harness/s920.py | $G -c '^>'), the diff's md5 $(diff ../c9-unit19/harness/s919.py harness/s920.py | md5 -q) · Etag.java from U12's: $(diff ../c9-unit12/harness/src/probe/Etag.java harness/src/probe/Etag.java | $G -c '^[<>]') lines, the diff's md5 $ETD"
  echo "  new | chk20.py md5 $(md5 -q harness/chk20.py) · chrome20.py $(md5 -q harness/chrome20.py) · exercise: break.sh $(md5 -q exercise/break.sh) · apply.sh $(md5 -q exercise/apply.sh) · check.sh $(md5 -q exercise/check.sh)"
  echo "  not used (absent from harness/): loc9.py presign/ Routes.java - $(for f in loc9.py presign src/probe/Routes.java; do [ -e harness/$f ] && echo $f; done | wc -l | tr -d ' ') present"
  echo "  static (i), as written: output md5 $STMD5"
  local SC=.harness/static-copy; rm -rf $SC; mkdir -p $SC; cp -R after $SC/after; ln -s "$U/before" $SC/before; printf 'x' >> $SC/after/compose.yaml
  echo "  static on a scratch copy with a byte appended to after/compose.yaml (a path this unit did not change; the frozen tree untouched): $(python3 -I -B harness/chk20.py static $SC/after $SC/before > $J/st2.txt 2>&1; echo "exit $?") · a FAIL names it: $($G -c '^FAIL' $J/st2.txt || true)"
  echo "  static plants (flag 31): a static assertion reading the live anchor (its folder name assembled) -> $(python3 -I -B harness/chk20.py static-plant live > /dev/null 2>&1; echo "exit $?") · the same path from two pieces -> $(python3 -I -B harness/chk20.py static-plant pieces > /dev/null 2>&1; echo "exit $?")"; }
exrun() { local v=$1 sh=$2 o cmd
  guard "the exercise, $v, $sh"
  rm -rf .harness/exercise/tree; copy after .harness/exercise/tree
  case $v in broken) cmd='sh break.sh "$0" > /dev/null && sh check.sh "$0"' ;; solved) cmd='sh break.sh "$0" > /dev/null && sh apply.sh "$0" > /dev/null && sh check.sh "$0"' ;; *) cmd="sh break.sh \"\$0\" > /dev/null && HOW=$v sh apply.sh \"\$0\" > /dev/null && sh check.sh \"\$0\"" ;; esac
  if [ $sh = bash ]; then o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21098 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock bash -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1)
  else o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21098 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock /bin/zsh -f -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1); fi
  local pre="  $v $sh |"; [ $v = broken ] || [ $v = solved ] || pre="  ~ $v $sh |"
  printf '%s\n' "$o" | sed -E "s/127\.0\.0\.1:21098/127.0.0.1:<port>/g; s/^/$pre /"
  [ ! -f exercise/check.build.log ] || offl exercise/check.build.log
  [ "$(listeners 21098)" = 0 ] || die "the exercise left something listening on 21098"; }
c_exercise() { local v sh
  rm -rf .harness/exercise; mkdir -p .harness/exercise
  for v in broken solved; do for sh in bash zsh; do echo "  == $v, $sh"; exrun $v $sh; done; done
  if [ "$RUNNO" = 1 ] || [ "$RUNNO" = 0 ]; then for v in mergeonly required fixedelsewhere; do exrun $v bash; done; fi
  rm -rf exercise/check.run; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.h
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures${DEVCAPS:+ (DEVELOPMENT: only $DEVCAPS - not a run of record)}"
cap advisory c_advisory
cap before c_before
cap change c_change
cap census c_census
NEEDPG=1; [ -n "${DEVCAPS:-}" ] && ! echo " $DEVCAPS " | $G -qE ' (shallow|deep|ifmatch) ' && NEEDPG=""
[ -z "$NEEDPG" ] || pgup
cap shallow c_shallow
cap paths c_paths
cap weak c_weak
cap deep c_deep
cap ifmatch c_ifmatch
[ -z "$NEEDPG" ] || pgdown
cap cache c_cache
cap chrome c_chrome
cap metrics c_metrics
cap spec c_spec
cap moved c_moved
cap api c_api
cap seven c_seven
cap surface c_surface
cap moving c_moving
cap tests c_tests
cap harness c_harness
cap exercise c_exercise
cap inert c_inert
echo "== plants (each made to FAIL first on a copy of this run's capture; harness/chk20.py plants)"
if [ -z "${DEVCAPS:-}" ]; then
PL=$(python3 -I -B harness/chk20.py plants .) || die "a plant was not caught: $(printf '%s\n' "$PL" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$PL" | $G '^ok ' | sed 's/^ok /  /'
PLV=$(printf '%s\n' "$PL" | sed -n 's/^VALUES //p')
fi

# ---- the end: the sweep, the values, the published hashes -------------------------------------------------------------------------------
[ -z "$(echo $PIDS)" ] || die "a JVM of this run is still running: $PIDS"
[ -z "$CPID" ] || die "a Chrome of this run is still running: $CPID"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
[ -z "$(dk ps -aq --filter label=org.testcontainers=true)" ] || die "a Testcontainers container of this run is left"
[ -z "$(dk ps -aq --filter name=^/c9u20-)" ] || die "a c9u20-* container is left"
NI1=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI1" = "$NI0" ] && [ "$VOL1" = "$VOL0" ] || die "R.322: images $NI0 -> $NI1, volumes $VOL0 -> $VOL1"
CHR1=$(pgrep -x 'Google Chrome' | wc -l | tr -d ' ')
AD1=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true); [ "$AD1" = "$AD" ] || die "the anchor moved during the run"
pin before-tree before; pin after-tree after
MDB=$(find . ../c9-tiffinbox ../c9-unit19 -name '*.mv.db' -not -path './.harness/*' -not -path '../c9-unit19/.harness/*' 2> /dev/null | wc -l | tr -d ' ')
[ "$MDB" = 0 ] || die "an H2 file outside .harness/"
[ -z "$(ls exercise | $G -v -xE 'README.md|SOLUTION.md|apply.sh|break.sh|check.sh')" ] || die "the exercise left a file in exercise/"
VALS="$VALS
plants: $PLV
build: seed_files=$NF0 seed_bytes=$NB0 central_only=$CO"
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
[ -n "${DEVCAPS:-}" ] && { echo "c9-unit20: DEVELOPMENT run ($DEVCAPS) - nothing published"; exit 2; }
VO=$(python3 -I -B harness/chk20.py values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; [ -n "${NOPIN:-}" ] || die "README.md's values block is not this run's"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM and no Chrome of this run, ports free, no container left, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1, the author's Chrome $CHR0 -> $CHR1 (never touched) · the anchor against after/ as at the start · the tree pins · *.mv.db outside .harness 0"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit20: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit20: $NCAPS captures checked; every capture = published ($NCAPS)"
