# c5-unit01 — From Context to Application

Course 5 · Spring Boot · Section 1 "What Boot Actually Is" · **the first unit of the course.** Verified on **JDK 25.0.4.1,
Apache Maven 3.9.16, Spring Boot 4.1.1 (Spring Framework 7.0.9)**, macOS 27.0, on 2026-09-29 (re-measured after the
Section 1 RED review, `spring-boot/_briefs/RED-C5-S1-2026-09-27.md`).
The change lands in the long-lived project, `../c5-tiffinbox`. These receipts measure **`after/`** — this unit's frozen
copy of the anchor as unit 01 left it — against **`../c4-tiffinbox`**, frozen at Course 4's end, so later units' changes
to the anchor cannot move them. Builds are `clean` builds: `copy-dependencies` never deletes a jar, so a `lib/` built
before a version change would hold both versions.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # builds both, runs every capture 3 times, compares each hash with receipts.md5, asserts every number
```

`receipts.sh` carries the same two `export` lines at its top (contract §R.9), so it also runs on its own. Maven runs
offline first (`-o`) against this folder's `.m2-demo/`, and resolves online only if something is missing.

**How a capture becomes a receipt.** The `.r-*.out` captures are not committed: `receipts.sh` regenerates them, requires
three identical runs, and compares each hash with `receipts.md5`. A hash that **differs stops the run** (it prints
`DIFFERS from the published …` first, and says what to suspect: another JDK, Maven or locale, a busy port, edited
sources); a capture with **no** published hash also fails the run, at the end. Every check reads a line the program
computed, never a label `receipts.sh` prints unconditionally, and each check is tagged with the spoken words it pays for.

**The mask** (`mask()` in `receipts.sh`, used on the `beans` capture and on the logging capture's first route line).
Boot's log line is `<ISO time> <LEVEL> <pid> --- [<thread>] <logger> : <message>`. Four tokens are **replaced in place**
with awk's `sub`/`gsub`, so Boot's own padding survives: the ISO timestamp → `<time>`; the process id before `---` →
`<pid>`; `with PID <n> (<path …>)` → `with PID <pid> (<path>)`; `in <n> seconds (process running for <n>)` →
`in <s> seconds (process running for <s>)`. Plain Spring logs through JUL, whose two-line records open with a
locale-dependent date line; that header line is dropped. The mask's last line counts both: `… N JUL header line(s)
elided; M Boot line(s) with time and pid masked …`. The harness JVMs run with `-Duser.language=en -Duser.country=US`
(JUL's header is locale-dependent); the servers run exactly as a viewer types them, with no extra flag.

**Ports** (contract §R.10, unit 01 = 18521-18529): 18521 both servers, one after the other · 18523/18524 the beans
harness · 18525 the logging runs · 18526 the shutdown-hook harness · 18527/18528 the exercise. The exercise's second
command lands on 18425 — the port in `tiffinbox.properties` — which is its lesson.

## The run command, and the same seven responses

Both projects are served the way the last course documented it — in the project's `tiffinbox-web/target`,
`java -jar tiffinbox-web-1.0.0.jar <port>` — on the same port, one after the other. The two captures are byte-identical:
`.r-before.out` and `.r-after.out` both `50cef8401efffbd8e2028a0f9f72f23e`.

```
$ java -jar tiffinbox-web-1.0.0.jar 18521
GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
POST  /shutdown   -> 200 application/json  {"stopping":true}
  (server exit 0, 0 listeners left)
```

Hashed on their own, beside the command each was started with (`.r-identical.out` `804506454073112e2c17d63cfbe39e22`):

```
the command, both times (each project, in its tiffinbox-web/target):
  Course 4, a context you build      $ java -jar tiffinbox-web-1.0.0.jar 18521
  Course 5, SpringApplication.run    $ java -jar tiffinbox-web-1.0.0.jar 18521
