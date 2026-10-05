# Solution — Boot's other stop command

In the first terminal, still in `.harness/mine` (where `../README.md`'s start command left it), the same command with
`--spring.docker.compose.stop.command=down` at the end:

```bash
java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18888 --spring.profiles.active=dev --spring.docker.compose.stop.command=down
```

Then, in the second terminal, from the unit's folder - the same two commands, and the volumes:

```bash
{ printf 'X-Shutdown-Token: '; head -n 1 .harness/mine/secrets/tiffinbox/shutdown-token; } | curl -s -w ' %{http_code}\n' -H @- -X POST http://127.0.0.1:18888/shutdown
docker ps -a --filter label=com.docker.compose.project=tiffinbox-dev --format '{{.Names}}:{{.State}}'
docker volume ls --filter label=com.docker.compose.project=tiffinbox-dev --format '{{.Name}}'
```

**Measured.** `../README.md`'s three blocks and the two above, every line exactly as written, in one clean shell (`env -i
HOME=… PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin bash --noprofile --norc`), from `c5-unit17/`, on 2026-10-05, Docker
(OrbStack) running. The two start commands ran in the background - the first terminal - and their log is shown from each line's
message on, Docker Compose's lines and TiffinBox's listening line only (the time, level, PID, thread and logger columns, and every
other line, dropped); everything else ran in order - the second terminal. One thing is masked: this unit's folder, `…`. Re-run
exactly as written by BLUE part B, 2026-10-05 (two clean shells, the first terminal's and the second's), after the README gained its
note on the anchor's project name (prose only): the same transcript, line for line.

```
$ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  (exit 0)
$ export PATH="$JAVA_HOME/bin:$PATH"
  (exit 0)
$ rm -rf .harness/mine && mkdir -p .harness && rsync -a --exclude target after/ .harness/mine/
  (exit 0)
$ mvn -o -q -B -f .harness/mine/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt
  (exit 0)
$ mkdir -p .harness/mine/secrets/tiffinbox && (umask 077 && openssl rand -hex 16 > .harness/mine/secrets/tiffinbox/shutdown-token)
  (exit 0)
$ cd .harness/mine && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18888 --spring.profiles.active=dev   [first terminal]
  [first terminal] The following 1 profile is active: "dev"
  [first terminal] Using Docker Compose file …/.harness/mine/compose.yaml
  [first terminal] Network tiffinbox-dev_default Creating
  [first terminal] Network tiffinbox-dev_default Created
  [first terminal] Volume tiffinbox-dev_data Creating
  [first terminal] Volume tiffinbox-dev_data Created
  [first terminal] Container tiffinbox-dev-postgres-1 Creating
  [first terminal] Container tiffinbox-dev-postgres-1 Created
  [first terminal] Container tiffinbox-dev-postgres-1 Starting
  [first terminal] Container tiffinbox-dev-postgres-1 Started
  [first terminal] Container tiffinbox-dev-postgres-1 Waiting
  [first terminal] Container tiffinbox-dev-postgres-1 Healthy
  [first terminal] TiffinBox listening on http://127.0.0.1:18888
$ { printf 'X-Shutdown-Token: '; head -n 1 .harness/mine/secrets/tiffinbox/shutdown-token; } | curl -s -w ' %{http_code}\n' -H @- -X POST http://127.0.0.1:18888/shutdown
{"stopping":true} 200
  (exit 0)
  [first terminal, back at its prompt] (exit 0)
$ docker ps -a --filter label=com.docker.compose.project=tiffinbox-dev --format '{{.Names}}:{{.State}}'
tiffinbox-dev-postgres-1:exited
  (exit 0)
$ java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18888 --spring.profiles.active=dev --spring.docker.compose.stop.command=down   [first terminal, from .harness/mine]
  [first terminal] The following 1 profile is active: "dev"
  [first terminal] Using Docker Compose file …/.harness/mine/compose.yaml
  [first terminal] Container tiffinbox-dev-postgres-1 Starting
  [first terminal] Container tiffinbox-dev-postgres-1 Started
  [first terminal] Container tiffinbox-dev-postgres-1 Waiting
  [first terminal] Container tiffinbox-dev-postgres-1 Healthy
  [first terminal] TiffinBox listening on http://127.0.0.1:18888
$ { printf 'X-Shutdown-Token: '; head -n 1 .harness/mine/secrets/tiffinbox/shutdown-token; } | curl -s -w ' %{http_code}\n' -H @- -X POST http://127.0.0.1:18888/shutdown
{"stopping":true} 200
  (exit 0)
  [first terminal, back at its prompt] (exit 0)
$ docker ps -a --filter label=com.docker.compose.project=tiffinbox-dev --format '{{.Names}}:{{.State}}'
  (exit 0)
$ docker volume ls --filter label=com.docker.compose.project=tiffinbox-dev --format '{{.Name}}'
tiffinbox-dev_data
  (exit 0)
$ docker compose -p tiffinbox-dev down -v
 Volume tiffinbox-dev_data Removing
 Volume tiffinbox-dev_data Removed
  (exit 0)
$ rm -rf .harness/mine
  (exit 0)
```

**Why.** Boot keeps the command it runs when TiffinBox stops in `spring.docker.compose.stop.command`. Its default, `stop`, stops the
container and leaves it there, `exited`: the next start finds it and starts it again (`Starting`, with no `Created`). `down` removes the
container - Docker Compose's own `down` - and the list is empty. The data is not in the container: it is in the volume `compose.yaml`
names, `tiffinbox-dev_data`, which `down` keeps. `docker compose -p tiffinbox-dev down -v` deletes it: its only output is the volume's
two lines, because the container and the network were already gone.
