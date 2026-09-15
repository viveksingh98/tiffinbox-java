# Exercise — give the class a clock

**Start here.** With `JAVA_HOME` exported:

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="../.m2-demo" test
```

Right now that does not even compile:

```
[ERROR] COMPILATION ERROR :
[ERROR] .../src/test/java/com/tiffinbox/BillingTest.java:[15,16] constructor Billing in class
        com.tiffinbox.Billing cannot be applied to given types;
[INFO] BUILD FAILURE
```

**The end state to reach:**

```
[INFO] Tests run: 2, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

**What to do:** `src/main/java/com/tiffinbox/Billing.java` asks the machine what day it is.
Give it a `java.time.Clock` instead — a constructor parameter, a `private final Clock` field,
and `LocalDate.now(clock)` where it currently says `LocalDate.now()`. Change nothing else:
the arithmetic is already right, and `BillingTest.java` is the specification — do not edit it.

That is the whole seam. Three lines, and two dates that were previously untestable become
values the test chooses.

**The answer** is in [`solution/`](solution/) — `Billing.java`, which was run before this file
was written. `../receipts.sh solution` runs it again.
