# Exercise — three verbs TiffinBox never declared, and the series they make

**Your turn:** call `/customers` with three verbs TiffinBox never declared, then count the request series in the scrape, and say why.

The video tagged every answer with the route TiffinBox declares: `/customers/7`, `/customers/8` and `/customersXYZ` all counted
under `route="GET /customers"`, one series. A route's key is a verb and a path, and a client chooses the verb too. Send
`/customers` three verbs no route of TiffinBox's takes — `BREW`, `PUT` and `DELETE` — and read what the scrape keeps.

Run everything from `c5-unit23/`. The commands below copy TiffinBox — `after/`, the anchor as this lesson leaves it — to
`.harness/mine/after` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), build it the plain way, offline against this
unit's own repository `.m2-demo`, and give it a config tree with a token of its own: 26 random lowercase letters and digits, in
`.harness/mine/after/secrets/tiffinbox/shutdown-token` (readable by you alone), never printed. On a fresh clone `.m2-demo` is
empty: run `./receipts.sh` once first. No GraalVM is needed for that: without `GRAALVM_HOME` it fills `.m2-demo` from Maven
Central, makes every capture that needs no GraalVM — this exercise's among them — and stops before the native build.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
mvn -o -B -q -f .harness/mine/after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package
mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
(umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/after/secrets/tiffinbox/shutdown-token)
```

Then start TiffinBox from `.harness/mine/after`, the folder that holds the config tree, as the anchor README runs it, on port
`19029`; wait until `http://127.0.0.1:19029/actuator/health/readiness` answers 200; send `/customers` the three verbs (`curl -X`);
then read `http://127.0.0.1:19029/actuator/prometheus` and keep the lines that start `tiffinbox_requests_seconds_count`. Stop
TiffinBox with POST /shutdown and its token — `harness/shutdown.sh 19029 .harness/mine/after/secrets/tiffinbox/shutdown-token`
hands it to curl from the file.

**Done** when you can print

```
tiffinbox_requests_seconds_count{route="UNKNOWN",status="405"} 3
```

— one series for three verbs: the tag holds a route TiffinBox declares, and a verb no route declares is `UNKNOWN`, never the word
the client sent. Each answer was a 405, so the three share one series. The same line is in this unit's `exercise` capture
(`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.
