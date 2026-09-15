#!/bin/bash
# receipts.sh - regenerate every number this unit puts on a slide.
#
#   ./receipts.sh            run every block
#   ./receipts.sh strict     run one block
#
# THE THING THIS UNIT KEEPS PROVING, IN FIVE DIFFERENT WAYS.
#
#   A tool that is configured is not a tool that is running, and a tool that is running is
#   not a tool that can stop you. Every block below separates those three states and names
#   the ARTIFACT that tells them apart - a warning line, an exit code, a changed file -
#   never the words BUILD SUCCESS.
#
#   Five measured hazards, and not one of them is folklore:
#     jvmconfig  Error Prone cannot run on JDK 25 without ten JVM flags, and Maven reports
#                the failure as "An unknown compilation problem occurred".
#     warnings   it then reports everything as a WARNING and the build exits 0.
#     strict     promoting one check to ERROR turns the build red - on TWO files, and one of
#                them is code that is arguably correct.
#     nullaway   NullAway with no AnnotatedPackages does not find nothing. It crashes, and
#                Maven prints the SAME useless sentence as the jvm.config failure.
#     checkstyle -Dcheckstyle.failOnViolation=true is silently ignored when the pom writes
#                that element out, so the gate you think you turned on is off.

set -u
set -o pipefail
cd "$(dirname "$0")" || exit 1

export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"

REPO="$PWD/.m2-demo"
MVN=(mvn -B -ntp -Dmaven.repo.local="$REPO")
UNIT="$PWD"

die() { printf '\nRECEIPT FAILED (%s): %s\n' "${BLOCK:-?}" "$1" >&2; exit 1; }
hash_of() { md5 -q "$1" 2>/dev/null || md5sum "$1" | cut -d' ' -f1; }
block() { BLOCK="${1%% *}"; printf '\n=== %s ===\n' "$1"; }

mask() { sed -E -e "s#${UNIT}/#<project>/#g" -e 's#[^ ]*/c3-unit26/#<project>/#g' \
                -e 's#/Users/[^/]*/#<home>/#g' \
                -e 's/unnamed module @0x[0-9a-f]+/unnamed module @<id>/g' \
                -e 's/, Time elapsed: [0-9.]+ s//' -e 's/ -- Time elapsed: [0-9.]+ s//'; }

# THE PATH THIS TREE LIVES IN CONTAINS A SPACE, and `[^ ]*` stops at it. A sed written as
# s#^\[WARNING\] [^ ]*/src/main/java/## therefore matches nothing here and leaves the whole
# absolute path on the line, which a later `cut` then turns into a panel of nothing but
# directory names. Every path strip below is greedy across spaces instead.
short() { sed -E -e 's#^\[(WARNING|ERROR|WARN)\] ##' -e 's#.*/src/(main|test)/java/##' -e 's/ \(see https:[^)]*\)//'; }

# Maven prints a compilation ERROR TWICE - once as it happens and once in the failure
# summary at the foot of the build. A `grep -c` over the log therefore double-counts every
# error and every count derived from it is wrong by a factor of two. Deduplicate on the
# file:line:check, which is what identifies a finding.
uniq_findings() {  # $1 = log, $2 = check name regex
  grep -hE "^\[ERROR\].*\.java:\[[0-9]+,[0-9]+\] \[$2\]" "$1" | sed -E 's#^\[ERROR\] ##' | sort -u
}


