# Exercise — Money in the Database

**Your turn:** the README saves a bill of 120.105 and the table quietly keeps 120.11. Make it refuse the third decimal before any SQL.

Run it from this unit's folder (`c7-unit14/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (the frozen anchor,
copied, its jar extracted — its libraries hold Hibernate Validator), `.harness/drv` (the PostgreSQL driver — on the class path, unused
here) and `.harness/hc` (the money harness, compiled). The block copies the exercise's entity, `harness/src/probe/map/ex/Bill.java`, to
`.harness/ex/` and compiles it there: a `Bill` whose `amount` is a `BigDecimal` in a column of ten digits, two after the point —
`@Column(precision = 10, scale = 2)` — and nothing else. Then one JVM, H2 in its memory, persists a bill of `120.105` in one
transaction and reads it back with a new EntityManager. Its flags travel as an array, `V`, so bash and zsh pass each one as one
argument; the bind logger is on (`-Dbind=TRACE`): it prints what Hibernate sent. It binds no port and stops on its own.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/map/ex/Bill.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/hc:.harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/Bill.java
V=(-Dlogback.configurationFile=../../harness/logback.xml -Dbind=TRACE)
(cd .harness/run && exec java -Duser.language=en -Duser.country=US -Duser.timezone=UTC "${V[@]}" -cp "../ex/classes:../hc:../anchor/tiffinbox-web/target/extracted/lib/*:../drv/*" probe.map.Main ex u14ex) > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -hE '^(PROBE (EXCEPTION|  Caused by|refused|  violation|statistics|jdbc|read back)|DEBUG org\.hibernate\.SQL : insert|TRACE org\.hibernate\.orm\.jdbc\.bind : binding parameter \(1:NUMERIC\))' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh):

```
the JVM: exit 0
DEBUG org.hibernate.SQL : insert into bill (amount,id) values (?,default)
TRACE org.hibernate.orm.jdbc.bind : binding parameter (1:NUMERIC) <- [120.105]
PROBE statistics: statements prepared (getPrepareStatementCount) 1 | queries executed (getQueryExecutionCount) 0 | entities loaded (getEntityLoadCount) 0 | entity inserts 1
PROBE jdbc: prepareStatement 1 | executeUpdate 1 | addBatch 0 | executeBatch 0 | executeQuery 0 | execute 0
PROBE read back by a new EntityManager: amount 120.11
```

Hibernate sent `120.105` whole (the bind line); the table keeps `120.11` — the database rounded the third decimal, and said nothing.

**Done** when the JVM prints `refused at persist` and `statements prepared (getPrepareStatementCount) 0` — the third decimal refused
before any SQL. The solution, and what it prints, is in `SOLUTION.md`.
