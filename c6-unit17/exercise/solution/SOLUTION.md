# Solution — the handler that answers first

Run from `c6-unit17/`, after `exercise/README.md`'s commands — in the same shell, or in a new one: the README's two `export` lines
come first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot run this jar: the JVM stops at
once, and `wait "$p"` ends the line with its exit code). The handler list (`.harness/mine/handlers.txt`) names `probe.web.CatchAllFirst`
first, at order -2147483648 — ahead of Boot's `ProblemDetailsExceptionHandler` at 0 — and its one method, `anything`, for every exception
type it lists. Then the fix: the README's last line again, with `probe.web.CatchAllFirst,` taken out of `--spring.main.sources=`. It
changes no file, so run twice it prints the same: it builds the copy again, starts it, asks, stops it.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
M="$PWD/.m2-demo" && (cd .harness/mine/anchor && rm -f ../handlers.txt && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*" ../../../harness/probe/web/CatchAllFirst.java ../../../harness/probe/web/Who.java && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19469 --spring.main.sources=probe.web.Who > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19469/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s -o ../handlers.txt http://127.0.0.1:19469/probe/who/advice; a=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19469/shutdown); b=$(curl -s -o /dev/null -w '%{http_code}' -X DELETE http://127.0.0.1:19469/customers); ../../../harness/shutdown.sh 19469 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "wrong verbs: $a $b")
```

Measured (this unit's `exercise` capture, `receipts.sh` — run in the same shell as the README's commands, which left it in
`c6-unit17/`):

```
wrong verbs: 405 405
```

An advice's order decides who is asked first, not how near its exception type is: a handler for `Exception` ordered ahead of Boot's
takes Spring MVC's own errors too, and answers them in silence. Kept at the default order, the same class would sit behind Boot's handler
(this unit's `catchall` capture) — and still take every exception Boot's handler leaves alone, a name nobody has among them.
