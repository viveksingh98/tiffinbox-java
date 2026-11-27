# Course 9 · Rate Limiting — evidence

```
Five reads go through. The sixth gets a 429 and a number: try again then. Key the bucket on a header instead, and a made-up one walks straight past.
```

What is measured behind that hook, on H2 unless a line says otherwise: five reads of `GET /api/v1/customers/Ravi` answer two hundred on a
start with the capacity five (a run flag), the sixth is refused with `429` and a `Retry-After` header, an integer within the refill
period read back. A made-up key walks past only on the harness's header-keyed copy; TiffinBox's own filter counts it under the address.
The hook stands in a fenced block, byte for byte the brief's: the prose gate refuses its `429` said in digits as a spoken sentence, and
its length (`29` words, the longest sentence `14`) is handed to RED and the scripts stage; the hook is never edited here.

A token bucket: a count of requests that refills.

Course 9's fifteenth anchor change, Section 4's first unit. `before` is a link to `../c9-unit18/after`; `after/` is the frozen copy of
`../c9-tiffinbox` after this unit's change. Every number below names its tree and its capture; every capture says which database or store
answered (H2, in memory, a fresh one per JVM, unless a line says the profile "dev" with PostgreSQL, Redis, MongoDB and Elasticsearch).

## Runs of record

Three runs, each launched below load1 `20` with the load printed on its first line, each ending `every capture = published (19)`, and `check_unit9.py 19 --runlog` read on each run log (its unit gate exits `2` until the script of this unit exists, as
expected; the run-log line is the one read):

- run 1: bash `3.2.57`, `RUNNO=1 ./receipts.sh` in this folder.
- run 2: bash `5.3.9`, `RUNNO=2 bash receipts.sh` in this folder.
- run 3: bash `3.2.57`, `RUNNO=3 ./receipts.sh` in a sealed copy of the repository in a folder whose path holds a space (R.129), with
  that copy's own anchor folder moved aside before the run (flag 31 (iii)).

