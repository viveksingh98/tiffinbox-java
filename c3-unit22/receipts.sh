#!/bin/bash
# receipts.sh - regenerate every number this unit puts on a slide.
#
#   ./receipts.sh            run every block
#   ./receipts.sh scores     run one block
#
# THE RULE THIS UNIT EXISTS TO SETTLE, AND IT IS WHY THIS FILE IS SPLIT THE WAY IT IS.
#
# The course's measurement rule says a duration is never a fact. This unit's subject is a
# tool whose whole purpose is to produce durations. Both are true, and the split below is
# what makes them consistent:
#
#   HASHED .............. everything that is NOT a duration. The harness's own conditions
#                         (mode, forks, warm-up, measurement iterations, unit, blackhole
#                         mode), the warnings the JVM prints, the text JMH prints about its
#                         own numbers, the benchmark names, the Cnt column, and - for the
#                         naive stopwatch - a count of what its output does NOT contain.
#                         Every one of those is the same on any machine.
#
#   PRINTED, NEVER HASHED  every Score, every Error, every JFR count. These are properties
#                         of this Mac on this afternoon. A hash over them would claim a
#                         reproducibility that does not exist, which is the exact defect
#                         this course has shipped three blockers about. The blocks that
#                         print them SAY SO IN THEIR OWN OUTPUT, the way the concurrency
#                         unit's race blocks do.
#
#   VERDICTS .............. derived from the run, guarded, and printed beside the numbers -
#                         "the two intervals overlap: yes" is a fact about this run and the
#                         block dies rather than guess it.
#
# Everything else follows the section's four rules: a derived line is part of the capture,
# a block that cannot measure must not print, every block measures its own run, and every
# clock is masked before anything is hashed.

set -u
set -o pipefail
cd "$(dirname "$0")" || exit 1

export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"

REPO="$PWD/.m2-demo"
MVN=(mvn -B -Dmaven.repo.local="$REPO")
JAR=target/benchmarks.jar

die() { printf '\nRECEIPT FAILED (%s): %s\n' "${BLOCK:-?}" "$1" >&2; exit 1; }
hash_of() { md5 -q "$1" 2>/dev/null || md5sum "$1" | cut -d' ' -f1; }
block() { BLOCK="${1%% *}"; printf '\n=== %s ===\n' "$1"; }
nohash() { printf 'no md5: %s\n' "$1"; }

mask() { sed -E -e 's#file:[^ )]*/benchmarks\.jar#file:<project>/target/benchmarks.jar#g' \
                -e "s#${PWD}/#<project>/#g" \
                -e 's#[^ ]*/c3-unit22/#<project>/#g' \
                -e 's#/Users/[^/]*/#<home>/#g' \
                -e 's/, Time elapsed: [0-9.]+ s//' -e 's/ -- Time elapsed: [0-9.]+ s//'; }

# A count's label must name what it counted. A javadoc line reading {@code @Fork(2)} is not
# an annotation, and this block found that out: two matches in one file made "forks 2" read
# "forks 22". Drop whole comment lines AND trailing // comments before any source count.
code_only() { grep -vE '^[[:space:]]*(\*|//|/\*)' "$1" | sed -E 's#[[:space:]]*//.*$##'; }

# awk over JMH's result table, which has a different shape depending on whether the
# benchmark declares an @Param. Two readers, so neither has to guess.
#
#   no param:  Benchmark          Mode Cnt Score  +- Error Units    -> $2 $3 $4 $5 $6
#   @Param:    Benchmark (rows)   Mode Cnt Score  +- Error Units    -> $3 $4 $5 $6 $7
jmh_col() {   # $1 = benchmark suffix, $2 = cnt|score|error ; reads a JMH stdout file
  awk -v name="$1" -v want="$2" '
    $1 ~ ("\\." name "$") {
      if (want=="cnt")   print $3;
      if (want=="score") print $4;
      if (want=="error") { if ($5 == "±") print $6; else print "" }
    }'
}
jmh_p() {     # $1 = benchmark suffix, $2 = the @Param value, $3 = cnt|score|error
  awk -v name="$1" -v par="$2" -v want="$3" '
    $1 ~ ("\\." name "$") && $2 == par {
      if (want=="cnt")   print $4;
      if (want=="score") print $5;
      if (want=="error") { if ($6 == "±") print $7; else print "" }
    }'
}

# The @Param values this unit runs at, read out of the benchmark rather than typed here.
param_values() {
  code_only src/main/java/com/tiffinbox/bench/ReceiptBench.java \
    | grep -oE '@Param\(\{[^}]*\}\)' | grep -oE '[0-9]+' | tr '\n' ' '
}

package_once() {
  [ -f "$JAR" ] && return 0
  "${MVN[@]}" -q clean package > .r-pkg.raw 2>&1 || die "mvn package failed; see .r-pkg.raw"
  [ -f "$JAR" ] || die "no $JAR after package - the shade plugin produced nothing"
}

