# c3-unit08 — tasks, inputs, outputs

The same five `tiffinbox-core` sources as [`../c3-unit07/`](../c3-unit07/), plus **one custom task**
that reads a text file and writes a Java source file. That task is here so that the build has
something of yours in it — everything this unit says about `UP-TO-DATE` is true of `compileJava` too,
but you cannot break `compileJava` on purpose and you can break this.

```
c3-unit08/
  src/main/java/com/tiffinbox/   the five core sources, byte-identical to c3-tiffinbox
  src/main/menu/menu.txt         the generator's input: three lines
  build.gradle.kts               java plugin + the GenerateMenu task, inputs and outputs declared
  gradle.properties              org.gradle.caching=true
  breaks/undeclared-input/       the same task with one annotation removed
  exercise/
  gradlew · gradle/wrapper/      Gradle 9.7.1, pinned by sha256
```

## Every hash on this page is regenerable

```bash
./receipts.sh            # re-runs every quoted capture and prints its md5
./receipts.sh break      # just one of them
```

`receipts.sh` holds the **exact** pipeline behind each hash, including every `grep` and `sed`, and it
resets its own state first, so the numbers below are checkable rather than quotable. A hash taken over
a capture that was trimmed afterwards is not a receipt.

## Requirements

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRADLE_USER_HOME="$PWD/.gradle-home"
```

Run those from **this directory** and keep them exported: the `breaks/` project below is run with
`../../gradlew`, and it shares this one Gradle home so the 9.7.1 distribution is downloaded once.
Without `JAVA_HOME` the compiler fails with `error: release version 25 not supported` — see the unit
07 README for that capture.

## Three answers, not two

Run the build three times, in three different states. Gradle prints a different word each time, and
the three words mean three different things.

```bash
./gradlew --no-build-cache -q clean
./gradlew --console=plain build                      | grep -E '^> Task :(generateMenu|compileJava|jar)|actionable'
./gradlew --console=plain build                      | grep -E '^> Task :(generateMenu|compileJava|jar)|actionable'
./gradlew -q clean && ./gradlew --console=plain build | grep -E '^> Task :(generateMenu|compileJava|jar)|actionable'
```

```
$ ./gradlew build                       # nothing built yet
> Task :generateMenu
> Task :compileJava
> Task :jar
3 actionable tasks: 3 executed

$ ./gradlew build                       # straight away, again
> Task :generateMenu UP-TO-DATE
> Task :compileJava UP-TO-DATE
> Task :jar UP-TO-DATE
3 actionable tasks: 3 up-to-date

$ ./gradlew clean && ./gradlew build    # outputs deleted, inputs unchanged
> Task :generateMenu
> Task :compileJava FROM-CACHE
> Task :jar
3 actionable tasks: 2 executed, 1 from cache
```

- **`UP-TO-DATE`** — the outputs are still on disk and still match the inputs, so there is nothing to do.
- **`FROM-CACHE`** — the outputs were *gone*, but this exact set of inputs has been compiled before, so
  the result was copied out of the build cache instead of being made again. Different claim, different word.
- **no word at all** — the task ran.

**Why only `compileJava` says `FROM-CACHE`.** Ask, do not guess:

```bash
./gradlew -q clean && ./gradlew --console=plain build --info | grep -A1 '^Caching disabled for task'
```

```
Caching disabled for task ':generateMenu' because:
  Caching has not been enabled for the task
Caching disabled for task ':jar' because:
  Not worth caching
```

A custom task is not cacheable until you mark it `@CacheableTask`, and Gradle decides on its own that
re-zipping a jar is cheaper than fetching one. Those are Gradle's words, not a summary of them.

*Receipts:* `./receipts.sh three-states` → `md5 4ce8b3e6e3177766e46f27ba1180cc26` ·
`./receipts.sh caching-why` → `md5 9a9b3b54fbcf9b21c575e2d1bf1d14e9`. Both three runs, exit 0.

## Gradle will tell you why, for every task

```bash
./gradlew --no-build-cache -q clean && ./gradlew --no-build-cache -q build
./gradlew --console=plain --no-build-cache build --info | grep '^Skipping task'
```

```
Skipping task ':generateMenu' as it is up-to-date.
Skipping task ':compileJava' as it is up-to-date.
Skipping task ':processResources' as it has no source files and no previous output files.
Skipping task ':classes' as it has no actions.
Skipping task ':jar' as it is up-to-date.
Skipping task ':assemble' as it has no actions.
Skipping task ':compileTestJava' as it has no source files and no previous output files.
Skipping task ':processTestResources' as it has no source files and no previous output files.
Skipping task ':testClasses' as it has no actions.
Skipping task ':test' as it has no source files and no previous output files.
Skipping task ':check' as it has no actions.
Skipping task ':build' as it has no actions.
```

Twelve tasks, twelve reasons, three kinds of reason — *up to date* (3), *no source files* (4),
*no actions* (5). Nothing is silent. *Receipt:* `./receipts.sh skip-reasons` → `md5 35c30d2604ea1d8153d59fda63fbf00c`.

Now change the input and ask again:

```bash
echo 'Lentil Soup|VEGAN' >> src/main/menu/menu.txt
./gradlew --console=plain --no-build-cache build --info | grep -E "is not up-to-date because:|  Input property"
```

```
Task ':generateMenu' is not up-to-date because:
  Input property 'menuFile' file src/main/menu/menu.txt has changed.
Task ':compileJava' is not up-to-date because:
  Input property 'stableSources' file build/generated/menu/com/tiffinbox/MenuCatalog.java has changed.
