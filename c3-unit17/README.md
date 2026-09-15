# c3-unit17 — coverage, and what it does not tell you

Course 3 · Build & Test Like a Pro · Section 3 "Testing That Earns Trust".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16**, macOS 27.0, Apple silicon, on 2026-09-15.

This project ships **a bug on purpose**, with a test suite that covers every line and every
branch of the method that has it. That is the point: you are meant to run it, read the
hundred percent, and then find the customer it gets wrong.

## Run it

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" clean test
cat target/site/jacoco/jacoco.csv | grep Pricing
```

```
TiffinBox Core,com.tiffinbox,Pricing,0,15,0,4,0,6,0,3,0,1
```

Read the columns: **0 instructions missed, 15 covered · 0 branches missed, 4 covered ·
0 lines missed, 6 covered.** Every counter JaCoCo keeps for that class is at a hundred
percent. `./receipts.sh coverage` prints the same row with the percentages worked out.

## Now find the bug

`Pricing`'s javadoc states the rule the kitchen agreed: **6000 rupees and above is SILVER.**
The code says `if (bill > 6_000)`. A customer billed exactly 6000 gets BRONZE.

```
./receipts.sh bug
```

```
[INFO] Results:
[INFO] 
[ERROR] Failures: 
[ERROR]   PricingTest.exactlySixThousandIsSilver:30 
expected: "SILVER"
 but was: "BRONZE"
[INFO] 
[ERROR] Tests run: 4, Failures: 1, Errors: 0, Skipped: 0
the code branches on: bill > 6_000 ; the rule in the javadoc says: 6000 and above
```

That is the whole of `.r-bug.out`, byte for byte, trailing spaces and all — it is what
`md5 b2505193eae46373a69f0f98613ab1e2` is taken over. The last line is not narration: the block
greps the comparison out of the code and the threshold out of the javadoc in the same run.

**And here is the receipt that matters** (`./receipts.sh unchanged`): the JaCoCo row for
`Pricing` with the bug, and with the bug fixed, are the same string.

```
with the bug : TiffinBox Core,com.tiffinbox,Pricing,0,15,0,4,0,6,0,3,0,1
bug fixed    : TiffinBox Core,com.tiffinbox,Pricing,0,15,0,4,0,6,0,3,0,1
the two rows are identical: yes
```

Read what the second build actually is: `run_unchanged` copies **both** answer files over the
project, so the bug-fixed build carries the boundary test as well — `Tests run:` goes 3 to 4.
That makes the result stronger, not weaker: a test was added, a defect was fixed, and the
coverage row still did not move by one character.

Coverage did not move, because coverage was never measuring whether the code is right. It
measures which lines ran.

**That sentence is only worth something if two builds really produced two rows.** The block
records the exit code of both builds and checks that both CSV rows came back non-empty before
it is allowed to print a word; if either build fails, or if the JaCoCo agent silently does not
load — the very hazard this unit is about — it stops with
`RECEIPT FAILED (unchanged): …` instead of reporting two empty strings as identical.

## Two things the number hides

**Its denominator.** The same run, the same `jacoco.csv`:

```
Pricing      lines 6/6 (100%)
whole project (8 classes) lines 8/97 (8%)
```

A hundred percent, and eight percent, from one file. Whenever somebody quotes a coverage
figure, the first question is *of what* — and the second is *who chose that*.

**That other tools count differently.** PIT, over the same class in the same session, reports
its own line coverage as `6/8`. Neither tool is wrong; JaCoCo applies filters (a private,
empty constructor of a class that only has static methods is one of them) and PIT does not.
That filter is measured rather than asserted — `./receipts.sh ctor` builds this project twice,
once as shipped and once with that constructor removed, and reads both rows out of the two
`jacoco.csv` files it just wrote:

```
as shipped, private constructor present : lines 6/6 (100%)
the same project, that constructor gone : lines 6/7 (86%)
lines JaCoCo counted: 6 -> 7 ; lines it called covered: 6 -> 6
```

Seven lines, not six, because the default constructor javac generates in place of the private
one is not filtered. The block finds that constructor **by pattern, never by line number**, and
it stops with `RECEIPT FAILED (ctor): …` rather than print if `Pricing.java` does not carry
exactly one empty private constructor, or if deleting it does not move the denominator.

## Mutation testing

```
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" test-compile org.pitest:pitest-maven:mutationCoverage
```

PIT changes the compiled code on purpose — one small edit at a time — and re-runs your tests
against each edit. A change your tests do not notice is a **surviving mutant**, and it is a
place where your suite is not actually checking anything.

```
>> Generated 7 mutations Killed 5 (71%)
SURVIVED  line 20  changed conditional boundary  [ConditionalsBoundaryMutator]
SURVIVED  line 23  changed conditional boundary  [ConditionalsBoundaryMutator]
```

Line 23 is the bug. PIT found it from the outside, with no idea what the rule was supposed to
be, on a class JaCoCo had already called finished.

**PIT needs `pitest-junit5-plugin` declared as a dependency of the plugin itself** — see
`pom.xml`. Without it PIT 1.30.0 cannot see a JUnit 5 or 6 test at all.

**Two honest caveats**, both in [`exercise/README.md`](exercise/README.md): one of those two
survivors cannot be killed by any test, and 100% mutation score is not the goal either.

## The break — a coverage report that never ran

```
cd breaks/naive-argline
mvn -B -Dmaven.repo.local="../../.m2-demo" test
```

```
[INFO] Tests run: 3, Failures: 0, Errors: 0, Skipped: 0
[INFO] --- jacoco:0.8.15:report (report) @ naive-argline ---
[INFO] Skipping JaCoCo execution due to missing execution data file.
[INFO] BUILD SUCCESS
```

Seven goals ran, three tests passed, the build is green — and `target/jacoco.exec` does not
exist, `target/site/` has **0** files in it. The whole difference is one token:

```
this unit      <argLine>@{argLine} -Xmx512m</argLine>
the break      <argLine>-Xmx512m</argLine>
```

`jacoco:prepare-agent` does not add anything to the command line; it **sets a property called
`argLine`**. Surefire's own `<argLine>` configuration overrides that property, so the agent
never reaches the forked JVM. `@{argLine}` is late replacement: it tells surefire to expand
the property at fork time, which is after JaCoCo set it.

**So the question to ask of any tool in your build is never "did the build pass".** It is
*"which file proves it ran?"* Here that file is `target/jacoco.exec`, and `./receipts.sh
coverage` prints whether it exists and how big it is before it prints a single percentage.

## receipts.sh

```
./receipts.sh              # all nine blocks
./receipts.sh unchanged    # just the one that matters most
```

Every percentage is computed by one `awk` routine from the CSV that the run above it wrote, so
no two blocks can disagree. PIT's own log is never captured — it stamps a wall-clock time on
every line — only its `>>` statistics block and the mutation XML.

**Every block measures its own run**, including when you run it on its own. `scope` used to
reuse a `jacoco.csv` an earlier run had left behind, and to print `exit 0` for a build it had
not made: edit `Pricing.java`, run `./receipts.sh scope` by itself, and it reported a hundred
percent of everything in about a second for source it had never compiled — greener than the
truth, in the unit that exists to say a green build is not evidence a tool ran. It rebuilds
every time now, and the exit code beside the md5 is the one it took from that build.

## Offline

```
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -o test
```

passes after one warm build. Note that `mutationCoverage` is a **different lifecycle** — run
it online once before expecting `-o` to work for it.

> 📌 Code for this unit: tiffinbox-java/c3-unit17 · verified on JDK 25.0.4.1
