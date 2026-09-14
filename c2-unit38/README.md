# c2-unit38 — TiffinBox on a Real Database: The JDBC Repository (JDK 25.0.4.1, Maven 3.9.16)
1. `export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH=$JAVA_HOME/bin:$PATH`
2. `mvn -q compile exec:java -Dexec.mainClass=RepoDemo`
3. To also see the HikariCP banner that `mvn -q` swallows: `mvn -q dependency:build-classpath -Dmdep.outputFile=cp.txt` then `java -cp "target/classes:$(cat cp.txt)" RepoDemo`
`Repository.java` is the generics unit's interface, extended: `save` returns the saved item and `deleteById` replaced `count()`; `findById` and `findAll` are untouched, and no `java.sql` type appears in it. `JdbcCustomerRepository.java` implements it over a pooled `DataSource`, reads the count `executeUpdate()` returns in **both** writers, and adds `revenueOf` — a query that deliberately does not go on the interface — plus `revenueWithoutCoalesce`, which shows `rs.getLong` returning `0` with `rs.wasNull() = true`.
`Db.java` is the section's final `Db`: every table the four units built, plus the pool. 3 runs byte-identical — md5 `e30e949df191665a420a45c56c7d4414` (`mvn -q`), `2a1adca12e441e4a25c6967a3e75d389` (`java -cp`). Delete `data/` any time; `reset` rebuilds it.
