# Course 9 · Unit 16 — Spring HATEOAS in Practice

Course 9's twelfth anchor change, Section 3's fourth unit. `before` is a link to `../c9-unit14/after` (unit 15 changed nothing in the
anchor); `after/` is a frozen copy of `../c9-tiffinbox` after this unit's change. The change: the `spring-boot-starter-hateoas`
dependency in `tiffinbox-web/pom.xml`, one new controller that is not final, `OrderResources` (`GET /api/v1/orders/{id}`, one order as
`HAL`), one by-id read on the core module's `OrderEntityRepository`, one new test class, the committed spec regenerated and the client
rebuilt on it. Every count below is printed by `receipts.sh` on this unit's own trees; H2 answered unless a line says PostgreSQL.

`HAL`: JSON with its links under `_links`.

## Runs of record

Three runs, each launched below load1 `20` with the load printed on its first and last line, each ending
`c9-unit16: every capture = published (20)`, and `check_unit9.py 16 --runlog` read on each run log (its unit gate exits `2` until the
script of unit 16 exists, as expected; the run-log line is the one read):

- run 1: bash `3.2.57`, `RUNNO=1 ./receipts.sh` in this folder.
- run 2: bash `5.3.9`, `RUNNO=2 bash receipts.sh` in this folder.
- run 3: bash `3.2.57`, `RUNNO=3 ./receipts.sh` in a sealed copy of the repository in a folder whose path holds a space (R.129).

