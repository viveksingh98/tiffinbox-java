# Unit 10 — Methods: Name a Piece of Work

**What this unit teaches:** A method is a named block of work: return type, name, parameters, body — plus overloading and `void`.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit10`), in the order below.

### java Billing.java

`calculateBill` called three ways, an overload, and a `void` method.

```console
$ java Billing.java
7200
4500
7200
Ravi owes 7200 this month
```

### java BreakReturn.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** a non-`void` method that forgets to return.

```console
$ java BreakReturn.java
BreakReturn.java:7: error: missing return statement
}
^
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).