# ---------------------------------------------------------------- harness ----
# HASHED. Nothing here is a duration; every line is a condition or a warning.
run_harness() {
  block "harness - the conditions JMH prints whether you ask or not  [HASHED]"
  "${MVN[@]}" -q clean package > .r-pkg.raw 2>&1; local rcp=$?
  [ "$rcp" -eq 0 ] || die "mvn package exited $rcp"
  [ -f "$JAR" ] || die "no $JAR"

  # -f 0 runs in the harness JVM: enough to make JMH print its own configuration and the
  # JDK warnings, without spending two forks on a block that measures no time at all.
  java -jar "$JAR" -f 0 -wi 1 -w 1s -i 1 -r 1s ReceiptBench.stringBuilder > .r-h.raw 2>&1
  local rc=$?
  [ "$rc" -eq 0 ] || die "the harness run exited $rc"

  # @Param makes JMH print its WHOLE configuration header once per size, so a bare grep
  # over this file pastes the same eight lines twice and leaves a panel head to explain a
  # duplicate. Take the FIRST header block only, and state how many times it repeated as a
  # derived line inside the hash - a counted account of the cut rather than a silent one.
  local hdrs
  hdrs=$(grep -c '^# JMH version:' .r-h.raw)
  [ "$hdrs" -ge 1 ] || die "JMH printed no configuration header at all"
  first_header() { awk '/^# JMH version:/{n++} n==1' .r-h.raw; }

  { printf 'the conditions, printed by JMH itself:\n'
    # The colons matter: "# Warmup:" is the CONFIGURATION line, "# Warmup Iteration 1:"
    # is a duration, and a duration must not enter a hashed block.
    first_header | grep -E '^# (JMH version:|VM version:|Warmup:|Measurement:|Timeout:|Threads:|Benchmark mode:|Blackhole mode:)' | mask
    # And what the -f 0 in the command line above costs, in JMH's own words rather than
    # ours. These three lines were once filtered out before the hash, which left the panel
    # claiming conditions without the harness's own warning about them.
    printf '\nand what the -f 0 on the command line costs, in its own words:\n'
    first_header | grep -E '^# Fork: |^# \*\*\* WARNING' | mask
    printf '\nwhat the JVM says about JMH on JDK 25:\n'
    grep -E '^WARNING:' .r-h.raw | mask
    printf '\nwhat JMH says about its own numbers:\n'
    sed -n '/^REMEMBER:/,/^Do not assume/p' .r-h.raw | mask
    printf '\nand what it says about this JDK in particular:\n'
    sed -n '/^NOTE: Current JVM/,/^modes can be very significant/p' .r-h.raw | mask
  } > .r-harness.out

  local jmhv vmv warn fork wi mi unit
  jmhv=$(grep -m1 '^# JMH version:' .r-h.raw | awk '{print $4}')
  vmv=$(grep -m1 '^# VM version:' .r-h.raw | sed -E 's/^# VM version: JDK ([^,]*),.*/\1/')
  warn=$(grep -cE '^WARNING:' .r-h.raw)
  local BENCH=src/main/java/com/tiffinbox/bench/ReceiptBench.java
  fork=$(code_only "$BENCH" | grep -oE '@Fork\([0-9]+\)' | tr -cd '0-9')
  wi=$(code_only "$BENCH" | grep -oE '@Warmup\(iterations = [0-9]+' | tr -cd '0-9')
  mi=$(code_only "$BENCH" | grep -oE '@Measurement\(iterations = [0-9]+' | tr -cd '0-9')
  unit=$(code_only "$BENCH" | grep -oE '@OutputTimeUnit\(TimeUnit\.[A-Z]+\)' | sed 's/.*TimeUnit\.//; s/)//')
  [ -n "$jmhv" ] || die "JMH printed no version line"
  [ "$vmv" = "25.0.4.1" ] || die "the benchmark JVM is $vmv, not the 25.0.4.1 this unit measured"
  [ "$warn" -gt 0 ] || die "no JVM warning at all - the sun.misc.Unsafe line has gone, re-read it"
  [ -n "$fork" ] && [ -n "$wi" ] && [ -n "$mi" ] && [ -n "$unit" ] || die "could not read the annotations"
  local benches sizes
  # anchored: @BenchmarkMode is not a benchmark, and an unanchored grep counts it
  benches=$(code_only "$BENCH" | grep -cE '^[[:space:]]*@Benchmark[[:space:]]*$')
  sizes=$(param_values | wc -w | tr -d ' ')
  [ "$benches" -gt 0 ] && [ "$sizes" -gt 0 ] || die "read $benches @Benchmark and $sizes @Param size(s)"

  { printf '\nJMH version %s, benchmark JVM %s\n' "$jmhv" "$vmv"
    printf 'configuration headers JMH printed in this one run: %d - one per @Param size,\n' "$hdrs"
    printf '  so the eight lines above are the first of %d identical blocks, not the whole file\n' "$hdrs"
    printf 'WARNING lines the JVM printed: %d\n' "$warn"
    printf 'read out of ReceiptBench.java: forks %s, warm-up iterations %s, measurement iterations %s, unit %s\n' \
      "$fork" "$wi" "$mi" "$unit"
    printf 'so the Cnt column on a full run must read %d: %s forks x %s measurement iterations\n' \
      "$(( fork * mi ))" "$fork" "$mi"
    printf '@Param sizes, read out of the same file: %s- so the result table has %d benchmarks x %d sizes = %d rows\n' \
      "$(param_values)" "$benches" "$sizes" "$(( benches * sizes ))"
    printf 'none of the above is a duration, which is why this block carries a hash\n'
  } >> .r-harness.out
  cat .r-harness.out
  printf 'md5 %s  exit %d\n' "$(hash_of .r-harness.out)" "$rc"
}

