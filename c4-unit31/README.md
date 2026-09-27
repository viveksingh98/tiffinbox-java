# Unit 31 — Capstone: TiffinBox as a Spring Application

Course 4 · Section 6 · *Close*. **Verified on JDK 25.0.4.1**, Maven 3.9.16, Spring Framework 7.0.9.
The rewire lands in the long-lived project, `../c4-tiffinbox`; this folder holds the evidence.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
./receipts.sh     # builds before/ and the rewired anchor, serves both, runs everything below 3 times, asserts it
```

## Before — and the wiring nobody counted

`before/` is `c4-tiffinbox` frozen at the commit before this unit: the project as the build course left it, plus
`Wiring.java`. The old ledger, re-derived (`.r-ledger-before.out` `decf86d7b4ca9aa5105c6d6e757dc4cb` — the same hash the
container and lifecycle sections recorded for the untouched anchor):

```
and what starting it costs, counted out of the source:
  lines in startEverything(), comments and blanks removed ... 18
  objects constructed with new .............................. 4
  configuration values held as constants beside them ........ 3
  places that order is written down ......................... 0
  things that check it ...................................... 0
```

**But the program that serves HTTP never calls `Wiring.java`.** `TiffinBoxServer.main` wires the same objects a
second time, with the same values typed a second time. Counted over both modules (`ledger-project.sh`,
`.r-ledger-project.out` `1ead38b54748e0bdd3a4f02d0b4c63a0`):

```
the classes the container now builds (every @Component in the rewired project):
  CustomerRepository Dashboard Database OrderQueue TiffinBoxServer
counted over both modules - before the rewire -> after it:
  hand-written constructions of those classes ......................... 9 -> 0
  configuration values held as constants in code ...................... 3 -> 0
  values in tiffinbox.properties ....................................... 0 -> 4
  lines in Wiring.startEverything(), comments and blanks removed ...... 18 -> 0
  lines in TiffinBoxServer.main(), comments and blanks removed ........ 26 -> 7
```

## The rewire — three moves

1. **Annotations on the objects:** `@Component` on the five, `@Value` on two constructor parameters, `@PostConstruct`
   on `Database.createAndSeed` (and `@PostConstruct`/`@PreDestroy` on the server's start and stop). Measured
   (`onlyannotations.py`, `.r-objects.out` `95b7c3fb5ba1f97ebc485c68c06104c7`):
   ```
  classes compared ............................................ 5
  lines changed ............................................... 20
  lines changed that are not an annotation or an import ...... 0
   ```
2. **One description:** `TiffinBoxApp` — `@Configuration @ComponentScan("com.tiffinbox")
   @PropertySource("classpath:tiffinbox.properties")`. It says where the objects are, and nothing about order.
3. **One properties file:** the three values `Wiring.java` held as constants, plus the port `main` hard-coded.

`Wiring.java` is deleted (`git rm`). The old ledger, run on the rewired project (`.r-ledger-after.out`
`b4dfbe4cf1dbb952f41afc9d67fae918`):
```
ledger: no ../c4-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox/wiring/Wiring.java - the ledger has nothing to count
exit 2
```

## Who decides the order now

`harness/BuildOrder` (not part of the application) records the order the container finished the objects in
(`.r-order.out` `258d22b6245613a59eafe30f1b5270e6`):
```
definitions, in the order the scan registered them: [tiffinBoxApp, tiffinBoxServer, customerRepository, dashboard, database, orderQueue]
objects, in the order the container finished them : [tiffinBoxApp, database, customerRepository, dashboard, orderQueue, tiffinBoxServer]
… 4 JUL header line(s), 4 INFO line(s), 0 stack line(s) elided …
```
Registered second, built last; registered fifth, built first. Nobody wrote that order down — the container
worked it out from the constructors.

## Identical — 7 of 7

`curlset.sh`: one request per layer the rewire touched. Before (`.r-before.out` `c4092678a85b29ba94537ee678e8337c`) and after
(`.r-after.out` `b7b292a18b3f5ce48bbc7ac97ec85483`) are **byte-identical** — status, content type and body — and after
`POST /shutdown` the rewired server exits 0 and leaves no listener (all asserted):
```
GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
POST  /shutdown   -> 200 application/json  {"stopping":true}
```
The run command did not change either: `java -jar tiffinbox-web-1.0.0.jar 18431`. `main` copies that positional
port into the system property `tiffinbox.port`, which outranks the properties file.

## The thing that checks it

`breaks/no-database-component`: `Database` without its `@Component`. Startup refuses (`.r-no-db.out`
`90bb74854c1758cce3a9b9aaf736524f`, jar paths masked, every dropped line counted):
```
WARNING: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'tiffinBoxSer
Exception in thread "main" org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'tiffinBoxServer' defined in URL [jar:file:<path>!/com/tiffinbox/web/TiffinBo
Caused by: org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'customerRepository' defined in URL [jar:file:<path>!/com/tiffinbox/CustomerRepository.class]
Caused by: org.springframework.beans.factory.NoSuchBeanDefinitionException: No qualifying bean of type 'com.tiffinbox.Database' available: expected at least 1 bean which qualifies as autowire candidat
… 1 JUL header line(s), 0 INFO line(s), 39 stack line(s) elided …
exit 1
```

## The break — one `new`, and it still works

`breaks/one-new`: the server builds its own `new OrderQueue(COOKS)`, with `COOKS = 3` back in the code. The curl
output is **still identical, 7 of 7** (`.r-one-new.out` `5931b0f12dedc72ab63254a99747783f`, asserted). Asked what it can see
(`harness/TwoKitchens`, `.r-kitchens.out` `c0cc3116cfde41769d7e13be02434904`):
```
kitchens in the context          : 1
the server cooks with that one?  : false
orders cooked - the server's kitchen: 120, the container's: 0
… 4 JUL header line(s), 4 INFO line(s), 0 stack line(s) elided …
```
Two kitchens: the container's, which nothing uses, and the server's, which the container cannot see — no
injection, no lifecycle, no proxy and no validation can reach it. And two rows of the ledger move back.

## Files

`before/` · `curlset.sh` · `ledger-project.sh` · `onlyannotations.py` · `harness/` (BuildOrder, TwoKitchens) ·
`breaks/` (no-database-component, one-new) · `receipts.sh` · `exercise/` — and the rewire itself in `../c4-tiffinbox`.
