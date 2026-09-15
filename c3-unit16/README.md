# c3-unit16 — testing concurrency and time

Course 3 · Build & Test Like a Pro · Section 3 "Testing That Earns Trust".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16**, macOS 27.0, Apple silicon, on 2026-09-15.

Two things make a test lie about the code: **the machine's clock** and **the machine's
speed**. This unit removes both as inputs.

`src/main/java` carries the five classes from the earlier units unchanged — the same
`md5 -q Customer.java CustomerRepository.java Dashboard.java Database.java OrderQueue.java |
sort | md5 -q` as `c3-unit11` — plus one new class, `Billing`, which is the only file here
that deals in dates.

## Run it

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" test
```

## What is in it

| Path | What it is |
|---|---|
| `src/main/.../Billing.java` | takes a `java.time.Clock`. Nothing in it calls `LocalDate.now()` with no argument |
| `src/test/.../BillingTest.java` | four dates the test chose. Run it in any month of any year and it says the same thing |
| `src/test/.../RailCloseFirstTest.java` | the cheapest fix: `close()` is already a barrier |
| `src/test/.../RailAwaitilityTest.java` | Awaitility 4.3.0, waiting for a **condition** with a deadline instead of for a duration |
| `breaks/wrong-arithmetic/` | a clock you can set, and a sum that is wrong on 245 days of the year |
| `breaks/sleep-race/` | `Thread.sleep(1)` standing in for a barrier, on the kitchen rail |
| `exercise/` | a `Billing` with no seam: the test does not compile until you add the `Clock` |
| `receipts.sh` | regenerates every number this unit shows, in eight blocks |

## The flake, and why this README will not tell you how often it fails

```
cd breaks/sleep-race
mvn -B -Dmaven.repo.local="../../.m2-demo" test
```

Twenty thousand orders go onto the rail, four cooks take them off it *while the loop is still
putting*, and the test sleeps one millisecond before counting. The sleep is not betting that
twenty thousand orders get cooked in a millisecond — it is betting that whatever the cooks are
still behind by when the last order goes on can be cleared in one. Run it once and you learn
nothing. `./receipts.sh race` runs it `RUNS` times at each of three queue lengths and prints
**both** numbers on every row — how many runs, how many failures — because neither means
anything without the other. With `SWEEPS=2` it does the whole thing twice and then compares
the two sweeps against each other:

```
load average when this block started: 98.36 75.68 51.80
the length this test ships with, read out of RailSleepTest.java: 20000
sweep 1 of 2 - the identical command, the same three lengths:
   2000 orders: .....F...F.F   failed 3 of 12 runs of `mvn test` in this session
  20000 orders: ............   failed 0 of 12 runs of `mvn test` in this session
 200000 orders: ............   failed 0 of 12 runs of `mvn test` in this session
counts, shortest queue first: 3 0 0 - did the count rise with the queue length? no
sweep 2 of 2 - the identical command, the same three lengths:
   2000 orders: .........FF.   failed 2 of 12 runs of `mvn test` in this session
  20000 orders: ........F.F.   failed 2 of 12 runs of `mvn test` in this session
 200000 orders: .FF.......FF   failed 4 of 12 runs of `mvn test` in this session
counts, shortest queue first: 2 2 4 - did the count rise with the queue length? yes
the count rose with the queue length in 1 of 2 sweeps
the SAME length, swept again, moved by up to 4 runs (at 200000 orders)
the three DIFFERENT lengths, inside one sweep, spanned at most 3 runs
```

**Your numbers will differ, and that is the point.** Read the last three lines. One length,
swept again minutes later on the same machine, moved further than the three different lengths
moved inside a single sweep. When the spread inside one configuration beats the gap between
configurations, the honest answer is that you could not measure it — so **this README will not
tell you the failure rate of this race, and it will not tell you its shape either.** An earlier
draft of this file claimed one (*short queue mostly green, the shipped length flaky, ten times
it red every time*); the block above refused it, and the claim is gone.

The obvious explanation for the spread is machine load. The block prints its own load average,
first line and last, and it does not predict a count either. Nothing measured here does. What
the block *can* tell you is that no two failing runs reached the same count, which is how you
know this is a race and not a bug with a threshold.

The knobs are `RUNS=20 ./receipts.sh race`, `SWEEPS=2 ./receipts.sh race` and
`LENGTHS="2000 20000" ./receipts.sh race`.

**A green build is not the same as a test that ran, and this script no longer confuses the two.**
`mvn test` over a class surefire did not select exits 0 and prints no `Tests run:` line at all.
Every multi-run block here — `race`, `retry` and `fixed` — counts the `@Test` methods its source
declares and checks each run's own `Tests run:` summary against it, and stops the block outright
when a run comes up short. Renaming the class inside `RailSleepTest.java` used to be enough to
make `race` and `retry` print a spotless receipt over zero tests; now they refuse.

### A retry is not a fix

`./receipts.sh retry` runs the same flaky test with `-Dsurefire.rerunFailingTestsCount=2`.
When the first attempt loses the race and the second wins, surefire prints this and **exits 0**:

```
of 12 runs at 20000 orders: 2 failed the build, 7 passed WITH a recorded flake, 3 passed clean
what a rescued run looks like:
[WARNING] Flakes: 
[WARNING] com.tiffinbox.RailSleepTest.everyOrderIsCooked
[ERROR]   Run 1: RailSleepTest.everyOrderIsCooked:26 
expected: 20000
 but was: 12672
