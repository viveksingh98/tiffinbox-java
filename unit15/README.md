# Unit 15 — Inheritance: Meal, VegMeal, NonVegMeal

**What this unit teaches:** Write the shared part once in a parent and let each child `extends` it, overriding only what differs.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit15`), in the order below.

### java Meals.java

The three-level tree with `super(...)` and two overrides.

```console
$ java Meals.java
lentil rice - 120
chicken curry - 150 (non-veg)
vegetable stew - 130 (no dairy, no eggs)
```

### java SilentBug.java — **supposed to be wrong**

> **This one is supposed to give the wrong answer — that is the lesson.** `prise()` instead of `price()` — without `@Override` it compiles as a brand-new method and the parent's price wins. Wrong answer, no error.

```console
$ java SilentBug.java
vegetable stew - 120 (no dairy, no eggs)
```

### java BreakOverride.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** the same typo *with* `@Override` — now the compiler catches it.

```console
$ java BreakOverride.java
BreakOverride.java:19: error: method does not override or implement a method from a supertype
    @Override int prise() { return 130; }
    ^
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).
