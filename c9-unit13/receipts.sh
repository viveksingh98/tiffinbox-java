#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 13 "Pagination, Filtering and Sorting as an API Concern" - this unit's receipts. Course 9's TENTH anchor change,
# Section 3's first: before is a link to ../c9-unit12/after (U12's after); after/ is a frozen copy of ../c9-tiffinbox after this unit's
# change - Flyway V6__tiffin_order.sql, OrderEntity and OrderEntityRepository (tiffinbox-core), OrderPages GET /api/v1/orders and
# OrderPagesTest (tiffinbox-web), and BLUE's four test edits (the slice's mock, the committed spec regenerated, both Flyway ITs' lists).
# The harness (never in the jar or the module): probe.u13.* - the harness's insert, offset route, Pageable route and trap, with their own
# repository - joined by --spring.main.sources on a harness-joined start only (21025). No Chrome, no NetLog.
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5; lines starting "  ~" are run-variant
# and left out of the hash - the tie orders, the refused exercise variants of run 1):
#   advisory  the S9.36 read filed for the batch day (ADV3), verified, before any build
#   before    GET /api/v1/orders and /orders on before (404), its Flyway history V1-V5, its mappings, /kitchen's counters
#   change    the modules, the new files whole, the derived changed list, the scans, the greps, the jar's Spring Data JPA
#   table     V6 on a clean H2 and a clean PostgreSQL: the histories, the rows, the ties; a value column refused on H2
#   first     page one newest first on H2 (21020) and PostgreSQL (21022): ids, members, the SQL
#   next      the cursor decoded once, page two, the keyset WHERE, both databases
#   refuse    every refusal, both databases; the size cases
#   pageable  the harness's Pageable route: the 500, three fresh JVMs / databases each, the tie orders counted, the SQL
#   walk      four walks x two databases, the harness's insert between page 1 and 2, each a fresh JVM and database
#   trap      Course 7's offset-then-keyset on 4.1.3, with same-method controls, both databases
#   restart   a cursor across a restart: a random key each start, then the same explicit key, both databases
#   spec      the committed spec against the served one, the diff, the counter, spec vs wire, the client rebuilt
#   moved     U12's nineteen requests and the new route on before (21026) and after/ (21020); the jars per entry
#   seven     c5-unit11's seven on before and after/
#   surface   the old surface by count on before and after/, the S9.14 plant (21024)
#   inert     the key header across this run's captures
#   tests     package, the Docker-free build of after/, verify (Surefire on H2, the five ITs on PostgreSQL), the web-only form, the two needs
#   exercise  break.sh, check.sh, apply.sh on 21028, bash and zsh -f, H2; the refused variants (run 1)
# Ports (U13's band, 21020-21029): 21020 after/ on H2, no harness · 21021 PostgreSQL 18.6 (c9u13-pg) · 21022 after/ on PostgreSQL, no
# harness · 21023 a scratch copy's JVM · 21024 the S9.14 plant · 21025 the harness-joined starts · 21026 before · 21028 the exercise ·
# 21027 and 21029 never bound. During mvn verify only: 21280-21284. Every store on 127.0.0.1; every curl --noproxy '*'.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
C9R=${C9R:-"/Users/$ME/Downloads/Youtube Content/LearnProgrammingWithVivek/rest-apis-done-right"}   # the course's folder (briefs, research)
SEED=${SEED:-"$C9R/_research/m2-seed-c9-s3"}   # the course's Section 3 seed
PK3="$C9R/_research/s3-probe-2026-11-26"; BK3="$C9R/_research/s3-blue-2026-11-26"; ADV="$C9R/_research/docs-2026-11-26/advisories"
export C9R
RUNNO=${RUNNO:-0}                                     # the run of record's number (1, 2, 3); 0 = development
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
export DOCKER_HOST="$DH"
CN=c9u13-pg
PIDS=""; INTR=""; mpid=""; PGUP=""
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in $mpid $PIDS; do [ -z "$p" ] || killtree "$p"; done; for p in $mpid $PIDS; do if kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; [ -z "$PGUP" ] || dk rm -fv $CN > /dev/null 2>&1; for c in $(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null); do dk rm -fv "$c" > /dev/null 2>&1; done; rm -rf exercise/check.run; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.b exercise/check.h; [ -z "$INTR" ] || rm -f .r-*.new; rmdir .r-lock 2> /dev/null || rm -rf .r-lock; true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git unzip /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|SPRINGDOC_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit13 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }') · run $RUNNO"

