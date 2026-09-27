# Unit 31 — Capstone: TiffinBox as a Spring Application

Course 4 · Section 6 · *Close*. **Verified on JDK 25.0.4.1**, Maven 3.9.16, Spring Framework 7.0.9.
The rewire lands in the long-lived project, `../c4-tiffinbox`; this folder holds the evidence.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
./receipts.sh     # builds before/, the rewired anchor and the breaks; runs everything below 3 times; asserts every number
```

The `.r-*.out` captures are **not committed**: `receipts.sh` regenerates every one, requires three identical runs,
and compares each hash with `receipts.md5` (the hashes quoted below). On another machine a different hash is
information, not a failure. Every JVM is pinned to `-Duser.language=en -Duser.country=US`, because Java's log
header is locale-dependent and the masks expect the en-US form.

## Before — and the wiring nobody counted

`before/` is `c4-tiffinbox` frozen at the commit before this unit: the project as the build course left it, plus
`Wiring.java`. The old ledger, re-derived (`.r-ledger-before.out` `decf86d7b4ca9aa5105c6d6e757dc4cb` — the same hash the container
and lifecycle sections recorded for the untouched anchor):

```
and what starting it costs, counted out of the source:
  lines in startEverything(), comments and blanks removed ... 18
  objects constructed with new .............................. 4
  configuration values held as constants beside them ........ 3
  places that order is written down ......................... 0
  things that check it ...................................... 0
```

**But the program that serves HTTP never calls `Wiring.java`.** `TiffinBoxServer.main` wires the same objects a second
time and types the values in again (`second-wiring.sh`, `.r-second-wiring.out` `ad3e383abd9eb4ca1b16a90610ee5946`):

```
hand-written constructions, counted per file (before the rewire):
  core: Wiring.java ...................... 4
  web:  TiffinBoxServer.java ............. 5
  both modules ........................... 9
