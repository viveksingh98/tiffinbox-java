# Solution — Bulk Updates and the Stale Context

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's/^    @Modifying$/    @Modifying(clearAutomatically = true)/' harness/src/probe/q/ex/ExApp.java > .harness/ex/ExApp.java
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none --spring.jpa.properties.hibernate.generate_statistics=true)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.q.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|^PROBE .*)' .harness/mine.log
```

One line differs from the README's: the copy of `ExApp.java` asks Spring Data to clear the persistence context after the bulk update
(by hand: open `.harness/ex/ExApp.java` and change the one line above `@Query`):

```java
    @Modifying(clearAutomatically = true)
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh — compared with this block, line for line):

```
the JVM: exit 0
Found 1 JPA repository interface.
PROBE Ravi before the update: mealsPerDay 2
PROBE the update changed 4 rows
PROBE findById(1) after the update: mealsPerDay 3 · statements it ran: 1
```

With the context cleared after the update, the loaded Ravi is detached, so `findById` finds nothing in the context and goes to the
database: a SELECT this time, and the new number (unit 22's `clear` capture, A). Both runs exit 0: the broken one is told apart by the value
it read and the statement it did not run, never by a failure.
