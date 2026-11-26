# Course 9 · Unit 17 — Bulk Operations and `202` Accepted

```
Ask TiffinBox to bill every customer, and it answers at once: accepted, come back here. Restart it, and here is gone.
```

What is measured behind that hook: the old run's address answers a four oh four with its type on JVM-2, a fresh start of the same jar;
a new run on JVM-2 is accepted and ends with the four bills (the control); a run stopped in the running state shows the same. Nothing is
said of any store other than this map in this JVM.

A status resource: the address that tells you how the job is going.

Course 9's thirteenth anchor change, Section 3's fifth unit. `before` is a link to `../c9-unit16/after`; `after/` is the frozen copy of
`../c9-tiffinbox` after this unit's change. Every number below names its tree and its capture; every capture says which database
answered (H2, in memory, a fresh one per JVM, unless a line says PostgreSQL).

## Runs of record

Three runs, each launched below load1 `20` with the load printed on its first and last line, each ending
`c9-unit17: every capture = published (18)`, and `check_unit9.py 17 --runlog` read on each run log (its unit gate exits `2` until the
script of unit 17 exists, as expected; the run-log line is the one read):

- run 1: bash `3.2.57`, `RUNNO=1 ./receipts.sh` in this folder.
- run 2: bash `5.3.9`, `RUNNO=2 bash receipts.sh` in this folder.
- run 3: bash `3.2.57`, `RUNNO=3 ./receipts.sh` in a sealed copy of the repository in a folder whose path holds a space (R.129).

As run (2026-11-26, on the script as committed; each log's `check_unit9.py 17 --runlog` line: `RESULT (run logs): PASS`):

- run 1: bash `3.2.57`, load `3.49 3.69 3.41` at the start and `3.00 3.53 3.44` at the end.
- run 2: bash `5.3.9`, load `2.92 3.51 3.43` and `14.88 9.41 6.05` (another session's load rose during the run; below `20`
  throughout, and no time here is a measurement).
- run 3: the sealed copy (a fresh `file://` clone of `c3bc1b2` with this unit's files laid in, a folder named `sealed clone`), bash
  `3.2.57`, load `14.01 9.32 6.04` and `5.85 7.85 6.81`.

Each ended `c9-unit17: every capture = published (18)`. Before them, development passes on the same tree stopped at their own checks
and were fixed: the advisory check's format string, the counter's line read by the wrong pattern, the exercise's clause 6 pattern, the
start note's line naming the live anchor, and three lines that vary between runs (each poll's line, the access log's GET lines, the `delay=off`
race of the `202`'s body, the test's printed request count) marked run-variant. A last development pass (`NOPIN=1`) on the final
scripts wrote the published hashes; the three runs above each matched every one. The runs section was written after the three runs; no
hashed capture reads it. Flag 31, measured on the sealed copy after run 3: `chk17.py static` printed the same output (md5 `c1afe204`)
before and after a byte was appended to the copy's anchor `Dockerfile` (restored after), and a planted static line that opens the live
anchor's file ended with its FAIL line, exit `1`.

## RE-MEASURE (settled first, each by its capture)

1. `advisory` - the read filed for the batch day (`C9/_research/docs-2026-11-26/advisories/`, fetched `2026-11-26`) stands on the run's
   own date: every checksum in its list verified, Spring's index rows read, Tomcat's page equal to the probe's read, the second witness
   (`osv`) with no advisory. The coordinates the shipped tree names are printed off `after/`'s `BOOT-INF/lib` (Spring HATEOAS `3.1.4`,
   Tomcat `11.0.29`, `spring-web` `7.0.11`, Hibernate `7.4.15.Final`, the PostgreSQL driver `42.7.14`, H2 `2.5.250` among them); the
   lib's name lists are equal on `before` and `after/`: this unit adds no jar and makes no network act of its own. Verdict: no pin
   affected.
2. `before` (`21066`, H2) - `POST /api/v1/billing-runs` and `GET /api/v1/billing-runs/<uuid>` both answer `404` `application/problem+json`
   (no such route: the print decided, not a `405`); order 1 `200` `225` bytes; Ravi `200`; `31` request-mapping patterns, `0` with
   billing in the path; the committed spec by `ops9s3.py` on this `before`: `16` operations, `14` paths, `27247` bytes, md5 `ab65420b`;
   `BOOT-INF/lib` `164` names. Each a check against unit 16's hand-off, re-derived here (R.527).
