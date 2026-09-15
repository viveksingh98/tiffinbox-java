#!/bin/bash
# receipts.sh - regenerate every number this unit puts on a slide.
#
# Every count below is DERIVED by the same run that produced the capture above it: a grep -c
# over that run's own output, or a wc -l over the block just printed. Nothing echoes a literal.
#
#   ./receipts.sh            run every block
#   ./receipts.sh warn       run one block
#
# Three rules every receipts.sh in this section now follows:
#
#   1. A DERIVED LINE IS PART OF THE CAPTURE - appended to the .out file before it is
#      hashed, so the md5 on a slide covers the number on the slide.
#   2. EVERY MAVEN RUN RECORDS ITS EXIT CODE, printed beside the md5 (contract 8.5).
#   3. A DEMONSTRATION THAT DID NOT FIRE MUST SAY SO. `spacetrap` asserts that the
#      unquoted argLine really did kill the fork before it prints the contrast, and it
#      asserts it on surefire's OWN evidence - the dead fork and the command line showing
#      the agent path split at the space - not on a line the forked JVM writes on another
#      stream and occasionally loses.
#   4. A COUNT ABOUT A RUN IS TAKEN FROM A RUN. `break` used to say how many of the green
#      tests "asserted on the amount" by grepping the source for `capture()`; that counted
#      a captor - and a comment - rather than an assertion, in both directions. It now
#      RE-RUNS the green class against a service charging a third wrong amount and reports
#      how many of its tests noticed.
#   5. ONE BAD BLOCK DOES NOT TRUNCATE THE RUN. Each block runs in its own subshell, so a
#      failed guard skips that block and the later blocks - whose hashes are on slides -
#      still run. The script's own exit code is non-zero if any block failed.
#
# Isolated: -Dmaven.repo.local="$PWD/.m2-demo" (quoted - this tree's path can contain a space).

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
strip_time() { sed -E 's/, Time elapsed: [0-9.]+ s//; s/ -- Time elapsed: [0-9.]+ s//'; }
# An agent line carries an absolute path that moves with the clone. Mask the directory; KEEP
# the jar's version number, because the version is the evidence (contract 8.6).
mask_jar() { sed -E 's|\((file:)?/[^)]*/([^/)]*\.jar)\)|(<repo>/\2)|; s|-javaagent:"?/[^" ]*/([^/" ]*\.jar)"?|-javaagent:<repo>/\1|'; }

run_doubles() {
  block "doubles - four written by hand, one written by the framework"
  "${MVN[@]}" test > .r-doubles.raw 2>&1; rc=$?
  [ "$rc" -eq 0 ] || die "mvn test exited $rc - this unit's own suite is not green"
  grep -E '^\[INFO\] (Running com|Tests run:)' .r-doubles.raw | strip_time > .r-doubles.out
  [ -s .r-doubles.out ] || die "no Running/Tests run: lines in the run"
  # DERIVED: the four hand-written doubles are four classes in one file; count them there,
  # and count the tests that exercised them out of the run above.
  hand=$(grep -cE '^    static final class [A-Za-z]+Gateway implements PaymentGateway' \
          src/test/java/com/tiffinbox/billing/HandWrittenDoublesTest.java)
  exercised=$(grep '^\[INFO\] Tests run:.*HandWrittenDoublesTest$' .r-doubles.out \
          | sed -E 's/.*Tests run: ([0-9]+).*/\1/')
  mockito=$(grep '^\[INFO\] Tests run:.*MockitoBasicsTest$' .r-doubles.out \
          | sed -E 's/.*Tests run: ([0-9]+).*/\1/')
  [ -n "$exercised" ] && [ -n "$mockito" ] \
    || die "one of the two classes is missing from the report - the comparison has no denominator"
  printf '%s hand-written doubles in HandWrittenDoublesTest.java, exercised by %s tests\n' \
    "$hand" "$exercised" >> .r-doubles.out
  printf '%s Mockito tests beside them\n' "$mockito" >> .r-doubles.out
  # DERIVED: the comparison slide 3 makes - the hand-written stub CLASS against the one
  # line the framework needs for the same job. Both counted here, in the bytes the hash
  # covers, so a wrong number on that caption moves this md5.
  stub_lines=$(awk '/^    static final class StubGateway implements PaymentGateway \{$/{f=1} f{n++} f&&/^    \}$/{print n; exit}' \
          src/test/java/com/tiffinbox/billing/HandWrittenDoublesTest.java)
  stub_half=$(grep -cE '^        when\(gateway\.charge' \
          src/test/java/com/tiffinbox/billing/MockitoBasicsTest.java)
  [ -n "$stub_lines" ] && [ "$stub_lines" -gt 0 ] && [ "$stub_half" -gt 0 ] \
    || die "the StubGateway class block or the when(...) line moved - the comparison has no numbers"
  printf 'hand-written StubGateway: %s lines. the framework stubs the same call in %s.\n' \
    "$stub_lines" "$stub_half" >> .r-doubles.out
  cat .r-doubles.out
  rm -f .r-doubles.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-doubles.out)" "$rc"
}

