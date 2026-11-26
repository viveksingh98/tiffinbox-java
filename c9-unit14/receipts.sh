#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 14 "Sparse Fieldsets and Compression" - this unit's receipts. Course 9's ELEVENTH anchor change, Section 3's second:
# before is a link to ../c9-unit13/after (U13's after); after/ is a frozen copy of ../c9-tiffinbox after this unit's change - CustomerFields
# GET /api/v1/customers?fields= and CustomerFieldsTest (tiffinbox-web), the committed spec regenerated; compression left a run flag.
# The harness (never in the jar or the module): probe.u14.* - the harness's @JsonView and MappingJacksonValue routes (U14Fields) and the
# harness's client (Gzip14, three factories, each with its own User-Agent) - joined on a harness-joined start only (21035). No Chrome.
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5; lines starting "  ~" are run-variant
# and left out of the hash - the exercise's refused variants of run 1):
#   advisory  the S9.36 read filed for the batch day (ADV3), verified, before any build
#   before    GET /api/v1/customers on before, the old /customers, the order list, the mappings, the spec's counts
#   change    the modules, the new files whole, the derived changed list, the whitelist against the record, the greps, the handler names
#   full      the new route's full list and the old /customers at 4 customers, plain, flag off (21030): bytes, headers, the access log
#   fields    ?fields=name,mealType, ?fields=name, ?fields=mealType,name - bytes and members
#   refuse    every refusal and every odd fields form, each status, type and detail; the 400s with no type named
#   view      the harness's @JsonView route (21035, harness-joined, flag off)
#   mjv       the harness's MappingJacksonValue route: the five hundred and the JVM log's exception
#   floor     Boot 4.1.3's metadata read back; 4 customers, gzip asked, flag on: no encoding
#   page      /dashboard HTML, flag on, at 4 customers: plain and gzip asked, the framing printed
#   grown     30 POSTs, then both list routes plain and gzip asked: curl's bytes, Tomcat's %b, gunzip
#   under     at 34 customers, the two fieldsets plain and gzip asked: no encoding, their Content-Length
#   clients   three client factories (the harness's Gzip14, harness-joined, flag on, 34 customers), each with its own User-Agent
#   yaml      compression put in application.yaml on a scratch copy (21033): the old surface against after/ flag off, gzip asked
#   spec      the committed spec against the served one, the diff, the counter, spec vs wire, the client rebuilt
#   moved     U13's requests and the new route on before (21036) and after/ (21030); the jars per entry
#   seven     c5-unit11's seven on before and after/
#   surface   the old surface by count on before and after/, the S9.14 plant (21034)
#   inert     the key header across this run's captures
#   tests     package, the Docker-free build of after/, verify (Surefire on H2, the five ITs on PostgreSQL), the web-only form, the slice
#   exercise  break.sh, check.sh, apply.sh on 21038, bash and zsh -f, H2; the refused variants (run 1)
# Ports (U14's band, 21030-21039): 21030 after/ on H2, no harness · 21033 a scratch copy's JVM · 21034 the S9.14 plant · 21035 the
# harness-joined starts · 21036 before · 21038 the exercise · 21031, 21032, 21037 and 21039 never bound (no PostgreSQL leg in this unit:
# fields-pg was not captured). During mvn verify only: 21280-21284. Every store on 127.0.0.1; every curl --noproxy '*'.
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
trap 'trap "" INT TERM; for p in $mpid $PIDS; do [ -z "$p" ] || killtree "$p"; done; for p in $mpid $PIDS; do if kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; for c in $(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null); do dk rm -fv "$c" > /dev/null 2>&1; done; rm -rf exercise/check.run; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.b exercise/check.h; [ -z "$INTR" ] || rm -f .r-*.new; rmdir .r-lock 2> /dev/null || rm -rf .r-lock; true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git unzip gunzip /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|SPRINGDOC_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit14 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }') · run $RUNNO"

