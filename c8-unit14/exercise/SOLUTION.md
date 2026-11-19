# Solution — Redis Data Structures From Java

**Your turn:** the leaderboard is written, yet redis-cli finds no tiffinbox:leaderboard key and no score for Ravi. Make redis-cli read Ravi's score.

Write the board through `StringRedisTemplate` in place of `RedisTemplate<Object, Object>`: the one marked line of
`exercise/Board.java`, `var board = new StringRedisTemplate();`. Its serializer is `StringRedisSerializer` for keys and members alike,
so Redis holds `tiffinbox:leaderboard` and `Ravi` as the strings themselves, and redis-cli finds them by name — the template the
anchor's `Leaderboard` is built on. The block is the README's with one line changed: the copy of `Board.java` takes the new line in,
and the count of the line is printed as before.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex/hc && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
sed 's|^        var board = new RedisTemplate<Object, Object>();$|        var board = new StringRedisTemplate();|' exercise/Board.java > .harness/ex/Board.java; echo "StringRedisTemplate in Board.java: $(grep -c '^        var board = new StringRedisTemplate();$' .harness/ex/Board.java)"
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" clean package -DskipTests -pl tiffinbox-web -am) > .harness/ex/build.log 2>&1; echo "Maven: exit $?"
(cd .harness/ex/tree && exec perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted) > .harness/ex/extract.log 2>&1
L=.harness/ex/tree/tiffinbox-web/target/extracted; perl -e 'alarm 120; exec @ARGV' javac -d .harness/ex/hc -cp "$L/lib/*" .harness/ex/Board.java; echo "javac: exit $?"
docker -H "$DH" run -d --pull never --name c8u14-ex -p 127.0.0.1:20532:6379 redis@sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3 > /dev/null; echo "docker run: exit $?"
i=0; while [ "$(docker -H "$DH" exec c8u14-ex redis-cli PING 2> /dev/null)" != PONG ] && [ $i -lt 120 ]; do sleep 0.5; i=$((i + 1)); done
perl -e 'alarm 120; exec @ARGV' java -cp ".harness/ex/hc:$L/lib/*" Board after/tiffinbox-core/src/main/resources/db/migration/V2__seed.sql after/tiffinbox-web/src/main/resources/application.yaml 20532 > .harness/ex/run.log 2>&1; echo "Board: exit $?"; grep -E '^(template|orders written):' .harness/ex/run.log
echo "redis-cli ZSCORE tiffinbox:leaderboard Ravi: ($(docker -H "$DH" exec c8u14-ex redis-cli ZSCORE tiffinbox:leaderboard Ravi | tr -d '\r'))"; echo "redis-cli EXISTS tiffinbox:leaderboard: $(docker -H "$DH" exec c8u14-ex redis-cli EXISTS tiffinbox:leaderboard | tr -d '\r')"
docker -H "$DH" rm -fv c8u14-ex > /dev/null; echo "docker rm -fv: exit $?"
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
StringRedisTemplate in Board.java: 1
Maven: exit 0
javac: exit 0
docker run: exit 0
Board: exit 0
template: StringRedisTemplate · key serializer StringRedisSerializer
orders written: 120 · no exception
redis-cli ZSCORE tiffinbox:leaderboard Ravi: (7200)
redis-cli EXISTS tiffinbox:leaderboard: 1
docker rm -fv: exit 0
```

**Done:** redis-cli reads Ravi's score, and `EXISTS` answers 1 — the key and the members are the strings themselves. The fill
itself is unchanged: the same orders, the same values, the same `ZINCRBY`; only the serializer the template hands Redis moved.
