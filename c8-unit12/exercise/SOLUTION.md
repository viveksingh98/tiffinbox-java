# Solution — Cache Invalidation

**Your turn:** a JdbcTemplate update changed Ravi's meals, and the cached list still shows the old number. Make the next read show it.

Empty the `customers` cache on the write path, right after the update: `caches.getCache("customers").clear();` — the line
`Meals.java` carries commented out. `clear()` removes every entry of that cache, as `add`'s `@CacheEvict(allEntries = true)` does: the
list's key is `SimpleKey []`, never the update's own values, so a key-by-key evict would have to name it (`evict(SimpleKey.EMPTY)`), and
the shipped form follows `add`'s. On Caffeine `clear()` empties the cache before it returns. The block is the README's with one line
changed: the copy of `Meals.java` takes that line in, and the count of the line is printed as before.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex/run/secrets/tiffinbox .harness/ex/hc && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" clean package -DskipTests -pl tiffinbox-web -am) > .harness/ex/build.log 2>&1; echo "Maven: exit $?"
(cd .harness/ex/tree && exec perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted) > .harness/ex/extract.log 2>&1
sed 's#^        // caches.getCache("customers").clear();$#        caches.getCache("customers").clear();#' exercise/Meals.java > .harness/ex/Meals.java; echo "clear() on the write path in Meals.java: $(grep -c '^        caches.getCache("customers").clear();$' .harness/ex/Meals.java)"
L=.harness/ex/tree/tiffinbox-web/target/extracted; perl -e 'alarm 120; exec @ARGV' javac -d .harness/ex/hc -cp "$L/tiffinbox-web-1.0.0.jar:$L/lib/*" .harness/ex/Meals.java; echo "javac: exit $?"
(umask 077 && openssl rand -hex 16 > .harness/ex/run/secrets/tiffinbox/shutdown-token)
(cd .harness/ex/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../hc:../tree/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../tree/tiffinbox-web/target/extracted/lib/*" Meals --tiffinbox.port=20510 --logging.config=../../../harness/logback.xml) > .harness/ex/run.log 2>&1; echo "TiffinBox: exit $?"
grep -E '^(cache|read [12]|update):' .harness/ex/run.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
Maven: exit 0
clear() on the write path in Meals.java: 1
javac: exit 0
TiffinBox: exit 0
cache: CaffeineCacheManager
read 1: Ravi's meals 2 · repository calls 1
update: 1 row · the table now says 3
read 2: Ravi's meals 3 · repository calls 2
```

**Done:** `read 2` shows the number the update wrote, and the repository calls went up by one — the read after the update reached
the table, because the cache held nothing for it. The update itself is unchanged; only the cache was told.
