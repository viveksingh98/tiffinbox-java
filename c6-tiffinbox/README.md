# c6-tiffinbox — Course 6 (Spring Web MVC)'s long-lived project

**Course 6 starts here.** This folder starts as an exact copy of `c5-tiffinbox` at the end of Course 5 (tiffinbox-java
7b1fe27): every file is byte-identical except this README, which gains only this header. That tree is
`c5-unit27/after`, the last Course 5 unit to change the anchor; units 28-30 measured the same tree through their links,
and Course 5's finale said this tree is where the next course starts. So Course 6 starts on Spring Boot 4.1.1 with
TiffinBox's own web layer: the JDK's HTTP server (`TiffinBoxServer`), the annotation the router reads (`Route`), the
Actuator bridge (`ActuatorRoutes`) and the port analyzer (`PortTakenFailureAnalyzer`), the four files Course 5's finale
measured doing the web's jobs. Course 6's units are planned to hand those jobs to Spring Web MVC, and each unit that
changes this folder records it below as a `## Course 6 · unit NN` section, as Course 5's did. `c5-tiffinbox` stays
frozen from here on, so every Course 5 unit keeps pointing at what it measured. Everything below the rule is
`c5-tiffinbox`'s README exactly as it was at 7b1fe27, except the history notes a Course 6 unit made false: each is
amended in place, in a note that starts *Course 6, unit NN*, and the unit sections keep their history. *(Course 6, unit
04: three of the four files' jobs have moved — `TiffinBoxServer` no longer names the JDK's server, and `ActuatorRoutes` and
`PortTakenFailureAnalyzer` are deleted; Tomcat, Boot's Actuator adapter and Boot's port analyzer do their jobs. `Route`
stays until Course 6's request-mapping lesson.)* *(Course 6, unit 06: and the fourth's — `Route` is deleted, with
`RouteMapping`: `TiffinBoxServer` is a `@RestController`, its routes Spring MVC's own request mappings. All four files' jobs have
moved.)*

## Course 6 · unit 04 — embedded Tomcat: TiffinBox's own server handed over (2026-10-12)