As run (2026-11-27; each log's `check_unit9.py 19 --runlog` line: `RESULT (run logs): PASS`):

- run 1: bash `3.2.57`, in this folder, load `4.75 5.53 5.73` at the start; every capture = published (`19`); run-log gate PASS.
- run 2: bash `5.3.9`, in this folder, load `4.49 4.59 5.08` at the start; every capture = published (`19`); run-log gate PASS.
- run 3: bash `3.2.57`, in the sealed copy (`…/sealed clone/tiffinbox-java/c9-unit19`, cloned from the local commit), its anchor folder
  moved aside before the run (the start note: "they differ"), load `3.43 4.12 4.56` at the start; every capture = published (`19`);
  run-log gate PASS.

Flag 31, the three static runs: `chk19.py static after before` printed the same output, md5 `e1ff81fc…`, (i) as written in this folder,
(ii) in the sealed copy after a byte was appended to that copy's own anchor `compose.yaml`, and (iii) in the sealed copy with its anchor
folder moved aside; an audit hook in `chk19.py` refuses any open of a path inside the live anchor's folder, and both plants exit `1`.
These lines were written after run 3; the prose gate and the values block were run again on this README as committed.

## RE-MEASURE (settled first, each by its capture)

- **1** `advisory` — the read filed for Section 4, `_research/docs-2026-11-27/advisories-s4probe/` (the S4 probe's dated act), its
  `fetched-at.txt` naming the run's own day; both of the day's `MD5SUMS.txt` verified line by line; Spring's first page `25` ids, all of
  one date; Tomcat's page `a1a756d9…`, equal to the earlier reads; OSV `19` coordinates queried, `0` with vulns (the other witness only,
  S2.8), the three Bucket4j coordinates and `lettuce-core` `7.5.2.RELEASE` among them; the three Bucket4j POMs' licence Apache-2.0.
  Verdict: no pin affected. Nothing else was read from the network.
- **2** `before` — on `before` (21086, U18's `after`) seven reads of `GET /api/v1/customers/Ravi` answer two hundred, seven access-log
  lines; no refusal line, no setting line, no `rate-limit` key; `BOOT-INF/lib` `164`; the committed spec `21` operations and `19` paths,
  `36164` bytes, `aa8cb98f…`; the dispatcher servlet's mappings and the servlet filters printed (the key filter on `/customers` and
  `/api/v1/customers/*`).
- **3** `change` — two new classes, one new test class, the two POMs, `application.yaml` and the anchor's README: the derived changed list
  is these seven paths and nothing else; the listed old files byte-equal; no handler added; the web jar holds `bucket4j_jdk17-core`,
  `bucket4j_jdk17-lettuce`, `bucket4j_jdk17-redis-common` `8.23.0` and `lettuce-core` `7.5.2.RELEASE`, and Maven's dependency tree
  resolves Lettuce to the parent's version.
- **4** `census` — the controllers on `before` and `after/` by unit 15's printed rule: equal; `RateLimitFilter` and `RateLimiting` are
  named as not controllers by the rule.
- **5** `limit` — on `after/` (21080), capacity five by the run flag: five reads answer two hundred, then `429` twice; the refusal
  `application/problem+json` with no charset, its members `type`, `title`, `status`, `detail`, `instance`, the type
  `tag:tiffinbox.example,2026:rate-limited`, the instance the path as sent; `Retry-After` an integer no larger than the period read off
  `application.yaml`; the body's bytes equal by `Content-Length`, curl's count, the saved file and the access log's `%b`, and the answer is
  not chunked; two refusal lines in the JVM's log, none naming the address; no Redis connection line on the default run. The metrics
  scrape after it: the refusals counted under `uri="UNKNOWN"`, `status="429"`, `outcome="CLIENT_ERROR"`; the five reads under the route.
- **6** `forge` and `xff` — on `after/`, after the address's refusal, a forged `X-Api-Key` (twice) and a forged `X-Forwarded-For` are
  refused: counted under the address at Boot's default. On the harness's header-keyed copy (a made-up key) the two forged keys answer two
  hundred each - two fresh buckets - and the header-less read is still refused. With the run flag `--server.forward-headers-strategy=framework`
  (`flag=on`) three forged forwarded addresses each answer two hundred after the address's refusal, and one of them is refused again once
  its own five are spent: behind that flag the address the filter sees is the header's.
- **7** `refill` — the harness's own refill period on the command line (`period=short`): five reads, the refusal, its `Retry-After`
  within that period; polled one request at a time by condition (a bound derived from the two values, a count, never a time): the first
  request after it answers two hundred, and the bucket gives back five before the next refusal.
- **8** `scope` — after the address's refusal: `GET /api/v1/orders?size=5`, `GET /api/v1/customers/Ravi/bill` and an unknown
  `/api/v1/nosuch/route` refused (the address's bucket, not the route's, counted before the not-found); `HEAD`, `OPTIONS` and `PATCH` on an
  `/api/v1/` path refused; the keyed `POST /api/v1/customers/Ravi/pauses` refused before the key filter runs; `/customers/Ravi`, `/revenue`,
  `/dashboard`, `/v3/api-docs` and the health endpoint answered two hundred (the default run, which keeps no Redis); `/api/1.0/customers/Ravi` a four oh four - outside the pattern.
- **9** `twojvm` and `lua` — the profile "dev" with its four stores by digest on 21081-21084 (PostgreSQL, Redis, MongoDB, Elasticsearch):
  both JVMs print the profile and the bucket store, Redis through the client of Boot's own `LettuceConnectionFactory`. Capacity five on
  both: JVM A three reads, JVM B three, JVM A one - five reads let through on the two together, then refused on B and on A. One Redis key,
  `tiffinbox:api-rate:127.0.0.1`, a string with a positive `PTTL` (read by `redis-cli` inside the container). The keyed POST refused on B
  left the key table's rows on PostgreSQL as they were. Course 8's Lua counter on the same Redis replied `1` to `6` and named no wait.
- **10** `defaults` — R.555: after/'s own build ran the web suite at the default capacity: `81` tests, `0` failures, and `0` refusals
  outside `RateLimitFilterTest`'s own context (its capacity of three refuses `4` requests, by design); the setting's start line printed
  once per test context, `6` contexts. The plant at five on a scratch copy turned it red: `22` failures in `3` classes
  (`CustomerPatchesTest` `13`, `CustomerReadsTest` `5`, `IdempotencyKeyTest` `4`), each refusal counted in its class's log lines, and its
  build exited non-zero. Every receipt of the section after this one prints the setting read back.
- **11** `spec` — the served document equals the committed file, which this unit leaves byte for byte as `unit 18`'s (`36164` bytes,
  `aa8cb98f…`); the operations' ids equal; no operation documents the refusal; `OpenApiSpecTest` passes; the client untouched.
