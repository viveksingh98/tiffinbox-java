#!/bin/bash
# receipts.sh - regenerate every number this unit puts on a slide.
#
# The rule this file exists to enforce: a count on a slide is DERIVED by the same run that
# produced the capture above it. Nothing here echoes a number a human typed. If a filter
# below changes, the hash changes, and the slide is wrong until it is re-captured.
#
#   ./receipts.sh            run every block
#   ./receipts.sh strict     run one block
#
# Six rules this file learned the hard way:
#
#   1. A DERIVED LINE IS PART OF THE CAPTURE. Every count is appended to the .out file
#      before that file is hashed, so the md5 on a slide covers the number on the slide.
#   2. A DEMONSTRATION THAT DID NOT FIRE MUST SAY SO, LOUDLY. An earlier `quoting` block
#      asked whether the CLONE's path had a space in it - so on a clone with no space it
#      printed `unquoted -> exit 0` and quietly inverted the whole lesson. The trap is now
#      built, not hoped for: the local repository is reached through a symlink whose own
#      name has a space in it, so it fires wherever this was cloned, and the block refuses
#      to print at all if the unquoted run succeeds.
#   3. BOTH SIDES OF A CONTRAST USE THE SAME FILTER. The same block once compared
#      `head -1` of the per-class lines against `tail -1` of the summary and produced a
#      "1 versus 4" that was made entirely of two different greps.
#   4. EVERY CAPTURE AND EVERY COUNT ON A SLIDE IS PRODUCED HERE. The `counts` and
#      `exercise` blocks exist because four things on the slides were true but derived
#      nowhere - the two classes' @Mock/when( counts, the ours-vs-JDBC split under them,
#      and the exercise's starting state, which `solution` overwrites before it runs.
#      A value no block derives is a value a wrong edit moves no hash.
#   5. A PARSER THAT UNDERSTANDS ONE STYLE COUNTS ZERO OF THE OTHER, IN SILENCE. `counts`
#      used to require the field's type on the same line as its annotation, the way this
#      unit's own break writes them (`@Mock Database db;`). Written the ordinary way -
#      `@Mock` on its own line above the field, which is how unit 14 writes every mock it
#      has - it matched nothing, printed `0 @Mock field(s), 8 when(...) stub(s)` and exited
#      0, because all three guards under it compared two numbers that were both zero.
#      Guards now compare things read by DIFFERENT passes: @Mock annotation SITES against
#      types RESOLVED, and stubs against mocks. Two numbers from one assumption can only
#      ever agree with each other.
#   6. A LABEL IS A CLAIM, AND THE FILTER UNDER IT HAS TO MEET THE CLAIM. `agent` printed
#      "<argLine> elements declaring -javaagent" while counting <argLine> elements of any
#      content whatsoever, so it read 1 with the agent deleted. Worse, the obvious repair -
#      grepping for `<argLine>[^<]*-javaagent:` - matches this pom's own prose comment,
#      which names both in one sentence: it reads 2 where the truth is 1, and still reads
#      1 with the agent gone. The count is anchored to the start of a line now, and the
#      run has to agree with the pom: a static agent is exactly what stops Mockito
#      self-attaching, so that warning appearing fails the block.
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

# every capture goes through this: durations and absolute paths are never hashed
clean() { sed -E -e 's/, Time elapsed: [0-9.]+ s//' -e 's/ -- Time elapsed: [0-9.]+ s//' \
                 -e "s#${PWD}/#<project>/#g" \
                 -e 's#[^ ]*/c3-unit15/#<project>/#g' \
                 -e 's#/Users/[^/]*/#<home>/#g'; }

run_tests() {
  block "tests - the unit's own suite, all green"
  "${MVN[@]}" test > .r-tests.raw 2>&1; rc=$?
  [ "$rc" -eq 0 ] || die "mvn test exited $rc - this unit's own suite is not green"
  grep -E '^\[INFO\] Tests run:' .r-tests.raw | clean > .r-tests.out
  [ -s .r-tests.out ] || die "no Tests run: line in the run"
  # DERIVED: how many test classes, and how many of them use a mock at all
  printf '%s test classes reported; %s of the %s test sources mention Mockito\n' \
    "$(grep -c 'in com.tiffinbox' .r-tests.out)" \
    "$(grep -l 'org.mockito' src/test/java/com/tiffinbox/*.java | wc -l | tr -d ' ')" \
    "$(ls src/test/java/com/tiffinbox/*.java | wc -l | tr -d ' ')" >> .r-tests.out
  cat .r-tests.out
  rm -f .r-tests.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-tests.out)" "$rc"
}

