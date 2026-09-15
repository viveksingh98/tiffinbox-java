# Exercise — kill the mutant that can be killed

**Start here.** With `JAVA_HOME` exported:

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="../.m2-demo" clean test
mvn -B -Dmaven.repo.local="../.m2-demo" test-compile org.pitest:pitest-maven:mutationCoverage
```

Right now the tests are green, JaCoCo reports **100% of lines and 100% of branches** on
`Pricing`, and PIT says:

```
>> Generated 7 mutations Killed 5 (71%)
SURVIVED  line 20  changed conditional boundary  [ConditionalsBoundaryMutator]
SURVIVED  line 23  changed conditional boundary  [ConditionalsBoundaryMutator]
```

**The end state to reach:**

```
[INFO] Tests run: 4, Failures: 0, Errors: 0, Skipped: 0
>> Generated 7 mutations Killed 6 (86%)
SURVIVED  line 20  changed conditional boundary  [ConditionalsBoundaryMutator]
```

**What to do:**

1. Add one test for the boundary on **line 23** — a customer whose monthly bill is exactly
   6000. `new Customer("Arun", 1, 200, "VEG")` is one; the rule in `Pricing`'s javadoc says
   that is SILVER.
2. Run it. It fails: `expected: "SILVER" but was: "BRONZE"`. You have found a real defect, and
   JaCoCo's number did not move by one line when you found it.
3. Fix `Pricing` so the code agrees with the rule it documents.
4. Run PIT again. Six of seven.

**And stop there.** The mutant on line 20 changes `bill >= 10000` to `bill > 10000`, which
differs only for a bill of exactly 10000 — and a monthly bill is always meals × price × 30,
so it is always a multiple of 30. 10000 is not (`10000 mod 30 = 10`). **No customer can tell
the two versions apart**, so no test can kill that mutant. It is an *equivalent mutant*, and
a team that treats "100% mutation score" as the target will spend a day on it.

That is the honest end of this exercise: 86%, and a sentence explaining the other 14%.

**The answer** is in [`solution/`](solution/) — `Pricing.java` and `PricingTest.java`, both run
before this file was written. `../receipts.sh solution` runs them again, PIT included.
