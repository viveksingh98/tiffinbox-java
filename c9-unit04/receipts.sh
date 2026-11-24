#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 04 "Idempotency, Safety and Retries" - this unit's receipts. Course 9's FIRST anchor change: before/ is a frozen copy
# of ../c9-tiffinbox at the set-up commit 80f7839 (= ../c8-unit27/after + a README header); after/ is ../c9-tiffinbox after this unit's
# change - Spring Boot 4.1.3 + Tomcat 11.0.29, V5__idempotency_key.sql, the fenced two-phase IdempotencyKeyFilter (order -90), the
# transaction-aware cache proxy, the public API's pause route, four tag: problem types, the pinning tests, the five ITs on
# 127.0.0.1:21280-21284. mid is the version step alone (before/ + 4.1.3 + 11.0.29), a copy under .harness/, never shipped.
# The harness (harness/src/probe/*, joined by --spring.main.sources, never in the jar): the statement witness (datasource-proxy), the
# request witness (PROBE-REQ, ERROR dispatches too), the hold advice and U08's order witness (probe.u04.U04Probe), the in-JVM map loser
# (probe.u04.MapKeys), the ShallowEtag plant (probe.Etag). Every line it prints is "the harness's".
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5):
#   tests     the version step and the ITs: mvn -o package on before/, mid and after/ (Surefire's XML), mvn -o verify on after/ (the
#             five IT BINDINGS lines), BOOT-INF/lib, the BOM's moves, the version lines, the handler methods (one flag start)
#   bill      Course 4's bill, read off ../c4-unit30 (the call-back) · twice  POST /customers twice, no key: 201 then 409
#   pause     the harness's unkeyed pause route twice: paused days 5 -> 7 -> 9 · key  the public route, no body, no Content-Type
#   mismatch  another query under a stored key: 422 · error  a planted failure after the write · race  a held first request, a duplicate
#   tx        a duplicate between the stored answer's UPDATE and the commit · fence  the slow original + a reclaiming retry (+ 2 plants)
#   kill      kill -9 inside phase 2, a restart (+ the no-reclaim plant on PostgreSQL) · map  the in-JVM map's restart (the loser)
#   types     the four type URIs, six malformed keys, the two 409s · order  U08's and U27's orders, proxy on and off · window  the cache
#             warm and cold · limits  413, prometheus, V5's column type · inert  the seven and the old surface on before/mid/after/proxy off
#   exercise  exercise/README.md's block, then SOLUTION.md's, then a wrong "solution" (another ?days= under the one key)
# Ports (Course 9's U04 band, 20930-20939): 20930 TiffinBox after/ on H2 (and the H2 kill pair) · 20931 PostgreSQL c9u04-pg · 20932
# TiffinBox after/ on PostgreSQL · 20933-20934 spare (asserted free) · 20935 the second JVM on PostgreSQL (R.408) · 20936 before/ ·
# 20937 mid · 20938 the exercise · 20939 never bound. During mvn verify only: 21280-21284, one per IT. Course 8's 20578 / 20615 and
# 18881-18884 are never bound. Every store on 127.0.0.1; every curl --noproxy '*'.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
MODE=${1:-run}
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
SETUP=80f7839
SEED=${SEED:-"/Users/$ME/Downloads/Youtube Content/LearnProgrammingWithVivek/rest-apis-done-right/_research/m2-seed-c9-u04"}   # the course's seed (B5b)
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c9u04-pg
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
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git uuidgen /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit04 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"

# ---- gates before anything is built: the folder, the pins, the anchor, the static check, the prose, the exercise ------------------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk04.py dur9.py s904.py src tree04.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
[ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe/Etag.java probe/Http.java probe/Routes.java probe/Witness.java probe/u04/MapKeys.java probe/u04/U04Probe.java' ] || die "harness/src holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md check.sh send.sh' ] || die "exercise/ holds another file, or misses one"
[ -d before ] && [ ! -L before ] && [ -d after ] && [ ! -L after ] || die "before/ and after/ are this unit's own frozen trees, not links (the link form resumes at unit 05)"
for t in before after; do [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/ - never built in place"; true; done
$G -v '^ *#' harness/src/probe/u04/*.java harness/src/probe/*.java | $G -q 'Thread\.sleep' && die "R.412: a Thread.sleep in harness/src"
git rev-parse -q --verify "$SETUP^{commit}" > /dev/null 2>&1 || die "the set-up commit $SETUP is not in this repository's history"
rm -rf .harness; mkdir -p .harness/setup .harness/home .harness/run .harness/work
git -C "$UP" archive "$SETUP" c9-tiffinbox 2> /dev/null | tar -x -C .harness/setup || die "git archive $SETUP c9-tiffinbox failed"
SD=$(diff -rq before .harness/setup/c9-tiffinbox 2>&1 || true)
[ -z "$SD" ] || die "before/ is not c9-tiffinbox at the set-up commit $SETUP (diff -rq: $(printf '%s\n' "$SD" | head -2 | paste -sd';' -))"
echo "  before/ against git archive $SETUP c9-tiffinbox (diff -rq): empty - before/ is the anchor at the set-up commit"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree04.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree04.py $dir/ -> $got = receipts.md5's $nm line"; }
pin before-tree before; pin after-tree after
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true)
echo "  after/ against ../c9-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures its own frozen after/' )"
echo "  before/ against ../c8-unit27/after (diff -rq): $(diff -rq before ../c8-unit27/after 2>&1 | sed "s#$UP/##g; s#\.\./##g" | paste -sd';' -)"
ST=$(python3 -I -B harness/chk04.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s904.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U04 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s904, per sentence): /'
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
GLOSS="An idempotency key: a label the client puts on a request so a repeat of it gets the first answer back."
[ "$($G -cxF -- "$GLOSS" README.md)" = 1 ] || die "the gloss (SECTION SHAPE 04) must stand in README.md once, as a line of its own, byte for byte"
EXQ="Your turn: the same pause sent twice counts twice on the dashboard. Send it twice so it counts once."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
[ "$EXW" = 19 ] || die "the exercise's spoken line is $EXW words, the brief's is 19"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
HOOK="Send the same pause twice and TiffinBox counts it twice: five paused days, then seven, then nine."
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S1B :305), byte for byte"
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
SETX=$(block exercise/README.md); SOLX=$(block exercise/SOLUTION.md)
[ -n "$SETX" ] && [ -n "$SOLX" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
[ "$(diff <(printf '%s\n' "$SETX") <(printf '%s\n' "$SOLX") | $G -c '^[<>]')" = 2 ] || die "R.196: SOLUTION.md's block must be the README's with one line changed"
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
$G -qxF 'KEY2=$(uuidgen)' exercise/send.sh || die "exercise/send.sh: the broken form - a fresh key for the second try (KEY2=\$(uuidgen))"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket"
DK=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -vF 'echo "' | $G -nE '(^|[ ;(])docker (run|exec|rm|ps|port|info|images|volume|image|pull|logs|inspect)\b' | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.344: receipts.sh calls docker without the pinned socket: $DK"
RMF=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) rm( +-[a-z]+)*' | sort -u | paste -sd'|' -)
[ "$RMF" = 'dk rm -fv' ] || die "R.387: receipts.sh removes a container without its volumes (found: ${RMF:-none})"
[ "$($G -v '^ *#' receipts.sh | $G -oE '(dk|docker) run -[^"]*' | $G -vcF -- '--pull never' || true)" = 0 ] || die "R.344: a dk run without --pull never"
MVA=$($G -v '^ *#' receipts.sh | $G -F '$MV ' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am"
echo "  the exercise: the spoken line $EXW words (wc -w); SOLUTION.md's block = the README's with one line changed; send.sh broken as shipped (a fresh key per try); the two What-it-prints blocks differ · the gloss and the hook byte for byte · placeholders 0"
echo "  static: no kill by name; every docker call on the pinned socket, every dk run --pull never, every removal rm -fv; every Maven build -pl tiffinbox-web -am; no Thread.sleep in harness/src"
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
    gsub(/\[[0-9]+\] /, "[<pg pid>] ")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'took 812 ms' '2026-11-24 07:12:01.123 CET [77] LOG:  statement: select 1' "$U/x $HOME/y" | mask)
[ "$(printf '%s\n' "$MP" | paste -sd'|' -)" = 'Started TiffinBoxServer in <t> (process running for <t>)|took <t>|<time> [<pg pid>] LOG:  statement: select 1|…/x ~/y' ] || die "the mask's self-test: $(printf '%s\n' "$MP" | paste -sd'|' -)"
echo "  mask: its self-test masked a Started line's times, a millisecond count, PostgreSQL's log prefix (time and pid), the folders and the home"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
$G -qF 'S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)' ../c8-unit27/receipts.sh || die "../c8-unit27/receipts.sh no longer reads the seven's md5 off ../c7-unit31/receipts.sh"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
SURF=316a96370fe5c34f58fc6ecca8e9557b   # the old surface, feed read by a count condition: the boundary's B8 re-baseline (S1B, BOUNDARY CHECK RESULT)
SURFP=e6b8a52edf25a850d4ed8c18b38c3878  # its ShallowEtag plant, the same section

# ---- docker, ports, the guard: the baselines ----------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that socket? (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
iid() { dk image inspect --format '{{.Id}}' "$1" 2> /dev/null | cut -c8-19; }
[ "$(iid $IMG)" = 77f585114c32 ] || die "the image $IMG is not on this machine - this script never pulls"
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run"
[ -z "$(dk ps -aq --filter name=^/$CN\$ 2> /dev/null)" ] || die "a container named $CN exists before the run - an interrupted run's? docker -H \"\$DH\" rm -fv $CN"
TC0=1
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18881 18882 18883 18884 20578 20615 20930 20931 20932 20933 20934 20935 20936 20937 20938 20939 21280 21281 21282 21283 21284"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
for p in 21280 21281 21282 21283 21284; do [ -z "$(lsof -nP -iUDP:$p 2> /dev/null)" ] || die "UDP $p is bound"; done
[ "$(pgrep -x java | wc -l | tr -d ' ')" = 0 ] || die "a java process is running before this script starts one - not this script's; stop it first"
guard() { local r; r=$(pgrep -fl "^/bin/(ba)?sh (\./|.*/)(receipts|runrec)[.]sh" 2> /dev/null | $G -v "^$$ " || true)
  local l1; l1=$(sysctl -n vm.loadavg | awk '{ print $2 }')
  [ -z "$r" ] || die "S9.17: another receipt runs ($r) before $1 - this run stops; wait for it, never kill it"
  local w=0; while ! awk -v l="$l1" 'BEGIN { exit !(l < 20) }'; do
    [ -n "${GUARD0:-}" ] || die "R.480: load1 $l1 is not below 20 at the launch - a run of record launches only below 20; launch again when it is"
    w=$((w + 1)); [ $w -lt 900 ] || die "R.480: load1 stayed at or above 20 for 900 checks before $1"; sleep 1; l1=$(sysctl -n vm.loadavg | awk '{ print $2 }'); done
  GUARD0=1
  echo "  guard before $1: no other receipt · load1 $l1 (< 20)$( [ $w = 0 ] || echo " after $w checks at or above 20 (waited, never killed)")"; }
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · $IMG present · nothing pulled, ever · no Testcontainers container, no $CN · ports $PORTS free (TCP; 21280-21284 UDP too) · no java process"