the seven responses (status, content type, body), hashed on their own:
  Course 4, a context you build      7 lines  md5 115c36bac276128e245ca57df11c2891
  Course 5, SpringApplication.run    7 lines  md5 115c36bac276128e245ca57df11c2891
```

## What changed: three files

(`.r-changes.out` `0623cc41111419ba536171e1e0a13d41`)

```
files compared (README aside): 14 · changed: pom.xml tiffinbox-web/pom.xml tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
pom.xml, every changed line but comments and blanks (6 of those not shown):
+  <parent>
+    <groupId>org.springframework.boot</groupId>
+    <artifactId>spring-boot-starter-parent</artifactId>
+    <version>4.1.1</version>
+    <relativePath/>
+  </parent>
-    <maven.compiler.release>25</maven.compiler.release>
+    <java.version>25</java.version>
-      <dependency>
-        <groupId>org.springframework</groupId>
-        <artifactId>spring-framework-bom</artifactId>
-        <version>7.0.9</version>
-        <type>pom</type>
-        <scope>import</scope>
-      </dependency>
tiffinbox-web/pom.xml, every changed line but comments and blanks (0 of those not shown):
+    <dependency>
+      <groupId>org.springframework.boot</groupId>
+      <artifactId>spring-boot-starter</artifactId>
+    </dependency>
TiffinBoxServer.java, every changed line:
-import org.springframework.context.annotation.AnnotationConfigApplicationContext;
+import org.springframework.boot.SpringApplication;
-        var context = new AnnotationConfigApplicationContext(TiffinBoxApp.class);
-        context.registerShutdownHook();
+        SpringApplication.run(TiffinBoxApp.class, args);
```

The root POM inherits `spring-boot-starter-parent:4.1.1`, swaps `maven.compiler.release` for the `java.version` the
parent reads, and drops the Spring Framework BOM import (the parent manages Spring's versions now); `tiffinbox-web/pom.xml`
adds `spring-boot-starter`. The six comment and blank lines the capture does not show are the two POM comments that
explain the change.

## The same beans — and what Boot added

`harness/WhatBootAdded` starts the Boot-converted project both ways, one JVM each. Every definition lands in exactly one
group, and each group's filter is printed beside its count (`.r-beans.out` `0638dc2e9b46fc98770fdb0e81f18bd5`):

```
INFO: orders cooked:  120
INFO: kitchen value:  24300
INFO: routes mapped:  [GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown]
INFO: TiffinBox listening on http://127.0.0.1:18523
new AnnotationConfigApplicationContext(TiffinBoxApp.class):
  your definitions (6): [customerRepository, dashboard, database, orderQueue, tiffinBoxApp, tiffinBoxServer]
  auto-configuration definitions (type name contains AutoConfiguration): 0
  Spring's own definitions (named org.springframework.context.*): 5
  Boot's own definitions (named org.springframework.boot.*): 0 []
  any other definitions: 0
  property sources, in the order they are asked: [systemProperties, systemEnvironment, class path resource [tiffinbox.properties]]
… 4 JUL header line(s) elided; 0 Boot line(s) with time and pid masked …

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/

 :: Spring Boot ::                (v4.1.1)

