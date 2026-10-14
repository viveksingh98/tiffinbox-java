# Solution — a name with a space, and the URL TiffinBox hands back

Run from `c6-unit10/`, after `exercise/README.md`'s commands — in the same shell, or in a new one: the README's two `export`
lines come first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot run this jar: the
JVM stops at once, and `wait $!` ends the line with its exit code). Then one line: the README's last line with its fetch's URL made
the Location the POST's answer named — `"$l"`, which the line already reads from `../head.txt` — in a subshell, so your shell stays
in `c6-unit10/`.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
(cd .harness/mine/after && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19399 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19399/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s -D ../head.txt -o /dev/null -H 'Content-Type: application/json' --data '{"name":"Sunil K","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"}' http://127.0.0.1:19399/customers; l=$(grep -i '^location:' ../head.txt | sed 's/^[^:]*: *//' | tr -d '\r'); rm -f ../got.json; f=$(curl -s -o ../got.json -w '%{http_code}' "$l"); ../../../harness/shutdown.sh 19399 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && g=$(grep -o '"name":"[^"]*"' ../got.json 2> /dev/null | sed 's/^"name":"//; s/"$//') && echo "POST: $(sed -n '1s/^HTTP\/1\.1 \([0-9]*\).*/\1/p' ../head.txt) · Location: ${l:-none} · fetch: $f · got: ${g:-none}")
```

Measured (this unit's `exercise` capture, `receipts.sh`, 2026-10-14 — run in the same shell as the README's commands, which left
it in `c6-unit10/`):

```
POST: 201 · Location: http://127.0.0.1:19399/customers/Sunil%20K · fetch: 200 · got: Sunil K
```

Typed by hand, the URL holds a raw space, and curl will not send it: `000`, no answer, curl's exit code 3 (a malformed URL). The
Location is the same URL as Spring built it — `ServletUriComponentsBuilder`, from the URL the POST came to, the name appended and
encoded, the space as `%20` — so the fetch reaches TiffinBox, the binding lesson's route reads the name back as `Sunil K`, and the
answer is the customer, 200. Each fresh JVM starts with the four customers TiffinBox seeds, so the POST is a 201 every run, never a
409.
