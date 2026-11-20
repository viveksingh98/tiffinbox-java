# Solution - unit 18: the default run builds no MongoClient

The health key alone switches off only the indicator; the client is still built, and its monitor still tries localhost 27017. The
default run builds no MongoClient when Boot's three MongoDB auto-configurations are excluded - the list `after/`'s own
`application.yaml` holds, under `spring.autoconfigure.exclude`:
`org.springframework.boot.mongodb.autoconfigure.MongoAutoConfiguration`,
`org.springframework.boot.data.mongodb.autoconfigure.DataMongoAutoConfiguration` and
`org.springframework.boot.data.mongodb.autoconfigure.DataMongoRepositoriesAutoConfiguration` (the names Boot 4.1.2's two MongoDB jars
list). With the list, the health key has nothing to switch off. The same lines as the exercise, one line changed - the file copied is
`after/`'s:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"
EX="$PWD/.harness/ex"; rm -rf "$EX"; mkdir -p "$EX/run/secrets/tiffinbox"; rsync -a --exclude target --exclude secrets after/ "$EX/tb/"
cp after/tiffinbox-web/src/main/resources/application.yaml "$EX/tb/tiffinbox-web/src/main/resources/application.yaml"
(cd "$EX/tb" && perl -e '$SIG{INT}="DEFAULT"; alarm 600; exec @ARGV' mvn -o -q -B "-Dmaven.repo.local=$EX/../../.m2-demo" package -DskipTests -pl tiffinbox-web -am) && echo "built: $(ls "$EX/tb/tiffinbox-web/target" | grep -c '^tiffinbox-web-1.0.0.jar$') jar"
(umask 077 && openssl rand -hex 16 > "$EX/run/secrets/tiffinbox/shutdown-token")
cd "$EX/run" && { perl -e '$SIG{INT}="DEFAULT"; alarm 120; exec @ARGV' java -jar ../tb/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20579 > run.log 2>&1 & TB=$!; }
for i in $(seq 480); do kill -0 $TB 2> /dev/null || break; [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:20579/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done
echo "health: $(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:20579/actuator/health)"; kill $TB; wait $TB
echo "lines naming 27017 in the log: $(grep -c 27017 run.log)"; cd - > /dev/null
```

What it prints:

```
built: 1 jar
health: 200
lines naming 27017 in the log: 0
```

Health 200 and no line naming 27017: no MongoClient, no monitor, nothing tries the port.
