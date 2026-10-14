# Solution — snake-case keys, and the word Jackson knows

Run from `c6-unit09/`, after `exercise/README.md`'s commands — in the same shell, or in a new one: the README's two `export`
lines come first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot run this jar: the
JVM stops at once, and the line prints its exit code with no keys). Then one line: the README's last line with the naming
strategy's value written as Jackson's constant — `SNAKE_CASE` — in a subshell, so your shell stays in `c6-unit09/`.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
(cd .harness/mine/after && rm -f ../ravi.json && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19389 --spring.jackson.property-naming-strategy=SNAKE_CASE > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19389/actuator/health/readiness)" = 200 ] && break; kill -0 $! 2> /dev/null || break; sleep 0.25; done; curl -s -o ../ravi.json http://127.0.0.1:19389/customers/Ravi; ../../../harness/shutdown.sh 19389 secrets/tiffinbox/shutdown-token > /dev/null; wait $!; e=$?; k=$(grep -o '"[A-Za-z_]*":' ../ravi.json 2> /dev/null | tr -d '":' | paste -sd' ' -); c=$(grep '^Caused by: ' ../run.log | tail -1 | sed 's/^Caused by: //'); echo "exit $e · its last cause: ${c:-none} · Ravi's keys: ${k:-none}")
```

Measured (this unit's `exercise` capture, `receipts.sh`, 2026-10-14 — run in the same shell as the README's commands, which left
it in `c6-unit09/`):

```
exit 0 · its last cause: none · Ravi's keys: name meals_per_day price_per_meal meal_type
```

The changed keys: `mealsPerDay` → `meals_per_day`, `pricePerMeal` → `price_per_meal`, `mealType` → `meal_type`; `name` is the same
in both cases. With `snake_case` the same line prints `exit 1 · its last cause: java.lang.IllegalStateException: Constant named
'snake_case' not found · Ravi's keys: none`: Boot hands the value to Jackson as the name of one of `PropertyNamingStrategies`'s
constants, and the name must match exactly — `SNAKE_CASE`, upper case. Boot logs no failure analysis for it — no `APPLICATION FAILED
TO START` — only Spring's chain of causes, over a hundred stack frames (this unit's `naming` capture, C). The strategy renames a
record's properties, never a map's keys: of the seven, only `/customers` changes (`naming`, B), and a property named by
`@JsonProperty` keeps that name (`rename`, and `naming` B).