run_warn() {
  block "warn - six lines became one, and here is the one that stayed"
  # BEFORE: the same project with everything between the two STATIC-AGENT markers removed.
  rm -rf .noagent && mkdir .noagent && cp -R src .noagent/src
  sed '/STATIC-AGENT-BEGIN/,/STATIC-AGENT-END/d' pom.xml > .noagent/pom.xml
  grep -q '<argLine>' .noagent/pom.xml \
    && die "the STATIC-AGENT markers no longer bracket the argLine - the before state still has the agent"
  # The JVM writes the "Sharing is only supported..." line on a different stream from the
  # other five, so its POSITION in the interleaved capture moves between runs. Two greps,
  # so that line always lands last and the block is hashable. Named filter, contract 8.5.
  ( cd .noagent && mvn -B -Dmaven.repo.local="$REPO" test > ../.r-warn-raw.out 2>&1 ); rc1=$?
  [ "$rc1" -eq 0 ] || die "the no-agent build exited $rc1 - the before state is not a passing build"
  sf_before=$(grep -oE 'surefire:[0-9.]+:test' .r-warn-raw.out | head -1 | sed -E 's/surefire:(.*):test/\1/')
  {
    echo '--- before: mockito attaches its own agent at run time ---'
    grep -E '^Mockito is currently|^WARNING:' .r-warn-raw.out | mask_jar
    grep -E '^OpenJDK 64-Bit' .r-warn-raw.out
  } > .r-warn-before.out
  before=$(grep -cE '^Mockito is currently|^OpenJDK 64-Bit|^WARNING:' .r-warn-before.out)
  [ "$before" -gt 0 ] || die "the before state printed no warning lines at all"
  "${MVN[@]}" test > .r-warn-raw.out 2>&1; rc2=$?
  [ "$rc2" -eq 0 ] || die "the with-agent build exited $rc2"
  # The two runs must differ by the two taught blocks and by NOTHING else. Surefire's own
  # version is pinned in pluginManagement, outside the markers, exactly so that deleting the
  # marker region cannot change the plugin that forks the test JVM. Prove it, every run.
  sf_after=$(grep -oE 'surefire:[0-9.]+:test' .r-warn-raw.out | head -1 | sed -E 's/surefire:(.*):test/\1/')
  [ -n "$sf_before" ] && [ "$sf_before" = "$sf_after" ] \
    || die "before forked surefire '$sf_before', after forked '$sf_after' - the contrast is not about the agent"
  {
    echo '--- after: mockito-core declared as a static -javaagent ---'
    grep -E '^Mockito is currently|^WARNING:' .r-warn-raw.out | mask_jar
    grep -E '^OpenJDK 64-Bit' .r-warn-raw.out
  } > .r-warn-after.out
  after=$(grep -cE '^Mockito is currently|^OpenJDK 64-Bit|^WARNING:' .r-warn-after.out)
  # And the surviving line is not a dynamic-agent warning at all - prove that by name, over
  # the captured line itself rather than over the header this script printed above it.
  agent_hits=$(grep -v '^---' .r-warn-after.out | grep -ci 'agent' || true)
  sharing_hits=$(grep -v '^---' .r-warn-after.out | grep -ci 'Sharing' || true)
  # DERIVED from the two runs above, not from anything typed here. The count goes into BOTH
  # files, so each hash covers the number the slide beside it shows.
  printf 'before: %s lines. after: %s.\n' "$before" "$after" >> .r-warn-before.out
  printf 'before: %s lines. after: %s.\n' "$before" "$after" >> .r-warn-after.out
  printf 'the survivor mentions an agent: %s time(s); it names class-data sharing: %s\n' \
    "$agent_hits" "$sharing_hits" >> .r-warn-after.out
  printf 'both runs forked surefire %s\n' "$sf_before" >> .r-warn-before.out
  printf 'both runs forked surefire %s\n' "$sf_after"  >> .r-warn-after.out
  cat .r-warn-before.out
  cat .r-warn-after.out
  rm -rf .noagent .r-warn-raw.out
  printf 'md5 before %s  exit %s\n' "$(hash_of .r-warn-before.out)" "$rc1"
  printf 'md5 after  %s  exit %s\n' "$(hash_of .r-warn-after.out)" "$rc2"
}

