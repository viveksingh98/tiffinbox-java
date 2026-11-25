#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 09 "Documenting Errors, Examples and Security" - this unit's receipts. Course 9's SIXTH anchor change, Section 2's third:
# before is a link to ../c9-unit08/after (U08's after: the document's own info, the committed document, OpenApiSpecTest); after/ is a frozen
# copy of ../c9-tiffinbox after this unit's change - per-operation error responses (Framework's ProblemDetail schema, one example per
# problem equal to an answer the wire sent) on the operations a command derives, the not-found problem typed
# tag:tiffinbox.example,2026:customer-not-found on every route that throws CustomerNotFound (the old GET /customers/{name} included), one
# new test per such route on $.type, and the committed document regenerated in the same commit. No pom, no property, no migration.
# The harness (never in the jar): the statement and request witnesses, Routes, the ShallowEtag plant - copied from U08's harness; unit 09's
# second client (probe.u09.U09Probe, /probe/u09/**) and the harness's COPY of the spec with a declared scheme (probe.u09.SchemeCopy);
# BLUE's specwire9.py, byte-equal. Every line they print is "the harness's". A JVM that joins the harness documents the harness's routes
# too: every claim about the document and every Nobody body is read from a start WITHOUT the harness. No browser in this unit.
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5), PostgreSQL first where both run:
#   tests     mvn -o package (tests on), its Docker-free twin, mvn -o verify (the ITs); 45 + k; BOOT-INF/lib before -> after
#   census    /actuator/mappings on after/ and before (one flag start each); flag 3's three parts; the problems TiffinBox writes; write routes
#   after     the three addresses and the document on after/ (no harness), PostgreSQL then H2
#   none      the three addresses, the document and the five Nobody answers on before (U08's after), H2, no harness
#   blanket   the plant (a scratch mirror of before + one @ResponseStatus line on the advice): the document's four-oh-fours, the wire beside
#   perop     the response codes of the 13 operations before and after; the document minus the added members hashed and read back; plants
#   shape     the ProblemDetail schema beside the wire's keys; every example against the filed wire bodies; plants
#   types     the five Nobody answers on after/, the old route's body before and after (S9.37), the key's problems, R2, the SHOULD, the write
#             routes; the keyed companion (harness-joined); the setType plant (k tests fail)
#   committed the file, the test on it, the stale file, a drifted file, drifted code, the moved four-oh-four (scratch mirrors)
#   diff      the spec against the wire on H2 (specwire9.py send + diff (a) and (b), the plant, the empty refusal)
#   scheme    the harness's copy of the spec with a declared scheme on 20985: anonymous GETs answer two hundred
#   moved     the old routes' answers, the Nobody requests and the addresses on before and after/, H2, no harness
#   seven     c5-unit11/curlset.sh on before and after/ (each its own JVM, no key)
#   surface   the old surface by count on before and after/, and the S9.14 plant (a ShallowEtagHeaderFilter, the harness's)
#   inert     the key header and the key table across every capture of the run
#   exercise  check.sh on the broken tree (before), the solution (apply.sh) and the refused "solutions", bash and zsh -f, H2
# Ports (Course 9's U09 band, 20980-20989): 20980 after/ on H2 · 20981 PostgreSQL c9u09-pg · 20982 after/ on PostgreSQL · 20983 the flag
# start of after/ · 20984 the S9.14 plant · 20985 the scheme copy · 20986 before (and its flag start) · 20987 the scratch mirrors (blanket) ·
# 20988 the exercise · 20989 never bound. During mvn verify only: 21280-21284, one per IT. Every store on 127.0.0.1; every curl
# --noproxy '*'. The key header is sent only by specwire9.py's pause-key request and the keyed companion's named requests (KEYH).
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
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c9u09-pg
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
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "curlset.sh") || index($0, "check.sh") || index($0, "apply.sh") || $3 ~ /(^|\/)javac$/) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
tcrm() { local c n=0 i=0; [ -n "$TC0" ] || return 0
  while [ $i -lt 10 ]; do
    for c in $(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null); do dk rm -fv "$c" > /dev/null 2>&1 && n=$((n + 1)); done
    [ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] && break; sleep 0.5; i=$((i + 1)); done
  [ "$n" = 0 ] || echo "  the trap: $n Testcontainers container(s) removed with their volumes (rm -fv)" >&3; }
ctrm() { [ -n "$TC0" ] || return 0; [ -z "$(dk ps -aq --filter name=^/$CN\$ 2> /dev/null)" ] || dk rm -fv "$CN" > /dev/null 2>&1 || true; }
trap 'trap "" INT TERM; for p in $pollpid $mpid $PIDS; do [ -z "$p" ] || killtree "$p"; done; for p in $pollpid $mpid $PIDS; do if kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; tcrm; ctrm; rm -rf exercise/check.run exercise/apply.run; rm -f exercise/check.build.log exercise/check.spec.json exercise/check.nobody.json exercise/check.status exercise/check.jvm.log exercise/apply.build.log exercise/apply.jvm.log exercise/apply.spec.json; [ -z "$INTR" ] || rm -f .r-*.new; rmdir .r-lock 2> /dev/null || rm -rf .r-lock; true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git unzip /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|SPRINGDOC_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT|BLUE_RUN)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit09 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }') · run $RUNNO"

