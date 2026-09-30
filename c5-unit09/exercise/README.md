# Exercise — a rule of your own

TiffinBox as this unit left it (`../after/`) checks its settings before its port opens: the record,
`TiffinBoxProperties`, carries `@NotBlank`, `@NotNull`, `@Min(1)` and `@NotEmpty`, and `@Validated` on the record asks
Boot's binder to check them. Nothing, though, stops a kitchen from being handed more cooks than it has room for. **Add a
rule of your own — at most ten cooks — then start TiffinBox with eleven, and read the report's reason.**

Run `./receipts.sh` once first, from the unit's folder (the one that holds `receipts.sh`): it builds `after/` and compiles
the harness into `.harness/classes`. Then, from that same folder, make your own copy of `after/` (inside `.harness/`, which
the repository ignores) and name its class path:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && cp -R after .harness/mine
MINE="$PWD/.harness/classes:$PWD/.harness/mine/tiffinbox-web/target/tiffinbox-web-1.0.0.jar"
```

`$MINE` is the harness's classes and your copy's jar; the jar's manifest names the rest of the class path (`lib/`). Build
your copy (offline, from this unit's own repository) and start it with eleven cooks:

```bash
mvn -o -q -B -f .harness/mine/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package
java -cp "$MINE" com.tiffinbox.harness.Start --tiffinbox.port=18699 --tiffinbox.cooks=11; echo "exit $?"
```

`Start` runs TiffinBox's own `main`, prints the record, and closes the context, which stops TiffinBox's server — nothing
is left listening on 18699, this exercise's port. As shipped, eleven cooks start without a word (measured 2026-09-30,
JDK 25.0.4.1, Spring Boot 4.1.1):

```
the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=11, days=30, port=18699, mealTypes=[VEG, NON_VEG, VEGAN]]
exit 0
```

Now open `.harness/mine/tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java` and give `cooks` one more
rule, beside the two it has: at most ten. Its annotation lives in the same package as `@Min`
(`jakarta.validation.constraints`), so it needs an import of its own. Then run the two commands above again.

**Done** means the run ends with Boot's report for `tiffinbox.cooks` — `Value: "11"`, and a `Reason:` line that names your
limit — and `exit 1`, with nothing left listening on 18699.

The answer, measured with the commands above exactly as written, is in `solution/SOLUTION.md`.
