# Exercise — *Distributed Locks and Rate Counters*

**Your turn:** holder A outlived its lock, B took it, then A's release deleted B's lock. Release a lock only while it is still yours.

Run it from this unit's folder (`c8-unit17/`). It needs this folder's `.m2-demo` (a copy of the course's Maven repository, offline —
`README.md`, *The repository*) and Docker: the exercise is about a key in Redis, so it needs a Redis — the image the course pinned, by
its digest, which the block starts itself (`--pull never`: it never pulls) on `127.0.0.1:20562` and removes with its volume at the end
(`rm -fv`). The block names the Docker socket as the receipts do (`docker -H "$DH"`, OrbStack's on the author's Mac — point `DH` at
yours). No TiffinBox, no web server, no database and no Spring context: `exercise/Release.java` is a small program on the anchor's
libraries — Lettuce's connection factory and Spring Data Redis's `StringRedisTemplate`, built by the program itself. The block copies
the anchor, `after/`, to `.harness/ex/tree`, and Maven builds its jar there (offline, the tests skipped, every module from the tree's own
sources: `-pl tiffinbox-web -am`) for the libraries in it; every Java and Maven run is under an alarm (`perl -e 'alarm 300; exec …'`;
macOS has no `timeout`). The lock is one key, `tiffinbox:lock:kitchen-slot`, its value the holder's name, set only if absent and with a
time to live. The program plays both holders. The program's holder A takes the lock, and then the program holds A past its lock's time to live
on purpose — it reads `EXISTS` until the key is gone, a count it caps — which is what "A outlived its lock" means here. The program's
holder B takes the lock, and then the program's A releases it, on the block's `java` line — the one line you change. Then redis-cli, the container's own client, reads the key.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex/hc && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" clean package -DskipTests -pl tiffinbox-web -am) > .harness/ex/build.log 2>&1; echo "Maven: exit $?"
(cd .harness/ex/tree && exec perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted) > .harness/ex/extract.log 2>&1
L=.harness/ex/tree/tiffinbox-web/target/extracted; perl -e 'alarm 120; exec @ARGV' javac -nowarn -d .harness/ex/hc -cp "$L/lib/*" exercise/Release.java > .harness/ex/javac.log 2>&1; echo "javac: exit $?"
docker -H "$DH" run -d --pull never --name c8u17-ex -p 127.0.0.1:20562:6379 redis@sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3 > /dev/null; echo "docker run: exit $?"
i=0; while [ "$(docker -H "$DH" exec c8u17-ex redis-cli PING 2> /dev/null)" != PONG ] && [ $i -lt 120 ]; do sleep 0.5; i=$((i + 1)); done
perl -e 'alarm 120; exec @ARGV' java -cp ".harness/ex/hc:$L/lib/*" Release 20562 del > .harness/ex/run.log 2>&1; echo "Release: exit $?"; grep -E '^(holder|the program)' .harness/ex/run.log
echo "redis-cli GET tiffinbox:lock:kitchen-slot: [$(docker -H "$DH" exec c8u17-ex redis-cli GET tiffinbox:lock:kitchen-slot | tr -d '\r')]"
docker -H "$DH" rm -fv c8u17-ex > /dev/null; echo "docker rm -fv: exit $?"
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
Maven: exit 0
javac: exit 0
docker run: exit 0
Release: exit 0
holder A: acquired true
the program holds A past its lock's time to live (EXISTS read until 0): EXISTS 0
holder B: acquired true
holder A sees, before its release: B
holder A releases by DEL: deleted true
redis-cli GET tiffinbox:lock:kitchen-slot: []
docker rm -fv: exit 0
```

**Done** when redis-cli's `GET` reads `[B]` after A's release — B's lock still there, its holder's name in it. The exit says nothing
here: the program exits zero in both states. As shipped, A releases with `DEL`, which deletes whatever the key holds when it runs: A's
own value was gone with its time to live, B's name was in the key, and A's `DEL` deleted B's lock while B believes it holds it. A hint:
a release can first read the key's value and delete it only if that value is still its own holder's name — and the read and the
delete belong in one step on the server, so nothing can take the key between them.
The solution, and what it prints, is in `SOLUTION.md`.
