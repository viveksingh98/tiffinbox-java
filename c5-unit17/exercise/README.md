# Your turn — stop it, and see what stays

In the lesson, Boot started Postgres with TiffinBox and stopped it when TiffinBox stopped. **Stop TiffinBox and list the
compose containers. Then make the next stop remove Postgres instead of just stopping it.**

Run everything from this unit's folder (`c5-unit17/`), with Docker running and this unit's own `.m2-demo` (every Maven build
is offline). The first block copies the lesson's tree to `.harness/mine` (git-ignored; `receipts.sh` wipes `.harness/` when
it runs), builds it the lesson's way - the jar, and the class path file Maven writes - gives the copy a token of its own (32
random hexadecimal characters, in a file only you can read) and starts TiffinBox there with the profile `dev`, on port 18888:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness && rsync -a --exclude target after/ .harness/mine/
mvn -o -q -B -f .harness/mine/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt
mkdir -p .harness/mine/secrets/tiffinbox && (umask 077 && openssl rand -hex 16 > .harness/mine/secrets/tiffinbox/shutdown-token)
cd .harness/mine && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18888 --spring.profiles.active=dev
```

TiffinBox keeps this terminal, which is now in `.harness/mine`: its log shows Docker Compose's lines, then `TiffinBox
listening on http://127.0.0.1:18888`. In a second terminal, from this unit's folder, stop it - POST /shutdown, with the
header read from your file - and, once the first terminal is back at its prompt, list the compose project's containers:

```bash
{ printf 'X-Shutdown-Token: '; head -n 1 .harness/mine/secrets/tiffinbox/shutdown-token; } | curl -s -w ' %{http_code}\n' -H @- -X POST http://127.0.0.1:18888/shutdown
docker ps -a --filter label=com.docker.compose.project=tiffinbox-dev --format '{{.Names}}:{{.State}}'
```

POST /shutdown answers `{"stopping":true} 200`, and the list says `tiffinbox-dev-postgres-1:exited`: Boot stopped Postgres,
and its container is still there.

**Your turn.** In the first terminal - still in `.harness/mine` - start TiffinBox again, so that this time, when it stops,
Boot removes the Postgres container instead of just stopping it: the same `java` command, with one more flag at the end.
Hint: Boot keeps the command it runs when TiffinBox stops in one key, `spring.docker.compose.stop.command`, and its default
is `stop`.

**Done** when, after the same two commands in the second terminal, the list is empty. The data stays: `docker volume ls
--filter label=com.docker.compose.project=tiffinbox-dev --format '{{.Name}}'` still prints `tiffinbox-dev_data`. The measured
answer, run exactly as written: `solution/SOLUTION.md`.

When you are done, from this unit's folder:

```bash
docker compose -p tiffinbox-dev down -v
rm -rf .harness/mine
```
