#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# verify_course3.sh — runs every command the Build & Test Like a Pro (`c3-*`)
# READMEs give a viewer, and says PASS/FAIL for each one.
#
#   ./verify_course3.sh                 # every c3-* folder that exists
#   ./verify_course3.sh 03 06           # only those units
#   ./verify_course3.sh 08 10           # the Gradle ones
#   ./verify_course3.sh 11 17           # the testing ones (Section 3)
#   ./verify_course3.sh 19 22           # the logging & measurement ones (Section 4)
#   ./verify_course3.sh 23 28           # the shipping ones (Section 5)
#   ./verify_course3.sh tiffinbox       # only c3-tiffinbox (that is unit 05's code)
#   SKIP_SLOW=1 ./verify_course3.sh     # skip the repeated-build hash loops AND the
#                                       #   second JMH sweep in unit 22
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
# Sections 4 and 5 need five more things, and every one of them is asserted rather
# than assumed — a missing one is a labelled SKIP, never a silent pass:
#   * `jq`            — c3-unit21's own receipts.sh refuses to run without it
#   * `ruby`          — c3-unit25 hands its workflow to a YAML parser
#   * `python3`       — c3-unit25/27/28 parse json and import the series module
#   * a **JDK 26** at /opt/homebrew/opt/openjdk@26 (JDK26= overrides) — c3-unit25's
#     matrix runs both legs for real and its receipts.sh dies rather than fake one
#   * `git`, and `~/Desktop/PromptVidya-Automation/java3_series.py` — c3-unit24
#     reads the repository it ships in, and c3-unit28 imports its own unit count
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
#   5. **In Section 3 a green build is never the evidence.** Units 11-18 are about tests
#      that pass for the wrong reason, so `BUILD SUCCESS` under a break beat is the thing
#      being warned about and can never be what proves the beat. Unit 11's three green
#      tests are checked by RUNNING the Customer they cover and reading 7440 back where
#      7200 belongs; unit 14's two green `verify` calls by running BillingService against a
#      recording gateway and reading 120 back where the month is 7200; unit 17's green
#      `naive-argline` build by the absence of `target/jacoco.exec` and the 0 files under
#      `target/site/`. And every one of those breaks is asserted to STILL BREAK, with the
#      exit code its receipts.sh prints — fix unit 11's 31-day month or unit 17's `>` and
#      the build improves while the video becomes wrong, which is a failure, not a pass.
#      The one number this script refuses to assert is unit 16's flake rate: that README
#      says out loud that it could not be measured, so what is held is the claim the page
#      makes rather than a figure it declined to give.
#
#   6. **In Section 4 a log line carries a clock, so a capture is masked before it is
#      hashed.** Units 19-22 each ship a `mask_time()`/`mask()` and every hash they quote
#      is over the masked capture — `<time>`, `<project>/`, `<home>/`. This script never
#      re-implements those filters: it runs the unit's own receipts.sh and compares the
#      line it printed with the line the deck quotes, and where a README prints a panel it
#      compares that panel against the block's own body. Unit 22 is the one unit in the
#      course whose subject is a duration, and the split it makes is the thing asserted:
#      four of its eight blocks print `no md5:` and a reason, and this script asserts that
#      they still do. **A block that started hashing a score would be the defect**, not an
#      improvement, so the count of unhashed blocks is checked in both directions.
#
#   7. **Section 5 has three units whose subject is something that DOES NOT EXIST here,
#      and they are held to exactly that.**
#        * **c3-unit27 ships no native binary.** `native-image` is not on this PATH and
#          `cc`, `ld` and `xcrun` all answer **69** — the Xcode licence. So the script
#          asserts that the `native` profile's failure is the PLUGIN's own documented
#          refusal (not a typo, not a missing dependency), that `cc` and `ld` really do
#          exit 69, and — the assertion that keeps the page honest — that **no binary
#          size, no start-up time and no throughput number appears anywhere in that
#          unit's README**. A fabricated "12 MB, 8 ms" would move no hash in that unit.
#        * **c3-unit25 ships no GitHub Actions run log.** There is no `.github/workflows/`
#          in this repository and `gh run list` returns nothing, so the script asserts the
#          unit's own capture of that state, asserts there is still no workflow directory,
#          and runs every command the shipped workflow runs — locally, on both JDKs.
#        * **c3-unit24 must never write to the shipped repository.** Its subject is git.
#          Every demonstration happens in a throwaway repo under `c3-unit24/.repos/`, and
#          the script takes HEAD, the commit count, the ref list and a content fingerprint
#          of `.git` BEFORE its receipts run and asserts all four unchanged after.
#
#      **And four hashes in Section 5 are deliberately NOT fixed, so this script does not
#      demand that they be.** `u28-ship` moves because the AOT class count moves run to
#      run (three runs here gave 2070 · 2071 · 2070); `u24-convention`, `u24-realrepo` and
#      `u28-gaps` are live snapshots of a repository that grows, and each one prints that
#      instruction in its own output. For all four the STRUCTURE and the derived arithmetic
#      are asserted — six steps and seven zeros, `4 named / 3 closed / 1 handed on`, the
#      counts adding up — and the figure itself gets a labelled SKIP that names what went
#      unchecked. A SKIP that says so beats a green line that hides it.
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
# Section 3: every unit's own README prints `-Dmaven.repo.local="$PWD/.m2-demo"` and its own
# receipts.sh uses the same path, so this run warms the repository the receipts then reuse.
M2_U11="$REPO/c3-unit11/.m2-demo"; M2_U12="$REPO/c3-unit12/.m2-demo"
M2_U13="$REPO/c3-unit13/.m2-demo"; M2_U14="$REPO/c3-unit14/.m2-demo"
M2_U15="$REPO/c3-unit15/.m2-demo"; M2_U16="$REPO/c3-unit16/.m2-demo"
M2_U17="$REPO/c3-unit17/.m2-demo"; M2_U18="$REPO/c3-unit18/.m2-demo"
# Sections 4 and 5: the same convention again — every one of these ten READMEs prints
# `-Dmaven.repo.local="$PWD/.m2-demo"` and every one of their receipts.sh uses the same
# path, so a warm-up here is the repository the receipts run then reuses.
M2_U19="$REPO/c3-unit19/.m2-demo"; M2_U20="$REPO/c3-unit20/.m2-demo"
M2_U21="$REPO/c3-unit21/.m2-demo"; M2_U22="$REPO/c3-unit22/.m2-demo"
M2_U23="$REPO/c3-unit23/.m2-demo"; M2_U24="$REPO/c3-unit24/.m2-demo"
M2_U25="$REPO/c3-unit25/.m2-demo"; M2_U26="$REPO/c3-unit26/.m2-demo"
M2_U27="$REPO/c3-unit27/.m2-demo"; M2_U28="$REPO/c3-unit28/.m2-demo"
export M2 M2_U02 M2_U04 M2_U06 M2_CONSUMER
export M2_U11 M2_U12 M2_U13 M2_U14 M2_U15 M2_U16 M2_U17 M2_U18
export M2_U19 M2_U20 M2_U21 M2_U22 M2_U23 M2_U24 M2_U25 M2_U26 M2_U27 M2_U28

# c3-unit25's matrix is JDK 25 PLUS ONE, and its receipts.sh dies rather than fake the
# second leg. The real JDK home (not the Homebrew symlink) is what jlink and jmod need in
# units 27 and 28, and the series module is the single source of unit 28's own counts.
JDK26="${JDK26:-/opt/homebrew/opt/openjdk@26}"
REALHOME25="$JAVA_HOME/libexec/openjdk.jdk/Contents/Home"
SERIES="$HOME/Desktop/PromptVidya-Automation/java3_series.py"
export JDK26 REALHOME25 SERIES

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
  # Sections 4 and 5 fork JVMs this run does not tag: JMH's uber-jar, the AOT recorder,
  # two jlink images and the servers in nobody's process group. `timed` kills the process
  # GROUP of its own child, which a grandchild java started by receipts.sh is not always
  # in — so anything whose command line names one of these ten unit directories is killed
  # here by path. Nothing outside the repository can match.
  pkill -9 -f "$REPO/c3-unit19" >/dev/null 2>&1
  local u
  for u in 20 21 22 23 24 25 26 27 28; do pkill -9 -f "$REPO/c3-unit$u" >/dev/null 2>&1; done
  # c3-unit25 attaches a case-sensitive disk image to reproduce a Linux runner. Its own
  # block detaches it; this is for the run that was interrupted between the two.
  hdiutil detach /Volumes/TiffinBoxCaseSensitive -quiet >/dev/null 2>&1
  restore_all
  # target/ and build/ everywhere under Course 3 (incl. c3-unit06/target/team-repo)
  local d
  for d in "$REPO"/c3-unit0[1-9] "$REPO"/c3-unit1[0-9] "$REPO"/c3-unit2[0-8] "$REPO"/c3-tiffinbox; do
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
  # Section 3: each receipts.sh writes one `.r-<block>.out` per block plus a handful of
  # throwaway copies, and each unit's OWN .gitignore is the list of them — read it here, so a
  # block that gains a new scratch directory is cleaned up without this file being edited.
  local ln
  for d in "$REPO"/c3-unit1[1-9] "$REPO"/c3-unit2[0-2]; do
    [ -d "$d" ] && [ -f "$d/.gitignore" ] || continue
    while IFS= read -r ln; do
      ln="${ln%/}"
      case "$ln" in
        ''|'#'*|'.gitignore'|'.m2-demo') continue ;;
        *[*?]*)  ( cd "$d" && rm -rf -- $ln ) 2>/dev/null ;;
        .*)      rm -rf -- "$d/$ln" 2>/dev/null ;;
      esac
    done < "$d/.gitignore"
  done
  # Section 5 (units 23-28) ships no per-unit .gitignore: its working files are listed in
  # the ROOT one, under the `Course 3 · Section 5` heading, as `c3-unitNN/<path>` lines.
  # Read them from there for the same reason the loop above reads the per-unit files — a
  # block that grows a new scratch directory is then cleaned up without editing this file.
  # Only `.`-prefixed leaves and `target/` are removed, so a committed directory the
  # comments in that file are careful to name (central/, wrapper/, workflows/, templates/)
  # can never be deleted by a typo here.
  if [ -f "$REPO/.gitignore" ]; then
    while IFS= read -r ln; do
      ln="${ln%/}"; ln="${ln%$'\r'}"
      case "$ln" in
        c3-unit2[3-8]/.m2-demo*) : ;;   # KEEP_M2=1 owns those; the block below decides
        c3-unit2[3-8]/*)
          case "${ln#c3-unit??/}" in
            .*|*/.*|target|*/target) ( cd "$REPO" && rm -rf -- $ln ) 2>/dev/null ;;
          esac ;;
      esac
    done < "$REPO/.gitignore"
  fi
  # …and every `.r-*` working file under the ten Section 4 and 5 units, by PATTERN rather than
  # by list. A DEFECT, reported rather than fixed because this script does not own the file:
  # c3-unit22 writes `.r-nr.txt` and `.r-sweep.txt`, and neither is named in that unit's
  # .gitignore or in its README's teardown block — so a clone that ran its receipts is left
  # with two untracked files `git status` reports. Cleaning by pattern here means a block that
  # grows another one is cleaned up without this line being edited.
  for d in "$REPO"/c3-unit19 "$REPO"/c3-unit2[0-8]; do
    [ -d "$d" ] && rm -f "$d"/.r-* 2>/dev/null
  done
  # …and the four that are NOT in the .gitignore because a block always deletes them
  # itself: the exercise trees unit 23's and 25's solution blocks copy aside, and the two
  # jdeps output directories. Belt and braces for an interrupted run.
  rm -rf "$REPO/c3-unit24/.repos" "$REPO/c3-unit25/.r-cs.dmg" 2>/dev/null
  rm -rf "$REPO/c3-unit27/.img-full" "$REPO/c3-unit27/.img-trim" "$REPO/c3-unit28/.img" 2>/dev/null
  rm -f  "$REPO/c3-unit27/.aot.conf" "$REPO/c3-unit27/.aot.cache" "$REPO/c3-unit27/.aot.dir.conf" 2>/dev/null
  rm -f  "$REPO/c3-unit28/.aot.conf" "$REPO/c3-unit28/.aot.cache" 2>/dev/null
  remove_created
  if [ "$KEEP_M2" != "1" ]; then
    rm -rf "$M2_U02" "$M2_U04" "$M2_U06" "$M2_CONSUMER" 2>/dev/null
    rm -rf "$M2_U07" "$M2_U09C" "$M2_U10" 2>/dev/null
    rm -rf "$GH07" "$GH08" "$GH09" "$GH10" 2>/dev/null
    rm -rf "${M2_U11:-}" "${M2_U12:-}" "${M2_U13:-}" "${M2_U14:-}" 2>/dev/null
    rm -rf "${M2_U15:-}" "${M2_U16:-}" "${M2_U17:-}" "${M2_U18:-}" 2>/dev/null
    rm -rf "${M2_U19:-}" "${M2_U20:-}" "${M2_U21:-}" "${M2_U22:-}" 2>/dev/null
    rm -rf "${M2_U23:-}" "${M2_U24:-}" "${M2_U25:-}" "${M2_U26:-}" 2>/dev/null
    rm -rf "${M2_U27:-}" "${M2_U28:-}" 2>/dev/null
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

# ------------------------------------------ the Section 3 units (11-18) ------
# Section 3 is "Testing That Earns Trust", and it is the first section in this course
# whose subject is tests that are *supposed to fail* and tests that are *supposed to pass
# for the wrong reason*. Four rules follow from that, and every assertion below keeps
# them:
#
#   1. **Never assert BUILD SUCCESS over a break beat.** Unit 11's break is three green
#      tests over a `Customer` that overcharges everyone; unit 14's is two green `verify`
#      calls over a service that charges 120 where the bill is 7200; unit 17's is a green
#      build whose coverage agent never loaded. `BUILD SUCCESS` is what all three PRINT —
#      it is the thing being warned about, so it can never be the evidence. What is
#      asserted instead is the artifact: the number the compiled program really returns
#      (`bill_is` below runs it), the amount the gateway was really handed, the file the
#      tool was supposed to write and did not.
#
#   2. **A break beat that stopped breaking is a defect, not a pass.** Fix unit 11's
#      31-day month, give unit 14's mock a real expectation, fix unit 17's `>` to `>=`,
#      drop the `static` from unit 18's roster, and the *build* gets better while the
#      *video* becomes wrong: the page still teaches a lesson the code no longer shows.
#      So every break is asserted to still break, with the message and the exit code its
#      README quotes — and the artifact is asserted in the direction the lesson needs.
#
#   3. **receipts.sh is a deliverable here, in all eight units.** Each one regenerates the
#      numbers its slides and its README quote, block by block, and prints
#      `md5 <hash>  exit <codes>` under each. `receipt_is` below compares that whole line —
#      hash AND exit codes — because several blocks are deliberately multi-exit
#      (`exit 1`, `exit 0 and 0`, `exit 0 then 1 then 0`), and a block that stopped failing
#      is exactly the defect rule 2 is about. Unit 11's hashes are READ OUT OF its README's
#      table; the rest are quoted only on the slides, and are written down here with the
#      deck that quotes each one named beside it.
#
#   4. **A green suite is not a suite that checks anything.** Nothing in a unit — not its
#      test count, not its `Tests run:` line, not one md5 — is a function of what its tests
#      ASSERT. Measured: weakening a single `isEqualTo(7200)` to `.isNotNull()` in unit 18,
#      or `isEqualTo(24300)` in unit 15, left this whole script green until `sensitive_to`
#      below was written. It answers the section's own question — *what would this test have
#      to see before it failed?* — by moving the thing the tests watch in a scratch copy
#      (a 31-day billing month, a stubbed answer changed, `30 - dayOfMonth` put back into
#      the shipped clock) and asserting surefire's summary line, because how many of them
#      NOTICED is the claim. "It went red" is not: weakening one assertion in a class whose
#      other methods still name a number leaves the class red and a class-name check green.
#
# Every Maven command in this section carries `-Dmaven.repo.local="$REPO/c3-unitNN/.m2-demo"`
# — the very path the unit's own README prints as `"$PWD/.m2-demo"`, which is also the one
# its receipts.sh uses, so the receipts run below finds the repository this run warmed.
M2_U11="$REPO/c3-unit11/.m2-demo"; M2_U12="$REPO/c3-unit12/.m2-demo"
M2_U13="$REPO/c3-unit13/.m2-demo"; M2_U14="$REPO/c3-unit14/.m2-demo"
M2_U15="$REPO/c3-unit15/.m2-demo"; M2_U16="$REPO/c3-unit16/.m2-demo"
M2_U17="$REPO/c3-unit17/.m2-demo"; M2_U18="$REPO/c3-unit18/.m2-demo"
export M2_U11 M2_U12 M2_U13 M2_U14 M2_U15 M2_U16 M2_U17 M2_U18

# The md5 every unit in this section claims for the five carried sources. Not transcribed:
# it is `grep`ed out of each README that prints it, and only compared with a live `md5`.
CARRIED_FIVE="Customer.java CustomerRepository.java Dashboard.java Database.java OrderQueue.java"

# src_hash5 DIR — `md5 -q <the five named files> | sort | md5 -q`.
# src_hash above globs `*.java`, which is the same thing in units 11-13, 15 and the five at the
# top of unit 14's package — and NOT the same thing in unit 16, whose README names the five by
# hand precisely because `Billing.java` sits beside them in that package. Using the glob there
# would compare six files against a five-file hash and fail for the wrong reason.
src_hash5() { ( cd "$1" 2>/dev/null && for f in $CARRIED_FIVE; do md5of "$f"; done | sort | md5in ); }

# readme_hash NN ANCHOR — the first 32-hex md5 on the first line of c3-unitNN/README.md that
# contains ANCHOR (a FIXED string, not a pattern: the anchors are the commands the page prints).
# The point is that the number is read OFF THE PAGE and only then compared with a live one, so a
# README that drifts away from its own receipts.sh fails here instead of being quietly agreed with.
readme_hash() { grep -F -- "$2" "$REPO/c3-unit$1/README.md" | grep -oE '[0-9a-f]{32}' | head -1; }

# receipts_table NN — the (block, md5, exit) rows of the markdown table c3-unit11/README.md
# ships. Read out of the page exactly as receipts_pairs reads the Gradle units' prose: the hash
# a row carries is found by its SHAPE, not by its column index, so a description containing a
# pipe cannot silently shift which cell is compared.
receipts_table() {
  grep -E '^\| *`[a-z][a-z-]*` *\|.*\| *`[0-9a-f]{32}` *\|' "$REPO/c3-unit$1/README.md" \
    | awk -F'|' '{ id=""; h=""; e=""
        for (i=2; i<=NF; i++) { f=$i; sub(/^[ \t]+/,"",f); sub(/[ \t]+$/,"",f)
          if (id=="" && f ~ /^`[a-z][a-z-]*`$/) { id=f; gsub(/`/,"",id) }
          else if (h=="" && f ~ /^`[0-9a-f]+`$/) { h=f; gsub(/`/,"",h); e=$(i+1) } }
        gsub(/\*/,"",e); sub(/^[ \t]+/,"",e); sub(/[ \t]+$/,"",e)
        if (id != "" && h != "") printf "%s\t%s\t%s\n", id, h, e }'
}

# offline_test LABEL TIMEOUT DIR REPO — the Section 3 form of offline_receipt. These READMEs
# print `mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -o test`, not `verify`, and every one of them
# says in so many words that offline mode can only reuse what a previous ONLINE run of the SAME
# lifecycle fetched. So the pair has to be `test` and then `-o test`, in that order, in one
# repository — the online half is what earns the offline half its meaning.
offline_test() {
  local label="$1" t="$2" d="$3" r="$4"
  expect_ok "$label — online first, into the scratch repository" "$t" 'BUILD SUCCESS' \
      mvn_in "$d" "$r" test || return 1
  expect_ok "$label — then -o, same repository: it resolved nothing new" "$t" 'BUILD SUCCESS' \
      mvn_in "$d" "$r" -o test
}

# Some exercise answers are "put a file where there was none" rather than "swap one file for
# another", and restore_all cannot undo that: it only copies backups back. Anything this run
# CREATES is registered here and removed by the EXIT trap too, so an interrupted run does not
# leave a test directory behind for the next one to compile.
CREATED=()
created() { CREATED+=("$1"); }
remove_created() { local p; for p in ${CREATED[@]+"${CREATED[@]}"}; do [ -n "$p" ] && rm -rf "$p"; done; }

# ------------------------------------------------- the READMEs' own panels ---
# panel NN ANCHOR K — the Kth fenced ``` block at or after the first line of
# c3-unitNN/README.md matching ANCHOR (an ERE), into $WORK/panel. Anchored on the prose
# above it rather than on an index, so adding a section earlier in the page cannot silently
# move a check onto a different block.
panel() {
  awk -v a="$2" -v want="$3" '
      !st { if ($0 ~ a) st=1; next }
      /^```/ { if (open) { open=0; if (n==want) exit } else { open=1; n++ }; next }
      open && n==want { print }' "$REPO/c3-unit$1/README.md" > "$WORK/panel"
}

# xpanel NN ANCHOR K — the same selector against c3-unitNN/exercise/README.md. Three exercises
# in this section print their acceptance output on the exercise page rather than the unit page,
# and two of those acceptance outputs are FAILURES (unit 14's captured 7200-vs-120, unit 17's
# 86% mutation score), which is exactly the kind of claim a page is most likely to drift away from.
xpanel() {
  awk -v a="$2" -v want="$3" '
      !st { if ($0 ~ a) st=1; next }
      /^```/ { if (open) { open=0; if (n==want) exit } else { open=1; n++ }; next }
      open && n==want { print }' "$REPO/c3-unit$1/exercise/README.md" > "$WORK/panel"
}

# panel_drop N — drop the first N lines of the selected panel. c3-unit14/exercise/README.md says
# in so many words that the line number after the method name is not part of its acceptance
# ("it depends on where you put the assertion") — so the check there is the two lines under it,
# and the method name is asserted on its own.
panel_drop() { sed "1,${1}d" "$WORK/panel" > "$WORK/panel.t" && mv "$WORK/panel.t" "$WORK/panel"; }

# out_has_panel LABEL — the panel just selected occurs in $OUT as one contiguous run of
# lines. This is the "every output the README quotes must come back" half of the contract,
# and it is the opposite direction from readme_shows: there a capture has to be findable in
# the page, here the page's own capture has to be findable in the run.
out_has_panel() {
  if [ ! -s "$WORK/panel" ]; then bad "$1" "c3-unit's README has no such panel to check"; return 1; fi
  if awk 'NR==FNR{nd[++N]=$0;next}{h[++H]=$0}
          END{ if(N==0) exit 1
               for(i=1;i+N-1<=H;i++){ok=1; for(j=1;j<=N;j++) if(h[i+j-1]!=nd[j]){ok=0;break}; if(ok) exit 0}
               exit 1 }' "$WORK/panel" "$OUT"; then
    ok "$1"
  else
    bad "$1" "this run never printed those $(wc -l <"$WORK/panel" | tr -d ' ') lines; the README's panel starts: $(head -2 "$WORK/panel" | tr '\n' '|')"
  fi
}

# out_has_lines LABEL — every line of the selected panel appears in $OUT, in that order, but
# not necessarily next to each other. This is the right reading for a README panel that is an
# ELISION — c3-unit11 prints surefire's suite total and `BUILD SUCCESS` with the `Results:` rule
# between them left out, and a strict contiguity check there would be measuring the elision
# rather than the claim. Where the page prints a WHOLE capture (every receipts.sh panel below,
# and the `jacoco.csv` row), out_has_panel is used instead and contiguity is the point.
out_has_lines() {
  if [ ! -s "$WORK/panel" ]; then bad "$1" "the README has no such panel to check"; return 1; fi
  if awk 'NR==FNR{nd[++N]=$0;next}
          { if (k<N && $0==nd[k+1]) k++ }
          END{ exit (k==N ? 0 : 1) }' "$WORK/panel" "$OUT"; then
    ok "$1"
  else
    bad "$1" "this run did not print all $(wc -l <"$WORK/panel" | tr -d ' ') of the README's lines in that order; first is: $(head -1 "$WORK/panel")"
  fi
}

# out_has_panel_rtrim LABEL — as out_has_panel, but with trailing whitespace stripped from both
# sides. surefire writes `[ERROR]   Class.method ` with a trailing space before the message it puts
# on the next line, and a markdown editor strips it: c3-unit18/README.md's four-line failure-report
# panel is that capture minus four invisible characters. Where a trailing space IS the evidence —
# every hashed receipts capture below, which keeps them — the exact form is used instead.
out_has_panel_rtrim() {
  sed 's/[[:space:]]*$//' "$WORK/panel" > "$WORK/panel.r"
  sed 's/[[:space:]]*$//' "$OUT"        > "$WORK/out.r"
  if [ ! -s "$WORK/panel.r" ]; then bad "$1" "the README has no such panel to check"; return 1; fi
  if awk 'NR==FNR{nd[++N]=$0;next}{h[++H]=$0}
          END{ if(N==0) exit 1
               for(i=1;i+N-1<=H;i++){ok=1; for(j=1;j<=N;j++) if(h[i+j-1]!=nd[j]){ok=0;break}; if(ok) exit 0}
               exit 1 }' "$WORK/panel.r" "$WORK/out.r"; then
    ok "$1"
  else
    bad "$1" "this run did not print those $(wc -l <"$WORK/panel.r" | tr -d ' ') lines together, trailing spaces ignored"
  fi
}

# ------------------------------------ the Maven receipts.sh, as a deliverable ---
# Units 11-18 each ship a bash receipts.sh that rebuilds every number its slides and its
# README quote. run_receipts runs one from this clone into $WORK/receipts.NN.
run_receipts() {
  local n="$1" t="$2" env="${3:-}"
  expect_ok "c3-unit$n/receipts.sh — every block, from a clean clone" "$t" '' \
      bash -c "cd \"$REPO/c3-unit$n\" && $env ./receipts.sh" || return 1
  cp "$OUT" "$WORK/receipts.$n"
  return 0
}

# block_tail NN ID — the `md5 …` line(s) printed inside the `=== ID …` section of the run
# kept in $WORK/receipts.NN. Bounded by that block's OWN header, so a hash cannot be matched
# against a line another block printed.
block_tail() {
  awk -v id="$2" 'BEGIN{re="^=== " id "( |$)"}
       $0 ~ /^=== / { inb = ($0 ~ re) }
       inb && /^md5 / { print }' "$WORK/receipts.$1" 2>/dev/null
}

# receipt_is NN ID "md5 <hash>  exit <codes>" — the whole trailer line, hash and exit codes
# together. The exit codes are half the claim in this section: `break` blocks exit 1 on
# purpose, `unchanged` exits `0 and 0`, `green` exits `0 then 1 then 0`, and a block that
# quietly started exiting 0 is a break that stopped breaking.
receipt_is() {
  local got; got="$(block_tail "$1" "$2")"
  is "…c3-unit$1/receipts.sh $2 -> $3" "$got" "$3"
}

# receipt_body NN ID -> $OUT — everything the `=== ID …` block printed, without its header
# and without its `md5 …` trailer. That is exactly the console panel a README puts under it,
# so `panel`/`out_has_panel` can hold the page to it.
receipt_body() {
  awk -v id="$2" 'BEGIN{re="^=== " id "( |$)"}
       $0 ~ /^=== / { inb = ($0 ~ re); next }
       inb && /^md5 / { inb=0; next }
       inb { print }' "$WORK/receipts.$1" > "$OUT" 2>/dev/null
}

# ------------------------------ the Section 4 and 5 units (19-28) -----------
# Six things change in these ten units, and the helpers below are those six things.
#
#   1. **A receipt trailer is not "any line beginning md5".** c3-unit19's `levels` block
#      prints `md5 of target/classes before the two runs: …` as part of its own capture —
#      that IS the lesson — so `block_tail` above returns three lines for it and
#      `receipt_body` cuts the body in half at the first of them. `block_md5s` and
#      `receipt_panel` read the trailer by SHAPE (`md5 <32 hex>`) instead.
#   2. **Section 5's trailers are punctuated differently.** Units 19-22 print
#      `md5 X  exit 0`; units 23-28 print `md5 X  (exit 0)`, `(no build)`, `(no write)`,
#      `(exit 1, 2, 0)`. Nothing is normalised: the whole line is the claim, because the
#      exit codes in it are half of what each block is asserting.
#   3. **Four hashes are deliberately unpinned**, and `not_pinned` is how this script says
#      so out loud instead of agreeing with whatever came out.
#   4. **Some claims are about what a README does NOT say** — unit 27 ships no binary, so a
#      size or a start-up time on that page would be a fabrication no hash in that unit
#      could catch. `readme_hasnt` is that direction.
#   5. **Unit 24's subject is git**, so `git_state` fingerprints this repository before its
#      receipts run and asserts every part of it unchanged after.
#   6. **Unit 22's subject is a duration**, and the split it makes — four blocks hashed,
#      four printing `no md5:` and a reason — is itself the thing to assert. A block that
#      started hashing a Score would be the defect. `unhashed_blocks` counts them.

# block_md5s NN ID — the RECEIPT TRAILER line(s) of one block: `md5 <32 hex> …` and nothing
# else. Matched on shape rather than on the first three characters, for the reason above.
block_md5s() {
  awk -v id="$2" 'BEGIN{re="^=== " id "( |$)"}
       $0 ~ /^=== / { inb = ($0 ~ re) }
       inb && $1 == "md5" && $2 ~ /^[0-9a-f]+$/ && length($2) == 32 { print }' \
       "$WORK/receipts.$1" 2>/dev/null
}

# receipt_line NN ID "md5 <hash>  (exit …)" — the whole trailer, compared verbatim.
receipt_line() {
  local got; got="$(block_md5s "$1" "$2")"
  is "…c3-unit$1/receipts.sh $2 -> $3" "$got" "$3"
}

# receipt_hash_of NN ID — just the 32 hex characters of that trailer.
receipt_hash_of() { block_md5s "$1" "$2" | head -1 | awk '{print $2}'; }

# receipt_panel NN ID -> $OUT — the block's body, ending at the trailer rather than at the
# first line that happens to begin `md5 `. That is the console panel a README puts under it.
receipt_panel() {
  awk -v id="$2" 'BEGIN{re="^=== " id "( |$)"}
       $0 ~ /^=== / { inb = ($0 ~ re); next }
       inb && $1 == "md5" && $2 ~ /^[0-9a-f]+$/ && length($2) == 32 { inb=0; next }
       inb { print }' "$WORK/receipts.$1" > "$OUT" 2>/dev/null
}

# carried_five_hash NN — the first 32-hex md5 in the header of c3-unitNN/README.md, which in
# every unit from the Gradle section on is the five carried sources' own hash. READ OFF THE
# PAGE rather than transcribed here: three of these ten pages put it on a line of its own with
# no prose to anchor on, and a copy kept in this file is a claim about this script.
carried_five_hash() { sed -n '1,14p' "$REPO/c3-unit$1/README.md" | grep -oE '[0-9a-f]{32}' | head -1; }

# receipts_ids NN — the block ids c3-unitNN/receipts.sh really declares, sorted, `all` dropped.
# Three shapes across the ten units: an `ALL=(…)` array, a `case` with one alternation line, and
# a `case` with one label per line. All three are read, so the README's own block table can be
# compared against the deliverable instead of against a list typed in here — the table is where
# "./receipts.sh runs all nine" comes from, and a block that quietly left the dispatch is
# invisible to every per-hash check.
receipts_ids() {
  local f="$REPO/c3-unit$1/receipts.sh"
  [ -f "$f" ] || return 0
  { sed -n 's/^ALL=(\(.*\))$/\1/p' "$f" | tr ' ' '\n'
    sed -n 's/^ *\([a-z][a-z|-]*\)) *"run_\$b".*/\1/p' "$f" | tr '|' '\n'
    sed -n 's/^ *\([a-z][a-z-]*\)) *run_[a-z_]*.*/\1/p' "$f"
    sed -n 's/^ *all) *//p' "$f" | tr ';' '\n' | sed -n 's/^ *run_\([a-z][a-z-]*\).*/\1/p'
  } | grep -E '^[a-z][a-z-]*$' | grep -vx 'all' | LC_ALL=C sort -u | tr '\n' ' '
}
# readme_block_ids NN — the ids the `| `id` | …` table in c3-unitNN/README.md lists, sorted.
readme_block_ids() {
  grep -oE '^\| *`[a-z][a-z-]*` *\|' "$REPO/c3-unit$1/README.md" \
    | tr -d '|` ' | LC_ALL=C sort -u | tr '\n' ' '
}

# panel_unelide — drop the `... N line(s) elided: …` markers a README panel carries where the
# page cut something. Sections 4 and 5 elide a lot (a thirty-row dependency tree, eight sweep
# rows, four jdeps edges), and every one of those markers is a line the BLOCK never printed —
# so a contiguity check over them is measuring the cut rather than the claim. Use with
# out_has_lines, which asks the honest question: did every line the page kept really come back,
# in that order?
panel_unelide() {
  grep -vE '^[[:space:]]*\.\.\. .*(elided|more line)' "$WORK/panel" > "$WORK/panel.u" \
    && mv "$WORK/panel.u" "$WORK/panel"
}

# panel_indent N — prepend N spaces to every line of the selected panel. Most Section 5 blocks
# print their panels through `sed 's/^/  /'`, and the pages print the same lines two columns to
# the left. Indenting the PAGE is the comparison that has meaning; stripping the block's indent
# instead would throw away the one thing the block did to its own output.
panel_indent() {
  local pad; pad="$(printf '%*s' "$1" '')"
  sed "s/^/$pad/" "$WORK/panel" > "$WORK/panel.i" && mv "$WORK/panel.i" "$WORK/panel"
}

