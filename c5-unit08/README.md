# c5-unit08 — @ConfigurationProperties

Course 5 · Spring Boot · Section 2 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**, 2026-09-30.
TiffinBox read its settings with four `@Value` placeholders in three classes, each a key's name filled with one value as
text — and none of them read the meal-types list the last unit added. This unit binds them once, into one typed record,
`TiffinBoxProperties`, and measures what that buys and what it quietly costs: the record in the running app, the metadata
file Boot's configuration processor writes (and the one build setup that writes nothing, silently), the enum converter the
last course wrote by hand (now Boot's, and still needed in plain Spring), the placeholder resolver that one
auto-configuration declares, and a key deleted from the file — which `@Value` refused to start without, and the record
turns into a zero.

The change lands in `../c5-tiffinbox`; `after/` is this unit's frozen copy of it. "Before" is `../c5-unit07/after/` (the
anchor as the last unit left it), **copied** to `.harness/before/` and built there, so this unit never writes into another
unit's folder. Clean builds, offline first; every number the video speaks is asserted; three runs per capture.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 10 captures, 3 runs each; every spoken number asserted; a published-md5 mismatch stops it
```

(`receipts.sh` carries the same two `export` lines at its top; a bare `java` on this Mac is 23.0.1.) `receipts.sh`
**dies** when a capture's md5 differs from `receipts.md5` — it prints the `DIFFERS` line first, so you can see which one
moved (tested twice: after the `convert` capture gained a line, the run printed `convert … DIFFERS from the published
81d1a2d4…` and stopped with exit 1; a deliberately wrong hash for `change` stopped it the same way, and `receipts.md5` was
restored). A whole run takes about 1 min 45 s on the author's Mac.

**The repository.** Every build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` in the commands): a copy of
`../c5-unit07/.m2-demo`, plus **one** artifact the anchor did not need before — `spring-boot-configuration-processor`
4.1.1 (its jar and POM, recorded as from `central`), copied from the Section 2 probe's repository, which fetched it from
Maven Central on 2026-09-29. Nothing else was resolved: after a full run, no file in `.m2-demo` is newer than the run's
start. The three tree builds fall back to Maven Central only if the offline build fails; the five processor builds are
offline only. Offline re-run of the frozen tree: `mvn -o -B -f after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" verify` →
BUILD SUCCESS, 0 WARNING lines.

## The anchor change

Two files new, six changed (README aside), nothing else — `change`, below, shows every changed code line:
- **new in `tiffinbox-core`:** `TiffinBoxProperties`, a record annotated `@ConfigurationProperties("tiffinbox")` —
  `String jdbcUrl, int cooks, int days, int port, List<MealType> mealTypes`, each component described by a `@param` line —
  and `MealType`, an enum: `VEG, NON_VEG, VEGAN`, the list's values.
- `Database`, `OrderQueue` and `TiffinBoxServer` take the record as a constructor parameter where their `@Value`
  placeholders were (4 → 0). `TiffinBoxServer` also keeps the list, and logs it at startup: `meal types:     [VEG,
  NON_VEG, VEGAN]`. Field names are unchanged (`Database.url`, `OrderQueue.cooks`, `TiffinBoxServer.days` and `.port`).
- `TiffinBoxApp` gains `@EnableConfigurationProperties(TiffinBoxProperties.class)` (and a Javadoc paragraph).
- `tiffinbox-core/pom.xml` gains `spring-boot` (no version: managed) — `@ConfigurationProperties` is Boot's own
  annotation. Core still has no HTTP in it.
- the root `pom.xml` names `spring-boot-configuration-processor` in `maven-compiler-plugin`'s `annotationProcessorPaths`,
  in `pluginManagement`, with no version (Boot's parent manages it), so it runs in both modules.

`application.yaml` and the run command are unchanged. The seven responses of `../c4-unit31/curlset.sh` still hash to
`115c36bac276128e245ca57df11c2891` (`serve`, `break` A).

## The harness — TiffinBox's own `main`, read from the inside

`harness/com/tiffinbox/harness/` holds plain classes with **no class-level annotation**, so TiffinBox's
`@ComponentScan("com.tiffinbox")` (which registers annotated classes only) never picks one up. None copies TiffinBox's
start-up: each calls the tree's own `TiffinBoxServer.main(args)` inside Boot's `SpringApplication.withHook(…)`, whose run
listener is handed the context `main` starts (`Run.java`). If `main` throws, the harness prints the exception's type and
rethrows it, so the exit code is the one TiffinBox's own run gives. The harness is compiled against `after/`'s jars;
`Serve` and `Run` also run on the previous tree, so they never name the record's class in their code (they look it up by
name — that tree has no such class).

- `Props <TiffinBox's arguments>` — the record in the running app: the beans of its type and their names; its
  constructor count, its prefix, and **Boot's own bind method** for it (`ConfigurationPropertiesBean.getAll(context)` →
  `asBindTarget().getBindMethod()`); the record itself, as a record prints itself; the Java type of each item of its list;
  and the values the three readers hold, read off the live beans, compared with the record's.
- `Serve <TiffinBox's arguments>` — prints the record and which `application.yaml` the class path gave, then returns
  **without** closing the context: TiffinBox keeps serving, exactly as its own `main` leaves it, until `POST /shutdown`.
- `Favourite <TiffinBox's arguments>` — registers one extra bean by code, `FavouriteByValue` (`@Value("${tiffinbox.favourite}")
  MealType`), then prints the list's lines as the loaded file writes them, each beside the text Boot holds (in quotes, so a
  trailing space shows), the record's list with its items' type, and the favourite.
- `Convert <TiffinBox's arguments>` — the conversion service of TiffinBox's context (its class and jar, whether it is a
  Spring `GenericConversionService`, its String → Enum converters in the order its own listing prints them, and what it
  makes of `"non-veg"`); then, while that context is still open, a **plain Spring** `AnnotationConfigApplicationContext`
  on the same class path — no Boot — with one property, `tiffinbox.favourite=non-veg`, and the same `FavouriteByValue`
  bean, refreshed.
- `Placeholders <mael or -> <TiffinBox's arguments>` — with `mael`, one extra bean by code, `MaelByValue`
  (`@Value("${tiffinbox.mael}") String`, a typo with no default); then the beans of type
  `PropertySourcesPlaceholderConfigurer` and the configuration class and method that declared each.
