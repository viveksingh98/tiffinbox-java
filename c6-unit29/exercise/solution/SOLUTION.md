# Solution — give unversioned requests a version

The key is `spring.mvc.apiversion.default` — in Boot 4.1.1's metadata (this unit's `surface` capture, `default · default none ·
String`): the version a request gets when it sends none. With `1.0`, every request without an `API-Version` header is a 1.0 request,
and a mapping with no version takes any version — so TiffinBox's own routes answer as they did, and POST /shutdown stops it again. One
line changes — `V=` — and the README's last line runs again, unchanged, in the same shell. A new shell's `java` may be another JDK (the
Mac's own is 23, which refuses the anchor's Java 25 at compile), and it has no `CURLSET`, so the two export lines and the `CURLSET` line
come first, as the README gives them:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
CURLSET="$PWD/../c5-unit11/curlset.sh"
V="--spring.mvc.apiversion.use.header=API-Version --spring.mvc.apiversion.default=1.0"
M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19585 $V > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19585/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && "$CURLSET" 19585 secrets/tiffinbox/shutdown-token > ../seven.txt && if grep -qE '^POST +/shutdown +-> 2' ../seven.txt; then how="POST /shutdown"; else kill "$p" && how="its pid - POST /shutdown answered $(grep -E '^POST +/shutdown' ../seven.txt | awk '{ print $4 }')"; fi && { wait "$p"; echo "the seven: md5 $(md5 -q ../seven.txt) · answered 400: $(grep -c -- ' -> 400 ' ../seven.txt) · TiffinBox stopped by: $how"; })
```

Measured, run exactly as written after the README's lines (this unit's `exercise` capture):

```
the seven: md5 466c20ed7e0d5439cb052f32ce09de1b · answered 400: 0 · TiffinBox stopped by: POST /shutdown
```

The default answers the seven, not every question: a request that names a version the handlers do not know still answers 400, and with
the default every unversioned request is a 1.0 request — so a deprecation set on 1.0 reaches TiffinBox's own routes too (this unit's
`deprecation` capture). Which strategy an API should use, and how it retires a version, is Course 9's *Versioning Strategies*.
