# c3-unit13 — the unit whose subject is the failure message

Course 3 · Build & Test Like a Pro · Section 3 "Testing That Earns Trust".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16**, macOS 27.0, Apple silicon, on 2026-09-15.

Forked from `c3-unit12` with **one new dependency**: `org.assertj:assertj-core:3.27.7`.
`src/main/java` is still byte-identical to `c3-tiffinbox/tiffinbox-core`:

```
cd src/main/java/com/tiffinbox && md5 -q *.java | sort | md5 -q     # fdb1643d622615f3c331d75deaebb9da
```

## Run it

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" test
```

`src/test/java` is green. **The failures live in `breaks/three-messages/`, and they are the unit** —
a failure message you cannot see is not evidence of anything.

## Why 3.27.7 and not 4.0.0-M1

Maven Central's `<release>` field for `assertj-core` says **`4.0.0-M1`**. That is not the newest GA;
it is the newest *published* version, milestones included. Read the dates:

```
org/assertj/assertj-core/3.27.7     published 2026-01-24
org/assertj/assertj-core/4.0.0-M1   published 2025-03-09
```

**The milestone Central labels `<release>` is ten months older than the GA it hides.** The field is
simply **the last entry of the `<versions>` list**, and that list is in **version order — major number
first**. It is not text order (`3.9.1` sits *before* `3.10.0`, which a text sort would reverse) and it
is not publication order (`4.0.0-M1` sits last while being the older of the two). So a `4.x` milestone
outranks the newest `3.x` GA, and the field has no idea one of them is a milestone. Pin the newest GA,
found by reading the list.

`./receipts.sh release` derives every number above — **offline**. It reads `central/`, which holds the
`maven-metadata.xml` and the directory listing exactly as they came back from `repo1.maven.org` on
2026-09-15, and it asserts that the version this `pom.xml` pins *is* the newest GA in that list. A
metadata `curl` is not in this unit's network tier (`resolution only`), so the sweep is shipped as
bytes rather than repeated at build time.

## What is in it

| Path | What it is |
|---|---|
| `src/test/java/.../RosterAssertionsTest.java` | `extracting`, `filteredOn`, `containsExactlyInAnyOrder`, `usingRecursiveComparison`, `SoftAssertions`, `assertThatThrownBy` — all passing, over the real seeded roster |
| `breaks/three-messages/` | seven tests, every one failing on purpose. The lesson is what each failure **says** |
| `exercise/` | a failing test whose whole message is `expected: <true> but was: <false>` |
| `central/` | the authoring-time version sweep, shipped verbatim: Central's `maven-metadata.xml` and directory listing for `assertj-core`, fetched 2026-09-15. `./receipts.sh release` reads these, so the `<release>` chip is checkable offline |
| `receipts.sh` | regenerates every message and every count — **9 blocks**, `messages source records softly unsafe version release solution offline` |

## Three things the break project proves

**One bug, three assertions, three amounts of help.** Priya is missing from the roster.

```
cd breaks/three-messages && mvn -B -Dmaven.repo.local="../../.m2-demo" test
```

`assert` (Java's own keyword, which surefire runs with assertions enabled) reports the class, the
method and the line — and **nothing else at all**. `assertTrue` adds `expected: <true> but was:
<false>`, which is the same information restated. AssertJ prints the roster. `./receipts.sh messages`
counts the characters in each of the three messages so the comparison is a measurement, not an
impression.

**`assertEquals` is not the villain.** Handed two records it prints **both of them in full** — it is
`assertTrue` that carries zero information, and a slide claiming otherwise would be contradicted by
its own terminal. What `assertEquals` cannot do is say **which field** differs;
`usingRecursiveComparison` names it. Note the cost: that message runs to **20 lines**, and the last
eleven are a configuration dump. `./receipts.sh records` derives the elision count from the run.

**A chain of assertions stops at the first one.** Three things wrong with one customer; three
`assertThat` statements report **one**. `SoftAssertions` reports `Multiple Failures (3 failures)`,
numbered, with a line number each.

## The four warning lines nobody warns you about

On JDK 25, `new SoftAssertions()` costs you this, every run:

```
WARNING: A terminally deprecated method in sun.misc.Unsafe has been called
WARNING: sun.misc.Unsafe::objectFieldOffset has been called by net.bytebuddy...ClassInjector$UsingUnsafe... (<repo>/byte-buddy-1.18.3.jar)
WARNING: Please consider reporting this to the maintainers of class net.bytebuddy...
WARNING: sun.misc.Unsafe::objectFieldOffset will be removed in a future release
```

`sun.misc.Unsafe` is the JDK's own internal back door into raw memory, and the JDK is in the middle of
closing it. Soft assertions are built out of a generated proxy class, AssertJ generates it with **Byte
Buddy**, and Byte Buddy reaches for `Unsafe` to inject that class. Byte Buddy is nowhere in this
`pom.xml` — `./receipts.sh unsafe` says so with a number rather than an adjective, `grep -c
'<artifactId>byte-buddy</artifactId>' pom.xml`, so the line reads **`appears 0 time(s) in this pom`**
and declaring the library moves both the line and the block's md5. `mvn dependency:tree` shows where it
came from, and the same block runs the project twice: four warning lines without
`--sun-misc-unsafe-memory-access=allow`, zero with it, exit 0 either way, and it asserts the same five
tests ran on both sides first. The flag is handed to surefire on the command line,
`mvn -B test -DargLine='--sun-misc-unsafe-memory-access=allow'` — the same parameter as a surefire
`<argLine>` element in the POM, which is why the slide can teach the element: this POM gives surefire no
`<configuration>` of its own, so there is nothing for the property to lose to.

The flag is not shipped here on purpose. It silences a warning; it does not change what the code
does, and a future JDK that flips that option's default to `deny` will turn this into a failure
rather than a warning. Know what you are quieting.

## receipts.sh

```
./receipts.sh              # every block - 9 of them
./receipts.sh messages     # just this one
./receipts.sh 2>&1 | md5   # 31716a381967b32054cbc16382139d98 - the whole RUN, not the file
```

Every count a slide shows is derived **inside** the bytes its block's md5 covers, so a wrong number
moves a hash. That includes the two elisions on the source panel: `./receipts.sh source` re-reads
`RosterAssertionsTest.java`, prints the gaps between the three groups the slide keeps and counts them
(`2` lines and `23` lines, in a `74`-line file). The group boundaries are anchored — insert a line into
either gap and the block stops with the stale line number rather than counting the wrong one.

Each failure message is pulled out of the report by its own `[ERROR]  Class.method` marker, so the
capture does not depend on which order the classes ran in. `Time elapsed:` is stripped before
anything is hashed.

## Offline

```
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -o test
```

passes after one warm build (`./receipts.sh offline`). Offline mode can only reuse what a previous
**online run of the same lifecycle** fetched — a repository that has only run `dependency:tree` will
fail `mvn -o verify` on a build plugin it never downloaded.

> 📌 Code for this unit: tiffinbox-java/c3-unit13 · verified on JDK 25.0.4.1