- `Metadata <jar> <the record's source>` — reads `META-INF/spring-configuration-metadata.json` out of the jar (Jackson,
  on TiffinBox's class path), prints its sections and every property, and checks it against the record's source: each
  description against the `@param` line of its component, and each `int` component for `"defaultValue": 0`. It starts no
  application.

**`$BEFORE`, `$AFTER` and `$NOENABLE`** are the harness's classes plus that tree's jars (`tiffinbox-web-1.0.0.jar` and
`lib/*.jar`): the previous tree, this unit's `after/`, and `after/` built with `noenable/TiffinBoxApp.java` in place of its
own. `receipts.sh` writes them to `.harness/*.classpath`. Every command is printed exactly as it runs: `receipts.sh`
passes it to `eval`, so those variables — and `$M2`, this unit's `.m2-demo` — expand when it runs. The jar runs (`java -jar
tiffinbox-web-1.0.0.jar …`) start in `after/tiffinbox-web/target`; every other command runs from this folder.

**The demo files.** A folder put in front of `$AFTER` on a class path holds one `application.yaml` that the class path
then gives **instead of** the copy packaged in TiffinBox's jar (the harness's `the class path gives:` line names the file
it got). Each is the anchor's `application.yaml` with one declared change, and the `files` capture diffs every one:
`nodays/` (the `days` line deleted) · `nourl/` (the `jdbc-url` line deleted) · `nomeals/` (the `meal-types` list
deleted) · `lenient/` (the list written `veg`, `non-veg`, `"Vegan "`) · `vegetarian/`
(`lenient/`'s file with the third item `vegetarian`). `noenable/TiffinBoxApp.java` is `after/`'s with three lines taken
out (the annotation and its two imports). `processor/` holds the POMs laid over a copy of `after/` for the processor's
variants: `dependency/pom.xml` (the root without the processor path — the previous tree's root POM, byte for byte) and
`dependency/tiffinbox-core/pom.xml` (the processor as an `<optional>` dependency) · `full/pom.xml` (A's root plus
`<proc>full</proc>`) · `web/tiffinbox-web/pom.xml` (the processor path in web alone) · `plain/tiffinbox-core/pom.xml`
(`dependency/`'s without `<optional>`, its comment reworded).

**Ports** (Section 2 brief ⚑11: 18680-18689): serve 18680 · record 18681 (B never binds) · lenient 18682 (B never binds)
· convert 18683 · placeholder 18684 (A never binds) · break 18685 (C and D never bind) · the exercise 18689. Every command
names its port; `receipts.sh` first checks that nothing listens on 18425 or on any of its ports.

## Masks, filters and hygiene — every one, declared

1. Boot's own log lines (each starts with an ISO timestamp and carries a pid) are dropped from a harness report and
   counted; so are the lines printed before the report (the banner and its blank lines): the last line of each report says
   how many of each (`… elided: N log line(s) of Boot's, and M line(s) printed before the report …`).
2. A kept log message loses its prefix (time, level, pid, thread, logger) through `sub()` — the list's line and the
   profile line in `serve`, `orders cooked:` in `break`. In `convert`, the run's one WARN line keeps its logger and loses
   its time, pid and thread, and its message is cut before the exception's own text (`: org.springframework…`), both by
   `sub()`.
3. A failed start shows its exit code, its WARN, ERROR and `listening` line counts, then Boot's own failure report
   (`APPLICATION FAILED TO START` to the end of its Action) **without its blank lines and its rows of asterisks** — or,
   when Boot printed no report, the run's first `Caused by:` line — then the exception the harness names, then a counted
   line: `… N more line(s) of this run's output not shown …`. `break` D (no report; its first `Caused by:` line carries
   an absolute jar path) shows instead how many `Caused by:` lines there are and the last one, the root cause, its
   `Caused by: ` prefix cut by `sed`; the rest is counted the same way.
4. The processor builds are reduced to counts: the exit code, the `BUILD` line, the `[WARNING]` and `[ERROR]` lines, the
   metadata files found under both modules' `target/`, and `lib/`'s jars (with the processor among them, and in the
   manifest's `Class-Path`).
5. `change` shows every changed **code** line: each changed file's comments (Java `/* */` blocks and lines starting `*` or
   `//`; XML `<!-- -->`) and blank lines are dropped from both versions before git diffs them (`-U0`), and the header line
   counts the changed lines that were dropped.
6. Hygiene: `receipts.sh` unsets every `TIFFINBOX_*` and `SPRING_*` variable, `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`,
   `MAVEN_OPTS` and `MAVEN_ARGS` before it runs anything — a variable of yours would otherwise become a property source,
   or a flag. It also refuses to run twice at once in this folder (`.r-lock`): two runs share `.harness/` and the ports.
   On every exit — the end, a failed check, or Ctrl-C — its EXIT trap stops the JVM it started in the background, if it
   still runs, and removes the lock; Ctrl-C makes it exit 130. Tested 2026-09-30: Ctrl-C (SIGINT to the script's process
   group) while `break` served on 18685 → exit 130, that JVM gone, nothing listening on 18425 or 18680-18689, `.r-lock`
   removed. If a port is still busy, the port check names it and gives the stop command: `curl -X POST
   http://127.0.0.1:<port>/shutdown`.
7. `serve`'s second and third runs take their flag from `after/README.md` (its logging command and its lunch-rush
   command, the flag after the port), read out of the file by `sed`; each label prints what it read, and `receipts.sh`
   dies if the file stops giving one.

## 1 · The change — two files in, six changed

`.r-change.out` `39843f5233c6111ee63a2b09dd24913d`