run_spacetrap() {
  block "spacetrap - the quotes around the agent path are load bearing"
  # What matters is whether the path to the AGENT JAR contains a space, and that path lives
  # inside the local repository. So the trap is reproduced by pointing -Dmaven.repo.local at a
  # symlink whose own name has a space in it - deterministic wherever this was cloned, and it
  # re-downloads nothing.
  rm -rf ".space trap" && mkdir -p ".space trap" && cp -R src ".space trap/src"
  ln -s "$REPO" ".space trap/m2 demo"
  SPACED="$PWD/.space trap/m2 demo"
  sed 's|-javaagent:"${org.mockito:mockito-core:jar}"|-javaagent:${org.mockito:mockito-core:jar}|' \
    pom.xml > ".space trap/pom.xml"
  grep -q '<argLine>-javaagent:\${org.mockito' ".space trap/pom.xml" \
    || die "the unquoting sed did not match pom.xml - it is coupled to the argLine form"
  # THE GUARD IS SUREFIRE'S EVIDENCE, NOT THE FORK'S. "Error occurred during initialization
  # of VM" is written by the dying fork on its own stream and surefire relays it; very
  # occasionally it does not reach the combined capture at all, and keying the guard off it
  # alone made this block die on a run that had worked exactly as designed. What surefire
  # itself prints is deterministic and is the real evidence: the fork died, AND the command
  # it launched shows the agent path split at the space. The VM line is still part of the
  # hashed capture, so it is retried for rather than assumed.
  attempt=0
  while : ; do
    attempt=$((attempt + 1))
    ( cd ".space trap" && rm -rf target \
        && mvn -B -Dmaven.repo.local="$SPACED" test > ../.r-space-raw.out 2>&1 ); rc1=$?
    [ "$rc1" -ne 0 ] || die "the UNQUOTED argLine exited 0 - the space trap did not fire"
    forkdied=$(grep -cE '^\[ERROR\] (The forked VM terminated|Error occurred in starting fork)' .r-space-raw.out)
    [ "$forkdied" -gt 0 ] \
      || die "the unquoted run exited $rc1 but surefire never reported a dead fork - this failure is not the space trap"
    # NOT '-javaagent:[^']*\.space' - that insists the agent's OWN token ends in ".space", which is
    # only true when the checkout path has no space in it. From a path that already contains one
    # (the canonical "Youtube Content" one does), surefire tears the argument at the FIRST space, so
    # the -javaagent: token ends in "Youtube" and this guard rejected a run where the trap had fired
    # exactly as designed. What the split really looks like is two ADJACENT tokens: one ending
    # ".space" and the next being "trap/m2". That is what is matched, and it holds either way.
    split=$(grep -cE "^\[ERROR\] Command was .*'[^']*\.space' 'trap/m2'" .r-space-raw.out)
    [ "$split" -gt 0 ] \
      || die "surefire's command line does not show the agent path split at the space - this failure is not the space trap"
    unquoted_err=$(grep -c '^\[ERROR\] Error occurred during initialization of VM' .r-space-raw.out)
    [ "$unquoted_err" -eq 0 ] && [ "$attempt" -lt 3 ] && continue
    break
  done
  [ "$unquoted_err" -gt 0 ] || die "the fork died at the split agent path on $attempt attempt(s), but the JVM's own initialisation error never reached the capture"
  {
    echo '--- argLine WITHOUT the quotes, agent jar under a path containing a space ---'
    grep -m1 '^\[ERROR\] Error occurred during initialization of VM' .r-space-raw.out
    grep -m1 '^\[ERROR\] The forked VM terminated' .r-space-raw.out
    grep -m1 '^\[INFO\] Tests run: 0,' .r-space-raw.out | strip_time
  } > .r-spacetrap.out
  # the same directory, the same repository, one pair of quotes put back
  cp pom.xml ".space trap/pom.xml"
  ( cd ".space trap" && rm -rf target && mvn -B -Dmaven.repo.local="$SPACED" test \
      > ../.r-space-raw.out 2>&1 ); rc2=$?
  [ "$rc2" -eq 0 ] || die "the QUOTED argLine exited $rc2 - the shipped pom does not build under a spaced path"
  {
    echo '--- the same directory, the same repository, argLine WITH the quotes ---'
    grep -E '^\[INFO\] Tests run: [0-9]+, Fail' .r-space-raw.out | tail -1 | strip_time
    grep -m1 '^\[INFO\] BUILD' .r-space-raw.out
  } >> .r-spacetrap.out
  # DERIVED from those two runs.
  printf 'unquoted: %s VM initialisation error(s), %s test(s) run. quoted: %s test(s), %s\n' \
    "$unquoted_err" \
    "$(awk '/^--- argLine WITHOUT/{p=1;next} /^--- the same directory/{p=0} p' .r-spacetrap.out \
        | grep -oE 'Tests run: [0-9]+' | tail -1 | sed -E 's/Tests run: //')" \
    "$(grep -E '^\[INFO\] Tests run: [0-9]+, Fail' .r-spacetrap.out | tail -1 \
        | sed -E 's/.*Tests run: ([0-9]+).*/\1/')" \
    "$(grep -oE 'BUILD [A-Z]+' .r-spacetrap.out | tail -1)" >> .r-spacetrap.out
  cat .r-spacetrap.out
  rm -rf ".space trap" .r-space-raw.out
  printf 'md5 %s  exit %s then %s\n' "$(hash_of .r-spacetrap.out)" "$rc1" "$rc2"
}

