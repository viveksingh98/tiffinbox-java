#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 07 "OpenAPI: The Contract" - this unit's receipts. Course 9's FOURTH anchor change, Section 2's first unit: before is a
# link to ../c9-unit06/after (U06's after: Spring Boot 4.1.3, Tomcat 11.0.29, the key filter, U05's PATCH, U06's public read); after/ is a
# frozen copy of ../c9-tiffinbox after this unit's change - springdoc-openapi 3.2.1 (one parent property with its comment, one managed
# dependency, the Spring MVC UI starter in tiffinbox-web) and the committed document (tiffinbox-web/src/test/resources/openapi/
# tiffinbox.json, no servers) checked by one new test (OpenApiSpecTest). Nothing in src/main moves.
# The harness (harness/src/probe/*, joined by --spring.main.sources, never in the jar): the statement witness and the request witness
# (Witness, Http), Routes, the ShallowEtag plant (Etag) - copied from U06's harness; unit 07's reads (probe.u07.U07Probe: the customer
# row, the customer count, the key table, the JsonMapper beans). The spec-vs-wire script is BLUE's instrument, byte-equal (specwire9.py).
# Every line they print is "the harness's". A JVM that joins the harness serves the harness's routes in its document too: every
# document a claim reads comes from a start WITHOUT the harness.
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5), PostgreSQL first where both run:
#   tests     mvn -o package (tests on), its Docker-free twin, mvn -o verify (the ITs), each on its own copy of after/; BOOT-INF/lib before -> after
#   census    /actuator/mappings on after/ and on before (one flag start each, H2, no harness); the handlers -> the document's operations
#   after     the three addresses and the document, on after/ (no harness), PostgreSQL then H2
#   diffpg    the spec against the wire on PostgreSQL (specwire9.py send + diff, the harness joined, a fresh database)
#   exercise  check.sh on the broken tree, the solution (apply.sh) and four refused "solutions", bash and zsh -f, H2 (the solution on PostgreSQL too)
#   before    the three addresses on before (U06's after), H2, the harness joined (the request witness)
#   diff      the spec against the wire on H2 (send, diff without and with the probe's filed generated source, the plant, the empty refusal)
#   jackson   which Jackson: the jars' constant pools, the wire's mapper (diff's harness read)
#   committed the file, the test, a drifted file and drifted code (scratch mirrors), and what the test does not catch
#   moved     the old routes' answers and the three addresses on before and after/, H2, no harness
#   seven     c5-unit11/curlset.sh on before and after/ (each its own JVM, no key)
#   surface   the old surface by count on before and after/, and the S9.14 plant (a ShallowEtagHeaderFilter, the harness's)
#   inert     the key header and the key table across every capture of the run
# Ports (Course 9's U07 band, 20960-20969): 20960 TiffinBox after/ on H2 · 20961 PostgreSQL c9u07-pg · 20962 after/ on PostgreSQL ·
# 20963 the flag start of after/ · 20964 the S9.14 plant · 20965 asserted free · 20966 before (and its flag start) · 20967 asserted free
# (no browser) · 20968 the exercise · 20969 never bound. During mvn verify only: 21280-21284, one per IT. Every store on 127.0.0.1; every
# curl --noproxy '*'. The key header is sent only by specwire9.py's pause-key request.
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
CN=c9u07-pg
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
trap 'trap "" INT TERM; for p in $pollpid $mpid $PIDS; do [ -z "$p" ] || killtree "$p"; done; for p in $pollpid $mpid $PIDS; do if kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; tcrm; ctrm; rm -rf exercise/check.run exercise/apply.run; rm -f exercise/check.build.log exercise/check.spec.json exercise/check.status exercise/check.jvm.log exercise/apply.build.log exercise/apply.jvm.log exercise/apply.spec.json; [ -z "$INTR" ] || rm -f .r-*.new; rmdir .r-lock 2> /dev/null || rm -rf .r-lock; true' EXIT
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
echo "c9-unit07 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }') · run $RUNNO"

