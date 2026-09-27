# c5-unit01 — From Context to Application

Course 5 · Spring Boot · Section 1 "What Boot Actually Is" · **the first unit of the course.** Verified on **JDK 25.0.4.1,
Apache Maven 3.9.16, Spring Boot 4.1.1 (Spring Framework 7.0.9)**, macOS 27.0, on 2026-09-27.
The change lands in the long-lived project, `../c5-tiffinbox`. These receipts measure **`after/`** — this unit's frozen
copy of the anchor as unit 01 left it — against **`../c4-tiffinbox`**, frozen at Course 4's end, so later units' changes
to the anchor cannot move them. Builds are `clean` builds: `copy-dependencies` never deletes a jar, so a `lib/` built
before a version change would hold both versions.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
./receipts.sh     # builds both, serves both, runs everything below 3 times, asserts every number
```

The `.r-*.out` captures are not committed: `receipts.sh` regenerates them, requires three identical runs, and compares
each hash with `receipts.md5`. Every JVM runs with `-Duser.language=en -Duser.country=US` (log headers are
locale-dependent). Boot's log lines carry a time, a process id and two durations; `mask()` replaces them and counts them.

## The same seven responses

`../c4-unit31/curlset.sh` against both (`.r-identical.out` `d125ee0717f07eb3abf9e8324a5be1fe`):

```
the seven responses (status, content type, body), hashed on their own:
  Course 4, a context you build      7 lines  md5 115c36bac276128e245ca57df11c2891
  Course 5, SpringApplication.run    7 lines  md5 115c36bac276128e245ca57df11c2891
```

```
GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
POST  /shutdown   -> 200 application/json  {"stopping":true}
```

## What changed: three files

(`.r-changes.out` `89e6d4681a33fcaef14ccfb3fb4072aa`)

```
files compared (README aside): 14 · changed: pom.xml tiffinbox-web/pom.xml tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
TiffinBoxServer.java, Course 4 -> Course 5, every changed line:
-import org.springframework.context.annotation.AnnotationConfigApplicationContext;
+import org.springframework.boot.SpringApplication;
-        var context = new AnnotationConfigApplicationContext(TiffinBoxApp.class);
-        context.registerShutdownHook();
+        SpringApplication.run(TiffinBoxApp.class, args);
```

`pom.xml` inherits `spring-boot-starter-parent:4.1.1`; `tiffinbox-web/pom.xml` adds `spring-boot-starter`.

## The same beans — and what Boot added

`harness/WhatBootAdded` starts the Boot-converted project both ways, one JVM each (`.r-beans.out` `e9456513e66b3e2168bc236e7206dc8f`):

```
INFO: orders cooked:  120
INFO: kitchen value:  24300
INFO: routes mapped:  [GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown]
INFO: TiffinBox listening on http://127.0.0.1:18523
new AnnotationConfigApplicationContext(TiffinBoxApp.class):
  your definitions (6): [customerRepository, dashboard, database, orderQueue, tiffinBoxApp, tiffinBoxServer]
  auto-configuration definitions: 0
  Spring's own definitions: 5
  property sources, in the order they are asked: [systemProperties, systemEnvironment, class path resource [tiffinbox.properties]]
… 4 JUL header line(s) elided; 0 Boot line(s) with time and pid masked …

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/

 :: Spring Boot ::                (v4.1.1)

<time> INFO <pid> --- [ main] com.tiffinbox.harness.WhatBootAdded : Starting WhatBootAdded using Java 25.0.4.1 with PID <pid> (<path>)
<time> INFO <pid> --- [ main] com.tiffinbox.harness.WhatBootAdded : No active profile set, falling back to 1 default profile: "default"
<time> INFO <pid> --- [ main] tiffinbox : orders cooked: 120
<time> INFO <pid> --- [ main] tiffinbox : kitchen value: 24300
<time> INFO <pid> --- [ main] tiffinbox : routes mapped: [GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown]
<time> INFO <pid> --- [ main] tiffinbox : TiffinBox listening on http://127.0.0.1:18524
<time> INFO <pid> --- [ main] com.tiffinbox.harness.WhatBootAdded : Started WhatBootAdded in <s> seconds (process running for <s>)
SpringApplication.run(TiffinBoxApp.class, args):
  your definitions (6): [customerRepository, dashboard, database, orderQueue, tiffinBoxApp, tiffinBoxServer]
  auto-configuration definitions: 0
  Spring's own definitions: 6
  property sources, in the order they are asked: [configurationProperties, commandLineArgs, systemProperties, systemEnvironment, random, applicationInfo, class path resource [tiffinbox.properties]]
… 0 JUL header line(s) elided; 7 Boot line(s) with time and pid masked …
```

Your six definitions are identical both ways, and **no auto-configuration happens**: `SpringApplication.run` alone
adds the banner, its own log format and four property sources — `configurationProperties`,
`commandLineArgs`, `random`, `applicationInfo`. Auto-configuration needs one more annotation (unit 04).

## The price

(`.r-price.out` `2306c6e6ce2ccf18fd42dd340493555e`)

```
jars the application needs at run time: 15 -> 26
  added:   jul-to-slf4j log4j-api log4j-to-slf4j logback-classic logback-core slf4j-api snakeyaml spring-boot spring-boot-autoconfigure spring-boot-starter spring-boot-starter-logging
  version moved: commons-logging-1.3.5.jar -> commons-logging-1.3.6.jar  jackson-annotations-2.22.jar -> jackson-annotations-2.21.jar  jackson-core-2.22.2.jar -> jackson-core-2.21.5.jar  jspecify-1.0.0.jar -> jspecify-1.0.1.jar  micrometer-commons-1.16.7.jar -> micrometer-commons-1.17.1.jar  micrometer-observation-1.16.7.jar -> micrometer-observation-1.17.1.jar  
MethodParameters attributes in OrderQueue.class (Course 4): 0
MethodParameters attributes in OrderQueue.class (Course 5): 3
```

Two of those moved versions are a Jackson skew: the parent still pins `jackson-databind 2.22.2`, while Boot's
management moves `jackson-core` and `jackson-annotations` to 2.21.x. Everything still works; unit 03 shows why and fixes it.
`MethodParameters` 0 → 3: the parent switched `-parameters` on in TiffinBox's own build (unit 02 opens the parent).

## The break — a logging config that stops working, silently

The same `-Djava.util.logging.config.file=logging-debug.properties` flag, before and after, and Boot's own way back
(`.r-logging.out` `2514cd1c30e748230b39bf08235ea810`):

```
A  Course 4, -Djava.util.logging.config.file=logging-debug.properties
  exit 0 · route DEBUG lines 5 · banner none
  first route line: route GET /customers -> customers()
B  Course 5, the same flag
  exit 0 · route DEBUG lines 0 · banner printed (v4.1.1)
  first route line: (none)
A' Course 5, --logging.level.tiffinbox=debug
  exit 0 · route DEBUG lines 5 · banner printed (v4.1.1)
  first route line: <time> DEBUG <pid> --- [ main] tiffinbox : route GET /customers -> customers()
```

Boot owns logging now: your JUL records reach Logback through `jul-to-slf4j`, and a JUL configuration file no longer
sets their level. Exit 0 every time — nothing warns you.

## Exercise

`exercise/`: delete Course 4's port bridge and let Boot read `--tiffinbox.port`. Solution and measurements in
`exercise/solution/`.
