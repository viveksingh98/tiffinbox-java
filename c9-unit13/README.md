# c9-unit13 — Pagination, Filtering and Sorting as an API Concern

Course 9 · Section 3 · unit 13. Course 9's tenth anchor change, Section 3's first: TiffinBox gets an order list and a public route that
pages it. `before` is a link to `../c9-unit12/after` (pinned by `../c9-unit12/receipts.md5`'s `after-tree` line); `after/` is a frozen
copy of `../c9-tiffinbox` after this unit's change. Every number below is printed by `receipts.sh` on this unit's own trees, the same in
each run of record; the probe's and BLUE's numbers were the expectation, read and never voiced.

## Runs of record

Three runs, each launched below load1 `20` with the load printed on its first and last line, each ending
`c9-unit13: every capture = published (18)`, and `check_unit9.py 13 --runlog` on each run log (its unit gate exits `2` until the
script of unit 13 exists, as expected; the run-log line is the one read):

- run 1: bash `3.2.57`, `RUNNO=1 ./receipts.sh` in this folder.
- run 2: bash `5.3.9`, `RUNNO=2 bash receipts.sh` in this folder.
- run 3: bash `3.2.57`, `RUNNO=3 ./receipts.sh` in a sealed fresh clone of the commit, in a folder whose path holds a space (R.129).

As run (2026-11-26, on the committed script; each log's `check_unit9.py 13 --runlog` line: `RESULT (run logs): PASS`):

- run 1: bash `3.2.57`, load `3.12 3.77 4.43` at the start and `4.03 3.90 4.19` at the end; the tie orders `3` over `3` on H2, `1` over
  `3` on PostgreSQL.
- run 2: bash `5.3.9`, load `4.03 3.90 4.19` and `3.94 3.89 4.02`; `3` over `3`, `1` over `3`.
- run 3: the sealed clone (`file://` of the commit, a folder named `sealed clone`), bash `3.2.57`, load `3.08 4.42 5.02` and
  `3.27 3.83 4.47`; `2` over `3` on H2, `1` over `3` on PostgreSQL.

Each ended `c9-unit13: every capture = published (18)`. An earlier attempt of each, on the same tree, stopped at its own check and was
fixed before the runs above: the new route's body hashed with its key-bound cursor in `moved` (now masked), and the pom check scoped to
`c9-tiffinbox` (a clone holds `after/`'s poms as tracked files). The README's runs section was written after the three runs; no hashed
capture reads it.

## RE-MEASURE (settled first)

- **1. `advisory`** — S9.36. The read filed for this batch (`docs-2026-11-26/advisories/`, fetched `2026-11-26` by the probe), its
  checksums verified, Spring's index rows naming Spring Framework `0` times, Tomcat's page the earlier read's, the t3 tree's pins
  (Spring Data JPA `4.1.3`, Hibernate `7.4.15.Final`, Tomcat `11.0.29`, Jackson `3.1.8`, the driver `42.7.14`, H2 `2.5.250`), the OSV
  result the other witness only: no pin affected. This unit adds no artifact; the run's date is the read's date, so no network act.
- **2. `before`** — on U12's tree `GET /api/v1/orders` and `GET /orders` are not found (a four oh four from the static handler), the
  Flyway history is V1-V5, no request mapping names an order list, and `/kitchen`'s `ordersCooked` and `ordersValue` are the in-JVM
  counters of `OrderQueue`, not a list. `KitchenOrder` and `OrderDocument` are the "dev" profile's only (Redis, MongoDB), not run.
- **3. `change`** — the parent's modules three to three, no pom moved, the derived changed list is the flag-2 set plus the anchor's README;
  `TiffinBoxApp`'s `@EntityScan("com.tiffinbox")` and `@EnableJpaRepositories("com.tiffinbox")` find the entity and the repository with
  no edit; `src/main` holds no `offset(`, `Pageable` or `PageRequest` in code (the repository's Javadoc names two of them, said as what it
  does not offer); the handler `orderPage` is unique; the web jar carries `spring-data-jpa-4.1.3.jar`.
- **4. `table`** — V6 applied by Flyway to a clean H2 and a clean PostgreSQL `18.6` database: the history V1-V6 on both, the same list;
  `20` rows, ten `placed_at` values, two rows each (read through the route on H2, by `psql` on PostgreSQL). A column named `value` stops
  V6 on H2 (`org.h2.jdbc.JdbcSQLSyntaxErrorException`, the harness's scratch copy): the column is `amount`.
- **5. `first`** — page one newest first, `size=5`: `200`, `application/json`, the members `items` and `next`, the ids
  `[19, 20, 17, 18, 15]`, a next cursor, on H2 and on PostgreSQL. The SQL on both:
  `... order by oe1_0.placed_at desc,oe1_0.id fetch first ? rows only` - the id is in the ORDER BY, ascending under a descending sort,
  so the two orders that share a `placed_at` come back id ascending. That direction is this unit's measurement.
- **6. `next`** — the cursor decoded once: `{"s":"newest","f":null,"k":[["id","L","15"],["placedAt","I","<time>"]]}`, then a dot and its
  signature (masked); no filter is JSON `null`; its length `158` on both databases. Page two through it: `[16, 13, 14, 11, 12]`, the SQL
  `... where oe1_0.placed_at<? or oe1_0.placed_at=? and oe1_0.id>? order by oe1_0.placed_at desc,oe1_0.id ...` on both.
- **7. `refuse`** — fourteen refusals, each a four hundred `application/problem+json` with its own `type`, the same body on H2 and
  PostgreSQL: `cursor-invalid` (one payload character changed with the signature kept; `notacursor`; a truncated cursor);
  `cursor-mismatch` (reused with `sort=oldest`, the detail naming `sort`; with `mealType=VEG`, the detail naming `mealType` - the two
  bodies differ; with `mealType=null`, the string, against a cursor written with no filter - refused, naming `mealType`);
  `sort-unknown` (`sort=nosuch`, the detail naming the four sorts); `parameter-unknown` (`colour=red`, `customer=Ravi`, the detail naming
  the four parameters the route reads); `filter-unknown` (`mealType=PIZZA`, and `mealType=null` with no cursor, the detail naming the
  three meal types); `size-invalid` (`size=0`, `size=-1`, `size=51`). `size=abc` never reaches the route: Framework's own conversion
  refuses it (a four hundred with no `type` member). `size=50` answers all `20` orders.
- **8. `pageable`** — the loser, the harness's Pageable route (Spring Data's own web support): `sort=nosuch` answers five hundred, Boot's
  `/error` body, the JVM's log naming `PropertyReferenceException: No property 'nosuch' found for type 'OrderEntity'`, on both databases.
  `sort=amount,desc&size=5` (the five orders of amount `300` tie): the SQL `... order by oe1_0.amount desc offset ? rows fetch first ?
  rows only` - no id in its ORDER BY - and the five tied ids counted over fresh starts: three different orders over three fresh H2 JVMs
  and one order over three fresh PostgreSQL databases in run 1 (each run's count is in its log; the values block says each run's).
- **9. `walk`** — four walks on each database, each a fresh JVM and database, pages of `5`, the harness's insert of `2` rows between page
  one and page two:

  | walk | duplicates | skips (of the `20` rows there at the start) | new rows seen |
  | --- | --- | --- | --- |
  | newest first, the harness's offset route | `2` | `0` | `0` |
  | newest first, the cursor | `0` | `0` | `0` |
  | oldest first, the harness's offset route | `0` | `0` | `2` |
  | oldest first, the cursor | `0` | `0` | `2` |

  Identical on H2 and PostgreSQL. The failure receipt: newest first, the offset walk's page two begins with page one's last two ids
  (`[20, 19, 18, 17, 16]`, then `[17, 16, 15, 14, 13]`).
- **10. `trap`** — the offset-then-keyset trap of Course 7's *Paging and Sorting* (`java7_series.py`, its line 84), re-run on `4.1.3` on both databases: a scroll method asked `offset()` and then
  `keyset()` runs `order by oe1_0.amount` with no id both times; the same method asked `keyset()` alone in a JVM of its own runs
  `order by oe1_0.amount,oe1_0.id`; another method asked `keyset()` twice keeps the id both times; and a method asked `keyset()`, then
  `offset()`, then `keyset()` again loses the id on its third call. The shipped repository offers no offset read at all.
- **11. `restart`** — a cursor written by one start and sent to the next, each with its own random key: refused, `cursor-invalid`, on both
  databases; the same pair of starts with the same explicit key (`tiffinbox.cursor-key`, a generated file, never printed) accepts it
  and answers page two. The key itself is in no log.
- **12. `spec`** — the committed file regenerated in this commit is the served document with `servers` removed, byte for byte; against
  `0248b1c`'s it adds `108` lines and removes none (one path, `/api/v1/orders`, and the schemas `OrderPage` and `OrderView`); operations
  `13` to `14`, paths `11` to `12` (BLUE's counter); the old operations' ids equal before and after; the ids unique. Spec against wire
  for the new route: `200` `application/json` with the schema's two properties `items` and `next`, `400` `application/problem+json`, on
  the wire as in the document - the route is annotated, so no gap is left to name. `OpenApiSpecTest` passes on the regenerated file.
  The client built on it: `.openapi-generator/FILES` lists `10` to `12` Java files (`OrderPage`, `OrderView` new), `ApiApi` holds
  `orderPage`; every other generated file differs only by the generator's `@Generated` date line.
- **13. `moved`** — U12's requests and the new route on `before` and `after/`: no line moved but the two this unit adds - `GET /api/v1/orders`
  (not found, then two hundred: the added route, not a move) and `GET /v3/api-docs.yaml` (the document lists the added path, named
  under S9.37). The web jar gains `OrderPages` and its two records, the core jar `OrderEntity`, `OrderEntityRepository` and V6; no
  shared entry's CRC moves but the web jar's copy of the core jar; `BOOT-INF/lib` `157` names, unmoved.
- **14. the seven and the old surface** — the expected hashes (read off `c7-unit31` and `c9-unit04`'s receipts) on both trees, byte for byte, and the planted surface (problem
  details off, 21024) moves it: the check can fail. Neither is a witness for the new route: they send nothing to `/api/v1/orders`
  (R.511). The witnesses for the new route are `first`, `next`, `refuse` and `walk`; for the old routes, `moved`.
- **15. `tests`** — `mvn package` on the whole reactor: web `57` (`52` at unit 12, and `5` new), client `1`, `0` skipped;
  `OrderPagesTest` `5`, `ApiVersionTest` `2`, `TiffinBoxRestDocsTest` `1`, `OpenApiSpecTest` `1`, `TiffinBoxWebTest` `15` as before;
  the Docker-free build and the web-only form print the same counts. `mvn verify`: Surefire's tests on H2 in memory, then the five ITs
  on PostgreSQL `18.6` (and Redis, MongoDB, Elasticsearch) in their containers, `14` tests green, both Flyway ITs printing V1-V6, five
  bindings, every one on `127.0.0.1`. The two measured needs, each on a scratch copy: without the slice's mock the slice does not start
  (`15` errors, "required a bean of type 'com.tiffinbox.OrderEntityRepository'"); without the two IT lines both Flyway ITs fail.
- **16. `exercise`** — on the broken copy (the whitelist check removed) the cursor route answers `sort=nosuch` with a five hundred
  (`application/json`, Boot's `/error` body, an exception in the JVM's log), and a cursor reused under another sort is still refused
  (`cursor-mismatch`): the binding survives the break. The solution restores the whitelist; `check.sh` passes only then, under bash
  and `zsh -f`.

## The change, file by file, and every README/Javadoc sentence it rewrote or noted (R.250/R.453)

- NEW `tiffinbox-core/src/main/resources/db/migration/V6__tiffin_order.sql` — the table and its `20` seeded orders, one file for both
  databases.
- NEW `tiffinbox-core/src/main/java/com/tiffinbox/OrderEntity.java`, `OrderEntityRepository.java` — the row; two keyset reads on a plain
  `Repository`.
- NEW `tiffinbox-web/src/main/java/com/tiffinbox/web/OrderPages.java` — the route (whole in the `change` capture).
- NEW `tiffinbox-web/src/test/java/com/tiffinbox/web/OrderPagesTest.java` — five MockMvc tests.
- EDITED (BLUE's four): `TiffinBoxWebTest.java` (one `@MockitoBean` line and its comment), the committed `tiffinbox.json` (regenerated),
  `CustomerEntityRepositoryIT.java` and `jdbc/CustomerAggregatesIT.java` (one comment line and one list element each).
- `c9-tiffinbox/README.md` — the unit 13 card, and a *Course 9, unit 13* note under unit 12's: the unit 04 note's "five migrations
  (V1-V5)" was true at unit 04 and is noted, not rewritten; the opening paragraph's history stays. The stale-sentence hunt (`order`,
  `cursor`, `V1-V5`, `52`, `157`, `20306`, `kitchen`, `OrderQueue`): the unit 12 card's `52` is unit 12's count (history, kept); the
  ITs' Javadoc "(Course 9, unit 04: V1-V5 ...)" is dated history, kept; `OrderQueue` and `/kitchen` are said to be the counters.
- Untouched and asserted byte-equal by `chk13.py static`: every pom, `TiffinBoxApiVersioning`, `IdempotencyKeyFilter`, `TiffinBoxErrors`,
  `TiffinBoxOpenApi`, `ApiVersionTest`, `TiffinBoxRestDocsTest`, `OpenApiSpecTest`, `application.yaml`, `TiffinBoxProperties`,
  `Dockerfile`, `compose.yaml`.

## Which tree, which profile

`before` is U12's `after`: Spring Boot `4.1.3`, Framework `7.0.11`, Spring Data JPA `4.1.3`, Hibernate `7.4.15.Final`, Tomcat
`11.0.29`, Jackson `3.1.8`, H2 `2.5.250`. `after/` adds this unit's change. Every JVM runs the default profile; H2 is in memory and
fresh per JVM; PostgreSQL is `postgres@sha256:77f58511...` (`18.6`), one container `c9u13-pg` on `127.0.0.1:21021`, a fresh database
per JVM. Every sentence above names the database that answered.

## Unit 13's section

Read TiffinBox's orders newest first, two pages of five. Two orders arrive between the pages, and page two repeats two orders you already read.

That hook is the harness's offset route, the loser; TiffinBox's own route is the cursor, and newest first the cursor repeats none of
the rows that were there and does not see the two new ones. The failure receipt is that offset walk (the `walk` capture); the server is
right, and offset is the wrong tool for an order list read newest first while orders arrive. Oldest first, offset and cursor both see
the two new rows at the end.

A cursor: where the next page starts, signed.

Opaque here means signed: the payload is readable, shown decoded once above, and the server refuses one it did not sign. The hazards,
each with its capture: a column named `value` on H2 (`table`); a new controller turns the slice red without its mock and a new migration
turns two Flyway ITs red (`tests`); a scroll method asked `offset()` first loses its tie-breaker for good (`trap`); a Pageable route has
no id in its order by, so the tied rows came back in more than one order (`pageable`). Nothing about a row deleted between two pages was
measured, and nothing is said about it.

Title for search (read off the brief, not edited here): "Spring Data Keyset Pagination: a Cursor API vs Offset".

## The captures — what each one shows

Each capture is `.r-NAME.out` on the author's disk (ignored by git) and hashed into `receipts.md5`; lines starting `~` (the per-start
tie orders, the exercise's refused variants of run 1) are left out of the hash and said only with their run.

### advisory, before, change, table
As items 1-4 above. `change` prints `V6__tiffin_order.sql`, `OrderEntityRepository.java`, `OrderPages.java` and `OrderPagesTest.java`
whole - the code panel.

### first, next
```
h2 | page one newest -> 200 application/json · keys ['items', 'next'] · ids [19, 20, 17, 18, 15] · next present
h2 | page one newest SQL | select oe1_0.id,oe1_0.amount,oe1_0.customer,oe1_0.meal_type,oe1_0.placed_at from tiffin_order oe1_0 order by oe1_0.placed_at desc,oe1_0.id fetch first ? rows only
h2 | decoded once | {"s":"newest","f":null,"k":[["id","L","15"],["placedAt","I","<time>"]]} . <signature masked> · length 158
h2 | page two -> 200 application/json · keys ['items', 'next'] · ids [16, 13, 14, 11, 12] · next present
h2 | page two SQL | select ... from tiffin_order oe1_0 where oe1_0.placed_at<? or oe1_0.placed_at=? and oe1_0.id>? order by oe1_0.placed_at desc,oe1_0.id fetch first ? rows only
```
PostgreSQL prints the same lines (`pg |`).

### refuse, pageable, walk, trap, restart
As items 7-11. The trap's SQL, on both databases:
```
B offset        ... where oe1_0.customer=? order by oe1_0.amount fetch first ? rows only
B keyset        ... where oe1_0.customer=? order by oe1_0.amount fetch first ? rows only
A keyset        ... where oe1_0.meal_type=? order by oe1_0.amount,oe1_0.id fetch first ? rows only
A keyset again  ... where oe1_0.meal_type=? order by oe1_0.amount,oe1_0.id fetch first ? rows only
C keyset        ... where oe1_0.customer<>? order by oe1_0.amount,oe1_0.id fetch first ? rows only
C offset        ... where oe1_0.customer<>? order by oe1_0.amount fetch first ? rows only
C keyset again  ... where oe1_0.customer<>? order by oe1_0.amount fetch first ? rows only
Aprime keyset   ... where oe1_0.customer=? order by oe1_0.amount,oe1_0.id fetch first ? rows only
```

### spec, moved, seven, surface, inert, tests, exercise
As items 12-16. `inert`: no request of this unit carries the key header; the harness's insert goes through the harness's own route.

## Measured, not shipped

The harness's insert (`POST /probe/u13/orders`), the harness's offset route (`/probe/u13/orders/by-page`, `placed_at` and id both
descending - RED #24), the harness's Pageable route (`/probe/u13/orders/pageable`), the trap (`/probe/u13/trap`) and their repository
`U13OrderRepository` live in `harness/src/probe/u13/`, joined by `--spring.main.sources=probe.u13.U13Config` on a harness-joined start
only (21025), never in the jar, the module or `after/`. The value copy, the two needs and the exercise's variants are scratch copies under
`.harness/`.

## Refused, named

The refused readings are the XU13 families of `harness/s913.py` (and the carried base), each planted and refused in its self-test; this
README states none of them, and the gate runs over it, the exercise's two files and the spoken lines in every run.

## The repository, and the network

This unit adds no artifact: every build is `mvn -o` from a copy of `m2-seed-c9-s3` (`11,238` files, `888,071,893` bytes, `0` naming
`central-only`), `Downloading from` `0` in every log. The S9.36 read that cleared it is the probe's of `2026-11-26` (12:33 CET); nothing
else was read, and no network act was made but the final `git push`.

## The folders, the harness and the ports

`README.md after before exercise harness receipts.md5 receipts.sh`; `harness/`: `chk13.py` (the checker), `dur9.py` (as shipped,
= `java9_series.DUR9_MD5`), `ops9s3.py` (BLUE's counter, byte for byte), `s913.py` (U12's `s912.py` with XU13 for XU12; its XFAM_S9S1
slice asserted equal), `tree13.py` (tree12's code), `walk.py` (the probe's, a named diff: the harness's routes, one walk per JVM), and
`src/probe/u13/` (six classes). Not carried: `seal9.py`, `cdp.mjs`, `cdp9.mjs`, `loc9.py`, `specwire9.py`, U12's mirrors and versioning
classes, `Caller.java`. Ports: `21020` after/ on H2, `21021` PostgreSQL, `21022` after/ on PostgreSQL, `21023` scratch and restart JVMs,
`21024` the S9.14 plant, `21025` harness-joined starts, `21026` before, `21028` the exercise; `21027` and `21029` never bound;
`21280`-`21284` only during `verify`.

## Masks, filters and hygiene

One self-tested mask: the run-time figures of a Started line and of the log, every ISO time (the `placedAt` values and the cursor's decoded
key included), the folders, the home; the cursor's own text is never hashed (it carries the start's key), only its decoded structure.
Every JVM is stopped by `POST /shutdown` or by its recorded pid; every container `rm -fv`; images and volumes equal at the end.

## Interrupted

No SIGINT point was driven in this unit's runs (dropped at the cap's drop order: "not done", said here).

## Planted faults — each caught

`harness/chk13.py plants` runs at the end of every run: each planted fault is a copy of this run's capture with a single change (the
list is in `chk13.py`, `plants()`), and each ends with its FAIL line, exit `1`, no traceback. The S9.14 surface plant runs for real on
21024. Static plants of the earlier units (another gloss line, a fully-qualified `@EnabledIf...`) are checked by `chk13.py static`.

## What differed from the brief

- C1: the id as Spring Data's tie-breaker is called back by title (*Capstone: TiffinBox on Postgres*); the direction (id ascending under a
  descending sort) is this unit's measurement, never that lesson's.
- C2: tie orders counted per fresh start, never per database.
- C3: the exercise measured on the cursor route itself: five hundred on the broken copy, the cursor still bound.
- C4: the route is annotated (`application/json` with `OrderPage`, `application/problem+json` with `ProblemDetail`); spec equals wire.
- C5: the payload carries `"f":null` (JSON null), length `158` (the probe's `160` was its string form).
- C6: ports as the writer's extension of S3B's five slots.
- C7: the run's date is the read's: the probe's read stands.
- C8: title `53` characters, printed, not edited.
- C9: one class `OrderPagesTest`, five methods (`k` = `5`); web `52` to `57`.
- C10: the harness's offset route labelled on every line; its tie direction (id descending) is its own Sort.
- The cursor key: `@Value("${tiffinbox.cursor-key:}")` read once in `OrderPages`, `32` `SecureRandom` bytes when unset; no
  `TiffinBoxProperties` edit. Refusals thrown as Framework's `ErrorResponseException` with the route's own `ProblemDetail`, answered by
  Boot's problem-details handler: no edit to `TiffinBoxErrors`.
- `size`: `1` to `50`, default `5`; `0`, negative and over `50` refused `size-invalid`; non-numeric left to Framework's conversion
  (four hundred, no `type`) - the route never sees it.
- The repository extends `Repository`, not `JpaRepository` (no inherited offset read). The harness reaches the table through its own
  `U13OrderRepository` (another `@EnableJpaRepositories`, the harness's, on harness-joined starts only).
- The changed list is derived from `diff -rq before after/` (stable across a clone); `git status --short` gave the same list before the
  commit.
- `verify` on H2 and PostgreSQL is one `mvn verify`: Surefire's tests on H2 in memory, the five ITs on PostgreSQL (and Redis, MongoDB,
  Elasticsearch) in their containers, as the anchor's pom runs them. The IT need is measured with the two Flyway ITs alone
  (`mvn package -Dtest=...`, the same containers).
- The Docker-free twin is `after/`'s own first build (the whole reactor with tests, `DOCKER_HOST` unset to a dead socket).
- Not done, said: SIGINT points. The exercise's refused variants run in run 1 only (`unboundcursor`, `rawsort`, `fixedelsewhere`,
  `typed404`), each failing `check.sh` on its own clause; `unboundcursor` (the sort refused, the cursor's binding removed) answers a
  newest cursor reused oldest first with the wrong rows (`[16, 17, 18, 19, 20]`), which is why clause 2 exists.
- `s913.py` carries U12's base and XFAM_S9S1 slice; U12's own `s912.py` held no XFAM_S9S2 slice to carry (it lives in the scripts
  stage's `C9/_builders/s912.py`).

## For RED

- The `size` pick (non-numeric answered by Framework, no `type`); the key's setting name; five test methods; the annotation pick.
- The two named moves: `GET /api/v1/orders` added; `GET /v3/api-docs.yaml` moved by the new path (S9.37).
- The client's regenerated files differ only in the `@Generated` date line - check the scripts never call that "the client moved".
- Frozen receipts (flag 22): a grep of `c9-unit01`-`c9-unit12`'s `receipts.sh` for the committed spec's md5, `flyway_schema_history`,
  `V1-V5`, `containsExactly`, `V6__` and `OrderPages` finds `0` lines - each earlier receipt reads its own frozen `after/`, so this
  commit moves none of their pins; their anchor check stays a note. Unit 03's `instance` view reads the live `src/main` and prints its
  `ProblemDetail.forStatus...` calls: `OrderPages.java` now adds one (a print, not a stop).
- `OrderPages` builds its problems with `ProblemDetail.forStatusAndDetail`; unit 03's `instance` view greps that call in the live
  `src/main` (a print, not a stop).
- The ledger: no row names this unit's refusals or the four test edits; BLUE's pointers `#223`-`#225` still open (orchestrator's note).

## The ledger rows this unit pays

`TRACK-ROADMAP.md:385` (cursor pagination for an order list that keeps growing); C9-5 (a web route that pages, on PostgreSQL, with the names of
Course 7's *Paging and Sorting* (`java7_series.py`, its line 84) in its code: `Window`, `ScrollPosition.keyset()`, `KeysetScrollPosition`); C9-3 (pagination has its unit); C9-11 (the seven,
the old surface and the spec's old operations at this anchor change). The ledger is not edited here.

## The values the video may say

Each with its capture, both databases unless said: page one `[19, 20, 17, 18, 15]` and page two `[16, 13, 14, 11, 12]` (`first`,
`next`); the cursor's length `158` (`next`); fourteen refusals in six problem types (`refuse`); the walks' `2` duplicates for the offset
route newest first and `0` for the cursor, `2` new rows seen oldest first by both (`walk`); the Pageable route's five hundred for an
unknown sort and no id in its order by (`pageable`); web `52` to `57`, `14` ITs (`tests`); operations `13` to `14` (`spec`).

<!-- values: begin -->
```
advisory: adv_rows=25
before: before_mappings=29
change: changed=10
table:
first: p1=19,20,17,18,15
next: cursor_len_h2=158 cursor_len_pg=158 p2=16,13,14,11,12
refuse: refusals=14 types=cursor-invalid,cursor-mismatch,sort-unknown,parameter-unknown,filter-unknown,size-invalid
spec: ops=13->14 paths=11->12 spec_added=108 client_files=10->12 spec_md5=fd608a6e
pageable: fresh_h2=3 fresh_pg=3
walk: walk=newest-offset=2/0/0 newest-cursor=0/0/0 oldest-offset=0/0/2 oldest-cursor=0/0/2
trap: trap=reproduced_both
restart:
moved: moved=0 named=1
seven: seven=466c20ed
surface: surface=316a9637
tests: web_tests=57 web_before=52 k=5 its=14 slice_errors=15
exercise: ex_broken=500
inert:
plants: plants=25
build: seed_files=11238 seed_bytes=888071893 central_only=0
```
<!-- values: end -->
