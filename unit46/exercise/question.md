# NullPointerException unboxing HashMap.get inside a daily-total loop (JDK 25)

*Worked step 4 of Exercise 46. Written, then **not** posted — writing part 2 is what found the bug.*

## What I am doing

Counting how many meals to cook today. Names come from an array; today's quantities come from a
`HashMap<String, Integer>`. Not every name is in the map — some customers are not subscribed today.

## Minimal reproduction (3 lines, complete, runs on its own)

```java
void main() {
    var meals = new HashMap<String, Integer>();
    int n = meals.get("Priya");
    IO.println(n);
}
```

Run with `java Repro46.java` (JDK 25 compact source file, no imports needed).

## The exact error

```
Exception in thread "main" java.lang.NullPointerException: Cannot invoke "java.lang.Integer.intValue()" because the return value of "java.util.HashMap.get(Object)" is null
	at Repro46.main(Repro46.java:3)
```

## Version

```console
$ java -version
openjdk version "25.0.4.1" 2026-08-18
OpenJDK Runtime Environment Homebrew (build 25.0.4.1)
OpenJDK 64-Bit Server VM Homebrew (build 25.0.4.1, mixed mode, sharing)
```

## Expected / got / tried

I expected a missing key to give me `0`; I got a `NullPointerException` on the assignment line.
I have tried printing the map (the key really is absent) and checked that `intValue()` appears
nowhere in my code, so something is calling it for me.

---

## The answer, found while writing part 2

`HashMap.get` returns `null` for a missing key. Assigning it to an `int` makes Java insert an
automatic `Integer.intValue()` call — *unboxing* — and there is nothing to call it on. That is the
`intValue()` in the message that I never typed.

Fix: `int meals = mealsToday.getOrDefault(name, 0);`

Second bug in the original file, which never threw anything: the loop ran
`for (int i = 1; i <= customers.length; i++)`, so it skipped `customers[0]` — Ravi — and would have
run off the end. Correct form: `for (int i = 0; i < customers.length; i++)`.

Third change, which is not a bug but the thing Asha asked for in step 3: a `0` on the report is
ambiguous until it says why. `mealsToday.containsKey(name) ? "" : "  (not subscribed today)"` — two
spaces, and `containsKey` rather than `meals == 0`, so a customer who really is down for zero meals
today would not be told they never subscribed.
