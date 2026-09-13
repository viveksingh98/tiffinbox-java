# Unit 28 — Lambdas and Functional Interfaces

**What this unit teaches:** A lambda is behaviour written inline and passed as a value: `Predicate`, `Function`, `Consumer`, `Supplier` and method references.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit28`), in the order below.

### java Lambdas.java

The four everyday functional interfaces, plus `removeIf` and a method reference.

```console
$ java Lambdas.java
true false
7200
Ravi pays 7200
Meera pays 4500
Sunil pays 3600
Customer[name=Guest, mealsPerDay=1, pricePerMeal=120, isVeg=true]
true false
2 veg customers
6480
```

### java OldWay.java

The same behaviour as an anonymous class — what the lambda replaced.

```console
$ java OldWay.java
true
```

### java FixCapture.java

The fix for capture: a stream sum, or a one-element array.

```console
$ java FixCapture.java
Revenue: 15300
Revenue: 15300
```

### java BreakCapture.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** a lambda cannot reassign a local variable.

```console
$ java BreakCapture.java
BreakCapture.java:4: error: local variables referenced from a lambda expression must be final or effectively final
    customers.forEach(c -> total += c.monthlyBill());
                           ^
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).
