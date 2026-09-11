# Unit 18 — Records, Enums and Sealed Types

- `Orders.java` — `record Order(String customer, MealType type, int quantity)` with a `total()` method + `enum MealType { VEG(120), NON_VEG(150), VEGAN(130) }`; prints `Order[customer=Ravi, type=VEG, quantity=2]` / `Ravi pays 240` / `true` / `VEG -> 120` / `NON_VEG -> 150` / `VEGAN -> 130`. Run: `java Orders.java`
- `BreakRecord.java` — the first "break it on purpose" file: `order.quantity = 3;` does NOT compile (`BreakRecord.java:3: error: cannot assign a value to final variable quantity`) — a record is a value; make a new Order instead. Run: `java BreakRecord.java` and read the error.
- `Payments.java` — `sealed interface Payment permits Cash, Upi, Card` (three records) + `describe(...)` pattern `switch` with no `default`; prints `cash at the door` / `UPI to ravi@okbank` / `card ending 4421`. Run: `java Payments.java`
- `BreakSealed.java` — the second "break it on purpose" file: the `case Card` line is deleted, so it does NOT compile (`BreakSealed.java:7: error: the switch expression does not cover all possible input values`). Fix: put the `case Card c -> ...` line back. Run: `java BreakSealed.java` and read the error.
- Needs JDK 25 (compact source files + `IO.println`, JEP 512; records JEP 395, sealed types JEP 409, pattern switch JEP 441). Verified on JDK 25.0.4.1.
