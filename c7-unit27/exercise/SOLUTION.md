# Solution — Optimistic Locking with @Version

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's/^    private Long version;$/    @Version private Long version;/' harness/src/probe/t/ex/ExApp.java > .harness/ex/ExApp.java
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=create)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*" probe.t.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(\[[A-Za-z]+\] org\.springframework\.orm\.jpa\.JpaTransactionManager : (Creating new transaction with name \[[^]]*\]|Initiating transaction (commit|rollback( after commit exception)?)$)|^PROBE .*)' .harness/mine.log
```

One line differs from the README's: the copy of `ExApp.java` carries `@Version` on `Diner`'s version field (by hand: open
`.harness/ex/ExApp.java` and annotate the field):

```java
    @Version private Long version;
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh — compared with this block, line for line):

```
the JVM: exit 0
[main] org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [probe.t.ex.Meals.store]
[main] org.springframework.orm.jpa.JpaTransactionManager : Initiating transaction commit
[A] org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [probe.t.ex.Meals.add]
[B] org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [probe.t.ex.Meals.add]
[B] org.springframework.orm.jpa.JpaTransactionManager : Initiating transaction commit
[A] org.springframework.orm.jpa.JpaTransactionManager : Initiating transaction commit
[A] org.springframework.orm.jpa.JpaTransactionManager : Initiating transaction rollback after commit exception
PROBE edit B committed: mealsPerDay 7
PROBE edit A threw: org.springframework.orm.ObjectOptimisticLockingFailureException: Unexpected row count (expected row count 1 but was 0) [update diner set meals_per_day=?,name=?,version=? where id=? and version=?] for entity [probe.t.ex.Diner with id '1']
PROBE after both edits, its own JDBC connection reads: Ravi mealsPerDay 7
```

B commits first, as before; A's UPDATE now carries the version it read in its where clause, matches no row — B moved the version on —
and A's commit fails with `ObjectOptimisticLockingFailureException`: the edit that lost says so, and Ravi keeps B's 7. The `race`
capture's A is the same shape on TiffinBox's own `CustomerEntity`, which carries `@Version` since this unit.
