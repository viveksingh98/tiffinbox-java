# Exercise — the guard that answers twice

**Your turn:** the README's interceptor turns a five hundred into Tomcat's own page. Make it skip the error dispatch, and ask again.

`exercise/Guard.java` is a handler interceptor that registers itself with Spring MVC (no path pattern, so it sees every handler) and
refuses a request that says the kitchen is closed — `X-Kitchen: closed` — by throwing an `IllegalStateException`. An exception nobody
handles is Boot's job: Tomcat sends the request round a second time, on its **error dispatch**, to Boot's error controller at `/error`,
which writes a JSON 500. But the guard runs on that second pass too — the header is still on the request — and throws again.

Run everything from `c6-unit18/`, in one shell. The commands below copy TiffinBox — `anchor/`, the tree the problem-detail lesson made —
to `.harness/mine/anchor` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), copy the guard to `.harness/mine/Guard.java` (the
file you edit), and give the copy a config tree with a token of its own — 26 random hexadecimal digits (`openssl rand -hex 13`), in
`.harness/mine/anchor/secrets/tiffinbox/shutdown-token`, readable by you alone, never printed. Its last line runs in a subshell (the
parentheses), so your shell stays in `c6-unit18/` for the next run: it builds the copy offline against this unit's `.m2-demo`, extracts
its jar, compiles `.harness/mine/Guard.java` against it (into `.harness/mine/hc`), starts TiffinBox on its class path with the guard
joined (`--spring.main.sources=probe.web.Guard`) on `127.0.0.1:19479` (the JVM's locale pinned, `-Duser.language=en
-Duser.country=US`), waits until readiness answers 200, asks for Ravi with `X-Kitchen: closed` — keeping the status and the content
type — stops TiffinBox with POST /shutdown (`harness/shutdown.sh`, the token read from the copy's own file), waits for that JVM to exit
(`wait "$p"`, the pid it saved: a JVM that failed — another JDK's `java`, say — ends the line with its own exit code, never with an
answer, and so does a build that failed: no JVM, no pid), and prints the answer and the number of ERROR lines in the log (counted by
the log's own line shape: a date, then the level). The whole log is `.harness/mine/run.log`. On a fresh clone `.m2-demo` is empty: run
`./receipts.sh` once first (no GraalVM, no Docker and no browser are needed).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/ && cp exercise/Guard.java .harness/mine/Guard.java
mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*" ../Guard.java && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19479 --spring.main.sources=probe.web.Guard > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19479/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -o /dev/null -w '%{http_code} %{content_type}' -H 'X-Kitchen: closed' http://127.0.0.1:19479/customers/Ravi); ../../../harness/shutdown.sh 19479 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the guard: $a · ERROR lines: $(grep -cE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +ERROR ' ../run.log)")
```

As shipped, it prints `the guard: 500 text/html;charset=utf-8 · ERROR lines: 3` — Tomcat's own HTML error page, whatever the client
asked for, and three ERROR lines where Boot's 500 has one: the error dispatch itself failed, so Tomcat wrote the page. Edit
`.harness/mine/Guard.java`: make `preHandle` let every dispatch but the request's own pass untouched (`request.getDispatcherType()`
tells you which one is running; `jakarta.servlet.DispatcherType` names them). Then run the last line again from the same shell.

**Done** when you can print

```
the guard: 500 application/json · ERROR lines: 1
```

— Boot's JSON 500 again, and one ERROR line: Tomcat's, for the exception the guard threw on the request itself. The same line is in
this unit's `exercise` capture (`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.