<time>  INFO <pid> --- [           main] com.tiffinbox.harness.WhatBootAdded      : Starting WhatBootAdded using Java 25.0.4.1 with PID <pid> (<path>)
<time>  INFO <pid> --- [           main] com.tiffinbox.harness.WhatBootAdded      : No active profile set, falling back to 1 default profile: "default"
<time>  INFO <pid> --- [           main] tiffinbox                                : orders cooked:  120
<time>  INFO <pid> --- [           main] tiffinbox                                : kitchen value:  24300
<time>  INFO <pid> --- [           main] tiffinbox                                : routes mapped:  [GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown]
<time>  INFO <pid> --- [           main] tiffinbox                                : TiffinBox listening on http://127.0.0.1:18524
<time>  INFO <pid> --- [           main] com.tiffinbox.harness.WhatBootAdded      : Started WhatBootAdded in <s> seconds (process running for <s>)
SpringApplication.run(TiffinBoxApp.class, args):
  your definitions (6): [customerRepository, dashboard, database, orderQueue, tiffinBoxApp, tiffinBoxServer]
  auto-configuration definitions (type name contains AutoConfiguration): 0
  Spring's own definitions (named org.springframework.context.*): 5
  Boot's own definitions (named org.springframework.boot.*): 1 [org.springframework.boot.autoconfigure.internalCachingMetadataReaderFactory]
  any other definitions: 0
  property sources, in the order they are asked: [configurationProperties, commandLineArgs, systemProperties, systemEnvironment, random, applicationInfo, class path resource [tiffinbox.properties]]
… 0 JUL header line(s) elided; 7 Boot line(s) with time and pid masked …
```

Your six definitions are identical both ways, and **no auto-configuration happens**. `SpringApplication.run` alone
adds the banner, Boot's log format, four property sources — `configurationProperties`, `commandLineArgs`, `random`,
`applicationInfo` — and **one definition, Boot's own**: `org.springframework.boot.autoconfigure.internalCachingMetadataReaderFactory`.
Auto-configuration needs one more annotation (unit 04).

## SpringApplication's second list: META-INF/spring.factories

`harness/WhatRunLoads` builds `new SpringApplication(TiffinBoxApp.class)` and prints what it holds before `run()`;
`receipts.sh` looks each name up in the class path's `META-INF/spring.factories` files, shows two entries, and reads the
bean name one initializer registers with `javap -constants` (`.r-factories.out` `d33bd2b619308b4d41ae03d81e066f41`):

```
what a new SpringApplication(TiffinBoxApp.class) holds before run(), each looked up in META-INF/spring.factories:
  initializers  5 held · 5 of 5 named in a spring.factories file on the class path
  listeners     7 held · 7 of 7 named in a spring.factories file on the class path
two of those entries, as the files write them:
  spring-boot-autoconfigure-4.1.1.jar, line 2: org.springframework.context.ApplicationContextInitializer=\
  spring-boot-autoconfigure-4.1.1.jar, line 3: org.springframework.boot.autoconfigure.SharedMetadataReaderFactoryContextInitializer,\
  spring-boot-4.1.1.jar, line 39: org.springframework.context.ApplicationListener=\
  spring-boot-4.1.1.jar, line 43: org.springframework.boot.context.logging.LoggingApplicationListener,\
the bean name that initializer registers (javap -constants):
  SharedMetadataReaderFactoryContextInitializer.BEAN_NAME = "org.springframework.boot.autoconfigure.internalCachingMetadataReaderFactory"
```

That `BEAN_NAME` is the one definition Boot added above (asserted). `LoggingApplicationListener`, listed the same way,
is the listener behind the logging break below: it moves Java's logging onto Logback, and from then on Logback decides
the levels.

## Who closes the context: the line Boot's `run` replaced

`harness/WhoCloses` starts TiffinBox plus one `goodbye.Goodbye` bean — outside `com.tiffinbox`, so the scan never finds
it — then calls `System.exit(0)`; nobody calls `close()`. `Goodbye`'s `@PreDestroy` prints only if a shutdown hook
closes the context (`.r-hook.out` `441c331f7a2c687991fec68ffb37546b`):

```
TiffinBox + one Goodbye bean, then System.exit(0) - nobody calls close():
  new AnnotationConfigApplicationContext(...)                        exit 0 · @PreDestroy did not run
  new AnnotationConfigApplicationContext(...).registerShutdownHook() exit 0 · @PreDestroy ran
  SpringApplication.run(...)                                         exit 0 · @PreDestroy ran
