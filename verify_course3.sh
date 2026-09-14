#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# verify_course3.sh — runs every command the Build & Test Like a Pro (`c3-*`)
# READMEs give a viewer, and says PASS/FAIL for each one.
#
#   ./verify_course3.sh                 # every c3-* folder that exists
#   ./verify_course3.sh 03 06           # only those units
#   ./verify_course3.sh tiffinbox       # only c3-tiffinbox (that is unit 05's code)
#   SKIP_SLOW=1 ./verify_course3.sh     # skip the repeated-build hash loops
#   KEEP_M2=1 ./verify_course3.sh       # keep the scratch repositories (warm re-runs)
#
# It walks only the folders that are actually present, so it stays green as new
# units land. Every command is time-boxed and its JVM killed; the server port is
# asserted free before use and after; every file the READMEs generate is removed.
#
# Requires JDK **25** and Apache Maven 3.9.x.
#   export JAVA_HOME=/opt/homebrew/opt/openjdk@25
#   ./verify_course3.sh
#
# JAVA_HOME is not decoration. A bare `java` on this Mac is 23.0.1 and a default
# Maven resolves JDK 26; c3-unit01, c3-unit03 and c3-unit04 compile
# `--release 25 --enable-preview`, which JDK 26 refuses with
# `invalid source release 25 with --enable-preview`. The script exports it for
# every `mvn` and `java` it runs and refuses to start on the wrong JDK.
#
# Two rules this script keeps, and why:
#
#   1. **`mvn -o` only against a repository this run filled itself.**
#      verify_course2.sh used offline mode everywhere; on the maintainer's warm
#      machine everything passed and a fresh clone with a cold local repository
#      was 15 FAIL / 27 PASS, because offline mode cannot resolve what was never
#      downloaded. That false green is about *depending* on a warm repository —
#      but several c3 READMEs make an explicit **offline receipt** claim ("this
#      resolves nothing new when offline"), and a claim nobody runs is a claim
#      nobody has checked. So every offline receipt here is a **pair**, run by
#      `offline_receipt` below: the ordinary ONLINE `verify` first, into the
#      scratch repository, and then the SAME command with `-o` in the SAME
#      scratch repository. The online half is what earns the offline half its
#      meaning — a green `-o` then really does say "this needed nothing new",
#      and never "this machine happened to be warm".
#
#   2. **Your real `~/.m2` is never written to.** Course 3 runs `install` and
#      `deploy`; every `mvn` below carries a quoted `-Dmaven.repo.local=`, which
#      is the only difference between these commands and the ones printed in the
#      READMEs. The units that name their own scratch repository get that one
#      (`c3-unit02/.m2-demo`, `c3-unit04/.m2-unit04`, `c3-unit06/.m2-unit06`,
#      `/tmp/m2consumer`); everything else shares $M2_REPO, which defaults to a
#      directory outside the repository. `~/.m2/repository/com/tiffinbox` is
#      asserted absent at the end of the run.
#
#      **The quotes are not decoration.** This tree lives under a directory whose
#      name contains a space (`Youtube Content`); unquoted, the shell splits
#      `-Dmaven.repo.local=` and Maven reads the tail as a goal:
#      `Unknown lifecycle phase "Content/LearnProgrammingWithVivek/…"`.
#
# The first run downloads Maven plugins and H2/Jackson/SnakeYAML/JUnit into cold
# scratch repositories, so it needs a network and takes a while. $M2_REPO lives
# outside the repository and is kept between runs; the three that live inside a
# unit folder are deleted at the end unless KEEP_M2=1, so the working tree is as
# the run found it.
# ---------------------------------------------------------------------------
set -u

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ----------------------------------------------------------------- the JDK ---
JAVA_HOME="${JAVA_HOME:-/opt/homebrew/opt/openjdk@25}"
if [ ! -x "$JAVA_HOME/bin/java" ]; then
  cat >&2 <<EOF
verify_course3.sh needs JDK 25, and JAVA_HOME does not name one:
  JAVA_HOME=$JAVA_HOME
Set it and run again, e.g.
  export JAVA_HOME=/opt/homebrew/opt/openjdk@25
EOF
  exit 2
fi
export JAVA_HOME
export PATH="$JAVA_HOME/bin:$PATH"
JAVA="$JAVA_HOME/bin/java"
JAVAP="$JAVA_HOME/bin/javap"
export JAVA JAVAP     # the `bash -c` helpers below reach for both

JV="$("$JAVA" -version 2>&1 | head -1)"
JMAJOR="$(printf '%s' "$JV" | sed -n 's/.*"\([0-9][0-9]*\).*/\1/p')"
if [ "${JMAJOR:-0}" != "25" ]; then
  cat >&2 <<EOF
