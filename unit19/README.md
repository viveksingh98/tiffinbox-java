# Unit 19 — ArrayList: A List That Grows

- `Customers.java` — `List<String> customers = new ArrayList<>();` then `add`, `get`, `size`, `remove("Meera")`, `contains`, `add(0, "Meera")`, `getFirst`/`getLast`/`reversed` (JDK 21+); prints `[Ravi, Meera, Sunil]` / `3 customers, first: Ravi` / `false` / `Meera ... Sunil` / `[Sunil, Ravi, Meera]`. Run: `java Customers.java`
- `Orders.java` — `var orders = new ArrayList<Order>();` with Unit 18's `Order` record + `MealType` enum below `main`, enhanced-for total, plus the fixed `List.of` menu; prints `3 orders, today's takings: 520` / `bean curry of 3`. Run: `java Orders.java`
- `BreakFixed.java` — trap 1: `menu.add("vegetable stew")` on a `List.of` list compiles, then throws `java.lang.UnsupportedOperationException` at run time (`at BreakFixed.main(BreakFixed.java:3)`). Fix: `new ArrayList<>(List.of(...))`. Run: `java BreakFixed.java` and read the stack trace.
- `BreakLoop.java` — trap 2: `customers.remove(name)` inside a for-each throws `java.util.ConcurrentModificationException` (`at BreakLoop.main(BreakLoop.java:3)`); `FixLoop.java` uses `customers.removeIf(name -> name.equals("Ravi"));` and prints `[Meera, Sunil]`. Run: `java BreakLoop.java`, then `java FixLoop.java`
- Needs JDK 25 (compact source files + `IO.println`, JEP 512; no import line — `java.base` is implicit). Verified on JDK 25.0.4.1.
