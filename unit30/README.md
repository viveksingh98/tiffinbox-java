# Unit 30 — Optional: The End of null Checks

**What this unit teaches:** `Optional<T>` says "maybe nothing" in the type: `map`, `orElse`, `ifPresentOrElse` — and why `get()` is a trap.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit30`), in the order below.

### java Finder.java

`findFirst` returns an Optional; read it with `map`/`orElse`/`ifPresentOrElse`.

```console
$ java Finder.java
Optional[Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, isVeg=false]]
Optional.empty
4500
0
Sunil is on the list
no such customer
```

### java WhenAbsent.java

`orElseGet` builds the fallback only when it is needed.

```console
$ java WhenAbsent.java
Ravi pays 7200
Customer[name=Guest, mealsPerDay=1, pricePerMeal=120, isVeg=true]
```

### java NullFinder.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** the old way: a method that returns `null` and a caller that forgets to check.

```console
$ java NullFinder.java
Exception in thread "main" java.lang.NullPointerException: Cannot invoke "NullFinder$Customer.monthlyBill()" because the return value of "NullFinder.findByName(java.util.List, String)" is null
	at NullFinder.main(NullFinder.java:3)
```

Exit code: `1` (non-zero — the failure is the point).

### java BreakOptional.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** `get()` on an empty Optional — the same crash with a new name.

```console
$ java BreakOptional.java
Exception in thread "main" java.util.NoSuchElementException: No value present
	at java.base/java.util.Optional.get(Optional.java:143)
	at BreakOptional.main(BreakOptional.java:3)
```

Exit code: `1` (non-zero — the failure is the point).
