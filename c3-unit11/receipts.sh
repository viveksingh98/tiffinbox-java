#!/bin/bash
# receipts.sh - regenerate every number this unit puts on a slide.
#
# The rule this file exists to enforce: a count on a slide is DERIVED by the same run that
# produced the capture above it. Nothing here echoes a number a human typed. If a filter
# below changes, the hash changes, and the slide is wrong until it is re-captured.
#
#   ./receipts.sh            run every block
#   ./receipts.sh lifecycle  run one block
#
# Three rules every receipts.sh in this section now follows:
#
#   1. A DERIVED LINE IS PART OF THE CAPTURE. Every count is appended to the .out file
#      before that file is hashed, so the md5 quoted on a slide covers the number on the
#      slide. A wrong derived count moves the hash - which is the only reason to take one.
#   2. EVERY MAVEN RUN RECORDS ITS EXIT CODE, and it is printed beside the md5
#      (contract 8.5, C2 OPEN-FINDINGS #10). A block whose build did not do what the
#      lesson needs calls die() instead of printing a confident number.
#   3. A COUNT'S LABEL NAMES WHAT WAS COUNTED. Where the honest count needs a second run
#      rather than a grep - "does any of these tests actually constrain the value?" - the
#      block does the second run.
#
# Everything is isolated: -Dmaven.repo.local="$PWD/.m2-demo" (quoted - this tree's path can
# contain a space), never ~/.m2.

set -u
set -o pipefail
cd "$(dirname "$0")" || exit 1

export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"

REPO="$PWD/.m2-demo"
MVN=(mvn -B -Dmaven.repo.local="$REPO")

die() { printf '\nRECEIPT FAILED (%s): %s\n' "${BLOCK:-?}" "$1" >&2; exit 1; }

hash_of() { md5 -q "$1" 2>/dev/null || md5sum "$1" | cut -d' ' -f1; }
block() { BLOCK="${1%% *}"; printf '\n=== %s ===\n' "$1"; }
clean() { sed -E -e 's/, Time elapsed: [0-9.]+ s//' -e 's/ -- Time elapsed: [0-9.]+ s//' \
                 -e "s#${PWD}/#<project>/#g" \
                 -e 's#[^ ]*/c3-unit11/#<project>/#g' \
                 -e 's#/Users/[^/]*/#<home>/#g'; }

