# Unit 08 — Making Decisions: if, else, switch

**What this unit teaches:** Pick one path: `if / else if / else`, the arrow `switch` expression, and why exhaustiveness is checked.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit08`), in the order below.

### java Pricing.java

The `switch` expression handing back a value.

```console
$ java Pricing.java
vegan meal: 130
```

### java Pricing2.java

A `switch` case with a block and `yield`.

```console
$ java Pricing2.java
Vegan: no dairy, no eggs
vegan meal: 130
```

### java Label.java

`if / else if / else` picking one branch.

```console
$ java Label.java
priced
```

### java BreakSwitch.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** a `switch` expression with no `default` and a missing case.

```console
$ java BreakSwitch.java
BreakSwitch.java:3: error: the switch expression does not cover all possible input values
    int price = switch (mealType) {
                ^
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).
