#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 06 "API Design Review" - this unit's receipts. Course 9's THIRD anchor change, Section 1's last unit: before is a link to
# ../c9-unit05/after (U05's after: Spring Boot 4.1.3, Tomcat 11.0.29, the key filter, U05's PATCH /api/v1/customers/{name}); after/ is a
# frozen copy of ../c9-tiffinbox after this unit's change - GET /api/v1/customers/{name} (CustomerReads, one handler method, a NEW
# package-private final class; the old GET /customers/{name}'s read through the same CustomerRepository.findByName and its customer
# cache) and its pinning test (CustomerReadsTest). Nothing else in the anchor moves but its README.
# The harness (harness/src/probe/*, joined by --spring.main.sources, never in the jar): the statement witness and the request witness
# (Witness, Http - copied from U05's harness, which copied U03's), the second client on H2 (Routes - U05's = U04's), unit 06's reads
# (probe.u06.U06Probe: both caches' keys, the key table, the rows, the pauses by customer_id, the feed's listeners), the ShallowEtag
# plant (Etag), the planted no-evict CustomerRepository (the shipped class with its update's @Caching removed by one edit, U05's form).
# Every line it prints is "the harness's".
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5), PostgreSQL first where both run:
#   tests    mvn -o verify on a copy of after/ (Surefire's and Failsafe's XML per class, the five IT BINDINGS lines), BOOT-INF/lib before -> after
#   mappings /actuator/mappings on after/ (one flag start, H2): every handler method, the partition by commit, the write routes, the dev five
#   rows     the review's rows R1-R13, each one request (or pair) on before (U05's after), PostgreSQL then H2 - the failure receipt
#   fixes    the one fix's after on after/ (PostgreSQL then H2), the old route beside it, the rename round trip on the public read, and
#            the planted no-evict copy (the detector)
#   moved    U02's method table (4 addresses x 9 methods), U05's PATCH answers and the new address, on before and after/, H2
#   inert    the seven and the old surface on before and after/ (U05's reader), and the S9.14 plant
#   exercise read.sh as shipped (broken), SOLUTION.md's line (solved), five refused "solutions", bash and zsh -f, PostgreSQL then H2
# Ports (Course 9's U06 band, 20950-20959): 20950 TiffinBox after/ on H2 · 20951 PostgreSQL c9u06-pg · 20952 TiffinBox after/ on
# PostgreSQL · 20953 the S9.14 plant · 20954 the flag start · 20955 the planted no-evict JVM · 20956 before (on both databases, one at a
# time) · 20957 asserted free · 20958 the exercise · 20959 never bound. During mvn verify only: 21280-21284, one per IT. Every store on
# 127.0.0.1; every curl --noproxy '*'. The key header is sent only by the requests labelled k- (the rows R1 and R7: KEYED below).
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
C9R=${C9R:-"/Users/$ME/Downloads/Youtube Content/LearnProgrammingWithVivek/rest-apis-done-right"}   # the course's folder (briefs, research)
SEED=${SEED:-"$C9R/_research/m2-seed-c9-u04"}   # the course's seed (B5b)
DOCS="$C9R/_research/docs-2026-11-23"
export C9R
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c9u06-pg
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
echo "c9-unit06 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"