# out_has_lines_lax LABEL — as out_has_lines, but with leading and trailing whitespace removed
# from both sides first. Several Section 5 panels are a page's RE-INDENTED copy of a block whose
# own indentation is not uniform: c3-unit27's jdeps panel has one indented line and three
# un-indented ones, from a block that indents all four, and c3-unit28's four-holes panel is the
# same ledger three columns over. A strict comparison there is measuring the markdown rather
# than the claim. Where the whitespace IS the evidence — every hashed capture, which keeps it —
# the strict forms above are used instead, and most of these panels still get one.
out_has_lines_lax() {
  sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' "$WORK/panel" > "$WORK/panel.l"
  sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' "$OUT"        > "$WORK/out.l"
  if [ ! -s "$WORK/panel.l" ]; then bad "$1" "the README has no such panel to check"; return 1; fi
  if awk 'NR==FNR{nd[++N]=$0;next}
          { if (k<N && $0==nd[k+1]) k++ }
          END{ exit (k==N ? 0 : 1) }' "$WORK/panel.l" "$WORK/out.l"; then
    ok "$1"
  else
    bad "$1" "this run did not print all $(wc -l <"$WORK/panel.l" | tr -d ' ') of the README's lines in that order, indentation ignored; first is: $(head -1 "$WORK/panel.l")"
  fi
}

# panel_drop_re REGEX — drop the lines of the selected panel that match REGEX. For the one case
# where a page prints a genuinely variable figure inside an otherwise fixed panel: c3-unit28's
# `ship` panel carries `classes loaded N, of those out of the cache M`, and that pair moves run
# to run. Everything else on that panel is structure, and dropping one line is how the structure
# gets checked without the figure being demanded — the caller then asserts the arithmetic and
# says out loud, as a labelled SKIP, that the figure itself went unchecked.
panel_drop_re() { grep -vE "$1" "$WORK/panel" > "$WORK/panel.d" && mv "$WORK/panel.d" "$WORK/panel"; }

# jmh_guarded LABEL TIMEOUT NN ID PATTERN — one of c3-unit22's three unhashed blocks, whose
# guard is a fact about the MACHINE rather than about the deliverable. `scores` stops if an
# interval pair overlaps, `deadcode` if the discarded call stops being indistinguishable from an
# empty method, `jfr` if the compilation rate does not fall by four; and unit 22's README says in
# so many words that an overlap is section 2c's legitimate answer — "I could not measure a
# difference above the noise on this machine" — and that the block stops rather than let a spoken
# line contradict the panel. Measured: on a machine running two other Maven builds, `scores`
# stopped exactly there, twice.
#
# So three outcomes, and all three are honest: exit 0 WITH the sentence the page speaks is a
# PASS; the block's OWN documented refusal is a labelled SKIP naming the machine; anything else
# is a FAIL, because a break that is not the guard is a break.
jmh_guarded() {
  local label="$1" t="$2" n="$3" id="$4" pat="$5"
  timed "$t" bash -c "cd \"$REPO/c3-unit$n\" && ./receipts.sh $id"
  if [ "$RC" -eq 124 ]; then bad "$label" "timed out after ${t}s"; return 1; fi
  if [ "$RC" -eq 0 ]; then
    if grep -qE "$pat" "$OUT"; then ok "$label"; return 0
    else bad "$label" "exit 0, but no line matching the sentence the page speaks: $pat"; return 1; fi
  fi
  if grep -qE "^RECEIPT FAILED \($id\):" "$OUT"; then
    skip "$label" "the block stopped with its OWN documented refusal, which is section 2c's legitimate answer on a machine under load: $(grep -m1 -oE "RECEIPT FAILED \($id\).{0,130}" "$OUT")"
    return 2
  fi
  bad "$label" "exit $RC, and NOT with the block's own guard message — that is a break, not a noisy machine"
  return 1
}

# receipts_says NN LABEL REGEX — a sentence the unit's receipts.sh prints about its own
# numbers. Searched over the WHOLE run rather than over one block's body, because the three
# snapshot warnings and unit 22's four `no md5:` reasons are printed BELOW the trailer,
# where receipt_panel cannot see them.
receipts_says() {
  local n="$1" label="$2" re="$3"
  if grep -qE "$re" "$WORK/receipts.$n" 2>/dev/null; then ok "$label"
  else cp "$WORK/receipts.$n" "$OUT" 2>/dev/null
       bad "$label" "c3-unit$n/receipts.sh printed no line matching: $re"; fi
}

# unhashed_blocks NN — blocks that printed `no md5:` and a reason, which in unit 22 is a
# deliberate design decision and not a gap.
unhashed_blocks() { grep -cE '^no md5:' "$WORK/receipts.$1" 2>/dev/null | tr -d ' '; }

# not_pinned LABEL WHAT — one of the four Section 5 figures this script must NOT demand.
# `u28-ship` moves because the JVM's AOT class count moves run to run (three runs here gave
# 2070 · 2071 · 2070); `u24-convention`, `u24-realrepo` and `u28-gaps` are live snapshots of
# a repository that grows, and each block prints that instruction itself. The STRUCTURE and
# the derived arithmetic are asserted above every one of these; the figure is not, and a
# labelled SKIP naming it beats a green line that agrees with whatever came out.
not_pinned() { skip "$1" "not pinned by this run: $2"; }

# readme_hasnt LABEL NN REGEX — nothing in c3-unitNN/README.md matches. The direction unit 27
# needs: that page's whole framing is that no native binary exists here, so a binary size, a
# start-up time or a throughput figure on it would be an invention — and not one hash in that
# unit is a function of the README's prose, so nothing else would notice.
readme_hasnt() {
  local label="$1" n="$2" re="$3" hit
  hit="$(grep -nE "$re" "$REPO/c3-unit$n/README.md" 2>/dev/null | head -3 | tr '\n' ' ')"
  if [ -z "$hit" ]; then ok "$label"
  else bad "$label" "c3-unit$n/README.md carries: $hit"; fi
}
# xreadme_quotes LABEL NN TEXT — as readme_quotes, but of c3-unitNN/exercise/README.md. Three
# exercises in Sections 4 and 5 make their headline claim on their own page rather than on the
# unit page, and c3-unit22's is the one that matters most: "on this machine, you cannot tell".
xreadme_quotes() {
  if grep -qF "$3" "$REPO/c3-unit$2/exercise/README.md"; then ok "$1"
  else bad "$1" "c3-unit$2/exercise/README.md does not quote: $3"; fi
}
# …and the same question of an exercise page.
xreadme_hasnt() {
  local label="$1" n="$2" re="$3" hit
  hit="$(grep -nE "$re" "$REPO/c3-unit$n/exercise/README.md" 2>/dev/null | head -3 | tr '\n' ' ')"
  if [ -z "$hit" ]; then ok "$label"
  else bad "$label" "c3-unit$n/exercise/README.md carries: $hit"; fi
}

# git_state — HEAD, the commit count, every ref, the object-store census and the working-tree
# status of the repository this script lives in, on one line. c3-unit24's whole subject is git:
# its receipts.sh creates every repository it writes to under `c3-unit24/.repos/` and has a
# `guard()` that refuses anything else, and this is the assertion that the guard held. Taken
# immediately before that receipts run and compared immediately after, so the window is exactly
# that run and nothing else in this script can be blamed for a difference.
git_state() {
  ( cd "$REPO" 2>/dev/null || return 0
    printf '%s|%s|%s|%s|%s' \
      "$(git rev-parse HEAD 2>/dev/null)" \
      "$(git rev-list --count HEAD 2>/dev/null)" \
      "$(git for-each-ref --format='%(refname) %(objectname)' 2>/dev/null | LC_ALL=C sort | shasum | cut -d' ' -f1)" \
      "$(git count-objects -v 2>/dev/null | LC_ALL=C sort | shasum | cut -d' ' -f1)" \
      "$(git status --porcelain 2>/dev/null | LC_ALL=C sort | shasum | cut -d' ' -f1)" )
}

# derived_unprobed NN — say out loud that this unit's derived counts are hashed but not PROBED.
#
# A `$(grep -c …)` and the literal it happens to equal today produce identical bytes, an identical
# block md5 and an identical whole-run md5. No hash can tell a measurement from a caption; only
# moving the INPUT can, and that means a second receipts run per unit. Measured, twice: replacing
# one derived count in c3-unit11's `counts` block with `"1"`, and one in c3-unit12's `cases` block
# with `"5"`, left this script entirely green until the two probes above were written. Those two
# units now have them. Doing the same for every derived line in the other six would add a full
# extra receipts run each to a script that already takes the better part of an hour — so it is
# named here instead of hidden behind a green line.
derived_unprobed() {
  skip "c3-unit$1/receipts.sh — its derived counts are HASHED but not PROBED" \
       "a \$(grep -c …) and the literal it happens to equal today are the same bytes and the same md5; only moving the input separates them. c3-unit11's counts and c3-unit12's cases have that probe; here a WRONG count is caught (it is compared with the number the README and the deck quote) but a RIGHT one that stopped being measured is not"
}

# receipts_blocks NN — how many `=== … ===` blocks the run printed. Several READMEs state
# that count in words ("eight blocks", "all nine block hashes"), and a block that stopped
# running is invisible to every per-hash check above.
receipts_blocks() { grep -cE '^=== ' "$WORK/receipts.$1" 2>/dev/null | tr -d ' '; }

# receipts_md5 NN — the md5 of the WHOLE run's output. Four of these READMEs quote that
# number and say in so many words that hashing receipts.sh itself is a different number and
# is not a receipt of anything, so both readings are checked where both are written down.
receipts_md5() { md5of "$WORK/receipts.$1"; }

# pit_survivors XML — the line numbers PIT recorded as SURVIVED, sorted, on one line. c3-unit17's
# receipts.sh derives its survivor lines from `target/pit-reports/mutations.xml` and never from
# PIT's console log, which stamps a wall clock on every line — so anything asserted about a
# survivor has to read the same file, not grep the build output for a word that is not in it.
pit_survivors() {
  [ -f "$1" ] || { echo "no mutations.xml"; return 0; }
  python3 - "$1" <<'PYEOF'
import re,sys
s=open(sys.argv[1]).read()
out=[]
for m in re.finditer(r"<mutation detected='\w+' status='(\w+)'[^>]*>(.*?)</mutation>", s, re.S):
    if m.group(1)!='SURVIVED': continue
    out.append(re.search(r'<lineNumber>(\d+)', m.group(2)).group(1))
print(' '.join(sorted(out, key=int)))
PYEOF
}

# sensitive_to LABEL NN REPO FILE FROM TO WANT — the question this whole section asks of a test:
# **what would it have to see before it failed?**
#
# This exists because of two survivors this script did not catch when it was first written.
# Weaken one `assertThat(…monthlyBill()).isEqualTo(7200)` in c3-unit18/src/test to `.isNotNull()`,
# or one `assertThat(view.monthRevenue()).isEqualTo(24300)` in c3-unit15's, and NOTHING moves: the
# classes still declare the same methods, surefire still prints the same `Tests run:` line, the
# build is still green, and every md5 in the unit still reproduces — because not one of them is a
# function of what the test asserts. A suite can keep its count, keep its tick and stop
# constraining anything at all, which is the exact failure mode Section 3 exists to teach.
#
# The only honest answer is the one c3-unit11's own `green` receipt uses on its break: move the
# thing the tests are supposed to be watching, and count how many of them notice. So this copies
# the unit into $WORK, makes ONE edit there — a 31-day billing month, a stubbed answer changed,
# `30 - dayOfMonth` put back into the shipped clock — and asserts surefire's own summary line,
# because the COUNT is the claim. "It went red" is not: weakening one assertion in a class whose
# other methods still name a number leaves the class in the failure list and the suite red, and a
# check that only asked for the class name passes straight over it. Measured: that is exactly how
# this probe's first draft let a weakened `isEqualTo(7200)` through.
#
# Nothing in the working tree is touched; the copy is deleted either way.
sensitive_to() {
  local label="$1" n="$2" r="$3" f="$4" from="$5" to="$6" want="$7"
  local d="$WORK/vs$n" got
  rm -rf "$d"
  mkdir -p "$d" || { bad "$label" "could not make a scratch copy of c3-unit$n"; return 1; }
  ( cd "$REPO/c3-unit$n" && tar cf - pom.xml src ) | ( cd "$d" && tar xf - ) 2>/dev/null
  if [ ! -f "$d/$f" ]; then bad "$label" "no $f in the copy"; rm -rf "$d"; return 1; fi
  if ! python3 - "$d/$f" "$from" "$to" <<'PYEOF'
import sys
p, a, b = sys.argv[1], sys.argv[2], sys.argv[3]
s = open(p, encoding='utf-8').read()
if s.count(a) != 1:
    sys.exit(3)
open(p, "w", encoding='utf-8').write(s.replace(a, b))
PYEOF
  then
    bad "$label" "the probe's edit did not apply exactly once to $f — it would prove nothing"
    rm -rf "$d"; return 1
  fi
  timed 900 bash -c "cd \"$d\" && mvn -B \"-Dmaven.repo.local=$r\" test"
  got="$(grep -oE 'Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+' "$OUT" | tail -1)"
  is "$label" "$got" "$want"
  rm -rf "$d"
}

# ------------------------------------------------- the artifact, not the word ---
# bill_is LABEL CLASSES NAME MEALS PRICE WANT — what `new Customer(NAME, MEALS, PRICE, "VEG")
# .monthlyBill()` really returns when run against a given target/classes, compared with WANT.
#
# This exists because rule 1 above has no other honest answer. c3-unit11's break is three
# tests that pass over a Customer billing a 31-day month; every one of surefire's words is
# `Tests run: 3, Failures: 0` and `BUILD SUCCESS`, which is the lesson rather than the
# evidence. The evidence is 7440 where 7200 belongs, and the only way to have it is to run
# the class that was just built and read the number.
bill_is() {
  local label="$1" cp="$2" nm="$3" meals="$4" price="$5" want="$6"
  cat > "$WORK/Bill.java" <<EOF
public class Bill {
  public static void main(String[] a) throws Exception {
    System.out.println(new com.tiffinbox.Customer("$nm", $meals, $price, "VEG").monthlyBill());
  }
}
EOF
  if [ ! -d "$cp" ]; then bad "$label" "no compiled classes at $cp"; return 1; fi
  timed 120 "$JAVA" "-D$TAG=bill" -cp "$cp" "$WORK/Bill.java"
  is "$label" "$(tr -d ' \n' <"$OUT")" "$want"
}

# charged_is LABEL CLASSES NAME MEALS PRICE WANT — the amount BillingService really hands the
# PaymentGateway. c3-unit14's break is two green `verify(gateway).charge(eq("Ravi"), anyInt())`
# calls over a service that charges one meal instead of the month; `anyInt()` is satisfied by
# every possible answer, so the green run says nothing at all. The captured amount is the
# artifact, and this runs the compiled service against a gateway that records it.
charged_is() {
  local label="$1" cp="$2" nm="$3" meals="$4" price="$5" want="$6"
  cat > "$WORK/Charged.java" <<EOF
import com.tiffinbox.Customer;
import com.tiffinbox.billing.BillingService;
import com.tiffinbox.billing.PaymentGateway;
public class Charged {
  public static void main(String[] a) {
    final int[] seen = { -1 };
    PaymentGateway recorder = new PaymentGateway() {
      public String charge(String customer, int paise) { seen[0] = paise; return "REF-TEST"; }
      public int balanceOf(String customer) { return 0; }
    };
    new BillingService(recorder).chargeMonthly(new Customer("$nm", $meals, $price, "VEG"));
    System.out.println(seen[0]);
  }
}
EOF
  if [ ! -d "$cp" ]; then bad "$label" "no compiled classes at $cp"; return 1; fi
  timed 120 "$JAVA" "-D$TAG=charged" -cp "$cp" "$WORK/Charged.java"
  is "$label" "$(tr -d ' \n' <"$OUT")" "$want"
}

# ------------------------------------------ the tree, before and after --------
# The run swaps pom.xml files and `sed`s one source file, and has to put every one
# back. The old proof was `git status` at the end — which also fails when the tree
# legitimately carries uncommitted work that this run never touched. So take a
# content fingerprint of everything Course 3 ships, minus what a build writes, and
# compare it with itself at the end: that is literally "as this run found it".
tree_fingerprint() {
  local d f
  { for d in "$REPO"/c3-unit0[1-9] "$REPO"/c3-unit1[0-9] "$REPO"/c3-unit2[0-8] "$REPO"/c3-tiffinbox; do
      [ -d "$d" ] || continue
      find "$d" -type f \
           -not -path '*/target/*'      -not -path '*/.m2-demo/*' \
           -not -path '*/.m2-unit04/*'  -not -path '*/.m2-unit06/*' \
           -not -path '*/build/*'       -not -path '*/.gradle/*' \
           -not -path '*/.gradle-home/*' \
           -not -path '*/.gh-fresh/*'   -not -path '*/.gh-old/*' \
           -not -name 'cp.txt'          -not -name 'cp-*.txt' \
           -not -name 'es.xml'          -not -name 'effective-pom.xml' \
           -not -name '.r-*'            -not -path '*/.sol/*' \
           -not -path '*/.capstone/*'   -not -path '*/.green/*' \
           -not -path '*/.green2/*'     -not -path '*/.zero-strict/*' \
           -not -path '*/.assertall/*'  -not -path '*/.noagent/*' \
           -not -path '*/.space trap/*' -not -path '*/.amount/*' \
           -not -path '*/.flags/*'      -not -path '*/.q/*' \
           -not -path '*/.ex/*'         -not -path '*/.fix/*' \
           -not -path '*/.props/*' \
           -not -path '*/logs/*'        -not -path '*/.gate/*' \
           -not -path '*/.jq/*'         -not -path '*/.spot/*' \
           -not -path '*/.repos/*'      -not -path '*/.mi[123]/*' \
           -not -path '*/.img/*'        -not -path '*/.img-full/*' \
           -not -path '*/.img-trim/*' \
           -not -name 'benchmarks.jar'  -not -name '*.jfr' \
           -not -name 'jmh-result.*'    -not -name 'kitchen*.log' \
           -not -name 'kitchen*.json'   -not -name '.r-cs.dmg' \
           -not -name '.aot.conf'       -not -name '.aot.cache' \
           -not -name '.aot.dir.conf' 2>/dev/null
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
      0[1-9]|1[0-9]|2[0-8]) [ -d "$REPO/c3-unit$u" ] || { echo "unknown unit: $u (no c3-unit$u/ in $REPO)" >&2; exit 2; } ;;
      # A unit that has landed but that this script does not cover yet gets its own sentence. The
      # folder is right there, so "no such unit" would be a lie, and the report's
      # "not covered by this script yet" line is the thing to read instead.
      *) if [ -d "$REPO/c3-unit$u" ]; then
           echo "c3-unit$u/ exists but verify_course3.sh does not cover it yet — run with no arguments and read the 'not covered by this script yet' line" >&2
         else
           echo "unknown unit: $u (use two digits, 01-28, or 'tiffinbox')" >&2
         fi
         exit 2 ;;
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
printf '                                  c3-unit11..18/.m2-demo — one per testing unit, the path each README prints\n'
printf '                                  c3-unit19..28/.m2-demo — one per logging and shipping unit, same convention\n'
printf 'Gradle homes (never ~/.gradle):   c3-unit07..10/.gradle-home — each project'"'"'s committed wrapper fetches 9.7.1 into its own\n'
[ -n "${OLD_GRADLE:-}" ] && printf 'OLD_GRADLE=%s — unit 10'"'"'s drift beat runs for real\n' "$OLD_GRADLE"
[ "$SKIP_SLOW" = "1" ] && printf '%sSKIP_SLOW=1 — the repeated-build hash loops are shortened%s\n' "$YLW" "$OFF"
# Sections 4 and 5 reach for five tools the Maven sections did not. Say which are here
# BEFORE anything runs, so a SKIP later on reads as a missing tool and not as a defect.
S45=""
for t in jq ruby python3 git gh; do
  command -v "$t" >/dev/null 2>&1 && S45="$S45 $t" || S45="$S45 ${t}(MISSING)"
done
[ -x "$JDK26/bin/java" ] && S45="$S45 jdk26" || S45="$S45 jdk26(MISSING)"
[ -s "$SERIES" ]         && S45="$S45 java3_series.py" || S45="$S45 java3_series.py(MISSING)"
printf 'sections 4-5 also need:          %s\n' "${S45# }"
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

# ============================================================= c3-unit11 ====
if unit 11 "The Section 3 baseline: JUnit 6, and a green build that proves nothing"; then
  # ---- the carried sources. The README prints the command and the number it gives, twice —
  # once here and once in ../c3-tiffinbox — so both halves are run and the number is read off
  # the page rather than kept in this file.
  U11H="$(readme_hash 11 'Both print')"
  is "README quotes a 32-hex md5 for the five carried sources" "$(printf '%s' "$U11H" | wc -c | tr -d ' ')" "32"
  is "cd src/main/java/com/tiffinbox && md5 -q *.java | sort | md5 -q -> the hash the README prints" \
     "$(src_hash "$REPO/c3-unit11/src/main/java/com/tiffinbox")" "$U11H"
  is "…and ../c3-tiffinbox/tiffinbox-core prints the same one — byte-identical, not 'the same idea'" \
     "$(src_hash "$REPO/c3-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox")" "$U11H"
  # …and that the hash covers FIVE files and no sixth. `md5 -q *.java` is a non-recursive glob:
  # a class added under com/tiffinbox/<anything>/ compiles, ships, and moves no hash at all.
  is "…and the source root holds exactly those five .java files, nothing else" \
     "$(src_files "$REPO/c3-unit11/src/main/java")" "$FIVE_SRC"

  # ---- the POM's two claims: one version for the whole JUnit family, and surefire pinned
  timed 60 cat "$REPO/c3-unit11/pom.xml"
  has "pom.xml imports org.junit:junit-bom 6.1.3 in dependencyManagement" '<artifactId>junit-bom</artifactId>'
  has "…at 6.1.3"                                                        '<version>6\.1\.3</version>'
  has "…and pins maven-surefire-plugin"                                  '<artifactId>maven-surefire-plugin</artifactId>'
  has "…at 3.6.0, not the 3.5.4 Maven 3.9.16 would bind on its own"      '<version>3\.6\.0</version>'
  # the BOM's whole point, and the one line that proves it: junit-jupiter carries NO version.
  N="$(awk '/<artifactId>junit-jupiter<\/artifactId>/{f=1} f&&/<version>/{c++} /<\/dependency>/{f=0} END{print c+0}' "$REPO/c3-unit11/pom.xml")"
  is "…and junit-jupiter carries no <version> of its own — the BOM decides it" "$N" "0"

  # ---- run it, the way the README's "Run it" block says to
  expect_ok 'mvn -B -Dmaven.repo.local="$PWD/.m2-demo" test' 1200 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit11" && mvn -B "-Dmaven.repo.local=$M2_U11" test'
  has "…Tests run: 4, Skipped: 1 — four @Test methods, and the assumeTrue one really is skipped" \
      'Tests run: 4, Failures: 0, Errors: 0, Skipped: 1'
  is  "…and CustomerTest really declares four of them" \
      "$(grep -c '@Test' "$REPO/c3-unit11/src/test/java/com/tiffinbox/CustomerTest.java")" "4"
  sensitive_to "…and they CONSTRAIN the bill: make the month 31 days and TWO of those four notice" \
      11 "$M2_U11" src/main/java/com/tiffinbox/Customer.java \
      "mealsPerDay * pricePerMeal * 30;" "mealsPerDay * pricePerMeal * 31;" \
      "Tests run: 4, Failures: 2, Errors: 0, Skipped: 1"

  # ---- breaks/green-for-nothing. The README's own words: three green ticks, and not one of
  # them looks at the number. So the run is asserted to be GREEN — that is the lesson — and
  # then the ARTIFACT is measured, because the green is what is being warned about.
  expect_ok "breaks/green-for-nothing: mvn -B test -> BUILD SUCCESS, three passing tests over a wrong bill" 900 \
      'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit11/breaks/green-for-nothing" && mvn -B "-Dmaven.repo.local=$M2_U11" test'
  panel 11 'The one to run before you write another test' 2
  out_has_lines "…and the two lines the README prints under that command came back, in order"
  # THE assertion of this beat. `Tests run: 3, Failures: 0` and `BUILD SUCCESS` are the defect;
  # 7440 is the evidence. Ravi is 2 meals at 120 — 7200 for a 30-day month, 7440 for the 31 this
  # Customer bills. Fix the 31 and this line fails, which is correct: the video is then teaching
  # a lesson the code no longer shows.
  bill_is "…and the bill it really returns for Ravi is 7440, not 7200 — a 31-day month" \
      "$REPO/c3-unit11/breaks/green-for-nothing/target/classes" "Ravi" 2 120 "7440"
  bill_is "…while the unit's own Customer, same inputs, returns 7200" \
      "$REPO/c3-unit11/target/classes" "Ravi" 2 120 "7200"
  timed 60 cat "$REPO/c3-unit11/breaks/green-for-nothing/src/main/java/com/tiffinbox/Customer.java"
  has "…and the one character that does it is still there: * 31" 'mealsPerDay \* pricePerMeal \* 31'
  is  "…and the break declares three @Test methods, all of which pass" \
      "$(grep -c '@Test' "$REPO/c3-unit11/breaks/green-for-nothing/src/test/java/com/tiffinbox/GreenForNothingTest.java")" "3"

  # ---- breaks/one-assertion: the same wrong Customer, checked two ways. This one FAILS.
  expect_fail "breaks/one-assertion: mvn -B test -> exit 1, and two different failure reports" 900 \
      'Tests run: 2, Failures: 2' \
      bash -c 'cd "$REPO/c3-unit11/breaks/one-assertion" && mvn -B "-Dmaven.repo.local=$M2_U11" test'
  # counted inside the Failures: block, and per class inside its own entry — surefire's
  # runOrder is not a promise about which class is reported first, and 'the text is in there
  # somewhere' would read the same number whichever way round the two arrived.
  sed -n '/^\[ERROR\] Failures:/,/^\[ERROR\] Tests run:/p' "$OUT" > "$WORK/fails"
  N="$(awk '/^\[ERROR\]   ReportsAllOfThemTest\./{p=1;next} p&&/^\[ERROR\]   [A-Za-z]/{p=0} p&&/expected:/{c++} END{print c+0}' "$WORK/fails")"
  is "…assertAll named TWO failures inside its own report entry" "$N" "2"
  N="$(awk '/^\[ERROR\]   StopsAtTheFirstTest\./{p=1} p&&/expected:/{c++} p&&/^\[ERROR\] Tests run:/{p=0} END{print c+0}' "$WORK/fails")"
  is "…and the three-statements-in-a-row version named ONE — the first assert ends the method" "$N" "1"

  # ---- the exercise, both halves. The starter's whole output is 'No tests to run.'
  expect_ok "exercise: mvn -B test unedited -> No tests to run." 900 'No tests to run\.' \
      bash -c 'cd "$REPO/c3-unit11/exercise" && mvn -B "-Dmaven.repo.local=$M2_U11" test'
  has "…and BUILD SUCCESS under it — an empty suite is a green build" 'BUILD SUCCESS'
  hasnt "…with no Tests run: line at all, because surefire found no test directory" 'Tests run:'
  # the surefire NOBODY pinned: the exercise pom leaves it out on purpose, and Maven binds 3.5.4
  has "…run by surefire 3.5.4, Maven 3.9.16's own default binding, because this pom pins none" \
      'surefire:3\.5\.4:test'
  backup "$REPO/c3-unit11/exercise/pom.xml"
  cp "$REPO/c3-unit11/exercise/solution/pom.xml" "$REPO/c3-unit11/exercise/pom.xml"
  mkdir -p "$REPO/c3-unit11/exercise/src/test/java/com/tiffinbox"
  cp "$REPO/c3-unit11/exercise/solution/BillTest.java" \
     "$REPO/c3-unit11/exercise/src/test/java/com/tiffinbox/BillTest.java"
  created "$REPO/c3-unit11/exercise/src/test/java"
  expect_ok "exercise solution: the answer's pom + BillTest.java -> Tests run: 1, BUILD SUCCESS" 900 \
      'Tests run: 1, Failures: 0, Errors: 0, Skipped: 0' \
      bash -c 'cd "$REPO/c3-unit11/exercise" && mvn -B "-Dmaven.repo.local=$M2_U11" test'
  has "…and the answer's pom pins surefire, so this half is NOT run by 3.5.4" 'surefire:3\.6\.0:test'
  # …and that answer CONSTRAINS the three bills it names. A survivor this script did not catch when
  # it was first written: weaken the first `assertEquals(7200, ravi.monthlyBill())` to
  # `assertEquals(7200, 7200)` and `Tests run: 1`, `BUILD SUCCESS`, the receipts `solution` block
  # and its md5 are all exactly where they were, because none of them is a function of what the
  # answer asserts. So the exercise's own Customer is given the break's 31-day month for one run:
  # the answer has to go red, and — because it uses assertAll — has to name all THREE at once.
  # Weaken any one of them and that count is 2.
  backup "$REPO/c3-unit11/exercise/src/main/java/com/tiffinbox/Customer.java"
  sed -i '' 's/mealsPerDay \* pricePerMeal \* 30;/mealsPerDay * pricePerMeal * 31;/' \
      "$REPO/c3-unit11/exercise/src/main/java/com/tiffinbox/Customer.java"
  expect_fail "…and the answer CONSTRAINS all three bills: a 31-day month turns it red" 900 \
      'Tests run: 1, Failures: 1' \
      bash -c 'cd "$REPO/c3-unit11/exercise" && mvn -B "-Dmaven.repo.local=$M2_U11" test'
  has "…naming all THREE of them, because the answer is one assertAll" 'Multiple Failures \(3 failures\)'
  rm -rf "$REPO/c3-unit11/exercise/src/test" "$REPO/c3-unit11/exercise/target"
  restore_all

  # ---- receipts.sh. Ten blocks, and c3-unit11 is the one unit in this section whose README
  # writes the hashes down in a table — so they are read OUT OF the page, never transcribed
  # here, which is the only way this still fails when README and receipts.sh drift apart.
  if run_receipts 11 3600; then
    is "…and it printed ten blocks" "$(receipts_blocks 11)" "10"
    NP=0
    while IFS="$(printf '\t')" read -r RID RHASH REXIT; do
      [ -n "${RID:-}" ] || continue
      NP=$((NP+1))
      receipt_is 11 "$RID" "md5 $RHASH  exit $REXIT"
    done < <(receipts_table 11)
    is "…and c3-unit11/README.md's table carries ten (block, md5, exit) rows" "$NP" "10"
    # …and that the counts block's first number is DERIVED, not a literal. Replace
    # `$(grep -c '^\[INFO\] Tests run:' .r-counts.out)` with `"1"` — right today — and the line, the
    # block's md5 and the whole run's md5 do not move by one character, because a receipt and a
    # caption are the same bytes until the input does. So the input is moved: a SECOND test class,
    # with nothing skipped in it, is added to a copy of this unit and the block re-run there.
    # Surefire then prints that class's own line at [INFO] as well, so a derived pair answers
    # `2 of the 3`; a hardcoded first number keeps saying 1.
    D11="$WORK/d11"; rm -rf "$D11"; mkdir -p "$D11"
    ( cd "$REPO/c3-unit11" && tar cf - pom.xml src receipts.sh ) | ( cd "$D11" && tar xf - ) 2>/dev/null
    ln -s "$M2_U11" "$D11/.m2-demo"
    cat > "$D11/src/test/java/com/tiffinbox/DerivedProbeTest.java" <<'JAVA'
package com.tiffinbox;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

class DerivedProbeTest {
    @Test
    void aSecondClassVerifyCourse3Added() {
        assertEquals(7200, new Customer("Ravi", 2, 120, "VEG").monthlyBill());
    }
}
JAVA
    expect_ok "…and both numbers on its counts line are DERIVED, not literals: a second test class in a copy makes them 2 and 3" 900 \
        '^the \[INFO\] filter kept 2 of the 3 Tests run: lines surefire printed; this one is the suite total$' \
        bash -c "cd \"$D11\" && ./receipts.sh counts"
    rm -rf "$D11"

    # the two panels this unit's README prints out of receipts.sh, held to what it really got
    receipt_body 11 platform
    panel 11 '`platform` is the one block whose output does not appear on a slide' 1
    out_has_panel "…README's platform panel is what receipts.sh really printed"
    receipt_body 11 lifecycle
    panel 11 'So the block recomputes that hash over' 1
    out_has_panel "…README's lifecycle order panel is what receipts.sh really printed"
  fi

  # ---- the offline receipt, as a pair: online first into this repository, then -o in the same one
  offline_test 'mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -o test' 900 "$REPO/c3-unit11" "$M2_U11"
fi