```
files, README aside: the previous tree 14 · after/ 16 · in both 14: identical 8, changed 6
  only before: (none)
  only after:  tiffinbox-core/src/main/java/com/tiffinbox/MealType.java tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java
pom.xml (the root), every changed line but comments and blanks (5 of those not shown):
+          <configuration>
+            <annotationProcessorPaths>
+              <path>
+                <groupId>org.springframework.boot</groupId>
+                <artifactId>spring-boot-configuration-processor</artifactId>
+              </path>
+            </annotationProcessorPaths>
+          </configuration>
tiffinbox-core/pom.xml, every changed line but comments and blanks (2 of those not shown):
+    <dependency>
+      <groupId>org.springframework.boot</groupId>
+      <artifactId>spring-boot</artifactId>
+    </dependency>
Database.java, every changed line but comments and blanks (0 of those not shown):
-import org.springframework.beans.factory.annotation.Value;
-    public Database(@Value("${tiffinbox.jdbc-url}") String url) {
-        this.url = url;
+    public Database(TiffinBoxProperties settings) {
+        this.url = settings.jdbcUrl();
OrderQueue.java, every changed line but comments and blanks (0 of those not shown):
-import org.springframework.beans.factory.annotation.Value;
-    public OrderQueue(@Value("${tiffinbox.cooks}") int cooks) {
-        this.cooks = cooks;
+    public OrderQueue(TiffinBoxProperties settings) {
+        this.cooks = settings.cooks();
TiffinBoxApp.java, every changed line but comments and blanks (4 of those not shown):
+import com.tiffinbox.TiffinBoxProperties;
+import org.springframework.boot.context.properties.EnableConfigurationProperties;
+@EnableConfigurationProperties(TiffinBoxProperties.class)
TiffinBoxServer.java, every changed line but comments and blanks (0 of those not shown):
-import org.springframework.beans.factory.annotation.Value;
+import com.tiffinbox.MealType;
+import com.tiffinbox.TiffinBoxProperties;
+    private final List<MealType> mealTypes;
-    TiffinBoxServer(CustomerRepository repo, Dashboard dashboard, OrderQueue kitchen,
-                    @Value("${tiffinbox.days}") int days, @Value("${tiffinbox.port}") int port) {
+    TiffinBoxServer(CustomerRepository repo, Dashboard dashboard, OrderQueue kitchen, TiffinBoxProperties settings) {
-        this.days = days;
-        this.port = port;
+        this.days = settings.days();
+        this.port = settings.port();
+        this.mealTypes = settings.mealTypes();
+        LOG.log(INFO, "meal types:     {0}", mealTypes);
TiffinBox's @Value placeholders: the previous tree 4, in Database.java OrderQueue.java TiffinBoxServer.java · after/ 0
  the keys the previous tree's placeholders name: tiffinbox.cooks tiffinbox.days tiffinbox.jdbc-url tiffinbox.port
the new file, whole: tiffinbox-core/src/main/java/com/tiffinbox/MealType.java
  1 | package com.tiffinbox;
  2 | 
  3 | /** The meal types TiffinBox serves: the values application.yaml lists under {@code tiffinbox.meal-types}. */
  4 | public enum MealType { VEG, NON_VEG, VEGAN }
the new file, whole: tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java
  1 | package com.tiffinbox;
  2 | 
  3 | import org.springframework.boot.context.properties.ConfigurationProperties;
  4 | 
  5 | import java.util.List;
  6 | 
  7 | /**
  8 |  * TiffinBox's settings: every key under {@code tiffinbox} in application.yaml, bound once, into one typed object.
  9 |  *
 10 |  * <p>Boot's binder fills it through its only constructor, the record's own. The {@code @param} lines below are not
 11 |  * decoration: the configuration processor copies each one into the metadata file an IDE reads, as the description of
 12 |  * that key.
 13 |  *
 14 |  * @param jdbcUrl   the address of TiffinBox's database, an in-memory H2 database
 15 |  * @param cooks     how many cooks take orders off the kitchen rail
 16 |  * @param days      how many days of orders the kitchen cooks at startup
 17 |  * @param port      the port TiffinBox listens on, on 127.0.0.1
 18 |  * @param mealTypes the meal types TiffinBox serves
 19 |  */
 20 | @ConfigurationProperties("tiffinbox")
 21 | public record TiffinBoxProperties(String jdbcUrl, int cooks, int days, int port, List<MealType> mealTypes) {
 22 | }
```

Fourteen files before, sixteen after (README aside): eight identical, six changed, two new. The four `@Value`
placeholders (in `Database`, `OrderQueue` and the two on one line in `TiffinBoxServer`) name the four keys — none names the
list — and each class takes `TiffinBoxProperties settings` instead: 4 → 0. `TiffinBoxApp`'s code gains one annotation and
its two imports (its Javadoc paragraph is the 4 lines not shown); the root POM gains the processor path (8 code lines, no
version); core's POM gains `spring-boot`. The record's `@param` lines (14-18) are the descriptions the metadata file will
carry (section 5).

## 2 · The record in the running app — and the annotation that registers it

`.r-record.out` `463d0479bf99770e2bdba012bc2b4f0d`

```
A   this tree
$ java -cp "$AFTER" com.tiffinbox.harness.Props --tiffinbox.port=18681
exit 0 · WARN lines 0 · ERROR lines 0
beans of type TiffinBoxProperties: [tiffinbox-com.tiffinbox.TiffinBoxProperties]
its constructors: 1 · its prefix: tiffinbox · Boot's binder fills it by: VALUE_OBJECT
the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=3, days=30, port=18681, mealTypes=[VEG, NON_VEG, VEGAN]]
the type of each item of its list: [com.tiffinbox.MealType, com.tiffinbox.MealType, com.tiffinbox.MealType]
the readers, off the live beans: Database.url = jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1 · OrderQueue.cooks = 3 · TiffinBoxServer.days = 30 · TiffinBoxServer.port = 18681
each one the record's own value: true
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application.properties <- none
… elided: 8 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
B   this tree built with noenable/TiffinBoxApp.java: @EnableConfigurationProperties and its two imports taken out
$ java -cp "$NOENABLE" com.tiffinbox.harness.Props --tiffinbox.port=18681
  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0
  APPLICATION FAILED TO START
  Description:
  Parameter 0 of constructor in com.tiffinbox.Database required a bean of type 'com.tiffinbox.TiffinBoxProperties' that could not be found.
  Action:
  Consider defining a bean of type 'com.tiffinbox.TiffinBoxProperties' in your configuration.
  the exception TiffinBox's main threw: org.springframework.beans.factory.UnsatisfiedDependencyException
  … 26 more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …
A′  A, re-run
$ java -cp "$AFTER" com.tiffinbox.harness.Props --tiffinbox.port=18681
exit 0 · WARN lines 0 · ERROR lines 0
beans of type TiffinBoxProperties: [tiffinbox-com.tiffinbox.TiffinBoxProperties]
its constructors: 1 · its prefix: tiffinbox · Boot's binder fills it by: VALUE_OBJECT
the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=3, days=30, port=18681, mealTypes=[VEG, NON_VEG, VEGAN]]
the type of each item of its list: [com.tiffinbox.MealType, com.tiffinbox.MealType, com.tiffinbox.MealType]
the readers, off the live beans: Database.url = jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1 · OrderQueue.cooks = 3 · TiffinBoxServer.days = 30 · TiffinBoxServer.port = 18681
each one the record's own value: true
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application.properties <- none
… elided: 8 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
C   this tree, the profile rush on
$ java -cp "$AFTER" com.tiffinbox.harness.Props --tiffinbox.port=18681 --spring.profiles.active=rush
exit 0 · WARN lines 0 · ERROR lines 0
beans of type TiffinBoxProperties: [tiffinbox-com.tiffinbox.TiffinBoxProperties]
its constructors: 1 · its prefix: tiffinbox · Boot's binder fills it by: VALUE_OBJECT
the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=6, days=30, port=18681, mealTypes=[VEG, NON_VEG, VEGAN]]
the type of each item of its list: [com.tiffinbox.MealType, com.tiffinbox.MealType, com.tiffinbox.MealType]
the readers, off the live beans: Database.url = jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1 · OrderQueue.cooks = 6 · TiffinBoxServer.days = 30 · TiffinBoxServer.port = 18681
each one the record's own value: true
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application.properties <- none
… elided: 8 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
```