# ---- gates before anything is built: the folder, the link, the pins, the anchor, the static check, the prose, the exercise ----------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk06.py dur9.py s906.py src tree06.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
HSRC='probe/Etag.java probe/Http.java probe/Routes.java probe/Witness.java probe/u06/U06Probe.java'
[ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$HSRC" ] || die "harness/src holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md check.sh read.sh' ] || die "exercise/ holds another file, or misses one"
[ -L before ] && [ "$(readlink before)" = ../c9-unit05/after ] || die "before must be a link whose text is exactly ../c9-unit05/after (found: $( [ -L before ] && readlink before || echo 'not a link'))"
[ -d after ] && [ ! -L after ] || die "after/ is this unit's own frozen tree, a directory, not a link"
for t in before after; do [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/ - never built in place"; true; done
echo "  before -> $(readlink before) (a link, the text exact) · after/ a directory (the frozen copy) · no secrets/, target/ or .m2-demo/ in either"
$G -v '^ *#' harness/src/probe/*.java harness/src/probe/u06/*.java | $G -q 'Thread\.sleep' && die "R.412: a Thread.sleep in the harness"
for f in Witness Http Etag Routes; do w=$(awk -v n="harness/src/probe/$f.java" '$1 == "file" && $2 == n { print $3 }' ../c9-unit05/receipts.md5)
  [ -n "$w" ] && [ "$(md5 -q harness/src/probe/$f.java)" = "$w" ] || die "harness/src/probe/$f.java is not U05's published file (../c9-unit05/receipts.md5)"; done
echo "  harness/src/probe: Witness, Http, Etag, Routes = ../c9-unit05/receipts.md5's file lines (copied from U05's harness) · U06Probe = this unit's"
[ "$(sed -n '5,$p' harness/tree06.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit05/harness/tree05.py | md5 -q)" ] || die "harness/tree06.py's code is not tree05.py's"
for u in 01 02 03 04 05; do [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit$u/harness/dur9.py)" ] || die "harness/dur9.py is not ../c9-unit$u's copy (dur9 as shipped)"; done
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"
  [ ! -f "$C9R/_builders/dur9.py" ] || [ "$(md5 -q "$C9R/_builders/dur9.py")" = "$D9" ] || die "harness/dur9.py is not C9/_builders/dur9.py"
else D9N="(the registry is not on this machine: U01-U05's copies are the pin)"; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit01-05's copies $D9N · tree06.py's code = tree05.py's"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit05/receipts.md5)
[ -n "$UA" ] || die "../c9-unit05/receipts.md5 has no after-tree line"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree06.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$nm" = after-tree ] || [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit05/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree06.py $dir/ -> $got = receipts.md5's $nm line$( [ "$nm" = before-tree ] && echo " = ../c9-unit05/receipts.md5's after-tree line")"; }
pin before-tree before; pin after-tree after
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true)
echo "  after/ against ../c9-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures its own frozen after/' )"
HF="harness/chk06.py harness/s906.py harness/tree06.py harness/dur9.py $(for f in $HSRC; do printf 'harness/src/%s ' $f; done)exercise/read.sh exercise/check.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's scripts: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
ST=$(python3 -I -B harness/chk06.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
STV=$(printf '%s\n' "$ST" | sed -n 's/^VALUES //p')
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s906.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U06 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s906, per sentence): /'
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
G1=$(python3 -I -B harness/chk06.py gloss)
[ "$($G -cxF -- "$G1" README.md)" = 1 ] || die "the gloss (SECTION SHAPE 06, S1B :388) must stand in README.md once, as a line of its own, byte for byte: $G1"
HOOK=$(python3 -I -B harness/chk06.py hook); EXQ=$(python3 -I -B harness/chk06.py exq)
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook candidate (BLUE C9-U06 Q-c), byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SP=$(python3 -I -B harness/chk06.py spoken "$HOOK" "$EXQ" "$G1") || die "the spoken lines: $(printf '%s\n' "$SP" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$SP" | $G -v '^VALUES ' | sed 's/^/  /'
SPV=$(printf '%s\n' "$SP" | sed -n 's/^VALUES //p')
printf '%s\n\n%s\n\n%s\n' "$HOOK" "$EXQ" "$G1" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s906.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
printf '%s\n' "$SW" | tail -1 | $G -qE ' refused: 0$' || die "a refused reading in a spoken line: $(printf '%s\n' "$SW" | $G ' line ' | head -3 | paste -sd';' -)"
echo "  the hook candidate, the exercise's line and the gloss through s906.py (every family, dur9 inside it): refused 0"; rm -f .r-lock/spoken.md
block() { awk '/^```(bash|sh)$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
SETX=$(block exercise/README.md); SOLX=$(block exercise/SOLUTION.md)
[ -n "$SETX" ] && [ -n "$SOLX" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
[ "$(printf '%s\n' "$SOLX" | wc -l | tr -d ' ')" = 1 ] || die "R.196: SOLUTION.md's block must be the one fixed line"
[ "$($G -c '^curl ' exercise/read.sh)" = 1 ] || die "exercise/read.sh: one asking line (the line the fix changes)"
$G -q -- '/api/v1/customers/priya"' exercise/read.sh || die "exercise/read.sh: the broken form - the name in the wrong case"
swapline() { XN="$2" python3 -I -c 'import os, re, sys; f = open(sys.argv[1]).read().split("\n"); i = [k for k, l in enumerate(f) if re.match(sys.argv[2], l)]; assert len(i) == 1; f[i[0]] = os.environ["XN"]; sys.stdout.write("\n".join(f))' "$1" "$3"; }
SOLV=$(swapline exercise/read.sh "$SOLX" '^curl ')
[ "$(diff exercise/read.sh <(printf '%s\n' "$SOLV") | $G -c '^[<>]')" = 2 ] || die "R.196: SOLUTION.md's line must change read.sh's asking line and nothing else"
[ "$($G '^curl ' exercise/read.sh | sed 's#/customers/priya"#/customers/Priya"#')" = "$SOLX" ] || die "R.196: SOLUTION.md's line changes one word of read.sh's asking line (priya -> Priya)"
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
$G -qE '^rm -f read\.status read\.body$' exercise/check.sh || die "exercise/check.sh must remove the saved answer before it runs read.sh"
! $G -qwE 'path' exercise/check.sh || die "exercise/check.sh names a variable path - under zsh that is the PATH array (BLUE C9-U06's finding): rpath"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket"
DK=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -vF 'echo "' | $G -nE '(^|[ ;(])docker (run|exec|rm|ps|port|info|images|volume|image|pull|logs|inspect)\b' | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.344: receipts.sh calls docker without the pinned socket: $DK"
RMF=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) rm( +-[a-z]+)*' | sort -u | paste -sd'|' -)
[ "$RMF" = 'dk rm -fv' ] || die "R.387: receipts.sh removes a container without its volumes (found: ${RMF:-none})"
[ "$($G -v '^ *#' receipts.sh | $G -oE '(dk|docker) run -[^"]*' | $G -vcF -- '--pull never' || true)" = 0 ] || die "R.344: a dk run without --pull never"
MVA=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -F '$MV ' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am"
KW='idempotency''-key'; KH=$($G -v '^ *#' receipts.sh exercise/read.sh exercise/check.sh | $G -iF "$KW" | $G -vcF 'KEYH=' || true)
[ "$KH" = 0 ] || die "S9.21: a line of receipts.sh or the exercise names the key header outside KEYH= ($KH)"
KU=$($G -v '^ *#' receipts.sh | $G -F '$KEYH' | $G -vF 'KU=' | $G -vcE '^  (CK=1 )?ask k-' || true)
[ "$KU" = 0 ] || die "S9.21: the key header is sent by a request not labelled k- ($KU)"
echo "  the exercise: SOLUTION.md's line = read.sh's asking line with one word changed (priya -> Priya), nothing else; read.sh broken as shipped; check.sh removes the saved answer first, names no variable path; the two What-it-prints blocks differ · the gloss, the hook candidate and the exercise's line byte for byte · placeholders 0"
echo "  static: no kill by name; every docker call on the pinned socket, every dk run --pull never, every removal rm -fv; every Maven build -pl tiffinbox-web -am; no Thread.sleep in the harness; the key header only on the k- requests"
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
MH=$(printf 'Date: Tue, 24 Nov 2026 08:00:00 GMT\r\nSet-Cookie: JSESSIONID=ABC123; Path=/; HttpOnly\r\nLocation: http://127.0.0.1:20950/dashboard\r\nExpires: Tue, 24 Nov 2027 08:00:00 GMT\r\n' > .r-lock/mh; maskh .r-lock/mh | paste -sd'|' -; rm -f .r-lock/mh)
[ "$MH" = 'Date: <masked>|Set-Cookie: JSESSIONID=<masked>; Path=/; HttpOnly|Location: http://127.0.0.1:<port>/dashboard|Expires: <masked>' ] || die "the header mask's self-test: $MH"
echo "  masks: the log mask's self-test masked a Started line's times, a millisecond count, Boot's /error timestamp, the folders and the home; the header mask's self-test masked a planted Date, session cookie value, port and Expires"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
$G -qF 'S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)' ../c9-unit04/receipts.sh || die "../c9-unit04/receipts.sh no longer reads the seven's md5 off ../c7-unit31/receipts.sh"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SURF=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh)
[ ${#U4SURF} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh (SURF=)"
U5V=$(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit05/README.md | $G -oE 'seven=[0-9a-f]+ surface=[0-9a-f]+' | head -1)
[ "$U5V" = "seven=$(echo $S466 | cut -c1-8) surface=$(echo $U4SURF | cut -c1-8)" ] || die "U05's README values block ($U5V) is not the seven and the surface read off the receipts"
echo "  the seven: expected $S466 (../c7-unit31/receipts.sh's S466= line, as ../c9-unit04/receipts.sh reads it) · the old surface: expected $U4SURF (../c9-unit04/receipts.sh's SURF= line, U05's reader) · both = U05's README values block ($U5V)"

# ---- docker, ports, the guard: the baselines ----------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that socket? (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
iid() { dk image inspect --format '{{.Id}}' "$1" 2> /dev/null | cut -c8-19; }
[ "$(iid $IMG)" = 77f585114c32 ] || die "the image $IMG is not on this machine - this script never pulls"
[ "$IMG" = "$(sed -n 's/^IMG=\(postgres@sha256:[0-9a-f]*\).*/\1/p' ../c9-unit05/receipts.sh)" ] || die "the image digest is not ../c9-unit05/receipts.sh's IMG= line"
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run"
[ -z "$(dk ps -aq --filter name=^/$CN\$ 2> /dev/null)" ] || die "a container named $CN exists before the run - an interrupted run's? docker -H \"\$DH\" rm -fv $CN"
TC0=1
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
BAND="20950 20951 20952 20953 20954 20955 20956 20957 20958 20959"
PORTS="18881 18882 18883 18884 20578 20615 $BAND 21280 21281 21282 21283 21284"
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
  echo "  guard before $1: no other receipt · load1 $l1 (< 20)$( [ $w = 0 ] || echo " after $w checks at or above 20 (waited, never killed)")"; }
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · $IMG present (= U05's IMG=) · nothing pulled, ever · no Testcontainers container, no $CN · ports $PORTS free (TCP; the band and 21280-21284 UDP too) · no java process"

# ---- the trees, copied and built offline: before (through the link), after/, the tests copy; the harness and the plant, compiled ---------
M2="$PWD/.m2-demo"
if [ ! -d "$M2" ]; then [ -d "$SEED" ] || die "the seed $SEED is missing (README.md, The repository)"; cp -cR "$SEED" "$M2" 2> /dev/null || cp -R "$SEED" "$M2" || die "the seed could not be copied"; fi
NF0=$(find "$M2" -type f | wc -l | tr -d ' ')
for a in org/springframework/boot/spring-boot-starter-parent/4.1.3/spring-boot-starter-parent-4.1.3.pom org/apache/tomcat/embed/tomcat-embed-core/11.0.29/tomcat-embed-core-11.0.29.jar \
         org/eclipse/parsson/parsson/1.1.9/parsson-1.1.9.jar jakarta/json/jakarta.json-api/2.1.3/jakarta.json-api-2.1.3.jar net/ttddyy/datasource-proxy/1.11.1/datasource-proxy-1.11.1.jar; do
  [ -f "$M2/$a" ] || die ".m2-demo holds no $a - it is not the U04 seed"; done
echo "  .m2-demo (a copy of the seed m2-seed-c9-u04): files $NF0 · the 4.1.3 parent, tomcat-embed-core 11.0.29, parsson 1.1.9, jakarta.json-api 2.1.3, datasource-proxy 1.11.1 present"
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
[ -n "$PGJ" ] || die "after/'s lib/ holds no PostgreSQL driver"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \"$CPA:$DSP\" harness/src/probe/*.java harness/src/probe/u06/*.java" .harness/javac.log
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
# the server's own lines for one request, after a mark (U05's srv, copied - U03's): the access log's line, every PROBE-REQ line since the
# mark, the resolver's lines (harness logging: ExceptionHandlerExceptionResolver at DEBUG)
srv() { local lab=$1 m=$2 a0=$3 i=0
  while [ "$(acount $lab)" -le "$a0" ]; do i=$((i + 1)); [ $i -lt 400 ] || { echo "     access: NO LINE"; break; }; sleep 0.02; done
  [ $i -ge 400 ] || echo "     access: $(sed -n "$(( a0 + 1 ))p" ".harness/run/$lab/access/access.log")"
  sed -n "$(( m + 1 )),\$p" ".harness/run/$lab/jvm.log" | $G -E "^PROBE-REQ [0-9]+ " | sed -E 's/^PROBE-REQ [0-9]+ /     server: /' | cut -c1-260
  sed -n "$(( m + 1 )),\$p" ".harness/run/$lab/jvm.log" | $G -oE 'Using @ExceptionHandler [A-Za-z0-9_.$]+#[A-Za-z0-9_]+\([^)]*\)|Resolved \[[A-Za-z0-9_.$]+' | sed -E 's/^Using @ExceptionHandler ([A-Za-z0-9_.$]+\.)?([A-Za-z0-9_$]+#[A-Za-z0-9_]+)\(.*$/     resolved by: \2/; s/^Resolved \[([A-Za-z0-9_$]+\.)*([A-Za-z0-9_$]+)$/     resolved: \2/'; }
HSEL='^(Location|Allow|Accept-Patch|Content-Length|Content-Type|Link):'
VSEL='^(ETag|Last-Modified|Cache-Control|Expires|Vary|Link|X-Total-Count):'
# ask LABEL METHOD PATH [curl args]: one request into its own (reset) header and body files (U05's ask, copied; HEAD by curl -I; the
# validator and paging header NAMES it carries; whether this request sent the key header); where CK is set, both caches' keys before and after
ask() { local lab=$1 m=$2 p=$3 o=$J/$DB-$1 w rc mk a0 c0 c1 x; shift 3
  : > "$o.h"; : > "$o.b"; [ -z "${CK:-}" ] || c0=$(ck); mk=$(mark $L); a0=$(acount $L)
  if [ "$m" = HEAD ]; then w=$($CURL --http1.1 -sS -I -D "$o.h" -o "$o.b" -w '%{http_code} %{content_type} %{size_download}' --max-time 20 "$@" "$(B $P)$p" 2> "$o.err"); rc=$?
  else w=$($CURL --http1.1 -sS -D "$o.h" -o "$o.b" -w '%{http_code} %{content_type} %{size_download}' --max-time 20 -X "$m" "$@" "$(B $P)$p" 2> "$o.err"); rc=$?; fi
  echo "-- $lab | $m $p -> $w (curl exit $rc)"
  x=no; for a in "$@"; do case "$a" in [Ii]dempotency-[Kk]ey:*) x=yes ;; esac; done; echo "     sent: key header $x"
  echo "     status lines: $(tr -d '\r' < "$o.h" | $G -E '^HTTP/' | sed 's/ *$//' | paste -sd'>' - | sed 's/>/ > /g')"
  tr -d '\r' < "$o.h" | $G -iE "$HSEL" | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' | while IFS= read -r h; do case "$h" in [Aa]llow:*|[Aa]ccept-[Pp]atch:*) echo "     header: $h · set {$(printf '%s' "${h#*:}" | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)}" ;; *) echo "     header: $h" ;; esac; done
  echo "     validators: {$(tr -d '\r' < "$o.h" | $G -iE "$VSEL" | cut -d: -f1 | sort | paste -sd, -)}"
  srv $L $mk $a0
  [ -z "${CK:-}" ] || { c1=$(ck); echo "     cache: before $c0 · after $c1"; }
  local n; n=$(wc -c < "$o.b" | tr -d ' ')
  if [ "$m" = HEAD ]; then echo "     body: (HEAD) $n B of headers in the -I file, size_download is the body"
  elif [ "$n" -le 330 ] && [ "$n" -gt 0 ]; then echo "     body: $(tr -d '\r' < "$o.b" | tr '\n' '~' | sed -E 's/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/"timestamp":"[^"]*"/"timestamp":"<masked>"/')"; else echo "     body: $n B md5 $(md5 -q "$o.b")"; fi; }
probe() { $CURL -s "$(B $P)/probe/u06/$1"; }
ck() { probe cache | python3 -I -c 'import json,sys; d = json.load(sys.stdin); print("customers %s customer %s" % (d["customers"], d["customer"]))'; }
psqlq() { dk exec $CN psql -U tiffinbox -d "${2:-tiffinbox}" -qAt -c "$1" 2>&1 | tr '\n' ' ' | sed 's/ *$//'; }
row() { if [ "$DB" = pg ]; then local x; x=$(psqlq "SELECT name || ' ' || meals_per_day || ' ' || price_per_meal || ' ' || meal_type || ' v' || version FROM customer WHERE name = '$1'"); echo "${x:-no row} (psql in $CN, the second client)"
  else echo "$($CURL -s "$(B $P)/probe/row/$1" | python3 -I -c 'import json,sys; r = [{k.lower(): v for k, v in x.items()} for x in json.load(sys.stdin)]; print(" ".join("%s %s %s %s v%s" % (x["name"], x["meals_per_day"], x["price_per_meal"], x["meal_type"], x["version"]) for x in r) or "no row")') (the harness's JdbcTemplate route /probe/row/$1, the second client)"; fi; }
count() { if [ "$DB" = pg ]; then echo "$(psqlq "SELECT count(*) FROM customer") (psql in $CN, the second client)"; else echo "$(probe count | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])') (the harness's JdbcTemplate route /probe/u06/count, the second client)"; fi; }
keyrows() { if [ "$DB" = pg ]; then echo "$(psqlq "SELECT count(*) FROM idempotency_key") (psql in $CN, the second client)"; else echo "$(probe keys | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["rows"])') (the harness's JdbcTemplate route /probe/u06/keys, the second client)"; fi; }
pauses() { if [ "$DB" = pg ]; then echo "$(psqlq "SELECT string_agg(p.id || ':' || p.customer_id || ':' || p.days, ' ' ORDER BY p.id) FROM pause p JOIN customer c ON c.id = p.customer_id WHERE c.name = '$1'") (id:customer_id:days, psql in $CN, the second client)"
  else echo "$(probe pauses/$1 | python3 -I -c 'import json,sys; d = json.load(sys.stdin); print(" ".join("%s:%s:%s" % (r.get("ID", r.get("id")), r.get("CUSTOMER_ID", r.get("customer_id")), r.get("DAYS", r.get("days"))) for r in d["pauses"]))') (id:customer_id:days, the harness's JdbcTemplate route /probe/u06/pauses/$1, the second client)"; fi; }
lis() { probe feed | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["listeners"])'; }
pgfresh() { psqlq "drop database if exists tiffinbox with (force)" postgres > /dev/null; psqlq "create database tiffinbox" postgres > /dev/null; }
pgup() { guard "the PostgreSQL container"
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:20951:5432 -e POSTGRES_DB=tiffinbox -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust $IMG" .harness/docker-run-pg.log
  [ "$RE" = 0 ] || die "the PostgreSQL container did not start: $(tail -2 .harness/docker-run-pg.log)"
  local i=0; while ! dk exec $CN pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 240 ] || die "PostgreSQL did not accept connections"; sleep 0.5; done
  [ "$(dk port $CN | paste -sd'|' -)" = '5432/tcp -> 127.0.0.1:20951' ] || die "$CN publishes on another address than 127.0.0.1:20951"
  echo "  $CN: PostgreSQL $(psqlq 'show server_version') by the digest, on 127.0.0.1:20951 alone (docker port), trust on the loopback (U05's form: no password exists to print), a fresh database"; }
# tb LABEL PORT DB HCX [args]: TiffinBox (the extracted jar of TREE=after unless TREE is set), from its own run folder with a generated token
# (a config tree, 0600, never printed), Tomcat's access log on (unbuffered, no time field: %m %U%q %s %b, S9.27); waited for by its
# Started line (never a health poll: the cache's cold state stays observable), or by health 200 where HEALTHUP is set
tb() { local label=$1 port=$2 db=$3 hcx=$4 t=${TREE:-after} run=.harness/run/$1 jx="" src="" i=0; shift 4
  guard "TiffinBox $label"
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox" "$run/access"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  local x="$U/.harness/$t/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  if [ -n "$hcx" ]; then cp="$hcx:$cp:$U/.harness/hc:$DSP"; src="--spring.main.sources=${SRC:-probe.Witness,probe.Http,probe.Routes,probe.u06.U06Probe}"; fi
  [ "$db" = pg ] && jx="-Dtiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:20951/tiffinbox?user=tiffinbox"
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
  echo "  version lines ($label): $($G -oE 'Starting Servlet engine: \[[^]]*\]|HHH000001: Hibernate ORM core version [0-9A-Za-z.]+' "$run/jvm.log" | paste -sd'|' -) · Boot $(ls .harness/$t/$XD/lib | sed -n 's/^spring-boot-\([0-9][0-9.]*\)\.jar$/\1/p') · Framework $(ls .harness/$t/$XD/lib | sed -n 's/^spring-core-\([0-9][0-9.]*\)\.jar$/\1/p') · Jackson $(ls .harness/$t/$XD/lib | sed -n 's/^jackson-databind-\(3[0-9.]*\)\.jar$/\1/p') · database: $($G -m1 -oE 'Database: [^ ]+ \([^)]*\)' "$run/jvm.log" | sed -E 's/jdbc:[a-z0-9]+:[^ ]*/<url>/')"; }
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
  local o e=0; o=$(python3 -I -B harness/chk06.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk06 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  $G -v '^ok \|^FAIL ' .harness/chk-$nm.out | sed 's/^/  chk06 /' || true
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; [ -n "${DEVCAPS:-}" ] && { echo "  (development: $nm's check failed, the run goes on)"; unpub="$unpub $nm"; } || die "$nm: its check failed (harness/chk06.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk06.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-11s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-11s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff its block in README.md against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }

# ---- the captures --------------------------------------------------------------------------------------------------------------------
MPT='Content-Type: application/merge-patch+json'; JSON='Content-Type: application/json'
KEYH='Idempotency-Key'          # the key header's name: sent only by the k- requests (R1's pause, R7's pair)
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
  for f in .harness/tests/tiffinbox-web/target/surefire-reports/TEST-*.xml; do python3 -I -B harness/chk06.py surefire "$f"; done
  echo "== Failsafe's XML, per class (the ITs)"
  for f in .harness/tests/tiffinbox-web/target/surefire-reports-it/TEST-*.xml; do python3 -I -B harness/chk06.py surefire "$f"; done
  $G -E '^IT BINDINGS ' .harness/verify.log | sort | sed 's/^/  /'
  echo "  Testcontainers' containers while verify ran (docker ps Ports, beside, never the witness): $(tr ', ' '\n\n' < .harness/tcps.txt | $G -oE '^[0-9.]+:[0-9]+' | sort -u | paste -sd' ' -)"
  echo "  Testcontainers containers after: $(dk ps -aq --filter label=org.testcontainers=true | wc -l | tr -d ' ') · listeners on 21280-21284 after: $(for p in 21280 21281 21282 21283 21284; do listeners $p; done | paste -sd+ - | bc)"
  echo "== BOOT-INF/lib before -> after"
  for t in before after; do echo "  $t: $(ls .harness/$t/$XD/lib | wc -l | tr -d ' ') jars · $(ls .harness/$t/$XD/lib | $G -E '^(spring-boot-[0-9]|spring-core-|tomcat-embed-(core|el|websocket)-|netty-common-|jackson-databind-|jackson-core-3|tools\.jackson|postgresql-|jakarta\.json-api-|parsson-)' | sort | paste -sd' ' -)"; done
  echo "  the jars whose names moved: $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c '^[<>]')"; }

# the handler methods: ONE flag start of after/ (mappings exposed on the command line once, never shipped; no harness: the count is
# TiffinBox's own), and the partition by commit, derived from the sources (git grep, anchored: a Javadoc's {@code @GetMapping} is not a mapping)
MAPRX='^[[:space:]]*@(Get|Post|Patch|Put|Delete)Mapping'
WMJ=c9-tiffinbox/tiffinbox-web/src/main/java
gcount() { git -C .. grep -cE "$MAPRX" "$1" -- "$WMJ" 2> /dev/null | awk -F: '{ s += $NF } END { print s + 0 }'; }
gdev() { git -C .. grep -lE '@Profile\("dev"\)' "$1" -- "$WMJ" 2> /dev/null | sed "s#^$1:##" | sort; }
c_mappings() { local h n d dm c
  echo "== the handler methods on after/ (one flag start on 20954, H2, no harness: --management.endpoints.web.exposure.include=health,prometheus,mappings, once)"
  P=20954; L=FLAG; tb FLAG 20954 h2 "" --management.endpoints.web.exposure.include=health,prometheus,mappings
  $CURL -s "$(B 20954)/actuator/mappings" > $J/mappings.json
  python3 -I -B harness/chk06.py mapjson < $J/mappings.json
  tbstop FLAG 20954
  echo "== the partition by commit (git grep -cE '$MAPRX' over $WMJ at each commit; the dev classes by @Profile(\"dev\"))"
  for c in 80f7839 a0a0151 df4ff12; do
    n=$(gcount $c); d=$(gdev $c | wc -l | tr -d ' '); dm=0
    for f in $(gdev $c); do [ "$(git -C .. grep -cE "$MAPRX" "$c" -- "${f#*:}" 2> /dev/null | awk -F: '{ s += $NF } END { print s + 0 }')" -gt 0 ] && dm=$((dm + $(git -C .. grep -cE "$MAPRX" "$c" -- "${f#*:}" | awk -F: '{ s += $NF } END { print s + 0 }'))); done
    echo "  commit $c ($(git -C .. log -1 --format=%s $c | cut -c1-24)): mapping annotations $n · dev classes $d · dev mappings $dm · default run $((n - dm))"
  done
  n=$(cat $(find after/tiffinbox-web/src/main/java -name '*.java') | $G -cE "$MAPRX"); d=0; dm=0
  for f in $($G -lE '@Profile\("dev"\)' $(find after/tiffinbox-web/src/main/java -name '*.java') | sort); do d=$((d + 1)); dm=$((dm + $($G -cE "$MAPRX" "$f" || true))); done
  echo "  after/ (this unit's tree): mapping annotations $n · dev classes $d · dev mappings $dm · default run $((n - dm))"
  echo "  the unanchored count beside (the finding): after/ $(cat $(find after/tiffinbox-web/src/main/java -name '*.java') | $G -cE '@(Get|Post|Patch|Put|Delete)Mapping') - the extra line(s): $($G -nE '@(Get|Post|Patch|Put|Delete)Mapping' $(find after/tiffinbox-web/src/main/java -name '*.java') | $G -vE ':[0-9]+:[[:space:]]*@(Get|Post|Patch|Put|Delete)Mapping' | sed 's#^after/tiffinbox-web/src/main/java/com/tiffinbox/web/##' | cut -c1-90 | paste -sd';' -)"
  echo "== the dev classes and their mappings (after/, by source)"
  for f in $($G -lE '@Profile\("dev"\)' $(find after/tiffinbox-web/src/main/java -name '*.java') | sort); do
    echo "  $(basename $f .java):$($G -nE '@Profile\("dev"\)' "$f" | head -1 | cut -d: -f1) · mappings $($G -cE "$MAPRX" "$f" || true)$($G -E "$MAPRX" "$f" | sed -E 's/^[[:space:]]*/ /' | paste -sd' ' -)"; done
  echo "== the key filter's table (IdempotencyKeyFilter, read off the source)"
  $G -nE 'addUrlPatterns|"/customers"|"/api/v1/customers/\*"|POST' after/tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeys.java after/tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java 2> /dev/null | sed 's#^after/tiffinbox-web/src/main/java/com/tiffinbox/web/#  #' | cut -c1-200 | head -12; }

# R10 by count (U02's reader, copied): headers, then lines to the first event's blank line, under a 10 s alarm; the reader closes it
feed() { local o=$1 BB=$2 frc; : > "$o.h"; : > "$o.b"
  perl -e '$SIG{ALRM}=sub{kill "TERM",$pid; exit 3}; alarm 10; $pid=open(my $c,"-|",@ARGV) or die; $s=0; while(defined($l=<$c>)){print $l; if($l=~/^\r?\n$/){last if $s} else {$s=1}} kill "TERM",$pid; exit 0' \
     curl --noproxy '*' --http1.1 -sS -N -D "$o.h" -H 'Accept: text/event-stream' "$BB/customers/feed" > "$o.b" 2> "$o.e"; frc=$?
  FEEDRC=$frc; }
# the rows: each review row's request (or pair) on before (U05's after), the shipped tree - the failure receipt
c_rows() { local loc lp
  echo "== $DB: the review's rows on before (U05's after) + the harness on $P; which database answered (Flyway's line): $($G -m1 -oE 'Database: [^ ]+ \([^)]*\)' .harness/run/$L/jvm.log | sed -E 's/jdbc:[a-z0-9]+:[^ ]*/<url>/')"
  echo "  cache before any request: $(ck) · one GET /actuator/health (a counted step of its own): $($CURL -s -o /dev/null -w '%{http_code}' "$(B $P)/actuator/health") · cache after it: $(ck)"
  echo "== R13 a resource the public API can PATCH but not GET (the row unit 06's code fixes)"
  CK=1 ask r13-get GET $API/Ravi
  ask r13-head HEAD $API/Ravi
  ask r13-put PUT $API/Ravi -H "$JSON" --data-binary '{"name":"Ravi","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEG"}'
  ask r13-options OPTIONS $API/Ravi
  ask r13-nobody GET $API/Nobody
  echo "  Priya before: $(row Priya)"
  CK=1 ask r13-priya-patch PATCH $API/Priya -H "$MPT" --data-binary '{"mealsPerDay":2}'
  echo "  Priya after the PATCH: $(row Priya)"
  CK=1 ask r13-priya-get GET $API/Priya
  echo "== R1 the name as the identity: a pause added to Sunil (its Location), then Sunil renamed Sunny on U05's route"
  echo "  Sunil's pauses before: $(pauses Sunil)"
  ask k-r1-pause POST "$API/Sunil/pauses?days=2" -H "$KEYH: \"r1-a\""
  loc=$(tr -d '\r' < $J/$DB-k-r1-pause.h | sed -n 's/^Location: //p' | sed -E 's#^https?://[^/]+##'); lp=${loc##*/}
  echo "  the pause's Location path: $loc · id $lp · Sunil's pauses now: $(pauses Sunil)"
  CK=1 ask r1-warm GET /customers/Sunil
  CK=1 ask r1-rename PATCH $API/Sunil -H "$MPT" --data-binary '{"name":"Sunny"}'
  CK=1 ask r1-old GET /customers/Sunil
  CK=1 ask r1-new GET /customers/Sunny
  ask r1-loc-old GET "$loc"
  ask r1-loc-new GET "$API/Sunny/pauses/$lp"
  echo "  pauses after the rename: Sunil $(pauses Sunil) · Sunny $(pauses Sunny)"
  echo "== R2 about:blank - one error body from each author; RFC 9457 :512-514 (rfc9457.txt md5 $(md5 -q "$DOCS/rfc9457.txt" | cut -c1-8)): $(sed -n 512,514p "$DOCS/rfc9457.txt" | tr -s ' ' | paste -sd' ' -)"
  ask r2-404 GET /customers/Nobody
  ask r2-422 PATCH $API/Meera -H "$MPT" --data-binary '{"mealsPerDay":9}'
  ask r2-400 POST /customers -H "$JSON" --data-binary '{"name":"Bad","mealsPerDay":9,"pricePerMeal":110,"mealType":"VEG"}'
  echo "  (the key-typed 400 is R7's k-r7-pause-nokey, below)"
  echo "== R3 no paging: the list, and the list with a paging query"
  ask r3-list GET /customers
  ask r3-page GET '/customers?page=1&size=1'
  echo "  the two bodies: $(cmp -s $J/$DB-r3-list.b $J/$DB-r3-page.b && echo byte-identical || echo DIFFERENT) · rows by the second client: $(count)"
  echo "== R4 no validators on the JSON answers; the conditional headers are ignored; the stylesheet beside"
  ask r4-ravi GET /customers/Ravi
  ask r4-inm-star GET /customers -H 'If-None-Match: *'
  ask r4-inm-made GET /customers -H 'If-None-Match: "made-up"'
  ask r4-css GET /css/tiffinbox.css
  echo "== R5 no version: the old address answers beside the literal /api/v1/ mapping (U04's address; not measured under a versioning strategy)"
  ask r5-old GET /customers/Ravi
  echo "== R6 the dev routes on the default run (their sources: mappings)"
  ask r6-search GET '/dishes/search?q=rice'
  ask r6-dishes POST /dishes -H "$JSON" --data-binary '{"name":"Dal","price":80}'
  ask r6-leaderboard GET /leaderboard
  ask r6-menu GET /menu/MONDAY
  ask r6-bycustomer GET /revenue/by-customer
  echo "== R10 a GET that keeps state for a client that has gone: the feed's listeners (the harness's /probe/u06/feed) around one read by count"
  echo "  listeners before: $(lis)"
  local mk a0; mk=$(mark $L); a0=$(acount $L); feed $J/$DB-feed "$(B $P)"
  echo "-- r10-feed | GET /customers/feed -> $(tr -d '\r' < $J/$DB-feed.h | head -1 | cut -d' ' -f2) $(tr -d '\r' < $J/$DB-feed.h | $G -i '^Content-Type:' | cut -d' ' -f2 | tr -d ';') $(wc -c < $J/$DB-feed.b | tr -d ' ') (curl exit $FEEDRC)"
  echo "     sent: key header no"; echo "     body: $(tr -d '\r' < $J/$DB-feed.b | tr '\n' '~')"
  echo "  listeners after the client left: $(lis) · again: $(lis)"
  echo "== R7 the optional key: the old create route with no key, twice; the pause route with no key, with one, and the same key again"
  echo "  key table rows before: $(keyrows)"
  ask r7-create POST /customers -H "$JSON" --data-binary '{"name":"Kavi","mealsPerDay":1,"pricePerMeal":110,"mealType":"VEG"}'
  echo "  listeners after the next stored customer (R10's second half): $(lis)"
  ask r7-create-again POST /customers -H "$JSON" --data-binary '{"name":"Kavi","mealsPerDay":1,"pricePerMeal":110,"mealType":"VEG"}'
  local w2 i=0; w2=$($CURL --http1.1 -sS -o /dev/null -w '%{http_code}' --max-time 20 -X POST -H "$JSON" --data-binary '{"name":"Lata","mealsPerDay":1,"pricePerMeal":110,"mealType":"VEG"}' "$(B $P)/customers")
  while [ "$(awk '$3 == 500 && index($2, "/customers/feed") == 1' .harness/run/$L/access/access.log | wc -l | tr -d ' ')" = 0 ]; do i=$((i + 1)); [ $i -lt 500 ] || break; sleep 0.02; done
  echo "  a second stored customer (POST /customers Lata; its own line, not a request block - the departed feed's async error is resolved inside its window): $w2 · the feed's access-log line, waited for by count: $(awk '$3 == 500 && index($2, "/customers/feed") == 1' .harness/run/$L/access/access.log | head -1)"
  echo "  listeners after a second stored customer: $(lis)"
  ask k-r7-pause-nokey POST "$API/Ravi/pauses?days=1"
  echo "  key table rows after the keyless ones: $(keyrows)"
  ask k-r7-pause-key POST "$API/Ravi/pauses?days=1" -H "$KEYH: \"r7-a\""
  ask k-r7-pause-replay POST "$API/Ravi/pauses?days=1" -H "$KEYH: \"r7-a\""
  echo "  the replay's body: $(cmp -s $J/$DB-k-r7-pause-key.b $J/$DB-k-r7-pause-replay.b && echo byte-identical || echo DIFFERENT) · Ravi's pauses: $(pauses Ravi) · key table rows: $(keyrows)"
  echo "== R8 TRACE's body"
  ask r8-trace TRACE /customers
  echo "== R9 a 406 that read first, beside its control"
  ask r9-csv GET /customers -H 'Accept: text/csv'
  ask r9-json GET /customers -H 'Accept: application/json'
  echo "== R11 the 405's Allow narrower than OPTIONS' (the old list, and the public address: r13-put / r13-options above)"
  ask r11-put PUT /customers -H "$JSON" --data-binary '{}'
  ask r11-options OPTIONS /customers
  echo "== R12 the action-named routes (named from mappings), each asked once"
  ask r12-kitchen GET /kitchen
  ask r12-shutdown GET /shutdown
  echo "  access log in all: $(acount $L) lines · status 500: $(awk '$3 == 500' .harness/run/$L/access/access.log | wc -l | tr -d ' ')$(awk '$3 == 500 { printf " (%s %s)", $1, $2 }' .harness/run/$L/access/access.log)"
  echo "  cache at the end: $(ck)"; }

# the fixes: the same requests on after/ (the one fix), the old route beside, the rename round trip on the public read
c_fixes() {
  echo "== $DB: the fix on after/ + the harness on $P; which database answered: $($G -m1 -oE 'Database: [^ ]+ \([^)]*\)' .harness/run/$L/jvm.log | sed -E 's/jdbc:[a-z0-9]+:[^ ]*/<url>/')"
  echo "  cache before any request: $(ck) · one GET /actuator/health: $($CURL -s -o /dev/null -w '%{http_code}' "$(B $P)/actuator/health") · cache after it: $(ck)"
  CK=1 ask f-get GET $API/Ravi
  CK=1 ask f-get2 GET $API/Ravi
  CK=1 ask f-old GET /customers/Ravi
  echo "  the public read's body and the old address's: $(cmp -s $J/$DB-f-get.b $J/$DB-f-old.b && echo byte-identical || echo DIFFERENT)"
  ask f-head HEAD $API/Ravi
  ask f-put PUT $API/Ravi -H "$JSON" --data-binary '{"name":"Ravi","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEG"}'
  ask f-options OPTIONS $API/Ravi
  ask f-nobody GET $API/Nobody
  ask f-inm GET $API/Ravi -H 'If-None-Match: *'
  echo "  Priya before: $(row Priya)"
  CK=1 ask f-priya-patch PATCH $API/Priya -H "$MPT" --data-binary '{"mealsPerDay":2}'
  CK=1 ask f-priya-get GET $API/Priya
  echo "== $DB: the rename round trip on the public read (Sunil -> Sunny, U05's route, its eviction after the commit)"
  CK=1 ask f-warm GET $API/Sunil
  CK=1 ask f-rename PATCH $API/Sunil -H "$MPT" --data-binary '{"name":"Sunny"}'
  CK=1 ask f-pub-old GET $API/Sunil
  CK=1 ask f-pub-new GET $API/Sunny
  CK=1 ask f-old-old GET /customers/Sunil
  CK=1 ask f-old-new GET /customers/Sunny
  echo "  key table rows: $(keyrows)"; }
c_noevict() {
  echo "== $DB: the planted no-evict copy (the shipped CustomerRepository with its update's @Caching removed - the harness's plant, never TiffinBox's), after/, on $P"
  echo "  the class path's first entry: .harness/pc-noevict ($(find .harness/pc-noevict -name '*.class' | sed 's#.*/##' | paste -sd' ' -))"
  CK=1 ask n-warm GET $API/Sunil
  CK=1 ask n-rename PATCH $API/Sunil -H "$MPT" --data-binary '{"name":"Sunny"}'
  CK=1 ask n-pub-old GET $API/Sunil
  CK=1 ask n-pub-new GET $API/Sunny; }
fixes1() { c_fixes; tbstop $L $P
  [ "$DB" = pg ] && pgfresh
  local p0=$P; P=20955; L=N$DB; tb N$DB 20955 $DB "$U/.harness/pc-noevict:$U/.harness/hc" "$MX"
  echo "  cache before any request: $(ck) · one GET /actuator/health: $($CURL -s -o /dev/null -w '%{http_code}' "$(B $P)/actuator/health") · cache after it: $(ck)"
  c_noevict; tbstop $L $P; P=$p0; }

# moved: U02's method table on the four old addresses, OPTIONS on Ravi, U05's PATCH answers, and the new address - before and after/, H2
movedone() { local port=$1 m=$2 p=$3 w; shift 3; : > $J/mv.h; : > $J/mv.b
  if [ "$m" = HEAD ]; then w=$($CURL --http1.1 -sS -I -D $J/mv.h -o $J/mv.b -w '%{http_code} %{content_type} %{size_download}' --max-time 5 "$@" "$(B $port)$p" 2> /dev/null)
  else w=$($CURL --http1.1 -sS -D $J/mv.h -o $J/mv.b -w '%{http_code} %{content_type} %{size_download}' --max-time 5 -X "$m" "$@" "$(B $port)$p" 2> /dev/null); fi
  local bm; [ "$m" = HEAD ] && bm=- || bm=$(sed -E 's/"timestamp":"[^"]*"/"timestamp":"<masked>"/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' $J/mv.b | md5 -q | cut -c1-12)
  echo "  $SIDE | $m $p$( [ -n "${TAG:-}" ] && echo " [$TAG]") -> $w · Allow {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Aa]llow: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)} · Accept-Patch {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Aa]ccept-[Pp]atch: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)} · body $bm"; }
movedside() { local side=$1 port=$2 a m
  HEALTHUP=1 TREE=$side tb moved-$side $port h2 ""
  SIDE=$side
  for a in /customers /customers/Ravi /revenue /shutdown; do for m in GET HEAD POST PUT DELETE CONNECT OPTIONS TRACE PATCH; do movedone $port $m $a; done; done
  for m in GET HEAD PUT DELETE OPTIONS; do movedone $port $m $API/Ravi; done
  movedone $port GET $API/Nobody
  TAG=meals movedone $port PATCH $API/Meera -H "$MPT" --data-binary '{"mealsPerDay":2}'
  TAG=type-null movedone $port PATCH $API/Meera -H "$MPT" --data-binary '{"mealType":null}'
  TAG=rule movedone $port PATCH $API/Meera -H "$MPT" --data-binary '{"mealsPerDay":9}'
  TAG=notjson movedone $port PATCH $API/Meera -H "$MPT" --data-binary '{"mealsPerDay":'
  TAG=json movedone $port PATCH $API/Meera -H "$JSON" --data-binary '{"mealsPerDay":3}'
  TAG=nobody movedone $port PATCH $API/Nobody -H "$MPT" --data-binary '{"mealsPerDay":2}'
  TAG=test movedone $port PATCH $API/Meera -H 'Content-Type: application/json-patch+json' --data-binary '[{"op":"test","path":"/mealsPerDay","value":9}]'
  TAG=taken movedone $port PATCH $API/Meera -H "$MPT" --data-binary '{"name":"Ravi"}'
  tbstop moved-$side $port; }
c_moved() { echo "== U02's method table (four addresses x nine methods), U05's PATCH answers and the new address, on before (20956) and after/ (20950), H2, each its own JVM; bodies hashed with Boot's /error timestamp masked"
  movedside before 20956; movedside after 20950; }

# inert: the seven and the old surface (no key header) on before and after/, one JVM per request set (R.97), health-polled as U05's were
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
  echo "== the seven and the old surface (no key header), each set in its own JVM, H2: the expected seven $S466, the old surface $U4SURF (U05's values block; U05's reader)"
  inert1 before before 20956 ""; inert1 after after 20950 ""
  echo "  before -> after/: the seven $(cmp -s $J/seven-before.txt $J/seven-after.txt && echo equal || echo DIFFER) · the old surface $(cmp -s $J/surface-before.txt $J/surface-after.txt && echo equal || echo DIFFER)"
  diff $J/surface-before.txt $J/surface-after.txt | sed 's/^/    moved: /'
  echo "== the self-test (S9.14, the harness's plant - LABELLED, not a finding about TiffinBox): a ShallowEtagHeaderFilter on /* (probe.Etag, U05's), after/, on 20953"
  SRC=probe.Etag HEALTHUP=1 tb seven-etag 20953 h2 "$U/.harness/hc"
  sh $CURLSET 20953 .harness/run/seven-etag/secrets/tiffinbox/shutdown-token > $J/seven-etag.txt 2>&1
  local i=0; while kill -0 "$(cat .harness/run/seven-etag/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 400 ] || die "seven-etag did not stop"; sleep 0.05; done; tbstop seven-etag 20953
  SRC=probe.Etag HEALTHUP=1 tb surface-etag 20953 h2 "$U/.harness/hc"; oldsurface2 20953 $J/surface-etag.txt; tbstop surface-etag 20953
  echo "  planted: the seven $(md5 -q $J/seven-etag.txt) (unchanged: $(cmp -s $J/seven-etag.txt $J/seven-after.txt && echo yes || echo NO)) · the old surface $(md5 -q $J/surface-etag.txt) (moved: $(cmp -s $J/surface-etag.txt $J/surface-after.txt && echo NO || echo yes)) · the feed's line: $($G '^== GET /customers/feed' $J/surface-etag.txt | sed -E 's/^== //')"; }

# the exercise: read.sh as shipped (broken), SOLUTION.md's line in its place (solved), and five refused "solutions" - the solved line with
# one more change - against TiffinBox's jar alone on 20958 (no harness, a fresh JVM and a fresh database per try), env -i, from the
# exercise's folder, under bash then zsh -f; PostgreSQL first, then H2 in memory
c_exercise() { local v sh d o db sol
  sol=$(block exercise/SOLUTION.md)
  for db in pg h2; do
    for sh in bash zsh; do
      for v in broken solved oldaddr method media other segment; do
        d=$J/ex-$db-$v-$sh; rm -rf $d; mkdir -p $d/exercise; cp exercise/read.sh exercise/check.sh $d/exercise/
        case $v in broken) : ;;
          solved) swapline exercise/read.sh "$sol" '^curl ' > $d/exercise/read.sh ;;
          oldaddr) swapline exercise/read.sh "$(printf '%s' "$sol" | sed 's#/api/v1/customers/Priya#/customers/Priya#')" '^curl ' > $d/exercise/read.sh ;;
          method) swapline exercise/read.sh "$(printf '%s' "$sol" | sed 's#^curl -s #curl -s -X PATCH #')" '^curl ' > $d/exercise/read.sh ;;
          media) swapline exercise/read.sh "$(printf '%s' "$sol" | sed "s#^curl -s #curl -s -H 'Accept: text/csv' #")" '^curl ' > $d/exercise/read.sh ;;
          other) swapline exercise/read.sh "$(printf '%s' "$sol" | sed 's#/api/v1/customers/Priya#/api/v1/customers/Ravi#')" '^curl ' > $d/exercise/read.sh ;;
          segment) swapline exercise/read.sh "$(printf '%s' "$sol" | sed 's#/api/v1/customers/Priya#/api/v1/customer/Priya#')" '^curl ' > $d/exercise/read.sh ;; esac
        echo "== the exercise, $db, $v, $sh (env -i, from the exercise's folder, TiffinBox's jar alone on 20958; a stale read.status planted first; read.sh vs shipped: $(diff exercise/read.sh $d/exercise/read.sh | $G -c '^[<>]') changed lines):"
        [ $db = pg ] && pgfresh
        tb ex-$db-$v-$sh 20958 $db "" > /dev/null
        echo "200 http://127.0.0.1:20958/api/v1/customers/Priya" > $d/exercise/read.status
        if [ $sh = bash ]; then o=$(cd $d/exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=20958 bash -c 'sh check.sh; echo "check exit $?"' 2>&1); else o=$(cd $d/exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=20958 /bin/zsh -f -c 'sh check.sh; echo "check exit $?"' 2>&1); fi
        printf '%s\n' "$o" | sed -E 's/127\.0\.0\.1:20958/127.0.0.1:<port>/g; s/^/  /'
        tbstop ex-$db-$v-$sh 20958
      done
    done
  done
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures${DEVCAPS:+ (DEVELOPMENT: only $DEVCAPS - not a run of record)}"
cap tests c_tests
cap mappings c_mappings
pgup
DB=pg; P=20956; L=RP; TREE=before tb RP 20956 pg "$U/.harness/hc" "$MX"
cap rowspg c_rows
tbstop RP 20956
pgfresh; DB=pg; P=20952; L=FP; tb FP 20952 pg "$U/.harness/hc" "$MX"
cap fixespg fixes1
pgfresh
cap exercise c_exercise
dk rm -fv $CN > /dev/null 2>&1 || die "$CN could not be removed"
DB=h2; P=20956; L=RH; TREE=before tb RH 20956 h2 "$U/.harness/hc" "$MX"
cap rows c_rows
tbstop RH 20956
DB=h2; P=20950; L=FH; tb FH 20950 h2 "$U/.harness/hc" "$MX"
cap fixes fixes1
cap moved c_moved
cap inert c_inert

