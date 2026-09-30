# c5-unit12 — Write Your Own Starter

Course 5 · Spring Boot · Section 2 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**, 2026-09-29 (every capture
re-run and `= published` again on 2026-09-30, with the exercise's README run as written).
Two projects of this unit's own — a starter, `tiffinbox-spring-boot-starter/`, and a program that has never seen
TiffinBox, `lunch-counter/` (package `com.lunchcounter`) — and the receipts that measure them. **`c5-tiffinbox` is not
changed by this unit** (brief ⚑10): TiffinBox does not consume the starter; the scan trap (§6) uses TiffinBoxApp's
annotation shape, checked against the living anchor (`../c5-tiffinbox`), instead.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 6 captures, 3 runs each; every number the video says is asserted; a published-md5 mismatch stops it
```

`receipts.sh` carries the same two `export` lines at its top (a bare `java` on this Mac is 23.0.1). It **dies** when a
capture's md5 differs from `receipts.md5` — it prints the `DIFFERS` line first, so you can see which capture moved;
`./receipts.sh --publish` rewrites `receipts.md5` and is the only thing that does. Tested: with `starter` set to
`000…` in `receipts.md5`, it printed `DIFFERS from the published 00000000000000000000000000000000` and exited 1. It
refuses to run twice at once in this folder (`.r-lock`): two runs would share `.harness/`, the starter's install in `$M2`
and `lunch-counter`'s `target/`; nothing it starts outlives its command, so its exit trap only drops the lock.

**Maven.** Every build runs `mvn -o` first against this unit's own repository, `.m2-demo` (`$M2` below), and resolves
from Maven Central only if that fails; Maven's own output goes to `.harness/mvn.log`, and a capture keeps the exit code.
From a fresh clone `.m2-demo` does not exist (it is git-ignored), so the first run resolves once. Here it was seeded from
the Section 2 probe's repository (`/private/tmp/claude-501/c5s2/m2`: `c5-unit01..05/.m2-demo` merged, plus what the
probe added — the configuration processor, the validation artifacts, the install plugin and its resolver jars), without
the probe's own install of the starter, and with the 11 `_remote.repositories` markers that named the probe's `userm2`
repository deleted — `mvn -o` refuses an artifact recorded as coming from a repository it does not know. Each of the
fifteen builds a run makes prints `built <project> (<goals>) · offline: yes` (or `no - …`) on the terminal, so a run that
went online is never silent (the captures are unchanged by it). `starter`
deletes `$M2/com/tiffinbox/tiffinbox-spring-boot-starter/` before it installs, so the jar `lunch-counter` resolves is
always the one this run built.

**Ports: none.** `lunch-counter` has no web layer and TiffinBox is never served here; 18720-18729 (brief ⚑11) stay free.

## What is where

- `tiffinbox-spring-boot-starter/` — **one module** (⚑10): `pom.xml` (Boot's parent 4.1.1; `spring-boot-autoconfigure`;
  the configuration processor in `annotationProcessorPaths`, no version), `Kitchen`, the `KitchenProperties` record
  (`tiffinbox.kitchen.*`, `@DefaultValue`), `KitchenAutoConfiguration` (`@AutoConfiguration`,
  `@EnableConfigurationProperties`, one `@Bean @ConditionalOnMissingBean`), and a one-line
  `META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports`.
- `lunch-counter/` — `pom.xml` (`spring-boot-starter` + the starter; runnable the way TiffinBox's jar is: `Main-Class`
  and a `Class-Path` into `target/lib`) and `LunchCounter.java` (`@SpringBootApplication`; prints the `Kitchen` beans
  and the one it gets).
- `own-kitchen/OwnKitchen.java` — B's one file. `receipts.sh` copies it into a **working copy** of lunch-counter under
  `.harness/backoff/`, never into `lunch-counter/`.
- `harness/trap/` — C `TiffinBoxShape` (TiffinBoxApp's `@Configuration`, `@EnableAutoConfiguration`,
  `@ComponentScan("com.tiffinbox")`) and D `SpringBootShape` (`@SpringBootApplication(scanBasePackages =
  "com.tiffinbox")`), each with its own `@Bean Kitchen myKitchen()`, printing through `Kitchens`. Package `trap`, outside
  `com.tiffinbox`, so the scan of `com.tiffinbox` finds only the starter's classes.
- `harness/spy/WhoReads.java` — starts `LunchCounter`'s configuration class through `SpringApplication` with a class
  loader that writes down every request for the imports file (who asked, whether the row-2 hook was on the stack, which
  files came back, how many the caller took); it dies if Boot did not use it.
- `exercise/` — the task, and three measured answers.

## The commands — whole, as the video shows them

- From this folder: `M2="$PWD/.m2-demo"`, then
  `(cd tiffinbox-spring-boot-starter && mvn -q -DskipTests clean install -Dmaven.repo.local="$M2")` and
  `(cd lunch-counter && mvn -q -DskipTests clean package -Dmaven.repo.local="$M2")` (`receipts.sh` adds `-o -B` first).
- In `lunch-counter/`: `java -jar target/lunch-counter-1.0.0.jar`, the same with `--tiffinbox.kitchen.cooks=5`, and the
  same with `--debug`. (lunch-counter reads no positional argument, so a Boot flag can go anywhere.)
- After `./receipts.sh`, from this folder: `CP="$(cat .harness/classpath)"` — `.harness/classes` (the harness, compiled)
  + `lunch-counter/target/lunch-counter-1.0.0.jar` + the 22 jars in `lunch-counter/target/lib` — then
  `java -cp "$CP" spy.WhoReads`, `java -cp "$CP" trap.TiffinBoxShape --debug`, `java -cp "$CP" trap.SpringBootShape --debug`.
  Every capture that runs on `$CP` prints its make-up, and that TiffinBox's own jars on it: 0.

## Filters and masks (declared; `sub`/`gsub` only where awk touches a kept line — here it touches none)

1. **What a run keeps:** its own lines (the program's `System.out`), plus — where the capture is about it — the condition
   report's entry for the starter's one `@Bean` method (`KitchenAutoConfiguration#kitchen`, in whichever list it lands).
2. **What it leaves out, counted:** Boot's banner (the ten lines from the blank line above its art to the blank line
   below `:: Spring Boot ::`, recognised by both ends — a program may print before it), every log line (a timestamp
   first; they carry times and pids), and the rest of the condition report. Each run ends on one trailer, e.g.
   `exit 0 · … 13 lines not shown: Boot's banner 10 · its log 3 …`; `show()` dies if banner + log + report + kept lines
   do not add up to the whole output.
