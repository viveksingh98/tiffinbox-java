# Solution — Caffeine

**Your turn:** Caffeine counts the customer list's hits, yet the prometheus endpoint has no cache line. Make its hits appear there.

`spring.cache.cache-names: customers` in `application.yaml` makes the customers cache when TiffinBox starts, and Micrometer reports the
caches named at the start: their hits, misses, size and evictions become lines of `/actuator/prometheus`. Without it the
`CaffeineCacheManager` makes the cache at the first call, Caffeine still counts, and Micrometer is never told about it. Put the line
back: here the block keeps `after/` as shipped — the line the README's copy took out. The block is the README's with one line changed:
the derivation is not run, and the count of the line is printed as before.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex/run/secrets/tiffinbox && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
echo "cache-names lines in application.yaml: $(grep -c '^    cache-names: customers$' .harness/ex/tree/tiffinbox-web/src/main/resources/application.yaml)"
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" clean package -DskipTests -pl tiffinbox-web -am) > .harness/ex/build.log 2>&1; echo "Maven: exit $?"
(cd .harness/ex/tree && exec perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted) > .harness/ex/extract.log 2>&1
L=.harness/ex/tree/tiffinbox-web/target/extracted; perl -e 'alarm 120; exec @ARGV' javac -d .harness/ex/hc -cp "$L/tiffinbox-web-1.0.0.jar:$L/lib/*" harness/src/probe/u10/*.java; echo "javac: exit $?"
(umask 077 && openssl rand -hex 16 > .harness/ex/run/secrets/tiffinbox/shutdown-token)
(cd .harness/ex/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../hc:../tree/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../tree/tiffinbox-web/target/extracted/lib/*" probe.u10.U10 reads,scrape --tiffinbox.port=20492 --logging.config=../../../harness/logback.xml --spring.jpa.properties.hibernate.generate_statistics=true) > .harness/ex/run.log 2>&1; echo "TiffinBox: exit $?"
grep -oE 'hitCount=[0-9]+, missCount=[0-9]+|GET /actuator/prometheus -> [0-9]+ · cache_ lines [0-9]+ · cache_ lines for customers [0-9]+|cache_gets_total\{[^}]*result="hit"\} [0-9.]+' .harness/ex/run.log
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
cache-names lines in application.yaml: 1
Maven: exit 0
javac: exit 0
TiffinBox: exit 0
hitCount=4, missCount=1
GET /actuator/prometheus -> 200 · cache_ lines 6 · cache_ lines for customers 6
cache_gets_total{cache="customers",cache_manager="cacheManager",name="customers",result="hit"} 4.0
```

The five calls are one miss and four hits on Caffeine's own counts, in both states; with the name given at the start the same counts
reach the endpoint, Caffeine's hit line among them. The check is the prometheus line of the cache named at the start and Caffeine's
count, never the exit: both runs exit 0.
