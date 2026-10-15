# Solution — every field error in Boot's own body, and a key Boot no longer reads

Run from `c6-unit12/`, after `exercise/README.md`'s commands — in the same shell, or in a new one: the README's two `export`
lines come first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot run this jar: the
JVM stops at once, and `wait $!` ends the line with its exit code). Then one line: the README's last line with its last option
given by Boot 4's name, `--spring.web.error.include-binding-errors=always`, in a subshell, so your shell stays in `c6-unit12/`.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
(cd .harness/mine/after && { java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19419 --spring.main.sources=probe.web.Unbound --spring.web.error.include-binding-errors=always > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19419/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o ../got.json -w '%{http_code}' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":110,"mealType":"LUNCH"}' http://127.0.0.1:19419/probe/unbound); ../../../harness/shutdown.sh 19419 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && n=$(grep -o '"field":"[^"]*"' ../got.json | wc -l | tr -d ' ') && f=$(grep -o '"field":"[^"]*"' ../got.json | sed 's/^"field":"//; s/"$//' | sort | paste -sd' ' -) && echo "status: $s · errors: $n · fields: ${f:-none}")
```

Measured (this unit's `exercise` capture, `receipts.sh`, 2026-10-15 — run in the same shell as the README's commands, which left
it in `c6-unit12/`):

```
status: 400 · errors: 3 · fields: mealType mealsPerDay name
```

Boot 4 reads its error keys under `spring.web.error` — `include-binding-errors`, `include-message`, `include-exception` and the rest —
and the name the README gave, Boot 3's, is in Boot 4's metadata as deprecated at level *error*, replaced by this one; a property Boot no
longer reads changes nothing and logs nothing. With the key Boot reads, its error body gains `errors`: the three field errors the body
broke, each whole. Their order in the array moves between runs — Hibernate Validator hands its violations over as a set — so the line
sorts the fields. TiffinBox's own POST /customers needs none of this: its `BindingResult` lets the method answer with each field and its
message, one line.
