# Solution — a session id in the address

Run from `c6-unit24/`, after `exercise/README.md`'s commands — in the same shell, or in a new one: the README's two `export` lines
come first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot build or run this jar: the
line ends with an exit code and prints nothing). Then the fix — the copy's `tiffinbox-local.yaml` sets
`server.servlet.session.tracking-modes: cookie,url`; `cookie,url` becomes `cookie` (written to a new file and moved back, so it runs the
same on macOS and Linux; run twice, the second finds nothing to change) — and the README's last line again, exactly as written: it
builds the copy again, starts it, posts the form, stops it.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
f=.harness/mine/after/tiffinbox-local.yaml && sed 's/tracking-modes: cookie,url/tracking-modes: cookie/' "$f" > "$f.new" && mv "$f.new" "$f"
M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19538 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19538/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o /dev/null -w '%{http_code} · %{redirect_url}' --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:19538/customers | sed -E 's/jsessionid=[0-9A-F]+/jsessionid=<id>/'); ../../../harness/shutdown.sh 19538 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the redirect: $s")
```

Measured (this unit's `exercise` capture, `receipts.sh` — run in the same shell as the README's commands, which left it in
`c6-unit24/`):

```
the redirect: 302 · http://127.0.0.1:19538/dashboard
```

Tomcat writes a session's id into an address only when the tracking modes include `url` and the client sent no cookie it could read
the id from — a client's first request that makes a session. With `cookie` alone the id travels in `Set-Cookie` and nowhere else.
Removing the line from `tiffinbox-local.yaml` works too: `application.yaml`'s own key is `cookie`.
