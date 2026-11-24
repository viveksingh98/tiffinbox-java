#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 02 "Resources, URIs and the Method Table" - this unit's receipts. NO anchor change: before/ and after/ are both links
# to ../c9-unit04/after (U04's frozen anchor - Spring Boot 4.1.3, Framework 7.0.11, Tomcat 11.0.29, the key filter present and inert
# without its header), pinned by harness/tree02.py against ../c9-unit04/receipts.md5's after-tree line (Course 8 U23's two-link form,
# as U01 did). The measured tree is a copy of after/ under .harness/, built offline (mvn -o clean package -DskipTests -pl tiffinbox-web
# -am) from a cp -c copy of the seed; nothing is built in place. The ONE other build is the harness's test copy (.harness/mockmvc: a
# second copy of after/ with harness/test/ProbeMethodTableTest.java added - never shipped, never in the anchor), one test class run.
# The harness (harness/src/probe/*, joined by --spring.main.sources, never in the jar): the statement witness (Witness) and the
# request witness (Http, PROBE-REQ lines, ERROR dispatches too) - copied from U04's harness byte for byte, md5-asserted - the
# ShallowEtag plant (Etag, U04's) and U02's three read-only routes (probe.u02.U02Probe: the cache's keys, the key table's rows, the
# feed's listener count).
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5):
#   tablepg   the method table (4 addresses x 9 methods, 36 requests) + the safe GETs (each twice) + the feed's listeners, PostgreSQL
#   table     the same on H2 (the default run) · xhead  curl -X HEAD beside curl -I, H2's JVM, once
#   head who trace safe   read off both table captures (PostgreSQL first) · cross  every HTTP column of the two JVMs, equal
#   mockmvc   the same 36 requests through MockMvc (the harness's test copy, no socket), compared with the socket's table
#   seven     c5-unit11's comparison set on after/ · surface  the old surface, its feed read by a count condition (+ the S9.14 plant)
#   exercise  exercise/README.md's block, SOLUTION.md's, and three refused "solutions", under bash and zsh -f
# Ports (Course 9's U02 band, 20910-20919): 20910 TiffinBox after/ on H2 (table, xhead; seven, surface each in its own JVM) · 20911
# PostgreSQL c9u02-pg · 20912 TiffinBox after/ on PostgreSQL · 20913 the S9.14 plant's JVMs · 20914 asserted free · 20915 never bound
# (no flag run: mappings is U01's) · 20916 never bound (before/ and after/ are one tree: no before/ JVM) · 20917 asserted free (no
# browser) · 20918 the exercise · 20919 never bound. Course 8's 20578 / 20615, U04's 21280-21289 and 18881-18884 are never bound.
# No request of this script carries the key header (S9.21): the key table's rows are read after every table, by a second client.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
C9R=${C9R:-"/Users/$ME/Downloads/Youtube Content/LearnProgrammingWithVivek/rest-apis-done-right"}   # the course's folder (briefs, research)
SEED=${SEED:-"$C9R/_research/m2-seed-c9-u04"}   # the course's seed (B5b)
BR8="$C9R/_research/boundary-2026-11-24/B8/census-mid/census.txt"; BRT="$C9R/_research/boundary-2026-11-24/instruments/test-src/ProbeMethodTableTest.java"
LEDGER="$C9R/_briefs/PROMISE-LEDGER-2026-11-24.md"
export C9R                                            # chk02.py reads the boundary's table under it
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c9u02-pg
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
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "surefire") || index($0, "curlset.sh") || $3 ~ /(^|\/)javac$/) { print $1 }' | paste -sd' ' -) || l=""
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
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git od /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit02 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"

