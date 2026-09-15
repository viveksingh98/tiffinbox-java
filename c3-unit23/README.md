# c3-unit23 — jars, fat jars, layered jars

Course 3 · Build & Test Like a Pro · Section 5 "Ship the Artifact".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16**, macOS 27.0, 8-core / 16 GB Apple silicon,
on 2026-09-15.

`src/main/java/com/tiffinbox/` holds the same five carried classes —
`fdb1643d622615f3c331d75deaebb9da`. **Every Maven command carries
`-Dmaven.repo.local="$PWD/.m2-demo"` with the quotes**; this tree's path contains a space,
and unquoted, Maven reads the tail as a goal and answers `Unknown lifecycle phase`.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh
```

Bare `java` on this Mac is **23.0.1** and Maven with no `JAVA_HOME` resolves **26.0.2.1**.
The reason it matters *here* is narrower than in the earlier sections: a jar records the JDK
that built it (`Build-Jdk-Spec`), `--multi-release` is a JDK-version question, and
`jar --describe-module` answers differently on different releases. Every capture below is
JDK 25 or it is a capture of a different program.

## One program, three files

Same sources, same four dependencies, three packagings.

| | command | what it is | what has to be beside it |
|---|---|---|---|
| **thin** | `mvn package` | your classes only — **18 entries** | `target/lib/`, four jars, named one by one in a `Class-Path` manifest header |
| **fat** (uber) | `mvn -Pfat package` | everything, flattened — **2354 entries** | nothing |
| **layered** | *not a file format* | the same two piles, kept apart on purpose | see below |

**"Layered" is not a third archive format, and that is the most useful thing this unit has
to say about it.** A layered artifact is the thin jar plus its dependency directory, built
so that the pile that changes every commit and the pile that changes twice a year are
*separate files*. `./receipts.sh layers` measures it rather than describing it: two builds
with nothing changed, then a third with one line of one `.java` file changed.

```
build 3, after changing ONE line of one .java file:
  application layer  7a7c82d6a2c183e6c3e18507f64d9b5f   moved: yes
  dependency  layer  7977d3c96bd603d1448705861836dbcb   moved: no
layers whose bytes changed: 1 of 2
bytes of application layer per 1000 bytes of the two layers together: 3
```

Three bytes in a thousand moved. That ratio is the entire argument for layering, and it is
why the next course's container image rebuilds in seconds instead of minutes. The fat jar
has the opposite property by construction: change one line and all five megabytes are a new
file.

## The `Class-Path` header, and what checks it

Nothing checks it. Not `mvn package`, not `java -jar`, not the JVM at start-up.

```
Class-Path: lib/h2-2.5.250.jar lib/jackson-databind-2.22.2.jar lib/jacks
 on-annotations-2.22.jar lib/jackson-core-2.22.2.jar
Main-Class: com.tiffinbox.ship.TiffinBoxApp
```

`./receipts.sh classpath` runs the jar with `target/lib` in place (exit **0**), renames the
directory, runs the **same jar** again, and gets

```
Exception in thread "main" java.lang.NoClassDefFoundError: com/fasterxml/jackson/databind/ObjectMapper
exit code: 1
jars named in the Class-Path header: 4
of those, present when the run failed: 0
lines of build output that warned about it: 0
```

**Zero lines of warning.** A manifest header is a promise about the filesystem, made at build
time, checked never. That block refuses to pass unless the run really fails — a green run
there would mean the trap did not reproduce, and printing it anyway is how a slide gets a
number the terminal contradicts.

## What a fat jar throws away — counted, not asserted

`./receipts.sh overlap` builds the fat jar twice: once as shipped, once with the
`ServicesResourceTransformer` deleted and **nothing else changed**.

```
overlap groups shade reported: 3
the widest of those lines names 5 jars; the slide shows the first 3 and elides 2.
META-INF/LICENSE: carried by 3 of the input jars, present in the fat jar 1 time(s)
META-INF/NOTICE : carried by 3 of the input jars, present in the fat jar 1 time(s)
licence files that did not survive being merged: 2
```

The three warning lines above those counts are shade's own, character for character, but the
block **sorts** them before it hashes the capture: `maven-shade-plugin` walks its overlap
groups in an order that is stable inside one directory and different between directories, so
an unsorted hash would be a fact about where you cloned rather than about the build. Measured
on three clean copies, one of them on a path containing a space: **one hash, 9 of 9.**

Two licence files gone. That is a legal problem wearing a build-tool costume, and no
tutorial mentions it.

Then the honest half, which matters more than the folklore:

```
service files: 3, and no two of them have the same name
META-INF/services/java.sql.Driver, with ServicesResourceTransformer: 14 bytes
the same file with the transformer deleted and nothing else changed: 13 bytes
difference: 1 byte(s) - the merge appends a newline per provider
```

**On this classpath the famous services transformer changes one byte and nothing breaks.**
It is not this classpath it is there for. It matters the day two of your jars declare the
same service — two SLF4J bindings, two JDBC drivers, two `ServiceLoader` extensions — and
then one file can hold only one of them and the loser disappears without a word. Leave the
transformer in; understand that on most days it is doing nothing.

And one more thing the fat jar kept and should not have:

```
Class-Path entries in a jar that needs none: 4
```

The shaded jar still carries the thin jar's `Class-Path` header, pointing at a `lib/` it does
not need. Harmless here. Not harmless next to a stale `lib/` from an older build.

## `jdeps --generate-module-info` — the promise, paid, and it takes four goes

```
attempt 1   jdeps --generate-module-info <dir> tiffinbox-core-1.0.0.jar
            Error: Missing dependencies: classes not found ...          exit 1
