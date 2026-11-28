# Course 9 · Unit `23` — `Observability for APIs` (no anchor change)

```
Nine requests. The scrape names the route each one hit — and two of them sit under the pattern that catches every path.
```

That is the brief's hook, byte for byte, and it holds for the nine requests of the probe's sequence as this unit rebuilt them (D4):
of the nine, `7` are counted under a route template and `2` under `/**`, the pattern that catches every path (`known`). "The route each
one hit" is a template for the seven and the catch-all pattern for the two. The limiter's refusal and the `405` are outside the nine;
both carry `uri="UNKNOWN"` (`unknown`).

The RED method: rate, errors and duration.

Rate and errors are counts read off the scrape (`http_server_requests_seconds_count`, per route and status); the duration is the third
letter, named here and never voiced: its series names only (`duration`).

No anchor change. `c9-tiffinbox` is not touched by one byte; `before` and `after` are two links whose text is `../c9-unit22/after`
(unit `22`'s frozen tree, pinned by `../c9-unit22/receipts.md5`'s `after-tree` line). The unit reads what the shipped tree already
answers on `/actuator/prometheus` (exposed: `health,prometheus`): Spring Boot's `http.server.requests`, Micrometer
`1.17.3`, on the extracted jar of `before`, H2 only. No store, no container, no browser.

## Runs of record

Three runs, each launched below load1 `20` with the load printed on its first line, each ending `every capture = published (21)`,
and `check_unit9.py 23 --runlog` read on each run log (its unit gate exits `2` until this unit's script exists, as expected; the
run-log line is the one read):

- run 1: bash `3.2.57`, `RUNNO=1 ./receipts.sh` in this folder (the exercise's five refused variants run here only).
- run 2: bash `5.3.9`, `RUNNO=2 bash receipts.sh` in this folder.
- run 3: bash `3.2.57`, `RUNNO=3 ./receipts.sh` in a sealed clone of the repository in a folder whose path holds a space (R.129),
  cloned from the local repository at `d7e0663` with this unit's files laid over it, and the clone's own `c9-tiffinbox` folder moved
  aside for the whole run: the static check's run there is the third, with no anchor beside it.

The pins in `receipts.md5` were taken from a development run (`NOPIN=1`) of this same script before run 1; the three runs then had to
print the same hashes.

The three runs of record ran on 2026-11-28; this unit's evidence started on 2026-11-27 (`21:46` CET). The first session wrote this
folder, ran its runs on 2026-11-27 and stopped before its sealed clone, its check and its commit; the resumed session (the factory's
2026-11-28 lock) changed the receipt's date rule (below, D15) and so ran all three again with the changed files. Each run's date and
load are its log's first two lines.

## RE-MEASURE (settled first, each by its capture)

- **1** `advisory` — the read filed for Section 4 (`_research/docs-2026-11-27/advisories-s4probe/`), its `fetched-at.txt` naming the
  day this unit's evidence started (the runs of record fell on the day after it: D15); both of the day's `MD5SUMS.txt` verified line by line; Tomcat's page `a1a756d9…` as before; OSV `0` with vulns (the
  other witness only; it queried `micrometer-core` `1.17.3`). The pins read off the jar: Boot `4.1.3`, Framework `7.0.11`, Tomcat
  `11.0.29`, Jackson `3.1.8`, Micrometer `1.17.3`. `BOOT-INF/lib` `167`: this unit adds no artifact. Verdict: no pin affected.
- **2** `before` — `before` and `after` are one tree through two links (`128` files, `b8956a6e…` each); `BOOT-INF/lib` `167`; the
  committed spec `36,164` B, `aa8cb98f…`, `21` operations and `19` paths; the filters' orders off the sources: the limiter `-95`, the
  key filter `-90`, the shallow tag filter `-80`; the limiter's keys `capacity: 1000`, `refill-period: 1m`.