# ---- gates before anything is built: the folder, the link, the pins, the anchor, the static check, the prose, the exercise ----------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk07.py dur9.py s907.py specwire9.py src tree07.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
HSRC='probe/Etag.java probe/Http.java probe/Routes.java probe/Witness.java probe/u07/U07Probe.java'
[ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$HSRC" ] || die "harness/src holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md apply.sh check.sh' ] || die "exercise/ holds another file, or misses one"
[ -L before ] && [ "$(readlink before)" = ../c9-unit06/after ] || die "before must be a link whose text is exactly ../c9-unit06/after (found: $( [ -L before ] && readlink before || echo 'not a link'))"
[ -d after ] && [ ! -L after ] || die "after/ is this unit's own frozen tree, a directory, not a link"
for t in before after; do [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/ - never built in place"; true; done
echo "  before -> $(readlink before) (a link, the text exact) · after/ a directory (the frozen copy) · no secrets/, target/ or .m2-demo/ in either"
$G -v '^ *#' harness/src/probe/*.java harness/src/probe/u07/*.java | $G -q 'Thread\.sleep' && die "R.412: a Thread.sleep in the harness"
for f in Witness Http Etag Routes; do w=$(awk -v n="harness/src/probe/$f.java" '$1 == "file" && $2 == n { print $3 }' ../c9-unit06/receipts.md5)
  [ -n "$w" ] && [ "$(md5 -q harness/src/probe/$f.java)" = "$w" ] || die "harness/src/probe/$f.java is not U06's published file (../c9-unit06/receipts.md5)"; done
echo "  harness/src/probe: Witness, Http, Etag, Routes = ../c9-unit06/receipts.md5's file lines (copied from U06's harness, c9-unit06/harness/src/probe) · U07Probe = this unit's"
SW9=$(awk '$2 ~ /instruments\/specwire9\.py$/ { print $1 }' "$BK/MD5SUMS")
[ -n "$SW9" ] && [ "$(md5 -q harness/specwire9.py)" = "$SW9" ] && [ "$(md5 -q "$BK/instruments/specwire9.py")" = "$SW9" ] || die "harness/specwire9.py is not BLUE's instrument (its MD5SUMS line: ${SW9:-none})"
echo "  harness/specwire9.py: BLUE's instrument, byte-equal (md5 $SW9 = $BK's MD5SUMS line, = the filed copy) - the names it sends are its own"
[ "$(sed -n '5,$p' harness/tree07.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit06/harness/tree06.py | md5 -q)" ] || die "harness/tree07.py's code is not tree06.py's"
for u in 01 02 03 04 05 06; do [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit$u/harness/dur9.py)" ] || die "harness/dur9.py is not ../c9-unit$u's copy (dur9 as shipped)"; done
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"
  [ ! -f "$C9R/_builders/dur9.py" ] || [ "$(md5 -q "$C9R/_builders/dur9.py")" = "$D9" ] || die "harness/dur9.py is not C9/_builders/dur9.py"
else D9N="(the registry is not on this machine: U01-U06's copies are the pin)"; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit01-06's copies $D9N · tree07.py's code = tree06.py's"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit06/receipts.md5)
[ -n "$UA" ] || die "../c9-unit06/receipts.md5 has no after-tree line"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree07.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$nm" = after-tree ] || [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit06/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree07.py $dir/ -> $got = receipts.md5's $nm line$( [ "$nm" = before-tree ] && echo " = ../c9-unit06/receipts.md5's after-tree line")"; }
pin before-tree before; pin after-tree after
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true)
echo "  after/ against ../c9-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures its own frozen after/' )"
HF="harness/chk07.py harness/s907.py harness/tree07.py harness/dur9.py harness/specwire9.py $(for f in $HSRC; do printf 'harness/src/%s ' $f; done)exercise/check.sh exercise/apply.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's scripts: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
ST=$(python3 -I -B harness/chk07.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
STV=$(printf '%s\n' "$ST" | sed -n 's/^VALUES //p')
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s907.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U07 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s907, per sentence): /'
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b|<measure>' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
GL=$(python3 -I -B harness/chk07.py gloss README.md) || die "the gloss: $(printf '%s\n' "$GL" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$GL" | $G -v '^VALUES ' | sed 's/^/  /'
GLV=$(printf '%s\n' "$GL" | sed -n 's/^VALUES //p')
HOOK=$(python3 -I -B harness/chk07.py hook); EXQ=$(python3 -I -B harness/chk07.py exq)
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S2B :158), byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SP=$(python3 -I -B harness/chk07.py spoken "$HOOK" "$EXQ") || die "the spoken lines: $(printf '%s\n' "$SP" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$SP" | $G -v '^VALUES ' | sed 's/^/  /'
SPV=$(printf '%s\n' "$SP" | sed -n 's/^VALUES //p')
printf '%s\n\n%s\n' "$HOOK" "$EXQ" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s907.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
printf '%s\n' "$SW" | tail -1 | $G -qE ' refused: 0$' || die "a refused reading in a spoken line: $(printf '%s\n' "$SW" | $G ' line ' | head -3 | paste -sd';' -)"
echo "  the hook and the exercise's line through s907.py (every family, dur9 inside it): refused 0"; rm -f .r-lock/spoken.md
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
[ "$KH" = 0 ] || die "S9.21: a line of receipts.sh or the exercise names the key header ($KH) - only specwire9.py's pause-key sends it"
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
MH=$(printf 'Date: Tue, 24 Nov 2026 08:00:00 GMT\r\nSet-Cookie: JSESSIONID=ABC123; Path=/; HttpOnly\r\nLocation: http://127.0.0.1:20960/dashboard\r\nExpires: Tue, 24 Nov 2027 08:00:00 GMT\r\nKeep-Alive: timeout=60\r\n' > .r-lock/mh; maskh .r-lock/mh | paste -sd'|' -; rm -f .r-lock/mh)
[ "$MH" = 'Date: <masked>|Set-Cookie: JSESSIONID=<masked>; Path=/; HttpOnly|Location: http://127.0.0.1:<port>/dashboard|Expires: <masked>|Keep-Alive: <masked>' ] || die "the header mask's self-test: $MH"
SM=$(printf '{"openapi":"3.1.0","servers":[{"url":"http://127.0.0.1:20960","description":"Generated server url"}],"paths":{}}' | python3 -I -B harness/chk07.py specmask)
[ "$SM" = '[{"url": "http://127.0.0.1:<port>", "description": "Generated server url"}]' ] || die "the servers mask's self-test: $SM"
echo "  masks: the log mask masked a Started line's times, a millisecond count, Boot's /error timestamp, the folders and the home; the header mask a planted Date, session cookie, port, Expires and Keep-Alive; the servers mask a planted servers[0].url's port"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
$G -qF 'S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)' ../c9-unit06/receipts.sh || die "../c9-unit06/receipts.sh no longer reads the seven's md5 off ../c7-unit31/receipts.sh"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SURF=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh)
[ ${#U4SURF} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh (SURF=)"
U6V=$(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit06/README.md | $G -oE 'seven=[0-9a-f]+ surface=[0-9a-f]+' | head -1)
[ "$U6V" = "seven=$(echo $S466 | cut -c1-8) surface=$(echo $U4SURF | cut -c1-8)" ] || die "U06's README values block ($U6V) is not the seven and the surface read off the receipts"
U6I=$(awk '$1 == "inert" { print $2 }' ../c9-unit06/receipts.md5); [ ${#U6I} = 32 ] || die "../c9-unit06/receipts.md5 has no inert line"
echo "  the seven: expected $S466 (../c7-unit31/receipts.sh's S466= line, as ../c9-unit06/receipts.sh reads it) · the old surface: expected $U4SURF (../c9-unit04/receipts.sh's SURF= line, U06's reader) · both = U06's README values block ($U6V) · U06's inert capture (the seven and the surface) published as $U6I in ../c9-unit06/receipts.md5"
FA=$(cat "$ADV/fetched-at.txt" 2> /dev/null | head -1); [ -n "$FA" ] || die "the advisories' fetched-at line is missing ($ADV)"
FAE=$(python3 -I -c 'import datetime,sys; t = datetime.datetime.strptime(sys.argv[1], "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=datetime.timezone.utc); print(int((datetime.datetime.now(datetime.timezone.utc) - t).total_seconds() // 3600))' "$FA")
[ "$FAE" -lt 48 ] || die "S9.36: the filed advisory read is $FAE hours old - a re-read is the orchestrator's act"
echo "  S9.36: today's filed read ($ADV), fetched at $FA ($FAE h before this run; not re-read: no network) · $(head -1 "$ADV/tomcat-11.0.30-section.txt") · OSV for springdoc: $($G -i springdoc "$ADV/osv-summary.txt" | sed 's/^org.springdoc://' | paste -sd';' -)"

# ---- docker, ports, the guard: the baselines ----------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that socket? (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
iid() { dk image inspect --format '{{.Id}}' "$1" 2> /dev/null | cut -c8-19; }
[ "$(iid $IMG)" = 77f585114c32 ] || die "the image $IMG is not on this machine - this script never pulls"
[ "$IMG" = "$(sed -n 's/^IMG=\(postgres@sha256:[0-9a-f]*\).*/\1/p' ../c9-unit06/receipts.sh)" ] || die "the image digest is not ../c9-unit06/receipts.sh's IMG= line"
[ "$IMG" = "$(sed -n '42s/^IMG=\(postgres@sha256:[0-9a-f]*\).*/\1/p' ../c8-unit27/receipts.sh)" ] || die "the image digest is not ../c8-unit27/receipts.sh:42's"
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run"
[ -z "$(dk ps -aq --filter name=^/$CN\$ 2> /dev/null)" ] || die "a container named $CN exists before the run - an interrupted run's? docker -H \"\$DH\" rm -fv $CN"
TC0=1
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
BAND="20960 20961 20962 20963 20964 20965 20966 20967 20968 20969"
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
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · $IMG present (= U06's IMG=, = c8-unit27:42's) · nothing pulled, ever · no Testcontainers container, no $CN · ports $PORTS free (TCP; the band and 21280-21284 UDP too) · no java process"

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
mkdir -p .harness; rm -rf .harness/before .harness/after .harness/pkg .harness/twin .harness/tests .harness/run .harness/work .harness/hc .harness/drift-file .harness/drift-code .harness/exercise
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
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \"$CPA:$DSP\" harness/src/probe/*.java harness/src/probe/u07/*.java" .harness/javac.log
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
probe() { $CURL -s "$(B $P)/probe/u07/$1"; }
psqlq() { dk exec $CN psql -U tiffinbox -d "${2:-tiffinbox}" -qAt -c "$1" 2>&1 | tr '\n' ' ' | sed 's/ *$//'; }
row() { if [ "$DB" = pg ]; then local x; x=$(psqlq "SELECT name || ' ' || meals_per_day || ' ' || price_per_meal || ' ' || meal_type || ' v' || version FROM customer WHERE name = '$1'"); echo "${x:-no row} (psql in $CN, the second client)"
  else echo "$(probe row/$1 | python3 -I -c 'import json,sys; r = [{k.lower(): v for k, v in x.items()} for x in json.load(sys.stdin)]; print(" ".join("%s %s %s %s v%s" % (x["name"], x["meals_per_day"], x["price_per_meal"], x["meal_type"], x["version"]) for x in r) or "no row")') (the harness's JdbcTemplate route /probe/u07/row/$1, the second client)"; fi; }
count() { if [ "$DB" = pg ]; then echo "$(psqlq "SELECT count(*) FROM customer") (psql in $CN, the second client)"; else echo "$(probe count | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])') (the harness's JdbcTemplate route /probe/u07/count, the second client)"; fi; }
keyrows() { if [ "$DB" = pg ]; then echo "$(psqlq "SELECT count(*) FROM idempotency_key") (psql in $CN, the second client)"; else echo "$(probe keys | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])') (the harness's JdbcTemplate route /probe/u07/keys, the second client)"; fi; }
pgfresh() { psqlq "drop database if exists tiffinbox with (force)" postgres > /dev/null; psqlq "create database tiffinbox" postgres > /dev/null; }
pgup() { guard "the PostgreSQL container"
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:20961:5432 -e POSTGRES_DB=tiffinbox -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust $IMG" .harness/docker-run-pg.log
  [ "$RE" = 0 ] || die "the PostgreSQL container did not start: $(tail -2 .harness/docker-run-pg.log)"
  local i=0; while ! dk exec $CN pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 240 ] || die "PostgreSQL did not accept connections"; sleep 0.5; done
  [ "$(dk port $CN | paste -sd'|' -)" = '5432/tcp -> 127.0.0.1:20961' ] || die "$CN publishes on another address than 127.0.0.1:20961"
  MINE=20961
  echo "  $CN: PostgreSQL $(psqlq 'show server_version') by the digest, on 127.0.0.1:20961 alone (docker port), trust on the loopback (no password exists to print), a fresh database"; }
# tb LABEL PORT DB HCX [args]: TiffinBox (the extracted jar of TREE=after unless TREE is set), from its own run folder with a generated token
# (a config tree, 0600, never printed), Tomcat's access log on (unbuffered, no time field: %m %U%q %s %b, S9.27); waited for by its
# Started line (never a health poll)
tb() { local label=$1 port=$2 db=$3 hcx=$4 t=${TREE:-after} run=.harness/run/$1 jx="" src="" i=0; shift 4
  guard "TiffinBox $label"
  for q in 20965 20967 20969; do [ "$(listeners $q)" = 0 ] && [ -z "$(lsof -nP -iUDP:$q 2> /dev/null)" ] || die "$q must stay free (TCP and UDP)"; done
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox" "$run/access"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  local x="$U/.harness/$t/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  if [ -n "$hcx" ]; then cp="$hcx:$cp:$U/.harness/hc:$DSP"; src="--spring.main.sources=${SRC:-probe.Witness,probe.Http,probe.Routes,probe.u07.U07Probe}"; fi
  [ "$db" = pg ] && jx="-Dtiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:20961/tiffinbox?user=tiffinbox"
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
  local o e=0; o=$(python3 -I -B harness/chk07.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk07 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  $G -v '^ok \|^FAIL ' .harness/chk-$nm.out | sed 's/^/  chk07 /' || true
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; [ -n "${DEVCAPS:-}" ] && { echo "  (development: $nm's check failed, the run goes on)"; unpub="$unpub $nm"; } || die "$nm: its check failed (harness/chk07.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk07.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-11s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-11s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff its block in README.md against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }

# ---- the captures --------------------------------------------------------------------------------------------------------------------
JSON='Content-Type: application/json'; MPT='Content-Type: application/merge-patch+json'; JPT='Content-Type: application/json-patch+json'
MX="--logging.level.org.springframework.web.servlet.mvc.method.annotation.ExceptionHandlerExceptionResolver=DEBUG"   # harness logging, never shipped
API=/api/v1/customers
KEYH='Idempotency-Key'          # the key header's name: no request of receipts.sh sends it (specwire9.py's pause-key does, and only it)
THREE="/v3/api-docs /swagger-ui.html /swagger-ui/index.html"
SPECF=after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json

surefire() { local f; for f in "$1"/TEST-*.xml; do python3 -I -B harness/chk07.py surefire "$f"; done; }
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
  for t in before after; do echo "  $t: $(ls .harness/$t/$XD/lib | wc -l | tr -d ' ') jars · $(ls .harness/$t/$XD/lib | $G -E '^(spring-boot-[0-9]|spring-core-|tomcat-embed-(core|el|websocket)-|jackson-databind-|postgresql-|parsson-)' | sort | paste -sd' ' -)"; done
  diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G '^[<>]' | sed 's/^/  lib /'; }

MAPRX='^[[:space:]]*@(Get|Post|Patch|Put|Delete)Mapping'
WMJ=c9-tiffinbox/tiffinbox-web/src/main/java
gcount() { git -C .. grep -cE "$MAPRX" "$1" -- "$WMJ" 2> /dev/null | awk -F: '{ s += $NF } END { print s + 0 }'; }
gdevm() { local f n=0; for f in $(git -C .. grep -lE '@Profile\("dev"\)' "$1" -- "$WMJ" 2> /dev/null | sed "s#^$1:##"); do n=$((n + $(git -C .. grep -cE "$MAPRX" "$1" -- "$f" 2> /dev/null | awk -F: '{ s += $NF } END { print s + 0 }'))); done; echo $n; }
c_census() { local c n dm
  echo "== the handler methods on after/ (one flag start on 20963, H2, no harness: --management.endpoints.web.exposure.include=health,prometheus,mappings, once, never shipped)"
  P=20963; L=FLAGA; DB=h2; tb FLAGA 20963 h2 "" --management.endpoints.web.exposure.include=health,prometheus,mappings
  $CURL -s "$(B 20963)/actuator/mappings" > $J/map-after.json; $CURL -s "$(B 20963)/v3/api-docs" > $J/spec-flag.json
  python3 -I -B harness/chk07.py mapjson after < $J/map-after.json
  tbstop FLAGA 20963
  echo "== the handler methods on before (U06's after; its own flag start on 20966, H2, no harness, the same flag once)"
  P=20966; L=FLAGB; TREE=before tb FLAGB 20966 h2 "" --management.endpoints.web.exposure.include=health,prometheus,mappings
  $CURL -s "$(B 20966)/actuator/mappings" > $J/map-before.json
  python3 -I -B harness/chk07.py mapjson before < $J/map-before.json
  tbstop FLAGB 20966
  echo "== the handlers against the document's operations (the flag start's /v3/api-docs, read by python; servers removed)"
  python3 -I -B harness/chk07.py ops $J/map-after.json $J/spec-flag.json
  echo "== the partition by commit (git grep -cE '$MAPRX' over $WMJ at each commit, the dev classes' mappings apart; no checkout)"
  for c in 80f7839 a0a0151 df4ff12 a805e6c; do n=$(gcount $c); dm=$(gdevm $c)
    echo "  commit $c ($(git -C .. log -1 --format=%s $c | cut -c1-24)): mapping annotations $n · dev mappings $dm · default run $((n - dm))"; done
  n=$(cat $(find after/tiffinbox-web/src/main/java -name '*.java') | $G -cE "$MAPRX"); dm=0
  for f in $($G -lE '@Profile\("dev"\)' $(find after/tiffinbox-web/src/main/java -name '*.java') | sort); do dm=$((dm + $($G -cE "$MAPRX" "$f" || true))); done
  echo "  after/ (this unit's tree): mapping annotations $n · dev mappings $dm · default run $((n - dm))"
  echo "  the unanchored count beside: after/ $(cat $(find after/tiffinbox-web/src/main/java -name '*.java') | $G -cE '@(Get|Post|Patch|Put|Delete)Mapping')"; }

# the three addresses and the document on one harness-free start
addrs() { local a
  for a in $THREE /v3/api-docs.yaml /v3/api-docs/swagger-config; do ask "a-$(echo $a | tr '/.' '--' | sed 's/^-//')" GET $a; done; }
docfacts() { $CURL -s "$(B $P)/v3/api-docs" > $J/spec-$DB.raw
  python3 -I -B harness/chk07.py docfacts $J/spec-$DB.raw $J/spec-$DB.json "$SPECF"; }
c_after() { local d
  for d in pg h2; do
    echo "== $d: the three addresses and the document on after/ (no harness: the document is TiffinBox's alone)"
    if [ $d = pg ]; then pgfresh; DB=pg; P=20962; L=AP; tb AP 20962 pg "" ; else DB=h2; P=20960; L=AH; tb AH 20960 h2 ""; fi
    echo "  which database answered (Flyway's line): $($G -m1 -oE 'Database: [^ ]+ \([^)]*\)' .harness/run/$L/jvm.log | sed -E 's/jdbc:[a-z0-9]+:[^ ]*/<url>/')"
    health
    NOWIT=1 addrs
    docfacts
    tbstop $L $P
  done
  echo "  the document on PostgreSQL and on H2, servers removed: $(cmp -s $J/spec-pg.json $J/spec-h2.json && echo byte-identical || echo DIFFERENT)"; }

# the spec against the wire: specwire9.py send (its own JVM, the harness joined, a fresh database) + diff
wire() { local dir=$J/wire-$DB
  rm -rf $dir; mkdir -p $dir
  echo "  the document diff reads: the harness-free start's (.harness/work/spec-$DB.json, servers removed; md5 $(md5 -q $J/spec-$DB.json))"
  echo "  the second client before: count $(count) · keys $(keyrows) · Ravi $(row Ravi)"
  echo "== $DB: python3 -I harness/specwire9.py send $P (BLUE_RUN=$RUNNO; the request set is BLUE's, its names its own; each request and answer filed as JSON)"
  (cd $J && BLUE_RUN=$RUNNO python3 -I "$U/harness/specwire9.py" send $P wire-$DB) 2>&1 | sed 's/^/  sent: /'
  python3 -I -B harness/chk07.py pairs $dir
  echo "== $DB: specwire9.py diff spec wire (a: no third argument - this tree's own census)"
  python3 -I harness/specwire9.py diff $J/spec-$DB.json $dir 2>&1 | sed 's/^/  (a) /'; echo "  (a) exit ${PIPESTATUS[0]}"
  echo "  the second client after: count $(count) · keys $(keyrows) · Ravi $(row Ravi)"
  for n in Blue1 Blue2 Blue3 Blue4; do echo "  row ${n}r$RUNNO: $(row ${n}r$RUNNO)"; done; }
c_diffpg() { pgfresh; DB=pg; P=20962; L=DP; tb DP 20962 pg "$U/.harness/hc" "$MX"
  echo "== pg: the spec against the wire on PostgreSQL 18.6 (c9u07-pg on 20961, TiffinBox on 20962)"
  health; wire; tbstop DP 20962; }
c_before() { DB=h2; P=20966; L=BH; TREE=before tb BH 20966 h2 "$U/.harness/hc" "$MX"
  echo "== h2: the three addresses on before (U06's after, 20966, the harness joined: the request witness)"
  health
  local a; for a in $THREE; do ask "b-$(echo $a | tr '/.' '--' | sed 's/^-//')" GET $a; done
  echo "  key table rows: $(keyrows)"
  tbstop BH 20966
  echo "== Course 8's line, read off the ledger (LED C9-10d) and its source by title (What's Next: The API Other People Will Use)"
  echo "  ledger: $($G -oE 'The API docs route and the Swagger page answer four-oh-four: TiffinBox publishes no contract today\.' "$C9R/_briefs/PROMISE-LEDGER-2026-11-24.md" | head -1)"
  echo "  the script's line $($G -nF 'The API docs route and the Swagger page answer four-oh-four' "$C9R/../spring-data-beyond-jpa/scripts-and-decks/28-whats-next-the-api-other-people-will-use.md" | head -1 | cut -d: -f1) holds it: $($G -cF 'TiffinBox publishes no contract today' "$C9R/../spring-data-beyond-jpa/scripts-and-decks/28-whats-next-the-api-other-people-will-use.md")"; }
c_diff() { DB=h2; P=20960; L=DH2; tb DH2 20960 h2 "$U/.harness/hc" "$MX"
  echo "== h2: the spec against the wire on H2 (TiffinBox after/ on 20960, the harness joined, a fresh database)"
  health
  echo "== h2: the addresses springdoc added, and the static handler's own address, asked with the request witness (which handler answers)"
  local a; for a in $THREE /nowhere; do ask "w-$(echo $a | tr '/.' '--' | sed 's/^-//')" GET $a; done
  $CURL -s "$(B $P)/v3/api-docs" > $J/spec-harness.raw
  echo "  the document on this harness-joined start: $(python3 -I -c 'import json,sys; d = json.load(open(sys.argv[1])); print("paths %d, of them /probe/ %d (the harness'"'"'s routes, documented too: no claim reads this document)" % (len(d["paths"]), sum(1 for p in d["paths"] if p.startswith("/probe/"))))' $J/spec-harness.raw)"
  echo "  the wire's mapper (the harness's /probe/u07/mapper): $(probe mapper)"
  wire
  echo "== h2: diff (b): the probe's filed generated source as the third argument - U10's tool's output, read, not produced here"
  python3 -I harness/specwire9.py diff $J/spec-h2.json $J/wire-h2 "$PK/captures/generated-sources/hi" 2>&1 | sed 's/^/  (b) /'; echo "  (b) exit ${PIPESTATUS[0]}"
  echo "== the plant: the document with mealType renamed meal_type (one sed), diff (a) and (b)"
  sed 's/"mealType"/"meal_type"/g' $J/spec-h2.json > $J/spec-plant.json
  echo "  the plant's diff against the document: $(diff $J/spec-h2.json $J/spec-plant.json | $G -c '^>') changed lines"
  python3 -I harness/specwire9.py diff $J/spec-plant.json $J/wire-h2 2>&1 | $G -E '^(KINDS|DISAGREEMENTS)' | sed 's/^/  plant (a) /'
  python3 -I harness/specwire9.py diff $J/spec-plant.json $J/wire-h2 "$PK/captures/generated-sources/hi" 2>&1 | $G -E '^(KINDS|DISAGREEMENTS)' | sed 's/^/  plant (b) /'
  rm -rf $J/wire-empty; mkdir -p $J/wire-empty
  python3 -I harness/specwire9.py diff $J/spec-h2.json $J/wire-empty 2>&1 | sed 's/^/  empty: /'; echo "  empty: exit ${PIPESTATUS[0]}"
  echo "  BLUE's filed (b) output, for the comparison: $BK/captures/wire/diff-run1.txt md5 $(md5 -q "$BK/captures/wire/diff-run1.txt" 2> /dev/null || echo absent)"
  python3 -I harness/specwire9.py diff $J/spec-h2.json $J/wire-h2 "$PK/captures/generated-sources/hi" > $J/diffb.txt 2>&1
  echo "  this run's (b) output md5 $(md5 -q $J/diffb.txt) · its rows against BLUE's: $(python3 -I -B harness/chk07.py rowsvs $J/diffb.txt "$BK/captures/wire/diff-run1.txt")"
  tbstop DH2 20960; }
c_jackson() {
  echo "== which Jackson: the constant pools of after/'s BOOT-INF/lib (python, zipfile; the class files' own UTF-8 entries)"
  python3 -I -B harness/chk07.py jars .harness/after/$XD/lib
  echo "  the wire's mapper: read by the diff capture's harness route (/probe/u07/mapper), its line there"; }
c_committed() {
  echo "== (i) the committed file: $SPECF"
  echo "  bytes $(wc -c < $SPECF | tr -d ' ') (wc -c) · md5 $(md5 -q $SPECF) · servers member: $(python3 -I -c 'import json,sys; print("present" if "servers" in json.load(open(sys.argv[1])) else "absent")' $SPECF)"
  echo "  the fixed rule (python3 -I, json.dump(indent=2, ensure_ascii=False) + a final newline) re-applied to the file: $(python3 -I -c 'import io,json,sys; d = json.load(open(sys.argv[1], encoding="utf-8")); b = io.StringIO(); json.dump(d, b, indent=2, ensure_ascii=False); b.write("\n"); print("byte-identical" if b.getvalue() == open(sys.argv[1], encoding="utf-8").read() else "DIFFERENT")' $SPECF)"
  echo "  the file against the served document, servers removed (the after capture's python, live): pg $(cmp -s $J/spec-pg.json $SPECF && echo byte-identical || echo DIFFERENT) · h2 $(cmp -s $J/spec-h2.json $SPECF && echo byte-identical || echo DIFFERENT)"
  echo "== (ii) OpenApiSpecTest in the tests capture's package and its Docker-free twin (Surefire's XML)"
  python3 -I -B harness/chk07.py surefire .harness/pkg/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.OpenApiSpecTest.xml | sed 's/^/  package:/'
  python3 -I -B harness/chk07.py surefire .harness/twin/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.OpenApiSpecTest.xml | sed 's/^/  twin:/'
  echo "  MockMvc's servers, as the test printed it: $($G -m1 -E '^OpenApiSpecTest: ' .harness/pkg.log | sed -E 's/^OpenApiSpecTest: servers served //')"
  echo "  the socket's servers, as the after capture read it (masked): $(python3 -I -B harness/chk07.py specmask < $J/spec-h2.raw)"
  local k f
  for k in file code; do
    rm -rf .harness/drift-$k; copy after .harness/drift-$k
    if [ $k = file ]; then f=tiffinbox-web/src/test/resources/openapi/tiffinbox.json
      python3 -I -c 'import re,sys; p = sys.argv[1]; s = open(p, encoding="utf-8").read(); a = "\"required\": [\n          \"mealType\",\n          \"name\"\n        ]"; assert s.count(a) == 1, s.count(a); open(p, "w", encoding="utf-8").write(s.replace(a, "\"required\": [\n          \"mealType\",\n          \"mealsPerDay\",\n          \"name\",\n          \"pricePerMeal\"\n        ]"))' .harness/drift-$k/$f
      echo "== (iii) a drifted copy of the file (scratch mirror .harness/drift-file, one edit: required widened to four)"
    else f=tiffinbox-core/src/main/java/com/tiffinbox/Customer.java
      sed -i '' 's/@NotBlank @Size(max = 60) String name/@NotBlank @Size(max = 61) String name/' .harness/drift-$k/$f
      echo "== (iv) drifted code (scratch mirror .harness/drift-code, one sed: the record's @Size(max = 60) -> 61; the served document follows, the file does not)"
    fi
    diff after/$f .harness/drift-$k/$f | $G '^[<>]' | sed 's/^/  diff: /' | cut -c1-200
    guard "the drift-$k test"
    bg "cd .harness/drift-$k && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean test -Dtest=OpenApiSpecTest -Dsurefire.failIfNoSpecifiedTests=false -pl tiffinbox-web -am" .harness/drift-$k.log
    offl .harness/drift-$k.log
    echo "  mvn test -Dtest=OpenApiSpecTest exit $RE · $($G -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures' .harness/drift-$k.log | tail -1 | sed -E 's/^\[[A-Z]+\] //')"
    echo "  its FAIL line: $($G -m1 -oE 'theServedDocumentIsTheCommittedOne.*FAILURE!' .harness/drift-$k.log | sed -E 's/Time elapsed: [0-9.]+ s/Time elapsed: <t>/')"
    echo "  the assertion: $($G -m1 -oE '^(expected|Expecting)[^{]*' .harness/drift-$k.log | head -1) (the two documents follow it in the log)"
  done
  echo "== (v) what the test does not catch: on the shipped after/, the test PASSED (ii) in the same run in which diff printed its rows"
  echo "  the diff capture's (a) line: $($G -m1 -E '^  \(a\) DISAGREEMENTS [0-9]+$' .r-diff.new 2> /dev/null | sed 's/^  //') · the test: equal: true with every disagreement present (code against the committed file, never the document against the wire)"; }
movedone() { local port=$1 m=$2 p=$3 w; shift 3; : > $J/mv.h; : > $J/mv.b
  w=$($CURL --http1.1 -sS -D $J/mv.h -o $J/mv.b -w '%{http_code} %{content_type} %{size_download}' --max-time 5 -X "$m" "$@" "$(B $port)$p" 2> /dev/null)
  local bm; bm=$(sed -E 's/"timestamp":"[^"]*"/"timestamp":"<masked>"/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' $J/mv.b | md5 -q | cut -c1-12)
  echo "  $SIDE | $m $p$( [ -n "${TAG:-}" ] && echo " [$TAG]") -> $w · Allow {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Aa]llow: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)} · Accept-Patch {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Aa]ccept-[Pp]atch: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)} · Location {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Ll]ocation: //p' | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/')} · body $bm"; }
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
  for a in $THREE; do movedone $port GET $a; done
  tbstop moved-$side $port; }
c_moved() { echo "== the old routes' answers and the three addresses, on before (20966) and after/ (20960), H2, each its own JVM, no harness; bodies hashed with Boot's /error timestamp and any port masked"
  movedside before 20966; movedside after 20960; }
c_seven() { local side tree port i
  echo "== the seven (c5-unit11/curlset.sh, no key header), each tree its own JVM, H2, no harness: the expected $S466"
  for side in before after; do [ $side = before ] && port=20966 || port=20960
    P=$port; L=seven-$side; DB=h2; TREE=$side tb seven-$side $port h2 ""
    sh $CURLSET $port .harness/run/seven-$side/secrets/tiffinbox/shutdown-token > $J/seven-$side.txt 2>&1
    i=0; while kill -0 "$(cat .harness/run/seven-$side/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 400 ] || die "seven-$side: the seven's POST /shutdown did not stop it"; sleep 0.05; done
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
  echo "== the old surface by count (U06's reader, copied), each tree its own JVM, H2, no harness: the expected $U4SURF"
  for side in before after; do [ $side = before ] && port=20966 || port=20960
    P=$port; L=surface-$side; DB=h2; TREE=$side tb surface-$side $port h2 ""
    oldsurface2 $port $J/surface-$side.txt
    tbstop surface-$side $port
    echo "  $side: the old surface $(md5 -q $J/surface-$side.txt) ($($G -c '^== ' $J/surface-$side.txt) requests, $(wc -l < $J/surface-$side.txt | tr -d ' ') lines)"; done
  echo "  before -> after/: $(cmp -s $J/surface-before.txt $J/surface-after.txt && echo equal || echo DIFFER)"
  diff $J/surface-before.txt $J/surface-after.txt | sed 's/^/    moved: /'
  echo "== the self-test (S9.14, the harness's plant - LABELLED, not a finding about TiffinBox): a ShallowEtagHeaderFilter on /* (probe.Etag, U06's), after/, on 20964"
  P=20964; L=seven-etag; SRC=probe.Etag tb seven-etag 20964 h2 "$U/.harness/hc"
  sh $CURLSET 20964 .harness/run/seven-etag/secrets/tiffinbox/shutdown-token > $J/seven-etag.txt 2>&1
  i=0; while kill -0 "$(cat .harness/run/seven-etag/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 400 ] || die "seven-etag did not stop"; sleep 0.05; done; tbstop seven-etag 20964
  P=20964; L=surface-etag; SRC=probe.Etag tb surface-etag 20964 h2 "$U/.harness/hc"; oldsurface2 20964 $J/surface-etag.txt; tbstop surface-etag 20964
  echo "  planted: the seven $(md5 -q $J/seven-etag.txt) (unchanged: $(cmp -s $J/seven-etag.txt $J/seven-after.txt && echo yes || echo NO)) · the old surface $(md5 -q $J/surface-etag.txt) (moved: $(cmp -s $J/surface-etag.txt $J/surface-after.txt && echo NO || echo yes)) · the feed's line: $($G '^== GET /customers/feed' $J/surface-etag.txt | sed -E 's/^== //')"; }
c_inert() { local f
  echo "== every request of this run that says whether it sent the key header, by capture (the request blocks' sent: lines; specwire9.py's filed requests)"
  for f in .r-before.new .r-after.new .r-diff.new .r-diffpg.new; do echo "  $f: sent the key: $($G -c '^     sent: key header yes' $f || true) · did not: $($G -c '^     sent: key header no' $f || true)"; done
  for f in $J/wire-h2 $J/wire-pg; do echo "  $(basename $f): $(python3 -I -c 'import json,os,sys; d = sys.argv[1]; r = [json.load(open(os.path.join(d, x))) for x in sorted(os.listdir(d))]; print("requests %d · with the key: %s" % (len(r), ",".join(x["name"] for x in r if any(k.lower() == sys.argv[2].lower() for k in x["request"]["headers"])) or "none"))' $f "$KEYH")"; done
  echo "== the key table, read by the second client on every harness-joined JVM of the run"
  for f in .r-before.new .r-diff.new .r-diffpg.new; do $G -E 'key table rows: |the second client (before|after): ' $f | sed "s#^#  $f: #"; done
  echo "  the harness-free JVMs (after, census, moved, seven, surface) are not read after the fact: H2 in memory ends with its JVM, PostgreSQL's database is made fresh before the next"; }

# the exercise: check.sh on a tree (a cp -c copy of after/ under .harness/exercise/), against TiffinBox's jar alone on 20968, from the
# exercise's folder, env -i, under bash then zsh -f; the solution = apply.sh; four refused "solutions"
exprep() { local v=$1 d=.harness/exercise/$1
  rm -rf $d; mkdir -p .harness/exercise; copy after $d
  local cu=$d/tiffinbox-core/src/main/java/com/tiffinbox/Customer.java f=$d/tiffinbox-web/src/test/resources/openapi/tiffinbox.json
  case $v in
    broken) : ;;
    solved) (cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=20968 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" sh apply.sh "../$d") > $J/apply-$v.txt 2>&1 ;;
    fileonly) python3 -I -c 'import sys; p = sys.argv[1]; s = open(p, encoding="utf-8").read(); a = "\"required\": [\n          \"mealType\",\n          \"name\"\n        ]"; assert s.count(a) == 1; open(p, "w", encoding="utf-8").write(s.replace(a, "\"required\": [\n          \"mealType\",\n          \"mealsPerDay\",\n          \"name\",\n          \"pricePerMeal\"\n        ]"))' $f ;;
    noregen) sed -i '' -e 's/@Min(1) @Max(3) int mealsPerDay/@NotNull @Min(1) @Max(3) int mealsPerDay/' -e 's/@Min(1) int pricePerMeal/@NotNull @Min(1) int pricePerMeal/' $cu ;;
    wrongprops) sed -i '' 's/@Min(1) @Max(3) int mealsPerDay/@NotNull @Min(1) @Max(3) int mealsPerDay/' $cu
      (cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=20968 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" sh apply.sh --regenerate "../$d") > $J/apply-$v.txt 2>&1 ;;
    unvalidated) (cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=20968 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" sh apply.sh "../$d") > $J/apply-$v.txt 2>&1
      sed -i '' 's/ResponseEntity<?> add(@Valid @RequestBody Customer customer, BindingResult errors)/ResponseEntity<?> add(@RequestBody Customer customer, BindingResult errors)/' $d/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java ;;
  esac
  echo "== the exercise's tree, $v: changed against after/: $(diff -rq -x target -x secrets after $d | sed "s#$d/##; s#after/##" | awk '{ print $2 }' | sed 's#^after/##' | sort -u | paste -sd' ' - | sed 's/^$/nothing/')$( [ -f $J/apply-$v.txt ] && echo " · apply.sh: $(tail -1 $J/apply-$v.txt | sed -E 's/127\.0\.0\.1:20968/127.0.0.1:<port>/g')")"
  diff after/tiffinbox-core/src/main/java/com/tiffinbox/Customer.java $cu | $G '^>' | sed 's/^> */     Customer.java: /'
  diff after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java $d/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java | $G '^>' | sed 's/^> */     TiffinBoxServer.java: /'
  echo "     the committed file: required $(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1]))["components"]["schemas"]["Customer"]["required"])' $f) · md5 $(md5 -q $f)"; }
