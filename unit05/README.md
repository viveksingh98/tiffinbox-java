# Unit 05 — Variables and Types: Where Data Lives

**What this unit teaches:** A variable is a named, typed box in memory: declare-and-assign, the types TiffinBox needs, and `var`.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit05`), in the order below.

### java Customer.java

The four TiffinBox variables plus `var total`.

```console
$ java Customer.java
Ravi eats 2 meals, pays 240.0
```

### java BreakIt.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** `mealsPerDay = "two";` — a value can change, its type cannot.

```console
$ java BreakIt.java
BreakIt.java:5: error: incompatible types: String cannot be converted to int
    mealsPerDay = "two";
                  ^
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).
