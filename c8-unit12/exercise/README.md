# Exercise — Cache Invalidation

**Your turn:** a JdbcTemplate update changed Ravi's meals, and the cached list still shows the old number. Make the next read show it.

Run it from this unit's folder (`c8-unit12/`). It needs this folder's `.m2-demo` (a copy of the course's Maven repository, offline —
`README.md`, *The repository*) and nothing else: no Docker. The database is H2 in memory and the cache is Caffeine's, in the JVM —
TiffinBox's default run — because the stale read needs no store outside the JVM: the write goes around the cache, and any cache serves
the old list (`../README.md`, `pinned`, on three stores). The block copies the anchor, `after/`, to `.harness/ex/tree`; Maven builds the
jar from that tree (offline, the tests skipped, every module from the tree's own sources: `-pl tiffinbox-web -am`), under an alarm
(`perl -e 'alarm 300; exec …'`; macOS has no `timeout`). `exercise/Meals.java` — the program you change — is compiled against the
jar's libraries; it starts TiffinBox's application class (its web server on `127.0.0.1:20510`, freed when it stops), reads the
customer list, changes Ravi's meals with a `JdbcTemplate` update that never passes through the cache, and reads the list again. Each
read prints Ravi's meals and the calls that reached Spring Data JPA's repository since the first read.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex/run/secrets/tiffinbox .harness/ex/hc && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" clean package -DskipTests -pl tiffinbox-web -am) > .harness/ex/build.log 2>&1; echo "Maven: exit $?"
(cd .harness/ex/tree && exec perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted) > .harness/ex/extract.log 2>&1
cp exercise/Meals.java .harness/ex/Meals.java; echo "clear() on the write path in Meals.java: $(grep -c '^        caches.getCache("customers").clear();$' .harness/ex/Meals.java)"
L=.harness/ex/tree/tiffinbox-web/target/extracted; perl -e 'alarm 120; exec @ARGV' javac -d .harness/ex/hc -cp "$L/tiffinbox-web-1.0.0.jar:$L/lib/*" .harness/ex/Meals.java; echo "javac: exit $?"
(umask 077 && openssl rand -hex 16 > .harness/ex/run/secrets/tiffinbox/shutdown-token)
(cd .harness/ex/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../hc:../tree/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../tree/tiffinbox-web/target/extracted/lib/*" Meals --tiffinbox.port=20510 --logging.config=../../../harness/logback.xml) > .harness/ex/run.log 2>&1; echo "TiffinBox: exit $?"
grep -E '^(cache|read [12]|update):' .harness/ex/run.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
Maven: exit 0
clear() on the write path in Meals.java: 0
javac: exit 0
TiffinBox: exit 0
cache: CaffeineCacheManager
read 1: Ravi's meals 2 · repository calls 1
update: 1 row · the table now says 3
read 2: Ravi's meals 2 · repository calls 1
```

**Done** when `read 2` shows the number the update wrote, and its repository calls have gone up by one — the second read reached the
table. TiffinBox's exit says nothing here: it is 0 in both states, and so is Maven's. As shipped the second read is a hit in Caffeine, in the JVM: the update
went around the cache, nothing told the cache, and the list it keeps is the one the first read returned. A hint: TiffinBox's own write,
`CustomerRepository.add`, carries `@CacheEvict(cacheNames = "customers", allEntries = true)` — the cache is emptied on its write path.
The solution, and what it prints, is in `SOLUTION.md`.