run_lifecycle() {
  block "lifecycle - the order Jupiter really used"
  "${MVN[@]}" test > .r-life.raw 2>&1; rc=$?
  [ "$rc" -eq 0 ] || die "mvn test exited $rc - there is no lifecycle to read"
  sed -n '/@BeforeAll/,/@AfterAll/p' .r-life.raw | clean > .r-lifecycle.out
  [ -s .r-lifecycle.out ] || die "the run printed no @BeforeAll/@AfterAll lines"
  # DERIVED, not typed:
  printf 'beforeEach ran %s times; the class has %s @Test methods\n' \
    "$(grep -c '@BeforeEach' .r-lifecycle.out)" \
    "$(grep -c '@Test' src/test/java/com/tiffinbox/CustomerTest.java)" >> .r-lifecycle.out
  # DERIVED, and it is the MECHANISM rather than the claim. Slide 3 puts two orders in a table and
  # then says why they differ; neither row may be a string a human typed. With no @TestMethodOrder
  # and no junit.jupiter.testmethod.order.default, Jupiter installs no MethodOrderer at all -
  # MethodOrderer.Default is an uninstantiable marker whose orderMethods() body is empty, and
  # DefaultJupiterConfiguration.getDefaultTestMethodOrderer() just reads that property and returns
  # Optional.empty() when it is unset. The sort is junit-platform-commons' own defaultMethodSorter:
  # Integer.compare(m1.getName().hashCode(), m2.getName().hashCode()), ties broken by the name and
  # then the signature. So recompute that hash over the four method names in the source and check
  # the order it predicts against the order this run actually printed. If a later JUnit changes the
  # rule, the two stop matching and this block DIES rather than shipping a wrong sentence.
  SRC_T=src/test/java/com/tiffinbox/CustomerTest.java
  file_order=$(awk '/^    @Test/{t=1}
                    t && /System\.out\.println\("    test: /{sub(/.*test: /,""); sub(/".*/,""); print; t=0}' \
                 "$SRC_T" | paste -sd' ' -)
  run_order=$(sed -n 's/^ *test: //p' .r-lifecycle.out | paste -sd' ' -)
  hash_order=$(awk '/^    @Test/{t=1}
                    t==1 && /^    void /{name=$2; sub(/\(.*/,"",name); t=2; next}
                    t==2 && /System\.out\.println\("    test: /{lbl=$0; sub(/.*test: /,"",lbl); sub(/".*/,"",lbl);
                                                                  print name"\t"lbl; t=0}' "$SRC_T" \
               | awk -F'\t' 'BEGIN{for(i=0;i<128;i++) ord[sprintf("%c",i)]=i}
                   {h=0; n=length($1); for(i=1;i<=n;i++){h=(h*31+ord[substr($1,i,1)])%4294967296}
                    if(h>=2147483648) h-=4294967296
                    printf "%d\t%s\n", h, $2}' | sort -n -k1,1 | cut -f2 | paste -sd' ' -)
  [ -n "$file_order" ] && [ -n "$run_order" ] && [ -n "$hash_order" ] \
    || die "could not read all three method orders out of the run and the source"
  [ "$run_order" = "$hash_order" ] || die \
    "this run ordered the tests $run_order, but the method-name hashCode order is $hash_order - slide 3's rule bar is wrong on this JUnit and the beat must be RE-CUT, not re-hashed"
  printf 'declared in the file: %s\n' "$file_order" >> .r-lifecycle.out
  printf 'sorted by method-name hashCode: %s - and that is the order above\n' "$hash_order" >> .r-lifecycle.out
  cat .r-lifecycle.out
  rm -f .r-life.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-lifecycle.out)" "$rc"
}

run_counts() {
  block "counts - what the [INFO] filter kept out of surefire's Tests run: lines"
  "${MVN[@]}" test > .r-counts.raw 2>&1; rc=$?
  [ "$rc" -eq 0 ] || die "mvn test exited $rc"
  grep -E '^\[INFO\] Tests run:' .r-counts.raw | clean > .r-counts.out
  [ -s .r-counts.out ] || die "no Tests run: line in the run"
  # DERIVED, and the label names THE FILTER, not surefire: surefire prints the per-class line at
  # [WARNING] when anything was skipped, so the [INFO] filter on the panel head is what reduced
  # two lines to one. Crediting the 1 to surefire would be rule 3 broken in this file's own words.
  printf 'the [INFO] filter kept %s of the %s Tests run: lines surefire printed; this one is the suite total\n' \
    "$(grep -c '^\[INFO\] Tests run:' .r-counts.out)" \
    "$(grep -cE '^\[[A-Z]+\] Tests run:' .r-counts.raw)" >> .r-counts.out
  cat .r-counts.out
  rm -f .r-counts.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-counts.out)" "$rc"
}

run_capstone() {
  block "capstone - the state this unit opens on, rebuilt from the delivered long-lived project"
  SRC=../c3-tiffinbox
  [ -d "$SRC" ] || die "$SRC is not beside this unit - slide 1's capture is the long-lived project's own build"
  rm -rf .capstone && cp -R "$SRC" .capstone
  find .capstone -name target -type d -prune -exec rm -rf {} + 2>/dev/null
  ( cd .capstone && mvn -B -Dmaven.repo.local="$REPO" clean package > ../.r-cap.raw 2>&1 ); rc=$?
  [ "$rc" -eq 0 ] || die "the delivered capstone exited $rc - slide 1 shows it green"
  grep -E '^\[INFO\] --- surefire|^\[INFO\] No tests to run\.|^\[INFO\] BUILD' .r-cap.raw \
    | clean > .r-capstone.out
  grep -q 'No tests to run' .r-capstone.out || die \
    "the long-lived project no longer prints 'No tests to run.' - a later unit gave it tests, so slide 1 is a historical capture and must be RE-CUT, not re-hashed"
  cat .r-capstone.out
  rm -rf .capstone .r-cap.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-capstone.out)" "$rc"
}

