# Solution — *Distributed Locks and Rate Counters*

**Your turn:** holder A outlived its lock, B took it, then A's release deleted B's lock. Release a lock only while it is still yours.

Have A release by the Lua compare-and-delete: the block's `java` line runs the program as `lua` instead of `del`. As `lua`, A sends
Redis one script, `if redis.call('GET', KEYS[1]) == ARGV[1] then return redis.call('DEL', KEYS[1]) else return 0 end`, with the key
and its own name (`DefaultRedisScript`, Spring Data Redis's, through `StringRedisTemplate.execute`): Redis runs the `GET` and the `DEL`
as one step, so the key is deleted only while its value is still A. Here it holds B, the script returns 0 and B's lock stays. What the
release does not do: the program holds A past its lock's time to live on purpose, so A's own work still ran while B held the lock —
the two held the slot together, and the script stops only A's delete of B's lock. The block is the README's with that one line changed.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex/hc && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" clean package -DskipTests -pl tiffinbox-web -am) > .harness/ex/build.log 2>&1; echo "Maven: exit $?"
(cd .harness/ex/tree && exec perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted) > .harness/ex/extract.log 2>&1
L=.harness/ex/tree/tiffinbox-web/target/extracted; perl -e 'alarm 120; exec @ARGV' javac -nowarn -d .harness/ex/hc -cp "$L/lib/*" exercise/Release.java > .harness/ex/javac.log 2>&1; echo "javac: exit $?"
docker -H "$DH" run -d --pull never --name c8u17-ex -p 127.0.0.1:20562:6379 redis@sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3 > /dev/null; echo "docker run: exit $?"
i=0; while [ "$(docker -H "$DH" exec c8u17-ex redis-cli PING 2> /dev/null)" != PONG ] && [ $i -lt 120 ]; do sleep 0.5; i=$((i + 1)); done
perl -e 'alarm 120; exec @ARGV' java -cp ".harness/ex/hc:$L/lib/*" Release 20562 lua > .harness/ex/run.log 2>&1; echo "Release: exit $?"; grep -E '^(holder|the program)' .harness/ex/run.log
echo "redis-cli GET tiffinbox:lock:kitchen-slot: [$(docker -H "$DH" exec c8u17-ex redis-cli GET tiffinbox:lock:kitchen-slot | tr -d '\r')]"
docker -H "$DH" rm -fv c8u17-ex > /dev/null; echo "docker rm -fv: exit $?"
```

What it prints, solved (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
Maven: exit 0
javac: exit 0
docker run: exit 0
Release: exit 0
holder A: acquired true
the program holds A past its lock's time to live (EXISTS read until 0): EXISTS 0
holder B: acquired true
holder A sees, before its release: B
holder A releases by the Lua compare-and-delete: returned 0
redis-cli GET tiffinbox:lock:kitchen-slot: [B]
docker rm -fv: exit 0
```

**Done:** redis-cli's `GET` reads `[B]` after A's release, and the script returned 0 — A's release left B's lock alone, because the
key no longer held A's name. A token the store checks on every write would also refuse A's late work itself; this program builds none.
