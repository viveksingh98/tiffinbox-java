# c3-unit07 — Gradle in one build file

One directory. One set of sources. **Two build tools.**

```
c3-unit07/
  src/main/java/com/tiffinbox/   Customer · CustomerRepository · Database · Dashboard · OrderQueue
  pom.xml                        the Maven build   →  target/tiffinbox-core-1.0.0.jar
  settings.gradle.kts            names the build
  build.gradle.kts               the Gradle build  →  build/libs/tiffinbox-core-1.0.0.jar
  gradlew · gradlew.bat · gradle/wrapper/     the committed Gradle wrapper, pinned to 9.7.1
  exercise/
```

The five Java files are the `tiffinbox-core` sources of [`../c3-tiffinbox/`](../c3-tiffinbox/), byte for
byte. Check it rather than believe it:

```bash
cd src/main/java/com/tiffinbox           && md5 -q *.java | sort | md5 -q
cd ../../../../../../c3-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox && md5 -q *.java | sort | md5 -q
```

```
fdb1643d622615f3c331d75deaebb9da
fdb1643d622615f3c331d75deaebb9da
```

## Every hash on this page is regenerable

```bash
./receipts.sh            # re-runs every quoted capture and prints its md5
./receipts.sh gradle-jar # just one of them
```

`receipts.sh` holds the **exact** pipeline behind each hash, including every `grep` and `sed`. A hash
taken over a capture that was trimmed afterwards is not a receipt, so nothing on this page is trimmed
after hashing.

## Requirements

JDK **25 or newer**, Maven **3.9 or newer**, and **nothing else** — the Gradle wrapper fetches Gradle
itself. Every command below starts with the same two exports:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRADLE_USER_HOME="$PWD/.gradle-home"
```

**The `JAVA_HOME` line is not ceremony here, it is the build.** With it unset, `./gradlew` runs on
whatever `java` is first on your path — on this Mac that is 23.0.1 — and the build dies before it
reaches your code:

```bash
( unset JAVA_HOME; PATH=/usr/bin:/bin java -version ); java -version
```

```
openjdk version "23.0.1" 2024-10-15
openjdk version "25.0.4.1" 2026-08-18
```

```bash
( unset JAVA_HOME; PATH=/usr/bin:/bin ./gradlew --console=plain clean jar ) 2>&1 \
  | grep -E '^> Task|^> Java|^    error:|^BUILD'
```

```
> Task :clean
> Task :compileJava FAILED
> Java compilation initialization error
    error: release version 25 not supported
BUILD FAILED
```

*Receipt:* `./receipts.sh no-jdk` → `md5 b41e09276986807bcd4f4d0218eb25f1`, exit 1, three runs. The
grep above is the whole of the filter: the unfiltered run is 21 lines, and these five are not adjacent
in it — the `FAILURE:` header, the problems-report path and the four `Try` lines sit between them.

**The `GRADLE_USER_HOME` line keeps this project out of your `~/.gradle`.** Gradle's downloaded
distribution, its caches and its daemon registry all go into `.gradle-home/` beside the build
instead. Delete that directory and nothing of this project is left on your machine. It is also why
the commands below never touch a shared cache you might care about.

## Which Gradle is running

There may well be a `gradle` on your `PATH` already. This project does not use it. Two commands say
so, and both are worth running before you trust any Gradle output ever again:

```bash
./gradlew --version | grep -E '^Gradle|^Launcher JVM|^Daemon JVM|^OS'
```

```
Gradle 9.7.1
Launcher JVM:  25.0.4.1 (Homebrew 25.0.4.1)
Daemon JVM:    /opt/homebrew/Cellar/openjdk@25/25.0.4.1/libexec/openjdk.jdk/Contents/Home (no Daemon JVM specified, using current Java home)
OS:            Mac OS X 27.0 aarch64
```

```bash
grep -E 'distributionUrl|distributionSha256Sum' gradle/wrapper/gradle-wrapper.properties
```

```
distributionSha256Sum=acd53f1edaf02f1a8ff99879f8a34b302661a057d9b063ae9e35b552f804d20a
distributionUrl=https\://services.gradle.org/distributions/gradle-9.7.1-bin.zip
```

The second line is the version. The first line is the guarantee that it is the real one: the wrapper
hashes the zip it downloads and refuses to run if the hash is wrong. Both values are published —
`curl -s https://services.gradle.org/versions/current` prints them as `checksum` and `wrapperChecksum`.
The jar in `gradle/wrapper/` is 47 505 bytes and its own published checksum matches:

