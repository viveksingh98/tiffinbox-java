# Course 9 · Unit 06 · API Design Review — evidence

Course 9's third anchor change, and the last unit of Section 1. `before` is a link to `../c9-unit05/after` (U05's frozen anchor:
Spring Boot 4.1.3, Framework 7.0.11, Tomcat 11.0.29, the key filter, U05's `PATCH /api/v1/customers/{name}`), pinned by
`harness/tree06.py` against `../c9-unit05/receipts.md5`'s `after-tree` line. `after/` is a frozen copy of `../c9-tiffinbox` after this
unit's change, pinned by its own `after-tree` line; `diff -rq after ../c9-tiffinbox` is empty the day this unit lands. The change is
the review's one code fix: `GET /api/v1/customers/{name}` (a new class, `CustomerReads`, one handler method) beside U05's PATCH, and
its pinning test. Every other route answers as it did.

The hook candidate (BLUE C9-U06's, S1B AMENDMENT Q-c, byte for byte; optional, RED's to keep or cut):

> You can change Priya on TiffinBox's public address, but you cannot read her back: a GET there is refused. So we review every route, one by one.

Both of its facts are this unit's `rows` capture on `before`, on both databases: the merge patch on Priya answers two hundred and
the second client reads her new meals; the GET on the same address answers four-oh-five, `Allow` naming PATCH alone.

The gloss this unit owns (SECTION SHAPE, S1B :388), one sentence on a line of its own; its first spoken use is this line:

A contract: what a route promises its callers: the path, the method, the shapes in and out.

## Runs of record

Three runs, each launched below load1 20 with the load printed on its first line, every build offline, `check_unit9.py 06 --runlog`
PASS on each run's log (the unit gate exits 2: no `06-*.md` script exists yet, expected):

```
bash 3.2.57  ./receipts.sh            14:40 CET, load1 2.53 at the launch (3.30 before verify) · exit 0 · "c9-unit06: every capture = published (9)"
bash 5.3.9   bash receipts.sh         14:46 CET, load1 3.25 (3.59 before verify) · exit 0 · the same
sealed clone a local git clone of HEAD df4ff12 into ".../sealed clone/tiffinbox-java" (a path with a space), this folder and
             c9-tiffinbox's changed files copied in, the seed copied by the receipt itself; bash 3.2.57 ./receipts.sh
                                      14:52 CET, load1 4.36 (4.65 before verify) · exit 0 · the same
every build offline: Downloading/Downloaded from 0 in each Maven log · the ITs' log waits: none timed out
check_unit9.py 06 --runlog <log>: RESULT (run logs): PASS on each (0 grep error lines, R.166)
```

The capture hashes and the harness's file lines (`receipts.md5`), equal in all three runs:

```
before-tree 94 333c596e9a2fd8c5b2485e1845bcce37
after-tree 96 e554c5335a1654dc5a892ed5e418ca83
tests f6a9dbd6e01b414085cf388f3d1a5bc3
mappings b818bcd0bbae4d48ceae3b1c9ee26c02
rowspg 976050a3c5f86cc7beb6b228d1859a64
fixespg e2af086da4705e0678f83d888828ff1f
exercise 4cff11291d561936fc371784b287973f
rows c961d3423188d9be315ebf87b4ce7c06
fixes 3717c45683997e8ba2eecd91c82465f8
moved 26346df2ca535b2a0db05e58ba0e4c1e
inert bfbe81dc1f51e3d4789a0afcfa40efd9
file harness/chk06.py 4cb2790f8ef6613a2bc2508f213929f5
file harness/s906.py dd1afaad9c62fdc80fdf90ae91752ee4
file harness/tree06.py 808c457241a216f6222fa079616e544b
file harness/dur9.py 77d6fcf895637e0beda50c7bdf9a0df0
file harness/src/probe/Etag.java 0c518b8fd1f63014970bf0df96bc9e5a
file harness/src/probe/Http.java aac9acc077572e5c6aad1043c8b6cd55
file harness/src/probe/Routes.java 1b0e6742c9e41fa70268c92ec8e38d80
file harness/src/probe/Witness.java ee8d933cd8f46afac621e4ea63c01510
file harness/src/probe/u06/U06Probe.java 5faa624af8dd51d83e8bc59208650352
file exercise/read.sh 82cb82eebe9b3b93c9bbd3a3c66c4971
file exercise/check.sh bbcc1248a0c833351bc90e062eab6cd2
```

## RE-MEASURE (settled first)

1. **The review's table** (`mappings`, one flag start of `after/` on H2, no harness). The handler methods by `/actuator/mappings`,
   TiffinBox's by class, the others apart (actuator five, `/error` two); the partition is derived from the sources at each commit
   (`git grep`, the pattern anchored at the line's start, so a Javadoc's `{@code @GetMapping}` is not counted - BLUE's finding,
   re-measured: the unanchored pattern counts one line more):

```
after/: handler methods 24 in all · TiffinBox's 17 · others 7
TiffinBox's by class: TiffinBoxServer 7 · DashboardPage 3 · CustomerPatches 2 · CustomerPauses 2 · CustomerFeed 1 · CustomerImport 1 · CustomerReads 1
the partition (default run = mapping annotations - the dev profile's):
  80f7839 the set-up        17 - 5 = 12
  a0a0151 unit 04           19 - 5 = 14   (+2: the pause POST and its GET)
  df4ff12 unit 05           21 - 5 = 16   (+2: the PATCH, one handler per media type)
  after/  unit 06           22 - 5 = 17   (+1: CustomerReads#one GET /api/v1/customers/{name})
the dev profile: nine classes carry @Profile("dev"), five of them a mapping (DishSearch /dishes/search, DishWrite POST /dishes,
  Leaderboard /leaderboard, Menus /menu/{day}, Revenue /revenue/by-customer) - not started on the default run
the write routes (method not GET, HEAD or OPTIONS), as data for unit 26 (C9-13): 7 - the fix adds none
  PATCH /api/v1/customers/{name}       CustomerPatches#jsonPatch   application/json-patch+json     public  not keyed
  PATCH /api/v1/customers/{name}       CustomerPatches#merge       application/merge-patch+json    public  not keyed
  POST  /api/v1/customers/{name}/pauses CustomerPauses#add         -                               public  the key REQUIRED
  POST  /customers                     DashboardPage#add           application/x-www-form-urlencoded old   the form: the filter lets it by
  POST  /customers                     TiffinBoxServer#add         -                               old     the key taken when sent
  POST  /customers/import              CustomerImport#importCsv    multipart/form-data             old     not keyed
  POST  /shutdown                      TiffinBoxServer#shutdown    -                               old     not keyed (its own token)
```

   The sentence a script may say: "the set-up's twelve, two added by the idempotency lesson, two by the PATCH lesson, and one here" -
   the mappings minus what U04 and U05 added is the set-up's twelve (S1B #1, the dated note).

