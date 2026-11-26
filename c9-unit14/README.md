# c9-unit14 — Sparse Fieldsets and Compression

Course 9 · Section 3 · unit 14. Course 9's eleventh anchor change, Section 3's second: TiffinBox gets a public customer list that answers
only the fields a client names. `before` is a link to `../c9-unit13/after` (pinned by `../c9-unit13/receipts.md5`'s `after-tree` line);
`after/` is a frozen copy of `../c9-tiffinbox` after this unit's change. Every number below is printed by `receipts.sh` on this unit's own
trees, the same in each run of record; the probe's and BLUE's numbers were the expectation, read and never voiced.

## Runs of record

Three runs, each launched below load1 `20` with the load printed on its first and last line, each ending
`c9-unit14: every capture = published (21)`, and `check_unit9.py 14 --runlog` on each run log (its unit gate exits `2` until the
script of unit 14 exists, as expected; the run-log line is the one read):

- run 1: bash `3.2.57`, `RUNNO=1 ./receipts.sh` in this folder.
- run 2: bash `5.3.9`, `RUNNO=2 bash receipts.sh` in this folder.
- run 3: bash `3.2.57`, `RUNNO=3 ./receipts.sh` in a sealed fresh clone of the commit, in a folder whose path holds a space (R.129).

As run (2026-11-26, on the committed script; each log's `check_unit9.py 14 --runlog` line: `RESULT (run logs): PASS`):

- run 1: bash `3.2.57`, load `3.19 3.80 3.65` at the start and `4.29 4.03 3.83` at the end.
- run 2: bash `5.3.9`, load `4.34 4.04 3.84` and `4.26 4.05 3.89`.
- run 3: the sealed clone (`file://` of the commit, a folder named `sealed clone`), bash `3.2.57`, load `3.82 3.96 3.86` and
  `4.02 4.13 3.99`.

Each ended `c9-unit14: every capture = published (21)`. Earlier attempts on the same tree stopped at their own checks and were fixed
before the runs above: an empty header printed as nothing instead of `none`, Tomcat's `%q` printing a dash after a path, and the full
capture's two requests sent in an order the shell did not fix. The README's runs section was written after the three runs; no hashed
capture reads it.

## RE-MEASURE (settled first)

- **1. `advisory`** — S9.36. The read filed for this batch (`docs-2026-11-26/advisories/`, fetched `2026-11-26` by the probe), its
  checksums verified, Spring's index rows naming Spring Framework `0` times, Tomcat's page the earlier read's, the t3 tree's pins (Spring
  Data JPA `4.1.3`, Hibernate `7.4.15.Final`, Tomcat `11.0.29`, Jackson `3.1.8` databind and core, the driver `42.7.14`, H2 `2.5.250`,
  HttpClient `5.6.5`, spring-web `7.0.11`), the OSV result the other witness only: no pin affected. This unit adds no artifact; the run's
  date is the read's date, so no network act.
- **2. `before`** — on U13's tree `GET /api/v1/customers` and `GET /api/v1/customers?fields=name` are not found (a four oh four), no
  request mapping is `/api/v1/customers`, the old `GET /customers` answers `282` bytes at the seed's four customers, the order list
  answers, and the committed spec holds its operations and paths as U13 left them (BLUE's counter, on `before`'s own file).
- **3. `change`** — the parent's modules three to three, the four poms equal, the derived changed list is `CustomerFields.java`,
  `CustomerFieldsTest.java`, the committed spec and the anchor's README; the whitelist is the `Customer` record's components in the
  record's order (`name`, `mealsPerDay`, `pricePerMeal`, `mealType`); `src/main` holds no `JsonView`, `MappingJacksonValue`, `Pageable`,
  `offset(` or probe name in code; `application.yaml` holds no compression key, before or after; the handler `customerFields` is unique.
- **4. `full` and `fields`** — H2, the seed's four customers, the flag off: the full list `282` bytes, the same bytes as the old
  `/customers`; `?fields=name,mealType` `142`; `?fields=name` `68`; `?fields=pricePerMeal` one member. `?fields=mealType,name` answers
  the same `142` bytes as `?fields=name,mealType`: the members come in the record's order, not the request's (the pick, handed to RED).
  Every answer carries a `Content-Length` equal to curl's bytes, no `Content-Encoding`, no `Vary`; Tomcat's access log agrees.
- **5. `refuse`** — eleven refusals, each a four hundred `application/problem+json` with its own `type` and `instance` the path:
  `field-unknown` (`fields=nickname`, `fields=name,nickname`, `fields=Name` - case is a different name -, `fields=%20name` - a leading
  space is kept and refused), the detail naming the four fields; `parameter-unknown` (`colour=red`, `size=5` - this route reads no
  `size` -, `fields[]=name` - a parameter named `fields[]`); `fields-invalid` (`fields=` empty, `fields=name,` a trailing comma,
  `fields=name,name` a name twice, `fields=name&fields=mealType` the parameter twice). One four hundred has no `type`: `fields=%zz`, a
  malformed escape that Tomcat's parameter decoding refuses before the route runs (Boot's `/error` body, `application/json`) - not the
  route's, named.
- **6. `view` and `mjv`** — on a harness-joined start: the harness's `@JsonView` route answers the same `142` bytes as the shipped
  route's `?fields=name,mealType`, byte for byte, and `282` without the view. The harness's `MappingJacksonValue` route answers five
  hundred, Boot's `/error` body, and the JVM's own log names `java.lang.UnsupportedOperationException: MappingJacksonValue is not
  supported, use hints instead`, thrown in Spring's Jackson converter (`AbstractJacksonHttpMessageConverter.canWrite`, spring-web
  `7.0.11`) with Jackson `3.1.8` on the class path. That five hundred is the failure receipt: on Jackson 3 the wrapper throws.
