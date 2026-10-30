# Solution — lower the floor

The key is `server.compression.min-response-size` - in Boot 4.1.1's metadata (this unit's `which` capture: `min-response-size ·
default 2KB · DataSize`): the floor. Tomcat tests it against an answer's length when the answer has one - the list says
`Content-Length: 282`, under 2KB, so it went plain; the dashboard page is a chunked answer (sent in pieces, no length up front), so there
was no length to test, and it was zipped. With the floor at 128 bytes, the list's 282 reach it. One line changes - `V=( ... )` - and the
README's last line runs again, unchanged, in the same shell. A new shell's `java` may be another JDK (the Mac's own java is 23: it can
neither compile nor run the anchor's Java 25 classes, class file 69), and it has no `S`, so the two export lines and the `S=` line come first, as the README gives them:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
S="$PWD/harness/shutdown.sh"
V=(--server.compression.enabled=true --server.compression.min-response-size=128)
M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19596 "${V[@]}" > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19596/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && b=$(curl -s -o /dev/null -D ../head.txt -H 'Accept-Encoding: gzip' -w '%{size_download}' http://127.0.0.1:19596/customers) && "$S" 19596 secrets/tiffinbox/shutdown-token > ../stop.txt && { wait "$p"; echo "/customers, gzip asked: $b bytes · Content-Encoding: $(tr -d '\r' < ../head.txt | grep -i '^content-encoding: ' | cut -d' ' -f2 | grep . || echo none) · TiffinBox stopped by: POST /shutdown, $(awk '{ print $4 }' ../stop.txt)"; })
```

Measured, run exactly as written after the README's lines (this unit's `exercise` capture):

```
/customers, gzip asked: 129 bytes · Content-Encoding: gzip · TiffinBox stopped by: POST /shutdown, 200
```

The floor is a size, not a rule about JSON: an answer of known length under it goes plain, whatever its type; an answer with no length
has nothing for it to test - here, the page was zipped at 962 bytes (its type on the list, gzip asked). 129 bytes for 282 is this list's ratio - four rows - and a
grown list of near-identical rows zips to about a tenth (this unit's `floor` capture). Which answers an API should shrink, and how, is
Course 9's *Sparse Fieldsets and Compression*.
