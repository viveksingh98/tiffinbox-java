# c5-unit04 — Auto-Configuration, Mechanism First

Course 5 · Spring Boot · Section 1 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**, 2026-09-29.
The change — one annotation, `@EnableAutoConfiguration` on `TiffinBoxApp` — lands in `../c5-tiffinbox`; `after/` is this
unit's frozen copy of the anchor. "Before" is `../c5-unit03/after/`, **copied** to `.harness/before/` and built there, so
this unit never writes into another unit's folder; `receipts.sh` first checks the two trees differ by that one annotation
and nothing else. Clean builds; every number the video speaks is asserted; three runs per capture.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh
```

(`receipts.sh` carries the same two `export` lines at its top. A bare `java` on this Mac is 23.0.1, so `PATH` matters.)
`receipts.sh` **dies** when a capture's md5 differs from `receipts.md5` — it prints the `DIFFERS` line first, so you can
see which capture moved. Maven runs offline when `.m2-demo` already holds everything, and resolves once if it does not.

**What is filtered or masked before hashing (every one, declared):** `quiet()` drops Boot's own log lines — each begins
with a timestamp and carries a pid — and prints how many it dropped (`… N Boot log line(s), M JUL line(s) elided …`).
`defs` keeps only its own ` | ` lines and **masks one token, with `gsub`**: in a definition's "read from", the jar's
absolute path up to the tree's own `tiffinbox-web/target/` becomes `jar:file:<tree>/tiffinbox-web/target/` (the two
trees sit in different folders, so that prefix differs by design; everything after it is compared). `swap` keeps four
lines of a failed start: the exit code, the failure banner, the exception's type, and the first line of Boot's
description (never the raw log, which carries times and absolute paths). No other token is masked.

**Ports (contract §R.10):** count 18542 (before) / 18543 (after) · hook 18544 · swap 18545 · serve 18546 · the exercise
18547 · defs 18548 · the web application 18549. Every one is bound on 127.0.0.1.

Course 4's finale named the sentence — *configuration classes, most of them guarded by conditions, listed in a file,
read by the row-2 hook* — and said the next course would open the file. This unit runs it, and counts "most".

## One annotation, counted — and the file, entry by entry

`harness/AutoConfig count <port>`, before (18542) and after (18543) — `.r-count.out` `8a53690a961d3715c02a87ab7a6d789a`. Each class the imports files
list is marked registered or not, beside **Boot's own verdict** on it, read from `ConditionEvaluationReport`:
`getUnconditionalClasses()` gives "unconditional" (Boot's word: no condition on the class itself); every other class is
"guarded", and its recorded outcomes say "condition held" or "condition failed":

```
@EnableAutoConfiguration on TiffinBoxApp: false
  definitions in all: 12 · yours 6 · listed auto-configuration classes registered 0 · everything else 6
  classes the imports files list: 12 · in Boot's report 0: unconditional 0 · guarded by a condition 0 (held 0 · failed 0)
  of the 0 unconditional, with a condition on one of their own @Bean methods: 0
    not used    not evaluated     SpringApplicationAdminJmxAutoConfiguration
    not used    not evaluated     AopAutoConfiguration
    not used    not evaluated     ApplicationAvailabilityAutoConfiguration
    not used    not evaluated     ConfigurationPropertiesAutoConfiguration
    not used    not evaluated     LifecycleAutoConfiguration
    not used    not evaluated     MessageSourceAutoConfiguration
    not used    not evaluated     PropertyPlaceholderAutoConfiguration
    not used    not evaluated     ProjectInfoAutoConfiguration
    not used    not evaluated     JmxAutoConfiguration
    not used    not evaluated     SslAutoConfiguration
    not used    not evaluated     TaskExecutionAutoConfiguration
    not used    not evaluated     TaskSchedulingAutoConfiguration
  JSON mapper beans, type com.fasterxml.jackson.databind.ObjectMapper: 0
  JSON mapper beans, type tools.jackson.databind.ObjectMapper: not on the class path
… 7 Boot log line(s), 0 JUL line(s) elided …
@EnableAutoConfiguration on TiffinBoxApp: true
  definitions in all: 55 · yours 6 · listed auto-configuration classes registered 9 · everything else 40
  classes the imports files list: 12 · in Boot's report 12: unconditional 6 · guarded by a condition 6 (held 3 · failed 3)
  of the 6 unconditional, with a condition on one of their own @Bean methods: 5
    not used    condition failed  SpringApplicationAdminJmxAutoConfiguration
    registered  condition held    AopAutoConfiguration
    registered  unconditional     ApplicationAvailabilityAutoConfiguration
    registered  unconditional     ConfigurationPropertiesAutoConfiguration
    registered  unconditional     LifecycleAutoConfiguration
    not used    condition failed  MessageSourceAutoConfiguration
    registered  unconditional     PropertyPlaceholderAutoConfiguration
    registered  unconditional     ProjectInfoAutoConfiguration
    not used    condition failed  JmxAutoConfiguration
    registered  unconditional     SslAutoConfiguration
    registered  condition held    TaskExecutionAutoConfiguration
    registered  condition held    TaskSchedulingAutoConfiguration
  JSON mapper beans, type com.fasterxml.jackson.databind.ObjectMapper: 0
  JSON mapper beans, type tools.jackson.databind.ObjectMapper: not on the class path
