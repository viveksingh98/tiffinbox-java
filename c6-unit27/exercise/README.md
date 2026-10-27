# Exercise — the header the move lost

**Your turn:** the README moved the old call to RestClient and lost its X-Via header. Build the client from the template, and call again.

The harness's routes (`harness/probe/web/TemplateRoutes.java`) read Ravi's row from the stub — a small stand-in server on this computer,
`harness/stub/Stub.java` — two ways. `GET /probe/old` is the old code: a template from Boot's builder with an interceptor added, `Via`,
which puts `X-Via: template-interceptor` on every request the template sends. `GET /probe/moved` is the same call moved to RestClient —
as shipped, a client made with `RestClient.create()`, which knows nothing of the template.

Run everything from `c6-unit27/`, in one shell. The commands below copy TiffinBox — `anchor/`, the tree the sessions lesson made — to
`.harness/mine/anchor` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), give the copy a config tree with a token of its own —
26 random hexadecimal digits (`openssl rand -hex 13`), in `.harness/mine/anchor/secrets/tiffinbox/shutdown-token`, readable by you alone,
never printed — and copy the harness's four sources to `.harness/mine/src`: **that copy is the code you change**, never `harness/`. The
last line runs in a subshell (the parentheses), so your shell stays in `c6-unit27/` for the next run: it builds the copy offline against
this unit's `.m2-demo`, extracts its jar, asks Maven for the harness POM's class path (`harness/pom.xml`: Boot's RestClient starter) and
copies the jars the copy's `lib/` lacks that hold classes into `.harness/mine/xlib`, compiles the sources in `.harness/mine/src` against
both (into `.harness/mine/hc`), starts the stub on `127.0.0.1:19566` and TiffinBox on its class path with the routes joined
(`--spring.main.sources=probe.web.TemplateRoutes`) on `127.0.0.1:19564` — each JVM in a job of its own, its locale pinned
(`-Duser.language=en -Duser.country=US`), its pid saved — waits until the stub listens and readiness answers 200, calls both routes with
curl, reads TiffinBox's `/actuator/prometheus` once, stops TiffinBox with POST /shutdown (`harness/shutdown.sh`, the token read from the
copy's own file) and the stub by its pid, waits for both (`wait "$s"`, `wait "$p"`: a JVM that failed — another JDK's `java`, say — ends
the line with its own exit code, never with an answer, and so does a build that failed), and prints both routes' statuses, how many of the
requests the stub saw carried `X-Via`, and how many client calls the scrape counted under the URI template `/{f}` (an observation:
Spring's record of one call). TiffinBox's whole log is `.harness/mine/run.log`, the stub's `.harness/mine/stub.log`, the routes' answers
`.harness/mine/old.txt` and `.harness/mine/moved.txt`. On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once first (no GraalVM,
no Docker and no browser are needed).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine/xlib && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/
mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
mkdir -p .harness/mine/src && cp harness/probe/web/*.java .harness/mine/src/
M="$PWD/.m2-demo" && H="$PWD/harness" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && mvn -o -B -q -Dmaven.repo.local="$M" -f "$H/pom.xml" dependency:build-classpath -Dmdep.outputFile="$PWD/../harness.cp" && rm -f ../xlib/* && tr ':' '\n' < ../harness.cp | while IFS= read -r j; do [ -e "tiffinbox-web/target/extracted/lib/${j##*/}" ] || ! unzip -l "$j" | grep -q '\.class$' || cp "$j" ../xlib/; done && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*:../xlib/*" ../src/*.java && { java -Duser.language=en -Duser.country=US "$H/stub/Stub.java" --port=19566 --www="$H/stub/www" > ../stub.log 2>&1 & } && s=$! && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19564 --spring.main.sources=probe.web.TemplateRoutes > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do grep -q '^STUB listening' ../stub.log && [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19564/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -o ../old.txt -w '%{http_code}' http://127.0.0.1:19564/probe/old) && b=$(curl -s -o ../moved.txt -w '%{http_code}' http://127.0.0.1:19564/probe/moved) && o=$(curl -s http://127.0.0.1:19564/actuator/prometheus | awk '/^http_client_requests_seconds_count/ && index($0, "uri=\"/{f}\"") { s += $NF } END { print s + 0 }'); "$H/shutdown.sh" 19564 secrets/tiffinbox/shutdown-token > /dev/null; kill "$s"; wait "$s"; wait "$p" && echo "the old call: $a · the moved call: $b · requests at the stub with X-Via: $(grep -c '^STUB-H x-via: template-interceptor$' ../stub.log) of $(grep -c '^STUB [A-Z]* /' ../stub.log) · observed calls: $o")
```

As shipped, it prints `the old call: 200 · the moved call: 200 · requests at the stub with X-Via: 1 of 2 · observed calls: 1` — both routes answer Ravi's row, but the stub saw `X-Via` on one request of two, the old call's: the moved
client sent none, and nothing failed. The scrape counted one call, the template's; the moved call is not there at all. The moved client
is `RestClient.create()` in `.harness/mine/src/TemplateRoutes.java`: read what the template was set up with (this unit's `migrate` capture
builds RestClient two ways from one), change that one call in the copy, from the same shell, and run the last line again.

**Done** when you can print

```
the old call: 200 · the moved call: 200 · requests at the stub with X-Via: 2 of 2 · observed calls: 2
```

— the moved client now sends what the template sent: its interceptor travelled, and so did its observation. The same line is in this
unit's `exercise` capture (`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.