TiffinBox's routes, its token, its JSON and its kitchen are unchanged; the server under them is not. Since Core Java II the JDK's
`HttpServer` listened here, one virtual thread per answer. From this unit on, **embedded Tomcat** listens — the web server Spring
MVC's starter brings, running inside TiffinBox's own JVM — and Spring MVC's **`DispatcherServlet`** (the one servlet every request
goes through) hands each request to TiffinBox's handler for its path. Six files changed, two deleted, one new:
- `tiffinbox-web/pom.xml` — **`spring-boot-starter-webmvc`**: Spring MVC, Tomcat and Jackson 3, the JSON library Spring writes its
  own answers with. Twelve more jars in `BOOT-INF/lib` (46 → 58), none removed. The Boot plugin's two `tools.jackson.core`
  `<exclude>`s and the native plugin's two `<exclusion>`s are gone; the Compose module's stay. Course 5 needed them because the
  Compose module's Jackson 3 reached Spring's AOT step but not the jar; the starter puts Jackson 3 in the jar, so the step, the jar
  and the binary agree. Until Course 6's Jackson lessons, one jar holds two Jacksons: Jackson 2 writes TiffinBox's five answers,
  Jackson 3 writes Spring's (an error body, Actuator's answers). *(Course 6, unit 06: Spring MVC's JSON converter writes TiffinBox's five answers too, with
  Jackson 3; Jackson 2 stays in the jar until Course 6's Jackson lessons, and writes none of them — `../c6-unit06/`, `json`.)*
  *(Course 6, unit 08: one Jackson from there on — Jackson 2's `jackson-databind` is out of this POM, and two of the jar's 58 jars
  with it: 56; `../c6-unit08/`, `jackson`.)* *(Course 6, unit 22: 61 — Thymeleaf's starter adds five; `../c6-unit22/`,
  `change`.)*
- `TiffinBoxServer.java` — the server half is out: no `HttpServer`, no executor, no contexts, no `stop()`. `handle()`, `respond()`
  and `holdsToken()` work on the servlet API (`HttpServletRequest`, `HttpServletResponse`); `handlers()` builds one **handler** per
  path (the object a request is handed to), each named — its `toString()` reads `TiffinBox route /customers` — and the verb is still
  matched inside `handle()`. POST /shutdown flushes its reply, then a platform thread closes the application context. Its
  `TiffinBox listening on http://…` line is gone: Boot's `TomcatWebServer` logs `Tomcat started on port 18431 (http) with context
  path '/'`, which names the port, never the address (Tomcat's own connector line names it, at a level Boot's logging defaults
  hide). The Javadoc's "jdk.httpserver on a virtual-thread executor" and "One server, one stop" sentences are
  rewritten. *(Course 6, unit 06: `handle()`, `respond()`, `handlers()` and the named handlers are deleted: the routes are
  Spring MVC's request mappings, and POST /shutdown is a controller method that starts the close on a platform thread of its own
  and returns its answer.)* *(Course 6, unit 07: `holdsToken()` takes the header's value, which Spring MVC hands POST /shutdown as a
  parameter, `@RequestHeader`; `../c6-unit07/`, `token`.)* *(Course 6, unit 10: no route takes the servlet response any more — POST /shutdown's 403 is a return value, a `ResponseEntity`;
  `../c6-unit10/`, `entity`.)*
- `RouteMapping.java` (new) — one **handler mapping** (what the `DispatcherServlet` asks "which handler takes this request?"):
  Spring's own `SimpleUrlHandlerMapping`, a table of paths, here TiffinBox's five, each with its handler. Spring's
  `HttpRequestHandlerAdapter` calls the handler. `@Route` and `scanRoutes()` stay TiffinBox's until Course 6's request-mapping
  lesson. *(Course 6, unit 06: deleted, with `Route.java` and `scanRoutes()`.)*
- `ActuatorRoutes.java` — **deleted** (196 lines): a JDK `HttpHandler` cannot outlive the JDK's server. Boot's own Actuator adapter
  answers `/actuator` on Tomcat, with the same content types (Course 6's mappings lesson lists its routes).
- `PortTakenFailureAnalyzer.java` — **deleted** (51 lines), and its name taken out of `META-INF/spring.factories`, which keeps the
  bare-argument guard and its analyzer. A port taken is Tomcat's now, and Boot's own analyzer (`PortInUseFailureAnalyzer`, in
  `spring-boot-web-server`) explains it, exit 1, no stack trace: `Web server failed to start. Port 18431 was already in use.` and
  `Identify and stop the process that's listening on port 18431 or configure this application to listen on another port.` Boot's
  two sentences name neither the address nor a setting; TiffinBox's named both (`127.0.0.1:18431`, `--tiffinbox.port=<a free
  port>`).
- `application.yaml` — in its **first document, above the `---`**: `server.address: ${tiffinbox.address}` and
  `server.port: ${tiffinbox.port}`, and `spring.threads.virtual.enabled: true` under the `spring:` key it already had.
- `META-INF/spring.factories` — the analyzer's name out of the `FailureAnalyzer` key, and the comment rewritten.
- `BareArgumentAnalyzer.java` — one Javadoc line, which named the deleted analyzer. Its code is unchanged.

The Dockerfile, `compose.yaml`, `Route.java`, the indicator, the meters, `TiffinBoxApp.java`, the guard and `tiffinbox-core` are
not touched. *(Course 6, unit 06: `Route.java` is deleted.)*

**The address the log hides.** Boot's started line names a port, never an address. Tomcat's own connector line names the
address — `Initializing ProtocolHandler ["http-nio-127.0.0.1-18431"]` — but Boot's logging defaults hold its logger
(`org.apache.coyote.http11.Http11NioProtocol`) at WARN, so at the default levels the address the process listens on is the
witness: `127.0.0.1:18431`, this computer only, as before (`../c6-unit04/`, `bind` A and F). Without `server.address`, Tomcat
listens on **every interface** — measured on a copy of this tree with the alias's three lines taken out: `*:<port>`
(`../c6-unit04/`, `bind` B).
So the alias must sit above the `---`: below it, it would belong to the profile "rush" alone, and a plain start would listen on
Tomcat's defaults — every interface, port 8080 (Boot's own metadata: `server.port` 8080, `server.address` no default). In the image,
the Dockerfile's `TIFFINBOX_ADDRESS=0.0.0.0` reaches Tomcat through the alias: inside, Tomcat listens on every interface of the
container, and the port is published on the Mac's `127.0.0.1` alone. **One port, two names:** where both are given, Boot's own
`--server.port` wins over `--tiffinbox.port`. TiffinBox's commands use `--tiffinbox.port=`, as every README line here does.

```bash
mvn -B package
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --server.port=18432
curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:18431/customers
```

**Whose threads.** With `spring.threads.virtual.enabled: true` (`application.yaml`), Tomcat answers each request on a virtual
thread of its own, `tomcat-handler-N`, and Boot's task executor is a `SimpleAsyncTaskExecutor` whose tasks run on virtual threads.
Switched off, Tomcat's default pool answers — platform threads named `http-nio-127.0.0.1-18431-exec-N`, ten kept while idle, two
hundred at most (`server.tomcat.threads.max`) — and Boot's executor is a `ThreadPoolTaskExecutor` again. Eight slow requests at
once: on virtual threads, eight threads answer; with virtual threads off and `--server.tomcat.threads.max=2`, two do
(`../c6-unit04/`, `threads`). Idle, the server keeps five platform threads: Tomcat's Acceptor and Poller (daemon threads) and
its two `Catalina-utility` threads, and `container-0`, whose class is Boot's (`TomcatWebServer$1`); the last three are not daemons,
and they keep the JVM alive while Tomcat runs (`../c6-unit04/`, `pool`). **Under Spring's AOT step the build
decides:** the AOT jar runs on `tomcat-handler-N` even with `--spring.threads.virtual.enabled=false` at run time, and the
native binary, built the same way, runs on `tomcat-handler-N` too. `%thread %msg%n` makes Logback print each line as its thread's whole name and the message.

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.threads.virtual.enabled=false
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.threads.virtual.enabled=false --server.tomcat.threads.max=2
java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.threads.virtual.enabled=false --logging.level.kitchen=debug --logging.pattern.console='%thread %msg%n'
tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431 --logging.level.web=debug --logging.level.kitchen=debug --logging.pattern.console='%thread %msg%n'
```

**The seven, on Tomcat.** Six of `../c5-unit11/curlset.sh`'s seven lines — status, content type and body, all a line holds — are
byte for byte what TiffinBox's own server answered; under them the status line and the headers changed (`HTTP/1.1 200 OK` is now
`HTTP/1.1 200 `, and `Date` comes last; `../c6-unit04/`, `seven`). One line differs, `GET /nowhere`: the JDK's `404 text/html <h1>404 Not Found</h1>No context found for request` is now Spring's
`404 application/json {"timestamp":"…","status":404,"error":"Not Found","path":"/nowhere"}`. No handler TiffinBox registered takes
`/nowhere`; Spring MVC's static-resource handler, which Boot maps to `/**`, does, finds no file, and the 404 goes to Boot's `/error` controller, which writes
JSON with Jackson 3: Spring MVC's one JSON converter is `JacksonJsonHttpMessageConverter`, on Jackson 3's `JsonMapper` (Boot's
`web` log group at DEBUG shows each step; `../c6-unit04/`, `seven`). The timestamp moves every run, so the set is compared
**masked**: the timestamp's value becomes `…` (both forms: an ISO-8601 string, which Jackson 3 writes here, and epoch milliseconds),
and the masked set hashes to `571faaea42e87e85add8c9548c64c961` — the comparison set from here on. `GET /shutdown` is still
TiffinBox's own `405 {"error":"method not allowed"}`: its handler still matches the verb. *(Course 6, unit 06: it is Spring MVC's 405 now —
`{"timestamp":"…","status":405,"error":"Method Not Allowed","path":"/shutdown"}`, `Allow: POST` — and the masked set hashes to
`87ca7efc8584dcccd40e6b956db1de9b`, the comparison set from there on; `../c6-unit06/`, `seven`.)* *(Course 6, unit 16: both are problem details since, written by Boot's `ProblemDetailsExceptionHandler` with no error dispatch — `404 application/problem+json {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"}` and the 405's — and carry no timestamp, so the mask changes 0 lines; the masked set hashes to `466c20ed7e0d5439cb052f32ce09de1b`; `../c6-unit16/`, `seven`.)*

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.web=debug
```

**The seam.** Paths the JDK's server matched by prefix — `/customersXYZ`, `/customers/`, `/kitchen/anything` — answered 200; Spring's
handler mapping matches whole paths, and they answer 404. `/actuator` answers 200, Boot's list of links, where the bridge said 404.
HEAD, `Accept: application/xml` and DELETE answer as before (TiffinBox's handler decides them). **Two timers** from here on: Boot's
`http_server_requests` times every answer (it tags every 404 here `uri="/**"`), TiffinBox's own `tiffinbox_requests` only the
answers TiffinBox's handler gives — the three 404s are on Boot's timer alone. *(Course 6, unit 06: Spring MVC decides those three now — HEAD 200 with
`Content-Length: 282`, `Accept: application/xml` 406, DELETE 405 with `Allow: GET`, the 405 and the 406 one WARN line each; and
TiffinBox's own timer is retired: Boot's alone times every answer — `../c6-unit06/`, `verbs`, `timers`.)* *(Course 6, unit 16: with problem
details on, the 405 and the 406 are problem details; the 405 still logs one WARN line, now Spring MVC's `PageNotFound`, the 406 none —
`../c6-unit16/`, `flag`.)* **A `static/` folder is served:** `/**`'s locations
end with `ServletContext [/]`, Tomcat's document root, which Boot takes from the folder TiffinBox starts in (its `static/`,
`public/` or `src/main/webapp/`): a file in `static/` there answers 200, while that folder's own files and the config tree,
`secrets/`, answer 404 (`../c6-unit05/`, `catchall` D).

**What stops it.** POST /shutdown answers `{"stopping":true}`, then the context closes, Boot's graceful shutdown (`server.shutdown`'s
default is `graceful`; `spring.lifecycle.timeout-per-shutdown-phase` 30s) stops Tomcat — `Commencing graceful shutdown. Waiting for
active requests to complete`, `Graceful shutdown complete` — and the JVM exits **0**. A request in flight finishes first: a slow
request of three seconds, sent before POST /shutdown, answers 200; with `--server.shutdown=immediate` it gets no answer
(`../c6-unit04/`, `stop`). Tomcat is TiffinBox's only server: with two servers in one JVM, Boot's `container-0` kept it alive
after TiffinBox's own server stopped (Course 6's servlet-container lesson). *(Course 6, unit 06: POST /shutdown is a controller method — it starts the close
on a platform thread of its own and returns its answer. The answer arrived with Boot's graceful shutdown and with
`--server.shutdown=immediate` alike, so graceful shutdown is not what lets it out; `../c6-unit06/`, `stop`.)* *(Course 6, unit 10:
not so — `../c6-unit06/`'s `stop`, made again with the answer held in flight two seconds after the method returned: with graceful
shutdown it arrived in every run, with immediate shutdown in none. Graceful shutdown is what guarantees the reply.)*

**Every form still serves:** the jar, the AOT jar, the native binary (a build of under 20 minutes; the binary's DEBUG says `Mapped to
TiffinBox route /customers`), and the image — each listening on `127.0.0.1` (the image: published there), each answering the seven
`571faaea…` (masked), each exit 0 after POST /shutdown. *(Course 6, unit 06: the binary's DEBUG says `Mapped to
com.tiffinbox.web.TiffinBoxServer#customers()`, and the four forms answer `87ca7efc…`; `../c6-unit06/`, `forms`.)*

Evidence for every sentence in this section: `../c6-unit04/` (`receipts.sh`, ten captures).

## Course 6 · unit 06 — @RestController: TiffinBox's routes become Spring MVC's (2026-10-14)

TiffinBox's five routes, their bodies, its token and its kitchen are unchanged; what finds them is not. Since Core Java II TiffinBox
found its routes itself — an annotation of its own (`Route`), a scan by reflection into a `TreeMap` keyed "VERB path", the verb
checked inside its handler — and wrote each answer with a Jackson 2 mapper of its own. From this unit on they are **Spring MVC's own
request mappings**: `TiffinBoxServer` is a **`@RestController`** — Spring MVC's `@Controller`, itself a `@Component`, plus
`@ResponseBody`, as Spring reads the class (`../c6-unit06/`, `change`) — and each route a **`@GetMapping`** or **`@PostMapping`**.
One Java file changed and two deleted, besides this README:
- `TiffinBoxServer.java` — `@Component` → `@RestController`; `@Route(path = "/customers")` → `@GetMapping("/customers")`, and so for
  `/revenue`, `/dashboard` and `/kitchen`; `@Route(path = "/shutdown", method = "POST")` → `@PostMapping("/shutdown")`. Each route
  returns its type — `List<Customer>`, `Map<String, Object>` — never `Object`, and `@RegisterReflectionForBinding(Customer.class)`
  is gone (below). Deleted with the router: `scanRoutes()`, `handlers()`, the named `RouteHandler`, `handle()`, `respond()`,
  `paths()`, the Jackson 2 `ObjectMapper` field, TiffinBox's own timer (`tiffinbox.requests`, and the `MeterRegistry` parameter) and
  its line per answer at DEBUG: 285 lines → 176. POST /shutdown is a controller method: without the token,
  `response.setStatus(403)` and `{"error":"forbidden"}`; with it, a platform thread of its own closes the application context, and
  the method returns `{"stopping":true}`. *(Course 6, unit 10: both answers are a `ResponseEntity` since —
  `status(HttpStatus.FORBIDDEN)` and `ok(…)` — the servlet response parameter gone; `../c6-unit10/`, `entity`.)* The Javadoc is rewritten where it described the router, the hint, the timer, the line per
  answer and the catch.
- `Route.java` (24 lines) and `RouteMapping.java` (20) — **deleted**.

The POMs, `application.yaml`, `spring.factories`, the Dockerfile, `compose.yaml`, `KitchenMetrics`, the indicator, the guard and
its analyzer, `TiffinBoxApp.java` and `tiffinbox-core` are not touched; the executable jar holds the same 58 libraries — Jackson 2
among them, until Course 6's Jackson lessons. *(Course 6, unit 08: 56 — Jackson 2 is out; `../c6-unit08/`, `jackson`.)*

**Registered at start.** Spring MVC's `RequestMappingHandlerMapping` finds the five while the context starts, before Boot's started
line: at TRACE, `{GET [/customers]}: customers()` and four more under `c.t.w.TiffinBoxServer:`, then `7 mappings in
'requestMappingHandlerMapping'` — TiffinBox's five and Boot's two `/error` routes. TiffinBox's own `route GET /customers ->
customers()` and `routes mapped: […]` lines are gone (`../c6-unit06/`, `scan`). The routing table, `/actuator/mappings` exposed for
one run, still has 14 rows, and TiffinBox's five now carry their verbs: `{GET [/customers]}` → `TiffinBoxServer#customers()`,
`methods ["GET"]` (`rows`). *(Course 6, unit 07: six routes, 8 mappings, 15 rows — `GET /customers/{name}` is the sixth, and the
routes list their parameter types, `customers(MealType)`; `../c6-unit07/`, `change`.)* *(Course 6, unit 08: seven routes, 9 mappings,
16 rows — `POST /customers`, `add(Customer)`, is the seventh; `../c6-unit08/`, `change`.)* *(Course 6, unit 12: `add(Customer,BindingResult)`
since, still 9 mappings; `../c6-unit12/`, `constraints`.)* *(Course 6, unit 22: ten routes, 19 rows — `DashboardPage`'s `GET /dashboard` and
`GET /customers/new`, each producing `text/html`, and its `POST /customers`, consuming a form's type; `../c6-unit22/`, `negotiate`.)*

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.kitchen=debug --logging.level.org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping=trace
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,mappings
```

**Spring MVC decides the verbs, and says so.** `HEAD /customers` answers 200 with `Content-Length: 282` (TiffinBox's own handler
answered 405); `OPTIONS` 200 with `Allow: GET,HEAD,OPTIONS`; `DELETE` 405 with `Allow: GET`; `GET /shutdown` 405 with `Allow: POST`;
`Accept: application/xml` 406 with an empty body (it was 200 JSON). The cost: the 405s and the 406 add one WARN line each at Boot's
default level, Spring MVC's `DefaultHandlerExceptionResolver` — `Resolved [org.springframework.web.HttpRequestMethodNotSupportedException:
Request method 'DELETE' is not supported]` — where TiffinBox's own 405 logged none; HEAD, OPTIONS and the 403 log none (`verbs`). *(Course 6, unit 16: with problem details on, the 406 has a body — `{"detail":"Acceptable representations: [application/json, application/*+json].",…}`, `application/problem+json` — and logs no WARN line; GET /shutdown's 405 logs one, Spring MVC's `PageNotFound`, `Request method 'GET' is not supported`; `../c6-unit16/`, `flag`.)*

**The seven, on Spring MVC's routes.** Six of `../c5-unit11/curlset.sh`'s seven lines are byte for byte the embedded-Tomcat
lesson's: the four bodies of TiffinBox's routes and `{"stopping":true}` are written now by Spring MVC's JSON converter,
`JacksonJsonHttpMessageConverter` on Jackson 3's `JsonMapper`, where TiffinBox's own Jackson 2 wrote them, and the record's
components and the maps' keys come out in the same order. One line differs, `GET /shutdown`: no mapping takes GET there, so Spring
MVC's `DefaultHandlerExceptionResolver` answers 405 with `Allow: POST`, and the error dispatch takes it to Boot's error controller —
`405 application/json {"timestamp":"…","status":405,"error":"Method Not Allowed","path":"/shutdown"}`. Masked — two timestamps now,
the 404's and the 405's — the seven hash to **`87ca7efc8584dcccd40e6b956db1de9b`**, the comparison set from here on. The status
line and the header names are unchanged (`[HTTP/1.1 200 ]`, `Content-Type Content-Length Date`); the seven log one WARN line,
GET /shutdown's (`seven`). *(Course 6, unit 16: `466c20ed…` since — lines 5 and 6 problem details, the other five byte for byte — and that WARN line is Spring MVC's `PageNotFound` now; `../c6-unit16/`, `seven`.)*

**Who writes the answers, a class taken away.** With Jackson 2's `JDK14Util` deleted from a copy of the extracted jar (Course 5's
missing-class lines, below), `/customers` still answers 200: Jackson 2 is no longer on its road. With Jackson 3's `RecordUtil`
deleted instead, `/customers` is Boot's 500 body, and Tomcat logs `… threw exception [Handler dispatch failed:
java.lang.NoClassDefFoundError: tools/jackson/databind/util/RecordUtil] with root cause` at ERROR, with the trace; `/kitchen`, a
map, still answers (`json`). *(Course 6, unit 08: there is no Jackson 2 jar to take `JDK14Util` from any more — the last course's
`zip` line finds nothing to do, exit 12; `RecordUtil`'s line still shows who writes the answers; `../c6-unit08/`, `jackson`.)*

**Whole paths, by pattern.** A mapping takes a whole path or nothing: `/customersXYZ`, `/customers/`, `/customers.json` and
`/CUSTOMERS` are 404s, and so is `POST /shutdownXYZ`, token and all — TiffinBox keeps serving (Course 5's finale measured the
JDK's server taking it as POST /shutdown). `/customers;x=1` answers 200: a path parameter is not part of the match. A literal beats a variable
beside it, and `{*rest}` takes the rest of a path (the harness's routes). A pattern with `**` in the middle stops the start — exit 1,
`APPLICATION FAILED TO START`, `Invalid mapping pattern detected:` with a caret under the `**`, `{*...} or ** pattern elements should
be placed at the start or end of the pattern`, no stack trace — and Boot's action names the legacy parser,
`spring.mvc.pathmatch.matching-strategy` (Boot's default `path-pattern-parser`): with `ant-path-matcher` the route answers 200, and
the log holds 0 WARN lines (`patterns`). This tree never sets it.

**Who times and logs each answer.** TiffinBox's own timer and its line per answer are retired with the router's handler. Boot's
`http.server.requests` times every answer, tagged with the mapping's pattern, never the URL a client typed: `/customers` and
`/customers?mealType=VEG` are one series, `uri="/customers"`; a 404 is `uri="/**"`; a verb no mapping takes — and OPTIONS —
`uri="UNKNOWN"` (`timers`). Per request, the `kitchen` group is quiet; Boot's `web` group at DEBUG prints Spring MVC's lines, and
they show the request as the client typed it: `GET "/customers?mealType=VEG", parameters={masked}`. Course 5's line per answer
never held what the client typed; Spring MVC's DEBUG line does.

**What stops it.** POST /shutdown with the token answers `{"stopping":true}`, `Content-Length: 17`, and the JVM exits 0 — with
Boot's graceful shutdown and its two lines, and with `--server.shutdown=immediate` and none: the answer arrived both ways, so
graceful shutdown is not what lets it out (`stop`). *(Course 6, unit 10: two corrections. That `stop`, made again with the answer
held in flight two seconds after the method returned, answered in every run with graceful shutdown and in none with immediate
shutdown: graceful shutdown is what guarantees the reply. And the answer is a `ResponseEntity` now, flushed as it is written: it goes out
chunked, with no `Content-Length`; `../c6-unit10/`, `entity`.)*

**Every form still serves:** the jar, the AOT jar, the native binary — with no hint in the tree, Spring's AOT step registers
`com.tiffinbox.Customer` from the routes' signatures (all its declared fields and constructors, its four accessors), where a copy
whose `customers()` returns `Object` registers none — and the image: each listening on `127.0.0.1` (the image: published there),
each answering the seven `87ca7efc…` (masked), each exit 0 after POST /shutdown (`forms`).

Evidence for every sentence in this section: `../c6-unit06/` (`receipts.sh`, eleven captures).

## Course 6 · unit 07 — @PathVariable, @RequestParam: values from the request, as parameters (2026-10-14)

Until this unit TiffinBox's routes took nothing from a request but its path: `/customers?mealType=VEGAN` answered all four
customers, and `/customers/Ravi` was Spring's 404 — no mapping took it (`../c6-unit07/`, `change`). From this unit on, a route takes
values from the request as **method parameters**, each named by an annotation, and one of Spring MVC's **argument resolvers** — the
objects that fill one kind of parameter each — fills it before the method runs. Two Java files changed, besides this README:
- `TiffinBoxServer.java` — **`GET /customers/{name}`**, new: `Customer customer(@PathVariable String name)` — a **path variable**,
  one segment of the path — answers the customer whose name is exactly that one; a name nobody has throws Spring's
  **`ResponseStatusException`** with 404 *(Course 6, unit 15: `CustomerNotFound` since, which the controller advice `TiffinBoxErrors`
  answers — 404 and `{"error":"no customer named Nobody"}`; `../c6-unit15/`, `notfound`)* *(Course 6, unit 16: a problem detail since —
`application/problem+json`, title `Customer not found`, the name a member of its own; `../c6-unit16/`, `own`)*. **`GET /customers`** takes `@RequestParam(required = false) MealType mealType` — a
  **request parameter**, from the query string — and keeps the customers of that meal type; without it, or with an empty value, all
  four. **POST /shutdown** takes its token as `@RequestHeader(name = "X-Shutdown-Token", required = false) String token`, where it read
  the servlet request's header itself: `holdsToken()` takes the header's value (`null` when there is none), and the 403 is still the
  method's own (`response.setStatus(403)`). The Javadoc gains the paragraph that says so: 176 lines → 197. *(Course 6, unit 10: the
  403 is the method's return value since, `ResponseEntity.status(HttpStatus.FORBIDDEN)`; `../c6-unit10/`, `entity`.)*
- `tiffinbox-core`'s `CustomerRepository.java` — **`findByName(String)`**, new: one row by exact name, the name a parameter of the SQL,
  never part of it — an `Optional<Customer>`: 50 lines → 64.

- `application.yaml` — its first document holds two loggers at INFO, Boot's default, whatever level the rest is given: Tomcat's
  `Http11InputBuffer` and Spring MVC's `HandlerMethod`, the two that print the token at TRACE (below).

The POMs, the Dockerfile, `compose.yaml`, the meters, the indicator, the guard and the rest of `tiffinbox-core` are not touched — 18
files byte for byte — and the executable jar holds the same 58 libraries. *(Course 6, unit 08: 56 — Jackson 2 is
out; `../c6-unit08/`, `jackson`.)*

```bash
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers/Ravi
curl -s -w ' %{http_code}\n' 'http://127.0.0.1:18431/customers?mealType=VEGAN'
```

**Registered with their types, filled by name.** At TRACE, Spring MVC's `RequestMappingHandlerMapping` lists six of TiffinBox's
routes now, each with its parameter types — `{GET [/customers/{name}]}: customer(String)`, `{GET [/customers]}: customers(MealType)`,
`{POST [/shutdown]}: shutdown(String,HttpServletResponse)` *(Course 6, unit 10: `shutdown(String)` since — the servlet response
parameter is gone; `../c6-unit10/`, `entity`)* — and `8 mappings in 'requestMappingHandlerMapping'`; the routing table
(`/actuator/mappings`, exposed for one run) has 15 rows, TiffinBox's six each naming a verb, and the `/customers` row's
`requestMappingConditions.params` is `[]`: the meal type is no part of the match (`change`). *(Course 6, unit 08: seven routes —
`{POST [/customers]}: add(Customer)` the seventh — 9 mappings and 16 rows; `../c6-unit08/`, `change`.)* *(Course 6, unit 12:
`add(Customer,BindingResult)` since; `../c6-unit12/`, `constraints`.)* *(Course 6, unit 22: ten routes, 19 rows; `../c6-unit22/`, `negotiate`.)* The first time it meets a parameter,
Spring MVC's `RequestMappingHandlerAdapter` asks its 28 argument resolvers in order — the first that takes it fills it, and that
choice is cached for the parameter:
`@PathVariable` → `PathVariableMethodArgumentResolver`, `@RequestParam` → `RequestParamMethodArgumentResolver`, `@RequestHeader` →
`RequestHeaderMethodArgumentResolver`, the `HttpServletResponse` → `ServletResponseMethodArgumentResolver` *(Course 6, unit 10: no
route takes it since)* (the course's harness
reads them off the running adapter: `../c6-unit07/`, `resolvers`). The path variable and the request parameter give no name of
their own, so each is found by the **parameter's name** (the header names its own, `X-Shutdown-Token`) — and Spring reads a parameter's
name only where javac's `-parameters` writes it: Boot's parent POM turns it on (`spring-boot-starter-parent-4.1.1.pom`, its compiler
plugin, `<parameters>true</parameters>`), and `javap -v -p` reads the names in `TiffinBoxServer.class`. A route compiled without the
flag starts cleanly and answers its first request with a 500: `Ensure that the compiler uses the '-parameters' flag.` (`resolvers` C).

**What a missing or malformed value gets** (`path`, `params`, `token`):
- `/customers/Ravi` → the record; `/customers/Nobody` → 404, Boot's body in the shape of `/nowhere`'s
  (`{"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"}`), no WARN line, and no reason in the body (Course 6's
  *Boot's Default Error Response* opens it). *(Course 6, unit 15: `{"error":"no customer named Nobody"} 404` since, still no WARN line —
  TiffinBox's own advice answers; `../c6-unit15/`, `notfound`.)* *(Course 6, unit 16: a problem detail since — `{"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"}`, `application/problem+json`; `../c6-unit16/`, `own`.)* `Ravi.json` is the whole segment (no suffix match); `%20` arrives as a space; an encoded
  slash, `%2F`, is Tomcat's own HTML `HTTP Status 400 – Bad Request` page, not Spring's JSON.
- `?mealType=VEG` → Ravi and Sunil; `?mealType=veg` → **400**, and one WARN line at Boot's default level, Spring MVC's
  `DefaultHandlerExceptionResolver`: `MethodArgumentTypeMismatchException: Method parameter 'mealType': Failed to convert value of
  type 'java.lang.String' to required type 'com.tiffinbox.MealType'`. *(Course 6, unit 16: a problem detail since — `"detail":"Failed to convert 'mealType' with value: 'veg'"` — and no WARN line: Boot's problem-details handler resolves it, silently; `../c6-unit16/`, `flag`.)* The text must be one of `MealType`'s names, as the enum spells
  them. `?mealType=` (empty) → all four; the parameter twice → the first.
- POST /shutdown with no header, or the token under a misspelt name (`X-Shutdown-Tokn`), is the method's own 403
  (`required = false`). With `required = true` — measured on a copy, one attribute changed — the same requests are Spring MVC's 400,
  with a WARN line that names the header (`MissingRequestHeaderException`), and TiffinBox's method never answers forbidden. *(Course 6,
unit 16: that copy is not re-measured on this tree; with problem details on, the 400s Spring MVC decides that `flag` sends are problem
details with no WARN line — `../c6-unit16/`, `flag`.)*

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.root=trace
```

**A parameter is something TRACE prints — so two loggers are held at INFO.** At TRACE, Spring MVC's `HandlerMethod` prints the
arguments it bound — `Arguments: [<the token>, …]` — so the token, a parameter now, would be in that log, and Boot's `web` group at
TRACE is enough; Tomcat's `Http11InputBuffer` prints each request it received, its headers among the lines, when its logger is at
TRACE (Boot's log labels the record DEBUG) — the token there too, since TiffinBox moved onto Tomcat. `application.yaml`'s first
document holds both at INFO, Boot's default level. Measured with a fake token of its own, through the seven (`../c6-unit07/`, `trace`): this tree, 0
copies with every logger at TRACE (the line above, Course 5's logging lesson's) and 0 with the web group at TRACE; a copy without
those lines, 2 and 1; the previous tree, 1 (Tomcat's). TiffinBox itself still logs neither the header nor the token. Never run
TRACE with a real token in the config tree.

**One series per route.** Boot's timer files `/customers/Ravi` and `/customers/Meera` under one series, `uri="/customers/{name}"`
(200, 2), and `/customers/Nobody` and `/customers/7` beside them (404, 2); `?mealType=VEG` and `?mealType=veg` are `uri="/customers"`
(200 and 400). The encoded slash is not counted: Tomcat answered it before Boot's timer — a servlet filter — saw it (`timer`: 7
requests, 6 counted).

**Every form still serves:** the jar, the AOT jar, the native binary — Spring's AOT step's metadata names `com.tiffinbox.Customer` and
`com.tiffinbox.MealType` — and the image: each on `127.0.0.1` (the image: published there), each answering
the seven `87ca7efc…` (masked), and, on a second start of each, `/customers/Ravi` 200, `/customers/Nobody` 404,
`?mealType=VEGAN` → Priya, `?mealType=vegan` 400 and POST /shutdown without the header 403 (`forms`).

Evidence for every sentence in this section: `../c6-unit07/` (`receipts.sh`, ten captures).

## Course 6 · unit 08 — @RequestBody: a new customer, as JSON; one Jackson left (2026-10-14)

Until this unit TiffinBox took nothing from a request's body: a POST to `/customers` was Spring MVC's 405, with one WARN line —
no mapping took POST there (`../c6-unit08/`, `change`). From this unit on, **`POST /customers`** takes a new customer as the
request's **body**, in JSON, stores it and answers with it. Four files changed, besides this README:
- `TiffinBoxServer.java` — **`POST /customers`**, new: `Customer add(@RequestBody Customer customer)`. `@RequestBody` hands the method
  the request's body, read into the Course 1 record before the method runs; the method stores it (`repo.add`) and returns it — 200
  and the record (statuses on purpose are Course 6's *Responses: ResponseEntity and Status Codes*). *(Course 6, unit 10: 201, the
  record and a Location since — a `ResponseEntity`; a name that is taken, 409; `../c6-unit10/`, `created`, `conflict`.)* *(Course 6,
unit 12: and a body that breaks one of the record's rules, 400, each broken field named — `@Valid`, and a `BindingResult` beside it;
`../c6-unit12/`, `answer`.)* The Javadoc gains the paragraph
  that says how: 197 lines → 215.
- `tiffinbox-core`'s `CustomerRepository.java` — **`add(Customer)`**, new: one `INSERT`, the record's four values parameters of the
  SQL, never part of it: 64 lines → 80.
- `tiffinbox-web/pom.xml` — `com.fasterxml.jackson.core:jackson-databind`, **out**: TiffinBox's own JSON library since Core Java II,
  Jackson 2, which has written none of TiffinBox's answers since Course 6's request-mapping lesson. Two comments rewritten.
- `pom.xml` — `<jackson-2-bom.version>2.22.2</jackson-2-bom.version>` and its comment, **out**: with Jackson 2's library gone, it
  pinned only the annotations jar both Jacksons read (below).

The executable jar holds 56 libraries, where it held 58: `jackson-databind-2.22.2.jar` and `jackson-core-2.22.2.jar` are out, and
`jackson-annotations-2.22.jar` is `jackson-annotations-2.21.jar` (`jackson`). `application.yaml`, `spring.factories`, the Dockerfile,
`compose.yaml` and the other classes are not touched — 20 of the tree's 25 files byte for byte.

```bash
curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:18431/customers
```

**Registered, then read.** At TRACE (the request-mapping lesson's line), `RequestMappingHandlerMapping` lists seven of TiffinBox's
routes now — `{POST [/customers]}: add(Customer)` the seventh *(Course 6, unit 12: `add(Customer,BindingResult)` since;
`../c6-unit12/`, `constraints`)* — and `9 mappings in 'requestMappingHandlerMapping'`; the routing
table has 16 rows, two of them `/customers`, one per verb, and the new row's `requestMappingConditions.consumes` is `[]`: the route
names no media type of its own (`change`). *(Course 6, unit 22: 19 rows since, three of them `/customers` — `DashboardPage`'s `POST`
consumes `application/x-www-form-urlencoded`; `../c6-unit22/`, `negotiate`.)* Spring MVC's `RequestMappingHandlerAdapter` holds six **message converters** — the
objects that turn a request's body into a parameter, and a return value into an answer's bytes — and asks them in order which can
read the parameter's type from the body's **media type**, the type the request's `Content-Type` header names. For a `Customer`, only
the sixth says yes, `JacksonJsonHttpMessageConverter`, for `application/json`, and it writes one too; none reads a `Customer` from a
form (`application/x-www-form-urlencoded`) or from `text/plain` (`chain`: the course's harness, reading the running adapter). *(Course 6,
unit 22: still none of the converters — but a form's fields are bound onto a `Customer` since, by Spring MVC's data binder, on
`DashboardPage`'s `POST /customers`; `../c6-unit22/`, `form`.)* Its
mapper is Boot's bean `jacksonJsonMapper`, Jackson 3's `JsonMapper`. A record has no setters and no constructor without arguments:
Jackson builds it through its canonical constructor, once per body (a harness record whose compact constructor counts its calls:
1, then 2 — `body`).

**A body is in the log at DEBUG.** With Boot's `web` group at DEBUG (the embedded-Tomcat lesson's line), Spring MVC's
`RequestResponseBodyMethodProcessor` logs the body it read — `Read "application/json;charset=UTF-8" to [Customer[name=Asha,
mealsPerDay=2, pricePerMeal=110, mealType=VEG]]` — and the record it wrote back: six lines for the POST, every value in them
(`body`). Harmless for a customer; never run DEBUG on a route whose body carries a secret.

**The Content-Type is on the command line.** curl's `--data` names a form, `application/x-www-form-urlencoded`, unless told
otherwise: without `-H 'Content-Type: application/json'` the same POST is Spring MVC's **415**, Boot's body, and the answer's `Accept`
header names what it would read — `application/json, application/*+json` — with one WARN line, `HttpMediaTypeNotSupportedException:
Content-Type 'application/x-www-form-urlencoded;charset=UTF-8' is not supported`; nothing is stored (`ctype`). The 415 is the
converters', not the route's. *(Course 6, unit 16: a problem detail since, and no WARN line; `../c6-unit16/`, `flag`.)* *(Course 6, unit
22: no longer a 415 — a form's type reaches `DashboardPage`'s `POST /customers` since, which answers 200 with the form and one raw
message, `Failed to convert value of type null to required type int; …`; nothing is stored; `../c6-unit22/`, `form`.)*

**What doesn't fit** (`misfit`) is a 400, Boot's body, the reason only in one WARN line of Spring MVC's
`DefaultHandlerExceptionResolver`, Jackson's message inside it: malformed JSON, an empty body (`Required request body is missing`),
an array, a missing `mealsPerDay` (``Cannot map `null` into type `int` ``), trailing text after the object. **Stored, with no word in
the log:** an unknown property is ignored (`"loyaltyPoints":5`, Core Java II's own unknown field — that lesson's Jackson 2 refused
one by default; Jackson 3 does not, Boot's mapper and a plain `JsonMapper` alike: `chain`), `"2"` is read as 2 — and **`2.7` meals a
day is stored as 2**. *(Course 6, unit 09: refused since — a 400 and one WARN line, Jackson's reason in it: `application.yaml`'s
`spring.jackson.deserialization.accept-float-as-int: false`; `"2"`, an unknown property and a misspelt key are read as before;
`../c6-unit09/`, `float`.)* *(Course 6, unit 16: each such 400 is a problem detail since, `"detail":"Failed to read request"`, and logs no WARN line: Jackson's reason is in neither the answer nor the log — `--spring.mvc.log-resolved-exception=true` puts it back in a WARN line, one per resolved exception; `../c6-unit16/`, `flag`.)*

**What nothing checks yet** (`unchecked`): `{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}` → 200 *(Course 6, unit
10: 201 since, its Location `…/customers/` a 404; `../c6-unit10/`, `created`)*, stored, and
`/customers` lists it first. A misspelt key (`"mealTyp"`) is ignored, so the meal type arrives as `null`, and H2 refuses the row —
`NULL not allowed for column "MEAL_TYPE"`, H2's code 23502 — in Tomcat's ERROR line, with a trace of over 50 frames, and Boot's 500;
a name already taken is H2's `Unique index or primary key violation`, 23505 — the same exception class — another 500 and trace.
Course 6's *Validation on the Way In* and *Responses: ResponseEntity and Status Codes* take these on. *(Course 6, unit 10: a name
already taken is 409 since, decided by its SQLSTATE, no trace; the misspelt key is still H2's 23502 and a 500; `../c6-unit10/`,
`conflict`.)* *(Course 6, unit 12: both bodies refused since, 400, before the database is asked — the first with its four broken
fields named, the misspelt key with `{"mealType":"must not be null"}`; nothing stored, no trace; `../c6-unit12/`, `answer`, `typo`.)*

**One Jackson left** (`jackson`). Jackson 2's databind and core are out of the jar's libraries, and out of the class path Maven lists
for `tiffinbox-web`, the one the native build reads; `jackson-annotations` stays — Jackson 3's `jackson-databind-3.1.5.jar` imports
the same package, `com.fasterxml.jackson.annotation` (its manifest: `version="[2.21,3)"`) — and moves 2.22 → 2.21, Boot's own: the
parent's pin was what kept it at 2.22 (Boot 4.1.1's `<jackson-2-bom.version>2.21.5</jackson-2-bom.version>`; Jackson 3's BOM,
`<jackson.version.annotations>2.21</jackson.version.annotations>`). Boot's condition report (`--debug`): Actuator's
`Jackson2EndpointAutoConfiguration` matched on the previous tree, and here `did not find required class
'com.fasterxml.jackson.databind.ObjectMapper'` — Actuator builds no Jackson 2 mapper. The seven are unchanged, `87ca7efc…` (masked).

**Every form still serves:** the jar, the AOT jar, the native binary and the image: each on `127.0.0.1` (the image: published there),
each answering the seven `87ca7efc…` (masked), and, on a second start of each, the new customer 200 *(Course 6, unit 10: 201 since,
with a Location; `../c6-unit10/`, `forms`)* and read back by name, the
form's 415, and `2.7` meals stored as 2 (`forms`). *(Course 6, unit 09: refused, 400, in all four forms since;
`../c6-unit09/`, `forms`.)* *(Course 6, unit 22: the form's 415 is gone — a form's type reaches the form's route; `../c6-unit22/`,
`form`.)*

Evidence for every sentence in this section: `../c6-unit08/` (`receipts.sh`, nine captures).

## Course 6 · unit 09 — spring.jackson: one key, and two point seven meals is refused (2026-10-14)

Until this unit a number with a decimal point, sent for one of the record's whole-number fields, was read by dropping the
fraction: `"mealsPerDay":2.7` was stored as 2 — 200, and not a word in the log (`../c6-unit09/`, `float`, before). From this unit
on it is refused. One file changed, besides this README:
- `tiffinbox-web/src/main/resources/application.yaml` — three lines in its **first document**, under `spring:`, above the `---`
  (moved below it, under the second document's `spring:`, a run without the profile `rush` never reads them: `float`, C), and the
  four comment lines above them:
  `spring.jackson.deserialization.accept-float-as-int: false`. `spring.jackson.*` is Boot's family of keys for the JSON mapper it
  builds — the bean `jacksonJsonMapper`, Jackson 3's `JsonMapper`, the one Spring MVC's JSON converter reads request bodies and
  writes answers with — and `deserialization` takes Jackson's own feature names, here `ACCEPT_FLOAT_AS_INT`.

The POMs, the Java sources, `spring.factories`, the Dockerfile and `compose.yaml` are not touched — 23 of the tree's 25 files byte
for byte — and the executable jar holds the same 56 libraries.

```bash
curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:18431/customers
```

**Refused, and logged once.** That POST is now Spring MVC's 400, Boot's body, with one WARN line of Spring MVC's
`DefaultHandlerExceptionResolver` holding Jackson's reason: ``Cannot coerce Floating-point value (2.7) to `int` value (but could if
coercion was enabled using `CoercionConfig`)``; nothing is stored (`/customers/Mohan` → 404). *(Course 6, unit 16: not logged since — a problem detail, `Failed to read request`, 0 WARN lines; `../c6-unit16/`, `flag`.)* The key looks at how a number is
written, not at its value: `2.0` is refused too, and so is a price of `110.5` (`pricePerMeal` is a whole number as well).
**What it leaves alone:** `"2"`, a number sent as text, is still read as 2; an unknown property (`"loyaltyPoints":5`) is still
ignored, and so is a misspelt key — `"mealTyp"` still reaches H2 as a missing meal type, H2's 23502 refusal and Boot's 500; a
missing `mealsPerDay` is still a 400 (`float`, A). *(Course 6, unit 12: the misspelt key is refused since, before H2 is asked — 400,
`{"mealType":"must not be null"}`; an unknown property is still ignored; `../c6-unit12/`, `typo`.)* Unknown properties stay ignored on purpose: refusing them — `custom` B does it in
code — turns the misspelt key into an opaque 400 whose reason is only in the log; Course 6's *Validation on the Way In* takes the typo
on. The run line with `--spring.jackson.deserialization.accept-float-as-int=true` turns Jackson's default back on: stored as 2 again
(`float`, B).

**Boot's mapper, read off the running application** (`bean`: the course's harness, joined by `--spring.main.sources`). One bean of
type `JsonMapper`, `jacksonJsonMapper` — the JSON converter's own mapper; Actuator's endpoints write with another, their own
`EndpointJsonMapper`; two modules registered (Boot's `JacksonComponentModule` and `JacksonMixinModule`; a plain
`JsonMapper.builder().build()` has none); no naming strategy. Of the 120 features of eight kinds it reads (every constant of
`MapperFeature`, `DeserializationFeature`, `SerializationFeature`, `DateTimeFeature`, `EnumFeature`, `JsonNodeFeature`,
`StreamReadFeature` and `StreamWriteFeature`), on the previous tree **all 120** are a plain mapper's — Boot's defaults are Jackson 3's
own — and here **one** differs: `ACCEPT_FLOAT_AS_INT`, false. Records keep the order they declare their components in, a class's
properties are sorted, a `LinkedHashMap` keeps its keys' order (`order`): TiffinBox answers with records and such maps, which is why
its JSON bytes never moved when Jackson 3 began writing them.

**Boot's other knobs, measured on this tree** (`defaults`, `naming`, `rename`, `custom`, `three` — none of them in the anchor):
`--spring.jackson.use-jackson2-defaults=true` ("the same defaults as Spring Boot previously used for Jackson 2", Boot's metadata) flips
13 of the 120 features — a missing `int` becomes 0 and is stored, text after the JSON is accepted, a class keeps its declared order, an
error's timestamp ends `+00:00` instead of `Z` — and leaves `2.7` refused: the key above wins. `--spring.jackson.property-naming-strategy=SNAKE_CASE`
changes one of the seven's lines, `/customers`' keys (`meals_per_day`; the maps keep theirs, Actuator's mapper is not touched, and a
`@JsonProperty` name wins); `snake_case` stops the start — exit 1, no failure analysis, the last cause `Constant named 'snake_case' not
found`. A `JsonMapperBuilderCustomizer` bean changes Boot's mapper and not Actuator's. `java.time` values are written as ISO-8601
strings with no module registered, and Core Java II's `new ObjectMapper().configure(…)` does not compile against Jackson 3: its
setting goes on the builder.

**Every form follows the key:** the jar, the AOT jar, the native binary and the image — each on `127.0.0.1` (the image: published
there), each answering the seven `87ca7efc…` (masked), and, on a second start of each, the new customer 200 *(Course 6, unit 10: 201
since, with a Location; `../c6-unit10/`, `forms`)* and two point seven meals
refused, 400, then not found. Boot reads the key when TiffinBox starts, under Spring's AOT step and in the binary too: on a third start
of the AOT jar and of the binary, the flag above turns it back on (`forms`).

Evidence for every sentence in this section: `../c6-unit09/` (`receipts.sh`, ten captures).

## Course 6 · unit 10 — ResponseEntity: 201 and a Location, 409 for a name that is taken (2026-10-14)

Until this unit a new customer was answered 200, the status Spring MVC gives a route that returns its body alone; a name already
taken was H2's refusal, Boot's 500 and an ERROR line with a trace of over 50 frames; and POST /shutdown set its 403 on the servlet
response itself (`../c6-unit10/`, `conflict` and `entity`, before). From this unit on, TiffinBox's two POST routes return a
**`ResponseEntity`** — Spring's type for a whole answer: its status code, its headers and its body, as one return value. One Java file
changed, besides this README:
- `TiffinBoxServer.java` — **`POST /customers`** is `ResponseEntity<Customer> add(@RequestBody Customer customer)` *(Course 6, unit 12:
  `ResponseEntity<?> add(@Valid @RequestBody Customer customer, BindingResult errors)` since — a body that breaks a rule is a 400;
  `../c6-unit12/`, `constraints`)*. Stored, it answers
  **201 Created**, the record, and a **`Location`** header, the new customer's own URL:
  `ServletUriComponentsBuilder.fromCurrentRequestUri().path("/{name}").buildAndExpand(customer.name()).toUri()` — this request's URL
  without its query string, the name appended and encoded — handed to `ResponseEntity.created(location).body(customer)`. A name that
  is taken: **409 Conflict**, no body, `ResponseEntity.status(HttpStatus.CONFLICT).build()`. *(Course 6, unit 16: a problem detail since, `a customer named X already exists`; `../c6-unit16/`, `own`.)* The method decides by H2's **SQLSTATE** —
  the five-character code a database reports with a refusal — `23505`, the unique index's (`NAME_TAKEN.equals(e.getSQLState())`);
  every other refusal is thrown on and stays Spring MVC's 500, a misspelt key's missing meal type, `23502`, among them, though H2
  throws both with one exception class. **`POST /shutdown`** is `ResponseEntity<Map<String, Object>> shutdown(@RequestHeader(…) String
  token)`: the 403 is its return value, `ResponseEntity.status(HttpStatus.FORBIDDEN).body(…)`, the 200 `ResponseEntity.ok(…)`; the
  `HttpServletResponse` parameter, its `setStatus(403)` and their import are gone. *(Course 6, unit 16: `ResponseEntity<?> shutdown(…)` since, its 403 a problem detail, `the shutdown token is missing or wrong`; `../c6-unit16/`, `change`.)* The Javadoc gains the paragraph that says how: 215
  lines → 241.

The POMs, `application.yaml`, `CustomerRepository`, the Dockerfile and `compose.yaml` are not touched — 23 of the tree's 25 files byte
for byte — and the executable jar holds the same 56 libraries (`entity`).

```bash
curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:18431/customers
```

**201, and a Location you can follow.** That POST — the request-body lesson's, its answer's Location printed — answers the record,
`201` and `Location: [http://127.0.0.1:18431/customers/Asha]`; the binding lesson's one-customer line with that URL answers 200 and the
record. A name with a space, `Sunil K`, comes back `…/customers/Sunil%20K`, and that URL answers 200 too; typed by hand with a raw
space, curl refuses to send it (the exercise). OPTIONS on `/customers` lists `GET,HEAD,OPTIONS,POST`, on a Location `GET,HEAD,OPTIONS`
(`created`; the verbs sorted: Spring MVC's order moves between runs). Nothing checks a body's values yet: the request-body lesson's
empty name is created too, `201`, and its Location, `…/customers/`, is Spring's 404 — none of TiffinBox's routes takes that path; the static files row does, and finds no file. Course 6's
*Validation on the Way In* refuses that body. *(Course 6, unit 12: refused since — 400, its four broken fields named, nothing
stored; `../c6-unit12/`, `answer`.)*

**The Location is the request's host.** Spring builds it from the URL the request came to, and that URL's host and port are the ones
the request's `Host` header names: curl names `127.0.0.1` and the port it dialled; a client that sends `Host: kitchen.localhost` gets
`Location: [http://kitchen.localhost/customers/Asha]` — no port, a name TiffinBox was never given (`host` B). `X-Forwarded-Host` and
`X-Forwarded-Proto`, the headers a proxy adds, are ignored here (`host` C): Boot's `server.forward-headers-strategy` has no default
value (its metadata), and Boot deduces the strategy from the cloud platform it detects — told it runs on Kubernetes, it reads them
(`host` E). In the image, TiffinBox listens on 18425 inside its container, and the Location names the port the Mac published —
`127.0.0.1:19397` in `forms`: the request's, again. Spring's `fromCurrentRequest()` would carry the request's query string into the
Location too — `?via=app`, measured on the course's harness (`statuses`); `fromCurrentRequestUri()` leaves it out.

**409 by the database's code.** The same name POSTed twice: `201`, then `409`, no body, no WARN or ERROR line; *(Course 6, unit 16: the 409 a problem detail since; `../c6-unit16/`, `own`)* a name the seed already
holds, `Ravi`, `409`, and Ravi's row unchanged. A misspelt key (`"mealTyp"`) is still H2's 23502, Tomcat's ERROR line with a trace of
over 50 frames, and Boot's 500 (`conflict` A). *(Course 6, unit 12: a 400 since, `{"mealType":"must not be null"}`, no ERROR line;
`../c6-unit12/`, `typo`.)* A copy that tests the exception's class instead of the code —
`SQLIntegrityConstraintViolationException`, which both refusals are — answers the misspelt key 409 too, with nothing in its log
(`conflict` C, labelled). Two POSTs of one name at the same moment are not measured here.

**Who writes the answers.** At DEBUG (Boot's `web` group, the embedded-Tomcat lesson's line) the routes are mapped as before —
`TiffinBoxServer#add(Customer)` *(Course 6, unit 12: `#add(Customer, BindingResult)` since; `../c6-unit12/`, `constraints`)*, and
`#shutdown(String)` where it was `#shutdown(String, HttpServletResponse)` — and Spring MVC's
`HttpEntityMethodProcessor` writes their answers, where `RequestResponseBodyMethodProcessor` did: `Writing [Customer[…]]`, then the
`DispatcherServlet`'s `Completed 201 CREATED` (`entity`). The 403's bytes are the same — `{"error":"forbidden"} 403` — *(Course 6, unit 16: a problem detail since, `application/problem+json`; `../c6-unit16/`, `own`)* but not its
headers: `HttpEntityMethodProcessor` flushes the answer it writes (javap: 2 calls to `ServletServerHttpResponse.flush` in its
`handleReturnValue`, none in the other's), so an answer with a body goes out `Transfer-Encoding: chunked` — the 403, where it went out
with `Content-Length: 21`, while the bodiless 409 says `Content-Length: 0` (`conflict`); *(Course 6, unit 16: the 409 has a body since)* POST /shutdown's `{"stopping":true}` lost its `Content-Length: 17` the same way. The seven are unchanged, `87ca7efc…` (masked):
they print status, type and body, never a length.

**Statuses by accident** (the course's harness, `statuses`): a name nobody has, answered four ways — TiffinBox's own route, Spring's
`ResponseStatusException`: 404 and Boot's body *(Course 6, unit 15: TiffinBox's route throws `CustomerNotFound` since — 404 and
`{"error":"no customer named Nobody"}`, its controller advice's body; `../c6-unit15/`, `notfound`)* *(Course 6, unit 16: a problem
detail since, the name a member of its own; `../c6-unit16/`, `own`)*; `ResponseEntity.of(…)` with an empty `Optional`: 404, no body; `null`: 200, no body;
the `Optional` itself: 200 and the word `null`. None of them logs a WARN line. `@ResponseStatus(HttpStatus.CREATED)` on a route answers
201 with no Location.

**Every form still serves:** the jar, the AOT jar, the native binary — Spring's AOT step's metadata names `com.tiffinbox.Customer` —
and the image: each on `127.0.0.1` (the image: published there), each answering the seven `87ca7efc…` (masked), and, on a second start
of each, a new customer 201 with a Location on 127.0.0.1 and that form's own port, the Location followed 200, the same name again 409
and POST /shutdown without the token 403 (`forms`).

Evidence for every sentence in this section: `../c6-unit10/` (`receipts.sh`, seven captures).

## Course 6 · unit 12 — @Valid: a body checked on its way in, and a 400 that names each field (2026-10-15)

Until this unit nothing checked a request body's values. The request-body lesson's empty name — `{"name":"","mealsPerDay":0,
"pricePerMeal":-5,"mealType":"LUNCH"}` — was created: 201, its Location `…/customers/` a path no mapping takes, 404, and `/customers`
listed it first; a misspelt key (`"mealTyp"`) left the meal type `null`, and H2 refused the row — its code 23502, Tomcat's ERROR line
with a trace of over 50 frames, Boot's 500 (`../c6-unit12/`, `before`). From this unit on, the record carries its rules, and Spring MVC
checks each body against them before the method runs. Two Java files changed, besides this README:
- `tiffinbox-core`'s `Customer.java` — the record's four components carry **constraints**, Bean Validation's annotations (its API jar
  has been the core POM's since Course 5's settings record): `@NotBlank name`, `@Min(1) @Max(3) mealsPerDay`, `@Min(1) pricePerMeal`,
  `@NotNull @Pattern(regexp = "VEG|NON_VEG|VEGAN") mealType` — six constraints. A value breaks at most one rule of its component:
  `@Pattern` lets a missing meal type through and `@NotNull` an empty one, so each field that fails has one message (with `@NotBlank`
  beside `@Pattern`, an empty meal type would break both). The annotations check nothing by themselves, and a record the database or
  the seed builds is never checked. The Javadoc says so: 8 lines → 27.
- `TiffinBoxServer.java` — **`POST /customers`** is `ResponseEntity<?> add(@Valid @RequestBody Customer customer, BindingResult errors)`.
  **`@Valid`** asks Spring MVC to check the body against the record's constraints once Jackson has read it; every rule it broke is in
  the **`BindingResult`** — the parameter straight after the one it reports on — and the method answers them itself: **400 Bad
  Request**, its body each broken field and its rule's message, sorted by field name (`fieldMessages`, a `TreeMap`); nothing is stored.
  A body that keeps every rule goes on as before: 201 and a Location, or 409 for a name that is taken (H2's SQLSTATE 23505, the test
  kept). The return type names no body type any more: the 400's body is a map, the 201's the record. *(Course 6, unit 16: a `ProblemDetail` since, the map its member `errors`; `../c6-unit16/`, `change`.)* The class carries no
  `@Validated` (below). The class Javadoc gains the paragraph that says how, and the method's its own: 241 lines → 273.

The POMs, `application.yaml`, `CustomerRepository`, the Dockerfile and `compose.yaml` are not touched — 22 of the tree's 25 files byte
for byte — and the executable jar holds the same 56 libraries (`constraints`).

```bash
curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:18431/customers
```

**A 400 that names each field.** That POST — the response lesson's Location line with the request-body lesson's empty name — answers
`{"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be
blank","pricePerMeal":"must be greater than or equal to 1"} 400 · Location: []`: four rules broken, four fields, none twice, no WARN
line, and `/customers` still lists the four customers TiffinBox seeds. Four meals a day: `{"mealsPerDay":"must be less than or equal
to 3"}`. Asha's body: 201 and her Location; the same again: 409 — a body that keeps every rule still reaches the unique index
(`answer`, A). *(Course 6, unit 16: the same four fields since, as the member `errors` of a problem detail — `{"detail":"the customer breaks 4 rules",…,"title":"Invalid customer","errors":{…}}`, `application/problem+json`; `../c6-unit16/`, `own`.)* At TRACE (the request-mapping lesson's line) the route registers as `{POST [/customers]}: add(Customer,BindingResult)`,
still 9 mappings; at DEBUG (Boot's `web` group) Spring MVC maps the POST to `TiffinBoxServer#add(Customer, BindingResult)`, logs the
body it read, and `HttpEntityMethodProcessor` writes the method's map: `Completed 400 BAD_REQUEST` (`constraints`). **Without the
`BindingResult`** — a copy with that parameter, and the three lines that answer from it, deleted (`answer`, B) — Spring MVC answers for
the method: its `MethodArgumentNotValidException`, Boot's 400 body (`timestamp`, `status`, `error`, `path`: no field), and one WARN line
of Spring MVC's `DefaultHandlerExceptionResolver` that lists the 4 errors, each with the value it was given; their order in that line
moves between runs — Hibernate Validator hands its violations over as a set — which is why the method's map is a `TreeMap`. *(Course 6, unit 16: with problem details on, Boot's handler answers that exception — `{"detail":"Invalid request content.",…,"title":"Bad Request"}`, no field, no WARN line (the harness's `ValidIn`); `../c6-unit16/`, `losers`.)*

**The misspelt key, caught** (`typo`). Jackson still ignores `"mealTyp"`, so the record's meal type is `null` — and that is now
`{"mealType":"must not be null"}`, 400 *(Course 6, unit 16: inside a problem detail since — `"errors":{"mealType":"must not be null"}`,
"the customer breaks 1 rule"; `../c6-unit16/`, `own`)*, before H2 is asked: no ERROR line, nothing stored (`/customers/Rohan` 404). An unknown property
beside a full body (`"loyaltyPoints":5`) is still ignored: 201, and the customer is stored without it — validation checks the record
Jackson built, not the JSON that was sent. `2.7` meals is still Jackson's refusal, before validation: Boot's 400, one WARN line *(Course 6, unit 16: a problem detail since,
`Failed to read request`, and no WARN line — Jackson's reason in neither; `../c6-unit16/`, `flag`)*.

**Who validates** (`validator`: the course's harness, `probe.web.Who`, reading the running application). Spring MVC's handler adapter
binds and validates with the bean `mvcValidator`, Boot's `ValidatorAdapter`; its target is the very `LocalValidatorFactoryBean` Boot
declares as `defaultValidator` — the context's one Bean Validation `Validator`, Hibernate Validator's `ValidatorImpl` once unwrapped:
the kind of object Course 4's validation lesson called by hand, now called by the web layer. On the JVM its messages come in the
request's language — the same body sent with `Accept-Language: de` gets them in German — and, from a client that names none, in the
JVM's locale (`en_US` on this Mac). On macOS the JVM takes the Mac's first language, not `LC_ALL`: start it with `-Duser.language=en
-Duser.country=US` before `-jar` (or `-cp`) for the English messages this README shows (`../c6-unit12/`, every run line). The native
binary's messages were fixed when it was built: it answers English, even to `Accept-Language: de` (`../c6-unit12/`, README, RED B2 #116).

**Which validation runs** (`methods`: the course's harness controllers). A constraint on a request parameter (`@RequestParam @Min(1)
int meals`) on a class with no `@Validated` is Spring MVC's own method validation: `?meals=0` → 400, `HandlerMethodValidationException`
(Boot's body names the exception with `--spring.web.error.include-exception=true`, a key that is false by default), no WARN line. The
same route on a class that carries `@Validated`: Boot's `FilteredMethodValidationPostProcessor` hands the context a subclass of it
(`…$$SpringCGLIB$$<n>`), whose check throws `jakarta.validation.ConstraintViolationException` → 500 and Tomcat's ERROR line with its
trace. On a `final` class `@Validated` stops the start: exit 1, `Could not generate CGLIB subclass … Cannot subclass final class`.
`TiffinBoxServer` is final, so it carries no `@Validated`. `TiffinBoxProperties` is final and carries `@Validated` too, and starts:
Boot's one `MethodValidationExcludeFilter` keeps `@ConfigurationProperties` beans from the post-processor — on a settings record,
`@Validated` asks Boot's binder to check it.

**Boot's error keys** (`keys`). `--spring.web.error.include-binding-errors=always` changes nothing where the method answers — the
anchor's map, the same; on the copy without the `BindingResult`, Boot's body gains `errors`: each field error whole, 8 keys apiece
(its field, the value it was given, its message, the codes and arguments behind them, a binding flag). *(Course 6, unit 16: with problem details on, that copy's answer is Boot's problem detail; `spring.web.error.include-message`, measured, changes Boot's `/error` body — a route's 500 — and leaves a problem detail's bytes as they were; `../c6-unit16/`, `edges`.)* Boot 3's name for the same key
(the same words, under `server` instead of `spring.web`) is in Boot 4.1.1's metadata as deprecated at level error since 4.0.0, and a run
given it changes nothing and logs nothing about it (the exercise).

**Every form validates:** the jar, the AOT jar, the native binary and the image — each on `127.0.0.1` (the image: published there),
each answering the seven `87ca7efc…` (masked), and, on a second start of each, the refused body 400 with its four fields named, a new
customer 201 with a Location on that form's own port, the Location followed 200, the same name again 409 and POST /shutdown without
the token 403 (`forms`). Spring's AOT step registers the same 665 reflection entries as on the previous tree; one changed —
`TiffinBoxServer`'s, `add`'s parameter types — and `Customer`'s entry is the same: the record is still registered by the signatures
that name it, the `@RequestBody` parameter and `GET /customers/{name}`'s return type, though `add` no longer names it in its own.

Evidence for every sentence in this section: `../c6-unit12/` (`receipts.sh`, nine captures).

## Course 6 · unit 15 — @RestControllerAdvice: a 404 that names the customer (2026-10-17)

Until this unit a name nobody has was Spring's `ResponseStatusException`: 404 and Boot's error body —
`{"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"}` — which names no customer and gives no reason
(`../c6-unit15/`, `notfound`, the previous tree). From this unit on, TiffinBox throws an exception of its own, and one class of its own
answers it: an **exception handler** — a method Spring MVC calls with the exception a route threw, whose return value is the answer — in
a **controller advice**, a component whose handlers serve every controller. Two Java files are new, and one changed, besides this README:
- `CustomerNotFound.java` — new: a `RuntimeException`, package-private, final, holding the name it was asked for; its message is `no
  customer named X`.
- `TiffinBoxErrors.java` — new: **`@RestControllerAdvice`** — Spring MVC's `@ControllerAdvice` plus `@ResponseBody`, read off the
  annotation (`notfound`) — final, package-private, with one handler: `@ExceptionHandler(CustomerNotFound.class)`
  `@ResponseStatus(HttpStatus.NOT_FOUND)` `Map<String, String> notFound(CustomerNotFound e)` → `{"error": e.getMessage()}`, the shape
  TiffinBox's own 403 already had. *(Course 6, unit 16: it returns a `ProblemDetail` since — 404, title `Customer not found`, the
  message as the detail, the name as a member; `@ResponseStatus` gone; the 403 a problem detail too; `../c6-unit16/`, `change`, `own`.)*
- `TiffinBoxServer.java` — `GET /customers/{name}` throws `new CustomerNotFound(name)` where it threw `ResponseStatusException`; that
  import is gone, and the Javadoc says who answers now: 273 lines → 274.

The POMs, `application.yaml`, the Dockerfile and `compose.yaml` are not touched, and the executable jar holds the same 56 libraries
(`change`).

```bash
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers/Nobody
```

**A 404 that names the customer.** That line — the path-variable lesson's one-customer line, its name one nobody has — answers
`{"error":"no customer named Nobody"} 404`; `/customers/Sunil%20K` answers `{"error":"no customer named Sunil K"} 404` (the path
variable arrives decoded); Ravi still 200. No WARN and no ERROR line for any of them. *(Course 6, unit 16: Nobody's answer is a problem
detail since — `application/problem+json`, the name a member of its own, 0 WARN 0 ERROR; `../c6-unit16/`, `own`, `accept`.)* The seven are unchanged, `87ca7efc…` (masked):
none of them asks for a name (`notfound`). **Who answers:** Spring MVC's `ExceptionHandlerExceptionResolver`, the first of the three
resolvers in its composite (then `ResponseStatusExceptionResolver`, then `DefaultHandlerExceptionResolver`; the DispatcherServlet asks
Boot's `DefaultErrorAttributes` before the composite), keeps an advice cache — here one advice, `TiffinBoxErrors`, at the default order, the lowest *(Course 6, unit 16: two since — Boot's
`ProblemDetailsExceptionHandler` at order 0 first, then `TiffinBoxErrors`; `../c6-unit16/`, `seven`)*; at DEBUG it logs
`Using @ExceptionHandler com.tiffinbox.web.TiffinBoxErrors#notFound(CustomerNotFound)` and `Completed 404 NOT_FOUND`, and no error
dispatch follows — where the previous tree's `ResponseStatusException` was resolved by the second resolver, and Boot's error controller
wrote the body on an error dispatch (`notfound`, at DEBUG).

**Which handler wins** (the course's harness, `precedence`): inside one advice, the nearest exception type (a `NumberFormatException`
went to the handler for it, not to the one for `IllegalArgumentException`); a controller's own `@ExceptionHandler` before any advice;
no handler at all, Boot's 500 and Tomcat's ERROR line. Across advices, **order before nearness**: an advice ordered first that takes
any `RuntimeException` took `CustomerNotFound` from `TiffinBoxErrors` — and, naming no status, answered **200**. Two advices at the
same order are asked in the order the cache lists them — here the harness's, joined by `--spring.main.sources`, before `TiffinBoxErrors`;
a broad handler takes more than its name says (the harness's `IllegalArgumentException` handler also took the type mismatch's 400).
**The status is the handler's to name:** a copy whose handler has no
`@ResponseStatus` answers `{"error":"no customer named Nobody"} 200` (`status` B; the exercise).

**What it costs, for now** (`status` C, D, labelled): a handler's return value is content-negotiated like a route's — so a client
that accepts **only** HTML (`Accept: text/html`) or **only** XML gets **500**, where the previous tree answered both 404: TiffinBox's
JSON-only converters cannot write the handler's map in either, Spring MVC's `ExceptionHandlerExceptionResolver` logs one WARN,
`Failure in @ExceptionHandler com.tiffinbox.web.TiffinBoxErrors#notFound(CustomerNotFound)` (`HttpMediaTypeNotAcceptableException: No
acceptable representation`), and Tomcat logs the `CustomerNotFound` at ERROR; a browser's whole Accept header (Chrome's, sent by
curl), which ends `*/*;q=0.8`, gets the JSON 404 — where the previous tree gave it Boot's Whitelabel 404. Course 6's *ProblemDetail and RFC 9457* answers in a shape every client gets. *(Course 6, unit 16: it does — the same 404 problem detail, `application/problem+json`, for all three Accept headers, no WARN, no ERROR; `../c6-unit16/`, `accept`.)*

**Every form still serves:** the jar, the AOT jar, the native binary and the image — each on `127.0.0.1` (the image: published there),
each answering the seven `87ca7efc…` (masked), and, on a second start of each, `/customers/Nobody` and `/customers/Sunil%20K` 404
with the name, Ravi 200, Nobody for a client that accepts only HTML Boot's 500 page, and POST /shutdown without the token 403
(`forms`). Spring's AOT step registers one reflection entry more than on the previous tree, 665 → 666 — `TiffinBoxErrors` and its
`notFound` handler — and the binary needs no hint. *(Course 6, unit 16: Nobody for a client that accepts only HTML is a 404 problem detail in every form since; `../c6-unit16/`, `forms`.)*

Evidence for every sentence in this section: `../c6-unit15/` (`receipts.sh`, six captures).

## Course 6 · unit 16 — ProblemDetail: one key, and every refusal in RFC 9457's shape (2026-10-17)

Until this unit TiffinBox said "no" in four shapes: Boot's error body with its four keys — `timestamp`, `status`, `error`, `path` — for
every error Spring MVC decided (a path nobody maps, a wrong verb, a value it could not convert or read, a type nobody accepts, a body type
it cannot read); the advice's `{"error":"no customer named Nobody"}`; the 403's `{"error":"forbidden"}`, the same shape; the
validation method's bare field map; and a 409 with no body at all (`../c6-unit16/`, `own`, the previous tree). From this unit on they are one
shape, a **problem detail** — RFC 9457's, the internet standard for an error's shape: a `title`, the `status`, a `detail` that says what
happened, the `instance` (the request's path, which Spring MVC fills in), a `type` (left unset here: RFC 9457 reads a missing one as
`about:blank`), and members of the application's own — written as `application/problem+json`. Three files changed, besides this README:
- `application.yaml` — one key in the first document (line 64, above the `---` at 99), **`spring.mvc.problemdetails.enabled: true`**,
  with its comment: Boot's `ProblemDetailsExceptionHandler` — a `ResponseEntityExceptionHandler`, Spring MVC's own class for this —
  joins as an advice ordered 0, asked before `TiffinBoxErrors`, and answers Spring MVC's own exceptions. Boot's metadata gives the key
  `false` by default (`change`).
- `TiffinBoxErrors.java` — its handler returns a `ProblemDetail`: 404, the exception's message as the detail, the title `Customer not
  found`, and the name as a member of TiffinBox's own, `name`; the `@ResponseStatus` line is gone — the status is the problem detail's.
- `TiffinBoxServer.java` — the 400 is a problem detail whose `errors` member is the field map, the detail the number of rules broken;
  the 409 says `a customer named X already exists`; the 403 `the shutdown token is missing or wrong`; `shutdown()` returns
  `ResponseEntity<?>`; the Javadoc says so: 274 lines → 296.

The POMs, the Dockerfile and `compose.yaml` are not touched — 23 of the tree's 27 files byte for byte — and the executable jar holds the
same 56 libraries and the same 9 web classes (`change`).

```bash
curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:18431/customers/Nobody
```

**One shape.** That line — the exception-handler lesson's, with curl's Content-Type printed — answers
`{"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 ·
Content-Type: [application/problem+json]`: the four standard keys in alphabetical order (Jackson 3 sorts a class's properties), then the
member of TiffinBox's own, and no `type` key (Spring's `ProblemDetail.forStatus` leaves it `null`, read off the class by the harness's
`Who`). The validation lesson's body that breaks four rules: `{"detail":"the customer breaks 4 rules",…,"title":"Invalid customer",
"errors":{…the four fields…}}`; the misspelt key (`"mealTyp"`) `the customer breaks 1 rule`, `{"mealType":"must not be null"}`; POST
/shutdown without the token 403 `the shutdown token is missing or wrong`; a name that is taken 409 `a customer named Asha already
exists` — each `application/problem+json`, no WARN, no ERROR (`own`).

**The seven move by two lines** (`seven`): `87ca7efc…` → **`466c20ed7e0d5439cb052f32ce09de1b`** (masked) — line 5, `GET /nowhere ->
404 application/problem+json {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"}`, and line 6,
`GET /shutdown -> 405 application/problem+json {"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method
Not Allowed"}`; lines 1-4 and 7 byte for byte. A problem detail carries no timestamp: the mask still runs and changes 0 lines. The seven
still log one WARN line — now Spring MVC's `PageNotFound` (`Request method 'GET' is not supported`), where it was
`DefaultHandlerExceptionResolver`'s.

**Every client gets it** (`accept`): `/customers/Nobody` for a client that accepts only HTML, only XML, or a browser's whole Accept
header (Chrome's, sent by curl) — the same 404 problem detail, `application/problem+json`, no WARN, no ERROR. The exception-handler
lesson's tree answered the first two 500, with a WARN line and Tomcat's ERROR line each. Spring MVC writes a problem detail as
`application/problem+json` whatever the client accepts.

**What the key cost** (`flag`): the reasons left the log. With the key, a type mismatch, an unreadable body, two point seven meals, a
415 and a 406 log **0 WARN lines** — Boot's handler resolves them, silently — and an unreadable body's answer says `Failed to read
request`: Jackson's reason is in neither the answer nor the log. The 405 logs one, `PageNotFound`. With the key off for one run
(`--spring.mvc.problemdetails.enabled=false`) they are Boot's four keys again, one `DefaultHandlerExceptionResolver` WARN each, Jackson's
reason inside it, the 406 empty — and TiffinBox's own 404 and 400 still problem details. `--spring.mvc.log-resolved-exception=true` (not
set here) puts the reason back, at a price: one WARN per resolved exception — every 404, `CustomerNotFound` included — and two for a 405.

**What it does not reach** (`edges`): a route's unexpected exception (the harness's `Boom`) is still Boot's `/error` body —
`{"timestamp":"…","status":500,…}`, the Whitelabel page for HTML — with Tomcat's ERROR line; `spring.web.error.include-message=always`
adds `message` to that body and leaves a problem detail's bytes as they were; Tomcat's own HTML 400 for an encoded slash is
untouched. Two shapes, by design: problem details for what TiffinBox and Spring MVC decided, Boot's body for what nobody caught. *(Course 6,
unit 22: for a client that asks for HTML, what nobody caught is TiffinBox's own error page since, `templates/error/5xx.html`, in place
of the Whitelabel page; curl's own Accept still gets Boot's body; `../c6-unit22/`, `errors`.)*

