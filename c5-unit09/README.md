# c5-unit09 — Validating Configuration

Course 5 · Spring Boot · Section 2 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**, 2026-09-30.
The previous unit bound TiffinBox's settings into one record, `TiffinBoxProperties`, and measured the cost: a key missing
from the file became a zero, and TiffinBox started anyway. This unit makes the configuration refuse to start instead — the
validation starter, constraints and `@Validated` on the record, `Integer` for its numbers — and measures when that refusal
actually gets its turn: what TiffinBox did before (a zero that starts, a minus one that crashes without naming its key),
Boot's report, what the starter brings (seven jars and a second imports file), what happens without it, the order trap
that decides whether the report is printed at all, `int` against `Integer` for a key nobody wrote, and method validation
— Course 4's "you get it free" — asked of Boot.

The change lands in `../c5-tiffinbox`; `after/` is this unit's frozen copy of it. "Before" is `../c5-unit08/after/` (the
anchor as the last unit left it), **copied** to `.harness/before/` and built there, so this unit never writes into another
unit's folder. Clean builds, offline first; every number the video speaks is asserted; three runs per capture.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 10 captures, 3 runs each; every spoken number asserted; a published-md5 mismatch stops it
```

(`receipts.sh` carries the same two `export` lines at its top; a bare `java` on this Mac is 23.0.1.) `receipts.sh`
**dies** when a capture's md5 differs from `receipts.md5` — it prints the `DIFFERS` line first, so you can see which one
moved (tested: with `change`'s published hash altered by one character, the run printed `change … DIFFERS from the
published 01e3b18d…`, stopped with exit 1 and released its lock; `receipts.md5` was restored). A whole run takes about
3 min 20 s on the author's Mac (seven tree builds, and `order`'s six unsorted runs).

**The repository.** Every build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` in the commands): a copy of
`../c5-unit08/.m2-demo`, plus the artifacts the validation starter needs, copied from the Section 2 probe's repository
(`/private/tmp/claude-501/c5s2/m2`) — nothing was resolved by this unit, and after a full run no file in `.m2-demo` is newer
than the run's start:
- recorded as from `central` (the probe fetched them from Maven Central on 2026-09-29): `spring-boot-starter-validation`
  4.1.1, `spring-boot-validation` 4.1.1, `hibernate-validator` 9.1.3.Final, `tomcat-embed-el` 11.0.24;
- copied from `~/.m2` by the probe, their `_remote.repositories` markers **dropped** (they named the probe's `userm2`
  repository, and `mvn -o` refuses an artifact recorded from a repository it is not using — the brief's warning,
  confirmed): `jakarta.validation-api` 3.1.1, `jboss-logging` 3.6.3.Final, `classmate` 1.7.3, and the parents
  `jboss-parent` 52 and `oss-parent` 74.

The seven tree builds fall back to Maven Central only if the offline build fails, and each prints `built <tree> · offline:
yes` (or `no - …`) on the terminal, so a run that went online is never silent; the `starter` C build is offline only.
Offline re-run of the frozen tree: `mvn -o -B -f after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" verify` → BUILD SUCCESS.

## The anchor change

Three files changed (README aside), nothing new, nothing else — `change`, below, shows every changed code line:
- `tiffinbox-web/pom.xml` adds `spring-boot-starter-validation` (no version: managed). Web's `lib/` goes from 26 jars to
  33 — `hibernate-validator` 9.1.3.Final, `jakarta.validation-api` 3.1.1, `classmate`, `jboss-logging`, `tomcat-embed-el`,
  `spring-boot-validation` and the starter itself, whose jar holds no class — and the jars in it that carry an
  `AutoConfiguration.imports` file go from 1 to 2 (`imports`).
- `tiffinbox-core/pom.xml` adds `jakarta.validation-api` (no version): the constraint annotations the record carries, and
  nothing that checks them. Core still has no HTTP in it.
- `TiffinBoxProperties` gains `@Validated`, and a rule on each component: `@NotBlank jdbcUrl`, `@NotNull @Min(1)` on
  `cooks`, `days` and `port`, `@NotEmpty mealTypes`. Its three numbers become `Integer` (brief ⚑6): a key nobody wrote is
  then `null`, which `@NotNull` reports as missing, where an `int` reported a zero nobody wrote (`boxed`). The metadata
  file the configuration processor writes no longer gives those three `"defaultValue": 0` (3 → 0, `change`).

The readers are untouched: `Database`, `OrderQueue` and `TiffinBoxServer` already take the record (the previous unit), and
unbox its `Integer`s into their own `int` fields. The startup log still prints the meal-types list alone, never the whole
record. `application.yaml` and the run command are unchanged, and the seven responses of `../c4-unit31/curlset.sh` still
hash to `115c36bac276128e245ca57df11c2891` (`serve`, `starter` A).

## The harness — TiffinBox's own `main`, read from the inside