# which of a class's @Mock types we wrote and which arrived from JDBC. A mocked type is OURS
# if a source file of that name sits in the same project's src/main; it is java.sql's if that
# same test file imports it from there. Anything that is neither fails the block, so a new
# collaborator can never be silently counted on the wrong side of the boundary.
#
# Two passes, deliberately not sharing a reader: mock_annotations counts annotation SITES,
# mock_types resolves the TYPE each one applies to. run_counts makes them agree, so a field
# style neither understands stops the block instead of quietly counting nothing.
mock_annotations() {   # $1 = test source -> how many @Mock annotation sites the file carries
  # a trailing space is added so a bare `@Mock` on its own line has a character after it,
  # and `$` never has to appear inside an alternation (grep dialects differ about that)
  sed 's/$/ /' "$1" | grep -cE '^[[:space:]]*@Mock[^A-Za-z0-9_]'
}

mock_types() {   # $1 = test source -> one mocked type per line, qualified or not
  # Reads BOTH field styles: `@Mock Database db;` and `@Mock` on its own line above the
  # field. Anything after the annotation that is not an identifier - `(answer = ...)`, a
  # blank line - is stepped over; `@MockitoSettings` and javadoc mentions are not matched.
  awk '
    { line = $0; sub(/^[[:space:]]+/, "", line); probe = line " " }
    pending && line == "" { next }                          # blank line before the field
    pending {
      pending = 0
      if (match(line, /^[A-Za-z_][A-Za-z0-9_.]*/)) print substr(line, RSTART, RLENGTH)
      next
    }
    probe ~ /^@Mock[^A-Za-z0-9_]/ {
      sub(/^@Mock([[:space:]]*\([^)]*\))?[[:space:]]*/, "", line)
      if (match(line, /^[A-Za-z_][A-Za-z0-9_.]*/)) print substr(line, RSTART, RLENGTH)
      else pending = 1                                      # the field is on the next line
    }
  ' "$1"
}

mock_split() {   # $1 = test source, $2 = that project's main package dir -> "<ours> <jdbc> <other>"
  local f="$1" main="$2" t s ours=0 jdbc=0 other=0
  for t in $(mock_types "$f"); do
    s="${t##*.}"                                  # the simple name, however it was written
    if [ -f "$main/$s.java" ]; then ours=$((ours+1))
    elif [ "$t" != "$s" ] && [ "${t%.*}" = "java.sql" ]; then jdbc=$((jdbc+1))
    elif [ "$t" = "$s" ] && grep -qE "^import java\.sql\.$s;" "$f"; then jdbc=$((jdbc+1))
    else other=$((other+1)); fi
  done
  printf '%s %s %s\n' "$ours" "$jdbc" "$other"
}

run_counts() {
  block "counts - the two classes on the fake-vs-mock slide, counted off the shipped sources"
  local dir=breaks/green-over-broken
  local main="$dir/src/main/java/com/tiffinbox"
  local c f annotated fields stubs ours jdbc other
  : > .r-counts.out
  for c in MockedJdbcTest RealDatabaseTest; do
    f="$dir/src/test/java/com/tiffinbox/$c.java"
    [ -f "$f" ] || die "$c.java is not where the slides say it is"
    annotated=$(mock_annotations "$f")
    fields=$(mock_types "$f" | wc -l | tr -d ' ')
    stubs=$(grep -c 'when(' "$f")
    # Read by two different passes on purpose. When both came out of one same-line
    # assumption they agreed at zero for a file written the ordinary way, and every guard
    # under them passed on 0 == 0.
    [ "$fields" -eq "$annotated" ] \
      || die "$c carries $annotated @Mock annotation(s) but only $fields of them resolved to a type - the ours/theirs split would be counted over the wrong set"
    # A class with stubs and no mocks is not a fact about the class, it is a broken reader.
    # RealDatabaseTest has neither and is untouched by this; it is the honest half of the
    # contrast, so the guard is keyed on the contradiction and not on zero.
    { [ "$stubs" -eq 0 ] || [ "$fields" -gt 0 ]; } \
      || die "$c sets up $stubs when(...) stub(s) and has no @Mock field to hang them on - one of those two counts is being read wrong"
    read -r ours jdbc other <<< "$(mock_split "$f" "$main")"
    [ "$other" -eq 0 ] \
      || die "$c mocks $other type(s) that are neither ours nor java.sql's - the ours/theirs split on the slide would be wrong"
    [ "$((ours + jdbc))" -eq "$fields" ] || die "$c: the split does not add up to its $fields @Mock field(s)"
    printf '%s: %s @Mock field(s), %s when(...) stub(s); of the mocked types %s is ours and %s belong to java.sql\n' \
      "$c" "$fields" "$stubs" "$ours" "$jdbc" >> .r-counts.out
  done
  # DERIVED: the stubbed calls themselves, in file order, so an excerpt of this class on a
  # slide and the elision that names what it left out are both checkable against the file.
  printf 'the when(...) calls of MockedJdbcTest, in file order: %s\n' \
    "$(sed -nE 's/^[[:space:]]*when\((.*)\)\.thenReturn.*/\1/p' \
         "$dir/src/test/java/com/tiffinbox/MockedJdbcTest.java" | paste -sd'~' - | sed 's/~/, /g')" \
    >> .r-counts.out
  cat .r-counts.out
  printf 'md5 %s  exit %s\n' "$(hash_of .r-counts.out)" 0
}

