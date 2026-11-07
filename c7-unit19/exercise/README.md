# Exercise — Projections: Four Kinds

**Your turn:** the README's projection selects every column to show two. Make the SELECT ask only for the name and the meal type.

Run it from this unit's folder (`c7-unit19/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (Section 3's frozen
anchor, copied, its jar extracted — among its libraries `tiffinbox-core-1.0.0.jar`, with TiffinBox's entities and the shipped
`Database`). The block copies the exercise's application, `harness/src/probe/q/ex/ExApp.java`, to `.harness/ex/` and compiles it
there. It is a Spring Boot application with no web server, in its own package, `probe.q.ex`, that maps TiffinBox's entities
(`@EntityScan("com.tiffinbox")`), seeds its own H2 database with the shipped `Database` (Ravi, Meera, Sunil, Priya), and carries a
repository of its own in the same file — `interface Customers extends JpaRepository<CustomerEntity, Long>` with one derived query,
`List<Row> findRowsByMealType(MealType type)` — and one runner, `list`, that prints the vegetarian customers as `name mealType`
labels. The screen needs two fields. `Row` is the projection, and it has one getter:

```java
    @Value("#{target.name + ' ' + target.mealType}") String getLabel();
```

One JVM starts it, under an alarm (`perl -e 'alarm 120; exec …'`: macOS has no `timeout`), its arguments in an array, `A`, so bash
and zsh pass each one as one argument; the database is H2, in that JVM's memory. It binds no port and stops on its own; a run that
fails prints its exception and each cause, one line each. The last line keeps the lines that matter from its log: Spring Data's scan
line, Hibernate's SQL line and the runner's.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/q/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.q.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|^PROBE .*|org\.hibernate\.SQL : .*)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 0
Found 1 JPA repository interface.
org.hibernate.SQL : select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where ce1_0.meal_type=?
PROBE rows: [Ravi VEG, Sunil VEG]
```

It works — and that is the trap. The labels are right, but the SELECT names every column the entity maps: `@Value` is a SpEL
expression over `target`, the whole entity, so Spring Data cannot tell which fields it reads and asks Hibernate for the entity (an
open projection; `../receipts.sh`'s `four` shows the same SELECT for the open interface, and its entity loads).

**Done** when the JVM prints `exit 0`, the same two labels, and one SQL line whose column list is the name's and the meal type's
columns alone. The solution, and what it prints, is in `SOLUTION.md`.