# ---- gates before anything is built: the folder, the link, the pins, the anchor, the static check, the prose, the exercise ----------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk09.py dur9.py s909.py specwire9.py src tree09.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
HSRC='mirror/TiffinBoxErrorDocs.java probe/Etag.java probe/Http.java probe/Routes.java probe/Witness.java probe/u09/SchemeCopy.java probe/u09/U09Probe.java'
[ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$HSRC" ] || die "harness/src holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md apply.sh check.sh' ] || die "exercise/ holds another file, or misses one"
[ -L before ] && [ "$(readlink before)" = ../c9-unit08/after ] || die "before must be a link whose text is exactly ../c9-unit08/after (found: $( [ -L before ] && readlink before || echo 'not a link'))"
[ -d after ] && [ ! -L after ] || die "after/ is this unit's own frozen tree, a directory, not a link"
for t in before after; do [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/ - never built in place"; true; done
echo "  before -> $(readlink before) (a link, the text exact) · after/ a directory (the frozen copy) · no secrets/, target/ or .m2-demo/ in either"
$G -v '^ *#' harness/src/probe/*.java harness/src/probe/u09/*.java | $G -q 'Thread\.sleep' && die "R.412: a Thread.sleep in the harness"
for f in Witness Http Etag Routes; do w=$(awk -v n="harness/src/probe/$f.java" '$1 == "file" && $2 == n { print $3 }' ../c9-unit08/receipts.md5)
  [ -n "$w" ] && [ "$(md5 -q harness/src/probe/$f.java)" = "$w" ] || die "harness/src/probe/$f.java is not U08's published file (../c9-unit08/receipts.md5)"; done
echo "  harness/src/probe: Witness, Http, Etag, Routes = ../c9-unit08/receipts.md5's file lines (copied from U08's harness, c9-unit08/harness/src/probe) · u09/U09Probe, u09/SchemeCopy = this unit's"
SW9=$(awk '$2 ~ /instruments\/specwire9\.py$/ { print $1 }' "$BK/MD5SUMS")
[ -n "$SW9" ] && [ "$(md5 -q harness/specwire9.py)" = "$SW9" ] && [ "$(md5 -q "$BK/instruments/specwire9.py")" = "$SW9" ] || die "harness/specwire9.py is not BLUE's instrument (its MD5SUMS line: ${SW9:-none})"
echo "  harness/specwire9.py: BLUE's instrument, byte-equal (md5 $SW9 = $BK's MD5SUMS line, = the filed copy) - the names it sends are its own"
[ "$(sed -n '5,$p' harness/tree09.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit08/harness/tree08.py | md5 -q)" ] || die "harness/tree09.py's code is not tree08.py's"
W8=$(awk '$1 == "file" && $2 == "harness/specwire9.py" { print $3 }' ../c9-unit08/receipts.md5); [ "$(md5 -q harness/specwire9.py)" = "$W8" ] || die "harness/specwire9.py is not U08's copy"
for u in 01 02 03 04 05 06 07 08; do [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit$u/harness/dur9.py)" ] || die "harness/dur9.py is not ../c9-unit$u's copy (dur9 as shipped)"; done
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"
  [ ! -f "$C9R/_builders/dur9.py" ] || [ "$(md5 -q "$C9R/_builders/dur9.py")" = "$D9" ] || die "harness/dur9.py is not C9/_builders/dur9.py"
else D9N="(the registry is not on this machine: U01-U08's copies are the pin)"; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit01-08's copies $D9N · tree09.py's code = tree08.py's · specwire9.py = U08's copy ($W8)"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit08/receipts.md5)
[ -n "$UA" ] || die "../c9-unit08/receipts.md5 has no after-tree line"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree09.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$nm" = after-tree ] || [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit08/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree09.py $dir/ -> $got = receipts.md5's $nm line$( [ "$nm" = before-tree ] && echo " = ../c9-unit08/receipts.md5's after-tree line")"; }
pin before-tree before; pin after-tree after
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true)
echo "  after/ against ../c9-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures its own frozen after/' )"
HF="harness/chk09.py harness/s909.py harness/tree09.py harness/dur9.py harness/specwire9.py $(for f in $HSRC; do printf 'harness/src/%s ' $f; done)exercise/check.sh exercise/apply.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's scripts: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
ST=$(python3 -I -B harness/chk09.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
STV=$(printf '%s\n' "$ST" | sed -n 's/^VALUES //p')
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s909.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U09 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s909, per sentence): /'
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b|<measure>' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
GL=$(python3 -I -B harness/chk09.py gloss README.md) || die "the gloss: $(printf '%s\n' "$GL" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$GL" | $G -v '^VALUES ' | sed 's/^/  /'
GLV=$(printf '%s\n' "$GL" | sed -n 's/^VALUES //p')
HOOK=$(python3 -I -B harness/chk09.py hook); EXQ=$(python3 -I -B harness/chk09.py exq); GLS=$(python3 -I -B harness/chk09.py gloss-line)
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S2B's Unit 09 Hook line), byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SP=$(python3 -I -B harness/chk09.py spoken "$HOOK" "$EXQ") || die "the spoken lines: $(printf '%s\n' "$SP" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$SP" | $G -v '^VALUES ' | sed 's/^/  /'
SPV=$(printf '%s\n' "$SP" | sed -n 's/^VALUES //p')
printf '%s\n\n%s\n' "$EXQ" "$GLS" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s909.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
printf '%s\n' "$SW" | tail -1 | $G -qE ' refused: 0$' || die "a refused reading in a spoken line: $(printf '%s\n' "$SW" | $G ' line ' | head -3 | paste -sd';' -)"
printf '%s\n' "$HOOK" > .r-lock/spoken.md
SH=$(python3 -I -B harness/s909.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the hook did not run"
SHV=$(printf '%s\n' "$SH" | $G ' line ' | sed 's/^ *[^:]*: //' | paste -sd';' -)
echo "  the hook through s909.py (every family, the carried base included): $(printf '%s\n' "$SH" | tail -1 | sed 's/.*refused: //') refused - ${SHV:-none}"
[ "$SHV" = 'XU19: the revenue without "the same orders copied" in its paragraph (RED #16)' ] || die "the hook: a refusal other than the one filed (the carried XU19): $SHV"
echo "  FILED (What differed, For RED): the brief's hook passes the status, spelling, Hinglish and dur9 gates and XU09, and the carried base's XU19 (Course 8's \"the revenue\" rule) refuses it - recorded, the brief's line not edited; the smallest passing wording is RED's"
echo "  the exercise's line and the gloss through s909.py (every family, dur9 inside it): refused 0"; rm -f .r-lock/spoken.md
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
$G -qE '^rm -f check\.' exercise/check.sh || die "exercise/check.sh must remove its saved files before it builds"
! $G -qwE 'path' exercise/check.sh exercise/apply.sh || die "exercise/check.sh or apply.sh names a variable path - under zsh that is the PATH array (BLUE C9-U06's finding): rpath"
$G -qF 'sh apply.sh' exercise/SOLUTION.md || die "SOLUTION.md must give the solution as apply.sh's run"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh exercise/check.sh exercise/apply.sh | $G -qwE "$K1|$K2" || die "a script names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket"
DK=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -vF 'echo "' | $G -nE '(^|[ ;(])docker (run|exec|rm|ps|port|info|images|volume|image|pull|logs|inspect)\b' | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.344: receipts.sh calls docker without the pinned socket: $DK"
RMF=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) rm( +-[a-z]+)*' | sort -u | paste -sd'|' -)
[ "$RMF" = 'dk rm -fv' ] || die "R.387: receipts.sh removes a container without its volumes (found: ${RMF:-none})"
[ "$($G -v '^ *#' receipts.sh | $G -oE '(dk|docker) run -[^"]*' | $G -vcF -- '--pull never' || true)" = 0 ] || die "R.344: a dk run without --pull never"
MVA=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -F '$MV ' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am"
KW='idempotency''-key'; KH=$($G -v '^ *#' receipts.sh exercise/check.sh exercise/apply.sh | $G -iF "$KW" | $G -vcF 'KEYH=' || true)
[ "$KH" = 0 ] || die "S9.21: a line of receipts.sh or the exercise names the key header ($KH) - the named requests send it through $KEYH"
echo "  the exercise: check.sh removes its saved files first, names no variable path; SOLUTION.md runs apply.sh; the two What-it-prints blocks differ · the hook and the exercise's line byte for byte · placeholders 0"
echo "  static: no kill by name; every docker call on the pinned socket, every dk run --pull never, every removal rm -fv; every Maven build -pl tiffinbox-web -am; no Thread.sleep in the harness; the key header named by no line of receipts.sh or the exercise"
mask() { awk -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(PE, "…"); gsub(P, "…"); gsub(QE, "…/.."); gsub(Q, "…/.."); gsub(H, "~")
    gsub(/ in [0-9.]+ seconds \(process running for [0-9.]+\)/, " in <t> (process running for <t>)")
    gsub(/\(execution time [0-9:.]+s\)/, "(execution time <t>)")
    gsub(/Total time: +[0-9.:]+ [a-z]+/, "Total time: <t>")
    gsub(/Time elapsed: [0-9.]+ s/, "Time elapsed: <t>")
    gsub(/[0-9]+ ms/, "<t>")
    gsub(/pid [0-9]+/, "pid <n>")
    gsub(/[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?( ?[A-Z]{3,4}|Z|[+-][0-9:]+)?/, "<time>")
    gsub(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/, "<uuid>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'took 812 ms' '"timestamp":"2026-11-24T07:12:01.123+01:00"' "$U/x $HOME/y" | mask)
[ "$(printf '%s\n' "$MP" | paste -sd'|' -)" = 'Started TiffinBoxServer in <t> (process running for <t>)|took <t>|"timestamp":"<time>"|…/x ~/y' ] || die "the mask's self-test: $(printf '%s\n' "$MP" | paste -sd'|' -)"
maskh() { tr -d '\r' < "$1" | sed -E 's/^(Date|date): .*/\1: <masked>/; s/(JSESSIONID=)[^;]*/\1<masked>/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/^(Expires): .*/\1: <masked>/; s/^(Keep-Alive): .*/\1: <masked>/'; }
MH=$(printf 'Date: Tue, 24 Nov 2026 08:00:00 GMT\r\nSet-Cookie: JSESSIONID=ABC123; Path=/; HttpOnly\r\nLocation: http://127.0.0.1:20970/dashboard\r\nExpires: Tue, 24 Nov 2027 08:00:00 GMT\r\nKeep-Alive: timeout=60\r\n' > .r-lock/mh; maskh .r-lock/mh | paste -sd'|' -; rm -f .r-lock/mh)
[ "$MH" = 'Date: <masked>|Set-Cookie: JSESSIONID=<masked>; Path=/; HttpOnly|Location: http://127.0.0.1:<port>/dashboard|Expires: <masked>|Keep-Alive: <masked>' ] || die "the header mask's self-test: $MH"
SM=$(printf '{"openapi":"3.1.0","servers":[{"url":"http://127.0.0.1:20970","description":"Generated server url"}],"paths":{}}' | python3 -I -B harness/chk09.py specmask)
[ "$SM" = '[{"url": "http://127.0.0.1:<port>", "description": "Generated server url"}]' ] || die "the servers mask's self-test: $SM"
echo "  masks: the log mask masked a Started line's times, a millisecond count, Boot's /error timestamp, the folders and the home; the header mask a planted Date, session cookie, port, Expires and Keep-Alive; the servers mask a planted servers[0].url's port"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
$G -qF 'S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)' ../c9-unit08/receipts.sh || die "../c9-unit08/receipts.sh no longer reads the seven's md5 off ../c7-unit31/receipts.sh"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SURF=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh)
[ ${#U4SURF} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh (SURF=)"
U7V=$(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit08/README.md | $G -oE '^(seven: seven|surface: surface)=[0-9a-f]+' | sed 's/^[a-z]*: //' | paste -sd' ' -)
[ "$U7V" = "seven=$(echo $S466 | cut -c1-8) surface=$(echo $U4SURF | cut -c1-8)" ] || die "U08's README values block ($U7V) is not the seven and the surface read off the receipts"
U7I=$(awk '$1 == "seven" { print $2 }' ../c9-unit08/receipts.md5); [ ${#U7I} = 32 ] || die "../c9-unit08/receipts.md5 has no seven line"
echo "  the seven: expected $S466 (../c7-unit31/receipts.sh's S466= line, as ../c9-unit08/receipts.sh reads it) · the old surface: expected $U4SURF (../c9-unit04/receipts.sh's SURF= line, U08's reader) · both = U08's README values block ($U7V) · U08's seven capture published as $U7I in ../c9-unit08/receipts.md5"
FA=$(cat "$ADV/fetched-at.txt" 2> /dev/null | head -1); [ -n "$FA" ] || die "the advisories' fetched-at line is missing ($ADV)"
FAE=$(python3 -I -c 'import datetime,sys; t = datetime.datetime.strptime(sys.argv[1], "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=datetime.timezone.utc); print(int((datetime.datetime.now(datetime.timezone.utc) - t).total_seconds() // 3600))' "$FA")
[ "$FAE" -lt 48 ] || die "S9.36: the filed advisory read is $FAE hours old - a re-read is the orchestrator's act"
echo "  S9.36: today's filed read ($ADV), fetched at $FA ($FAE h before this run; not re-read: no network) · $(head -1 "$ADV/tomcat-11.0.30-section.txt") · OSV for springdoc: $($G -i springdoc "$ADV/osv-summary.txt" | sed 's/^org.springdoc://' | paste -sd';' -)"

# ---- docker, ports, the guard: the baselines ----------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that socket? (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
iid() { dk image inspect --format '{{.Id}}' "$1" 2> /dev/null | cut -c8-19; }
[ "$(iid $IMG)" = 77f585114c32 ] || die "the image $IMG is not on this machine - this script never pulls"
[ "$IMG" = "$(sed -n 's/^IMG=\(postgres@sha256:[0-9a-f]*\).*/\1/p' ../c9-unit08/receipts.sh)" ] || die "the image digest is not ../c9-unit08/receipts.sh's IMG= line"
[ "$IMG" = "$(sed -n '42s/^IMG=\(postgres@sha256:[0-9a-f]*\).*/\1/p' ../c8-unit27/receipts.sh)" ] || die "the image digest is not ../c8-unit27/receipts.sh:42's"
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run"
[ -z "$(dk ps -aq --filter name=^/$CN\$ 2> /dev/null)" ] || die "a container named $CN exists before the run - an interrupted run's? docker -H \"\$DH\" rm -fv $CN"
TC0=1
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
BAND="20980 20981 20982 20983 20984 20985 20986 20987 20988 20989"
PORTS="18425 18881 18882 18883 18884 20578 20615 $BAND 21280 21281 21282 21283 21284"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
for p in $BAND 21280 21281 21282 21283 21284; do [ -z "$(lsof -nP -iUDP:$p 2> /dev/null)" ] || die "UDP $p is bound"; done
[ "$(pgrep -x java | wc -l | tr -d ' ')" = 0 ] || die "a java process is running before this script starts one - not this script's; stop it first"
guard() { local r; r=$(pgrep -fl "^/bin/(ba)?sh (\./|.*/)(receipts|runrec)[.]sh" 2> /dev/null | $G -v "^$$ " || true)
  local l1; l1=$(sysctl -n vm.loadavg | awk '{ print $2 }')
  [ -z "$r" ] || die "S9.17: another receipt runs ($r) before $1 - this run stops; wait for it, never kill it"
  local w=0; while ! awk -v l="$l1" 'BEGIN { exit !(l < 20) }'; do
    [ -n "${GUARD0:-}" ] || die "R.480: load1 $l1 is not below 20 at the launch - a run of record launches only below 20; launch again when it is"
    w=$((w + 1)); [ $w -lt 900 ] || die "R.480: load1 stayed at or above 20 for 900 checks before $1"; sleep 1; l1=$(sysctl -n vm.loadavg | awk '{ print $2 }'); done
  GUARD0=1
  for p in $BAND; do case " ${MINE:-} " in *" $p "*) continue ;; esac; [ "$(listeners $p)" = 0 ] || die "guard before $1: something listens on $p that this run did not start"; done
  echo "  guard before $1: no other receipt · load1 $l1 (< 20)$( [ $w = 0 ] || echo " after $w checks at or above 20 (waited, never killed)") · the band free"; }
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · $IMG present (= U08's IMG=, = c8-unit27:42's) · nothing pulled, ever · no Testcontainers container, no $CN · ports $PORTS free (TCP; the band and 21280-21284 UDP too) · no java process"

# ---- the trees, copied and built offline: before (through the link), after/; the harness, compiled -----------------------------------
M2="$PWD/.m2-demo"
if [ ! -d "$M2" ]; then [ -d "$SEED" ] || die "the seed $SEED is missing (README.md, The repository)"; cp -cR "$SEED" "$M2" 2> /dev/null || cp -R "$SEED" "$M2" || die "the seed could not be copied"; fi
NF0=$(find "$M2" -type f | wc -l | tr -d ' '); NB0=$(find "$M2" -type f -print0 | xargs -0 stat -f %z | awk '{ s += $1 } END { printf "%d", s }')
CO=$(find "$M2" -name _remote.repositories -print0 | xargs -0 $G -l 'central-only' 2> /dev/null | wc -l | tr -d ' ')
[ "$CO" = 0 ] || die "S2.4: $CO _remote.repositories files in the seed copy still name central-only - the seed is not the rewritten one"
for a in org/springframework/boot/spring-boot-starter-parent/4.1.3/spring-boot-starter-parent-4.1.3.pom org/apache/tomcat/embed/tomcat-embed-core/11.0.29/tomcat-embed-core-11.0.29.jar \
         org/springdoc/springdoc-openapi-starter-webmvc-ui/3.2.1/springdoc-openapi-starter-webmvc-ui-3.2.1.jar org/springdoc/springdoc-openapi-starter-webmvc-api/3.2.1/springdoc-openapi-starter-webmvc-api-3.2.1.jar \
         io/swagger/core/v3/swagger-core/3.0.0/swagger-core-3.0.0.jar org/webjars/swagger-ui/5.35.1/swagger-ui-5.35.1.jar net/ttddyy/datasource-proxy/1.11.1/datasource-proxy-1.11.1.jar; do
  [ -f "$M2/$a" ] || die ".m2-demo holds no $a - it is not the Section 2 seed"; done
echo "  .m2-demo (a copy of the seed m2-seed-c9-s2): files $NF0 · bytes $NB0 · _remote.repositories naming central-only: $CO · the 4.1.3 parent, tomcat-embed-core 11.0.29, springdoc's two starters 3.2.1, swagger-core 3.0.0, swagger-ui 5.35.1, datasource-proxy 1.11.1 present"
mkdir -p .harness; rm -rf .harness/before .harness/after .harness/pkg .harness/twin .harness/tests .harness/run .harness/work .harness/hc .harness/drift-* .harness/exercise .harness/blanket .harness/revert
mkdir -p .harness/home .harness/run .harness/work
printf '%s\n' 'checks.disable=true' "tinyimage.container.image=$IMG" > .harness/home/.testcontainers.properties
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy before .harness/before; copy after .harness/after
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE 'Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" HOME=\"$U/.harness/home\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 900; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
AL="-DargLine=$JL -Dstdout.encoding=UTF-8 -Duser.home=../../home"
for t in before after; do
  guard "the build of $t"
  bg "cd .harness/$t && $MV -DskipTests clean package -pl tiffinbox-web -am" .harness/build-$t.log
  [ "$RE" = 0 ] || { tail -30 .harness/build-$t.log | mask >&3; die ".harness/$t did not build offline (exit $RE)"; }; offl .harness/build-$t.log
  bg "cd .harness/$t && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$t.log
  [ "$RE" = 0 ] || die ".harness/$t: the jar's extract failed"
  echo "  built $t offline (mvn -o -DskipTests clean package -pl tiffinbox-web -am, exit 0, Downloading/Downloaded from: 0) · its jar extracted"
done
CPA=".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*"
DSP="$M2/net/ttddyy/datasource-proxy/1.11.1/datasource-proxy-1.11.1.jar"
PGJ=$(ls .harness/after/$XD/lib | $G '^postgresql-[0-9.]*\.jar$' || true)
[ "$PGJ" = postgresql-42.7.14.jar ] || die "after/'s lib/ holds no postgresql-42.7.14.jar (found: ${PGJ:-none})"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \"$CPA:$DSP\" harness/src/probe/*.java harness/src/probe/u09/*.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/'s jar: $(head -5 .harness/javac.log)"
echo "  the harness compiled against after/'s jar ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes, javac 25 -parameters; datasource-proxy 1.11.1 from .m2-demo, on the harness's class path only; the PostgreSQL driver is the jar's own, $PGJ)"

# ---- helpers ---------------------------------------------------------------------------------------------------------------------------
B() { echo "http://127.0.0.1:$1"; }
J=.harness/work
mark() { wc -l < ".harness/run/$1/jvm.log" | tr -d ' '; }
acount() { wc -l < ".harness/run/$1/access/access.log" 2> /dev/null | tr -d ' '; }
srv() { local lab=$1 m=$2 a0=$3 i=0
  while [ "$(acount $lab)" -le "$a0" ]; do i=$((i + 1)); [ $i -lt 400 ] || { echo "     access: NO LINE"; break; }; sleep 0.02; done
  [ $i -ge 400 ] || echo "     access: $(sed -n "$(( a0 + 1 ))p" ".harness/run/$lab/access/access.log")"
  [ -n "${NOWIT:-}" ] && return 0
  sed -n "$(( m + 1 )),\$p" ".harness/run/$lab/jvm.log" | $G -E "^PROBE-REQ [0-9]+ " | sed -E 's/^PROBE-REQ [0-9]+ /     server: /' | cut -c1-260 || true; }
HSEL='^(Location|Allow|Accept-Patch|Content-Length|Content-Type):'
# ask LABEL METHOD PATH [curl args]: one request into its own (reset) header and body files (U06's ask, trimmed: no cache keys)
ask() { local lab=$1 m=$2 p=$3 o=$J/$DB-$1 w rc mk a0 x; shift 3
  : > "$o.h"; : > "$o.b"; mk=$(mark $L); a0=$(acount $L)
  w=$($CURL --http1.1 -sS -D "$o.h" -o "$o.b" -w '%{http_code} %{content_type} %{size_download}' --max-time 20 -X "$m" "$@" "$(B $P)$p" 2> "$o.err"); rc=$?
  echo "-- $lab | $m $p -> $w (curl exit $rc)"
  x=no; for a in "$@"; do case "$a" in [Ii]dempotency-[Kk]ey:*) x=yes ;; esac; done; echo "     sent: key header $x"
  echo "     status lines: $(tr -d '\r' < "$o.h" | $G -E '^HTTP/' | sed 's/ *$//' | paste -sd'>' - | sed 's/>/ > /g')"
  tr -d '\r' < "$o.h" | $G -iE "$HSEL" | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' | while IFS= read -r h; do echo "     header: $h"; done
  srv $L $mk $a0
  local n; n=$(wc -c < "$o.b" | tr -d ' ')
  if [ "$n" -le 330 ] && [ "$n" -gt 0 ]; then echo "     body: $(tr -d '\r' < "$o.b" | tr '\n' '~' | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/"timestamp":"[^"]*"/"timestamp":"<masked>"/')"; else echo "     body: $n B md5 $(sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' "$o.b" | md5 -q) (the port masked)"; fi; }
probe() { $CURL -s "$(B $P)/probe/u09/$1"; }
psqlq() { dk exec $CN psql -U tiffinbox -d "${2:-tiffinbox}" -qAt -c "$1" 2>&1 | tr '\n' ' ' | sed 's/ *$//'; }
row() { if [ "$DB" = pg ]; then local x; x=$(psqlq "SELECT name || ' ' || meals_per_day || ' ' || price_per_meal || ' ' || meal_type || ' v' || version FROM customer WHERE name = '$1'"); echo "${x:-no row} (psql in $CN, the second client)"
  else echo "$(probe row/$1 | python3 -I -c 'import json,sys; r = [{k.lower(): v for k, v in x.items()} for x in json.load(sys.stdin)]; print(" ".join("%s %s %s %s v%s" % (x["name"], x["meals_per_day"], x["price_per_meal"], x["meal_type"], x["version"]) for x in r) or "no row")') (the harness's JdbcTemplate route /probe/u09/row/$1, the second client)"; fi; }
count() { if [ "$DB" = pg ]; then echo "$(psqlq "SELECT count(*) FROM customer") (psql in $CN, the second client)"; else echo "$(probe count | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])') (the harness's JdbcTemplate route /probe/u09/count, the second client)"; fi; }
keyrows() { if [ "$DB" = pg ]; then echo "$(psqlq "SELECT count(*) FROM idempotency_key") (psql in $CN, the second client)"; else echo "$(probe keys | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])') (the harness's JdbcTemplate route /probe/u09/keys, the second client)"; fi; }
pgfresh() { psqlq "drop database if exists tiffinbox with (force)" postgres > /dev/null; psqlq "create database tiffinbox" postgres > /dev/null; }
pgup() { guard "the PostgreSQL container"
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:20981:5432 -e POSTGRES_DB=tiffinbox -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust $IMG" .harness/docker-run-pg.log
  [ "$RE" = 0 ] || die "the PostgreSQL container did not start: $(tail -2 .harness/docker-run-pg.log)"
  local i=0; while ! dk exec $CN pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 240 ] || die "PostgreSQL did not accept connections"; sleep 0.5; done
  [ "$(dk port $CN | paste -sd'|' -)" = '5432/tcp -> 127.0.0.1:20981' ] || die "$CN publishes on another address than 127.0.0.1:20981"
  MINE=20981
  echo "  $CN: PostgreSQL $(psqlq 'show server_version') by the digest, on 127.0.0.1:20981 alone (docker port), trust on the loopback (no password exists to print), a fresh database"; }
# tb LABEL PORT DB HCX [args]: TiffinBox (the extracted jar of TREE=after unless TREE is set), from its own run folder with a generated token
# (a config tree, 0600, never printed), Tomcat's access log on (unbuffered, no time field: %m %U%q %s %b, S9.27); waited for by its
# Started line (never a health poll)
tb() { local label=$1 port=$2 db=$3 hcx=$4 t=${TREE:-after} run=.harness/run/$1 jx="" src="" i=0; shift 4
  guard "TiffinBox $label"
  for q in 20989; do [ "$(listeners $q)" = 0 ] && [ -z "$(lsof -nP -iUDP:$q 2> /dev/null)" ] || die "$q must stay free (TCP and UDP)"; done
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox" "$run/access"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  local x="$U/.harness/$t/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  if [ -n "$hcx" ]; then cp="$hcx:$cp:$U/.harness/hc:$DSP"; src="--spring.main.sources=${SRC:-probe.Witness,probe.Http,probe.Routes,probe.u09.U09Probe}"; fi
  [ "$db" = pg ] && jx="-Dtiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:20981/tiffinbox?user=tiffinbox"
  (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 $jx -cp "$cp" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port="$port" $src \
     --server.tomcat.accesslog.enabled=true --server.tomcat.accesslog.directory="$U/$run/access" --server.tomcat.accesslog.prefix=access --server.tomcat.accesslog.suffix=.log \
     --server.tomcat.accesslog.file-date-format= --server.tomcat.accesslog.rotate=false "--server.tomcat.accesslog.pattern=%m %U%q %s %b" --server.tomcat.accesslog.buffered=false "$@" > jvm.log 2>&1) &
  local p=$!; echo $p > "$run/pid"; PIDS="$PIDS $p"
  while ! $G -q -E 'Started TiffinBox(App|Server) in' "$run/jvm.log" 2> /dev/null; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before its Started line"; }; i=$((i + 1)); [ $i -lt 900 ] || die "$label: no Started line"; sleep 0.1; done
  echo "  $label up on $port ($db, tree $t$( [ -n "$hcx" ] && echo ", the harness joined" || echo ", no harness")) · cap: alarm 900 (perl) · waited for its Started line · $($G -o -E 'Successfully applied [0-9]+ migrations[^(]*|Schema "[^"]*" is up to date[^.(]*' "$run/jvm.log" | head -1 | sed 's/ *$//')"
  echo "  version lines ($label): $($G -oE 'Starting Servlet engine: \[[^]]*\]|HHH000001: Hibernate ORM core version [0-9A-Za-z.]+' "$run/jvm.log" | paste -sd'|' -) · Boot $(ls .harness/$t/$XD/lib | sed -n 's/^spring-boot-\([0-9][0-9.]*\)\.jar$/\1/p') · Framework $(ls .harness/$t/$XD/lib | sed -n 's/^spring-core-\([0-9][0-9.]*\)\.jar$/\1/p') · Jackson $(ls .harness/$t/$XD/lib | sed -n 's/^jackson-databind-\(3[0-9.]*\)\.jar$/\1/p') · springdoc $(ls .harness/$t/$XD/lib | sed -n 's/^springdoc-openapi-starter-webmvc-ui-\([0-9.]*\)\.jar$/\1/p' | $G . || echo none) · database: $($G -m1 -oE 'Database: [^ ]+ \([^)]*\)' "$run/jvm.log" | sed -E 's/jdbc:[a-z0-9]+:[^ ]*/<url>/')"; }
tbstop() { local label=$1 port=$2 run=.harness/run/$1 p i=0; p=$(cat "$run/pid")
  if kill -0 "$p" 2> /dev/null; then printf 'X-Shutdown-Token: %s\n' "$(head -1 "$run/secrets/tiffinbox/shutdown-token")" | $CURL -s -o /dev/null --max-time 5 -H @- -X POST "$(B $port)/shutdown" || true; fi
  while kill -0 "$p" 2> /dev/null; do i=$((i + 1)); [ $i = 80 ] && kill "$p" 2> /dev/null; [ $i -lt 400 ] || { kill -9 "$p" 2> /dev/null; break; }; sleep 0.05; done
  wait "$p" 2> /dev/null || true; PIDS=$(echo " $PIDS " | sed "s/ $p / /g")
  [ "$(listeners $port)" = 0 ] || die "$label: something still listens on $port"; }
health() { echo "  one GET /actuator/health (a counted step of its own): $($CURL -s -o /dev/null -w '%{http_code}' "$(B $P)/actuator/health")"; }
NCAPS=0; unpub=""; VALS=""
cap() { local nm=$1; shift
  if [ -n "${DEVCAPS:-}" ] && ! echo " $DEVCAPS " | $G -qF " $nm "; then return 0; fi   # development only: a run of record sets no DEVCAPS
  "$@" > .harness/cap-$nm.raw 2>&1 || true
  $G -q '^  \*\*\* ' .harness/cap-$nm.raw && { cat .harness/cap-$nm.raw >&3; die "$nm stopped (above)"; }
  mask < .harness/cap-$nm.raw > .r-$nm.new
  sed 's/^/  | /' .r-$nm.new | cut -c1-260
  local o e=0; o=$(python3 -I -B harness/chk09.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk09 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  $G -v '^ok \|^FAIL ' .harness/chk-$nm.out | sed 's/^/  chk09 /' || true
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; [ -n "${DEVCAPS:-}" ] && { echo "  (development: $nm's check failed, the run goes on)"; unpub="$unpub $nm"; } || die "$nm: its check failed (harness/chk09.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk09.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-11s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-11s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff its block in README.md against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }


alog() { cat ".harness/run/$1/access/access.log" 2> /dev/null || true; }

# ---- the captures --------------------------------------------------------------------------------------------------------------------
JSON='Content-Type: application/json'; MPT='Content-Type: application/merge-patch+json'; JPT='Content-Type: application/json-patch+json'
MX="--logging.level.org.springframework.web.servlet.mvc.method.annotation.ExceptionHandlerExceptionResolver=DEBUG"   # harness logging, never shipped
API=/api/v1/customers
KEYH='Idempotency-Key'          # the key header's name: sent only by specwire9.py's pause-key and the keyed companion's named requests
THREE="/v3/api-docs /v3/api-docs.yaml /v3/api-docs/swagger-config"
SPECF=after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json
FILTER=after/tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java
WEBM=tiffinbox-web/src/main/java/com/tiffinbox/web
BODIES=$J/bodies
INVALID='{"name":"","mealsPerDay":0,"pricePerMeal":0,"mealType":"X"}'
ck() { python3 -I -B harness/chk09.py "$@"; }

surefire() { local f; for f in "$1"/TEST-*.xml; do ck surefire "$f"; done; }
c_tests() { local p
  echo "== mvn -o clean package (tests on) on a copy of after/ (.harness/pkg), Docker reachable"
  guard "mvn package"
  copy after .harness/pkg; copy after .harness/twin; copy after .harness/tests
  bg "cd .harness/pkg && DOCKER_HOST=\"$DH\" $MV \"$AL\" clean package -pl tiffinbox-web -am" .harness/pkg.log
  echo "  mvn package exit $RE · Downloading/Downloaded from: $($G -cE 'Download(ing|ed) from ' .harness/pkg.log || true) · Results: $($G -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures' .harness/pkg.log | tail -1 | sed -E 's/^\[[A-Z]+\] //')"
  echo "== Surefire's XML, per class (package)"; surefire .harness/pkg/tiffinbox-web/target/surefire-reports
  echo "== the Docker-free twin: the same, DOCKER_HOST=unix:///nonexistent/docker.sock (.harness/twin)"
  guard "the Docker-free twin"
  bg "cd .harness/twin && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package -pl tiffinbox-web -am" .harness/twin.log
  echo "  mvn package (Docker-free) exit $RE · Downloading/Downloaded from: $($G -cE 'Download(ing|ed) from ' .harness/twin.log || true) · Results: $($G -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures' .harness/twin.log | tail -1 | sed -E 's/^\[[A-Z]+\] //')"
  echo "== Surefire's XML, per class (the twin)"; surefire .harness/twin/tiffinbox-web/target/surefire-reports
  echo "  the twin's OpenApiSpecTest line: $($G -m1 -E '^OpenApiSpecTest: ' .harness/twin.log | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g')"
  echo "== the new tests: the @Test lines the change adds (git diff 4725421 over the test sources, read off the trees)"
  for p in $(cd after && ls tiffinbox-web/src/test/java/com/tiffinbox/web/*.java); do
    n=$(diff before/$p after/$p | $G -cE '^> +@Test$' || true); [ "$n" = 0 ] || echo "  new @Test | $(basename $p .java) | $n | $(diff before/$p after/$p | $G -oE '^> +void [A-Za-z]+' | sed 's/^> *void //' | paste -sd, -)"; done
  echo "== mvn -o clean verify on a copy of after/ (.harness/tests): Surefire's tests, then the five ITs; 21280-21284 and 18881-18884 asserted free before"
  for p in 21280 21281 21282 21283 21284 18881 18882 18883 18884; do [ "$(listeners $p)" = 0 ] && [ -z "$(lsof -nP -iUDP:$p 2> /dev/null)" ] || die "$p is bound before verify"; done
  guard "mvn verify"
  : > .harness/tcps.txt
  ( while :; do dk ps --filter label=org.testcontainers=true --format '{{.Ports}}' >> .harness/tcps.txt 2> /dev/null; sleep 1; done ) & pollpid=$!
  bg "cd .harness/tests && DOCKER_HOST=\"$DH\" TESTCONTAINERS_RYUK_DISABLED=true $MV \"$AL\" clean verify -pl tiffinbox-web -am" .harness/verify.log
  kill $pollpid 2> /dev/null; wait $pollpid 2> /dev/null; pollpid=""
  local vre=$RE; offl .harness/pkg.log; offl .harness/twin.log; offl .harness/verify.log
  $G -q 'Timed out waiting' .harness/verify.log && echo "  an IT's wait TIMED OUT (S9.32: this run of record fails)"
  echo "  mvn verify exit $vre · Downloading/Downloaded from: 0 · Results: $($G -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures' .harness/verify.log | sed -E 's/^\[[A-Z]+\] //' | paste -sd'|' -)"
  echo "== Failsafe's XML, per class (the ITs)"; surefire .harness/tests/tiffinbox-web/target/surefire-reports-it
  $G -E '^IT BINDINGS ' .harness/verify.log | sort | sed 's/^/  /'
  echo "  the Elasticsearch IT's wait: $($G -cE 'Timed out waiting' .harness/verify.log || true) timed out (S9.32)"
  echo "  Testcontainers' containers while verify ran (docker ps Ports, beside, never the witness): $(tr ', ' '\n\n' < .harness/tcps.txt | $G -oE '^[0-9.]+:[0-9]+' | sort -u | paste -sd' ' -)"
  echo "  Testcontainers containers after: $(dk ps -aq --filter label=org.testcontainers=true | wc -l | tr -d ' ') · listeners on 21280-21284 after: $(for p in 21280 21281 21282 21283 21284; do listeners $p; done | paste -sd+ - | bc)"
  echo "== BOOT-INF/lib before -> after"
  for t in before after; do echo "  $t: $(ls .harness/$t/$XD/lib | wc -l | tr -d ' ') jars · $(ls .harness/$t/$XD/lib | $G -E '^(spring-boot-[0-9]|spring-core-|tomcat-embed-(core|el|websocket)-|jackson-databind-|postgresql-|springdoc-openapi-starter-webmvc-ui-|swagger-ui-|swagger-annotations-)' | sort | paste -sd' ' -)"; done
  diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G '^[<>]' | sed 's/^/  lib /'
  echo "  the jars' names moved before -> after: $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c '^[<>]' || true)"; }

MAPRX='^[[:space:]]*@(Get|Post|Patch|Put|Delete)Mapping'
WRX='^[[:space:]]*@(Post|Patch|Put|Delete)Mapping'
WMJ=c9-tiffinbox/tiffinbox-web/src/main/java
gcount() { git -C .. grep -cE "$MAPRX" "$1" -- "$WMJ" 2> /dev/null | awk -F: '{ s += $NF } END { print s + 0 }'; }
gdevm() { local f n=0; for f in $(git -C .. grep -lE '@Profile\("dev"\)' "$1" -- "$WMJ" 2> /dev/null | sed "s#^$1:##"); do n=$((n + $(git -C .. grep -cE "$MAPRX" "$1" -- "$f" 2> /dev/null | awk -F: '{ s += $NF } END { print s + 0 }'))); done; echo $n; }
c_census() { local n dm j f
  echo "== the handler methods on after/ (one flag start on 20983, H2, no harness: --management.endpoints.web.exposure.include=health,prometheus,mappings, once, never shipped)"
  P=20983; L=FLAGA; DB=h2; tb FLAGA 20983 h2 "" --management.endpoints.web.exposure.include=health,prometheus,mappings
  $CURL -s "$(B 20983)/actuator/mappings" > $J/map-after.json; $CURL -s "$(B 20983)/v3/api-docs" > $J/spec-flag.json
  ck mapjson after < $J/map-after.json
  tbstop FLAGA 20983
  echo "== the handler methods on before (U08's after; its own flag start on 20986, H2, no harness, the same flag once)"
  P=20986; L=FLAGB; TREE=before tb FLAGB 20986 h2 "" --management.endpoints.web.exposure.include=health,prometheus,mappings
  $CURL -s "$(B 20986)/actuator/mappings" > $J/map-before.json
  ck mapjson before < $J/map-before.json
  tbstop FLAGB 20986
  echo "== the handlers against the document's operations (the flag start's /v3/api-docs, read by python; servers removed)"
  ck opsmap $J/map-after.json $J/spec-flag.json
  n=$(cat $(find after/tiffinbox-web/src/main/java -name '*.java') | $G -cE "$MAPRX"); dm=0
  for f in $($G -lE '@Profile\("dev"\)' $(find after/tiffinbox-web/src/main/java -name '*.java') | sort); do dm=$((dm + $($G -cE "$MAPRX" "$f" || true))); done
  echo "  after/ (this unit's tree): mapping annotations $n · dev mappings $dm · default run $((n - dm)) · U08's commit 4725421: mapping annotations $(gcount 4725421) · dev mappings $(gdevm 4725421) · default run $(( $(gcount 4725421) - $(gdevm 4725421) ))"
  echo "== flag 3, part (1): the {name} operations of after/'s served document (python over paths), each asked for Nobody on the wire in the types capture"
  ck nameset $J/spec-flag.json
  echo "== flag 3, part (2): the keyed operations - the filter's GUARDED table (read off the source)"
  ck keyset $FILTER
  echo "== flag 3, part (3): the union, and the responses each operation documents on after/ (the flag start's document)"
  ck union $J/spec-flag.json $FILTER
  echo "== flag 2: every problem TiffinBox constructs (the construction sites in after/'s main sources, file:line), typed or about:blank"
  for f in $(cd after && $G -lE 'ProblemDetail\.forStatus|problem\(HttpStatus|refuse\(HttpStatus|new ResponseStatusException|answer\(req, res, op' $WEBM/*.java | sort); do
    $G -nE 'ProblemDetail\.forStatus|problem\(HttpStatus\.[A-Z_]+|refuse\(HttpStatus\.[A-Z_]+|new ResponseStatusException\(HttpStatus\.[A-Z_]+|answer\(req, res, op, HttpStatus\.[A-Z_]+' after/$f | sed -E 's/^([0-9]+):[[:space:]]*/\1 /' | while read -r ln rest; do
      st=$(printf '%s' "$rest" | $G -oE 'HttpStatus\.[A-Z_]+' | head -1 | sed 's/HttpStatus\.//')
      ty=about:blank; case "$(basename $f)" in IdempotencyKeyFilter.java) printf '%s' "$rest" | $G -qE ', (MISSING|MALFORMED|OUTSTANDING|REUSED),' && ty=$(printf '%s' "$rest" | $G -oE '(MISSING|MALFORMED|OUTSTANDING|REUSED)') ;; TiffinBoxErrors.java) ty=CUSTOMER_NOT_FOUND ;; esac
      [ -n "$st" ] || st=-; echo "  problem | $(basename $f):$ln | ${st} | ${ty}"; done; done
  echo "== flag 15: the write handler methods (the anchored grep of @Post|@Patch|@Put|@DeleteMapping over the default-run classes) beside the document's write operations"
  n=0; for f in $(find after/tiffinbox-web/src/main/java -name '*.java' | sort); do $G -qE '@Profile\("dev"\)' "$f" && continue; c=$($G -cE "$WRX" "$f" || true); [ "$c" = 0 ] || { echo "  write handler | $(basename $f .java) | $c"; n=$((n + c)); }; done
  echo "  write handler methods (default run): $n · the document's write operations: $(python3 -I -c 'import json,sys; d = json.load(open(sys.argv[1])); print(sum(1 for v in d["paths"].values() for m in v if m != "get"))' $J/spec-flag.json)"
  echo "== the jars: entries named probe/ (unzip -l; the harness's classes never in the jar)"
  for t in before after; do j=.harness/$t/tiffinbox-web/target/tiffinbox-web-1.0.0.jar; echo "  $t's jar: $(unzip -l $j | awk '{ print $4 }' | $G -cE '(^|/)probe/' || true) entries named probe/"; done
  cp .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar $J/plant.jar; python3 -I -c 'import sys,zipfile; z = zipfile.ZipFile(sys.argv[1], "a"); z.write(sys.argv[2], "probe/Http.class"); z.close()' $J/plant.jar .harness/hc/probe/Http.class
  echo "  plant (one probe/ class added to a scratch copy of the jar): $(unzip -l $J/plant.jar | awk '{ print $4 }' | $G -cE '(^|/)probe/' || true) entries named probe/ - the check FAILS on it (the harness's plant)"; rm -f $J/plant.jar; }

docs3() { local side=$1 a
  for a in $THREE; do ask "a-$side-$(echo $a | tr '/.' '--' | sed 's/^-//')" GET $a; done
  $CURL -s "$(B $P)/v3/api-docs" > $J/spec-$side.raw
  ck docsum $J/spec-$side.raw
  python3 -I -c 'import io,json,sys; d = json.load(open(sys.argv[1], encoding="utf-8")); d.pop("servers", None); b = io.StringIO(); json.dump(d, b, indent=2, ensure_ascii=False); b.write("\n"); open(sys.argv[2], "w", encoding="utf-8").write(b.getvalue())' $J/spec-$side.raw $J/spec-$side.json
  echo "  $side: the document with servers removed (the fixed rule) md5 $(md5 -q $J/spec-$side.json) · the socket's servers $(ck specmask < $J/spec-$side.raw)"; }
c_after() { local d
  for d in pg h2; do
    echo "== $d: the three addresses and the document on after/ (no harness: the document is TiffinBox's alone)"
    if [ $d = pg ]; then pgfresh; DB=pg; P=20982; L=AP; tb AP 20982 pg ""; else DB=h2; P=20980; L=AH; tb AH 20980 h2 ""; fi
    echo "  which database answered (Flyway's line): $($G -m1 -oE 'Database: [^ ]+ \([^)]*\)' .harness/run/$L/jvm.log | sed -E 's/jdbc:[a-z0-9]+:[^ ]*/<url>/')"
    health
    NOWIT=1 docs3 $d
    tbstop $L $P
  done
  echo "  the document on PostgreSQL and on H2, servers removed: $(cmp -s $J/spec-pg.json $J/spec-h2.json && echo byte-identical || echo DIFFERENT) · = the committed file: pg $(cmp -s $J/spec-pg.json $SPECF && echo byte-identical || echo DIFFERENT) · h2 $(cmp -s $J/spec-h2.json $SPECF && echo byte-identical || echo DIFFERENT)"; }

# the five Nobody requests (flag 3 part 1) and R2's four bodies, on one harness-free start; the bodies filed under $BODIES/<side>-<name>.json
nobody() { local side=$1
  mkdir -p $BODIES
  ask "nb-$side-old" GET /customers/Nobody; cp $J/$DB-nb-$side-old.b $BODIES/$side-nf-customers.json
  ask "nb-$side-public" GET $API/Nobody; cp $J/$DB-nb-$side-public.b $BODIES/$side-nf-public.json
  ask "nb-$side-patch" PATCH $API/Nobody -H "$MPT" --data-binary '{"mealsPerDay":2}'; cp $J/$DB-nb-$side-patch.b $BODIES/$side-nf-patch.json
  ask "nb-$side-pause" POST "$API/Nobody/pauses?days=1"
  ask "nb-$side-pauseget" GET $API/Nobody/pauses/1; cp $J/$DB-nb-$side-pauseget.b $BODIES/$side-pauseget-404.json
  echo "  (the pause POST without its key is the filter's 400 before the route runs: its CustomerNotFound needs a key - the keyed companion sends it)"
  ask "r2-$side-create" POST /customers -H "$JSON" --data-binary "$INVALID"; cp $J/$DB-r2-$side-create.b $BODIES/$side-r2-create.json
  ask "r2-$side-patch" PATCH $API/Ravi -H "$MPT" --data-binary '{"mealsPerDay":0}'; cp $J/$DB-r2-$side-patch.b $BODIES/$side-r2-patch.json
  ask "r2-$side-shutdown" POST /shutdown; cp $J/$DB-r2-$side-shutdown.b $BODIES/$side-r2-shutdown.json; }
c_none() {
  echo "== h2: the three addresses, the document and the Nobody answers on before (U08's after, 20986, no harness)"
  DB=h2b; P=20986; L=NB; TREE=before tb NB 20986 h2 ""
  health; NOWIT=1 docs3 before; NOWIT=1 nobody before
  tbstop NB 20986
  echo "  U08's values block: $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit08/README.md | $G -oE 'errors_documented=[0-9]+ key_named=[0-9]+' | head -1)"; }

c_blanket() { local f=$WEBM/TiffinBoxErrors.java
  echo "== the plant (the harness's): a scratch mirror of before (.harness/blanket) + ONE line on the advice's handler - the S2 probe's t09-plant.diff as the draft"
  echo "  the probe's draft: $PK/instruments/t09-plant.diff md5 $(md5 -q "$PK/instruments/t09-plant.diff") ($(awk '$2 ~ /t09-plant\.diff$/ { print $1 }' "$PK/MD5SUMS") in its MD5SUMS)"
  rm -rf .harness/blanket; copy before .harness/blanket
  sed -i '' 's/^    ProblemDetail notFound(CustomerNotFound e) {$/    @org.springframework.web.bind.annotation.ResponseStatus(HttpStatus.NOT_FOUND)   \/\/ the harness'"'"'s plant (blanket)\
    ProblemDetail notFound(CustomerNotFound e) {/' .harness/blanket/$f
  diff before/$f .harness/blanket/$f | $G '^[<>]' | sed 's/^/  diff: /'
  guard "the blanket build"
  bg "cd .harness/blanket && $MV -DskipTests clean package -pl tiffinbox-web -am" .harness/build-blanket.log
  [ "$RE" = 0 ] || die "the blanket mirror did not build"; offl .harness/build-blanket.log
  bg "cd .harness/blanket && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-blanket.log
  DB=h2m; P=20987; L=BL; TREE=blanket tb BL 20987 h2 ""
  $CURL -s "$(B 20987)/v3/api-docs" > $J/spec-blanket.raw
  ck docsum $J/spec-blanket.raw
  ck count404 $J/spec-blanket.raw
  echo "== the same mirror's WIRE beside its document (the plant changes the document, not the answers)"
  ask "bl-revenue" GET /revenue; ask "bl-kitchen" GET /kitchen; ask "bl-nobody" GET /customers/Nobody
  tbstop BL 20987
  [ "$(listeners 20987)" = 0 ] || die "20987 still bound after the blanket mirror"
  echo "  the probe's figure, to compare (1 run, on its own tree, NOTES §6): 13 of 13, md5 $(awk '$2 ~ /pd\/apidocs\.b$/ { print $1 }' "$PK/MD5SUMS" | head -1 | cut -c1-8) - not asserted"; }

mirror() { local nm=$1
  guard "the $nm mirror's build"
  bg "cd .harness/$nm && $MV -DskipTests clean package -pl tiffinbox-web -am" .harness/build-$nm.log
  [ "$RE" = 0 ] || { tail -20 .harness/build-$nm.log | mask >&3; die "the $nm mirror did not build"; }; offl .harness/build-$nm.log
  bg "cd .harness/$nm && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$nm.log
  [ "$RE" = 0 ] || die "the $nm mirror's jar did not extract"; }
c_perop() { local k
  echo "== the response codes of the thirteen operations, before (U08's after, the none capture's document) and after/ (the after capture's H2 document)"
  ck codetable $J/spec-before.raw $J/spec-h2.raw
  echo "== flag 9 (a)-(c): the two documents with info, servers, every added response and ProblemDetail removed (python3 -I harness/chk09.py strip)"
  ck strip $J/spec-before.raw $J/spec-h2.raw; echo "  strip exit $?"
  echo "  swagger-config: before $(tr -d '\r' < $J/h2b-a-before-v3-api-docs-swagger-config.b | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' | md5 -q) · after $(tr -d '\r' < $J/h2-a-h2-v3-api-docs-swagger-config.b | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' | md5 -q) (the port masked)"
  echo "  the YAML: before $(wc -l < $J/h2b-a-before-v3-api-docs-yaml.b | tr -d ' ') lines · after $(wc -l < $J/h2-a-h2-v3-api-docs-yaml.b | tr -d ' ') lines · removed lines $(diff <(sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' $J/h2b-a-before-v3-api-docs-yaml.b) <(sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' $J/h2-a-h2-v3-api-docs-yaml.b) | $G -c '^<' || true)"
  echo "== the plants (scratch copies of after/'s document, one edit each - the harness's plants)"
  for k in description schema securitySchemes; do ck plantdoc $k $J/spec-h2.raw $J/plant-$k.raw
    ck strip $J/spec-before.raw $J/plant-$k.raw > $J/plant-$k.out 2>&1; echo "  plant $k: strip exit $? · $($G -E '^  MOVED member' $J/plant-$k.out | head -2 | paste -sd' ' - | sed 's/^ *//')"; done
  : > $J/empty.raw; ck strip $J/spec-before.raw $J/empty.raw > $J/plant-empty.out 2>&1; echo "  plant empty input: strip exit $? · $(head -1 $J/plant-empty.out | sed 's/^ *//')"
  echo "== the mechanism (flag 4): A (@ApiResponse on the handler methods) is after/'s; B, measured, not shipped: a scratch mirror of before (.harness/loser) + one package-private class (harness/src/mirror/TiffinBoxErrorDocs.java: an OperationCustomizer keyed by handler method, and the ProblemDetail schema)"
  rm -rf .harness/loser; copy before .harness/loser
  cp -v harness/src/mirror/TiffinBoxErrorDocs.java .harness/loser/$WEBM/TiffinBoxErrorDocs.java | sed "s#$U#…#g; s/^/  cp: /"
  mirror loser
  DB=h2m; P=20987; L=LO; TREE=loser tb LO 20987 h2 ""
  $CURL -s "$(B 20987)/v3/api-docs" > $J/spec-loser.raw
  tbstop LO 20987
  [ "$(listeners 20987)" = 0 ] || die "20987 still bound after the loser mirror"
  ck abdiff $J/spec-h2.raw $J/spec-loser.raw; echo "  abdiff exit $?"; }

c_shape() {
  echo "== flag 6: every example in after/'s document against the wire bodies this run filed ($BODIES: the types capture's after-side bodies, the keyed companion's, and U04's filed outstanding body)"
  ls $BODIES | sed 's/^/  filed: /'
  rm -rf $J/ex-bodies; mkdir -p $J/ex-bodies; for f in $BODIES/after-nf-*.json $BODIES/after-pauseget-404.json $BODIES/key-*.json; do cp $f $J/ex-bodies/; done
  echo "  the bodies the documented problems answer with (R2's create, PATCH and shutdown bodies are not among them: no documented response is theirs): $(ls $J/ex-bodies | sed 's/\.json$//' | paste -sd' ' -)"
  ck examples $J/spec-h2.raw $J/ex-bodies; echo "  examples exit $?"
  echo "== flag 5: the ProblemDetail schema's members beside each filed body's keys"
  ck schema $J/spec-h2.raw $J/ex-bodies; echo "  schema exit $?"
  echo "== the plants (scratch copies - the harness's)"
  python3 -I -c 'import json,sys; d = json.load(open(sys.argv[1])); p = d["components"]["schemas"]["ProblemDetail"]["properties"]; p["details"] = p.pop("detail"); json.dump(d, open(sys.argv[2], "w"))' $J/spec-h2.raw $J/shape-plant.raw
  echo "  plant rename (detail -> details in the schema): $(ck schema $J/shape-plant.raw $J/ex-bodies | $G 'the wire sends' | sed 's/^ *//')"
  python3 -I -c 'import json,sys; d = json.load(open(sys.argv[1])); r = d["paths"]["/api/v1/customers/{name}"]["get"]["responses"]["404"]["content"]["application/problem+json"]["examples"]; e = next(iter(r.values())); e["value"]["status"] += 1; json.dump(d, open(sys.argv[2], "w"))' $J/spec-h2.raw $J/shape-plant2.raw
  ck examples $J/shape-plant2.raw $J/ex-bodies > $J/shape-plant2.out 2>&1; echo "  plant status one off: examples exit $? · $($G 'NO FILED BODY' $J/shape-plant2.out | head -1 | sed 's/^ *//')"
  rm -rf $J/ex-empty; mkdir -p $J/ex-empty; ck schema $J/spec-h2.raw $J/ex-empty > $J/shape-empty.out 2>&1; echo "  plant empty input: schema exit $? · $(head -1 $J/shape-empty.out | sed 's/^ *//')"; }

c_types() { local f=$WEBM/TiffinBoxErrors.java
  echo "== h2: the Nobody answers and R2's bodies on after/ (20980, no harness, a fresh database)"
  DB=h2; P=20980; L=TY; tb TY 20980 h2 ""
  health; NOWIT=1 nobody after
  ask "ravi-after" GET $API/Ravi; cp $J/h2-ravi-after.b $J/ravi-after.b
  tbstop TY 20980
  echo "== S9.37: the CustomerNotFound bodies, before and after (the none capture's bodies beside this capture's)"
  ck bodydiff $BODIES before after
  echo "== the keyed companion (harness-joined, 20980, its own JVM, a fresh database): the key's problems from the wire"
  DB=h2; P=20980; L=TK; tb TK 20980 h2 "$U/.harness/hc"
  health
  echo "  the second client before: count $(count) · keys $(keyrows)"
  ask "key-missing" POST "$API/Ravi/pauses?days=1"; cp $J/h2-key-missing.b $BODIES/key-missing.json
  ask "key-malformed" POST "$API/Ravi/pauses?days=1" -H "$KEYH: k-unquoted"; cp $J/h2-key-malformed.b $BODIES/key-malformed.json
  ask "key-nobody" POST "$API/Nobody/pauses?days=1" -H "$KEYH: \"k-nobody-r$RUNNO\""; cp $J/h2-key-nobody.b $BODIES/after-nf-pause.json
  echo "  the second client after the keyed Nobody POST: keys $(keyrows) (the error answer deleted the claim)"
  ask "key-reused-1" POST "$API/Ravi/pauses?days=1" -H "$KEYH: \"k-reused-r$RUNNO\""
  ask "key-reused-2" POST "$API/Ravi/pauses?days=2" -H "$KEYH: \"k-reused-r$RUNNO\""; cp $J/h2-key-reused-2.b $BODIES/key-reused.json
  echo "  the second client after the reused pair: count $(count) · keys $(keyrows)"
  echo "  the harness's plant row: an in-flight claim (status 0, claimed now) under a new key with the reused request's fingerprint, written by the second client (POST /probe/u09/inflight/..., the harness's route): $($CURL -s -X POST "$(B $P)/probe/u09/inflight/k-inflight-r$RUNNO/k-reused-r$RUNNO")"
  ask "key-outstanding" POST "$API/Ravi/pauses?days=1" -H "$KEYH: \"k-inflight-r$RUNNO\""; cp $J/h2-key-outstanding.b $BODIES/key-outstanding.json
  echo "  the second client after the outstanding request: count $(count) · keys $(keyrows) (the reused pair's row and the harness's in-flight row)"
  tbstop TK 20980
  echo "  unit 04 measured the outstanding answer too (../c9-unit04/README.md:$($G -n 'the duplicate answers `409`, typed `…-outstanding`' ../c9-unit04/README.md | head -1 | cut -d: -f1)); this run sends it itself (the filed body above)"
  echo "== flag 14: RFC 9457 section 4.2.1's SHOULD, from the filed copy only ($RFC, md5 $(md5 -q "$RFC"), lines 498-515)"
  sed -n '498,515p' "$RFC" | $G -n 'SHOULD' | sed 's/^/  RFC :497+/'
  ck should $BODIES
  echo "== flag 11: the type, and RFC 4151 (a NOTE)"
  echo "  type $(ck typeconst after/$f) · tiffinbox.example stands where your own domain goes; the scheme names a tagging entity and a date, no host (the filed RFC 9457 copy, line 282, shows a tag: type: $(sed -n '282p' "$RFC" | sed 's/^ *//'))"
  echo "  the folder holds: $(ls "$(dirname "$RFC")" | paste -sd' ' -) - RFC 4151 and RFC 2606 are not filed: RED #23's reading is RED's, not read here"
  echo "== the plant: the setType line reverted on a scratch mirror of after/ (.harness/revert) -> the k new tests"
  rm -rf .harness/revert; copy after .harness/revert
  sed -i '' '/problem\.setType(CUSTOMER_NOT_FOUND);/d' .harness/revert/$f
  diff after/$f .harness/revert/$f | $G '^[<>]' | sed 's/^/  diff: /'
  guard "the revert plant's tests"
  bg "cd .harness/revert && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean test -Dtest=TiffinBoxWebTest,CustomerReadsTest,CustomerPatchesTest,IdempotencyKeyTest -Dsurefire.failIfNoSpecifiedTests=false -pl tiffinbox-web -am" .harness/revert.log
  offl .harness/revert.log
  echo "  mvn test exit $RE · $($G -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures' .harness/revert.log | tail -1 | sed -E 's/^\[[A-Z]+\] //')"
  $G -oE '^\[ERROR\] +[A-Za-z]+Test\.[A-Za-z]+:[0-9]+' .harness/revert.log | sed -E 's/^\[ERROR\] +/  failed: /; s/:[0-9]+$//' | sort -u; }

c_committed() { local k f
  echo "== (i) the committed file: $SPECF"
  echo "  bytes $(wc -c < $SPECF | tr -d ' ') (wc -c) · md5 $(md5 -q $SPECF) · servers member: $(python3 -I -c 'import json,sys; print("present" if "servers" in json.load(open(sys.argv[1])) else "absent")' $SPECF) · U08's file $(wc -c < before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tr -d ' ') B"
  echo "  the fixed rule (python3 -I, json.dump(indent=2, ensure_ascii=False) + a final newline) re-applied to the file: $(python3 -I -c 'import io,json,sys; d = json.load(open(sys.argv[1], encoding="utf-8")); b = io.StringIO(); json.dump(d, b, indent=2, ensure_ascii=False); b.write("\n"); print("byte-identical" if b.getvalue() == open(sys.argv[1], encoding="utf-8").read() else "DIFFERENT")' $SPECF)"
  echo "  the file against the served document, servers removed (the after capture's python, live): pg $(cmp -s $J/spec-pg.json $SPECF && echo byte-identical || echo DIFFERENT) · h2 $(cmp -s $J/spec-h2.json $SPECF && echo byte-identical || echo DIFFERENT)"
  echo "  its diff against U08's (= 4725421's) file: $(diff before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json $SPECF | $G -c '^>' || true) lines added · $(diff before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json $SPECF | $G -c '^<' || true) removed"
  echo "  the file with the added responses and ProblemDetail removed: md5 $(ck unadd before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json $SPECF) · U08's file md5 $(md5 -q before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json)"
  echo "  the file: securitySchemes $(python3 -I -c 'import json,sys; d = json.load(open(sys.argv[1])); print("present" if "securitySchemes" in d.get("components", {}) else "absent", "· security", "present" if "security" in d else "absent")' $SPECF)"
  echo "== (ii) OpenApiSpecTest in the tests capture's package and its Docker-free twin (Surefire's XML)"
  ck surefire .harness/pkg/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.OpenApiSpecTest.xml | sed 's/^/  package:/'
  ck surefire .harness/twin/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.OpenApiSpecTest.xml | sed 's/^/  twin:/'
  echo "  MockMvc's servers, as the test printed it: $($G -m1 -E '^OpenApiSpecTest: ' .harness/pkg.log | sed -E 's/^OpenApiSpecTest: servers served //')"
  for k in stale file code moved; do
    rm -rf .harness/drift-$k; copy after .harness/drift-$k
    case $k in
      stale) f=tiffinbox-web/src/test/resources/openapi/tiffinbox.json; cp -v before/$f .harness/drift-$k/$f | sed "s#$U#…#g; s/^/  cp: /"
        echo "== (iii) the STALE file (scratch mirror .harness/drift-stale: the shipped code with U08's file, no other change)" ;;
      file) f=tiffinbox-web/src/test/resources/openapi/tiffinbox.json
        python3 -I -c 'import re,sys; p = sys.argv[1]; s = open(p, encoding="utf-8").read(); a = "\"required\": [\n          \"mealType\",\n          \"name\"\n        ]"; assert s.count(a) == 1, s.count(a); open(p, "w", encoding="utf-8").write(s.replace(a, "\"required\": [\n          \"mealType\",\n          \"mealsPerDay\",\n          \"name\",\n          \"pricePerMeal\"\n        ]"))' .harness/drift-$k/$f
        echo "== (iv) a drifted copy of the file (scratch mirror .harness/drift-file, one edit: required widened to four)" ;;
      code) f=tiffinbox-core/src/main/java/com/tiffinbox/Customer.java
        sed -i '' 's/@NotBlank @Size(max = 60) String name/@NotBlank @Size(max = 61) String name/' .harness/drift-$k/$f
        echo "== (v) drifted code (scratch mirror .harness/drift-code, one sed: the record's @Size(max = 60) -> 61)" ;;
      moved) f=$WEBM/CustomerReads.java
        python3 -I -c 'import sys; p = sys.argv[1]; s = open(p, encoding="utf-8").read(); a = "responseCode = \"404\""; assert s.count(a) == 1; open(p, "w", encoding="utf-8").write(s.replace(a, "responseCode = \"410\""))' .harness/drift-$k/$f
        echo "== (vi) this unit's drift: the public read's documented four-oh-four moved to another code in code (scratch mirror .harness/drift-moved, one edit)" ;;
    esac
    diff after/$f .harness/drift-$k/$f | $G '^[<>]' | sed 's/^/  diff: /' | cut -c1-160
    guard "the drift-$k test"
    bg "cd .harness/drift-$k && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean test -Dtest=OpenApiSpecTest -Dsurefire.failIfNoSpecifiedTests=false -pl tiffinbox-web -am" .harness/drift-$k.log
    offl .harness/drift-$k.log
    echo "  mvn test -Dtest=OpenApiSpecTest exit $RE · $($G -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures' .harness/drift-$k.log | tail -1 | sed -E 's/^\[[A-Z]+\] //')"
    echo "  its FAIL line: $($G -m1 -oE 'theServedDocumentIsTheCommittedOne.*FAILURE!' .harness/drift-$k.log | sed -E 's/Time elapsed: [0-9.]+ s/Time elapsed: <t>/')"
    echo "  the report names: $(ck rnames .harness/drift-$k/tiffinbox-web/target/surefire-reports/com.tiffinbox.web.OpenApiSpecTest.txt)"
  done
  echo "== (vii) what the test does not catch: on the shipped after/, the test PASSED (ii) in the same run in which diff prints its rows"
  echo "  the test: code against the committed file, never the document against the wire; it reads no \$.type (the k new tests do)"; }

wire() { local dir=$J/wire-$DB
  rm -rf $dir; mkdir -p $dir
  echo "  the document diff reads: the harness-free start's (.harness/work/spec-$DB.json, servers removed; md5 $(md5 -q $J/spec-$DB.json))"
  echo "  the second client before: count $(count) · keys $(keyrows) · Ravi $(row Ravi)"
  echo "== $DB: python3 -I harness/specwire9.py send $P (BLUE_RUN=$RUNNO; the request set is BLUE's, its names its own; each request and answer filed as JSON)"
  (cd $J && BLUE_RUN=$RUNNO python3 -I "$U/harness/specwire9.py" send $P wire-$DB) 2>&1 | sed 's/^/  sent: /'
  ck pairs $dir
  echo "== $DB: specwire9.py diff spec wire (a: no third argument - this tree's own census)"
  python3 -I harness/specwire9.py diff $J/spec-$DB.json $dir 2>&1 | sed 's/^/  (a) /'; echo "  (a) exit ${PIPESTATUS[0]}"
  echo "  the second client after: count $(count) · keys $(keyrows) · Ravi $(row Ravi)"
  for n in Blue1 Blue2 Blue3 Blue4; do echo "  row ${n}r$RUNNO: $(row ${n}r$RUNNO)"; done; }
c_diff() { DB=h2; P=20980; L=DH2; tb DH2 20980 h2 "$U/.harness/hc" "$MX"
  echo "== h2: the spec against the wire on H2 (TiffinBox after/ on 20980, the harness joined, a fresh database)"
  health
  local a; for a in $THREE /nowhere; do ask "w-$(echo $a | tr '/.' '--' | sed 's/^-//')" GET $a; done
  ask "w-nobody" GET $API/Nobody
  wire
  echo "== h2: diff (b): the probe's filed generated source as the third argument - U10's tool's output, read, not produced here"
  python3 -I harness/specwire9.py diff $J/spec-h2.json $J/wire-h2 "$PK/captures/generated-sources/hi" 2>&1 | sed 's/^/  (b) /'; echo "  (b) exit ${PIPESTATUS[0]}"
  echo "== the plant: the document with mealType renamed meal_type (one sed), diff (a) and (b)"
  sed 's/"mealType"/"meal_type"/g' $J/spec-h2.json > $J/spec-plant.json
  python3 -I harness/specwire9.py diff $J/spec-plant.json $J/wire-h2 2>&1 | $G -E '^(KINDS|DISAGREEMENTS)' | sed 's/^/  plant (a) /'
  python3 -I harness/specwire9.py diff $J/spec-plant.json $J/wire-h2 "$PK/captures/generated-sources/hi" 2>&1 | $G -E '^(KINDS|DISAGREEMENTS)' | sed 's/^/  plant (b) /'
  rm -rf $J/wire-empty; mkdir -p $J/wire-empty
  python3 -I harness/specwire9.py diff $J/spec-h2.json $J/wire-empty 2>&1 | sed 's/^/  empty: /'; echo "  empty: exit ${PIPESTATUS[0]}"
  echo "  U08's values block (before's rows, re-measured by U08 on this anchor's before): $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit08/README.md | $G -E '^diff: ' | $G -oE 'kinds_b=[0-9]+ rows_b=[0-9]+ kinds_a=[0-9]+ rows_a=[0-9]+')"
  tbstop DH2 20980; }

c_scheme() {
  echo "== the harness's COPY of the spec (probe.u09.SchemeCopy, a document customizer: springdoc's $(unzip -l "$M2/org/springdoc/springdoc-openapi-starter-common/3.2.1/springdoc-openapi-starter-common-3.2.1.jar" | awk '{ print $4 }' | $G -E 'customizers/OpenApiCustomizer\.class$')) on after/'s jar, 20985, harness-joined"
  echo "  the S2 probe's draft, read: $PK/instruments/src/probe/DeclaredScheme.java md5 $(md5 -q "$PK/instruments/src/probe/DeclaredScheme.java") (a second OpenAPI bean; not run on this tree - filed under What differed)"
  DB=h2s; P=20985; L=SC; SRC=probe.Witness,probe.Http,probe.u09.SchemeCopy tb SC 20985 h2 "$U/.harness/hc"
  health
  $CURL -s "$(B 20985)/v3/api-docs" > $J/spec-scheme.raw
  ck docsum $J/spec-scheme.raw | $G -E '^  doc: '
  echo "  the copy's scheme: $(python3 -I -c 'import json,sys; d = json.load(open(sys.argv[1])); print(json.dumps(d["components"].get("securitySchemes")), "· security", json.dumps(d.get("security")))' $J/spec-scheme.raw)"
  ask "sc-anon" GET $API/Ravi
  ask "sc-bearer" GET $API/Ravi -H 'Authorization: Bearer not-a-token'
  echo "  the bodies: anonymous $(md5 -q $J/h2s-sc-anon.b) · bearer $(md5 -q $J/h2s-sc-bearer.b) · after/'s own (the types capture, 20980, no harness) $(md5 -q $J/ravi-after.b) · the probe's anon.b (the figure to compare) $(awk '$2 ~ /sec\/anon\.b$/ { print $1 }' "$PK/MD5SUMS")"
  echo "  the access log's lines: $(alog SC | $G -E "^GET $API/Ravi" | paste -sd'|' -)"
  echo "  every request of the copy's JVM a GET (the access log): $(alog SC | awk '{ print $1 }' | sort | uniq -c | awk '{ print $2, $1 }' | paste -sd' ' -)"
  tbstop SC 20985
  echo "  the shipped document beside it (the after capture's H2 document): $(ck docsum $J/spec-h2.raw | $G -oE 'securitySchemes [a-z]+ · security [a-z]+')"
  echo "== the S2 probe's own probe.DeclaredScheme (a second OpenAPI bean), compiled from its filed source (read, not copied) and joined to after/'s jar, 20985 (1/1)"
  rm -rf .harness/hc-ds; bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc-ds -cp \"$CPA\" \"$PK/instruments/src/probe/DeclaredScheme.java\"" .harness/javac-ds.log
  echo "  javac exit $RE"
  P=20985; L=DS; DB=h2s; guard "the probe's DeclaredScheme start"
  rm -rf .harness/run/DS; mkdir -p .harness/run/DS/secrets/tiffinbox; (umask 077 && openssl rand -hex 16 > .harness/run/DS/secrets/tiffinbox/shutdown-token)
  (cd .harness/run/DS && exec perl -e '$SIG{INT}="DEFAULT"; alarm 120; exec @ARGV' java $JL -cp "$U/.harness/hc-ds:$U/.harness/after/$XD/tiffinbox-web-1.0.0.jar:$U/.harness/after/$XD/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=20985 --spring.main.sources=probe.DeclaredScheme > jvm.log 2>&1) &
  local dp=$! i=0; PIDS="$PIDS $dp"
  while kill -0 $dp 2> /dev/null && ! $G -q 'Started TiffinBox' .harness/run/DS/jvm.log; do i=$((i + 1)); [ $i -lt 900 ] || break; sleep 0.1; done
  if $G -q 'Started TiffinBox' .harness/run/DS/jvm.log; then echo "  the start: Started (two OpenAPI beans start)"; $CURL -s "$(B 20985)/v3/api-docs" > $J/spec-ds.raw; echo "  its document: $(ck docsum $J/spec-ds.raw | $G -E '^  doc: ' | sed 's/^  doc: //')"; echo "$dp" > .harness/run/DS/pid; tbstop DS 20985
  else wait $dp 2> /dev/null; echo "  the start: no Started line - its last lines:"; $G -E 'APPLICATION FAILED TO START|required a single bean|^[[:space:]]+- [A-Za-z]+: defined by method' .harness/run/DS/jvm.log | head -4 | cut -c1-200 | sed 's/^[[:space:]]*/    /'; fi
  PIDS=$(echo " $PIDS " | sed "s/ $dp / /g")
  [ "$(listeners 20985)" = 0 ] || die "20985 still bound after the probe's DeclaredScheme start"; }

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
c_moved() { echo "== U08's fourteen requests and the census's Nobody requests, on before (20986) and after/ (20980), H2, each its own JVM, no harness; bodies hashed (and sized) with Boot's /error timestamp and any port masked"
  movedside before 20986; movedside after 20980; }
c_seven() { local side tree port i
  echo "== the seven (c5-unit11/curlset.sh, no key header), each tree its own JVM, H2, no harness: the expected $S466"
  for side in before after; do [ $side = before ] && port=20986 || port=20980
    P=$port; L=seven-$side; DB=h2; TREE=$side tb seven-$side $port h2 ""
    sh $CURLSET $port .harness/run/seven-$side/secrets/tiffinbox/shutdown-token > $J/seven-$side.txt 2>&1
    i=0; while kill -0 "$(cat .harness/run/seven-$side/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 400 ] || die "seven-$side: the seven's POST /shutdown did not stop it"; sleep 0.05; done
    echo "  $side: the seven's requests (the access log, a harness-free start): $(alog seven-$side | awk '{ print $1, $2, $3 }' | paste -sd'|' -)"
    tbstop seven-$side $port
    echo "  $side: the seven $(md5 -q $J/seven-$side.txt) ($(wc -l < $J/seven-$side.txt | tr -d ' ') lines)"; done
  echo "  before -> after/: $(cmp -s $J/seven-before.txt $J/seven-after.txt && echo equal || echo DIFFER)"; }
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
  echo "== the old surface by count (U08's reader, copied), each tree its own JVM, H2, no harness: the expected $U4SURF"
  for side in before after; do [ $side = before ] && port=20986 || port=20980
    P=$port; L=surface-$side; DB=h2; TREE=$side tb surface-$side $port h2 ""
    oldsurface2 $port $J/surface-$side.txt
    tbstop surface-$side $port
    echo "  $side: the old surface $(md5 -q $J/surface-$side.txt) ($($G -c '^== ' $J/surface-$side.txt) requests, $(wc -l < $J/surface-$side.txt | tr -d ' ') lines)"; done
  echo "  before -> after/: $(cmp -s $J/surface-before.txt $J/surface-after.txt && echo equal || echo DIFFER)"
  diff $J/surface-before.txt $J/surface-after.txt | sed 's/^/    moved: /'
  echo "== the self-test (S9.14, the harness's plant - LABELLED, not a finding about TiffinBox): a ShallowEtagHeaderFilter on /* (probe.Etag, U08's copy), after/, on 20984"
  P=20984; L=seven-etag; SRC=probe.Etag tb seven-etag 20984 h2 "$U/.harness/hc"
  sh $CURLSET 20984 .harness/run/seven-etag/secrets/tiffinbox/shutdown-token > $J/seven-etag.txt 2>&1
  i=0; while kill -0 "$(cat .harness/run/seven-etag/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 400 ] || die "seven-etag did not stop"; sleep 0.05; done; tbstop seven-etag 20984
  P=20984; L=surface-etag; SRC=probe.Etag tb surface-etag 20984 h2 "$U/.harness/hc"; oldsurface2 20984 $J/surface-etag.txt; tbstop surface-etag 20984
  echo "  planted: the seven $(md5 -q $J/seven-etag.txt) (unchanged: $(cmp -s $J/seven-etag.txt $J/seven-after.txt && echo yes || echo NO)) · the old surface $(md5 -q $J/surface-etag.txt) (moved: $(cmp -s $J/surface-etag.txt $J/surface-after.txt && echo NO || echo yes)) · the feed's line: $($G '^== GET /customers/feed' $J/surface-etag.txt | sed -E 's/^== //')"
  echo "== the wide plant (the harness's, 1/1): a scratch mirror of after/ (.harness/wide) with a setType on /shutdown's 403 - the wider reading of \"all routes\" - and the seven on it (20987)"
  rm -rf .harness/wide; copy after .harness/wide
  python3 -I -c 'import sys; p = sys.argv[1]; s = open(p, encoding="utf-8").read(); a = "            return problem(HttpStatus.FORBIDDEN, \"the shutdown token is missing or wrong\");"; assert s.count(a) == 1; open(p, "w", encoding="utf-8").write(s.replace(a, "            ProblemDetail wide = ProblemDetail.forStatusAndDetail(HttpStatus.FORBIDDEN, \"the shutdown token is missing or wrong\"); wide.setType(java.net.URI.create(\"tag:tiffinbox.example,2026:shutdown-forbidden\")); return problem(HttpStatus.FORBIDDEN, wide);   // the harness'"'"'s plant (wide)"))' .harness/wide/$WEBM/TiffinBoxServer.java
  diff after/$WEBM/TiffinBoxServer.java .harness/wide/$WEBM/TiffinBoxServer.java | $G '^[<>]' | sed 's/^/  diff: /' | cut -c1-200
  mirror wide
  P=20987; L=seven-wide; DB=h2; TREE=wide tb seven-wide 20987 h2 ""
  sh $CURLSET 20987 .harness/run/seven-wide/secrets/tiffinbox/shutdown-token > $J/seven-wide.txt 2>&1
  i=0; while kill -0 "$(cat .harness/run/seven-wide/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 400 ] || die "seven-wide: the seven's POST /shutdown did not stop it"; sleep 0.05; done
  tbstop seven-wide 20987
  echo "  wide: the seven $(md5 -q $J/seven-wide.txt) (moved against the expected: $( [ "$(md5 -q $J/seven-wide.txt)" = "$S466" ] && echo NO || echo yes)) · the moved lines: $(diff $J/seven-after.txt $J/seven-wide.txt | $G -c '^>' || true)"
  P=20987; L=surface-wide; DB=h2; TREE=wide tb surface-wide 20987 h2 ""
  oldsurface2 20987 $J/surface-wide.txt
  tbstop surface-wide 20987
  echo "  wide: the old surface $(md5 -q $J/surface-wide.txt) (moved against the expected: $( [ "$(md5 -q $J/surface-wide.txt)" = "$U4SURF" ] && echo NO || echo yes)) · the moved lines: $(diff $J/surface-after.txt $J/surface-wide.txt | $G -c '^>' || true)"
  diff $J/surface-after.txt $J/surface-wide.txt | $G '^>' | sed 's/^/    wide moved: /' | cut -c1-220
  [ "$(listeners 20987)" = 0 ] || die "20987 still bound after the wide mirror"; }

c_inert() { local f
  echo "== every request of this run that says whether it sent the key header, by capture (the request blocks' sent: lines; specwire9.py's filed requests)"
  for f in .r-after.new .r-none.new .r-blanket.new .r-types.new .r-diff.new .r-scheme.new; do echo "  $f: sent the key: $($G -c '^     sent: key header yes' $f || true) ($($G -B3 '^     sent: key header yes' $f | $G -oE '^-- [a-z0-9-]+' | sed 's/^-- //' | paste -sd, -)) · did not: $($G -c '^     sent: key header no' $f || true)"; done
  f=$J/wire-h2; echo "  $(basename $f): $(python3 -I -c 'import json,os,sys; d = sys.argv[1]; r = [json.load(open(os.path.join(d, x))) for x in sorted(os.listdir(d))]; print("requests %d · with the key: %s" % (len(r), ",".join(x["name"] for x in r if any(k.lower() == sys.argv[2].lower() for k in x["request"]["headers"])) or "none"))' $f "$KEYH")"
  echo "== the key table, read by the second client on every harness-joined JVM of the run"
  $G -E 'the second client (before|after)' .r-diff.new .r-types.new | sed "s#^#  #"
  echo "  the harness-free JVMs (after, none, blanket, census, moved, surface, the exercise) are not read after the fact: H2 in memory ends with its JVM, PostgreSQL's database is made fresh before the next; their witness is the access log"; }

# the exercise: check.sh on a copy of before (.harness/exercise/tree), TiffinBox's jar alone on 20988, from the exercise's folder, env -i,
# under bash then zsh -f; the solution = apply.sh on the copy, then check.sh; the refused "solutions" each their own copy and start
exrun() { local v=$1 sh=$2 o cmd
  guard "the exercise, $v, $sh"
  rm -rf .harness/exercise/tree; copy before .harness/exercise/tree
  case $v in broken) cmd='sh check.sh "$0"' ;; solved) cmd='sh apply.sh "$0" > /dev/null && sh check.sh "$0"' ;; *) cmd="HOW=$v sh apply.sh \"\$0\" > /dev/null && sh check.sh \"\$0\"" ;; esac
  echo "== the exercise, h2, $v, $sh (env -i, from the exercise's folder; the tree a fresh copy of before; built offline from the receipt's seed copy, its jar alone on 20988):"
  if [ $sh = bash ]; then o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=20988 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" bash -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1)
  else o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=20988 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" /bin/zsh -f -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1); fi
  printf '%s\n' "$o" | sed -E 's/127\.0\.0\.1:20988/127.0.0.1:<port>/g; s/^/  /'
  offl exercise/check.build.log
  [ "$(listeners 20988)" = 0 ] || die "the exercise left something listening on 20988"; }
