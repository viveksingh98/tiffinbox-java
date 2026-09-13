# Unit 19 — ArrayList: A List That Grows

**What this unit teaches:** `List` is the interface, `ArrayList` the growable class: add, get, remove, contains — and the two classic traps.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit19`), in the order below.

### java Customers.java

`add`, `get`, `size`, `remove`, `contains`, `Collections.reverse`.

```console
$ java Customers.java
[Ravi, Meera, Sunil]
3 customers, first: Ravi
false
Meera ... Sunil
[Sunil, Ravi, Meera]
```

### java Orders.java

A `List` of records, looped and summed.

```console
$ java Orders.java
3 orders, today's takings: 520
bean curry of 3
```

### java FixLoop.java

The fix for removing while looping: `removeIf`.

```console
$ java FixLoop.java
[Meera, Sunil]
```

### java BreakFixed.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** `List.of(...)` is fixed-size — `add` throws.

```console
$ java BreakFixed.java
Exception in thread "main" java.lang.UnsupportedOperationException
	at java.base/java.util.ImmutableCollections.uoe(ImmutableCollections.java:159)
	at java.base/java.util.ImmutableCollections$AbstractImmutableCollection.add(ImmutableCollections.java:164)
	at BreakFixed.main(BreakFixed.java:3)
```

Exit code: `1` (non-zero — the failure is the point).

### java BreakLoop.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** removing inside an enhanced `for`.

```console
$ java BreakLoop.java
Exception in thread "main" java.util.ConcurrentModificationException
	at java.base/java.util.ArrayList$Itr.checkForComodification(ArrayList.java:1096)
	at java.base/java.util.ArrayList$Itr.next(ArrayList.java:1050)
	at BreakLoop.main(BreakLoop.java:3)
```

Exit code: `1` (non-zero — the failure is the point).
