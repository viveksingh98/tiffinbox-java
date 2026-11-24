#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 05 "PATCH Properly: JSON Patch and Merge Patch" - this unit's receipts. Course 9's SECOND anchor change: before is a
# link to ../c9-unit04/after (U04's after: Spring Boot 4.1.3, Tomcat 11.0.29, the key filter); after/ is a frozen copy of ../c9-tiffinbox
# after this unit's change - PATCH /api/v1/customers/{name} (CustomerPatches: JSON-P's createMergePatch and createPatch, Parsson), every
# patched document re-read into Customer by Boot's JsonMapper and checked by Boot's Validator, CustomerRepository.update evicting
# customers and both names in customer after the commit, JSON-P and Parsson declared directly (Parsson pinned in the parent), the
# pinning tests (CustomerPatchesTest).
# The harness (harness/src/probe/*, joined by --spring.main.sources, never in the jar): the statement witness and the request witness
# (Witness, Http - U04's), the second client on H2 (Routes - U04's), the S1 probe's PATCH routes (Patch - the naive copies, the JsonNode
# merge, readerForUpdating; BR/instruments/probe-src, byte for byte) and its mapper print (JsonProbe), unit 05's reads (probe.u05.U05Probe),
# the ShallowEtag plant (Etag - U04's), the planted no-evict CustomerRepository (the shipped class with its @Caching removed by one sed).
# Every line it prints is "the harness's".
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5), PostgreSQL first where both run:
#   tests    mvn -o verify on a copy of after/ (Surefire's and Failsafe's XML per class, the five IT BINDINGS lines), BOOT-INF/lib before ->
#            after, the version lines, the handler methods (one flag start)
#   jsonp    the two JSON-P jars' dependency paths on before and after (mvn -o dependency:tree), the pin, the provider a running JVM uses
#   bodies   the four bodies through TiffinBox's own POST /customers · trap  the naive PATCH (trap-a, trap-b, trap-a2) + the String-absent body
#   merge    the shipped merge patch · jsonpatch  the shipped JSON Patch · retry  each sent twice · rename  the evicting rename
#   stale    the planted no-evict copy · reader  readerForUpdating behind the harness's route (H2) · matrix  every PATCH answer and its author
#   moved    the old addresses' PATCH rows and OPTIONS on before and after · inert  the seven and the old surface on before and after
#   exercise exercise/README.md's block (broken), SOLUTION.md's line (solved), four refused "solutions", bash and zsh -f
# Ports (Course 9's U05 band, 20940-20949): 20940 TiffinBox after/ on H2 · 20941 PostgreSQL c9u05-pg · 20942 TiffinBox after/ on
# PostgreSQL · 20943 the S9.14 plant · 20944 the trap's JVMs · 20945 the planted no-evict JVM · 20946 before · 20947 asserted free ·
# 20948 the exercise · 20949 never bound. During mvn verify only: 21280-21284, one per IT. Every store on 127.0.0.1; every curl
# --noproxy '*'. No request of this script carries an idempotency key header or asks U04's pause route.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
C9R=${C9R:-"/Users/$ME/Downloads/Youtube Content/LearnProgrammingWithVivek/rest-apis-done-right"}   # the course's folder (briefs, research)
SEED=${SEED:-"$C9R/_research/m2-seed-c9-u04"}   # the course's seed (B5b)
BRI="$C9R/_research/boundary-2026-11-24/instruments/probe-src"
export C9R
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c9u05-pg
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
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "curlset.sh") || $3 ~ /(^|\/)javac$/) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
tcrm() { local c n=0 i=0; [ -n "$TC0" ] || return 0
  while [ $i -lt 10 ]; do
    for c in $(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null); do dk rm -fv "$c" > /dev/null 2>&1 && n=$((n + 1)); done
    [ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] && break; sleep 0.5; i=$((i + 1)); done
  [ "$n" = 0 ] || echo "  the trap: $n Testcontainers container(s) removed with their volumes (rm -fv)" >&3; }
ctrm() { [ -n "$TC0" ] || return 0; [ -z "$(dk ps -aq --filter name=^/$CN\$ 2> /dev/null)" ] || dk rm -fv "$CN" > /dev/null 2>&1 || true; }
trap 'trap "" INT TERM; for p in $pollpid $mpid $PIDS; do [ -z "$p" ] || killtree "$p"; done; for p in $pollpid $mpid $PIDS; do if kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; tcrm; ctrm; [ -z "$INTR" ] || rm -f .r-*.new; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit05 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"