`harness/com/tiffinbox/harness/` holds plain classes. None carries a stereotype annotation, so TiffinBox's
`@ComponentScan("com.tiffinbox")` (which registers annotated components) never picks one up — `Hiring`'s `@Validated` is
not a stereotype. None copies TiffinBox's start-up: each calls the tree's own `TiffinBoxServer.main(args)` inside Boot's
`SpringApplication.withHook(…)`, whose run listener is handed the context `main` starts (`Run.java`). If `main` throws, the
harness prints the exception's type and rethrows it, so the exit code is the one TiffinBox's own run gives. The harness is
compiled against `after/`'s jars, and it also runs on the previous tree and the variants, so it never names the record's
class in its code (it looks the record up by name). `receipts.sh` compiles it **twice** from the same sources: into
`.harness/classes` with `javac -parameters` (as Boot's parent compiles TiffinBox), and into `.harness/noparams` without it.

- `Serve <TiffinBox's arguments>` — prints which `application.yaml` the class path gives (first, so a failed start shows
  it too), runs TiffinBox's `main`, prints the record, and returns **without** closing the context: TiffinBox keeps serving,
  exactly as its own `main` leaves it, until `POST /shutdown`.
- `Start <TiffinBox's arguments>` — runs `main`, prints the record, and closes the context (the exercise's harness).
- `Hire <TiffinBox's arguments>` — registers one extra bean by code, `Hiring` (`@Validated`; `hire(@Min(1) int cooks)`,
  `take(@Valid Slip slip)`, `takeUnchecked(Slip slip)`, and `Slip(@Min(1) int meals)`), then prints: the parameter names
  as compiled — TiffinBox's `OrderQueue(TiffinBoxProperties)` (built by Maven) and the harness's `Hiring.hire(int)` (built
  by `javac`); the beans of type `MethodValidationPostProcessor` (Spring's class, in `spring-context`) with the
  configuration class and method that declared each; the class of the `Hiring` bean the context hands out; and what three
  calls with a zero do. It closes the context.

**`$BEFORE`, `$AFTER`, `$ATVALUE`, `$INTRECORD`, `$NOSTARTER`, `$NOVALID`, `$NOSTARTER_NOVALID`** are the harness's
classes plus that tree's jars (`tiffinbox-web-1.0.0.jar` and `lib/*.jar`): the previous tree, this unit's `after/`, and five
copies of `after/` with one demo file (two, for the last) laid over each. **`$NOPARAMS`** is the harness compiled without `-parameters`, plus `after/`'s jars.
`receipts.sh` writes each to `.harness/*.classpath`. Every command is printed exactly as it runs: `receipts.sh` passes it
to `eval`, so those variables — and `$M2`, this unit's `.m2-demo` — expand when it runs. The jar runs (`java -jar
tiffinbox-web-1.0.0.jar …`) start in that tree's `tiffinbox-web/target` (`serve`: `after/`; `unvalidated`:
`.harness/before/`); every other command runs from this folder.

**The demo files.** A folder put in front of a tree on a class path holds one `application.yaml` that the class path then
gives **instead of** the copy packaged in TiffinBox's jar (the harness's `the class path gives:` line names the file it
got). Each is the anchor's `application.yaml` with declared changes, and `files` diffs every one: `cooks0/` (`cooks: 0`,
line 4) · `nodays/` (the `days` line deleted) · `fourbad/` (`jdbc-url: ""`, `cooks: 0`, no `days` line, `meal-types: []`).
The variants laid over a copy of `after/`: `atvalue/Database.java` (the constructor back on
`@Value("${tiffinbox.jdbc-url}")` — the `Database` of the tree before the record, byte for byte) · `intrecord/TiffinBoxProperties.java`
(the record's header with `@Min(1) int` for the three numbers, no `@NotNull`) · `novalidated/TiffinBoxProperties.java`
(`after/`'s record minus its one line `@Validated` — every constraint kept) · `nostarter/tiffinbox-web/pom.xml` (the
previous tree's web POM, byte for byte: no starter) · `noapi/tiffinbox-core/pom.xml` (the previous tree's core POM, byte for
byte: no API; used with `nostarter/`'s, in `starter` C). `nostarter/` and `novalidated/` together make `starter` D.

**Ports** (Section 2 brief ⚑11: 18690-18699): serve 18690 · unvalidated 18691 · break 18692 (A never binds) · starter 18693
(B never binds) · order 18694 (never binds) · boxed 18695 (never binds) · method 18696 · the exercise 18699. Every command
names its port; `receipts.sh` first checks that nothing listens on 18425 or on any of its ports.

## Masks, filters and hygiene — every one, declared

1. Boot's own log lines (each starts with an ISO timestamp and carries a pid) are dropped from a harness report and
   counted; so are the lines printed before the report (the banner and its blank lines): the last line of each report says
   how many of each (`… elided: N log line(s) of Boot's, and M line(s) printed before the report …`).
2. A kept log message loses its prefix (time, level, pid, thread, logger) through `sub()` — `orders cooked:`, the list's
   line, the profile line.
3. A failed start shows its exit code, its WARN, ERROR and `listening` line counts, its `Property:`, `SQLException` and
   stack-frame lines counted, the file the class path gave, then Boot's own failure report (`APPLICATION FAILED TO START`
   to the end of its Action) **without its blank lines and its rows of asterisks** — or, when Boot printed no report, the
   run's **last two** `Caused by:` lines, a `[jar:file:…]` or `[file:…]` location in them cut to `[…]` by `gsub()` — then
   the exception the harness names (harness runs only), then a counted line: `… N more line(s) of this run's output not
   shown …`.
4. **A report with two or more `Property:` blocks is printed with its blocks sorted by the `Property:` line** (brief ⚑7:
   the probe saw Boot print the same four violations in three different orders in six runs), and a line says so: `(the 4
   Property: blocks below are sorted by name - README.md, masks)`. `order` measures the drift once: A's command six more
   times, the `Property:` lines read in the order Boot printed them — `4 blocks every run: yes · more than one order among
   the 6: yes` (only that is printed: which orders come up differs from run to run). The deck's chip says so.
5. `SpringCGLIB$$<digits>` in a harness line becomes `SpringCGLIB$$<n>` (`gsub()`); a compiler error's absolute path, up to
   `tiffinbox-core/`, becomes `…/` (`gsub()`).
6. The Maven builds in `starter` C are reduced to counts: the exit code, the `BUILD` line, the `[WARNING]` and `[ERROR]`
   lines, the compiler's error lines and the files they name, and the first one.
7. `change` shows every changed **code** line: each changed file's comments (Java `/* */` blocks and lines starting `*` or
   `//`; XML `<!-- -->`) and blank lines are dropped from both versions before git diffs them (`-U0`), and the header line
   counts the changed lines that were dropped. The record is then printed whole.
8. Hygiene: `receipts.sh` unsets every `TIFFINBOX_*` and `SPRING_*` variable, `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`,
   `MAVEN_OPTS` and `MAVEN_ARGS` before it runs anything — a variable of yours would otherwise become a property source,
   or a flag. It also refuses to run twice at once in this folder (`.r-lock`): two runs share `.harness/` and the ports.
9. `change`'s reader line names each class with its module (`tiffinbox-core/Database.java`), so "two of them live in core"
   is read off the capture.

**Interrupted.** `receipts.sh`'s exit trap stops the JVM it started in the background, if one still runs, and drops the
lock — on a failed check and on Ctrl-C alike (a background job of a non-interactive shell ignores the terminal's Ctrl-C, so
without the kill it would keep listening). Tested 2026-09-30, the driver in the foreground, `SIGINT` sent to the script's
process group the moment `break` B's JVM (`cooks0:$NOVALID`, port 18692) started: `receipts.sh` exited 130, and 5 s later
no JVM for 18692 was running, nothing listened on 18692, and `.r-lock` was gone. The same test against the script as first
shipped (a trap that only removed the lock) left that JVM listening on 18692; it was stopped with `POST /shutdown`. If a
run is ever interrupted some other way, the port check names the way out: `curl -X POST http://127.0.0.1:<port>/shutdown`.

## 1 · The change — three files, the rules and the numbers

`.r-change.out` `907f0f32d4069adf48e4cab224fdd81b`

```
files, README aside: the previous tree 16 · after/ 16 · in both 16: identical 13, changed 3
  only before: (none)
  only after:  (none)
tiffinbox-core/pom.xml, every changed line but comments and blanks (3 of those not shown):
+    <dependency>
+      <groupId>jakarta.validation</groupId>
+      <artifactId>jakarta.validation-api</artifactId>
+    </dependency>
TiffinBoxProperties.java, every changed line but comments and blanks (5 of those not shown):
+import jakarta.validation.constraints.Min;
+import jakarta.validation.constraints.NotBlank;
+import jakarta.validation.constraints.NotEmpty;
+import jakarta.validation.constraints.NotNull;
+import org.springframework.validation.annotation.Validated;
+@Validated
-public record TiffinBoxProperties(String jdbcUrl, int cooks, int days, int port, List<MealType> mealTypes) {
+public record TiffinBoxProperties(@NotBlank String jdbcUrl, @NotNull @Min(1) Integer cooks, @NotNull @Min(1) Integer days,
+                                  @NotNull @Min(1) Integer port, @NotEmpty List<MealType> mealTypes) {
tiffinbox-web/pom.xml, every changed line but comments and blanks (3 of those not shown):
+    <dependency>
+      <groupId>org.springframework.boot</groupId>
+      <artifactId>spring-boot-starter-validation</artifactId>
+    </dependency>
the record, whole, after/: tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java
  1 | package com.tiffinbox;
  2 | 
  3 | import jakarta.validation.constraints.Min;
  4 | import jakarta.validation.constraints.NotBlank;
  5 | import jakarta.validation.constraints.NotEmpty;
  6 | import jakarta.validation.constraints.NotNull;
  7 | import org.springframework.boot.context.properties.ConfigurationProperties;
  8 | import org.springframework.validation.annotation.Validated;
  9 | 
 10 | import java.util.List;
 11 | 
 12 | /**
 13 |  * TiffinBox's settings: every key under {@code tiffinbox} in application.yaml, bound once, into one typed object.
 14 |  *
 15 |  * <p>Boot's binder fills it through its only constructor, the record's own. The {@code @param} lines below are not
 16 |  * decoration: the configuration processor copies each one into the metadata file an IDE reads, as the description of
 17 |  * that key.
 18 |  *
 19 |  * <p>{@code @Validated} asks the binder to check the constraints below. A value that breaks one stops the start, before
 20 |  * TiffinBox's port opens, with a report: the property, its value, where it came from, and the rule it broke. The three
 21 |  * numbers are {@code Integer}, not {@code int}: a key nobody wrote is then {@code null}, which {@code @NotNull} reports
 22 |  * as missing - an {@code int} would be a zero that nobody wrote.
 23 |  *
 24 |  * @param jdbcUrl   the address of TiffinBox's database, an in-memory H2 database
 25 |  * @param cooks     how many cooks take orders off the kitchen rail
 26 |  * @param days      how many days of orders the kitchen cooks at startup
 27 |  * @param port      the port TiffinBox listens on, on 127.0.0.1
 28 |  * @param mealTypes the meal types TiffinBox serves
 29 |  */
 30 | @Validated
 31 | @ConfigurationProperties("tiffinbox")
 32 | public record TiffinBoxProperties(@NotBlank String jdbcUrl, @NotNull @Min(1) Integer cooks, @NotNull @Min(1) Integer days,
 33 |                                   @NotNull @Min(1) Integer port, @NotEmpty List<MealType> mealTypes) {
 34 | }
TiffinBox's @Value placeholders: the previous tree 0 · after/ 0
classes whose constructor takes the record (TiffinBoxProperties settings): the previous tree 3: tiffinbox-core/Database.java tiffinbox-core/OrderQueue.java tiffinbox-web/TiffinBoxServer.java · after/ 3: tiffinbox-core/Database.java tiffinbox-core/OrderQueue.java tiffinbox-web/TiffinBoxServer.java
"defaultValue": 0 entries in the core jar's metadata file: the previous tree 3 · after/ 0
```

Three files changed, none new, none gone. Core's POM gains the API, the record gains five imports, `@Validated`, and a new
header — a rule on each component, `Integer` for the numbers — and web's POM gains the starter (the capture lists them in
that order). No `@Value` placeholder is left in either tree, the same three classes take the record in both — two of them
in `tiffinbox-core`, so the record lives there too — and the metadata file's `"defaultValue": 0` entries go from 3 to 0: an
`Integer` component has no default.

