# Exercise — Criteria API and Specifications

**Your turn:** the README's search passes a filter it does not have, and Spring Data four refuses it. Combine the filters it has.

Run it from this unit's folder (`c7-unit18/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (Section 3's frozen
anchor, copied, its jar extracted — among its libraries `tiffinbox-core-1.0.0.jar`, with TiffinBox's entities and the shipped
`Database`). The block copies the exercise's application, `harness/src/probe/q/ex/ExApp.java`, to `.harness/ex/` and compiles it
there. It is a Spring Boot application with no web server, in its own package, `probe.q.ex`, that maps TiffinBox's entities
(`@EntityScan("com.tiffinbox")`), seeds its own H2 database with the shipped `Database` (Ravi, Meera, Sunil, Priya), and carries a
repository of its own in the same file — `interface Customers extends JpaRepository<CustomerEntity, Long>,
JpaSpecificationExecutor<CustomerEntity>` — and one runner, `search`, with three optional filters, each a `Specification`: a meal
type (not given — `byType` is `null`), a name that contains `r` (`byName`) and at least two meals a day (`byMeals`). It collects the
ones it has into a list, `filters`, and then combines all three the way older code does — `Specification.where(byType).and(byName)
.and(byMeals)` — and asks the repository for the customers. One JVM starts it, under an alarm (`perl -e 'alarm 120; exec …'`: macOS
has no `timeout`), its arguments in an array, `A`, so bash and zsh pass each one as one argument; the database is H2, in that JVM's
memory. It binds no port and stops on its own; a run that fails prints its exception and each cause, one line each. The last line
keeps the lines that matter from its log: Spring Data's scan line, Hibernate's SQL lines and the runner's.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/q/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.q.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|^PROBE .*|org\.hibernate\.SQL : .*)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 1
Found 1 JPA repository interface.
PROBE threw: java.lang.IllegalArgumentException: Specification must not be null
```

The application starts and Spring Data finds the repository (`Found 1`); then the runner builds its search, and the first call,
`Specification.where(byType)`, gets the filter the search does not have — `null`. Spring Data JPA 4.1 refuses it there, before any
query exists: no SQL line at all. Unit 18's `nulls` capture shows the same refusal (B), and `and(null)`'s beside it.

**Done** when the JVM prints `exit 0`, one SQL line with the conditions the search has, and the runner's customers. The solution,
and what it prints, is in `SOLUTION.md`.
