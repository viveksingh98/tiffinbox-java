# Solution — Projections: Four Kinds

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's/    @Value(.*) String getLabel();/    String getName(); MealType getMealType(); default String getLabel() { return getName() + " " + getMealType(); }/' harness/src/probe/q/ex/ExApp.java > .harness/ex/ExApp.java
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.q.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|^PROBE .*|org\.hibernate\.SQL : .*)' .harness/mine.log
```

One line differs from the README's: the copy of `ExApp.java` makes `Row` a closed projection — two getters named after the entity's
properties, and the label built from them in a `default` method instead of a SpEL expression (by hand: open `.harness/ex/ExApp.java`
and change `Row`'s one line):

```java
    String getName(); MealType getMealType(); default String getLabel() { return getName() + " " + getMealType(); }
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh — compared with this block, line for line):

```
the JVM: exit 0
Found 1 JPA repository interface.
org.hibernate.SQL : select ce1_0.name,ce1_0.meal_type from customer ce1_0 where ce1_0.meal_type=?
PROBE rows: [Ravi VEG, Sunil VEG]
```

Every getter Spring Data must fill now names a property — `getName()`, `getMealType()` — so it asks Hibernate for those columns
alone; the `default` method is plain Java, run on the proxy, and reads nothing from the database. The record does the same:
`record Row(String name, MealType mealType)` with the label built where it is printed (`../receipts.sh`'s `four`, its record row).