## 2 · The starter's jars, and a second imports file

`.r-imports.out` `d6a0b6250a44955254fe54ac9a053e2f`

```
jars in tiffinbox-web/target/lib: the previous tree 26 · after/ 33
  new in after/: classmate-1.7.3.jar hibernate-validator-9.1.3.Final.jar jakarta.validation-api-3.1.1.jar jboss-logging-3.6.3.Final.jar spring-boot-starter-validation-4.1.1.jar spring-boot-validation-4.1.1.jar tomcat-embed-el-11.0.24.jar
  gone from after/: (none)
jars in lib/ that carry META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports:
  the previous tree 1: spring-boot-autoconfigure-4.1.1.jar
  after/ 2: spring-boot-autoconfigure-4.1.1.jar spring-boot-validation-4.1.1.jar
$ unzip -p after/tiffinbox-web/target/lib/spring-boot-validation-4.1.1.jar META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports
  1 | org.springframework.boot.validation.autoconfigure.ValidationAutoConfiguration
the starter's own jar, spring-boot-starter-validation-4.1.1.jar: .class entries 0
```

Seven jars in, none out. Two jars in `lib/` now carry `META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports`
— Boot's list of auto-configurations: `spring-boot-autoconfigure`'s, and `spring-boot-validation`'s, which names one class,
`ValidationAutoConfiguration` (the class that declares the method-validation post-processor, section 8). The starter's own
jar holds no class: it is a POM with dependencies, packaged.

