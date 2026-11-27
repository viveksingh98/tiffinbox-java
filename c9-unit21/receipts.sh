#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 21 "Timeouts and Retries From the Caller's Side" - this unit's receipts. Course 9's SEVENTEENTH anchor change, Section
# 4's third: before is a link to ../c9-unit20/after (U20's after); after/ is a frozen copy of ../c9-tiffinbox after this unit's change -
# tiffinbox-client/src/test gains Payments (a hand-written @HttpExchange interface: Course 6's payments shape plus ONE Idempotency-Key
# header parameter), PaymentCaller (@Retryable, the key a parameter, its nested Checkout minting one key per payment) and PaymentRetryTest
# (MockRestServiceServer, no socket); the anchor's README card. No src/main file, no pom, no route, no spec byte.
# The harness's things, labelled on every capture that uses one: Course 6's stub (harness/stub, byte for byte), the harness's caller JVM
# (harness/src/probe21/Caller21.java, compiled with the SHIPPED Payments.java and PaymentCaller.java on the client module's test class
# path), the harness's HttpClient 5 class path (that path + httpclient5 5.6.5, httpcore5 5.4.4, httpcore5-h2 5.4.4), the wide-includes
# copy and the key-per-attempt copy of PaymentCaller, the Resilience4j class paths (harness/src/r4, the S4 probe's R4.java and R4Core.java).
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5; lines starting "  ~" are run-variant and
# left out of the hash - the exercise's refused variants of run 1, the clients' version strings):
#   advisory  the S9.36 read filed for this section (ADV4), verified, before any build
#   before    before's client module: its test class path, its one test, the builder's factory; before's counters
#   change    the modules, the derived changed list, the new files whole, Course 6's interface beside, the test class path before/after
#   census    the controllers on before and after/ by unit 15's printed rule
#   factory   the harness's caller on the module's class path and on the harness's HttpClient 5 class path: the factory, the User-Agent
#   timeout   a raw RestClient from the module's builder on the stub's slow path: no read timeout, 1 s, and 1 s on HttpClient 5
#   retry     the shipped caller against the stub: one key x3, the key minted per attempt, a remote 404 narrow and wide, HttpClient 5
#   mock      PaymentRetryTest: Surefire's counts and its printed lines (MockRestServiceServer: no socket)
#   resilience4j  the core Retry and the Boot 4 starter, with and without Micrometer - a harness class path only
#   spec      the committed spec against the served document (after/, 21100): unchanged
#   moved     the web jar's, the core jar's and the client main jar's entries before -> after; BOOT-INF/lib by name
#   api       every GET of the committed spec's /api/v1/ paths on before (21106) and after/ (21100) - not a witness for the caller
#   seven     c5-unit11's seven · surface: the old surface by count - not witnesses for the caller
#   tests     package, the Docker-free twin, verify (the five ITs), the client-only form, the lib lists
#   harness   the folder's files, the copied and adapted instruments with their named diffs, the static check (three runs)
#   exercise  break.sh, check.sh, apply.sh against a stub on 21108, bash and zsh -f; the refused variants (run 1)
#   inert     the key header on every TiffinBox JVM's access log: none
#   title     the title for search
# Ports (U21's band, 21100-21109): 21100 after/ · 21105 Course 6's stub · 21106 before · 21108 the exercise's stub · 21101-21104, 21107,
# 21109 never bound. During mvn verify only: 21280-21284. The caller JVMs bind no port. Every store on 127.0.0.1; every curl --noproxy '*'.
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
H20=f73a7c3                                           # unit 20's commit: the static check reads its objects, never the live anchor
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
export DOCKER_HOST="$DH"
PIDS=""; INTR=""; mpid=""
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in $mpid $PIDS; do [ -z "$p" ] || killtree "$p"; done; for p in $mpid $PIDS; do if kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; for c in $(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null); do dk rm -fv "$c" > /dev/null 2>&1; done; rm -rf exercise/check.run; rm -f exercise/check.build.log; [ -z "$INTR" ] || rm -f .r-*.new; rmdir .r-lock 2> /dev/null || rm -rf .r-lock; true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git unzip javac javap /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|SPRINGDOC_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|AWS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit21 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · $(curl --version | head -1 | cut -d' ' -f1-2) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }') · run $RUNNO"