run_green() {
  block "green - the mocked test passes, the real database does not"
  ( cd breaks/green-over-broken && rm -rf target \
      && mvn -B -Dmaven.repo.local="$REPO" test > ../../.r-green.raw 2>&1 ); rc=$?
  [ "$rc" -ne 0 ] || die "breaks/green-over-broken passed - the broken column no longer breaks"
  # the hook's panel, out of this same run: the one class that slide is about
  grep 'in com.tiffinbox.MockedJdbcTest' .r-green.raw | clean > .r-mocked.out
  [ -s .r-mocked.out ] || die "MockedJdbcTest did not report at all"
  grep -q 'Failures: 0, Errors: 0' .r-mocked.out \
    || die "MockedJdbcTest is not green - the whole hook depends on it being green"
  cat .r-mocked.out
  printf 'md5 %s  exit %s\n' "$(hash_of .r-mocked.out)" "$rc"
  sed -n '/^\[INFO\] Results:/,/^\[ERROR\] Tests run:/p' .r-green.raw | clean > .r-green.out
  [ -s .r-green.out ] || die "no Results: block - the break did not compile"
  # DERIVED: the column the SELECT asks for, and the column CREATE TABLE declares
  asked=$(grep 'SELECT name' breaks/green-over-broken/src/main/java/com/tiffinbox/CustomerRepository.java \
          | grep -oE 'meal_typ[a-z]*')
  declared=$(grep -oE 'meal_type[a-z]*' breaks/green-over-broken/src/main/java/com/tiffinbox/Database.java | head -1)
  [ -n "$asked" ] && [ -n "$declared" ] || die "could not read both column names out of the sources"
  printf 'the SELECT asks for "%s"; CREATE TABLE declares "%s"\n' "$asked" "$declared" >> .r-green.out
  # DERIVED from the summary line this run printed, so the arithmetic cannot drift
  # the LAST [ERROR] Tests run: line of the capture is the Results: summary; the per-class
  # line above it counts one class only, and adding the two would double-count the suite.
  counted=$(grep -E '^\[ERROR\] Tests run:' .r-green.out | tail -1 \
    | awk -F'[:,]' '{ran=$2+0; err=$6+0; seen=1;
        printf "%d test(s) ran; %d green, %d errored - over one column name\n", ran, ran-err, err}
        END {if (!seen) exit 1}') \
    || die "the report has no [ERROR] Tests run: summary to count"
  printf '%s\n' "$counted" >> .r-green.out
  cat .r-green.out
  rm -f .r-green.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-green.out)" "$rc"
}

# how many of a class's stubs the test body actually calls. Counting `assertThat(repo...)`
# lines counts assertions, not stub usage: a stub the code under test reaches without an
# assertion beside it is invisible to that. Read the stubbed method names instead, then
# look for a call to each one somewhere that is not the when(...) that created it.
stubs_invoked() {   # $1 = java source
  local f="$1" m n=0
  for m in $(grep -oE 'when\(repo\.[a-zA-Z0-9_]+\(' "$f" | sed -E 's/^when\(repo\.//; s/\($//' | sort -u); do
    grep -v 'when(repo\.' "$f" | grep -q "repo\.$m(" && n=$((n+1))
  done
  printf '%s\n' "$n"
}

