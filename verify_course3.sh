#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# verify_course3.sh — runs every command the Build & Test Like a Pro (`c3-*`)
# READMEs give a viewer, and says PASS/FAIL for each one.
#
#   ./verify_course3.sh                 # every c3-* folder that exists
#   ./verify_course3.sh 03 06           # only those units
#   ./verify_course3.sh 08 10           # the Gradle ones
#   ./verify_course3.sh tiffinbox       # only c3-tiffinbox (that is unit 05's code)
#   SKIP_SLOW=1 ./verify_course3.sh     # skip the repeated-build hash loops
#   KEEP_M2=1 ./verify_course3.sh       # keep the scratch repositories AND the four
#                                       #   .gradle-home/ directories (warm re-runs;
#                                       #   without it every run re-downloads 9.7.1)
#   OLD_GRADLE=/path/to/gradle-8.5/bin/gradle ./verify_course3.sh
#                                       # unit 10's drift beat needs a SECOND Gradle
#                                       #   distribution, which only you can supply;
#                                       #   without it those checks SKIP out loud
#
# It walks only the folders that are actually present, so it stays green as new
# units land. Every command is time-boxed and its JVM killed; the server port is
# asserted free before use and after; every file the READMEs generate is removed.
#
# Requires JDK **25** and Apache Maven 3.9.x. Gradle is NOT a requirement: units
# 07-10 fetch 9.7.1 through each project's own committed wrapper.
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
#   3. **The Gradle units run the committed wrapper, never a `gradle` on your
#      PATH, and never write to `~/.gradle`.** `/opt/homebrew/bin/gradle` on this
#      Mac is also 9.7.1, so a version string proves nothing on its own; every
#      Gradle command below goes through the project's `./gradlew` with
#      `GRADLE_USER_HOME="$PWD/.gradle-home"` — the export at the top of all four
#      Gradle READMEs — and the check that it really was the wrapper is that the
#      distribution it ran came out of that directory. `~/.gradle`'s entry count
#      and listing hash are taken before the run and asserted unchanged at the
#      end, and every group ends with `./gradlew --stop`, verified by pid: the
#      daemon outlives the terminal that started it and the time-box cannot reach
#      it, because it is not in the child's process group.
#
#   4. **A state word is built into before it is named.** `UP-TO-DATE`,
#      `FROM-CACHE`, `NO-SOURCE` and `N executed / N up-to-date` are statements
#      about daemon and build-cache state, so units 08 and 10 wipe the build
#      cache, `rm -rf build`, or pin `--no-build-cache` / `--offline` exactly
#      where the unit pins them, *before* asserting the word. Two beats here fail
#      with **exit 0** — unit 08's undeclared input and unit 04's annotation
#      processor — and for both the assertion is the artifact (the program's own
#      output against `wc -l` of its input; the generated-file count), never the
#      word SUCCESS, which is precisely what those failures print.
#
# The first run downloads Maven plugins and H2/Jackson/SnakeYAML/JUnit into cold
# scratch repositories, and the four Gradle wrappers each fetch the 9.7.1
# distribution (~130 MB) into their own `.gradle-home`, so it needs a network and
# takes a while. $M2_REPO lives outside the repository and is kept between runs;
# the scratch repositories and Gradle homes inside a unit folder are deleted at
# the end unless KEEP_M2=1, so the working tree is as the run found it.
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
  # Gradle daemons are not in any child's process group, so the time-box never sees
  # them. Only ones started under THIS run's Gradle homes are touched; a daemon
  # somebody else started from ~/.gradle is none of our business.
  local g
  for g in "$GH07" "$GH08" "$GH09" "$GH10" "$GH10X" "$REPO/c3-unit10/.gh-old" "$REPO/c3-unit10/.gh-fresh"; do
    [ -n "${g:-}" ] && pkill -9 -f "$g/wrapper/dists" >/dev/null 2>&1
  done
  restore_all
  # target/ and build/ everywhere under Course 3 (incl. c3-unit06/target/team-repo)
  local d
  for d in "$REPO"/c3-unit0[1-9] "$REPO"/c3-unit10 "$REPO"/c3-tiffinbox; do
    [ -d "$d" ] || continue
    find "$d" -type d -name target -prune -exec rm -rf {} + 2>/dev/null
    find "$d" -type d -name build  -prune -exec rm -rf {} + 2>/dev/null
    find "$d" -type d -name '.gradle' -prune -exec rm -rf {} + 2>/dev/null
    find "$d" -type d -name 'generated-sources' -prune -exec rm -rf {} + 2>/dev/null
  done
  rm -f  "$REPO"/c3-unit01/effective-pom.xml 2>/dev/null
  rm -f  "$REPO"/c3-unit03/scopes/cp-*.txt 2>/dev/null
  rm -f  "$REPO"/c3-unit02/cp.txt "$REPO"/c3-unit02/*/cp.txt 2>/dev/null
  rm -f  "$REPO"/c3-unit06/es.xml 2>/dev/null
  # the throw-away Gradle homes unit 10 uses to prove the sha256 pin bites
  rm -rf "$GH10X" "$REPO/c3-unit10/.gh-fresh" "$REPO/c3-unit10/.gh-old" 2>/dev/null
  if [ "$KEEP_M2" != "1" ]; then
    rm -rf "$M2_U02" "$M2_U04" "$M2_U06" "$M2_CONSUMER" 2>/dev/null
    rm -rf "$M2_U07" "$M2_U09C" "$M2_U10" 2>/dev/null
    rm -rf "$GH07" "$GH08" "$GH09" "$GH10" 2>/dev/null
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

# ---------------------------------------------------------- the Gradle units ---
# Units 07-10 are the Gradle section, and they need four things the Maven sections did
# not. Each one is a rule this script keeps, not a preference:
#
#   1. **The committed wrapper, and only it.** `/opt/homebrew/bin/gradle` on this Mac is
#      also 9.7.1, so `Gradle 9.7.1` on its own proves nothing about which binary ran.
#      Every Gradle command below goes through the project's own `./gradlew`, and
#      `wrapper_asserts` additionally checks that the distribution it ran came out of
#      *this project's* GRADLE_USER_HOME — a path the global `gradle` never touches.
#
#   2. **GRADLE_USER_HOME inside the unit, never `~/.gradle`.** Every README in this
#      section opens with `export GRADLE_USER_HOME="$PWD/.gradle-home"`, and that is what
#      this script exports too: the 9.7.1 distribution, the dependency cache, the build
#      cache and the daemon registry all land beside the build. `~/.gradle`'s entry count
#      and listing hash are taken before the run and asserted unchanged at the end.
#
#   3. **Build into the state before naming it.** `UP-TO-DATE`, `FROM-CACHE`, `NO-SOURCE`
#      and the `N executed / N up-to-date` counts are statements about daemon and
#      build-cache state. An assertion that just runs the command and hopes is worthless,
#      so each one here first puts the tree into the state it is about to describe — a
#      `rm -rf build` for a first-run capture, a build-cache wipe before the `FROM-CACHE`
#      beat, `--no-build-cache`/`--offline` wherever the unit pins them.
#
#   4. **The checksum is verified on DOWNLOAD, not on every run.** Measured, in unit 10: a
#      warm Gradle home runs happily with a deliberately wrong `distributionSha256Sum`.
#      So the assertion that the pin bites uses a Gradle home that has never held 9.7.1 —
#      and the assertion that it does *not* bite on a warm one is written down as well,
#      because it is the reason the first assertion needs a fresh home to mean anything.
GRADLE_VERSION="9.7.1"
GRADLE_DIST_SHA256="acd53f1edaf02f1a8ff99879f8a34b302661a057d9b063ae9e35b552f804d20a"
GRADLE_WRAPPER_JAR_SHA256="7a9ce74cff467ca1bf60a4fcd9f05185acceda4d0f382434d393e17864262c5d"
# gradlew.bat is the third file of the wrapper triplet and the one no assertion used to name.
# All four units ship the same bytes; this is their sha256.
GRADLEW_BAT_SHA256="d539676c48b596afda64c963ec8f7ee56c7b3fe7e3b81d1dbe2d1a1e3dd9e9f8"
# Gradle prints `in 493ms`, `in 12s`, `in 1.5s`, `in 1m 2s`, `in 1h 2m 3s` — the same one
# regex every receipts.sh in this section uses, so a wall clock never enters a hashed capture.
GDUR='s/ in ([0-9]+h )?([0-9]+m )?[0-9]+(\.[0-9]+)?(ms|s)$//'
GH07="$REPO/c3-unit07/.gradle-home"
GH08="$REPO/c3-unit08/.gradle-home"
GH09="$REPO/c3-unit09/.gradle-home"
GH10="$REPO/c3-unit10/.gradle-home"
GH10X="$REPO/c3-unit10/exercise/.gh-fresh"   # a home that has never held 9.7.1
M2_U07="$REPO/c3-unit07/.m2-demo"            # each of these is the `$PWD/.m2-demo` its README names
M2_U09C="$REPO/c3-unit09/conflict/.m2-demo"
M2_U10="$REPO/c3-unit10/.m2-demo"
PORT10=18425                                 # unit 10's README and its receipts.sh both hard-code this one
export GDUR GH07 GH08 GH09 GH10 GH10X M2_U07 M2_U09C M2_U10 PORT10
export GRADLE_VERSION GRADLE_DIST_SHA256 GRADLE_WRAPPER_JAR_SHA256 GRADLEW_BAT_SHA256

# The listing of ~/.gradle before anything runs. Nothing in this section may add to it.
gradle_home_count() { [ -d "$HOME/.gradle" ] && find "$HOME/.gradle" -mindepth 1 2>/dev/null | wc -l | tr -d ' ' || echo 0; }
gradle_home_hash()  { [ -d "$HOME/.gradle" ] && find "$HOME/.gradle" -mindepth 1 2>/dev/null | LC_ALL=C sort | shasum | cut -d' ' -f1 || echo none; }

# class_hash JAR — md5 of the md5s of every `.class` member in sorted order. The pipeline
# units 07 and 10 print, written once: it is the number that says two jars built by two
# different tools hold the same code.
class_hash() {
  local j="$1" c
  for c in $(unzip -Z1 "$j" 2>/dev/null | grep '\.class$' | sort); do unzip -p "$j" "$c" | md5in; done | md5in
}
class_count() { unzip -Z1 "$1" 2>/dev/null | grep -c '\.class$' | tr -d ' '; }

# src_hash DIR — `md5 -q *.java | sort | md5 -q`, the receipt every Gradle unit opens with.
src_hash() { ( cd "$1" 2>/dev/null && for f in *.java; do md5of "$f"; done | sort | md5in ); }

# src_files SRCDIR — every .java under a source root, relative and sorted, on one line.
#
# src_hash above is a NON-RECURSIVE glob of the package directory: `*.java` in
# src/main/java/com/tiffinbox and nothing below it. So a file added at
# com/tiffinbox/<subpackage>/Anything.java is outside the receipt, is still compiled by
# `sourceSets.main`, and still ships in build/classes and in the jar — and the hash goes on
# saying "the five sources are c3-tiffinbox's, byte for byte". The hash says the five files have
# not changed; this says there are five of them and no sixth anywhere under the source root.
src_files() { ( cd "$1" 2>/dev/null && find . -name '*.java' | LC_ALL=C sort | tr '\n' ' ' ); }
FIVE_SRC="./com/tiffinbox/Customer.java ./com/tiffinbox/CustomerRepository.java ./com/tiffinbox/Dashboard.java ./com/tiffinbox/Database.java ./com/tiffinbox/OrderQueue.java "

# --------------------------------------- the READMEs' console panels, as deliverables ---------
# check_receipts below proves "what receipts.sh printed == the md5 README.md quotes". Neither half
# of that ever looks at the README's own console blocks, so every panel in c3-unit07..10 is
# unverified prose: a capture can lose a character, or drift to the opposite of the lesson the
# page is teaching, or the command printed above it can lose the `rm -rf build` that makes its
# first line true, and not one hash moves. These three compare what the page PRINTS against what
# this run actually got.

# readme_shows LABEL NN — the capture now in $OUT appears in c3-unitNN/README.md as one
# contiguous run of lines, so a printed panel cannot drift away from the command it is under.
readme_shows() {
  local label="$1" n="$2" r="$REPO/c3-unit$2/README.md"
  if [ ! -s "$OUT" ]; then bad "$label" "nothing was captured to look for in c3-unit$n/README.md"; return 1; fi
  if awk 'NR==FNR{nd[++N]=$0;next}{h[++H]=$0}
          END{ if(N==0) exit 1
               for(i=1;i+N-1<=H;i++){ok=1; for(j=1;j<=N;j++) if(h[i+j-1]!=nd[j]){ok=0;break}; if(ok) exit 0}
               exit 1 }' "$OUT" "$r"; then
    ok "$label"
  else
    bad "$label" "c3-unit$n/README.md prints no such block; this run's $(wc -l <"$OUT" | tr -d ' ') lines start: $(head -3 "$OUT" | tr '\n' '|')"
  fi
}

# readme_panel_is LABEL NN MARKER K — the Kth console panel under the prompt line `$ MARKER` in
# c3-unitNN/README.md is, line for line, what this run just got. Positional on purpose: the same
# command appears twice in unit 08's break block and the whole lesson is that both answers are
# the same one, so "the text is in there somewhere" is not the claim being made.
readme_panel_is() {
  local label="$1" n="$2" m="$3" k="$4" r="$REPO/c3-unit$2/README.md"
  awk -v mk="\$ $m" -v want="$k" '
      $0==mk { c++; if (c==want) { p=1; next } }
      p { if ($0 ~ /^\$ / || $0 == "```") exit; print }' "$r" > "$WORK/panel"
  if [ ! -s "$WORK/panel" ]; then bad "$label" "c3-unit$n/README.md has no panel $k under '\$ $m'"; return 1; fi
  if diff -q "$WORK/panel" "$OUT" >/dev/null 2>&1; then ok "$label"
  else bad "$label" "c3-unit$n/README.md prints something else under '\$ $m' (panel $k): $(diff "$WORK/panel" "$OUT" | tr '\n' ' ' | cut -c1-200)"; fi
}

# readme_quotes LABEL NN HASH — a number THIS run measured is really the number on the page.
# receipts_pairs only sees hashes written in the `receipts.sh <id> … md5 <hash>` shape; a hash
# quoted in prose is invisible to it, and without this the script holds its own correct copy,
# compares it to live output, and the README can carry anything at all under the same label.
readme_quotes() {
  if grep -qF "$3" "$REPO/c3-unit$2/README.md"; then ok "$1"
  else bad "$1" "c3-unit$2/README.md does not quote $3 anywhere"; fi
}

# receipt_hash NN ID — the md5 c3-unitNN/receipts.sh printed for ID on this run (check_receipts
# keeps its output in $WORK/receipts.NN).
receipt_hash() { grep -E "^$2[[:space:]]" "$WORK/receipts.$1" 2>/dev/null | head -1 | awk '{print $2}'; }

# wrapper_asserts LABEL DIR HOME — the same five questions of every Gradle project here.
# The last one is the one that matters: a `gradle` on the PATH would answer `Gradle 9.7.1`
# too, and only the distribution's location says which binary actually ran.
wrapper_asserts() {
  local label="$1" d="$2" h="$3"
  # THREE files, not two. gradlew.bat is the third of the same triplet and it was referenced
  # nowhere: not its bytes, not its checksum, not its existence. Replace it with two lines
  # pointing at `C:\tools\gradle-8.5\bin\gradle.bat` and every Windows student silently gets a
  # Gradle from outside the project, past the pin and past the checksum, with this script green.
  if [ -x "$d/gradlew" ] && [ -f "$d/gradlew.bat" ] && [ -f "$d/gradle/wrapper/gradle-wrapper.jar" ]; then
    ok "$label: gradlew + gradlew.bat + gradle/wrapper/ are committed, and gradlew is executable"
  else
    bad "$label: the committed wrapper" "one of gradlew, gradlew.bat, gradle/wrapper/gradle-wrapper.jar is missing in $d"
    return 1
  fi
  is "$label: gradlew is the 8 656-byte wrapper script" "$(wc -c <"$d/gradlew" | tr -d ' ')" "8656"
  is "$label: gradlew.bat is the 2 848-byte wrapper script Windows runs" \
     "$(wc -c <"$d/gradlew.bat" | tr -d ' ')" "2848"
  is "$label: …and gradlew.bat carries the sha256 all four units ship" \
     "$(shasum -a 256 "$d/gradlew.bat" | cut -d' ' -f1)" "$GRADLEW_BAT_SHA256"
  if grep -q 'gradle\\wrapper\\gradle-wrapper\.jar' "$d/gradlew.bat"; then
    ok "$label: …and gradlew.bat launches THIS project's gradle-wrapper.jar, not a gradle installed on the machine"
  else
    bad "$label: gradlew.bat" "it does not run %APP_HOME%\\gradle\\wrapper\\gradle-wrapper.jar, so a Windows student gets some other Gradle"
  fi
  is "$label: gradle-wrapper.jar is 47 505 bytes" \
     "$(wc -c <"$d/gradle/wrapper/gradle-wrapper.jar" | tr -d ' ')" "47505"
  is "$label: …and carries the published wrapper sha256" \
     "$(shasum -a 256 "$d/gradle/wrapper/gradle-wrapper.jar" | cut -d' ' -f1)" "$GRADLE_WRAPPER_JAR_SHA256"
  timed 60 cat "$d/gradle/wrapper/gradle-wrapper.properties"
  has "$label: the properties pin a DISTRIBUTION CHECKSUM, not just a version" \
      "^distributionSha256Sum=$GRADLE_DIST_SHA256\$"
  has "$label: …and the version is $GRADLE_VERSION" "gradle-9\.7\.1-bin\.zip"
  # The filename regex above is what the version check used to be on its own, and a filename is
  # not a source: swap the host for a box on the LAN, keep `gradle-9.7.1-bin.zip`, serve the
  # genuine zip, and the sha256 pin is satisfied by construction because the bytes are real.
  # So the whole line is pinned — scheme and host included.
  has "$label: …fetched over HTTPS from services.gradle.org, whole line — a checksum a mirror can satisfy by serving the real bytes pins nothing about WHERE the build tool came from" \
      '^distributionUrl=https\\://services\.gradle\.org/distributions/gradle-9\.7\.1-bin\.zip$'
  # …and the four properties that decide where the zip is unpacked and run from. Nothing read
  # them before, so `distributionPath=dists-elsewhere` moved the distribution that actually ran
  # the build out from under the `exists` check below, which then passed on a stale directory
  # left by an earlier run.
  has "$label: …distributionBase=GRADLE_USER_HOME"  '^distributionBase=GRADLE_USER_HOME$'
  has "$label: …distributionPath=wrapper/dists, which is the directory the next check looks in" \
      '^distributionPath=wrapper/dists$'
  has "$label: …zipStoreBase=GRADLE_USER_HOME"      '^zipStoreBase=GRADLE_USER_HOME$'
  has "$label: …zipStorePath=wrapper/dists"         '^zipStorePath=wrapper/dists$'
  expect_ok "$label: ./gradlew --version -> Gradle $GRADLE_VERSION" 1800 "^Gradle 9\.7\.1\$" \
      bash -c "cd \"$d\" && GRADLE_USER_HOME=\"$h\" ./gradlew --console=plain -q --version"
  # THE assertion of the four. /opt/homebrew/bin/gradle is 9.7.1 on this machine, so the
  # version string above cannot tell the two apart; the unpacked distribution under this
  # project's own Gradle home can, because only the wrapper ever puts one there.
  exists "$label: …and it ran the wrapper's own distribution, out of this project's GRADLE_USER_HOME" \
      "$h/wrapper/dists/gradle-9.7.1-bin"
}

# gstop LABEL DIR HOME — `./gradlew --stop`, then WAIT for the JVM to actually be gone.
# The daemon outlives the terminal that started it (unit 07's README says exactly that) and
# `timed` cannot reach it: it is not in the child's process group. Verified by pid, never by
# the message the command prints, and matched on this run's own Gradle home so that a daemon
# somebody else started from ~/.gradle is neither waited for nor killed.
gstop() {
  local label="$1" d="$2" h="$3" i
  [ -d "$h" ] || return 0
  ( cd "$d" && GRADLE_USER_HOME="$h" ./gradlew --stop ) >/dev/null 2>&1
  for i in $(seq 1 60); do
    pgrep -f "$h/wrapper/dists" >/dev/null 2>&1 || { ok "$label: ./gradlew --stop — no daemon of ours left"; return 0; }
    sleep 0.5
  done
  pkill -9 -f "$h/wrapper/dists" >/dev/null 2>&1
  bad "$label: ./gradlew --stop" "a Gradle daemon under $h was still alive 30s later (killed by hand)"
}

# ------------------------------------------- receipts.sh, checked as a deliverable ---
# Units 07-10 each ship a receipts.sh that regenerates every md5 its README quotes. The
# pairs are read OUT OF the README — `receipts.sh <id>` … `md5 <hash>`, which the four
# READMEs write on one line and across two — so what is compared is the README's own
# number against the script's own output. Nothing is transcribed into this file, which is
# the only way the check still fails when a README and its receipts.sh drift apart.
receipts_pairs() {
  tr '\n' ' ' < "$1/README.md" \
    | grep -oE 'receipts\.sh [a-z][a-z-]*`?[^`]{0,40}`?md5 [0-9a-f]{32}' \
    | sed -E 's/^receipts\.sh ([a-z][a-z-]*).*md5 ([0-9a-f]{32})$/\1 \2/'
}

# check_receipts NN TIMEOUT EXPECTED_PAIRS — run the unit's receipts.sh from this clone and
# assert every hash it prints is the hash its README quotes.
check_receipts() {
  local n="$1" t="$2" want="$3" d h
  d="$REPO/c3-unit$n"; h="$REPO/c3-unit$n/.gradle-home"
  if ! command -v zsh >/dev/null 2>&1; then
    skip "c3-unit$n/receipts.sh" "the receipts scripts are #!/bin/zsh and there is no zsh here"
    return 0
  fi
  expect_ok "c3-unit$n/receipts.sh — every block, from a clean clone" "$t" '' \
      bash -c "cd \"$d\" && GRADLE_USER_HOME=\"$h\" ./receipts.sh" || return 1
  cp "$OUT" "$WORK/receipts.$n"
  local np=0 id hh line
  id=""; hh=""; line=""
  while read -r id hh; do
    [ -n "${id:-}" ] || continue
    np=$((np+1))
    # unit 10's `drift` needs a SECOND Gradle distribution, which only the viewer can
    # supply. The thing to assert then is that it says so — a block that quietly printed
    # nothing would be indistinguishable from one that passed.
    if [ "$id" = "drift" ] && [ -z "${OLD_GRADLE:-}" ]; then
      if grep -qE "^drift +skipped - set OLD_GRADLE=" "$WORK/receipts.$n"; then
        ok "…receipts.sh drift — SKIPS out loud without a second distribution (no hash, no silent pass)"
        # …and say out loud that the NUMBER went unchecked. The line above is true of the block and
        # says nothing about $hh: with OLD_GRADLE unset, c3-unit$n/README.md's drift hash can be
        # anything at all — thirty-two zeroes included — and the run stays green. A green line over
        # an unmeasured number is exactly the reading this script exists to prevent.
        skip "…receipts.sh drift -> md5 $hh, the hash c3-unit$n/README.md quotes" \
             "not measured by this run: the drift receipt needs a SECOND Gradle distribution, so that hash is the one number on the page nothing here checks — set OLD_GRADLE=/path/to/an/older/gradle/bin/gradle to check it"
      else
        cp "$WORK/receipts.$n" "$OUT"
        bad "receipts.sh drift" "expected 'drift  skipped - set OLD_GRADLE=…'; it printed something else"
      fi
      continue
    fi
    if grep -qE "^$id[[:space:]]+$hh" "$WORK/receipts.$n"; then
      ok "…receipts.sh $id -> md5 $hh, the hash c3-unit$n/README.md quotes"
    else
      line="$(grep -E "^$id[[:space:]]" "$WORK/receipts.$n" | head -1)"
      cp "$WORK/receipts.$n" "$OUT"
      bad "receipts.sh $id" "README.md quotes $hh; receipts.sh printed: ${line:-<no line for that id at all>}"
    fi
  done < <(receipts_pairs "$d")
  is "…and c3-unit$n/README.md quotes $want receipt hashes in all" "$np" "$want"
}

# ------------------------------------------ the tree, before and after --------
# The run swaps pom.xml files and `sed`s one source file, and has to put every one
# back. The old proof was `git status` at the end — which also fails when the tree
# legitimately carries uncommitted work that this run never touched. So take a
# content fingerprint of everything Course 3 ships, minus what a build writes, and
# compare it with itself at the end: that is literally "as this run found it".
tree_fingerprint() {
  local d f
  { for d in "$REPO"/c3-unit0[1-9] "$REPO"/c3-unit10 "$REPO"/c3-tiffinbox; do
      [ -d "$d" ] || continue
      find "$d" -type f \
           -not -path '*/target/*'      -not -path '*/.m2-demo/*' \
           -not -path '*/.m2-unit04/*'  -not -path '*/.m2-unit06/*' \
           -not -path '*/build/*'       -not -path '*/.gradle/*' \
           -not -path '*/.gradle-home/*' \
           -not -path '*/.gh-fresh/*'   -not -path '*/.gh-old/*' \
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
      0[1-9]|10) [ -d "$REPO/c3-unit$u" ] || { echo "unknown unit: $u (no c3-unit$u/ in $REPO)" >&2; exit 2; } ;;
      *) echo "unknown unit: $u (use two digits, 01-10, or 'tiffinbox')" >&2; exit 2 ;;
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
printf '                                  c3-unit07/.m2-demo · c3-unit09/conflict/.m2-demo · c3-unit10/.m2-demo\n'
printf 'Gradle homes (never ~/.gradle):   c3-unit07..10/.gradle-home — each project'"'"'s committed wrapper fetches 9.7.1 into its own\n'
[ -n "${OLD_GRADLE:-}" ] && printf 'OLD_GRADLE=%s — unit 10'"'"'s drift beat runs for real\n' "$OLD_GRADLE"
[ "$SKIP_SLOW" = "1" ] && printf '%sSKIP_SLOW=1 — the repeated-build hash loops are shortened%s\n' "$YLW" "$OFF"
if [ -e "$HOME/.m2/repository/com/tiffinbox" ]; then
  printf '%sNOTE: ~/.m2/repository/com/tiffinbox already exists — something before this run installed it.%s\n' "$YLW" "$OFF"
fi

FP_BEFORE="$(tree_fingerprint)"
GRADLE_N_BEFORE="$(gradle_home_count)"
GRADLE_H_BEFORE="$(gradle_home_hash)"

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

# ============================================================= c3-unit07 ====
if unit 07 "Gradle in one build file"; then
  wrapper_asserts "c3-unit07" "$REPO/c3-unit07" "$GH07"

  # README line 19: the five sources ARE c3-tiffinbox/tiffinbox-core, byte for byte.
  H="$(src_hash "$REPO/c3-unit07/src/main/java/com/tiffinbox")"
  is "md5 -q *.java | sort | md5 -q -> the hash the README quotes" "$H" "fdb1643d622615f3c331d75deaebb9da"
  is "…and c3-tiffinbox/tiffinbox-core answers with the same one" \
     "$(src_hash "$REPO/c3-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox")" "$H"
  # …and there are five of them. The hash above globs one directory and does not descend.
  is "…and src/main/java holds those FIVE files and no sixth below them" \
     "$(src_files "$REPO/c3-unit07/src/main/java")" "$FIVE_SRC"

  # ---- the two halves of this one directory, on the same dependency. Unit 07's whole thesis is
  # "the whole build, in one file — every line has a counterpart in pom.xml", and H2 is a compile
  # dependency that never enters either jar, so the class-hash comparison below cannot see the
  # Gradle side and the Maven side drifting on to different versions of it.
  GH2="$(sed -n 's/.*com\.h2database:h2:\([0-9.]*\).*/\1/p' "$REPO/c3-unit07/build.gradle.kts" | head -1)"
  PH2="$(sed -n '/<artifactId>h2<\/artifactId>/,/<\/dependency>/s|.*<version>\([0-9.]*\)</version>.*|\1|p' "$REPO/c3-unit07/pom.xml" | head -1)"
  is "build.gradle.kts and pom.xml name the SAME H2 version, which is what 'a counterpart in pom.xml' means" "$GH2" "$PH2"
  is "…and it is the 2.5.250 both files ship" "$GH2" "2.5.250"

  # ---- the Maven side of the directory: seven goals, two of them about tests
  expect_ok "mvn -B clean package | grep '^\[INFO\] --- ' (the Maven half of the same directory)" 1200 \
      'surefire:3\.5\.4:test \(default-test\) @ tiffinbox-core' \
      bash -c 'cd "$REPO/c3-unit07" && mvn -B "-Dmaven.repo.local=$M2_U07" clean package 2>&1 | grep -E "^\[INFO\] --- "'
  N="$(countq '^\[INFO\] --- ')"
  is "…SEVEN goal lines, in a project with no tests at all" "$N" "7"
  has "…and the jar plugin at the version the POM pins" 'jar:3\.5\.0:jar \(default-jar\) @ tiffinbox-core'

  # ---- the Gradle side. `rm -rf build` FIRST, because the README's block is the viewer's
  # first `clean jar` on a fresh clone: there is no build/ yet, so `clean` has nothing to
  # delete and says UP-TO-DATE. Build into the state, then name it.
  timed 1800 bash -c 'cd "$REPO/c3-unit07" && rm -rf build && GRADLE_USER_HOME="$GH07" ./gradlew --console=plain clean jar \
      | grep -E "^> Task|^BUILD|actionable" | sed -E "$GDUR"'
  if [ "$RC" -eq 0 ]; then
    has "rm -rf build && ./gradlew clean jar -> :clean UP-TO-DATE (nothing to delete yet)" '^> Task :clean UP-TO-DATE$'
    has "…:compileJava, with no word after it — it ran" '^> Task :compileJava$'
    has "…:processResources NO-SOURCE — 'nothing to work on', which is not UP-TO-DATE" '^> Task :processResources NO-SOURCE$'
    has "…BUILD SUCCESSFUL" '^BUILD SUCCESSFUL$'
    has "…3 actionable tasks: 2 executed, 1 up-to-date" '^3 actionable tasks: 2 executed, 1 up-to-date$'
    N="$(countq '^> Task ')"
    is "…five task lines, and not one of them is a test" "$N" "5"
    is "…md5 of the capture (receipts.sh gradle-jar)" "$(md5of "$OUT")" "a833ea2212678d80bc0c16f9aa694d8e"
    # …and the page PRINTS these seven lines, which until now nothing checked: the md5 above and
    # the md5 the README quotes could agree perfectly while the block on screen said `NO-SORCE`.
    readme_shows "…and c3-unit07/README.md prints this capture, line for line, not a hash of it" 07
    cp "$OUT" "$WORK/u07.jar-capture"
  else
    bad "rm -rf build && ./gradlew clean jar" "exit $RC"
  fi
  # The command printed above that block is a deliverable too, and this script runs a transcribed
  # copy of it rather than the README's text — so the page can lose the `rm -rf build` that is the
  # only reason its first line reads `:clean UP-TO-DATE` without a single assertion moving.
  if grep -qF "rm -rf build && ./gradlew --console=plain clean jar | grep -E '^> Task|^BUILD|actionable'" "$REPO/c3-unit07/README.md"; then
    ok "…and the command c3-unit07/README.md hands the viewer still starts with the rm -rf build that makes that first line true"
  else
    bad "c3-unit07/README.md's clean jar command" \
        "the printed command is no longer 'rm -rf build && ./gradlew --console=plain clean jar | grep -E …' — the capture under it describes a different state"
  fi
  # …and the SECOND run, which the README also quotes and also calls real: now clean has
  # something to delete, so the same five lines carry two different words.
  timed 1800 bash -c 'cd "$REPO/c3-unit07" && GRADLE_USER_HOME="$GH07" ./gradlew --console=plain clean jar \
      | grep -E "^> Task|^BUILD|actionable" | sed -E "$GDUR"'
  if [ "$RC" -eq 0 ]; then
    has "…run it again and :clean really deletes something" '^> Task :clean$'
    has "…3 actionable tasks: 3 executed" '^3 actionable tasks: 3 executed$'
    is "…md5 of the second-run capture, the other hash the README quotes" \
       "$(md5of "$OUT")" "96be409590cea1a7dcfb4a8820899d98"
    # …and it really is quoted. No receipts.sh block regenerates this one and it is written in
    # prose, outside the `receipts.sh <id> → md5 <hash>` shape receipts_pairs reads, so
    # check_receipts never sees it: the label above was a claim about this script's own copy.
    readme_quotes "…and c3-unit07/README.md is the page quoting it — 96be409590cea1a7dcfb4a8820899d98" \
                  07 "$(md5of "$OUT")"
  else
    bad "./gradlew clean jar (second run)" "exit $RC"
  fi

  # ---- the same jar, and exactly how it is not the same file
  timed 120 bash -c 'cd "$REPO/c3-unit07" && diff <(unzip -Z1 target/tiffinbox-core-1.0.0.jar | sort) \
                                                  <(unzip -Z1 build/libs/tiffinbox-core-1.0.0.jar | sort)'
  cp "$OUT" "$WORK/u07.jar-entries"   # receipts.sh `jar-entries` hashes this same diff; compared below
  N="$(countq '^< META-INF/maven/')"
  is "diff of the two jars' entry lists: five META-INF/maven entries Maven adds" "$N" "5"
  hasnt "…and nothing at all the Gradle jar has that the Maven jar does not" '^> '
  CH="$(class_hash "$REPO/c3-unit07/target/tiffinbox-core-1.0.0.jar")"
  is "one class-content hash, two jars: the Maven jar" "$CH" "8bd6fdb961f65dddc82a242e5472059c"
  is "…and the Gradle jar, identical" "$(class_hash "$REPO/c3-unit07/build/libs/tiffinbox-core-1.0.0.jar")" "$CH"
  is "…seven class files in each" "$(class_count "$REPO/c3-unit07/target/tiffinbox-core-1.0.0.jar")" "7"
  is "…seven in the Gradle one too" "$(class_count "$REPO/c3-unit07/build/libs/tiffinbox-core-1.0.0.jar")" "7"

  # ---- phases are a sequence, tasks are a graph
  timed 1200 bash -c 'cd "$REPO/c3-unit07" && mvn -B "-Dmaven.repo.local=$M2_U07" help:describe -Dcmd=package | grep -c "^\* "
                      cd "$REPO/c3-unit07" && mvn -B "-Dmaven.repo.local=$M2_U07" help:describe -Dcmd=package | grep -c "Not defined"'
  is "help:describe -Dcmd=package -> 23 phases" "$(sed -n '1p' "$OUT" | tr -d ' ')" "23"
  is "…15 of them have no default goal for jar packaging" "$(sed -n '2p' "$OUT" | tr -d ' ')" "15"
  expect_ok "./gradlew -m jar | grep '^:' -> the plan, and test is not on it" 900 '^:jar SKIPPED$' \
      bash -c 'cd "$REPO/c3-unit07" && GRADLE_USER_HOME="$GH07" ./gradlew --console=plain -m jar | grep "^:"'
  is "…four tasks" "$(countq '^:')" "4"
  hasnt "…:test is not on the path to :jar, so it is not in the plan" '^:test SKIPPED$'
  expect_ok "./gradlew -m build | grep '^:' -> eleven, and now test IS on it" 900 '^:test SKIPPED$' \
      bash -c 'cd "$REPO/c3-unit07" && GRADLE_USER_HOME="$GH07" ./gradlew --console=plain -m build | grep "^:"'
  is "…eleven tasks against four" "$(countq '^:')" "11"

  expect_ok "./gradlew -q tasks | grep -cE '^[a-zA-Z]+ - ' -> 26 described tasks" 900 '' \
      bash -c 'cd "$REPO/c3-unit07" && GRADLE_USER_HOME="$GH07" ./gradlew --console=plain -q tasks | grep -cE "^[a-zA-Z]+ - "'
  is "…26, out of a build.gradle.kts of 21 lines" "$(tr -d ' \n' <"$OUT")" "26"
  cp "$OUT" "$WORK/u07.task-count"    # receipts.sh `task-count` hashes this same number; compared below

  expect_fail "./gradlew jarr -> exit 1, and Gradle names the task you meant" 900 \
      "Task 'jarr' not found in root project 'tiffinbox-core'\. Some candidates are: 'jar'\." \
      bash -c 'cd "$REPO/c3-unit07" && GRADLE_USER_HOME="$GH07" ./gradlew --console=plain jarr'

  # ---- the README's offline claims, both of them, each as a pair: the ordinary online
  # build into this unit's own repository/cache first, then the same command offline.
  offline_receipt 'mvn -o -B verify -Dmaven.repo.local="$PWD/.m2-demo"' 1200 "$REPO/c3-unit07" "$M2_U07"
  expect_ok "./gradlew build — online first, filling this unit's own Gradle home" 1800 'BUILD SUCCESSFUL' \
      bash -c 'cd "$REPO/c3-unit07" && GRADLE_USER_HOME="$GH07" ./gradlew --console=plain build'
  expect_ok "./gradlew --offline build — then offline, same cache: it resolved nothing new" 1800 'BUILD SUCCESSFUL' \
      bash -c 'cd "$REPO/c3-unit07" && GRADLE_USER_HOME="$GH07" ./gradlew --console=plain --offline build'

  # ---- exercise: the block Maven gave you for free
  backup "$REPO/c3-unit07/exercise/build.gradle.kts"
  expect_fail "exercise: ../gradlew jar unedited -> no repositories are defined" 1800 \
      'Cannot resolve external dependency com\.h2database:h2:2\.5\.250 because no repositories are defined' \
      bash -c 'cd "$REPO/c3-unit07/exercise" && GRADLE_USER_HOME="$GH07" ../gradlew --console=plain jar'
  has "…and it is :compileJava that fails, exactly as the exercise README prints it" \
      "Execution failed for task ':compileJava'"
  cp "$REPO/c3-unit07/exercise/solution/build.gradle.kts" "$REPO/c3-unit07/exercise/build.gradle.kts"
  expect_ok "exercise solution: the one repositories { } block, and ../gradlew jar is green" 1800 \
      '^BUILD SUCCESSFUL' bash -c 'cd "$REPO/c3-unit07/exercise" && GRADLE_USER_HOME="$GH07" ../gradlew --console=plain jar'
  exists "…and build/libs/tiffinbox-core-1.0.0.jar is really there, which is the end state it promises" \
      "$REPO/c3-unit07/exercise/build/libs/tiffinbox-core-1.0.0.jar"
  restore_all

  # ---- the honest-limit panel: no JAVA_HOME, and the build dies before it reaches the code.
  # Runs late because it leaves build/ deleted; receipts.sh rebuilds whatever it needs.
  if [ -x /usr/bin/java ]; then
    expect_fail "( unset JAVA_HOME; PATH=/usr/bin:/bin ./gradlew clean jar ) -> release version 25 not supported" 1800 \
        '^    error: release version 25 not supported$' \
        bash -c 'cd "$REPO/c3-unit07" && unset JAVA_HOME && PATH=/usr/bin:/bin GRADLE_USER_HOME="$GH07" ./gradlew --console=plain clean jar'
    has "…> Task :compileJava FAILED" '^> Task :compileJava FAILED'
    has "…> Java compilation initialization error" '^> Java compilation initialization error'
  else
    skip "the no-JAVA_HOME panel" "there is no /usr/bin/java on this machine to be the wrong JDK"
  fi

  check_receipts 07 3600 6

  # ---- the five receipts nobody was reading.
  # receipts.sh prints eleven; c3-unit07/README.md quotes six; check_receipts only looks at ids the
  # README quotes. So gradle-ver, wrapper-props, jar-entries, task-count and java-versions are
  # computed on every run and thrown away — `task-count`'s grep can go from `^[a-zA-Z]+ - ` to
  # `^[a-zA-Z]+ -- `, print 0 where the README's page says 26, and nothing moves. Each one below is
  # compared against THIS run's own capture of the same pipeline, hashed the way run() hashes it.
  is "c3-unit07/receipts.sh prints ELEVEN receipts — six the README quotes and five nothing used to read" \
     "$(grep -cE '^[a-z][a-z-]+ +[0-9a-f]{32}$' "$WORK/receipts.07" | tr -d ' ')" "11"
  is "…receipts.sh task-count is the md5 of the 26 THIS run counted, not of some other number" \
     "$(receipt_hash 07 task-count)" "$(md5of "$WORK/u07.task-count")"
  is "…receipts.sh jar-entries is the md5 of the two-jar diff THIS run took" \
     "$(receipt_hash 07 jar-entries)" "$(md5of "$WORK/u07.jar-entries")"
  timed 60 bash -c 'cd "$REPO/c3-unit07" && grep -E "distributionUrl|distributionSha256Sum" gradle/wrapper/gradle-wrapper.properties'
  is "…receipts.sh wrapper-props is the md5 of the two pinning lines as they stand in the file" \
     "$(receipt_hash 07 wrapper-props)" "$(md5of "$OUT")"
  timed 900 bash -c 'cd "$REPO/c3-unit07" && GRADLE_USER_HOME="$GH07" ./gradlew --console=plain --version \
      | grep -E "^Gradle|^Launcher JVM|^Daemon JVM|^OS"'
  is "…receipts.sh gradle-ver is the md5 of the version block this machine prints" \
     "$(receipt_hash 07 gradle-ver)" "$(md5of "$OUT")"
  if [ -x /usr/bin/java ]; then
    timed 120 bash -c '( unset JAVA_HOME; PATH=/usr/bin:/bin java -version 2>&1 | head -1 ); "$JAVA" -version 2>&1 | head -1'
    is "…receipts.sh java-versions is the md5 of the two JDK lines this machine prints" \
       "$(receipt_hash 07 java-versions)" "$(md5of "$OUT")"
  else
    skip "…receipts.sh java-versions" "there is no /usr/bin/java on this machine to be the other JDK"
  fi

  # ---- and two questions about receipts.sh itself, which no hash can answer.
  #
  # (a) A receipt that stopped measuring. `gradle-jar` is one of the six the README quotes, so
  # check_receipts looks at it — but all check_receipts can see is that the string receipts.sh
  # printed equals the string README.md quotes. Delete the pipeline, `printf` today's seven lines,
  # and the two still agree exactly. The question a hash cannot ask is whether the block did any
  # work, so this asks the artifact: the block begins `rm -rf build` and ends having built a jar.
  rm -rf "$REPO/c3-unit07/build"
  expect_ok "receipts.sh gradle-jar, run on its own with build/ deleted" 1800 '^gradle-jar ' \
      bash -c "cd \"$REPO/c3-unit07\" && GRADLE_USER_HOME=\"$GH07\" ./receipts.sh gradle-jar"
  exists "…really BUILT the jar it hashes a build of — a block that printf's the remembered number leaves no build/libs" \
      "$REPO/c3-unit07/build/libs/tiffinbox-core-1.0.0.jar"
  is "…and the hash it printed is still the one this run measured" \
     "$(sed -n 's/^gradle-jar  *\([0-9a-f]*\).*/\1/p' "$OUT" | head -1)" "$(md5of "$WORK/u07.jar-capture")"

  # (b) run() folds stderr INTO the hashed capture, and receipts.sh's Rule 1 — "a block that needs
  # an artifact BUILDS it first, or fails loudly" — is only observable because it does. Every block
  # that needs stderr redirects it itself, so `2>&1` → `2>/dev/null` in run() changes not one of
  # the eleven hashes on a good day; it changes every one of them on the day a guard fires, to the
  # md5 of nothing. Fire the guard: no pom.xml, no jars, so need_jars cannot build and says so.
  # The message is read OUT OF receipts.sh, so this compares the deliverable with itself rather
  # than with a number typed in here.
  GUARD="$(sed -n 's/.*echo "\(jar-entries  FAILED - mvn package[^"]*\)".*/\1/p' "$REPO/c3-unit07/receipts.sh" | head -1)"
  backup "$REPO/c3-unit07/pom.xml"
  rm -rf "$REPO/c3-unit07/build" "$REPO/c3-unit07/target" "$REPO/c3-unit07/pom.xml"
  timed 900 bash -c "cd \"$REPO/c3-unit07\" && GRADLE_USER_HOME=\"$GH07\" ./receipts.sh jar-entries"
  restore_all
  is "receipts.sh jar-entries with no pom.xml and no jars: run() hashed need_jars' loud refusal, which is the only thing that makes Rule 1 observable" \
     "$(sed -n 's/^jar-entries  *\([0-9a-f]*\).*/\1/p' "$OUT" | head -1)" "$(printf '%s\n' "$GUARD" | md5in)"
  hasnt "…and it is NOT d41d8cd98f00b204e9800998ecf8427e, the md5 of nothing, which is what a receipt prints once run() stops folding stderr in" \
      'd41d8cd98f00b204e9800998ecf8427e'

  gstop "c3-unit07" "$REPO/c3-unit07" "$GH07"
fi

# ============================================================= c3-unit08 ====
# The state words ARE the subject here, so every one of them is built into first: the
# build cache is wiped before the beat that says FROM-CACHE, `--no-build-cache` is passed
# wherever the unit passes it, and the three states are run in the order the README runs
# them. A green build proves nothing in this unit — twice below, the artifact does.
if unit 08 "Tasks, inputs, outputs"; then
  wrapper_asserts "c3-unit08" "$REPO/c3-unit08" "$GH08"
  MENU="$REPO/c3-unit08/src/main/menu/menu.txt"
  BMENU="$REPO/c3-unit08/breaks/undeclared-input/src/main/menu/menu.txt"
  J8="$REPO/c3-unit08/build/libs/tiffinbox-core-1.0.0.jar"
  backup "$MENU"; backup "$BMENU"

  is "the five sources are c3-tiffinbox's, byte for byte" \
     "$(src_hash "$REPO/c3-unit08/src/main/java/com/tiffinbox")" "fdb1643d622615f3c331d75deaebb9da"
  # The hash above is a glob of one directory. A sixth file at com/tiffinbox/<subpackage>/ is
  # outside it, compiles anyway, and ships in build/classes and in the jar — while the line above
  # goes on saying "byte for byte". This is the count the hash cannot make.
  is "…and there are FIVE of them under src/main/java, with nothing below the package directory" \
     "$(src_files "$REPO/c3-unit08/src/main/java")" "$FIVE_SRC"
  is "src/main/menu/menu.txt ships with THREE lines" "$(wc -l <"$MENU" | tr -d ' ')" "3"
  has_caching=0
  grep -q '^org.gradle.caching=true' "$REPO/c3-unit08/gradle.properties" && has_caching=1
  is "gradle.properties turns the build cache on — the one line the FROM-CACHE beat needs" "$has_caching" "1"

  # ---- three answers, not two. Each one is built INTO before it is named.
  rm -rf "$GH08/caches/build-cache-1"
  expect_ok "state 1 — cache wiped, ./gradlew clean, then build: three tasks, no word on any of them" 1800 \
      '^3 actionable tasks: 3 executed$' \
      bash -c 'cd "$REPO/c3-unit08" && GRADLE_USER_HOME="$GH08" ./gradlew --no-build-cache -q clean \
               && GRADLE_USER_HOME="$GH08" ./gradlew --console=plain build | grep -E "^> Task :(generateMenu|compileJava|jar)|actionable"'
  has "…:generateMenu ran" '^> Task :generateMenu$'
  has "…:compileJava ran" '^> Task :compileJava$'
  has "…:jar ran" '^> Task :jar$'
  expect_ok "state 2 — straight away, again: outputs on disk and inputs unchanged" 1800 \
      '^3 actionable tasks: 3 up-to-date$' \
      bash -c 'cd "$REPO/c3-unit08" && GRADLE_USER_HOME="$GH08" ./gradlew --console=plain build | grep -E "^> Task :(generateMenu|compileJava|jar)|actionable"'
  has "…:generateMenu UP-TO-DATE" '^> Task :generateMenu UP-TO-DATE$'
  has "…:compileJava UP-TO-DATE"  '^> Task :compileJava UP-TO-DATE$'
  has "…:jar UP-TO-DATE"          '^> Task :jar UP-TO-DATE$'
  expect_ok "state 3 — clean && build: outputs GONE, inputs unchanged" 1800 \
      '^3 actionable tasks: 2 executed, 1 from cache$' \
      bash -c 'cd "$REPO/c3-unit08" && GRADLE_USER_HOME="$GH08" ./gradlew -q clean \
               && GRADLE_USER_HOME="$GH08" ./gradlew --console=plain build | grep -E "^> Task :(generateMenu|compileJava|jar)|actionable"'
  has "…:compileJava FROM-CACHE — a different claim from UP-TO-DATE, and a different word" \
      '^> Task :compileJava FROM-CACHE$'
  hasnt "…and it is the ONLY one of the three that says it" '^> Task :(generateMenu|jar) FROM-CACHE$'

  expect_ok "…and Gradle says WHY the other two are not cacheable, in its own words" 1800 \
      "Caching disabled for task ':generateMenu' because:" \
      bash -c 'cd "$REPO/c3-unit08" && GRADLE_USER_HOME="$GH08" ./gradlew -q clean \
               && GRADLE_USER_HOME="$GH08" ./gradlew --console=plain build --info | grep -A1 "^Caching disabled for task" | grep -v "^--$"'
  has "…'Caching has not been enabled for the task' (a custom task is not cacheable until you say so)" \
      '^  Caching has not been enabled for the task$'
  has "…:jar: 'Not worth caching' — Gradle's decision, not a summary of it" "Caching disabled for task ':jar' because:"
  has "…and those are its words" '^  Not worth caching$'

  # ---- twelve tasks, twelve reasons. --no-build-cache is in the README's command, so it is here.
  expect_ok "./gradlew --no-build-cache build --info | grep '^Skipping task' -> twelve reasons" 1800 \
      "^Skipping task ':generateMenu' as it is up-to-date\.$" \
      bash -c 'cd "$REPO/c3-unit08" && GRADLE_USER_HOME="$GH08" ./gradlew --console=plain --no-build-cache -q clean \
               && GRADLE_USER_HOME="$GH08" ./gradlew --console=plain --no-build-cache -q build \
               && GRADLE_USER_HOME="$GH08" ./gradlew --console=plain --no-build-cache build --info | grep "^Skipping task"'
  is "…twelve lines, one per task — nothing is silent" "$(countq '^Skipping task')" "12"
  is "…three of them 'up to date'"        "$(countq 'as it is up-to-date\.')" "3"
  is "…four 'no source files'"            "$(countq 'as it has no source files and no previous output files\.')" "4"
  is "…five 'no actions'"                 "$(countq 'as it has no actions\.')" "5"

  # ---- change the input and ask again: three tasks, each naming the previous one's output
  expect_ok "echo 'Lentil Soup|VEGAN' >> menu.txt && build --info -> the chain, printed" 1800 \
      "^Task ':generateMenu' is not up-to-date because:$" \
      bash -c 'cd "$REPO/c3-unit08" && printf "Lentil Soup|VEGAN\n" >> src/main/menu/menu.txt \
               && GRADLE_USER_HOME="$GH08" ./gradlew --console=plain --no-build-cache build --info \
                  | grep -E "is not up-to-date because:|  Input property" | sed -E "s|file .*c3-unit08/|file |"'
  has "…menuFile: src/main/menu/menu.txt has changed" \
      "^  Input property 'menuFile' file src/main/menu/menu\.txt has changed\.$"
  has "…compileJava's stableSources: the generated MenuCatalog.java — generateMenu's output" \
      "^  Input property 'stableSources' file build/generated/menu/com/tiffinbox/MenuCatalog\.java has changed\.$"
  has "…jar's rootSpec\$1: MenuCatalog.class — compileJava's output" \
      "Input property 'rootSpec\\\$1' file build/classes/java/main/com/tiffinbox/MenuCatalog\.class has changed\."
  is "…three tasks re-run, three reasons" "$(countq 'is not up-to-date because:')" "3"
  restore_all

  # ---- THE BREAK. One annotation removed; the build stays green and the jar goes stale.
  # The proof is deliberately NOT the build result — this beat fails with exit 0. It is the
  # program's own output, next to `wc -l` of the file it was generated from.
  expect_ok "breaks/undeclared-input: clean, then build -> three tasks executed" 1800 \
      '^3 actionable tasks: 3 executed$' \
      bash -c 'cd "$REPO/c3-unit08/breaks/undeclared-input" && GRADLE_USER_HOME="$GH08" ../../gradlew -q clean \
               && GRADLE_USER_HOME="$GH08" ../../gradlew --console=plain build | grep -E "^> Task :(generateMenu|compileJava|jar)|actionable"'
  expect_ok "…java -cp build/classes/java/main com.tiffinbox.MenuCatalog -> menu items: 3" 300 \
      '^menu items: 3$' \
      bash -c 'cd "$REPO/c3-unit08/breaks/undeclared-input" && "$JAVA" "-D$TAG=u08" -cp build/classes/java/main com.tiffinbox.MenuCatalog'
  has "…[Grilled Chicken, Steamed Rice, Garden Salad]" '^\[Grilled Chicken, Steamed Rice, Garden Salad\]$'
  # …and the break panel c3-unit08/README.md prints under that very command says the same thing.
  # Nothing compared a README's console block against a command's output before: receipts_pairs
  # reads hashes, check_receipts compares hashes, and the page's own panel could drift to the
  # opposite of the lesson — `menu items: 4`, with Lentil Soup in the list, two lines above the
  # sentence "The file has four lines. The jar says three." — with every hash unmoved.
  readme_panel_is "…and c3-unit08/README.md's first break panel prints exactly that" \
      08 'java -cp build/classes/java/main com.tiffinbox.MenuCatalog' 1
  printf 'Lentil Soup|VEGAN\n' >> "$BMENU"
  is "…echo 'Lentil Soup|VEGAN' >> menu.txt ; wc -l -> the file now has FOUR lines" \
     "$(wc -l <"$BMENU" | tr -d ' ')" "4"
  expect_ok "…and ./gradlew build says UP-TO-DATE over the changed input, with exit 0" 1800 \
      '^3 actionable tasks: 3 up-to-date$' \
      bash -c 'cd "$REPO/c3-unit08/breaks/undeclared-input" && GRADLE_USER_HOME="$GH08" ../../gradlew --console=plain build \
               | grep -E "^> Task :(generateMenu|compileJava|jar)|actionable"'
  has "…:generateMenu UP-TO-DATE, over an input Gradle was never told about" '^> Task :generateMenu UP-TO-DATE$'
  # THE assertion. Not BUILD SUCCESSFUL — that is what this failure prints.
  expect_ok "…the artifact is STALE: four lines in, three items out, and the build was green" 300 \
      '^menu items: 3$' \
      bash -c 'cd "$REPO/c3-unit08/breaks/undeclared-input" && "$JAVA" "-D$TAG=u08" -cp build/classes/java/main com.tiffinbox.MenuCatalog'
  hasnt "…Lentil Soup is in the file and not in the jar" 'Lentil Soup'
  # The whole break is that this second panel is the SAME two lines as the first, so it is checked
  # positionally: "those lines are somewhere on the page" is not the claim the page is making.
  readme_panel_is "…and c3-unit08/README.md's SECOND break panel prints the same two lines — the unit's headline is this panel, not the prose under it" \
      08 'java -cp build/classes/java/main com.tiffinbox.MenuCatalog' 2
  restore_all
  timed 1800 bash -c 'cd "$REPO/c3-unit08/breaks/undeclared-input" && GRADLE_USER_HOME="$GH08" ../../gradlew -q clean'

  # ---- the fixed task, one directory up, given the identical edit. --no-build-cache is in
  # the README's command on purpose: with the cache on, compileJava comes FROM-CACHE and the
  # capture stops being the one printed.
  expect_ok "the fixed task: clean, --no-build-cache build, then the same one-line edit" 1800 \
      '^3 actionable tasks: 3 executed$' \
      bash -c 'cd "$REPO/c3-unit08" && GRADLE_USER_HOME="$GH08" ./gradlew -q clean \
               && GRADLE_USER_HOME="$GH08" ./gradlew --no-build-cache -q build \
               && printf "Lentil Soup|VEGAN\n" >> src/main/menu/menu.txt \
               && GRADLE_USER_HOME="$GH08" ./gradlew --console=plain --no-build-cache build \
                  | grep -E "^> Task :(generateMenu|compileJava|jar)|actionable"'
  has "…:generateMenu ran, because this one declared its input" '^> Task :generateMenu$'
  expect_ok "…and the program now says menu items: 4" 300 '^menu items: 4$' \
      bash -c 'cd "$REPO/c3-unit08" && "$JAVA" "-D$TAG=u08" -cp build/classes/java/main com.tiffinbox.MenuCatalog'
  has "…[Grilled Chicken, Steamed Rice, Garden Salad, Lentil Soup]" \
      '^\[Grilled Chicken, Steamed Rice, Garden Salad, Lentil Soup\]$'
  readme_shows "…and c3-unit08/README.md's fixed panel prints those two lines, not a hash of them" 08
  restore_all
  timed 1800 bash -c 'cd "$REPO/c3-unit08" && GRADLE_USER_HOME="$GH08" ./gradlew --no-build-cache -q build'

  # ---- the jar, which no beat in this unit has opened.
  # Every program above runs from build/classes/java/main, so the shipped artifact is the one thing
  # unit 08 never looks at: append `tasks.jar { into("nested") }` to build.gradle.kts and the
  # MANIFEST and all six classes land under nested/, `java -cp` the jar answers
  # ClassNotFoundException — and all three task words, both `N executed / N up-to-date` counts, the
  # twelve skip reasons and all six receipt hashes are exactly what they were. Unit 07 has
  # class_hash and class_count over its jars; unit 08 had nothing.
  is "build/libs/tiffinbox-core-1.0.0.jar: its MANIFEST is at META-INF/MANIFEST.MF, where a JVM looks" \
     "$(unzip -Z1 "$J8" 2>/dev/null | grep -c '^META-INF/MANIFEST\.MF$' | tr -d ' ')" "1"
  is "…and every class in it is at com/tiffinbox/, not under a prefix" \
     "$(unzip -Z1 "$J8" 2>/dev/null | grep -c '^com/tiffinbox/.*\.class$' | tr -d ' ')" "$(class_count "$J8")"
  expect_ok "…and java -cp build/libs/tiffinbox-core-1.0.0.jar com.tiffinbox.MenuCatalog runs OUT OF THE JAR" 300 \
      '^menu items: 3$' \
      bash -c 'cd "$REPO/c3-unit08" && "$JAVA" "-D$TAG=u08" -cp build/libs/tiffinbox-core-1.0.0.jar com.tiffinbox.MenuCatalog'
  has "…and prints the three items the committed menu.txt holds" '^\[Grilled Chicken, Steamed Rice, Garden Salad\]$'

  # ---- the offline claim, as a pair in both projects
  expect_ok "./gradlew build — online first, into this unit's own Gradle home" 1800 'BUILD SUCCESSFUL' \
      bash -c 'cd "$REPO/c3-unit08" && GRADLE_USER_HOME="$GH08" ./gradlew --console=plain build'
  expect_ok "./gradlew --offline build -> BUILD SUCCESSFUL, 3 actionable tasks: 3 up-to-date" 1800 \
      '^3 actionable tasks: 3 up-to-date$' \
      bash -c 'cd "$REPO/c3-unit08" && GRADLE_USER_HOME="$GH08" ./gradlew --console=plain --offline build'
  expect_ok "breaks/undeclared-input: ../../gradlew build online, then --offline" 1800 'BUILD SUCCESSFUL' \
      bash -c 'cd "$REPO/c3-unit08/breaks/undeclared-input" && GRADLE_USER_HOME="$GH08" ../../gradlew --console=plain build \
               && GRADLE_USER_HOME="$GH08" ../../gradlew --console=plain --offline build'

  # ---- exercise: the other half of the pair — a hidden OUTPUT instead of a hidden input
  backup "$REPO/c3-unit08/exercise/build.gradle.kts"
  expect_ok "exercise: ../gradlew stamp, twice, unedited -> it runs twice" 1800 \
      '^1 actionable task: 1 executed$' \
      bash -c 'cd "$REPO/c3-unit08/exercise" && GRADLE_USER_HOME="$GH08" ../gradlew --console=plain stamp >/dev/null \
               && GRADLE_USER_HOME="$GH08" ../gradlew --console=plain stamp | grep -E "^> Task|actionable"'
  has "…> Task :stamp, with no UP-TO-DATE after it" '^> Task :stamp$'
  expect_ok "exercise: ../gradlew stamp --info | grep -A1 'not up-to-date' -> Gradle says why" 1800 \
      "^Task ':stamp' is not up-to-date because:$" \
      bash -c 'cd "$REPO/c3-unit08/exercise" && GRADLE_USER_HOME="$GH08" ../gradlew --console=plain stamp --info | grep -A1 "not up-to-date"'
  has "…'Task has not declared any outputs despite executing actions.'" \
      '^  Task has not declared any outputs despite executing actions\.$'
  # The file the unit hands the student as THE FIX is a deliverable in its own right, and the
  # beats below check only its behaviour: UP-TO-DATE, and stamp.txt on disk. Turn `@get:Input`
  # into `@get:Internal` and every one of those still passes — editing build.gradle.kts changes
  # the task's implementation classpath, so the task re-runs anyway and the missing declaration
  # never shows. What is lost is the thing the page is teaching, so it is read out of the file.
  SOL8="$REPO/c3-unit08/exercise/solution/build.gradle.kts"
  is "exercise solution: it declares its INPUT — grep -c '@get:Input' is 1" \
     "$(grep -c '^    @get:Input$' "$SOL8" | tr -d ' ')" "1"
  is "…and its OUTPUT — grep -c '@get:OutputFile' is 1; the unit is about both halves" \
     "$(grep -c '^    @get:OutputFile$' "$SOL8" | tr -d ' ')" "1"
  is "…and nothing in it is annotated @get:Internal, which is how a declared input stops being one" \
     "$(grep -c '@get:Internal' "$SOL8" | tr -d ' ')" "0"
  cp "$REPO/c3-unit08/exercise/solution/build.gradle.kts" "$REPO/c3-unit08/exercise/build.gradle.kts"
  expect_ok "exercise solution: declare the output, and the second run is UP-TO-DATE" 1800 \
      '^1 actionable task: 1 up-to-date$' \
      bash -c 'cd "$REPO/c3-unit08/exercise" && GRADLE_USER_HOME="$GH08" ../gradlew --console=plain stamp >/dev/null \
               && GRADLE_USER_HOME="$GH08" ../gradlew --console=plain stamp | grep -E "^> Task|actionable"'
  has "…> Task :stamp UP-TO-DATE" '^> Task :stamp UP-TO-DATE$'
  is "…and the output it now declares really is on disk" \
     "$(cat "$REPO/c3-unit08/exercise/build/stamp.txt" 2>/dev/null)" "tiffinbox"
  restore_all

  check_receipts 08 3600 6
  # receipts.sh appends a line to both menu.txt files and puts them back; prove it did.
  is "…and receipts.sh left src/main/menu/menu.txt at its committed three lines" \
     "$(wc -l <"$MENU" | tr -d ' ')" "3"
  is "…and breaks/undeclared-input/src/main/menu/menu.txt too" "$(wc -l <"$BMENU" | tr -d ' ')" "3"

  # ---- and the question check_receipts cannot ask: did the block do any work?
  # `three-states` is one of the six the README quotes, so check_receipts looks at it — but all it
  # can see is that the string receipts.sh printed equals the string README.md quotes. Delete the
  # whole block, `printf` that very number, and the two agree exactly while the three ./gradlew
  # builds the unit is named for are gone. The block writes its capture to /tmp/r08a.txt and hashes
  # THAT file; it can do neither without building, so ask the artifacts.
  rm -f /tmp/r08a.txt
  timed 1800 bash -c "cd \"$REPO/c3-unit08\" && GRADLE_USER_HOME=\"$GH08\" ./gradlew --no-build-cache -q clean"
  expect_ok "receipts.sh three-states, run on its own with build/ deleted" 1800 '^three-states ' \
      bash -c "cd \"$REPO/c3-unit08\" && GRADLE_USER_HOME=\"$GH08\" ./receipts.sh three-states"
  exists "…really BUILT the three states it describes: build/libs/tiffinbox-core-1.0.0.jar is back" "$J8"
  is "…and it wrote the three panels, one per state, into the capture it hashes" \
     "$(grep -c '^\$ \./gradlew ' /tmp/r08a.txt 2>/dev/null | tr -d ' ')" "3"
  is "…and the md5 it printed is the md5 of that capture, not a number pasted into the block" \
     "$(sed -n 's/^three-states  *\([0-9a-f]*\).*/\1/p' "$OUT" | head -1)" "$(md5of /tmp/r08a.txt 2>/dev/null)"
  rm -f /tmp/r08a.txt
  gstop "c3-unit08" "$REPO/c3-unit08" "$GH08"
fi

# ============================================================= c3-unit09 ====
if unit 09 "Configurations and the version catalog"; then
  wrapper_asserts "c3-unit09" "$REPO/c3-unit09" "$GH09"
  CORE9="$REPO/c3-unit09/tiffinbox-core/build.gradle.kts"
  backup "$CORE9"

  is "tiffinbox-core's five sources are c3-tiffinbox's, byte for byte" \
     "$(src_hash "$REPO/c3-unit09/tiffinbox-core/src/main/java/com/tiffinbox")" "fdb1643d622615f3c331d75deaebb9da"
  is "…and there are five of them, with nothing below the package directory the hash globs" \
     "$(src_files "$REPO/c3-unit09/tiffinbox-core/src/main/java")" "$FIVE_SRC"

  # ---- the catalog. The claim worth making is not "two version strings in the project" —
  # it is ZERO in any *.kts, with the four .toml hits named, exercise copy included.
  #
  # The README's printed command, its quoted output, its prose and receipts.sh `catalog`
  # now all run the SAME pipeline and all say four. (They did not: line 150 used to carry a
  # trailing `| grep -v './exercise'` left over from an earlier draft, so the command a
  # viewer copied returned two while everything under it said four. Repaired 2026-09-15,
  # and the assertions below are what stop it coming back — line 150 is READ OUT OF the
  # README and run, so this script keeps no copy of it to drift from.)
  timed 120 bash -c 'cd "$REPO/c3-unit09" && grep -rn "2\.5\.250\|2\.22\.2" --include="*.kts" --include="*.toml" . \
                     | grep -v "\./conflict" | sed "s|^\./||"'
  is "grep -rn '2.5.250|2.22.2' *.kts *.toml (conflict/ excluded) -> FOUR hits, not two" "$(countq '.')" "4"
  has "…gradle/libs.versions.toml:9:h2"        '^gradle/libs\.versions\.toml:9:h2 '
  has "…gradle/libs.versions.toml:10:jackson"  '^gradle/libs\.versions\.toml:10:jackson '
  has "…and the exercise's byte-identical copy, which the README refuses to filter out" \
      '^exercise/gradle/libs\.versions\.toml:9:h2 '
  has "…both lines of it" '^exercise/gradle/libs\.versions\.toml:10:jackson '
  hasnt "…and ZERO version strings in any *.kts outside conflict/ — the claim that was worth making" '\.kts:'
  # This half is about a line of a README, so the command is READ OUT OF that README and run —
  # this script keeps no copy of it. Both halves used to be re-typed pipelines, which means the
  # beat was a claim about verify_course3.sh and not about the deliverable: delete the
  # `| grep -v './exercise'` on line 150 (that is, REPAIR the mismatch the note above documents)
  # and the run went on printing "the command README.md line 150 actually prints returns TWO" over
  # a line that returns four.
  R150="$(grep -m1 '^grep -rn ' "$REPO/c3-unit09/README.md")"
  is "…README.md's version grep is still the line 150 this note names" \
     "$(grep -n '^grep -rn ' "$REPO/c3-unit09/README.md" | head -1 | cut -d: -f1)" "150"
  if printf '%s' "$R150" | grep -qF "grep -v './exercise'"; then
    bad "c3-unit09/README.md line 150" \
        "the './exercise' filter is back. It makes the printed command return two while the output, the prose and receipts.sh catalog all say four — and filtering a grep until it agrees with the claim above it is the one thing this unit's beat cannot survive. Line 150 now reads: $R150"
  else
    ok "…and it does NOT filter ./exercise — the exercise copy is a real hit and the page says so"
  fi
  timed 120 bash -c "cd \"$REPO/c3-unit09\" && $R150"
  is "…and running README.md line 150 itself, verbatim, returns FOUR — the same four receipts.sh prints" "$(countq '.')" "4"
  has "…including the exercise copy, unfiltered" '^exercise/gradle/libs\.versions\.toml:9:h2 '
  if cmp -s "$REPO/c3-unit09/gradle/libs.versions.toml" "$REPO/c3-unit09/exercise/gradle/libs.versions.toml"; then
    ok "…exercise/gradle/libs.versions.toml really is byte-identical to the catalog beside it"
  else
    bad "exercise/gradle/libs.versions.toml" "the README calls it a byte-identical copy; it is not"
  fi
  expect_ok "grep -n 'libs\.' tiffinbox-*/build.gradle.kts -> the two typed accessors" 60 \
      '^tiffinbox-core/build\.gradle\.kts:14: *api\(libs\.h2\)$' \
      bash -c 'cd "$REPO/c3-unit09" && grep -n "libs\." tiffinbox-core/build.gradle.kts tiffinbox-web/build.gradle.kts'
  has "…and tiffinbox-web's implementation(libs.jackson.databind)" \
      '^tiffinbox-web/build\.gradle\.kts:14: *implementation\(libs\.jackson\.databind\)$'

  # ---- one word in the OTHER module decides what this one may import.
  # `clean` first, so :tiffinbox-web:compileJava really compiles instead of reporting UP-TO-DATE.
  expect_ok "api(libs.h2): ./gradlew :tiffinbox-web:compileJava -> it compiles" 1800 \
      '^> Task :tiffinbox-web:compileJava$' \
      bash -c 'cd "$REPO/c3-unit09" && GRADLE_USER_HOME="$GH09" ./gradlew --console=plain -q clean >/dev/null \
               && GRADLE_USER_HOME="$GH09" ./gradlew --console=plain :tiffinbox-web:compileJava'
  has "…BUILD SUCCESSFUL" '^BUILD SUCCESSFUL'
  sed -i '' 's/^    api(libs.h2)$/    implementation(libs.h2)/' "$CORE9"
  if grep -q '^    implementation(libs.h2)$' "$CORE9"; then
    ok "…flip ONE word in tiffinbox-core: api -> implementation"
  else
    bad "sed api -> implementation" "the edit did not apply to $CORE9"
  fi
  expect_fail "implementation(libs.h2): the same command now FAILS to compile" 1800 \
      'error: package org\.h2\.jdbcx does not exist' \
      bash -c 'cd "$REPO/c3-unit09" && GRADLE_USER_HOME="$GH09" ./gradlew --console=plain -q clean >/dev/null \
               && GRADLE_USER_HOME="$GH09" ./gradlew --console=plain :tiffinbox-web:compileJava'
  has "…> Task :tiffinbox-web:compileJava FAILED" '^> Task :tiffinbox-web:compileJava FAILED$'
  has "…HealthCheck.java:15: cannot find symbol" 'HealthCheck\.java:15: error: cannot find symbol'
  has "…symbol: class JdbcDataSource" 'symbol: *class JdbcDataSource'
  has "…3 errors" '^ *3 errors$'
  has "…BUILD FAILED" '^BUILD FAILED'

  # ---- implementation hides it from the compiler, and from the compiler alone
  expect_ok "…:tiffinbox-web:dependencies --configuration compileClasspath: H2 is GONE" 1800 \
      "^compileClasspath - Compile classpath for source set 'main'\.$" \
      bash -c 'cd "$REPO/c3-unit09" && GRADLE_USER_HOME="$GH09" ./gradlew --console=plain -q :tiffinbox-web:dependencies --configuration compileClasspath'
  hasnt "…no com.h2database:h2 on the compile classpath — that is the whole mechanism" 'com\.h2database:h2'
  expect_ok "…:tiffinbox-web:dependencies --configuration runtimeClasspath: H2 is still THERE" 1800 \
      'com\.h2database:h2:2\.5\.250' \
      bash -c 'cd "$REPO/c3-unit09" && GRADLE_USER_HOME="$GH09" ./gradlew --console=plain -q :tiffinbox-web:dependencies --configuration runtimeClasspath'
  restore_all
  if grep -q '^    api(libs.h2)$' "$CORE9"; then
    ok "…and the flip is put back: tiffinbox-core says api(libs.h2) again"
  else
    bad "restore api(libs.h2)" "$CORE9 was left flipped"
  fi
  expect_ok "api(libs.h2): H2 is back on the compile classpath, three of four reports carry it" 1800 \
      'com\.h2database:h2:2\.5\.250' \
      bash -c 'cd "$REPO/c3-unit09" && GRADLE_USER_HOME="$GH09" ./gradlew --console=plain -q :tiffinbox-web:dependencies --configuration compileClasspath'

  # ---- the runtime half, run rather than asserted: `health` is a JavaExec on runtimeClasspath
  expect_ok "./gradlew -q health -> health: ok (the driver really is on the runtime classpath)" 1800 \
      '^health: ok$' \
      bash -c 'cd "$REPO/c3-unit09" && GRADLE_USER_HOME="$GH09" ./gradlew --console=plain -q health'

  # ---- same two lines, two different answers
  expect_ok "conflict: mvn -B dependency:tree | grep jackson-core:jar -> Maven takes the NEAREST" 1800 \
      '\\- com\.fasterxml\.jackson\.core:jackson-core:jar:2\.13\.5:compile' \
      bash -c 'cd "$REPO/c3-unit09/conflict" && mvn -B "-Dmaven.repo.local=$M2_U09C" dependency:tree 2>&1 | grep "jackson-core:jar"'
  expect_ok "conflict: ../gradlew dependencies --configuration runtimeClasspath -> Gradle takes the HIGHEST" 1800 \
      '^\\--- com\.fasterxml\.jackson\.core:jackson-core:2\.13\.5 -> 2\.22\.2 \(\*\)$' \
      bash -c 'cd "$REPO/c3-unit09/conflict" && GRADLE_USER_HOME="$GH09" ../gradlew --console=plain -q dependencies --configuration runtimeClasspath 2>&1 \
               | grep -E "^.--- com.fasterxml.jackson.core:jackson-core"'

  # ---- the README's two offline claims, each proved as a pair
  offline_receipt 'conflict: mvn -o -B verify -Dmaven.repo.local="$PWD/.m2-demo"' 1800 \
      "$REPO/c3-unit09/conflict" "$M2_U09C"
  expect_ok "./gradlew build — online first, into this unit's own Gradle home" 1800 'BUILD SUCCESSFUL' \
      bash -c 'cd "$REPO/c3-unit09" && GRADLE_USER_HOME="$GH09" ./gradlew --console=plain build'
  expect_ok "./gradlew --offline build -> BUILD SUCCESSFUL, 7 actionable tasks: 7 up-to-date" 1800 \
      '^7 actionable tasks: 7 up-to-date$' \
      bash -c 'cd "$REPO/c3-unit09" && GRADLE_USER_HOME="$GH09" ./gradlew --console=plain --offline build'

  # ---- exercise: declare what you use, and do NOT reach for api
  WEB9X="$REPO/c3-unit09/exercise/tiffinbox-web/build.gradle.kts"
  backup "$WEB9X"
  is "exercise: tiffinbox-core's sources are the same five again" \
     "$(src_hash "$REPO/c3-unit09/exercise/tiffinbox-core/src/main/java/com/tiffinbox")" "fdb1643d622615f3c331d75deaebb9da"
  is "…and five is how many there are, here too" \
     "$(src_files "$REPO/c3-unit09/exercise/tiffinbox-core/src/main/java")" "$FIVE_SRC"
  is "exercise: grep -c 'api(' tiffinbox-core/build.gradle.kts -> 0, and it must stay 0" \
     "$(grep -c 'api(' "$REPO/c3-unit09/exercise/tiffinbox-core/build.gradle.kts" | tr -d ' ')" "0"
  expect_fail "exercise: ../gradlew :tiffinbox-web:compileJava unedited -> FAILED" 1800 \
      'HealthCheck\.java:4: error: package org\.h2\.jdbcx does not exist' \
      bash -c 'cd "$REPO/c3-unit09/exercise" && GRADLE_USER_HOME="$GH09" ../gradlew --console=plain :tiffinbox-web:compileJava'
  has "…> Task :tiffinbox-web:compileJava FAILED" '^> Task :tiffinbox-web:compileJava FAILED$'
  has "…3 errors" '^ *3 errors$'
  cp "$REPO/c3-unit09/exercise/solution/tiffinbox-web.build.gradle.kts" "$WEB9X"
  expect_ok "exercise solution: the web module declares the H2 it uses -> BUILD SUCCESSFUL" 1800 \
      '^> Task :tiffinbox-web:compileJava$' \
      bash -c 'cd "$REPO/c3-unit09/exercise" && GRADLE_USER_HOME="$GH09" ../gradlew --console=plain :tiffinbox-web:compileJava'
  has "…BUILD SUCCESSFUL" '^BUILD SUCCESSFUL'
  is "…and the other fix was NOT taken: grep -c 'api(' on core is still 0" \
     "$(grep -c 'api(' "$REPO/c3-unit09/exercise/tiffinbox-core/build.gradle.kts" | tr -d ' ')" "0"
  restore_all

  check_receipts 09 3600 5
  # receipts.sh flips tiffinbox-core between api and implementation while it works.
  if grep -q '^    api(libs.h2)$' "$CORE9"; then
    ok "…and receipts.sh put tiffinbox-core back to api(libs.h2), as its header promises"
  else
    bad "receipts.sh left the flip in place" "$CORE9 does not say api(libs.h2)"
  fi
  gstop "c3-unit09" "$REPO/c3-unit09" "$GH09"
fi

# ============================================================= c3-unit10 ====
if unit 10 "Maven or Gradle: the same project, both tools"; then
  wrapper_asserts "c3-unit10" "$REPO/c3-unit10" "$GH10"
  GWP10="$REPO/c3-unit10/gradle/wrapper/gradle-wrapper.properties"
  GWP10X="$REPO/c3-unit10/exercise/gradle/wrapper/gradle-wrapper.properties"
  backup "$GWP10"; backup "$GWP10X"

  # ---- a comparison between two tools is worth nothing if the two sides differ
  for F in pom.xml tiffinbox-core/pom.xml tiffinbox-web/pom.xml; do
    if cmp -s "$REPO/c3-unit10/$F" "$REPO/c3-tiffinbox/$F"; then
      ok "$F is byte-identical to ../c3-tiffinbox/$F"
    else
      bad "$F" "the README says byte-identical to ../c3-tiffinbox/$F; it is not"
    fi
  done
  is "md5 -q pom.xml -> the hash the README quotes" "$(md5of "$REPO/c3-unit10/pom.xml")" "4303ad02dc14f99ac2213baabb3c8999"
  is "md5 -q tiffinbox-core/pom.xml" "$(md5of "$REPO/c3-unit10/tiffinbox-core/pom.xml")" "2bf4a5b3bd375cbbdbb148692cc5a7e5"
  is "md5 -q tiffinbox-web/pom.xml"  "$(md5of "$REPO/c3-unit10/tiffinbox-web/pom.xml")"  "f8736191a4900ae1a76d1fcdf744c4ab"
  timed 60 diff -r "$REPO/c3-unit10/tiffinbox-core/src" "$REPO/c3-tiffinbox/tiffinbox-core/src"
  is "diff -r tiffinbox-core/src -> no differences at all" "$RC" "0"
  timed 60 diff -r "$REPO/c3-unit10/tiffinbox-web/src" "$REPO/c3-tiffinbox/tiffinbox-web/src"
  is "diff -r tiffinbox-web/src -> no differences at all (seven Java files, shared by both builds)" "$RC" "0"

  # ---- the Maven wrapper is committed too, and pins a version (not a checksum: that is the point)
  if [ -x "$REPO/c3-unit10/mvnw" ] && [ -f "$REPO/c3-unit10/.mvn/wrapper/maven-wrapper.properties" ]; then
    ok "mvnw + .mvn/wrapper/ are committed, and mvnw is executable"
  else
    bad "the Maven wrapper" "mvnw or .mvn/wrapper/maven-wrapper.properties is missing"
  fi
  timed 60 cat "$REPO/c3-unit10/.mvn/wrapper/maven-wrapper.properties"
  has "…and it pins Maven 3.9.16 by URL" 'distributionUrl=.*apache-maven/3\.9\.16/apache-maven-3\.9\.16-bin\.zip'
  hasnt "…by URL and NOT by checksum — that asymmetry is what unit 10 is about" '[Ss]ha256'
  expect_ok 'MAVEN_USER_HOME="$PWD/.m2-demo" ./mvnw -v -> Apache Maven 3.9.16, fetched beside the project' 1800 \
      '^Apache Maven 3\.9\.16 ' \
      bash -c 'cd "$REPO/c3-unit10" && MAVEN_USER_HOME="$M2_U10" ./mvnw -v'
  has "…and its Maven home is under .m2-demo, never ~/.m2" 'Maven home: .*/\.m2-demo/wrapper/dists/apache-maven-3\.9\.16'
  has "…running on the JDK 25 this script validated" '^Java version: 25\.'

  # ---- build it twice
  expect_ok "mvn -B clean package (the Maven build)" 1800 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit10" && mvn -B "-Dmaven.repo.local=$M2_U10" clean package'
  expect_ok "./gradlew clean build (the Gradle build, same sources)" 1800 'BUILD SUCCESSFUL' \
      bash -c 'cd "$REPO/c3-unit10" && GRADLE_USER_HOME="$GH10" ./gradlew --console=plain clean build'
  LIBS="$(cd "$REPO/c3-unit10/tiffinbox-web/target/lib" 2>/dev/null && ls | sort | tr '\n' ' ')"
  is "ls tiffinbox-web/target/lib -> five jars" "$LIBS" \
     "h2-2.5.250.jar jackson-annotations-2.22.jar jackson-core-2.22.2.jar jackson-databind-2.22.2.jar tiffinbox-core-1.0.0.jar "
  is "ls tiffinbox-web/build/libs/lib -> the same five names" \
     "$(cd "$REPO/c3-unit10/tiffinbox-web/build/libs/lib" 2>/dev/null && ls | sort | tr '\n' ' ')" "$LIBS"
  CH="$(class_hash "$REPO/c3-unit10/tiffinbox-web/target/tiffinbox-web-1.0.0.jar")"
  is "the web jar's class content, out of Maven" "$CH" "cb46ca054c40d14146a9e8579b4b1ff3"
  is "…and out of Gradle, identical" "$(class_hash "$REPO/c3-unit10/tiffinbox-web/build/libs/tiffinbox-web-1.0.0.jar")" "$CH"
  is "the core jar's class content is the SAME hash c3-unit07 and c3-unit09 produce" \
     "$(class_hash "$REPO/c3-unit10/tiffinbox-core/target/tiffinbox-core-1.0.0.jar")" "8bd6fdb961f65dddc82a242e5472059c"
  is "…from the Gradle jar too — five jars in this repository, one class-content hash" \
     "$(class_hash "$REPO/c3-unit10/tiffinbox-core/build/libs/tiffinbox-core-1.0.0.jar")" "8bd6fdb961f65dddc82a242e5472059c"

  # ---- both jars are runnable, and print the same four lines. The README's command takes no
  # port argument, so the server takes its default 18425 — the port unit 10's receipts.sh
  # hard-codes as well, which is why this is guarded rather than parameterised.
  if port_busy "$PORT10"; then
    skip "java -jar tiffinbox-web-1.0.0.jar, from both builds" "port $PORT10 is already in use"
  else
    for J in target/tiffinbox-web-1.0.0.jar build/libs/tiffinbox-web-1.0.0.jar; do
      ( cd "$REPO/c3-unit10/tiffinbox-web" && "$JAVA" "-D$TAG=u10" \
          -Djava.util.logging.config.file=logging.properties -jar "$J" ) >"$WORK/u10.log" 2>&1 &
      S10=$!
      if wait_port_up "$PORT10"; then
        cp "$WORK/u10.log" "$OUT"
        has "java -jar $J -> orders cooked: 120"  'orders cooked: +120'
        has "…kitchen value: 24300"               'kitchen value: +24300'
        has "…routes mapped: the five routes"     'routes mapped: +\[GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown\]'
        has "…TiffinBox listening on http://127.0.0.1:$PORT10" "TiffinBox listening on http://127\.0\.0\.1:$PORT10"
        curl -s -m 10 -X POST "http://127.0.0.1:$PORT10/shutdown" >/dev/null 2>&1
      else
        cp "$WORK/u10.log" "$OUT"; bad "java -jar $J" "the server never came up"
      fi
      for _ in $(seq 1 60); do kill -0 "$S10" 2>/dev/null || break; sleep 0.25; done
      kill -9 "$S10" >/dev/null 2>&1; wait "$S10" 2>/dev/null
      pkill -9 -f "$TAG=u10" >/dev/null 2>&1
      if wait_port_free "$PORT10"; then ok "…port $PORT10 free again after POST /shutdown"
      else bad "port $PORT10" "still in LISTEN after the $J server"; fi
    done
  fi

  # ---- the comparison table, row by row. Every Maven number is `mvn -o` and every Gradle
  # one is `--offline --no-build-cache`, exactly as the README's flags say — and the online
  # builds above are what earns those offline runs the right to be measured at all.
  expect_ok "mvn -o -B clean package | grep -c '^\[INFO\] --- ' -> 16 goals in a clean build" 1800 '' \
      bash -c 'cd "$REPO/c3-unit10" && mvn -o -B "-Dmaven.repo.local=$M2_U10" clean package | grep -cE "^\[INFO\] --- "'
  is "…16" "$(tr -d ' \n' <"$OUT")" "16"
  expect_ok "mvn -o -B package | grep -c '^\[INFO\] --- ' -> 13 goals when nothing changed" 1800 '' \
      bash -c 'cd "$REPO/c3-unit10" && mvn -o -B "-Dmaven.repo.local=$M2_U10" package | grep -cE "^\[INFO\] --- "'
  is "…13" "$(tr -d ' \n' <"$OUT")" "13"
  expect_ok "mvn -o -B package | grep -c 'Nothing to compile' -> 2 goals said so out loud" 1800 '' \
      bash -c 'cd "$REPO/c3-unit10" && mvn -o -B "-Dmaven.repo.local=$M2_U10" package | grep -c "Nothing to compile"'
  is "…2 of 13, and the other eleven leave you to infer it" "$(tr -d ' \n' <"$OUT")" "2"
  expect_ok "./gradlew --offline --no-build-cache clean build | grep -c '^> Task ' -> 25 tasks" 1800 '' \
      bash -c 'cd "$REPO/c3-unit10" && GRADLE_USER_HOME="$GH10" ./gradlew --console=plain --offline --no-build-cache clean build | grep -c "^> Task "'
  is "…25" "$(tr -d ' \n' <"$OUT")" "25"
  # …and now the no-change state, built into first, which is what rows 2-4 are about.
  timed 1800 bash -c 'cd "$REPO/c3-unit10" && GRADLE_USER_HOME="$GH10" ./gradlew --console=plain --offline --no-build-cache build'
  expect_ok "./gradlew --offline --no-build-cache build (nothing changed) -> 23 task lines" 1800 \
      '^5 actionable tasks: 5 up-to-date$' \
      bash -c 'cd "$REPO/c3-unit10" && GRADLE_USER_HOME="$GH10" ./gradlew --console=plain --offline --no-build-cache build'
  is "…23 task lines" "$(countq '^> Task ')" "23"
  is "…15 of them UP-TO-DATE" "$(countq 'UP-TO-DATE')" "15"
  is "…8 NO-SOURCE — 23 of 23 labelled, against Maven's 2 of 13" "$(countq 'NO-SOURCE')" "8"
  has "…and one line that says what the whole build did, which Maven prints nowhere" \
      '^5 actionable tasks: 5 up-to-date$'

  # ---- the configuration-line rows, which are pure file arithmetic
  N="$(cat "$REPO/c3-unit10/pom.xml" "$REPO/c3-unit10/tiffinbox-core/pom.xml" "$REPO/c3-unit10/tiffinbox-web/pom.xml" | wc -l | tr -d ' ')"
  is "wc -l over the three POMs -> 183 raw lines" "$N" "183"
  N="$(cat "$REPO/c3-unit10/settings.gradle.kts" "$REPO/c3-unit10/build.gradle.kts" \
           "$REPO/c3-unit10/gradle/libs.versions.toml" "$REPO/c3-unit10/tiffinbox-core/build.gradle.kts" \
           "$REPO/c3-unit10/tiffinbox-web/build.gradle.kts" | wc -l | tr -d ' ')"
  is "…and over the five Gradle files -> 59" "$N" "59"
  if command -v perl >/dev/null 2>&1; then
    N="$(cat "$REPO/c3-unit10/pom.xml" "$REPO/c3-unit10/tiffinbox-core/pom.xml" "$REPO/c3-unit10/tiffinbox-web/pom.xml" \
         | perl -0pe 's/<!--.*?-->//gs' | grep -c '\S' | tr -d ' ')"
    is "…comments stripped (XML comments span lines, so a line-wise grep cannot do it) -> 155" "$N" "155"
  else
    skip "the comment-stripped Maven line count" "no perl on this machine to strip multi-line XML comments"
  fi
  N="$(cat "$REPO/c3-unit10/settings.gradle.kts" "$REPO/c3-unit10/build.gradle.kts" \
           "$REPO/c3-unit10/gradle/libs.versions.toml" "$REPO/c3-unit10/tiffinbox-core/build.gradle.kts" \
           "$REPO/c3-unit10/tiffinbox-web/build.gradle.kts" | grep -vE '^\s*$|^\s*//|^\s*#' | grep -c . | tr -d ' ')"
  is "…and the same rule on the Gradle side -> 43" "$N" "43"

  # ---- the pin. TWO assertions, and the second is the reason the first needs a fresh home.
  sed -i '' 's/^distributionSha256Sum=acd/distributionSha256Sum=bcd/' "$GWP10"
  if grep -q '^distributionSha256Sum=bcd' "$GWP10"; then
    ok "sed one character of distributionSha256Sum: acd… -> bcd…"
  else
    bad "sed the checksum" "the edit did not apply to $GWP10"
  fi
  expect_ok "…and against the WARM Gradle home it runs anyway: the pin is checked on DOWNLOAD only" 1800 \
      "^Gradle 9\.7\.1\$" \
      bash -c 'cd "$REPO/c3-unit10" && GRADLE_USER_HOME="$GH10" ./gradlew --console=plain -q --version'
  restore_all
  is "…the real checksum is back" \
     "$(grep '^distributionSha256Sum=' "$GWP10")" "distributionSha256Sum=$GRADLE_DIST_SHA256"
  # The fresh-home half — the one that actually bites — is receipts.sh `shapin` below, and the
  # exercise repeats it on its own wrapper. Neither can pass on a warm home, which is the point.

  # ---- the drift break: a machine with a different tool. It needs a SECOND distribution, which
  # only the operator can supply; without one this SKIPS out loud rather than passing quietly.
  if [ -n "${OLD_GRADLE:-}" ] && [ -x "${OLD_GRADLE:-}" ]; then
    expect_ok "drift: \$OLD_GRADLE --version -> an older Gradle really is what is on the PATH here" 1800 \
        '^Gradle ' bash -c 'cd "$REPO/c3-unit10" && GRADLE_USER_HOME="$REPO/c3-unit10/.gh-old" "$OLD_GRADLE" --console=plain -q --version'
    hasnt "…and it is NOT the 9.7.1 the project names" '^Gradle 9\.7\.1$'
    expect_fail "drift: typing \`gradle build\` instead of \`./gradlew build\` -> it FAILS" 1800 \
        'What went wrong' \
        bash -c 'cd "$REPO/c3-unit10" && GRADLE_USER_HOME="$REPO/c3-unit10/.gh-old" "$OLD_GRADLE" --console=plain build'
    has "…and the entire 'what went wrong' is the JDK version string it cannot parse" \
        '^25\.[0-9.]+$'
    ( cd "$REPO/c3-unit10" && GRADLE_USER_HOME="$REPO/c3-unit10/.gh-old" "$OLD_GRADLE" --stop ) >/dev/null 2>&1
    expect_ok "drift: the next line of the same session, same directory, with ./gradlew" 1800 \
        '^BUILD SUCCESSFUL' \
        bash -c 'cd "$REPO/c3-unit10" && GRADLE_USER_HOME="$GH10" ./gradlew --console=plain --offline build'
  else
    skip "drift: an older Gradle against this project" \
         "set OLD_GRADLE=/path/to/an/older/gradle/bin/gradle to run the break beat for real"
  fi
  # The drift block is the one break beat in units 07-10 that nothing runs in the default envelope,
  # and a block that never runs is a block whose CONTENTS nobody reads. Point its "what went wrong"
  # capture at the project's own ./gradlew — 9.7.1, which succeeds — and the break becomes
  # structurally incapable of breaking, while a default run's assertion list is byte-identical to a
  # pristine one. The behaviour needs a second distribution; the wiring does not.
  D10="$(sed -n '/^if sel drift;/,/^fi$/p' "$REPO/c3-unit10/receipts.sh")"
  is "receipts.sh drift: the 'what went wrong' capture is taken from \$OLD_GRADLE — a drift break run with the project's own 9.7.1 cannot break" \
     "$(printf '%s\n' "$D10" | grep -c 'OLD_GRADLE.*--console=plain build.*What went wrong' | tr -d ' ')" "1"
  is "…and so is the version line above it, which is what makes the two halves a comparison" \
     "$(printf '%s\n' "$D10" | grep -c 'OLD_GRADLE.*--version' | tr -d ' ')" "1"
  is "…three \$OLD_GRADLE invocations in the block: --version, build, --stop" \
     "$(printf '%s\n' "$D10" | grep -c '"\$OLD_GRADLE"' | tr -d ' ')" "3"
  is "…and exactly TWO ./gradlew commands in it, which are the OTHER half — 'the next line of the same session'" \
     "$(printf '%s\n' "$D10" | grep -c '^ *\./gradlew --console=plain' | tr -d ' ')" "2"

  # ---- exercise: pin the distribution, then prove the pin bites
  is "exercise: the shipped wrapper properties are MISSING the line -> grep -c is 0" \
     "$(grep -c 'distributionSha256Sum' "$GWP10X" | tr -d ' ')" "0"
  expect_ok "exercise: unpinned, ./gradlew --version still runs (nothing checks what is not declared)" 1800 \
      "^Gradle 9\.7\.1\$" \
      bash -c 'cd "$REPO/c3-unit10/exercise" && GRADLE_USER_HOME="$GH10" ./gradlew --console=plain -q --version'
  cp "$REPO/c3-unit10/exercise/solution/gradle-wrapper.properties" "$GWP10X"
  is "exercise solution: the pin is the DISTRIBUTION's published checksum" \
     "$(grep '^distributionSha256Sum=' "$GWP10X")" "distributionSha256Sum=$GRADLE_DIST_SHA256"
  if grep -q "$GRADLE_WRAPPER_JAR_SHA256" "$GWP10X"; then
    bad "exercise solution" "it pins the WRAPPER JAR's checksum, which is the mistake the exercise is shaped around"
  else
    ok "…and not the wrapper jar's 7a9ce74c…, which is the mistake the exercise is shaped around"
  fi
  expect_ok "exercise solution: pinned correctly, ./gradlew --version prints Gradle 9.7.1" 1800 \
      "^Gradle 9\.7\.1\$" \
      bash -c 'cd "$REPO/c3-unit10/exercise" && GRADLE_USER_HOME="$GH10" ./gradlew --console=plain -q --version'
  # …and now the end state the exercise asks for: one character wrong, and a Gradle home that
  # has NEVER held this distribution. This downloads ~130 MB and then refuses to use it.
  sed -i '' 's/^distributionSha256Sum=acd/distributionSha256Sum=bcd/' "$GWP10X"
  rm -rf "$GH10X"
  expect_fail "exercise end state: wrong pin + a Gradle home that never held 9.7.1 -> it REFUSES" 1800 \
      'Verification of Gradle distribution failed!' \
      bash -c 'cd "$REPO/c3-unit10/exercise" && GRADLE_USER_HOME="$GH10X" ./gradlew --console=plain -q --version'
  has "…Expected checksum: the bcd… one that was typed" "Expected checksum: *'bcd53f1edaf02f1a8ff99879f8a34b302661a057d9b063ae9e35b552f804d20a'"
  has "…Actual checksum: the acd… one the real zip has"  "Actual checksum: *'$GRADLE_DIST_SHA256'"
  has "…and it names the distribution it was refusing" 'Distribution Url: https://services\.gradle\.org/distributions/gradle-9\.7\.1-bin\.zip'
  rm -rf "$GH10X"
  restore_all
  is "…and the exercise wrapper is back to the unpinned file that ships" \
     "$(grep -c 'distributionSha256Sum' "$GWP10X" | tr -d ' ')" "0"

  # ---- receipts.sh. `probe` starts the server on 18425 twice and `shapin` downloads a whole
  # distribution into a throw-away home to prove the pin bites where it is supposed to.
  if port_busy "$PORT10"; then
    skip "c3-unit10/receipts.sh" "its probe block hard-codes port $PORT10, and something is on it"
  else
    check_receipts 10 5400 9
    for ID in "probe 5da5f0f66da7105f322537b77751a0ea" "samejars-cls cb46ca054c40d14146a9e8579b4b1ff3"; do
      RID="${ID%% *}"; RHASH="${ID##* }"
      # these two the README quotes in prose rather than in the `→ md5 …` shape the pair
      # reader above understands, so they are checked in both directions by hand: the script
      # printed it, and README.md really does carry that number.
      if grep -qE "^$RID +$RHASH" "$WORK/receipts.10" 2>/dev/null; then
        ok "…receipts.sh $RID -> md5 $RHASH, for BOTH jars"
      else
        cp "$WORK/receipts.10" "$OUT" 2>/dev/null
        bad "receipts.sh $RID" "expected md5 $RHASH"
      fi
      if grep -qF "$RHASH" "$REPO/c3-unit10/README.md"; then
        ok "…and c3-unit10/README.md quotes $RHASH"
      else
        bad "c3-unit10/README.md" "it does not quote the $RID hash $RHASH that receipts.sh prints"
      fi
    done
    if [ -z "${OLD_GRADLE:-}" ]; then
      if grep -qE '^stacktrace +skipped - set OLD_GRADLE=' "$WORK/receipts.10" 2>/dev/null; then
        ok "…receipts.sh stacktrace — the other block that needs a second distribution, and it says so"
      else
        cp "$WORK/receipts.10" "$OUT" 2>/dev/null
        bad "receipts.sh stacktrace" "expected 'stacktrace  skipped - set OLD_GRADLE=…'"
      fi
    fi
    if wait_port_free "$PORT10"; then ok "…and receipts.sh left port $PORT10 free"
    else bad "port $PORT10" "receipts.sh probe left a server in LISTEN"; fi
  fi
  is "…receipts.sh shapin edits gradle-wrapper.properties and puts it back: it did" \
     "$(grep '^distributionSha256Sum=' "$GWP10")" "distributionSha256Sum=$GRADLE_DIST_SHA256"
  gstop "c3-unit10" "$REPO/c3-unit10" "$GH10"
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
# The Gradle half of the same promise. Units 07-10 export GRADLE_USER_HOME into the unit,
# so the shared home has to be the listing it was before the run — count first, because a
# count that moved says more in the failure line than a hash that moved.
is "~/.gradle holds the same number of entries as before the run" "$(gradle_home_count)" "$GRADLE_N_BEFORE"
is "…and the same listing, hashed" "$(gradle_home_hash)" "$GRADLE_H_BEFORE"
OURD=""
for g in "$GH07" "$GH08" "$GH09" "$GH10" "$GH10X" "$REPO/c3-unit10/.gh-old" "$REPO/c3-unit10/.gh-fresh"; do
  pgrep -f "$g/wrapper/dists" >/dev/null 2>&1 && OURD="$OURD $g"
done
if [ -z "$OURD" ]; then
  ok "no Gradle daemon of this run is left alive (every group ended with ./gradlew --stop)"
else
  bad "a Gradle daemon survived the run" "still running under:$OURD"
fi
GD="$(pgrep -f GradleDaemon 2>/dev/null | tr '\n' ' ')"
[ -n "$GD" ] && printf '  %sNOTE%s  GradleDaemon pids from somewhere else are running and were left alone: %s\n' "$YLW" "$OFF" "$GD"
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
      c3-unit0[1-9]|c3-unit10|c3-tiffinbox) continue ;;
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