**A** One bean of the record's type, named `tiffinbox-com.tiffinbox.TiffinBoxProperties` — the prefix, a dash, the class
name. One constructor, and Boot's binder fills it by `VALUE_OBJECT`, Boot's name for binding through a constructor (a
record has no setters: its constructor is the one way in). All five components hold the file's values, each converted to
its type — the list's three items are `MealType`s — and the three readers hold exactly the record's values. **B** The same
tree built without `@EnableConfigurationProperties` (and its two imports): exit 1 before the port opens — `Parameter 0 of
constructor in com.tiffinbox.Database required a bean of type 'com.tiffinbox.TiffinBoxProperties' that could not be
found.` The record is not a bean by itself (it carries no `@Component`, and the scan registers annotated classes only).
**A′** = A, line for line. **C** (a variant, labelled so) `--spring.profiles.active=rush`: `cooks=6`, and `OrderQueue.cooks
= 6` — the record reads the profile's document, so the anchor README's rush line still holds.

## 3 · The jar: the list's log line, and the seven responses

`.r-serve.out` `0134239bba4ecec601f4098da92132e6`

```
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18680
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  TiffinBox's log: meal types:     [VEG, NON_VEG, VEGAN]
the logging flag after/README.md gives, after the port: --logging.level.tiffinbox=debug
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18680 --logging.level.tiffinbox=debug
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  route DEBUG lines 5
the lunch-rush flag after/README.md gives, after the port: --spring.profiles.active=rush
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18680 --spring.profiles.active=rush
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  Boot: The following 1 profile is active: "rush"
```

The run command is the anchor's, unchanged (`--tiffinbox.port=`). TiffinBox logs the list at startup — the first time anything in it reads
the list — and the seven responses of `../c4-unit31/curlset.sh` hash to `115c36bac276128e245ca57df11c2891` with the new
tree, with the logging flag read out of `after/README.md` (5 route lines), and with the lunch-rush flag it gives (the
profile `rush` on).

## 4 · The processor: six clean builds, one question

`.r-processor.out` `a567a97dfa1f0ea74811b20df95fe5d4`

```
A   the processor as an optional dependency: processor/dependency/pom.xml (the root, no processor path) · processor/dependency/tiffinbox-core/pom.xml (the processor, <optional>)
$ cd .harness/proc-dependency && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  exit 0 · BUILD SUCCESS · WARNING lines 0 · ERROR lines 0
  metadata files under the two modules' target/: 0
  lib/: 26 jars · the processor among them: 0 · named in the manifest's Class-Path: 0
B   this unit's after/, copied: the processor on the compiler's processor path, in the root pom.xml
$ cd .harness/proc-path && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  exit 0 · BUILD SUCCESS · WARNING lines 0 · ERROR lines 0
  metadata files under the two modules' target/: 1 · tiffinbox-core/target/classes/META-INF/spring-configuration-metadata.json
  lib/: 26 jars · the processor among them: 0 · named in the manifest's Class-Path: 0
A′  A, re-run
$ cd .harness/proc-dependency && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  exit 0 · BUILD SUCCESS · WARNING lines 0 · ERROR lines 0
  metadata files under the two modules' target/: 0
  lib/: 26 jars · the processor among them: 0 · named in the manifest's Class-Path: 0
C   A, plus <proc>full</proc> for the compiler: processor/full/pom.xml (the root) · A's tiffinbox-core/pom.xml
$ cd .harness/proc-full && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  exit 0 · BUILD SUCCESS · WARNING lines 0 · ERROR lines 0
  metadata files under the two modules' target/: 1 · tiffinbox-core/target/classes/META-INF/spring-configuration-metadata.json
  the same bytes as B's file: yes
  lib/: 26 jars · the processor among them: 0 · named in the manifest's Class-Path: 0
D   the processor path in tiffinbox-web only: A's root pom.xml · processor/web/tiffinbox-web/pom.xml · after/'s tiffinbox-core/pom.xml
$ cd .harness/proc-web && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  exit 0 · BUILD SUCCESS · WARNING lines 0 · ERROR lines 0
  metadata files under the two modules' target/: 0
  lib/: 26 jars · the processor among them: 0 · named in the manifest's Class-Path: 0
E   A without <optional>: A's root pom.xml · processor/plain/tiffinbox-core/pom.xml (the processor a plain dependency)
$ cd .harness/proc-plain && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  exit 0 · BUILD SUCCESS · WARNING lines 0 · ERROR lines 0
  metadata files under the two modules' target/: 0
  lib/: 27 jars · the processor among them: 1 · named in the manifest's Class-Path: 1
```

