# Exercise — Redis Data Structures From Java

**Your turn:** the leaderboard is written, yet redis-cli finds no tiffinbox:leaderboard key and no score for Ravi. Make redis-cli read Ravi's score.

Run it from this unit's folder (`c8-unit14/`). It needs this folder's `.m2-demo` (a copy of the course's Maven repository, offline —
`README.md`, *The repository*) and Docker: the exercise is about what redis-cli reads, so it needs a Redis — the image the course
pinned, by its digest, which the block starts itself (`--pull never`: it never pulls) on `127.0.0.1:20532` and removes with its volume
at the end (`rm -fv`). The block names the Docker socket as the receipts do (`docker -H "$DH"`, OrbStack's on the author's Mac — point
`DH` at yours). No TiffinBox and no database: `exercise/Board.java` is a program of its own on the anchor's libraries. The block copies
the anchor, `after/`, to `.harness/ex/tree`, and Maven builds its jar there (offline, the tests skipped, every module from the tree's
own sources: `-pl tiffinbox-web -am`) for the libraries in it; every Java and Maven run is under an alarm (`perl -e 'alarm 300; exec …'`;
macOS has no `timeout`). `Board.java` reads the four customers from the anchor's seed and the days from `application.yaml`, deletes
`tiffinbox:leaderboard` and adds every order's value to its customer's score, one `ZINCRBY` per order, as TiffinBox's start does under
the profile "dev" — through the template its one marked line builds. Then redis-cli, the container's own client, reads Ravi's score and
asks whether the key exists. The file you change is the copy the block takes, `exercise/Board.java`.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex/hc && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
cp exercise/Board.java .harness/ex/Board.java; echo "StringRedisTemplate in Board.java: $(grep -c '^        var board = new StringRedisTemplate();$' .harness/ex/Board.java)"
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
StringRedisTemplate in Board.java: 0
Maven: exit 0
javac: exit 0
docker run: exit 0
Board: exit 0
template: RedisTemplate · key serializer JdkSerializationRedisSerializer
orders written: 120 · no exception
redis-cli ZSCORE tiffinbox:leaderboard Ravi: ()
redis-cli EXISTS tiffinbox:leaderboard: 0
docker rm -fv: exit 0
```

**Done** when redis-cli prints Ravi's score inside the brackets, and `EXISTS` answers 1 — redis-cli found the key by its name.
`Board`'s exit says nothing here: it is 0 in both states, and no exception is thrown in either. As shipped the board is written, but
through a `RedisTemplate` of `Object` and `Object`, whose serializer is Java serialization's (`JdkSerializationRedisSerializer`): the
key and every member Redis holds begin with that serializer's own bytes, so the plain name finds nothing (`../README.md`, `trap`). A
hint: Spring Data Redis has a template whose keys and members are the strings themselves.
The solution, and what it prints, is in `SOLUTION.md`.
