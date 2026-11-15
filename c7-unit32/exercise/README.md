# Exercise — The Second-Level Cache

**Your turn:** the README's cache keeps serving Ravi's old meals after a plain JDBC update changed them. Make the next read see the database.

Run it from this unit's folder (`c7-unit32/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (TiffinBox as unit 31
left it, copied, its jar extracted — its libraries are Spring Boot's, Spring Data's, Hibernate's and H2's) and `.harness/cache-caffeine`
(the jars the cache adds: Hibernate's JCache module and Caffeine's provider, copied from this unit's `.m2-demo`). The block copies the
exercise's application, `harness/src/probe/k/ex/ExApp.java`, to `.harness/ex/` and compiles it there. It is a Spring Boot application
with no web server, in its own package, `probe.k.ex`, with one entity of its own — `Diner` (a name and meals a day), cached:
`@Cacheable` and `@Cache(usage = READ_WRITE)` — on a table Hibernate creates in this JVM's own H2 database (`ddl-auto=create`, the
exercise's own table, never TiffinBox's). The runner stores Ravi, reads him in a transaction of its own, changes his meals with plain
JDBC — a second `java.sql.Connection` on the same URL, a write Hibernate never sees — and reads him again in a new transaction. Each
read prints the meals it got and the region's hit and miss counts (Hibernate's statistics, cleared before each read). The second-level
cache is switched on by the arguments: the four keys and `missing_cache_strategy=create`. One JVM, under an alarm (`perl -e 'alarm 120;
exec …'`: macOS has no `timeout`), its arguments in an array, `A`, so bash and zsh pass each one as one argument. It binds no port and
stops on its own. The last line keeps the runner's lines from its log.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/k/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=create --spring.jpa.properties.hibernate.generate_statistics=true --spring.jpa.properties.hibernate.cache.use_second_level_cache=true --spring.jpa.properties.hibernate.cache.region.factory_class=jcache --spring.jpa.properties.hibernate.javax.cache.provider=com.github.benmanes.caffeine.jcache.spi.CaffeineCachingProvider --spring.jpa.properties.jakarta.persistence.sharedCache.mode=ENABLE_SELECTIVE --spring.jpa.properties.hibernate.javax.cache.missing_cache_strategy=create)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*:../cache-caffeine/*" probe.k.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -E '^PROBE ' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 0
PROBE read 1: Ravi's meals 2 · region hit 0 · miss 1
PROBE plain JDBC set Ravi's meals to 3
PROBE read 2: Ravi's meals 2 · region hit 1 · miss 0
```

The first read misses the region and puts Ravi in it. Plain JDBC changes his meals in the table, and Hibernate never hears of it: the
second read, in a new transaction, is a hit — the region answers, no SELECT is sent, and the value is the one Hibernate last read.

**Done** when the second read prints the value plain JDBC wrote, and it is a miss: the region asked the database again. A hint: the
`EntityManagerFactory` has a `getCache()`, and the cache can forget one entity by its class and its id. The solution, and what it
prints, is in `SOLUTION.md`.
