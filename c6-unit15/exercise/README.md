# Exercise — a handler that forgot its status

**Your turn:** the README's request for a missing customer answers two hundred. Find the handler's missing line, add it, and ask again.

Since this lesson TiffinBox's `GET /customers/{name}` throws `CustomerNotFound` for a name nobody has, and `TiffinBoxErrors` — a
controller advice, `@RestControllerAdvice` — answers it with one exception handler: `{"error":"no customer named Nobody"}`. The
handler's return value is the body; the status is the handler's to name. The course's harness ships a copy of that class that is one
line short, `harness/exercise/TiffinBoxErrors.java` (outside TiffinBox's own tree).

Run everything from `c6-unit15/`, in one shell. The commands below copy TiffinBox — `after/`, the tree this lesson made — to
`.harness/mine/after` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), put the harness's copy of the advice in place of the
tree's own, and give the copy a config tree with a token of its own — 26 random hexadecimal digits (`openssl rand -hex 13`), in
`.harness/mine/after/secrets/tiffinbox/shutdown-token`, readable by you alone, never printed. Its last line runs in a subshell (the
parentheses), so your shell stays in `c6-unit15/` for the next run: it builds the copy offline against this unit's `.m2-demo`, starts
it from the copy's folder on `127.0.0.1:19449` (the JVM's locale pinned, `-Duser.language=en -Duser.country=US`), waits until
readiness answers 200, asks for a customer nobody has — curl's own `Accept: */*` — and saves the answer to `../got.json`, stops
TiffinBox with POST /shutdown (`harness/shutdown.sh`, the token read from the copy's own file), waits for that JVM to exit (`wait "$p"`, the pid it
saved: a JVM that failed — another JDK's `java`, say — ends the line with its own exit code, never with a status, and so does a build
that failed: no JVM, no pid), and prints the status and
the body. The whole log is `.harness/mine/run.log`. On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once first (no GraalVM
is needed for that, but Docker must answer, with `eclipse-temurin:25-jre` on it: the script checks both before its first build;
without `GRAALVM_HOME` it fills `.m2-demo`, makes every capture that needs none — this exercise's among them — and stops before the
native build).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
cp harness/exercise/TiffinBoxErrors.java .harness/mine/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxErrors.java
mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/after && rm -f ../got.json && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19449 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19449/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o ../got.json -w '%{http_code}' http://127.0.0.1:19449/customers/Nobody); ../../../harness/shutdown.sh 19449 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "status: $s · body: $(cat ../got.json)")
```

As shipped, it prints `status: 200 · body: {"error":"no customer named Nobody"}`: the right words, the wrong status. A client that
reads the status — a browser, a script, a monitor that counts errors — is told the request worked. Spring MVC used the handler,
wrote its map as the body, and, with no status named, answered as for any method that returns normally. Open the copy's
`TiffinBoxErrors.java` (`.harness/mine/after/tiffinbox-web/src/main/java/com/tiffinbox/web/`) — or compare it with `after/`'s — find
the line the handler is missing, add it, and run the last line again from the same shell.

**Done** when you can print

```
status: 404 · body: {"error":"no customer named Nobody"}
```

— the same body, and the status that says what happened. The same line is in this unit's `exercise` capture (`.r-exercise.out`). The
measured answer, run exactly as written: `solution/SOLUTION.md`.
