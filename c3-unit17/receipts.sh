#!/bin/bash
# receipts.sh - regenerate every number this unit puts on a slide.
#
# The rule this file exists to enforce: a count on a slide is DERIVED by the same run that
# produced the capture above it. Every percentage below is computed by awk from the CSV or
# the XML that the run above it wrote. Nothing here echoes a number a human typed.
#
#   ./receipts.sh            run every block
#   ./receipts.sh mutants    run one block
#
# Three rules this file learned the hard way, and they are why it looks like this:
#
#   1. A DERIVED LINE IS PART OF THE CAPTURE. Every count is appended to the .out file
#      before that file is hashed, so the md5 on a slide covers the number on the slide.
#      A wrong derived number moves the hash; that is the whole point of taking one.
#   2. A BLOCK THAT CANNOT MEASURE MUST NOT PRINT. Every Maven run records its exit code,
#      every derived value is checked for emptiness, and a block that has nothing to
#      measure calls die() instead of printing a confident zero. An earlier draft of
#      `unchanged` compared two empty strings and cheerfully reported them identical.
#   3. EVERY BLOCK MEASURES ITS OWN RUN, AND PRINTS THE EXIT CODE IT MEASURED. No block
#      reads back a report an earlier run left on disk, and no block prints an exit code
#      it typed rather than took from $?. Run one block on its own - which is what the
#      line above tells you to do - and it rebuilds. See `scope` for the draft that did
#      not, and what it reported.
#
# PIT stamps a wall-clock time on every log line, so only its ">>" statistics block is ever
# captured here, never its log.

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

# Durations move every run; so do absolute paths. JaCoCo prints the exec file's FULL path,
# so masking only /Users/<name>/ leaves the rest of this clone's path inside a hashed block
# and the hash stops being reproducible anywhere but the author's disk (contract 8.5).
# Mask the project root itself, by two independent rules, before the home rule.
clean() { sed -E -e 's/, Time elapsed: [0-9.]+ s//' -e 's/ -- Time elapsed: [0-9.]+ s//' \
                 -e "s#${PWD}/#<project>/#g" \
                 -e 's#[^ ]*/c3-unit17/#<project>/#g' \
                 -e 's#/Users/[^/]*/#<home>/#g'; }

# the one percentage routine, used everywhere, so no two blocks can disagree.
# A denominator of zero is not 0% and is not "n/a" - it means nothing was measured, and
# a receipt that prints a percentage over nothing is the defect this file guards against.
pct() { awk -v m="$1" -v c="$2" 'BEGIN{t=m+c; if (t==0) exit 1; printf "%d/%d (%.0f%%)", c, t, 100*c/t}'; }

csv_row() { grep "^[^,]*,com.tiffinbox,$1," "$2" 2>/dev/null; }

# A row that is not there is not a row of zeroes. Refuse to report one.
require_row() {   # $1 = class, $2 = csv, $3 = what asked for it
  [ -f "$2" ] || die "$3: $2 does not exist - JaCoCo wrote no report"
  row=$(csv_row "$1" "$2")
  [ -n "$row" ] || die "$3: no $1 row in $2 - the agent measured nothing"
  printf '%s\n' "$row"
}

report_class() {   # $1 = class, $2 = csv
  local row lines branches instr
  row=$(require_row "$1" "$2" report_class) || exit 1
  lines=$(pct    "$(echo "$row" | cut -d, -f8)" "$(echo "$row" | cut -d, -f9)") \
    || die "report_class: $1 has no lines at all in $2"
  branches=$(pct "$(echo "$row" | cut -d, -f6)" "$(echo "$row" | cut -d, -f7)") \
    || die "report_class: $1 has no branches at all in $2"
  instr=$(pct    "$(echo "$row" | cut -d, -f4)" "$(echo "$row" | cut -d, -f5)") \
    || die "report_class: $1 has no instructions at all in $2"
  printf '%-12s lines %s  branches %s  instructions %s\n' "$1" "$lines" "$branches" "$instr"
}

