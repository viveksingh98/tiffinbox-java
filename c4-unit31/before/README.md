# c3-tiffinbox — TiffinBox, split into modules

The long-lived project of **Build & Test Like a Pro**. It starts as the Core Java II capstone
(`../c2-capstone/`) cut into three POMs, and every later unit in the course changes it: Gradle
scripts beside these POMs, a test source tree, a logging configuration, a workflow file, a
native-image profile.

```
c3-tiffinbox/
  pom.xml                 com.tiffinbox:tiffinbox-parent:1.0.0   <packaging>pom</packaging> — builds nothing
  tiffinbox-core/         com.tiffinbox        Customer · Database · CustomerRepository · OrderQueue · Dashboard
  tiffinbox-web/          com.tiffinbox.web    Route · TiffinBoxServer · logging.properties
```

**The rule that decides which class goes where: core knows nothing about HTTP, web knows
nothing about SQL.** Not a claim — `grep` it:

```bash
grep -rl "com.sun.net.httpserver" tiffinbox-*/src
grep -rl "java.sql" tiffinbox-*/src
```

```
tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java
tiffinbox-core/src/main/java/com/tiffinbox/Database.java
```

## What changed from the capstone, and why

| | `c2-capstone` | `c3-tiffinbox` |
|---|---|---|
| modules | 1 | **3** — parent (pom) + core + web |
| packages | `com.tiffinbox` | `com.tiffinbox` (core) · **`com.tiffinbox.web`** (web) |
| `Dashboard.load()` | `StructuredTaskScope.open(…)` — **preview** | **`ExecutorService.invokeAll`** — no preview |
| compile | `--release 25 --enable-preview` | `--release 25` |
| run | `java --enable-preview -jar …` | **`java -jar …`** |
| `target/lib` | 4 jars | **5** — the four, plus `tiffinbox-core-1.0.0.jar` |
| `Main-Class` | `com.tiffinbox.TiffinBoxServer` | `com.tiffinbox.web.TiffinBoxServer` |

**Two decisions, both deliberate.**

1. **The preview flag came out.** `StructuredTaskScope` is a preview API in JDK 25 (JEP 505),
   so it needs `--enable-preview` at compile time *and* at run time, which pins the project to
   one exact JDK. This build has to run on more than one. Nothing was wrong with the original —
   Course 2's capstone still uses it, unchanged — this is the build making a trade, and the
   trade is named. The proof it is faithful is below.
2. **The web classes moved to `com.tiffinbox.web`.** Two jars must not share a package. A
   *split package* is legal on the classpath and refused outright by the module system, and it
   would be inherited by everything this course does later. It cost one `package` line and five
   imports.

## Requirements

JDK **25 or newer** and Maven **3.9 or newer**. On a Mac with more than one JDK installed,
Maven uses the one `JAVA_HOME` names — and with `JAVA_HOME` unset it takes whatever `java` is
first on the path, which here is a different JDK entirely. So **every command below starts with
the export**:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -version           # Java version: 25.0.4.1
```

The first build downloads H2 2.5.250 and Jackson 2.22.2 from Maven Central; after that,
nothing.

## Build

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B clean package
```

Sixteen goals run: one for the parent (`clean` — that is all a `pom` module has to do),
seven for core, and eight for web, the extra one being `copy-dependencies`. The last block is
the reactor summary, in dependency order:

```
[INFO] Reactor Summary for TiffinBox 1.0.0:
[INFO]
[INFO] TiffinBox .......................................... SUCCESS [  n.nnn s]
[INFO] TiffinBox Core ..................................... SUCCESS [  n.nnn s]
[INFO] TiffinBox Web ...................................... SUCCESS [  n.nnn s]
[INFO] BUILD SUCCESS
```

The `[ n.nnn s]` column moves on every run and is the one thing on that block you must never
quote as a fact.

Read the manifest the build wrote:

```bash
unzip -p tiffinbox-web/target/tiffinbox-web-1.0.0.jar META-INF/MANIFEST.MF
```

```
Class-Path: lib/tiffinbox-core-1.0.0.jar lib/h2-2.5.250.jar lib/jackson-
 databind-2.22.2.jar lib/jackson-annotations-2.22.jar lib/jackson-core-2
 .22.2.jar
Main-Class: com.tiffinbox.web.TiffinBoxServer
```

```bash
ls tiffinbox-web/target/lib
```

