#!/bin/bash
# receipts.sh - regenerate every number this unit puts on a slide.
#
# The rule this file exists to enforce: a count on a slide is DERIVED by the same run that
# produced the capture above it. Nothing here echoes a number a human typed.
#
#   ./receipts.sh            run every block
#   ./receipts.sh race       run one block
#
# The `race` block is the one that cannot be hashed. It runs the same test, with the same
# one-millisecond sleep, at three queue lengths, RUNS cold surefire forks of each. Every count
# is printed beside its own N, so the two can never be separated (contract 2a rank 4, 2c).
# It claims no shape and no rate: what a sweep produced is all it says, and the derived lines
# below say how far that moved when the identical sweep was run again.
#
#   RUNS=20 ./receipts.sh race                 # more runs per length
#   LENGTHS="2000 20000" ./receipts.sh race    # fewer lengths, for a quick check
#   SWEEPS=2 ./receipts.sh race                # the same sweep twice, and the block compares them
#
# The `race` block derives one more thing than the counts: whether the count tracked the queue
# length at all. That ordering used to be asserted by an author on a slide. It is now computed
# from the loop's own counts, and with SWEEPS=2 the block also measures how far one length moves
# between two sweeps against how far the three lengths move inside one. That comparison IS
# contract 2c, arrived at by arithmetic instead of by claim.
#
# Everything else in this file is deterministic and hashed.
#
# TWO RULES THIS FILE ENFORCES ON ITSELF, BOTH ADDED BY THE 2026-09-15 REPAIR PASS:
#   A RUN THAT EXECUTED NO TEST IS NOT A PASS. Every multi-run block reads the `Tests run:`
#   summary out of each build and dies when it is below the @Test count the source declares.
#   `mvn test` over a class surefire did not select exits 0 and prints no Tests run: line at all,
#   so a loop reading only the exit status reports a spotless sweep over nothing - which `race`
#   and `retry` both did until this pass, and `fixed` already refused.
#   AN EXIT CODE IS MEASURED OR IT IS NOT PRINTED. There is no literal exit status in this file.
#   Nor is there a slide-facing line built from a grep whose result was never checked.

set -u
set -o pipefail
cd "$(dirname "$0")" || exit 1

export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"

REPO="$PWD/.m2-demo"
MVN=(mvn -B -Dmaven.repo.local="$REPO")
RUNS="${RUNS:-12}"
# how many times the whole three-length sweep is repeated. 2 is what the slides show, because
# one sweep cannot tell you whether its own ordering is a property of the test or of the hour.
SWEEPS="${SWEEPS:-1}"
# short, the length this unit ships, and ten times it. One table, generated here, quoted
# everywhere - so no appendix can disagree with a slide about how many runs there were.
LENGTHS="${LENGTHS:-2000 20000 200000}"
# the length the retry experiment uses: the one where the race is a flake rather than a
# certainty, because a retry only has something to rescue when the second attempt can win
RETRY_ORDERS="${RETRY_ORDERS:-20000}"

die() { printf '\nRECEIPT FAILED (%s): %s\n' "${BLOCK:-?}" "$1" >&2; exit 1; }

hash_of() { md5 -q "$1" 2>/dev/null || md5sum "$1" | cut -d' ' -f1; }
block() { BLOCK="${1%% *}"; printf '\n=== %s ===\n' "$1"; }
# javadoc that names a thing is not a use of it: every source count below is code-only
code() { grep -hvE '^[[:space:]]*(\*|//|/\*)' "$@"; }
clean() { sed -E -e 's/, Time elapsed: [0-9.]+ s//' -e 's/ -- Time elapsed: [0-9.]+ s//' \
                 -e "s#${PWD}/#<project>/#g" \
                 -e 's#[^ ]*/c3-unit16/#<project>/#g' \
                 -e 's#/Users/[^/]*/#<home>/#g'; }

# THE FLAKE'S OWN SOURCE. Every multi-run block below builds this one class, so every one of
# them counts its @Test methods from here - not from src/test, which is a different project.
RACE_SRC=breaks/sleep-race/src/test/java/com/tiffinbox/RailSleepTest.java

