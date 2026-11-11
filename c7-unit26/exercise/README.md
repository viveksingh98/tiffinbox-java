# Exercise — Rollback Rules

**Your turn:** the README's method fails with a checked exception and the customer is still saved. Make it roll back.

Run it from this unit's folder (`c7-unit26/`) after `./receipts.sh` has run once: it builds `.harness/after` (TiffinBox after this
unit's change, copied, its jar extracted — among its libraries `tiffinbox-core-1.0.0.jar`, with TiffinBox's entities, its own
`CustomerEntityRepository` and the shipped `Database`). The block copies the exercise's application,
`harness/src/probe/t/ex/ExApp.java`, to `.harness/ex/` and compiles it there. It is a Spring Boot application with no web server, in
its own package, `probe.t.ex`, that maps TiffinBox's entities, seeds its own H2 database with the shipped `Database` (Ravi, Meera,
Sunil, Priya), and holds one service. `SignUp.signUp(name)` is `@Transactional`: it saves the new customer through TiffinBox's own
repository, then reads the welcome letter it would send — and the file is missing: `FileNotFoundException`, a **checked** exception,
leaves the method. The runner signs up Kavya, prints what the call threw, then reads the table through a JDBC connection of its own,
after the call. One JVM starts it, under an alarm (`perl -e 'alarm 120; exec …'`: macOS has no `timeout`), its arguments in an array,
`A`, so bash and zsh pass each one as one argument. It binds no port and stops on its own. The last line keeps the lines that matter
from its log: Spring Data's scan line, the transaction manager's lines that create, commit or roll back, and the runner's.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/t/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*" probe.t.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|Creating new transaction with name \[[^]]*\]|Initiating transaction (commit|rollback)|^PROBE .*)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 0
Found 1 JPA repository interface.
Creating new transaction with name [probe.t.ex.SignUp.signUp]
Initiating transaction commit
PROBE signUp(Kavya) threw: java.io.FileNotFoundException: welcome-letter.txt (the letter template is missing)
PROBE after the call, its own JDBC connection reads: customer rows 5 · Kavya kept
```

The method threw, and Kavya is still in the table: five customers. `signUp`'s `FileNotFoundException` is a checked exception, and by
Spring's default rule a checked exception that leaves a transactional method **commits** — the manager's line says so. The `rules`
capture's first row is the same shape.

**Done** when the JVM prints `exit 0`, the call still throws the same `FileNotFoundException`, and the table holds four customers —
Kavya gone. The solution, and what it prints, is in `SOLUTION.md`.