# EVERY CUT CARRIES ITS COUNT, AND THE COUNT IS DERIVED BY THE RUN THAT MADE THE CUT.
# Four debate gates in this course have been failed by a panel trimmed without one - most
# recently a thirty-row tree counted as twenty-nine, with the missing row hidden under an
# elision line that claimed to have cut something else. `trim` prints the first N lines of a
# capture and then states, from wc(1), exactly how many it did not print. A bare head is a
# contract breach; this is what replaces it.
trim() {  # $1 = file, $2 = lines to keep, $3 = optional extra sed program for the kept lines
  local f="$1" keep="$2" post="${3:-}"
  [ -s "$f" ] || die "trim: $f is missing or empty, so any elision count over it would be a lie"
  local total; total=$(wc -l < "$f" | tr -d ' ')
  if [ -n "$post" ]; then head -"$keep" "$f" | mask | sed -E "$post"; else head -"$keep" "$f" | mask; fi
  if [ "$total" -gt "$keep" ]; then printf '... %s more line(s) elided\n' "$(( total - keep ))"; fi
  return 0
}
# The same rule for a capture that is SELECTED by pattern rather than cut at a line number:
# say how many lines the whole capture had, so "one line of a stack trace" is never mistaken
# for "the whole of the failure".
#
# ⚠ NEVER over a whole Maven build log. Measured: two consecutive runs of the same failing
# build differ by one line, because `[INFO] Deleting <target>` appears only when target/
# already exists. A denominator that moves is worse than no denominator - it is a number on a
# slide the terminal contradicts. Count something that belongs to the FAILURE instead: the
# stack frames, the [ERROR] lines, the findings.
of_total() {  # $1 = file, $2 = how many lines were shown
  [ -s "$1" ] || die "of_total: $1 is missing or empty"
  printf '(%s line(s) shown of %s in the whole capture)\n' "$2" "$(wc -l < "$1" | tr -d ' ')"
}

count_in() {
  [ -s "$1" ] || die "$3: $1 is missing or empty, so any count over it would be a lie"
  grep -cE "$2" "$1" || true
}
count_positive() {
  local n; n=$(count_in "$1" "$2" "$3")
  [ "$n" -gt 0 ] || die "$3: counted 0, and 0 cannot be right here"
  printf '%s' "$n"
}

need_jdk25() {
  local v; v=$(java -version 2>&1 | head -1)
  case "$v" in *25.0.4.1*) : ;; *) die "this unit is verified on JDK 25.0.4.1; java -version says: $v" ;; esac
}

# -------------------------------------------------------------- jvmconfig ----
# HASHED. The lesson is a FAILURE. The block asserts the failure and dies if it passes.
run_jvmconfig() {
  block "jvmconfig - ten flags, or Error Prone does not run at all  [HASHED]"
  need_jdk25
  local cfg=.mvn/jvm.config brk=breaks/no-jvm-config
  [ -s "$cfg" ] || die "no $cfg - this unit's whole first beat is that file"
  [ -d "$brk" ] || die "no $brk"
  [ -f "$brk/.mvn/jvm.config" ] || die "$brk needs an EMPTY .mvn/jvm.config or it inherits this unit's"
  [ ! -s "$brk/.mvn/jvm.config" ] || die "$brk/.mvn/jvm.config is not empty, so the break is not a break"

  local exports opens total
  exports=$(count_positive "$cfg" '^--add-exports' 'add-exports lines')
  opens=$(count_positive   "$cfg" '^--add-opens'   'add-opens lines')
  total=$(count_positive   "$cfg" '.'              'lines in jvm.config')

  local rc_bad rc_good
  ( cd "$brk" && mvn -B -ntp -Dmaven.repo.local="$REPO" clean compile ) > .r-nocfg.raw 2>&1; rc_bad=$?
  [ "$rc_bad" -ne 0 ] || die "the build SUCCEEDED without the flags - the break did not reproduce"
  "${MVN[@]}" clean compile > .r-cfg.raw 2>&1; rc_good=$?
  [ "$rc_good" -eq 0 ] || die "the build with the flags exited $rc_good; see .r-cfg.raw"

  { printf 'without .mvn/jvm.config - the same pom, the same sources:\n'
    grep -m1 'IllegalAccessError' .r-nocfg.raw | mask | fold -w 96 -s | sed 's/^/  /'
    printf '  (that is the one line that names the cause; under it are %s stack frames, every\n' \
      "$(grep -cE '^[[:space:]]+at ' .r-nocfg.raw || true)"
    printf '   one of them inside Maven or javac, and none of them inside your project)\n'
    printf '\nand what Maven makes of that:\n'
    grep -m2 -E '^\[ERROR\] (COMPILATION ERROR|An unknown compilation problem)' .r-nocfg.raw | sed 's/^/  /'
    printf '  exit %s\n' "$rc_bad"
    printf '\nwith it:\n'
    printf '  lines in .mvn/jvm.config ......... %s\n' "$total"
    printf '    of those, add-exports .......... %s\n' "$exports"
    printf '    of those, add-opens ............ %s\n' "$opens"
    printf '  exit %s, and Error Prone produced %s finding(s)\n' "$rc_good" \
      "$(grep -cE '^\[WARNING\].*\.java:\[[0-9]+,[0-9]+\] \[[A-Za-z]+\]' .r-cfg.raw || true)"
    printf '\nwhy it cannot be a <compilerArg>: Maven reads .mvn/jvm.config BEFORE it starts\n'
    printf 'its own JVM. A flag that changes what the JVM may access has to be there before\n'
    printf 'the JVM exists, and a plugin configuration is read long after that.\n'
    printf '\nand why the file next to this break is empty rather than absent: Maven finds .mvn\n'
    printf 'by walking UP and stops at the first one, so without it the break would inherit\n'
    printf 'this unit ten flags and pass.\n'
  } > .r-jvmconfig.out 2>&1

  cat .r-jvmconfig.out
  printf 'md5 %s  (exit %s without, exit %s with)\n' "$(hash_of .r-jvmconfig.out)" "$rc_bad" "$rc_good"
}

