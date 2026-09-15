# Exercise — turn `No tests to run.` into a green run

**Start here.** With `JAVA_HOME` exported:

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="../.m2-demo" test
```

*(`../.m2-demo` is the repository the unit root already warmed. Writing `"$PWD/.m2-demo"` from in here builds a **second** isolated repository under `exercise/` and re-downloads the whole test stack — measured: 16 MB and 50 jars. Corrected at the Section-3 gate; units 15-18 already used this form.)*

Right now that prints:

```
[INFO] No tests to run.
[INFO] BUILD SUCCESS
```

**The end state to reach:**

```
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

**What to do:** finish the three `TODO` comments in `pom.xml` (import the BOM, add
`junit-jupiter` at test scope with no version of its own, pin surefire), then move `BillTest.java.txt`
to `src/test/java/com/tiffinbox/BillTest.java` (the directory does not exist yet - that is why
surefire has nothing to run) and delete the three lines of prose at the top of it.

The point of TODO 2 is the one worth pausing on: the dependency carries **no `<version>`**.
If you find yourself typing one, the BOM import in TODO 1 is not doing its job.

**The answer** is in [`solution/`](solution/) — `pom.xml` and `BillTest.java`, both of which
were run before this file was written.
