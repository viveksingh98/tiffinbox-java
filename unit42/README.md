# Unit 42 — Text, Properly: char, the Methods You'll Type Daily, and printf

**What this unit teaches:** `char` is a number you can do arithmetic on, the dozen `String` methods you
will actually type this month, and `System.out.printf` for output that lines up.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1
(`openjdk version "25.0.4.1" 2026-08-18`, `/opt/homebrew/opt/openjdk@25`).

> **Why `System.out.printf` and not `IO.printf`?** There is no `IO.printf`. `javap java.lang.IO` lists the
> whole class: `println(Object)`, `println()`, `print(Object)`, `readln()`, `readln(String)`. Formatting is
> the one job `java.lang.IO` does not do, so this unit goes back to `System.out`.
>
> **Locale matters here.** `%,d` and `%.2f` follow the machine's language setting. Every capture below was
> taken at **`en_US`**. Pin it the way the commands show — `-Duser.language=en -Duser.country=US` — or read
> the `locale:` line each program prints and expect your own machine's grouping if it differs.

Run everything from this folder (`cd unit42`), in the order below.

### java Chars.java

`charAt`, the index loop, and the fact that surprises everyone: a `char` **is** a number.

```console
$ java Chars.java
First letter: M
Initial + dot: M.
0 -> M
1 -> e
2 -> e
3 -> r
4 -> a
'M' as a number: 77
(char)(77)     : M
'M' + 1        : 78
(char)('M' + 1): N
'm' - 'M'      : 32
Not a digit at 5: x
Digits found: 9 of 10
isLetter('x') : true
toUpperCase('x'): X
```

### java TextToolkit.java

The everyday twelve on dirty typed input, plus the two that bite: `trim` vs `strip`, and `split` dropping
the empty last field.

```console
$ java TextToolkit.java
[Cottage Cheese Curry]
[Cottage Cheese Curry]
lower  : cottage cheese curry
replace: Cottage Cheese Stew
every one: stew, stew, stew
indexOf("Cheese")   : 8
indexOf('e')        : 6
lastIndexOf('e')    : 13
indexOf("chicken")  : -1
"".isEmpty()   : true
"   ".isEmpty(): false
"   ".isBlank(): true
----------------------------
valueOf(7200) : 7200
join: Ravi, Meera, Sunil
split default: [Ravi, 2, 120] length 3
split(-1)    : [Ravi, 2, 120, ] length 4
trim  [ Ravi ] length 6
strip [Ravi] length 4
```

`trim  [ Ravi ]` still has an em-space (U+2003, written `\u2003` in Java source) on each side: `trim` is from 1995 and only removes
characters up to a plain space. **Use `strip`.**

### java Printf.java

One format string, a table that lines up. `%-10s` = left-align in 10 columns; `%8d` = right-align a number
in 8. The last two lines are the same text built with `String.format(...)` and with `"...".formatted(...)`.

```console
$ java -Duser.language=en -Duser.country=US Printf.java
NAME       TYPE          BILL
Ravi       VEG           7200
Meera      NON_VEG       4500
Sunil      VEG           3600
Priya      VEG           7200
TOTAL                   22500
[Ravi           7200]
[Ravi           7200]
```

### java Conversions.java

The conversions you will actually type — and the honest locale line.

```console
$ java -Duser.language=en -Duser.country=US Conversions.java
locale: en_US
23.33
2,082,000
00042
+240
Ravi owes 7200 rupees (32.0% of revenue)
true M ff
100% delivered
```

Same program, same JDK, German machine — `%,d` and `%.2f` change, `%05d`/`%+d`/`%x` do not:

```console
$ java -Duser.language=de -Duser.country=DE Conversions.java
locale: de_DE
23,33
2.082.000
00042
+240
Ravi owes 7200 rupees (32,0% of revenue)
true M ff
100% delivered
```

### java BreakFormat.java — **supposed to fail**

`%d` handed a `double`. Read the message, then look at what is **already on the screen**.

```console
$ java BreakFormat.java
Ravi owes Exception in thread "main" java.util.IllegalFormatConversionException: d != java.lang.Double
	at java.base/java.util.Formatter$FormatSpecifier.failConversion(Formatter.java:4662)
	at java.base/java.util.Formatter$FormatSpecifier.printInteger(Formatter.java:3200)
	at java.base/java.util.Formatter$FormatSpecifier.print(Formatter.java:3155)
	at java.base/java.util.Formatter.format(Formatter.java:2761)
	at java.base/java.io.PrintStream.format(PrintStream.java:1183)
	at java.base/java.io.PrintStream.printf(PrintStream.java:1081)
	at BreakFormat.main(BreakFormat.java:3)
```

`Ravi owes ` printed before the crash — `printf` writes as it formats. Proof, with the error stream thrown
away (octal `0000012` = 10 bytes, and no newline):

```console
$ java BreakFormat.java 2>/dev/null | od -c
0000000    R   a   v   i       o   w   e   s                            
0000012
```

