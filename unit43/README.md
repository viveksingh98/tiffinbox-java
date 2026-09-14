# Unit 43 — Talking to the User: Scanner, args, and a Program That Answers Back

**What this unit teaches:** How a program asks a question and reads the answer — `Scanner` + `nextLine()`, the `nextInt()`-then-`nextLine()` trap reproduced live, what happens when the input runs out, JDK 25's one-line `IO.readln("prompt")`, and `String[] args` — the promise Unit 03 made and never kept.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1 (`openjdk version "25.0.4.1" 2026-08-18`, Homebrew).

Run everything from this folder (`cd unit43`), in the order below.

**Every interactive program here is driven with piped input** (`printf '…' | java File.java`) so the output is reproducible and nothing is ever left waiting on a terminal. **Piped input is not echoed**, so the prompts run together on one line — that is why `Customer name: Meals per day: Welcome Priya…` is one line and not three. Type the same values by hand and you get the familiar three-line conversation.

Every capture below was taken **three times**; all three were byte-identical (same `md5`).

---

### java SignUp.java — the first conversation

`Scanner` on `System.in`, `System.out.print` for the prompt so the cursor stays on the line, `nextLine()` for the answer, `Integer.parseInt` to turn the answer into a number.

```console
$ printf 'Priya\n2\n' | java SignUp.java
Customer name: Meals per day: Welcome Priya - 2 meals a day, 7200 a month.
```

### java BreakScanner.java — **supposed to be wrong**

> **This one is supposed to lose the name — that is the lesson.** `nextInt()` takes the `2` and stops *in front of* the newline. The very next `nextLine()` reads "everything up to the next newline", finds it immediately, and hands back an empty String. The brackets are in the print so nobody can argue about it.

```console
$ printf '2\nPriya\n' | java BreakScanner.java
Meals per day: Customer name: Welcome [] - 2 meals a day.
```

### java FixScanner.java — the forum patch

One extra `in.nextLine()` after `nextInt()` eats the leftover newline. It works. It is also the patch you will find in a thousand forum answers — this course teaches the other fix instead: **read whole lines, always, and parse them.**

```console
$ printf '2\nPriya\n' | java FixScanner.java
Meals per day: Customer name: Welcome [Priya] - 2 meals a day.
```

### java NextVariants.java — the trap wears other names

Proof that `next()`, `nextDouble()` and `nextBoolean()` all leave the newline behind too: after each one, the rest of that line is empty.

```console
$ printf 'VEG\n2.5\ntrue\n' | java NextVariants.java
next()        left: [VEG] rest of that line: []
nextDouble()  left: [2.5] rest of that line: []
nextBoolean() left: [true] rest of that line: []
```

### java BreakClosed.java — **supposed to crash**

> **This one is supposed to throw — that is the lesson.** Close the input (Ctrl-D on Mac and Linux, Ctrl-Z then Enter on Windows, or a script that simply ends) and `nextLine()` does not return an empty String. It throws.

```console
$ printf '' | java BreakClosed.java
Customer name: Exception in thread "main" java.util.NoSuchElementException: No line found
	at java.base/java.util.Scanner.nextLine(Scanner.java:1690)
	at BreakClosed.main(BreakClosed.java:4)
```

### java Guard.java — `hasNextLine()` asks without taking

The guard Unit 37 used and Unit 38's `readChoice` relies on. Two runs, one file.

```console
$ printf '' | java Guard.java
Customer name: (no input - closing TiffinBox)
```

```console
$ printf 'Priya\n' | java Guard.java
Customer name: Welcome Priya
```

### java Blank.java — blank is not closed

A blank line is a real line: `nextLine()` hands back `""`, not `null` and not an exception. Only *after* it has been taken does `hasNextLine()` say `false`.

```console
$ printf '\n' | java Blank.java
Scanner on a blank line: [] null? false
hasNextLine now       : false
```

### java Readln.java — the JDK 25 one-liner

`IO.readln("Customer name: ")` prints the prompt and reads the line in one call. No `Scanner`, no `System.out.print`, no import — `IO` is in `java.lang`.

```console
$ printf 'Priya\n2\n' | java Readln.java
Customer name: Meals per day: Welcome Priya - 2 meals a day, 7200 a month.
```

That output is **byte-identical** to `SignUp.java`'s — same `md5` (`26a6a738448870c98fabf8152b8399d2`). Same conversation, six lines of code instead of seven:

```console
$ printf 'Priya\n2\n' | java SignUp.java | md5 -q
26a6a738448870c98fabf8152b8399d2
$ printf 'Priya\n2\n' | java Readln.java | md5 -q
26a6a738448870c98fabf8152b8399d2
```

### java Readln.java with the input closed — **supposed to crash**

> **This is the difference nobody documents.** At end of input `Scanner.nextLine()` **throws**; `IO.readln` **returns `null`** and lets you walk into the next line of code. Here the `null` reaches `Integer.parseInt`, which names it in the message.

```console
$ printf '' | java Readln.java
Customer name: Meals per day: Exception in thread "main" java.lang.NumberFormatException: Cannot parse null string
	at java.base/java.lang.Integer.parseInt(Integer.java:527)
	at java.base/java.lang.Integer.parseInt(Integer.java:662)
	at Readln.main(Readln.java:3)
```

### java ReadlnNull.java — the `null`, printed

The same fact with no exception in the way.

