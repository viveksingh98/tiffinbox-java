# Solution — the key, spelled as Boot 4.1 reads it

Boot 4.1's client keys are `spring.http.clients.*` — plural. The README's `T=` spells the read timeout the way Boot 3 did, a key Boot 4.1's
metadata lists as deprecated since 4.0.0, replaced by `spring.http.clients.read-timeout`; given as an option it changes nothing, and nothing
in the log says so (this unit's `timeouts` capture, B: 0 WARN, 0 lines that say "deprecat"). One line changes — `T=` — and the README's last
line runs again, unchanged, in the same shell. A new shell's `java` may be another JDK (the Mac's own is 23, which refuses the anchor's
Java 25 at compile), so the two export lines come first:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
T=--spring.http.clients.read-timeout=1s
M="$PWD/.m2-demo" && H="$PWD/harness" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && mvn -o -B -q -Dmaven.repo.local="$M" -f "$H/pom.xml" dependency:build-classpath -Dmdep.outputFile="$PWD/../harness.cp" && rm -f ../xlib/* && tr ':' '\n' < ../harness.cp | while IFS= read -r j; do [ -e "tiffinbox-web/target/extracted/lib/${j##*/}" ] || ! unzip -l "$j" | grep -q '\.class$' || cp "$j" ../xlib/; done && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*:../xlib/*" "$H"/probe/web/*.java && { java -Duser.language=en -Duser.country=US "$H/stub/Stub.java" --port=19546 --www="$H/stub/www" > ../stub.log 2>&1 & } && s=$! && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19544 --spring.main.sources=probe.web.CallRoutes "$T" > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do grep -q '^STUB listening' ../stub.log && [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19544/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -o ../answer.txt -w '%{http_code}' 'http://127.0.0.1:19544/probe/remote?path=/slow'); "$H/shutdown.sh" 19544 secrets/tiffinbox/shutdown-token > /dev/null; kill "$s"; wait "$s"; wait "$p" && echo "the slow call: $a · Request cancelled in its log: $(grep -c '^java.net.http.HttpTimeoutException: Request cancelled$' ../run.log)")
```

Measured, run exactly as written after the README's lines (this unit's `exercise` capture):

```
the slow call: 500 · Request cancelled in its log: 1
```

The route's answer is TiffinBox's 500 — Boot's four keys — and TiffinBox's log holds one ERROR, Tomcat's `[dispatcherServlet]`, whose
message ends in `Request cancelled`, its root cause `java.net.http.HttpTimeoutException: Request cancelled`.
