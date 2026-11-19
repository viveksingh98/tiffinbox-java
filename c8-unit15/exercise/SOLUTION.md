# Solution — Spring Data Redis Repositories

**Your turn:** the kitchen orders reached their time to live, yet count() still counts them and findAll() returns nulls. Make the running repository forget them.

Start the repository with keyspace events on: the one marked line of `exercise/Rail.java` becomes
`@EnableRedisRepositories(basePackageClasses = KitchenOrders.class, enableKeyspaceEvents = EnableKeyspaceEvents.ON_STARTUP)` — the
setting the anchor's `RedisDatastore` ships. With it the repository writes `notify-keyspace-events` on the server (`CONFIG SET`; redis-cli
reads it back) and starts a listener: when Redis tells it a hash is gone, it removes the id from `kitchen-order` and from the index sets.
Its condition: it removes only what it hears while it is running. A stale index left while nothing listened stays as it was under a
fresh JVM that only listens (`../README.md`, `nolisten`); here it is cleaned because the start saves the same ids again and stays up
across their time to live — as TiffinBox's start does under the profile "dev", the same ids every start. The block is the README's
with one line changed: the copy of `Rail.java` takes the new line in, and the count of the line is printed as before.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex/hc && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
sed 's|^@EnableRedisRepositories(basePackageClasses = KitchenOrders.class)$|@EnableRedisRepositories(basePackageClasses = KitchenOrders.class, enableKeyspaceEvents = EnableKeyspaceEvents.ON_STARTUP)|' exercise/Rail.java > .harness/ex/Rail.java; echo "ON_STARTUP in Rail.java: $(grep -c '^@EnableRedisRepositories(basePackageClasses = KitchenOrders.class, enableKeyspaceEvents = EnableKeyspaceEvents.ON_STARTUP)$' .harness/ex/Rail.java)"
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" clean package -DskipTests -pl tiffinbox-web -am) > .harness/ex/build.log 2>&1; echo "Maven: exit $?"
(cd .harness/ex/tree && exec perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted) > .harness/ex/extract.log 2>&1
L=.harness/ex/tree/tiffinbox-web/target/extracted; perl -e 'alarm 120; exec @ARGV' javac -d .harness/ex/hc -cp "$L/tiffinbox-web-1.0.0.jar:$L/lib/*" .harness/ex/Rail.java; echo "javac: exit $?"
docker -H "$DH" run -d --pull never --name c8u15-ex -p 127.0.0.1:20542:6379 redis@sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3 > /dev/null; echo "docker run: exit $?"
i=0; while [ "$(docker -H "$DH" exec c8u15-ex redis-cli PING 2> /dev/null)" != PONG ] && [ $i -lt 120 ]; do sleep 0.5; i=$((i + 1)); done
perl -e 'alarm 120; exec @ARGV' java -cp ".harness/ex/hc:$L/tiffinbox-web-1.0.0.jar:$L/lib/*" Rail after/tiffinbox-core/src/main/resources/db/migration/V2__seed.sql 20542 > .harness/ex/run.log 2>&1; echo "Rail: exit $?"; grep -E '^(keyspace events|orders saved|the timed hashes|SCARD|count|findAll)' .harness/ex/run.log
echo "redis-cli SCARD kitchen-order: $(docker -H "$DH" exec c8u15-ex redis-cli SCARD kitchen-order | tr -d '\r')"; echo "redis-cli SMEMBERS kitchen-order:mealType:VEG: ($(docker -H "$DH" exec c8u15-ex redis-cli SMEMBERS kitchen-order:mealType:VEG | tr -d '\r' | sort | paste -sd' ' -))"
docker -H "$DH" rm -fv c8u15-ex > /dev/null; echo "docker rm -fv: exit $?"
```

What it prints, solved (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
ON_STARTUP in Rail.java: 1
Maven: exit 0
javac: exit 0
docker run: exit 0
Rail: exit 0
keyspace events (CONFIG GET notify-keyspace-events): "xE"
orders saved: 3 (o1 and o2 with a time to live, o3 with none) · count() 3
the timed hashes gone (EXISTS kitchen-order:o1, kitchen-order:o2: 0), the JVM still up
SCARD kitchen-order, read until it holds the untimed order alone (a cap of 50 reads): reached, 1
count(): 1
findAll(): [KitchenOrder[o3,Meera,NON_VEG,150]]
redis-cli SCARD kitchen-order: 1
redis-cli SMEMBERS kitchen-order:mealType:VEG: ()
docker rm -fv: exit 0
```

**Done:** `count()` counts the untimed order alone, `findAll()` holds it and no null, and redis-cli's `SCARD kitchen-order` agrees, the
meal type's index set gone with the timed ids — read with the JVM up, after both timed hashes are gone. The saves are unchanged: the same
three orders, the same ids, the same time to live; only the listener the repository starts moved.
