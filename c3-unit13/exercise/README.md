# Exercise — make the failure tell you something

**Start here.** With `JAVA_HOME` exported:

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="../.m2-demo" test
```

*(`../.m2-demo` is the repository the unit root already warmed. Writing `"$PWD/.m2-demo"` from in here builds a **second** isolated repository under `exercise/` and re-downloads the whole test stack — measured: 16 MB and 50 jars. Corrected at the Section-3 gate; units 15-18 already used this form.)*

Right now that fails, and the whole message is:

```
[ERROR]   RosterTest.theKitchenKnowsAboutSunil:31 expected: <true> but was: <false>
```

A name is wrong somewhere. Nothing on that line tells you which one, or what the roster
actually holds.

**What to do:** rewrite the one `assertTrue` in `src/test/java/com/tiffinbox/RosterTest.java`
as an AssertJ chain — `assertThat(...)` over the **list**, then `extracting(Customer::name)`,
then `contains(...)`. Run it again and read the new message. It prints the roster, and the
roster shows you the bug. Fix that.

**The end state to reach:**

```
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

The point is not the green run. The point is the message in between, which is in
[`solution/RosterTest.step1.java.txt`](solution/RosterTest.step1.java.txt) — read that before
you look at [`solution/RosterTest.java`](solution/RosterTest.java). Both states were run before
this file was written, and `../receipts.sh solution` runs all three.
