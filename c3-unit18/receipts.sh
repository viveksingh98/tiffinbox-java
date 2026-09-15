#!/bin/bash
# receipts.sh - regenerate every number this unit puts on a slide.
#
# The rule this file exists to enforce: a count on a slide is DERIVED by the same run that
# produced the capture above it. Nothing here echoes a number a human typed.
#
#   ./receipts.sh            run every block
#   ./receipts.sh seeds      run one block
#
# The `seeds` block is the important one: it runs the same three tests under six named
# execution orders and counts the failures each time. Every one of those numbers repeats,
# which is what makes this flake a thing you can hand to a colleague.
#
# Four rules this file learned the hard way, every one of them from a wrong number that
# shipped onto a slide:
#
#   1. A DERIVED LINE IS PART OF THE CAPTURE. Every count is appended to the .out file
#      before that file is hashed, so the md5 on a slide covers the number on the slide.
#   2. "0 failures" AND "no tests ran" ARE NOT THE SAME SENTENCE. An earlier draft read
#      `Failures: N` off the last summary line and printed an empty string when there was
#      no summary line at all - so a build that compiled nothing still reported six green
#      orders. summary_of() now returns ERR, and every order asserts that the whole class
#      actually ran before its failure count is allowed on a slide.
#   3. A DETECTOR THAT CANNOT SEE THIS UNIT'S OWN BUG IS NOT A DETECTOR. An earlier draft
#      counted "static non-final fields" with a regex that needed the declaration to end on
#      its own line AND excluded every line containing `final` - so the multi-line
#      `private static final List<Customer> ROSTER = new ArrayList<>(List.of(` that this
#      whole unit is about counted as ZERO. static_fields() below counts the modifier, not
#      the shape, and the line it feeds says "static fields": a static final collection is
#      the bug, not the exception to it.
#   4. AN EXIT CODE IS MEASURED OR IT IS NOT PRINTED. An earlier draft printed
#      `exit 0` / `exit 1` as printf literals for the multi-run blocks, so reintroducing the
#      bug into the repaired class left `./receipts.sh fixed` still claiming `exit 0` beside
#      five red orders. one_order() now keeps every run's status and each multi-run block
#      prints the real count - and `fixed` and `solution` refuse to print anything at all
#      when a run they promise is green was not.
#   5. A WARNING IS NOT SILENCE, AND A FALLBACK IS NOT A PASS. The deck's quoting chip said
#      the shell's expansion "silently selects the default orderer, and you get a green run
#      that proves nothing". Nothing measured either half, and both are false on this class:
#      JUnit logs the failure twice and the fallback run is red. run_quotes() below runs
#      both forms plus a no-orderer control, and refuses to print when the two forms produce
#      the same failure count - because then the quotes cost nothing and there is no lesson.

set -u
set -o pipefail
cd "$(dirname "$0")" || exit 1

export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"

REPO="$PWD/.m2-demo"
MVN=(mvn -B -Dmaven.repo.local="$REPO")
SEEDS="${SEEDS:-1 2 3 42 2026}"
# $ must survive the shell: MethodOrderer$Random is a nested class, not a variable
ORDERER='-Djunit.jupiter.testmethod.order.default=org.junit.jupiter.api.MethodOrderer$Random'

die() { printf '\nRECEIPT FAILED (%s): %s\n' "${BLOCK:-?}" "$1" >&2; exit 1; }

hash_of() { md5 -q "$1" 2>/dev/null || md5sum "$1" | cut -d' ' -f1; }
block() { BLOCK="${1%% *}"; printf '\n=== %s ===\n' "$1"; }
# javadoc that names a thing is not a use of it: every source count below is code-only
code() { grep -hvE '^[[:space:]]*(\*|//|/\*)' "$@"; }
# every FIELD declared `static`, whatever else is on it. Two things this has to get right:
#   - `final` is NOT an exemption. `private static final List<...>` is the exact defect this
#     unit exists to teach, and it is routinely written across three lines, so what gets
#     counted is the modifier, not the shape of the declaration.
#   - a static METHOD is not shared state. `static CustomerBuilder aCustomer() {` opens its
#     parenthesis before any `=` or `;`; a field never does. That is the whole second grep.
static_fields() {
  code "$@" | grep -E '^[[:space:]]+(private|protected|public)?[[:space:]]*static[[:space:]]' \
            | grep -vcE '^[^=;]*\('
}
clean() { sed -E -e 's/, Time elapsed: [0-9.]+ s//' -e 's/ -- Time elapsed: [0-9.]+ s//' \
                 -e "s#${PWD}/#<project>/#g" \
                 -e 's#[^ ]*/c3-unit18/#<project>/#g' \
                 -e 's#/Users/[^/]*/#<home>/#g'; }

