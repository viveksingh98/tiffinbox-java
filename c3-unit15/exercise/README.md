# Exercise — one stub too many

**Start here.** With `JAVA_HOME` exported:

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="../.m2-demo" test
```

Right now that prints:

```
[ERROR]   PausesTest.reportsThePausedDays » UnnecessaryStubbing
Unnecessary stubbings detected.
Following stubbings are unnecessary (click to navigate to relevant line of code):
  1. -> at com.tiffinbox.PausesTest.reportsThePausedDays(PausesTest.java:20)
  2. -> at com.tiffinbox.PausesTest.reportsThePausedDays(PausesTest.java:21)
[ERROR] Tests run: 2, Failures: 0, Errors: 1, Skipped: 0
```

**The end state to reach:**

```
[INFO] Tests run: 2, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

**What to do:** delete the two stubs Mockito names. Do **not** add
`@MockitoSettings(strictness = Strictness.LENIENT)` — that would make the message go away
without making the test true, and the whole point of the setting is that it is telling you
something. A stub the code never reaches is a sentence in your test that describes a call
that does not happen.

Ask yourself, before you delete them, why they were there: somebody wrote the test by
copying a fixture, and the fixture set up three reads because *some other* test needed three.
That is how a suite ends up describing a system nobody has.

**Both states are receipts.** `../receipts.sh exercise` runs this directory untouched and
reads the two line numbers above back out of Mockito's own report. **The answer** is in
[`solution/`](solution/) — `PausesTest.java`, which was run before this file was written;
`../receipts.sh solution` runs it again and prints how many stubs the two versions have
(4 and 2).
