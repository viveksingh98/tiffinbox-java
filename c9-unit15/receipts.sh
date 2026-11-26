#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 15 "HATEOAS: The Argument" - this unit's receipts. NO anchor change (Section 3's third unit, a harness unit):
# before and after are both links whose text is ../c9-unit14/after (U14's frozen after); c9-tiffinbox is not touched.
# The harness's copy (.harness/hcopy/, never tracked): an rsync of before plus ONE pom line in tiffinbox-web - the dependency
# spring-boot-starter-hateoas (no version: Boot 4.1.3 manages it). The harness (never in a jar, the module, before or c9-tiffinbox):
# probe.u15.* (U15Config, U15Hal, U15Moved compiled twice - build A /probe/people, build B /probe/members - and U15Placeholder),
# compiled by javac against the copy's extracted lib/ and joined by --spring.main.sources on a harness-joined start only.
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5; lines starting "  ~" are run-variant
# and left out of the hash - the S9.14 plant's own line; the exercise's refused variants run on every run and are hashed):
#   advisory    the S9.36 read filed for the batch day (ADV3), verified, before any build
#   before      before's harness-free JVM (21043): the shipped answers, the harness's routes 404, the mappings, no hateoas jar
#   pin         the copy's jars: Spring HATEOAS's version and its HAL package's Jackson references, the BOM's line
#   starter     the copy built WITH its tests beside a same-run build of before WITH its tests; the jars added; the jar's entries
#   cost        the bytes a link adds (21040, harness-joined): one customer with and without links, four, the host they carry
#   moved       the harness's member route at two builds (21040 A, 21045 B), the harness's two clients, the access logs
#   literal     ops9s3.py on before's committed spec and on its served one (21043), and on the built client's PATH_* constants
#   final       the final-controller census by its printed rule; methodOn() and the Method form on the final CustomerReads
#   placeholder a ${...} mapping: the link it writes, and that link followed (21040), the property unset and set
#   seven       c5-unit11's seven on before (21043) and on the copy without the harness (21041)
#   surface     the old surface by count on the same two, the S9.14 plant (21042)
#   inert       the key header across this run's captures
#   exercise    build.sh, check.sh, apply.sh on 21048, bash and zsh -f, H2; the four refused variants under bash
# Ports (U15's band, 21040-21049): 21040 the copy + harness (build A, the placeholder) · 21041 the copy without the harness · 21042 the
# S9.14 plant · 21043 before · 21045 the copy + harness build B · 21048 the exercise · 21044, 21046, 21047 and 21049 never bound. No
# PostgreSQL, no container, no verify (21280-21284 stay free). Every store on 127.0.0.1; every curl --noproxy '*' --http1.1.
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
PIDS=""; INTR=""; mpid=""
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in $mpid $PIDS; do [ -z "$p" ] || killtree "$p"; done; for p in $mpid $PIDS; do if kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; [ -z "$INTR" ] || rm -f .r-*.new; rmdir .r-lock 2> /dev/null || rm -rf .r-lock; true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git unzip /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|SPRINGDOC_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_CONTEXT|HOW)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit15 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }') · run $RUNNO"

