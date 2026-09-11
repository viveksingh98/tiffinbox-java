# Unit 08 — Making Decisions: if, else, switch

- `Pricing.java` — `if / else if / else` on Ravi's meal type, prints `vegan meal: 130`. Run: `java Pricing.java`
- `Pricing2.java` — the `switch` expression with arrow cases, a `vegan` block case using `yield`, prints `Vegan: no dairy, no eggs` then `vegan meal: 130`. Run: `java Pricing2.java`
- `Label.java` — the ternary operator `price > 0 ? "priced" : "unknown"`, prints `priced`. Run: `java Label.java`
- `BreakSwitch.java` — the "break it on purpose" file: `default` deleted, does NOT compile (`the switch expression does not cover all possible input values`). Run: `java BreakSwitch.java` and read the error.
- Needs JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.
