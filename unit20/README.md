# Unit 20 — HashMap and HashSet: Look Things Up Fast

**What this unit teaches:** A `Map` answers by key instead of walking a list; a `Set` keeps each value once. Order is never promised.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit20`), in the order below.

### java Dues.java

`put`, `get`, `containsKey`, `getOrDefault`, `merge`, and a sorted `TreeMap` walk.

```console
$ java Dues.java
4500
{Meera=4800, Ravi=7200, Sunil=3600}
false 3
null
0
7440
Meera owes 4800
Ravi owes 7440
Sunil owes 3600
```

### java Phones.java

A `HashSet` dropping the duplicate, and `Map.of` for a fixed lookup.

```console
$ java Phones.java
true
true
false
2 unique: [98200 22222, 98200 11111]
south
```

### java BreakNull.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** `map.get(missingKey)` returns `null`, and unboxing it throws.

```console
$ java BreakNull.java
Exception in thread "main" java.lang.NullPointerException: Cannot invoke "java.lang.Integer.intValue()" because the return value of "java.util.Map.get(Object)" is null
	at BreakNull.main(BreakNull.java:7)
```

Exit code: `1` (non-zero — the failure is the point).