2. **The rows** (`rows`, `rowspg`: each review row's request or pair on `before`, the shipped tree; PostgreSQL 18.6 first, H2 the
   same on every request's status, type, size, `Allow`, `Accept-Patch` and author; the authors by U03's rule, copied). Thirteen rows:
   FIXED three (R7 and R5's address at U04, R13 by this unit), HANDED four (R2, R3, R4, R5's strategy), NAMED seven; R5 is one row
   counted in both halves, as BLUE classed it.

```
row  class                      before (U05's after), PostgreSQL = H2                                         author
R1   NAMED  the name is the     a pause added to Sunil (its Location .../Sunil/pauses/N, 201), Sunil renamed  the route; TiffinBox's
     identity                   Sunny (200): the old address 404, the new 200; the pause's Location 404, the   advice; Boot's pd handler
                                new path 200; the pause row survives (the pause table points at customer_id)
R2   HANDED -> U09              404 "Customer not found" (advice) · 422 "Invalid customer" (U05's route) ·    advice; the route; the route;
     about:blank                400 "Invalid customer" (the create route): no type; only the key filter's     the key filter
                                400 carries one (tag:)
R3   HANDED -> U13  no paging   GET /customers 200, every customer; ?page=1&size=1 the same bytes; no Link    the route
R4   HANDED -> U20  validators  no ETag, no Last-Modified, no Cache-Control on the JSON answers; If-None-Match  the route; the static
                                * and a made-up one: 200; the stylesheet beside: Last-Modified, Cache-Control  handler
R5   FIXED at U04 (address) /   the old GET /customers/Ravi 200 beside the literal /api/v1/ mapping           the route
     HANDED -> U12 (strategy)   (not measured under a versioning strategy)
R6   NAMED  the dev routes      the five dev addresses on the default run: 404 each (NoResourceFound)          Boot's pd handler
R7   FIXED at U04, shown        old POST /customers no key 201, again 409 · the pause route no key 400 (tag:)  the route; the route;
     the key                    · with a key 201 · the same key again 201, the body byte-identical            the key filter; the route;
                                                                                                              the key filter
R8   NAMED  TRACE's body        TRACE /customers 405 application/json, Allow {DELETE,GET,HEAD,OPTIONS,POST,PUT} Boot's /error
R9   NAMED  a 406 that read     GET /customers Accept: text/csv 406, the handler ran (post-handle no); the     Boot's pd handler
     first                      control Accept: application/json 200
R10  NAMED  a GET that keeps    the feed read by count (200 text/event-stream, its first line); its listeners  -
     state for a client gone    0 before, 1 after the client left, 1 after the next stored customer, 0 after a
                                second; the access log's 500 for the abandoned read written then
R11  NAMED  the 405's Allow     PUT /customers 405 Allow {GET,POST} vs OPTIONS {GET,HEAD,OPTIONS,POST}         Boot's pd handler; OPTIONS
R12  NAMED  action-named        GET /kitchen 200 · GET /shutdown 405 Allow {POST} · /customers/import (from   the route; Boot's pd handler
     routes                     the mappings, not asked)
R13  FIXED by U06  a resource   GET /api/v1/customers/Ravi 405 Allow {PATCH}; HEAD 405; PUT 405 {PATCH};       Boot's pd handler; OPTIONS
     you can PATCH but not GET  OPTIONS 200 Allow {OPTIONS,PATCH}; Nobody 405 (not 404); PATCH Priya 200 and   handler; the route
                                GET Priya 405
```

3. **The fix** (`fixes`, `fixespg`: the same requests on `after/`, PostgreSQL first, H2 the same):

```
GET  /api/v1/customers/Ravi    405 Allow {PATCH} (Boot's pd handler)  ->  200 application/json, CustomerReads#one, cold 1 statement, warm 0
HEAD /api/v1/customers/Ravi    405                                   ->  200, Content-Length = the GET's body, no body
OPTIONS                        Allow {OPTIONS,PATCH}                 ->  Allow {GET,HEAD,OPTIONS,PATCH}; Accept-Patch both (as a set)
PUT  /api/v1/customers/Ravi    405 Allow {PATCH}                     ->  405 Allow {GET,PATCH}   (R11's gap, on this address too: NAMED)
GET  /api/v1/customers/Nobody  405                                   ->  404 "Customer not found" (TiffinBox's advice), 1 statement
PATCH then GET on Priya        200, then 405                         ->  200, then 200 with her new meals
the rename Sunil -> Sunny on the public read (warm first): customer [Sunil] evicted after the commit; public old 404 (advice),
  public new 200; the old address old 404, new 200 - one cache entry per name serves both addresses
the old GET /customers/Ravi on before and after/: the same status and the same bytes; on after/ its statement count follows the
  public read's (one shared customer entry - the order decides which read is cold)
no ETag, no Last-Modified, no Cache-Control on the public read; If-None-Match: * -> 200 (validators are unit 20's)
the planted no-evict copy (20955): the old public address 200 from Caffeine, 0 statements - the detector's FAIL
```

   The cannot-fail detector (R.276 + R.374), both directions: the check "the public GET answered two hundred" run on `before`'s
   `rows` capture fails there (four-oh-five); the check "the old public address answered four-oh-four after the rename" run on the
   planted no-evict copy fails there (two hundred).

4. **`moved`** (H2, `before` on 20956 and `after/` on 20950, each its own JVM): U02's method table (four addresses × nine methods),
   U05's eight PATCH answers on the public address, and the new address's GET, HEAD, PUT, DELETE, OPTIONS and a GET for nobody -
   status, type, size, `Allow` and `Accept-Patch` as sets, the body's md5 (Boot's `timestamp` masked). The only lines that moved are
   the new address's own six: the one compatible move (S9.37), named here. C9-10a's pinned sentence stays true on `after/`: a PATCH to
   slash customers still answers four-oh-five, and its Allow header names POST and GET. U05's README says the new address answers no
   read; from this unit's `after` on that sentence is history (For RED).

5. **The tests per runner** (`tests`, `mvn -o clean verify` on a copy of `after/`, under R.480): U05's tests and `CustomerReadsTest`'s
   at the test phase (H2, Docker-free), the five ITs on `127.0.0.1:21280`-`21284`:

