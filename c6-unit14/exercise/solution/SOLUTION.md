# Solution — an HTML page where you wanted JSON

Run from `c6-unit14/`, after `exercise/README.md`'s commands — in the same shell, or in a new one: the README's two `export` lines
come first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot run this jar: the JVM stops
at once, and `wait "$p"` ends the line with its exit code). Then the README's last line with its one header changed — `-H 'Accept:
text/html'` becomes `-H 'Accept: application/json'` — and nothing else: it builds the copy again, starts it, asks, stops it. It
changes no file, so running it twice gives the same line twice.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
M="$PWD/.m2-demo" && (cd .harness/mine/anchor && rm -f ../got.txt && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19439 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19439/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o ../got.txt -w '%{http_code} · Content-Type: %{content_type}' -H 'Accept: application/json' http://127.0.0.1:19439/customers/Nobody); ../../../harness/shutdown.sh 19439 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "status: $s")
```

Measured (this unit's `exercise` capture, `receipts.sh` — run in the same shell as the README's commands, which left it in
`c6-unit14/`):

```
status: 404 · Content-Type: application/json
```

The status was never the problem: Boot's error controller answers a 404 either way. What changes is the type it writes, and it picks
the type from the `Accept` header — `text/html` gets the Whitelabel page (its HTML method), anything a JSON converter can write gets
the four keys. `.harness/mine/got.txt` now holds `{"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"}`.