# A BUILD THAT RAN NO TEST IS NOT A PASS. `mvn test` over a class surefire did not select exits
# 0 and prints no Tests run: line at all, so a loop that reads only the exit status counts it
# as a clean run and reports a green sweep over nothing. run_fixed always asserted this; run_race
# and run_retry did not, and a class renamed inside its own file was enough to make both of them
# print a spotless receipt over zero tests. These two helpers are that assertion, shared.
want_tests() {   # $1 = a test source. Echoes its @Test count. Caller: want=$(want_tests f) || exit 1
  [ -f "$1" ] || die "$1 is not in this project, so there is no test count to assert a run against"
  local w; w=$(code "$1" | grep -c '@Test')
  [ "$w" -gt 0 ] || die "$1 declares no @Test method, so no run of it can be checked"
  printf '%s' "$w"
}
assert_ran() {   # $1 = that run's log, $2 = what the source declares, $3 = what to call the run
  # a failing run says [ERROR] Tests run:, a rescued one says [WARNING] Tests run:, a clean one [INFO]
  local ran; ran=$(grep -E '^\[(INFO|WARNING|ERROR)\] Tests run: [0-9]+, Failures' "$1" | tail -1 \
                   | sed -E 's/.*Tests run: ([0-9]+).*/\1/')
  [ -n "$ran" ] && [ "$ran" -ge "$2" ] \
    || die "$3 executed '$ran' of $2 test(s) - a run that executed no test is not a pass, and a sweep over it is not a receipt"
}

run_tests() {
  block "tests - the unit's own suite, all green"
  "${MVN[@]}" test > .r-tests.raw 2>&1; rc=$?
  [ "$rc" -eq 0 ] || die "mvn test exited $rc - this unit's own suite is not green"
  grep -E '^\[INFO\] Tests run:' .r-tests.raw | clean > .r-tests.out
  [ -s .r-tests.out ] || die "no Tests run: line in the run"
  # DERIVED: not one of these tests can see the machine's clock or guess at a duration
  printf 'test sources: %s; lines calling LocalDate.now() with no argument: %s; lines calling Thread.sleep: %s\n' \
    "$(ls src/test/java/com/tiffinbox/*.java | wc -l | tr -d ' ')" \
    "$(code src/test/java/com/tiffinbox/*.java src/main/java/com/tiffinbox/Billing.java | grep -c 'LocalDate\.now()')" \
    "$(code src/test/java/com/tiffinbox/*.java | grep -c 'Thread\.sleep')" >> .r-tests.out
  cat .r-tests.out
  rm -f .r-tests.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-tests.out)" "$rc"
}

run_clock() {
  block "clock - a wrong sum, and the two dates that show it"
  ( cd breaks/wrong-arithmetic && rm -rf target \
      && mvn -B -Dmaven.repo.local="$REPO" test > ../../.r-clock.raw 2>&1 ); rc=$?
  [ "$rc" -ne 0 ] || die "breaks/wrong-arithmetic passed - the wrong sum is no longer visible on any day"
  { grep -E '^agrees with the calendar' .r-clock.raw
    sed -n '/^\[INFO\] Results:/,/^\[ERROR\] Tests run:/p' .r-clock.raw
  } | clean > .r-clock.out
  grep -q '^agrees with the calendar' .r-clock.out \
    || die "the test printed no 'agrees with the calendar' line - there is no fraction to derive"
  # DERIVED from the line the test itself printed, so the fraction cannot be typed wrong
  awk '/^agrees with the calendar on/ {print "the wrong sum is invisible on " $6 " of " $8 " days, i.e. red on " ($8-$6) " of them"}' \
    .r-clock.raw >> .r-clock.out
  cat .r-clock.out
  rm -f .r-clock.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-clock.out)" "$rc"
}

