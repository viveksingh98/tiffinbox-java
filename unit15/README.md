# Unit 15 — Inheritance: Meal, VegMeal, NonVegMeal

- `Meals.java` — parent `Meal` (dish, basePrice, `price()`, `label()`), children `VegMeal` (120) and `NonVegMeal` (150, overrides `label()` via `super.label()`), grandchild `JainMeal extends VegMeal` (overrides `price()` → 130 and `label()`); prints `dal rice - 120` / `chicken curry - 150 (non-veg)` / `kadhi - 130 (no onion, no garlic)`. Run: `java Meals.java`
- `BreakOverride.java` — the "break it on purpose" file: `@Override int prise()` (misspelt) does NOT compile (`BreakOverride.java:19: error: method does not override or implement a method from a supertype`, caret under `@Override`). Run: `java BreakOverride.java` and read the error.
- `SilentBug.java` — the same misspelling without `@Override`: compiles, `prise()` is a new method nobody calls, and the jain meal bills `kadhi - 120 (no onion, no garlic)`. Run: `java SilentBug.java`
- Needs JDK 25 (compact source files + `IO.println`, JEP 512); classes below `main` are nested members of the implicit class. Verified on JDK 25.0.4.1.
