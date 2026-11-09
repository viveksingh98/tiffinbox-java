# Exercise — Query By Example and Querydsl

**Your turn:** the README searches by example for vegetarian customers and finds nobody. Make the example ignore what you never set.

Run it from this unit's folder (`c7-unit21/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (Section 3's frozen
anchor, copied, its jar extracted — among its libraries `tiffinbox-core-1.0.0.jar`, with TiffinBox's entities and the shipped
`Database`). The block copies the exercise's application, `harness/src/probe/q/ex/ExApp.java`, to `.harness/ex/` and compiles it
there. It is a Spring Boot application with no web server, in its own package, `probe.q.ex`, that maps TiffinBox's entities
(`@EntityScan("com.tiffinbox")`), seeds its own H2 database with the shipped `Database` (Ravi, Meera, Sunil, Priya), and carries a
repository of its own in the same file — `interface Customers extends JpaRepository<CustomerEntity, Long>`, whose Query by Example
methods it inherits — and one runner, `search`: a probe, the example object, `new CustomerEntity(null, 0, 0, MealType.VEG)` — only the
meal type set, the constructor's two `int`s at zero — and `Example.of(probe)`. It prints the vegetarian customers it found and the paths
its matcher ignores. One JVM starts it, under an alarm (`perl -e 'alarm 120; exec …'`: macOS has no `timeout`), its arguments in an
array, `A`, so bash and zsh pass each one as one argument; the database is H2, in that JVM's memory. It binds no port and stops on its
own. The last line keeps the lines that matter from its log: Spring Data's scan line and the runner's.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/q/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.q.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|^PROBE .*)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 0
Found 1 JPA repository interface.
PROBE vegetarian customers: 0 · []
PROBE the matcher ignores: []
```

The application starts, Spring Data finds the repository (`Found 1`), the query runs — and nobody is vegetarian. Nothing failed: the
probe's `name` and `id` are `null` and Spring Data leaves them out, but `mealsPerDay` and `pricePerMeal` are `int`s, and zero is a
value, so the query asks for vegetarian customers who eat 0 meals a day at 0 a meal. Unit 21's `probe` capture shows the SQL (B), in its
normal form.

**Done** when the JVM prints `exit 0` and the runner finds the vegetarian customers the seed holds. The solution, and what it prints, is
in `SOLUTION.md`.