**Every form serves it** (`forms`): the jar, the AOT jar, the native binary and the image — each on `127.0.0.1` (the image: published
there), each answering the seven `466c20ed…` (masked, the mask changing 0 lines), and, on a second start of each, Nobody's problem
detail for curl's own Accept and for only HTML, the four-rule 400 with its `errors`, the 403 and the 409 problem details. Spring's AOT step registers 4
reflection entries more than on the previous tree, 666 → 670 — Boot's `ProblemDetailsExceptionHandler`, its configuration class,
`MessageSourceAware` and `ResponseEntityExceptionHandler`'s `handleException` — and the binary needs no hint.

Evidence for every sentence in this section: `../c6-unit16/` (`receipts.sh`, nine captures).

## Course 6 · unit 22 — Thymeleaf: the dashboard as a page, a form, an error page (2026-10-22)

Until this unit TiffinBox answered every client in JSON: a browser that asked for `/dashboard` got the braces curl gets. From this unit
on, a client that ranks HTML first gets a **page**, rendered on the server by **Thymeleaf**, a template engine — a **template** is an
HTML file whose `th:*` attributes Thymeleaf fills from the model, the values a route hands it, on each request. One file changed and
six are new, besides this README (`change`):
- `tiffinbox-web/pom.xml` — Boot's `spring-boot-starter-thymeleaf`, with its comment (130 → 137 lines). The executable jar holds 61
  libraries where it held 56: `attoparser`, `spring-boot-thymeleaf`, `thymeleaf`, `thymeleaf-spring6`, `unbescape`.