# ------------------------------------------------------------------ naive ----
# HASHED: what the stopwatch's output does NOT contain. NOT HASHED: its numbers.
run_naive() {
  block "naive - the stopwatch, and what it cannot tell you  [structure HASHED, numbers not]"
  "${MVN[@]}" -q compile > .r-c.raw 2>&1 || die "compile failed"
  "${MVN[@]}" -q dependency:build-classpath -Dmdep.outputFile=.r-cp.txt > /dev/null 2>&1 \
    || die "could not build the classpath"

  local n=3 i
  : > .r-n.raw
  for ((i = 1; i <= n; i++)); do
    java -cp "target/classes:$(cat .r-cp.txt)" com.tiffinbox.bench.NaiveTimer >> .r-n.raw 2>&1 \
      || die "the naive timer exited non-zero on run $i"
  done

  # Every count below is over the RESULT lines only. NaiveTimer's own header says the words
  # "no warm-up", and counting that line as a line that states a warm-up is exactly the
  # label-versus-count defect this section keeps finding.
  #
  # AND THE SELECTOR IS NOT THE THING BEING COUNTED. This block used to select the result
  # rows with `grep ns/op` and then count `ns/op` among them, so the fifth count could not
  # come out as anything but the row count - a measurement that measures nothing, on the
  # slide that teaches measuring things properly. A row is a result row because it is not
  # the run header, and "carries a unit" is then a question that can be answered no.
  grep -vE '^naive: |^[[:space:]]*$' .r-n.raw > .r-nr.txt
  local lines warmup forks err cnt unit methods
  lines=$(grep -c . .r-nr.txt)
  warmup=$(grep -ciE 'warm.?up' .r-nr.txt)
  forks=$(grep -ciE 'fork' .r-nr.txt)
  err=$(grep -cE '±|\+/-' .r-nr.txt)
  cnt=$(grep -ciE '\bcnt\b|[0-9]+ samples?\b' .r-nr.txt)
  unit=$(grep -cE 'ns/op' .r-nr.txt)
  # The expected row count, read out of NaiveTimer.java rather than out of its output: one
  # time() call per method, n runs. If the two disagree the selector is wrong, not the run.
  methods=$(code_only src/main/java/com/tiffinbox/bench/NaiveTimer.java | grep -cE '^[[:space:]]*time\("')
  [ "$lines" -gt 0 ] || die "the naive timer printed no result line at all"
  [ "$methods" -gt 0 ] || die "could not read NaiveTimer's time() call sites"
  [ "$lines" -eq $(( n * methods )) ] \
    || die "selected $lines result row(s) where $n runs x $methods method(s) should give $(( n * methods )) - the row selector is wrong"

  { printf 'the naive stopwatch, run %d times. Of its %d result line(s):\n' "$n" "$lines"
    printf '  lines stating a warm-up ............ %d\n' "$warmup"
    printf '  lines stating a fork count ......... %d\n' "$forks"
    printf '  lines carrying an error term ....... %d\n' "$err"
    printf '  lines carrying the number of samples %d\n' "$cnt"
    printf '  lines carrying a unit .............. %d\n' "$unit"
    printf 'four of the five counts above are zero, and they are the four conditions this\n'
    printf 'course requires before a wall-clock number may go on a slide\n'
  } > .r-naive.out
  [ "$warmup" -eq 0 ] && [ "$forks" -eq 0 ] && [ "$err" -eq 0 ] && [ "$cnt" -eq 0 ] \
    || die "the naive output now states one of the four conditions ($warmup/$forks/$err/$cnt); rewrite the claim"
  cat .r-naive.out
  printf 'md5 %s  exit 0\n' "$(hash_of .r-naive.out)"

  printf '\nand here are its numbers, from %d runs on this machine:\n' "$n"
  mask < .r-n.raw

  # The ordering the stopwatch hands you, run by run. Derived from the same three runs.
  local wins
  wins=$(awk '/^concatInALoop/{c=$2} /^stringBuilder/{ if (c<$2) w++ } END{print w+0}' .r-n.raw)
  printf '\nruns in which concatInALoop came out ahead of stringBuilder: %d of %d\n' "$wins" "$n"
  if [ "$wins" -ne 0 ] && [ "$wins" -ne "$n" ]; then
    printf 'the stopwatch gave a confident ordering every time and did NOT give the same one twice.\n'
  else
    printf 'the stopwatch gave the same ordering all %d times - which is not the same thing as it\n' "$n"
    printf 'being right, because nothing in its output says how far apart the two numbers have to\n'
    printf 'be before the ordering means anything.\n'
  fi
  nohash "these are durations from one machine on one afternoon, and so is the count above them. The five counts inside the hash are the receipt; these are the data."
}

