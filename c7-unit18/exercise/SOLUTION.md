# Solution — Criteria API and Specifications

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's/Specification.where(byType).and(byName).and(byMeals);/Specification.allOf(filters);/' harness/src/probe/q/ex/ExApp.java > .harness/ex/ExApp.java
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.q.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|^PROBE .*|org\.hibernate\.SQL : .*)' .harness/mine.log
```

One line differs from the README's: the copy of `ExApp.java` combines the list it already built — the filters the search has — with
`Specification.allOf` (by hand: open `.harness/ex/ExApp.java` and change the one line):

```java
            Specification<CustomerEntity> spec = Specification.allOf(filters);
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh — compared with this block, line for line):

```
the JVM: exit 0
Found 1 JPA repository interface.
org.hibernate.SQL : select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where lower(ce1_0.name) like ? escape '' and ce1_0.meals_per_day>=?
PROBE customers: [Ravi]
```

`filters` holds `byName` and `byMeals` — `byType` was left out when the list was built, because it is `null` — so `allOf` combines
two conditions with `and`, and the meal type is simply not in the SQL. Ravi is the one customer with an `r` in his name and at least
two meals a day. With no filter at all, `allOf` of an empty list is the search with no `where` clause (unit 18's `spec`, its first row).
