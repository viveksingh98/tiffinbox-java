# Course 9 · Unit 24 — Retiring an Endpoint Without Breaking Anyone

Section 4's sixth and last unit, Course 9's nineteenth change to the anchor, and the course's one named break: the old
`GET /customers/{name}` stops answering `200`. It answers `410` Gone, `application/problem+json`, the type
`tag:tiffinbox.example,2026:route-retired`, and a `Link` naming its successor, `GET /api/v1/customers/{name}`, for the name asked,
with `rel="successor-version"`. Every number below was printed by this folder's `receipts.sh`, three runs of record, on H2 in memory;
the probe's and BLUE's rows (`c5406fc`, U18's tree) are named as theirs where they are quoted, never as this unit's.

## Runs of record

Three runs, each launched below load1 `20` with the load printed on its first line, each ending `every capture = published (21)`, and
`check_unit9.py 24 --runlog` read on each run log (its unit gate exits `2` until this unit's script exists, as expected; the run-log
line is the one read):

- run 1: bash `3.2.57`, `RUNNO=1 ./receipts.sh` in this folder (`mvn verify` with the five ITs, and the exercise's five refused
  variants, run here only).
- run 2: bash `5.3.9`, `RUNNO=2 bash receipts.sh` in this folder.
- run 3: bash `3.2.57`, `RUNNO=3 ./receipts.sh` in a sealed clone of the repository in a folder whose path holds a space (R.129),
  cloned from the local repository at `1473426` with this unit's files and the changed anchor laid over it, and the clone's own
  `c9-tiffinbox` folder moved aside for the whole run: the static check's run there is the third, with no anchor beside it.

The pins in `receipts.md5` were taken from a development run (`NOPIN=1`) of this same script before run 1; the three runs then had to
print the same hashes. All three ran on 2026-11-28, the evidence's start day (`USTART`, read off `.harness/ustart`, never typed into the
script). Each run's date and load are its log's first two lines.

## RE-MEASURE (settled first, each by its capture)

- **1** `advisory` — the S9.36 read was made on `2026-11-28`, the evidence's start day, as its first act (the orchestrator delegated
  it): `_research/docs-2026-11-28/advisories-u24/`, `13` files, every line of its `MD5SUMS.txt` verified by the receipt. Tomcat's page is
  the earlier reads byte for byte (`a1a756d9…`); Spring's index holds the same `25` ids as the read of `2026-11-27`. OSV, over the `167`
  jars of `before`'s `BOOT-INF/lib` resolved to coordinates and the client's generator (`168` queries): `1` hit, `opentelemetry-api`
  `1.62.0`, `GHSA-ccrj-gw8r-854m` (moderate; the W3C `tracestate` parser; fixed in `1.67.0`). No class of any other shipped jar names
  `W3CTraceContextPropagator` (`0` of `166`), so nothing on this tree calls the method the advisory names, and the jar is not one this
  unit moves. The verdict filed with the read: no pin this unit moves is affected; the evidence went on, the advisory carried for the
  orchestrator (a bump is a dependency change, not this unit's). The read also filed the texts of `RFC 8594`, `RFC 9745`, `RFC 8288` and
  `RFC 5829` and the IANA link-relations registry (its `successor-version` row present); this README says what the headers do only as
  the captures print it.
- **2** `before` — a link, `../c9-unit23/after`, whose own text is `../c9-unit22/after`: two hops, the tree `128` files `b8956a6e…` =
  U23's after-tree line. Re-derived on it (R.527), each equal to U23's value: `BOOT-INF/lib` `167`, the committed spec `36,164` B
  `aa8cb98f…` (`21` operations, `19` paths), the census `17/11/1/5`, the web module's tests `88` and the client's `5` at `mvn package`,
  `5` IT classes.
- **3** `count` — the gate. On a fresh `before` JVM (`21136`), six requests sent by the receipt: `GET /customers/Ravi` three times,
  `GET /customers/Nobody` once, `GET /api/v1/customers/Ravi` twice. `http_server_requests_seconds_count` under
  `uri="/customers/{name}"`: `200` `×3` and `404` `×1`, equal to what was sent and to the access log; the successor's row `200` `×2`.
  U23's `old=1` was one request of its own run. The `_count` row counts what reached the route, here the receipt's own requests; it
  cannot say whether any client still calls it, and no capture of this unit can. "Retire when the row stays at none over a window" is
  the unit's rule, not a measurement. Inside `src/main` no code calls the old route (a classified grep: route mappings, comments, the
  documentation annotations, links under `/api/v1/`); the callers inside the tree are the tests, the need-measure's red list.