lines of TiffinBoxServer.java that mention Wiring: 0
its main() (lines 142-175) types in these values, as written:
   145: var db = new Database("jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1");
   152: var kitchen = new OrderQueue(3);
   154: for (int day = 0; day < 30; day++) {
   143: int port = args.length > 0 ? Integer.parseInt(args[0]) : 18425;
```

## The rewire — three moves

1. **Annotations on the objects:** `@Component` on the five, `@Value` on two constructor parameters, `@PostConstruct` on
   `Database.createAndSeed`, and `@PostConstruct`/`@PreDestroy` on the server's new `start()` and `stop()`.
2. **One description:** `TiffinBoxApp` — `@Configuration @ComponentScan("com.tiffinbox")
   @PropertySource("classpath:tiffinbox.properties")`. No `@Bean` method: it names no object and no order, only where
   to look and which file to read.
3. **One properties file:** the three values `Wiring.java` held as constants, plus the port `main` typed in.

**The objects, measured** (`onlyannotations.py`, `.r-objects.out` `02e580745a31bceae504dedf9d164ea3`). The core classes are compared
line by line, **in order**, once annotations, imports and blank lines are set aside. The server is run through the
same check and **did** change — its `main` became `start()` and `stop()` — so it is reported, not excused. The last
run feeds the checker `breaks/fool-the-checker` (one line deleted, one duplicated), which an earlier, order-blind
version of this script passed; it must fail:

```
  classes compared: Customer CustomerRepository Dashboard Database OrderQueue
  lines changed ................................................ 20
    blank lines ................................................ 4
    import lines ............................................... 7
    annotation lines ........................................... 5
    code lines touched ......................................... 4
  code that differs once annotations are set aside, in order ... 0
exit 0
the server, the same check:
  classes compared: Route TiffinBoxServer
  lines changed ................................................ 72
    blank lines ................................................ 10
    import lines ............................................... 6
    annotation lines ........................................... 3
    code lines touched ......................................... 53
  code that differs once annotations are set aside, in order ... 53
  … 53 differing line(s) listed by the checker, elided …
exit 1
the checker, fed breaks/fool-the-checker (one line deleted, one duplicated):
  differs: Database.java: -                ps.addBatch();
  differs: OrderQueue.java: +                    cooked.incrementAndGet();
  classes compared: Customer CustomerRepository Dashboard Database OrderQueue
  lines changed ................................................ 22
    blank lines ................................................ 4
    import lines ............................................... 7
    annotation lines ........................................... 5
    code lines touched ......................................... 6
  code that differs once annotations are set aside, in order ... 2
exit 1
```

## Delete it

`Wiring.java` is deleted. The old ledger, run on the rewired project, refuses — and because a mistyped path would
refuse the same way, a search confirms the file is gone (`.r-ledger-after.out` `38724a99ecb96f5d78db817febba23be`):

```
ledger: no ../c4-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox/wiring/Wiring.java - the ledger has nothing to count
exit 2
files named Wiring.java: under before/ 1, under the rewired anchor 0
```

Counted over the whole project instead (`ledger-project.sh`, `.r-ledger-project.out` `3220f1d65f1a8071f5b184a3c75e8b25`). A count
over a file that no longer exists says so rather than printing a confident `0`; the last two rows are the price:

```
the classes the container builds (every @Component or @Configuration in the rewired project):
  CustomerRepository Dashboard Database OrderQueue TiffinBoxApp TiffinBoxServer
counted over both modules - before the rewire -> after it:
  hand-written constructions of those classes ......................... 9 -> 0
  configuration values held as constants in code ...................... 3 -> 0
  tiffinbox.properties values typed as literals into main() ........... 4 -> 0
  values in tiffinbox.properties ....................................... 0 (no file) -> 4
  lines in Wiring.startEverything(), comments and blanks removed ...... 18 -> (file gone)
  lines in TiffinBoxServer.main(), comments and blanks removed ........ 26 -> 7
  lines in start() and stop(), which the container now calls .......... 0 -> 25
the price:
  dependencies tiffinbox-core declares in its pom.xml ................. 1 -> 3
  jars the application needs at run time (tiffinbox-web/target/lib) .. 5 -> 15
```

## Who decides the order now

`harness/BuildOrder` (not part of the application) prints what was handed to the context, the order the definitions
were registered in, and the order the container **finished** the objects in — constructed, values in,
`@PostConstruct` run. It runs twice, with the two jars in opposite class-path orders (`.r-order.out` `3773d04a7008186251dc1354a7c5fd17`):

```
class path: tiffinbox-web first, then tiffinbox-core
  handed to the context, before refresh() : [tiffinBoxApp]
  definitions, in the order registered    : [tiffinBoxApp, tiffinBoxServer, customerRepository, dashboard, database, orderQueue]
  objects, in the order finished          : [tiffinBoxApp, database, customerRepository, dashboard, orderQueue, tiffinBoxServer]
… 4 JUL header line(s), 4 INFO line(s), 0 stack line(s) elided …
class path: tiffinbox-core first, then tiffinbox-web
  handed to the context, before refresh() : [tiffinBoxApp]
  definitions, in the order registered    : [tiffinBoxApp, customerRepository, dashboard, database, orderQueue, tiffinBoxServer]
  objects, in the order finished          : [tiffinBoxApp, database, customerRepository, dashboard, orderQueue, tiffinBoxServer]
… 4 JUL header line(s), 4 INFO line(s), 0 stack line(s) elided …
```

One class was handed in; the scan found the other five, **in an order that depends on which jar comes first**. The
order they were finished in did not move: the database — seeded — before the repository that reads it, the server
last. The container worked it out from the constructors: whatever an object needs is finished first.

## Identical — the seven responses

`curlset.sh`: one request per layer the rewire touched. The seven responses — status, content type and body — hashed
on their own, for the frozen project, the rewired one and the break (`.r-identical.out` `c9fbb8127a6f7363977d98e6248e5cf8`):

```
the seven responses (status, content type, body), hashed on their own:
  before/, as Course 3 left it   7 lines  md5 115c36bac276128e245ca57df11c2891
  the rewired anchor             7 lines  md5 115c36bac276128e245ca57df11c2891
  the one-new break              7 lines  md5 115c36bac276128e245ca57df11c2891
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

After `POST /shutdown` the rewired server exits 0 and leaves no listener (`.r-after.out` `b7b292a18b3f5ce48bbc7ac97ec85483`, asserted). The run
command did not change: `java -jar tiffinbox-web-1.0.0.jar 18431` — `main` copies the positional port into the system
property `tiffinbox.port`, which outranks the properties file.

**Identical responses, not identical insides.** The server's start-up now runs in `start()`, called by the container.
And at shutdown the container also calls `close()` on `OrderQueue` — Spring infers it for any `AutoCloseable` bean —
a second time, after `start()` closed it to drain the rail. The second call is harmless: three poison pills land on a
rail with no cooks left (measured by the RED review of this section, S6 #21). `curl` cannot see either difference.

## The thing that checks it

The build course's missing checker was about **order**: move two lines of `Wiring.java` and it still compiled. There
are no such lines any more — the container finished the database, seed included, before anything that reads it (above).
And when a piece is missing, it refuses to start and names the chain. `breaks/no-database-component`: `Database` without
its `@Component` (`.r-no-db.out` `90bb74854c1758cce3a9b9aaf736524f`, jar paths masked, every dropped line counted):

```
WARNING: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'tiffinBoxServer' defined in URL [jar:file:<path>!/com/tiffinbox/web/TiffinBoxServer.class]: Unsatisfied dependency expressed through constructor parameter 0: Error creating bean with name 'customerRepository' defined in URL [jar:file:<path>!/com/tiffinbox/CustomerRepository.class]: Unsatisfied dependency expressed through constructor parameter 0: No qualifying bean of type 'com.tiffinbox.Database' available: expected at least 1 bean which qualifies as autowire candidate. Dependency annotations: {}
Exception in thread "main" org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'tiffinBoxServer' defined in URL [jar:file:<path>!/com/tiffinbox/web/TiffinBoxServer.class]: Unsatisfied dependency expressed through constructor parameter 0: Error creating bean with name 'customerRepository' defined in URL [jar:file:<path>!/com/tiffinbox/CustomerRepository.class]: Unsatisfied dependency expressed through constructor parameter 0: No qualifying bean of type 'com.tiffinbox.Database' available: expected at least 1 bean which qualifies as autowire candidate. Dependency annotations: {}
Caused by: org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'customerRepository' defined in URL [jar:file:<path>!/com/tiffinbox/CustomerRepository.class]: Unsatisfied dependency expressed through constructor parameter 0: No qualifying bean of type 'com.tiffinbox.Database' available: expected at least 1 bean which qualifies as autowire candidate. Dependency annotations: {}
Caused by: org.springframework.beans.factory.NoSuchBeanDefinitionException: No qualifying bean of type 'com.tiffinbox.Database' available: expected at least 1 bean which qualifies as autowire candidate. Dependency annotations: {}
… 1 JUL header line(s), 0 INFO line(s), 39 stack line(s) elided …
exit 1
```

Hand-wiring refused a missing object too — at compile time, as `cannot find symbol`. What it could not refuse was the
wrong order.

## The break — one `new`, and it still works

`breaks/one-new`, as a diff against the anchor (`.r-break-diff.out` `c9e1b80b187e67e8c252d4637f42d55a`):

```
@@ -46,3 +46,4 @@
     private final Dashboard dashboard;
-    private final OrderQueue kitchen;
+    private static final int COOKS = 3;                       // THE BREAK: the value is back in the code
+    private final OrderQueue kitchen = new OrderQueue(COOKS); // THE BREAK: one hand-written new
     private final int days;
@@ -53,3 +54,3 @@
 
-    TiffinBoxServer(CustomerRepository repo, Dashboard dashboard, OrderQueue kitchen,
+    TiffinBoxServer(CustomerRepository repo, Dashboard dashboard,
                     @Value("${tiffinbox.days}") int days, @Value("${tiffinbox.port}") int port) {
@@ -57,3 +58,2 @@
         this.dashboard = dashboard;
-        this.kitchen = kitchen;
         this.days = days;
… 2 diff header line(s) elided …
```

The seven responses are still identical (the same hash as above, `.r-one-new.out` `5931b0f12dedc72ab63254a99747783f`). Asked what it can
see — on the anchor (A), on the break (B) and on the anchor again (A′), objects named by identity (`harness/TwoKitchens`,
`.r-kitchens.out` `e83b1068a607ce252e0b474d272e7e9a`):

```
A  the rewired anchor
  kitchens in the context             : 1
  the container's kitchen             : kitchen #1
  the kitchen the server cooks with   : kitchen #1
  orders cooked - the server's kitchen: 120, the container's: 120
… 4 JUL header line(s), 4 INFO line(s), 0 stack line(s) elided …
B  the one-new break
  kitchens in the context             : 1
  the container's kitchen             : kitchen #1
  the kitchen the server cooks with   : kitchen #2
  orders cooked - the server's kitchen: 120, the container's: 0
… 4 JUL header line(s), 4 INFO line(s), 0 stack line(s) elided …
A' the rewired anchor, again
  kitchens in the context             : 1
  the container's kitchen             : kitchen #1
  the kitchen the server cooks with   : kitchen #1
  orders cooked - the server's kitchen: 120, the container's: 120
… 4 JUL header line(s), 4 INFO line(s), 0 stack line(s) elided …
```

Two kitchens: the container's, which cooked nothing, and the server's, which the container cannot see — nothing in
the context can be handed it. And two rows of the ledger move back (`.r-ledger-one-new.out` `c9fbd2d5d0bac28ffc4a9d18c2b52c77`, 2 of its 13 lines):

```
  hand-written constructions of those classes ......................... 9 -> 1
  configuration values held as constants in code ...................... 3 -> 1
  jars the application needs at run time (tiffinbox-web/target/lib) .. 5 -> 15
```

## Files

`before/` · `curlset.sh` · `second-wiring.sh` · `ledger-project.sh` · `onlyannotations.py` · `harness/` (BuildOrder,
TwoKitchens) · `breaks/` (no-database-component, one-new, fool-the-checker) · `receipts.sh` · `receipts.md5` ·
`exercise/` — and the rewire itself in `../c4-tiffinbox`.
