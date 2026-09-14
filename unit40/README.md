# Unit 40 — Recursion, Varargs and Two-Dimensional Arrays

**What this unit teaches:** a method that calls itself needs a base case and a smaller problem; `int...` takes however many arguments and is just an array inside; `[][]` is an array of arrays.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1 (`openjdk version "25.0.4.1" 2026-08-18`, Homebrew, `/opt/homebrew/opt/openjdk@25`).

Run everything from this folder (`cd unit40`), in the order below. Every output here is a real capture. Each command was run **at least three times**; anything not byte-identical is marked.

### java Combo.java

Recursion: a box that holds boxes. Base case + recursive case.

```console
$ java Combo.java
Family lunch costs 270
```

### java ComboTrace.java

The same recursion, printing its own call stack. Every `->` meets a `<-`; nothing returns until the things below it have.

```console
$ java ComboTrace.java
-> totalOf(family lunch)
  -> totalOf(veg plate)
    -> totalOf(lentil rice)
    <- 120 (base case)
    -> totalOf(bean curry)
    <- 60 (base case)
  <- 180
  -> totalOf(vegetable stew)
  <- 90 (base case)
<- 270
```

### java Contains.java

The same three questions on a different shape. `totalOf` combines with `+=` and hands back a number;
`contains` compares in the base case and combines by **stopping at the first yes**. Byte-identical over
three runs.

```console
$ java Contains.java
bean curry in the lunch?  true
spiced rice in the lunch? false
```

The recipe, in three questions — it works for every recursive method you will ever write:

| | `totalOf` | `contains` |
|---|---|---|
| **1** what is the smallest input, and what is its answer? | a meal → its price | a meal → is this the dish? |
| **2** how do I hand on something smaller? | one part at a time | one part at a time |
| **3** how do I combine what comes back? | `+=` — add them all up | stop at the first `true` |

### java BreakBaseCase.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** The base case is deleted, so nothing stops the calling.

**⚠ DIFFERS EVERY RUN — the first line only.** Across 21 runs on this machine the counter was
15435 (×7) · 17129 · 21924 · 23151 · 25138 · 28270 · 28434 · 28766 · 29094 · 29755 · 29918 · 32562 · 32927 · 34769 · 86633 — a spread of 15,435 to 86,633, so never quote it as a fixed number. The stack is a fixed lump of memory and how much is free when you start depends on the machine.

Two real captures, same file, same JDK:

```console
$ java BreakBaseCase.java
calls before the crash: 15435
Exception in thread "main" java.lang.StackOverflowError
	at BreakBaseCase.daysLeft(BreakBaseCase.java:5)
	at BreakBaseCase.daysLeft(BreakBaseCase.java:5)
	at BreakBaseCase.daysLeft(BreakBaseCase.java:5)
[1016 lines cut to fit — see the note below]
```

```console
$ java BreakBaseCase.java
calls before the crash: 86633
Exception in thread "main" java.lang.StackOverflowError
	at BreakBaseCase.daysLeft(BreakBaseCase.java:5)
	at BreakBaseCase.daysLeft(BreakBaseCase.java:5)
	at BreakBaseCase.daysLeft(BreakBaseCase.java:5)
[1016 lines cut to fit — see the note below]
```

The bracketed line is **ours, not the JVM's**. The JVM prints no ellipsis and trims nothing: the whole
run is 1021 lines — one counter line, one exception line and **1019** `at` lines. Measure it yourself:

```console
$ java BreakBaseCase.java 2>&1 | wc -l
    1021
$ java BreakBaseCase.java 2>&1 | grep -c 'more'
0
```

**What IS stable — measured on all 21 runs:**

| fact | value |
|---|---|
| printed `at` lines | **exactly 1019**, every run |
| the repeated frame | `BreakBaseCase.daysLeft(BreakBaseCase.java:5)`, every run |
| `main` at the bottom of the trace | **never present** — the trace is cut off |
| exit code | `1` |

Reproduce the count yourself:

```console
$ java BreakBaseCase.java 2>&1 | grep -c '	at '
1019
$ java BreakBaseCase.java 2>&1 | grep -c 'BreakBaseCase.main'
0
```

**The fix:** put the base case back — that is `DaysLeft.java`.

### java DaysLeft.java

The same answer both ways. Counting days is a row, so the loop wins: it cannot overflow and it reads more easily.

```console
$ java DaysLeft.java
Recursion: 30
Loop:      30
```

### java NoTailCalls.java — **supposed to fail**

> Proof that Java does not quietly rewrite recursion as a loop. The recursive call here **is** the last thing the method does (a *tail call*) and there **is** a base case — HotSpot still keeps one stack frame per call.

```console
$ java NoTailCalls.java
30 days      : 30
Exception in thread "main" java.lang.StackOverflowError
	at NoTailCalls.countDown(NoTailCalls.java:5)
	at NoTailCalls.countDown(NoTailCalls.java:5)
[1017 lines cut to fit — 1019 `at` lines in total, nothing trimmed by the JVM]
```

`at` lines: **1019**, every run. **⚠ the top frame's line number differs**: `NoTailCalls.java:5` (the call) on some runs, `NoTailCalls.java:4` (the base-case test) on others — measured both. Everything below it is line 5.

### java Varargs.java

`int... amounts` = "zero or more of these". Inside the method it is **just an array**, which is why line 4 (an `int[]` handed straight in) works unchanged.

```console
$ java Varargs.java
0 bills [] -> 0
1 bills [7200] -> 7200
5 bills [7200, 4500, 3600, 7200, 5520] -> 28020
3 bills [7200, 4500, 3600] -> 15300
```

### java BreakVarargs.java — **supposed to fail**