run_coverage() {
  block "coverage - JaCoCo over the class this unit is about"
  "${MVN[@]}" clean test > .r-cov.raw 2>&1; rc=$?
  [ "$rc" -eq 0 ] || die "mvn clean test exited $rc - there is nothing to measure"
  grep -E '^\[INFO\] Tests run:|^\[INFO\] BUILD|Loading execution data' .r-cov.raw \
    | clean > .r-coverage.out
  # RED's question (e): name the artifact, not the build result
  [ -f target/jacoco.exec ] || die "no target/jacoco.exec - the agent never loaded"
  printf 'target/jacoco.exec exists: yes\n' >> .r-coverage.out
  require_row Pricing target/site/jacoco/jacoco.csv coverage >> .r-coverage.out
  report_class Pricing target/site/jacoco/jacoco.csv >> .r-coverage.out
  cat .r-coverage.out
  # The exec file's SIZE is deliberately NOT printed. Measured: the same test set gives 30848
  # bytes under one checkout path and 30847 under another, because the session record inside
  # it is not path-independent. Printing it put a machine-dependent number into this script's
  # own stdout, which made the WHOLE-RUN roll-up md5 unreproducible - a hash over a size is
  # not a receipt (contract 8.5), and neither is a roll-up that contains one. What is worth
  # asserting is that the agent ran at all, so that is asserted, and it can fail:
  [ -s target/jacoco.exec ] || die 'coverage: no target/jacoco.exec - the JaCoCo agent did not run'
  printf 'target/jacoco.exec: present and non-empty (its byte size varies with machine and path, so it is not printed or hashed)\n'
  rm -f .r-cov.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-coverage.out)" "$rc"
}

run_scope() {
  block "scope - the same run, two denominators"
  csv=target/site/jacoco/jacoco.csv
  # Rule 3, and this is the block that taught it. An earlier draft reused $csv whenever the
  # file already existed and set rc=0 by typing it. Add a method to Pricing.java that no test
  # calls, then run `./receipts.sh scope` on its own - the single-block usage this file's own
  # header documents - and it printed `Pricing lines 6/6 (100%) branches 4/4 (100%)
  # instructions 15/15 (100%)`, `whole project (8 classes) lines 8/97 (8%)`, `classes in the
  # report: 8` and `exit 0`, in about a second, for source it had never compiled. The honest
  # measurement of that same tree is 6/9, 4/8, 15/27. Every number on the slide was stale and
  # the receipt read GREENER than the truth - in the unit whose subject is that a green build
  # is not evidence a tool ran. It rebuilds every time now, and prints the rc it measured.
  "${MVN[@]}" clean test > .r-scope.raw 2>&1; rc=$?
  [ "$rc" -eq 0 ] || die "mvn clean test exited $rc - there is no report to scope"
  [ -f "$csv" ] || die "no $csv after a green build - JaCoCo wrote no report to scope"
  rm -f .r-scope.raw
  report_class Pricing "$csv" > .r-scope.out
  # DERIVED: every row of the same file, summed
  awk -F, 'NR>1 {lm+=$8; lc+=$9; n++} END {
      if (n==0 || lm+lc==0) { print "NO CLASS ROWS"; exit 1 }
      printf "whole project (%d classes) lines %d/%d (%.0f%%)\n", n, lc, lm+lc, 100*lc/(lm+lc) }' \
      "$csv" >> .r-scope.out || die "jacoco.csv has no class rows"
  # DERIVED, and the label has to name what is measured. An earlier draft counted test
  # SOURCE FILES here and called them "classes this unit tests". That was right by accident -
  # one test class over one class under test - and it would have printed 2 the day somebody
  # split PricingTest in two without adding a single class under test. The classes under test
  # are the ones the pom declares, and it is the same declaration PIT is pointed at.
  under_test=$(python3 - pom.xml <<'PY'
import re, sys
s = open(sys.argv[1]).read()
m = re.search(r'<targetClasses>(.*?)</targetClasses>', s, re.S)
print(len(re.findall(r'<param>', m.group(1))) if m else 0)
PY
)
  [ -n "$under_test" ] && [ "$under_test" -gt 0 ] \
    || die "pom.xml declares no <targetClasses> - there is no class-under-test count to print"
  printf 'classes in the report: %s; classes this unit tests: %s\n' \
    "$(awk -F, 'NR>1' "$csv" | wc -l | tr -d ' ')" \
    "$under_test" >> .r-scope.out
  cat .r-scope.out
  printf 'md5 %s  exit %s\n' "$(hash_of .r-scope.out)" "$rc"
}

# the .fix tree: this project, with the answer's two files copied over it
make_fix() {
  rm -rf .fix && cp -R . .fix 2>/dev/null
  rm -rf .fix/.fix .fix/.m2-demo .fix/target .fix/breaks .fix/exercise .fix/.r-*
}

