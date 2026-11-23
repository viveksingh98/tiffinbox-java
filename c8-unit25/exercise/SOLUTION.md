# Exercise - unit 25: one solution

Index the property the finder reads. Spring Data Redis answers a derived finder from the index sets its entity's `@Indexed` fields
make - one set per value, holding the ids that have it - so the copy of `KitchenOrder` gets `@Indexed` on `value`, the annotation
`customer` and `mealType` already carry (its import is already in the file). TiffinBox's own seeding then writes a
`kitchen-order:value:*` set for every value it saves, and the same `findByValue(240)` reads thirty ids out of
`kitchen-order:value:240`. The lines are the README's, with the one line that copies `KitchenOrder` changed:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
EX="$PWD/.harness/ex"; mkdir -p "$EX/run/secrets/tiffinbox"; rm -rf "$EX/run.log" "$EX/cls"; [ -d "$EX/tb" ] || rsync -a --exclude target --exclude secrets after/ "$EX/tb/"
[ -f "$EX/x/tiffinbox-web-1.0.0.jar" ] || { (cd "$EX/tb" && perl -e '$SIG{INT}="DEFAULT"; alarm 600; exec @ARGV' mvn -o -q -B "-Dmaven.repo.local=$EX/../../.m2-demo" package -DskipTests -pl tiffinbox-web -am) && perl -e '$SIG{INT}="DEFAULT"; alarm 120; exec @ARGV' java -Djarmode=tools -jar "$EX/tb/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" extract --destination "$EX/x" > /dev/null; }; echo "built: $(ls "$EX/x" | grep -c '^tiffinbox-web-1.0.0.jar$') jar"
[ -s "$EX/run/secrets/tiffinbox/shutdown-token" ] || (umask 077 && openssl rand -hex 16 > "$EX/run/secrets/tiffinbox/shutdown-token")
perl -pe 's/^    private int value;$/    \@Indexed\n    private int value;/' exercise/KitchenOrder.java > "$EX/KitchenOrder.java"
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
the lab's KitchenOrder: @Indexed fields [customer, mealType, value]
the lab's RValue (built by RedisRepositoryFactory): findByValue(240) -> 30 orders
check: the lab's call findByValue(240) -> 30 orders · redis-cli SCARD kitchen-order:value:240 30 · solved: yes
```

The method's name did not change and the number did not change: the module's request did - the same `SINTER`, on a set that now
exists. The shipped `KitchenOrder` in `../c8-tiffinbox` is unchanged; this unit changes no anchor file.