Fix: `%.0f`, or `Math.round` first and decide the rounding yourself. `%d` never rounds for you.

### java BreakCharAt.java — **supposed to fail**

Unit 11's off-by-one, on text instead of an array. Ten `java.base` frames on top, **your file on the last
line** — that last line is the one to read.

```console
$ java BreakCharAt.java
Exception in thread "main" java.lang.StringIndexOutOfBoundsException: Index 20 out of bounds for length 5
	at java.base/jdk.internal.util.Preconditions$1.apply(Preconditions.java:55)
	at java.base/jdk.internal.util.Preconditions$1.apply(Preconditions.java:52)
	at java.base/jdk.internal.util.Preconditions$4.apply(Preconditions.java:213)
	at java.base/jdk.internal.util.Preconditions$4.apply(Preconditions.java:210)
	at java.base/jdk.internal.util.Preconditions.outOfBounds(Preconditions.java:98)
	at java.base/jdk.internal.util.Preconditions.outOfBoundsCheckIndex(Preconditions.java:106)
	at java.base/jdk.internal.util.Preconditions.checkIndex(Preconditions.java:302)
	at java.base/java.lang.String.checkIndex(String.java:4904)
	at java.base/java.lang.StringLatin1.charAt(StringLatin1.java:45)
	at java.base/java.lang.String.charAt(String.java:1624)
	at BreakCharAt.main(BreakCharAt.java:3)
```

### java Emoji.java

`length()` counts storage slots, not letters you can see — and `%n` versus `\n`, settled with a byte count.

```console
$ java Emoji.java
Meera 🍛
length()        : 8
codePointCount(): 7
%n bytes: 10 [82, 97, 118, 105, 10, 77, 101, 101, 114, 97]
\n bytes: 10 [82, 97, 118, 105, 10, 77, 101, 101, 114, 97]
```

Force the platform's line ending to the Windows one and only `%n` changes — eleven bytes, `13, 10`:

```console
$ java -Dline.separator=$'\r\n' Emoji.java
%n bytes: 11 [82, 97, 118, 105, 13, 10, 77, 101, 101, 114, 97]
\n bytes: 10 [82, 97, 118, 105, 10, 77, 101, 101, 114, 97]
```

(That run's own lines end `\r\n` as well — `IO.println` uses the same separator — so the two lines
above are shown with their carriage returns stripped. Everything inside the brackets is verbatim.)

---

## Exercise 42 — "Clean the Sign-up Form"

**Start at `exercise/SignUpFormStarter.java`** — it compiles and runs unedited, with three `// TODO`
stubs. Full task, acceptance output and traps: **`exercise/README.md`**.

Four names and four phone numbers arrive from Asha's web form, all typed by humans. Fill in three methods;
the table and the join are already written:

- `String tidyName(String typed)` — turn what a human typed into a name Asha can print, and return
  `Guest` when they typed **nothing useful**.
- `boolean validPhone(String typed)` — `true` only for a **real ten-digit phone number**.
- `int countVowels(String text)` — a, e, i, o, u, either case.

The arrays are already in the starter:

```java
String[] typedNames  = {"  meera ", "RAVI", "  ", "priya"};
String[] typedPhones = {"9876543210", "98765 43210", "98765x4321", "0123456789"};
```

**The three traps this exercise is built on** — each is a plausible first attempt that passes three rows
and fails the fourth: `"  ".isEmpty()` is `false`, so only `isBlank` catches row 3; `"98765 43210"` has ten
*digits* and eleven *characters*, so counting digits lets it through; `"98765x4321"` has ten *characters*
and an `x` in the middle, so counting characters lets **it** through. You need both halves.

**Acceptance (byte-identical over three runs) — run your own file, not the solution:**

```console
$ cd exercise
$ java SignUpFormStarter.java
NAME     PHONE          OK     VOWELS
--------------------------------------
Meera    9876543210     true   3
Ravi     98765 43210    false  2
Guest    98765x4321     false  2
Priya    0123456789     true   2
All names: Meera, Ravi, Guest, Priya
```

Worked solution: `exercise/SignUpForm.java` — same output, run it afterwards to compare.

---

## Every command in this unit

```console
$ java Chars.java
$ java TextToolkit.java
$ java -Duser.language=en -Duser.country=US Printf.java
$ java -Duser.language=en -Duser.country=US Conversions.java
$ java -Duser.language=de -Duser.country=DE Conversions.java
$ java BreakFormat.java                      # supposed to fail
$ java BreakCharAt.java                      # supposed to fail
$ java Emoji.java
$ java -Dline.separator=$'\r\n' Emoji.java
$ cd exercise && java SignUpFormStarter.java    # your answer
$ cd exercise && java SignUpForm.java           # the worked solution
```

Every capture in this file was taken from these exact files on JDK 25.0.4.1 and reproduced
byte-identically three times in a row.
