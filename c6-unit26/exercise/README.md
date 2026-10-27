# Exercise — the client that starts fine

**Your turn:** the README's payment client starts fine and fails on every call. Tell the group where the payment service lives, and pay again.

The harness route `GET /probe/pay` (`harness/probe/web/PayRoutes.java`) pays Ravi's month through the payment interface
(`harness/probe/web/Payments.java`), whose client Spring builds for the service group `payments` (`harness/probe/web/PaymentConfig.java`).
The payment service is the stub — a small stand-in server on this computer, `harness/stub/Stub.java` — on `127.0.0.1:19556`. The group's
own options go in `B=`, which the last line passes to TiffinBox unquoted: as shipped, `B=` is empty, so it passes nothing.

Run everything from `c6-unit26/`, in one shell. The commands below copy TiffinBox — `anchor/`, the tree the sessions lesson made — to
`.harness/mine/anchor` (git-ignored; `receipts.sh` wipes `.harness/` when it runs) and give the copy a config tree with a token of its own —
26 random hexadecimal digits (`openssl rand -hex 13`), in `.harness/mine/anchor/secrets/tiffinbox/shutdown-token`, readable by you alone,
never printed. Its last line runs in a subshell (the parentheses), so your shell stays in `c6-unit26/` for the next run: it builds the copy
offline against this unit's `.m2-demo`, extracts its jar, asks Maven for the harness POM's class path (`harness/pom.xml`: Boot's RestClient
starter) and copies the jars the copy's `lib/` lacks that hold classes into `.harness/mine/xlib`, compiles the harness against both (into
`.harness/mine/hc`, with `-parameters`), starts the stub on `127.0.0.1:19556` and TiffinBox on its class path with the group and the route
joined (`--spring.main.sources=probe.web.PaymentConfig,probe.web.PayRoutes`) on `127.0.0.1:19554` — each JVM in a job of its own, its
locale pinned (`-Duser.language=en -Duser.country=US`), its pid saved — waits until the stub listens and readiness answers 200, calls the
route with curl, stops TiffinBox with POST /shutdown (`harness/shutdown.sh`, the token read from the copy's own file) and the stub by its
pid, waits for both (`wait "$s"`, `wait "$p"`: a JVM that failed — another JDK's `java`, say — ends the line with its own exit code, never
with an answer, and so does a build that failed), and prints readiness's status, the route's status, the payment's id (or `none`), how
many times TiffinBox's log names the call's failure, and how many requests reached the stub. TiffinBox's whole log is
`.harness/mine/run.log`, the stub's `.harness/mine/stub.log`, the route's answer `.harness/mine/answer.txt`. On a fresh clone `.m2-demo`
is empty: run `./receipts.sh` once first (no GraalVM, no Docker and no browser are needed).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine/xlib && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/
mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
B=
M="$PWD/.m2-demo" && H="$PWD/harness" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && mvn -o -B -q -Dmaven.repo.local="$M" -f "$H/pom.xml" dependency:build-classpath -Dmdep.outputFile="$PWD/../harness.cp" && rm -f ../xlib/* && tr ':' '\n' < ../harness.cp | while IFS= read -r j; do [ -e "tiffinbox-web/target/extracted/lib/${j##*/}" ] || ! unzip -l "$j" | grep -q '\.class$' || cp "$j" ../xlib/; done && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*:../xlib/*" "$H"/probe/web/*.java && { java -Duser.language=en -Duser.country=US "$H/stub/Stub.java" --port=19556 --www="$H/stub/www" > ../stub.log 2>&1 & } && s=$! && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19554 --spring.main.sources=probe.web.PaymentConfig,probe.web.PayRoutes $B > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do grep -q '^STUB listening' ../stub.log && [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19554/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && r=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19554/actuator/health/readiness) && a=$(curl -s -o ../answer.txt -w '%{http_code}' http://127.0.0.1:19554/probe/pay); "$H/shutdown.sh" 19554 secrets/tiffinbox/shutdown-token > /dev/null; kill "$s"; wait "$s"; wait "$p" && echo "readiness: $r · the pay call: $a · its payment: $(grep -o 'pay-[0-9]*' ../answer.txt || echo none) · URI with undefined scheme in its log: $(grep -c '^java.lang.IllegalArgumentException: URI with undefined scheme$' ../run.log) · requests the stub saw: $(grep -c '^STUB [A-Z]* /' ../stub.log)")
```

As shipped, it prints `readiness: 200 · the pay call: 500 · its payment: none · URI with undefined scheme in its log: 1 · requests the stub saw: 0`
— TiffinBox started and said it was ready, not one WARN line in its log; then the call failed inside TiffinBox, before any request left it:
the stub saw nothing. The words come from the JDK's own client, which was handed a path with no `http://127.0.0.1:…` in front of it.
Read the keys a group takes in Boot's own metadata — this unit's `group` capture prints them, and the class each group binds to — then set
`B=`, from the same shell, and run the last line again.

**Done** when you can print

```
readiness: 200 · the pay call: 200 · its payment: pay-1 · URI with undefined scheme in its log: 0 · requests the stub saw: 1
```

— the group's client called the stub, the stub answered 201 with the payment, and the route passed it on. The same line is in this unit's
`exercise` capture (`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.
