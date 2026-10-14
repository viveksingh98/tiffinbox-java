# Solution — a new customer, and the header that says it is JSON

Run from `c6-unit08/`, after `exercise/README.md`'s commands — in the same shell, or in a new one: the README's two `export`
lines come first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot run this jar: the
JVM stops at once, and `wait $!` ends the line with its exit code). Then one line: the README's last line with the header the 415's
`Accept` header asks for — `-H 'Content-Type: application/json'` — on its POST, in a subshell, so your shell stays in `c6-unit08/`.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
(cd .harness/mine/after && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19379 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19379/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s -D ../head.txt -o ../body.txt -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19379/customers; n=$(curl -s http://127.0.0.1:19379/customers | grep -o '"name":"' | wc -l | tr -d ' '); ../../../harness/shutdown.sh 19379 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && a=$(grep -i '^accept:' ../head.txt | sed 's/^[^:]*: *//' | tr -d '\r') && echo "status: $(sed -n '1s/^HTTP\/1\.1 \([0-9]*\).*/\1/p' ../head.txt) · its Accept header: ${a:-none} · customers now: $n")
```

Measured (this unit's `exercise` capture, `receipts.sh`, 2026-10-14 — run in the same shell as the README's commands, which left
it in `c6-unit08/`):

```
status: 200 · its Accept header: none · customers now: 5
```

Without the header the same line prints `status: 415 · its Accept header: application/json, application/*+json · customers now:
4`: curl's `--data` names a form, `application/x-www-form-urlencoded`; Spring MVC's converter that reads forms reads a map of names
to values, never a `Customer`, and the one that reads a `Customer` reads JSON — so Spring MVC answers 415, lists in `Accept` the
types it can read a `Customer` from, and logs one WARN line, `HttpMediaTypeNotSupportedException: Content-Type
'application/x-www-form-urlencoded;charset=UTF-8' is not supported` (this unit's `ctype` capture). With the header, the JSON
converter reads the body into the record, TiffinBox's method stores it, and the answer is the record, 200 — no `Accept` header,
nothing logged.
