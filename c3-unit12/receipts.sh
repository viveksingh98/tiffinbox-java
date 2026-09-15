#!/bin/bash
# receipts.sh - regenerate every number this unit puts on a slide.
#
# The rule this file exists to enforce: a count on a slide is DERIVED by the same run that
# produced the capture above it. Nothing here echoes a number a human typed. Every "N of M"
# below is a grep -c or a wc -l over the output of the command printed just above it.
#
#   ./receipts.sh            run every block
#   ./receipts.sh cases      run one block
#
# Three rules every receipts.sh in this section now follows:
#
#   1. A DERIVED LINE IS PART OF THE CAPTURE - it is appended to the .out file before that
#      file is hashed, so the md5 on a slide covers the number on the slide.
#   2. EVERY MAVEN RUN RECORDS ITS EXIT CODE, printed beside the md5 (contract 8.5).
#   3. A BLOCK THAT COULD NOT MEASURE CALLS die(). The `names` block in particular used to
#      print "console: 0 of 0" if the break project failed to build, which reads as a
#      finding and is actually a missing build.
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
block()   { BLOCK="${1%% *}"; printf '\n=== %s ===\n' "$1"; }
# a javadoc that NAMES an annotation is not a use of it - the exercise's TODO comment says
# "@CsvSource" in prose, and counting it would have said the starting test already had one
code() { grep -hvE '^[[:space:]]*(\*|//|/\*)' "$@"; }

# Time elapsed: rides on EVERY surefire "Tests run:" line and moves every run. Strip it
# before anything is hashed, together with every absolute path.
clean() { sed -E -e 's/, Time elapsed: [0-9.]+ s//' -e 's/ -- Time elapsed: [0-9.]+ s//' \
                 -e "s#${PWD}/#<project>/#g" \
                 -e 's#[^ ]*/c3-unit12/#<project>/#g' \
                 -e 's#/Users/[^/]*/#<home>/#g'; }

run_cases() {
  block "cases - three case sources, and what the runner counted"
  "${MVN[@]}" test > .r-cases.raw 2>&1; rc=$?
  [ "$rc" -eq 0 ] || die "mvn test exited $rc - this unit's own suite is not green"
  grep -E '^\[INFO\] (Running com|Tests run:)' .r-cases.raw | clean > .r-cases.out
  [ -s .r-cases.out ] || die "no Running/Tests run: lines in the run"
  # DERIVED: the case count on the report, against the test METHODS in the source tree.
  printf '%s test methods in src/test/java; %s cases on the report\n' \
    "$(grep -rhcE '^\s+(@Test|@ParameterizedTest|@TestFactory)' src/test/java/com/tiffinbox/*.java \
        | paste -sd+ - | bc)" \
    "$(grep -E '^\[INFO\] Tests run:' .r-cases.out | tail -1 | sed -E 's/.*Tests run: ([0-9]+).*/\1/')" \
    >> .r-cases.out
  cat .r-cases.out
  rm -f .r-cases.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-cases.out)" "$rc"
}