# ---- gates before anything is built: the folder, the links, the pins, the anchor note, the static check, the prose, the exercise ----------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk15.py dur9.py follow.py ops9s3.py s915.py src tree15.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
HSRC='probe/u15/U15Config.java probe/u15/U15Hal.java probe/u15/U15Moved.java probe/u15/U15Placeholder.java'
[ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$HSRC" ] || die "harness/src holds another file, or misses one"
for f in walk.py loc9.py seal9.py cdp.mjs cdp9.mjs specwire9.py mirror src/probe/u14 src/probe/u13 src/probe/u15/Gzip14.java src/probe/u15/U14Fields.java src/probe/u15/U14Config.java; do [ ! -e harness/$f ] || die "harness/$f: an earlier unit's instrument this unit does not carry"; done
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md apply.sh build.sh check.sh client.py' ] || die "exercise/ holds another file, or misses one: $(ls exercise | paste -sd' ' -)"
for t in before after; do [ -L $t ] && [ "$(readlink $t)" = ../c9-unit14/after ] || die "$t must be a link whose text is exactly ../c9-unit14/after"; done
for t in before after; do [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-client/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/"; true; done
echo "  before -> $(readlink before) · after -> $(readlink after) (two links, the text exact; no anchor change) · no secrets/, target/ or .m2-demo/ through either · harness/: no walk.py, seal9.py, cdp.mjs, cdp9.mjs, loc9.py, specwire9.py, mirror/, U13's or U14's harness classes, Gzip14.java"
$G -v '^ *#' harness/src/probe/u15/*.java | $G -q 'Thread\.sleep' && die "R.412: a Thread.sleep in the harness"
PH_=$(md5 -q "$PK3/instruments/probe-src/ProbeHal.java"); [ "$PH_" = 02f08c8deb56463da2dc09d8590e5c93 ] || die "the probe's ProbeHal.java is not 02f08c8d (its md5 $PH_)"
PM_=$(md5 -q "$PK3/instruments/probe-src/ProbeMoved.java"); [ "$PM_" = 7a322ca6b7e16a87d748e9dff701754a ] || die "the probe's ProbeMoved.java is not 7a322ca6 (its md5 $PM_)"
PF_=$(md5 -q "$PK3/instruments/follow.py"); [ "$PF_" = 93e11e4c98cae60e8566aa7464555fa1 ] || die "the probe's follow.py is not 93e11e4c (its md5 $PF_)"
OP=$(md5 -q "$BK3/instruments/ops9s3.py"); [ "$OP" = 8f062a0e5e872c478579756a8426c012 ] || die "BLUE's ops9s3.py is not 8f062a0e"
[ "$(md5 -q harness/ops9s3.py)" = "$OP" ] || die "harness/ops9s3.py is not BLUE's instrument, byte for byte"
nd() { echo "  $3 against the probe's $(basename "$1") (md5 $(md5 -q "$1"), asserted before the diff): the named diff md5 $(diff "$1" "$2" | md5 -q), $(diff "$1" "$2" | $G -c '^[<>]') lines ($4) · $(basename "$2") md5 $(md5 -q "$2")"; }
nd "$PK3/instruments/probe-src/ProbeHal.java" harness/src/probe/u15/U15Hal.java U15Hal.java "the package probe.u15, the class name, the label, CustomerNotFound -> ResponseStatusException 404, CustomerReads reached by reflection (package-private), the non-final self link added to the final route's answer; the routes' paths KEPT"
nd "$PK3/instruments/probe-src/ProbeMoved.java" harness/src/probe/u15/U15Moved.java U15Moved.java "the package, the class name, the label, the member route's path a LITERAL constant ROUTE (/probe/people), joined only for leg moved; /probe/entry KEPT"
nd "$PK3/instruments/probe-src/ProbeMoved.java" harness/src/probe/u15/U15Placeholder.java U15Placeholder.java "the package, the class name, the label, joined only for leg placeholder; the placeholder mapping KEPT as the probe's"
nd "$PK3/instruments/follow.py" harness/follow.py follow.py "the labels, the answer's members and Content-Type printed, the port masked; the two clients' requests KEPT"
echo "  ops9s3.py = BLUE's (md5 $OP, byte for byte; it refuses an empty spec and a directory with no constant) · U15Config.java md5 $(md5 -q harness/src/probe/u15/U15Config.java)"
[ "$(sed -n '5,$p' harness/tree15.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit14/harness/tree14.py | md5 -q)" ] || die "harness/tree15.py's code is not tree14.py's"
for u in 01 02 03 04 05 06 07 08 09 10 11 12 13 14; do [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit$u/harness/dur9.py)" ] || die "harness/dur9.py is not ../c9-unit$u's copy"; done
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"
  [ ! -f "$C9R/_builders/dur9.py" ] || [ "$(md5 -q "$C9R/_builders/dur9.py")" = "$D9" ] || die "harness/dur9.py is not C9/_builders/dur9.py"
  TT=$(python3 -I -c 'import ast,sys
for n in ast.parse(open(sys.argv[1]).read()).body:
    if isinstance(n, ast.Assign) and getattr(n.targets[0], "id", "") == "TITLES":
        d = ast.literal_eval(n.value); print("|".join(d[k] for k in ("15", "01", "10", "07", "14", "12", "16")))' "$J9")
  [ "$(echo "$TT" | cut -d'|' -f1)" = "HATEOAS: The Argument" ] || die "java9_series.TITLES[\"15\"] is \"$(echo "$TT" | cut -d'|' -f1)\""
  echo "  the titles, read off the registry: Course 9's 15 \"$(echo "$TT" | cut -d'|' -f1)\" · the call-backs (by title only, R.224): $(echo "$TT" | cut -d'|' -f2- | sed 's/|/ · /g')"
else D9N="(the registry is not on this machine: U01-U14's copies are the pin)"; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit01-14's copies $D9N · tree15.py's code = tree14.py's"
XS1=$(sed -n '/^# --- XFAM_S9S1 begin ---$/,/^# --- XFAM_S9S1 end ---$/p' harness/s915.py | md5 -q); XS1U=$(sed -n '/^# --- XFAM_S9S1 begin ---$/,/^# --- XFAM_S9S1 end ---$/p' ../c9-unit14/harness/s914.py | md5 -q)
[ "$XS1" = "$XS1U" ] || die "s915.py's XFAM_S9S1 slice is not U14's s914.py's"
echo "  s915.py: XFAM_S9S1's slice md5 $XS1 = ../c9-unit14/harness/s914.py's · its XU15 family this unit's · lines outside XU15 = s914.py's but for the names: $(diff <(sed '/^XU14 = {/,/^u04 = u14$/d' ../c9-unit14/harness/s914.py) <(sed '/^XU15 = {/,/^u04 = u15$/d' harness/s915.py) | $G -c '^[<>]') lines differ"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit14/receipts.md5)
[ -n "$UA" ] || die "../c9-unit14/receipts.md5 has no after-tree line"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree15.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || { [ -n "${NOPIN:-}" ] && { echo "  $dir/: $got (NOPIN: no pin yet)"; return 0; }; die "receipts.md5 has no $nm line"; }
  [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit14/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree15.py $dir/ -> $got = receipts.md5's $nm line = ../c9-unit14/receipts.md5's after-tree line"; }
pin before-tree before; pin after-tree after
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after/ ../c9-tiffinbox 2>&1 || true)
echo "  after/ against ../c9-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures after/' )"
HF="harness/chk15.py harness/s915.py harness/tree15.py harness/dur9.py harness/ops9s3.py harness/follow.py $(for f in $HSRC; do printf 'harness/src/%s ' $f; done)exercise/client.py exercise/build.sh exercise/check.sh exercise/apply.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's scripts: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
ST=$(python3 -I -B harness/chk15.py static . receipts.sh) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
echo "  static (harness/chk15.py static): $(printf '%s\n' "$ST" | $G -c '^ok ') checks, FAIL 0"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s915.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U15 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s915, per sentence): /'
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b|<measure>' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
GL=$(python3 -I -B harness/chk15.py gloss README.md) || die "the gloss: $(printf '%s\n' "$GL" | $G '^FAIL' | head -3 | paste -sd';' -)"
echo "  the gloss: $(printf '%s\n' "$GL" | $G -c '^ok ') checks, FAIL 0 ($(python3 -I -B harness/chk15.py gloss-line))"
HOOK=$(python3 -I -B harness/chk15.py hook); EXQ=$(python3 -I -B harness/chk15.py exq); GLS=$(python3 -I -B harness/chk15.py gloss-line)
IL=$(python3 -I -B harness/chk15.py interleaved) || die "the brief's interleaved hooks and exercises: $IL"
echo "  $IL"
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S3B's Unit 15 Hook line), byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
HW=$(printf '%s\n' "$HOOK" | wc -w | tr -d ' '); EW=$(printf '%s\n' "${EXQ#Your turn: }" | wc -w | tr -d ' ')
[ "$HW" -le 25 ] && [ "$EW" -le 25 ] || die "a spoken line over 25 words (hook $HW, exercise $EW)"
echo "  the hook ($HW words) and the exercise's line ($EW words after 'Your turn:') byte for byte, extracted from S3B's Unit 15 (md5 $(md5 -q "$C9R/_briefs/UNIT-BRIEFS-S3-PAYLOADS.md"))"
printf '%s\n\n%s\n\n%s\n' "$HOOK" "$EXQ" "$GLS" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s915.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
printf '%s\n' "$SW" | tail -1 | $G -qE ' refused: 0$' || die "a refused reading in a spoken line: $(printf '%s\n' "$SW" | $G ' line ' | head -3 | paste -sd';' -)"
echo "  the hook, the exercise's line and the gloss through s915.py: refused 0"; rm -f .r-lock/spoken.md
TS="HATEOAS Explained: Links vs Hardcoded Paths in REST"
$G -qF "$TS" "$C9R/_briefs/UNIT-BRIEFS-S3-PAYLOADS.md" || die "the title for search is not S3B's"
TL=$(python3 -I -c 'import sys; print(len(sys.argv[1]))' "$TS"); [ "$TL" -le 60 ] || die "the title for search is over 60 characters"
echo "  the title for search (read, not edited here): \"$TS\" - $TL characters (<= 60)"
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
! $G -qE '(^|[^A-Za-z0-9_.-])path=|[$][{]?path([^A-Za-z0-9_]|$)' exercise/check.sh exercise/apply.sh exercise/build.sh || die "an exercise script names a variable path (zsh): rpath"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh exercise/check.sh exercise/apply.sh exercise/build.sh | $G -qwE "$K1|$K2" || die "a script names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket"
MVL=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -F '$MV ')
MVA=$(printf '%s\n' "$MVL" | $G -cF -- '-pl ' || true)
[ "$MVA" = 0 ] || die "R.391 / flag 21: a Maven build in receipts.sh with a -pl form (every build here is the whole reactor)"
KW='idempotency''-key'; KH=$($G -v '^ *#' receipts.sh exercise/check.sh exercise/apply.sh exercise/build.sh exercise/client.py harness/follow.py | $G -ciF "$KW" || true)
[ "$KH" = 0 ] || die "S9.21: a line of receipts.sh, the harness's clients or the exercise names the key header"
echo "  static: no kill by name; every docker call on the pinned socket (no container started here); every Maven build the whole reactor; no Thread.sleep in the harness; the key header named by no line"
mask() { awk -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(PE, "…"); gsub(P, "…"); gsub(QE, "…/.."); gsub(Q, "…/.."); gsub(H, "~")
    gsub(/127\.0\.0\.1:2104[0-9]/, "127.0.0.1:<port>"); gsub(/localhost:2104[0-9]/, "localhost:<port>")
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
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'took 812 ms' '"timestamp":"2026-11-01T08:09:00.123Z"' "$U/x $HOME/y" '[INFO] TiffinBox Web ...... SUCCESS [ 11.955 s]' '"href":"http://127.0.0.1:21040/probe/entry"' | mask)
[ "$(printf '%s\n' "$MP" | paste -sd'|' -)" = 'Started TiffinBoxServer in <t> (process running for <t>)|took <t>|"timestamp":"<time>"|…/x ~/y|[INFO] TiffinBox Web ...... SUCCESS [<t>]|"href":"http://127.0.0.1:<port>/probe/entry"' ] || die "the mask's self-test: $(printf '%s\n' "$MP" | paste -sd'|' -)"
echo "  masks: the log mask masked a Started line's times, a millisecond count, a timestamp, the folders, the home, a reactor line's time and a band port inside an href (self-test; a masked port is five characters shorter than <port>, so no byte count is taken from masked text)"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh); [ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SURF=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh); [ ${#U4SURF} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh (SURF=)"
U14V=$(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit14/README.md | $G -E '^(seven|surface): ' | $G -oE '(seven|surface)=[0-9a-f]{8}' | paste -sd' ' -)
[ "$U14V" = "seven=$(echo $S466 | cut -c1-8) surface=$(echo $U4SURF | cut -c1-8)" ] || die "U14's README values block ($U14V) is not the seven and the surface read off the receipts"
echo "  the seven: expected $S466 (../c7-unit31/receipts.sh's S466= line) · the old surface: expected $U4SURF (../c9-unit04/receipts.sh's SURF= line) · both = U14's values block ($U14V)"
for f in plain.b one____.b oneapplication_hal_json_.b oneapplication_json_.b all.b fin.b follow.txt follow-literal.txt generated-paths.txt; do
  [ -f "$PK3/captures/h35/$f" ] && echo "  probe | h35/$f md5 $(md5 -q "$PK3/captures/h35/$f") $(wc -c < "$PK3/captures/h35/$f" | tr -d ' ') B (read, not copied: the expectation, 1 run, port 21300)"; done
for f in B3-ops.txt B3-ops1.txt B3-ops2.txt B3-ops3.txt; do [ -f "$BK3/captures/$f" ] && echo "  BLUE | $f md5 $(md5 -q "$BK3/captures/$f") (read, not copied)"; done

# ---- docker, ports, the guard: the baselines ----------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' '); NC0=$(dk ps -aq 2> /dev/null | wc -l | tr -d ' ')
[ -z "$(dk ps -aq --filter name=^/c9u15- 2> /dev/null)" ] || die "a c9u15-* container exists before the run"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
BAND="21040 21041 21042 21043 21044 21045 21046 21047 21048 21049"
PORTS="18425 18881 18882 18883 18884 20578 20615 $BAND 21280 21281 21282 21283 21284"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
for p in $BAND; do [ -z "$(lsof -nP -iUDP:$p 2> /dev/null)" ] || die "UDP $p is bound"; done
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
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · containers $NC0 · nothing pulled, nothing started · no c9u15-* container · ports $PORTS free"

# ---- the trees, copied and built offline: before (through the link), the harness's copy; the harness, compiled twice ------------------
M2="$PWD/.m2-demo"
if [ ! -d "$M2" ]; then [ -d "$SEED" ] || die "the seed $SEED is missing"; cp -cR "$SEED" "$M2" 2> /dev/null || cp -R "$SEED" "$M2" || die "the seed could not be copied"; fi
NF0=$(find "$M2" -type f | wc -l | tr -d ' '); NB0=$(find "$M2" -type f -print0 | xargs -0 stat -f %z | awk '{ s += $1 } END { printf "%d", s }')
CO=$(find "$M2" -name _remote.repositories -print0 | xargs -0 $G -l 'central-only' 2> /dev/null | wc -l | tr -d ' ')
[ "$CO" = 0 ] || die "$CO _remote.repositories files in the seed copy still name central-only"
ART="org/springframework/boot/spring-boot-starter-hateoas/4.1.3 org/springframework/hateoas/spring-hateoas/3.1.4 tools/jackson/core/jackson-databind/3.1.8 org/springframework/boot/spring-boot-hateoas/4.1.3 org/springframework/plugin/spring-plugin-core/4.1.0"
for a in $ART; do [ -n "$(ls "$M2/$a" 2> /dev/null | $G -E '\.(jar|pom)$')" ] || die ".m2-demo holds no $a (no seed act here: report the coordinates)"; done
echo "  .m2-demo (a copy of the seed m2-seed-c9-s3): files $NF0 · bytes $NB0 · _remote.repositories naming central-only: $CO"
for a in $ART; do echo "  seed | $a | $(ls "$M2/$a" | $G -E '\.(jar|pom)$' | paste -sd' ' -)"; done
mkdir -p .harness; for d in before before-tests hcopy hcopy-tests hcA hcB srcB run work servers; do rm -rf .harness/$d; done
mkdir -p .harness/home .harness/run .harness/work
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy before .harness/before; copy before .harness/before-tests
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE 'Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" HOME=\"$U/.harness/home\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 900; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
AL="-DargLine=$JL -Dstdout.encoding=UTF-8 -Duser.home=../../home"
# the ONE pom edit of the harness's copy (printed in the starter capture): spring-boot-starter-hateoas after the webmvc starter
pomedit() { python3 -I - "$1" <<'PY'
import sys
p = sys.argv[1]; t = open(p, encoding="utf-8").read()
anchor = "      <artifactId>spring-boot-starter-webmvc</artifactId>\n    </dependency>\n"
if t.count(anchor) != 1: sys.exit("the pom's webmvc dependency was not found once")
add = ("    <!-- THE HARNESS'S COPY (Course 9 unit 15): Spring HATEOAS, managed by Boot 4.1.3 - this copy only, never before or c9-tiffinbox -->\n"
       "    <dependency>\n      <groupId>org.springframework.boot</groupId>\n      <artifactId>spring-boot-starter-hateoas</artifactId>\n    </dependency>\n")
open(p, "w", encoding="utf-8").write(t.replace(anchor, anchor + add))
PY
}
copy before .harness/hcopy; pomedit .harness/hcopy/tiffinbox-web/pom.xml || die "the harness's copy's pom edit failed"
copy before .harness/hcopy-tests; pomedit .harness/hcopy-tests/tiffinbox-web/pom.xml || die "the harness's copy's pom edit failed"
extract() { bg "cd .harness/$1 && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$1.log
  [ "$RE" = 0 ] || die ".harness/$1: the jar's extract failed"; }
guard "the build of before"
bg "cd .harness/before && $MV -DskipTests clean package" .harness/build-before.log
[ "$RE" = 0 ] || { tail -30 .harness/build-before.log | mask >&3; die ".harness/before did not build offline (exit $RE)"; }; offl .harness/build-before.log
echo "  built before offline (mvn -o -DskipTests clean package, the whole reactor - the generator runs in the client module; exit 0, Downloading/Downloaded from: 0)"
guard "the build of the harness's copy"
bg "cd .harness/hcopy && $MV -DskipTests clean package" .harness/build-hcopy.log
[ "$RE" = 0 ] || { tail -30 .harness/build-hcopy.log | mask >&3; die ".harness/hcopy did not build offline (exit $RE)"; }; offl .harness/build-hcopy.log
echo "  built the harness's copy offline (mvn -o -DskipTests clean package, the whole reactor; exit 0, Downloading/Downloaded from: 0)"
guard "the build of before WITH its tests"
bg "cd .harness/before-tests && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package" .harness/build-before-tests.log; BTRE=$RE; offl .harness/build-before-tests.log
guard "the build of the harness's copy WITH its tests"
bg "cd .harness/hcopy-tests && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package" .harness/build-hcopy-tests.log; HTRE=$RE; offl .harness/build-hcopy-tests.log
echo "  built before and the harness's copy WITH their tests, Docker-free (mvn -o clean package, the whole reactor; exits $BTRE and $HTRE - printed again in the starter capture)"
extract before; extract hcopy
CPA=".harness/hcopy/$XD/tiffinbox-web-1.0.0.jar:.harness/hcopy/$XD/lib/*"
mkdir -p .harness/hcA .harness/hcB; cp -R harness/src .harness/srcB
python3 -I - .harness/srcB/probe/u15/U15Moved.java <<'PY' || die "build B's edit failed"
import sys
p = sys.argv[1]; t = open(p, encoding="utf-8").read()
a = 'static final String ROUTE = "/probe/people/{name}";'
if t.count(a) != 1: sys.exit("the route's constant was not found once")
open(p, "w", encoding="utf-8").write(t.replace(a, 'static final String ROUTE = "/probe/members/{name}";'))
PY
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hcA -cp \"$CPA\" harness/src/probe/u15/*.java" .harness/javacA.log
[ "$RE" = 0 ] || die "the harness (build A) did not compile against the copy's jar: $(head -5 .harness/javacA.log)"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hcB -cp \"$CPA\" .harness/srcB/probe/u15/*.java" .harness/javacB.log
[ "$RE" = 0 ] || die "the harness (build B) did not compile against the copy's jar: $(head -5 .harness/javacB.log)"
echo "  the harness compiled twice against the copy's web jar and lib/ (build A $(find .harness/hcA -name '*.class' | wc -l | tr -d ' ') classes, build B $(find .harness/hcB -name '*.class' | wc -l | tr -d ' '), -parameters) - never in a jar"
B() { echo "http://127.0.0.1:$1"; }
J=.harness/work
ALP='%m %U%q %s %b "%{Accept}i" "%{Content-Type}o"'
# tb LABEL PORT TREE HC [args]: TiffinBox from the extracted jar of TREE (before | hcopy), from its own run folder with a generated
# token (0600, never printed), H2 in memory (fresh per JVM), waited for by its Started line. HC: "" = no harness, hcA / hcB = the
# harness joined (probe.u15.U15Config, build A or B). ACC=1: Tomcat's access log (the harness's pattern, unbuffered, into the run folder).
tb() { local label=$1 port=$2 t=$3 hx=$4 run=.harness/run/$1 src="" i=0; shift 4
  guard "TiffinBox $label"
  for q in 21044 21046 21047 21049; do [ "$(listeners $q)" = 0 ] && [ -z "$(lsof -nP -iUDP:$q 2> /dev/null)" ] || die "$q must stay free (TCP and UDP)"; done
  [ "$(listeners $port)" = 0 ] && [ -z "$(lsof -nP -iUDP:$port 2> /dev/null)" ] || die "$port is bound before $label"
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  local x="$U/.harness/$t/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  local ax=(); [ -n "${ACC:-}" ] && ax=(--server.tomcat.accesslog.enabled=true "--server.tomcat.accesslog.directory=$U/$run" --server.tomcat.accesslog.prefix=access --server.tomcat.accesslog.suffix=.log --server.tomcat.accesslog.rotate=false --server.tomcat.accesslog.buffered=false "--server.tomcat.accesslog.pattern=$ALP")
  if [ -n "$hx" ]; then cp="$cp:$U/.harness/$hx"; src="--spring.main.sources=probe.u15.U15Config"; fi
  echo "java -cp <tree $t>$( [ -n "$hx" ] && echo ":<harness $hx>") com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=$port $src $( [ -n "${ACC:-}" ] && echo '<the access log>') $*" > "$run/cmd"
  (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -cp "$cp" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port="$port" $src "${ax[@]}" "$@" > jvm.log 2>&1) &
  local p=$!; echo $p > "$run/pid"; PIDS="$PIDS $p"; MINE="${MINE:-} $port"
  while ! $G -q -E 'Started TiffinBox(App|Server) in' "$run/jvm.log" 2> /dev/null; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before its Started line"; }; i=$((i + 1)); [ $i -lt 900 ] || die "$label: no Started line"; sleep 0.1; done
  if [ -n "$hx" ]; then i=0; while ! $G -q '^U15 harness: joined' "$run/jvm.log"; do i=$((i + 1)); [ $i -lt 100 ] || die "$label: no U15 harness line"; sleep 0.05; done
  else $G -q '^U15 harness' "$run/jvm.log" && die "$label: a harness-free start printed the harness's line"; fi
  local dup; dup=$(tr ' ' '\n' < "$run/cmd" | $G -E '^--' | sed 's/=.*//' | sort | uniq -d | paste -sd, -); [ -z "$dup" ] || die "R.444: a flag twice on $label's command line ($dup)"
  echo "  $label up on $port (H2, tree $t$( [ -n "$hx" ] && echo ", the harness joined ($hx; its U15 harness line printed: $($G '^U15 harness' "$run/jvm.log" | sed 's/^U15 harness: joined //'))" || echo ", no harness (no U15 harness line)")$( [ -n "${ACC:-}" ] && echo ", the access log on")) · $(sed 's/ *$//' "$run/cmd")"; }
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
  local o e=0; o=$(python3 -I -B harness/chk15.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk15 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; [ -n "${DEVCAPS:-}${NOPIN:-}" ] && { echo "  (development: $nm's check failed, the run goes on)"; unpub="$unpub $nm"; } || die "$nm: its check failed (harness/chk15.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk15.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-11s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-11s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff .r-$nm.new against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }
# one LABEL PORT PATH DESC [curl args]: one GET; prints status, type, curl's size, the saved file's bytes and md5, Content-Length
one() { local lab=$1 port=$2 p=$3 d=$4 w; shift 4; : > $J/o.h; : > $J/o.b
  w=$($CURL --http1.1 -sS -D $J/o.h -o $J/o.b -w '%{http_code} %{content_type} %{size_download}' --max-time 10 "$@" "$(B $port)$p")
  local cl; cl=$(tr -d '\r' < $J/o.h | $G -i '^Content-Length:' | head -1 | sed -E 's/^[^:]*: *//'); cp $J/o.b "$J/$lab-$(echo "$p$d" | tr -c 'A-Za-z0-9' '_').b"
  echo "  $lab | GET $p$d -> $w · file $(wc -c < $J/o.b | tr -d ' ') B md5 $(md5 -q $J/o.b) · Content-Length ${cl:-none}"; }
acclog() { cat .harness/run/$1/access*.log 2> /dev/null | sed -E 's/^([A-Z]+ [^ ]*)- /\1 /; s/ +$//'; }   # %q prints - for no query: dropped
# hal FILE LABEL: the body's members in order, the hrefs' hosts, the _links member's bytes by the printed rule (read from the UNMASKED file)
hal() { python3 -I - "$1" "$2" <<'PY'
import json, re, sys
raw = open(sys.argv[1], "rb").read(); d = json.loads(raw)
def strip(o):
    if isinstance(o, dict): return {k: strip(v) for k, v in o.items() if k != "_links"}
    if isinstance(o, list): return [strip(v) for v in o]
    return o
compact = json.dumps(d, separators=(",", ":"), ensure_ascii=False).encode()
nolinks = json.dumps(strip(d), separators=(",", ":"), ensure_ascii=False).encode()
hrefs = re.findall(rb'"href":"([^"]*)"', raw)
hosts = sorted({re.match(rb"https?://[^/]+", h).group(0).decode() for h in hrefs})
emb = list(d.get("_embedded", {}).keys())
print("  %s | members %s · embedded %s · hrefs %d · hosts %s · bytes %d · re-serialized compact %s · without every _links member %d B · the _links members %d B" % (
    sys.argv[2], list(d), emb or "none", len(hrefs), ",".join(hosts), len(raw), "equal" if compact == raw else "DIFFERS", len(nolinks), len(raw) - len(nolinks)))
PY
}

# ---- the captures ----------------------------------------------------------------------------------------------------------------------
c_advisory() {
  echo "== S9.36: the read filed for the batch day (ADV3; not re-read: no network), before any build"
  echo "  fetched-at $(head -1 "$ADV/fetched-at.txt" | cut -c1-10) (the hour masked) · run date $(date '+%Y-%m-%d')"
  sed -n '2,$p' "$ADV/fetched-at.txt" | sed 's/^/  fetched | /'
  local n=0 v=0 f h; while read -r h f; do n=$((n + 1)); [ "$(md5 -q "$ADV/$f" 2> /dev/null)" = "$h" ] && v=$((v + 1)); done < <($G -vE '^\s*$' "$ADV/MD5SUMS.txt" | awk '$2 != "MD5SUMS.txt" { print $1, $2 }')
  echo "  MD5SUMS.txt: $n lines, $v verified (its own line left out)"
  echo "  spring rows $($G -c . "$ADV/spring-index-rows-2026-11-24.txt") · naming Spring Framework $($G -c 'Spring Framework' "$ADV/spring-index-rows-2026-11-24.txt" || true) · naming HATEOAS $($G -ci 'hateoas' "$ADV/spring-index-rows-2026-11-24.txt" || true)"
  echo "  tomcat page md5 $(md5 -q "$ADV/tomcat-security-11.html")"
  local a g; for a in org.springframework.hateoas:spring-hateoas org.springframework.boot:spring-boot-starter-hateoas org.springframework.boot:spring-boot-hateoas org.springframework.plugin:spring-plugin-core com.jayway.jsonpath:json-path net.minidev:json-smart org.apache.tomcat.embed:tomcat-embed-core tools.jackson.core:jackson-databind org.springframework:spring-web; do
    echo "  t3 tree | $a $($G -E "^$(echo $a | sed 's/\./\\./g'):jar:" "$ADV/probe-tree-t3-dependency-list.txt" | head -1 | awk -F: '{ print $4 }')"; done
  echo "  osv (second witness only): $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); r=d.get("results",[]); print("%d results, %d with vulns" % (len(r), sum(1 for x in r if x.get("vulns"))))' "$ADV/osv-result.json") · queries naming spring-hateoas $($G -c 'spring-hateoas' "$ADV/osv-query.json" || true)"
  echo "  verdict: no pin affected; evidence may proceed"; }
c_before() {
  echo "== before (21043, U14's after, H2, no harness; the exposure flag for /actuator/mappings)"
  tb before 21043 before "" --management.endpoints.web.exposure.include=health,prometheus,mappings
  one before 21043 /api/v1/customers/Ravi ""; one before 21043 /api/v1/customers ""; one before 21043 /customers ""
  one before 21043 /probe/hal/customers/Ravi " (Accept: application/hal+json)" -H 'Accept: application/hal+json'
  one before 21043 /probe/entry " (Accept: application/hal+json)" -H 'Accept: application/hal+json'
  $CURL -s "$(B 21043)/actuator/mappings" | python3 -I -c '
import json,sys
d=json.load(sys.stdin); ps=[]
for c in d["contexts"].values():
    for m in c["mappings"]["dispatcherServlets"]["dispatcherServlet"]:
        rc=(m.get("details") or {}).get("requestMappingConditions")
        if rc: ps += [p for p in rc.get("patterns", [])]
print("  before | mappings %d · with probe in the path %d (rule: the request-mapping patterns of the dispatcher servlet)" % (len(ps), sum(1 for p in ps if "probe" in p)))'
  echo "  before | BOOT-INF/lib names $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · naming hateoas $(ls .harness/before/$XD/lib | $G -ci hateoas || true)"
  tbstop before 21043; }
c_pin() {
  echo "== pin: the harness's copy's jars (its extracted BOOT-INF/lib) and the Boot BOM read off the seed copy"
  local L=.harness/hcopy/$XD/lib
  python3 -I - "$L" <<'PY'
import glob, os, re, sys, zipfile
L = sys.argv[1]
j = [f for f in os.listdir(L) if f.startswith("spring-hateoas-")]
print("  pin | the HATEOAS jars in lib/: %s" % " ".join(sorted(f for f in os.listdir(L) if "hateoas" in f)))
z = zipfile.ZipFile(os.path.join(L, j[0]))
mf = z.read("META-INF/MANIFEST.MF").decode()
print("  pin | %s MANIFEST Implementation-Version %s" % (j[0], re.search(r"Implementation-Version: (\S+)", mf).group(1)))
pre = "org/springframework/hateoas/mediatype/hal/"
cls = [n for n in z.namelist() if n.startswith(pre) and n.endswith(".class") and "/" not in n[len(pre):]]
t3 = sum(1 for n in cls if b"tools/jackson/databind" in z.read(n)); t2 = sum(1 for n in cls if b"com/fasterxml/jackson/databind" in z.read(n))
print("  pin | rule: the .class entries directly in %s; a class references a Jackson when its bytes hold the package's internal name" % pre)
print("  pin | HAL classes %d · referencing tools/jackson/databind %d · referencing com/fasterxml/jackson/databind %d" % (len(cls), t3, t2))
cls2 = [n for n in z.namelist() if n.startswith(pre) and n.endswith(".class")]
print("  pin | the same rule with the subpackages (%s**): classes %d · tools/jackson/databind %d · com/fasterxml/jackson/databind %d" % (pre, len(cls2), sum(1 for n in cls2 if b"tools/jackson/databind" in z.read(n)), sum(1 for n in cls2 if b"com/fasterxml/jackson/databind" in z.read(n))))
print("  pin | jackson in lib/: %s" % " ".join(sorted(f for f in os.listdir(L) if f.startswith(("jackson-databind", "jackson-core")))))
print("  pin | jackson in before's lib/: %s" % " ".join(sorted(f for f in os.listdir(L.replace("/hcopy/", "/before/")) if f.startswith(("jackson-databind", "jackson-core")))))
PY
  local bom; bom=$(ls "$M2/org/springframework/boot/spring-boot-dependencies/4.1.3/"*.pom)
  echo "  pin | the BOM spring-boot-dependencies-4.1.3.pom: $($G -E '<spring-hateoas\.version>' "$bom" | sed 's/^ *//')"
  echo "  pin | the starter's pom spring-boot-starter-hateoas-4.1.3.pom names: $($G -oE '<artifactId>[^<]+' "$M2/org/springframework/boot/spring-boot-starter-hateoas/4.1.3/spring-boot-starter-hateoas-4.1.3.pom" | sed 's/<artifactId>//' | sort | paste -sd' ' -)"
  echo "  pin | the copy's lib/ against before's: tomcat-embed-core $(ls $L | $G -E '^tomcat-embed-core' | paste -sd' ' -) · spring-web $(ls $L | $G -E '^spring-web-[0-9]' | paste -sd' ' -)"; }
reactor() { $G -E '^\[INFO\] TiffinBox[A-Za-z ]* \.+ (SUCCESS|FAILURE|SKIPPED)' "$1" | sed -E 's/ \.+ / ... /; s/\[ *[0-9.:]+ (s|min)\]//; s/^\[INFO\] //; s/ *$//' | paste -sd',' -; }
c_starter() {
  echo "== starter: the harness's copy = before + ONE pom line; built WITH its tests beside a same-run build of before WITH its tests (Docker-free, H2)"
  diff before/tiffinbox-web/pom.xml .harness/hcopy/tiffinbox-web/pom.xml | sed 's/^/  edit | /'
  echo "  edit | the diff's md5 $(diff before/tiffinbox-web/pom.xml .harness/hcopy/tiffinbox-web/pom.xml | md5 -q) · lines added $(diff before/tiffinbox-web/pom.xml .harness/hcopy/tiffinbox-web/pom.xml | $G -c '^>') removed $(diff before/tiffinbox-web/pom.xml .harness/hcopy/tiffinbox-web/pom.xml | $G -c '^<' || true) · the tests copy's pom = the JVM copy's: $(cmp -s .harness/hcopy/tiffinbox-web/pom.xml .harness/hcopy-tests/tiffinbox-web/pom.xml && echo yes || echo no)"
  echo "  edit | git diff --stat f3724ca -- '*pom.xml': $(git -C .. diff --stat f3724ca -- '*pom.xml' | wc -l | tr -d ' ') lines · before's web pom = c9-tiffinbox's: $(cmp -s before/tiffinbox-web/pom.xml ../c9-tiffinbox/tiffinbox-web/pom.xml && echo yes || echo no)"
  echo "  build | before WITH tests: exit $BTRE · $(reactor .harness/build-before-tests.log)"
  echo "  build | the copy WITH tests: exit $HTRE · $(reactor .harness/build-hcopy-tests.log)"
  python3 -I - .harness/before-tests .harness/hcopy-tests <<'PY'
import glob, os, sys, xml.etree.ElementTree as E
def read(t):
    out = {}
    for m in ("web", "client"):
        for f in glob.glob(os.path.join(t, "tiffinbox-%s/target/surefire-reports/TEST-*.xml" % m)):
            r = E.parse(f).getroot()
            out[(m, r.get("name").split(".")[-1])] = tuple(int(r.get(k) or 0) for k in ("tests", "failures", "errors", "skipped"))
    return out
a, b = read(sys.argv[1]), read(sys.argv[2])
for m in ("web", "client"):
    ta = [sum(v[i] for k, v in a.items() if k[0] == m) for i in range(4)]; tb = [sum(v[i] for k, v in b.items() if k[0] == m) for i in range(4)]
    print("  tests | tiffinbox-%s | before tests %d failures %d errors %d skipped %d · the copy tests %d failures %d errors %d skipped %d" % ((m,) + tuple(ta) + tuple(tb)))
for k in sorted(set(a) | set(b)):
    print("  tests | class %s %s | before %s · the copy %s%s" % (k[0], k[1], "/".join(map(str, a.get(k, ()))) or "absent", "/".join(map(str, b.get(k, ()))) or "absent", "" if a.get(k) == b.get(k) else "  MOVED"))
print("  tests | classes that differ: %d (of %d)" % (sum(1 for k in set(a) | set(b) if a.get(k) != b.get(k)), len(set(a) | set(b))))
PY
  local f; for f in .harness/hcopy-tests/tiffinbox-web/target/surefire-reports/*.txt; do $G -q -E 'FAILURE|ERROR' "$f" && $G -m3 -E '<<< (FAILURE|ERROR)|^[a-zA-Z.]+(Error|Exception)' "$f" | cut -c1-240 | sed 's/^/  failing | /'; done; true
  echo "  lib | before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') names · the copy $(ls .harness/hcopy/$XD/lib | wc -l | tr -d ' ') names"
  diff <(ls .harness/before/$XD/lib) <(ls .harness/hcopy/$XD/lib) | $G -E '^[<>]' | sed 's/^>/  lib | added/; s/^</  lib | removed/'
  python3 -I - .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/hcopy/tiffinbox-web/target/tiffinbox-web-1.0.0.jar <<'PY'
import sys, zipfile
a = {i.filename: i.CRC for i in zipfile.ZipFile(sys.argv[1]).infolist()}; b = {i.filename: i.CRC for i in zipfile.ZipFile(sys.argv[2]).infolist()}
only_b = sorted(n for n in b if n not in a); only_a = sorted(n for n in a if n not in b)
crc = sorted(n for n in a if n in b and a[n] != b[n] and not n.endswith("/"))
print("  jar | entries: before %d · the copy %d · only the copy: %d (in BOOT-INF/lib/ %d) · only before %d" % (len(a), len(b), len(only_b), sum(1 for n in only_b if n.startswith("BOOT-INF/lib/")), len(only_a)))
print("  jar | only the copy, outside BOOT-INF/lib/: %s" % (", ".join(n for n in only_b if not n.startswith("BOOT-INF/lib/")) or "none"))
print("  jar | shared entries whose CRC differs: %s" % (", ".join(crc) or "none"))
PY
}
c_cost() {
  echo "== cost: the bytes a link adds - the harness's copy + the harness's HAL routes (21040, build A), H2, the seed's four customers; no compression flag anywhere"
  ACC=1 tb cost 21040 hcopy hcA
  one cost 21040 /api/v1/customers/Ravi " (the shipped route, curl's Accept */*)"
  one cost 21040 /probe/hal/customers/Ravi " (Accept: application/hal+json)" -H 'Accept: application/hal+json'; hal $J/o.b "cost hal one"
  one cost 21040 /probe/hal/customers/Ravi " (Accept: application/json)" -H 'Accept: application/json'
  one cost 21040 /probe/hal/customers/Ravi " (Accept: */*)" -H 'Accept: */*'
  one cost 21040 /customers " (the old list)"
  one cost 21040 /api/v1/customers " (U14's route, the full list)"
  one cost 21040 /probe/hal/customers " (Accept: application/hal+json)" -H 'Accept: application/hal+json'; hal $J/o.b "cost hal four"
  one cost 21040 /probe/hal/customers/Ravi " (Accept: application/hal+json, Host: localhost:<port>)" -H 'Accept: application/hal+json' -H 'Host: localhost:21040'; hal $J/o.b "cost hal host-localhost"
  one cost 21040 /probe/hal/customers/Ravi " (Accept: application/hal+json, Host: api.tiffinbox.localhost:<port>)" -H 'Accept: application/hal+json' -H 'Host: api.tiffinbox.localhost:21040'; hal $J/o.b "cost hal host-longer"
  echo "  host lengths: 127.0.0.1 $(printf %s 127.0.0.1 | wc -c | tr -d ' ') · localhost $(printf %s localhost | wc -c | tr -d ' ') · api.tiffinbox.localhost $(printf %s api.tiffinbox.localhost | wc -c | tr -d ' ') characters"
  acclog cost | sed 's/^/  access | /'
  tbstop cost 21040; }
c_moved() {
  echo "== moved: the harness's member route at two builds of one source, the harness's two clients (harness/follow.py, Python urllib), each its own fresh JVM, H2, the harness's copy"
  diff harness/src/probe/u15/U15Moved.java .harness/srcB/probe/u15/U15Moved.java | sed 's/^/  build diff | /'
  echo "  build diff | md5 $(diff harness/src/probe/u15/U15Moved.java .harness/srcB/probe/u15/U15Moved.java | md5 -q) · lines $(diff harness/src/probe/u15/U15Moved.java .harness/srcB/probe/u15/U15Moved.java | $G -c '^[<>]')"
  local f; for f in $(cd .harness/hcA && find . -name '*.class' | sed 's#^\./##' | sort); do echo "  classes | $f A $(md5 -q .harness/hcA/$f | cut -c1-8) B $(md5 -q .harness/hcB/$f | cut -c1-8) $(cmp -s .harness/hcA/$f .harness/hcB/$f && echo equal || echo differ)"; done
  python3 -I -c 'import re,sys
for s, f in (("A", sys.argv[1]), ("B", sys.argv[2])): print("  classes | the /probe/ strings in U15Moved.class, build %s: %s" % (s, " ".join(sorted(set(x.decode() for x in re.findall(rb"/probe/[A-Za-z/{}]*", open(f, "rb").read()))))))' .harness/hcA/probe/u15/U15Moved.class .harness/hcB/probe/u15/U15Moved.class
  ACC=1 tb movedA 21040 hcopy hcA
  python3 -I harness/follow.py 21040 "build A (the member route at /probe/people)" | sed 's/^/  follow | /'
  acclog movedA | sed 's/^/  access A | /'; tbstop movedA 21040
  ACC=1 tb movedB 21045 hcopy hcB
  python3 -I harness/follow.py 21045 "build B (the member route moved to /probe/members)" | sed 's/^/  follow | /'
  acclog movedB | sed 's/^/  access B | /'; tbstop movedB 21045
  echo "  the probe's follow-literal.txt md5 $(md5 -q "$PK3/captures/h35/follow-literal.txt") (the expectation, 1 run, read)"; }
c_literal() {
  local spec=before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json gs
  echo "== literal: harness/ops9s3.py (BLUE's, byte for byte) on U15's own before - the committed spec, the served spec (21043, harness-free), the built client"
  echo "  spec | the committed spec $(wc -c < $spec | tr -d ' ') B md5 $(md5 -q $spec) · inputSpec in tiffinbox-client/pom.xml: $($G -oE '<inputSpec>[^<]+' before/tiffinbox-client/pom.xml | sed 's/<inputSpec>//')"
  python3 -I harness/ops9s3.py ops $spec | sed 's/^/  ops committed | /'
  tb literal 21043 before ""
  $CURL --http1.1 -s -o $J/live.json "$(B 21043)/v3/api-docs"; tbstop literal 21043
  python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); d.pop("servers",None); json.dump(d,open(sys.argv[2],"w"))' $J/live.json $J/live-noservers.json
  python3 -I harness/ops9s3.py ops $J/live-noservers.json | tail -1 | sed 's/^/  ops served (servers removed) | /'
  echo "  ops served | the served document (servers removed) = the committed file, as parsed JSON: $(python3 -I -c 'import json,sys; a=json.load(open(sys.argv[1])); b=json.load(open(sys.argv[2])); a.pop("servers",None); b.pop("servers",None); print("equal" if a==b else "DIFFER")' $spec $J/live-noservers.json)"
  gs=$(find .harness/before/tiffinbox-client/target -type d -path '*/generated-sources/openapi/src/main/java' | head -1)
  echo "  client | find .harness/before/tiffinbox-client/target -type d -path '*/generated-sources/openapi/src/main/java' -> $gs · its .java files $(find "$gs" -name '*.java' | wc -l | tr -d ' ')"
  python3 -I harness/ops9s3.py paths "$gs" | sed 's/^/  paths | /'
  python3 -I - "$gs" $spec <<'PY'
import json, os, re, sys
gs, spec = sys.argv[1:3]
lit, pair = {}, []
for root, _, fs in os.walk(gs):
    for f in sorted(fs):
        if not (f.endswith(".java") and os.sep + "api" + os.sep in os.path.join(root, f)): continue
        t = open(os.path.join(root, f), encoding="utf-8").read()
        for m in re.finditer(r'String (PATH_[A-Z0-9_]+) = "([^"]*)";', t): lit[m.group(1)] = m.group(2)
        for m in re.finditer(r'@HttpExchange\(\s*method = "([A-Z]+)",\s*value = \w+\.(PATH_[A-Z0-9_]+),.*?\)\s*\S+(?:<[^;]*?>)?\s+(\w+)\(', t, re.S):
            pair.append((m.group(2), m.group(1), m.group(3)))
d = json.load(open(spec)); oid = {}
for p, it in d["paths"].items():
    for m, op in it.items(): oid[(p, m.upper())] = op.get("operationId")
print("  table | rule: each @HttpExchange's method and value constant, the constant's literal, the spec's operationId at (literal, method)")
for c, m, meth in pair:
    print("  table | %-22s %-6s %-40s method %-14s operationId %s" % (c, m, lit.get(c), meth, oid.get((lit.get(c), m))))
print("  table | constants %d · distinct strings %d · @HttpExchange methods %d" % (len(lit), len(set(lit.values())), len(pair)))
PY
  echo "  vocabulary | lines matching _links, href, Link, RepresentationModel, EntityModel or HAL (grep -rwE) in the generated sources: $($G -rwE '_links|href|Link|RepresentationModel|EntityModel|HAL' "$gs" | wc -l | tr -d ' ')"
  mkdir -p $J/empty; printf '{}\n' > $J/empty.json
  local o r; o=$(python3 -I harness/ops9s3.py ops $J/empty.json 2>&1); r=$?; echo "  plant | ops on an empty spec ({}) -> exit $r · $o"
  o=$(python3 -I harness/ops9s3.py paths $J/empty 2>&1); r=$?; echo "  plant | paths on an empty directory -> exit $r · $o"
  echo "  probe | h35/generated-paths.txt md5 $(md5 -q "$PK3/captures/h35/generated-paths.txt") · $(wc -l < "$PK3/captures/h35/generated-paths.txt" | tr -d ' ') constants - counted on c9-unit12/after's client (RED3 #3), another tree; not this unit's count"; }