- **12** `moved`, `api`, the seven and the old surface — U18's request list on both trees at the default capacity: `0` lines moved, the
  answers' header names included (the limiter adds none to an answer it lets through); every GET of the committed spec's `/api/v1/` paths
  and two old refusals byte-identical on both trees; the seven and the old surface equal to the values block's on both - not witnesses for the
  limiter: neither sends a request to `/api/v1/` (R.511). The web jar gained `6` entries (the two classes, the filter's inner interface,
  the three jars); `4` shared entries moved, each named: `BOOT-INF/classes/application.yaml`, `BOOT-INF/classpath.idx`,
  `BOOT-INF/layers.idx` and the web module's `pom.xml` under `META-INF/maven` - the settings and the jar list, nothing else.
- **13** `tests` — `mvn -o clean package` over the reactor: the web module and the client green, none skipped, `RateLimitFilterTest`'s
  three tests among them; the Docker-free twin and the hand-built `-pl tiffinbox-web -am` form print the same counts; `mvn -o clean
  verify`: the five ITs, `14` tests, on their Testcontainers stores, every binding on `127.0.0.1`, nothing pulled, no container left;
  `0` downloads; `BOOT-INF/lib` `164` -> `167`, `0` removed.
- **14** `exercise` — on 21088, H2, under bash and `zsh -f`: the broken copy answers both forged keys two hundred after the refusal and
  `check.sh` fails on that clause; the solution passes; three refused variants fail (run 1).

## The change, file by file, and every README/Javadoc sentence it rewrote or noted (R.250/R.453)

The anchor's README card `## Course 9 · unit 19` and its header note give the change; the files whole are in `change`. The stale-sentence
hunt (`git grep -i` over the anchor's README and `src/main` for the limiter's words, `Retry-After`, `X-Forwarded`, `forward-headers`,
`bucket`, `kitchen-slot`, `tiffinbox:rate`, `no limit`) found only history: unit 16's card on the forwarded header (still true at Boot's
default), unit 17's card and `BillingRuns`' Javadoc on its own `Retry-After` (a different header use, untouched), `OrderResources`'
Javadoc on `X-Forwarded-Host` (still true). The cards' current counts, the web module's tests and `BOOT-INF/lib`'s jars, are
noted in the header note as true at `unit 18`. No card said the API had no limit. Course 8's `tiffinbox:rate:kitchen-slot` is its
harness's counter, not this filter's key family (`tiffinbox:api-rate:`).

## Which tree, which profile

Every capture of the shipped filter is a harness-free start of `after/` (21080) or of `before` (21086), on H2, the default run - except
`twojvm`, which runs `after/`'s jar twice (21080, 21085) under the profile "dev" with PostgreSQL `18.6` as its datasource, Redis `8.10.3`,
MongoDB and Elasticsearch `9.4.8`, each by digest with `--pull never`, on `127.0.0.1` only. The harness's header-keyed copy is a labelled
start of a copy (21085). `verify`'s ITs run on their own Testcontainers stores.

## This unit's section