# ============================================================= c3-unit12 ====
if unit 12 "One test, many cases — and the case name your build tool throws away"; then
  U12H="$(readme_hash 12 'cd src/main/java/com/tiffinbox && md5 -q')"
  is "cd src/main/java/com/tiffinbox && md5 -q *.java | sort | md5 -q -> the hash the README prints" \
     "$(src_hash "$REPO/c3-unit12/src/main/java/com/tiffinbox")" "$U12H"
  is "…and it is still c3-tiffinbox/tiffinbox-core's own hash — forked with no new dependency" \
     "$(src_hash "$REPO/c3-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox")" "$U12H"
  is "…and the source root holds exactly those five .java files" \
     "$(src_files "$REPO/c3-unit12/src/main/java")" "$FIVE_SRC"
  # "no new dependency at all — junit-jupiter already brings junit-jupiter-params"
  N="$(grep -c '<artifactId>junit-jupiter-params</artifactId>' "$REPO/c3-unit12/pom.xml" | tr -d ' ')"
  is "…and junit-jupiter-params is declared nowhere in the pom: junit-jupiter already brings it" "$N" "0"

  # ---- five test methods, twenty cases on the report
  expect_ok 'mvn -B -Dmaven.repo.local="$PWD/.m2-demo" test' 1200 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit12" && mvn -B "-Dmaven.repo.local=$M2_U12" test'
  has "…Tests run: 20 — twenty cases on the report" 'Tests run: 20, Failures: 0, Errors: 0, Skipped: 0'
  N="$(grep -hcE '^ *@(ParameterizedTest|TestFactory|Test)\b' "$REPO"/c3-unit12/src/test/java/com/tiffinbox/*.java | paste -sd+ - | bc)"
  is "…out of FIVE test methods in src/test/java — the runner did the looping, not the test" "$N" "5"
  sensitive_to "…and those twenty cases CONSTRAIN the bill: a 31-day month is noticed by 16 of the 20" \
      12 "$M2_U12" src/main/java/com/tiffinbox/Customer.java \
      "mealsPerDay * pricePerMeal * 30;" "mealsPerDay * pricePerMeal * 31;" \
      "Tests run: 20, Failures: 16, Errors: 0, Skipped: 0"

  # ---- breaks/loop-in-a-test: one bug, five rows, counted two ways
  expect_fail "breaks/loop-in-a-test: mvn -B test -> exit 1, the same bug counted two ways" 900 \
      'Tests run: 6, Failures: 6' \
      bash -c 'cd "$REPO/c3-unit12/breaks/loop-in-a-test" && mvn -B "-Dmaven.repo.local=$M2_U12" test'
  N="$(countq '^\[ERROR\]   LoopOverTheTableTest\.')"
  is "…the loop version reports ONE failure, whatever the table's length" "$N" "1"
  N="$(countq '^\[ERROR\]   OneCaseEachTest\.')"
  is "…the @ParameterizedTest version, over the same five rows and the same bug, reports FIVE" "$N" "5"
  # the bug itself is the 31-day month again, and it is the artifact, not the report
  bill_is "…and the Customer under both is billing 31 days: Ravi comes back 7440" \
      "$REPO/c3-unit12/breaks/loop-in-a-test/target/classes" "Ravi" 2 120 "7440"

  # ---- breaks/zero-cases: two test methods in the file, one line on the report, BUILD SUCCESS
  expect_ok "breaks/zero-cases: mvn -B test -> BUILD SUCCESS over a method that ran zero times" 900 \
      'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit12/breaks/zero-cases" && mvn -B "-Dmaven.repo.local=$M2_U12" test'
  has "…and the report says Tests run: 1" 'Tests run: 1, Failures: 0, Errors: 0, Skipped: 0'
  N="$(grep -cE '^ *@(ParameterizedTest|Test)\b' "$REPO/c3-unit12/breaks/zero-cases/src/test/java/com/tiffinbox/EmptySourceTest.java" | tr -d ' ')"
  is "…while the file declares TWO — the silenced one is not in the count at all" "$N" "2"
  is "…and the silencer is on the annotation itself, where a reader will not look" \
     "$(grep -c '@ParameterizedTest(allowZeroInvocations = true)' "$REPO/c3-unit12/breaks/zero-cases/src/test/java/com/tiffinbox/EmptySourceTest.java" | tr -d ' ')" "1"
  # …and the refusal it turns off is real. Same class, same empty source, the switch removed.
  rm -rf "$WORK/zero"; cp -R "$REPO/c3-unit12/breaks/zero-cases" "$WORK/zero"; rm -rf "$WORK/zero/target"
  sed -i '' 's/@ParameterizedTest(allowZeroInvocations = true)/@ParameterizedTest/' \
      "$WORK/zero/src/test/java/com/tiffinbox/EmptySourceTest.java"
  expect_fail "…and without that switch JUnit 6.1.3 refuses the empty source and the build fails" 900 \
      'You must configure at least one set of arguments for this @ParameterizedTest' \
      bash -c 'cd "$WORK/zero" && mvn -B "-Dmaven.repo.local=$M2_U12" test'
  rm -rf "$WORK/zero"

  # ---- breaks/name-thrown-away: the console cannot tell the two naming styles apart
  expect_fail "breaks/name-thrown-away: mvn -B test -> exit 1, the same case named two ways" 900 \
      'defaultName\(int, int, int\)\[4\]' \
      bash -c 'cd "$REPO/c3-unit12/breaks/name-thrown-away" && mvn -B "-Dmaven.repo.local=$M2_U12" test'
  N="$(countq 'meals x')"
  is "…and the phrased name reaches the console zero times, though the method carries one" "$N" "0"
  is "…because the method really does carry a name = pattern, and the console still will not print it" \
     "$(grep -c 'name = "{0} meals x {1} rupees -> {2}"' "$REPO/c3-unit12/breaks/name-thrown-away/src/test/java/com/tiffinbox/NamedCasesTest.java" | tr -d ' ')" "1"

  # ---- the exercise, both halves
  expect_ok "exercise: mvn -B test unedited -> Tests run: 1 over five rows" 900 \
      'Tests run: 1, Failures: 0, Errors: 0, Skipped: 0' \
      bash -c 'cd "$REPO/c3-unit12/exercise" && mvn -B "-Dmaven.repo.local=$M2_U12" test'
  backup "$REPO/c3-unit12/exercise/src/test/java/com/tiffinbox/PlanTableTest.java"
  cp "$REPO/c3-unit12/exercise/solution/PlanTableTest.java" \
     "$REPO/c3-unit12/exercise/src/test/java/com/tiffinbox/PlanTableTest.java"
  expect_ok "exercise solution: solution/PlanTableTest.java -> Tests run: 5, BUILD SUCCESS" 900 \
      'Tests run: 5, Failures: 0, Errors: 0, Skipped: 0' \
      bash -c 'cd "$REPO/c3-unit12/exercise" && mvn -B "-Dmaven.repo.local=$M2_U12" test'
  has "…and it is still one @ParameterizedTest, not five methods" 'BUILD SUCCESS'
  N="$(grep -c '@ParameterizedTest' "$REPO/c3-unit12/exercise/solution/PlanTableTest.java" | tr -d ' ')"
  is "…the answer declares ONE @ParameterizedTest and lets the runner count the rows" "$N" "1"
  restore_all

  # ---- receipts.sh. c3-unit12/README.md quotes ONE number, the md5 of the whole RUN, and says
  # in so many words that hashing receipts.sh itself is a different number. Both readings below.
  if run_receipts 12 3600; then
    is "…and it printed eight blocks, the count c3-unit12/README.md states" "$(receipts_blocks 12)" "8"
    U12R="$(readme_hash 12 './receipts.sh 2>&1 | md5 -q')"
    is "…./receipts.sh 2>&1 | md5 -q -> the md5 c3-unit12/README.md quotes for the whole run" \
       "$(receipts_md5 12)" "$U12R"
    # …and the six per-block hashes, which live only on the deck (12-parameterized-dynamic-tests.md).
    receipt_is 12 cases     "md5 f2d7236ccec93c8124043efe0bc31a4f  exit 0"
    receipt_is 12 break     "md5 950b82490fb791eeee4b5e294e816b59  exit 1"
    receipt_is 12 names     "md5 a2136c900ef9e1900ef44966691b262c  exit 1 then 0"
    receipt_is 12 plain     "md5 4c0327166284f402e8b2893a775b32c3  exit 1 then 0"
    receipt_is 12 assertall "md5 0dd5dea3369f4782afa31c10668ef6e7  exit 1 then 1"
    receipt_is 12 zero      "md5 9128b4e7f9520586f8a3cb39649a764b  exit 0 then 1"
    # …and its two counts are DERIVED, not literals. This is the survivor that is invisible to
    # every hash: replace `$(grep -rhcE '^\s+(@Test|@ParameterizedTest|@TestFactory)' …)` with the
    # literal `5` and the line, the block's md5 and the whole run's md5 are all unchanged, because
    # a receipt and a caption are the same bytes until the input moves. So the input is moved: a
    # sixth test method is added to a COPY of this unit and the block re-run there. A derived pair
    # answers 6 and 21; a literal keeps saying 5, and a literal case count keeps saying 20.
    D12="$WORK/d12"; rm -rf "$D12"; mkdir -p "$D12"
    ( cd "$REPO/c3-unit12" && tar cf - pom.xml src receipts.sh ) | ( cd "$D12" && tar xf - ) 2>/dev/null
    ln -s "$M2_U12" "$D12/.m2-demo"
    cat > "$D12/src/test/java/com/tiffinbox/DerivedProbeTest.java" <<'JAVA'
package com.tiffinbox;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

class DerivedProbeTest {
    @Test
    void aSixthTestMethodVerifyCourse3Added() {
        assertEquals(7200, new Customer("Ravi", 2, 120, "VEG").monthlyBill());
    }
}
JAVA
    expect_ok "…and both numbers on its cases line are DERIVED, not literals: a sixth test method in a copy makes them 6 and 21" 900 \
        '^6 test methods in src/test/java; 21 cases on the report$' \
        bash -c "cd \"$D12\" && ./receipts.sh cases"
    rm -rf "$D12"

    # assertAll fixes the MESSAGE, never the COUNT — the one sentence this unit's second half is
    # about, and the only place the three numbers appear together is that block's own output.
    receipt_body 12 assertall
    has "…receipts.sh assertall: hoisted out of the loop, assertAll names five rows" 'hoisted.*5|5.*hoisted'
    has "…and wrapped round the loop body it still names one" 'wrapped.*1|1.*wrapped'
  fi

  offline_test 'mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -o test' 900 "$REPO/c3-unit12" "$M2_U12"
fi

# ============================================================= c3-unit13 ====
if unit 13 "AssertJ: the unit whose subject is the failure message"; then
  U13H="$(readme_hash 13 'cd src/main/java/com/tiffinbox && md5 -q')"
  is "cd src/main/java/com/tiffinbox && md5 -q *.java | sort | md5 -q -> the hash the README prints" \
     "$(src_hash "$REPO/c3-unit13/src/main/java/com/tiffinbox")" "$U13H"
  is "…still c3-tiffinbox/tiffinbox-core's own, forked with ONE new dependency and no source change" \
     "$(src_hash "$REPO/c3-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox")" "$U13H"
  is "…and the source root holds exactly those five .java files" \
     "$(src_files "$REPO/c3-unit13/src/main/java")" "$FIVE_SRC"
  timed 60 cat "$REPO/c3-unit13/pom.xml"
  has "pom.xml pins assertj-core 3.27.7, the newest GA" '<artifactId>assertj-core</artifactId>'
  has "…at 3.27.7"        '<version>3\.27\.7</version>'
  # NOT 4.0.0-M1 — and the pom names that milestone in a comment explaining why it is not the
  # pin, so the assertion has to be about the <version> ELEMENT and not about the word anywhere.
  is "…and no <version> element in it is 4.0.0-M1, the milestone Central's <release> field points at" \
     "$(grep -c '<version>4\.0\.0-M1</version>' "$REPO/c3-unit13/pom.xml" | tr -d ' ')" "0"
  is "…while the comment above the pin does name it, which is how a reader learns why" \
     "$(grep -c '4\.0\.0-M1' "$REPO/c3-unit13/pom.xml" | tr -d ' ')" "1"

  expect_ok 'mvn -B -Dmaven.repo.local="$PWD/.m2-demo" test' 1200 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit13" && mvn -B "-Dmaven.repo.local=$M2_U13" test'
  has "…Tests run: 5, all green — the failures live in breaks/, and they are the unit" \
      'Tests run: 5, Failures: 0, Errors: 0, Skipped: 0'
  # …and the one assertion here that names a NUMBER is a threshold, so the probe has to land
  # between the two: bill one day instead of thirty and `isGreaterThanOrEqualTo(3000)` notices.
  # Lower that 3000 to anything a one-day bill clears and this line is the only thing that moves.
  sensitive_to "…and the soft assertions CONSTRAIN that threshold: a one-day bill is noticed by 1 of the 5" \
      13 "$M2_U13" src/main/java/com/tiffinbox/Customer.java \
      "mealsPerDay * pricePerMeal * 30;" "mealsPerDay * pricePerMeal * 1;" \
      "Tests run: 5, Failures: 1, Errors: 0, Skipped: 0"

  # ---- breaks/three-messages. Seven tests, every one failing on purpose; the lesson is what
  # each failure SAYS, so what is asserted is the three messages, not the exit code alone.
  expect_fail "breaks/three-messages: mvn -B test -> exit 1, seven failures on purpose" 900 \
      'Tests run: 7' \
      bash -c 'cd "$REPO/c3-unit13/breaks/three-messages" && mvn -B "-Dmaven.repo.local=$M2_U13" test'
  has "…assertTrue's whole contribution: expected: <true> but was: <false>" 'expected: <true> but was: <false>'
  has "…AssertJ prints the roster instead, and names the element that is missing" 'Priya'
  has "…and SoftAssertions reports all three at once" 'Multiple Failures \(3 failures\)'
  N="$(grep -hcE '^ *@Test' "$REPO"/c3-unit13/breaks/three-messages/src/test/java/com/tiffinbox/*.java | paste -sd+ - | bc)"
  is "…and the three classes really declare seven @Test methods between them" "$N" "7"

  # ---- central/: the version sweep, shipped as bytes so the <release> chip is checkable offline
  exists "central/assertj-core-maven-metadata.xml is shipped, so the sweep needs no network" \
      "$REPO/c3-unit13/central/assertj-core-maven-metadata.xml"
  exists "…and the directory listing beside it" "$REPO/c3-unit13/central/assertj-core-listing.html"
  timed 60 cat "$REPO/c3-unit13/central/assertj-core-maven-metadata.xml"
  has "…and Central's <release> field in those bytes really is the milestone, not the GA" \
      '<release>4\.0\.0-M1</release>'

  # ---- the exercise, both halves
  expect_fail "exercise: mvn -B test unedited -> the whole message is 'expected: <true> but was: <false>'" 900 \
      'RosterTest\.theKitchenKnowsAboutSunil:[0-9]+ expected: <true> but was: <false>' \
      bash -c 'cd "$REPO/c3-unit13/exercise" && mvn -B "-Dmaven.repo.local=$M2_U13" test'
  xpanel 13 'Right now that fails, and the whole message is' 1
  out_has_panel "…and that is the exercise README's panel, line for line"
  # step 1 is NOT run in place: solution/RosterTest.step1.java.txt is deliberately not a
  # compilable file — it is the one assertion plus the report it produces, because the MESSAGE is
  # the lesson rather than the green run. receipts.sh solution runs that state for real, and the
  # .txt is held to it below.
  backup "$REPO/c3-unit13/exercise/src/test/java/com/tiffinbox/RosterTest.java"
  cp "$REPO/c3-unit13/exercise/solution/RosterTest.java" \
     "$REPO/c3-unit13/exercise/src/test/java/com/tiffinbox/RosterTest.java"
  expect_ok "exercise solution: solution/RosterTest.java -> Tests run: 1, BUILD SUCCESS" 900 \
      'Tests run: 1, Failures: 0, Errors: 0, Skipped: 0' \
      bash -c 'cd "$REPO/c3-unit13/exercise" && mvn -B "-Dmaven.repo.local=$M2_U13" test'
  # …and the answer still LOOKS AT the roster. `Tests run: 1` and `BUILD SUCCESS` are true of an
  # answer that asserts nothing at all, and no hash in this unit covers what it asserts — so the
  # roster under it is moved by one character and the answer has to notice.
  sed -i '' 's/new Customer("Sunil", 3, 100, "VEG")/new Customer("Suniel", 3, 100, "VEG")/' \
      "$REPO/c3-unit13/exercise/src/test/java/com/tiffinbox/RosterTest.java"
  expect_fail "…and it CONSTRAINS the name it looks for: misspell the roster and the answer goes red" 900 \
      'but could not find the following element' \
      bash -c 'cd "$REPO/c3-unit13/exercise" && mvn -B "-Dmaven.repo.local=$M2_U13" test'
  has "…printing the roster it searched, which is the whole point of the rewrite" '"Ravi", "Meera", "Suniel"'
  restore_all

  # ---- receipts.sh: nine blocks, and BOTH readings of "the hash" the README is careful about
  if run_receipts 13 3600; then
    is "…and it printed nine blocks" "$(receipts_blocks 13)" "9"
    U13R="$(readme_hash 13 './receipts.sh 2>&1 | md5')"
    is "…./receipts.sh 2>&1 | md5 -> the md5 of the whole RUN that c3-unit13/README.md quotes" \
       "$(receipts_md5 13)" "$U13R"
    # the other reading, which the deck names precisely so a viewer does not conclude the
    # receipts are broken: hashing the FILE is a different number and is a receipt of nothing.
    is "…and md5 receipts.sh — the file, not the run — is still the number the deck warns about" \
       "$(md5of "$REPO/c3-unit13/receipts.sh")" "c8bbdfa90f04f08b3cad018c15c5217f"
    receipt_is 13 messages "md5 6da4bc0f4174295ab57e5958f7ff33b2  exit 1"
    receipt_is 13 source   "md5 243f933ff6060128e142f0fbd596a5c5  no build - this block reads the shipped source"
    receipt_is 13 records  "md5 4ce8c4efcebcf14042b9d10ff768032b  exit 1"
    receipt_is 13 softly   "md5 73c17e5bdf980d3562a1379ab02d2819  exit 1"
    receipt_is 13 unsafe   "md5 6a71c127dc14372c175322299d6496c7  exit 0 then 0"
    receipt_is 13 version  "md5 8db3799720e21fc190bb9f59d155ba0c  exit 0"
    receipt_is 13 release  "md5 0c5ce7edbf947e3330ead81298839f6f  no build - this block reads central/, fetched 2026-09-15 and shipped verbatim"
    receipt_is 13 solution "md5 35722400e3a8aba3e4573e858f9b7856  exit 1 then 1 then 0"
    receipt_is 13 offline  "md5 dd1c74f681b049d1e239e42bb4b0f8bd  exit 0"
    derived_unprobed 13
    # the README's <release> chip, held to the bytes in central/ rather than to prose. The page
    # lays the two versions out as a little table; the block derives them as one sentence, so what
    # is compared is the two DATES and the ordering finding, not the page's formatting.
    receipt_body 13 release
    has "…receipts.sh release: <release> is the milestone, and it is the last entry of the list" \
        '<release> is 4\.0\.0-M1 and the last entry of the list is 4\.0\.0-M1'
    has "…and it is not publication order: the milestone is ten months OLDER than the GA it hides" \
        '4\.0\.0-M1 was published 2025-03-09 and 3\.27\.7 on 2026-01-24, 10 months later'
    has "…nor text order: 3.9.1 sits before 3.10.0, which a text sort would reverse" \
        'not text order: entry 38 is 3\.9\.1 and entry 39 is 3\.10\.0'
    has "…it is version order, major first — and the pom pins the newest GA in that list" \
        'newest GA in the list: 3\.27\.7; pom\.xml pins: 3\.27\.7'
    readme_quotes "…and c3-unit13/README.md prints the 3.27.7 date the block derived" 13 "published 2026-01-24"
    readme_quotes "…and the 4.0.0-M1 one" 13 "published 2025-03-09"
    # the halfway state, which is the whole point of that exercise and lives only in a .txt file:
    # not compilable, so nothing else in this run would ever notice if its message went stale.
    receipt_body 13 solution
    awk '/^    \[ERROR\]   RosterTest/{c=1;next} c&&c<=6{sub(/^    /,"");print;c++}' \
        "$REPO/c3-unit13/exercise/solution/RosterTest.step1.java.txt" > "$WORK/panel"
    out_has_lines "…and solution/RosterTest.step1.java.txt still shows the message that state really prints" 
    # the Byte Buddy warning count, and the zero that only means something as a measurement
    receipt_body 13 unsafe
    has "…receipts.sh unsafe: byte-buddy appears 0 times in this pom" 'appears 0 time\(s\) in this pom'
    is  "…and the pom really does not declare it — grep -c, the same number the block prints" \
        "$(grep -c '<artifactId>byte-buddy</artifactId>' "$REPO/c3-unit13/pom.xml" | tr -d ' ')" "0"
  fi

  offline_test 'mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -o test' 900 "$REPO/c3-unit13" "$M2_U13"
fi

# ============================================================= c3-unit14 ====
if unit 14 "Test doubles, and Mockito doing the one job it is for"; then
  U14H="$(readme_hash 14 'cd src/main/java/com/tiffinbox && md5 -q')"
  is "cd src/main/java/com/tiffinbox && md5 -q *.java | sort | md5 -q -> the hash the README prints" \
     "$(src_hash "$REPO/c3-unit14/src/main/java/com/tiffinbox")" "$U14H"
  is "…the same five, byte for byte, as c3-tiffinbox/tiffinbox-core" \
     "$(src_hash "$REPO/c3-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox")" "$U14H"
  # THE reason that hash still means something here. The two new production classes live one
  # package DOWN, and `md5 -q *.java` is a non-recursive glob: the README says so in words, and
  # this is the measurement of that sentence. Move BillingService up into com/tiffinbox/ and the
  # hash above is wrong while every other check in this unit stays green.
  is "…and the five-file glob really is five files, with the two new classes one package down" \
     "$( cd "$REPO/c3-unit14/src/main/java/com/tiffinbox" && ls *.java | LC_ALL=C sort | tr '\n' ' ' )" \
     "Customer.java CustomerRepository.java Dashboard.java Database.java OrderQueue.java "
  is "…com/tiffinbox/billing/ holding exactly the two the unit added" \
     "$(src_files "$REPO/c3-unit14/src/main/java/com/tiffinbox/billing")" \
     "./BillingService.java ./PaymentGateway.java "
  timed 60 cat "$REPO/c3-unit14/pom.xml"
  has "pom.xml declares mockito-core"          '<artifactId>mockito-core</artifactId>'
  has "…and mockito-junit-jupiter"             '<artifactId>mockito-junit-jupiter</artifactId>'
  has "…both at 5.23.0"                        '<version>5\.23\.0</version>'
  # the quotes that stop the fork dying on a path with a space in it
  has "…and the static-agent argLine QUOTES the jar path — this tree's own path has a space in it" \
      '<argLine>-javaagent:"\$\{org\.mockito:mockito-core:jar\}"</argLine>'
  # surefire's version sits OUTSIDE the STATIC-AGENT markers on purpose: run_warn deletes that
  # region and both halves must still fork the same surefire, or the contrast measures two things.
  N="$(awk '/STATIC-AGENT/{f=!f} !f && /<artifactId>maven-surefire-plugin<\/artifactId>/{c++} END{print c+0}' "$REPO/c3-unit14/pom.xml")"
  is "…and maven-surefire-plugin's version is pinned OUTSIDE the STATIC-AGENT markers" "$N" "1"

  expect_ok 'mvn -B -Dmaven.repo.local="$PWD/.m2-demo" test' 1200 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit14" && mvn -B "-Dmaven.repo.local=$M2_U14" test'
  has "…Tests run: 9 — four hand-written doubles plus the framework's fifth word" \
      'Tests run: 9, Failures: 0, Errors: 0, Skipped: 0'
  hasnt "…and Mockito is NOT self-attaching, because the agent is declared statically" 'self-attaching'
  is "…byte-buddy appears zero times in this pom: it is nobody's declared dependency" \
     "$(grep -c '<artifactId>byte-buddy</artifactId>' "$REPO/c3-unit14/pom.xml" | tr -d ' ')" "0"
  # …and this suite really would catch the bug the break ships. Give the SHIPPED BillingService the
  # break's one-meal charge and five of the nine tests notice; a suite that stopped naming the
  # amount would stay green and no count, hash or exit code in this unit would move.
  sensitive_to "…and they CONSTRAIN the amount: give the shipped service the break's one-meal charge and 5 of the 9 notice" \
      14 "$M2_U14" src/main/java/com/tiffinbox/billing/BillingService.java \
      "gateway.charge(c.name(), c.monthlyBill());" "gateway.charge(c.name(), c.pricePerMeal());" \
      "Tests run: 9, Failures: 4, Errors: 1, Skipped: 0"

  # ---- the break. Two green verifies over a service that charges 120 where the bill is 7200.
  # The run is RED overall (the captor class fails), so the exit code proves nothing about the two
  # that passed — which is exactly why the amount is measured directly below.
  expect_fail "breaks/verified-nothing: mvn -B test -> the captor fails where the two verifies passed" 900 \
      'expected: 7200' \
      bash -c 'cd "$REPO/c3-unit14/breaks/verified-nothing" && mvn -B "-Dmaven.repo.local=$M2_U14" test'
  has "… but was: 120 — the captured value is the artifact, not the green run" ' but was: 120'
  N="$(countq '^\[ERROR\]   GreenAndWrongTest\.')"
  is "…and NOT ONE of the two tests in GreenAndWrongTest is in the failure list" "$N" "0"
  # THE assertion of this beat: what the service really hands the gateway. verify(…, anyInt())
  # is satisfied by every possible answer, so a green `verify` says nothing at all; 120 does.
  charged_is "…BillingService really hands the gateway 120 — one meal, where the month is 7200" \
      "$REPO/c3-unit14/breaks/verified-nothing/target/classes" "Ravi" 2 120 "120"
  timed 60 cat "$REPO/c3-unit14/breaks/verified-nothing/src/test/java/com/tiffinbox/billing/GreenAndWrongTest.java"
  has "…and the two green tests really do ask only for a call of that SHAPE" 'anyInt\(\)'

  # ---- the exercise. Its END STATE is a FAILURE, which is the whole point of the unit.
  expect_ok "exercise: mvn -B test unedited -> Tests run: 1, BUILD SUCCESS, and the wrong amount" 900 \
      'Tests run: 1, Failures: 0, Errors: 0, Skipped: 0' \
      bash -c 'cd "$REPO/c3-unit14/exercise" && mvn -B "-Dmaven.repo.local=$M2_U14" test'
  has "…green" 'BUILD SUCCESS'
  charged_is "…over a BillingService that hands the gateway 120, not 7200" \
      "$REPO/c3-unit14/exercise/target/classes" "Ravi" 2 120 "120"
  backup "$REPO/c3-unit14/exercise/src/test/java/com/tiffinbox/billing/ChargeTest.java"
  cp "$REPO/c3-unit14/exercise/solution/ChargeTest.java" \
     "$REPO/c3-unit14/exercise/src/test/java/com/tiffinbox/billing/ChargeTest.java"
  expect_fail "exercise answer: the ArgumentCaptor version -> the end state IS a failure" 900 \
      'ChargeTest\.raviIsChargedHisMonthlyBill' \
      bash -c 'cd "$REPO/c3-unit14/exercise" && mvn -B "-Dmaven.repo.local=$M2_U14" test'
  xpanel 14 'The end state to reach' 1
  panel_drop 1     # the README says the line number after the method name is not part of its acceptance
  out_has_panel "…and the two lines under the method name are the exercise README's, verbatim"
  backup "$REPO/c3-unit14/exercise/src/main/java/com/tiffinbox/billing/BillingService.java"
  cp "$REPO/c3-unit14/exercise/solution/BillingService.java" \
     "$REPO/c3-unit14/exercise/src/main/java/com/tiffinbox/billing/BillingService.java"
  expect_ok "…and solution/BillingService.java is the one-word fix that makes it green" 900 \
      'Tests run: 1, Failures: 0, Errors: 0, Skipped: 0' \
      bash -c 'cd "$REPO/c3-unit14/exercise" && mvn -B "-Dmaven.repo.local=$M2_U14" test'
  charged_is "…because it now hands the gateway 7200" \
      "$REPO/c3-unit14/exercise/target/classes" "Ravi" 2 120 "7200"
  restore_all

  # ---- receipts.sh: eight blocks, seven hashes on the deck (14-test-doubles-and-mockito.md),
  # plus the whole-run number. c3-unit14/README.md quotes none of them, so these are the deck's.
  #
  # RECENTLY FIXED, SO VERIFIED HERE RATHER THAN REDISCOVERED. `run_spacetrap` used to be unable
  # to run from a checkout whose OWN path contains a space — and this tree's does (`Youtube
  # Content`), which is the very hazard that block exists to teach. It builds its trap by
  # symlinking the local repository under a directory called `m2 demo`, and its guard required
  # surefire's `Command was …` line to show
  #     '-javaagent:<…>.space' 'trap/m2'
  # — the `-javaagent:` token ITSELF ending in `.space`. From a path that already has a space in
  # it, surefire tears the argument at the FIRST space instead, somewhere inside the checkout
  # path, so that token ended in `Youtube`, the guard did not match, and the block died with
  # "this failure is not the space trap" on a run where the trap had fired exactly as designed.
  #
  # The guard is now the two ADJACENT tokens — `'[^']*\.space' 'trap/m2'` — without insisting the
  # first is the agent's own, which is true from either kind of path. So the block runs IN PLACE
  # here, and two things are asserted rather than assumed: that the widened form is what
  # receipts.sh really carries on its `split=` line (the narrow one cannot come back without this
  # failing), and that the block completes from this spaced path with the deck's own hash and its
  # `exit 1 then 0` — which is the whole claim the fix makes.
  is "receipts.sh spacetrap's guard is the PATH-INDEPENDENT form: two ADJACENT tokens, not the agent's own token ending in .space" \
     "$(grep -F "'[^']*\\.space' 'trap/m2'" "$REPO/c3-unit14/receipts.sh" | grep -c '^ *split=' | tr -d ' ')" "1"
  expect_ok "receipts.sh spacetrap, run IN PLACE from this checkout — and this checkout's own path is the hazard" 1800 \
      '^md5 c34582e7e4035b1e925c475eaba03461  exit 1 then 0$' \
      bash -c "cd \"$REPO/c3-unit14\" && ./receipts.sh spacetrap"
  U14DIR="$REPO/c3-unit14"
  if expect_ok "c3-unit14/receipts.sh — every block, from this clone" 3600 '' \
      bash -c "cd \"$U14DIR\" && ./receipts.sh"; then
    cp "$OUT" "$WORK/receipts.14"
    is "…and it printed eight blocks" "$(receipts_blocks 14)" "8"
    is "…./receipts.sh | md5 -> the whole-script hash the deck quotes" \
       "$(receipts_md5 14)" "5194e04a0e748099330175d5001ce54a"
    receipt_is 14 doubles   "md5 c030c244d7410d347620b1fa3ba28dc8  exit 0"
    receipt_is 14 spacetrap "md5 c34582e7e4035b1e925c475eaba03461  exit 1 then 0"
    receipt_is 14 flags     "md5 87458d528c4005f275108108bc943a1e  exit 0"
    receipt_is 14 bytebuddy "md5 cec564d104b2df1fc5285728cb34120e  exit 0"
    receipt_is 14 break     "md5 8333f03da3e4f06f353b476552938ede  exit 1"
    derived_unprobed 14
    # `warn` is the one block that prints TWO md5 lines, one per half of its contrast
    is "…receipts.sh warn -> the before/after pair the deck quotes" \
       "$(block_tail 14 warn | tr '\n' '|')" \
       "md5 before aa7a579eb37f09049edcb20d15d78221  exit 0|md5 after  d0d6c46d817b071e156549d3775db489  exit 0|"
    # the flags table, exactly as c3-unit14/README.md prints it
    receipt_body 14 flags
    panel 14 'tries four flags against it' 1
    out_has_panel "…README's five-row flags table is what receipts.sh really measured"
    # and the sentence the break block exists for: a grep for capture() could not tell the
    # difference in either direction, so the block re-runs the green class against a third
    # wrong amount and counts what it noticed.
    receipt_body 14 break
    has "…receipts.sh break: the 2 that passed, re-run against a third wrong amount, noticed it 0 times" \
        'the 2 that passed, re-run against a third wrong amount, noticed it 0 time\(s\)'
    readme_quotes "…and c3-unit14/README.md prints that same derived sentence" 14 \
        "3 test(s) ran; 1 failed; the 2 that passed, re-run against a third wrong amount, noticed it 0 time(s)"
  fi

  offline_test 'mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -o test' 900 "$REPO/c3-unit14" "$M2_U14"
fi