c_final() {
  echo "== final: the census of controllers in before's tiffinbox-web (src/main), by its printed rule; methodOn() on the final CustomerReads (21040, harness-joined)"
  python3 -I - before/tiffinbox-web/src/main/java/com/tiffinbox/web <<'PY'
import os, re, sys
d = sys.argv[1]
print("  census | rule: a class whose annotation lines (the lines between the Javadoc's end and its declaration) include exactly @RestController or @Controller; its final modifier; @Profile(\"dev\") among those lines")
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
    print("  census | %-16s final %-3s dev-only %-3s %s:%d" % (r[0], "yes" if r[1] else "no", "yes" if r[2] else "no", r[3], r[4]))
for e in excl:
    print("  census | excluded by the rule: %s (%s:%d) - annotated @RestControllerAdvice, not a controller the link builder proxies" % e)
fd = sum(1 for r in rows if r[1] and not r[2]); nd = sum(1 for r in rows if not r[1] and r[2])
print("  census | controllers %d · final, default-run %d · not final, dev-only %d · other %d" % (len(rows), fd, nd, len(rows) - fd - nd))
PY
  echo "  source | $($G -n 'final class CustomerReads' before/tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerReads.java) (CustomerReads.java) · $($G -n 'final class CustomerFields' before/tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerFields.java) (CustomerFields.java)"
  tb final 21040 hcopy hcA
  one final 21040 /probe/hal/final " (the harness's route)"
  python3 -I -c 'import json,sys
d=json.load(open(sys.argv[1]))
for k in ("methodOn","methodOnRoot","methodForm","nonFinal"): print("  final | %s: %s" % (k, d.get(k, "absent")))' $J/o.b
  tbstop final 21040; }