run_race() {
  block "race - one millisecond of sleep, $RUNS cold surefire forks at each of three queue lengths, $SWEEPS sweep(s)"
  ( cd breaks/sleep-race && rm -rf target && mvn -B -q -Dmaven.repo.local="$REPO" test-compile ) \
    > /dev/null 2>&1 || die "breaks/sleep-race does not compile"
  # how many tests every run below MUST execute. Without this the block cannot tell a green
  # sweep from a sweep in which surefire selected nothing at all.
  want=$(want_tests "$RACE_SRC") || exit 1
  rm -f .r-race-worst.raw .r-race-counts.raw
  worst=0
  # the machine was not idle, and this block says so in its own output rather than in a note
  printf 'load average when this block started: %s\n' "$(uptime | sed -E 's/.*[Ll]oad averages?: //')"
  # the ORDERS the shipped test uses when nobody passes -Dorders, read out of the source
  ships=$(code "$RACE_SRC" | grep -oE 'Integer\.getInteger\("orders", [0-9_]+\)' \
          | grep -oE '[0-9][0-9_]*' | tr -d '_')
  [ -n "$ships" ] || die "$RACE_SRC no longer reads -Dorders with a default, so the shipped queue length cannot be read out of the source"
  printf 'the length this test ships with, read out of RailSleepTest.java: %s\n' "$ships"
  sweep=0
  while [ "$sweep" -lt "$SWEEPS" ]; do
    sweep=$((sweep+1))
    [ "$SWEEPS" -gt 1 ] && printf 'sweep %s of %s - the identical command, the same three lengths:\n' "$sweep" "$SWEEPS"
    counts=""
    for n in $LENGTHS; do
      fails=0
      printf '%7s orders: ' "$n"
      for i in $(seq 1 "$RUNS"); do
        if ( cd breaks/sleep-race && mvn -B -Dmaven.repo.local="$REPO" -Dorders="$n" test \
               > ../../.r-race-last.raw 2>&1 ); then
          printf '.'
        else
          printf 'F'; fails=$((fails+1))
          if [ "$n" -ge "$worst" ]; then worst=$n; cp .r-race-last.raw .r-race-worst.raw; fi
        fi
        # a dot means the build was green, which is not the same as the test having run
        assert_ran .r-race-last.raw "$want" "$n orders, run $i of $RUNS (sweep $sweep)"
      done
      # DERIVED: both numbers come from this loop, and neither is ever printed without the other
      printf '   failed %s of %s runs of `mvn test` in this session\n' "$fails" "$RUNS"
      counts="$counts $fails"
      printf '%s %s %s\n' "$n" "$fails" "$sweep" >> .r-race-counts.raw
    done
    # DERIVED, and this is the line that replaced an author's claim: did the count actually
    # track the queue length in THIS sweep? Computed from the counts the loop just printed.
    rose=yes; prev=-1
    for c in $counts; do [ "$c" -lt "$prev" ] && rose=no; prev=$c; done
    printf 'counts, shortest queue first:%s - did the count rise with the queue length? %s\n' "$counts" "$rose"
  done
  # DERIVED across the sweeps, from the same counts: how many sweeps had the count rise with the
  # queue length at all, and how far ONE length moves when the identical sweep is run again.
  # These three lines are the whole reason no slide in this unit claims an ordering.
  if [ "$SWEEPS" -gt 1 ]; then
    awk '{ n=$1; f=$2; s=$3
           if (!(n in lo) || f<lo[n]) lo[n]=f
           if (!(n in hi) || f>hi[n]) hi[n]=f
           if (!(s in slo) || f<slo[s]) slo[s]=f
           if (!(s in shi) || f>shi[s]) shi[s]=f
           if (s in prev && f < prev[s]) fell[s]=1
           prev[s]=f; seen[s]=1 }
         END { w=-1; wn=""
               for (n in lo) { d=hi[n]-lo[n]; if (d>w) { w=d; wn=n } }
               g=-1
               for (s in slo) { d=shi[s]-slo[s]; if (d>g) g=d }
               ns=0; nr=0
               for (s in seen) { ns++; if (!(s in fell)) nr++ }
               printf "the count rose with the queue length in %d of %d sweeps\n", nr, ns
               printf "the SAME length, swept again, moved by up to %d runs (at %s orders)\n", w, wn
               printf "the three DIFFERENT lengths, inside one sweep, spanned at most %d runs\n", g }' \
      .r-race-counts.raw
  fi
  if [ -f .r-race-worst.raw ]; then
    printf 'one of those failures, in full (at %s orders):\n' "$worst"
    sed -n '/^\[INFO\] Results:/,/^\[ERROR\] Tests run:/p' .r-race-worst.raw | clean
    printf 'the number it reached is NOT stable and is never quoted as one: '
    grep -h 'but was:' .r-race-worst.raw | tr -d ' ' | head -1
  else
    printf 'no run failed at any length in this session - the race did not fire here, and no\n'
    printf 'slide may show a failure captured somewhere else as if it were this run\n'
  fi
  printf 'load average when this block finished: %s\n' "$(uptime | sed -E 's/.*[Ll]oad averages?: //')"
  rm -f .r-race-last.raw .r-race-worst.raw .r-race-counts.raw
  printf 'no md5: a flake has no byte-identical output, which is the whole finding\n'
}

