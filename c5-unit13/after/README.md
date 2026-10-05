# c5-tiffinbox — Course 5 (Spring Boot)'s long-lived project

**Starts as an exact copy of `c4-tiffinbox`** at the end of Course 4 (tiffinbox-java 1b3b52f): the application Course 4
rewired — `TiffinBoxApp`, component scanning, `tiffinbox.properties`, no `Wiring.java`. Course 5's units change it
from here on; `c4-tiffinbox` stays frozen, so every Course 4 unit keeps pointing at what it measured. Unit 01 of
Course 5 is where Spring Boot arrives. Everything below the second rule is `c4-tiffinbox`'s README as it was.

## Course 5 · unit 01 — Boot arrives (2026-09-27)

Three files changed, and nothing else:
- `pom.xml` inherits `spring-boot-starter-parent:4.1.1` (`java.version 25` replaces `maven.compiler.release`; the
  Spring Framework BOM import goes — the parent manages Spring Framework 7.0.9 now);
- `tiffinbox-web/pom.xml` adds `spring-boot-starter`;
- `TiffinBoxServer.main`: `new AnnotationConfigApplicationContext(TiffinBoxApp.class)` + `registerShutdownHook()`
  become `SpringApplication.run(TiffinBoxApp.class, args)`.

The run command is unchanged — `java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18431` — and the seven
responses of `../c4-unit31/curlset.sh` hash to `115c36bac276128e245ca57df11c2891`, exactly as Course 4's did. What Boot
added (a banner, its own log format over the application's JUL records, four property sources, 11 more jars, and
`-parameters` in this build) is measured in `../c5-unit01/`.

## Course 5 · unit 03 — the Jackson family moves together (2026-09-27)

`pom.xml` no longer pins `jackson-databind` alone: under Boot's parent that left `jackson-core` and
`jackson-annotations` on Boot's 2.21.x beside databind 2.22.2. It sets `<jackson-2-bom.version>2.22.2</jackson-2-bom.version>`
instead — the property Boot's BOM reads — and all three are 2.22.x. The seven responses are unchanged; evidence in
`../c5-unit03/`.

## Course 5 · unit 04 — auto-configuration switched on (2026-09-27)

`TiffinBoxApp` gains `@EnableAutoConfiguration`. On this class path Boot's imports file lists 12 configuration classes;
9 are registered, 3 are not used; the definitions go 12 → 55; the seven responses are unchanged. Evidence in
`../c5-unit04/`.

## Course 5 · unit 06 — one configuration file, and a new run command (2026-09-29)

Three changes, and nothing else:
- `tiffinbox-web/src/main/resources/tiffinbox.properties` is renamed `application.properties`, byte for byte. Boot
  finds a file of that name by itself, while it prepares the environment.
- `TiffinBoxApp` loses `@PropertySource("classpath:tiffinbox.properties")` and its import. A `@PropertySource` file
  ranks **last** of the property sources (8 of 8 with the key set in five places), and it is read during refresh, after
  Boot has read keys such as `logging.level.tiffinbox` and `spring.main.banner-mode` (both measured: in that file they
  were silently ignored).
- `TiffinBoxServer.main` loses the three-line port bridge (`System.setProperty("tiffinbox.port", args[0])`). Boot's
  command-line source already outranked that system property.

**The run command changes, for the first time in Course 5:**

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
```

Flags may come in any order (`--debug --tiffinbox.port=18431` works), and the seven responses of
`../c4-unit31/curlset.sh` still hash to `115c36bac276128e245ca57df11c2891`. **The old command still starts, and says
nothing:** `java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18431` exits 0 and listens on **18425**, the file's
port — a bare number names no property, so nothing reads it. Every `… <port>` command further down this README was
written before this change: put `--tiffinbox.port=` in front of the number. Evidence in `../c5-unit06/`.

## Course 5 · unit 07 — application.yaml (2026-09-30)

Two files, and one comment:
- `tiffinbox-web/src/main/resources/application.properties` is **deleted**, and `application.yaml` replaces it. The
  same four keys with the same values, one level of nesting per dot (`tiffinbox:` written once, `cooks: 3` under it), and
  two things the old file did not have:
  - `tiffinbox.meal-types`, a list (`VEG`, `NON_VEG`, `VEGAN`). Boot keeps it as three keys, `tiffinbox.meal-types[0]`
    to `[2]`; `@Value("${tiffinbox.meal-types}")` cannot read it (the start fails: `Could not resolve placeholder`), and
    nothing in TiffinBox reads it yet.
  - a second document, after `---`, read only while the profile `rush` is active: `tiffinbox.cooks: 6`.
- The old file is deleted rather than kept beside the new one: in the same folder Boot asks `application.properties`
  first, so an edit to the YAML would be silently outvoted (measured: YAML `cooks: 4`, answer `3`).
- `TiffinBoxApp`'s Javadoc says so (comments only).

The run command is unchanged, and the seven responses of `../c4-unit31/curlset.sh` still hash to
`115c36bac276128e245ca57df11c2891`. The lunch rush is one flag more:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.profiles.active=rush
```

