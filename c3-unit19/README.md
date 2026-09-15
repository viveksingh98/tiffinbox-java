# c3-unit19 — SLF4J, Logback and why not println

Course 3 · Build & Test Like a Pro · Section 4 "Logging & Honest Measurement".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16**, macOS 27.0, Apple silicon, on 2026-09-15.

`src/main/java/com/tiffinbox/` holds the same five classes this course has carried since the
Gradle section — `md5 -q Customer.java CustomerRepository.java Dashboard.java Database.java
OrderQueue.java | sort | md5 -q` is `fdb1643d622615f3c331d75deaebb9da` here, in `c3-unit07`,
in every unit of the testing section and in `c3-tiffinbox/tiffinbox-core`. The new file is
`com/tiffinbox/kitchen/KitchenLog.java`, one package down, and its four logging calls are
copied from the capstone server unchanged.

**Every Maven command below carries `-Dmaven.repo.local="$PWD/.m2-demo"` with the quotes.**
This tree's path contains a space; unquoted, the shell splits the argument and Maven reads
the tail as a goal (`Unknown lifecycle phase "Content/…"`). Nothing here touches `~/.m2`.

## Run it

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -q compile exec:exec
```

```
11:20:31.442 INFO  tiffinbox - orders cooked:  90
11:20:31.444 INFO  tiffinbox - kitchen value:  26700
```

The timestamp moves every run, so every capture in this unit is put through
`sed -E 's/^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3} /<time> /'` before it is hashed, and
every slide that quotes a hash shows that filter. **A log line carries a clock; a clock is
not a fact you can pin to a slide.**

## The same classes, a different level

```
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -q -Dlogback.config=logback-debug.xml exec:exec
```

```
<time> DEBUG tiffinbox - placing 30 order(s) for Arun
<time> DEBUG tiffinbox - placing 30 order(s) for Bela
<time> DEBUG tiffinbox - placing 30 order(s) for Chandran
<time> INFO  tiffinbox - orders cooked:  90
<time> INFO  tiffinbox - kitchen value:  26700
```

`./receipts.sh levels` runs both and then answers the question that makes it a proof rather
than a demonstration — **did anything recompile between the two?**

```
INFO run:  2 INFO line(s), 0 DEBUG line(s)
DEBUG run: 2 INFO line(s), 3 DEBUG line(s)
level= attributes that differ between the two config files: 2
md5 of target/classes before the two runs: 351f1f0a772cd0e6788477c785d2fa4b
md5 of target/classes after  the two runs: 351f1f0a772cd0e6788477c785d2fa4b
the classes were recompiled between the two outputs: no
```

Same bytes of `.class`, two different outputs. That is the sentence `println` cannot say.

## The same source, three bindings

`swap/src/main/java` and `breaks/no-binding/src/main/java` are **byte-identical** to
`src/main/java` — `./receipts.sh bridge` hashes all three and refuses to continue if they
ever stop matching. Only the dependency differs.

```
./receipts.sh bridge
```

```
logback-classic 1.6.3
<time> INFO  tiffinbox - orders cooked:  90
<time> INFO  tiffinbox - kitchen value:  26700
slf4j-simple 2.0.19
[main] INFO tiffinbox - orders cooked:  90
[main] INFO tiffinbox - kitchen value:  26700
no binding at all
SLF4J(W): No SLF4J providers were found.
SLF4J(W): Defaulting to no-operation (NOP) logger implementation
SLF4J(W): See https://www.slf4j.org/codes.html#noProviders for further details.
the three src/main/java trees hash to: 5883e0ad7c44e5bed8f683b9da25726a (identical: yes)
'orders cooked' lines: logback 1, slf4j-simple 1, no binding 0
exit codes: logback 0, slf4j-simple 0, no binding 0
```

Read the third state twice. **Exit code 0.** Nothing crashed, nothing was skipped, and the
kitchen still cooked ninety orders — it just stopped telling anyone. A missing binding is
not an error; it is a silence, and SLF4J's three lines on stderr are the only warning you
get. The block **dies** rather than print, if that run ever exits non-zero: a no-binding
state that failed loudly would be a different (and much less dangerous) lesson.

## Which `slf4j-api` did you actually get?

```
./receipts.sh tree
```

```
this project - logback-classic declared, slf4j-api NOT declared
com.tiffinbox:tiffinbox-core:jar:1.0.0
+- ch.qos.logback:logback-classic:jar:1.6.3:compile
|  +- ch.qos.logback:logback-core:jar:1.6.3:compile
|  \- org.slf4j:slf4j-api:jar:2.0.18:compile
+- org.slf4j:slf4j-jdk-platform-logging:jar:2.0.19:runtime
|  \- (org.slf4j:slf4j-api:jar:2.0.19:runtime - omitted for conflict with 2.0.18)
... 24 of 30 tree rows elided: everything that is not logback or slf4j ...
swap/ - slf4j-simple declared, slf4j-api NOT declared
com.tiffinbox:tiffinbox-core-simple:jar:1.0.0
+- org.slf4j:slf4j-simple:jar:2.0.19:compile
|  \- org.slf4j:slf4j-api:jar:2.0.19:compile
\- org.slf4j:slf4j-jdk-platform-logging:jar:2.0.19:runtime
   \- (org.slf4j:slf4j-api:jar:2.0.19:runtime - omitted for duplicate)