run_bug() {
  block "bug - the input the tests never tried"
  make_fix
  cp exercise/solution/PricingTest.java .fix/src/test/java/com/tiffinbox/PricingTest.java
  ( cd .fix && mvn -B -Dmaven.repo.local="$REPO" test > ../.r-bug.raw 2>&1 ); rc=$?
  [ "$rc" -ne 0 ] || die "the boundary test passed - this break no longer breaks"
  sed -n '/^\[INFO\] Results:/,/^\[ERROR\] Tests run:/p' .r-bug.raw | clean > .r-bug.out
  [ -s .r-bug.out ] || die "no Results: block in the run - the build failed before a test ran"
  # DERIVED: the boundary the code tests, and the boundary the javadoc promises
  code_bound=$(grep -oE 'bill [<>=]+ [0-9_]+' src/main/java/com/tiffinbox/Pricing.java | sed -n 2p)
  doc_bound=$(grep -oE '[0-9]+ rupees and above: SILVER' src/main/java/com/tiffinbox/Pricing.java \
              | grep -oE '^[0-9]+')
  [ -n "$code_bound" ] && [ -n "$doc_bound" ] || die "could not read both boundaries out of Pricing.java"
  printf 'the code branches on: %s ; the rule in the javadoc says: %s and above\n' \
    "$code_bound" "$doc_bound" >> .r-bug.out
  cat .r-bug.out
  rm -rf .fix .r-bug.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-bug.out)" "$rc"
}

run_unchanged() {
  block "unchanged - the coverage number before and after the bug is fixed"
  "${MVN[@]}" clean test > .r-unch.raw 2>&1; rc1=$?
  [ "$rc1" -eq 0 ] || die "the with-the-bug build exited $rc1 - no row to compare"
  before=$(csv_row Pricing target/site/jacoco/jacoco.csv)
  [ -n "$before" ] || die "the with-the-bug build produced no Pricing row"
  make_fix
  cp exercise/solution/Pricing.java     .fix/src/main/java/com/tiffinbox/Pricing.java
  cp exercise/solution/PricingTest.java .fix/src/test/java/com/tiffinbox/PricingTest.java
  ( cd .fix && mvn -B -Dmaven.repo.local="$REPO" clean test > ../.r-unch.raw 2>&1 ); rc2=$?
  [ "$rc2" -eq 0 ] || die "the bug-fixed build exited $rc2 - no row to compare"
  after=$(csv_row Pricing .fix/target/site/jacoco/jacoco.csv)
  [ -n "$after" ] || die "the bug-fixed build produced no Pricing row"
  # Only now, with two real rows in hand, is the comparison allowed to print.
  { printf 'with the bug : %s\n' "$before"
    printf 'bug fixed    : %s\n' "$after"
    printf 'the two rows are identical: %s\n' "$([ "$before" = "$after" ] && echo yes || echo no)"
  } > .r-unchanged.out
  cat .r-unchanged.out
  rm -rf .fix .r-unch.raw
  printf 'md5 %s  exit %s and %s\n' "$(hash_of .r-unchanged.out)" "$rc1" "$rc2"
}

pit_survivors() {   # $1 = mutations.xml
  python3 - "$1" <<'PY'
import re,sys
s=open(sys.argv[1]).read()
for m in re.finditer(r"<mutation detected='\w+' status='(\w+)'[^>]*>(.*?)</mutation>", s, re.S):
    st, body = m.group(1), m.group(2)
    if st != 'SURVIVED':
        continue
    ln = re.search(r'<lineNumber>(\d+)', body).group(1)
    d  = re.search(r'<description>(.*?)</description>', body).group(1)
    mu = re.search(r'<mutator>(.*?)</mutator>', body).group(1).split('.')[-1]
    print(f"SURVIVED  line {ln}  {d}  [{mu}]")
PY
}

run_mutants() {
  block "mutants - PIT over the same class, the same tests"
  "${MVN[@]}" test-compile org.pitest:pitest-maven:mutationCoverage > .r-pit.raw 2>&1; rc=$?
  [ "$rc" -eq 0 ] || die "mutationCoverage exited $rc"
  [ -f target/pit-reports/mutations.xml ] || die "PIT wrote no mutations.xml"
  grep -E '^>> (Generated [0-9]+ mutations|Mutations with no coverage|Line Coverage)' .r-pit.raw \
    > .r-mutants.out || die "PIT printed no >> statistics block"
  pit_survivors target/pit-reports/mutations.xml >> .r-mutants.out
  # DERIVED from the XML, not from the log above it
  gen=$(grep -c "<mutation detected=" target/pit-reports/mutations.xml)
  [ "$gen" -gt 0 ] || die "mutations.xml records no mutations"
  printf 'mutants generated %s, survived %s, killed %s\n' \
    "$gen" \
    "$(grep -c "status='SURVIVED'" target/pit-reports/mutations.xml)" \
    "$(grep -c "status='KILLED'" target/pit-reports/mutations.xml)" >> .r-mutants.out
  cat .r-mutants.out
  rm -f .r-pit.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-mutants.out)" "$rc"
}