run_retry() {
  block "retry - -Dsurefire.rerunFailingTestsCount=2 over the same flake, $RUNS runs at $RETRY_ORDERS orders"
  # the same assertion the race block makes: a run surefire skipped entirely would otherwise be
  # counted here as one that "passed clean", which is the most flattering lie this block can tell
  want=$(want_tests "$RACE_SRC") || exit 1
  red=0; flaked=0
  for i in $(seq 1 "$RUNS"); do
    if ( cd breaks/sleep-race && mvn -B -Dmaven.repo.local="$REPO" -Dorders="$RETRY_ORDERS" \
           -Dsurefire.rerunFailingTestsCount=2 test > ../../.r-retry.raw 2>&1 ); then
      if grep -q 'Flakes: [1-9]' .r-retry.raw; then
        flaked=$((flaked+1)); printf 'f'; cp .r-retry.raw .r-retry-keep.raw
      else
        printf '.'
      fi
    else
      red=$((red+1)); printf 'F'
    fi
    assert_ran .r-retry.raw "$want" "retry run $i of $RUNS"
  done
  printf '\n'
  # DERIVED: three numbers from one loop - green, green-but-flagged, and red
  printf 'of %s runs at %s orders: %s failed the build, %s passed WITH a recorded flake, %s passed clean\n' \
    "$RUNS" "$RETRY_ORDERS" "$red" "$flaked" "$((RUNS-red-flaked))"
  if [ -f .r-retry-keep.raw ]; then
    printf 'what a rescued run looks like:\n'
    sed -n '/^\[WARNING\] Flakes:/,/^\[INFO\] BUILD/p' .r-retry-keep.raw | clean
  else
    printf 'no run in this session was rescued by a rerun, so this session has no Flakes: block\n'
    printf 'to show; a slide that needs one must be recorded from a session that produced one\n'
  fi
  rm -f .r-retry.raw .r-retry-keep.raw
  printf 'no md5: a retried flake has no byte-identical output either\n'
}

run_fixed() {
  block "fixed - the two rewrites, $RUNS runs each"
  for cls in RailCloseFirstTest RailAwaitilityTest; do
    [ -f "src/test/java/com/tiffinbox/$cls.java" ] || die "$cls.java is not in this project"
    want=$(code "src/test/java/com/tiffinbox/$cls.java" | grep -c '@Test')
    [ "$want" -gt 0 ] || die "$cls declares no @Test method"
    fails=0
    for i in $(seq 1 "$RUNS"); do
      # NO -DfailIfNoSpecifiedTests=false: if the filter ever stops matching, Maven fails
      # the build and this loop counts that as a failure instead of reporting a clean sweep
      # over a class that never ran.
      "${MVN[@]}" -Dtest="$cls" test > .r-fixed-last.raw 2>&1 || fails=$((fails+1))
      ran=$(grep -E '^\[(INFO|ERROR)\] Tests run: [0-9]+, Failures' .r-fixed-last.raw | tail -1 \
            | sed -E 's/.*Tests run: ([0-9]+).*/\1/')
      [ -n "$ran" ] && [ "$ran" -ge "$want" ] \
        || die "$cls: run $i executed '$ran' of $want test(s) - a green sweep over a class that did not run is not a receipt"
    done
    printf '%-22s failed %s of %s, and ran %s test(s) every time\n' "$cls" "$fails" "$RUNS" "$want"
  done
  rm -f .r-fixed-last.raw
  # DERIVED: what each rewrite actually waits on, and WHERE - close() after the assertion is
  # cleanup; close() before it is the barrier. Read the two line numbers out of the sources.
  # Each grep is checked: an empty line number is a grep that found nothing, and a slide-facing
  # line with a hole in it is worse than a block that stops.
  [ -f "$RACE_SRC" ] || die "$RACE_SRC is not in this project, so slide 3's two line numbers cannot be derived"
  sleep_close=$(grep -n 'q\.close()' "$RACE_SRC" | head -1 | cut -d: -f1)
  sleep_assert=$(grep -n 'assertThat(q\.cooked())' "$RACE_SRC" | head -1 | cut -d: -f1)
  fix_close=$(grep -n 'q\.close()' src/test/java/com/tiffinbox/RailCloseFirstTest.java | head -1 | cut -d: -f1)
  fix_assert=$(grep -n 'assertThat(q\.cooked())' src/test/java/com/tiffinbox/RailCloseFirstTest.java | head -1 | cut -d: -f1)
  for v in "$sleep_close" "$sleep_assert" "$fix_close" "$fix_assert"; do
    [ -n "$v" ] || die "one of slide 3's four line numbers came back empty - a line number no grep found is not a receipt"
  done
  printf 'RailSleepTest calls q.close() on source line %s and asserts on line %s; RailCloseFirstTest closes on line %s and asserts on line %s\n' \
    "$sleep_close" "$sleep_assert" "$fix_close" "$fix_assert"
  waits=$(grep -oE 'await\("[^"]*"\)' src/test/java/com/tiffinbox/RailAwaitilityTest.java | head -1)
  [ -n "$waits" ] || die "RailAwaitilityTest no longer calls await(\"...\") - the 'waits on' line would print empty"
  printf 'RailAwaitilityTest waits on: %s\n' "$waits"
  printf 'no md5: these two counts are measured against a race, so they are reported with their N and never hashed\n'
}