# ---- gates before anything is built: the folder, the link, the pins, the anchor, the static check, the prose, the exercise ----------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk13.py dur9.py ops9s3.py s913.py src tree13.py walk.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
HSRC='probe/u13/U13Config.java probe/u13/U13Offset.java probe/u13/U13OrderRepository.java probe/u13/U13Pageable.java probe/u13/U13Rows.java probe/u13/U13Trap.java'
[ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$HSRC" ] || die "harness/src holds another file, or misses one"
for f in loc9.py seal9.py cdp.mjs cdp9.mjs specwire9.py mirror src/probe/u12 src/probe/u10/Caller.java; do [ ! -e harness/$f ] || die "harness/$f: an earlier unit's instrument this unit does not carry"; done
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md apply.sh break.sh check.sh' ] || die "exercise/ holds another file, or misses one"
[ -L before ] && [ "$(readlink before)" = ../c9-unit12/after ] || die "before must be a link whose text is exactly ../c9-unit12/after"
[ -d after ] && [ ! -L after ] || die "after/ is this unit's own frozen tree, a directory, not a link"
for t in before after; do [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-client/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/"; true; done
echo "  before -> $(readlink before) (a link, the text exact) · after/ a directory (the frozen copy) · no secrets/, target/ or .m2-demo/ in either · harness/: no seal9.py, cdp.mjs, cdp9.mjs, loc9.py, specwire9.py, mirror/, U12's versioning classes or Caller.java"
$G -v '^ *#' harness/src/probe/u13/*.java | $G -q 'Thread\.sleep' && die "R.412: a Thread.sleep in the harness"
WK=$(md5 -q "$PK3/instruments/walk.py"); [ "$WK" = 84dc35abf5a7e44e6ce3836c321e35e8 ] || die "the probe's walk.py is not 84dc35ab (its md5 $WK)"
OP=$(md5 -q "$BK3/instruments/ops9s3.py"); [ "$OP" = 8f062a0e5e872c478579756a8426c012 ] || die "BLUE's ops9s3.py is not 8f062a0e"
[ "$(md5 -q harness/ops9s3.py)" = "$OP" ] || die "harness/ops9s3.py is not BLUE's instrument, byte for byte"
echo "  walk.py against the probe's (md5 $WK, asserted before the diff): the named diff md5 $(diff "$PK3/instruments/walk.py" harness/walk.py | md5 -q), $(diff "$PK3/instruments/walk.py" harness/walk.py | $G -c '^[<>]') lines (the docstring, the arguments, the harness's routes /probe/u13/, one walk per JVM)"
echo "  ops9s3.py = BLUE's (md5 $OP, byte for byte; it refuses an empty spec)"
for f in U13Config U13OrderRepository U13Rows U13Offset U13Pageable U13Trap; do echo "  harness/src/probe/u13/$f.java md5 $(md5 -q harness/src/probe/u13/$f.java)"; done
for p in V6__tiffin_order.sql ProbeOrderEntity.java ProbeOrderRepository.java ProbeOrderPages.java; do echo "  the probe's $p (the model, read, never shipped): md5 $(md5 -q "$PK3/instruments/probe-src/$p")"; done
[ "$(sed -n '5,$p' harness/tree13.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit12/harness/tree12.py | md5 -q)" ] || die "harness/tree13.py's code is not tree12.py's"
for u in 01 02 03 04 05 06 07 08 09 10 11 12; do [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit$u/harness/dur9.py)" ] || die "harness/dur9.py is not ../c9-unit$u's copy"; done
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"
  [ ! -f "$C9R/_builders/dur9.py" ] || [ "$(md5 -q "$C9R/_builders/dur9.py")" = "$D9" ] || die "harness/dur9.py is not C9/_builders/dur9.py"
else D9N="(the registry is not on this machine: U01-U12's copies are the pin)"; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit01-12's copies $D9N · tree13.py's code = tree12.py's"
XS1=$(sed -n '/^# --- XFAM_S9S1 begin ---$/,/^# --- XFAM_S9S1 end ---$/p' harness/s913.py | md5 -q); XS1U=$(sed -n '/^# --- XFAM_S9S1 begin ---$/,/^# --- XFAM_S9S1 end ---$/p' ../c9-unit12/harness/s912.py | md5 -q)
[ "$XS1" = "$XS1U" ] || die "s913.py's XFAM_S9S1 slice is not U12's s912.py's"
echo "  s913.py: XFAM_S9S1's slice md5 $XS1 = ../c9-unit12/harness/s912.py's · its XU13 family this unit's · lines outside XU13 = s912.py's but for the names: $(diff <(sed '/^XU12 = {/,/^u04 = u12$/d' ../c9-unit12/harness/s912.py) <(sed '/^XU13 = {/,/^u04 = u13$/d' harness/s913.py) | $G -c '^[<>]') lines differ"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit12/receipts.md5)
[ -n "$UA" ] || die "../c9-unit12/receipts.md5 has no after-tree line"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree13.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || { [ -n "${NOPIN:-}" ] && { echo "  $dir/: $got (NOPIN: no pin yet)"; return 0; }; die "receipts.md5 has no $nm line"; }
  [ "$nm" = after-tree ] || [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit12/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree13.py $dir/ -> $got = receipts.md5's $nm line$( [ "$nm" = before-tree ] && echo " = ../c9-unit12/receipts.md5's after-tree line")"; }
pin before-tree before; pin after-tree after
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true)
echo "  after/ against ../c9-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures its own frozen after/' )"
HF="harness/chk13.py harness/s913.py harness/tree13.py harness/dur9.py harness/ops9s3.py harness/walk.py $(for f in $HSRC; do printf 'harness/src/%s ' $f; done)exercise/check.sh exercise/apply.sh exercise/break.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's scripts: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
ST=$(python3 -I -B harness/chk13.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
echo "  static (harness/chk13.py static after before): $(printf '%s\n' "$ST" | $G -c '^ok ') checks, FAIL 0"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s913.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U13 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s913, per sentence): /'
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b|<measure>' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
GL=$(python3 -I -B harness/chk13.py gloss README.md) || die "the gloss: $(printf '%s\n' "$GL" | $G '^FAIL' | head -3 | paste -sd';' -)"
echo "  the gloss: $(printf '%s\n' "$GL" | $G -c '^ok ') checks, FAIL 0 ($(python3 -I -B harness/chk13.py gloss-line))"
HOOK=$(python3 -I -B harness/chk13.py hook); EXQ=$(python3 -I -B harness/chk13.py exq); GLS=$(python3 -I -B harness/chk13.py gloss-line)
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S3B's Unit 13 Hook line), byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
HW=$(printf '%s\n' "$HOOK" | wc -w | tr -d ' '); EW=$(printf '%s\n' "${EXQ#Your turn: }" | wc -w | tr -d ' ')
[ "$HW" -le 25 ] && [ "$EW" -le 25 ] || die "a spoken line over 25 words (hook $HW, exercise $EW)"
echo "  the hook ($HW words) and the exercise's line ($EW words after 'Your turn:') byte for byte, extracted from S3B's Unit 13 (md5 $(md5 -q "$C9R/_briefs/UNIT-BRIEFS-S3-PAYLOADS.md"))"
printf '%s\n\n%s\n\n%s\n' "$HOOK" "$EXQ" "$GLS" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s913.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
printf '%s\n' "$SW" | tail -1 | $G -qE ' refused: 0$' || die "a refused reading in a spoken line: $(printf '%s\n' "$SW" | $G ' line ' | head -3 | paste -sd';' -)"
echo "  the hook, the exercise's line and the gloss through s913.py: refused 0"; rm -f .r-lock/spoken.md
TS="Spring Data Keyset Pagination: a Cursor API vs Offset"
$G -qF "$TS" "$C9R/_briefs/UNIT-BRIEFS-S3-PAYLOADS.md" || die "the title for search is not S3B's"
echo "  the title for search (read, not edited here): \"$TS\" - $(python3 -I -c 'import sys; print(len(sys.argv[1]))' "$TS") characters (<= 60)"
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
! $G -qE '(^|[^A-Za-z0-9_.-])path=|[$][{]?path([^A-Za-z0-9_]|$)' exercise/check.sh exercise/apply.sh exercise/break.sh || die "an exercise script names a variable path (zsh): rpath"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh exercise/check.sh exercise/apply.sh exercise/break.sh | $G -qwE "$K1|$K2" || die "a script names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket"
RMF=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) rm( +-[a-z]+)*' | sort -u | paste -sd'|' -)
[ "$RMF" = 'dk rm -fv' ] || die "R.387: receipts.sh removes a container without its volumes (found: ${RMF:-none})"
MVL=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -F '$MV ')
MVA=$(printf '%s\n' "$MVL" | $G -vF -- '-pl tiffinbox-web -am' | $G -vF -- '-pl tiffinbox-client -am' | $G -cF -- '-pl ' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh with a -pl form other than '-pl tiffinbox-web -am' or '-pl tiffinbox-client -am'"
KW='idempotency''-key'; KH=$($G -v '^ *#' receipts.sh exercise/check.sh exercise/apply.sh exercise/break.sh | $G -ciF "$KW" || true)
[ "$KH" = 0 ] || die "S9.21: a line of receipts.sh or the exercise names the key header"
echo "  static: no kill by name; every docker call on the pinned socket, every removal rm -fv; R.391's Maven forms only; no Thread.sleep in the harness; the key header named by no line"
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
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'took 812 ms' '"placedAt":"2026-11-01T08:09:00Z"' "$U/x $HOME/y" '[INFO] TiffinBox Web ...... SUCCESS [ 11.955 s]' | mask)
[ "$(printf '%s\n' "$MP" | paste -sd'|' -)" = 'Started TiffinBoxServer in <t> (process running for <t>)|took <t>|"placedAt":"<time>"|…/x ~/y|[INFO] TiffinBox Web ...... SUCCESS [<t>]' ] || die "the mask's self-test: $(printf '%s\n' "$MP" | paste -sd'|' -)"
echo "  masks: the log mask masked a Started line's times, a millisecond count, a placedAt value, the folders, the home and a reactor line's time (self-test)"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh); [ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SURF=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh); [ ${#U4SURF} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh (SURF=)"
U12V=$(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit12/README.md | $G -E '^(seven|surface): ' | $G -oE '(seven|surface)=[0-9a-f]{8}' | paste -sd' ' -)
[ "$U12V" = "seven=$(echo $S466 | cut -c1-8) surface=$(echo $U4SURF | cut -c1-8)" ] || die "U12's README values block ($U12V) is not the seven and the surface read off the receipts"
echo "  the seven: expected $S466 (../c7-unit31/receipts.sh's S466= line) · the old surface: expected $U4SURF (../c9-unit04/receipts.sh's SURF= line) · both = U12's values block ($U12V)"
IMG=$(sed -n 's/^IMG=\(postgres@sha256:[0-9a-f]*\).*/\1/p' ../c9-unit09/receipts.sh); [ -n "$IMG" ] || die "the image digest could not be read off ../c9-unit09/receipts.sh's IMG= line"
for f in walk-h2.txt walk-pg.txt; do w=$(find "$PK3/captures" -name $f | head -1); [ -n "$w" ] && echo "  probe | $f md5 $(md5 -q "$w") (read, not copied: the expectation, 1 run)"; done
for f in h2b1.txt h2b2.txt h2b3.txt pgb1.txt pgb2.txt pgb3.txt; do [ -f "$BK3/captures/$f" ] && echo "  BLUE | $f md5 $(md5 -q "$BK3/captures/$f") (read, not copied)"; done

# ---- docker, ports, the guard: the baselines ----------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run"
[ -z "$(dk ps -aq --filter name=^/c9u13- 2> /dev/null)" ] || die "a c9u13-* container exists before the run"
dk image inspect "$IMG" > /dev/null 2>&1 || die "$IMG is not present - no pull here (STOP)"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
BAND="21020 21021 21022 21023 21024 21025 21026 21027 21028 21029"
PORTS="18425 18881 18882 18883 18884 20578 20615 $BAND 21280 21281 21282 21283 21284"
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
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · $IMG present (= ../c9-unit09/receipts.sh's IMG= line) · --pull never, nothing pulled · no Testcontainers or c9u13-* container · ports $PORTS free"

# ---- the trees, copied and built offline: before (through the link), after/; the harness, compiled -------------------------------------
M2="$PWD/.m2-demo"
if [ ! -d "$M2" ]; then [ -d "$SEED" ] || die "the seed $SEED is missing"; cp -cR "$SEED" "$M2" 2> /dev/null || cp -R "$SEED" "$M2" || die "the seed could not be copied"; fi
NF0=$(find "$M2" -type f | wc -l | tr -d ' '); NB0=$(find "$M2" -type f -print0 | xargs -0 stat -f %z | awk '{ s += $1 } END { printf "%d", s }')
CO=$(find "$M2" -name _remote.repositories -print0 | xargs -0 $G -l 'central-only' 2> /dev/null | wc -l | tr -d ' ')
[ "$CO" = 0 ] || die "$CO _remote.repositories files in the seed copy still name central-only"
ART="org/springframework/boot/spring-boot-starter-parent/4.1.3 org/springframework/data/spring-data-jpa/4.1.3 org/hibernate/orm/hibernate-core/7.4.15.Final"
for a in $ART; do [ -n "$(ls "$M2/$a" 2> /dev/null | $G -E '\.(jar|pom)$')" ] || die ".m2-demo holds no $a (no seed act here: report the coordinates)"; done
echo "  .m2-demo (a copy of the seed m2-seed-c9-s3): files $NF0 · bytes $NB0 · _remote.repositories naming central-only: $CO · no artifact this unit adds"
for a in $ART; do echo "  seed | $a | $(ls "$M2/$a" | $G -E '\.(jar|pom)$' | paste -sd' ' -)"; done
mkdir -p .harness; for d in before after pkg tests webonly need-mock need-its need-value exercise run work hc client-before; do rm -rf .harness/$d; done
mkdir -p .harness/home .harness/run .harness/work
printf '%s\n' 'checks.disable=true' > .harness/home/.testcontainers.properties
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy before .harness/before; copy after .harness/after
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE 'Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" HOME=\"$U/.harness/home\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 900; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
AL="-DargLine=$JL -Dstdout.encoding=UTF-8 -Duser.home=../../home"
extract() { bg "cd .harness/$1 && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$1.log
  [ "$RE" = 0 ] || die ".harness/$1: the jar's extract failed"; }
guard "the build of before"
bg "cd .harness/before && $MV -DskipTests clean package -pl tiffinbox-web -am" .harness/build-before.log
[ "$RE" = 0 ] || { tail -30 .harness/build-before.log | mask >&3; die ".harness/before did not build offline (exit $RE)"; }; offl .harness/build-before.log
echo "  built before offline (mvn -o -DskipTests clean package -pl tiffinbox-web -am; exit 0, Downloading/Downloaded from: 0)"
guard "the build of after"
bg "cd .harness/after && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package" .harness/build-after.log
[ "$RE" = 0 ] || { tail -30 .harness/build-after.log | mask >&3; die ".harness/after did not build offline (exit $RE)"; }; offl .harness/build-after.log
echo "  built after/ offline WITH its tests, Docker-free (mvn -o clean package, the whole reactor: $($G -E '^\[INFO\] TiffinBox[A-Za-z ]* \.+ SUCCESS' .harness/build-after.log | sed -E 's/^\[INFO\] (TiffinBox[A-Za-z ]*) \.+ SUCCESS.*/\1/' | paste -sd, -); exit 0) - the jars come from this build; it is the tests capture's Docker-free twin"
extract before; extract after
CPA=".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \"$CPA\" harness/src/probe/u13/*.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/'s jar: $(head -5 .harness/javac.log)"
echo "  the harness compiled against after/'s web jar ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes, -parameters) - never in either jar"
B() { echo "http://127.0.0.1:$1"; }
J=.harness/work
NDB=0
# pgdb: a fresh database in the one container, by name (createdb through the container's own client); prints its JDBC URL
pgdb() { NDB=$((NDB + 1)); dk exec $CN createdb -U tiffinbox "u13db$NDB" > /dev/null 2>&1 || die "createdb u13db$NDB failed"; PGURL="jdbc:postgresql://127.0.0.1:21021/u13db$NDB?user=tiffinbox"; }
psq() { dk exec $CN psql -U tiffinbox -d "$1" -At -c "$2"; }
# tb LABEL PORT DB HARNESS [args]: TiffinBox (the extracted jar of TREE=after unless TREE is set), from its own run folder with a generated
# token and, when KEY is set, a generated cursor key (a config tree, 0600, never printed); the SQL log on (the capture's JVMs); waited for
# by its Started line. DB: h2 (in memory, fresh per JVM) or pg (a fresh database in c9u13-pg). HARNESS: 1 joins probe.u13.U13Config.
tb() { local label=$1 port=$2 db=$3 hx=$4 t=${TREE:-after} run=.harness/run/$1 src="" i=0 jx=""; shift 4
  guard "TiffinBox $label"
  for q in 21027 21029; do [ "$(listeners $q)" = 0 ] && [ -z "$(lsof -nP -iUDP:$q 2> /dev/null)" ] || die "$q must stay free (TCP and UDP)"; done
  [ "$(listeners $port)" = 0 ] && [ -z "$(lsof -nP -iUDP:$port 2> /dev/null)" ] || die "$port is bound before $label"
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  if [ -n "${KEY:-}" ]; then (umask 077 && cp "$KEY" "$run/secrets/tiffinbox/cursor-key") || die "the cursor key was not written"; fi
  if [ "$db" = pg ]; then pgdb; jx="--tiffinbox.jdbc-url=$PGURL"; fi
  local x="$U/.harness/$t/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  if [ -n "$hx" ]; then cp="$cp:$U/.harness/hc"; src="--spring.main.sources=probe.u13.U13Config"; fi
  (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -cp "$cp" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port="$port" $src $jx \
     --logging.level.org.hibernate.SQL=debug "$@" > jvm.log 2>&1) &
  local p=$!; echo $p > "$run/pid"; PIDS="$PIDS $p"; MINE="${MINE:-} $port"
  while ! $G -q -E 'Started TiffinBox(App|Server) in' "$run/jvm.log" 2> /dev/null; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before its Started line"; }; i=$((i + 1)); [ $i -lt 900 ] || die "$label: no Started line"; sleep 0.1; done
  if [ -n "$hx" ]; then i=0; while ! $G -q '^U13 harness: joined' "$run/jvm.log"; do i=$((i + 1)); [ $i -lt 100 ] || die "$label: no U13 harness line"; sleep 0.05; done; fi
  echo "  $label up on $port ($db, tree $t$( [ -n "$hx" ] && echo ", the harness joined (its U13 harness line printed)" || echo ", no harness")) · $($G -o -E 'Successfully applied [0-9]+ migrations[^(]*' "$run/jvm.log" | head -1 | sed 's/ *$//') · cursor key: $($G -oE "cursor key: (set|defaulted)" "$run/jvm.log" | head -1 | sed 's/cursor key: //')"; }
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
  local o e=0; o=$(python3 -I -B harness/chk13.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk13 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; [ -n "${DEVCAPS:-}${NOPIN:-}" ] && { echo "  (development: $nm's check failed, the run goes on)"; unpub="$unpub $nm"; } || die "$nm: its check failed (harness/chk13.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk13.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-11s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-11s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff .r-$nm.new against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }
ck() { python3 -I -B harness/chk13.py "$@"; }
API=/api/v1/orders
# get SIDE LABEL PORT QUERY RUN: one GET of the order list; prints status, type, members, ids, next present, and the SQL it ran
pagereq() { local db=$1 lab=$2 port=$3 q=$4 run=.harness/run/$5 n0 w
  n0=$(wc -l < $run/jvm.log | tr -d ' ')
  w=$($CURL --http1.1 -sS -o $J/pg.b -w '%{http_code} %{content_type}' --max-time 10 "$(B $port)$API$q")
  echo "  $db | $lab -> $w · $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print("keys %s · ids %s · next %s" % (list(d), [i["id"] for i in d["items"]], "present" if d.get("next") else "null"))' $J/pg.b)"
  echo "  $db | $lab SQL | $(tail -n +$((n0 + 1)) $run/jvm.log | $G -E 'org\.hibernate\.SQL' | $G 'tiffin_order' | tail -1 | sed -E 's/.*org\.hibernate\.SQL *: //')"; }
# prq DB LABEL PORT QUERY: one refused (or not) request, the body whole
prq() { local db=$1 lab=$2 port=$3 q=$4 w
  w=$($CURL --http1.1 -sS -o $J/pr.b -w '%{http_code} %{content_type}' --max-time 10 "$(B $port)$API$q")
  echo "  $db | $lab -> $w | $(tr -d '\r\n' < $J/pr.b | cut -c1-600)"; }
nextof() { python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1]))["next"])' "$1"; }

# ---- the captures ----------------------------------------------------------------------------------------------------------------------
c_advisory() {
  echo "== S9.36: the read filed for the batch day (ADV3; not re-read: no network), before any build"
  echo "  fetched-at $(head -1 "$ADV/fetched-at.txt" | cut -c1-10) (the hour masked) · run date $(date '+%Y-%m-%d')"
  sed -n '2,$p' "$ADV/fetched-at.txt" | sed 's/^/  fetched | /'
  local n=0 v=0 f h; while read -r h f; do n=$((n + 1)); [ "$(md5 -q "$ADV/$f" 2> /dev/null)" = "$h" ] && v=$((v + 1)); done < <($G -vE '^\s*$' "$ADV/MD5SUMS.txt" | awk '$2 != "MD5SUMS.txt" { print $1, $2 }')
  echo "  MD5SUMS.txt: $n lines, $v verified (its own line, the md5 of an empty file, left out)"
  echo "  spring rows $($G -c . "$ADV/spring-index-rows-2026-11-24.txt") · naming Spring Framework $($G -c 'Spring Framework' "$ADV/spring-index-rows-2026-11-24.txt" || true)"
  echo "  tomcat page md5 $(md5 -q "$ADV/tomcat-security-11.html")"
  for a in spring-data-jpa spring-data-commons hibernate-core tomcat-embed-core jackson-databind postgresql h2; do
    g='[:.]'; [ $a = jackson-databind ] && g='tools\.jackson\.core:'
    echo "  t3 tree | $a $($G -E "$g$a:jar:" "$ADV/probe-tree-t3-dependency-list.txt" | head -1 | awk -F: '{ print $4 }')"; done
  echo "  t3 tree | jackson-databind (Jackson 2, beside it at run time) $($G -E 'com\.fasterxml\.jackson\.core:jackson-databind:jar:' "$ADV/probe-tree-t3-dependency-list.txt" | head -1 | awk -F: '{ print $4 }')"
  echo "  t3 tree | coordinates $($G -cE ':jar:' "$ADV/probe-tree-t3-dependency-list.txt")"
  echo "  osv (second witness only, S2.8): $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); r=d.get("results",[]); print("%d results, %d with vulns" % (len(r), sum(1 for x in r if x.get("vulns"))))' "$ADV/osv-result.json")"
  echo "  verdict: no pin affected; evidence may proceed"; }
c_before() {
  echo "== before (21026, U12's after, H2, no harness; the harness's exposure flag for /actuator/flyway and /actuator/mappings)"
  TREE=before tb before 21026 h2 "" --management.endpoints.web.exposure.include=health,prometheus,flyway,mappings
  local p; for p in /api/v1/orders /orders; do echo "  before | GET $p -> $($CURL --http1.1 -sS -o $J/b.b -w '%{http_code} %{content_type}' "$(B 21026)$p") · $(tr -d '\r\n' < $J/b.b | cut -c1-200)"; done
  echo "  before | flyway $($CURL -s "$(B 21026)/actuator/flyway" | python3 -I -c 'import json,sys; d=json.load(sys.stdin); m=list(d["contexts"].values())[0]["flywayBeans"]["flyway"]["migrations"]; print([x["version"] for x in m])')"
  $CURL -s "$(B 21026)/actuator/mappings" | python3 -I -c '
import json,sys
d=json.load(sys.stdin); ps=[]
for c in d["contexts"].values():
    for m in c["mappings"]["dispatcherServlets"]["dispatcherServlet"]:
        rc=(m.get("details") or {}).get("requestMappingConditions")
        if rc: ps += rc.get("patterns", [])
print("  before | mappings %d · with order in the path %d (rule: the request-mapping patterns of the dispatcher servlet; order = the path holds \"order\", case-blind)" % (len(ps), sum(1 for p in ps if "order" in p.lower())))'
  echo "  before | GET /kitchen -> $($CURL --http1.1 -sS -o $J/k.b -w '%{http_code}' "$(B 21026)/kitchen") · members $(python3 -I -c 'import json,sys; print(list(json.load(open(sys.argv[1]))))' $J/k.b) - the in-JVM counters (OrderQueue), not the list"
  echo "  before | the dev-only order classes (not run: Redis and MongoDB are not on the default run): $(cd before/tiffinbox-web/src/main/java/com/tiffinbox/web && ls KitchenOrder.java OrderDocument.java | paste -sd' ' -)"
  tbstop before 21026; }
c_change() {
  echo "== the modules, the change file by file"
  echo "  modules: $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' before/pom.xml | paste -sd' ' -) ($($G -c '<module>' before/pom.xml)) -> $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' after/pom.xml | paste -sd' ' -) ($($G -c '<module>' after/pom.xml))"
  echo "  poms against 0248b1c: $(cd .. && git diff --stat 0248b1c -- 'c9-tiffinbox/*pom.xml' | wc -l | awk '{ print ($1 == 0 ? "empty" : $1 " lines") }')"
  echo "  changed (derived: diff -rq before after/, the frozen trees - git status --short c9-tiffinbox gave the same list before the commit): $(diff -rq before/ after/ | sed -E 's#^Files before/(.*) and after/.* differ$#M \1#; s#^Only in after/(.*): (.*)$#A \1/\2#; s#^Only in after/: (.*)$#A \1#' | sort | paste -sd'~' - | sed 's/~/ · /g')"
  local f; for f in tiffinbox-core/src/main/resources/db/migration/V6__tiffin_order.sql tiffinbox-core/src/main/java/com/tiffinbox/OrderEntityRepository.java tiffinbox-web/src/main/java/com/tiffinbox/web/OrderPages.java tiffinbox-web/src/test/java/com/tiffinbox/web/OrderPagesTest.java; do
    echo "== $f (whole, md5 $(md5 -q after/$f))"; sed 's/^/    /' after/$f; done
  echo "  OrderEntity.java md5 $(md5 -q after/tiffinbox-core/src/main/java/com/tiffinbox/OrderEntity.java)"
  $G -E '^@(EntityScan|EnableJpaRepositories)' after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java | sed 's/^/  TiffinBoxApp | /'
  for k in 'offset(' Pageable PageRequest; do echo "  src/main grep $k: $(cd after && $G -rhF "$k" tiffinbox-web/src/main tiffinbox-core/src/main | $G -vcE '^[[:space:]]*(\*|//|/\*)' || true) code lines (Javadoc and comment lines aside: $(cd after && $G -rhF "$k" tiffinbox-web/src/main tiffinbox-core/src/main | $G -cE '^[[:space:]]*(\*|//|/\*)' || true))"; done
  echo "  handler orderPage: $(cd after && $G -rhE -A3 '@(Get|Post|Put|Patch|Delete|Request)Mapping' tiffinbox-web/src/main/java | $G -cE ' orderPage\(') occurrence(s) among the mapped handlers"
  echo "  the web jar's spring-data-jpa: $(ls .harness/after/$XD/lib | $G -E '^spring-data-jpa-' )"
  echo "  the web jar's Jackson databind majors: $(ls .harness/after/$XD/lib | $G -E 'jackson-databind' | paste -sd' ' -)"; }
c_table() {
  echo "== V6 by Flyway on a clean H2 and a clean PostgreSQL database (harness-joined, 21025, the harness's exposure flag)"
  local db; for db in h2 pg; do
    tb table-$db 21025 $db 1 --management.endpoints.web.exposure.include=health,prometheus,flyway
    echo "  $db | flyway $($CURL -s "$(B 21025)/actuator/flyway" | python3 -I -c 'import json,sys; d=json.load(sys.stdin); m=list(d["contexts"].values())[0]["flywayBeans"]["flyway"]["migrations"]; print([x["version"] for x in m])')"
    $CURL -s "$(B 21025)$API?sort=oldest&size=50" > $J/t.b
    python3 -I -c '
import json,sys,collections
d=json.load(open(sys.argv[1]))["items"]; c=collections.Counter(i["placedAt"][:16] for i in d)
print("  %s | rows %d · placed_at minutes %d · rows per minute %s (read through the route, oldest first, size 50)" % (sys.argv[2], len(d), len(c), [c[k] for k in sorted(c)]))' $J/t.b $db
    [ $db = pg ] && echo "  pg | psql: flyway_schema_history $(psq u13db$NDB "select string_agg(version || ' ' || success, ', ' order by installed_rank) from flyway_schema_history") · tiffin_order rows $(psq u13db$NDB 'select count(*) from tiffin_order') · minutes with two rows $(psq u13db$NDB 'select count(*) from (select placed_at from tiffin_order group by placed_at having count(*) = 2) t')"
    $CURL -s "$(B 21025)/actuator/flyway" | python3 -I -c 'import json,sys; d=json.load(sys.stdin); m=list(d["contexts"].values())[0]["flywayBeans"]["flyway"]["migrations"]; print(" ".join(x["version"] + ":" + x["description"] for x in m))' > $J/hist-$db.txt
    tbstop table-$db 21025; done
  echo "  the two histories: $(cmp -s $J/hist-h2.txt $J/hist-pg.txt && echo equal || echo DIFFER) ($(cat $J/hist-h2.txt))"
  echo "== a column named value, on a scratch copy (.harness/need-value: V6's amount renamed value; the harness's copy), H2, 21023"
  copy after .harness/need-value
  sed -i '' -E 's/^    amount    INT/    value     INT/; s/\(customer, meal_type, amount, placed_at\)/(customer, meal_type, value, placed_at)/' .harness/need-value/tiffinbox-core/src/main/resources/db/migration/V6__tiffin_order.sql
  echo "  the copy's V6 names value $($G -cw value .harness/need-value/tiffinbox-core/src/main/resources/db/migration/V6__tiffin_order.sql) times (comments included)"
  guard "the value copy's build"
  bg "cd .harness/need-value && $MV -DskipTests clean package -pl tiffinbox-web -am" .harness/build-need-value.log
  [ "$RE" = 0 ] || die "the value copy did not build"; offl .harness/build-need-value.log
  rm -rf .harness/run/value; mkdir -p .harness/run/value/secrets/tiffinbox; (umask 077 && openssl rand -hex 16 > .harness/run/value/secrets/tiffinbox/shutdown-token)
  guard "the value copy's start"
  (cd .harness/run/value && exec perl -e '$SIG{INT}="DEFAULT"; alarm 120; exec @ARGV' java $JL -jar "$U/.harness/need-value/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" --tiffinbox.port=21023 > jvm.log 2>&1) & local p=$!; PIDS="$PIDS $p"
  wait $p; local rc=$?; PIDS=$(echo " $PIDS " | sed "s/ $p / /g")
  echo "  value | the scratch copy's start: $($G -oE 'org\.h2\.jdbc\.JdbcSQLSyntaxErrorException' .harness/run/value/jvm.log | head -1) (exit $rc; Started lines $($G -c 'Started TiffinBox' .harness/run/value/jvm.log))"
  echo "  value | $($G -oE 'Syntax error in SQL statement "[^"]{0,90}' .harness/run/value/jvm.log | head -1 | cut -c1-140)"; }
c_first() {
  echo "== page one, newest first, size 5 (harness-free: H2 on 21020, PostgreSQL on 21022; the SQL log of these JVMs)"
  pagereq h2 "page one newest" 21020 "?sort=newest&size=5" first-h2
  pagereq pg "page one newest" 21022 "?sort=newest&size=5" first-pg
  echo "  h2 | the page's placedAt values, masked: $(python3 -I -c 'import json,sys; print([i["placedAt"] for i in json.load(open(sys.argv[1]))["items"]])' $J/pg.b)"; }
c_next() {
  echo "== next: the cursor decoded once (its signature masked), then page two through it, both databases"
  local db port n; for db in h2 pg; do [ $db = h2 ] && port=21020 || port=21022
    $CURL -s "$(B $port)$API?sort=newest&size=5" > $J/n1.b; n=$(nextof $J/n1.b)
    echo "  $db | decoded once | $(python3 -I -c 'import sys,base64; b=sys.argv[1].split(".")[0]; print(base64.urlsafe_b64decode(b + "=" * (-len(b) % 4)).decode())' "$n") . <signature masked> · length ${#n}"
    pagereq $db "page two" $port "?sort=newest&size=5&cursor=$n" first-$db; done; }
c_refuse() {
  echo "== every refusal, both databases (harness-free, 21020 and 21022), each body whole"
  local db port n t; for db in h2 pg; do [ $db = h2 ] && port=21020 || port=21022
    $CURL -s "$(B $port)$API?sort=newest&size=5" > $J/r1.b; n=$(nextof $J/r1.b)
    t=$(python3 -I -c 'import sys; n=sys.argv[1]; print(n[:5] + ("A" if n[5] != "A" else "B") + n[6:])' "$n")
    prq $db tampered $port "?cursor=$t"
    prq $db notacursor $port "?cursor=notacursor"
    prq $db truncated $port "?cursor=${n:0:100}"
    prq $db "reused sort=oldest" $port "?sort=oldest&cursor=$n"
    prq $db "reused mealType=VEG" $port "?mealType=VEG&cursor=$n"
    prq $db "reused mealType=null (the string)" $port "?mealType=null&cursor=$n"
    prq $db sort=nosuch $port "?sort=nosuch"
    prq $db colour=red $port "?colour=red"
    prq $db customer=Ravi $port "?customer=Ravi"
    prq $db mealType=PIZZA $port "?mealType=PIZZA"
    prq $db "mealType=null (no cursor)" $port "?mealType=null"
    prq $db size=0 $port "?size=0"; prq $db size=-1 $port "?size=-1"; prq $db size=51 $port "?size=51"; prq $db size=abc $port "?size=abc"
    echo "  $db | size=50 -> $($CURL -s -o $J/s.b -w '%{http_code}' "$(B $port)$API?size=50") · items $(python3 -I -c 'import json,sys; print(len(json.load(open(sys.argv[1]))["items"]))' $J/s.b)"
    echo "  $db | mealType=VEGAN -> $($CURL -s -o $J/s.b -w '%{http_code}' "$(B $port)$API?mealType=VEGAN&size=50") · ids $(python3 -I -c 'import json,sys; print([i["id"] for i in json.load(open(sys.argv[1]))["items"]])' $J/s.b)"; done
  echo "  the JVMs' logs: exceptions logged for these requests (h2 / pg): $($G -cE 'Exception' .harness/run/first-h2/jvm.log || true) / $($G -cE 'Exception' .harness/run/first-pg/jvm.log || true)"; }
c_pageable() {
  echo "== the harness's Pageable route (Spring Data's own web support; harness-joined, 21025): three fresh JVMs on H2, three fresh databases on PostgreSQL"
  local db i; for db in h2 pg; do : > $J/ties-$db.txt
    for i in 1 2 3; do tb pageable-$db-$i 21025 $db 1 > $J/tb.out; $G -oE 'up on [0-9]+ \([a-z0-9]+' $J/tb.out | sed "s/^/  $db | run $i /"
      local n0; n0=$(wc -l < .harness/run/pageable-$db-$i/jvm.log | tr -d ' ')
      $CURL -s "$(B 21025)/probe/u13/orders/pageable?sort=amount,desc&size=5" > $J/pa.b
      echo "  ~ $db | run $i | ties $(python3 -I -c 'import json,sys; print([i["id"] for i in json.load(open(sys.argv[1]))["items"]])' $J/pa.b)"
      python3 -I -c 'import json,sys; print([i["id"] for i in json.load(open(sys.argv[1]))["items"]])' $J/pa.b >> $J/ties-$db.txt
      [ $i = 1 ] && { echo "  $db | SQL | $(tail -n +$((n0 + 1)) .harness/run/pageable-$db-$i/jvm.log | $G -E 'org\.hibernate\.SQL' | $G 'tiffin_order' | $G -v 'count(' | tail -1 | sed -E 's/.*org\.hibernate\.SQL *: //')"
        echo "  $db | sort=nosuch -> $($CURL -s -o $J/pn.b -w '%{http_code} %{content_type}' "$(B 21025)/probe/u13/orders/pageable?sort=nosuch") | $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); d["timestamp"]="<masked>"; print(json.dumps(d))' $J/pn.b)"
        echo "  $db | the JVM's log: $($G -oE 'PropertyReferenceException: No property .nosuch. found for type .[A-Za-z]+.' .harness/run/pageable-$db-$i/jvm.log | head -1)"; }
      QUIET=1 tbstop pageable-$db-$i 21025; done
    echo "  ~ $db | distinct orders $(sort -u $J/ties-$db.txt | wc -l | tr -d ' ') over $(wc -l < $J/ties-$db.txt | tr -d ' ') fresh $( [ $db = h2 ] && echo JVMs || echo databases)"; done; }
c_walk() {
  echo "== four walks x two databases (harness-joined, 21025; each walk a fresh JVM and a fresh database): pages of 5, the harness's insert of 2 rows between page 1 and page 2"
  local db s m; for db in h2 pg; do for s in newest oldest; do for m in offset cursor; do
    tb walk-$db-$s-$m 21025 $db 1 > /dev/null
    python3 -I harness/walk.py 21025 "$(echo $db | tr a-z A-Z)" $s $m | sed 's/^/  /'
    QUIET=1 tbstop walk-$db-$s-$m 21025; done; done; done
  python3 -I - .harness/cap-walk.raw <<'PY'
import re, sys
t = open(sys.argv[1]).read().splitlines()
for i, l in enumerate(t):
    if l.startswith("  H2 sort=newest mode=offset"):
        pages = eval(t[i + 1].split("pages: ", 1)[1])
        print("  H2 | offset newest page two begins with page one's last two: %s (page one %s, page two %s)" % ("yes" if pages[1][:2] == pages[0][-2:] else "no", pages[0], pages[1]))
PY
  echo "  (the offset route is the harness's: placed_at and id both descending, RED #24; the cursor route is TiffinBox's: placed_at descending, id ascending)"; }
c_trap() {
  echo "== Course 7's offset-then-keyset on 4.1.3 (the harness's trap, harness-joined, 21025): JVM 1 runs B, A and C; JVM 2 runs A-prime alone; the SQL after each marker"
  local db; for db in h2 pg; do
    tb trap-$db-1 21025 $db 1 > /dev/null; for m in B A C; do $CURL -s "$(B 21025)/probe/u13/trap?mode=$m" > /dev/null; done; QUIET=1 tbstop trap-$db-1 21025
    tb trap-$db-2 21025 $db 1 > /dev/null; $CURL -s "$(B 21025)/probe/u13/trap?mode=Aprime" > /dev/null; QUIET=1 tbstop trap-$db-2 21025
    cat .harness/run/trap-$db-1/jvm.log .harness/run/trap-$db-2/jvm.log | awk -v db=$db '/^U13TRAP / { st = substr($0, 9); next } /org\.hibernate\.SQL/ && /tiffin_order/ && st != "" && st != "end" { sub(/.*org\.hibernate\.SQL *: /, ""); print "  " db " | " st " | " $0; st = "" }'; done; }
c_restart() {
  echo "== a cursor across a restart (harness-free starts on 21023, one at a time): a random key per start, then the same explicit key (a generated 0600 file, never printed)"
  (umask 077 && openssl rand -hex 32 > .harness/run/cursor-key) || die "the key file"
  local db n w; for db in h2 pg; do
    tb rs-$db-r1 21023 $db "" > $J/r.out; $CURL -s "$(B 21023)$API?sort=newest&size=5" > $J/rs.b; n=$(nextof $J/rs.b); QUIET=1 tbstop rs-$db-r1 21023
    tb rs-$db-r2 21023 $db "" >> $J/r.out; w=$($CURL -s -o $J/rs2.b -w '%{http_code} %{content_type}' "$(B 21023)$API?sort=newest&size=5&cursor=$n"); QUIET=1 tbstop rs-$db-r2 21023
    echo "  $db | random-key JVM 2 | the cursor of random-key JVM 1 -> $w | type $(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1])).get("type"))' $J/rs2.b)"
    KEY=.harness/run/cursor-key tb rs-$db-k1 21023 $db "" >> $J/r.out; $CURL -s "$(B 21023)$API?sort=newest&size=5" > $J/rs.b; n=$(nextof $J/rs.b); QUIET=1 tbstop rs-$db-k1 21023
    KEY=.harness/run/cursor-key tb rs-$db-k2 21023 $db "" >> $J/r.out; w=$($CURL -s -o $J/rs2.b -w '%{http_code} %{content_type}' "$(B 21023)$API?sort=newest&size=5&cursor=$n"); QUIET=1 tbstop rs-$db-k2 21023
    echo "  $db | same-key JVM 2 | the cursor of same-key JVM 1 -> $w | ids $(python3 -I -c 'import json,sys; print([i["id"] for i in json.load(open(sys.argv[1]))["items"]])' $J/rs2.b)"
    echo "  $db | cursor key: defaulted (random-key JVMs: $($G -c 'cursor key: defaulted' $J/r.out)) · set (same-key JVMs: $($G -c 'cursor key: set' $J/r.out)) - the key itself in no log ($(cat .harness/run/rs-$db-*/jvm.log | $G -cF "$(cat .harness/run/cursor-key)" || true) lines)"; done; }
c_spec() {
  echo "== the committed spec: regenerated in this commit; read here against the served document (after/, 21020, no harness)"
  local SF=after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json
  $CURL -s "$(B 21020)/v3/api-docs" > $J/served.json
  echo "  the committed file against the served document (servers removed): $(python3 -I -c '
import json,sys
d=json.load(open(sys.argv[1])); d.pop("servers",None)
print("equal" if json.dumps(d,indent=2,ensure_ascii=False)+"\n" == open(sys.argv[2],encoding="utf-8").read() else "differ")' $J/served.json $SF)"
  (cd .. && git show 0248b1c:c9-tiffinbox/tiffinbox-web/src/test/resources/openapi/tiffinbox.json) > $J/spec-before.json
  echo "  committed md5 before $(md5 -q $J/spec-before.json) · after $(md5 -q $SF) · bytes before $(wc -c < $J/spec-before.json | tr -d ' ') · after $(wc -c < $SF | tr -d ' ')"
  echo "  the diff against 0248b1c: $(diff $J/spec-before.json $SF | $G -c '^>') lines added, $(diff $J/spec-before.json $SF | $G -c '^<') removed"
  diff $J/spec-before.json $SF | $G '^[0-9]' | sed 's/^/  hunk /'
  python3 -I harness/ops9s3.py ops $J/spec-before.json > $J/ops-before.txt; python3 -I harness/ops9s3.py ops $SF > $J/ops-after.txt
  echo "  before: $(tail -1 $J/ops-before.txt) · after: $(tail -1 $J/ops-after.txt)"
  echo "  the old operations' ids before -> after: $( [ -z "$(diff <($G -E '^  [A-Z]+ ' $J/ops-before.txt) <($G -E '^  [A-Z]+ ' $J/ops-after.txt) | $G '^<')" ] && echo equal || echo differ)"
  diff <($G -E '^  [A-Z]+ ' $J/ops-before.txt) <($G -E '^  [A-Z]+ ' $J/ops-after.txt) | $G '^[<>]' | sed 's/^/  ops moved | /'
  printf '{}' > $J/empty.json; python3 -I harness/ops9s3.py ops $J/empty.json > /dev/null 2>&1; echo "  ops9s3.py on an empty spec: exit $? (refused)"
  echo "  operationIds unique: $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); i=[o.get("operationId") for v in d["paths"].values() for o in v.values()]; print("yes" if len(i)==len(set(i)) else "no")' $SF)"
  python3 -I harness/ops9s3.py media $SF /api/v1/orders | sed 's/^/  spec | /'
  local w4; $CURL --http1.1 -s -D $J/sw.h -o $J/sw.b "$(B 21020)$API"; w4=$($CURL -s -o /dev/null -w '%{content_type}' "$(B 21020)$API?sort=nosuch")
  echo "  spec vs wire | 200 $(python3 -I -c 'import json,sys; r=json.load(open(sys.argv[1]))["paths"]["/api/v1/orders"]["get"]["responses"]["200"]["content"]; k=list(r)[0]; print(k, r[k]["schema"]["$ref"].split("/")[-1])' $SF) · wire 200 $(tr -d '\r' < $J/sw.h | sed -n 's/^Content-Type: //p') members $(python3 -I -c 'import json,sys; print(list(json.load(open(sys.argv[1]))))' $J/sw.b) · schema properties $(python3 -I -c 'import json,sys; print(list(json.load(open(sys.argv[1]))["components"]["schemas"]["OrderPage"]["properties"]))' $SF)"
  echo "  spec vs wire | 400 $(python3 -I -c 'import json,sys; r=json.load(open(sys.argv[1]))["paths"]["/api/v1/orders"]["get"]["responses"]["400"]["content"]; k=list(r)[0]; print(k, r[k]["schema"]["$ref"].split("/")[-1])' $SF) · wire 400 $w4"
  echo "  the parameters: $(python3 -I -c 'import json,sys; print([(p["name"], p["schema"]["type"]) for p in json.load(open(sys.argv[1]))["paths"]["/api/v1/orders"]["get"]["parameters"]])' $SF)"
  echo "  OpenApiSpecTest on the regenerated file: $(python3 -I -c '
import sys,xml.etree.ElementTree as E
r=E.parse(sys.argv[1]).getroot(); print("tests %s failures %s errors %s" % (r.get("tests"), r.get("failures"), r.get("errors")))' .harness/after/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.OpenApiSpecTest.xml) (after/'s build)"
  echo "== the client rebuilt on the regenerated spec: before's client (-pl tiffinbox-client -am on a copy of before) and after/'s (its build)"
  copy before .harness/client-before; guard "before's client"
  bg "cd .harness/client-before && $MV -DskipTests clean package -pl tiffinbox-client -am" .harness/build-client-before.log; offl .harness/build-client-before.log
  local GB=.harness/client-before/tiffinbox-client/target/generated-sources/openapi GA=.harness/after/tiffinbox-client/target/generated-sources/openapi
  echo "  the client: FILES $($G -c '\.java$' $GB/.openapi-generator/FILES) -> $($G -c '\.java$' $GA/.openapi-generator/FILES) · build exit $RE (before's) / 0 (after/'s, its reactor)"
  diff <($G '\.java$' $GB/.openapi-generator/FILES) <($G '\.java$' $GA/.openapi-generator/FILES) | $G '^[<>]' | sed 's/^/  the client: files /'
  for f in $(cd $GA && $G '\.java$' .openapi-generator/FILES); do [ -f $GB/$f ] && { [ "$($G -v '^@Generated(' $GB/$f | md5 -q)" = "$($G -v '^@Generated(' $GA/$f | md5 -q)" ] && s="equal (the generator's @Generated date line aside)" || s=moved; } || s=new; echo "  the client: $f $s"; done
  echo "  the client: ApiApi.java orderPage: $($G -c 'orderPage(' $GA/src/main/java/com/tiffinbox/client/api/ApiApi.java) · the new operation's group: ApiApi (the first path segment, api)"; }
movedone() { local port=$1 m=$2 p=$3 w; shift 3; : > $J/mv.h; : > $J/mv.b
  w=$($CURL --http1.1 -sS -D $J/mv.h -o $J/mv.b -w '%{http_code} %{content_type} %{size_download}' --max-time 5 -X "$m" "$@" "$(B $port)$p" 2> /dev/null)
  local bm; bm=$(sed -E 's/"timestamp":"[^"]*"/"timestamp":"<masked>"/; s/"next":"[^"]*"/"next":"<cursor>"/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' $J/mv.b | md5 -q | cut -c1-12)
  w=$(echo "$w" | awk '{ print $1, $2 }')
  echo "  $SIDE | $m $p$( [ -n "${TAG:-}" ] && echo " [$TAG]") -> $w · Allow {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Aa]llow: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)} · Accept-Patch {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Aa]ccept-[Pp]atch: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)} · body $bm"; }
MPT='Content-Type: application/merge-patch+json'; JPT='Content-Type: application/json-patch+json'; CAPI=/api/v1/customers
movedside() { local side=$1 port=$2 a
  TREE=$side tb moved-$side $port h2 ""
  SIDE=$side
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
  movedone $port GET $API
  QUIET=1 tbstop moved-$side $port; }
c_moved() { echo "== U12's requests (its movedside list, copied; /v3/api-docs left out: the spec capture reads it, it moved by the new path) and the new route, on before (21026) and after/ (21020), H2, each its own JVM, no harness"
  movedside before 21026; movedside after 21020
  echo "== the jars per entry (unzip -lv: every entry's name and CRC)"
  local j t; for j in web core; do for t in before after; do
    if [ $j = web ]; then unzip -lv .harness/$t/tiffinbox-web/target/tiffinbox-web-1.0.0.jar; else unzip -lv .harness/$t/tiffinbox-core/target/tiffinbox-core-1.0.0.jar; fi | awk 'NF >= 8 && $1 ~ /^[0-9]+$/ { print $7, $8 }' | sort -k2 > $J/jar-$j-$t.txt; done
    python3 -I - $J/jar-$j-before.txt $J/jar-$j-after.txt $j <<'PY'
import sys
a = dict(l.split(" ", 1)[::-1] for l in open(sys.argv[1]).read().splitlines()); b = dict(l.split(" ", 1)[::-1] for l in open(sys.argv[2]).read().splitlines())
j = sys.argv[3]
print("  %s jar: entries before %d · after %d" % (j, len(a), len(b)))
print("  %s jar: entries only after has: %s" % (j, ",".join(sorted(set(b) - set(a))) or "none"))
print("  %s jar: entries only before has: %s" % (j, ",".join(sorted(set(a) - set(b))) or "none"))
mv = [k for k in sorted(set(a) & set(b)) if a[k] != b[k] and not k.endswith("/")]
print("  %s jar: shared entries whose CRC moved: %s" % (j, ",".join(mv) or "none"))
PY
  done
  echo "  BOOT-INF/lib names: before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ') · moved $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c '^[<>]' || true)"; }
c_seven() {
  echo "== the seven (c5-unit11/curlset.sh, no key header), each tree its own JVM, H2, no harness - not a witness for the new route: it sends nothing to /api/v1/orders"
  echo "  expected $S466"
  local s port i; for s in before after; do [ $s = before ] && port=21026 || port=21020
    TREE=$s tb seven-$s $port h2 "" > /dev/null
    sh $CURLSET $port .harness/run/seven-$s/secrets/tiffinbox/shutdown-token > $J/seven-$s.txt 2>&1
    i=0; while kill -0 "$(cat .harness/run/seven-$s/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 60 ] || break; sleep 0.05; done
    QUIET=1 tbstop seven-$s $port
    echo "  $s: the seven $(md5 -q $J/seven-$s.txt) ($(wc -l < $J/seven-$s.txt | tr -d ' ') lines)"; done
  echo "  the seven's paths (read off curlset.sh): $($G -oE '^req [A-Z]+ /[a-z]*' $CURLSET | awk '{ print $3 }' | paste -sd' ' -) and POST /shutdown - none under /api/"; }
oldsurface2() { local port=$1 out=$2 BB="http://127.0.0.1:$1" t=$U/$J/os
  printf 'name,mealsPerDay,pricePerMeal,mealType\nChitra,1,130,VEGAN\n' > "$t.csv"; : > "$out"
  one() { local label=$1; shift; local w rc
    w=$($CURL --http1.1 -sS -D "$t.h" -o "$t.b" -w '%{http_code} %{content_type} %{size_download}' --max-time 10 "$@" 2>"$t.e"); rc=$?
    { echo "== $label -> $w (curl exit $rc)"; tr -d '\r' < "$t.h" | sed -E 's/^(Date|date): .*/\1: <masked>/; s/(JSESSIONID=)[^;]*/\1<masked>/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g; s/^(Expires): .*/\1: <masked>/; s/^(Keep-Alive): .*/\1: <masked>/' | $G -v '^$'
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
    tr -d '\r' < "$t.h" | sed -E 's/^(Date|date): .*/\1: <masked>/; s/(JSESSIONID=)[^;]*/\1<masked>/; s/^(Keep-Alive): .*/\1: <masked>/' | $G -v '^$'; echo "body: $(tr -d '\r' < "$t.b" | tr '\n' '~')"; } >> "$out"
  one "GET /kitchen" "$BB/kitchen"
  one "GET /nowhere" "$BB/nowhere"
  one "POST /shutdown (no token, last)" -X POST "$BB/shutdown"
  rm -f "$t".*; }
c_surface() { local side port
  echo "== the old surface by count (U12's reader, copied), each tree its own JVM, H2, no harness - not a witness for the new route"
  echo "  expected $U4SURF"
  for side in before after; do [ $side = before ] && port=21026 || port=21020
    TREE=$side tb surface-$side $port h2 "" > /dev/null
    oldsurface2 $port $J/surface-$side.txt
    QUIET=1 tbstop surface-$side $port
    echo "  $side: the old surface $(md5 -q $J/surface-$side.txt) ($($G -c '^== ' $J/surface-$side.txt) requests, $(wc -l < $J/surface-$side.txt | tr -d ' ') lines)"; done
  echo "  before -> after/: $(cmp -s $J/surface-before.txt $J/surface-after.txt && echo equal || echo DIFFER)"
  echo "== the S9.14 plant (1/1 per run): after/ with Spring MVC's problem details off (--spring.mvc.problemdetails.enabled=false), 21024 - the check that can fail"
  tb surface-plant 21024 h2 "" --spring.mvc.problemdetails.enabled=false > /dev/null
  oldsurface2 21024 $J/surface-plant.txt; QUIET=1 tbstop surface-plant 21024
  echo "  ~ plant (21024, the S9.14 slot): the old surface $(md5 -q $J/surface-plant.txt) - $(cmp -s $J/surface-plant.txt $J/surface-after.txt && echo 'EQUAL (the plant was not seen)' || echo 'moved, as planted')"; }
c_inert() {
  echo "== the key header across this run's captures (request lines and bodies)"
  echo "  request lines naming the key header across the captures: $(cat .r-*.new 2> /dev/null | $G -ciF "$KW" || true)"
  echo "  the harness's insert (walk) goes through the harness's route, a POST under /probe/u13/: IdempotencyKeyFilter's table names POST /api/v1/customers/{name}/pauses only (read): $($G -c 'POST' after/tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java) POST lines in the filter"
  echo "  MockMvc runs: OrderPagesTest sends GETs only; no request of this unit carries the key"; }
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
cls() { python3 -I -c '
import sys,xml.etree.ElementTree as E
r=E.parse(sys.argv[1]).getroot(); print("  %s | class %s | tests %s failures %s errors %s skipped %s" % (sys.argv[2], sys.argv[3], r.get("tests"), r.get("failures"), r.get("errors"), r.get("skipped")))' "$1" "$2" "$3"; }
reactor() { $G -E '^\[INFO\] TiffinBox[A-Za-z ]* \.+ (SUCCESS|FAILURE|SKIPPED)' "$1" | sed -E 's/ \.+ / ... /; s/\[ *[0-9.:]+ (s|min)\]//; s/^\[INFO\] /  reactor: /; s/ *$//'; }
c_tests() { local p
  echo "== mvn -o clean package (tests on) on a copy of after/ (.harness/pkg): the whole reactor, Docker reachable"
  copy after .harness/pkg; copy after .harness/tests; copy after .harness/webonly; copy after .harness/need-mock; copy after .harness/need-its
  guard "mvn package"
  bg "cd .harness/pkg && $MV \"$AL\" clean package" .harness/pkg.log; local pre=$RE
  echo "  mvn package exit $pre"; reactor .harness/pkg.log
  for p in web client; do surefire .harness/pkg/tiffinbox-$p/target/surefire-reports "package | tiffinbox-$p"; done
  for c in OrderPagesTest ApiVersionTest TiffinBoxRestDocsTest OpenApiSpecTest TiffinBoxWebTest; do cls .harness/pkg/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.$c.xml package $c; done
  $G -E '^OrderPagesTest: ' .harness/pkg.log | sed 's/^/  printed | /'
  echo "== the Docker-free twin: after/'s own build (DOCKER_HOST=unix:///nonexistent/docker.sock, the run's first build)"
  for p in web client; do surefire .harness/after/tiffinbox-$p/target/surefire-reports "twin | tiffinbox-$p"; done
  echo "  slice TiffinBoxWebTest: before $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit12/README.md >/dev/null; python3 -I -c 'import re,sys; print(len(re.findall(r"^\s+@Test\b", open(sys.argv[1]).read(), re.M)))' before/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java) · after $(python3 -I -c 'import xml.etree.ElementTree as E,sys; print(E.parse(sys.argv[1]).getroot().get("tests"))' .harness/pkg/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.TiffinBoxWebTest.xml) (before: its @Test lines; after: Surefire's XML)"
  echo "  web tests before (unit 12's values): $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit12/README.md | $G -oE 'web_tests=[0-9]+' | head -1 | cut -d= -f2) · new @Test lines $($G -cE '^ +@Test$' after/tiffinbox-web/src/test/java/com/tiffinbox/web/OrderPagesTest.java)"
  echo "  test files moved before -> after: $(for p in $(cd before && find tiffinbox-web/src/test -type f | sort); do cmp -s before/$p after/$p || basename $p; done | paste -sd, -) · new: $(cd after && for p in $(find tiffinbox-web/src/test -type f | sort); do [ -e ../before/$p ] || basename $p; done | paste -sd, -)"
  echo "  the test classes that send /api/v1/ (grep -l): $( (cd after && $G -rl '/api/v1/' tiffinbox-web/src/test/java) | sed 's#.*/##; s#\.java$##' | sort | paste -sd, -)"
  echo "== mvn -o clean verify on a copy of after/ (.harness/tests): Surefire's tests on H2 in memory, then the five ITs on PostgreSQL 18.6 in Testcontainers containers (21280-21284)"
  for p in 21280 21281 21282 21283 21284 18881 18882 18883 18884; do [ "$(listeners $p)" = 0 ] || die "$p is bound before verify"; done
  guard "mvn verify"
  bg "cd .harness/tests && DOCKER_HOST=\"$DH\" TESTCONTAINERS_RYUK_DISABLED=true $MV \"$AL\" clean verify" .harness/verify.log; local vre=$RE
  reactor .harness/verify.log
  python3 -I - .harness/tests/tiffinbox-web/target/failsafe-reports .harness/tests/tiffinbox-web/target/surefire-reports-it $vre <<'PY'
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
  $G -E '^IT flyway_schema_history|^JDBC IT flyway_schema_history' .harness/verify.log | sed 's/^/  printed | /'
  echo "  Testcontainers containers after: $(dk ps -aq --filter label=org.testcontainers=true | wc -l | tr -d ' ')"
  echo "== the hand-built form: mvn -o clean package -pl tiffinbox-web -am on a copy of after/ (.harness/webonly), Docker-free"
  guard "the web-only form"
  bg "cd .harness/webonly && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package -pl tiffinbox-web -am" .harness/webonly.log
  surefire .harness/webonly/tiffinbox-web/target/surefire-reports "webonly | tiffinbox-web"
  echo "== the two measured needs, each on a scratch copy of after/ (the harness's copies)"
  python3 -I - .harness/need-mock/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java <<'PY'
import sys
p = sys.argv[1]; s = open(p).read(); s2 = "\n".join(l for l in s.split("\n") if "OrderEntityRepository orders;" not in l); open(p, "w").write(s2); print("  need | the slice copy: the @MockitoBean OrderEntityRepository line removed (%d lines removed)" % (s.count("\n") - s2.count("\n")))
PY
  guard "the slice need"
  bg "cd .harness/need-mock && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package -pl tiffinbox-web -am -Dtest=TiffinBoxWebTest -Dsurefire.failIfNoSpecifiedTests=false" .harness/need-mock.log
  echo "  need | without the slice mock: exit $RE · TiffinBoxWebTest $(python3 -I -c 'import xml.etree.ElementTree as E,sys; r=E.parse(sys.argv[1]).getroot(); print("tests %s errors %s" % (r.get("tests"), r.get("errors")))' .harness/need-mock/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.TiffinBoxWebTest.xml) · $($G -oE "required a bean of type 'com\.tiffinbox\.OrderEntityRepository'" .harness/need-mock/tiffinbox-web/target/surefire-reports/*.txt .harness/need-mock.log 2> /dev/null | head -1 | sed 's/.*:required/required/')"
  python3 -I - .harness/need-its <<'PY'
import sys, re
for rel, el in (("tiffinbox-web/src/test/java/com/tiffinbox/CustomerEntityRepositoryIT.java", ', "6 tiffin order true"'), ("tiffinbox-web/src/test/java/com/tiffinbox/jdbc/CustomerAggregatesIT.java", ', "6 true"')):
    p = sys.argv[1] + "/" + rel; s = open(p).read(); s2 = s.replace(el, ""); open(p, "w").write(s2); print("  need | %s: the V6 element removed (%d)" % (rel.split("/")[-1], s.count(el)))
PY
  guard "the IT need"
  bg "cd .harness/need-its && DOCKER_HOST=\"$DH\" TESTCONTAINERS_RYUK_DISABLED=true $MV \"$AL\" clean package -pl tiffinbox-web -am -Dtest=CustomerEntityRepositoryIT,CustomerAggregatesIT -Dsurefire.failIfNoSpecifiedTests=false" .harness/need-its.log
  echo "  need | without the two IT edits (the two Flyway ITs alone, -Dtest, on PostgreSQL in their containers, mvn package): exit $RE · $(python3 -I -c '
import sys,glob,xml.etree.ElementTree as E
o=[]
for f in sorted(glob.glob(sys.argv[1]+"/TEST-*.xml")+glob.glob(sys.argv[2]+"/TEST-*.xml")):
    r=E.parse(f).getroot(); o.append("%s failures %s" % (r.get("name").split(".")[-1], r.get("failures")))
print(" · ".join(o))' .harness/need-its/tiffinbox-web/target/surefire-reports .harness/need-its/tiffinbox-web/target/surefire-reports-it)"
  echo "  Testcontainers containers after: $(dk ps -aq --filter label=org.testcontainers=true | wc -l | tr -d ' ')"
  echo "  downloads across the builds: $(cat .harness/pkg.log .harness/verify.log .harness/webonly.log .harness/need-mock.log .harness/need-its.log .harness/build-after.log .harness/build-before.log | $G -cE 'Download(ing|ed) from ' || true)"
  echo "  BOOT-INF/lib: before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ')"; }
exrun() { local v=$1 sh=$2 o cmd
  guard "the exercise, $v, $sh"
  rm -rf .harness/exercise/tree; copy after .harness/exercise/tree
  case $v in broken) cmd='sh break.sh "$0" > /dev/null && sh check.sh "$0"' ;; solved) cmd='sh break.sh "$0" > /dev/null && sh apply.sh "$0" > /dev/null && sh check.sh "$0"' ;; *) cmd="sh break.sh \"\$0\" > /dev/null && HOW=$v sh apply.sh \"\$0\" > /dev/null && sh check.sh \"\$0\"" ;; esac
  if [ $sh = bash ]; then o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21028 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock bash -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1)
  else o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21028 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock /bin/zsh -f -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1); fi
  local pre="  $v $sh |"; [ $v = broken ] || [ $v = solved ] || pre="  ~ $v $sh |"
  printf '%s\n' "$o" | sed -E "s/127\.0\.0\.1:21028/127.0.0.1:<port>/g; s/^/$pre /"
  [ ! -f exercise/check.build.log ] || offl exercise/check.build.log
  [ "$(listeners 21028)" = 0 ] || die "the exercise left something listening on 21028"; }