# ============================================================= c3-unit15 ====
if unit 15 "Mockito's sharp edges: a green test over broken SQL"; then
  U15H="$(readme_hash 15 'Both print')"
  is "cd src/main/java/com/tiffinbox && md5 -q *.java | sort | md5 -q -> the hash the README prints" \
     "$(src_hash "$REPO/c3-unit15/src/main/java/com/tiffinbox")" "$U15H"
  is "…and c3-unit11's own source root prints the same one, which is what the README claims" \
     "$(src_hash "$REPO/c3-unit11/src/main/java/com/tiffinbox")" "$U15H"
  is "…and the source root holds exactly those five .java files" \
     "$(src_files "$REPO/c3-unit15/src/main/java")" "$FIVE_SRC"

  timed 60 cat "$REPO/c3-unit15/pom.xml"
  has "pom.xml declares mockito-core and mockito-junit-jupiter" '<artifactId>mockito-junit-jupiter</artifactId>'
  is "…both at 5.23.0, the version this unit's deck quotes" \
     "$(grep -c '<version>5\.23\.0</version>' "$REPO/c3-unit15/pom.xml" | tr -d ' ')" "2"
  is "…and assertj-core at 3.27.7, carried from the unit before it" \
     "$(awk '/<artifactId>assertj-core<\/artifactId>/{getline; print}' "$REPO/c3-unit15/pom.xml" | tr -d ' ')" \
     "<version>3.27.7</version>"
  has "…and the static-agent argLine QUOTES the jar path" \
      '<argLine>-javaagent:"\$\{org\.mockito:mockito-core:jar\}"</argLine>'

  expect_ok 'mvn -B -Dmaven.repo.local="$PWD/.m2-demo" test' 1200 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit15" && mvn -B "-Dmaven.repo.local=$M2_U15" test'
  has "…Tests run: 4 — a mock of our own boundary, a fake over real H2, and the strict-stub shape" \
      'Tests run: 4, Failures: 0, Errors: 0, Skipped: 0'
  hasnt "…and Mockito is not self-attaching: the agent is declared in the POM" 'self-attaching'
  # A mocked boundary cannot see a production change — that is this unit's own lesson, and it is
  # why the 31-day probe the other units use says nothing here. So the STUB is moved instead: same
  # class, same mock, one different canned answer. A test that names the number goes red; the one
  # that stopped naming it (`isEqualTo(24300)` weakened to `.isNotNegative()`) does not.
  sensitive_to "…and MockedRepositoryTest CONSTRAINS the value it stubs: change the canned answer and 1 of the 4 notices" \
      15 "$M2_U15" src/test/java/com/tiffinbox/MockedRepositoryTest.java \
      "when(repo.monthRevenue()).thenReturn(24300);" "when(repo.monthRevenue()).thenReturn(99999);" \
      "Tests run: 4, Failures: 1, Errors: 0, Skipped: 0"

  # ---- breaks/green-over-broken. ONE character wrong in the SQL. The mocked test passes
  # *because its stubs were written by reading the same broken code*; the real database does not.
  expect_fail "breaks/green-over-broken: mvn -B test -> the mocked test is green, the real one is not" 900 \
      'Column "MEAL_TYP" not found' \
      bash -c 'cd "$REPO/c3-unit15/breaks/green-over-broken" && mvn -B "-Dmaven.repo.local=$M2_U15" test'
  N="$(countq '^\[ERROR\]   MockedJdbcTest\.')"
  is "…MockedJdbcTest is in no failure entry at all — a mock of somebody else's type only ever agrees with you" "$N" "0"
  has "…and RealDatabaseTest is the one that failed" 'RealDatabaseTest'
  # the artifact: the character itself, in the two files that disagree
  timed 60 grep -n 'meal_typ' "$REPO/c3-unit15/breaks/green-over-broken/src/main/java/com/tiffinbox/CustomerRepository.java"
  has "…the SELECT really asks for meal_typ" 'SELECT name, meals_per_day, price_per_meal, meal_typ FROM customer'
  timed 60 grep -n 'meal_type' "$REPO/c3-unit15/breaks/green-over-broken/src/main/java/com/tiffinbox/Database.java"
  has "…while the CREATE TABLE beside it declares meal_type" 'meal_type +VARCHAR'

  # ---- breaks/strict-vs-lenient: the same unused stub under both settings, in one run
  expect_fail "breaks/strict-vs-lenient: mvn -B test -> strict reports UnnecessaryStubbing, lenient says nothing" 900 \
      'UnnecessaryStubbing' \
      bash -c 'cd "$REPO/c3-unit15/breaks/strict-vs-lenient" && mvn -B "-Dmaven.repo.local=$M2_U15" test'
  N="$(countq '^\[ERROR\]   LenientTest\.')"
  is "…and the LENIENT copy of the same class reports nothing — that is the hazard" "$N" "0"
  has "…while the strict one names the line" 'StrictTest'
  is "…and the two classes really are the same test twice, one carrying @MockitoSettings" \
     "$(grep -c 'Strictness.LENIENT' "$REPO/c3-unit15/breaks/strict-vs-lenient/src/test/java/com/tiffinbox/LenientTest.java" | tr -d ' ')" "1"

  # ---- the exercise, both halves. The starting state is RED, on purpose.
  expect_fail "exercise: mvn -B test unedited -> UnnecessaryStubbing, Tests run: 2, Errors: 1" 900 \
      'UnnecessaryStubbing' \
      bash -c 'cd "$REPO/c3-unit15/exercise" && mvn -B "-Dmaven.repo.local=$M2_U15" test'
  has "…Tests run: 2, Failures: 0, Errors: 1" 'Tests run: 2, Failures: 0, Errors: 1, Skipped: 0'
  has "…and Mockito names the two lines by number" 'PausesTest\.java:2[01]'
  backup "$REPO/c3-unit15/exercise/src/test/java/com/tiffinbox/PausesTest.java"
  cp "$REPO/c3-unit15/exercise/solution/PausesTest.java" \
     "$REPO/c3-unit15/exercise/src/test/java/com/tiffinbox/PausesTest.java"
  expect_ok "exercise solution: the two stubs deleted -> Tests run: 2, BUILD SUCCESS" 900 \
      'Tests run: 2, Failures: 0, Errors: 0, Skipped: 0' \
      bash -c 'cd "$REPO/c3-unit15/exercise" && mvn -B "-Dmaven.repo.local=$M2_U15" test'
  # the fix is deletion, not @MockitoSettings — the exercise README says so in so many words
  is "…and the answer does NOT reach for Strictness.LENIENT to make the message go away" \
     "$(grep -c 'LENIENT' "$REPO/c3-unit15/exercise/solution/PausesTest.java" | tr -d ' ')" "0"
  is "…it deletes stubs: 4 when(…) lines in the starter, 2 in the answer" \
     "$(grep -c 'when(' "$REPO/c3-unit15/exercise/src/test/java/com/tiffinbox/PausesTest.java" | tr -d ' ')" "2"
  # …and the two it keeps are the two it ASSERTS on. `Tests run: 2` and `BUILD SUCCESS` are true of
  # an answer whose assertions say nothing, and the stub count alone cannot tell the difference —
  # so one canned answer is moved and one of the two tests has to notice.
  sed -i '' 's/when(repo.pausedDays()).thenReturn(5);/when(repo.pausedDays()).thenReturn(6);/' \
      "$REPO/c3-unit15/exercise/src/test/java/com/tiffinbox/PausesTest.java"
  expect_fail "…and it CONSTRAINS what those stubs return: change one canned answer and 1 of the 2 goes red" 900 \
      'Tests run: 2, Failures: 1, Errors: 0, Skipped: 0' \
      bash -c 'cd "$REPO/c3-unit15/exercise" && mvn -B "-Dmaven.repo.local=$M2_U15" test'
  restore_all
  is "…and the starter really carries the four" \
     "$(grep -c 'when(' "$REPO/c3-unit15/exercise/src/test/java/com/tiffinbox/PausesTest.java" | tr -d ' ')" "4"

  # ---- receipts.sh: ten blocks. c3-unit15/README.md quotes the whole-run md5; the ten per-block
  # hashes live on the deck (15-mockito-sharp-edges.md).
  if run_receipts 15 3600; then
    is "…and it printed ten blocks" "$(receipts_blocks 15)" "10"
    U15R="$(readme_hash 15 './receipts.sh | md5')"
    is "…./receipts.sh | md5 -> the md5 of the whole run that c3-unit15/README.md quotes" \
       "$(receipts_md5 15)" "$U15R"
    receipt_is 15 tests    "md5 c2ba52d3218b4c90ce0f4af487472397  exit 0"
    receipt_is 15 counts   "md5 8de5a53ad4be939f9fc154d2731785ed  exit 0"
    receipt_is 15 strict   "md5 552fcea51f23fe2952218470a1dc053c  exit 1"
    receipt_is 15 doubles  "md5 f9cbc359f9ddc4d3db93012073230aca  exit 0"
    receipt_is 15 quoting  "md5 c11cf094c34aea27e015442aeceb00b0  exit 1 then 0"
    receipt_is 15 exercise "md5 affcd166ae46065a85242c7ac7ca2b25  exit 1"
    receipt_is 15 solution "md5 6ffe3e00f5bf40e13f048989cab730ae  exit 0"
    receipt_is 15 offline  "md5 34f321bd001f4095704674bd7053bde4  exit 0"
    derived_unprobed 15
    # `green` prints two md5 lines: the mocked class's single green line, and the Results: block
    is "…receipts.sh green -> the mocked/green pair the deck quotes" \
       "$(block_tail 15 green | tr '\n' '|')" \
       "md5 0133599168cf7507d1a4a536fcf63125  exit 1|md5 b97f9930e4117e11b7d949970edd95b9  exit 1|"
    # the quoting trap, which is the same hazard as -Dmaven.repo.local and is measured, not hoped
    receipt_body 15 quoting
    has "…receipts.sh quoting: unquoted -> 0 tests ran; quoted -> 4 tests ran" \
        'unquoted -> exit 1, 0 test\(s\) ran; quoted -> exit 0, 4 test\(s\) ran'
    has "…and the verdict comes from the two exit codes, not from an adjective" \
        'the quotes are load bearing on this machine: yes'
    panel 15 'unquoted run succeeds:' 1
    out_has_panel "…and README's quoting panel is what that block really printed"
  fi

  offline_test 'mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -o test' 900 "$REPO/c3-unit15" "$M2_U15"
fi

# ============================================================= c3-unit16 ====
# The one unit in this section whose headline number is deliberately NOT a number. Its race
# beat has no reproducible failure rate — the README says that out loud, and says why — so the
# assertions below hold the page to the claim it actually makes: that the rate varies, that the
# block prints both numbers on every row, and that the three flaky blocks carry NO md5 and say
# so. Asserting "3 of 12" here would be inventing a receipt the page refused to give.
if unit 16 "Testing concurrency and time: a clock you can set, a race you cannot count"; then
  U16H="$(readme_hash 11 'Both print')"     # the section's carried-five hash, from c3-unit11's page
  # `md5 -q *.java` would be SIX files here: Billing.java sits in the same package. c3-unit16's
  # README names the five by hand for exactly that reason, and this is that command.
  is "md5 -q Customer.java CustomerRepository.java Dashboard.java Database.java OrderQueue.java | sort | md5 -q" \
     "$(src_hash5 "$REPO/c3-unit16/src/main/java/com/tiffinbox")" "$U16H"
  is "…and the package holds those five plus Billing.java, the one new class, and nothing else" \
     "$(src_files "$REPO/c3-unit16/src/main/java")" \
     "./com/tiffinbox/Billing.java ./com/tiffinbox/Customer.java ./com/tiffinbox/CustomerRepository.java ./com/tiffinbox/Dashboard.java ./com/tiffinbox/Database.java ./com/tiffinbox/OrderQueue.java "
  # counted over the CODE, not the file: Billing.java's own javadoc says "Nothing below calls
  # LocalDate.now() with no argument", so a grep over the whole file reads 1 and means nothing.
  is "…and nothing in Billing.java calls LocalDate.now() with no argument — that is the seam" \
     "$(grep -vE '^\s*(\*|//|/\*)' "$REPO/c3-unit16/src/main/java/com/tiffinbox/Billing.java" | grep -c 'LocalDate\.now()' | tr -d ' ')" "0"
  is "…it asks the Clock it was handed" \
     "$(grep -c 'LocalDate\.now(clock)' "$REPO/c3-unit16/src/main/java/com/tiffinbox/Billing.java" | tr -d ' ')" "1"

  is "pom.xml pins awaitility at 4.3.0, the one new dependency this unit declares" \
     "$(awk '/<artifactId>awaitility<\/artifactId>/{getline; print}' "$REPO/c3-unit16/pom.xml" | tr -d ' ')" \
     "<version>4.3.0</version>"
  is "…and declares no Mockito at all: no agent is on this classpath" \
     "$(grep -c 'mockito' "$REPO/c3-unit16/pom.xml" | tr -d ' ')" "0"

  expect_ok 'mvn -B -Dmaven.repo.local="$PWD/.m2-demo" test' 1200 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit16" && mvn -B "-Dmaven.repo.local=$M2_U16" test'
  has "…Tests run: 6 — four fixed dates plus the two rewrites of the race" \
      'Tests run: 6, Failures: 0, Errors: 0, Skipped: 0'
  # …and the four fixed dates CONSTRAIN the arithmetic. Put breaks/wrong-arithmetic's own bug into
  # the shipped class — `30 - dayOfMonth` where `lengthOfMonth() - dayOfMonth` belongs — and two of
  # the six notice. A BillingTest that stopped naming the days would stay green under it.
  sensitive_to "…and the four dates CONSTRAIN the arithmetic: put the break's own bug in the shipped clock and 2 of the 6 notice" \
      16 "$M2_U16" src/main/java/com/tiffinbox/Billing.java \
      "return d.lengthOfMonth() - d.getDayOfMonth();" "return 30 - d.getDayOfMonth();" \
      "Tests run: 6, Failures: 2, Errors: 0, Skipped: 0"

  # ---- the clock. 30 - dayOfMonth is invisible on the 120 days of the year that have 30 in them.
  expect_fail "breaks/wrong-arithmetic: mvn -B test -> exit 1, and the count it is wrong on" 900 \
      'agrees with the calendar on 120 of 365 days in 2026' \
      bash -c 'cd "$REPO/c3-unit16/breaks/wrong-arithmetic" && mvn -B "-Dmaven.repo.local=$M2_U16" test'
  has "…and on 31 January it is not: expected: 0 but was: -1" 'expected: 0'
  has "…but was: -1"                                          'but was: -1'
  timed 60 cat "$REPO/c3-unit16/breaks/wrong-arithmetic/src/main/java/com/tiffinbox/Billing.java"
  has "…the arithmetic that does it is still written 30 - dayOfMonth" 'return 30 - today\(\)\.getDayOfMonth\(\);'
  hasnt "…not lengthOfMonth(), which is what the shipped class uses" 'lengthOfMonth\(\)'

  # ---- the flake. What this script may assert about it is what the README claims about it,
  # and the README refuses to give a rate. So: the beat still races (the sleep is still there,
  # the class still declares its tests), and the page still says the number cannot be quoted.
  readme_quotes "README still refuses to quote a failure rate for this race" 16 \
      "**Your numbers will differ, and that is the point.**"
  readme_quotes "…and still says the spread inside one configuration beat the gap between configurations" 16 \
      "tell you the failure rate of this race, and it will not tell you its shape either"
  is "…and breaks/sleep-race still stands in a Thread.sleep for a barrier" \
     "$(grep -c 'Thread\.sleep' "$REPO/c3-unit16/breaks/sleep-race/src/test/java/com/tiffinbox/RailSleepTest.java" | tr -d ' ')" "1"
  is "…over the queue length the README reads out of that file — 20 000 orders, written 20_000" \
     "$(grep -oE 'Integer\.getInteger\("orders", [0-9_]+\)' "$REPO/c3-unit16/breaks/sleep-race/src/test/java/com/tiffinbox/RailSleepTest.java" | grep -oE '[0-9_]+\)' | tr -d '_)')" "20000"
  # the two rewrites, on the other hand, are NOT flaky and that is assertable: run each one.
  expect_ok "RailCloseFirstTest + RailAwaitilityTest: mvn -B test -Dtest='Rail*' -> the fixed pair is green" 900 \
      'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit16" && mvn -B "-Dmaven.repo.local=$M2_U16" test -Dtest=RailCloseFirstTest,RailAwaitilityTest -DfailIfNoSpecifiedTests=true'
  has "…and both really ran: Tests run: 2" 'Tests run: 2, Failures: 0, Errors: 0, Skipped: 0'

  # ---- the exercise. Its starting state does not even COMPILE, which is the acceptance.
  expect_fail "exercise: mvn -B test unedited -> COMPILATION ERROR, there is no Clock to hand it" 900 \
      'constructor Billing in class com\.tiffinbox\.Billing cannot be applied to given types' \
      bash -c 'cd "$REPO/c3-unit16/exercise" && mvn -B "-Dmaven.repo.local=$M2_U16" test'
  has "…BUILD FAILURE, not a red test" 'BUILD FAILURE'
  backup "$REPO/c3-unit16/exercise/src/main/java/com/tiffinbox/Billing.java"
  cp "$REPO/c3-unit16/exercise/solution/Billing.java" \
     "$REPO/c3-unit16/exercise/src/main/java/com/tiffinbox/Billing.java"
  expect_ok "exercise solution: solution/Billing.java -> Tests run: 2, BUILD SUCCESS" 900 \
      'Tests run: 2, Failures: 0, Errors: 0, Skipped: 0' \
      bash -c 'cd "$REPO/c3-unit16/exercise" && mvn -B "-Dmaven.repo.local=$M2_U16" test'
  # "Change nothing else: BillingTest.java is the specification - do not edit it." The receipt for
  # that sentence is what the answer ships: one file, and it is the production class.
  is "…and the answer is the production class alone — BillingTest.java is the specification, untouched" \
     "$(ls "$REPO/c3-unit16/exercise/solution" | tr '\n' ' ')" "Billing.java "
  restore_all

  # ---- receipts.sh. The five deterministic blocks are run as the README's own command prints
  # them, and hashed; race/retry/fixed are run separately with the RUNS knob the README documents,
  # and asserted to carry NO md5 — because a flake has no byte-identical output, and saying so is
  # the finding rather than a gap.
  if expect_ok "c3-unit16/receipts.sh tests clock classpath solution offline — the deterministic five" 3600 '' \
      bash -c 'cd "$REPO/c3-unit16" && ./receipts.sh tests clock classpath solution offline'; then
    cp "$OUT" "$WORK/receipts.16"
    is "…five blocks" "$(receipts_blocks 16)" "5"
    U16R="$(readme_hash 16 'whole-output md5')"
    is "…and their combined output is the md5 c3-unit16/README.md quotes" "$(receipts_md5 16)" "$U16R"
    receipt_is 16 tests     "md5 c724ff44ebce3ffd223d654bef76e2f0  exit 0"
    receipt_is 16 clock     "md5 d915ee30eddb35efa3f85715b0ebe8a2  exit 1"
    receipt_is 16 classpath "md5 939c27594066d3165d7829e1ac2b7f31  exit 0"
    receipt_is 16 solution  "md5 268aafd6c73386c400ee2967f450bad3  exit 0"
    receipt_is 16 offline   "md5 e119de6084ff170590fb1e43386284d0  exit 0"
    derived_unprobed 16
    receipt_body 16 classpath
    panel 16 'prints the rule it counted under, and diffs the two lists' 1
    out_has_panel "…README's classpath panel is what that block really measured"
  fi
  U16RUNS=4; [ "$SKIP_SLOW" = "1" ] && U16RUNS=2
  if expect_ok "c3-unit16/receipts.sh race retry fixed (RUNS=$U16RUNS — the knob the README documents)" 3600 '' \
      bash -c "cd \"$REPO/c3-unit16\" && RUNS=$U16RUNS ./receipts.sh race retry fixed"; then
    cp "$OUT" "$WORK/receipts.16f"
    N="$(grep -cE '^md5 ' "$WORK/receipts.16f" | tr -d ' ')"
    is "…and not one of those three blocks printed an md5: a flake has no byte-identical output" "$N" "0"
    has "…race prints BOTH numbers on every row — runs and failures, because neither means anything alone" \
        "failed [0-9]+ of $U16RUNS runs of .mvn test. in this session"
    has "…and it prints the queue length it read out of RailSleepTest.java, not one somebody typed" \
        'the length this test ships with, read out of RailSleepTest\.java: 20000'
    has "…retry: surefire rescues a lost race and the build goes green with a [WARNING] nobody reads" \
        'passed WITH a recorded flake'
    has "…fixed: 0 failures each, and the test count asserted on every run so that is not 0-over-nothing" \
        '0 failure\(s\)|failed 0 of '"$U16RUNS"
  fi
fi

# ============================================================= c3-unit17 ====
# The unit that ships a bug on purpose under 100% line AND branch coverage. Three things here
# are assertions nothing else in this script makes:
#   * the JaCoCo CSV row for Pricing is compared as a STRING, before and after the fix, because
#     "the two rows are identical" is the whole lesson and a percentage would hide it;
#   * the break is a build that EXITS 0 — its coverage agent never loaded — so the assertion is
#     the file that proves the tool ran (`target/jacoco.exec`), never the word SUCCESS;
#   * the whole-run roll-up is asserted to be PATH-INDEPENDENT. Every capture in this unit is
#     masked to `<project>/`, and that is what makes one number true from two different
#     checkouts. If this line ever fails, the thing to fix is the masking, not the number.
if unit 17 "Coverage, and what it does not tell you"; then
  timed 60 cat "$REPO/c3-unit17/src/main/java/com/tiffinbox/Pricing.java"
  has "Pricing's javadoc states the rule: 6000 rupees and above is SILVER" '6000 rupees and above: SILVER'
  has "…and the code branches on bill > 6_000 — the bug, on purpose, still there" 'if \(bill > 6_000\) \{'
  hasnt "…it is NOT >= yet; that is the exercise" 'if \(bill >= 6_000\) \{'
  # the artifact of that bug, run rather than read: a bill of exactly 6000 comes back BRONZE.
  timed 60 cat "$REPO/c3-unit17/pom.xml"
  has "pom.xml carries jacoco-maven-plugin"              '<artifactId>jacoco-maven-plugin</artifactId>'
  has "…and the surefire argLine that makes its agent reach the fork: @{argLine}" \
      '<argLine>@\{argLine\}'
  has "…and pitest-junit5-plugin declared as a dependency OF the pitest plugin" \
      '<artifactId>pitest-junit5-plugin</artifactId>'
  # …at the versions the deck quotes. A survivor this script did not catch when it was first
  # written: JaCoCo 0.8.15 -> 0.8.14 moved no hash here, because every capture in this unit is
  # either a CSV row both versions agree on, or a goal line out of breaks/naive-argline, whose pom
  # is a different file. Both poms are pinned below, and the version that actually RAN is read off
  # the goal line of this unit's own build further down.
  is "…jacoco-maven-plugin is pinned at 0.8.15, the version the deck quotes" \
     "$(awk '/<artifactId>jacoco-maven-plugin<\/artifactId>/{getline; print}' "$REPO/c3-unit17/pom.xml" | tr -d ' ')" \
     "<version>0.8.15</version>"
  is "…and breaks/naive-argline pins the SAME one, which is what makes the two builds comparable" \
     "$(awk '/<artifactId>jacoco-maven-plugin<\/artifactId>/{getline; print}' "$REPO/c3-unit17/breaks/naive-argline/pom.xml" | tr -d ' ')" \
     "<version>0.8.15</version>"
  is "…pitest-maven at 1.30.0" \
     "$(awk '/<artifactId>pitest-maven<\/artifactId>/{getline; print}' "$REPO/c3-unit17/pom.xml" | tr -d ' ')" \
     "<version>1.30.0</version>"
  is "…and pitest-junit5-plugin at 1.2.3, without which PIT cannot see a JUnit 5 or 6 test at all" \
     "$(awk '/<artifactId>pitest-junit5-plugin<\/artifactId>/{getline; print}' "$REPO/c3-unit17/pom.xml" | tr -d ' ')" \
     "<version>1.2.3</version>"

  expect_ok 'mvn -B -Dmaven.repo.local="$PWD/.m2-demo" clean test' 1800 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit17" && mvn -B "-Dmaven.repo.local=$M2_U17" clean test'
  has "…Tests run: 3, and every one of them green over a class that is wrong" \
      'Tests run: 3, Failures: 0, Errors: 0, Skipped: 0'
  has "…and the agent that really ran is jacoco 0.8.15 — the goal line, not the pom" 'jacoco:0\.8\.15:prepare-agent'
  exists "…and target/jacoco.exec exists — the file that proves the agent really ran" \
      "$REPO/c3-unit17/target/jacoco.exec"
  timed 60 bash -c 'cd "$REPO/c3-unit17" && cat target/site/jacoco/jacoco.csv | grep Pricing'
  is "cat target/site/jacoco/jacoco.csv | grep Pricing -> 0 missed, everything covered" \
     "$(tr -d ' \n' <"$OUT")" "TiffinBoxCore,com.tiffinbox,Pricing,0,15,0,4,0,6,0,3,0,1"
  panel 17 '^## Run it' 2
  out_has_panel "…and that row is the one c3-unit17/README.md prints, character for character"
  bill_is "…the customer the hundred percent gets wrong: Arun, 1 meal at 200, is billed exactly 6000" \
      "$REPO/c3-unit17/target/classes" "Arun" 1 200 "6000"

  # ---- the break: seven goals ran, three tests passed, the build is green, and the tool did
  # nothing. BUILD SUCCESS is the defect here, so the assertion is the missing artifact.
  expect_ok "breaks/naive-argline: mvn -B test -> exit 0, BUILD SUCCESS, and no coverage at all" 900 \
      'Skipping JaCoCo execution due to missing execution data file' \
      bash -c 'cd "$REPO/c3-unit17/breaks/naive-argline" && mvn -B "-Dmaven.repo.local=$M2_U17" test'
  has "…with three tests passing under it" 'Tests run: 3, Failures: 0, Errors: 0, Skipped: 0'
  absent "…and target/jacoco.exec does not exist: the agent never reached the forked JVM" \
      "$REPO/c3-unit17/breaks/naive-argline/target/jacoco.exec"
  N="$(find "$REPO/c3-unit17/breaks/naive-argline/target/site" -type f 2>/dev/null | wc -l | tr -d ' ')"
  is "…and target/site/ holds 0 files — 'which file proves it ran?' is the question, not 'did it pass'" "$N" "0"
  timed 60 grep -n '<argLine>' "$REPO/c3-unit17/breaks/naive-argline/pom.xml"
  has "…the whole difference is one token: the break's argLine has no @{argLine}" '<argLine>-Xmx512m</argLine>'
  hasnt "…which is late replacement, and without it surefire's own element overrides the property" '@\{argLine\}'

  # ---- the exercise: 86%, not 100%, because one survivor is an equivalent mutant
  expect_ok "exercise: mvn -B clean test unedited -> green, and JaCoCo at a hundred percent" 1800 \
      'Tests run: 3, Failures: 0, Errors: 0, Skipped: 0' \
      bash -c 'cd "$REPO/c3-unit17/exercise" && mvn -B "-Dmaven.repo.local=$M2_U17" clean test'
  expect_ok "exercise: org.pitest:pitest-maven:mutationCoverage -> 7 mutations, 5 killed, 2 survivors" 1800 \
      '>> Generated 7 mutations Killed 5 \(71%\)' \
      bash -c 'cd "$REPO/c3-unit17/exercise" && mvn -B "-Dmaven.repo.local=$M2_U17" test-compile org.pitest:pitest-maven:mutationCoverage'
  is "…and the two survivors PIT recorded are on lines 20 and 23, read out of mutations.xml — PIT's own console log is never a receipt, it stamps a clock on every line" \
     "$(pit_survivors "$REPO/c3-unit17/exercise/target/pit-reports/mutations.xml")" "20 23"
  backup "$REPO/c3-unit17/exercise/src/main/java/com/tiffinbox/Pricing.java"
  backup "$REPO/c3-unit17/exercise/src/test/java/com/tiffinbox/PricingTest.java"
  cp "$REPO/c3-unit17/exercise/solution/PricingTest.java" \
     "$REPO/c3-unit17/exercise/src/test/java/com/tiffinbox/PricingTest.java"
  expect_fail "exercise step 2: the boundary test alone -> a real defect, found before the fix" 1800 \
      'expected: "SILVER"' \
      bash -c 'cd "$REPO/c3-unit17/exercise" && mvn -B "-Dmaven.repo.local=$M2_U17" clean test'
  has "… but was: \"BRONZE\"" 'but was: "BRONZE"'
  cp "$REPO/c3-unit17/exercise/solution/Pricing.java" \
     "$REPO/c3-unit17/exercise/src/main/java/com/tiffinbox/Pricing.java"
  expect_ok "exercise solution: both answer files -> Tests run: 4, BUILD SUCCESS" 1800 \
      'Tests run: 4, Failures: 0, Errors: 0, Skipped: 0' \
      bash -c 'cd "$REPO/c3-unit17/exercise" && mvn -B "-Dmaven.repo.local=$M2_U17" clean test'
  expect_ok "exercise solution: PIT again -> 6 of 7, which is 86% and is where the exercise STOPS" 1800 \
      '>> Generated 7 mutations Killed 6 \(86%\)' \
      bash -c 'cd "$REPO/c3-unit17/exercise" && mvn -B "-Dmaven.repo.local=$M2_U17" test-compile org.pitest:pitest-maven:mutationCoverage'
  is "…with ONE survivor left, not none, and it is line 20 — the equivalent mutant no test can kill" \
     "$(pit_survivors "$REPO/c3-unit17/exercise/target/pit-reports/mutations.xml")" "20"
  # the arithmetic that makes it equivalent, checked rather than repeated: a monthly bill is
  # meals x price x 30, and 10000 is not a multiple of 30.
  is "…10000 mod 30 is 10, so no Customer can tell bill >= 10000 from bill > 10000" \
     "$(awk 'BEGIN{print 10000%30}')" "10"
  restore_all
  rm -rf "$REPO/c3-unit17/exercise/target"

  # ---- receipts.sh: nine blocks, every hash on the deck, and the roll-up that must not move
  # when the checkout does.
  if run_receipts 17 5400; then
    is "…and it printed nine blocks" "$(receipts_blocks 17)" "9"
    receipt_is 17 coverage  "md5 e1686a68cd30b56e95930ff44ee9f619  exit 0"
    receipt_is 17 scope     "md5 18596680f0137dafc3df3b1d9f3ff809  exit 0"
    receipt_is 17 bug       "md5 b2505193eae46373a69f0f98613ab1e2  exit 1"
    receipt_is 17 unchanged "md5 af39241963b2db0568fb30b7365968e8  exit 0 and 0"
    receipt_is 17 mutants   "md5 b78a169a50376ef389a9dab076855d5b  exit 0"
    receipt_is 17 ctor      "md5 eab2e7b90b5514b8a42703075c4692ae  exit 0 and 0"
    receipt_is 17 naive     "md5 1ab59782d46afe52ad2da4925a9fae29  exit 0"
    receipt_is 17 solution  "md5 d2910ac2af3a0b0077c81cb3377e9bac  exit 0 and 0"
    receipt_is 17 offline   "md5 2bdee10c78eb172ea120d5528197df88  exit 0"
    derived_unprobed 17
    # c3-unit17/README.md quotes exactly one of those numbers in prose, and it is the one the
    # whole unit turns on; so that half is read off the page rather than trusted to this file.
    U17B="$(readme_hash 17 'is taken over')"
    is "…and the bug block's hash is the one c3-unit17/README.md quotes in prose" \
       "$(block_tail 17 bug | awk '{print $2}')" "$U17B"
    # THE roll-up. Every capture in this unit is masked to `<project>/`, so this number is the
    # same from any checkout — verified 3/3 across two paths, one of them containing a space.
    # A mismatch here is a finding about the masking, not a number to update.
    is "…./receipts.sh 2>&1 | md5 -q -> the 9-block roll-up, and it is NOT path-dependent" \
       "$(receipts_md5 17)" "701ad6052901edb0d476fad22f05e4c4"
    # the receipt that matters: the same CSV row, with the bug and with it fixed
    receipt_body 17 unchanged
    panel 17 'the JaCoCo row for' 1
    out_has_panel "…README's before/after panel is what that block really wrote"
    has "…and the two rows really are identical" 'the two rows are identical: yes'
    # the denominator, and the other tool that counts differently
    receipt_body 17 scope
    has "…receipts.sh scope: Pricing lines 6/6 (100%)"        'Pricing +lines 6/6 \(100%\)'
    has "…and the whole project 8/97 (8%), from the same file" 'whole project \(8 classes\) lines 8/97 \(8%\)'
    receipt_body 17 ctor
    has "…receipts.sh ctor: the filtered private constructor moves the DENOMINATOR, 6 -> 7" \
        'lines JaCoCo counted: 6 -> 7 ; lines it called covered: 6 -> 6'
    # PIT's panel, on the unit page and on the exercise page, held to the block that made it.
    # An elision, not a contiguous capture: `>> Mutations with no coverage …` sits between the
    # Generated line and the survivors, and the pages leave it out.
    receipt_body 17 mutants
    panel 17 '^## Mutation testing' 2
    out_has_lines "…README's PIT panel — 7 generated, 5 killed, two survivors — is what that block produced"
    xpanel 17 'Right now the tests are green, JaCoCo reports' 1
    out_has_lines "…and the exercise README's starting PIT panel is the same three lines"
    receipt_body 17 solution
    xpanel 17 'The end state to reach' 1
    out_has_panel "…and its end state — Tests run: 4, 6 of 7 killed, one survivor — is what the answer really produced"
    has "…and the block says WHY that survivor cannot be killed, in arithmetic" \
        'the surviving boundary is reachable by a Customer: no'
  fi

  offline_test 'mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -o test' 900 "$REPO/c3-unit17" "$M2_U17"
fi

