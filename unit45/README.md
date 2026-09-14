# Unit 45 — The Keywords We Skipped: protected, final, static Interface Methods, Nested Classes

**What this unit teaches:** the fourth access door (`protected`) proved across two real packages, what `final` does to classes and methods, `static` and `private` methods on interfaces, and the difference between a static nested class and an inner class — with `javap` showing the `final Customer this$0` field the compiler writes for you.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1 (`javac 25.0.4.1`, `/opt/homebrew/opt/openjdk@25`). Every command below was run **three times**; all output is byte-identical across the three runs.

**Why this unit has two shapes.** Slides 1 and 2 leave the compact-file form on purpose: `protected` only differs from package-private *across packages*, and a compact source file has no package. Those two slides use a real `src/com/tiffinbox/...` tree compiled with `javac -d out`. Everything else is a compact file run with `java File.java`, exactly as Units 03-44.

Run the compact files from this folder (`cd unit45`). Run the package commands from `unit45/packages` and `unit45/break-package-private`, as marked.

---

## Part 1 — `protected` proved with two packages

### javac -d out … && java -cp out com.tiffinbox.app.Main

Run from `unit45/packages`. `Meal` lives in `com.tiffinbox.menu`; `VeganMeal` extends it from `com.tiffinbox.special` — a **different package** — and still reads `protected int basePrice`.

```console
$ cd packages
$ javac -d out src/com/tiffinbox/menu/Meal.java src/com/tiffinbox/special/VeganMeal.java src/com/tiffinbox/app/Main.java
$ java -cp out com.tiffinbox.app.Main
Meal      120
VeganMeal 130
dish      lentil rice
```

### javac … Peek.java — **supposed to fail** (the subtle `protected` rule)

> **This one is supposed to fail — that is the lesson.** A subclass in another package may read `protected` **through itself**, not through a reference of the parent type. In `Peek.java`, line 6 (`return basePrice;`) compiles; line 7 (`return other.basePrice;`) does not.

```console
$ javac -d out src/com/tiffinbox/menu/Meal.java src/com/tiffinbox/special/VeganMeal.java src/com/tiffinbox/special/Peek.java
src/com/tiffinbox/special/Peek.java:7: error: basePrice has protected access in Meal
    public int someoneElses(Meal other) { return other.basePrice; }
                                                      ^
1 error
```

Exit code: `1` (non-zero — the failure is the point).

### javac … Stock.java — **supposed to fail** (package-private from outside the package)

> **This one is supposed to fail — that is the lesson.** `Stock` is in `com.tiffinbox.app` and is not a subclass of anything. `packedToday` has no modifier at all, so it is package-private.

```console
$ javac -d out src/com/tiffinbox/menu/Meal.java src/com/tiffinbox/app/Stock.java
src/com/tiffinbox/app/Stock.java:6: error: packedToday is not public in Meal; cannot be accessed from outside package
    public int packedToday(Meal m) { return m.packedToday; }
                                             ^
1 error
```

Exit code: `1`.

### break-package-private — **supposed to fail** (take `protected` off and watch the subclass break)

> **This one is supposed to fail — that is the lesson.** Same two files as Part 1, one word removed: `basePrice` is package-private instead of `protected`. The subclass in the other package can no longer see it, and the message is a **third, different** one.

```console
$ cd ../break-package-private
$ javac -d out src/com/tiffinbox/menu/Meal.java src/com/tiffinbox/special/VeganMeal.java
src/com/tiffinbox/special/VeganMeal.java:7: error: basePrice is not public in Meal; cannot be accessed from outside package
    public int price() { return basePrice + 10; }
                                ^
1 error
```

Exit code: `1`. Three refusals, three different messages — that is slide 2.

---

## Part 2 — `final` (compact files, run from `unit45`)

### java FinalProof.java

`final` measured with reflection instead of asserted.

```console
$ java FinalProof.java
String        is final: true
Integer       is final: true
LocalDate     is final: true
java.lang.IO  is final: true
record Order  is final: true
Meal (ours)   is final: false
VeganMeal     is final: true
deliveryFee() is final: true
```

