# Exercise — make the order stop mattering

**Start here.** With `JAVA_HOME` exported:

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="../.m2-demo" test
```

Right now that prints:

```
[ERROR]   RosterTest.startsWithTwoCustomers:24
Expected size: 2 but was: 3 in:
[Customer[name=Ravi, ...], Customer[name=Meera, ...], Customer[name=Sunil, ...]]
[ERROR] Tests run: 3, Failures: 1, Errors: 0, Skipped: 0
```

**The end state to reach** — green under Jupiter's default order **and** under a shuffled one:

```
mvn -B -Dmaven.repo.local="../.m2-demo" test
mvn -B -Dmaven.repo.local="../.m2-demo" \
    '-Djunit.jupiter.testmethod.order.default=org.junit.jupiter.api.MethodOrderer$Random' \
    -Djunit.jupiter.execution.order.random.seed=1 test
```

Both must print:

```
[INFO] Tests run: 3, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

**What to do:** `RosterTest` keeps its roster in a `private static final List`, and one of the
three tests adds to it. `static` means one list for the whole class, so the second test to run
sees what the first one did. Replace it with an instance field and a `@BeforeEach` that builds
a fresh list before every test. Do not reorder the methods and do not pin a seed — those make
*this* run pass; the field makes every run pass.

**Watch the single quotes** around the orderer property. `MethodOrderer$Random` is a nested
class; in a double-quoted shell string `$Random` expands to nothing, so JUnit is handed the bare
interface `org.junit.jupiter.api.MethodOrderer`, which it cannot construct. It says so — twice,
naming the parameter and the class — and falls back to its default order. The run is still red,
so nothing warns you by going green: what you have lost is the seed. `../receipts.sh quotes`
runs both forms and a no-orderer control and prints all three counts.

**The answer** is in [`solution/`](solution/) — `RosterTest.java` and the `CustomerBuilder` it
uses, both run before this file was written, under the default order and five named seeds.
`../receipts.sh solution` runs all six again.
