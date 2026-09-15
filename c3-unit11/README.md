# c3-unit11 — the Section 3 baseline

Course 3 · Build & Test Like a Pro · Section 3 "Testing That Earns Trust".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16**, macOS 27.0, Apple silicon, on 2026-09-15.

This is the project the rest of the testing section grows from. The `src/main/java` sources are
**byte-identical** to `c3-tiffinbox/tiffinbox-core` — the same five classes you finished the Gradle
section with, not a fresh toy. You can check that yourself:

```
cd src/main/java/com/tiffinbox              && md5 -q *.java | sort | md5 -q
cd ../../../../../../c3-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox && md5 -q *.java | sort | md5 -q
```

Both print `fdb1643d622615f3c331d75deaebb9da`.

## Run it

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" test
```

The `export` is line 1 for a reason: a bare `mvn` on the machine this was built on resolves a
different JDK, and `maven.compiler.release` is 25. The quotes around `-Dmaven.repo.local=` are load
bearing if the path you cloned into contains a space — without them the shell splits the argument and
Maven reads the tail as a goal name.

`.m2-demo/` keeps every jar this project resolves inside the project directory, so your real
`~/.m2/repository` is never touched by anything here.

## What is in it

| Path | What it is |
|---|---|
| `pom.xml` | the `junit-bom` import, `junit-jupiter` at test scope with **no version of its own**, and surefire **pinned** |
| `src/main/java/com/tiffinbox/` | the five core classes, unchanged |
| `src/test/java/com/tiffinbox/CustomerTest.java` | lifecycle callbacks that **print**, `assertAll`, `assertThrows`, `assumeTrue` |
| `breaks/one-assertion/` | one **correct** `Customer` and a test that asks for two wrong things, checked two ways — run it and compare the two reports |
| `breaks/green-for-nothing/` | three passing tests over a method that is wrong, and `BUILD SUCCESS` under them |
| `exercise/` | starts at `No tests to run.`; the end state is a green `Tests run: 1` |
| `receipts.sh` | regenerates every number this unit shows |

## Two things worth knowing before you read the POM

**The BOM decides one version for the whole family.** Import `org.junit:junit-bom` once in
`dependencyManagement`, and every JUnit artifact below carries no `<version>`. `./receipts.sh bom`
prints the resolved list and counts the distinct version numbers in it; the count it prints is `1`.
In the JUnit 5 line that same list had two numbers in it — Jupiter at `5.x`, the Platform at `1.x`.
This line unified them, so an artifact's version now tells you the generation directly.

**Pin surefire.** Delete the surefire block and the build still works — Maven falls back to its own
default binding, which is `3.5.4` on Maven 3.9.16. `./receipts.sh notests` shows exactly that
happening in `exercise/`, where surefire is deliberately left unpinned: the goal line reads
`surefire:3.5.4:test`. Which version runs your tests should not depend on which Maven you installed.

## The one to run before you write another test

```
cd breaks/green-for-nothing && mvn -B -Dmaven.repo.local="../../.m2-demo" test
```

```
[INFO] Tests run: 3, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

That `Customer` bills a **31-day** month. Ravi's bill comes back as `7440` where it should be
`7200`, and three tests pass over it: one calls the method and asserts nothing at all; one asserts
the bill is greater than zero, which every possible answer satisfies; one asserts that nothing was
thrown, which arithmetic never does. Three green ticks, and not one of them looks at the number.

`./receipts.sh green` proves that by running it: first the three tests against the wrong bill,
then the **same three tests against a different wrong bill** — a 29-day month instead of 31 —
where all three stay green and the receipt derives *0 of them constrain the value*. Then it
copies in a fourth test — one `assertEquals` — and the same suite becomes
`Tests run: 4, Failures: 1`. Every count in that block is derived from those two runs.

**The question to ask of any test you write: what would this have to see before it failed?**

## receipts.sh

```
./receipts.sh              # every block
./receipts.sh bom break    # just these two
```

