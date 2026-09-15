# c3-unit15 — Mockito's sharp edges

Course 3 · Build & Test Like a Pro · Section 3 "Testing That Earns Trust".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16**, macOS 27.0, Apple silicon, on 2026-09-15.

The five classes in `src/main/java` are the ones you have been building since the Gradle
section, unchanged. Check it yourself — the same command in `c3-unit11` prints the same hash:

```
cd src/main/java/com/tiffinbox && md5 -q *.java | sort | md5 -q
```

Both print `fdb1643d622615f3c331d75deaebb9da`.

## Run it

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" test
```

The `export` is line 1 for a reason, and in a testing unit it is a sharper reason than usual:
surefire **forks a JVM** to run your tests, and that fork inherits Maven's JDK. Every agent
in this section — Mockito's, JaCoCo's — is being exercised on whichever JDK Maven picked. An
unpinned JDK does not just risk a compile error; it voids the receipt.

The quotes around `-Dmaven.repo.local=` are load bearing if the path you cloned into contains
a space — see **The quoting trap** below, which is the same hazard in a second place.

## What is in it

| Path | What it is |
|---|---|
| `pom.xml` | AssertJ, Mockito and `mockito-junit-jupiter`; `maven-dependency-plugin:properties` and a surefire `<argLine>` that declares Mockito as a **static agent** |
| `src/test/.../MockedRepositoryTest.java` | a mock used where a mock belongs — our own boundary, stubbed, verified, `verifyNoMoreInteractions` |
| `src/test/.../FakeDatabaseTest.java` | the same assertions against a **fake**: a real repository over a real H2 database that happens to live in memory |
| `src/test/.../EveryStubIsUsedTest.java` | the shape strict stubs are happy with |
| `breaks/green-over-broken/` | **the one to run first.** One character wrong in the SQL. The mocked test passes; the real database does not |
| `breaks/strict-vs-lenient/` | the same unused stub under both strictness settings, in one run |
| `exercise/` | a build that fails with `UnnecessaryStubbingException`; fix the test, not the setting |
| `receipts.sh` | regenerates every capture and every number this unit shows — ten blocks |

## The one to run first

```
cd breaks/green-over-broken
mvn -B -Dmaven.repo.local="../../.m2-demo" test
```

`MockedJdbcTest` is green. `RealDatabaseTest` is not:

```
Column "MEAL_TYP" not found; SQL statement:
SELECT name, meals_per_day, price_per_meal, meal_typ FROM customer ORDER BY name [42122-250]
```

Two tests, one repository, one column name. The mocked one passes **because the stubs were
written by reading the same broken code**. `Connection`, `PreparedStatement` and `ResultSet`
belong to JDBC, not to you; a mock of somebody else's type can only ever agree with what you
already believed about it.

## The quoting trap — worth knowing before it costs you an hour

Declaring Mockito as a static agent means a surefire `<argLine>` that points at a jar:

```
<argLine>-javaagent:"${org.mockito:mockito-core:jar}"</argLine>
```

**Those quotes are not decoration.** Surefire splits `argLine` on whitespace before handing it
to the forked JVM, so if the path to the agent jar contains a space the argument is torn in
half and the fork dies before a single test runs.

`./receipts.sh quoting` does not *hope* your checkout has a space in it — it builds the trap.
It points `-Dmaven.repo.local` at a symlink whose own name contains a space, runs the project
once with the quotes removed and once as shipped, and refuses to print anything at all if the
unquoted run succeeds:

```
--- argLine WITHOUT the quotes, agent jar under a path containing a space ---
Error opening zip file or JAR manifest missing : <the agent path, torn at its first space>
[ERROR] Error occurred during initialization of VM
[INFO] Tests run: 0, Failures: 0, Errors: 0, Skipped: 0
--- the same directory, the same repository, argLine WITH the quotes ---
[INFO] Tests run: 4, Failures: 0, Errors: 0, Skipped: 0
unquoted -> exit 1, 0 test(s) ran; quoted -> exit 0, 4 test(s) ran
the quotes are load bearing on this machine: yes
```

Both sides read through the same filter, and the verdict comes from the two exit codes.
JaCoCo, in the coverage unit, quotes its own agent argument for you *when the path needs it*;
Mockito's property does not, because the property is only the path.

`./receipts.sh agent` is the guard that the static agent is still *declared and still working*,
and it needs both halves. The pom is checked for an `<argLine>` element whose own content
declares `-javaagent:`, anchored to the start of a line — unanchored, the pattern matches the
prose comment three lines above the element, which names `<argLine>` and `-javaagent:` in one
sentence, and then reads 2 when the truth is 1 and still reads 1 with the agent deleted. Then
the run itself has to agree: declaring the agent statically is exactly what stops Mockito
attaching one at run time, so a `self-attaching` line in the capture fails the block, however
convincing the pom looks.

## receipts.sh

```
./receipts.sh              # every block: tests counts green strict doubles agent quoting exercise solution offline
./receipts.sh green strict # just these two
./receipts.sh | md5        # 46d9109477ef72314d0d11c65f0c3edd
```

Every number it prints is **derived from the run above it** — the stub counts come from a
`grep -c` over the test sources, the green/errored split is computed by `awk` from the
surefire summary line that same run produced. Change a filter and the hash changes.

Three of those captures exist because a value on a slide was true but derived nowhere, and a
value nothing derives is a value a wrong edit moves no hash:

- **`counts`** runs no build. It reads the `@Mock` types and the `when(…)` lines out of
  `MockedJdbcTest` and `RealDatabaseTest`, and sorts each mocked type into **ours** (a source
  of that name in this project's `src/main`) or **JDBC's** (imported from `java.sql`). A type
  that is neither **fails the block** rather than being counted on the wrong side. It reads
  both field styles — `@Mock Database db;` and `@Mock` on its own line above the field — and
  it cross-checks two *different* passes, `@Mock` annotation **sites** against types
  **resolved**, plus stubs against mocks. That is the point: a reader that understands one
  style returns zero for the other in silence, and guards built out of one assumption agree
  with each other at zero while the block still exits 0.
- **`exercise`** runs the exercise *untouched* — `solution` copies the answer over the
  starting test before it runs, so the failing start state is never captured otherwise — and
  reads the line numbers Mockito reported back out of the report, checking each one really is
  a `when(repo` line in the shipped file.
- **`green`** emits two captures from one build: the hook's single green `MockedJdbcTest`
  line, and the `Results:` block underneath it.

The last line of the whole run is not a hash of this file. `md5 receipts.sh` is a different
number and means nothing; what is checkable is what the script **prints**, which is why the
command above pipes it.

## Offline

```
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -o test
```

passes after one warm build (`./receipts.sh offline`). Note the order: offline mode can only
reuse what a previous **online run of the same lifecycle** fetched. A repository that has
only ever run `dependency:tree` will fail `mvn -o test` on a plugin it never downloaded.

> 📌 Code for this unit: tiffinbox-java/c3-unit15 · verified on JDK 25.0.4.1
