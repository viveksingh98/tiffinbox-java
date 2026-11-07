# Solution — @Query: JPQL and Native

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's/byType(MealType type)/byType(@Param("type") MealType type)/' harness/src/probe/q/ex/ExApp.java > .harness/ex/ExApp.java
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*" probe.q.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|^PROBE .*)' .harness/mine.log
```

One line differs from the README's: the copy of `ExApp.java` gives the parameter its name — `@Param("type")`, from
`org.springframework.data.repository.query.Param`, already imported (by hand: open `.harness/ex/ExApp.java` and add it):

```java
    @Query("select c from CustomerEntity c where c.mealType = :type order by c.name")
    List<CustomerEntity> byType(@Param("type") MealType type);
```

What it prints is `../receipts.sh`'s capture `exercise`, in the same shell, after the README's lines (in bash and in zsh; its block
in `../README.md`, section 9).

`@Param("type")` is part of the class file whatever `javac` was told, so the name reaches the query: Hibernate's SQL is `select …
from customer ce1_0 where ce1_0.meal_type=? order by ce1_0.name`, `VEG` its parameter, and the runner gets the two VEG customers back.
The other way out is compiling with `-parameters` — Boot's parent POM does it for TiffinBox's own build (`<parameters>true</parameters>`).