# ---- the trees, copied and built offline: before/, mid (the version step alone), after/; the harness, compiled -----------------------
M2="$PWD/.m2-demo"
if [ ! -d "$M2" ]; then [ -d "$SEED" ] || die "the seed $SEED is missing (README.md, The repository)"; cp -cR "$SEED" "$M2" 2> /dev/null || cp -R "$SEED" "$M2" || die "the seed could not be copied"; fi
NF0=$(find "$M2" -type f | wc -l | tr -d ' ')
[ -f "$M2/org/springframework/boot/spring-boot-starter-parent/4.1.3/spring-boot-starter-parent-4.1.3.pom" ] && [ -f "$M2/org/apache/tomcat/embed/tomcat-embed-core/11.0.29/tomcat-embed-core-11.0.29.jar" ] || die ".m2-demo holds no 4.1.3 parent or no Tomcat 11.0.29 - it is not the U04 seed"
echo "  .m2-demo (a copy of the seed m2-seed-c9-u04): files $NF0 · the 4.1.3 parent and tomcat-embed-core 11.0.29 present"
printf '%s\n' 'checks.disable=true' "tinyimage.container.image=$IMG" > .harness/home/.testcontainers.properties
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy before .harness/before; copy before .harness/mid; copy after .harness/after; copy after .harness/verify
python3 -I - .harness/mid/pom.xml <<'PY' || die "mid: the version step could not be written"
import sys
p = sys.argv[1]; s = open(p).read()
a = "    <version>4.1.2</version>\n    <relativePath/>"; b = "    <h2.version>2.5.250</h2.version>\n"
assert s.count(a) == 1 and s.count(b) == 1
s = s.replace(a, "    <version>4.1.3</version>\n    <relativePath/>").replace(b, b + "    <tomcat.version>11.0.29</tomcat.version>\n")
open(p, "w").write(s)
PY
echo "  mid = before/ + the version step alone: $(diff before/pom.xml .harness/mid/pom.xml | $G '^[<>]' | sed 's/^ *//' | tr -s ' ' | paste -sd'|' -)"
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE 'Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" HOME=\"$U/.harness/home\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 900; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
AL="-DargLine=$JL -Dstdout.encoding=UTF-8 -Duser.home=../../home"
for t in before mid after; do
  guard "the build of $t"
  bg "cd .harness/$t && $MV \"$AL\" clean package -pl tiffinbox-web -am" .harness/build-$t.log
  [ "$RE" = 0 ] || { tail -30 .harness/build-$t.log | mask >&3; die ".harness/$t did not build offline (exit $RE)"; }; offl .harness/build-$t.log
  bg "cd .harness/$t && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$t.log
  [ "$RE" = 0 ] || die ".harness/$t: the jar's extract failed"
  echo "  built $t offline (mvn -o clean package -pl tiffinbox-web -am, exit 0, Downloading/Downloaded from: 0) · its jar extracted"
done
CPA=".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*"
DSP="$M2/net/ttddyy/datasource-proxy/1.11.1/datasource-proxy-1.11.1.jar"
PGJ=$(ls .harness/after/$XD/lib | $G '^postgresql-[0-9.]*\.jar$' || true)
[ -f "$DSP" ] || die "the harness's jar (datasource-proxy 1.11.1) is not in .m2-demo"
[ -n "$PGJ" ] || die "after/'s lib/ holds no PostgreSQL driver - the dev profile's driver ships in the jar since Course 8"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \"$CPA:$DSP\" harness/src/probe/*.java harness/src/probe/u04/*.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/'s jar: $(head -5 .harness/javac.log)"
FS=after/tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java
mkdir -p .harness/plants/nofence .harness/plants/nolimit .harness/plants/noreclaim
sed -e 's/ WHERE idem_key = ? AND claim_token = ? AND status = 0",/ WHERE idem_key = ? AND status = 0",/' -e 's/StandardCharsets.UTF_8), key, token);/StandardCharsets.UTF_8), key);/' \
    -e 's/if (n != 1) {/if (false) {/' -e '/this.phase2.setTimeout(limit);/d' -e 's/AND status = 0", key, token);/AND status = 0", key);/' $FS > .harness/plants/nofence/IdempotencyKeyFilter.java
sed -e '/this.phase2.setTimeout(limit);/d' $FS > .harness/plants/nolimit/IdempotencyKeyFilter.java
sed -e 's/AND status = 0 AND claimed_at < CURRENT_TIMESTAMP/AND 1 = 0 AND status = 0 AND claimed_at < CURRENT_TIMESTAMP/' $FS > .harness/plants/noreclaim/IdempotencyKeyFilter.java
for p in nofence nolimit noreclaim; do
  [ "$(diff $FS .harness/plants/$p/IdempotencyKeyFilter.java | $G -c '^[<>]')" -ge 1 ] || die "plant-$p: its sed changed nothing"
  bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/pc-$p -cp \"$CPA\" .harness/plants/$p/IdempotencyKeyFilter.java" .harness/javac-$p.log
  [ "$RE" = 0 ] || die "plant-$p did not compile: $(head -5 .harness/javac-$p.log)"; done
echo "  the harness compiled against after/'s jar ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes, javac 25 -parameters; datasource-proxy 1.11.1 from .m2-demo, on the harness's class path only; the PostgreSQL driver is the jar's own, $PGJ) · the three plants compiled (each the shipped filter with one sed)"

# ---- helpers ---------------------------------------------------------------------------------------------------------------------------
B() { echo "http://127.0.0.1:$1"; }
keyh() { printf 'Idempotency-Key: "%s"' "$1"; }
r() { local o=$1 m=$2 u=$3 w rc; shift 3
  w=$($CURL --http1.1 -sS -D "$o.h" -o "$o.b" -w '%{http_code} %{content_type} %{size_download}' --max-time 20 -X "$m" "$@" "$u" 2> "$o.err"); rc=$?
  echo "$m $(printf '%s' "$u" | sed -E 's#^http://127\.0\.0\.1:[0-9]+##') -> $w (curl exit $rc)"; }
