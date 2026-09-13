# Unit 17 — Abstract Classes and Interfaces

**What this unit teaches:** Two ways to describe shape without a finished product: an abstract class for "is a, but incomplete", an interface for "can do".

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit17`), in the order below.

### java AbstractMeal.java

An `abstract class` with state, a constructor and one `abstract` method.

```console
$ java AbstractMeal.java
vegetable stew - 130
```

### java Payable.java

One interface implemented by two unrelated classes.

```console
$ java Payable.java
Due: 7200
Sunil earns 8800
```

### java BreakAbstract.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** `new Meal(...)` on an abstract class.

```console
$ java BreakAbstract.java
BreakAbstract.java:2: error: BreakAbstract.Meal is abstract; cannot be instantiated
    Meal mystery = new Meal("mystery");
                   ^
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).

### java BreakInterface.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** a class that claims an interface but skips a method.

```console
$ java BreakInterface.java
BreakInterface.java:11: error: BreakInterface.Rider is not abstract and does not override abstract method amountDue() in Payable
class Rider implements Payable {
^
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).