# ----------------------------------------------------------------- scores ----
# NOT HASHED, and it says so. The verdict IS derived and guarded.
run_scores() {
  block "scores - JMH over the same three methods, at two input sizes  [NOT HASHED]"
  package_once
  java -jar "$JAR" > .r-s.raw 2>&1; local rc=$?
  [ "$rc" -eq 0 ] || die "the benchmark run exited $rc"

  grep -E '^Benchmark |^ReceiptBench\.' .r-s.raw | mask
  grep -E '^ReceiptBench\.' .r-s.raw | grep -q '±' \
    || die "JMH printed no error term - with fewer than three samples it cannot, and without one there is nothing to read"

  local size verdicts=""
  printf '\n'
  for size in $(param_values); do
    local cs ce bs be v
    cs=$(jmh_p concatInALoop "$size" score < .r-s.raw); ce=$(jmh_p concatInALoop "$size" error < .r-s.raw)
    bs=$(jmh_p stringBuilder "$size" score < .r-s.raw); be=$(jmh_p stringBuilder "$size" error < .r-s.raw)
    [ -n "$cs" ] && [ -n "$ce" ] && [ -n "$bs" ] && [ -n "$be" ] \
      || die "no score-with-error pair at rows=$size"
    v=$(awk -v a="$cs" -v ae="$ce" -v b="$bs" -v be="$be" 'BEGIN{
        print ((a-ae)<=(b+be) && (b-be)<=(a+ae)) ? "OVERLAP" : (a<b ? "concat" : "builder") }')
    verdicts="$verdicts $v"
    awk -v s="$size" -v a="$cs" -v ae="$ce" -v b="$bs" -v be="$be" 'BEGIN{
        alo=a-ae; ahi=a+ae; blo=b-be; bhi=b+be;
        over = (alo<=bhi && blo<=ahi);
        printf "rows=%-4s concatInALoop [%.3f, %.3f]   stringBuilder [%.3f, %.3f]   %s\n",
               s, alo, ahi, blo, bhi, over ? "the intervals OVERLAP" : (a<b ? "concat is ahead" : "stringBuilder is ahead") }'
  done
  # DERIVE THE SENTENCE THE SLIDE SPEAKS, AND ASSERT IT. This block used to print whatever
  # came out while the slide said "at six rows concatenation is ahead, at six hundred the
  # builder wins" as a fixed fact about an unhashed number. The verdicts below are that
  # sentence, computed from this run's own intervals, and the block stops rather than let
  # a spoken line contradict the panel underneath it.
  verdicts=$(printf '%s' "$verdicts" | xargs)
  printf 'the verdict at each size, smallest first: %s\n' "$verdicts"
  case "$verdicts" in
    *OVERLAP*)
      die "an interval pair OVERLAPS on this run ($verdicts). That is section 2c's answer and it is a legitimate result - 'I could not measure a difference above the noise on this machine' - but it is NOT the beat slide 4 speaks. Re-cut the slide to say it, or re-run on a quiet machine; do not quote a different number." ;;
    "concat builder") : ;;
    *)
      die "the two sizes gave $verdicts - the small size no longer contradicts the large one, so this unit's whole argument has evaporated. Re-cut slide 4; do not quote a different number." ;;
  esac
  printf 'the two sizes do not give the same answer, and that is the result: a benchmark at one\n'
  printf 'input size measures an algorithm at one input size. Reading the small row as a rule is\n'
  printf 'how folklore gets written down.\n'
  nohash "every Score and Error above is a property of this Mac on this afternoon. Re-run it on yours; the conditions in ./receipts.sh harness are what stay the same, and ./receipts.sh sweep is what says whether one reading is worth anything."
}