run_names() {
  block "names - the console throws the case name away; the XML report does not"
  N=breaks/name-thrown-away
  ( cd "$N" && rm -rf target \
      && mvn -B -Dmaven.repo.local="$REPO" test > ../../.r-names.raw 2>&1 ); rc=$?
  [ "$rc" -ne 0 ] || die "$N passed - row 4 is supposed to be wrong in both methods"
  XML="$N/target/surefire-reports/TEST-com.tiffinbox.NamedCasesTest.xml"
  [ -f "$XML" ] || die "surefire wrote no XML report for NamedCasesTest"
  {
    echo '--- surefire CONSOLE, no reporter configured, both methods failing on case 4 ---'
    grep -E '^\[ERROR\] com\.tiffinbox\.NamedCasesTest' .r-names.raw
    echo '--- and the same run Results: summary, which drops the case index too ---'
    sed -n '/^\[ERROR\] Failures:/,/^\[ERROR\] Tests run:/p' .r-names.raw \
      | grep -E '^\[ERROR\]   NamedCasesTest|^\[ERROR\] Tests run:'
    echo '--- the same run XML: target/surefire-reports/TEST-com.tiffinbox.NamedCasesTest.xml ---'
    grep -oE 'testcase name="[^"]*"' "$XML" | grep '\[4\]'
  } | clean > .r-names.out
  "${MVN[@]}" test > .r-names2.raw 2>&1; rc2=$?
  [ "$rc2" -eq 0 ] || die "this unit's own suite exited $rc2 - no XML to compare against"
  MINE=target/surefire-reports/TEST-com.tiffinbox.DisplayNameTest.xml
  [ -f "$MINE" ] || die "surefire wrote no XML report for DisplayNameTest"
  {
    # The header NAMES the file, because it is a different file in a different project from a
    # second build - the reporter block is a POM difference, so the two states cannot come from
    # one build of one project, and a slide that implies they do is asserting something false.
    echo '--- this project XML: TEST-com.tiffinbox.DisplayNameTest.xml, with the reporter block ---'
    grep -oE 'testcase name="[^"]*"' "$MINE" | sed -n '4p;8p'
  } >> .r-names.out
  # DERIVED: a name "carries the arguments" iff the quoted values are in it. Counted, not
  # claimed - and every denominator is asserted non-zero first, because "0 of 0" is not a
  # finding, it is a build that did not happen.
  #
  # ONE detector for all four halves: does the name contain a quoted argument value? That is a
  # bare " on the console and the same character escaped as &quot; in the XML. An earlier draft
  # asked the console half `grep -c 'meals x'` - which is namedPattern's OWN wording. Phrased,
  # defaultName reads  [4] "1", "120", "9999"  and carries no "meals x" at all, so half of that
  # denominator could never have incremented and the 0 it printed could not have moved. Both
  # detectors are PROVEN TO FIRE below before any count they produce is trusted: a check that
  # cannot fail is not a check, and a 0 is only a finding if a 1 was reachable.
  ARGS='"'        # console: a quoted argument value, as surefire would print one
  XARGS='quot;'   # XML: the same character, escaped by the reporter
  console_all=$(grep -c '^\[ERROR\] com\.tiffinbox\.NamedCasesTest' .r-names.out)
  console_named=$(grep '^\[ERROR\] com\.tiffinbox\.NamedCasesTest' .r-names.out | grep -cF "$ARGS" || true)
  summary_all=$(grep -c '^\[ERROR\]   NamedCasesTest' .r-names.out)
  summary_idx=$(grep '^\[ERROR\]   NamedCasesTest' .r-names.out | grep -c '\[4\]' || true)
  plain_all=$(grep -c 'testcase name=' "$XML")
  plain_named=$(grep -o 'testcase name="[^"]*"' "$XML" | grep -cF "$XARGS" || true)
  fixed_all=$(grep -c 'testcase name=' "$MINE")
  fixed_named=$(grep -o 'testcase name="[^"]*"' "$MINE" | grep -cF "$XARGS" || true)
  for n in "$console_all" "$summary_all" "$plain_all" "$fixed_all"; do
    [ "$n" -gt 0 ] || die "one of the four denominators is zero - a build did not run"
  done
  # FALSIFIABILITY PROBES. The case-index detector is proven on this run's own console lines,
  # which do carry [4]. The quoted-value detector is proven on the phrased form of BOTH
  # methods - what surefire would print if it ever phrased a console name - and both must
  # match, so a detector that only understands one method's wording kills the receipt here
  # rather than printing a 0 onto a slide.
  grep '^\[ERROR\] com\.tiffinbox\.NamedCasesTest' .r-names.out | grep -q '\[4\]' \
    || die "the case-index detector cannot match [4] - the summary counts are blind"
  printf '%s\n%s\n' \
    'defaultName(int, int, int)[4] "1", "120", "9999"' \
    'namedPattern(int, int, int) "1" meals x "120" rupees -> "9999"' \
    | grep -cF "$ARGS" | grep -qx 2 \
    || die "the quoted-value detector cannot match a phrased name - the console count is blind"
  { printf 'console: %s of %s failure lines carry the arguments\n' "$console_named" "$console_all"
    printf 'Results: summary: %s of %s lines carry even the case index [4]\n' "$summary_idx" "$summary_all"
    printf 'XML without the reporter: %s of %s names carry them\n' "$plain_named" "$plain_all"
    printf 'XML with the reporter:    %s of %s names carry them\n' "$fixed_named" "$fixed_all"
  } >> .r-names.out
  cat .r-names.out
  rm -f .r-names.raw .r-names2.raw
  printf 'md5 %s  exit %s then %s\n' "$(hash_of .r-names.out)" "$rc" "$rc2"
}

