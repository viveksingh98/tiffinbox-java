# Exercise — the timeout that does not fire

**Your turn:** the README gives the client a one-second read timeout, yet the slow kitchen still makes it wait. Fix the key, and call again.

The harness route `GET /probe/remote?path=/slow` (`harness/probe/web/CallRoutes.java`) asks the stub — a small stand-in server on this
computer, `harness/stub/Stub.java` — for `/slow`, which it answers after three seconds. The route's client comes from Boot's builder bean,
so Boot's client keys decide its timeouts. The line below gives it a read timeout of one second: `T=` holds the key, as an option.

Run everything from `c6-unit25/`, in one shell. The commands below copy TiffinBox — `anchor/`, the tree the sessions lesson made — to
`.harness/mine/anchor` (git-ignored; `receipts.sh` wipes `.harness/` when it runs) and give the copy a config tree with a token of its own —
26 random hexadecimal digits (`openssl rand -hex 13`), in `.harness/mine/anchor/secrets/tiffinbox/shutdown-token`, readable by you alone,
never printed. Its last line runs in a subshell (the parentheses), so your shell stays in `c6-unit25/` for the next run: it builds the copy
offline against this unit's `.m2-demo`, extracts its jar, asks Maven for the harness POM's class path (`harness/pom.xml`: Boot's RestClient
starter) and copies the jars the copy's `lib/` lacks that hold classes into `.harness/mine/xlib`, compiles the harness against both (into
`.harness/mine/hc`), starts the stub on `127.0.0.1:19546` and TiffinBox on its class path with the route joined
(`--spring.main.sources=probe.web.CallRoutes`) on `127.0.0.1:19544` — each JVM in a job of its own, its locale pinned
(`-Duser.language=en -Duser.country=US`), its pid saved — waits until the stub listens and readiness answers 200, calls the route with curl,
stops TiffinBox with POST /shutdown (`harness/shutdown.sh`, the token read from the copy's own file) and the stub by its pid, waits for both
(`wait "$s"`, `wait "$p"`: a JVM that failed — another JDK's `java`, say — ends the line with its own exit code, never with an answer, and so
does a build that failed), and prints the route's status and how many times TiffinBox's log names the timeout's cause. TiffinBox's whole log
is `.harness/mine/run.log`, the stub's `.harness/mine/stub.log`, the route's answer `.harness/mine/answer.txt`. On a fresh clone `.m2-demo`
is empty: run `./receipts.sh` once first (no GraalVM, no Docker and no browser are needed).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine/xlib && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/
mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
T=--spring.http.client.read-timeout=1s
M="$PWD/.m2-demo" && H="$PWD/harness" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && mvn -o -B -q -Dmaven.repo.local="$M" -f "$H/pom.xml" dependency:build-classpath -Dmdep.outputFile="$PWD/../harness.cp" && rm -f ../xlib/* && tr ':' '\n' < ../harness.cp | while IFS= read -r j; do [ -e "tiffinbox-web/target/extracted/lib/${j##*/}" ] || ! unzip -l "$j" | grep -q '\.class$' || cp "$j" ../xlib/; done && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*:../xlib/*" "$H"/probe/web/*.java && { java -Duser.language=en -Duser.country=US "$H/stub/Stub.java" --port=19546 --www="$H/stub/www" > ../stub.log 2>&1 & } && s=$! && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19544 --spring.main.sources=probe.web.CallRoutes "$T" > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do grep -q '^STUB listening' ../stub.log && [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19544/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -o ../answer.txt -w '%{http_code}' 'http://127.0.0.1:19544/probe/remote?path=/slow'); "$H/shutdown.sh" 19544 secrets/tiffinbox/shutdown-token > /dev/null; kill "$s"; wait "$s"; wait "$p" && echo "the slow call: $a · Request cancelled in its log: $(grep -c '^java.net.http.HttpTimeoutException: Request cancelled$' ../run.log)")
```

As shipped, it prints `the slow call: 200 · Request cancelled in its log: 0` — the route waited the stub's whole three seconds and passed
its answer on (`.harness/mine/answer.txt`: `{"slow":true}`), and nothing in TiffinBox's log says a timeout fired, or that a key was ignored.
Read the key's name in Boot's own metadata — this unit's `timeouts` capture prints it, and what Boot 4.1 says about the spelling in `T=` —
then fix `T=`, from the same shell, and run the last line again.

**Done** when you can print

```
the slow call: 500 · Request cancelled in its log: 1
```

— the read timeout fired after one second: the client's call failed with `Request cancelled`, the route did not catch it, and TiffinBox
answered with its own 500. The same line is in this unit's `exercise` capture (`.r-exercise.out`). The measured answer, run exactly as
written: `solution/SOLUTION.md`.