# reads a surefire log on stdin, echoes "<tests run> <failures>".
# If the log has no summary line at all - a compile error, a filter that matched nothing,
# an offline miss - it echoes "ERR ERR" and fails, so no caller can do arithmetic on it.
summary_of() {
  local line
  line=$(grep -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures' | tail -1)
  if [ -z "$line" ]; then printf 'ERR ERR\n'; return 1; fi
  printf '%s %s\n' "$(printf '%s' "$line" | sed -E 's/.*Tests run: ([0-9]+).*/\1/')" \
                   "$(printf '%s' "$line" | sed -E 's/.*Failures: ([0-9]+).*/\1/')"
}

# how many @Test methods a class declares - the number that must have run
tests_in() { code "$1" | grep -c '@Test'; }

# every multi-run block resets these, and one_order keeps them. They are what the "N of M
# mvn runs exited non-zero" line beside each md5 is made of - nothing there is a literal.
RC_TOTAL=0
RC_NONZERO=0
tally() { RC_TOTAL=$((RC_TOTAL + 1)); [ "$1" -eq 0 ] || RC_NONZERO=$((RC_NONZERO + 1)); }

# run one execution order and append "<label>  <n> failure(s) of <m> test(s)" - but only
# after proving the whole class ran. The run's real exit status goes into the tally.
# $1 label, $2 expected test count, $3 outfile, $4 directory, rest: the command
one_order() {
  local label="$1" want="$2" out="$3" dir="$4"; shift 4
  local ran f rc
  ( cd "$dir" && "$@" ) > .r-order.raw 2>&1; rc=$?
  read -r ran f < <( summary_of < .r-order.raw ) || true
  rm -f .r-order.raw
  [ "$ran" = "ERR" ] && die "$label: the run printed no Tests run: summary at all"
  [ "$ran" -ge "$want" ] \
    || die "$label: only $ran of $want test(s) ran - a failure count over a class that did not run is not a receipt"
  tally "$rc"
  printf '%-22s %s failure(s) of %s test(s)\n' "$label" "$f" "$ran" >> "$out"
}

run_tests() {
  block "tests - the unit's own suite, all green"
  "${MVN[@]}" test > .r-tests.raw 2>&1; rc=$?
  [ "$rc" -eq 0 ] || die "mvn test exited $rc - this unit's own suite is not green"
  grep -E '^\[INFO\] Tests run:' .r-tests.raw | clean > .r-tests.out
  [ -s .r-tests.out ] || die "no Tests run: line in the run"
  # DERIVED: no test source in this project holds state that outlives a test
  printf 'test sources: %s; static fields among them: %s; @BeforeEach methods: %s\n' \
    "$(ls src/test/java/com/tiffinbox/*.java | wc -l | tr -d ' ')" \
    "$(static_fields src/test/java/com/tiffinbox/*.java)" \
    "$(code src/test/java/com/tiffinbox/*.java | grep -c '@BeforeEach')" >> .r-tests.out
  cat .r-tests.out
  rm -f .r-tests.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-tests.out)" "$rc"
}

