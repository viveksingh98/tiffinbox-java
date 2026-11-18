# Exercise — Conditional Caching, sync and Nulls

**Your turn:** a lookup for a missing customer was cached, and she stays invisible after she is added. Stop caching the empty answer.

Run it from this unit's folder (`c8-unit13/`). It needs this folder's `.m2-demo` (a copy of the course's Maven repository, offline —
`README.md`, *The repository*) and nothing else: no Docker. The database is H2 in memory and the cache is Caffeine's, in the JVM —
TiffinBox's default run — because the kept empty answer needs no store outside the JVM (`../README.md`, `nulls`, on Caffeine and on
Redis). The block copies the anchor, `after/`, to `.harness/ex/tree`, and puts this folder's `CustomerRepository.java` in it — the
anchor's file with one line changed: `findByName`'s annotation, `@Cacheable(cacheNames = "customer")`, a labelled copy. That file is
the one you change. Maven builds the jar from that tree (offline, the tests skipped, every module from the tree's own sources:
`-pl tiffinbox-web -am`), under an alarm (`perl -e 'alarm 300; exec …'`; macOS has no `timeout`). `exercise/Lookup.java` is compiled
against the jar's libraries; it starts TiffinBox's application class (its web server on `127.0.0.1:20520`, freed when it stops),
looks up Nobody, adds her with a `JdbcTemplate` insert that never passes through the cache, and looks her up again. Each lookup prints
whether she was found and the calls that reached Spring Data JPA's repository since the first lookup.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"
M="$PWD/.m2-demo"; R=tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java; rm -rf .harness/ex && mkdir -p .harness/ex/run/secrets/tiffinbox .harness/ex/hc && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
cp exercise/CustomerRepository.java .harness/ex/tree/$R; echo "unless on findByName: $(grep -c '^    @Cacheable(cacheNames = "customer", unless = "#result == null")$' .harness/ex/tree/$R)"
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" clean package -DskipTests -pl tiffinbox-web -am) > .harness/ex/build.log 2>&1; echo "Maven: exit $?"
(cd .harness/ex/tree && exec perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted) > .harness/ex/extract.log 2>&1
L=.harness/ex/tree/tiffinbox-web/target/extracted; perl -e 'alarm 120; exec @ARGV' javac -d .harness/ex/hc -cp "$L/tiffinbox-web-1.0.0.jar:$L/lib/*" exercise/Lookup.java; echo "javac: exit $?"
(umask 077 && openssl rand -hex 16 > .harness/ex/run/secrets/tiffinbox/shutdown-token)
(cd .harness/ex/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../hc:../tree/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../tree/tiffinbox-web/target/extracted/lib/*" Lookup --tiffinbox.port=20520 --logging.config=../../../harness/logback.xml) > .harness/ex/run.log 2>&1; echo "TiffinBox: exit $?"
grep -E '^(cache|lookup [12]|insert):' .harness/ex/run.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
unless on findByName: 0
Maven: exit 0
javac: exit 0
TiffinBox: exit 0
cache: CaffeineCacheManager
lookup 1: Nobody not found · repository calls 1
insert: 1 row · the table now holds Nobody: 1
lookup 2: Nobody not found · repository calls 1
```

**Done** when `lookup 2` finds her, and its repository calls have gone up by one — the second lookup reached the table. TiffinBox's
exit says nothing here: it is 0 in both states, and so is Maven's. As shipped the second lookup is a hit in Caffeine, in the JVM: the
first lookup's empty `Optional` was kept, as a holder of null, and the insert went around the cache. A hint: `@Cacheable` reads a
condition after the call as well as before it, and the cache hands that condition the value inside the `Optional`.
The solution, and what it prints, is in `SOLUTION.md`.