# ---- gates before anything is built: the folder, the link, the pins, the anchor, the static check, the prose, the exercise ----------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk14.py dur9.py ops9s3.py s914.py src tree14.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
HSRC='probe/u14/Gzip14.java probe/u14/U14Config.java probe/u14/U14Fields.java'
[ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$HSRC" ] || die "harness/src holds another file, or misses one"
for f in walk.py loc9.py seal9.py cdp.mjs cdp9.mjs specwire9.py mirror src/probe/u12 src/probe/u13 src/probe/u10/Caller.java; do [ ! -e harness/$f ] || die "harness/$f: an earlier unit's instrument this unit does not carry"; done
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md apply.sh break.sh check.sh' ] || die "exercise/ holds another file, or misses one"
[ -L before ] && [ "$(readlink before)" = ../c9-unit13/after ] || die "before must be a link whose text is exactly ../c9-unit13/after"
[ -d after ] && [ ! -L after ] || die "after/ is this unit's own frozen tree, a directory, not a link"
for t in before after; do [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-client/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/"; true; done
echo "  before -> $(readlink before) (a link, the text exact) · after/ a directory (the frozen copy) · no secrets/, target/ or .m2-demo/ in either · harness/: no walk.py, seal9.py, cdp.mjs, cdp9.mjs, loc9.py, specwire9.py, mirror/, U12's or U13's harness classes or Caller.java"
$G -v '^ *#' harness/src/probe/u14/*.java | $G -q 'Thread\.sleep' && die "R.412: a Thread.sleep in the harness"
GZM=$(md5 -q "$PK3/instruments/Gzip.java"); [ "$GZM" = 0310b5ff81b6626843db1c3eb5988f64 ] || die "the probe's Gzip.java is not 0310b5ff (its md5 $GZM)"
PF=$(md5 -q "$PK3/instruments/probe-src/ProbeFields.java"); [ "$PF" = 41b3d7e2c4546bc5c482bfd8aea4e231 ] || die "the probe's ProbeFields.java is not 41b3d7e2 (its md5 $PF)"
OP=$(md5 -q "$BK3/instruments/ops9s3.py"); [ "$OP" = 8f062a0e5e872c478579756a8426c012 ] || die "BLUE's ops9s3.py is not 8f062a0e"
[ "$(md5 -q harness/ops9s3.py)" = "$OP" ] || die "harness/ops9s3.py is not BLUE's instrument, byte for byte"
$G -q 'header("User-Agent"' harness/src/probe/u14/Gzip14.java && die "RED #16: Gzip14 overrides the User-Agent"
$G -q 'header("User-Agent"' "$PK3/instruments/Gzip.java" || die "the probe's Gzip.java no longer holds its User-Agent override (the named diff's line)"
echo "  Gzip14.java against the probe's Gzip.java (md5 $GZM, asserted before the diff): the named diff md5 $(diff "$PK3/instruments/Gzip.java" harness/src/probe/u14/Gzip14.java | md5 -q), $(diff "$PK3/instruments/Gzip.java" harness/src/probe/u14/Gzip14.java | $G -c '^[<>]') lines (the package, the class name, the Javadoc, its User-Agent override removed: each client sends its own) · Gzip14 md5 $(md5 -q harness/src/probe/u14/Gzip14.java)"
echo "  U14Fields.java against the probe's ProbeFields.java (md5 $PF): the named diff md5 $(diff "$PK3/instruments/probe-src/ProbeFields.java" harness/src/probe/u14/U14Fields.java | md5 -q), $(diff "$PK3/instruments/probe-src/ProbeFields.java" harness/src/probe/u14/U14Fields.java | $G -c '^[<>]') lines (the package, the class name, the label, the routes under /probe/u14/fields/; the probe's /api/v1/customers route left out - the shipped CustomerFields is this unit's own)"
echo "  ops9s3.py = BLUE's (md5 $OP, byte for byte; it refuses an empty spec) · U14Config.java md5 $(md5 -q harness/src/probe/u14/U14Config.java)"
[ "$(sed -n '5,$p' harness/tree14.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit13/harness/tree13.py | md5 -q)" ] || die "harness/tree14.py's code is not tree13.py's"
for u in 01 02 03 04 05 06 07 08 09 10 11 12 13; do [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit$u/harness/dur9.py)" ] || die "harness/dur9.py is not ../c9-unit$u's copy"; done
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"
  [ ! -f "$C9R/_builders/dur9.py" ] || [ "$(md5 -q "$C9R/_builders/dur9.py")" = "$D9" ] || die "harness/dur9.py is not C9/_builders/dur9.py"
  T14=$(python3 -I -c 'import re,sys; t=open(sys.argv[1]).read(); m=re.search(r"\"14\": *\"([^\"]+)\"", t.split("TITLES",1)[1]); print(m.group(1) if m else "")' "$J9")
  [ "$T14" = "Sparse Fieldsets and Compression" ] || die "java9_series.TITLES[\"14\"] is \"$T14\""
  T630=$(python3 -I -c 'import re,sys; t=open(sys.argv[1]).read(); m=re.search(r"\"30\": *\"([^\"]+)\"", t.split("TITLES",1)[1]); print(m.group(1) if m else "")' "$HOME/Desktop/PromptVidya-Automation/java6_series.py")
  [ "$T630" = "Web Layer Performance" ] || die "java6_series.TITLES[\"30\"] is \"$T630\" (C14: the live title wins - a finding)"
  echo "  the titles, read off the registry: Course 9's 14 \"$T14\" · Course 6's call-back \"$T630\" (by title only, R.224)"
else D9N="(the registry is not on this machine: U01-U13's copies are the pin)"; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit01-13's copies $D9N · tree14.py's code = tree13.py's"
XS1=$(sed -n '/^# --- XFAM_S9S1 begin ---$/,/^# --- XFAM_S9S1 end ---$/p' harness/s914.py | md5 -q); XS1U=$(sed -n '/^# --- XFAM_S9S1 begin ---$/,/^# --- XFAM_S9S1 end ---$/p' ../c9-unit13/harness/s913.py | md5 -q)
[ "$XS1" = "$XS1U" ] || die "s914.py's XFAM_S9S1 slice is not U13's s913.py's"
echo "  s914.py: XFAM_S9S1's slice md5 $XS1 = ../c9-unit13/harness/s913.py's · its XU14 family this unit's · lines outside XU14 = s913.py's but for the names: $(diff <(sed '/^XU13 = {/,/^u04 = u13$/d' ../c9-unit13/harness/s913.py) <(sed '/^XU14 = {/,/^u04 = u14$/d' harness/s914.py) | $G -c '^[<>]') lines differ"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit13/receipts.md5)
[ -n "$UA" ] || die "../c9-unit13/receipts.md5 has no after-tree line"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree14.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || { [ -n "${NOPIN:-}" ] && { echo "  $dir/: $got (NOPIN: no pin yet)"; return 0; }; die "receipts.md5 has no $nm line"; }
  [ "$nm" = after-tree ] || [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit13/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree14.py $dir/ -> $got = receipts.md5's $nm line$( [ "$nm" = before-tree ] && echo " = ../c9-unit13/receipts.md5's after-tree line")"; }
pin before-tree before; pin after-tree after
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true)
echo "  after/ against ../c9-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures its own frozen after/' )"
HF="harness/chk14.py harness/s914.py harness/tree14.py harness/dur9.py harness/ops9s3.py $(for f in $HSRC; do printf 'harness/src/%s ' $f; done)exercise/check.sh exercise/apply.sh exercise/break.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's scripts: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
ST=$(python3 -I -B harness/chk14.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
echo "  static (harness/chk14.py static after before): $(printf '%s\n' "$ST" | $G -c '^ok ') checks, FAIL 0"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s914.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U14 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s914, per sentence): /'
PH=$($G -rnE '\bPENDING\b|PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b|<measure>' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
GL=$(python3 -I -B harness/chk14.py gloss README.md) || die "the gloss: $(printf '%s\n' "$GL" | $G '^FAIL' | head -3 | paste -sd';' -)"
echo "  the gloss: $(printf '%s\n' "$GL" | $G -c '^ok ') checks, FAIL 0 ($(python3 -I -B harness/chk14.py gloss-line))"
HOOK=$(python3 -I -B harness/chk14.py hook); EXQ=$(python3 -I -B harness/chk14.py exq); GLS=$(python3 -I -B harness/chk14.py gloss-line)
IL=$(python3 -I -B harness/chk14.py interleaved) || die "the brief's interleaved hooks and exercises: $IL"
echo "  $IL"
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S3B's Unit 14 Hook line), byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
HW=$(printf '%s\n' "$HOOK" | wc -w | tr -d ' '); EW=$(printf '%s\n' "${EXQ#Your turn: }" | wc -w | tr -d ' ')
[ "$HW" -le 25 ] && [ "$EW" -le 25 ] || die "a spoken line over 25 words (hook $HW, exercise $EW)"
echo "  the hook ($HW words) and the exercise's line ($EW words after 'Your turn:') byte for byte, extracted from S3B's Unit 14 (md5 $(md5 -q "$C9R/_briefs/UNIT-BRIEFS-S3-PAYLOADS.md"))"
printf '%s\n\n%s\n\n%s\n' "$HOOK" "$EXQ" "$GLS" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s914.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
printf '%s\n' "$SW" | tail -1 | $G -qE ' refused: 0$' || die "a refused reading in a spoken line: $(printf '%s\n' "$SW" | $G ' line ' | head -3 | paste -sd';' -)"
echo "  the hook, the exercise's line and the gloss through s914.py: refused 0"; rm -f .r-lock/spoken.md
TS="Sparse Fieldsets in Spring Boot: @JsonView, Fields, gzip"
$G -qF "$TS" "$C9R/_briefs/UNIT-BRIEFS-S3-PAYLOADS.md" || die "the title for search is not S3B's"
TL=$(python3 -I -c 'import sys; print(len(sys.argv[1]))' "$TS"); [ "$TL" -le 60 ] || die "the title for search is over 60 characters"
echo "  the title for search (read, not edited here): \"$TS\" - $TL characters (<= 60)"
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
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'took 812 ms' '"timestamp":"2026-11-01T08:09:00.123Z"' "$U/x $HOME/y" '[INFO] TiffinBox Web ...... SUCCESS [ 11.955 s]' | mask)
[ "$(printf '%s\n' "$MP" | paste -sd'|' -)" = 'Started TiffinBoxServer in <t> (process running for <t>)|took <t>|"timestamp":"<time>"|…/x ~/y|[INFO] TiffinBox Web ...... SUCCESS [<t>]' ] || die "the mask's self-test: $(printf '%s\n' "$MP" | paste -sd'|' -)"
echo "  masks: the log mask masked a Started line's times, a millisecond count, a timestamp, the folders, the home and a reactor line's time (self-test)"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh); [ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SURF=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh); [ ${#U4SURF} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh (SURF=)"
U13V=$(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit13/README.md | $G -E '^(seven|surface): ' | $G -oE '(seven|surface)=[0-9a-f]{8}' | paste -sd' ' -)
[ "$U13V" = "seven=$(echo $S466 | cut -c1-8) surface=$(echo $U4SURF | cut -c1-8)" ] || die "U13's README values block ($U13V) is not the seven and the surface read off the receipts"
echo "  the seven: expected $S466 (../c7-unit31/receipts.sh's S466= line) · the old surface: expected $U4SURF (../c9-unit04/receipts.sh's SURF= line) · both = U13's values block ($U13V)"
for f in c4plain.b c4gzip.b c34plain.b c34gzip.b c34fplain.b c34fgzip.b c34f2.b c34f2g.b clients.txt f_api_v1_customers_.b f_api_v1_customers_fields_name_.b f_api_v1_customers_fields_name_meal_ype_.b f_probe_fields_view_.b f_probe_fields_mjv_.b; do
  [ -f "$PK3/captures/h34/$f" ] && echo "  probe | h34/$f md5 $(md5 -q "$PK3/captures/h34/$f") $(wc -c < "$PK3/captures/h34/$f" | tr -d ' ') B (read, not copied: the expectation, 1 run)"; done
for f in h2b1.txt h2b2.txt h2b3.txt; do [ -f "$BK3/captures/$f" ] && echo "  BLUE | $f md5 $(md5 -q "$BK3/captures/$f") (read, not copied)"; done

# ---- docker, ports, the guard: the baselines ----------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run"
[ -z "$(dk ps -aq --filter name=^/c9u14- 2> /dev/null)" ] || die "a c9u14-* container exists before the run"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
BAND="21030 21031 21032 21033 21034 21035 21036 21037 21038 21039"
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
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · nothing pulled · no Testcontainers or c9u14-* container · ports $PORTS free"

# ---- the trees, copied and built offline: before (through the link), after/; the harness, compiled -------------------------------------
M2="$PWD/.m2-demo"
if [ ! -d "$M2" ]; then [ -d "$SEED" ] || die "the seed $SEED is missing"; cp -cR "$SEED" "$M2" 2> /dev/null || cp -R "$SEED" "$M2" || die "the seed could not be copied"; fi
NF0=$(find "$M2" -type f | wc -l | tr -d ' '); NB0=$(find "$M2" -type f -print0 | xargs -0 stat -f %z | awk '{ s += $1 } END { printf "%d", s }')
CO=$(find "$M2" -name _remote.repositories -print0 | xargs -0 $G -l 'central-only' 2> /dev/null | wc -l | tr -d ' ')
[ "$CO" = 0 ] || die "$CO _remote.repositories files in the seed copy still name central-only"
ART="org/springframework/boot/spring-boot-starter-parent/4.1.3 org/apache/httpcomponents/client5/httpclient5/5.6.5 tools/jackson/core/jackson-databind/3.1.8"
for a in $ART; do [ -n "$(ls "$M2/$a" 2> /dev/null | $G -E '\.(jar|pom)$')" ] || die ".m2-demo holds no $a (no seed act here: report the coordinates)"; done
echo "  .m2-demo (a copy of the seed m2-seed-c9-s3): files $NF0 · bytes $NB0 · _remote.repositories naming central-only: $CO · no artifact this unit adds"
for a in $ART; do echo "  seed | $a | $(ls "$M2/$a" | $G -E '\.(jar|pom)$' | paste -sd' ' -)"; done
mkdir -p .harness; for d in before after pkg tests webonly need-yaml exercise run work hc client-before; do rm -rf .harness/$d; done
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
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \"$CPA\" harness/src/probe/u14/*.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/'s jar: $(head -5 .harness/javac.log)"
echo "  the harness compiled against after/'s web jar ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes, -parameters) - never in either jar"
B() { echo "http://127.0.0.1:$1"; }
J=.harness/work
ALP='%m %U%q %s %b "%{Accept-Encoding}i" "%{Content-Encoding}o" "%{User-Agent}i"'
# tb LABEL PORT FLAG HARNESS [args]: TiffinBox (the extracted jar of TREE=after unless TREE is set), from its own run folder with a
# generated token (0600, never printed), H2 in memory (fresh per JVM), waited for by its Started line. FLAG: on = the run flag
# --server.compression.enabled=true on the command line, off = none. HARNESS: 1 joins probe.u14.U14Config. ACC=1: Tomcat's access log
# (the harness's pattern, unbuffered, into the run folder).
tb() { local label=$1 port=$2 flag=$3 hx=$4 t=${TREE:-after} run=.harness/run/$1 src="" i=0; shift 4
  guard "TiffinBox $label"
  for q in 21031 21032 21037 21039; do [ "$(listeners $q)" = 0 ] && [ -z "$(lsof -nP -iUDP:$q 2> /dev/null)" ] || die "$q must stay free (TCP and UDP)"; done
  [ "$(listeners $port)" = 0 ] && [ -z "$(lsof -nP -iUDP:$port 2> /dev/null)" ] || die "$port is bound before $label"
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  local x="$U/.harness/$t/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  local fx=(); [ "$flag" = on ] && fx=(--server.compression.enabled=true)
  local ax=(); [ -n "${ACC:-}" ] && ax=(--server.tomcat.accesslog.enabled=true "--server.tomcat.accesslog.directory=$U/$run" --server.tomcat.accesslog.prefix=access --server.tomcat.accesslog.suffix=.log --server.tomcat.accesslog.rotate=false --server.tomcat.accesslog.buffered=false "--server.tomcat.accesslog.pattern=$ALP")
  if [ -n "$hx" ]; then cp="$cp:$U/.harness/hc"; src="--spring.main.sources=probe.u14.U14Config"; fi
  echo "java -cp <tree $t> com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=$port $src ${fx[*]:-} $( [ -n "${ACC:-}" ] && echo '<the access log>') $*" > "$run/cmd"
  (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -cp "$cp" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port="$port" $src "${fx[@]}" "${ax[@]}" "$@" > jvm.log 2>&1) &
  local p=$!; echo $p > "$run/pid"; PIDS="$PIDS $p"; MINE="${MINE:-} $port"
  while ! $G -q -E 'Started TiffinBox(App|Server) in' "$run/jvm.log" 2> /dev/null; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before its Started line"; }; i=$((i + 1)); [ $i -lt 900 ] || die "$label: no Started line"; sleep 0.1; done
  if [ -n "$hx" ]; then i=0; while ! $G -q '^U14 harness: joined' "$run/jvm.log"; do i=$((i + 1)); [ $i -lt 100 ] || die "$label: no U14 harness line"; sleep 0.05; done; fi
  local dup; dup=$(tr ' ' '\n' < "$run/cmd" | $G -E '^--' | sed 's/=.*//' | sort | uniq -d | paste -sd, -); [ -z "$dup" ] || die "R.444: a flag twice on $label's command line ($dup)"
  echo "  $label up on $port (H2, tree $t, flag=$flag$( [ -n "$hx" ] && echo ", the harness joined (its U14 harness line printed)" || echo ", no harness")$( [ -n "${ACC:-}" ] && echo ", the access log on")) · $(sed 's/ *$//' "$run/cmd")"; }
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
  local o e=0; o=$(python3 -I -B harness/chk14.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk14 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; [ -n "${DEVCAPS:-}${NOPIN:-}" ] && { echo "  (development: $nm's check failed, the run goes on)"; unpub="$unpub $nm"; } || die "$nm: its check failed (harness/chk14.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk14.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-11s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-11s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff .r-$nm.new against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }
ck() { python3 -I -B harness/chk14.py "$@"; }
API=/api/v1/customers
# one LABEL PORT PATH [curl args]: one GET; prints status, type, curl's size, the saved file's bytes and md5, Content-Length,
# Content-Encoding, Transfer-Encoding and Vary (none when absent), and the members of the first element when the body is JSON
one() { local lab=$1 port=$2 p=$3 w; shift 3; : > $J/o.h; : > $J/o.b
  w=$($CURL --http1.1 -sS -D $J/o.h -o $J/o.b -w '%{http_code} %{content_type} %{size_download}' --max-time 10 "$@" "$(B $port)$p")
  hv() { local v; v=$(tr -d '\r' < $J/o.h | $G -i "^$1:" | head -1 | sed -E "s/^[^:]*: *//"); echo "${v:-none}"; }
  echo "  $lab | GET $p -> $w · file $(wc -c < $J/o.b | tr -d ' ') B md5 $(md5 -q $J/o.b) · Content-Length $(hv Content-Length) · Content-Encoding $(hv Content-Encoding) · Transfer-Encoding $(hv Transfer-Encoding) · Vary $(hv Vary)$(python3 -I -c '
import json,sys
try:
    d=json.load(open(sys.argv[1],encoding="utf-8"))
    print(" · members %s · elements %d" % (list(d[0]) if isinstance(d,list) and d else list(d), len(d) if isinstance(d,list) else 1))
except Exception: print("")' $J/o.b)"; }
# prq LABEL QUERY: a refused (or not) request to the new route on 21030; its members read by python
prq() { local lab=$1 q=$2 w
  w=$($CURL --http1.1 -sS -o $J/pr.b -w '%{http_code} %{content_type}' --max-time 10 "$(B 21030)$API$q")
  echo "  refuse | $lab ($q) -> $w | $(python3 -I -c '
import json,sys
try:
    d=json.load(open(sys.argv[1],encoding="utf-8"))
    if isinstance(d,list): print("a list of %d · members %s" % (len(d), list(d[0]) if d else []))
    else:
        d.pop("timestamp",None) if "timestamp" not in d else d.update(timestamp="<masked>")
        print(" · ".join("%s=%s" % (k, d[k]) for k in ("type","title","detail","instance","status","error","path") if k in d) or "members %s" % list(d))
except Exception as e: print("not JSON")' $J/pr.b)"; }
acclog() { cat .harness/run/$1/access*.log 2> /dev/null | sed -E 's/^([A-Z]+ [^ ]*)- /\1 /; s/ +$//'; }   # %q prints - for no query: dropped
grow() { local port=$1 n s=""; for n in $(seq 1 30); do
    s="$s $($CURL --http1.1 -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json' --data-binary "{\"name\":\"Guest$n\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}" "$(B $port)/customers")"; done
  echo "  grow | 30 POST /customers (Course 6's body, Guest1..Guest30, no key header) -> statuses $(echo $s | tr ' ' '\n' | sort | uniq -c | awk '{ print $2 " x" $1 }' | paste -sd' ' -)"; }

# ---- the captures ----------------------------------------------------------------------------------------------------------------------
c_advisory() {
  echo "== S9.36: the read filed for the batch day (ADV3; not re-read: no network), before any build"
  echo "  fetched-at $(head -1 "$ADV/fetched-at.txt" | cut -c1-10) (the hour masked) · run date $(date '+%Y-%m-%d')"
  sed -n '2,$p' "$ADV/fetched-at.txt" | sed 's/^/  fetched | /'
  local n=0 v=0 f h; while read -r h f; do n=$((n + 1)); [ "$(md5 -q "$ADV/$f" 2> /dev/null)" = "$h" ] && v=$((v + 1)); done < <($G -vE '^\s*$' "$ADV/MD5SUMS.txt" | awk '$2 != "MD5SUMS.txt" { print $1, $2 }')
  echo "  MD5SUMS.txt: $n lines, $v verified (its own line, the md5 of an empty file, left out)"
  echo "  spring rows $($G -c . "$ADV/spring-index-rows-2026-11-24.txt") · naming Spring Framework $($G -c 'Spring Framework' "$ADV/spring-index-rows-2026-11-24.txt" || true)"
  echo "  tomcat page md5 $(md5 -q "$ADV/tomcat-security-11.html")"
  for a in spring-data-jpa spring-data-commons hibernate-core tomcat-embed-core jackson-databind jackson-core postgresql h2 httpclient5 spring-web; do
    g='[:.]'; case $a in jackson-databind|jackson-core) g='tools\.jackson\.core:' ;; spring-web) g='org\.springframework:' ;; esac
    echo "  t3 tree | $a $($G -E "$g$a:jar:" "$ADV/probe-tree-t3-dependency-list.txt" | head -1 | awk -F: '{ print $4 }')"; done
  echo "  t3 tree | jackson-annotations (the @JsonView annotation's jar) $($G -E 'com\.fasterxml\.jackson\.core:jackson-annotations:jar:' "$ADV/probe-tree-t3-dependency-list.txt" | head -1 | awk -F: '{ print $4 }')"
  echo "  t3 tree | coordinates $($G -cE ':jar:' "$ADV/probe-tree-t3-dependency-list.txt")"
  echo "  osv (second witness only, S2.8): $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); r=d.get("results",[]); print("%d results, %d with vulns" % (len(r), sum(1 for x in r if x.get("vulns"))))' "$ADV/osv-result.json")"
  echo "  verdict: no pin affected; evidence may proceed"; }
c_before() {
  echo "== before (21036, U13's after, H2, no harness, flag=off; the harness's exposure flag for /actuator/mappings)"
  TREE=before tb before 21036 off "" --management.endpoints.web.exposure.include=health,prometheus,mappings
  local p; for p in "$API" "$API?fields=name" /api/v1/orders /customers; do
    echo "  before | GET $p -> $($CURL --http1.1 -sS -o $J/b.b -w '%{http_code} %{content_type} %{size_download}' "$(B 21036)$p") · $(tr -d '\r\n' < $J/b.b | sed -E 's/"timestamp":"[^"]*"/"timestamp":"<masked>"/; s/"next":"[^"]*"/"next":"<cursor>"/' | cut -c1-160)"; done
  $CURL -s "$(B 21036)/actuator/mappings" | python3 -I -c '
import json,sys
d=json.load(sys.stdin); ps=[]
for c in d["contexts"].values():
    for m in c["mappings"]["dispatcherServlets"]["dispatcherServlet"]:
        rc=(m.get("details") or {}).get("requestMappingConditions")
        if rc: ps += [(tuple(rc.get("methods", [])), p) for p in rc.get("patterns", [])]
print("  before | mappings %d · with customers in the path %d · GET /api/v1/customers mapped %s (rule: the request-mapping patterns of the dispatcher servlet)" % (len(ps), sum(1 for m, p in ps if "customers" in p), "yes" if any(p == "/api/v1/customers" for m, p in ps) else "no"))'
  echo "  before | the committed spec: $(python3 -I harness/ops9s3.py ops before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tail -1) · $(wc -c < before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tr -d ' ') B md5 $(md5 -q before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json)"
  tbstop before 21036; }
c_change() {
  echo "== the modules, the change file by file"
  echo "  modules: $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' before/pom.xml | paste -sd' ' -) ($($G -c '<module>' before/pom.xml)) -> $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' after/pom.xml | paste -sd' ' -) ($($G -c '<module>' after/pom.xml))"
  local pm; pm=$(for p in pom.xml tiffinbox-core/pom.xml tiffinbox-web/pom.xml tiffinbox-client/pom.xml; do cmp -s before/$p after/$p || echo $p; done | paste -sd' ' -)
  echo "  poms before -> after/: ${pm:-equal}"
  echo "  changed (derived: diff -rq before after/, the frozen trees - git status --short c9-tiffinbox gave the same list before the commit): $(diff -rq before/ after/ | sed -E 's#^Files before/(.*) and after/.* differ$#M \1#; s#^Only in after/(.*): (.*)$#A \1/\2#; s#^Only in after/: (.*)$#A \1#; s#^Only in before/(.*): (.*)$#D \1/\2#' | sort | paste -sd'~' - | sed 's/~/ · /g')"
  local f; for f in tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerFields.java tiffinbox-web/src/test/java/com/tiffinbox/web/CustomerFieldsTest.java; do
    echo "== $f (whole, md5 $(md5 -q after/$f))"; sed 's/^/    /' after/$f; done
  echo "  the record's components: $(python3 -I -c 'import re,sys; h=re.search(r"record Customer\((.*?)\)\s*\{", open(sys.argv[1]).read(), re.S).group(1); print(",".join(re.findall(r"(?:String|int)\s+(\w+)\s*(?:,|$)", h)))' after/tiffinbox-core/src/main/java/com/tiffinbox/Customer.java)"
  echo "  the whitelist (CustomerFields.FIELDS, in order): $($G -oE 'FIELDS\.put\("[a-zA-Z]+"' after/tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerFields.java | sed -E 's/.*"(.*)"/\1/' | paste -sd, -)"
  for k in JsonView MappingJacksonValue Pageable 'offset(' Probe /probe/; do echo "  src/main grep $k: $(cd after && $G -rhF "$k" tiffinbox-web/src/main tiffinbox-core/src/main | $G -vcE '^[[:space:]]*(\*|//|/\*)' || true) code lines"; done
  echo "  application.yaml compression keys: before $($G -c 'compression' before/tiffinbox-web/src/main/resources/application.yaml || true) · after $($G -c 'compression' after/tiffinbox-web/src/main/resources/application.yaml || true)"
  echo "  handler customerFields: $(cd after && $G -rhE -A3 '@(Get|Post|Put|Patch|Delete|Request)Mapping' tiffinbox-web/src/main/java | $G -cE ' customerFields\(') occurrence(s) among the mapped handlers"
  echo "  ProblemDetail.forStatus calls in src/main (unit 03's instance view greps them): before $(cd before && $G -rc 'ProblemDetail\.forStatus' tiffinbox-web/src/main | awk -F: '{ s += $2 } END { print s }') · after $(cd after && $G -rc 'ProblemDetail\.forStatus' tiffinbox-web/src/main | awk -F: '{ s += $2 } END { print s }')"
  echo "  the web jar's Jackson databind jars: $(ls .harness/after/$XD/lib | $G -E 'jackson-databind' | paste -sd' ' -) · the @JsonView annotation's jar: $(for j in .harness/after/$XD/lib/jackson-annotations-*.jar; do unzip -l "$j" | $G -q 'com/fasterxml/jackson/annotation/JsonView.class' && basename "$j"; done)"
  echo "  the web jar's HttpClient 5: $(ls .harness/after/$XD/lib | $G -E '^httpclient5-')"; }
c_full() {
  echo "== the full list on after/ (21030, harness-free, H2, the seed's four customers, flag=off), and the old /customers beside it"
  one full 21030 $API
  one full 21030 /customers
  local m1 m2; m1=$($CURL -s "$(B 21030)$API" | md5 -q); m2=$($CURL -s "$(B 21030)/customers" | md5 -q)   # one after the other: the access log's order is fixed
  echo "  full | the two bodies byte-equal: $( [ "$m1" = "$m2" ] && echo yes || echo "no ($m1 / $m2)")"
  echo "  full | the access log (the harness's pattern, these GETs): $(acclog full | $G -E '^GET /(api/v1/)?customers ' | head -3 | paste -sd'|' -)"; }
c_fields() {
  echo "== the fieldsets on after/ (21030, the same JVM, flag=off)"
  one fields 21030 "$API?fields=name,mealType"
  one fields 21030 "$API?fields=name"
  one fields 21030 "$API?fields=mealType,name"
  one fields 21030 "$API?fields=pricePerMeal"
  echo "  fields | the access log: $(acclog full | $G -cE '^GET /api/v1/customers\?fields=' ) lines with fields=, each status 200: $(acclog full | $G -E '^GET /api/v1/customers\?fields=' | awk '$3 != 200' | wc -l | tr -d ' ') not"; }
c_refuse() {
  echo "== every refusal and every odd form of fields (after/, 21030, the same JVM, flag=off), each body read by python"
  prq "an unknown field" "?fields=nickname"
  prq "a known and an unknown field" "?fields=name,nickname"
  prq "an unknown parameter" "?colour=red"
  prq "size, which this route does not read" "?size=5"
  prq "fields empty" "?fields="
  prq "a trailing comma" "?fields=name,"
  prq "a name twice" "?fields=name,name"
  prq "case" "?fields=Name"
  prq "the parameter twice" "?fields=name&fields=mealType"
  prq "fields[]" "?fields%5B%5D=name"
  prq "a leading space" "?fields=%20name"
  prq "a malformed escape" "?fields=%zz"
  echo "  refuse | the JVM's log: lines naming an Exception $($G -cE 'Exception' .harness/run/full/jvm.log || true)"; }
c_view() {
  echo "== the harness's @JsonView route (21035, harness-joined, H2, flag=off; never in the jar)"
  one view 21035 /probe/u14/fields/view
  one view 21035 /probe/u14/fields/noview
  echo "  view | the view's bytes against the shipped route's ?fields=name,mealType bytes (the fields capture): $(curl --noproxy '*' -s "$(B 21035)/probe/u14/fields/view" | md5 -q) vs $(curl --noproxy '*' -s "$(B 21035)$API?fields=name,mealType" | md5 -q)"; }
c_mjv() {
  echo "== the harness's MappingJacksonValue route (the same JVM): the failure receipt"
  local n0; n0=$(wc -l < .harness/run/view/jvm.log | tr -d ' ')
  local w; w=$($CURL --http1.1 -sS -o $J/m.b -w '%{http_code} %{content_type}' "$(B 21035)/probe/u14/fields/mjv")
  echo "  mjv | GET /probe/u14/fields/mjv -> $w | $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); d["timestamp"]="<masked>"; print(json.dumps(d))' $J/m.b)"
  local i=0; while ! tail -n +$((n0 + 1)) .harness/run/view/jvm.log | $G -q 'UnsupportedOperationException'; do i=$((i + 1)); [ $i -lt 40 ] || break; sleep 0.05; done
  echo "  mjv | the JVM's log: $(tail -n +$((n0 + 1)) .harness/run/view/jvm.log | $G -oE 'java\.lang\.UnsupportedOperationException: MappingJacksonValue is not supported, use hints instead' | head -1)"
  echo "  mjv | the frame that threw: $(tail -n +$((n0 + 1)) .harness/run/view/jvm.log | $G -A1 '^java.lang.UnsupportedOperationException: MappingJacksonValue' | sed -n '2p' | sed -E 's/^[[:space:]]*at //; s/\(.*//')"
  echo "  mjv | MappingJacksonValue's jar: $(for j in .harness/after/$XD/lib/spring-web-*.jar; do unzip -l "$j" | $G -q 'org/springframework/http/converter/json/MappingJacksonValue.class' && basename "$j"; done) · the Jackson 3 databind on the class path: $(ls .harness/after/$XD/lib | $G -E '^jackson-databind-3')"
  QUIET=1 tbstop view 21035; }
c_floor() {
  echo "== the floor read back: Boot 4.1.3's own metadata (META-INF/spring-configuration-metadata.json of the jar that holds server.compression)"
  local j; for j in .harness/after/$XD/lib/spring-boot-*.jar; do unzip -p "$j" META-INF/spring-configuration-metadata.json 2> /dev/null | $G -q '"server.compression' && { MJ=$j; break; }; done
  echo "  floor | the jar: $(basename "$MJ")"
  unzip -p "$MJ" META-INF/spring-configuration-metadata.json | python3 -I -c '
import json,sys
d=json.load(sys.stdin); ps=[p for p in d["properties"] if p["name"].startswith("server.compression.")]
print("  floor | keys %d: %s" % (len(ps), ", ".join(sorted(p["name"] for p in ps))))
for p in sorted(ps, key=lambda p: p["name"]):
    if "defaultValue" in p and not isinstance(p["defaultValue"], list): print("  floor | %s default %s" % (p["name"], json.dumps(p["defaultValue"])))
mt=[p for p in ps if p["name"]=="server.compression.mime-types"][0]["defaultValue"]
print("  floor | mime-types default: %d entries" % len(mt))
for m in mt: print("  floor | mime-type %s" % m)
print("  floor | application/json in the list: %s · application/hal+json: %s · application/problem+json: %s" % tuple("yes" if x in mt else "no" for x in ("application/json","application/hal+json","application/problem+json")))'
  echo "== 4 customers, gzip asked, flag=on (21030, a fresh harness-free JVM, the access log on)"
  one floor 21030 /customers -H 'Accept-Encoding: gzip'
  one floor 21030 $API -H 'Accept-Encoding: gzip'
  echo "  floor | the access log: $(acclog grown | $G -E '^GET /(api/v1/)?customers ' | paste -sd'|' -)"; }
c_page() {
  echo "== Course 6's page, re-measured on this pin: GET /dashboard, Accept: text/html, flag=on, 4 customers (the same JVM, before the POSTs)"
  one page 21030 /dashboard -H 'Accept: text/html'
  cp $J/o.b $J/page-plain.b
  one page 21030 /dashboard -H 'Accept: text/html' -H 'Accept-Encoding: gzip'
  echo "  page | gunzip -c, the saved bytes: $(gunzip -c < $J/o.b | wc -c | tr -d ' ') B md5 $(gunzip -c < $J/o.b | md5 -q) · equal to the plain answer: $(gunzip -c < $J/o.b | cmp -s - $J/page-plain.b && echo yes || echo no)"
  echo "  page | the stylesheet the page names: $($G -oE '/css/[^"]*' $J/page-plain.b | head -1)"
  echo "  page | the access log: $(acclog grown | $G -E '^GET /dashboard ' | paste -sd'|' -)"; }
c_grown() {
  echo "== the list grown past the floor (the same JVM, flag=on): 30 POSTs, then both list routes, plain and gzip asked"
  grow 21030
  local p; for p in /customers $API; do
    one grown 21030 $p
    cp $J/o.b $J/g-plain.b
    one grown 21030 $p -H 'Accept-Encoding: gzip'
    echo "  grown | $p gunzip -c: $(gunzip -c < $J/o.b | wc -c | tr -d ' ') B md5 $(gunzip -c < $J/o.b | md5 -q) · equal to the plain answer: $(gunzip -c < $J/o.b | cmp -s - $J/g-plain.b && echo yes || echo no)"; done
  echo "  grown | the access log's %b for the gzip-asked GETs: $(acclog grown | $G -E '^GET /(api/v1/)?customers 200 [0-9]+ "gzip" "gzip"' | awk '{ print $2 ":" $4 }' | paste -sd' ' -) · for the plain GETs: $(acclog grown | $G -E '^GET /(api/v1/)?customers 200 [0-9]+ "-"' | tail -2 | awk '{ print $2 ":" $4 }' | paste -sd' ' -)"; }
c_under() {
  echo "== the fieldsets at 34 customers (the same JVM, flag=on), plain and gzip asked"
  local q; for q in "?fields=name" "?fields=name,mealType"; do
    one under 21030 "$API$q"
    one under 21030 "$API$q" -H 'Accept-Encoding: gzip'; done
  echo "  under | the floor read back (the floor capture): $(unzip -p "$MJ" META-INF/spring-configuration-metadata.json | python3 -I -c 'import json,sys; print([p["defaultValue"] for p in json.load(sys.stdin)["properties"] if p["name"]=="server.compression.min-response-size"][0])')"
  echo "  under | the access log: $(acclog grown | $G -E '^GET /api/v1/customers\?fields=' | paste -sd'|' -)"
  QUIET=1 tbstop grown 21030; }
c_clients() {
  echo "== three client factories (the harness's Gzip14, its class path after/'s extracted lib/ plus the harness) against GET /customers at 34 customers (21035, harness-joined, flag=on, the access log on)"
  ACC=1 tb clients 21035 on 1
  grow 21035
  echo "  clients | the class path: $(ls .harness/after/$XD/lib | $G -E '^(httpclient5|httpcore5|spring-web)-' | paste -sd' ' -)"
  bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -cp \"$CPA:.harness/hc\" probe.u14.Gzip14 $(B 21035)/customers" $J/gz.out
  echo "  clients | Gzip14 exit $RE"
  sed 's/^/  clients | /' $J/gz.out | $G 'CLIENT '
  echo "  clients | Tomcat saw (the access log, the three GETs): $(acclog clients | $G -E '^GET /customers ' | paste -sd'|' -)"
  echo "  clients | the JDK: $(java -version 2>&1 | head -1 | sed -E 's/.*"(.*)".*/\1/')"
  local c6=../c6-unit30/README.md
  echo "  clients | Course 6's factory line ($c6:$($G -n 'RestClient.create(): its request factory' $c6 | head -1 | cut -d: -f1)): $($G 'RestClient.create(): its request factory' $c6 | head -1 | sed 's/^ *//')"
  echo "  clients | Course 6's access-log line for that factory ($c6:$($G -n 'upgrade:h2c accept-encoding:gzip,deflate' $c6 | head -1 | cut -d: -f1)): $($G 'upgrade:h2c accept-encoding:gzip,deflate' $c6 | head -1 | sed 's/^ *//')"
  echo "  clients | Course 6's class path ($c6:$($G -n 'httpclient5, Jetty' $c6 | head -1 | cut -d: -f1)): $($G 'httpclient5, Jetty' $c6 | head -1 | sed 's/^ *//')"
  QUIET=1 tbstop clients 21035; }
oldsurface2() { local port=$1 out=$2 BB="http://127.0.0.1:$1" t=$U/$J/os
  local gz=(); [ -n "${GZ:-}" ] && gz=(-H 'Accept-Encoding: gzip')
  printf 'name,mealsPerDay,pricePerMeal,mealType\nChitra,1,130,VEGAN\n' > "$t.csv"; : > "$out"
  one1() { local label=$1; shift; local w rc
    w=$($CURL --http1.1 -sS -D "$t.h" -o "$t.b" -w '%{http_code} %{content_type} %{size_download}' --max-time 10 "${gz[@]}" "$@" 2>"$t.e"); rc=$?
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
     curl --noproxy '*' --http1.1 -sS -N -D "$t.h" "${gz[@]}" -H 'Accept: text/event-stream' "$BB/customers/feed" > "$t.b" 2>"$t.e"; local frc=$?
  { echo "== GET /customers/feed (by count: headers + the first event, to its blank line, alarm 10 s) -> $(tr -d '\r' < "$t.h" | head -1 | cut -d' ' -f2) $(tr -d '\r' < "$t.h" | $G -i '^Content-Type:' | cut -d' ' -f2) $(wc -c < "$t.b" | tr -d ' ') (reader exit $frc)"
    tr -d '\r' < "$t.h" | sed -E 's/^(Date|date): .*/\1: <masked>/; s/(JSESSIONID=)[^;]*/\1<masked>/; s/^(Keep-Alive): .*/\1: <masked>/' | $G -v '^$'; echo "body: $(tr -d '\r' < "$t.b" | tr '\n' '~')"; } >> "$out"
  one1 "GET /kitchen" "$BB/kitchen"
  one1 "GET /nowhere" "$BB/nowhere"
  one1 "POST /shutdown (no token, last)" -X POST "$BB/shutdown"
  rm -f "$t".*; }
c_yaml() {
  echo "== compression put in application.yaml (the plant: a scratch copy of after/, .harness/need-yaml, never c9-tiffinbox), against after/ flag=off; the old surface with gzip asked on every request, the same client; H2"
  copy after .harness/need-yaml
  python3 -I - .harness/need-yaml/tiffinbox-web/src/main/resources/application.yaml <<'PY'
import sys
p = sys.argv[1]; s = open(p).read(); a = "server:\n  address: ${tiffinbox.address}\n"
assert s.count(a) == 1
open(p, "w").write(s.replace(a, "server:\n  compression:\n    enabled: true\n  address: ${tiffinbox.address}\n"))
print("  yaml | the scratch copy's application.yaml: server.compression.enabled: true added (2 lines)")
PY
  echo "  yaml | the copy's compression keys: $($G -c 'compression' .harness/need-yaml/tiffinbox-web/src/main/resources/application.yaml) · after/'s: $($G -c 'compression' after/tiffinbox-web/src/main/resources/application.yaml || true)"
  guard "the yaml copy's build"
  bg "cd .harness/need-yaml && $MV -DskipTests clean package -pl tiffinbox-web -am" .harness/build-need-yaml.log
  [ "$RE" = 0 ] || die "the yaml copy did not build"; offl .harness/build-need-yaml.log
  echo "  yaml | built (mvn -o -DskipTests clean package -pl tiffinbox-web -am; exit 0)"
  extract need-yaml
  TREE=need-yaml tb yaml-on 21033 off "" > /dev/null; GZ=1 oldsurface2 21033 $J/yaml-on.txt; QUIET=1 tbstop yaml-on 21033
  tb yaml-off 21030 off "" > /dev/null; GZ=1 oldsurface2 21030 $J/yaml-off.txt; QUIET=1 tbstop yaml-off 21030
  echo "  yaml | the old surface, gzip asked: after/ flag=off $(md5 -q $J/yaml-off.txt) ($($G -c '^== ' $J/yaml-off.txt) requests) · the yaml copy $(md5 -q $J/yaml-on.txt) ($($G -c '^== ' $J/yaml-on.txt) requests)"
  diff $J/yaml-off.txt $J/yaml-on.txt | $G '^[<>]' | sed 's/^/  yaml | diff /'
  python3 -I - $J/yaml-off.txt $J/yaml-on.txt <<'PY'
import sys
def blocks(f):
    out, cur = {}, None
    for l in open(f).read().splitlines():
        if l.startswith("== "): cur = l.split(" -> ")[0][3:]; out[cur] = []
        elif cur: out[cur].append(l)
    return out
a, b = blocks(sys.argv[1]), blocks(sys.argv[2])
moved = [k for k in a if a[k] != b.get(k)]
print("  yaml | answers that differ: %d - %s" % (len(moved), "; ".join(moved) or "none"))
for k in moved:
    add = [l for l in b[k] if l not in a[k]]; rem = [l for l in a[k] if l not in b[k]]
    print("  yaml | %s: added %s · removed %s" % (k, add, rem))
PY
  TREE=need-yaml tb yaml-seven 21033 off "" > /dev/null
  sh $CURLSET 21033 .harness/run/yaml-seven/secrets/tiffinbox/shutdown-token > $J/seven-yaml.txt 2>&1
  local i=0; while kill -0 "$(cat .harness/run/yaml-seven/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 60 ] || break; sleep 0.05; done
  QUIET=1 tbstop yaml-seven 21033
  echo "  yaml | the seven under the key (its own client, no gzip asked): $(md5 -q $J/seven-yaml.txt) · expected $S466"; }
c_spec() {
  echo "== the committed spec: regenerated in this commit; read here against the served document (after/, 21030, no harness, flag=off)"
  tb spec 21030 off "" > /dev/null
  local SF=after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json
  $CURL -s "$(B 21030)/v3/api-docs" > $J/served.json
  echo "  the committed file against the served document (servers removed): $(python3 -I -c '
import json,sys
d=json.load(open(sys.argv[1])); d.pop("servers",None)
print("equal" if json.dumps(d,indent=2,ensure_ascii=False)+"\n" == open(sys.argv[2],encoding="utf-8").read() else "differ")' $J/served.json $SF)"
  local BF=before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json
  echo "  committed md5 before $(md5 -q $BF) · after $(md5 -q $SF) · bytes before $(wc -c < $BF | tr -d ' ') · after $(wc -c < $SF | tr -d ' ')"
  echo "  the diff against before's (fd06e77's) file: $(diff $BF $SF | $G -c '^>') lines added, $(diff $BF $SF | $G -c '^<') removed"
  diff $BF $SF | $G '^[0-9]' | sed 's/^/  hunk /'
  echo "  the paths added: $(python3 -I -c 'import json,sys; a=json.load(open(sys.argv[1]))["paths"]; b=json.load(open(sys.argv[2]))["paths"]; print(sorted(set(b)-set(a)), "removed", sorted(set(a)-set(b)), "other paths moved", [k for k in a if k in b and a[k]!=b[k]], "components moved", json.load(open(sys.argv[1]))["components"]!=json.load(open(sys.argv[2]))["components"])' $BF $SF)"
  python3 -I harness/ops9s3.py ops $BF > $J/ops-before.txt; python3 -I harness/ops9s3.py ops $SF > $J/ops-after.txt
  echo "  before: $(tail -1 $J/ops-before.txt) · after: $(tail -1 $J/ops-after.txt)"
  echo "  the old operations' ids before -> after: $( [ -z "$(diff <($G -E '^  [A-Z]+ ' $J/ops-before.txt) <($G -E '^  [A-Z]+ ' $J/ops-after.txt) | $G '^<')" ] && echo equal || echo differ)"
  diff <($G -E '^  [A-Z]+ ' $J/ops-before.txt) <($G -E '^  [A-Z]+ ' $J/ops-after.txt) | $G '^[<>]' | sed 's/^/  ops moved | /'
  printf '{}' > $J/empty.json; python3 -I harness/ops9s3.py ops $J/empty.json > /dev/null 2>&1; echo "  ops9s3.py on an empty spec: exit $? (refused)"
  echo "  operationIds unique: $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); i=[o.get("operationId") for v in d["paths"].values() for o in v.values()]; print("yes" if len(i)==len(set(i)) else "no")' $SF)"
  python3 -I harness/ops9s3.py media $SF $API | sed 's/^/  spec | /'
  $CURL --http1.1 -s -D $J/sw.h -o $J/sw.b "$(B 21030)$API"; $CURL --http1.1 -s -o $J/sw2.b "$(B 21030)$API?fields=mealsPerDay"
  local w4; w4=$($CURL -s -o /dev/null -w '%{content_type}' "$(B 21030)$API?fields=nickname")
  echo "  spec vs wire | 200 $(python3 -I -c 'import json,sys; r=json.load(open(sys.argv[1]))["paths"]["/api/v1/customers"]["get"]["responses"]["200"]["content"]; k=list(r)[0]; s=r[k]["schema"]; print(k, s["type"], s["items"]["$ref"].split("/")[-1])' $SF) · wire 200 $(tr -d '\r' < $J/sw.h | sed -n 's/^Content-Type: //p') $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print("array" if isinstance(d,list) else "object", "members", list(d[0]))' $J/sw.b) · schema properties $(python3 -I -c 'import json,sys; s=json.load(open(sys.argv[1]))["components"]["schemas"]["Customer"]; print(list(s["properties"]), "required", sorted(s.get("required",[])))' $SF)"
  echo "  spec vs wire | the gap, named: ?fields=mealsPerDay answers members $(python3 -I -c 'import json,sys; print(list(json.load(open(sys.argv[1]))[0]))' $J/sw2.b) - the schema's required members absent from a fieldset answer (the description says the members vary; the schema does not)"
  echo "  spec vs wire | 400 $(python3 -I -c 'import json,sys; r=json.load(open(sys.argv[1]))["paths"]["/api/v1/customers"]["get"]["responses"]["400"]["content"]; k=list(r)[0]; print(k, r[k]["schema"]["$ref"].split("/")[-1])' $SF) · wire 400 $w4"
  echo "  the parameters: $(python3 -I -c 'import json,sys; print([(p["name"], p["in"], p["schema"]["type"], p.get("required")) for p in json.load(open(sys.argv[1]))["paths"]["/api/v1/customers"]["get"]["parameters"]])' $SF)"
  echo "  OpenApiSpecTest on the regenerated file: $(python3 -I -c '
import sys,xml.etree.ElementTree as E
r=E.parse(sys.argv[1]).getroot(); print("tests %s failures %s errors %s" % (r.get("tests"), r.get("failures"), r.get("errors")))' .harness/after/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.OpenApiSpecTest.xml) (after/'s build)"
  QUIET=1 tbstop spec 21030
  echo "== the client rebuilt on the regenerated spec: before's client (-pl tiffinbox-client -am on a copy of before) and after/'s (its build)"
  copy before .harness/client-before; guard "before's client"
  bg "cd .harness/client-before && $MV -DskipTests clean package -pl tiffinbox-client -am" .harness/build-client-before.log; offl .harness/build-client-before.log
  local GB=.harness/client-before/tiffinbox-client/target/generated-sources/openapi GA=.harness/after/tiffinbox-client/target/generated-sources/openapi
  echo "  the client: FILES $($G -c '\.java$' $GB/.openapi-generator/FILES) -> $($G -c '\.java$' $GA/.openapi-generator/FILES) · build exit $RE (before's) / 0 (after/'s, its reactor) · tracked generated files in the anchor: $(cd .. && git ls-files c9-tiffinbox/tiffinbox-client | $G -c 'generated' || true)"
  diff <($G '\.java$' $GB/.openapi-generator/FILES) <($G '\.java$' $GA/.openapi-generator/FILES) | $G '^[<>]' | sed 's/^/  the client: files /'
  local f s ne=0 nd=0 nn=0 nm=0 ng=0; for f in $(cd $GA && $G '\.java$' .openapi-generator/FILES); do
    if [ -f $GB/$f ]; then if cmp -s $GB/$f $GA/$f; then s=equal; ne=$((ne + 1)); elif [ "$($G -v '^@Generated(' $GB/$f | md5 -q)" = "$($G -v '^@Generated(' $GA/$f | md5 -q)" ]; then s="date line only"; nd=$((nd + 1)); elif [ -z "$(diff <($G -v '^@Generated(' $GB/$f) <($G -v '^@Generated(' $GA/$f) | $G '^<')" ]; then s="lines added only (the new operation), the date line aside"; ng=$((ng + 1)); else s=moved; nm=$((nm + 1)); fi; else s=added; nn=$((nn + 1)); fi
    echo "  the client: $f $s"; done
  echo "  the client: counts - equal $ne · date line only $nd · lines added only $ng · moved $nm · added $nn"
  diff $GB/src/main/java/com/tiffinbox/client/api/ApiApi.java $GA/src/main/java/com/tiffinbox/client/api/ApiApi.java | $G '^[<>]' | $G -v '@Generated(' | head -12 | sed 's/^/  the client: ApiApi diff /'
  echo "  the client: ApiApi.java customerFields: $($G -c 'customerFields(' $GA/src/main/java/com/tiffinbox/client/api/ApiApi.java) · the new operation's group: ApiApi (the first path segment, api)"; }
movedone() { local port=$1 m=$2 p=$3 w; shift 3; : > $J/mv.h; : > $J/mv.b
  w=$($CURL --http1.1 -sS -D $J/mv.h -o $J/mv.b -w '%{http_code} %{content_type} %{size_download}' --max-time 5 -X "$m" "$@" "$(B $port)$p" 2> /dev/null)
  local bm; bm=$(sed -E 's/"timestamp":"[^"]*"/"timestamp":"<masked>"/; s/"next":"[^"]*"/"next":"<cursor>"/; s/(127\.0\.0\.1|localhost):[0-9]{4,5}/\1:<port>/g' $J/mv.b | md5 -q | cut -c1-12)
  w=$(echo "$w" | awk '{ print $1, $2 }')
  echo "  $SIDE | $m $p$( [ -n "${TAG:-}" ] && echo " [$TAG]") -> $w · Allow {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Aa]llow: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)} · Accept-Patch {$(tr -d '\r' < $J/mv.h | sed -n 's/^[Aa]ccept-[Pp]atch: //p' | tr -d ' ' | tr ',' '\n' | $G -v '^$' | sort | paste -sd, -)} · body $bm"; }
MPT='Content-Type: application/merge-patch+json'; JPT='Content-Type: application/json-patch+json'; CAPI=/api/v1/customers
movedside() { local side=$1 port=$2 a
  TREE=$side tb moved-$side $port off ""
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
  movedone $port GET /api/v1/orders
  movedone $port GET $API
  movedone $port OPTIONS $API
  QUIET=1 tbstop moved-$side $port; }
c_moved() { echo "== U13's requests (its movedside list, copied; the order list's page one with its cursor masked; /v3/api-docs left out: the spec capture reads it) and the new route, on before (21036) and after/ (21030), H2, each its own JVM, no harness, flag=off"
  movedside before 21036; movedside after 21030
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
  echo "  the web jar's md5: before $(md5 -q .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | cut -c1-8) · after $(md5 -q .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | cut -c1-8) ($(cmp -s .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar && echo equal || echo differ))"
  echo "  BOOT-INF/lib names: before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ') · moved $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c '^[<>]' || true)"; }
c_seven() {
  echo "== the seven (c5-unit11/curlset.sh, no key header), each tree its own JVM, H2, no harness, flag=off - not a witness for the new route: it sends nothing to /api/v1/customers"
  echo "  expected $S466"
  local s port i; for s in before after; do [ $s = before ] && port=21036 || port=21030
    TREE=$s tb seven-$s $port off "" > /dev/null
    sh $CURLSET $port .harness/run/seven-$s/secrets/tiffinbox/shutdown-token > $J/seven-$s.txt 2>&1
    i=0; while kill -0 "$(cat .harness/run/seven-$s/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 60 ] || break; sleep 0.05; done
    QUIET=1 tbstop seven-$s $port
    echo "  $s: the seven $(md5 -q $J/seven-$s.txt) ($(wc -l < $J/seven-$s.txt | tr -d ' ') lines)"; done
  echo "  the seven's paths (read off curlset.sh): $($G -oE '^req [A-Z]+ /[a-z]*' $CURLSET | awk '{ print $3 }' | paste -sd' ' -) and POST /shutdown - none under /api/"; }
c_surface() { local side port
  echo "== the old surface by count (U13's reader, copied), each tree its own JVM, H2, no harness, flag=off - not a witness for the new route"
  echo "  expected $U4SURF"
  for side in before after; do [ $side = before ] && port=21036 || port=21030
    TREE=$side tb surface-$side $port off "" > /dev/null
    oldsurface2 $port $J/surface-$side.txt
    QUIET=1 tbstop surface-$side $port
    echo "  $side: the old surface $(md5 -q $J/surface-$side.txt) ($($G -c '^== ' $J/surface-$side.txt) requests, $(wc -l < $J/surface-$side.txt | tr -d ' ') lines)"; done
  echo "  before -> after/: $(cmp -s $J/surface-before.txt $J/surface-after.txt && echo equal || echo DIFFER)"
  echo "== the S9.14 plant (1/1 per run): after/ with Spring MVC's problem details off (--spring.mvc.problemdetails.enabled=false), 21034 - the check that can fail"
  tb surface-plant 21034 off "" --spring.mvc.problemdetails.enabled=false > /dev/null
  oldsurface2 21034 $J/surface-plant.txt; QUIET=1 tbstop surface-plant 21034
  echo "  ~ plant (21034, the S9.14 slot): the old surface $(md5 -q $J/surface-plant.txt) - $(cmp -s $J/surface-plant.txt $J/surface-after.txt && echo 'EQUAL (the plant was not seen)' || echo 'moved, as planted')"; }
c_inert() {
  echo "== the key header across this run's captures (request lines and bodies)"
  echo "  request lines naming the key header across the captures: $(cat .r-*.new 2> /dev/null | $G -ciF "$KW" || true)"
  echo "  the 30 POSTs of grown and clients go through the old public POST /customers, with no key header; IdempotencyKeyFilter's table names POST /api/v1/customers/{name}/pauses only (read): $($G -c 'POST' after/tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java) POST lines in the filter"
  echo "  MockMvc runs: CustomerFieldsTest sends GETs only; no request of this unit carries the key"; }
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
  copy after .harness/pkg; copy after .harness/tests; copy after .harness/webonly
  guard "mvn package"
  bg "cd .harness/pkg && $MV \"$AL\" clean package" .harness/pkg.log; local pre=$RE
  echo "  mvn package exit $pre"; reactor .harness/pkg.log
  for p in web client; do surefire .harness/pkg/tiffinbox-$p/target/surefire-reports "package | tiffinbox-$p"; done
  for c in CustomerFieldsTest OrderPagesTest ApiVersionTest TiffinBoxRestDocsTest OpenApiSpecTest TiffinBoxWebTest; do cls .harness/pkg/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.$c.xml package $c; done
  $G -E '^CustomerFieldsTest: ' .harness/pkg.log | sed 's/^/  printed | /'
  echo "== the Docker-free twin: after/'s own build (DOCKER_HOST=unix:///nonexistent/docker.sock, the run's first build)"
  for p in web client; do surefire .harness/after/tiffinbox-$p/target/surefire-reports "twin | tiffinbox-$p"; done
  echo "  slice TiffinBoxWebTest: before $(python3 -I -c 'import re,sys; print(len(re.findall(r"^\s+@Test\b", open(sys.argv[1]).read(), re.M)))' before/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java) · after $(python3 -I -c 'import xml.etree.ElementTree as E,sys; print(E.parse(sys.argv[1]).getroot().get("tests"))' .harness/pkg/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.TiffinBoxWebTest.xml) (before: its @Test lines; after: Surefire's XML) · the slice's file byte-equal to before's: $(cmp -s before/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java after/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java && echo yes || echo no) - measured: no slice edit needed, CustomerRepository is already mocked ($($G -c '@MockitoBean CustomerRepository' after/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java) line)"
  echo "  web tests before (unit 13's values): $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit13/README.md | $G -oE 'web_tests=[0-9]+' | head -1 | cut -d= -f2) · new @Test lines $($G -cE '^ +@Test$' after/tiffinbox-web/src/test/java/com/tiffinbox/web/CustomerFieldsTest.java)"
  echo "  test files moved before -> after: $(for p in $(cd before && find tiffinbox-web/src/test -type f | sort); do cmp -s before/$p after/$p || basename $p; done | paste -sd, -) · new: $(cd after && for p in $(find tiffinbox-web/src/test -type f | sort); do [ -e ../before/$p ] || basename $p; done | paste -sd, -)"
  echo "  the test classes that send /api/v1/ (grep -l): $( (cd after && $G -rl '/api/v1/' tiffinbox-web/src/test/java) | sed 's#.*/##; s#\.java$##' | sort | paste -sd, -)"
  echo "== mvn -o clean verify on a copy of after/ (.harness/tests): Surefire's tests on H2 in memory, then the five ITs on PostgreSQL 18.6 in Testcontainers containers (21280-21284)"
  for p in 21280 21281 21282 21283 21284 18881 18882 18883 18884; do [ "$(listeners $p)" = 0 ] || die "$p is bound before verify"; done
  guard "mvn verify"
  bg "cd .harness/tests && DOCKER_HOST=\"$DH\" TESTCONTAINERS_RYUK_DISABLED=true $MV \"$AL\" clean verify" .harness/verify.log; local vre=$RE
  reactor .harness/verify.log
  surefire .harness/tests/tiffinbox-web/target/surefire-reports "verify | tiffinbox-web"
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
  echo "  Testcontainers containers after: $(dk ps -aq --filter label=org.testcontainers=true | wc -l | tr -d ' ') · images pulled: $($G -ciE 'Pulling image|pull(ed|ing) ' .harness/verify.log || true)"
  echo "== the hand-built form: mvn -o clean package -pl tiffinbox-web -am on a copy of after/ (.harness/webonly), Docker-free"
  guard "the web-only form"
  bg "cd .harness/webonly && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package -pl tiffinbox-web -am" .harness/webonly.log
  surefire .harness/webonly/tiffinbox-web/target/surefire-reports "webonly | tiffinbox-web"
  echo "  downloads across the builds: $(cat .harness/pkg.log .harness/verify.log .harness/webonly.log .harness/build-after.log .harness/build-before.log .harness/build-need-yaml.log .harness/build-client-before.log 2> /dev/null | $G -cE 'Download(ing|ed) from ' || true)"
  echo "  BOOT-INF/lib: before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ')"; }
exrun() { local v=$1 sh=$2 o cmd
  guard "the exercise, $v, $sh"
  rm -rf .harness/exercise/tree; copy after .harness/exercise/tree
  case $v in broken) cmd='sh break.sh "$0" > /dev/null && sh check.sh "$0"' ;; solved) cmd='sh break.sh "$0" > /dev/null && sh apply.sh "$0" > /dev/null && sh check.sh "$0"' ;; *) cmd="sh break.sh \"\$0\" > /dev/null && HOW=$v sh apply.sh \"\$0\" > /dev/null && sh check.sh \"\$0\"" ;; esac
  if [ $sh = bash ]; then o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21038 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock bash -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1)
  else o=$(cd exercise && env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21038 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock /bin/zsh -f -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1); fi
  local pre="  $v $sh |"; [ $v = broken ] || [ $v = solved ] || pre="  ~ $v $sh |"
  printf '%s\n' "$o" | sed -E "s/127\.0\.0\.1:21038/127.0.0.1:<port>/g; s/^/$pre /"
  [ ! -f exercise/check.build.log ] || offl exercise/check.build.log
  [ "$(listeners 21038)" = 0 ] || die "the exercise left something listening on 21038"; }