- **3** `pin` — Micrometer `1.17.3` and its Prometheus registry `1.17.3`, off the jars' manifests. The outcome rule, read off the jar
  with `javap` (`Outcome.forStatus`): `100`-`199` `INFORMATIONAL`, `200`-`299` `SUCCESS`, `300`-`399` `REDIRECTION`, `400`-`499`
  `CLIENT_ERROR`, `500`-`599` `SERVER_ERROR`, anything else `UNKNOWN`. So a `429` falls in `CLIENT_ERROR` and a `304` in
  `REDIRECTION` by the rule the jar holds (no standards document is read here, R.559). The exposure: `include: health,prometheus` in
  `application.yaml`; on a harness-free JVM `GET /actuator` lists `health`, `health-path`, `prometheus`, `self`, and
  `/actuator/metrics` and `/actuator/mappings` answer `404`. The scrape is the way in. No `application*.yaml` names
  `percentiles-histogram` or `distribution` (`0`; a scratch yaml holding the key counts `1`). `RateLimitFilter.java` names
  `setPathPattern` or `findObservationContext` on `0` lines, `IdempotencyKeyFilter.java` on `1` (a scratch copy of the limiter's file
  with one such line added counts `1`), and the key filter calls its `observe(req, op)` at two sites: the replay and every problem it
  writes itself.
- **4** `census` and `spec` — `17` controllers by unit 15's printed rule (`11` final default-run, `1` not final default-run, `5`
  dev-only), the census refusing a planted empty folder; the spec as above, its count refusing a planted empty file.
- **5** `scrape` — `GET /actuator/prometheus` on the nine's JVM answers `200`, `text/plain;version=0.0.4;charset=utf-8`, its
  `Content-Length` equal to the file's bytes. Its `http_server_requests` families: `http_server_requests_seconds` (TYPE `summary`),
  `http_server_requests_seconds_max` (TYPE `gauge`), `http_server_requests_active_seconds` (TYPE `summary`) and
  `http_server_requests_active_seconds_max` (TYPE `gauge`). `0` `_bucket` lines. The filed scrape is the masked one: every value but
  the `_count` lines becomes `<v>`.
- **6** `tags` — `6` tag keys on every `_count` row: `error`, `exception`, `method`, `outcome`, `status`, `uri`. On the nine:
  `method` `GET`; `status` `200`, `400`, `404`; `outcome` `SUCCESS`, `CLIENT_ERROR`; `error` and `exception` `none` on every row,
  the not-founds and the bad request included. The `error` tag is not the E of RED.
- **7** `known` — the nine, rebuilt from the probe's filed bodies (D4), sent in order to a fresh JVM that gets nothing else first:
  `7` rows outside `/actuator/`, their counts summing to the `9` requests sent, equal label for label and count for count to the
  probe's `series.txt` (`1a6ae5cd…`). The counts equal the requests sent per method and status, outside `/actuator/`; the first read
  holds no actuator row, and the scrape's own row appears in the next one (`GET 200 /actuator/prometheus`, count `2` in `scrape2`: the
  first read and its agreement read). The access log is the second witness. The old route's row, `GET 200 /customers/{name}`, counts
  `1` (handed to unit 24). The second set on the same JVM, row by row in the diff `scrape1 -> scrape2`: a `GET` (`200`, the template's
  count up by one), the conditional `GET` with the first answer's tag (`304`, a new `REDIRECTION` row under the template), a `DELETE`
  (`405`, a new row under `UNKNOWN`), and the key filter's three (below).
- **8** `404` — the not-found rows of `scrape1` by `uri`: `/api/v1/customers/{name}` `1`, `/api/v1/customers/{name}/bill` `1`, `/**`
  `2`. A mapped route's `404` keeps its template, and its body is TiffinBox's own problem (`customer-not-found`); a request no route
  matched is counted under `/**`, and its body is Spring's static-resource problem ("No static resource …", no type). `/**` is a
  resource handler's pattern on the mappings read (the harness's exposure flag), not a handler method's.
- **9** `unknown` — the harness's capacity of five (`--tiffinbox.rate-limit.capacity=5`, a run flag; the start line reads `capacity 5`):
  five reads of `GET /api/v1/customers/Ravi` answer `200`, the next two `429`, and an eighth read too, `application/problem+json`
  with no charset, `Retry-After` read back (its value masked, never voiced). Its scrape: the five under `/api/v1/customers/{name}`,
  the three refusals under `uri="UNKNOWN"`, `status="429"`, `outcome="CLIENT_ERROR"`; three refusal lines in the JVM's log. The
  `405` on the nine's JVM: `DELETE /api/v1/customers/Ravi`, `Allow: GET, PATCH`, counted under `UNKNOWN`: a finding of Course 6's units,
  re-measured on this tree.
