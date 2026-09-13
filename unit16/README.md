# Unit 16 — Polymorphism: One Call, Many Behaviours

**What this unit teaches:** One call, many behaviours: the real object decides which `price()` runs, and the reference type decides what you may call.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit16`), in the order below.

### java Polymorphism.java

One loop over `List<Meal>` running three different `price()` methods.

```console
$ java Polymorphism.java
lentil rice - 120
chicken curry - 150 (non-veg)
vegetable stew - 130 (no dairy, no eggs)
Total: 400
130
```

### java BreakUpcast.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** a `Meal` reference cannot see a child-only method.

```console
$ java BreakUpcast.java
BreakUpcast.java:3: error: cannot find symbol
    IO.println(special.kitchenNote());
                      ^
  symbol:   method kitchenNote()
  location: variable special of type BreakUpcast.Meal
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).

### java FixUpcast.java

The fix: `instanceof` with a pattern variable.

```console
$ java FixUpcast.java
Vegan: no dairy, no eggs
```