run_bytebuddy() {
  block "bytebuddy - the version mockito runs on here is not the version mockito pinned"
  "${MVN[@]}" dependency:tree -Dverbose > .r-bb.raw 2>&1; rc=$?
  [ "$rc" -eq 0 ] || die "dependency:tree -Dverbose exited $rc"
  grep -E 'assertj-core|mockito-core:jar|mockito-junit-jupiter|bytebuddy' .r-bb.raw \
    | sed 's/^\[INFO\] //' > .r-bytebuddy.out
  [ -s .r-bytebuddy.out ] || die "the tree named none of the four artifacts"
  # DERIVED: this block is FILTERED, so the filter's cost is counted rather than described.
  # kept is this file before anything is appended to it; rows is every edge the tree printed.
  kept_rows=$(grep -c '' .r-bytebuddy.out)
  tree_rows=$(grep -cE '^\[INFO\] [|+\\ ]*[+\\]- ' .r-bb.raw)
  [ "$tree_rows" -ge "$kept_rows" ] || die "fewer tree rows than kept rows - the row regex no longer matches this output"
  # DERIVED: how many byte-buddy versions are on the resolved tree, and is the pair matched?
  "${MVN[@]}" dependency:tree > .r-bb2.raw 2>&1 || die "dependency:tree exited non-zero"
  bb=$(grep -oE 'net\.bytebuddy:byte-buddy:jar:[0-9.]+' .r-bb2.raw | sed -E 's/.*jar://' | head -1)
  ba=$(grep -oE 'net\.bytebuddy:byte-buddy-agent:jar:[0-9.]+' .r-bb2.raw | sed -E 's/.*jar://' | head -1)
  [ -n "$bb" ] && [ -n "$ba" ] || die "the resolved tree has no byte-buddy pair to compare"
  printf 'resolved: byte-buddy %s next to byte-buddy-agent %s - matched pair: %s\n' \
    "$bb" "$ba" "$([ "$bb" = "$ba" ] && echo yes || echo no)" >> .r-bytebuddy.out
  printf 'byte-buddy appears in pom.xml %s times\n' "$(grep -c 'byte-buddy' pom.xml)" >> .r-bytebuddy.out
  printf 'the grep kept %s of the %s rows dependency:tree printed\n' "$kept_rows" "$tree_rows" >> .r-bytebuddy.out
  cat .r-bytebuddy.out
  rm -f .r-bb.raw .r-bb2.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-bytebuddy.out)" "$rc"
}