3. **The one mask:** the spy prints a jar's file name where the class loader returned a whole `jar:file:…!/…` URL
   (`String.replaceAll`, in `WhoReads.jar()`): the claim is which jars, never where they sit.
4. Maven's output never reaches a capture (see above); `cmp` checks and exit codes do.
5. On a slide, a panel that shows part of a capture ends on `… N of this capture's M lines not shown …`, and a cut in the
   middle of a panel is named where it is.

## 1 · The starter: four files, installed

(`.r-starter.out` `65602b74f6138df0d1911e8d565498e3`)

```
the starter's files, pom.xml aside (tiffinbox-spring-boot-starter/):
  src/main/java/com/tiffinbox/autoconfigure/KitchenAutoConfiguration.java
  src/main/java/com/tiffinbox/autoconfigure/KitchenProperties.java
  src/main/java/com/tiffinbox/kitchen/Kitchen.java
  src/main/resources/META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports
the imports file, whole (1 line):
  com.tiffinbox.autoconfigure.KitchenAutoConfiguration
KitchenAutoConfiguration.java, from its first annotation:
  @AutoConfiguration
  @EnableConfigurationProperties(KitchenProperties.class)
  public class KitchenAutoConfiguration {
  
      @Bean
      @ConditionalOnMissingBean
      Kitchen kitchen(KitchenProperties props) {
          return new Kitchen(props.name(), props.cooks());
      }
  }
KitchenProperties.java, from its first annotation:
  @ConfigurationProperties("tiffinbox.kitchen")
  public record KitchenProperties(@DefaultValue("TiffinBox kitchen") String name, @DefaultValue("3") int cooks) {
  }
$ (cd tiffinbox-spring-boot-starter && mvn -q -DskipTests clean install -Dmaven.repo.local="$M2")
exit 0
$M2/com/tiffinbox/tiffinbox-spring-boot-starter/1.0.0/ now holds: tiffinbox-spring-boot-starter-1.0.0.jar · tiffinbox-spring-boot-starter-1.0.0.pom
the jar there is byte for byte target/tiffinbox-spring-boot-starter-1.0.0.jar: yes
the jar's files, directories aside (8):
  META-INF/MANIFEST.MF
  META-INF/maven/com.tiffinbox/tiffinbox-spring-boot-starter/pom.properties
  META-INF/maven/com.tiffinbox/tiffinbox-spring-boot-starter/pom.xml
  META-INF/spring-configuration-metadata.json
  META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports
  com/tiffinbox/autoconfigure/KitchenAutoConfiguration.class
  com/tiffinbox/autoconfigure/KitchenProperties.class
  com/tiffinbox/kitchen/Kitchen.class
its .class files: 3
inside it, META-INF/spring-configuration-metadata.json: groups 1 · properties 2
  tiffinbox.kitchen.cooks  java.lang.Integer  default 3                    "how many cooks it has"
  tiffinbox.kitchen.name   java.lang.String   default "TiffinBox kitchen"  "what the kitchen is called"
```

