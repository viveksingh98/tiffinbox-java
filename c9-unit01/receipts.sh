#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 01 "What REST Actually Says" - this unit's receipts. NO anchor change: before/ and after/ are both links to
# ../c9-unit04/after (U04's frozen anchor - Spring Boot 4.1.3, Framework 7.0.11, Tomcat 11.0.29, the key filter present and inert
# without its header), pinned by harness/tree01.py against ../c9-unit04/receipts.md5's after-tree line (Course 8 U23's two-link form).
# The measured tree is a copy of after/ under .harness/, built offline (mvn -o clean package -DskipTests -pl tiffinbox-web -am) from a
# cp -c copy of the seed; nothing is built in place, no test is run (U04's 18 + 10 and 28 + 14 are cited, not re-run).
# The harness (harness/src/probe/*, joined by --spring.main.sources, never in the jar): the statement witness (Witness, datasource-proxy
# 1.11.1) and the request witness (Http, PROBE-REQ lines, ERROR dispatches too) - copied from U04's harness byte for byte, md5-asserted -
# the ShallowEtag plant (Etag, U04's too) and U01's two read-only routes (probe.u01.U01Probe: the cache's keys, the key table's rows).
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5):
#   mappings   the flag run (mappings exposed, never shipped): the handler methods, the hook's count by two derivations
#   censuspg   every route once on PostgreSQL 18.6 (first) · census  the same on H2 (the default run) - each with the stateless pair
#   stateless  Set-Cookie per route + the failure receipt, read off both census captures · cache  lifetimes and validators per route,
#              the stylesheet's three headers and its two conditional requests · links  links and forms per representation
#   seven      c5-unit11's comparison set on after/ · surface  the old surface, its feed read by a count condition (+ the S9.14 plant)
#   exercise   exercise/README.md's block, SOLUTION.md's, and two refused "solutions", under bash and zsh -f
# Ports (Course 9's U01 band, 20900-20909): 20900 TiffinBox after/ on H2 (census, seven, surface) · 20901 PostgreSQL c9u01-pg · 20902
# TiffinBox after/ on PostgreSQL · 20903-20904 asserted free · 20905 the flag run · 20906 never bound (before/ and after/ are one tree:
# no before/ JVM) · 20907 asserted free (no browser: pages are read as bytes) · 20908 the exercise · 20909 never bound. Course 8's
# 20578 / 20615, U04's 21280-21284 and 18881-18884 are never bound. Every server on 127.0.0.1; every curl --noproxy '*'.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
SETUP=80f7839
SEED=${SEED:-"/Users/$ME/Downloads/Youtube Content/LearnProgrammingWithVivek/rest-apis-done-right/_research/m2-seed-c9-u04"}   # the course's seed (B5b)
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c9u01-pg
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
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git od /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit01 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"

