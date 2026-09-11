# Unit 10 — Methods: Name a Piece of Work

- `Billing.java` — `calculateBill(meals, price, days)`, its 30-day overload `calculateBill(meals, price)` and the `void printReceipt(name, amount)`; prints `7200` / `4500` / `7200` / `Ravi owes 7200 this month`. Run: `java Billing.java`
- `BreakReturn.java` — the "break it on purpose" file: the body stores `int total = ...` and forgets `return`, so it does NOT compile (`BreakReturn.java:7: error: missing return statement`). Fix: add `return total;`. Run: `java BreakReturn.java` and read the error. (A `return amount;` inside a `void` method fails with `incompatible types: unexpected return value`.)
- Needs JDK 25 (compact source files + `IO.println`, JEP 512) — no `static` needed here; inside a classic `public class` these methods would need `static` (Unit 14). Verified on JDK 25.0.4.1.