Three classes and a one-line file. The configuration class declares one bean, guarded by one condition, written bare —
`@ConditionalOnMissingBean` takes its type from the method's return type (the report below prints `types:
com.tiffinbox.kitchen.Kitchen`). `mvn install` puts the jar into `$M2`, byte for byte the one it built. Inside, besides
the three classes and the imports file, and Maven's own three (the manifest, `pom.xml`, `pom.properties`): the metadata
file the configuration processor generated from the record — both keys, their types, the `@DefaultValue`s (3,
"TiffinBox kitchen") and the record's `@param` text as descriptions. The processor runs because it is on the compiler's
processor path (`annotationProcessorPaths`), not because it is a dependency (brief finding 7).

## 2 · lunch-counter: one extra dependency, a kitchen it never declared

(`.r-consumer.out` `964f389c5f9b296638756ece7356d70d`)

```
lunch-counter's dependencies, as its pom.xml declares them (2):
  org.springframework.boot:spring-boot-starter
  com.tiffinbox:tiffinbox-spring-boot-starter:1.0.0
its sources: 1 file · @Bean methods in them: 0
  src/main/java/com/lunchcounter/LunchCounter.java
LunchCounter.java, from its first annotation:
  @SpringBootApplication
  public class LunchCounter {
      public static void main(String[] args) {
          try (var ctx = SpringApplication.run(LunchCounter.class, args)) {
              System.out.println("Kitchen beans: " + Arrays.toString(ctx.getBeanNamesForType(Kitchen.class))
                      + " -> " + ctx.getBean(Kitchen.class).describe());
          }
      }
  }
$ (cd lunch-counter && mvn -q -DskipTests clean package -Dmaven.repo.local="$M2")
exit 0
target/lib/tiffinbox-spring-boot-starter-1.0.0.jar is byte for byte the jar the starter's build made: yes
the class path, as the jar's manifest names it: 22 jars, all in target/lib · TiffinBox's own jars among them: 0
.class files: tiffinbox-spring-boot-starter-1.0.0.jar 3 · Boot's own starters on this class path: spring-boot-starter-4.1.1.jar 0 · spring-boot-starter-logging-4.1.1.jar 0
the jars on this class path holding META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports: 2 of 23
  spring-boot-autoconfigure-4.1.1.jar      12 lines
  tiffinbox-spring-boot-starter-1.0.0.jar   1 line