[INFO]   Run 2: PASS
... 2 empty [INFO] lines elided ...
[WARNING] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Flakes: 1
... 2 lines elided: an empty [INFO] line and a rule ...
[INFO] BUILD SUCCESS
```

The race is still there. The build is green. The only trace is a `[WARNING]` line nobody
reads. Use `rerunFailingTestsCount` to *find* flakes, never to *ship* over them.

**Those three counts are one session's, exactly like the sweep above, and they do not repeat
either.** Three runs of this block on the machine that recorded it gave `2 / 7 / 3`, `4 / 5 / 3`
and `0 / 1 / 11`. The capture under the counts comes from the same run as the counts, and if you
quote them anywhere you quote them together. When a session rescues no run at all the block says
so in its own words rather than leaving you to wonder where the capture went.

### The two rewrites, and why they are not flaky

`./receipts.sh fixed` runs each of them `RUNS` times — 12 by default — and asserts on every
run that the class actually executed its tests, because *0 failures over a class that never
ran* is the easiest lie here to tell by accident. **0 failures each — and that count is not the
evidence.** Look at the sweep at the top of this file: at 20 000 orders, the length these two
classes run at, the *unfixed* test scored `0 of 12` as well in one of the two sweeps. A failure
count cannot separate a fix from a quiet afternoon. The reason is what does:

- `RailCloseFirstTest` calls `q.close()` before asserting. `close()` puts one poison pill per
  cook onto a FIFO queue and blocks until every cook has taken one — so when it returns, every
  order ahead of those pills has already been cooked. There is nothing left to wait for.
- `RailAwaitilityTest` polls `q.cooked() == ORDERS` every 2 ms for at most 5 seconds. A slower
  machine makes this test *slower*, not *red*.

Reach for the first one whenever the class already gives you a handle. Awaitility is for when
it does not.

## The clock

```
cd breaks/wrong-arithmetic
mvn -B -Dmaven.repo.local="../../.m2-demo" test
```

`daysLeftInCycle()` there is written as `30 - dayOfMonth`. The test prints, from its own loop
over every day of 2026:

```
agrees with the calendar on 120 of 365 days in 2026
```

Four months have thirty days. For those 120 days the wrong sum is invisible. On 31 January it
is not:

```
expected: 0
 but was: -1
```

Neither of those facts is reachable without a `Clock` you can set. That is the seam, and it is
the whole reason `Billing` takes a constructor parameter it never asks the user for.

## receipts.sh

```
./receipts.sh             # every block
RUNS=20 ./receipts.sh race retry
```

Eight blocks: `tests clock classpath race retry fixed solution offline`.

Every number is derived by the run that printed it — the 120/365 line is parsed out of the
test's own output, the failure counts are counted by the loop that produced them, the two
classpath counts are `wc -l` over what `dependency:build-classpath` actually listed, and the
ordering verdict is arithmetic on the sweep counts rather than a sentence somebody wrote. The
`race`, `retry` and `fixed` blocks carry **no md5**, and say so: a flake has no byte-identical
output, which is the finding rather than a gap in the receipts. The other five are hashed and
reproduce 3/3 from a clean copy —

```
./receipts.sh tests clock classpath solution offline   # whole-output md5 9997454ecdfaa59957be2f4305f7d457
```

### What came off the classpath

`./receipts.sh classpath` runs `mvn -B dependency:build-classpath -DincludeScope=test` in
`../c3-unit15` and here, prints the rule it counted under, and diffs the two lists:

```
rule: every entry `mvn -B dependency:build-classpath -DincludeScope=test` prints, the carried compile-scope h2 included
test classpath entries - the unit before this one: 16; this unit: 14
gone (4): byte-buddy-agent-1.17.7.jar mockito-core-5.23.0.jar mockito-junit-jupiter-5.23.0.jar objenesis-3.3.jar
arrived (2): awaitility-4.3.0.jar hamcrest-2.1.jar
```

Four left when the two Mockito declarations came out of the POM — `objenesis` among them,
which nothing in this project ever named. Two arrived with Awaitility. A test dependency you
are not using is still one your build resolves.

## Offline

```
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -o test
```

passes after one warm build (`./receipts.sh offline`). Offline mode can only reuse what a
previous **online run of the same lifecycle** fetched.

> 📌 Code for this unit: tiffinbox-java/c3-unit16 · verified on JDK 25.0.4.1