run_strict() {
  block "strict - the same unused stub under both strictness settings"
  ( cd breaks/strict-vs-lenient && rm -rf target \
      && mvn -B -Dmaven.repo.local="$REPO" test > ../../.r-strict.raw 2>&1 ); rc=$?
  [ "$rc" -ne 0 ] || die "breaks/strict-vs-lenient passed - strict stubs are no longer strict"
  grep -E '^\[INFO\] Running|^\[(INFO|ERROR)\] Tests run:|UnnecessaryStubbing $' .r-strict.raw \
    | clean > .r-strict.out
  [ -s .r-strict.out ] || die "nothing matched the strict filter"
  # counted off the capture BEFORE anything is appended to it, so it counts the report and
  # not this script's own lines
  unnecessary=$(grep -c 'UnnecessaryStubbing' .r-strict.out)
  # DERIVED: the two classes set up the same stubs, and one of them also names a Strictness.
  # "used" is a count of stubbed METHODS the test body calls, not of assertion lines.
  for c in StrictTest LenientTest; do
    f=breaks/strict-vs-lenient/src/test/java/com/tiffinbox/$c.java
    printf '%s: %s stub(s) set up, %s of them invoked by the test body, @MockitoSettings present: %s\n' \
      "$c" "$(grep -c 'when(repo' "$f")" \
      "$(stubs_invoked "$f")" \
      "$(grep -q 'MockitoSettings' "$f" && echo yes || echo no)" >> .r-strict.out
  done
  # DERIVED: how many UnnecessaryStubbing reports the run itself produced
  printf 'test case(s) this run reported as UnnecessaryStubbing: %s\n' \
    "$unnecessary" >> .r-strict.out
  cat .r-strict.out
  rm -f .r-strict.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-strict.out)" "$rc"
}

run_doubles() {
  block "doubles - which byte-buddy actually ends up on the test classpath"
  "${MVN[@]}" dependency:tree -Dverbose > .r-tree.raw 2>&1; rc=$?
  [ "$rc" -eq 0 ] || die "dependency:tree exited $rc"
  grep -E 'assertj-core:jar|mockito-core:jar|byte-buddy' .r-tree.raw | sed -E 's/^\[INFO\] //' \
    | clean > .r-doubles.out
  [ -s .r-doubles.out ] || die "the tree named neither assertj nor mockito nor byte-buddy"
  # DERIVED from the classpath itself, not from the tree above
  "${MVN[@]}" -q dependency:build-classpath -Dmdep.outputFile=.r-cp.txt > /dev/null 2>&1 \
    || die "dependency:build-classpath failed"
  bb=$(tr ':' '\n' < .r-cp.txt | grep -oE 'byte-buddy-[0-9][^/]*\.jar' | head -1)
  ba=$(tr ':' '\n' < .r-cp.txt | grep -oE 'byte-buddy-agent-[0-9][^/]*\.jar' | head -1)
  [ -n "$bb" ] && [ -n "$ba" ] || die "no byte-buddy on the built classpath"
  printf 'byte-buddy on the classpath: %s ; byte-buddy-agent: %s\n' "$bb" "$ba" >> .r-doubles.out
  printf 'assertj-core is declared before mockito-core in pom.xml: %s\n' \
    "$(awk '/<artifactId>assertj-core<\/artifactId>/{a=NR}
            /<artifactId>mockito-core<\/artifactId>/{if(!m)m=NR}
            END{print (a && m && a<m) ? "yes" : "no"}' pom.xml)" >> .r-doubles.out
  cat .r-doubles.out
  rm -f .r-cp.txt .r-tree.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-doubles.out)" "$rc"
}

