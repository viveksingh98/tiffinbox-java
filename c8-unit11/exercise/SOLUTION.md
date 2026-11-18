# Solution — Redis as a Cache

**Your turn:** the cached customer list comes back once, then the second read from Redis throws. Make the second read a hit.

`CustomerRepository.findAll()` collects the list into an `ArrayList` in the anchor (`Collectors.toCollection(ArrayList::new)`): the
JSON serializer writes an `ArrayList` with its class beside it (`["java.util.ArrayList",[…]]`) and reads it back as one, so the second
call is a hit, read back from Redis. `Stream.toList()`'s list is written as a bare array, each element with its `@class` but the list with none, and the
serializer, which expects a type id first, throws at the hit, in Redis's cache. Put the `ArrayList` back: here the block keeps `after/` as shipped — the
statement the README's copy took out. The block is the README's with one line changed: the derivation is not run, and the count of the
`toList()` statement is printed as before.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex/run/secrets/tiffinbox && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
echo "toList() in CustomerRepository.java: $(grep -c 'toRecord).toList();$' .harness/ex/tree/tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java)"
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" clean package -DskipTests -pl tiffinbox-web -am) > .harness/ex/build.log 2>&1; echo "Maven: exit $?"
(cd .harness/ex/tree && exec perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted) > .harness/ex/extract.log 2>&1
L=.harness/ex/tree/tiffinbox-web/target/extracted; perl -e 'alarm 120; exec @ARGV' javac -d .harness/ex/hc -cp "$L/tiffinbox-web-1.0.0.jar:$L/lib/*" harness/src/probe/u11/*.java; echo "javac: exit $?"
docker -H "$DH" run -d --pull never --name c8u11-ex-redis -p 127.0.0.1:20502:6379 redis:8-alpine > /dev/null; echo "Redis: exit $?"; for i in $(seq 1 100); do [ "$(docker -H "$DH" exec c8u11-ex-redis redis-cli PING 2> /dev/null)" = PONG ] && break; sleep 0.2; done
(umask 077 && openssl rand -hex 16 > .harness/ex/run/secrets/tiffinbox/shutdown-token)
(cd .harness/ex/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../hc:../tree/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../tree/tiffinbox-web/target/extracted/lib/*" probe.u11.U11 two --tiffinbox.port=20500 --logging.config=../../../harness/logback.xml --spring.jpa.properties.hibernate.generate_statistics=true --spring.cache.type=redis --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20502) > .harness/ex/run.log 2>&1; echo "TiffinBox: exit $?"
docker -H "$DH" rm -fv c8u11-ex-redis > /dev/null; echo "Redis removed: exit $?"
grep -oE 'call [12] of CustomerRepository.findAll\(\) \(H2 [0-9.]+, Redis\): repository calls [0-9]+|(returned java[.A-Za-z$]+|threw [.A-Za-z]+: Could not read JSON: Unexpected token)' .harness/ex/run.log
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
toList() in CustomerRepository.java: 0
Maven: exit 0
javac: exit 0
Redis: exit 0
TiffinBox: exit 0
Redis removed: exit 0
call 1 of CustomerRepository.findAll() (H2 2.5.250, Redis): repository calls 1
returned java.util.ArrayList
call 2 of CustomerRepository.findAll() (H2 2.5.250, Redis): repository calls 0
returned java.util.ArrayList
```

The first call is a miss in both states and reaches the repository once; with the `ArrayList` the second is a hit — 0 repository
calls, the list read back from Redis as an `ArrayList`. The check is the second call's line and its repository calls, never the exit:
both runs exit 0.