# ============================================================= c3-unit18 ====
if unit 18 "Test architecture: naming, builders, and a flake you can hand to a colleague"; then
  is "pom.xml pins assertj-core at 3.27.7" \
     "$(awk '/<artifactId>assertj-core<\/artifactId>/{getline; print}' "$REPO/c3-unit18/pom.xml" | tr -d ' ')" \
     "<version>3.27.7</version>"
  is "…and declares no Mockito, no JaCoCo, no agent of any kind — the deck's ⚑ D13" \
     "$(grep -cE 'mockito|jacoco|javaagent' "$REPO/c3-unit18/pom.xml" | tr -d ' ')" "0"

  expect_ok 'mvn -B -Dmaven.repo.local="$PWD/.m2-demo" test' 1200 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit18" && mvn -B "-Dmaven.repo.local=$M2_U18" test'
  has "…Tests run: 6 — the naming convention, and the repaired flake" \
      'Tests run: 6, Failures: 0, Errors: 0, Skipped: 0'
  is "…and src/test's RosterTest holds NO static field: that is the repair, one word" \
     "$(grep -cE '^ *private +static' "$REPO/c3-unit18/src/test/java/com/tiffinbox/RosterTest.java" | tr -d ' ')" "0"
  # counted over the CODE: the class's own javadoc explains the repair and names @BeforeEach in
  # a sentence, so a grep over the whole file reads 2 and says nothing about the annotation.
  is "…rebuilt by a @BeforeEach instead" \
     "$(grep -cE '^ *@BeforeEach' "$REPO/c3-unit18/src/test/java/com/tiffinbox/RosterTest.java" | tr -d ' ')" "1"
  sensitive_to "…and MonthlyBillTest CONSTRAINS the bill it names: a 31-day month is noticed by 2 of the 6" \
      18 "$M2_U18" src/main/java/com/tiffinbox/Customer.java \
      "mealsPerDay * pricePerMeal * 30;" "mealsPerDay * pricePerMeal * 31;" \
      "Tests run: 6, Failures: 2, Errors: 0, Skipped: 0"

  # ---- breaks/nameless: four failures, two bugs, the same two assertions in both classes
  expect_fail "breaks/nameless: mvn -B test -> exit 1, four failures over two bugs" 900 \
      'Tests run: 4, Failures: 4' \
      bash -c 'cd "$REPO/c3-unit18/breaks/nameless" && mvn -B "-Dmaven.repo.local=$M2_U18" test'
  panel 18 '^## What actually reaches a failure report' 2
  out_has_panel_rtrim "…and the README's four-line failure report is what this run really printed"
  # the finding that surprises people, measured in the direction that can fail: the three
  # @DisplayName strings reach the report ZERO times, and a zero only counts when the search
  # could have found something — so the method names, which DO reach it, are counted too.
  # searched in THE FAILURE REPORT, which is what the page's sentence is about — not in the whole
  # console, where surefire prints the CLASS display name for free on its `Running …` lines and
  # every one of these three would be found. That is also where c3-unit18/receipts.sh looks.
  sed -n '/^\[INFO\] Results:/,/^\[ERROR\] Tests run:/p' "$OUT" > "$WORK/report18"
  D=0; Z=0
  while IFS= read -r dn; do
    D=$((D+1)); grep -qF "$dn" "$WORK/report18" && Z=$((Z+1))
  done < <(sed -nE 's/.*@DisplayName\("([^"]*)"\).*/\1/p' "$REPO/c3-unit18/breaks/nameless/src/test/java/com/tiffinbox/BillingRulesTest.java")
  is "…BillingRulesTest carries three @DisplayName annotations" "$D" "3"
  is "…and zero of those three strings appear anywhere in the failure report" "$Z" "0"
  if grep -q 'BillingRulesTest\.doesNotBillThePausedDays' "$WORK/report18"; then
    ok "…while the METHOD name does, which is what makes that zero a finding and not an empty grep"
  else
    bad "the failure report" "it does not name BillingRulesTest.doesNotBillThePausedDays either, so the 0 above counted nothing"
  fi
  # what surefire DOES give you for free: the class display name, on the console
  has "…and the class display name is free on the console: Running billing rules" 'Running billing rules'
  hasnt "…not Running com.tiffinbox.BillingRulesTest" 'Running com\.tiffinbox\.BillingRulesTest'

  # ---- breaks/positional-arguments: it compiles, it bills correctly, and it is wrong
  expect_fail "breaks/positional-arguments: mvn -B test -> only the field assertion catches it" 900 \
      'PositionalTest\.theCustomerIsNot' \
      bash -c 'cd "$REPO/c3-unit18/breaks/positional-arguments" && mvn -B "-Dmaven.repo.local=$M2_U18" test'
  has "…expected: 2"   'expected: 2'
  has "… but was: 120" 'but was: 120'
  # THE artifact: the two ints are interchangeable, so the BILL is right either way. 120 x 2 x 30
  # and 2 x 120 x 30 are the same 7200, which is why the bill test passes over a swapped record.
  bill_is "…and new Customer(\"Ravi\", 120, 2, \"VEG\") really does bill 7200, same as the right way round" \
      "$REPO/c3-unit18/breaks/positional-arguments/target/classes" "Ravi" 120 2 "7200"
  bill_is "…because 2 x 120 x 30 is the same number — the bill can never catch this" \
      "$REPO/c3-unit18/breaks/positional-arguments/target/classes" "Ravi" 2 120 "7200"

  # ---- breaks/shared-state: one static list, three tests, an order-dependent failure
  expect_fail "breaks/shared-state: mvn -B test -> red under Jupiter's own default order" 900 \
      'Expected size: 2 but was: 3' \
      bash -c 'cd "$REPO/c3-unit18/breaks/shared-state" && mvn -B "-Dmaven.repo.local=$M2_U18" test'
  is "…and the cause is one word: the roster is a private static final List" \
     "$(grep -cE 'private +static +final +List' "$REPO/c3-unit18/breaks/shared-state/src/test/java/com/tiffinbox/RosterTest.java" | tr -d ' ')" "1"
  # named seeds, so the flake is reproducible rather than "it fails sometimes"
  expect_ok "…and seed 2 passes, which is what makes this a flake you can hand to a colleague" 900 \
      'Tests run: 3, Failures: 0, Errors: 0, Skipped: 0' \
      bash -c 'cd "$REPO/c3-unit18/breaks/shared-state" && mvn -B "-Dmaven.repo.local=$M2_U18" '"'"'-Djunit.jupiter.testmethod.order.default=org.junit.jupiter.api.MethodOrderer$Random'"'"' -Djunit.jupiter.execution.order.random.seed=2 test'
  expect_fail "…while seed 42, the same command, does not" 900 'Tests run: 3, Failures: 2' \
      bash -c 'cd "$REPO/c3-unit18/breaks/shared-state" && mvn -B "-Dmaven.repo.local=$M2_U18" '"'"'-Djunit.jupiter.testmethod.order.default=org.junit.jupiter.api.MethodOrderer$Random'"'"' -Djunit.jupiter.execution.order.random.seed=42 test'
  # the double-quote trap, which is NOT silent and does NOT go green
  expect_fail "…and in double quotes \$Random expands to nothing, JUnit falls back, and it says so twice" 900 \
      'Failed to load default method orderer class' \
      bash -c 'cd "$REPO/c3-unit18/breaks/shared-state" && mvn -B "-Dmaven.repo.local=$M2_U18" "-Djunit.jupiter.testmethod.order.default=org.junit.jupiter.api.MethodOrderer$Random" -Djunit.jupiter.execution.order.random.seed=42 test'
  N="$(countq 'Failed to load default method orderer class')"
  is "…twice, naming the parameter and the class" "$N" "2"
  has "…with a NoSuchMethodException under it" 'NoSuchMethodException'
  has "…and the fallback run is RED, so nothing warns you by going green" 'Tests run: 3, Failures: 1'

  # ---- junit-platform.properties: the file form of the same two knobs
  exists "junit-platform.properties ships beside the pom" "$REPO/c3-unit18/junit-platform.properties"
  timed 60 cat "$REPO/c3-unit18/junit-platform.properties"
  has "…and it carries the orderer"  'junit\.jupiter\.testmethod\.order\.default'
  has "…and the seed"                'junit\.jupiter\.execution\.order\.random\.seed'

  # ---- the exercise, both halves
  expect_fail "exercise: mvn -B test unedited -> Tests run: 3, Failures: 1, order-dependent" 900 \
      'RosterTest\.startsWithTwoCustomers' \
      bash -c 'cd "$REPO/c3-unit18/exercise" && mvn -B "-Dmaven.repo.local=$M2_U18" test'
  has "…Expected size: 2 but was: 3" 'Expected size: 2 but was: 3'
  backup "$REPO/c3-unit18/exercise/src/test/java/com/tiffinbox/RosterTest.java"
  cp "$REPO/c3-unit18/exercise/solution/RosterTest.java" \
     "$REPO/c3-unit18/exercise/src/test/java/com/tiffinbox/RosterTest.java"
  cp "$REPO/c3-unit18/exercise/solution/CustomerBuilder.java" \
     "$REPO/c3-unit18/exercise/src/test/java/com/tiffinbox/CustomerBuilder.java"
  created "$REPO/c3-unit18/exercise/src/test/java/com/tiffinbox/CustomerBuilder.java"
  expect_ok "exercise solution: green under Jupiter's default order" 900 \
      'Tests run: 3, Failures: 0, Errors: 0, Skipped: 0' \
      bash -c 'cd "$REPO/c3-unit18/exercise" && mvn -B "-Dmaven.repo.local=$M2_U18" test'
  expect_ok "…and green under a shuffled one, seed 1 — which the starter is not" 900 \
      'Tests run: 3, Failures: 0, Errors: 0, Skipped: 0' \
      bash -c 'cd "$REPO/c3-unit18/exercise" && mvn -B "-Dmaven.repo.local=$M2_U18" '"'"'-Djunit.jupiter.testmethod.order.default=org.junit.jupiter.api.MethodOrderer$Random'"'"' -Djunit.jupiter.execution.order.random.seed=1 test'
  is "…and the answer's field is not static — the repair is the field, not a pinned seed" \
     "$(grep -cE '^ *private +static' "$REPO/c3-unit18/exercise/solution/RosterTest.java" | tr -d ' ')" "0"
  # …and the answer's three assertions are still assertions. Green under two orders is true of a
  # class that asserts nothing, and no hash here covers what it asserts — so a third customer is
  # put into the @BeforeEach roster and all three have to notice.
  if python3 - "$REPO/c3-unit18/exercise/src/test/java/com/tiffinbox/RosterTest.java" <<'PYEOF'
import sys
p = sys.argv[1]
a = 'aCustomer().named("Meera").eating(1).atRupees(150).ofType("NON_VEG").build()));'
b = ('aCustomer().named("Meera").eating(1).atRupees(150).ofType("NON_VEG").build(),\n'
     '            aCustomer().named("Extra").build()));')
s = open(p, encoding='utf-8').read()
if s.count(a) != 1:
    sys.exit(3)
open(p, "w", encoding='utf-8').write(s.replace(a, b))
PYEOF
  then
    expect_fail "…and it CONSTRAINS the roster it builds: a third customer in the @BeforeEach and all 3 go red" 900 \
        'Tests run: 3, Failures: 3, Errors: 0, Skipped: 0' \
        bash -c 'cd "$REPO/c3-unit18/exercise" && mvn -B "-Dmaven.repo.local=$M2_U18" test'
  else
    bad "c3-unit18 exercise answer: the third-customer probe" \
        "the edit did not apply exactly once to the answer's @BeforeEach — the probe would prove nothing"
  fi
  rm -f "$REPO/c3-unit18/exercise/src/test/java/com/tiffinbox/CustomerBuilder.java"
  restore_all

  # ---- receipts.sh: nine blocks. c3-unit18/README.md quotes no hash at all, so every number
  # below is the deck's (18-test-architecture.md), including both readings it is careful to
  # separate: the md5 of the whole OUTPUT, and the md5 of the script FILE.
  if run_receipts 18 5400; then
    is "…and it printed nine blocks" "$(receipts_blocks 18)" "9"
    is "…./receipts.sh | md5 -> the md5 of the whole OUTPUT the deck quotes" \
       "$(receipts_md5 18)" "f7c205f518262b5db5446f7d478956c6"
    is "…and md5 receipts.sh — the FILE, which the deck is careful to call a different thing" \
       "$(md5of "$REPO/c3-unit18/receipts.sh")" "ce33b5613d9eb92003f5a59a18f528ae"
    receipt_is 18 tests      "md5 e82720a3f6352ab8b5b97ea80847df03  exit 0"
    receipt_is 18 names      "md5 30ac0690c2f92704c9ba7f2422b5165c  exit 1"
    receipt_is 18 builders   "md5 2b8b1bae97335442359807f4dcacf468  exit 1"
    receipt_is 18 seeds      "md5 3c794aaf243981ae26bee297a06e8234  5 of 6 mvn runs exited non-zero"
    receipt_is 18 properties "md5 aa238f896a53aebf27a50e10796c0ce1  2 of 2 mvn runs exited non-zero"
    receipt_is 18 quotes     "md5 27d7df359a05264086787a1f1a6a6745  exit 1 then 1"
    receipt_is 18 fixed      "md5 dfa53278f20f1cac70c67abda936e4d4  0 of 6 mvn runs exited non-zero"
    receipt_is 18 offline    "md5 cdff0a142ac3f7101931c250e89d4506  exit 0"
    derived_unprobed 18
    # the seeds panel: one order green out of six, every row asserting that three tests RAN
    receipt_body 18 seeds
    panel 18 '^## The flake, made reproducible' 2
    out_has_panel "…README's seeds panel is what that block really produced"
    has "…and every row carries 'of 3 test(s)', because a failure count over a class that did not run is not a receipt" \
        'of 3 test\(s\)'
    has "…1 of 6 orders tried were green; the class holds 1 static field" \
        '1 of 6 orders tried were green; the class holds 1 static field\(s\); 3 test\(s\) ran under every order'
    # the quotes block, which refuses to print unless all four of its conditions fired
    receipt_body 18 quotes
    has "…receipts.sh quotes: single-quoted at seed 42 is 2 of 3" '2 (failure\(s\) )?of 3'
    has "…and the double-quoted run is a DIFFERENT order, not a silent nothing" 'Failed to load default method orderer class'
  fi

  offline_test 'mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -o test' 900 "$REPO/c3-unit18" "$M2_U18"
fi

# ============================================================= c3-unit19 ====
# Section 4 opens, and its rule is its own: A LOG LINE CARRIES A CLOCK. Every capture this
# unit hashes goes through its own `mask_time()` first, and every hash its slides quote is over
# the masked form — so this script does not re-implement that filter. It runs the unit's own
# receipts.sh, compares each trailer with the number the deck quotes, and holds every console
# panel on the page to the block that produced it. The one place a clock is unmasked is the
# README's own "Run it" panel, and that one is masked HERE with the very sed the page prints
# two lines under it.
if unit 19 "SLF4J, Logback and why not println"; then
  U19H="$(carried_five_hash 19)"
  is "README quotes a 32-hex md5 for the five carried sources" "$(printf '%s' "$U19H" | wc -c | tr -d ' ')" "32"
  is "md5 -q <the five named files> | sort | md5 -q -> the hash c3-unit19/README.md prints" \
     "$(src_hash5 "$REPO/c3-unit19/src/main/java/com/tiffinbox")" "$U19H"
  is "…and c3-tiffinbox/tiffinbox-core answers with the same one — byte-identical, not 'the same idea'" \
     "$(src_hash5 "$REPO/c3-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox")" "$U19H"
  # …and the new class really is one package DOWN, which is what keeps that five-file hash true
  # of this unit. Move KitchenLog.java up into com/tiffinbox/ and `md5 -q *.java` is six files
  # against a five-file hash, while every other check in the unit stays green.
  is "…and src/main/java holds those five plus com/tiffinbox/kitchen/KitchenLog.java, and nothing else" \
     "$(src_files "$REPO/c3-unit19/src/main/java")" \
     "./com/tiffinbox/Customer.java ./com/tiffinbox/CustomerRepository.java ./com/tiffinbox/Dashboard.java ./com/tiffinbox/Database.java ./com/tiffinbox/OrderQueue.java ./com/tiffinbox/kitchen/KitchenLog.java "
  is "…and the README's block table names exactly the ids receipts.sh declares" \
     "$(readme_block_ids 19)" "$(receipts_ids 19)"
  # The mask is a DELIVERABLE in this section, and the page prints it. If receipts.sh's filter
  # and the one the README shows ever part company, every hash on the page is over a capture the
  # viewer cannot reproduce — and no hash comparison can see that, because both halves move
  # together. So the two are compared with each other.
  U19M="s/^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3} /<time> /"
  if grep -qF -- "$U19M" "$REPO/c3-unit19/README.md" && grep -qF -- "$U19M" "$REPO/c3-unit19/receipts.sh"; then
    ok "the clock filter c3-unit19/README.md prints is the one receipts.sh really applies before it hashes"
  else
    bad "c3-unit19's clock filter" "the README and receipts.sh do not both carry: sed -E '$U19M'"
  fi

  # ---- "Run it": the command the page hands the viewer, and the panel under it
  timed 1800 bash -c 'cd "$REPO/c3-unit19" && mvn -B -q "-Dmaven.repo.local=$M2_U19" compile exec:exec \
      | sed -E "s/^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3} /<time> /"'
  if [ "$RC" -eq 0 ]; then
    has "mvn -B -q compile exec:exec -> INFO tiffinbox - orders cooked:  90" '^<time> INFO  tiffinbox - orders cooked: +90$'
    has "…kitchen value:  26700" '^<time> INFO  tiffinbox - kitchen value: +26700$'
    is "…and TWO lines, not five: the per-customer lines are DEBUG and this config's root is INFO" \
       "$(countq '^<time> ')" "2"
    panel 19 '^## Run it' 2
    sed -E 's/^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3} /<time> /' "$WORK/panel" > "$WORK/panel.m" && mv "$WORK/panel.m" "$WORK/panel"
    out_has_panel "…and that is the two-line panel c3-unit19/README.md prints, once the clock the page says moves is masked"
  else
    bad "mvn -B -q compile exec:exec" "exit $RC"
  fi

  # ---- the same classes, a different level. One word in one XML file.
  timed 1800 bash -c 'cd "$REPO/c3-unit19" && mvn -B -q "-Dmaven.repo.local=$M2_U19" -Dlogback.config=logback-debug.xml exec:exec \
      | sed -E "s/^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3} /<time> /"'
  if [ "$RC" -eq 0 ]; then
    is "-Dlogback.config=logback-debug.xml -> FIVE lines where the same classes gave two" \
       "$(countq '^<time> ')" "5"
    is "…three of them DEBUG" "$(countq '^<time> DEBUG ')" "3"
    panel 19 '^## The same classes, a different level' 2
    out_has_panel "…and the five-line panel c3-unit19/README.md prints under that command is what came back"
  else
    bad "mvn -q -Dlogback.config=logback-debug.xml exec:exec" "exit $RC"
  fi

  # ---- the three bindings, and the third one. THE assertion of this unit is an EXIT CODE OF
  # ZERO over silence: a missing binding is not an error, it is a program that stopped telling
  # you anything, and `expect_ok` with no kitchen line is the only honest way to say that.
  expect_ok "breaks/no-binding: mvn -B -q compile exec:exec -> exit 0, and the kitchen still cooked" 1800 \
      'SLF4J\(W\): No SLF4J providers were found\.' \
      bash -c 'cd "$REPO/c3-unit19/breaks/no-binding" && mvn -B -q "-Dmaven.repo.local=$M2_U19" compile exec:exec'
  is "…three SLF4J warning lines on stderr, which is the whole warning you get" "$(countq '^SLF4J\(W\): ')" "3"
  hasnt "…and NOT ONE kitchen line reached the console" 'tiffinbox - |^orders cooked|^kitchen value'
  # …and the three source trees really are one source tree. The README calls them
  # byte-identical; `bridge` dies if they are not, and this is the same question asked here so
  # that the claim is not only true inside the block that depends on it.
  U19T="$( cd "$REPO/c3-unit19/src/main/java" && find . -name '*.java' | LC_ALL=C sort | xargs md5 -q | md5 -q )"
  is "src/main/java, swap/src/main/java and breaks/no-binding/src/main/java are ONE tree: swap" \
     "$( cd "$REPO/c3-unit19/swap/src/main/java" && find . -name '*.java' | LC_ALL=C sort | xargs md5 -q | md5 -q )" "$U19T"
  is "…and breaks/no-binding" \
     "$( cd "$REPO/c3-unit19/breaks/no-binding/src/main/java" && find . -name '*.java' | LC_ALL=C sort | xargs md5 -q | md5 -q )" "$U19T"
  readme_quotes "…and it is the hash c3-unit19/README.md prints in its bridge panel" 19 "$U19T"

  # ---- the exercise's START state, run in place: the page's own command, and its own panel.
  # `../.m2-demo` is this unit's .m2-demo, which is the repository every command above warmed.
  expect_ok "exercise: mvn -B -q compile exec:exec unedited -> exit 0 and three warnings" 1800 \
      'SLF4J\(W\): No SLF4J providers were found\.' \
      bash -c 'cd "$REPO/c3-unit19/exercise" && mvn -B -q "-Dmaven.repo.local=../.m2-demo" compile exec:exec'
  xpanel 19 '^## The start state' 2
  out_has_panel "…and those are the three lines c3-unit19/exercise/README.md prints, verbatim"
  hasnt "…not one kitchen line: four logging calls, all of them into the NOP logger" 'tiffinbox - '

  # ---- receipts.sh, all nine blocks, and the nine hashes the deck (19-slf4j-logback-why-not-
  # println.md) quotes. c3-unit19/README.md quotes none of them in the `receipts.sh <id> → md5`
  # shape, so these are the deck's numbers with the deck named beside them.
  if run_receipts 19 3600; then
    is "…and it printed nine blocks, the count c3-unit19/README.md states" "$(receipts_blocks 19)" "9"
    is "…./receipts.sh 2>&1 | md5 -q -> the whole-run md5 the deck quotes for the nine" \
       "$(receipts_md5 19)" "7a4b561ed17d4e756fc23ef4baa24f14"
    is "…and md5 of the receipts.sh FILE is a DIFFERENT number, which the deck is careful to call a receipt of nothing" \
       "$( [ "$(md5of "$REPO/c3-unit19/receipts.sh")" != "$(receipts_md5 19)" ] && echo different || echo "the same" )" "different"
    receipt_line 19 bridge    "md5 f223a0a5bac6a7db751411877ee4f656  exit 0 then 0 then 0"
    receipt_line 19 levels    "md5 4fbc27f7700c84cd10c0b00377a0db0e  exit 0 then 0"
    receipt_line 19 tree      "md5 78ffea1b0c2e3e62398a575c628f8588  exit 0 then 0"
    receipt_line 19 println   "md5 8237b0d1d16f31a5adc1ecadcd4b83b2  exit 0 then 0"
    receipt_line 19 nobinding "md5 6f91730c4f6e78933ea3bd0495246449  exit 0"
    receipt_line 19 cost      "md5 b1cb78e200ad3b615a8b4fcde21579dc  exit 0"
    receipt_line 19 release   "md5 091e674687c615245199a2de87ab815b  (no build)"
    receipt_line 19 solution  "md5 52ac5d500ab11a7e362adad01b143530  exit 0 then 0"
    receipt_line 19 offline   "md5 5752d5e6f631c8e90e17e9f084414cf0  exit 0"
    derived_unprobed 19

    # every console panel on the page, against the block that made it
    receipt_panel 19 bridge
    panel 19 '^## The same source, three bindings' 2
    out_has_panel "…README's bridge panel — three bindings, the third silent at exit 0 — is what that block printed"
    receipt_panel 19 levels
    panel 19 '^## The same classes, a different level' 3
    out_has_panel "…README's levels panel is what that block printed, target/classes hash and all"
    receipt_panel 19 tree
    panel 19 'did you actually get' 2
    out_has_panel "…README's two dependency trees are that block's, elision counts included"
    panel 19 'did you actually get' 3
    out_has_panel "…and the four version lines under them"
    receipt_panel 19 cost
    panel 19 'What a switched-off DEBUG call costs' 2
    out_has_panel "…README's cost panel — 1000 renders against 0 — is what the test really logged"
    receipt_panel 19 release
    panel 19 'trap, on this unit' 2
    out_has_panel "…README's <release> panel is derived from central/ and reproduces character for character"
    # the exercise's END state, which is the exercise page's own acceptance
    receipt_panel 19 solution
    xpanel 19 '^## The end state you are reaching' 1
    out_has_lines "…and the five lines c3-unit19/exercise/README.md promises are what the answer really produced"
    has "…with src/main/java untouched: the answer changed 0 lines of Java" \
        '^lines of src/main/java the answer changed: 0$'
    # the two derived sentences that are the unit's headline, asserted where they are derived
    receipt_panel 19 println
    has "…receipts.sh println: the SAME switch that moved Logback moved the println output by 0 lines" \
        'moved the println output by: 0 line\(s\)$'
    has "…and of those five lines, 0 carry a level word and 0 name a source" \
        '^of those 5 lines, 0 carry a level word and 0 name a source$'
    receipt_panel 19 nobinding
    has "…receipts.sh nobinding: 3 warning lines, 0 kitchen lines, exit code 0" '^the process exit code: 0$'
  fi

  offline_test 'mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -o test' 1800 "$REPO/c3-unit19" "$M2_U19"
fi

# ============================================================= c3-unit20 ====
# Appenders, patterns, rolling and MDC. Two things here are assertions nothing else in this
# script makes: the file appender's OUTPUT is compared with the console's (the README's claim is
# "character for character once the clock is masked", and a `diff` is the only way to say it),
# and the rolling beat is asserted to DISCARD — a rolling appender is a bounded buffer, the page
# says 48 lines of 61 survived, and "it rolled" without that count is the half nobody mentions.
if unit 20 "Appenders, patterns, rolling and MDC"; then
  is "README quotes the five carried sources' hash, and it is the course's own" \
     "$(src_hash5 "$REPO/c3-unit20/src/main/java/com/tiffinbox")" "$(carried_five_hash 20)"
  is "…and everything this unit adds is under com/tiffinbox/kitchen/" \
     "$(src_files "$REPO/c3-unit20/src/main/java/com/tiffinbox/kitchen")" \
     "./KitchenLog.java ./KitchenMdc.java ./KitchenPool.java ./KitchenRoll.java ./Mdc.java "
  is "…and the README's block table names exactly the ids receipts.sh declares" \
     "$(readme_block_ids 20)" "$(receipts_ids 20)"
  is "logback.xml attaches TWO appenders to the root — the count the whole first beat rests on" \
     "$(grep -c '<appender-ref' "$REPO/c3-unit20/src/main/resources/logback.xml" | tr -d ' ')" "2"

  # ---- one event, two destinations. The README's command, and then the FILE, which is the
  # evidence: a console line proves a console appender and nothing else.
  timed 1800 bash -c 'cd "$REPO/c3-unit20" && rm -rf target/logs && mvn -B -q "-Dmaven.repo.local=$M2_U20" compile exec:exec \
      | grep " kitchen " | sed -E "s/^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3} /<time> /"'
  if [ "$RC" -eq 0 ]; then
    is "mvn -B -q compile exec:exec -> the console shows SEVEN lines, as the README says" "$(countq '^<time> ')" "7"
    cp "$OUT" "$WORK/u20.console"
    exists "…and target/logs/kitchen.log was written, which is the half a console line cannot prove" \
        "$REPO/c3-unit20/target/logs/kitchen.log"
    grep ' kitchen ' "$REPO/c3-unit20/target/logs/kitchen.log" 2>/dev/null \
      | sed -E 's/^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3} /<time> /' > "$WORK/u20.file"
    if diff -q "$WORK/u20.console" "$WORK/u20.file" >/dev/null 2>&1; then
      ok "…and the two renderings are identical once the clock is masked — one event, two destinations"
    else
      cp "$WORK/u20.file" "$OUT"
      bad "console against target/logs/kitchen.log" "the two appenders rendered the same events differently: $(diff "$WORK/u20.console" "$WORK/u20.file" | tr '\n' ' ' | cut -c1-200)"
    fi
  else
    bad "mvn -B -q compile exec:exec (c3-unit20)" "exit $RC"
  fi

  # ---- the MDC's headline, read out of the source rather than described: not one logging call
  # passes the order id, and there is exactly one MDC.put.
  is "KitchenMdc.java carries exactly one MDC.put(…) call" \
     "$(grep -vE '^[[:space:]]*(\*|//|/\*)' "$REPO/c3-unit20/src/main/java/com/tiffinbox/kitchen/KitchenMdc.java" | sed -E 's#[[:space:]]*//.*$##' | grep -c 'MDC.put(' | tr -d ' ')" "1"
  is "…and ZERO of its log.info(…) call sites pass the order id — that is the whole mechanism" \
     "$(grep -vE '^[[:space:]]*(\*|//|/\*)' "$REPO/c3-unit20/src/main/java/com/tiffinbox/kitchen/KitchenMdc.java" | sed -E 's#[[:space:]]*//.*$##' | grep 'log\.info(' | grep -c 'orderId' | tr -d ' ')" "0"
  is "…while the LAYOUT names it, which is where the id comes from — counted in the pattern PROPERTY, not in the comment above it" \
     "$(grep -c 'value=".*%X{orderId:-}.*"' "$REPO/c3-unit20/src/main/resources/logback.xml" | tr -d ' ')" "1"

  # ---- the break: an id at a thread boundary. Exit 0 in both states, and the second state is
  # worse than the first — asserted as the artifact (one line carrying another request's id),
  # never as a build result, because nothing here fails.
  expect_ok "breaks/mdc-lost: mvn -B -q compile exec:exec -> exit 0, and one line is a confident lie" 1800 \
      'state 2: copy the map in, forget to take it out' \
      bash -c 'cd "$REPO/c3-unit20/breaks/mdc-lost" && mvn -B -q "-Dmaven.repo.local=$M2_U20" compile exec:exec'
  is "…state 1: BOTH cooking lines reached the pool thread with no id at all" \
     "$(sed -n "/state 1/,/state 2/p" "$OUT" | grep -c 'pool-1-thread-1.*kitchen \.\.\. - cooking' | tr -d ' ')" "2"
  is "…state 2: ONE cooking line carries another request's id — Arun's, on Bela's line" \
     "$(sed -n "/state 2/,\$p" "$OUT" | grep -c 'pool-1-thread-1.*A-4417 - cooking Bela' | tr -d ' ')" "1"
  hasnt "…and nothing threw: no exception reached the console" 'Exception|BUILD FAILURE'

  # ---- rolling. `roll` is the one beat where the FILE COUNT is the claim and the LINE COUNT is
  # the half nobody mentions, so both are taken from disk after the run rather than from a log.
  expect_ok "breaks/no-roll: the configuration every tutorial shows -> exit 0" 1800 '' \
      bash -c 'cd "$REPO/c3-unit20/breaks/no-roll" && rm -rf target/logs && mvn -B -q "-Dmaven.repo.local=$M2_U20" compile exec:exec'
  is "…and it produced ONE file: a 1KB roller that did not roll" \
     "$(ls -1 "$REPO/c3-unit20/breaks/no-roll/target/logs" 2>/dev/null | wc -l | tr -d ' ')" "1"
  is "…and the tutorial configuration really does set maxFileSize to 1KB, so that is not the cause" \
     "$(grep -c '<maxFileSize>1KB</maxFileSize>' "$REPO/c3-unit20/breaks/no-roll/src/main/resources/logback.xml" | tr -d ' ')" "1"
  is "…while this unit's own logback.xml adds ONE element the tutorial's has not" \
     "$(grep -c '<checkIncrement>' "$REPO/c3-unit20/src/main/resources/logback.xml" | tr -d ' ')" "1"

  # ---- receipts.sh: nine blocks, and the nine hashes on the deck (20-appenders-patterns-mdc.md)
  if run_receipts 20 3600; then
    is "…and it printed nine blocks, the count c3-unit20/README.md states" "$(receipts_blocks 20)" "9"
    is "…./receipts.sh 2>&1 | md5 -q -> the whole-run md5 the deck quotes for the nine" \
       "$(receipts_md5 20)" "0c85d0a2d34f00c7c3d901396269b3b9"
    receipt_line 20 appenders "md5 205f6364153a422705a54f24acce40f6  exit 0"
    receipt_line 20 pattern   "md5 388fd72e4ba7e14e170654616e003b34  exit 0"
    receipt_line 20 mdc       "md5 1ca820dcdb9d16f42a3eb81eeaae378b  exit 0"
    receipt_line 20 handoff   "md5 c53fc8c078f1f0a8d92e0f7afd231bc3  exit 0"
    receipt_line 20 pool      "md5 a64d33f95dc65b51b7f8101c0386221d  exit 0"
    receipt_line 20 roll      "md5 a95ad56ea5eed3d9f21c8c852a91a8d7  exit 0 then 0"
    receipt_line 20 gate      "md5 873e2f6750e68591d6d32aaebb3afe31  exit 0"
    receipt_line 20 solution  "md5 96d8c3e98fdd4893ccd304266c78445e  exit 0 then 0"
    receipt_line 20 offline   "md5 9eea88dc8bea20c1f216134741799357  exit 0"
    derived_unprobed 20

    receipt_panel 20 pattern
    panel 20 'checks each token against the field it produced' 1
    out_has_panel "…README's pattern panel — every token against the field it produced — is that block's own"
    receipt_panel 20 mdc
    panel 20 'Which lines belong to [*]this[*] order' 2
    out_has_panel "…README's mdc panel, ending in 'sites passing an order id: 0', is what the run printed"
    receipt_panel 20 roll
    panel 20 'the reason a 1 KB roller does not roll' 2
    out_has_panel "…README's roll panel — 1 file against 4, and 48 lines of 61 — is what the two runs measured"
    has "…and the discarded count is DERIVED, not described: a rolling appender deletes" \
        '^lines the window discarded: [0-9]+$'
    receipt_panel 20 gate
    panel 20 'read out of the jar rather than out of a blog post' 2
    out_has_lines "…README's gate panel is read out of logback-core-1.6.3.jar, not out of documentation"
    receipt_panel 20 handoff
    has "…receipts.sh handoff: state 1 lost the id on 2 of 2 cooking lines" \
        '^state 1 - cooking lines that reached the pool with NO id: 2 of 2$'
    has "…state 2 mislabelled exactly 1 of 2, which is worse than losing it" \
        "^state 2 - cooking lines labelled with another request's id: 1 of 2$"
    has "…and both states exited 0" '^the process exit code, in both states: 0$'
    receipt_panel 20 pool
    has "…receipts.sh pool: the repair carries 2 of 2 ids and 0 stale ones" '^cooking lines carrying a stale id: 0$'
    has "…and a pooled thread that had an id offers none to the task that has none" \
        '^tasks submitted with an empty MDC that came back with an empty MDC: 1 of 1$'
    # the exercise, both halves, against its own page
    receipt_panel 20 solution
    has "…the exercise's start state is 1 file, and the answer more than one" '^start state: 1 file\(s\), [0-9]+ line\(s\) on disk$'
    has "…and the answer DISCARDED lines, which is the trade the exercise is about" \
        '^lines rolled off the end and deleted: [0-9]+ of [0-9]+$'
    xpanel 20 '^## The end state you are reaching' 1
    is "…and c3-unit20/exercise/README.md's end state names FOUR log files" \
       "$(grep -c '^kitchen' "$WORK/panel" | tr -d ' ')" "4"
    is "…which is what its answer's <maxIndex> and the <checkIncrement> the starter has not add up to" \
       "$(grep -c '<checkIncrement>' "$REPO/c3-unit20/exercise/solution/logback.xml" | tr -d ' ')-$(grep -c '<checkIncrement>' "$REPO/c3-unit20/exercise/src/main/resources/logback.xml" | tr -d ' ')" \
       "2-0"
    # A SIZE IS NOT A CONSTANT, and that is this unit's own rule: the per-file byte sizes are
    # printed OUTSIDE the hash. A block that started hashing them would reproduce once.
    receipts_says 20 "…and the per-file byte sizes are printed OUTSIDE the hash, with the reason on screen" \
        '^outside the hash, because a byte size is not a constant:'
  fi

  offline_test 'mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -o test' 1800 "$REPO/c3-unit20" "$M2_U20"
fi

