# Solution — Pub/Sub and Streams

**Your turn:** a consumer died holding three kitchen events, and XPENDING still lists them. Have a second consumer take them and acknowledge them.

Have `c2` claim them: the block's last `java` line runs the program as `claim` instead of `read`. As `claim`, `c2` asks the group's
pending list for `c1`'s entries (`XPENDING` with a range, the ids it names), takes them — `XCLAIM`, Spring Data Redis's
`opsForStream().claim(key, "kitchen", "c2", Duration.ZERO, ids)`: a minimum idle time of `Duration.ZERO`, so the entries move to `c2`
however long `c1` has held them — and acknowledges them as its own (`XACK`). Reading with `">"` gives a consumer only the entries no
consumer of the group was given; an entry another consumer was given and never acknowledged reaches a second consumer only by a claim.
The block is the README's with that one line changed.

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
perl -e 'alarm 120; exec @ARGV' java -cp ".harness/ex/hc:$L/lib/*" Pending 20552 claim > .harness/ex/c2.log 2>&1; echo "Pending c2: exit $?"; grep -E '^(c2 |the pending list)' .harness/ex/c2.log
echo "redis-cli XPENDING tiffinbox:kitchen-events kitchen (its count): $(docker -H "$DH" exec c8u16-ex redis-cli XPENDING tiffinbox:kitchen-events kitchen | head -1 | tr -d '\r') · XLEN tiffinbox:kitchen-events: $(docker -H "$DH" exec c8u16-ex redis-cli XLEN tiffinbox:kitchen-events | tr -d '\r')"
docker -H "$DH" rm -fv c8u16-ex > /dev/null; echo "docker rm -fv: exit $?"
```

What it prints, solved (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
Maven: exit 0
javac: exit 0
docker run: exit 0
Pending died: exit 0
events added: 5 · c1 read 5 · acknowledged 2 · then c1 stops
the pending list, by Java: 3 · per consumer {c1=3}
redis-cli XPENDING tiffinbox:kitchen-events kitchen (its count): 3
Pending c2: exit 0
c2 claimed 3 of c1's pending entries · acknowledged 3
the pending list, by Java: 0 · per consumer {}
redis-cli XPENDING tiffinbox:kitchen-events kitchen (its count): 0 · XLEN tiffinbox:kitchen-events: 5
docker rm -fv: exit 0
```

**Done:** redis-cli's `XPENDING` count reads zero after `c2`'s run, and the stream's length is what it was — `c2` claimed `c1`'s three
entries and acknowledged them. Acknowledging moves an entry out of the group's pending list; the entry stays in the stream.
