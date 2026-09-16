# c3-unit22 — JMH and JFR: honest measurement

Course 3 · Build & Test Like a Pro · Section 4 "Logging & Honest Measurement".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16**, macOS 27.0, 8-core / 16 GB Apple silicon,
on 2026-09-15. **Measured on Vivek's Mac — yours will differ, and that is the subject.**

`src/main/java/com/tiffinbox/` holds the same five carried classes —
`fdb1643d622615f3c331d75deaebb9da`. **Every Maven command carries
`-Dmaven.repo.local="$PWD/.m2-demo"` with the quotes**; this tree's path contains a space.

## The rule this unit has to settle first

This course's measurement rule says **a duration is never a fact**, and this unit's subject
is a tool whose entire purpose is to produce durations. Those are not in conflict, and
`receipts.sh` is organised around the reason why:

| | |
|---|---|
| **HASHED** | everything that is not a duration — the harness's own conditions, the warnings the JVM prints, the text JMH prints about its own numbers, the benchmark names, the `Cnt` column, and a count of what the naive stopwatch's output does *not* contain. Every one of those is the same on any machine. |
| **PRINTED, NEVER HASHED** | every `Score`, every `Error`, every JFR count. These are properties of one Mac on one afternoon. Those blocks say so in their own output, the way the concurrency unit's race blocks do. |
| **VERDICTS** | derived from the run and guarded — *"the two intervals overlap: yes"* is a fact about this run, and the block dies rather than guess it. |

The rule was never "do not measure time". It is **"never state a duration without the four
things that make it a measurement"** — N runs with N stated, a stated warm-up, the machine
named, every flag pinned. A stopwatch states a duration with none of them. **JMH prints all
four whether you ask for them or not**, and refuses to print an error term it cannot
compute. It is not an exception to the rule; it is the tool that makes the rule satisfiable.

## What the harness tells you before it tells you anything

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh harness
```

```
# JMH version: 1.37
# VM version: JDK 25.0.4.1, OpenJDK 64-Bit Server VM, 25.0.4.1
# Blackhole mode: compiler (auto-detected, use -Djmh.blackhole.autoDetect=false to disable)
# Warmup: 1 iterations, 1 s each
# Measurement: 1 iterations, 1 s each
# Timeout: 10 min per iteration
# Threads: 1 thread, will synchronize iterations
# Benchmark mode: Average time, time/op
```

`@Param` makes JMH print that whole header **once per input size**, so the file holds two
identical copies of it; the block takes the first and says so in a derived line rather than
pasting it twice. And from the same run, what the `-f 0` on that command line costs — in
the harness's own words, which used to be filtered out before the hash:

```
# Fork: N/A, test runs in the host VM
# *** WARNING: Non-forked runs may silently omit JVM options, mess up profilers, disable compiler hints, etc. ***
# *** WARNING: Use non-forked runs only for debugging purposes, not for actual performance runs. ***
```

and, on JDK 25, four lines you should see rather than crop:

```
WARNING: A terminally deprecated method in sun.misc.Unsafe has been called
WARNING: sun.misc.Unsafe::objectFieldOffset has been called by org.openjdk.jmh.util.Utils (file:<project>/target/benchmarks.jar)
WARNING: Please consider reporting this to the maintainers of class org.openjdk.jmh.util.Utils
WARNING: sun.misc.Unsafe::objectFieldOffset will be removed in a future release
```

**JMH 1.37 runs correctly on JDK 25 and prints four `sun.misc.Unsafe` warnings while doing
it.** They are real, they are the JVM's, and they are not a reason to distrust the numbers.
And then JMH says something about its own output that is better than anything this README
could write:

```
REMEMBER: The numbers below are just data. To gain reusable insights, you need to follow up on
... 3 lines elided: the advice in between - use profilers, design factorial experiments, run
baseline and negative tests, keep the environment safe, ask the domain experts for review ...
Do not assume the numbers tell you what you want them to tell.
```

And then it says something about **this** JDK that this unit has every reason to want on
screen, given that the header above reads `Blackhole mode: compiler` and the dead-code
section below is built on `Blackhole`:

```
NOTE: Current JVM experimentally supports Compiler Blackholes, and they are in use. Please exercise
extra caution when trusting the results, look into the generated code to check the benchmark still
works, and factor in a small probability of new VM bugs. Additionally, while comparisons between
different JVMs are already problematic, the performance difference caused by different Blackhole
modes can be very significant. Please make sure you use the consistent Blackhole mode for comparisons.
```

## The stopwatch, and what it cannot tell you

```
./receipts.sh naive
```

```
the naive stopwatch, run 3 times. Of its 9 result line(s):
  lines stating a warm-up ............ 0
  lines stating a fork count ......... 0
  lines carrying an error term ....... 0
  lines carrying the number of samples 0
  lines carrying a unit .............. 9
