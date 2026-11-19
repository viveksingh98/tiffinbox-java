# Exercise — Pub/Sub and Streams

**Your turn:** a consumer died holding three kitchen events, and XPENDING still lists them. Have a second consumer take them and acknowledge them.

Run it from this unit's folder (`c8-unit16/`). It needs this folder's `.m2-demo` (a copy of the course's Maven repository, offline —
`README.md`, *The repository*) and Docker: the exercise is about what a consumer group keeps in Redis, so it needs a Redis — the image
the course pinned, by its digest, which the block starts itself (`--pull never`: it never pulls) on `127.0.0.1:20552` and removes with
its volume at the end (`rm -fv`). The block names the Docker socket as the receipts do (`docker -H "$DH"`, OrbStack's on the author's
Mac — point `DH` at yours). No TiffinBox, no database and no Spring context: `exercise/Pending.java` is a small program on the anchor's
libraries — Lettuce's connection factory and Spring Data Redis's `StringRedisTemplate`, built by the program itself. The block copies
the anchor, `after/`, to `.harness/ex/tree`, and Maven builds its jar there (offline, the tests skipped, every module from the tree's own
sources: `-pl tiffinbox-web -am`) for the libraries in it; every Java and Maven run is under an alarm (`perl -e 'alarm 300; exec …'`;
macOS has no `timeout`). The program runs twice. First as `died`: it adds five kitchen events to `tiffinbox:kitchen-events`, creates
the group `kitchen` from the stream's first entry, and consumer `c1` reads all five, acknowledges two and exits — a JVM that ends with
three entries never acknowledged, so no signal is needed. Then as the second consumer, `c2`, on the block's last `java` line — the one
line you change. Each run prints what Java read and the group's pending list as Java reads it; then redis-cli, the container's own
client, reads the pending list's count (`XPENDING`'s first line) and the stream's length.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex/hc && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" clean package -DskipTests -pl tiffinbox-web -am) > .harness/ex/build.log 2>&1; echo "Maven: exit $?"
(cd .harness/ex/tree && exec perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted) > .harness/ex/extract.log 2>&1
L=.harness/ex/tree/tiffinbox-web/target/extracted; perl -e 'alarm 120; exec @ARGV' javac -nowarn -d .harness/ex/hc -cp "$L/lib/*" exercise/Pending.java > .harness/ex/javac.log 2>&1; echo "javac: exit $?"
docker -H "$DH" run -d --pull never --name c8u16-ex -p 127.0.0.1:20552:6379 redis@sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3 > /dev/null; echo "docker run: exit $?"
i=0; while [ "$(docker -H "$DH" exec c8u16-ex redis-cli PING 2> /dev/null)" != PONG ] && [ $i -lt 120 ]; do sleep 0.5; i=$((i + 1)); done
perl -e 'alarm 120; exec @ARGV' java -cp ".harness/ex/hc:$L/lib/*" Pending 20552 died > .harness/ex/died.log 2>&1; echo "Pending died: exit $?"; grep -E '^(events added|the pending list)' .harness/ex/died.log
echo "redis-cli XPENDING tiffinbox:kitchen-events kitchen (its count): $(docker -H "$DH" exec c8u16-ex redis-cli XPENDING tiffinbox:kitchen-events kitchen | head -1 | tr -d '\r')"
perl -e 'alarm 120; exec @ARGV' java -cp ".harness/ex/hc:$L/lib/*" Pending 20552 read > .harness/ex/c2.log 2>&1; echo "Pending c2: exit $?"; grep -E '^(c2 |the pending list)' .harness/ex/c2.log
echo "redis-cli XPENDING tiffinbox:kitchen-events kitchen (its count): $(docker -H "$DH" exec c8u16-ex redis-cli XPENDING tiffinbox:kitchen-events kitchen | head -1 | tr -d '\r') · XLEN tiffinbox:kitchen-events: $(docker -H "$DH" exec c8u16-ex redis-cli XLEN tiffinbox:kitchen-events | tr -d '\r')"
docker -H "$DH" rm -fv c8u16-ex > /dev/null; echo "docker rm -fv: exit $?"
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
Maven: exit 0
javac: exit 0
docker run: exit 0
Pending died: exit 0
events added: 5 · c1 read 5 · acknowledged 2 · then c1 stops
the pending list, by Java: 3 · per consumer {c1=3}
redis-cli XPENDING tiffinbox:kitchen-events kitchen (its count): 3
Pending c2: exit 0
c2 read 0 new entries (">") · acknowledged 0
the pending list, by Java: 3 · per consumer {c1=3}
redis-cli XPENDING tiffinbox:kitchen-events kitchen (its count): 3 · XLEN tiffinbox:kitchen-events: 5
docker rm -fv: exit 0
```

**Done** when redis-cli's `XPENDING` count is zero after the second consumer's run, the stream's length unchanged — `c2` has taken
`c1`'s three entries and acknowledged them. The exits say nothing here: every run exits zero, in both states. As shipped, `c2` reads
the group with `">"`: the entries no consumer of the group has been given yet. `c1` was given all five, so `c2` reads none, and the
three `c1` never acknowledged stay in the group's pending list, listed under `c1` (`../README.md`, `pending`). A hint: a consumer can
take another's pending entries by their ids — the pending list names them — and acknowledge them as its own.
The solution, and what it prints, is in `SOLUTION.md`.
