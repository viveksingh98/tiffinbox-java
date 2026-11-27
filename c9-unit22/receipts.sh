#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 9 · Unit 22 "Input Hardening" - this unit's receipts. Course 9's EIGHTEENTH anchor change, Section 4's fourth: before is a link
# to ../c9-unit21/after (U21's after); after/ is a frozen copy of ../c9-tiffinbox after this unit's change - ONE line of
# tiffinbox-web/src/main moves (CustomerPatches.readBack reads with its own strict reader, readerFor(Customer.class)
# .with(FAIL_ON_UNKNOWN_PROPERTIES), plus its import and one sentence of the class comment), InputHardeningTest is added, and the
# anchor's README card. No pom, no application.yaml key, no route, no migration, no spec byte.
# The harness's things, labelled on every capture that uses one (R.397): the harness's entity-bound route (harness/src/probe22/Bind.java,
# the held ev22 run's, byte for byte), the record route (harness/src/probe22b/Rec.java, BLUE C9-U22's, byte for byte), the harness's copy
# with the key (after/'s jar started with spring.jackson.deserialization.fail-on-unknown-properties=true as a run flag - never the
# anchor), the limits reader (harness/src/probe22/Limits.java), and the drivers bind.py, rec.py, reach.py, norm.py (the normaliser).
# Captures (once per run of record; their 3/3 is across the three runs, hashed in receipts.md5; lines starting "  ~" are run-variant and
# left out of the hash - the exercise's refused variants of run 1, the JDK's version):
#   advisory  the S9.36 read filed for this section (ADV4), verified, before any build
#   before    before's yaml (no key), its readBack line, its counters
#   change    the modules, the derived changed list, the one-line diff, the new test whole, the byte-equal files
#   census    the controllers on before and after/ by unit 15's printed rule
#   drop      the hook's request (POST /customers, version 99 and two more extras) on before (21166) and after/ (21160): 201, read back
#   bind      the harness's entity-bound route on before (21166), H2 and PostgreSQL 18.6 (c9u22-pg, 21161): each member's outcome
#   record    the cure: the record route beside the entity route on one JVM (after/, 21168), H2 and PostgreSQL, rows read back
#   strict    the reach inventory, then the 25 reach requests on before (21166) and after/ (21160), H2 and PostgreSQL: 3 moved
#   key       the harness's copy with the key (21162), H2 and PostgreSQL: the cost (the old POST's answers move)
#   limits    Jackson 3's read constraints (the library's defaults) and Boot's metadata for the request-size keys - no attack
#   spec      the committed spec against the served document (after/, 21160): unchanged
#   moved     the web jar's, the core jar's and the client main jar's entries before -> after; BOOT-INF/lib by name
#   api       every GET of the committed spec's /api/v1/ paths on before (21166) and after/ (21160) - not a witness for the refusal
#   seven     c5-unit11's seven · surface: the old surface by count - not witnesses for the refusal
#   tests     the need-measure (before + the new test), after/'s own build (Docker-free), verify (the five ITs)
#   harness   the folder's files, the copied and adapted instruments with their named diffs, the static check (three runs)
#   exercise  break.sh, check.sh, apply.sh on 21168, bash and zsh -f; the refused variants (run 1)
#   title     the title for search
# Ports (U22's band, 21160-21169, the course's one exception to §P): 21160 after/ · 21161 PostgreSQL (c9u22-pg) · 21162 the harness's
# copy with the key · 21166 before · 21168 the record JVM and the exercise · 21163-21165, 21167, 21169 and 21110-21119 never bound.
# During mvn verify only: 21280-21284. Every store on 127.0.0.1; every curl --noproxy '*'.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
C9R=${C9R:-"/Users/$ME/Downloads/Youtube Content/LearnProgrammingWithVivek/rest-apis-done-right"}   # the course's folder (briefs, research)
SEED=${SEED:-"$C9R/_research/m2-seed-c9-s4"}   # the course's Section 4 seed
PK4="$C9R/_research/s4-probe-2026-11-27"; BK4="$C9R/_research/u22-blue-2026-11-27"; HELD="$C9R/_held/ev22-2026-11-27"; ADV="$C9R/_research/docs-2026-11-27/advisories-s4probe"
S4B="$C9R/_briefs/UNIT-BRIEFS-S4-OPERATING.md"
export C9R
RUNNO=${RUNNO:-0}                                     # the run of record's number (1, 2, 3); 0 = development
H21=afba429                                           # unit 21's commit: the static check reads its objects, never the live anchor
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
export DOCKER_HOST="$DH"
PIMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873   # postgres:18-alpine by digest (U20's), never pulled
CN=c9u22-pg
PIDS=""; INTR=""; mpid=""; CTRS=""
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in $mpid $PIDS; do [ -z "$p" ] || killtree "$p"; done; for p in $mpid $PIDS; do if kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; for c in $CTRS; do dk rm -fv "$c" > /dev/null 2>&1; done; for c in $(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null); do dk rm -fv "$c" > /dev/null 2>&1; done; rm -rf exercise/check.run; rm -f exercise/check.build.log; [ -z "$INTR" ] || rm -f .r-*.new; rmdir .r-lock 2> /dev/null || rm -rf .r-lock; true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git unzip javac javap /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|SPRINGDOC_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|AWS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
curlq() { curl --noproxy '*' "$@"; }
CURL=curlq
echo "c9-unit22 receipts · $(date '+%Y-%m-%d') · bash $BASH_VERSION · $(java -version 2>&1 | head -1) · $(curl --version | head -1 | cut -d' ' -f1-2) · load $(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }') · run $RUNNO"

