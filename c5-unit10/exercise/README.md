# Exercise — the audit's own cooks

TiffinBox as this unit left it (`../after/`) has two profiles. `rush` is the second document in `application.yaml`
(`tiffinbox.cooks: 6`). `audit` is a file of its own, `application-audit.yaml`, holding one key — TiffinBox's logging at
debug — and no cooks. The group `lunch` switches both on. Give the audit profile its own cooks value, activate `lunch`,
**predict the winner before you run it**, then check the source.

Run `./receipts.sh` once first, from the unit's folder (the one that holds `receipts.sh`): it builds `after/` and compiles
the harness into `.harness/classes`. Then, from that same folder, make your own copy of `after/` (inside `.harness/`, which
the repository ignores) and name its class path:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && cp -R after .harness/mine
MINE="$PWD/.harness/classes:$PWD/.harness/mine/tiffinbox-web/target/tiffinbox-web-1.0.0.jar"
```

Build your copy (offline, from this unit's own repository) and start it with the group on:

```bash
mvn -o -q -B -f .harness/mine/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package
java -cp "$MINE" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18709 --spring.profiles.active=lunch; echo "exit $?"
```

`Stack` runs TiffinBox's own `main`, prints the stack for `tiffinbox.cooks` — every property source, in the order Boot asks
them — and closes the context, which stops TiffinBox's server: nothing is left listening on 18709, this exercise's port.
Run it from the unit's folder, which holds no `tiffinbox-local.yaml`. As shipped, before your edit, the report's `KEY`
line reads (measured 2026-09-30, JDK 25.0.4.1, Spring Boot 4.1.1):

```
KEY tiffinbox.cooks -> WINNER 6 · from source 7 of 9, Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1)
```

— and the row just above it in the stack, source 6, is the audit's file, holding `-` for cooks.

Now open `.harness/mine/tiffinbox-web/src/main/resources/application-audit.yaml` and give audit a cooks value of your own
under a `tiffinbox:` key, at the file's top level (any whole number of 1 or more: the record's `@Min(1)` refuses a zero).
Write down which source you expect to answer, and why. Then run the two commands above again.

**Done** means the `KEY` line names your value, and `application-audit.yaml` as the source it came from.

The answer, measured with the commands above exactly as written, is in `solution/SOLUTION.md`.