run_agent() {
  block "agent - what the forked test JVM still prints, with Mockito declared statically"
  "${MVN[@]}" test > .r-agent.raw 2>&1; rc=$?
  [ "$rc" -eq 0 ] || die "mvn test exited $rc"
  grep -vE '^\[(INFO|WARNING|ERROR|DEBUG)\]' .r-agent.raw | grep -E 'warning|WARNING|Mockito' \
    | clean > .r-agent.out
  # DERIVED: how many lines the JVM/Mockito printed, and whether the static agent is declared.
  # Counted BEFORE the count itself is appended, so it counts the capture and not itself.
  lines=$(grep -c . .r-agent.out)
  # Count what the label names: an <argLine> ELEMENT whose own content declares -javaagent:.
  # It used to count <argLine> of any content, and read 1 with the agent replaced by -Xmx.
  # The line anchor is what keeps the pom's own prose out: the comment above the element
  # names <argLine> and -javaagent: in one sentence, so an unanchored pattern reads 2 here
  # and still reads 1 with the agent deleted.
  agents=$(grep -cE '^[[:space:]]*<argLine>[^<]*-javaagent:[^<]*</argLine>' pom.xml)
  [ "$agents" -ge 1 ] \
    || die "no <argLine> element in pom.xml declares -javaagent: - the static agent is gone"
  # And the run has to agree with the pom. Declaring the agent statically is precisely what
  # stops Mockito attaching one at run time, so this line in the capture means it did not
  # take - a state the pom alone cannot tell you about.
  if grep -q 'self-attaching' .r-agent.out; then
    die "the forked JVM reported Mockito self-attaching - the <argLine> agent did not take effect"
  fi
  printf '%s line(s) of warning; <argLine> elements declaring -javaagent in pom.xml: %s\n' \
    "$lines" "$agents" >> .r-agent.out
  cat .r-agent.out
  rm -f .r-agent.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-agent.out)" "$rc"
}

run_quoting() {
  block "quoting - the inherited agent line, with and without its quotes"
  # What matters is whether the path to the AGENT JAR contains a space, and that path lives
  # inside the local repository. So the trap is reproduced by pointing -Dmaven.repo.local at
  # a symlink whose own name has a space in it: it fires wherever this was cloned, and it
  # re-downloads nothing.
  rm -rf ".space trap" && mkdir -p ".space trap" && cp -R src ".space trap/src"
  ln -s "$REPO" ".space trap/m2 demo"
  SPACED="$PWD/.space trap/m2 demo"
  sed 's|-javaagent:"${org.mockito:mockito-core:jar}"|-javaagent:${org.mockito:mockito-core:jar}|' \
    pom.xml > ".space trap/pom.xml"
  grep -q '<argLine>-javaagent:\${org.mockito' ".space trap/pom.xml" \
    || die "the unquoting sed did not match pom.xml - it is coupled to the argLine form"
  ( cd ".space trap" && mvn -B -Dmaven.repo.local="$SPACED" test > ../.r-q1.raw 2>&1 ); rc_unq=$?
  # the same directory, the same repository, the shipped pom with its quotes
  cp pom.xml ".space trap/pom.xml"
  ( cd ".space trap" && rm -rf target && mvn -B -Dmaven.repo.local="$SPACED" test > ../.r-q2.raw 2>&1 ); rc_q=$?
  # A demonstration that did not fire is not a demonstration.
  [ "$rc_unq" -ne 0 ] || die "the UNQUOTED argLine exited 0 - the space trap did not fire, and the contrast below would be a lie"
  [ "$rc_q" -eq 0 ] || die "the QUOTED argLine exited $rc_q - the shipped pom does not build under a spaced path"
  # Both sides read through the SAME filter: the last Tests run: summary line of each run.
  {
    echo '--- argLine WITHOUT the quotes, agent jar under a path containing a space ---'
    grep -m1 'Error opening zip file or JAR manifest missing' .r-q1.raw \
      | sed -E 's#(Error opening zip file or JAR manifest missing : ).*#\1<the agent path, torn at its first space>#'
    grep -m1 '^\[ERROR\] Error occurred during initialization of VM' .r-q1.raw
    grep -E '^\[(INFO|ERROR)\] Tests run: [0-9]+, Fail' .r-q1.raw | tail -1
    echo '--- the same directory, the same repository, argLine WITH the quotes ---'
    grep -E '^\[(INFO|ERROR)\] Tests run: [0-9]+, Fail' .r-q2.raw | tail -1
  } | clean > .r-quoting.out
  # DERIVED from the two exit codes and from the same filter on both sides
  unq=$(awk '/^--- argLine WITHOUT/{p=1;next} /^--- the same directory/{p=0} p' .r-quoting.out \
        | grep -oE 'Tests run: [0-9]+' | tail -1 | sed -E 's/Tests run: //')
  q=$(awk '/^--- the same directory/{p=1;next} p' .r-quoting.out \
      | grep -oE 'Tests run: [0-9]+' | tail -1 | sed -E 's/Tests run: //')
  [ -n "$unq" ] && [ -n "$q" ] || die "one side produced no Tests run: line at all"
  printf 'unquoted -> exit %s, %s test(s) ran; quoted -> exit %s, %s test(s) ran\n' \
    "$rc_unq" "$unq" "$rc_q" "$q" >> .r-quoting.out
  printf 'the quotes are load bearing on this machine: %s\n' \
    "$([ "$rc_unq" -ne 0 ] && [ "$rc_q" -eq 0 ] && echo yes || echo no)" >> .r-quoting.out
  cat .r-quoting.out
  rm -rf ".space trap" .r-q1.raw .r-q2.raw
  printf 'md5 %s  exit %s then %s\n' "$(hash_of .r-quoting.out)" "$rc_unq" "$rc_q"
}