Each build is a clean one, in a copy of `after/` with the variant's POMs laid over it (section 10 diffs every POM).
**A** the processor added as an optional dependency of `tiffinbox-core` (`<optional>true</optional>`), the processor path
taken out: BUILD SUCCESS, 0 WARNING lines — and **no metadata file**. **B** `after/` itself, the processor on the
compiler's processor path in the root POM: the file, in core. **A′** = A, line for line: none again. **C** (a variant) A
plus `<proc>full</proc>` — one element apart: the file appears, byte for byte B's. So the processor itself works; on this
JDK (25.0.4.1), javac did not run a processor it found only on the class path until processing was switched on, and it said
nothing. (That JDK 23 changed this default is the known reason; no older JDK was measured here.) **D** (a variant) the
processor path in `tiffinbox-web` alone: no file anywhere — the processor runs only where it is configured, and the record
compiles in core. That is why it sits in the root POM's `pluginManagement`. `lib/` holds 26 jars in A to D: an
`<optional>` dependency of core does not reach web's `copy-dependencies`. **E** (a variant) A without `<optional>` — the
processor a plain dependency of core: still **no metadata file**, and now the processor is in `lib/` (27 jars) and in the
manifest's `Class-Path`. So a dependency writes nothing, optional or not, and 27 jars is what the non-optional
dependency ships — not `<proc>full</proc>` (C: 26). The Section 2 brief's ⚑5 said 27 for "dependency plus
`<proc>full</proc>`"; its ERRATA of 2026-09-30 quotes these lines.

## 5 · The file the processor writes

`.r-metadata.out` `c3e433a41ab46c2fa845778328474359`

```
$ unzip -p after/tiffinbox-web/target/lib/tiffinbox-core-1.0.0.jar META-INF/spring-configuration-metadata.json
  1 | {
  2 |   "groups": [
  3 |     {
  4 |       "name": "tiffinbox",
  5 |       "type": "com.tiffinbox.TiffinBoxProperties",
  6 |       "sourceType": "com.tiffinbox.TiffinBoxProperties"
  7 |     }
  8 |   ],
  9 |   "properties": [
 10 |     {
 11 |       "name": "tiffinbox.cooks",
 12 |       "type": "java.lang.Integer",
 13 |       "description": "how many cooks take orders off the kitchen rail",
 14 |       "sourceType": "com.tiffinbox.TiffinBoxProperties",
 15 |       "defaultValue": 0
 16 |     },
 17 |     {
 18 |       "name": "tiffinbox.days",
 19 |       "type": "java.lang.Integer",
 20 |       "description": "how many days of orders the kitchen cooks at startup",
 21 |       "sourceType": "com.tiffinbox.TiffinBoxProperties",
 22 |       "defaultValue": 0
 23 |     },
 24 |     {
 25 |       "name": "tiffinbox.jdbc-url",
 26 |       "type": "java.lang.String",
 27 |       "description": "the address of TiffinBox's database, an in-memory H2 database",
 28 |       "sourceType": "com.tiffinbox.TiffinBoxProperties"
 29 |     },
 30 |     {
 31 |       "name": "tiffinbox.meal-types",
 32 |       "type": "java.util.List<com.tiffinbox.MealType>",
 33 |       "description": "the meal types TiffinBox serves",
 34 |       "sourceType": "com.tiffinbox.TiffinBoxProperties"
 35 |     },
 36 |     {
 37 |       "name": "tiffinbox.port",
 38 |       "type": "java.lang.Integer",
 39 |       "description": "the port TiffinBox listens on, on 127.0.0.1",
 40 |       "sourceType": "com.tiffinbox.TiffinBoxProperties",
 41 |       "defaultValue": 0
 42 |     }
 43 |   ],
 44 |   "hints": [],
 45 |   "ignored": {
 46 |     "properties": []
 47 |   }
 48 | }
$ java -cp "$AFTER" com.tiffinbox.harness.Metadata after/tiffinbox-web/target/lib/tiffinbox-core-1.0.0.jar after/tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java
exit 0
its sections: groups 1 · properties 5 · hints 0 · ignored properties 0
group tiffinbox · type com.tiffinbox.TiffinBoxProperties
  tiffinbox.cooks        java.lang.Integer                      default 0     "how many cooks take orders off the kitchen rail"
  tiffinbox.days         java.lang.Integer                      default 0     "how many days of orders the kitchen cooks at startup"
  tiffinbox.jdbc-url     java.lang.String                       default none  "the address of TiffinBox's database, an in-memory H2 database"
  tiffinbox.meal-types   java.util.List<com.tiffinbox.MealType> default none  "the meal types TiffinBox serves"
  tiffinbox.port         java.lang.Integer                      default 0     "the port TiffinBox listens on, on 127.0.0.1"
the record's @param lines: 5 · descriptions that are one of them, word for word, for the same component: 5 of 5
the record's int components: [cooks, days, port] · given "defaultValue": 0 in the file: 3 of 3
the previous tree's core jar, the same question:
$ java -cp "$AFTER" com.tiffinbox.harness.Metadata .harness/before/tiffinbox-web/target/lib/tiffinbox-core-1.0.0.jar after/tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java
exit 0
no META-INF/spring-configuration-metadata.json in tiffinbox-core-1.0.0.jar
the jars in after/'s lib/ that carry a META-INF/spring-configuration-metadata.json: 3 of 26 · spring-boot-4.1.1.jar spring-boot-autoconfigure-4.1.1.jar tiffinbox-core-1.0.0.jar
```

The whole file, as the core jar in `after/tiffinbox-web/target/lib/` carries it — the jar on TiffinBox's class path —
then read: one group (`tiffinbox`), five properties, no hints. Every description is the record's `@param` text for that
component, word for word (5 of 5). Every `int` component (`cooks`, `days`, `port`) is given `"defaultValue": 0` (3 of 3),
typed `java.lang.Integer`: the processor documents the value an `int` holds when nothing sets it. Section 9 is that zero,
bound. The previous tree's core jar has no such file. The last line: 3 of the 26 jars in `after/`'s `lib/` carry a file of
the same name — Boot's `spring-boot` and `spring-boot-autoconfigure`, and TiffinBox's core. That editors read these files
to complete keys is what Boot's reference documentation says; no IDE was run here, and the video says it as the
documentation's claim, with a chip.

## 6 · Loose spellings, and one it cannot match

