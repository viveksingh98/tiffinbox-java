# c3-unit18 — test architecture: naming, builders, flakiness

Course 3 · Build & Test Like a Pro · Section 3 "Testing That Earns Trust".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16**, macOS 27.0, Apple silicon, on 2026-09-15.

Three tests are easy. Two hundred is an engineering problem. This unit is the three pieces of
engineering that keep a suite worth reading: names that survive a failure report, builders
instead of positional constructors, and a flake **diagnosed** rather than retried.

## Run it

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" test
```

## What is in it

| Path | What it is |
|---|---|
| `src/test/.../CustomerBuilder.java` | the test-data builder: `aCustomer().eating(2).atRupees(120).build()` |
| `src/test/.../MonthlyBillTest.java` | the naming convention, with `@Nested` and `@DisplayName` |
| `src/test/.../RosterTest.java` | the fixed version of the flake: an instance field and a `@BeforeEach` |
| `breaks/nameless/` | two test classes, the same two assertions, the same two bugs — only the names differ |
| `breaks/positional-arguments/` | `new Customer("Ravi", 120, 2, "VEG")`: compiles, bills correctly, is wrong |
| `breaks/shared-state/` | one `static` list, three tests, and a failure you can reproduce by naming a seed |
| `exercise/` | that flake, for you to fix |
| `junit-platform.properties` | the file form of the two ordering knobs; `./receipts.sh properties` copies it onto a test classpath and runs it |
| `receipts.sh` | regenerates every number this unit shows |

## What actually reaches a failure report

```
cd breaks/nameless
mvn -B -Dmaven.repo.local="../../.m2-demo" test
```

```
[ERROR]   BillingRulesTest.doesNotBillThePausedDays
expected: 6480
 but was: 7200
[ERROR]   BillingRulesTest.isNoLongerActive
Expecting value to be false but was true
[ERROR]   SubscriptionTest.testOne:13
expected: 6480
 but was: 7200
[ERROR]   SubscriptionTest.testTwo:19
Expecting value to be false but was true
```

Four failures, two bugs, and **the same two assertions in both classes** — `./receipts.sh
names` checks that by comparing the `assertThat(` call lines, and prints how many are
identical. (The trailing bracket is load-bearing: `import static
org.assertj.core.api.Assertions.assertThat;` carries the word and is not an assertion.
Counting it once made all three of those numbers read 3 instead of 2.)

Read the first two lines and you know what broke: paused days are being billed. Read the last
two and you know only that something called `testOne` is unhappy about a number.

**Now the part that surprises people.** `BillingRulesTest` carries three `@DisplayName`
annotations. The receipt counts how many of those strings appear anywhere in the failure
report above: **zero**. It then counts how many appear in any file under
`target/surefire-reports/` — also **zero**, because surefire only phrases its XML when a
`<statelessTestsetReporter>` is configured and this pom configures none (the receipt prints that
count too). Add the reporter and two of the three arrive; the *outer* class's name never does.
Surefire's failure summary is `ClassName.methodName`. The display name is a nicety for an HTML
report; the line your CI pastes into a chat channel is the method name. **Put the information in
the method name.** Use `@DisplayName` as well, not instead.

What surefire *does* give you for free is the **class** display name, on the console: run
`breaks/nameless` and the test-set lines read `Running billing rules`, not `Running
com.tiffinbox.BillingRulesTest`.

## Four arguments, two of them interchangeable

`Customer` is `(String name, int mealsPerDay, int pricePerMeal, String mealType)`. The two
ints are adjacent, so this compiles:

```
new Customer("Ravi", 120, 2, "VEG")
```

and `monthlyBill()` still returns 7200, because 120 × 2 × 30 is the same as 2 × 120 × 30.
The bill test passes. Only an assertion that looks at a *field* catches it:

```
[ERROR]   PositionalTest.theCustomerIsNot:25
expected: 2
 but was: 120
```

A builder names each field at the call site, so there is no order left to get wrong.
That is the whole argument for it — not tidiness.

## The flake, made reproducible

```
./receipts.sh seeds
```

```
Jupiter's default      1 failure(s) of 3 test(s)
MethodOrderer$Random seed=1 2 failure(s) of 3 test(s)
MethodOrderer$Random seed=2 0 failure(s) of 3 test(s)
MethodOrderer$Random seed=3 1 failure(s) of 3 test(s)
MethodOrderer$Random seed=42 2 failure(s) of 3 test(s)
MethodOrderer$Random seed=2026 2 failure(s) of 3 test(s)
--- what the default order actually fails with ---
[ERROR] Failures: 
[ERROR]   RosterTest.startsWithTwoCustomers:24 
Expected size: 2 but was: 3 in:
[Customer[name=Ravi, mealsPerDay=2, pricePerMeal=120, mealType=VEG],
    Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG],
    Customer[name=Sunil, mealsPerDay=3, pricePerMeal=100, mealType=VEG]]