c_placeholder() {
  echo "== placeholder: the harness's U15Placeholder (@GetMapping(\"\${probe.customers-path:/probe/people}/{name}\")), 21040, harness-joined, a fresh JVM per side, H2"
  local side
  for side in unset set; do
    if [ $side = unset ]; then ACC=1 tb ph-unset 21040 hcopy hcA --probe.u15.leg=placeholder; else ACC=1 tb ph-set 21040 hcopy hcA --probe.u15.leg=placeholder --probe.customers-path=/probe/members; fi
    local rp=/probe/people/Ravi; [ $side = set ] && rp=/probe/members/Ravi
    one ph-$side 21040 $rp " (the route, Accept: application/hal+json)" -H 'Accept: application/hal+json'
    one ph-$side 21040 /probe/entry " (Accept: application/hal+json)" -H 'Accept: application/hal+json'
    echo "  ph-$side | the entry's body: $(cat $J/o.b)"
    python3 -I - "$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1]))["_links"]["ravi"]["href"])' $J/o.b)" ph-$side <<'PY'
import sys, urllib.error, urllib.request
href, lab = sys.argv[1:3]
try:
    with urllib.request.urlopen(urllib.request.Request(href, headers={"Accept": "application/hal+json"}), timeout=10) as r:
        s, t, b = r.status, r.headers.get("Content-Type"), r.read()
except urllib.error.HTTPError as e:
    s, t, b = e.code, e.headers.get("Content-Type"), e.read()
import re
title = re.search(rb"<title>([^<]*)</title>", b)
print("  %s | the link followed (Python urllib, the href sent as written) -> %s %s %d B · title %s" % (lab, s, t, len(b), title.group(1).decode() if title else "none"))
PY
    echo "  ph-$side | the JVM log on the refusal: $($G -E 'Http11Processor|Invalid character found' .harness/run/ph-$side/jvm.log | sed -E 's/^[0-9T:.+-]+ +//; s/ [0-9]+ --- \[[^]]*\] +/ /' | cut -c1-220 | paste -sd'|' -)"
    acclog ph-$side | sed "s/^/  access $side | /"
    tbstop ph-$side 21040; done; }