> Varargs put first. Java has to know where the "however many" stops, so nothing may follow it — and there can only be one.

```console
$ java BreakVarargs.java
BreakVarargs.java:1: error: varargs parameter must be the last parameter
int total(int... amounts, String label) {
                 ^
1 error
error: compilation failed
```

Exit code: `1`.

### java WeekGrid.java

`int[7][2]` — an array of arrays. `[row][column]`. Jagged rows are legal: Java has no rectangle rule.

```console
$ java WeekGrid.java
Empty grid: [[0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]]
Rows 7, columns 2
Wednesday non-veg: 14
Mon  veg 40  non-veg 12
Tue  veg 38  non-veg 10
Wed  veg 42  non-veg 14
Thu  veg 41  non-veg 9
Fri  veg 45  non-veg 18
Sat  veg 52  non-veg 22
Sun  veg 30  non-veg 6
Week total: veg 288, non-veg 91
Jagged: [[120], [120, 150], [120, 150, 130]]
```

### java FlatVsDeep.java — **⚠ NOT A FIXED VALUE**

Why `Arrays.toString` is useless on a grid: it prints each row's *identity hash code* (the `@` code Unit 11 met), not the meals.

```console
$ java FlatVsDeep.java
toString    : [[I@4e41089d, [I@32a068d1, [I@33cb5951, [I@365c30cc, [I@701fc37a, [I@4148db48, [I@282003e1]
deepToString: [[40, 12], [38, 10], [42, 14], [41, 9], [45, 18], [52, 22], [30, 6]]
```

The `deepToString` line is byte-identical on every run. The `toString` line was byte-identical across five runs of *this* file on this JDK build — but it is **not a constant**. `FlatVsDeepWarm.java` is the same program with one extra `new Object()` allocated first, and every code changes:

```console
$ java FlatVsDeepWarm.java
toString    : [[I@12028586, [I@17776a8, [I@69a10787, [I@2d127a61, [I@2bbaf4f0, [I@11c20519, [I@70beb599]
```

Never hand-type these; re-capture from the file in front of you. The deck follows Unit 23's convention for
identity hashes — a **greyed placeholder hex** plus a "yours will differ" chip — rather than printing the
concrete codes above, because they are not a promise the language makes.

### java Labels.java

The course's first nested loop, and the thing that bites immediately: a plain `break` leaves the **inner** loop only. A label on the outer loop plus `break search;` leaves both.

```console
$ java Labels.java
Busy: Wed
Busy: Thu
Busy: Fri
Busy: Sat
First busy slot: Wed
```

### java ArraysToolkit.java

The rest of the `Arrays` toolbox — signposted here, documented in the JDK (Unit 44 teaches you to read it).

```console
$ java ArraysToolkit.java
copyOf(orders, 3)         : [40, 42, 38]
copyOf(orders, 9)         : [40, 42, 38, 45, 50, 60, 55, 0, 0]
copyOfRange(orders, 2, 5) : [38, 45, 50]
fill(fresh, 7)            : [7, 7, 7, 7, 7, 7, 7]
a == b                    : false
Arrays.equals(a, b)       : true
sorted                    : [38, 40, 42, 45, 50, 55, 60]
binarySearch(sorted, 50)  : 4
stream(orders).sum()      : 330
```

`a` and `b` hold the same three numbers. `==` asks "the same array?" (**false**); `Arrays.equals` asks "the same contents?" (**true**).

`binarySearch` only works on a **sorted** array — that is why `sorted` is sorted one line above. Hand it an
unsorted array and it does not throw: it returns a wrong answer, quietly. Sort first, every time.

---

## 🏋️ EXERCISE 40 — "The Party Box"

**Your turn. Open `exercise/PartyBoxStarter.java` and fill in the four TODO methods — nothing else needs to change.**

Asha sells a party box that may contain plates, and plates contain meals. Starting from the `Item` record on slide 1:

| method | shape | rule |
|---|---|---|
| `int countMeals(Item)` | recursive | how many actual meals, at any depth |
| `int depth(Item)` | recursive | how many layers; a bare meal is 1 |
| `int cheapest(int... prices)` | varargs | the smallest price; **0** when no prices are handed in |
| `String busiestDay(int[][] week, String[] days)` | nested loop | the day with the most meals, both types added together |

```console
$ cd exercise
$ java PartyBoxStarter.java
Meals in the box: 0
Nesting depth   : 0
Cheapest of 120, 60, 90: 0
Cheapest of nothing    : 0
Busiest day     : ?
Grid            : [[40, 12], [38, 10], [42, 14], [41, 9], [45, 18], [52, 22], [30, 6]]
```

**You are done when `java PartyBoxStarter.java` prints exactly this (byte-identical over three runs):**

```console
Meals in the box: 3
Nesting depth   : 3
Cheapest of 120, 60, 90: 60
Cheapest of nothing    : 0
Busiest day     : Sat (74 meals)
Grid            : [[40, 12], [38, 10], [42, 14], [41, 9], [45, 18], [52, 22], [30, 6]]
```

**Do not open `exercise/PartyBox.java` first** — that is the worked solution. When you are stuck, or when you are finished and want to compare:

```console
$ java PartyBox.java
Meals in the box: 3
Nesting depth   : 3
Cheapest of 120, 60, 90: 60
Cheapest of nothing    : 0
Busiest day     : Sat (74 meals)
Grid            : [[40, 12], [38, 10], [42, 14], [41, 9], [45, 18], [52, 22], [30, 6]]
```

Full task, expected output and traps: **`exercise/README.md`**. Start at `exercise/PartyBoxStarter.java`.

---

> 📌 Verified on JDK 25.0.4.1 · every console block above is a real capture, three runs minimum · outputs marked ⚠ are not fixed and say why.
