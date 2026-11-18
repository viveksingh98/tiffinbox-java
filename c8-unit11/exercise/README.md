# Exercise — Redis as a Cache

**Your turn:** the cached customer list comes back once, then the second read from Redis throws. Make the second read a hit.

Run it from this unit's folder (`c8-unit11/`). It needs this folder's `.m2-demo` (a copy of the course's Maven repository, offline —
`README.md`, *The repository*), Docker, and the image `redis:8-alpine` on your machine — by its tag, as the anchor's `compose.yaml`
names it; fetch it once with `docker pull redis:8-alpine` if you have not (the block itself never pulls: `--pull never`). The first
line names your Docker socket: OrbStack's on the author's Mac — point it at yours. The block starts its own Redis, a container named
`c8u11-ex-redis` published on `127.0.0.1:20502` alone, with no password, and removes it with its volume (`rm -fv`) at its end; TiffinBox's
own web server binds `127.0.0.1:20500` and frees it when TiffinBox stops. The database is H2 in memory. The block copies the anchor,
`after/`, to `.harness/ex/tree` and puts `CustomerRepository.findAll()` back to `Stream.toList()` with `harness/variants.py tolist` (the
derivation the receipt's `json` capture uses: that one statement, nothing else). Maven builds the jar from that tree (offline, the tests
skipped, every module from the tree's own sources: `-pl tiffinbox-web -am`), under an alarm (`perl -e 'alarm 300; exec …'`; macOS has no
`timeout`). The harness — this unit's program, `harness/src/probe/u11` — is compiled against the jar's libraries and starts TiffinBox's
application class with the cache's type set to `redis` and Lettuce pointed at that Redis, and calls `CustomerRepository.findAll()` twice
through the context's bean, each call in a window of its own: the calls that reached Spring Data JPA's repository, and what the call
returned or threw.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex/run/secrets/tiffinbox && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
python3 -I -B harness/variants.py tolist .harness/ex/tree > /dev/null; echo "toList() in CustomerRepository.java: $(grep -c 'toRecord).toList();$' .harness/ex/tree/tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java)"
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" clean package -DskipTests -pl tiffinbox-web -am) > .harness/ex/build.log 2>&1; echo "Maven: exit $?"
(cd .harness/ex/tree && exec perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted) > .harness/ex/extract.log 2>&1
L=.harness/ex/tree/tiffinbox-web/target/extracted; perl -e 'alarm 120; exec @ARGV' javac -d .harness/ex/hc -cp "$L/tiffinbox-web-1.0.0.jar:$L/lib/*" harness/src/probe/u11/*.java; echo "javac: exit $?"
docker -H "$DH" run -d --pull never --name c8u11-ex-redis -p 127.0.0.1:20502:6379 redis:8-alpine > /dev/null; echo "Redis: exit $?"; for i in $(seq 1 100); do [ "$(docker -H "$DH" exec c8u11-ex-redis redis-cli PING 2> /dev/null)" = PONG ] && break; sleep 0.2; done
(umask 077 && openssl rand -hex 16 > .harness/ex/run/secrets/tiffinbox/shutdown-token)
(cd .harness/ex/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../hc:../tree/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../tree/tiffinbox-web/target/extracted/lib/*" probe.u11.U11 two --tiffinbox.port=20500 --logging.config=../../../harness/logback.xml --spring.jpa.properties.hibernate.generate_statistics=true --spring.cache.type=redis --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20502) > .harness/ex/run.log 2>&1; echo "TiffinBox: exit $?"
docker -H "$DH" rm -fv c8u11-ex-redis > /dev/null; echo "Redis removed: exit $?"
grep -oE 'call [12] of CustomerRepository.findAll\(\) \(H2 [0-9.]+, Redis\): repository calls [0-9]+|(returned java[.A-Za-z$]+|threw [.A-Za-z]+: Could not read JSON: Unexpected token)' .harness/ex/run.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
toList() in CustomerRepository.java: 1
Maven: exit 0
javac: exit 0
Redis: exit 0
TiffinBox: exit 0
Redis removed: exit 0
call 1 of CustomerRepository.findAll() (H2 2.5.250, Redis): repository calls 1
returned java.util.ImmutableCollections$ListN
call 2 of CustomerRepository.findAll() (H2 2.5.250, Redis): repository calls 0
threw org.springframework.data.redis.serializer.SerializationException: Could not read JSON: Unexpected token
```

**Done** when the second call's line is `returned` and its repository calls are 0 — a hit, read back from Redis. TiffinBox's exit says
nothing here: it is 0 in both states, and so is Maven's; the first call is a miss in both and reaches the repository once. As shipped the
second call throws at the hit: the bytes Redis keeps (redis-cli's `GET` shows them) carry no class for the list, and the JSON
serializer cannot read the list back. A hint: compare the bytes Redis keeps, by `redis-cli GET`, for the anchor's list with the ones this tree's list
writes, and the class Java reads back. The solution, and what it prints, is in `SOLUTION.md`.