run_names() {
  block "names - two failure reports over the same two bugs"
  ( cd breaks/nameless && rm -rf target \
      && mvn -B -Dmaven.repo.local="$REPO" test > ../../.r-names.raw 2>&1 ); rc=$?
  [ "$rc" -ne 0 ] || die "breaks/nameless passed - there is no failure report to read"
  sed -n '/^\[INFO\] Results:/,/^\[ERROR\] Tests run:/p' .r-names.raw | clean > .r-names.out
  [ -s .r-names.out ] || die "no Results: block - the break did not compile"
  # DERIVED: the two classes assert exactly the same things, and differ only in names.
  # The trailing '(' is load-bearing: `import static ...Assertions.assertThat;` contains the
  # word and is not an assertion, and counting it once made every one of these three read 3.
  printf 'assertions in SubscriptionTest: %s; in BillingRulesTest: %s; identical assertion lines: %s\n' \
    "$(grep -c 'assertThat(' breaks/nameless/src/test/java/com/tiffinbox/SubscriptionTest.java)" \
    "$(grep -c 'assertThat(' breaks/nameless/src/test/java/com/tiffinbox/BillingRulesTest.java)" \
    "$(comm -12 <(grep -o 'assertThat(.*' breaks/nameless/src/test/java/com/tiffinbox/SubscriptionTest.java | sort) \
                <(grep -o 'assertThat(.*' breaks/nameless/src/test/java/com/tiffinbox/BillingRulesTest.java | sort) \
       | wc -l | tr -d ' ')" >> .r-names.out
  # DERIVED: does a @DisplayName reach the failure line at all?
  printf '@DisplayName annotations in BillingRulesTest: %s; of those appearing in the failure report above: %s\n' \
    "$(grep -c '@DisplayName' breaks/nameless/src/test/java/com/tiffinbox/BillingRulesTest.java)" \
    "$(grep -oE '@DisplayName\("[^"]+"\)' breaks/nameless/src/test/java/com/tiffinbox/BillingRulesTest.java \
       | sed -E 's/@DisplayName\("(.*)"\)/\1/' | while read -r n; do grep -qF "$n" .r-names.out && echo x; done | wc -l | tr -d ' ')" \
    >> .r-names.out
  # DERIVED: and the XML is not the consolation prize. A slide used to say the phrased name
  # "does reach target/surefire-reports/*.xml, and only there"; it does not, because the
  # phrased names only land there when surefire is configured with a statelessTestsetReporter
  # and this pom configures none. A ZERO IS ONLY A RECEIPT IF THE SEARCH COULD HAVE FOUND
  # SOMETHING: the two guards below prove the directory exists and that the report really is
  # this run's, so "0 of 3" cannot be produced by a missing folder the way a bracket
  # expression once made `warnings: 0` true for every input.
  [ -d breaks/nameless/target/surefire-reports ] \
    || die "no breaks/nameless/target/surefire-reports - a 0 counted over a missing directory is not a receipt"
  grep -rqF 'doesNotBillThePausedDays' breaks/nameless/target/surefire-reports/ \
    || die "the surefire reports do not carry the METHOD names either - wrong directory, or not this run"
  printf 'the same strings searched in every file under target/surefire-reports/: %s of %s; statelessTestsetReporter elements in that pom: %s\n' \
    "$(grep -oE '@DisplayName\("[^"]+"\)' breaks/nameless/src/test/java/com/tiffinbox/BillingRulesTest.java \
       | sed -E 's/@DisplayName\("(.*)"\)/\1/' \
       | while read -r n; do grep -rqF "$n" breaks/nameless/target/surefire-reports/ && echo x; done | wc -l | tr -d ' ')" \
    "$(grep -c '@DisplayName' breaks/nameless/src/test/java/com/tiffinbox/BillingRulesTest.java)" \
    "$(grep -c '<statelessTestsetReporter' breaks/nameless/pom.xml)" \
    >> .r-names.out
  # DERIVED: which class surefire reported first, so no slide has to guess
  printf 'the failure report names these classes, in this order: %s\n' \
    "$(grep -oE '^\[ERROR\]   [A-Za-z]+Test' .r-names.out | sed 's/^\[ERROR\]   //' \
       | awk '!seen[$0]++' | paste -sd' ' -)" >> .r-names.out
  cat .r-names.out
  rm -f .r-names.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-names.out)" "$rc"
}

