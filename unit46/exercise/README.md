# Exercise 46 — "Unstick Yourself"

**Edit `DayReportStarter.java`** — an exact copy of `DayReportBroken.java`, so the broken original stays
intact for re-reading. It compiles and runs as it stands: two lines, then a crash. That is the starting line.
**Do not open `DayReport.java` or `question.md` until you have finished steps 1-4.** They are the worked
solution. The point of this exercise is the four minutes before the answer, not the answer.

The program is supposed to print how many meals Asha must cook today. It does not. There are **two** bugs
in it and **only one of them crashes**.

Run it from this folder:

```console
$ java DayReportStarter.java
Meera: 1
Sunil: 1
Exception in thread "main" java.lang.NullPointerException: Cannot invoke "java.lang.Integer.intValue()" because the return value of "java.util.HashMap.get(Object)" is null
	at DayReportStarter.main(DayReportStarter.java:21)
```

(`DayReportBroken.java` prints the same thing with its own name and line 11 — the starter carries a
comment header, so the same statement sits further down the file.)

## Step 1 — read the trace

Write down, in your own words, on paper or in a comment:

- what **line one** of the trace says (the *what*),
- which line of **your own file** line two points at (the *where*) — open that line before anything else.

There are no `java.base` frames in this trace at all, so every line in it is yours.

## Step 2 — shrink it

Cut the program down to **three lines inside `main`** that still throw the same exception.
Delete, do not explain. Call the file `Repro46.java`.

Target:

```console
$ java Repro46.java
Exception in thread "main" java.lang.NullPointerException: Cannot invoke "java.lang.Integer.intValue()" because the return value of "java.util.HashMap.get(Object)" is null
	at Repro46.main(Repro46.java:3)
```

## Step 3 — fix both bugs, and say so on the report

Fix the crash **and** the silent one — **and** add a `(not subscribed today)` note, after two spaces, for
anyone who is not in the map. Asha wants the report to say why a customer shows `0`, not leave her
guessing. That is three edits, not two: the two bugs, then the note.

Acceptance criterion — this exact output, byte-identical over three runs:

```console
$ java DayReportStarter.java
Ravi: 2
Meera: 1
Sunil: 1
Priya: 0  (not subscribed today)
Meals to cook today: 4
```

Note the first line. If `Ravi` is missing from your output, the silent bug is still there.
Note also the **two** spaces before `(not subscribed today)`, and that it appears on Priya's line only —
a customer who *is* in the map with `0` meals would not get it, so `containsKey` and not `meals == 0` is
what the note has to ask.

Run `java DayReport.java` afterwards to compare: same output, its own file name.

## Step 4 — write the question you would have posted

Fill in `question-template.md` (copy it to `question.md` of your own, somewhere else) with all five parts
from slide 5:

1. a title that names the exception and where it happened,
2. the three-line reproduction from step 2, **as text**, not a screenshot,
3. the **exact** error message, pasted whole,
4. `java -version` output,
5. one sentence of *I expected X, I got Y, I have tried Z*.

**Do not post it.** By the time you have written part 2 you will usually have the answer —
that is what this step is for.

## Files

| File | What it is |
|---|---|
| `DayReportStarter.java` | **start here** — the file you edit · compiles, runs, crashes |
| `DayReportBroken.java` | the pristine original, for re-reading the trace |
| `question-template.md` | the five empty headings for step 4 |
| `Repro46.java` | worked step 2 — the three-line reproduction — open it last |
| `DayReport.java` | worked step 3 — both bugs fixed **and** the note — open it last |
| `question.md` | worked step 4 — the question, written but not posted — open it last |

Verified on JDK 25.0.4.1.