c_seven() {
  echo "== the seven (c5-unit11/curlset.sh, no key header), each its own JVM, H2, no harness - not a witness for the harness's routes: it sends nothing to /probe/"
  echo "  expected $S466"
  local s port t i; for s in before copy; do [ $s = before ] && { port=21043; t=before; } || { port=21041; t=hcopy; }
    tb seven-$s $port $t "" > /dev/null
    sh $CURLSET $port .harness/run/seven-$s/secrets/tiffinbox/shutdown-token > $J/seven-$s.txt 2>&1
    i=0; while kill -0 "$(cat .harness/run/seven-$s/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 60 ] || break; sleep 0.05; done
    QUIET=1 tbstop seven-$s $port
    echo "  $s: the seven $(md5 -q $J/seven-$s.txt) ($(wc -l < $J/seven-$s.txt | tr -d ' ') lines)"; done
  echo "  the seven's paths (read off curlset.sh): $($G -oE '^req [A-Z]+ /[a-z]*' $CURLSET | awk '{ print $3 }' | paste -sd' ' -) and POST /shutdown - none under /probe/"; }
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
c_surface() { local side port t
  echo "== the old surface by count (U14's reader, copied), each its own JVM, H2, no harness - not a witness for the harness's routes"
  echo "  expected $U4SURF"
  for side in before copy; do [ $side = before ] && { port=21043; t=before; } || { port=21041; t=hcopy; }
    tb surface-$side $port $t "" > /dev/null
    oldsurface2 $port $J/surface-$side.txt
    QUIET=1 tbstop surface-$side $port
    echo "  $side: the old surface $(md5 -q $J/surface-$side.txt) ($($G -c '^== ' $J/surface-$side.txt) requests, $(wc -l < $J/surface-$side.txt | tr -d ' ') lines)"; done
  echo "  before -> the copy: $(cmp -s $J/surface-before.txt $J/surface-copy.txt && echo equal || echo DIFFER)"
  echo "== the S9.14 plant (1/1 per run): the copy with Spring MVC's problem details off (--spring.mvc.problemdetails.enabled=false), 21042 - the check that can fail"
  tb surface-plant 21042 hcopy "" --spring.mvc.problemdetails.enabled=false > /dev/null
  oldsurface2 21042 $J/surface-plant.txt; QUIET=1 tbstop surface-plant 21042
  echo "  ~ plant (21042, the S9.14 slot): the old surface $(md5 -q $J/surface-plant.txt) - $(cmp -s $J/surface-plant.txt $J/surface-copy.txt && echo 'EQUAL (the plant was not seen)' || echo 'moved, as planted')"; }
