# Unit 16 — Polymorphism: One Call, Many Behaviours
Run each file with JDK 25: `java Polymorphism.java` (one loop, three `price()` methods, total 400, then the upcast prints 130).
`java BreakUpcast.java` fails on purpose: `cannot find symbol ... method kitchenNote() ... variable special of type BreakUpcast.Meal`.
`java FixUpcast.java` prints `Vegan: no dairy, no eggs` via pattern matching for `instanceof`.
Verified on JDK 25.0.4.1 (compact source files, `IO.println`, no imports needed for `List.of`).