run_platform() {
  block "platform - the version line surefire's own provider adds, beside the one your tests use"
  "${MVN[@]}" test > .r-plat.raw 2>&1; rc=$?
  [ "$rc" -eq 0 ] || die "mvn test exited $rc - surefire never ran, so its provider pulled nothing"
  "${MVN[@]}" dependency:build-classpath -Dmdep.outputFile="$PWD/.r-cp.txt" >> .r-plat.raw 2>&1; rc2=$?
  [ "$rc2" -eq 0 ] || die "dependency:build-classpath exited $rc2"
  find "$REPO/org/junit/platform" -name '*.jar' \
    | sed -E 's#.*/org/junit/platform/([^/]+)/([^/]+)/.*#\1 \2#' | sort -u > .r-platform.out
  [ -s .r-platform.out ] || die "no junit-platform jar in the isolated repository"
  # DERIVED both ways: what the repository holds after a real test run, and what the test
  # classpath actually carries. The gap is surefire's own surefire-junit-platform provider.
  repo_v=$(awk '{print $2}' .r-platform.out | sort -u)
  cp_v=$(tr ':' '\n' < .r-cp.txt | grep -oE 'junit-platform-[a-z]+-[0-9][^/]*\.jar' \
         | sed -E 's/^junit-platform-[a-z]+-(.*)\.jar$/\1/' | sort -u)
  printf 'in the local repository: %s junit-platform version line(s) - %s\n' \
    "$(printf '%s\n' "$repo_v" | wc -l | tr -d ' ')" "$(printf '%s' "$repo_v" | tr '\n' ' ')" >> .r-platform.out
  printf 'on the test classpath:   %s junit-platform version line(s) - %s\n' \
    "$(printf '%s\n' "$cp_v" | wc -l | tr -d ' ')" "$(printf '%s' "$cp_v" | tr '\n' ' ')" >> .r-platform.out
  cat .r-platform.out
  rm -f .r-plat.raw .r-cp.txt
  printf 'md5 %s  exit %s\n' "$(hash_of .r-platform.out)" "$rc"
}

run_bom() {
  block "bom - one version number across the whole JUnit family"
  "${MVN[@]}" dependency:tree > .r-bom.raw 2>&1; rc=$?
  [ "$rc" -eq 0 ] || die "dependency:tree exited $rc"
  grep -oE 'org\.junit[^ ]*:jar:[0-9][^:]*' .r-bom.raw | sort -u > .r-bom.out
  [ -s .r-bom.out ] || die "the tree named no org.junit artifact at all"
  # DERIVED: how many distinct version numbers do all those artifacts carry?
  printf '%s junit artifacts, %s distinct version number(s)\n' \
    "$(wc -l < .r-bom.out | tr -d ' ')" \
    "$(sed -E 's/.*:jar://' .r-bom.out | sort -u | wc -l | tr -d ' ')" >> .r-bom.out
  cat .r-bom.out
  rm -f .r-bom.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-bom.out)" "$rc"
}

run_notests() {
  block "notests - the starting state of the exercise"
  ( cd exercise && rm -rf target \
      && mvn -B -Dmaven.repo.local="$REPO" test > ../.r-notests.raw 2>&1 ); rc=$?
  [ "$rc" -eq 0 ] || die "the exercise's start state exited $rc - it is supposed to be green and empty"
  grep -E '^\[INFO\] --- surefire|^\[INFO\] No tests to run\.|^\[INFO\] BUILD' .r-notests.raw \
    | clean > .r-notests.out
  grep -q 'No tests to run' .r-notests.out || die "the start state no longer prints 'No tests to run.'"
  printf 'surefire version Maven chose with no pin in this pom: %s\n' \
    "$(grep -oE 'surefire:[0-9][0-9.]*' .r-notests.out | head -1 | cut -d: -f2)" >> .r-notests.out
  cat .r-notests.out
  rm -f .r-notests.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-notests.out)" "$rc"
}

