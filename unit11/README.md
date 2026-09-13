# Unit 11 — Arrays: Seven Days of Menus

**What this unit teaches:** An array is a fixed row of same-type values reached by index, with `length` and the enhanced `for`.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit11`), in the order below.

### java WeekMenu.java

Declare, index from 0, `length`, replace a slot, `Arrays.toString`.

```console
$ java WeekMenu.java
Monday: lentil rice
Days: 7
- lentil rice
- bean curry
- chickpea curry
- vegetable stew
- cottage cheese
- spiced rice
- combo plate
[lentil rice, bean curry, chickpea curry, vegetable stew, cottage cheese, spiced rice, combo plate]
[Ljava.lang.String;@ba8d91c
```

### java Orders.java

An `int[]` summed, sorted and reset.

```console
$ java Orders.java
Meals this week: 330
[38, 40, 42, 45, 50, 55, 60]
Busiest day: 60
[0, 0, 0, 0, 0, 0, 0]
```

### java BreakIndex.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** index 7 of a 7-slot array — the last index is 6.

```console
$ java BreakIndex.java
Exception in thread "main" java.lang.ArrayIndexOutOfBoundsException: Index 7 out of bounds for length 7
	at BreakIndex.main(BreakIndex.java:3)
```

Exit code: `1` (non-zero — the failure is the point).
