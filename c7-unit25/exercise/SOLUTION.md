# Solution — Isolation Levels

Ask for a stricter level on the report's transaction: `@Transactional(isolation = Isolation.REPEATABLE_READ)`. At REPEATABLE_READ
the transaction reads from one snapshot, taken at its first read, so its second read answers what its first did — on H2 here, and
on PostgreSQL alike (the `context` capture's REPEATABLE_READ reader prints 2, then 2 on both). The kitchen's commit is not undone:
its own JDBC connection reads Ravi 9 after both transactions ended. The block below is the exercise's with one line changed — the
copy step writes `ExApp.java` with the report's isolation set to `REPEATABLE_READ`.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's/^    @Transactional(isolation = Isolation.READ_COMMITTED)$/    @Transactional(isolation = Isolation.REPEATABLE_READ)/' harness/src/probe/t/ex/ExApp.java > .harness/ex/ExApp.java
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.t.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|Creating new transaction with name \[[^]]*\]: [A-Z_,]+|Initiating transaction (commit|rollback)|^PROBE .*)' .harness/mine.log
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — compared with the run, line for line):

```
the JVM: exit 0
Found 1 JPA repository interface.
Creating new transaction with name [probe.t.ex.Report.mealsTwice]: PROPAGATION_REQUIRED,ISOLATION_REPEATABLE_READ
Creating new transaction with name [probe.t.ex.Kitchen.setRavi]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT
Initiating transaction commit
Initiating transaction commit
PROBE the report: Ravi's meals, read twice in one transaction: 2, then 2 · both reads agree
PROBE after both transactions, its own JDBC connection reads: Ravi 9
```

The manager's line names the level the report asked for (`ISOLATION_REPEATABLE_READ`); the kitchen's stays `ISOLATION_DEFAULT`.
SERIALIZABLE would also make the two reads agree here; REPEATABLE_READ is the least level that does.
