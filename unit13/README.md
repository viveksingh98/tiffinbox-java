# Unit 13 — Constructors and this

**What this unit teaches:** A constructor fills the object at `new`; `this` separates the field from the parameter of the same name.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit13`), in the order below.

### java Constructors.java

A constructor with arguments, an overloaded one, and `this(...)` chaining.

```console
$ java Constructors.java
Ravi: 7200
[Meera]: 7200
```

### java Shadow.java — **supposed to be wrong**

> **This one is supposed to give the wrong answer — that is the lesson.** the constructor assigns the parameter to itself — the field stays `null`. It compiles, it runs, and it is wrong. Add `this.` to fix it.

```console
$ java Shadow.java
null
```

### java BreakNoArgs.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** write one constructor and the free no-argument one disappears.

```console
$ java BreakNoArgs.java
BreakNoArgs.java:2: error: constructor Customer in class BreakNoArgs.Customer cannot be applied to given types;
    var ravi = new Customer();   // no arguments
               ^
  required: String
  found:    no arguments
  reason: actual and formal argument lists differ in length
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).