c_exercise() { local v sh
  rm -rf .harness/exercise; mkdir -p .harness/exercise
  for v in broken solved; do for sh in bash zsh; do exrun $v $sh; done; done
  if [ "${RUNNO:-0}" = 1 ] || [ "${RUNNO:-0}" = 0 ]; then for v in blanket oldroute both pauseget noschema nofile handedit; do exrun $v bash; done
  else echo "== the refused variants: run 1/1 (in run 1; the drop order's step - 3/3 -> 1/1)"; fi
  rm -rf exercise/check.run exercise/apply.run; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.spec.json exercise/check.nobody.json exercise/check.status exercise/apply.build.log exercise/apply.jvm.log exercise/apply.spec.json
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures${DEVCAPS:+ (DEVELOPMENT: only $DEVCAPS - not a run of record)}"
RFC="$C9R/_research/docs-2026-11-23/rfc9457.txt"
[ "$(md5 -q "$RFC")" = "$(awk '$NF ~ /rfc9457\.txt$/ { print $1 }' "$(dirname "$RFC")/MD5SUMS.txt")" ] || die "the filed RFC 9457 copy is not its MD5SUMS.txt line"
cap tests c_tests
cap census c_census
pgup
cap after c_after
dk rm -fv $CN > /dev/null 2>&1 || die "$CN could not be removed"
MINE=""
cap none c_none
cap blanket c_blanket
cap perop c_perop
cap types c_types
cap shape c_shape
cap committed c_committed
cap diff c_diff
cap scheme c_scheme
cap moved c_moved
cap seven c_seven
cap surface c_surface
cap inert c_inert
cap exercise c_exercise

# ---- the end: the sweep, the values, the published hashes -------------------------------------------------------------------------------
[ -z "$(echo $PIDS)" ] || die "a JVM of this run is still running: $PIDS"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
[ -z "$(dk ps -aq --filter label=org.testcontainers=true)" ] && [ -z "$(dk ps -aq --filter name=^/$CN\$)" ] || die "a container of this run is left"
NI1=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI1" = "$NI0" ] && [ "$VOL1" = "$VOL0" ] || die "R.322: images $NI0 -> $NI1, volumes $VOL0 -> $VOL1"
AD1=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true); [ "$AD1" = "$AD" ] || die "the anchor moved during the run"
pin before-tree before; pin after-tree after
MDB=$(find . ../c9-tiffinbox ../c9-unit08 -name '*.mv.db' -not -path './.harness/*' -not -path '../c9-unit08/.harness/*' 2> /dev/null | wc -l | tr -d ' ')
[ "$MDB" = 0 ] || die "an H2 file outside .harness/"
[ -z "$(ls exercise | $G -v -xE 'README.md|SOLUTION.md|apply.sh|check.sh')" ] || die "the exercise left a file in exercise/"
VALS="$VALS
static: $STV
gloss: $GLV
spoken: $SPV
build: seed_files=$NF0 seed_bytes=$NB0 central_only=$CO"
[ -n "${DEVCAPS:-}" ] && { printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'; echo "c9-unit09: DEVELOPMENT run ($DEVCAPS) - nothing published"; exit 2; }
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
VO=$(ck values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; die "README.md's values block is not this run's (harness/chk09.py values)"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM of this run, ports free, no container left, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1 · the anchor against after/ as at the start · the tree pins · *.mv.db outside .harness 0 · the values block = this run's"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit09: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit09: every capture = published ($NCAPS) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"
