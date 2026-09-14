# Unit 46 — You're On Your Own Now: Practice, Errors and Asking for Help

**What this unit teaches:** how to read a stack trace all the way down, the four errors a beginner
meets first, shrinking a bug to a minimal reproduction, disciplined print-debugging, reading the
Javadoc to answer your own question, catching an AI-invented method, and how to ask a question that
gets answered.

**You need:** JDK 25 (`java.lang.IO` is an ordinary class in `java.lang`, JEP 512 — it works inside a
normal `public class` too, with no import). Verified on JDK 25.0.4.1
(`openjdk version "25.0.4.1" 2026-08-18`, Homebrew).

Run everything from this folder (`cd unit46`), in the order below. **Seven of these programs fail on
purpose.** Every block below is a real capture, run three times, byte-identical each time.

---

## Slide 1 — one stack trace, read line by line

### `java Report.java` — **supposed to crash**

> Ravi is in the map; Priya is not. `bills.get("Priya")` hands back `null`, and `return amount;`
> from an `int` method unboxes it. Line 10 is `return amount;`, line 14 is the call in
> `printReport`, line 21 is the call in `main`. **No `java.base` frames at all** — every line in this
> trace is yours.

```console
$ java Report.java
Ravi owes 7200
Exception in thread "main" java.lang.NullPointerException: Cannot invoke "java.lang.Integer.intValue()" because "<local1>" is null
	at Report.billFor(Report.java:10)
	at Report.printReport(Report.java:14)
	at Report.main(Report.java:21)
```

### `javac -g Report.java` then `java Report` — the same crash, a better message

> This is the unit's sharpest beat. The **only** difference is `-g`, which keeps the local variable
> names in the class file. IntelliJ compiles with `-g` by default; the source launcher
> (`java Report.java`) does not. `"<local1>"` becomes `"amount"` — the quality of the error message
> is something you control.

```console
$ javac -g -d outg Report.java && java -cp outg Report
Ravi owes 7200
Exception in thread "main" java.lang.NullPointerException: Cannot invoke "java.lang.Integer.intValue()" because "amount" is null
	at Report.billFor(Report.java:10)
	at Report.printReport(Report.java:14)
	at Report.main(Report.java:21)
```

Plain `javac` with no flags gives `"<local1>"`, exactly like the source launcher — verified:

```console
$ javac -d outn Report.java && java -cp outn Report
Ravi owes 7200
Exception in thread "main" java.lang.NullPointerException: Cannot invoke "java.lang.Integer.intValue()" because "<local1>" is null
	at Report.billFor(Report.java:10)
	at Report.printReport(Report.java:14)
	at Report.main(Report.java:21)
```

### `java ReportFixed.java` — the fix

> `bills.getOrDefault(customer, 0)` — one word, and a missing customer is a zero instead of a crash.

```console
$ java ReportFixed.java
Ravi owes 7200
Priya owes 0
```

---

## Slide 2 — the four errors you will meet first

### E1 · `java E1CannotFindSymbol.java` — **supposed to fail**

> `mealsperday` vs `mealsPerDay`. The `symbol:` line tells you the name; the `location:` line tells
> you where javac was looking. This one never ran — it is a **compiler** error, with a caret under
> the exact column.

```console
$ java E1CannotFindSymbol.java
E1CannotFindSymbol.java:4: error: cannot find symbol
    IO.println("Ravi owes " + mealsperday * pricePerMeal * 30);
                              ^
  symbol:   variable mealsperday
  location: class E1CannotFindSymbol
1 error
error: compilation failed
```

### E1b · `java BillsNoImport.java` — **supposed to fail** (the version that will actually catch you)

> Compact source files (Units 03-45) import all of `java.base` for you. A normal `public class` does
> **not**. Same error, twice, for `Map` and `HashMap`. Fix: `import java.util.Map;` and
> `import java.util.HashMap;` — which is why `Report.java` in this folder has both.

```console
$ java BillsNoImport.java
BillsNoImport.java:2: error: cannot find symbol
    static Map<String, Integer> bills = new HashMap<>();
           ^
  symbol:   class Map
  location: class BillsNoImport
BillsNoImport.java:2: error: cannot find symbol
    static Map<String, Integer> bills = new HashMap<>();
                                            ^
  symbol:   class HashMap
  location: class BillsNoImport
2 errors
error: compilation failed
```

### E2 · `java E2IncompatibleTypes.java` — **supposed to fail**

> The shapes do not match. The same message appears on a bad `return`. The fix is
> `Integer.parseInt("two")` — a conversion, not a cast.

```console
$ java E2IncompatibleTypes.java
E2IncompatibleTypes.java:2: error: incompatible types: String cannot be converted to int
    int mealsPerDay = "two";
                      ^
1 error
error: compilation failed
```

### E3 · `java E3IndexOutOfBounds.java` — **supposed to crash**

> The loop starts at 1 and runs to `length`. Read what printed **before** the crash: `Day 1: Tue`.
> It skipped Monday as well as running off the end — one bug, two symptoms. Last index is
> `length - 1`, always.

```console
$ java E3IndexOutOfBounds.java
Day 1: Tue
Day 2: Wed
Day 3: Thu
Day 4: Fri
Day 5: Sat
Day 6: Sun
Exception in thread "main" java.lang.ArrayIndexOutOfBoundsException: Index 7 out of bounds for length 7
	at E3IndexOutOfBounds.main(E3IndexOutOfBounds.java:4)
```

