# c3-unit09 — configurations and the version catalog

Two modules and one text file. The two modules are the same `tiffinbox-core` and `tiffinbox-web`
sources the Maven build uses; the text file is `gradle/libs.versions.toml`, and it is the only place
in this project where a version number appears.

```
c3-unit09/
  settings.gradle.kts            includes the two modules
  build.gradle.kts               the root builds nothing
  gradle/libs.versions.toml      the version catalog - two versions, and that is all of them
  tiffinbox-core/                java-library · api(libs.h2)
  tiffinbox-web/                 java · project(":tiffinbox-core") + libs.jackson.databind
     …/web/HealthCheck.java      imports an H2 type that tiffinbox-web never declared
  conflict/                      the same two dependencies to Maven and to Gradle - two answers
  exercise/
  receipts.sh · gradlew · gradle/wrapper/
```

## Every hash on this page is regenerable

```bash
./receipts.sh            # re-runs every quoted capture and prints its md5
./receipts.sh flip       # just one of them
```

`receipts.sh` holds the exact pipeline behind each hash. It edits `tiffinbox-core/build.gradle.kts`
while it works and puts it back to `api(libs.h2)` before it exits, so your working tree is unchanged.

## Requirements

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRADLE_USER_HOME="$PWD/.gradle-home"
```

JDK **25 or newer**; Gradle arrives through the committed wrapper (9.7.1, pinned by sha256). The
`conflict/` project also uses Maven **3.9 or newer**.

## One word decides what the module next door can see

`tiffinbox-web/src/main/java/com/tiffinbox/web/HealthCheck.java` line 4:

```java
import org.h2.jdbcx.JdbcDataSource;
```

`tiffinbox-web/build.gradle.kts` declares exactly two dependencies, and H2 is not one of them:

```kotlin
dependencies {
    implementation(project(":tiffinbox-core"))
    implementation(libs.jackson.databind)
}
```

It compiles. Then flip **one word in the other module** — `api` to `implementation` — and it does not:

```
$ grep "libs.h2" tiffinbox-core/build.gradle.kts
api(libs.h2)
$ ./gradlew :tiffinbox-web:compileJava
> Task :tiffinbox-web:compileJava
BUILD SUCCESSFUL

$ grep "libs.h2" tiffinbox-core/build.gradle.kts
implementation(libs.h2)
$ ./gradlew :tiffinbox-web:compileJava
> Task :tiffinbox-web:compileJava FAILED
  tiffinbox-web/src/main/java/com/tiffinbox/web/HealthCheck.java:15: error: cannot find symbol
    symbol:   class JdbcDataSource
  tiffinbox-web/src/main/java/com/tiffinbox/web/HealthCheck.java:15: error: cannot find symbol
    symbol:   class JdbcDataSource
  tiffinbox-web/src/main/java/com/tiffinbox/web/HealthCheck.java:4: error: package org.h2.jdbcx does not exist
  3 errors
BUILD FAILED
```

*Receipt:* `./receipts.sh flip` → `md5 071e627036175f2961ceaf2d65143a1e`, three runs.
(The script masks the absolute path prefix before hashing; that is the only edit.)

**A configuration is a named bucket of dependencies with a rule about who else can see it.**
`api` means *my consumers compile against this too*. `implementation` means *this is mine*.
Maven has one compile scope and no way to say the second thing, which is why a Maven dependency tree
leaks everything downward and a Gradle one does not have to.

## `implementation` hides it from the compiler, and from the compiler alone

```bash
./gradlew -q :tiffinbox-web:dependencies --configuration compileClasspath
./gradlew -q :tiffinbox-web:dependencies --configuration runtimeClasspath
```

```
=== tiffinbox-core/build.gradle.kts :  api(libs.h2)
compileClasspath - Compile classpath for source set 'main'.
+--- project ':tiffinbox-core'
|    \--- com.h2database:h2:2.5.250
     ... the jackson subtree, 8 lines elided ...
runtimeClasspath - Runtime classpath of source set 'main'.
+--- project ':tiffinbox-core'
|    \--- com.h2database:h2:2.5.250
     ... the jackson subtree, 8 lines elided ...

=== tiffinbox-core/build.gradle.kts :  implementation(libs.h2)
compileClasspath - Compile classpath for source set 'main'.
+--- project ':tiffinbox-core'
     ... the jackson subtree, 8 lines elided ...
runtimeClasspath - Runtime classpath of source set 'main'.
+--- project ':tiffinbox-core'
|    \--- com.h2database:h2:2.5.250
     ... the jackson subtree, 8 lines elided ...