four of the five counts above are zero, and they are the four conditions this
course requires before a wall-clock number may go on a slide
```

Those five counts are hashed, because they are true on any machine. The numbers under them
are not:

```
concatInALoop   320.850 ns/op      concatInALoop   322.933      concatInALoop   343.895
stringBuilder   320.123 ns/op      stringBuilder   359.527      stringBuilder   313.867

runs in which concatInALoop came out ahead of stringBuilder: 1 of 3
```

**Three runs, three confident orderings.** That last count has come out `1 of 3` and
`3 of 3` on the same machine on the same day, and the block prints a different closing
sentence for each — which is the point rather than a wrinkle: **neither reading rescues the
stopwatch.** `NaiveTimer` is not a straw man — it uses `nanoTime`, divides by the iteration
count and keeps a sink so the work is used. What it has no way to do is tell you how far
apart two of its numbers have to be before the gap means anything, so three runs that agree
are no better evidence than three that do not.

## What the harness says about the same three methods

```
./receipts.sh scores
```

```
Benchmark                   (rows)  Mode  Cnt       Score      Error  Units
ReceiptBench.concatInALoop       6  avgt    6     112.536 ±    0.424  ns/op
ReceiptBench.concatInALoop     600  avgt    6  126434.174 ± 3875.139  ns/op
ReceiptBench.streamJoining       6  avgt    6     184.694 ±    1.194  ns/op
ReceiptBench.streamJoining     600  avgt    6   13837.750 ±   66.973  ns/op
ReceiptBench.stringBuilder       6  avgt    6     136.938 ±    0.624  ns/op
ReceiptBench.stringBuilder     600  avgt    6   11379.710 ±   61.102  ns/op