- **10** `filters` — two filters, two answers. On the nine's JVM, `POST /api/v1/customers/Ravi/pauses?days=2` with one generated
  `Idempotency-Key` twice answers `201` twice (the second is the key filter's replay: its body is the first answer's, byte for byte),
  and once with no key `400` (the key filter's own refusal). Their rows: `POST 201` count `2` and `POST 400` count `1`, both under
  `/api/v1/customers/{name}/pauses`; no `POST` row under `UNKNOWN`. The limiter's refusal is counted under `UNKNOWN` (above). So the
  key filter's answers carry their route; the limiter's do not.
- **11** `errors` — E of RED, computed by python off `outcome` (`CLIENT_ERROR` and `SERVER_ERROR`), never off `error`. On the nine's
  JVM after the second set the rows in are the `400`s, the `404`s and the `405`; the rows out are the `200`s, the `201`s and the `304`
  (`REDIRECTION`). On the capacity-of-five JVM the `429` row is in. The `error` tag reads `none` on every one of those rows. The
  `SERVER_ERROR` half: on the harness's failing route (`GET /probe23/boom`, harness-joined, `21126`) the answer is `500`, its row
  `outcome="SERVER_ERROR"` under `/probe23/boom`, with `exception` and `error` both `IllegalStateException` - so the `error` tag names
  the exception on that row, and `none` on every row of a shipped answer this unit captured.
- **12** `duration` — names only: `http_server_requests_seconds` (TYPE `summary`: `_count`, `_sum`; `_max` as its own `gauge`) and
  `http_server_requests_active_seconds`; every `_sum` and `_max` value masked. `0` `_bucket` lines on the default run; the same count
  on that scrape with one planted `_bucket` line is `1` (the control); with the harness's histogram flag (a run flag on a scratch JVM)
  `_bucket` lines appear. Handed to *Ship It & Observe* by course title: where the third letter lives and how it is read.
- **13** `api`, `seven`, `surface` — each its own JVM; not witnesses for the scrape (none of them reads `/actuator/prometheus`): the
  `/api/v1/` census `11` requests, identical on two passes (U22's `api` line names `11` too); the seven and the old surface equal
  to U22's values (their md5 values in the values block), and the S9.14 plant (problem details off, a run flag) moves the surface. Nothing was edited, so nothing could move (R.511).
- **14** `inert` — the exact list of requests that carried an `Idempotency-Key` to a TiffinBox JVM in this unit: the two keyed POSTs of
  `filters`, on the nine's JVM; none elsewhere (a scratch list with one added counts it).
- **15** `tests` — `mvn -o clean package` of `before` with its tests: the web module `88` green (`InputHardeningTest` `3` of them),
  the client `5`, `0` skipped, the reactor's four `SUCCESS` lines, `0` refusals of the limiter outside `RateLimitFilterTest`, `0`
  downloads. No test is added and no `verify` runs: there is no anchor change, and no IT reaches a path this unit touches (U22's `tests`
  leg ran the `14` ITs on this tree).
- **16** `exercise` — measured first on the scrape the exercise names: its own JVM (`21128`) answers the nine plus two more not-founds,
  and its scrape's not-found rows are `/**` `3`, `/api/v1/customers/{name}` `2`, `/api/v1/customers/{name}/bill` `1`. The empty answer
  fails clauses one and three; the key (the rows by `uri` and `not a route: /**`) passes, under bash and `zsh -f`; five refused
  variants fail (run 1).

## The change: none

`git diff --stat d7e0663` over `c9-tiffinbox`, `c9-unit01` … `c9-unit22` and every `pom.xml` prints `0` lines at the start and at the
end of every run; the derived changed list is empty. The commit holds `c9-unit23/` alone.

## Which tree, which profile

`before` = `after` = `../c9-unit22/after`, read through the links, pinned by `../c9-unit22/receipts.md5`'s `after-tree` line. Every
JVM runs on H2 in memory (fresh per JVM), the default profile, the default capacity and the default exposure, except the labelled
harness starts below. No PostgreSQL, no container, no dev profile: what this unit says of the scrape is said of H2 only.

## Unit `23`'s section

The spine [S4B `## Unit 23`] says every request TiffinBox answers is counted by route and status, rate and errors as counts, errors =
`CLIENT_ERROR` + `SERVER_ERROR` (a `429` counts, a `304` does not), a template's not-found keeps its template, an unknown path is
`/**`, and its last clause puts every filter's answer under `UNKNOWN`. Measured: all of it, with one scope. What the limiter answers
has no route at all (`UNKNOWN`); the key filter's answers carry theirs (D1, `filters`). The failure receipt is the limiter's `429` counted
under `UNKNOWN` on the harness's capacity of five (R.312: the counter is right; the limiter answered before any route matched). The
hazards, each with its capture: `UNKNOWN` against `/**` (`404`, `unknown`); `0` histogram buckets by default, with its planted control
and the harness's histogram flag (`duration`); the actuator's own requests are counted too: the scrape's own row appears from the
second read on, and every "equal to the requests sent" line is computed outside `/actuator/` (`known`).

## The captures — what each one shows

### `advisory`, `before`, `pin`, `census`, `spec`

The day's read, verified; the counters re-derived on `before`; Micrometer's version and the outcome rule off the jar; the exposure in
the yaml and on a running JVM; the controllers and the spec.

### `scrape`, `tags`, `known`, `404` (the nine's JVM, `21120`; H2; harness-free)

```
the nine (rebuilt from the probe's a1-a9: each request from its status and its body's instance)
  GET /api/v1/customers/Ravi        200   uri=/api/v1/customers/{name}
  GET /api/v1/customers/Ravi        200   uri=/api/v1/customers/{name}
  GET /api/v1/customers/Nobody      404   uri=/api/v1/customers/{name}
  GET /api/v1/nosuch/route          404   uri=/**
  GET /customers/Ravi               200   uri=/customers/{name}
  GET /api/v1/orders?size=2         200   uri=/api/v1/orders
  GET /api/v1/orders?bogus=1        400   uri=/api/v1/orders
  GET /api/v1/customers/Nobody/bill 404   uri=/api/v1/customers/{name}/bill
  GET /nowhere                      404   uri=/**

scrape1, the _count rows (uri · status · outcome · count)
  /api/v1/customers/{name}       200  SUCCESS       2
  /api/v1/orders                 200  SUCCESS       1
  /customers/{name}              200  SUCCESS       1
  /api/v1/orders                 400  CLIENT_ERROR  1
  /**                            404  CLIENT_ERROR  2
  /api/v1/customers/{name}       404  CLIENT_ERROR  1
  /api/v1/customers/{name}/bill  404  CLIENT_ERROR  1

the diff scrape1 -> scrape2 (the second set)
  added   DELETE 405 CLIENT_ERROR UNKNOWN · count 1
  added   GET 200 SUCCESS /actuator/prometheus · count 2
  changed GET 200 SUCCESS /api/v1/customers/{name} · count 2 -> 3
  added   GET 304 REDIRECTION /api/v1/customers/{name} · count 1
  added   POST 201 SUCCESS /api/v1/customers/{name}/pauses · count 2
  added   POST 400 CLIENT_ERROR /api/v1/customers/{name}/pauses · count 1
```

### `unknown`, `filters` (the harness's capacity of five, `21125`; the nine's JVM)

```
cap=5 (the harness's capacity of five, a run flag)
  GET /api/v1/customers/Ravi ×5 -> 200 · ×2 -> 429 · an eighth -> 429 application/problem+json, Retry-After <s>
  GET 200 SUCCESS      /api/v1/customers/{name}         count 5
  GET 429 CLIENT_ERROR UNKNOWN                          count 3
the nine's JVM, the second set
  DELETE /api/v1/customers/Ravi -> 405, Allow: GET, PATCH       -> DELETE 405 CLIENT_ERROR UNKNOWN
  POST …/pauses?days=2, a generated key  -> 201 (the route)      \
  POST …/pauses?days=2, the same key     -> 201 (the replay)      -> POST 201 SUCCESS /api/v1/customers/{name}/pauses count 2
  POST …/pauses?days=2, no key           -> 400 (the key filter) -> POST 400 CLIENT_ERROR /api/v1/customers/{name}/pauses count 1
```

### `errors`, `duration`

```
E of RED, off outcome (the nine's JVM after the second set)
  in : DELETE 405 UNKNOWN · GET 400 /api/v1/orders · GET 404 /** · GET 404 /api/v1/customers/{name}
       GET 404 /api/v1/customers/{name}/bill · POST 400 /api/v1/customers/{name}/pauses
  out: GET 200 (three routes) · GET 304 REDIRECTION /api/v1/customers/{name} · POST 201 /api/v1/customers/{name}/pauses
  cap=5: in GET 429 CLIENT_ERROR UNKNOWN · out GET 200
the harness's failing route (21126, harness-joined)
  GET /probe23/boom -> 500 · GET 500 SERVER_ERROR /probe23/boom error=IllegalStateException exception=IllegalStateException
the duration, by name (values masked)
  http_server_requests_seconds_count / _sum   (summary)    http_server_requests_seconds_max (gauge)
  http_server_requests_active_seconds         (summary)    _bucket lines: 0 · with one planted: 1 · the histogram flag: more than 0
```

The harness's failing route, whole: `harness/src/probe23/Boom.java` - one `@RestController` whose `GET /probe23/boom` throws
`IllegalStateException`, labelled THE HARNESS'S FAILING ROUTE, joined only by `--spring.main.sources=probe23.Boom` on `21126`.

### `api`, `seven`, `surface`, `inert`, `tests`, `harness`, `exercise`, `title`

Not witnesses for the scrape: the census, the seven and the old surface, each its own JVM. The keyed list. The build with its tests.
The folder's files, the instruments and the static check's three runs. The exercise under both shells. The title for search,
"Spring Boot http.server.requests: Per-Endpoint API Metrics", `58` characters by `len()`, no clash in the registries.

## Measured, not shipped

The harness's capacity of five (`--tiffinbox.rate-limit.capacity=5` on one scratch JVM), the harness's histogram flag
(`--management.metrics.distribution.percentiles-histogram.http.server.requests=true` on one scratch JVM), the harness's exposure flag
(`health,prometheus,mappings,metrics`, on the harness-joined JVM only), the harness's failing route (`harness/src/probe23/Boom.java`),
the S9.14 plant's JVM (problem details off) and the scratch copies of the plants. None is in a jar, a module or a yaml.

## Refused, named

Each refused by `harness/s923.py` (XU23C9, fourteen families) and planted in its self-test, with a near miss beside each that passes:
the filter left unnamed when an answer's route is said; the catch-all said of every not-found; the `error` tag read as the errors; a
typed E total; the refusal or the not-modified answer placed on the wrong side of E; a status's meaning taken from a standard with no
dated read; the refusal said of a client at the default capacity; the actuator's rows left unnamed when the counts are said; the
metrics endpoint, the histogram or the percentiles said to be on; a duration value or a word that judges one; a scraper said to be
reading TiffinBox (a `curl` read it); a route said to be a person; the census, the seven or the surface said to witness the scrape;
the method said as a rule of good practice. A count typed instead of printed.

## The repository, and the network

The advisory read of the batch day stands: the S4 probe's read filed under `_research/docs-2026-11-27/` (2026-11-27, `12:32` CET)
cleared Boot `4.1.3`, Framework `7.0.11`, Tomcat `11.0.29`, Jackson `3.1.8` and Micrometer `1.17.3`, and this unit adds no
coordinate. The day rule is applied to the day this unit's evidence started (2026-11-27); each run prints its own date, and
all three runs of record and the commit fell on 2026-11-28, after midnight (D15). Nothing else was read from the network; the only network act is the final `git push`.

## The folders, the harness and the ports

`README.md`, `receipts.sh`, `receipts.md5`, `before` and `after` (two links), `harness/` (`chk23.py`, `dur9.py`, `norm.py`,
`ops9s3.py`, `s923.py`, `scrape.py`, `tree23.py`, `src/probe23/Boom.java`), `exercise/` (`README.md`, `SOLUTION.md`, `run.sh`,
`check.sh`, `apply.sh`, `requests.txt`, `mappings.txt`). Copied byte-equal: `dur9.py`, `ops9s3.py`, `norm.py` (unit 22's). Adapted with a
named diff: `tree23.py` (the docstring), `s923.py` (U22's `s922.py` with XU23C9), `chk23.py` (U22's machinery, this unit's captures).
New: `scrape.py`, `Boom.java`, the exercise's scripts. Read, not copied: the probe's `h45` and `h41` captures. Not used: every Chrome,
entity-route, record, key-copy and PostgreSQL instrument. Ports, §P's slot for this unit: `21120` the nine's JVM, `21125` the scratch
JVMs one at a time, `21126` the harness-joined, exposure-flagged JVM, `21128` the exercise; `21121`-`21124`, `21127`, `21129`,
`21110`-`21119` and `21160`-`21169` never bound; `21280`-`21284` not bound (no `verify`).

## Masks, filters and hygiene

One self-tested log mask (the start lines' times, the `ms` counts, timestamps, the folders, the band's ports, HTTP dates, UUIDs, the
`Retry-After` value) and the scrape's own mask (`harness/scrape.py`, self-tested: every value but the `_count` lines becomes `<v>`; a
planted `_bucket` line counted `1`). The raw scrapes stay under `.harness/`, never tracked. Every capture file is asserted non-empty, no
capture step hides its failure, and the receipts refuse a GNU-only `sed` form (R.564). Every process is stopped by its recorded pid; no
container is started; images, volumes and the container list equal at the end.

## Interrupted

Four SIGINT points, each by a driver that starts `bash receipts.sh` under `perl` with SIGINT at its default, holds until its
condition and signals the receipt's own recorded pid (never a name); each ended with exit `130`, no java of this unit left, `21120`-
`21129` free, no `.r-lock`, no `.r-*.new`, the captures unchanged, `c9-tiffinbox` equal to `c9-unit22/after`, images `9` and
volumes `315` as at the start (2026-11-28, before the runs of record):

- mid-build: `before`'s Maven build started and not finished.
- mid-harness: the nine's JVM (`21120`) up, the nine sent, the first scrape not yet read.
- mid-scratch-JVM: the capacity-of-five JVM (`21125`) up.
- mid-exercise: the exercise's JVM (`21128`) listening.

Mid-container and mid-Chrome do not apply: no container, no browser.

## Planted faults — each caught

`chk23.py plants` on every run of record: `49` plants caught, each a FAIL line with exit `1` and no traceback. They cover a count
one off, the old route's count typed `2`, a row of `series.txt` typed differently, a `/actuator/prometheus` row typed into the first
read, the `405` typed under a template, a seventh tag key, the `error` tag typed non-`none`, the catch-all's count typed up, a
template's not-found typed under `/**`, the `429` typed under its route, the capacity typed `1000` on the capacity-of-five JVM,
`Retry-After` voiced, the replay typed `UNKNOWN`, the missing-key refusal typed `201`, a `429` left out of E, a `304` counted in it, the
`error` tag read as E, the `SERVER_ERROR` row typed otherwise, `_bucket=0` without its control, a `_sum` value left in a filed text,
buckets typed present by default, Micrometer typed `1.17.2`, the exposure typed wider, `/actuator/metrics` typed `200`, the limiter
typed as setting its route, the sources' grep without its control, `before` retargeted, the jar list typed `166`, the census typed
`18`, the spec one byte off, the web tests typed `85`, a skipped test, a refusal at the default capacity, the seven's and the surface's
md5 altered, the census moved, a keyed request outside the key filter's leg, the solution equal to the broken answer, the empty answer
typed passing, a read dated before the start's date, a run dated 2026-11-29, a request count over the cap, a refusal line at the default, a title over the limit, and
unparseable listings. The static check's own plants (a read of the live anchor, its path from two pieces), R.564's GNU-`sed` plant and
the prose gate's self-test (XU23C9's plants and near misses) run at every start or in `harness`.

## What differed from the brief

The orchestrator bound C1-C10 to their RECOMMENDED options and D1-D18 as written (2026-11-27 `21:46` CET); each is listed here and
under "For RED".

- C1 (a): two links, text `../c9-unit22/after`. C2 (a): no anchor README card. C3 (a): the probe's nine, rebuilt, on one fresh JVM,
  the second set after `scrape1`. C4 (a): three legs (the `429` at a capacity of five, a `405`, the key filter's replay and refusal). C5 (a):
  E off `outcome`, plus the harness's failing route. C6 (a): names only, the zero count with its control, the histogram flag run. C7
  (a): the default `404` of `/actuator/metrics` and one exposure-flagged read (mappings and the metrics endpoint). C8 (a): one package
  with tests, no `verify`. C9 (a): the live scrape exercise on `21128`, a derived key, five refused variants. C10 (a): the batch day's
  read stands.
- D1: measured for both filters (`filters`): the limiter's refusal under `UNKNOWN`, the key filter's replay and refusal under
  `/api/v1/customers/{name}/pauses`. Every sentence here names the filter; the spine's sentence is quoted as the brief's and scoped by
  the line after it.
- D2: line numbers were re-read; where a rule's text and a number differed the text ruled.
- D3: every number here is this unit's own, three runs; the probe's rows were the expectation and were met (`series.txt` equal).
- D4: the nine are rebuilt from the probe's bodies (the order list's `size=2` and the bad request's `bogus=1` are readings of the bodies:
  two items and a `next`; "unknown parameter [bogus]"); the capture asserts the rows equal `series.txt`.
- D5: `s923.py` = U22's `s922.py` + XU23C9, asserted against U22's copy; `_builders/s923.py` does not exist (the guard stays).
- D6: the exercise's words are kept; its "not a route" is answered by the catch-all pattern `/**` (it names no route: a resource
  handler's pattern on the mappings read), never by `UNKNOWN`, which counts no not-found here.
- D7: Course 6's units' `/**` and `UNKNOWN` re-measured on this tree; the anchor README's two sentences (`it tags every 404 here uri="/**"`,
  `a 404 is uri="/**"`) are true only of a request no mapping matched - filed for the orchestrator, not edited (no anchor change).
- D8: E is read off `outcome`; the `SERVER_ERROR` row comes from the harness's failing route only; the `error` tag reads `none` on every
  shipped row captured and names the exception on the failing route's row.
- D9: every capture of the shipped scrape is on the default exposure; the exposure flag appears only on the labelled `21126` start.
- D10: the scrape is filed masked; the start-time gauges, the JVM and process families and every `_sum` and `_max` become `<v>`.
- D11: the duration is handed to *Ship It & Observe* by course title; Course 16 is not named.
- D12: the gloss is the one typed line; its spoken form of "RED" is the scripts stage's.
- D13 and N1: the ports as listed above (the brief names three; §P's slot names ten).
- D14: SIGINT points, as recorded under "Interrupted"; the third static run in the sealed clone with its anchor moved aside.
- D15: the date rule applied at the start (2026-11-27). The first session's receipt compared each run's own date with the read's, so a
  run after midnight would have stopped; the resumed session changed that check to the prompt's rule: the read's date equals the date
  the evidence started (`USTART` in `receipts.sh`), and a run's date (a run-variant line) is that date or the next calendar date, the
  start's session resumed; any other date stops. Planted both ways (a read dated 2026-11-26, a run dated 2026-11-29). All three runs
  of record and the commit fell on 2026-11-28.
- The cap: the first session's cap (`00:15` CET, from its start at `21:45`) passed with the unit unlanded; the resumed session ran under
  the 2026-11-28 lock (its `06:26` slot, until `11:30`) with the orchestrator's cap of `09:45` CET.
- D16: the old route's row is printed as `old=` and handed to unit 24.
- D17: the failure receipt is the harness's capacity of five's; the default capacity is read back on every other start line.
- D18: the title is `58` characters, printed, not edited.
- Flag 10's witness: the key filter's `REPLAY` line is logged at `DEBUG`, so the default run's log holds none; the replay is witnessed
  by its body (byte-equal to the first answer) and its row. The limiter's count at a capacity of five is `3`, not `2`: the eighth read
  (the one whose headers are printed) is a third refusal.
- Flag 9's label: the brief's label for the capacity flag is written "the harness's capacity of five" in this README: the prose
  gate refuses its adjective as a duration word (XFAM_S2); the captures keep the brief's label.
- Flag 13: the `api` census ran twice on one JVM (two passes), where U22 ran it on two trees; `11` requests each, equal to U22's.

## For RED

- C1-C10 as bound above.
- D1: the spine's last clause (every filter's answer under `UNKNOWN`) - measured for two filters: true of the limiter, not of the
  key filter (its `observe` sets the route on the replay and on its own problems). The scripts stage decides whether the spine's
  sentence is rewritten.
- D4: the nine are rebuilt, not filed. D6: "not a route" against RED #25 - the catch-all is a resource handler's pattern.
- D7: the anchor README's two sentences from Course 6's units that a mapped template's not-found contradicts, filed, not edited.
- D8: `SERVER_ERROR` measured only on the harness's failing route; the `error` tag names the exception there.
- D10: the scrape's values outside `_sum`/`_max` (start times, JVM and process gauges) masked too.
- D11: Course `18` alone. D12: the gloss form and the spoken form of "RED". D15: the day rule across midnight. D16: the old route's
  count for unit 24. D17: the failure receipt on the harness's capacity of five. The title. The hook's word count. No test is added (no
  route, no test pins a scrape): a note, not a defect.

## The ledger rows this unit pays

`TRACK-ROADMAP.md:397` ("per-endpoint metrics and the RED method; deepened in course `18`"); C9-15's Course `18` half - the duration handed
to *Ship It & Observe* by course title. C9-11 is not re-paid (no anchor change). No ledger edit: a note for the orchestrator.

## The values the video may say

Each value with its capture, three runs, H2: the nine and their `7` template rows and `2` catch-all rows (`known`); the six tag keys
(`tags`); the not-found rows by `uri` (`404`); the limiter's refusal under `UNKNOWN`, `CLIENT_ERROR`, on the harness's capacity of five,
and the `405` under `UNKNOWN` (`unknown`); the key filter's replay and refusal under their route (`filters`); which rows E takes and
which it leaves (`errors`); the duration's family names and `0` buckets by default (`duration`); Micrometer `1.17.3` and the outcome
rule (`pin`). No duration value, no total, no bucket value; no E total.

<!-- values: begin -->
```
advisory: fetched=2026-11-27 micrometer=1.17.3 lib=167
before: tree=128/b8956a6e lib=167 orders=-95/-90/-80
pin: micrometer=1.17.3 rule=4xx:CLIENT_ERROR,3xx:REDIRECTION exposure=health,prometheus metrics=404
census: census=17/11/1/5
spec: spec=36164 ops=OPERATIONS 21 PATHS 19
scrape: families=http_server_requests_active_seconds:summary,http_server_requests_active_seconds_max:gauge,http_server_requests_seconds:summary,http_server_requests_seconds_max:gauge _bucket=0
tags: keys=6(error,exception,method,outcome,status,uri) error=none
known: nine=9 rows=7 template=7 catchall=2 equal_series=yes old=1 second=304,405,201x2,400
404: template=2_rows catchall=/**x2
unknown: 429=UNKNOWN(3,CLIENT_ERROR) 405=UNKNOWN cap=5
filters: replay=/api/v1/customers/{name}/pauses(201) refusal=/api/v1/customers/{name}/pauses(400) limiter=UNKNOWN
errors: in=CLIENT_ERROR+SERVER_ERROR out=SUCCESS,REDIRECTION(304) 429=in error_tag=none server_error=boom(500,IllegalStateException)
duration: names=http_server_requests_seconds(_count,_sum,_max) _bucket=0 control=1 histogram_flag=buckets
api: api=11 identical
seven: seven=466c20ed
surface: surface=316a9637
inert: keyed=2(jvma) elsewhere=0
tests: web=88 client=5 its=14(U22) verify=not_run
harness: static=ed1c7c6fe09efb19eb1418ba3a29d7c3
exercise: broken=FAIL(1,3) solved=PASS(3_rows) catchall=/**
title: title_len=58
plants: plants=49
build: seed_files=11323 seed_bytes=889446136 central_only=0
```
<!-- values: end -->
