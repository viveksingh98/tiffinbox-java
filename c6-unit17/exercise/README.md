# Exercise — the handler that answers first

**Your turn:** the README's run turns every wrong verb into a five hundred. Read the handler list, remove the one that's first, and count again.

TiffinBox answers a wrong verb — GET on `/shutdown`, DELETE on `/customers` — with a 405 problem detail: Boot's
`ProblemDetailsExceptionHandler`, the advice at order 0, answers it. The course's harness ships a catch-all,
`harness/probe/web/CatchAllFirst.java`: one `@ExceptionHandler(Exception.class)`, ordered first (`HIGHEST_PRECEDENCE`), answering 500
"something went wrong". The run below joins it to TiffinBox — and the harness's `Who`, which writes the handler list: the advices in the
order Spring MVC asks them.

Run everything from `c6-unit17/`, in one shell. The commands below copy TiffinBox — `anchor/`, the tree the problem-detail lesson made — to
`.harness/mine/anchor` (git-ignored; `receipts.sh` wipes `.harness/` when it runs) and give the copy a config tree with a token of its own —
26 random hexadecimal digits (`openssl rand -hex 13`), in `.harness/mine/anchor/secrets/tiffinbox/shutdown-token`, readable by you alone,
never printed. Its last line runs in a subshell (the parentheses), so your shell stays in `c6-unit17/` for the next run: it builds the copy
offline against this unit's `.m2-demo`, extracts its jar, compiles the two harness classes against it (into `.harness/mine/hc`), starts
TiffinBox on its class path with both joined (`--spring.main.sources=`) on `127.0.0.1:19469` (the JVM's locale pinned,
`-Duser.language=en -Duser.country=US`), waits until readiness answers 200, saves the handler list to `.harness/mine/handlers.txt`, asks
GET `/shutdown` and DELETE `/customers` — keeping each status — stops TiffinBox with POST /shutdown (`harness/shutdown.sh`, the token read
from the copy's own file), waits for that JVM to exit (`wait "$p"`, the pid it saved: a JVM that failed — another JDK's `java`, say — ends
the line with its own exit code, never with a status, and so does a build that failed: no JVM, no pid), and prints the two statuses. The
whole log is `.harness/mine/run.log`. On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once first (no GraalVM and no Docker are
needed).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/
mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/anchor && rm -f ../handlers.txt && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*" ../../../harness/probe/web/CatchAllFirst.java ../../../harness/probe/web/Who.java && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19469 --spring.main.sources=probe.web.CatchAllFirst,probe.web.Who > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19469/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s -o ../handlers.txt http://127.0.0.1:19469/probe/who/advice; a=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19469/shutdown); b=$(curl -s -o /dev/null -w '%{http_code}' -X DELETE http://127.0.0.1:19469/customers); ../../../harness/shutdown.sh 19469 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "wrong verbs: $a $b")
```

As shipped, it prints `wrong verbs: 500 500`: two requests Spring MVC knows the answer to, both answered "something went wrong" — and
the log has no line for either (count its WARN and ERROR lines). Open `.harness/mine/handlers.txt`: its advice cache lists the advices
in the order Spring MVC asks them, each with its order, and for each exception type the method each one would answer it with. Find the
one that's first, take it out of `--spring.main.sources=` on the last line (leave `probe.web.Who`), and run the last line again from the
same shell. Moving the class is not the point: any advice ordered ahead of Boot's, holding a handler for `Exception`, answers first.

**Done** when you can print

```
wrong verbs: 405 405
```

— Boot's 405 problem details again, and two WARN lines in the copy's log, one for each (this unit's `catchall` capture names
the logger: Spring MVC's `PageNotFound`). The same line is in this unit's `exercise`
capture (`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.