- `DashboardPage.java` (new) — a `@Controller`, not a `@RestController`: its routes return a **view**'s name, which Thymeleaf's view
  resolver turns into `templates/<name>.html`, where a `@RestController`'s return value is the body itself (`@ResponseBody`). `GET
  /dashboard` with `produces = text/html` → `dashboard`; `GET /customers/new` (HTML) → `customer-form`, its **form-backing object** a
  new `Customer`; `POST /customers` with `consumes = application/x-www-form-urlencoded` → the fields bound onto a `Customer`
  (`@ModelAttribute`) and checked (`@Valid`): the form again with each message beside its field, a taken name one more (H2's 23505, as
  `TiffinBoxServer` reads it), or `redirect:/dashboard`. Its nested `TemplateHints` registers `Dashboard.View` and `Customer` for the
  native image, and the customer count is computed in Java (`customerCount`) so the template calls no method on a type nobody
  registered.
- `templates/fragments.html` (three **fragments**, pieces another template pulls in: `head(title)`, `header`, `footer`),
  `templates/dashboard.html`, `templates/customer-form.html` (`th:object`, `th:field`, `th:errors`), `templates/error/5xx.html` — and
  no `templates/error/404.html` (below) — and `static/css/tiffinbox.css`.

25 of the tree's 33 files are byte for byte the previous tree's; the jar's `com/tiffinbox/web` holds 11 classes where it held 9
(`DashboardPage`, `DashboardPage$TemplateHints`).

```bash
curl -s -H 'Accept: text/html' http://127.0.0.1:18431/dashboard
curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data 'name=Lata&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:18431/customers
```

**One URL, two answers** (`negotiate`). The seven are the previous tree's, byte for byte — `466c20ed7e0d5439cb052f32ce09de1b` (masked),
one WARN line (`PageNotFound`) — because curl's own `Accept: */*` still gets `TiffinBoxServer`'s JSON `/dashboard`, and so does
`Accept: application/json`. The routing table (`/actuator/mappings`, exposed for one run) has 19 rows where it had 16: two `GET
/dashboard` rows, `DashboardPage#page` producing `text/html` and `TiffinBoxServer#dashboard` producing anything; two `POST /customers`
rows, the form's consuming `application/x-www-form-urlencoded`; and `GET /customers/new`, producing `text/html`. A client that asks
for HTML alone, or a browser's whole Accept header (Chrome 155's, sent by curl), gets the page — `200 text/html;charset=UTF-8`,
`Content-Language: en-US` (the JVM's locale; `Accept-Language: de` makes it `de`), `<title>Dashboard · TiffinBox</title>`, the four
customers in a table. `GET /customers/new` asked for JSON is `/customers/{name}` with the name `new`: the 404 problem detail.

**Shared pieces** (`fragments`): both pages' `<head>`, `<header>` and `<footer>` come from `fragments.html` (`th:fragment`, pulled in by
`th:replace`) — seven lines each, one different: the `<title>`, the fragment's parameter.

**A form that answers in words** (`form`): the line above → `302`, `Location: http://127.0.0.1:18431/dashboard`, no body — the
**redirect-after-POST** pattern: the browser asks for the page with a GET, so a reload never sends the form again — and the dashboard
lists Lata (5 customers). The validation lesson's four broken rules, as a form → 200, the form again, four messages beside their
fields, in the language the request names (none: the JVM's, pinned — `must not be blank`, …; `Accept-Language: de` → `darf nicht leer
sein`, …). Letters for a number (`mealsPerDay=two`) → one message, Spring's own and raw: `Failed to convert value of type
java.lang.String to required type int; For input string: "two"` (a `typeMismatch` key in a `messages.properties` would word it; not
set here). A taken name → `a customer named Lata already exists`, on the name. The JSON POST is still `201`. **One answer moved:** the
request-body lesson's POST without `-H 'Content-Type: application/json'` (curl's `--data` names a form's type) is no longer a 415 — it
reaches the form's route, and answers 200 with the form and one raw message (`Failed to convert value of type null to required type
int; …`). The form carries no CSRF token: Course 10's subject. 0 WARN, 0 ERROR.

**In a browser** (`browser`; headless Chrome 155, a fresh profile, sealed to 127.0.0.1): typed into the address bar, `/dashboard`
went with Chrome's whole Accept header — the one curl sends above — and came back the page; the form, filled and sent, went as `POST
/customers`, `Content-Type: application/x-www-form-urlencoded`, `Origin` TiffinBox's own, `Sec-Fetch-Site: same-origin` → `302` →
`GET /dashboard` 200, Kiran in the table; four broken rules → the form, four messages in English (`Accept-Language: en-US,en;q=0.9`).
Each seen twice: in Chrome's own record of the request and in the server's (the course's `Dump` filter).

**When it breaks** (`errors`): a name of 61 letters — the table's column holds 60, and nothing checks the length — is H2's refusal
(22001), which nobody handles: `500`, Tomcat's ERROR line, and for a client that asks for HTML the error page is TiffinBox's own,
`templates/error/5xx.html` (`<title>Something broke · TiffinBox</title>`); curl's own Accept still gets Boot's JSON body. A template
with a misspelt name (the exercise's) fails only when the page is asked for: `500`, the same error page, and two ERROR lines —
Thymeleaf's `TemplateEngine` naming the template, the expression and its line, then Tomcat's — while the JSON `/dashboard` stays 200.
**No `error/404.html`:** a copy with one, asked for `/nowhere` or a name nobody has as HTML or with Chrome's Accept header, still
answers the 404 problem detail — every 404 here is answered before the error dispatch (C).

**The template cache** (`devtools`): Boot's `spring.thymeleaf.cache` is `true` by default (its metadata): run from a classes folder,
a template edited while TiffinBox runs is not read again by a page that has already rendered — the dashboard keeps the old footer —
while a page asked for the first time (the form) reads the edited file; with `--spring.thymeleaf.cache=false` every request reads
it. Boot's `spring.template.provider.cache` (no metadata entry; read in `TemplateAvailabilityProviders`) caches whether a template
exists: an error page added while TiffinBox runs is not found until it is `false`. DevTools on this class path adds 10 defaults —
`spring.thymeleaf.cache` and `spring.template.provider.cache` false among them.

**Every form serves it** (`forms`): the jar, the AOT jar, the native binary and the image — each on `127.0.0.1` (the image:
published there), each answering the seven `466c20ed…` (masked), and, on a second start of each, every page: the dashboard, the form,
its four messages, the valid POST's `302` and Lata in the table, TiffinBox's error page for the 61-letter name — the binary's too — and
the JSON POST's `201`. Spring's AOT step registers 687 reflection entries where the previous tree's registered 670 — `Dashboard$View`
with its public methods, `Customer`'s public methods (the hint), `DashboardPage`, Thymeleaf's engine, resolver and configuration
classes — and `templates/**` and `static/**` as resources. The binary's pages say `Content-Language: en` where the jar's say `en-US`:
its run line takes no locale option.

Evidence for every sentence in this section: `../c6-unit22/` (`receipts.sh`, nine captures).

---

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
`-parameters` in this build) is measured in `../c5-unit01/`. (Since Course 5 unit 06 that bare `18431` is ignored, and
since unit 27 it is refused: the start exits 2 before the banner. The port is `--tiffinbox.port=18431`.)

## Course 5 · unit 03 — the Jackson family moves together (2026-09-27)

`pom.xml` no longer pins `jackson-databind` alone: under Boot's parent that left `jackson-core` and
`jackson-annotations` on Boot's 2.21.x beside databind 2.22.2. It sets `<jackson-2-bom.version>2.22.2</jackson-2-bom.version>`
instead — the property Boot's BOM reads — and all three are 2.22.x. The seven responses are unchanged; evidence in
`../c5-unit03/`. *(Course 6, unit 08: the property is gone, with Jackson 2's `jackson-databind`: no Jackson 2 library is left to
pin, and the one Jackson 2 artifact the jar still holds, `jackson-annotations` — Jackson 3 reads the same annotations — takes Boot's
version, 2.21; `../c6-unit08/`, `jackson`.)*

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
written before this change: put `--tiffinbox.port=` in front of the number. Evidence in `../c5-unit06/`. **Since Course 5
unit 27 the old command no longer starts:** a bare argument is refused, exit 2, before the banner and before any port
(below, unit 27).

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
- `TiffinBoxServer` answers POST /shutdown with `403 {"error":"forbidden"}` *(Course 6, unit 16: a 403 problem detail since, `the shutdown token is missing or wrong`)* — and keeps running — unless the request's
  `X-Shutdown-Token` header holds the token (compared with `MessageDigest.isEqual`). Nothing logs the header or the token.
  *(Course 6, unit 07: TiffinBox still logs neither; at TRACE, Spring MVC's `HandlerMethod` prints a route's arguments — the token
  among them, since the header is a parameter — and Tomcat's `Http11InputBuffer` prints each request it received, headers too (a
  TRACE record, labelled DEBUG); `application.yaml` holds both loggers at INFO, so the log holds the token 0 times at
  `root=trace` and at `web=trace`; `../c6-unit07/`, `trace`.)*
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

It answers `{"stopping":true} 200`; without the header, `{"error":"forbidden"} 403`, and TiffinBox keeps running. *(Course 6, unit 16: without it, a 403 problem detail since — `{"detail":"the shutdown token is missing or wrong","instance":"/shutdown","status":403,"title":"Forbidden"}`; `../c6-unit16/`, `own`.)*
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

## Course 5 · unit 14 — one fixed build time (2026-10-05)

One file changed, and nothing else: the root `pom.xml` gains one property,
`<project.build.outputTimestamp>2026-09-15T00:00:00Z</project.build.outputTimestamp>` — the same line, with the same date,
that Course 3's reproducible-build exercise put into its packaging POM (`../c3-unit23/pom.xml`). Every archive the build
writes now stamps each entry with that instant instead of the build's clock, so **two clean builds of the same sources,
in one time zone, give the same bytes**: measured, `tiffinbox-web-1.0.0.jar` built twice has one md5, and the four
layers Boot's index names (`BOOT-INF/layers.idx`: `dependencies`, `spring-boot-loader`, `snapshot-dependencies`,
`application`) unpack to the same files. In another time zone the jar differs: Boot's repackage gives 8 entries under
`BOOT-INF/classes/` an NTFS time field that follows the zone (measured: `TZ=UTC` against `TZ=Asia/Kolkata`, 5.5 hours
apart; every entry's name, content and date the same; `tiffinbox-core`'s jar byte for byte the same) — `../c5-unit14/`,
capture `moved`. Without it, `tiffinbox-core`'s jar — the same classes, 18 of its 19 entries dated by its build — and
with it the `application` layer of Boot's jar changed on every build, even with no change at all.

Nothing about building or running TiffinBox changes: the build, the jar's name and the run command are unit 13's
(`java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431`, with its token). `tiffinbox-core` lands in
the `application` layer only when the reactor builds it — a build from this root folder; a build of `tiffinbox-web` on its
own takes `tiffinbox-core` from the local repository, as a library, into `dependencies`.

The images this was measured with are not part of the anchor: Boot's two-stage Dockerfile recipe, a copy of
host-extracted layer folders, and a single-jar image (Boot's jar, copied whole) live in `../c5-unit14/docker/`, with
their evidence. **If you write a Dockerfile for this jar, run Boot's `extract` inside the build**, as the recipe's first
stage does: with this fixed time, a layer folder extracted on the host keeps its files' sizes and times across a
same-length change, Docker's build does not send the changed file again, and the image keeps the old class (measured in
`../c5-unit14/`, capture `stale`).

## Course 5 · unit 15 — an address a container can reach (2026-10-05)

Three files changed, and nothing else:
- `TiffinBoxProperties` gains `@NotBlank String address` — the key `tiffinbox.address` — after `port`; its `toString()`
  prints it.
- `TiffinBoxServer` binds that address — `new InetSocketAddress(address, port)`, where it said `"127.0.0.1"` — and its
  listening line prints it: `TiffinBox listening on http://<address>:<port>`.
- `application.yaml` gives the key its default, `address: 127.0.0.1`: this computer only, as before.

**On the Mac, nothing changes:** the run command, the log line (`TiffinBox listening on http://127.0.0.1:18431`) and the
seven responses (`115c36bac276128e245ca57df11c2891`). **In a container, `127.0.0.1` is the container's own address:** a
port Docker publishes does not arrive there — measured: the log says `TiffinBox listening on http://127.0.0.1:18425`, and
the Mac's `curl` gets `curl: (52) Empty reply from server` (on OrbStack; another Docker may answer differently). Give
the container `TIFFINBOX_ADDRESS=0.0.0.0` — every interface of the container — and publish the port on the Mac's
`127.0.0.1` alone. Boot's own key, `server.address` (`SERVER_ADDRESS`), changes nothing here: TiffinBox's `HttpServer`
never reads it. *(Course 6, unit 04: Tomcat reads `server.address` now, and `application.yaml` sets it to
`${tiffinbox.address}`, so `TIFFINBOX_ADDRESS` still moves the address — in the image too. The `TiffinBox listening on …`
line is gone: Boot's `Tomcat started on port 18431 (http) with context path '/'` replaces it, which names the port and never the
address — Tomcat's own connector line names it, at a level Boot's logging defaults hide.)*

**An image with no Dockerfile.** Boot's Maven plugin hands the jar to Paketo's buildpacks, in two steps: the first builds
both modules (so `tiffinbox-core` lands in the `application` layer, unit 14's index), the second builds the web module's
image from the jar the first just made. The builder is pinned by its digest, and neither it nor the run image is pulled
when already present:

```bash
mvn -B install
mvn -B -pl tiffinbox-web spring-boot:build-image-no-fork -Dspring-boot.build-image.builder=paketobuildpacks/builder-noble-java-tiny@sha256:b95da27fce97b58037f0c11ae934760c50730da4c9a24976205b53638592eba9 -Dspring-boot.build-image.runImage=paketobuildpacks/ubuntu-noble-run-tiny:0.0.138 -Dspring-boot.build-image.pullPolicy=IF_NOT_PRESENT
docker run -d --name tiffinbox -m 1g --user "$(id -u):$(id -g)" -e TIFFINBOX_ADDRESS=0.0.0.0 -v "$PWD/secrets:/workspace/secrets:ro" -p 127.0.0.1:18431:18425 tiffinbox-web:1.0.0
```

The image is `tiffinbox-web:1.0.0`, Boot's default name for this module. It runs as user `1002:1001` from `/workspace` —
the jar, unpacked — and holds no shell. The config tree goes there, read-only, so the token never enters the image; with
`-e TIFFINBOX_SHUTDOWN_TOKEN=…` instead, `docker inspect` lists the token. Stop it with POST /shutdown and the header (unit
11's command, on port 18431): the container exits 0, and `docker rm tiffinbox` removes it. **Not `mvn
spring-boot:build-image` from this folder:** it runs on `tiffinbox-core` first, fails (`Unable to find main class`), and
leaves a container, its image and four `pack-*` volumes behind. A first build downloads, inside the build, BellSoft
Liberica JRE 25.0.4 and syft (github.com) and spring-cloud-bindings 2.0.4 (Maven Central); the JRE is kept in the image's
own layer, so a rebuild skips the download only while the previous image is still there. `--user "$(id -u):$(id -g)"`
runs the container as the owner of the `0600` token file. Where a file keeps its owner and mode — measured in a Docker
volume, as on Linux — the image's own user, `1002:1001`, cannot read the folder, and the container exits 82 before Java
starts (the buildpack's memory calculator: `open /workspace/secrets: permission denied`); run as your own user, it
serves. On this Mac, OrbStack's file sharing lets the image's own user read a mounted file too. Evidence in
`../c5-unit15/`, capture `user`.

## Course 5 · unit 16 — a Dockerfile of its own (2026-10-05)

Two new files beside this README, and nothing else changed (the jar is byte for byte the one before):
- `Dockerfile` — two stages, both on the official `eclipse-temurin:25-jre`. Stage one copies the jar Maven built and runs
  Boot's extract tool on it, inside the build (unit 14's recipe). Stage two — the only one that ships — copies the four layer
  folders into `/app`, then three settings: `ENV TIFFINBOX_ADDRESS=0.0.0.0` (unit 15's key: in a container `127.0.0.1` is the
  container's own), `USER ubuntu` (uid 1000, already in the base image, which runs as root) and an exec-form entrypoint,
  `ENTRYPOINT ["java", "-jar", "application.jar"]`. No memory flag is baked in.
- `.dockerignore` — `secrets/` and `tiffinbox-local.yaml`, the two files this README tells you to keep beside it and never
  commit. `docker build` hands the builder this folder, the build context: a Dockerfile that copies the whole folder (`COPY .`)
  puts the token into an image layer, and the ignore file keeps both out whatever a Dockerfile copies. This Dockerfile copies
  the jar alone, and BuildKit sent it the same bytes with or without the ignore file — measured, on this Mac.

**Build and run** — Maven on your machine first, then Docker; the config tree mounted read-only where the image works,
`/app`; the port published on `127.0.0.1` alone; a memory limit:

```bash
mvn -B package
docker build -t tiffinbox-docker:1.0.0 .
docker run -d --name tiffinbox -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:18431:18425 tiffinbox-docker:1.0.0
```

Inside the container TiffinBox listens on `0.0.0.0:18425`; the Mac reaches it on `127.0.0.1:18431`, with the same seven
responses (`115c36bac276128e245ca57df11c2891`). Boot's first line says `started by ubuntu in /app`. Stop it with POST /shutdown
and the header (unit 11's command, on port 18431) — the container exits 0 — or with `docker stop tiffinbox`: Java is process
1, so Docker's SIGTERM reaches it, Boot's shutdown hook closes the context and TiffinBox's `@PreDestroy` method runs; the
container exits 143. Then `docker rm tiffinbox`. Arguments after the image name reach TiffinBox:
`… tiffinbox-docker:1.0.0 --tiffinbox.days=10`.
- **Keep the exec form.** In the shell form (`ENTRYPOINT java -jar application.jar`) Docker runs `/bin/sh -c`, the shell is
  process 1, an argument after the image name never reaches Java, and `docker stop` waits out Docker's ten seconds, then kills
  everything: exit 137, no `@PreDestroy`. The build warns (`JSONArgsRecommended`), and `docker build -q` hides the warning.
- **Memory:** Java reads the container's limit. With `-m 512m` it keeps a quarter for its heap (`MaxHeapSize = 134217728`);
  without `-m`, a quarter of whatever memory Docker's machine has. Change the share at run time, not in the image:
  `-e JAVA_TOOL_OPTIONS=-XX:MaxRAMPercentage=75`.
- **The user:** as `ubuntu`, the container cannot delete the app's own jar; the same image run with `--user root` can.
  `ubuntu` is a member of Ubuntu's default groups, `sudo` among them; the image has no `sudo` command.
- On the Mac the container's user, `ubuntu` (uid 1000), read the `0600` token file through OrbStack's file sharing.
  Where a file keeps its owner and mode — measured in a Docker volume, as on Linux — it cannot read a tree another user
  owns: TiffinBox stops before it listens (`Unable to find files in '/app/./secrets'`, caused by
  `java.nio.file.AccessDeniedException`), exit 1. Run it as the tree's owner — `--user "$(id -u):$(id -g)"` in the
  `docker run` line — and it serves the seven. Evidence in `../c5-unit16/`, capture `owner`.

## Course 5 · unit 17 — Postgres for development (2026-10-05)

Two new files and two changed ones; the Java sources are untouched:
- `compose.yaml` — new, beside this README: one official Postgres image (`postgres:18-alpine`), the project name
  `tiffinbox-dev` (so the network, the container and the volume are `tiffinbox-dev_default`, `tiffinbox-dev-postgres-1` and
  `tiffinbox-dev_data`, whatever this folder is called), its port published on `127.0.0.1:18881` alone, and no password —
  `POSTGRES_HOST_AUTH_METHOD: trust` tells Postgres to trust whoever connects, so nothing secret is committed. The data lives
  in a volume with a name: `docker compose down` keeps it, `docker compose -p tiffinbox-dev down -v` deletes it. Without
  that line the image's own volume gets no name, and `docker compose down` leaves it behind, its 64-character ID the only
  name it has.
- `tiffinbox-web/pom.xml` — `spring-boot-docker-compose`, Boot's Docker Compose support, as an **optional** dependency. It
  brings two jars of Jackson 3 (`jackson-databind`, `jackson-core` 3.1.5) to the class path Maven lists, beside Jackson 2.
  The executable jar holds none of the three: Boot's plugin leaves optional dependencies out (`includeOptional`, off),
  and keeps this module out on its own too (`excludeDockerCompose`, on). With `includeOptional` on, that second setting
  still keeps the module out, but not its Jackson: 33 jars, the module 0, Jackson 3's two. *(Course 6, unit 08: there is no
  Jackson 2 beside them now — of Jackson 2's three jars only `jackson-annotations` is left on that class path, which Jackson 3
  reads too; `../c6-unit08/`, `jackson`.)*
- `application.yaml` — `spring.docker.compose.enabled: false`: off.
- `application-dev.yaml` — new: the profile `dev` switches it on.

**Postgres with TiffinBox** — from this folder (`compose.yaml` and `secrets/` beside you), on the class path Maven lists:

```bash
mvn -B package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt
java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.profiles.active=dev
```

Boot runs Docker's own command-line tool before TiffinBox starts — `docker compose … up --no-color --detach --wait` among
others — and Compose creates the network, the volume and the container; its last line is `Healthy`, which here means
only that the container is running: the image declares no health check of its own (`docker image inspect` says `null`),
and the running container has no health status (`docker inspect`). TiffinBox then serves the same seven responses
(`115c36bac276128e245ca57df11c2891`). When TiffinBox stops, Boot runs `docker compose … stop --timeout 10` on its
shutdown hook's thread: the container is left `exited`, and the network and the volume stay. Add
`--spring.docker.compose.stop.command=down` and Boot removes the container instead; the volume stays. To remove
everything, `docker compose -p tiffinbox-dev down -v`.

**Why it is off unless `dev` is on.** With the module on the class path and Boot's default, a start from a folder that holds
no `compose.yaml` stops: `No Docker Compose file found in directory '…'`. With the profile on and Docker not answering:
`'docker version --format {{.Client.Version}}' failed with exit code 1.` With Docker off, start without `dev`, or add
`--spring.docker.compose.enabled=false`. Without `dev` nothing changes — the jar, the jar extracted, the image and Maven's
class path each serve the seven: the executable jar holds no Docker Compose support, and run with `dev` it starts nothing.

**Postgres runs beside TiffinBox, not under it.** TiffinBox's `Database` still connects to `tiffinbox.jdbc-url`, H2 in
memory, and its SQL is H2's: pointed at this Postgres (`--tiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:18881/tiffinbox?user=tiffinbox`,
with the Postgres driver on the class path), the start stops with `syntax error at or near "AUTO_INCREMENT"`. Postgres is
Course 7's subject. With Spring Boot's JDBC module and the Postgres driver on the class path (not in this project), Boot
registers the database's address as a bean — `jdbcConnectionDetailsForTiffinboxDevPostgres1`,
`jdbc:postgresql://127.0.0.1:18881/tiffinbox`, user `tiffinbox` — but with no connection pool on the class path its
`DataSource` is an embedded H2. Evidence in `../c5-unit17/`.

## Course 5 · unit 19 — ahead of time, and a native image (2026-10-05)

One file changed: `tiffinbox-web/pom.xml` declares GraalVM's Native Build Tools plugin (`native-maven-plugin`), bare — no
version, no execution. Boot's parent manages its version, **1.1.8** (`native-build-tools-plugin.version`; Course 3 pinned
1.1.13 by hand). Nothing else in TiffinBox changed: a build without the profile `native` gives the same executable jar as
before, but for the copy of this POM Maven puts in every jar (169 of 170 entries the same). The plugin is now a build extension
of every build of the web module (Boot's parent declares it with `<extensions>true</extensions>`): the first build downloads it
from Maven Central, with its metadata repository. The plugin reads that metadata repository (a zip) from the local Maven
repository — and when the zip is not there, it does not stop, even offline (`-o`): it downloads the zip from GitHub instead.

**Spring's ahead-of-time step (AOT), on the plain JDK.** Boot's parent's profile `native` runs Boot's `process-aot` on the web
module: at build time it reads TiffinBox's configuration — the scan, the conditions, the constructors — without starting the
server, and writes what it decided as Java code (`tiffinbox-web/target/spring-aot/main/`: the bean definitions as code,
compiled into the jar) and as data
(`reachability-metadata.json` — not Course 3's `reflect-config.json` — the file a native build reads). With the plugin
declared, the profile also runs the plugin's `add-reachability-metadata`, which copies metadata for the jars TiffinBox uses
from GraalVM's shared repository (a zip Maven downloads from Central on the first build; for H2 2.5.250 it has no entry, and
takes 2.1.210's):

```bash
mvn -B -Pnative package
java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
```

The jar runs with or without `-Dspring.aot.enabled=true`; with it, Spring starts the context from the generated code, and
Boot's first line says `Starting AOT-processed TiffinBoxServer`. Measured: the same seven responses
(`115c36bac276128e245ca57df11c2891`) either way; 59 bean definitions without it, 55 with it — the four missing are three
post-processors whose work the build already did (the configuration-class one, the autowired one, the common-annotation one)
and Boot's cache for reading class files.

**What the build decides, a run can no longer change.** Under `-Dspring.aot.enabled=true`, `spring.threads.virtual.enabled`
given at run time is read and ignored: the environment says `true`, and Boot's executor is still the pool
(`ThreadPoolTaskExecutor`, eight platform threads) — no warning. Built with the switch on
(`-Dspring-boot.aot.jvmArguments=-Dspring.threads.virtual.enabled=true`), the same run without it gets virtual threads. An
`@Async` method follows Boot's executor: under AOT, the pool. Choose such settings when you build. *(Course 6, unit 04:
`application.yaml` switches virtual threads on, so every build is made with them. On the JVM, Boot's executor is a
`SimpleAsyncTaskExecutor` whose tasks run on virtual threads, and Tomcat answers on virtual threads too; under AOT, a
run-time `--spring.threads.virtual.enabled=false` leaves Tomcat's request threads virtual — `../c6-unit04/`, `threads`.)*

**A faster start, with the JDK's AOT cache too** — Course 3's training run, now on TiffinBox, on the extracted jar (unit 13's
command): train once — one command records the run and writes the cache — then run with the cache:

```bash
java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
java -XX:AOTCacheOutput=tiffinbox-web/target/tiffinbox.aot -Dspring.aot.enabled=true -Dspring.context.exit=onRefresh -jar tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -XX:AOTCache=tiffinbox-web/target/tiffinbox.aot -Dspring.aot.enabled=true -jar tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
```

Measured on an Apple M1 (8 cores, 16 GB), from the process's start to the first answer, the middle of five runs: the executable
jar over a second; Spring's AOT alone a little faster (its median under the jar's, over three quarters of it); the jar extracted,
faster; extracted and with the JDK's AOT cache, with or without Spring's AOT, under half the executable jar's. On the executable
jar itself the cache does less: over half the jar's time. Never the `Started … in` line. Evidence in `../c5-unit19/`, capture
`ladder`.

**A native image** — needs a GraalVM JDK 25 (`GRAALVM_HOME`; the course used GraalVM CE 25.3.4.1) and minutes of CPU. First
install both modules, then build the binary from the web module alone:

```bash
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25
mvn -B -Pnative install
mvn -B -Pnative -pl tiffinbox-web native:compile-no-fork
tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431
```

**As this unit left it, the binary stopped at start**: the build says `BUILD SUCCESS`, and the binary prints Boot's banner, then
exits 1 — `MissingReflectionRegistrationError: Cannot reflectively invoke method 'public boolean
com.tiffinbox.TiffinBoxProperties.isShutdownTokenLongEnough()'` (Hibernate Validator calls the token-length rule by reflection,
and nothing registered it). Unit 20 adds the hints (below). The binary was built from Maven's class path, so it also held the
optional `spring-boot-docker-compose` and its Jackson 3, which the executable jar leaves out; unit 20 keeps them out of the
binary too. **Not `mvn -Pnative native:compile` from this folder:** it runs on the parent POM first and fails (`Image classpath
is empty`). Evidence in `../c5-unit19/`.


## Course 5 · unit 20 — the hints a closed world needs (2026-10-06)

Three Java files gained one annotation each, and `tiffinbox-web/pom.xml` keeps two optional modules out of the native binary.
Nothing a JVM run sees changed: the executable jar serves the same seven responses (`115c36bac276128e245ca57df11c2891`) before and
after, and holds the same 31 jars.

**What a native binary cannot do without them.** A native image calls by reflection only what its build registered, and Spring's
ahead-of-time step registers what Spring itself calls. TiffinBox calls more: its router invokes the route methods it finds by
reflection, Jackson reads the `Customer` record by reflection, and Hibernate Validator calls the token-length rule by reflection.
Each hint taken out on its own, the other two in (`../c5-unit20/`, capture `breaks`):

- without `@Reflective` on `isShutdownTokenLongEnough()` (`TiffinBoxProperties`), the binary stops at start, exit 1 —
  `MissingReflectionRegistrationError` on that method, as in unit 19: the router's and the record's hints are not enough;
- without `@Reflective` on the annotation `Route`, the router still finds its five routes (`routes mapped: [GET /customers, GET
  /dashboard, GET /kitchen, GET /revenue, POST /shutdown]`), but calling one fails on the request's thread (`Cannot reflectively
  invoke method 'java.lang.Object com.tiffinbox.web.TiffinBoxServer.kitchen()'`) and the client gets no answer — POST /shutdown
  included: only a signal stops it. GraalVM's refusal is an `Error` (a `LinkageError`), and the handler catches only `Exception`,
  so no 500 is sent;
- without `@RegisterReflectionForBinding(Customer.class)` on `TiffinBoxServer`, `/customers` answers
  `500 {"error":"InvalidDefinitionException"}` (Jackson's), and the other six answers are the same. *(Course 6, unit 06: both the router's hint and
  this one are gone — `Route` is deleted, and each route names its return type, `List<Customer>` or `Map<String, Object>`: Spring's
  AOT step registers `Customer` from the routes' signatures, its fields, constructors and four accessors, and the binary serves
  `/customers`; a copy whose `customers()` returns `Object` registers none — `../c6-unit06/`, `forms`.)*

**The hints, where the need is** — Spring's own annotations, from `spring-core`:

```java
@Reflective                                      // on @interface Route: every method carrying @Route is registered
@RegisterReflectionForBinding(Customer.class)    // on TiffinBoxServer: the record, its components, their accessors
@Reflective                                      // on TiffinBoxProperties.isShutdownTokenLongEnough(): that method
```

Each one is data in Spring's generated `reachability-metadata.json` (`mvn -B -Pnative package`; 262 reflection entries before,
263 after): `Customer` is a new entry — its fields, its constructors and its four accessors — `TiffinBoxServer`'s entry gains its
five route methods, and `TiffinBoxProperties`' gains `isShutdownTokenLongEnough`. A `RuntimeHintsRegistrar`, Spring's general
tool — code that registers hints, imported with `@ImportRuntimeHints` — wrote the same file byte for byte in place of the third
annotation (capture `metadata`, E; not in the anchor, which keeps `TiffinBoxApp` unedited).

**The binary's class path.** The plugin builds the binary from Maven's class path, not from the jar's. Unit 19's binary held the
optional `spring-boot-docker-compose` and its two Jackson 3 jars (36 jars against the jar's 31; in its bytes, 34 distinct names
from the Compose module and 991 from Jackson 3, 24 and 884 of them class names). The plugin's `<exclusions>` keep those three jars
out: 33 jars — the jar's 31 less `spring-boot-jarmode-tools`, plus three starters that hold no class — and in the binary's bytes
0 names from the Compose module and 3 from Jackson 3 (2 of them class names) — names that classes of `spring-boot`'s own JSON
support mention. The executable jar never held either. TiffinBox's own Jackson, version 2 (`com.fasterxml`), stays on the
binary's class path. *(Course 6, unit 08: it is out of the build — of `com.fasterxml.jackson`, the class path Maven lists, which the
native build reads, holds only the annotations, which Jackson 3 reads too; `../c6-unit08/`, `jackson`.)*

Build and run the binary with unit 19's four lines (above). Measured on an Apple M1 (8 cores, 16 GB), from the process's start to
the first answer, the middle of five runs after a warm-up round: the binary's warmed-up start under a tenth of a second, under a
tenth of the executable jar's time, and under a fifth of the fastest JVM way (the jar extracted, with the JDK's AOT cache and
Spring's AOT). That is one measure, start time, on one Mac: no size, and no throughput figure — the work done once it runs is
Course 18's to measure (Course 3's rule). Evidence in `../c5-unit20/`.


## Course 5 · unit 21 — Actuator, on TiffinBox's own server (2026-10-07)

Four files changed and one is new. The seven responses are the same before and after
(`115c36bac276128e245ca57df11c2891`), and so is `TiffinBoxApp.java`:
- `tiffinbox-web/pom.xml` — **`spring-boot-starter-actuator`**, Boot's Actuator: endpoints, small reports on the running
  application (health, env, beans, metrics, …), and Micrometer, Boot's metrics library. Eight more jars in `BOOT-INF/lib`
  (31 → 39). And **three `<excludes>` in Boot's plugin** — `org.springframework.boot:spring-boot-docker-compose`,
  `tools.jackson.core:jackson-databind`, `tools.jackson.core:jackson-core`: the three jars the native plugin's exclusions already keep
  out of the binary (unit 20), now kept out of Spring's AOT step too (below).
- `tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes.java` — **new**: three beans that put Boot's endpoints on
  TiffinBox's own server, under `/actuator`.
- `TiffinBoxServer.java` — one more constructor argument, the handler `ActuatorRoutes` builds, and one more context:
  `server.createContext("/actuator", actuator)`. One server, one stop: POST /shutdown still ends the JVM. *(Course 6, unit 04:
  both are gone with TiffinBox's own server. Boot's own adapter answers `/actuator` on Tomcat, and POST /shutdown closes the
  application context: Tomcat stops, and the JVM exits 0.)*
- `application.yaml` — `management.endpoints.web.exposure.include: health`: the endpoints that answer, written down.
- `.gitignore` — `*.hprof`: a heap dump holds the shutdown token (below), so none is ever committed.

**The starter alone reaches nothing.** Boot's HTTP side of Actuator waits for a web application it knows — Spring MVC or WebFlux,
on Tomcat, Jetty or Netty (Course 6). TiffinBox's server is the JDK's own, so to Boot TiffinBox is no web application (`NONE`).
*(Course 6, unit 04: on Tomcat it is a servlet web application — its context is a `ConfigServletWebServerApplicationContext`.)*
Measured with the starter and nothing else: 59 bean definitions become 134 and 10 auto-configuration classes 31, one endpoint bean
exists (`health`) — and no bean hands it to HTTP or to JMX: `/actuator/health` gets TiffinBox's own server's 404 (`No context found
for request`). Boot's condition report (`--debug`) says why, in Boot's words: `WebEndpointAutoConfiguration` —
`@ConditionalOnWebApplication did not find reactive or servlet web application classes`; `JmxEndpointAutoConfiguration` — `did not
find property 'spring.jmx.enabled'`; `HealthEndpointWebExtensionConfiguration` — `did not find servlet web application classes`.
JMX switched on carries health and, with every endpoint exposed, 11 MBeans — never `heapdump`, `logfile` or `prometheus`, whose
classes are `@WebEndpoint`s. Spring MVC on Tomcat makes TiffinBox the web application Boot waits for: 12 more jars and a second
server in the JVM, which keeps running after TiffinBox's POST /shutdown until it is killed — Course 6's road. *(Course 6,
unit 04 took that road with one server: TiffinBox's own is gone, Tomcat is the only one, and POST /shutdown ends the JVM.)*

**So TiffinBox serves the endpoints itself** — `ActuatorRoutes`, from Boot's own parts. An endpoint is a bean with operations, HTTP
is one adapter, and exposure is a filter:
- `webEndpointDiscoverer` — Boot's own `WebEndpointDiscoverer`, the class Spring MVC's Actuator adapter reads, through two filters:
  exposure (`management.endpoints.web.exposure.*`, `health` unless told otherwise) and access (`management.endpoint.<id>.access`). It
  is a bean: Spring's AOT step reads its class's hints (`@ImportRuntimeHints`) from beans, and the native binary needs them.
- `healthEndpointWebExtension` — Boot's `HealthEndpointWebExtension`: health over HTTP, its groups, no details unless asked for.
  `@ConditionalOnAvailableEndpoint(endpoint = HealthEndpoint.class)` keeps it out while health is not exposed.
- `actuatorHandler` — the `HttpHandler` for `/actuator`: it matches the request's path and verb to an operation (`health`,
  `health/{*path}`, `loggers/{name}`, …) and gathers the operation's arguments as Spring MVC's adapter does — the path's variables,
  a write's JSON body, then the query string (one value a String, several a list: `?tag=status:405` filters) — and passes the
  `Accept` header. A write that takes arguments needs a JSON `Content-Type` (else `415`) and one JSON object as its body (else
  `400`); an argument Boot can't map (`{"configuredLevel":"LOUD"}`) is a `400`. It invokes the operation and writes its answer
  with TiffinBox's own Jackson (version 2), in the type asked for (`Accept: application/json` gets `application/json`) — 404 for a
  path no operation has, 405 for a path without that verb, and 500 for an `Exception` or a `LinkageError` (a missing class, or a
  native binary's missing hint). Measured against Boot's own adapter, eight requests each (`../c5-unit21/`, `ways` and `tour`):
  the same answers but two — a write with an empty body, which the bridge refuses (`400`) where Boot's adapter resets the level
  (`204`), and `/actuator` itself, which only Boot's adapter answers (its list of links).

In a Spring MVC application Boot writes this adapter for you; TiffinBox's server is its own, so it writes it here.

```bash
mvn -B package
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/liveness
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18431/actuator/env
```

Measured: `{"status":"UP","groups":["liveness","readiness"]}` 200 for health, `{"status":"UP"}` 200 for each group, 404 for env (not
exposed), 405 for a POST to health; TiffinBox listens on its one address, and POST /shutdown ends the JVM, exit 0. Ask readiness
until it answers 200 before anything else: TiffinBox's own routes answer earlier (the next unit). The starter makes the jar's start
longer: to its first answer — which TiffinBox gives before Boot calls it ready — on an Apple M1, quiet, by under a quarter, the
middle of five runs (a busy machine moves the ratio: `../c5-unit21/` judges it behind a load gate).

**Exposure is a list, and each endpoint costs what it hands over.** Widen it for one run, with a flag, on the JVM:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,env
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/env/tiffinbox.shutdown-token
```

- `env` masks every value (`******`) but lists the name of every environment variable and every system property, and the config
  tree's property source names its folder's absolute path. `--management.endpoint.env.show-values=when-authorized` still masks (no
  Spring Security here: Course 10); `=always` prints the shutdown token in clear. Never `always`.
- `beans` lists every bean (153 with every endpoint exposed) and where each was read from — for TiffinBox's own, the jar's absolute
  path. `conditions` is the condition report. `mappings` is empty: TiffinBox's routes are not Spring MVC's (Course 6 lists them).
  *(Course 6, unit 04: they are Spring MVC's now — five paths in one `SimpleUrlHandlerMapping`, `tiffinBoxRoutes`; Course 6's
  mappings lesson lists them.)* *(Course 6, unit 06: five of `requestMappingHandlerMapping`'s rows, each with its verb — `{GET [/customers]}` →
  `TiffinBoxServer#customers()` — `../c6-unit06/`, `rows`.)* *(Course 6, unit 08: seven, `POST /customers` among them;
  `../c6-unit08/`, `change`.)*
- `heapdump` has access NONE by default: exposed, it still answers 404. Switched on for one run, it hands over a copy of the JVM's
  memory, over 20 MB, with 3 copies of the shutdown token in it — `rm heap.hprof` at once (`.gitignore` keeps it out of a
  commit):

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,heapdump --management.endpoint.heapdump.access=read-only
curl -s -o heap.hprof -w '%{http_code}\n' http://127.0.0.1:18431/actuator/heapdump
```

- Every endpoint at once stops the start — exit 1, `NoClassDefFoundError: com/fasterxml/jackson/datatype/jsr310/JavaTimeModule`,
  for the `configprops` endpoint, which needs Jackson 2's time module; TiffinBox's Jackson 2 does not carry it, and Boot has no
  failure analysis for it *(Course 6, unit 08: false since the embedded-Tomcat lesson put Jackson 3 in the
  jar — exposed alone for one run, `--management.endpoints.web.exposure.include=health,configprops`, configprops answers 200 on the
  previous tree and on this one, which holds no Jackson 2 library; `../c6-unit08/`, `jackson` C)*:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include='*'
```

  With configprops excluded it starts, and 11 of the 19 endpoints the jars declare answer:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include='*' --management.endpoints.web.exposure.exclude=configprops
```

So the list in `application.yaml` stays `health`, Boot's own default, written down so that widening it is a line someone reviews;
what to expose in production, and how to secure it, is Course 18's.

**AOT and the native binary.** Spring's AOT step (the profile `native`) reads Maven's class path, not the jar's — and there the
optional Compose module brings Jackson 3. Without the plugin's excludes it generated Actuator's Jackson 3 configuration
(`JacksonEndpointAutoConfiguration__BeanDefinitions`), and the AOT jar — `java -Dspring.aot.enabled=true -jar …`, unit 19's line —
stopped at start after TiffinBox's server had opened its port: `NoClassDefFoundError: tools/jackson/databind/json/JsonMapper`, exit 1,
while the same jar run without AOT served. With the excludes, the AOT jar and the native binary (unit 19's four lines) serve the
seven and `/actuator/health`. **Under AOT, and in the binary, the endpoints are the ones built in:** an exposure list given at run
time adds nothing there (env stays 404), and still filters what was built — a list without `health` takes health, liveness and
readiness away (404). Change `application.yaml` and build again. Evidence in `../c5-unit21/`.

## Course 5 · unit 22 — the kitchen joins readiness (2026-10-07)

One file is new and one changed. The seven responses are the same before and after
(`115c36bac276128e245ca57df11c2891`), and so are `ActuatorRoutes.java`, `TiffinBoxServer.java` and `TiffinBoxApp.java`:
- `tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenHealthIndicator.java` — **new**: a `HealthIndicator` bean, one more
  component of `/actuator/health`. Boot names the component after the bean, `HealthIndicator` left off: **`kitchen`**. UP while
  the database answers — with the customers it holds and the orders the kitchen cooked — and DOWN, with the error's class name,
  when it does not.
- `application.yaml` — **`management.endpoint.health.group.readiness.include: readinessState,kitchen`**: the kitchen joins the
  readiness group, beside Boot's own readiness state; liveness stays Boot's liveness state alone.

**Health is components and groups.** Each component is a health indicator, a bean that answers UP or DOWN; `/actuator/health`
answers with the worst of them — 503 for DOWN or OUT_OF_SERVICE, 200 otherwise — and hides which ones there are. Shown by a flag,
the anchor as unit 21 left it had five: `diskSpace`, `livenessState`, `ping`, `readinessState`, `ssl`. A group is a named subset
with its own path: Boot 4.1 makes two by default, **liveness** (`livenessState`: should a platform restart this process?) and
**readiness** (`readinessState`: should it send this process traffic?). A probe is a platform — Kubernetes, Course 18 — asking
one of those paths on a timer. Boot's own two groups show no components, even with the flag below; a group you define — as
`application.yaml` now defines readiness — shows them. Before this change a dead database left health UP: nothing in it touched
the database.

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoint.health.show-components=always
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/kitchen
```

Measured: six components now, `kitchen` among them, UP; `/actuator/health/kitchen` answers `{"status":"UP"}` 200 — and 404
without the flag: a component's own path exists only while components are shown. Its details, by a second flag:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoint.health.show-details=always
```

`/actuator/health/kitchen` → status UP, details `{"customers":4,"ordersCooked":120}` (the bridge writes an answer's keys in the order
reflection lists them, which has moved between runs: compare keys, not text). Ask the kitchen alone with that flag:
`/actuator/health` itself would show the disk's sizes and the folder TiffinBox runs in.

**Answered is not ready.** TiffinBox's server opens in `@PostConstruct`, during the refresh: polled from the moment the process
starts, `/kitchen` answered 200 at least once while liveness and readiness both answered 503. Boot publishes liveness
(`CORRECT`) after the refresh and readiness (`ACCEPTING_TRAFFIC`) after the runners. Wait for readiness, never for the port.

**When the database dies** (unit 22's harness closes it once TiffinBox is ready): `/actuator/health` 503, `kitchen` DOWN with
`{"error":"JdbcSQLSyntaxErrorException"}` — H2 opens a new, empty in-memory database under the same URL, so the table is gone —
liveness 200, **readiness 503**; `/customers` 500; `/kitchen` 200, from memory. A platform stops sending this process traffic and
does not restart it. TiffinBox's own H2 lives in memory, so here a restart would rebuild it; the harness plays a database outside
the process that stays down — the usual case, and the one this choice is for. Without the kitchen in readiness — the line below —
readiness says 200 and traffic keeps arriving at a TiffinBox that answers 500:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoint.health.group.readiness.include=readinessState
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers
```

The trade: TiffinBoxes that share one database outside them leave rotation together when it blinks — when that is worth it is
Course 18's.

**Readiness by hand** (`AvailabilityChangeEvent.publish(context, ReadinessState.REFUSING_TRAFFIC)`) counts only after Boot's own
`ACCEPTING_TRAFFIC`: published from a runner it is overwritten (readiness 200); published after it, readiness answers
`{"status":"OUT_OF_SERVICE"}` 503. On SIGTERM TiffinBox's context closes and publishes no state (exit 143).

**Switching the groups off** — `management.endpoint.health.probes.enabled`, true by default — now stops the start: the readiness
group names `readinessState`, which exists only while probes are on, and Boot says so (`Health contributor 'readinessState'
defined in 'management.endpoint.health.group.readiness.include' does not exist`). Not `management.health.probes.enabled`:
deprecated since 2.3.2 at level `error`, it changes nothing.

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoint.health.probes.enabled=false
```

The AOT jar and the native binary (unit 19's lines) report the kitchen UP and readiness 200, and serve the seven. Evidence in
`../c5-unit22/`.

## Course 5 · unit 23 — the kitchen's count and every answer's time, scraped (2026-10-07)

One file is new and four changed. The seven responses are the same before and after (`115c36bac276128e245ca57df11c2891`);
`tiffinbox-core`, `TiffinBoxApp.java` and `KitchenHealthIndicator.java` are not touched:
- `tiffinbox-web/pom.xml` — **`io.micrometer:micrometer-registry-prometheus`**, its version Boot's parent's (1.17.1). The executable
  jar's `BOOT-INF/lib` goes from 39 jars to 46: the registry and six `prometheus-metrics-*` jars (the Prometheus client, 1.7.0).
- `tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenMetrics.java` — **new**: a `MeterBinder` bean that registers two
  `FunctionCounter`s, `tiffinbox.orders.cooked` and `tiffinbox.orders.value`, over `OrderQueue::cooked` and `::cookedValue` — read
  when the registry is read, so the kitchen keeps its own count and `tiffinbox-core` gains no dependency. Its one hint,
  `@RegisterReflection` of `com.sun.management.OperatingSystemMXBean`'s public methods, is for the native binary (below).
- `TiffinBoxServer.java` — a `MeterRegistry` constructor parameter, and a timer around `handle()`: **`tiffinbox.requests`**, tagged
  `route` — the route TiffinBox declares (`GET /customers`), or `UNKNOWN` for a verb no route declares — and `status`. *(Course 6, unit 06:
  retired, with `handle()`. Boot's `http.server.requests` times every answer, its `uri` tag the mapping's pattern — `UNKNOWN` for a
  verb no mapping takes, and for OPTIONS; the scrape holds no `tiffinbox_requests` line — `../c6-unit06/`, `timers`.)*
- `ActuatorRoutes.java` — one line: a `byte[]` answer is written as it is. Boot hands the scrape over as bytes, and the bridge
  wrote them as JSON — a quoted base64 string, with Prometheus's content type.
- `application.yaml` — **`management.endpoints.web.exposure.include: health,prometheus`**.

**A meter** is one named measurement; a **registry** keeps them. Actuator's starter brought Micrometer with a registry that keeps
them in memory, `SimpleMeterRegistry`: JVM, process, system, Logback, disk, executor and application meters, and
`/actuator/prometheus` 404 even when exposed by a flag — the endpoint exists only beside Prometheus's registry. No `http.server.*` meter either, even after
a request: TiffinBox's server is the JDK's, and nothing in Boot times it. With the registry, `/actuator/prometheus` answers in
the text a Prometheus server reads when it **scrapes** — pulls the page on a timer, over HTTP:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:18431/actuator/prometheus
curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' -H 'Accept: application/openmetrics-text; version=1.0.0' http://127.0.0.1:18431/actuator/prometheus
curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' -H 'Accept: application/openmetrics-text;version=1.0.0;q=0.5,application/openmetrics-text;version=0.0.1;q=0.4,text/plain;version=1.0.0;q=0.3,text/plain;version=0.0.4;q=0.2,*/*;q=0.1' http://127.0.0.1:18431/actuator/prometheus
```

The third line sends the `Accept` header a Prometheus 3 server sends with every scrape (its default scrape protocols): it gets
OpenMetrics too, so a Prometheus server reads OpenMetrics by default, and curl, asking for nothing, gets the older text format.
Measured: `200 text/plain;version=0.0.4;charset=utf-8`; `# HELP`, `# TYPE tiffinbox_orders_cooked_total counter`,
`tiffinbox_orders_cooked_total 120.0` and `tiffinbox_orders_value_total 24300.0` — the dots of a meter's name become underscores,
and a counter gains `_total`. Asked for OpenMetrics: `200 application/openmetrics-text;version=1.0.0;charset=utf-8`, the family
named `tiffinbox_orders_cooked` (the sample keeps `_total`), and the last line `# EOF`. A scrape holds this computer's own
numbers — memory, threads, the disk and the folder TiffinBox runs in — so the file stays on your machine. The two counters are
`/kitchen`'s numbers (`{"ordersCooked":120,"ordersValue":24300}`), with the default 30 days; with `--tiffinbox.days=10`, 40 and
8100:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --tiffinbox.days=10
```

**The timer** appears with its first answer: a `summary` — `tiffinbox_requests_seconds_count` and `_sum` per route and status, in
seconds — and a gauge, `tiffinbox_requests_seconds_max`. After `/customers`, `/revenue`, `/dashboard`, `/kitchen`, `/nowhere`,
`GET /shutdown` and a `POST /shutdown` without the token: one series each for the four routes (200), `UNKNOWN` 405 and
`POST /shutdown` 403; `/nowhere` is not timed — the JDK server's own 404, before any handler of TiffinBox's.

```bash
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18431/customers/7
curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:18431/shutdown
```

**The route tag holds a route, never a URL.** The JDK server matches a context by prefix: `/customers/7`, `/customers/8` and
`/customersXYZ` all reach the `/customers` route (and answer the customer list — a router quirk, path patterns are Course 6's),
and all four count under one series, `route="GET /customers"`, `4`. *(Course 6, unit 06: path patterns are Spring MVC's now — a mapping takes a whole
path, so `/customersXYZ` is a 404, which Boot's timer files under `uri="/**"`; `/customers?mealType=VEG` counts under
`uri="/customers"`: Boot's tag keeps the rule, a pattern, never a URL — `../c6-unit06/`, `patterns`, `timers`.)* *(Course 6, unit 07:
`/customers/7` reaches `GET /customers/{name}` — no customer has that name: a 404, which Boot's timer files under
`uri="/customers/{name}"`, with `/customers/Ravi`'s 200s; `../c6-unit07/`, `timer`.)* A copy whose tag holds the raw path keeps one series per
URL a client types — every one of them kept, and scraped, from then on.

**Actuator's other metrics endpoints, by flag** — the registry's class and the meters' names:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,metrics,beans
curl -s -o metrics.json -w '%{http_code}\n' http://127.0.0.1:18431/actuator/metrics
curl -s -o beans.json -w '%{http_code}\n' http://127.0.0.1:18431/actuator/beans
curl -s -o metrics.json -w '%{http_code}\n' 'http://127.0.0.1:18431/actuator/metrics/tiffinbox.requests?tag=status:405'
```