run_break() {
  block "break - one assertion at a time vs assertAll"
  ( cd breaks/one-assertion && rm -rf target \
      && mvn -B -Dmaven.repo.local="$REPO" test > ../../.r-break.raw 2>&1 ); rc=$?
  [ "$rc" -ne 0 ] || die "breaks/one-assertion passed - there is no failure report to compare"
  sed -n '/^\[ERROR\] Failures:/,/^\[ERROR\] Tests run:/p' .r-break.raw | clean > .r-break.out
  [ -s .r-break.out ] || die "no Failures: block - the break did not compile"
  # Each class's entry is bounded by ITS OWN [ERROR]   marker, not by where the other class
  # happens to sit. surefire's runOrder=filesystem is not a promise about which class is reported
  # first, and the earlier range form ('/ReportsAllOfThem/,/StopsAtTheFirst/' and
  # '/StopsAtTheFirst/,$') read 2 and 3 out of the same two entries when they arrived reversed -
  # which inverts slide 5's point. Same predicate on both sides, too: one 'expected: <x> but was:
  # <y>' per named mismatch, wherever the runner chose to print it.
  entry() { awk -v k="$1" '
      $0 ~ "^\\[ERROR\\]   " k "\\." {p=1; print; next}
      p && /^\[ERROR\]   [A-Za-z]/  {p=0}
      p && /^\[(INFO|ERROR)\] /     {p=0}
      p {print}' .r-break.out; }
  for c in ReportsAllOfThemTest StopsAtTheFirstTest; do
    [ -n "$(entry "$c")" ] || die "$c has no entry in the Failures: block - there is nothing to compare"
  done
  named_all=$(entry ReportsAllOfThemTest | grep -c 'expected:')
  named_one=$(entry StopsAtTheFirstTest  | grep -c 'expected:')
  # DERIVED, not assumed (brief 0.11): which class surefire reported first, on the record and
  # inside the hashed file, so no slide has to depend on an order nobody promised.
  class_order=$(grep -oE '^\[ERROR\]   [A-Za-z]+Test' .r-break.out | sed 's/^\[ERROR\]   //' \
                | awk '!seen[$0]++' | paste -sd' ' -)
  printf 'assertAll named %s failures; the three-statements version named %s\n' \
    "$named_all" "$named_one" >> .r-break.out
  printf 'the report named the classes in this order: %s\n' "$class_order" >> .r-break.out
  cat .r-break.out
  rm -f .r-break.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-break.out)" "$rc"
}

