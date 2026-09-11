# Unit 17 — Abstract Classes and Interfaces

- `AbstractMeal.java` — `abstract class Meal` (field, constructor, `abstract int price()`, concrete `label()`), `VegMeal extends Meal` (120) and `VeganMeal extends VegMeal` (130); prints `vegetable stew - 130`. Run: `java AbstractMeal.java`
- `BreakAbstract.java` — the "break it on purpose" file: `new Meal("mystery")` does NOT compile (`BreakAbstract.java:2: error: BreakAbstract.Meal is abstract; cannot be instantiated`). Run: `java BreakAbstract.java` and read the error.
- `Payable.java` — `interface Payable` with `int amountDue()` and a `default String receipt()`; `Customer` and `Rider` both `implements Payable`; a `Payable[]` loop prints `Due: 7200` / `Sunil earns 8800`. Run: `java Payable.java`
- `BreakInterface.java` — `Rider implements Payable` but forgets `amountDue()`: `error: BreakInterface.Rider is not abstract and does not override abstract method amountDue() in Payable`. Run: `java BreakInterface.java`
- Needs JDK 25 (compact source files + `IO.println`, JEP 512); classes below `main()` are nested members, so messages read `BreakAbstract.Meal`. Verified on JDK 25.0.4.1.