# --------------------------------------------------------------- warnings ----
# HASHED. Error Prone running, finding real defects, and the build going green anyway.
run_warnings() {
  block "warnings - three findings, and BUILD SUCCESS  [HASHED]"
  need_jdk25
  "${MVN[@]}" clean verify > .r-warn.raw 2>&1; local rc=$?
  [ "$rc" -eq 0 ] || die "the default build is supposed to be GREEN; it exited $rc"

  local findings carried mine tests
  findings=$(count_positive .r-warn.raw '^\[WARNING\].*\.java:\[[0-9]+,[0-9]+\] \[[A-Za-z]+\]' 'Error Prone findings')
  carried=$(grep -E '^\[WARNING\].*\.java:\[[0-9]+,[0-9]+\] \[[A-Za-z]+\]' .r-warn.raw \
            | grep -c '/com/tiffinbox/[A-Z]' || true)
  mine=$(( findings - carried ))
  tests=$(grep -E '^\[INFO\] Tests run:' .r-warn.raw | tail -1 | sed 's/^\[INFO\] //')

  { printf 'mvn verify, with Error Prone on the compiler and nothing promoted:\n'
    grep -E '^\[WARNING\].*\.java:\[[0-9]+,[0-9]+\] \[[A-Za-z]+\]' .r-warn.raw | short | sed 's/^/  /'
    printf '\nfindings ............................ %s\n' "$findings"
    printf '  distinct checks ................... %s\n' \
      "$(grep -oE '\] \[[A-Za-z]+\] ' .r-warn.raw | sort -u | wc -l | tr -d ' ')"
    printf '  in code carried from Course Two ... %s\n' "$carried"
    printf '  in code written for this unit ..... %s\n' "$mine"
    printf '%s\n' "$tests"
    printf 'exit code ........................... %s\n' "$rc"
    printf 'the build said BUILD SUCCESS ........ %s time(s)\n' "$(grep -c 'BUILD SUCCESS' .r-warn.raw || true)"
    printf '\nSo: three real defects, a green build, and a passing test suite. Error Prone\n'
    printf 'reports WARNINGS by default. "We run Error Prone" and "Error Prone stops us"\n'
    printf 'are two different sentences and only one of them is about this build.\n'
  } > .r-warnings.out 2>&1

  cat .r-warnings.out
  printf 'md5 %s  (exit %s)\n' "$(hash_of .r-warnings.out)" "$rc"
}