Boot logs `The following 1 profile is active: "rush"`, and `OrderQueue` runs six cooks (the responses do not change:
the cooks share the same orders). **Indentation is structure in YAML:** indent the rush document's `tiffinbox:` block two
spaces further, under `spring:`, and the start is clean, silent, and back to three cooks — the key has become
`spring.tiffinbox.cooks`. A tab, or one space too many under `tiffinbox:`, fails the start with a line and a column
(`in 'reader', line 4, column 1`), and the message does not name the file. Evidence in `../c5-unit07/`.

## Course 5 · unit 08 — one typed record for every reader (2026-09-30)

Six files changed, two new, and nothing else:
- `tiffinbox-core` gains `TiffinBoxProperties`, a record annotated `@ConfigurationProperties("tiffinbox")` —
  `String jdbcUrl, int cooks, int days, int port, List<MealType> mealTypes` — and `MealType`, an enum (`VEG`, `NON_VEG`,
  `VEGAN`). Boot's binder fills the record through its one constructor, from every key under `tiffinbox`, the list
  included (each item a `MealType`).
- `TiffinBoxApp` gains `@EnableConfigurationProperties(TiffinBoxProperties.class)`, which registers the record as a bean
  (its name: `tiffinbox-com.tiffinbox.TiffinBoxProperties`). Without it, TiffinBox does not start: no bean of that type.
- `Database`, `OrderQueue` and `TiffinBoxServer` take the record in their constructors, so TiffinBox's `@Value`
  placeholders go from 4 to 0. `TiffinBoxServer` reads the list at last, and logs it at startup:
  `meal types:     [VEG, NON_VEG, VEGAN]`.
