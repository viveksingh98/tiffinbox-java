# Solution — a five hundred the slice never sees

Run from `c6-unit28/`, after `exercise/README.md`'s commands — in the same shell, or in a new one: the README's two `export` lines come
first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot compile this module: the line
ends with exit 1 and no counts). Then the fix — the copy's `RevenueTest` asserts `.hasStatus(500)`; that becomes
`.hasFailed().failure().hasMessageContaining("kitchen on fire")` (written to a new file and moved back, so it runs the same on macOS
and Linux; run twice, the second finds nothing to change) — and the README's last line again, exactly as written: it runs the test.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
f=.harness/mine/after/tiffinbox-web/src/test/java/com/tiffinbox/web/RevenueTest.java && sed 's/\.hasStatus(500);/.hasFailed().failure().hasMessageContaining("kitchen on fire");/' "$f" > "$f.new" && mv "$f.new" "$f"
M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -pl tiffinbox-web -Dtest=RevenueTest clean test > ../test.log 2>&1; e=$?; x=tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.RevenueTest.xml; echo "exit $e · RevenueTest: $(sed -n 's/.* tests="\([0-9]*\)" errors="\([0-9]*\)" skipped="[0-9]*" failures="\([0-9]*\)".*/tests \1 · errors \2 · failures \3/p' "$x")"; sed -n 's/.*<failure message="&#10;\([^&]*\)&#10; \([^&]*\)&#10;.*/  \1 \2/p' "$x")
```

Measured (this unit's `exercise` capture, `receipts.sh` — run in the same shell as the README's commands, which left it in
`c6-unit28/`):

```
exit 0 · RevenueTest: tests 1 · errors 0 · failures 0
```

`hasFailed()` is `MockMvcTester`'s way of saying "the request ended with an exception nobody handled"; `failure()` is that exception,
and `hasMessageContaining` reads its message, which carries the repository's own `kitchen on fire`. The five hundred is real — but it
is Tomcat's and Boot's, after the error dispatch: TiffinBox's `FullStackTest` asserts it, on a real server.