# ---- gates before anything is built: the folder, the links, the pins, the static check, the prose, the exercise ------------------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk01.py dur9.py s901.py src tree01.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
[ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe/Etag.java probe/Http.java probe/Witness.java probe/u01/U01Probe.java' ] || die "harness/src holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md check.sh post.sh' ] || die "exercise/ holds another file, or misses one"
for t in before after; do
  [ -L "$t" ] || die "$t is not a link - unit 01 measures ../c9-unit04/after through a link, never a copy"
  [ "$(readlink "$t")" = ../c9-unit04/after ] || die "$t's link text is \"$(readlink "$t")\", not ../c9-unit04/after"
  [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/ - never built in place"; true; done
echo "  before -> $(readlink before) · after -> $(readlink after) (links, the text exact; no secrets/, target/ or .m2-demo/ behind them)"
$G -v '^ *#' harness/src/probe/*.java harness/src/probe/u01/*.java | $G -q 'Thread\.sleep' && die "R.412: a Thread.sleep in harness/src"
for f in Witness Http Etag; do [ "$(md5 -q harness/src/probe/$f.java)" = "$(md5 -q ../c9-unit04/harness/src/probe/$f.java)" ] || die "harness/src/probe/$f.java is not U04's byte for byte"; done
echo "  harness/src/probe/{Witness,Http,Etag}.java = ../c9-unit04/harness/src/probe's (md5 $(md5 -q harness/src/probe/Witness.java | cut -c1-8) $(md5 -q harness/src/probe/Http.java | cut -c1-8) $(md5 -q harness/src/probe/Etag.java | cut -c1-8)) - copied from U04's harness"
[ "$(sed -n '5,$p' harness/tree01.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit04/harness/tree04.py | md5 -q)" ] || die "harness/tree01.py's code is not tree04.py's"
[ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit04/harness/dur9.py)" ] || die "harness/dur9.py is not U04's copy (dur9 as shipped)"
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"; else D9N="(the registry is not on this machine: U04's copy is the pin)"; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit04/harness/dur9.py $D9N · tree01.py's code = tree04.py's"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit04/receipts.md5)
[ -n "$UA" ] || die "../c9-unit04/receipts.md5 has no after-tree line"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree01.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line"
  [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit04/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree01.py $dir/ -> $got = receipts.md5's $nm line = ../c9-unit04/receipts.md5's after-tree line"; }
anchortree() { pin before-tree before; pin after-tree after
  local AD; AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after/ ../c9-tiffinbox 2>&1 || true)
  [ -z "$AD" ] || die "the anchor ../c9-tiffinbox is not ../c9-unit04/after (diff -rq: $(printf '%s\n' "$AD" | head -2 | paste -sd';' -))"
  echo "  ../c9-tiffinbox against ../c9-unit04/after (diff -rq, .m2-demo target secrets .harness left out): empty"; }
anchortree
HF="harness/chk01.py harness/s901.py harness/tree01.py harness/dur9.py harness/src/probe/Witness.java harness/src/probe/Http.java harness/src/probe/Etag.java harness/src/probe/u01/U01Probe.java exercise/post.sh exercise/check.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's scripts: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
git rev-parse -q --verify "$SETUP^{commit}" > /dev/null 2>&1 || die "the set-up commit $SETUP is not in this repository's history"
# the set-up filter: the classes that hold a handler method at the set-up commit, found by their mapping annotations, never typed
SETC=$(cd .. && git grep -lE '^ +@(Get|Post|Put|Delete|Patch|Request)Mapping[(]' "$SETUP" -- c9-tiffinbox/tiffinbox-web/src/main/java 2> /dev/null | sed -E 's#^[0-9a-f]+:##' | while read -r f; do
  n=$(git show "$SETUP:$f" | $G -cE '^ +@(Get|Post|Put|Delete|Patch|Request)Mapping[(]'); p=$(git show "$SETUP:$f" | $G -c '@Profile("dev")'); c=$(basename "$f" .java); echo "$c:$n:$p"; done | sort | paste -sd' ' -)
[ -n "$SETC" ] || die "the set-up commit's handler classes could not be read"
echo "  the set-up commit $SETUP's classes with a mapping annotation (git grep; class:methods:dev): $SETC"
ST=$(python3 -I -B harness/chk01.py static "$SETC") || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s901.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U01 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s901, per sentence): /'
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
G1="A constraint: a rule an architecture style puts on how parts may talk."
G2="A representation: the bytes a resource is sent as."
for g in "$G1" "$G2"; do [ "$($G -cxF -- "$g" README.md)" = 1 ] || die "the gloss (SECTION SHAPE 01) must stand in README.md once, as a line of its own, byte for byte: $g"; done
HOOK="TiffinBox came into this course with twelve routes. Exactly one answer says how long it may be kept, and it's the stylesheet."
[ "$(printf '%s\n' "$HOOK" | wc -w | tr -d ' ')" = 22 ] || die "the hook is not 22 words"
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S1B's dated note), byte for byte"
EXQ="Your turn: post the form with curl and make the dashboard show the note. The session cookie is all it needs."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
[ "$EXW" = 21 ] || die "the exercise's spoken line is $EXW words, the brief's (RED-C9-S1 #37) is 21"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SP=$(python3 -I -B harness/chk01.py spoken "$HOOK" "$EXQ") || die "the spoken lines: $(printf '%s\n' "$SP" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$SP" | $G -v '^VALUES ' | sed 's/^/  /'
printf '%s\n\n%s\n' "$HOOK" "$EXQ" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s901.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
printf '%s\n' "$SW" | tail -1 | $G -qE ' refused: 0$' || die "a refused reading in a spoken line: $(printf '%s\n' "$SW" | $G ' line ' | head -3 | paste -sd';' -)"
echo "  the two spoken lines through s901.py (every family, dur9 inside it): refused 0"; rm -f .r-lock/spoken.md
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
SETX=$(block exercise/README.md); SOLX=$(block exercise/SOLUTION.md)
[ -n "$SETX" ] && [ -n "$SOLX" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
[ "$(diff <(printf '%s\n' "$SETX") <(printf '%s\n' "$SOLX") | $G -c '^[<>]')" = 2 ] || die "R.196: SOLUTION.md's block must be the README's with one line changed"
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
$G -qx 'JAR=' exercise/post.sh || die "exercise/post.sh: the broken form - no cookie jar (JAR=)"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket"
DK=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -vF 'echo "' | $G -nE '(^|[ ;(])docker (run|exec|rm|ps|port|info|images|volume|image|pull|logs|inspect)\b' | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.344: receipts.sh calls docker without the pinned socket: $DK"
RMF=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) rm( +-[a-z]+)*' | sort -u | paste -sd'|' -)
[ "$RMF" = 'dk rm -fv' ] || die "R.387: receipts.sh removes a container without its volumes (found: ${RMF:-none})"
[ "$($G -v '^ *#' receipts.sh | $G -oE '(dk|docker) run -[^"]*' | $G -vcF -- '--pull never' || true)" = 0 ] || die "R.344: a dk run without --pull never"
MVA=$($G -v '^ *#' receipts.sh | $G -F '$MV ' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am"
KH=$($G -v '^ *#' receipts.sh | $G -cE "^keyh\(\) \{ printf 'Idempotency-Key" || true); KU=$($G -v '^ *#' receipts.sh | $G -vF 'KU=' | $G -oF '$(keyh ' | wc -l | tr -d ' ')
[ "$KH" = 1 ] && [ "$KU" = 1 ] || die "S9.21: the key header is written by keyh() alone ($KH) and sent once, by the labelled extra ($KU)"
echo "  the exercise: the spoken line $EXW words (wc -w); SOLUTION.md's block = the README's with one line changed; post.sh broken as shipped (no jar); the two What-it-prints blocks differ · the glosses and the hook byte for byte · placeholders 0"
echo "  static: no kill by name; every docker call on the pinned socket, every dk run --pull never, every removal rm -fv; every Maven build -pl tiffinbox-web -am; no Thread.sleep in harness/src; the key header named once (keyh, the labelled extra)"
mask() { awk -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(PE, "…"); gsub(P, "…"); gsub(QE, "…/.."); gsub(Q, "…/.."); gsub(H, "~")
    gsub(/ in [0-9.]+ seconds \(process running for [0-9.]+\)/, " in <t> (process running for <t>)")
    gsub(/[0-9]+ ms/, "<t>")
    gsub(/pid [0-9]+/, "pid <n>")
    gsub(/[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?( ?[A-Z]{3,4}|Z|[+-][0-9:]+)?/, "<time>")
    gsub(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/, "<uuid>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'took 812 ms' '"timestamp":"2026-11-24T07:12:01.123+01:00"' "$U/x $HOME/y" | mask)
[ "$(printf '%s\n' "$MP" | paste -sd'|' -)" = 'Started TiffinBoxServer in <t> (process running for <t>)|took <t>|"timestamp":"<time>"|…/x ~/y' ] || die "the mask's self-test: $(printf '%s\n' "$MP" | paste -sd'|' -)"
maskh() { tr -d '\r' < "$1" | sed -E 's/^(Date|date): .*/\1: <masked>/; s/(JSESSIONID=)[^;]*/\1<masked>/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/^(Expires): .*/\1: <masked>/'; }
MH=$(printf 'Date: Tue, 24 Nov 2026 08:00:00 GMT\r\nSet-Cookie: JSESSIONID=ABC123; Path=/; HttpOnly\r\nLocation: http://127.0.0.1:20900/dashboard\r\nExpires: Tue, 24 Nov 2027 08:00:00 GMT\r\n' > .r-lock/mh; maskh .r-lock/mh | paste -sd'|' -; rm -f .r-lock/mh)
[ "$MH" = 'Date: <masked>|Set-Cookie: JSESSIONID=<masked>; Path=/; HttpOnly|Location: http://127.0.0.1:<port>/dashboard|Expires: <masked>' ] || die "the header mask's self-test: $MH"
echo "  masks: the log mask's self-test masked a Started line's times, a millisecond count, Boot's /error timestamp, the folders and the home; the header mask's self-test masked a planted Date, session cookie value, port and Expires"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
$G -qF 'S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)' ../c8-unit27/receipts.sh || die "../c8-unit27/receipts.sh no longer reads the seven's md5 off ../c7-unit31/receipts.sh"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SEVEN=$(sed -n 's/^  after: the seven \([0-9a-f]*\) .*/\1/p' ../c9-unit04/.r-inert.out 2> /dev/null; true)
U4SURF=$(sed -n 's/^  after: the seven [0-9a-f]* ([0-9]* lines) · the old surface \([0-9a-f]*\) .*/\1/p' ../c9-unit04/.r-inert.out 2> /dev/null; true)
U4SURFR=$($G -oE "old surface by count [0-9a-f]{32}" ../c9-unit04/receipts.sh | awk '{ print $5 }' | head -1; true)
U4SURFC=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh)
[ ${#U4SURFC} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh's SURF= line"
echo "  the seven: $S466 (read off ../c7-unit31/receipts.sh's S466= line as ../c8-unit27/receipts.sh reads it)$( [ -n "$U4SEVEN" ] && echo " · U04's after/ capture (.r-inert.out): $U4SEVEN") · the old surface: $U4SURFC (../c9-unit04/receipts.sh's SURF= line)$( [ -n "$U4SURF" ] && echo " · U04's after/ capture: $U4SURF")"

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
PORTS="18881 18882 18883 18884 20578 20615 20900 20901 20902 20903 20904 20905 20906 20907 20908 20909 21280 21281 21282 21283 21284"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
for p in 20900 20901 20902 20903 20904 20905 20906 20907 20908 20909; do [ -z "$(lsof -nP -iUDP:$p 2> /dev/null)" ] || die "UDP $p is bound"; done
[ "$(pgrep -x java | wc -l | tr -d ' ')" = 0 ] || die "a java process is running before this script starts one - not this script's; stop it first"
guard() { local r; r=$(pgrep -fl "^/bin/(ba)?sh (\./|.*/)(receipts|runrec)[.]sh" 2> /dev/null | $G -v "^$$ " || true)
  local l1; l1=$(sysctl -n vm.loadavg | awk '{ print $2 }')
  [ -z "$r" ] || die "S9.17: another receipt runs ($r) before $1 - this run stops; wait for it, never kill it"
  local w=0; while ! awk -v l="$l1" 'BEGIN { exit !(l < 20) }'; do
    [ -n "${GUARD0:-}" ] || die "R.480: load1 $l1 is not below 20 at the launch - a run of record launches only below 20; launch again when it is"
    w=$((w + 1)); [ $w -lt 900 ] || die "R.480: load1 stayed at or above 20 for 900 checks before $1"; sleep 1; l1=$(sysctl -n vm.loadavg | awk '{ print $2 }'); done
  GUARD0=1
  echo "  guard before $1: no other receipt · load1 $l1 (< 20)$( [ $w = 0 ] || echo " after $w checks at or above 20 (waited, never killed)")"; }
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · $IMG present (= ../c9-unit04/receipts.sh's IMG= line) · nothing pulled, ever · no $CN · ports $PORTS free (TCP; 20900-20909 UDP too) · no java process"

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
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \"$CPA:$DSP\" harness/src/probe/*.java harness/src/probe/u01/*.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/'s jar: $(head -5 .harness/javac.log)"
echo "  the harness compiled against after/'s jar ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes, javac 25 -parameters; datasource-proxy 1.11.1 from .m2-demo, on the harness's class path only; the PostgreSQL driver is the jar's own, $PGJ)"
CSSF=.harness/after/tiffinbox-web/target/classes/static/css/tiffinbox.css
[ -f "$CSSF" ] || die "the stylesheet is not in the build's classes"
CSSMD5=$(md5 -q "$CSSF")

# ---- helpers ---------------------------------------------------------------------------------------------------------------------------
B() { echo "http://127.0.0.1:$1"; }
keyh() { printf 'Idempotency-Key: "%s"' "$1"; }
J=.harness/work
mark() { wc -l < ".harness/run/$1/jvm.log" | tr -d ' '; }
# the server's own lines for one request, after a mark: wait (a count condition, bounded) for its PROBE-REQ line, then print every
# PROBE-REQ line since the mark (an ERROR dispatch prints its own)
srv() { local lab=$1 m=$2 pat=$3 p=$4 i=0
  while ! sed -n "$(( m + 1 )),\$p" ".harness/run/$lab/jvm.log" | $G -qE "^PROBE-REQ [0-9]+ $pat"; do i=$((i + 1)); [ $i -lt 200 ] || { echo "     server: no PROBE-REQ line"; return 0; }; sleep 0.02; done
  sed -n "$(( m + 1 )),\$p" ".harness/run/$lab/jvm.log" | $G -E "^PROBE-REQ [0-9]+ $pat" | head -1 | sed -E 's/^PROBE-REQ [0-9]+ /     server: /' | cut -c1-240
  sed -n "$(( m + 1 )),\$p" ".harness/run/$lab/jvm.log" | $G -F "[dispatch ERROR, for $p]" | head -1 | sed -E 's/^PROBE-REQ [0-9]+ /     server: /' | cut -c1-240; }
HDRS='^(HTTP|Content-Type|Set-Cookie|Cache-Control|Expires|Pragma|ETag|Last-Modified|Vary|Link|Location|Allow)'
# ask LABEL METHOD PATH [curl args]: one request into its own header and body files (both reset first), its two witnesses
ask() { local lab=$1 m=$2 p=$3 o=$J/$DB-$1 w rc mk; shift 3
  : > "$o.h"; : > "$o.b"; mk=$(mark $L)
  w=$($CURL --http1.1 -sS -D "$o.h" -o "$o.b" -w '%{http_code} %{content_type} %{size_download}' --max-time 20 -X "$m" "$@" "$(B $P)$p" 2> "$o.err"); rc=$?
  [ "$p" = /actuator/prometheus ] && w=$(printf '%s' "$w" | awk '{ print $1, $2, "<n>" }')
  echo "-- $lab | $m $p -> $w (curl exit $rc)"
  maskh "$o.h" | $G -iE "$HDRS" | sed 's/^/     /'
  srv $L $mk "$m $(printf '%s' "$p" | sed 's/[?]/[?]/g')[? ]" "${p%%\?*}"
  python3 -I -B harness/chk01.py linkcount "$o.b" "$(printf '%s' "$w" | awk '{ print $2 }')" | sed 's/^/     /'
  local n; n=$(wc -c < "$o.b" | tr -d ' ')
  if [ "$p" != /actuator/prometheus ] && [ "$n" -le 360 ] && [ "$n" -gt 0 ]; then echo "     body: $(tr -d '\r' < "$o.b" | tr '\n' '~' | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g')"; fi; }
ck() { $CURL -s "$(B $P)/probe/u01/cache" | python3 -I -c 'import json,sys; print("customers " + json.load(sys.stdin)["customers"])'; }
keyrows() { if [ "$DB" = pg ]; then echo "$(psqlq "SELECT count(*) FROM idempotency_key") (psql in $CN, the second client)"; else echo "$($CURL -s "$(B $P)/probe/u01/keys" | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])') (the harness's JdbcTemplate route /probe/u01/keys, the second client)"; fi; }
psqlq() { dk exec $CN psql -U tiffinbox -d "${2:-tiffinbox}" -qAt -c "$1" 2>&1 | tr '\n' ' ' | sed 's/ *$//'; }
pgfresh() { psqlq "drop database if exists tiffinbox with (force)" postgres > /dev/null; psqlq "create database tiffinbox" postgres > /dev/null; }
pgup() { guard "the PostgreSQL container"
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:20901:5432 -e POSTGRES_DB=tiffinbox -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust $IMG" .harness/docker-run-pg.log
  [ "$RE" = 0 ] || die "the PostgreSQL container did not start: $(tail -2 .harness/docker-run-pg.log)"
  local i=0; while ! dk exec $CN pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 240 ] || die "PostgreSQL did not accept connections"; sleep 0.5; done
  [ "$(dk port $CN | paste -sd'|' -)" = '5432/tcp -> 127.0.0.1:20901' ] || die "$CN publishes on another address than 127.0.0.1:20901"
  echo "  $CN: PostgreSQL $(psqlq 'show server_version') by the digest, on 127.0.0.1:20901 alone (docker port), trust on the loopback (U04's form: no password exists to print)"; }
# tb LABEL PORT DB HCX [args]: TiffinBox (the extracted jar), from its own run folder with a generated token (a config tree, 0600, never
# printed), Tomcat's access log on (unbuffered, no time field: %m %U%q %s %b, S9.27); waited for by its Started line (never a health poll:
# the cache's cold state stays observable), or by health 200 where HEALTHUP is set (the seven and the surface, as U04's were)
tb() { local label=$1 port=$2 db=$3 hcx=$4 run=.harness/run/$1 jx="" src="" i=0; shift 4
  guard "TiffinBox $label"
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox" "$run/access"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  local x="$U/.harness/after/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  if [ -n "$hcx" ]; then cp="$cp:$hcx:$DSP"; src="--spring.main.sources=${SRC:-probe.Witness,probe.Http,probe.u01.U01Probe}"; fi
  [ "$db" = pg ] && jx="-Dtiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:20901/tiffinbox?user=tiffinbox"
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
  local o e=0; o=$(python3 -I -B harness/chk01.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk01 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  $G -v '^ok \|^FAIL ' .harness/chk-$nm.out | sed 's/^/  chk01 /' || true
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; die "$nm: its check failed (harness/chk01.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk01.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-9s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-9s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff its block in README.md against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }

# ---- the captures --------------------------------------------------------------------------------------------------------------------
c_mappings() { local m
  echo "== the flag run (20905, H2, LABELLED: never shipped): --management.endpoints.web.exposure.include=health,prometheus,mappings"
  tb flag 20905 h2 "" --management.endpoints.web.exposure.include=health,prometheus,mappings
  m=$($CURL -sS -o $J/mappings.json -w '%{http_code}' --max-time 10 "$(B 20905)/actuator/mappings")
  echo "  GET /actuator/mappings -> $m · $(wc -c < $J/mappings.json | tr -d ' ') B"
  python3 -I -B harness/chk01.py mapread $J/mappings.json "$SETC"
  tbstop flag 20905; }

# one census JVM: the cache cold, one health check, every route once, the stateless pair, the stylesheet's conditionals, U04's extras
c_census() { local css lm et nb
  echo "== $DB: TiffinBox after/ + the harness on $P; the cache right after the Started line"
  echo "  which database answered (Flyway's line): $($G -m1 -oE 'Database: [^ ]+ \([^)]*\)' .harness/run/$L/jvm.log | sed -E 's/jdbc:[a-z0-9]+:[^ ]*/<url>/')"
  echo "  $(ck) (the harness's /probe/u01/cache, before any request of the census)"
  ask health0 GET /actuator/health
  echo "  $(ck) (after one health check: the kitchen's health reads the cached findAll())"
  ask customers GET /customers
  ask veg GET '/customers?mealType=VEG'
  ask ravi GET /customers/Ravi
  ask ravi2 GET /customers/Ravi
  ask nobody GET /customers/Nobody
  ask revenue GET /revenue
  ask dashjson GET /dashboard -H 'Accept: application/json'
  ask dashhtml GET /dashboard -H 'Accept: text/html'
  ask form GET /customers/new -H 'Accept: text/html'
  ask kitchen GET /kitchen
  local mk; mk=$(mark $L); feed $J/$DB-feed "$(B $P)"
  echo "-- feed | GET /customers/feed -> $(tr -d '\r' < $J/$DB-feed.h | head -1 | cut -d' ' -f2) $(tr -d '\r' < $J/$DB-feed.h | $G -i '^Content-Type:' | cut -d' ' -f2) $(wc -c < $J/$DB-feed.b | tr -d ' ') (read by count: headers + the first event to its blank line, alarm 10 s; reader exit $FEEDRC; closed by the reader)"
  maskh $J/$DB-feed.h | $G -iE "$HDRS" | sed 's/^/     /'
  srv $L $mk 'GET /customers/feed -' /customers/feed
  echo "     body: $(tr -d '\r' < $J/$DB-feed.b | tr '\n' '~')"
  python3 -I -B harness/chk01.py linkcount $J/$DB-feed.b text/event-stream | sed 's/^/     /'
  ask nowhere GET /nowhere
  css=$($G -oE '/css/tiffinbox-[0-9a-f]+\.css' $J/$DB-dashhtml.b | head -1)
  echo "  the pages' stylesheet link: $css · the file's own md5 (md5 -q of the built static/css/tiffinbox.css): $CSSMD5"
  ask css GET "$css"
  lm=$(tr -d '\r' < $J/$DB-css.h | $G -i '^Last-Modified:' | cut -d' ' -f2-); et=$(tr -d '\r' < $J/$DB-css.h | $G -i '^ETag:' | cut -d' ' -f2-)
  ask css304 GET "$css" -H "If-Modified-Since: $lm"
  echo "     the 304's body file: $(wc -c < $J/$DB-css304.b | tr -d ' ') B (created empty before the request)"
  ask cssinm GET "$css" -H "If-None-Match: ${et:-\"none\"}"
  ask add POST /customers -H 'Content-Type: application/json' --data-binary '{"name":"Asha","mealsPerDay":1,"pricePerMeal":110,"mealType":"VEG"}'
  echo "== $DB: stateless - the same form POST with curl's cookie jar, then without it, then with it again (a fresh name each)"
  ask formjar POST /customers -c $J/$DB-jar1 -H 'Content-Type: application/x-www-form-urlencoded' --data-binary 'name=Chitra&mealsPerDay=1&pricePerMeal=100&mealType=VEG'
  echo "     the jar (the cookie's name; curl's #HttpOnly_ prefix stripped before reading): $(sed 's/^#HttpOnly_//' $J/$DB-jar1 | $G -v '^#' | awk -F '\t' 'NF >= 7 { print $6 "=<masked>" }' | paste -sd' ' -) · the raw line starts with: $($G -oE '^#HttpOnly_' $J/$DB-jar1 | head -1)"
  ask dashjar GET /dashboard -b $J/$DB-jar1 -H 'Accept: text/html'
  nb=$($G -c '<p class="note">Chitra added</p>' $J/$DB-dashjar.b || true); echo "     the note \"Chitra added\" on the page: $nb"
  ask formnojar POST /customers -H 'Content-Type: application/x-www-form-urlencoded' --data-binary 'name=Bina&mealsPerDay=1&pricePerMeal=100&mealType=VEG'
  ask dashnojar GET /dashboard -H 'Accept: text/html'
  nb=$($G -c '<p class="note">Bina added</p>' $J/$DB-dashnojar.b || true); echo "     the note \"Bina added\" on the page: $nb · any note: $($G -c '<p class="note">' $J/$DB-dashnojar.b || true)"
  ask formjar2 POST /customers -c $J/$DB-jar2 -H 'Content-Type: application/x-www-form-urlencoded' --data-binary 'name=Divya&mealsPerDay=1&pricePerMeal=100&mealType=VEG'
  ask dashjar2 GET /dashboard -b $J/$DB-jar2 -H 'Accept: text/html'
  nb=$($G -c '<p class="note">Divya added</p>' $J/$DB-dashjar2.b || true); echo "     the note \"Divya added\" on the page: $nb"
  printf 'name,mealsPerDay,pricePerMeal,mealType\nEsha,1,130,VEGAN\n' > $J/$DB-two.csv
  ask import POST /customers/import -F "file=@$J/$DB-two.csv;type=text/csv;filename=two.csv"
  ask shutdown POST /shutdown
  ask health GET /actuator/health
  ask prometheus GET /actuator/prometheus
  ask mappings GET /actuator/mappings
  echo "  key table rows before U04's extras: $(keyrows)"
  if [ -z "${NOEXTRAS:-}" ]; then
    echo "== $DB: U04's routes - LABELLED, not in the hook's twelve: the pause route without and with a key (the one place a request carries one)"
    ask pausenokey POST '/api/v1/customers/Ravi/pauses?days=2'
    ask pausekey POST '/api/v1/customers/Ravi/pauses?days=2' -H "$(keyh u01-$DB-1)"
    local loc; loc=$(tr -d '\r' < $J/$DB-pausekey.h | $G -i '^Location:' | cut -d' ' -f2- | sed -E 's#^https?://[^/]+##')
    ask pauseget GET "$loc"
  fi
  echo "  key table rows after the census: $(keyrows)"
  echo "  $(ck) (at the end)"
  echo "== $DB: Tomcat's access log (the valve, unbuffered, %m %U%q %s %b), every line so far"
  sed -E 's#^(GET /actuator/prometheus- 200) [0-9]+$#\1 <n>#; s/^/     access: /' .harness/run/$L/access/access.log
  echo "== $DB: PROBE-REQ lines in all: $($G -c '^PROBE-REQ ' .harness/run/$L/jvm.log) · access-log lines: $(wc -l < .harness/run/$L/access/access.log | tr -d ' ')"; }

c_view() { python3 -I -B harness/chk01.py view "$1" .r-censuspg.new .r-census.new .r-mappings.new; }

# the seven and the old surface (no Idempotency-Key), each in its own JVM, H2, health-polled as U04's were; then the S9.14 plant
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
  echo "== the seven (c5-unit11/curlset.sh, md5 bfa34552cb762f099b6a389386324468) on after/, H2, its own JVM, no Idempotency-Key: expected $S466 (../c7-unit31/receipts.sh; U04's after/ capture, where its .r-inert.out is on disk, compared outside this capture)"
  HEALTHUP=1 tb seven 20900 h2 ""
  sh $CURLSET 20900 .harness/run/seven/secrets/tiffinbox/shutdown-token > $J/seven.txt 2>&1
  local i=0; while kill -0 "$(cat .harness/run/seven/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 400 ] || die "the seven's POST /shutdown did not stop it"; sleep 0.05; done
  tbstop seven 20900
  sed 's/^/  /' $J/seven.txt
  echo "  the seven: $(md5 -q $J/seven.txt) ($(wc -l < $J/seven.txt | tr -d ' ') lines) · expected $S466"
  [ -z "$U4SEVEN" ] || [ "$(md5 -q $J/seven.txt)" = "$U4SEVEN" ] || die "the seven differs from U04's after/ capture ($U4SEVEN)"; }
c_surface() {
  echo "== the old surface on after/, H2, its own JVM, no Idempotency-Key, the feed read by a count condition: expected $U4SURFC (../c9-unit04/receipts.sh's SURF=, the boundary's B8)"
  HEALTHUP=1 tb surface 20900 h2 ""
  oldsurface2 20900 $J/surface.txt
  tbstop surface 20900
  sed 's/^/  /' $J/surface.txt
  echo "  the old surface: $(md5 -q $J/surface.txt) ($($G -c '^== ' $J/surface.txt) requests, $(wc -l < $J/surface.txt | tr -d ' ') lines) · expected $U4SURFC"
  [ -z "$U4SURF" ] || [ "$(md5 -q $J/surface.txt)" = "$U4SURF" ] || die "the old surface differs from U04's after/ capture ($U4SURF)"
  echo "== the self-test (S9.14, the harness's plant - LABELLED, not a finding about TiffinBox): a ShallowEtagHeaderFilter on /* (probe.Etag, U04's)"
  SRC=probe.Etag HEALTHUP=1 tb seven-etag 20900 h2 "$U/.harness/hc"
  sh $CURLSET 20900 .harness/run/seven-etag/secrets/tiffinbox/shutdown-token > $J/seven-etag.txt 2>&1
  local i=0; while kill -0 "$(cat .harness/run/seven-etag/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 400 ] || die "seven-etag did not stop"; sleep 0.05; done; tbstop seven-etag 20900
  SRC=probe.Etag HEALTHUP=1 tb surface-etag 20900 h2 "$U/.harness/hc"; oldsurface2 20900 $J/surface-etag.txt; tbstop surface-etag 20900
  echo "  planted: the seven $(md5 -q $J/seven-etag.txt) (unchanged: $(cmp -s $J/seven-etag.txt $J/seven.txt && echo yes || echo NO)) · the old surface $(md5 -q $J/surface-etag.txt) (moved: $(cmp -s $J/surface-etag.txt $J/surface.txt && echo NO || echo yes)) · the feed's line: $($G '^== GET /customers/feed' $J/surface-etag.txt | sed -E 's/^== //')"; }

c_exercise() { local v sh d o
  XREP='import os, sys; t = sys.stdin.read(); o = "sed '"'"'s/^JAR=$/JAR=jar.txt/'"'"' post.sh"; assert t.count(o) == 1; sys.stdout.write(t.replace(o, os.environ["XN"]))'
  for v in broken solved jaronly emptyjar; do
    for sh in bash zsh; do
      d=$J/ex-$v-$sh; rm -rf $d; mkdir -p $d/exercise; cp exercise/post.sh exercise/check.sh $d/exercise/
      case $v in broken) block exercise/README.md > $d/block.sh ;;
                 solved) block exercise/SOLUTION.md > $d/block.sh ;;
                 jaronly) block exercise/SOLUTION.md | XN="sed -e 's/^JAR=\$/JAR=jar.txt/' -e 's/ \${JAR:+-b \"\$JAR\"}//' post.sh" python3 -I -c "$XREP" > $d/block.sh ;;
                 emptyjar) block exercise/SOLUTION.md | XN="sed -e 's/^JAR=\$/JAR=jar.txt/' -e 's/ \${JAR:+-c \"\$JAR\"}//' -e 's/^rm -f name.txt dashboard.html jar.txt\$/&; : > jar.txt/' post.sh" python3 -I -c "$XREP" > $d/block.sh ;; esac
      case $v in jaronly|emptyjar) [ "$(diff <(block exercise/SOLUTION.md) $d/block.sh | $G -c '^[<>]')" = 2 ] || die "the refused \"solution\" $v must be SOLUTION.md's block with one line changed" ;; esac
      tb ex-$v-$sh 20908 h2 ""
      if [ $sh = bash ]; then o=$(cd $d/exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=20908 bash ../block.sh 2>&1); else o=$(cd $d/exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=20908 /bin/zsh -f ../block.sh 2>&1); fi
      echo "== the exercise, $v, $sh (env -i, from the exercise's folder, TiffinBox's jar alone on 20908, H2):"; printf '%s\n' "$o" | sed 's/^/  /'
      [ $v = jaronly ] || [ $v = emptyjar ] && echo "  (its post.sh: $(cd $d/exercise && ls post-jar.sh 2> /dev/null | head -1) · the jar: $( [ -s $d/exercise/jar.txt ] && echo "holds $(sed 's/^#HttpOnly_//' $d/exercise/jar.txt | $G -v '^#' | awk -F '\t' 'NF >= 7 { print $6 }' | paste -sd' ' -)" || echo empty))"
      tbstop ex-$v-$sh 20908
    done
  done
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures"
cap mappings c_mappings
pgup; pgfresh
DB=pg; P=20902; L=CP
tb CP 20902 pg "$U/.harness/hc"
cap censuspg c_census
tbstop CP 20902
dk rm -fv $CN > /dev/null 2>&1 || die "$CN could not be removed"
DB=h2; P=20900; L=CH
tb CH 20900 h2 "$U/.harness/hc"
cap census c_census
tbstop CH 20900
cap stateless c_view stateless
cap cache c_view cache
cap links c_view links
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
build: libs=$LIBN css_md5=$CSSMD5 seed_files=$NF0"
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
VO=$(python3 -I -B harness/chk01.py values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; die "README.md's values block is not this run's (harness/chk01.py values)"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM of this run, ports free, no container left, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1 · the anchor = ../c9-unit04/after · *.mv.db outside .harness 0 · the values block = this run's"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit01: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit01: every capture = published ($NCAPS) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"