run_ctor() {
  block "ctor - the line JaCoCo filters out of its own denominator"
  # Slide 5 puts a measurement on screen beside PIT's 6/8: "delete that constructor and JaCoCo
  # moves to 6/7". It was true and it was the one number on that slide no block derived, so a
  # wrong value there would have moved no hash. It is measured here, in both directions, out of
  # two jacoco.csv files this block itself wrote. Nothing below is typed.
  "${MVN[@]}" clean test > .r-ctor.raw 2>&1; rc1=$?
  [ "$rc1" -eq 0 ] || die "the as-shipped build exited $rc1 - there is no before row"
  before=$(require_row Pricing target/site/jacoco/jacoco.csv ctor) || exit 1
  make_fix
  # The constructor is found by pattern, never by line number, and the block dies if it is not
  # there exactly once - because a beat about a filtered constructor over a class that no
  # longer has one is not a measurement, it is a leftover.
  python3 - .fix/src/main/java/com/tiffinbox/Pricing.java <<'PY' \
    || die "Pricing.java does not carry exactly one empty private constructor - this beat is gone"
import re, sys
p = sys.argv[1]
s = open(p).read()
new, n = re.subn(r'\n[ \t]*private Pricing\(\) \{\n[ \t]*\}\n', '\n', s)
if n != 1:
    sys.exit(1)
open(p, 'w').write(new)
PY
  ( cd .fix && mvn -B -Dmaven.repo.local="$REPO" clean test > ../.r-ctor.raw 2>&1 ); rc2=$?
  [ "$rc2" -eq 0 ] || die "the constructor-removed build exited $rc2 - there is no after row"
  after=$(require_row Pricing .fix/target/site/jacoco/jacoco.csv ctor) || exit 1
  b_lines=$(pct "$(echo "$before" | cut -d, -f8)" "$(echo "$before" | cut -d, -f9)") \
    || die "the as-shipped row records no lines at all"
  a_lines=$(pct "$(echo "$after"  | cut -d, -f8)" "$(echo "$after"  | cut -d, -f9)") \
    || die "the constructor-removed row records no lines at all"
  b_tot=$(echo "$before" | awk -F, '{print $8+$9}'); b_cov=$(echo "$before" | awk -F, '{print $9}')
  a_tot=$(echo "$after"  | awk -F, '{print $8+$9}'); a_cov=$(echo "$after"  | awk -F, '{print $9}')
  # If deleting it does not move the denominator, JaCoCo is not filtering it and the sentence
  # on slide 5 is wrong. Say nothing rather than reprint a claim the run just contradicted.
  [ "$a_tot" -gt "$b_tot" ] \
    || die "deleting the private constructor left JaCoCo's line denominator at $b_tot - the filter beat is gone"
  { printf 'as shipped, private constructor present : lines %s\n' "$b_lines"
    printf 'the same project, that constructor gone : lines %s\n' "$a_lines"
    printf 'lines JaCoCo counted: %s -> %s ; lines it called covered: %s -> %s\n' \
      "$b_tot" "$a_tot" "$b_cov" "$a_cov"
  } > .r-ctor.out
  cat .r-ctor.out
  rm -rf .fix .r-ctor.raw
  printf 'md5 %s  exit %s and %s\n' "$(hash_of .r-ctor.out)" "$rc1" "$rc2"
}

run_naive() {
  block "naive - argLine without @{argLine}"
  ( cd breaks/naive-argline && rm -rf target \
      && mvn -B -Dmaven.repo.local="$REPO" test > ../../.r-naive.raw 2>&1 ); rc=$?
  # The whole lesson is that this build SUCCEEDS. If it ever stops succeeding, the lesson
  # is gone and the block must not pretend otherwise.
  [ "$rc" -eq 0 ] || die "the naive build exited $rc - the point of it is that it is green"
  grep -E '^\[INFO\] --- |^\[INFO\] Skipping JaCoCo|^\[INFO\] Tests run:|^\[INFO\] BUILD' .r-naive.raw \
    | clean > .r-naive.out
  [ -s .r-naive.out ] || die "nothing matched the naive filter"
  # DERIVED: goals that ran, tests that passed, and the artifact that does not exist
  tests=$(awk -F'[:,]' '/^\[INFO\] Tests run:/{print $2+0; exit}' .r-naive.out)
  [ -n "$tests" ] && [ "$tests" -gt 0 ] || die "the naive build ran $tests tests - nothing was proved green"
  printf '%s goals ran; %s tests green; jacoco.exec exists: %s; files under target/site: %s\n' \
    "$(grep -c '^\[INFO\] --- ' .r-naive.out)" \
    "$tests" \
    "$([ -f breaks/naive-argline/target/jacoco.exec ] && echo yes || echo no)" \
    "$(find breaks/naive-argline/target/site -type f 2>/dev/null | wc -l | tr -d ' ')" >> .r-naive.out
  { printf 'the argLine each pom declares:\n'
    printf '  this unit      %s\n' "$(grep -oE '<argLine>.*</argLine>' pom.xml)"
    printf '  the break      %s\n' "$(grep -oE '<argLine>.*</argLine>' breaks/naive-argline/pom.xml)"
    printf '  poms whose argLine carries the @{argLine} token: %s of 2\n' \
      "$(grep -lE '<argLine>@\{argLine\}' pom.xml breaks/naive-argline/pom.xml | wc -l | tr -d ' ')"
  } >> .r-naive.out
  cat .r-naive.out
  rm -f .r-naive.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-naive.out)" "$rc"
}

