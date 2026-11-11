# Exercise — @Transactional: What the Proxy Does

**Your turn:** the README's method saves a customer and then fails, and the customer stays. Make the rollback happen.

Run it from this unit's folder (`c7-unit23/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (TiffinBox as shipped,
copied, its jar extracted — among its libraries `tiffinbox-core-1.0.0.jar`, with TiffinBox's entities, its own
`CustomerEntityRepository` and the shipped `Database`). The block copies the exercise's application,
`harness/src/probe/t/ex/ExApp.java`, to `.harness/ex/` and compiles it there. It is a Spring Boot application with no web server,
in its own package, `probe.t.ex`, that maps TiffinBox's entities, seeds its own H2 database with the shipped `Database` (Ravi,
Meera, Sunil, Priya), and holds one service, `Signup`: its `signUp(name)` calls `this.inner(name)`, and `inner` — annotated
`@Transactional` — saves the customer through the repository, then throws. The runner calls `signUp("Asha")` from outside the
bean, prints what it threw, then reads the table through a JDBC connection of its own, after the call. One JVM starts it, under an
alarm (`perl -e 'alarm 120; exec …'`: macOS has no `timeout`), its arguments in an array, `A`, so bash and zsh pass each one as one
argument. It binds no port and stops on its own. The last line keeps the lines that matter from its log: Spring Data's scan line,
the transaction manager's two lines, and the runner's.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/t/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.t.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|Creating new transaction with name \[[^]]*\]|Initiating transaction (commit|rollback)|^PROBE .*)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 0
Found 1 JPA repository interface.
Creating new transaction with name [org.springframework.data.jpa.repository.support.SimpleJpaRepository.save]
Initiating transaction commit
PROBE signUp(Asha) threw: java.lang.IllegalStateException: the welcome step failed after the save of Asha
PROBE after the call, its own JDBC connection reads: customer rows 5 · Asha kept
```

The call threw, and Asha stayed: the only transaction in the log is the repository's own `save`, and it committed before `inner`
failed. `signUp` called `inner` on `this` — the object itself, not the proxy the runner was handed — so `inner`'s annotation was never
read; nothing in the log says so. Unit 23's `trap` capture, B, shows the same run with the manager's lines whole.

**Done** when the JVM prints `exit 0`, the transaction manager names the method the runner calls, the transaction is rolled back, and
the table holds the four seeded customers again — Asha gone. The solution, and what it prints, is in `SOLUTION.md`.