- `tiffinbox-core/pom.xml` depends on `spring-boot` (the annotation is Boot's). Core still has no HTTP in it.
- The root `pom.xml` names Boot's configuration processor in `maven-compiler-plugin`'s `annotationProcessorPaths`, with no
  version (the parent manages it). The core jar now carries `META-INF/spring-configuration-metadata.json` — one group,
  five properties, each described by the record's `@param` line — the file an IDE reads to complete and describe the
  keys. Added as an ordinary dependency instead, the processor writes nothing on JDK 25 — 0 files, 0 warnings — unless
  processing is switched on (`<proc>full</proc>`).

The run command and `application.yaml` are unchanged, and the seven responses of `../c4-unit31/curlset.sh` still hash to
`115c36bac276128e245ca57df11c2891`. The file may spell a meal type loosely (`veg`, `non-veg`, `"Vegan "`): Boot's
conversion service binds each to its constant, with no converter written; a word it cannot match (`vegetarian`) stops the
start and lists the valid values.

**What it quietly costs:** a key missing from the file no longer stops the start. Delete `days` and TiffinBox starts,
cooks 0 orders and answers `/kitchen` with zeros — the `"defaultValue": 0` the metadata file gives every `int`. With
`@Value`, the same file stopped the start and named `tiffinbox.days`. Evidence in `../c5-unit08/`.

## Course 5 · unit 09 — the configuration refuses to start (2026-09-30)

Three files changed, and nothing else:
- `tiffinbox-web/pom.xml` adds `spring-boot-starter-validation`: Hibernate Validator 9.1.3.Final (the implementation), the
  Bean Validation API it implements, and `spring-boot-validation`, whose own imports file lists one class,
  `ValidationAutoConfiguration`. `lib/` goes from 26 jars to 33, and the jars in it that carry an
  `AutoConfiguration.imports` file from 1 to 2.
- `tiffinbox-core/pom.xml` adds `jakarta.validation-api` (no version: managed) — the constraint annotations, and nothing
  that checks them. Core still has no HTTP in it.
- `TiffinBoxProperties` gains `@Validated` and a rule on each component — `@NotBlank jdbcUrl`, `@NotNull @Min(1)` on
  `cooks`, `days` and `port`, `@NotEmpty mealTypes` — and its three numbers become `Integer`, so a key nobody wrote is
  `null` ("must not be null") rather than an `int`'s zero. The metadata file no longer gives them `"defaultValue": 0`.

A value that breaks a rule now stops the start, before the port opens, with one report (four bad values in one file gave
one report with four blocks). Each block names the property — by the record's Java name, `tiffinbox.jdbcUrl`, not
`jdbc-url` — its value, its origin, and the rule. `cooks: 0` in a file:

```
    Property: tiffinbox.cooks
    Value: "0"
    Origin: class path resource [application.yaml] - 4:10
    Reason: must be greater than or equal to 1
```

The report gets its turn because `Database`, `OrderQueue` and `TiffinBoxServer` all take the record: with `Database` back
on a `@Value` placeholder, a blank URL fails first, as `SQLException: No suitable driver found`, and no report is printed.
The run command and `application.yaml` are unchanged, and the seven responses of `../c4-unit31/curlset.sh` still hash to
`115c36bac276128e245ca57df11c2891`. Evidence in `../c5-unit09/`.

## Course 5 · unit 10 — profiles, a group, and a developer's own file (2026-09-30)

One file changed, two new, and nothing else:
- `tiffinbox-web/src/main/resources/application.yaml` gains two keys in its first document:
  - `spring.profiles.group.lunch: rush,audit` — a profile group. `--spring.profiles.active=lunch` switches on three
    profiles, and Boot says so: `The following 3 profiles are active: "lunch", "rush", "audit"`.
  - `spring.config.import: optional:file:./tiffinbox-local.yaml` — a developer's own settings, read from the folder
    TiffinBox starts in when that file is there. `optional:` makes a missing file no error; without it, a missing file
    stops the start, and Boot's report says `prefix it with 'optional:'`.
- `tiffinbox-web/src/main/resources/application-audit.yaml` (new) — the profile `audit`, a file of its own with one key,
  `logging.level.tiffinbox: debug`. Boot reads a profile's file while it prepares the environment, before refresh, so a
  logging key works there (5 route lines at DEBUG) — the key a `@PropertySource` file received too late.
- `.gitignore` (new, beside this README) — `tiffinbox-local.yaml`, so a developer's own file stays out of git.

Where `tiffinbox.cooks` comes from with `lunch` on and a `tiffinbox-local.yaml` present, highest first: the audit's file
(no cooks in it) · the rush document (6, the winner) · `tiffinbox-local.yaml` · `application.yaml`'s first document (3).
Naming the profiles the other way round (`audit,rush`) gives the same order: here a profile's own file ranks above both
documents of `application.yaml`. A misspelt profile (`lnch`) starts without a warning: Boot's profile line names it, and
nothing is composed for it. `spring.profiles.active` inside a profile file stops the start
(`InvalidConfigDataPropertyException`, naming the file, line and column) — once that profile is switched on; until then
the file is never read.

The run command is unchanged, and the seven responses of `../c4-unit31/curlset.sh` still hash to
`115c36bac276128e245ca57df11c2891` — plain, with `rush`, and with the group:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.profiles.active=lunch
```

Started as above, from this folder, TiffinBox imports `./tiffinbox-local.yaml` — a file beside this README, for example:

```yaml
tiffinbox:
  cooks: 4
```

Evidence in `../c5-unit10/`.

## Course 5 · unit 11 — a secret with a job (2026-09-30)

Until now anyone who could reach TiffinBox's port could stop it: POST /shutdown asked for nothing. Four files changed,
and nothing else:
- `TiffinBoxProperties` gains `@NotBlank String shutdownToken` — the key `tiffinbox.shutdown-token` — and its length rule,
  16 characters or more, as a yes-or-no method, `isShutdownTokenLongEnough()`. Not as `@Size` on the token: a failure
  report prints the value of the property that broke a rule, so `@Size` on the token prints the token, with the file it
  came from, in a log line at ERROR. With the method, a short token's report reads `Value: "false"`. The record also
  writes its own `toString()`: every component, and `[not shown]` in the token's place — a record's default prints every
  component, the token included, and a settings object is the first thing anyone logs.
- `TiffinBoxServer` answers POST /shutdown with `403 {"error":"forbidden"}` — and keeps running — unless the request's
  `X-Shutdown-Token` header holds the token (compared with `MessageDigest.isEqual`). Nothing logs the header or the token.
- `application.yaml`'s `spring.config.import` becomes a list: `optional:file:./tiffinbox-local.yaml`, then
  `optional:configtree:./secrets/` — a config tree: one file per key, in the folder TiffinBox starts in. Both rank below
  the profiles' sources, and the later import ranks higher: with a token in both, the tree's answers.
- `.gitignore` gains `secrets/`.

**The run command is unchanged, but TiffinBox no longer starts without a token.** With none anywhere the start stops,
before the port opens: `Property: tiffinbox.shutdownToken` · `Value: "null"` · `Reason: must not be blank`. Make one, in a
file beside this README that only you can read (never committed: `secrets/` is git-ignored), then start as before:

```bash
mkdir -p secrets/tiffinbox && (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > secrets/tiffinbox/shutdown-token)
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
```

Boot drops the file's trailing newline. **Stopping it now takes the header** — read from the file, so the token is never
on a command line (`ps` prints every argument; `ps eww`, a process's environment too):

```bash
{ printf 'X-Shutdown-Token: '; head -n 1 secrets/tiffinbox/shutdown-token; } | curl -s -w ' %{http_code}\n' -H @- -X POST http://127.0.0.1:18431/shutdown
```

It answers `{"stopping":true} 200`; without the header, `{"error":"forbidden"} 403`, and TiffinBox keeps running.
`../c4-unit31/curlset.sh` can no longer stop it: its seven responses now hash to `11bbc19ca107097dfd6477aa7fb0246b`. The
comparison set from here on is `../c5-unit11/curlset.sh PORT TOKENFILE` — Course 4's seven, the last with the header — and
they hash to `115c36bac276128e245ca57df11c2891`: plain, and with the logging, rush and lunch commands above. With `lunch`
on (the audit's logging at DEBUG) the token appears 0 times in the log. Evidence in `../c5-unit11/`.

## Course 5 · unit 13 — one executable jar (2026-10-05)

One file changed, and nothing else: `tiffinbox-web/pom.xml` declares `spring-boot-maven-plugin` — bare, with no version
and no execution: Boot's parent manages both, and declaring the plugin is what binds its `repackage` goal to `package` —
and loses the jar plugin's `<archive>` block (`Main-Class`, `addClasspath`, `classpathPrefix`) and the
`copy-dependencies` execution.

`tiffinbox-web/target/tiffinbox-web-1.0.0.jar` is now Boot's executable jar, a jar of jars: TiffinBox's three classes and
two YAML files under `BOOT-INF/classes/`, the 31 jars it needs under `BOOT-INF/lib/`, each kept whole, and Boot's launcher
at the top — `Main-Class: org.springframework.boot.loader.launch.JarLauncher`, `Start-Class:
com.tiffinbox.web.TiffinBoxServer`. The build no longer writes `target/lib/`, and the jar runs alone. **The run command is
unchanged:**

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
```

(it still needs its token — unit 11's section above). **A class path from the jar** — for a tool or a test harness that
names its own main class — comes from Boot's own tool, which unpacks the jar into a thin jar and a `lib/` folder:

```bash
java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
```

The extracted jar's `Main-Class` is TiffinBox's own and its `Class-Path` names the 31 jars in `lib/`, so `java -jar
tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431` runs it too, without Boot's launcher. The
`lib/*` in the second command is the JVM's own class-path wildcard: every jar in that folder. Each of the three serves the
seven responses `115c36bac276128e245ca57df11c2891` (`../c5-unit11/curlset.sh PORT TOKENFILE`). **Don't put a jar built with
the old `<archive>` block beside an older `lib/`:** its `Class-Path` header survives `repackage`, and the application class
loader, asked first, loads the classes that header names from that folder — measured with an older release's `lib/`:
`NoSuchMethodError: 'java.lang.String com.tiffinbox.TiffinBoxProperties.shutdownToken()'`. The jar as built here has no
`Class-Path` and serves from the same folder. Evidence in `../c5-unit13/`.

---

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

> **Stale since Course 5, unit 13.** Web's build no longer runs `copy-dependencies`, its jar's manifest has no
> `Class-Path`, and there is no `tiffinbox-web/target/lib/`: the jar is Boot's executable jar (unit 13's section at the
> top). The manifest and the `lib/` listing below are Course 3's, kept as they were written.

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

> **Stale under Boot (Course 5, unit 01 measured it).** Since Spring Boot arrived, Boot's logging system owns
> `java.util.logging`: the `-Djava.util.logging.config.file=…` flag below no longer sets any level (the debug file's
> five `route` lines go 5 → 0, silently; see `../c5-unit01/` → `.r-logging.out`). Boot's way is a property:
> `java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.tiffinbox=debug`
> (the port as a flag since Course 5 unit 06, which measured this command: 5 route lines). The rest of this section is
> Course 3's text, kept as it was written — including "pass another as the first argument", which since unit 06 is
> silently ignored (the server listens on 18425).

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

> **Stale since Course 5, unit 11:** POST /shutdown now answers 403 unless it carries the token in an
> `X-Shutdown-Token` header — see that unit's section at the top of this README for the command. The line below is
> Course 3's, kept as it was written.

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

## Course 4 — rewired (Spring Framework Core, capstone)

`Wiring.java` is gone, and so is the second hand-wiring in `TiffinBoxServer.main`. The five objects carry
`@Component` (and two `@Value` parameters, one `@PostConstruct`); `tiffinbox-web` adds `TiffinBoxApp`
(`@Configuration @ComponentScan @PropertySource`) and `tiffinbox.properties` (the JDBC URL, cooks, days, port).
The core module now depends on `spring-context` and `jakarta.annotation-api`. The run command is unchanged:

```bash
mvn -q -DskipTests package
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18431
```

The project as it was before the rewire is frozen in `../c4-unit31/before/`; the evidence that the two serve
byte-identical responses, and everything else the capstone claims, is `../c4-unit31/receipts.sh`.
