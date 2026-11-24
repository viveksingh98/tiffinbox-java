#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 03 "Status Codes That Mean Something" - this unit's receipts. NO anchor change: before/ and after/ are both links to
# ../c9-unit04/after (U04's frozen anchor - Spring Boot 4.1.3, Framework 7.0.11, Tomcat 11.0.29, the key filter present and inert
# without its header), pinned by harness/tree03.py against ../c9-unit04/receipts.md5's after-tree line (Course 8 U23's two-link form,
# as U01 and U02 did). The measured tree is a copy of after/ under .harness/, built offline (mvn -o clean package -DskipTests -pl
# tiffinbox-web -am) from a cp -c copy of the seed; nothing is built in place; it is the ONLY build (no test copy, no suite, no verify).
# The harness (harness/src/probe/*, joined by --spring.main.sources, never in the jar): the statement witness (Witness) and the
# request witness (Http, PROBE-REQ lines, ERROR dispatches too) and the ShallowEtag plant (Etag) - copied from U02's harness (= U04's)
# byte for byte, md5-asserted - and U03's four labelled routes (probe.u03.U03Probe: the cache's keys, the key table's rows, a name's
# row count, and boom - the harness's 500). Harness logging, never shipped: ExceptionHandlerExceptionResolver at DEBUG on the
# matrix JVMs' command line (its "Using @ExceptionHandler" line names the advice that wrote a body).
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5):
#   matrixpg  the status matrix - every request of the unit, PostgreSQL's JVM · matrix  the same on H2 (the default run)
#   census authors six conditional limits cannot five inert instance cross   read off both matrix captures (PostgreSQL first)
#   seven     c5-unit11's comparison set on after/ · surface  the old surface, its feed read by a count condition (+ the S9.14 plant)
#   exercise  exercise/README.md's ask, SOLUTION.md's line, and four refused "solutions", under bash and zsh -f
# Ports (Course 9's U03 band, 20920-20929): 20920 TiffinBox after/ on H2 (the matrix; seven, surface each in its own JVM) · 20921
# PostgreSQL c9u03-pg · 20922 TiffinBox after/ on PostgreSQL · 20923 the S9.14 plant's JVMs · 20924, 20925, 20927 asserted free · 20926
# never bound (before/ and after/ are one tree: no before/ JVM) · 20928 the exercise · 20929 never bound. Course 8's 20578 / 20615,
# U04's 21280-21289, the probes' 21300-21399 and 18881-18884 are never bound.
# No request of this script carries the key header (S9.21) and none goes to U04's routes (S9.3): the key table's rows are read after
# every matrix, by a second client.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
C9R=${C9R:-"/Users/$ME/Downloads/Youtube Content/LearnProgrammingWithVivek/rest-apis-done-right"}   # the course's folder (briefs, research)
SEED=${SEED:-"$C9R/_research/m2-seed-c9-u04"}   # the course's seed (B5b)
BRI="$C9R/_research/boundary-2026-11-24/instruments/probe-src"
LEDGER="$C9R/_briefs/PROMISE-LEDGER-2026-11-24.md"
export C9R                                            # chk03.py reads the boundary's census, the brief and the filed RFCs under it
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c9u03-pg
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
PIDS=""; TC0=""; INTR=""; mpid=""
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "curlset.sh") || $3 ~ /(^|\/)javac$/) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
ctrm() { [ -n "$TC0" ] || return 0; [ -z "$(dk ps -aq --filter name=^/$CN\$ 2> /dev/null)" ] || dk rm -fv "$CN" > /dev/null 2>&1 || true; }
trap 'trap "" INT TERM; for p in $mpid $PIDS; do [ -z "$p" ] || killtree "$p"; done; for p in $mpid $PIDS; do if kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; ctrm; [ -z "$INTR" ] || rm -f .r-*.new; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git od unzip /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit03 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"