c_inert() {
  echo "== the key header across this run's captures (request lines and bodies), the harness's clients and the exercise"
  echo "  lines naming the key header across the captures: $(cat .r-*.new 2> /dev/null | $G -ciF "$KW" || true)"
  echo "  lines naming it in harness/follow.py, harness/src and exercise/: $(cat harness/follow.py harness/src/probe/u15/*.java exercise/*.py exercise/*.sh | $G -ciF "$KW" || true)"
  echo "  this unit sends GETs to the harness's routes; its POSTs are the seven's and the old surface's own (no key header)"; }
wpy() { awk '/^```python$/ { w = 1; next } w == 1 && /^```$/ { exit } w == 1 { print }' "$1"; }
exrun() { local v=$1 sh=$2 o cmd
  guard "the exercise, $v, $sh"
  rm -rf .harness/exercise; mkdir -p .harness/exercise; cp exercise/client.py .harness/exercise/my_client.py
  case $v in broken) cmd='sh check.sh "$0"' ;; solved) cmd='sh apply.sh "$0" > /dev/null && sh check.sh "$0"' ;; *) cmd="HOW=$v sh apply.sh \"\$0\" > /dev/null && sh check.sh \"\$0\"" ;; esac
  if [ $sh = bash ]; then o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21048 JAVA_HOME="$JAVA_HOME" bash -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/my_client.py" 2>&1)
  else o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21048 JAVA_HOME="$JAVA_HOME" /bin/zsh -f -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/my_client.py" 2>&1); fi
  local pre="  $v $sh |"; [ $v = broken ] || [ $v = solved ] || pre="  variant $v $sh |"
  printf '%s\n' "$o" | sed -E "s/127\.0\.0\.1:21048/127.0.0.1:<port>/g; s/^/$pre /"
  [ "$(listeners 21048)" = 0 ] || die "the exercise left something listening on 21048"; }