```bash
shasum -a 256 gradle/wrapper/gradle-wrapper.jar
```

```
7a9ce74cff467ca1bf60a4fcd9f05185acceda4d0f382434d393e17864262c5d  gradle/wrapper/gradle-wrapper.jar
```

## Build it both ways

```bash
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" clean package | grep -E '^\[INFO\] --- '
```

```
[INFO] --- clean:3.2.0:clean (default-clean) @ tiffinbox-core ---
[INFO] --- resources:3.4.0:resources (default-resources) @ tiffinbox-core ---
[INFO] --- compiler:3.15.0:compile (default-compile) @ tiffinbox-core ---
[INFO] --- resources:3.4.0:testResources (default-testResources) @ tiffinbox-core ---
[INFO] --- compiler:3.15.0:testCompile (default-testCompile) @ tiffinbox-core ---
[INFO] --- surefire:3.5.4:test (default-test) @ tiffinbox-core ---
[INFO] --- jar:3.5.0:jar (default-jar) @ tiffinbox-core ---
```

**Seven goals.** Two of them are about tests, in a project that has none.
*Receipt:* `./receipts.sh maven-goals` → `md5 7cd2e14a1639e3cea1ddac8102e94fbd`, exit 0, three runs.

**Quote the `-Dmaven.repo.local=` value.** This tree's path contains a space. In `bash`, an unquoted
`$PWD` splits at it and Maven reads the tail as a goal name; `zsh` does not split. Quote it and both
shells behave.

```bash
rm -rf build && ./gradlew --console=plain clean jar | grep -E '^> Task|^BUILD|actionable' \
  | sed -E 's/ in ([0-9]+h )?([0-9]+m )?[0-9]+(\.[0-9]+)?(ms|s)$//'
```

```
> Task :clean UP-TO-DATE
> Task :compileJava
> Task :processResources NO-SOURCE
> Task :classes
> Task :jar
BUILD SUCCESSFUL
3 actionable tasks: 2 executed, 1 up-to-date
```

**This is a first run on a fresh clone**, which is why the block starts with `rm -rf build`: there is no
`build/` directory yet, so `clean` has nothing to delete and says `UP-TO-DATE`. Run it a second time and
those two lines read `> Task :clean` and `3 actionable tasks: 3 executed` — `md5 96be409590cea1a7dcfb4a8820899d98`.
Both are real; the slide shows the one you see first (contract §1d).

**Five tasks, and not one of them is a test.** *Receipt:* `./receipts.sh gradle-jar` →
`md5 a833ea2212678d80bc0c16f9aa694d8e`, exit 0, three runs. The `sed` strips Gradle's `in 1s` — that number moves every run and is the one thing on
that block you must never quote as a fact.

`NO-SOURCE` is Gradle saying *this task has nothing to work on*: there is no `src/main/resources`.
It is a different statement from `UP-TO-DATE`, and Gradle never uses one where it means the other.

## The same jar

The two jars are **not** byte-identical, and pretending otherwise would be a lie. Here is exactly how
they differ and exactly how they do not.

```bash
diff <(unzip -Z1 target/tiffinbox-core-1.0.0.jar | sort) \
     <(unzip -Z1 build/libs/tiffinbox-core-1.0.0.jar | sort)
```

```
3,7d2
< META-INF/maven/
< META-INF/maven/com.tiffinbox/
< META-INF/maven/com.tiffinbox/tiffinbox-core/
< META-INF/maven/com.tiffinbox/tiffinbox-core/pom.properties
< META-INF/maven/com.tiffinbox/tiffinbox-core/pom.xml
```

Five entries, all metadata: Maven puts a copy of your POM inside the jar. Its manifest carries three
extra lines too (`Created-By`, `Java-Version`, `Build-Jdk-Spec`). **Every class file is identical.**