# --------------------------------------------------------------- deadcode ----
# NOT HASHED. The verdict is derived and guarded.
run_deadcode() {
  block "deadcode - the same call, four ways  [NOT HASHED]"
  ( cd breaks/no-blackhole && "${MVN[@]}" -q clean package ) > .r-dcp.raw 2>&1 \
    || die "the break did not package"
  java -jar breaks/no-blackhole/target/benchmarks.jar > .r-d.raw 2>&1; local rc=$?
  [ "$rc" -eq 0 ] || die "the dead-code run exited $rc"

  grep -E '^Benchmark |^DeadCodeBench\.' .r-d.raw | mask
  local base disc cons ret
  base=$(jmh_col baseline  score < .r-d.raw)
  disc=$(jmh_col discarded score < .r-d.raw)
  cons=$(jmh_col consumed  score < .r-d.raw)
  ret=$(jmh_col returned   score < .r-d.raw)
  [ -n "$base" ] && [ -n "$disc" ] && [ -n "$cons" ] && [ -n "$ret" ] \
    || die "one of the four benchmarks produced no score"

  # A DIFFERENCE OF TWO JMH SCORES CARRIES THEIR ERRORS (contract 2e). Printing 0.128
  # bare was the precise sin this unit exists to correct: it is a difference of two scores
  # whose own errors are larger than it, and the propagated interval is what says so.
  local baseE discE consE
  baseE=$(jmh_col baseline  error < .r-d.raw)
  discE=$(jmh_col discarded error < .r-d.raw)
  consE=$(jmh_col consumed  error < .r-d.raw)
  [ -n "$baseE" ] && [ -n "$discE" ] && [ -n "$consE" ] \
    || die "JMH printed no error term on one of the four rows - with fewer than three samples it cannot, and a bare score is not allowed on a slide"

  awk -v b="$base" -v be="$baseE" -v d="$disc" -v de="$discE" \
      -v c="$cons" -v ce="$consE" -v r="$ret" 'BEGIN{
    dw = c-b; dwe = sqrt(ce*ce + be*be);
    dd = d-b; dde = sqrt(de*de + be*be);
    printf "\nthe work, as measured by the benchmark that consumes it: %.3f - %.3f = %.3f +- %.3f ns/op\n", c, b, dw, dwe;
    printf "the same work, discarded:                                %.3f - %.3f = %.3f +- %.3f ns/op\n", d, b, dd, dde;
    printf "consumed and returned agree: %s\n", (r-c < 0.05 && c-r < 0.05) ? "yes" : "no";
    f = dd/dw; if (f < 0) f = -f;
    printf "what is left of the discarded call, as a fraction of the work measured: %.2f  (the guard: below 0.50)\n", f;
  }'
  # THE GUARDS, AND THEY ASSERT THE SENTENCE THE VOICE SPEAKS, NOT A SIGN.
  #
  # The difference between `discarded` and an empty method is noise: on this Mac it has
  # come out -0.010, +0.033, -0.011, +0.041, -0.033, +0.028 and +0.014 ns/op across seven
  # runs, and the block that asserted only `(d-b) < 0.5*(c-b)` let a POSITIVE number reach
  # the screen under a spoken line that said "below". The sign is not the lesson and must
  # not be asserted.
  #
  # Nor is "its error bar straddles zero" - that was tried here and it is wrong. On a
  # quiet run JMH resolved baseline to +-0.011 and discarded to +-0.003, so a fourteen-
  # PICOSECOND difference came out statistically separated while being nine percent of the
  # work and physically nothing. A tighter instrument does not make a non-difference real.
  #
  # What IS reproducible, in either direction and at every error bar seen so far, is that
  # whatever is left of the discarded call is a small FRACTION of the work the Blackhole
  # version measured. That is a ratio (contract 2a rank 3), it is what is printed, and it
  # is what the guard below asserts.
  awk -v b="$base" -v d="$disc" -v c="$cons" 'BEGIN{ x=d-b; if (x<0) x=-x; exit !(x < 0.5*(c-b)) }' \
    || die "discarded is no longer indistinguishable from the baseline - the JIT did not eliminate it on this run"
  awk -v b="$base" -v c="$cons" 'BEGIN{ exit !((c-b) > 0) }' \
    || die "consumed is not above the baseline - there is no work to eliminate"
  printf 'so the number for "discarded" is not a small measurement of the work. It is an\n'
  printf 'accurate measurement of nothing happening, and nothing in the output says so.\n'
  nohash "four durations from one machine, and the sign of the discarded difference is noise - it comes out above the baseline about as often as below. What is reproducible is the SHAPE - discarded cannot be told apart from the empty method in either direction, consumed and returned sit above it - and that shape is what the two guards above assert."
}