run_exercise() {
  block "exercise - the starting state the exercise card describes, before anything is fixed"
  # run_solution copies the answer over the starting test, so the failing start state has to
  # be captured in its own throwaway copy or it is never captured at all.
  rm -rf .ex && cp -R exercise .ex && rm -rf .ex/solution .ex/target
  ( cd .ex && mvn -B -Dmaven.repo.local="$REPO" test > ../.r-ex.raw 2>&1 ); rc=$?
  [ "$rc" -ne 0 ] || die "the untouched exercise passed - there is nothing left for the viewer to fix"
  sed -n '/^\[ERROR\]   PausesTest/,/^\[ERROR\] Tests run:/p' .r-ex.raw \
    | grep -E '^\[ERROR\]|^ +[0-9]+\. -> at ' | clean > .r-exercise.out
  [ -s .r-exercise.out ] || die "the run reported no UnnecessaryStubbing for PausesTest"
  # counted off the capture BEFORE anything is appended to it
  named=$(grep -c '\. -> at ' .r-exercise.out)
  lines=$(grep -oE 'PausesTest\.java:[0-9]+' .r-exercise.out | cut -d: -f2 | sort -un | paste -sd, -)
  [ "$named" -gt 0 ] && [ -n "$lines" ] || die "the report named no stubbing and no line number"
  # DERIVED: every line the report points at is read back out of the shipped starting test,
  # so the line numbers on the exercise card cannot drift from the file the viewer clones.
  start=exercise/src/test/java/com/tiffinbox/PausesTest.java
  stubs=yes
  for n in $(printf '%s' "$lines" | tr ',' ' '); do
    sed -n "${n}p" "$start" | grep -q 'when(repo' || stubs=no
  done
  printf 'the report names %s unnecessary stubbing(s), at PausesTest.java line(s) %s; every one of those lines in the shipped exercise is a when(repo line: %s\n' \
    "$named" "$lines" "$stubs" >> .r-exercise.out
  [ "$stubs" = yes ] || die "the report points at a line of $start that is not a when(repo stub"
  cat .r-exercise.out
  rm -rf .ex .r-ex.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-exercise.out)" "$rc"
}

run_solution() {
  block "solution - the exercise answer, actually run"
  rm -rf .sol && cp -R exercise .sol && rm -rf .sol/solution .sol/target
  cp exercise/solution/PausesTest.java .sol/src/test/java/com/tiffinbox/PausesTest.java
  ( cd .sol && mvn -B -Dmaven.repo.local="$REPO" test > ../.r-sol.raw 2>&1 ); rc=$?
  [ "$rc" -eq 0 ] || die "the answer exited $rc - it does not pass"
  grep -E '^\[INFO\] Tests run:|^\[INFO\] BUILD' .r-sol.raw | clean > .r-solution.out
  [ -s .r-solution.out ] || die "the answer produced no Tests run: line"
  # DERIVED: how many stubs the answer removed
  printf 'stubs in the starting test: %s; in the answer: %s\n' \
    "$(grep -c 'when(repo' exercise/src/test/java/com/tiffinbox/PausesTest.java)" \
    "$(grep -c 'when(repo' exercise/solution/PausesTest.java)" >> .r-solution.out
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

ALL=(tests counts green strict doubles agent quoting exercise solution offline)
TARGETS=("$@")
[ ${#TARGETS[@]} -eq 0 ] && TARGETS=("${ALL[@]}")
for t in "${TARGETS[@]}"; do "run_$t"; done