run_break() {
  block "break - two green verifies over a service that charges the wrong amount"
  ( cd breaks/verified-nothing && rm -rf target \
      && mvn -B -Dmaven.repo.local="$REPO" test > ../../.r-break.raw 2>&1 ); rc=$?
  [ "$rc" -ne 0 ] || die "breaks/verified-nothing passed - the wrong amount is no longer caught by anything"
  sed -n '/^\[INFO\] Results:/,/^\[ERROR\] Tests run:/p' .r-break.raw | strip_time > .r-break.out
  [ -s .r-break.out ] || die "no Results: block - the break did not compile"
  # DERIVED from that same report: how many ran, and how many did not pass. Errors count as
  # not passing - a break that ERRORS instead of failing used to print "0 failed" beside exit 1.
  tally=$(grep -E '^\[ERROR\] Tests run:' .r-break.out | tail -1)
  ran=$(sed -E 's/.*Tests run: ([0-9]+).*/\1/' <<<"$tally")
  failed=$(( $(sed -E 's/.*Failures: ([0-9]+).*/\1/' <<<"$tally") \
           + $(sed -E 's/.*Errors: ([0-9]+).*/\1/' <<<"$tally") ))
  # The green class has to BE green in that same run, or the sentence below has no subject.
  # Its count is read out of the run too, and cross-checked against ran-minus-failed - the
  # old version counted @Test lines in the source and could say "the 2 that passed" on a run
  # where one of them had just failed.
  gline=$(grep -E 'Tests run: [0-9]+,.*-- in com\.tiffinbox\.billing\.GreenAndWrongTest' .r-break.raw | tail -1)
  [ -n "$gline" ] || die "GreenAndWrongTest is not in the report - the green half of this beat did not run"
  gran=$(sed -E 's/.*Tests run: ([0-9]+).*/\1/' <<<"$gline")
  gbad=$(( $(sed -E 's/.*Failures: ([0-9]+).*/\1/' <<<"$gline") \
         + $(sed -E 's/.*Errors: ([0-9]+).*/\1/' <<<"$gline") ))
  [ "$gbad" -eq 0 ] || die "GreenAndWrongTest reported $gbad failure(s)/error(s) - the class this beat calls green is not green"
  [ $((ran - failed)) -eq "$gran" ] \
    || die "$((ran - failed)) test(s) passed but the green class ran $gran - the derived line would contradict its own arithmetic"
  # MEASURED BY RUNNING IT, not by grepping for the word. The old version counted lines
  # containing 'capture()' in the source, which is a text count in both directions: a green
  # test that pins the amount with eq(120) and no captor was invisible to it, and the word in
  # a comment counted as an assertion. So the green class is RE-RUN here against a service
  # that charges a THIRD wrong amount - neither the 120 it charges nor the 7200 it should -
  # and the number is how many of its tests noticed, read out of that run's own report.
  rm -rf .amount && cp -R breaks/verified-nothing .amount && rm -rf .amount/target
  rm -f .amount/src/test/java/com/tiffinbox/billing/TheCaptorTellsYouTest.java
  sed 's|gateway\.charge(c\.name(), c\.pricePerMeal())|gateway.charge(c.name(), 9999)|' \
    breaks/verified-nothing/src/main/java/com/tiffinbox/billing/BillingService.java \
    > .amount/src/main/java/com/tiffinbox/billing/BillingService.java
  grep -q 'gateway\.charge(c\.name(), 9999)' .amount/src/main/java/com/tiffinbox/billing/BillingService.java \
    || die "the third-amount sed did not match BillingService.java - the probe would re-run the very amount it is meant to change"
  ( cd .amount && mvn -B -Dmaven.repo.local="$REPO" test > ../.r-amount.raw 2>&1 ); arc=$?
  aline=$(grep -E 'Tests run: [0-9]+,.*-- in com\.tiffinbox\.billing\.GreenAndWrongTest' .r-amount.raw | tail -1)
  [ -n "$aline" ] || die "the third-amount re-run (exit $arc) produced no report for GreenAndWrongTest"
  aran=$(sed -E 's/.*Tests run: ([0-9]+).*/\1/' <<<"$aline")
  noticed=$(( $(sed -E 's/.*Failures: ([0-9]+).*/\1/' <<<"$aline") \
            + $(sed -E 's/.*Errors: ([0-9]+).*/\1/' <<<"$aline") ))
  [ "$aran" -eq "$gran" ] \
    || die "the re-run exercised $aran of the green class's $gran test(s) - the two runs are not comparable"
  printf '%s test(s) ran; %s failed; the %s that passed, re-run against a third wrong amount, noticed it %s time(s)\n' \
    "$ran" "$failed" "$gran" "$noticed" >> .r-break.out
  cat .r-break.out
  rm -rf .r-break.raw .r-amount.raw .amount
  printf 'md5 %s  exit %s\n' "$(hash_of .r-break.out)" "$rc"
}