run_green() {
  block "green - three passing tests over a method that is wrong"
  G=breaks/green-for-nothing
  ( cd "$G" && rm -rf target && mvn -B -Dmaven.repo.local="$REPO" test > ../../.r-g1.raw 2>&1 ); rc1=$?
  [ "$rc1" -eq 0 ] || die "the green suite exited $rc1 - the whole point is that it is green"
  grep -E '^\[INFO\] Tests run:|^\[INFO\] BUILD' .r-g1.raw | clean > .r-green.out
  [ -s .r-green.out ] || die "the green run printed no Tests run: line"
  # now the same project with one real assertion added
  rm -rf .green && cp -R "$G" .green && rm -rf .green/target
  sed -n '/^package com.tiffinbox;/,$p' "$G/CaughtItTest.java.txt" \
    > .green/src/test/java/com/tiffinbox/CaughtItTest.java
  ( cd .green && mvn -B -Dmaven.repo.local="$REPO" test > ../.r-g2.raw 2>&1 ); rc2=$?
  [ "$rc2" -ne 0 ] || die "the fourth test passed - it is supposed to catch the wrong bill"
  grep -E '^\[ERROR\] Tests run:|^\[ERROR\]   CaughtIt|^\[INFO\] BUILD' .r-g2.raw \
    | sed -E 's/ <<< FAILURE!.*//' | clean >> .r-green.out
  # DERIVED BY RUNNING IT, not by grepping for the word "assert": if no test in the green
  # class constrains the VALUE, then changing the value must not change the result. Same
  # three tests, a different wrong number of days.
  rm -rf .green2 && cp -R "$G" .green2 && rm -rf .green2/target
  sed 's/\* 31;/\* 29;/' "$G/src/main/java/com/tiffinbox/Customer.java" \
    > .green2/src/main/java/com/tiffinbox/Customer.java
  grep -q '\* 29;' .green2/src/main/java/com/tiffinbox/Customer.java \
    || die "the 31 -> 29 edit did not apply; the value-sensitivity probe would prove nothing"
  ( cd .green2 && mvn -B -Dmaven.repo.local="$REPO" test > ../.r-g3.raw 2>&1 ); rc3=$?
  probe=$(grep -E '^\[(INFO|ERROR)\] Tests run:' .r-g3.raw | tail -1 \
          | sed -E 's/.*Tests run: ([0-9]+), Failures: ([0-9]+).*/\1 \2/')
  [ -n "$probe" ] || die "the 29-day probe printed no Tests run: summary"
  set -- $probe
  printf 'the same three tests against a month of 29 days instead of 31: %s ran, %s failed - so %s of them constrain the value\n' \
    "$1" "$2" "$2" >> .r-green.out
  printf '%s test method(s) in the green class; add one that names the number and the suite becomes %s test(s), %s failure(s)\n' \
    "$(grep -c '^    @Test' "$G/src/test/java/com/tiffinbox/GreenForNothingTest.java")" \
    "$(grep -E '^\[ERROR\] Tests run:' .r-green.out | tail -1 | sed -E 's/.*Tests run: ([0-9]+).*/\1/')" \
    "$(grep -E '^\[ERROR\] Tests run:' .r-green.out | tail -1 | sed -E 's/.*Failures: ([0-9]+).*/\1/')" \
    >> .r-green.out
  cat .r-green.out
  rm -rf .green .green2 .r-g1.raw .r-g2.raw .r-g3.raw
  printf 'md5 %s  exit %s then %s then %s\n' "$(hash_of .r-green.out)" "$rc1" "$rc2" "$rc3"
}

run_solution() {
  block "solution - the exercise answer, actually run"
  rm -rf .sol && cp -R exercise .sol && rm -rf .sol/solution .sol/BillTest.java.txt .sol/target
  cp exercise/solution/pom.xml .sol/pom.xml
  mkdir -p .sol/src/test/java/com/tiffinbox
  cp exercise/solution/BillTest.java .sol/src/test/java/com/tiffinbox/BillTest.java
  ( cd .sol && mvn -B -Dmaven.repo.local="$REPO" test > ../.r-sol.raw 2>&1 ); rc=$?
  [ "$rc" -eq 0 ] || die "the exercise answer exited $rc - it does not pass"
  grep -E '^\[INFO\] Tests run:|^\[INFO\] BUILD' .r-sol.raw | clean > .r-solution.out
  [ -s .r-solution.out ] || die "the answer printed no Tests run: line"
  printf 'the answer adds %s test method(s) and pins surefire to %s\n' \
    "$(grep -c '@Test' exercise/solution/BillTest.java)" \
    "$(grep -A2 'maven-surefire-plugin' exercise/solution/pom.xml | grep -oE '<version>[0-9.]+' | head -1 | cut -d'>' -f2)" \
    >> .r-solution.out
  cat .r-solution.out
  rm -rf .sol .r-sol.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-solution.out)" "$rc"
}

run_offline() {
  block "offline - contract 1c, after one warm build"
  "${MVN[@]}" -o test > .r-off.raw 2>&1; rc=$?
  [ "$rc" -eq 0 ] || die "mvn -o test exited $rc - this unit does not build offline"
  grep -E '^\[INFO\] Tests run:|^\[INFO\] BUILD' .r-off.raw | clean > .r-offline.out
  [ -s .r-offline.out ] || die "the offline run printed no Tests run: line"
  cat .r-offline.out
  rm -f .r-off.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-offline.out)" "$rc"
}

ALL=(capstone lifecycle counts bom platform notests break green solution offline)
TARGETS=("$@")
[ ${#TARGETS[@]} -eq 0 ] && TARGETS=("${ALL[@]}")
for t in "${TARGETS[@]}"; do "run_$t"; done