attempt 2   ... --module-path target/lib
            Error: h2-2.5.250.jar is a multi-release jar file but
                   --multi-release option is not set                    exit 2
attempt 3   ... --module-path target/lib --multi-release 25             exit 0
```

```
module tiffinbox.core {
    requires com.fasterxml.jackson.databind;
    requires transitive java.sql;
    exports com.tiffinbox;
    exports com.tiffinbox.ship;
}
```

`requires transitive java.sql` is the line to remember — a later unit takes that module
away and watches what happens.

## `<release>` is not "newest"

`./receipts.sh release` derives this from the two files in `central/`, **with no network**:

```
versions in the list ............ 27
<release> field says ............ 4.0.0-beta-1, published 2024-06-26
newest GA ....................... 3.5.1, published 2026-07-19
the GA is NEWER than the field by 753 days
```

The `<release>` field is the **last entry of the version list in Maven's own version order**
— 4 sorts above 3 — and nothing more. It is not newest-GA and it is not newest-published.
This pom pins **3.5.1**, found by reading the list.

## Exercise — `exercise/`

`exercise/` is this project with one property missing. Build it twice:

```
cd exercise
mvn -B -Dmaven.repo.local="../.m2-demo" clean package -DskipTests
md5 -q target/tiffinbox-core-1.0.0.jar
mvn -B -Dmaven.repo.local="../.m2-demo" clean package -DskipTests
md5 -q target/tiffinbox-core-1.0.0.jar
```

The two hashes differ. Nothing changed between them — not a source file, not a dependency,
not a flag.

**End state:** the same two commands print **the same hash**, with **0 lines of Java
changed**. The answer is in `exercise/solution/pom-fragment.xml`, and
`./receipts.sh solution` runs both states and refuses to continue if the untouched exercise
is already reproducible.

## Receipts

| Block | What it proves |
|---|---|
| `three` | the three artifacts, entry counts read out of the archives |
| `classpath` | the header nothing checks — exit 0, then exit 1, same jar |
| `overlap` | what one file can hold only one of; the transformer's real one-byte effect |
| `jdeps` | four goes at `--generate-module-info`, exit codes 1, 2, 0 |
| `layers` | which bytes move when one line moves |
| `release` | the `<release>` trap on this unit's own plugin, no network |
| `solution` | the exercise, start state asserted before it is answered |
| `offline` | `mvn -o test` after a warm **`package`** — `copy-dependencies` is bound to `prepare-package`, so a repository warmed by `mvn test` alone cannot serve this |

Every count above is derived by the run that printed it and written into the file that is
hashed, so a wrong number cannot survive a re-run. Every block that could report a confident
zero over a run that did not happen stops with `RECEIPT FAILED` instead.

**Not hashed, and each says so in its own output:** every byte size (a jar's size moved
between two identical builds in Course 2, finding #3) · the exercise's start-state jar
hashes, which are wall clocks in hex and differ on purpose.