bgr() { local o=$1; shift; $CURL --http1.1 -sS -D "$o.h" -o "$o.b" -w '%{http_code}' --max-time 60 "$@" > "$o.code" 2> "$o.err" & LASTPID=$!; }
maskh() { tr -d '\r' < "$1" | sed -E 's/^(Date|date): .*/\1: <masked>/; s/(JSESSIONID=)[^;]*/\1<masked>/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/^(Expires): .*/\1: <masked>/'; }
hdr() { maskh "$1" | $G -iE '^(HTTP|Location|Content-Type):?' | tr '\n' ' ' | sed 's/ *$//'; }
cmpans() { if diff <(maskh "$1.h"; cat "$1.b") <(maskh "$2.h"; cat "$2.b") > /dev/null; then echo "cmp: byte-identical (Date masked; headers + body)"; else echo "cmp: DIFFER"; diff <(maskh "$1.h"; cat "$1.b") <(maskh "$2.h"; cat "$2.b") | sed 's/^/      /'; fi; }
prob() { python3 -I -B harness/chk04.py prob "$1"; }
J=.harness/work
mark() { wc -l < ".harness/run/$1/jvm.log" | tr -d ' '; }
since() { sed -n "$(( $2 + 1 )),\$p" ".harness/run/$1/jvm.log" | $G -E "${3:-KEY |U04HOLD|U08ORDER|U04PLANT|MAPKEY}" | sed -E 's/^.*(KEY |U04HOLD|U08ORDER|U04PLANT|PROBE-REQ|MAPKEY|CACHE |FILTER-ORDER)/\1/' | sed -E 's/PROBE-REQ [0-9]+ /PROBE-REQ /' | cut -c1-240 | sed 's/^/      /'; }
reqline() { local i=0 x; while :; do x=$(sed -n "$(( $2 + 1 )),\$p" ".harness/run/$1/jvm.log" | $G -E "PROBE-REQ [0-9]+ $3[? ]" | sed -E 's/^.*PROBE-REQ [0-9]+ /PROBE-REQ /' | head -1 | cut -c1-240)
  [ -n "$x" ] && break; i=$((i + 1)); [ $i -lt 100 ] || break; sleep 0.02; done; echo "$x"; }