$ java -jar target/lunch-counter-1.0.0.jar
Kitchen beans: [kitchen] -> TiffinBox kitchen with 3 cooks
exit 0 · … 13 lines not shown: Boot's banner 10 · its log 3 …
$ java -jar target/lunch-counter-1.0.0.jar --tiffinbox.kitchen.cooks=5
Kitchen beans: [kitchen] -> TiffinBox kitchen with 5 cooks
exit 0 · … 13 lines not shown: Boot's banner 10 · its log 3 …
```

lunch-counter's one class has no `@Bean` method; the kitchen comes from the starter. The jar in its `target/lib` is byte
for byte the starter's build — resolved from `$M2`, where `mvn install` put it. **Boot's own starters on this class path
hold no code** (0 classes each); this one holds 3: it carries its own configuration (unit 03's "a starter holds no code"
was measured on Boot's own starters, and is scoped so). **Two of the 23 jars carry an imports file under the same
name**, and on a class path both are read. (Not ledger P15: Course 3's setting merges `META-INF/services` when jars are
flattened into one, and nothing here is merged — what one jar does with them is the next section's first lesson, P15's
owner.) One property on the command line gives 5 cooks.

## 3 · The report: the method is guarded, the class is not

(`.r-report.out` `04578477a01e81ff629b9d047fe0c795`)

```
$ java -jar target/lunch-counter-1.0.0.jar --debug
Kitchen beans: [kitchen] -> TiffinBox kitchen with 3 cooks
   KitchenAutoConfiguration#kitchen matched:
      - @ConditionalOnMissingBean (types: com.tiffinbox.kitchen.Kitchen; SearchStrategy: all) did not find any beans (OnBeanCondition)
exit 0 · … 160 lines not shown: Boot's banner 10 · its log 7 · the rest of its report 143 …
the report's 4 lists: positive matches 16 · negative matches 13 · exclusions 0 · unconditional classes 7
the starter's class in this report: under unconditional classes 1 · as a class under positive or negative matches 0 · its @Bean method, #kitchen, under positive matches 1
every line of both imports files, as this report files it:
  spring-boot-autoconfigure-4.1.1.jar      12: unconditional 6 · matched 3 · did not match 3 · not in the report 0
  tiffinbox-spring-boot-starter-1.0.0.jar   1: unconditional 1 · matched 0 · did not match 0 · not in the report 0
```

With `--debug`, the report's four lists: 16 positive matches, 13 negative, 0 exclusions, 7 unconditional classes — Boot's
6 plus the starter's class. The starter's **method** is a positive match (`did not find any beans`); its **class** is
under Unconditional classes and nowhere else: the condition guards the method, not the class (§R.5). And the report
files every line of both imports files — Boot's 12 (6 · 3 · 3) and ours (1) — with 0 lines "not in the report": both
files were read.

## 4 · Who reads the file: the row-2 hook, both files

(`.r-hook.out` `e9b07c27b9bd7b0c446e953bb7f4209f`)

```
$CP: .harness/classes (harness/, compiled) + lunch-counter/target/lunch-counter-1.0.0.jar + the 22 jars in lunch-counter/target/lib · TiffinBox's own jars on it: 0
$ java -cp "$CP" spy.WhoReads
requests for META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports: 1
  1  asked by ImportCandidates.findUrlsInClasspath, called from ImportCandidates.load · inside the row-2 hook: yes
     files handed back 2 · taken 2: spring-boot-autoconfigure-4.1.1.jar, tiffinbox-spring-boot-starter-1.0.0.jar
     the stack from the hook down, 11 frames:
       ConfigurationClassPostProcessor.postProcessBeanDefinitionRegistry
       ConfigurationClassPostProcessor.processConfigBeanDefinitions
       ConfigurationClassParser.parse
       ConfigurationClassParser$DeferredImportSelectorHandler.process
       ConfigurationClassParser$DeferredImportSelectorGroupingHandler.processGroupImports
       ConfigurationClassParser$DeferredImportSelectorGrouping.getImports
       AutoConfigurationImportSelector$AutoConfigurationGroup.process
       AutoConfigurationImportSelector.getAutoConfigurationEntry
       AutoConfigurationImportSelector.getCandidateConfigurations
       ImportCandidates.load
       ImportCandidates.findUrlsInClasspath
exit 0 · … 3 lines not shown: its log 3 …
```

The class loader is asked for the imports file **once**, by Boot's `ImportCandidates.load`, from
`AutoConfigurationImportSelector.getCandidateConfigurations`, inside `ConfigurationClassPostProcessor
.postProcessBeanDefinitionRegistry` — Course 4's row-2 hook; the same 11-frame path unit 04 traced for Boot's own file.
It hands back **2** files and the caller takes **2**. (Why not twice: `@SpringBootApplication`'s scan carries
`AutoConfigurationExcludeFilter`, which can read the file too — but the scan's own declaring-class filter is checked
first and excludes `LunchCounter` before it is asked; `javap` on spring-context 7.0.9: `addExcludeFilter` inserts at index
0, and `ComponentScanAnnotationParser` adds the declaring-class filter last.)

## 5 · It backs off — A, B, A′

(`.r-backoff.out` `5bb59194093c49361f4c21a27f58ff8d`)

```
A   lunch-counter as shipped
  its sources: LunchCounter.java
  built with lunch-counter's own mvn command: exit 0