... 1 of 6 tree rows elided: everything that is not logback or slf4j ...
```

```
slf4j-api on this classpath ......... 2.0.18
slf4j-api the OTHER path offered ... 2.0.19, omitted for conflict
slf4j-api in swap/ ................. 2.0.19
times slf4j-api is declared in pom.xml: 0
the version that won is the newer one: no
```

Two paths reach `slf4j-api` at the same depth, so nearest-wins is a tie and **declaration
order decides** — and the version that loses is the newer one. Note the flag: `-Dverbose`
**without** `-Dincludes`. `-Dincludes` collapses the losing node, and the losing node is the
whole point. Never assert a transitive version from memory; print it.

## What a switched-off DEBUG call costs — counted, not timed

```
./receipts.sh cost
```

```
<time> INFO  c.t.ArgumentCostTest - cost | concatenated  "..." + label   DEBUG off | 1000 render(s) of 1000 call(s)
<time> INFO  c.t.ArgumentCostTest - cost | parameterised "...{}", label  INFO  on  | 3 render(s) of 3 call(s)
<time> INFO  c.t.ArgumentCostTest - cost | parameterised "...{}", label  DEBUG off | 0 render(s) of 1000 call(s)
[INFO] Tests run: 3, Failures: 0, Errors: 0, Skipped: 0 -- in com.tiffinbox.ArgumentCostTest
[INFO] Tests run: 3, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
CALLS, read out of the test source: 1000
renders with DEBUG off: concatenated 1000, parameterised 0
the ratio the placeholder bought you, on this run: 1000 to 0
every number above is read back out of a line the test logged AFTER its own assertion
```

No stopwatch anywhere. `CostlyLabel.toString()` counts its own calls, so the answer is a
**number the test asserted** — and each `cost |` line is logged *after* the assertion that
fixed it, so a line that reaches the log is a line an assertion already agreed with.

## The `<release>` trap, on this unit's own headline artifact

```
./receipts.sh release
```

```
org.slf4j:slf4j-api, read from central/ with no network
  versions in the list ............ 108
  <release> field says ............ 2.1.0-alpha1, published 2024-01-02
  last entry of the version list .. 2.1.0-alpha1  (the same string: yes)
  newest GA ....................... 2.0.19, published 2026-09-04
  the GA is NEWER than the field by 976 days (32 months)
  so the field is neither newest-GA nor newest-published
  this pom pins .................. 2.0.19
```

Derived from the two files in `central/`, fetched on 2026-09-15 and shipped verbatim, with
**no network request**. Re-fetch them yourself and the block will print the moved numbers.

## Every block

| Block | What it measures |
|---|---|
| `bridge` | three bindings over one hashed source tree; the no-binding run's exit code |
| `levels` | INFO and DEBUG out of `.class` files whose md5 does not move |
| `tree` | the resolved `slf4j-api` and the one that was omitted for conflict |
| `println` | the same kitchen with `System.out.println`, under both configs |
| `nobinding` | SLF4J's three-line warning, verbatim, and the zero log lines beside it |
| `cost` | the switched-off DEBUG call, as a render count |
| `release` | the `<release>` field, derived offline from `central/` |
| `solution` | the exercise, before and after |
| `offline` | `mvn -o test` after one warm build (contract §1c) |

`./receipts.sh` runs all nine. Every count it prints is appended into the `.out` file
**before** that file is hashed, so a wrong number moves the hash.

## Teardown

```
rm -rf target .m2-demo .r-*.out .r-*.raw .sol
rm -rf swap/target breaks/*/target exercise/target
```

Nothing in this unit writes to `~/.m2`, `~/.m2/settings.xml` or `~/.gradle`.