# ============================================================= c3-unit21 ====
# Structured logging. The claim worth checking here is the one the page makes about GREP being
# wrong in BOTH directions at once — a false positive it includes and two stack-trace lines it
# excludes — so both halves are counted, and the false positive is decided by the id FIELD at
# its position in the layout rather than by looking for a particular order.
if unit 21 "Structured logging"; then
  if ! command -v jq >/dev/null 2>&1; then
    skip "c3-unit21 — every check" "this unit needs jq on the PATH; its own receipts.sh refuses to run without it"
  else
  is "README quotes the five carried sources' hash, and it is the course's own" \
     "$(src_hash5 "$REPO/c3-unit21/src/main/java/com/tiffinbox")" "$(carried_five_hash 21)"
  is "…and the source root holds those five plus the two classes this unit adds" \
     "$(src_files "$REPO/c3-unit21/src/main/java")" \
     "./com/tiffinbox/Customer.java ./com/tiffinbox/CustomerRepository.java ./com/tiffinbox/Dashboard.java ./com/tiffinbox/Database.java ./com/tiffinbox/OrderQueue.java ./com/tiffinbox/kitchen/KitchenEvents.java ./com/tiffinbox/kitchen/Mdc.java "
  is "…and the README's block table names exactly the ids receipts.sh declares" \
     "$(readme_block_ids 21)" "$(receipts_ids 21)"
  # THE design of the unit, asserted before any of its numbers: both encodings come from ONE run,
  # because two runs would let any difference be blamed on the runs.
  is "logback.xml attaches the TEXT and the JSON appender to the SAME <root> — so no event can be in one file and not the other" \
     "$(sed -n '/<root /,/<\/root>/p' "$REPO/c3-unit21/src/main/resources/logback.xml" \
        | grep -oE 'ref="[A-Z]+"' | LC_ALL=C sort | tr '\n' ' ')" 'ref="CONSOLE" ref="JSON" ref="TEXT" '
  is "…and the JSON appender names orderId ZERO times: an MDC entry becomes a key with no configuration" \
     "$(sed -n '/<appender name="JSON"/,/<\/appender>/p' "$REPO/c3-unit21/src/main/resources/logback.xml" | grep -c 'orderId' | tr -d ' ')" "0"

  # ---- one run, two files. The README's own command, and then the two files it wrote.
  timed 1800 bash -c 'cd "$REPO/c3-unit21" && rm -rf target/logs && mvn -B -q "-Dmaven.repo.local=$M2_U21" compile exec:exec'
  if [ "$RC" -eq 0 ]; then
    exists "mvn -B -q compile exec:exec -> target/logs/kitchen.log" "$REPO/c3-unit21/target/logs/kitchen.log"
    exists "…and target/logs/kitchen.json, from the same run" "$REPO/c3-unit21/target/logs/kitchen.json"
    TL="$(grep -c . "$REPO/c3-unit21/target/logs/kitchen.log" | tr -d ' ')"
    JE="$(jq -s 'length' "$REPO/c3-unit21/target/logs/kitchen.json" 2>/dev/null)"
    is "…every line of the JSON log parses as one object per line, which is what makes jq's answer a measurement" \
       "$(jq -e . "$REPO/c3-unit21/target/logs/kitchen.json" >/dev/null 2>&1 && echo ok)" "ok"
    is "…8 lines in the text log" "$TL" "8"
    is "…6 objects in the JSON log — the text log is line-oriented and the events are not" "$JE" "6"
    # THE question, asked of both, exactly as the page asks it — and grep wrong in both
    # directions at once. `$4` is the id field at its position in the layout, which is how the
    # page decides which hits are false; a grep for the order id would agree with itself.
    JN="$(jq -c 'select(.orderId=="B-9082" and .level_value>=30000)' "$REPO/c3-unit21/target/logs/kitchen.json" | grep -c .)"
    GN="$(grep 'B-9082' "$REPO/c3-unit21/target/logs/kitchen.log" | grep -cE 'WARN|ERROR' | tr -d ' ')"
    FP="$(grep 'B-9082' "$REPO/c3-unit21/target/logs/kitchen.log" | grep -E 'WARN|ERROR' | awk '$4 != "B-9082" { c++ } END { print c+0 }')"
    TR="$(grep -cE '^(java\.|\s+at )' "$REPO/c3-unit21/target/logs/kitchen.log" | tr -d ' ')"
    is "jq 'select(.orderId==\"B-9082\" and .level_value>=30000)' -> 2 events" "$JN" "2"
    is "…grep B-9082 | grep -E 'WARN|ERROR' -> 3 lines, which is the wrong answer twice over" "$GN" "3"
    is "…one of those three belongs to a DIFFERENT order, decided by the id field at its position" "$FP" "1"
    is "…and two lines that ARE B-9082's are missing, because a stack-trace line carries no level and no id" "$TR" "2"
  else
    bad "mvn -B -q compile exec:exec (c3-unit21)" "exit $RC"
  fi

  # ---- receipts.sh: seven blocks, and the seven hashes on the deck (21-structured-logging.md)
  if run_receipts 21 3600; then
    is "…and it printed seven blocks, the count c3-unit21/README.md states" "$(receipts_blocks 21)" "7"
    is "…./receipts.sh 2>&1 | md5 -q -> the whole-run md5 the deck quotes for the seven" \
       "$(receipts_md5 21)" "c721452e39f57dc1b8c3a832d1d32ecb"
    receipt_line 21 both     "md5 9716f83c319f8ecc911b85f929feb2f8  exit 0"
    receipt_line 21 query    "md5 d164a83ddeb39cccaaaa5bd0b2e14a57  exit 0"
    receipt_line 21 fields   "md5 df250d771a99d2b88ea69eafb78e8842  exit 0"
    receipt_line 21 truncate "md5 af3a6212e942b190e5e428fb70fe06ac  exit 0"
    receipt_line 21 cost     "md5 0644e9d40df3d41736a7771b4ddb0fd3  exit 0"
    receipt_line 21 solution "md5 0b06995fc4f22b38d5e221b57c9ce29e  exit 0 then 0"
    receipt_line 21 offline  "md5 9ff76e632a99d4e98edd0e647da2fb68  exit 0"
    derived_unprobed 21

    receipt_panel 21 both
    panel 21 '^## One run, two encodings' 2
    out_has_lines "…README's 8-against-6 panel is what that block really counted"
    receipt_panel 21 query
    panel 21 '^## One question, asked of both' 2
    panel_unelide
    # The page re-cuts the two JSON lines by hand ("…,\"message\":…,… ") where the block cuts them
    # at 120 characters, so those two are dropped and the rest of the panel — the query itself,
    # the three grep hits and the four derived counts — is what the page is held to.
    panel_drop_re '^\{"@timestamp"'
    out_has_lines "…README's query panel — jq 2, grep 3, one of them somebody else's order — is that block's"
    is "…and the page shortens exactly TWO of that block's lines by hand: the two jq matched" \
       "$(grep -c '^{\"@timestamp\":\"<time>\",' "$OUT" | tr -d ' ')" "2"
    is "…each of which the block itself cut at 120 characters and marked with an ellipsis" \
       "$(grep -cE '^\{\"@timestamp\".{95,120}\.\.\.$' "$OUT" | tr -d ' ')" "2"
    receipt_panel 21 truncate
    panel 21 '^## The delimiter is not yours alone' 2
    out_has_panel "…README's truncate panel, and the 19 characters the layout's own separator cost"
    receipt_panel 21 fields
    panel 21 '^## Fields, and the one that is not there' 2
    out_has_lines "…README's fields panel — five events with the key, one with no such key at all"
    receipt_panel 21 cost
    panel 21 '^## What it costs — the honest other half' 2
    out_has_lines "…README's cost panel: three jackson rows, two groupIds, and the bytes per event"
    has "…and Jackson 3 really arrives under tools.jackson.*, beside Jackson 2 rather than against it" \
        'under tools\.jackson\.\* \(Jackson 3\) \.+ [0-9]+'
    # the exercise, both halves: the query answers 0 before and more than 0 after, with no
    # logback.xml change — which is the page's whole claim about a new field costing no config.
    receipt_panel 21 solution
    has "…the exercise's start state answers the query 0 times" \
        '^start state: jq select\(\.customer=="Bela"\) matched 0 of [0-9]+ event\(s\)$'
    has "…and the answer answers it, with the new key on the event" '^answer:      jq select\(\.customer=="Bela"\) matched [1-9]'
    # "Do NOT change logback.xml. The point is that a new field costs no configuration." The
    # receipt for that sentence is what the answer SHIPS: one Java file and no XML at all.
    is "…and the answer it ships is ONE file — the events class, with no logback.xml beside it" \
       "$(ls "$REPO/c3-unit21/exercise/solution" | tr '\n' ' ')" "KitchenEvents.java "
    is "…which reaches for StructuredArguments.kv, the tool the exercise page names, twice" \
       "$(grep -c 'StructuredArguments' "$REPO/c3-unit21/exercise/solution/KitchenEvents.java" | tr -d ' ')" "2"
    is "…and the starter reaches for it not at all, which is why the query answers nothing" \
       "$(grep -c 'StructuredArguments' "$REPO/c3-unit21/exercise/src/main/java/com/tiffinbox/kitchen/KitchenEvents.java" | tr -d ' ')" "0"
  fi

  offline_test 'mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -o test' 1800 "$REPO/c3-unit21" "$M2_U21"
  fi
fi

# ============================================================= c3-unit22 ====
# The one unit in this course whose subject IS a duration, and the split it makes is the thing
# to assert: four blocks hashed because nothing in them is a duration, and four printing
# `no md5:` and a reason because everything in them is. A block that started hashing a Score
# would be the defect, not an improvement.
#
# And the three unhashed blocks guard a fact about the MACHINE. `scores` stops if an interval
# pair overlaps, `deadcode` if the discarded call stops being indistinguishable from an empty
# method, `jfr` if the compilation rate does not fall by four — and the README says in so many
# words that an overlap is section 2c's legitimate answer ("I could not measure a difference
# above the noise on this machine"). So the default `./receipts.sh` CAN exit 1 here through no
# fault of the deliverable, which is why the five hashed blocks are run on their own first and
# the three guarded ones one at a time after: each of those is a PASS when it clears its guard,
# a labelled SKIP when it stops with its OWN documented refusal, and a FAIL on anything else.
if unit 22 "JMH and JFR: honest measurement"; then
  is "README quotes the five carried sources' hash, and it is the course's own" \
     "$(src_hash5 "$REPO/c3-unit22/src/main/java/com/tiffinbox")" "$(carried_five_hash 22)"
  is "…and the source root holds those five plus the three classes this unit adds" \
     "$(src_files "$REPO/c3-unit22/src/main/java")" \
     "./com/tiffinbox/Customer.java ./com/tiffinbox/CustomerRepository.java ./com/tiffinbox/Dashboard.java ./com/tiffinbox/Database.java ./com/tiffinbox/OrderQueue.java ./com/tiffinbox/bench/NaiveTimer.java ./com/tiffinbox/bench/ReceiptBench.java ./com/tiffinbox/bench/Receipts.java "
  is "…and the README's block table names exactly the ids receipts.sh declares, sweep included" \
     "$(readme_block_ids 22)" "$(receipts_ids 22)"
  # THE contract this unit is auditing, read out of the page's own table: which blocks are
  # hashed and which are not. A row that changed its answer is the defect.
  is "README's table marks \`scores\`, \`deadcode\` and \`jfr\` as NOT hashed" \
     "$(grep -cE '^\| `(scores|deadcode|jfr)` \| no \|' "$REPO/c3-unit22/README.md" | tr -d ' ')" "3"
  is "…and \`harness\`, \`release\` and \`offline\` as hashed" \
     "$(grep -cE '^\| `(harness|release|offline)` \| \*\*yes\*\* \|' "$REPO/c3-unit22/README.md" | tr -d ' ')" "3"
  is "…and \`naive\` and \`solution\` as structure only" \
     "$(grep -cE '^\| `(naive|solution)` \| \*\*structure only\*\* \|' "$REPO/c3-unit22/README.md" | tr -d ' ')" "2"
  # the pins the harness block reads back out of the benchmark, so the Cnt column on the page
  # is arithmetic rather than a memory: forks x measurement iterations.
  is "ReceiptBench declares @Fork(2) and @Measurement(iterations = 3), so Cnt on a full run must be 6" \
     "$(( $(grep -oE '@Fork\([0-9]+\)' "$REPO/c3-unit22/src/main/java/com/tiffinbox/bench/ReceiptBench.java" | head -1 | tr -cd '0-9') * $(grep -oE '@Measurement\(iterations = [0-9]+' "$REPO/c3-unit22/src/main/java/com/tiffinbox/bench/ReceiptBench.java" | head -1 | tr -cd '0-9') ))" "6"
  is "…and @Param({\"6\", \"600\"}), which is why the small row cannot be read as a rule" \
     "$(grep -oE '@Param\(\{[^}]*\}\)' "$REPO/c3-unit22/src/main/java/com/tiffinbox/bench/ReceiptBench.java" | grep -oE '[0-9]+' | tr '\n' ' ')" "6 600 "

  # ---- the five blocks whose content is not a duration
  if expect_ok "c3-unit22/receipts.sh harness naive release solution offline — the five with a hash" 5400 '' \
      bash -c "cd \"$REPO/c3-unit22\" && ./receipts.sh harness naive release solution offline"; then
    cp "$OUT" "$WORK/receipts.22"
    is "…five blocks" "$(receipts_blocks 22)" "5"
    receipt_line 22 harness  "md5 fec852069415f845b2b42123de949c67  exit 0"
    receipt_line 22 naive    "md5 5f476dc39b6b360d1ab374dcc17041fe  exit 0"
    receipt_line 22 release  "md5 cc9b7bd93d0523bd3f0a79c3166ef3bb  (no build)"
    receipt_line 22 solution "md5 e311f7bfc86e275fe255b60e33f76c9d  exit 0 then 0"
    receipt_line 22 offline  "md5 b0e0f803461c1733a1749dd53939d6ce  exit 0"
    is "…and TWO of those five also printed \`no md5:\` and a reason — naive's numbers and the answer's scores" \
       "$(unhashed_blocks 22)" "2"

    receipt_panel 22 harness
    panel 22 '^## What the harness tells you before' 2
    out_has_panel "…README's conditions panel is the eight lines JMH printed, whether you ask or not"
    panel 22 '^## What the harness tells you before' 3
    out_has_panel "…and the three lines the -f 0 on that command line costs, in the harness's own words"
    has "…four sun.misc.Unsafe warnings on JDK 25, which are real and are not a reason to distrust the numbers" \
        '^WARNING lines the JVM printed: 4$'
    has "…and the header printed twice, once per @Param size, with the cut counted rather than pasted" \
        '^configuration headers JMH printed in this one run: 2 - one per @Param size,$'
    readme_quotes "…and the README carries JMH's own sentence about its own numbers" 22 \
        "Do not assume the numbers tell you what you want them to tell."
    receipt_panel 22 naive
    panel 22 '^## The stopwatch, and what it cannot tell you' 2
    out_has_panel "…README's five-count panel over the stopwatch's result lines is that block's own"
    has "…and four of the five counts are ZERO, which are the four conditions this course requires" \
        '^  lines carrying an error term \.+ 0$'
    has "…while the fifth is not, which is what makes the four zeroes a measurement" \
        '^  lines carrying a unit \.+ 9$'
    receipt_panel 22 release
    has "…receipts.sh release: JMH 1.37 is the last entry of its own version list" \
        '^  last entry of the version list \.\. 1\.37  \(the same string: yes\)$'
    has "…and no rc or milestone sits above it" '^no rc and no milestone sits above it'
    # the exercise, both halves: an empty Error column, then Cnt 6 with a ± on every row. The
    # scores themselves are durations and the exercise page says so; the two COUNTS are not.
    receipt_panel 22 solution
    has "…the exercise's start state prints Cnt = 2 and ZERO error terms" \
        '^start state: Cnt = 2 ; result rows carrying an error term: 0$'
    has "…and the answer Cnt = 6 with an error term on every row" \
        '^answer:      Cnt = 6 ; result rows carrying an error term: 2 of 2$'
    xreadme_hasnt "…and the exercise page never claims one of the two is faster: no such verdict on it" 22 \
        '(concatenation|concat) is (faster|quicker) than'
    xreadme_quotes "…what its own page says instead is that you cannot tell" 22 \
        "**on this machine, you cannot tell.**"
  fi

  # ---- and the three whose guard is a fact about this machine
  jmh_guarded "receipts.sh scores — the score table, and the verdict at each size" 5400 22 scores \
      '^the verdict at each size, smallest first: concat builder$'
  # …and the GUARD, which is what makes that verdict a claim rather than a print. Measured: take
  # the `die` out of the OVERLAP arm and the block prints "OVERLAP builder" and carries on — and on
  # a quiet machine NOTHING in this script moves, because the overlap only happens under load. The
  # behaviour needs a loaded machine; the wiring does not, so the wiring is read out of the
  # deliverable, exactly as unit 10's drift block is.
  S22="$(sed -n '/^ *verdicts=\$(printf/,/^  esac$/p' "$REPO/c3-unit22/receipts.sh")"
  is "receipts.sh scores still DIES on an OVERLAP rather than printing one — the guard is what makes that verdict a claim" \
     "$(printf '%s\n' "$S22" | grep -A1 '[*]OVERLAP[*])' | grep -c '^ *die "an interval pair OVERLAPS on this run' | tr -d ' ')" "1"
  is "…and the arm that PASSES is the matched pair alone, with anything else dying too — two die()s in that case, not one" \
     "$(printf '%s\n' "$S22" | grep -c '^ *die ' | tr -d ' ')" "2"
  is "…and the sentence it dies with is section 2c's, so a viewer is told the answer is legitimate rather than that the block is broken" \
     "$(printf '%s\n' "$S22" | grep -c "I could not measure a difference above the noise on this machine" | tr -d ' ')" "1"
  case "$?" in
    0) U22R="$(grep -cE '^ReceiptBench\.' "$OUT" | tr -d ' ')"
       is "…six result rows: three benchmarks at two input sizes, which is the arithmetic above" "$U22R" "6"
       is "…and every one of them carries an error term, which JMH refuses to print with fewer than three samples" \
          "$(grep -cE '^ReceiptBench\..*±' "$OUT" | tr -d ' ')" "6" ;;
  esac
  jmh_guarded "receipts.sh deadcode — the same call four ways, and the one that measures nothing" 5400 22 deadcode \
      '^what is left of the discarded call, as a fraction of the work measured: 0\.[0-4][0-9]  \(the guard: below 0\.50\)$'
  jmh_guarded "receipts.sh jfr — the warm-up, as a count of compilations rather than a duration" 5400 22 jfr \
      '^the first interval compiled at least four times what the last one did: yes$'
  exists "…and the artifact that proves the recorder ran is the recording, not the exit code" \
      "$REPO/c3-unit22/target/bench.jfr"

  # ---- sweep, which the README calls the block that decides whether any of it is worth quoting
  if [ "$SKIP_SLOW" = "1" ]; then
    skip "RUNS=2 ./receipts.sh sweep" "SKIP_SLOW=1 — two more JMH runs; the README documents the RUNS knob"
  else
    if expect_ok "RUNS=2 ./receipts.sh sweep (not in the default run — the README says so)" 5400 \
        '^of 4 readings \(2 runs x 2 input sizes\) on one machine in one session:$' \
        bash -c "cd \"$REPO/c3-unit22\" && RUNS=2 ./receipts.sh sweep"; then
      is "…and it printed NO md5 at all: N readings of a duration cannot be byte-identical" \
         "$(countq '^md5 ')" "0"
      has "…it records the load average beside every row, because machine load is a flag" \
          '^ *[0-9]+ +[0-9.]+ +(6|600) '
      has "…and the verdicts add up to the readings it took" \
          '^[0-9]+ said the two overlap, [0-9]+ said they are separated$'
      has "…with a \`no md5:\` line saying why there is none" '^no md5: N runs of a duration on one machine'
    fi
  fi
fi

# ============================================================= c3-unit23 ====
# Section 5 opens. Two things here are assertions nothing else in this script makes.
#
#   * **The overlap capture must hash the same from two different directories.** maven-shade-
#     plugin walks its overlap groups in an order that is stable inside one directory and
#     DIFFERENT between directories — three copies of this tree gave three hashes — so the block
#     now `LC_ALL=C sort`s the three warning lines before it hashes them. A fix like that is
#     only a fix if it is measured, so this runs the block twice: in place, and again from a
#     copy under $TMPDIR, and asserts ONE hash.
#   * **The Class-Path header is a promise nothing checks**, and the lesson is a FAILURE. The
#     assertion is the failing run and the zero lines of warning beside it — never `BUILD
#     SUCCESS`, which is what the build that wrote that header printed.
if unit 23 "Jars, fat jars, layered jars"; then
  is "README quotes the five carried sources' hash, and it is the course's own" \
     "$(src_hash5 "$REPO/c3-unit23/src/main/java/com/tiffinbox")" "$(carried_five_hash 23)"
  is "…and the source root holds those five plus the one class this unit adds, one package down" \
     "$(src_files "$REPO/c3-unit23/src/main/java")" \
     "./com/tiffinbox/Customer.java ./com/tiffinbox/CustomerRepository.java ./com/tiffinbox/Dashboard.java ./com/tiffinbox/Database.java ./com/tiffinbox/OrderQueue.java ./com/tiffinbox/ship/TiffinBoxApp.java "
  is "…and the README's block table names exactly the ids receipts.sh declares" \
     "$(readme_block_ids 23)" "$(receipts_ids 23)"

  # ---- one program, three files. The entry counts are the README's own table, and they are
  # read out of the ARCHIVES: a green `mvn package` says nothing about what is in a jar.
  expect_ok "mvn -B clean package -> the thin jar and its four libs" 1800 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit23" && mvn -B "-Dmaven.repo.local=$M2_U23" clean package'
  is "unzip -l target/tiffinbox-core-1.0.0.jar -> 18 entries, the number the README's table states" \
     "$(unzip -l "$REPO/c3-unit23/target/tiffinbox-core-1.0.0.jar" 2>/dev/null | tail -1 | awk '{print $2}')" "18"
  readme_quotes "…and the page really does say 18" 23 "**18 entries**"
  is "…and four jars landed in target/lib, which is what the thin jar needs beside it" \
     "$(ls -1 "$REPO/c3-unit23/target/lib"/*.jar 2>/dev/null | wc -l | tr -d ' ')" "4"
  expect_ok "mvn -B -Pfat package -> the uber jar" 1800 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit23" && mvn -B "-Dmaven.repo.local=$M2_U23" -Pfat package'
  is "unzip -l target/tiffinbox-fat.jar -> 2354 entries, the number the README's table states" \
     "$(unzip -l "$REPO/c3-unit23/target/tiffinbox-fat.jar" 2>/dev/null | tail -1 | awk '{print $2}')" "2354"
  readme_quotes "…and the page really does say 2354" 23 "**2354 entries**"
  # "Layered is not a third archive format" — the README's own sentence, and the receipt for it
  # is that there is no third FILE. Two artifacts in target/, and the layered one is the thin
  # jar plus a directory.
  is "…and 'layered' really is not a third archive: target/ holds the thin jar and the fat jar, and no other" \
     "$(ls -1 "$REPO/c3-unit23/target"/*.jar 2>/dev/null | wc -l | tr -d ' ')" "2"

  # ---- the header nothing checks. Exit 0, then exit 1, the SAME jar, nothing rebuilt.
  expect_ok "java -jar target/tiffinbox-core-1.0.0.jar (with target/lib beside it)" 300 '' \
      bash -c 'cd "$REPO/c3-unit23" && "$JAVA" "-D$TAG=u23" -jar target/tiffinbox-core-1.0.0.jar'
  mv "$REPO/c3-unit23/target/lib" "$REPO/c3-unit23/target/lib-verify-moved" 2>/dev/null
  expect_fail "…one directory renamed, nothing rebuilt: the SAME jar now dies" 300 \
      'NoClassDefFoundError: com/fasterxml/jackson/databind/ObjectMapper' \
      bash -c 'cd "$REPO/c3-unit23" && "$JAVA" "-D$TAG=u23" -jar target/tiffinbox-core-1.0.0.jar'
  mv "$REPO/c3-unit23/target/lib-verify-moved" "$REPO/c3-unit23/target/lib" 2>/dev/null
  timed 120 bash -c 'cd "$REPO/c3-unit23" && unzip -p target/tiffinbox-core-1.0.0.jar META-INF/MANIFEST.MF | tr -d "\r"'
  has "…and the manifest really does name four jars it never checks" 'Class-Path: lib/h2-2\.5\.250\.jar'
  is "…four of them, counted with the continuation line unfolded — a folded header undercounts" \
     "$(unzip -p "$REPO/c3-unit23/target/tiffinbox-core-1.0.0.jar" META-INF/MANIFEST.MF | tr -d '\r' \
        | awk '/^Class-Path:/{f=1;print;next} f&&/^ /{print;next} {f=0}' | grep -o 'lib/' | wc -l | tr -d ' ')" "4"

  # ---- receipts.sh: eight blocks, and the eight hashes the deck (23-jars-fat-jars-layered-
  # jars.md) quotes. c3-unit23/README.md quotes none of them in the `→ md5` shape.
  if run_receipts 23 5400; then
    is "…and it printed eight blocks, the count c3-unit23/README.md's table states" "$(receipts_blocks 23)" "8"
    receipt_line 23 three     "md5 1190c8b5bfe13a08bab8a15bdc73f081  (exit 0)"
    receipt_line 23 classpath "md5 c47ee3540a9fb2f4671472fd22a4370e  (exit 0 with lib present, exit 1 without)"
    receipt_line 23 overlap   "md5 ece50c68d852a1238fbe28f9bf08f65e  (exit 0 then 0)"
    receipt_line 23 jdeps     "md5 e89fc0168d976861d1f040f4a3728de7  (exit 1, 2, 0)"
    receipt_line 23 layers    "md5 4c26626bfcb4c0b933a3491a8fb75aff  (over the block above with the byte-size line removed - 1 line elided, counted)"
    receipt_line 23 release   "md5 70b715d9acd4c4a15402f6f8639fe3fc  (no build)"
    receipt_line 23 solution  "md5 8dd5d7029554f3bf112d9ffa808c2b10  (exit 0 then 0)"
    receipt_line 23 offline   "md5 f29bccc4bc3de9f2164bd7b1f439362b  (exit 0)"
    derived_unprobed 23

    # THE fix this unit shipped, measured rather than believed. The three warning lines are
    # shade's, character for character; only their ORDER is the block's, and the whole reason
    # for sorting them is that shade's own order is a property of the directory. So: the same
    # block, from a second checkout on a different path, has to print the same hash.
    U23H="$(receipt_hash_of 23 overlap)"
    case "$WORK" in
      *\ *) skip "receipts.sh overlap from a SECOND checkout path" \
                 "TMPDIR has a space in it, so there is no second path here to compare against; set TMPDIR to one without" ;;
      *)
        rm -rf "$WORK/u23"
        ( cd "$REPO/c3-unit23" && tar cf - pom.xml src exercise central receipts.sh ) | ( mkdir -p "$WORK/u23" && cd "$WORK/u23" && tar xf - ) 2>/dev/null
        ln -s "$M2_U23" "$WORK/u23/.m2-demo" 2>/dev/null
        if expect_ok "receipts.sh overlap, run again from a copy on a DIFFERENT path" 1800 '^md5 ' \
            bash -c "cd \"$WORK/u23\" && ./receipts.sh overlap"; then
          is "…and it is ONE hash across the two paths — which is the whole point of LC_ALL=C sorting shade's warnings" \
             "$(sed -n 's/^md5 \([0-9a-f]*\).*/\1/p' "$OUT" | head -1)" "$U23H"
        fi
        rm -rf "$WORK/u23"
        ;;
    esac
    is "…and the sort really is in the block: receipts.sh pipes shade's warnings through LC_ALL=C sort" \
       "$(grep -c 'LC_ALL=C sort > \.r-warn\.raw' "$REPO/c3-unit23/receipts.sh" | tr -d ' ')" "1"
    receipt_panel 23 overlap
    # …the THREE warning lines, and only those: the block prints a fourth, indented, copy of
  # the widest one under its own elision count, and a sort over all four is a different question.
  W23="$(grep -E '^[^ ].*define [0-9]+ overlapping' "$OUT")"
    is "…and the three warning lines in the capture really are in C order, not shade's" \
       "$(printf '%s\n' "$W23" | LC_ALL=C sort | md5in)" "$(printf '%s\n' "$W23" | md5in)"
    panel 23 'the honest half, which matters more than the folklore' 1
    out_has_lines "…README's services panel — 14 bytes against 13, one byte and nothing breaks — is that block's"
    panel 23 '^## What a fat jar throws away' 1
    panel_unelide
    out_has_lines "…and its licence arithmetic: 3 input jars carry it, 1 survives, 2 gone"
    has "…two licence files did not survive the merge, derived rather than described" \
        '^licence files that did not survive being merged: 2$'
    has "…and the fat jar still carries a Class-Path header for a lib/ it does not need" \
        '^Class-Path entries in a jar that needs none: 4$'

    # layering, which is not a file format: which bytes move when one line moves.
    receipt_panel 23 layers
    panel 23 '^## One program, three files' 1
    out_has_lines "…README's layers panel — the application layer moved, the dependency layer did not"
    has "…1 of 2 layers changed" '^layers whose bytes changed: 1 of 2$'
    has "…and the ratio that is the whole argument for layering: 3 bytes in a thousand" \
        '^bytes of application layer per 1000 bytes of the two layers together: 3$'
    # …and the ONE count in that block a literal could impersonate. `jars in the dependency
    # layer: 4` is right today, and `"4"` in its place is the same bytes, the same block md5 and
    # the same whole-run md5 — measured: that substitution left this entire script green until
    # this probe was written. No hash can tell a measurement from a caption; only moving the
    # input can. So a copy of the unit is given MORE jars in its dependency layer — junit-jupiter
    # promoted out of test scope, which is already in this unit's own repository because its own
    # tests use it, so nothing is downloaded — and the block is re-run there. A derived count
    # follows the input; a literal keeps saying 4.
    case "$WORK" in
      *\ *) skip "…c3-unit23/receipts.sh layers: its dependency-layer count PROBED rather than hashed" \
                 "TMPDIR has a space in it, and this probe needs a second directory to build in; set TMPDIR to one without" ;;
      *)
        D23="$WORK/d23"; rm -rf "$D23"; mkdir -p "$D23"
        ( cd "$REPO/c3-unit23" && tar cf - pom.xml src receipts.sh ) | ( cd "$D23" && tar xf - ) 2>/dev/null
        ln -s "$M2_U23" "$D23/.m2-demo"
        if python3 - "$D23/pom.xml" <<'PY23'
import sys
p = sys.argv[1]
a = """      <artifactId>junit-jupiter</artifactId>
      <scope>test</scope>"""
b = """      <artifactId>junit-jupiter</artifactId>"""
s = open(p, encoding='utf-8').read()
if s.count(a) != 1:
    sys.exit(3)
open(p, "w", encoding='utf-8').write(s.replace(a, b))
PY23
        then
          if expect_ok "receipts.sh layers, re-run in a copy whose dependency layer has MORE jars in it" 1800 \
              '^jars in the dependency layer: [0-9]+$' bash -c "cd \"$D23\" && ./receipts.sh layers"; then
            N23="$(grep -oE '^jars in the dependency layer: [0-9]+' "$OUT" | grep -oE '[0-9]+$')"
            is "…and that count FOLLOWED the input, which a literal 4 could not" \
               "$( [ -n "$N23" ] && [ "$N23" -gt 4 ] && echo "more than 4" || echo "still ${N23:-nothing}" )" "more than 4"
            is "…and it is exactly the number of jars that copy's build really put there" \
               "$N23" "$(ls "$D23"/target/lib/*.jar 2>/dev/null | wc -l | tr -d ' ')"
          fi
        else
          bad "c3-unit23 layers: the dependency-layer probe" \
              "the edit did not apply exactly once to the copy's pom.xml — the probe would prove nothing"
        fi
        rm -rf "$D23"
        ;;
    esac
    # jdeps: the exit codes ARE the lesson, and the module-info it finally wrote
    receipt_panel 23 jdeps
    has "…receipts.sh jdeps: two of the three attempts failed" '^attempts that failed: 2 of 3$'
    has "…and the line to remember is requires transitive java.sql" 'requires transitive java\.sql;'
    panel 23 '^## .jdeps --generate-module-info.' 2
    panel_indent 2
    out_has_lines "…and the module-info c3-unit23/README.md prints is the one jdeps really generated"
    receipt_panel 23 release
    panel 23 '^## .<release>. is not' 1
    panel_indent 2
    out_has_lines "…README's <release> panel is derived from central/ with no network"
    # the exercise's END state, and the sentence that makes its START state a start state
    receipt_panel 23 solution
    has "…the exercise's two start-state builds do NOT agree" '^  the two builds agree: no$'
    has "…and its two answered builds do" '^  the two builds agree: yes$'
    has "…with 0 lines of Java changed" '^lines of Java changed to get there: 0$'
    receipts_says 23 "…and the four jar hashes under it are printed OUTSIDE the hash, with the reason: the start state moves on purpose" \
        '^no md5 on these four: the start state is non-reproducible ON PURPOSE'
  fi

  # ---- the exercise's START state, run with the page's own two commands: the same build
  # twice, and two different files. This is the one beat in the unit whose evidence is that a
  # hash does NOT reproduce, so it is measured here as well as inside the receipts block.
  is "exercise/pom.xml really is missing the property — otherwise there is nothing to fix" \
     "$(grep -c 'outputTimestamp' "$REPO/c3-unit23/exercise/pom.xml" | tr -d ' ')" "0"
  U23A=""; U23B=""
  if expect_ok "exercise: mvn -B clean package -DskipTests (build 1 of 2)" 1800 '' \
      bash -c 'cd "$REPO/c3-unit23/exercise" && mvn -B -q "-Dmaven.repo.local=../.m2-demo" clean package -DskipTests'; then
    U23A="$(md5of "$REPO/c3-unit23/exercise/target/tiffinbox-core-1.0.0.jar" 2>/dev/null)"
    sleep 1
    if expect_ok "exercise: …and again, with nothing changed between them" 1800 '' \
        bash -c 'cd "$REPO/c3-unit23/exercise" && mvn -B -q "-Dmaven.repo.local=../.m2-demo" clean package -DskipTests'; then
      U23B="$(md5of "$REPO/c3-unit23/exercise/target/tiffinbox-core-1.0.0.jar" 2>/dev/null)"
      is "…and the two hashes DIFFER: the jar's entry timestamps are a wall clock, which is not a build input you control" \
         "$( [ -n "$U23A" ] && [ "$U23A" != "$U23B" ] && echo different || echo "the same" )" "different"
    fi
  fi
  is "…and the answer is ONE property, in exercise/solution/pom-fragment.xml" \
     "$(grep -c '<project\.build\.outputTimestamp>' "$REPO/c3-unit23/exercise/solution/pom-fragment.xml" | tr -d ' ')" "1"
  xreadme_hasnt "…and the exercise page quotes neither of those two hashes, because they move every run" 23 '[0-9a-f]{32}'