```

**Three of the four have H2 in them.** The one that does not is the compile classpath under
`implementation` — and that is the whole mechanism: the jar still ships, the JVM still finds the
driver, you just cannot write `import org.h2.…` in a module that never asked for H2.
*Receipt:* `./receipts.sh classpaths` → `md5 0939bbb0891871d0ea51ee56acc3a4ed`.

Proof the runtime side is real — `health` is a `JavaExec` task wired to
`sourceSets.main.runtimeClasspath`:

```bash
./gradlew -q health
```

```
health: ok
```

*Receipt:* `./receipts.sh health` → `md5 cf867c92c071ae083ec4751c3f4067b5`.

## Versions live in exactly one place

```
[versions]
h2      = "2.5.250"
jackson = "2.22.2"

[libraries]
h2               = { module = "com.h2database:h2",                           version.ref = "h2" }
jackson-databind = { module = "com.fasterxml.jackson.core:jackson-databind", version.ref = "jackson" }
```

Gradle reads `gradle/libs.versions.toml` by convention and generates a typed accessor for every entry.
Check that no build file carries a version:

```bash
grep -rn '2\.5\.250\|2\.22\.2' --include='*.kts' --include='*.toml' . | grep -v './conflict' | sed 's|^\./||'
grep -n 'libs\.' tiffinbox-*/build.gradle.kts
```

```
gradle/libs.versions.toml:9:h2      = "2.5.250"
gradle/libs.versions.toml:10:jackson = "2.22.2"
exercise/gradle/libs.versions.toml:9:h2      = "2.5.250"
exercise/gradle/libs.versions.toml:10:jackson = "2.22.2"

tiffinbox-core/build.gradle.kts:14:    api(libs.h2)
tiffinbox-web/build.gradle.kts:14:    implementation(libs.jackson.databind)
```

*Receipt:* `./receipts.sh catalog` → `md5 a477f0b79175ef44c306be955392ddff`. Four hits, not two: the
last two are `exercise/gradle/libs.versions.toml`, a byte-identical copy of the catalog that ships in
this same tree. The block used to hide it with a `grep -v './exercise'` that appeared on no slide,
under a chip claiming *two version strings in the whole project*. Two in the project, two in its
exercise copy, and **zero in any `*.kts` file** — which is the claim that was worth making.

**The catalog is half of what `<dependencyManagement>` did, not all of it.** A parent POM's
`dependencyManagement` does two jobs: it says *where the version is written*, and it *overrides the
version a transitive dependency would otherwise get*. `libs.versions.toml` does the first job only.
The second job in Gradle is `platform()` and `constraints { }`. Calling the catalog "Gradle's
`dependencyManagement`" and stopping there is how people get surprised — so here is the surprise,
measured.

## Same two lines, two different answers

`conflict/` declares `jackson-databind:2.22.2` (which brings `jackson-core:2.22.2` with it) and then
`jackson-core:2.13.5` directly. Identical declarations in `pom.xml` and in `build.gradle.kts`,
in the same order.

```bash
cd conflict
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" dependency:tree | grep 'jackson-core:jar'
../gradlew -q dependencies --configuration runtimeClasspath | grep -E '^.--- com.fasterxml.jackson.core:jackson-core'
```

```
[INFO] \- com.fasterxml.jackson.core:jackson-core:jar:2.13.5:compile
\--- com.fasterxml.jackson.core:jackson-core:2.13.5 -> 2.22.2 (*)
```

**Maven takes the nearest declaration: 2.13.5. Gradle takes the highest version: 2.22.2.** Neither is
a bug; they are two different documented rules, and the same project gets a different classpath from
each. Gradle even prints the substitution it made — `2.13.5 -> 2.22.2` — which is a thing Maven's tree
does not show unless you ask for `-Dverbose`.
*Receipt:* `./receipts.sh conflict` → `md5 632f0e964cfa899d5206dabc852026a8`, three runs.

## Offline

```bash
./gradlew --offline build                 # BUILD SUCCESSFUL, 7 actionable tasks: 7 up-to-date
cd conflict && mvn -o -B -Dmaven.repo.local="$PWD/.m2-demo" verify   # BUILD SUCCESS
```

Run each one online once first: offline mode can only reuse what has already been fetched, and the
`conflict/` project needs its build plugins as well as its dependencies.

## Clean up

```bash
./gradlew --stop
rm -rf */build build .gradle .gradle-home conflict/build conflict/.gradle conflict/target conflict/.m2-demo exercise/*/build exercise/.gradle
```

## Verified

**JDK 25.0.4.1**, **Gradle 9.7.1** via the committed wrapper, **Apache Maven 3.9.16**, macOS 27.0 on an
8-core 16 GB Apple-silicon Mac, **2026-09-15**. Every capture run three times, byte-identical each
time; every hash is produced by `receipts.sh` and by nothing else. Nothing was installed into `~/.m2`
or `~/.gradle`.