run_classpath() {
  block "classpath - what came off the test classpath when Mockito came off this project"
  here="$PWD"; prev="$here/../c3-unit15"
  [ -d "$prev" ] || die "c3-unit15 is not beside this unit, so the seam cannot be derived here"
  # THE RULE, and the slide states it in these words: every entry that
  # `dependency:build-classpath -DincludeScope=test` prints - the carried compile-scope h2 included.
  # Nothing is silently excluded, because a count a viewer cannot reproduce is not a receipt.
  # AN EXIT CODE IS MEASURED OR IT IS NOT PRINTED. This block used to print `exit 0` as a
  # printf literal - the only typed exit code in this section's receipts. It is now the worst
  # status the two builds actually returned, read from $? the way every other block here reads it.
  cp_rc=0
  for tag in prev here; do
    eval "dir=\$$tag"
    ( cd "$dir" && mvn -B -q -Dmaven.repo.local="$REPO" dependency:build-classpath \
        -DincludeScope=test -Dmdep.outputFile="$here/.r-cp-$tag.raw" ) > /dev/null 2>&1; rc=$?
    [ "$rc" -gt "$cp_rc" ] && cp_rc=$rc
    [ "$rc" -eq 0 ] || die "dependency:build-classpath exited $rc in $dir - there is no classpath to compare"
    tr ':' '\n' < ".r-cp-$tag.raw" | sed 's#.*/##' | sort > ".r-cp-$tag-list.raw"
  done
  { printf 'rule: every entry `mvn -B dependency:build-classpath -DincludeScope=test` prints, the carried compile-scope h2 included\n'
    printf 'test classpath entries - the unit before this one: %s; this unit: %s\n' \
      "$(wc -l < .r-cp-prev-list.raw | tr -d ' ')" "$(wc -l < .r-cp-here-list.raw | tr -d ' ')"
    printf 'gone (%s):%s\n' \
      "$(comm -23 .r-cp-prev-list.raw .r-cp-here-list.raw | wc -l | tr -d ' ')" \
      "$(comm -23 .r-cp-prev-list.raw .r-cp-here-list.raw | tr '\n' ' ' | sed 's/ $//;s/^/ /')"
    printf 'arrived (%s):%s\n' \
      "$(comm -13 .r-cp-prev-list.raw .r-cp-here-list.raw | wc -l | tr -d ' ')" \
      "$(comm -13 .r-cp-prev-list.raw .r-cp-here-list.raw | tr '\n' ' ' | sed 's/ $//;s/^/ /')"
    printf 'stayed (%s):%s\n' \
      "$(comm -12 .r-cp-prev-list.raw .r-cp-here-list.raw | wc -l | tr -d ' ')" \
      "$(comm -12 .r-cp-prev-list.raw .r-cp-here-list.raw | tr '\n' ' ' | sed 's/ $//;s/^/ /')"
  } > .r-classpath.out
  cat .r-classpath.out
  rm -f .r-cp-prev.raw .r-cp-here.raw .r-cp-prev-list.raw .r-cp-here-list.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-classpath.out)" "$cp_rc"
}

run_solution() {
  block "solution - the exercise answer, actually run"
  rm -rf .sol && cp -R exercise .sol && rm -rf .sol/solution .sol/target
  cp exercise/solution/Billing.java .sol/src/main/java/com/tiffinbox/Billing.java
  ( cd .sol && mvn -B -Dmaven.repo.local="$REPO" test > ../.r-sol.raw 2>&1 ); rc=$?
  [ "$rc" -eq 0 ] || die "the exercise answer exited $rc - it does not pass"
  grep -E '^\[INFO\] Tests run:|^\[INFO\] BUILD' .r-sol.raw | clean > .r-solution.out
  [ -s .r-solution.out ] || die "the answer printed no Tests run: line"
  # DERIVED, code lines only: how many lines of the class mention a Clock before and after
  printf 'code lines naming Clock - starting class: %s, answer: %s\n' \
    "$(code exercise/src/main/java/com/tiffinbox/Billing.java | grep -c 'Clock')" \
    "$(code exercise/solution/Billing.java | grep -c 'Clock')" >> .r-solution.out
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

ALL=(tests clock classpath race retry fixed solution offline)
TARGETS=("$@")
[ ${#TARGETS[@]} -eq 0 ] && TARGETS=("${ALL[@]}")
for t in "${TARGETS[@]}"; do "run_$t"; done