fi

# ============================================================= c3-unit24 ====
# The unit whose subject is git, which makes it the one place in this script where a receipts
# run could do real damage. So this section is built the other way round from every other: the
# FIRST thing it does is fingerprint the repository it is standing in — HEAD, the commit count,
# every ref, the object-store census and the working-tree status — and the last thing it does is
# assert all five unchanged. The unit's own defence is a `guard()` that refuses to run a write
# command against any tree whose top level is not under `c3-unit24/.repos/`, and that guard is
# checked in both directions: statically, that it is there and what it refuses, and dynamically,
# that a block which creates three repositories left this one alone.
if unit 24 "Git workflow for real"; then
  if ! command -v git >/dev/null 2>&1 || ! ( cd "$REPO" && git rev-parse --git-dir >/dev/null 2>&1 ); then
    skip "c3-unit24 — every check" "this unit reads the repository it ships in, and this is not a git checkout"
  else
  is "README quotes the five carried sources' hash, and it is the course's own" \
     "$(src_hash5 "$REPO/c3-unit24/src/main/java/com/tiffinbox")" "$(carried_five_hash 24)"
  is "…and the README's block table names exactly the ids receipts.sh declares" \
     "$(readme_block_ids 24)" "$(receipts_ids 24)"

  # ---- the guard, read out of the deliverable
  is "receipts.sh carries a guard() that REFUSES a write outside .repos/" \
     "$(grep -c 'REFUSING to write to .* - it is not under' "$REPO/c3-unit24/receipts.sh" | tr -d ' ')" "1"
  is "…and every throwaway repository it makes is created under \$PLAY, which is c3-unit24/.repos" \
     "$(grep -c '^PLAY="\$PWD/\.repos"$' "$REPO/c3-unit24/receipts.sh" | tr -d ' ')" "1"
  is "…and the one block that touches THIS repository runs no write command at all — 0 of commit, push, rebase, reset, tag, add, rm, checkout, merge, init, clone" \
     "$(sed -n '/^run_realrepo() {/,/^}$/p' "$REPO/c3-unit24/receipts.sh" \
        | grep -cE '(^|[ 	(`$])(git|G)( +-[cC] +[^ ]+)* +(commit|push|rebase|reset|tag|add|rm|checkout|merge|init|clone)\b' | tr -d ' ')" "0"
  # …and that the count above can go up. A regex that matches nothing is not a finding, so the
  # same regex is run over a block that DOES write, and has to see it.
  is "…and that zero is a measurement: the same regex over run_branch, which does write, counts nine" \
     "$(sed -n '/^run_branch() {/,/^}$/p' "$REPO/c3-unit24/receipts.sh" \
        | grep -cE '(^|[ 	(`$])(git|G)( +-[cC] +[^ ]+)* +(commit|push|rebase|reset|tag|add|rm|checkout|merge|init|clone)\b' | tr -d ' ')" "9"
  # ~/.gitconfig is never read and never written: every commit sets its identity through the
  # environment and every git invocation carries -c user.name / -c core.hooksPath=/dev/null.
  is "…and every git invocation goes through -c core.hooksPath=/dev/null, so ~/.gitconfig and your hooks are never read" \
     "$(grep -c 'core\.hooksPath=/dev/null' "$REPO/c3-unit24/receipts.sh" | tr -d ' ')" "1"
  is "…and the eight fields a commit id is made of are pinned through the environment, not through ~/.gitconfig" \
     "$(grep -cE '^ *export GIT_(AUTHOR|COMMITTER)_(NAME|EMAIL|DATE)' "$REPO/c3-unit24/receipts.sh" | tr -d ' ')" "4"
  if [ -f "$HOME/.gitconfig" ]; then GC24="$(md5of "$HOME/.gitconfig")"; else GC24="absent"; fi

  # ---- the dynamic half. One block that creates three repositories, and this one untouched.
  G24="$(git_state)"
  rm -rf "$REPO/c3-unit24/.repos"
  if expect_ok "receipts.sh branch, run on its own: it creates its own repositories" 1800 '^md5 ' \
      bash -c "cd \"$REPO/c3-unit24\" && ./receipts.sh branch"; then
    is "…three of them, all of them under c3-unit24/.repos/ and none anywhere else" \
       "$(find "$REPO/c3-unit24/.repos" -maxdepth 2 -type d -name '.git' 2>/dev/null | wc -l | tr -d ' ')" "3"
    is "…and there is no .git anywhere else under c3-unit24/ — not one repository outside .repos" \
       "$(find "$REPO/c3-unit24" -type d -name '.git' -not -path "$REPO/c3-unit24/.repos/*" 2>/dev/null | wc -l | tr -d ' ')" "0"
    is "…and THIS repository is byte-identical: HEAD, the commit count, every ref, the object census and the working tree" \
       "$(git_state)" "$G24"
  fi
  if expect_ok "receipts.sh clean -> it removes the repositories it made" 300 'removed' \
      bash -c "cd \"$REPO/c3-unit24\" && ./receipts.sh clean"; then
    absent "…and c3-unit24/.repos is gone" "$REPO/c3-unit24/.repos"
  fi

  # ---- receipts.sh: nine blocks plus clean, and the seven hashes the deck (24-git-workflow-
  # for-real.md) quotes. TWO of them are live snapshots of a repository that grows, and this
  # script does not demand either — see not_pinned below.
  G24="$(git_state)"
  if run_receipts 24 3600; then
    is "…and it printed nine blocks (clean prints no header of its own)" "$(receipts_blocks 24)" "9"
    is "…and after all nine, THIS repository is still byte-identical — the guard held" \
       "$(git_state)" "$G24"
    if [ "$GC24" = absent ]; then
      absent "…and ~/.gitconfig was not created" "$HOME/.gitconfig"
    else
      is "…and ~/.gitconfig is unchanged" "$(md5of "$HOME/.gitconfig")" "$GC24"
    fi
    absent "…and .repos is gone again, because the default run ends with clean" "$REPO/c3-unit24/.repos"

    receipt_line 24 branch   "md5 049d00ea4d8c52aa02c43bf3a02e69d0  (exit 0)"
    receipt_line 24 tag      "md5 82193ccd6148bcfa9121d984724973d4  (exit 0)"
    receipt_line 24 hashes   "md5 dccf45d14f25a2a05ce72e4907725443  (exit 0)"
    receipt_line 24 ignored  "md5 bbb767466752863a9ed7ab7e0255f4ed  (exit 0)"
    receipt_line 24 wrapper  "md5 86413d3d1d5235f1bee78832ee47ca48  (exit 1 from ./gradlew in the clone)"
    receipt_line 24 solution "md5 ee12aa67a26f4d1ea9e6c11607b206d4  (exit 0 then 0)"
    derived_unprobed 24

    # THE TWO THAT MOVE. `convention`'s second half and the whole of `realrepo` are find(1) and
    # git(1) over this repository as it stands right now — the commit count grows, the author
    # count can change, the dates move — and both blocks print that instruction themselves. So
    # the STRUCTURE is asserted and the figure is not.
    receipts_says 24 "…receipts.sh realrepo says its own md5 is a SNAPSHOT and is SUPPOSED to move" \
        'and that md5 is a SNAPSHOT, not a constant'
    not_pinned "…receipts.sh realrepo -> md5 $(receipt_hash_of 24 realrepo)" \
        "every number in that block is a property of this repository as it stands right now (36 commits today, 34 on the page), and the block says so in its own output; what is asserted instead is the structure below"
    not_pinned "…receipts.sh convention -> md5 $(receipt_hash_of 24 convention), the hash the deck quotes as e7fea4ee19b0453f32c32bd75a327de8" \
        "its second half counts the commits of the repository it ships in, so it moved the moment the next commit landed — the four throwaway commits and the ZERO conventional ones in the real history are asserted below instead"
    receipt_panel 24 convention
    has "…and the throwaway history it built is four commits, four of them classifiable" \
        '^commits in this history \.+ 4$'
    has "…with one marked breaking by the !" '^commits marked breaking by the ! \.+ 1$'
    has "…and the arithmetic holds: 4 classifiable, 0 it cannot" '^commits it cannot \.+ 0$'
    # THE finding, and it is a zero that means something: this repository does NOT use
    # conventional commits, and the same parser that read four out of four reads none here.
    has "…and asked of the repository this unit ships in, that parser reads ZERO" \
        '^  commits a conventional-commit parser can read \.+ 0$'
    has "…over a history that is not empty, which is what makes the zero a finding" '^  commits \.+ [1-9][0-9]*$'
    panel 24 '^## A message shape a command can read' 1
    panel_drop_re '^  commits \.+ [0-9]+$'
    out_has_lines "…and the rest of that panel is what the block really printed"
    receipt_panel 24 realrepo
    has "…receipts.sh realrepo: target/ paths tracked anywhere is 0" '^  target/ paths tracked anywhere \.+ 0$'
    has "…and build/ paths 0 — this repository ships no build output" '^  build/ paths tracked anywhere \.+ 0$'
    has "…while the gradle wrapper IS tracked here, which is the unit's own rule applied to itself" \
        '^  tracked wrapper jars \.+ [1-9]'

    # the three beats whose evidence is an object, a count or an exit code
    receipt_panel 24 hashes
    has "…receipts.sh hashes: the same commit in two directories is the same id" '^  identical: yes$'
    has "…one field changed by one second and the id is different" '^  identical to the first: no$'
    has "…over three identical trees, which is the whole point" '^  all three trees identical: yes$'
    receipt_panel 24 ignored
    has "…receipts.sh ignored: git rm --cached removed 0 objects" '^objects the un-commit removed \.+ 0$'
    has "…and ADDED two — the repository got bigger" '^objects it ADDED \.+ 2   \(one commit, one tree\)$'
    has "…and the blob is still reachable in the history, forever" 'HEAD~1:target/tiffinbox-core-1\.0\.0\.jar -> blob$'
    receipt_panel 24 wrapper
    has "…receipts.sh wrapper: git status reports nothing at all" '^  git status --porcelain lines \.+ 0   \(nothing to report\)$'
    has "…the jar is present in YOUR copy" '^  gradle/wrapper/gradle-wrapper\.jar \.+ present$'
    has "…and absent in a real clone, which is the only honest test of a \.gitignore" \
        '^  gradle/wrapper/gradle-wrapper\.jar \.+ absent$'
    has "…where ./gradlew cannot start" 'Unable to access jarfile'
    has "…0 jar files tracked against 1 in the working copy — that gap IS the bug" \
        '^jar files TRACKED in the repository \.+ 0$'
    receipt_panel 24 tag
    has "…receipts.sh tag: the annotated tag is a tag OBJECT, not a commit" '^  annotated tag         -> tag object$'
    has "…the lightweight one IS the commit" '^  lightweight tag       -> commit object$'
    has "…and a branch moves under you while a tag does not" '^  they are the same commit: no$'
    receipt_panel 24 solution
    has "…the exercise's start state tracks 0 wrapper jars" '^  wrapper jars tracked \.+ 0$'
    has "…and the answer tracks exactly one" '^  wrapper jars tracked \.+ 1$'
    has "…with 0 target/ paths either way" '^  target/ paths tracked \.+ 0$'
    not_pinned "…./receipts.sh 2>&1 | md5 -q -> $(receipts_md5 24), against the 1005857d715575fdfec065487b369d1a the deck quotes" \
        "the whole-run hash contains the two snapshot blocks above, so it moves with the repository; the deck's figure is over a different subset (the seven blocks that run anywhere, plus clean)"
  fi

  # ---- the exercise, both halves, read out of the two files it ships
  is "exercise/gitignore.broken is the two-line rule: *.jar and target/" \
     "$(grep -vE '^\s*(#|$)' "$REPO/c3-unit24/exercise/gitignore.broken" | tr '\n' ' ')" "*.jar target/ "
  is "…and the answer does not write a *.jar rule at all, which is what its own comments say the rule is" \
     "$(grep -vE '^\s*(#|$)' "$REPO/c3-unit24/exercise/solution/.gitignore" | grep -c '^\*\.jar' | tr -d ' ')" "0"
  # …and where it DOES discuss the two-line form, the order is the one that works. A `!` line
  # cannot rescue a file inside an ignored directory, so the order is the whole content of the
  # advice, and a page that printed it the other way round would be teaching a no-op.
  is "…and where it explains the two-line form, *.jar comes BEFORE the ! that rescues the wrapper" \
     "$(grep -nE '^#? *(\*\.jar|!gradle/wrapper/gradle-wrapper\.jar)$' "$REPO/c3-unit24/exercise/solution/.gitignore" \
        | sed -E 's/:.*(\*\.jar|!gradle.*)$/ \1/' | awk '{print $2}' | tr '\n' ' ')" "*.jar !gradle/wrapper/gradle-wrapper.jar "
  is "…and templates/java.gitignore is the same file the answer is" \
     "$(cmp -s "$REPO/c3-unit24/templates/java.gitignore" "$REPO/c3-unit24/exercise/solution/.gitignore" && echo identical || echo differs)" "identical"
  fi
fi

# ============================================================= c3-unit25 ====
# A CI unit with NO RUN LOG, which is the honest version and is the thing to hold it to. There
# is no `.github/workflows/` in this repository — on purpose, because a workflow there runs on
# every push and spends real minutes — so `gh run list` has nothing to list. Three assertions
# follow from that and nothing else in this script makes them: that the directory really is
# absent, that `gh` really does list nothing, and that the unit's own capture of that state is
# what its page prints. What it DOES have is every command the workflow runs, run here, on two
# real JDKs, and the bug that makes the exercise worth doing: a green build whose artifact
# cannot start.
if unit 25 "CI in 20 minutes: GitHub Actions"; then
  is "README quotes the five carried sources' hash, and it is the course's own" \
     "$(src_hash5 "$REPO/c3-unit25/src/main/java/com/tiffinbox")" "$(carried_five_hash 25)"
  is "…and the README's block table names exactly the ids receipts.sh declares" \
     "$(readme_block_ids 25)" "$(receipts_ids 25)"

  # ---- THE claim about the absent. Both halves, measured.
  absent "there is no .github/workflows/ in this repository, which is why this unit has no run log" \
      "$REPO/.github/workflows"
  is "…and the taught workflow lives at c3-unit25/workflows/build.yml instead, where nothing runs it" \
     "$( [ -f "$REPO/c3-unit25/workflows/build.yml" ] && echo there || echo missing )" "there"
  if command -v gh >/dev/null 2>&1; then
    timed 300 bash -c 'gh run list --limit 100 2>/dev/null; true'
    is "…and gh run list --limit 100 returns NOTHING, asked of this machine rather than assumed" \
       "$(grep -c . "$OUT" | tr -d ' ')" "0"
  else
    skip "gh run list --limit 100 -> 0 runs" "there is no gh on this machine to ask"
  fi

  # ---- every command the workflow runs, run here. The parser first, because "it looks right"
  # is not a check — and the `on:` key is the finding only a parser makes.
  if ! command -v ruby >/dev/null 2>&1; then
    skip "the workflow, handed to a YAML parser" "no ruby on this machine; the unit's own receipts.sh dies without it"
  else
    timed 300 bash -c 'cd "$REPO/c3-unit25" && ruby -ryaml -rjson -e "
      d = YAML.safe_load(File.read(ARGV[0]), aliases: true)
      puts((d.key?(\"on\") ? \"string\" : (d.key?(true) ? \"boolean\" : \"absent\")))
      puts d[\"jobs\"].keys.length
      puts d[\"jobs\"][\"build\"][\"strategy\"][\"matrix\"][\"java\"].join(\",\")
      puts d[\"jobs\"][\"build\"][\"strategy\"][\"fail-fast\"]
      puts d[\"permissions\"][\"contents\"]
      puts d[\"jobs\"][\"release\"][\"permissions\"][\"contents\"]
    " workflows/build.yml'
    if [ "$RC" -eq 0 ]; then
      is "workflows/build.yml parses, and the top-level \`on:\` key is the BOOLEAN true to a YAML 1.1 parser" \
         "$(sed -n '1p' "$OUT")" "boolean"
      is "…two jobs"                          "$(sed -n '2p' "$OUT")" "2"
      is "…a matrix of 25 and one newer"      "$(sed -n '3p' "$OUT")" "25,26"
      is "…fail-fast false, so a red 26 cannot hide a green 25" "$(sed -n '4p' "$OUT")" "false"
      is "…contents: read at the top level"   "$(sed -n '5p' "$OUT")" "read"
      is "…and contents: write only in the release job" "$(sed -n '6p' "$OUT")" "write"
    else
      bad "workflows/build.yml, handed to a YAML parser" "ruby could not read it: exit $RC"
    fi
    # the secret half. Exactly one reference, and it is the token GitHub provides.
    is "…exactly ONE secret reference in the whole file" \
       "$(grep -cE '\$\{\{ *secrets\.' "$REPO/c3-unit25/workflows/build.yml" | tr -d ' ')" "1"
    is "…and it is secrets.GITHUB_TOKEN, with nothing typed, echoed or committed" \
       "$(grep -oE '\$\{\{ *secrets\.[A-Za-z_]+' "$REPO/c3-unit25/workflows/build.yml" | grep -vc 'secrets.GITHUB_TOKEN' | tr -d ' ')" "0"
    is "…and no action is pinned to a branch or to @main" \
       "$(grep -cE 'uses: .*@(main|master)$' "$REPO/c3-unit25/workflows/build.yml" | tr -d ' ')" "0"
  fi

  # ---- the bug, and the three places the same classes give two answers. (b) needs nothing at
  # all — a zip entry name is an exact byte string — so the jar of a green build is the evidence.
  expect_ok "mvn -B -ntp clean package -> BUILD SUCCESS, Tests run: 2" 1800 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit25" && mvn -B -ntp "-Dmaven.repo.local=$M2_U25" clean package'
  has "…Tests run: 2, Failures: 0" 'Tests run: 2, Failures: 0, Errors: 0, Skipped: 0'
  is "…and the file on disk is Menu.json while the code asks for /menu.json — the two spellings do NOT agree" \
     "$(ls "$REPO/c3-unit25/src/main/resources" | head -1)::$(grep -oE 'RESOURCE = "[^"]+"' "$REPO/c3-unit25/src/main/java/com/tiffinbox/ci/MenuLoader.java" | grep -oE '/[^"]+')" \
     "Menu.json::/menu.json"
  expect_ok "(a) java -cp target/classes …MenuLoader -> ok, exit 0 on this case-insensitive volume" 300 \
      '^ok$' bash -c 'cd "$REPO/c3-unit25" && "$JAVA" "-D$TAG=u25" -cp target/classes com.tiffinbox.ci.MenuLoader'
  has "…meal types declared: 3" '^meal types declared: 3$'
  expect_fail "(b) java -cp target/tiffinbox-core-1.0.0.jar …MenuLoader -> exit 1, from the SAME build" 300 \
      'java\.io\.IOException: menu resource not found on the classpath: /menu\.json' \
      bash -c 'cd "$REPO/c3-unit25" && "$JAVA" "-D$TAG=u25" -cp target/tiffinbox-core-1.0.0.jar com.tiffinbox.ci.MenuLoader'
  is "…and the jar really carries the capital M, which is why (b) needs no Linux runner at all" \
     "$(unzip -l "$REPO/c3-unit25/target/tiffinbox-core-1.0.0.jar" 2>/dev/null | grep -cE ' Menu\.json$' | tr -d ' ')" "1"
  is "…and no entry named menu.json" \
     "$(unzip -l "$REPO/c3-unit25/target/tiffinbox-core-1.0.0.jar" 2>/dev/null | grep -cE ' menu\.json$' | tr -d ' ')" "0"

  # ---- EVERY COMMAND THE SHIPPED WORKFLOW RUNS, RUN HERE. The set of them is read out of the
  # YAML first, so a command added to that file later cannot slip past this script unrun — the
  # whole reason this unit exists is that it has no run log, and "we ran the commands" has to
  # mean all of them.
  if command -v ruby >/dev/null 2>&1; then
    timed 300 bash -c 'cd "$REPO/c3-unit25" && ruby -ryaml -e "
      d = YAML.safe_load(File.read(ARGV[0]), aliases: true)
      d[\"jobs\"].each_value { |j| j[\"steps\"].each { |st| next unless st[\"run\"]
        puts st[\"run\"].strip.gsub(/\\s+/, \" \") } }
    " workflows/build.yml'
    is "the shipped workflow runs FOUR shell commands across its two jobs, read out of the YAML" \
       "$(grep -c . "$OUT" | tr -d ' ')" "4"
    has "…the build job's own goal"       '^mvn -B -ntp verify$'
    has "…the step that proves the jar RUNS, which a green verify does not" \
        '^java -cp target/tiffinbox-core-1\.0\.0\.jar com\.tiffinbox\.ci\.MenuLoader$'
    has "…the release job's build"        '^mvn -B -ntp -DskipTests package$'
    has "…and the one that publishes"     '^gh release create '
  else
    skip "the four shell commands the workflow runs, read out of the YAML" "no ruby on this machine to parse it"
  fi
  # three of the four run here. The fourth is the one command this unit must NOT run.
  expect_ok "the release job's own build: mvn -B -ntp -DskipTests package" 1800 'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit25" && mvn -B -ntp "-Dmaven.repo.local=$M2_U25" -DskipTests package'
  exists "…and it produced the jar that job would attach to a release" \
      "$REPO/c3-unit25/target/tiffinbox-core-1.0.0.jar"
  skip "gh release create \"\${GITHUB_REF_NAME}\" … (the fourth command)" \
       "it creates a public GitHub release from a tag that does not exist, so it is the one command in this workflow nothing here may run — and saying so is the point of this unit: there is no run log because no run happened"

  # ---- the matrix, both legs, for real. The unit's own receipts.sh dies rather than fake one.
  if [ ! -x "$JDK26/bin/java" ]; then
    skip "the matrix, both legs" "no JDK 26 at $JDK26 — set JDK26= to one; this unit's receipts.sh refuses to fake the second leg"
  else
    is "…and the two legs really are two different JDKs" \
       "$( [ "$("$JAVA" -version 2>&1 | head -1)" != "$("$JDK26/bin/java" -version 2>&1 | head -1)" ] && echo different || echo "the same" )" "different"
    expect_ok "the workflow's own goal on JDK 26: mvn -B -ntp verify" 1800 'BUILD SUCCESS' \
        bash -c 'cd "$REPO/c3-unit25" && JAVA_HOME="$JDK26" PATH="$JDK26/bin:$PATH" mvn -B -ntp "-Dmaven.repo.local=$M2_U25" clean verify'
    has "…Tests run: 2 on the second leg too" 'Tests run: 2, Failures: 0, Errors: 0, Skipped: 0'
  fi

  # ---- receipts.sh: seven blocks, and the six hashes the deck (25-ci-github-actions.md) quotes
  if run_receipts 25 5400; then
    is "…and it printed seven blocks, the count the deck states" "$(receipts_blocks 25)" "7"
    is "…./receipts.sh 2>&1 | md5 -q -> the whole-run md5 the deck quotes for the seven" \
       "$(receipts_md5 25)" "4378493339b4f4f9af56619581858978"
    receipt_line 25 workflow "md5 6db539edc2d9b2b049df2e00fe65b410  (exit 0)"
    receipt_line 25 actions  "md5 a8dad56f75289a2d61dc5af9604f2f29  (no build, no network)"
    receipt_line 25 matrix   "md5 4aa7477c08e61a47d1588015f9c82976  (exit 0, 0)"
    receipt_line 25 casebug  "md5 9ffcb073395d6aa61c1a7dd2f06372d9  (exit 0, 1, 1)"
    receipt_line 25 solution "md5 e69c361aad41443e39996c97bcac9f65  (exit 1 then 0)"
    receipt_line 25 offline  "md5 a7fb8c2eec158bb6d5dfc5cf6121d7e1  (exit 0)"
    derived_unprobed 25

    # `norun` is the block whose hash is a fact about the MACHINE, and a DEFECT worth naming:
    # the three yes/no answers are written into .r-norun.out and therefore ARE inside the hash,
    # while the line under it says "NOT hashed". So the deck's figure only reproduces where gh
    # is installed, authenticated and has nothing to list — and that is asserted, not assumed.
    receipt_panel 25 norun
    if grep -q '^  gh installed \.* yes$' "$OUT" && grep -q '^  gh authenticated \.* yes$' "$OUT" \
       && grep -q '^  \.github/workflows/ present in this repo \.* no$' "$OUT" \
       && grep -q '^  workflow runs gh can list \.* 0$' "$OUT"; then
      receipt_line 25 norun "md5 e7a2b6da17c47446e407223f46cae30f  (no run to have an exit code)"
    else
      skip "…receipts.sh norun -> md5 $(receipt_hash_of 25 norun), the hash the deck quotes as e7a2b6da17c47446e407223f46cae30f" \
           "that block writes this machine's gh answers INTO the file it hashes (while the line under it says they are not hashed), and this machine answers differently — so the figure is not this run's to check. The two claims that are the unit's own are asserted above: no .github/workflows/ here, and nothing for gh to list"
    fi
    has "…and the block says out loud that there is no run log and this unit does not have one" \
        '^So there is no run log, and this unit does not have one\.$'
    has "…naming what would produce one" '^  \$ gh run list --limit 1$'

    receipt_panel 25 workflow
    panel 25 '^## The workflow, checked by a parser' 1
    out_has_lines "…README's parser panel is what ruby really answered about that file"
    # the finding only a parser makes. The page prints that one JSON member on its own, so what
    # is compared is the member itself — the block has it four columns in and with a comma after.
    has "…including the finding only a parser makes: the \`on:\` key is the BOOLEAN true" \
        '"on_key_read_as": "the BOOLEAN true \(YAML 1\.1\)"'
    readme_quotes "…and that is the line c3-unit25/README.md prints" 25 \
        '"on_key_read_as": "the BOOLEAN true (YAML 1.1)"'
    receipt_panel 25 actions
    panel 25 '^## Pins, and what a pin is worth' 1
    panel_indent 2
    out_has_panel "…README's pin table is derived from central/ with no network, actions/cache included"
    has "…and actions/cache is in the header comment and in NO step, which the block says out loud" \
        'actions/cache +NOT USED in this workflow'
    # the Adoptium answer lives in `actions`, not in `matrix`, though the page prints the two
    # panels one under the other — so it is compared against the block that really made it.
    panel 25 '^## The matrix, run here' 2
    out_has_lines_lax "…and the Adoptium answer that makes the matrix 25-plus-one, read from central/"
    receipt_panel 25 matrix
    panel 25 '^## The matrix, run here' 1
    out_has_lines_lax "…README's matrix panel is two real JDKs, both green, with fail-fast false"
    receipt_panel 25 casebug
    panel 25 '^## The bug' 1
    panel_indent 2
    out_has_panel "…README's build panel: Tests run: 2 and exit 0, over a jar that cannot start"
    has "…three states run, two of them failed" '^states run: 3 ; states that failed: 2$'
    has "…and the build that produced all three said BUILD SUCCESS once" \
        '^and the build that produced all of them said BUILD SUCCESS: 1$'
    has "…state (c) is a case-sensitive volume made here in one command, no privileges and no network" \
        '^\(c\) the SAME classes, on a case-sensitive volume made here in one command:$'
    receipt_panel 25 solution
    has "…the exercise's start state exits 1 from the shipped jar" '^  exit 1$'
    has "…the answer exits 0" '^  exit 0$'
    has "…with 0 Java files changed — the answer is the rename, not the code" \
        '^Java files that differ between the two trees: 0$'
    has "…and the answered jar carries an entry named menu.json" \
        '^entries in the answered jar whose name is menu\.json: 1$'
  fi
  # …and the answer's own second half, which is the trap one layer down: `git mv` on a
  # case-insensitive filesystem can be a no-op while git keeps the old name.
  is "exercise/solution/fix.txt names the rename, and the git mv trap under it" \
     "$(grep -c 'git mv src/main/resources/Menu\.json src/main/resources/menu\.json\.tmp' "$REPO/c3-unit25/exercise/solution/fix.txt" | tr -d ' ')" "1"
  is "…and the durable fix, which is neither half: one test that loads every resource FROM THE JAR" \
     "$(grep -c 'run from the JAR rather than from target/classes' "$REPO/c3-unit25/exercise/solution/fix.txt" | tr -d ' ')" "1"
fi

# ============================================================= c3-unit26 ====
# Static analysis, and the thing it keeps proving five different ways: a tool that is CONFIGURED
# is not a tool that is RUNNING, and a tool that is running is not a tool that can STOP you. So
# no assertion here is `BUILD SUCCESS`: each beat names the artifact that separates the three
# states — a warning line, an exit code, a changed file. Two of the three defects it finds are
# in the five sources this course has carried since the Gradle section, and it does not touch
# them, which is why the carried hash has to be the same before and after.
if unit 26 "Static analysis: Spotless, Checkstyle, Error Prone"; then
  is "README quotes the five carried sources' hash, and it is the course's own" \
     "$(src_hash5 "$REPO/c3-unit26/src/main/java/com/tiffinbox")" "$(carried_five_hash 26)"
  is "…and the README's block table names exactly the ids receipts.sh declares" \
     "$(readme_block_ids 26)" "$(receipts_ids 26)"

  # ---- ten flags, or Error Prone does not run at all. The break ships an EMPTY .mvn/jvm.config
  # rather than none, because Maven finds .mvn by walking UP and would otherwise inherit this
  # unit's ten flags and pass — and a break that passes is not a break.
  is ".mvn/jvm.config is ten lines: eight --add-exports and two --add-opens" \
     "$(grep -c . "$REPO/c3-unit26/.mvn/jvm.config" | tr -d ' ')-$(grep -c '^--add-exports' "$REPO/c3-unit26/.mvn/jvm.config" | tr -d ' ')-$(grep -c '^--add-opens' "$REPO/c3-unit26/.mvn/jvm.config" | tr -d ' ')" \
     "10-8-2"
  exists "…and breaks/no-jvm-config ships an EMPTY .mvn/jvm.config rather than none" \
      "$REPO/c3-unit26/breaks/no-jvm-config/.mvn/jvm.config"
  is "…empty, so the break cannot inherit this unit's flags by Maven walking up" \
     "$(wc -c < "$REPO/c3-unit26/breaks/no-jvm-config/.mvn/jvm.config" | tr -d ' ')" "0"
  expect_fail "breaks/no-jvm-config: mvn -B -ntp clean compile -> exit 1, and Maven tells you nothing useful" 1800 \
      'IllegalAccessError' \
      bash -c 'cd "$REPO/c3-unit26/breaks/no-jvm-config" && mvn -B -ntp "-Dmaven.repo.local=$M2_U26" clean compile'
  has "…jdk.compiler does not export com.sun.tools.javac.api to an unnamed module" \
      'module jdk\.compiler does not export com\.sun\.tools\.javac\.api'
  has "…and what Maven makes of that: An unknown compilation problem occurred" \
      '^\[ERROR\] An unknown compilation problem occurred'

  # ---- three findings, a green build, and a passing suite. BUILD SUCCESS is the thing being
  # warned about, so the assertion is the findings and the exit code together.
  expect_ok "mvn -B -ntp clean verify -> exit 0, with three real defects reported as WARNINGS" 1800 \
      'BUILD SUCCESS' \
      bash -c 'cd "$REPO/c3-unit26" && mvn -B -ntp "-Dmaven.repo.local=$M2_U26" clean verify'
  is "…three Error Prone findings" "$(countq '^\[WARNING\].*\.java:\[[0-9]+,[0-9]+\] \[[A-Za-z]+\]')" "3"
  is "…TWO of them in the code this course has carried since Course Two, which this unit does not touch" \
     "$(grep -E '^\[WARNING\].*\.java:\[[0-9]+,[0-9]+\] \[[A-Za-z]+\]' "$OUT" | grep -c '/com/tiffinbox/[A-Z]' | tr -d ' ')" "2"
  has "…and every test passed under them" 'Tests run: 3, Failures: 0, Errors: 0, Skipped: 0'

  # ---- the red build, and the finding that is correct about the syntax and wrong about the code
  expect_fail "mvn -B -ntp -Pstrict clean compile -> exit 1, on TWO files" 1800 \
      '\[ReferenceEquality\]' \
      bash -c 'cd "$REPO/c3-unit26" && mvn -B -ntp "-Dmaven.repo.local=$M2_U26" -Pstrict clean compile'
  # Maven prints each compilation ERROR twice — once where it happens and once in the failure
  # summary — so a bare grep -c answers 4 for two findings. Deduplicated on file:line:check.
  is "…TWO distinct findings, deduplicated: a bare grep -c answers 4 because Maven prints each one twice" \
     "$(grep -hE '^\[ERROR\].*\.java:\[[0-9]+,[0-9]+\] \[ReferenceEquality\]' "$OUT" | sed -E 's#^\[ERROR\] ##' | sort -u | wc -l | tr -d ' ')" "2"
  is "…and one of the two is a SENTINEL compared by identity, which is correct code: OrderQueue.java:30" \
     "$(sed -n '30p' "$REPO/c3-unit26/src/main/java/com/tiffinbox/OrderQueue.java" | sed 's/^ *//')" "if (o == CLOSED) {"
  is "…while the other compares a database string with a literal, which is a bug: MealPlan.java:30" \
     "$(sed -n '30p' "$REPO/c3-unit26/src/main/java/com/tiffinbox/quality/MealPlan.java" | sed 's/^ *//')" 'return c.mealType() == "VEGAN";'

  # ---- the flag that does nothing. Three runs of the same goal, and the middle one is the trap.
  expect_ok "mvn -B -ntp checkstyle:check -> exit 0 over four violations" 1800 '' \
      bash -c 'cd "$REPO/c3-unit26" && mvn -B -ntp "-Dmaven.repo.local=$M2_U26" checkstyle:check'
  is "…four of them, and all four in the carried Customer record" \
     "$(countq '^\[WARN\] .*\[JavadocType\]')" "4"
  expect_ok "mvn -B -ntp -Dcheckstyle.failOnViolation=true checkstyle:check -> STILL exit 0. That is the trap." 1800 \
      'violations detected but failOnViolation set to false' \
      bash -c 'cd "$REPO/c3-unit26" && mvn -B -ntp "-Dmaven.repo.local=$M2_U26" -Dcheckstyle.failOnViolation=true checkstyle:check'
  expect_fail "mvn -B -ntp -Dcheckstyle.fail=true checkstyle:check -> exit 1, because the pom left THAT switch reachable" 1800 \
      'You have [0-9]+ Checkstyle violation' \
      bash -c 'cd "$REPO/c3-unit26" && mvn -B -ntp "-Dmaven.repo.local=$M2_U26" -Dcheckstyle.fail=true checkstyle:check'
  is "…and the pom is why: it writes \${checkstyle.fail} into the element rather than a literal false" \
     "$(grep -c '<failOnViolation>\${checkstyle\.fail}</failOnViolation>' "$REPO/c3-unit26/pom.xml" | tr -d ' ')" "1"

  # ---- receipts.sh: eight blocks, and the eight hashes the deck (26-static-analysis.md) quotes
  if run_receipts 26 5400; then
    is "…and it printed eight blocks, the count the deck states" "$(receipts_blocks 26)" "8"
    is "…./receipts.sh 2>&1 | md5 -q -> the whole-run md5 the deck quotes for the eight" \
       "$(receipts_md5 26)" "a5b26959b285de3b523c28069480993b"
    receipt_line 26 jvmconfig  "md5 0797b831ffdb5cb7ca3eeaf9c428d72a  (exit 1 without, exit 0 with)"
    receipt_line 26 warnings   "md5 98f221916a06a7c4d56415b704749c4e  (exit 0)"
    receipt_line 26 strict     "md5 9a9bbaedf49445f6c2df86c63db56903  (exit 1)"
    receipt_line 26 nullaway   "md5 5d306eca649376e7b482d326856cc37b  (exit 1 configured, exit 1 misconfigured)"
    receipt_line 26 spotless   "md5 c66690f4a8a1564493d994bb79afbe17  (exit 1 then 0)"
    receipt_line 26 checkstyle "md5 cf8de0a2a1332a809d20e93b62b99d26  (exit 0, 0, 1)"
    receipt_line 26 solution   "md5 18636b3b782a46fe28ba8980533c8331  (exit 1 then 0)"
    receipt_line 26 offline    "md5 9193626e559859df6113227749428222  (exit 0)"
    derived_unprobed 26

    receipt_panel 26 jvmconfig
    panel 26 '^## Ten flags, or Error Prone' 3
    panel_indent 2
    out_has_panel "…README's jvm.config panel — ten lines, eight and two, exit 0 and three findings"
    receipt_panel 26 warnings
    panel 26 '^## Three findings' 1
    # the page truncates Error Prone's first message with an ellipsis, so that one line is
    # dropped and asserted on its own; the other two are quoted in full and are held to it.
    panel_drop_re 'FutureReturnValueIgnored'
    out_has_lines_lax "…README's findings panel is what Error Prone really reported"
    has "…including the FutureReturnValueIgnored the page abbreviates, at the line it names" \
        'OrderQueue\.java:\[27,28\] \[FutureReturnValueIgnored\]'
    has "…two in carried code, one in this unit's own" '^  in code carried from Course Two \.+ 2$'
    has "…and the build said BUILD SUCCESS once, which is the thing being warned about" \
        '^the build said BUILD SUCCESS \.+ 1 time\(s\)$'
    receipt_panel 26 strict
    panel 26 '^## The red build' 2
    panel_indent 2
    out_has_panel "…README's two flagged lines are read out of the sources, not retyped"
    has "…two promoted to ERROR, one a genuine defect and one correct code" '^of those, correct code \.+ 1$'
    receipt_panel 26 nullaway
    panel 26 '^## NullAway' 1
    out_has_lines_lax "…README's NullAway panel: one unboxing of a @Nullable expression, exit 1"
    has "…and 0 lines of Java were added to make it fire" \
        '^lines of Java the check needed \.+ 0   \(no annotations were added to make it fire\)$'
    has "…and the misconfiguration prints the SAME useless Maven sentence as the jvm.config failure" \
        '^    \[ERROR\] An unknown compilation problem occurred$'
    receipt_panel 26 spotless
    panel 26 '^## Spotless' 2
    panel_indent 2
    out_has_lines "…README's spotless panel: two files changed, three imports reordered, nothing else"
    has "…and it touched ZERO of the carried Course Two sources" \
        '^  carried Course Two sources it touched: 0$'
    receipt_panel 26 checkstyle
    panel 26 '^## Checkstyle' 1
    panel_indent 2
    out_has_panel "…README's three runs of the same goal, and the middle one that does nothing"
    has "…and all four violations are in code this unit did not write" \
        '^and every one of them is in code carried from Course Two: 4 of 4$'
    receipt_panel 26 solution
    has "…the exercise's start state is exit 1 with one NullAway error" '^  exit 1$'
    has "…and the answer is exit 0 with none" '^  distinct NullAway errors now \.+ 0$'
    has "…and 0 ReferenceEquality errors under -Pstrict, one fixed and one suppressed with its reason" \
        '^  distinct ReferenceEquality errors now 0'
    has "…with the tests still green" '^  tests: Tests run: 3, Failures: 0, Errors: 0, Skipped: 0$'
  fi
  # ---- and the shipped sources are still the shipped sources. spotless:apply RE-WRITES files;
  # the unit runs it in a copy for exactly that reason, and this is the receipt for that choice.
  is "…and after all eight blocks the five carried sources are byte-identical: spotless:apply ran in a copy" \
     "$(src_hash5 "$REPO/c3-unit26/src/main/java/com/tiffinbox")" "$(carried_five_hash 26)"
  is "…and MealPlan.java still carries the import order spotless would change, so the demonstration stays runnable" \
     "$(grep -m1 '^import ' "$REPO/c3-unit26/src/main/java/com/tiffinbox/quality/MealPlan.java")" \
     "import com.tiffinbox.Customer;"
  absent "…and the copy it used is gone" "$REPO/c3-unit26/.spot"