c_exercise() { local v sh o r
  echo "== the exercise on 21048 (H2, the harness's copy and its two builds, one server at a time), bash and zsh -f"
  guard "the exercise's build.sh"
  o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" sh build.sh 2>&1); r=$?
  echo "  build.sh -> exit $r · $o"; offl .harness/servers/build.log
  o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21048 JAVA_HOME="$JAVA_HOME" sh check.sh client.py 2>&1); r=$?
  echo "  check.sh client.py (no --allow-broken) -> exit $r · $o"
  echo "  == broken, measured first on the route the exercise names (the shipped client.py itself, --allow-broken)"
  o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21048 JAVA_HOME="$JAVA_HOME" sh check.sh --allow-broken client.py 2>&1); r=$?
  printf '%s\n' "$o" | sed -E 's/127\.0\.0\.1:21048/127.0.0.1:<port>/g; s/^/  measured | /'; echo "  measured | check exit $r"
  for v in broken solved; do for sh in bash zsh; do echo "  == $v, $sh"; exrun $v $sh; done; done
  for v in bothpaths entryonly wired ignore404; do exrun $v bash; done   # the refused variants, every run (3/3), under bash
  echo "  solution | SOLUTION.md's python block = the lines apply.sh writes: $(cp exercise/client.py $J/sol.py && (cd exercise && sh apply.sh "../$J/sol.py" > /dev/null) && python3 -I -c 'import sys; print("yes" if open(sys.argv[2]).read() in open(sys.argv[1]).read() else "no")' $J/sol.py <(wpy exercise/SOLUTION.md))"
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures${DEVCAPS:+ (DEVELOPMENT: only $DEVCAPS - not a run of record)}"
cap advisory c_advisory
cap before c_before
cap pin c_pin
cap starter c_starter
cap cost c_cost
cap moved c_moved
cap literal c_literal
cap final c_final
cap placeholder c_placeholder
cap seven c_seven
cap surface c_surface
cap exercise c_exercise
cap inert c_inert
echo "== plants (each made to FAIL first on a copy of this run's capture; harness/chk15.py plants)"
PL=$(python3 -I -B harness/chk15.py plants .) || die "a plant was not caught: $(printf '%s\n' "$PL" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$PL" | $G '^ok ' | sed 's/^ok /  /'
PLV=$(printf '%s\n' "$PL" | sed -n 's/^VALUES //p')

