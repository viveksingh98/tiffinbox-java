# Unit 13 — Externalized Configuration and the Environment

Course 4 · Section 3 · *Configuration and Environment*.
**Verified on JDK 25.0.4.1**, Apache Maven 3.9.16, Spring Framework 7.0.9, macOS 27.0.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
```

**Line 1 of every command below.** A bare `java` on the machine these captures were taken on is
**23.0.1** and cannot load a class file the pinned 25 compiler wrote; a bare `mvn` resolves **26.0.2.1**
and would compile `<release>25</release>` with a JDK this course does not use.

```
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"
```

Quote `-Dmaven.repo.local="$PWD/.m2-demo"`. The path above this folder contains a space, and an
unquoted expansion is split by bash. (It is *not* split by zsh, which is what the author's shell is —
so this is a bug that appears only on somebody else's machine.)

## What this unit proves

**1 — The `Environment` is an ordered list, and the first match wins.**

```
java -cp "$CP" com.tiffinbox.Sources
```

`.r-files.out` · md5 `92ca37b1f782ad7bcc09161dd3b1a00b` · exit 0 · 3 of 3.

The list is printed off the live `Environment`, the count is the length of that iteration, and
`sources carrying tiffinbox.rail` is counted while walking it. Nothing on the slide is typed.

**2 — The LAST `@PropertySource` declared wins, which is the reverse of reading order.**

```
./flip.sh
```

A/B/A′ on one edit — the order of two annotations — with the file restored by a `trap` even if a
compile fails. A `92ca37b1f782ad7bcc09161dd3b1a00b` · B `bfce98701d69e5ee52fd324b9d98d7aa` ·
A′ `92ca37b1f782ad7bcc09161dd3b1a00b`. **A′ is a real third run, not A's hash copied**, which is the
only thing that makes "the swap did it" a measurement.

Course 3 taught nearest-wins for Maven dependencies. A viewer carrying that habit here guesses the
first declaration wins. It does not.

**3 — A JVM system property outranks every file you added.**

```
java -cp "$CP" com.tiffinbox.Sources sysprop
```

`.r-sysprop.out` · md5 `ae65ea619db80d59a0dd72c62528a6e6` · exit 0 · 3 of 3.

## The break — and it is a capture, not a crash

```
./flip.sh sysprop
```

The same A/B/A′, with one system property also set. The stack visibly reorders; **the `WINNER` line
does not move.** A `ae65ea619db80d59a0dd72c62528a6e6` · B `5a84e03f1366c6bb0ad20a6550844f70` ·
A′ `ae65ea619db80d59a0dd72c62528a6e6`.

`flip.sh` asks the two questions separately and prints both answers, because **"the output changed"
and "the answer changed" are different claims and this unit exists because they come apart**:

```
  -> THE WINNER DID NOT MOVE. The stack reordered underneath a line that stayed still.
     A viewer watching only that line would have concluded the swap did nothing.
```

That is the unit's lesson about evidence, and it is the reason the video shows this capture *before*
the one where the winner moves.

## The guards, and what each one refuses

`Sources` exits **2** rather than print something that looks like a receipt and is not:

| guard | why it exists |
|---|---|
| fewer than 2 property sources | there is no precedence to show with one source |
| fewer than 2 sources carry the key | an uncontested key has an answer, not a winner |
| `--key=` with no name | asking which source wins for the empty string is not a question |
| an unknown argument | a typo'd flag would otherwise run the default capture and look correct |

Try them:

```
java -cp "$CP" com.tiffinbox.Sources --key=tiffinbox.db.url   # exit 2 — only one source has it
java -cp "$CP" com.tiffinbox.Sources --nope                   # exit 2 — unknown argument
```

## Files

| file | what it is |
|---|---|
| `src/main/java/com/tiffinbox/Sources.java` | the ordered stack, printed off the live `Environment` |
| `src/main/java/com/tiffinbox/TiffinBoxConfig.java` | the description — **read the order of the two `@PropertySource` lines** |
| `src/main/resources/rails-one.properties` | declared first; loses the contested key |
| `src/main/resources/rails-two.properties` | declared second; wins it |
| `flip.sh` | A/B/A′ on the declaration order, both modes, with teardown |
| `Customer` · `CustomerRepository` · `Database` · `OrderQueue` · `Dashboard` | carried in from the long-lived project; the URL and the cook count now arrive as properties |
| `exercise/` | a quarter-staffed kitchen and nothing wrong with the build |

`Database` and `OrderQueue` take their URL and cook count from the files now rather than from
constants in a configuration class. That is the unit's title in one sentence: the values moved out,
and something has to decide which file wins.

## ERRATA — after the section's RED review (2026-09-26)

The video for this unit is live. These corrections were measured after it was published; the RED report and
BLUE's re-runs are in `spring-core/_briefs/RED-S3-2026-09-26.md` (course folder).

- **"The last property source you declare wins"** holds for sources declared in **one** configuration class.
  Across classes found by component scanning the order is hard to predict — the `@PropertySource` Javadoc says
  so, and renaming a scanned class flipped the winner in the RED probe. Keep order-sensitive files in one class.
- `systemEnvironment` (row 2) is real: `TIFFINBOX_COOKS=4` outranks both files. And a source added with
  `addFirst` outranks even a `-D` system property ("a system property sits above everything you added" is
  true only for `addLast`).
- The slide-5 chip says "5 rows not shown"; the capture hides 6.
