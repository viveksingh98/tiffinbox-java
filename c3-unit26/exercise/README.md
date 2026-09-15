# Exercise 26 — make the build red, then make it green for the right reason

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
cd ..
mvn -B -ntp -Dmaven.repo.local="$PWD/.m2-demo" -Pnullaway clean compile
```

**Start state:**

```
[ERROR] .../quality/MealPlan.java:[40,16] [NullAway] unboxing of a @Nullable expression 'grams'
exit 1
```

**End state:** `mvn -Pnullaway clean compile` exits **0**, and `mvn -Pstrict clean test`
exits **0** as well — with the tests still green, and **without deleting a check, widening
a profile, or adding a `@SuppressWarnings` you cannot justify in one sentence**.

Two of the three findings are yours to fix. The third — `OrderQueue.java:30`, comparing
against a sentinel by identity — is code that is **correct**, and the answer there is a
`@SuppressWarnings("ReferenceEquality")` on that one method with the reason in a comment.
That is a code review that happened once instead of every time.

The answer is `solution/MealPlan.java`, and `../receipts.sh solution` runs both states and
stops if the shipped project already passes.
