# Exercise — make the runner count the rows

**Start here.** With `JAVA_HOME` exported:

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="../.m2-demo" test
```

*(`../.m2-demo` is the repository the unit root already warmed. Writing `"$PWD/.m2-demo"` from in here builds a **second** isolated repository under `exercise/` and re-downloads the whole test stack — measured: 16 MB and 50 jars. Corrected at the Section-3 gate; units 15-18 already used this form.)*

Right now that prints:

```
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

Five rows in the table. One test on the report.

**The end state to reach:**

```
[INFO] Tests run: 5, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

**What to do:** in `src/test/java/com/tiffinbox/PlanTableTest.java`, replace the `@Test` and its
`for` loop with a `@ParameterizedTest` and a `@CsvSource` carrying the same five rows. The method
takes the three values as parameters; the `TABLE` constant goes away. Nothing about the rows or the
expected numbers changes — only who does the looping.

Why it matters is on the report rather than in the code: with the loop, a broken row is one failure
and the other four never run. With five cases, the runner tells you about all five.

**The answer** is in [`solution/PlanTableTest.java`](solution/PlanTableTest.java), which was run
before this file was written.
