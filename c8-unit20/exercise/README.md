# Exercise - unit 20: the index that is not there

**Your turn:** on a fresh Mongo, getIndexes lists only the id index and explain says COLLSCAN, 120 documents examined. Make Mongo examine thirty.

This exercise needs Docker and a MongoDB container: an index is the server's, so a server has to hold it. The lines below start a new
one - the course's MongoDB image by its digest, with the variable the course's machine needs (`../c8-tiffinbox/compose.yaml` says why),
on `127.0.0.1:20599` - and build TiffinBox's jar from `after/`, offline, from this unit's `.m2-demo`, for its libraries and for the
shipped `OrderDocument`, whose `customer` carries `@Indexed`. `IndexedOrders.java` then starts a small Spring Boot context - MongoDB's
client and Spring Data MongoDB's template, Boot's own auto-configurations, nothing else - saves TiffinBox's orders, one per customer per
day (read off `after/`'s seed and `tiffinbox.days`), into the collection `orders`, and prints two readings: the indexes the server lists
for `orders` (`getIndexes`, through the driver's `listIndexes`), then what `explain` says a find of one customer's orders read - the
plan's stages, the documents and the keys examined, the documents returned. Run the lines from `c8-unit20/`, in bash or zsh (the first
line points at JDK 25 and at the docker socket on the author's Mac - point them at yours; on a machine without the image,
`docker -H "$DH" run` pulls it):

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
EX="$PWD/.harness/ex"; rm -rf "$EX"; mkdir -p "$EX"; rsync -a --exclude target --exclude secrets after/ "$EX/tb/"
(cd "$EX/tb" && perl -e '$SIG{INT}="DEFAULT"; alarm 600; exec @ARGV' mvn -o -q -B "-Dmaven.repo.local=$EX/../../.m2-demo" package -DskipTests -pl tiffinbox-web -am) && perl -e '$SIG{INT}="DEFAULT"; alarm 120; exec @ARGV' java -Djarmode=tools -jar "$EX/tb/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" extract --destination "$EX/x" > /dev/null && echo "built: $(ls "$EX/x" | grep -c '^tiffinbox-web-1.0.0.jar$') jar"
docker -H "$DH" run -d --name c8u20-mongo-ex -p 127.0.0.1:20599:27017 -e GLIBC_TUNABLES=glibc.pthread.rseq=1 mongo@sha256:05b334b0a7a78fe913caac0cd2e1ecccf4da515d9a3a44be911b6ea3734c17cd --unixSocketPrefix /data/db > /dev/null
perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -cp "$EX/x/tiffinbox-web-1.0.0.jar:$EX/x/lib/*" exercise/IndexedOrders.java > "$EX/run.log" 2>&1; grep -E '^(orders saved:|indexes:|explain )' "$EX/run.log"
docker -H "$DH" rm -fv c8u20-mongo-ex > /dev/null
```

What it prints:

```
built: 1 jar
orders saved: 120
indexes: [_id_]
explain find {customer: Ravi}: COLLSCAN · totalDocsExamined 120 · totalKeysExamined 0 · nReturned 30
```

`@Indexed` is on the field, and the server lists the id's index alone: the annotation asks, and nothing made the index. Without one,
the server reads every document of the collection to find one customer's. The check is the two readings in that order - first
`getIndexes`, then `explain` - never the exit of the run, and never `explain` alone: an index stays when a collection's documents are
deleted, so a container that once held it would read as solved. That is why each run starts its own container and removes it after.
Make the same lines print the index on `customer` and a plan that walks it - `SOLUTION.md` shows one way, `../c8-unit20/README.md`
(index, noindex) why.
