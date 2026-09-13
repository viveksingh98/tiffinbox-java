# Unit 35 — Testing with JUnit 5

**What this unit teaches:** A test calls your code with known inputs and asserts the answer: `@Test`, `assertEquals`, `assertThrows`, `mvn test`.

**You need:** JDK 25, Apache Maven 3.9.x and JUnit Jupiter 5.13.4 (Maven downloads it on the first run), with `JAVA_HOME` on JDK 25. Verified on JDK 25.0.4.1, Maven 3.9.16, surefire 3.5.3.

Run everything from this folder (`cd unit35`), in the order below.

### mvn -B test

Surefire runs everything under `src/test/java` — three green tests.

```console
$ mvn -B test
[... Maven's own log trimmed ...]
[INFO] Compiling 2 source files with javac [debug release 25] to target/classes
[INFO] Compiling 1 source file with javac [debug release 25] to target/test-classes
[INFO] Running com.tiffinbox.BillingTest
[INFO] Tests run: 3, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.037 s -- in com.tiffinbox.BillingTest
[INFO] Tests run: 3, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

### mvn -q package

`package` runs the tests first: a red test means no jar.

```console
$ mvn -q package && ls target
classes
generated-sources
generated-test-sources
maven-archiver
maven-status
surefire-reports
test-classes
tiffinbox-1.0.jar
```

### Notes

- `export JAVA_HOME=/opt/homebrew/opt/openjdk@25` (macOS Homebrew) before `mvn`.
- See the red run from the video: in `src/main/java/com/tiffinbox/Billing.java`, change the two-argument overload to `return calculateBill(mealsPerDay, pricePerMeal, 31);` and run `mvn -B test` → `expected: <7200> but was: <7440>` at `BillingTest.defaultMonthIsThirtyDays:10`, `BUILD FAILURE`. Change the `31` back to `30` for green. The shipped code is the fixed version.
- `target/` is git-ignored — never commit it.