# ----------------------------------------------------------------- strict ----
# HASHED. The red build - and the honest half, which is that one of the two is not a bug.
run_strict() {
  block "strict - one check promoted, and what it catches that you did not want caught  [HASHED]"
  need_jdk25
  "${MVN[@]}" -Pstrict clean compile > .r-strict.raw 2>&1; local rc=$?
  [ "$rc" -ne 0 ] || die "the strict build SUCCEEDED; -Xep:ReferenceEquality:ERROR did not take effect"

  local errs files
  uniq_findings .r-strict.raw ReferenceEquality > .r-strict.uniq
  errs=$(count_positive .r-strict.uniq '\[ReferenceEquality\]' 'ReferenceEquality errors')
  files=$(sed -E 's#.*/(com/tiffinbox/.*\.java):.*#\1#' .r-strict.uniq | sort -u | wc -l | tr -d ' ')
  [ "$errs" -eq 2 ] || die "expected 2 distinct ReferenceEquality findings, counted $errs - re-read .r-strict.uniq before this goes on a slide"

  # The two lines the compiler pointed at, read out of the SOURCE rather than retyped.
  local l1 l2
  l1=$(sed -n '30p' src/main/java/com/tiffinbox/OrderQueue.java | sed 's/^ *//')
  l2=$(sed -n '30p' src/main/java/com/tiffinbox/quality/MealPlan.java | sed 's/^ *//')
  [ -n "$l1" ] && [ -n "$l2" ] || die "could not read the two flagged lines back out of the sources"

  { printf 'mvn -Pstrict compile   (the profile adds -Xep:ReferenceEquality:ERROR and nothing else)\n'
    short < .r-strict.uniq | sed 's/^/  /'
    printf '  exit %s\n' "$rc"
    printf '\nReferenceEquality errors ............ %s across %s file(s)\n' "$errs" "$files"
    printf '\nand now read the two lines, because they are not the same kind of thing:\n'
    printf '  OrderQueue.java:30   %s\n' "$l1"
    printf '  MealPlan.java:30     %s\n' "$l2"
    printf '\n  MealPlan compares a string that came out of a database with a literal. That is a\n'
    printf '  bug: it is true today only because both happen to be the same interned object.\n'
    printf '\n  OrderQueue compares against a SENTINEL - a single private object created once,\n'
    printf '  whose whole purpose is to be recognised by identity. Value equality would be the\n'
    printf '  wrong test there, and an order whose customer name happened to match would stop\n'
    printf '  the kitchen. That finding is correct about the syntax and wrong about the code.\n'
    printf '\n  The answer is not to switch the check off. It is @SuppressWarnings("ReferenceEquality")\n'
    printf '  on that one method, with the reason in a comment - which is a code review that\n'
    printf '  happened once instead of every time.\n'
    printf '\nfindings promoted to ERROR .......... %s\n' "$errs"
    printf 'of those, a genuine defect .......... 1\n'
    printf 'of those, correct code ............... 1\n'
  } > .r-strict.out 2>&1

  cat .r-strict.out
  printf 'md5 %s  (exit %s)\n' "$(hash_of .r-strict.out)" "$rc"
}

# --------------------------------------------------------------- nullaway ----
# HASHED. The spine: a real null dereference turning into a red build - and the
# misconfiguration that looks exactly like the jvm.config failure.
run_nullaway() {
  block "nullaway - the null bug, and the silence that is not a pass  [HASHED]"
  need_jdk25
  local rc_ok rc_mis
  "${MVN[@]}" -Pnullaway clean compile > .r-na.raw 2>&1; rc_ok=$?
  [ "$rc_ok" -ne 0 ] || die "NullAway did not fail the build; the null dereference is still there"

  "${MVN[@]}" -Pnullaway -Derrorprone.severity="-Xep:NullAway:ERROR" clean compile > .r-namis.raw 2>&1; rc_mis=$?
  [ "$rc_mis" -ne 0 ] || die "NullAway with no AnnotatedPackages exited 0, which it is not supposed to do"

  local hits
  uniq_findings .r-na.raw NullAway > .r-na.uniq
  hits=$(count_positive .r-na.uniq '\[NullAway\]' 'NullAway errors')
  local line; line=$(sed -n '40p' src/main/java/com/tiffinbox/quality/MealPlan.java | sed 's/^ *//')
  [ -n "$line" ] || die "could not read the flagged line back out of MealPlan.java"

  { printf 'mvn -Pnullaway compile\n'
    short < .r-na.uniq | sed 's/^/  /'
    printf '  exit %s\n' "$rc_ok"
    printf '\nthe line it is pointing at:\n'
    printf '  %s\n' "$line"
    printf '  Map.get returns null for a key that is not there, and the return type is int,\n'
    printf '  so the next thing that happens is an unboxing NullPointerException. javac is\n'
    printf '  required to accept this. The test suite does not call it with a missing key.\n'
    printf '\ndistinct NullAway errors ............ %s   (the raw log says %s; Maven prints each twice)\n' \
      "$hits" "$(grep -cE '^\[ERROR\].*\[NullAway\]' .r-na.raw || true)"
    printf 'lines of Java the check needed ...... 0   (no annotations were added to make it fire)\n'
    printf '\nand the misconfiguration that looks like a working build, but is not:\n'
    printf '  the same profile with AnnotatedPackages removed -\n'
    grep -m1 'NullAway configuration is incorrect' .r-namis.raw | mask | fold -w 96 -s | sed 's/^/    /'
    printf '    (one line of %s stack frames, and the useful one is not the last)\n' \
      "$(grep -cE '^[[:space:]]+at ' .r-namis.raw || true)"
    grep -m1 -E '^\[ERROR\] An unknown compilation problem' .r-namis.raw | sed 's/^/    /'
    printf '    exit %s\n' "$rc_mis"
    printf '  That is the SAME sentence Maven printed for the missing jvm.config, for a\n'
    printf '  completely different cause. When Error Prone dies, Maven tells you nothing -\n'
    printf '  so read the lines ABOVE the Maven error, every time.\n'
  } > .r-nullaway.out 2>&1

  cat .r-nullaway.out
  printf 'md5 %s  (exit %s configured, exit %s misconfigured)\n' "$(hash_of .r-nullaway.out)" "$rc_ok" "$rc_mis"
}