`.r-lenient.out` `6c82902d0e3067e1807118cd0ba7b0f0`

```
converters TiffinBox declares, in after/: 0 classes implement Converter, ConverterFactory or GenericConverter
A   lenient/: the list written veg, non-veg, "Vegan " (a trailing space)
$ java -cp "lenient:$AFTER" com.tiffinbox.harness.Favourite --tiffinbox.port=18682 --tiffinbox.favourite=non-veg
exit 0 · WARN lines 0 · ERROR lines 0
  line  9 |     - veg       ->  tiffinbox.meal-types[0] = "veg"
  line 10 |     - non-veg   ->  tiffinbox.meal-types[1] = "non-veg"
  line 11 |     - "Vegan "  ->  tiffinbox.meal-types[2] = "Vegan "
the record's list: [VEG, NON_VEG, VEGAN] · the type of each item: [com.tiffinbox.MealType]
@Value("${tiffinbox.favourite}") MealType favourite = NON_VEG
the class path gives: application.yaml <- lenient/application.yaml · application.properties <- none
… elided: 8 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
B   vegetarian/: the third item written vegetarian
$ java -cp "vegetarian:$AFTER" com.tiffinbox.harness.Favourite --tiffinbox.port=18682 --tiffinbox.favourite=non-veg
  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0
  APPLICATION FAILED TO START
  Description:
  Failed to bind properties under 'tiffinbox.meal-types[2]' to com.tiffinbox.MealType:
      Property: tiffinbox.meal-types[2]
      Value: "vegetarian"
      Origin: class path resource [application.yaml] - 11:7
      Reason: failed to convert java.lang.String to com.tiffinbox.MealType (caused by java.lang.IllegalArgumentException: No enum constant com.tiffinbox.MealType.vegetarian)
  Action:
  Update your application's configuration. The following values are valid:
      NON_VEG
      VEG
      VEGAN
  the exception TiffinBox's main threw: org.springframework.beans.factory.UnsatisfiedDependencyException
  … 27 more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …
A′  A, re-run
$ java -cp "lenient:$AFTER" com.tiffinbox.harness.Favourite --tiffinbox.port=18682 --tiffinbox.favourite=non-veg
exit 0 · WARN lines 0 · ERROR lines 0
  line  9 |     - veg       ->  tiffinbox.meal-types[0] = "veg"
  line 10 |     - non-veg   ->  tiffinbox.meal-types[1] = "non-veg"
  line 11 |     - "Vegan "  ->  tiffinbox.meal-types[2] = "Vegan "
the record's list: [VEG, NON_VEG, VEGAN] · the type of each item: [com.tiffinbox.MealType]
@Value("${tiffinbox.favourite}") MealType favourite = NON_VEG
the class path gives: application.yaml <- lenient/application.yaml · application.properties <- none
… elided: 8 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
```

TiffinBox declares no converter (0 classes implement `Converter`, `ConverterFactory` or `GenericConverter`). **A**
`lenient/`: the list written `veg`, `non-veg`, `"Vegan "` (a trailing space, inside quotes) binds to `[VEG, NON_VEG,
VEGAN]`, each item a `MealType`, and a `@Value` placeholder of type `MealType` given `non-veg` gets `NON_VEG`. The last
course wrote `MealTypeConverter` by hand to do exactly this. **B** `vegetarian/`: exit 1 before the port opens; Boot's
report names the key (`tiffinbox.meal-types[2]`), the value, the line and column in the file (11:7), and the valid values.
**A′** = A.

## 7 · Who converts

`.r-convert.out` `d49a280f54e27809b23dd1e5498a5984`

```
$ java -cp "$AFTER" com.tiffinbox.harness.Convert --tiffinbox.port=18683
exit 0 · WARN lines 1 · ERROR lines 0
Boot - TiffinBox as it runs:
  the context's conversion service: org.springframework.boot.convert.ApplicationConversionService (spring-boot-4.1.1.jar)
  a Spring Framework org.springframework.core.convert.support.GenericConversionService: true
  its converters for String -> Enum, in the order it asks them: org.springframework.boot.convert.LenientStringToEnumConverterFactory (spring-boot-4.1.1.jar) · org.springframework.core.convert.support.StringToEnumConverterFactory (spring-core-7.0.9.jar)
  "non-veg" -> MealType, through it: NON_VEG
plain Spring - the same class path, no Boot: an AnnotationConfigApplicationContext, tiffinbox.favourite=non-veg, one bean: FavouriteByValue
  the context's conversion service: null
  refresh: org.springframework.beans.factory.UnsatisfiedDependencyException
  its last cause: java.lang.IllegalStateException: Cannot convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType': no matching editors or conversion strategy found
… elided: 9 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
the WARN line: s.c.a.AnnotationConfigApplicationContext : Exception encountered during context initialization - cancelling refresh attempt
```

TiffinBox's context — the one Boot started — converts through Boot's `ApplicationConversionService` (in
`spring-boot-4.1.1.jar`), a Spring Framework `GenericConversionService`: the last course's mechanism, a registry of
converters. For String → Enum it holds two, and its own listing puts Boot's `LenientStringToEnumConverterFactory` before
Spring's `StringToEnumConverterFactory`; `"non-veg"` comes back `NON_VEG` through it. A plain Spring context on the same class path has **no** conversion service (`null`), and the same bean
fails with the last course's error: `no matching editors or conversion strategy found`. So "the third one needs a
converter, and you write it" (Course 4) is still true in plain Spring, and not under Boot. The run's one WARN line is that
plain context's own (`Exception encountered during context initialization`); TiffinBox's run is clean, and the capture
exits 0.

## 8 · One auto-configuration resolves placeholders

`.r-placeholder.out` `94184a99245230096c89a9056d0fac58`

