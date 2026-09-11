# Unit 35 — Testing with JUnit 5

- Maven project (`pom.xml` + `src/`) in its final green state: `Billing.java` (two-argument overload fixed from `31` to `30`, plus the 1-to-3 meals guard), `Main.java`, and `src/test/java/com/tiffinbox/BillingTest.java` with three tests (`defaultMonthIsThirtyDays`, `nonVegSingleMeal`, `rejectsImpossibleMeals`).
- Run the tests: `mvn test` (from this folder, with `JAVA_HOME` on JDK 25) → `Tests run: 3, Failures: 0, Errors: 0, Skipped: 0` / `BUILD SUCCESS`. Run the app: `mvn -q package` then `java -jar target/tiffinbox-1.0.jar`.
- To see the red run from the video: change `30` back to `31` in `Billing.java`'s two-argument `calculateBill`, run `mvn test`, and read `expected: <7200> but was: <7440>`; `mvn package` on that state ends in `BUILD FAILURE` and builds no jar.
- Needs JDK 25 (`java.lang.IO`, JEP 512), Apache Maven 3.9.x, JUnit Jupiter 5.13.4 (downloaded by Maven on the first run). Verified on JDK 25.0.4.1, Maven 3.9.16, surefire 3.5.3.
