# Solution — RestClient, built from the template

`RestClient.create()` makes a client from nothing: no interceptor, and no observation. `RestClient.create(template)` — spring-web's own
way from a template to a client — takes what the template was set up with: here its request factory (the JDK's client, under Boot's
builder), its interceptor (`Via`, so `X-Via` goes out again), and Boot's observation of every call. One change, in the copy of the route
the README made — `RestClient.create()` becomes `RestClient.create(template)` (`sed -i ''` is macOS's in-place edit; run twice, the second
finds nothing left to change) — and the README's last line runs again, unchanged, in the same shell. A new shell's `java` may be another
JDK (the Mac's own is 23, which refuses the anchor's Java 25 at compile), so the two export lines come first:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
sed -i '' 's/RestClient\.create()/RestClient.create(template)/' .harness/mine/src/TemplateRoutes.java
M="$PWD/.m2-demo" && H="$PWD/harness" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && mvn -o -B -q -Dmaven.repo.local="$M" -f "$H/pom.xml" dependency:build-classpath -Dmdep.outputFile="$PWD/../harness.cp" && rm -f ../xlib/* && tr ':' '\n' < ../harness.cp | while IFS= read -r j; do [ -e "tiffinbox-web/target/extracted/lib/${j##*/}" ] || ! unzip -l "$j" | grep -q '\.class$' || cp "$j" ../xlib/; done && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*:../xlib/*" ../src/*.java && { java -Duser.language=en -Duser.country=US "$H/stub/Stub.java" --port=19566 --www="$H/stub/www" > ../stub.log 2>&1 & } && s=$! && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19564 --spring.main.sources=probe.web.TemplateRoutes > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do grep -q '^STUB listening' ../stub.log && [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19564/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -o ../old.txt -w '%{http_code}' http://127.0.0.1:19564/probe/old) && b=$(curl -s -o ../moved.txt -w '%{http_code}' http://127.0.0.1:19564/probe/moved) && o=$(curl -s http://127.0.0.1:19564/actuator/prometheus | awk '/^http_client_requests_seconds_count/ && index($0, "uri=\"/{f}\"") { s += $NF } END { print s + 0 }'); "$H/shutdown.sh" 19564 secrets/tiffinbox/shutdown-token > /dev/null; kill "$s"; wait "$s"; wait "$p" && echo "the old call: $a · the moved call: $b · requests at the stub with X-Via: $(grep -c '^STUB-H x-via: template-interceptor$' ../stub.log) of $(grep -c '^STUB [A-Z]* /' ../stub.log) · observed calls: $o")
```

Measured, run exactly as written after the README's lines (this unit's `exercise` capture):

```
the old call: 200 · the moved call: 200 · requests at the stub with X-Via: 2 of 2 · observed calls: 2
```

The stub saw `x-via: template-interceptor` on both requests, and the scrape counted both calls under `/{f}`. What the move does not
carry is the template's `Accept` header: the moved call still sends none — RestClient's own habit (this unit's `migrate` capture).
