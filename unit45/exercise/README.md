# Exercise 45 — "Tidy Asha's Kitchen"

**Start at `KitchenStarter.java`.** It compiles and runs as it stands — the four shapes are stubbed, so it
prints the wrong answers. Fill in the four `// TODO`s. `main` is written for you; the only edit you make
there is uncommenting the two lines TODO 4 asks for.
**`Kitchen.java` is the worked solution — open it last.**

## The task

Asha's kitchen code has grown into a pile of loose classes. Tidy it into **one compact source file**,
using the four shapes from this unit. Print **nothing anywhere except `main`**.

1. **`interface Payable`** with two abstract methods, `String who()` and `int amountDue()`, plus
   - a **`static`** factory `Payable of(String who, int amount)` that returns an **anonymous**
     implementation (and then the `Placeholder` record at the bottom of the starter can go),
   - two **`default`** methods, `receipt()` and `reminder()`,
   - and **one `private`** method that both defaults share, so the two rows line up identically.
2. **`abstract class Meal`** with a `basePrice` a subclass in **another package** could still reach, and a
   `deliveryFee()` returning `20` that **nobody can override**.
3. **A `VeganMeal`** that nobody may extend. Its base price is `130`, and a vegan meal takes 10 off the
   total — `price()` must use **both** `basePrice` and `deliveryFee()`.
4. **A class `Receipt`** with a **private constructor** and a nested **`static class Builder`** that
   defaults to `Guest`, `0` and `-`, chains its setters, and calls the private constructor from `build()`.
   Then uncomment the two `Receipt` lines in `main`.

`main` then prints, in this order: Ravi's receipt for `7200` and Sunil's reminder for `8800`; the vegan
meal's price and its delivery fee; a built receipt for `Priya`, `7200`, note `paid by UPI`; a receipt built
from nothing at all; whether `VeganMeal` is final; and the runtime class name `Payable.of` hands back.

## Run it

```console
$ cd unit45/exercise
$ java KitchenStarter.java
?
?
Vegan meal price: 0 (delivery 0)
VeganMeal is final: false
Payable.of returns: KitchenStarter$Placeholder
```

Five lines, because TODO 4's two lines are still commented out.

## Acceptance — this exact output, byte-identical over three runs

```console
$ java KitchenStarter.java
DUE       Ravi       7200
REMINDER  Sunil      8800
Vegan meal price: 140 (delivery 20)
Priya | 7200 | paid by UPI
Guest | 0 | -
VeganMeal is final: true
Payable.of returns: KitchenStarter$Payable$1
```

The last line names the file you are running. The worked solution prints `Kitchen$Payable$1` for the same
reason; everything above it is identical. The `$Payable$1` half is the point — slide 4 showed you that an
anonymous class is numbered, not nameless.

## The trap this exercise exists for

Step 4 asks for "a class `Receipt`". It does **not** tell you which modifiers to write, because working
that out is the exercise. Your first version — `class Receipt` or `final class Receipt` — will not
compile, and this is the whole error, both times, measured:

```console
$ java KitchenStarter.java
KitchenStarter.java:49: error: non-static variable this cannot be referenced from a static context
        Receipt build()          { return new Receipt(this); }
                                          ^
1 error
error: compilation failed
```

That is slide 5, in your own file. In a compact source file every "top-level" class is an **inner** class
of the implicit class, so `new Receipt(...)` needs an enclosing instance — and the `static` `Builder` has
none to give it. The line number will be wherever your `build()` landed.

## If you are properly stuck

- The two rows `DUE       Ravi       7200` and `REMINDER  Sunil      8800` differ by one word. Count the
  columns in the expected output: that tells you the shape of the shared `private` method's format string.
- `140` is `130`, plus the delivery fee, minus the vegan discount. Work out which way round.
- Each `Builder` setter has to hand something back, or the calls cannot chain.
- `Modifier` needs no import in a compact source file — `main` already uses it.

## Files

| file | what it is |
|---|---|
| `KitchenStarter.java` | **start here** — compiles and runs, four `// TODO` stubs |
| `Kitchen.java` | the worked solution — open it last; the trap is explained at the bottom of that file |

Verified on JDK 25.0.4.1 · starter and solution both run unedited · solution output byte-identical over three runs.
