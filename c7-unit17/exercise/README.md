# Exercise — @Query: JPQL and Native

**Your turn:** the README's query names its parameter, and this build cannot tell which argument it is. Make the name reach the query.

Run it from this unit's folder (`c7-unit17/`) after `./receipts.sh` has run once: it builds `.harness/after` (the anchor after this
unit's change, copied, its jar extracted — among its libraries `tiffinbox-core-1.0.0.jar`, with TiffinBox's entities and the shipped
`Database`). The block copies the exercise's application, `harness/src/probe/q/ex/ExApp.java`, to `.harness/ex/` and compiles it
there **with plain `javac`** — no `-parameters`, so the class file keeps no parameter names. It is a Spring Boot application with no
web server, in its own package, `probe.q.ex`, that maps TiffinBox's entities (`@EntityScan("com.tiffinbox")`), seeds its own H2
database with the shipped `Database` (Ravi, Meera, Sunil, Priya), and carries a repository of its own in the same file —
`interface Customers extends JpaRepository<CustomerEntity, Long>` with one JPQL query, `select c from CustomerEntity c where
c.mealType = :type order by c.name`, on the method `byType(MealType type)` — and one runner, `kitchen`, that asks it for the VEG
customers. Then one JVM starts it, under an alarm (`perl -e 'alarm 120; exec …'`: macOS has no `timeout`), its arguments in an array,
`A`, so bash and zsh pass each one as one argument; the database is H2, in that JVM's memory. It binds no port and stops on its own;
a run that fails prints its exception and each cause, one line each. The last line keeps the lines that matter from its log.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/q/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*" probe.q.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|^PROBE .*)' .harness/mine.log
```

What it prints, as shipped, is `../receipts.sh`'s capture `exercise` (in bash and in zsh; its block in `../README.md`, section 9).

The application starts — Hibernate checked the JPQL at start, and `:type` is a fine name — and the runner calls `byType(VEG)`. Only
then does Spring Data look for the argument named `type`: the method has no `@Param`, and a class compiled without `-parameters`
keeps no names (`javap -v` finds no `MethodParameters` in it), so the call fails before any SQL is sent. Unit 17's `jpql` capture
shows the same query on a build compiled with `-parameters` (it binds) and on one without (the same failure).

**Done** when the JVM prints `exit 0` and the runner's line with the VEG customers. The solution, and what it prints, is in `SOLUTION.md`.
