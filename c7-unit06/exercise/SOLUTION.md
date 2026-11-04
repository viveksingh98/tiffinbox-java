# Solution — Ids and Generation Strategies

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mkdir -p .harness/ex/classes && sed 's/GenerationType.IDENTITY/GenerationType.SEQUENCE/' harness/src/probe/map/ex/ExCustomer.java > .harness/ex/ExCustomer.java
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExCustomer.java
V=(-Dlogback.configurationFile=../../harness/logback.xml -Dsql=WARN)
(cd .harness/run && exec java -Duser.language=en -Duser.country=US "${V[@]}" -cp "../ex/classes:../hc:../after/tiffinbox-web/target/extracted/lib/*" probe.map.Main batch 200 50 ex.ExCustomer) > .harness/mine.log 2>&1; echo "exit $?"
grep -E '^PROBE (statistics|jdbc|rows)' .harness/mine.log
```

One line differs from the README's: the copy of `ExCustomer.java` gets `GenerationType.SEQUENCE` in its `@GeneratedValue` (by hand,
open `.harness/ex/ExCustomer.java` and change that one word). What it prints (measured, `../receipts.sh`, capture `exercise`, in the
same shell, after the README's lines, in bash and in zsh):

```
exit 0
PROBE statistics: statements prepared 6 | inserts 200 | updates 0 | deletes 0 | flushes 1
PROBE jdbc: prepareStatement 6 | executeUpdate 0 | addBatch 200 | executeBatch 4 | executeQuery 5 | execute 0
PROBE rows, read by a second connection: [200]
```

A sequence hands Hibernate the ids before any INSERT — five calls for two hundred rows (`executeQuery 5`: one per fifty, and the
first) — so the INSERTs wait for the commit and go in four batches of fifty: one statement prepared for all of them, `addBatch` 200,
`executeBatch` 4.
