# Solution — the Allow header

Run from `c6-unit06/`, after `exercise/README.md`'s commands — in the same shell, or in a new one: the README's two `export`
lines come first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot run this jar: the
JVM stops at once, and `wait $!` ends the line with its exit code). Then one line: the README's last line without `-X DELETE` —
curl's own verb, GET, the one the `Allow` header named — in a subshell, so your shell stays in `c6-unit06/`.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
(cd .harness/mine/after && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19359 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19359/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s -D ../head.txt -o ../body.txt http://127.0.0.1:19359/customers; ../../../harness/shutdown.sh 19359 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && a=$(tr -d '\r' < ../head.txt | sed -n 's/^Allow: //p') && echo "status: $(sed -n '1s/^HTTP\/1\.1 \([0-9]*\).*/\1/p' ../head.txt) · Allow: ${a:-none} · customers: $(grep -o '"name"' ../body.txt | wc -l | tr -d ' ')")
```

Measured (this unit's `exercise` capture, `receipts.sh`, 2026-10-14 — run in the same shell as the README's commands, which left
it in `c6-unit06/`):

```
status: 200 · Allow: none · customers: 4
```

With `-X DELETE` the same line prints `status: 405 · Allow: GET · customers: 0`: Spring MVC's own 405, its `Allow` header read off
the mapping (`@GetMapping("/customers")`: GET, and HEAD with it — the `verbs` capture answers HEAD 200 and lists
`GET,HEAD,OPTIONS` for OPTIONS). On the previous tree, the embedded-Tomcat lesson's, TiffinBox's own handler answered that DELETE
with a 405 of its own and no `Allow` header at all (this unit's `verbs` capture, before).