### E4 · the `NullPointerException` — slide 1's `Report.java`, above.

E1 and E2 came from **javac**, before anything ran: a source line and a caret.
E3 and E4 came from the **JVM**, while running: a message and a stack trace.

---

## Slide 3 — shrink it

### `java PauseReport.java` — **supposed to crash** (and to be wrong before it crashes)

> Two faces, one bug. Line two is the silent one: Ravi cancelled the pause on day **2** and day
> **3** disappeared. No exception, no warning, a wrong bill for a year. Then the same call throws.
> The trace has **five `java.base` frames** before it reaches your file — `PauseReport.java:14` is
> the first line that is yours, and that is the one to open.

```console
$ java PauseReport.java
Ravi paused : [1, 2, 3, 4, 5]
After cancelling the pause on day 2: [1, 2, 4, 5]
Exception in thread "main" java.lang.IndexOutOfBoundsException: Index 5 out of bounds for length 4
	at java.base/jdk.internal.util.Preconditions.outOfBounds(Preconditions.java:100)
	at java.base/jdk.internal.util.Preconditions.outOfBoundsCheckIndex(Preconditions.java:106)
	at java.base/jdk.internal.util.Preconditions.checkIndex(Preconditions.java:302)
	at java.base/java.util.Objects.checkIndex(Objects.java:365)
	at java.base/java.util.ArrayList.remove(ArrayList.java:552)
	at PauseReport$PauseBook.unpause(PauseReport.java:14)
	at PauseReport.main(PauseReport.java:32)
```

### `java Shrink.java` — the same bug, four lines

> Thirty lines cut down by deleting: the record went, the map went, the class went, the method went.
> `List<Integer>` has both `remove(int index)` and `remove(Object o)`, and an `int` argument picks
> the index one every time.

```console
$ java Shrink.java
[1, 2, 4, 5]
```

### `java ShrinkFixed.java` — the fix

```console
$ java ShrinkFixed.java
[1, 3, 4, 5]
```

The Javadoc that settles it, verbatim from this JDK's `lib/src.zip`
(`java.base/java/util/List.java`, lines 291 and 629):

```java
/**
 * Removes the first occurrence of the specified element from this list,
 * if it is present (optional operation). ...
 * @param o element to be removed from this list, if present
 * @return {@code true} if this list contained the specified element
 */
boolean remove(Object o);

/**
 * Removes the element at the specified position in this list (optional
 * operation).  Shifts any subsequent elements to the left ...
 * @param index the index of the element to be removed
 * @return the element previously at the specified position
 * @throws IndexOutOfBoundsException if the index is out of range
 *         ({@code index < 0 || index >= size()})
 */
E remove(int index);
```

---

## Slide 4 — print-debugging with discipline

### `java Trace.java`

> Label it, print the whole collection and not just its size, and print on **both sides** of the
> suspect line. Two lines of output and the bug is visible: `2` went in, `2` is still there, `3` is
> gone.

```console
$ java Trace.java
[unpause] day=2 list=[1, 2, 3, 4, 5] size=5
[unpause] after remove list=[1, 2, 4, 5]
```

In IntelliJ the same answer comes from a breakpoint on the `days.remove(day)` line — and a
**conditional** breakpoint (right-click the red dot → `day >= 28`) is the one thing a print cannot
do cheaply when the bug only happens on the twenty-eighth round. Delete the prints before you
commit.

---

## Slide 5 — the AI rule

### `java BreakHallucination.java` — **supposed to fail**

> `capitalize()` is a Python method. Java has no such thing. An assistant will write it confidently;
> the compiler disagrees in under a second. Note the `location:` line — it names the *variable* and
> its type, which is how you know you are looking at the wrong class's method list.

```console
$ java BreakHallucination.java
BreakHallucination.java:3: error: cannot find symbol
    IO.println(name.capitalize());
                   ^
  symbol:   method capitalize()
  location: variable name of type String
1 error
error: compilation failed
```

### `java Capitalise.java` — what the docs actually give you

```console
$ java Capitalise.java
Meera
```

Checked against the docs: `java.lang.String` has no `capitalize` in JDK 25 —
`javap java.lang.String | grep -i capital` prints nothing.

---

## The exercise

`exercise/` — "Unstick Yourself". **Edit `exercise/DayReportStarter.java`** — it compiles and runs
unedited (two lines, then the crash), and the TODOs mark the two bug sites and the note Asha wants.
`DayReportBroken.java` beside it is the pristine original, kept so you can re-read the trace.
Read `exercise/README.md` first. `Repro46.java`, `DayReport.java` and `question.md` are the worked
answers and are not to be opened until steps 1-4 are done; `question-template.md` holds the five empty
headings for step 4.

Three edits, not two: the loop bounds, `getOrDefault`, **and** the `(not subscribed today)` note — the
acceptance output in `exercise/README.md` needs all three, and step 3 says so.

```console
$ cd exercise
$ java DayReportStarter.java          # where it starts: two lines, then the NullPointerException
$ java DayReport.java                 # where it ends (the worked answer)
Ravi: 2
Meera: 1
Sunil: 1
Priya: 0  (not subscribed today)
Meals to cook today: 4
```

---

## Notes

- `outg/` and `outn/` are the only build folders this unit creates; `rm -rf outg outn` resets it.
- Every capture above was produced three times and was byte-identical each time (md5 of the
  combined stdout+stderr stream compared across runs).
- Nothing here needs the network.
