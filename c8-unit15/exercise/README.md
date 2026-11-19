# Exercise — Spring Data Redis Repositories

**Your turn:** the kitchen orders reached their time to live, yet count() still counts them and findAll() returns nulls. Make the running repository forget them.

Run it from this unit's folder (`c8-unit15/`). It needs this folder's `.m2-demo` (a copy of the course's Maven repository, offline —
`README.md`, *The repository*) and Docker: the exercise is about what a Redis repository leaves in Redis, so it needs a Redis — the
image the course pinned, by its digest, which the block starts itself (`--pull never`: it never pulls) on `127.0.0.1:20542` and removes
with its volume at the end (`rm -fv`). The block names the Docker socket as the receipts do (`docker -H "$DH"`, OrbStack's on the
author's Mac — point `DH` at yours). No TiffinBox and no database: `exercise/Rail.java` is a small Spring context of its own on the
anchor's libraries and the anchor's own `KitchenOrder` and `KitchenOrders`. The block copies the anchor, `after/`, to
`.harness/ex/tree`, and Maven builds its jar there (offline, the tests skipped, every module from the tree's own sources:
`-pl tiffinbox-web -am`) for the classes and libraries in it; every Java and Maven run is under an alarm (`perl -e 'alarm 300; exec …'`;
macOS has no `timeout`). `Rail.java` saves three orders through the repository — two with a time to live (its own setting, `TTL`,
never printed) and one with none — and stays up: it reads from Java until both timed hashes are gone, reads `SCARD kitchen-order` until
the untimed order is alone in it or its cap of reads is reached, and prints what `count()` and `findAll()` say. Then redis-cli, the
container's own client, reads the ids' set and the meal type's index set. The file you change is the copy the block takes,
`exercise/Rail.java`: the repository configuration on its one marked line, `RailConfig`'s `@EnableRedisRepositories`.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex/hc && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
cp exercise/Rail.java .harness/ex/Rail.java; echo "ON_STARTUP in Rail.java: $(grep -c '^@EnableRedisRepositories(basePackageClasses = KitchenOrders.class, enableKeyspaceEvents = EnableKeyspaceEvents.ON_STARTUP)$' .harness/ex/Rail.java)"
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" clean package -DskipTests -pl tiffinbox-web -am) > .harness/ex/build.log 2>&1; echo "Maven: exit $?"
(cd .harness/ex/tree && exec perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted) > .harness/ex/extract.log 2>&1
L=.harness/ex/tree/tiffinbox-web/target/extracted; perl -e 'alarm 120; exec @ARGV' javac -d .harness/ex/hc -cp "$L/tiffinbox-web-1.0.0.jar:$L/lib/*" .harness/ex/Rail.java; echo "javac: exit $?"
docker -H "$DH" run -d --pull never --name c8u15-ex -p 127.0.0.1:20542:6379 redis@sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3 > /dev/null; echo "docker run: exit $?"
i=0; while [ "$(docker -H "$DH" exec c8u15-ex redis-cli PING 2> /dev/null)" != PONG ] && [ $i -lt 120 ]; do sleep 0.5; i=$((i + 1)); done
perl -e 'alarm 120; exec @ARGV' java -cp ".harness/ex/hc:$L/tiffinbox-web-1.0.0.jar:$L/lib/*" Rail after/tiffinbox-core/src/main/resources/db/migration/V2__seed.sql 20542 > .harness/ex/run.log 2>&1; echo "Rail: exit $?"; grep -E '^(keyspace events|orders saved|the timed hashes|SCARD|count|findAll)' .harness/ex/run.log
echo "redis-cli SCARD kitchen-order: $(docker -H "$DH" exec c8u15-ex redis-cli SCARD kitchen-order | tr -d '\r')"; echo "redis-cli SMEMBERS kitchen-order:mealType:VEG: ($(docker -H "$DH" exec c8u15-ex redis-cli SMEMBERS kitchen-order:mealType:VEG | tr -d '\r' | sort | paste -sd' ' -))"
docker -H "$DH" rm -fv c8u15-ex > /dev/null; echo "docker rm -fv: exit $?"
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
ON_STARTUP in Rail.java: 0
Maven: exit 0
javac: exit 0
docker run: exit 0
Rail: exit 0
keyspace events (CONFIG GET notify-keyspace-events): ""
orders saved: 3 (o1 and o2 with a time to live, o3 with none) · count() 3
the timed hashes gone (EXISTS kitchen-order:o1, kitchen-order:o2: 0), the JVM still up
SCARD kitchen-order, read until it holds the untimed order alone (a cap of 50 reads): not reached, 3
count(): 3
findAll(): [null, null, KitchenOrder[o3,Meera,NON_VEG,150]]
redis-cli SCARD kitchen-order: 3
redis-cli SMEMBERS kitchen-order:mealType:VEG: (o1 o2)
docker rm -fv: exit 0
```

**Done** when `count()` counts the untimed order alone, `findAll()` holds no null, and redis-cli's `SCARD kitchen-order` agrees —
with the JVM up after both timed hashes are gone: the hash is gone (`EXISTS` zero) and so is its id. `Rail`'s exit says nothing here:
it is zero in both states, and no exception is thrown in either. As shipped the repository runs with keyspace events off, Spring Data
Redis's default: when a hash's time to live ends Redis removes the hash, and nothing removes its id from `kitchen-order` or from the
index sets, so `count()` (`SCARD`) still counts it and `findAll()` returns a null where its hash was (`../README.md`, `stale`). A hint:
`@EnableRedisRepositories` has a setting that starts a listener with the repository, one Redis tells when a hash is gone.
The solution, and what it prints, is in `SOLUTION.md`.