fi

# ============================================================= c3-unit27 ====
# THE unit that ships nothing. There is no GraalVM here, `native-image` is not on this PATH, and
# even with one the link step could not run: `cc`, `ld` and `xcrun` all answer **69** — the Xcode
# licence. So this section asserts three things nothing else in this script asserts.
#
#   1. The `native` profile's failure is the PLUGIN's own documented refusal, named by
#      coordinate and version — not a typo, not a missing dependency, not a stale pom.
#   2. `cc`, `ld` and `xcrun` really do exit 69, with the licence sentence, because that is the
#      SECOND and independent reason the page gives.
#   3. **No binary size, no start-up time and no throughput figure appears anywhere on that
#      page.** That is the one claim in the unit no hash can protect: every capture it takes is
#      of something that ran, so a fabricated "12 MB, 8 ms" in the prose would move nothing at
#      all. `readme_hasnt` is the only assertion that can see it.
if unit 27 "GraalVM native image" ; then
  is "README quotes the five carried sources' hash, and it is the course's own" \
     "$(src_hash5 "$REPO/c3-unit27/src/main/java/com/tiffinbox")" "$(carried_five_hash 27)"
  is "…and the README's block table names exactly the ids receipts.sh declares" \
     "$(readme_block_ids 27)" "$(receipts_ids 27)"

  # ---- 1. the absent toolchain, and the plugin's own words
  is "native-image is NOT on this PATH, which is the unit's whole framing" \
     "$(command -v native-image >/dev/null 2>&1 && echo present || echo absent)" "absent"
  is "…and GRAALVM_HOME is unset" "${GRAALVM_HOME:-<unset>}" "<unset>"
  is "…and there is no GraalVM JDK installed anywhere this unit looks" \
     "$(ls -d /Library/Java/JavaVirtualMachines/*graal* "$HOME"/Library/Java/JavaVirtualMachines/*graal* /opt/homebrew/opt/*graal* 2>/dev/null | wc -l | tr -d ' ')" "0"
  expect_fail "mvn -B -ntp -Pnative package -> exit 1, and it is the PLUGIN's own refusal" 1800 \
      'org\.graalvm\.buildtools:native-maven-plugin:1\.1\.13:compile-no-fork' \
      bash -c 'cd "$REPO/c3-unit27" && mvn -B -ntp "-Dmaven.repo.local=$M2_U27" -Pnative package'
  has "…in the plugin's own sentence: native-image is not installed in your JAVA_HOME" \
      'native-image is not installed in your'
  has "…naming the JDK it was handed, which is why a viewer with GraalVM runs this profile unchanged" \
      'is not a GraalVM distribution'
  is "…and the profile really pins 1.1.13, the newest in its own version list" \
     "$(grep -A2 'native-maven-plugin' "$REPO/c3-unit27/pom.xml" | grep -oE '<version>[^<]*' | sed 's/<version>//' | head -1)" \
     "$(grep -o '<version>[^<]*' "$REPO/c3-unit27/central/native-maven-plugin-maven-metadata.xml" | sed 's/<version>//' | tail -1)"

  # ---- 2. the linker. native-image shells out to it for its last step, and it answers 69.
  printf 'int main(void){return 0;}\n' > "$WORK/u27.c"
  expect_rc "cc <a two-line C file> -o <binary> -> exit 69" 120 69 \
      'You have not agreed to the Xcode license agreements' \
      bash -c "cc \"$WORK/u27.c\" -o \"$WORK/u27.bin\""
  expect_rc "/usr/bin/ld -v -> exit 69, the same sentence" 120 69 \
      'You have not agreed to the Xcode license agreements' /usr/bin/ld -v
  expect_rc "xcrun -f cc -> exit 69 as well, which is the third of the three the README names" 120 69 \
      'You have not agreed to the Xcode license agreements' xcrun -f cc
  rm -f "$WORK/u27.c" "$WORK/u27.bin"

  # ---- 3. THE assertion that keeps that page honest. Three shapes of number, none of them
  # measurable here, none of them on the page. (The 16 GB in the verification header is the
  # machine, and the 339188208 bytes is the GraalVM DOWNLOAD read out of central/ — neither is
  # a property of a binary that does not exist, so both are excluded by anchoring on the noun.)
  readme_hasnt "c3-unit27/README.md quotes no BINARY size — there is no binary here to have one" 27 \
      '(binar(y|ies)|executable|image)[^.]{0,60}[0-9]+([.,][0-9]+)? *(MB|KB|GB|MiB|KiB|GiB)|[0-9]+([.,][0-9]+)? *(MB|KB|GB|MiB|KiB|GiB)[^.]{0,40}(binar(y|ies)|executable)'
  readme_hasnt "…and no start-up time: not one millisecond, microsecond or nanosecond figure on the page" 27 \
      '[0-9]+([.,][0-9]+)? *(ms|milliseconds?|µs|us|nanoseconds?|ns)\b'
  readme_hasnt "…and no throughput figure either" 27 \
      '(ops|requests?|req)/s|[0-9]+ *(ops|rps|qps)\b|throughput of'
  xreadme_hasnt "…nor on its exercise page" 27 \
      '[0-9]+([.,][0-9]+)? *(MB|KB|GB|ms|µs|us|ns)\b'
  readme_quotes "…and the page says so itself, in one sentence" 27 \
      "**So there is no native binary in this unit, no binary file size, and no start-up time.**"

  # ---- what DOES run here: the closed-world problem, measured with the JDK's own tool
  is "formatters.properties names two implementation classes" \
     "$(grep -c '^[a-z]*=com\.tiffinbox\.aot\.' "$REPO/c3-unit27/src/main/resources/formatters.properties" | tr -d ' ')" "2"
  is "…and ZERO Java source files outside the classes themselves name either one — that is the closed world, in one number" \
     "$(grep -rlE 'PlainFormatter|LedgerFormatter' "$REPO/c3-unit27/src/main/java" --include='*.java' \
        | grep -vE '(PlainFormatter|LedgerFormatter)\.java$' | wc -l | tr -d ' ')" "0"
  is "…and the reachability metadata ships at the path a closed-world build looks in" \
     "$( [ -f "$REPO/c3-unit27/src/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-core/reflect-config.json" ] \
        && [ -f "$REPO/c3-unit27/src/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-core/resource-config.json" ] \
        && echo both || echo missing )" "both"
  # the half people forget, and the reason the page gives for it: a resource is not carried
  # either, and the failure is one line EARLIER with a message about a null stream.
  # …and the resource half, checked as a REGEX rather than as a string. That file spells the
  # pattern `formatters\\.properties`, so a grep for the file name does not find it — and a grep
  # for the escaped form would pass over a pattern that no longer matched anything.
  is "…and resource-config.json's include pattern really MATCHES formatters.properties, which is the half people forget" \
     "$(python3 -c "
import json,re
d=json.load(open('$REPO/c3-unit27/src/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-core/resource-config.json'))
print(sum(1 for i in d['resources']['includes'] if re.fullmatch(i['pattern'], 'formatters.properties')))")" "1"

  # ---- receipts.sh: seven blocks, and the six hashes the deck (27-graalvm-native-image.md)
  # quotes. The deck says in so many words that there is NO whole-script hash for this unit and
  # that the blocks say why themselves — and that is asserted rather than worked around.
  if run_receipts 27 5400; then
    is "…and it printed seven blocks, the count the README's table states" "$(receipts_blocks 27)" "7"
    receipt_line 27 closedworld  "md5 8b369d156ae270ca70df59514b19b5e0  (exit 0)"
    receipt_line 27 aot          "md5 f4dd3ce4630f795b0476fc625adc11fa  (exit 0 / 0 / 0 / 0)"
    receipt_line 27 jlink        "md5 293e584d48412834224ffd8f9321b846  (exit 0 full, exit 1 trimmed)"
    receipt_line 27 graalvm      "md5 979c016353f3cb84197afd46bb610803  (exit 1 from mvn -Pnative, 69 from cc, 69 from ld)"
    receipt_line 27 nativeconfig "md5 7c9ad3b1cf4bee7278bc9c9b3960ca99  (no build)"
    receipt_line 27 solution     "md5 fe2edae3b575cd2d6074996d18db686e  (no build - the answer is data, and this machine cannot run the build that consumes it)"
    derived_unprobed 27
    # THE reason there is no whole-script hash: three blocks print a byte size OUTSIDE the hash,
    # with the reason on screen. A block that started hashing one would reproduce exactly once.
    is "…and TWO blocks printed a \`no md5:\` line for their byte sizes, which is part of why this unit has no whole-script hash" \
       "$(unhashed_blocks 27)" "2"
    # …and the deck says there is no whole-script hash for this unit. A run's md5 taken anyway
    # would be a number nobody can reproduce, because those two lines carry an AOT cache size
    # and two image sizes. So it is named here rather than quietly omitted.
    not_pinned "…./receipts.sh 2>&1 | md5 -q -> $(receipts_md5 27)" \
        "two of the seven blocks print a byte size outside their hash, so the whole-run number moves with the JDK build and the compression level; the deck quotes none for this unit and says the blocks say why themselves"
    receipts_says 27 "…the AOT block says its three sizes go on a slide only after they have repeated" \
        '^no md5: the three sizes below are bytes'
    receipts_says 27 "…and the jlink block says image sizes move with the compression level and the JDK build" \
        '^no md5: image sizes vary with the compression level'

    receipt_panel 27 graalvm
    has "…receipts.sh graalvm: native-image on PATH ... no" '^  native-image on PATH \.+ no$'
    has "…GRAALVM_HOME unset" '^  GRAALVM_HOME \.+ <unset>$'
    has "…0 GraalVM JDKs installed" '^  GraalVM JDKs installed \.+ 0$'
    has "…exit 69 from cc" '^    exit 69$'
    has "…and the GraalVM CE release and asset are read out of central/ with no network" \
        '^  GraalVM CE release \.+ graal-'
    panel 27 '^## Read this first' 2
    panel_indent 2
    out_has_panel "…and README's pinned-and-shipped panel is what that block derived from central/"
    receipt_panel 27 closedworld
    panel 27 '^## The one line no compiler can follow' 3
    out_has_lines_lax "…README's jdeps panel — 0 edges into either formatter — is that block's own"
    has "…and jdeps' own module answer includes java.sql, because it reads the ARCHIVE and not the reachable graph" \
        'jdeps --print-module-deps over the whole jar \.+ .*java\.sql'
    receipt_panel 27 aot
    panel 27 '^## The AOT path, counted rather than timed' 1
    out_has_lines_lax "…README's step-0 panel: the recorder refuses an exploded directory"
    panel 27 '^## The AOT path, counted rather than timed' 3
    # the page drops the `file:` scheme the class loader really printed, so that one line is
    # dropped here and asserted in full on its own two lines below.
    panel_drop_re 'LedgerFormatter loaded from'
    out_has_lines_lax "…and its step-4 panel, which is the beat the unit exists for"
    has "…the training run only ever exercised plain, so LedgerFormatter came out of the JAR" \
        '^  LedgerFormatter loaded from \.+ file:<project>/target/tiffinbox-core-1\.0\.0\.jar$'
    has "…while PlainFormatter came out of the cache, even on the ledger run" \
        '^  PlainFormatter  loaded from \.+ shared objects file$'
    # and the ARITHMETIC of the AOT beat, which is a count and not a duration: almost every
    # class came out of a file instead of out of a jar, and the JIT path used no cache at all.
    U27T="$(grep -m1 -E '^  classes loaded \.+ [0-9]+$' "$OUT" | grep -oE '[0-9]+$')"
    is "…over a program that really loads a JDK's worth of classes, so the cache count is not a count of nothing" \
       "$( [ -n "$U27T" ] && [ "$U27T" -gt 1500 ] && echo "more than 1500" || echo "only $U27T" )" "more than 1500"
    is "…and the JIT path loaded ZERO classes from a cache, which is what makes the AOT count mean something" \
       "$(grep -m1 -E '^  of those, out of a cache \.+ [0-9]+$' "$OUT" | grep -oE '[0-9]+$')" "0"
    is "…while the AOT path loaded all but six of its classes out of the cache" \
       "$(grep -m1 -E '^  loaded from somewhere else \.+ [0-9]+$' "$OUT" | grep -oE '[0-9]+$')" "6"
    receipt_panel 27 jlink
    panel 27 '^## A closed world you can build here' 1
    out_has_lines_lax "…README's jlink panel: 69 modules in the JDK, 5 in the full image, 1 in the trimmed one"
    has "…and the trimmed image dies at start-up on java/sql/DriverManager, nothing recompiled" \
        'NoClassDefFoundError: java/sql/DriverManager'
    receipt_panel 27 nativeconfig
    has "…receipts.sh nativeconfig: three entries, two formatter classes, both covered" \
        '^of those, covered by reflect-config\.json \.+ 2$'
    has "…and both files parsed rather than eyeballed" '^valid JSON \(parsed, not eyeballed\) \.+ both files$'
    receipt_panel 27 solution
    has "…the exercise's start state covers ONE of the two formatter classes" '^  of those, covered \.+ 1$'
    has "…the answer covers both" '^  of 2 formatter classes, covered \.+ 2$'
    has "…with 0 lines of Java changed, because the fix is DATA" '^  lines of Java changed \.+ 0$'
    has "…and the block says so: the answer is data, and this machine cannot run the build that consumes it" \
        'That is eight lines of Python, it runs in CI, and it costs no minutes\.'
  fi
fi

# ============================================================= c3-unit28 ====
# The finale, and the last unit of the course. Two of its four blocks are deliberately NOT
# pinned and both say so in their own output: `gaps` is a find(1) census of a repository that
# grows, and `ship`'s AOT class count moves run to run (2070 · 2071 · 2070 measured here). So
# for both the STRUCTURE and the DERIVED ARITHMETIC are asserted — the four-holes ledger reading
# 4 named / 3 closed / 1 handed on, six steps and seven captured exit codes — and the figures
# themselves get a labelled SKIP naming what went unchecked.
#
# **There is no exercise in this unit, by design**, and that is asserted rather than assumed:
# every other unit in the course ships one, and a missing exercise directory would otherwise be
# indistinguishable from an oversight.
if unit 28 "What's next: the container, industrialised"; then
  is "README quotes the five carried sources' hash, and it is the course's own" \
     "$(src_hash5 "$REPO/c3-unit28/src/main/java/com/tiffinbox")" "$(carried_five_hash 28)"
  is "…and the README's block table names exactly the ids receipts.sh declares" \
     "$(readme_block_ids 28)" "$(receipts_ids 28)"
  absent "there is no exercise/ in this unit, and the page says the finale's task is the hand-off" \
      "$REPO/c3-unit28/exercise"
  readme_quotes "…in those words" 28 "**There is no exercise in this unit.**"
  # …and that absence is a decision rather than an omission: every OTHER c3 unit that ships one.
  is "…while all 27 of the other units do ship one" \
     "$(ls -d "$REPO"/c3-unit0[1-9]/exercise "$REPO"/c3-unit1[0-9]/exercise "$REPO"/c3-unit2[0-7]/exercise 2>/dev/null | wc -l | tr -d ' ')" "27"

  # ---- the counts, which are IMPORTED rather than typed. A finale that types its own unit
  # count is the failure mode of every roadmap video on the internet.
  if [ ! -s "$SERIES" ]; then
    skip "receipts.sh counts — the numbers imported from java3_series.py" \
         "no $SERIES on this machine, and this unit is forbidden to type its own counts"
  else
    is "receipts.sh imports its counts from java3_series.py rather than typing them" \
       "$(grep -c 'importlib.util.spec_from_file_location("java3_series"' "$REPO/c3-unit28/receipts.sh" | tr -d ' ')" "1"
    is "…and the module really declares 28 units across 5 sections, which is what the page says" \
       "$(python3 -c "
import importlib.util,sys
spec=importlib.util.spec_from_file_location('j','$SERIES'); m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
print(len(m.TITLES), len(m.SECTIONS))")" "28 5"
  fi

  # ---- the chain, run rather than claimed, and the wiring gap the course leaves open
  is "Wiring.java is the one gap: nothing in the project writes that startup order down" \
     "$(ls "$REPO/c3-unit28/src/main/java/com/tiffinbox/wiring" | tr '\n' ' ')" "Wiring.java "
  is "…and WiringOrderTest is the three tests that say out loud that the order is load-bearing" \
     "$(grep -cE '^[[:space:]]+void [a-zA-Z]+\(' "$REPO/c3-unit28/src/test/java/com/tiffinbox/WiringOrderTest.java" | tr -d ' ')" "3"
  is "…and there is no container spec, no compose file and no DI descriptor anywhere in Course 3 — the zero under hole 2 is a measurement" \
     "$(find "$REPO" -maxdepth 4 -path '*/c3-unit[0-9][0-9]/*' -not -path '*/target/*' -not -path '*/build/*' \
          \( -name 'Dockerfile' -o -name 'compose.yaml' -o -name 'docker-compose.yml' -o -name 'beans.xml' -o -name 'applicationContext*.xml' \) 2>/dev/null | wc -l | tr -d ' ')" "0"

  # ---- receipts.sh: five blocks, and the three hashes the deck (28-whats-next-the-container.md)
  # quotes as fixed. `gaps` and `ship` are the two it does not.
  if run_receipts 28 5400; then
    is "…and it printed five blocks, the count the README's table states" "$(receipts_blocks 28)" "5"
    receipt_line 28 counts  "md5 089c0e4b375d444e20044e387231958f  (no build)"
    receipt_line 28 wiring  "md5 44cb43bf1330236cc962d8d79192654c  (exit 0)"
    receipt_line 28 offline "md5 3d6831ca22fb5b3ec1ed0f1c3971d214  (exit 0)"
    derived_unprobed 28

    receipt_panel 28 counts
    panel 28 '^## Every count here is re-read' 1
    panel_indent 2
    out_has_panel "…README's counts panel is what importing java3_series.py really answered"
    has "…and the five sections account for every unit, asserted inside the block rather than typed" \
        '^  units accounted for by the five sections: 28$'

    # ---- gaps: the ledger is DERIVED from the four rows, and that arithmetic is the claim.
    # The md5 is not: every count in it is a find(1) over a repository that grows, and the block
    # prints that instruction itself. THE guard this unit shipped is NOTGEN — without it, running
    # c3-unit27/receipts.sh (which is exactly what this course tells the viewer to do) puts a
    # generated copy of reflect-config.json under target/ and the reachability count goes 2 -> 3,
    # taking the block's md5 with it. Units 19-27 have all just been built by this script, so
    # this run is the adverse condition, and the ledger has to be the same anyway.
    receipt_panel 28 gaps
    has "…receipts.sh gaps: four holes named" '^holes the last course named \.+ 4$'
    has "…three with an artifact behind them" '^holes with an artifact behind them \.+ 3$'
    has "…and ONE handed to the next course, which is hole 2" \
        '^holes handed to the next course \.+ 1   \(hole 2 - see the next block\)$'
    has "…hole 2's count is a zero that MOVES the day a container spec is added, not a rhetorical one" \
        '^     files that write that startup order down \.+ 0   <- the one still open$'
    has "…28 unit directories, 18 with a test tree, 22 with a receipts.sh" \
        '^     of those, carrying a src/test tree \.+ 18$'
    # THE NOTGEN receipt: this run has just built units 19-27, so target/ is full of generated
    # copies of exactly the files this census counts. The reachability count has to be 3 anyway.
    is "…and the NOTGEN guard held under the adverse condition this run creates: units 19-27 have just been BUILT, and the reachability count is still the shipped 3" \
       "$(grep -m1 -oE 'reachability metadata files shipped \.+ [0-9]+' "$OUT" | grep -oE '[0-9]+$')" "3"
    is "…and the logback count is still the shipped 7, for the same reason" \
       "$(grep -m1 -oE 'logback configurations shipped \.+ [0-9]+' "$OUT" | grep -oE '[0-9]+$')" "7"
    U28N="$(grep -oE "[-]not [-]path '[^']*'" "$REPO/c3-unit28/receipts.sh" | LC_ALL=C sort -u | tr '\n' ' ')"
    is "…and the five NOTGEN exclusions are all there: target, build, out, .gradle and .m2-demo" \
       "$U28N" "-not -path '*/.gradle/*' -not -path '*/.m2-demo/*' -not -path '*/build/*' -not -path '*/out/*' -not -path '*/target/*' "
    panel 28 '^## The four holes' 1
    # the page's last line points the reader at the `wiring` block by name where the block says
    # "the next block", so that one line is dropped and the number in it is asserted above.
    panel_drop_re '^holes handed to the next course'
    out_has_lines_lax "…and README's four-holes panel is what the census really printed"
    receipts_says 28 "…and the block says out loud that its md5 is a SNAPSHOT and is supposed to move" \
        'and that md5 is a SNAPSHOT, not a constant'
    not_pinned "…receipts.sh gaps -> md5 $(receipt_hash_of 28 gaps)" \
        "every count in it is a find(1) over this repository as it stands right now, so it moves the day a unit is added, renamed or removed — the ledger arithmetic above is asserted instead"

    # ---- ship: the chain, and the two numbers in it that move
    receipt_panel 28 wiring
    panel 28 '^## The one gap this course leaves' 1
    panel_indent 2
    out_has_panel "…README's wiring panel — 18 lines, 4 objects, 3 constants, 0 places the order is written"
    panel 28 '^## The one gap this course leaves' 2
    panel_indent 2
    out_has_panel "…and the three tests that are what '0 things check it' means"
    # …and those three tests CONSTRAIN what the wiring returns. Measured: weaken
    # theWiringAsWrittenWorks to `.isNotNull()` and nothing moves — the block reads the METHOD
    # NAMES out of the file, surefire still prints `Tests run: 3`, and the md5 is untouched,
    # because not one of them is a function of what the test asserts. So the thing the tests
    # watch is moved in a scratch copy and the count that notices is the claim.
    sensitive_to "…and WiringOrderTest CONSTRAINS the answer it names: add one to the customer count and 1 of the 3 notices" \
        28 "$M2_U28" src/main/java/com/tiffinbox/wiring/Wiring.java \
        '"customers=" + view.customers().size()' '"customers=" + (view.customers().size() + 1)' \
        "Tests run: 3, Failures: 1, Errors: 0, Skipped: 0"
    receipt_panel 28 ship
    has "…receipts.sh ship: six steps in the chain" '^steps in the chain \.+ 6$'
    has "…seven commands, because step 3 is two" '^commands those steps ran \.+ 7   \(step 3 is two\)$'
    has "…seven exit codes CAPTURED, not six booleans that were already guarded" '^exit codes captured \.+ 7$'
    has "…and seven of seven exited 0" '^commands that exited 0 \.+ 7$'
    has "…the jar and the 5-module runtime image printed the SAME answer" \
        '^the two runs printed the same answer: yes$'
    has "…out of 5 of this JDK's 69 modules" '^       5 of this JDK 69 modules$'
    # the AOT pair is the one figure in this unit that moves run to run, so what is asserted is
    # the ARITHMETIC — almost everything came out of the cache, and the cache is not bigger than
    # the run — and never the integers.
    U28T="$(grep -m1 -oE 'classes loaded [0-9]+, of those out of the cache [0-9]+' "$OUT" | grep -oE '[0-9]+' | head -1)"
    U28C="$(grep -m1 -oE 'classes loaded [0-9]+, of those out of the cache [0-9]+' "$OUT" | grep -oE '[0-9]+' | tail -1)"
    is "…and its AOT arithmetic holds: the cache served fewer classes than the run loaded, and more than two thousand of them" \
       "$( [ -n "$U28T" ] && [ "$U28C" -le "$U28T" ] && [ "$U28C" -gt 2000 ] && echo sound || echo "loaded=$U28T cached=$U28C" )" "sound"
    is "…and SEVEN \`exit 0\`s are on the panel itself, one per command — six at the end of a line and step 1's ahead of its Tests run:" \
       "$(grep -cE ' exit 0( |$)' "$OUT" | tr -d ' ')" "7"
    panel 28 '^## The chain, run' 1
    panel_drop_re 'classes loaded [0-9]+, of those out of the cache [0-9]+|Tests run: 3, Failures: 0, \.\.\.'
    out_has_lines_lax "…and the rest of README's chain panel — every step, every exit code, both answers — is what the run printed"
    # …and the one thing the panel cannot show: that step 6 ran in the IMAGE. Measured: point that
    # line at the JDK's own `java` instead of `.img/bin/java` and every number above is identical —
    # six steps, seven captured zeros, both answers the same — while the runtime image the whole
    # chain exists to build is never executed. So the chain's last command is read out of the
    # deliverable, and so is the module count beside it.
    is "…and step 6 really runs the program INSIDE the jlink image: the chain's last command is .img/bin/java, not the JDK again" \
       "$(sed -n '/^run_ship() {/,/^}$/p' "$REPO/c3-unit28/receipts.sh" \
          | grep -c '^  \.img/bin/java -cp "\$CP" "\$MAIN" > \.r-ship7\.raw' | tr -d ' ')" "1"
    is "…and the 5 on that panel is the IMAGE's module count, taken from the image's own java" \
       "$(sed -n '/^run_ship() {/,/^}$/p' "$REPO/c3-unit28/receipts.sh" \
          | grep -c 'mods=\$(\.img/bin/java --list-modules' | tr -d ' ')" "1"
    not_pinned "…receipts.sh ship -> md5 $(receipt_hash_of 28 ship)" \
        "the AOT class count inside it moves run to run (2070 · 2071 · 2070 measured here), so the deck quotes no figure for this block and neither does this script; the six steps, the seven captured exit codes and the two identical answers are asserted above"
    receipts_says 28 "…and the three sizes under it are printed OUTSIDE the hash, with the reason" \
        '^no md5: sizes, which move:'
    not_pinned "…./receipts.sh 2>&1 | md5 -q -> $(receipts_md5 28)" \
        "the whole-run hash contains both moving blocks above, so the deck quotes none for this unit either"
  fi
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
      "fingerprint $FP_BEFORE -> $FP_AFTER; git status: $(cd "$REPO" && git status --porcelain -- 'c3-unit*' c3-tiffinbox 2>/dev/null | head -5 | tr '\n' ' ')"
fi

# ------------------------------------------------------------------ report ---
printf '\n---------------------------------------------\n'
# Units that have landed since this script was last extended: say so instead of
# quietly passing, so nobody mistakes "not checked" for "checked and green". All 28
# of Course 3 are covered now, so this prints nothing — and the sentence under it is
# what the reader gets instead, because "no line at all" and "nothing uncovered" are
# not the same statement.
if [ ${#UNITS[@]} -eq 0 ]; then
  UNCHECKED=""
  for d in "$REPO"/c3-*/; do
    n="$(basename "$d")"
    case "$n" in
      c3-unit0[1-9]|c3-unit1[0-9]|c3-unit2[0-8]|c3-tiffinbox) continue ;;
      *) UNCHECKED="$UNCHECKED $n" ;;
    esac
  done
  if [ -n "$UNCHECKED" ]; then
    printf '%snot covered by this script yet:%s%s\n' "$YLW" "$OFF" "$UNCHECKED"
  else
    printf 'not covered by this script yet: nothing — c3-tiffinbox and all 28 units of Course 3 are covered.\n'
  fi
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
