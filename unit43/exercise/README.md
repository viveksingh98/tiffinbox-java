# Exercise 43 — "Sign Priya Up, Both Ways"

**Start at `SignUpStarter.java`.** It compiles and runs as it stands — every invocation prints the usage
line, because the three `// TODO` methods are empty. Fill them in.
**`SignUp.java` is the worked solution — open it last.** Its design notes are in a comment at the bottom
of that file, not here, so nothing above spoils the four minutes of thinking that are the point.

## The task

Write **one** program with two ways in:

- with **three** arguments it registers straight away;
- with **no** arguments it asks three questions;
- with any other count it prints a usage line.

It must reject a non-number, reject meals outside 1 to 3, and survive the input being closed.
**No `nextInt()` anywhere** — Unit 43 slide 2 showed you why.

Asha's arithmetic: the monthly bill is `mealsPerDay × pricePerMeal × 30`.

## Acceptance — all six runs, each byte-identical over three runs

```console
$ cd unit43/exercise
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

The usage line names the file you are running, so the worked solution prints `java SignUp.java` on that
last line instead. Every other line is identical between the two.

## The three traps this exercise is built on

1. **Run 3 prints ONE prompt, not three.** That is the acceptance test for closed input. If `ask` prints
   its prompt and then reads without checking there is anything to read, you get an exception; if it
   checks but the caller ignores the answer, you print all three prompts into a void and save nothing.
2. **Run 2 has no line breaks between the prompts.** `Customer name: Meals per day (1-3): Price per
   meal: Welcome…` is one line. A prompt that ends with a line break will not match.
3. **Run 4's message comes from the exception, not from you.** `For input string: "two"` is what Java
   put in the message — print the exception's own text after your prefix rather than inventing one.

## Files

| file | what it is |
|---|---|
| `SignUpStarter.java` | **start here** — compiles and runs, three `// TODO` stubs |
| `SignUp.java` | the worked solution — open it last; its design notes are at the bottom of the file |

Verified on JDK 25.0.4.1 · starter and solution both run unedited · all six runs byte-identical over three runs.