`prometheusMeterRegistry`, a `PrometheusMeterRegistry`. **A query string reaches the operation** — the bridge merges it as Spring
MVC's adapter does (the Actuator lesson's fix): `?tag=status:405` answers `COUNT 1.0`, with `route` the one tag left to filter by.
*(Course 6, unit 06: `tiffinbox.requests` is retired — the scrape holds no `tiffinbox_requests` line; `../c6-unit06/`, `timers`.)*

**The native binary needs one hint.** Micrometer's processor meters call the JDK's operating-system bean through
`com.sun.management.OperatingSystemMXBean`, by reflection, and Micrometer's own native-image metadata lists three of that
interface's methods — not `getProcessCpuTime()`, which its CPU-time meter (`process.cpu.time`) calls. Without the hint the binary's
scrape answers `{"error":"MissingReflectionRegistrationError"}` 500; the same binary with the CPU-time meter switched off answers
200, without `process_cpu_time_ns_total`:

```bash
tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431 --management.metrics.enable.process.cpu.time=false
```

With the hint, 200 and every meter. `com.sun.management.UnixOperatingSystemMXBean` in its place answers 200 too: it inherits the
method, and the hint registers an interface's public methods, inherited ones included. The AOT jar and the binary
serve the seven and the scrape. Evidence in `../c5-unit23/`.

