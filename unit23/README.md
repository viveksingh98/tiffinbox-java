# Unit 23 — equals, hashCode and toString

- `Identity.java` — Unit 14's `Customer` with no overrides: prints `Identity$Customer@51b7e5df` (class name + identity hash, the hex is not a promise) / `false` / `false`. Run: `java Identity.java`
- `ToStringDemo.java` — `toString()` + `equals(Object)` overridden (`instanceof` pattern + field compare): prints `Ravi (2 meals/day)` / `Today: Ravi (2 meals/day)` / `true`. Run: `java ToStringDemo.java`
- `BreakEqualsSig.java` — "break it on purpose": `equals(Customer other)` under `@Override` does NOT compile (`BreakEqualsSig.java:15: error: method does not override or implement a method from a supertype`). Fix: the parameter must be `Object`. Run: `java BreakEqualsSig.java` and read the error.
- `BreakSet.java` → `2 customers, contains Ravi: false` (equals without hashCode: the HashSet keeps both Ravis and cannot find either) · `FixSet.java` adds `hashCode()` via `Objects.hash(name, mealsPerDay)` → `1 customers, contains Ravi: true` · `RecordSet.java` — `record Customer(String name, int mealsPerDay) {}` generates all three → `Customer[name=Ravi, mealsPerDay=2]` / `true` / `2`. Run: `java BreakSet.java`, `java FixSet.java`, `java RecordSet.java`
- Needs JDK 25 (compact source files + `IO.println`, JEP 512; `Set`, `HashSet`, `Objects` from `java.util`, imported implicitly). Verified on JDK 25.0.4.1.
