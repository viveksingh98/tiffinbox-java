# Exercise — Batching and the Write Path

**Your turn:** the README saves customers with a pause each, and every insert goes in a batch of its own. Make the batches full.

Run it from this unit's folder (`c7-unit33/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (TiffinBox as unit 31
left it, copied, its jar extracted — its libraries are Spring Boot's, Spring Data's, Hibernate's and H2's). The block copies the
exercise's application, `harness/src/probe/b/ex/ExApp.java`, to `.harness/ex/` and compiles it there. It is a Spring Boot application
with no web server, in its own package, `probe.b.ex`, with two entities of its own — `Diner` (a name) and `Break` (a diner's days
off, its own table `break_day`) — both on SEQUENCE ids, fifty per call (`allocationSize = 50`), on tables Hibernate creates in this JVM's
own H2 database in memory (`ddl-auto=create`: no port, no container, never TiffinBox's tables). The runner saves 100 diners in one
transaction, each persisted with one break right after it, then prints the rows a second connection reads back and how many times
Hibernate called `executeBatch` — the application wraps Boot's pool in a small counting proxy, as the lesson's harness does. The batch
size is an argument: `hibernate.jdbc.batch_size=50`. One JVM, under an alarm (`perl -e 'alarm 120; exec …'`: macOS has no `timeout`),
its arguments in an array, `A`, so bash and zsh pass each one as one argument. It binds no port and stops on its own. The last line
keeps the runner's lines from its log.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/b/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=create --logging.level.org.hibernate.SQL=warn --spring.jpa.properties.hibernate.jdbc.batch_size=50)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.b.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -E '^PROBE ' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 0
PROBE hibernate.jdbc.batch_size 50 · hibernate.order_inserts null
PROBE rows read back: diner 100 · break_day 100
PROBE executeBatch 200
```

Each diner is followed by its break, so the next INSERT is for the other table — and a JDBC batch holds one statement text: every
switch of table sends the batch that is open, with one row in it.

**Done** when the same 200 rows go in full batches of fifty. A hint: one key lets Hibernate sort the inserts of a flush by entity
before it builds the batches — the lesson's `order` capture runs it. The solution, and what it prints, is in `SOLUTION.md`.
