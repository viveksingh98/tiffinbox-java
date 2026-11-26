# Course 9 · Unit 15 · HATEOAS: The Argument

No anchor change. `before` and `after` are two links whose text is exactly `../c9-unit14/after` (U14's frozen tree, commit
`f3724ca`); `c9-tiffinbox` is not touched by one byte. Everything this unit measures runs on `before`, or on the harness's copy of it
(`.harness/hcopy/`, never tracked): `before` plus one pom line, the dependency `spring-boot-starter-hateoas`, and the harness's
classes `probe.u15.*`, joined on a harness-joined start only. H2 in memory everywhere; no PostgreSQL, no container, no `verify`.

A link relation: the name of where a link goes.

## Runs of record

Three runs, each launched below load1 `20` with the load printed on its first and last line, each ending
`c9-unit15: every capture = published (13)`, and `check_unit9.py 15 --runlog` on each run log (its unit gate exits `2` until the
script of unit 15 exists, as expected; the run-log line is the one read):

- run 1: bash `3.2.57`, `RUNNO=1 ./receipts.sh` in this folder.
- run 2: bash `5.3.9`, `RUNNO=2 bash receipts.sh` in this folder.
- run 3: bash `3.2.57`, `RUNNO=3 ./receipts.sh` in a sealed fresh clone of the commit, in a folder whose path holds a space (R.129).

As run (2026-11-26, on the committed script; each log's `check_unit9.py 15 --runlog` line: `RESULT (run logs): PASS`):

- run 1: bash `3.2.57`, load `3.11 3.25 3.13` at the start and `4.03 3.84 3.43` at the end.
- run 2: bash `5.3.9`, load `3.59 3.75 3.40` and `4.12 4.00 3.60`.
- run 3: the sealed clone (`file://` of the commit, a folder named `sealed clone`), bash `3.2.57`, load `3.42 3.96 3.79` and `4.33 4.03 3.84`.

Each ended `c9-unit15: every capture = published (13)`. Earlier development runs on the same tree stopped at their own checks and
were fixed before the runs above: a capture's lookup matching a request by a substring of its description, the placeholder's refused
request leaving an access-log line with no path (now checked), Apple's `strings` refusing a class file (replaced by a python read),
and the refused variants moved from run 1 only to every run. The README's runs section was written after the runs; no hashed capture
reads it.

## RE-MEASURE (settled first)

- **1. `advisory`** — S9.36. The read filed for this batch (`docs-2026-11-26/advisories/`, fetched `2026-11-26` by the probe), its
  `8` checksums verified, Spring's index `25` rows naming Spring Framework `0` times and the `Spring HATEOAS` project `0` times,
  Tomcat's page the earlier read's, the probe's t3 tree naming the nine coordinates this unit stands on (listed under `advisory`
  below), the OSV result the other witness only (`6` results, `0` with a vulnerability): no pin affected. The run's date is the
  read's date, so no network act.