```
TiffinBox as it runs: who resolves placeholders
$ java -cp "$AFTER" com.tiffinbox.harness.Placeholders - --tiffinbox.port=18684
exit 0 · WARN lines 0 · ERROR lines 0
PropertySourcesPlaceholderConfigurer beans: [propertySourcesPlaceholderConfigurer] · propertySourcesPlaceholderConfigurer is declared by org.springframework.boot.autoconfigure.context.PropertyPlaceholderAutoConfiguration.propertySourcesPlaceholderConfigurer()
… elided: 8 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
A   one bean added, with a typo in its placeholder: @Value("${tiffinbox.mael}") String mael
$ java -cp "$AFTER" com.tiffinbox.harness.Placeholders mael --tiffinbox.port=18684
  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0
  Caused by: org.springframework.util.PlaceholderResolutionException: Could not resolve placeholder 'tiffinbox.mael' in value "${tiffinbox.mael}"
  the exception TiffinBox's main threw: org.springframework.beans.factory.BeanCreationException
  … 62 more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …
B   the same, with the one auto-configuration that declares that bean excluded
$ java -cp "$AFTER" com.tiffinbox.harness.Placeholders mael --tiffinbox.port=18684 --spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.context.PropertyPlaceholderAutoConfiguration
  exit 0 · WARN lines 0 · ERROR lines 0 · listening lines 1
  @Value("${tiffinbox.mael}") String mael = ${tiffinbox.mael}
  PropertySourcesPlaceholderConfigurer beans: []
  … elided: 8 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
A′  A, re-run
$ java -cp "$AFTER" com.tiffinbox.harness.Placeholders mael --tiffinbox.port=18684
  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0
  Caused by: org.springframework.util.PlaceholderResolutionException: Could not resolve placeholder 'tiffinbox.mael' in value "${tiffinbox.mael}"
  the exception TiffinBox's main threw: org.springframework.beans.factory.BeanCreationException
  … 62 more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …
C   the same typo, with a default after the colon: @Value("${tiffinbox.mael:VEG}") String mael
$ java -cp "$AFTER" com.tiffinbox.harness.Placeholders mael:VEG --tiffinbox.port=18684
  exit 0 · WARN lines 0 · ERROR lines 0 · listening lines 1
  @Value("${tiffinbox.mael:VEG}") String mael = VEG
  PropertySourcesPlaceholderConfigurer beans: [propertySourcesPlaceholderConfigurer] · propertySourcesPlaceholderConfigurer is declared by org.springframework.boot.autoconfigure.context.PropertyPlaceholderAutoConfiguration.propertySourcesPlaceholderConfigurer()
  … elided: 8 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
```

TiffinBox as it runs holds one `PropertySourcesPlaceholderConfigurer` — the bean the last course registered by hand so that
an unresolved placeholder fails — and it is declared by Boot's `PropertyPlaceholderAutoConfiguration`. **A** one bean with
a typo in its placeholder (`mael`, no default): exit 1, `Could not resolve placeholder 'tiffinbox.mael'`. **B** the same,
with that one auto-configuration excluded: exit 0, the placeholder's own text injected (`${tiffinbox.mael}`), and no
configurer bean — the last course's behaviour without the bean. **A′** = A. TiffinBox itself starts in B: it has no `@Value`
left to resolve. **C** (a variant, labelled so) the same typo with a default after the colon, `${tiffinbox.mael:VEG}`:
exit 0, no WARN line, `mael = VEG` — the last course's other case, unchanged under Boot. So the auto-configuration makes a
typo **with no default** fail; a typo with one starts on the default.

## 9 · The break — one key deleted

`.r-break.out` `e61c8dd9153f23f0c43efc471d238aa5`

```
A   this tree, the anchor's own file
$ java -cp "$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18685
  listens on: 127.0.0.1:18685 · WARN lines 0 · ERROR lines 0
  the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=3, days=30, port=18685, mealTypes=[VEG, NON_VEG, VEGAN]]
  the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application.properties <- none
  TiffinBox's log: orders cooked:  120
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
B   nodays/: the anchor's file with the days line deleted
$ java -cp "nodays:$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18685
  listens on: 127.0.0.1:18685 · WARN lines 0 · ERROR lines 0
  the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=3, days=0, port=18685, mealTypes=[VEG, NON_VEG, VEGAN]]
  the class path gives: application.yaml <- nodays/application.yaml · application.properties <- none
  TiffinBox's log: orders cooked:  0
  GET   /kitchen    -> 200 application/json  {"ordersCooked":0,"ordersValue":0}
  exit 0 · the seven responses: 7 lines · md5 48c20805358e969bfc65e9197ce3b541
A′  A, re-run
$ java -cp "$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18685
  listens on: 127.0.0.1:18685 · WARN lines 0 · ERROR lines 0
  the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=3, days=30, port=18685, mealTypes=[VEG, NON_VEG, VEGAN]]
  the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application.properties <- none
  TiffinBox's log: orders cooked:  120
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
C   the previous tree (@Value), the same nodays/ file
$ java -cp "nodays:$BEFORE" com.tiffinbox.harness.Serve --tiffinbox.port=18685
  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0
  Caused by: org.springframework.util.PlaceholderResolutionException: Could not resolve placeholder 'tiffinbox.days' in value "${tiffinbox.days}"
  the exception TiffinBox's main threw: org.springframework.beans.factory.BeanCreationException
  … 62 more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …
D   nourl/: the anchor's file with the jdbc-url line deleted - text, not a number
$ java -cp "nourl:$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18685
  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0
  "Caused by:" lines 3 · the last, the root cause: java.sql.SQLException: The url cannot be null
  the exception TiffinBox's main threw: org.springframework.beans.factory.UnsatisfiedDependencyException
  … 92 more line(s) of this run's output not shown: the banner, Boot's log, the other "Caused by:" lines and the stack frames …
E   nomeals/: the anchor's file with the meal-types list deleted
$ java -cp "nomeals:$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18685
  listens on: 127.0.0.1:18685 · WARN lines 0 · ERROR lines 0
  the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=3, days=30, port=18685, mealTypes=null]
  the class path gives: application.yaml <- nomeals/application.yaml · application.properties <- none
  TiffinBox's log: orders cooked:  120
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

**A** this tree, the anchor's own file: `days=30`, 120 orders cooked, `115c36ba…`. **B** `nodays/`, the same file with its
`days` line deleted: the start is clean (exit 0, no WARN line), the record holds `days=0`, **0** orders are cooked,
`/kitchen` answers `{"ordersCooked":0,"ordersValue":0}`, and the seven responses hash to
`48c20805358e969bfc65e9197ce3b541`. Nothing says a key is missing. **A′** = A. **C** (a variant, labelled so) the previous
tree, whose `TiffinBoxServer` reads `@Value("${tiffinbox.days}")`, with the same file: exit 1 before the port opens,
naming the key. The metadata file printed that zero for `tiffinbox.days` (section 5): it records the zero, it does not
cause it. **D** (a variant) `nourl/`, the text key `jdbc-url` deleted: the record's `jdbcUrl` is null and the database
driver refuses it — exit 1 before the port opens, three `Caused by:` lines, the last `java.sql.SQLException: The url
cannot be null`. **E** (a variant) `nomeals/`, the list deleted: TiffinBox starts (0 WARN lines), the record holds
`mealTypes=null`, and the seven responses are unchanged (`115c36ba…`). So a missing **number** binds as zero; missing text
or a list binds as null. A default of your own is `@DefaultValue` on the record's component (the starter lesson uses it);
the next unit makes the configuration refuse to start instead.

## 10 · The demo files, against the files they stand in for

`.r-files.out` `bb6f3aac6f60926ddbe9773dc665316e`

```
nodays/application.yaml, against the anchor's application.yaml:
  5d4
  <   days: 30
