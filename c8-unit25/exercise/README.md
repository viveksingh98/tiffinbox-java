# Exercise - unit 25: the order Redis did not find

**Your turn:** the harness's Redis repository finds zero orders worth two hundred forty, and MongoDB finds thirty. Make Redis find the thirty.

This exercise needs Docker and four containers of its own, the four stores TiffinBox runs on under the profile "dev": a PostgreSQL on
`127.0.0.1:20641`, a Redis on `127.0.0.1:20642`, a MongoDB on `127.0.0.1:20643` and an Elasticsearch on `127.0.0.1:20644`, by the tags
the course measured (`postgres:18-alpine`, `redis:8-alpine`, `mongo:8` and `docker.elastic.co/elasticsearch/elasticsearch:9.4.8`, at
the digests `../c8-tiffinbox/compose.yaml` names), every port on the loopback address alone, all four removed with their volumes at
the end. The PostgreSQL container trusts every connection to it, with no password: it is published on the loopback address alone.
The lines below build TiffinBox's jar from `after/`, offline, from this unit's `.m2-demo`, compile a copy of the shipped
`KitchenOrder` and `Lab25.java` against it, and start TiffinBox under "dev" on `127.0.0.1:20645` with the lab joined
(`--spring.main.sources=lab25.Lab25`) and the copy of `KitchenOrder` ahead of the jar on the class path. TiffinBox's own start seeds
its 120 kitchen orders into Redis, as it always does under "dev"; then the lab builds its repository `RValue` through Spring Data
Redis's own factory (`RedisRepositoryFactory`, never a scan), calls `findByValue(240)` once and exits. Run the lines from `c8-unit25/`,
in bash or zsh (the first line points at JDK 25 and at the docker socket on the author's Mac - point them at yours; on a machine
without the images, `docker -H "$DH" run` pulls them; a second run reuses the jar the first built under `.harness/ex` - remove that
folder to build it again):

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
EX="$PWD/.harness/ex"; mkdir -p "$EX/run/secrets/tiffinbox"; rm -rf "$EX/run.log" "$EX/cls"; [ -d "$EX/tb" ] || rsync -a --exclude target --exclude secrets after/ "$EX/tb/"
[ -f "$EX/x/tiffinbox-web-1.0.0.jar" ] || { (cd "$EX/tb" && perl -e '$SIG{INT}="DEFAULT"; alarm 600; exec @ARGV' mvn -o -q -B "-Dmaven.repo.local=$EX/../../.m2-demo" package -DskipTests -pl tiffinbox-web -am) && perl -e '$SIG{INT}="DEFAULT"; alarm 120; exec @ARGV' java -Djarmode=tools -jar "$EX/tb/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" extract --destination "$EX/x" > /dev/null; }; echo "built: $(ls "$EX/x" | grep -c '^tiffinbox-web-1.0.0.jar$') jar"
[ -s "$EX/run/secrets/tiffinbox/shutdown-token" ] || (umask 077 && openssl rand -hex 16 > "$EX/run/secrets/tiffinbox/shutdown-token")
cp exercise/KitchenOrder.java "$EX/KitchenOrder.java"
cp exercise/Lab25.java "$EX/Lab25.java"
docker -H "$DH" run -d --name c8u25-ex-pg -p 127.0.0.1:20641:5432 -e POSTGRES_DB=tiffinbox -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust postgres:18-alpine > /dev/null
docker -H "$DH" run -d --name c8u25-ex-redis -p 127.0.0.1:20642:6379 redis:8-alpine > /dev/null
docker -H "$DH" run -d --name c8u25-ex-mongo -p 127.0.0.1:20643:27017 -e GLIBC_TUNABLES=glibc.pthread.rseq=1 mongo:8 --unixSocketPrefix /data/db > /dev/null
docker -H "$DH" run -d --name c8u25-ex-es -p 127.0.0.1:20644:9200 -e discovery.type=single-node -e xpack.security.enabled=false -e xpack.ml.enabled=false -e ingest.geoip.downloader.enabled=false -e xpack.inference.elastic.authorization.enabled=false -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" docker.elastic.co/elasticsearch/elasticsearch:9.4.8 > /dev/null
perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' javac -nowarn -d "$EX/cls" -cp "$EX/x/tiffinbox-web-1.0.0.jar:$EX/x/lib/*" "$EX/KitchenOrder.java" "$EX/Lab25.java"
i=0; until [ "$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' http://127.0.0.1:20644/)" = 200 ] || [ $i -ge 480 ]; do sleep 0.5; i=$((i + 1)); done
i=0; until docker -H "$DH" exec c8u25-ex-pg pg_isready -U tiffinbox -h 127.0.0.1 -q || [ $i -ge 240 ]; do sleep 0.5; i=$((i + 1)); done
(cd "$EX/run" && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -cp "$EX/cls:$EX/x/tiffinbox-web-1.0.0.jar:$EX/x/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=20645 --spring.profiles.active=dev --spring.docker.compose.enabled=false "--tiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:20641/tiffinbox?user=tiffinbox" --spring.datasource.username=tiffinbox --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20642 --spring.mongodb.uri=mongodb://127.0.0.1:20643/tiffinbox --spring.elasticsearch.uris=http://127.0.0.1:20644 --spring.main.sources=lab25.Lab25) > "$EX/run.log" 2>&1; grep "^the lab's" "$EX/run.log"
bash exercise/check.sh "$EX/run.log"
docker -H "$DH" rm -fv c8u25-ex-pg c8u25-ex-redis c8u25-ex-mongo c8u25-ex-es > /dev/null
```

What it prints:

```
built: 1 jar
the lab's KitchenOrder: @Indexed fields [customer, mealType]
the lab's RValue (built by RedisRepositoryFactory): findByValue(240) -> 0 orders
check: the lab's call findByValue(240) -> 0 orders · redis-cli SCARD kitchen-order:value:240 0 · solved: no
```

`findByValue` is a name Spring Data Commons parses the same way for every module - `value SIMPLE_PROPERTY (1): [Is, Equals]` - and
Spring Data Redis turns it into one command, `SINTER kitchen-order:value:240`: the intersection of the index sets for that value. The
shipped `KitchenOrder` indexes `customer` and `mealType` only, so TiffinBox's seeding never wrote a `kitchen-order:value:*` set; the
command reads a set that is not there, and the lab's repository answers zero orders, with no exception. Spring Data MongoDB's
repository, given the same name, sends one `find` with the filter `{"value": 240}` and gets thirty documents (this unit's `hole`).
The check is `exercise/check.sh`: the lab's own line - the method it called, the number it asked for and what came back - AND Redis's
own answer, `redis-cli SCARD kitchen-order:value:240`, never the exit of the run (the lab exits 0 either way). Make the same lines
print `findByValue(240) -> 30 orders`, `SCARD` 30 and `solved: yes` - `SOLUTION.md` shows one way. A "solution" that calls another
method, say `findByCustomer("Ravi")`, finds thirty orders too, and fails the check: the call is not `findByValue(240)`, and the set
for 240 is still absent. One that asks for another number fails it as well. The receipt runs both, once per run of record.
