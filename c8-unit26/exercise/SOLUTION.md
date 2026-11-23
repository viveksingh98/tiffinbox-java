# Exercise - unit 26: one way to solve it

Give the class the name Commons looks for: `OrderTotalsImpl`, the fragment interface's name and the default postfix. Commons then
finds it in the repository's package, puts it in the repository's composition before `SimpleMongoRepository`, and the repository
hands `totalsByCustomer()` to it - the start completes and the route answers the four totals. The lines are `README.md`'s, with one
line changed: the copy goes in under the class's right name, its class and constructor renamed. Run them from `c8-unit26/`:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
EX="$PWD/.harness/ex"; W=tiffinbox-web/src/main/java/com/tiffinbox/web; rm -rf "$EX/tb" "$EX/x" "$EX/build.log" "$EX/run.log" "$EX/route.txt"; mkdir -p "$EX/run/secrets/tiffinbox"; rsync -a --exclude target --exclude secrets after/ "$EX/tb/"; rm "$EX/tb/$W/OrderTotalsImpl.java"
sed 's/OrderTotalsImplementation/OrderTotalsImpl/' exercise/OrderTotalsImplementation.java > "$EX/tb/$W/OrderTotalsImpl.java"
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
check: the start: started · the route: Sunil 9000, Ravi 7200, Meera 4500, Priya 3600 · their sum 24300 · /kitchen's ordersValue 24300 · solved: yes
```

Not offered here: a `repositoryImplementationPostfix` on an `@EnableMongoRepositories` of your own, which would let another name
through. This unit measured no such annotation - an `@Enable...Repositories` switches Boot's own repository scan off for that module,
and its effect on TiffinBox's six repositories was not captured. The class's name is the measured fix.
