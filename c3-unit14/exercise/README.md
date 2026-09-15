# Exercise — make the mock prove something

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

Green. And `BillingService` charges Ravi **120** — one meal — where his monthly bill is **7200**.

**What to do:** in `src/test/java/com/tiffinbox/billing/ChargeTest.java`, replace `anyInt()` with
an `ArgumentCaptor<Integer>` (a `@Captor` field, `paise.capture()` in the `verify`), and assert that
the captured value is `7200`.

**The end state to reach:**

```
[ERROR]   ChargeTest.raviIsChargedHisMonthlyBill
expected: 7200
 but was: 120
```

The line number after the method name depends on where you put the assertion, so it is not part of the
acceptance — the two lines under it are.

Yes — the end state is a **failure**. That is the whole point of this unit: the green run you
started from was green because `anyInt()` asked whether a charge of *some* amount happened, and
charging is the only thing this service does. The captor asks *which* amount, and that question has
a wrong answer.

Once you have seen the failure, [`solution/BillingService.java`](solution/BillingService.java) is
the one-word fix that makes it green. Do not copy it first — seeing the failure is the exercise.
`../receipts.sh solution` runs all three states.
