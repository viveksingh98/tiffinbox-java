# c5-unit04 — Auto-Configuration, Mechanism First

Course 5 · Spring Boot · Section 1 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**, 2026-09-27.
The change — one annotation, `@EnableAutoConfiguration` on `TiffinBoxApp` — lands in `../c5-tiffinbox`; `after/` is this
unit's frozen copy of the anchor, "before" is `../c5-unit03/after/`. Clean builds; every number asserted.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
./receipts.sh
```

Course 4's finale named the sentence — *configuration classes, most of them guarded by conditions, listed in a file,
read by the row-2 hook* — and said the next course would open the file. This unit runs it.

## One annotation, counted — and the file, entry by entry

`harness/AutoConfig count`, before and after (`.r-count.out` `cb041454d8d784492e2a54cea3a79c7f`; Boot's own log lines are dropped and counted):

```
@EnableAutoConfiguration on TiffinBoxApp: false
  definitions in all: 12 · yours 6 · listed auto-configuration classes registered 0 · everything else 6
  classes the imports files list: 12
    not used    SpringApplicationAdminJmxAutoConfiguration
    not used    AopAutoConfiguration
    not used    ApplicationAvailabilityAutoConfiguration
    not used    ConfigurationPropertiesAutoConfiguration
    not used    LifecycleAutoConfiguration
    not used    MessageSourceAutoConfiguration
    not used    PropertyPlaceholderAutoConfiguration
    not used    ProjectInfoAutoConfiguration
    not used    JmxAutoConfiguration
    not used    SslAutoConfiguration
    not used    TaskExecutionAutoConfiguration
    not used    TaskSchedulingAutoConfiguration
… 7 Boot log line(s), 0 JUL line(s) elided …
@EnableAutoConfiguration on TiffinBoxApp: true
  definitions in all: 55 · yours 6 · listed auto-configuration classes registered 9 · everything else 40
  classes the imports files list: 12
    not used    SpringApplicationAdminJmxAutoConfiguration
    registered  AopAutoConfiguration
    registered  ApplicationAvailabilityAutoConfiguration
    registered  ConfigurationPropertiesAutoConfiguration
    registered  LifecycleAutoConfiguration
    not used    MessageSourceAutoConfiguration
    registered  PropertyPlaceholderAutoConfiguration
    registered  ProjectInfoAutoConfiguration
    not used    JmxAutoConfiguration
    registered  SslAutoConfiguration
    registered  TaskExecutionAutoConfiguration
    registered  TaskSchedulingAutoConfiguration
… 7 Boot log line(s), 0 JUL line(s) elided …
```

The file on TiffinBox's class path lists **12** classes; with the annotation, **9 are registered and 3 are not used** —
the conditions decide (unit 05 reads the report that says why).

## The path from the annotation to the hook

(`.r-path.out` `7a1d127c160dc7d726b4f3ae325a96bf`)

```
@EnableAutoConfiguration carries @Import(AutoConfigurationImportSelector)
AutoConfigurationImportSelector is a DeferredImportSelector: true
without ConfigurationClassPostProcessor: definitions 5 · auto-configuration classes 0
… 0 Boot log line(s), 0 JUL line(s) elided …
@SpringBootApplication carries: [SpringBootConfiguration, EnableAutoConfiguration, ComponentScan]
… 0 Boot log line(s), 0 JUL line(s) elided …
```

`@EnableAutoConfiguration` imports a *deferred* import selector; the configuration-class post-processor — Course 4's
row-2 hook — processes it after your own configuration. Take that hook out and not one auto-configuration class is
registered. Core Java II's *"nothing registered anything"* needs its correction here: the imports file **is** a
registration, by name — Boot's list, read by Spring's hook.

## One file per module

Boot 4 splits itself into modules, and each module brings its own imports file. The smallest web application — one
starter, one class (`webapp/`) — counted (`.r-web.out` `a72ea07c5c27364b1e633b55a5cdbc0d`):

```
a Boot web application with one starter:
  spring-boot-autoconfigure-4.1.1.jar           12 classes listed
  spring-boot-http-converter-4.1.1.jar           1 classes listed
  spring-boot-jackson-4.1.1.jar                  1 classes listed
  spring-boot-servlet-4.1.1.jar                  5 classes listed
  spring-boot-tomcat-4.1.1.jar                   5 classes listed
  spring-boot-webmvc-4.1.1.jar                   6 classes listed
  imports files 6 · classes listed 30 · bean definitions 145
… 0 Boot log line(s), 0 JUL line(s) elided …
```

Course 4 said "the file" (unit 32) and "thousands of descriptions" (unit 11). Measured: six files, thirty listed
classes, 145 bean definitions in all, for a web application with nothing of its own in it.

## Nothing else changed

(`.r-responses.out` `d548fa1538774bd772924a7e34f3204a`)

```
the seven responses with auto-configuration on: md5 115c36bac276128e245ca57df11c2891
server exit 0
```

## Exercise

`exercise/`: exclude one auto-configuration with `spring.autoconfigure.exclude` and count again. Measured solution in
`exercise/solution/` (registered 9 → 8, definitions 55 → 49).