## 3 · Without rules: a zero that starts, and minus one

`.r-unvalidated.out` `d0a58a01dd7d0c8702235ba593ff8a4c`

```
the previous tree's jar (no validation), zero cooks from the command line:
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18691 --tiffinbox.cooks=0
  listens on: 127.0.0.1:18691 · WARN lines 0 · ERROR lines 0
  TiffinBox's log: orders cooked:  0
  GET   /kitchen    -> 200 application/json  {"ordersCooked":0,"ordersValue":0}
  exit 0 · the seven responses: 7 lines · md5 48c20805358e969bfc65e9197ce3b541
the same jar, minus one cook:
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18691 --tiffinbox.cooks=-1
  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0
  Property: lines 0 · SQLException lines 0 · stack-frame lines 45
  Caused by: org.springframework.beans.BeanInstantiationException: Failed to instantiate [com.tiffinbox.OrderQueue]: Constructor threw exception
  Caused by: java.lang.IllegalArgumentException: count < 0
  … 69 more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …
  lines that name the key (cooks, in any case): 0 · NullPointerException lines: 0 · output lines in all: 71
```

The previous tree's jar, as its README runs it, with a value set on the command line. **Zero cooks starts**: exit 0 after
`POST /shutdown`, 0 orders cooked, `/kitchen` answers 200 with zeros, and the seven responses hash to `48c20805…` — the
previous unit's missing `days` gave the same hash. **Minus one does not**: exit 1, 71 lines, 45 of them stack frames, and
the last two causes say where — `OrderQueue`'s constructor threw `IllegalArgumentException: count < 0` (the kitchen's
`CountDownLatch` refuses a negative count). No line of the 71 contains `cooks`, in any case: the key is never named. And no
line contains `NullPointerException`: the roadmap's "NPE" is not what happens **in this run** (brief finding 10) — the
previous tree's numbers are `int`. This unit's own switch to `Integer` brings one back whenever validation is off (`boxed`
C, section 7).

## 4 · The break — `cooks: 0` in a file

`.r-break.out` `dc3946da420bd506b91db801b0e61ffc`

```
A   this tree, cooks0/ in front of its jar's file
$ java -cp "cooks0:$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18692
  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0
  Property: lines 1 · SQLException lines 0 · stack-frame lines 0
  the class path gives: application.yaml <- cooks0/application.yaml · application.properties <- none
  APPLICATION FAILED TO START
  Description:
  Binding to target com.tiffinbox.TiffinBoxProperties failed:
      Property: tiffinbox.cooks
      Value: "0"
      Origin: class path resource [application.yaml] - 4:10
      Reason: must be greater than or equal to 1
  Action:
  Update your application's configuration
  the exception TiffinBox's main threw: org.springframework.beans.factory.UnsatisfiedDependencyException
  … 27 more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …
B   novalidated/: this tree minus @Validated - every constraint kept - the same cooks0/ file
$ java -cp "cooks0:$NOVALID" com.tiffinbox.harness.Serve --tiffinbox.port=18692
  listens on: 127.0.0.1:18692 · WARN lines 0 · ERROR lines 0
  the class path gives: application.yaml <- cooks0/application.yaml · application.properties <- none
  the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=0, days=30, port=18692, mealTypes=[VEG, NON_VEG, VEGAN]]
  TiffinBox's log: orders cooked:  0
  GET   /kitchen    -> 200 application/json  {"ordersCooked":0,"ordersValue":0}
  exit 0 · the seven responses: 7 lines · md5 48c20805358e969bfc65e9197ce3b541
A′  A, re-run
$ java -cp "cooks0:$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18692
  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0
  Property: lines 1 · SQLException lines 0 · stack-frame lines 0
  the class path gives: application.yaml <- cooks0/application.yaml · application.properties <- none
  APPLICATION FAILED TO START
  Description:
  Binding to target com.tiffinbox.TiffinBoxProperties failed:
      Property: tiffinbox.cooks
      Value: "0"
      Origin: class path resource [application.yaml] - 4:10
      Reason: must be greater than or equal to 1
  Action:
  Update your application's configuration
  the exception TiffinBox's main threw: org.springframework.beans.factory.UnsatisfiedDependencyException
  … 27 more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …
C   the previous tree (no starter, no constraints, no @Validated), the same cooks0/ file
$ java -cp "cooks0:$BEFORE" com.tiffinbox.harness.Serve --tiffinbox.port=18692
  listens on: 127.0.0.1:18692 · WARN lines 0 · ERROR lines 0
  the class path gives: application.yaml <- cooks0/application.yaml · application.properties <- none
  the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=0, days=30, port=18692, mealTypes=[VEG, NON_VEG, VEGAN]]
  TiffinBox's log: orders cooked:  0
  GET   /kitchen    -> 200 application/json  {"ordersCooked":0,"ordersValue":0}
  exit 0 · the seven responses: 7 lines · md5 48c20805358e969bfc65e9197ce3b541
```