# ---- gates before anything is built: the folder, the link, the pins, the anchor note, the static check, the prose, the exercise --------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'bind.py chk22.py dur9.py norm.py ops9s3.py reach.py rec.py s922.py src tree22.py' ] || die "harness/ holds another file, or misses one: $(ls harness | paste -sd' ' -)"
HSRC='probe22/Bind.java probe22/Limits.java probe22b/Rec.java'
[ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$HSRC" ] || die "harness/src holds another file, or misses one"
for f in cdp.mjs cdp9.mjs seal9.py chrome20.py loc9.py presign stub src/probe/Etag.java src/probe/Witness.java src/probe/Http.java src/probe21/Caller21.java src/r4; do [ ! -e harness/$f ] || die "harness/$f: an instrument this unit does not carry (no browser, no witness, no stub)"; done
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md apply.sh break.sh check.sh' ] || die "exercise/ holds another file, or misses one"
[ -L before ] && [ "$(readlink before)" = ../c9-unit21/after ] || die "before must be a link whose text is exactly ../c9-unit21/after"
[ -d after ] && [ ! -L after ] || die "after/ is this unit's own frozen tree, a directory, not a link"
for t in before after; do [ -e "$t/secrets" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-client/target" ] || [ -e "$t/.m2-demo" ] && die "$t holds a secrets/, a target/ or a .m2-demo/"; true; done
echo "  before -> $(readlink before) (a link, the text exact) · after/ a directory (the frozen copy) · no secrets/, target/ or .m2-demo/ in either · no browser instrument, no witness class, no stub"
cmp -s harness/src/probe22/Bind.java "$HELD/harness/src/probe22/Bind.java" || die "harness/src/probe22/Bind.java is not the held ev22 run's"
cmp -s harness/src/probe22b/Rec.java "$BK4/instruments/harness/probe22b/Rec.java" || die "harness/src/probe22b/Rec.java is not BLUE C9-U22's"
[ "$(md5 -q "$BK4/instruments/harness/probe22b/Rec.java")" = "$(awk '$2 == "./instruments/harness/probe22b/Rec.java" { print $1 }' "$BK4/MD5SUMS")" ] || die "BLUE's Rec.java is not its MD5SUMS line"
cmp -s harness/reach.py "$BK4/instruments/reach.py" && cmp -s harness/reach.py "$HELD/harness/reach.py" || die "harness/reach.py is not BLUE's (= the held run's)"
cmp -s harness/rec.py "$BK4/instruments/rec.py" || die "harness/rec.py is not BLUE's"
BPD=$(diff "$HELD/harness/bind.py" harness/bind.py | md5 -q); BPN=$(diff "$HELD/harness/bind.py" harness/bind.py | $G -c '^[<>]' || true)
echo "  instruments: Bind.java $(md5 -q harness/src/probe22/Bind.java | cut -c1-8) = the held run's · Rec.java $(md5 -q harness/src/probe22b/Rec.java | cut -c1-8) = BLUE's (its MD5SUMS line) · reach.py $(md5 -q harness/reach.py | cut -c1-8) = BLUE's = the held run's · rec.py $(md5 -q harness/rec.py | cut -c1-8) = BLUE's · bind.py adapted from the held run's ($BPN diff lines, the named diff's md5 $BPD: R.567's two prints)"
[ "$(md5 -q harness/ops9s3.py)" = "$(md5 -q ../c9-unit21/harness/ops9s3.py)" ] || die "harness/ops9s3.py is not unit 21's copy, byte for byte"
[ "$(sed -n '5,$p' harness/tree22.py | md5 -q)" = "$(sed -n '5,$p' ../c9-unit21/harness/tree21.py | md5 -q)" ] || die "harness/tree22.py's code is not tree21.py's"
for u in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21; do [ "$(md5 -q harness/dur9.py)" = "$(md5 -q ../c9-unit$u/harness/dur9.py)" ] || die "harness/dur9.py is not ../c9-unit$u's copy"; done
J9="$HOME/Desktop/PromptVidya-Automation/java9_series.py"; J6="$HOME/Desktop/PromptVidya-Automation/java6_series.py"; D9=$(md5 -q harness/dur9.py)
if [ -f "$J9" ]; then R9=$(sed -n 's/^DUR9_MD5 = "\([0-9a-f]*\)".*/\1/p' "$J9"); [ "$R9" = "$D9" ] || die "harness/dur9.py ($D9) is not java9_series.DUR9_MD5 ($R9)"; D9N="= java9_series.DUR9_MD5, read off the registry"
  TT=$(python3 -I -c '
import re,sys; t=open(sys.argv[1]).read().split("TITLES",1)[1]; s6=open(sys.argv[2]).read()
for k in ("05","21","22","23"):
    m=re.search(r"\"%s\": *\"([^\"]+)\"" % k, t); print("c9u%s=%s" % (k, m.group(1) if m else ""))
for n in ("Bean Validation",): print("c6=%s" % (n if n in s6 else ""))' "$J9" "$J6" | paste -sd'|' -)
  echo "  the titles, read off the registries (the call-backs, by title only, R.224): $TT"
else D9N="(the registry is not on this machine: U01-U21's copies are the pin)"; TT=""; fi
echo "  harness/dur9.py md5 $D9 = ../c9-unit01-21's copies $D9N · tree22.py's code = tree21.py's · ops9s3.py = unit 21's (md5 $(md5 -q harness/ops9s3.py))"
S21=$(md5 -q ../c9-unit21/harness/s921.py); [ "$S21" = 931590880093d1ebb31e6508c6be2adc ] || die "U21's s921.py is not 93159088"
NS=$(diff ../c9-unit21/harness/s921.py harness/s922.py | $G -c '^<' || true)
echo "  s922.py: U21's s921.py (93159088) with XU22C9 added - lines of s921.py's not in s922.py: $NS · lines added $(diff ../c9-unit21/harness/s921.py harness/s922.py | $G -c '^>') · the diff's md5 $(diff ../c9-unit21/harness/s921.py harness/s922.py | md5 -q)"
UA=$(awk '$1 == "after-tree" { print $2, $3 }' ../c9-unit21/receipts.md5)
[ "$UA" = "127 0a9a44cd0bb102c379351e8e83b3e24c" ] || die "../c9-unit21/receipts.md5's after-tree line is not 127 0a9a44cd ($UA)"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree22.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || { [ -n "${NOPIN:-}" ] && { echo "  $dir/: $got (NOPIN: no pin yet)"; return 0; }; die "receipts.md5 has no $nm line"; }
  [ "$nm" = after-tree ] || [ "$want" = "$UA" ] || die "receipts.md5's $nm line ($want) is not ../c9-unit21/receipts.md5's after-tree line ($UA)"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/: python3 -I harness/tree22.py $dir/ -> $got = receipts.md5's $nm line$( [ "$nm" = before-tree ] && echo " = ../c9-unit21/receipts.md5's after-tree line")"; }
pin before-tree before; pin after-tree after
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true)
echo "  after/ against the live anchor (the start note): $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ, or the anchor is not beside this folder - this unit measures its own frozen after/' )"
HF="harness/chk22.py harness/s922.py harness/tree22.py harness/dur9.py harness/ops9s3.py harness/bind.py harness/rec.py harness/reach.py harness/norm.py harness/src/probe22/Bind.java harness/src/probe22/Limits.java harness/src/probe22b/Rec.java exercise/check.sh exercise/apply.sh exercise/break.sh"
for f in $HF; do w=$(awk -v n="$f" '$1 == "file" && $2 == n { print $3 }' receipts.md5); [ -n "$w" ] || { [ -n "${NOPIN:-}" ] && continue; die "receipts.md5 has no file line for $f"; }
  [ "$(md5 -q "$f")" = "$w" ] || { [ -n "${NOPIN:-}" ] && { echo "  $f: md5 $(md5 -q "$f") differs from the published $w (NOPIN: development)"; continue; }; die "$f is not the published file (md5 $(md5 -q "$f"), receipts.md5 $w)"; }; done
echo "  the harness and the exercise's scripts: $(echo $HF | wc -w | tr -d ' ') files, each md5 = its receipts.md5 file line"
ST=$(python3 -I -B harness/chk22.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
STMD5=$(printf '%s\n' "$ST" | md5 -q)
echo "  static (harness/chk22.py static after before; reads after/, before and git show $H21:… only - flag 20): $(printf '%s\n' "$ST" | $G -c '^ok ') checks, FAIL 0 · its output md5 $STMD5"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s922.py harness/dur9.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -3 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · XFAM_S9S1 [0-9]+ families · U19 [0-9]+ families · U20 [0-9]+ families · U21 [0-9]+ families · U22 [0-9]+ families · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -2 | sed 's/^/  prose (s922, per sentence): /'
PH=$($G -rnE 'PLACEHOLDER|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b|<measure>' README.md exercise | cut -c1-100 | head -2 | paste -sd';' -)
[ -z "$PH" ] || die "a placeholder in this unit's prose or exercise: $PH"
GL=$(python3 -I -B harness/chk22.py gloss README.md) || die "the gloss: $(printf '%s\n' "$GL" | $G '^FAIL' | head -3 | paste -sd';' -)"
echo "  the gloss: $(printf '%s\n' "$GL" | $G -c '^ok ') checks, FAIL 0 ($(printf '%s\n' "$GL" | $G '^GLOSS ' | sed 's/^GLOSS //'))"
HOOK=$(python3 -I -B harness/chk22.py hook) || die "the hook could not be extracted"; EXQ=$(python3 -I -B harness/chk22.py exq) || die "the exercise line could not be extracted"
IL=$(python3 -I -B harness/chk22.py interleaved) || die "the brief's interleaved hooks and exercises: $IL"
echo "  $IL"
[ "$($G -cF -- "$HOOK" README.md)" -ge 1 ] || die "README.md: the hook (S4B's Unit 22 Hook line), byte for byte"
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
HW=$(printf '%s\n' "$HOOK" | wc -w | tr -d ' '); EW=$(printf '%s\n' "${EXQ#Your turn: }" | wc -w | tr -d ' ')
HSW=$(printf '%s\n' "$HOOK" | python3 -I -c 'import re,sys; print(max(len(s.split()) for s in re.split(r"(?<=[.!?:])\s+", sys.stdin.read().strip()) if s))')
[ "$EW" -le 25 ] && [ "$HSW" -le 25 ] || die "a spoken line over 25 words (exercise $EW, the hook's longest sentence $HSW)"
echo "  the hook ($HW words, its longest sentence $HSW <= 25) and the exercise's line ($EW words after 'Your turn:'), byte for byte; both extracted from S4B's Unit 22 (md5 $(md5 -q "$S4B"))"
printf '%s\n\n%s\n' "$HOOK" "$EXQ" > .r-lock/spoken.md
SW=$(python3 -I -B harness/s922.py harness/dur9.py .r-lock/spoken.md) || die "the prose gate on the spoken lines did not run"
SWR=$(printf '%s\n' "$SW" | $G ' line ' | sed 's#.*spoken.md ##' | sort -u | paste -sd';' -)
echo "  the hook and the exercise's line through s922.py: $(printf '%s\n' "$SW" | tail -1 | sed 's/.* refused: /refused /')$( [ -n "$SWR" ] && echo " - $SWR (handed to RED: the hook is the brief's, never edited)")"; rm -f .r-lock/spoken.md
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
! $G -qE '(^|[^A-Za-z0-9_.-])path=|[$][{]?path([^A-Za-z0-9_]|$)' exercise/check.sh exercise/apply.sh exercise/break.sh || die "an exercise script names a variable path (zsh): rpath"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh exercise/check.sh exercise/apply.sh exercise/break.sh | $G -qwE "$K1|$K2" || die "a script names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket"
DRL=$($G -v '^ *#' receipts.sh | $G -F 'dk run ' | $G -vF -- '--pull never' | $G -vF '$G -F' | wc -l | tr -d ' ')
[ "$DRL" = 0 ] || die "a dk run line without --pull never"
MVL=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -F '$MV ')
MVA=$(printf '%s\n' "$MVL" | $G -vF -- '-pl tiffinbox-web -am' | $G -cF -- '-pl ' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh with a -pl form other than '-pl tiffinbox-web -am'"
MVS=$(printf '%s\n%s\n' "$MVL" "$($G -F 'mvn ' exercise/check.sh)" | $G -cE -- ' -s | --settings ' || true); [ "$MVS" = 0 ] || die "RED4 #27: a Maven line with -s (the central-only settings fail offline)"
# R.564: no GNU-only sed form, no bare sed -i, no '|| true' or '2> /dev/null' on a line that writes a capture file ($J/...txt)
GNU=$($G -v '^ *#' receipts.sh exercise/check.sh exercise/apply.sh exercise/break.sh | $G -vF 'GNUFORM' | $G -cE "sed [^|]*[0-9]~[0-9]|sed -i( |$)|sed -i ''" || true)   # GNUFORM: this line and the plant's name the forms
[ "$GNU" = 0 ] || die "R.564: a GNU-only sed form or a bare sed -i ($GNU lines)"   # GNUFORM
HID=$($G -v '^ *#' receipts.sh | $G -E '> "?\$J/[A-Za-z0-9_.-]+\.txt' | $G -cE '\|\| true|2> /dev/null' || true)
[ "$HID" = 0 ] || die "R.564: a capture-writing line hides its failure ($HID lines)"
LA=$($G -nF 'c9-tiffinbox' receipts.sh exercise/check.sh exercise/apply.sh exercise/break.sh harness/tree22.py harness/chk22.py harness/bind.py harness/rec.py harness/reach.py harness/norm.py | $G -v ':[0-9]*: *#' | $G -vF 'AD=$(diff -rq' | $G -vF 'AD1=$(diff -rq' | $G -vF 'MDB=$(find' | $G -vF "\$G -nF 'c9-tiffinbox'" | $G -vF 'LIVE_ANCHOR_PLANT' | wc -l | tr -d ' ')
[ "$LA" = 0 ] || die "flag 20: a line of the receipts, the exercise or the harness reads the live anchor outside the start note, the end check and the H2-file sweep"
echo "  static: no kill by name; every docker call on the pinned socket, every dk run --pull never; R.391's Maven form only, no -s; R.564: no GNU sed form, no hidden capture step; the live anchor read only by the start note, the end check and the H2-file sweep (flag 20)"
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
    gsub(/127\.0\.0\.1:21[0-9][0-9][0-9]/, "127.0.0.1:<port>")
    gsub(/\$\$SpringCGLIB\$\$[0-9]+/, "$$SpringCGLIB$$N")
    gsub(/[A-Z][a-z][a-z], [0-9][0-9] [A-Z][a-z][a-z] [0-9][0-9][0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9] GMT/, "<date>")
    gsub(/refill period [0-9]+[smh]/, "refill period <period>")
    gsub(/password=[0-9a-f]+/, "password=<masked>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxServer in 3.1 seconds (process running for 4.2)' 'took 812 ms' '"timestamp":"2026-11-01T08:09:00.123Z"' "$U/x $HOME/y" 'jdbc:postgresql://127.0.0.1:21161/u22?user=tiffinbox&password=0a1b2c' 'Date: Fri, 27 Nov 2026 10:00:00 GMT · key 62cd547a-8da7-4f2c-ac9b-e4db970ce097' | mask)
[ "$(printf '%s\n' "$MP" | paste -sd'|' -)" = 'Started TiffinBoxServer in <t> (process running for <t>)|took <t>|"timestamp":"<time>"|…/x ~/y|jdbc:postgresql://127.0.0.1:<port>/u22?user=tiffinbox&password=<masked>|Date: <date> · key <uuid>' ] || die "the mask's self-test: $(printf '%s\n' "$MP" | paste -sd'|' -)"
echo "  masks: the log mask masked a Started line's times, a millisecond count, a timestamp, the folders, the home, a band port, a password, an HTTP date and a uuid (self-test)"
CURLSET=../c5-unit11/curlset.sh
[ "$(md5 -q $CURLSET)" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not c5-unit11's comparison set"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh); [ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"
U4SURF=$(sed -n 's/^SURF=\([0-9a-f]*\).*/\1/p' ../c9-unit04/receipts.sh); [ ${#U4SURF} = 32 ] || die "the old surface's md5 could not be read off ../c9-unit04/receipts.sh (SURF=)"
U21V=$(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit21/README.md | $G -E '^(seven|surface): ' | $G -oE '(seven|surface)=[0-9a-f]{8}' | paste -sd' ' -)
[ "$U21V" = "seven=$(echo $S466 | cut -c1-8) surface=$(echo $U4SURF | cut -c1-8)" ] || die "U21's README values block ($U21V) is not the seven and the surface read off the receipts"
echo "  the seven: expected $S466 (../c7-unit31/receipts.sh's S466= line) · the old surface: expected $U4SURF (../c9-unit04/receipts.sh's SURF= line) · both = U21's values block ($U21V)"
echo "  BLUE C9-U22's re-measure (BK4/out, read, not copied: the expectation, never the sentence): reach before $(md5 -q "$BK4/out/reach1/reach-before.txt" | cut -c1-8) · (b′) $(md5 -q "$BK4/out/reach1/reach-bp.txt" | cut -c1-8) · the key $(md5 -q "$BK4/out/reach1/reach-after.txt" | cut -c1-8) · rec H2 x3 $(for k in 1 2 3; do md5 -q "$BK4/out/rec$k-h2/rec.txt" | cut -c1-8; done | paste -sd' ' -)"

# ---- docker, ports, the guard: the baselines ----------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed (R.344)"
NI0=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run"
[ -z "$(dk ps -aq --filter name=^/c9u22- 2> /dev/null)" ] || die "a c9u22-* container exists before the run"
dk image inspect -f '{{.Id}}' "$PIMG" > /dev/null 2>&1 || die "the PostgreSQL image $PIMG is not on this machine (nothing is pulled)"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
BAND="21160 21161 21162 21163 21164 21165 21166 21167 21168 21169"
NEVER="21163 21164 21165 21167 21169 21110 21111 21112 21113 21114 21115 21116 21117 21118 21119"
PORTS="18425 18881 18882 18883 18884 20578 20615 $BAND 21110 21111 21112 21113 21114 21115 21116 21117 21118 21119 21280 21281 21282 21283 21284"
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
  for p in $BAND; do if echo " ${MINE:-} " | $G -qF " $p "; then continue; fi; [ "$(listeners $p)" = 0 ] || die "guard before $1: something listens on $p that this run did not start"; done
  echo "  guard before $1: no other receipt · load1 $l1 (< 20)$( [ $w = 0 ] || echo " after $w checks at or above 20 (waited, never killed)") · the band free" >&3; }
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · nothing pulled · the PostgreSQL image present by digest · no Testcontainers or c9u22-* container · ports free (21163-21165, 21167, 21169 and 21110-21119 included, never bound)"

# ---- the trees, copied and built offline: before (through the link), after/; the harness's classes ------------------------------------
M2="$PWD/.m2-demo"
if [ ! -d "$M2" ]; then [ -d "$SEED" ] || die "the seed $SEED is missing"; cp -cR "$SEED" "$M2" 2> /dev/null || cp -R "$SEED" "$M2" || die "the seed could not be copied"; fi
NF0=$(find "$M2" -type f | wc -l | tr -d ' '); NB0=$(find "$M2" -type f -print0 | xargs -0 stat -f %z | awk '{ s += $1 } END { printf "%d", s }')
CO=$(find "$M2" -name _remote.repositories -print0 | xargs -0 $G -l 'central-only' | wc -l | tr -d ' ')
[ "$CO" = 0 ] || die "$CO _remote.repositories files in the seed copy still name central-only"
ART="org/springframework/boot/spring-boot-starter-parent/4.1.3 org/springframework/spring-context/7.0.11 tools/jackson/core/jackson-databind/3.1.8 tools/jackson/core/jackson-core/3.1.8 org/postgresql/postgresql"
for a in $ART; do [ -n "$(ls -R "$M2/$a" 2> /dev/null | $G -E '\.(jar|pom)$')" ] || die ".m2-demo holds no $a (no seed act here: report the coordinates)"; done
echo "  .m2-demo (a copy of the seed m2-seed-c9-s4): files $NF0 · bytes $NB0 · _remote.repositories naming central-only: $CO"
mkdir -p .harness; for d in before after need tests exercise run work hc static-copy iii pg; do rm -rf .harness/$d; done
mkdir -p .harness/home .harness/run .harness/work .harness/hc .harness/pg
printf '%s\n' 'checks.disable=true' > .harness/home/.testcontainers.properties
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy before .harness/before; copy after .harness/after
JL=(-Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8)
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE 'Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" HOME=\"$U/.harness/home\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 900; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
AL="-DargLine=-Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Duser.home=../../home"
extract() { bg "cd .harness/$1 && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$1.log
  [ "$RE" = 0 ] || die ".harness/$1: the jar's extract failed"; }
guard "the build of before"
bg "cd .harness/before && $MV -DskipTests clean package -pl tiffinbox-web -am" .harness/build-before.log
[ "$RE" = 0 ] || { tail -30 .harness/build-before.log | mask >&3; die ".harness/before did not build offline (exit $RE)"; }; offl .harness/build-before.log
echo "  built before offline (mvn -o -DskipTests clean package -pl tiffinbox-web -am; exit 0, Downloading/Downloaded from: 0)"
guard "the build of after"
bg "cd .harness/after && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" clean package" .harness/build-after.log
[ "$RE" = 0 ] || { tail -30 .harness/build-after.log | mask >&3; die ".harness/after did not build offline (exit $RE)"; }; offl .harness/build-after.log
echo "  built after/ offline WITH its tests, Docker-free (mvn -o clean package, the whole reactor: $($G -E '^\[INFO\] TiffinBox[A-Za-z ]* \.+ SUCCESS' .harness/build-after.log | sed -E 's/^\[INFO\] (TiffinBox[A-Za-z ]*) \.+ SUCCESS.*/\1/' | paste -sd, -); exit 0) - the jars come from this build; it is the tests capture's package run"
extract before; extract after
XA="$U/.harness/after/$XD"; CPA="$XA/tiffinbox-web-1.0.0.jar:$XA/lib/*"
bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' javac -nowarn -parameters -d .harness/hc -cp \"$CPA\" harness/src/probe22/Bind.java harness/src/probe22b/Rec.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
echo "  the harness compiled (javac -nowarn -parameters) against after/'s extracted web jar and BOOT-INF/lib: probe22.Bind (the entity-bound route) and probe22b.Rec (the record route) - joined only by --spring.main.sources"
B() { echo "http://127.0.0.1:$1"; }
J=.harness/work
ALP='%m %U%q %s %b'
# tb LABEL PORT [args]: TiffinBox (the extracted jar of TREE=after unless TREE is set), from its own run folder with a generated token
# (0600, never printed), H2 in memory (fresh per JVM) unless PGDB names a PostgreSQL database (the URL a 0600 secret); HJ=1 joins the
# harness's classes (--spring.main.sources names which); waited for by its Started line; Tomcat's access log on.
tb() { local label=$1 port=$2 t=${TREE:-after} run=.harness/run/$1 i=0; shift 2
  guard "TiffinBox $label"
  for q in $NEVER; do [ "$(listeners $q)" = 0 ] || die "$q must stay free (TCP)"; done
  [ "$(listeners $port)" = 0 ] && [ -z "$(lsof -nP -iUDP:$port 2> /dev/null)" ] || die "$port is bound before $label"
  rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox"
  (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > "$run/secrets/tiffinbox/shutdown-token") || die "the token was not written"
  if [ -n "${PGDB:-}" ]; then (umask 077 && printf 'jdbc:postgresql://127.0.0.1:21161/%s?user=tiffinbox&password=%s\n' "$PGDB" "$PW" > "$run/secrets/tiffinbox/jdbc-url") || die "the URL was not written"; fi
  local x="$U/.harness/$t/$XD" cp; cp="$x/tiffinbox-web-1.0.0.jar:$x/lib/*"
  if [ -n "${HJ:-}" ]; then cp="$cp:$U/.harness/hc"; fi
  local ax=(--server.tomcat.accesslog.enabled=true "--server.tomcat.accesslog.directory=$U/$run" --server.tomcat.accesslog.prefix=access --server.tomcat.accesslog.suffix=.log --server.tomcat.accesslog.rotate=false --server.tomcat.accesslog.buffered=false "--server.tomcat.accesslog.pattern=$ALP")
  local main=com.tiffinbox.web.TiffinBoxServer
  echo "java -cp <tree $t>${HJ:+ + the harness} $main --tiffinbox.port=$port <the access log> $*" > "$run/cmd"
  (cd "$run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' java "${JL[@]}" -cp "$cp" $main --tiffinbox.port="$port" "${ax[@]}" "$@" > jvm.log 2>&1) &
  local p=$!; echo $p > "$run/pid"; PIDS="$PIDS $p"; MINE="${MINE:-} $port"
  while ! $G -q -E 'Started TiffinBox(App|Server) in' "$run/jvm.log" 2> /dev/null; do kill -0 $p 2> /dev/null || { tail -25 "$run/jvm.log" | mask >&3; die "$label exited before its Started line"; }; i=$((i + 1)); [ $i -lt 1200 ] || die "$label: no Started line"; sleep 0.1; done
  local db=H2; [ -z "${PGDB:-}" ] || db="PostgreSQL ($($G -c 'PostgreSQL' "$run/jvm.log") log lines name it)"
  echo "  $label up on $port ($db, tree $t, $( [ -n "${HJ:-}" ] && echo 'harness-joined' || echo 'harness-free'), the access log on)"; }
tbstop() { local label=$1 port=$2 run=.harness/run/$1 p i=0 how="POST /shutdown"; p=$(cat "$run/pid")
  if kill -0 "$p" 2> /dev/null; then printf 'X-Shutdown-Token: %s\n' "$(head -1 "$run/secrets/tiffinbox/shutdown-token")" | $CURL -s -o /dev/null --max-time 5 -H @- -X POST "$(B $port)/shutdown" || true; fi
  while kill -0 "$p" 2> /dev/null; do i=$((i + 1)); [ $i = 80 ] && { kill "$p" 2> /dev/null; how="its recorded pid (SIGTERM)"; }; [ $i -lt 400 ] || { kill -9 "$p" 2> /dev/null; break; }; sleep 0.05; done
  wait "$p" 2> /dev/null || true; PIDS=$(echo " $PIDS " | sed "s/ $p / /g"); MINE=$(echo " ${MINE:-} " | sed "s/ $port / /g")
  [ "$(listeners $port)" = 0 ] || die "$label: something still listens on $port"
  echo "  budget | $label: requests under /api/v1/ (its access log): $(cat $run/access*.log | $G -cE '^[A-Z]+ /api/v1/' || true) · refusal lines: $($G -c 'rate limit: refused' $run/jvm.log || true)"
  [ -z "${QUIET:-}" ] && echo "  $label stopped by $how"; true; }
PSQ() { dk exec "$CN" psql -U tiffinbox -d "${2:-tiffinbox}" -qAt -v ON_ERROR_STOP=1 -c "$1" 2>&1 || die "psql failed: $1"; }
pgup() { PW=$(openssl rand -hex 12); (umask 077 && printf 'POSTGRES_USER=tiffinbox\nPOSTGRES_PASSWORD=%s\nPOSTGRES_DB=tiffinbox\n' "$PW" > .harness/pg/pg.env)
  guard "PostgreSQL"; CTRS="$CN"; MINE="${MINE:-} 21161"
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:21161:5432 --env-file .harness/pg/pg.env $PIMG" .harness/pg/run.log; [ "$RE" = 0 ] || die "PostgreSQL did not start"
  local i=0; while ! dk exec $CN pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 120 ] || die "PostgreSQL did not accept connections"; sleep 0.5; done
  echo "  postgres | $CN $(dk port $CN | paste -sd'|' -) · the image by digest $(dk inspect -f '{{.Config.Image}}' $CN | sed -E 's/@sha256:(.{8}).*/@\1/') · server_version $(PSQ 'show server_version') · ready by pg_isready (the container's own answer)"; }
pgdb() { PSQ "drop database if exists $1" > /dev/null; PSQ "create database $1" > /dev/null; echo "  postgres | a fresh database $1 for the next JVM"; }
pgdown() { dk rm -fv $CN > /dev/null 2>&1 || die "$CN could not be removed"; CTRS=""; MINE=$(echo " ${MINE:-} " | sed "s/ 21161 / /g")
  [ "$(listeners 21161)" = 0 ] || die "21161 still listens after $CN was removed"; echo "  postgres | $CN removed (rm -fv) · volumes $(dk volume ls -q | wc -l | tr -d ' ') (the start's $VOL0)"; }
ANC="c9-""tiffinbox"   # the anchor folder's name, assembled: the frozen receipts' pom lines are counted for it (a read of THEIR text, not of the anchor)
NCAPS=0; unpub=""; VALS=""
must() { local f; for f in "$@"; do test -s "$f" || die "R.564: $f is empty or missing"; done; }
cap() { local nm=$1; shift
  if [ -n "${DEVCAPS:-}" ] && ! echo " $DEVCAPS " | $G -qF " $nm "; then return 0; fi   # development only: a run of record sets no DEVCAPS
  "$@" > .harness/cap-$nm.raw 2>&1 || true
  $G -q '^  \*\*\* ' .harness/cap-$nm.raw && { cat .harness/cap-$nm.raw >&3; die "$nm stopped (above)"; }
  mask < .harness/cap-$nm.raw > .r-$nm.new
  sed 's/^/  | /' .r-$nm.new | cut -c1-260
  local o e=0; o=$(python3 -I -B harness/chk22.py "$nm" .r-$nm.new) || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk22 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -8 >&3; [ -n "${DEVCAPS:-}${NOPIN:-}" ] && { echo "  (development: $nm's check failed, the run goes on)"; unpub="$unpub $nm"; } || die "$nm: its check failed (harness/chk22.py)"; }
  VALS="$VALS${VALS:+
}$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"
  local h p; h=$(python3 -I -B harness/chk22.py hashable "$nm" .r-$nm.new | md5 -q); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-12s md5 %s  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-12s md5 %s  = published\n' "$nm" "$h"
  else printf '  %-12s md5 %s  DIFFERS from the published %s\n' "$nm" "$h" "$p"; [ -n "${NOPIN:-}" ] || die "$nm is not the published capture - diff .r-$nm.new against .r-$nm.out"; unpub="$unpub $nm"; fi
  NCAPS=$((NCAPS + 1)); }
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
reactor() { $G -E '^\[INFO\] TiffinBox[A-Za-z ]* \.+ (SUCCESS|FAILURE|SKIPPED)' "$1" | sed -E 's/ \.+ / ... /; s/\[ *[0-9.:]+ (s|min)\]//; s/^\[INFO\] /  reactor: /; s/ *$//'; }
CPJ=tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerPatches.java
TST=tiffinbox-web/src/test/java/com/tiffinbox/web/InputHardeningTest.java
YML=tiffinbox-web/src/main/resources/application.yaml
KEYFLAG=--spring.jackson.deserialization.fail-on-unknown-properties=true

# ---- the captures ----------------------------------------------------------------------------------------------------------------------
c_advisory() {
  echo "== S9.36: the read filed for Section 4 (ADV4 = _research/docs-2026-11-27/advisories-s4probe, the S4 probe's dated act; not re-read: no network), before any capture"
  echo "  fetched-at $(head -1 "$ADV/fetched-at.txt" | cut -c1-10) (the hour masked) · run date $(date '+%Y-%m-%d') · the batch day's other read (advisories/) fetched-at $(head -1 "$ADV/../advisories/fetched-at.txt" | cut -c1-10)"
  local d n=0 v=0 f h; for d in "$ADV" "$ADV/../advisories"; do n=0; v=0; while read -r h f; do n=$((n + 1)); [ "$(md5 -q "$d/$f")" = "$h" ] && v=$((v + 1)); done < <($G -vE '^\s*$' "$d/MD5SUMS.txt" | awk '$2 != "MD5SUMS.txt" { print $1, $2 }')
    echo "  $(basename "$d")/MD5SUMS.txt: $n lines, $v verified (its own line left out)"; done
  echo "  tomcat page md5 $(md5 -q "$ADV/tomcat-security-11.html") (the 11-24, 11-26 and 11-27 00:51 reads: a1a756d985225fb5143eefd9aae3183c)"
  local a; for a in spring-boot spring-web spring-context tomcat-embed-core jackson-databind jackson-core postgresql; do
    echo "  shipped | $a $(ls .harness/after/$XD/lib | $G -E "^$a-[0-9]" | sed -E "s/^$a-//; s/\.jar$//" | paste -sd, -)"; done
  python3 -I - "$ADV/osv-query.json" "$ADV/osv-result.json" <<'PY'
import json, sys
q = json.load(open(sys.argv[1]))["queries"]; r = json.load(open(sys.argv[2])).get("results", [])
print("  osv (second witness only, S2.8): %d coordinates queried, %d results, %d with vulns" % (len(q), len(r), sum(1 for x in r if x.get("vulns"))))
names = sorted(x.get("package", {}).get("name", "") + "@" + x.get("version", "") for x in q)
for k in ("jackson-databind", "jackson-core", "postgresql"): print("  osv | queried coordinates naming %s: %s" % (k, ", ".join(n for n in names if k in n) or "none"))
PY
  echo "  lib names before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ') · by name: $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) > /dev/null && echo equal || echo DIFFER) · the four poms byte-equal: $(for p in pom.xml tiffinbox-web/pom.xml tiffinbox-core/pom.xml tiffinbox-client/pom.xml; do cmp -s before/$p after/$p || echo no; done | $G -c no || true) differ (no new artifact in the anchor)"
  echo "  verdict: no pin affected; evidence may proceed (the read is the batch day's: run date = fetched-at date); nothing else was read from the network"; }
c_before() {
  echo "== before (U21's after): the yaml's deserialization map, the merge patch's read line, the counters"
  echo "  before | $YML lines naming fail-on-unknown: $($G -ci 'fail-on-unknown' before/$YML || true) · the deserialization map:"
  $G -n -A1 '^    deserialization:' before/$YML | sed 's/^/    /'
  echo "  before | CustomerPatches.readBack's read: $($G -nE 'c = json\.read' before/$CPJ | sed -E 's/^([0-9]+): +/:\1 /')"
  echo "  before | FAIL_ON_UNKNOWN_PROPERTIES named in src/main: $( (cd before && $G -rl 'FAIL_ON_UNKNOWN_PROPERTIES' tiffinbox-web/src/main tiffinbox-core/src/main) | wc -l | tr -d ' ') files"
  echo "  before | the committed spec: $(python3 -I harness/ops9s3.py ops before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tail -1) · $(wc -c < before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tr -d ' ') B md5 $(md5 -q before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json)"
  echo "  before | BOOT-INF/lib names $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · web tests, client tests and ITs (U21's values block): $(sed -n '/<!-- values: begin -->/,/<!-- values: end -->/p' ../c9-unit21/README.md | $G -oE '(web|client|its)=[0-9>-]+' | paste -sd' ' -)"; }
c_change() {
  echo "== the modules, the change file by file"
  echo "  modules: $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' before/pom.xml | paste -sd' ' -) ($($G -c '<module>' before/pom.xml)) -> $(sed -n 's#.*<module>\(.*\)</module>.*#\1#p' after/pom.xml | paste -sd' ' -) ($($G -c '<module>' after/pom.xml))"
  echo "  changed (derived: diff -rq before after/, the frozen trees - git status --short gave the same list before the commit): $(diff -rq before/ after/ | sed -E 's#^Files before/(.*) and after/.* differ$#M \1#; s#^Only in after/(.*): (.*)$#A \1/\2#; s#^Only in after/: (.*)$#A \1#; s#^Only in before/(.*): (.*)$#D \1/\2#' | sort | paste -sd'~' - | sed 's/~/ · /g')"
  echo "== $CPJ: the diff, before -> after/"
  diff before/$CPJ after/$CPJ | sed 's/^/    /'
  echo "  the diff's lines: added $(diff before/$CPJ after/$CPJ | $G -c '^>') · removed $(diff before/$CPJ after/$CPJ | $G -c '^<') · code lines added (not comments) $(diff before/$CPJ after/$CPJ | $G '^>' | $G -vcE '^> +(\*|//)' ) · code lines removed $(diff before/$CPJ after/$CPJ | $G '^<' | $G -vcE '^< +(\*|//)' )"
  echo "== $TST (whole, md5 $(md5 -q after/$TST))"; sed 's/^/    /' after/$TST
  local f; for f in pom.xml tiffinbox-web/pom.xml tiffinbox-core/pom.xml tiffinbox-client/pom.xml $YML tiffinbox-web/src/main/resources/application-dev.yaml Dockerfile compose.yaml tiffinbox-web/src/test/resources/openapi/tiffinbox.json; do echo "  $f byte-equal to before's: $(cmp -s before/$f after/$f && echo yes || echo no)"; done
  echo "  src/main files moved (every module): $(for m in tiffinbox-web tiffinbox-core; do diff -rq before/$m/src/main after/$m/src/main; done | sed -E 's#^Files before/(.*) and after/.* differ$#\1#' | paste -sd' ' -) · tiffinbox-core/ and tiffinbox-client/ byte-equal: $(diff -rq before/tiffinbox-core after/tiffinbox-core > /dev/null && diff -rq before/tiffinbox-client after/tiffinbox-client > /dev/null && echo yes || echo no)"
  echo "  greps over after/: src/main files naming FAIL_ON_UNKNOWN_PROPERTIES $( (cd after && $G -rl 'FAIL_ON_UNKNOWN_PROPERTIES' tiffinbox-web/src/main tiffinbox-core/src/main) | sed 's#.*/##' | paste -sd, -) · readerFor( in src/main code lines $( (cd after && $G -rn 'readerFor(' tiffinbox-web/src/main tiffinbox-core/src/main) | $G -vE ':[0-9]+: +(\*|//)' | wc -l | tr -d ' ') · yaml lines naming fail-on-unknown $($G -ci 'fail-on-unknown' after/$YML || true) · Probe/probe./BLUE in the new test $($G -cE 'Probe|probe\.|BLUE|/probe/' after/$TST || true)"; }
census() { python3 -I - "$1/tiffinbox-web/src/main/java/com/tiffinbox/web" "$2" <<'PY'
import os, re, sys
d, side = sys.argv[1], sys.argv[2]
print("  census %s | rule (unit 15's, copied off unit 21's receipts): a class whose annotation lines include exactly @RestController or @Controller; its final modifier; @Profile(\"dev\") among those lines" % side)
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
    print("  census %s | %-16s final %-3s dev-only %-3s %s:%d" % (side, r[0], "yes" if r[1] else "no", "yes" if r[2] else "no", r[3], r[4]))
for e in excl:
    print("  census %s | excluded by the rule: %s (%s:%d) - annotated @RestControllerAdvice" % ((side,) + e))
fd = sum(1 for r in rows if r[1] and not r[2]); nd = sum(1 for r in rows if not r[1] and r[2]); nf = sum(1 for r in rows if not r[1] and not r[2])
print("  census %s | controllers %d · final, default-run %d · not final, default-run %d · not final, dev-only %d · other %d" % (side, len(rows), fd, nf, nd, len(rows) - fd - nd - nf))
PY
}
c_census() { echo "== the controllers on before and after/ (R.527: each derived on its own tree) - no route added or removed: the change is inside CustomerPatches"; census before before; census after after
  echo "  the spec's counts (ops9s3.py, each tree's own committed file): before $(python3 -I harness/ops9s3.py ops before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tail -1) · after $(python3 -I harness/ops9s3.py ops after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json | tail -1)"; }
dropside() { local side=$1 port=$2 o=$J/drop-$1.txt
  TREE=$side tb drop-$side $port > /dev/null
  python3 -I - $port > $o <<'PY'
import sys, json, re, http.client
port = int(sys.argv[1])
def call(m, p, body=None):
    c = http.client.HTTPConnection("127.0.0.1", port, timeout=10)
    c.request(m, p, body=None if body is None else json.dumps(body), headers={"Content-Type": "application/json"} if body is not None else {})
    r = c.getresponse(); b = r.read().decode("utf-8", "replace"); h = {k.lower(): v for k, v in r.getheaders()}; c.close(); return r.status, b, h
body = {"name": "Mohan", "mealsPerDay": 1, "pricePerMeal": 110, "mealType": "VEG", "version": 99, "admin": True, "createdAt": "2001-01-01T00:00:00Z"}
s, b, h = call("POST", "/customers", body)
print("  drop | POST /customers %s -> %s %s · Location %s · body %s" % (json.dumps(body, sort_keys=True), s, h.get("content-type"), re.sub(r":\d{4,5}/", ":<port>/", h.get("location", "none")), re.sub(r'"(createdAt|updatedAt|timestamp)":"[^"]*"', r'"\1":"<t>"', b)))
s, b, h = call("GET", "/customers/Mohan")
print("  drop | GET /customers/Mohan (the old read back) -> %s · %s" % (s, b))
s, b, h = call("GET", "/api/v1/customers/Mohan")
print("  drop | GET /api/v1/customers/Mohan (the public read back) -> %s · ETag %s · %s" % (s, h.get("etag"), b))
PY
  must $o
  local run=.harness/run/drop-$side w pl
  w=$($G -cE ' WARN .*(HttpMessageNotReadable|Unrecognized|unknown)' $run/jvm.log || true)
  cp $run/jvm.log $J/drop-$side-plant.log; printf '%s\n' '2026-11-27T20:00:00.000+01:00  WARN 1 --- [tiffinbox] [nio-1-exec-1] .w.s.m.s.DefaultHandlerExceptionResolver : Resolved [org.springframework.http.converter.HttpMessageNotReadableException: Unrecognized field "admin"]' >> $J/drop-$side-plant.log
  pl=$($G -cE ' WARN .*(HttpMessageNotReadable|Unrecognized|unknown)' $J/drop-$side-plant.log || true)
  QUIET=1 tbstop drop-$side $port > /dev/null
  sed "s/^  drop |/  drop $side |/" $o
  echo "  drop $side | the JVM's log: WARN lines naming the read $w (the same grep on a copy with one planted WARN line: $pl, R.566)"; }
c_drop() {
  echo "== drop: the hook's request (POST /customers with version 99, admin and createdAt beside the record's four members) on before (21166) and after/ (21160), H2, harness-free, each its own JVM"
  dropside before 21166; dropside after 21160
  echo "  drop | before -> after/: $(cmp -s $J/drop-before.txt $J/drop-after.txt && echo identical || echo DIFFER) - the old POST's answer is unmoved by the change (it reads with Boot's shared mapper)"; }
MEMBERS() { javap -p -cp .harness/after/tiffinbox-core/target/classes com.tiffinbox.CustomerEntity | sed -nE 's/^  public [^ ]+ get([A-Z][A-Za-z]*)\(\);$/\1/p' | python3 -I -c 'import sys; print(",".join(l.strip()[0].lower()+l.strip()[1:] for l in sys.stdin if l.strip()))'; }
bindleg() { local db=$1 o=$J/bind-$1.txt dbn=u22bind; local psq=()
  if [ $db = pg ]; then pgdb $dbn; psq=(docker -H "$DH" exec $CN psql -U tiffinbox -d $dbn -tA -c); fi
  if [ $db = pg ]; then PGDB=$dbn TREE=before HJ=1 tb bind-$db 21166 --spring.main.sources=probe22.Bind > /dev/null; else TREE=before HJ=1 tb bind-$db 21166 --spring.main.sources=probe22.Bind > /dev/null; fi
  python3 -I harness/bind.py 21166 "$(MEMBERS)" "${psq[@]}" > $o
  must $o
  { $G -h 'PROBE-KEY' .harness/run/bind-$db/jvm.log | sed 's/^/  key | /'; $G -h '^PROBE-BIND' .harness/run/bind-$db/jvm.log | sed 's/^/  log | /' | cut -c1-240; } >> $o
  QUIET=1 tbstop bind-$db 21166
  sed "s/^  /  $db | /" $o
  python3 -I harness/norm.py statuses $o > $J/bind-$db.statuses; must $J/bind-$db.statuses
  echo "  $db | normalised: python3 -I harness/norm.py statuses .harness/work/bind-$db.txt | md5 -q -> $(md5 -q $J/bind-$db.statuses) · python3 -I harness/norm.py rows … | md5 -q -> $(python3 -I harness/norm.py rows $o | md5 -q)"; }
c_bind() {
  echo "== bind: the harness's entity-bound route (probe22.Bind, labelled, R.397 - json.readerForUpdating(the CustomerEntity the URL names) then saveAndFlush; no shipped route reads a body onto an entity) on before (21166), harness-joined, a fresh JVM per database"
  echo "  members | the entity's getters (javap -p, after/'s core classes): $(MEMBERS)"
  bindleg h2; bindleg pg
  echo "  bind | the statuses, H2 against PostgreSQL 18.6: $(cmp -s $J/bind-h2.statuses $J/bind-pg.statuses && echo equal || echo DIFFER) · psql against the companion read: $($G -c 'EQUAL to the companion read' $J/bind-pg.txt) equal, $($G -c '| DIFFER$' $J/bind-pg.txt || true) differ"; }
recleg() { local db=$1 o=$J/record-$1.txt dbn=u22rec; local psq=()
  if [ $db = pg ]; then pgdb $dbn; psq=(docker -H "$DH" exec $CN psql -U tiffinbox -d $dbn -tA -c); fi
  if [ $db = pg ]; then PGDB=$dbn HJ=1 tb record-$db 21168 --spring.main.sources=probe22.Bind,probe22b.Rec > /dev/null; else HJ=1 tb record-$db 21168 --spring.main.sources=probe22.Bind,probe22b.Rec > /dev/null; fi
  python3 -I harness/rec.py 21168 "${psq[@]}" > $o
  must $o
  QUIET=1 tbstop record-$db 21168
  sed "s/^  /  $db | /" $o
  python3 -I harness/norm.py rows $o > $J/record-$db.rows; must $J/record-$db.rows
  echo "  $db | normalised: python3 -I harness/norm.py rows .harness/work/record-$db.txt | md5 -q -> $(md5 -q $J/record-$db.rows)"; }
c_record() {
  echo "== record: the cure - the record route (probe22b.Rec, labelled: @RequestBody @Valid Customer, the row found by the URL's name, only mealsPerDay copied) beside the entity route (probe22.Bind, the control) on ONE JVM, after/ (21168), harness-joined, H2 then PostgreSQL 18.6"
  recleg h2; recleg pg
  echo "  record | the rows and answers, H2 against PostgreSQL 18.6 (norm.py rows): $(cmp -s $J/record-h2.rows $J/record-pg.rows && echo equal || echo DIFFER) · psql against the companion read: $($G -c 'EQUAL to the companion read' $J/record-pg.txt) equal, $($G -c '| DIFFER$' $J/record-pg.txt || true) differ"; }
reachone() { local lab=$1 port=$2 side=$3 db=$4 o=$J/reach-$1.txt dbn; shift 4; dbn=u22$(printf %s "$lab" | tr -d -)
  if [ $db = pg ]; then pgdb $dbn; PGDB=$dbn TREE=$side tb reach-$lab $port "$@" > /dev/null; else TREE=$side tb reach-$lab $port "$@" > /dev/null; fi
  python3 -I harness/reach.py $port > $o
  must $o
  QUIET=1 tbstop reach-$lab $port
  echo "  $lab | python3 -I harness/norm.py reach .harness/work/reach-$lab.txt | md5 -q -> $(python3 -I harness/norm.py reach $o | md5 -q) · $(wc -l < $o | tr -d ' ') lines"; }
moved() { python3 -I - "$1" "$2" "$3" <<'PY'
import sys
a = open(sys.argv[1]).read().splitlines(); b = open(sys.argv[2]).read().splitlines(); n = 0
for x, y in zip(a, b):
    if x != y:
        n += 1; print("  MOVED %s | before%s" % (sys.argv[3], x[9:])); print("        %s | after %s" % (" " * len(sys.argv[3]), y[9:]))
print("  %s | %d lines, %d moved, the rest byte-equal" % (sys.argv[3], len(a), n))
PY
}
c_strict() {
  echo "== strict: the change's reach - the inventory (derived on after/), then the held run's 25 requests (harness/reach.py) on before (21166) and after/ (21160), H2 and PostgreSQL 18.6, harness-free, each its own JVM"
  echo "  inventory | @RequestBody in after/'s src/main (grep -rn): $( (cd after && $G -rn '@RequestBody' tiffinbox-web/src/main tiffinbox-core/src/main) | $G -v '{@code' | wc -l | tr -d ' ') routes"
  (cd after && $G -rn '@RequestBody' tiffinbox-web/src/main tiffinbox-core/src/main) | $G -v '{@code' | sed -E 's#^tiffinbox-web/src/main/java/com/tiffinbox/web/##; s/^([A-Za-z]+\.java:[0-9]+):.*@RequestBody[^A-Za-z]*([A-Za-z<>\[\]]+) .*/\1 \2/; s/^/  inventory | /'
  echo "  inventory | readBack( in after/'s src/main: $( (cd after && $G -rn 'readBack(' tiffinbox-web/src/main) | sed -E 's#^tiffinbox-web/src/main/java/com/tiffinbox/web/##; s/^([A-Za-z]+\.java:[0-9]+):.*/\1/' | paste -sd' ' -) - one caller (apply, under both PATCH routes) and the method itself"
  echo "  inventory | src/main files naming JsonMapper (Boot's shared mapper's users): $( (cd after && $G -rl 'JsonMapper' tiffinbox-web/src/main tiffinbox-core/src/main) | sed 's#.*/##' | sort | paste -sd' ' -)"
  echo "  inventory | reached by the change: CustomerPatches.readBack only (the strict reader is its own; the shared mapper is unchanged) · out of reach by construction: TiffinBoxServer.add (POST /customers), DishWrite.add (POST /dishes, dev only), IdempotencyKeyFilter/IdempotencyKeys (write), RateLimiting/RateLimitFilter (write), OrderPages (write) - each reads with the shared mapper or writes only"
  echo "  not a witness for this change (R.511, they do not reach readBack): the POSTs to /customers and their read-backs, the form POST, the JSON Patch add /version (refused by the route's own path check first), the keyed pauses replay, billing-runs; the seven, the old surface and the 11 GETs of api"
  reachone before-h2 21166 before h2; reachone after-h2 21160 after h2
  reachone before-pg 21166 before pg; reachone after-pg 21160 after pg
  moved $J/reach-before-h2.txt $J/reach-after-h2.txt h2; moved $J/reach-before-pg.txt $J/reach-after-pg.txt pg
  echo "  strict | before H2 = before PostgreSQL: $(cmp -s $J/reach-before-h2.txt $J/reach-before-pg.txt && echo yes || echo no) · after/ H2 = after/ PostgreSQL: $(cmp -s $J/reach-after-h2.txt $J/reach-after-pg.txt && echo yes || echo no)"
  paste -d'\n' $J/reach-before-h2.txt $J/reach-after-h2.txt | awk 'NR%2==1{print "  before |" substr($0,10); next}{print "  after  |" substr($0,10)}' > $J/reach-side.txt
  must $J/reach-side.txt
  echo "  strict | the side-by-side file (paste + awk, BSD-safe): $(wc -l < $J/reach-side.txt | tr -d ' ') lines · its md5 $(md5 -q $J/reach-side.txt)"; }
c_key() {
  echo "== key: the harness's copy with the key - after/'s jar started with $KEYFLAG as a run flag (never the anchor), harness-joined to read the running mapper (21162), H2 then PostgreSQL 18.6; the same 25 requests - the cost"
  HJ=1 reachone key-h2 21162 after h2 $KEYFLAG --spring.main.sources=probe22.Bind
  echo "  key-h2 | $($G -h 'PROBE-KEY' .harness/run/reach-key-h2/jvm.log)"
  HJ=1 reachone key-pg 21162 after pg $KEYFLAG --spring.main.sources=probe22.Bind
  echo "  key-pg | $($G -h 'PROBE-KEY' .harness/run/reach-key-pg/jvm.log)"
  moved $J/reach-before-h2.txt $J/reach-key-h2.txt key-h2; moved $J/reach-before-pg.txt $J/reach-key-pg.txt key-pg
  echo "  key | the misspelt mealTyp (Course 6's typo case): before $($G 'misspelt mealTyp' $J/reach-before-h2.txt | sed -E 's/.*-> //') · the key $($G 'misspelt mealTyp' $J/reach-key-h2.txt | sed -E 's/.*-> //')"
  echo "  key | +loyaltyPoints (Course 6's): before $($G 'loyaltyPoints:5 (Lata' $J/reach-before-h2.txt | sed -E 's/.*-> //') · the key $($G 'loyaltyPoints:5 (Lata' $J/reach-key-h2.txt | sed -E 's/.*-> //')"; }
c_limits() {
  echo "== limits: what a body may be, read from the jars (no request to a TiffinBox JVM, no attack) - (i) Jackson 3's read constraints as the library defines them, (iii) Boot's configuration metadata for the request-size keys"
  bg "perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 120; exec @ARGV' java ${JL[*]} -cp \"$XA/lib/*\" harness/src/probe22/Limits.java" $J/limits.txt
  [ "$RE" = 0 ] || die "the limits reader failed: $(head -3 $J/limits.txt)"
  must $J/limits.txt
  $G '^LIMIT ' $J/limits.txt | sed 's/^LIMIT /  (i) library default | /'
  python3 -I - "$XA/lib" <<'PY'
import sys, os, json, zipfile
want = ["server.tomcat.max-http-form-post-size", "server.tomcat.max-swallow-size", "server.max-http-request-header-size", "spring.servlet.multipart.max-file-size", "spring.servlet.multipart.max-request-size", "spring.jackson.deserialization"]
seen = {}
for f in sorted(os.listdir(sys.argv[1])):
    if not f.endswith(".jar"): continue
    z = zipfile.ZipFile(os.path.join(sys.argv[1], f))
    if "META-INF/spring-configuration-metadata.json" not in z.namelist(): continue
    d = json.loads(z.read("META-INF/spring-configuration-metadata.json"))
    for p in d.get("properties", []):
        if p["name"] in want and p["name"] not in seen: seen[p["name"]] = (f, p.get("defaultValue", "no default named"), p.get("type", ""))
for w in want:
    if w in seen: print("  (iii) Boot's metadata | %s = %s (%s, %s)" % (w, json.dumps(seen[w][1]), seen[w][2], seen[w][0]))
    else: print("  (iii) Boot's metadata | %s: not in any jar's metadata" % w)
PY
  echo "  (ii) the running mapper's own constraints: not captured, not said (the drop order's first cut)"
  echo "  limits | the upload and request-size keys are named, not tried: handed to Spring Security - complete (Course 6 S6 CARRIED)"; }
c_spec() {
  echo "== spec: the committed file against the served document (after/, 21160, H2, harness-free) - unchanged by this unit"
  tb spec 21160 > /dev/null
  local SF=after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json BF=before/tiffinbox-web/src/test/resources/openapi/tiffinbox.json
  $CURL -s "$(B 21160)/v3/api-docs" > $J/served.json
  must $J/served.json
  echo "  the committed file against the served document (servers removed, json.dump indent 2, ensure_ascii False, a final newline): $(python3 -I -c '
import json,sys
d=json.load(open(sys.argv[1])); d.pop("servers",None)
print("equal" if json.dumps(d,indent=2,ensure_ascii=False)+"\n" == open(sys.argv[2],encoding="utf-8").read() else "differ")' $J/served.json $SF)"
  echo "  committed md5 before $(md5 -q $BF) · after $(md5 -q $SF) · bytes before $(wc -c < $BF | tr -d ' ') · after $(wc -c < $SF | tr -d ' ') · byte-equal: $(cmp -s $BF $SF && echo yes || echo no)"
  python3 -I harness/ops9s3.py ops $BF > $J/ops-before.txt; python3 -I harness/ops9s3.py ops $SF > $J/ops-after.txt
  echo "  before: $(tail -1 $J/ops-before.txt) · after: $(tail -1 $J/ops-after.txt) · the operations' ids before -> after: $(cmp -s $J/ops-before.txt $J/ops-after.txt && echo equal || echo differ)"
  echo "  the merge patch's documented answers (the committed file): $(python3 -I -c '
import json,sys
d=json.load(open(sys.argv[1])); o=d["paths"]["/api/v1/customers/{name}"]["patch"]
print(" ".join(sorted(o.get("responses",{}).keys())))' $SF) - 422 was documented before this unit (the patched document that is not a valid customer)"
  echo "  OpenApiSpecTest on the committed file: $(python3 -I -c '
import sys,xml.etree.ElementTree as E
r=E.parse(sys.argv[1]).getroot(); print("tests %s failures %s errors %s" % (r.get("tests"), r.get("failures"), r.get("errors")))' .harness/after/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.OpenApiSpecTest.xml) (after/'s build)"
  QUIET=1 tbstop spec 21160; }
jarcmp() { python3 -I - "$1" "$2" "$3" <<'PY'
import sys, zipfile
a = {i.filename: i.CRC for i in zipfile.ZipFile(sys.argv[1]).infolist()}; b = {i.filename: i.CRC for i in zipfile.ZipFile(sys.argv[2]).infolist()}
add = sorted(set(b) - set(a)); rem = sorted(set(a) - set(b)); mv = sorted(k for k in a if k in b and a[k] != b[k])
print("  jar | %s: entries %d -> %d · added %d %s · removed %d · shared entries whose CRC moved %d %s" % (sys.argv[3], len(a), len(b), len(add), add[:4], len(rem), len(mv), mv[:4]))
PY
}
c_moved() { echo "== moved: the jars this build makes, before -> after/ (entry by entry, CRC) - the test is in no jar"
  jarcmp .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar "the web jar"
  jarcmp .harness/before/tiffinbox-core/target/tiffinbox-core-1.0.0.jar .harness/after/tiffinbox-core/target/tiffinbox-core-1.0.0.jar "the core jar"
  echo "  jar | the web jar names InputHardeningTest: $(unzip -l .harness/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | $G -c 'InputHardening' || true)"
  echo "  BOOT-INF/lib names: before $(ls .harness/before/$XD/lib | wc -l | tr -d ' ') · after $(ls .harness/after/$XD/lib | wc -l | tr -d ' ') · added $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c '^>' || true) · removed $(diff <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c '^<' || true)"; }
apiside() { local side=$1 port=$2
  TREE=$side tb api-$side $port > /dev/null
  python3 -I - "$side" "$port" after/tiffinbox-web/src/test/resources/openapi/tiffinbox.json > $J/api-$side.txt <<'PY'
import sys, json, re, hashlib, http.client
side, port, spec = sys.argv[1], sys.argv[2], sys.argv[3]
d = json.load(open(spec))
fill = {"name": "Ravi", "id": "1"}
urls = []
for p, v in sorted(d["paths"].items()):
    if not p.startswith("/api/v1/") or "get" not in v: continue
    u = re.sub(r"\{(\w+)\}", lambda m: fill.get(m.group(1), "1"), p)
    if p == "/api/v1/billing-runs/{id}": u = "/api/v1/billing-runs/00000000-0000-0000-0000-000000000000"
    if p.endswith("/bill/signed"): u += "?expires=1&sig=x"
    urls.append(u)
urls += ["/api/v1/customers/Nobody", "/api/v1/customers?nosuch=1"]
def mask(b):
    s = b.decode("utf-8", "replace")
    s = re.sub(r'"timestamp":"[^"]*"', '"timestamp":"<masked>"', s); s = re.sub(r'"next":"[^"]*"', '"next":"<cursor>"', s)
    s = re.sub(r"(127\.0\.0\.1|localhost):\d{4,5}", r"\1:<port>", s); s = re.sub(r"expires=\d+", "expires=<masked>", s); s = re.sub(r"sig=[A-Za-z0-9_-]+", "sig=<masked>", s)
    return s
for u in urls:
    c = http.client.HTTPConnection("127.0.0.1", int(port), timeout=10); c.request("GET", u); r = c.getresponse(); b = r.read(); st = r.status
    h = {k.lower(): v for k, v in r.getheaders()}; c.close()
    fr = "chunked" if h.get("transfer-encoding", "").lower() == "chunked" else ("Content-Length" if "content-length" in h else "none")
    et = h.get("etag")
    et = "none" if et is None else (et if re.fullmatch(r'"v\d+"', et) else "<shallow tag>")
    hs = ",".join(sorted(k for k in h if k not in ("date", "keep-alive", "connection", "content-length", "transfer-encoding")))
    print("  api | GET %s -> %s %s · headers {%s} · etag %s · framing %s · body %s" % (u, st, h.get("content-type"), hs, et, fr, hashlib.md5(mask(b).encode()).hexdigest()[:12]))
PY
  must $J/api-$side.txt
  QUIET=1 tbstop api-$side $port; }
c_api() { echo "== api: every GET of the committed spec's /api/v1/ paths (filled: name Ravi, id 1; the run id zeros; the signed link expired) and two old refusals, on before (21166) and after/ (21160), H2, the default capacity, each its own JVM - not a witness for the refusal (no GET reaches readBack)"
  apiside before 21166; apiside after 21160
  sed 's/^  api |/  api before |/' $J/api-before.txt; sed 's/^  api |/  api after |/' $J/api-after.txt
  echo "  api | before -> after/: $(cmp -s $J/api-before.txt $J/api-after.txt && echo identical || echo DIFFER) ($(wc -l < $J/api-after.txt | tr -d ' ') requests each)"; }
c_seven() {
  echo "== the seven (c5-unit11/curlset.sh), each tree its own JVM, H2, the default capacity - not a witness for the refusal: none of the seven is a merge patch"
  echo "  expected $S466"
  local s port i; for s in before after; do if [ $s = before ]; then port=21166; else port=21160; fi
    TREE=$s tb seven-$s $port > /dev/null
    sh $CURLSET $port .harness/run/seven-$s/secrets/tiffinbox/shutdown-token > $J/seven-$s.txt 2>&1
    must $J/seven-$s.txt
    i=0; while kill -0 "$(cat .harness/run/seven-$s/pid)" 2> /dev/null; do i=$((i + 1)); [ $i -lt 60 ] || break; sleep 0.05; done
    QUIET=1 tbstop seven-$s $port
    echo "  $s: the seven $(md5 -q $J/seven-$s.txt) ($(wc -l < $J/seven-$s.txt | tr -d ' ') lines)"; done; }
eval "$(sed -n '/^oldsurface2() {/,/^  rm -f "\$t".\*; }$/p' ../c9-unit21/receipts.sh)"
type oldsurface2 > /dev/null 2>&1 || die "oldsurface2 could not be read off ../c9-unit21/receipts.sh"
c_surface() { local side port
  echo "== the old surface by count (U18's reader, sourced off U21's receipts byte for byte), each tree its own JVM, H2, the default capacity - not a witness for the refusal"
  echo "  expected $U4SURF · the reader's md5 $(sed -n '/^oldsurface2() {/,/^  rm -f "\$t".\*; }$/p' ../c9-unit21/receipts.sh | md5 -q)"
  for side in before after; do if [ $side = before ]; then port=21166; else port=21160; fi
    TREE=$side tb surface-$side $port > /dev/null
    oldsurface2 $port $J/surface-$side.txt
    must $J/surface-$side.txt
    QUIET=1 tbstop surface-$side $port
    echo "  $side: the old surface $(md5 -q $J/surface-$side.txt) ($($G -c '^== ' $J/surface-$side.txt) requests, $(wc -l < $J/surface-$side.txt | tr -d ' ') lines)"; done
  echo "  before -> after/: $(cmp -s $J/surface-before.txt $J/surface-after.txt && echo equal || echo DIFFER)"; }
c_tests() {
  echo "== the need-measure (C1): a copy of before with ONLY the new test added (.harness/need), mvn -o test of that class, Docker-free"
  copy before .harness/need; mkdir -p .harness/need/$(dirname $TST); cp after/$TST .harness/need/$TST
  guard "the need-measure"
  bg "cd .harness/need && DOCKER_HOST=unix:///nonexistent/docker.sock $MV \"$AL\" -Dtest=InputHardeningTest -Dsurefire.failIfNoSpecifiedTests=false clean test -pl tiffinbox-web -am" .harness/need.log; local nre=$RE
  echo "  need | mvn test exit $nre (expected non-zero: the test is red without the change)"
  surefire .harness/need/tiffinbox-web/target/surefire-reports "need | InputHardeningTest on before"
  echo "  need | red methods: $($G -oE '^\[ERROR\]   InputHardeningTest\.[A-Za-z0-9]+' .harness/need.log | sed 's/.*\.//' | sort -u | paste -sd' ' -) · its printed line: $($G -h '^InputHardeningTest: POST' .harness/need.log | head -1)"
  echo "== package: after/'s own build (mvn -o clean package, the whole reactor, its tests on, Docker-free - the run's second build)"
  reactor .harness/build-after.log
  for p in web client; do surefire .harness/after/tiffinbox-$p/target/surefire-reports "package | tiffinbox-$p"; done
  python3 -I - .harness/after/tiffinbox-web/target/surefire-reports <<'PY'
import sys, glob, xml.etree.ElementTree as E
for f in sorted(glob.glob(sys.argv[1] + "/TEST-*InputHardeningTest.xml")):
    r = E.parse(f).getroot(); print("  package | class InputHardeningTest | tests %s failures %s errors %s skipped %s" % (r.get("tests"), r.get("failures"), r.get("errors"), r.get("skipped")))
PY
  echo "  package | its printed lines: $($G -h '^InputHardeningTest: ' .harness/build-after.log | sort | paste -sd'|' -)"
  local nps; nps=$(sed -E 's/"[^"]*"/""/g' after/$TST | $G -cE 'RANDOM_PORT|DEFINED_PORT|LocalServerPort|Socket|Thread\.sleep|[^0-9.A-Za-z_][0-9]{4,5}[^0-9.]' || true)
  echo "  InputHardeningTest: @Test lines $($G -cE '^ +@Test$' after/$TST) · disabling or conditional annotations $($G -cE '@(org\.junit\.jupiter\.api\.(condition\.)?)?(Disabled|EnabledIf|DisabledIf|EnabledOn|DisabledOn|EnabledFor|DisabledFor)' after/$TST || true) · ports, sockets, sleeps or 4-5 digit literals (string literals removed) $nps · header-name literals in it (\"Content-Type\", \"If-Match\", \"Idempotency-Key\") $($G -cE '"(Content-Type|If-Match|Idempotency-Key)"' after/$TST || true) · statuses as named constants $($G -cE 'private static final int (CREATED|OK|BAD_REQUEST|UNPROCESSABLE) = ' after/$TST)"
  echo "  refusal lines of the limiter in the build log (the suite at the default; RateLimitFilterTest's own context refuses by design): outside RateLimitFilterTest $(awk '/\[INFO\] Running com\./ { c = $NF } /rate limit: refused/ && c !~ /RateLimitFilterTest/ { n++ } END { print n + 0 }' .harness/build-after.log)"
  echo "  test files moved before -> after: $(for p in $(cd before && find tiffinbox-web/src/test tiffinbox-client/src/test -type f | sort); do cmp -s before/$p after/$p || basename $p; done | paste -sd, -) · new: $(cd after && for p in $(find tiffinbox-web/src/test tiffinbox-client/src/test -type f | sort); do [ -e ../before/$p ] || basename $p; done | paste -sd, -)"
  echo "== mvn -o clean verify on a copy of after/ (.harness/tests): Surefire's tests on H2 in memory, then the five ITs in Testcontainers containers (21280-21284)"
  copy after .harness/tests
  for p in 21280 21281 21282 21283 21284 18881 18882 18883 18884; do [ "$(listeners $p)" = 0 ] || die "$p is bound before verify"; done
  guard "mvn verify"
  bg "cd .harness/tests && DOCKER_HOST=\"$DH\" TESTCONTAINERS_RYUK_DISABLED=true $MV \"$AL\" clean verify" .harness/verify.log; local vre=$RE
  reactor .harness/verify.log
  for p in web client; do surefire .harness/tests/tiffinbox-$p/target/surefire-reports "verify | tiffinbox-$p"; done
  python3 -I - .harness/tests/tiffinbox-web/target/surefire-reports-it .harness/tests/tiffinbox-web/target/failsafe-reports $vre <<'PY'
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
  echo "  Testcontainers containers after: $(dk ps -aq --filter label=org.testcontainers=true | wc -l | tr -d ' ') · images pulled: $($G -ciE 'Pulling image|pull(ed|ing) ' .harness/verify.log || true)"
  echo "  downloads across the builds: $(cat .harness/verify.log .harness/need.log .harness/build-after.log .harness/build-before.log | $G -cE 'Download(ing|ed) from ' || true)"; }
c_harness() {
  echo "== harness: the folder's files and the instruments (copied byte-equal, adapted with a named diff, new)"
  echo "  harness/: $(ls harness | paste -sd' ' -) · harness/src: $(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -) · exercise/: $(ls exercise | paste -sd' ' -)"
  echo "  copied | dur9.py md5 $(md5 -q harness/dur9.py) · ops9s3.py md5 $(md5 -q harness/ops9s3.py) (unit 21's) · Bind.java $(md5 -q harness/src/probe22/Bind.java) (the held run's) · Rec.java $(md5 -q harness/src/probe22b/Rec.java), reach.py $(md5 -q harness/reach.py), rec.py $(md5 -q harness/rec.py) (BLUE C9-U22's)"
  echo "  adapted | tree22.py from tree21.py: $(diff ../c9-unit21/harness/tree21.py harness/tree22.py | $G -c '^[<>]') lines (the docstring only) · s922.py from s921.py: lines removed $(diff ../c9-unit21/harness/s921.py harness/s922.py | $G -c '^<'), added $(diff ../c9-unit21/harness/s921.py harness/s922.py | $G -c '^>'), the diff's md5 $(diff ../c9-unit21/harness/s921.py harness/s922.py | md5 -q) · bind.py from the held run's: the named diff's md5 $BPD"
  echo "  new | chk22.py md5 $(md5 -q harness/chk22.py) · norm.py $(md5 -q harness/norm.py) · Limits.java $(md5 -q harness/src/probe22/Limits.java) · exercise: break.sh $(md5 -q exercise/break.sh) · apply.sh $(md5 -q exercise/apply.sh) · check.sh $(md5 -q exercise/check.sh)"
  echo "  not used (absent from harness/): cdp.mjs cdp9.mjs seal9.py chrome20.py loc9.py stub src/probe21 - $(for f in cdp.mjs cdp9.mjs seal9.py chrome20.py loc9.py stub src/probe21; do [ -e harness/$f ] && echo $f; done | wc -l | tr -d ' ') present"
  echo "  static (i), as written: output md5 $STMD5"
  local SC=.harness/static-copy; rm -rf $SC; mkdir -p $SC; cp -R after $SC/after; ln -s "$U/before" $SC/before; printf 'x' >> $SC/after/compose.yaml
  python3 -I -B harness/chk22.py static $SC/after $SC/before > $J/st2.txt 2>&1; local e2=$?
  echo "  static (ii) on a scratch copy with a byte appended to after/compose.yaml (a path this unit did not change; the frozen tree untouched): exit $e2 · a FAIL names it: $($G -c '^FAIL.*compose.yaml' $J/st2.txt || true)"
  local III=.harness/iii/u; rm -rf .harness/iii; mkdir -p $III/harness; cp harness/chk22.py $III/harness/; cp -R after $III/after; cp -RL before $III/before
  local s3; s3=$(cd $III && REPO="$UP" python3 -I -B harness/chk22.py static after before 2>&1 | md5 -q)
  echo "  static (iii) in a folder copy with no sibling anchor (git objects read from the repository by REPO): output md5 = (i): $( [ "$s3" = "$STMD5" ] && echo yes || echo NO)"
  echo "  ~ static (iii) of this run: the anchor folder beside this unit's folder $( [ -d "../$ANC" ] && echo 'present (runs 1, 2)' || echo 'moved aside (the sealed clone, run 3)')"
  echo "  static plants (flag 20): a static assertion reading the live anchor (its folder name assembled) -> $(python3 -I -B harness/chk22.py static-plant live > /dev/null 2>&1; echo "exit $?") · the same path from two pieces -> $(python3 -I -B harness/chk22.py static-plant pieces > /dev/null 2>&1; echo "exit $?")"
  printf '%s\n' 'paste a b | sed -E '"'"'1~2s/^/x/'"'"' > $J/side.txt' > $J/gnu-plant.sh   # GNUFORM (the plant)
  echo "  R.564 plant: a GNU-only sed line counted by the receipts' own GNU-form grep: $($G -cE "sed [^|]*[0-9]~[0-9]|sed -i( |$)|sed -i ''" $J/gnu-plant.sh || true) (1 = caught)"   # GNUFORM
  echo "  the frozen receipts that read the live anchor's poms (the orchestrator's flag-31 class, read, not edited): $(for f in ../c9-unit10/receipts.sh:611 ../c9-unit13/receipts.sh:334 ../c9-unit15/receipts.sh:396; do n=${f##*:}; sed -n "${n}p" "${f%%:*}" | $G -cF "$ANC" | sed "s#^#${f#../}=#"; done | paste -sd' ' -) (1 = the line names the live anchor)"; }
exrun() { local v=$1 sh=$2 o cmd
  guard "the exercise, $v, $sh"
  rm -rf .harness/exercise/tree; copy after .harness/exercise/tree
  if [ $v = broken ]; then cmd='sh break.sh "$0" > /dev/null && sh check.sh "$0"'; elif [ $v = solved ]; then cmd='sh break.sh "$0" > /dev/null && sh apply.sh "$0" > /dev/null && sh check.sh "$0"'; else cmd="sh break.sh \"\$0\" > /dev/null && HOW=$v sh apply.sh \"\$0\" > /dev/null && sh check.sh \"\$0\""; fi
  local envs=(env -i PATH="$XPATH" HOME="$U/.harness/home" PORT=21168 MAVEN_REPO="$M2" JAVA_HOME="$JAVA_HOME" DOCKER_HOST=unix:///nonexistent/docker.sock)
  if [ $sh = bash ]; then o=$(cd exercise && "${envs[@]}" bash -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1)
  else o=$(cd exercise && "${envs[@]}" /bin/zsh -f -c "$cmd < /dev/null; echo \"check exit \$?\"" "../.harness/exercise/tree" 2>&1); fi
  local pre="  $v $sh |"; if [ $v != broken ] && [ $v != solved ]; then pre="  ~ $v $sh |"; fi
  printf '%s\n' "$o" | sed -E "s/127\.0\.0\.1:21168/127.0.0.1:<port>/g; s/^/$pre /"
  [ ! -f exercise/check.build.log ] || offl exercise/check.build.log
  [ "$(listeners 21168)" = 0 ] || die "the exercise left something listening on 21168"; }
c_exercise() { local v sh
  rm -rf .harness/exercise; mkdir -p .harness/exercise
  for v in broken solved; do for sh in bash zsh; do echo "  == $v, $sh"; exrun $v $sh; done; done
  if [ "$RUNNO" = 1 ] || [ "$RUNNO" = 0 ]; then for v in none strict nowrite; do exrun $v bash; done; fi
  rm -rf exercise/check.run; rm -f exercise/check.build.log
  echo "== What it prints, as the two files say"
  wib exercise/README.md | sed 's/^/  README: /'; wib exercise/SOLUTION.md | sed 's/^/  SOLUTION: /'; }
c_title() {
  local TS; TS=$(python3 -I -B harness/chk22.py title-line)
  echo "== the title for search (S4B's Unit 22, printed, not edited - the copy step's): \"$TS\" ($(python3 -I -c 'import sys; print(len(sys.argv[1]))' "$TS") characters by len())"
  echo "  over-posting named in it: $(printf '%s\n' "$TS" | $G -ci 'over-posting' || true) · a 'blocked' claim in it: $(printf '%s\n' "$TS" | $G -ciE 'block|prevent|stop' || true)"; }

# ---- the run ---------------------------------------------------------------------------------------------------------------------------
echo "### the captures${DEVCAPS:+ (DEVELOPMENT: only $DEVCAPS - not a run of record)}"
cap advisory c_advisory
cap before c_before
cap change c_change
cap census c_census
cap drop c_drop
NEEDPG=1; [ -n "${DEVCAPS:-}" ] && ! echo " $DEVCAPS " | $G -qE ' (bind|record|strict|key) ' && NEEDPG=""
[ -z "$NEEDPG" ] || pgup
cap bind c_bind
cap record c_record
cap strict c_strict
cap key c_key
[ -z "$NEEDPG" ] || pgdown
cap limits c_limits
cap spec c_spec
cap moved c_moved
cap api c_api
cap seven c_seven
cap surface c_surface
cap tests c_tests
cap harness c_harness
cap exercise c_exercise
cap title c_title
echo "== plants (each made to FAIL first on a copy of this run's capture; harness/chk22.py plants)"
if [ -z "${DEVCAPS:-}" ]; then
PL=$(python3 -I -B harness/chk22.py plants .) || die "a plant was not caught: $(printf '%s\n' "$PL" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$PL" | $G '^ok ' | sed 's/^ok /  /'
PLV=$(printf '%s\n' "$PL" | sed -n 's/^VALUES //p')
fi

# ---- the end: the sweep, the values, the published hashes -------------------------------------------------------------------------------
[ -z "$(echo $PIDS)" ] || die "a JVM of this run is still running: $PIDS"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something still listens on $p"; done
[ -z "$(dk ps -aq --filter label=org.testcontainers=true)" ] || die "a Testcontainers container of this run is left"
[ -z "$(dk ps -aq --filter name=^/c9u22-)" ] || die "a c9u22-* container is left"
NI1=$(dk images -q --no-trunc 2> /dev/null | sort -u | wc -l | tr -d ' '); VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI1" = "$NI0" ] && [ "$VOL1" = "$VOL0" ] || die "R.322: images $NI0 -> $NI1, volumes $VOL0 -> $VOL1"
AD1=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c9-tiffinbox 2>&1 || true); [ "$AD1" = "$AD" ] || die "the anchor moved during the run"
pin before-tree before; pin after-tree after
MDB=$(find . ../c9-tiffinbox ../c9-unit21 -name '*.mv.db' -not -path './.harness/*' -not -path '../c9-unit21/.harness/*' 2> /dev/null | wc -l | tr -d ' ')
[ "$MDB" = 0 ] || die "an H2 file outside .harness/"
[ -z "$(ls exercise | $G -v -xE 'README.md|SOLUTION.md|apply.sh|break.sh|check.sh')" ] || die "the exercise left a file in exercise/"
VALS="$VALS
plants: $PLV
build: seed_files=$NF0 seed_bytes=$NB0 central_only=$CO"
printf '%s\n' "$VALS" | sed 's/^/  values (this run) /'
[ -n "${DEVCAPS:-}" ] && { echo "c9-unit22: DEVELOPMENT run ($DEVCAPS) - nothing published"; exit 2; }
VO=$(python3 -I -B harness/chk22.py values README.md "$VALS") || { printf '%s\n' "$VO" | sed 's/^/  /'; [ -n "${NOPIN:-}" ] || die "README.md's values block is not this run's"; }
printf '%s\n' "$VO" | tail -1 | sed 's/^/  /'
echo "  sweep: no JVM of this run, ports free, no container left, images $NI0 -> $NI1, volumes $VOL0 -> $VOL1 · the anchor against after/ as at the start · the tree pins · *.mv.db outside .harness 0"
for f in .r-*.new; do mv "$f" "${f%.new}.out"; done   # the captures replace the last run's only when the whole run got here
if [ -n "$unpub" ]; then echo "c9-unit22: $NCAPS captures checked; NOT published:$unpub"; exit 2; fi
echo "c9-unit22: $NCAPS captures checked; every capture = published ($NCAPS)"
