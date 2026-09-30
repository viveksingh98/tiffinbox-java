# Exercise — the constraints without @Validated

TiffinBox as this unit left it (`../after/`) carries its rules on the record, `TiffinBoxProperties`: `@NotBlank`,
`@NotNull`, `@Min(1)`, `@NotEmpty` — and `@Validated` on the record itself. Remove **only** `@Validated`, keep every
constraint, and start TiffinBox with zero cooks. Read the orders-cooked line. Then put `@Validated` back and start it
again.

Run `./receipts.sh` once first, from the unit's folder (the one that holds `receipts.sh`): it builds `after/` and compiles
the harness into `.harness/classes`. Then, from that same folder, make your own copy of `after/` (inside `.harness/`, which
the repository ignores) and name its class path:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && cp -R after .harness/mine
MINE="$PWD/.harness/classes:$PWD/.harness/mine/tiffinbox-web/target/tiffinbox-web-1.0.0.jar"
```

Build your copy (offline, from this unit's own repository) and start it with zero cooks:

```bash
mvn -o -q -B -f .harness/mine/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package
java -cp "$MINE" com.tiffinbox.harness.Start --tiffinbox.port=18699 --tiffinbox.cooks=0; echo "exit $?"
```

`Start` runs TiffinBox's own `main`, prints the record, and closes the context, which stops TiffinBox's server — nothing
is left listening on 18699, this exercise's port. The jar's manifest names the rest of the class path (`lib/`). As
shipped, with `@Validated` in place, the run ends (measured 2026-09-30, JDK 25.0.4.1, Spring Boot 4.1.1):

```
Binding to target com.tiffinbox.TiffinBoxProperties failed:

    Property: tiffinbox.cooks
    Value: "0"
    Origin: "tiffinbox.cooks" from property source "commandLineArgs"
    Reason: must be greater than or equal to 1
…
exit 1
```

Now open `.harness/mine/tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java`, delete the one line
`@Validated`, and run the two commands above again.

**Done** means you have read TiffinBox's own `orders cooked:` line from the run without `@Validated`, with its exit code —
and, after you put the line back and ran the two commands once more, the `Property: tiffinbox.cooks` block again.

The answer, measured with the commands above exactly as written, is in `solution/SOLUTION.md`.
