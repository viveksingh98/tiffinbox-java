# c3-unit01 — The POM, Read Line by Line

The Course 2 capstone POM, unchanged, plus the two projects the unit compares and the exercise.
`export JAVA_HOME=/opt/homebrew/opt/openjdk@25` is line 1 of every command below: without it Maven
on this Mac resolves **JDK 26.0.2.1**, and this POM's `--enable-preview` then dies with
`invalid source release 25 with --enable-preview` (measured, 3/3, exit 1).
Verified 2026-09-14 · Maven 3.9.16 · JDK 25.0.4.1 · every command run 3 times, output byte-identical.

## The five commands

1. `mvn -B -q help:effective-pom -Doutput=effective-pom.xml && wc -l < effective-pom.xml && wc -l < pom.xml`
   → `     323` then `     100` · exit 0 · md5 of the two integers `e6c49765b03c55770194580fcf5a8b9f` (3/3)
2. `MH=$(mvn -version | sed -n 's/^Maven home: //p'); unzip -p "$MH/lib/maven-model-builder-3.9.16.jar" org/apache/maven/model/pom-4.0.0.xml | wc -l`
   → `     144` (the Super POM; line 51 is `<directory>${project.basedir}/target</directory>`, 3/3)
3. `unzip -p "$MH/lib/maven-core-3.9.16.jar" META-INF/plexus/default-bindings.xml | sed -n '67,94p'`
   → the `jar-lifecycle` phase table, surefire `3.5.4` and jar `3.5.0` included · md5 `902be49edcf2e7a18040e5644bbbe559` (3/3)
4. `mvn -B clean package 2>&1 | grep -E '^\[INFO\] --- '` here vs `cd unpinned && mvn -B dependency:tree`
   → `dependency:3.11.0:… @ c2-capstone` (pinned) vs `dependency:3.7.0:tree (default-cli) @ unpinned` (Super POM's default), 3/3
5. `cd exercise && mvn -B clean package && javap -v -cp target/classes com.tiffinbox.Dashboard | grep -E 'major|minor'`
   → `BUILD SUCCESS`, exit 0, and `minor version: 65535` / `major version: 69` — Java 25 with the preview bit, **not** the Java 17 the `<properties>` asked for

## Layout

| Path | What it is |
|---|---|
| `pom.xml` · `src/` | the delivered Course 2 capstone, byte-identical — the 100 lines the unit reads |
| `unpinned/pom.xml` | the same group and version with **no plugin pinned**, so `dependency:tree` prints the inherited `3.7.0` |
| `exercise/` | the capstone with `<maven.compiler.release>` set to **17** — `mvn -B clean package` still prints `BUILD SUCCESS` |
| `exercise/solution/pom.xml` | the fix: the **compiler plugin's own** `<release>` set to 17 |

## Exercise

**Start:** `cd exercise && mvn -B clean package` → `BUILD SUCCESS` even though `<properties>` asks for Java 17.
**Task:** find the line that overrules the property and make the build fail.
**End state:** `[ERROR] invalid source release 17 with --enable-preview`, exit **1**.
**Solution** (`exercise/solution/pom.xml`, run by the author, 3/3): `cp solution/pom.xml pom.xml && mvn -B clean package`
→ exit 1; `… | grep -E '^\[ERROR\]' | head -4` hashes to `6742c83f84c6c9b0044888d3cb706a11`.

> 📌 Code for this unit: tiffinbox-java/c3-unit01 · verified on JDK 25.0.4.1