# ---- gates before anything is built: the folder, the links, the pins, the static check, the prose, the exercise ------------------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk02.py dur9.py s902.py src test tree02.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
[ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe/Etag.java probe/Http.java probe/Witness.java probe/u02/U02Probe.java' ] || die "harness/src holds another file, or misses one"
[ "$(ls harness/test | paste -sd' ' -)" = 'ProbeMethodTableTest.java' ] || die "harness/test holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md ask.sh check.sh' ] || die "exercise/ holds another file, or misses one"
for t in before after; do
  [ -L "$t" ] || die "$t is not a link - unit 02 measures ../c9-unit04/after through a link, never a copy"
  [ "$(readlink "$t")" = ../c9-unit04/after ] || die "$t's link text is \"$(readlink "$t")\", not ../c9-unit04/after"
  [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/ - never built in place"; true; done
echo "  before -> $(readlink before) · after -> $(readlink after) (links, the text exact; no secrets/, target/ or .m2-demo/ behind them)"
$G -v '^ *#' harness/src/probe/*.java harness/src/probe/u02/*.java harness/test/*.java | $G -q 'Thread\.sleep' && die "R.412: a Thread.sleep in the harness"
for f in Witness Http Etag; do [ "$(md5 -q harness/src/probe/$f.java)" = "$(md5 -q ../c9-unit04/harness/src/probe/$f.java)" ] || die "harness/src/probe/$f.java is not U04's byte for byte"; done
echo "  harness/src/probe/{Witness,Http,Etag}.java = ../c9-unit04/harness/src/probe's (md5 $(md5 -q harness/src/probe/Witness.java | cut -c1-8) $(md5 -q harness/src/probe/Http.java | cut -c1-8) $(md5 -q harness/src/probe/Etag.java | cut -c1-8)) - copied from U04's harness"
$G -q 'shouldNotFilterErrorDispatch' harness/src/probe/Http.java && $G -qF '" [dispatch " + req.getDispatcherType()' harness/src/probe/Http.java || die "Http.java does not print ERROR dispatches (S9.25 amended)"
TQ=$(diff "$BRT" harness/test/ProbeMethodTableTest.java 2> /dev/null | $G -c '^<' || true)
if [ -f "$BRT" ]; then [ "$(md5 -q "$BRT")" = eb4a78c1fec12932f38f61e4af892164 ] || die "the boundary's durable ProbeMethodTableTest.java is not md5 eb4a78c1… (the ORCHESTRATOR NOTE)"
  [ "$TQ" = 0 ] || die "harness/test/ProbeMethodTableTest.java removes or changes a line of the boundary's copy ($TQ) - it may only add"
  TA=$(diff "$BRT" harness/test/ProbeMethodTableTest.java | $G -c '^>' || true)
  echo "  harness/test/ProbeMethodTableTest.java = the boundary's durable copy (md5 eb4a78c1…, instruments/test-src) + $TA added lines, none removed (the Pauses stand-in; the four kinds asserted; the flip plant's switch) - the harness's test, never shipped"
else echo "  the boundary's durable test copy is not on this machine: harness/test/ProbeMethodTableTest.java's receipts.md5 line is the pin"; fi
[ "$(sed -n '5,$p' harness/tree02.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit04/harness/tree04.py | md5 -q)" ] || die "harness/tree02.py's code is not tree04.py's"
[ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit04/harness/dur9.py)" ] || die "harness/dur9.py is not U04's copy (dur9 as shipped)"
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"; else D9N="(the registry is not on this machine: U04's copy is the pin)"; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit04/harness/dur9.py $D9N · tree02.py's code = tree04.py's"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit04/receipts.md5)
[ -n "$UA" ] || die "../c9-unit04/receipts.md5 has no after-tree line"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree02.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line"
  [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit04/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree02.py $dir/ -> $got = receipts.md5's $nm line = ../c9-unit04/receipts.md5's after-tree line"; }
anchortree() { pin before-tree before; pin after-tree after
  local AD; AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after/ ../c9-tiffinbox 2>&1 || true)
  echo "  after/ (= ../c9-unit04/after) against ../c9-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures ../c9-unit04/after' )"; }
anchortree
HF="harness/chk02.py harness/s902.py harness/tree02.py harness/dur9.py harness/src/probe/Witness.java harness/src/probe/Http.java harness/src/probe/Etag.java harness/src/probe/u02/U02Probe.java harness/test/ProbeMethodTableTest.java exercise/ask.sh exercise/check.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's scripts: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
ST=$(python3 -I -B harness/chk02.py static "$LEDGER") || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s902.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U02 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s902, per sentence): /'
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md exercise harness/src harness/test 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
G1="A resource: anything with an address a client can ask for."
[ "$($G -cxF -- "$G1" README.md)" = 1 ] || die "the gloss (SECTION SHAPE 02) must stand in README.md once, as a line of its own, byte for byte: $G1"
for g in '`Safe`, as this unit measures it: ' 'Idempotent, as this unit measures it: '; do [ "$($G -cF -- "$g" README.md)" = 1 ] && [ "$($G -c -- "^$g" README.md)" = 1 ] || die "README.md: the proposed gloss line \"$g…\" once, at the start of its line"; done
HOOK="Send TRACE to TiffinBox and no TiffinBox route runs: Tomcat refuses it four oh five, and Spring Boot's error page writes the answer. Send it through MockMvc, and it comes back two hundred."
PINS=$(head -1 ../c8-unit28/pinned.txt)
EXQ="Your turn: curl -X HEAD waits on the customer list. Ask it so curl stops after the headers, and print the methods shutdown allows."
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (RED-C9-S1 #4), byte for byte"
[ "$($G -cxF -- "$PINS" README.md)" = 1 ] || die "README.md: the pinned sentence (C9-10a), once, as a line of its own, byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SP=$(python3 -I -B harness/chk02.py spoken "$HOOK" "$PINS" "$EXQ" "$LEDGER") || die "the spoken lines: $(printf '%s\n' "$SP" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$SP" | $G -v '^VALUES ' | sed 's/^/  /'
printf '%s\n\n%s\n\n%s\n' "$HOOK" "$PINS" "$EXQ" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s902.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
printf '%s\n' "$SW" | tail -1 | $G -qE ' refused: 0$' || die "a refused reading in a spoken line: $(printf '%s\n' "$SW" | $G ' line ' | head -3 | paste -sd';' -)"
echo "  the three spoken lines through s902.py (every family, dur9 inside it): refused 0"; rm -f .r-lock/spoken.md
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
SETX=$(block exercise/README.md); SOLX=$(block exercise/SOLUTION.md)
[ -n "$SETX" ] && [ -n "$SOLX" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
[ "$(diff <(printf '%s\n' "$SETX") <(printf '%s\n' "$SOLX") | $G -c '^[<>]')" = 2 ] || die "R.196: SOLUTION.md's block must be the README's with one line changed"
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
[ "$($G -c -- '-X HEAD --max-time' exercise/ask.sh)" = 1 ] || die "exercise/ask.sh: the broken form - one curl -X HEAD with its harness-free cap (#37)"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket"
DK=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -vF 'echo "' | $G -nE '(^|[ ;(])docker (run|exec|rm|ps|port|info|images|volume|image|pull|logs|inspect)\b' | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.344: receipts.sh calls docker without the pinned socket: $DK"
RMF=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) rm( +-[a-z]+)*' | sort -u | paste -sd'|' -)
[ "$RMF" = 'dk rm -fv' ] || die "R.387: receipts.sh removes a container without its volumes (found: ${RMF:-none})"
[ "$($G -v '^ *#' receipts.sh | $G -oE '(dk|docker) run -[^"]*' | $G -vcF -- '--pull never' || true)" = 0 ] || die "R.344: a dk run without --pull never"
MVA=$($G -v '^ *#' receipts.sh | $G -F '$MV ' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am"
KW='idempotency''-key'; KH=$($G -v '^ *#' receipts.sh exercise/ask.sh exercise/check.sh | $G -ciF "$KW" || true)
[ "$KH" = 0 ] || die "S9.21: a line of receipts.sh or the exercise names the key header ($KH) - unit 02 sends no key on any request"
echo "  the exercise: SOLUTION.md's block = the README's with one line changed; ask.sh broken as shipped (curl -X HEAD); the two What-it-prints blocks differ · the gloss, the hook and the pinned sentence byte for byte · placeholders 0"
echo "  static: no kill by name; every docker call on the pinned socket, every dk run --pull never, every removal rm -fv; every Maven build -pl tiffinbox-web -am; no Thread.sleep in the harness; no line sends the key header"
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
    gsub(/[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?( ?[A-Z]{3,4}|Z|[+-][0-9:]+)?/, "<time>")
    gsub(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/, "<uuid>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'took 812 ms' '"timestamp":"2026-11-24T07:12:01.123+01:00"' "$U/x $HOME/y" 'curl: (28) Operation timed out after 5004 milliseconds with 0 out of 282 bytes received' | mask)
[ "$(printf '%s\n' "$MP" | paste -sd'|' -)" = 'Started TiffinBoxServer in <t> (process running for <t>)|took <t>|"timestamp":"<time>"|…/x ~/y|curl: (28) Operation timed out after <masked> with 0 out of 282 bytes received' ] || die "the mask's self-test: $(printf '%s\n' "$MP" | paste -sd'|' -)"
maskh() { tr -d '\r' < "$1" | sed -E 's/^(Date|date): .*/\1: <masked>/; s/(JSESSIONID=)[^;]*/\1<masked>/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/^(Expires): .*/\1: <masked>/'; }
MH=$(printf 'Date: Tue, 24 Nov 2026 08:00:00 GMT\r\nSet-Cookie: JSESSIONID=ABC123; Path=/; HttpOnly\r\nLocation: http://127.0.0.1:20910/dashboard\r\nExpires: Tue, 24 Nov 2027 08:00:00 GMT\r\n' > .r-lock/mh; maskh .r-lock/mh | paste -sd'|' -; rm -f .r-lock/mh)
[ "$MH" = 'Date: <masked>|Set-Cookie: JSESSIONID=<masked>; Path=/; HttpOnly|Location: http://127.0.0.1:<port>/dashboard|Expires: <masked>' ] || die "the header mask's self-test: $MH"
echo "  masks: the log mask's self-test masked a Started line's times, a millisecond count, Boot's /error timestamp, the folders, the home and curl's timed-out elapsed time; the header mask's self-test masked a planted Date, session cookie value, port and Expires"
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
echo "  the anchor's test counts, CITED from ../c9-unit04/README.md's values block (no suite is re-run here): $U4T"

# ---- docker, ports, the guard: the baselines ----------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that socket? (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
iid() { dk image inspect --format '{{.Id}}' "$1" 2> /dev/null | cut -c8-19; }
[ "$(iid $IMG)" = 77f585114c32 ] || die "the image $IMG is not on this machine - this script never pulls"
[ "$($G -c "^IMG=$IMG\$" ../c9-unit04/receipts.sh)" = 1 ] || die "../c9-unit04/receipts.sh's IMG= line is not this digest"
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run"
[ -z "$(dk ps -aq --filter name=^/$CN\$ 2> /dev/null)" ] || die "a container named $CN exists before the run - an interrupted run's? docker -H \"\$DH\" rm -fv $CN"
TC0=1
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
BAND="20910 20911 20912 20913 20914 20915 20916 20917 20918 20919"
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
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · $IMG present (= ../c9-unit04/receipts.sh's IMG= line) · nothing pulled, ever · no $CN · ports free: $(echo $PORTS | wc -w | tr -d ' ') (TCP; 20910-20919 UDP too) · no java process"

# ---- the tree, copied and built offline; the harness, compiled ------------------------------------------------------------------------
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
CPA=".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*"
DSP="$M2/net/ttddyy/datasource-proxy/1.11.1/datasource-proxy-1.11.1.jar"
PGJ=$(ls .harness/after/$XD/lib | $G '^postgresql-[0-9.]*\.jar$' || true)
[ -f "$DSP" ] || die "the harness's jar (datasource-proxy 1.11.1) is not in .m2-demo"
[ -n "$PGJ" ] || die "after/'s lib/ holds no PostgreSQL driver - the dev profile's driver ships in the jar since Course 8 (U04 used it)"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \"$CPA:$DSP\" harness/src/probe/*.java harness/src/probe/u02/*.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/'s jar: $(head -5 .harness/javac.log)"
echo "  the harness compiled against after/'s jar ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes, javac 25 -parameters; datasource-proxy 1.11.1 from .m2-demo, on the harness's class path only; the PostgreSQL driver is the jar's own, $PGJ)"

# ---- helpers ---------------------------------------------------------------------------------------------------------------------------
B() { echo "http://127.0.0.1:$1"; }
J=.harness/work
mark() { wc -l < ".harness/run/$1/jvm.log" | tr -d ' '; }
acount() { wc -l < ".harness/run/$1/access/access.log" 2> /dev/null | tr -d ' '; }
# the server's own lines for one request, after a mark: wait (a count condition, bounded) for the access log's line for it - the valve
# writes it after the request's filters and its ERROR dispatch have returned - then print every PROBE-REQ line since the mark
srv() { local lab=$1 m=$2 a0=$3 i=0
  while [ "$(acount $lab)" -le "$a0" ]; do i=$((i + 1)); [ $i -lt 400 ] || { echo "     access: NO LINE"; break; }; sleep 0.02; done
  [ $i -ge 400 ] || echo "     access: $(sed -n "$(( a0 + 1 ))p" ".harness/run/$lab/access/access.log")"
  sed -n "$(( m + 1 )),\$p" ".harness/run/$lab/jvm.log" | $G -E "^PROBE-REQ [0-9]+ " | sed -E 's/^PROBE-REQ [0-9]+ /     server: /' | cut -c1-260; }
HDRS='^(HTTP|Content-Type|Content-Length|Allow|Cache-Control|ETag|Location|Transfer-Encoding)'
# row METHOD PATH: one request of the method table, in the boundary's two curl forms (HEAD by -I; the other eight by -X), no body,
# no Content-Type, no key header, no token; curl's -w triple (status, content type, size_download), its exit, Allow as sent and as a set
row() { local m=$1 p=$2 o=$J/$DB-t$(printf '%s' "$2" | tr '/' '_')-$1 w rc mk a0 al; shift 2
  : > "$o.h"; : > "$o.b"; mk=$(mark $L); a0=$(acount $L)
  if [ $m = HEAD ]; then w=$($CURL --http1.1 -sS -I -D "$o.h" -o "$o.b" -w '%{http_code} %{content_type} %{size_download}' --max-time 5 "$@" "$(B $P)$p" 2> "$o.err"); rc=$?
  else w=$($CURL --http1.1 -sS -D "$o.h" -o "$o.b" -w '%{http_code} %{content_type} %{size_download}' --max-time 5 -X $m "$@" "$(B $P)$p" 2> "$o.err"); rc=$?; fi
  echo "-- $m $p -> $w (curl exit $rc)"
  al=$(tr -d '\r' < "$o.h" | $G -i '^Allow:' | head -1 | cut -d' ' -f2-)
  echo "     allow: ${al:--} · set {$(printf '%s' "$al" | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)}"
  echo "     content-length: $(tr -d '\r' < "$o.h" | $G -i '^Content-Length:' | head -1 | cut -d' ' -f2)"
  srv $L $mk $a0
  local n; n=$(wc -c < "$o.b" | tr -d ' ')
  if [ $m = HEAD ]; then echo "     body file: the -I output (headers), $n B - not a body; size_download is the body"
  elif [ "$n" -le 360 ]; then echo "     body: $(tr -d '\r' < "$o.b" | tr '\n' '~' | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g')"
  else echo "     body: $n B md5 $(md5 -q "$o.b")"; fi; }
# ask LABEL METHOD PATH [curl args]: one request outside the table into its own header and body files, its two witnesses
ask() { local lab=$1 m=$2 p=$3 o=$J/$DB-$1 w rc mk a0; shift 3
  : > "$o.h"; : > "$o.b"; mk=$(mark $L); a0=$(acount $L)
  w=$($CURL --http1.1 -sS -D "$o.h" -o "$o.b" -w '%{http_code} %{content_type} %{size_download}' --max-time 20 -X "$m" "$@" "$(B $P)$p" 2> "$o.err"); rc=$?
  echo "-- $lab | $m $p -> $w (curl exit $rc)"
  srv $L $mk $a0
  local n; n=$(wc -c < "$o.b" | tr -d ' ')
  if [ "$n" -le 200 ] && [ "$n" -gt 0 ]; then echo "     body: $(tr -d '\r' < "$o.b" | tr '\n' '~' | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g')"; else echo "     body: $n B md5 $(md5 -q "$o.b")"; fi; }
probe() { $CURL -s "$(B $P)/probe/u02/$1"; }
ck() { probe cache | python3 -I -c 'import json,sys; print("customers " + json.load(sys.stdin)["customers"])'; }
lis() { probe feed | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["listeners"])'; }
keyrows() { if [ "$DB" = pg ]; then echo "$(psqlq "SELECT count(*) FROM idempotency_key") (psql in $CN, the second client)"; else echo "$(probe keys | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])') (the harness's JdbcTemplate route /probe/u02/keys, the second client)"; fi; }
psqlq() { dk exec $CN psql -U tiffinbox -d "${2:-tiffinbox}" -qAt -c "$1" 2>&1 | tr '\n' ' ' | sed 's/ *$//'; }
pgup() { guard "the PostgreSQL container"
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:20911:5432 -e POSTGRES_DB=tiffinbox -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust $IMG" .harness/docker-run-pg.log
  [ "$RE" = 0 ] || die "the PostgreSQL container did not start: $(tail -2 .harness/docker-run-pg.log)"
  local i=0; while ! dk exec $CN pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 240 ] || die "PostgreSQL did not accept connections"; sleep 0.5; done
  [ "$(dk port $CN | paste -sd'|' -)" = '5432/tcp -> 127.0.0.1:20911' ] || die "$CN publishes on another address than 127.0.0.1:20911"
  echo "  $CN: PostgreSQL $(psqlq 'show server_version') by the digest, on 127.0.0.1:20911 alone (docker port), trust on the loopback (U04's form: no password exists to print), a fresh database"; }
# tb LABEL PORT DB HCX [args]: TiffinBox (the extracted jar), from its own run folder with a generated token (a config tree, 0600, never
# printed), Tomcat's access log on (unbuffered, no time field: %m %U%q %s %b, S9.27); waited for by its Started line (never a health poll:
# the cache's cold state stays observable), or by health 200 where HEALTHUP is set (the seven and the surface, as U04's were)
tb() { local label=$1 port=$2 db=$3 hcx=$4 run=.harness/run/$1 jx="" src="" i=0; shift 4
  guard "TiffinBox $label"
  for q in $BAND; do [ "$q" = "$port" ] || [ "$q" = 20911 ] || [ "$(listeners $q)" = 0 ] || die "$q is bound before $label starts"; done
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox" "$run/access"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  local x="$U/.harness/after/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  if [ -n "$hcx" ]; then cp="$cp:$hcx:$DSP"; src="--spring.main.sources=${SRC:-probe.Witness,probe.Http,probe.u02.U02Probe}"; fi
  [ "$db" = pg ] && jx="-Dtiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:20911/tiffinbox?user=tiffinbox"
  (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 $jx -cp "$cp" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port="$port" $src \
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
# the feed read by a count condition: headers, then lines to the first event's blank line, under a 10 s alarm; the reader closes it
feed() { local o=$1 BB=$2 frc; : > "$o.h"; : > "$o.b"
  perl -e '$SIG{ALRM}=sub{kill "TERM",$pid; exit 3}; alarm 10; $pid=open(my $c,"-|",@ARGV) or die; $s=0; while(defined($l=<$c>)){print $l; if($l=~/^\r?\n$/){last if $s} else {$s=1}} kill "TERM",$pid; exit 0' \
     curl --noproxy '*' --http1.1 -sS -N -D "$o.h" -H 'Accept: text/event-stream' "$BB/customers/feed" > "$o.b" 2> "$o.e"; frc=$?
  FEEDRC=$frc; }
NCAPS=0; unpub=""; VALS=""
cap() { local nm=$1; shift
  "$@" > .harness/cap-$nm.raw 2>&1 || true
  $G -q '^  \*\*\* ' .harness/cap-$nm.raw && { cat .harness/cap-$nm.raw >&3; die "$nm stopped (above)"; }
  mask < .harness/cap-$nm.raw > .r-$nm.new
  sed 's/^/  | /' .r-$nm.new | cut -c1-260
  local o e=0; o=$(python3 -I -B harness/chk02.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk02 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  $G -v '^ok \|^FAIL ' .harness/chk-$nm.out | sed 's/^/  chk02 /' || true
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; die "$nm: its check failed (harness/chk02.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk02.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-9s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-9s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff its block in README.md against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }

# ---- the captures --------------------------------------------------------------------------------------------------------------------
ADDRS="/customers /customers/Ravi /revenue /shutdown"; METHODS="GET HEAD POST PUT DELETE CONNECT OPTIONS TRACE PATCH"
# one table JVM: the cache cold, one health check (warm), the 36 requests in a labelled access-log window, the key table's rows; then
# the safe GETs, each twice; the feed's listeners around one feed read; the key table's rows again; the access log's 500s
c_table() { local a0 a1 p m
  echo "== $DB: TiffinBox after/ + the harness on $P; which database answered (Flyway's line): $($G -m1 -oE 'Database: [^ ]+ \([^)]*\)' .harness/run/$L/jvm.log | sed -E 's/jdbc:[a-z0-9]+:[^ ]*/<url>/')"
  echo "  cache before any request: $(ck) (the harness's /probe/u02/cache, read right after the Started line)"
  ask health0 GET /actuator/health
  echo "  cache after one health check: $(ck)"
  a0=$(acount $L)
  echo "== $DB: the method table - 4 addresses x 9 methods (RFC 9110's eight and RFC 5789's PATCH); HEAD by curl -I, the other eight by -X; no body, no Content-Type, no key header, no token"
  echo "  window opens after access-log line $a0"
  for p in $ADDRS; do for m in $METHODS; do row $m $p; done; done
  a1=$(acount $L)
  echo "  window closes at access-log line $a1: $((a1 - a0)) lines"
  echo "  key table rows after the table: $(keyrows)"
  echo "== $DB: safe, as measured - each GET twice, the second answer compared with the first (cmp, bodies)"
  for s in "customers GET /customers" "ravi GET /customers/Ravi" "revenue GET /revenue" "veg GET /customers?mealType=VEG" "dashjson GET /dashboard -H Accept:application/json" "dashhtml GET /dashboard -H Accept:text/html" "form GET /customers/new -H Accept:text/html" "kitchen GET /kitchen"; do
    set -- $s; local lab=$1; shift
    ask $lab-1 "$@"; ask $lab-2 "$@"
    echo "  twice $lab: $(cmp -s $J/$DB-$lab-1.b $J/$DB-$lab-2.b && echo byte-identical || echo DIFFERENT)"; done
  echo "== $DB: the feed - CustomerFeed's listeners (the harness's /probe/u02/feed, by reflection) around one feed read"
  echo "  listeners before: $(lis)"
  local mk; mk=$(mark $L); a0=$(acount $L); feed $J/$DB-feed "$(B $P)"
  echo "-- feed | GET /customers/feed -> $(tr -d '\r' < $J/$DB-feed.h | head -1 | cut -d' ' -f2) $(tr -d '\r' < $J/$DB-feed.h | $G -i '^Content-Type:' | cut -d' ' -f2) $(wc -c < $J/$DB-feed.b | tr -d ' ') bytes (read by count: headers + the first event to its blank line, alarm 10 s; reader exit $FEEDRC; closed by the reader)"
  echo "     body: $(tr -d '\r' < $J/$DB-feed.b | tr '\n' '~')"
  echo "  listeners after the client left: $(lis)"
  echo "  listeners again: $(lis)"
  echo "  key table rows at the end: $(keyrows)"
  echo "  access log in all: $(acount $L) lines · status 500: $(awk '$3 == 500' .harness/run/$L/access/access.log | wc -l | tr -d ' ')$(awk '$3 == 500 { printf " (%s %s)", $1, $2 }' .harness/run/$L/access/access.log)"
  echo "  cache at the end: $(ck)"; }

# the failure receipt (S9.26, H1.2): the GET for the length, the control curl -I, then curl -X HEAD once under its cap - never repeated
c_xhead() { local o=$J/xhead w rc
  echo "== h2: curl -X HEAD beside curl -I, /customers, H2's JVM (20910), once each"
  w=$($CURL --http1.1 -sS -o $o.g -w '%{http_code} %{size_download}' --max-time 5 "$(B $P)/customers" 2> $o.ge); echo "  GET /customers -> $w (curl exit $?)"
  w=$($CURL --http1.1 -sS -I -o $o.i -w '%{http_code} %{size_download}' --max-time 5 "$(B $P)/customers" 2> $o.ie); rc=$?
  echo "  curl -I /customers -> $w (curl exit $rc) · Content-Length: $(tr -d '\r' < $o.i | $G -i '^Content-Length:' | cut -d' ' -f2)"
  echo "  the cap on the next request: --max-time 5, the harness's alarm - never a result"
  w=$($CURL --http1.1 -sS -D $o.xh -o $o.x -w '%{http_code} %{size_download}' -X HEAD --max-time 5 "$(B $P)/customers" 2> $o.xe); rc=$?
  echo "  curl -X HEAD /customers -> $w (curl exit $rc) · headers received: $(tr -d '\r' < $o.xh | head -1) · Content-Length: $(tr -d '\r' < $o.xh | $G -i '^Content-Length:' | cut -d' ' -f2)"
  echo "  curl said: $(head -1 $o.xe)"; }

c_view() { python3 -I -B harness/chk02.py view "$1" .r-tablepg.new .r-table.new; }

# the MockMvc table: the harness's test copy (after/ + harness/test's one class), one test class run, no socket (S9.19, C9-9's share)
c_mockmvc() { local q mx=0 n
  echo "== the harness's test copy (.harness/mockmvc: after/ + harness/test/ProbeMethodTableTest.java - never shipped, never in the anchor)"
  rm -rf .harness/mockmvc; rsync -a --exclude target --exclude secrets --exclude .m2-demo after/ .harness/mockmvc/
  cp harness/test/ProbeMethodTableTest.java .harness/mockmvc/tiffinbox-web/src/test/java/com/tiffinbox/web/
  guard "the harness's test copy"
  (cd .harness/mockmvc && eval "$MV ${MOCKFLIP:-} -Dtest=ProbeMethodTableTest -Dsurefire.failIfNoSpecifiedTests=false test -pl tiffinbox-web -am") > .harness/build-mockmvc.log 2>&1 < /dev/null & mpid=$!
  while kill -0 $mpid 2> /dev/null; do n=0; for q in $BAND; do n=$((n + $(listeners $q))); done; [ $n -le $mx ] || mx=$n; sleep 0.5; done
  RE=0; wait $mpid || RE=$?; mpid=""
  offl .harness/build-mockmvc.log
  echo "  mvn -o test -Dtest=ProbeMethodTableTest -pl tiffinbox-web -am: exit $RE · Downloading/Downloaded from: 0 · listeners on 20910-20919 during the build (sampled): at most $mx"
  $G -E '^MOCKMVC ' .harness/build-mockmvc.log
  $G -E 'Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+.* in com\.tiffinbox\.web\.ProbeMethodTableTest' .harness/build-mockmvc.log | sed -E 's/^\[[A-Z]+\] //; s/, Time elapsed: [^-]* -- / -- /'
  $G -E '^\[ERROR\] .*ProbeMethodTableTest.*(expected|Expect|TRACE)|^\[ERROR\] Failures:|^\[ERROR\] +ProbeMethodTableTest' .harness/build-mockmvc.log | head -4 | cut -c1-200
  local x; x=$(ls .harness/mockmvc/tiffinbox-web/target/surefire-reports/TEST-*ProbeMethodTableTest.xml 2> /dev/null | head -1)
  echo "  the test's class path (its Surefire report): $( [ -n "$x" ] && tr ':' '\n' < "$x" | $G -oE '(spring-test|spring-boot-webmvc-test|spring-boot-test|mockito-core|assertj-core)-[0-9][0-9A-Za-z.-]*\.jar' | sort -u | paste -sd' ' - || echo none)"; }

# the seven and the old surface (no key header), each in its own JVM, H2, health-polled as U04's were; then the S9.14 plant on 20913
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
  HEALTHUP=1 tb seven 20910 h2 ""
  sh $CURLSET 20910 .harness/run/seven/secrets/tiffinbox/shutdown-token > $J/seven.txt 2>&1
  local i=0; while kill -0 "$(cat .harness/run/seven/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 400 ] || die "the seven's POST /shutdown did not stop it"; sleep 0.05; done
  tbstop seven 20910
  sed 's/^/  /' $J/seven.txt
  echo "  the seven: $(md5 -q $J/seven.txt) ($(wc -l < $J/seven.txt | tr -d ' ') lines) · expected $S466"; }
c_surface() {
  echo "== the old surface on after/, H2, its own JVM, no key header, the feed read by a count condition: expected $U4SURFC (../c9-unit04/receipts.sh's SURF=, = U04's inert: surface=)"
  HEALTHUP=1 tb surface 20910 h2 ""
  oldsurface2 20910 $J/surface.txt
  tbstop surface 20910
  sed 's/^/  /' $J/surface.txt
  echo "  the old surface: $(md5 -q $J/surface.txt) ($($G -c '^== ' $J/surface.txt) requests, $(wc -l < $J/surface.txt | tr -d ' ') lines) · expected $U4SURFC"
  echo "== the self-test (S9.14, the harness's plant - LABELLED, not a finding about TiffinBox): a ShallowEtagHeaderFilter on /* (probe.Etag, U04's), on 20913"
  SRC=probe.Etag HEALTHUP=1 tb seven-etag 20913 h2 "$U/.harness/hc"
  sh $CURLSET 20913 .harness/run/seven-etag/secrets/tiffinbox/shutdown-token > $J/seven-etag.txt 2>&1
  local i=0; while kill -0 "$(cat .harness/run/seven-etag/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 400 ] || die "seven-etag did not stop"; sleep 0.05; done; tbstop seven-etag 20913
  SRC=probe.Etag HEALTHUP=1 tb surface-etag 20913 h2 "$U/.harness/hc"; oldsurface2 20913 $J/surface-etag.txt; tbstop surface-etag 20913
  echo "  planted: the seven $(md5 -q $J/seven-etag.txt) (unchanged: $(cmp -s $J/seven-etag.txt $J/seven.txt && echo yes || echo NO)) · the old surface $(md5 -q $J/surface-etag.txt) (moved: $(cmp -s $J/surface-etag.txt $J/surface.txt && echo NO || echo yes)) · the feed's line: $($G '^== GET /customers/feed' $J/surface-etag.txt | sed -E 's/^== //')"; }

# the exercise: the README's block (broken), SOLUTION.md's (solved), and three refused "solutions" - each SOLUTION.md's block with its
# fixed line changed - against TiffinBox's jar alone on 20918 (no harness), env -i, from the exercise's folder, under bash then zsh -f
c_exercise() { local v sh d o
  XREP='import os, sys; f = sys.stdin.read(); a, b = os.environ["XN"].split("=>", 1); assert f.count(a) == 1, (a,); sys.stdout.write(f.replace(a, b))'
  for sh in bash zsh; do
    tb ex-$sh 20918 h2 ""
    for v in broken solved ionly custopts headkept; do
      d=$J/ex-$v-$sh; rm -rf $d; mkdir -p $d/exercise; cp exercise/ask.sh exercise/check.sh $d/exercise/
      case $v in broken) block exercise/README.md > $d/block.sh ;;
                 solved) block exercise/SOLUTION.md > $d/block.sh ;;
                 ionly) block exercise/SOLUTION.md | XN=' && curl --noproxy "*" -sS -X OPTIONS -D - -o /dev/null "$B/shutdown"=>' python3 -I -c "$XREP" > $d/block.sh ;;
                 custopts) block exercise/SOLUTION.md | XN='"$B/shutdown"=>"$B/customers"' python3 -I -c "$XREP" > $d/block.sh ;;
                 headkept) block exercise/SOLUTION.md | XN='-sS -I "$B/customers"=>-sS -X HEAD --max-time 5 -D - -o /dev/null "$B/customers"' python3 -I -c "$XREP" > $d/block.sh ;; esac
      case $v in ionly|custopts|headkept) [ "$(diff <(block exercise/SOLUTION.md) $d/block.sh | $G -c '^[<>]')" = 2 ] || die "the refused \"solution\" $v must be SOLUTION.md's block with one line changed" ;; esac
      if [ $sh = bash ]; then o=$(cd $d/exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=20918 bash ../block.sh 2>&1); else o=$(cd $d/exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=20918 /bin/zsh -f ../block.sh 2>&1); fi
      echo "== the exercise, $v, $sh (env -i, from the exercise's folder, TiffinBox's jar alone on 20918, H2):"; printf '%s\n' "$o" | maskh /dev/stdin | sed 's/^/  /'
    done
    tbstop ex-$sh 20918
  done
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures"
pgup
DB=pg; P=20912; L=TP
tb TP 20912 pg "$U/.harness/hc"
cap tablepg c_table
tbstop TP 20912
dk rm -fv $CN > /dev/null 2>&1 || die "$CN could not be removed"
DB=h2; P=20910; L=TH
tb TH 20910 h2 "$U/.harness/hc"
cap table c_table
cap xhead c_xhead
tbstop TH 20910
cap head c_view head
cap who c_view who
cap trace c_view trace
cap safe c_view safe
cap cross c_view cross
cap mockmvc c_mockmvc
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
build: libs=$LIBN seed_files=$NF0"
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
VO=$(python3 -I -B harness/chk02.py values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; die "README.md's values block is not this run's (harness/chk02.py values)"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM of this run, ports free, no container left, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1 · the tree pins = ../c9-unit04/after's after-tree · *.mv.db outside .harness 0 · the values block = this run's"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit02: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit02: every capture = published ($NCAPS) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"