- **7. `floor`** — read back from Boot `4.1.3`'s own metadata (`spring-boot-web-server-4.1.3.jar`): five `server.compression` keys,
  `enabled` false by default, `min-response-size` `2KB`, `mime-types` eight entries counted one by one, `application/json` in the list,
  `application/hal+json` and `application/problem+json` not in it. With the run flag on and gzip asked, the old `/customers` and the new
  route at four customers each answer `282` bytes with a `Content-Length`, no `Content-Encoding`, no `Vary`.
- **8. `page`** — *Web Layer Performance*'s page re-measured on this pin, the flag on, four customers: `GET /dashboard` HTML `1022` bytes plain,
  `488` gzip asked, both `Transfer-Encoding: chunked` (no length), `gunzip` giving back the plain page byte for byte. *Web Layer Performance* measured
  `962` and `477` on its own pin; the page on this tree is longer, so these are this unit's numbers, and *Web Layer Performance*'s stay its own.
- **9. `grown`** — thirty `POST /customers` with *Web Layer Performance*'s body, each a two oh one, no key header: both list routes answer `2403`
  bytes plain (with `Vary: accept-encoding`, the flag on) and `229` bytes over the socket gzip asked; `gunzip` gives back the `2403`
  plain bytes; the plain md5 is *Web Layer Performance*'s, reproduced, on the old `/customers` and on the new route alike. Tomcat's access log prints
  `245` for the same gzip answers: curl's `229` is voiced, the gap is not explained.
- **10. `under`** — the same JVM, thirty-four customers, gzip asked: `?fields=name` `629` bytes and `?fields=name,mealType` `1213`
  bytes, each with a `Content-Length`, no `Content-Encoding`, no `Vary` - below the `2KB` floor read back. The full list gzipped (`229`)
  is smaller than either fieldset sent plain; the two savings do not stack at these sizes.
