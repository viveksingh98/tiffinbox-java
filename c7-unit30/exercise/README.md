# Exercise — N+1, Measured

**Your turn:** the README prints the page's query count, and it stays the same however many customers there are. Print the count that grows.

Run it from this unit's folder (`c7-unit30/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (TiffinBox as unit 29
left it, copied, its jar extracted — its libraries are Spring Boot's, Hibernate's and H2's, the ones the block compiles against). The
block copies the exercise's application, `harness/src/probe/v/ex/ExApp.java`, to `.harness/ex/` and compiles it there. It is a Spring
Boot application with no web server, in its own package, `probe.v.ex`, with two entities of its own — `Diner` (a name: the
application's customers) and `Break` (a diner's paused days; a diner's `breaks` are a lazy collection, as TiffinBox's `pauses` are) —
on tables Hibernate creates in this JVM's own H2 database (`ddl-auto=create`, the exercise's own tables, never TiffinBox's). The runner
stores four diners (Priya with a break of 2 days, Sunil 3) and 6 more, reads the page — every diner by name, her breaks summed, in a
read-only transaction — and prints how many diners it read and the page's count from Hibernate's statistics (switched on by the
last argument, cleared before each read); then it stores diners up to 36 more and does the same. One JVM, under an alarm (`perl -e
'alarm 120; exec …'`: macOS has no `timeout`), its arguments in an array, `A`, so bash and zsh pass each one as one argument. It binds
no port and stops on its own. The last line keeps the runner's lines from its log.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/v/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=create --spring.jpa.properties.hibernate.generate_statistics=true)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.v.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -E '^PROBE ' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 0
PROBE diners 10 · the page's count: 1
PROBE diners 40 · the page's count: 1
```

Thirty more diners, and the count did not move: `ExApp.count` returns `getQueryExecutionCount()`, Hibernate's count of the
queries it ran — the page's one JPQL query. The breaks it loaded, one SELECT for each diner, are collection loads, not queries, and
that count leaves them out.

**Done** when the two lines print two different counts, each one more than its diners — one statement for the list and one for each
diner's breaks. The solution, and what it prints, is in `SOLUTION.md`.
