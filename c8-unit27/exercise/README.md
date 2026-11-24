# Exercise - unit 27: the second cache manager

**Your turn:** TiffinBox's dev start stops, no bean of type CacheProperties. Remove the bean that made Boot's cache configuration back off.

This exercise needs Docker and four containers of its own, the four stores TiffinBox runs on under the profile "dev": a PostgreSQL on
`127.0.0.1:20661`, a Redis on `127.0.0.1:20662`, a MongoDB on `127.0.0.1:20663` and an Elasticsearch on `127.0.0.1:20664`, by the tags
the course measured (`postgres:18-alpine`, `redis:8-alpine`, `mongo:8` and `docker.elastic.co/elasticsearch/elasticsearch:9.4.8`, at
the digests `../c8-tiffinbox/compose.yaml` names), every port on the loopback address alone, all four removed with their volumes at
the end. The PostgreSQL container logs every statement it runs (`log_statement=all`), and it trusts every connection to it, with no
password: it is published on the loopback address alone. The lines below copy `after/` - TiffinBox after this unit's change - into
`.harness/ex/tb` and add `exercise/LocalCacheConfig.java` to that copy: a configuration class for the profile, whose bean is another
`CacheManager`, named `localCaches`. They build the copy's jar offline from this unit's `.m2-demo` and start it under "dev" on
`127.0.0.1:20666`. Then `exercise/check.sh` reads the start's outcome. On a started TiffinBox it deletes the customer list's key first
(`redis-cli DEL 'customers::SimpleKey []'` - the start's own read cached the list). Next it sends `GET /customers` twice and counts
PostgreSQL's statements between markers in that database's own log. Last it reads the key back with `redis-cli EXISTS`. Run them from
`c8-unit27/`, in bash or zsh (the first line points at JDK 25 and at the docker socket on the author's Mac - point them at yours; on a
machine without the images, `docker -H "$DH" run` pulls them):

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
EX="$PWD/.harness/ex"; W=tiffinbox-web/src/main/java/com/tiffinbox/web; rm -rf "$EX/tb" "$EX/x" "$EX/build.log" "$EX/run.log" "$EX/run/application-dev.properties"; mkdir -p "$EX/run/secrets/tiffinbox"; rsync -a --exclude target --exclude secrets after/ "$EX/tb/"
cp exercise/LocalCacheConfig.java "$EX/tb/$W/LocalCacheConfig.java"
(cd "$EX/tb" && perl -e '$SIG{INT}="DEFAULT"; alarm 600; exec @ARGV' mvn -o -q -B "-Dmaven.repo.local=$EX/../../.m2-demo" package -DskipTests -pl tiffinbox-web -am > "$EX/build.log" 2>&1) && perl -e '$SIG{INT}="DEFAULT"; alarm 120; exec @ARGV' java -Djarmode=tools -jar "$EX/tb/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" extract --destination "$EX/x" > /dev/null; echo "built: $(ls "$EX/x" 2> /dev/null | grep -c '^tiffinbox-web-1.0.0.jar$') jar"
[ -s "$EX/run/secrets/tiffinbox/shutdown-token" ] || (umask 077 && openssl rand -hex 16 > "$EX/run/secrets/tiffinbox/shutdown-token")
docker -H "$DH" run -d --name c8u27-ex-pg -p 127.0.0.1:20661:5432 -e POSTGRES_DB=tiffinbox -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust postgres:18-alpine -c log_statement=all > /dev/null
docker -H "$DH" run -d --name c8u27-ex-redis -p 127.0.0.1:20662:6379 redis:8-alpine > /dev/null
docker -H "$DH" run -d --name c8u27-ex-mongo -p 127.0.0.1:20663:27017 -e GLIBC_TUNABLES=glibc.pthread.rseq=1 mongo:8 --unixSocketPrefix /data/db > /dev/null
docker -H "$DH" run -d --name c8u27-ex-es -p 127.0.0.1:20664:9200 -e discovery.type=single-node -e xpack.security.enabled=false -e xpack.ml.enabled=false -e ingest.geoip.downloader.enabled=false -e xpack.inference.elastic.authorization.enabled=false -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" docker.elastic.co/elasticsearch/elasticsearch:9.4.8 > /dev/null
i=0; until [ "$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' http://127.0.0.1:20664/)" = 200 ] || [ $i -ge 480 ]; do sleep 0.5; i=$((i + 1)); done
i=0; until docker -H "$DH" exec c8u27-ex-pg pg_isready -U tiffinbox -h 127.0.0.1 -q || [ $i -ge 240 ]; do sleep 0.5; i=$((i + 1)); done
P=""; if [ -f "$EX/x/tiffinbox-web-1.0.0.jar" ]; then (cd "$EX/run" && exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -cp "$EX/x/tiffinbox-web-1.0.0.jar:$EX/x/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=20666 --spring.profiles.active=dev --spring.docker.compose.enabled=false "--tiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:20661/tiffinbox?user=tiffinbox" --spring.datasource.username=tiffinbox --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20662 --spring.mongodb.uri=mongodb://127.0.0.1:20663/tiffinbox --spring.elasticsearch.uris=http://127.0.0.1:20664) > "$EX/run.log" 2>&1 & P=$!; fi
i=0; while [ -n "$P" ] && kill -0 "$P" 2> /dev/null && [ "$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' http://127.0.0.1:20666/actuator/health/readiness)" != 200 ] && [ $i -lt 480 ]; do sleep 0.5; i=$((i + 1)); done
bash exercise/check.sh "$EX" "$DH"
if [ -n "$P" ] && kill -0 "$P" 2> /dev/null; then head -1 "$EX/run/secrets/tiffinbox/shutdown-token" | sed 's/^/X-Shutdown-Token: /' | curl -s --noproxy '*' -o /dev/null -H @- -X POST http://127.0.0.1:20666/shutdown; fi; [ -z "$P" ] || wait "$P"
docker -H "$DH" rm -fv c8u27-ex-pg c8u27-ex-redis c8u27-ex-mongo c8u27-ex-es > /dev/null
```

What it prints:

```
built: 1 jar
check: the start: failed - Parameter 0 of method redisCacheConfiguration in com.tiffinbox.web.RedisCaching required a bean of type 'org.springframework.boot.cache.autoconfigure.CacheProperties' that could not be found. · the reads: none · solved: no
```

The profile's cache manager is Boot's `RedisCacheManager`: `RedisCaching`, a configuration class of TiffinBox's own, gives it a JSON
serializer from Boot's `CacheProperties`. Boot's `CacheAutoConfiguration` makes `CacheProperties`, and it backs off when the context
already holds a bean of type `CacheManager` - `localCaches` is one. So `RedisCaching`'s method finds no `CacheProperties`, and the start
stops (this unit's `twocaches`, the same shape as the harness's bean). The check is `exercise/check.sh`: the start's own outcome, read
off TiffinBox's log, AND the two reads counted in PostgreSQL's log AND the list's key in Redis - never the exit of a run. Make the same
lines print `the start: started`, PostgreSQL `3` then `0` statements, `EXISTS` `1` and `solved: yes` - `SOLUTION.md` shows one way. A
"solution" that keeps the class and switches the dev cache type to `caffeine` starts, and the list never reaches Redis: it fails the
check. The receipt runs it three times, once per run of record each.
