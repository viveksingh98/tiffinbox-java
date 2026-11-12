# Exercise — Optimistic Locking with @Version

**Your turn:** the README edits Ravi twice at once, and one edit disappears without an error. Make the losing edit fail loudly.

Run it from this unit's folder (`c7-unit27/`) after `./receipts.sh` has run once: it builds `.harness/after` (TiffinBox after this
unit's change, copied, its jar extracted — its libraries are Spring Boot's, Hibernate's and H2's, the ones the block compiles against).
The block copies the exercise's application, `harness/src/probe/t/ex/ExApp.java`, to `.harness/ex/` and compiles it there. It is a
Spring Boot application with no web server, in its own package, `probe.t.ex`, with one entity of its own, `Diner` — an id, a name,
meals a day, and a field called `version` — on a table Hibernate creates in this JVM's own H2 database (`ddl-auto=create`, the
exercise's own table, never TiffinBox's). The runner stores Ravi with 2 meals a day, then edits him **twice, on two threads at the same time**:
A loads Ravi, B loads Ravi, B adds 5 and commits, then A adds 1 and commits. Two latches keep that order — each edit is one
`@Transactional` call of the service `Meals`. Then it prints what each edit did and reads the table through a JDBC connection of its
own, after both. One JVM starts it, under an alarm (`perl -e 'alarm 120; exec …'`: macOS has no `timeout`), its arguments in an array,
`A`, so bash and zsh pass each one as one argument. It binds no port and stops on its own. The last line keeps the lines that matter
from its log: the transaction manager's lines that create, commit or roll back, and the runner's. H2 only, here.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/t/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=create)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*" probe.t.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(\[[A-Za-z]+\] org\.springframework\.orm\.jpa\.JpaTransactionManager : (Creating new transaction with name \[[^]]*\]|Initiating transaction (commit|rollback( after commit exception)?)$)|^PROBE .*)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 0
[main] org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [probe.t.ex.Meals.store]
[main] org.springframework.orm.jpa.JpaTransactionManager : Initiating transaction commit
[A] org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [probe.t.ex.Meals.add]
[B] org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [probe.t.ex.Meals.add]
[B] org.springframework.orm.jpa.JpaTransactionManager : Initiating transaction commit
[A] org.springframework.orm.jpa.JpaTransactionManager : Initiating transaction commit
PROBE edit B committed: mealsPerDay 7
PROBE edit A committed: mealsPerDay 3
PROBE after both edits, its own JDBC connection reads: Ravi mealsPerDay 3
```

Both edits committed, and Ravi has 3 meals a day: B's +5 is gone, and nothing said so. A wrote what it had read plus one, over B's
change. The field called `version` is just a column here: Hibernate neither checks it nor raises it. The `race` capture's B is the
same shape on TiffinBox's own `CustomerEntity` before this unit's change.

**Done** when the JVM prints `exit 0`, B still commits 7, A's edit throws `ObjectOptimisticLockingFailureException`, and the table says
Ravi 7 — the +5 kept. The solution, and what it prints, is in `SOLUTION.md`.
