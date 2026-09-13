# Unit 12 — Classes and Objects: Meet Customer

**What this unit teaches:** A class is the blueprint, an object is one real customer built with `new` — fields, defaults and methods.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit12`), in the order below.

### java Customer.java

Two objects from one class, each with its own field values.

```console
$ java Customer.java
Ravi eats 2 meals a day
Monthly: 7200
Monthly: 4500
Ravi now eats 3
```

### java BreakNoNew.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** a declared reference with no `new` behind it.

```console
$ java BreakNoNew.java
BreakNoNew.java:3: error: variable ravi might not have been initialized
    ravi.name = "Ravi";
    ^
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).