# -------------------------------------------------------------------- jfr ----
# NOT HASHED. The warm-up, as a count of compilations rather than as a duration.
run_jfr() {
  block "jfr - the warm-up you were told about, counted  [NOT HASHED]"
  package_once
  rm -f target/bench.jfr
  java -jar "$JAR" -f 1 -wi 4 -w 1s -i 4 -r 1s \
     -jvmArgsAppend "-XX:StartFlightRecording=filename=target/bench.jfr,settings=profile,dumponexit=true" \
     ReceiptBench.stringBuilder > .r-j.raw 2>&1
  local rc=$?
  [ "$rc" -eq 0 ] || die "the recorded run exited $rc"
  [ -s target/bench.jfr ] || die "no target/bench.jfr - the recorder never started"

  printf 'the recording exists, which is the artifact - not the exit code:\n'
  printf '  target/bench.jfr, %s bytes\n' "$(wc -c < target/bench.jfr | tr -d ' ')"
  printf '\njfr summary target/bench.jfr - the five biggest event types:\n'
  jfr summary target/bench.jfr | sed -n '/Event Type/,$p' | sed -n '3,7p'

  printf '\njfr print --events jdk.CompilerStatistics - compileCount, one snapshot a second:\n'
  jfr print --events jdk.CompilerStatistics target/bench.jfr \
    | grep -E 'compileCount' | awk '{print $3}' > .r-cc.txt
  local n first last
  n=$(grep -c . .r-cc.txt)
  [ "$n" -ge 3 ] || die "only $n CompilerStatistics snapshot(s) - not enough to see a shape"
  awk 'NR==1{prev=$1; printf "  snapshot %2d: %6d compiled\n", NR, $1; next}
            {printf "  snapshot %2d: %6d compiled  (+%d since the last one)\n", NR, $1, $1-prev; prev=$1}' .r-cc.txt
  first=$(awk 'NR==2{print $1-p} {p=$1}' .r-cc.txt)
  last=$(awk '{d=$1-p; p=$1} END{print d}' .r-cc.txt)
  [ -n "$first" ] && [ -n "$last" ] || die "could not compute the first and last deltas"
  printf '\nnew compilations in the first interval: %s ; in the last: %s\n' "$first" "$last"
  # THE INTEGERS ARE THIS RUN'S; THE RATIO IS THE CLAIM. Measured here as 21 -> 1, 22 -> 2
  # and 23 -> 2 on three separate runs, so no spoken line may name either numeral - but
  # every one of those runs clears "at least four times", and that is what is said aloud.
  # A ratio rather than a quotient, so a last interval of 0 is not a division by zero.
  [ "$first" -gt "$last" ] || die "the compilation rate did not fall ($first -> $last) - this run shows no warm-up"
  printf 'the first interval compiled at least four times what the last one did: %s\n' \
    "$( [ "$first" -ge $(( 4 * last )) ] && echo yes || echo no )"
  [ "$first" -ge $(( 4 * last )) ] \
    || die "the first interval ($first) is not at least four times the last ($last) - the fall is there but it is not the fall this slide speaks; re-cut the line or re-run on a quiet machine"
  printf 'that fall IS the warm-up. It is why the harness throws the first iterations away,\n'
  printf 'and it is a count of compilations rather than a duration - which is why it is here.\n'
  nohash "every count above is this JVM on this machine on this run, and the integers move run to run. What is asserted is the RATIO - the first interval compiles at least four times what the last one does - and the two guards above are what assert it."
}