Every number it prints is **derived from the run above it** — the failure counts come from a `grep -c`
over that run's own output, not from a string in this file. Change a filter and the hash changes.
The whole output was byte-identical across three consecutive runs on the machine above.

Ten blocks, in this order:

| Block | What it proves | md5 | exit |
|---|---|---|---|
| `capstone` | the delivered `../c3-tiffinbox`, rebuilt: `No tests to run.` once per module, from a surefire nobody pinned | `1a290aa9f17a44a2eff968b6678015a7` | 0 |
| `lifecycle` | every callback printed, in the order Jupiter really used — plus the file order and the method-name-`hashCode` order, recomputed and checked against it | `060f0c6386f0b9e4635030850f533afd` | 0 |
| `counts` | what the `[INFO]` filter kept out of surefire's `Tests run:` lines | `45e0c1aab64deacf3d60aacb44f9e787` | 0 |
| `bom` | 6 JUnit artifacts on the test classpath, 1 distinct version number | `27d8912283a93cb763b75feaec288f42` | 0 |
| `platform` | the repository holds **two** `junit-platform` version lines; the test classpath carries **one** | `76a9fb9ea5cf4ab832cfbab771a507dd` | 0 |
| `notests` | the exercise's starting state, and the surefire version Maven picked with no pin | `02d05faf294ebde2d808989cb5a07620` | 0 |
| `break` | `assertAll` named 2 failures; three statements in a row named 1 — each class counted inside its own report entry, and the order surefire used printed beside them | `ce5b4f23aeefab925d4a4180b001c344` | **1** |
| `green` | three green tests, a different wrong answer, and the fourth test that catches it | `c213776160cee7ca719b4f5fe6c21f72` | 0 then **1** then 0 |
| `solution` | the exercise answer, actually run | `49e4b8dbc1c540946db7d3a916c593e7` | 0 |
| `offline` | contract §1c, after one warm build | `44678bee0769ebbde049244fd2f194d9` | 0 |

`capstone` needs `../c3-tiffinbox` beside this directory, because that is where the opening capture
of the lesson comes from — it is the long-lived project's own build, not something written for the
video. If a later unit ever gives that project tests, the block **stops with a message saying the
slide is a historical capture and must be re-cut**, rather than quietly hashing something else.

`lifecycle` does one thing worth calling out. Jupiter runs the four test methods in an order that is
neither the file's nor random, and it is easy to say why and be wrong: there is **no default
`MethodOrderer`**. With no `@TestMethodOrder` and no `junit.jupiter.testmethod.order.default`, no orderer is
installed at all — `MethodOrderer.Default` is a marker class that cannot be instantiated and whose
`orderMethods()` body is empty. The sort belongs to `junit-platform-commons`:
`Integer.compare(m1.getName().hashCode(), m2.getName().hashCode())`. So the block recomputes that hash over
the four method names in `CustomerTest` and **stops with a message** if the order it predicts is not the
order the run printed:

```
declared in the file: monthlyBill assertAll assertThrows assumeTrue
sorted by method-name hashCode: assertAll monthlyBill assumeTrue assertThrows - and that is the order above
```

It is deterministic and it repeats — and it is an implementation detail JUnit documents as deliberately
nonobvious, so do not build a test on it.

`platform` is the one block whose output does not appear on a slide. It answers the question a viewer
asks the same day they first look inside their local repository:

```
in the local repository: 2 junit-platform version line(s) - 1.14.4 6.1.3
on the test classpath:   1 junit-platform version line(s) - 6.1.3
```

Surefire's own `surefire-junit-platform` provider resolves the `1.14.4` line for itself. Those jars
are **not** on your test classpath, and your tests do not run on them.

## Offline

```
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -o test
```

passes after one warm build (`./receipts.sh offline`). Nothing here needs the network twice.

> 📌 Code for this unit: tiffinbox-java/c3-unit11 · verified on JDK 25.0.4.1
