# Solution — N+1, Measured

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's/^        return s.getQueryExecutionCount();$/        return s.getPrepareStatementCount();/' harness/src/probe/v/ex/ExApp.java > .harness/ex/ExApp.java
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=create --spring.jpa.properties.hibernate.generate_statistics=true)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.v.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -E '^PROBE ' .harness/mine.log
```

One line differs from the README's: the copy of `ExApp.java` returns `getPrepareStatementCount()` from `ExApp.count` (by hand: open
`.harness/ex/ExApp.java` and change the one line in `count`):

```java
        return s.getPrepareStatementCount();
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh — compared with this block, line for line):

```
the JVM: exit 0
PROBE diners 10 · the page's count: 11
PROBE diners 40 · the page's count: 41
```

Hibernate's statistics count every statement it prepares: the page's one query for the list, and one more for each diner whose breaks
it reads — the count grows with the diners, one plus one per diner, at 10 diners and at 40 diners. This is the counter unit 39's test
asserts, `SessionFactory.getStatistics().getPrepareStatementCount()`.