run_builders() {
  block "builders - four positional arguments, two of them interchangeable"
  ( cd breaks/positional-arguments && rm -rf target \
      && mvn -B -Dmaven.repo.local="$REPO" test > ../../.r-builders.raw 2>&1 ); rc=$?
  [ "$rc" -ne 0 ] || die "breaks/positional-arguments passed - the swap no longer shows"
  { grep -E '^\[INFO\] Running|^\[(INFO|ERROR)\] Tests run: [0-9]+, Failures.*in com' .r-builders.raw
    sed -n '/^\[INFO\] Results:/,/^\[ERROR\] Tests run:/p' .r-builders.raw
  } | clean > .r-builders.out
  [ -s .r-builders.out ] || die "nothing matched the builders filter"
  # DERIVED: read the two ints out of the wrong call and multiply them the way Customer does
  swapped=$(grep -oE 'new Customer\("[A-Za-z]+", [0-9]+, [0-9]+,' \
      breaks/positional-arguments/src/test/java/com/tiffinbox/PositionalTest.java | head -1)
  [ -n "$swapped" ] || die "could not find the swapped new Customer(...) call in PositionalTest.java"
  mult=$(grep -oE 'mealsPerDay \* pricePerMeal \* [0-9][0-9_]*' src/main/java/com/tiffinbox/Customer.java \
         | grep -oE '[0-9][0-9_]*$' | tr -d '_')
  [ -n "$mult" ] || die "could not read the days multiplier out of Customer.java"
  # the equality on the slide has to be an equality this block CHECKED, so the asserted
  # value is read back out of the same file rather than described in words
  asserted=$(grep -oE 'isEqualTo\([0-9]+\)' \
      breaks/positional-arguments/src/test/java/com/tiffinbox/PositionalTest.java \
      | head -1 | grep -oE '[0-9]+')
  [ -n "$asserted" ] || die "could not read the asserted bill out of PositionalTest.java"
  printf '%s' "$swapped" | tr -dc '0-9 ' \
    | awk -v d="$mult" -v a="$asserted" '{printf "the PositionalTest call passes %d then %d; %d x %d x %d = %d, and the test asserts isEqualTo(%s)\n", $1, $2, $1, $2, d, $1*$2*d, a}' \
    >> .r-builders.out
  printf 'the two adjacent int parameters are "%s"; the builder names %s field(s) instead\n' \
    "$(grep -oE 'int [a-zA-Z]+, int [a-zA-Z]+' src/main/java/com/tiffinbox/Customer.java | head -1)" \
    "$(code src/test/java/com/tiffinbox/CustomerBuilder.java | grep -cE '^[[:space:]]+CustomerBuilder [a-z]')" \
    >> .r-builders.out
  cat .r-builders.out
  rm -f .r-builders.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-builders.out)" "$rc"
}

run_seeds() {
  block "seeds - the same three tests, six named execution orders"
  ( cd breaks/shared-state && rm -rf target \
      && mvn -B -q -Dmaven.repo.local="$REPO" test-compile ) > /dev/null 2>&1 \
    || die "breaks/shared-state does not compile"
  want=$(tests_in breaks/shared-state/src/test/java/com/tiffinbox/RosterTest.java)
  [ "$want" -gt 0 ] || die "RosterTest declares no @Test methods"
  : > .r-seeds.out
  # the default order first, and keep its log - its failure message is what slide 4 shows
  RC_TOTAL=0; RC_NONZERO=0
  ( cd breaks/shared-state && mvn -B -Dmaven.repo.local="$REPO" test > ../../.r-seed0.raw 2>&1 ); rc=$?
  tally "$rc"
  read -r ran f < <( summary_of < .r-seed0.raw ) || true
  [ "$ran" = "ERR" ] && die "the default order printed no Tests run: summary"
  [ "$ran" -ge "$want" ] || die "the default order ran $ran of $want tests"
  printf '%-22s %s failure(s) of %s test(s)\n' "Jupiter's default" "$f" "$ran" >> .r-seeds.out
  for s in $SEEDS; do
    one_order "MethodOrderer\$Random seed=$s" "$want" .r-seeds.out breaks/shared-state \
      mvn -B -Dmaven.repo.local="$REPO" \
        "$ORDERER" "-Djunit.jupiter.execution.order.random.seed=$s" test
  done
  # the failure itself, from the default-order log above - so the message on the slide has
  # a receipt of its own instead of being remembered
  printf -- '--- what the default order actually fails with ---\n' >> .r-seeds.out
  sed -n '/^\[ERROR\] Failures:/,/^\[INFO\] $/p' .r-seed0.raw | clean \
    | grep -vE '^\[INFO\] $' >> .r-seeds.out
  # DERIVED: how many of the orders tried were green, and what the one shared field is
  printf '%s of %s orders tried were green; the class holds %s static field(s); %s test(s) ran under every order\n' \
    "$(grep -c ' 0 failure' .r-seeds.out)" \
    "$(grep -c 'failure(s) of' .r-seeds.out)" \
    "$(static_fields breaks/shared-state/src/test/java/com/tiffinbox/RosterTest.java)" \
    "$want" >> .r-seeds.out
  cat .r-seeds.out
  rm -f .r-seed0.raw
  printf 'md5 %s  %s of %s mvn runs exited non-zero\n' \
    "$(hash_of .r-seeds.out)" "$RC_NONZERO" "$RC_TOTAL"
}

