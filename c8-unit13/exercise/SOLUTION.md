# Solution — Conditional Caching, sync and Nulls

**Your turn:** a lookup for a missing customer was cached, and she stays invisible after she is added. Stop caching the empty answer.

Keep the empty answer out of the cache: `unless = "#result == null"` on `findByName`'s `@Cacheable` in
`exercise/CustomerRepository.java` — the anchor's own line. `unless` is read after the call, against the value the cache would keep;
for a method that returns an `Optional` the cache unwraps it, so `#result` is the customer, or null when there is none, and an empty
answer is not stored. `sync = true` cannot sit beside it (`../README.md`, `syncunless`: the first call throws). The block is the
README's with one line changed: the copy of `CustomerRepository.java` takes the attribute in, and the count of the line is printed as
before.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"
M="$PWD/.m2-demo"; R=tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java; rm -rf .harness/ex && mkdir -p .harness/ex/run/secrets/tiffinbox .harness/ex/hc && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
sed 's|^    @Cacheable(cacheNames = "customer")$|    @Cacheable(cacheNames = "customer", unless = "#result == null")|' exercise/CustomerRepository.java > .harness/ex/tree/$R; echo "unless on findByName: $(grep -c '^    @Cacheable(cacheNames = "customer", unless = "#result == null")$' .harness/ex/tree/$R)"
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" clean package -DskipTests -pl tiffinbox-web -am) > .harness/ex/build.log 2>&1; echo "Maven: exit $?"
(cd .harness/ex/tree && exec perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted) > .harness/ex/extract.log 2>&1
L=.harness/ex/tree/tiffinbox-web/target/extracted; perl -e 'alarm 120; exec @ARGV' javac -d .harness/ex/hc -cp "$L/tiffinbox-web-1.0.0.jar:$L/lib/*" exercise/Lookup.java; echo "javac: exit $?"
(umask 077 && openssl rand -hex 16 > .harness/ex/run/secrets/tiffinbox/shutdown-token)
(cd .harness/ex/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../hc:../tree/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../tree/tiffinbox-web/target/extracted/lib/*" Lookup --tiffinbox.port=20520 --logging.config=../../../harness/logback.xml) > .harness/ex/run.log 2>&1; echo "TiffinBox: exit $?"
grep -E '^(cache|lookup [12]|insert):' .harness/ex/run.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
unless on findByName: 1
Maven: exit 0
javac: exit 0
TiffinBox: exit 0
cache: CaffeineCacheManager
lookup 1: Nobody not found · repository calls 1
insert: 1 row · the table now holds Nobody: 1
lookup 2: Nobody found · repository calls 2
```

**Done:** `lookup 2` finds her, and the repository calls went up by one — the lookup after the insert reached the table,
because the cache held nothing for that name. The insert itself is unchanged; only the empty answer was not kept.
