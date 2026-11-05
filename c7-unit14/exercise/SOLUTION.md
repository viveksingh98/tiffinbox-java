# Solution — Money in the Database

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's/^    @Column(precision = 10, scale = 2)$/    @Digits(integer = 8, fraction = 2) @Column(precision = 10, scale = 2)/' harness/src/probe/map/ex/Bill.java > .harness/ex/Bill.java
javac -d .harness/ex/classes -cp ".harness/hc:.harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/Bill.java
V=(-Dlogback.configurationFile=../../harness/logback.xml -Dbind=TRACE)
(cd .harness/run && exec java -Duser.language=en -Duser.country=US -Duser.timezone=UTC "${V[@]}" -cp "../ex/classes:../hc:../anchor/tiffinbox-web/target/extracted/lib/*:../drv/*" probe.map.Main ex u14ex) > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -hE '^(PROBE (EXCEPTION|  Caused by|refused|  violation|statistics|jdbc|read back)|DEBUG org\.hibernate\.SQL : insert|TRACE org\.hibernate\.orm\.jdbc\.bind : binding parameter \(1:NUMERIC\))' .harness/mine.log
```

One line differs from the README's: the copy of `Bill.java` puts Bean Validation's `@Digits` beside the column (by hand, open
`.harness/ex/Bill.java` and add it — the import is already there):

```java
    @Digits(integer = 8, fraction = 2) @Column(precision = 10, scale = 2)
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh):

```
the JVM: exit 0
PROBE refused at persist: jakarta.validation.ConstraintViolationException: Validation failed for classes [probe.map.ex.Bill] during persist time for groups [jakarta.validation.groups.Default, ]
PROBE   violation probe.map.ex.Bill.amount = 120.105: numeric value out of bounds (<8 digits>.<2 digits> expected)
PROBE statistics: statements prepared (getPrepareStatementCount) 0 | queries executed (getQueryExecutionCount) 0 | entities loaded (getEntityLoadCount) 0 | entity inserts 0
PROBE jdbc: prepareStatement 0 | executeUpdate 0 | addBatch 0 | executeBatch 0 | executeQuery 0 | execute 0
```

Eight digits before the point, two after: the validator checks the bill when it is persisted, before Hibernate prepares any SQL —
`0` statements by Hibernate's count and by the driver's, nothing in the SQL log. The column is the same `numeric(10,2)` either way
(the `ddl` capture in `../receipts.sh`); only the solution refuses.