```console
$ printf '' | java ReadlnNull.java
Customer name: readln handed back: null
name == null ? true
```

### javap java.lang.IO — the whole class

`IO` is small and `final`. **Five public methods, and no `printf`** — that is why Unit 42 goes back to `System.out.printf` for aligned output. (`reader()` has no `public` on it: it is package-private, so your code cannot call it.)

```console
$ javap java.lang.IO
Compiled from "IO.java"
public final class java.lang.IO {
  public static void println(java.lang.Object);
  public static void println();
  public static void print(java.lang.Object);
  public static java.lang.String readln();
  public static java.lang.String readln(java.lang.String);
  static synchronized java.io.BufferedReader reader();
}
```

### java Bill.java Ravi 2 120 — Unit 03's promise, kept

`String[] args` holds whatever you typed after the file name. In order, always Strings, built by the JVM before your first line runs.

```console
$ java Bill.java Ravi 2 120
args.length = 3
args        = [Ravi, 2, 120]
Ravi owes 7200 this month.
```

**In IntelliJ:** Run → Edit Configurations… → **Program arguments** → type `Ravi 2 120`. Same array.

### java Bill.java Ravi two 120 — **supposed to crash**

> They are **always Strings**. `Integer.parseInt` is what turns `"2"` into `2` — and it refuses `"two"`.

```console
$ java Bill.java Ravi two 120
args.length = 3
args        = [Ravi, two, 120]
Exception in thread "main" java.lang.NumberFormatException: For input string: "two"
	at java.base/java.lang.NumberFormatException.forInputString(NumberFormatException.java:67)
	at java.base/java.lang.Integer.parseInt(Integer.java:565)
	at java.base/java.lang.Integer.parseInt(Integer.java:662)
	at Bill.main(Bill.java:9)
```

### java Bill.java — no arguments, and the usage line

No arguments is not an error. It is an **empty array** — `args` is never `null`.

```console
$ java Bill.java
args.length = 0
args        = []
Usage: java Bill.java <name> <mealsPerDay> <pricePerMeal>
```

### java BreakArgs.java — **supposed to crash**

> **This is what the usage guard is protecting you from.** `args[0]` with nothing passed.

```console
$ java BreakArgs.java
Exception in thread "main" java.lang.ArrayIndexOutOfBoundsException: Index 0 out of bounds for length 0
	at BreakArgs.main(BreakArgs.java:2)
```

### java Classic.java — **supposed to fail to compile**

> **Why is there no `import` line in any of the files above?** A compact source file imports the whole `java.base` module for you, so `Scanner` just resolves. A normal `public class` does not get that.

```console
$ java Classic.java
Classic.java:3: error: cannot find symbol
        Scanner in = new Scanner(System.in);
        ^
  symbol:   class Scanner
  location: class Classic
Classic.java:3: error: cannot find symbol
        Scanner in = new Scanner(System.in);
                         ^
  symbol:   class Scanner
  location: class Classic
2 errors
error: compilation failed
```

### java ClassicFixed.java — one line fixes it

`import java.util.Scanner;` at the top (Unit 33's rule).

```console
$ printf 'Priya\n' | java ClassicFixed.java
Welcome Priya
```

---

## Exercise — "Sign Priya Up, Both Ways"

**Start at `exercise/SignUpStarter.java`** — it compiles and runs unedited, with three `// TODO` stubs.
Full task, the six acceptance runs and the traps: **`exercise/README.md`**.
**`exercise/SignUp.java` is the worked solution — open it last;** its design notes are in a comment at the
bottom of that file, deliberately not in any README.

Write **one** program with two ways in:

- With **three** arguments it registers straight away.
- With **no** arguments it asks three questions.
- With any other count it prints a usage line.
- It must reject a non-number, reject meals outside 1 to 3, and survive the input being closed.
- **No `nextInt()` anywhere.**

Asha's numbers: the monthly bill is `mealsPerDay × pricePerMeal × 30`.

### Expected output — all six runs, each byte-identical over three runs

```console
$ java SignUpStarter.java Priya 2 120
Welcome Priya - 2 meals a day, 7200 a month.
```

```console
$ printf 'Priya\n2\n120\n' | java SignUpStarter.java
Customer name: Meals per day (1-3): Price per meal: Welcome Priya - 2 meals a day, 7200 a month.
```

```console
$ printf '' | java SignUpStarter.java
Customer name: (input closed - nothing saved)
```

```console
$ java SignUpStarter.java Priya two 120
Error: not a number - For input string: "two"
```

```console
$ java SignUpStarter.java Priya 9 120
Error: meals a day must be 1 to 3, got 9
```

```console
$ java SignUpStarter.java Priya
Usage: java SignUpStarter.java <name> <mealsPerDay> <pricePerMeal>
```

The usage line names the file you run, so the worked solution prints `java SignUp.java` there instead; every other line is identical. Note the third run: **one** prompt, not three. That is the acceptance test for the closed-input rule — `ask` must return `null` and `main` must return immediately, or you will print all three prompts into a void.

### Worked solution

`exercise/SignUp.java` — run it from that folder (`cd exercise`) with exactly the commands above, but only
after your own six runs match. How it is put together is written at the **bottom of that file**, so it
cannot be read by accident.

### Notes

- Nothing here writes a file and nothing needs a network.
- `java File.java` compiles in memory — there are no `.class` files to clean up.
