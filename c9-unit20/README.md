# Course 9 · ETags and Conditional GET — evidence

```
Chrome reloads the customer. TiffinBox answers 304 and sends no body. Chrome's record of the page still says 200 — the copy it kept.
```

What is measured behind that hook, on H2 unless a line says otherwise: sealed headless Chrome reloads `GET /api/v1/customers/Ravi` on
`after/`; TiffinBox's access log writes the reload as `304` with `If-None-Match: "v0"`, Chrome's extra-info event records `304`, and
`Network.responseReceived` keeps `200` for the reloaded page - the page, not a stylesheet: on the harness's page copy a revalidated
stylesheet reports `304` in both events. The hook stands in a fenced block, byte for byte the brief's: the prose gate refuses its `304`
and `200` said in digits, and its length (`24` words, the longest sentence `13`) is handed to RED and the scripts stage; it is never
edited here.

A precondition: a condition the server checks before it writes.

Course 9's sixteenth anchor change, Section 4's second unit. `before` is a link to `../c9-unit19/after`; `after/` is the frozen copy of
`../c9-tiffinbox` after this unit's change. Every number below names its tree and its capture; every capture says which database
answered (H2, in memory, a fresh one per JVM, unless a line says PostgreSQL `18.6`).

## Runs of record

Three runs, each launched below load1 `20` with the load printed on its first line, each ending `every capture = published (22)`, and
`check_unit9.py 20 --runlog` read on each run log (its unit gate exits `2` until the script of this unit exists, as expected; the run-log
line is the one read):

- run 1: bash `3.2.57`, `RUNNO=1 ./receipts.sh` in this folder.
- run 2: bash `5.3.9`, `RUNNO=2 bash receipts.sh` in this folder.
- run 3: bash `3.2.57`, `RUNNO=3 ./receipts.sh` in a sealed copy of the repository in a folder whose path holds a space (R.129), with
  that copy's own anchor folder moved aside before the run (flag 31 (iii)).

The pins in `receipts.md5` were taken from a development run (`NOPIN=1`) of this same script before run 1; the three runs then had to
print the same hashes. A first run 1 stopped at run 2's check: bash `3.2.57` refused a `case` inside a command substitution in `moving`
(its error text had reached that capture); the line became an `if`, the `moving` pin was taken from bash `5.3.9`'s correct capture, and
runs 1 and 2 were run again.