… 7 Boot log line(s), 0 JUL line(s) elided …
```

Measured: of the **12** listed, **9** registered and **3** not used. Boot's report calls **6 unconditional — and all 6
were registered** (5 of those 6 still guard one of their own `@Bean` methods: "unconditional" is about the class); the
other **6 are guarded** by a condition (3 held, 3 failed). So on TiffinBox's class path, "most of them guarded" is
**half**. No JSON mapper bean: TiffinBox's class path has no Jackson module of Boot's.

The file itself, as it ships inside `spring-boot-autoconfigure-4.1.1.jar` — `.r-imports.out` `f42de7fe356f2f2eaf83028ccd8a5dd9`; `receipts.sh` checks its 12
lines are the count's 12 rows, in the same order:

```
unzip -p after/tiffinbox-web/target/lib/spring-boot-autoconfigure-4.1.1.jar META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports
```
```
org.springframework.boot.autoconfigure.admin.SpringApplicationAdminJmxAutoConfiguration
org.springframework.boot.autoconfigure.aop.AopAutoConfiguration
org.springframework.boot.autoconfigure.availability.ApplicationAvailabilityAutoConfiguration
org.springframework.boot.autoconfigure.context.ConfigurationPropertiesAutoConfiguration
org.springframework.boot.autoconfigure.context.LifecycleAutoConfiguration
org.springframework.boot.autoconfigure.context.MessageSourceAutoConfiguration
org.springframework.boot.autoconfigure.context.PropertyPlaceholderAutoConfiguration
org.springframework.boot.autoconfigure.info.ProjectInfoAutoConfiguration
org.springframework.boot.autoconfigure.jmx.JmxAutoConfiguration
org.springframework.boot.autoconfigure.ssl.SslAutoConfiguration
org.springframework.boot.autoconfigure.task.TaskExecutionAutoConfiguration
org.springframework.boot.autoconfigure.task.TaskSchedulingAutoConfiguration
```

## Added, not edited

`AutoConfig defs 18548` prints every definition, one line each — its kind, and 18 fields: class, scope, lazy, primary,
fallback, candidate, depends-on, factory, arguments, properties, init, destroy, role, abstract, attributes, description,
source, and where it was read from (that path masked, above) — for the tree without the annotation and the tree with
it; `receipts.sh` compares the two dumps line for line —
`.r-added.out` `2f17eb1a9a81b0a8d87d9df806ff79ce`:

```
definitions: before 12 · after 55
the 12 from before, compared field by field after: identical 12 · changed 0 · gone 0
new 43: configuration classes 17 (named in the file 9 · imported by those 8) · @Bean methods 14 · registered by code 12
```

Course 4 called auto-configuration "descriptions, edited". Measured here: **43 added, none edited** — and "everything
else 40" in the count is named: the container's own 6 (as before) + 8 configuration classes the listed ones import + 14
beans from `@Bean` methods + 12 registered by code. These are Boot 4.1.1's counts; they move with versions.

## Who reads the file: the row-2 hook, taken out (A/B/A′, one program)

`AutoConfig hook kept|removed 18544 <label>`: the same `SpringApplication` start three times — the hook kept (A), taken
out after the sources are loaded and before refresh (B), kept again (A′). The application's class loader is a spy that
writes down each request for the imports file and the call stack that made it — `.r-hook.out` `3a62b1f4532b5480f87f4c76d671a9df`:

```
A   hook kept     definitions 55 · yours 6 · tiffinbox.days 30 · listed registered 9 · imports file opened 1x
      when it was opened: yours already registered 6 · the stack from the hook down, 11 frames:
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
… 7 Boot log line(s), 0 JUL line(s) elided …
B   hook removed  definitions 6 · yours 1 · tiffinbox.days null · listed registered 0 · imports file opened 0x
… 3 Boot log line(s), 0 JUL line(s) elided …
A′  hook kept     definitions 55 · yours 6 · tiffinbox.days 30 · listed registered 9 · imports file opened 1x
      when it was opened: yours already registered 6 · the stack from the hook down, 11 frames:
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
… 7 Boot log line(s), 0 JUL line(s) elided …
```

Take the hook out and your six definitions drop to one, your properties file is never read (`tiffinbox.days null`), and
the imports file is **never opened**: the configuration-class post-processor is what processes your `@ComponentScan`,
your `@PropertySource` and your `@Import`s — `@EnableAutoConfiguration` is one of those imports. With the hook, the file
is opened once, by **Boot's selector** (`AutoConfigurationImportSelector.getCandidateConfigurations`), from inside the
parser's deferred step, when all six of yours are already registered. Core Java II's *"nothing registered anything"*
needs its correction here: the imports file **is** a registration, by name — Boot's list, read by Spring's hook.

## The annotations, opened — and the one-annotation swap that fails

`AutoConfig opened` — `.r-opened.out` `57eb477afe0207da8c31ea8b2e2802ec`. Java's own annotations (package `java.lang.annotation`) are counted apart from
Spring's, so the filter is on screen:

```
@EnableAutoConfiguration carries 6: java.lang.annotation 4 [Target, Retention, Documented, Inherited] · Spring 2 [AutoConfigurationPackage, Import(AutoConfigurationImportSelector)]
AutoConfigurationImportSelector is a DeferredImportSelector: true
@SpringBootApplication carries 7: java.lang.annotation 4 [Target, Retention, Documented, Inherited] · Spring 3 [SpringBootConfiguration, EnableAutoConfiguration, ComponentScan]
@SpringBootConfiguration carries 5: java.lang.annotation 3 [Target, Retention, Documented] · Spring 2 [Configuration, Indexed]
@SpringBootApplication's @ComponentScan: basePackages [] · basePackageClasses []
```

The break: `breaks/springbootapplication/TiffinBoxApp.java` replaces TiffinBoxApp's three annotations with
`@SpringBootApplication` (keeping `@PropertySource`); `receipts.sh` builds that copy in `.harness/swap/` and runs it the
way TiffinBox always runs, port first — `.r-swap.out` `8a7c91ea0656082d9d8368f320bab8dd`:

```
java -jar .harness/swap/tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18545
```
```
exit 1
APPLICATION FAILED TO START
org.springframework.beans.factory.UnsatisfiedDependencyException
Parameter 0 of constructor in com.tiffinbox.web.TiffinBoxServer required a bean of type 'com.tiffinbox.CustomerRepository' that could not be found.
```

`@SpringBootApplication`'s scan names no package, so it starts at the package of the class it sits on —
`com.tiffinbox.web` — and never reaches `com.tiffinbox`, where tiffinbox-core's `CustomerRepository` lives. That is why
TiffinBox keeps `@ComponentScan("com.tiffinbox")`.

## One file per module that auto-configures something

Boot 4 splits itself into modules, and a module that auto-configures something brings its own imports file. The
smallest web application — one starter, one class (`webapp/`, `CountApp`, port 18549) — counted, `.r-web.out` `27c7e192de0d28b23dc276ea122b4049`:

```
a Boot web application with one starter:
  spring-boot-autoconfigure-4.1.1.jar           12 classes listed
  spring-boot-http-converter-4.1.1.jar           1 classes listed
  spring-boot-jackson-4.1.1.jar                  1 classes listed
  spring-boot-servlet-4.1.1.jar                  5 classes listed
  spring-boot-tomcat-4.1.1.jar                   5 classes listed
  spring-boot-webmvc-4.1.1.jar                   6 classes listed
  imports files 6 · classes listed 30 · bean definitions 145
  Boot's jars on the class path 14: starters 6, classes in them 0 · code modules 8, with an imports file 6
  code modules without one: spring-boot-4.1.1.jar, spring-boot-web-server-4.1.1.jar
  Boot's report on the 30: unconditional 6 · guarded by a condition 24 (held 11 · failed 13) · registered 17
  JSON mapper beans, type tools.jackson.databind.ObjectMapper: [jacksonJsonMapper] -> tools.jackson.databind.json.JsonMapper
  JSON mapper beans, type com.fasterxml.jackson.databind.ObjectMapper: not on the class path
… 0 Boot log line(s), 0 JUL line(s) elided …
```

Measured: 6 files in the 8 code modules on its class path (the 6 starters hold no classes at all), 30 listed classes —
**24 of them guarded** by a condition — and 145 bean definitions in all, for a web application with nothing of its own
in it. Course 4 said "the file" and "thousands of descriptions". Core Java II said "Spring Boot already has one in the
container" (a JSON mapper): this container holds one, `jacksonJsonMapper`, a Jackson 3 `JsonMapper`, and Jackson 2's
`ObjectMapper` is not on its class path. Measured only; whether Core Java II's line needs a correction is Vivek's call
(ledger P5-P7).

## Nothing else changed

`.r-responses.out` `185ef528bab96ee841e41e9a5990c3f0`

```
the responses with auto-configuration on: 7 · md5 115c36bac276128e245ca57df11c2891
server exit 0
```

## Exercise

`exercise/`: exclude one auto-configuration with `spring.autoconfigure.exclude` — by its short name, then by the name the
file uses — and count again. Measured solution in `exercise/solution/` (short name: 9, silently; full name: 9 → 8,
definitions 55 → 49).
