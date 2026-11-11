# Solution — Propagation, All Seven

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's/^    public void addRow(String name) {$/    @Transactional(propagation = Propagation.REQUIRES_NEW) public void addRow(String name) {/' harness/src/probe/t/ex/ExApp.java > .harness/ex/ExApp.java
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.t.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|Creating new transaction with name \[[^]]*\]|Suspending current transaction, creating new transaction with name \[[^]]*\]|Participating transaction failed - marking existing transaction as rollback-only|Initiating transaction (commit|rollback)|^PROBE .*)' .harness/mine.log
```

One line differs from the README's: the copy of `ExApp.java` carries `@Transactional(propagation = Propagation.REQUIRES_NEW)` on the
per-row method (by hand: open `.harness/ex/ExApp.java` and put the annotation on `addRow`):

```java
    @Transactional(propagation = Propagation.REQUIRES_NEW) public void addRow(String name) {
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh — compared with this block, line for line):

```
the JVM: exit 0
Found 1 JPA repository interface.
Creating new transaction with name [probe.t.ex.Importer.importRows]
Suspending current transaction, creating new transaction with name [probe.t.ex.Rows.addRow]
Initiating transaction commit
Suspending current transaction, creating new transaction with name [probe.t.ex.Rows.addRow]
Participating transaction failed - marking existing transaction as rollback-only
Initiating transaction rollback
Suspending current transaction, creating new transaction with name [probe.t.ex.Rows.addRow]
Initiating transaction commit
Initiating transaction commit
PROBE importRows([Asha, Ravi, Dev]) returned: added 2 · refused Ravi (23505)
PROBE after the call, its own JDBC connection reads: customer rows 6 · Asha kept · Dev kept
```

Each row now gets a transaction of its own: the import's is suspended, the row's is created, committed or rolled back, and the
import's resumes. Ravi's refusal marks and rolls back only Ravi's own transaction; Asha's and Dev's commit; the import's commits
last, with nothing marked: `added 2 · refused Ravi (23505)`, six rows. The same exception kind (Spring's runtime
`DataIntegrityViolationException`) and the same call path (the import calls another bean's method) as the README's.

**Not this file's change — TiffinBox's own import:** its `CustomerRepository.add` turns the refusal into the checked `SQLException`.
In that shape `REQUIRES_NEW` alone is not enough: the row's transaction ends with a checked exception, which commits by default, the
commit finds the mark and throws `UnexpectedRollbackException`, and Dev is never stored. The fix needs a rollback rule for the checked
exception — the lesson called *Rollback Rules*.