# ---- gates before anything is built: the folder, the link, the pins, the anchor, the static check, the prose, the exercise ----------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk05.py dur9.py s905.py src tree05.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
HSRC='probe/Etag.java probe/Http.java probe/JsonProbe.java probe/Patch.java probe/Routes.java probe/Witness.java probe/u05/U05Probe.java'
[ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$HSRC" ] || die "harness/src holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md check.sh patch.sh' ] || die "exercise/ holds another file, or misses one"
[ -L before ] && [ "$(readlink before)" = ../c9-unit04/after ] || die "before must be a link whose text is exactly ../c9-unit04/after (found: $( [ -L before ] && readlink before || echo 'not a link'))"
[ -d after ] && [ ! -L after ] || die "after/ is this unit's own frozen tree, a directory, not a link"
for t in before after; do [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/ - never built in place"; true; done
echo "  before -> $(readlink before) (a link, the text exact) · after/ a directory (the frozen copy) · no secrets/, target/ or .m2-demo/ in either"
$G -v '^ *#' harness/src/probe/*.java harness/src/probe/u05/*.java | $G -q 'Thread\.sleep' && die "R.412: a Thread.sleep in the harness"
for f in Witness Http Etag; do w=$(awk -v n="harness/src/probe/$f.java" '$1 == "file" && $2 == n { print $3 }' ../c9-unit03/receipts.md5)
  [ "$(md5 -q harness/src/probe/$f.java)" = "$w" ] || die "harness/src/probe/$f.java is not U03's published file (../c9-unit03/receipts.md5)"; done
[ "$(md5 -q harness/src/probe/Routes.java)" = "$(md5 -q ../c9-unit04/harness/src/probe/Routes.java)" ] || die "harness/src/probe/Routes.java is not U04's byte for byte"
for f in Patch JsonProbe; do
  if [ -f "$BRI/MD5SUMS" ]; then w=$(awk -v n="$f.java" '$2 == n { print $1 }' "$BRI/MD5SUMS"); [ "$(md5 -q harness/src/probe/$f.java)" = "$w" ] || die "harness/src/probe/$f.java is not the S1 probe's ($BRI/MD5SUMS)"; fi; done
echo "  harness/src/probe: Witness, Http, Etag = ../c9-unit03/receipts.md5's file lines (copied from U03's harness) · Routes = U04's byte for byte · Patch, JsonProbe = the S1 probe's (BR/instruments/probe-src/MD5SUMS: $(md5 -q harness/src/probe/Patch.java | cut -c1-8) $(md5 -q harness/src/probe/JsonProbe.java | cut -c1-8))"
[ "$(sed -n '5,$p' harness/tree05.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit04/harness/tree04.py | md5 -q)" ] || die "harness/tree05.py's code is not tree04.py's"
for u in 01 02 03 04; do [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit$u/harness/dur9.py)" ] || die "harness/dur9.py is not ../c9-unit$u's copy (dur9 as shipped)"; done
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"
  [ ! -f "$C9R/_builders/dur9.py" ] || [ "$(md5 -q "$C9R/_builders/dur9.py")" = "$D9" ] || die "harness/dur9.py is not C9/_builders/dur9.py"
else D9N="(the registry is not on this machine: U01-U04's copies are the pin)"; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit01-04's copies $D9N · tree05.py's code = tree04.py's"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit04/receipts.md5)
[ -n "$UA" ] || die "../c9-unit04/receipts.md5 has no after-tree line"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree05.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$nm" = after-tree ] || [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit04/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree05.py $dir/ -> $got = receipts.md5's $nm line$( [ "$nm" = before-tree ] && echo " = ../c9-unit04/receipts.md5's after-tree line")"; }
pin before-tree before; pin after-tree after
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true)
echo "  after/ against ../c9-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures its own frozen after/' )"
HF="harness/chk05.py harness/s905.py harness/tree05.py harness/dur9.py $(for f in $HSRC; do printf 'harness/src/%s ' $f; done)exercise/patch.sh exercise/check.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's scripts: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
ST=$(python3 -I -B harness/chk05.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
STV=$(printf '%s\n' "$ST" | sed -n 's/^VALUES //p')
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s905.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U05 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s905, per sentence): /'
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
G1="A partial update: a change that names only the fields it changes."
[ "$($G -cxF -- "$G1" README.md)" = 1 ] || die "the gloss (SECTION SHAPE 05, S1B :387) must stand in README.md once, as a line of its own, byte for byte: $G1"
HOOK=$(python3 -I -B harness/chk05.py hook); EXQ=$(python3 -I -B harness/chk05.py exq)
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S1B :333), byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SP=$(python3 -I -B harness/chk05.py spoken "$HOOK" "$EXQ" "$G1") || die "the spoken lines: $(printf '%s\n' "$SP" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$SP" | $G -v '^VALUES ' | sed 's/^/  /'
printf '%s\n\n%s\n\n%s\n' "$HOOK" "$EXQ" "$G1" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s905.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
printf '%s\n' "$SW" | tail -1 | $G -qE ' refused: 0$' || die "a refused reading in a spoken line: $(printf '%s\n' "$SW" | $G ' line ' | head -3 | paste -sd';' -)"
echo "  the hook, the exercise's line and the gloss through s905.py (every family, dur9 inside it): refused 0"; rm -f .r-lock/spoken.md
block() { awk '/^```(bash|sh)$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
SETX=$(block exercise/README.md); SOLX=$(block exercise/SOLUTION.md)
[ -n "$SETX" ] && [ -n "$SOLX" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
[ "$(printf '%s\n' "$SOLX" | wc -l | tr -d ' ')" = 1 ] || die "R.196: SOLUTION.md's block must be the one fixed line"
[ "$($G -c '^curl .*-X PATCH' exercise/patch.sh)" = 1 ] || die "exercise/patch.sh: one asking line (the line the fix changes)"
$G -q -- '-H "Content-Type: application/json"' exercise/patch.sh || die "exercise/patch.sh: the broken form - the patch sent as plain JSON"
swapline() { XN="$2" python3 -I -c 'import os, re, sys; f = open(sys.argv[1]).read().split("\n"); i = [k for k, l in enumerate(f) if re.match(sys.argv[2], l)]; assert len(i) == 1; f[i[0]] = os.environ["XN"]; sys.stdout.write("\n".join(f))' "$1" "$3"; }
SOLV=$(swapline exercise/patch.sh "$SOLX" '^curl .*-X PATCH')
[ "$(diff exercise/patch.sh <(printf '%s\n' "$SOLV") | $G -c '^[<>]')" = 2 ] || die "R.196: SOLUTION.md's line must change patch.sh's asking line and nothing else"
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
$G -qE '^rm -f patch\.status' exercise/check.sh || die "exercise/check.sh must remove the saved status before it runs the patch"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket"
DK=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -vF 'echo "' | $G -nE '(^|[ ;(])docker (run|exec|rm|ps|port|info|images|volume|image|pull|logs|inspect)\b' | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.344: receipts.sh calls docker without the pinned socket: $DK"
RMF=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) rm( +-[a-z]+)*' | sort -u | paste -sd'|' -)
[ "$RMF" = 'dk rm -fv' ] || die "R.387: receipts.sh removes a container without its volumes (found: ${RMF:-none})"
[ "$($G -v '^ *#' receipts.sh | $G -oE '(dk|docker) run -[^"]*' | $G -vcF -- '--pull never' || true)" = 0 ] || die "R.344: a dk run without --pull never"
MVA=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -F '$MV ' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am"
KW='idempotency''-key'; KH=$($G -v '^ *#' receipts.sh exercise/patch.sh exercise/check.sh | $G -ciF "$KW" || true)
[ "$KH" = 0 ] || die "S9.21: a line of receipts.sh or the exercise names the key header ($KH) - unit 05 sends no key on any request"
AP=$($G -v '^ *#' receipts.sh exercise/patch.sh | $G -vF '$G -' | $G -cE '/pauses' || true)
[ "$AP" = 0 ] || die "S9.3: a line of receipts.sh or the exercise asks a pause route ($AP)"
echo "  the exercise: SOLUTION.md's line = patch.sh's asking line changed, nothing else; patch.sh broken as shipped (plain JSON); check.sh removes the saved status first; the two What-it-prints blocks differ · the gloss, the hook and the exercise's line byte for byte · placeholders 0"
echo "  static: no kill by name; every docker call on the pinned socket, every dk run --pull never, every removal rm -fv; every Maven build -pl tiffinbox-web -am; no Thread.sleep in the harness; no line sends the key header or asks a pause route"
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
maskh() { tr -d '\r' < "$1" | sed -E 's/^(Date|date): .*/\1: <masked>/; s/(JSESSIONID=)[^;]*/\1<masked>/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/^(Expires): .*/\1: <masked>/'; }
MH=$(printf 'Date: Tue, 24 Nov 2026 08:00:00 GMT\r\nSet-Cookie: JSESSIONID=ABC123; Path=/; HttpOnly\r\nLocation: http://127.0.0.1:20940/dashboard\r\nExpires: Tue, 24 Nov 2027 08:00:00 GMT\r\n' > .r-lock/mh; maskh .r-lock/mh | paste -sd'|' -; rm -f .r-lock/mh)
[ "$MH" = 'Date: <masked>|Set-Cookie: JSESSIONID=<masked>; Path=/; HttpOnly|Location: http://127.0.0.1:<port>/dashboard|Expires: <masked>' ] || die "the header mask's self-test: $MH"
echo "  masks: the log mask's self-test masked a Started line's times, a millisecond count, Boot's /error timestamp, the folders and the home; the header mask's self-test masked a planted Date, session cookie value, port and Expires"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
$G -qF 'S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)' ../c9-unit04/receipts.sh || die "../c9-unit04/receipts.sh no longer reads the seven's md5 off ../c7-unit31/receipts.sh"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SURF=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh)
[ ${#U4SURF} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh (SURF=)"
U4V=$(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit04/README.md | $G -oE 'seven=[0-9a-f]+ surface=[0-9a-f]+' | head -1)
[ "$U4V" = "seven=$(echo $S466 | cut -c1-8) surface=$(echo $U4SURF | cut -c1-8)" ] || die "U04's README values block ($U4V) is not the seven and the surface read off the receipts"
echo "  the seven: expected $S466 (../c7-unit31/receipts.sh's S466= line, as ../c9-unit04/receipts.sh reads it) · the old surface: expected $U4SURF (../c9-unit04/receipts.sh's SURF= line) · both = U04's README values block ($U4V)"

# ---- docker, ports, the guard: the baselines ----------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that socket? (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
iid() { dk image inspect --format '{{.Id}}' "$1" 2> /dev/null | cut -c8-19; }
[ "$(iid $IMG)" = 77f585114c32 ] || die "the image $IMG is not on this machine - this script never pulls"
[ "$IMG" = "$(sed -n 's/^IMG=\(postgres@sha256:[0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh)" ] || die "the image digest is not ../c9-unit04/receipts.sh's IMG= line"
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run"
[ -z "$(dk ps -aq --filter name=^/$CN\$ 2> /dev/null)" ] || die "a container named $CN exists before the run - an interrupted run's? docker -H \"\$DH\" rm -fv $CN"
TC0=1
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18881 18882 18883 18884 20578 20615 20940 20941 20942 20943 20944 20945 20946 20947 20948 20949 21280 21281 21282 21283 21284"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
for p in 20940 20941 20942 20943 20944 20945 20946 20947 20948 20949 21280 21281 21282 21283 21284; do [ -z "$(lsof -nP -iUDP:$p 2> /dev/null)" ] || die "UDP $p is bound"; done
[ "$(pgrep -x java | wc -l | tr -d ' ')" = 0 ] || die "a java process is running before this script starts one - not this script's; stop it first"
guard() { local r; r=$(pgrep -fl "^/bin/(ba)?sh (\./|.*/)(receipts|runrec)[.]sh" 2> /dev/null | $G -v "^$$ " || true)
  local l1; l1=$(sysctl -n vm.loadavg | awk '{ print $2 }')
  [ -z "$r" ] || die "S9.17: another receipt runs ($r) before $1 - this run stops; wait for it, never kill it"
  local w=0; while ! awk -v l="$l1" 'BEGIN { exit !(l < 20) }'; do
    [ -n "${GUARD0:-}" ] || die "R.480: load1 $l1 is not below 20 at the launch - a run of record launches only below 20; launch again when it is"
    w=$((w + 1)); [ $w -lt 900 ] || die "R.480: load1 stayed at or above 20 for 900 checks before $1"; sleep 1; l1=$(sysctl -n vm.loadavg | awk '{ print $2 }'); done
  GUARD0=1
  echo "  guard before $1: no other receipt · load1 $l1 (< 20)$( [ $w = 0 ] || echo " after $w checks at or above 20 (waited, never killed)")"; }
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · $IMG present (= U04's IMG=) · nothing pulled, ever · no Testcontainers container, no $CN · ports $PORTS free (TCP; the band and 21280-21284 UDP too) · no java process"

# ---- the trees, copied and built offline: before (through the link), after/, the tests copy; the harness and the plant, compiled ---------
M2="$PWD/.m2-demo"
if [ ! -d "$M2" ]; then [ -d "$SEED" ] || die "the seed $SEED is missing (README.md, The repository)"; cp -cR "$SEED" "$M2" 2> /dev/null || cp -R "$SEED" "$M2" || die "the seed could not be copied"; fi
NF0=$(find "$M2" -type f | wc -l | tr -d ' ')
for a in org/springframework/boot/spring-boot-starter-parent/4.1.3/spring-boot-starter-parent-4.1.3.pom org/apache/tomcat/embed/tomcat-embed-core/11.0.29/tomcat-embed-core-11.0.29.jar \
         org/eclipse/parsson/parsson/1.1.9/parsson-1.1.9.jar org/eclipse/parsson/parsson/1.1.7/parsson-1.1.7.jar jakarta/json/jakarta.json-api/2.1.3/jakarta.json-api-2.1.3.jar; do
  [ -f "$M2/$a" ] || die ".m2-demo holds no $a - it is not the U04 seed"; done
echo "  .m2-demo (a copy of the seed m2-seed-c9-u04): files $NF0 · the 4.1.3 parent, tomcat-embed-core 11.0.29, parsson 1.1.9 and 1.1.7, jakarta.json-api 2.1.3 present"
mkdir -p .harness; rm -rf .harness/before .harness/after .harness/tests .harness/run .harness/work .harness/hc .harness/pc-noevict .harness/plants
mkdir -p .harness/home .harness/run .harness/work .harness/plants/noevict
printf '%s\n' 'checks.disable=true' "tinyimage.container.image=$IMG" > .harness/home/.testcontainers.properties
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy before .harness/before; copy after .harness/after; copy after .harness/tests
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
[ -f "$DSP" ] || die "the harness's jar (datasource-proxy 1.11.1) is not in .m2-demo"
[ -n "$PGJ" ] || die "after/'s lib/ holds no PostgreSQL driver"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \"$CPA:$DSP\" harness/src/probe/*.java harness/src/probe/u05/*.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/'s jar: $(head -5 .harness/javac.log)"
FR=after/tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java
python3 -I - "$FR" .harness/plants/noevict/CustomerRepository.java <<'PY' || die "plant-noevict: the shipped update's @Caching block could not be removed"
import re, sys
s = open(sys.argv[1]).read()
blk = re.search(r"    @Caching\(evict = \{\n(?:            @CacheEvict\([^\n]*\n){3}", s)
assert blk and s.count("@Caching(evict") == 1
open(sys.argv[2], "w").write(s[:blk.start()] + s[blk.end():])
PY
echo "  plant-noevict = the shipped CustomerRepository with its update's @Caching block removed (the diff): $(diff $FR .harness/plants/noevict/CustomerRepository.java | $G '^[<>]' | sed 's/^< *//' | paste -sd'|' - | cut -c1-240)"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/pc-noevict -cp \"$CPA\" .harness/plants/noevict/CustomerRepository.java" .harness/javac-noevict.log
[ "$RE" = 0 ] || die "plant-noevict did not compile: $(head -5 .harness/javac-noevict.log)"
echo "  the harness compiled against after/'s jar ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes, javac 25 -parameters; datasource-proxy 1.11.1 from .m2-demo, on the harness's class path only; the PostgreSQL driver is the jar's own, $PGJ) · plant-noevict compiled ($(find .harness/pc-noevict -name '*.class' | wc -l | tr -d ' ') class)"

# ---- helpers ---------------------------------------------------------------------------------------------------------------------------
B() { echo "http://127.0.0.1:$1"; }
J=.harness/work
mark() { wc -l < ".harness/run/$1/jvm.log" | tr -d ' '; }
acount() { wc -l < ".harness/run/$1/access/access.log" 2> /dev/null | tr -d ' '; }
# the server's own lines for one request, after a mark (U03's srv, copied): wait for the access log's line, then every PROBE-REQ line
# since the mark, the resolver's lines (harness logging: ExceptionHandlerExceptionResolver at DEBUG) and JSON-P's words where the route logged them
srv() { local lab=$1 m=$2 a0=$3 i=0
  while [ "$(acount $lab)" -le "$a0" ]; do i=$((i + 1)); [ $i -lt 400 ] || { echo "     access: NO LINE"; break; }; sleep 0.02; done
  [ $i -ge 400 ] || echo "     access: $(sed -n "$(( a0 + 1 ))p" ".harness/run/$lab/access/access.log")"
  sed -n "$(( m + 1 )),\$p" ".harness/run/$lab/jvm.log" | $G -E "^PROBE-REQ [0-9]+ " | sed -E 's/^PROBE-REQ [0-9]+ /     server: /' | cut -c1-260
  sed -n "$(( m + 1 )),\$p" ".harness/run/$lab/jvm.log" | $G -oE 'Using @ExceptionHandler [A-Za-z0-9_.$]+#[A-Za-z0-9_]+\([^)]*\)|Resolved \[[A-Za-z0-9_.$]+' | sed -E 's/^Using @ExceptionHandler ([A-Za-z0-9_.$]+\.)?([A-Za-z0-9_$]+#[A-Za-z0-9_]+)\(.*$/     resolved by: \2/; s/^Resolved \[([A-Za-z0-9_$]+\.)*([A-Za-z0-9_$]+)$/     resolved: \2/'
  sed -n "$(( m + 1 )),\$p" ".harness/run/$lab/jvm.log" | $G -oE "JSON-P's words: .*" | sed -E "s/^/     log: /" | cut -c1-220; }
HSEL='^(Location|Allow|Accept-Patch|Content-Length):'
# ask LABEL METHOD PATH [curl args]: one request into its own (reset) header and body files (U03's ask, copied; Accept-Patch added to the
# headers it prints); where CK is set, both caches' keys before and after it (read by the harness's route, never through the cache)
ask() { local lab=$1 m=$2 p=$3 o=$J/$DB-$1 w rc mk a0 c0 c1; shift 3
  : > "$o.h"; : > "$o.b"; [ -z "${CK:-}" ] || c0=$(ck); mk=$(mark $L); a0=$(acount $L)
  w=$($CURL --http1.1 -sS -D "$o.h" -o "$o.b" -w '%{http_code} %{content_type} %{size_download}' --max-time 20 -X "$m" "$@" "$(B $P)$p" 2> "$o.err"); rc=$?
  echo "-- $lab | $m $p -> $w (curl exit $rc)"
  echo "     status lines: $(tr -d '\r' < "$o.h" | $G -E '^HTTP/' | sed 's/ *$//' | paste -sd'>' - | sed 's/>/ > /g')"
  tr -d '\r' < "$o.h" | $G -iE "$HSEL" | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' | while IFS= read -r h; do case "$h" in [Aa]llow:*|[Aa]ccept-[Pp]atch:*) echo "     header: $h · set {$(printf '%s' "${h#*:}" | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)}" ;; *) echo "     header: $h" ;; esac; done
  srv $L $mk $a0
  [ -z "${CK:-}" ] || { c1=$(ck); echo "     cache: before $c0 · after $c1"; }
  local n; n=$(wc -c < "$o.b" | tr -d ' ')
  if [ "$n" -le 330 ] && [ "$n" -gt 0 ]; then echo "     body: $(tr -d '\r' < "$o.b" | tr '\n' '~' | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/"timestamp":"[^"]*"/"timestamp":"<masked>"/')"; else echo "     body: $n B md5 $(md5 -q "$o.b")"; fi; }
probe() { $CURL -s "$(B $P)/probe/u05/$1"; }
ck() { probe cache | python3 -I -c 'import json,sys; d = json.load(sys.stdin); print("customers %s customer %s" % (d["customers"], d["customer"]))'; }
psqlq() { dk exec $CN psql -U tiffinbox -d "${2:-tiffinbox}" -qAt -c "$1" 2>&1 | tr '\n' ' ' | sed 's/ *$//'; }
# the second client: the customer row (name, meals a day, price a meal, meal type, version) - psql in the container on PostgreSQL, the
# harness's JdbcTemplate route /probe/row/{name} on H2 - never the cached routes
row() { if [ "$DB" = pg ]; then local x; x=$(psqlq "SELECT name || ' ' || meals_per_day || ' ' || price_per_meal || ' ' || meal_type || ' v' || version FROM customer WHERE name = '$1'"); echo "${x:-no row} (psql in $CN, the second client)"
  else echo "$($CURL -s "$(B $P)/probe/row/$1" | python3 -I -c 'import json,sys; r = [{k.lower(): v for k, v in x.items()} for x in json.load(sys.stdin)]; print(" ".join("%s %s %s %s v%s" % (x["name"], x["meals_per_day"], x["price_per_meal"], x["meal_type"], x["version"]) for x in r) or "no row")') (the harness's JdbcTemplate route /probe/row/$1, the second client)"; fi; }
rows() { if [ "$DB" = pg ]; then echo "$(psqlq "SELECT count(*) FROM customer WHERE name = '$1'") (psql in $CN, the second client)"; else echo "$(probe rows/$1 | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])') (the harness's JdbcTemplate route /probe/u05/rows/$1, the second client)"; fi; }
keyrows() { if [ "$DB" = pg ]; then echo "$(psqlq "SELECT count(*) FROM idempotency_key") (psql in $CN, the second client)"; else echo "$(probe keys | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])') (the harness's JdbcTemplate route /probe/u05/keys, the second client)"; fi; }
revenue() { $CURL -s "$(B $P)/revenue" | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["monthRevenue"])'; }
pgfresh() { psqlq "drop database if exists tiffinbox with (force)" postgres > /dev/null; psqlq "create database tiffinbox" postgres > /dev/null; }
pgup() { guard "the PostgreSQL container"
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:20941:5432 -e POSTGRES_DB=tiffinbox -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust $IMG" .harness/docker-run-pg.log
  [ "$RE" = 0 ] || die "the PostgreSQL container did not start: $(tail -2 .harness/docker-run-pg.log)"
  local i=0; while ! dk exec $CN pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 240 ] || die "PostgreSQL did not accept connections"; sleep 0.5; done
  [ "$(dk port $CN | paste -sd'|' -)" = '5432/tcp -> 127.0.0.1:20941' ] || die "$CN publishes on another address than 127.0.0.1:20941"
  echo "  $CN: PostgreSQL $(psqlq 'show server_version') by the digest, on 127.0.0.1:20941 alone (docker port), trust on the loopback (U04's form: no password exists to print), a fresh database"; }
# tb LABEL PORT DB HCX [args]: TiffinBox (the extracted jar of TREE=after unless TREE is set), from its own run folder with a generated token
# (a config tree, 0600, never printed), Tomcat's access log on (unbuffered, no time field: %m %U%q %s %b, S9.27); waited for by its
# Started line (never a health poll: the cache's cold state stays observable), or by health 200 where HEALTHUP is set
tb() { local label=$1 port=$2 db=$3 hcx=$4 t=${TREE:-after} run=.harness/run/$1 jx="" src="" i=0; shift 4
  guard "TiffinBox $label"
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox" "$run/access"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  local x="$U/.harness/$t/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  if [ -n "$hcx" ]; then cp="$hcx:$cp:$U/.harness/hc:$DSP"; src="--spring.main.sources=${SRC:-probe.Witness,probe.Http,probe.Routes,probe.Patch,probe.JsonProbe,probe.u05.U05Probe}"; fi
  [ "$db" = pg ] && jx="-Dtiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:20941/tiffinbox?user=tiffinbox"
  [ -n "${H2URL:-}" ] && jx="-Dtiffinbox.jdbc-url=$H2URL"
  (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 $jx -cp "$cp" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port="$port" $src \
     --server.tomcat.accesslog.enabled=true --server.tomcat.accesslog.directory="$U/$run/access" --server.tomcat.accesslog.prefix=access --server.tomcat.accesslog.suffix=.log \
     --server.tomcat.accesslog.file-date-format= --server.tomcat.accesslog.rotate=false "--server.tomcat.accesslog.pattern=%m %U%q %s %b" --server.tomcat.accesslog.buffered=false "$@" > jvm.log 2>&1) &
  local p=$!; echo $p > "$run/pid"; PIDS="$PIDS $p"
  if [ -n "${HEALTHUP:-}" ]; then
    while [ "$($CURL -s -o /dev/null -w '%{http_code}' --max-time 2 "$(B $port)/actuator/health" 2> /dev/null || true)" != 200 ]; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before health 200"; }; i=$((i + 1)); [ $i -lt 600 ] || die "$label: no health 200"; sleep 0.1; done
  else
    while ! $G -q -E 'Started TiffinBox(App|Server) in' "$run/jvm.log" 2> /dev/null; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before its Started line"; }; i=$((i + 1)); [ $i -lt 900 ] || die "$label: no Started line"; sleep 0.1; done
  fi
  echo "  $label up on $port ($db, tree $t$( [ -n "$hcx" ] && echo ", the harness joined")) · cap: alarm 900 (perl) · $($G -o -E 'Successfully applied [0-9]+ migrations[^(]*|Schema "[^"]*" is up to date[^.(]*' "$run/jvm.log" | head -1 | sed 's/ *$//')"
  echo "  version lines ($label): $($G -oE 'Starting Servlet engine: \[[^]]*\]|HHH000001: Hibernate ORM core version [0-9A-Za-z.]+' "$run/jvm.log" | paste -sd'|' -) · Boot $(ls .harness/$t/$XD/lib | sed -n 's/^spring-boot-\([0-9][0-9.]*\)\.jar$/\1/p') · Framework $(ls .harness/$t/$XD/lib | sed -n 's/^spring-core-\([0-9][0-9.]*\)\.jar$/\1/p') · database: $($G -m1 -oE 'Database: [^ ]+ \([^)]*\)' "$run/jvm.log" | sed -E 's/jdbc:[a-z0-9]+:[^ ]*/<url>/')"; }
tbstop() { local label=$1 port=$2 run=.harness/run/$1 p i=0; p=$(cat "$run/pid")
  if kill -0 "$p" 2> /dev/null; then printf 'X-Shutdown-Token: %s\n' "$(head -1 "$run/secrets/tiffinbox/shutdown-token")" | $CURL -s -o /dev/null --max-time 5 -H @- -X POST "$(B $port)/shutdown" || true; fi
  while kill -0 "$p" 2> /dev/null; do i=$((i + 1)); [ $i = 80 ] && kill "$p" 2> /dev/null; [ $i -lt 400 ] || { kill -9 "$p" 2> /dev/null; break; }; sleep 0.05; done
  wait "$p" 2> /dev/null || true; PIDS=$(echo " $PIDS " | sed "s/ $p / /g")
  [ "$(listeners $port)" = 0 ] || die "$label: something still listens on $port"; }
NCAPS=0; unpub=""; VALS=""
cap() { local nm=$1; shift
  if [ -n "${DEVCAPS:-}" ] && ! echo " $DEVCAPS " | $G -qF " $nm "; then return 0; fi   # development only: a run of record sets no DEVCAPS
  "$@" > .harness/cap-$nm.raw 2>&1 || true
  $G -q '^  \*\*\* ' .harness/cap-$nm.raw && { cat .harness/cap-$nm.raw >&3; die "$nm stopped (above)"; }
  mask < .harness/cap-$nm.raw > .r-$nm.new
  sed 's/^/  | /' .r-$nm.new | cut -c1-260
  local o e=0; o=$(python3 -I -B harness/chk05.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk05 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  $G -v '^ok \|^FAIL ' .harness/chk-$nm.out | sed 's/^/  chk05 /' || true
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; [ -n "${DEVCAPS:-}" ] && { echo "  (development: $nm's check failed, the run goes on)"; unpub="$unpub $nm"; } || die "$nm: its check failed (harness/chk05.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk05.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-11s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-11s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff its block in README.md against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }

# ---- the captures --------------------------------------------------------------------------------------------------------------------
MPT='Content-Type: application/merge-patch+json'; JPT='Content-Type: application/json-patch+json'; JSON='Content-Type: application/json'
MX="--logging.level.org.springframework.web.servlet.mvc.method.annotation.ExceptionHandlerExceptionResolver=DEBUG"   # harness logging, never shipped
API=/api/v1/customers

c_tests() { local f
  echo "== mvn -o clean verify on a copy of after/ (.harness/tests): Surefire's tests on H2 (Docker-free) at the test phase, then the five ITs; 21280-21284 and 18881-18884 asserted free before"
  for p in 21280 21281 21282 21283 21284 18881 18882 18883 18884; do [ "$(listeners $p)" = 0 ] && [ -z "$(lsof -nP -iUDP:$p 2> /dev/null)" ] || die "$p is bound before verify"; done
  guard "mvn verify"
  : > .harness/tcps.txt
  ( while :; do dk ps --filter label=org.testcontainers=true --format '{{.Ports}}' >> .harness/tcps.txt 2> /dev/null; sleep 1; done ) & pollpid=$!
  bg "cd .harness/tests && DOCKER_HOST=\"$DH\" TESTCONTAINERS_RYUK_DISABLED=true $MV \"$AL\" clean verify -pl tiffinbox-web -am" .harness/verify.log
  kill $pollpid 2> /dev/null; wait $pollpid 2> /dev/null; pollpid=""
  local vre=$RE; offl .harness/verify.log
  $G -q 'Timed out waiting' .harness/verify.log && echo "  an IT's wait TIMED OUT (S9.32: this run of record fails)"
  echo "  mvn verify exit $vre · Downloading/Downloaded from: 0 · Results: $($G -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures' .harness/verify.log | sed -E 's/^\[[A-Z]+\] //' | paste -sd'|' -)"
  echo "== Surefire's XML, per class (the test phase, H2)"
  for f in .harness/tests/tiffinbox-web/target/surefire-reports/TEST-*.xml; do python3 -I -B harness/chk05.py surefire "$f"; done
  echo "== Failsafe's XML, per class (the ITs)"
  for f in .harness/tests/tiffinbox-web/target/surefire-reports-it/TEST-*.xml; do python3 -I -B harness/chk05.py surefire "$f"; done
  $G -E '^IT BINDINGS ' .harness/verify.log | sort | sed 's/^/  /'
  echo "  Testcontainers' containers while verify ran (docker ps Ports, beside, never the witness): $(tr ', ' '\n\n' < .harness/tcps.txt | $G -oE '^[0-9.]+:[0-9]+' | sort -u | paste -sd' ' -)"
  echo "  Testcontainers containers after: $(dk ps -aq --filter label=org.testcontainers=true | wc -l | tr -d ' ') · listeners on 21280-21284 after: $(for p in 21280 21281 21282 21283 21284; do listeners $p; done | paste -sd+ - | bc)"
  echo "== BOOT-INF/lib before -> after"
  for t in before after; do echo "  $t: $(ls .harness/$t/$XD/lib | wc -l | tr -d ' ') jars · $(ls .harness/$t/$XD/lib | $G -E '^(spring-boot-[0-9]|spring-core-|tomcat-embed-(core|el|websocket)-|netty-common-|jackson-databind-|jackson-core-3|tools\.jackson|postgresql-|jakarta\.json-api-|parsson-)' | sort | paste -sd' ' -)"; done
  echo "  the jars whose names moved: $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c '^[<>]')"
  echo "== the handler methods on after/ (one flag start: mappings exposed, never shipped)"
  P=20940; tb flag 20940 h2 "" --management.endpoints.web.exposure.include=health,prometheus,mappings
  $CURL -s "$(B 20940)/actuator/mappings" | python3 -I -B harness/chk05.py mappings
  tbstop flag 20940; }

c_jsonp() { local t
  for t in before after; do
    echo "== $t: mvn -o dependency:tree -Dincludes=jakarta.json:jakarta.json-api,org.eclipse.parsson:parsson (tiffinbox-web; offline from the seed)"
    bg "cd .harness/$t && $MV dependency:tree -Dincludes=jakarta.json:jakarta.json-api,org.eclipse.parsson:parsson -pl tiffinbox-web -am" .harness/tree-$t.log
    offl .harness/tree-$t.log
    echo "  exit $RE"; sed -n '/tiffinbox-web ---/,/BUILD/p' .harness/tree-$t.log | $G -E '^\[INFO\] [-+\\| ]' | sed -E 's/^\[INFO\] /  /'
  done
  echo "== the pin: the parent's property, and the jar it names in BOOT-INF/lib"
  echo "  before: $($G -c 'parsson' .harness/before/pom.xml) parsson lines in the parent · after: $($G -n '<parsson.version>' after/pom.xml | sed 's/^ *//; s/  */ /g') · after's tiffinbox-web/pom.xml names \${parsson.version} $($G -c '<version>${parsson.version}</version>' after/tiffinbox-web/pom.xml) time(s) · jakarta.json-api with no version (Boot's jakarta-json.version $(sed -n 's/.*<jakarta-json.version>\(.*\)<\/jakarta-json.version>.*/\1/p' "$M2/org/springframework/boot/spring-boot-dependencies/4.1.3/spring-boot-dependencies-4.1.3.pom"))"
  echo "  the seed's Parsson versions: $(ls "$M2/org/eclipse/parsson/parsson" | paste -sd' ' -) · BOOT-INF/lib's: before $(ls .harness/before/$XD/lib | $G '^parsson-' | paste -sd' ' -) · after $(ls .harness/after/$XD/lib | $G '^parsson-' | paste -sd' ' -)"
  echo "== the provider a running JVM uses (the harness's /probe/u05/jsonp, after/ on H2)"
  echo "  $(probe jsonp)"; }

c_bodies() { echo "== $DB: the four bodies through TiffinBox's own POST /customers (@Valid @RequestBody Customer, JSON - the route unit 05 does not touch)"
  echo "  Jackson (the harness's JsonProbe, this JVM's start): $($G -m1 -oE "JSON Boot's mapper bean: .*" .harness/run/$L/jvm.log)"
  echo "  DeserializationFeature: $(python3 -I -B harness/chk05.py features < .harness/run/$L/jvm.log)"
  $G -E '^JSON read \[' .harness/run/$L/jvm.log | sed 's/^/  JsonProbe: /' | cut -c1-260
  ask b-int-absent POST /customers -H "$JSON" --data-binary '{"name":"Asha","pricePerMeal":120,"mealType":"VEGAN"}'
  ask b-int-null POST /customers -H "$JSON" --data-binary '{"name":"Asha","mealsPerDay":null,"pricePerMeal":120,"mealType":"VEGAN"}'
  ask b-text-absent POST /customers -H "$JSON" --data-binary '{"name":"Asha","mealsPerDay":1,"pricePerMeal":120}'
  ask b-text-null POST /customers -H "$JSON" --data-binary '{"name":"Asha","mealsPerDay":1,"pricePerMeal":120,"mealType":null}'
  echo "  rows Asha after the four: $(rows Asha)"; }

# the trap's three JVMs (one database each side, kept across them): trap-a (Boot's default), trap-b (the attribute switched off on the
# command line, once), trap-a2 (the default again); the naive harness route on Priya, the row by the second client and /revenue each time
c_trap() { local h2=""
  [ "$DB" = h2 ] && h2="jdbc:h2:file:./../../work/trap-h2;DB_CLOSE_DELAY=-1"   # relative to the JVM's run folder: no space in the URL
  P=20944; L=TA; H2URL=$h2 tb TA 20944 $DB "$U/.harness/hc" --probe.json=true "$MX"
  echo "== $DB trap-a: Boot's default JVM - $(python3 -I -B harness/chk05.py features < .harness/run/TA/jvm.log | $G -oE 'FAIL_ON_NULL_FOR_PRIMITIVES [a-z]+')"
  echo "  Priya before: $(row Priya) · /revenue $(revenue)"
  ask trap-a PATCH /probe/naive/customers/Priya -H "$JSON" --data-binary '{"mealsPerDay":2,"mealType":"VEGAN"}'
  echo "  Priya after trap-a: $(row Priya) · /revenue $(revenue)"
  echo "  Ravi before: $(row Ravi)"
  ask trap-text PATCH /probe/naive/customers/Ravi -H "$JSON" --data-binary '{"mealsPerDay":2,"pricePerMeal":150}'
  echo "  Ravi after the String-absent body: $(row Ravi)"
  tbstop TA 20944
  L=TB; H2URL=$h2 tb TB 20944 $DB "$U/.harness/hc" --probe.json=true "$MX" --spring.jackson.deserialization.fail-on-null-for-primitives=false
  echo "== $DB trap-b: the attribute switched off on the command line, once (R.444) - $(python3 -I -B harness/chk05.py features < .harness/run/TB/jvm.log | $G -oE 'FAIL_ON_NULL_FOR_PRIMITIVES [a-z]+')"
  echo "  Priya before: $(row Priya) · /revenue $(revenue)"
  ask trap-b-valid PATCH /probe/naivevalid/customers/Priya -H "$JSON" --data-binary '{"mealsPerDay":2,"mealType":"VEGAN"}'
  echo "  Priya after the @Valid copy: $(row Priya) · /revenue $(revenue)"
  ask trap-b PATCH /probe/naive/customers/Priya -H "$JSON" --data-binary '{"mealsPerDay":2,"mealType":"VEGAN"}'
  echo "  Priya after trap-b: $(row Priya) · /revenue $(revenue)"
  tbstop TB 20944
  L=TA2; H2URL=$h2 tb TA2 20944 $DB "$U/.harness/hc" --probe.json=true "$MX"
  echo "== $DB trap-a2: a fresh JVM, the default again - $(python3 -I -B harness/chk05.py features < .harness/run/TA2/jvm.log | $G -oE 'FAIL_ON_NULL_FOR_PRIMITIVES [a-z]+')"
  echo "  Priya before: $(row Priya) · /revenue $(revenue)"
  ask trap-a2 PATCH /probe/naive/customers/Priya -H "$JSON" --data-binary '{"mealsPerDay":2,"mealType":"VEGAN"}'
  echo "  Priya after trap-a2: $(row Priya) · /revenue $(revenue)"
  tbstop TA2 20944
  [ "$DB" = h2 ] && { rm -f $J/trap-h2*.db; echo "  the trap's H2 file removed"; }; true; }

c_merge() { echo "== $DB: the shipped merge patch (PATCH $API/{name}, application/merge-patch+json) on Meera; RFC 7396 :180-182 (rfc7396.txt md5 $(md5 -q "$C9R/_research/docs-2026-11-23/rfc7396.txt" | cut -c1-8)): $(sed -n 180,182p "$C9R/_research/docs-2026-11-23/rfc7396.txt" | tr -s ' ' | paste -sd' ' -)"
  echo "  Meera before: $(row Meera)"
  CK=1 ask m-meals PATCH $API/Meera -H "$MPT" --data-binary '{"mealsPerDay":2}'
  echo "  Meera after m-meals: $(row Meera)"
  ask m-type-null PATCH $API/Meera -H "$MPT" --data-binary '{"mealType":null}'
  ask m-price-null PATCH $API/Meera -H "$MPT" --data-binary '{"pricePerMeal":null}'
  ask m-price-text PATCH $API/Meera -H "$MPT" --data-binary '{"pricePerMeal":"abc"}'
  ask m-rule PATCH $API/Meera -H "$MPT" --data-binary '{"mealsPerDay":9}'
  ask m-notjson PATCH $API/Meera -H "$MPT" --data-binary '{"mealsPerDay":'
  ask m-unknown PATCH $API/Meera -H "$MPT" --data-binary '{"colour":"red"}'
  ask m-json PATCH $API/Meera -H "$JSON" --data-binary '{"mealsPerDay":3}'
  ask m-nobody PATCH $API/Nobody -H "$MPT" --data-binary '{"mealsPerDay":2}'
  echo "  Meera after the refused ones: $(row Meera)"
  echo "  RFC 5789 :355-357 (rfc5789.txt md5 $(md5 -q "$C9R/_research/docs-2026-11-23/rfc5789.txt" | cut -c1-8)): $(sed -n 355,356p "$C9R/_research/docs-2026-11-23/rfc5789.txt" | tr -s ' ' | paste -sd' ' -)"
  echo "== $DB: the harness's routes beside (the S1 probe's, never TiffinBox's): the JSON-P merge with the re-read unmapped, on Sunil"
  ask h-mergep-null PATCH /probe/mergep/customers/Sunil -H "$MPT" --data-binary '{"pricePerMeal":null}'
  ask h-mergep-notjson PATCH /probe/mergep/customers/Sunil -H "$MPT" --data-binary '{"mealsPerDay":'
  echo "  Sunil after: $(row Sunil)"; }

c_jsonpatch() { echo "== $DB: the shipped JSON Patch (PATCH $API/{name}, application/json-patch+json) on Meera; RFC 6902 (rfc6902.txt md5 $(md5 -q "$C9R/_research/docs-2026-11-23/rfc6902.txt" | cut -c1-8)) :185-187 $(sed -n 185,186p "$C9R/_research/docs-2026-11-23/rfc6902.txt" | tr -s ' ' | paste -sd' ' -) · :366-367 $(sed -n 366,367p "$C9R/_research/docs-2026-11-23/rfc6902.txt" | tr -s ' ' | paste -sd' ' -)"
  echo "  Meera before: $(row Meera)"
  ask j-replace PATCH $API/Meera -H "$JPT" --data-binary '[{"op":"replace","path":"/mealsPerDay","value":1}]'
  echo "  Meera after j-replace: $(row Meera)"
  ask j-test PATCH $API/Meera -H "$JPT" --data-binary '[{"op":"test","path":"/mealsPerDay","value":9},{"op":"replace","path":"/mealsPerDay","value":2}]'
  echo "  Meera after j-test: $(row Meera)"
  echo "  RFC 5789 :292-294: $(sed -n 292,294p "$C9R/_research/docs-2026-11-23/rfc5789.txt" | tr -s ' ' | paste -sd' ' -)"
  ask j-remove PATCH $API/Meera -H "$JPT" --data-binary '[{"op":"remove","path":"/mealType"}]'
  ask j-null PATCH $API/Meera -H "$JPT" --data-binary '[{"op":"replace","path":"/pricePerMeal","value":null}]'
  ask j-text PATCH $API/Meera -H "$JPT" --data-binary '[{"op":"replace","path":"/pricePerMeal","value":"abc"}]'
  ask j-op PATCH $API/Meera -H "$JPT" --data-binary '[{"op":"frobnicate","path":"/mealsPerDay","value":2}]'
  ask j-novalue PATCH $API/Meera -H "$JPT" --data-binary '[{"op":"replace","path":"/mealsPerDay"}]'
  ask j-nomember PATCH $API/Meera -H "$JPT" --data-binary '[{"op":"replace","path":"/colour","value":2}]'
  ask j-object PATCH $API/Meera -H "$JPT" --data-binary '{"op":"replace","path":"/mealsPerDay","value":2}'
  ask j-notjson PATCH $API/Meera -H "$JPT" --data-binary '[{"op":'
  ask j-json PATCH $API/Meera -H "$JSON" --data-binary '[{"op":"replace","path":"/mealsPerDay","value":2}]'
  echo "  Meera after the refused ones: $(row Meera)"
  echo "  RFC 6902 :419-422: $(sed -n 419,420p "$C9R/_research/docs-2026-11-23/rfc6902.txt" | tr -s ' ' | paste -sd' ' -)"
  echo "== $DB: the harness's JSON Patch route beside (the S1 probe's: JsonNode read by Spring MVC, JSON-P's exception printed), on Sunil"
  ask h-jp-op PATCH /probe/jsonpatch/customers/Sunil -H "$JPT" --data-binary '[{"op":"frobnicate","path":"/mealsPerDay","value":2}]'
  ask h-jp-novalue PATCH /probe/jsonpatch/customers/Sunil -H "$JPT" --data-binary '[{"op":"replace","path":"/mealsPerDay"}]'
  ask h-jp-nomember PATCH /probe/jsonpatch/customers/Sunil -H "$JPT" --data-binary '[{"op":"remove","path":"/colour"}]'
  ask h-jp-test PATCH /probe/jsonpatch/customers/Sunil -H "$JPT" --data-binary '[{"op":"test","path":"/mealsPerDay","value":9}]'
  ask h-jp-object PATCH /probe/jsonpatch/customers/Sunil -H "$JPT" --data-binary '{"op":"replace","path":"/mealsPerDay","value":2}'
  echo "  Sunil after: $(row Sunil)"; }

c_retry() { echo "== $DB: each patch sent twice, on Ravi; no request carries a key header; RFC 5789 :132-133: $(sed -n 132,133p "$C9R/_research/docs-2026-11-23/rfc5789.txt" | tr -s ' ' | paste -sd' ' -)"
  echo "  Ravi before: $(row Ravi)"
  ask r-merge-1 PATCH $API/Ravi -H "$MPT" --data-binary '{"mealsPerDay":3}'
  echo "  Ravi after r-merge-1: $(row Ravi)"
  ask r-merge-2 PATCH $API/Ravi -H "$MPT" --data-binary '{"mealsPerDay":3}'
  echo "  Ravi after r-merge-2: $(row Ravi)"
  ask r-tr-1 PATCH $API/Ravi -H "$JPT" --data-binary '[{"op":"test","path":"/mealsPerDay","value":3},{"op":"replace","path":"/mealsPerDay","value":1}]'
  echo "  Ravi after r-tr-1: $(row Ravi)"
  ask r-tr-2 PATCH $API/Ravi -H "$JPT" --data-binary '[{"op":"test","path":"/mealsPerDay","value":3},{"op":"replace","path":"/mealsPerDay","value":1}]'
  echo "  Ravi after r-tr-2: $(row Ravi)"
  echo "  key table rows: $(keyrows)"; }

renamesteps() { local new=$1
  CK=1 ask w-old GET /customers/Meera
  CK=1 ask w-list GET /customers
  echo "  Meera before: $(row Meera) · $new: $(rows $new)"
  CK=1 ask rename PATCH $API/Meera -H "$MPT" --data-binary "{\"name\":\"$new\"}"
  echo "  rows Meera $(rows Meera) · rows $new $(rows $new)"
  CK=1 ask old GET /customers/Meera
  CK=1 ask new GET /customers/$new
  CK=1 ask list GET /customers; }
c_rename() { echo "== $DB: the shipped rename (merge patch {\"name\":\"Mira\"}) on Meera, warm first; unit 04's transaction-aware proxy on (the default, tiffinbox.cache.transaction-aware unset)"
  renamesteps Mira
  ask taken PATCH $API/Mira -H "$MPT" --data-binary '{"name":"Ravi"}'
  echo "  rows Ravi $(rows Ravi) · rows Mira $(rows Mira)"
  echo "  the order step (Course 8 unit 08's): read by the keys before and after each request only; U04's order capture holds the keys inside the transaction"; }
c_stale() { echo "== $DB: the planted no-evict copy (the shipped CustomerRepository with its update's @Caching removed - the harness's plant, never TiffinBox's) on Meera, warm first"
  echo "  the class path's first entry: .harness/pc-noevict ($(find .harness/pc-noevict -name '*.class' | sed 's#.*/##' | paste -sd' ' -))"
  renamesteps Mira
  echo "  the configured time to live (application.yaml, read back): $($G -n 'spec: maximumSize' after/tiffinbox-web/src/main/resources/application.yaml | sed 's/^ *//; s/  */ /g') · the running cache's policy: $(probe cache | python3 -I -c 'import json,sys; d = json.load(sys.stdin); print("customers.expireAfterWrite %s customer.expireAfterWrite %s" % (d["customers.expireAfterWrite"], d["customer.expireAfterWrite"]))')"; }

c_reader() { echo "== $DB: readerForUpdating behind the harness's route (the S1 probe's /probe/reader, never TiffinBox's) on Sunil; JsonProbe's line: $($G -m1 -oE 'JSON readerForUpdating\(record\) .*' .harness/run/$L/jvm.log)"
  echo "  Sunil before: $(row Sunil)"
  ask rd-meals PATCH '/probe/reader/customers/Sunil?mapped=1' -H "$MPT" --data-binary '{"mealsPerDay":2}'
  ask rd-type-null PATCH '/probe/reader/customers/Sunil?mapped=1' -H "$MPT" --data-binary '{"mealType":null}'
  ask rd-price-null-unmapped PATCH '/probe/reader/customers/Sunil?mapped=0' -H "$MPT" --data-binary '{"pricePerMeal":null}'
  ask rd-price-null PATCH '/probe/reader/customers/Sunil?mapped=1' -H "$MPT" --data-binary '{"pricePerMeal":null}'
  ask rd-unknown PATCH '/probe/reader/customers/Sunil?mapped=1' -H "$MPT" --data-binary '{"colour":"red"}'
  ask rd-rename PATCH '/probe/reader/customers/Sunil?mapped=1' -H "$MPT" --data-binary '{"name":"Sunny"}'
  echo "  Sunil after: $(row Sunil)"
  echo "== $DB: the shipped route, the same bodies, on Sunil"
  ask sr-meals PATCH $API/Sunil -H "$MPT" --data-binary '{"mealsPerDay":3}'
  ask sr-type-null PATCH $API/Sunil -H "$MPT" --data-binary '{"mealType":null}'
  ask sr-price-null PATCH $API/Sunil -H "$MPT" --data-binary '{"pricePerMeal":null}'
  ask sr-unknown PATCH $API/Sunil -H "$MPT" --data-binary '{"colour":"red"}'
  ask sr-rename PATCH $API/Sunil -H "$MPT" --data-binary '{"name":"Sunny"}'
  echo "  rows Sunil $(rows Sunil) · rows Sunny $(rows Sunny)"; }

c_matrix() { python3 -I -B harness/chk05.py view matrix .r-mergepg.new .r-jsonpatchpg.new .r-retrypg.new .r-renamepg.new .r-merge.new .r-jsonpatch.new .r-retry.new .r-rename.new; }

movedside() { local side=$1 port=$2
  HEALTHUP=1 TREE=$side tb moved-$side $port h2 ""
  local q
  for q in "PATCH /customers" "PATCH /customers/Ravi" "PATCH /revenue" "PATCH /shutdown" "OPTIONS /customers/Ravi" "OPTIONS $API/Ravi" "GET $API/Ravi"; do
    set -- $q; : > $J/mv.h
    local w; w=$($CURL --http1.1 -sS -D $J/mv.h -o /dev/null -w '%{http_code} %{content_type}' --max-time 10 -X "$1" -H "$MPT" --data-binary '{"mealsPerDay":2}' "$(B $port)$2")
    [ "$1" = PATCH ] || w=$($CURL --http1.1 -sS -D $J/mv.h -o /dev/null -w '%{http_code} %{content_type}' --max-time 10 -X "$1" "$(B $port)$2")
    echo "  $side | $q -> $w · Allow {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Aa]llow: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)} · Accept-Patch {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Aa]ccept-[Pp]atch: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)}"
  done
  tbstop moved-$side $port; }
c_moved() { echo "== the old addresses' PATCH rows (U02's table) and OPTIONS /customers/Ravi, on before (20946) and after/ (20940), H2, each its own JVM; the new address beside (a merge-patch body on every PATCH)"
  movedside before 20946; movedside after 20940; }

# inert: the seven and the old surface (no key header) on before and after/, one JVM per request set (R.97), health-polled as U04's were
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
inert1() { local side=$1 tree=$2 port=$3 hcx=${4:-}
  HEALTHUP=1 TREE=$tree tb seven-$side $port h2 "$hcx"
  sh $CURLSET $port .harness/run/seven-$side/secrets/tiffinbox/shutdown-token > $J/seven-$side.txt 2>&1
  local i=0; while kill -0 "$(cat .harness/run/seven-$side/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 400 ] || die "seven-$side: the seven's POST /shutdown did not stop it"; sleep 0.05; done
  tbstop seven-$side $port
  HEALTHUP=1 TREE=$tree tb surface-$side $port h2 "$hcx"
  oldsurface2 $port $J/surface-$side.txt
  tbstop surface-$side $port
  echo "  $side: the seven $(md5 -q $J/seven-$side.txt) ($(wc -l < $J/seven-$side.txt | tr -d ' ') lines) · the old surface $(md5 -q $J/surface-$side.txt) ($($G -c '^== ' $J/surface-$side.txt) requests, $(wc -l < $J/surface-$side.txt | tr -d ' ') lines)"; }
c_inert() {
  echo "== the seven and the old surface (no key header), each set in its own JVM, H2: the expected seven $S466, the old surface $U4SURF (U04's)"
  inert1 before before 20946 ""; inert1 after after 20940 ""
  echo "  before -> after/: the seven $(cmp -s $J/seven-before.txt $J/seven-after.txt && echo equal || echo DIFFER) · the old surface $(cmp -s $J/surface-before.txt $J/surface-after.txt && echo equal || echo DIFFER)"
  diff $J/surface-before.txt $J/surface-after.txt | sed 's/^/    moved: /'
  echo "== the self-test (S9.14, the harness's plant - LABELLED, not a finding about TiffinBox): a ShallowEtagHeaderFilter on /* (probe.Etag, U04's), after/, on 20943"
  SRC=probe.Etag HEALTHUP=1 tb seven-etag 20943 h2 "$U/.harness/hc"
  sh $CURLSET 20943 .harness/run/seven-etag/secrets/tiffinbox/shutdown-token > $J/seven-etag.txt 2>&1
  local i=0; while kill -0 "$(cat .harness/run/seven-etag/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 400 ] || die "seven-etag did not stop"; sleep 0.05; done; tbstop seven-etag 20943
  SRC=probe.Etag HEALTHUP=1 tb surface-etag 20943 h2 "$U/.harness/hc"; oldsurface2 20943 $J/surface-etag.txt; tbstop surface-etag 20943
  echo "  planted: the seven $(md5 -q $J/seven-etag.txt) (unchanged: $(cmp -s $J/seven-etag.txt $J/seven-after.txt && echo yes || echo NO)) · the old surface $(md5 -q $J/surface-etag.txt) (moved: $(cmp -s $J/surface-etag.txt $J/surface-after.txt && echo NO || echo yes)) · the feed's line: $($G '^== GET /customers/feed' $J/surface-etag.txt | sed -E 's/^== //')"; }

# the exercise: patch.sh as shipped (broken), SOLUTION.md's line in its place (solved), and four refused "solutions" - patch.sh with one
# line changed - against TiffinBox's jar alone on 20948 (no harness, H2 in memory, a fresh JVM per try), env -i, from the exercise's folder,
# under bash then zsh -f
c_exercise() { local v sh d o
  for sh in bash zsh; do
    for v in broken solved jsonpatch typenull mealstext other; do
      d=$J/ex-$v-$sh; rm -rf $d; mkdir -p $d/exercise; cp exercise/patch.sh exercise/check.sh $d/exercise/
      case $v in broken) : ;;
        solved) swapline exercise/patch.sh "$(block exercise/SOLUTION.md)" '^curl .*-X PATCH' > $d/exercise/patch.sh ;;
        jsonpatch) swapline exercise/patch.sh "$(block exercise/SOLUTION.md | sed 's#application/merge-patch+json#application/json-patch+json#')" '^curl .*-X PATCH' > $d/exercise/patch.sh ;;
        typenull) swapline $d/exercise/patch.sh "BODY='{\"mealsPerDay\":2,\"mealType\":null}'" '^BODY=' > $d/b; swapline $d/b "$(block exercise/SOLUTION.md)" '^curl .*-X PATCH' > $d/exercise/patch.sh ;;
        mealstext) swapline $d/exercise/patch.sh "BODY='{\"mealsPerDay\":\"two\"}'" '^BODY=' > $d/b; swapline $d/b "$(block exercise/SOLUTION.md)" '^curl .*-X PATCH' > $d/exercise/patch.sh ;;
        other) swapline $d/exercise/patch.sh "WHO=Ravi" '^WHO=' > $d/b; swapline $d/b "$(block exercise/SOLUTION.md)" '^curl .*-X PATCH' > $d/exercise/patch.sh ;; esac
      echo "== the exercise, $v, $sh (env -i, from the exercise's folder, TiffinBox's jar alone on 20948, H2; a stale patch.status planted first; patch.sh vs shipped: $(diff exercise/patch.sh $d/exercise/patch.sh | $G -c '^[<>]') changed lines):"
      tb ex-$v-$sh 20948 h2 "" > /dev/null
      echo 200 > $d/exercise/patch.status
      if [ $sh = bash ]; then o=$(cd $d/exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=20948 bash -c 'sh check.sh; echo "check exit $?"' 2>&1); else o=$(cd $d/exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=20948 /bin/zsh -f -c 'sh check.sh; echo "check exit $?"' 2>&1); fi
      printf '%s\n' "$o" | sed 's/^/  /'
      tbstop ex-$v-$sh 20948
    done
  done
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures${DEVCAPS:+ (DEVELOPMENT: only $DEVCAPS - not a run of record)}"
cap tests c_tests
pgup
DB=pg; P=20942; L=MP
tb MP 20942 pg "$U/.harness/hc" --probe.json=true "$MX"
echo "  cache before any request: $(ck) · then one GET /actuator/health (a counted step of its own): $($CURL -s -o /dev/null -w '%{http_code}' "$(B 20942)/actuator/health") · cache after it: $(ck)"
cap bodiespg c_bodies
cap mergepg c_merge
cap jsonpatchpg c_jsonpatch
cap retrypg c_retry
cap renamepg c_rename
tbstop MP 20942
pgfresh; DB=pg; cap trappg c_trap
pgfresh; DB=pg; P=20945; L=SP; tb SP 20945 pg "$U/.harness/pc-noevict:$U/.harness/hc" --probe.json=true "$MX"
cap stalepg c_stale
tbstop SP 20945
dk rm -fv $CN > /dev/null 2>&1 || die "$CN could not be removed"
DB=h2; P=20940; L=M
tb M 20940 h2 "$U/.harness/hc" --probe.json=true "$MX"
echo "  cache before any request: $(ck) · then one GET /actuator/health (a counted step of its own): $($CURL -s -o /dev/null -w '%{http_code}' "$(B 20940)/actuator/health") · cache after it: $(ck)"
cap jsonp c_jsonp
cap bodies c_bodies
cap merge c_merge
cap jsonpatch c_jsonpatch
cap retry c_retry
cap rename c_rename
cap reader c_reader
tbstop M 20940
DB=h2; cap trap c_trap
DB=h2; P=20945; L=S; tb S 20945 h2 "$U/.harness/pc-noevict:$U/.harness/hc" --probe.json=true "$MX"
cap stale c_stale
tbstop S 20945
cap matrix c_matrix
cap moved c_moved
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
MDB=$(find . ../c9-tiffinbox ../c9-unit04 -name '*.mv.db' -not -path './.harness/*' 2> /dev/null | wc -l | tr -d ' ')
[ "$MDB" = 0 ] || die "an H2 file outside .harness/"
VALS="$VALS
static: $STV
build: seed_files=$NF0"
[ -n "${DEVCAPS:-}" ] && { printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'; echo "c9-unit05: DEVELOPMENT run ($DEVCAPS) - nothing published"; exit 2; }
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
VO=$(python3 -I -B harness/chk05.py values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; die "README.md's values block is not this run's (harness/chk05.py values)"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM of this run, ports free, no container left, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1 · the anchor against after/ as at the start · the tree pins · *.mv.db outside .harness 0 · the values block = this run's"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit05: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit05: every capture = published ($NCAPS) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"