The spine as the brief gives it: a limit on the public API, the refusal that says when to come back, a bucket the JVM keeps and one
Redis keeps for two JVMs together, and the key that decides whose bucket it is. Each part has its capture: `limit` (the refusal), `refill` (the
number kept), `twojvm` (one bucket for two JVMs), `forge` (the key). The failure receipt is the made-up key: on the harness's
header-keyed copy a header the caller chooses is a bucket the caller chooses; the anchor counts it under the address. The hazards: the
pattern is `/api/v1/*` only (`scope`); the default capacity meets no test (`defaults`); "dev" needs all its stores (the leg starts all
four); the jar list moves by three (`tests`).

## The captures — what each one shows

### advisory
The read's two `fetched-at.txt` lines, both `MD5SUMS.txt` verified, the shipped coordinates read off `after/`'s `BOOT-INF/lib`, the OSV
query's Bucket4j and Lettuce coordinates, the licences, the verdict.

### before, change, census
Seven reads on `before`; the POM diffs, `RateLimitFilter`, `RateLimiting` and `RateLimitFilterTest` printed whole, the derived changed
list, the greps, the dependency tree's Bucket4j and Lettuce lines; the census on both trees.

### limit
The seven-request table, the refusal's headers in full (`Date` masked, `Retry-After`'s value masked `<n>`), its body, python's reading of
the charset, the period and the bytes, the access log, the refusal lines; then the metrics lines for the route and for the refusal.

### forge and xff
The anchor's three forged requests beside the harness copy's, each labelled; then the flag leg.

### refill, scope
The harness's own period waited out by condition and the bucket given back; the table of what is counted and what is not.

### twojvm and lua
The four stores, both start lines, the sequence across the two JVMs, the Redis key by `redis-cli`, the key table on PostgreSQL; the Lua
counter's six replies.

### defaults, spec, moved, api, seven, surface, inert, tests, harness, exercise
The suite at the default and the plant at five; the spec unchanged; U18's list and the `/api/v1/` census on both trees; the seven and the
old surface; the two keyed requests; the reactor, the twin, `verify`, the web-only form; the harness's files and flag 31's static runs;
the exercise under both shells.

## Measured, not shipped

The harness's header-keyed copy (`break.sh`'s edit on `.harness/need-forge`, labelled "a made-up key"); the plant copy
(`.harness/plant-cap5`, the capacity five in its `application.yaml`); the run flags (`--tiffinbox.rate-limit.capacity=5`, the harness's
own period, `--server.forward-headers-strategy=framework`); the four dev containers and the datasource's config-tree file. No harness Java.

## Refused, named