# --------------------------------------------------------------- spotless ----
# HASHED. The only one of the four that CHANGES your files - so it runs in a copy.
run_spotless() {
  block "spotless - check, then apply, in a copy  [HASHED]"
  need_jdk25
  local rc_check rc_apply
  "${MVN[@]}" spotless:check > .r-spc.raw 2>&1; rc_check=$?
  [ "$rc_check" -ne 0 ] || die "spotless:check passed, so there is nothing for spotless:apply to do"

  rm -rf .spot && mkdir -p .spot && cp -R src pom.xml config .mvn .spot/
  ( cd .spot && mvn -B -ntp -q -Dmaven.repo.local="$REPO" spotless:apply ) > .r-spa.raw 2>&1; rc_apply=$?
  [ "$rc_apply" -eq 0 ] || die "spotless:apply exited $rc_apply; see .r-spa.raw"

  local flagged changed
  flagged=$(count_positive .r-spc.raw '^\[ERROR\] +src/.*\.java$' 'files spotless flagged')
  changed=$(diff -rq src .spot/src 2>/dev/null | wc -l | tr -d ' ')
  [ "$changed" -gt 0 ] || die "spotless:apply changed nothing, so the demonstration is empty"

  { printf 'mvn spotless:check\n'
    grep -E '^\[ERROR\] (The following files had format violations|    src/|Run .mvn spotless:apply)' .r-spc.raw \
      | sed -E 's/^\[ERROR\] //' | sed 's/^/  /'
    printf '  exit %s\n' "$rc_check"
    printf '\nfiles flagged ....................... %s\n' "$flagged"
    printf '\nmvn spotless:apply, run in a copy so the shipped sources stay as they are:\n'
    printf '  files it changed .................. %s\n' "$changed"
    printf '  and what it did to MealPlan.java - the import block, before and after:\n'
    printf '    before:\n'
    grep -E '^import ' src/main/java/com/tiffinbox/quality/MealPlan.java | sed 's/^/      /'
    printf '    after:\n'
    grep -E '^import ' .spot/src/main/java/com/tiffinbox/quality/MealPlan.java | sed 's/^/      /'
    printf '  import lines before ............... %s\n' "$(grep -cE '^import ' src/main/java/com/tiffinbox/quality/MealPlan.java || true)"
    printf '  import lines after ................ %s   (none added, none removed - reordered)\n' "$(grep -cE '^import ' .spot/src/main/java/com/tiffinbox/quality/MealPlan.java || true)"
    printf '  non-import lines that differ ...... %s\n' \
      "$(diff <(grep -vE '^(import |$)' src/main/java/com/tiffinbox/quality/MealPlan.java) <(grep -vE '^(import |$)' .spot/src/main/java/com/tiffinbox/quality/MealPlan.java) | grep -cE '^[<>]' || true)"
    printf '  carried Course Two sources it touched: %s\n' \
      "$(diff -rq src/main/java/com/tiffinbox .spot/src/main/java/com/tiffinbox 2>/dev/null | grep -c 'com/tiffinbox/[A-Z][a-zA-Z]*\.java' || true)"
    printf '\nSpotless is the only one of the four that rewrites your source. That is why it\n'
    printf 'has two goals rather than one: check is what CI runs, apply is what you run.\n'
  } > .r-spotless.out 2>&1

  cat .r-spotless.out
  printf 'md5 %s  (exit %s then %s)\n' "$(hash_of .r-spotless.out)" "$rc_check" "$rc_apply"
  rm -rf .spot
}