# ---- gates before anything is built: the folder, the link, the pins, the anchor note, the static check, the prose, the exercise --------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk21.py dur9.py ops9s3.py s921.py src stub tree21.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
HSRC='probe21/Caller21.java r4/R4.java r4/R4Core.java'
[ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$HSRC" ] || die "harness/src holds another file, or misses one"
[ "$(cd harness/stub && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "Stub.java www/customers.json www/meera.json www/priya.json www/ravi.json www/sunil.json" ] || die "harness/stub holds another file, or misses one"
for f in cdp.mjs cdp9.mjs seal9.py chrome20.py loc9.py presign src/probe/Etag.java src/probe/Witness.java src/probe/Http.java src/probe/Presign.java; do [ ! -e harness/$f ] || die "harness/$f: an instrument this unit does not carry (no browser, no witness)"; done
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md apply.sh break.sh check.sh' ] || die "exercise/ holds another file, or misses one"
[ -L before ] && [ "$(readlink before)" = ../c9-unit20/after ] || die "before must be a link whose text is exactly ../c9-unit20/after"
[ -d after ] && [ ! -L after ] || die "after/ is this unit's own frozen tree, a directory, not a link"
for t in before after; do [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-client/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/"; true; done
echo "  before -> $(readlink before) (a link, the text exact) · after/ a directory (the frozen copy) · no secrets/, target/ or .m2-demo/ in either · no browser instrument, no witness class (cdp*.mjs, seal9.py, chrome20.py, Etag/Http/Witness.java absent)"
STUBMD5=$(md5 -q harness/stub/Stub.java)
[ "$STUBMD5" = 42b656ddba1e9f80107495c65dacc975 ] && cmp -s harness/stub/Stub.java ../c6-unit26/harness/stub/Stub.java && cmp -s harness/stub/Stub.java ../c6-unit25/harness/stub/Stub.java || die "harness/stub/Stub.java is not Course 6's stub (c6-unit25's and c6-unit26's, 42b656dd)"
diff -rq harness/stub/www ../c6-unit26/harness/stub/www > /dev/null || die "harness/stub/www is not c6-unit26's"
for f in R4.java R4Core.java; do cmp -s harness/src/r4/$f "$PK4/instruments/probe-src/$f" || die "harness/src/r4/$f is not the S4 probe's copy"; done
[ "$(md5 -q "$BK4/instruments/BlueCaller.java")" = "$(awk '$2 == "./instruments/BlueCaller.java" { print $1 }' "$BK4/MD5SUMS")" ] || die "BLUE's BlueCaller.java is not its MD5SUMS line"
[ "$(md5 -q "$PK4/instruments/probe-src/Caller.java")" = "$(awk '$2 == "./instruments/probe-src/Caller.java" { print $1 }' "$PK4/MD5SUMS")" ] || die "the probe's Caller.java is not its MD5SUMS line"
CLD=$(diff "$BK4/instruments/BlueCaller.java" harness/src/probe21/Caller21.java | md5 -q); CLP=$(diff "$PK4/instruments/probe-src/Caller.java" harness/src/probe21/Caller21.java | md5 -q)
echo "  instruments: Stub.java $STUBMD5 = c6-unit25's = c6-unit26's (www/ too) · R4.java, R4Core.java = the S4 probe's · Caller21.java adapted from BLUE's BlueCaller.java ($(md5 -q "$BK4/instruments/BlueCaller.java" | cut -c1-8), the named diff's md5 $CLD) and the probe's Caller.java ($(md5 -q "$PK4/instruments/probe-src/Caller.java" | cut -c1-8), $CLP)"
[ "$(md5 -q harness/ops9s3.py)" = "$(md5 -q ../c9-unit20/harness/ops9s3.py)" ] || die "harness/ops9s3.py is not unit 20's copy, byte for byte"
[ "$(sed -n '5,$p' harness/tree21.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit20/harness/tree20.py | md5 -q)" ] || die "harness/tree21.py's code is not tree20.py's"
for u in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20; do [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit$u/harness/dur9.py)" ] || die "harness/dur9.py is not ../c9-unit$u's copy"; done
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; J6="$HOME/Desktop/PromptVidya-Automation/java6_series.py"; J4="$HOME/Desktop/PromptVidya-Automation/java4_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"
  [ ! -f "$C9R/_builders/dur9.py" ] || [ "$(md5 -q "$C9R/_builders/dur9.py")" = "$D9" ] || die "harness/dur9.py is not C9/_builders/dur9.py"
  AL9=$(python3 -I -c 'import re,sys; t=open(sys.argv[1]).read(); m=re.search(r"^ALLOW\s*=\s*(\{[^}]*\})", t, re.M); print(re.sub(r"\s+", "", m.group(1)) if m else "absent")' "$C9R/_builders/dur9_allow.py" 2> /dev/null || echo absent)
  TT=$(python3 -I -c '
import re,sys; t=open(sys.argv[1]).read().split("TITLES",1)[1]; s6=open(sys.argv[2]).read(); s4=open(sys.argv[3]).read()
for k in ("01","04","10","21","25"):
    m=re.search(r"\"%s\": *\"([^\"]+)\"" % k, t); print("c9u%s=%s" % (k, m.group(1) if m else ""))
for n in ("RestClient", "HTTP Interface Clients: @HttpExchange", "Spring Boot RestClient: Timeouts and Status Handlers"): print("c6=%s" % (n if ("\"%s\"" % n) in s6 else ""))
print("c4=%s" % ("Core Resilience Annotations in Framework 7" if "Core Resilience Annotations in Framework 7" in s4 else ""))' "$J9" "$J6" "$J4" | paste -sd'|' -)
  echo "  the titles, read off the registries (the call-backs, by title only, R.224): $TT"
else D9N="(the registry is not on this machine: U01-U20's copies are the pin)"; TT=""; AL9="(not read)"; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit01-20's copies $D9N · C9/_builders/dur9_allow.py ALLOW = $AL9 (read, never edited) · tree21.py's code = tree20.py's · ops9s3.py = unit 20's (md5 $(md5 -q harness/ops9s3.py))"
S20=$(md5 -q ../c9-unit20/harness/s920.py); [ "$S20" = 1e5a022eaa7f05adbcf8a9d95e59fe3d ] || die "U20's s920.py is not 1e5a022e"
[ ! -f "$C9R/_builders/s920.py" ] || cmp -s ../c9-unit20/harness/s920.py "$C9R/_builders/s920.py" || die "U20's s920.py is not C9/_builders/s920.py"
NS=$(diff ../c9-unit20/harness/s920.py harness/s921.py | $G -c '^<' || true)
echo "  s921.py: U20's s920.py (1e5a022e) with XU21C9 added - lines of s920.py's not in s921.py: $NS · lines added $(diff ../c9-unit20/harness/s920.py harness/s921.py | $G -c '^>') · the diff's md5 $(diff ../c9-unit20/harness/s920.py harness/s921.py | md5 -q)"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit20/receipts.md5)
[ "$UA" = "124 43ec1112e477b11aca28868e11e2c8c3" ] || die "../c9-unit20/receipts.md5's after-tree line is not 124 43ec1112 ($UA)"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree21.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || { [ -n "${NOPIN:-}" ] && { echo "  $dir/: $got (NOPIN: no pin yet)"; return 0; }; die "receipts.md5 has no $nm line"; }
  [ "$nm" = after-tree ] || [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit20/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree21.py $dir/ -> $got = receipts.md5's $nm line$( [ "$nm" = before-tree ] && echo " = ../c9-unit20/receipts.md5's after-tree line")"; }
pin before-tree before; pin after-tree after
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true)
echo "  after/ against the live anchor (the start note): $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures its own frozen after/' )"
HF="harness/chk21.py harness/s921.py harness/tree21.py harness/dur9.py harness/ops9s3.py harness/src/probe21/Caller21.java harness/src/r4/R4.java harness/src/r4/R4Core.java harness/stub/Stub.java exercise/check.sh exercise/apply.sh exercise/break.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's scripts: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
ST=$(python3 -I -B harness/chk21.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
STMD5=$(printf '%s\n' "$ST" | md5 -q)
echo "  static (harness/chk21.py static after before; reads after/, before and git show $H20:… only - flag 18): $(printf '%s\n' "$ST" | $G -c '^ok ') checks, FAIL 0 · its output md5 $STMD5"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s921.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U19 [0-9]+ families · U20 [0-9]+ families · U21 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s921, per sentence): /'
PH=$($G -rnE 'PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b|<measure>' README.md exercise 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
GL=$(python3 -I -B harness/chk21.py gloss README.md) || die "the gloss: $(printf '%s\n' "$GL" | $G '^FAIL' | head -3 | paste -sd';' -)"
echo "  the gloss: $(printf '%s\n' "$GL" | $G -c '^ok ') checks, FAIL 0 (none new: S4B's \"21 none new\")"
HOOK=$(python3 -I -B harness/chk21.py hook) || die "the hook could not be extracted"; EXQ=$(python3 -I -B harness/chk21.py exq) || die "the exercise line could not be extracted"
IL=$(python3 -I -B harness/chk21.py interleaved) || die "the brief's interleaved hooks and exercises: $IL"
echo "  $IL"
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S4B's Unit 21 Hook line), byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
HW=$(printf '%s\n' "$HOOK" | wc -w | tr -d ' '); EW=$(printf '%s\n' "${EXQ#Your turn: }" | wc -w | tr -d ' ')
HSW=$(printf '%s\n' "$HOOK" | python3 -I -c 'import re,sys; print(max(len(s.split()) for s in re.split(r"(?<=[.!?:])\s+", sys.stdin.read().strip()) if s))')
[ "$EW" -le 25 ] && [ "$HSW" -le 25 ] || die "a spoken line over 25 words (exercise $EW, the hook's longest sentence $HSW)"
echo "  the hook ($HW words, its longest sentence $HSW <= 25) and the exercise's line ($EW words after 'Your turn:'), byte for byte; both extracted from S4B's Unit 21 (md5 $(md5 -q "$S4B"))"
printf '%s\n\n%s\n' "$HOOK" "$EXQ" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s921.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
SWR=$(printf '%s\n' "$SW" | $G ' line ' | sed 's#.*spoken.md ##' | sort -u | paste -sd';' -)
echo "  the hook and the exercise's line through s921.py: $(printf '%s\n' "$SW" | tail -1 | sed 's/.* refused: /refused /')$( [ -n "$SWR" ] && echo " - $SWR (handed to RED: the hook is the brief's, never edited)")"; rm -f .r-lock/spoken.md
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
! $G -qE '(^|[^A-Za-z0-9_.-])path=|[$][{]?path([^A-Za-z0-9_]|$)' exercise/check.sh exercise/apply.sh exercise/break.sh || die "an exercise script names a variable path (zsh): rpath"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh exercise/check.sh exercise/apply.sh exercise/break.sh | $G -qwE "$K1|$K2" || die "a script names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket"
DRL=$($G -v '^ *#' receipts.sh | $G -F 'dk run ' | $G -vF -- '--pull never' | $G -vF '$G -F' | wc -l | tr -d ' ')
[ "$DRL" = 0 ] || die "a dk run line without --pull never"
MVL=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -F '$MV ')
MVA=$(printf '%s\n' "$MVL" | $G -vF -- '-pl tiffinbox-web -am' | $G -vF -- '-pl tiffinbox-client -am' | $G -cF -- '-pl ' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh with a -pl form other than '-pl tiffinbox-web -am' or '-pl tiffinbox-client -am'"
MVS=$(printf '%s\n%s\n' "$MVL" "$($G -F 'mvn ' exercise/check.sh)" | $G -cE -- ' -s | --settings ' || true); [ "$MVS" = 0 ] || die "RED4 #27: a Maven line with -s (the central-only settings fail offline)"
LA=$($G -nF 'c9-tiffinbox' receipts.sh exercise/check.sh exercise/apply.sh exercise/break.sh harness/tree21.py harness/chk21.py harness/src/probe21/Caller21.java | $G -v ':[0-9]*: *#' | $G -vF 'AD=$(diff -rq' | $G -vF 'AD1=$(diff -rq' | $G -vF 'MDB=$(find' | $G -vF "\$G -nF 'c9-tiffinbox'" | $G -vF 'LIVE_ANCHOR_PLANT' | wc -l | tr -d ' ')
[ "$LA" = 0 ] || die "flag 18: a line of the receipts, the exercise or the harness reads the live anchor outside the start note, the end check and the H2-file sweep"
echo "  static: no kill by name; every docker call on the pinned socket; R.391's Maven forms only, no -s; the live anchor read only by the start note, the end check and the H2-file sweep (flag 18)"
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
    gsub(/127\.0\.0\.1:21[01][0-9][0-9]/, "127.0.0.1:<port>")
    gsub(/\/slow\?ms=[0-9]+/, "/slow?ms=<ms>")
    gsub(/read-timeout=[0-9]+[a-z]*/, "read-timeout=<set>"); gsub(/read-timeout = [0-9]+[a-z]*/, "read-timeout = <set>")
    gsub(/Java-http-client\/[0-9.]+/, "Java-http-client/<jdk>"); gsub(/\(Java\/[0-9.]+\)/, "(Java/<jdk>)")
    gsub(/\$\$SpringCGLIB\$\$[0-9]+/, "$$SpringCGLIB$$N")
    gsub(/[A-Z][a-z][a-z], [0-9][0-9] [A-Z][a-z][a-z] [0-9][0-9][0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9] GMT/, "<date>")
    gsub(/refill period [0-9]+[smh]/, "refill period <period>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'took 812 ms' '"timestamp":"2026-11-01T08:09:00.123Z"' "$U/x $HOME/y" 'GET http://127.0.0.1:21105/slow?ms=3000 · read-timeout = 1s · read-timeout=1s' 'Java-http-client/25.0.4.1 · Apache-HttpClient/5.6.5 (Java/25.0.4.1) · PaymentCaller$$SpringCGLIB$$0' 'key 62cd547a-8da7-4f2c-ac9b-e4db970ce097 · Date: Fri, 27 Nov 2026 10:00:00 GMT' 'rate limit: capacity 1000 per refill period 1m, the' | mask)
[ "$(printf '%s\n' "$MP" | paste -sd'|' -)" = 'Started TiffinBoxServer in <t> (process running for <t>)|took <t>|"timestamp":"<time>"|…/x ~/y|GET http://127.0.0.1:<port>/slow?ms=<ms> · read-timeout = <set> · read-timeout=<set>|Java-http-client/<jdk> · Apache-HttpClient/5.6.5 (Java/<jdk>) · PaymentCaller$$SpringCGLIB$$N|key <uuid> · Date: <date>|rate limit: capacity 1000 per refill period <period>, the' ] || die "the mask's self-test: $(printf '%s\n' "$MP" | paste -sd'|' -)"
echo "  masks: the log mask masked a Started line's times, a millisecond count, a timestamp, the folders, the home, a band port, the stub's ms= and the read-timeout's value, the JDK's build in a User-Agent, the proxy class's number, a key (a uuid), an HTTP date, the period in the start's line (self-test)"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh); [ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SURF=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh); [ ${#U4SURF} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh (SURF=)"
U20V=$(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit20/README.md | $G -E '^(seven|surface): ' | $G -oE '(seven|surface)=[0-9a-f]{8}' | paste -sd' ' -)
[ "$U20V" = "seven=$(echo $S466 | cut -c1-8) surface=$(echo $U4SURF | cut -c1-8)" ] || die "U20's README values block ($U20V) is not the seven and the surface read off the receipts"
echo "  the seven: expected $S466 (../c7-unit31/receipts.sh's S466= line) · the old surface: expected $U4SURF (../c9-unit04/receipts.sh's SURF= line) · both = U20's values block ($U20V)"
echo "  the probe's caller captures (PK4/captures/h43, read, not copied: the expectation on the probe's class, 1 run): $(ls "$PK4/captures/h43" | wc -l | tr -d ' ') files, md5 of their md5s $(cd "$PK4/captures/h43" && md5 -q * | md5 -q) · BLUE B1 (BK4/out/k1-k3/K.txt, 3/3 on BlueCaller's Map/String stand-in): $(for k in k1 k2 k3; do md5 -q "$BK4/out/$k/K.txt" | cut -c1-8; done | paste -sd' ' -)"

# ---- docker, ports, the guard: the baselines ----------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run"
[ -z "$(dk ps -aq --filter name=^/c9u21- 2> /dev/null)" ] || die "a c9u21-* container exists before the run"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
BAND="21100 21101 21102 21103 21104 21105 21106 21107 21108 21109"
PORTS="18425 18881 18882 18883 18884 20578 20615 $BAND 21110 21111 21112 21113 21114 21115 21116 21117 21118 21280 21281 21282 21283 21284"
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
  echo "  guard before $1: no other receipt · load1 $l1 (< 20)$( [ $w = 0 ] || echo " after $w checks at or above 20 (waited, never killed)") · the band free" >&3; }
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · nothing pulled · no Testcontainers or c9u21-* container · ports free (21101-21104, 21107, 21109 and 21110-21118 included, never bound)"

# ---- the trees, copied and built offline: before (through the link), after/; the harness's class paths ---------------------------------
M2="$PWD/.m2-demo"
if [ ! -d "$M2" ]; then [ -d "$SEED" ] || die "the seed $SEED is missing"; cp -cR "$SEED" "$M2" 2> /dev/null || cp -R "$SEED" "$M2" || die "the seed could not be copied"; fi
NF0=$(find "$M2" -type f | wc -l | tr -d ' '); NB0=$(find "$M2" -type f -print0 | xargs -0 stat -f %z | awk '{ s += $1 } END { printf "%d", s }')
CO=$(find "$M2" -name _remote.repositories -print0 | xargs -0 $G -l 'central-only' 2> /dev/null | wc -l | tr -d ' ')
[ "$CO" = 0 ] || die "$CO _remote.repositories files in the seed copy still name central-only"
ART="org/springframework/boot/spring-boot-starter-parent/4.1.3 org/springframework/spring-context/7.0.11 org/springframework/boot/spring-boot-restclient/4.1.3 org/springframework/boot/spring-boot-restclient-test/4.1.3 org/apache/httpcomponents/client5/httpclient5/5.6.5 org/apache/httpcomponents/core5/httpcore5/5.4.4 org/apache/httpcomponents/core5/httpcore5-h2/5.4.4 io/github/resilience4j/resilience4j-spring-boot4/2.4.0 io/github/resilience4j/resilience4j-retry/2.4.0 io/micrometer/micrometer-core/1.17.3"
for a in $ART; do [ -n "$(ls "$M2/$a" 2> /dev/null | $G -E '\.(jar|pom)$')" ] || die ".m2-demo holds no $a (no seed act here: report the coordinates)"; done
echo "  .m2-demo (a copy of the seed m2-seed-c9-s4): files $NF0 · bytes $NB0 · _remote.repositories naming central-only: $CO"
for a in $ART; do echo "  seed | $a | $(ls "$M2/$a" | $G -E '\.(jar|pom)$' | paste -sd' ' -)"; done
mkdir -p .harness; for d in before after pkg tests clientonly exercise run work hc cp stubs static-copy iii wide broken r4; do rm -rf .harness/$d; done
mkdir -p .harness/home .harness/run .harness/work .harness/hc .harness/cp .harness/stubs
printf '%s\n' 'checks.disable=true' > .harness/home/.testcontainers.properties
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy before .harness/before; copy after .harness/after
JL=(-Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8)
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE 'Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" HOME=\"$U/.harness/home\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 900; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
AL="-DargLine=-Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Duser.home=../../home"
extract() { bg "cd .harness/$1 && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$1.log
  [ "$RE" = 0 ] || die ".harness/$1: the jar's extract failed"; }
guard "the build of before"
bg "cd .harness/before && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package -pl tiffinbox-client -am" .harness/build-before-client.log
[ "$RE" = 0 ] || { tail -30 .harness/build-before-client.log | mask >&3; die ".harness/before's client did not build offline (exit $RE)"; }; offl .harness/build-before-client.log
bg "cd .harness/before && $MV -DskipTests package -pl tiffinbox-web -am" .harness/build-before.log
[ "$RE" = 0 ] || { tail -30 .harness/build-before.log | mask >&3; die ".harness/before did not build offline (exit $RE)"; }; offl .harness/build-before.log
echo "  built before offline (mvn -o clean package -pl tiffinbox-client -am, its tests on; then -DskipTests package -pl tiffinbox-web -am; exit 0, Downloading/Downloaded from: 0)"
guard "the build of after"
bg "cd .harness/after && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package" .harness/build-after.log
[ "$RE" = 0 ] || { tail -30 .harness/build-after.log | mask >&3; die ".harness/after did not build offline (exit $RE)"; }; offl .harness/build-after.log
echo "  built after/ offline WITH its tests, Docker-free (mvn -o clean package, the whole reactor: $($G -E '^\[INFO\] TiffinBox[A-Za-z ]* \.+ SUCCESS' .harness/build-after.log | sed -E 's/^\[INFO\] (TiffinBox[A-Za-z ]*) \.+ SUCCESS.*/\1/' | paste -sd, -); exit 0) - the jars come from this build; it is the tests capture's Docker-free twin"
extract before; extract after
for s in before after; do bg "cd .harness/$s && $MV dependency:build-classpath -pl tiffinbox-client -am -Dmdep.includeScope=test -Dmdep.outputFile=\"$U/.harness/cp/client-$s.txt\"" .harness/cp-$s.log
  [ "$RE" = 0 ] || die "the client module's test class path on $s could not be read offline"; offl .harness/cp-$s.log; done
CPM=$(cat .harness/cp/client-after.txt); CPB=$(cat .harness/cp/client-before.txt)
HC5="$M2/org/apache/httpcomponents/client5/httpclient5/5.6.5/httpclient5-5.6.5.jar:$M2/org/apache/httpcomponents/core5/httpcore5/5.4.4/httpcore5-5.4.4.jar:$M2/org/apache/httpcomponents/core5/httpcore5-h2/5.4.4/httpcore5-h2-5.4.4.jar"
CPH="$CPM:$HC5"
CT=tiffinbox-client/src/test/java/com/tiffinbox/client
hcomp() { local out=$1 cp=$2 src=$3; mkdir -p "$out"
  bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d \"$out\" -cp \"$cp\" \"$src/Payments.java\" \"$src/PaymentCaller.java\" harness/src/probe21/Caller21.java" .harness/javac-$(basename "$out").log
  [ "$RE" = 0 ] || die "the harness did not compile ($out): $(head -5 .harness/javac-$(basename "$out").log)"; }
hcomp .harness/hc/main "$CPM" .harness/after/$CT
hcomp .harness/hc/before "$CPB" .harness/after/$CT
mkdir -p .harness/wide .harness/broken; cp .harness/after/$CT/Payments.java .harness/after/$CT/PaymentCaller.java .harness/wide/; cp .harness/after/$CT/Payments.java .harness/after/$CT/PaymentCaller.java .harness/broken/
python3 -I - .harness/wide/PaymentCaller.java <<'PY' || die "the wide copy could not be made"
import sys
p = sys.argv[1]; s = open(p, encoding="utf-8").read()
old = "includes = {ResourceAccessException.class, HttpServerErrorException.class})"; new = "includes = org.springframework.web.client.RestClientException.class)"
assert s.count(old) == 1; open(p, "w", encoding="utf-8").write(s.replace(old, new, 1))
PY
python3 -I - .harness/broken/PaymentCaller.java <<'PY' || die "the key-per-attempt copy could not be made"
import sys
p = sys.argv[1]; s = open(p, encoding="utf-8").read()
old = "        return payments.pay(key, charge);\n"; new = "        return payments.pay(UUID.randomUUID().toString(), charge);   // a new key on every attempt\n"
assert s.count(old) == 1; open(p, "w", encoding="utf-8").write(s.replace(old, new, 1))
PY
hcomp .harness/hc/wide "$CPM" .harness/wide; hcomp .harness/hc/broken "$CPM" .harness/broken
echo "  the harness compiled (javac -nowarn -parameters) with the SHIPPED Payments.java and PaymentCaller.java on the client module's test class path (after/'s; before's for before's factory) · the wide copy (includes = RestClientException) and the key-per-attempt copy, each one printed python edit: $(diff .harness/after/$CT/PaymentCaller.java .harness/wide/PaymentCaller.java | $G -c '^>') and $(diff .harness/after/$CT/PaymentCaller.java .harness/broken/PaymentCaller.java | $G -c '^>') line(s)"
B() { echo "http://127.0.0.1:$1"; }
J=.harness/work
ALP='%m %U%q %s %b key=%{Idempotency-Key}i'
# tb LABEL PORT [args]: TiffinBox (the extracted jar of TREE=after unless TREE is set), from its own run folder with a generated token
# (0600, never printed), H2 in memory (fresh per JVM), waited for by its Started line; Tomcat's access log with the key header's value.
tb() { local label=$1 port=$2 t=${TREE:-after} run=.harness/run/$1 i=0; shift 2
  guard "TiffinBox $label"
  for q in 21101 21102 21103 21104 21107 21109; do [ "$(listeners $q)" = 0 ] && [ -z "$(lsof -nP -iUDP:$q 2> /dev/null)" ] || die "$q must stay free (TCP and UDP)"; done
  [ "$(listeners $port)" = 0 ] && [ -z "$(lsof -nP -iUDP:$port 2> /dev/null)" ] || die "$port is bound before $label"
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  local x="$U/.harness/$t/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  local ax=(--server.tomcat.accesslog.enabled=true "--server.tomcat.accesslog.directory=$U/$run" --server.tomcat.accesslog.prefix=access --server.tomcat.accesslog.suffix=.log --server.tomcat.accesslog.rotate=false --server.tomcat.accesslog.buffered=false "--server.tomcat.accesslog.pattern=$ALP")
  local main=com.tiffinbox.web.TiffinBoxServer
  echo "java -cp <tree $t> $main --tiffinbox.port=$port <the access log> $*" > "$run/cmd"
  (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java "${JL[@]}" -cp "$cp" $main --tiffinbox.port="$port" "${ax[@]}" "$@" > jvm.log 2>&1) &
  local p=$!; echo $p > "$run/pid"; PIDS="$PIDS $p"; MINE="${MINE:-} $port"
  while ! $G -q -E 'Started TiffinBox(App|Server) in' "$run/jvm.log" 2> /dev/null; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before its Started line"; }; i=$((i + 1)); [ $i -lt 1200 ] || die "$label: no Started line"; sleep 0.1; done
  SETL=$($G -F 'rate limit: capacity' "$run/jvm.log" | sed -E 's/^.*tiffinbox\.ratelimit +: //' | head -1)
  echo "  $label up on $port (H2, tree $t, harness-free, the access log on) · the setting read back by its start line: $SETL"; }
tbstop() { local label=$1 port=$2 run=.harness/run/$1 p i=0 how="POST /shutdown"; p=$(cat "$run/pid")
  if kill -0 "$p" 2> /dev/null; then printf 'X-Shutdown-Token: %s\n' "$(head -1 "$run/secrets/tiffinbox/shutdown-token")" | $CURL -s -o /dev/null --max-time 5 -H @- -X POST "$(B $port)/shutdown" || true; fi
  while kill -0 "$p" 2> /dev/null; do i=$((i + 1)); [ $i = 80 ] && { kill "$p" 2> /dev/null; how="its recorded pid (SIGTERM)"; }; [ $i -lt 400 ] || { kill -9 "$p" 2> /dev/null; break; }; sleep 0.05; done
  wait "$p" 2> /dev/null || true; PIDS=$(echo " $PIDS " | sed "s/ $p / /g"); MINE=$(echo " ${MINE:-} " | sed "s/ $port / /g")
  [ "$(listeners $port)" = 0 ] || die "$label: something still listens on $port"
  echo "  budget | $label: requests under /api/v1/ (its access log): $(cat $run/access*.log 2> /dev/null | $G -cE '^[A-Z]+ /api/v1/' || true) · refusal lines: $($G -c 'rate limit: refused' $run/jvm.log || true) · the setting: ${SETL:-none}"
  [ -z "${QUIET:-}" ] && echo "  $label stopped by $how"; true; }
# stub LABEL PORT: Course 6's stub from a fresh copy of harness/stub (never a path under the live anchor), its pid recorded; ready when it
# answers (a request for /ready, which it answers 404 - that request is in its dump and left out by the reader). stubstop LABEL.
stub() { local label=$1 port=$2 d=.harness/stubs/$1 i=0
  guard "the stub $label"
  [ "$(listeners $port)" = 0 ] || die "$port is bound before the stub $label"
  rm -rf "$d"; cp -R harness/stub "$d"; [ "$(md5 -q "$d/Stub.java")" = "$STUBMD5" ] || die "the stub copy is not Course 6's"
  (cd "$d" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 600; exec @ARGV' java "${JL[@]}" Stub.java --port=$port --www=www > dump.out 2>&1) &
  local p=$!; echo $p > "$d/pid"; PIDS="$PIDS $p"; MINE="${MINE:-} $port"; SPORT=$port; SLAB=$label
  until [ "$($CURL -s -o /dev/null -w '%{http_code}' --max-time 1 "$(B $port)/ready" 2> /dev/null)" = 404 ]; do kill -0 $p 2> /dev/null || die "the stub $label exited"; i=$((i + 1)); [ $i -lt 300 ] || die "the stub $label did not answer"; sleep 0.1; done; }
stubstop() { local d=.harness/stubs/$1 p; p=$(cat "$d/pid"); kill "$p" 2> /dev/null; wait "$p" 2> /dev/null || true
  PIDS=$(echo " $PIDS " | sed "s/ $p / /g"); MINE=$(echo " ${MINE:-} " | sed "s/ $SPORT / /g"); [ "$(listeners $SPORT)" = 0 ] || die "the stub $1: $SPORT still listens"; }
# caller LABEL CLASSDIR CLASSPATH [-Dprops...] -- [args]: the harness's caller JVM (binds no port), its PROBE21 lines; its pid recorded.
caller() { local label=$1 cd=$2 cp=$3 o=.harness/stubs/$SLAB/caller-$1.out; shift 3; local props=(); while [ $# -gt 0 ] && [ "$1" != -- ]; do props+=("$1"); shift; done; [ "${1:-}" = -- ] && shift
  guard "the caller $label"
  (exec perl -e '$SIG{INT}="DEFAULT"; alarm 300; exec @ARGV' java "${JL[@]}" -Dprobe21.stub="$(B $SPORT)" "${props[@]}" -cp "$cd:$cp" probe21.Caller21 "$@" > "$o" 2>&1) &
  local p=$!; PIDS="$PIDS $p"; wait $p; local e=$?; PIDS=$(echo " $PIDS " | sed "s/ $p / /g")
  $G -E '^PROBE21 ' "$o" | sed "s/^/  $label | /"; echo "  $label | caller exit $e"; }
# dump LABEL: the stub's dump read by python - each request (the readiness GET left out), the key's values per POST, the answers.
dump() { python3 -I - .harness/stubs/$1/dump.out "$1" <<'PY'
import sys, re
t = open(sys.argv[1], encoding="utf-8").read().splitlines(); lab = sys.argv[2]
reqs = []
for l in t:
    m = re.match(r"^STUB (\S+) (\S+) headers=\[(.*)\]$", l)
    if m: reqs.append({"m": m.group(1), "u": m.group(2), "h": m.group(3), "key": None, "ua": None, "ans": None}); continue
    if not reqs: continue
    m = re.match(r"^STUB-H idempotency-key: (.*)$", l)
    if m: reqs[-1]["key"] = m.group(1)
    m = re.match(r"^STUB-H user-agent: (.*)$", l)
    if m: reqs[-1]["ua"] = m.group(1)
    m = re.match(r"^STUB-ANSWER (\d+) ", l)
    if m: reqs[-1]["ans"] = m.group(1)
reqs = [r for r in reqs if r["u"] != "/ready"]
for r in reqs:
    print("  %s stub | %s %s -> %s · headers [%s] · user-agent %s%s" % (lab, r["m"], r["u"], r["ans"] or "no answer written", r["h"], r["ua"], " · idempotency-key %s" % r["key"] if r["key"] else ""))
posts = [r for r in reqs if r["m"] == "POST" and r["u"] == "/payments"]
keys = [r["key"] for r in posts]
print("  %s stub | POST /payments %d · with the key header %d · distinct keys %d · 201 answers %d · GET /payments/slow %d · GET /status/404 %d" % (lab, len(posts), sum(1 for k in keys if k), len(set(k for k in keys if k)), sum(1 for r in posts if r["ans"] == "201"), sum(1 for r in reqs if r["u"] == "/payments/slow"), sum(1 for r in reqs if r["u"] == "/status/404")))
PY
}
ANC="c9-""tiffinbox"   # the anchor folder's name, assembled: the frozen receipts' pom lines are counted for it (a read of THEIR text, not of the anchor)
NCAPS=0; unpub=""; VALS=""
cap() { local nm=$1; shift
  if [ -n "${DEVCAPS:-}" ] && ! echo " $DEVCAPS " | $G -qF " $nm "; then return 0; fi   # development only: a run of record sets no DEVCAPS
  "$@" > .harness/cap-$nm.raw 2>&1 || true
  $G -q '^  \*\*\* ' .harness/cap-$nm.raw && { cat .harness/cap-$nm.raw >&3; die "$nm stopped (above)"; }
  mask < .harness/cap-$nm.raw > .r-$nm.new
  sed 's/^/  | /' .r-$nm.new | cut -c1-260
  local o e=0; o=$(python3 -I -B harness/chk21.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk21 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; [ -n "${DEVCAPS:-}${NOPIN:-}" ] && { echo "  (development: $nm's check failed, the run goes on)"; unpub="$unpub $nm"; } || die "$nm: its check failed (harness/chk21.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk21.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
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
PY
}
classes() { python3 -I - "$1" "$2" <<'PY'
import sys, glob, xml.etree.ElementTree as E
for f in sorted(glob.glob(sys.argv[1] + "/TEST-*.xml")):
    r = E.parse(f).getroot(); print("  %s | class %s | tests %s failures %s errors %s skipped %s" % (sys.argv[2], r.get("name").split(".")[-1], r.get("tests"), r.get("failures"), r.get("errors"), r.get("skipped")))
PY
}
reactor() { $G -E '^\[INFO\] TiffinBox[A-Za-z ]* \.+ (SUCCESS|FAILURE|SKIPPED)' "$1" | sed -E 's/ \.+ / ... /; s/\[ *[0-9.:]+ (s|min)\]//; s/^\[INFO\] /  reactor: /; s/ *$//'; }

# ---- the captures ----------------------------------------------------------------------------------------------------------------------
c_advisory() {
  echo "== S9.36: the read filed for Section 4 (ADV4 = _research/docs-2026-11-27/advisories-s4probe, the S4 probe's dated act; not re-read: no network), before any capture"
  echo "  fetched-at $(head -1 "$ADV/fetched-at.txt" | cut -c1-10) (the hour masked) · run date $(date '+%Y-%m-%d') · the batch day's other read (advisories/) fetched-at $(head -1 "$ADV/../advisories/fetched-at.txt" | cut -c1-10)"
  local d n=0 v=0 f h; for d in "$ADV" "$ADV/../advisories"; do n=0; v=0; while read -r h f; do n=$((n + 1)); [ "$(md5 -q "$d/$f" 2> /dev/null)" = "$h" ] && v=$((v + 1)); done < <($G -vE '^\s*$' "$d/MD5SUMS.txt" | awk '$2 != "MD5SUMS.txt" { print $1, $2 }')
    echo "  $(basename "$d")/MD5SUMS.txt: $n lines, $v verified (its own line left out)"; done
  echo "  spring index: CVE ids on its first page $($G -oE 'CVE-[0-9]{4}-[0-9]+' "$ADV/spring-security-index.html" | sort -u | wc -l | tr -d ' ') · the dates on the page: $($G -oE '(January|February|March|April|May|June|July|August|September|October|November|December) [0-9]{1,2}, 2026' "$ADV/spring-security-index.html" | sort | uniq -c | sed -E 's/^ +//' | paste -sd'|' -)"
  echo "  tomcat page md5 $(md5 -q "$ADV/tomcat-security-11.html") (the 11-24, 11-26 and 11-27 00:51 reads: a1a756d985225fb5143eefd9aae3183c)"
  local a; for a in spring-boot spring-web spring-context tomcat-embed-core bucket4j_jdk17-core; do
    echo "  shipped | $a $(ls .harness/after/$XD/lib | $G -E "^$a-[0-9]" | sed -E "s/^$a-//; s/\.jar$//" | paste -sd, -)"; done
  python3 -I - "$ADV/osv-query.json" "$ADV/osv-result.json" <<'PY'
import json, sys
q = json.load(open(sys.argv[1]))["queries"]; r = json.load(open(sys.argv[2])).get("results", [])
print("  osv (second witness only, S2.8): %d coordinates queried, %d results, %d with vulns" % (len(q), len(r), sum(1 for x in r if x.get("vulns"))))
names = sorted(x.get("package", {}).get("name", "") + "@" + x.get("version", "") for x in q)
for k in ("httpclient5", "resilience4j", "micrometer-core"): print("  osv | queried coordinates naming %s: %s" % (k, ", ".join(n for n in names if k in n) or "none"))
PY
  echo "  harness-only (the seed, never the anchor) | httpclient5 5.6.5 · httpcore5 5.4.4 · httpcore5-h2 5.4.4 · resilience4j-spring-boot4 2.4.0 · resilience4j-retry 2.4.0 · micrometer-core 1.17.3 (each ls'd above)"
  echo "  lib names before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ') · by name: $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) > /dev/null && echo equal || echo DIFFER) · tiffinbox-client/pom.xml byte-equal: $(cmp -s before/tiffinbox-client/pom.xml after/tiffinbox-client/pom.xml && echo yes || echo no) (flag 1: no new artifact in the anchor)"
  echo "  verdict: no pin affected; evidence may proceed (the read is the batch day's: run date = fetched-at date); nothing else was read from the network"; }
c_before() {
  echo "== before (U20's after): the client module's test class path, its one test, the builder's factory; before's counters"
  echo "  before | the client's test class path (mvn -o dependency:build-classpath -pl tiffinbox-client -am -Dmdep.includeScope=test): $(tr ':' '\n' < .harness/cp/client-before.txt | $G -c . ) jars · httpclient5 $(tr ':' '\n' < .harness/cp/client-before.txt | $G -c 'httpclient5' || true) · $(tr ':' '\n' < .harness/cp/client-before.txt | sed 's#.*/##' | $G -E '^(spring-boot-restclient|spring-boot-restclient-test|spring-test|spring-context|spring-web)-[0-9]' | sort | paste -sd' ' -)"
  surefire .harness/before/tiffinbox-client/target/surefire-reports "before | tiffinbox-client"
  classes .harness/before/tiffinbox-client/target/surefire-reports "before"
  stub before-factory 21105
  caller before-factory .harness/hc/before "$CPB" -Dprobe21.mode=factory
  dump before-factory
  stubstop before-factory
  echo "  before | the committed spec: $(python3 -I harness/ops9s3.py ops before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tail -1) · $(wc -c < before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tr -d ' ') B md5 $(md5 -q before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json)"
  echo "  before | BOOT-INF/lib names $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · web tests and ITs (U20's values block): $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit20/README.md | $G -oE '(web|client|its)=[0-9]+' | paste -sd' ' -)"
  echo "  before | the web jar's httpclient5 in BOOT-INF/lib: $(ls .harness/before/$XD/lib | $G -E '^httpclient5-' | paste -sd' ' -) (the web module's class path, not the client's)"; }
c_change() {
  echo "== the modules, the change file by file"
  echo "  modules: $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' before/pom.xml | paste -sd' ' -) ($($G -c '<module>' before/pom.xml)) -> $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' after/pom.xml | paste -sd' ' -) ($($G -c '<module>' after/pom.xml))"
  echo "  changed (derived: diff -rq before after/, the frozen trees - git status --short gave the same list before the commit): $(diff -rq before/ after/ | sed -E 's#^Files before/(.*) and after/.* differ$#M \1#; s#^Only in after/(.*): (.*)$#A \1/\2#; s#^Only in after/: (.*)$#A \1#; s#^Only in before/(.*): (.*)$#D \1/\2#' | sort | paste -sd'~' - | sed 's/~/ · /g')"
  local f; for f in Payments.java PaymentCaller.java PaymentRetryTest.java; do echo "== $CT/$f (whole, md5 $(md5 -q after/$CT/$f))"; sed 's/^/    /' after/$CT/$f; done
  echo "== Course 6's interface (../c6-unit26/harness/probe/web/Payments.java :15-:29) beside this unit's - the one added parameter"
  sed -n '15,29p' ../c6-unit26/harness/probe/web/Payments.java | sed 's/^/    c6 | /'
  echo "  the POST's signature: Course 6 $($G -E '^ +Payment pay\(' ../c6-unit26/harness/probe/web/Payments.java | sed 's/^ *//') -> this unit $($G -E '^ +Payment pay\(' after/$CT/Payments.java | sed 's/^ *//')"
  echo "  the client's test class path before -> after (by name): $(tr ':' '\n' < .harness/cp/client-before.txt | sed 's#.*/##' | sort | md5 -q | cut -c1-12) -> $(tr ':' '\n' < .harness/cp/client-after.txt | sed 's#.*/##' | sort | md5 -q | cut -c1-12) · added $(diff <(tr ':' '\n' < .harness/cp/client-before.txt | sed 's#.*/##' | sort) <(tr ':' '\n' < .harness/cp/client-after.txt | sed 's#.*/##' | sort) | $G -c '^>' || true) · removed $(diff <(tr ':' '\n' < .harness/cp/client-before.txt | sed 's#.*/##' | sort) <(tr ':' '\n' < .harness/cp/client-after.txt | sed 's#.*/##' | sort) | $G -c '^<' || true)"
  echo "  greps over after/: files naming Idempotency-Key in tiffinbox-client $( (cd after && $G -rlF 'Idempotency-Key' tiffinbox-client) | wc -l | tr -d ' ') ($( (cd after && $G -rlF 'Idempotency-Key' tiffinbox-client) | sed 's#.*/##' | paste -sd, -)) · ClientHttpRequestInterceptor $( (cd after && $G -rlF 'ClientHttpRequestInterceptor' .) | wc -l | tr -d ' ') · resilience4j (any case) $( (cd after && $G -rli 'resilience4j' .) | wc -l | tr -d ' ') · @EnableResilientMethods in src/main $( (cd after && $G -rlF '@EnableResilientMethods' tiffinbox-*/src/main 2> /dev/null) | wc -l | tr -d ' ') · Probe/probe./BLUE in the new files $(cd after/$CT && $G -cE 'Probe|probe\.|BLUE|/probe/' Payments.java PaymentCaller.java PaymentRetryTest.java | awk -F: '{ s += $2 } END { print s + 0 }')"
  for f in pom.xml tiffinbox-web/pom.xml tiffinbox-core/pom.xml tiffinbox-client/pom.xml $CT/TiffinBoxClientTest.java tiffinbox-web/src/main/resources/application.yaml Dockerfile compose.yaml tiffinbox-web/src/test/resources/openapi/tiffinbox.json; do echo "  $f byte-equal to before's: $(cmp -s before/$f after/$f && echo yes || echo no)"; done
  echo "  src/main of every module byte-equal to before's: $(diff -rq before/tiffinbox-web/src/main after/tiffinbox-web/src/main > /dev/null && diff -rq before/tiffinbox-core/src/main after/tiffinbox-core/src/main > /dev/null && [ ! -e after/tiffinbox-client/src/main ] && echo yes || echo no) (tiffinbox-client has no src/main) · tiffinbox-web/ and tiffinbox-core/ byte-equal: $(diff -rq before/tiffinbox-web after/tiffinbox-web > /dev/null && diff -rq before/tiffinbox-core after/tiffinbox-core > /dev/null && echo yes || echo no)"
  python3 -I - .harness/before/tiffinbox-client/target/generated-sources/openapi .harness/after/tiffinbox-client/target/generated-sources/openapi <<'PY'
import os, re, sys, zlib
def crc(r):
    o = {}
    for d, ds, fs in os.walk(r):
        for f in fs: p = os.path.join(d, f); o[os.path.relpath(p, r)] = zlib.crc32(re.sub(rb'date = "[^"]*"', b'date = "<generated>"', open(p, "rb").read()))
    return o
a, b = crc(sys.argv[1]), crc(sys.argv[2])
j = [k for k in b if k.endswith(".java")]
print("  the generated client (after/'s build): %d files (.java %d) · added %d · removed %d · moved %d (CRC, before's build -> after's, the @Generated date masked)" % (len(b), len(j), len(set(b) - set(a)), len(set(a) - set(b)), sum(1 for k in a if k in b and a[k] != b[k])))
PY
  python3 -I - .harness/after/tiffinbox-client/target/generated-sources/openapi/src/main/java/com/tiffinbox/client/api/ApiApi.java <<'PY2'
import re, sys
t = open(sys.argv[1], encoding="utf-8").read(); m = re.search(r"\badd1\((.*?)\);", t, re.S)
ps = re.findall(r"\b(\w+) (\w+)\s*(?:,|$)", re.sub(r"@\w+\([^)]*\)", "", m.group(1)).strip()) if m else []
print("  ApiApi.add1's parameters (the generated source): %s · @RequestHeader in ApiApi: %d (the spec's Idempotency-Key named only in the Javadoc's problem lines: %d)" % (", ".join("%s %s" % x for x in ps), t.count("@RequestHeader"), t.count("Idempotency-Key")))
PY2
  echo "  mvn dependency:tree (the client module, -o, filtered):"
  bg "cd .harness/after && $MV dependency:tree -pl tiffinbox-client -am" .harness/deptree.log; offl .harness/deptree.log
  echo "    lines naming httpclient5 $($G -c 'httpclient5' .harness/deptree.log || true) · resilience4j $($G -ci 'resilience4j' .harness/deptree.log || true) · micrometer $($G -c 'micrometer' .harness/deptree.log || true)"
  $G -E 'spring-web:jar|spring-context:jar' .harness/deptree.log | sed -E 's/^\[INFO\] //; s/^[-+|\\ ]*//; s/^/    /' | sort -u; }
census() { python3 -I - "$1/tiffinbox-web/src/main/java/com/tiffinbox/web" "$2" <<'PY'
import os, re, sys
d, side = sys.argv[1], sys.argv[2]
print("  census %s | rule (unit 15's, copied off unit 20's receipts): a class whose annotation lines include exactly @RestController or @Controller; its final modifier; @Profile(\"dev\") among those lines" % side)
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
c_census() { echo "== the controllers on before and after/ (R.527: each derived on its own tree) - the caller is in tiffinbox-client's test scope, no controller"; census before before; census after after
  echo "  the spec's counts (ops9s3.py, each tree's own committed file): before $(python3 -I harness/ops9s3.py ops before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tail -1) · after $(python3 -I harness/ops9s3.py ops after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tail -1)"
  echo "  the generated client's files (after/'s build): $($G -c '\.java$' .harness/after/tiffinbox-client/target/generated-sources/openapi/.openapi-generator/FILES) · PATH_* (ops9s3.py paths): $(python3 -I harness/ops9s3.py paths .harness/after/tiffinbox-client/target/generated-sources/openapi 2>&1 | tail -1)"; }
c_factory() {
  echo "== factory: the harness's caller (Caller21, a Boot context with no web server; the module's builder) against Course 6's stub (21105, a fresh copy each) - one GET /status/200 each"
  stub factory-module 21105
  caller factory-module .harness/hc/main "$CPM" -Dprobe21.mode=factory
  dump factory-module; stubstop factory-module
  echo "  ~ factory-module | the JDK: $(java -version 2>&1 | head -1)"
  stub factory-hc5 21105
  caller factory-hc5 .harness/hc/main "$CPH" -Dprobe21.mode=factory
  dump factory-hc5; stubstop factory-hc5
  echo "  class paths | the module's: $(tr ':' '\n' < .harness/cp/client-after.txt | $G -c .) jars, httpclient5 $(tr ':' '\n' < .harness/cp/client-after.txt | $G -c httpclient5 || true) · the harness's HttpClient 5 class path: that + $(echo "$HC5" | tr ':' '\n' | sed 's#.*/##' | paste -sd' ' -) (labelled; the module's pom untouched) · the web jar's BOOT-INF/lib: $(ls .harness/after/$XD/lib | $G -E '^httpclient5-' | paste -sd' ' -) (the web module's, not the client's)"; }
c_timeout() {
  echo "== timeout: a raw RestClient from the module's builder (never the generated client, RED4 #1) on the stub's slow path (GET /slow?ms=3000 - the stub's own default delay, the harness's choice), each leg a fresh stub on 21105"
  stub timeout-none 21105
  caller timeout-none .harness/hc/main "$CPM" -Dprobe21.mode=timeout -Dprobe21.ms=3000
  dump timeout-none; stubstop timeout-none
  stub timeout-module 21105
  caller timeout-module .harness/hc/main "$CPM" -Dprobe21.mode=timeout -Dprobe21.ms=3000 -- --spring.http.clients.read-timeout=1s
  dump timeout-module; stubstop timeout-module
  stub timeout-hc5 21105
  caller timeout-hc5 .harness/hc/main "$CPH" -Dprobe21.mode=timeout -Dprobe21.ms=3000 -- --spring.http.clients.read-timeout=1s
  dump timeout-hc5; stubstop timeout-hc5; }
c_retry() {
  echo "== retry: the SHIPPED PaymentCaller (its Checkout mints one key per payment) against Course 6's stub (21105, a fresh stub per leg: its payment ids start at pay-1) - the stub honours no key"
  echo "  the harness's lost reply: a later call in the same method - the harness's Payments wrapper sends the POST, then GET /payments/slow, which the read-timeout run flag cuts; the POST's own 201 arrived"
  stub retry-onekey 21105
  caller retry-onekey .harness/hc/main "$CPM" -Dprobe21.mode=retry -Dprobe21.wrap=lossy -- --spring.http.clients.read-timeout=1s
  dump retry-onekey; stubstop retry-onekey
  stub retry-keyper 21105
  caller retry-keyper .harness/hc/broken "$CPM" -Dprobe21.mode=retry -Dprobe21.wrap=lossy -- --spring.http.clients.read-timeout=1s
  dump retry-keyper; stubstop retry-keyper
  stub retry-404narrow 21105
  caller retry-404narrow .harness/hc/main "$CPM" -Dprobe21.mode=retry -Dprobe21.wrap=missing
  dump retry-404narrow; stubstop retry-404narrow
  stub retry-404wide 21105
  caller retry-404wide .harness/hc/wide "$CPM" -Dprobe21.mode=retry -Dprobe21.wrap=missing
  dump retry-404wide; stubstop retry-404wide
  stub retry-hc5 21105
  caller retry-hc5 .harness/hc/main "$CPH" -Dprobe21.mode=retry -Dprobe21.wrap=lossy -- --spring.http.clients.read-timeout=1s
  dump retry-hc5; stubstop retry-hc5
  echo "  the copies: retry-keyper = the key-per-attempt copy (the exercise's broken state: $(diff .harness/after/$CT/PaymentCaller.java .harness/broken/PaymentCaller.java | $G '^>' | sed 's/^> *//')) · retry-404wide = the wide copy ($(diff .harness/after/$CT/PaymentCaller.java .harness/wide/PaymentCaller.java | $G '^>' | sed 's/^> *//' | $G -oE 'includes = [^)]*'))"; }
c_mock() {
  echo "== mock: PaymentRetryTest (after/'s build, the whole reactor, Docker-free) - MockRestServiceServer: no socket, no HTTP client"
  classes .harness/after/tiffinbox-client/target/surefire-reports "mock"
  $G -E '^PaymentRetryTest: ' .harness/build-after.log | sed 's/^/  mock | /'
  echo "  mock | its @Test lines $($G -cE '^ +@Test$' after/$CT/PaymentRetryTest.java) · MockRestServiceServer.bindTo $($G -c 'MockRestServiceServer.bindTo(builder)' after/$CT/PaymentRetryTest.java) · ExpectedCount times(3) $($G -c 'times(3)' after/$CT/PaymentRetryTest.java) · verify() $($G -c 'server.verify()' after/$CT/PaymentRetryTest.java)"
  echo "  mock | what it does not test: the timeout and the slow path, the stub's three charges, a real HTTP client's behaviour, and whether any server honours the key (the factory, timeout and retry captures are those witnesses)"; }
c_resilience4j() {
  echo "== resilience4j: previewed on a HARNESS class path only (the client module's test class path + the seed's Resilience4j 2.4.0 jars), never on the anchor"
  local R4J; R4J=$(ls "$M2"/io/github/resilience4j/*/2.4.0/*-2.4.0.jar | paste -sd: -); local MC="$M2/io/micrometer/micrometer-core/1.17.3/micrometer-core-1.17.3.jar"
  mkdir -p .harness/r4; bg "javac -nowarn -d .harness/r4 -cp \"$CPM:$R4J\" harness/src/r4/R4.java harness/src/r4/R4Core.java" .harness/javac-r4.log; [ "$RE" = 0 ] || die "R4 did not compile"
  echo "  r4 | the jars: $(echo "$R4J" | tr ':' '\n' | sed 's#.*/##' | paste -sd' ' -)"
  guard "R4Core"; bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java ${JL[*]} -cp \".harness/r4:$CPM:$R4J\" R4Core" .harness/r4core.out
  $G -E '^R4CORE ' .harness/r4core.out | sed 's/^/  r4 core | /'
  echo "  r4 core | calls $($G -c '^R4CORE call ' .harness/r4core.out) · RETRY events $($G -c '^R4CORE event RETRY ' .harness/r4core.out) (the library's own event publisher)"
  guard "R4 without Micrometer"; bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java ${JL[*]} -cp \".harness/r4:$CPM:$R4J\" R4" .harness/r4-nomicro.out; local e1=$RE
  echo "  r4 starter without micrometer-core | exit $e1 · started: $($G -c '^R4 started' .harness/r4-nomicro.out || true) · the innermost cause: $($G -E '^Caused by: ' .harness/r4-nomicro.out | tail -1 | sed 's/^Caused by: //')"
  guard "R4 with Micrometer"; bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java ${JL[*]} -cp \".harness/r4:$CPM:$R4J:$MC\" R4" .harness/r4-micro.out; local e2=$RE
  echo "  r4 starter with micrometer-core 1.17.3 | exit $e2 · $($G -E '^R4 started' .harness/r4-micro.out) · retry beans: $($G -E '^R4 bean retry' .harness/r4-micro.out | sed -E 's/^R4 bean ([^ ]+) .*/\1/' | sort | paste -sd' ' -) · the Boot 4 verifier: $($G -c 'SpringBoot4VerifierAutoConfiguration' .harness/r4-micro.out || true)"
  echo "  r4 | the anchor: files naming resilience4j in after/ $( (cd after && $G -rli resilience4j .) | wc -l | tr -d ' ') · Course 16 (Microservices & Spring Cloud) by title: backoff, jitter and Resilience4j in full"; }
c_spec() {
  echo "== spec: the committed file against the served document (after/, 21100, H2, harness-free) - unchanged by this unit"
  tb spec 21100 > /dev/null
  local SF=after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json BF=before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json
  $CURL -s "$(B 21100)/v3/api-docs" > $J/served.json
  echo "  the committed file against the served document (servers removed, json.dump indent 2, ensure_ascii False, a final newline): $(python3 -I -c '
import json,sys
d=json.load(open(sys.argv[1])); d.pop("servers",None)
print("equal" if json.dumps(d,indent=2,ensure_ascii=False)+"\n" == open(sys.argv[2],encoding="utf-8").read() else "differ")' $J/served.json $SF)"
  echo "  committed md5 before $(md5 -q $BF) · after $(md5 -q $SF) · bytes before $(wc -c < $BF | tr -d ' ') · after $(wc -c < $SF | tr -d ' ') · byte-equal: $(cmp -s $BF $SF && echo yes || echo no)"
  python3 -I harness/ops9s3.py ops $BF > $J/ops-before.txt; python3 -I harness/ops9s3.py ops $SF > $J/ops-after.txt
  echo "  before: $(tail -1 $J/ops-before.txt) · after: $(tail -1 $J/ops-after.txt) · the operations' ids before -> after: $(cmp -s $J/ops-before.txt $J/ops-after.txt && echo equal || echo differ)"
  echo "  OpenApiSpecTest on the committed file: $(python3 -I -c '
import sys,xml.etree.ElementTree as E
r=E.parse(sys.argv[1]).getroot(); print("tests %s failures %s errors %s" % (r.get("tests"), r.get("failures"), r.get("errors")))' .harness/after/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.OpenApiSpecTest.xml) (after/'s build) · the client is not rebuilt from a new file: its generated sources come from the same committed file"
  QUIET=1 tbstop spec 21100; }
jarcmp() { python3 -I - "$1" "$2" "$3" <<'PY'
import sys, zipfile
a = {i.filename: i.CRC for i in zipfile.ZipFile(sys.argv[1]).infolist()}; b = {i.filename: i.CRC for i in zipfile.ZipFile(sys.argv[2]).infolist()}
add = sorted(set(b) - set(a)); rem = sorted(set(a) - set(b)); mv = sorted(k for k in a if k in b and a[k] != b[k])
print("  jar | %s: entries %d -> %d · added %d %s · removed %d · shared entries whose CRC moved %d %s" % (sys.argv[3], len(a), len(b), len(add), add[:4], len(rem), len(mv), mv[:4]))
PY
}
c_moved() { echo "== moved: the jars this build makes, before -> after/ (entry by entry, CRC) - test scope only: the interface, the caller and the test are in no jar"
  jarcmp .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar "the web jar"
  jarcmp .harness/before/tiffinbox-core/target/tiffinbox-core-1.0.0.jar .harness/after/tiffinbox-core/target/tiffinbox-core-1.0.0.jar "the core jar"
  jarcmp .harness/before/tiffinbox-client/target/tiffinbox-client-1.0.0.jar .harness/after/tiffinbox-client/target/tiffinbox-client-1.0.0.jar "the client's main jar"
  echo "  jar | the client's main jar names Payment: $(unzip -l .harness/after/tiffinbox-client/target/tiffinbox-client-1.0.0.jar | $G -c 'Payment' || true)"
  echo "  BOOT-INF/lib names: before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ') · added $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c '^>' || true) · removed $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c '^<' || true)"; }
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
c_api() { echo "== api: every GET of the committed spec's /api/v1/ paths (filled: name Ravi, id 1; the run id zeros; the signed link expired) and two old refusals, on before (21106) and after/ (21100), H2, the default capacity, each its own JVM - not a witness for the caller (none of these requests reaches a test-scope class)"
  apiside before 21106; apiside after 21100
  sed 's/^  api |/  api before |/' $J/api-before.txt; sed 's/^  api |/  api after |/' $J/api-after.txt
  echo "  api | before -> after/: $(cmp -s $J/api-before.txt $J/api-after.txt && echo identical || echo DIFFER) ($(wc -l < $J/api-after.txt | tr -d ' ') requests each)"; }
c_seven() {
  echo "== the seven (c5-unit11/curlset.sh, no key header), each tree its own JVM, H2, the default capacity - not a witness for the caller: it sends nothing to a test-scope class"
  echo "  expected $S466"
  local s port i; for s in before after; do if [ $s = before ]; then port=21106; else port=21100; fi
    TREE=$s tb seven-$s $port > /dev/null
    sh $CURLSET $port .harness/run/seven-$s/secrets/tiffinbox/shutdown-token > $J/seven-$s.txt 2>&1
    i=0; while kill -0 "$(cat .harness/run/seven-$s/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 60 ] || break; sleep 0.05; done
    QUIET=1 tbstop seven-$s $port
    echo "  $s: the seven $(md5 -q $J/seven-$s.txt) ($(wc -l < $J/seven-$s.txt | tr -d ' ') lines)"; done; }
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
  echo "== the old surface by count (U18's reader, copied off U20's receipts), each tree its own JVM, H2, the default capacity - not a witness for the caller"
  echo "  expected $U4SURF"
  for side in before after; do if [ $side = before ]; then port=21106; else port=21100; fi
    TREE=$side tb surface-$side $port > /dev/null
    oldsurface2 $port $J/surface-$side.txt
    QUIET=1 tbstop surface-$side $port
    echo "  $side: the old surface $(md5 -q $J/surface-$side.txt) ($($G -c '^== ' $J/surface-$side.txt) requests, $(wc -l < $J/surface-$side.txt | tr -d ' ') lines)"; done
  echo "  before -> after/: $(cmp -s $J/surface-before.txt $J/surface-after.txt && echo equal || echo DIFFER)"; }
c_tests() {
  echo "== mvn -o clean package (tests on) on a copy of after/ (.harness/pkg): the whole reactor, Docker reachable"
  copy after .harness/pkg; copy after .harness/tests; copy after .harness/clientonly
  guard "mvn package"
  bg "cd .harness/pkg && $MV \"$AL\" clean package" .harness/pkg.log; local pre=$RE
  echo "  mvn package exit $pre"; reactor .harness/pkg.log
  for p in web client; do surefire .harness/pkg/tiffinbox-$p/target/surefire-reports "package | tiffinbox-$p"; done
  classes .harness/pkg/tiffinbox-client/target/surefire-reports "package | client"
  python3 -I - .harness/pkg/tiffinbox-web/target/surefire-reports .harness/before/tiffinbox-web/target/surefire-reports <<'PY'
import sys, glob, xml.etree.ElementTree as E
def load(d): return {E.parse(f).getroot().get("name").split(".")[-1]: E.parse(f).getroot().get("tests") for f in glob.glob(d + "/TEST-*.xml")}
a = load(sys.argv[1])
print("  package | the web module's classes %d · tests %d (U20's values block: web=85; before's own web tests were not run here: -DskipTests)" % (len(a), sum(int(x) for x in a.values())))
PY
  echo "  package | the client before (before's own build): $(python3 -I -c '
import sys,glob,xml.etree.ElementTree as E
print(sum(int(E.parse(f).getroot().get("tests")) for f in glob.glob(sys.argv[1] + "/TEST-*.xml")))' .harness/before/tiffinbox-client/target/surefire-reports) -> after: $(python3 -I -c '
import sys,glob,xml.etree.ElementTree as E
print(sum(int(E.parse(f).getroot().get("tests")) for f in glob.glob(sys.argv[1] + "/TEST-*.xml")))' .harness/pkg/tiffinbox-client/target/surefire-reports) · PaymentRetryTest's @Test lines $($G -cE '^ +@Test$' after/$CT/PaymentRetryTest.java)"
  local nps; nps=$(sed -E 's/"[^"]*"/""/g' after/$CT/PaymentRetryTest.java | $G -cE 'RANDOM_PORT|DEFINED_PORT|LocalServerPort|Socket|Thread\.sleep|[^0-9.][0-9]{4,5}[^0-9.]' || true)
  echo "  PaymentRetryTest: disabling or conditional annotations $($G -cE '@(org\.junit\.jupiter\.api\.(condition\.)?)?(Disabled|EnabledIf|DisabledIf|EnabledOn|DisabledOn|EnabledFor|DisabledFor)' after/$CT/PaymentRetryTest.java || true) · ports, sockets or sleeps (string literals removed) $nps"
  echo "  refusal lines of the limiter in the build log (the suite at the default; RateLimitFilterTest's own context refuses by design): outside RateLimitFilterTest $(awk '/\[INFO\] Running com\./ { c = $NF } /rate limit: refused/ && c !~ /RateLimitFilterTest/ { n++ } END { print n + 0 }' .harness/pkg.log)"
  echo "  test files moved before -> after: $(for p in $(cd before && find tiffinbox-web/src/test tiffinbox-client/src/test -type f | sort); do cmp -s before/$p after/$p || basename $p; done | paste -sd, -) · new: $(cd after && for p in $(find tiffinbox-web/src/test tiffinbox-client/src/test -type f | sort); do [ -e ../before/$p ] || basename $p; done | paste -sd, -)"
  echo "  the test classes that name MockRestServiceServer (grep -l): $( (cd after && $G -rl 'MockRestServiceServer' tiffinbox-client/src/test tiffinbox-web/src/test) | sed 's#.*/##; s#\.java$##' | sort | paste -sd, -)"
  echo "== the Docker-free twin: after/'s own build (DOCKER_HOST=unix:///nonexistent/docker.sock, the run's first build)"
  for p in web client; do surefire .harness/after/tiffinbox-$p/target/surefire-reports "twin | tiffinbox-$p"; done
  echo "== mvn -o clean verify on a copy of after/ (.harness/tests): Surefire's tests on H2 in memory, then the five ITs in Testcontainers containers (21280-21284)"
  for p in 21280 21281 21282 21283 21284 18881 18882 18883 18884; do [ "$(listeners $p)" = 0 ] || die "$p is bound before verify"; done
  guard "mvn verify"
  bg "cd .harness/tests && DOCKER_HOST=\"$DH\" TESTCONTAINERS_RYUK_DISABLED=true $MV \"$AL\" clean verify" .harness/verify.log; local vre=$RE
  reactor .harness/verify.log
  for p in web client; do surefire .harness/tests/tiffinbox-$p/target/surefire-reports "verify | tiffinbox-$p"; done
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
  echo "== the hand-built form: mvn -o clean package -pl tiffinbox-client -am on a copy of after/ (.harness/clientonly), Docker-free"
  guard "the client-only form"
  bg "cd .harness/clientonly && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package -pl tiffinbox-client -am" .harness/clientonly.log
  surefire .harness/clientonly/tiffinbox-client/target/surefire-reports "clientonly | tiffinbox-client"
  echo "  downloads across the builds: $(cat .harness/pkg.log .harness/verify.log .harness/clientonly.log .harness/build-after.log .harness/build-before.log .harness/build-before-client.log .harness/deptree.log .harness/cp-before.log .harness/cp-after.log 2> /dev/null | $G -cE 'Download(ing|ed) from ' || true)"
  echo "  BOOT-INF/lib: before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ') · added $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c '^>' || true) · removed $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c '^<' || true)"; }
c_harness() {
  echo "== harness: the folder's files and the instruments (copied byte-equal, adapted with a named diff, new)"
  echo "  harness/: $(ls harness | paste -sd' ' -) · harness/src: $(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -) · exercise/: $(ls exercise | paste -sd' ' -)"
  echo "  copied | dur9.py md5 $(md5 -q harness/dur9.py) · ops9s3.py md5 $(md5 -q harness/ops9s3.py) (unit 20's) · Stub.java $(md5 -q harness/stub/Stub.java) (Course 6's) · R4.java $(md5 -q harness/src/r4/R4.java) · R4Core.java $(md5 -q harness/src/r4/R4Core.java) (the S4 probe's)"
  echo "  adapted | tree21.py from tree20.py: $(diff ../c9-unit20/harness/tree20.py harness/tree21.py | $G -c '^[<>]') lines (the docstring only) · s921.py from s920.py: lines removed $(diff ../c9-unit20/harness/s920.py harness/s921.py | $G -c '^<'), added $(diff ../c9-unit20/harness/s920.py harness/s921.py | $G -c '^>'), the diff's md5 $(diff ../c9-unit20/harness/s920.py harness/s921.py | md5 -q) · Caller21.java from BlueCaller.java: the named diff's md5 $CLD"
  echo "  new | chk21.py md5 $(md5 -q harness/chk21.py) · exercise: break.sh $(md5 -q exercise/break.sh) · apply.sh $(md5 -q exercise/apply.sh) · check.sh $(md5 -q exercise/check.sh)"
  echo "  not used (absent from harness/): cdp.mjs cdp9.mjs seal9.py chrome20.py loc9.py src/probe - $(for f in cdp.mjs cdp9.mjs seal9.py chrome20.py loc9.py src/probe; do [ -e harness/$f ] && echo $f; done | wc -l | tr -d ' ') present"
  echo "  static (i), as written: output md5 $STMD5"
  local SC=.harness/static-copy; rm -rf $SC; mkdir -p $SC; cp -R after $SC/after; ln -s "$U/before" $SC/before; printf 'x' >> $SC/after/compose.yaml
  echo "  static (ii) on a scratch copy with a byte appended to after/compose.yaml (a path this unit did not change; the frozen tree untouched): $(python3 -I -B harness/chk21.py static $SC/after $SC/before > $J/st2.txt 2>&1; echo "exit $?") · a FAIL names it: $($G -c '^FAIL' $J/st2.txt || true)"
  local III=.harness/iii/u; rm -rf .harness/iii; mkdir -p $III/harness; cp harness/chk21.py $III/harness/; cp -R after $III/after; cp -RL before $III/before
  local s3; s3=$(cd $III && REPO="$UP" python3 -I -B harness/chk21.py static after before 2>&1 | md5 -q)
  echo "  static (iii) in a folder copy with no sibling anchor (no anchor folder beside it there; git objects read from the repository by REPO): output md5 = (i): $( [ "$s3" = "$STMD5" ] && echo yes || echo NO)"
  echo "  static plants (flag 18): a static assertion reading the live anchor (its folder name assembled) -> $(python3 -I -B harness/chk21.py static-plant live > /dev/null 2>&1; echo "exit $?") · the same path from two pieces -> $(python3 -I -B harness/chk21.py static-plant pieces > /dev/null 2>&1; echo "exit $?")"
  echo "  the frozen receipts that read the live anchor's poms (the orchestrator's flag-31 class, read, not edited): $(for f in ../c9-unit10/receipts.sh:611 ../c9-unit13/receipts.sh:334 ../c9-unit15/receipts.sh:396; do n=${f##*:}; sed -n "${n}p" "${f%%:*}" | $G -cF "$ANC" | sed "s#^#${f#../}=#"; done | paste -sd' ' -) (1 = the line names the live anchor)"; }
exrun() { local v=$1 sh=$2 o cmd
  guard "the exercise, $v, $sh"
  rm -rf .harness/exercise/tree; copy after .harness/exercise/tree
  if [ $v = broken ]; then cmd='sh break.sh "$0" > /dev/null && sh check.sh "$0"'; elif [ $v = solved ]; then cmd='sh break.sh "$0" > /dev/null && sh apply.sh "$0" > /dev/null && sh check.sh "$0"'; else cmd="sh break.sh \"\$0\" > /dev/null && HOW=$v sh apply.sh \"\$0\" > /dev/null && sh check.sh \"\$0\""; fi
  local envs=(env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21108 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock)
  if [ $sh = bash ]; then o=$(cd exercise && "${envs[@]}" bash -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1)
  else o=$(cd exercise && "${envs[@]}" /bin/zsh -f -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1); fi
  local pre="  $v $sh |"; if [ $v != broken ] && [ $v != solved ]; then pre="  ~ $v $sh |"; fi
  printf '%s\n' "$o" | sed -E "s/127\.0\.0\.1:21108/127.0.0.1:<port>/g; s/^/$pre /"
  [ ! -f exercise/check.build.log ] || offl exercise/check.build.log
  [ "$(listeners 21108)" = 0 ] || die "the exercise left something listening on 21108"; }
c_exercise() { local v sh
  rm -rf .harness/exercise; mkdir -p .harness/exercise
  for v in broken solved; do for sh in bash zsh; do echo "  == $v, $sh"; exrun $v $sh; done; done
  if [ "$RUNNO" = 1 ] || [ "$RUNNO" = 0 ]; then for v in none constant onlyfirst swallow fixedelsewhere; do exrun $v bash; done; fi
  rm -rf exercise/check.run; rm -f exercise/check.build.log
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }
c_inert() {
  echo "== the key header on every TiffinBox JVM of this run (their access logs, the pattern's key=%{Idempotency-Key}i field) and in the captures' request lines"
  echo "  TiffinBox access-log lines: $(cat .harness/run/*/access*.log 2> /dev/null | wc -l | tr -d ' ') · carrying a key: $(cat .harness/run/*/access*.log 2> /dev/null | $G -v 'key=-$' | wc -l | tr -d ' ') · JVMs $(ls -d .harness/run/*/ 2> /dev/null | wc -l | tr -d ' ')"
  echo "  the stubs' dumps (Course 6's stub, the only party the caller called): POSTs with the key $(cat .harness/stubs/*/dump.out 2> /dev/null | $G -c '^STUB-H idempotency-key: ' || true) · TiffinBox's ports in the callers' stub URLs: $(cat .harness/stubs/*/caller-*.out 2> /dev/null | $G -cE '127\.0\.0\.1:2110[06]' || true)"; }
c_title() {
  local TS; TS=$(python3 -I -B harness/chk21.py title-line)
  echo "== the title for search (S4B's Unit 21, printed, not edited - the copy step's): \"$TS\" ($(python3 -I -c 'import sys; print(len(sys.argv[1]))' "$TS") characters by len())"
  echo "  Course 6's search title beside it (java6_series.py): \"$($G -oF 'Spring Boot RestClient: Timeouts and Status Handlers' "$J6" 2> /dev/null | head -1)\" - RED4 #31's clash, NOTED for the copy step"; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures${DEVCAPS:+ (DEVELOPMENT: only $DEVCAPS - not a run of record)}"
cap advisory c_advisory
cap before c_before
cap change c_change
cap census c_census
cap factory c_factory
cap timeout c_timeout
cap retry c_retry
cap mock c_mock
cap resilience4j c_resilience4j
cap spec c_spec
cap moved c_moved
cap api c_api
cap seven c_seven
cap surface c_surface
cap tests c_tests
cap harness c_harness
cap exercise c_exercise
cap inert c_inert
cap title c_title
echo "== plants (each made to FAIL first on a copy of this run's capture; harness/chk21.py plants)"
if [ -z "${DEVCAPS:-}" ]; then
PL=$(python3 -I -B harness/chk21.py plants .) || die "a plant was not caught: $(printf '%s\n' "$PL" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$PL" | $G '^ok ' | sed 's/^ok /  /'
PLV=$(printf '%s\n' "$PL" | sed -n 's/^VALUES //p')
fi

# ---- the end: the sweep, the values, the published hashes -------------------------------------------------------------------------------
[ -z "$(echo $PIDS)" ] || die "a JVM of this run is still running: $PIDS"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
[ -z "$(dk ps -aq --filter label=org.testcontainers=true)" ] || die "a Testcontainers container of this run is left"
[ -z "$(dk ps -aq --filter name=^/c9u21-)" ] || die "a c9u21-* container is left"
NI1=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI1" = "$NI0" ] && [ "$VOL1" = "$VOL0" ] || die "R.322: images $NI0 -> $NI1, volumes $VOL0 -> $VOL1"
AD1=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true); [ "$AD1" = "$AD" ] || die "the anchor moved during the run"
pin before-tree before; pin after-tree after
MDB=$(find . ../c9-tiffinbox ../c9-unit20 -name '*.mv.db' -not -path './.harness/*' -not -path '../c9-unit20/.harness/*' 2> /dev/null | wc -l | tr -d ' ')
[ "$MDB" = 0 ] || die "an H2 file outside .harness/"
[ -z "$(ls exercise | $G -v -xE 'README.md|SOLUTION.md|apply.sh|break.sh|check.sh')" ] || die "the exercise left a file in exercise/"
VALS="$VALS
plants: $PLV
build: seed_files=$NF0 seed_bytes=$NB0 central_only=$CO"
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
[ -n "${DEVCAPS:-}" ] && { echo "c9-unit21: DEVELOPMENT run ($DEVCAPS) - nothing published"; exit 2; }
VO=$(python3 -I -B harness/chk21.py values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; [ -n "${NOPIN:-}" ] || die "README.md's values block is not this run's"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM and no stub of this run, ports free, no container left, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1 · the anchor against after/ as at the start · the tree pins · *.mv.db outside .harness 0"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit21: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit21: $NCAPS captures checked; every capture = published ($NCAPS)"
