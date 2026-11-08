# Solution — Paging and Sorting

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's/@Query("select c from/@Query("select distinct c from/' harness/src/probe/q/ex/ExApp.java > .harness/ex/ExApp.java
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.q.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(^PROBE .*|org\.hibernate\.SQL : .*)' .harness/mine.log
```

One line differs from the README's: the copy of `ExApp.java` asks for `select distinct c` (by hand: open `.harness/ex/ExApp.java` and
add `distinct` to the query):

```java
    @Query("select distinct c from CustomerEntity c join c.pauses p where p.days >= :d")
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh — compared with this block, line for line):

```
the JVM: exit 0
org.hibernate.SQL : select distinct ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 join pause p1_0 on ce1_0.id=p1_0.customer_id where p1_0.days>=? order by ce1_0.id desc fetch first ? rows only
org.hibernate.SQL : select count(distinct ce1_0.id) from customer ce1_0 join pause p1_0 on ce1_0.id=p1_0.customer_id where p1_0.days>=?
PROBE total 2 · pages 1 · content [Priya, Sunil]
```

With `distinct` in the query, Spring Data derives `count(distinct …)` for the page's count: each customer counted once, the total is
two, one page. The content is the same two customers — only the count changed.
