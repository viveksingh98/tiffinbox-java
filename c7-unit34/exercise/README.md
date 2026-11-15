# Exercise — Reading the SQL Hibernate Writes

**Your turn:** the README's schema script has no index on a pause's customer. Add one in the mapping, so Hibernate's script creates it.

Run it from this unit's folder (`c7-unit34/`) after `./receipts.sh` has run once: it builds `.harness/after` (TiffinBox as this unit
leaves it, copied, its jar extracted — its libraries are Spring Boot's, Spring Data's, Hibernate's and H2's). The block copies the
exercise's application, `harness/src/probe/q/ex/ExApp.java`, to `.harness/ex/` and compiles it there. It is a Spring Boot application
with no web server, in its own package, `probe.q.ex`, with two entities of its own — `Diner` (a name: this exercise's customer) and
`Break` (a diner's days off, its own table `break_day`: this exercise's pause). The break owns the foreign key, `@ManyToOne` with
`@JoinColumn(name = "diner_id")`, as TiffinBox's pause does. Hibernate writes its schema script for the two entities to a file,
`.harness/ex/ddl.sql` (`scripts.action=create`; nothing runs it, `ddl-auto=none`), in this JVM's own H2 database in memory — no port, no
container, never TiffinBox's tables. The runner reads the file back and prints how many lines it has, the lines that hold `index`, and
the file's md5. One JVM, under an alarm (`perl -e 'alarm 120; exec …'`: macOS has no `timeout`), its arguments in an array, `A`, so bash
and zsh pass each one as one argument. It binds no port and stops on its own. The last line keeps the runner's lines from its log.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/q/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=../ex/ddl.sql)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*" probe.q.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -E '^PROBE ' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 0
PROBE Hibernate's schema script: 3 lines · lines with "index": 0 · md5 13401762a6f471154830cd96790e4660
```

The script holds the two tables and the foreign key from `break_day` to `diner` — and no index on `diner_id`. H2 would make one for the
constraint by itself; PostgreSQL would not, and a diner's breaks would then be read by scanning the whole table.

**Done** when Hibernate's script holds one line more: an index on `break_day (diner_id)`. A hint: the mapping says it in the entity's
`@Table` annotation — the lesson's `PauseEntity` does. The solution, and what it prints, is in `SOLUTION.md`.
