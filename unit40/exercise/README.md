# Exercise 40 — "The Party Box"

**Start at `PartyBoxStarter.java`.** It compiles and runs as it stands — it just prints the wrong
answers. Fill in the four `// TODO` methods; nothing else in the file needs to change.
**`PartyBox.java` is the worked solution — open it last.**

## The task

Asha sells a party box. A party box holds plates; a plate holds meals. That is slide 1's `Item` record,
already in the starter:

```java
record Item(String name, int price, List<Item> parts) { }
```

Write four methods:

| method | shape | rule |
|---|---|---|
| `int countMeals(Item item)` | recursive | how many actual meals are in here, at any depth |
| `int depth(Item item)` | recursive | how many layers of box · a bare meal is **1** |
| `int cheapest(int... prices)` | varargs | the smallest price · **0** when no prices are handed in |
| `String busiestDay(int[][] week, String[] days)` | nested loop | the day with the most meals, both types added together |

Use the three questions from slide 3 on the two recursive ones: what is the smallest input and what is
its answer, how do I hand on something smaller, how do I combine what comes back.

## Run it

```console
$ cd unit40/exercise
$ java PartyBoxStarter.java
```

Before you write anything, the starter prints the stubs' answers:

```console
Meals in the box: 0
Nesting depth   : 0
Cheapest of 120, 60, 90: 0
Cheapest of nothing    : 0
Busiest day     : ?
Grid            : [[40, 12], [38, 10], [42, 14], [41, 9], [45, 18], [52, 22], [30, 6]]
```

## Acceptance — this exact output, byte-identical over three runs

```console
$ java PartyBoxStarter.java
Meals in the box: 3
Nesting depth   : 3
Cheapest of 120, 60, 90: 60
Cheapest of nothing    : 0
Busiest day     : Sat (74 meals)
Grid            : [[40, 12], [38, 10], [42, 14], [41, 9], [45, 18], [52, 22], [30, 6]]
```

`Sat` is `52 + 22 = 74`, the highest of the seven day totals. `Nesting depth   : 3` is party box → plate →
meal. Mind the column padding: the labels are printed exactly as the starter already prints them.

## The three traps this exercise is built on

1. **`countMeals` returns `1` on the base case, not the price.** Counting is not totalling — if your
   answer is `270` you copied `totalOf`.
2. **`depth` is the *deepest* child plus one, not the sum of the children.** A party box holding a plate
   holding a meal is 3 layers, not 4. `Math` is the *next* unit, so write the comparison yourself:
   keep a `deepest` variable and `if (d > deepest) deepest = d;`.
3. **`cheapest()` with no arguments must return `0`.** Guard `prices.length == 0` *before* you touch
   `prices[0]`, or Unit 11's `ArrayIndexOutOfBoundsException` is waiting for you. That guard is the whole
   reason varargs needs one: "however many" includes **none**.

## Files

| file | what it is |
|---|---|
| `PartyBoxStarter.java` | **start here** — compiles and runs, four `// TODO` stubs |
| `PartyBox.java` | the worked solution — open it last |

Verified on JDK 25.0.4.1 · starter and solution both run unedited · solution output byte-identical over three runs.
