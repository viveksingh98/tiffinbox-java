# Solution — Query By Example and Querydsl

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's/Example.of(probe);/Example.of(probe, ExampleMatcher.matching().withIgnorePaths("mealsPerDay", "pricePerMeal"));/' harness/src/probe/q/ex/ExApp.java > .harness/ex/ExApp.java
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.q.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|^PROBE .*)' .harness/mine.log
```

One line differs from the README's: the copy of `ExApp.java` gives the example a matcher that ignores the two fields the probe never set
(by hand: open `.harness/ex/ExApp.java` and change the one line):

```java
            Example<CustomerEntity> example = Example.of(probe, ExampleMatcher.matching().withIgnorePaths("mealsPerDay", "pricePerMeal"));
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh — compared with this block, line for line):

```
the JVM: exit 0
Found 1 JPA repository interface.
PROBE vegetarian customers: 2 · [Ravi, Sunil]
PROBE the matcher ignores: [mealsPerDay, pricePerMeal]
```

With the two paths ignored, the probe's one value left is the meal type: the query asks for vegetarian customers alone, and the seed's
two — Ravi and Sunil — come back (unit 21's `probe` A). Both runs exit 0: the broken one is told apart by what it found, never by a failure.