1 of 6 orders tried were green; the class holds 1 static field(s); 3 test(s) ran under every order
```

**Read the `of 3 test(s)` on every row.** It is there because a failure count over a class that
did not run is not a receipt: the block asserts that all three tests executed under each order
before it is allowed to write the row. Every one of those numbers repeats. Ask for a seed and you get the same order, so you get the
same result — which means this is not a flake you describe as *"it fails sometimes"*. It is a
flake you hand to a colleague as **"seed 2 passes; seeds 1, 3, 42 and 2026 do not"**, and they
can reproduce it before lunch.

Two things worth knowing about Jupiter's ordering before you go looking:

- **The default order is not declaration order, and it is not random.** It is a deterministic
  hash of the method names, so it repeats exactly — and it is not the order you wrote.
- **`MethodOrderer$Random` needs single quotes in a shell command.** In double quotes `$Random`
  expands to nothing and JUnit is handed the bare interface `org.junit.jupiter.api.MethodOrderer`,
  which has no no-arg constructor. It is **not** silent about that: it logs
  *"Failed to load default method orderer class … Falling back to default behavior"* **twice**, with a
  `NoSuchMethodException`. And the fallback run here is **red**, not green. What the quotes actually
  cost you is the order you asked for — `./receipts.sh quotes` runs both forms and a no-orderer
  control and prints all three: **2 failures of 3** single-quoted at seed 42, **1 of 3** double-quoted,
  and **1 of 3** with no orderer named at all. The double-quoted run is not proving nothing; it is
  proving something about a different order than the one you asked for.

`./receipts.sh fixed` runs the repaired class under all six orders: **6 of 6 green, and 3 tests
under every one of them.** The repair is one word — the field is no longer `static` — plus a
`@BeforeEach` that rebuilds it. That block is not allowed to *claim* six green orders unless it
got them: every `mvn` run's exit status is kept, and if even one of them is non-zero the block
refuses to print anything and the script exits 1.

**A retry would also have made this green.** It would not have made it true. The unit before
this one measures exactly what `-Dsurefire.rerunFailingTestsCount` does to a race.

## The same seed, set two ways

```
./receipts.sh properties
```

`junit-platform.properties` is the form you want for a setting that stays. The block copies the
shipped file to `src/test/resources/` — the classpath root Jupiter reads — in a throwaway copy
of `breaks/shared-state`, runs it with **no `-D` of JUnit's on the command line at all**, then
runs the same class with the same seed on the command line instead, and prints how many
distinct failure counts the two forms produced. One means they selected the same order.

## receipts.sh

```
./receipts.sh            # every block
SEEDS="7 99" ./receipts.sh seeds fixed
```

Nine blocks: `tests`, `names`, `builders`, `seeds`, `properties`, `quotes`, `fixed`, `solution`,
`offline`. Every count is derived from the run above it: the failure numbers are parsed out of
surefire's own summary line, the `@BeforeEach` counts are grepped from the sources with comment
lines excluded, and the display-name finding is checked by searching the actual report.

Three of those greps are worth reading before you trust them:

- **`static_fields()` counts the modifier, not the shape.** `final` is not an exemption — a
  `private static final List<…>` is precisely the bug this unit teaches, and it is normally
  written across three lines. A static *method* is excluded by the one thing that always
  separates it from a field: its `(` arrives before any `=` or `;`.
- **Every exit code printed beside an md5 was measured.** The single-run blocks print the run's
  own status; the multi-run blocks (`seeds`, `properties`, `fixed`, `solution`) keep each run's
  status and print `N of M mvn runs exited non-zero`. Put the `static` list back into
  `src/test/.../RosterTest.java` and `./receipts.sh fixed` does not say `exit 0` — it fails.
- **A zero is only a receipt when the search could have found something.** `names` prints
  *0 of 3 under `target/surefire-reports/`* — a number that a missing directory would also produce.
  So the block dies if that directory is not there, and dies again if the reports do not carry the
  *method* names either. Same idea in `quotes`: it refuses to print at all unless the double-quoted
  run logged the fallback warning, the single-quoted one did not, the two forms produced **different**
  failure counts, and the double-quoted count matched a no-orderer control. A demonstration that
  did not fire must not be allowed to print a confident number.

## Offline

```
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -o test
```

passes after one warm build (`./receipts.sh offline`).

> 📌 Code for this unit: tiffinbox-java/c3-unit18 · verified on JDK 25.0.4.1