run_plain() {
  block "plain - the console under the plain report format, without and WITH the reporter block"
  N=breaks/name-thrown-away
  ( cd "$N" && rm -rf target \
      && mvn -B -Dmaven.repo.local="$REPO" -Dsurefire.reportFormat=plain -Dsurefire.useFile=false test \
         > ../../.r-plain1.raw 2>&1 ); rc1=$?
  [ "$rc1" -ne 0 ] || die "$N passed - row 4 is supposed to be wrong in both methods"
  rm -rf target
  "${MVN[@]}" -Dsurefire.reportFormat=plain -Dsurefire.useFile=false test > .r-plain2.raw 2>&1; rc2=$?
  [ "$rc2" -eq 0 ] || die "this project exited $rc2 under the plain report format"
  MINE=target/surefire-reports/TEST-com.tiffinbox.DisplayNameTest.xml
  [ -f "$MINE" ] || die "surefire wrote no XML report for DisplayNameTest - useFile=false must not suppress it"
  {
    echo '--- plain console, breaks/name-thrown-away (no reporter block): EVERY case, not only the failures ---'
    grep -E '^\[ERROR\] com\.tiffinbox\.NamedCasesTest\.' .r-plain1.raw
    echo '--- plain console, this project - the same build whose XML carries the phrased names ---'
    grep -E '^\[INFO\] com\.tiffinbox\.DisplayNameTest\.' .r-plain2.raw
  } | clean > .r-plain.out
  [ -s .r-plain.out ] || die "the plain format printed no per-case console lines at all"
  # DERIVED. Two detectors, and the zero half of each is only a finding if a one was reachable:
  #   index    - does the console line end the signature with a case index, (int, int, int)[N]
  #   argument - does the name carry a quoted argument value: a bare " on the console, &quot; in XML
  # The argument detector is PROVEN TO FIRE on the second project's own XML in the SAME build whose
  # console is counted three lines below - so "0 on the console, 8 in the XML" is one build's two
  # outputs, not two runs, and a blind detector kills the receipt instead of printing a 0.
  IDX='\([^)]*\)\[[0-9][0-9]*\]'   # a signature immediately followed by a case index
  CQ='"'                          # console: a quoted argument value, as surefire would print one
  QV='quot;'                      # XML: the same character, escaped by the reporter
  off_all=$(grep -c '^\[ERROR\] com\.tiffinbox\.NamedCasesTest\.' .r-plain.out)
  off_idx=$(grep '^\[ERROR\] com\.tiffinbox\.NamedCasesTest\.' .r-plain.out | grep -cE "$IDX" || true)
  off_arg=$(grep '^\[ERROR\] com\.tiffinbox\.NamedCasesTest\.' .r-plain.out | grep -cF "$CQ" || true)
  on_all=$(grep -c '^\[INFO\] com\.tiffinbox\.DisplayNameTest\.' .r-plain.out)
  on_idx=$(grep '^\[INFO\] com\.tiffinbox\.DisplayNameTest\.' .r-plain.out | grep -cE "$IDX" || true)
  on_arg=$(grep '^\[INFO\] com\.tiffinbox\.DisplayNameTest\.' .r-plain.out | grep -cF "$CQ" || true)
  xml_all=$(grep -c 'testcase name=' "$MINE")
  xml_arg=$(grep -o 'testcase name="[^"]*"' "$MINE" | grep -cF "$QV" || true)
  for n in "$off_all" "$on_all" "$xml_all"; do
    [ "$n" -gt 0 ] || die "one of the three denominators is zero - a build did not run"
  done
  [ "$xml_arg" -gt 0 ] \
    || die "the argument detector did not fire on the reporter-enabled XML - the two console zeros are blind"
  # The XML probe above proves &quot; fires. It does NOT prove the console's own detector fires,
  # because that one looks for a bare " - a different literal. Prove it the way the names block
  # does: against the phrased form of BOTH methods, which is what a console line would look like
  # if surefire ever carried one. Both must match, or a one-method-shaped detector dies here.
  printf '%s\n%s\n' \
    'com.tiffinbox.DisplayNameTest.defaultName(int, int, int)[4] "1", "120", "3600"' \
    'com.tiffinbox.DisplayNameTest.namedPattern(int, int, int) "1" meals x "120" rupees -> "3600"' \
    | grep -cF "$CQ" | grep -qx 2 \
    || die "the console argument detector cannot match a phrased name - both console zeros are blind"
  { printf 'plain console, no reporter block: %s of %s case lines carry the index [N]; %s of %s carry an argument value\n' \
      "$off_idx" "$off_all" "$off_arg" "$off_all"
    printf 'plain console, reporter block ON: %s of %s case lines carry the index [N]; %s of %s carry an argument value\n' \
      "$on_idx" "$on_all" "$on_arg" "$on_all"
    printf 'the SAME build XML, reporter block ON: %s of %s testcase name= values carry an argument value\n' \
      "$xml_arg" "$xml_all"
  } >> .r-plain.out
  cat .r-plain.out
  rm -f .r-plain1.raw .r-plain2.raw
  printf 'md5 %s  exit %s then %s\n' "$(hash_of .r-plain.out)" "$rc1" "$rc2"
}