# ---- the end: the sweep, the values, the published hashes -------------------------------------------------------------------------------
[ -z "$(echo $PIDS)" ] || die "a JVM of this run is still running: $PIDS"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
[ -z "$(dk ps -aq --filter name=^/c9u15-)" ] || die "a c9u15-* container is left"
NI1=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' '); NC1=$(dk ps -aq 2> /dev/null | wc -l | tr -d ' ')
[ "$NI1" = "$NI0" ] && [ "$VOL1" = "$VOL0" ] && [ "$NC1" = "$NC0" ] || die "R.322: images $NI0 -> $NI1, volumes $VOL0 -> $VOL1, containers $NC0 -> $NC1"
AD1=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after/ ../c9-tiffinbox 2>&1 || true); [ "$AD1" = "$AD" ] || die "the anchor moved during the run"
pin before-tree before; pin after-tree after
MDB=$(find . ../c9-tiffinbox ../c9-unit14 -name '*.mv.db' -not -path './.harness/*' -not -path '../c9-unit14/.harness/*' 2> /dev/null | wc -l | tr -d ' ')
[ "$MDB" = 0 ] || die "an H2 file outside .harness/"
[ -z "$(ls -A exercise | $G -v -xE 'README.md|SOLUTION.md|apply.sh|build.sh|check.sh|client.py')" ] || die "the exercise left a file in exercise/"
VALS="$VALS
plants: $PLV
build: seed_files=$NF0 seed_bytes=$NB0 central_only=$CO"
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
[ -n "${DEVCAPS:-}" ] && { echo "c9-unit15: DEVELOPMENT run ($DEVCAPS) - nothing published"; exit 2; }
VO=$(python3 -I -B harness/chk15.py values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; [ -n "${NOPIN:-}" ] || die "README.md's values block is not this run's"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM of this run, ports free, no container started, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1, containers $NC0 -> $NC1 · the anchor against after/ as at the start · the tree pins · *.mv.db outside .harness 0"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit15: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit15: every capture = published ($NCAPS) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"
