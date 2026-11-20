# Solution - unit 20: the index that is not there

The mapper creates the indexes a document class asks for only when Spring Boot's key `spring.data.mongodb.auto-index-creation` is
true; Boot's default is false. TiffinBox's own `application-dev.yaml` sets it for the profile "dev". `IndexedOrders.java` reads its keys
as Boot reads them, so the solution is the key, given on its command line - the same lines, the run's one argument added, on a new
container again:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
EX="$PWD/.harness/ex"; rm -rf "$EX"; mkdir -p "$EX"; rsync -a --exclude target --exclude secrets after/ "$EX/tb/"
(cd "$EX/tb" && perl -e '$SIG{INT}="DEFAULT"; alarm 600; exec @ARGV' mvn -o -q -B "-Dmaven.repo.local=$EX/../../.m2-demo" package -DskipTests -pl tiffinbox-web -am) && perl -e '$SIG{INT}="DEFAULT"; alarm 120; exec @ARGV' java -Djarmode=tools -jar "$EX/tb/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" extract --destination "$EX/x" > /dev/null && echo "built: $(ls "$EX/x" | grep -c '^tiffinbox-web-1.0.0.jar$') jar"
docker -H "$DH" run -d --name c8u20-mongo-ex -p 127.0.0.1:20599:27017 -e GLIBC_TUNABLES=glibc.pthread.rseq=1 mongo@sha256:05b334b0a7a78fe913caac0cd2e1ecccf4da515d9a3a44be911b6ea3734c17cd --unixSocketPrefix /data/db > /dev/null
perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -cp "$EX/x/tiffinbox-web-1.0.0.jar:$EX/x/lib/*" exercise/IndexedOrders.java --spring.data.mongodb.auto-index-creation=true > "$EX/run.log" 2>&1; grep -E '^(orders saved:|indexes:|explain )' "$EX/run.log"
docker -H "$DH" rm -fv c8u20-mongo-ex > /dev/null
```

What it prints:

```
built: 1 jar
orders saved: 120
indexes: [_id_, customer]
explain find {customer: Ravi}: FETCH > IXSCAN · totalDocsExamined 30 · totalKeysExamined 30 · nReturned 30
```

The index named `customer`, made by the mapper when the context met `OrderDocument`, and a plan that walks it (`IXSCAN`) and fetches
only the documents it points to. The orders are the same; the server reads the thirty of one customer and no other.
