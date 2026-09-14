# Exercise 41 — "Asha's Safe Till"

**Start at `TillStarter.java`.** It compiles and runs as it stands — the two methods you have to write
just return `0`. Fill in the two `// TODO` methods; nothing else in the file needs to change.
**`Till.java` is the worked solution — open it last.**

## The task

Write two methods:

1. `long yearlyPaise(int kitchens, int rupeesPerMonth)` — the year's takings in **paise**. It must
   survive **1200 kitchens at 20,820 rupees a month**.
2. `int toPaise(double rupees)` — rupees to paise **without losing the paisa**. `4.35` must come out as
   `435`, not `434`.

`main` is already written for you, because it prints ten aligned lines and the alignment is not the
point of this exercise. It shows:

- the correct yearly paise, and the number the same expression gives when everything stays `int`;
- `4.35` converted the wrong way (`(int) (4.35 * 100)`) and the right way (`toPaise(4.35)`);
- Unit 06's skipped-days percentage `7 / (double) 30 * 100` three ways — raw, as `%.1f%%`, and rounded;
- three "meal of the day" picks from the seven-dish menu, using a `Random` **seeded with 2026** so your
  output matches this exactly.

## Run it

```console
$ cd unit41/exercise
$ java TillStarter.java
```

With the stubs still returning `0`, the first and fourth lines are wrong and everything else is already right:

```console
Yearly paise (int would break): 0
int would have given         : -83971072
4.35 rupees in paise, wrong  : 434
4.35 rupees in paise, right  : 0
Skipped, raw                 : 23.333333333333332
Skipped, for Asha            : 23.3%
Skipped, rounded to a whole  : 23
Meal of day 1            : lentil rice
Meal of day 2            : cottage cheese curry
Meal of day 3            : combo plate
```

## Acceptance — this exact output, byte-identical over three runs

```console
$ java TillStarter.java
Yearly paise (int would break): 29980800000
int would have given         : -83971072
4.35 rupees in paise, wrong  : 434
4.35 rupees in paise, right  : 435
Skipped, raw                 : 23.333333333333332
Skipped, for Asha            : 23.3%
Skipped, rounded to a whole  : 23
Meal of day 1            : lentil rice
Meal of day 2            : cottage cheese curry
Meal of day 3            : combo plate
```

Only two lines change: `29980800000` and `435`.

## The format strings, in full

`printf` is **Unit 42's** subject; slide 2 of this unit defines only the two pieces used here
(`%-10s` = a text slot *n* columns wide, pushed left · `%n` = end the line). `java.lang.IO` has no
`printf` at all, so **formatting** is the one job this course hands back to `System.out`. Here are the
exact calls the starter already contains, so nothing is guesswork:

```java
System.out.printf("%-29s: %d%n", "int would have given", kitchens * rupeesPerMonth * 100 * 12);
System.out.printf("%-29s: %s%n", "Skipped, raw", skipped);
System.out.printf("%-25s: %s%n", "Meal of day " + day, menu[picker.nextInt(menu.length)]);
```

**Leave the `%n` on.** Without it `printf` writes no line ending at all and the ten lines run into one
another — the first line would read `29980800000int would have given         : -83971072…`.

The first label is 30 characters (`Yearly paise (int would break)`), one wider than the `%-29s` slot, so
that one line is a plain `IO.println` with the colon typed in. Everything else lines up.

## The two traps this exercise is built on

- **The cast goes on the first operand, not on the result.** `(long) kitchens * rupeesPerMonth * 100 * 12`
  is right; `(long) (kitchens * rupeesPerMonth * 100 * 12)` has already overflowed before the cast runs,
  and hands you `-83971072` — the number printed on the line below, so you can see the wrong answer
  beside the right one.
- **Round first, cast second.** `(int) Math.round(rupees * 100)` gives `435`; `(int) (rupees * 100)`
  truncates `434.99999999999994` to `434` and loses a paisa on every single tiffin.

Both traps are reachable: the natural first attempt at each one lands in it.

## Files

| file | what it is |
|---|---|
| `TillStarter.java` | **start here** — compiles and runs, two `// TODO` stubs |
| `Till.java` | the worked solution — open it last |

Verified on JDK 25.0.4.1 · starter and solution both run unedited · solution output byte-identical over three runs.