- **2. `before`** — the harness-free start of `before` (`21043`): `GET /api/v1/customers/Ravi` answers `67` bytes of
  `application/json`; `GET /api/v1/customers` and `GET /customers` the same `282` bytes; the harness's `/probe/hal/customers/Ravi` and
  `/probe/entry` are not found (a four oh four each: the harness's routes are not in `before`); `/actuator/mappings` lists `30`
  request-mapping patterns, none with `probe` in it; `BOOT-INF/lib` holds `157` names and none names `hateoas`.
- **3. `pin`** — the harness's copy's `lib/` holds `spring-hateoas-3.1.4.jar` (its manifest's `Implementation-Version` `3.1.4`) and
  `spring-boot-hateoas-4.1.3.jar`; the Boot `4.1.3` BOM's line is `<spring-hateoas.version>3.1.4</spring-hateoas.version>`. By the
  printed rule (the `.class` entries directly in `org/springframework/hateoas/mediatype/hal/`, a class counted when its bytes hold the
  package's internal name), the package holds `34` classes, `15` reference `tools/jackson/databind` and `0` reference
  `com/fasterxml/jackson/databind`; the same rule with the subpackages prints its own counts beside it. `Spring HATEOAS 3.1.4` writes
  `HAL` through Jackson 3 here, from that print.
- **4. `starter`** — the one pom edit adds `5` lines (a comment and the dependency, no version) and removes none; `git diff --stat
  f3724ca -- '*pom.xml'` prints nothing; `before`'s web pom is `c9-tiffinbox`'s, byte for byte. Built WITH their tests in the same run,
  `before` and the copy each pass the four reactor lines; web `62` tests and client `1` on both, `0` failures, `0` skipped, and `0` of the
  `13` test classes differ between them. The starter adds `7` jars to `BOOT-INF/lib` (`157` to `164`, listed under `starter`
  below) and removes none; the copy's jar gains entries only under `BOOT-INF/lib/`.
- **5. `cost`** — the harness-joined start of the copy (`21040`), the seed's four customers. Bytes, each with the host its links carry:
  the shipped `GET /api/v1/customers/Ravi` `67` bytes without links; the harness's `GET /probe/hal/customers/Ravi` `210` bytes with its
  two links on `http://127.0.0.1:<port>`, `143` of them the `_links` member (the body without it is the same `67` bytes); four
  customers: the harness's collection `696` bytes against the old list's `282`, its five links on the same host. The same route asked
  with `Host: api.tiffinbox.localhost:<port>` answers `238` bytes: a longer host is more bytes in every link. `Host: localhost:<port>`
  answers `210`, because `localhost` and `127.0.0.1` are both nine characters (the brief's control, corrected).
- **6. `moved`** — the harness's member route at two builds of one source, the harness's two clients, H2, a fresh JVM each. Build A
  (`/probe/people`): the written-path client reads Ravi, the link follower reads Ravi through `…/probe/people/Ravi`. Build B (the route
  moved to `/probe/members`): the written-path client gets a four oh four (`application/problem+json`, members `detail`, `instance`,
  `status`, `title`, no `name`); the link follower reads Ravi through the new `…/probe/members/Ravi` it took from the entry point. Each
  access log shows the written client's one request and the follower's two, the entry point first.
- **7. `literal`** — BLUE's `ops9s3.py` on U15's own `before`: the committed spec (`24250` bytes, `b5ec509e`) holds `15` operations on
  `13` paths, and the served document (`21043`, harness-free, servers removed) is the committed file as parsed JSON. The client built
  from it holds `15` `PATH_*` constants in `6` files (of its `12` generated files), `13` distinct strings among them, one constant per
  operation; `0` lines of its generated sources match the link vocabulary. `ops9s3.py` refuses an empty spec and an empty directory.
- **8. `final`** — by the printed rule, `before`'s web module holds `14` controllers: `9` final and default-run, `5` not final and
  dev-only; `TiffinBoxErrors` is excluded by the rule (its annotation is the advice's). On the harness's route `methodOn()` on the final
  `CustomerReads` fails with the run's own `AopConfigException` (Could not generate CGLIB subclass), root cause `Cannot subclass final
  class`; the Method form builds `…/api/v1/customers/Ravi` on the same class; `methodOn()` on the non-final harness class builds its link.
- **9. `placeholder`** — a mapping with a property placeholder answers on its route, and the entry point's link holds the placeholder
  as written (`${probe.customers-path/probe/people}`), with the property unset and with it set to `/probe/members`. Followed, that link
  is refused with a four hundred whose author the JVM log names: Tomcat's `Http11Processor`, `Invalid character found in the request
  target`. The access log keeps a line for it with no path.
- **10. The seven and the old surface** — byte-identical on `before` (`21043`) and on the copy with the starter (`21041`, no harness):
  the seven and the old surface (`13` requests), each md5 the one read off its own receipt. The starter on the class path moved no old answer to a request the
  dependency can move. Neither is a witness for the harness's routes: they send nothing to `/probe/`. The planted surface (problem
  details off, `21042`) moves it: the check can fail.
- **11. `exercise`** — measured first, on the route the exercise names: the shipped client reads Ravi from server A and gets a four oh
  four from server B, while server B's entry point already names `/probe/members/Ravi`. The solution passes under bash and `zsh -f`;
  the four refused variants (`bothpaths`, `entryonly`, `wired`, `ignore404`) fail their clauses on every run.

## The change: none

`git diff --stat f3724ca -- c9-tiffinbox c9-unit01 … c9-unit14` prints nothing at the start, in the middle (`chk15.py static`, before
every run) and at the end. The commit is `c9-unit15/` alone.

## Which tree, which profile

`before` = `after` = `../c9-unit14/after`, pinned by `receipts.md5`'s two tree lines (`113` files, `ff8de365`), each equal to
`../c9-unit14/receipts.md5`'s `after-tree` line, read at run time. `after/` against `../c9-tiffinbox` is a note at the start and the
end (`diff -rq` empty today). H2 in memory by default, every capture, said.

## Unit 15's section

**Spine** (S3B `## Unit 15`): links let a client follow the server instead of hard-coding it; they cost bytes; this course's own
generated client shows one reason, measured: every path in it is a string constant, compiled in, with no link to follow.

**Hook:** Move one route, and the client with the path written in gets nothing. The client that followed a link still reads Ravi.

What "gets nothing" is on the wire, from `moved`: a four oh four, an `application/problem+json` body with `detail`, `instance`,
`status` and `title`, and no customer member. The hook is said of the harness's member route and the harness's two clients only.

**Failure receipt:** `moved`, build B, the written-path client's four oh four.

**Hazards, each with its capture:** the placeholder link (`placeholder`); every `href` carries the request's own host and port
(`cost`, the `Host` control; masked in the filed text).

The roadmap's line is paid as three measured legs: bytes (`cost`), the moved route (`moved`), the generated client's constants
(`literal`). Its last clause, `why most teams skip it` `[RM :387]`, is voiced only as the one measured reason this course found: the
generated client holds every path as a constant and no link vocabulary.

## The captures — what each one shows

### advisory
The S9.36 read, verified before any build (see RE-MEASURE 1). The coordinates the probe's t3 tree names:

```
org.springframework.hateoas:spring-hateoas 3.1.4
org.springframework.boot:spring-boot-starter-hateoas 4.1.3
org.springframework.boot:spring-boot-hateoas 4.1.3
org.springframework.plugin:spring-plugin-core 4.1.0
com.jayway.jsonpath:json-path 2.10.0
net.minidev:json-smart 2.6.1
org.apache.tomcat.embed:tomcat-embed-core 11.0.29
tools.jackson.core:jackson-databind 3.1.8
org.springframework:spring-web 7.0.11
```

### before
The harness-free `before`: the shipped answers, the harness's routes not found, the mappings, no `hateoas` jar.

### pin
| reading | value |
|---|---|
| `spring-hateoas` jar manifest | `3.1.4` |
| Boot `4.1.3` BOM | `<spring-hateoas.version>3.1.4</spring-hateoas.version>` |
| `mediatype/hal/` classes (direct) | `34` |
| referencing `tools/jackson/databind` | `15` |
| referencing `com/fasterxml/jackson/databind` | `0` |

The copy's `lib/` also holds Jackson 2's databind `2.21.8`, as `before`'s does (both printed): it was on the class path before the
starter; the `HAL` package references only Jackson 3's.

### starter
The one edit, printed and hashed in the capture:

```
>     <!-- THE HARNESS'S COPY (Course 9 unit 15): Spring HATEOAS, managed by Boot 4.1.3 - this copy only, never before or c9-tiffinbox -->
>     <dependency>
>       <groupId>org.springframework.boot</groupId>
>       <artifactId>spring-boot-starter-hateoas</artifactId>
>     </dependency>
```

The jars it adds to `BOOT-INF/lib`, as the capture printed them:

```
accessors-smart-2.6.1.jar
asm-9.11.1.jar
json-path-2.10.0.jar
json-smart-2.6.1.jar
spring-boot-hateoas-4.1.3.jar
spring-hateoas-3.1.4.jar
spring-plugin-core-4.1.0.jar
```

Tests on both trees, class by class, side by side: `0` classes differ. The starter alone moves no test and no served document here,
because the harness's classes are not in the module (the probe's t3 failed `OpenApiSpecTest` only because its routes were in
`src/main`). Handed to U16 as a measured fact: adding the starter to the anchor leaves web `62` and client `1` green on this tree; a
route of its own is what moves the spec.

### cost
| request | host the links carry | bytes |
|---|---|---|
| `GET /api/v1/customers/Ravi` (the shipped route) | none | `67` |
| `GET /probe/hal/customers/Ravi`, `Accept: application/hal+json` (the harness's route) | `127.0.0.1:<port>` | `210` |
| its `_links` member (body bytes minus the body without it, compact JSON, re-serialized byte-equal) | `127.0.0.1:<port>` | `143` |
| `GET /customers` (the old list, four customers) | none | `282` |
| `GET /api/v1/customers` (U14's route, the full list) | none | `282` |
| `GET /probe/hal/customers` (the harness's collection, four customers) | `127.0.0.1:<port>` | `696` |
| the harness's one customer, `Host: localhost:<port>` | `localhost:<port>` | `210` |
| the harness's one customer, `Host: api.tiffinbox.localhost:<port>` | `api.tiffinbox.localhost:<port>` | `238` |

The `_links` member comes first in the body. Under `Accept: application/json` the harness's route answers the same `210` bytes, its
`Content-Type` `application/json`; under `*/*`, `application/hal+json`. The collection's embedded key is `customerList`. Tomcat's
access log is the second witness: one line per request, its byte count curl's. No ratio of these numbers is typed here: the bytes are
the reading, with the host said.

### moved
The two builds differ in one source line, and only `U15Moved.class` differs between them:

```
<     static final String ROUTE = "/probe/people/{name}";
>     static final String ROUTE = "/probe/members/{name}";
```

| build | the harness's written-path client | the harness's link follower |
|---|---|---|
| A, the member route at `/probe/people` | `200`, Ravi | entry `200`, link `…/probe/people/Ravi`, `200`, Ravi |
| B, the route moved to `/probe/members` | `404`, `application/problem+json`, no `name` | entry `200`, link `…/probe/members/Ravi`, `200`, Ravi |

The client that read the link took the new path from the answer; the client with the path written in asked the old one. The
follower reads `_links` only: no `Link` header and no `Location` are involved.

### literal
Two counts, each by its own printed rule, on U15's own `before` (R.527):

| counter | rule | count |
|---|---|---|
| `ops9s3.py ops` | `(path, method)` pairs under `paths` | `15` operations, `13` paths |
| `ops9s3.py paths` | lines matching `String PATH_<NAME> =` in `api/*.java` | `15` constants in `6` files |

Each constant pairs with one operation; U13's `orderPage` with `PATH_ORDER_PAGE = "/api/v1/orders"`, U14's `customerFields` with
`PATH_CUSTOMER_FIELDS = "/api/v1/customers"`. `PATH_ADD` and `PATH_CUSTOMERS` share `/customers`, `PATH_MERGE` and `PATH_ONE` share
`/api/v1/customers/{name}`: `15` constants, `13` distinct strings. The probe's filed count (`generated-paths.txt`) was taken on
`c9-unit12/after`'s client, another tree (RED3 #3), and is not this unit's. This spec's generated client holds `15` path constants
and no link vocabulary (`0` lines).

### final
The census rule, printed: a class whose annotation lines include exactly `@RestController` or `@Controller`; its `final`
modifier; `@Profile("dev")` among those lines.

| controllers | final, default-run | not final, dev-only |
|---|---|---|
| `14` | `9` (`CustomerFeed`, `CustomerFields`, `CustomerImport`, `CustomerPatches`, `CustomerPauses`, `CustomerReads`, `DashboardPage`, `OrderPages`, `TiffinBoxServer`) | `5` (`DishSearch`, `DishWrite`, `Leaderboard`, `Menus`, `Revenue`) |

The census line kept by the rule: excluded by the rule: TiffinBoxErrors (annotated `@RestControllerAdvice`, `TiffinBoxErrors.java:27`).

```
methodOn: org.springframework.aop.framework.AopConfigException: Could not generate CGLIB subclass of class com.tiffinbox.web.CustomerReads: Common causes of this problem include using a final class or a non-visible class
methodOnRoot: java.lang.IllegalArgumentException: Cannot subclass final class com.tiffinbox.web.CustomerReads
methodForm: http://127.0.0.1:<port>/api/v1/customers/Ravi
nonFinal: http://127.0.0.1:<port>/probe/hal/customers/Ravi
```

`methodOn()` builds its link by proxying the class; `CustomerReads` is final (`CustomerReads.java:24`, as `CustomerFields` is at
line `49`), so it fails, measured. That is the hazard U16 builds on; U16 re-derives the census on its own `before`.

### placeholder
```
{"_links":{"ravi":{"href":"http://127.0.0.1:<port>/${probe.customers-path/probe/people}/Ravi"}}}
```

A placeholder in a mapping is written into the link as it stands, with the property unset and with it set (the route then answers at
`/probe/members/Ravi`, and the link still names the unresolved text). The link, followed, is refused: the JVM log's line names Tomcat's
request parser (`o.apache.coyote.http11.Http11Processor : Error parsing HTTP request header`, `Invalid character found in the request
target`), the body Tomcat's `HTTP Status 400 – Bad Request` page. The container refuses it before any route is chosen; the access
log's line for it has no path.

### seven and surface
On `before` and on the copy without the harness, each its own JVM: the seven and the old surface byte-identical, as read off
`c7-unit31` and `c9-unit04`. Not witnesses for the harness's routes.

### inert
No request of this unit carries the key header; the harness's clients and the exercise name it nowhere.

### exercise
See `exercise/README.md` and `exercise/SOLUTION.md`: the broken answer and the solved one, each as the capture printed it.

## The code panel

`harness/src/probe/u15/U15Hal.java` (the harness's `HAL` routes), `U15Moved.java` (the entry point and the member route at a literal
path, compiled twice), `U15Placeholder.java` (the probe's placeholder mapping, kept), `U15Config.java` (joins them), and
`harness/follow.py` (the harness's two clients) are the files the video may show whole; each is the probe's with a named diff, its
md5 printed by every run.

## Measured, not shipped

The harness's copy and its one pom line; the harness's classes `probe.u15.*`; the harness's clients. None is in a jar, the module,
`before` or `c9-tiffinbox`. The starter lands at U16, never here.

## Refused, named

Every `XU15` reading of `harness/s915.py`: a verdict word on links, an adoption claim, a typed ratio or percentage of the bytes, a
per-item figure, links said to keep a client from ever failing, `REST requires`, an uncaptured actor, generated clients in general,
`methodOn()` on any controller, a Jackson 2 `HAL`, the link always right, the refusal's author without its log line, the proxy headers
(U16's), the probe's numbers from another tree, another gloss line, a bare `HATEOAS` or `HAL` outside the title and code spans, a
status in digits.

## The repository, and the network

This unit adds no artifact to the anchor. The read that cleared the copy's coordinates is the probe's of `2026-11-26`
(`docs-2026-11-26/advisories/`), verified by `advisory` on the same day. No network act; every build `-o` from a copy of
`m2-seed-c9-s3` (`11238` files, `888071893` bytes, `central-only` `0`), `Downloading from` `0` in every log.

## The folders, the harness and the ports

`README.md after before exercise harness receipts.md5 receipts.sh`; `harness/`: `chk15.py dur9.py follow.py ops9s3.py s915.py src
tree15.py`, `src/probe/u15/` the four classes. Copied byte-equal and asserted every run: `dur9.py` (`77d6fcf8`, the registry's), `ops9s3.py`
(`8f062a0e`, BLUE's). Adapted with a named diff: `U15Hal` (from `ProbeHal`, `02f08c8d`), `U15Moved` and `U15Placeholder` (from
`ProbeMoved`, `7a322ca6`), `follow.py` (from the probe's, `93e11e4c`), `tree15.py`, `s915.py`, `chk15.py`. New: the exercise's
`client.py`, `build.sh`, `check.sh`, `apply.sh`. Read, not copied: the probe's `h35/` captures and BLUE's `B3` files. Not used:
`walk.py`, `Gzip14.java`, `seal9.py`, `cdp.mjs`, `cdp9.mjs`, `loc9.py`, U14's harness classes, `ProbeFields`, `ProbeJobsAndBills`,
`ProbeOrder*`. Ports: `21040` the copy with the harness (build A, the placeholder), `21041` the copy without it, `21042` the S9.14
plant, `21043` `before`, `21045` build B, `21048` the exercise; `21044`, `21046`, `21047`, `21049` never bound; `21280`-`21284` free.

## Masks, filters and hygiene

The log mask (self-tested every run) masks times, the folders, the user and every band port inside an `href` as `<port>`; byte counts
are taken from the unmasked files. Every JVM is stopped by `POST /shutdown` with its generated token, else by its recorded pid. No
container is started; images, volumes and containers counted at the start and the end.

## Interrupted

Three SIGINT points, each a development start of `receipts.sh` under `perl -e '$SIG{INT}="DEFAULT"; exec …'`, the signal sent to
the pid the driver recorded: mid-build of the harness's copy (a Maven build of `.harness/` live), mid-harness (a JVM listening on
`21040`), mid-exercise (the exercise's JVM listening on `21048`). Each ended with exit `130`; after each: no JVM of this unit, no
process under `.harness/`, `21040`-`21049` free, no `.r-lock`, no `.r-*.new`, the published captures unchanged, `c9-tiffinbox` =
`c9-unit14/after`, images `9` and volumes `315` as at the start. A first try at the harness and exercise points signalled between
JVMs (no listener at the signal); each was repeated with the driver waiting for the listener, as listed.

## Planted faults — each caught

`chk15.py plants` makes each planted fault fail first on a copy of the run's capture, then the prose plants on a scratch copy of this
README through `s915.py`; the run prints the count in its values. Static plants (a link retargeted, an anchor edit, a left-out capture
name, a placeholder in the prose) are refused before any build by `chk15.py static` and the gates of `receipts.sh`.

## What differed from the brief

- C1 harness: no anchor change, bound by ⚑S3-4; `c9-tiffinbox` untouched.
- C2 two links, both `../c9-unit14/after`; both tree lines equal U14's `after-tree` line.
- C3 the counts are `ops9s3.py`'s on this `before`: `15` operations, `13` paths, `15` constants in `6` files, `13` distinct strings;
  the generated set has `12` files, never mixed with the `6`.
- C4 bytes only, with the host; no ratio typed; the spine's phrase about the size is left to the reader's arithmetic on two printed numbers.
- C5 the probe's route paths kept; the harness's classes are `probe.u15.*`. Correction: `CustomerReads` and `CustomerNotFound` are
  package-private in `com.tiffinbox.web`, so `U15Hal` reaches `CustomerReads` by reflection and answers a missing customer with a
  `ResponseStatusException`; the bytes are the probe's (`210`, `143`, `696`).
- C6 the copy's one pom edit; the harness compiled outside by `javac` against the copy's `lib/`.
- C7 bytes and the constants, each measured once; "no link to follow" said only of this spec's client.
- C8 the refuser named from the JVM log: Tomcat's `Http11Processor`. The brief's control (the property set) also refused: the link
  keeps the unresolved text, measured.
- C9 the census: `9` final default-run, `5` dev-only, the advice excluded, by the printed rule.
- C10 `3.1.4` from the jar and the BOM.
- C11 the advisory read stands on the batch day.
- C12 the seven and the surface on `before` and on the copy without the harness; not witnesses for the harness's routes.
- C13 the title for search printed, `51` characters, not edited.
- C14 the hook unaltered (`22` words); "gets nothing" is a four oh four with a problem body. Correction: the body is
  `application/problem+json` (Spring's problem details are on in this tree), not Boot's `/error` JSON the brief guessed.
- Flag 5, corrected: `Host: localhost` is the same length as `127.0.0.1`, so it moves no byte; the longer host
  `api.tiffinbox.localhost` was added as the control, `238` bytes.
- Flag 4, corrected: the `HAL` package counts by this unit's rule (direct classes) are `34` / `15` / `0`; the probe's `62` / `26` / `0`
  were taken by another rule; the subpackage rule's counts are printed beside it. The finding (Jackson 3 only) holds by both.
- Flag 13: the exercise's servers live in `.harness/servers/` (ignored by the repository's `c9-unit*/.harness/` rule), not
  `exercise/.servers/`, which the root ignore file does not cover and this unit may not edit.
- Flag 13: the exercise line is `22` words after `Your turn:` (`24` with it), as extracted.
- Flag 6: `U15Config` imports both legs; `probe.u15.leg` picks `U15Moved` (default) or `U15Placeholder`, since both map `/probe/entry`.
- Flag 13: the refused variants run on every run under bash (3/3), not run 1 only; they are hashed.
- SIGINT: the three points done (see Interrupted); U13 and U14 did none.

## For RED

- C1-C14 as above; the census rule and its excluded line (`TiffinBoxErrors`).
- The placeholder's refuser is Tomcat's request parser, named from the log; Python's `urllib` sends the `href` as written, a client
  that escapes the dollar sign and the braces would send a different request (not measured).
- The host control: equal-length hosts move nothing; the longer host moves `28` bytes over two links.
- What "gets nothing" is on the wire: a four oh four problem body.
- The starter's measured effect on the tests: none on this tree (`0` classes differ); handed to U16.
- `HAL` is served under `Accept: application/json` with `Content-Type` `application/json` (the same bytes).
- The exercise's design: two builds, one server at a time on one port; `wired` proves a link carried in a file fails.
- The spine's phrase about the size stays the spine's: the README types bytes only.

## The ledger rows this unit pays

`[RM :387]`, as three measured legs. C9-11 is not re-paid (no anchor change; the `15` operations are a count on this tree, not a
diff). C9-16 is Course 17's, no Course 9 action. No ledger edit. One note for the orchestrator: no ledger row names U15's legs, and
BLUE's pointers `#223`-`#225` stay open at `U11/exercise/README.md:23`.

## The values the video may say

Each from this unit's receipts, the same on every run: `210` and `67` bytes on `127.0.0.1:<port>`, `143` of them the links; `696`
for four customers against `282`; the written-path client's four oh four and the follower's two hundred; `15` path constants for
`15` operations; the placeholder link refused with a four hundred by the container.

<!-- values: begin -->
```
advisory: adv_rows=25 adv_hateoas=0
before: before_mappings=30 lib_before=157 plain=67 old_list=282
pin: hateoas=3.1.4 hal_classes=34/15/0
starter: copy_build=exit0 copy_reactor=4S/0F/0K web_before=62 web_copy=62/0/0/0 client=1/1 classes_moved=none lib=157->164 lib_added=7
cost: four_nolinks=313 four_links=383 hal_one=210 links=143 plain=67 hal_four=696 old_list=282 host_longer=238 json_ctype=application/json
moved: moved=404/200 moved_404_type=application/problem+json
literal: ops=15 paths=13 spec_bytes=24250 spec_md5=b5ec509e constants=15 const_files=6 distinct=13 link_vocab=0 client_files=12
final: census=9/5/0
placeholder: ph_unset=400 ph_set=400 refuser=Http11Processor
seven: seven=466c20ed
surface: surface=316a9637
exercise: ex_broken=200/404 ex_variants=4
inert:
plants: plants=36
build: seed_files=11238 seed_bytes=888071893 central_only=0
```
<!-- values: end -->