$ java -jar target/lunch-counter-1.0.0.jar --debug
Kitchen beans: [kitchen] -> TiffinBox kitchen with 3 cooks
   KitchenAutoConfiguration#kitchen matched:
      - @ConditionalOnMissingBean (types: com.tiffinbox.kitchen.Kitchen; SearchStrategy: all) did not find any beans (OnBeanCondition)
exit 0 · … 160 lines not shown: Boot's banner 10 · its log 7 · the rest of its report 143 …
B   plus one file, src/main/java/com/lunchcounter/OwnKitchen.java
  OwnKitchen.java, from its first annotation:
    @Configuration
    class OwnKitchen {
        @Bean
        Kitchen myKitchen() {
            return new Kitchen("Lunch counter's own kitchen", 2);
        }
    }
  its sources: LunchCounter.java OwnKitchen.java
  built with lunch-counter's own mvn command: exit 0
$ java -jar target/lunch-counter-1.0.0.jar --debug
Kitchen beans: [myKitchen] -> Lunch counter's own kitchen with 2 cooks
   KitchenAutoConfiguration#kitchen:
      Did not match:
         - @ConditionalOnMissingBean (types: com.tiffinbox.kitchen.Kitchen; SearchStrategy: all) found beans of type 'com.tiffinbox.kitchen.Kitchen' myKitchen (OnBeanCondition)
exit 0 · … 160 lines not shown: Boot's banner 10 · its log 7 · the rest of its report 143 …
A′  that file deleted again: A, re-run
  its sources: LunchCounter.java
  built with lunch-counter's own mvn command: exit 0
$ java -jar target/lunch-counter-1.0.0.jar --debug
Kitchen beans: [kitchen] -> TiffinBox kitchen with 3 cooks
   KitchenAutoConfiguration#kitchen matched:
      - @ConditionalOnMissingBean (types: com.tiffinbox.kitchen.Kitchen; SearchStrategy: all) did not find any beans (OnBeanCondition)
exit 0 · … 160 lines not shown: Boot's banner 10 · its log 7 · the rest of its report 143 …
```

All three in **one working copy** of lunch-counter, built with lunch-counter's own `mvn` command and run with the same
`java -jar … --debug`. **A** the starter's kitchen, and the condition "did not find any beans". **B** one more file in
`com.lunchcounter` — `OwnKitchen`, a `@Configuration` with `@Bean Kitchen myKitchen()` — and the starter steps aside:
`[myKitchen]`, and the report says the condition `found beans of type 'com.tiffinbox.kitchen.Kitchen' myKitchen`. **A′**
the file deleted, built and run again: `receipts.sh` checks the A′ block equals the A block, line for line.

## 6 · The break — C, TiffinBox's own scan · D, `@SpringBootApplication`

(`.r-scan.out` `1bae17deca2c15b1f215ecc014e85e81`)

```
$CP: .harness/classes (harness/, compiled) + lunch-counter/target/lunch-counter-1.0.0.jar + the 22 jars in lunch-counter/target/lib · TiffinBox's own jars on it: 0
C   TiffinBoxApp's shape - a plain @ComponentScan of com.tiffinbox - plus a Kitchen of its own
  harness/trap/TiffinBoxShape.java: @Configuration · @EnableAutoConfiguration · @ComponentScan("com.tiffinbox") · @Bean Kitchen myKitchen()
$ java -cp "$CP" trap.TiffinBoxShape --debug
KitchenAutoConfiguration carries @Component: @AutoConfiguration → @Configuration → @Component
its scan: basePackages [com.tiffinbox] · exclude filters []
Kitchen beans, in the order they were registered: [kitchen, myKitchen]
the starter's configuration class, registered as: kitchenAutoConfiguration
asking for one Kitchen: NoUniqueBeanDefinitionException: No qualifying bean of type 'com.tiffinbox.kitchen.Kitchen' available: expected single matching bean but found 2: kitchen,myKitchen
   KitchenAutoConfiguration#kitchen matched:
      - @ConditionalOnMissingBean (types: com.tiffinbox.kitchen.Kitchen; SearchStrategy: all) did not find any beans (OnBeanCondition)