# the file form of the same two knobs. The slide shows a junit-platform.properties; this is
# what makes that file a thing that ships and was run, instead of a path in a picture.
run_properties() {
  block "properties - one seed, set twice: once by a file, once on the command line"
  want=$(tests_in breaks/shared-state/src/test/java/com/tiffinbox/RosterTest.java)
  [ "$want" -gt 0 ] || die "RosterTest declares no @Test methods"
  seed=$(grep -oE 'random\.seed[[:space:]]*=[[:space:]]*[0-9]+' junit-platform.properties \
         | grep -oE '[0-9]+$')
  [ -n "$seed" ] || die "could not read the seed out of junit-platform.properties"
  rm -rf .props && cp -R breaks/shared-state .props && rm -rf .props/target
  mkdir -p .props/src/test/resources
  cp junit-platform.properties .props/src/test/resources/junit-platform.properties
  RC_TOTAL=0; RC_NONZERO=0
  : > .r-properties.out
  # the file form: not one of JUnit's -D on the command line
  one_order "junit-platform.properties" "$want" .r-properties.out .props \
    mvn -B -Dmaven.repo.local="$REPO" test
  # the same class, the same seed, set the other way
  one_order "the same seed on -D" "$want" .r-properties.out breaks/shared-state \
    mvn -B -Dmaven.repo.local="$REPO" \
      "$ORDERER" "-Djunit.jupiter.execution.order.random.seed=$seed" test
  # DERIVED: one distinct failure count means the two forms selected the same order
  printf 'seed %s read out of the file; the two forms produced %s distinct failure count(s) over %s run(s)\n' \
    "$seed" \
    "$(grep -oE '[0-9]+ failure\(s\)' .r-properties.out | sort -u | wc -l | tr -d ' ')" \
    "$RC_TOTAL" >> .r-properties.out
  cat .r-properties.out
  rm -rf .props
  printf 'md5 %s  %s of %s mvn runs exited non-zero\n' \
    "$(hash_of .r-properties.out)" "$RC_NONZERO" "$RC_TOTAL"
}

# the quoting trap, MEASURED. The deck used to claim that in double quotes the property
# "silently selects the default orderer, and you get a green run that proves nothing".
# Neither half is true here, and nothing measured it. JUnit 6.1.3 logs the failure twice,
# names the parameter and the class it could not construct, and falls back; on this very
# class the fallback run is RED. What the quotes actually cost you is the ORDER you asked
# for - and the only way to see that is to run both forms and compare the failure counts.
# The two commands are written to a throwaway script so that the SHELL does the expanding:
# asserting what `$Random` expands to is not the same experiment as letting it expand.
run_quotes() {
  block "quotes - MethodOrderer\$Random in single quotes, and in double quotes"
  want=$(tests_in breaks/shared-state/src/test/java/com/tiffinbox/RosterTest.java)
  [ "$want" -gt 0 ] || die "RosterTest declares no @Test methods"
  seed=$(grep -oE 'random\.seed[[:space:]]*=[[:space:]]*[0-9]+' junit-platform.properties \
         | grep -oE '[0-9]+$')
  [ -n "$seed" ] || die "could not read the seed out of junit-platform.properties"
  # quoted heredoc: nothing below is expanded HERE, it is expanded when the script runs
  cat > .r-quotes.cmd <<'SH'
#!/bin/bash
# $1 repo, $2 seed, $3 = single | double | none
case "$3" in
  single) exec mvn -B -Dmaven.repo.local="$1" \
            '-Djunit.jupiter.testmethod.order.default=org.junit.jupiter.api.MethodOrderer$Random' \
            -Djunit.jupiter.execution.order.random.seed="$2" test ;;
  double) exec mvn -B -Dmaven.repo.local="$1" \
            "-Djunit.jupiter.testmethod.order.default=org.junit.jupiter.api.MethodOrderer$Random" \
            -Djunit.jupiter.execution.order.random.seed="$2" test ;;
  *)      exec mvn -B -Dmaven.repo.local="$1" test ;;