exrun() { local v=$1 sh=$2 db=$3 o
  guard "the exercise, $v, $sh, $db"
  [ $db = pg ] && pgfresh
  echo "== the exercise, $db, $v, $sh (env -i, from the exercise's folder; check.sh builds the tree offline from the receipt's seed copy and starts its jar alone on 20968):"
  if [ $sh = bash ]; then o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=20968 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" ${JX:+JDBC_URL="$JX"} bash -c 'sh check.sh "$0"; echo "check exit $?"' "../.harness/exercise/$v" 2>&1)
  else o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=20968 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" ${JX:+JDBC_URL="$JX"} /bin/zsh -f -c 'sh check.sh "$0"; echo "check exit $?"' "../.harness/exercise/$v" 2>&1); fi
  printf '%s\n' "$o" | sed -E 's/127\.0\.0\.1:20968/127.0.0.1:<port>/g; s/^/  /'
  offl exercise/check.build.log
  [ "$(listeners 20968)" = 0 ] || die "the exercise left something listening on 20968"; }
c_exercise() { local v sh
  for v in broken solved fileonly noregen wrongprops unvalidated; do exprep $v; done
  for v in broken solved fileonly noregen wrongprops unvalidated; do for sh in bash zsh; do exrun $v $sh h2; done; done
  for sh in bash zsh; do JX="jdbc:postgresql://127.0.0.1:20961/tiffinbox?user=tiffinbox" exrun solved $sh pg; JX="jdbc:postgresql://127.0.0.1:20961/tiffinbox?user=tiffinbox" exrun broken $sh pg; done
  rm -rf exercise/check.run exercise/apply.run; rm -f exercise/check.build.log exercise/check.spec.json exercise/check.status exercise/check.jvm.log exercise/apply.build.log exercise/apply.jvm.log exercise/apply.spec.json
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures${DEVCAPS:+ (DEVELOPMENT: only $DEVCAPS - not a run of record)}"
cap tests c_tests
cap census c_census
pgup
cap after c_after
cap diffpg c_diffpg
cap exercise c_exercise
dk rm -fv $CN > /dev/null 2>&1 || die "$CN could not be removed"
MINE=""
cap before c_before
cap diff c_diff
cap jackson c_jackson
cap committed c_committed
cap moved c_moved
cap seven c_seven
cap surface c_surface
cap inert c_inert

# ---- the end: the sweep, the values, the published hashes -------------------------------------------------------------------------------
[ -z "$(echo $PIDS)" ] || die "a JVM of this run is still running: $PIDS"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
[ -z "$(dk ps -aq --filter label=org.testcontainers=true)" ] && [ -z "$(dk ps -aq --filter name=^/$CN\$)" ] || die "a container of this run is left"
NI1=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI1" = "$NI0" ] && [ "$VOL1" = "$VOL0" ] || die "R.322: images $NI0 -> $NI1, volumes $VOL0 -> $VOL1"
AD1=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true); [ "$AD1" = "$AD" ] || die "the anchor moved during the run"
pin before-tree before; pin after-tree after
MDB=$(find . ../c9-tiffinbox ../c9-unit06 -name '*.mv.db' -not -path './.harness/*' 2> /dev/null | wc -l | tr -d ' ')
[ "$MDB" = 0 ] || die "an H2 file outside .harness/"
[ -z "$(ls exercise | $G -v -xE 'README.md|SOLUTION.md|apply.sh|check.sh')" ] || die "the exercise left a file in exercise/"
VALS="$VALS
static: $STV
gloss: $GLV
spoken: $SPV
build: seed_files=$NF0 seed_bytes=$NB0 central_only=$CO"
[ -n "${DEVCAPS:-}" ] && { printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'; echo "c9-unit07: DEVELOPMENT run ($DEVCAPS) - nothing published"; exit 2; }
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
VO=$(python3 -I -B harness/chk07.py values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; die "README.md's values block is not this run's (harness/chk07.py values)"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM of this run, ports free, no container left, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1 · the anchor against after/ as at the start · the tree pins · *.mv.db outside .harness 0 · the values block = this run's"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit07: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit07: every capture = published ($NCAPS) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"
