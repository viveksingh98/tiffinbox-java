# Unit 23 — equals, hashCode and toString

**What this unit teaches:** The three methods every class inherits from `Object`, why the defaults are wrong for your classes, and the contract.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit23`), in the order below.

### java Identity.java

The defaults: `Class@hash` and identity-based `equals`.

```console
$ java Identity.java
Identity$Customer@51b7e5df
false
false
```

### java ToStringDemo.java

`toString` overridden, and `equals` alone making two customers equal.

```console
$ java ToStringDemo.java
Ravi (2 meals/day)
Today: Ravi (2 meals/day)
true
```

### java BreakSet.java — **supposed to be wrong**

> **This one is supposed to give the wrong answer — that is the lesson.** `equals` without `hashCode`: the `HashSet` keeps the duplicate and cannot find it. It runs happily and the answer is wrong.

```console
$ java BreakSet.java
2 customers, contains Ravi: false
```

### java FixSet.java

Add `hashCode` and the set behaves.

```console
$ java FixSet.java
1 customers, contains Ravi: true
```

### java RecordSet.java

A record generates all three for free.

```console
$ java RecordSet.java
Customer[name=Ravi, mealsPerDay=2]
true
2
```

### java BreakEqualsSig.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** `equals(Customer)` is an overload, not an override.

```console
$ java BreakEqualsSig.java
BreakEqualsSig.java:15: error: method does not override or implement a method from a supertype
    @Override
    ^
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).
