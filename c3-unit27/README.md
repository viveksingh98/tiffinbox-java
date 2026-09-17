# c3-unit27 — GraalVM native image

Course 3 · Build & Test Like a Pro · Section 5 "Ship the Artifact".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16**, macOS 27.0, 8-core / 16 GB Apple silicon,
on 2026-09-15. **The `native` block is new on 2026-09-17** and was measured against
**Oracle GraalVM 25.0.4+7.1**, `native-image 25.0.4`.

`src/main/java/com/tiffinbox/` holds the same five carried classes —
`fdb1643d622615f3c331d75deaebb9da`.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh
```

**`./receipts.sh` runs seven blocks and takes seconds. The eighth builds two real native
images, takes minutes, and is therefore not part of that run — you ask for it by name:**

```
export GRAALVM_HOME=/path/to/a/graalvm-jdk
./receipts.sh native
```

`GRAALVM_HOME` first, then `JAVA_HOME` when that one contains a `bin/native-image`. With
neither, the block **skips and names the variable to set**: it never fails, and it never prints
a hash for a build that did not happen. No path into anybody's home directory is written down
in it.

## Read this first

**There is a native binary in this unit, and the second one is the point.** The project as it
ships builds an image that answers both of its keys:

```
$ export GRAALVM_HOME=<a GraalVM JDK> ; export JAVA_HOME="$GRAALVM_HOME"
$ mvn -B -Pnative -Dmaven.repo.local="$PWD/.m2-demo" clean package
native-image stages it printed ....... 8 of the 8 it announces
BUILD SUCCESS lines in the log ....... 1
mvn exit code ........................ 0
types found reachable ................ 8612
types registered for reflection ...... 2741
$ ./target/tiffinbox plain
  formatter key: plain
  Meera x1
  Priya x1
  Ravi x2
  Sunil x3
  ok
  exit 0
$ ./target/tiffinbox ledger
  formatter key: ledger
  column type: 4
  customers: 4
  month total: 24300
  ok
  exit 0
```

**8 stages, and you wait through every one of them.** That is the build's cost stated as a
count, which is the only way this course states it: there is no wall-clock number for the build
here, on any slide, or in the Director's Note (contract §2a — *a duration is never a fact*).
What the page carries instead is what the tool states about itself and what it counted.

Pinned and shipped, derived from `pom.xml` and `central/` with no network:

```
native-maven-plugin pinned in pom.xml ... 1.1.13
newest in its version list .............. 1.1.13, published 2026-09-15
the goal it binds ....................... compile-no-fork, at the package phase
the image it names ...................... tiffinbox
build arguments ......................... 2   --no-fallback -H:+ReportExceptionStackTraces
GraalVM CE release ...................... graal-25.3.4.1, published 2026-08-25
the macOS arm64 asset ................... graalvm-community-jdk-25i3-25.0.4.1_macos-aarch64_bin.tar.gz
its size, in bytes ...................... 339188208
```

Every line in that panel is a property of this **repository** rather than of the machine
reading it, so `./receipts.sh graalvm` hashes the same for a viewer who has GraalVM and one who
does not. That is a repair, and it is worth naming: an earlier version of that block hashed
*this machine's* Xcode-licence state — `exit 69` from `cc`, because the licence had never been
accepted — the licence was accepted on 2026-09-16, the state changed underneath the block, and
the hash moved. **A receipt exists to stop exactly that**, so machine state now lives in
`native`, which says when it cannot run, and a pin lives here, where it cannot move unless a
file moves.

## The green build that shipped a broken program

Delete `src/main/resources/META-INF/native-image/` — the two reachability descriptors this unit
has always shipped and never had a build to consume — change **nothing else**, and build again:

```
files removed ........................ 2   reflect-config.json resource-config.json
reachability files inside its jar .... 0   <- the guard: `package` without `clean`
                                           leaves a stale copy in target/classes,
                                           packages it, and the deletion becomes
                                           invisible. Both builds here are clean.
native-image stages it printed ....... 8 of the 8 it announces
BUILD SUCCESS lines in the log ....... 1   <- THE BUILD IS GREEN
mvn exit code ........................ 0
types found reachable ................ 8609   (3 fewer than step 1)
types registered for reflection ...... 2737   (4 fewer than step 1)
$ ./target/tiffinbox plain
  formatter key: plain
  Exception in thread "main" java.lang.ClassNotFoundException: com.tiffinbox.aot.PlainFormatter
    at com.oracle.svm.core.hub.ClassForNameSupport.forName(ClassForNameSupport.java:<line>)
    at com.tiffinbox.aot.Startup.formatterNamed(Startup.java:43)
  ... 6 of the 8 frames elided
  exit 1
$ ./target/tiffinbox ledger
  formatter key: ledger
  Exception in thread "main" java.lang.ClassNotFoundException: com.tiffinbox.aot.LedgerFormatter
    at com.oracle.svm.core.hub.ClassForNameSupport.forName(ClassForNameSupport.java:<line>)
    at com.tiffinbox.aot.Startup.formatterNamed(Startup.java:43)
  ... 6 of the 8 frames elided
  exit 1