## Course 5 · unit 24 — one line per answer, and a level changed while it runs (2026-10-07)

Two files changed, and three things of Course 3's retired. The seven responses are the same before and after
(`115c36bac276128e245ca57df11c2891`); `tiffinbox-core`, `TiffinBoxApp.java`, `ActuatorRoutes.java`, `KitchenHealthIndicator.java`
and `KitchenMetrics.java` are not touched. The two Java logging files of Course 3 and the exec plugin's argument that named one
are deleted (below):
- `TiffinBoxServer.java` — `handle()`'s `finally` logs **one line per answer at DEBUG**, through TiffinBox's own `System.Logger`
  (`tiffinbox`): the route and the status, `GET /customers -> 200` — the two values the timer tags (`UNKNOWN -> 405` for a verb no
  route declares). Never a header, never the token, never what the client typed. Silent at INFO, Boot's default. The line is
  written before the timer stops, so once a scrape counts an answer, that answer's line has been decided. *(Course 6, unit 06:
  retired, with `handle()`: the `kitchen` group logs no line per answer. Boot's `web` group at DEBUG prints Spring MVC's lines,
  which show the request as the client typed it — `GET "/customers?mealType=VEG", parameters={masked}` — `../c6-unit06/`,
  `timers`.)*
- `application.yaml` — **`logging.group.kitchen: tiffinbox, com.tiffinbox`**: a log group, one name for TiffinBox's own logger
  and the loggers under `com.tiffinbox` — Boot logs TiffinBox's startup under its main class's name,
  `com.tiffinbox.web.TiffinBoxServer`.