esac
SH
  chmod +x .r-quotes.cmd
  CMD="$PWD/.r-quotes.cmd"
  one_run() {   # $1 form -> sets rc_/ran_/f_/w_ for that form
    ( cd breaks/shared-state && rm -rf target && "$CMD" "$REPO" "$seed" "$1" ) > ".r-q-$1.raw" 2>&1
    printf '%s\n' "$?"
  }
  rc_single=$(one_run single); rc_double=$(one_run double); rc_none=$(one_run none)
  read -r ran_single f_single < <( summary_of < .r-q-single.raw ) || true
  read -r ran_double f_double < <( summary_of < .r-q-double.raw ) || true
  read -r ran_none   f_none   < <( summary_of < .r-q-none.raw )   || true
  for v in single double none; do
    eval "r=\$ran_$v"
    [ "$r" = "ERR" ] && die "the $v-quoted run printed no Tests run: summary at all"
    [ "$r" -ge "$want" ] || die "the $v form ran $r of $want test(s) - not a receipt"
  done
  w_single=$(grep -c 'Failed to load default method orderer' .r-q-single.raw)
  w_double=$(grep -c 'Failed to load default method orderer' .r-q-double.raw)
  # THE DEMONSTRATION HAS TO FIRE, AND IT HAS TO FIRE THE WAY THE SLIDE SAYS IT DOES.
  [ "$w_double" -ge 1 ] || die "the double-quoted run logged no fallback warning - the shell did not eat \$Random, and every line below would be a lie"
  [ "$w_single" -eq 0 ] || die "the SINGLE-quoted run also fell back - then the quotes are not what is being measured"
  [ "$f_single" -ne "$f_double" ] \
    || die "both forms produced $f_single failure(s) - the quoting costs nothing on this class and the lesson has evaporated"
  [ "$f_double" -eq "$f_none" ] \
    || die "the double-quoted run ($f_double) did not match the no-orderer run ($f_none) - 'falls back to the default' is not what happened"
  {
    printf -- '--- single quotes: MethodOrderer$Random reaches JUnit intact ---\n'
    grep -E '^\[(INFO|ERROR)\] Tests run: [0-9]+, Failures' .r-q-single.raw | tail -1
    printf -- '--- double quotes: the shell removed $Random, so JUnit was handed the bare interface ---\n'
    grep -m1 'Failed to load default method orderer' .r-q-double.raw
    grep -E '^\[(INFO|ERROR)\] Tests run: [0-9]+, Failures' .r-q-double.raw | tail -1
  } | clean > .r-quotes.out
  # DERIVED: three runs, one filter, and the sentence the slide is allowed to say
  printf 'single quotes: exit %s, %s failure(s) of %s test(s), %s fallback warning(s); double quotes: exit %s, %s failure(s) of %s test(s), %s fallback warning(s)\n' \
    "$rc_single" "$f_single" "$ran_single" "$w_single" \
    "$rc_double" "$f_double" "$ran_double" "$w_double" >> .r-quotes.out
  printf 'the same class with no orderer named at all: %s failure(s) of %s test(s) - the count the DOUBLE-quoted form produced, not the single-quoted one; neither run was green\n' \
    "$f_none" "$ran_none" >> .r-quotes.out
  cat .r-quotes.out
  rm -f .r-q-single.raw .r-q-double.raw .r-q-none.raw .r-quotes.cmd
  printf 'md5 %s  exit %s then %s\n' "$(hash_of .r-quotes.out)" "$rc_single" "$rc_double"
}

