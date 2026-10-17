# Solution — a key Boot never read

Run from `c6-unit16/`, after `exercise/README.md`'s commands — in the same shell, or in a new one: the README's two `export` lines
come first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot run this jar: the JVM stops at
once, and `wait "$p"` ends the line with its exit code). Then the fix — the copy's `tiffinbox-local.yaml` names
`spring.mvc.problemdetail.enabled`, singular, as the class is named; Boot's key is `spring.mvc.problemdetails.enabled`, plural, so the
line `    problemdetail:` becomes `    problemdetails:` (written to a new file and moved back, so it runs the same on macOS and Linux; run
twice, the second finds nothing to change) — and the README's last line again, exactly as written: it builds the copy again, starts
it, asks, stops it.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
f=.harness/mine/after/tiffinbox-local.yaml && sed 's/^    problemdetail:$/    problemdetails:/' "$f" > "$f.new" && mv "$f.new" "$f"
M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19459 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19459/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o /dev/null -w '%{http_code} · Content-Type: %{content_type}' http://127.0.0.1:19459/nowhere); ../../../harness/shutdown.sh 19459 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "nowhere: $s")
```

Measured (this unit's `exercise` capture, `receipts.sh` — run in the same shell as the README's commands, which left it in
`c6-unit16/`):

```
nowhere: 404 · Content-Type: application/problem+json
```

A key Boot does not know is not an error: Boot binds the keys it has a property for, and the rest stay in the environment, read by
nobody, with no line in the log. Its relaxed binding forgives a dash — `problem-details` (this unit's `losers` capture) — never a
letter missing. When an answer does not change, read the key back against Boot's own metadata (this unit's `change` capture prints it).