- **4** `announce` — the timeline's first step, on a scratch jar (`before` + `harness/mirror/announce.diff`, `21135`), never said of
  the shipped tree: `GET /customers/Ravi` answers `200` `application/json` with `Deprecation`, `Sunset` and
  `Link: </api/v1/customers/Ravi>; rel="successor-version"`, its body the successor's `67` bytes on the same JVM. Python converted both
  dates to epoch values and printed that `Deprecation` comes before `Sunset` (R.557); the values are masked on every capture.
- **5** `remove` — the loser, the harness's copy of the bare removal (`before` + `harness/mirror/remove.diff`, `21136`):
  `GET /customers/Ravi` answers `404` `application/problem+json`, detail `No static resource customers/Ravi.`, and
  `GET /customers/typo-xyz` answers the same `404` but for the name - an old client cannot tell a retired route from a typo. Both are
  counted under `uri="/**"`, the pattern that catches every path no route matched.
- **6** `compat` — the compat guard, run first as a development step on a scratch copy (`harness/mirror/compat0.diff`, before any
  anchor path was written), then in every run on `after`'s jar: every request class sent to `before` (`21136`) and to `after`
  (`21130`). The seven are equal, the expected md5 - not a witness for the retirement: they send no read of the old route. The old
  surface moved by exactly one line, its one request on this route: `GET /customers/Ravi`, `200` to `410`. The `/api/v1/` census (`11`
  requests) is identical. Of the `14` reach requests, the ones that moved are exactly the `GET` and `HEAD` requests whose path is
  `/customers/<one segment>`: `Ravi`, `Nobody`, `HEAD Ravi`, `new` asked for JSON (it is the template with the name `new`),
  `Meera%20Joshi`, `a%3Eb` and `x%0D%0Ay`, each now the same `410`. Unmoved: `OPTIONS` (`Allow: GET,HEAD,OPTIONS`), `PUT`, `DELETE`
  and `POST` (`405`, `Allow: GET`), `GET /customers/new` asked for HTML (the page's own mapping), and the successor. The HOLD rule did
  not fire. `names`: the `Link` carries the name encoded as one path segment, as the capture shows - `Meera%20Joshi`, `a%3Eb` and
  `x%0D%0Ay` (the encoded CR LF stays percent-encoded in the header, and the answer is the `410`). On the `cap=5` start (the harness's
  capacity flag) the limiter refuses the sixth `/api/v1/` read with `429` and the old route still answers `410` (on `before`, `200`):
  the limiter does not reach it. U20's filter adds no `ETag` to the `410`.
- **7** `gone` — on `after` (`21130`): `GET /customers/Ravi` answers `410`, `application/problem+json`, members `detail`, `instance`,
  `status`, `title` and `type`, the type equal to the constant `ROUTE_RETIRED`, the title "Route retired", the `Link` for Ravi; no
  `Deprecation` and no `Sunset` header (C1 (a); the announce copy's carry both, the control). `HEAD` answers `410`, no body.
  `GET /customers/Nobody` answers the same `410`: the route no longer says that nobody has a name. The successor answers `200`, the same
  `67` bytes. The scrape counts the `410` under `uri="/customers/{name}"`, `CLIENT_ERROR`: a handler's own `410` keeps its route's
  template. *Versioning Strategies*, called back on its own tree's line: there a retired version answers `400` "Invalid API version"
  with `rel="deprecation"` stamps; here a retired route answers `410` with `rel="successor-version"`.
- **8** `tests` — the need-measure (`after`'s main sources with `before`'s tests, unedited): `7` red tests in `6` classes -
  `ApiVersionTest.theOldAddressAnswersAsBefore`, `CustomerPatchesTest.aRenameLeavesNothingAtTheOldAddress`,
  `CustomerReadsTest.thePublicReadAnswersWhatTheOldAddressAnswers`, `OpenApiSpecTest.theServedDocumentIsTheCommittedOne`,
  `RateLimitFilterTest.aRouteOutsideTheApiIsNeverRefused`, `TiffinBoxWebTest.aNameNobodyHasIsAProblemDetail` and
  `TiffinBoxWebTest.aNameNobodyHasIsTyped`. The brief's number is the probe's, on `c5406fc`, before U19 added
  `RateLimitFilterTest` (D1). Six of the seven are edited in this commit (the table below); `OpenApiSpecTest` is not edited and goes
  green on the regenerated file. `after`'s own build: web `93` (`88` and `RetiredRouteTest`'s `5`), client `5`, failures `0`, skipped
  `0`, `InputHardeningTest` `3` untouched, four reactor modules `SUCCESS`, no refusal line of the limiter outside
  `RateLimitFilterTest`'s own context. With `before`'s `TiffinBoxServer.java` put back (the handler removed), four of
  `RetiredRouteTest`'s five methods are red; the successor's method stays green. `mvn verify` (run 1): the five ITs, `14` tests, green.
- **9** `spec` and `client` — the document `after` serves (`GET /v3/api-docs`, `servers` removed, `json.dump(indent=2,
  ensure_ascii=False)` and a newline) is the regenerated committed file byte for byte: `35,935` B (`36,164` B before). The operations,
  the paths and the `operationId`s are kept (`21`, `19`); one operation moved, `GET /customers/{name}` (`customer`): its responses
  `200` and `404` became one `410`, and it is marked `deprecated`. The other twenty are byte-equal as JSON, and the components are
  unmoved. Spec against wire (R.528): the `410`, `application/problem+json`, the `ProblemDetail` schema, and the example equal to the
  answer this route sends. The generated client, built and tested on both specs: on `before`'s, `CustomersApi.customer` returns
  `ResponseEntity<Customer>`; on the regenerated one it keeps the method, returns `ResponseEntity<Void>` and is marked `@Deprecated`; its `5` tests are green on
  both, and its test sources name neither the old path nor `customer(` (the grep's planted control line counted `1`).
- **10** `census`, `api`, `moved`, `seven`, `surface`, `inert` (R.511, each named by what it witnesses) — the census `17/11/1/5` on both
  trees: a handler body adds no controller. `api`: the `11` `/api/v1/` requests identical - the successor's side. `moved`: the web jar
  `0` added, `0` removed, `4` moved - `TiffinBoxServer.class`, `TiffinBoxErrors.class`, and `CustomerNotFound.class` and
  `CustomerReads.class`, whose sources moved only in a comment (their line numbers moved); the core jar `0` moved; the client jar `1` moved, the generated `CustomersApi`; `BOOT-INF/lib`
  `167` = `167`. `seven` - not a witness for the retirement. `surface` - the witness: the one moved block, whole. `inert`: no request of
  this unit carried an `Idempotency-Key` or a body.
- **11** `exercise` — measured before it was written: the broken copy (`break.sh`, the announce edit on a copy of `after`) answers
  `200` with the three headers and fails clause (1); the solved copy answers `410` `route-retired` and passes, under bash and `zsh -f`,
  the successor's `67` bytes unchanged in both; five refused variants each fail (run 1).
- **12** `title` — `Retiring a Spring Boot Endpoint: Deprecation and 410 Gone`, `57` characters by `len()`; no clash in the registries.

The table of edits (the evidence of "edited and named"):

| method | class | before | after | why |
|---|---|---|---|---|
| `aNameNobodyHasIsAProblemDetail` | `TiffinBoxWebTest` | `GET /customers/Nobody` → `404`, the problem names him | the same, asked on `/api/v1/customers/{name}` | it guards `TiffinBoxErrors`' not-found problem, which the successor still answers |
| `aNameNobodyHasIsTyped` | `TiffinBoxWebTest` | the old route's `404` carries `customer-not-found` | the same, on the successor | the not-found type, unit 09's |
| `theOldAddressAnswersAsBefore` | `ApiVersionTest` | the old route `200`, the same body | the old route `410`; the versioned half unchanged | the retirement, beside the version |
| `thePublicReadAnswersWhatTheOldAddressAnswers` | `CustomerReadsTest` | the public body = the old body | the public read `200` with the name, the old `410` | the body equality has no old body left to equal |
| `aRenameLeavesNothingAtTheOldAddress` | `CustomerPatchesTest` | four reads of the old route | the same reads on the public read | it guards the rename's cache eviction |
| `aRouteOutsideTheApiIsNeverRefused` | `RateLimitFilterTest` | the old route `200` after the refusal | the old route `410` after the refusal | "never refused" kept: not `429` |

## The change, file by file, and every README/Javadoc sentence it rewrote or noted (R.250/R.453)

Derived by the receipt (`after/` against `before/`, file by file): 12 paths, 11 moved and 1 added, no pom, no `application*.yaml`, no
`tiffinbox-core` or `tiffinbox-client` file.

- `TiffinBoxServer.java`: the method `customer(@PathVariable String name)` keeps its mapping and its name (so its `operationId`) and
  returns the `410` problem with the `Link` (`UriUtils.encodePathSegment`); its documentation is one `410` response with an example
  and `@Operation(deprecated = true)`; three imports added (`Operation`, `HttpHeaders`, `UriUtils`).
- `TiffinBoxErrors.java`: `ROUTE_RETIRED` beside `CUSTOMER_NOT_FOUND` (an addition only).
- `CustomerNotFound.java`, `CustomerReads.java`: one dated *Course 9, unit 24* sentence each; `CustomerReads.one(String)` untouched.
- The six edited test methods (the table) and the new `RetiredRouteTest` (MockMvc over the whole application on H2, no socket, five
  methods, every header name and status from Spring's constants).
- `tiffinbox.json`: regenerated; only the retired route's entry moves.
- `c9-tiffinbox/README.md`: the unit 24 card; a dated *Course 9, unit 24* note under unit 22's; the unit 09 note's "the old `GET
  /customers/{name}` included" now says until unit 24; unit 12's "nothing is deprecated or retired here" rewritten to say that no route
  was retired by unit 12, unit 24 retiring this one; unit 20's "unchanged and untagged" followed by a dated note. The older cards'
  sentences about the old route measured their own trees and are left; the dated note at the top says so (`stale`).

## Which tree, which profile

`before` is U22's frozen tree through U23's link; `after/` is the changed anchor, frozen. Spring Boot `4.1.3`, Spring Framework `7.0.11`,
Tomcat `11.0.29`, Jackson `3.1.8`, Micrometer `1.17.3`, `springdoc` `3.2.1` and the `OpenAPI` generator `7.27.0`, as the jars and the
parent POM hold them. Every JVM runs on H2 in memory; there is no "dev" leg, no PostgreSQL, no Redis and no container but the ITs' Testcontainers in
`mvn verify` (run 1).

## Unit 24's section

The hook, as the brief has it (never edited; its "six" is the probe's number - D1):

```
Retire one route and six tests go red. The client's test stays green — it never asked that route.
```

A sunset date: the date an endpoint stops answering.

The exercise's line is in `exercise/README.md`, byte for byte. The title for search:
`Retiring a Spring Boot Endpoint: Deprecation and 410 Gone`. Callbacks, by title only: *Versioning Strategies* (a retired version),
*Observability for APIs* (the route's `_count` row), *Code Generation From the Contract* (the client), and Course 6's not-found problem
detail. The dates are masked on screen and never spoken.

## The captures — what each one shows

`advisory` the start day's read · `before` the counters on `before` · `census` both trees' controllers · `count` the gate's rows ·
`announce` the timeline's first step · `remove` the loser · `compat` the guard · `gone` the shipped `410` · `tests` the red list, the
suite, the plant, `verify` · `spec` the served document against the file, the one moved operation · `client` both specs · `api`,
`seven`, `surface`, `moved`, `inert` · `change` the derived paths and diffs · `stale` the sentences and their dispositions · `frozen`
the older receipts' lines, printed · `exercise` · `title`. Each is hashed in `receipts.md5`; lines that start `  ~` (the run's date,
`verify`'s lines, the refused variants) are left out of the hash.

## Measured, not shipped

The timeline's first step (`harness/mirror/announce.diff` on a copy of `before`, `21135`), the harness's copy of the bare removal
(`harness/mirror/remove.diff`, `21136`), the compat guard's development copy (`harness/mirror/compat0.diff`), and the exercise's broken
copy (`21138`). A status or a header seen on any of them is never said of the shipped tree.

## Refused, named

- The anchor jumps to the timeline's last step on the evidence's day; the `Sunset` value the first step sends is a date after it. No
  commit of the course ships the first step, so "with its timeline said" (S9.2) is met by this unit's words and a copy, not by a
  shipped state (D4). No sentence here claims a shipped announce step.
- S9.2's carve-out ("a retirement is U24's, with its timeline said") is what lets this route break; S9.37 is named only for the
  successor, which is unmoved (D8).
- The gate counts what was sent (D9).
- The frozen folders' sentences that the retirement makes false are named, never edited: `../c9-unit12/README.md` says `/customers/Ravi`
  still answers `200` on its own tree.
- F-31 (carried, flag 31's class): the frozen receipts of U10, U13 and U15 read the live anchor's poms and diff it against old commits;
  U24's anchor change does not touch a pom, so none of the three reads moved; it DOES move the committed spec and the old route, so a
  re-run of any frozen check that pins those would fail on U24's tree - they are fixed before any receipts re-run (the orchestrator's),
  never by U24. None was re-run here (`frozen` prints the lines).
- The standards texts are filed (`2026-11-28`), and this README quotes no requirement from them; what the headers do here is what the
  captures print.

## The repository, and the network

One commit for `c9-unit24/` and the anchor's changed paths. The network was used twice: the advisory read and the standards texts at the start (the
orchestrator delegated them as the evidence's first step; filed under `_research/docs-2026-11-28/advisories-u24/`) and the final `git
push`. Every build ran offline (`mvn -o`, Maven's default settings, a copy of the seed `m2-seed-c9-s4`), with no `Downloading from`
line.

## The folders, the harness and the ports

`harness/`: `chk24.py` (the checks), `s924.py` (the prose gate: U23's `s923.py` with `XU24C9`), `tree24.py`, `dur9.py`, `ops9s3.py`,
`norm.py` and `scrape.py` (U23's, byte for byte), and `mirror/` (the three named diffs). `exercise/`: `README.md`, `SOLUTION.md`,
`break.sh`, `apply.sh`, `check.sh`. Ports: `21130` `after`, `21135` the announce copy, `21136` `before` then the loser's copy, `21138`
the exercise; `21131`-`21134`, `21137` and `21139` never bound; `21280`-`21284` the ITs in `verify`.

## Masks, filters and hygiene

One log mask, self-tested: times, ports, folders, uuids, HTTP dates, the `Deprecation` epoch, the `Sunset` date and every printed epoch.
The scrape reader prints `_count` rows only; no `_sum`, `_max` or bucket value is printed, hashed or said. Every JVM is stopped by its
own token or its recorded pid; at the end no JVM, no listener on the band, the images and volumes as at the start.

## Interrupted

Three SIGINT points, each by a driver that starts `bash receipts.sh` under `perl` with SIGINT at its default, holds until its
condition and signals the receipt's own pid (never a name); each ended with exit `130`, no java of this unit left, `21130`-`21139` and
`21280`-`21284` free, no `.r-lock`, no `.r-*.new`, no `exercise/.work`, only `open-webui` running (2026-11-28, before the runs of
record):

- mid-build: the scratch jar of the timeline's first step being built.
- mid-compat: `before`'s compat JVM (`21136`) listening.
- mid-exercise: the exercise's JVM (`21138`) listening.

Mid-`verify` was not run (the receipt runs `verify` in run 1 only; the cap went to the runs of record): not captured, not said.

## Planted faults — each caught

The plants run at the end of every run on copies of that run's captures (`harness/chk24.py plants`), each ending with its own FAIL line,
exit `1`, no traceback: the read dated before the start, a run date outside the two allowed dates, the OSV advisory dropped,
`BOOT-INF/lib` typed `166`, the web count typed `87`, `before`'s link retargeted, a controller added, the old route's count one off, a
`_sum` line printed, the actuator's row left in the count, the probe's inverted pair of dates, an epoch typed, the typo's detail
altered, a moved line outside the retired route's class (the HOLD line fires), the seven one byte off, the surface's moved list emptied, an `OPTIONS` line moved (HOLD), the type altered, `application/json` on the `410`, `Deprecation` on the `410`, the
`Link` a template, the successor's body altered, a red method not in the table, the table one method down, a typed web count, the
handler removed with `RetiredRouteTest` green, another moved operation, the `410`'s example altered, the old spec restored, a client
test naming the old route, the grep's control not counted, a jar added, a probe word in the shipped card, the stale sentence left, a
pom moved, the solution failing, the broken copy passing, a title over `60`, a per-JVM request count above the cap, a refusal line at
the default capacity, four unparseable listings, the hook one word changed, the exercise's word count, a duplicate gloss line, a typed
`USTART`. Static plants: a read of the live anchor and the same path from two pieces (exit `1`), and a GNU-only `sed` line counted by
the receipt's own grep.

## What differed from the brief

Picked by the orchestrator: C1-C11 and C-gloss as RECOMMENDED (a), and C10's reads delegated to this evidence's first step.

- **The red count (D1):** `7` red tests in `6` classes on this tree, not the brief's `6` in `5` (the probe's, on `c5406fc`). The
  seventh is `RateLimitFilterTest.aRouteOutsideTheApiIsNeverRefused`, U19's. Edited: six methods in five classes; `OpenApiSpecTest` is green
  on the regenerated file. The hook keeps its "six" (for RED).
- **The gloss (C-gloss):** the bound words `A sunset: …` are refused by `dur9.py` (its `Sunset:` header form reads the gloss's
  colon as the header; `ALLOW = {}` and `dur9.py` are never edited), so the gloss line is "A sunset date: the date an endpoint stops
  answering." (for RED).
- **C10:** the orchestrator delegated the advisory read and the standards texts to this evidence's first step, dated `2026-11-28`, filed under
  `_research/docs-2026-11-28/advisories-u24/` - option (a)'s folder, the one write outside the repository besides `FACTORY-NEXT.md`.
  The read found one OSV advisory on a shipped jar the unit does not move (`opentelemetry-api` `1.62.0`); carried, not stopped on.
- **D2, D6:** every probe number the brief quotes was re-measured on this tree (`compat`, `remove`, `tests`).
- **D3:** "the client's test stays green" holds: 5 green on both specs, its tests name neither the old path nor `customer(`; the
  generated `CustomersApi.customer` survives with `ResponseEntity<Void>` where it returned `ResponseEntity<Customer>`.
- **D5, C2:** the `Link` is built from the name encoded as one path segment; the awkward names' headers are printed (`compat`).
- **D7, C5:** the annotations document the one `410` the route sends and mark it `deprecated`.
- **D10:** `20` of `21` operations are byte-equal; the one that moved is the retired route's, by design.
- **D11:** the exercise's line carries `200` and `410` as digits; the prose gate refuses them outside code spans (printed on the spoken
  lines' run); the brief's words are not edited (for RED).
- **D12:** the moved reach lines are exactly the `GET`/`HEAD` requests on `/customers/<one segment>`, `GET /customers/new` asked for
  JSON among them; the HTML one is unmoved.
- **D13:** the older README cards' sentences about the old route are left with a dated note at the top (they measured their own trees).
- **D16:** the title is 57 characters; `SEARCH_TITLES["24"]` still does not exist (the copy step's).
- **D17 / F-31:** no frozen receipt was re-run; the lines are printed (`frozen`).
- **The IT count:** five IT classes are counted on `before` from the sources; the 14 IT methods are `verify`'s count (run 1).
- **Shapes of this harness:** the receipt is smaller than U22's and U23's (no PostgreSQL, no scrape families, no harness route); the
  compat guard's development step ran as a scratch script before any anchor path was written, its result (the seven equal, the surface's
  one moved line, only `GET`/`HEAD` on `/customers/<segment>` moved in the reach) recorded in `FACTORY-NEXT.md` before the anchor
  write.
- **Runs re-run:** a first run 1 passed (`08:15`); its run 2 stopped at the values check, because the exercise's value counted the
  refused variants, which run in run 1 only. The value now names the shells instead; the pin of `chk24.py` moved with it, and all
  three runs of record were run again on the changed files.
- **SIGINT:** three points ran (build, compat, exercise); mid-`verify` was dropped (see "Interrupted").

## For RED

- The hook's "six" (D1): the tree has seven red tests in six classes; the hook voices a number the anchor no longer has.
- The exercise's digits `200` and `410` outside a code span (D11).
- D4: the shipped tree jumps from `200` to the timeline's last step; its first step is a copy's.
- D5: the `Link`'s encoding, as printed for a space, a `>` and an encoded CR LF.
- D8: S9.2's carve-out, not S9.37, lets this route break.
- D9: the gate counts only the receipt's requests.
- The gloss's words (`A sunset date: …`, and `dur9.py`'s refusal of `A sunset: …`).
- F-31: the frozen receipts that pin the spec or curl the old route would fail on this tree if re-run.
- The advisory hit on `opentelemetry-api` `1.62.0` (no caller of the method on this tree).
- `CustomersApi.customer` now returns `ResponseEntity<Void>`: a client that called it compiles and meets the `410` at run time.

## The ledger rows this unit pays

C9-11 ("every anchor change": the seven, the old surface, the spec's old operations, the tests per runner, the census - all above). No
C9-24 row (not added by BLUE - D14); no ledger edit; no new rule number.

## The values the video may say

Each value below was printed 3/3 across the runs of record, on H2. The dates are not values the video says.

<!-- values: begin -->
```
advisory: read=2026-11-28 osv_hits=1 rfcs=4
before: web=88 client=5 it_classes=5 lib=167 spec=36164 census=17/11/1/5
census: census=17/11/1/5
count: old_200=3 old_404=1 succ_200=2 calls_in_main=0 u23_old=1
announce: status=200 headers=Deprecation,Sunset,Link dates=ok body=67
remove: status=404 detail=No static resource customers/Ravi. typo=same_but_name
compat: moved_surface=1(GET /customers/Ravi) moved_reach=7 seven=equal api=identical hold=no
gone: status=410 type=route-retired link=successor counted_410=7 head=410 successor=200/67
tests: red=7 classes=6 web=88->93 client=5 refusals=0 plant_red=4
spec: ops=21 moved=1(customer) bytes=36164->35935
client: before_spec=green after_spec=green customer=Customer->Void deprecated_mark=1
api: api=11 identical
seven: seven=466c20ed
surface: surface=316a9637 after=9ae1ea6d moved=1
moved: web_moved=4 client_moved=1 lib=167=167
inert: keyed=0
change: paths=12 added=1 poms=0
stale: hits=64 undisposed=0
frozen: re_run=0 poms=0 spec_moved=yes
exercise: broken=200(FAIL 1) solved=410 shells=bash,zsh
title: title_len=57
plants: plants=48
build: seed_files=11323 seed_bytes=889446136 central_only=0
```
<!-- values: end -->