run_break() {
  block "break - one loop vs five cases, over the same five rows and the same bug"
  ( cd breaks/loop-in-a-test && rm -rf target \
      && mvn -B -Dmaven.repo.local="$REPO" test > ../../.r-break.raw 2>&1 ); rc=$?
  [ "$rc" -ne 0 ] || die "breaks/loop-in-a-test passed - there is no failure report to compare"
  sed -n '/^\[INFO\] Results:/,/^\[ERROR\] Tests run:/p' .r-break.raw | clean > .r-break.out
  [ -s .r-break.out ] || die "no Results: block - the break did not compile"
  # DERIVED: failures named per style, counted out of the same report.
  printf 'the loop named %s failing row(s); five cases named %s\n' \
    "$(grep -c 'LoopOverTheTableTest' .r-break.out)" \
    "$(grep -c 'OneCaseEachTest' .r-break.out)" >> .r-break.out
  cat .r-break.out
  rm -f .r-break.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-break.out)" "$rc"
}

# One assertAll variant, run in a COPY of the break project with that variant as the only test
# class. The shipped break project keeps exactly the two classes slide 2 compares, so neither
# `./receipts.sh break` nor its md5 moves because these receipts exist.
aa_run() {
  rm -rf .assertall && cp -R "$L" .assertall && rm -rf .assertall/target .assertall/variants
  rm -f .assertall/src/test/java/com/tiffinbox/*.java
  cp "$L/variants/$1.java" .assertall/src/test/java/com/tiffinbox/
  [ "$(ls .assertall/src/test/java/com/tiffinbox/*.java | wc -l | tr -d ' ')" = "1" ] \
    || die "$1 is not the only test class in the copy - the counts below would be over two classes"
  ( cd .assertall && mvn -B -Dmaven.repo.local="$REPO" test > "../.r-$1.raw" 2>&1 ); AA_RC=$?
  [ "$AA_RC" -ne 0 ] || die "$1 passed - the 31-day bug is gone and there is nothing to count"
  sed -n '/^\[INFO\] Results:/,/^\[ERROR\] Tests run:/p' ".r-$1.raw" | clean
  rm -rf .assertall ".r-$1.raw"
}

run_assertall() {
  block "assertall - the previous unit's answer applied to this loop, both placements"
  L=breaks/loop-in-a-test
  { echo '--- assertAll HOISTED OUT of the loop, one Executable per row ---'
    aa_run AssertAllOverTheTableTest; rc1=$AA_RC
    echo '--- the same assertAll wrapped round the loop BODY ---'
    aa_run AssertAllRoundTheBodyTest;  rc2=$AA_RC
  } > .r-assertall.out
  [ -s .r-assertall.out ] || die "no Results: block - a variant did not compile"
  # DERIVED: rows named inside the one case, per placement, against the count each run reported.
  # The row counts differ and the Tests run: counts do not - and that pair IS the beat: assertAll
  # changes the message, never the count. Each half is counted inside its own section of the file,
  # so a placement that stopped producing output cannot borrow the other one's number.
  hoisted=$(sed -n '/HOISTED OUT/,/round the loop BODY/p' .r-assertall.out | grep -c 'AssertionFailedError: expected:')
  body=$(sed -n '/round the loop BODY/,$p' .r-assertall.out | grep -c 'AssertionFailedError: expected:')
  runs=$(grep -cE '^\[ERROR\] Tests run: 1, Failures: 1,' .r-assertall.out)
  [ "$hoisted" -gt 0 ] && [ "$body" -gt 0 ] \
    || die "one of the two placements named no rows at all - that is a missing run, not a finding"
  [ "$runs" -eq 2 ] \
    || die "expected both placements to report Tests run: 1, Failures: 1 - got $runs such summaries"
  printf 'assertAll hoisted out of the loop named %s row(s); wrapped round the loop body, %s; both runs counted Tests run: 1, Failures: 1\n' \
    "$hoisted" "$body" >> .r-assertall.out
  cat .r-assertall.out
  printf 'md5 %s  exit %s then %s\n' "$(hash_of .r-assertall.out)" "$rc1" "$rc2"
}

run_zero() {
  block "zero - a case source with nothing in it, both ways"
  Z=breaks/zero-cases
  ( cd "$Z" && rm -rf target \
      && mvn -B -Dmaven.repo.local="$REPO" test > ../../.r-zero1.raw 2>&1 ); rc1=$?
  [ "$rc1" -eq 0 ] || die "$Z with allowZeroInvocations exited $rc1 - it is supposed to be green"
  grep -E '^\[INFO\] Tests run:|^\[INFO\] BUILD' .r-zero1.raw | clean > .r-zero.out
  # now the same project with the switch taken back out
  rm -rf .zero-strict && cp -R "$Z" .zero-strict && rm -rf .zero-strict/target
  sed -i '' 's/@ParameterizedTest(allowZeroInvocations = true)/@ParameterizedTest/' \
    .zero-strict/src/test/java/com/tiffinbox/EmptySourceTest.java
  grep -q '@ParameterizedTest$' .zero-strict/src/test/java/com/tiffinbox/EmptySourceTest.java \
    || die "the allowZeroInvocations sed did not apply"
  ( cd .zero-strict && mvn -B -Dmaven.repo.local="$REPO" test > ../.r-zero2.raw 2>&1 ); rc2=$?
  [ "$rc2" -ne 0 ] || die "a zero-case @ParameterizedTest without the switch passed - the finding is gone"
  # No cosmetic filter here, on purpose. An earlier draft piped this through
  #   sed -E 's/^\[ERROR\]   [A-Za-z]+\.[a-zA-Z]+\(String\) » //'
  # to shorten surefire's summary line. That sed is anchored on a (String) signature and the
  # method it targets is heldPlansStillBillCorrectly(Customer, int), so it never fired once -
  # the line went into the hashed file untouched while the slide above it was drawn as if the
  # line were not there. A filter that silently matches nothing is the same hazard as a check
  # that cannot fail. The five lines this grep returns are the five lines the slide shows.
  grep -E 'Configuration error|^\[ERROR\] Tests run:|^\[INFO\] BUILD' .r-zero2.raw | clean >> .r-zero.out
  # DERIVED: methods in the file, against what each run counted.
  printf 'the file declares %s test methods; with the switch on the runner counted %s; with it off, %s\n' \
    "$(grep -cE '^\s+@(Test|ParameterizedTest)' "$Z/src/test/java/com/tiffinbox/EmptySourceTest.java")" \
    "$(grep -E '^\[INFO\] Tests run:' .r-zero.out | head -1 | sed -E 's/.*Tests run: ([0-9]+).*/\1/')" \
    "$(grep -E '^\[ERROR\] Tests run:' .r-zero.out | head -1 | sed -E 's/.*Tests run: ([0-9]+).*/\1/')" \
    >> .r-zero.out
  cat .r-zero.out
  rm -rf .zero-strict .r-zero1.raw .r-zero2.raw
  printf 'md5 %s  exit %s then %s\n' "$(hash_of .r-zero.out)" "$rc1" "$rc2"
}

