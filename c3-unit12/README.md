# c3-unit12 — one test, many cases

Course 3 · Build & Test Like a Pro · Section 3 "Testing That Earns Trust".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16**, macOS 27.0, Apple silicon, on 2026-09-15.

Forked from `c3-unit11` with **no new dependency at all** — `junit-jupiter` already brings
`junit-jupiter-params`. The `src/main/java` sources are still byte-identical to
`c3-tiffinbox/tiffinbox-core`:

```
cd src/main/java/com/tiffinbox && md5 -q *.java | sort | md5 -q     # fdb1643d622615f3c331d75deaebb9da
```

## Run it

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" test
```

Five test methods in `src/test/java`. **Twenty cases on the report.** `./receipts.sh cases` prints
both numbers, and it counts them out of the run rather than out of this README.

The quotes around `-Dmaven.repo.local=` are load bearing if the path you cloned into contains a
space. `.m2-demo/` keeps every jar inside the project; your real `~/.m2/repository` is never touched.

## What is in it

| Path | What it is |
|---|---|
| `src/test/java/.../PriceTableTest.java` | `@CsvSource` over the price table, and `@MethodSource` for the cases a CSV cannot carry |
| `src/test/java/.../RosterFactoryTest.java` | `@TestFactory` — the cases are rows in an in-memory H2 database, so nobody knows how many there are until it runs |
| `src/test/java/.../DisplayNameTest.java` | the same four rows, with and without a `name =` pattern |
| `pom.xml` | the surefire `statelessTestsetReporter` block, which is the only thing that keeps a case name alive |
| `breaks/loop-in-a-test/` | one bug, five rows, counted two ways |
| `breaks/loop-in-a-test/variants/` | the same loop under `assertAll`, hoisted out and wrapped round the body. **Outside `src/`**, so `mvn test` here still runs exactly the two classes the slide compares; `./receipts.sh assertall` copies the project and runs them |
| `breaks/name-thrown-away/` | the same failing case, named two ways, and a console that cannot tell them apart |
| `breaks/zero-cases/` | two test methods in the file, one line on the report, `BUILD SUCCESS` |
| `exercise/` | a loop that reports `Tests run: 1`; the end state is `Tests run: 5` |
| `receipts.sh` | regenerates every number this unit shows |

## Three things worth knowing

**A loop inside a test is one test.** `breaks/loop-in-a-test/` has a `Customer` that bills a 31-day
month, so all five rows in the price table are wrong. Run it:

```
cd breaks/loop-in-a-test && mvn -B -Dmaven.repo.local="../../.m2-demo" test
```

The loop version reports **one** failure. The `@ParameterizedTest` version, over the same five rows
and the same bug, reports **five**. `./receipts.sh break` counts both out of one report.

`assertAll` is the previous unit's answer to *"the failing assert ends the method"*, and it is worth being
exact about what it does and does not buy here. **Hoisted out of the loop** — one `Executable` per row — it
runs every row and names **five**. **Wrapped round the loop body** it still stops at the first and names
**one**. And both report `Tests run: 1, Failures: 1`: assertAll fixes the *message*, never the *count*.
`./receipts.sh assertall` runs both placements and derives all three numbers.

**Your build tool throws the case name away.** JUnit knows which case failed and what its arguments
were. Surefire's console prints `defaultName(int, int, int)[4]` — and it prints exactly the same
thing for a method that has a `name = "{0} meals x {1} rupees -> {2}"` pattern. `-Dsurefire.reportFormat=plain
-Dsurefire.useFile=false` does not change it and neither does the `.txt` report. The **XML** report
can carry the name, and only once the `statelessTestsetReporter` in `pom.xml` asks for it.
`./receipts.sh names` shows the console, the XML without that block, and the XML with it.

`./receipts.sh plain` is the receipt for that middle sentence, because "the console cannot be fixed" is a
negative and a negative has to be measured or it is just a claim. It runs the plain format twice — once on
`breaks/name-thrown-away/` and once here, where the reporter block **is** configured — and counts: **8 of 8**
console case lines carry `(int, int, int)[N]` in both projects, **0 of 8** carry an argument value in either,
while the XML written by that **same** build carries them **8 of 8**. One build, two outputs, opposite
answers. The console detector is proven able to fire against a phrased name before either zero is trusted.

Two traps if you type that block from memory: the class is `JUnit5Xml30StatelessReporter` (the tree
reporter is `JUnit5StatelessTestsetInfoReporter`, and a wrong hint fails the build with
`Cannot load implementation hint`), and the tree reporter has no `usePhrasedTestCaseMethodName`
parameter at all.

**An empty case source is not silent — unless you silence it.** JUnit 6.1.3 refuses an empty
`@MethodSource` by default: `Configuration error: You must configure at least one set of arguments
for this @ParameterizedTest`, and the build fails. `@ParameterizedTest(allowZeroInvocations = true)`
turns that refusal off, and then the method disappears from the count entirely —
`breaks/zero-cases/` declares **two** test methods and reports `Tests run: 1`, `BUILD SUCCESS`.
`./receipts.sh zero` runs it both ways and derives all three numbers.

## receipts.sh

```
./receipts.sh              # every block
./receipts.sh break zero   # just these two
```

Every number it prints is derived from the run above it by a `grep -c` or a `wc -l`, never from a
string in the file. `Time elapsed:` rides on every surefire `Tests run:` line and moves every run, so
it is stripped before anything is hashed.

Two of the numbers in the `names` block are **zero**, and a zero is only a finding if a one was
reachable — so that block **proves each detector can fire before it trusts the zero**, and calls
`die()` if a probe does not match. The detector is the same on all four halves: *does the name carry a
quoted argument value* — a bare `"` on the console, `&quot;` in the XML. An earlier draft asked the
console half for `meals x`, which is `namedPattern`'s own `name =` wording, so `defaultName`'s half of
that denominator could never have incremented. There is also **no cosmetic `sed`** in the `zero` block
any more: the one that used to be there was anchored on a `(String)` signature against a method taking
`(Customer, int)`, so it silently matched nothing. A filter that matches nothing and a check that
cannot fail are the same hazard, and neither is allowed in here.

The `solution` block reads each state's case count out of **that state's own log**, and stops on `die()` if
the starting state did not build. It used to read both counts with `head -1` / `tail -1` out of one joined
capture, which meant that a starting state which failed to compile contributed no line at all and the
answer's `Tests run: 5` was printed in the starting number's place — a green-looking receipt over a build
that never happened. Reproduce the old failure by appending a syntax error to
`exercise/src/test/java/com/tiffinbox/PlanTableTest.java`: it now exits 1 with
`RECEIPT FAILED (solution): the exercise starting state exited 1`.

The whole run's hash is over its **combined output**, not over this file:

```
./receipts.sh 2>&1 | md5 -q        # 24d0744c32bcc26e1c5c311ab4fa3610, eight blocks
```

## Offline

```
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -o test
```

passes after one warm build (`./receipts.sh offline`). Note the limit: offline mode can only reuse
what a previous **online run of the same lifecycle** fetched. A repository that has only ever run
`dependency:tree` will fail `mvn -o verify` on a build plugin it never downloaded.

> 📌 Code for this unit: tiffinbox-java/c3-unit12 · verified on JDK 25.0.4.1
