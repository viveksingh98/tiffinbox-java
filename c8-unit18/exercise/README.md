# Exercise - unit 18: the default run builds no MongoClient

**Your turn:** the default run keeps no Mongo, yet its log still tries localhost 27017. Make the default run build no MongoClient.

This exercise needs no Docker and no MongoDB: it is about TiffinBox's default run, which keeps no Mongo. `application.yaml` here is
`after/`'s with one change, the broken state - Boot's three MongoDB auto-configurations are not excluded, and MongoDB's health
indicator is switched off instead (`management.health.mongodb.enabled: false`). On the default run health answers 200, so the run looks clean; the log
says otherwise. The lines below build TiffinBox's jar with that file, offline, from this unit's `.m2-demo`, start it with no profile
on H2, read its health, stop it, and count the log's lines that name 27017. Run them from `c8-unit18/`, in bash or zsh (the first line points at JDK 25 on the author's Mac - point it at yours):

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"
EX="$PWD/.harness/ex"; rm -rf "$EX"; mkdir -p "$EX/run/secrets/tiffinbox"; rsync -a --exclude target --exclude secrets after/ "$EX/tb/"
cp exercise/application.yaml "$EX/tb/tiffinbox-web/src/main/resources/application.yaml"
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
lines naming 27017 in the log: 2
```

Health 200 and lines that name 27017: the client is built and its monitor tries localhost 27017, though nothing here keeps a Mongo.
The check is the log's count beside health, never the exit of the run. Change `exercise/application.yaml` until the same lines print
health 200 and no line naming 27017 - `SOLUTION.md` shows one way, `../c8-unit18/README.md` (default) why.