3. `change` - the derived changed list holds four paths: `A` `BillingRuns.java`, `A` `BillingRunsTest.java`, `M` the committed spec, `M`
   the anchor's `README.md`. No pom differs, nothing under `tiffinbox-core/` or `tiffinbox-client/`, no key in `application.yaml`
   (`compression`, `forward-headers`, `hateoas`, `billing`, `pause`: `0` before and after). `startBillingRun` and `billingRun` each occur
   once among the mapped handlers; `IdempotencyKeyFilter.java` is byte-equal to `before`'s.
4. `census` - by unit 15's printed rule (copied off unit 16's receipts; `TiffinBoxErrors` excluded by the rule, the excluded line printed
   on both sides): `before` `15` controllers (`9` final default-run, `1` not final default-run - `OrderResources` -, `5` dev-only);
   `after/` `16` (`10` final default-run - `BillingRuns` the new row -, `1`, `5`).
5. `accept`, `poll` and `bills` (`21060`, H2, `delay=on`: the harness's pause on the command line) - the POST answers `202` with
   Tomcat's status line `HTTP/1.1 202` and no reason phrase, `Location` `http://127.0.0.1:<port>/api/v1/billing-runs/<uuid>` (absolute,
   the request's own host), `Retry-After: <masked>`, `application/json`, `76` bytes (curl's size and the saved file), the body
   `{id, state, bills}` with `state` `RUNNING` and `bills` `null`; following `Location` answers `200`. Polled by its condition, each poll
   sleeping the answer's own `Retry-After`: the states seen, in order, are `RUNNING` then `SUCCEEDED`; every `RUNNING` answer carried
   `Retry-After` and the first finished one did not; the alarm (a guard) was not hit. The final body's bills: `Meera=4500 Priya=3600
   Ravi=7200 Sunil=9000`, equal to V2's four rows through `monthlyBill()` (`mealsPerDay * pricePerMeal * 30`, printed). At `delay=off`
   the `202`'s own body read `RUNNING` with `Retry-After` present in this run (observed in the `202`'s body; a race, not a promise).
6. `restart` - the failure receipt: on JVM-1 (`21060`) a finished run (`SUCCEEDED`) and a run in the `RUNNING` state, then JVM-1
   stopped by `POST /shutdown`; on JVM-2 (`21065`, the same jar, a fresh start, H2 a fresh database) both old ids answer `404`
   `application/problem+json`, type `tag:tiffinbox.example,2026:billing-run-unknown`, the detail naming the id. The control: a new POST
   on JVM-2 answers `202`, and its status resource ends `SUCCEEDED` with the same four bills.
7. `double` (`delay=off`) - two key-less posts started two runs (`202` `202`, two distinct ids, each `200`); a POST with an
   `Idempotency-Key` and the same key again started two runs too (the route is not in the filter's table: `2` rows, `/customers` and
   `/api/v1/customers/{name}/pauses`). The key table is not read by this harness-free JVM; the filter's table is the witness.
8. `refuse` - an unknown UUID and a non-UUID id: `404`, the route's `billing-run-unknown`; `?x=1` on the POST and on the status resource:
   `400`, the route's `parameter-unknown`; `GET /api/v1/billing-runs` (no list route), `PUT` and `DELETE` on the status resource: `405`,
   Framework's, no type of TiffinBox's, `Allow` printed; a trailing slash: `404`, Boot's static-resource answer, no type.
9. `specwire` - the served entries: the POST documents `202` (with `Location` and `Retry-After` as headers) and `400`; the GET documents
   `200` (with `Retry-After`), `400` and `404`; one schema `BillingRun` with `id`, `state` (`RUNNING`, `SUCCEEDED`, `FAILED`) and `bills`
   (object or null). Against the wire, `5` gaps named (below).
10. `spec` - the committed file equals the served document (servers removed); `27247` to `30801` bytes, `132` lines added, `0` removed,
    five hunks; two paths added, one schema added, no old path or schema moved; operations `16` to `18`, paths `14` to `16`, the old
    operations' ids equal (R.535); the harness's counter refuses an empty spec (exit `1`); `OpenApiSpecTest` passes on the regenerated file. The
    client rebuilt on it: `.openapi-generator/FILES` `14` to `15` Java files - `13` differ in the date line only, `ApiApi` gains lines
    only, `BillingRun` is new, `0` moved; its test passes; `PATH_*` constants `16` to `18` (a check); `git status --short
    tiffinbox-client` `0` lines.
11. `moved` - unit 16's requests on `before` and `after/`, each its own JVM: `0` old lines moved; the named differences are the new
    status route (`404` with no route before, the route's own `404` after) and `GET /v3/api-docs.yaml` (the served document lists the
    added paths). The web jar gained the four `BillingRuns` classes and moved no shared entry's CRC.
12. The seven and the old surface (`13` requests) are byte for byte on both trees, each equal to the hash unit 16's values block gives - neither is a witness for the
    new routes (R.511): they send nothing to `/api/v1/billing-runs`.
13. `tests` - see the capture.
14. `exercise` - measured first on the route the exercise names, the broken copy's status resource: `RUNNING` answered `200`
    `application/json` with no `Retry-After`, and the finished run none either; the solution passes under bash and `zsh -f`.

## The change, file by file, and every README/Javadoc sentence it rewrote or noted (R.250/R.453)

- `tiffinbox-web/src/main/java/com/tiffinbox/web/BillingRuns.java` (new): one final controller and its store, the two routes, the
  refusals built from `ProblemDetail.forStatusAndDetail` as `OrderResources` builds them (no edit to `TiffinBoxErrors`). Its Javadoc says
  what it does, that the map is not kept across a restart, that it has no eviction, no cancel, no list, no key handling, and that who may start or
  read a run is Course 10's.
- `tiffinbox-web/src/test/java/com/tiffinbox/web/BillingRunsTest.java` (new): four tests, MockMvc, polled by condition.
- `tiffinbox-web/src/test/resources/openapi/tiffinbox.json`: regenerated by the receipt's own step.
- `c9-tiffinbox/README.md`: a *Course 9, unit 17* note under the unit 16 note (the cards' "a long-running bill (unit 17)" paid; the
  cards' counts true at unit 16) and the unit 17 card. The stale-sentence hunt (`git grep` over the anchor for `long-running`, `unit 17`,
  `billing`, `Retry-After`, `status resource`, `27,247`, `14 paths`, `operations 16`): the three old cards' "a long-running bill (unit
  17)" stay as history and are noted; "27,247", "14 paths" and "operations 16" stand in the unit 16 card as unit 16's counts and are
  noted; no Javadoc names another unit for a billing run.

## Which tree, which profile

H2 in memory by default, a fresh database per JVM: every capture but `verify`'s ITs. PostgreSQL `18.6` appears only in `verify` (the
anchor's five ITs, Testcontainers). The optional `bills-pg` leg was not captured (not said).

## Unit 17's section

- Spine [S3B :262-:265]: TiffinBox answers before the bills are made - `202`, `Location`, `Retry-After` (`accept`) - and keeps the run's state at that
  address (`poll`); the client polls by the header and stops when the run says it is done (`poll`: the states in order, the header
  gone at the end); here the harness's pause makes the run last long enough to be seen running, labelled `delay=on` on every capture
  that uses it. The state lives in the JVM: a restart, and the address answers a four oh four (`restart`) - which is why jobs kept across
  restarts belong to *Spring Batch & Scheduling* and *Messaging & Integration*.
- The failure receipt: `restart`'s four oh four on the old ids, with its control (a new run on JVM-2 accepted and finished).
- Hazards [S3B :274], each with its capture: `PENDING` is not a state this route ships (`change`, `poll`); `Location` absolute with the
  port, masked (`accept`); Tomcat's status line has no reason phrase (`accept`); `springdoc` would document the `202` as `200 */*` unless
  annotated - annotated here, and the served entry says `202` (`specwire`).

## The captures — what each one shows

The code panel: `BillingRuns.java` and `BillingRunsTest.java` whole (`change`); the `202`'s status line and headers, masked (`accept`);
the polls' states in order beside `Retry-After`'s presence (`poll`); the four bills beside V2's rows and `monthlyBill()` (`bills`); the
two JVMs of `restart`; the double post's runs (`double`); the refusal table (`refuse`); the census before and after (`census`); the
regenerated spec's two new paths and their spec-vs-wire gaps (`specwire`, `spec`); the client's per-file classification (`spec`).

The gaps `specwire` names (spec against wire): the schema marks no member required, the wire always sends `id`, `state` and `bills`;
`bills` is documented as object or null, the wire sends `null` until `SUCCEEDED`, and the spec cannot say which state carries which; the
`id` parameter is documented as a plain string, the ids are UUIDs and a non-UUID id is the route's own four oh four; `Retry-After` is
documented as a string header on the `202` and the `200`, the wire sends it only while `RUNNING` (the description says so, the schema
cannot); the method refusals (`PUT`, `DELETE`) are Framework's and not documented.

The access log beside curl: `accept`'s access log prints `87` bytes for the `202` whose body curl saved as `76` - Tomcat's `%b` counts
the chunked framing of an answer with no `Content-Length` (named, not a difference of bodies).

## Measured, not shipped

The harness's pause between customers (C1 (a)): the run flag `--tiffinbox.billing-runs.harness-pause-ms` on the command line of every
`delay=on` start, printed there; the shipped default is none, and no `application.yaml` key holds it. The slice need: measured, none
(`TiffinBoxWebTest` already mocks `CustomerRepository`; the slice file byte-equal, its tests as before).

## Refused, named

The prose gate (`harness/s917.py`, unit 16's `s916.py` with its family made `XU17`) refuses each of these, planted and caught (the
plants in `s917.py`'s self-test and in `chk17.py plants`; the readings the README keeps are the near misses beside them in `s917.py`):

```
The job survives a restart.          The run is saved.                The map is durable.          Billing is slow.
TiffinBox's billing takes longer than one request should.             Try again in a second.       Two of four done.
The run starts pending.              The status resource tells the client how long to wait.        The double POST is safe.
It is safe to retry.                 TiffinBox bills once.            The route is idempotent.     Accepted means done.
Polling is cheap.                    REST requires a status resource. Spring does it.              The run is lost.
The old address is wrong.            Location is localhost.           MockMvc's Location is the wire's.   It answers 202.
```

## The repository, and the network

The advisory read is the probe's, filed `2026-11-26` and read here on the same date (S9.36); this unit adds no jar, edits no pom, and
makes no network act of its own. Every build is offline (`mvn -o`) from a copy of the Section 3 seed (`11238` files), `0` downloads.

## The folders, the harness and the ports

`README.md`, `after/`, `before` (the link), `exercise/` (`README.md`, `SOLUTION.md`, `apply.sh`, `break.sh`, `check.sh`), `harness/`
(`chk17.py`, `dur9.py` and `ops9s3.py` copied byte-equal, `s917.py`, `tree17.py`; no Java: C1 (a)), `receipts.md5`, `receipts.sh`.
`chk17.py` is written on `chk16.py`'s shared machinery (its helpers, `static`, `gloss`, `hook`, `exq`, `interleaved`, `values`,
`plants`), its capture checks new for this unit's captures. Not used: `walk.py`, `follow.py`, `seal9.py`, `cdp.mjs`, `cdp9.mjs`,
`loc9.py`, units 14-16's harness classes; the probe's captures and `ProbeJobsAndBills.java` are read, not copied. Ports: `21060` after/,
`21065` JVM-2 of `restart`, `21066` before, `21068` the exercise; `21061`-`21064`, `21067` and `21069` never bound; `21280`-`21284` during
`verify` only. No Chrome.

## Masks, filters and hygiene

One self-tested log mask: run figures, ISO times, folders, the home, a band port (`127.0.0.1:<port>`), the run's UUID, `Retry-After`'s
value. `Date` is masked in the header prints. Every JVM is stopped by `POST /shutdown` or by its recorded pid; every container `rm -fv`;
images and volumes equal at the end.

## Interrupted

No SIGINT point was driven in this unit's runs (as units 13, 14 and 16: not done, said here).

## Planted faults — each caught

`harness/chk17.py plants` runs at the end of every run: each planted fault is a copy of this run's capture with one change (a reason
phrase typed on the status line, `Location` typed `localhost`, `PENDING` typed as observed, the states in the wrong order, `Retry-After`
typed on the terminal poll, a bill one off, the bills in another order, the old id typed `200`, the control left out, JVM-2 on JVM-1's
port, one run typed for two posts, the route's type dropped, the census one off, an `operationId` renumbered, an empty spec accepted,
the `202`'s headers typed absent, the seven one character off, a skipped test), and each ends with its FAIL line, exit `1`, no
traceback; the prose plants are refused by `s917.py`. The static plants are `chk17.py static`'s own checks.

## What differed from the brief

- C1/C2 (OPEN, picked (a)): the harness's pause is a typed setting with no default value in any file - `@Value("${tiffinbox.billing-runs.harness-pause-ms:0}")`
  in `BillingRuns` - given only as a run flag; so no harness class exists (`harness/` holds no Java). Argued: one mechanism for the
  receipts and the exercise, a learner runs it with one flag and no `javac`; it is not a public request parameter (the probe's
  `?msPerCustomer=` form avoided), so the route's unknown-parameter refusal stays whole. The cost, for RED: pause code exists in the jar
  (a sleep guarded by a value that is zero unless a flag says otherwise).
- C3: the bills come from `CustomerRepository.findAll()` and `Customer.monthlyBill()`; no core method, no bill table; the read is a fresh
  JVM's, the cache's first. In `BillingRunsTest` (one shared context) other test classes add customers, so the run bills them too: the
  test checks the four seed values and that the bills equal every customer's `monthlyBill()` (measured on the first full build, which
  failed on an exact four-entry assert).
- C4 (OPEN, picked (a)): the route is left out of `GUARDED`; `IdempotencyKeyFilter.java` byte-equal; a key is inert here; two posts start
  two runs. A billing run that bills twice is what (a) does (named).
- C5 (OPEN, picked annotate): `@ApiResponse` with `@Header`s on both handlers; the served entry says `202`; the remaining gaps named.
- C6 (OPEN): the body is `{id, state, bills}`; no `done`/`total` count is shipped; the states are `RUNNING`, `SUCCEEDED`, `FAILED` -
  no `PENDING` state exists in the code (a run is `RUNNING` from the moment it is accepted), so none can be observed; `bills` is `null`
  until `SUCCEEDED`. `Retry-After` follows one rule in both handlers: sent when the answer's state is `RUNNING`.
- C7 (OPEN): `BillingRuns`, final (nothing proxies it), handlers `startBillingRun` and `billingRun`, unique (static and the spec).
- C8 (OPEN): a `ConcurrentHashMap`, a virtual thread per run, no eviction (said in the Javadoc and the card).
- C9: the slice need measured: none. The generated client: `FILES` `14` to `15`, classified per file.
- C10: `BillingRunsTest` has `4` methods, polled by condition with the answer's own `Retry-After`; no typed sleep; the guard is a
  deadline, not a measurement.
- C11: the titles read off `java9_series.py` and the roadmap, asserted equal at the start of each run.
- C12: the advisory read stands on its own date (`2026-11-26`).
- C13: the cap - three runs of record were made (see Runs of record); SIGINT, the sealed run's extra variants, `bills-pg` and the S9.14
  plant slot were not done.
- C14: the title for search, `55` characters, printed only.
- C15: `Retry-After` stays in code spans and capture blocks; its value is masked in every print.
- C16: the hook is quoted byte for byte; it is refused by the prose gate as a spoken line (`at once`, R.388 and S9S1's time-meaning
  family), so it stands in a fenced block in this README and is handed to RED and the scripts stage.
- Flag 2: the changed set is the four derived paths. Flag 11: PostgreSQL only in `verify`. Flag 13: `moved`'s list is unit 16's, with
  unit 16's route and the new status route added. Flag 15: the web-only form and the twin print the same web counts. Flag 17: the
  exercise's refused variants run in run 1 only (said). Flag 21 and 31: see For RED. Flag 28: the receipt's own count (`18` captures).
- The access log's bytes and curl's differ by the chunked framing (named above); the brief expected the three equal.
- The published hashes were written by a development pass (`NOPIN=1`) on the final scripts; the three runs of record each matched
  every one. No SIGINT point was driven.

## For RED

- C1/C2: the pause as a typed setting in the shipped class (pause code in the jar, off by default) against a harness-joined bean.
- C4: no key handling on a POST that starts a billing run - two posts, two runs; a guarded row is the other pick (a shipped filter's
  table edited).
- C5: annotated; the five named gaps (no required members, `bills` nullable by state, `id` not a UUID format, `Retry-After`'s presence
  by state, the undocumented `405`s).
- C6: no `PENDING` state at all (the brief expected one that is never observed); no count shipped; `bills: null` until done.
- C7: `BillingRuns` final; the census's final default-run count moves `9` to `10`.
- C8: no eviction - a long-lived JVM keeps every run.
- The refusal forms: the non-UUID id is the route's `404` (the id is a plain string), the `405`s Framework's, the trailing slash Boot's.
- The hook is refused as a spoken line by the prose gate (`at once`): the scripts stage's call.
- The test's bill assert: the run bills every customer the shared test context holds (other test classes add some).
- Flag 31 (stale cross-reference): `chk17.py static` reads only `after/`, `before` and `git show c3bc1b2:…`; its own check refuses a
  static source that names the live anchor's path (a literal path; a name built from pieces is not caught by it - for RED); the receipts and the exercise name it only in the start note, the end check, the H2-file
  sweep and the client's `git status`. The same class in the frozen units: unit 15's `chk15.py static` (`git diff --stat f3724ca` over
  the working tree, `:399`-`:400`) and unit 16's `chk16.py static` (`git diff --stat c7e5118 -- '*pom.xml'`, `:570`-`:572`) compare the
  live working tree with a pinned hash; unit 16's passes after this unit only because this unit edits no pom; filed for the orchestrator,
  not edited.
- U03's `instance` view greps the live `src/main` for `ProblemDetail.forStatus`: `before` and `after/` counts printed in `change` (the
  new controller adds one call site).

## The ledger rows this unit pays

`TRACK-ROADMAP.md:389` (`17 Bulk Operations and 202 Accepted - a bulk billing request with a status resource to poll`); C9-11 at this
anchor change (the seven, the old surface, the spec's old operations, the tests). The ledger is not edited here (a note for the
orchestrator).

## The values the video may say

Each from this unit's own captures, 3/3, H2 unless named; no `done` count, no time, no `Retry-After` value: the status `202` and
`Location` on the POST (`accept`); the states in order, `RUNNING` then `SUCCEEDED` (`poll`, `delay=on`, the harness's pause labelled);
the four bills `4500`, `3600`, `7200`, `9000` for Meera, Priya, Ravi and Sunil (`bills`); the old address's four oh four on a new JVM
and the control's `202` (`restart`); two key-less posts, two runs (`double`); operations `16` to `18`, paths `14` to `16` (`spec`);
the web module's tests `67` to `71` (`tests`).

<!-- values: begin -->
```
advisory: adv_rows=25
before: before_billing=404/404 before_ops=16/14 before_lib=164 before_mappings=31
change: changed=4
census: census_before=15/9/1/5 census_after=16/10/1/5
accept: accept=202,RUNNING
poll: poll=RUNNING,SUCCEEDED
bills: bills=Meera=4500,Priya=3600,Ravi=7200,Sunil=9000
restart: restart=404,control=202
double: double=two_runs,key_inert
refuse: refusals=8 notype=DELETE_on_the_status_resource,PUT_on_the_status_resource,a_trailing_slash,no_list_route
specwire: gaps=5
spec: spec=27247->30801,+132/-0 spec_md5=3cda0901 ops=16->18 paths=14->16 client=14->15,date=13,added_lines=1,new=1 path_consts=16->18
moved: moved=0 named=2
seven: seven=466c20ed
surface: surface=316a9637
tests: web_tests=71 web_before=67 k=4 its=14
exercise: ex_broken=200,no_retry_after
inert:
plants: plants=27
build: seed_files=11238 seed_bytes=888071893 central_only=0
```
<!-- values: end -->
