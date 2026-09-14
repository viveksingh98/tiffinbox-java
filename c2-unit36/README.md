# c2-unit36 — Transactions, Savepoints and Batches (JDK 25.0.4.1, Maven 3.9.16)
1. `export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH=$JAVA_HOME/bin:$PATH`
2. `mvn -q compile exec:java -Dexec.mainClass=Tx`
One dependency, H2 `2.5.250` — transactions and batches need nothing but the driver.
`Tx.java` — `setAutoCommit(false)` and a committed move; a rollback proven by printing `7` inside the transaction and `6` from a fresh connection after the foreign key fires (SQLState `23506`); the same pair again with a `Savepoint`, where the good insert survives; a 40-row `addBatch`/`executeBatch` whose counts are checked for *failure* (`n >= 0 || n == SUCCESS_NO_INFO`), not for `1`; and the money slide — `INT` paise, `DECIMAL(10,2)` and `DOUBLE`, where the `DOUBLE` row exists but `WHERE as_double = 0.3` cannot find it.
3 runs byte-identical, md5 `ba965d893799139b452a5bd9828357ae`. `Db.reset()` rebuilds the schema every run; delete `data/` to start over.