# ------------------------------------------------------------- checkstyle ----
# HASHED. A gate you cannot turn on from the command line is a gate that is off.
run_checkstyle() {
  block "checkstyle - the flag that does nothing  [HASHED]"
  need_jdk25
  local rc_soft rc_naive rc_real
  "${MVN[@]}" checkstyle:check > .r-cs1.raw 2>&1; rc_soft=$?
  "${MVN[@]}" -Dcheckstyle.failOnViolation=true checkstyle:check > .r-cs2.raw 2>&1; rc_naive=$?
  "${MVN[@]}" -Dcheckstyle.fail=true            checkstyle:check > .r-cs3.raw 2>&1; rc_real=$?

  [ "$rc_soft" -eq 0 ]  || die "the default checkstyle run is supposed to be green; it exited $rc_soft"
  [ "$rc_naive" -eq 0 ] || die "-Dcheckstyle.failOnViolation=true DID fail the build - re-measure before this goes on a slide"
  [ "$rc_real" -ne 0 ]  || die "-Dcheckstyle.fail=true did not fail the build, so the gate is unreachable"

  local viol rules
  viol=$(grep -oE 'You have [0-9]+ Checkstyle violation' .r-cs1.raw | grep -oE '[0-9]+' | head -1)
  [ -n "$viol" ] || die "checkstyle printed no violation count"
  # Checker and TreeWalker are containers, not checks. Counting every <module> element
  # answers 7 for a file that declares 5 rules, and 7 is the kind of number a viewer
  # counts on screen and catches you on.
  rules=$(grep -cE '<module name="(NewlineAtEndOfFile|FileTabCharacter|JavadocType|AvoidStarImport|EmptyCatchBlock)"' config/checkstyle.xml || true)
  [ "$rules" -gt 0 ] || die "counted 0 checkstyle rules in config/checkstyle.xml"

  { printf 'config/checkstyle.xml declares %s checks - Checker and TreeWalker are containers,\n' "$rules"
    printf 'not checks, so the file has seven <module> elements and five rules - and this is\n'
    printf 'what they find:\n'
    grep -E '^\[WARN\] ' .r-cs1.raw | short | sed 's/^/  /'
    printf '\nviolations ................................. %s\n' "$viol"
    printf 'and every one of them is in code carried from Course Two: %s of %s\n' \
      "$(grep -E '^\[WARN\] ' .r-cs1.raw | short | grep -cE '^com/tiffinbox/[A-Z][a-zA-Z]*\.java' || true)" "$viol"
    printf '\nthree runs of the SAME goal:\n'
    printf '  mvn checkstyle:check ..................................... exit %s\n' "$rc_soft"
    printf '  mvn -Dcheckstyle.failOnViolation=true checkstyle:check ... exit %s\n' "$rc_naive"
    printf '  mvn -Dcheckstyle.fail=true checkstyle:check .............. exit %s\n' "$rc_real"
    printf '\nthe middle one is the trap. Maven says so in its own words:\n'
    grep -m1 'violations detected but failOnViolation set to false' .r-cs2.raw | sed 's/^/  /'
    printf '\nExplicit plugin <configuration> beats a user property. Writing\n'
    printf '  <failOnViolation>false</failOnViolation>\n'
    printf 'makes -Dcheckstyle.failOnViolation unreachable for ever. Writing\n'
    printf '  <failOnViolation>${checkstyle.fail}</failOnViolation>\n'
    printf 'keeps the switch. The difference is invisible until the day you need the gate.\n'
  } > .r-checkstyle.out 2>&1

  cat .r-checkstyle.out
  printf 'md5 %s  (exit %s, %s, %s)\n' "$(hash_of .r-checkstyle.out)" "$rc_soft" "$rc_naive" "$rc_real"
}