# ---------------------------------------------------------------- release ----
# HASHED. Derived offline from central/.
run_release() {
  block "release - JMH's last release date is a fact, not an embarrassment  [HASHED]"
  local md dir
  md=central/jmh-core-maven-metadata.xml
  dir=central/jmh-core-directory-listing.html
  [ -f "$md" ] && [ -f "$dir" ] || die "central/ is missing - see central/README.md"

  local total rel last pinned pub prerel
  total=$(grep -c '<version>' "$md")
  rel=$(grep -oE '<release>[^<]*' "$md" | sed 's/<release>//')
  last=$(grep -oE '<version>[^<]*</version>' "$md" | sed 's/<[^>]*>//g' | tail -1)
  pinned=$(grep -oE '<jmh.version>[^<]*' pom.xml | sed 's/<jmh.version>//')
  pub=$(sed 's/<[^>]*>/ /g' "$dir" | grep -E "(^| )$rel/ " | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
  prerel=$(grep -oE '<version>[^<]*</version>' "$md" | sed 's/<[^>]*>//g' \
           | grep -ciE 'rc|alpha|beta|-M[0-9]|milestone' || true)
  [ "$total" -gt 0 ] && [ -n "$rel" ] && [ -n "$pub" ] || die "could not parse $md / $dir"
  [ "$rel" = "$last" ] || die "<release> ($rel) is not the last entry of the version list ($last)"
  [ "$pinned" = "$rel" ] || die "this pom pins $pinned while the newest is $rel"

  { printf 'org.openjdk.jmh:jmh-core, read from central/ with no network\n'
    printf '  versions in the list ............ %s\n' "$total"
    printf '  <release> field says ............ %s\n' "$rel"
    printf '  last entry of the version list .. %s  (the same string: yes)\n' "$last"
    printf '  published ....................... %s\n' "$pub"
    printf '  pre-release entries anywhere in the list: %s\n' "$prerel"
    printf '  this pom pins ................... %s\n' "$pinned"
    printf 'no rc and no milestone sits above it, so there is nothing newer to move to\n'
  } > .r-release.out
  cat .r-release.out
  printf 'md5 %s  (no build)\n' "$(hash_of .r-release.out)"
}

# --------------------------------------------------------------- solution ----
run_solution() {
  block "solution - the exercise answer, run  [structure HASHED, numbers not]"
  rm -rf .sol && cp -R exercise .sol && rm -rf .sol/solution .sol/target
  ( cd .sol && "${MVN[@]}" -q clean package ) > .r-sp0.raw 2>&1; local rc0=$?
  [ "$rc0" -eq 0 ] || die "the untouched exercise did not package"
  java -jar .sol/target/benchmarks.jar > .r-s0.raw 2>&1 || die "the untouched exercise's benchmark failed"
  local cnt0 err0
  cnt0=$(grep -E '^SplitBench\.' .r-s0.raw | awk '{print $3}' | sort -u | tr '\n' ' ' | xargs)
  err0=$(grep -cE '^SplitBench\..*±' .r-s0.raw)

  cp exercise/solution/SplitBench.java .sol/src/main/java/com/tiffinbox/bench/SplitBench.java
  ( cd .sol && "${MVN[@]}" -q clean package ) > .r-sp1.raw 2>&1; local rc1=$?
  [ "$rc1" -eq 0 ] || die "the answer did not package"
  java -jar .sol/target/benchmarks.jar > .r-s1.raw 2>&1 || die "the answer's benchmark failed"
  local cnt1 err1 rows1
  cnt1=$(grep -E '^SplitBench\.' .r-s1.raw | awk '{print $3}' | sort -u | tr '\n' ' ' | xargs)
  err1=$(grep -cE '^SplitBench\..*±' .r-s1.raw)
  rows1=$(grep -cE '^SplitBench\.' .r-s1.raw)

  { printf 'start state: Cnt = %s ; result rows carrying an error term: %d\n' "$cnt0" "$err0"
    printf 'answer:      Cnt = %s ; result rows carrying an error term: %d of %d\n' "$cnt1" "$err1" "$rows1"
    printf 'JMH refuses to print an error term it cannot compute. Two samples is not a spread.\n'
  } > .r-solution.out
  [ "$err0" -eq 0 ] || die "the untouched exercise already prints an error term - it is not a start state"
  [ "$err1" -eq "$rows1" ] && [ "$rows1" -gt 0 ] || die "the answer printed $err1 error term(s) over $rows1 row(s)"
  cat .r-solution.out
  printf 'md5 %s  exit %d then %d\n' "$(hash_of .r-solution.out)" "$rc0" "$rc1"

  printf '\nthe two tables, for reading rather than for hashing:\n'
  grep -E '^Benchmark |^SplitBench\.' .r-s0.raw | sed 's/^/  before  /' | mask
  grep -E '^Benchmark |^SplitBench\.' .r-s1.raw | sed 's/^/  after   /' | mask
  nohash "the scores are durations from this machine; the two counts above are the receipt."
  rm -rf .sol
}

# ---------------------------------------------------------------- offline ----
run_offline() {
  block "offline - the contract's 1c receipt  [HASHED]"
  "${MVN[@]}" package > /dev/null 2>&1 || die "the warm-up build failed; there is nothing to go offline with"
  "${MVN[@]}" -o test > .r-o.raw 2>&1; local rc=$?
  grep -E '^\[INFO\] Tests run:|^\[INFO\] BUILD' .r-o.raw | mask > .r-offline.out
  [ "$rc" -eq 0 ] || die "mvn -o test exited $rc"
  grep -q 'BUILD SUCCESS' .r-offline.out || die "no BUILD SUCCESS in the offline run"
  { printf 'offline: yes (-o), after one warm PACKAGE of the same project\n'
    printf 'package, not test: the shade plugin and the annotation processor are only resolved\n'
    printf 'by a package run, so a repository warmed by mvn test alone cannot serve this offline\n'
  } >> .r-offline.out
  cat .r-offline.out
  printf 'md5 %s  exit %d\n' "$(hash_of .r-offline.out)" "$rc"
}

# ------------------------------------------------------------------ sweep ----
# NOT HASHED, NOT IN THE DEFAULT RUN, and the most important block in this unit.
#
# One run of `scores` is one reading. This one takes N of them and prints the verdict each
# time, with the machine's load average beside it - because machine load is a flag, and
# section 2b.4 says a timing taken with an unnamed flag set is not a measurement.
#
#   ./receipts.sh sweep                 5 runs, the default
#   RUNS=8 ./receipts.sh sweep
#   RUNS=3 LOAD=8 ./receipts.sh sweep   the same sweep with 8 busy cores underneath it
#
# LOAD=N IS THE 2c RECEIPT. Section 2c says the noise verdict is a legitimate answer and
# is mandatory when true, and this unit is the contract's auditor - so "on a loaded
# machine the error bars grew and the verdict moved" must be something a viewer can make
# happen, not something the author remembers. LOAD=N starts N busy workers around the
# sweep, prints the load average it actually created beside every row, and lets the
# verdict move. Nothing about the verdict is asserted in this block: the whole point is
# that it is allowed to change, and the block says which way it went.
#
# It is slow on purpose: each run is two forks of three one-second iterations over three
# benchmarks, twice over for warm-up. That is what a number with an error bar costs.
LOAD_PIDS=()
stop_load() { [ "${#LOAD_PIDS[@]}" -eq 0 ] || kill "${LOAD_PIDS[@]}" 2>/dev/null; LOAD_PIDS=(); }
run_sweep() {
  block "sweep - the same benchmark, N times, with the verdict each time  [NOT HASHED]"
  package_once
  local runs="${RUNS:-5}" i load_n="${LOAD:-0}"
  if [ "$load_n" -gt 0 ]; then
    trap stop_load EXIT INT TERM
    local k
    for ((k = 1; k <= load_n; k++)); do yes > /dev/null & LOAD_PIDS+=("$!"); done
    printf 'LOAD=%d: %d busy worker(s) started, and every reading below is taken against them.\n' "$load_n" "$load_n"
    printf 'This is section 2c on purpose - the error bars are expected to grow.\n'
    sleep 20   # let the 1-minute load average start to show them
  fi
  printf 'run  load(1m)  rows  concatInALoop            stringBuilder             verdict\n'
  : > .r-sweep.txt
  for ((i = 1; i <= runs; i++)); do
    local load
    load=$(uptime | sed -E 's/.*averages?: *//' | awk '{print $1}' | tr -d ',')
    java -jar "$JAR" > ".r-sw$i.raw" 2>&1 || die "sweep run $i exited non-zero"
    local size
    for size in $(param_values); do
      local cs ce bs be
      cs=$(jmh_p concatInALoop "$size" score < ".r-sw$i.raw"); ce=$(jmh_p concatInALoop "$size" error < ".r-sw$i.raw")
      bs=$(jmh_p stringBuilder "$size" score < ".r-sw$i.raw"); be=$(jmh_p stringBuilder "$size" error < ".r-sw$i.raw")
      [ -n "$cs" ] && [ -n "$ce" ] && [ -n "$bs" ] && [ -n "$be" ] \
        || die "run $i produced a row with no error term at rows=$size"
      awk -v i="$i" -v l="$load" -v s="$size" -v a="$cs" -v ae="$ce" -v b="$bs" -v be="$be" 'BEGIN{
          v = ((a-ae)<=(b+be) && (b-be)<=(a+ae)) ? "overlap" : "separated";
          printf "%2d   %7s  %-5s %10.3f +- %-8.3f  %10.3f +- %-8.3f  %s\n", i, l, s, a, ae, b, be, v }' \
        | tee -a .r-sweep.txt
    done
  done

  local overlaps separated
  overlaps=$(grep -c 'overlap' .r-sweep.txt)
  separated=$(grep -c 'separated' .r-sweep.txt)
  local sizes rowsn
  sizes=$(param_values | wc -w | tr -d ' ')
  rowsn=$(( runs * sizes ))
  [ $(( overlaps + separated )) -eq "$rowsn" ] || die "the per-run verdicts do not add up to $rowsn"
  printf '\nof %d readings (%d runs x %d input sizes) on one machine in one session:\n' "$rowsn" "$runs" "$sizes"
  printf '%d said the two overlap, %d said they are separated\n' "$overlaps" "$separated"
  if [ "$overlaps" -gt 0 ] && [ "$separated" -gt 0 ]; then
    printf 'THE VERDICT ITSELF MOVED between runs. The honest sentence is section 2c\047s:\n'
    printf '"I could not measure a difference above the noise on this machine" - and note that\n'
    printf 'the harness never lied. On the noisy runs its error bars grew and refused the\n'
    printf 'ordering; on the quiet runs they shrank and allowed it. The confidence tracked the\n'
    printf 'conditions, which is the whole job.\n'
  else
    printf 'every run agreed. That is a result about THIS machine in THIS session and nothing more;\n'
    printf 'the number to quote is the range across %d runs, never one of them.\n' "$runs"
  fi
  local loads
  loads=$(awk '{print $2}' .r-sweep.txt | sort -n | awk 'NR==1{lo=$1} {hi=$1} END{printf "%s-%s", lo, hi}')
  printf 'load average across the whole sweep: %s ; busy workers this block started: %d\n' "$loads" "$load_n"
  stop_load
  trap - EXIT INT TERM
  nohash "N runs of a duration on one machine. N is on the table, the load average is beside every row, and no rate or percentage is computed from any of it. Run it again with LOAD=8 and watch the error bars grow - that is section 2c, and it is a thing you can make happen rather than a thing you are told."
}

ALL=(harness naive scores deadcode jfr release solution offline)
if [ $# -eq 0 ]; then set -- "${ALL[@]}"; fi
for b in "$@"; do
  case "$b" in
    harness|naive|scores|deadcode|jfr|release|solution|offline|sweep) "run_$b" ;;
    *) printf 'unknown block: %s\nblocks: %s  (plus sweep, which is not in the default run)\n' "$b" "${ALL[*]}" >&2; exit 2 ;;
  esac
done
printf '\n'