```
h2-2.5.250.jar
jackson-annotations-2.22.jar
jackson-core-2.22.2.jar
jackson-databind-2.22.2.jar
tiffinbox-core-1.0.0.jar
```

`tiffinbox-core-1.0.0.jar` is in there because `copy-dependencies` does not care that it came
from the module next door: to `tiffinbox-web`, core is a dependency like any other.

## Run

**No `--enable-preview`.** That is the whole point of the swap.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
cd tiffinbox-web
java -Djava.util.logging.config.file=logging.properties -jar target/tiffinbox-web-1.0.0.jar
```

```
orders cooked:  120
kitchen value:  24300
routes mapped:  [GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown]
TiffinBox listening on http://127.0.0.1:18425
```

`-Djava.util.logging.config.file=` is not decoration: `logging.properties` pins
`SimpleFormatter.format = %5$s%n`, and without it the JDK stamps a date and the calling method
on every line. The server binds `127.0.0.1` explicitly, so it is reachable from this machine
and from nowhere else.

`tiffinbox-web/pom.xml` still carries `exec-maven-plugin`, and it no longer has to pass a
preview flag — but starting a module of a multi-module project through Maven needs the sibling
jar in a repository first, so it is **two** commands, not one:

```bash
mvn -B clean install                        # tiffinbox-core lands in your local repository
mvn -q -B -pl tiffinbox-web exec:exec
```

Without `-pl` the goal is asked of the parent too, which has no `<executable>` and fails with
`The parameter 'executable' is missing or invalid`; without the `install` the reactor cannot
find `tiffinbox-core`. Both of those are the local repository's doing, and the repository is a
subject of its own later on — which is why `java -jar` above is the command this project uses.

The port is `18425`; pass another as the first argument:
`java -jar target/tiffinbox-web-1.0.0.jar 9090`.

Then, in a second shell:

```bash
curl -s http://127.0.0.1:18425/customers
curl -s http://127.0.0.1:18425/dashboard
curl -s http://127.0.0.1:18425/kitchen
curl -s http://127.0.0.1:18425/revenue
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18425/pauses    # 404 — no such route
curl -s -w ' %{http_code}\n' http://127.0.0.1:18425/shutdown              # 405 — wrong verb
```

```json
[{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
{"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
{"ordersCooked":120,"ordersValue":24300}
{"monthRevenue":24300}
404
{"error":"method not allowed"} 405
```

## Stopping it

```bash
curl -s -X POST http://127.0.0.1:18425/shutdown     # -> {"stopping":true}
```

The JVM exits on its own a moment later; the database is in memory, so nothing is left on
disk. If a run was killed hard and the port is stuck,
`lsof -nP -iTCP:18425 -sTCP:LISTEN` names the process.

## The receipt: the split changed nothing observable

Both projects were started, asked the same seven questions (four routes, a 404, a 405, and
`POST /shutdown`), and shut down — **three runs of `c2-capstone` and three of `c3-tiffinbox`,
six captures, one hash**:

```
md5  d6402e7c500031cb39addba72cb846e5     6 of 6
diff c2-capstone-run.txt c3-tiffinbox-run.txt     (empty)
```

The class file is where you can see the flag actually leave. Same major version, different
minor:

```bash
javap -v -cp tiffinbox-core/target/classes com.tiffinbox.Dashboard | grep -E 'major|minor'
```

| | minor | major |
|---|---|---|
| `c2-capstone` `Dashboard.class` | **65535** — the preview bit | 69 |
| `c3-tiffinbox` `Dashboard.class` | **0** | 69 |

`65535` is why the capstone's jar cannot start without the flag:
`UnsupportedClassVersionError: Preview features are not enabled for com/tiffinbox/Dashboard
(class file version 69.65535)`. This project's jar has nothing to enable.

## Versions live in exactly one place

The parent's `<dependencyManagement>` decides `tiffinbox-core`, `h2` and `jackson-databind`;
its `<pluginManagement>` decides the four plugin versions. **No child POM contains a
`<version>` for a dependency or a plugin.** Check it:

```bash
mvn -B dependency:tree
```

```
[INFO] com.tiffinbox:tiffinbox-parent:pom:1.0.0
[INFO] com.tiffinbox:tiffinbox-core:jar:1.0.0
[INFO] \- com.h2database:h2:jar:2.5.250:compile
[INFO] com.tiffinbox:tiffinbox-web:jar:1.0.0
[INFO] +- com.tiffinbox:tiffinbox-core:jar:1.0.0:compile
[INFO] |  \- com.h2database:h2:jar:2.5.250:compile
[INFO] \- com.fasterxml.jackson.core:jackson-databind:jar:2.22.2:compile
[INFO]    +- com.fasterxml.jackson.core:jackson-annotations:jar:2.22:compile
[INFO]    \- com.fasterxml.jackson.core:jackson-core:jar:2.22.2:compile
```

**Run that on the whole project, never with `-pl`.** With `-pl tiffinbox-web`, Maven cannot
read the sibling's POM, so it draws `tiffinbox-core` as a leaf — **h2 disappears from the
picture** — prints one `[WARNING]` above the tree and then `BUILD SUCCESS`, exit 0:

```
[WARNING] The POM for com.tiffinbox:tiffinbox-core:jar:1.0.0 is missing, no dependency information available
[INFO] com.tiffinbox:tiffinbox-web:jar:1.0.0
[INFO] +- com.tiffinbox:tiffinbox-core:jar:1.0.0:compile
[INFO] \- com.fasterxml.jackson.core:jackson-databind:jar:2.22.2:compile
[INFO]    +- com.fasterxml.jackson.core:jackson-annotations:jar:2.22:compile
[INFO]    \- com.fasterxml.jackson.core:jackson-core:jar:2.22.2:compile
```

Jackson's own two children are still drawn — it is `tiffinbox-core` that goes flat, taking **h2** with it.

## Building part of it

| Command | Modules *built* | Result |
|---|---|---|
| `mvn -B clean package` | **3** | `BUILD SUCCESS` |
| `mvn -B clean package -pl tiffinbox-core` | **1** — *and no reactor summary is printed at all, which is why a summary-row counter reads zero here* | `BUILD SUCCESS` |
| `mvn -B clean package -pl tiffinbox-web` | **1** | **`BUILD FAILURE`**, exit 1 |
| `mvn -B clean package -pl tiffinbox-web -am` | **3** | `BUILD SUCCESS` |

`-pl` picks modules; `-am` *also makes* what they depend on. Without it:

```
[ERROR] Failed to execute goal on project tiffinbox-web: Could not resolve dependencies for project com.tiffinbox:tiffinbox-web:jar:1.0.0
[ERROR] dependency: com.tiffinbox:tiffinbox-core:jar:1.0.0 (compile)
[ERROR] 	Could not find artifact com.tiffinbox:tiffinbox-core:jar:1.0.0 in central (https://repo.maven.apache.org/maven2)
```

With only two jar modules, `-pl tiffinbox-web -am` **is** the whole build — measured, the
filtered capture of the two commands has the same md5. It starts paying the day there are nine
modules.

## Verified

Built and run on **JDK 25.0.4.1** (`/opt/homebrew/opt/openjdk@25`) with **Maven 3.9.16**,
macOS on Apple silicon, **2026-09-14**, from a clean copy outside the repository, with an
isolated local repository (`-Dmaven.repo.local=`) so nothing of ours reaches `~/.m2`.
Offline receipt after one warm build: `mvn -o -B verify` → `BUILD SUCCESS`, exit 0, three runs.


---

## Course 4 starts here (added 2026-09-16, Section 1 · The Container)

This directory is **the Course 3 line of TiffinBox, carried forward byte-identically** — it was
created by copying `c3-tiffinbox/`, which is frozen and read only. The five carried sources
still hash to `fdb1643d622615f3c331d75deaebb9da` here, as they do in every unit folder that
holds them.

**One thing had to be carried from somewhere else, and it is worth writing down:**
`Wiring.java` is *not* in `c3-tiffinbox/`. It lives in the previous course's final unit folder,
`c3-unit28/src/main/java/com/tiffinbox/wiring/Wiring.java`. It has been copied here into
`tiffinbox-core`, byte-identical, so that the ledger this course is built on has a real file to
count. Verified with `cmp`: identical.

The ledger, re-derived here rather than remembered (`c4-unit01/ledger.sh`):

```
  lines in startEverything(), comments and blanks removed ... 18
  objects constructed with new .............................. 4
  configuration values held as constants beside them ........ 3
  places that order is written down ......................... 0
  things that check it ...................................... 0
```

Units 01 to 30 each move one of those rows; the last unit of the course re-runs the count with
the file deleted. **Every one of those numbers is derived from the file on the day, by that
script, which exits 2 rather than print a number it could not measure.**
