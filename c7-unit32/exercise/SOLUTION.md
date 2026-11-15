# Solution — The Second-Level Cache

One line changes in the block: the copy of `ExApp.java` becomes a `sed` that puts
`emf.getCache().evict(Diner.class, id);` where the source says `// after the outside write` — right after the plain JDBC update.
`getCache()` is JPA's `jakarta.persistence.Cache` over Hibernate's second-level cache; `evict(Diner.class, id)` drops that one entity
from its region, so the next read misses and asks the database. The id is the one the runner read back by Ravi's name.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's#^            // after the outside write$#            emf.getCache().evict(Diner.class, id);#' harness/src/probe/k/ex/ExApp.java > .harness/ex/ExApp.java
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=create --spring.jpa.properties.hibernate.generate_statistics=true --spring.jpa.properties.hibernate.cache.use_second_level_cache=true --spring.jpa.properties.hibernate.cache.region.factory_class=jcache --spring.jpa.properties.hibernate.javax.cache.provider=com.github.benmanes.caffeine.jcache.spi.CaffeineCachingProvider --spring.jpa.properties.jakarta.persistence.sharedCache.mode=ENABLE_SELECTIVE --spring.jpa.properties.hibernate.javax.cache.missing_cache_strategy=create)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*:../cache-caffeine/*" probe.k.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -E '^PROBE ' .harness/mine.log
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh, in the same shell right after the README's lines):

```
the JVM: exit 0
PROBE read 1: Ravi's meals 2 · region hit 0 · miss 1
PROBE plain JDBC set Ravi's meals to 3
PROBE read 2: Ravi's meals 3 · region hit 0 · miss 1
```

The second read misses and prints what plain JDBC wrote. An eviction is a step you write after a write you know Hibernate did not see;
a write you do not know of — another program on the same database — stays out of reach of any line in this application.
Course 8's lesson called Cache Invalidation takes that up.