```

**`BUILD SUCCESS`, and a broken program.** Nothing failed at build time. There was no warning,
no missing dependency and no non-zero exit anywhere in the build; the artifact it handed over
is simply not the program you wrote.

The frame under the exception is the mechanism, and it is worth reading twice:

```
at com.oracle.svm.core.hub.ClassForNameSupport.forName(ClassForNameSupport.java:<line>)
at com.tiffinbox.aot.Startup.formatterNamed(Startup.java:43)
```

**That `forName` is not the JDK's.** In a native image, `Class.forName` is Substrate VM's own
implementation, and it answers out of a registry fixed when the image was built. The two json
files were the only thing that ever put those two class names into it. `Startup.java:43` is the
line at the top of this unit — the one line no compiler can follow — and GraalVM's own line
number is masked to `<line>` because it moves with the GraalVM version, while ours is not
masked, because it is this project's line.

`reflect-config.json` is three entries. Deleting it takes the reflection registration count
from **2741** down by **4**, which is the whole of the difference between a program that
works and one that does not:

```
exit code .......................... 1
exception type ..................... java.lang.ClassNotFoundException
first line of the message (plain) .. com.tiffinbox.aot.PlainFormatter
first line of the message (ledger) . com.tiffinbox.aot.LedgerFormatter
frames each failure printed ........ 8 and 8, from wc - 2 shown above, 6 elided
```

**That trio — exit code, exception type, first line of the message — is the artifact worth
keeping**, and it is what gets hashed. The capture around it is not: its last frame is a
generated `LambdaForm` holder whose name carries a per-build suffix, so the raw stderr would
not hash twice. 8 frames were printed, two are shown because those two are the lesson, and
the elision count comes from `wc`.

**And the two costs are not the same kind of thing.** The build printed 8 stages and you wait
through all of them — twice over, to get this comparison, which is why the block is not part of
a bare `./receipts.sh` run. The failure cost no build at all: it was already sitting in the
artifact the green build handed over, and it arrives on the first run.

⚠ **`clean` is load-bearing in both builds, and this A/B was a false negative without it.**
`maven-resources-plugin` does not delete stale resources, so `mvn -Pnative package` after an
earlier build leaves the previous run's copy of `reflect-config.json` in `target/classes`,
packages it into the jar, and the deletion becomes invisible — the "broken" binary runs
perfectly. The block counts what actually reached the jar (`reachability files inside its jar
.... 0`) instead of trusting that the files are gone.

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
project already has. It is also, exactly, why the binary above failed: `jdeps` cannot see
those two names and neither can a closed-world compiler, and this page now has both halves
of that sentence measured.

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

**That is the difference between the two kinds of ahead-of-time, and this unit no longer has
to take the second half on trust.** An AOT cache is an optimisation over a program that is
still complete: there is a jar beside it, and it falls back. A native image has no jar beside
it, and the `native` block above is what that costs — same program, same missing class, and a
`ClassNotFoundException` that no build stage complained about.

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
anything at all**, which is why the binary in this unit had to be run before anyone found out.

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
JVM ignores them. **Both are now known to be load-bearing rather than assumed to be**: the
`native` block deletes them and the binary stops working.

## Exercise — `exercise/`

See `exercise/README.md`. **Start state:** the metadata covers **1 of 2** formatter classes,
so a binary built from it runs `plain` and dies on `ledger`. **End state:** 2 of 2, with
**0 lines of Java changed**.

The exercise's real point is its last paragraph: the check that catches this needs **no
GraalVM at all** — every value in `formatters.properties` compared against the names in the
json, eight lines of Python, running in CI, costing no build minutes. `./receipts.sh native`
is what that check is standing in for, and it costs minutes and a 339 MB download.

## Receipts

| Block | What it proves |
|---|---|
| `closedworld` | `jdeps` reports **0** edges from the entry point to either formatter |
| `aot` | the JDK 25 AOT cache, as counts; and the class the training run never saw being loaded from the jar |
| `jlink` | two runtimes, 5 modules vs 1, exit 0 vs exit 1, nothing recompiled |
| `graalvm` | what the native profile pins, every line read out of `pom.xml` and `central/` — the same hash on every machine |
| `native` | **the binary, and the same binary with its two reachability files deleted: BUILD SUCCESS both times, exit 0 then exit 1.** Minutes long, not part of a bare run, skips without `GRAALVM_HOME` |
| `nativeconfig` | the metadata, parsed rather than eyeballed, and both formatters covered |
| `solution` | the exercise, start state asserted before it is answered |
| `offline` | `mvn -o test` after a warm `package` |

**Not hashed, and each says so:** every byte size — the AOT configuration, the AOT cache,
the jar, the two jlink images, and **both native binaries** (C2 finding #3: a size goes on a
slide only after it has repeated, and image sizes move with the compression level and the JDK
build). The binary's size is the newest entry on that list and it earned its place there: it did not
repeat. **Four runs of `./receipts.sh native` on 2026-09-17, over identical sources, gave
51,018,376 · 51,018,376 · 51,018,360 · 51,001,848 bytes for the shipped binary** — a spread of
about 16 KB, and on the fourth run it landed on exactly the size the *no-metadata* binary has
had every time, which is a coincidence and a good illustration of why a size is not an
identity. That is precisely the situation C2 finding #3 was written for (a `.dmg` that differed
between two identical builds). The block prints both sizes outside its hash and no slide quotes
either.

The `native` block's own `no md5:` line carries the two sizes of the run that printed it, and
deliberately **not** a list of what earlier runs measured — a script cannot know its own past,
and an earlier draft that hardcoded three sizes was wrong by the fourth run. The spread above is
recorded here, on a page a person maintains, instead.
