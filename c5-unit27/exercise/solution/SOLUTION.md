# Solution — a banner that prints TiffinBox's version

Run from `c5-unit27/`, after `exercise/README.md`'s commands. One line: it writes the banner, builds the copy offline with the
class-path line, starts the jar and then the folder run on 19069 — each one waited on until readiness answers 200, then stopped
with POST /shutdown (`harness/shutdown.sh`, the token read from the copy's own file) — and prints each log's banner line.

```bash
M="$PWD/.m2-demo" H="$PWD/harness" && cd .harness/mine/after && printf '%s\n' 'TiffinBox version=[${application.version}]' > tiffinbox-web/src/main/resources/banner.txt && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt && for w in jar folders; do if [ $w = jar ]; then java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19069 > $w.log 2>&1 & else java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19069 > $w.log 2>&1 & fi; for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19069/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done; "$H/shutdown.sh" 19069 secrets/tiffinbox/shutdown-token > /dev/null; wait; done; echo "the jar: $(grep -m1 '^TiffinBox version=' jar.log) · the folders: $(grep -m1 '^TiffinBox version=' folders.log)"
```

Measured (this unit's `exercise` capture, `receipts.sh`, 2026-10-08):

```
the jar: TiffinBox version=[1.0.0] · the folders: TiffinBox version=[]
```

The placeholder, not a typed version, is what the line tells apart. The same line with `TiffinBox version=[1.0.0]` typed into
the file instead (measured once by hand, 2026-10-08, after the README's commands) printed
`the jar: TiffinBox version=[1.0.0] · the folders: TiffinBox version=[1.0.0]` — the folders "know" a version nobody read, and the
done line does not match.