```

Course 4's second line, `registerShutdownHook()`, is what made the difference; `SpringApplication.run` registers the
hook itself.

## The price

(`.r-price.out` `407c1ebc0847d6059717940c3295e394`)

```
jars the application needs at run time: 15 -> 26
  added:   jul-to-slf4j log4j-api log4j-to-slf4j logback-classic logback-core slf4j-api snakeyaml spring-boot spring-boot-autoconfigure spring-boot-starter spring-boot-starter-logging
  version moved: commons-logging-1.3.5.jar -> commons-logging-1.3.6.jar  jackson-annotations-2.22.jar -> jackson-annotations-2.21.jar  jackson-core-2.22.2.jar -> jackson-core-2.21.5.jar  jspecify-1.0.0.jar -> jspecify-1.0.1.jar  micrometer-commons-1.16.7.jar -> micrometer-commons-1.17.1.jar  micrometer-observation-1.16.7.jar -> micrometer-observation-1.17.1.jar  
  Jackson in Course 5's lib: jackson-annotations-2.21.jar jackson-core-2.21.5.jar jackson-databind-2.22.2.jar
MethodParameters attributes in OrderQueue.class (Course 4): 0
MethodParameters attributes in OrderQueue.class (Course 5): 3
```

Two of those moved versions are a Jackson skew: the parent still pins `jackson-databind 2.22.2`, while Boot's
management moves `jackson-core` and `jackson-annotations` to 2.21.x. Everything still works; unit 03 shows why and fixes it.
`MethodParameters` 0 → 3: the parent switched `-parameters` on in TiffinBox's own build (unit 02 opens the parent).

## The break — a logging config that stops working, silently

A, B, A′ — A′ is A re-run (contract §R.1) — then two more variants, labelled C and D. Every run is the whole command a
viewer types in that project's `tiffinbox-web/target`, printed before it runs (`.r-logging.out` `7032b96d1230dcf165c1591433f6d32a`):

```
A  Course 4's jar, with the last course's Java logging file
  $ java -Djava.util.logging.config.file=../logging-debug.properties -jar tiffinbox-web-1.0.0.jar 18525
  exit 0 · route DEBUG lines 5 · banner none
  first route line: route GET /customers -> customers()
B  Course 5's jar, the same flag and the same file
  $ java -Djava.util.logging.config.file=../logging-debug.properties -jar tiffinbox-web-1.0.0.jar 18525
  exit 0 · route DEBUG lines 0 · banner printed (v4.1.1)
  first route line: (none)
A' Course 4's jar again: A, re-run
  $ java -Djava.util.logging.config.file=../logging-debug.properties -jar tiffinbox-web-1.0.0.jar 18525
  exit 0 · route DEBUG lines 5 · banner none
  first route line: route GET /customers -> customers()
C  Course 5's jar, Boot's logging.level property, after the port
  $ java -jar tiffinbox-web-1.0.0.jar 18525 --logging.level.tiffinbox=debug
  exit 0 · route DEBUG lines 5 · banner printed (v4.1.1)
  first route line: <time> DEBUG <pid> --- [           main] tiffinbox                                : route GET /customers -> customers()
D  Course 5's jar, the same property with no port in front of it
  $ java -jar tiffinbox-web-1.0.0.jar --logging.level.tiffinbox=debug
  exit 1 · java.lang.NumberFormatException: For input string: "--logging.level.tiffinbox=debug"
```

Boot owns logging now: `LoggingApplicationListener` routes your JUL records to Logback (through `jul-to-slf4j`), and a
JUL configuration file no longer sets their level. Exit 0 every time — nothing warns you. Boot's own way back is a
property, and it goes **after** the port: `main` still copies its first argument into `tiffinbox.port` (the last
course's bridge), so the same property in front of it is read as the port and start-up fails (D).

## Exercise

`exercise/`: delete the last course's port bridge and let Boot read `--tiffinbox.port`. The README's commands were run
exactly as written; the run and the answer are in `exercise/solution/SOLUTION.md`.
