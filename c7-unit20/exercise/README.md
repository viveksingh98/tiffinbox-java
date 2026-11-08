# Exercise — Paging and Sorting

**Your turn:** the README pages customers who took a pause, and the page counts one customer twice. Make the count count customers.

Run it from this unit's folder (`c7-unit20/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (Section 3's frozen
anchor, copied, its jar extracted — among its libraries `tiffinbox-core-1.0.0.jar`, with TiffinBox's entities and the shipped
`Database`). The block copies the exercise's application, `harness/src/probe/q/ex/ExApp.java`, to `.harness/ex/` and compiles it
there. It is a Spring Boot application with no web server, in its own package, `probe.q.ex`, that maps TiffinBox's entities
(`@EntityScan("com.tiffinbox")`), seeds its own H2 database with the shipped `Database` (Ravi, Meera, Sunil, Priya; Sunil's pause of
three days and Priya's of two), gives Sunil a second pause (four days), and carries a repository of its own in the same file:

```java
    @Query("select c from CustomerEntity c join c.pauses p where p.days >= :d")
    Page<CustomerEntity> pausedSince(@Param("d") int d, Pageable pageable);
```

Its one runner asks for the customers with a pause of at least two days, `PageRequest.of(0, 2, Sort.by(Sort.Direction.DESC, "id"))`
— a page of two, because a page 0 that is not full needs no count and Spring Data runs none (at a page of ten both versions say 2).
Two customers match: Sunil and Priya.

One JVM starts it, under an alarm (`perl -e 'alarm 120; exec …'`: macOS has no `timeout`), its arguments in an array, `A`, so bash
and zsh pass each one as one argument; the database is H2, in that JVM's memory. It binds no port and stops on its own. The last
line keeps the lines that matter from its log: Hibernate's two SQL lines and the runner's.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/q/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.q.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(^PROBE .*|org\.hibernate\.SQL : .*)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 0
org.hibernate.SQL : select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 join pause p1_0 on ce1_0.id=p1_0.customer_id where p1_0.days>=? order by ce1_0.id desc fetch first ? rows only
org.hibernate.SQL : select count(ce1_0.id) from customer ce1_0 join pause p1_0 on ce1_0.id=p1_0.customer_id where p1_0.days>=?
PROBE total 3 · pages 2 · content [Priya, Sunil]
```

Two customers, and the page says three. The content is right — Hibernate hands back each customer once — but the count Spring Data
derives from the query counts the join's rows, and Sunil has two pauses that match.

**Done** when the JVM prints `exit 0`, the same two customers, and a total of two. The solution, and what it prints, is in `SOLUTION.md`.
