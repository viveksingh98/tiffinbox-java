# Unit 14 — Encapsulation: Private Fields, Public Doors

**What this unit teaches:** Hide the data, expose behaviour: `private` fields, getters, a setter that enforces the rule, `static` and `final`.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1. `Customer.java` has no `main` — the launcher compiles it because `Encapsulation.java` beside it uses it (JEP 458).

Run everything from this folder (`cd unit14`), in the order below.

### java Encapsulation.java

The setter refuses a bad value; `static` counts every customer ever made.

```console
$ java Encapsulation.java
Ravi eats 3
Rejected: -5 meals a day
Ravi still eats 3
Customers: 2
```

### java BreakPrivate.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** reaching past the door straight into a `private` field.

```console
$ java BreakPrivate.java
BreakPrivate.java:3: error: mealsPerDay has private access in Customer
    ravi.mealsPerDay = -5;
        ^
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).

### java BreakFinal.java (from `breakfinal/`) — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** a `final` field left unassigned by the constructor.

```console
$ cd breakfinal
$ java BreakFinal.java
.../tiffinbox-java/unit14/breakfinal/Customer.java:7: error: variable name might not have been initialized
    }
    ^
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).

### Notes

- `Customer.java` is a helper class with no `main`; running `java Customer.java` on its own prints `error: can't find main(String[]) or main() method in class: Customer`. Run `Encapsulation.java` instead.