**One line's road.** `System.Logger` hands a line to `java.util.logging`; on its root logger Boot installed one handler,
`org.slf4j.bridge.SLF4JBridgeHandler`, which hands it to Logback, whose root logger writes through one appender, `CONSOLE`.
Logback's `LevelChangePropagator`, a listener Boot adds, copies every level set in Logback back to `java.util.logging`: DEBUG
there is FINE here, so `System.Logger`'s DEBUG check answers yes.

**At start**, Boot's property — on TiffinBox's own logger (the first lesson's), or on the group:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.tiffinbox=debug
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.kitchen=debug
```

The group prints five `route` lines at start, Spring's `Running with Spring Boot v4.1.1, Spring v7.0.9` (logged under
`com.tiffinbox.web.TiffinBoxServer`), and one line per answer: the seven requests add six (`/nowhere` is the JDK server's own
404, never `handle()`'s). *(Course 6, unit 06: no `route` line and no line per answer now: Spring MVC's `RequestMappingHandlerMapping`
registers the routes, at TRACE — `{GET [/customers]}: customers()` and four more, `7 mappings in 'requestMappingHandlerMapping'` —
`../c6-unit06/`, `scan`.)* *(Course 6, unit 07: six, with their parameter types — `customers(MealType)` — and 8 mappings;
`../c6-unit07/`, `change`.)* *(Course 6, unit 08: seven — `add(Customer)` — and 9 mappings; `../c6-unit08/`, `change`.)* *(Course 6, unit 12:
`add(Customer,BindingResult)` since; `../c6-unit12/`, `constraints`.)*

**While it runs**, through Actuator's `loggers` endpoint — exposed by a flag, for one run, never in `application.yaml`: it is a
write on the app's own port, and anyone who reaches the port can call it:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,loggers
curl -s -o loggers.json -w '%{http_code}\n' http://127.0.0.1:18431/actuator/loggers
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/loggers/kitchen
curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:18431/actuator/loggers/kitchen
curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":null}' http://127.0.0.1:18431/actuator/loggers/kitchen
```

Measured on one process: three requests at INFO, 0 lines; the POST, `204`; three more, 3 lines; `null`, `204`; three more,
still 3. *(Course 6, unit 06: those lines were the line per answer, which is retired: on this tree, with the kitchen group at
DEBUG from the start, five requests print 0 lines of TiffinBox's — `../c6-unit06/`, `timers`.)* **`null` is not a clean reset:** Logback's propagator copies the level `tiffinbox` falls back to, INFO, into
`java.util.logging`, and it stays there. A later POST to the root (`…/loggers/ROOT`, DEBUG) makes Actuator report `tiffinbox` at
DEBUG while TiffinBox prints nothing; on a process where the group was never set, the same root POST prints the line. `loggers.json` lists every logger, Boot's groups `web` and `sql` beside `kitchen`, and the levels; it names only
loggers, but it is long — read it through a filter. **Locked**, the way a production run would keep it:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,loggers --management.endpoint.loggers.access=read-only
```

The POST answers `405`, and the level stays. **The bridge takes a write only as JSON,** as Boot's own adapter does (the Actuator
lesson's fix): the same POST without `-H 'Content-Type: application/json'` (curl's `-d` sends a form's type) answers `415` here,
and so does a POST with no body at all; the group's level stays. (A JSON POST with an empty body is a `400`: an empty write never
resets a level.)

```bash
curl -s -w ' %{http_code}\n' -X POST -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:18431/actuator/loggers/kitchen
curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:18431/actuator/loggers/kitchen
```

**A group and one of its members, both set:** while it runs, the last write wins for each logger, and the group's own answer
keeps the level last set on the group; at start, in either order on the command line, the group won. Set one or the other:

```bash
curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"INFO"}' http://127.0.0.1:18431/actuator/loggers/tiffinbox
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.kitchen=debug --logging.level.tiffinbox=info
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.tiffinbox=info --logging.level.kitchen=debug
```

**The name decides, not the package.** TiffinBox's logger is `tiffinbox` (Course 2's `System.getLogger("tiffinbox")`):
`com.tiffinbox` alone at DEBUG prints Spring's one line about TiffinBox and 0 lines per answer:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.com.tiffinbox=debug
```

**Boot's own groups are silent here.** `web` (5 members) and `sql` (3) name Spring's web loggers — the bridge's endpoint
package among them — and three SQL libraries' (Spring's JDBC, Hibernate, jOOQ); each at DEBUG prints 0 DEBUG lines over the seven:
*(Course 6, unit 06: not since TiffinBox moved onto Spring MVC — `web` at DEBUG prints Spring MVC's lines for a request,
`GET "/customers?mealType=VEG", parameters={masked}` and the rest; `../c6-unit06/`, `timers` C, and `seven` C.)*

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.web=debug
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.sql=debug
```

**At TRACE, still no token.** With every logger at TRACE, the seven requests — the last one carrying `X-Shutdown-Token` —
print their six lines, and the log holds the token 0 times and the header's name 0 times: *(Course 6, unit 06: TiffinBox prints no line per
answer now, so the six lines are gone; this run is not re-measured on this tree.)* *(Course 6, unit 07: re-measured — false
from the embedded-Tomcat lesson to this unit, true again from it: Tomcat's `Http11InputBuffer` prints the request it received, the
header among its lines, when its logger is at TRACE (labelled DEBUG; the request-mapping lesson's tree holds the token once), and
Spring MVC's `HandlerMethod` prints the arguments it bound, the token among them; `application.yaml` holds both at INFO, and the
seven's log holds the token 0 times — 2 on a copy without those lines; `../c6-unit07/`, `trace`.)*

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.root=trace
```

