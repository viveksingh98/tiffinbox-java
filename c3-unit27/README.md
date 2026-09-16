# c3-unit27 — GraalVM native image

Course 3 · Build & Test Like a Pro · Section 5 "Ship the Artifact".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16**, macOS 27.0, 8-core / 16 GB Apple silicon,
on 2026-09-15.

`src/main/java/com/tiffinbox/` holds the same five carried classes —
`fdb1643d622615f3c331d75deaebb9da`.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh
```

## Read this first

**A native image cannot be built on the machine this unit was written on, and this README
says so instead of pretending otherwise.** Two independent reasons, both *measured* by
`./receipts.sh graalvm`:

```
native-image on PATH ............... no
GRAALVM_HOME ....................... <unset>
GraalVM JDKs installed ............. 0

$ mvn -Pnative package
Failed to execute goal org.graalvm.buildtools:native-maven-plugin:1.1.13:compile-no-fork
(build-native) on project tiffinbox-core: native-image is not installed in your
JAVA_HOME.This probably means that the JDK at '/opt/homebrew/opt/openjdk@25' is not a
GraalVM distribution. ...
exit 1

$ cc <a two-line C file> -o <binary>
  You have not agreed to the Xcode license agreements. ...
  exit 69
$ /usr/bin/ld -v
  You have not agreed to the Xcode license agreements. ...
  exit 69
```

The second one matters even if you install GraalVM: **`native-image` shells out to the
system linker for its last step**, and on this machine `cc`, `ld` and `xcrun` all answer
exit **69**. Accepting that licence needs `sudo` and changes a machine-wide setting, so this
unit does not do it — it records the state and designs around it.

**So there is no native binary in this unit, no binary file size, and no start-up time.**
What there is instead runs here, on a plain JDK 25, and is what the unit is actually about:

- the **AOT path**, measured as a count — JEP 483 and JEP 515, in the JDK you already have;
- the **closed-world problem**, measured with `jdeps`;
- the **native profile and its reachability metadata**, shipped as real, pinned files that a
  viewer with a GraalVM JDK runs unchanged.

Pinned and shipped, derived from `central/` with no network:

```
native-maven-plugin pinned in pom.xml ... 1.1.13
newest in its version list .............. 1.1.13, published 2026-09-15
GraalVM CE release ...................... graal-25.3.4.1, published 2026-08-25
the macOS arm64 asset ................... graalvm-community-jdk-25i3-25.0.4.1_macos-aarch64_bin.tar.gz
its size, in bytes ...................... 339188208
```

## The one line no compiler can follow

```properties
plain=com.tiffinbox.aot.PlainFormatter
ledger=com.tiffinbox.aot.LedgerFormatter
```

```java
Class<?> type = Class.forName(className);
```

`./receipts.sh closedworld` asks the JDK's own reachability tool what it can see:

```
Java source files that name either class (other than the classes themselves): 0
edges out of Startup ............................ 20
of those, into PlainFormatter ................... 0
of those, into LedgerFormatter .................. 0
```

**Zero.** Nothing in the code points at either implementation. That is not a flaw in the
design — it is the shape of every service loader, every dependency-injection container,
every plugin system and every annotation-driven router in Java, including the one this
project already has.

## The AOT path, counted rather than timed

`./receipts.sh aot` runs four states. It starts by finding out something a packaging unit
should have warned you about:

```
$ java -XX:AOTMode=record ... -cp target/classes com.tiffinbox.aot.Startup plain
  [<t>][error][aot] Error: non-empty directory 'target/classes'
```

**The recorder refuses an exploded directory. An AOT cache is a thing you make from a jar.**

Then:

```
step 2 - the JIT path, cache switched off:
  classes loaded ................. 1890
  of those, out of a cache ....... 0

step 3 - the AOT path, same program, same arguments:
  classes loaded ................. 1991
  of those, out of the cache ..... 1985
  loaded from somewhere else ..... 6
```

**A count, not a duration.** This course's measurement rule says a wall-clock number is
never the lesson, and here it does not have to be: "1985 of 1991 classes came out of a file
instead of out of a jar" is the whole mechanism, and it is the same number on your machine.

Then the beat the unit exists for:

```
step 4 - the SAME cache, running the path the training run never touched:
  PlainFormatter  loaded from ... shared objects file
  LedgerFormatter loaded from ... file:<project>/target/tiffinbox-core-1.0.0.jar
  exit 0, and the program printed its answer
    formatter key: ledger
    month total: 24300
    ok
```

The training run only ever exercised `plain`. `LedgerFormatter` is **not in the cache** — so
the JVM loaded it from the jar and the program worked.

**That is the difference between the two kinds of ahead-of-time.** An AOT cache is an
optimisation over a program that is still complete. A native image is not: there is no jar
beside it, and a class that is not in the binary is a `ClassNotFoundException` at run time.

*(`PlainFormatter` comes out of the cache even on the ledger run — an AOT cache loads what
it archived whether or not this run asks for it.)*

## A closed world you can build here

`./receipts.sh jlink` builds two runtimes from the same JDK:

```
modules in this JDK ................. 69
modules in the full image ........... 5   java.base java.logging java.sql java.transaction.xa java.xml
modules in the trimmed image ........ 1   java.base
```

Same jar, same program, two worlds:

```
full:    formatter key: ledger / column type: 4 / customers: 4 / month total: 24300 / ok   exit 0
trimmed: Exception in thread "main" java.lang.NoClassDefFoundError: java/sql/DriverManager  exit 1
```

Nothing was recompiled between those two runs. **jlink is the gentle version of a closed
world — it tells you at start-up. A native image decides at build time and cannot tell you
anything at all.**

## The repair

`src/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-core/` ships the two files
a closed-world build reads, at the path it looks in:

- **`reflect-config.json`** — three entries: both formatters and `org.h2.Driver`.
- **`resource-config.json`** — and this is the half people forget. `formatters.properties`
  is a **resource**, and a closed-world build does not carry resources it cannot see being
  read either. A binary with the classes and without the properties file fails one line
  *earlier*, on `getResourceAsStream`, with a message about a null stream rather than a
  missing class — so it looks like a different bug entirely.

Neither file changes a normal build; `mvn -o test` runs with both on the classpath and the
JVM ignores them.

## Exercise — `exercise/`

See `exercise/README.md`. **Start state:** the metadata covers **1 of 2** formatter classes,
so a binary built from it runs `plain` and dies on `ledger`. **End state:** 2 of 2, with
**0 lines of Java changed**.

The exercise's real point is its last paragraph: the check that catches this needs **no
GraalVM at all** — every value in `formatters.properties` compared against the names in the
json, eight lines of Python, running in CI, costing no build minutes.

## Receipts

| Block | What it proves |
|---|---|
| `closedworld` | `jdeps` reports **0** edges from the entry point to either formatter |
| `aot` | the JDK 25 AOT cache, as counts; and the class the training run never saw being loaded from the jar |
| `jlink` | two runtimes, 5 modules vs 1, exit 0 vs exit 1, nothing recompiled |
| `graalvm` | why there is no binary here — measured, verbatim, twice over |
| `nativeconfig` | the metadata, parsed rather than eyeballed, and both formatters covered |
| `solution` | the exercise, start state asserted before it is answered |
| `offline` | `mvn -o test` after a warm `package` |

**Not hashed, and each says so:** every byte size — the AOT configuration, the AOT cache,
the jar, and the two jlink images (C2 finding #3: a size goes on a slide only after it has
repeated, and image sizes move with the compression level and the JDK build).
