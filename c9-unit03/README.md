# Course 9 · Unit 03 · Status Codes That Mean Something — evidence

No anchor change. `before/` and `after/` are both links to `../c9-unit04/after` (U04's frozen anchor: Spring Boot 4.1.3, Framework
7.0.11, Tomcat 11.0.29, the key filter present and inert without its header), pinned by `harness/tree03.py` against
`../c9-unit04/receipts.md5`'s `after-tree` line. This folder measures that tree; it changes nothing in it, builds it once offline
under `.harness/`, runs no suite and builds no test copy.

The hook (S1B :273, byte for byte; the spoken line is RED's):

> Ask TiffinBox for a customer list in CSV. It answers four oh six — after it has already read the customers.

The gloss this unit owns (SECTION SHAPE, S1B :385), one sentence on a line of its own; its first spoken use is this line:

An author: which part of the server wrote these bytes.

## Runs of record

Three runs, each launched below load1 20 with the load printed on its first line, every build offline, `check_unit9.py 03 --runlog`
PASS on each run's log (the unit gate exits 2: no `03-*.md` script exists yet, expected):

```
bash 3.2.57  ./receipts.sh            12:24 CET, load1 2.51 at the launch · exit 0 · "c9-unit03: every capture = published (15)"
bash 5.3.9   bash receipts.sh         12:26 CET, load1 4.04 · exit 0 · the same
sealed clone a local git clone of HEAD 959f6ae into ".../sealed clone/tiffinbox-java" (a path with a space), this folder's
             tracked files copied in, the seed copied by the receipt itself; bash 3.2.57 ./receipts.sh
                                      12:27 CET, load1 3.47 · exit 0 · the same
check_unit9.py 03 --runlog <log>: RESULT (run logs): PASS on each (0 grep error lines, R.166)
```

The capture hashes (`receipts.md5`), equal in all three runs:

```
before-tree 92 8761a535e4940fe7d5b0d9d0c7dea711
after-tree 92 8761a535e4940fe7d5b0d9d0c7dea711
matrixpg e38df7689a028f7105982f18d02655b9
matrix 452f508b0e68b290510b4bd1c04b0736
census 8b432d43bc1151d3793030f3325fa947
authors 603a9f06b767af1eb55ec70d9de4f797
six b4ba932854a6af51b6256538ae5b2435
conditional a06508375af0e55ffe0e89525aa19de7
limits b16160599b9996b64df62745e6bab3ea
cannot 67afc6262ab971319c5042d8a085da88
five be8e8627c1444f168bfeacdd3a9187aa
inert 5de555993f947ad57f1923dce4c9248f
instance 403843d00af174b364e23255c50a5597
cross 1161f466162d1cba763b1d4dc20fd52b
seven ea7e64f7efa50cb31266e10dae7d40e4
surface ec1ba0fd16b39021d0ac0eaf08ff2d4e
exercise 1d9d5b36bceb994f6133bce7a61c01c2
```

## RE-MEASURE (settled first)

1. **The status matrix on `after`.** Every request this unit sends, over a real socket, one JVM per database (PostgreSQL first, then
   H2), forty-seven requests in one access-log window, no key header on any of them. The asked routes answered fourteen distinct
   final codes (`200 201 302 304 400 403 404 405 406 409 412 413 415 501`) - the brief's fourteen - plus the interim `100` and the
   harness's own `500` (`boom`), counted apart. Every request is attributed by one rule (`author()` in `harness/chk03.py`, below)
   to the part of the server that wrote its body; the counts per class, per request and per code, are equal on the two databases,
   and so is every HTTP column of every row (`cross`). `inert`: every row this unit shares with the boundary's census on 4.1.3 +
   Tomcat 11.0.29 before the key (`B8/census-mid/census.txt:168-354`) is equal in method, path, status, content type and bytes -
   nothing moved - and the key table holds no row after the matrix on either database, read by another client.
2. **The four oh six after the read (`six`).** Cold (the create's eviction just ran): `GET /customers` with `Accept: text/csv`
   answers `406` problem+json, and inside that request the statement witness counts `1` read and the customers cache goes from
   empty to `[SimpleKey []]`; the handler is `TiffinBoxServer#customers` with `post-handle no`, and the resolver's line names
   `HttpMediaTypeNotAcceptableException` resolved by Boot's `ProblemDetailsExceptionHandler`. The same list as JSON straight after:
   `200`, `0` statements. Warm, the CSV ask again: `406`, `0` statements, the keys unchanged. After another eviction, a cold JSON
   read: `200`, `1` statement, the same SQL text as the cold four oh six's.
3. **The static handler's preconditions on Framework 7.0.11 (`conditional`).** On the stylesheet: the date alone
   (`If-Modified-Since` = its own `Last-Modified`) gets `304`; its own weak `ETag` in `If-None-Match` gets `200` and the whole file -
   the live line "the ETag Spring MVC sends here matches nothing" from the Spring Web MVC course's *Static Resources and Cache
   Headers* is still true here; the `ETag` beside the date gets `200`; `If-None-Match: *` gets `200`; `If-Match: "x"` gets `200`,
   where RFC 9110's clause in §13.1.1 (line `5833`) wants a `412`; the only `412` comes from `If-Unmodified-Since` set before
   `Last-Modified`, and the same header with the true date gets `200`. Every one of them is the static handler
   (`ResourceHttpRequestHandler`, `post-handle yes`) on the same file, `0` statements.
4. **Tomcat's three on 11.0.29 (`limits`, `authors`).** `TRACE` goes to Boot's `/error` on an ERROR dispatch (`405`, the four-key
   JSON); `CONNECT` gets Tomcat's own HTML page (`501`); a request line with a nine-thousand-character path gets Tomcat's own HTML
   page (`400`, the same bytes as the boundary's census) with no witness line and an access-log line `GET -- 400` (Tomcat's `%U` and
   `%q` both `-`: no URI was parsed). RFC 9110 §15.5.15 (line `7720`) names `414` for a target URI too long; the capture is a `400`.
5. **The five hundreds of the access log (`five`).** Of the requests this unit sent, the only `500` is the harness's `boom`
   (`/probe/u03/boom`, a harness route, never TiffinBox's). This unit sends no feed request; U01's access log holds a `500` for
   `GET /customers/feed` (cited below, not re-sent here). The window's distinct codes are the fourteen plus that `500`.
6. **The seven and the old surface on `after`.** Each equal to the value U04's values block holds for `after` (`inert:` line),
   the surface's feed read by a count condition; the S9.14 plant (a shallow-ETag filter on every path, a harness copy) leaves the
   seven unchanged, moves the surface and silences the feed.

```
the matrix (H2; PostgreSQL equal in every HTTP column): 47 requests · 14 final codes · interim 100 · the harness's 500
authors per request: the route 21 · TiffinBox's advice 1 · Boot's problem-details handler 11 · the static handler 8 ·
                     Spring MVC's redirect 1 · Boot's /error 1 · Tomcat 2 · Spring MVC's OPTIONS handler 1   (+ boom: Boot's /error)
authors per code:    the route 5 (200 201 400 403 409) · TiffinBox's advice 1 (404) · Boot's problem-details handler 6
                     (400 404 405 406 413 415) · the static handler 3 (200 304 412) · Spring MVC's redirect 1 (302) ·
                     Boot's /error 1 (405) · Tomcat 2 (400 501) · Spring MVC's OPTIONS handler 1 (200)
the brief's (S1B :287): route 5 · advice 1 · Boot 7 · static 2 · Tomcat 3      Tomcat refused 3 · Tomcat wrote 2
```

## The change: none

`git diff --stat HEAD -- c9-tiffinbox c9-unit04 c9-unit01 c9-unit02` is empty before and after every run; no anchor path changes, so
no builder grep for changed paths applies (R.211 / R.331 are about a moved anchor; this unit moves nothing).

## Which tree, which profile

`before` = `after` = `../c9-unit04/after`, both links, the text exact; `receipts.md5`'s `before-tree` and `after-tree` lines both
equal `../c9-unit04/receipts.md5`'s `after-tree` line, read at run time. The receipt also prints, as a note and never a stop,
whether `after/` still equals `../c9-tiffinbox` (Course 8's form, `c8-unit04/receipts.sh:149-150`): "the anchor today" while it
does. The matrix runs on both databases, PostgreSQL 18.6 first (by its digest, on the loopback, a fresh database per start) and
then H2 (the default run); the version lines printed by every JVM are Spring Boot 4.1.3, Framework 7.0.11, Tomcat 11.0.29 and
Hibernate 7.4.15.Final, equal to U04's. U04's own test counts are cited from its values block (`tests_after=28 tests_k=10 its=14`),
never re-run here; this unit has no test of its own and builds no test copy.

## The captures — what each one shows

Every capture is hashed into `receipts.md5`; a hash that differs stops the run. PostgreSQL is named first wherever both ran.

### matrixpg, matrix — every request of the unit

One JVM per database. The cache is read before any request (empty, once the `Started` line is printed), one `GET /actuator/health` is counted apart (it
fills the cache: Course 8's cached list, read by the kitchen's health indicator), then the window opens. Each request has its own
header and body files, reset before it; each prints every status line of curl's header file (the interim `100` too), the headers
the matrix reads, the access log's line, the request witness's lines (a REQUEST line, and an ERROR line when Boot's `/error` ran),
the resolver's line where an advice wrote the body (harness logging, below), the cache's keys where the order matters, and the
body. The window's access-log lines are printed whole; the harness's own reads (`/probe/u03/cache`, `/keys`, `/row/…`) are set
apart by one named rule, and the remaining lines equal the requests sent.

### authors — who wrote each body

The author rule, written once as `author()` in `harness/chk03.py` and printed with the capture, in this order: an ERROR-dispatch
witness line means Boot's `/error`; no REQUEST witness line means Tomcat; a resolver line names TiffinBox's advice
(`TiffinBoxErrors`) or Boot's problem-details handler (`ProblemDetailsExceptionHandler`); `ResourceHttpRequestHandler` means the
static handler; a handler that ran and answered a redirect with a `Location` means Spring MVC's redirect; `HttpOptionsHandler` means
Spring MVC's own handler for an `OPTIONS` (a class the brief does not list - see What differed); a handler that ran means the route.

```
  s404a   GET  /customers/Nobody  404 problem+json 126 · TiffinBox's advice             · resolver: TiffinBoxErrors#notFound (CustomerNotFound)
  s404b   GET  /nowhere           404 problem+json  95 · Boot's problem-details handler · resolver: ProblemDetailsExceptionHandler#handleException (NoResourceFoundException)
  s405    GET  /shutdown          405 problem+json 108 · Boot's problem-details handler · resolver: … (HttpRequestMethodNotSupportedException)
  trace   TRACE /customers        405 json         102 · Boot's /error                  · an ERROR-dispatch line only (GET /error, BasicErrorController#error)
  s409    POST /customers         409 problem+json 106 · the route                      · handler TiffinBoxServer#add, post-handle yes
  connect CONNECT /customers      501 html         443 · Tomcat                         · no witness line
  long    GET  /customers/<9000 x> 400 html        435 · Tomcat                         · no witness line; access GET -- 400
```

The same code from two authors (the two four oh fours; the two four oh fives), and the same author for different codes (Boot's
problem-details handler writes six). The route's conflict sits beside the advice's not-found: both TiffinBox's, two authors.

### census — the two hundreds and three hundreds

`200` (the route's list, warm, `0` statements; and the form's re-render, a `200` from `DashboardPage#add`, a different class from the
list's `TiffinBoxServer#customers`) · `201` + `Location` (the route's `ResponseEntity.created`, `1` write; the cache evicted) · `302`
+ `Location` (the form POST's `redirect:/dashboard`, `DashboardPage.java:107`; Spring MVC's redirect; `Content-Length: 0`) · `304`
(the stylesheet by its date; the static handler; `0` body bytes). The gloss of a status code is the Spring Web MVC course's, in
*Responses: ResponseEntity and Status Codes*: called back, never re-glossed.

### six — the failure receipt

```
  six-cold    COLD: GET /customers (Accept: text/csv) -> 406 problem+json · cache [] -> [SimpleKey []] · handler TiffinBoxServer#customers · post-handle no · statements 1 (writes 0)
  six-control the control: GET /customers (JSON)     -> 200 · statements 0
  six-warm    WARM: GET /customers (Accept: text/csv) -> 406 · cache [SimpleKey []] -> [SimpleKey []] · statements 0
  six-base    after an eviction, cold, JSON            -> 200 · cache [] -> [SimpleKey []] · statements 1 (the same SQL text)
```

The hook's "after it has already read the customers" rests on the cold row's statement and keys line and on the warm row's keys
line; the spoken number one belongs to the cold row only. `post-handle no` is not the witness of the read (the converter refused the
handler's return value); the statement witness and the cache's keys are. RFC 9110 §15.5.7 is read off the filed copy (line `7613`).
*Content Negotiation* (the Spring Web MVC course) is where the four oh six was built.

### conditional — what the static handler does and does not do

The seven precondition requests above, each with its witness line (`ResourceHttpRequestHandler`, `post-handle yes`), on both
databases. The `304` and the `412` come from the same handler on the same file, by two different headers. RFC 9110 §13.1.1 to
§13.1.4 and §13.2.2 are read off the filed copy, the heading line and one clause's line printed for each. *ETags and Conditional GET*
is the lesson that works with these validators.

### limits — the two answers that come before any route

The big import (`1,500,000` bytes, made from `/dev/zero` as the boundary's instrument made it) is over the multipart file limit the
jar's own metadata gives (`spring.servlet.multipart.max-file-size`, default `1MB`, `spring-boot-servlet-4.1.3.jar`); curl's header
file holds `HTTP/1.1 100` then `HTTP/1.1 413`: the server said go ahead, then refused the file. The resolver's line names
`MaxUploadSizeExceededException`, resolved by Boot's handler with no handler selected (`handler none`, `0` statements). With
`-H 'Expect:'` the same request gets the same `413` with no `100` block: the `100` answered curl's own `Expect: 100-continue`. A
small valid CSV reaches the route (`200`). The long request line gets Tomcat's own page; the jar's metadata gives
`server.max-http-request-header-size` default `8KB`; a normal path (`/customers/Ravi`) reaches Spring with a REQUEST witness line.
RFC 9110 §15.2.1, §15.5.14 and §15.5.15 are read off the filed copy.

### cannot — the codes TiffinBox cannot produce yet

Asked first, then named. A small CSV import answers `200` (not `202`); `DELETE /customers/Ravi` answers `405` and `OPTIONS
/customers` answers `200` (not `204`); a bearer token on the list answers `200`, a wrong shutdown token answers the route's own `403`
(the route's, not a login's - not `401`); the deleted-then-read name still answers `200` (not `410`); the body that parses and breaks
a rule is the matrix's own `s400a`, a `400` (not `422`); a burst of five list reads answers `200` five times (not `429`). Then each
code is named by the lesson that builds it, read off `java9_series.TITLES`: *Bulk Operations and `202` Accepted*, *Idempotency, Safety
and Retries* (the next lesson), *Rate Limiting*, *Retiring an Endpoint Without Breaking Anyone*, and the course *Spring Security —
complete*; no Course 9 title builds a two oh four, so it is left unsaid.

### five — the harness's five hundred, labelled

`GET /probe/u03/boom` answers `500` with Boot's `/error` four keys (`timestamp` masked, `status`, `error`, `path`), a REQUEST line
`handler U03Probe#boom` and an ERROR line `BasicErrorController#error` - a harness route, never TiffinBox's. `TRACE`'s `405` carries
the same four-key shape from the same class. No TiffinBox request of the matrix answered `500`.

### inert — the key filter is inert for the matrix

The rows the boundary's pre-key census also asked, compared row by row, on both databases: equal. The `POST /customers` rows the
filter could have moved (it is registered on `/customers`) are listed, each passed on with no key header. The key table's rows after
the matrix: none on either database (psql in the container on PostgreSQL; the harness's JdbcTemplate route on H2).

### instance — who fills it

No TiffinBox source calls `setInstance` (the grep is printed with its matches: none); the route's and the advice's `ProblemDetail`
objects leave it unset, and every problem+json answer of the matrix carries `instance` equal to its request path - the route's, the
advice's and Boot's handler's alike. On this version, instance holds the request path, filled in by Spring Framework on the way out.
Boot's `/error` bodies (`TRACE`, `boom`) carry no `instance`: a different, four-key shape. RFC 9457 §3.1.5 (line `336`) describes the
member as a reference to the specific occurrence of the problem; the capture shows what this version puts there.

### cross — PostgreSQL and H2

Every HTTP column of every row (status, content type, bytes, status lines, headers with `Allow` read as a set, the access line, the
author, the body) equal on the two databases; the statement column equal too.

### seven, surface — the old answers, unchanged

`c5-unit11/curlset.sh` on `after/` and the old surface (thirteen requests, its feed read by a count condition), each in its own JVM
on H2, each equal to U04's `inert:` values; then the S9.14 plant in a plant slot (labelled, not a capture of TiffinBox).

### exercise — the exercise, under bash and zsh

`exercise/ask.sh` as shipped (broken: `If-None-Match` with the stylesheet's own `ETag`, answered `200` and the whole file), with
SOLUTION.md's line in place (`If-Modified-Since` = its `Last-Modified`: `304`, `0` body bytes), and four refused "solutions" (each
fails `check.sh`), against TiffinBox's jar alone on 20928, `env -i`, from the exercise's folder, under bash and `zsh -f`. A stale
`ask.bytes` is planted before each try: `check.sh` removes it first.

## Measured, not shipped

`harness/src/probe/u03/U03Probe.java` (four labelled routes: the cache's keys, the key table's rows, a name's rows, and `boom`),
the copied witnesses (`Witness`, `Http`, `Etag`), the harness logging (`ExceptionHandlerExceptionResolver` at DEBUG, on the matrix
JVMs' command line only), the S9.14 plant slot. None of it is in the jar or the anchor.

## Refused, named

`a dozen codes` or any count but the derived fourteen; the four oh six `before the handler` or `without reading`; `the static
handler checks If-Match`; `its own ETag answers three oh four`; `Spring answers CONNECT` or the long line; `every error body is
JSON`; a code TiffinBox cannot produce shown as if it did; `the access log holds fourteen codes` (it also holds the harness's
`500`); a five hundred `only from the harness` without U01's feed line beside it; `Tomcat answers four fourteen`; `Tomcat is
wrong`; U04's routes or key measured; the feed's `500` voiced. Each is a phrase of `XU03` in `harness/s903.py`, self-tested.

## The repository, and the network

`D` = `_deliverables/tiffinbox-java`, HEAD at the start `959f6ae` (the receipts-note fix) with `cabc6d3` (U02) its parent;
`origin/main...main` = `0 0` from the local tracking ref. ONE commit for `c9-unit03/` alone, pushed. No network of any kind but
that push: the build is offline from a `cp -c` copy of `m2-seed-c9-u04`, no image is pulled, the RFCs are the filed copies in
`docs-2026-11-23` (each file's md5 in its `MD5SUMS.txt`), no advisory is read or cited.

## The folders, the harness and the ports

`before`, `after` (links) · `receipts.sh`, `receipts.md5` · `harness/` (`chk03.py`, `s903.py`, `tree03.py`, `dur9.py`, `src/probe/…`)
· `exercise/` (`README.md`, `ask.sh`, `check.sh`, `SOLUTION.md`) · `README.md`. Ports, U03's band: 20920 TiffinBox on H2 (the
matrix; the seven and the surface each in its own JVM) · 20921 PostgreSQL · 20922 TiffinBox on PostgreSQL · 20923 the S9.14 plant's
JVMs · 20924, 20925, 20927 asserted free · 20926 never bound (no `before/` JVM: one tree) · 20928 the exercise · 20929 never bound.
U04's 21280-21289 and Course 8's ports are asserted free and never bound.

## Masks, filters and hygiene

The log mask (times, the folders, the home, the user, the nine-thousand-character path) and the header mask (`Date`, the session
cookie's value, a port, `Expires`) are each self-tested on planted lines at every run. Every docker call names the pinned socket;
the container is removed with its volumes; images and volumes are equal at the start and the end.

## Interrupted

SIGINT at five points of a real run of this receipt, each run started with SIGINT reset to its default (U01's finding: a job started
in the background ignores SIGINT, and bash cannot trap a signal ignored at entry), the signal sent to the receipt's own process:

```
mid-build            exit 130 · java 0 · listeners 20920-20929 0 · c9u03-pg 0 · images 9 · volumes 315 · captures unchanged · .r-lock gone · .r-*.new 0
mid-container        (PostgreSQL up, before TiffinBox)                                      the same
mid-tiffinbox-pg     (TiffinBox on 20922, PostgreSQL's JVM)                                 the same
mid-harness          (TiffinBox on 20920, H2's matrix JVM, the harness joined)               the same
mid-exercise         (the exercise's TiffinBox on 20928)                                     the same
after each: c9-tiffinbox = c9-unit04/after (diff -rq empty)
```

Exit `130` is the receipt's own `INT` trap (`exit 130`); its `EXIT` trap stops every JVM of the run by its pid, removes the container
with its volumes and the unfinished captures, and leaves the published ones untouched.

## Planted faults — each caught

Run on a scratch mirror of this folder (its siblings linked read-only; the one plant that changes U04's tree changes a scratch copy of
it), each made to fail first; each ended with its FAIL line (or the receipt's `***` line), exit 1, no traceback:

```
the spoken lines   the hook one byte changed · 406 / four hundred and six in it · "has already read" removed · its claim inverted
                   (XU03) · the exercise one byte changed · 200 / 304 in digits · the gloss one word changed (chk03 spoken, the README gate)
the numbers        "a dozen / thirteen / fifteen codes" (XU03) · the values block typed 13, 15, Boot 7, static 2, Tomcat 3, "Tomcat wrote 3"
six                the cold 406 with 0 statements · its keys unchanged · post-handle yes on it
conditional        If-Match "x" answering 412 · a 304 for If-None-Match with its own ETag
limits, authors    the 413 with no 100 block · a 100 on the Expect-less control · the long line given a witness line · CONNECT's body
                   typed as Boot's · TRACE's ERROR line removed · the advice's 404 typed as Boot's handler's
cannot, five       a cannot ask answering 422, another 429 · a 500 from a TiffinBox request · boom removed · a fifteenth access-log code
                   · "the access log holds fourteen codes" (XU03)
S9.21, S9.3        the key table's rows 1 · a request to U04's pause route (in the capture, and in receipts.sh) · a key header in receipts.sh
instance           instance on Boot's /error body · instance absent from the route's problem body
coverage           a row removed · a window line with no row · the PostgreSQL capture labelled H2 · one byte across the databases
pins               receipts.md5's tree hash wrong · before/ a copy · after's link text with a slash, or to ../c9-unit02/after · one byte
                   changed in a scratch copy of c9-unit04/after · the seven's and the surface's md5 one character off
the checker        inert against an altered census-mid row (and passing on the true one: it can fail and pass) · a listing line it
                   cannot parse · a view over an unreadable matrix
prose              a duration word (README, exercise) · 406 / four hundred and thirteen spoken · each XU03 phrase · the carried
                   families the unit uses ("A PUT is idempotent.", "Most APIs do this.")
the exercise       the solution = the broken · a refused solution passing · a changed What-it-prints line (and the four refused
                   "solutions" fail in every run of record)
the receipt        dk() without the socket · rm without -v · a placeholder · the header mask and the log mask each broken · U04's
                   21281 and Course 8's 20578 bound before the run · a second receipt live (the guard stops this run; the other lives)
```

Eighty-four plants, eighty-four caught. One plant was bad on its first try and is recorded: the "second receipt" stand-in replaced its
shell with `exec sleep`, so the guard's pattern did not see it and the mirror ran to its end (every capture equal to the published
ones - an extra replication, not a run of record); with a live shell the guard stopped the run and left the other process alive.
The S9.14 plant (a shallow-ETag filter on every path) runs in every run of record, in its plant slot.

## What differed from the brief

- Link form: Course 8 U23's two links, as U01 and U02 (flag 1).
- The hook: byte-equal to S1B :273 with its em dash; `wc -w` counts the lone dash, twenty-one words, twenty without it (flag 2).
- The exercise's line: nineteen words, RED #37's count; the brief's `(18 words)` is stale (flag 3).
- Tomcat: refused three before any route, wrote two bodies; `TRACE`'s body is Boot's `/error` (flag 4, #22).
- The author counts, derived per request and per code: Boot's problem-details handler writes six codes over eleven requests, not
   seven; the static handler three codes (its `200` for the stylesheet counts), not two; Tomcat two bodies (flag 5).
- An eighth author class the brief does not list: `OPTIONS /customers` (the `cannot` ask for a two oh four) is answered by Spring
   MVC's own `HttpOptionsHandler`, no TiffinBox method; the rule names it rather than calling it the route.
- The five hundreds: this unit sends no feed request; the only `500` of its access log is `boom`; `feed500` was dropped first (not
   captured, not said) (flag 6).
- "The next lesson" for *Idempotency, Safety and Retries* (flag 7, #31).
- Both databases, PostgreSQL first, every HTTP column equal (flag 8, #24).
- Ten captures from the brief's list plus `six`, and the named checks `inert` and `instance` as captures of their own; the two
  matrix captures hold every request, the others are views recomputed from them by `chk03.py` (flag 9).
- 20926 asserted free and never bound (flag 10); U04's counts cited, no suite (flag 11).
- `instance`: no TiffinBox `setInstance`; every problem body carries the request path; Boot's `/error` bodies carry none (flag 12).
- PostgreSQL's start: U02's (= U04's), trust on the loopback, the jar's own driver `postgresql-42.7.14` (flag 13).
- The warm cache: U04's resolution; the states printed at every counted request of `six` and `census` (flag 14).
- "Fourteen": here it counts final status codes; U04's `after` also has fourteen handler methods - a coincidence (flag 15).
- Viewing order: no key header, no `/api/**`, no `/probe/pauses/**` (flag 16).
- The long line: Tomcat's `400` beside §15.5.15's `414`, said only as the capture shows it (flag 17); its access line is
  `GET -- 400` on this pattern (both `%U` and `%q` print `-`), not the `GET - 400` the boundary's summary shows.
- The boundary's census window `census-mid/census.txt:168-354` holds twenty-five request blocks, not the twenty-seven the prompt
  names; twenty-two of them are requests of this unit and all are equal.
- The access log's lines end their path with `-` (`%q` prints `-` for an empty query): read by the same rule as U02.
- The resolver's own DEBUG line (`ExceptionHandlerExceptionResolver`, "Using @ExceptionHandler …") names the advice class on
  7.0.11: no resolver observer class was written.

## For RED

- The hook and the exercise are byte-equal to the brief; the hook's "already read" is true cold (one read, the cache filled) and
  warm (the cache's answer, no read); the spoken number one is the cold row's only.
- The author rule and its classes (eight, one more than the brief's seven); the counts per request and per code against the brief's
  "route 5 · advice 1 · Boot 7 · static 2 · Tomcat 3"; Tomcat refused three, wrote two.
- `instance`: filled by Framework with the request path on 4.1.3; RFC 9457 §3.1.5's meaning is a reference to this occurrence.
- "Fourteen" twice in Course 9 by U04's tree (codes here, handler methods there): RED's call whether a script says both.
- The spelling gate does not name "CSV" or "ETag"; their spoken forms are SC §10's call, made with TTS samples.
- RED-C9-S1 #1, #22, #23, #24, #31, #36, #37 are each measured or applied above.
- The call-backs, by title only: from the Spring Web MVC course, *Responses: ResponseEntity and Status Codes* (the gloss of a status
  code), *Boot's Default Error Response*, *@ExceptionHandler and @RestControllerAdvice* and *ProblemDetail and RFC 9457* (the
  authors of the problem bodies), *Content Negotiation* (the four oh six), *File Upload and Download* (the multipart limit) and
  *Static Resources and Cache Headers* (the date, the weak `ETag`); from this course, *Resources, URIs and the Method Table* (`TRACE`
  and `CONNECT` are in its table), *Idempotency, Safety and Retries* (the next lesson), *ETags and Conditional GET*, and the titles
  `cannot` names.
- A script must not say: a count but fourteen; the read skipped; the static handler checking `If-Match`; the `ETag` getting a three
  oh four; Spring writing Tomcat's pages; the access log holding only fourteen codes; the feed's `500`.
- `Connection: close` as printed per row: the three `400` answers (`s400a`, `s400b`, `s400c`), both `413` answers, the long line's
  `400`, `CONNECT`'s `501` and `boom`'s `500`; not the `403`, the four oh fours, the four oh fives or the four oh six - U06's to
  read, not voiced here.

## The ledger rows this unit pays

`TRACK-ROADMAP.md:371` names the lesson `the dozen you will actually use, each with a TiffinBox case`; the census found fourteen and
this unit says fourteen (S9.3). No ledger row is owned by U03; C9-10b and C9-10f name its title (`java9_series.TITLES["03"]`, equal,
checked by `chk03.py static`); C9-8 is U20's (the `ETag` that matches nothing: named here, not paid); C9-11 is not re-paid; C9-3's
registry share is the title.

## The values the video may say

Each value below is re-derived at the end of every run from its capture's own lines and asserted equal to this block.

<!-- values: begin -->
- matrix.requests = 47 · the matrix capture's window, H2 (the request blocks)
- matrix.codes = 14 · the matrix capture, the distinct final codes of the asked routes, H2
- matrixpg.codes = 14 · the same on PostgreSQL
- authors.requests = 47 · authors, H2
- authors.codes = 14 · authors, H2
- authors.refused = 3 · authors: no REQUEST witness line (TRACE, CONNECT, the long line)
- authors.wrote = 2 · authors: Tomcat's own pages (CONNECT, the long line)
- authors.req_route = 21 · authors per request
- authors.req_advice = 1 · authors per request
- authors.req_bootpd = 11 · authors per request
- authors.req_static = 8 · authors per request
- authors.req_redirect = 1 · authors per request
- authors.req_booterr = 1 · authors per request
- authors.req_tomcat = 2 · authors per request
- authors.req_options = 1 · authors per request
- authors.code_route = 5 · authors per code
- authors.code_advice = 1 · authors per code
- authors.code_bootpd = 6 · authors per code
- authors.code_static = 3 · authors per code
- authors.code_redirect = 1 · authors per code
- authors.code_booterr = 1 · authors per code
- authors.code_tomcat = 2 · authors per code
- authors.code_options = 1 · authors per code
- six.cold_stm = 1 · six, H2, the cold four oh six's statements
- six.warm_stm = 0 · six, H2, the warm four oh six's statements
- limits.big_bytes = 1500000 · limits, the big file's size by wc -c (the brief's 1,500,000)
- limits.long_page = 435 · limits, H2, Tomcat's page for the long line (bytes)
- cannot.burst_h2 = 5 · cannot, the burst's counter
- five.acc_codes_h2 = 15 · five, the window's distinct access-log codes (the fourteen + the harness's 500)
- inert.moved = 0 · inert, rows moved against the boundary's census
- inert.blocks = 25 · inert, the boundary's request blocks in census-mid:168-354
- instance.problem_h2 = 16 · instance, problem+json answers, H2, each carrying the request path
- cross.differ = 0 · cross, rows whose HTTP columns differ between PostgreSQL and H2
- exercise.css_bytes = 200 · exercise, the broken ask's body bytes (the stylesheet)
- build.libs = 146 · the BOOT-INF/lib count of the built jar
- build.limit_file = 1MB · spring-boot-servlet-4.1.3.jar's metadata, spring.servlet.multipart.max-file-size
- build.limit_header = 8KB · spring-boot-web-server-4.1.3.jar's metadata, server.max-http-request-header-size
<!-- values: end -->