Task ':jar' is not up-to-date because:
  Input property 'rootSpec$1' file build/classes/java/main/com/tiffinbox/MenuCatalog.class has changed.
```

(Absolute paths shortened to fit; the real output names the full path of each file.)
One edit to a text file; three tasks re-run; each one names the exact file that changed, and the file
it names is the previous task's output. That chain is the build graph, printed.
*Receipt:* `./receipts.sh change-reasons` → `md5 95c02a68a4552c9dc462dabb8b3feb96` — the script applies
`sed -E "s|file .*c3-unit08/|file |"` before hashing, which is the same shortening you see above.

Put it back:

```bash
printf 'Grilled Chicken|NON_VEG\nSteamed Rice|VEG\nGarden Salad|VEGAN\n' > src/main/menu/menu.txt
```

## The break: a green build that did nothing

`breaks/undeclared-input/` is the same generator with **one annotation removed** — `@get:InputFile`.
The task still reads `src/main/menu/menu.txt`; it just reads it inside the action, from a plain
`File`, where Gradle cannot see it. Gradle has an output to check and nothing to check it against.

```bash
cd breaks/undeclared-input
../../gradlew -q clean
../../gradlew --console=plain build | grep -E '^> Task :(generateMenu|compileJava|jar)|actionable'
java -cp build/classes/java/main com.tiffinbox.MenuCatalog
echo 'Lentil Soup|VEGAN' >> src/main/menu/menu.txt ; wc -l < src/main/menu/menu.txt
../../gradlew --console=plain build | grep -E '^> Task :(generateMenu|compileJava|jar)|actionable'
java -cp build/classes/java/main com.tiffinbox.MenuCatalog
```

```
$ ./gradlew build
> Task :generateMenu
> Task :compileJava
> Task :jar
3 actionable tasks: 3 executed
$ java -cp build/classes/java/main com.tiffinbox.MenuCatalog
menu items: 3
[Grilled Chicken, Steamed Rice, Garden Salad]
$ echo "Lentil Soup|VEGAN" >> src/main/menu/menu.txt ; wc -l < src/main/menu/menu.txt
       4
$ ./gradlew build
> Task :generateMenu UP-TO-DATE
> Task :compileJava UP-TO-DATE
> Task :jar UP-TO-DATE
3 actionable tasks: 3 up-to-date
$ java -cp build/classes/java/main com.tiffinbox.MenuCatalog
menu items: 3
[Grilled Chicken, Steamed Rice, Garden Salad]
```

**The file has four lines. The jar says three. The build said `BUILD SUCCESSFUL`.**

Note what the proof is, because it matters: not the build result — the **program's own output**, next
to `wc -l` of the file it was generated from. A green build is not evidence that a tool ran.
*Receipt:* `./receipts.sh break` → `md5 6a4e45e40f02963812bb1a0b49b9d38e`, exit 0, three runs.

Reset it:

```bash
printf 'Grilled Chicken|NON_VEG\nSteamed Rice|VEG\nGarden Salad|VEGAN\n' > src/main/menu/menu.txt
cd ../..
```

The fixed task, one directory up, given the identical edit:

```bash
./gradlew -q clean && ./gradlew --no-build-cache -q build
echo 'Lentil Soup|VEGAN' >> src/main/menu/menu.txt
./gradlew --console=plain --no-build-cache build | grep -E '^> Task :(generateMenu|compileJava|jar)|actionable'
java -cp build/classes/java/main com.tiffinbox.MenuCatalog
```

```
> Task :generateMenu
> Task :compileJava
> Task :jar
3 actionable tasks: 3 executed
menu items: 4
[Grilled Chicken, Steamed Rice, Garden Salad, Lentil Soup]
```

*Receipt:* `./receipts.sh fixed` → `md5 c45972a54e91ebac4516935937a43738`.
**`--no-build-cache` is in that command on purpose:**
with the cache on, the second and third runs of this sequence fetch `compileJava` `FROM-CACHE` instead
of executing it, and the capture stops being byte-identical. Measured, not assumed — that is exactly
what happened here the first time.

## A note on the syntax

`build.gradle.kts` registers the task like this:

```kotlin
val generateMenu = tasks.register<GenerateMenu>("generateMenu") { … }
```

and **not** like this:

```kotlin
val generateMenu by tasks.registering(GenerateMenu::class) { … }
```

The second form is what most tutorials and most Stack Overflow answers use. On Gradle 9.7.1 it builds,
and prints:

```
The 'val name by registering(Type::class) { }' property delegate syntax has been deprecated.
This is scheduled to be removed in Gradle 10. Use 'val element = register<Type>(name) { }' instead.
```

You only see it with `--warning-mode all`. Worth running on your own build once.

## Offline

```bash
./gradlew --offline build                       # BUILD SUCCESSFUL, 3 actionable tasks: 3 up-to-date
cd breaks/undeclared-input && ../../gradlew --offline build
```

## Clean up

```bash
./gradlew --stop
rm -rf build .gradle .gradle-home breaks/undeclared-input/build breaks/undeclared-input/.gradle exercise/build exercise/.gradle
```

## Verified

**JDK 25.0.4.1**, **Gradle 9.7.1** via the committed wrapper, macOS 27.0, 8-core 16 GB Apple silicon,
**2026-09-15**. Every command run three times; every hash is over the exact pipeline printed above it.
No duration on this page is quoted as a fact — this unit's lesson is the word Gradle prints, and the
counts beside it. `~/.gradle` was not written to.
