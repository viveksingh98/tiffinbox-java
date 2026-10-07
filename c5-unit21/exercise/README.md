# Exercise — the token's property source, and what env shows of it

**Your turn:** expose the env endpoint for one run, then find the property source that holds tiffinbox.shutdown-token, and what it shows.

The video exposed one endpoint, health, and read what env costs when it is exposed: every value masked, every name listed. Now ask
env about one key, the shutdown token itself: which of Boot's property sources holds it, and what does env show of it?

Run everything from `c5-unit21/`. The commands below copy TiffinBox — `after/`, the anchor as this lesson leaves it — to
`.harness/mine` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), build it the plain way, offline against this unit's
own repository `.m2-demo`, and give it a config tree with a token of its own: 26 random lowercase letters and digits, in
`.harness/mine/run/secrets/tiffinbox/shutdown-token` (readable by you alone), never printed. On a fresh clone `.m2-demo` is empty:
run `./receipts.sh` once first. No GraalVM is needed for that: without `GRAALVM_HOME` it fills `.m2-demo` from Maven Central, makes
every capture that needs no GraalVM — this exercise's among them — and stops before the native build.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine/run/secrets/tiffinbox && rsync -a --exclude target after/ .harness/mine/after/
mvn -o -B -q -f .harness/mine/after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package
chmod 700 .harness/mine/run/secrets .harness/mine/run/secrets/tiffinbox && (umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/run/secrets/tiffinbox/shutdown-token)
```

Then start TiffinBox from `.harness/mine/run`, the folder that holds the config tree, with the jar
`../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar`, port `19009`, and one flag more than the README's run line: the one that
exposes env beside health (`after/README.md`, unit 21's section). Wait until `/actuator/health/readiness` answers 200, then ask
`http://127.0.0.1:19009/actuator/env/tiffinbox.shutdown-token`. The answer's `property` names the source and shows the value. The
source's name carries an absolute path: write it as `…` up to `/secrets`. Stop TiffinBox with POST /shutdown and its token —
`harness/shutdown.sh 19009 .harness/mine/run/secrets/tiffinbox/shutdown-token` hands it to curl from the file.

**Done** when you can print

```
Config tree '…/secrets' · tiffinbox.shutdown-token = ******
```

— the config tree holds the token, and env masks its value. The same line is in this unit's `exercise` capture (`.r-exercise.out`).
The measured answer, run exactly as written: `solution/SOLUTION.md`. What `--management.endpoint.env.show-values=always` does to
that value, and what a heap dump holds, is in the `tour` capture: never run either against a real token.