rows=6    concatInALoop [112.112, 112.960]   stringBuilder [136.314, 137.562]   concat is ahead
rows=600  concatInALoop [122559.035, 130309.313]   stringBuilder [11318.608, 11440.812]   stringBuilder is ahead
```

**Read those two verdicts again.** At six rows, string concatenation in a loop beats
`StringBuilder` — the error bars are tight and the ordering is clean. At six hundred rows
the same two methods give the *opposite* answer, and `StringBuilder` wins by a factor of
eleven. Both readings are correct. Neither is a fact about "concatenation versus
StringBuilder".

Both verdicts are **derived from this run's own intervals and asserted**: the block prints
`the verdict at each size, smallest first: concat builder` and then **stops** if either pair
overlaps, or if the two sizes ever agree. An overlap is §2c's legitimate answer — *"I could
not measure a difference above the noise on this machine"* — but it is not the sentence the
video speaks over this table, so the block refuses to let the two drift apart silently.

### `./receipts.sh` is not an unconditional `exit 0`, and this is the block that refuses

**`scores` is load-dependent by design, so on a busy machine it will stop instead of print.**
The three blocks whose subject is a duration — `scores`, `deadcode` and `jfr` — guard a fact
about the machine, and a machine under load fails that guard honestly. Measured here: at rest
the `scores` verdict came out `concat builder` on **2 of 2** attempts, exit 0; with two other
Maven builds running in other trees it refused on **1 of 2** — one-minute load average 4.15 at
the start of the run and 20.87 by the end of it — and what it printed was its own guard, at
exit **1**:

    rows=6    concatInALoop [158.019, 240.425]   stringBuilder [96.355, 508.041]   the intervals OVERLAP
    the verdict at each size, smallest first: OVERLAP builder

    RECEIPT FAILED (scores): an interval pair OVERLAPS on this run (OVERLAP builder). That is
    section 2c's answer and it is a legitimate result - 'I could not measure a difference above
    the noise on this machine' - but it is NOT the beat slide 4 speaks. Re-cut the slide to say
    it, or re-run on a quiet machine; do not quote a different number.

**That `exit 1` is the guard working, not a broken deliverable.** The error bars really did
grow until the ordering stopped being readable, and the block's job at that point is to refuse
rather than print a table under a sentence the table no longer supports. Nothing is wrong with
your clone and nothing needs editing.

**How to re-run it:** close the other builds, wait for the load average to come back down
(`uptime`), and run the one block again — `./receipts.sh scores`. It does not need the rest of
the file re-run; every block here stands alone. If you would rather see the refusal on purpose
than meet it by accident, `RUNS=3 LOAD=8 ./receipts.sh sweep` creates the load itself and
prints the load average beside every row. What does **not** depend on load is everything this
unit hashes — `harness`, `release` and `offline`, plus the structure-only halves of `naive` and
`solution` — and those reproduce on any machine.

That is why `@Param({"6", "600"})` is on the class. A benchmark at one input size measures
an algorithm at one input size, and reading the small row as a rule is exactly how folklore
gets written down. (The small row is not a fluke either: JDK 9 onwards compiles `+` through
`invokedynamic` and `StringConcatFactory`, which sizes the buffer once. At six rows that
wins; at six hundred the quadratic copying of `out = out + ...` swamps it.)

`ReceiptsAgreeTest` runs before any of this and asserts that all three implementations
return **the identical string** — at six rows and at six hundred. Two benchmarks that
produce different output are not a comparison; they are two measurements of two different
programs, and nothing in a benchmark harness checks that for you.

## One reading is not a measurement

```
RUNS=5 ./receipts.sh sweep
```

```
run  load(1m)  rows  concatInALoop            stringBuilder             verdict
 1      1.93  6        112.122 +- 0.797        136.386 +- 0.751     separated
 1      1.93  600   126761.609 +- 3628.897   11299.877 +- 34.583    separated
... 8 rows elided: runs 2 to 5, both sizes, every one of them "separated" ...
of 10 readings (5 runs x 2 input sizes) on one machine in one session:
0 said the two overlap, 10 said they are separated
```

`sweep` is **not in the default run** — it takes several minutes — and it is the block that
decides whether any of the numbers above are worth quoting. It records the **load average**
beside every row, because machine load is a flag and a timing taken with an unnamed flag
set is not a measurement.

It matters, and you can make it happen rather than take it on trust:

```
RUNS=3 LOAD=8 ./receipts.sh sweep
```

`LOAD=N` starts N busy workers around the sweep and prints the load average it actually
created beside every row. Nothing about the verdict is asserted in this block — the whole
point is that it is **allowed to move**, and the block says which way it went and prints
§2c's sentence when it moves. The harness is not wrong either way: its error bars grow when
the conditions get worse and refuse the ordering, and shrink when they improve and allow it.
**The confidence tracks the conditions, which is the entire job.**

(The author first saw this by accident, with four other Maven builds running in other trees:
`210.830 ± 57.134` against `200.515 ± 40.257`, and `rows=6` came out **overlap**. Those
figures are on no slide, because a block that cannot reproduce them cannot receipt them.
`LOAD=N` exists so that the *behaviour* is reproducible even though the figures are not.)

## A number that is correct and means nothing

```
./receipts.sh deadcode
```

```
Benchmark                Mode  Cnt  Score   Error  Units
DeadCodeBench.baseline   avgt    6  0.560 ± 0.001  ns/op
DeadCodeBench.consumed   avgt    6  0.717 ± 0.039  ns/op
DeadCodeBench.discarded  avgt    6  0.570 ± 0.004  ns/op
DeadCodeBench.returned   avgt    6  0.713 ± 0.008  ns/op

