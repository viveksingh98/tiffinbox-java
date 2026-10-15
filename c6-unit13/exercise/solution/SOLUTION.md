# Solution — a converter, and the sources that make it a bean

Run from `c6-unit13/`, after `exercise/README.md`'s commands — in the same shell, or in a new one: the README's two `export`
lines come first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot run this jar: the
JVM stops at once, and `wait $!` ends the line with its exit code). Then one line: the README's last line with one option added after
the port, `--spring.main.sources=probe.web.MealTypeConverter`, in a subshell, so your shell stays in `c6-unit13/`.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
(cd .harness/mine/anchor && { java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19429 --spring.main.sources=probe.web.MealTypeConverter > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19429/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o ../got.json -w '%{http_code}' 'http://127.0.0.1:19429/customers?mealType=veg'); ../../../harness/shutdown.sh 19429 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && n=$(grep -o '"name":"[^"]*"' ../got.json | wc -l | tr -d ' ') && f=$(grep -o '"name":"[^"]*"' ../got.json | sed 's/^"name":"//; s/"$//' | paste -sd' ' -) && echo "GET /customers?mealType=veg: $s · customers: $n · names: ${f:-none}")
```

Measured (this unit's `exercise` capture, `receipts.sh`, 2026-10-15 — run in the same shell as the README's commands, which left
it in `c6-unit13/`):

```
GET /customers?mealType=veg: 200 · customers: 2 · names: Ravi Sunil
```

`--spring.main.sources` names classes the application is built from, beside TiffinBox's own: the converter's class becomes a bean,
and Boot adds every `Converter` bean to Spring MVC's conversion service — the one each request's data binder asks. For a `String`
going to a `MealType` the service now finds the harness's converter before Spring's own one for every enum, and the harness's ignores
case: `veg` is `VEG`, and TiffinBox's method, unchanged, filters by it. The class on the class path alone did nothing: TiffinBox's
component scan reads `com.tiffinbox`, and the harness lives outside it.
