# Exercise — TiffinBox's own rows, and their verbs

**Your turn:** expose mappings for one run, count TiffinBox's own rows, and name the verbs the table gives them.

Since the embedded-Tomcat lesson TiffinBox's five paths are rows in Spring MVC's routing table, and Boot's Actuator serves that
table at `/actuator/mappings` — but only when `mappings` is in the exposure list. `application.yaml` lists `health,prometheus`
and nothing else, so the list is widened for one run, with a flag, on the plain JVM (under Spring's AOT step the build fixes the
list, and a flag adds nothing there).

Run everything from `c6-unit05/`. The commands below copy TiffinBox — `anchor/`, the tree this lesson reads — to
`.harness/mine/tree` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), give it a config tree with a token of its own —
26 random lowercase letters and digits, in `.harness/mine/tree/secrets/tiffinbox/shutdown-token`, readable by you alone, never
printed — and build the jar offline against this unit's `.m2-demo`. The last line starts TiffinBox on `127.0.0.1:19349` with an
exposure list for this one run, waits until readiness answers 200, saves `/actuator/mappings`' answer to `.harness/mine/answer.json`,
stops TiffinBox with POST /shutdown (`harness/shutdown.sh`, the token read from the copy's own file), waits for it to exit, and
reads the answer with the course's harness (`harness/table.py tiffinbox`: TiffinBox's rows, counted, and the verbs each row
lists). On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once first.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/tree/
mkdir -p .harness/mine/tree/secrets/tiffinbox && chmod 700 .harness/mine/tree/secrets .harness/mine/tree/secrets/tiffinbox
(umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/tree/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/tree && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package)
cd .harness/mine/tree && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19349 --management.endpoints.web.exposure.include=health,prometheus,mapping > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19349/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s http://127.0.0.1:19349/actuator/mappings > ../answer.json && ../../../harness/shutdown.sh 19349 secrets/tiffinbox/shutdown-token > /dev/null && wait && python3 ../../../harness/table.py tiffinbox < ../answer.json
```

As shipped, it prints `TiffinBox's rows: 0 · not a routing table: status 404`: the exposure list names an endpoint that does not
exist, Boot says nothing about it, and `/actuator/mappings` answers Spring's JSON 404. Change one word in the last line.

**Done** when you can print

```
TiffinBox's rows: 5 · the verbs the table gives them: none
```

— five rows, `/customers` … `/shutdown`, each with a path and a handler's name and nothing else: the verb is still checked inside
TiffinBox's own handler, so the table cannot list one. The same line is in this unit's `exercise` capture (`.r-exercise.out`).
The measured answer, run exactly as written: `solution/SOLUTION.md`.
