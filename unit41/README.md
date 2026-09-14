# Unit 41 — Numbers You Can Trust: Ranges, Overflow, Math and Random

**What this unit teaches:** why `int` goes negative without a word of warning, how big each numeric type really is, why a `double` cannot hold one tenth, the difference between truncating, `Math.round` and `Math.rint`, the `Math` toolbox, and `Random` with and without a seed.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1 (`openjdk version "25.0.4.1" 2026-08-18`, `javac 25.0.4.1`).

Run everything from this folder (`cd unit41`), in the order below. Every block below is a real capture, and every fixed capture was run three times with identical bytes.

> `java.lang.IO` has `println`, `print` and `readln` — and **no `printf`**. Wherever a column has to line up, these files use `System.out.printf`.

### java Overflow.java

Asha's twelve-hundred-kitchen dream. One multiplication, and the total is negative.

```console
$ java Overflow.java
int max:  2147483647
int min:  -2147483648
one more: -2147483648
int  total paise: -1796567296
long total paise: 2498400000
cast too late   : -1796567296
long max: 9223372036854775807
with the L suffix: 3000000000
```

`cast too late` is `(long) (paisePerKitchen * kitchens)` — the multiply already happened in `int`, so the cast preserves the wrong answer. `(long) paisePerKitchen * kitchens` casts the **first operand**, so the multiply itself happens in `long`.

### java Ranges.java

The ranges printed rather than quoted, straight out of `Byte.SIZE` / `Byte.MIN_VALUE` and friends.

```console
$ java Ranges.java
TYPE     BITS                     MIN  MAX
byte       8                    -128  127
short     16                  -32768  32767
int       32             -2147483648  2147483647
long      64    -9223372036854775808  9223372036854775807
float     32                 1.4E-45  3.4028235E38
double    64                4.9E-324  1.7976931348623157E308
char      16                       0  65535
boolean: 1 bit of meaning, true or false
```

`Float.MIN_VALUE` and `Double.MIN_VALUE` are the smallest **positive** values, not the most negative ones — that is what the JDK constants mean for floating point.

### java BreakLiteral.java — breaks on purpose

```console
$ java BreakLiteral.java
BreakLiteral.java:2: error: integer number too large
    long big = 3000000000;
               ^
1 error
error: compilation failed
```

Fix: `long big = 3_000_000_000L;` — the literal is an `int` before it is ever assigned, so the `L` has to be on the literal.

### java Doubles.java

```console
$ java Doubles.java
0.1 + 0.2         = 0.30000000000000004
0.1 + 0.2 == 0.3  ? false
what Java stores  : 0.3000000000000000444089209850062616169452667236328125
4.35 * 100        = 434.99999999999994
(int)(4.35 * 100) = 434
0.05 sixty times  = 2.9999999999999973
rounded for the bill: 0.30
1.0 / 0.0         = Infinity
0.0 / 0.0         = NaN
```

Line 3 is `new BigDecimal(0.1 + 0.2)` — the exact value the `double` is holding. No import is needed: a compact source file sees the whole `java.base` module.

### java Rounding.java

```console
$ java Rounding.java
(int) 2.99   = 2
(int) 2.01   = 2
(int) -2.99  = -2
Math.floor(-2.99) = -3.0
Math.round(2.99) = 3
Math.round(2.5)  = 3
Math.round(3.5)  = 4
Math.round(-2.5) = -2
Math.rint(2.5)   = 2.0
Math.rint(3.5)   = 4.0
Math.rint(-2.5)  = -2.0
Math.ceil(2.01)  = 3.0
Math.floor(2.99) = 2.0
widening, free: 840.0
(int) 3_000_000_000L = -1294967296
```

Three facts: a cast to `int` **truncates towards zero** (so it disagrees with `Math.floor` on negatives); `Math.round` is **half-up towards positive infinity** (`-2.5` → `-2`) while `Math.rint` is **half-to-even** (`2.5` → `2.0`); and a narrowing cast that does not fit produces garbage with no warning at all.

### java MathTools.java

```console
$ java MathTools.java
Math.abs(-240)        = 240
Math.max(7200, 4500)  = 7200
Math.min(7200, 4500)  = 4500
Math.round(23.333)    = 23
Math.ceil(6.2)        = 7.0
Math.floor(6.9)       = 6.0
Math.pow(1.1, 12)     = 3.138428376721003
Math.sqrt(2025)       = 45.0
Math.PI               = 3.141592653589793
bags for 31 tiffins   = 7
multiplyExact throws  : integer overflow
```

`bags` is `(int) Math.ceil(31 / 5.0)` — `Math.ceil` hands back a `double`, so storing it in an `int` needs this unit's cast rules. `Math.multiplyExact(2_082_000, 1200)` is the same multiplication as `Overflow.java`, except it throws `ArithmeticException: integer overflow` instead of quietly returning a wrong number.

### java SeededRandom.java

Byte-identical over three runs, and on any machine, because the seed is fixed.

```console
$ java SeededRandom.java
Day 1: bean curry
Day 2: spiced rice
Day 3: combo plate
Day 4: vegetable stew
Day 5: spiced rice
Dice: 3
```

`Dice` is `new Random(42).nextInt(1, 7)` — the two-argument form: lower bound included, upper bound excluded.

### java Unseeded.java — DIFFERS EVERY RUN

No seed, so Java picks one. **This output is different every single time** — do not expect to match it.

```console
$ java Unseeded.java          # run 1
Day 1: spiced rice
Day 2: lentil rice
Day 3: vegetable stew
Math.random(): 0.7024494062395427
Dice roll:     6

$ java Unseeded.java          # run 2
Day 1: chickpea curry
Day 2: spiced rice
Day 3: lentil rice
Math.random(): 0.7152403263857938
Dice roll:     3
```

(Runs 3, 4 and 5 gave `0.3634533613002655`, `0.7447414835281286` and `0.06225608289856244`.) Seed it when you are teaching or testing. Never seed it for anything that has to be unguessable — that job wants `SecureRandom`.

---

## Exercise — "Asha's Safe Till"

The task, the expected output and the worked solution are in [`exercise/`](exercise/). Read `exercise/README.md`, write your own `Till.java` somewhere else, and only then open `exercise/Till.java`.

```console
$ cd exercise && java Till.java
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
