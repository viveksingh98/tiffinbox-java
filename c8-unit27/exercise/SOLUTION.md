# Exercise - unit 27: one way to solve it

Remove the bean: the copy goes without `LocalCacheConfig`. With no `CacheManager` bean of TiffinBox's own, Boot's
`CacheAutoConfiguration` runs under "dev" as it does in the shipped tree: it makes `CacheProperties`, `RedisCaching` builds its
configuration from it, and Boot builds the one `RedisCacheManager`. The start completes, the first read goes to PostgreSQL and its
list to Redis, the second is answered from Redis. The lines are `README.md`'s, with one line changed: the class is removed from the
copy instead of copied into it. Run them from `c8-unit27/`:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
EX="$PWD/.harness/ex"; W=tiffinbox-web/src/main/java/com/tiffinbox/web; rm -rf "$EX/tb" "$EX/x" "$EX/build.log" "$EX/run.log" "$EX/run/application-dev.properties"; mkdir -p "$EX/run/secrets/tiffinbox"; rsync -a --exclude target --exclude secrets after/ "$EX/tb/"
rm -f "$EX/tb/$W/LocalCacheConfig.java"
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
check: the start: started · DEL customers::SimpleKey [] -> 1 · GET /customers twice: PostgreSQL 3 then 0 statements · Redis EXISTS customers::SimpleKey [] -> 1 · solved: yes
```

Not offered here: a `CachingConfigurer` whose `cacheManager()` names one of two managers. This unit measured another `CacheManager`
bean only; that shape was not captured, and the bean's removal is the measured fix.