# ---- the end: the sweep, the values, the published hashes -------------------------------------------------------------------------------
[ -z "$(echo $PIDS)" ] || die "a JVM of this run is still running: $PIDS"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
[ -z "$(dk ps -aq --filter label=org.testcontainers=true)" ] && [ -z "$(dk ps -aq --filter name=^/$CN\$)" ] || die "a container of this run is left"
NI1=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI1" = "$NI0" ] && [ "$VOL1" = "$VOL0" ] || die "R.322: images $NI0 -> $NI1, volumes $VOL0 -> $VOL1"
AD1=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true); [ "$AD1" = "$AD" ] || die "the anchor moved during the run"
pin before-tree before; pin after-tree after
MDB=$(find . ../c9-tiffinbox ../c9-unit05 -name '*.mv.db' -not -path './.harness/*' 2> /dev/null | wc -l | tr -d ' ')
[ "$MDB" = 0 ] || die "an H2 file outside .harness/"
VALS="$VALS
static: $STV
spoken: $SPV
build: seed_files=$NF0"
[ -n "${DEVCAPS:-}" ] && { printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'; echo "c9-unit06: DEVELOPMENT run ($DEVCAPS) - nothing published"; exit 2; }
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
VO=$(python3 -I -B harness/chk06.py values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; die "README.md's values block is not this run's (harness/chk06.py values)"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM of this run, ports free, no container left, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1 · the anchor against after/ as at the start · the tree pins · *.mv.db outside .harness 0 · the values block = this run's"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit06: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit06: every capture = published ($NCAPS) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"