wlf() { local f=".harness/run/$1/jvm.log" s=$2 i=0; while ! $G -q -F -- "$s" "$f"; do i=$((i + 1)); [ $i -lt 1200 ] || return 1; sleep 0.05; done; }
cust() { echo "{\"name\":\"$1\",\"mealsPerDay\":1,\"pricePerMeal\":110,\"mealType\":\"VEG\"}"; }
psqlq() { dk exec $CN psql -U tiffinbox -d "${2:-tiffinbox}" -qAt -c "$1" 2>&1 | tr '\n' ' ' | sed 's/ *$//'; }
pgmark() { psqlq "select 'S9MARK-$1'" > /dev/null; }
pgslice() { dk logs $CN 2>&1 | awk -v a="S9MARK-$1-begin" -v b="S9MARK-$1-end" 'index($0, a) { f = 1; next } index($0, b) { f = 0 } f' | $G -E 'LOG:  (execute|statement)|ERROR:|DETAIL:' | $G -v "S9MARK" | sed -E 's/^.*(LOG:|ERROR:|DETAIL:)/\1/' | cut -c1-220 | sed 's/^/      pg: /'; }
# the second client: H2 = the harness's JdbcTemplate routes; PostgreSQL = psql in the container
pd() { $CURL -s -H 'Accept: application/json' "$(B $1)/dashboard" | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["pausedDays"])'; }
pauses() { if [ "$DB" = pg ]; then echo "$(psqlq "SELECT count(*) || ' pauses, ' || coalesce(sum(days),0) || ' days' FROM pause") (psql)"; else echo "$($CURL -s "$(B $1)/probe/u04/pauses" | python3 -I -B harness/chk04.py pauses) (the harness's /probe/u04/pauses)"; fi; }
keyrow() { if [ "$DB" = pg ]; then local x; x=$(psqlq "SELECT 'status ' || status || ' claimed ' || (claim_token IS NOT NULL) FROM idempotency_key WHERE idem_key = '$2'"); echo "${x:-no row} (psql)"; else echo "$($CURL -s "$(B $1)/probe/u04/keys" | python3 -I -B harness/chk04.py keyrow "$2") (the harness's /probe/u04/keys)"; fi; }
rows() { if [ "$DB" = pg ]; then echo "$(psqlq "SELECT count(*) FROM customer WHERE name = '$2'") (psql)"; else echo "$($CURL -s "$(B $1)/probe/row/$2" | python3 -I -c 'import json,sys; print(len(json.load(sys.stdin)))') (the harness's /probe/row)"; fi; }
ck() { $CURL -s "$(B $1)/probe/u04/cache" | python3 -I -B harness/chk04.py ck; }
# tb LABEL PORT DB HCX [args]: TiffinBox (the extracted jar of TREE=after unless TREE is set), from its own run folder with a generated
# token (a config tree, 0600, never printed); waited for by its Started line (never a health poll: the cache's cold state stays observable)
tb() { local label=$1 port=$2 db=$3 hcx=$4 t=${TREE:-after} run=.harness/run/$1 jx="" src="" i=0; shift 4
  guard "TiffinBox $label"
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  local x="$U/.harness/$t/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  if [ -n "$hcx" ]; then cp="$hcx:$cp:$U/.harness/hc:$DSP"; src="--spring.main.sources=probe.Witness,probe.Http,probe.Routes,probe.u04.U04Probe${SRCX:-}"; fi
  [ "$db" = pg ] && { jx="-Dtiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:20931/tiffinbox?user=tiffinbox"; }
  [ -n "${H2URL:-}" ] && jx="-Dtiffinbox.jdbc-url=$H2URL"
  (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 $jx -cp "$cp" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port="$port" $src "$@" > jvm.log 2>&1) &
  local p=$!; echo $p > "$run/pid"; PIDS="$PIDS $p"
  if [ -n "${HEALTHUP:-}" ]; then
    while [ "$($CURL -s -o /dev/null -w '%{http_code}' --max-time 2 "$(B $port)/actuator/health" 2> /dev/null || true)" != 200 ]; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before health 200"; }; i=$((i + 1)); [ $i -lt 600 ] || die "$label: no health 200"; sleep 0.1; done
  else
    while ! $G -q -E 'Started TiffinBox(App|Server) in' "$run/jvm.log" 2> /dev/null; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before its Started line"; }; i=$((i + 1)); [ $i -lt 900 ] || die "$label: no Started line"; sleep 0.1; done
  fi
  echo "  $label up on $port ($db$( [ -n "$hcx" ] && echo ", the harness joined")) · $($G -o -E 'Successfully applied [0-9]+ migrations[^(]*|Schema "[^"]*" is up to date[^.(]*' "$run/jvm.log" | head -1 | sed 's/ *$//')"; }
tbstop() { local label=$1 port=$2 run=.harness/run/$1 p i=0; p=$(cat "$run/pid")
  if kill -0 "$p" 2> /dev/null; then printf 'X-Shutdown-Token: %s\n' "$(head -1 "$run/secrets/tiffinbox/shutdown-token")" | $CURL -s -o /dev/null --max-time 5 -H @- -X POST "$(B $port)/shutdown" || true; fi
  while kill -0 "$p" 2> /dev/null; do i=$((i + 1)); [ $i = 80 ] && kill "$p" 2> /dev/null; [ $i -lt 400 ] || { kill -9 "$p" 2> /dev/null; break; }; sleep 0.05; done
  wait "$p" 2> /dev/null || true; PIDS=$(echo " $PIDS " | sed "s/ $p / /g")
  [ "$(listeners $port)" = 0 ] || die "$label: something still listens on $port"; }
pgfresh() { psqlq "drop database if exists tiffinbox with (force)" postgres > /dev/null; psqlq "create database tiffinbox" postgres > /dev/null; }
pgup() { guard "the PostgreSQL container"
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:20931:5432 -e POSTGRES_DB=tiffinbox -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust $IMG -c log_statement=all" .harness/docker-run-pg.log
  [ "$RE" = 0 ] || die "the PostgreSQL container did not start: $(tail -2 .harness/docker-run-pg.log)"
  local i=0; while ! dk exec $CN pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 240 ] || die "PostgreSQL did not accept connections"; sleep 0.5; done
  [ "$(dk port $CN | paste -sd'|' -)" = '5432/tcp -> 127.0.0.1:20931' ] || die "$CN publishes on another address than 127.0.0.1:20931"
  echo "  $CN: PostgreSQL $(psqlq 'show server_version') by the digest, on 127.0.0.1:20931 alone (docker port), log_statement $(psqlq 'show log_statement'), trust on the loopback (no password exists to print)"; }
NCAPS=0; unpub=""; VALS=""
cap() { local nm=$1; shift
  if [ -n "${DEVCAPS:-}" ] && ! echo " $DEVCAPS " | $G -qF " $nm "; then return 0; fi   # development only: a run of record sets no DEVCAPS (its log says so)
  "$@" > .harness/cap-$nm.raw 2>&1 || true
  $G -q '^  \*\*\* ' .harness/cap-$nm.raw && { cat .harness/cap-$nm.raw >&3; die "$nm stopped (above)"; }
  mask < .harness/cap-$nm.raw > .r-$nm.new
  sed 's/^/  | /' .r-$nm.new | cut -c1-260
  local o e=0; o=$(python3 -I -B harness/chk04.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk04 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -6 >&3; [ -n "${DEVCAPS:-}" ] && { echo "  (development: $nm's check failed, the run goes on)"; unpub="$unpub $nm"; } || die "$nm: its check failed (harness/chk04.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk04.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-9s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-9s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff its block in README.md against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }

# ---- the captures --------------------------------------------------------------------------------------------------------------------
TD="--logging.level.tiffinbox.idempotency=debug"   # the shipped defaults (phase 2 and the reclaim age as IdempotencyKeys sets them)
TV="$TD --tiffinbox.idempotency.phase2-timeout=2s --tiffinbox.idempotency.reclaim-after=5s"
TVL="the receipt's test values, not the defaults: tiffinbox.idempotency.phase2-timeout=<test value>, reclaim-after=<test value>, each once on the command line"

c_tests() {
  local t f
  for t in before mid after; do
    echo "== $t: mvn -o clean package -pl tiffinbox-web -am (H2, Docker-free) · Surefire's XML, per class"
    for f in .harness/$t/tiffinbox-web/target/surefire-reports/TEST-*.xml; do python3 -I -B harness/chk04.py surefire "$f"; done
    echo "  BOOT-INF/lib: $(ls .harness/$t/$XD/lib | wc -l | tr -d ' ') jars · $(ls .harness/$t/$XD/lib | $G -E '^(spring-boot-[0-9]|spring-core-|tomcat-embed-(core|el|websocket)-|netty-common-|jackson-databind-|tools\.jackson\.core|jackson-core-3|hibernate-core-|spring-data-commons-|spring-data-mongodb-|spring-data-elasticsearch-|flyway-core-|h2-)' | sort | paste -sd' ' -)"
  done
  echo "== the BOM: spring-boot-dependencies 4.1.2 -> 4.1.3, version properties"
  python3 -I -B harness/chk04.py bom "$M2/org/springframework/boot/spring-boot-dependencies/4.1.2/spring-boot-dependencies-4.1.2.pom" "$M2/org/springframework/boot/spring-boot-dependencies/4.1.3/spring-boot-dependencies-4.1.3.pom"
  echo "== BOOT-INF/lib before/ -> after/ (the jars whose names moved)"
  diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G '^[<>]' | sed 's/^/  /'
  echo "== mvn -o verify on after/ (the five ITs; 21280-21284 asserted free before; Docker's own record of each Testcontainers container polled through the pinned socket)"
  for p in 21280 21281 21282 21283 21284; do [ "$(listeners $p)" = 0 ] && [ -z "$(lsof -nP -iUDP:$p 2> /dev/null)" ] || die "$p is bound before verify"; done
  guard "mvn verify"
  : > .harness/tcps.txt
  ( while :; do dk ps --filter label=org.testcontainers=true --format '{{.Ports}}' >> .harness/tcps.txt 2> /dev/null; sleep 1; done ) & pollpid=$!
  bg "cd .harness/verify && DOCKER_HOST=\"$DH\" TESTCONTAINERS_RYUK_DISABLED=true $MV \"$AL\" clean verify -pl tiffinbox-web -am" .harness/verify.log
  kill $pollpid 2> /dev/null; wait $pollpid 2> /dev/null; pollpid=""
  local vre=$RE; offl .harness/verify.log
  $G -q 'Timed out waiting' .harness/verify.log && echo "  an IT's wait TIMED OUT (R.480: this run of record fails)"
  echo "  mvn verify exit $vre · Results: $($G -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures' .harness/verify.log | sed -E 's/^\[[A-Z]+\] //' | paste -sd'|' -)"
  $G -E '^IT BINDINGS ' .harness/verify.log | sort | sed 's/^/  /'
  echo "  Testcontainers' containers while verify ran (docker ps Ports, beside, never the witness): $(tr ', ' '\n\n' < .harness/tcps.txt | $G -oE '^[0-9.]+:[0-9]+' | sort -u | paste -sd' ' -)"
  echo "  Testcontainers containers after: $(dk ps -aq --filter label=org.testcontainers=true | wc -l | tr -d ' ') · listeners on 21280-21284 after: $(for p in 21280 21281 21282 21283 21284; do listeners $p; done | paste -sd+ - | bc)"
  for f in .harness/verify/tiffinbox-web/target/surefire-reports-it/TEST-*.xml; do python3 -I -B harness/chk04.py surefire "$f"; done
  echo "== mvn -o dependency:list on after/ (S9.36 (1): the resolved tree, offline from the seed)"
  bg "cd .harness/verify && $MV \"$AL\" -DskipTests compile dependency:list -DincludeScope=runtime -pl tiffinbox-web -am" .harness/deps.log
  echo "  exit $RE · $($G -cE '^\[INFO\]    [a-z].*:(compile|runtime)' .harness/deps.log) runtime entries · $($G -oE '(org\.apache\.tomcat\.embed:tomcat-embed-core|io\.netty:netty-common|org\.springframework:spring-core|org\.springframework\.boot:spring-boot):jar:[0-9A-Za-z.]+' .harness/deps.log | sort -u | paste -sd' ' -)"
  offl .harness/deps.log
  echo "== the handler methods on after/ (one flag start: mappings exposed, never shipped)"
  tb flag 20930 h2 "" --management.endpoints.web.exposure.include=health,prometheus,mappings
  $CURL -s "$(B 20930)/actuator/mappings" | python3 -I -B harness/chk04.py mappings
  echo "  version lines (this JVM): $($G -oE 'Starting Servlet engine: \[[^]]*\]|HHH000001: Hibernate ORM core version [0-9A-Za-z.]+|Flyway OSS Edition [0-9.]+|Successfully applied [0-9]+ migrations to schema "[A-Z]+", now at version v[0-9]+' .harness/run/flag/jvm.log | paste -sd'|' -) · Boot $(ls .harness/after/$XD/lib | sed -n 's/^spring-boot-\([0-9][0-9.]*\)\.jar$/\1/p') · Framework $(ls .harness/after/$XD/lib | sed -n 's/^spring-core-\([0-9][0-9.]*\)\.jar$/\1/p')"
  echo "  Hibernate's validate and the extra table: the start above passed ddl-auto validate with idempotency_key in the schema (no entity maps it)"
  tbstop flag 20930; }

c_bill() {
  local f=../c4-unit30/README.md o=../c4-unit30/.r-bill.out
  echo "== Course 4's Core Resilience Annotations in Framework 7 (../c4-unit30), read the day this runs: README.md md5 $(md5 -q $f)"
  awk '/^## The break — the bill/ { f = 1 } f && /^The gateway/ { exit } f' $f | $G -v '^$' | sed 's/^/  README: /'
  if [ -f $o ]; then echo "  (.r-bill.out, git-ignored, not hashed) lines 1-2:"; head -2 $o | sed 's/^/  (.r-bill.out, git-ignored, not hashed) /'; echo "  (.r-bill.out, git-ignored, not hashed) the README block and .r-bill.out agree: $(diff <(head -2 $o) <(awk '/^## The break — the bill/ { f = 1 } f && /^```$/ { n++; next } f && n == 1' $f | head -2) > /dev/null && echo yes || echo NO)"; else echo "  (.r-bill.out, git-ignored, not hashed) absent here - the tracked README's block is the source"; fi
  echo "  C9-12 (the payment sent twice): named for Timeouts and Retries From the Caller's Side - nothing measured here"; }

c_twice() { local P=$1; echo "== $DB: POST /customers (JSON, no key) twice - the table is safe, the client is told its own success failed"
  echo "  try 1: $(r $J/tw1 POST "$(B $P)/customers" -H 'Content-Type: application/json' --data-binary "$(cust Nila)") · rows $(rows $P Nila)"
  echo "  try 2: $(r $J/tw2 POST "$(B $P)/customers" -H 'Content-Type: application/json' --data-binary "$(cust Nila)") · rows $(rows $P Nila) · $(prob $J/tw2.b)"
  echo "  R.312, the negation: the same body with a fresh name: $(r $J/tw3 POST "$(B $P)/customers" -H 'Content-Type: application/json' --data-binary "$(cust Nilam)") · rows $(rows $P Nilam)"; }

c_pause() { local P=$1; echo "== $DB: the harness's unkeyed pause route POST /probe/pauses/Sunil?days=2 twice (no key is read: /probe/** is not in the key filter's URL patterns)"
  echo "  /dashboard pausedDays $(pd $P) · $(pauses $P)"
  echo "  try 1: $(r $J/pa1 POST "$(B $P)/probe/pauses/Sunil?days=2") · pausedDays $(pd $P) · $(pauses $P)"
  echo "  try 2: $(r $J/pa2 POST "$(B $P)/probe/pauses/Sunil?days=2") · pausedDays $(pd $P) · $(pauses $P)"; }

c_key() { local P=$1 m loc; echo "== $DB: POST /api/v1/customers/Sunil/pauses?days=2 - no body, no Content-Type"
  m=$(mark $L)
  echo "  (i) no key: $(r $J/k0 POST "$(B $P)/api/v1/customers/Sunil/pauses?days=2") · $(prob $J/k0.b) · pausedDays $(pd $P)"
  echo "  (ii) key a-1, try 1: $(r $J/k1 POST "$(B $P)/api/v1/customers/Sunil/pauses?days=2" -H "$(keyh a-1)") · $(hdr $J/k1.h) · $(cat $J/k1.b) · pausedDays $(pd $P)"
  [ "$DB" = pg ] && pgmark key-begin
  m=$(mark $L)
  echo "  (ii) key a-1, try 2: $(r $J/k2 POST "$(B $P)/api/v1/customers/Sunil/pauses?days=2" -H "$(keyh a-1)") · $(cmpans $J/k1 $J/k2)"
  echo "    the request witness: $(reqline $L $m 'POST /api/v1/customers/Sunil/pauses')"
  [ "$DB" = pg ] && { pgmark key-end; echo "    PostgreSQL's log_statement between the markers (the second witness):"; pgslice key; }
  echo "    pausedDays $(pd $P) · $(pauses $P)"
  loc=$(tr -d '\r' < $J/k1.h | $G -i '^location:' | sed 's/^[^:]*: //')
  echo "  GET its Location: $(r $J/kl GET "$loc") · $(cat $J/kl.b) · key row a-1: $(keyrow $P a-1)"
  echo "  (iii) POST /customers JSON, key j-1: $(r $J/j1 POST "$(B $P)/customers" -H 'Content-Type: application/json' -H "$(keyh j-1)" --data-binary "$(cust Jaya)") · again: $(r $J/j2 POST "$(B $P)/customers" -H 'Content-Type: application/json' -H "$(keyh j-1)" --data-binary "$(cust Jaya)") · $(cmpans $J/j1 $J/j2) · rows $(rows $P Jaya)"
  echo "  (iii) POST /customers JSON, no key (inert): $(r $J/j3 POST "$(B $P)/customers" -H 'Content-Type: application/json' --data-binary "$(cust Inder)") · rows $(rows $P Inder)"
  echo "  (iv) the form at /customers WITH a key: $(r $J/fm POST "$(B $P)/customers" -H 'Content-Type: application/x-www-form-urlencoded' -H "$(keyh f-1)" --data-binary 'name=Farah&mealsPerDay=2&pricePerMeal=100&mealType=VEGAN') · $(hdr $J/fm.h | sed -E 's/;jsessionid=[^ ]*//') · rows $(rows $P Farah) · key row f-1: $(keyrow $P f-1)"
  echo "  (iv) application/json-patch+json at /customers with a key: $(r $J/jp POST "$(B $P)/customers" -H 'Content-Type: application/json-patch+json' -H "$(keyh jp-1)" --data-binary "$(cust Juhi)") · rows $(rows $P Juhi) · key row jp-1: $(keyrow $P jp-1)"
  echo "  a replay carries only these: $(maskh $J/k2.h | $G -iE '^(HTTP|Location|Content-Type|Content-Length):?' | cut -d' ' -f1 | tr -d ':' | paste -sd' ' -) (and the body)"; }

c_mismatch() { local P=$1; echo "== $DB: key a-1 again with another query, ?days=3"
  echo "  $(r $J/mm POST "$(B $P)/api/v1/customers/Sunil/pauses?days=3" -H "$(keyh a-1)") · $(prob $J/mm.b) · pausedDays $(pd $P)"
  echo "  the fingerprint: SHA-256 over the method, the request URI and the query as sent, and the body's bytes"; }

c_error() { local P=$1 m; echo "== $DB: a planted failure after the route's write (the harness's X-Probe-Fail-After-Write), POST /customers JSON, key pl-1"
  m=$(mark $L)
  echo "  planted: $(r $J/pl1 POST "$(B $P)/customers" -H 'Content-Type: application/json' -H "$(keyh pl-1)" -H 'X-Probe-Fail-After-Write: 1' --data-binary "$(cust Pallavi)") · $(hdr $J/pl1.h) · rows $(rows $P Pallavi) · key row pl-1: $(keyrow $P pl-1)"
  since $L $m 'KEY |U04PLANT'
  echo "  its retry, same key: $(r $J/pl2 POST "$(B $P)/customers" -H 'Content-Type: application/json' -H "$(keyh pl-1)" --data-binary "$(cust Pallavi)") · $(hdr $J/pl2.h) · rows $(rows $P Pallavi) · key row pl-1: $(keyrow $P pl-1)"; }

c_race() { local P=$1 P2=${2:-} m flag=$U/$J/flag-race-$DB pid; rm -f "$flag"; echo "== $DB: the first request held after its write, inside phase 2 (a planted hold); a duplicate meanwhile"
  m=$(mark $L)
  bgr $J/ra1 -X POST -H "$(keyh o-1)" -H "X-Probe-Hold-File: $flag" -H 'X-Probe-Hold-Where: after-write' "$(B $P)/api/v1/customers/Priya/pauses?days=1"; pid=$LASTPID
  wlf $L 'U04HOLD Pauses.add (key "o-1") after the write' || die "the hold's line did not appear"
  echo "  the duplicate, same JVM, while the first is held: $(r $J/ra2 POST "$(B $P)/api/v1/customers/Priya/pauses?days=1" -H "$(keyh o-1)") · $(prob $J/ra2.b)"
  [ -n "$P2" ] && echo "  the duplicate on the second JVM ($P2, the same database), while the first is held: $(r $J/ra3 POST "$(B $P2)/api/v1/customers/Priya/pauses?days=1" -H "$(keyh o-1)") · $(prob $J/ra3.b)"
  [ "$DB" = pg ] && echo "  pg_locks not granted while held: $(psqlq 'select count(*) from pg_locks where not granted')"
  touch "$flag"; wait $pid
  echo "  the first, released: $(cat $J/ra1.code) · $(hdr $J/ra1.h)"
  echo "  the retry after it$( [ -n "$P2" ] && echo " (on the second JVM)"): $(r $J/ra4 POST "$(B ${P2:-$P})/api/v1/customers/Priya/pauses?days=1" -H "$(keyh o-1)") · vs the first: $(cmpans $J/ra1 $J/ra4) · $(pauses $P)"
  since $L $m 'KEY |U04HOLD'; }

c_tx() { local P=$1 m flag=$U/$J/flag-tx-$DB p1 p2 seen=no i=0; rm -f "$flag"; echo "== $DB: a duplicate sent between the stored answer's UPDATE and the commit (a planted hold in beforeCommit)"
  m=$(mark $L)
  bgr $J/tx1 -X POST -H "$(keyh bc-1)" -H "X-Probe-Hold-File: $flag" -H 'X-Probe-Hold-Where: before-commit' "$(B $P)/api/v1/customers/Ravi/pauses?days=1"; p1=$LASTPID
  wlf $L 'U04HOLD Pauses.add (key "bc-1") before the commit' || die "the hold's line did not appear"
  bgr $J/tx2 -X POST -H "$(keyh bc-1)" "$(B $P)/api/v1/customers/Ravi/pauses?days=1"; p2=$LASTPID
  while [ $i -lt 400 ]; do
    if [ "$DB" = pg ]; then [ "$(psqlq 'select count(*) from pg_locks where not granted')" != 0 ] && { seen="yes: pg_locks not granted 1 or more (the duplicate's UPDATE waits on the claim's row)"; break; }
    else kill -0 $p2 2> /dev/null || { seen="the duplicate answered while the first was held"; break; }; fi
    i=$((i + 1)); sleep 0.05; done
  touch "$flag"; wait $p1 $p2
  echo "  the duplicate seen: $seen"
  echo "  the first: $(cat $J/tx1.code) · the duplicate: $(cat $J/tx2.code) · $( [ "$(cat $J/tx2.code)" = 201 ] && cmpans $J/tx1 $J/tx2 || prob $J/tx2.b)"
  since $L $m 'KEY |U04HOLD'; }

# slow LABEL PA PB KEY [LABB]: A held after its write past phase 2's limit and the reclaim age; B (same key, same bytes) polls until it
# reclaims; A released after B's answer. The 409s are counted; a time is never printed.
slow() { local lab=$1 pa=$2 pb=$3 k=$4 labb=${5:-} o=$J/sl-$4 flag=$U/$J/flag-sl-$4 m mb=0 before n=0 c pida i=0; rm -f "$flag"; m=$(mark $lab); [ -n "$labb" ] && mb=$(mark $labb)
  before=$(pauses $pa)
  bgr $o.A -X POST -H "$(keyh $k)" -H "X-Probe-Hold-File: $flag" -H 'X-Probe-Hold-Where: after-write' "$(B $pa)/api/v1/customers/Meera/pauses?days=2"; pida=$LASTPID
  wlf $lab "U04HOLD Pauses.add (key \"$k\") after the write" || die "A's hold line did not appear"
  while :; do c=$($CURL --http1.1 -sS -D $o.B.h -o $o.B.b -w '%{http_code}' --max-time 20 -X POST -H "$(keyh $k)" "$(B $pb)/api/v1/customers/Meera/pauses?days=2")
    if [ "$c" = 409 ]; then n=$((n + 1)); [ $n = 1 ] && cp $o.B.b $o.B409.b; i=$((i + 1)); [ $i -lt 400 ] || break; sleep 0.1; else break; fi; done
  echo "    B (the retry, on $pb): 409 answers $n [$( [ -f $o.B409.b ] && prob $o.B409.b)] then $c · $(hdr $o.B.h)"
  echo "$n" > $o.n
  touch "$flag"; wait $pida
  echo "    A (the slow original, on $pa, released after B's answer): $(cat $o.A.code) · $(hdr $o.A.h) · $(prob $o.A.b)"
  echo "    pauses (the second client): $before -> $(pauses $pa) · key row: $(keyrow $pa $k)"
  echo "    C (one more retry): $(r $o.C POST "$(B $pb)/api/v1/customers/Meera/pauses?days=2" -H "$(keyh $k)" | sed 's/^POST [^ ]* -> //') · vs B's answer: $(cmpans $o.B $o.C) · pauses $(pauses $pa)"
  since $lab $m 'KEY |U04HOLD' | $G -v 'KEY IN-FLIGHT' | sed 's/^/  /'
  echo "      (KEY IN-FLIGHT lines: $(sed -n "$(( m + 1 )),\$p" .harness/run/$lab/jvm.log | $G -c 'KEY IN-FLIGHT' ) on $lab$( [ -n "$labb" ] && echo ", $(sed -n "$(( mb + 1 )),\$p" .harness/run/$labb/jvm.log | $G -c 'KEY IN-FLIGHT') on $labb"))"
  [ -n "$labb" ] && since $labb $mb 'KEY |U04HOLD' | $G -v 'KEY IN-FLIGHT' | sed 's/^/  (JVM B) /'; true; }

c_order() { local P=$1 mode m w; for mode in nokey key; do m=$(mark $L); $CURL -s -o /dev/null "$(B $P)/customers"
    if [ $mode = key ]; then w=$(r $J/ord-$mode POST "$(B $P)/customers" -H 'Content-Type: application/json' -H "$(keyh ord-$L)" --data-binary "$(cust Ord$mode$L)")
    else w=$(r $J/ord-$mode POST "$(B $P)/customers" -H 'Content-Type: application/json' --data-binary "$(cust Ord$mode$L)"); fi
    echo "== $DB ($L$( [ "$L" = X ] && echo ', tiffinbox.cache.transaction-aware=false')): POST /customers $mode: ${w#* -> } · then customers $(ck $P) · the next GET lists it: $($CURL -s "$(B $P)/customers" | $G -c "Ord$mode$L")"
    since $L $m 'U08ORDER|KEY COMMIT'; done; }

c_window_i() { local P=$1; echo "== $DB: the cache right after the Started line, before any request; one health check; then GET /customers"
  echo "  customers $(ck $P) (the harness's /probe/u04/cache)"
  local m; m=$(mark $L)
  echo "  $(r $J/h1 GET "$(B $P)/actuator/health") · $(cut -c1-60 $J/h1.b) · customers $(ck $P) · $(reqline $L $m 'GET /actuator/health' | $G -oE 'statements [0-9]+ \(writes [0-9]+')"
  m=$(mark $L)
  echo "  $(r $J/h2 GET "$(B $P)/customers") · $(reqline $L $m 'GET /customers' | $G -oE 'statements [0-9]+ \(writes [0-9]+')"; }

c_window_ii() { local P=$1 v nm flag pid m; for v in warm cold; do flag=$U/$J/flag-w-$v-$L; rm -f "$flag"; nm=Win$v$L
    [ "$L" = X ] && [ $v = cold ] && continue
    if [ $v = warm ]; then $CURL -s -o /dev/null "$(B $P)/customers"; else $CURL -s -o /dev/null -X POST "$(B $P)/probe/u04/cache/clear"; fi
    echo "== $DB ($L$( [ "$L" = X ] && echo ', proxy off')) $v: before the keyed POST, customers $(ck $P)"
    bgr $J/w-$v -X POST -H 'Content-Type: application/json' -H "$(keyh w-$v-$L)" -H "X-Probe-Hold-File: $flag" -H 'X-Probe-Hold-Where: after-write' --data-binary "$(cust $nm)" "$(B $P)/customers"; pid=$LASTPID
    wlf $L "U04HOLD CustomerRepository.add (key \"w-$v-$L\") after the write" || die "the window's hold line did not appear"
    m=$(mark $L)
    echo "  inside the window (held after the write, before the commit): $(r $J/w-$v-in GET "$(B $P)/customers" | sed 's/^GET [^ ]* -> //') · $nm listed $($G -c "$nm" $J/w-$v-in.b) · customers $(ck $P) · $(reqline $L $m 'GET /customers' | $G -oE 'statements [0-9]+ \(writes [0-9]+')"
    touch "$flag"; wait $pid; m=$(mark $L)
    echo "  the POST $(cat $J/w-$v.code) · after the commit: customers $(ck $P) · $(r $J/w-$v-af GET "$(B $P)/customers" | sed 's/^GET [^ ]* -> //') · $nm listed $($G -c "$nm" $J/w-$v-af.b) · $(reqline $L $m 'GET /customers' | $G -oE 'statements [0-9]+ \(writes [0-9]+')"
  done
  echo "  the configured time to live, read back: $($CURL -s "$(B $P)/probe/u04/cache" | python3 -I -B harness/chk04.py ttl)"; }

c_types() { local P=$1 c label val f; echo "== $DB: every answer the filter writes, parsed as JSON (json.loads)"
  echo "  missing: $(prob $J/k0.b)"; echo "  reused: $(prob $J/mm.b)"; echo "  outstanding: $(prob $J/ra2.b)"
  for c in 'escaped quote|"ab\"cd"' 'two field lines|' 'a parameter|"k1";x=1' 'a Token, not a String|k1' 'an empty String|""' "256 characters|\"$(printf 'k%.0s' $(seq 256))\"" "255 characters (accepted)|\"$(printf 'm%.0s' $(seq 255))\""; do
    label=${c%%|*}; val=${c#*|}; f=$J/fmt-$(echo "$label" | tr -cd 'a-z0-9')
    if [ "$label" = "two field lines" ]; then r $f POST "$(B $P)/api/v1/customers/Priya/pauses?days=1" -H 'Idempotency-Key: "k2a"' -H 'Idempotency-Key: "k2b"' > /dev/null
    else r $f POST "$(B $P)/api/v1/customers/Priya/pauses?days=1" -H "Idempotency-Key: $val" > /dev/null; fi
    echo "  $label: $(head -1 $f.h | tr -d '\r' | cut -d' ' -f2) · $( [ "$label" = '255 characters (accepted)' ] && echo "$(hdr $f.h | sed 's/^HTTP[^ ]* [0-9]* *//')" || prob $f.b) · the key echoed in the body: $($G -c 'k1\|ab\|kkkkkkkk\|k2a' $f.b)"
  done
  echo "  the two 409s side by side:"
  echo "    the route's own (a taken name, a fresh key): $(r $J/n409 POST "$(B $P)/customers" -H 'Content-Type: application/json' -H "$(keyh n-1)" --data-binary "$(cust Ravi)" | sed 's/^POST [^ ]* -> //') · $(cat $J/n409.b) · key row n-1: $(keyrow $P n-1)"
  echo "    the filter's (a request outstanding): $(cat $J/ra2.b)"; }

c_limits() { local P=$1; echo "== $DB: a 70,000-byte JSON body with a key; prometheus after the replays; V5's body column"
  python3 -I -c 'import sys; sys.stdout.write("{\"name\":\"Big\",\"note\":\"" + "x"*70000 + "\"}")' > $J/big.json
  echo "  $(r $J/big POST "$(B $P)/customers" -H 'Content-Type: application/json' -H "$(keyh big-1)" --data-binary "@$J/big.json") · $(prob $J/big.b) · key row big-1: $(keyrow $P big-1)"
  $CURL -s "$(B $P)/actuator/prometheus" | $G -E '^http_server_requests_seconds_count\{.*uri="/api/v1/customers/\{name\}/pauses' | sed -E 's/,(error|exception|outcome)="[^"]*"//g; s/ [0-9.E]+$/ &/' | sort | sed 's/^/  /'
  if [ "$DB" = pg ]; then echo "  idempotency_key.body: $(psqlq "select data_type from information_schema.columns where table_name = 'idempotency_key' and column_name = 'body'") (psql)"
  else echo "  idempotency_key.body: $($CURL -s "$(B $P)/probe/coltype/idempotency_key/body") (the harness's /probe/coltype)"; fi; }

c_map() { local P=20932 i; echo "== pg: the harness's in-JVM map (the loser) on its unkeyed route POST /probe/pauses/Sunil?days=2, key m-1"
  for i in 1 2; do echo "  JVM $i, try 1: $(r $J/mp$i-1 POST "$(B $P)/probe/pauses/Sunil?days=2" -H "$(keyh m-1)" | sed 's/^POST [^ ]* -> //') · $(pauses $P)"
    echo "  JVM $i, try 2: $(r $J/mp$i-2 POST "$(B $P)/probe/pauses/Sunil?days=2" -H "$(keyh m-1)" | sed 's/^POST [^ ]* -> //') · $(pauses $P)"
    since MAP$i 0 'MAPKEY'
    if [ $i = 1 ]; then tbstop MAP1 $P; echo "  JVM 1 stopped; PostgreSQL keeps its rows (no fresh database): $(pauses $P)"; SRCX=,probe.u04.MapKeys tb MAP2 $P pg "$U/.harness/hc"; fi; done
  echo "  H2: not run - an in-memory H2 dies with its JVM (PostgreSQL only)"; }

kpoll() { local lab=$1 port=$2 k=$3 o=$4 max=$5 n=0 c i=0
  while :; do c=$($CURL --http1.1 -sS -D $o.h -o $o.b -w '%{http_code}' --max-time 20 -X POST -H "$(keyh $k)" "$(B $port)/api/v1/customers/Meera/pauses?days=2")
    if [ "$c" = 409 ]; then n=$((n + 1)); i=$((i + 1)); [ $i -lt $max ] || break; sleep 0.25; else break; fi; done
  echo "$n $c"; }
c_kill() { local port=$1 age=$2 kurl="" lab before flag=$U/$J/flag-k-$DB pid kpid res; rm -f "$flag"
  echo "== $DB: kill -9 inside phase 2, then a restart and retries ($TVL; for this pair the reclaim age is a longer <test value>)"
  [ "$DB" = h2 ] && { rm -rf $J/h2kill; mkdir -p $J/h2kill; kurl="jdbc:h2:file:../../work/h2kill/tb;FILE_LOCK=NO;WRITE_DELAY=0"; echo "  H2 on a file, the harness's (an in-memory H2 dies with its JVM): FILE_LOCK=NO, one JVM at a time, WRITE_DELAY=0"; }
  [ "$DB" = pg ] && pgfresh
  H2URL=$kurl tb K1 $port $DB "$U/.harness/hc" --logging.level.tiffinbox.idempotency=debug --tiffinbox.idempotency.phase2-timeout=2s --tiffinbox.idempotency.reclaim-after=${age}s
  before=$(pauses $port)
  bgr $J/k1 -X POST -H "$(keyh k-$DB)" -H "X-Probe-Hold-File: $flag" -H 'X-Probe-Hold-Where: after-write' "$(B $port)/api/v1/customers/Meera/pauses?days=2"; pid=$LASTPID
  wlf K1 "U04HOLD Pauses.add (key \"k-$DB\") after the write" || die "K1's hold line did not appear"
  echo "  K1 holds inside phase 2 (the claim committed, the pause written, nothing committed): $before · key row: $(keyrow $port k-$DB)"
  kpid=$(cat .harness/run/K1/pid); kill -9 "$kpid"; wait "$pid"; wait "$kpid" 2> /dev/null; PIDS=$(echo " $PIDS " | sed "s/ $kpid / /g")
  echo "  kill -9 K1 (its own pid): the client's answer $(cat $J/k1.code) (curl: $(sed -E 's/^curl: \([0-9]+\) //' $J/k1.err | head -1)) · listeners on $port: $(listeners $port)"
  [ "$DB" = pg ] && echo "  PostgreSQL after the kill: key row $(keyrow $port k-$DB) · $(pauses $port) · sessions idle in transaction $(psqlq "select count(*) from pg_stat_activity where state like 'idle in transaction%'")"
  if [ "$DB" = pg ]; then
    tb K2plant $port pg "$U/.harness/pc-noreclaim:$U/.harness/hc" --logging.level.tiffinbox.idempotency=debug --tiffinbox.idempotency.phase2-timeout=2s --tiffinbox.idempotency.reclaim-after=${age}s
    res=$(kpoll K2plant $port k-$DB $J/kp $(( age * 4 + 40 )))
    echo "  K2plant (plant-noreclaim: AND 1 = 0 in the takeover), retried past the age: 409 answers ${res% *} then ${res#* } - the stuck key"
    echo "${res% *}" > $J/kp.n
    tbstop K2plant $port
  fi
  H2URL=$kurl tb K3 $port $DB "$U/.harness/hc" --logging.level.tiffinbox.idempotency=debug --tiffinbox.idempotency.phase2-timeout=2s --tiffinbox.idempotency.reclaim-after=${age}s
  echo "  K3 up (the shipped filter): key row $(keyrow $port k-$DB) · $(pauses $port)"
  res=$(kpoll K3 $port k-$DB $J/k3 $(( age * 4 + 40 ))); echo "${res% *}" > $J/k3.n
  echo "  K3 retries: 409 answers ${res% *} then ${res#* } · $(hdr $J/k3.h) · $(pauses $port) · key row $(keyrow $port k-$DB)"
  echo "  one more retry: $(r $J/k4 POST "$(B $port)/api/v1/customers/Meera/pauses?days=2" -H "$(keyh k-$DB)" | sed 's/^POST [^ ]* -> //') · vs the reclaimed answer: $(cmpans $J/k3 $J/k4) · $(pauses $port) (before the kill: $before)"
  since K3 0 'KEY (RECLAIMED|CLAIMED|COMMIT|REPLAY)' | sed 's/^/  (K3) /'
  tbstop K3 $port
  [ "$DB" = h2 ] && { rm -rf $J/h2kill; echo "  the H2 file removed; *.mv.db outside .harness: $(find . ../c9-tiffinbox -name '*.mv.db' -not -path './.harness/*' | wc -l | tr -d ' ')"; }; true; }

# inert: the seven and the old surface, no Idempotency-Key, one JVM per request set (R.97), health-polled as the boundary's were
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
inert1() { local side=$1 tree=$2 port=$3 hcx=${4:-}; shift 4 2> /dev/null || shift $#
  local a=""; [ "$side" = after-off ] && a=--tiffinbox.cache.transaction-aware=false
  [ "$side" = after-etag ] && SRCX="" 
  HEALTHUP=1 TREE=$tree tb seven-$side $port h2 "$hcx" $a
  [ "$side" = before ] || [ "$side" = after ] && echo "  TRACE / on $side (Tomcat's own answer): $(r $J/tr-$side TRACE "$(B $port)/" | sed 's/^TRACE [^ ]* -> //') · body $(cat $J/tr-$side.b)"
  sh $CURLSET $port .harness/run/seven-$side/secrets/tiffinbox/shutdown-token > $J/seven-$side.txt 2>&1
  local i=0; while kill -0 "$(cat .harness/run/seven-$side/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 400 ] || die "seven-$side: the seven's POST /shutdown did not stop it"; sleep 0.05; done
  tbstop seven-$side $port
  HEALTHUP=1 TREE=$tree tb surface-$side $port h2 "$hcx" $a
  oldsurface2 $port $J/surface-$side.txt
  tbstop surface-$side $port
  echo "  $side: the seven $(md5 -q $J/seven-$side.txt) ($(wc -l < $J/seven-$side.txt | tr -d ' ') lines) · the old surface $(md5 -q $J/surface-$side.txt) ($($G -c '^== ' $J/surface-$side.txt) requests, $(wc -l < $J/surface-$side.txt | tr -d ' ') lines)"; }
c_inert() {
  echo "== the seven and the old surface (no Idempotency-Key), each set in its own JVM, H2: the expected seven $S466 (../c7-unit31/receipts.sh), the old surface by count $SURF (the boundary's B8)"
  inert1 before before 20936 ""; inert1 mid mid 20937 ""; inert1 after after 20930 ""; inert1 after-off after 20930 ""
  echo "  the proxy's own pair (after/ on and off): the seven $(cmp -s $J/seven-after.txt $J/seven-after-off.txt && echo equal || echo DIFFER) · the old surface $(cmp -s $J/surface-after.txt $J/surface-after-off.txt && echo equal || echo DIFFER)"
  echo "  before/ -> mid -> after/: the seven $(cmp -s $J/seven-before.txt $J/seven-mid.txt && cmp -s $J/seven-mid.txt $J/seven-after.txt && echo equal || echo DIFFER) · the old surface $(cmp -s $J/surface-before.txt $J/surface-mid.txt && cmp -s $J/surface-mid.txt $J/surface-after.txt && echo equal || echo DIFFER)"
  diff $J/surface-before.txt $J/surface-after.txt | sed 's/^/    moved: /'
  echo "== the self-test (S9.14): a planted ShallowEtagHeaderFilter on /* (the harness's probe.Etag), after/"
  SRCX=,probe.Etag inert1e; }
inert1e() { HEALTHUP=1 tb seven-etag 20930 h2 "$U/.harness/hc"
  sh $CURLSET 20930 .harness/run/seven-etag/secrets/tiffinbox/shutdown-token > $J/seven-etag.txt 2>&1
  local i=0; while kill -0 "$(cat .harness/run/seven-etag/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 400 ] || die "seven-etag did not stop"; sleep 0.05; done; tbstop seven-etag 20930
  HEALTHUP=1 tb surface-etag 20930 h2 "$U/.harness/hc"; oldsurface2 20930 $J/surface-etag.txt; tbstop surface-etag 20930
  echo "  planted: the seven $(md5 -q $J/seven-etag.txt) (unchanged: $(cmp -s $J/seven-etag.txt $J/seven-after.txt && echo yes || echo NO)) · the old surface $(md5 -q $J/surface-etag.txt) (moved: $(cmp -s $J/surface-etag.txt $J/surface-after.txt && echo NO || echo yes); the boundary's plant $SURFP) · the feed's line: $($G '^== GET /customers/feed' $J/surface-etag.txt | sed -E 's/^== //')"; }

c_exercise() { local v sh f o d
  for v in broken solved wrong; do
    for sh in bash zsh; do
      [ $v = wrong ] && [ $sh = zsh ] && continue
      d=$J/ex-$v-$sh; rm -rf $d; mkdir -p $d/exercise; cp exercise/send.sh exercise/check.sh $d/exercise/
      case $v in broken) block exercise/README.md > $d/block.sh ;;
                 solved) block exercise/SOLUTION.md > $d/block.sh ;;
                 wrong) block exercise/SOLUTION.md | XO="sed 's/^KEY2=\$(uuidgen)\$/KEY2=\$KEY1/' exercise/send.sh" XN="sed -e 's/^KEY2=\$(uuidgen)\$/KEY2=\$KEY1/' -e 's/^DAYS2=2\$/DAYS2=3/' exercise/send.sh" python3 -I -c 'import os, sys; t = sys.stdin.read(); assert t.count(os.environ["XO"]) == 1; sys.stdout.write(t.replace(os.environ["XO"], os.environ["XN"]))' > $d/block.sh ;; esac
      [ $v = wrong ] && { [ "$(diff <(block exercise/SOLUTION.md) $d/block.sh | $G -c '^[<>]')" = 2 ] || die "the wrong \"solution\" must be SOLUTION.md's block with one line changed"; }
      TREE=after tb ex-$v-$sh 20938 h2 ""
      if [ $sh = bash ]; then o=$(cd $d && env -i PATH="$XPATH" HOME="$U/.harness/home" bash block.sh 2>&1); else o=$(cd $d && env -i PATH="$XPATH" HOME="$U/.harness/home" /bin/zsh -f block.sh 2>&1); fi
      echo "== the exercise, $v, $sh (env -i, from the exercise's folder):"; printf '%s\n' "$o" | sed -E 's#/pauses/[0-9]+#/pauses/<id>#g' | sed 's/^/  /'
      tbstop ex-$v-$sh 20938
    done
  done
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures${DEVCAPS:+ (DEVELOPMENT: only $DEVCAPS - not a run of record)}"
cap tests c_tests
cap bill c_bill
cap inert c_inert
# H2: JVM M (after/ + the harness, the shipped defaults); the fence's JVMs carry the receipt's test values
DB=h2; L=M
tb M 20930 h2 "$U/.harness/hc" $TD
cap window c_window_i 20930
cap twice c_twice 20930
cap pause c_pause 20930
cap key c_key 20930
cap mismatch c_mismatch 20930
cap error c_error 20930
cap race c_race 20930
cap tx c_tx 20930
cap types c_types 20930
cap order c_order 20930
cap windowii c_window_ii 20930
cap limits c_limits 20930
tbstop M 20930
L=X; tb X 20930 h2 "$U/.harness/hc" $TD --tiffinbox.cache.transaction-aware=false
cap orderoff c_order 20930
cap windowoff c_window_ii 20930
tbstop X 20930
echo "  the fence's JVMs below carry $TVL"
L=F; tb F 20930 h2 "$U/.harness/hc" $TV
cap fence slow F 20930 20930 s-h2
tbstop F 20930
for p in nofence nolimit; do L=P$p; tb P$p 20930 h2 "$U/.harness/pc-$p:$U/.harness/hc" $TV
  cap plant$p slow P$p 20930 20930 p$p-h2; tbstop P$p 20930; done
DB=h2; cap killh2 c_kill 20930 60
# PostgreSQL: c9u04-pg, JVM MP and the second JVM M2 (R.408), a fresh database for each pair
pgup
DB=pg; L=MP
tb MP 20932 pg "$U/.harness/hc" $TD
tb M2 20935 pg "$U/.harness/hc" $TD
cap windowpg c_window_i 20932
cap twicepg c_twice 20932
cap pausepg c_pause 20932
cap keypg c_key 20932
cap mismatchpg c_mismatch 20932
cap errorpg c_error 20932
cap racepg c_race 20932 20935
cap txpg c_tx 20932
cap typespg c_types 20932
cap orderpg c_order 20932
cap windowiipg c_window_ii 20932
cap limitspg c_limits 20932
tbstop M2 20935; tbstop MP 20932
pgfresh; L=FP
tb FP 20932 pg "$U/.harness/hc" $TV
tb F2 20935 pg "$U/.harness/hc" $TV
cap fencepg slow FP 20932 20935 s2-pg F2
tbstop F2 20935; tbstop FP 20932
pgfresh; SRCX=,probe.u04.MapKeys tb MAP1 20932 pg "$U/.harness/hc"
cap map c_map
tbstop MAP2 20932
DB=pg; cap killpg c_kill 20932 45
dk rm -fv $CN > /dev/null 2>&1 || die "$CN could not be removed"
cap exercise c_exercise

# ---- the end: the sweep, the values, the published hashes -------------------------------------------------------------------------------
[ -z "$(echo $PIDS)" ] || die "a JVM of this run is still running: $PIDS"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
[ -z "$(dk ps -aq --filter label=org.testcontainers=true)" ] && [ -z "$(dk ps -aq --filter name=^/$CN\$)" ] || die "a container of this run is left"
NI1=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI1" = "$NI0" ] && [ "$VOL1" = "$VOL0" ] || die "R.322: images $NI0 -> $NI1, volumes $VOL0 -> $VOL1"
AD1=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true); [ "$AD1" = "$AD" ] || die "the anchor moved during the run"
pin before-tree before; pin after-tree after
VO=$(python3 -I -B harness/chk04.py values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; die "README.md's values block is not this run's (harness/chk04.py values)"; }
echo "  sweep: no JVM of this run, ports free, no container left, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1 · the anchor against after/ as at the start · the values block = this run's"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit04: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit04: every capture = published ($NCAPS) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"