**A** — this tree, `cooks0/` in front: exit 1 before the port opens (0 `listening` lines), and Boot's report: the property,
the value as written, its origin (`class path resource [application.yaml] - 4:10`: line 4, column 10 of `cooks0/`'s file —
`files` shows line 4 is the changed line), and the constraint's message. **B** — `novalidated/`: this tree minus the one
line `@Validated`, every constraint kept, the same file: it listens, 0 orders cooked, `48c20805…` (its exit 0 is read after
`POST /shutdown`) — the rules alone check nothing; `@Validated` is what asks the binder to. **A′** — A re-run, line for
line. **C** — the previous tree (no starter, no constraints, no `@Validated`), the same file: the same as B.

## 5 · Without the starter, then without the API

`.r-starter.out` `2260597e847feaa9f3458fc0b1717358`

```
A   this tree, its own file
$ java -cp "$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18693
  listens on: 127.0.0.1:18693 · WARN lines 0 · ERROR lines 0
  the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application.properties <- none
  the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=3, days=30, port=18693, mealTypes=[VEG, NON_VEG, VEGAN]]
  TiffinBox's log: orders cooked:  120
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
B   the starter taken out: nostarter/tiffinbox-web/pom.xml (the API jar still comes from tiffinbox-core), its own file
  lib/: 27 jars · jakarta.validation-api among them: 1 · hibernate-validator among them: 0
$ java -cp "$NOSTARTER" com.tiffinbox.harness.Serve --tiffinbox.port=18693
  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0
  Property: lines 0 · SQLException lines 0 · stack-frame lines 0
  the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application.properties <- none
  APPLICATION FAILED TO START
  Description:
  The Bean Validation API is on the classpath but no implementation could be found
  Action:
  Add an implementation, such as Hibernate Validator, to the classpath
  the exception TiffinBox's main threw: org.springframework.beans.factory.UnsatisfiedDependencyException
  … 25 more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …
A′  A, re-run
$ java -cp "$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18693
  listens on: 127.0.0.1:18693 · WARN lines 0 · ERROR lines 0
  the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application.properties <- none
  the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=3, days=30, port=18693, mealTypes=[VEG, NON_VEG, VEGAN]]
  TiffinBox's log: orders cooked:  120
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
C   the API taken out too: this tree with nostarter/tiffinbox-web/pom.xml and noapi/tiffinbox-core/pom.xml, built
$ cd .harness/noapi && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  exit 1 · BUILD FAILURE · WARNING lines 0 · ERROR lines 52
  the compiler's error lines ([ERROR] …java:[line,column] …): 24 · in: TiffinBoxProperties.java
  the first: [ERROR] …/tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java:[3,38] package jakarta.validation.constraints does not exist
D   the starter taken out AND @Validated: nostarter/tiffinbox-web/pom.xml and novalidated/, its own file
  lib/: 27 jars · jakarta.validation-api among them: 1 · hibernate-validator among them: 0
$ java -cp "$NOSTARTER_NOVALID" com.tiffinbox.harness.Serve --tiffinbox.port=18693
  listens on: 127.0.0.1:18693 · WARN lines 0 · ERROR lines 0
  the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application.properties <- none
  the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=3, days=30, port=18693, mealTypes=[VEG, NON_VEG, VEGAN]]
  TiffinBox's log: orders cooked:  120
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

**A** — this tree, its own file: it serves, `115c36ba…`. **B** — the starter taken out (the previous tree's web POM, byte
for byte), so `lib/` holds 27 jars: the API (which core brings), no implementation. With the same good file, TiffinBox
does not start: `The Bean Validation API is on the classpath but no implementation could be found`. **A′** — A re-run.
**C** — the API taken out too (the previous tree's core POM, byte for byte): the build fails, and every compiler error
(24 lines) is in `TiffinBoxProperties.java`, starting with `package jakarta.validation.constraints does not exist`.
**D** — the starter taken out **and** `@Validated` (`nostarter/` and `novalidated/`): the same 27 jars, API and no
implementation, and TiffinBox serves — 120 orders cooked, `115c36ba…`. So B's failure is `@Validated` asking for a
validator nobody provides, not the API on the class path.

## 6 · The order trap — when the report gets its turn

`.r-order.out` `be417414cec2854119ed409d40473bbc`

```
A   this tree, fourbad/ in front of its jar's file
$ java -cp "fourbad:$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18694
  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0
  Property: lines 4 · SQLException lines 0 · stack-frame lines 0
  the class path gives: application.yaml <- fourbad/application.yaml · application.properties <- none
  APPLICATION FAILED TO START
  Description:
  Binding to target com.tiffinbox.TiffinBoxProperties failed:
  (the 4 Property: blocks below are sorted by name - README.md, masks)
      Property: tiffinbox.cooks
      Value: "0"
      Origin: class path resource [application.yaml] - 4:10
      Reason: must be greater than or equal to 1
      Property: tiffinbox.days
      Value: "null"
      Reason: must not be null
      Property: tiffinbox.jdbcUrl
      Value: ""
      Origin: class path resource [application.yaml] - 3:13
      Reason: must not be blank
      Property: tiffinbox.mealTypes
      Value: "[]"
      Origin: class path resource [application.yaml] - 7:15
      Reason: must not be empty
  Action:
  Update your application's configuration
  the exception TiffinBox's main threw: org.springframework.beans.factory.UnsatisfiedDependencyException
  … 30 more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …
B   atvalue/: Database back on a @Value placeholder, the same fourbad/ file
$ java -cp "fourbad:$ATVALUE" com.tiffinbox.harness.Serve --tiffinbox.port=18694
  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0
  Property: lines 0 · SQLException lines 1 · stack-frame lines 67
  the class path gives: application.yaml <- fourbad/application.yaml · application.properties <- none
  Caused by: org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'database': Invocation of init method failed
  Caused by: java.sql.SQLException: No suitable driver found for 
  the exception TiffinBox's main threw: org.springframework.beans.factory.UnsatisfiedDependencyException
  … 91 more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …
A′  A, re-run
$ java -cp "fourbad:$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18694
  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0
  Property: lines 4 · SQLException lines 0 · stack-frame lines 0
  the class path gives: application.yaml <- fourbad/application.yaml · application.properties <- none
  APPLICATION FAILED TO START
  Description:
  Binding to target com.tiffinbox.TiffinBoxProperties failed:
  (the 4 Property: blocks below are sorted by name - README.md, masks)
      Property: tiffinbox.cooks
      Value: "0"
      Origin: class path resource [application.yaml] - 4:10
      Reason: must be greater than or equal to 1
      Property: tiffinbox.days
      Value: "null"
      Reason: must not be null
      Property: tiffinbox.jdbcUrl
      Value: ""
      Origin: class path resource [application.yaml] - 3:13
      Reason: must not be blank
      Property: tiffinbox.mealTypes
      Value: "[]"
      Origin: class path resource [application.yaml] - 7:15
      Reason: must not be empty
  Action:
  Update your application's configuration
  the exception TiffinBox's main threw: org.springframework.beans.factory.UnsatisfiedDependencyException
  … 30 more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …
Boot's own order, unsorted: A's command 6 more times, its Property: lines as Boot printed them - 4 blocks every run: yes · more than one order among the 6: yes
```

**A** — four bad values in one file (`fourbad/`: a blank URL, zero cooks, no `days` line, an empty list): exit 1, **one**
report with four `Property:` blocks (sorted: mask 4), and 0 `SQLException` lines. The names are the record's Java
components — `tiffinbox.jdbcUrl`, `tiffinbox.mealTypes` — not the keys as the file writes them (`jdbc-url`, `meal-types`);
`days` has no `Origin:` line, because no source holds it. **B** — `atvalue/`: `Database` back on a `@Value` placeholder,
nothing else changed. The same file gives exit 1 with **no report** (0 `Property:` lines): the last two causes are
`Error creating bean with name 'database': Invocation of init method failed` and `SQLException: No suitable driver found
for ` (the empty URL). The database's `@PostConstruct` ran, and failed, before anything bound the record. **A′** — A re-run.
Then A's command six more times, unsorted: four blocks each time, and more than one order among the six (mask 4). With all
three readers taking the record, it is bound — and checked — before any of them uses a value; two of the three live in
`tiffinbox-core`, so the record lives there too (brief ⚑4).

## 7 · A key nobody wrote: `int` against `Integer`

`.r-boxed.out` `713660299c95ea38ed8e5f829fb3a87a`

```
A   this tree (Integer, @NotNull @Min(1)), nodays/ in front of its jar's file
$ java -cp "nodays:$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18695
  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0
  Property: lines 1 · SQLException lines 0 · stack-frame lines 0
  the class path gives: application.yaml <- nodays/application.yaml · application.properties <- none
  APPLICATION FAILED TO START
  Description:
  Binding to target com.tiffinbox.TiffinBoxProperties failed:
      Property: tiffinbox.days
      Value: "null"
      Reason: must not be null
  Action:
  Update your application's configuration
  the exception TiffinBox's main threw: org.springframework.beans.factory.UnsatisfiedDependencyException
  … 27 more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …
B   intrecord/: the record with int (@Min(1), no @NotNull), the same nodays/ file
$ java -cp "nodays:$INTRECORD" com.tiffinbox.harness.Serve --tiffinbox.port=18695
  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0
  Property: lines 1 · SQLException lines 0 · stack-frame lines 0
  the class path gives: application.yaml <- nodays/application.yaml · application.properties <- none
  APPLICATION FAILED TO START
  Description:
  Binding to target com.tiffinbox.TiffinBoxProperties failed:
      Property: tiffinbox.days
      Value: "0"
      Reason: must be greater than or equal to 1
  Action:
  Update your application's configuration
  the exception TiffinBox's main threw: org.springframework.beans.factory.UnsatisfiedDependencyException
  … 27 more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …
A′  A, re-run
$ java -cp "nodays:$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18695
  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0
  Property: lines 1 · SQLException lines 0 · stack-frame lines 0
  the class path gives: application.yaml <- nodays/application.yaml · application.properties <- none
  APPLICATION FAILED TO START
  Description:
  Binding to target com.tiffinbox.TiffinBoxProperties failed:
      Property: tiffinbox.days
      Value: "null"
      Reason: must not be null
  Action:
  Update your application's configuration
  the exception TiffinBox's main threw: org.springframework.beans.factory.UnsatisfiedDependencyException
  … 27 more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …
C   novalidated/: this tree minus @Validated, the same nodays/ file
$ java -cp "nodays:$NOVALID" com.tiffinbox.harness.Serve --tiffinbox.port=18695
  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0
  Property: lines 0 · SQLException lines 0 · stack-frame lines 37
  the class path gives: application.yaml <- nodays/application.yaml · application.properties <- none
  Caused by: org.springframework.beans.BeanInstantiationException: Failed to instantiate [com.tiffinbox.web.TiffinBoxServer]: Constructor threw exception
  Caused by: java.lang.NullPointerException: Cannot invoke "java.lang.Integer.intValue()" because the return value of "com.tiffinbox.TiffinBoxProperties.days()" is null
  the exception TiffinBox's main threw: org.springframework.beans.factory.BeanCreationException
  … 59 more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …
```

The `days` line deleted. **A** — this tree (`@NotNull @Min(1) Integer days`): `Value: "null"`, `must not be null`.
**B** — `intrecord/` (`@Min(1) int days`, no `@NotNull`): `Value: "0"` — a value nobody wrote — `must be greater than or
equal to 1`. Neither block has an `Origin:` line: the key is in no source. **A′** — A re-run. **C** — `novalidated/`, the
same file: nothing checks the record, the `null` reaches `TiffinBoxServer`'s constructor, which unboxes `days()`, and the
start dies — exit 1, 0 `Property:` lines, `NullPointerException: Cannot invoke "java.lang.Integer.intValue()" because the
return value of "com.tiffinbox.TiffinBoxProperties.days()" is null`. Brief ⚑6's choice, measured both ways, and its cost:
`Integer` needs `@Validated`.

## 8 · Method validation, asked of Boot

`.r-method.out` `17fc43a7c836bcea5c1606978407b4e1`

```
Boot's parent POM, the compiler's flag: line 113: <parameters>true</parameters> (1 such line)
A   this tree
$ java -cp "$AFTER" com.tiffinbox.harness.Hire --tiffinbox.port=18696
exit 0 · WARN lines 0 · ERROR lines 0
parameter names, as compiled: TiffinBox's OrderQueue(TiffinBoxProperties) -> settings (present: true) · the harness's Hiring.hire(int) -> cooks (present: true)
MethodValidationPostProcessor beans: [methodValidationPostProcessor] · methodValidationPostProcessor is declared by org.springframework.boot.validation.autoconfigure.ValidationAutoConfiguration.methodValidationPostProcessor()
the hiring bean's class: com.tiffinbox.harness.Hiring$$SpringCGLIB$$<n> · a subclass of Hiring: true
hire(0) -> threw jakarta.validation.ConstraintViolationException: hire.cooks: must be greater than or equal to 1
take(new Slip(0)), its parameter marked @Valid -> threw jakarta.validation.ConstraintViolationException: take.slip.meals: must be greater than or equal to 1
takeUnchecked(new Slip(0)), no @Valid -> returned 0
… elided: 8 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
B   the previous tree: no validation starter
$ java -cp "$BEFORE" com.tiffinbox.harness.Hire --tiffinbox.port=18696
exit 0 · WARN lines 0 · ERROR lines 0
parameter names, as compiled: TiffinBox's OrderQueue(TiffinBoxProperties) -> settings (present: true) · the harness's Hiring.hire(int) -> cooks (present: true)
MethodValidationPostProcessor beans: []
the hiring bean's class: com.tiffinbox.harness.Hiring · a subclass of Hiring: false
hire(0) -> returned 0
take(new Slip(0)), its parameter marked @Valid -> returned 0
takeUnchecked(new Slip(0)), no @Valid -> returned 0
… elided: 8 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
A′  A, re-run
$ java -cp "$AFTER" com.tiffinbox.harness.Hire --tiffinbox.port=18696
exit 0 · WARN lines 0 · ERROR lines 0
parameter names, as compiled: TiffinBox's OrderQueue(TiffinBoxProperties) -> settings (present: true) · the harness's Hiring.hire(int) -> cooks (present: true)
MethodValidationPostProcessor beans: [methodValidationPostProcessor] · methodValidationPostProcessor is declared by org.springframework.boot.validation.autoconfigure.ValidationAutoConfiguration.methodValidationPostProcessor()
the hiring bean's class: com.tiffinbox.harness.Hiring$$SpringCGLIB$$<n> · a subclass of Hiring: true
hire(0) -> threw jakarta.validation.ConstraintViolationException: hire.cooks: must be greater than or equal to 1
take(new Slip(0)), its parameter marked @Valid -> threw jakarta.validation.ConstraintViolationException: take.slip.meals: must be greater than or equal to 1
takeUnchecked(new Slip(0)), no @Valid -> returned 0
… elided: 8 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
C   this tree, the harness compiled without -parameters
$ java -cp "$NOPARAMS" com.tiffinbox.harness.Hire --tiffinbox.port=18696
exit 0 · WARN lines 0 · ERROR lines 0
parameter names, as compiled: TiffinBox's OrderQueue(TiffinBoxProperties) -> settings (present: true) · the harness's Hiring.hire(int) -> arg0 (present: false)
MethodValidationPostProcessor beans: [methodValidationPostProcessor] · methodValidationPostProcessor is declared by org.springframework.boot.validation.autoconfigure.ValidationAutoConfiguration.methodValidationPostProcessor()
the hiring bean's class: com.tiffinbox.harness.Hiring$$SpringCGLIB$$<n> · a subclass of Hiring: true
hire(0) -> threw jakarta.validation.ConstraintViolationException: hire.arg0: must be greater than or equal to 1
take(new Slip(0)), its parameter marked @Valid -> threw jakarta.validation.ConstraintViolationException: take.arg0.meals: must be greater than or equal to 1
takeUnchecked(new Slip(0)), no @Valid -> returned 0
… elided: 8 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
```

The ledger's P33: Course 4 said "you get it free", and its README's erratum said method validation is not free without
Spring Boot. **A** — this tree: one `MethodValidationPostProcessor`, declared by
`ValidationAutoConfiguration.methodValidationPostProcessor()` — the class `imports` found in the second imports file. The
`Hiring` bean the context hands out is a subclass Spring generated (`Hiring$$SpringCGLIB$$<n>`), and the checks happen
there: `hire(0)` throws `ConstraintViolationException: hire.cooks: …`; `take(@Valid Slip)` throws for the slip's own rule
(`take.slip.meals`); `takeUnchecked(Slip)`, the same object without `@Valid`, returns 0. **B** — the previous tree, no
starter: no post-processor, the plain class, and all three calls return 0. **A′** — A re-run. **C** — the harness compiled
without `-parameters`: the same rejection reads `hire.arg0` (and `take.arg0.meals`). P27: Boot's parent POM sets
`<parameters>true</parameters>` (line 113 of `spring-boot-starter-parent-4.1.1.pom`), and TiffinBox's own `OrderQueue`,
built by Maven under that parent, keeps its parameter's name (`settings`, present: true).

So under Boot, with the validation starter, the post-processor is registered for you; `@Validated` on the class and
`@Valid` on an object parameter are still yours. Course 4's erratum stands for plain Spring.

## 9 · The jar: the seven responses, unchanged

`.r-serve.out` `0aa052161d73d7884aa71a9db2e10421`

```
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18690
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  TiffinBox's log: meal types:     [VEG, NON_VEG, VEGAN]
the logging flag after/README.md gives, after the port: --logging.level.tiffinbox=debug
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18690 --logging.level.tiffinbox=debug
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  route DEBUG lines 5
the lunch-rush flag after/README.md gives, after the port: --spring.profiles.active=rush
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18690 --spring.profiles.active=rush
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  Boot: The following 1 profile is active: "rush"
```

`after/`'s jar, run as the anchor README runs it, three ways: plain, with the logging flag `after/README.md` gives (read
from the file, not typed here: `--logging.level.tiffinbox=debug`, 5 route DEBUG lines), and with its lunch-rush flag
(`--spring.profiles.active=rush`). The seven responses hash to `115c36ba…` every time: the anchor change changed nothing a
client sees.

## 10 · The demo files, against the files they stand in for

`.r-files.out` `f6ef094ef1786f67929df773c6df539f`

```
cooks0/application.yaml, against the anchor's application.yaml:
  4c4
  <   cooks: 3
  ---
  >   cooks: 0