verify_course3.sh needs JDK 25 exactly, and JAVA_HOME gives: $JV
Older refuses to RUN what this course builds: a bare \`java\` on this Mac is
23.0.1 and cannot read a class file of version 69.
Newer refuses to BUILD it: c3-unit01, c3-unit03 and c3-unit04 compile
\`--release 25 --enable-preview\`, and JDK 26 answers
  [ERROR] invalid source release 25 with --enable-preview
Point JAVA_HOME at a JDK 25 and run again:
  export JAVA_HOME=/opt/homebrew/opt/openjdk@25
EOF
  exit 2
fi

if ! command -v mvn >/dev/null 2>&1; then
  echo "verify_course3.sh needs Apache Maven 3.9.x on the PATH — Course 3 is the Maven course." >&2
  exit 2
fi
MVNV="$(mvn -v 2>/dev/null | head -1)"
MVN_VERSION="$(printf '%s' "$MVNV" | sed -n 's/^Apache Maven \([0-9.]*\).*/\1/p')"

# ------------------------------------------------------------- scratch repo ---
# One shared local repository for the units that do not name their own, plus the
# three the READMEs do name. None of them is ~/.m2.
M2="${M2_REPO:-${TMPDIR:-/tmp}/c3verify-m2}"
case "$M2" in /*) ;; *) M2="$PWD/$M2" ;; esac
M2_U02="$REPO/c3-unit02/.m2-demo"
M2_U04="$REPO/c3-unit04/.m2-unit04"
M2_U06="$REPO/c3-unit06/.m2-unit06"
M2_CONSUMER="/tmp/m2consumer"        # c3-unit06/README.md step 3 names this path
export M2 M2_U02 M2_U04 M2_U06 M2_CONSUMER

TAG="c3verify$$"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/c3verify.XXXXXX")"
OUT="$WORK/out.txt"
export TAG WORK REPO OUT
PORT="${PORT:-18425}"
SKIP_SLOW="${SKIP_SLOW:-0}"
KEEP_M2="${KEEP_M2:-0}"

PASS=0; FAIL=0; SKIP=0; FAILED_LABELS=()
RED=''; GRN=''; YLW=''; DIM=''; OFF=''
if [ -t 1 ]; then RED=$'\033[31m'; GRN=$'\033[32m'; YLW=$'\033[33m'; DIM=$'\033[2m'; OFF=$'\033[0m'; fi

# --------------------------------------------------- edited files, restored ---
# Several exercises say `cp solution/pom.xml pom.xml`, and one break beat edits a
# source file with sed. Every such file is copied aside first and put back by the
# EXIT trap, so an interrupted run still leaves the working tree as it found it.
BAK_SRC=(); BAK_DST=(); BAK_N=0
backup() {
  local f="$1"
  [ -f "$f" ] || return 0
  BAK_N=$((BAK_N+1))
  cp "$f" "$WORK/bak.$BAK_N" || return 1
  BAK_SRC+=("$f"); BAK_DST+=("$WORK/bak.$BAK_N")
}
restore_all() {
  local i=0
  while [ "$i" -lt "${#BAK_SRC[@]}" ]; do
    [ -f "${BAK_DST[$i]}" ] && cp "${BAK_DST[$i]}" "${BAK_SRC[$i]}" 2>/dev/null
    i=$((i+1))
  done
}

# ----------------------------------------------------------------- cleanup ---
# Exactly what the Course 3 block of .gitignore lists, plus the scratch
# repositories and the one file the consumer demo writes under /tmp.
cleanup() {
  pkill -9 -f "$TAG" >/dev/null 2>&1
  restore_all
  # target/ everywhere under Course 3 (incl. c3-unit06/target/team-repo)
  local d
  for d in "$REPO"/c3-unit0[1-6] "$REPO"/c3-tiffinbox; do
    [ -d "$d" ] || continue
    find "$d" -type d -name target -prune -exec rm -rf {} + 2>/dev/null
    find "$d" -type d -name 'generated-sources' -prune -exec rm -rf {} + 2>/dev/null
  done
  rm -f  "$REPO"/c3-unit01/effective-pom.xml 2>/dev/null
  rm -f  "$REPO"/c3-unit03/scopes/cp-*.txt 2>/dev/null
  rm -f  "$REPO"/c3-unit02/cp.txt "$REPO"/c3-unit02/*/cp.txt 2>/dev/null
  rm -f  "$REPO"/c3-unit06/es.xml 2>/dev/null
  if [ "$KEEP_M2" != "1" ]; then
    rm -rf "$M2_U02" "$M2_U04" "$M2_U06" "$M2_CONSUMER" 2>/dev/null
  fi
  rm -rf "$WORK"
}
trap cleanup EXIT INT TERM

# ------------------------------------------------------------- the reports ---
ok()   { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$GRN" "$OFF" "$1"; }
bad()  { FAIL=$((FAIL+1)); FAILED_LABELS+=("$1"); printf '  %sFAIL%s  %s\n     %s\n' "$RED" "$OFF" "$1" "$2";
         sed -n '1,12p' "$OUT" 2>/dev/null | sed 's/^/     | /'; }
skip() { SKIP=$((SKIP+1)); printf '  %sSKIP%s  %s %s(%s)%s\n' "$YLW" "$OFF" "$1" "$DIM" "$2" "$OFF"; }

# run CMD... with a wall-clock limit; stdout+stderr -> $OUT; returns the exit
# code (124 if it had to be killed). Kills the whole process group of the child.
RC=0
timed() {
  local secs="$1"; shift
  ( "$@" >"$OUT" 2>&1 ) &
  local pid=$! waited=0 limit=$(( secs * 10 ))
  while kill -0 "$pid" 2>/dev/null; do
    if [ "$waited" -ge "$limit" ]; then
      pkill -9 -P "$pid" >/dev/null 2>&1; kill -9 "$pid" >/dev/null 2>&1
      pkill -9 -f "$TAG" >/dev/null 2>&1
      wait "$pid" 2>/dev/null; RC=124; return 124
    fi
    sleep 0.1; waited=$((waited+1))
  done
  wait "$pid"; RC=$?; return $RC
}

# expect_ok   LABEL TIMEOUT PATTERN CMD...  exit 0 and PATTERN in the output
expect_ok() {
  local label="$1" t="$2" pat="$3"; shift 3
  timed "$t" "$@"
  if [ "$RC" -eq 124 ]; then bad "$label" "timed out after ${t}s (expected it to finish)"; return 1; fi
  if [ "$RC" -ne 0 ]; then bad "$label" "exit $RC, expected 0"; return 1; fi
  if [ -n "$pat" ] && ! grep -qE "$pat" "$OUT"; then bad "$label" "expected output matching: $pat"; return 1; fi
  ok "$label"; return 0
}

# expect_fail LABEL TIMEOUT PATTERN CMD...  non-zero exit and PATTERN present
expect_fail() {
  local label="$1" t="$2" pat="$3"; shift 3
  timed "$t" "$@"
  if [ "$RC" -eq 124 ]; then bad "$label" "timed out after ${t}s (expected it to fail fast)"; return 1; fi
  if [ "$RC" -eq 0 ]; then bad "$label" "exit 0, expected a failure"; return 1; fi
  if [ -n "$pat" ] && ! grep -qE "$pat" "$OUT"; then bad "$label" "expected error matching: $pat"; return 1; fi
  ok "$label (fails on purpose)"; return 0
}

# expect_rc   LABEL TIMEOUT WANTED_RC PATTERN CMD...  an exact exit code
expect_rc() {
  local label="$1" t="$2" want="$3" pat="$4"; shift 4
  timed "$t" "$@"
  if [ "$RC" -eq 124 ]; then bad "$label" "timed out after ${t}s"; return 1; fi
  if [ "$RC" -ne "$want" ]; then bad "$label" "exit $RC, expected $want"; return 1; fi
  if [ -n "$pat" ] && ! grep -qE "$pat" "$OUT"; then bad "$label" "expected output matching: $pat"; return 1; fi
  ok "$label"; return 0
}

# ------------------------------------------------------ the offline receipts ---
# mvn_in DIR REPO ARGS... — one Maven run, the way every one in this script is done:
# from DIR, against a scratch local repository, never ~/.m2. `timed` runs it in a
# subshell, so the `cd` never leaks back here.
mvn_in() { local d="$1" r="$2"; shift 2; cd "$d" && mvn -B "-Dmaven.repo.local=$r" "$@"; }

# offline_receipt LABEL TIMEOUT DIR REPO ARGS...
# Proves a README's "offline receipt" line instead of assuming it, as two assertions:
# the ordinary ONLINE `verify` into REPO, then the SAME command with `-o` in the SAME
# REPO. The first is what makes the second mean anything; if the second is green, the
# README's claim holds — that build resolved nothing new.
offline_receipt() {
  local label="$1" t="$2" d="$3" r="$4"; shift 4
  expect_ok "$label — online first, into the scratch repository" "$t" 'BUILD SUCCESS' \
      mvn_in "$d" "$r" "$@" verify || return 1
  expect_ok "$label — then -o, same repository: it resolved nothing new" "$t" 'BUILD SUCCESS' \
      mvn_in "$d" "$r" -o "$@" verify
}

# assertions about an artifact rather than about an exit code — the only honest
# way to check a silent failure (c3-unit04's annotation processor)
is()      { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1" "expected [$3], got [$2]"; fi; }
has()     { if grep -qE "$2" "$OUT"; then ok "$1"; else bad "$1" "expected output matching: $2"; fi; }
hasnt()   { if grep -qE "$2" "$OUT"; then bad "$1" "did NOT expect: $2"; else ok "$1"; fi; }
exists()  { if [ -e "$2" ]; then ok "$1"; else bad "$1" "missing: $2"; fi; }
absent()  { if [ -e "$2" ]; then bad "$1" "should not exist: $2"; else ok "$1"; fi; }
countq()  { grep -cE "$1" "$OUT" 2>/dev/null | tr -d ' '; }
md5of()   { if command -v md5 >/dev/null 2>&1; then md5 -q "$1"; else md5sum "$1" | cut -d' ' -f1; fi; }
md5in()   { if command -v md5 >/dev/null 2>&1; then md5 -q; else md5sum | cut -d' ' -f1; fi; }

# ------------------------------------------ the tree, before and after --------
# The run swaps pom.xml files and `sed`s one source file, and has to put every one
# back. The old proof was `git status` at the end — which also fails when the tree
# legitimately carries uncommitted work that this run never touched. So take a
# content fingerprint of everything Course 3 ships, minus what a build writes, and
# compare it with itself at the end: that is literally "as this run found it".
tree_fingerprint() {
  local d f
  { for d in "$REPO"/c3-unit0[1-6] "$REPO"/c3-tiffinbox; do
      [ -d "$d" ] || continue
      find "$d" -type f \
           -not -path '*/target/*'      -not -path '*/.m2-demo/*' \
           -not -path '*/.m2-unit04/*'  -not -path '*/.m2-unit06/*' \
           -not -name 'cp.txt'          -not -name 'cp-*.txt' \
           -not -name 'es.xml'          -not -name 'effective-pom.xml' 2>/dev/null
    done | LC_ALL=C sort | while IFS= read -r f; do
      printf '%s  %s\n' "$(shasum "$f" | cut -d' ' -f1)" "${f#"$REPO"/}"
    done; } | shasum | cut -d' ' -f1
}

# --------------------------------------------------------------- the ports ---
port_busy()      { lsof -nP -iTCP:"$1" -sTCP:LISTEN >/dev/null 2>&1; }
wait_port_free() { local i; for i in $(seq 1 60);  do port_busy "$1" || return 0; sleep 0.25; done; return 1; }
wait_port_up()   { local i; for i in $(seq 1 160); do port_busy "$1" && return 0; sleep 0.25; done; return 1; }

# ------------------------------------------------------------ unit filters ---
UNITS=("$@")
if [ ${#UNITS[@]} -ne 0 ]; then
  for u in "${UNITS[@]}"; do
    case "$u" in
      tiffinbox|05) ;;   # unit 05's code IS c3-tiffinbox; c3-unit05/ holds only the exercise
      0[1-6]) [ -d "$REPO/c3-unit$u" ] || { echo "unknown unit: $u (no c3-unit$u/ in $REPO)" >&2; exit 2; } ;;
      *) echo "unknown unit: $u (use two digits, 01-06, or 'tiffinbox')" >&2; exit 2 ;;
    esac
  done
fi
want() {
  [ ${#UNITS[@]} -eq 0 ] && return 0
  local u; for u in "${UNITS[@]}"; do [ "$u" = "$1" ] && return 0; done; return 1
}
unit() {  # unit NN "title" -> cd into c3-unitNN, or skip the section
  local n="$1"
  want "$n" || return 1
  [ -d "$REPO/c3-unit$n" ] || return 1
  printf '\n%sc3-unit%s%s  %s\n' "$DIM" "$n" "$OFF" "$2"
  cd "$REPO/c3-unit$n" || return 1
  return 0
}

printf 'verify_course3.sh — %s\n' "$JV"
printf '                   %s\n' "$MVNV"
printf 'repo: %s\n' "$REPO"
printf 'local repositories (never ~/.m2): %s\n' "$M2"
printf '                                  c3-unit02/.m2-demo · c3-unit04/.m2-unit04 · c3-unit06/.m2-unit06 · %s\n' "$M2_CONSUMER"
[ "$SKIP_SLOW" = "1" ] && printf '%sSKIP_SLOW=1 — the repeated-build hash loops are shortened%s\n' "$YLW" "$OFF"
if [ -e "$HOME/.m2/repository/com/tiffinbox" ]; then
  printf '%sNOTE: ~/.m2/repository/com/tiffinbox already exists — something before this run installed it.%s\n' "$YLW" "$OFF"
fi

FP_BEFORE="$(tree_fingerprint)"

# =========================================================== c3-tiffinbox ===
# Unit 05's code. Runs first because unit 05's exercise is a copy of it.
if want tiffinbox || want 05; then
if [ -d "$REPO/c3-tiffinbox" ]; then
  printf '\n%sc3-tiffinbox%s  TiffinBox, split into modules (the project unit 05 builds)\n' "$DIM" "$OFF"
  cd "$REPO/c3-tiffinbox" || exit 2

  # the rule that decides which class goes where, grepped exactly as the README does
  timed 60 bash -c 'cd "$REPO/c3-tiffinbox" && grep -rl "com.sun.net.httpserver" tiffinbox-*/src'
  has "grep -rl com.sun.net.httpserver tiffinbox-*/src -> web only" 'tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java'
  hasnt "…and no HTTP anywhere in core" 'tiffinbox-core/'
  timed 60 bash -c 'cd "$REPO/c3-tiffinbox" && grep -rl "java.sql" tiffinbox-*/src'
  has "grep -rl java.sql tiffinbox-*/src -> core only" 'tiffinbox-core/src/main/java/com/tiffinbox/(CustomerRepository|Database).java'
  hasnt "…and no SQL anywhere in web" 'tiffinbox-web/'

  expect_ok "mvn -B clean package (3 modules, first run downloads H2 + Jackson)" 1200 \
      'BUILD SUCCESS' bash -c 'cd "$REPO/c3-tiffinbox" && mvn -B "-Dmaven.repo.local=$M2" clean package'
  RS="$(sed -n '/Reactor Summary/,/^\[INFO\] -----/p' "$OUT" | grep -cE 'SUCCESS \[|FAILURE \[|SKIPPED' | tr -d ' ')"
  is "the Reactor Summary lists 3 modules (parent, core, web)" "$RS" "3"

  expect_ok "unzip -p tiffinbox-web/target/tiffinbox-web-1.0.0.jar META-INF/MANIFEST.MF" 60 \
      'Main-Class: com.tiffinbox.web.TiffinBoxServer' \
      bash -c 'cd "$REPO/c3-tiffinbox" && unzip -p tiffinbox-web/target/tiffinbox-web-1.0.0.jar META-INF/MANIFEST.MF'
  has "…and its Class-Path starts with lib/tiffinbox-core-1.0.0.jar" 'Class-Path: lib/tiffinbox-core-1.0.0.jar'

  timed 60 bash -c 'cd "$REPO/c3-tiffinbox" && ls tiffinbox-web/target/lib'
  LIBS="$(tr -d ' ' <"$OUT" | sort | tr '\n' ' ')"
  is "ls tiffinbox-web/target/lib -> 5 jars, core among them" "$LIBS" \
     "h2-2.5.250.jar jackson-annotations-2.22.jar jackson-core-2.22.2.jar jackson-databind-2.22.2.jar tiffinbox-core-1.0.0.jar "

  expect_ok "javap -v … com.tiffinbox.Dashboard | grep -E 'major|minor' (no preview bit)" 120 \
      'minor version: 0' bash -c 'cd "$REPO/c3-tiffinbox" && "$JAVA_HOME/bin/javap" -v -cp tiffinbox-core/target/classes com.tiffinbox.Dashboard | grep -E "major|minor"'
  has "…major version: 69" 'major version: 69'

  expect_ok "mvn -B dependency:tree (whole project — h2 under core, jackson under web)" 600 \
      'com.h2database:h2:jar:2.5.250:compile' \
      bash -c 'cd "$REPO/c3-tiffinbox" && mvn -B "-Dmaven.repo.local=$M2" dependency:tree'
  has "…jackson-annotations is 2.22, not 2.22.2" 'jackson-annotations:jar:2.22:compile'

  # ---- the selector table. These three have to run BEFORE `install`, because
  # they are only true while tiffinbox-core is NOT in the local repository.
  rm -rf "$M2/com/tiffinbox"
  expect_fail "mvn -B clean package -pl tiffinbox-web (no -am: BUILD FAILURE, exit 1)" 600 \
      'Could not find artifact com.tiffinbox:tiffinbox-core:jar:1.0.0' \
      bash -c 'cd "$REPO/c3-tiffinbox" && mvn -B "-Dmaven.repo.local=$M2" clean package -pl tiffinbox-web'
  expect_ok "mvn -B dependency:tree -pl tiffinbox-web (WARNING + exit 0, and h2 vanishes)" 600 \
      'The POM for com.tiffinbox:tiffinbox-core:jar:1.0.0 is missing' \
      bash -c 'cd "$REPO/c3-tiffinbox" && mvn -B "-Dmaven.repo.local=$M2" dependency:tree -pl tiffinbox-web'
  hasnt "…h2 is not drawn at all once core goes flat" 'com.h2database:h2'
  expect_ok "mvn -B clean package -pl tiffinbox-web -am (3 modules, BUILD SUCCESS)" 900 \
      'BUILD SUCCESS' bash -c 'cd "$REPO/c3-tiffinbox" && mvn -B "-Dmaven.repo.local=$M2" clean package -pl tiffinbox-web -am'
  RS="$(sed -n '/Reactor Summary/,/^\[INFO\] -----/p' "$OUT" | grep -cE 'SUCCESS \[|FAILURE \[|SKIPPED' | tr -d ' ')"
  is "…and its Reactor Summary has 3 rows" "$RS" "3"
  expect_ok "mvn -B clean package -pl tiffinbox-core (1 module, no Reactor Summary at all)" 600 \
      'BUILD SUCCESS' bash -c 'cd "$REPO/c3-tiffinbox" && mvn -B "-Dmaven.repo.local=$M2" clean package -pl tiffinbox-core'
  hasnt "…a one-module build prints no Reactor Summary — the absence IS the count" 'Reactor Summary'

  # ---- run it. java -jar, no --enable-preview: that is the whole point of the swap.
  expect_ok "mvn -B clean package (rebuild all three before running)" 900 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-tiffinbox" && mvn -B "-Dmaven.repo.local=$M2" clean package'
  if port_busy "$PORT"; then
    skip "java -jar tiffinbox-web-1.0.0.jar + the six curls" "port $PORT is already in use"
  else
    ( cd "$REPO/c3-tiffinbox/tiffinbox-web" && "$JAVA" "-D$TAG=srv" \
        -Djava.util.logging.config.file=logging.properties \
        -jar target/tiffinbox-web-1.0.0.jar "$PORT" ) >"$WORK/srv.log" 2>&1 &
    SRV=$!
    if wait_port_up "$PORT"; then
      cp "$WORK/srv.log" "$OUT"
      has "java -jar target/tiffinbox-web-1.0.0.jar -> orders cooked: 120" 'orders cooked: +120'
      has "…kitchen value: 24300" 'kitchen value: +24300'
      has "…routes mapped: the five routes" 'routes mapped: +\[GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown\]'
      has "…TiffinBox listening on http://127.0.0.1:$PORT" "TiffinBox listening on http://127.0.0.1:$PORT"
      C="$(curl -s -m 10 "http://127.0.0.1:$PORT/customers")"
      is "curl /customers -> the four customers, in name order" "$C" \
         '[{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]'
      C="$(curl -s -m 10 "http://127.0.0.1:$PORT/dashboard")"
      is "curl /dashboard" "$C" '{"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}'
      C="$(curl -s -m 10 "http://127.0.0.1:$PORT/kitchen")"
      is "curl /kitchen" "$C" '{"ordersCooked":120,"ordersValue":24300}'
      C="$(curl -s -m 10 "http://127.0.0.1:$PORT/revenue")"
      is "curl /revenue" "$C" '{"monthRevenue":24300}'
      C="$(curl -s -m 10 -o /dev/null -w '%{http_code}' "http://127.0.0.1:$PORT/pauses")"
      is "curl /pauses -> 404, there is no such route" "$C" "404"
      C="$(curl -s -m 10 -w ' %{http_code}' "http://127.0.0.1:$PORT/shutdown")"
      is "curl GET /shutdown -> 405, wrong verb" "$C" '{"error":"method not allowed"} 405'
      C="$(curl -s -m 10 -X POST "http://127.0.0.1:$PORT/shutdown")"
      is "curl -X POST /shutdown" "$C" '{"stopping":true}'
    else
      cp "$WORK/srv.log" "$OUT"; bad "java -jar target/tiffinbox-web-1.0.0.jar" "the server never came up"
    fi
    for _ in $(seq 1 60); do kill -0 "$SRV" 2>/dev/null || break; sleep 0.25; done
    kill -9 "$SRV" >/dev/null 2>&1; wait "$SRV" 2>/dev/null
    pkill -9 -f "$TAG=srv" >/dev/null 2>&1
    if wait_port_free "$PORT"; then ok "port $PORT free again, the JVM exited on its own"
    else bad "port $PORT" "still in LISTEN after POST /shutdown"; fi
  fi

  # ---- exec:exec needs the sibling in a repository first, and needs -pl
  expect_ok "mvn -B clean install (tiffinbox-core lands in the local repository)" 900 \
      'BUILD SUCCESS' bash -c 'cd "$REPO/c3-tiffinbox" && mvn -B "-Dmaven.repo.local=$M2" clean install'
  expect_fail "mvn -B exec:exec without -pl (the parent has no <executable>)" 600 \
      "The parameter 'executable' is missing or invalid" \
      bash -c 'cd "$REPO/c3-tiffinbox" && mvn -B "-Dmaven.repo.local=$M2" exec:exec'
  if port_busy "$PORT"; then
    skip "mvn -q -B -pl tiffinbox-web exec:exec" "port $PORT is already in use"
  else
    ( cd "$REPO/c3-tiffinbox" && mvn -q -B "-Dmaven.repo.local=$M2" "-Dtiffinbox.tag=$TAG" \
        -pl tiffinbox-web exec:exec ) >"$WORK/exec.log" 2>&1 &
    EX=$!
    if wait_port_up "$PORT"; then
      cp "$WORK/exec.log" "$OUT"
      has "mvn -q -B -pl tiffinbox-web exec:exec -> the same server, started by Maven" \
          "TiffinBox listening on http://127.0.0.1:$PORT"
      curl -s -m 10 -X POST "http://127.0.0.1:$PORT/shutdown" >/dev/null 2>&1
    else
      cp "$WORK/exec.log" "$OUT"; bad "mvn -q -B -pl tiffinbox-web exec:exec" "the server never came up"
    fi
    for _ in $(seq 1 60); do kill -0 "$EX" 2>/dev/null || break; sleep 0.25; done
    pkill -9 -f 'tiffinbox-web-1.0.0.jar' >/dev/null 2>&1
    kill -9 "$EX" >/dev/null 2>&1; wait "$EX" 2>/dev/null
    if wait_port_free "$PORT"; then ok "port $PORT free again after exec:exec"
    else bad "port $PORT" "still in LISTEN after exec:exec"; fi
  fi
  # README line 281: "Offline receipt after one warm build: mvn -o -B verify".
  # Proved as a pair rather than assumed — see the header.
  offline_receipt "mvn -o -B verify (c3-tiffinbox's offline receipt)" 900 "$REPO/c3-tiffinbox" "$M2"

  rm -rf "$M2/com/tiffinbox"
fi
fi

# ============================================================= c3-unit01 ====
if unit 01 "The POM, Read Line by Line"; then
  expect_ok "mvn -B -q help:effective-pom -Doutput=effective-pom.xml && wc -l" 900 '' \
      bash -c 'cd "$REPO/c3-unit01" && mvn -B -q "-Dmaven.repo.local=$M2" help:effective-pom -Doutput=effective-pom.xml && wc -l < effective-pom.xml && wc -l < pom.xml'
  EFF="$(sed -n '1p' "$OUT" | tr -d ' ')"; SRC="$(sed -n '2p' "$OUT" | tr -d ' ')"
  is "…pom.xml is 100 lines" "$SRC" "100"
  is "…the effective POM is 323 lines (Maven $MVN_VERSION)" "$EFF" "323"

  MH="$(mvn -version 2>/dev/null | sed -n 's/^Maven home: //p')"
  if [ -f "$MH/lib/maven-model-builder-3.9.16.jar" ]; then
    timed 60 bash -c 'unzip -p "$1/lib/maven-model-builder-3.9.16.jar" org/apache/maven/model/pom-4.0.0.xml' _ "$MH"
    N="$(wc -l <"$OUT" | tr -d ' ')"
    is "unzip -p maven-model-builder-3.9.16.jar pom-4.0.0.xml | wc -l -> the Super POM is 144 lines" "$N" "144"
    L="$(sed -n '51p' "$OUT" | sed 's/^ *//')"
    is "…line 51 is the <directory> every target/ comes from" "$L" '<directory>${project.basedir}/target</directory>'
  else
    skip "unzip -p maven-model-builder-3.9.16.jar (the Super POM)" "Maven $MVN_VERSION, not the 3.9.16 the README pins"
  fi
  if [ -f "$MH/lib/maven-core-3.9.16.jar" ]; then
    timed 60 bash -c 'unzip -p "$1/lib/maven-core-3.9.16.jar" META-INF/plexus/default-bindings.xml | sed -n "67,94p"' _ "$MH"
    has "unzip -p maven-core-3.9.16.jar default-bindings.xml | sed -n '67,94p' -> the jar lifecycle" 'jar-lifecycle|maven-jar-plugin'
    has "…surefire 3.5.4 is in that table" '3\.5\.4'
    H="$(md5of "$OUT")"
    is "…md5 of those 28 lines" "$H" "902be49edcf2e7a18040e5644bbbe559"
  else
    skip "unzip -p maven-core-3.9.16.jar (the phase table)" "Maven $MVN_VERSION, not the 3.9.16 the README pins"
  fi

  expect_ok "mvn -B clean package | grep '^\[INFO\] --- ' (the pinned plugin versions)" 900 \
      'dependency:3\.11\.0:' bash -c 'cd "$REPO/c3-unit01" && mvn -B "-Dmaven.repo.local=$M2" clean package 2>&1 | grep -E "^\[INFO\] --- "'
  has "…and the build ran the jar plugin at the pinned version too" 'jar:3\.5\.0:jar'
  expect_ok "cd unpinned && mvn -B dependency:tree (the Super POM's inherited 3.7.0)" 900 \
      'dependency:3\.7\.0:tree \(default-cli\) @ unpinned' \
      bash -c 'cd "$REPO/c3-unit01/unpinned" && mvn -B "-Dmaven.repo.local=$M2" dependency:tree'

  # ---- exercise: the starter runs unedited, the solution fails on purpose
  expect_ok "exercise: mvn -B clean package unedited -> BUILD SUCCESS (the property is ignored)" 900 \
      'BUILD SUCCESS' bash -c 'cd "$REPO/c3-unit01/exercise" && mvn -B "-Dmaven.repo.local=$M2" clean package'
  expect_ok "exercise: javap -v … Dashboard -> minor 65535, the preview bit, not the Java 17 asked for" 120 \
      'minor version: 65535' \
      bash -c 'cd "$REPO/c3-unit01/exercise" && "$JAVA_HOME/bin/javap" -v -cp target/classes com.tiffinbox.Dashboard | grep -E "major|minor"'
  has "…major version: 69" 'major version: 69'
  backup "$REPO/c3-unit01/exercise/pom.xml"
  cp "$REPO/c3-unit01/exercise/solution/pom.xml" "$REPO/c3-unit01/exercise/pom.xml"
  expect_fail "exercise solution: cp solution/pom.xml pom.xml && mvn -B clean package" 900 \
      'invalid source release 17 with --enable-preview' \
      bash -c 'cd "$REPO/c3-unit01/exercise" && mvn -B "-Dmaven.repo.local=$M2" clean package'
  H="$(grep -E '^\[ERROR\]' "$OUT" | head -4 | md5in)"
  is "…md5 of the first four [ERROR] lines" "$H" "6742c83f84c6c9b0044888d3cb706a11"
  restore_all
fi

# ============================================================= c3-unit02 ====
if unit 02 "The Lifecycle and the Reactor"; then
  expect_ok 'mvn -B clean package -Dmaven.repo.local="$PWD/.m2-demo" (4 modules)' 1200 \
      'BUILD SUCCESS' bash -c 'cd "$REPO/c3-unit02" && mvn -B clean package "-Dmaven.repo.local=$M2_U02"'
  has "…the Reactor Build Order names all four, parent first" 'TiffinBox \(reactor demo\) +\[pom\]'
  has "…TiffinBox Core [jar]"    'TiffinBox Core +\[jar\]'
  has "…TiffinBox Kitchen [jar]" 'TiffinBox Kitchen +\[jar\]'
  has "…TiffinBox Web [jar]"     'TiffinBox Web +\[jar\]'

  expect_ok "java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar (the three jars, running)" 120 \
      'trays on the rail *: *3' \
      bash -c 'cd "$REPO/c3-unit02" && "$JAVA" "-D$TAG=u02" -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar'
  has "…daily total 375" 'daily total *: *375'
  has "…Meera VEG 120"   'Meera +VEG +120'
  has "…Ravi NON_VEG 180" 'Ravi +NON_VEG +180'
  has "…Asha VEGAN 75"   'Asha +VEGAN +75'

  # README line 13: mvn -o -B verify -Dmaven.repo.local="$PWD/.m2-demo".
  # Proved as a pair rather than assumed — see the header.
  offline_receipt 'mvn -o -B verify -Dmaven.repo.local="$PWD/.m2-demo" (all four modules)' 900 \
      "$REPO/c3-unit02" "$M2_U02"

  # ---- exercise: -pl without -am cannot find the sibling …
  rm -rf "$M2_U02/com/tiffinbox"
  expect_fail "exercise: mvn -B clean package -pl tiffinbox-kitchen (no -am)" 600 \
      'Could not find artifact com.tiffinbox:tiffinbox-core:jar:1\.0\.0' \
      bash -c 'cd "$REPO/c3-unit02" && mvn -B clean package -pl tiffinbox-kitchen "-Dmaven.repo.local=$M2_U02"'
  # … and the answer is exactly one flag. run.sh honours an already-exported
  # JAVA_HOME and falls back to the pinned Homebrew path only when there is none,
  # so it runs against the JDK 25 this script validated at the top, anywhere.
  expect_ok "exercise solution: ./exercise/solution/run.sh (-pl tiffinbox-kitchen -am)" 900 \
      'BUILD SUCCESS' bash -c 'cd "$REPO/c3-unit02/exercise/solution" && ./run.sh'
  RS="$(sed -n '/Reactor Summary/,/^\[INFO\] -----/p' "$OUT" | grep -cE 'SUCCESS \[|FAILURE \[|SKIPPED' | tr -d ' ')"
  is "…the Reactor Summary has THREE rows (parent, core, kitchen — web is absent)" "$RS" "3"
  hasnt "…and tiffinbox-web really is not in it" 'TiffinBox Web \.'
  # the other half of "respects your JAVA_HOME": it also refuses a bad one out loud,
  # instead of overwriting it with a path that exists only on the author's Mac.
  expect_rc "…and it refuses a JAVA_HOME that is not a JDK 25, instead of silently ignoring it" 60 2 \
      'does not name a JDK|needs JDK 25' \
      bash -c 'cd "$REPO/c3-unit02/exercise/solution" && JAVA_HOME=/no/such/jdk ./run.sh'

  # ---- the selector table, proved by the summary and not by BUILD SUCCESS
  if [ -x "$REPO/c3-unit02/verify-selectors.sh" ]; then
    rm -rf "$M2_U02/com/tiffinbox"
    if expect_ok "./verify-selectors.sh (six selectors, six rows)" 1800 \
        '^<no selector> +modules=4 +exit=0 +BUILD SUCCESS' \
        bash -c 'cd "$REPO/c3-unit02" && ./verify-selectors.sh'; then :; fi
    has "…-pl tiffinbox-core            modules=0 exit=0 SUCCESS" '^-pl tiffinbox-core +modules=0 +exit=0 +BUILD SUCCESS'
    has "…-pl tiffinbox-kitchen         modules=0 exit=1 FAILURE" '^-pl tiffinbox-kitchen +modules=0 +exit=1 +BUILD FAILURE'
    has "…-pl tiffinbox-kitchen -am     modules=3 exit=0 SUCCESS" '^-pl tiffinbox-kitchen -am +modules=3 +exit=0 +BUILD SUCCESS'
    has "…-pl tiffinbox-core -amd       modules=3 exit=0 SUCCESS" '^-pl tiffinbox-core -amd +modules=3 +exit=0 +BUILD SUCCESS'
    has "…-pl tiffinbox-web -amd        modules=0 exit=1 FAILURE" '^-pl tiffinbox-web -amd +modules=0 +exit=1 +BUILD FAILURE'
  else
    skip "./verify-selectors.sh" "there is no executable verify-selectors.sh in c3-unit02/"
  fi

  # ---- break it on purpose: the cycle. The proof is the class-file count.
  backup "$REPO/c3-unit02/tiffinbox-core/pom.xml"
  find "$REPO/c3-unit02" -type d -name target -prune -exec rm -rf {} + 2>/dev/null
  cp "$REPO/c3-unit02/breaks/cycle/core-pom-with-cycle.xml" "$REPO/c3-unit02/tiffinbox-core/pom.xml"
  expect_fail "breaks/cycle: mvn -B clean package -> cyclic reference, exit 1" 600 \
      'The projects in the reactor contain a cyclic reference' \
      bash -c 'cd "$REPO/c3-unit02" && mvn -B clean package "-Dmaven.repo.local=$M2_U02"'
  has "…the loop is named: web -> kitchen -> core -> web" \
      'tiffinbox-web:1\.0\.0 --> com\.tiffinbox:tiffinbox-kitchen:1\.0\.0 --> com\.tiffinbox:tiffinbox-core:1\.0\.0 --> com\.tiffinbox:tiffinbox-web:1\.0\.0'
  N="$(find "$REPO/c3-unit02" -name '*.class' | wc -l | tr -d ' ')"
  is "…class files written: 0 — it died at 'Scanning for projects...'" "$N" "0"
  N="$(find "$REPO/c3-unit02" -type d -name target | wc -l | tr -d ' ')"
  is "…and no target/ directory exists anywhere in the tree" "$N" "0"
  restore_all

  # ---- break it on purpose: the stale sibling. Runs LAST — it installs.
  backup "$REPO/c3-unit02/tiffinbox-core/src/main/java/com/tiffinbox/core/MealType.java"
  if expect_ok "breaks/stale-sibling: mvn -B -q install (Friday: the whole reactor)" 900 '' \
      bash -c 'cd "$REPO/c3-unit02" && mvn -B -q install "-Dmaven.repo.local=$M2_U02"'; then
    sed -i '' 's/    VEG(60),/    VEG(999),/' \
        "$REPO/c3-unit02/tiffinbox-core/src/main/java/com/tiffinbox/core/MealType.java"
    grep -q 'VEG(999),' "$REPO/c3-unit02/tiffinbox-core/src/main/java/com/tiffinbox/core/MealType.java" \
      && ok "…Monday: sed edits core to VEG(999)" || bad "sed VEG(999)" "the edit did not apply"
    expect_ok "…mvn -B clean package -pl tiffinbox-kitchen -> green build, wrong input" 900 \
        'BUILD SUCCESS' bash -c 'cd "$REPO/c3-unit02" && mvn -B clean package -pl tiffinbox-kitchen "-Dmaven.repo.local=$M2_U02"'
    expect_ok "…dependency:build-classpath -pl tiffinbox-kitchen -Dmdep.outputFile=cp.txt" 600 '' \
        bash -c 'cd "$REPO/c3-unit02" && mvn -B -q dependency:build-classpath -pl tiffinbox-kitchen -Dmdep.outputFile=cp.txt "-Dmaven.repo.local=$M2_U02"'
    # -Dmdep.outputFile is relative to the module the goal ran in, so with
    # -pl tiffinbox-kitchen the file lands in tiffinbox-kitchen/, not here.
    CPTXT="$REPO/c3-unit02/tiffinbox-kitchen/cp.txt"
    [ -f "$CPTXT" ] || CPTXT="$REPO/c3-unit02/cp.txt"
    if grep -q 'com/tiffinbox/tiffinbox-core/1.0.0/tiffinbox-core-1.0.0.jar' "$CPTXT" 2>/dev/null; then
      ok "…the kitchen's compile classpath is the INSTALLED jar, not the sibling's target/classes"
    else
      cp "$CPTXT" "$OUT" 2>/dev/null
      bad "cp.txt" "expected the installed tiffinbox-core-1.0.0.jar on the classpath"
    fi
    expect_ok "…javap -c -p on that jar still says bipush 60" 120 'bipush +60' \
        bash -c 'cd "$REPO/c3-unit02" && "$JAVA_HOME/bin/javap" -c -p -cp "$M2_U02/com/tiffinbox/tiffinbox-core/1.0.0/tiffinbox-core-1.0.0.jar" com.tiffinbox.core.MealType'
    expect_ok "…add -am and the same command rebuilds the sibling from source" 900 'BUILD SUCCESS' \
        bash -c 'cd "$REPO/c3-unit02" && mvn -B clean package -pl tiffinbox-kitchen -am "-Dmaven.repo.local=$M2_U02"'
    expect_ok "…javap -c -p on target/classes now says sipush 999" 120 'sipush +999' \
        bash -c 'cd "$REPO/c3-unit02" && "$JAVA_HOME/bin/javap" -c -p -cp tiffinbox-core/target/classes com.tiffinbox.core.MealType | grep -E "bipush|sipush" | head -1'
  fi
  restore_all
  rm -f "$REPO/c3-unit02/cp.txt" "$REPO"/c3-unit02/*/cp.txt
  rm -rf "$M2_U02/com/tiffinbox"
fi

# ============================================================= c3-unit03 ====
if unit 03 "Dependencies: Scope, Transitivity, Conflict"; then
  backup "$REPO/c3-unit03/conflict/pom.xml"
  expect_ok "conflict: mvn -B dependency:tree -Dverbose" 900 'omitted for conflict with 2\.22\.2' \
      bash -c 'cd "$REPO/c3-unit03/conflict" && mvn -B "-Dmaven.repo.local=$M2" dependency:tree -Dverbose'
  N="$(countq 'omitted for conflict with 2\.22\.2')"
  is "…exactly two 'omitted for conflict with 2.22.2' lines" "$N" "2"

  cp "$REPO/c3-unit03/conflict/poms/pom-yaml-first.xml" "$REPO/c3-unit03/conflict/pom.xml"
  expect_ok "conflict: cp poms/pom-yaml-first.xml pom.xml && mvn -q clean compile && mvn -q exec:exec" 900 \
      'jackson-core *: *2\.13\.5' \
      bash -c 'cd "$REPO/c3-unit03/conflict" && mvn -B -q "-Dmaven.repo.local=$M2" clean compile && mvn -B -q "-Dmaven.repo.local=$M2" exec:exec'
  has "…nearest-wins: databind comes down to 2.13.5 too — the first declaration decides, not the highest version" \
      'databind *: *2\.13\.5'

  cp "$REPO/c3-unit03/conflict/poms/pom-jsr310-first.xml" "$REPO/c3-unit03/conflict/pom.xml"
  expect_ok "conflict: cp poms/pom-jsr310-first.xml pom.xml && mvn -q clean compile && mvn -q exec:exec" 900 \
      'jackson-core *: *2\.22\.2' \
      bash -c 'cd "$REPO/c3-unit03/conflict" && mvn -B -q "-Dmaven.repo.local=$M2" clean compile && mvn -B -q "-Dmaven.repo.local=$M2" exec:exec'
  H="$(md5of "$OUT")"
  is "…md5 of the program output (jsr310-first)" "$H" "7af6f75066689b3e6d64c64f707d8782"

  cp "$REPO/c3-unit03/conflict/poms/pom-excluded.xml" "$REPO/c3-unit03/conflict/pom.xml"
  expect_ok "conflict: cp poms/pom-excluded.xml pom.xml && mvn -q clean compile && mvn -q exec:exec (the fix)" 900 \
      'jackson-core *: *2\.22\.2' \
      bash -c 'cd "$REPO/c3-unit03/conflict" && mvn -B -q "-Dmaven.repo.local=$M2" clean compile && mvn -B -q "-Dmaven.repo.local=$M2" exec:exec'
  H="$(md5of "$OUT")"
  is "…md5 of the program output (excluded) — the same one" "$H" "7af6f75066689b3e6d64c64f707d8782"
  expect_ok "conflict: <exclusions> leaves zero 'omitted for conflict' lines" 600 '' \
      bash -c 'cd "$REPO/c3-unit03/conflict" && mvn -B "-Dmaven.repo.local=$M2" dependency:tree -Dverbose'
  N="$(countq 'omitted for conflict')"
  is "…zero, not two" "$N" "0"
  restore_all

  # ---- provided: green build, dead run
  expect_ok "provided-break: mvn -B clean package -> BUILD SUCCESS" 900 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit03/provided-break" && mvn -B "-Dmaven.repo.local=$M2" clean package'
  expect_fail "provided-break: java --enable-preview -jar target/c2-capstone-1.0.0.jar" 120 \
      'NoClassDefFoundError: com/fasterxml/jackson/databind/ObjectMapper' \
      bash -c 'cd "$REPO/c3-unit03/provided-break" && "$JAVA" "-D$TAG=u03" --enable-preview -jar target/c2-capstone-1.0.0.jar'

  # ---- the scope table, counted jar by jar
  expect_ok "scopes: for s in compile runtime test; do dependency:build-classpath -DincludeScope=\$s; done" 900 '' \
      bash -c 'cd "$REPO/c3-unit03/scopes" && for s in compile runtime test; do mvn -B -q "-Dmaven.repo.local=$M2" dependency:build-classpath "-DincludeScope=$s" "-Dmdep.outputFile=cp-$s.txt" || exit 1; done'
  for s in compile:4 runtime:4 test:14; do
    sc="${s%%:*}"; expn="${s##*:}"
    if [ -f "$REPO/c3-unit03/scopes/cp-$sc.txt" ]; then
      N="$(tr ':' '\n' <"$REPO/c3-unit03/scopes/cp-$sc.txt" | grep -c '\.jar' | tr -d ' ')"
      is "…includeScope=$sc -> $expn jars" "$N" "$expn"
    else
      bad "scopes cp-$sc.txt" "the file was not written"
    fi
  done

  # ---- exercise: green compile, dead run; then the BOM
  backup "$REPO/c3-unit03/exercise/pom.xml"
  expect_ok "exercise: mvn -B clean compile unedited -> BUILD SUCCESS" 900 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit03/exercise" && mvn -B "-Dmaven.repo.local=$M2" clean compile'
  expect_fail "exercise: mvn -B exec:exec -> NoClassDefFoundError StreamConstraintsException" 600 \
      'NoClassDefFoundError: com/fasterxml/jackson/core/exc/StreamConstraintsException' \
      bash -c 'cd "$REPO/c3-unit03/exercise" && mvn -B "-Dmaven.repo.local=$M2" exec:exec'
  cp "$REPO/c3-unit03/exercise/solution/pom.xml" "$REPO/c3-unit03/exercise/pom.xml"
  expect_ok "exercise solution: cp solution/pom.xml pom.xml && mvn -q clean compile && mvn -q exec:exec" 900 \
      'jackson-core *: *2\.22\.2' \
      bash -c 'cd "$REPO/c3-unit03/exercise" && mvn -B -q "-Dmaven.repo.local=$M2" clean compile && mvn -B -q "-Dmaven.repo.local=$M2" exec:exec'
  H="$(md5of "$OUT")"
  is "…md5 of the program output (solution) — the same one again" "$H" "7af6f75066689b3e6d64c64f707d8782"
  expect_ok "exercise solution: the tree now says 'version managed from', not 'omitted for conflict'" 600 \
      'version managed from' \
      bash -c 'cd "$REPO/c3-unit03/exercise" && mvn -B "-Dmaven.repo.local=$M2" dependency:tree -Dverbose'

  # ---- the README's "Receipts" line: mvn -o -B verify -> BUILD SUCCESS on all four
  # projects, on all four conflict/ POM states and on exercise/solution/. Each one a
  # pair, online into $M2 first and then -o in the same $M2 — see the header.
  # exercise/pom.xml is still the solution here; restore_all puts the starter back.
  offline_receipt "exercise/solution: mvn -o -B verify" 900 "$REPO/c3-unit03/exercise" "$M2"
  restore_all
  offline_receipt "exercise: mvn -o -B verify" 900 "$REPO/c3-unit03/exercise" "$M2"
  offline_receipt "scopes: mvn -o -B verify" 900 "$REPO/c3-unit03/scopes" "$M2"
  offline_receipt "provided-break: mvn -o -B verify" 900 "$REPO/c3-unit03/provided-break" "$M2"
  for P in pom-databind-first pom-yaml-first pom-jsr310-first pom-excluded; do
    cp "$REPO/c3-unit03/conflict/poms/$P.xml" "$REPO/c3-unit03/conflict/pom.xml"
    offline_receipt "conflict ($P.xml): mvn -o -B verify" 900 "$REPO/c3-unit03/conflict" "$M2"
  done
  restore_all
fi

# ============================================================= c3-unit04 ====
if unit 04 "Plugins: Bind Your Own Goal"; then
  # 1 — the banned dependency
  expect_fail "enforcer: mvn -B clean package -> BannedDependencies, exit 1" 900 \
      'BannedDependencies failed with message' \
      bash -c 'cd "$REPO/c3-unit04/enforcer" && mvn -B "-Dmaven.repo.local=$M2_U04" clean package'
  has "…the message is the team's own sentence, not the plugin's" 'snakeyaml 1\.31 is CVE-2022-1471'
  has "…and the path trace ends at the banned jar" 'org\.yaml:snakeyaml:jar:1\.31 <--- banned via the exclude/include list'

  # 2 — the over-ban: a bare version in an enforcer pattern is the range [1.31,)
  expect_fail "enforcer: mvn -B -f pom-upgraded.xml clean package -> still fails (the over-ban)" 900 \
      'org\.yaml:snakeyaml:jar:2\.5 <--- banned via the exclude/include list' \
      bash -c 'cd "$REPO/c3-unit04/enforcer" && mvn -B "-Dmaven.repo.local=$M2_U04" -f pom-upgraded.xml clean package'
  has "…against the upgraded YAML module 2.22.2" 'jackson-dataformat-yaml:jar:2\.22\.2'

  # 3 — the bracket, and the program that runs
  expect_ok "enforcer: mvn -B -f pom-pinned.xml clean package exec:exec" 900 'routes *: *2' \
      bash -c 'cd "$REPO/c3-unit04/enforcer" && mvn -B "-Dmaven.repo.local=$M2_U04" -f pom-pinned.xml clean package exec:exec'
  has "…North Block -> 14 stops" 'North Block -> 14 stops'
  has "…River Lane -> 9 stops"   'River Lane -> 9 stops'

  expect_fail "enforcer: mvn -B -f pom-pinned-unfixed.xml -> the bracket still catches the real thing" 900 \
      'org\.yaml:snakeyaml:jar:1\.31 <--- banned' \
      bash -c 'cd "$REPO/c3-unit04/enforcer" && mvn -B "-Dmaven.repo.local=$M2_U04" -f pom-pinned-unfixed.xml clean package'

  # 5 — green build, dead program: the old module against the new jar
  expect_ok "enforcer: mvn -B -f pom-excluded.xml clean package -> BUILD SUCCESS" 900 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit04/enforcer" && mvn -B "-Dmaven.repo.local=$M2_U04" -f pom-excluded.xml clean package'
  expect_fail "enforcer: …and then exec:exec dies, NoSuchMethodError ParserImpl.<init>" 600 \
      "NoSuchMethodError: .*org\.yaml\.snakeyaml\.parser\.ParserImpl\.<init>" \
      bash -c 'cd "$REPO/c3-unit04/enforcer" && mvn -B "-Dmaven.repo.local=$M2_U04" -f pom-excluded.xml exec:exec'

  # 6 — <level>WARN</level>: the same rule, demoted
  expect_ok "enforcer: mvn -B -f pom-warnonly.xml clean package -> exit 0" 900 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit04/enforcer" && mvn -B "-Dmaven.repo.local=$M2_U04" -f pom-warnonly.xml clean package'
  # <level>WARN</level> demotes the rule: the header line carries [WARNING] and the
  # message body is printed unprefixed, where the failing run prefixes every line [ERROR].
  has "…the same rule, demoted: [WARNING] Rule 0: … BannedDependencies warned with message:" \
      '^\[WARNING\] Rule 0: .*BannedDependencies warned with message:'
  has "…and it is the same sentence" 'snakeyaml 1\.31 is CVE-2022-1471'
  hasnt "…with not one [ERROR] line in the build" '^\[ERROR\]'

  # 4 — the annotation processor, installed so it can be resolved
  expect_ok "proc: mvn -B clean install (the processor must be installed to be resolvable)" 1200 \
      'BUILD SUCCESS' bash -c 'cd "$REPO/c3-unit04/proc" && mvn -B "-Dmaven.repo.local=$M2_U04" clean install'
  exists "…generated-sources/annotations/com/tiffinbox/MenuCatalog.java was written" \
      "$REPO/c3-unit04/proc/menu-app/target/generated-sources/annotations/com/tiffinbox/MenuCatalog.java"
  CL="$(cd "$REPO/c3-unit04/proc/menu-app/target/classes/com/tiffinbox" 2>/dev/null && ls *.class | sort | tr '\n' ' ')"
  is "…five class files, MenuCatalog.class among them" "$CL" \
     "GardenBowl.class GrilledWrap.class Kitchen.class MenuCatalog.class SoupOfTheDay.class "
  expect_ok "proc/menu-app: mvn -B exec:exec -> catalog size : 3" 600 'catalog size *: *3' \
      bash -c 'cd "$REPO/c3-unit04/proc/menu-app" && mvn -B "-Dmaven.repo.local=$M2_U04" exec:exec'
  has "…Garden Bowl @ 120"     'Garden Bowl @ 120'
  has "…Grilled Wrap @ 150"    'Grilled Wrap @ 150'
  has "…Soup of the Day @ 100" 'Soup of the Day @ 100'

  # the silent failure: BUILD SUCCESS, zero warnings, and the processor never ran.
  # Assert the ARTIFACT — the generated-file count and the class list — never the
  # word SUCCESS, because SUCCESS is exactly what a silent failure prints.
  expect_ok "proc/menu-app: mvn -B -f pom-classpath.xml clean package (exit 0, zero warnings)" 900 '' \
      bash -c 'cd "$REPO/c3-unit04/proc/menu-app" && mvn -B "-Dmaven.repo.local=$M2_U04" -f pom-classpath.xml clean package'
  hasnt "…zero warnings: nothing tells you the processor is missing" '^\[WARNING\].*[Pp]rocessor'
  N=0
  [ -d "$REPO/c3-unit04/proc/menu-app/target/generated-sources/annotations" ] && \
    N="$(find "$REPO/c3-unit04/proc/menu-app/target/generated-sources/annotations" -name '*.java' | wc -l | tr -d ' ')"
  is "…gen files: 0 — the processor never ran" "$N" "0"
  CL="$(cd "$REPO/c3-unit04/proc/menu-app/target/classes/com/tiffinbox" 2>/dev/null && ls *.class | sort | tr '\n' ' ')"
  is "…four class files, not five — no MenuCatalog.class" "$CL" \
     "GardenBowl.class GrilledWrap.class Kitchen.class SoupOfTheDay.class "
  expect_ok "proc/menu-app: mvn -B -f pom-classpath.xml exec:exec -> 'no MenuCatalog was generated'" 600 \
      'catalog size *: *no MenuCatalog was generated' \
      bash -c 'cd "$REPO/c3-unit04/proc/menu-app" && mvn -B "-Dmaven.repo.local=$M2_U04" -f pom-classpath.xml exec:exec'

  # 5 — the goal that is not late but absent. Count the goal lines.
  expect_ok "wrongphase: mvn -B clean package (the right binding)" 900 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit04/wrongphase" && mvn -B "-Dmaven.repo.local=$M2_U04" clean package'
  N="$(countq '^\[INFO\] --- ')"
  is "…eight goal lines" "$N" "8"
  N="$(ls "$REPO/c3-unit04/wrongphase/target/lib" 2>/dev/null | wc -l | tr -d ' ')"
  is "…and target/lib holds four jars" "$N" "4"
  expect_ok "wrongphase: mvn -B -f pom-wrongphase.xml clean package (copy-libs bound to install)" 900 \
      'BUILD SUCCESS' bash -c 'cd "$REPO/c3-unit04/wrongphase" && mvn -B "-Dmaven.repo.local=$M2_U04" -f pom-wrongphase.xml clean package'
  N="$(countq '^\[INFO\] --- ')"
  is "…SEVEN goal lines, not eight — the goal is absent, not late" "$N" "7"
  absent "…ls target/lib: No such file or directory" "$REPO/c3-unit04/wrongphase/target/lib"
  expect_ok "wrongphase: …and the manifest still points at the lib/ nobody wrote" 60 \
      'Class-Path: lib/h2-2\.5\.250\.jar' \
      bash -c 'cd "$REPO/c3-unit04/wrongphase" && unzip -p target/c2-capstone-1.0.0.jar META-INF/MANIFEST.MF'

  # ---- the README's "Offline receipt" table, four rows, each proved as a pair:
  # online into $M2_U04 first, then the same command with -o in the same repository.
  offline_receipt "enforcer (pom-pinned.xml): mvn -o -B verify" 900 \
      "$REPO/c3-unit04/enforcer" "$M2_U04" -f pom-pinned.xml
  offline_receipt "proc (reactor): mvn -o -B verify" 1200 "$REPO/c3-unit04/proc" "$M2_U04"
  offline_receipt "wrongphase (pom.xml): mvn -o -B verify" 900 "$REPO/c3-unit04/wrongphase" "$M2_U04"
  offline_receipt "wrongphase (pom-wrongphase.xml): mvn -o -B verify" 900 \
      "$REPO/c3-unit04/wrongphase" "$M2_U04" -f pom-wrongphase.xml

  # ---- exercise: the same silent failure, shipped broken
  backup "$REPO/c3-unit04/exercise/pom.xml"
  expect_ok "exercise: mvn -B clean package unedited -> exit 0, seven goal lines" 900 '' \
      bash -c 'cd "$REPO/c3-unit04/exercise" && mvn -B "-Dmaven.repo.local=$M2_U04" clean package'
  N="$(countq '^\[INFO\] --- ')"
  is "…seven goal lines" "$N" "7"
  absent "…ls target/lib: No such file or directory" "$REPO/c3-unit04/exercise/target/lib"
  expect_fail "exercise: java --enable-preview -jar target/c2-capstone-1.0.0.jar -> NoClassDefFoundError" 120 \
      'NoClassDefFoundError: com/fasterxml/jackson/databind/ObjectMapper' \
      bash -c 'cd "$REPO/c3-unit04/exercise" && "$JAVA" "-D$TAG=u04" --enable-preview -Djava.util.logging.config.file=logging.properties -jar target/c2-capstone-1.0.0.jar'
  cp "$REPO/c3-unit04/exercise/solution/pom.xml" "$REPO/c3-unit04/exercise/pom.xml"
  expect_ok "exercise solution: cp solution/pom.xml pom.xml && mvn -B clean package" 900 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit04/exercise" && mvn -B "-Dmaven.repo.local=$M2_U04" clean package'
  N="$(countq '^\[INFO\] --- ')"
  is "…EIGHT goal lines" "$N" "8"
  LIBS="$(cd "$REPO/c3-unit04/exercise/target/lib" 2>/dev/null && ls | sort | tr '\n' ' ')"
  is "…ls target/lib -> the four jars" "$LIBS" \
     "h2-2.5.250.jar jackson-annotations-2.22.jar jackson-core-2.22.2.jar jackson-databind-2.22.2.jar "
  if port_busy "$PORT"; then
    skip "exercise solution: the server starts" "port $PORT is already in use"
  else
    ( cd "$REPO/c3-unit04/exercise" && "$JAVA" "-D$TAG=u04srv" --enable-preview \
        -Djava.util.logging.config.file=logging.properties \
        -jar target/c2-capstone-1.0.0.jar "$PORT" ) >"$WORK/u04.log" 2>&1 &
    S4=$!
    if wait_port_up "$PORT"; then
      cp "$WORK/u04.log" "$OUT"
      has "exercise solution: the server starts — orders cooked: 120" 'orders cooked: +120'
      has "…kitchen value: 24300" 'kitchen value: +24300'
      has "…TiffinBox listening on http://127.0.0.1:$PORT" "TiffinBox listening on http://127.0.0.1:$PORT"
      curl -s -m 10 -X POST "http://127.0.0.1:$PORT/shutdown" >/dev/null 2>&1
    else
      cp "$WORK/u04.log" "$OUT"; bad "exercise solution: java -jar …" "the server never came up"
    fi
    for _ in $(seq 1 60); do kill -0 "$S4" 2>/dev/null || break; sleep 0.25; done
    kill -9 "$S4" >/dev/null 2>&1; wait "$S4" 2>/dev/null
    pkill -9 -f "$TAG=u04srv" >/dev/null 2>&1
    if wait_port_free "$PORT"; then ok "port $PORT free again after the exercise server"
    else bad "port $PORT" "still in LISTEN after POST /shutdown"; fi
  fi
  restore_all
fi

# ============================================================= c3-unit05 ====
if unit 05 "Multi-Module TiffinBox (the project is ../c3-tiffinbox)"; then
  # the README's claim that the answer is the shipped file, checked byte for byte
  if cmp -s "$REPO/c3-unit05/exercise/solution/pom.xml" "$REPO/c3-tiffinbox/tiffinbox-web/pom.xml"; then
    ok "exercise/solution/pom.xml is byte-identical to ../c3-tiffinbox/tiffinbox-web/pom.xml"
  else
    bad "exercise/solution/pom.xml" "it is NOT byte-identical to ../c3-tiffinbox/tiffinbox-web/pom.xml"
  fi

  backup "$REPO/c3-unit05/exercise/c3-tiffinbox/tiffinbox-web/pom.xml"
  expect_ok "exercise: cd c3-tiffinbox && mvn -B clean package -> green, with no warning of any kind" 1200 \
      'BUILD SUCCESS' bash -c 'cd "$REPO/c3-unit05/exercise/c3-tiffinbox" && mvn -B "-Dmaven.repo.local=$M2" clean package'
  hasnt "…Maven says nothing about the version the child overrode" '\[WARNING\].*jackson-databind'
  expect_ok "exercise: mvn -B dependency:tree -Dincludes=com.fasterxml.jackson.core -> 2.13.5" 600 \
      'jackson-databind:jar:2\.13\.5:compile' \
      bash -c 'cd "$REPO/c3-unit05/exercise/c3-tiffinbox" && mvn -B "-Dmaven.repo.local=$M2" dependency:tree -Dincludes=com.fasterxml.jackson.core'
  LIBS="$(cd "$REPO/c3-unit05/exercise/c3-tiffinbox/tiffinbox-web/target/lib" 2>/dev/null && ls | sort | tr '\n' ' ')"
  is "…ls tiffinbox-web/target/lib -> three 2.13.5 jars shipped" "$LIBS" \
     "h2-2.5.250.jar jackson-annotations-2.13.5.jar jackson-core-2.13.5.jar jackson-databind-2.13.5.jar tiffinbox-core-1.0.0.jar "

  cp "$REPO/c3-unit05/exercise/solution/pom.xml" "$REPO/c3-unit05/exercise/c3-tiffinbox/tiffinbox-web/pom.xml"
  expect_ok "exercise solution: cp ../solution/pom.xml tiffinbox-web/pom.xml && mvn -B clean package" 900 \
      'BUILD SUCCESS' bash -c 'cd "$REPO/c3-unit05/exercise/c3-tiffinbox" && mvn -B "-Dmaven.repo.local=$M2" clean package'
  expect_ok "exercise solution: the tree now reads 2.22.2" 600 'jackson-databind:jar:2\.22\.2:compile' \
      bash -c 'cd "$REPO/c3-unit05/exercise/c3-tiffinbox" && mvn -B "-Dmaven.repo.local=$M2" dependency:tree -Dincludes=com.fasterxml.jackson.core'
  has "…and jackson-annotations is 2.22, not 2.22.2 — that module skipped the patch" \
      'jackson-annotations:jar:2\.22:compile'
  LIBS="$(cd "$REPO/c3-unit05/exercise/c3-tiffinbox/tiffinbox-web/target/lib" 2>/dev/null && ls | sort | tr '\n' ' ')"
  is "…ls tiffinbox-web/target/lib -> the 2.22.2 jars" "$LIBS" \
     "h2-2.5.250.jar jackson-annotations-2.22.jar jackson-core-2.22.2.jar jackson-databind-2.22.2.jar tiffinbox-core-1.0.0.jar "
  restore_all
fi

# ============================================================= c3-unit06 ====
if unit 06 "Settings, the Repository, and Why Maven 4 Is Still Not Here"; then
  # 1 — settings you never wrote
  if [ -f "$HOME/.m2/settings.xml" ]; then
    skip "ls ~/.m2/settings.xml -> No such file or directory" "this machine has one, so the README's premise does not hold here"
  else
    ok "ls ~/.m2/settings.xml -> No such file or directory (the defaults are built in)"
  fi
  expect_ok "mvn -B -q help:effective-settings -Doutput=es.xml" 900 '' \
      bash -c 'cd "$REPO/c3-unit06" && mvn -B -q "-Dmaven.repo.local=$M2_U06" help:effective-settings -Doutput=es.xml'
  if [ -f "$REPO/c3-unit06/es.xml" ]; then
    cp "$REPO/c3-unit06/es.xml" "$OUT"
    has "…<localRepository> is in there (here it is the scratch repo, not ~/.m2)" '<localRepository>'
    has "…<interactiveMode>false</interactiveMode> — -B is already the default under a pipe" '<interactiveMode>false</interactiveMode>'
    has "…the mirror you never configured: maven-default-http-blocker" '<id>maven-default-http-blocker</id>'
    has "…sending external:http:\* to http://0.0.0.0/" '<mirrorOf>external:http:\*</mirrorOf>'
    has "…<blocked>true</blocked>" '<blocked>true</blocked>'
    has "…<pluginGroups> holds org.apache.maven.plugins" '<pluginGroup>org.apache.maven.plugins</pluginGroup>'
    has "…and org.codehaus.mojo" '<pluginGroup>org.codehaus.mojo</pluginGroup>'
  else
    bad "help:effective-settings -Doutput=es.xml" "es.xml was not written"
  fi

  # 2 — install vs deploy
  rm -rf "$M2_U06/com/tiffinbox"
  expect_ok 'mvn -B "-Dmaven.repo.local=$M2" clean install' 1200 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit06" && mvn -B "-Dmaven.repo.local=$M2_U06" clean install'
  N="$(countq '^\[INFO\] Installing ')"
  is "…five Installing lines (parent pom, core jar+pom, web jar+pom)" "$N" "5"
  N="$(find "$M2_U06/com/tiffinbox" -type f 2>/dev/null | wc -l | tr -d ' ')"
  is "…11 files under the local repository" "$N" "11"
  N="$(find "$M2_U06/com/tiffinbox" -type f \( -name '*.md5' -o -name '*.sha1' \) 2>/dev/null | wc -l | tr -d ' ')"
  is "…and NOT ONE checksum among them — install does not write any" "$N" "0"

  expect_ok 'mvn -B "-Dmaven.repo.local=$M2" clean deploy (to file://…/target/team-repo)' 1200 \
      'BUILD SUCCESS' bash -c 'cd "$REPO/c3-unit06" && mvn -B "-Dmaven.repo.local=$M2_U06" clean deploy'
  N="$(countq 'Uploaded to tiffinbox-team:')"
  is "…eight 'Uploaded to tiffinbox-team:' lines" "$N" "8"
  N="$(find "$REPO/c3-unit06/target/team-repo" -type f 2>/dev/null | wc -l | tr -d ' ')"
  is "…24 files in the team repository, not 11" "$N" "24"
  N="$(find "$REPO/c3-unit06/target/team-repo" -type f \( -name '*.md5' -o -name '*.sha1' \) 2>/dev/null | wc -l | tr -d ' ')"
  is "…16 of them are checksums — a .md5 and a .sha1 beside every artifact" "$N" "16"
  MD="$REPO/c3-unit06/target/team-repo/com/tiffinbox/tiffinbox-core/maven-metadata.xml"
  if [ -f "$MD" ]; then
    cp "$MD" "$OUT"; has "…a real maven-metadata.xml carrying <release>1.0.0</release>" '<release>1\.0\.0</release>'
  else bad "maven-metadata.xml" "missing: $MD"; fi
  JARP="$REPO/c3-unit06/target/team-repo/com/tiffinbox/tiffinbox-core/1.0.0/tiffinbox-core-1.0.0.jar"
  if [ -f "$JARP" ] && [ -f "$JARP.sha1" ]; then
    S="$(shasum "$JARP" | cut -d' ' -f1)"
    is "shasum tiffinbox-core-1.0.0.jar (the reproducible jar the README quotes)" "$S" \
       "1408ec152a3e3f418d725f504fbe43f6ea2d913a"
    is "…and it matches the .sha1 the deploy wrote beside it" "$S" "$(cat "$JARP.sha1" | tr -d ' \n')"
  else bad "tiffinbox-core-1.0.0.jar(.sha1)" "missing under target/team-repo"; fi

  # 3 — the mirror and the team repository, proved by repository id
  rm -rf "$M2_CONSUMER"
  expect_ok "consumer: mvn -B -s ../settings.xml -Dmaven.repo.local=/tmp/m2consumer clean package" 1800 \
      'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit06" && TEAM_REPO="$PWD/target/team-repo" && export TEAM_REPO && cd consumer && mvn -B -s ../settings.xml "-Dmaven.repo.local=$M2_CONSUMER" clean package'
  NT="$(countq 'Downloading from tiffinbox-team: file:')"
  is "…three 'Downloading from tiffinbox-team: file:///…' lines" "$NT" "3"
  NC="$(countq 'Downloading from central-mirror:')"
  if [ "${NC:-0}" -gt 100 ]; then ok "…and $NC 'Downloading from central-mirror:' lines (the README measured 174)"
  else bad "Downloading from central-mirror:" "expected a cold repository to pull >100, got $NC"; fi
  RR="$M2_CONSUMER/com/tiffinbox/tiffinbox-core/1.0.0/_remote.repositories"
  if [ -f "$RR" ]; then
    cp "$RR" "$OUT"; has "…_remote.repositories says tiffinbox-core-1.0.0.jar>tiffinbox-team=" 'tiffinbox-core-1\.0\.0\.jar>tiffinbox-team='
  else bad "_remote.repositories" "missing: $RR"; fi

  # the consumer half of the README's offline receipt, run here because the
  # reproducible-build loops below `clean` away target/team-repo.
  TEAM_REPO="$REPO/c3-unit06/target/team-repo"; export TEAM_REPO
  offline_receipt "consumer: mvn -o -B -s ../settings.xml verify" 1800 \
      "$REPO/c3-unit06/consumer" "$M2_CONSUMER" -s ../settings.xml

  # 4 — reproducible builds, byte-compared
  RUNS=3; [ "$SKIP_SLOW" = "1" ] && RUNS=2
  HASHES=""
  i=0; while [ "$i" -lt "$RUNS" ]; do
    i=$((i+1))
    timed 900 bash -c 'cd "$REPO/c3-unit06" && mvn -B -q "-Dmaven.repo.local=$M2_U06" "-Dproject.build.outputTimestamp=" clean package'
    [ "$RC" -eq 0 ] || break
    HASHES="$HASHES $(md5of "$REPO/c3-unit06/tiffinbox-core/target/tiffinbox-core-1.0.0.jar")"
  done
  N="$(printf '%s\n' $HASHES | sort -u | wc -l | tr -d ' ')"
  is "-Dproject.build.outputTimestamp= -> $RUNS builds, $RUNS different hashes (the wall clock is in the zip)" "$N" "$RUNS"
  HASHES=""
  i=0; while [ "$i" -lt "$RUNS" ]; do
    i=$((i+1))
    timed 900 bash -c 'cd "$REPO/c3-unit06" && mvn -B -q "-Dmaven.repo.local=$M2_U06" clean package'
    [ "$RC" -eq 0 ] || break
    HASHES="$HASHES $(md5of "$REPO/c3-unit06/tiffinbox-core/target/tiffinbox-core-1.0.0.jar")"
  done
  N="$(printf '%s\n' $HASHES | sort -u | wc -l | tr -d ' ')"
  is "…let the parent's <project.build.outputTimestamp> apply -> ONE hash, $RUNS times" "$N" "1"
  is "…and it is the one the README quotes" "$(printf '%s\n' $HASHES | sort -u | tr -d ' \n')" \
     "03a523276277fa6efd292152936a41d9"
  is "…the web jar's hash too" "$(md5of "$REPO/c3-unit06/tiffinbox-web/target/tiffinbox-web-1.0.0.jar")" \
     "4e40f21e53f95108408bc7f173c1ea69"
  timed 120 bash -c 'cd "$REPO/c3-unit06" && unzip -l tiffinbox-core/target/tiffinbox-core-1.0.0.jar'
  N="$(grep -cE '[0-9]{2}-[0-9]{2}-[0-9]{4} [0-9]{2}:[0-9]{2}' "$OUT" | tr -d ' ')"
  NZ="$(grep -cE '[0-9]{2}-[0-9]{2}-[0-9]{4} 00:00' "$OUT" | tr -d ' ')"
  is "unzip -l -> every entry stamped 00:00 ($NZ of $N)" "$NZ" "$N"
  expect_ok "mvn …:maven-artifact-plugin:3.6.0:check-buildplan -> No known issue" 900 \
      'No known issue in [0-9]+ plugins' \
      bash -c 'cd "$REPO/c3-unit06" && mvn -B "-Dmaven.repo.local=$M2_U06" org.apache.maven.plugins:maven-artifact-plugin:3.6.0:check-buildplan'

  # 5 — run it
  expect_ok "java -cp 'web.jar:core.jar' com.tiffinbox.web.Dashboard" 120 'Meera -> 3600' \
      bash -c 'cd "$REPO/c3-unit06" && "$JAVA" "-D$TAG=u06" -cp "tiffinbox-web/target/tiffinbox-web-1.0.0.jar:tiffinbox-core/target/tiffinbox-core-1.0.0.jar" com.tiffinbox.web.Dashboard'
  has "…Ravi -> 5400"  'Ravi -> 5400'
  has "…Priya -> 2250" 'Priya -> 2250'
  is "…md5 of those three lines" "$(md5of "$OUT")" "763da9925197453b5e61f11003d941f3"

  # the reactor half of the README's offline receipt, proved as a pair — see the header
  offline_receipt "reactor: mvn -o -B verify" 900 "$REPO/c3-unit06" "$M2_U06"

  # ---- exercise: three builds, one jar
  backup "$REPO/c3-unit06/exercise/pom.xml"
  HASHES=""
  i=0; while [ "$i" -lt "$RUNS" ]; do
    i=$((i+1))
    timed 900 bash -c 'cd "$REPO/c3-unit06/exercise" && mvn -B -q "-Dmaven.repo.local=$M2_U06" clean package'
    [ "$RC" -eq 0 ] || break
    HASHES="$HASHES $(md5of "$REPO/c3-unit06/exercise/tiffinbox-kitchen/target/tiffinbox-kitchen-1.0.0.jar")"
  done
  N="$(printf '%s\n' $HASHES | sort -u | wc -l | tr -d ' ')"
  is "exercise: $RUNS builds of the same source -> $RUNS different hashes" "$N" "$RUNS"
  cp "$REPO/c3-unit06/exercise/solution/pom.xml" "$REPO/c3-unit06/exercise/pom.xml"
  HASHES=""
  i=0; while [ "$i" -lt "$RUNS" ]; do
    i=$((i+1))
    timed 900 bash -c 'cd "$REPO/c3-unit06/exercise" && mvn -B -q "-Dmaven.repo.local=$M2_U06" clean package'
    [ "$RC" -eq 0 ] || break
    HASHES="$HASHES $(md5of "$REPO/c3-unit06/exercise/tiffinbox-kitchen/target/tiffinbox-kitchen-1.0.0.jar")"
  done
  N="$(printf '%s\n' $HASHES | sort -u | wc -l | tr -d ' ')"
  is "exercise solution: cp solution/pom.xml pom.xml -> ONE hash, $RUNS times" "$N" "1"
  is "…and it is the one the exercise README quotes" "$(printf '%s\n' $HASHES | sort -u | tr -d ' \n')" \
     "ec6afdd1d1188b7b00adb4465895827d"
  timed 120 bash -c 'cd "$REPO/c3-unit06/exercise" && unzip -l tiffinbox-kitchen/target/tiffinbox-kitchen-1.0.0.jar'
  N="$(grep -cE '[0-9]{2}-[0-9]{2}-[0-9]{4} [0-9]{2}:[0-9]{2}' "$OUT" | tr -d ' ')"
  NZ="$(grep -cE '[0-9]{2}-[0-9]{2}-[0-9]{4} 00:00' "$OUT" | tr -d ' ')"
  is "…unzip -l: every entry stamped 00:00 ($NZ of $N)" "$NZ" "$N"
  restore_all
  # the exercise half of the README's offline receipt (exercise/README.md line 17),
  # in the shipped starter state that restore_all just put back.
  offline_receipt "exercise: mvn -o -B verify" 900 "$REPO/c3-unit06/exercise" "$M2_U06"
  rm -rf "$M2_U06/com/tiffinbox"
fi

# =============================================================== teardown ===
cd "$REPO"
printf '\n%steardown%s\n' "$DIM" "$OFF"
absent "~/.m2/repository/com/tiffinbox does not exist — nothing of ours reached your real repository" \
       "$HOME/.m2/repository/com/tiffinbox"
if [ -f "$HOME/.m2/settings.xml" ]; then
  printf '  %sNOTE%s  ~/.m2/settings.xml exists and was not touched by this script\n' "$YLW" "$OFF"
else
  absent "~/.m2/settings.xml was not created" "$HOME/.m2/settings.xml"
fi
# Scoped to the folders this script touches: a c3-* folder it does not cover is
# somebody else's work in progress, not this run's mess — and neither is an edit
# that was already in the tree when the run started, which is why this compares the
# fingerprint with the one taken at the top rather than with git HEAD.
FP_AFTER="$(tree_fingerprint)"
if [ "$FP_AFTER" = "$FP_BEFORE" ]; then
  ok "the c3-* working tree is as this run found it (every pom swap and sed put back)"
else
  bad "the c3-* working tree changed under the run" \
      "fingerprint $FP_BEFORE -> $FP_AFTER; git status: $(cd "$REPO" && git status --porcelain -- 'c3-unit0[1-6]' c3-tiffinbox 2>/dev/null | head -5 | tr '\n' ' ')"
fi

# ------------------------------------------------------------------ report ---
printf '\n---------------------------------------------\n'
# Units that have landed since this script was last extended: say so instead of
# quietly passing, so nobody mistakes "not checked" for "checked and green".
if [ ${#UNITS[@]} -eq 0 ]; then
  UNCHECKED=""
  for d in "$REPO"/c3-*/; do
    n="$(basename "$d")"
    case "$n" in
      c3-unit0[1-6]|c3-tiffinbox) continue ;;
      *) UNCHECKED="$UNCHECKED $n" ;;
    esac
  done
  [ -n "$UNCHECKED" ] && printf '%snot covered by this script yet:%s%s\n' "$YLW" "$OFF" "$UNCHECKED"
fi
printf '%sPASS %d%s   %sFAIL %d%s   %sSKIP %d%s\n' "$GRN" "$PASS" "$OFF" "$RED" "$FAIL" "$OFF" "$YLW" "$SKIP" "$OFF"
if [ "$FAIL" -gt 0 ]; then
  printf 'failed:\n'
  for l in "${FAILED_LABELS[@]}"; do printf '  - %s\n' "$l"; done
  exit 1
fi
# A filtered run that ran nothing at all is not a pass either.
if [ ${#UNITS[@]} -ne 0 ] && [ $((PASS+FAIL+SKIP)) -eq 0 ]; then
  printf '%sno checks ran for:%s %s\n' "$YLW" "$OFF" "${UNITS[*]}" >&2
  exit 2
fi
printf 'all green.\n'
exit 0