```bash
for j in target/tiffinbox-core-1.0.0.jar build/libs/tiffinbox-core-1.0.0.jar; do
  for c in $(unzip -Z1 "$j" | grep '\.class$' | sort); do unzip -p "$j" "$c" | md5 -q; done | md5
done
```

```
8bd6fdb961f65dddc82a242e5472059c
8bd6fdb961f65dddc82a242e5472059c
```

**One hash, two jars, seven class files each.** The same hash comes back from
[`../c3-unit09/`](../c3-unit09/) and [`../c3-unit10/`](../c3-unit10/), where the same sources are built
as part of a two-module project — five jars in this repository, one class-content hash.

## Tasks are a graph, phases are a sequence

Maven's `package` is a position in a fixed list of 23 phases; naming it runs every phase before it.

```bash
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" help:describe -Dcmd=package | grep -c '^\* '
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" help:describe -Dcmd=package | grep -c 'Not defined'
```

```
23
15
```

23 phases; 15 of them have no default goal for `jar` packaging; 8 do.

Gradle has no list. It has tasks with dependencies, and asking for one pulls in whatever it needs and
nothing else. `-m` is "dry run": print the plan, run none of it.

```bash
./gradlew --console=plain -m jar   | grep '^:'
./gradlew --console=plain -m build | grep '^:'
```

```
:compileJava SKIPPED
:processResources SKIPPED
:classes SKIPPED
:jar SKIPPED
```

```
:compileJava SKIPPED
:processResources SKIPPED
:classes SKIPPED
:jar SKIPPED
:assemble SKIPPED
:compileTestJava SKIPPED
:processTestResources SKIPPED
:testClasses SKIPPED
:test SKIPPED
:check SKIPPED
:build SKIPPED
```

**4 tasks against 11.** `jar` does not run `test`, because `test` is not on the path to `jar`.
`mvn package` *does* run `surefire:test`, because `test` is phase 15 and `package` is phase 16.
That is the whole difference between the two models, printed by the two tools.
*Receipts:* `./receipts.sh dryrun-jar` → `md5 ba1e5693bc22a273948fd93ca10c2409` and
`./receipts.sh dryrun-build` → `md5 4efce7107dcf47f89b2cedf663a0be3a`, exit 0, three runs each.

## What is on offer

```bash
./gradlew -q tasks
```

26 tasks in 5 groups — Build, Build Setup, Documentation, Help, Verification — every one with a
one-line description — out of a `build.gradle.kts` of 21 lines, 15 of which are not comment or
blank. Count them yourself:

```bash
./gradlew -q tasks | grep -cE '^[a-zA-Z]+ - '
```

```
26
```

## Get the name wrong

```bash
./gradlew jarr
```

```
* What went wrong:
No matches
  Task 'jarr' not found in root project 'tiffinbox-core'. Some candidates are: 'jar'.

* Try:
> Run gradlew tasks to get a list of available tasks.
```

Exit code **1**. Gradle knows what you meant and says so; the message is generated from the same task
list `tasks` printed. *Receipt:* `./receipts.sh bad-task` → `md5 28ab51bf2feaeceeb0488f3c2764fdf3`.

## Offline

Both builds are reproducible with the network off, after one warm run:

```bash
mvn -o -B -Dmaven.repo.local="$PWD/.m2-demo" verify     # BUILD SUCCESS, exit 0
./gradlew --offline build                               # BUILD SUCCESSFUL
```

## Clean up

```bash
./gradlew --stop           # the daemon is a long-lived JVM; stop it when you are done
rm -rf build target .gradle .gradle-home .m2-demo
```

`./gradlew --stop` matters more than it looks: the Gradle daemon outlives your terminal. `--status`
lists the ones running.

## Verified

Built on **JDK 25.0.4.1** (`/opt/homebrew/opt/openjdk@25`), **Gradle 9.7.1** via the committed wrapper,
**Apache Maven 3.9.16**, macOS 27.0 on an 8-core 16 GB Apple-silicon Mac, **2026-09-15**. Every command
above was run three times; every hash quoted is over the exact pipeline printed above it, with no
trimming after the hash was taken. Nothing was installed into `~/.m2` or `~/.gradle`.
