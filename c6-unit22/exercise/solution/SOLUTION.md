# Solution — a name the template got wrong

Run from `c6-unit22/`, after `exercise/README.md`'s commands — in the same shell, or in a new one: the README's two `export` lines
come first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot run this jar: the JVM stops at
once, and `wait "$p"` ends the line with its exit code). Then the fix — the copy's template reads `${view.custmers}`; the view's
component is `customers`, so `view.custmers` becomes `view.customers` (written to a new file and moved back, so it runs the same on
macOS and Linux; run twice, the second finds nothing to change) — and the README's last line again, exactly as written: it builds the
copy again, starts it, asks, stops it.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
f=.harness/mine/after/tiffinbox-web/src/main/resources/templates/dashboard.html && sed 's/view\.custmers/view.customers/' "$f" > "$f.new" && mv "$f.new" "$f"
M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19518 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19518/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o ../page.html -w '%{http_code} · %{content_type}' -H 'Accept: text/html' http://127.0.0.1:19518/dashboard); ../../../harness/shutdown.sh 19518 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the dashboard: $s · $(sed -n 's/.*<title>\(.*\)<\/title>.*/\1/p' ../page.html)")
```

Measured (this unit's `exercise` capture, `receipts.sh` — run in the same shell as the README's commands, which left it in
`c6-unit22/`):

```
the dashboard: 200 · text/html;charset=UTF-8 · Dashboard · TiffinBox
```

A template is checked when it is rendered, not when it is built: Maven copies it into the jar as a file, and Thymeleaf reads it on
the first request that asks for the page. The JSON route beside it, `TiffinBoxServer`'s `GET /dashboard`, never reads the template —
so curl's own `Accept: */*` got a 200 the whole time (this unit's `errors` capture). When a page fails, the log's first ERROR line is
Thymeleaf's, and it names the template, the expression and its line.
