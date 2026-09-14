# Exercise 44 — "Document the Pause"

**Start at `starter/`.** `starter/src/com/tiffinbox/Pause.java` and `starter/PauseDemo.java` compile and run
as they stand — the methods return the wrong answers, the class carries no doc comments, and `javadoc`
prints **5 warnings**. Driving those five to zero is the exercise.
**`src/com/tiffinbox/Pause.java` and `PauseDemo.java` in this folder are the worked solution — open them last.**

---

## The task

Asha needs to record a stretch of days a customer skipped.

Write `src/com/tiffinbox/Pause.java` — an ordinary `public class Pause` in package `com.tiffinbox` — with:

1. `public static final int MAX_DAYS = 14;` — the longest pause Asha allows in one month.
2. A constructor `Pause(String customer, int from, int to)` that **validates**:
   * `to` before `from` → throw `IllegalArgumentException` with the message
     `pause ends before it starts: 20 to 14` (the two numbers are `from` then `to`);
   * a pause longer than `MAX_DAYS` days → throw `IllegalArgumentException` too.
3. `public int days()` — **both ends count**, so day 14 to day 20 is **7** days, not 6.
4. `public String describe()` — one line for Asha's report.

Then document **every public member** so that

```console
javadoc -d docs src/com/tiffinbox/Pause.java
```

reports **zero warnings**. Use `{@value #MAX_DAYS}` inside the constructor's `@throws` text so the number
cannot go stale, and `@see #days()` on `describe()`.

Then finish `PauseDemo.java` — a compact source file, five statements — that proves the `@throws` tag is
true: build a pause for **Ravi** from day 14 to day 20, print it, print its length, print the answer to the
docs question below, and then build an impossible pause inside a `try`/`catch` and print the caught message.

**Answer this from the documentation, not from the video:** `Math.abs(int)` hands back the absolute value of
an `int`. What does it hand back for `Integer.MIN_VALUE`, the most negative `int` there is? The answer is in
that method's own description — the paragraph *under* the first two lines, the part people skip (⌘B on
`abs` in IntelliJ, or `lib/src.zip`, or the JDK API page). Then prove it in the demo's third line. Unit 41
showed you `int` overflowing in silence; this is the same thing, inside a JDK method, documented.

---

## Acceptance — all three must hold

**1. The demo prints exactly this** (byte-identical over three runs):

```console
$ cd unit44/exercise/starter
$ javac -d out src/com/tiffinbox/Pause.java
$ java -cp out PauseDemo.java
Ravi paused 7 days (14 to 20)
Days: 7
Math.abs(Integer.MIN_VALUE): -2147483648
Caught, exactly as the Javadoc promised: pause ends before it starts: 20 to 14
```

Before you touch anything, the starter prints the stubs' answers — **three** lines, not four:

```console
$ javac -d out src/com/tiffinbox/Pause.java
$ java -cp out PauseDemo.java
?
Days: 0
Math.abs(Integer.MIN_VALUE): 0
```

The fourth line is missing because the stub constructor validates nothing, so the impossible pause is
accepted and the `catch` never fires. That missing line is TODO 2's acceptance test.

**2. `javadoc` says nothing.** The starter prints **5 warnings** (`no comment`, five times — one per
public member plus the class). You are finished when there are none: no warnings, no errors, just the
progress lines:

```console
$ rm -rf docs && javadoc -d docs src/com/tiffinbox/Pause.java
Loading source file src/com/tiffinbox/Pause.java...
Constructing Javadoc information...
Creating destination directory: "docs/"
Building index for all the packages and classes...
Standard Doclet version 25.0.4.1
Building tree for all the packages and classes...
Generating docs/com/tiffinbox/Pause.html...
Generating docs/com/tiffinbox/package-summary.html...
Generating docs/com/tiffinbox/package-tree.html...
Generating docs/constant-values.html...
Generating docs/overview-tree.html...
Generating docs/allclasses-index.html...
Building index for all classes...
Generating docs/allpackages-index.html...
Generating docs/index-all.html...
Generating docs/search.html...
Generating docs/index.html...
Generating docs/help-doc.html...
```

Byte-identical over three runs (with `docs/` removed first — the `Creating destination directory:` line
appears only when the folder is not already there).

**3. The site is 61 files:**

```console
$ find docs -type f | wc -l
      61
```

Open `docs/com/tiffinbox/Pause.html` and check that `{@value #MAX_DAYS}` came out as the literal `14`.

---

## Where people lose the warnings

* **`use of default constructor, which does not provide a comment`** — you wrote a class with no constructor
  at all, so `javadoc` documents the invisible one Java gave you. Write the constructor, and document it.
* **`no @param for customer`** — one `@param` tag per parameter, spelled exactly as the parameter is spelled.
* **`error: @param name not found`** — you spelled one wrong. A missing tag is a warning; a tag pointing at
  nothing is an error.
* A `private` field needs no doc comment. `javadoc` only documents `public` and `protected` members
  unless you ask it for more.

---

## Files

| file | what it is |
|---|---|
| `starter/src/com/tiffinbox/Pause.java` | **start here** — compiles, four `// TODO` stubs, no doc comments |
| `starter/PauseDemo.java` | **start here** — runs, with `// TODO 5` for the docs question |
| `src/com/tiffinbox/Pause.java` | the worked solution — open it last |
| `PauseDemo.java` | the worked demo — open it last |

## The worked solution

* The class doc opens with one sentence ending in a full stop (the tool uses it as the summary), then a `<p>`
  paragraph that spends `{@value #MAX_DAYS}`, then `@since 1.0`.
* `MAX_DAYS` carries a one-line `/** … */`.
* The constructor carries three `@param` tags and one `@throws IllegalArgumentException` naming **both** rules.
* `days()` returns `to - from + 1` — Unit 32's "the end is excluded" lesson, repaid: here it is included.
* `describe()` carries `@return` and `@see #days()`.
* `PauseDemo.java` is a compact source file with one `import com.tiffinbox.Pause;` line — compact files import
  `java.base` for free, but `com.tiffinbox` is your package, not the JDK's, so that one import is needed.
* The docs answer: `Math.abs(Integer.MIN_VALUE)` is `-2147483648` — itself, still negative. The JDK's own
  words: *"if the argument is equal to the value of `Integer.MIN_VALUE` … the result is that same value,
  which is negative. In contrast, the `Math.absExact(int)` method throws an `ArithmeticException`."*
  Verified: `Math.absExact(Integer.MIN_VALUE)` throws
  `java.lang.ArithmeticException: Overflow to represent absolute value of Integer.MIN_VALUE`.

> 📌 Verified on JDK 25.0.4.1 · demo output and `javadoc` console output each byte-identical over three runs · zero warnings · 61 files.