# ---- gates before anything is built: the folder, the links, the pins, the static check, the prose, the exercise ------------------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk03.py dur9.py s903.py src tree03.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
[ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe/Etag.java probe/Http.java probe/Witness.java probe/u03/U03Probe.java' ] || die "harness/src holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md ask.sh check.sh' ] || die "exercise/ holds another file, or misses one"
for t in before after; do
  [ -L "$t" ] || die "$t is not a link - unit 03 measures ../c9-unit04/after through a link, never a copy"
  [ "$(readlink "$t")" = ../c9-unit04/after ] || die "$t's link text is \"$(readlink "$t")\", not ../c9-unit04/after"
  [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/ - never built in place"; true; done
echo "  before -> $(readlink before) · after -> $(readlink after) (links, the text exact; no secrets/, target/ or .m2-demo/ behind them)"
$G -v '^ *#' harness/src/probe/*.java harness/src/probe/u03/*.java | $G -q 'Thread\.sleep' && die "R.412: a Thread.sleep in the harness"
for f in Witness Http Etag; do w=$(awk -v n="harness/src/probe/$f.java" '$1 == "file" && $2 == n { print $3 }' ../c9-unit02/receipts.md5)
  [ "$(md5 -q harness/src/probe/$f.java)" = "$w" ] || die "harness/src/probe/$f.java is not U02's published file (../c9-unit02/receipts.md5)"
  [ "$(md5 -q harness/src/probe/$f.java)" = "$(md5 -q ../c9-unit04/harness/src/probe/$f.java)" ] || die "harness/src/probe/$f.java is not U04's byte for byte"; done
echo "  harness/src/probe/{Witness,Http,Etag}.java = ../c9-unit02/receipts.md5's file lines = ../c9-unit04/harness/src/probe's (md5 $(md5 -q harness/src/probe/Witness.java | cut -c1-8) $(md5 -q harness/src/probe/Http.java | cut -c1-8) $(md5 -q harness/src/probe/Etag.java | cut -c1-8)) - copied from U02's harness"
$G -q 'shouldNotFilterErrorDispatch' harness/src/probe/Http.java && $G -qF '" [dispatch " + req.getDispatcherType()' harness/src/probe/Http.java || die "Http.java does not print ERROR dispatches (S9.25 amended)"
BOOM='        throw new IllegalStateException("probe: a planted failure (the harness'"'"'s labelled 500)");'
if [ -f "$BRI/Routes.java" ]; then [ "$(awk '$2 == "Routes.java" { print $1 }' "$BRI/MD5SUMS")" = "$(md5 -q "$BRI/Routes.java")" ] || die "the boundary's durable Routes.java is not its MD5SUMS line"
  $G -qxF -- "$BOOM" "$BRI/Routes.java" || die "the boundary's Routes.java no longer holds boom()'s throw"
  BN="= the boundary's durable probe-src/Routes.java's boom() throw (Routes.java md5 $(md5 -q "$BRI/Routes.java" | cut -c1-8) = its MD5SUMS line)"
else BN="(the boundary's durable probe sources are not on this machine: receipts.md5's file line is the pin)"; fi
[ "$($G -cxF -- "$BOOM" harness/src/probe/u03/U03Probe.java)" = 1 ] || die "U03Probe.java's boom() throw is not the probe's line"
echo "  harness/src/probe/u03/U03Probe.java: the cache and keys routes from U02's U02Probe, row and boom from the S1 probe's Routes.java; boom's throw $BN"
[ "$(sed -n '5,$p' harness/tree03.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit04/harness/tree04.py | md5 -q)" ] || die "harness/tree03.py's code is not tree04.py's"
[ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit04/harness/dur9.py)" ] && [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit02/harness/dur9.py)" ] && [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit01/harness/dur9.py)" ] || die "harness/dur9.py is not U04's / U02's / U01's copy (dur9 as shipped)"
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"
  [ ! -f "$C9R/_builders/dur9.py" ] || [ "$(md5 -q "$C9R/_builders/dur9.py")" = "$D9" ] || die "harness/dur9.py is not C9/_builders/dur9.py"
else D9N="(the registry is not on this machine: U04's copy is the pin)"; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit04, ../c9-unit02 and ../c9-unit01's copies $D9N · tree03.py's code = tree04.py's"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit04/receipts.md5)
[ -n "$UA" ] || die "../c9-unit04/receipts.md5 has no after-tree line"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree03.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line"
  [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit04/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree03.py $dir/ -> $got = receipts.md5's $nm line = ../c9-unit04/receipts.md5's after-tree line"; }
anchortree() { pin before-tree before; pin after-tree after
  local AD; AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after/ ../c9-tiffinbox 2>&1 || true)
  echo "  after/ (= ../c9-unit04/after) against ../c9-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures ../c9-unit04/after' )"; }
anchortree
HF="harness/chk03.py harness/s903.py harness/tree03.py harness/dur9.py harness/src/probe/Witness.java harness/src/probe/Http.java harness/src/probe/Etag.java harness/src/probe/u03/U03Probe.java exercise/ask.sh exercise/check.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's scripts: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
ST=$(python3 -I -B harness/chk03.py static "$LEDGER") || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s903.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U03 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s903, per sentence): /'
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
G1="An author: which part of the server wrote these bytes."
[ "$($G -cxF -- "$G1" README.md)" = 1 ] || die "the gloss (SECTION SHAPE 03, S1B :385) must stand in README.md once, as a line of its own, byte for byte: $G1"
HOOK=$(python3 -I -B harness/chk03.py hook); EXQ=$(python3 -I -B harness/chk03.py exq)
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S1B :273), byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SP=$(python3 -I -B harness/chk03.py spoken "$HOOK" "$EXQ" "$G1") || die "the spoken lines: $(printf '%s\n' "$SP" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$SP" | $G -v '^VALUES ' | sed 's/^/  /'
printf '%s\n\n%s\n' "$HOOK" "$EXQ" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s903.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
printf '%s\n' "$SW" | tail -1 | $G -qE ' refused: 0$' || die "a refused reading in a spoken line: $(printf '%s\n' "$SW" | $G ' line ' | head -3 | paste -sd';' -)"
echo "  the two spoken lines through s903.py (every family, dur9 inside it): refused 0"; rm -f .r-lock/spoken.md
block() { awk '/^```(bash|sh)$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
SETX=$(block exercise/README.md); SOLX=$(block exercise/SOLUTION.md)
[ -n "$SETX" ] && [ -n "$SOLX" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
[ "$(printf '%s\n' "$SOLX" | wc -l | tr -d ' ')" = 1 ] || die "R.196: SOLUTION.md's block must be the one fixed line"
[ "$($G -c '^curl .*-o ask\.body' exercise/ask.sh)" = 1 ] || die "exercise/ask.sh: one asking line (the line the fix changes)"
$G -q -- '-H "If-None-Match: $ETAG"' exercise/ask.sh || die "exercise/ask.sh: the broken form - If-None-Match with its own ETag"
SOLV=$(XN="$SOLX" python3 -I -c 'import os, re, sys; f = open("exercise/ask.sh").read().split("\n"); i = [k for k, l in enumerate(f) if re.match(r"^curl .*-o ask\.body", l)]; assert len(i) == 1; f[i[0]] = os.environ["XN"]; sys.stdout.write("\n".join(f))')
[ "$(diff exercise/ask.sh <(printf '%s\n' "$SOLV") | $G -c '^[<>]')" = 2 ] || die "R.196: SOLUTION.md's line must change ask.sh's asking line and nothing else"
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
$G -qE '^rm -f ask\.status ask\.bytes' exercise/check.sh || die "exercise/check.sh must remove the saved files before it runs the ask"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket"
DK=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -vF 'echo "' | $G -nE '(^|[ ;(])docker (run|exec|rm|ps|port|info|images|volume|image|pull|logs|inspect)\b' | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.344: receipts.sh calls docker without the pinned socket: $DK"
RMF=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) rm( +-[a-z]+)*' | sort -u | paste -sd'|' -)
[ "$RMF" = 'dk rm -fv' ] || die "R.387: receipts.sh removes a container without its volumes (found: ${RMF:-none})"
[ "$($G -v '^ *#' receipts.sh | $G -oE '(dk|docker) run -[^"]*' | $G -vcF -- '--pull never' || true)" = 0 ] || die "R.344: a dk run without --pull never"
MVA=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -F '$MV ' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am"
[ "$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -cF '$MV ' || true)" = 1 ] || die "ONE build: receipts.sh names the Maven command once"
KW='idempotency''-key'; KH=$($G -v '^ *#' receipts.sh exercise/ask.sh exercise/check.sh | $G -ciF "$KW" || true)
[ "$KH" = 0 ] || die "S9.21: a line of receipts.sh or the exercise names the key header ($KH) - unit 03 sends no key on any request"
AP=$($G -v '^ *#' receipts.sh exercise/ask.sh | $G -vF '$G -' | $G -cE '/api/v1|/probe/pauses' || true)
[ "$AP" = 0 ] || die "S9.3: a line of receipts.sh or the exercise asks one of U04's routes ($AP)"
echo "  the exercise: SOLUTION.md's line = ask.sh's asking line changed, nothing else; ask.sh broken as shipped (If-None-Match, its own ETag); check.sh removes the saved files first; the two What-it-prints blocks differ · the gloss, the hook and the exercise's line byte for byte · placeholders 0"
echo "  static: no kill by name; every docker call on the pinned socket, every dk run --pull never, every removal rm -fv; ONE Maven build, -pl tiffinbox-web -am; no Thread.sleep in the harness; no line sends the key header or asks U04's routes"
mask() { awk -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(PE, "…"); gsub(P, "…"); gsub(QE, "…/.."); gsub(Q, "…/.."); gsub(H, "~")
    gsub(/ in [0-9.]+ seconds \(process running for [0-9.]+\)/, " in <t> (process running for <t>)")
    gsub(/[0-9]+ ms/, "<t>")
    gsub(/after [0-9]+ milliseconds/, "after <masked>")
    gsub(/Time elapsed: [0-9.]+ s/, "Time elapsed: <t>")
    gsub(/pid [0-9]+/, "pid <n>")
    gsub(/x{9000}/, "<9000 x>")
    gsub(/[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?( ?[A-Z]{3,4}|Z|[+-][0-9:]+)?/, "<time>")
    gsub(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/, "<uuid>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
LX=$(head -c 9000 /dev/zero | tr '\0' 'x')
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'took 812 ms' '"timestamp":"2026-11-24T07:12:01.123+01:00"' "$U/x $HOME/y" 'curl: (28) Operation timed out after 5004 milliseconds with 0 out of 282 bytes received' "GET /customers/$LX 400" | mask)
[ "$(printf '%s\n' "$MP" | paste -sd'|' -)" = 'Started TiffinBoxServer in <t> (process running for <t>)|took <t>|"timestamp":"<time>"|…/x ~/y|curl: (28) Operation timed out after <masked> with 0 out of 282 bytes received|GET /customers/<9000 x> 400' ] || die "the mask's self-test: $(printf '%s\n' "$MP" | paste -sd'|' -)"
maskh() { tr -d '\r' < "$1" | sed -E 's/^(Date|date): .*/\1: <masked>/; s/(JSESSIONID=)[^;]*/\1<masked>/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/^(Expires): .*/\1: <masked>/'; }
MH=$(printf 'Date: Tue, 24 Nov 2026 08:00:00 GMT\r\nSet-Cookie: JSESSIONID=ABC123; Path=/; HttpOnly\r\nLocation: http://127.0.0.1:20920/dashboard\r\nExpires: Tue, 24 Nov 2027 08:00:00 GMT\r\n' > .r-lock/mh; maskh .r-lock/mh | paste -sd'|' -; rm -f .r-lock/mh)
[ "$MH" = 'Date: <masked>|Set-Cookie: JSESSIONID=<masked>; Path=/; HttpOnly|Location: http://127.0.0.1:<port>/dashboard|Expires: <masked>' ] || die "the header mask's self-test: $MH"
echo "  masks: the log mask's self-test masked a Started line's times, a millisecond count, Boot's /error timestamp, the folders, the home, curl's timed-out elapsed time and the 9,000-character path; the header mask's self-test masked a planted Date, session cookie value, port and Expires"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
$G -qF 'S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)' ../c9-unit04/receipts.sh || die "../c9-unit04/receipts.sh no longer reads the seven's md5 off ../c7-unit31/receipts.sh"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SURFC=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh)
[ ${#U4SURFC} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh's SURF= line"
U4INERT=$(sed -n 's/^inert: seven=\([0-9a-f]*\) surface=\([0-9a-f]*\)$/\1 \2/p' ../c9-unit04/README.md)
[ -n "$U4INERT" ] || die "../c9-unit04/README.md's values block has no inert: line"
case "$S466" in ${U4INERT%% *}*) ;; *) die "the seven ($S466) is not U04's values block's inert: seven=${U4INERT%% *}" ;; esac
case "$U4SURFC" in ${U4INERT##* }*) ;; *) die "the old surface ($U4SURFC) is not U04's values block's inert: surface=${U4INERT##* }" ;; esac
echo "  the seven: $S466 (read off ../c7-unit31/receipts.sh's S466= line as ../c9-unit04/receipts.sh reads it) · the old surface: $U4SURFC (../c9-unit04/receipts.sh's SURF= line) · both = U04's values block's inert: line ($U4INERT)"
U4T=$(sed -n 's/^tests: \(tests_after=[0-9]* tests_k=[0-9]* its=[0-9]*\) .*/\1/p; s/^tests: .*\(tests_after=[0-9]*\) \(tests_k=[0-9]*\) \(its=[0-9]*\) .*/\1 \2 \3/p' ../c9-unit04/README.md | head -1)
[ -n "$U4T" ] || die "../c9-unit04/README.md's values block has no tests: line"
echo "  the anchor's test counts, CITED from ../c9-unit04/README.md's values block (no suite is re-run here, no test copy is built): $U4T"
SRCS=$($G -rn 'setInstance' ../c9-tiffinbox/tiffinbox-web/src/main/java ../c9-tiffinbox/tiffinbox-core/src/main/java 2> /dev/null | wc -l | tr -d ' ')
echo "  instance: setInstance in TiffinBox's main sources (tiffinbox-web, tiffinbox-core): $SRCS lines · ProblemDetail.forStatus… calls: $($G -rn 'ProblemDetail\.forStatus' ../c9-tiffinbox/tiffinbox-web/src/main/java | sed -E 's#^\.\./c9-tiffinbox/tiffinbox-web/src/main/java/com/tiffinbox/web/##; s#^([A-Za-z]+\.java:[0-9]+):.*#\1#' | paste -sd' ' -)"

# ---- docker, ports, the guard: the baselines ----------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that socket? (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
iid() { dk image inspect --format '{{.Id}}' "$1" 2> /dev/null | cut -c8-19; }
[ "$(iid $IMG)" = 77f585114c32 ] || die "the image $IMG is not on this machine - this script never pulls"
[ "$($G -c "^IMG=$IMG\$" ../c9-unit04/receipts.sh)" = 1 ] && [ "$($G -c "^IMG=$IMG\$" ../c9-unit02/receipts.sh)" = 1 ] || die "../c9-unit04/receipts.sh's or ../c9-unit02/receipts.sh's IMG= line is not this digest"
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run"
[ -z "$(dk ps -aq --filter name=^/$CN\$ 2> /dev/null)" ] || die "a container named $CN exists before the run - an interrupted run's? docker -H \"\$DH\" rm -fv $CN"
TC0=1
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
BAND="20920 20921 20922 20923 20924 20925 20926 20927 20928 20929"
PORTS="18881 18882 18883 18884 20578 20615 $BAND 21280 21281 21282 21283 21284 21285 21286 21287 21288 21289"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
for p in $BAND; do [ -z "$(lsof -nP -iUDP:$p 2> /dev/null)" ] || die "UDP $p is bound"; done
[ "$(pgrep -x java | wc -l | tr -d ' ')" = 0 ] || die "a java process is running before this script starts one - not this script's; stop it first"
guard() { local r; r=$(pgrep -fl "^/bin/(ba)?sh (\./|.*/)(receipts|runrec)[.]sh" 2> /dev/null | $G -v "^$$ " || true)
  local l1; l1=$(sysctl -n vm.loadavg | awk '{ print $2 }')
  [ -z "$r" ] || die "S9.17: another receipt runs ($r) before $1 - this run stops; wait for it, never kill it"
  local w=0; while ! awk -v l="$l1" 'BEGIN { exit !(l < 20) }'; do
    [ -n "${GUARD0:-}" ] || die "R.480: load1 $l1 is not below 20 at the launch - a run of record launches only below 20; launch again when it is"
    w=$((w + 1)); [ $w -lt 900 ] || die "R.480: load1 stayed at or above 20 for 900 checks before $1"; sleep 1; l1=$(sysctl -n vm.loadavg | awk '{ print $2 }'); done
  GUARD0=1
  echo "  guard before $1: no other receipt · load1 $l1 (< 20)$( [ $w = 0 ] || echo " after $w checks at or above 20 (waited, never killed)")"; }
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · $IMG present (= ../c9-unit04 and ../c9-unit02's IMG= lines) · nothing pulled, ever · no $CN · ports free: $(echo $PORTS | wc -w | tr -d ' ') (TCP; 20920-20929 UDP too) · no java process · 20926 is never bound"

# ---- the tree, copied and built offline (the ONE build); the harness, compiled ------------------------------------------------------------
M2="$PWD/.m2-demo"
if [ ! -d "$M2" ]; then [ -d "$SEED" ] || die "the seed $SEED is missing (README.md, The repository)"; cp -cR "$SEED" "$M2" 2> /dev/null || cp -R "$SEED" "$M2" || die "the seed could not be copied"; fi
NF0=$(find "$M2" -type f | wc -l | tr -d ' ')
[ -f "$M2/org/springframework/boot/spring-boot-starter-parent/4.1.3/spring-boot-starter-parent-4.1.3.pom" ] && [ -f "$M2/org/apache/tomcat/embed/tomcat-embed-core/11.0.29/tomcat-embed-core-11.0.29.jar" ] || die ".m2-demo holds no 4.1.3 parent or no Tomcat 11.0.29 - it is not the U04 seed"
echo "  .m2-demo (a copy of the seed m2-seed-c9-u04): files $NF0 · the 4.1.3 parent and tomcat-embed-core 11.0.29 present"
rm -rf .harness; mkdir -p .harness/home .harness/run .harness/work
rsync -a --exclude target --exclude secrets --exclude .m2-demo after/ .harness/after/
[ -z "$(diff -rq after/ .harness/after 2>&1)" ] || die ".harness/after is not after/"
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE 'Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" HOME=\"$U/.harness/home\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 900; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
guard "the build of after/"
echo "  the build's cap: alarm 900 (perl, R.247)"
bg "cd .harness/after && $MV -DskipTests clean package -pl tiffinbox-web -am" .harness/build-after.log
[ "$RE" = 0 ] || { tail -30 .harness/build-after.log | mask >&3; die ".harness/after did not build offline (exit $RE)"; }; offl .harness/build-after.log
bg "cd .harness/after && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-after.log
[ "$RE" = 0 ] || die ".harness/after: the jar's extract failed"
echo "  built a copy of after/ offline (mvn -o -DskipTests clean package -pl tiffinbox-web -am, exit 0, Downloading/Downloaded from: 0; no test run) · its jar extracted"
LIBN=$(ls .harness/after/$XD/lib | wc -l | tr -d ' ')
echo "  BOOT-INF/lib: $LIBN jars · $(ls .harness/after/$XD/lib | $G -E '^(spring-boot-[0-9]|spring-core-|spring-webmvc-|tomcat-embed-(core|el|websocket)-|netty-common-|jackson-databind-|hibernate-core-|postgresql-)' | sort | paste -sd' ' -)"
meta() { unzip -p ".harness/after/$XD/lib/$1" META-INF/spring-configuration-metadata.json 2> /dev/null | python3 -I -c 'import json, sys; d = json.load(sys.stdin); print(next((p.get("defaultValue") for p in d.get("properties", []) if p["name"] == sys.argv[1]), "absent"))' "$2"; }
LIMF=$(meta spring-boot-servlet-4.1.3.jar spring.servlet.multipart.max-file-size); LIMH=$(meta spring-boot-web-server-4.1.3.jar server.max-http-request-header-size)
export LIMF LIMH                                      # chk03.py's limits view prints them
echo "  the jars' own metadata (META-INF/spring-configuration-metadata.json): spring.servlet.multipart.max-file-size defaultValue $LIMF (spring-boot-servlet-4.1.3.jar) · server.max-http-request-header-size defaultValue $LIMH (spring-boot-web-server-4.1.3.jar)"
CPA=".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*"
DSP="$M2/net/ttddyy/datasource-proxy/1.11.1/datasource-proxy-1.11.1.jar"
PGJ=$(ls .harness/after/$XD/lib | $G '^postgresql-[0-9.]*\.jar$' || true)
[ -f "$DSP" ] || die "the harness's jar (datasource-proxy 1.11.1) is not in .m2-demo"
[ -n "$PGJ" ] || die "after/'s lib/ holds no PostgreSQL driver - the dev profile's driver ships in the jar since Course 8 (U04 used it)"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \"$CPA:$DSP\" harness/src/probe/*.java harness/src/probe/u03/*.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/'s jar: $(head -5 .harness/javac.log)"
echo "  the harness compiled against after/'s jar ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes, javac 25 -parameters; datasource-proxy 1.11.1 from .m2-demo, on the harness's class path only; the PostgreSQL driver is the jar's own, $PGJ)"

# ---- helpers ---------------------------------------------------------------------------------------------------------------------------
B() { echo "http://127.0.0.1:$1"; }
J=.harness/work
mark() { wc -l < ".harness/run/$1/jvm.log" | tr -d ' '; }
acount() { wc -l < ".harness/run/$1/access/access.log" 2> /dev/null | tr -d ' '; }
# the server's own lines for one request, after a mark: wait (a count condition, bounded) for the access log's line for it - the valve
# writes it after the request's filters and its ERROR dispatch have returned - then print every PROBE-REQ line since the mark, the
# resolver's lines (harness logging: ExceptionHandlerExceptionResolver at DEBUG) and, where SQLP is set, the witness's SQL lines
srv() { local lab=$1 m=$2 a0=$3 i=0
  while [ "$(acount $lab)" -le "$a0" ]; do i=$((i + 1)); [ $i -lt 400 ] || { echo "     access: NO LINE"; break; }; sleep 0.02; done
  [ $i -ge 400 ] || echo "     access: $(sed -n "$(( a0 + 1 ))p" ".harness/run/$lab/access/access.log")"
  sed -n "$(( m + 1 )),\$p" ".harness/run/$lab/jvm.log" | $G -E "^PROBE-REQ [0-9]+ " | sed -E 's/^PROBE-REQ [0-9]+ /     server: /' | cut -c1-260
  sed -n "$(( m + 1 )),\$p" ".harness/run/$lab/jvm.log" | $G -oE 'Using @ExceptionHandler [A-Za-z0-9_.$]+#[A-Za-z0-9_]+\([^)]*\)|Resolved \[[A-Za-z0-9_.$]+' | sed -E 's/^Using @ExceptionHandler ([A-Za-z0-9_.$]+\.)?([A-Za-z0-9_$]+#[A-Za-z0-9_]+)\(.*$/     resolved by: \2/; s/^Resolved \[([A-Za-z0-9_$]+\.)*([A-Za-z0-9_$]+)$/     resolved: \2/'
  [ -z "${SQLP:-}" ] || sed -n "$(( m + 1 )),\$p" ".harness/run/$lab/jvm.log" | $G -E "^PROBE-SQL [0-9]+ " | sed -E 's/^PROBE-SQL [0-9]+ /     sql: /' | cut -c1-260; }
HSEL='^(Location|Allow|Connection|ETag|Last-Modified|Accept|Content-Length|Content-Language|Cache-Control):'
# ask LABEL METHOD PATH [curl args]: one request into its own (reset) header and body files; every status line of the header file (the
# interim 100 too), the headers the matrix reads (Allow as sent and as a set), its server witnesses, its body (masked) - and, where CK is
# set, the customers cache's keys before and after it (read by the harness's route, never through the cache)
ask() { local lab=$1 m=$2 p=$3 o=$J/$DB-$1 w rc mk a0 c0 c1 dp; shift 3
  : > "$o.h"; : > "$o.b"; [ -z "${CK:-}" ] || c0=$(ck); mk=$(mark $L); a0=$(acount $L)
  w=$($CURL --http1.1 -sS -D "$o.h" -o "$o.b" -w '%{http_code} %{content_type} %{size_download}' --max-time 20 -X "$m" "$@" "$(B $P)$p" 2> "$o.err"); rc=$?
  dp=$(printf '%s' "$p" | perl -pe 's#x{9000}#<9000 x>#')
  echo "-- $lab | $m $dp -> $w (curl exit $rc)"
  echo "     status lines: $(tr -d '\r' < "$o.h" | $G -E '^HTTP/' | sed 's/ *$//' | paste -sd'>' - | sed 's/>/ > /g')"
  tr -d '\r' < "$o.h" | $G -iE "$HSEL" | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' | while IFS= read -r h; do case "$h" in [Aa]llow:*) echo "     header: $h · set {$(printf '%s' "${h#*:}" | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)}" ;; *) echo "     header: $h" ;; esac; done
  srv $L $mk $a0
  [ -z "${CK:-}" ] || { c1=$(ck); echo "     cache: before $c0 · after $c1"; }
  local n; n=$(wc -c < "$o.b" | tr -d ' ')
  if [ "$n" -le 330 ] && [ "$n" -gt 0 ]; then echo "     body: $(tr -d '\r' < "$o.b" | tr '\n' '~' | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/"timestamp":"[^"]*"/"timestamp":"<masked>"/')"; else echo "     body: $n B md5 $(md5 -q "$o.b")$( $G -q '<h1>HTTP Status' "$o.b" && echo " · title: $(sed -n 's/.*<title>\([^<]*\)<\/title>.*/\1/p' "$o.b" | head -1)")"; fi; }
probe() { $CURL -s "$(B $P)/probe/u03/$1"; }
ck() { probe cache | python3 -I -c 'import json,sys; print("customers " + json.load(sys.stdin)["customers"])'; }
rows() { if [ "$DB" = pg ]; then echo "$(psqlq "SELECT count(*) FROM customer WHERE name = '$1'") (psql in $CN, the second client)"; else echo "$(probe row/$1 | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])') (the harness's JdbcTemplate route /probe/u03/row/$1, the second client)"; fi; }
keyrows() { if [ "$DB" = pg ]; then echo "$(psqlq "SELECT count(*) FROM idempotency_key") (psql in $CN, the second client)"; else echo "$(probe keys | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])') (the harness's JdbcTemplate route /probe/u03/keys, the second client)"; fi; }
psqlq() { dk exec $CN psql -U tiffinbox -d "${2:-tiffinbox}" -qAt -c "$1" 2>&1 | tr '\n' ' ' | sed 's/ *$//'; }
pgup() { guard "the PostgreSQL container"
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:20921:5432 -e POSTGRES_DB=tiffinbox -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust $IMG" .harness/docker-run-pg.log
  [ "$RE" = 0 ] || die "the PostgreSQL container did not start: $(tail -2 .harness/docker-run-pg.log)"
  local i=0; while ! dk exec $CN pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 240 ] || die "PostgreSQL did not accept connections"; sleep 0.5; done
  [ "$(dk port $CN | paste -sd'|' -)" = '5432/tcp -> 127.0.0.1:20921' ] || die "$CN publishes on another address than 127.0.0.1:20921"
  echo "  $CN: PostgreSQL $(psqlq 'show server_version') by the digest, on 127.0.0.1:20921 alone (docker port), trust on the loopback (U04's form: no password exists to print), a fresh database"; }
# tb LABEL PORT DB HCX [args]: TiffinBox (the extracted jar), from its own run folder with a generated token (a config tree, 0600, never
# printed), Tomcat's access log on (unbuffered, no time field: %m %U%q %s %b, S9.27); waited for by its Started line (never a health poll:
# the cache's cold state stays observable), or by health 200 where HEALTHUP is set (the seven and the surface, as U04's were)
tb() { local label=$1 port=$2 db=$3 hcx=$4 run=.harness/run/$1 jx="" src="" i=0; shift 4
  guard "TiffinBox $label"
  for q in $BAND; do [ "$q" = "$port" ] || [ "$q" = 20921 ] || [ "$(listeners $q)" = 0 ] || die "$q is bound before $label starts"; done
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox" "$run/access"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  local x="$U/.harness/after/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  if [ -n "$hcx" ]; then cp="$cp:$hcx:$DSP"; src="--spring.main.sources=${SRC:-probe.Witness,probe.Http,probe.u03.U03Probe}"; fi
  [ "$db" = pg ] && jx="-Dtiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:20921/tiffinbox?user=tiffinbox"
  (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 ${JX:-} $jx -cp "$cp" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port="$port" $src \
     --server.tomcat.accesslog.enabled=true --server.tomcat.accesslog.directory="$U/$run/access" --server.tomcat.accesslog.prefix=access --server.tomcat.accesslog.suffix=.log \
     --server.tomcat.accesslog.file-date-format= --server.tomcat.accesslog.rotate=false "--server.tomcat.accesslog.pattern=%m %U%q %s %b" --server.tomcat.accesslog.buffered=false "$@" > jvm.log 2>&1) &
  local p=$!; echo $p > "$run/pid"; PIDS="$PIDS $p"
  if [ -n "${HEALTHUP:-}" ]; then
    while [ "$($CURL -s -o /dev/null -w '%{http_code}' --max-time 2 "$(B $port)/actuator/health" 2> /dev/null || true)" != 200 ]; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before health 200"; }; i=$((i + 1)); [ $i -lt 600 ] || die "$label: no health 200"; sleep 0.1; done
  else
    while ! $G -q -E 'Started TiffinBox(App|Server) in' "$run/jvm.log" 2> /dev/null; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before its Started line"; }; i=$((i + 1)); [ $i -lt 900 ] || die "$label: no Started line"; sleep 0.1; done
  fi
  echo "  $label up on $port ($db$( [ -n "$hcx" ] && echo ", the harness joined")) · cap: alarm 900 (perl) · $($G -o -E 'Successfully applied [0-9]+ migrations[^(]*|Schema "[^"]*" is up to date[^.(]*' "$run/jvm.log" | head -1 | sed 's/ *$//')"
  echo "  version lines ($label): $($G -oE 'Starting Servlet engine: \[[^]]*\]|HHH000001: Hibernate ORM core version [0-9A-Za-z.]+' "$run/jvm.log" | paste -sd'|' -) · Boot $(ls .harness/after/$XD/lib | sed -n 's/^spring-boot-\([0-9][0-9.]*\)\.jar$/\1/p') · Framework $(ls .harness/after/$XD/lib | sed -n 's/^spring-core-\([0-9][0-9.]*\)\.jar$/\1/p') · database: $($G -m1 -oE 'Database: [^ ]+ \([^)]*\)' "$run/jvm.log" | sed -E 's/jdbc:[a-z0-9]+:[^ ]*/<url>/')"; }
tbstop() { local label=$1 port=$2 run=.harness/run/$1 p i=0; p=$(cat "$run/pid")
  if kill -0 "$p" 2> /dev/null; then printf 'X-Shutdown-Token: %s\n' "$(head -1 "$run/secrets/tiffinbox/shutdown-token")" | $CURL -s -o /dev/null --max-time 5 -H @- -X POST "$(B $port)/shutdown" || true; fi
  while kill -0 "$p" 2> /dev/null; do i=$((i + 1)); [ $i = 80 ] && kill "$p" 2> /dev/null; [ $i -lt 400 ] || { kill -9 "$p" 2> /dev/null; break; }; sleep 0.05; done
  wait "$p" 2> /dev/null || true; PIDS=$(echo " $PIDS " | sed "s/ $p / /g")
  [ "$(listeners $port)" = 0 ] || die "$label: something still listens on $port"; }
NCAPS=0; unpub=""; VALS=""
cap() { local nm=$1; shift
  "$@" > .harness/cap-$nm.raw 2>&1 || true
  $G -q '^  \*\*\* ' .harness/cap-$nm.raw && { cat .harness/cap-$nm.raw >&3; die "$nm stopped (above)"; }
  mask < .harness/cap-$nm.raw > .r-$nm.new
  sed 's/^/  | /' .r-$nm.new | cut -c1-260
  local o e=0; o=$(python3 -I -B harness/chk03.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk03 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  $G -v '^ok \|^FAIL ' .harness/chk-$nm.out | sed 's/^/  chk03 /' || true
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; die "$nm: its check failed (harness/chk03.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk03.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-11s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-11s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff its block in README.md against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }

# ---- the matrix ------------------------------------------------------------------------------------------------------------------------
JSON='Content-Type: application/json'; FORM='Content-Type: application/x-www-form-urlencoded'
KAVYA='{"name":"Kavya","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEGAN"}'
# one matrix JVM: the cache cold, one health check (warm, counted apart), then every request of the unit in one labelled access-log
# window - the boundary's literals (census.sh :65-100) where the boundary asked the same request, so the sizes compare with its census
c_matrix() { local a0 a1 LM ET DAYB CSS i
  echo "== $DB: TiffinBox after/ + the harness on $P; which database answered (Flyway's line): $($G -m1 -oE 'Database: [^ ]+ \([^)]*\)' .harness/run/$L/jvm.log | sed -E 's/jdbc:[a-z0-9]+:[^ ]*/<url>/')"
  echo "  cache before any request: $(ck) (the harness's /probe/u03/cache, read right after the Started line)"
  CK=1 ask health GET /actuator/health
  a0=$(acount $L)
  echo "  window opens after access-log line $a0"
  echo "== $DB: census · authors - the codes TiffinBox answers, every request with no key header"
  CK=1 ask s200 GET /customers
  CK=1 ask s201 POST /customers -H "$JSON" --data-binary "$KAVYA"
  ask s409 POST /customers -H "$JSON" --data-binary "$KAVYA"
  echo "  the name's rows after the 409: Kavya $(rows Kavya)"
  ask s400a POST /customers -H "$JSON" --data-binary '{"name":"","mealsPerDay":0,"pricePerMeal":0,"mealType":"VEG"}'
  ask s400b POST /customers -H "$JSON" --data-binary '{"name":'
  ask s400c GET '/customers?mealType=FISH'
  ask s403 POST /shutdown
  ask s404a GET /customers/Nobody
  ask s404b GET /nowhere
  ask s405 GET /shutdown
  echo "== $DB: six - a list in CSV, after the read (cold, the control, warm, the baseline); the witness's SQL lines printed"
  SQLP=1 CK=1 ask six-cold GET /customers -H 'Accept: text/csv'
  SQLP=1 CK=1 ask six-control GET /customers -H 'Accept: application/json'
  SQLP=1 CK=1 ask six-warm GET /customers -H 'Accept: text/csv'
  CK=1 ask six-evict POST /customers -H "$JSON" --data-binary '{"name":"Nina","mealsPerDay":1,"pricePerMeal":110,"mealType":"VEG"}'
  SQLP=1 CK=1 ask six-base GET /customers -H 'Accept: application/json'
  echo "== $DB: census · authors (continued)"
  ask s415a POST /customers -H 'Content-Type: text/plain' --data-binary 'Kavya'
  ask s415b POST /customers/import -H 'Content-Type: text/csv' --data-binary 'name'
  ask s302 POST /customers -H "$FORM" --data-binary 'name=Lata&mealsPerDay=1&pricePerMeal=100&mealType=VEG'
  ask s200form POST /customers -H "$FORM" --data-binary 'name=&mealsPerDay=1&pricePerMeal=100&mealType=VEG'
  ask dash GET /dashboard -H 'Accept: text/html'
  CSS=$(sed -n 's/.*<link[^>]*href="\([^"]*\.css\)".*/\1/p' $J/$DB-dash.b | head -1)
  echo "  the stylesheet's path, read off the page's own link: $CSS"
  CK=1 ask s200css GET "$CSS"
  LM=$(tr -d '\r' < $J/$DB-s200css.h | $G -i '^Last-Modified:' | cut -d' ' -f2-); ET=$(tr -d '\r' < $J/$DB-s200css.h | $G -i '^ETag:' | cut -d' ' -f2-)
  DAYB=$(python3 -I -c "import email.utils,sys,datetime; d=email.utils.parsedate_to_datetime(sys.argv[1]); print(email.utils.format_datetime(d-datetime.timedelta(days=1), usegmt=True))" "$LM")
  echo "  its validators, read off its own 200: Last-Modified $LM · ETag $ET · a day before (computed as census.sh :91 does): $DAYB"
  CK=1 ask s304 GET "$CSS" -H "If-Modified-Since: $LM"
  echo "== $DB: conditional - the static handler's preconditions on the same file"
  ask c-inm GET "$CSS" -H "If-None-Match: $ET"
  ask c-inmdate GET "$CSS" -H "If-None-Match: $ET" -H "If-Modified-Since: $LM"
  ask c-star GET "$CSS" -H 'If-None-Match: *'
  ask c-ifmatch GET "$CSS" -H 'If-Match: "x"'
  ask c-iusbefore GET "$CSS" -H "If-Unmodified-Since: $DAYB"
  ask c-iuseq GET "$CSS" -H "If-Unmodified-Since: $LM"
  echo "== $DB: limits - the two answers that come before any route"
  head -c 1500000 /dev/zero | tr '\0' 'a' > $J/big.csv
  printf 'name,mealsPerDay,pricePerMeal,mealType\nUma,1,120,VEG\n' > $J/small.csv
  echo "  the big file: $(wc -c < $J/big.csv | tr -d ' ') bytes (head -c of /dev/zero, as census.sh :93) · the small file: $(wc -c < $J/small.csv | tr -d ' ') bytes, one customer"
  ask l413 POST /customers/import -F "file=@$J/big.csv;type=text/csv;filename=big.csv"
  ask l413noexpect POST /customers/import -H 'Expect:' -F "file=@$J/big.csv;type=text/csv;filename=big.csv"
  ask lsmall POST /customers/import -F "file=@$J/small.csv;type=text/csv;filename=small.csv"
  echo "  the long request line: a path of $(printf '%s' "$LX" | wc -c | tr -d ' ') x's (head -c of /dev/zero, as census.sh :98)"
  ask long GET "/customers/$LX"
  ask ravi GET /customers/Ravi
  echo "== $DB: TRACE and CONNECT - also in U02's method table; re-sent here because S9.3 says a code is said beside the request that produced it in THIS run"
  ask trace TRACE /customers
  ask connect CONNECT /customers
  echo "== $DB: cannot - the ordinary requests that would reach 202, 204, 401, 410, 422, 429 (no key, nothing of U04's)"
  printf 'name,mealsPerDay,pricePerMeal,mealType\nVani,1,120,VEG\n' > $J/vani.csv
  ask k202 POST /customers/import -F "file=@$J/vani.csv;type=text/csv;filename=vani.csv"
  ask k204del DELETE /customers/Ravi
  ask k204opt OPTIONS /customers
  ask k401bearer GET /customers -H 'Authorization: Bearer x'
  ask k401token POST /shutdown -H 'X-Shutdown-Token: x'
  ask k410get GET /customers/Ravi
  echo "  422: the matrix's s400a is the request that would reach it (a body that parses and breaks a rule)"
  i=0; while [ $i -lt 5 ]; do i=$((i + 1)); ask k429-$i GET /customers; done
  echo "  429: the burst sent $i GET /customers, one call each (the loop's counter)"
  echo "== $DB: five - the harness's 500 (a harness route, never TiffinBox's)"
  ask boom GET /probe/u03/boom
  a1=$(acount $L)
  echo "  window closes at access-log line $a1: $((a1 - a0)) lines"
  sed -n "$((a0 + 1)),${a1}p" .harness/run/$L/access/access.log | perl -pe 's#x{9000}#<9000 x>#; s/^/  acc: /'
  echo "  key table rows after the matrix: $(keyrows)"
  echo "  access log in all: $(acount $L) lines · status 500: $(awk '$3 == 500' .harness/run/$L/access/access.log | wc -l | tr -d ' ')$(awk '$3 == 500 { printf " (%s %s)", $1, $2 }' .harness/run/$L/access/access.log)"; }

c_view() { python3 -I -B harness/chk03.py view "$1" .r-matrixpg.new .r-matrix.new; }

# the seven and the old surface (no key header), each in its own JVM, H2, health-polled as U04's were; then the S9.14 plant on 20923
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
c_seven() {
  echo "== the seven (c5-unit11/curlset.sh, md5 bfa34552cb762f099b6a389386324468) on after/, H2, its own JVM, no key header: expected $S466 (../c7-unit31/receipts.sh; = U04's inert: seven=)"
  HEALTHUP=1 tb seven 20920 h2 ""
  sh $CURLSET 20920 .harness/run/seven/secrets/tiffinbox/shutdown-token > $J/seven.txt 2>&1
  local i=0; while kill -0 "$(cat .harness/run/seven/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 400 ] || die "the seven's POST /shutdown did not stop it"; sleep 0.05; done
  tbstop seven 20920
  sed 's/^/  /' $J/seven.txt
  echo "  the seven: $(md5 -q $J/seven.txt) ($(wc -l < $J/seven.txt | tr -d ' ') lines) · expected $S466"; }
c_surface() {
  echo "== the old surface on after/, H2, its own JVM, no key header, the feed read by a count condition: expected $U4SURFC (../c9-unit04/receipts.sh's SURF=, = U04's inert: surface=)"
  HEALTHUP=1 tb surface 20920 h2 ""
  oldsurface2 20920 $J/surface.txt
  tbstop surface 20920
  sed 's/^/  /' $J/surface.txt
  echo "  the old surface: $(md5 -q $J/surface.txt) ($($G -c '^== ' $J/surface.txt) requests, $(wc -l < $J/surface.txt | tr -d ' ') lines) · expected $U4SURFC"
  echo "== the self-test (S9.14, the harness's plant - LABELLED, not a finding about TiffinBox): a ShallowEtagHeaderFilter on /* (probe.Etag, U04's), on 20923"
  SRC=probe.Etag HEALTHUP=1 tb seven-etag 20923 h2 "$U/.harness/hc"
  sh $CURLSET 20923 .harness/run/seven-etag/secrets/tiffinbox/shutdown-token > $J/seven-etag.txt 2>&1
  local i=0; while kill -0 "$(cat .harness/run/seven-etag/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 400 ] || die "seven-etag did not stop"; sleep 0.05; done; tbstop seven-etag 20923
  SRC=probe.Etag HEALTHUP=1 tb surface-etag 20923 h2 "$U/.harness/hc"; oldsurface2 20923 $J/surface-etag.txt; tbstop surface-etag 20923
  echo "  planted: the seven $(md5 -q $J/seven-etag.txt) (unchanged: $(cmp -s $J/seven-etag.txt $J/seven.txt && echo yes || echo NO)) · the old surface $(md5 -q $J/surface-etag.txt) (moved: $(cmp -s $J/surface-etag.txt $J/surface.txt && echo NO || echo yes)) · the feed's line: $($G '^== GET /customers/feed' $J/surface-etag.txt | sed -E 's/^== //')"; }

# the exercise: ask.sh as shipped (broken), SOLUTION.md's line in its place (solved), and four refused "solutions" - ask.sh's asking line
# changed - against TiffinBox's jar alone on 20928 (no harness), env -i, from the exercise's folder, under bash then zsh -f
c_exercise() { local v sh d o line LMX DAYX
  for sh in bash zsh; do
    tb ex-$sh 20928 h2 ""
    LMX=$($CURL -sS -D - -o /dev/null "$(B 20928)$($CURL -sS -H 'Accept: text/html' "$(B 20928)/dashboard" | sed -n 's/.*<link[^>]*href="\([^"]*\.css\)".*/\1/p' | head -1)" | tr -d '\r' | sed -n 's/^Last-Modified: //p')
    DAYX=$(python3 -I -c "import email.utils,sys,datetime; d=email.utils.parsedate_to_datetime(sys.argv[1]); print(email.utils.format_datetime(d-datetime.timedelta(days=1), usegmt=True))" "$LMX")
    for v in broken solved ifmatch both daybefore star; do
      d=$J/ex-$v-$sh; rm -rf $d; mkdir -p $d/exercise; cp exercise/ask.sh exercise/check.sh $d/exercise/
      case $v in broken) line="" ;;
                 solved) line=$(block exercise/SOLUTION.md) ;;
                 ifmatch) line=$(block exercise/SOLUTION.md | sed 's/If-Modified-Since: \$LM/If-Match: $ETAG/') ;;
                 both) line=$(block exercise/SOLUTION.md | sed 's/-H "If-Modified-Since: \$LM"/-H "If-None-Match: $ETAG" -H "If-Modified-Since: $LM"/') ;;
                 daybefore) line=$(block exercise/SOLUTION.md | sed "s/If-Modified-Since: \\\$LM/If-Modified-Since: $DAYX/") ;;
                 star) line=$(block exercise/SOLUTION.md | sed 's/If-Modified-Since: \$LM/If-None-Match: */') ;; esac
      if [ -n "$line" ]; then XN="$line" python3 -I -c 'import os, re, sys; f = open(sys.argv[1]).read().split("\n"); i = [k for k, l in enumerate(f) if re.match(r"^curl .*-o ask\.body", l)]; assert len(i) == 1; f[i[0]] = os.environ["XN"]; open(sys.argv[1], "w").write("\n".join(f))' $d/exercise/ask.sh
        [ "$(diff exercise/ask.sh $d/exercise/ask.sh | $G -c '^[<>]')" = 2 ] || die "the try $v must be ask.sh with its asking line changed"; fi
      : > $d/exercise/ask.status; echo stale > $d/exercise/ask.bytes
      if [ $sh = bash ]; then o=$(cd $d/exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=20928 bash -c 'sh check.sh; echo "check exit $?"' 2>&1); else o=$(cd $d/exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=20928 /bin/zsh -f -c 'sh check.sh; echo "check exit $?"' 2>&1); fi
      echo "== the exercise, $v, $sh (env -i, from the exercise's folder, TiffinBox's jar alone on 20928, H2; a stale ask.bytes planted first):"; printf '%s\n' "$o" | sed "s#$DAYX#<a day before Last-Modified>#" | sed 's/^/  /'
    done
    tbstop ex-$sh 20928
  done
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures"
MX="--logging.level.org.springframework.web.servlet.mvc.method.annotation.ExceptionHandlerExceptionResolver=DEBUG"   # harness logging, never shipped
pgup
DB=pg; P=20922; L=MP
JX=-Dprobe.sql=true tb MP 20922 pg "$U/.harness/hc" "$MX"
cap matrixpg c_matrix
tbstop MP 20922
dk rm -fv $CN > /dev/null 2>&1 || die "$CN could not be removed"
DB=h2; P=20920; L=MH
JX=-Dprobe.sql=true tb MH 20920 h2 "$U/.harness/hc" "$MX"
cap matrix c_matrix
tbstop MH 20920
for v in census authors six conditional limits cannot five inert instance cross; do cap $v c_view $v; done
cap seven c_seven
cap surface c_surface
cap exercise c_exercise

# ---- the end: the sweep, the values, the published hashes -------------------------------------------------------------------------------
[ -z "$(echo $PIDS)" ] || die "a JVM of this run is still running: $PIDS"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
[ -z "$(dk ps -aq --filter label=org.testcontainers=true)" ] && [ -z "$(dk ps -aq --filter name=^/$CN\$)" ] || die "a container of this run is left"
NI1=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI1" = "$NI0" ] && [ "$VOL1" = "$VOL0" ] || die "R.322: images $NI0 -> $NI1, volumes $VOL0 -> $VOL1"
anchortree
MDB=$(find . ../c9-tiffinbox ../c9-unit04 -name '*.mv.db' -not -path './.harness/*' 2> /dev/null | wc -l | tr -d ' ')
[ "$MDB" = 0 ] || die "an H2 file outside .harness/"
VALS="$VALS
build: libs=$LIBN seed_files=$NF0 limit_file=$LIMF limit_header=$LIMH"
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
VO=$(python3 -I -B harness/chk03.py values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; die "README.md's values block is not this run's (harness/chk03.py values)"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM of this run, ports free, no container left, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1 · the tree pins = ../c9-unit04/after's after-tree · *.mv.db outside .harness 0 · the values block = this run's"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit03: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit03: every capture = published ($NCAPS) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"
