# Unit 18 — Records, Enums and Sealed Types

**What this unit teaches:** Three modern types that say what you mean: `record` for immutable data, `enum` for a fixed set, `sealed` for a closed family.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit18`), in the order below.

### java Orders.java

A record's generated `toString`/`equals`, plus an enum with a field.

```console
$ java Orders.java
Order[customer=Ravi, type=VEG, quantity=2]
Ravi pays 240
true
VEG -> 120
NON_VEG -> 150
VEGAN -> 130
```

### java Payments.java

A `sealed interface` with three permitted records and an exhaustive `switch`.

```console
$ java Payments.java
cash at the door
UPI to ravi@okbank
card ending 4421
```

### java BreakRecord.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** a record is a value — its components cannot be reassigned.

```console
$ java BreakRecord.java
BreakRecord.java:3: error: cannot assign a value to final variable quantity
    order.quantity = 3;   // a record is a value
         ^
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).

### java BreakSealed.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** drop one permitted type from the switch and it stops compiling.

```console
$ java BreakSealed.java
BreakSealed.java:7: error: the switch expression does not cover all possible input values
    return switch (payment) {
           ^
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).
