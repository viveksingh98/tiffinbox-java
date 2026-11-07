# Solution — The Repository You Do Not Write

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's/^@EntityScan("com.tiffinbox")$/& @EnableJpaRepositories("com.tiffinbox")/' harness/src/probe/q/ex/ExApp.java > .harness/ex/ExApp.java
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*" probe.q.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|^APPLICATION FAILED TO START|^Parameter [0-9].*|^Consider defining.*|^PROBE ready.*)' .harness/mine.log
```

One line differs from the README's: the copy of `ExApp.java` gets the annotation beside `@EntityScan` (by hand: open
`.harness/ex/ExApp.java` and add the line under `@EntityScan("com.tiffinbox")` — the import is already there):

```java
@SpringBootApplication
@EntityScan("com.tiffinbox")
@EnableJpaRepositories("com.tiffinbox")
public class ExApp {
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh):

```
the JVM: exit 0
Found 1 JPA repository interface.
PROBE ready: the kitchen has its CustomerEntityRepository - target SimpleJpaRepository
```

`@EnableJpaRepositories("com.tiffinbox")` tells Spring Data where its repository interfaces live; it finds the one in TiffinBox's core
and builds the bean — a proxy whose target is its own `SimpleJpaRepository` — before the runner asks for it. It is the line `TiffinBoxApp`
carries since this unit, with the same value.
