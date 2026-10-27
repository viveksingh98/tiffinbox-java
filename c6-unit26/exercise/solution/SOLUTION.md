# Solution — tell the group where the payment service lives

A service group's client takes its address from one key: `spring.http.serviceclient.<group>.base-url` — `spring.http.serviceclient` is,
in Boot 4.1.1's metadata, a map from a group's name to `HttpClientProperties`, whose `setBaseUrl` is the `base-url` (this unit's `group`
capture). With no key the group's client is still built, and TiffinBox still starts — nothing checks the address until a call needs one.
One line changes — `B=` — and the README's last line runs again, unchanged, in the same shell. A new shell's `java` may be another JDK (the
Mac's own is 23, which refuses the anchor's Java 25 at compile), so the two export lines come first:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
B=--spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556
M="$PWD/.m2-demo" && H="$PWD/harness" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && mvn -o -B -q -Dmaven.repo.local="$M" -f "$H/pom.xml" dependency:build-classpath -Dmdep.outputFile="$PWD/../harness.cp" && rm -f ../xlib/* && tr ':' '\n' < ../harness.cp | while IFS= read -r j; do [ -e "tiffinbox-web/target/extracted/lib/${j##*/}" ] || ! unzip -l "$j" | grep -q '\.class$' || cp "$j" ../xlib/; done && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*:../xlib/*" "$H"/probe/web/*.java && { java -Duser.language=en -Duser.country=US "$H/stub/Stub.java" --port=19556 --www="$H/stub/www" > ../stub.log 2>&1 & } && s=$! && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19554 --spring.main.sources=probe.web.PaymentConfig,probe.web.PayRoutes $B > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do grep -q '^STUB listening' ../stub.log && [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19554/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && r=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19554/actuator/health/readiness) && a=$(curl -s -o ../answer.txt -w '%{http_code}' http://127.0.0.1:19554/probe/pay); "$H/shutdown.sh" 19554 secrets/tiffinbox/shutdown-token > /dev/null; kill "$s"; wait "$s"; wait "$p" && echo "readiness: $r · the pay call: $a · its payment: $(grep -o 'pay-[0-9]*' ../answer.txt || echo none) · URI with undefined scheme in its log: $(grep -c '^java.lang.IllegalArgumentException: URI with undefined scheme$' ../run.log) · requests the stub saw: $(grep -c '^STUB [A-Z]* /' ../stub.log)")
```

Measured, run exactly as written after the README's lines (this unit's `exercise` capture):

```
readiness: 200 · the pay call: 200 · its payment: pay-1 · URI with undefined scheme in its log: 0 · requests the stub saw: 1
```

The route's answer is the stub's payment, as the interface's client read it into a `Payment` record and Spring MVC wrote it back as JSON
(`.harness/mine/answer.txt`); TiffinBox's log holds no ERROR, and the stub's dump one request, `POST /payments`.