run_fixed() {
  block "fixed - the same three tests with the state made fresh, under the same orders"
  want=$(tests_in src/test/java/com/tiffinbox/RosterTest.java)
  [ "$want" -gt 0 ] || die "this unit's RosterTest declares no @Test methods"
  RC_TOTAL=0; RC_NONZERO=0
  : > .r-fixed.out
  # -Dtest=RosterTest with NO failIfNoSpecifiedTests escape hatch: if the filter ever stops
  # matching, Maven fails the build and one_order refuses to report six green orders.
  one_order "Jupiter's default" "$want" .r-fixed.out . \
    "${MVN[@]}" -Dtest=RosterTest test
  for s in $SEEDS; do
    one_order "MethodOrderer\$Random seed=$s" "$want" .r-fixed.out . \
      "${MVN[@]}" -Dtest=RosterTest "$ORDERER" "-Djunit.jupiter.execution.order.random.seed=$s" test
  done
  # this block's whole claim is "the repair holds under every order". It is not allowed to
  # print that claim unless every mvn run behind it actually exited 0.
  [ "$RC_NONZERO" -eq 0 ] \
    || die "$RC_NONZERO of $RC_TOTAL runs of the repaired class exited non-zero - the repair does not hold"
  printf '%s of %s orders tried were green; %s test(s) ran under every one of them\n' \
    "$(grep -c ' 0 failure' .r-fixed.out)" "$(grep -c 'failure(s) of' .r-fixed.out)" "$want" >> .r-fixed.out
  printf 'static fields in this RosterTest: %s; @BeforeEach methods: %s\n' \
    "$(static_fields src/test/java/com/tiffinbox/RosterTest.java)" \
    "$(code src/test/java/com/tiffinbox/RosterTest.java | grep -c '@BeforeEach')" >> .r-fixed.out
  cat .r-fixed.out
  printf 'md5 %s  %s of %s mvn runs exited non-zero\n' \
    "$(hash_of .r-fixed.out)" "$RC_NONZERO" "$RC_TOTAL"
}

run_solution() {
  block "solution - the exercise answer, actually run, under every order"
  rm -rf .sol && cp -R exercise .sol && rm -rf .sol/solution .sol/target
  cp exercise/solution/*.java .sol/src/test/java/com/tiffinbox/
  want=$(tests_in exercise/solution/RosterTest.java)
  [ "$want" -gt 0 ] || die "the answer's RosterTest declares no @Test methods"
  RC_TOTAL=0; RC_NONZERO=0
  : > .r-solution.out
  one_order "Jupiter's default" "$want" .r-solution.out .sol \
    mvn -B -Dmaven.repo.local="$REPO" test
  for s in $SEEDS; do
    one_order "MethodOrderer\$Random seed=$s" "$want" .r-solution.out .sol \
      mvn -B -Dmaven.repo.local="$REPO" \
        "$ORDERER" "-Djunit.jupiter.execution.order.random.seed=$s" test
  done
  [ "$RC_NONZERO" -eq 0 ] \
    || die "$RC_NONZERO of $RC_TOTAL runs of the exercise answer exited non-zero - the answer does not pass"
  # DERIVED: what the answer changed
  printf '%s of %s orders tried were green; %s test(s) ran under every one of them\n' \
    "$(grep -c ' 0 failure' .r-solution.out)" "$(grep -c 'failure(s) of' .r-solution.out)" "$want" \
    >> .r-solution.out
  printf 'static fields - starting class: %s, answer: %s; @BeforeEach - starting class: %s, answer: %s\n' \
    "$(static_fields exercise/src/test/java/com/tiffinbox/RosterTest.java)" \
    "$(static_fields exercise/solution/RosterTest.java)" \
    "$(code exercise/src/test/java/com/tiffinbox/RosterTest.java | grep -c '@BeforeEach')" \
    "$(code exercise/solution/RosterTest.java | grep -c '@BeforeEach')" >> .r-solution.out
  cat .r-solution.out
  rm -rf .sol
  printf 'md5 %s  %s of %s mvn runs exited non-zero\n' \
    "$(hash_of .r-solution.out)" "$RC_NONZERO" "$RC_TOTAL"
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

ALL=(tests names builders seeds properties quotes fixed solution offline)
TARGETS=("$@")
[ ${#TARGETS[@]} -eq 0 ] && TARGETS=("${ALL[@]}")
for t in "${TARGETS[@]}"; do "run_$t"; done