```
the test phase: 44 = U05's 40 (its README values block) + CustomerReadsTest 4
  CustomerPatchesTest 12 · CustomerReadsTest 4 · FeedTest 1 · FullStackTest 3 · IdempotencyKeyTest 7 · TiffinBoxWebTest 14 · TransactionAwareCachingTest 3
the ITs: 14 in 5 classes - CustomerEntityRepositoryIT 3 · CustomerAggregatesIT 2 · ElasticsearchIT 2 · MongoDatastoreIT 4 · RedisDatastoreIT 3
IT BINDINGS: classes 5 · entries 5 · not 127.0.0.1: 0 · the Elasticsearch wait: did not time out
BOOT-INF/lib 146 before, 146 after; no jar's name moved (no dependency moves)
```

6. **The seven and the old surface** (`inert`, H2, each set in its own JVM, no key header) on `before` and on `after/`: both equal to
   U05's values block, read by U05's reader (the feed by count), and the S9.14 plant moves the surface and leaves the seven.

## The change, file by file, and every README/Javadoc sentence it rewrote or noted (R.250/R.453)

- `tiffinbox-web/.../CustomerReads.java` (new): `final`, package-private, `@RestController`, one handler method
  `one` - `GET /api/v1/customers/{name}`, a literal mapping, no `version` attribute (⚑2) - `CustomerRepository.findByName` and
  `CustomerNotFound`, the old read's path through the `customer` cache. Taken from BLUE's design byte for byte. A new class, not a
  method on `CustomerPatches`: that class's Javadoc says it is the public API's partial update (one concern per class, as
  `CustomerPauses` and `CustomerImport`).
- `tiffinbox-web/src/test/.../CustomerReadsTest.java` (new): BLUE's four tests on the whole application (H2, over a socket), with
  RED-C9-U06's correction (a): the three asserts that the public read sends no `ETag`, `Last-Modified` or `Cache-Control` are dropped
  (a test that pins a missing feature would go red when *ETags and Conditional GET* adds it); the absence is a `fixes` line instead.
  Its Javadoc says so. Still four tests.
- `README.md`: a note beginning *Course 9, unit 06* after U05's in the header; a `## Course 9 · unit 06` card.
- Not changed: every other file of the anchor (`chk06.py static`: before and after differ in these three paths only) - no
  dependency, property, migration or problem type; the key filter, `TiffinBoxErrors` and `CustomerPatches` untouched.

