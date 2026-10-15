# Solution — one customer as XML, and the header that asks for it

Run from `c6-unit11/`, after `exercise/README.md`'s commands — in the same shell, or in a new one: the README's two `export`
lines come first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot run this jar: the
JVM stops at once, and `wait $!` ends the line with its exit code). Then one line: the README's last line with its one header made
the one that asks for a format — `-H 'Accept: application/xml'` where it said `-H 'Content-Type: application/xml'` — in a subshell,
so your shell stays in `c6-unit11/`.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
(cd .harness/mine/xml && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19409 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19409/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && t=$(curl -s -o ../got.txt -w '%{http_code} · %{content_type}' -H 'Accept: application/xml' http://127.0.0.1:19409/customers/Ravi); ../../../harness/shutdown.sh 19409 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && r=$(sed -n 's/^<\([A-Za-z]*\)>.*/\1/p' ../got.txt) && echo "GET /customers/Ravi: $t · root element: ${r:-none}")
```

Measured (this unit's `exercise` capture, `receipts.sh`, 2026-10-15 — run in the same shell as the README's commands, which left
it in `c6-unit11/`):

```
GET /customers/Ravi: 200 · application/xml;charset=UTF-8 · root element: Customer
```

`Content-Type` describes a body you send; a GET sends none, so the route never read the header, and curl's own `Accept: */*` let
TiffinBox answer in its first format, JSON. `Accept` is the header that asks: Spring MVC compares `application/xml` with what its
converters can write for a `Customer`, finds the seventh — Jackson's XML converter, there because the copy holds the XML module —
and answers `application/xml;charset=UTF-8`, Ravi's fields as elements inside one root element, `<Customer>`, named after the
record's class.
