# Solution — the guard that answers twice

Run from `c6-unit18/`, after `exercise/README.md`'s commands — in the same shell, or in a new one: the README's two `export` lines
come first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot run this jar: the JVM stops at
once, and `wait "$p"` ends the line with its exit code). The fix is three lines at the top of `preHandle`, and one import:

```java
import jakarta.servlet.DispatcherType;
…
        if (request.getDispatcherType() != DispatcherType.REQUEST) {
            return true;
        }
```

`solution/Guard.java` is the guard with them, and nothing else changed (this unit's `exercise` capture prints the diff). The lines
below copy it over your copy, then run the README's last line again, unchanged. Copying the same file twice gives the same file, so
run twice they print the same.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
cp exercise/solution/Guard.java .harness/mine/Guard.java
M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*" ../Guard.java && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19479 --spring.main.sources=probe.web.Guard > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19479/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -o /dev/null -w '%{http_code} %{content_type}' -H 'X-Kitchen: closed' http://127.0.0.1:19479/customers/Ravi); ../../../harness/shutdown.sh 19479 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the guard: $a · ERROR lines: $(grep -cE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +ERROR ' ../run.log)")
```

Measured (this unit's `exercise` capture, `receipts.sh` — run in the same shell as the README's commands, which left it in
`c6-unit18/`):

```
the guard: 500 application/json · ERROR lines: 1
```

A handler interceptor added with no path pattern runs for Boot's error controller too: Tomcat's error dispatch is a second request
through Spring MVC, with the first request's headers. A hook that throws there leaves Tomcat nobody to write the answer but itself.
Excluding the error path (`excludePathPatterns("/error")`) is the other way out: this unit's `dispatch` capture measures it (E).