c_exercise() { local v sh
  rm -rf .harness/exercise; mkdir -p .harness/exercise
  for v in broken solved; do for sh in bash zsh; do echo "  == $v, $sh"; exrun $v $sh; done; done
  if [ "$RUNNO" = 1 ] || [ "$RUNNO" = 0 ]; then for v in unboundcursor rawsort fixedelsewhere typed404; do exrun $v bash; done; fi
  rm -rf exercise/check.run; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.b exercise/check.h
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures${DEVCAPS:+ (DEVELOPMENT: only $DEVCAPS - not a run of record)}"
cap advisory c_advisory
guard "PostgreSQL's container"
bg "dk run -d --pull never --name $CN -p 127.0.0.1:21021:5432 -e POSTGRES_DB=tiffinbox -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust $IMG" .harness/docker-run-pg.log
[ "$RE" = 0 ] || die "the PostgreSQL container did not start: $(head -3 .harness/docker-run-pg.log)"; PGUP=1; MINE="${MINE:-} 21021"
i=0; until dk exec $CN pg_isready -U tiffinbox -h 127.0.0.1 > /dev/null 2>&1 && [ "$(dk logs $CN 2>&1 | $G -c 'database system is ready to accept connections')" -ge 2 ]; do i=$((i + 1)); [ $i -lt 300 ] || die "PostgreSQL never became ready"; sleep 0.2; done
echo "  $CN up on 127.0.0.1:21021 ($IMG, --pull never, trust on 127.0.0.1 alone: the port published there only) · $(dk exec $CN postgres --version)"
cap before c_before
cap change c_change
cap table c_table
tb first-h2 21020 h2 "" > .harness/first-h2.up; tb first-pg 21022 pg "" > .harness/first-pg.up
cat .harness/first-h2.up .harness/first-pg.up
cap first c_first
cap next c_next
cap refuse c_refuse
cap spec c_spec
tbstop first-h2 21020; tbstop first-pg 21022
cap pageable c_pageable
cap walk c_walk
cap trap c_trap
cap restart c_restart
cap moved c_moved
cap seven c_seven
cap surface c_surface
dk rm -fv $CN > /dev/null; PGUP=""; MINE=$(echo " ${MINE:-} " | sed "s/ 21021 / /g"); echo "  $CN removed (rm -fv)"
cap tests c_tests
cap exercise c_exercise
cap inert c_inert
echo "== plants (each made to FAIL first on a copy of this run's capture; harness/chk13.py plants)"
PL=$(ck plants .) || die "a plant was not caught: $(printf '%s\n' "$PL" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$PL" | $G '^ok ' | sed 's/^ok /  /'
PLV=$(printf '%s\n' "$PL" | sed -n 's/^VALUES //p')

# ---- the end: the sweep, the values, the published hashes -------------------------------------------------------------------------------
[ -z "$(echo $PIDS)" ] || die "a JVM of this run is still running: $PIDS"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
[ -z "$(dk ps -aq --filter label=org.testcontainers=true)" ] || die "a Testcontainers container of this run is left"
[ -z "$(dk ps -aq --filter name=^/c9u13-)" ] || die "a c9u13-* container is left"
NI1=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI1" = "$NI0" ] && [ "$VOL1" = "$VOL0" ] || die "R.322: images $NI0 -> $NI1, volumes $VOL0 -> $VOL1"
AD1=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true); [ "$AD1" = "$AD" ] || die "the anchor moved during the run"
pin before-tree before; pin after-tree after
MDB=$(find . ../c9-tiffinbox ../c9-unit12 -name '*.mv.db' -not -path './.harness/*' -not -path '../c9-unit12/.harness/*' 2> /dev/null | wc -l | tr -d ' ')
[ "$MDB" = 0 ] || die "an H2 file outside .harness/"
[ -z "$(ls exercise | $G -v -xE 'README.md|SOLUTION.md|apply.sh|break.sh|check.sh')" ] || die "the exercise left a file in exercise/"
VALS="$VALS
plants: $PLV
build: seed_files=$NF0 seed_bytes=$NB0 central_only=$CO"
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
[ -n "${DEVCAPS:-}" ] && { echo "c9-unit13: DEVELOPMENT run ($DEVCAPS) - nothing published"; exit 2; }
VO=$(ck values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; [ -n "${NOPIN:-}" ] || die "README.md's values block is not this run's"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM of this run, ports free, no container left, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1 · the anchor against after/ as at the start · the tree pins · *.mv.db outside .harness 0"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit13: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit13: every capture = published ($NCAPS) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"