### java BreakFinalClass.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** `String` is a `final` class, so nothing can extend it. Note the message says `final String`, with **no package qualifier**.

```console
$ java BreakFinalClass.java
BreakFinalClass.java:1: error: cannot inherit from final String
class MyString extends String {
                       ^
1 error
error: compilation failed
```

Exit code: `1`.

### java BreakFinalMethod.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** A `final` method cannot be overridden. Read the second line of the error.

```console
$ java BreakFinalMethod.java
BreakFinalMethod.java:7: error: deliveryFee() in BreakFinalMethod.VeganMeal cannot override deliveryFee() in BreakFinalMethod.Meal
    @Override int deliveryFee() { return 0; }
                  ^
  overridden method is final
1 error
error: compilation failed
```

Exit code: `1`. The class names in that message — `BreakFinalMethod.VeganMeal` — carry a dot because in a compact source file both classes are nested inside the implicit class. Part 4 proves it.

### javap java.lang.IO

The class this whole course prints with is itself `final`, and it has five public methods.

```console
$ javap java.lang.IO
Compiled from "IO.java"
public final class java.lang.IO {
  public static void println(java.lang.Object);
  public static void println();
  public static void print(java.lang.Object);
  public static java.lang.String readln();
  public static java.lang.String readln(java.lang.String);
  static synchronized java.io.BufferedReader reader();
}
```

(The sixth line has no `public` on it — it is package-private plumbing, not part of the API. There is no `printf`; Unit 42 said why.)

---

## Part 3 — `static` and `private` methods on interfaces

### java Interfaces.java

```console
$ java Interfaces.java
DUE       Ravi       7200
REMINDER  Sunil      8800
Payable.of made a: Interfaces$Payable$1
```

Both table rows come from one `private` interface method that implementers never see. The third line is the name the compiler gave the anonymous class inside the `static` factory — anonymous classes are not nameless, they are numbered.

---

## Part 4 — static nested vs inner, with the proof

### javac -d out Customer.java && java -cp out Customer

`Customer.java` is a normal `public class` (not a compact file) so the class files land on disk and `javap` can read them.

```console
$ javac -d out Customer.java
$ java -cp out Customer
Priya x2
Receipt for Priya: 7200
Builder needs no Customer : Customer$Builder
Receipt is tied to one    : Customer$Receipt
```

### javap -p 'Customer$Builder' and javap -p 'Customer$Receipt' — the headline capture

```console
$ javap -p -cp out 'Customer$Builder'
Compiled from "Customer.java"
public class Customer$Builder {
  private java.lang.String name;
  private int mealsPerDay;
  public Customer$Builder();
  public Customer$Builder name(java.lang.String);
  public Customer$Builder mealsPerDay(int);
  public Customer build();
}

$ javap -p -cp out 'Customer$Receipt'
Compiled from "Customer.java"
public class Customer$Receipt {
  final Customer this$0;
  public Customer$Receipt(Customer);
  public java.lang.String print();
}
```

`final Customer this$0` is a field you did not write, and the constructor demands a `Customer`. That is how `print()` reads `name` with no dot in front of it — and it is why holding a `Receipt` keeps the whole `Customer` alive in memory.

### java -cp out BreakInner.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** An inner class cannot be created without an instance of its outer class. (`Customer` must already be compiled into `out/` by the command above.)

```console
$ java -cp out BreakInner.java
BreakInner.java:2: error: an enclosing instance that contains Customer.Receipt is required
    Customer.Receipt slip = new Customer.Receipt();
                            ^
1 error
error: compilation failed
```

Exit code: `1`. The working form is `priya.new Receipt()`, which is in `Customer.java`.

### java ImplicitNesting.java + javap — the `$` explained at last

```console
$ java ImplicitNesting.java
Plain  isStatic: false
Marked isStatic: true
Plain  name    : ImplicitNesting$Plain
Marked name    : ImplicitNesting$Marked
this file      : ImplicitNesting
```

