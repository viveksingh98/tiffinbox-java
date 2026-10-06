# Exercise — take the binding hint out, and watch the record leave the file

**Your turn:** delete the binding hint, run the AOT step again, and search the generated metadata for Customer.

The video put three hints into TiffinBox, and one of them is for Jackson: `@RegisterReflectionForBinding(Customer.class)` on
`TiffinBoxServer` tells Spring's ahead-of-time step (AOT) that the record `/customers` returns is turned into JSON by
reflection. Spring then writes an entry for `Customer` into `reachability-metadata.json`, the file a native build reads. Take
the hint out, run the AOT step again, and see what the file says about `Customer` now. No GraalVM needed: the AOT step runs on
the plain JDK.

Run everything from `c5-unit20/`. The commands below copy TiffinBox — `after/`, the anchor as this lesson leaves it, hints and
all — to `.harness/mine` (git-ignored; `receipts.sh` wipes `.harness/` when it runs) and run the AOT step once, with Boot's
profile `native`, offline against this unit's own repository, `.m2-demo` (on a fresh clone, run `./receipts.sh` once first: its
first build fills `.m2-demo` from Maven Central).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
mvn -o -B -q -f .harness/mine/after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -Pnative -DskipTests clean package
```

The hint is one line of `.harness/mine/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java`. Delete it,
run the Maven line above again (it is the AOT step), and search the file it writes —
`.harness/mine/after/tiffinbox-web/target/spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json`
— for `com.tiffinbox.Customer`. It is pretty-printed: each entry names its class on a line of its own, `"type": "…"`. Count
before you delete, too.

**Done** when you can print

```
com.tiffinbox.Customer entries - with the hint: 1, methods mealsPerDay mealType name pricePerMeal · deleted, built again: 0
```

— one entry with the record's four accessors while the hint is there, none once it is gone. The same line is in this unit's
`exercise` capture (`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`. What the missing
entry costs a native binary is in the `breaks` capture, B: `/customers` answers `500 {"error":"InvalidDefinitionException"}`.