# Read the LAST "Tests run:" summary out of ONE state's own raw log. Never out of the joined
# .out file: head -1/tail -1 over a concatenation silently reads the other state's number when
# one state prints nothing, which is how a failed starting build got its case count reported as
# the answer's. One argument, one state, one file.
count_in() { grep -E '^\[INFO\] Tests run:' "$1" | tail -1 | sed -E 's/.*Tests run: ([0-9]+).*/\1/'; }

run_solution() {
  block "solution - the exercise, before and after, actually run"
  ( cd exercise && rm -rf target \
      && mvn -B -Dmaven.repo.local="$REPO" test > ../.r-sol1.raw 2>&1 ); rc1=$?
  # The STARTING state is green on purpose - one method, one case, Tests run: 1. If it did not
  # build, there is no starting count to compare and the block must stop here rather than print
  # the answer's number in the starting number's place.
  [ "$rc1" -eq 0 ] || die "the exercise starting state exited $rc1 - it is supposed to be green at Tests run: 1"
  grep -E '^\[INFO\] Tests run:|^\[INFO\] BUILD' .r-sol1.raw | clean > .r-solution.out
  rm -rf .sol && cp -R exercise .sol && rm -rf .sol/solution .sol/target
  cp exercise/solution/PlanTableTest.java .sol/src/test/java/com/tiffinbox/PlanTableTest.java
  ( cd .sol && mvn -B -Dmaven.repo.local="$REPO" test > ../.r-sol2.raw 2>&1 ); rc2=$?
  [ "$rc2" -eq 0 ] || die "the exercise answer exited $rc2 - it does not pass"
  grep -E '^\[INFO\] Tests run:|^\[INFO\] BUILD' .r-sol2.raw | clean >> .r-solution.out
  [ -s .r-solution.out ] || die "neither state printed a Tests run: line"
  SOL_BEFORE=$(count_in .r-sol1.raw); SOL_AFTER=$(count_in .r-sol2.raw)
  [ -n "$SOL_BEFORE" ] && [ -n "$SOL_AFTER" ] || die "one of the two states printed no Tests run: summary"
  # DERIVED: the answer turns one method into a table of cases. Both annotation counts are
  # taken over CODE lines only, and each case count off THAT state's own run.
  printf 'the same five rows: the starting test declares %s case-source annotation(s) and the runner counted %s case(s); the answer declares %s and the runner counted %s\n' \
    "$(code exercise/src/test/java/com/tiffinbox/PlanTableTest.java | grep -cE '@(CsvSource|MethodSource|TestFactory)')" \
    "$SOL_BEFORE" \
    "$(code exercise/solution/PlanTableTest.java | grep -cE '@(CsvSource|MethodSource|TestFactory)')" \
    "$SOL_AFTER" \
    >> .r-solution.out
  cat .r-solution.out
  rm -rf .sol .r-sol1.raw .r-sol2.raw
  printf 'md5 %s  exit %s then %s\n' "$(hash_of .r-solution.out)" "$rc1" "$rc2"
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

ALL=(cases names plain break assertall zero solution offline)
TARGETS=("$@")
[ ${#TARGETS[@]} -eq 0 ] && TARGETS=("${ALL[@]}")
for t in "${TARGETS[@]}"; do "run_$t"; done
