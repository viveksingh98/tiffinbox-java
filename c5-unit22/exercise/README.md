# Exercise — the kitchen in liveness too, and what a platform would do

**Your turn:** put the kitchen into the liveness group as well, close the database, and read what a platform would now do.

The video put the kitchen into the readiness group and closed the database: readiness answered 503 — stop sending this process
traffic — and liveness 200 — do not restart it. Now put the kitchen into liveness as well, close the database the same way, and ask
liveness.

Run everything from `c5-unit22/`. The commands below copy TiffinBox — `after/`, the anchor as this lesson leaves it — to
`.harness/mine` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), build it the plain way, offline against this unit's
own repository `.m2-demo`, extract the jar (the anchor README's extract line), compile the harness's `CloseDb` against the
extracted class path into `.harness/mine/hc`, and give TiffinBox a config tree with a token of its own: 26 random lowercase letters
and digits, in `.harness/mine/run/secrets/tiffinbox/shutdown-token` (readable by you alone), never printed. On a fresh clone
`.m2-demo` is empty: run `./receipts.sh` once first. No GraalVM is needed for that: without `GRAALVM_HOME` it fills `.m2-demo`
from Maven Central, makes every capture that needs no GraalVM — this exercise's among them — and stops before the native build.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine/run/secrets/tiffinbox .harness/mine/hc && rsync -a --exclude target after/ .harness/mine/after/
mvn -o -B -q -f .harness/mine/after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package
(cd .harness/mine/after && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted)
javac -d .harness/mine/hc -cp ".harness/mine/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/mine/after/tiffinbox-web/target/extracted/lib/*" harness/probe/health/CloseDb.java
chmod 700 .harness/mine/run/secrets .harness/mine/run/secrets/tiffinbox && (umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/run/secrets/tiffinbox/shutdown-token)
```

Then start TiffinBox from `.harness/mine/run`, the folder that holds the config tree, on the extracted class path
(`../after/tiffinbox-web/target/extracted/…`, the anchor README's exploded run) with `../hc` added to it, port `19019`, the harness
joined (`--spring.main.sources=probe.health.CloseDb`: it closes the database once Boot has called TiffinBox ready, then prints
`harness: done`), and one flag of your own: the liveness group's members — Boot's liveness state and the kitchen (the readiness
line in `after/tiffinbox-web/src/main/resources/application.yaml` shows the form). Wait for `harness: done` in TiffinBox's
output — readiness will never answer 200 here, so do not wait for it — then ask `http://127.0.0.1:19019/actuator/health/liveness`.
Stop TiffinBox with POST /shutdown and its token — `harness/shutdown.sh 19019 .harness/mine/run/secrets/tiffinbox/shutdown-token`
hands it to curl from the file.

**Done** when you can print

```
liveness {"status":"DOWN"} [503]
```

— a platform that probes liveness would now restart TiffinBox, and a restart cannot bring back a database outside the process
(TiffinBox's own in-memory H2 it would rebuild): here the harness closes it again in every run, as an outside database that stays
down would. The same line is in this unit's `exercise` capture
(`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`. Which group the kitchen belongs in is the
`groups` capture: readiness.