run_solution() {
  block "solution - the exercise, all three states, actually run"
  ( cd exercise && rm -rf target \
      && mvn -B -Dmaven.repo.local="$REPO" test > ../.r-s1.raw 2>&1 ); rc1=$?
  # The START state is GREEN and wrong - that is the whole exercise. If it ever goes red the
  # viewer is being asked to fix a test that is already failing for them.
  [ "$rc1" -eq 0 ] || die "the exercise start state exited $rc1 - it is supposed to be green over a wrong service"
  grep -E '^\[INFO\] Tests run:|^\[INFO\] BUILD' .r-s1.raw | strip_time > .r-solution.out
  rm -rf .sol && cp -R exercise .sol && rm -rf .sol/solution .sol/target
  cp exercise/solution/ChargeTest.java .sol/src/test/java/com/tiffinbox/billing/ChargeTest.java
  ( cd .sol && mvn -B -Dmaven.repo.local="$REPO" test > ../.r-s2.raw 2>&1 ); rc2=$?
  [ "$rc2" -ne 0 ] || die "the answer's captor test passed against the broken service - it proves nothing"
  sed -n '/^\[INFO\] Results:/,/^\[ERROR\] Tests run:/p' .r-s2.raw | strip_time >> .r-solution.out
  cp exercise/solution/BillingService.java .sol/src/main/java/com/tiffinbox/billing/BillingService.java
  ( cd .sol && rm -rf target && mvn -B -Dmaven.repo.local="$REPO" test > ../.r-s3.raw 2>&1 ); rc3=$?
  # The ANSWER state. Every other unit in this section dies here; this one used to check rc2
  # only, so the shipped answer could stop fixing the bug and the block would still exit 0
  # while printing a line labelled "the three states" that carried two.
  [ "$rc3" -eq 0 ] || die "the answer's fixed service exited $rc3 - the shipped answer does not pass"
  grep -E '^\[INFO\] Tests run:|^\[INFO\] BUILD' .r-s3.raw | strip_time >> .r-solution.out
  [ -s .r-solution.out ] || die "none of the three states produced a report"
  # DERIVED: what the answer added, and what each of the three states reported. The list is
  # counted before it is printed, so a line that says "the three states" cannot carry two.
  states=$(grep -E 'Tests run: [0-9]+, Failures: [0-9]+' .r-solution.out | grep -v -- ' -- in ' \
           | sed -E 's|.*Tests run: ([0-9]+), Failures: ([0-9]+).*|\1 test/\2 failure|')
  n_states=$(printf '%s\n' "$states" | grep -c '')
  [ "$n_states" -eq 3 ] || die "the three-state line would carry $n_states state(s), not 3"
  printf 'the answer adds %s ArgumentCaptor(s) and %s capture() call(s); the three states reported: %s\n' \
    "$(grep -c 'ArgumentCaptor' exercise/solution/ChargeTest.java)" \
    "$(grep -c 'capture()' exercise/solution/ChargeTest.java)" \
    "$(printf '%s\n' "$states" | tr '\n' ' ')" \
    >> .r-solution.out
  cat .r-solution.out
  rm -rf .sol .r-s1.raw .r-s2.raw .r-s3.raw
  printf 'md5 %s  exit %s then %s then %s\n' "$(hash_of .r-solution.out)" "$rc1" "$rc2" "$rc3"
}

