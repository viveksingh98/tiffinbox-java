# c2-unit35 — JDBC: Connect, Query, Map Rows to Records (JDK 25.0.4.1, Maven 3.9.16)
1. `export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH=$JAVA_HOME/bin:$PATH`
2. `mvn -q compile exec:java -Dexec.mainClass=Connect`
No install: H2 `2.5.250` arrives as a Maven dependency and creates `data/tiffinbox.mv.db` on the first connection.
`Connect.java` — `DriverManager` and `DataSource` side by side, `ResultSet` rows mapped into the shared `Customer` record by column name, the SQL-injection demo on a `staff_login` table this program creates and owns, and the `created_at` column that loses five and a half hours between a UTC writer and an `Asia/Kolkata` reader (the fix is `TIMESTAMP WITH TIME ZONE`).
3 runs byte-identical, md5 `8678293f879cc4326910a4e7764693b8` — and identical again under `-Duser.timezone=America/New_York`, `UTC` and `Australia/Sydney`, so the timestamp beat does not depend on your machine's zone. Delete `data/` to start clean.
