# Unit 34 — Maven in 15 Minutes
Run (JDK 25 + Maven 3.9, `JAVA_HOME` on JDK 25): `mvn package` → `java -jar target/tiffinbox-1.0.jar` (or `java -cp target/classes com.tiffinbox.Main`).
Break it on purpose: delete the `maven-jar-plugin` block from `pom.xml`, `mvn -q package`, then `java -jar target/tiffinbox-1.0.jar` → `no main manifest attribute`.
`mvn clean` deletes `target/`; `mvn -q package` brings the jar back. `Billing.java` still carries Unit 33's planted `31` overload — Unit 35's test finds it.
Never commit `target/`.
