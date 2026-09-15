# c3-unit14 — test doubles, and Mockito doing the one job it is for

Course 3 · Build & Test Like a Pro · Section 3 "Testing That Earns Trust".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16**, macOS 27.0, Apple silicon, on 2026-09-15.

Forked from `c3-unit13` with `mockito-core` and `mockito-junit-jupiter`, both **5.23.0**, plus the
two POM blocks that declare Mockito as a static agent. The five original sources in
`src/main/java/com/tiffinbox/` are still byte-identical to `c3-tiffinbox/tiffinbox-core`:

```
cd src/main/java/com/tiffinbox && md5 -q *.java | sort | md5 -q     # fdb1643d622615f3c331d75deaebb9da
```

The two new production classes live one package down, in `com/tiffinbox/billing/`, so that hash
still covers exactly the five it always did.

## Run it

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" test
```

## What is in it

| Path | What it is |
|---|---|
| `src/main/java/.../billing/PaymentGateway.java` | the collaborator: somebody else's service, which charges real money |
| `src/main/java/.../billing/BillingService.java` | the thing under test |
| `src/test/java/.../HandWrittenDoublesTest.java` | **dummy, stub, spy and fake**, written out by hand as four real `PaymentGateway` classes — no framework anywhere |
| `src/test/java/.../MockitoBasicsTest.java` | the fifth word: `when`/`thenReturn`, `verify`, `never`, and the `ArgumentCaptor` |
| `pom.xml` | `maven-dependency-plugin:properties` + surefire `<argLine>` — the two blocks between the `STATIC-AGENT` markers. Surefire's **version** is pinned in `<pluginManagement>` *outside* them, on purpose |
| `breaks/verified-nothing/` | two green verifies over a service that charges the wrong amount |
| `exercise/` | that same green test; the end state is a **failure** |
| `receipts.sh` | regenerates every number and both warning captures |

## Five words, four of them written by hand

The four hand-written doubles are the definitions, and the difference between them is exactly what
each one **knows**:

| double | what it knows |
|---|---|
| **dummy** | nothing. Every method throws. It exists to fill a parameter, and it fails loudly if anything calls it |
| **stub** | one canned answer, handed to anyone who asks. No memory |
| **spy** | answers like a stub **and** writes down every call, so the test can look afterwards |
| **fake** | a working implementation, small enough to keep in memory. Balances really go down, and an empty wallet is really refused |
| **mock** | a double the framework writes at run time, whose calls the framework remembers for you |

`StubGateway` is **four** lines. The framework stubs the same call in **one** —
`when(gateway.charge("Ravi", 7200)).thenReturn("REF-9001")`. Both numbers are counted by
`./receipts.sh doubles` (an `awk` over the class block, a `grep -c` over the `when(` line) and land
inside that block's hash, so the comparison on the slide cannot drift away from the source.

## Six warning lines became one, and the one that stayed is a different warning

Mockito's inline mock maker needs an agent. Left alone it attaches one to the JVM it is already
running in, and on JDK 25 that costs **six lines**:

```
Mockito is currently self-attaching to enable the inline-mock-maker. ...
WARNING: A Java agent has been loaded dynamically (<repo>/byte-buddy-agent-1.17.7.jar)
WARNING: If a serviceability tool is in use, please run with -XX:+EnableDynamicAgentLoading ...
WARNING: If a serviceability tool is not in use, please run with -Djdk.instrument.traceUsage ...
WARNING: Dynamic loading of agents will be disallowed by default in a future release
OpenJDK 64-Bit Server VM warning: Sharing is only supported for boot loader classes because bootstrap classpath has been appended
```

The two POM blocks between the `STATIC-AGENT` markers put the agent on the command line before the
JVM starts. `./receipts.sh warn` deletes them from a throwaway copy, runs both, and counts:
**six before, one after** — both counts derived from those two runs.

**The two runs have to differ by those two blocks and by nothing else.** That is why surefire's
`<version>3.6.0</version>` sits in `<pluginManagement>`, *outside* the markers: delete the marker
region and Maven still forks the test JVM with the same surefire, instead of falling back to the
3.5.4 its own default lifecycle would bind. `run_warn` reads `surefire:<version>:test` out of both
runs, **refuses to print the contrast if they differ**, and writes `both runs forked surefire 3.6.0`
into both captures before either is hashed.

**The one that stays is not about agents at all.** It says class-data sharing now covers only
boot-loader classes, because the agent appended to the bootstrap class path.

`./receipts.sh flags` tries four flags against it, each one **edited into this POM's `argLine`**,
and prints what each run actually produced:

```
<no flag>                       1 OpenJDK warning line(s), 9 test(s) ran
-Xshare:off                     0 OpenJDK warning line(s), 9 test(s) ran
-XX:-UseSharedSpaces            2 OpenJDK warning line(s), 9 test(s) ran
-Xshare:auto                    1 OpenJDK warning line(s), 9 test(s) ran
-XX:SharedArchiveFile=/dev/null 0 OpenJDK warning line(s), 9 test(s) ran
4 flags tried: 2 removed the line, 2 did not; 9 test(s) ran in every run
```

So it is **harmless, and removable only at a price worth more than the warning**: the two flags that
clear it do so by switching class-data sharing off for every test run, and `-XX:-UseSharedSpaces`
adds a *second* line telling you the option was removed in 19.0.

**Why the flag has to go in the POM.** Running `mvn -DargLine=-Xshare:off test` measures nothing:
`-DargLine` sets the argLine *property*, surefire's own inline `<configuration>` wins, the flag
never reaches the fork, and the build cheerfully prints the same one warning line every time. That
is the same mechanism that makes a naively-configured JaCoCo agent silently do nothing — the coverage
unit's break beat — and it is why `run_flags` **dies** rather than print a row whose flag it cannot
find in the generated POM.

## The quotes around the agent path are load bearing

```
<argLine>-javaagent:"${org.mockito:mockito-core:jar}"</argLine>
```

Surefire splits `argLine` on whitespace. If the path to your repository contains a space — and this
one does — the unquoted form launches the fork with `-javaagent:/Users/you/Downloads/Youtube` and the
JVM dies before a single test runs:

```
[ERROR] Error occurred during initialization of VM
[ERROR] The forked VM terminated without properly saying goodbye. VM crash or System.exit called?
```

`./receipts.sh spacetrap` reproduces it **anywhere** — it copies the project into a directory whose
name contains a space, runs it unquoted, then quoted, and derives both results. Same trap as
`-Dmaven.repo.local="$PWD/.m2-demo"`, same fix.

## The Byte Buddy nobody declared

```
+- org.assertj:assertj-core:jar:3.27.7:test
|  \- net.bytebuddy:byte-buddy:jar:1.18.3:test
+- org.mockito:mockito-core:jar:5.23.0:test
|  +- (net.bytebuddy:byte-buddy:jar:1.17.7:test - omitted for conflict with 1.18.3)
|  +- net.bytebuddy:byte-buddy-agent:jar:1.17.7:test
```

Mockito pinned Byte Buddy **1.17.7**. AssertJ pinned **1.18.3**. Both sit at the same depth, so
nearest-wins hands the tie to whichever is declared first — and AssertJ is. Mockito therefore runs
on `byte-buddy 1.18.3` next to `byte-buddy-agent 1.17.7`: **a pair neither library shipped.** It
works, every test passes, and swapping the two `<dependency>` blocks flips it to 1.17.7 with nothing
else changed. `./receipts.sh bytebuddy` prints the tree and derives whether the pair matches.

That block is the one **filtered** capture in this unit: it pipes `dependency:tree -Dverbose` through
`grep -E 'assertj-core|mockito-core:jar|mockito-junit-jupiter|bytebuddy'`. The filter is named on the
slide's panel head and the receipt counts its own cost — `the grep kept 7 of the 31 rows
dependency:tree printed` — so the elision is a measured number inside the hash, not a caption.

`byte-buddy` appears in this `pom.xml` **zero** times. That is the point.

## The break

```
cd breaks/verified-nothing && mvn -B -Dmaven.repo.local="../../.m2-demo" test
```

Two tests verify that `charge` was called. Both pass. The service charges **120** where the monthly
bill is **7200** — because `verify(gateway).charge(eq("Ravi"), anyInt())` asks whether a call of that
*shape* happened, and charging is the only thing this service does, so a call of that shape was
always going to happen. The `ArgumentCaptor` in the class beside it asks *which amount*, and fails:

```
expected: 7200
 but was: 120
```

**The captured value is the artifact.** Not the green run, and not the `verify`.

`run_break` does not take the receipt's word for "the two that passed said nothing about the
amount". It **re-runs the green class** against a `BillingService` charging a *third* wrong amount —
neither the 120 it charges nor the 7200 it should — and reports how many of its tests noticed:

```
3 test(s) ran; 1 failed; the 2 that passed, re-run against a third wrong amount, noticed it 0 time(s)
```

Give either green test a real assertion about the amount and that `0` becomes a `1`. A `grep` for
`capture()` could not tell the difference, in either direction.

## receipts.sh

```
./receipts.sh              # every block: doubles warn spacetrap flags bytebuddy break solution offline
./receipts.sh warn         # just this one
```

Each block runs in its **own subshell**. A guard that fails ends that block, prints why, and the run
carries on to the next one; the script's own exit code is non-zero if any block failed. A single
flaky guard cannot truncate the receipts the slides depend on.

Absolute paths inside agent lines are masked to `<repo>/`, but the **version number in the path is
kept**, because the version is the evidence. `Time elapsed:` is stripped before anything is hashed.

## Offline

```
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -o test
```

passes after one warm build (`./receipts.sh offline`). Offline mode can only reuse what a previous
**online run of the same lifecycle** fetched.

> 📌 Code for this unit: tiffinbox-java/c3-unit14 · verified on JDK 25.0.4.1