The hunt over `c9-tiffinbox/` (`git grep -n`): `GET`, `no GET`, `answers no read`, `a GET on the new address`, `Allow`, `handler
methods`, `twelve`, `40`, `tests`, `Not in this change`, `named, not` - every hit is history in a dated unit section or a Course 8
sentence about the old routes, still true; U05's card's sentences (its answers table, "The old addresses keep their four-oh-five
for a PATCH", "PATCH is not keyed") stay true; `CustomerPatches`' Javadoc names no read. `chk06.py static` asserts the note, the
card and the absence of the stale forms.

R.211/R.331's grep (`c9-tiffinbox` in `c9-unit0{1..5}/receipts.sh`, their `harness/*`, `C9/_builders/*.py` and the Java 9 tools):

```
c9-unit01-05/receipts.sh  after/ against ../c9-tiffinbox: a NOTE (U01/U04 since 959f6ae; U02, U03, U05 born so); U04's and U05's end
                          sweeps compare the note at the start with the note at the end - a later unit's move is not a stop
c9-unit01/receipts.sh :97 git grep at the pinned set-up commit - not the live tree
c9-unit0{1,2,3,5}/receipts.sh, c9-unit04 :521   find ../c9-tiffinbox -name '*.mv.db' - a sweep, not an equality
c9-unit03/receipts.sh :197-198 and harness/chk03.py :509-519   LIVE READS of ../c9-tiffinbox's main sources (setInstance;
                          ProblemDetail.forStatus… lines) - this change adds neither (CustomerReads throws CustomerNotFound), so U03's
                          view is as U05 left it (U05's hand-off: it already differs from U03's published capture at HEAD)
c9-unit04/receipts.sh :81 git archive at the set-up commit 80f7839 - pinned
C9/_builders/clone_java9_tools.py, T/upload_java9.py      the name in a constant or a comment - no read of the tree
no die on the live anchor is left: nothing for the orchestrator here
```

## Which tree, which profile

`before` = `../c9-unit05/after` (a link, its text exact), `after/` = this unit's frozen copy; both built offline under `.harness/`
from a `cp -c` copy of `m2-seed-c9-u04`. The default run (H2 in memory) and PostgreSQL 18.6 by digest (the image U05's receipts
name) through `-Dtiffinbox.jdbc-url`, the jar's own driver `postgresql-42.7.14.jar`. Every JVM prints Tomcat `11.0.29`, Hibernate ORM
`7.4.15.Final`, Boot `4.1.3`, Framework `7.0.11`, Jackson `3.1.8` (the `jackson-databind` jar of major three; Spring MVC's converter
writes every JSON body here with it) and the database it answered from. Jackson 2 is on the class path through the Elasticsearch
client only; no body of this unit comes from it.

## Unit 06's section (the mini-probe's, #29)

BLUE C9-U06 wrote the section's design (S1B AMENDMENT, Q-a to Q-d); this unit measured each line of it on its own tree:

- **The spine** (S1B :354-355): the review's table off `mappings`, one row at a time, each row fixed on the public API, handed on by
  title or named - kept; R13 is the row BLUE added and the one this unit's code fixes.
- **The hook candidate**: above, the facts in `rows` (R13). Optional; RED keeps or cuts it.
- **The failure receipt**: `rows` - each row's answer on the shipped tree beside its negation; no row is "the one".
- **The numbers**: the values block below; every one a capture's line.
- **The exercise**: `exercise/` - the spoken line is RED-C9-U06's correction (c), twenty-four words.
- **The hazards, measured**: one cache entry per name serves both addresses (the old read's statement count follows the public
  read's); HEAD answers the GET's `Content-Length` with no body; `Allow` and `Accept-Patch` come in no fixed order from one JVM
  start to the next (read as sets); a variable named `path` in a script sourced by zsh is zsh's `PATH` (planted below); the pause's
  `Location` dies with the old name while its row stays.

## The captures — what each one shows

### tests — the counts per runner, the jars
`mvn -o clean verify` on `.harness/tests` (a copy of `after/`): Surefire's XML per class, Failsafe's per IT, the five `IT BINDINGS`
lines, `BOOT-INF/lib` before and after.

### mappings — the review's input
The flag start's `/actuator/mappings` read by the boundary's reader rule (`census.sh`'s, copied into `chk06.py`), the partition by
commit from the sources, the dev classes by source line, the key filter's table read off its source.

### rows, rowspg — the failure receipt
`before`'s JVM with the harness joined; one request or pair per row, each with its witnesses (curl's headers, the access log's line,
the request witness, the resolver's line, the statement count, the second client - `psql` in the container on PostgreSQL, the
harness's JdbcTemplate route on H2 - and both caches' keys where they matter). Only the three `k-` requests send a key header.

### fixes, fixespg — the pair
`after/`'s JVM: the same requests, the old route beside, the rename round trip on the public read, then the planted no-evict copy's
JVM on 20955.

### moved — the old routes keep their answers
Fifty requests on each tree; the six moved lines named.

### inert — the seven and the old surface
U05's reader, U05's expected hashes; the S9.14 plant (a shallow-ETag filter on every path, the harness's) in its own JVM.

### exercise — under bash and zsh, PostgreSQL and H2
`read.sh` as shipped, `SOLUTION.md`'s line in its place, five refused "solutions", each against TiffinBox's jar alone on 20958
(a fresh JVM and database per try), `env -i`, from the exercise's folder.

## Measured, not shipped

The harness (`--spring.main.sources`, never in the jar): `probe.Witness` and `probe.Http` (the statement and request witnesses),
`probe.Routes` (the second client's row on H2), `probe.u06.U06Probe` (`/probe/u06/cache`, `/keys`, `/rows/{name}`, `/count`,
`/pauses/{name}`, `/feed` - the feed's listeners by reflection), `probe.Etag` (the S9.14 plant), the planted no-evict
`CustomerRepository`, the resolver's DEBUG line (harness logging), the flag start that exposes `mappings`.

## Refused, named

Each in a code span, as the prose gate reads it: `RESTful` and every verdict word about a route without its row; `every row is
fixed` (three fixed, four handed on, seven named); `the old route is deprecated` or `replaced` (the old routes stay and answer as
they did, on purpose: S9.2); the key filter extended (U04's frozen lesson); `about:blank is wrong` (RFC 9457 names it the type when
none is given); a public create; an `id` (the name stays the identity: NAMED); `the contract` for the generated document
(*OpenAPI: The Contract* owns it); a count of routes said without its partition; a time printed under load.

## The repository, and the network

`D` = `_deliverables/tiffinbox-java`, HEAD at the start `df4ff12` (U05), with `c0b0e73` (U03), `959f6ae` (the receipts-note fix),
`cabc6d3` (U02), `f688858` (U01) and `a0a0151` (U04) its ancestors; `origin/main...main` = `0 0` from the local tracking ref. ONE
commit for `c9-unit06/` and `c9-tiffinbox/`'s changed paths, pushed. No network of any kind but that push: every build offline from
the seed's copy (`Downloading from` 0), no image pulled, RFC 9457 the filed copy in `docs-2026-11-23`, no advisory read or cited.

## The folders, the harness and the ports

`before` (the link), `after/` (the frozen copy) · `receipts.sh`, `receipts.md5` · `harness/` (`chk06.py`, `s906.py`, `tree06.py`,
`dur9.py`, `src/probe/{Witness,Http,Etag,Routes}.java`, `src/probe/u06/U06Probe.java`) · `exercise/` (`README.md`, `read.sh`,
`check.sh`, `SOLUTION.md`) · `README.md`. `Witness`, `Http`, `Etag`, `Routes` = U05's published files (its `receipts.md5`). Ports,
U06's band: `20950` after/ on H2 · `20951` PostgreSQL · `20952` after/ on PostgreSQL · `20953` the S9.14 plant · `20954` the flag
start · `20955` the planted no-evict JVM · `20956` before (both databases, one at a time) · `20957` asserted free · `20958` the
exercise · `20959` never bound; `21280`-`21284` during `verify` only.

## Masks, filters and hygiene

The log mask and the header mask are self-tested on planted lines at every run. `Allow` and `Accept-Patch` are printed as sent and
as a sorted set; the hash reads the set. Every docker call names the pinned socket; the container is removed with its volumes;
images and volumes are equal at the start and the end.

## Interrupted

SIGINT at six points of a real run of this receipt (development runs, `NOPIN=1` and `DEVCAPS` naming the capture the point lies in,
so the point comes sooner), each run started with SIGINT reset to its default (U01's finding: a job started in the background ignores
SIGINT, and bash cannot trap a signal ignored at entry), the signal sent to the receipt's own pid at a count condition on its log,
Docker's state or the capture's raw file:

```
mid-build: exit 130 · java 0 · listeners 20950-20959 and 21280-21284 0 · c9u06-pg 0 · Testcontainers 0 · images 9 · volumes 315 · captures unchanged · .r-lock gone · .r-*.new 0 · c9-tiffinbox = after/ yes
mid-verify: exit 130 · java 0 · listeners 20950-20959 and 21280-21284 0 · c9u06-pg 0 · Testcontainers 0 · images 9 · volumes 315 · captures unchanged · .r-lock gone · .r-*.new 0 · c9-tiffinbox = after/ yes
mid-container: exit 130 · java 0 · listeners 20950-20959 and 21280-21284 0 · c9u06-pg 0 · Testcontainers 0 · images 9 · volumes 315 · captures unchanged · .r-lock gone · .r-*.new 0 · c9-tiffinbox = after/ yes
mid-tiffinbox-pg: exit 130 · java 0 · listeners 20950-20959 and 21280-21284 0 · c9u06-pg 0 · Testcontainers 0 · images 9 · volumes 315 · captures unchanged · .r-lock gone · .r-*.new 0 · c9-tiffinbox = after/ yes
mid-harness: exit 130 · java 0 · listeners 20950-20959 and 21280-21284 0 · c9u06-pg 0 · Testcontainers 0 · images 9 · volumes 315 · captures unchanged · .r-lock gone · .r-*.new 0 · c9-tiffinbox = after/ yes
mid-exercise: exit 130 · java 0 · listeners 20950-20959 and 21280-21284 0 · c9u06-pg 0 · Testcontainers 0 · images 9 · volumes 315 · captures unchanged · .r-lock gone · .r-*.new 0 · c9-tiffinbox = after/ yes
```

Exit `130` is the receipt's own `INT` trap; its `EXIT` trap stops every JVM of the run by its pid, removes the Testcontainers
containers by their label and the PostgreSQL container with their volumes, and drops the unfinished captures. The points came before
the plants; no README edit while one was live.

## Planted faults — each caught

Run on a scratch mirror of this folder (its siblings linked read-only; `plants.sh` in the evidence agent's scratch folder), each made
to fail first; each ended with its FAIL line, the prose gate's refusal or the receipt's `***` line, a non-zero exit, no traceback.
The receipt plants died at the gate, before any build or container. The near misses of `XU06` pass (five shown, the rest in
`s906.py`'s self-test, which asserts every plant and near miss of `XFAM_S9S1` and `XU06` before it judges a line):

```
(1) rows: R9's 406 answering 200 · FAIL r9-csv: GET /customers -> 200 (want 406)
(2) rows: R3's paging query changing the bytes · FAIL R3: the paging query changes nothing (the same bytes)
(3) rows: an ETag on a JSON answer (R4) · FAIL R4: r4-ravi carries no ETag, no Last-Modified, no Cache-Control (validators {ETag})
(4) rows: the 404's body carrying a type (R2) · FAIL R2: of 4 error bodies, only the key filter's carries a type (tag:) - ['r2-404', 'k-r7-pause-nokey']
(5) rows: the feed answering without its first line (R10) · FAIL R10: the feed answers 200 and its first line by count
(6) rows: a row removed (R8's TRACE) · FAIL r8-trace: no request block
(7) rows: the author swapped (TiffinBox's 404 resolved by Boot's handler) · FAIL r2-404: the author is Boot's problem-details handler (the resolver's line: ProblemDetailsExceptionHandler#ha
(8) rows: a key header on a request outside the listed ones · FAIL the key header sent by exactly ['k-r1-pause', 'k-r7-pause-key', 'k-r7-pause-replay'] (found ['k-r1-pause', 'k-r7-pause-key
(9) rows: the pause route answering 201 with no key (the fix absent) · FAIL k-r7-pause-nokey: POST /api/v1/customers/Ravi/pauses?days=1 -> 201 (want 400)
(10) rows: the public GET answering 200 on before (R13) · FAIL r13-get: GET /api/v1/customers/Ravi -> 200 (want 405)
(11) rows: a line the reader cannot parse (the tracebacking checker, Course 8 U25's class) · FAIL a sub-line the reader cannot parse: 'stutus lines: HTTP/1.1 405'
(12) rows (cross-database): one planted byte in H2's r5-old size · FAIL PostgreSQL and H2 equal on status, type, size, Allow, Accept-Patch and author (moved: ['r5-old'])
(13) rows: the database label swapped (PostgreSQL's capture said to be H2's) · FAIL which database answered: PostgreSQL (Flyway's line PostgreSQL 18.6), every second-client line names psql 
(14) mappings: the total typed one off · FAIL one mapping line per TiffinBox handler method (17 lines, 18 counted)
(15) mappings: a mapping line removed · FAIL one mapping line per TiffinBox handler method (16 lines, 17 counted)
(16) mappings: the dev mappings typed 4 · FAIL the dev profile: nine classes, five mappings, at every commit
(17) fixes: the public GET answering 405 on after/ · FAIL f-get: GET /api/v1/customers/Ravi -> 405 (want 200)
(18) fixes: the no-evict copy swapped into the slot (the old public address 404 there) · FAIL n-pub-old: GET /api/v1/customers/Sunil -> 404 (want 200)
(19) fixes: the shipped rename's old public address answering 200 · FAIL f-pub-old: GET /api/v1/customers/Sunil -> 200 (want 404)
(20) fixes: the old route's answer moved by one byte on after/ · FAIL the old GET /customers/Ravi: the same status and body on before and after/ (S9.2)
(21) fixes: the cannot-fail detector run against a before capture that answered 200 · FAIL the cannot-fail detector: the check 'the public GET answered 200' FAILS on before's capture (.r-ro
(22) fixes: the key table holding a row after the keyless capture · FAIL the key table: 0 rows (no request of this capture sent a key)
(23) moved: an old address's Allow drifted by one method (PATCH /customers {GET,HEAD,POST}) · FAIL moved: exactly the new address's own lines (S9.37, the one compatible move): ['DELETE /api
(24) moved: U05's route answer moved on after/ (a planted 200 -> 204) · FAIL moved: exactly the new address's own lines (S9.37, the one compatible move): ['DELETE /api/v1/customers/Ravi', '
(25) tests: an IT BINDINGS line removed (4 classes) · FAIL IT BINDINGS: classes 5 (found 4)
(26) tests: an IT on 127.0.0.2 · FAIL IT BINDINGS: entries 5 · not 127.0.0.1: 1
(27) tests: one IT's port off by one · FAIL ElasticsearchIT on 127.0.0.1:21284
(28) tests: CustomerReadsTest's count off (U05's 40 + k) · FAIL the test phase: 45 = U05's 40 (its README values block) + 4 (CustomerReadsTest)
(29) inert: the seven's md5 one character off · FAIL after: the seven = 466c20ed
(30) inert: the S9.14 plant's surface unmoved · FAIL the ETag plant: the seven unchanged, the old surface moved
(31) exercise: broken = solved (the broken run passing) · FAIL pg broken (bash): FAIL with status 404
(32) exercise: a refused solution passing (the right request to the wrong customer) · FAIL pg other (bash): FAIL with status 200
(33) values: one value of the block typed off (seven) · FAIL README.md has no values block
(34) the gloss one word changed · FAIL the gloss's quoted words are S1B :388's: 'A contract: what a route promises its callers: the path, the method, the shape in and out.'
(35) the exercise written with 404 in digits · FAIL the exercise's line is RED-C9-U06's correction (c), byte for byte (ev06-prompt.md's note)
(36) the exercise written with 200 in digits · FAIL the exercise's line is RED-C9-U06's correction (c), byte for byte (ev06-prompt.md's note)
(37) the exercise at 26 words · FAIL the exercise's line is RED-C9-U06's correction (c), byte for byte (ev06-prompt.md's note)
(38) the exercise in the hundred form (four hundred and four) · FAIL the exercise's line is RED-C9-U06's correction (c), byte for byte (ev06-prompt.md's note)
(39) the hook candidate with 405 in digits · FAIL the hook candidate is BLUE C9-U06's (S1B AMENDMENT Q-c), byte for byte (whitespace of the brief's line breaks collapsed)
(40) the hook candidate one byte changed · FAIL the hook candidate is BLUE C9-U06's (S1B AMENDMENT Q-c), byte for byte (whitespace of the brief's line breaks collapsed)
(41) the exercise voicing a file name (RED-C9-U06 #11's old form) · FAIL the exercise's line is RED-C9-U06's correction (c), byte for byte (ev06-prompt.md's note)
(42) s906: "Every row is fixed." · FAIL /private/tmp/claude-501/-Users-viveksingh-Downloads-OneID-Fable/624c4153-a086-4cf6-bc00-e8de6b1d6ea4/scratchpad/c9-ev06/p.md line 1: XU06: U06: every
(43) s906: "The old route is deprecated." · FAIL /private/tmp/claude-501/-Users-viveksingh-Downloads-OneID-Fable/624c4153-a086-4cf6-bc00-e8de6b1d6ea4/scratchpad/c9-ev06/p.md line 1: XU06: U
(44) s906: "The public API replaces the old one." · FAIL /private/tmp/claude-501/-Users-viveksingh-Downloads-OneID-Fable/624c4153-a086-4cf6-bc00-e8de6b1d6ea4/scratchpad/c9-ev06/p.md line 1:
(45) s906: "About:blank is wrong." · FAIL /private/tmp/claude-501/-Users-viveksingh-Downloads-OneID-Fable/624c4153-a086-4cf6-bc00-e8de6b1d6ea4/scratchpad/c9-ev06/p.md line 1: XU06: U06: abo
(46) s906: "The key is optional." · FAIL /private/tmp/claude-501/-Users-viveksingh-Downloads-OneID-Fable/624c4153-a086-4cf6-bc00-e8de6b1d6ea4/scratchpad/c9-ev06/p.md line 1: XU06: U06: the 
(47) s906: "The answers carry no validators." · FAIL /private/tmp/claude-501/-Users-viveksingh-Downloads-OneID-Fable/624c4153-a086-4cf6-bc00-e8de6b1d6ea4/scratchpad/c9-ev06/p.md line 1: XU0
(48) s906: "TiffinBox has sixteen routes." · FAIL /private/tmp/claude-501/-Users-viveksingh-Downloads-OneID-Fable/624c4153-a086-4cf6-bc00-e8de6b1d6ea4/scratchpad/c9-ev06/p.md line 1: XU06: 
(49) s906: "The dev routes are dead code." · FAIL /private/tmp/claude-501/-Users-viveksingh-Downloads-OneID-Fable/624c4153-a086-4cf6-bc00-e8de6b1d6ea4/scratchpad/c9-ev06/p.md line 1: XU06: 
(50) s906: "The feed leaks." · FAIL /private/tmp/claude-501/-Users-viveksingh-Downloads-OneID-Fable/624c4153-a086-4cf6-bc00-e8de6b1d6ea4/scratchpad/c9-ev06/p.md line 1: XU06: U06: the feed 
(51) s906: "Use an id." · FAIL /private/tmp/claude-501/-Users-viveksingh-Downloads-OneID-Fable/624c4153-a086-4cf6-bc00-e8de6b1d6ea4/scratchpad/c9-ev06/p.md line 1: XU06: U06: the name is a 
(52) s906: "The generated document is the contract." · FAIL /private/tmp/claude-501/-Users-viveksingh-Downloads-OneID-Fable/624c4153-a086-4cf6-bc00-e8de6b1d6ea4/scratchpad/c9-ev06/p.md line
(53) s906: "The old API is RESTful." · FAIL /private/tmp/claude-501/-Users-viveksingh-Downloads-OneID-Fable/624c4153-a086-4cf6-bc00-e8de6b1d6ea4/scratchpad/c9-ev06/p.md line 1: XFAM_S5: S5:
(54) s906: "The four oh six is wasteful." · FAIL /private/tmp/claude-501/-Users-viveksingh-Downloads-OneID-Fable/624c4153-a086-4cf6-bc00-e8de6b1d6ea4/scratchpad/c9-ev06/p.md line 1: XU06: U
(55) s906: "A PATCH answers four-oh-five." · FAIL /private/tmp/claude-501/-Users-viveksingh-Downloads-OneID-Fable/624c4153-a086-4cf6-bc00-e8de6b1d6ea4/scratchpad/c9-ev06/p.md line 1: XU06: 
(56) s906: "It answers 406." · FAIL /private/tmp/claude-501/-Users-viveksingh-Downloads-OneID-Fable/624c4153-a086-4cf6-bc00-e8de6b1d6ea4/scratchpad/c9-ev06/p.md line 1: XU06: U06: a status 
(57) s906: "The read returns in a second." · FAIL /private/tmp/claude-501/-Users-viveksingh-Downloads-OneID-Fable/624c4153-a086-4cf6-bc00-e8de6b1d6ea4/scratchpad/c9-ev06/p.md line 1: dur8: 
(58) s906: "The cache catches up after ten minutes." · FAIL /private/tmp/claude-501/-Users-viveksingh-Downloads-OneID-Fable/624c4153-a086-4cf6-bc00-e8de6b1d6ea4/scratchpad/c9-ev06/p.md line
(59) s906: "Spring decides the answer." · FAIL /private/tmp/claude-501/-Users-viveksingh-Downloads-OneID-Fable/624c4153-a086-4cf6-bc00-e8de6b1d6ea4/scratchpad/c9-ev06/p.md line 1: XU06: U06
(60) s906: "REST requires a GET." · FAIL /private/tmp/claude-501/-Users-viveksingh-Downloads-OneID-Fable/624c4153-a086-4cf6-bc00-e8de6b1d6ea4/scratchpad/c9-ev06/p.md line 1: XFAM_S9S1: S9S1
(61) check.sh with path under zsh -f (the right answer refused: zsh's path is PATH) · FAIL FAIL: status 200 · /api/v1/customers/Priya · the body's name none
(62) README: the gloss one word changed · *** the gloss (SECTION SHAPE 06, S1B :388) must stand in README.md once, as a line of its own, byte for byte: A contract: what a route promises its
(63) exercise/README.md: the spoken line one byte changed · *** exercise/README.md: the spoken exercise line ***
(64) before: the link text ../c9-unit04/after (the stale form) · *** before must be a link whose text is exactly ../c9-unit05/after (found: ../c9-unit04/after) ***
(65) before: the link text ../c9-unit05/after/ · *** before must be a link whose text is exactly ../c9-unit05/after (found: ../c9-unit05/after/) ***
(66) before: a copy, not a link · *** before must be a link whose text is exactly ../c9-unit05/after (found: not a link) ***
(67) receipts.md5: the after-tree hash typed wrong · *** R.211: after/'s tree is 96 e554c5335a1654dc5a892ed5e418ca83, the pin in receipts.md5 is 96 0e554c5335a1654dc5a892ed5e418ca83 - the t
(68) README: a duration word · *** a refused word or reading in this unit's prose:   README.md line 287: dur8: a second;  README.md line 287: XFAM_S2: S2: in a moment - a duration dur8 miss
(69) README: a status in digits in a spoken sentence · *** a refused word or reading in this unit's prose:   README.md line 287: XU06: U06: a status said as digits or in the hundred form **
(70) README: an XU06 phrase · *** a refused word or reading in this unit's prose:   README.md line 287: XU06: U06: every row is fixed ***
(71) README: a placeholder line · *** a placeholder in this unit's prose or exercise: README.md:<n>:<the planted word> ***
(72) exercise/check.sh: a variable named path · *** exercise/check.sh names a variable path - under zsh that is the PATH array (BLUE C9-U06's finding): rpath ***
(73) exercise: the broken What it prints = the solved one · *** R.196: the exercise's broken and solved blocks print the same ***
(74) receipts.sh: the key header on a request not labelled k- · *** S9.21: the key header is sent by a request not labelled k- (1) ***
(75) receipts.sh: the docker CLI unpinned under DOCKER_HOST=tcp://127.0.0.1:1 (R.344) · *** R.344: dk() must name the pinned socket ***
(76) receipts.sh: a container removed without -v (R.322/R.387) · *** R.387: receipts.sh removes a container without its volumes (found: dk rm -f|dk rm -fv) ***
(77) receipts.sh: a Maven build without -am (R.391) · *** R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am ***
(78) a port of the band bound before the run (20957), the anchor a byte off: the note printed, then the port gate · *** something already listens on 20957 - this unit's ports must be free *
(79) receipts.sh: a die restored on the start's anchor line (the second orchestrator note) · FAIL receipts.sh: the anchor check at the start is a NOTE (no die on it); the end's check is the
(80) after/README.md: a stale sentence left (the new address answers no read) · FAIL the stale hunt (R.250): README.md says nothing the read makes false (['answers no read'])
(81) s906.py: U01's binding broken (u04 bound to another judge) · FAIL U06's own family (XU06) follows the carried slice; u04 = u06 (U01's binding)
(82) chk06.py: the author rule one byte off U03's · FAIL author() = U03's chk03.py's, byte for byte (md5 7cbc51170fff7b5be557b1b0141a7113, 16 lines)
(83) CustomerReadsTest: a missing validator pinned (RED-C9-U06 #3's form) · FAIL CustomerReadsTest pins no missing validator (RED-C9-U06 #3: the absence is a fixes capture line, U20's)
(84) after/: a file the change does not name · FAIL no other file differs between before and after/ (before 94 files, after/ 97) ['tiffinbox-web/src/main/resources/extra.txt']
(85) a build log with a Downloading from line (receipts.sh's offl, the same two lines) · *** /private/tmp/claude-501/-Users-viveksingh-Downloads-OneID-Fable/624c4153-a086-4cf6-bc00-e8de6b1d
plants: 85 of 85 caught
```

## What differed from the brief

Read for this: `ev06-prompt.md` whole (its three closing notes bind), `ev05-prompt.md` whole, S1B's `## AMENDMENT (BLUE C9-U06
2026-11-24)`, `_briefs/RED-C9-U06-2026-11-24.md`, `C9/FACTORY-NEXT.md`'s `EVIDENCE 05 LANDED` section and the 13:53 / 14:00 / 14:03
lines, `c9-unit05/` at `df4ff12` (`receipts.sh`, `harness/chk05.py`, `README.md`'s values block), `git log -8`.

- **Flag 1 (anchor change?)** - DECIDED by BLUE (the orchestrator's note): YES, the anchor-change cap, no fallback; the decision point was spent by BLUE.
- **Flag 2 (`before`)** - `../c9-unit05/after`, as picked; the pin read off `c9-unit05/receipts.md5`'s `after-tree` line at run time.
- **Flag 3 (no mini-probe)** - BLUE C9-U06 WAS the mini-probe (#29); this README's "Unit 06's section" measures its lines.
- **Flag 4 (failure receipt)** - `rows` on `before`, as picked.
- **Flag 5 (the fix set)** - DECIDED: candidate (a) only, `CustomerReads` and `CustomerReadsTest` from BLUE's `design/`, the test with RED's
  correction (a) (three asserts dropped). No other candidate built.
- **Flag 6 (the name)** - NAMED; measured on Sunil (BLUE's choice, not the prompt's Meera): the pause row survives the rename (the pause
  table points at `customer_id`), its `Location` dies with the old name.
- **Flag 7 (moved)** - run on U02's whole method table plus U05's eight PATCH answers and the new address: six lines moved, all on the
  new address (DELETE's `Allow` among them - the prompt listed GET, HEAD, PUT and OPTIONS). C9-10a true on `after/`.
- **Flag 8 (hook, gloss)** - BLUE's hook candidate and gloss carrier line, byte for byte, typed once in `chk06.py`; `check_unit9.status_forms`
  could not be loaded by the system `python3` (`check_unit9.py` imports `build_units`, which needs numpy, the venv's) - the checker's
  own status pattern and the prose gate's ran instead; the run-log gate (venv) runs `check_unit9.py` itself.
- **Flag 9 (the key rows)** - FIXED at U04, shown; the pause route's no-key four hundred and the replay are authored by the key filter.
- **Flag 10 (the exercise)** - RED's correction (c) line; the shape BLUE's (`read.sh`, `check.sh` with `rpath`). Five refused "solutions"
  (the old address, PATCH, `Accept: text/csv`, Ravi, `/api/v1/customer/`), run on PostgreSQL then H2 (RED's correction (e)).
- **Flag 11 (`about:blank`)** - worded by the capture: of the four error bodies asked, only the key filter's carries a `type`.
- **Flag 12 (counts)** - the anchored grep (BLUE's finding, confirmed: the unanchored pattern counts one more). The flag start runs with
  no harness, so its total holds no harness route (BLUE's had seven). `census.sh` is not runnable outside the boundary's scratch (it
  sources a scratch `lib.sh`): its md5 is printed and its python reader rule copied into `chk06.py mapjson`.
- **Flag 13 (write routes)** - listed by the mappings and the filter's source; no "who may call" claim (Course 10's).
- **Flag 14 (frozen receipts)** - the grep above; none of U01-U05's receipts dies on the live anchor any more.
- **Flag 15 (PostgreSQL)** - U05's landed start, the digest = U05's `IMG=`.
- **Flag 16 (the anchor check)** - the note at the start, the "moved during the run" check at the end; `chk06.py static` asserts the form.
- **Flag 17 (the author rule)** - U03's `author()` copied byte for byte (static compares the slice). U03's rule has no class for a servlet
  filter that answers before a handler is chosen; ONE rule is added after it, named, in `author6()`: the key filter (IdempotencyKeyFilter).
- **`Flag 18` (where evidence exists)** - R10 re-measured on `before` (RED's correction (b)), not cited from U02's `safe`; TRACE re-asked.
- **R10's second event** - measured, not in the brief: the departed client is still listed after the next stored customer and dropped
  only at the second, and the access log's five hundred for the abandoned feed read is written then (the census's fifteenth code). The second
  stored customer is its own line, not a request block, because the feed's async error is resolved inside its window.
- **R4's stylesheet** - the static handler sends `Last-Modified` and `Cache-Control`, not an `ETag` (U01 wrote of a weak ETag on another
  request: unit 01's own capture, not re-run).
- **One `mvn verify` per run** (U05's form): the test phase's counts come from it.
- **Ports** - `20956` serves `before` on both databases, one JVM at a time (the prompt named it for H2).
- **Dropped** - nothing of the never-dropped list; the feed's emitter count is measured (cheap), TRACE re-run.

## For RED

- The fix: `CustomerReads#one`, BLUE's, unchanged; `CustomerReadsTest` with correction (a). Tests `44` at the test phase (U05's `40` + `4`).
- The rows: thirteen, FIXED three · HANDED four · NAMED seven, R5 counted in both halves.
- The gloss's first spoken use: the line under the hook in this README. Hook candidate `27` words, exercise `24`, gloss `17`; every gate `0`.
- `contract` vs U07's title: no spoken line says `the contract`; `XU06` refuses it outside the near miss.
- GET, PATCH and JSON spoken: the spelling gate names none of them; their TTS forms are the scripts stage's.
- The one compatible move: the new address's six lines. **U05's README says the new address answers no read** (its `moved` check and
  its "Not in this change" line) - true of U05's tree, history from this unit's `after` on; a script for unit 05 must not voice it as
  current once unit 06 is viewed.
- `about:blank`: four error bodies, one typed (the key filter's `tag:`), RFC 9457 section 4.2.1's SHOULD read off the filed copy.
- The key rows are "FIXED at U04, shown"; the key filter is the author of the no-key four hundred and of the replay (a ninth class, `author6`).
- The counts' partition: the set-up's twelve, U04's two, U05's two, U06's one; the sentence "the mappings minus what U04 and U05 added".
- The write routes for U26: seven, the fix adds none.
- The frozen receipts' anchor assertions: notes everywhere; U03's live-source `instance` view unchanged by this unit.
- The dur9 md5 is the registry's `DUR9_MD5`, equal to U01-U05's copies and `C9/_builders/dur9.py`.
- RED-C9-S1 #1 (counts derived), #18c (the name: NAMED, measured), #20 (the feed: measured on `before`), #21 (`Allow` gap, now on the
  public address too), #29 (the section above), #33 (`about:blank`); BLUE C9-U04 #19 (the pause GET counted in U04's two).
- The next anchor change is **U07** (SETUP row 07, springdoc - RED's correction (d)): U07's `before` = `../c9-unit06/after`; the seven,
  the old surface and the tests per runner are re-run there, never carried across it.

## The ledger rows this unit pays

`TRACK-ROADMAP.md:374`: "06 **API Design Review** - a bad TiffinBox API critiqued endpoint by endpoint, then fixed." - paid: the
rows (critiqued, each by class) and R13's before/after pair (then fixed), with U04's shown pairs. No ledger row is owned by U06.
C9-11 paid at this anchor change (the seven and the old surface on `before` and `after/`, equal to U05's) · C9-10a NOT moved
(re-asserted on `after/`) · C9-2 named -> *Versioning Strategies* · C9-4 / C9-8 named -> *ETags and Conditional GET* · C9-5 named ->
*Pagination, Filtering and Sorting as an API Concern* · C9-18 named -> *Documenting Errors, Examples and Security* · C9-13: the seven
write routes listed above as data for unit 26 · C9-3: Section 1's share - six units' evidence landed (`c9-unit01` to `c9-unit06`).

## The values the video may say

The block below is `chk06.py`'s VALUES lines of a run of record; `receipts.sh` asserts it equal to the run's at its end.

<!-- values: begin -->
```
tests: tests=44 tests_u05=40 tests_k=4 its=14 it_entries=5 lib=146/146
mappings: handlers=17 handlers_setup=12 handlers_u04=2 handlers_u05=2 handlers_u06=1 handlers_all=24 others=7 dev=9/5 writes=7 public=5
rowspg: database=PostgreSQL_18.6 typed_bodies=1/4 list_rows=4 listeners=0->1->1->0 keyrows=1->1->2 codes=200,201,400,404,405,406,409,422 authors=Boots_/error:1,Boots_problem-details_handler:14,Spring_MVCs_OPTIONS_handler:2,TiffinBoxs_advice:2,the_key_filter_(IdempotencyKeyFilter):2,the_route:19,the_static_handler:1 rows=13 fixed=3 handed=4 named=7 requests=42
fixespg: public=405->200 allow=GET+HEAD+OPTIONS+PATCH rename=200/404/200/404/200 noevict_old=200
exercise: exercise=broken-404-FAIL,solved-200-PASS,refused-5-FAIL,pg+h2
rows: database=H2_2.5 typed_bodies=1/4 list_rows=4 listeners=0->1->1->0 keyrows=1->1->2 codes=200,201,400,404,405,406,409,422 authors=Boots_/error:1,Boots_problem-details_handler:14,Spring_MVCs_OPTIONS_handler:2,TiffinBoxs_advice:2,the_key_filter_(IdempotencyKeyFilter):2,the_route:19,the_static_handler:1 rows=13 fixed=3 handed=4 named=7 requests=42 crossdb_moved=0
fixes: public=405->200 allow=GET+HEAD+OPTIONS+PATCH rename=200/404/200/404/200 noevict_old=200 crossdb_moved=0
moved: asked=50 moved=6 unmoved=44 patch_customers=405:GET+POST
inert: seven=466c20ed surface=316a9637
static: xfam_s9s1_md5=1f5217a0 files_new=2 files_changed=1
spoken: hook_words=27 exercise_words=24 gloss_words=17
build: seed_files=10068
```
<!-- values: end -->