exit 0 · … 160 lines not shown: Boot's banner 10 · its log 7 · the rest of its report 143 …
D   the same root and the same Kitchen, through @SpringBootApplication
  harness/trap/SpringBootShape.java: @SpringBootApplication(scanBasePackages = "com.tiffinbox") · @Bean Kitchen myKitchen()
$ java -cp "$CP" trap.SpringBootShape --debug
KitchenAutoConfiguration carries @Component: @AutoConfiguration → @Configuration → @Component
its scan: basePackages [com.tiffinbox] · exclude filters [TypeExcludeFilter, AutoConfigurationExcludeFilter]
AutoConfigurationExcludeFilter, asked about com.tiffinbox.autoconfigure.KitchenAutoConfiguration: match true
Kitchen beans, in the order they were registered: [myKitchen]
the starter's configuration class, registered as: com.tiffinbox.autoconfigure.KitchenAutoConfiguration
asking for one Kitchen: TiffinBox's own kitchen with 2 cooks
   KitchenAutoConfiguration#kitchen:
      Did not match:
         - @ConditionalOnMissingBean (types: com.tiffinbox.kitchen.Kitchen; SearchStrategy: all) found beans of type 'com.tiffinbox.kitchen.Kitchen' myKitchen (OnBeanCondition)
exit 0 · … 160 lines not shown: Boot's banner 10 · its log 7 · the rest of its report 143 …
```

**C** (labelled C per §R.1: a variant, not A′) is TiffinBoxApp's annotation shape — `receipts.sh` checks its three
scan-shaping annotations are exactly the living anchor's (`../c5-tiffinbox/…/TiffinBoxApp.java`: `@Configuration`,
`@EnableAutoConfiguration`, `@ComponentScan(…)` with whatever arguments it carries; `@EnableConfigurationProperties` aside,
as it shapes no scan), and fails if that class ever carries `@SpringBootApplication` — with a Kitchen of its own. The
recap's line is scoped to this shape ("scanned the way TiffinBox scans"): with a scan that reaches your own configuration
first, the outcome can differ, and that is not measured here. Its plain `@ComponentScan("com.tiffinbox")` has no exclude filters, and `KitchenAutoConfiguration`
carries `@Component` (through `@AutoConfiguration → @Configuration`), so the scan registers the auto-configuration as an
ordinary configuration class — under the scan's name, `kitchenAutoConfiguration` — and its kitchen **first**: the
condition runs before `myKitchen` exists, and the report reads exactly as in A, `did not find any beans`. Exit 0, two
kitchens; asking the container for one throws `NoUniqueBeanDefinitionException`. **D** is the same root through
`@SpringBootApplication`: its scan carries `AutoConfigurationExcludeFilter`, which answers `match true` for the starter's
class (it matches a `@Configuration` class that is annotated `@AutoConfiguration` or listed in an imports file — `javap`,
Boot 4.1.1: `isConfiguration && isAutoConfiguration`), so the class arrives through the file, under its full name, after
`myKitchen`: one kitchen, the application's. The rule, measured: **an auto-configuration must never be component-scanned.**

## Exercise

`exercise/README.md` — give the starter's kitchen your own name and five cooks, touching no Java in lunch-counter. Three
answers (a file, the command line, the environment), each run with the README's commands exactly as written, in
`exercise/solution/SOLUTION.md`.

## Pays (ledger) and the brief

Not P15 (RED #31): C3/23's setting is the shade plugin's `ServicesResourceTransformer`, which merges `META-INF/services/*`
when jars are flattened into one; here two jars carry one name and both are read, on a class path, and nothing is merged —
P15 stays with the ledger's U13 · P-C4-32a and P30's four parts, written instead of read (a configuration class · a condition — on its
method, the class unconditional · listed in a file · read by the row-2 hook) · unit 03's "a starter holds no code",
scoped to Boot's own starters. The brief's A/B/A′ and C/D are kept as labelled; the brief's "a property" run is in
`consumer`, unlettered.
