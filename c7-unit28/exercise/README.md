# Exercise — Pessimistic Locking and Deadlocks

**Your turn:** the README's two transactions lock Ravi and Meera in opposite orders, and one is killed. Lock them in one order.

Run it from this unit's folder (`c7-unit28/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (TiffinBox at Section 4's
end, copied, its jar extracted — its libraries are Spring Boot's, Hibernate's and H2's, the ones the block compiles against). The
block copies the exercise's application, `harness/src/probe/t/ex/ExApp.java`, to `.harness/ex/` and compiles it there. It is a Spring
Boot application with no web server, in its own package, `probe.t.ex`, with one entity of its own, `Diner` (an id, a name, meals a
day), on a table Hibernate creates in this JVM's own H2 database (`ddl-auto=create`, the exercise's own table, never TiffinBox's),
and a Spring Data repository of its own, `Diners`, whose one read takes the row with `@Lock(PESSIMISTIC_WRITE)`. The runner stores
Ravi and Meera, then runs **two transactions on two threads**, T1 and T2; each is one `@Transactional` call of the service
`Kitchen.lockBoth(first, second, …)`, which locks its two diners one after the other in the order the call names. **T1 locks Ravi,
then Meera; T2 locks Meera, then Ravi.** T1 locks Ravi and lets T2 start; T2 locks Meera, lets T1 go on, and asks for Ravi after a
configured gap of 300 (a latch nobody counts down, awaited that long - `ExApp.GAP`); T1 waits for T2's first lock at most that same gap. Then the
runner prints what each transaction did and reads the table through a JDBC connection of its own, after both. One JVM starts it,
under an alarm (`perl -e 'alarm 120; exec …'`: macOS has no `timeout`), its arguments in an array, `A`, so bash and zsh pass each
one as one argument. It binds no port and stops on its own. The last line keeps the runner's lines. H2 only, here.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/t/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.level.root=warn '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=create)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.t.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep '^PROBE ' .harness/mine.log
```


What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 0
PROBE T1: locked Ravi, then Meera, committed
PROBE T2: threw org.springframework.dao.CannotAcquireLockException <- org.hibernate.exception.LockAcquisitionException <- org.h2.jdbc.JdbcSQLTransactionRollbackException <- org.h2.mvstore.MVStoreException · the last cause says: Transaction <n> has been chosen as a deadlock victim
PROBE after both, its own JDBC connection reads: Ravi 2, Meera 1
```

T1 holds Ravi and waits for Meera; T2 holds Meera and asks for Ravi: each waits for the other, and H2 refuses the request that closes
the circle — T2's. T2's transaction is rolled back (its last cause says it was chosen as the deadlock's victim), T1 gets Meera and
commits, and the table still says Ravi 2, Meera 1: nothing was written, only locked. The `deadlock` capture is the same shape on
TiffinBox's own `CustomerEntity`, on H2 and on PostgreSQL.

**Done** when the JVM prints `exit 0`, both transactions say `committed`, and the table still says Ravi 2, Meera 1. The solution, and
what it prints, is in `SOLUTION.md`.
