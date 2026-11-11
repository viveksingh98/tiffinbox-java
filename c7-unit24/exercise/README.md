# Exercise — Propagation, All Seven

**Your turn:** the README's import catches one refused row and loses every row it stored. Keep the good rows.

Run it from this unit's folder (`c7-unit24/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (TiffinBox as shipped,
copied, its jar extracted — among its libraries `tiffinbox-core-1.0.0.jar`, with TiffinBox's entities, its own
`CustomerEntityRepository` and the shipped `Database`). The block copies the exercise's application,
`harness/src/probe/t/ex/ExApp.java`, to `.harness/ex/` and compiles it there. It is a Spring Boot application with no web server,
in its own package, `probe.t.ex`, that maps TiffinBox's entities, seeds its own H2 database with the shipped `Database` (Ravi,
Meera, Sunil, Priya), and holds two services. `Importer.importRows(names)` is `@Transactional`: one transaction around the whole
import. For each name it calls `Rows.addRow(name)` — another bean, so the call goes through that bean's proxy — which saves the
customer through TiffinBox's own repository, `CustomerEntityRepository.save`. A taken name comes back as Spring's runtime
`DataIntegrityViolationException`; the import catches it, notes the row as refused with its SQL state, and goes on with the next.
The runner imports Asha, Ravi (the seed already has a Ravi) and Dev, prints what came back, then reads the table through a JDBC
connection of its own, after the call. One JVM starts it, under an alarm (`perl -e 'alarm 120; exec …'`: macOS has no `timeout`), its
arguments in an array, `A`, so bash and zsh pass each one as one argument. It binds no port and stops on its own. The last line keeps
the lines that matter from its log: Spring Data's scan line, the transaction manager's lines that create, mark, commit or roll back,
and the runner's.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/t/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.t.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|Creating new transaction with name \[[^]]*\]|Suspending current transaction, creating new transaction with name \[[^]]*\]|Participating transaction failed - marking existing transaction as rollback-only|Initiating transaction (commit|rollback)|^PROBE .*)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 0
Found 1 JPA repository interface.
Creating new transaction with name [probe.t.ex.Importer.importRows]
Participating transaction failed - marking existing transaction as rollback-only
Initiating transaction commit
PROBE importRows([Asha, Ravi, Dev]) threw: org.springframework.transaction.UnexpectedRollbackException: Transaction silently rolled back because it has been marked as rollback-only
PROBE after the call, its own JDBC connection reads: customer rows 4 · Asha gone · Dev gone
```

The import caught Ravi's refusal and went on, and still lost Asha and Dev. `addRow` has no annotation, so the repository's `save`
takes part in the import's one transaction; when Ravi's INSERT is refused, that `save` fails inside the shared transaction and marks
it rollback-only — the manager's line says so. The import returns normally, the commit finds the mark, rolls everything back and
throws `UnexpectedRollbackException`: the seed's four rows, nothing added. The `grid` capture's REQUIRED row, inner-fails, is the same
shape.

**Done** when the JVM prints `exit 0`, the import returns `added 2 · refused Ravi (23505)`, and the table holds six customers —
Asha and Dev kept. The solution, and what it prints, is in `SOLUTION.md`.