c_exercise() { local v sh
  rm -rf .harness/exercise; mkdir -p .harness/exercise
  for v in broken solved; do for sh in bash zsh; do echo "  == $v, $sh"; exrun $v $sh; done; done
  if [ "$RUNNO" = 1 ] || [ "$RUNNO" = 0 ]; then for v in typed200 404 dropunknown rawmap fixedelsewhere; do exrun $v bash; done; fi
  rm -rf exercise/check.run; rm -f exercise/check.build.log exercise/check.jvm.log exercise/check.b exercise/check.h
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures${DEVCAPS:+ (DEVELOPMENT: only $DEVCAPS - not a run of record)}"
cap advisory c_advisory
cap before c_before
cap change c_change
ACC=1 tb full 21030 off "" > .harness/full.up; cat .harness/full.up
cap full c_full
cap fields c_fields
cap refuse c_refuse
tbstop full 21030
tb view 21035 off 1 > .harness/view.up; cat .harness/view.up
cap view c_view
cap mjv c_mjv
ACC=1 tb grown 21030 on "" > .harness/grown.up; cat .harness/grown.up
cap floor c_floor
cap page c_page
cap grown c_grown
cap under c_under
cap clients c_clients
cap yaml c_yaml
cap spec c_spec
cap moved c_moved
cap seven c_seven
cap surface c_surface
cap tests c_tests
cap exercise c_exercise
cap inert c_inert
echo "== plants (each made to FAIL first on a copy of this run's capture; harness/chk14.py plants)"
PL=$(ck plants .) || die "a plant was not caught: $(printf '%s\n' "$PL" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$PL" | $G '^ok ' | sed 's/^ok /  /'
PLV=$(printf '%s\n' "$PL" | sed -n 's/^VALUES //p')

# ---- the end: the sweep, the values, the published hashes -------------------------------------------------------------------------------
[ -z "$(echo $PIDS)" ] || die "a JVM of this run is still running: $PIDS"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
[ -z "$(dk ps -aq --filter label=org.testcontainers=true)" ] || die "a Testcontainers container of this run is left"
[ -z "$(dk ps -aq --filter name=^/c9u14-)" ] || die "a c9u14-* container is left"
NI1=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI1" = "$NI0" ] && [ "$VOL1" = "$VOL0" ] || die "R.322: images $NI0 -> $NI1, volumes $VOL0 -> $VOL1"
AD1=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true); [ "$AD1" = "$AD" ] || die "the anchor moved during the run"
pin before-tree before; pin after-tree after
MDB=$(find . ../c9-tiffinbox ../c9-unit13 -name '*.mv.db' -not -path './.harness/*' -not -path '../c9-unit13/.harness/*' 2> /dev/null | wc -l | tr -d ' ')
[ "$MDB" = 0 ] || die "an H2 file outside .harness/"
[ -z "$(ls exercise | $G -v -xE 'README.md|SOLUTION.md|apply.sh|break.sh|check.sh')" ] || die "the exercise left a file in exercise/"
VALS="$VALS
plants: $PLV
build: seed_files=$NF0 seed_bytes=$NB0 central_only=$CO"
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
[ -n "${DEVCAPS:-}" ] && { echo "c9-unit14: DEVELOPMENT run ($DEVCAPS) - nothing published"; exit 2; }
VO=$(ck values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; [ -n "${NOPIN:-}" ] || die "README.md's values block is not this run's"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM of this run, ports free, no container left, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1 · the anchor against after/ as at the start · the tree pins · *.mv.db outside .harness 0"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit14: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit14: every capture = published ($NCAPS) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')"
