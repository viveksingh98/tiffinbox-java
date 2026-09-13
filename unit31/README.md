# Unit 31 — Pattern Matching: instanceof and switch

**What this unit teaches:** A pattern tests the type and binds the variable in one step: record patterns, guarded cases and `case null`.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit31`), in the order below.

### java Patterns.java

`instanceof` patterns, record patterns, nested patterns and `when` guards.

```console
$ java Patterns.java
Ravi ordered 2 meals
cash at the door
UPI to ravi@okbank
Visa ending 4421
card ending 5123
Meera paid for 1 NON_VEG by UPI (meera@okbank)
Sunil paid 130 another way
```

### java NullSwitch.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** a `switch` on `null` throws unless you write `case null`.

```console
$ java NullSwitch.java
Exception in thread "main" java.lang.NullPointerException
	at java.base/java.util.Objects.requireNonNull(Objects.java:220)
	at NullSwitch.describe(NullSwitch.java:7)
	at NullSwitch.main(NullSwitch.java:3)
```

Exit code: `1` (non-zero — the failure is the point).

### java BreakGuard.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** a guarded case never counts towards exhaustiveness.

```console
$ java BreakGuard.java
BreakGuard.java:6: error: the switch expression does not cover all possible input values
    return switch (payment) {
           ^
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).

### java BreakDominated.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** a broad case above a narrow one hides it.

```console
$ java BreakDominated.java
BreakDominated.java:10: error: this case label is dominated by a preceding case label
        case Card(String last4) when last4.startsWith("4") -> "Visa ending " + last4;
             ^
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).

### java OrScope.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** a pattern variable is not in scope on the right of `||`.

```console
$ java OrScope.java
OrScope.java:3: error: cannot find symbol
    if (item instanceof Order order || order.quantity() > 1) {
                                       ^
  symbol:   variable order
  location: class OrScope
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).