run_flags() {
  block "flags - the four flags tried against the line that survived"
  # A flag only reaches the forked JVM if it is INSIDE surefire's <argLine>, beside the agent.
  # Handing it to Maven as -DargLine=... sets the argLine PROPERTY, surefire's own inline
  # <configuration> wins, and the flag never reaches the fork at all - the build still passes
  # and the warning count never moves, so four different flags "measure" the same number. That
  # is exactly the accident unit 17 teaches about JaCoCo, and it is how these four rows were
  # first got wrong. Every row below is a POM EDIT, and the block dies if the edit did not take.
  : > .r-flags.out
  for f in NONE -Xshare:off -XX:-UseSharedSpaces -Xshare:auto -XX:SharedArchiveFile=/dev/null; do
    rm -rf .flags && mkdir .flags && cp -R src .flags/src
    if [ "$f" = NONE ]; then
      cp pom.xml .flags/pom.xml
    else
      sed "s|<argLine>-javaagent:\"\${org.mockito:mockito-core:jar}\"</argLine>|<argLine>-javaagent:\"\${org.mockito:mockito-core:jar}\" $f</argLine>|" \
        pom.xml > .flags/pom.xml
      grep -q -- "$f</argLine>" .flags/pom.xml \
        || die "$f never reached surefire's argLine - the row below would measure the baseline again"
    fi
    ( cd .flags && mvn -B -Dmaven.repo.local="$REPO" test > ../.r-flags.raw 2>&1 ); frc=$?
    [ "$frc" -eq 0 ] || die "the run with flag '$f' exited $frc - a row of this table is not a passing build"
    n=$(grep -c '^OpenJDK 64-Bit' .r-flags.raw)
    m=$(grep -E '^\[INFO\] Tests run: [0-9]+,' .r-flags.raw | tail -1 | sed -E 's/.*Tests run: ([0-9]+),.*/\1/')
    [ -n "$m" ] || die "the run with flag '$f' printed no Tests run: line"
    if [ "$f" = NONE ]; then
      [ "$n" -eq 1 ] \
        || die "the no-flag baseline printed $n warning line(s), not 1 - there is nothing here for these flags to remove"
      label='<no flag>'
    else
      label="$f"
    fi
    printf '%-31s %s OpenJDK warning line(s), %s test(s) ran\n' "$label" "$n" "$m" >> .r-flags.out
  done
  # DERIVED from the five rows above, inside the bytes the hash covers.
  tried=$(grep -vc '^<no flag>' .r-flags.out)
  gone=$(grep -v '^<no flag>' .r-flags.out | grep -c ' 0 OpenJDK warning')
  counts=$(sed -E 's/.*, ([0-9]+) test\(s\) ran$/\1/' .r-flags.out | sort -u)
  [ "$(printf '%s\n' "$counts" | grep -c '')" -eq 1 ] \
    || die "the five runs did not all run the same number of tests - the rows are not comparable"
  printf '%s flags tried: %s removed the line, %s did not; %s test(s) ran in every run\n' \
    "$tried" "$gone" "$((tried - gone))" "$counts" >> .r-flags.out
  cat .r-flags.out
  rm -rf .flags .r-flags.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-flags.out)" "$frc"
}

run_offline() {
  block "offline - contract 1c, after one warm build"
  "${MVN[@]}" -o test > .r-off.raw 2>&1; rc=$?
  [ "$rc" -eq 0 ] || die "mvn -o test exited $rc - this unit does not build offline"
  grep -E '^\[INFO\] Tests run:|^\[INFO\] BUILD' .r-off.raw | strip_time > .r-offline.out
  [ -s .r-offline.out ] || die "the offline run printed no Tests run: line"
  cat .r-offline.out
  rm -f .r-off.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-offline.out)" "$rc"
}

ALL=(doubles warn spacetrap flags bytebuddy break solution offline)
TARGETS=("$@")
[ ${#TARGETS[@]} -eq 0 ] && TARGETS=("${ALL[@]}")
# Each block in its own subshell, so die() ends THAT block and not the run. A guard that
# fails in block 3 used to take blocks 4-8 with it, including two whose md5 is on a slide.
FAILED=()
for t in "${TARGETS[@]}"; do ( "run_$t" ) || FAILED+=("$t"); done
if [ ${#FAILED[@]} -gt 0 ]; then
  printf '\n%s of %s block(s) FAILED: %s\n' "${#FAILED[@]}" "${#TARGETS[@]}" "${FAILED[*]}" >&2
  exit 1
fi