nourl/application.yaml, against the anchor's application.yaml:
  3d2
  <   jdbc-url: jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1
nomeals/application.yaml, against the anchor's application.yaml:
  8,11d7
  <   meal-types:
  <     - VEG
  <     - NON_VEG
  <     - VEGAN
lenient/application.yaml, against the anchor's application.yaml:
  9,11c9,11
  <     - VEG
  <     - NON_VEG
  <     - VEGAN
  ---
  >     - veg
  >     - non-veg
  >     - "Vegan "
vegetarian/application.yaml, against lenient/application.yaml:
  11c11
  <     - "Vegan "
  ---
  >     - vegetarian
noenable/TiffinBoxApp.java, against after/'s TiffinBoxApp.java:
  3d2
  < import com.tiffinbox.TiffinBoxProperties;
  5d3
  < import org.springframework.boot.context.properties.EnableConfigurationProperties;
  32d29
  < @EnableConfigurationProperties(TiffinBoxProperties.class)
processor/dependency/pom.xml: the previous tree's pom.xml (the root), byte for byte
processor/dependency/pom.xml, against after/'s pom.xml (the root):
  73,85d72
  <           <!-- Course 5: Boot's configuration processor writes META-INF/spring-configuration-metadata.json, the file an IDE
  <                reads to complete and describe the keys of a @ConfigurationProperties class. It is named on the processor
  <                path, not added as a dependency: on JDK 25, javac skips a processor it finds only on the class path unless
  <                processing is switched on (-proc:full), and says nothing. No version: Boot's parent manages it. Declared
  <                here, so it runs in every module - the record lives in tiffinbox-core. -->
  <           <configuration>
  <             <annotationProcessorPaths>
  <               <path>
  <                 <groupId>org.springframework.boot</groupId>
  <                 <artifactId>spring-boot-configuration-processor</artifactId>
  <               </path>
  <             </annotationProcessorPaths>
  <           </configuration>
processor/dependency/tiffinbox-core/pom.xml, against after/'s tiffinbox-core/pom.xml:
  37a38,43
  >     <!-- The processor added as a dependency, optional so that it is not passed on to the modules that use this one. -->
  >     <dependency>
  >       <groupId>org.springframework.boot</groupId>
  >       <artifactId>spring-boot-configuration-processor</artifactId>
  >       <optional>true</optional>
  >     </dependency>
processor/plain/tiffinbox-core/pom.xml, against processor/dependency/tiffinbox-core/pom.xml:
  38c38
  <     <!-- The processor added as a dependency, optional so that it is not passed on to the modules that use this one. -->
  ---
  >     <!-- The processor added as a plain dependency: no <optional>, so it is passed on to the modules that use this one. -->
  42d41
  <       <optional>true</optional>
processor/full/pom.xml, against processor/dependency/pom.xml:
  72a73,76
  >           <!-- javac's -proc:full: run annotation processing, with the processors found on the class path. -->
  >           <configuration>
  >             <proc>full</proc>
  >           </configuration>
processor/web/tiffinbox-web/pom.xml, against after/'s tiffinbox-web/pom.xml:
  34a35,47
  >       <!-- The processor path, declared in this module only. -->
  >       <plugin>
  >         <groupId>org.apache.maven.plugins</groupId>
  >         <artifactId>maven-compiler-plugin</artifactId>
  >         <configuration>
  >           <annotationProcessorPaths>
  >             <path>
  >               <groupId>org.springframework.boot</groupId>
  >               <artifactId>spring-boot-configuration-processor</artifactId>
  >             </path>
  >           </annotationProcessorPaths>
  >         </configuration>
  >       </plugin>
```

Every demo file differs from the file it stands in for exactly as its folder says. `processor/dependency/pom.xml` is the
previous tree's root POM byte for byte — the root as it was before the processor path.

## Exercise

`exercise/README.md` — override only the first meal type, to `VEGAN`, through an environment variable; predict the whole
list, then check the record's line (`Props`, port 18689). Measured answers, run exactly as written in a clean shell, in
`exercise/solution/SOLUTION.md` (`TIFFINBOX_MEALTYPES_0=VEGAN` → `mealTypes=[VEGAN]`: the list comes whole from the
environment, not merged with the file's; every index, or the comma form, keeps the other two).

## Found on the way

- **macOS's bash 3.2 cannot parse a `case` inside `$( … )`.** The first `change` capture printed `syntax error near
  unexpected token` lines (and so showed comment lines it was meant to drop), and was still stable across three runs: a
  capture can be steady and wrong. The flag is now set by a `case` outside the substitution; the published capture was
  read line by line before its hash was.
- **An `int` is `java.lang.Integer` in the metadata**, with `"defaultValue": 0`; the list is typed
  `java.util.List<com.tiffinbox.MealType>` and has no default.
- **The probe's "27 jars" does not reproduce here:** it measured the processor as a dependency of web; as an `<optional>`
  dependency of core it never reaches web's `lib/` (26 in A to D). E, the same dependency without `<optional>`, gives 27:
  that is where 27 comes from.
- **`H2`'s URL carries its own `=`** (`DB_CLOSE_DELAY=-1`): the builder first counted the record's components by `=` and
  got six; it now counts `name=` after `[` or `, `.
