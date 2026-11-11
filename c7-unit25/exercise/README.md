# Exercise — Isolation Levels

**Your turn:** the README's report reads Ravi's meals twice in one transaction and gets two answers. Make both reads agree.

Run it from this unit's folder (`c7-unit25/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (TiffinBox as shipped,
copied, its jar extracted — among its libraries `tiffinbox-core-1.0.0.jar`, with TiffinBox's entities, its own
`CustomerEntityRepository` and the shipped `Database`). The block copies the exercise's application,
`harness/src/probe/t/ex/ExApp.java`, to `.harness/ex/` and compiles it there. It is a Spring Boot application with no web server,
in its own package, `probe.t.ex`, that maps TiffinBox's entities, seeds its own H2 database with the shipped `Database` (Ravi has
2 meals a day), and holds two services. `Report.mealsTwice` is `@Transactional(isolation = Isolation.READ_COMMITTED)`: in ONE
transaction it reads Ravi's meals with SQL that reaches the database (a native query, never `findById` — the persistence context
would answer the second read from memory), waits on a latch, and reads them again. Between the two reads `Kitchen.setRavi(9)`, on
another thread and in its own transaction, sets Ravi to 9 and commits; two latches put the steps in that order. The runner prints
both reads, then reads Ravi through a JDBC connection of its own, after both transactions ended. One JVM starts it, under an alarm
(`perl -e 'alarm 120; exec …'`: macOS has no `timeout`), its arguments in an array, `A`, so bash and zsh pass each one as one
argument. It binds no port and stops on its own. The last line keeps the lines that matter from its log: Spring Data's scan line,
the transaction manager's lines that create (with the level each transaction asked for) and commit, and the runner's.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/t/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.t.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|Creating new transaction with name \[[^]]*\]: [A-Z_,]+|Initiating transaction (commit|rollback)|^PROBE .*)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 0
Found 1 JPA repository interface.
Creating new transaction with name [probe.t.ex.Report.mealsTwice]: PROPAGATION_REQUIRED,ISOLATION_READ_COMMITTED
Creating new transaction with name [probe.t.ex.Kitchen.setRavi]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT
Initiating transaction commit
Initiating transaction commit
PROBE the report: Ravi's meals, read twice in one transaction: 2, then 9 · two answers
PROBE after both transactions, its own JDBC connection reads: Ravi 9
```

One transaction, two answers: at READ_COMMITTED every statement sees what was committed before it began, so the second read sees
the kitchen's committed 9. That is the non-repeatable read of the `anomalies` table's READ_COMMITTED row, on H2 here (it is the same
on PostgreSQL: the `context` capture's reader prints 2, then 9 on both).

**Done** when the JVM prints `exit 0` and the report prints `2, then 2 · both reads agree` — while the kitchen still commits its 9
(the last line still reads Ravi 9). Change one thing on the report, nothing on the kitchen. The solution, and what it prints, is in
`SOLUTION.md`.