nodays/application.yaml, against the anchor's application.yaml:
  5d4
  <   days: 30
fourbad/application.yaml, against the anchor's application.yaml:
  3,5c3,4
  <   jdbc-url: jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1
  <   cooks: 3
  <   days: 30
  ---
  >   jdbc-url: ""
  >   cooks: 0
  8,11c7
  <   meal-types:
  <     - VEG
  <     - NON_VEG
  <     - VEGAN
  ---
  >   meal-types: []
atvalue/Database.java, against after/'s Database.java:
  3a4
  > import org.springframework.beans.factory.annotation.Value;
  16,17c17,18
  <     public Database(TiffinBoxProperties settings) {
  <         this.url = settings.jdbcUrl();
  ---
  >     public Database(@Value("${tiffinbox.jdbc-url}") String url) {
  >         this.url = url;
intrecord/TiffinBoxProperties.java, against after/'s TiffinBoxProperties.java:
  32,33c32,33
  < public record TiffinBoxProperties(@NotBlank String jdbcUrl, @NotNull @Min(1) Integer cooks, @NotNull @Min(1) Integer days,
  <                                   @NotNull @Min(1) Integer port, @NotEmpty List<MealType> mealTypes) {
  ---
  > public record TiffinBoxProperties(@NotBlank String jdbcUrl, @Min(1) int cooks, @Min(1) int days, @Min(1) int port,
  >                                   @NotEmpty List<MealType> mealTypes) {
novalidated/TiffinBoxProperties.java, against after/'s TiffinBoxProperties.java:
  30d29
  < @Validated
nostarter/tiffinbox-web/pom.xml: the previous tree's tiffinbox-web/pom.xml, byte for byte
nostarter/tiffinbox-web/pom.xml, against after/'s tiffinbox-web/pom.xml:
  31,37d30
  <     <!-- Course 5: Bean Validation for TiffinBoxProperties - Hibernate Validator (the implementation), the API it
  <          implements, and spring-boot-validation, whose own imports file adds ValidationAutoConfiguration. Without an
  <          implementation, the API jar alone (which tiffinbox-core brings) stops the start even with a good configuration. -->
  <     <dependency>
  <       <groupId>org.springframework.boot</groupId>
  <       <artifactId>spring-boot-starter-validation</artifactId>
  <     </dependency>
noapi/tiffinbox-core/pom.xml: the previous tree's tiffinbox-core/pom.xml, byte for byte
noapi/tiffinbox-core/pom.xml, against after/'s tiffinbox-core/pom.xml:
  38,44d37
  <     <!-- Course 5: the record's constraints (@NotBlank, @NotNull, @Min, @NotEmpty) are Bean Validation's annotations, from
  <          its API jar alone - the version is managed by Boot's parent. The implementation that checks them comes with
  <          tiffinbox-web's validation starter; this module only needs the annotations to compile. -->
  <     <dependency>
  <       <groupId>jakarta.validation</groupId>
  <       <artifactId>jakarta.validation-api</artifactId>
  <     </dependency>
```

Every demo file differs from the file it stands in for exactly as its folder says. `nostarter/` and `noapi/` hold the
previous tree's POMs, byte for byte; `novalidated/` deletes one line, `@Validated`.

## Exercise

`exercise/README.md` — in a copy of `after/` (under `.harness/mine`), give `cooks` a rule of your own, at most ten, then
start TiffinBox with eleven cooks (`Start`, port 18699) and read the report's reason. (The unit's first exercise — remove
`@Validated`, start with zero cooks — became `break` B on screen, RED #27, so the exercise asks a new question.) Measured
answer, run exactly as written in a clean shell, in `exercise/solution/SOLUTION.md`: as shipped, eleven cooks start
without a word (exit 0); with `@Max(10)`, exit 1 and `Property: tiffinbox.cooks` · `Value: "11"` · `Reason: must be less
than or equal to 10`.

## Found on the way

- **The probe's "71 lines, no banner" is 71 lines with the banner here.** The previous tree's jar with `--tiffinbox.cooks=-1`
  prints Boot's banner (one `:: Spring Boot ::` line) and 71 lines in all, 45 of them stack frames; the voice speaks the
  frames.
- **A harness run that fails with Boot's report prints no stack trace** (0 stack-frame lines in `break` A, `order` A,
  `boxed`), while a failure no analyzer explains is logged whole (`order` B: 67 frames; `unvalidated`: 45).
- **The anchor's file starts with a comment,** so `cooks` is line 4 and its origin reads `4:10`; the probe's files had no
  comment and read `3:10`.
- **`-parameters` names the object parameter too:** without it, `take.slip.meals` becomes `take.arg0.meals`.
- **The jar's manifest carries the class path:** `$MINE` in the exercise names the harness's classes and one jar, and the
  manifest's `Class-Path` names all 33 jars in `lib/` (measured: the exercise runs).
