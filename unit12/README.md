# Unit 12 — Classes and Objects: Meet Customer

- `Customer.java` — the first TiffinBox class: `class Customer` (fields `name`, `mealsPerDay`, `pricePerMeal`, `isVeg` + method `monthlyBill()`) below `main`; `new Customer()` for Ravi and Meera, the dot to fill and read fields, and `var sameRavi = ravi;` to show two references to one object. Prints `Ravi eats 2 meals a day` / `Monthly: 7200` / `Monthly: 4500` / `Ravi now eats 3`. Run: `java Customer.java`
- `BreakNoNew.java` — the "break it on purpose" file: `Customer ravi;` without `new`, then `ravi.name = "Ravi";` — does NOT compile (`BreakNoNew.java:3: error: variable ravi might not have been initialized`). Fix: `Customer ravi = new Customer();`. Run: `java BreakNoNew.java` and read the error.
- Needs JDK 25 (compact source files + `IO.println`, JEP 512). In a compact file the class sits below `main` in the same file; Unit 14 moves it into its own file. Verified on JDK 25.0.4.1.
