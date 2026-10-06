# Exercise — what the metadata knows, and what it does not

**Your turn:** count TiffinBox's entries in the generated reachability metadata, then find the class its JSON needs that is
missing.

The video opened the file Spring's ahead-of-time step writes for a native build, `reachability-metadata.json`, and read
TiffinBox's server out of it. Now read it yourself: how many of its reflection entries name one of TiffinBox's own classes
(everything under `com.tiffinbox`)? And TiffinBox turns one of its own records into JSON when you ask for `/customers` — is
that record in the file at all?

Run everything from `c5-unit19/`. The commands below build a copy of TiffinBox — `after/`, the anchor as this lesson leaves
it — under `.harness/mine` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), with the Maven profile `native` from
Boot's parent, on the plain JDK: no GraalVM needed for this one. The build uses this unit's own repository, `.m2-demo`, offline.
On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once first — no GraalVM needed for that either. Its first build fills
`.m2-demo` from Maven Central, GraalVM's metadata repository included; without `GRAALVM_HOME` it then stops before the native
build, after this exercise's own capture. Do not skip it: when that metadata repository is not in `.m2-demo`, GraalVM's plugin
downloads it from GitHub, even offline (`README.md`, *The repository*).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
mvn -o -B -q -f .harness/mine/after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -Pnative -DskipTests clean package
```

The file is under the web module's `target/spring-aot/main/resources/`, in `META-INF/native-image/`. It is pretty-printed:
every entry's class sits on its own line, as `"type": "…"`. Hint: `grep -c` counts the lines that match a pattern — and the
record you are looking for has a name that another of TiffinBox's classes starts with.

**Done** when you can print

```
reflection entries naming com.tiffinbox: 9 · com.tiffinbox.Customer: 0
```

— nine entries, and none for `Customer`, the record `/customers` turns into JSON. The same line is in this unit's `exercise`
capture (`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`. What the missing entry costs
a native binary is the next lesson's.