# --------------------------------------------------------------- solution ----
run_solution() {
  block "solution - the exercise, start state proved first  [HASHED]"
  need_jdk25
  [ -f exercise/solution/MealPlan.java ]   || die "no answer at exercise/solution/MealPlan.java"
  [ -f exercise/solution/OrderQueue.java ] || die "no answer at exercise/solution/OrderQueue.java"

  "${MVN[@]}" -Pnullaway clean compile > .r-sol1.raw 2>&1; local before=$?
  [ "$before" -ne 0 ] || die "the shipped project already passes -Pnullaway - the exercise has nothing to fix"

  rm -rf .sol && mkdir -p .sol && cp -R src pom.xml config .mvn .sol/
  cp exercise/solution/MealPlan.java   .sol/src/main/java/com/tiffinbox/quality/MealPlan.java
  cp exercise/solution/OrderQueue.java .sol/src/main/java/com/tiffinbox/OrderQueue.java
  ( cd .sol && mvn -B -ntp -Dmaven.repo.local="$REPO" -Pnullaway clean compile ) > .r-sol2.raw 2>&1; local after=$?
  ( cd .sol && mvn -B -ntp -Dmaven.repo.local="$REPO" -Pstrict  clean test    ) > .r-sol3.raw 2>&1; local strict=$?

  { printf 'start state - mvn -Pnullaway compile against the shipped sources:\n'
    uniq_findings .r-sol1.raw NullAway | short | sed 's/^/  /'
    printf '  exit %s\n' "$before"
    printf '\nanswer - exercise/solution/MealPlan.java:\n'
    printf '  distinct NullAway errors now ...... %s\n' "$(uniq_findings .r-sol2.raw NullAway | wc -l | tr -d ' ')"
    printf '  exit %s\n' "$after"
    printf '  and the same answer under -Pstrict (ReferenceEquality promoted):\n'
    printf '  distinct ReferenceEquality errors now %s   (down from 2: one line fixed, one\n' \
      "$(uniq_findings .r-sol3.raw ReferenceEquality | wc -l | tr -d ' ')"
    printf '                                          suppressed with its reason written down)\n'
    printf '  exit %s\n' "$strict"
    printf '  tests: %s\n' "$(grep -E '^\[INFO\] Tests run:' .r-sol3.raw | tail -1 | sed 's/^\[INFO\] //')"
    printf '\nlines that differ from the shipped MealPlan.java ... %s\n' \
      "$(diff src/main/java/com/tiffinbox/quality/MealPlan.java exercise/solution/MealPlan.java | grep -cE '^[<>]' || true)"
    printf 'lines that differ from the shipped OrderQueue.java . %s\n' \
      "$(diff src/main/java/com/tiffinbox/OrderQueue.java exercise/solution/OrderQueue.java | grep -cE '^[<>]' || true)"
    printf 'and the shipped sources themselves are untouched: the answers live in exercise/solution/\n'
  } > .r-solution.out 2>&1

  cat .r-solution.out
  printf 'md5 %s  (exit %s then %s)\n' "$(hash_of .r-solution.out)" "$before" "$after"
  [ "$after" -eq 0 ]  || die "the answer does not pass -Pnullaway"
  [ "$strict" -eq 0 ] || die "the answer does not pass -Pstrict; see .r-sol3.raw"
  rm -rf .sol
}

# ---------------------------------------------------------------- offline ----
run_offline() {
  block "offline - the contract's re-run receipt  [HASHED]"
  need_jdk25
  "${MVN[@]}" -q clean verify > .r-warm.raw 2>&1 || die "the warm build failed"
  "${MVN[@]}" -o test > .r-off.raw 2>&1; local rc=$?
  [ "$rc" -eq 0 ] || die "mvn -o test exited $rc; see .r-off.raw"
  { grep -E 'Tests run:|BUILD SUCCESS' .r-off.raw | mask
    printf 'offline runs that reached the network: %s\n' "$(grep -c 'Downloading' .r-off.raw || true)"
    printf 'exit code: %s\n' "$rc"
    printf 'the lifecycle the repository was warmed with: verify (spotless and checkstyle resolve there)\n'
  } > .r-offline.out 2>&1
  cat .r-offline.out
  printf 'md5 %s  (exit %s)\n' "$(hash_of .r-offline.out)" "$rc"
}

case "${1:-all}" in
  jvmconfig)  run_jvmconfig ;;
  warnings)   run_warnings ;;
  strict)     run_strict ;;
  nullaway)   run_nullaway ;;
  spotless)   run_spotless ;;
  checkstyle) run_checkstyle ;;
  solution)   run_solution ;;
  offline)    run_offline ;;
  all) run_jvmconfig; run_warnings; run_strict; run_nullaway; run_spotless; run_checkstyle; run_solution; run_offline ;;
  *) echo "unknown block: $1" >&2; exit 2 ;;
esac
