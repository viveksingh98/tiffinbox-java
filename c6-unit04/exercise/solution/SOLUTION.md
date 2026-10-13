# Solution — two pool threads, eight slow requests

Run from `c6-unit04/`, after `exercise/README.md`'s commands — in the same shell, or in a new one: the README's two `export`
lines come first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot run this jar: the
JVM stops at once, and `wait $!` ends the line with its exit code). Then one line: the README's last line with
`--spring.threads.virtual.enabled=false` added — virtual threads off for this run, so Tomcat's pool of platform threads answers,
capped at two by `--server.tomcat.threads.max=2` — in a subshell, so your shell stays in `c6-unit04/`.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
(cd .harness/mine/after && { java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19339 --spring.main.sources=probe.web.Threads --server.tomcat.threads.max=2 --spring.threads.virtual.enabled=false > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19339/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && ../../../harness/slow8.sh 19339 > ../slow.txt && ../../../harness/shutdown.sh 19339 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && echo "threads that answered: $(sort -u ../slow.txt | wc -l | tr -d ' ')")
```

Measured (this unit's `exercise` capture, `receipts.sh`, 2026-10-13 — run in the same shell as the README's commands, which left
it in `c6-unit04/`):

```
threads that answered: 2
```

Without the option the same line prints 8: with virtual threads on, Tomcat runs each request on a new virtual thread, and the
cap on its pool changes nothing (this unit's `threads` capture: A, and B for the pool of two). On the JVM only: under Spring's
AOT step the build decides, and a run-time `--spring.threads.virtual.enabled=false` changes nothing (`threads` C).