```console
$ javac -d out ImplicitNesting.java
$ javap -p -cp out 'ImplicitNesting$Plain'
Compiled from "ImplicitNesting.java"
class ImplicitNesting$Plain {
  ImplicitNesting$Plain(ImplicitNesting);
}

$ javap -p -cp out 'ImplicitNesting$Marked'
Compiled from "ImplicitNesting.java"
class ImplicitNesting$Marked {
  ImplicitNesting$Marked();
}
```

A class written at the "top level" of a compact source file is an **inner class of the implicit class** — its constructor takes the implicit class as an argument. Write `static` in front and the constructor loses it. That is the `$` you have been reading since Unit 23 (`Identity$Customer@51b7e5df`) and Unit 25 (`Cause$TiffinBoxException`), and it is why this unit's exercise needs `static` in front of `Receipt`.

**Read that `javap` output carefully: there is no `this$0` field in it.** `Customer$Receipt` on the slide
before *does* carry `final Customer this$0`, and both captures are real. javac emits the hidden field only
when the inner class actually **uses** its outer object — `Receipt.print()` reads `name`, so it keeps one;
`Plain` is an empty class, so javac drops the field and keeps only the constructor parameter. The reliable
tell for "inner or static nested?" is therefore the **constructor**: an argument of the enclosing type means
inner, no argument means `static` nested.

---

## Part 5 — the anonymous class, rehabilitated

### java Anon.java

```console
$ java Anon.java
picked up Ravi (trip 1)
delivered to Ravi, 1 trips today
picked up Meera (trip 2)
delivered to Meera, 2 trips today
class name: Anon$1
```

Two methods and a field that remembers between calls. A lambda is one method and no memory, so a lambda cannot do this.

---

## The exercise

`exercise/` — read `exercise/README.md` and start at `exercise/KitchenStarter.java` (it compiles and runs
unedited, with four `// TODO` stubs). `exercise/Kitchen.java` is the worked solution; open it last.

The task deliberately does **not** tell you which modifiers `Receipt` needs — working that out from the
compiler's refusal is the exercise. Measured: **both** `class Receipt` and `final class Receipt` fail with
`error: non-static variable this cannot be referenced from a static context`.

```console
$ cd exercise && java Kitchen.java
DUE       Ravi       7200
REMINDER  Sunil      8800
Vegan meal price: 140 (delivery 20)
Priya | 7200 | paid by UPI
Guest | 0 | -
VeganMeal is final: true
Payable.of returns: Kitchen$Payable$1
```

---

## What is in this folder

- `packages/src/com/tiffinbox/menu/Meal.java` — four fields, four access levels.
- `packages/src/com/tiffinbox/special/VeganMeal.java` — subclass in **another** package, reads `protected basePrice`.
- `packages/src/com/tiffinbox/app/Main.java` — prints the three lines of slide 1.
- `packages/src/com/tiffinbox/special/Peek.java` — the `has protected access` failure (never compiled with the good build).
- `packages/src/com/tiffinbox/app/Stock.java` — the package-private failure (never compiled with the good build).
- `break-package-private/src/…` — the same `Meal` with `protected` removed; the third error message.
- `FinalProof.java` · `BreakFinalClass.java` · `BreakFinalMethod.java` — `final` on classes and methods.
- `Interfaces.java` — `static`, `default` and `private` interface methods.
- `Customer.java` · `BreakInner.java` — static nested `Builder` vs inner `Receipt`, plus the `javap` proof.
- `ImplicitNesting.java` — a compact file's "top-level" classes are inner classes.
- `Anon.java` — the one honest use of an anonymous class.
- `exercise/` — "Tidy Asha's Kitchen": `README.md`, the `KitchenStarter.java` you fill in, and `Kitchen.java`, the worked solution.

## Notes

- `out/` is git-ignored; `rm -rf out packages/out break-package-private/out` resets the unit.
- Quote the `$` names in the shell: `javap -p -cp out 'Customer$Receipt'`, otherwise the shell eats `$Receipt`.
- The `java.lang.reflect.Modifier`, `java.time.LocalDate` and `java.util` types used here need **no import** in a compact source file — it imports the whole `java.base` module. A normal `public class` does not get that (Unit 46).