- **11. `clients`** — three factories on this class path (after/'s `lib/`, HttpClient `5.6.5` on it), each with its own `User-Agent`,
  against the grown `/customers`: `new HttpComponentsClientHttpRequestFactory()`, `RestClient.create()` (it picked HttpComponents
  here) and `new JdkClientHttpRequestFactory()`. Tomcat saw each ask for gzip and sent gzip; each client handed back the plain `2403`
  bytes, the plain md5, and exposed no `Content-Encoding` and no `Content-Length`. *Web Layer Performance*'s own access-log line for its JDK factory
  (`../c6-unit30/README.md`, printed with its line number) shows `gzip,deflate` asked and gzip sent: every Spring factory asked for gzip
  and unzipped by itself, on *Web Layer Performance*'s pin and on this one. The one difference is the factory `RestClient.create()` picks: the JDK
  factory on *Web Layer Performance*'s class path, which held no HttpClient 5 (its own print), HttpComponents here.
- **12. `yaml`** — the key put in `application.yaml` on a scratch copy of `after/`, the old surface sent with gzip asked to it and to
  `after/` with the flag off: three old answers move, each gaining `vary: accept-encoding` and a gzip body - `POST /customers`,
  `GET /dashboard` HTML and `GET /customers/new`. The seven, under the key, keep their hash. So the switch stays a run flag.
- **13. `spec`** — the committed file regenerated in this commit is the served document with `servers` removed, byte for byte; against
  `before`'s it adds lines and removes none (one path, `/api/v1/customers`; no other path and no component moved); operations and paths
  each grow by one (BLUE's counter); the old operations' ids equal before and after; the ids unique. Spec against wire for the new
  route: `200` `application/json`, an array of `Customer`, the full answer's members the schema's four; `400`
  `application/problem+json`. The gap, named: the `Customer` schema lists `name` and `mealType` as required, and `?fields=mealsPerDay`
  answers objects without them - the description says the members vary, the schema does not. `OpenApiSpecTest` passes on the
  regenerated file. The client built on it: the same twelve files, `ApiApi` gains `customerFields` (lines added only), every other
  generated file differs only by the generator's `@Generated` date line.
- **14. `moved`** — U13's requests, the order list and the new route on `before` and `after/`: no line moved but the two this unit adds -
  `GET /api/v1/customers` (not found, then two hundred: the added route, not a move) and `GET /v3/api-docs.yaml` (the document lists the
  added path, named under S9.37). The web jar gains `CustomerFields.class` and nothing else; no shared entry's CRC moves; the core jar is
  unchanged; `BOOT-INF/lib` keeps its names.
- **15. the seven and the old surface** — the expected hashes (read off `c7-unit31` and `c9-unit04`'s receipts) on both trees, byte for
  byte, and the planted surface (problem details off, 21034) moves it: the check can fail. Neither is a witness for the new route: they
  send nothing to `/api/v1/customers` (R.511). The witnesses for the new route are `full`, `fields`, `refuse` and `spec`.
- **16. `tests`** — `mvn package` on the whole reactor: web `62` (`57` at unit 13, and `5` new), client `1`, `0` skipped;
  `CustomerFieldsTest` `5`, `OrderPagesTest` `5`, `ApiVersionTest` `2`, `TiffinBoxRestDocsTest` `1`, `OpenApiSpecTest` `1`,
  `TiffinBoxWebTest` as before with its file unedited: the slice already mocks `CustomerRepository`, the one bean the new controller
  takes, so the measured need is none. The Docker-free build and the web-only form print the same counts. `mvn verify`: Surefire's
  tests on H2 in memory, then the five ITs on PostgreSQL `18.6` (and Redis, MongoDB, Elasticsearch) in their containers, green, five
  bindings, every one on `127.0.0.1`, nothing pulled.
- **17. `exercise`** — on the broken copy (the projection removed) the route the exercise names answers `fields=name` and
  `fields=nickname` each with the whole list, `282` bytes, two hundred: `fields` is read and ignored there. The solution restores the
  whitelist projection; `check.sh` passes only then, under bash and `zsh -f`.

## The change, file by file, and every README/Javadoc sentence it rewrote or noted (R.250/R.453)

- NEW `tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerFields.java` — the route (whole in the `change` capture).
- NEW `tiffinbox-web/src/test/java/com/tiffinbox/web/CustomerFieldsTest.java` — five MockMvc tests.
- REGENERATED `tiffinbox-web/src/test/resources/openapi/tiffinbox.json` — one new path.
- `c9-tiffinbox/README.md` — the unit 14 card, and a *Course 9, unit 14* note under unit 13's: the unit 13 card's "Not fixed here: the
  fields of the answer and its size (unit 14)" was true at unit 13 and is noted, not rewritten. The stale-sentence hunt (`fields`,
  `fieldset`, `compression`, `gzip`, `2 KB`, `floor`, `282`, `2403`, `/api/v1/customers`, `57`, `operations`, `22908`, `157`): the unit
  13 card's `57` and its operation count are unit 13's (history, kept); the earlier sections' compression lines are *Web Layer Performance*'s run flag
  (kept, still true: no compression key in `application.yaml`); no card said a list route under `/api/v1/customers` existed.
- Untouched and asserted byte-equal by `chk14.py static`: every pom, `OrderPages`, `CustomerReads`, `TiffinBoxApiVersioning`,
  `IdempotencyKeyFilter`, `TiffinBoxErrors`, `TiffinBoxOpenApi`, the slice test, `ApiVersionTest`, `TiffinBoxRestDocsTest`,
  `OpenApiSpecTest`, `OrderPagesTest`, both Flyway ITs, V6, `application.yaml`, `TiffinBoxProperties`, `Dockerfile`, `compose.yaml`.

## Which tree, which profile

`before` is U13's `after`: Spring Boot `4.1.3`, Framework `7.0.11`, Tomcat `11.0.29`, Jackson `3.1.8`, HttpClient `5.6.5`, H2
`2.5.250`. `after/` adds this unit's change. Every JVM runs the default profile with H2 in memory, fresh per JVM; PostgreSQL appears only
in `mvn verify`, in the ITs' own containers. Every capture above was answered by H2.

## Unit 14's section

With thirty-four customers, gzip shrinks TiffinBox's list. Ask for their names only, and the answer slips under the size where gzip starts: it does nothing.

That hook is said of this route's JSON answers, which carry a `Content-Length` (the `under` capture prints it): at thirty-four
customers the full list goes from `2403` to `229` bytes gzip asked (`grown`), and `?fields=name` stays `629` bytes, sent plain, under the
`2KB` floor read back from Boot's metadata (`floor`). Nothing here is said of an answer sent chunked: *Web Layer Performance*'s page is chunked and was
compressed below that floor (`page`), and why is not measured here. The failure receipt is the harness's `MappingJacksonValue` route:
five hundred on Jackson 3 (`mjv`).

A sparse fieldset: only the fields asked for.

The hazards, each with its capture: the wrapper throws on Jackson 3 (`mjv`); the floor and the eight listed types decide what the switch
compresses, and `problem+json` is not among them (`floor`); the switch in `application.yaml` moves three old answers (`yaml`); a client's
bytes are the plain ones whatever the wire carried (`clients`); a handler named like an old one would renumber an `operationId`, so this
one is named `customerFields` and the old ids are equal (`spec`).

Title for search (read off the brief, not edited here): "Sparse Fieldsets in Spring Boot: @JsonView, Fields, gzip".

## The captures — what each one shows

Each capture is `.r-NAME.out` on the author's disk (ignored by git) and hashed into `receipts.md5`; lines starting `~` (the S9.14 plant's
hash, the exercise's refused variants of run 1) are left out of the hash and said only with their run.

### advisory, before, change
As items 1-3 above. `change` prints `CustomerFields.java` and `CustomerFieldsTest.java` whole - the code panel.

### full, fields, refuse, view, mjv, floor, page, grown, under
The byte table, H2, curl's bytes (each equal to the saved file's), gzip asked where said:

```
                                     plain       gzip asked   Content-Length  Content-Encoding  Vary
4 customers, flag off
  GET /api/v1/customers              282         -            yes             -                 -
  ?fields=name,mealType              142         -            yes             -                 -
  ?fields=name                       68          -            yes             -                 -
4 customers, flag on
  GET /api/v1/customers, /customers  282         282          yes             none              none
  GET /dashboard (HTML)              1022        488          no (chunked)    gzip              accept-encoding
34 customers, flag on
  GET /customers, /api/v1/customers  2403        229          plain yes       gzip              accept-encoding
  ?fields=name                       629         629          yes             none              none
  ?fields=name,mealType              1213        1213         yes             none              none
```

The metadata read: `server.compression.additional-mime-types`, `enabled` (`false`), `excluded-user-agents`, `mime-types` (eight:
`text/html`, `text/xml`, `text/plain`, `text/css`, `text/javascript`, `application/javascript`, `application/json`,
`application/xml`), `min-response-size` (`2KB`). The `mjv` stack line is printed from the run's own log.

### clients
```
factory                                        Accept-Encoding Tomcat saw   bytes handed back   User-Agent
HttpComponentsClientHttpRequestFactory (new)   gzip, deflate, x-gzip        2403 (plain md5)    Apache-HttpClient/5.6.5 (Java/25.0.4.1)
RestClient.create() -> HttpComponents          gzip, deflate, x-gzip        2403 (plain md5)    Apache-HttpClient/5.6.5 (Java/25.0.4.1)
JdkClientHttpRequestFactory (new)              gzip,deflate                 2403 (plain md5)    Java-http-client/25.0.4.1
Web Layer Performance, its README, JDK:      GET /customers HTTP/1.1 200 upgrade:h2c accept-encoding:gzip,deflate content-encoding:gzip
```
The capture prints each line as Tomcat's access log wrote it; this table is read off it.

### yaml, spec, moved, seven, surface, inert, tests, exercise
As items 12-17. `inert`: no request of this unit carries the key header; the thirty POSTs go through the old public `POST /customers`.

## Measured, not shipped

The harness's `@JsonView` route and its `MappingJacksonValue` route (`/probe/u14/fields/view`, `noview`, `mjv`) and the harness's
client `Gzip14` live in `harness/src/probe/u14/`, joined by `--spring.main.sources=probe.u14.U14Config` on a harness-joined start only
(21035), never in the jar, the module or `after/`. The compression key in `application.yaml` and the exercise's variants are scratch
copies under `.harness/`.

## Refused, named

The refused readings are the XU14 families of `harness/s914.py` (and the carried base), each planted and refused in its self-test; this
README states none of them, and the gate runs over it, the exercise's two files and the spoken lines in every run.

## The repository, and the network

This unit adds no artifact: every build is `mvn -o` from a copy of `m2-seed-c9-s3` (`11,238` files, `888,071,893` bytes, `0` naming
`central-only`), `Downloading from` `0` in every log. The S9.36 read that cleared it is the probe's of `2026-11-26` (12:33 CET); nothing
else was read, and no network act was made but the final `git push`.

## The folders, the harness and the ports

`README.md after before exercise harness receipts.md5 receipts.sh`; `harness/`: `chk14.py` (the checker), `dur9.py` (as shipped,
= `java9_series.DUR9_MD5`), `ops9s3.py` (BLUE's counter, byte for byte), `s914.py` (U13's `s913.py` with XU14 for XU13; its XFAM_S9S1
slice asserted equal), `tree14.py` (tree13's code), and `src/probe/u14/` (`U14Config`, `U14Fields` - the probe's `ProbeFields` with a
named diff, its own `/api/v1/customers` route left out -, `Gzip14` - the probe's `Gzip.java` with its `User-Agent` override removed,
a named diff). Not carried: `walk.py`, `seal9.py`, `cdp.mjs`, `cdp9.mjs`, `loc9.py`, `specwire9.py`, U12's and U13's harness classes,
`Caller.java`. Ports: `21030` after/ on H2, `21033` the scratch copy's JVMs, `21034` the S9.14 plant, `21035` harness-joined starts,
`21036` before, `21038` the exercise; `21031`, `21032`, `21037` and `21039` never bound; `21280`-`21284` only during `verify`.

## Masks, filters and hygiene

One self-tested mask: the run-time figures of a Started line and of the log, every ISO time (Boot's `/error` `timestamp` included), the
folders, the home; the order list's cursor masked in `moved`; `Date`, the session cookie and ports masked in the surface. Compressed
bodies are compared by their `gunzip` output and their size. Every JVM is stopped by `POST /shutdown` or by its recorded pid; every
container `rm -fv`; images and volumes equal at the end.

## Interrupted

No SIGINT point was driven in this unit's runs (as unit 13: "not done", said here).

## Planted faults — each caught

`harness/chk14.py plants` runs at the end of every run: each planted fault is a copy of this run's capture with a single change (the
list is in `chk14.py`, `plants()`), and each ends with its FAIL line, exit `1`, no traceback. The S9.14 surface plant runs for real on
21034. Static plants (a fully-qualified `@EnabledIf...`, a compression key, a whitelist missing a name) are checked by `chk14.py static`.

## What differed from the brief

- C1: no contrast with *Web Layer Performance*'s pin; *Web Layer Performance*'s JDK-factory line is printed beside this unit's, both asking gzip.
- C2: the hook is scoped to answers that carry a `Content-Length`; the page's compression below the floor is shown, its reason not said.
  The optional chunked harness control was not captured: not said.
- C3: the floor read off Boot `4.1.3`'s own jar; *Web Layer Performance*'s read stays its own.
- C4: handler `customerFields`, unique; the old ids equal.
- C5: the shipped route is the map projection; `@JsonView` and `MappingJacksonValue` are the harness's only.
- C6: ports as the writer's extension; no PostgreSQL leg, so `21031` and `21032` stay unbound.
- C7: the run's date is the read's: the probe's read stands.
- C8: title `56` characters, printed, not edited.
- C9: one class `CustomerFieldsTest`, five methods; web `57` to `62`; the slice needed no edit (measured). The tests share one
  application context with classes that add customers, so each test checks the seed's four at the head of the list and every element's
  members, never the list's length (a first draft asserting the whole body failed on the shared rows, and was fixed before any run).
- C10: the client's files classified per file: date line only, lines added only (`ApiApi`), none moved.
- C11: `grown` on both routes; the plain bodies equal, *Web Layer Performance*'s md5 reproduced on both.
- C12: curl's `229` voiced, Tomcat's `245` printed beside it; no `curl --raw` capture.
- C13: the page re-measured: `1022` to `488` on this tree, chunked both ways; *Web Layer Performance*'s `962` to `477` called back as *Web Layer Performance*'s.
- C14: the call-back's live title, *Web Layer Performance*, read off the registry (`java6_series.py`) and asserted.
- The odd forms: empty, trailing comma, a name twice and the parameter twice refused `fields-invalid`; case and a leading space
  `field-unknown`; `fields[]` `parameter-unknown`; a malformed escape refused by Tomcat with no `type` (not the route's). Framework's
  binding of a repeated `fields` was not measured: the route reads the parameter's values itself and refuses two.
- The `yaml` count: `3` old answers, with gzip asked on both sides (so each also gained a gzip body).
- Dropped, "not captured, not said": `fields-pg`, the chunked control, `curl --raw`, SIGINT points. The exercise's refused variants run in
  run 1 only (`typed200`, `404`, `dropunknown`, `rawmap`, `fixedelsewhere`), each failing `check.sh` on its own clause.

## For RED

- The member-order pick (the record's order, whatever the request's); the refusal forms above; the `fields=%zz` answer (Tomcat's).
- The annotation pick: the `200` answer is an array of `Customer` with `name` and `mealType` required, and a fieldset answer can lack them - the
  gap is named, not fixed.
- The two named moves: `GET /api/v1/customers` added; `GET /v3/api-docs.yaml` moved by the new path (S9.37).
- The client's regenerated files differ only in the `@Generated` date line but `ApiApi`, which gains lines - never "the client moved".
- The page: chunked HTML compressed below the `2KB` floor; the hook must stay scoped to answers that carry a length.
- Frozen receipts (flag 22): earlier receipts read their own frozen `after/`; unit 03's `instance` view greps the live `src/main` and now
  finds one more `ProblemDetail.forStatus...` call, in `CustomerFields` (a print, not a stop).

## The ledger rows this unit pays

`TRACK-ROADMAP.md:386` (payload sizes measured before and after); C9-6's *Sparse Fieldsets and Compression* half (`282`, `2403` to `229`
re-measured, the page re-measured with its framing, *Web Layer Performance*'s "2403, plain" called back as what its JDK factory handed back after asking
`gzip,deflate`); C9-11 (the seven, the old surface and the spec's old operations at this anchor change). C9-6's other halves are units
12, 21 and 25's. The ledger is not edited here.

## The values the video may say

Each with its capture, H2: the full list `282`, names and meal types `142`, names `68` bytes (`full`, `fields`); at thirty-four
customers `2403` plain and `229` gzipped, names only `629` and `1213` with no encoding (`grown`, `under`); the floor `2KB` and eight
types (`floor`); three old answers moved by the key in the yaml (`yaml`); web `57` to `62` (`tests`).

<!-- values: begin -->
```
advisory: adv_rows=25
before: before_mappings=29
change: changed=4 jsonview_jar=jackson-annotations-2.21.jar
full: full=282
fields: fields=142/68
refuse: notype=fields=%zz log_exceptions=2 refusals=11 types=field-unknown,fields-invalid,parameter-unknown
view: view=142 noview=282
mjv: thrower=AbstractJacksonHttpMessageConverter
floor: floor=2KB mime_types=8
page: page=1022->488 page_framing=chunked/chunked page_md5=1073b51d
grown: grown=2403->229 c6_md5=equal pct_b=245
under: under=629/1213
clients: ae=gzip,deflate,x-gzip;gzip,deflate,x-gzip;gzip,deflate
yaml: yaml_moved=3 yaml_answers=POST_/customers_(JSON,_a_fresh_name);_GET_/dashboard_(Accept:_text/html);_GET_/customers/new yaml_gzip=3 yaml_seven=equal
spec: ops=14->15 paths=12->13 spec_added=44 required=['mealType','name'] client_files=12->12 client_kinds=dateonly=11,linesadded=1,new=0 spec_md5=b5ec509e spec_bytes=24250
moved: moved=0 named=1
seven: seven=466c20ed
surface: surface=316a9637
tests: web_tests=62 web_before=57 k=5 its=14
exercise: ex_broken=200/282 ex_broken_unknown=200
inert: 
plants: plants=31
build: seed_files=11238 seed_bytes=888071893 central_only=0
```
<!-- values: end -->