**Retired here: the Java logging files of Course 3.** `tiffinbox-web/logging.properties`, `logging-debug.properties` and the
exec plugin's `-Djava.util.logging.config.file=logging.properties` are deleted in this lesson, measured first on the previous
tree, which still ships them (`../c5-unit24/`, `files`). Under Boot they changed nothing: `java.util.logging` read the file it was
given (its `.level = FINE`), then Boot replaced the root logger's handler with its bridge and set its level from Logback — 0
DEBUG lines, 0 lines on standard error, 0 lines in the file's bare format; the exec plugin's run printed Logback's lines. The line
that measured the debug file, on that tree:

```bash
java -Djava.util.logging.config.file=tiffinbox-web/logging-debug.properties -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
```

The exec plugin stays, with its `-classpath … TiffinBoxServer` arguments: Course 3's two lines (below) still start TiffinBox, now
without a logging file. **In the AOT jar and the native binary** the exposure list is the one they were
built with: `loggers` by flag answers 404, so a level changes only at start — `--logging.level.kitchen=debug` works in both:

```bash
tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431 --logging.level.kitchen=debug
tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,loggers
```

A copy built with `loggers` in `application.yaml`'s list switches live under AOT. Evidence in `../c5-unit24/`.

---

## Course 5 · unit 26 — TiffinBox's port failure explained to Boot, and a 500 for a missing class (2026-10-07)

Two files added, two changed. The seven responses are the same before and after (`115c36bac276128e245ca57df11c2891`);
`tiffinbox-core`, `TiffinBoxApp.java`, `KitchenHealthIndicator.java`, `KitchenMetrics.java`, `Route.java`, `application.yaml` and
the POMs are not touched:
- `PortTakenFailureAnalyzer.java` (new) — a **failure analyzer**: a class Boot asks, when the start fails, whether it recognises
  the failure; the first that does prints a description and an action instead of the stack trace. This one recognises one
  failure: a `java.net.BindException` whose message is `Address already in use`, thrown by the bind `TiffinBoxServer`'s `start`
  makes (that method on the exception's stack) — something else already listens on TiffinBox's port — and says where TiffinBox
  tried to listen, read from the `Environment` Boot hands its constructor: `tiffinbox.address` and `tiffinbox.port`, never another
  setting. Any other `BindException` — an address this machine does not have, another bean's port — gets `null`: Boot prints the
  trace, as it did before.
- `tiffinbox-web/src/main/resources/META-INF/spring.factories` (new) — one line,
  `org.springframework.boot.diagnostics.FailureAnalyzer=com.tiffinbox.web.PortTakenFailureAnalyzer`. Boot reads its analyzers
  from this file of names, never from the context: the same class as a `@Component` changes nothing.
- `TiffinBoxServer.java` — `handle()`'s catch around a route is **`catch (Exception | LinkageError e)`**, and it logs the error
  at ERROR, with its trace, under the route's name (`GET /customers failed`): a route that needs a class the class path or the
  native binary does not hold answers `500`, and the answer is logged and timed like any other. Caught as an `Exception` only, the
  error left `handle()`, the request's thread died and the client never got an answer — the hints lesson's hang — and at INFO the
  log said nothing. An `OutOfMemoryError` or a `StackOverflowError` is still not caught. *(Course 6, unit 06: `handle()` and its catch are gone
  with the router: a route that throws is Spring MVC's — Tomcat logs `Handler dispatch failed` at ERROR, with the trace, and the
  answer is Boot's 500 body; `../c6-unit06/`, `json` C.)*
- `ActuatorRoutes.java` — its catch, already `Exception | LinkageError`, logs at ERROR too: a `LinkageError` with its trace, any
  other failure by its class alone (`an actuator request failed: ` and the class's name) — an exception's message can quote what
  the client sent, and the log never holds what a client typed. A client's own mistake never reaches it: since the Actuator
  lesson's fix, a write without a JSON body, or with a level Boot can't map, is a `400` before any catch, and a read reads no body.

**Port taken.** Start TiffinBox twice on one port:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
```

The second exits 1 with two sentences and no stack trace — `TiffinBox could not listen on 127.0.0.1:18431: something else
already listens there.` and `Stop the program on that port, or start TiffinBox on another: --tiffinbox.port=<a free port>.` *(Course
6, unit 04: `PortTakenFailureAnalyzer` is deleted, and its name is out of `spring.factories`: a port taken is Tomcat's now, and
Boot's own analyzer prints `Web server failed to start. Port 18431 was already in use.` — exit 1, no stack trace; its action
names no setting.)* Before
this change it printed 40 stack frames and no analysis: Boot's own port analyzer, `PortInUseFailureAnalyzer`, lives in
`spring-boot-web-server`, for Boot's own web servers, and it only knows Boot's own `PortInUseException`; TiffinBox's server is
the JDK's. An address this machine does not have is not a taken port — the trace, and `Can't assign requested address`:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --tiffinbox.address=192.0.2.1
```

*(Course 6, unit 04: on Tomcat that start fails as `Unable to start embedded Tomcat server`, with the trace and no analysis —
`../c6-unit04/`, `taken` D.)*

The analysis for the taken port comes from the AOT jar and from the native binary too. **The trace is still there**, with Boot's
condition report, under `--debug`:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --debug
```

**Boot's own analyzers** — 21 in the jars TiffinBox ships (`spring-boot` 18, `spring-boot-autoconfigure` 2,
`spring-boot-micrometer-metrics` 1) *(Course 6, unit 04: 24 since Spring MVC's starter — `spring-boot-tomcat` 1 and
`spring-boot-web-server` 2 more, the port analyzer, `PortInUseFailureAnalyzer`, among them; `../c6-unit04/`, `taken`)* — explain a missing bean, a failed validation, a missing import file, a cycle and a malformed
value, among others. A malformed value's analysis prints the value it could not convert — fine for a port, never for a secret:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=nineteen
```

**A cycle stops the start under Boot.** Boot's `spring.main.allow-circular-references` defaults to `false` (Course 4's plain
Spring container allowed one): two beans that need each other through setters stop the start, and the analysis draws the cycle.
The switch is the last resort Boot's action names, never this project's setting; the cure is a third object both of them want:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.main.allow-circular-references=true
```

**After the start, no analyzer runs.** To see a missing class answer `500`, delete one class jackson-databind needs for a record,
`JDK14Util`, from a copy of the extracted jar's `lib/`, with the thin jar copied beside it — its `Class-Path` names `lib/`, so it
reads the copy — all under `target/`:

```bash
rm -rf tiffinbox-web/target/hang && mkdir tiffinbox-web/target/hang && cp tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar tiffinbox-web/target/hang/ && cp -R tiffinbox-web/target/extracted/lib tiffinbox-web/target/hang/lib
zip -q -d tiffinbox-web/target/hang/lib/jackson-databind-2.22.2.jar 'com/fasterxml/jackson/databind/jdk14/JDK14Util*'
java -jar tiffinbox-web/target/hang/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.kitchen=debug
curl -s -m 5 -w ' %{http_code}\n' http://127.0.0.1:18431/customers
```

`/customers` answers `{"error":"ClassNotFoundException"} 500`, and the log's line says `GET /customers -> 500`. *(Course 6, unit 06: not
on this tree — Jackson 2 no longer writes TiffinBox's answers, so with its `JDK14Util` deleted `/customers` answers 200. Spring MVC's
converter writes them with Jackson 3: delete Jackson 3's `RecordUtil` instead —
`zip -q -d tiffinbox-web/target/hang/lib/jackson-databind-3.1.5.jar 'tools/jackson/databind/util/RecordUtil*'` — and `/customers`
answers Boot's `500` body, while Tomcat logs `Servlet.service() … threw exception [Handler dispatch failed:
java.lang.NoClassDefFoundError: tools/jackson/databind/util/RecordUtil] with root cause` at ERROR, with the trace; `/kitchen`, a
map, still answers 200 — `../c6-unit06/`, `json`.)* *(Course 6, unit 08: and from Course 6's request-body lesson there is no
`jackson-databind-2.22.2.jar` in `lib/` to delete it from: the `zip` line prints `zip error: Nothing to do!` and exits 12 —
`../c6-unit08/`, `jackson`.)* Before this
change curl gave up after 5 seconds, while the log said `GET /customers -> -1` and the timer counted an answer no client received.
**At INFO, Boot's default, the error is in the log:** `GET /customers failed`, at ERROR, then
`java.lang.NoClassDefFoundError: com/fasterxml/jackson/databind/jdk14/JDK14Util` and its trace (before this change: nothing at
all). The bridge's catch logs too: Actuator's `sbom` endpoint, exposed for this one run, needs the same class — `an actuator
request failed`, with the trace. A body sent with a read never gets that far: the bridge reads a body only for a write that takes
one, so health answers `200`, nothing is logged, and the body's words appear 0 times in the log:

```bash
java -jar tiffinbox-web/target/hang/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,sbom
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/sbom
curl -s -X GET -d 'oops, not json' -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health
```

In the native binary, the hints lesson's break (the route annotation's `@Reflective` deleted) answers
`{"error":"MissingReflectionRegistrationError"} 500` instead of nothing. *(Course 6, unit 06: the route annotation is deleted.)* Evidence in `../c5-unit26/`.

## Course 5 · unit 27 — a bare argument refused before anything starts (2026-10-08)

Two files added, two changed. The seven responses are the same before and after (`115c36bac276128e245ca57df11c2891`);
`tiffinbox-core`, `TiffinBoxServer.java`, `PortTakenFailureAnalyzer.java`, `ActuatorRoutes.java`, the indicator, the meters,
`Route.java`, `application.yaml` and the POMs are not touched:
- `BareArgumentGuard.java` (new) — a **listener** for Boot's `ApplicationEnvironmentPreparedEvent`: the first moment of a start
  when the command line is parsed and the environment ready, before the banner, the container and the port. It reads the
  **bare arguments** — every argument that does not start with `--`, which Boot never makes a property (an option is
  `--name=value`, or `--name` alone, which Boot binds as empty) — with Boot's own `DefaultApplicationArguments`, and on a
  start that has one it throws an exception whose exit code is **2** (`ExitCodeGenerator`). The refusal never quotes an
  argument it cannot classify: a bare number of one to five digits (a port, typed the old way) is printed, unless it follows
  an option's bare name (`--tiffinbox.shutdown-token 48213`: a PIN typed after a space is a number too); an argument that
  starts with `-D`, and anything else, is named by its position only — a value typed after a space
  (`--tiffinbox.shutdown-token VALUE`) is a bare argument too, and it may be a secret.
- `BareArgumentAnalyzer.java` (new) — the failure analyzer for that exception: Boot prints its description and action instead
  of the stack trace. Boot runs the analysis with no container yet.
- `tiffinbox-web/src/main/resources/META-INF/spring.factories` — the listener's key added
  (`org.springframework.context.ApplicationListener=com.tiffinbox.web.BareArgumentGuard`), the analyzer added to the
  `FailureAnalyzer` key, and the comment rewritten for both keys. A listener for this event must be named here: the context
  that would hold a bean does not exist yet.
- `TiffinBoxApp.java` — the Javadoc sentence about a `@PropertySource` file only (RED C5-S2 #8): it ranks below every source
  Boot adds **but one, default properties**, which Boot keeps last when they are set in code (measured on Boot 4.1.1: 9 of 9
  without them, 9 of 10 with them — `../c5-unit27/`, `change`). Its code is unchanged.

**The old command is refused.** The port the way Courses 2 to 4 typed it — a bare number after the jar — started TiffinBox on
another port without a word (on the file's 18425, or on `TIFFINBOX_PORT` when it is set):

```bash
TIFFINBOX_PORT=18432 java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18431
```

Now it exits **2** before the banner — nothing listens, on either port — with two sentences: `TiffinBox reads no bare
arguments: argument 1 of 1 is 18431.` and `To set the port, give it as an option: --tiffinbox.port=18431.` (In a container,
that option moves the container's own port, and the port you published answers nothing: there, publish yours with
`docker run -p` instead — measured in `../c5-unit29/`, `fails` E.) A `-D` option typed
after the jar was dropped the same way (the kitchen cooked 120 orders, not 40); now it is refused, and the action says where it
goes:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 -Dtiffinbox.days=10
java -Dtiffinbox.days=10 -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/kitchen
```

The first exits 2 (`argument 2 of 2 starts with -D (not shown)`); the second serves, and `/kitchen` answers
`{"ordersCooked":40,"ordersValue":8100} 200`. The same refusal in the AOT jar and in the native binary.

**Exit codes**, each measured: `0` after POST /shutdown · `1` a failed start (a port taken: the failure lesson's analysis) ·
`2` a bare argument · `3` a runner's `SpringApplication.exit` with a generator that returns 3 (a harness, not TiffinBox) ·
`143` SIGTERM (`kill <pid>`: 128 + 15).

**A banner that reads the jar's manifest.** Boot prints `banner.txt` with its placeholders filled in;
`${application.title}` and `${application.version}` come from the jar's manifest, so a run from the build's folders prints them
empty, and `${spring-boot.version}` prints everywhere:

```bash
printf '%s\n' 'title=[${application.title}] version=[${application.version}] boot=[${spring-boot.version}]' > banner.txt
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.banner.location=file:banner.txt
mvn -B package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt
java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.banner.location=file:banner.txt
tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431 --spring.banner.location=file:banner.txt
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.main.banner-mode=off
```

The jar: `title=[TiffinBox Web] version=[1.0.0] boot=[4.1.1]`; the folders: `title=[] version=[] boot=[4.1.1]`; the native
binary: `title=[] version=[] boot=[4.1.1]` (it carries no manifest); `banner-mode=off`: no banner. Evidence in `../c5-unit27/`.

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
*(Course 6, unit 06: `Route` is deleted; TiffinBox's routes are Spring MVC's request mappings.)*

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
nothing. *(Course 6, unit 08: no Jackson 2.22.2 — the build names no Jackson 2 library, and the annotations jar Jackson 3 needs
comes at 2.21; `../c6-unit08/`, `jackson`.)*

## Build

> **Stale since Course 5, unit 13.** Web's build no longer runs `copy-dependencies`, its jar's manifest has no
> `Class-Path`, and there is no `tiffinbox-web/target/lib/`: the jar is Boot's executable jar (unit 13's section at the
> top). The manifest and the `lib/` listing below are Course 3's, kept as they were written. *(Course 6, unit 08: and Jackson 2's
> `jackson-databind` and `jackson-core` are out of the build — `../c6-unit08/`, `jackson`.)*

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
> silently ignored (the server listens on 18425), and since unit 27 is refused (exit 2, nothing listens). **Since Course 5 unit 24, `logging.properties`, `logging-debug.properties` and
> the exec plugin's `-D` argument are deleted:** the lines below that name them are history; `exec:exec` still starts TiffinBox.

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

*(Course 6, unit 04: that last line is gone — Boot's `Tomcat started on port …`, logged by Boot's `TomcatWebServer`, replaces it.)*

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
`java -jar target/tiffinbox-web-1.0.0.jar 9090`. *(Course 5: since unit 06 that bare `9090` is ignored, and since unit 27
it is refused — exit 2, nothing listens; the port is `--tiffinbox.port=9090`.)*

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
*(Course 6, unit 06: GET /shutdown is Spring MVC's 405 now — `{"timestamp":"…","status":405,"error":"Method Not Allowed","path":"/shutdown"}`
— with `Allow: POST`; `../c6-unit06/`, `seven`.)*
*(Course 6, unit 16: and a problem detail since — `{"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"}`, `application/problem+json`; `../c6-unit16/`, `seven`.)*

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
`<version>` for a dependency or a plugin.** *(Course 6, unit 08: `jackson-databind` is out of the build, and with it `jackson-core`
2; `jackson-annotations` stays, at 2.21, because Jackson 3 needs it — `../c6-unit08/`, `jackson`.)* Check it:

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

(Course 5: since unit 06 that bare `18431` is ignored, and since unit 27 it is refused — exit 2, nothing listens; the
port is `--tiffinbox.port=18431`.)

The project as it was before the rewire is frozen in `../c4-unit31/before/`; the evidence that the two serve
byte-identical responses, and everything else the capstone claims, is `../c4-unit31/receipts.sh`.
