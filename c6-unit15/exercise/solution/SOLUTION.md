# Solution — a handler that forgot its status

Run from `c6-unit15/`, after `exercise/README.md`'s commands — in the same shell, or in a new one: the README's two `export` lines
come first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot run this jar: the JVM stops at
once, and `wait "$p"` ends the line with its exit code). Then the line the handler is missing — `@ResponseStatus(HttpStatus.NOT_FOUND)`,
put back straight after its `@ExceptionHandler(CustomerNotFound.class)` line in the copy's `TiffinBoxErrors.java` (the class already
imports both names; run twice, the line is put back once) — and the README's last line again, exactly as written: it builds the copy again, starts it, asks, stops it.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
f=.harness/mine/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxErrors.java && { grep -q '@ResponseStatus(HttpStatus.NOT_FOUND)' "$f" || { awk '{ print } $0 == "    @ExceptionHandler(CustomerNotFound.class)" { print "    @ResponseStatus(HttpStatus.NOT_FOUND)" }' "$f" > "$f.new" && mv "$f.new" "$f"; }; }
M="$PWD/.m2-demo" && (cd .harness/mine/after && rm -f ../got.json && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19449 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19449/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o ../got.json -w '%{http_code}' http://127.0.0.1:19449/customers/Nobody); ../../../harness/shutdown.sh 19449 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "status: $s · body: $(cat ../got.json)")
```

Measured (this unit's `exercise` capture, `receipts.sh` — run in the same shell as the README's commands, which left it in
`c6-unit15/`):

```
status: 404 · body: {"error":"no customer named Nobody"}
```

An exception handler's answer is a method's answer: its return value is the body, written by the message converters, and its status
is whatever the method names — `@ResponseStatus` on the handler, or a `ResponseEntity` it returns. Name none and it is 200, whatever
the body says. The copy's file is now `after/`'s, byte for byte.