The prose gate (`s919.py`, `XU19C9`) refuses, each planted and caught in its self-test: `per user`, `per customer`, `only Ravi's requests
count`; `the bucket is shared` said of the in-JVM bucket, `shared across JVMs` without dev beside it, the stand-in's numbers credited to
dev; `cannot be bypassed`, `protects the API`, `keeps attackers out`, `DDoS`, `a forged header does not help`; any word of dur9's list; `RFC`, `specified`, `required by` without a dated read; `Redis expires the bucket in`; `Bucket4j is thread-safe`; `the default
is safe`; `runs before everything`; `X-Forwarded-For is trusted`; `the spec documents the limit`; another gloss line; bare
`Retry-After`, `OpenAPI`, `springdoc`, `X-Api-Key` and `X-Forwarded-For` outside code spans; Hinglish; a status in digits.

## The repository, and the network

The advisory read stands: filed by the S4 probe on the run's own day, it cleared every pin this unit ships, the new Bucket4j jars and
Lettuce among them. Nothing else was read from the network; the only network act of this unit is the final `git push`.

## The folders, the harness and the ports

`README.md`, `after/`, `before` (the link), `exercise/` (`README.md`, `SOLUTION.md`, `apply.sh`, `break.sh`, `check.sh`), `harness/`
(`chk19.py` new; `dur9.py` and `ops9s3.py` copied byte for byte; `s919.py` and `tree19.py` adapted, their named diffs in `harness`),
`receipts.md5`, `receipts.sh`. Ports: 21080 `after/` and dev JVM A · 21081-21084 the dev stores · 21085 dev JVM B and the header-keyed
copy · 21086 `before` · 21088 the exercise · 21087 and 21089 never bound; 21280-21284 during `verify` only.

## Masks, filters and hygiene

One self-tested mask: a start's times, the log's time counts, timestamps, the folders and the home, `Retry-After`'s value, the band's ports,
Redis's `PTTL`, a `PT` duration, the period on a command line and in the start's line. Every container is `c9u19-*`, removed with its
volumes; images and volumes at the end equal the start's; every JVM is stopped by its recorded pid.

## Interrupted

SIGINT, under `perl -e '$SIG{INT}="DEFAULT"; exec …'`, driven by a scratch driver at three points, each a development run (`DEVCAPS`) of
this script: mid-harness (a JVM listening on 21080 in `limit`), mid-container (the Redis container up in `twojvm`) and mid-dev-leg (dev JVM
A on 21080 with Elasticsearch up). Each exited `130` and left no JVM, no listener in the band, no `c9u19-*` container, volumes at the
start's `315`, no `.r-lock` and no `.r-*.new`. Not driven: mid-build, mid-`verify`, mid-scratch-copy and mid-exercise (not said).

## Planted faults — each caught

`chk19.py plants` alters a copy of each run's own captures and requires a FAIL line, exit `1`, no traceback: a status list one off, the
probe's non-UTF-8 charset on the refusal, `Retry-After` not an integer, the type altered, the anchor's forged header typed two hundred, the
made-up key typed refused, the first request after the refill typed refused, an old route typed refused, the unknown route typed not
found, the Lua replies one off, the second JVM's refusal changed, the key's `PTTL` not positive, the plant green, a refusal at the
default, the committed file touched, the seven's md5 one character off, `Skipped` typed `1`, the solution equal to the broken copy, the
read dated after the run, an unparseable listing. The static check fails on a scratch copy moved by one byte; flag 31's two
plants (a read of the live anchor, its name in one piece and in two) exit `1`.

## What differed from the brief

- C1-C13: the orchestrator's note bound every pick at its RECOMMENDED option (picked by the orchestrator); each holds as measured, with
  these readings: C5's problem is built as an ordered map of the five members and written by Boot's `JsonMapper` as bytes (not a
  `ProblemDetail` object: its Jackson form adds members the map does not); C8's `restart` leg was not captured and is not said; C9's
  test adds the filter to MockMvc at its registration's own patterns and gives each test an address of its own; C10 runs three of the
  six refused variants (`trustxff`, `headerlast`, `fixedelsewhere`), the broken tree itself the fourth; C11's four stores ran.
- C14a: the ledger row C9-13 still says "none yet" for this unit while the brief says this unit pays it - a stale cell, noted for the
  orchestrator, not edited.
- C14b: the hook's `29` words are gated as written; its digits are refused as a spoken sentence; it stands in a fenced block.
- C14c-f: the key family is `tiffinbox:api-rate:` as printed; "dev" ran with all four stores; the two-JVM sequence is this run's, not the
  probe's stand-in; the period is `1m` in `application.yaml`, read back, never voiced.
- The prose gate's unit family is named `XU19C9`: `s918.py`'s carried base already holds Course 8's `XU19` (its `unit 19`).
- The charset plant is a plant on the capture, not a scratch build answering through `getWriter()`; the S9.14 plant slot was not
  captured (dropped first by the prompt's order).
- BLUE counted `5` test contexts at the default; this unit's own test class is the sixth.
- Flag 21: the frozen receipts' bursts (RED's count: unit 04 `21`, unit 12 `15`, unit 14 `17`, unit 17 `15` requests to `/api/v1/` per JVM)
  are below the default `1000`; not re-counted here.

## For RED

The picks as bound; the problem built as a map, not a `ProblemDetail`; the refusal not chunked, its `Content-Length` set; the spec's gap
(no operation documents the refusal) named, C7 (b) the alternative at the cost of every operation's entry; the dev store through Boot's
own `LettuceConnectionFactory`'s client, the cast to `RedisClient` printed in its start line; `0` moved lines under S9.37; the jar list
`164` -> `167` (the three Bucket4j jars); `restart` and the S9.14 slot dropped; the hook's `29` words and its digits; behind
`--server.forward-headers-strategy=framework` the caller chooses its bucket - which address to trust behind a real proxy is not decided.

## The ledger rows this unit pays

`TRACK-ROADMAP.md:393` (Rate Limiting); C9-11 (the seven and the old surface at this anchor change); C9-13 (7), the unauthenticated key,
handed by course title to *Spring Security — complete*: a rate limiter keyed by an unauthenticated value - the address is what the server
sees, and a caller can change it. No ledger edit.

## The values the video may say

Statuses as words; counts and versions in code spans only; no period, no wait and no `Retry-After` value voiced. From the values block,
each with its capture: five reads let through and the sixth refused at the capacity five (`limit`, H2), the refusal's body `226` bytes;
two forged keys let through on the harness's header-keyed copy, refused on the anchor (`forge`, H2); the bucket gives back `5` after the
harness's own period (`refill`, H2); under "dev" the two JVMs' sequence and the one key `tiffinbox:api-rate:127.0.0.1` (`twojvm`, Redis
`8.10.3`, PostgreSQL `18.6`); Course 8's counter `1` to `6` (`lua`, Redis); the web suite `81` tests with `0` refusals at the default, and
`22` failures in `3` classes at five (`defaults`, H2); the web tests `78` -> `81`, the ITs `14`, `BOOT-INF/lib` `164` -> `167` (`tests`).

<!-- values: begin -->
```
advisory: fetched=2026-11-27 lib=164 · after 167
before: before=7x200 lib=164 mappings=36 OPERATIONS 21 PATHS 19
change: changed=7
census: census=17/11/1/5 spec=OPERATIONS 21 PATHS 19
limit: statuses=200,200,200,200,200,429,429 body=226B ct=application/problem+json metrics429=2 uri429=UNKNOWN uri200=/api/v1/customers/{name}
forge: anchor=429x3 copy=200,200,429 xff=200,200,200 xff_seventh=429
refill: after_wait=200 given_back=5
scope: /api/v1/orders?size=5=429 /api/v1/customers/Ravi/bill=429 /api/v1/nosuch/route=429 /customers/Ravi=200 /revenue=200 /dashboard=200 /v3/api-docs=200 /actuator/health=200 /api/1.0/customers/Ravi=404
twojvm: seq=A200 A200 A200 B200 B200 B429 A429 key=tiffinbox:api-rate:127.0.0.1 strlen=107 lua=1-6 rows=0->0
defaults: tests=81 refusals_default=0 contexts=6 plant_failures=22 plant_classes=3 CustomerPatchesTest=13,CustomerReadsTest=5,IdempotencyKeyTest=4 plant_refusals=CustomerPatchesTest=13,CustomerReadsTest=5,IdempotencyKeyTest=4,RateLimitFilterTest=4
spec: spec=36164 ops=OPERATIONS 21 PATHS 19
moved: moved=0 jar_added=6 jar_moved=['BOOT-INF/classes/application.yaml', 'BOOT-INF/classpath.idx', 'BOOT-INF/layers.idx', 'META-INF/maven/com.tiffinbox/tiffinbox-web/pom.xml'] lib=164->167
api: api=11
seven: seven=466c20ed
surface: surface=316a9637
tests: web=81 client=1 ratelimit=3 its=14 lib=164->167 added=bucket4j_jdk17-core-8.23.0.jar,bucket4j_jdk17-lettuce-8.23.0.jar,bucket4j_jdk17-redis-common-8.23.0.jar
harness: static=e1ff81fcfb860e69682a9798cb8548c8
exercise: broken=FAIL solved=PASS
inert: keyed=2
plants: plants=20
build: seed_files=11323 seed_bytes=889446136 central_only=0
```
<!-- values: end -->
