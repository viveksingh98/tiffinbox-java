# Course 9 · Unit 07 — OpenAPI: The Contract

**Course 9's fourth change to the anchor, and Section 2's first unit.** springdoc-openapi `3.2.1` now reads TiffinBox's
`@RestController` handler methods at start and serves the document they describe at `/v3/api-docs`; a copy of that document is
committed in the tests (`tiffinbox-web/src/test/resources/openapi/tiffinbox.json`, no `servers`), and one new test checks the code
against that file. `before` is a link to `../c9-unit06/after` (unit 06's tree); `after/` is a frozen copy of `../c9-tiffinbox` after
this unit's change. Every number below names its tree and is read by `harness/chk07.py` off a capture of `receipts.sh`, never typed.

The hook, as the brief gives it (S2B :158), byte for byte:

TiffinBox's own spec says a new customer's meals are optional. Leave them out, and TiffinBox answers four hundred.

It is true of two properties, `mealsPerDay` and `pricePerMeal` (the `diff` capture's `required` row); the spoken word "meals" covers
both, and the brief's sentence stands as written.

## Runs of record

Three runs, each launched below load1 `20` (R.480) with its load printed on its first line: bash `3.2.57` (`./receipts.sh`), bash
`5.3.9` (`bash receipts.sh`), and a sealed fresh clone of the repository in a folder whose name holds a space (R.129). Every build
says offline: yes (`Downloading from` `0` in every Maven log). Each run ended `every capture = published (13)`, and
`check_unit9.py 07 --runlog <log>` printed `RESULT (run logs): PASS` on each (the unit gate exits `2`, not judged, until unit 07's
script exists, as the prompt expects). The load each run printed on its first line: run `1` (bash `3.2.57`) `4.04`, run `2`
(bash `5.3.9`) `11.37` - both below the bar; run `3`'s is in the commit message, which this README cannot quote. The machine was
shared with another session's work through runs `1` and `2`, so no clock figure of a run is a measurement and none is said here.

## RE-MEASURE (settled first)

1. **The three addresses and the document.** On `before` (unit 06's tree, H2, the request witness joined) `GET /v3/api-docs`,
   `GET /swagger-ui.html` and `GET /swagger-ui/index.html` each answer four-oh-four, written by the static handler
   (`ResourceHttpRequestHandler`), Boot's problem detail "No static resource" - Course 8's line in What's Next: The API Other People Will Use
   (`The API docs route and the Swagger page answer four-oh-four: TiffinBox publishes no contract today.`, ledger `C9-10d`) is
   still true of unit 06's tree. On `after/`, with no harness, PostgreSQL `18.6` first and then H2: `/v3/api-docs` answers
   `application/json`, the page's address redirects to `/swagger-ui/index.html`, which answers too (status lines only: the page is
   *springdoc-openapi and Swagger UI*'s). The document: `openapi` `3.1.0`, `info` `OpenAPI definition` / `v0`, `11` paths, `13`
   operations, `6` tags, the schemas `Customer` and `SseEmitter`, no `components.securitySchemes` and no `security` member (data for
   *Documenting Errors, Examples and Security*, claimed nowhere here). Its `servers[0].url` is the request's own host and port; with
   `servers` removed and written by the fixed rule it is byte-identical on both databases and to the committed file.
2. **The census: seventeen handlers, thirteen operations.** One flag start per tree (the exposure flag once on the command line,
   never shipped): TiffinBox's `17` handler rows are byte-equal on `before` and `after/`, partitioned `12` + `2` + `2` + `1` by the
   anchored grep at each commit (unit 07 adds `0`); the other rows differ by exactly springdoc's `4` (`/v3/api-docs`,
   `/v3/api-docs.yaml`, `/v3/api-docs/swagger-config`, `/swagger-ui.html`). Matched to the document by method, path and tag,
   `DashboardPage`'s three handlers are absent (springdoc reads `@RestController` classes; `DashboardPage` is a `@Controller`, and
   two of its three share a method and a path with `TiffinBoxServer`'s - only the tag tells them apart), and `CustomerPatches`' two
   PATCH handlers are one operation with two request media types: `17` - `3` - `1` = `13`.
3. **The spec against the wire, by script.** `specwire9.py` (BLUE's instrument, byte-equal) sends its twelve requests to a fresh
   database and files each request and answer; `diff` over the harness-free document and those pairs, with no third argument,
   prints `7` kinds and `16` rows on this tree - the spec parts from the wire in seven kinds, counted by a script. They are
   `required` (the spec `[mealType, name]`, the wire refusing each of the four when it is left out), the name's `minLength` `0`
   against the blank name's four hundred, the success status (both create routes documented as two hundred, answered two-oh-one),
   the response media type (`*/*` on `12` of the `13` operations; the feed's `text/event-stream` agrees), `0` error responses
   against the four hundreds answered, the pause route's required `Idempotency-Key` named `0` times, and the feed's
   `SseEmitter {timeout}` against its `:listening` event. Property names agree, four of four. With the probe's filed generated
   source as the third argument (U10's tool's output, read, not produced here) it prints BLUE's `8` kinds and `17` rows, its output
   md5 equal to BLUE's filed run. The planted rename moves both by exactly one; an empty wire folder is refused, exit `2`. The same
   census on PostgreSQL `18.6` gives every status and content type and every row as H2 does.
4. **The committed file and its test.** The file is `9851` bytes (`wc -c`), no `servers`, written by Python's
   `json.dump(indent=2, ensure_ascii=False)` with a final newline. `OpenApiSpecTest` passes at `mvn package` and in its Docker-free
   twin; a drifted copy of the file (`required` widened to four) and drifted code (the record's `@Size(max = 60)` made `61`) each
   make it fail with its own assertion line, exit `1`. In the same run it passes while `diff` prints its rows: the test checks the
   code against the committed file, and nothing else.
5. **`moved`.** Twelve requests on `before` and on `after/`, each tree its own JVM: the three addresses are the one named move
   (moved, compatible (an addition), named in this unit: four-oh-four to the `after/` answers); the nine others answer byte for
   byte as before - among them the pinned sentence's request (a PATCH to slash customers answers four-oh-five, `Allow` the set
   `GET`, `POST`, on both trees) and `GET /nowhere`, the old request that reaches the resource handlers springdoc's page now sits
   beside.
6. **Tests per runner.** `45` at `mvn package` = unit 06's `44` (its values block, re-measured here) + `1` (`OpenApiSpecTest`), the
   same in the Docker-free twin; `14` in the five ITs at `mvn verify`, each `IT BINDINGS` line on its own `127.0.0.1:2128x` port,
   no IT wait timed out, no Testcontainers container left. `BOOT-INF/lib` `146` → `157`: eleven names added, none removed, no other
   version moved.
7. **The seven and the old surface.** The seven and the old surface (by count, `13` requests, `83` lines) answer byte for byte the hashes
   unit 06's values block holds, on `before` and on `after/` (the values block below carries them). Witness for this change: `GET /nowhere`, the one request of the
   set that reaches the resource handlers; not a witness for this change: the other requests of the seven and the surface - they
   stay equal because they do not reach it.

## The change, file by file, and every README/Javadoc sentence it rewrote or noted (R.250/R.453)

`git status --short c9-tiffinbox` lists five paths, `chk07.py static` asserts the same five against `before`: three changed, two new,
nothing under `src/main/`.
- `pom.xml`: `<springdoc.version>3.2.1</springdoc.version>` after the Parsson pin, once (S9.7), with a comment that names the parent
  POM line (`springdoc-openapi-3.2.1.pom:13` names Spring Boot `4.2.0`; this tree runs `4.1.3`), the two earlier lines not weighed
  (`3.1.0`, `3.1.1`; the seed holds `3.2.1` only), the surface it was measured on and this unit's receipts; what would change it
  is named by its lesson's title (*Versioning Strategies*). The word that R.515 refuses alone is not in it (`chk07.py static`). The
  managed `org.springdoc:springdoc-openapi-starter-webmvc-ui` follows `tiffinbox-core` in `dependencyManagement`.
- `tiffinbox-web/pom.xml`: the UI starter, no version, after `spring-boot-starter-webmvc`, with its comment.
- `tiffinbox-web/src/test/java/com/tiffinbox/web/OpenApiSpecTest.java`: package-private, `@SpringBootTest` with no web environment,
  MockMvc on the context, the file read off the test class path, `servers` removed on both sides, Jackson 3 `JsonNode` equality; no
  system property and no Docker. Its Javadoc says what it catches (the code drifting from the committed file), what it does not (the
  document drifting from the wire - the receipt's script), and that a change to the document on purpose makes it fail until the
  file is written again in the same commit.
- `tiffinbox-web/src/test/resources/openapi/tiffinbox.json`: written once, by this unit's author, from `/v3/api-docs` on the changed
  tree (H2), `servers` removed, the fixed rule; `receipts.sh` only asserts it.
- `README.md`: a `## Course 9 · unit 07` card after unit 06's and a note under the header's unit 06 note.

The hunt over `c9-tiffinbox/`: at `a805e6c` no source, POM or YAML says `api-docs`, `swagger`, `openapi` or `springdoc`, and neither
does the README, so no sentence there said the document answered four-oh-four. The README's `BOOT-INF/lib 146 jars` and its test
counts (line `12`) are the set-up's starting point, kept as written by unit 04's note: unit 07's note says so and does not rewrite them.
Course 8's dated sections that name `146` (its unit 21 note, line `1423`) are history, kept. The handler Javadoc in
`TiffinBoxServer.java` that names the mapping annotations is not edited, and no handler is added. The grep for R.211/R.331 over
`c9-unit01`-`06`'s `receipts.sh` and `harness/`, `C9/_builders/*.py` and the tools in `~/Desktop/PromptVidya-Automation` (the five
changed paths and the README) is in "For RED".

## Which tree, which profile

`before` = unit 06's `after`: Spring Boot `4.1.3`, Framework `7.0.11`, Tomcat `11.0.29`, Jackson `3.1.8` (with the `2.21.8` jar
present), `17` handler methods, `44` tests at `package`, `146` jars. `after/` = that tree plus this unit's change. The default
profile everywhere; H2 in memory unless a line says PostgreSQL `18.6` (the image by its digest, `127.0.0.1:20961` alone, a fresh
database per JVM). The document every claim reads comes from a start without the harness: a start that joins it documents the
harness's routes too (the `diff` capture counts them), and no claim reads that document.

## Unit 07's section

The spine, against S2B :155-:157: the routes are already a promise to their callers; springdoc reads them off the code and serves
the document. Generated means it says what the code says - two required properties where the wire requires four, two hundred where
TiffinBox answers two-oh-one, no errors at all. So the spec is checked against the wire by a script that counts where they part, and
committed, and a test fails when the code drifts from the committed file. The failure receipt is `diff`'s `required` row: the spec's
`[mealType, name]` beside the four hundred for an absent `mealsPerDay` (R.312: the server is right, the spec under-states), with its
negation in the same run - all four sent, two-oh-one. The hazards, each with its capture: `servers[0].url` is the socket's host and
port (`after`) and `http://localhost` under MockMvc (`tests`, `committed`), masked and never committed; `@Controller` handlers are
skipped (`census`); the name's `minLength` `0` from `@Size(max = 60)` sits beside `@NotBlank` (`diff`); the generator's beta banner is
the code generation lesson's (not met here). The hand-off of S1B §Q-d: none is addressed to this title.

## The captures — what each one shows

### tests — the counts per runner, the jars
`package`, its Docker-free twin and `verify`, each on its own copy of `after/`; Surefire's and Failsafe's XML per class; the five
`IT BINDINGS` lines; `BOOT-INF/lib` before and after and the eleven names that moved.

### census — handlers and operations
The two flag starts' mappings (TiffinBox's rows, springdoc's four, the others), the partition by commit, and one line per handler:
its operation or "absent". The code panel's table:

```
DashboardPage#add | POST /customers | absent          DashboardPage#form | GET /customers/new | absent
DashboardPage#page | GET /dashboard | absent          CustomerPatches#merge + #jsonPatch | PATCH /api/v1/customers/{name} | one operation
17 handlers - 3 absent - 1 merged = 13 operations     springdoc's own: /v3/api-docs  /v3/api-docs.yaml  /v3/api-docs/swagger-config  /swagger-ui.html
```

### after — the three addresses and the document
Five addresses per database (the three, the YAML form, the page's configuration), each with its status, type and access-log line;
the document's facts; its md5 masked and with `servers` removed; the committed file beside it.

### diffpg, diff — the spec against the wire
The twelve filed pairs, each request body printed; `diff` (a) and, on H2, (b), the plant and the empty refusal; the second client's
reads (the valid customer there, the refused names absent, the key table `0` → `1`); on H2 the request witness for the addresses and
the wire's mapper. The rows, as (a) prints them:

```
 1 required                 spec: ['mealType', 'name'] | wire: ['mealType', 'mealsPerDay', 'name', 'pricePerMeal']
 2 name minLength           spec: 0 | wire: 400
 5 post-ok status           spec: ['200'] | wire: 201
12 pause-nokey header       spec: header params [] | wire: requires Idempotency-Key
15 error responses          spec: 0 | wire: [400]
16 feed schema              spec: #/components/schemas/SseEmitter | wire: events: :listening
```

The feed's schema name and its one property (`"timeout"`, `tiffinbox.json` line `446`) appear only in fences and code spans here,
as names.

### jackson — which Jackson wrote each side
Python reads the class files' constant pools in `after/`'s `BOOT-INF/lib`: swagger-core `3.0.0`'s `ObjectMapperFactory` names
Jackson 3's databind (`54` entries) and Jackson 2's `0` times; `47` classes of springdoc's common jar name Jackson 3's, `0` Jackson
2's. The wire's mapper (the harness's read) is Jackson 3's `JsonMapper`; no Jackson 2 `ObjectMapper` bean exists, though its jar is
there. springdoc 3.2.1 reads the class with Jackson 3, and Jackson 3 wrote the answers. The setup's expectation (S2B :23-:25, quoted beside the capture)
is overruled by these lines.

### committed — the file, the test, two drifts
The file's facts, the test's two passes, MockMvc's `servers` beside the socket's, the two drifted mirrors' diffs and failure lines,
and the line that ties the test's pass to `diff`'s rows in the same run.

### moved, seven, surface — what springdoc could have moved
`moved`: twelve requests per tree, the three named moves and nine equal lines. `seven` and `surface`: the seven and the old surface
per tree, and the S9.14 plant (a shallow ETag filter on every path, the harness's): the seven stay equal, the surface moves, the feed
answers nothing at its alarm.

### inert — the key header and the key table
Every request of the run that says whether it sent the key: only `specwire9.py`'s `pause-key` did, on each database; the key table
`0` on `before`'s JVM and before each census, `1` after it.

### exercise — under bash and zsh, H2 and PostgreSQL
`check.sh` on the broken tree, the solution (`apply.sh`) and four refused "solutions", each under bash and `zsh -f`; the broken
tree and the solution also on PostgreSQL.

## Measured, not shipped

The exposure flag (`--management.endpoints.web.exposure.include=health,prometheus,mappings`, the two census starts only); the harness
classes (`probe.*`, `/probe/**`, the harness's routes); the request witness's logging; the drifted file and code (scratch mirrors
under `.harness/`); the shallow ETag plant; the exercise's solution and its refused variants.

## Refused, named

Each `XU07` reading in `harness/s907.py` (twenty-two families, each with its plant and its near miss, listed in that file and run by
its self-test before any prose is judged). Not done here,
by its lesson: an `info` bean and the page (*springdoc-openapi and Swagger UI*), documented errors and a security scheme
(*Documenting Errors, Examples and Security*), the generated client and the eighth kind voiced from this tree (*Code Generation From
the Contract*), versioned routes (*Versioning Strategies*). No browser is started; no clock figure is used as a number.

## The repository, and the network

`D` = `tiffinbox-java`, HEAD `a805e6c` at the start, clean, `0 0` against `origin/main`; one commit for `c9-unit07/` and the five
paths of `c9-tiffinbox/`, then one push. Every Maven build is offline (`-o`) from a `cp -c` copy of `_research/m2-seed-c9-s2`
(`11004` files, `876159996` bytes, `_remote.repositories` naming central-only: `0`); no pull, no image pulled. The advisories are
today's filed read (`_research/docs-2026-11-24/advisories/`, fetched at `2026-11-24T20:36:35Z`), not read again: Tomcat's section for
`11.0.30` and OSV's "none" for the springdoc coordinates; no pin is affected.

## The folders, the harness and the ports

`harness/`: `chk07.py`, `s907.py` (its self-test first), `tree07.py` (`tree06.py`'s code), `dur9.py` (as shipped), `specwire9.py`
(BLUE's, byte-equal), and `src/probe/` - `Witness`, `Http`, `Routes`, `Etag` copied from unit 06's harness (`c9-unit06/harness/src/probe`,
md5 = its `receipts.md5` lines) and `u07/U07Probe` (the second client's reads and the mapper read). Ports: `20960` `after/` on H2 ·
`20961` PostgreSQL `c9u07-pg` · `20962` `after/` on PostgreSQL · `20963` the flag start · `20964` the S9.14 plant · `20965`, `20967`
asserted free · `20966` `before` · `20968` the exercise · `20969` never bound; `21280`-`21284` during `verify` only.

## Masks, filters and hygiene

The log mask (a Started line's figures, Maven's and Boot's clock figures, Boot's `/error` `timestamp`, the folders, the home) and the header mask
(`Date`, the session cookie, a port, `Expires`, `Keep-Alive`) each pass a self-test; a third self-test masks `servers[0].url`'s port.
Maven's `Time elapsed` and `Total time` are masked. The duration-shaped words of the document (`"timeout"` in `SseEmitter`,
`tiffinbox.json` line `446`) appear here only in the fenced rows block and in code spans; dur9 over this README and the exercise: `0`.
Every container is removed with its volumes; images and volumes are equal on each run's first and last lines.

## Interrupted

Six interrupted runs of this `receipts.sh`, each started with SIGINT at its default (`perl -e '$SIG{INT}="DEFAULT"; exec …'`: a
background job starts with it ignored, and bash cannot trap a signal ignored at entry), the signal sent to the script's own pid when
its point's line appeared (and, where a line says so, when the port or the Testcontainers container was live). Each exited `130` (the
INT trap's own `exit 130`); the EXIT trap stopped every JVM by its pid, removed `c9u07-pg` and the Testcontainers containers by label
(`rm -fv`), and left no `.r-lock`, no `.r-*.new`, no exercise file; the captures, the volumes, the images and the anchor read back as
before. The lines, as the interrupting script printed them:

```
SIGINT mid-build: at /guard before the build of after/ (live then: java 1 · pg 0 · tc 0) -> exit 130 · left: java 0 · containers 0+0 · volumes 315 · images 9 · listeners 0 · .r-lock no · .r-*.new 0 · exercise/ README.md,SOLUTION.md,apply.sh,check.sh · captures unchanged · anchor = after/
SIGINT mid-harness: at /AH up on 20960/ (live then: java 1 · pg 1 · tc 0) -> exit 130 · left: java 0 · containers 0+0 · volumes 315 · images 9 · listeners 0 · .r-lock no · .r-*.new 0 · exercise/ README.md,SOLUTION.md,apply.sh,check.sh · captures unchanged · anchor = after/
SIGINT mid-container: at /c9u07-pg: PostgreSQL/ (live then: java 0 · pg 1 · tc 0) -> exit 130 · left: java 0 · containers 0+0 · volumes 315 · images 9 · listeners 0 · .r-lock no · .r-*.new 0 · exercise/ README.md,SOLUTION.md,apply.sh,check.sh · captures unchanged · anchor = after/
SIGINT mid-pg-tiffinbox: at /AP up on 20962/ (live then: java 1 · pg 1 · tc 0) -> exit 130 · left: java 0 · containers 0+0 · volumes 315 · images 9 · listeners 0 · .r-lock no · .r-*.new 0 · exercise/ README.md,SOLUTION.md,apply.sh,check.sh · captures unchanged · anchor = after/
SIGINT mid-verify: at /guard before mvn verify/ (live then: java 2 · pg 0 · tc 1) -> exit 130 · left: java 0 · containers 0+0 · volumes 315 · images 9 · listeners 0 · .r-lock no · .r-*.new 0 · exercise/ README.md,SOLUTION.md,apply.sh,check.sh · captures unchanged · anchor = after/
SIGINT mid-exercise: at /== the exercise, h2, solved, bash/ (live then: java 1 · pg 1 · tc 0) -> exit 130 · left: java 0 · containers 0+0 · volumes 315 · images 9 · listeners 0 · .r-lock no · .r-*.new 0 · exercise/ README.md,SOLUTION.md,apply.sh,check.sh · captures unchanged · anchor = after/
```

A first pass of three of these points matched a line in the last run's raw capture files and fired early; the script then removed
them before each point, and the three were run again (the lines above are the second pass's).

## Planted faults — each caught

Each plant ran on a scratch mirror (copies of this run's captures and filed pairs, or a copy of `after/` beside a copy of `harness/`),
never on `c9-unit01`-`06` or the live anchor, and was removed afterwards; each ended with its FAIL line, exit `1`, no traceback. The
prose plants print the gate's refused count. The script's own lines, as it printed them:

```
PLANT 2 a filed request removed -> exit 1 · FAIL h2: the twelve filed pairs, in BLUE's order, each request body printed (11)
PLANT 2 the required row swapped -> exit 1 · FAIL h2: the required row = the re-derived sides (spec ['mealType', 'name'], wire ['mealType', 'mealsPerDay', 'name', 'pricePerMeal']) - the failure receip
PLANT 2 the kinds typed eight in (a) -> exit 1 · FAIL h2: (a) KINDS 8 = the distinct kinds of its rows
PLANT 2 the plant moving by two -> exit 1 · FAIL the plant (mealType -> meal_type) moves the kinds and the rows by exactly one in (a) and (b) (R.508)
PLANT 2 a refused name present -> exit 1 · FAIL h2: the valid POST's customer is there (1 row), the refused names are not (2 of 3; the nameless two have no name to ask)
PLANT 2 the empty refusal exit 0 -> exit 1 · FAIL an empty wire directory: refused, exit 2
PLANT 3 operations typed 12 -> exit 1 · FAIL handlers - absent - merged = the document's operations: 17 - 3 - 1 = 12 (every operation maps a handler)
PLANT 3 a mapping line removed -> exit 1 · FAIL one mapping line per TiffinBox handler method (after 16, before 17)
PLANT 3 a springdoc row as TiffinBox's -> exit 1 · FAIL one mapping line per TiffinBox handler method (after 17, before 17)
PLANT 3 the partition off by one -> exit 1 · FAIL the partition by commit = U06's values block (12,2,2,1)
PLANT 3 the unanchored grep -> exit 1 · FAIL the unanchored pattern counts one line more (a Javadoc's {@code @GetMapping})
PLANT 4 the detector on before (200) -> exit 1 · FAIL before: GET /v3/api-docs -> 200 (want 404)
PLANT 4 servers unmasked -> exit 1 · FAIL pg: servers[0].url masked ([{"url": "http://127.0.0.1:20960", "description": "Generated server url"}])
PLANT 4 the H2 / PostgreSQL label -> exit 1 · FAIL the database label: PostgreSQL 18.6 on the pg block, H2 on the h2 block (each block's own Flyway line: ('H2', '2.5'), ('H2', '2.5'))
PLANT 5 the test deleted (45 -> 44) -> exit 1 · FAIL pkg: 44 = U06's 44 (its README values block; re-measured) + 0 (OpenApiSpecTest)
PLANT 5 a drift that passes -> exit 1 · FAIL (iii) the drifted file: the test FAILS (exit 1, Failures 1)
PLANT 7 44 + 1 typed 44 + 2 -> exit 1 · FAIL pkg: 46 = U06's 44 (its README values block; re-measured) + 2 (OpenApiSpecTest)
PLANT 7 an IT BINDINGS line removed -> exit 1 · FAIL IT BINDINGS: classes 5 (found 4)
PLANT 7 an IT on 127.0.0.2 -> exit 1 · FAIL IT BINDINGS: entries 5 · not 127.0.0.1: 1
PLANT 7 one IT port off by one -> exit 1 · FAIL ElasticsearchIT on 127.0.0.1:21284
PLANT 7 one more jar moved -> exit 1 · FAIL the jars whose names moved: 11 added (commons-lang3-3.20.0.jar jackson-dataformat-yaml-3.1.8.jar snakeyaml-engine-3.0.1.jar springdoc-openapi-starter-common
PLANT 8 the seven one character off -> exit 1 · FAIL after: the seven = 466c20ed
PLANT 8 the surface moved -> exit 1 · FAIL the old surface: before = after/, no line moved
PLANT 9 the S9.14 plant not moving -> exit 1 · FAIL the ETag plant (the harness's): the seven unchanged, the old surface moved
PLANT 11 the moved set widened -> exit 1 · FAIL moved: exactly the three addresses (S9.37, the one named compatible move - an addition): ['GET /customers/Ravi', 'GET /swagger-ui.html', 'GET /swagger-u
PLANT 14 an unparseable listing line -> exit 1 · FAIL a moved line this checker cannot parse: '  after | GET /nowhere ??? -> 404 application/problem+json 95 · Allow {} · Accept-Patch {} · Location {} 
PLANT 19 a key outside pause-key -> exit 1 · FAIL wire-h2: 12 filed requests, the key header on pause-key alone
PLANT 19 the key table 1 on before -> exit 1 · FAIL before's JVM: the key table 0 rows
PLANT 13 solution = broken -> exit 1 · FAIL h2 solved (bash): PASS:
PLANT 1 the hook one byte changed -> exit 1 · FAIL the hook is S2B :158's, byte for byte (extracted at run time = typed once here)
PLANT 1 the exercise with 400 in digits -> exit 1 · FAIL the exercise's line is S2B :166's, byte for byte (extracted at run time = typed once |FAIL the exercise: 20 words (wc -w; the brief's 19; <= 25
PLANT 1 the exercise at 26 words -> exit 1 · FAIL the exercise's line is S2B :166's, byte for byte (extracted at run time = typed once here)
PLANT 12 bare OpenAPI in the exercise line -> exit 1 · FAIL the exercise: the spelling gate 0 (API, URI, URL, RFC, bare OpenAPI / springdoc / Swagger)
PLANT 1 a second gloss line in the README -> exit 1 · FAIL README.md carries no line starting "A contract:" (no second gloss) [314]
PLANT 10-12 prose "The page loads immediately." -> refused: 4
PLANT 10-12 prose "TiffinBox answers 404 here." -> refused: 1
PLANT 10-12 prose "The spec matches the wire." -> refused: 1
PLANT 10-12 prose "The test checks the spec against the wire." -> refused: 1
PLANT 10-12 prose "The dependency is compatible." -> refused: 1
PLANT 10-12 prose "The document carries the timeout property." -> refused: 1
NEAR MISS "Open A-P-I and spring doc are the spoken forms." -> refused: 0
NEAR MISS "The committed file is a contract, and the wire keeps only part of it." -> refused: 0
PLANT 6 the bare word compatible -> exit 1 · FAIL R.515: the bare word "compatible" is not in the comment
PLANT 6 no parent-POM line -> exit 1 · FAIL R.515 (1): the comment names the parent POM line (Boot 4.2.0, springdoc-openapi-3.2.1.pom:13)
PLANT 6 no alternatives -> exit 1 · FAIL R.515 (2): the comment names the alternatives not weighed (3.1.0, 3.1.1)
PLANT 6 a second springdoc.version -> exit 1 · FAIL tiffinbox-web/pom.xml: the starter with no version and no second springdoc.version
PLANT 5 the file committed with servers -> exit 1 · FAIL the committed file carries no servers|FAIL the committed file is written by the fixed rule (json.dump indent 2, ensure_ascii False, a final new
PLANT 5 a system-property knob -> exit 1 · FAIL OpenApiSpecTest: no system-property or environment knob|FAIL OpenApiSpecTest: one test, the file off the test class path, servers removed
PLANT 16 a stale sentence in the card -> exit 1 · FAIL the stale hunt: unit 07's card says nothing as current that the change makes false (['/v3/api-docs[^.\n]
PLANT 5/16 src/main touched -> exit 1 · FAIL no other file differs between before and after/ (before 96 files, after/ 98) ['tiffinbox-web/src/main/jav|FAIL nothing under src/main/ is new or changed (n
plants: 48 run, 0 not caught
```

Also planted by the receipt itself, in every run: the detector "`/v3/api-docs` answered two hundred" against `before`'s capture
(it fails there), the renamed property in the document (`diff` moves by one), the empty wire folder (refused), the drifted file and
the drifted code (the test fails), the S9.14 shallow ETag filter (the surface moves), four refused exercise "solutions" and the three
mask self-tests. The plant numbers follow the prompt's list; plant `15` (the link text, a copied `before`, a tree pin typed wrong, the
anchor moved during a run) is the receipt's own gate, run on every start: the link's text, both tree pins and the anchor note are
printed on each run's first lines.

## What differed from the brief

The prompt's nineteen flagged contradictions, each with its pick and what the runs made of it:
- Flag 1 (an anchor change, decided): kept - springdoc `3.2.1` built offline from the seed, `0` downloads; nothing the probe recorded as unmoved moved.
- Flag 2 (`before` is `../c9-unit06/after`): kept - the link, its text exact; `before-tree` read off unit 06's `after-tree` line.
- Flag 3 (seven or eight kinds): kept and measured - (a) prints `7` kinds, `16` rows on this tree; (b), with the probe's filed generated source, prints BLUE's `8` and `17`, byte for byte BLUE's filed output.
- Flag 4 (the gloss): kept - no second gloss; the word is unit 06's, called back (`chk07.py gloss`).
- Flag 5 (PostgreSQL): kept - `after`, `diffpg` and the exercise's two trees on PostgreSQL `18.6`, equal to H2 on every printed fact.
- Flag 6 (no browser): kept - `20967` asserted free before every start; the page's addresses are status lines.
- Flag 7 (the document's duration-shaped word): kept - only in fences and code spans; dur9 `0` on this prose.
- Flag 8 (which old surface; R.511): kept - the by-count reader, its expected hash read off unit 04's `SURF=` line and unit 06's values block; the timed reader not copied (dropped first by the prompt's order, not said). The witness list is in item 7.
- Flag 9 (the test and the file): kept - no knob; the file written once from the running tree; `receipts.sh` only asserts it.
- Flag 10 (the exercise's solution): measured before it was written - `@NotNull` on the two numbers (no new dependency; the import was there) makes the served `required` four of four, the test fail until the file is written again, then pass, and moves no answer (the four omissions four hundred, the full one two-oh-one). `@Schema(requiredMode = REQUIRED)` was not built: `tiffinbox-core`'s POM names no swagger-annotations, so it moves a dependency, which the pick's criterion refuses by reading. An `OpenApiCustomizer` bean was not built (the first candidate passed).
- Flag 10, a measured difference: the refused "hand-edited file only" breaks clauses `1` and `2`, not `2` alone - the served document still requires two, so clause `1` fails first. `check.sh` names every clause it breaks.
- Flag 11 (the handler counts): kept - `17` by the anchored grep at five commits and the tree, unit 07 adds `0`; springdoc's rows are `4`, named.
- Flag 12 (which Jackson): kept - read off the constant pools; the wire's mapper is Jackson 3's `JsonMapper`.
- Flag 13 (the advisories): kept - today's filed read, not read again (no network).
- Flag 14 (`TIFFINBOX_MODULES`): kept - the parent's `<modules>` list as unit 06 left it (`chk07.py static`, the witness); the rows are carried to *Code Generation From the Contract*.
- Flag 15 (the frozen receipts' anchor checks): run - the grep's hits are in "For RED".
- Flag 16 (the hook and the exercise, R.513): kept - both extracted from S2B's Unit 07 section at run time; `gates9b.py` not copied.
- Flag 17 (the census writes rows): kept - `send` in its own JVM on a fresh database, `BLUE_RUN` = the run's number; one finding: its JSON Patch sets Ravi's meals to the value his seed row already holds, so the second client reads his row as it was (the answer and the row agree).
- Flag eighteen (nothing pending): kept - `0 0` at the start.
- Flag nineteen (FACTORY-NEXT): two lines appended at its end, nothing else.
- Not in the brief: a start that joins the harness documents the harness's routes too, so every document a claim reads comes from a start without it; and `DashboardPage`'s handlers share a method and a path with two of `TiffinBoxServer`'s, so the census matches handlers to operations by tag as well.

## For RED

- Seven kinds or eight: this tree's census prints seven kinds; the eighth (the generated client cannot send `application/json-patch+json`)
  exists only with the probe's filed generated source, U10's tool's output - *Code Generation From the Contract* re-measures it. BLUE's
  spine sentence `S07` ("the spec still parts from the wire in eight ways", `23` words in `gates9b.py`, not copied) is not gated or
  voiced from these receipts; the smallest passing wording is "seven ways, counted by a script on this tree".
- The gloss: none new. The brief's "what a client may rely on" reads as a paraphrase of unit 06's sentence; another sentence is the
  script writer's decision.
- The hook (`18` words) and the exercise (`19`), extracted from S2B's Unit 07 section at run time (the extracted lines' md5 is in
  `chk07.py spoken`'s output), through `s907.py`, dur9, the status gate, the spelling gate and the Hinglish list: `0` each. The hook's
  "meals are optional" is true of the two numbers, not of `mealType` or `name`.
- The exercise: measured before it was written (`@NotNull`, no dependency); the hand-edited file breaks two clauses, not one.
- The pin's comment: the parent POM line, the two versions not weighed, the measured surface, this unit's receipts, and the lesson that
  would move it; the word R.515 refuses alone is absent (`chk07.py static`).
- The committed file: `9851` bytes by `wc -c`, the voiced size; the socket's answer (it carries a port) is printed, never voiced.
- The seven and the old surface: equal to unit 06's on both trees; the R.511 witness is `GET /nowhere` alone.
- `diffpg`: every status, type and row equal to H2's - the census does not depend on the database on this tree.
- The advisories: today's filed read, not read again.
- `TIFFINBOX_MODULES`: no row here; carried to *Code Generation From the Contract*.
- Flag 15's grep (the five changed anchor paths and the README over `c9-unit01`-`06`'s receipts and harness, `C9/_builders/`, and the
  six tools): every hit is the anchor NOTE (`diff -rq … ../c9-tiffinbox`, non-fatal), an `*.mv.db` search, or unit 03's `setInstance`
  count over the anchor's `src/main` (which this change does not touch); no receipt or builder reads the anchor README's bytes (RED #37
  holds), and none `die`s on the live anchor.
- dur9: the harness copy's md5 equals `java9_series.DUR9_MD5` read off the registry, `C9/_builders/dur9.py`'s and units 01-06's copies.
- RED2 #5 / #8 / #24 / #32: the census is a script's over filed request and answer bodies; the test is code against the file, Docker-free;
  the file's size has no `servers`. #17: every number here is this unit's own, three runs. #25: "Open A-P-I" and "spring doc" pass the
  spelling gate, the bare words refuse in a spoken line. #29: Jackson 3 on both sides. #37: above.

## The ledger rows this unit pays

`TRACK-ROADMAP.md:377` ("why it is generated, not written"); `C9-10d`'s first half (the document's route answers now; the page is unit
08's half); `C9-11` (the seven and the old surface at this anchor change); `C9-13`'s data (no security scheme), for the lessons that follow.

## The values the video may say

The kinds and rows of (a), `required` two of four with its negation, `*/*` on twelve of thirteen, no error responses, the key header
named no times, thirteen operations from seventeen handlers, the committed file's bytes, forty-four plus one tests - each with its
capture, its run and its database, as the block below holds them.

<!-- values: begin -->
```
tests: tests=45 tests_u06=44 tests_k=1 its=14 it_entries=5 lib=146->157 new_jars=11
census: handlers=17 handlers_setup=12 handlers_u04=2 handlers_u05=2 handlers_u06=1 handlers_u07=0 operations=13 paths=11 absent=3 merged=1 springdoc_rows=4
after: openapi=3.1.0 info=OpenAPI_definition/v0 paths=11 operations=13 tags=6 schemas=Customer,SseEmitter required=2/4 socket_bytes_not_voiced=4357 spec_md5=0f5cbcb5 pg_equal=yes
diffpg: kinds_a=7 rows_a=16
exercise: exercise=broken-FAIL1,solved-PASS,refused-4-FAIL,bash+zsh,pg+h2
before: before=404/404/404 detector_on_before=FAIL
diff: kinds_b=8 rows_b=17 pg_equal=yes kinds_a=7 rows_a=16 required=2/4 star=12/13 errors_documented=0 key_named=0 witness=/nowhere
jackson: sc_j3=54 sc_j2=0 common_j3=47 common_j2=0
committed: spec_bytes=9851 spec_md5=0f5cbcb5 test=PASS drift_file=FAIL drift_code=FAIL
moved: asked=12 moved=3 unmoved=9 patch_customers=405:GET+POST
seven: seven=466c20ed
surface: surface=316a9637
inert: keyed=pause-key key_rows=0/1
static: xfam_s9s1_md5=1f5217a0 files_new=2 files_changed=3 spec_bytes=9851
gloss: gloss=U06s_called_back
spoken: hook_words=18 exercise_words=19
build: seed_files=11004 seed_bytes=876159996 central_only=0
```
<!-- values: end -->
