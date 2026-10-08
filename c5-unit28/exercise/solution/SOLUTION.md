# Solution — Boot's properties migrator

Run from `c5-unit28/`, after `exercise/README.md`'s commands. One line: it builds the copy offline with the plain line, extracts
it, starts the exploded run on 19145 with the migrator and its metadata jar on the class path and the old key — waited on until
readiness answers 200, then stopped with POST /shutdown (`harness/shutdown.sh`, the token read from the copy's own file) — and
prints the report's `Key:` line.

```bash
M="$PWD/.m2-demo" H="$PWD/harness" && cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && B="$M/org/springframework/boot" && { java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$B/spring-boot-properties-migrator/4.1.1/spring-boot-properties-migrator-4.1.1.jar:$B/spring-boot-configuration-metadata/4.1.1/spring-boot-configuration-metadata-4.1.1.jar" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19145 --management.endpoints.enabled-by-default=true > run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19145/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done; "$H/shutdown.sh" 19145 secrets/tiffinbox/shutdown-token > /dev/null; wait; grep -m1 -o 'Key: .*' run.log
```

Measured (this unit's `exercise` capture, `receipts.sh`, 2026-10-08):

```
Key: management.endpoints.enabled-by-default
```

The key is what the line tells apart. The same line without the old key (measured once by hand, 2026-10-08, after the README's
commands) printed nothing and exited 1 — `grep` found no `Key:` line: the migrator reports only what it finds.
