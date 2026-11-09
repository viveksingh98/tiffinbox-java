# Exercise — Bulk Updates and the Stale Context

**Your turn:** the README raises everyone's meals with one update and then reads Ravi's old number. Make the next read come from the database.

Run it from this unit's folder (`c7-unit22/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (Section 3's frozen
anchor, copied, its jar extracted — among its libraries `tiffinbox-core-1.0.0.jar`, with TiffinBox's entities and the shipped
`Database`). The block copies the exercise's application, `harness/src/probe/q/ex/ExApp.java`, to `.harness/ex/` and compiles it
there. It is a Spring Boot application with no web server, in its own package, `probe.q.ex`, that maps TiffinBox's entities
(`@EntityScan("com.tiffinbox")`), seeds its own H2 database with the shipped `Database` (Ravi, Meera, Sunil, Priya), and carries a
repository of its own in the same file — `interface Customers extends JpaRepository<CustomerEntity, Long>` with one bulk update,
`@Modifying @Query("update CustomerEntity c set c.mealsPerDay = c.mealsPerDay + 1") int raiseMeals()` — and one runner, `raise`: in
one transaction (a `TransactionTemplate`) it loads Ravi by `findById(1L)`, runs `raiseMeals()`, and reads Ravi again by `findById(1L)`,
printing the value that read returned and the number of statements it ran (Hibernate's statistics, switched on by the last argument
of `A`). One JVM starts it, under an alarm (`perl -e 'alarm 120; exec …'`: macOS has no `timeout`), its arguments in an array, `A`,
so bash and zsh pass each one as one argument; the database is H2, in that JVM's memory. It binds no port and stops on its own. The
last line keeps the lines that matter from its log: Spring Data's scan line and the runner's.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/q/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none --spring.jpa.properties.hibernate.generate_statistics=true)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.q.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|^PROBE .*)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 0
Found 1 JPA repository interface.
PROBE Ravi before the update: mealsPerDay 2
PROBE the update changed 4 rows
PROBE findById(1) after the update: mealsPerDay 2 · statements it ran: 0
```

The update ran and changed every customer's row in the database — yet the second `findById` hands back Ravi's old number, and it ran
no statement to get it: the persistence context already held Ravi, the bulk update went past it, and `findById` answered from it. Nothing
failed. Unit 22's `stale` capture shows the same read beside a native read in the same transaction, which sees the new value.

**Done** when the JVM prints `exit 0` and the second read returns Ravi's new number, read from the database. The solution, and what it
prints, is in `SOLUTION.md`.