run_solution() {
  block "solution - the exercise answer, actually run"
  rm -rf .sol && cp -R exercise .sol && rm -rf .sol/solution .sol/target
  cp exercise/solution/Pricing.java     .sol/src/main/java/com/tiffinbox/Pricing.java
  cp exercise/solution/PricingTest.java .sol/src/test/java/com/tiffinbox/PricingTest.java
  ( cd .sol && mvn -B -Dmaven.repo.local="$REPO" clean test > test.raw 2>&1 ); rc1=$?
  [ "$rc1" -eq 0 ] || die "the answer's tests exited $rc1 - the answer does not pass"
  ( cd .sol && mvn -B -Dmaven.repo.local="$REPO" \
      test-compile org.pitest:pitest-maven:mutationCoverage > pit.raw 2>&1 ); rc2=$?
  [ "$rc2" -eq 0 ] || die "the answer's mutationCoverage exited $rc2"
  { grep -E '^\[INFO\] Tests run: [0-9]+, Failures' .sol/test.raw | tail -1
    grep -E '^>> Generated [0-9]+ mutations' .sol/pit.raw
    pit_survivors .sol/target/pit-reports/mutations.xml
  } | clean > .r-solution.out
  [ -s .r-solution.out ] || die "the answer produced no summary and no mutation report"
  # DERIVED: why the last survivor cannot be killed through a Customer.
  # Nothing below is typed. The line number comes out of the report just printed; the
  # threshold is read off THAT line of the Pricing.java that was compiled; the multiplier
  # is read out of the Customer.java that was compiled beside it. Change either source and
  # this arithmetic changes with it.
  sline=$(awk '/^SURVIVED  line /{print $3; exit}' .r-solution.out)
  [ -n "$sline" ] || die "the answer left no SURVIVED mutant - the equivalent-mutant beat is gone"
  gold=$(sed -n "${sline}p" .sol/src/main/java/com/tiffinbox/Pricing.java \
         | grep -oE '[0-9][0-9_]*' | head -1 | tr -d '_')
  mult=$(grep -oE 'mealsPerDay \* pricePerMeal \* [0-9][0-9_]*' \
           .sol/src/main/java/com/tiffinbox/Customer.java \
         | grep -oE '[0-9][0-9_]*$' | tr -d '_')
  [ -n "$gold" ] && [ -n "$mult" ] \
    || die "could not read the threshold off Pricing.java line $sline, or the multiplier off Customer.java"
  printf 'the survivor sits on Pricing.java line %s, which reads: %s\n' \
    "$sline" "$(sed -n "${sline}p" .sol/src/main/java/com/tiffinbox/Pricing.java | sed 's/^ *//')" \
    >> .r-solution.out
  printf 'every monthlyBill is meals x price x %s, so it is a multiple of %s; %s mod %s = %s\n' \
    "$mult" "$mult" "$gold" "$mult" \
    "$(awk -v g="$gold" -v m="$mult" 'BEGIN{print g%m}')" >> .r-solution.out
  printf 'the surviving boundary is reachable by a Customer: %s\n' \
    "$(awk -v g="$gold" -v m="$mult" 'BEGIN{print (g%m==0) ? "yes" : "no"}')" >> .r-solution.out
  cat .r-solution.out
  rm -rf .sol
  printf 'md5 %s  exit %s and %s\n' "$(hash_of .r-solution.out)" "$rc1" "$rc2"
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

ALL=(coverage scope bug unchanged mutants ctor naive solution offline)
TARGETS=("$@")
[ ${#TARGETS[@]} -eq 0 ] && TARGETS=("${ALL[@]}")
for t in "${TARGETS[@]}"; do "run_$t"; done
