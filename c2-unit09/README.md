# c2-unit09 — Wildcards: `? extends`, `? super` and PECS

What it teaches: `List<VegMeal>` is **not** a `List<Meal>`, and the two wildcards that give you back the flexibility you expected — Producer Extends, Consumer Super.

Verified on JDK 25.0.4.1 (`export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH=$JAVA_HOME/bin:$PATH`).

The working demo:

```bash
java Wildcards.java
```
```
veg only total: 220
mixed total:    410
ledger:  [7200, 4500, 9000, 3600]
numbers: [7200, 4500, 9000, 3600]
howMany(vegOnly): 2, howMany(ledger): 4
```
(identical on 3 runs, md5 `86db8bc…`)

## Files that fail on purpose

| Command | Real error |
|---|---|
| `javac -d out Invariant.java` | `Invariant.java:10: error: incompatible types: List<VegMeal> cannot be converted to List<Meal>` / `1 error` |
| `javac -Xdiags:verbose -d out AddToExtends.java` | `AddToExtends.java:9: error: no suitable method found for add(VegMeal)` with `CAP#1 extends Meal from capture of ? extends Meal`. Plain `javac` simplifies it to `incompatible types: VegMeal cannot be converted to CAP#1` — use `-Xdiags:verbose` to see the capture. |
| `javac -d out NoWild.java` | `NoWild.java:13: error: incompatible types: List<Object> cannot be converted to List<Integer>` / `1 error` |

`NoWild.java` is the Slide 4 claim as a file you can compile: the same `copyBills` with the
wildcards taken out. `List<Integer>` then means `List<Integer>` and nothing else — the
`List<Object>` ledger no longer fits, even though it can hold every `Integer` produced.
That is the measurement behind "the wildcards are not decoration".

## The array contrast — compiles, then fails at run time

```bash
javac -d out ArrayStore.java
java -cp out ArrayStore
```
```
Exception in thread "main" java.lang.ArrayStoreException: ArrayStore$NonVegMeal
	at ArrayStore.main(ArrayStore.java:9)
```
Arrays are covariant, so the compiler lets this through and the JVM catches it at run time;
generics are invariant, so `Invariant.java` never gets that far. The `$` in the message is a
nested class (Unit 06's naming again) — the three error files keep the `Meal` hierarchy nested
so the line numbers stay clean; `Wildcards.java` is a compact source file.

Check everything in this folder at once: `../verify_course2.sh 09`
