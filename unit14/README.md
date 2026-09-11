# Unit 14 — Encapsulation: Private Fields, Public Doors

- `Customer.java` (a normal `public class`, its own file) + `Encapsulation.java` (compact `void main()`) — `private final name`, `private mealsPerDay`, public getters, `setMealsPerDay` with the 1..3 rule, `private static int count` + `Customer.count()`. Run from this folder: `java Encapsulation.java` → `Ravi eats 3` / `Rejected: -5 meals a day` / `Ravi still eats 3` / `Customers: 2` (the launcher compiles `Customer.java` beside it, JEP 458).
- `BreakPrivate.java` — the "break it on purpose" file: `ravi.mealsPerDay = -5;` from `main` does NOT compile (`BreakPrivate.java:3: error: mealsPerDay has private access in Customer`). Fix: use `ravi.setMealsPerDay(...)`. Run: `java BreakPrivate.java`
- `breakfinal/` — a `Customer.java` whose constructor forgets `this.name = name;`: `cd breakfinal && java BreakFinal.java` → `.../breakfinal/Customer.java:7: error: variable name might not have been initialized` (`final` = assigned exactly once, checked by the compiler).
- Two files on purpose: in one compact source file the classes would be nested and share `private` access. Needs JDK 25 (`IO.println`, JEP 512). Verified on JDK 25.0.4.1.
