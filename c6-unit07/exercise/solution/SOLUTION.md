# Solution — the meal type, as Spring reads it

Run from `c6-unit07/`, after `exercise/README.md`'s commands — in the same shell, or in a new one: the README's two `export`
lines come first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot run this jar: the
JVM stops at once, and `wait $!` ends the line with its exit code). Then one line: the README's last line with the meal type
spelt as `MealType` spells it — `VEGAN` — in a subshell, so your shell stays in `c6-unit07/`.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
(cd .harness/mine/after && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19369 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19369/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s -D ../head.txt -o ../body.txt 'http://127.0.0.1:19369/customers?mealType=VEGAN'; ../../../harness/shutdown.sh 19369 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && n=$(grep -o '"name":"[^"]*"' ../body.txt | sed 's/^"name":"//; s/"$//' | paste -sd' ' -) && w=$(grep -m1 -o "Failed to convert value of type [^;]*" ../run.log || true) && echo "status: $(sed -n '1s/^HTTP\/1\.1 \([0-9]*\).*/\1/p' ../head.txt) · customers: $(grep -o '"name":"' ../body.txt | wc -l | tr -d ' ')${n:+ ($n)} · conversion failure: ${w:-none}")
```

Measured (this unit's `exercise` capture, `receipts.sh`, 2026-10-14 — run in the same shell as the README's commands, which left
it in `c6-unit07/`):

```
status: 200 · customers: 1 (Priya) · conversion failure: none
```

With `mealType=vegan` the same line prints `status: 400 · customers: 0 · conversion failure: Failed to convert value of type 'java.lang.String'
to required type 'com.tiffinbox.MealType'`: Spring MVC's `DefaultHandlerExceptionResolver` logs the whole reason at WARN —
`MethodArgumentTypeMismatchException: Method parameter 'mealType': Failed to convert …` — and answers Boot's 400 body, which
names no reason (this unit's `params` capture). The text must be one of `MealType`'s names, exactly as the enum spells them:
`veg` is refused the same way, `VEG` and `VEGAN` are read (`params`, `forms`). A converter that reads `vegan` too is *Binding,
Converters and Formatters*' subject.
