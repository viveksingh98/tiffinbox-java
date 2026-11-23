# Exercise - unit 26: the class the repository did not find

**Your turn:** TiffinBox stops at the start, no property totalsByCustomer found for type OrderDocument. Make the repository find the class that holds that method.

This exercise needs Docker and four containers of its own, the four stores TiffinBox runs on under the profile "dev": a PostgreSQL on
`127.0.0.1:20651`, a Redis on `127.0.0.1:20652`, a MongoDB on `127.0.0.1:20653` and an Elasticsearch on `127.0.0.1:20654`, by the tags
the course measured (`postgres:18-alpine`, `redis:8-alpine`, `mongo:8` and `docker.elastic.co/elasticsearch/elasticsearch:9.4.8`, at
the digests `../c8-tiffinbox/compose.yaml` names), every port on the loopback address alone, all four removed with their volumes at
the end. The PostgreSQL container trusts every connection to it, with no password: it is published on the loopback address alone.
The lines below copy `after/` - TiffinBox after this unit's change - into `.harness/ex/tb`, put the shipped class `OrderTotalsImpl`
aside and the copy `exercise/OrderTotalsImplementation.java` in its place (the same class under another name), build that copy's jar
offline from this unit's `.m2-demo`, and start it under "dev" on `127.0.0.1:20656`. When it starts, the lines read
`GET /revenue/by-customer` and `GET /kitchen` and stop it by `POST /shutdown`. Run them from `c8-unit26/`, in bash or zsh (the first
line points at JDK 25 and at the docker socket on the author's Mac - point them at yours; on a machine without the images,
`docker -H "$DH" run` pulls them):

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
EX="$PWD/.harness/ex"; W=tiffinbox-web/src/main/java/com/tiffinbox/web; rm -rf "$EX/tb" "$EX/x" "$EX/build.log" "$EX/run.log" "$EX/route.txt"; mkdir -p "$EX/run/secrets/tiffinbox"; rsync -a --exclude target --exclude secrets after/ "$EX/tb/"; rm "$EX/tb/$W/OrderTotalsImpl.java"
cp exercise/OrderTotalsImplementation.java "$EX/tb/$W/OrderTotalsImplementation.java"
(cd "$EX/tb" && perl -e '$SIG{INT}="DEFAULT"; alarm 600; exec @ARGV' mvn -o -q -B "-Dmaven.repo.local=$EX/../../.m2-demo" package -DskipTests -pl tiffinbox-web -am > "$EX/build.log" 2>&1) && perl -e '$SIG{INT}="DEFAULT"; alarm 120; exec @ARGV' java -Djarmode=tools -jar "$EX/tb/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" extract --destination "$EX/x" > /dev/null; echo "built: $(ls "$EX/x" 2> /dev/null | grep -c '^tiffinbox-web-1.0.0.jar$') jar"
[ -s "$EX/run/secrets/tiffinbox/shutdown-token" ] || (umask 077 && openssl rand -hex 16 > "$EX/run/secrets/tiffinbox/shutdown-token")
docker -H "$DH" run -d --name c8u26-ex-pg -p 127.0.0.1:20651:5432 -e POSTGRES_DB=tiffinbox -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust postgres:18-alpine > /dev/null
docker -H "$DH" run -d --name c8u26-ex-redis -p 127.0.0.1:20652:6379 redis:8-alpine > /dev/null
docker -H "$DH" run -d --name c8u26-ex-mongo -p 127.0.0.1:20653:27017 -e GLIBC_TUNABLES=glibc.pthread.rseq=1 mongo:8 --unixSocketPrefix /data/db > /dev/null
docker -H "$DH" run -d --name c8u26-ex-es -p 127.0.0.1:20654:9200 -e discovery.type=single-node -e xpack.security.enabled=false -e xpack.ml.enabled=false -e ingest.geoip.downloader.enabled=false -e xpack.inference.elastic.authorization.enabled=false -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" docker.elastic.co/elasticsearch/elasticsearch:9.4.8 > /dev/null
i=0; until [ "$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' http://127.0.0.1:20654/)" = 200 ] || [ $i -ge 480 ]; do sleep 0.5; i=$((i + 1)); done
i=0; until docker -H "$DH" exec c8u26-ex-pg pg_isready -U tiffinbox -h 127.0.0.1 -q || [ $i -ge 240 ]; do sleep 0.5; i=$((i + 1)); done
P=""; if [ -f "$EX/x/tiffinbox-web-1.0.0.jar" ]; then (cd "$EX/run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -cp "$EX/x/tiffinbox-web-1.0.0.jar:$EX/x/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=20656 --spring.profiles.active=dev --spring.docker.compose.enabled=false "--tiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:20651/tiffinbox?user=tiffinbox" --spring.datasource.username=tiffinbox --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20652 --spring.mongodb.uri=mongodb://127.0.0.1:20653/tiffinbox --spring.elasticsearch.uris=http://127.0.0.1:20654) > "$EX/run.log" 2>&1 & P=$!; fi
i=0; while [ -n "$P" ] && kill -0 "$P" 2> /dev/null && [ "$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' http://127.0.0.1:20656/actuator/health/readiness)" != 200 ] && [ $i -lt 480 ]; do sleep 0.5; i=$((i + 1)); done
if [ -n "$P" ] && kill -0 "$P" 2> /dev/null; then { curl -s --noproxy '*' http://127.0.0.1:20656/revenue/by-customer; echo; curl -s --noproxy '*' http://127.0.0.1:20656/kitchen; echo; } > "$EX/route.txt"; head -1 "$EX/run/secrets/tiffinbox/shutdown-token" | sed 's/^/X-Shutdown-Token: /' | curl -s --noproxy '*' -o /dev/null -H @- -X POST http://127.0.0.1:20656/shutdown; fi; [ -z "$P" ] || wait "$P"
bash exercise/check.sh "$EX"
docker -H "$DH" rm -fv c8u26-ex-pg c8u26-ex-redis c8u26-ex-mongo c8u26-ex-es > /dev/null
```

What it prints:

```
built: 1 jar
check: the start: failed - No property 'totalsByCustomer' found for type 'OrderDocument' · the route: none · solved: no
```

`OrderDocuments` extends two interfaces: `MongoRepository`, Spring Data MongoDB's, and `OrderTotals`, a repository fragment. For a
fragment, Spring Data Commons looks in the repository's package for a class named after the interface with its postfix, `Impl` by
default - `OrderTotalsImpl`. In this copy no class has that name: Commons composes the repository without the fragment, and Spring Data
MongoDB parses `totalsByCustomer` as a derived method's name - a subject, then a property - and finds no property of that name on
`OrderDocument`. The repository's bean is never made, and the start stops (this unit's `misnamed`, the same tree built by the receipt).
The check is `exercise/check.sh`: the start's own outcome, read off TiffinBox's log, AND the route's four totals with their sum beside
`/kitchen`'s `ordersValue`, never the exit of a run. Make the same lines print `the start: started`, the four totals, the sum `24300`
and `solved: yes` - `SOLUTION.md` shows one way. A "solution" that deletes the method from the class builds no jar - the class no
longer implements `OrderTotals` - and fails the check. The receipt runs it three times, once per run of record each.