As run (2026-11-26, on the script as committed; each log's `check_unit9.py 16 --runlog` line: `RESULT (run logs): PASS`):

- run 1: bash `3.2.57`, load `3.26 3.85 3.79` at the start and `4.26 4.28 3.99` at the end.
- run 2: bash `5.3.9`, load `4.26 4.28 3.99` and `3.78 4.16 4.04`.
- run 3: the sealed copy (a fresh `file://` clone of `c7e5118` with this unit's files laid in, a folder named `sealed clone`), bash
  `3.2.57`, load `4.20 4.24 4.07` and `4.73 4.55 4.24`.

Each ended `c9-unit16: every capture = published (20)`. Earlier development passes on the same tree stopped at their own checks and
were fixed before the runs above: the migration's rows read by the wrong pattern, the forwarded lines keyed by four letters, the
anchor README's own prose counted as a committed configuration file, a comment in `OrderResources.java` read by the exercise's
clause 6 as code, and the harness's `final` route printing a map whose member order was not fixed (a first sealed run caught it;
the route now builds a `LinkedHashMap`, and all three runs were made again on the fixed file). The README's runs section was written after the three runs; no hashed capture reads it.

## RE-MEASURE (settled first)

1. `advisory` - the read filed for the batch day (`C9/_research/docs-2026-11-26/advisories/`, fetched `2026-11-26`) stands on the run's
   own date: its `8` checksums verified, Spring's index `25` rows with `0` naming Spring Framework and `0` naming Spring's link library,
   Tomcat's page the earlier read, the second witness (`osv`) `6` results with `0` advisories. The coordinates the shipped
   tree now names (the seven new jars, the starter as a pom edge, and Tomcat, Jackson, Spring Web, Spring Data JPA, Hibernate, the
   PostgreSQL driver and H2) are each in the read's dependency list at the version the build resolves (`advisory`, `starter`). Verdict:
   no pin affected.
2. `before` - on `before` (`21056`), `GET /api/v1/orders/1` answers four oh four, `application/problem+json`: no route maps it. The
   mappings are `30` patterns, one of them under `orders` (`/api/v1/orders`); the committed spec counts `15` operations and `13` paths by
   `ops9s3.py`, `24250` bytes, `b5ec509e`; `BOOT-INF/lib` holds `157` names, none naming the link library. `GET /api/v1/customers/Ravi` is
   `67` bytes with no `_links`.
3. `change` - three modules before and after; of the poms only `tiffinbox-web/pom.xml` differs; the changed set, derived from the two
   trees: `OrderResources.java` and `OrderResourcesTest.java` added; `OrderEntityRepository.java`, `tiffinbox-web/pom.xml`, the committed
   spec and the anchor's `README.md` changed. `OrderResources` is declared `class OrderResources` (package-private, not final);
   `OrderPages`, `CustomerReads` and `CustomerFields` stay final and byte-equal to `before`'s. `application.yaml` holds no compression,
   forwarded-header or link-library key on either tree. The handler name `orderResource` occurs once.
4. `starter` and `jackson` - the pom edit adds `6` lines (a comment of two and the dependency), removes `0`, carries no version (the
   BOM's `<spring-hateoas.version>3.1.4</spring-hateoas.version>`). `BOOT-INF/lib` goes `157` to `164`: the seven names below added, none
   removed. The web jar gains `8` entries, `7` of them under `BOOT-INF/lib/` and `OrderResources.class`; the shared entries whose CRC moved
   are the core jar, the class path index, the layers index and the module's own pom. The core jar differs in `OrderEntityRepository.class`
   alone. By unit 15's rule (the `.class` entries directly in `org/springframework/hateoas/mediatype/hal/`), `34` classes, `15` of them
   naming `tools/jackson/databind` and `0` naming `com/fasterxml/jackson/databind`: the writer is Jackson 3's.
5. `hal`, `accept` and `refuse` - see the captures. Order 1 is `225` bytes on the wire with its host `127.0.0.1:<port>` in both links;
   the same order without its `_links` member is `90` bytes (computed from the wire's bytes: the route has no answer without links).
6. `final` - by unit 15's rule, `before` holds `14` controllers: `9` final and run by default, `5` not final and only in the profile
   `dev`; `after/` holds `15`: the same `9`, `OrderResources` (not final, run by default) and the same `5`. The hook below is said of
   `before`'s census.
7. `next` - measured on the harness's page route only; the shipped list keeps its cursor.
8. `forwarded` - at Boot's default a request's `X-Forwarded-Host` and `X-Forwarded-Proto` are not read; with the run flag
   `--server.forward-headers-strategy=framework` they write the links' host.
9. `halgz` - Boot's metadata, read again on this tree: `5` keys, the switch off by default, the floor `2KB`, `8` types, `application/json`
   among them and neither `application/hal+json` nor `application/problem+json`.
10. `specwire` - the served entry names both types the route answers in, `EntityModelOrderView` as their schema; `5` differences from
    the wire are named, none fixed by hand.
11. `spec` - the committed file regenerated: `24250` to `27247` bytes, `122` lines added, `0` removed, one path added, three schemas
    added, no old byte moved; the harness's counter (`ops9s3.py`) on `before` and `after/`: operations `15` to `16`, paths `13` to `14`; the old operation ids
    equal.
12. `moved` - `0` old lines moved; the document's YAML moved (it lists the new path) and is named.
13. The seven and the old surface - byte-identical on both trees. Neither sends a request to `/api/v1/orders/{id}`: they are not a
    witness for the new route (R.511); they are this tree's witness for the starter on the class path.
14. `tests` - web `62` to `67` (`OrderResourcesTest` `5`, `0` skipped), client `1`; the slice unedited; `verify` green, the five ITs'
    `14` tests on PostgreSQL in their containers.
15. `exercise` - the broken copy's order route answers a server error, measured first; the solution passes under bash and `zsh -f`.

## The change, file by file, and every README/Javadoc sentence it rewrote or noted (R.250/R.453)

- `tiffinbox-web/pom.xml`: the starter, no version, with a *Course 9, unit 16* comment. The parent pom and the other two poms are
  byte-equal (`git diff --stat c7e5118 -- '*pom.xml'` names only this one).
- `tiffinbox-core/src/main/java/com/tiffinbox/OrderEntityRepository.java`: `Optional<OrderEntity> findById(Long id)`, one method with
  its Javadoc line. **A core file the brief did not list** (the interface had no read by id; flag C2, confirmed by the orchestrator).
- `tiffinbox-web/src/main/java/com/tiffinbox/web/OrderResources.java`: new, whole in the `change` capture.
- `tiffinbox-web/src/test/java/com/tiffinbox/web/OrderResourcesTest.java`: new, five tests, whole in the `change` capture.
- `tiffinbox-web/src/test/resources/openapi/tiffinbox.json`: regenerated by the documented step (served document, `servers` removed,
  `json.dump(indent=2, ensure_ascii=False)`, a final newline), never edited by hand.
- `c9-tiffinbox/README.md`: a *Course 9, unit 16* note under the unit 14 note and a unit 16 card. The stale-sentence hunt: the unit 13
  card's "links in an order and the page's next as a link (unit 16)" is noted as paid for the order and not for the page; the unit 14
  card's "links in a customer and the list (unit 16)" as paid for neither; every card's "`BOOT-INF/lib` stays `157` jars" as true to unit
  15 and `164` since; `OrderPages`' Javadoc line that leaves the proxy to another unit is kept as filed (the file is not edited), and
  the note names this unit as that unit. The cards' `62`, `15` operations, `13` paths and `24,250` bytes are each said with their unit and stay.

## Which tree, which profile

Every capture runs H2 in memory, a fresh database per JVM, the default profile; PostgreSQL `18.6` answers only in `verify` (the anchor's
five ITs in their Testcontainers containers, on 21280-21284). The optional `order-pg` leg was not captured and nothing is said of it.

## Unit 16's section

The brief's spine [S3B `## Unit 16`]: the link library comes with Boot `4.1.3` and writes `HAL` through Jackson 3 (`jackson`); its link
builder proxies the controller, which fails on a final one (`final`); the order's new class is the first that is not final (`final`'s
census on `after/`); the links carry the request's own host (`hal`) and a forwarded host is ignored until a setting trusts it
(`forwarded`).

The hook, unaltered, said of `before`'s census (every controller of the default run there is final, by the printed rule):

```
Spring HATEOAS builds a link by proxying the controller. Every controller TiffinBox runs by default is final, so it cannot.
```

After this unit the order's new class is the first controller of the default run that is not final; the nine others stay final. The
brief's hook names the library bare: the prose gate refuses that spoken form, and the spoken form of the library and of `HAL` is the
scripts stage's call (BUILDERS 5).

The failure receipt is `final`'s, from this run's own JVM: `methodOn(CustomerReads.class)` throws `AopConfigException: Could not
generate CGLIB subclass of class com.tiffinbox.web.CustomerReads`, its root `IllegalArgumentException: Cannot subclass final class
com.tiffinbox.web.CustomerReads`. The hazards [S3B]: the brief's count of final controllers was taken on an earlier tree and is not this
tree's (the census prints this tree's); the handler name is unique, so no old operation id moves (`spec`); the `HAL` body under
`application/json` too (`accept`).

## The captures — what each one shows

### advisory, before, change

The read filed for the batch day, verified line by line, before any capture. `before`'s answers, mappings and counts, re-derived on this
unit's own `before` (R.527). The change file by file, the new classes whole, the one core method and the pom's added lines:

```
  core | > 
  core | >     /** Course 9, unit 16: one order by its id, for GET /api/v1/orders/{id} (OrderResources) - empty when no order has it. */
  core | >     Optional<OrderEntity> findById(Long id);
  pom | >     <dependency>
  pom | >       <groupId>org.springframework.boot</groupId>
  pom | >       <artifactId>spring-boot-starter-hateoas</artifactId>
  pom | >     </dependency>
```

### starter, jackson

```
  lib | before 157 names · after 164 names
  lib | added accessors-smart-2.6.1.jar
  lib | added asm-9.11.1.jar
  lib | added json-path-2.10.0.jar
  lib | added json-smart-2.6.1.jar
  lib | added spring-boot-hateoas-4.1.3.jar
  lib | added spring-hateoas-3.1.4.jar
  lib | added spring-plugin-core-4.1.0.jar
  jackson | HAL classes 34 · referencing tools/jackson/databind 15 · referencing com/fasterxml/jackson/databind 0
```

### hal, accept, refuse

Order 1 on the wire (after/, `21050`, H2, no harness, flag off, Boot's default strategy), the host the request used in both links:

```
{"_links":{"self":{"href":"http://127.0.0.1:21050/api/v1/orders/1"},"customer":{"href":"http://127.0.0.1:21050/api/v1/customers/Ravi"}},"id":1,"customer":"Ravi","mealType":"VEG","amount":240,"placedAt":"2026-11-01T08:00:00Z"}
```

`225` bytes (curl's size, the saved file, `Content-Length` and the access log's `%b` agree); order 20 is `231`. `_links` comes first,
then the five members in the record's order. Following `customer` answers Ravi (`67` bytes). The `Accept` table, each its own request:

| Accept | status | Content-Type | bytes |
|---|---|---|---|
| `application/hal+json` | two hundred | `application/hal+json` | `225` |
| `application/json` | two hundred | `application/json` | `225`, the same bytes |
| `*/*` | two hundred | `application/hal+json` | `225` |
| none | two hundred | `application/hal+json` | `225` |
| `application/prs.hal-forms+json` | four oh six | `application/problem+json` | `150` |
| `text/html` | four oh six | `application/problem+json` | `150` |
| `application/xml` | four oh six | `application/problem+json` | `150` |

The four oh six names the two types the route answers in. The setting that writes the `HAL` body under `application/json`, read off
`spring-boot-hateoas-4.1.3.jar`'s metadata: `spring.hateoas.use-hal-as-default-json-media-type`, default `true`. The four old routes
(`/api/v1/customers/Ravi`, `/customers`, `/api/v1/customers`, `/api/v1/orders`) under `application/hal+json`, `application/json` and
`*/*` answer the same status, type and bytes on both trees: `0` moved. Under `application/hal+json` they answer that type with their
plain bodies, on `before` as on `after/`.

The refusals, each read by python: an id no order has (`21`), id `0` and id `-1`: four oh four, `order-unknown`, the detail naming the
id; a query parameter (`?x=1`): four hundred, `parameter-unknown`; an id that is not a number (`abc`), a decimal id and an id past
`Long`: four hundred with no `type` - Framework's conversion, not the route's; a trailing slash: four oh four with no `type` (Boot's
static-resource answer, not the route's); a `POST`: four oh five, `Allow: GET`. Each error is `application/problem+json` and its
`instance` is the path as sent.

### final, next

The census by unit 15's printed rule, on `after/` (on `before` the same rows without `OrderResources`):

```
  census after | CustomerFeed     final yes dev-only no  CustomerFeed.java:39
  census after | CustomerFields   final yes dev-only no  CustomerFields.java:49
  census after | CustomerImport   final yes dev-only no  CustomerImport.java:39
  census after | CustomerPatches  final yes dev-only no  CustomerPatches.java:50
  census after | CustomerPauses   final yes dev-only no  CustomerPauses.java:29
  census after | CustomerReads    final yes dev-only no  CustomerReads.java:24
  census after | DashboardPage    final yes dev-only no  DashboardPage.java:55
  census after | DishSearch       final no  dev-only yes DishSearch.java:22
  census after | DishWrite        final no  dev-only yes DishWrite.java:18
  census after | Leaderboard      final no  dev-only yes Leaderboard.java:35
  census after | Menus            final no  dev-only yes Menus.java:31
  census after | OrderPages       final yes dev-only no  OrderPages.java:63
  census after | OrderResources   final no  dev-only no  OrderResources.java:46
  census after | Revenue          final no  dev-only yes Revenue.java:40
  census after | TiffinBoxServer  final yes dev-only no  TiffinBoxServer.java:161
  census after | excluded by the rule: TiffinBoxErrors (TiffinBoxErrors.java:27) - annotated @RestControllerAdvice, not a controller the link builder proxies
  census after | controllers 15 · final, default-run 9 · not final, default-run 1 · not final, dev-only 5 · other 0
```

On the harness-joined start (`21055`), the harness's route `/probe/u16/final` runs the three forms on the app's own classes: `methodOn`
on `CustomerReads` throws the `AopConfigException` above (the same two lines in the JVM's log); the Method form on it builds
`http://127.0.0.1:<port>/api/v1/customers/Ravi`; `methodOn` on the non-final `OrderResources` builds
`http://127.0.0.1:<port>/api/v1/orders/1`. The shipped route's own `self` link is the same witness, on a harness-free start.

`next` (the harness's page route `/probe/u16/orders`, not shipped): unit 13's page one (`[19, 20, 17, 18, 15]`, a cursor of `158`
characters) with its `next` turned into a link by the Method form on the final `OrderPages`. The link's `href` is the list's own request
with the cursor (`0` `%` signs) and a URI template for the two parameters left null (`{&mealType,size}`, `templated` true); expanded,
following it answers page two, `[16, 13, 14, 11, 12]`; followed raw, its template unexpanded, Tomcat refuses it (four hundred). The shipped
`GET /api/v1/orders` answers the same page one, byte for byte, on both trees (`moved`): a `next` link on the shipped list needs a named
change to the list's answer - not made here.

### forwarded, halgz

`GET /api/v1/orders/1` with `X-Forwarded-Host: api.tiffinbox.example` and `X-Forwarded-Proto: https`, a fresh JVM per strategy:

| strategy (the command line) | with the headers | without them |
|---|---|---|
| Boot's default | `http://127.0.0.1:<port>/...` | `http://127.0.0.1:<port>/...` |
| `--server.forward-headers-strategy=framework` | `https://api.tiffinbox.example/...` (no port) | `http://127.0.0.1:<port>/...` |

With the setting on, a request that carries the header writes the link's host. The flag is on the capture's command line and in no
committed source or configuration file.

Compression is a run flag (`--server.compression.enabled=true` on the capture's command line). The shipped order, gzip asked: `225`
bytes, no `Content-Encoding`, a length under the floor; its four oh six and four oh four the same, uncompressed. The harness's route
`/probe/u16/hal-all` (the app's twenty orders as one `HAL` collection, `3344` bytes, above the floor): asked for `application/hal+json`
with gzip, `3344` bytes, no `Content-Encoding` - that type is not in the metadata's list; asked for `application/json` with gzip, the same
body gzipped to `399` bytes (`Content-Encoding: gzip`, `Vary: accept-encoding`; `gunzip` gives back the plain `3344` bytes, the two md5 values
equal) - that type is in the list. The answer depends on the type the client asked for, not on the body.

### specwire, spec

The new route's served entry against its wire:

```
  spec | 200 application/hal+json schema EntityModelOrderView
  spec | 200 application/json schema EntityModelOrderView
  spec | 400 application/problem+json schema ProblemDetail
  spec | 404 application/problem+json schema ProblemDetail
  gap | member order: the schema lists ['id', 'customer', 'mealType', 'amount', 'placedAt', '_links'], the wire sends ['_links', 'id', 'customer', 'mealType', 'amount', 'placedAt'] (JSON Schema's properties carry no order)
  gap | a link: the schema's Link lists ['href', 'hreflang', 'title', 'type', 'deprecation', 'profile', 'name', 'templated'], each link on the wire holds ['href']
  gap | _links: the schema allows any relation name (additionalProperties), the wire sends self and customer
  gap | the 406 (hal-forms, text/html, application/xml) is not documented
  gap | the 400 documents the route's own refusal; Framework's 400 for a non-numeric id (no type) is the same status, not told apart
```

The media types are annotated by the mapping's `produces` (the two types the route answers in), so the served document lists the wire's
types; the five gaps are named, not fixed by editing the file. The committed file equals the served document; the diff against
`c7e5118`'s file is four hunks of added lines (`122`), `0` removed: the path `/api/v1/orders/{id}` and the schemas
`EntityModelOrderView`, `Link`, `Links`. `OpenApiSpecTest` passes on the regenerated file. The client, generated again from it: `FILES`
`12` to `14`; `11` files differ from `before`'s build in the date line only, `ApiApi` gains lines only (`PATH_ORDER_RESOURCE` and the
`orderResource` exchange), two model files are new (`EntityModelOrderView`, `Link`); it builds and its test passes. The `PATH_*` check by
`ops9s3.py paths`: `15` on `before`, `16` on `after/`.

### moved, seven, surface, inert, tests, exercise

`moved`: unit 14's list (copied), the `Accept` class and the new route, on `before` and `after/`, each its own JVM: `37` requests, `0`
moved; `GET /api/v1/orders/1` is the added route (four oh four before, two hundred after: not a move); `GET /v3/api-docs.yaml` lists
the new path (named, as unit 13 and unit 14 named it). The seven and the old surface (`13` requests, `83` lines), each equal to its expected value,
are byte-identical on both trees; the S9.14 plant (problem details off, `21054`) moves the surface, so the check can fail. No request
carries the key header. `tests`: `mvn package` web `67`, client `1`, `0` skipped, the Docker-free twin and the hand-built web-only form
the same; `verify` exit `0`, five IT classes, `14` tests on PostgreSQL; `0` downloads. The exercise: see `exercise/`.

## Measured, not shipped

The harness's routes under `/probe/u16/` (`final`, `hal-all`, `orders`), joined only on `21055` by
`--spring.main.sources=probe.u16.U16Config`, compiled outside the module against `after/`'s extracted jar: the three link forms, the
twenty-order collection above the compression floor, and the list's `next` as a link. The slice need: measured, not needed -
`TiffinBoxWebTest` already mocks `OrderEntityRepository` and runs its `15` tests unedited.

## Refused, named

The prose gate (`harness/s916.py`, unit 15's `s915.py` with its family made `XU16`) refuses each of these, planted and caught (the
plants in `chk16.py plants`; the readings the README keeps are the near misses beside them in `s916.py`):

```
A client that follows links is immune to change.      Most teams skip HATEOAS.          HAL is compressed.
Compression shrinks every answer over 2 KB.           The list has a next link.         The href is localhost.
The framework strategy is safe.                       Spring trusts the proxy.          A link is an access control.
The starter moves nothing.                            The links make it more than double.   It answers instantly.
The route answers 404 back.                           A link relation: the name of where a link goes.   Spring HATEOAS writes it.
```

## The repository, and the network

The advisory read that clears this unit is the probe's, filed for the batch day, read on the run's own date (`advisory`). This unit puts
seven jars in a shipped pom's lib (named in `starter`; the starter itself is a pom edge) and makes no network act of its own: every build is offline from a copy of
the Section 3 seed (`11238` files, `888071893` bytes, `0` naming `central-only`), every request is on `127.0.0.1`, the only network
act is the final `git push`.

## The folders, the harness and the ports

`README.md`, `after/`, `before` (the link), `exercise/` (`README.md`, `SOLUTION.md`, `apply.sh`, `break.sh`, `check.sh`), `harness/`
(`chk16.py`, `dur9.py` and `ops9s3.py` copied byte-equal, `s916.py`, `tree16.py`, `src/probe/u16/` with `U16Config`, `U16Hal`, `U16Next`),
`receipts.md5`, `receipts.sh`. `U16Hal` and `U16Config` are adapted from unit 15's `U15Hal` and `U15Config` (the named diffs printed and
hashed at the start of each run); `U16Next` is new. Not used: `walk.py`, `follow.py`, `seal9.py`, `cdp.mjs`, `cdp9.mjs`, `loc9.py`,
unit 14's and unit 15's harness classes; the probe's captures and `ProbeHal.java` are read, not copied. Ports: `21050` after/ (no
harness), `21054` the S9.14 plant, `21055` the harness-joined starts, `21056` before, `21058` the exercise; `21051`, `21052`, `21053`,
`21057` and `21059` never bound; 21280-21284 during `verify` only. No Chrome.

## Masks, filters and hygiene

One self-tested log mask (run figures, ISO times - the order's own `placedAt` among them in the captures -, folders, the home) and one
self-tested cursor mask (a cursor keeps its first `12` characters). `Date`, the session cookie and ports are masked in the surface.
Compressed bodies are compared by their `gunzip` output and their size. Every JVM is stopped by `POST /shutdown` or by its recorded pid;
every container `rm -fv`; images and volumes equal at the end.

## Interrupted

No SIGINT point was driven in this unit's runs (as units 13 and 14: not done, said here).

## Planted faults — each caught

`harness/chk16.py plants` runs at the end of every run: each planted fault is a copy of this run's capture with one change, and each
ends with its FAIL line, exit `1`, no traceback; the prose plants are refused by `s916.py`. The S9.14 surface plant runs for real on
`21054`. Static plants (a version on the starter, a compression key, `final` on the new class, a fully-qualified `@EnabledIf...`) are
checked by `chk16.py static`.

## What differed from the brief

- C1: the list's `next` as a link is measured on the harness only (orchestrator's pick); found: the Method form leaves the null optional
  parameters as a URI template, so the raw `href` is not followable until expanded.
- C2: `findById` added to the core `OrderEntityRepository` - a file the brief did not list (orchestrator's pick).
- C3: the starter in `tiffinbox-web/pom.xml`, no version; the edit is `6` lines (unit 15's harness copy had `5`).
- C4: the census derived on both trees by unit 15's rule; the brief's earlier count is not said.
- C5: annotated through the mapping's `produces` rather than an `@Content` media type: an `@Content` naming only a media type served
  that type with an empty object under it (measured during development), so the mapping names the two types and the schema is derived from the return
  type; `5` gaps named.
- C6: the `Accept` table re-measured on the shipped route; the four oh six names the two types the route produces.
- C7: compression measured on the shipped route (under the floor) and on the harness's collection: the `application/json` ask of the
  same `HAL` body is compressed, the `application/hal+json` ask is not.
- C8: as written; the control on the framework JVM keeps the request's host.
- C9: the slice needed no edit (measured).
- C10: the client is not tracked; its generated files classified per file.
- C11: the titles read off the registry, equal.
- C12: the read stands on the batch day.
- C13: the cap - the orchestrator's header moved the end to `20:35` CET.
- C14: the title for search printed (`54` characters), not edited.
- C15: the gloss is written `` `HAL`: JSON with its links under `_links`. `` - the bare initialism is refused by the gate; the brief's hook
  holds the library's name bare and is kept, unaltered, in a fenced block: the spoken form is the scripts' call.
- Flag 2: `OrderResources` is package-private and not final, its handler package-private: `methodOn` on it works (measured), so no
  widening was needed.
- Flag 4: a trailing slash answers four oh four with no type (Boot's static-resource handler) - decided: left to Boot, named.
- Flag 12: `order-pg` not captured (first to drop): no PostgreSQL claim about the route.
- Flag 17: the `unfinal` variant shows that even a non-final `CustomerReads` does not rescue the proxy form: the proxy then fails on the
  final `Customer` record the handler returns.
- SIGINT points: not driven (said under Interrupted).
- The sealed run is a copy of the repository with this unit's files laid in (the commit is made after the three runs), in a folder whose
  path holds a space.

## For RED

The annotation pick (`produces`) and its five named gaps; the refusal forms (a trailing slash left to Boot); the visibility of
`OrderResources` (package-private, not final); the core method the brief did not list; the pom pick; the slice need's result; the `next`
link's template (C1) - if Vivek wants a shipped `next` link, it is a named change to the list's answer with the page's ITs; the
compression of the `HAL` body under `application/json` (C7); the hook's bare library name (C15); `order-pg` not captured; SIGINT not
driven. For the orchestrator: unit 15's frozen checker reads the live anchor - `chk15.py static` asserts `git diff --stat f3724ca --
c9-tiffinbox` and the poms' diff empty, and its `starter` capture compares `before`'s web pom with `../c9-tiffinbox`'s - so a re-run of
unit 15's receipts after this commit stops at its static check (a finding of the R.211/R.331 class, not a stop here; its fatal tree pins
stay).

## The ledger rows this unit pays

`TRACK-ROADMAP.md:388` ("`EntityModel`, link builders, `HAL` on screen"); C9-11 (the seven and the old surface at this anchor change);
C9-16 is not touched (Course 17's). The ledger itself is not edited here.

## The values the video may say

Each with its capture, H2, flag off unless said: order 1 `225` bytes with its two links, host `127.0.0.1:<port>` (`hal`); the four oh
six for the hal-forms ask (`accept`); `BOOT-INF/lib` `157` to `164` (`starter`); `9` final controllers of the default run on `before`, `9`
plus the new one on `after/` (`final`); the floor `2KB` and `8` types (`halgz`); the harness's `3344`-byte collection, `399` gzipped
under `application/json`, flag on (`halgz`); operations `15` to `16` (`spec`); web `62` to `67` (`tests`).

<!-- values: begin -->
```
advisory: adv_rows=25
before: before_order=404 before_ravi=67 before_mappings=30 before_ops=15/13 before_lib=157
change: changed=6
starter: pom_added=6 lib=157->164 jar_moved=4
jackson: hal_jackson=34/15/0
hal: hal=225/90
accept: accept=hal=225,json=225,406=3 accept_old_moved=0
refuse: trailing_slash=404 refusals=8 notype=a_decimal_id,a_trailing_slash,an_id_past_Long,not_a_number
final: census_before=14/9/0/5 census_after=15/9/1/5 final=AopConfigException
next: next=len=158,templated=True,pct=0,page2=200 next_raw=400
forwarded: forwarded=https://api.tiffinbox.example
halgz: halgz_meta=2KB/8 halgz=3344,hal+json=plain,json=gzip
specwire: gaps=5
spec: spec=24250->27247,+122/-0 spec_md5=ab65420b ops=15->16 paths=13->14 client=12->14,date=11,added_lines=1,new=2 path_consts=15->16
moved: moved=0 named=1
seven: seven=466c20ed
surface: surface=316a9637
tests: web_tests=67 web_before=62 k=5 its=14
exercise: ex_broken=500
inert: 
plants: plants=53
build: seed_files=11238 seed_bytes=888071893 central_only=0
```
<!-- values: end -->
