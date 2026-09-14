# Exercise 42 — "Clean the Sign-up Form"

**Start at `SignUpFormStarter.java`.** It compiles and runs as it stands — the three methods you have to
write just return placeholders. Fill in the three `// TODO` methods; the table and the join are already
written, because `printf` alignment is not what this exercise is testing.
**`SignUpForm.java` is the worked solution — open it last.**

## The task

Four names and four phone numbers arrive from Asha's web form, all typed by humans:

```java
String[] typedNames  = {"  meera ", "RAVI", "  ", "priya"};
String[] typedPhones = {"9876543210", "98765 43210", "98765x4321", "0123456789"};
```

Write three methods:

- `String tidyName(String typed)` — turn what a human typed into a name Asha can print, and return
  `Guest` when they typed **nothing useful**.
- `boolean validPhone(String typed)` — `true` only for a **real ten-digit phone number**.
- `int countVowels(String text)` — a, e, i, o, u, either case.

The task deliberately does **not** spell out the two checks. Working out what "nothing useful" and
"a real ten-digit phone number" have to mean *is* the exercise — see the traps below.

## Run it

```console
$ cd unit42/exercise
$ java SignUpFormStarter.java
NAME     PHONE          OK     VOWELS
--------------------------------------
?        9876543210     false  0
?        98765 43210    false  0
?        98765x4321     false  0
?        0123456789     false  0
All names: ?, ?, ?, ?
```

## Acceptance — this exact output, byte-identical over three runs

```console
$ java SignUpFormStarter.java
NAME     PHONE          OK     VOWELS
--------------------------------------
Meera    9876543210     true   3
Ravi     98765 43210    false  2
Guest    98765x4321     false  2
Priya    0123456789     true   2
All names: Meera, Ravi, Guest, Priya
```

Run the worked solution the same way when you are done: `java SignUpForm.java`. Do not use it as your
acceptance test before you have written your own — that is just running the answer.

## The three traps this exercise is built on

Each one is a plausible first attempt that passes three of the four rows and fails the fourth.

1. **`"  "` is not empty.** `"  ".isEmpty()` is `false` — the string has two characters in it. Only
   `isBlank()` (or stripping first, then `isEmpty`) catches whitespace-only input. Guess wrong and row 3
   prints a blank name instead of `Guest`.
2. **Counting digits is not enough.** `"98765 43210"` has exactly ten digits — and **eleven characters**.
   A `validPhone` that counts digits and stops lets that row through as `true`.
3. **Counting characters is not enough.** `"98765x4321"` has exactly ten characters — and one of them is
   an `x`. A `validPhone` that checks `length() == 10` and stops lets *that* row through as `true`.

You need both halves of check 2 and 3 — the length **and** every character. That is the whole exercise.

## Files

| file | what it is |
|---|---|
| `SignUpFormStarter.java` | **start here** — compiles and runs, three `// TODO` stubs |
| `SignUpForm.java` | the worked solution — open it last |

Verified on JDK 25.0.4.1 · starter and solution both run unedited · solution output byte-identical over three runs.