As run (2026-11-27; each log's `check_unit9.py 20 --runlog` line: `RESULT (run logs): PASS`):

- run 1: bash `3.2.57`, in this folder, load `6.82 5.20 4.79` at the start; every capture = published (`22`); run-log gate PASS.
- run 2: bash `5.3.9`, in this folder, load `6.56 5.63 5.04` at the start; every capture = published (`22`); run-log gate PASS.
- run 3: bash `3.2.57`, in the sealed copy (`…/sealed clone/tiffinbox-java/c9-unit20`, cloned from the local repository at `0609870` with
  this unit's files laid over it), its anchor folder moved aside before the run (the start note: "they differ"), load `7.52 6.26 5.46` at
  the start; every capture = published (`22`); run-log gate PASS.

Flag 31, the three static runs: `chk20.py static after before` printed the same output, md5 `4f3125b3…`, (i) as written in this folder,
(ii) in the sealed copy after a byte was appended to that copy's own anchor `compose.yaml`, and (iii) in the sealed copy with its anchor
folder moved aside; an audit hook in `chk20.py` refuses any open of a path inside the live anchor's folder, and both plants exit `1`.
These lines were written after run 3; the prose gate and the values block were run again on this README as committed.

## RE-MEASURE (settled first, each by its capture)

- **1** `advisory` — the read filed for Section 4 (`_research/docs-2026-11-27/advisories-s4probe/`), its `fetched-at.txt` naming the
  run's own day; both of the day's `MD5SUMS.txt` verified line by line; Tomcat's page `a1a756d9…` as before; OSV `0` with vulns (the other
  witness only). The pins read off the jar: Boot `4.1.3`, Framework `7.0.11`, Tomcat `11.0.29`. `BOOT-INF/lib` `167` = `167` by name: no
  new artifact - the filter is Spring Web's. Verdict: no pin affected. Nothing else was read from the network.
- **2** `before` — on `before` (21096, U19's `after`): the public read of Ravi answers two hundred with no `ETag`, and a request with
  `If-None-Match` is answered by nothing (two hundred); the list and the order untagged; the bill chunked, `595` bytes. Harness-joined,
  the cached public read sends `1` statement cold and `0` warm (the handler ran each time) - the price the deep tag will charge.
- **3** `change` — one new configuration class, one new test class, two controllers, one core class and the anchor's README: the derived
  changed list is these six paths and nothing else; the running context lists `apiEtagFilter` on `/api/v1/*` beside the limiter; the
  orders `-95`, `-90`, `-80`; no handler added; no pom, no yaml key, no spec byte.
- **4** `census` — the controllers on `before` and `after/` by unit 15's printed rule: equal (`17/11/1/5`); `ConditionalGets` is no
  controller by the rule; the spec `21` operations, `19` paths; the generated client `16` files.
- **5** `shallow` — on `after/` (21090): the list (`GET /api/v1/customers`, cached in "customers") answers two hundred with a strong
  tag and a `Content-Length`; the same read with that tag answers `304`, no body. Harness-joined: the handler ran on every `304`
  (post-handle counted); the list sent `1` statement cold and `0` on every warm answer, its `304` included - on the cached route, warm.
  The order (`GET /api/v1/orders/1`, no cache) sent `1` statement on every answer, both `304`s included: the `304` saved the body's
  bytes; the handler ran and the read ran. PostgreSQL `18.6` printed the same answers and the same counts. On the harness's `/*` copy
  (before's jar and a filter the anchor never registers) the old `/revenue` read `1` statement on its `304`, the old cached
  `/customers/Ravi` `0` warm.
- **6** `paths` — the filter is registered for `/api/v1/*` only. The feed's first event is read on both trees with no tag; `/revenue`,
  health, `/v3/api-docs` and the old `/customers/Ravi` untagged; U18's bill and its signed link stay chunked with no tag, the bill `595`
  bytes, its md5 equal on both trees; the bill link (plain JSON) is tagged. On the harness's `/*` copy the feed sends no byte before the
  reader's alarm, `7` old answers gain a tag and `6` lose chunking for a `Content-Length` (the old surface `e6b8a52e…`, `25` diff lines);
  on the unfiltered-bill copy the bill is buffered: `Content-Length: 595`, no chunking. Limiter at five (a labelled run flag): five
  tagged two hundreds, then the refusal with no tag.
- **7** `weak` — the list: its tag `304`, the `W/` form of it `304`, another tag two hundred, `*` two hundred, a list holding it `304`;
  the deep route the same five answers. Every tag the server wrote starts with a quote: none weak.
- **8** `deep` and `identity` — `GET /api/v1/customers/Ravi` answers `ETag: "v0"`; `If-None-Match: "v0"` answers `304`, no body; `"v7"`
  two hundred; `HEAD` carries the tag. Harness-joined, every two hundred and every `304` of this read sent `1` statement (one `select` by
  name) on H2 and on PostgreSQL `18.6`, where the cached read sent `0` warm on `before`: the price of a tag a writer
  can send back. A `PATCH` with no `If-Match` answered two hundred with no tag; the tag then read `"v1"` and the old tag two hundred. The
  old address stays untagged and cached. The body is byte-equal to `before`'s; a body hash of it is not the handler's tag - the filter kept
  the handler's. Identity, H2: a row renamed away reads `"v1"`; a new row under the old name reads `"v0"` again, and the first row's tag
  on it answered `304`: a version counts a row's edits, not the row.
- **9** `ifmatch` — both routes (merge patch, JSON Patch), each case its own customer, H2 and PostgreSQL `18.6`: the current tag two
  hundred and the tag moves to `"v1"`; the old tag again `412`, the customer read back unchanged; `W/"v1"` `412`; no `If-Match` two
  hundred (a write without a precondition, as before). Every `412` sent `1` statement and `0` writes; each two hundred wrote once, the
  `UPDATE` printed with the version in its `where` clause, as *Optimistic Locking with @Version* wrote it, on both databases. `If-Match: *` and a list holding the current tag answered
  two hundred; an unknown name with a stale tag is the route's not-found; a stale tag with a body that is not JSON is the bad-request
  refusal; `text/plain` Spring's unsupported media type. The refusal is a problem (`detail`, `instance`, `status`, `title`; no type).
  PostgreSQL's column: `version bigint`, not null, default `0`.
- **10** `cache` — the stylesheet of *Static Resources and Cache Headers* on Framework `7.0.11`: the plain name untagged; the versioned name a weak tag; its own weak tag
  alone two hundred, the whole stylesheet (it still matches nothing); its own date alone `304`, no body; both together two hundred.
  `javap` of the pinned `ResourceHttpRequestHandler`: it hands `checkNotModified` a tag and a date; on this tree only the date answered.
- **11** `chrome` — leg A on the shipped read and leg B on the harness's page copy, as the hook's paragraph says; every TCP connect in
  both NetLogs went to `127.0.0.1`.
- **12** `metrics` — after a two hundred, a `304` and a `412`: the `304` counted under `outcome="REDIRECTION"`, the `412` under
  `CLIENT_ERROR`, both under `uri="/api/v1/customers/{name}"`.
- **13** `spec` — the served document equals the committed file, unchanged (`36164` bytes, `aa8cb98f…`); the operations' ids equal; no
  operation documents the tag, `If-Match`, `304` or `412`; `OpenApiSpecTest` passes; the client untouched.
- **14** `api`, `moved`, the seven and the old surface — the `/api/v1/` census is additive: an `ETag` on five routes (the list, the deep
  read, the bill link, the order list, the order), no status, content type or masked body moved; four refusals (the billing run's and the
  pause's not-found, Nobody's not-found, the unknown parameter) moved from chunked to a `Content-Length`, named under S9.37; the two bill
  routes untagged and chunked. U18's request list: `15` lines moved, each by the `etag` header alone. The seven and the old surface equal
  the values block's on both trees - not witnesses for the filter: neither sends a request to `/api/v1/` (R.511). The web jar gained `2`
  entries (`ConditionalGets` and its filter); `4` shared entries moved, each named: `CustomerPatches`, its `Refused`, `CustomerReads` and
  `BOOT-INF/lib/tiffinbox-core-1.0.0.jar`.
- **15** `moving` — three starts on one port: the order list's and the bill link's tags moved per start (`3` distinct each); the deep
  tag, the list and the order kept one each.
- **16** `tests` — `mvn -o clean package`: the web module `85` tests (`81` at *Rate Limiting* plus `ConditionalGetTest`'s `4`), the client `1`,
  none skipped, `0` refusals at the default outside `RateLimitFilterTest`; the Docker-free twin and the `-pl tiffinbox-web -am` form the
  same; `mvn -o clean verify`: the five ITs, `14` tests, every binding on `127.0.0.1`, nothing pulled; `0` downloads; the slice green
  unedited.
- **17** `exercise` — on 21098, H2, under bash and `zsh -f`: the broken copy answers the stale tag two hundred and writes (clauses 2, 3
  and 4 fail); the solution passes; three refused variants fail (run 1).

## The change, file by file, and every README/Javadoc sentence it rewrote or noted (R.250/R.453)

The anchor's README card `## Course 9 · unit 20` and its header note give the change; the files whole are in `change`. `CustomerReads`'
Javadoc sentence "No validator header is sent here" is rewritten (the route now sends one); `CustomerReadsTest`'s Javadoc, which leaves a
validator unpinned, stays as written (a test, unedited). Unit 01's and unit 06's "no validator" lines are history on their own trees and
are noted in the header note, not edited. The web module's `81` tests are noted as *Rate Limiting*'s.

## Which tree, which profile

Every header, framing and status claim is read from a harness-free start of `after/` (21090) or `before` (21096) on H2, the default
run; every handler and statement count from a harness-joined start (`probe.Witness` and `probe.Http`, U12's), whose answers were printed
beside the harness-free ones and found equal. `shallow`, `deep` and `ifmatch` ran again on PostgreSQL `18.6` (`c9u20-pg` by digest, its
URL from the run folder's config tree, no dev profile, no other store). The harness's copies ran on 21095.

## This unit's section

The spine: a tag on a read, the not-modified answer that saves the body's bytes, the row's version as a tag a writer can send back, and
the precondition that refuses a stale one. The failure receipt is the exercise's broken copy: a stale `If-Match` writes. The hazards are
measured: the filter's patterns (`paths`), the bill's chunking (`paths`), the per-start tags (`moving`), the deep tag's price (`deep`).

## The captures — what each one shows

### advisory, before, change, census
The read, verified; `before`'s answers and the warm read's statements; the diffs and the new classes whole, the derived list, the
running context's filters; the census.

### shallow, paths, weak
The two reads' answers and the witness's lines on H2 and PostgreSQL; the anchor's paths beside the harness's `/*` copy and the
unfiltered-bill copy; the limiter at five; the `If-None-Match` table.

### deep, ifmatch, cache
The deep tag on both databases and the identity sequence; both PATCH routes on both databases with the `UPDATE` text; the stylesheet's
four requests and `javap`.

### chrome, metrics, spec, moved, api, seven, surface, moving, inert, tests, harness, exercise
Chrome's events beside the access log for both legs, the NetLog reading; the scrape; the spec unchanged; U18's list and the census on
both trees; the seven and the old surface; three starts; the key header absent; the reactor, the twin, `verify`, the web-only form;
the harness's files and flag 31's static runs; the exercise under both shells.

## Measured, not shipped

The harness's `/*` copy, the unfiltered-bill copy and Chrome leg B's page copy (`probe.Etag` adapted: its patterns a run flag); the
witness (`probe.Witness`, `probe.Http`); the run flags (the limiter at five; leg B's two resource flags; the actuator exposure flag);
the PostgreSQL container; the exercise's broken copy and its refused variants.

## Refused, named

The prose gate (`s920.py`: U19's `XU19C9` kept, `XU20C9` added) refuses, each planted and caught in its self-test: the handler or the
read said skipped on a not-modified answer; a browser's record named as the wire's answer, or its tool window named; the API's answers said not to move; the filter
said fit for streaming or on every path; the precondition said to guard every write; the version tag said to name the row itself; a meaning by a standard without the dated read; weak tags said written; the spec said to document the new
answers; a saving said for every route; another gloss line; bare header and class names outside code spans; any word of dur9's list.

## The repository, and the network

The advisory read stands: filed by the S4 probe on the run's own day, it cleared every pin this unit ships, and this unit adds no
artifact. No standard's text is cited: every meaning is the wire's, as printed. Nothing else was read from the network; the only network act of
this unit is the final `git push`.

## The folders, the harness and the ports

`README.md`, `after/`, `before` (the link), `exercise/` (`README.md`, `SOLUTION.md`, `apply.sh`, `break.sh`, `check.sh`), `harness/`
(`chk20.py` and `chrome20.py` new; `dur9.py`, `ops9s3.py`, `cdp.mjs`, `cdp9.mjs`, `seal9.py`, `src/probe/Http.java` and
`src/probe/Witness.java` copied byte for byte; `s920.py`, `tree20.py` and `src/probe/Etag.java` adapted, their named diffs in
`harness`), `receipts.md5`, `receipts.sh`. The `net.py` and `netlog.py` of `c6-unit23` are read in place. Ports: 21090 `after/` · 21091
PostgreSQL · 21095 the harness's copies · 21096 `before` · 21097 Chrome's DevTools · 21098 the exercise · 21092-21094 and 21099 never
bound; 21280-21284 during `verify` only.

## Masks, filters and hygiene

One self-tested mask: a start's times, the log's time counts, timestamps, the folders and the home, the band's ports, every shallow tag
(the deep tag stays raw), the stylesheet's weak tag and versioned name, `max-age`, an HTTP date, Chrome's version and platform, the
period in the start's line; the bodies' cursors, expiries and signatures before an md5. The NetLog's counts are run-variant lines. The
container is `c9u20-pg`, removed with its volume; images and volumes at the end equal the start's; every JVM and both Chromes stopped by
their recorded pids, each Chrome profile removed; the author's own Chrome never touched.

## Interrupted

SIGINT, under `perl -e '$SIG{INT}="DEFAULT"; exec …'`, driven by a scratch driver at two points, each a development run (`DEVCAPS`)
of this script interrupted by its recorded pid: mid-container and mid-harness at once (PostgreSQL up on 21091 and a JVM on 21090, in
`shallow`) and mid-Chrome (the headless Chrome's DevTools up on 21097, in `chrome`). Each exited `130` and left no JVM, no Chrome, no
listener in the band, no `c9u20-*` container, volumes at the start's `315`, images `9`, no Chrome profile, no `.r-lock` and no `.r-*.new`;
the author's own Chrome count stayed `1`. Not driven: mid-build, mid-`verify`, mid-scratch-copy and mid-exercise (not said).

## Planted faults — each caught

`chk20.py plants` alters a copy of each run's own captures and requires a FAIL line, exit `1`, no traceback: a `304` typed two hundred;
the uncached `304`'s statements typed `0`; the handler typed not run; the bill typed with a tag; the starved feed typed alive; the
refusal typed with a tag; `*` typed `304`; `W/` typed on a server tag; the deep tag typed `"v1"`; the deep `304`'s statements typed `0`;
the old route typed tagged; a stale tag typed two hundred; the weak form typed two hundred on PostgreSQL; no header typed `412`; a write
counted on a `412`; PostgreSQL's column typed otherwise; the stylesheet's tag alone typed `304`; its date alone typed two hundred; the
page's record typed `304`; a NetLog TCP host other than `127.0.0.1`; an empty event file accepted; a non-tag move in the census; a
per-start route typed stable; the committed file touched; the seven's md5 one character off; `Skipped` typed `1`; a refusal at the
default; the solution equal to the broken copy; the read dated after the run; `before` typed tagged; a JVM's request count above the cap;
a refusal line at the default; three unparseable listings. The static check fails on a scratch copy moved by one byte; flag 31's two
plants exit `1`.

## What differed from the brief

- C1-C14: the orchestrator's note bound every pick at its RECOMMENDED option (picked by the orchestrator). Readings: C1 (b) was not
  measured (dropped first); C2's method is `findVersioned` with a nested record `Versioned` (one method and its record); `CustomerReads.one`
  keeps its parameter list `(String)` - `OrderResources` looks it up by it for the order's customer link (a `WebRequest` parameter
  failed the start: `NoSuchMethodException`, measured once) - so it returns a `ResponseEntity` with the tag and Spring's entity processor
  answers the not-modified answer; C8 runs three of the six refused variants (`mergeonly`, `required`, `fixedelsewhere`); C11 ran; C12
  not captured, not said; C14: no standard's text cited.
- `If-Match: *` and a list holding the current tag answered two hundred on both routes (printed, not designed). A `PATCH` whose
  `If-None-Match` names the current tag would also meet the check (Spring evaluates both); not captured, not said.
- The shallow filter buffers every `/api/v1/` answer it passes: four refusals moved from chunked to a `Content-Length` (named, S9.37).
  `HEAD` of the list carries no shallow tag (the filter tags `GET` only); `HEAD` of the deep read carries `"v0"`.
- The static handler hands `checkNotModified` both its tag and its date (`javap`); the brief's "asks the date" is read as: only the date
  answered here.
- Chrome's NetLog held three UDP connects to a public IPv6 address, each failed (`net_error -109`), `0` bytes sent - the reason
  `seal9.py netlog` exits `1` on its UDP verdict; every TCP connect was to `127.0.0.1`. The check reads that, and RED should see it.
- Every shallow tag is masked, not only the per-start ones (N12's list is a subset).
- The exercise's line has `13` words after "Your turn:" (the brief counts `15` with them).
- The prose family is `XU20C9` (the carried base holds Course 8's `u20`).
- `cache`'s PostgreSQL twin, the S9.14 slot beyond `paths`' `/*` copy, four of the interrupt points and C1 (b) were dropped by the prompt's order.

## For RED

The picks as bound; the check-then-write window between the precondition and `update`'s own read (named, not closed, not measured); a
version counts a row's edits, so a re-created name answers the old row's tag `304`; the spec's named gap (C6 (b) would move the PATCH
operations' generated signatures); the `412` problem with no type; the core read beside the cached one; four refusals' framing moved; the
per-start mask; the NetLog's failed UDP connects; the hook's `24` words and its digits. For the orchestrator (flag 21): the frozen receipts that hash `/api/v1/` header sets
(`apiside`, `movedside`, in `c9-unit10` through `c9-unit19`) read their own frozen trees; run against this anchor they would meet the new
`etag` header and the four refusals' framing.

## The ledger rows this unit pays

`TRACK-ROADMAP.md:394` (ETags and Conditional GET); C9-4: `@Version`, `getVersion()`, the column and the `UPDATE`'s version check of *Optimistic Locking with @Version*
re-measured on H2 and PostgreSQL `18.6` - its exception is that lesson's, not provoked here: a stale tag is refused before the write;
C9-8: the stylesheet of *Static Resources and Cache Headers* still matches nothing on Framework `7.0.11`, and this unit's not-modified answers come from a body hash or a row's version; C9-11: the seven and the old surface at this
anchor change. No ledger edit.

## The values the video may say

Statuses as words; tags, counts and versions in code spans only; no `max-age` voiced. From the values block, each with its capture: the
deep tag `"v0"` and its not-modified answer, `1` statement on every answer of the public read (`deep`, H2 and PostgreSQL `18.6`) where the
cached read sent `0` warm (`before`); the list's not-modified answer with `0` statements warm and the order's with `1` (`shallow`); a stale
tag refused with `0` writes on both routes (`ifmatch`); the stylesheet's tag alone answered in full, its date alone not modified
(`cache`); Chrome's page record two hundred beside the wire's not-modified answer (`chrome`); the web tests `81` -> `85`, the ITs `14`,
`BOOT-INF/lib` `167` (`tests`).

<!-- values: begin -->
```
advisory: fetched=2026-11-27 lib=167->167
before: before=noetag warm_statements=0 cold_statements=1 lib=167 OPERATIONS 21 PATHS 19
change: changed=6 filters=apiEtagFilter:/api/v1/*
census: census=17/11/1/5 spec=OPERATIONS 21 PATHS 19 files=16
shallow: cached=/api/v1/customers cold=1 warm=0 handler304=3 uncached=/api/v1/orders/1 statements304=1 pg=equal star_revenue304=1
paths: filter=/api/v1/* feed_after=first_event bill_after=chunked,595B,noetag star_feed=starved star_tagged=7 star_unchunked=6 nobill=Content-Length: 595 dashboard=Content-Length: 1022 post=Content-Length: 67 lim429_etag=none
weak: list=304,W304,other200,star200,list304 deep=304,W304,v7_200,star200,list304 weak_written=0
deep: tag="v0" statements200=1 statements304=1 before_warm=0 pg=equal moved="v1" identity=304
ifmatch: both_routes current=200 stale=412 weak=412 none=200 star=200 list=200 unknown=404 malformed_stale=400 mediatype=415 writes412=0 pg=equal
cache: tag_alone=200 date_alone=304 both=200 javap=checkNotModified(String,long)
chrome: A_page=responseReceived200,extraInfo304 A_access=200,304 B_css=304,304 B_page=200,304 netlog=tcp_127.0.0.1_only,udp_probe_failed_0B
metrics: 304=REDIRECTION 412=CLIENT_ERROR
spec: spec=36164 ops=OPERATIONS 21 PATHS 19
moved: moved=15 moved_by=etag jar_added=2 jar_moved=['BOOT-INF/classes/com/tiffinbox/web/CustomerPatches$Refused.class', 'BOOT-INF/classes/com/tiffinbox/web/CustomerPatches.class', 'BOOT-INF/classes/com/tiffinbox/web/CustomerReads.class', 'BOOT-INF/lib/tiffinbox-core-1.0.0.jar'] lib=167->167
api: api=11 tagged=5 routes=/api/v1/customers,/api/v1/customers/Ravi,/api/v1/customers/Ravi/bill-link,/api/v1/orders,/api/v1/orders/1 framing_moved=/api/v1/billing-runs/<uuid>,/api/v1/customers/Ravi/pauses/1,/api/v1/customers/Nobody,/api/v1/customers?nosuch=1
seven: seven=466c20ed
surface: surface=316a9637
moving: orders=3 bill_link=3 deep=1 list=1 order=1
tests: web=85 client=1 conditionalget=4 its=14 lib=167->167
harness: static=4f3125b3e7879e4d78380c13d729d088
exercise: broken=FAIL(stale_200_written) solved=PASS
inert: keyed=0
plants: plants=35
build: seed_files=11323 seed_bytes=889446136 central_only=0
```
<!-- values: end -->