the work, as measured by the benchmark that consumes it: 0.717 - 0.560 = 0.157 +- 0.039 ns/op
the same work, discarded:                                0.570 - 0.560 = 0.010 +- 0.004 ns/op
consumed and returned agree: yes
what is left of the discarded call, as a fraction of the work measured: 0.06  (the guard: below 0.50)
```

`discarded` calls `customer.monthlyBill()` and throws the answer away, so the JIT stops
computing it. The result **cannot be told apart from the empty baseline** — an accurate
measurement of nothing happening, with an error term and a unit, and no warning of any kind.

**Do not expect that second line to come out negative, and do not let a slide say it will.**
Across seven runs on this Mac the difference was `-0.010`, `+0.033`, `-0.011`, `+0.041`,
`-0.033`, `+0.028` and `+0.010` ns/op — above the empty method about as often as below,
which is precisely what "there is nothing there" looks like. So the block asserts the
**fraction** and never the sign: whatever is left must be under half the work the
`Blackhole` version measured. Both differences carry their **propagated error**, because a
difference of two JMH scores is not exempt from the rule that produced them.

Read the javadoc on `DeadCodeBench`: the first version of this break discarded a
StringBuilder result and the JIT **did not** eliminate it (140.441 ± 0.777 against
138.475 ± 4.504). Allocation is much harder to prove dead than arithmetic. **You cannot tell
by looking at your own benchmark whether the work survived**, which is why the `Blackhole`
is not optional.

## JFR: the warm-up, counted

```
./receipts.sh jfr
```

```
the recording exists, which is the artifact - not the exit code:
... 1 line elided: the .jfr file's byte size, which this course never puts on a slide ...
... 6 lines elided: jfr summary's header and its five biggest event types ...
jfr print --events jdk.CompilerStatistics - compileCount, one snapshot a second:
  snapshot  1:   1603 compiled
  snapshot  2:   1624 compiled  (+21 since the last one)
  snapshot  3:   1628 compiled  (+4 since the last one)
... 4 rows elided: snapshots 4 to 7, deltas +3, +3, +4 and +1 ...
  snapshot  8:   1640 compiled  (+1 since the last one)

new compilations in the first interval: 21 ; in the last: 1
the first interval compiled at least four times what the last one did: yes
```

One flag on the benchmark fork —
`-XX:StartFlightRecording=filename=target/bench.jfr,settings=profile,dumponexit=true` — and
`jdk.CompilerStatistics` gives you the JIT's own count, once a second. **That fall is the
warm-up**, and it is why the harness throws the first iterations away. It is a count of
compilations rather than a duration, which is the only reason it is allowed on a slide at
all. The artifact that proves the recorder ran is `target/bench.jfr`, not the exit code.

## Every block

| Block | Hashed? | What it measures |
|---|---|---|
| `harness` | **yes** | JMH's own conditions, the four JDK-25 warnings, and what JMH says about its numbers |
| `naive` | **structure only** | five counts over the stopwatch's result lines; then its numbers, unhashed |
| `scores` | no | the score table with error terms, at both input sizes, and the verdict for each |
| `deadcode` | no | four ways to make the same call; the shape is guarded, the numbers are not hashed |
| `jfr` | no | compilations per second falling toward zero; the fall is asserted |
| `release` | **yes** | JMH 1.37's date and position in its version list, offline from `central/` |
| `solution` | **structure only** | the exercise's `Cnt` and error-term counts before and after |
| `offline` | **yes** | `mvn -o test` after one warm **package** (contract §1c) |
| `sweep` | no | **not in the default run.** N runs, the verdict and the load average per row; `LOAD=N` adds N busy workers so §2c's noise verdict is reproducible |

`./receipts.sh` runs the eight; `sweep` has to be asked for by name. **The run is not
guaranteed to exit 0:** `scores`, `deadcode` and `jfr` guard facts about the machine, and on a
loaded one `scores` stops with its own `an interval pair OVERLAPS` message — that is the guard
working, and re-running the single block on a quiet machine is the fix. **A full run takes several minutes** — six JMH forks of six
one-second iterations each, twice over, plus a recorded run. That is not overhead; it is
what a number with an error bar costs.

## Teardown

```
rm -rf target .m2-demo .r-*.out .r-*.raw .r-cp.txt .r-cc.txt .sol
rm -rf breaks/*/target exercise/target
```
