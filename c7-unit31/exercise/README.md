# Exercise — JOIN FETCH vs @EntityGraph vs @BatchSize

**Your turn:** the README's page runs one more statement for every customer. Make it one statement, without writing JPQL.

Run it from this unit's folder (`c7-unit31/`) after `./receipts.sh` has run once: it builds `.harness/after` (TiffinBox as this unit
leaves it, copied, its jar extracted — its libraries are Spring Boot's, Spring Data's, Hibernate's and H2's, the ones the block
compiles against). The block copies the exercise's application, `harness/src/probe/w/ex/ExApp.java`, to `.harness/ex/` and compiles it
there. It is a Spring Boot application with no web server, in its own package, `probe.w.ex`, with two entities of its own — `Diner`
(a name: the application's customers) and `Break` (a diner's paused days; a diner's `breaks` are a lazy collection, as TiffinBox's
`pauses` are) — on tables Hibernate creates in this JVM's own H2 database (`ddl-auto=create`, the exercise's own tables, never
TiffinBox's), and a Spring Data repository, `Diners`: `findAll(Sort)` inherited, and one derived method of its own,
`findAllByOrderByNameAsc()`. The runner stores four diners (Priya with a break of 2 days, Sunil 3) and 6 more, reads the page — every
diner through `diners.findAll(Sort.by("name"))`, her breaks summed, in a read-only transaction — and prints how many diners it read
and the statements the read prepared, from Hibernate's statistics (switched on by the last argument, cleared before each read); then
it stores diners up to 36 more and does the same. One JVM, under an alarm (`perl -e 'alarm 120; exec …'`: macOS has no `timeout`), its
arguments in an array, `A`, so bash and zsh pass each one as one argument. It binds no port and stops on its own. The last line keeps
the runner's lines from its log.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/w/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=create --spring.jpa.properties.hibernate.generate_statistics=true)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*" probe.w.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -E '^PROBE ' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 0
PROBE diners 10 · the page's statements (getPrepareStatementCount): 11
PROBE diners 40 · the page's statements (getPrepareStatementCount): 41
```

Thirty more diners, and thirty more statements: `findAll(Sort)` reads the diners in one statement, and each diner's breaks are read
in one more when the page sums them — one plus one per diner, at 10 diners and at 40 diners.

**Done** when the two lines print the same count, and it is one: the diners and their breaks in one statement, at any number of
diners. A hint: the repository already has a derived method of its own; Spring Data's `@EntityGraph` names what to fetch with it. The
solution, and what it prints, is in `SOLUTION.md`.
