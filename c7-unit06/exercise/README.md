# Exercise — Ids and Generation Strategies

**Your turn:** the README saves two hundred customers and the driver never sees a batch. Change one annotation until it does.

Run it from this unit's folder (`c7-unit06/`) after `./receipts.sh` has run once: it builds `.harness/after` (after/, copied, its
jar extracted) and `.harness/hc` (the mapping harness, compiled). The block copies the exercise's entity,
`harness/src/probe/map/ex/ExCustomer.java`, to `.harness/ex/`, compiles it there, and runs the harness's `batch` scenario on it:
two hundred persists in one transaction, `hibernate.jdbc.batch_size` 50, on H2 in the JVM's memory. The JVM's flags travel as an
array, `V`, so bash and zsh pass each one as one argument. It binds no port and stops on its own.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mkdir -p .harness/ex/classes && cp harness/src/probe/map/ex/ExCustomer.java .harness/ex/ExCustomer.java
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExCustomer.java
V=(-Dlogback.configurationFile=../../harness/logback.xml -Dsql=WARN)
(cd .harness/run && exec java -Duser.language=en -Duser.country=US "${V[@]}" -cp "../ex/classes:../hc:../after/tiffinbox-web/target/extracted/lib/*" probe.map.Main batch 200 50 ex.ExCustomer) > .harness/mine.log 2>&1; echo "exit $?"
grep -E '^PROBE (statistics|jdbc|rows)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh):

```
exit 0
PROBE statistics: statements prepared 200 | inserts 200 | updates 0 | deletes 0 | flushes 1
PROBE jdbc: prepareStatement 200 | executeUpdate 200 | addBatch 0 | executeBatch 0 | executeQuery 0 | execute 0
PROBE rows, read by a second connection: [200]
```

Two hundred statements prepared, two hundred `executeUpdate` calls, not one `executeBatch` — though the run sets
`hibernate.jdbc.batch_size` to 50. The id comes from the INSERT, so Hibernate sends each INSERT at `persist`, one at a time.

**Done** when the `jdbc:` line shows `executeBatch` above 0 and the rows are still 200. The solution, and what it prints, is in
`SOLUTION.md`.
