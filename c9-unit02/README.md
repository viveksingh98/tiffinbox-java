# Course 9 · Unit 02 · Resources, URIs and the Method Table — evidence

No anchor change. Unit 02 measures the tree unit 04 froze, `c9-unit04/after`, through two links, `before` and `after`, on
PostgreSQL 18.6 (named first) and on the default run (H2). Every number below names that tree: Spring Boot 4.1.3, Framework
7.0.11, Tomcat 11.0.29, the key filter present and inert without its header, the pause route and its GET, the cache proxy.

The hook, RED-C9-S1 #4's sentence byte for byte (S1B :574; its words counted by `chk02.py spoken`; every gate 0):

Send TRACE to TiffinBox and no TiffinBox route runs: Tomcat refuses it four oh five, and Spring Boot's error page writes the answer. Send it through MockMvc, and it comes back two hundred.

The pinned sentence, Course 8's *What's Next: The API Other People Will Use* (C9-10a, R.478), byte for byte, true on this tree:

A PATCH to slash customers answers four-oh-five, and its Allow header names POST and GET.

The gloss this unit owns (SECTION SHAPE 02), on a line of its own, byte-equal to the brief inside its quotes:

A resource: anything with an address a client can ask for.

The two glosses below are **proposed by the evidence agent — not the brief's text; RED reads them** (flag 15). Each is built from a
measured line of the `safe` capture; the word itself stands in a code span because the carried base refuses it bare (see "What
differed"):

`Safe`, as this unit measures it: a request after which TiffinBox writes no row, so its second answer comes back byte-identical.

Idempotent, as this unit measures it: a request whose repeat writes nothing new and gets the second answer byte-identical to the first.

The README is read by RED; the spoken lines are the script's. The first spoken use of "a resource" is the script's, where the gloss
above is said; in this README the word may appear before its gloss line.

## Runs of record

Three runs, each launched below load1 20 with the load printed on its first line, every build offline, `check_unit9.py 02 --runlog`
PASS on each run's log (the unit gate exits 2: no `02-*.md` script exists yet, expected):

```
bash 3.2.57  ./receipts.sh            the first line of the log: "c9-unit02 receipts · … · load …"; the last: "every capture = published (12)"
bash 5.3.9   bash receipts.sh         the same
sealed clone (git clone of the pushed tree into a path with a space; the seed copied in; bash 3.2.57)
```

The loads and end lines of the three runs are in the report-back of this evidence.

## RE-MEASURE (settled first)

1. **The method table on `after`.** Thirty-six requests, the four addresses by the nine methods, over a real socket, one JVM per
   database (PostgreSQL first). Tomcat refuses eight of them before any TiffinBox route: the four `TRACE` requests (Tomcat, then
   Boot's `/error` on an ERROR dispatch) and the four `CONNECT` requests (Tomcat alone, no witness line at all). The other
   twenty-eight carry a request-dispatch witness line. `inert`: every row equals the boundary's table on 4.1.3 + Tomcat 11.0.29
   before the key (`B8/census-mid/census.txt`), status, content type, bytes, `Allow` as a set and `Content-Length`; nothing moved.
   The key table holds no row after the table and at the end, on both databases, read by another client (the second witness).
2. **The pinned sentence on this tree.** `PATCH /customers` answers `405`, `Allow` the set {GET, POST}, `application/problem+json`,
   its body key for key the one Course 8's unit 28 printed. Both md5 values hold by their definitions (flag 9).
3. **The seven and the old surface on `after`.** Each equal to the value U04's values block holds for `after` (`inert:` line), the
   surface read by a count condition.
4. **MockMvc's table against the socket's.** The same thirty-six requests through MockMvc (the harness's test copy, no socket):
   four kinds of difference, by the grouping rule in `chk02.py`; status and `Allow` equal for GET, POST, PUT, DELETE, PATCH and
   OPTIONS on all four addresses.

```
the table (H2; PostgreSQL equal in every HTTP column): 36 requests · 200 x10 · 400 x1 · 403 x1 · 405 x20 · 501 x4 · distinct Allow sets 7
who answered: Spring MVC 28 (a REQUEST line each) · Tomcat, then Spring's /error 4 (TRACE: an ERROR line only) · Tomcat alone 4 (CONNECT: no line)
inert: 36 rows = B8/census-mid's 36 (4.1.3 + Tomcat 11.0.29, before the key): 0 moved · key table rows: 0 after the table, 0 at the end (both databases)
pinned: PATCH /customers -> 405 · Allow (as a set) GET,POST · application/problem+json · body = c8-unit28/README.md's line, key for key
pinned.txt md5 2a866987eea96a5cb42553f5dfb319b3 (90 B, the file, with its newline) · the sentence md5 726bd7288807908e67237ce33149f606 (89 B) = the ledger's C9-10a
the seven 466c20ed7e0d5439cb052f32ce09de1b = c7-unit31's S466 = U04's inert: seven=  ·  the old surface 316a96370fe5c34f58fc6ecca8e9557b (13 requests, 83 lines) = U04's SURF=
MockMvc: 36 MOCKMVC lines · 4 kinds (TRACE's status · CONNECT's status · HEAD's body bytes · Content-Length absent) · 38 raw difference lines · Tests run: 1, Failures: 0
```

## The change: none

```
git diff --stat HEAD -- c9-tiffinbox c9-unit04 c9-unit01      (empty)
```

No anchor path changes, so no builder is grepped for changed paths (R.211 / R.331): there is no changed path to look for.
`c9-tiffinbox` equals `c9-unit04/after` today (`diff -rq`, `.m2-demo` `target` `secrets` `.harness` left out), printed as a note
at the start and at the end of every run (an anchor change of another unit makes it differ; the tree pins are the gate).

## Which tree, which profile

`before` and `after` are both links whose text is exactly `../c9-unit04/after` (Course 8 U23's two-link form, as unit one did).
`receipts.md5`'s `before-tree` and `after-tree` lines equal `c9-unit04/receipts.md5`'s `after-tree` line; `receipts.sh` reads that
line at run time and `harness/tree02.py` (`tree04.py`'s code, its docstring changed) hashes through each link.

The measured tree is a copy of `after` under `.harness/`, built once per run offline (`mvn -o -B -DskipTests clean package -pl
tiffinbox-web -am`, `maven.repo.local` an absolute `cp -c` copy of `m2-seed-c9-u04`, its file count printed); no suite is re-run.
Unit 04's counts are cited by name from its values block, read at run time: `tests_after=28 tests_k=10 its=14` (the `18 + 10` at
`package` and the fourteen ITs at `verify`). The ONE other build is the harness's test copy, `mockmvc` below, whose `Tests run: 1`
is the harness's own line, never the anchor's count. The version lines, printed from every JVM:

```
Starting Servlet engine: [Apache Tomcat/11.0.29] · HHH000001: Hibernate ORM core version 7.4.15.Final · Boot 4.1.3 · Framework 7.0.11
BOOT-INF/lib: 146 jars (tomcat-embed-core/el/websocket 11.0.29, netty-common 4.2.20.Final, jackson-databind 3.1.8, spring-core 7.0.11, postgresql 42.7.14)
Database: PostgreSQL 18.6 (the first JVM, by digest, trust on 127.0.0.1:20911)  ·  Database: H2 2.5 (the default run)
the harness's test copy's class path: spring-test 7.0.11 · spring-boot-webmvc-test 4.1.3 · spring-boot-test 4.1.3 · mockito-core 5.23.0 · assertj-core 3.27.7
```

Each equals U04's README. The table, `head`, `who`, `trace` and `safe` run once per database, PostgreSQL's JVM first, then H2's:
every HTTP column is asserted equal across the two (`cross`), the statement column is printed on both and was equal request by
request. `xhead`, `seven`, `surface` and `exercise` are H2's; `mockmvc` has no socket and no database.

Viewing order (S9.3): unit 02 is seen before unit 04. U04's pause route is not one of the four addresses and is not asked here.

## The captures — what each one shows

### tablepg, then table — the method table, one JVM per database

Four addresses (`/customers`, `/customers/Ravi`, `/revenue`, `/shutdown`) by nine methods: RFC 9110's eight (section 9.1 onward,
read off `rfc9110.txt`, md5 `MD5SUMS.txt`'s line) and RFC 5789's PATCH (its section 2). HEAD is asked by `curl -I` (S9.26), the
other eight by `-X`, the boundary's two forms; no body, no `Content-Type`, no key header, no token. Each row prints curl's status,
content type and `size_download`, curl's exit, `Allow` as sent and as a set, `Content-Length`, the access log's line (the valve,
unbuffered, no time field) and the request witness's lines. Before the table: the cache's keys after the `Started` line,
before any request (empty), one `GET /actuator/health` (one statement, the indicator's read), the keys again (`[SimpleKey []]`, warm). The access
log's window around the table holds exactly the thirty-six lines; the over-long request line is unit three's and is not sent.

The code panel (H2's rows; PostgreSQL's equal):

```
-- PUT /customers -> 405 application/problem+json 109 (curl exit 0)        allow: GET, POST · set {GET,POST}
-- OPTIONS /customers -> 200  0 (curl exit 0)                              allow: GET,HEAD,POST,OPTIONS · set {GET,HEAD,OPTIONS,POST}
   served but absent from the 405's Allow: HEAD, OPTIONS
-- PATCH /customers -> 405 application/problem+json 111 (curl exit 0)      allow: GET, POST · set {GET,POST}
     body: {"detail":"Method 'PATCH' is not supported.","instance":"/customers","status":405,"title":"Method Not Allowed"}
-- TRACE /customers -> 405 application/json 102 (curl exit 0)
     access: TRACE /customers- 405 113
     server: GET /error [dispatch ERROR, for /customers] -> 405 | handler BasicErrorController#error | post-handle yes (count 1) | statements 0 (writes 0, prepares 0)
     body: {"timestamp":"<time>","status":405,"error":"Method Not Allowed","path":"/customers"}
-- CONNECT /customers -> 501 text/html;charset=utf-8 443 (curl exit 0)
     access: CONNECT /customers- 501 443                                    (no witness line)
```

The two `Allow` lines side by side (RED-C9-S1 #21): the `405` lists fewer methods than the route serves. RFC 9110 section 15.5.6
(`rfc9110.txt` line 7601 onward) asks a `405` for an `Allow` field `containing a list of the target resource's currently supported
methods`; TiffinBox's `405` lists POST and GET and leaves HEAD and OPTIONS out, which the same route answers. The pinned sentence
therefore says "POST and GET", and leaves HEAD and OPTIONS out with it.

`Allow` as sent is a hash-order list: its order moved between JVM starts in this unit's own runs (the exercise's two JVMs printed
`POST,GET,HEAD,OPTIONS` and `GET,HEAD,POST,OPTIONS` for the same request; the boundary printed `POST, GET` where this run printed
`GET, POST`). The set is the fact; the capture keeps the order as sent and `receipts.md5` hashes the set.

### head — HEAD runs the GET handler (H1.3; RFC 9110 section 9.3.2)

Read off the two table captures: on each GET address the request witness's post-handle count for the GET's handler rises by one on
HEAD (`TiffinBoxServer#customers` count `1` then `2`); HEAD's `Content-Length` equals the GET's (`282` / `67` / `22`) and
`size_download` is `0`. `HEAD /revenue` runs its one statement, as its GET does (uncached); `HEAD /customers` runs none (the list is
warm: R.312's negation, a HEAD whose GET reads nothing). `HEAD /shutdown` is a `405` with `Allow: POST`, no handler selected.
RFC 9110 section 9.3.2 (`rfc9110.txt` line 3985): HEAD `is identical to GET except that the server MUST NOT send content`.

### who — who answered (S9.25 amended; flags 3 and 14)

Per row, three classes by the dispatch type of the witness lines: a REQUEST line is "Spring MVC answered" (twenty-eight rows, the
handler or `none` for a `405`), no line and an access-log line is "Tomcat alone" (the four `CONNECT` rows, Tomcat's own HTML page,
`443` bytes), an ERROR line only is "Tomcat, then Spring's `/error`" (the four `TRACE` rows, `BasicErrorController#error`). The two
witnesses agree line for line: an access-log line without a witness line is exactly a `CONNECT` row; no witness line lacks an
access-log line. Who wrote each body (S9.31), as the run printed it: `BasicErrorController#error` for `TRACE`'s JSON (the witness's
handler field); Tomcat for `CONNECT`'s page (no Spring line at all); for the `405` bodies of PUT, DELETE, PATCH and the POSTs the
witness prints `handler none` and the body's `detail` is the text `Method 'PUT' is not supported.` — the exception class behind it
is not printed by this run, so it is not named here.

### trace — the hook's first half

`TRACE` to each address: `405`, `Allow` the set {DELETE, GET, HEAD, OPTIONS, POST, PUT}, the body Boot's `/error` JSON with exactly
four keys (`timestamp` masked), and a single witness line, the ERROR dispatch, `statements 0`; no request-dispatch line and no TiffinBox
handler. Each claim of the hook maps to a line: "no TiffinBox route runs" (no REQUEST line, no TiffinBox handler), "Tomcat refuses
it four oh five" (the access log's `405` with no REQUEST line), "Spring Boot's error page writes the answer" (the ERROR dispatch's
handler, `BasicErrorController#error`), "through MockMvc … two hundred" (`mockmvc`'s TRACE rows). The ERROR dispatch's witness line
names the method `GET`, not `TRACE`: Tomcat forwards the error page as a GET (a finding, flag 14). Whether Tomcat answers `TRACE`
at all is the connector's `allowTrace` setting, left at its default; no advisory was filed for it (S9.36): not filed, not cited.

### `safe` — writes, as measured (RFC 9110 section 9.2.1; RED-C9-S1 #20)

Two witnesses. (i) Statements: every request of the table writes no row (every witness line `writes 0`), and eight GETs asked
twice each outside the table (`/customers`, `/customers/Ravi`, `/revenue`, `/customers?mealType=VEG`, `/dashboard` as JSON and as
HTML, `/customers/new`, `/kitchen`) write no row and give the second answer byte-identical to the first (`cmp`). The statement column
per row, on both databases, equal: the list `0` (warm), Ravi `1` on the table's first read then `0`, `/revenue` `1` each time
(uncached), `/dashboard` `3`. (ii) The feed: `GET /customers/feed` read to its first event by a count condition and closed by the
reader; the harness's `/probe/u02/feed` reads `CustomerFeed`'s listeners `0` before, `1` after the client has gone, `1` again — a
GET that keeps state for a client that has gone (U06's row; never voiced here). (iii) C9-13's data, for unit twenty-six: the write
routes the table touched answered `400` (`POST /customers`, no body, `TiffinBoxServer#add`), `403` (`POST /shutdown`, no token,
`TiffinBoxServer#shutdown`) and `405` (POST on Ravi and on `/revenue`); unit one's `mappings` capture lists the write handlers
(`TiffinBoxServer` add and shutdown, `DashboardPage` add, `CustomerImport`); `/customers/import` and U04's pause route are not asked
here. No anonymous write is shown. POST's repeat is unit four's (*Idempotency, Safety and Retries*): no POST is repeated here.

### cross — PostgreSQL against H2

Every HTTP column of the thirty-six rows (status, content type, bytes, `Allow` as a set, `Content-Length`, the access-log line, who
answered, the body) equal across the two JVMs; the statement column printed on both, equal on every row.

### xhead — THE FAILURE RECEIPT (S9.26, H1.2; H2's JVM, once)

```
GET /customers -> 200 282 (curl exit 0)
curl -I /customers -> 200 0 (curl exit 0) · Content-Length: 282
curl -X HEAD /customers -> 200 0 (curl exit 28) · headers received: HTTP/1.1 200 · Content-Length: 282
curl: (28) Operation timed out after <masked> with 0 out of 282 bytes received
```

The server answered: the status line and `Content-Length` arrived. curl, told only to send the word HEAD, waited for the bytes the
`Content-Length` announced, which HEAD never sends, until the harness's cap ended it (its value is printed on the capture as the
harness's alarm, never a result). `curl -I` asks HEAD as HEAD: exit `0`, the headers, no wait. The `282` is read off the same JVM's
GET, never typed.

### mockmvc — the same table through MockMvc (C9-9's share; S9.19)

The harness's test copy: a second copy of `after` under `.harness/mockmvc/` with one test class added,
`harness/test/ProbeMethodTableTest.java` (the boundary's filed copy, md5 `eb4a78c1…`, plus eight added lines: the `Pauses`
stand-in `TiffinBoxWebTest` declares on U04's `after`, and assertions of the four kinds, so the test can fail). One test class run
offline, `Tests run: 1, Failures: 0`, no listener on the unit's ports during the build. `@WebMvcTest` on `slice/WebSlice` with
`MockMvcTester`: a slice holds no DataSource, so the key filter (which needs it, U04's `IdempotencyKeyTest` says) is not in this
chain; on these rows that absence is invisible (no request carries the key header). Compared line by line with H2's socket table:

```
status and Allow equal: GET, POST, PUT, DELETE, PATCH, OPTIONS on all four addresses
TRACE      MockMvc 200 message/http (the servlet's echo, Content-Length set) · socket 405 (Tomcat, then /error)        4 rows
CONNECT    MockMvc 405 with Allow · socket 501, Tomcat's page                                                        4 rows
HEAD       MockMvc body bytes present (69 / 67 / 21 / 109) · socket 0                                                 4 rows
Content-Length  absent on every MockMvc answer but TRACE's · the socket sends one on GET, HEAD, OPTIONS and CONNECT
```

Four kinds by the grouping rule (a TRACE row's differences are one kind, a CONNECT row's one, a HEAD row's body bytes one, any
other missing `Content-Length` one); the raw difference lines (38) are printed beside, so "four" and the boundary's "seven" (B8's
own grouping) are not confused. A GET's body size is the stand-ins' data, not compared (a named rule). The script voices one kind,
TRACE's (the hook's second half); the other three are handed to *Testing Spring Apps* by title. *Testing the Web Layer* is called
back for its LIVE words: MockMvc runs the DispatcherServlet with no socket. The flip plant (the test asserting `TRACE` `405`) fails
with Surefire's own FAIL line (Planted faults).

### seven and surface (measured, not paid again)

The seven (`c5-unit11/curlset.sh`) on `after` in its own JVM, H2, no key header, equal to `c7-unit31`'s `S466=` and to U04's
`inert: seven=`; the old surface (thirteen requests, the feed read by a count condition) in its own JVM, equal to U04's `SURF=`
and `inert: surface=`. The S9.14 self-test, in every run, labelled the harness's plant, on its own port: a `ShallowEtagHeaderFilter`
on every path (U04's `probe.Etag`) leaves the seven unchanged, moves the surface, and the feed answers nothing (the reader's alarm,
no bytes).

### exercise

Broken as shipped (`exercise/ask.sh`, `curl -X HEAD` with its own cap, exit `28`, no `Allow` line), solved by one line
(`SOLUTION.md`: `curl -I` for the list, then `OPTIONS` for `/shutdown`: exit `0`, `Allow: POST,OPTIONS`), and three refused
"solutions", each SOLUTION.md's block with its fixed line changed: `-I` without the `OPTIONS` ask (exit `0`, no `Allow`), the
`OPTIONS` of `/customers` instead (its `Allow` is the list's), and `-X HEAD` kept before the `OPTIONS` ask (exit `28`). `check.sh`
reads curl's exit AND the `Allow` line as a set, never an exit code alone. TiffinBox's jar alone on its exercise port (no harness),
`env -i`, from the exercise's folder, under bash then `zsh -f`; broken and solved print different blocks, each asserted against the
capture.

## Measured, not shipped

The harness's test copy (`.harness/mockmvc/`, one test class added, never in the anchor); the harness's classes, joined by
`--spring.main.sources` and never in the jar: the statement witness and the request witness (`Witness.java`, `Http.java`, U04's
byte for byte, md5-asserted), the ShallowEtag plant (`Etag.java`, U04's), and three read-only routes of this unit's own
(`probe/u02/U02Probe.java`: the cache's keys and the key table's rows, U01's two routes copied; the feed's listener count, the S1
probe's reader rewritten to find the bean by its class); the plant slot.

## Refused, named

Every verdict word (`safe` bare, `secure`, `RESTful`); `Spring never sees it` (the ERROR dispatch runs Boot's error page);
MockMvc as the socket (`MockMvc proves`, `the same as a real request`); `HEAD skips the handler`; `Allow` or `OPTIONS` said to list
every method without the gap; `HTTP has nine methods`; nouns obeyed (`URIs must be nouns`); a count of nine Tomcat answers, or the
census's 76 / 85; the over-long request line (unit three's); the `-X HEAD` wait voiced as the server's (`curl hangs`, `the server
hangs`); the key header sent or U04's pause route measured; the feed's listener note voiced; a status said in digits or in the
hundred form in a spoken line; every duration word (dur9 over this README and the exercise: 0).

## The repository, and the network

```
D = _deliverables/tiffinbox-java · HEAD at the start f688858 (unit 01's commit; a0a0151, unit 04's, its parent) · origin/main...main 0 0
git log --oneline -4 at the start: f688858 Course 9 unit 01 … · a0a0151 Course 9 unit 04 … · 80f7839 Course 9 set-up … · 7698e93 Course 8 unit 28 …
one commit: c9-unit02/ alone, then git push (0 1 -> 0 0). No network otherwise: no pull, no fetch, every build offline (Downloading from: 0)
```

## The folders, the harness and the ports

```
c9-unit02/  README.md receipts.sh receipts.md5 harness/ exercise/ before -> ../c9-unit04/after  after -> ../c9-unit04/after
harness/    chk02.py s902.py tree02.py dur9.py src/probe/{Witness,Http,Etag}.java src/probe/u02/U02Probe.java test/ProbeMethodTableTest.java
exercise/   README.md SOLUTION.md ask.sh check.sh
ports 20910 table H2, xhead, seven, surface · 20911 PostgreSQL c9u02-pg · 20912 table PostgreSQL · 20913 the S9.14 plant · 20914 free
      20915 never bound (no flag run) · 20916 never bound (no before/ JVM) · 20917 free (no browser) · 20918 the exercise · 20919 never bound
      18881-18884 20578 20615 21280-21289 never bound · mockmvc binds none (sampled during its build)
```

`harness/` has no `logback.xml`: U04's and U01's harnesses have none either, and the access log needs none (Tomcat's valve, its
pattern on the command line).

## Masks, filters and hygiene

Masked: `Date`, `Expires`, the session cookie's value, any port, Boot's `/error` timestamp, curl's timed-out elapsed time, Surefire's
elapsed time, the folders and the home; each mask self-tested on a planted unmasked line before any capture. `Allow` lists are
hashed as sets (the order as sent stays on the capture). Docker: the pinned socket on every call, `--pull never`, the image by
digest present at the start, the container removed with `rm -fv`; images and volumes equal at the start and the end of every run.
Every JVM and build runs under a `perl` alarm; every wait is a count condition under a bound (the request's own access-log line,
then its witness lines).

## Interrupted

A `SIGINT` at each of the six points below, on the scratch mirror (this folder beside clones of what it reads), each run started with INT reset to its default (U01's finding: a background job starts with
SIGINT ignored). Each run ended with exit 130 and left nothing: no JVM, no container of this unit, images and volumes at the start's
counts, the unit's ports free, the captures unchanged, `c9-tiffinbox` = `c9-unit04/after`, `.r-lock` gone and no `.r-*.new`.

```
build      exit 130 · java 0 · c9u02 containers 0 · volumes 315 · images 9 · listeners 20910-20919 0 · .r-lock gone · .r-*.new 0 · captures unchanged · anchor diff lines 0
container  exit 130 · java 0 · c9u02 containers 0 · volumes 315 · images 9 · listeners 20910-20919 0 · .r-lock gone · .r-*.new 0 · captures unchanged · anchor diff lines 0
pg         exit 130 · java 0 · c9u02 containers 0 · volumes 315 · images 9 · listeners 20910-20919 0 · .r-lock gone · .r-*.new 0 · captures unchanged · anchor diff lines 0
harness    exit 130 · java 0 · c9u02 containers 0 · volumes 315 · images 9 · listeners 20910-20919 0 · .r-lock gone · .r-*.new 0 · captures unchanged · anchor diff lines 0
mockmvc    exit 130 · java 0 · c9u02 containers 0 · volumes 315 · images 9 · listeners 20910-20919 0 · .r-lock gone · .r-*.new 0 · captures unchanged · anchor diff lines 0
exercise   exit 130 · java 0 · c9u02 containers 0 · volumes 315 · images 9 · listeners 20910-20919 0 · .r-lock gone · .r-*.new 0 · captures unchanged · anchor diff lines 0
the signal points: build (alarm line + 4 s), container (PostgreSQL up), pg (TiffinBox on 20912 up), harness (TiffinBox on 20910 up),
mockmvc (the test copy's mvn live, its log 39 lines, no BUILD line yet), exercise (the exercise's JVM on 20918)
```

The first mid-`mockmvc` try signalled too late (the test copy's build had ended) and its run then stopped at the S9.17 guard, which
had seen a plant gate's receipt live: exit 1, nothing left of it; it is plant (67) below, and the point was redone, signalled while
the build was live.

## Planted faults — each caught

Each made to FAIL first on a scratch mirror (never on `c9-unit04/` or the anchor), shown with its gate, removed after; each ended
with its FAIL line, exit 1, no traceback (or the receipt's own die line).

```
== the spoken lines and the pinned sentence
(01) the hook one byte changed exit 1 · FAIL the hook is RED-C9-S1 #4's (S1B :574), byte for byte · traceback: none
(02) the hook's old wording: Spring never sees it exit 1 · p.md line 1: XU02: U0 · traceback: none
(03) the pinned sentence one byte changed exit 1 · FAIL the pinned sentence = pinned.txt with ONE trailing newline stripped · traceback: none
(04) the pinned sentence written 405 exit 1 · FAIL the pinned sentence = pinned.txt with ONE trailing newline stripped · traceback: none
(05) the ledger's md5 one character off exit 1 · FAIL the SENTENCE's md5 726bd7288807908e67237ce33149f606 (89 B) = the ledger's C9-10a md5 (726bd7288807908e67237ce33149f607) - the one s902-era builde 
(06) the pinned sentence as four hundred and five exit 1 · p.md line 1: XU02: U0 · traceback: none
(07) the exercise one word changed exit 1 · FAIL the exercise's line is S1B :258-260's, byte for byte · traceback: none
== the table
(08) PATCH /customers planted with Allow: GET only exit 1 · FAIL (a) the pinned sentence's facts on this tree: PATCH /customers -> 405 · Allow as a set {GET} · application/problem+json · traceback: no
(09) HEAD's size_download planted non-zero exit 1 · FAIL (c) inert: the 36 rows (status, content type, size_download, Allow as a set, Content-Length) = the boundary's B8 census-mid table (4.1.3 + Tomc
(10) a GET row with one write statement exit 1 · FAIL GET /customers: a witness line with writes 1 · traceback: none
(11) the emitter typed 0 after the client left exit 1 · FAIL the feed's listeners: 0 before -> 0 after the client left -> 1 again (a GET that keeps state for a client that has gone; never voiced here)
(12) a 500 planted in the access log exit 1 · FAIL (d) a 500 in this JVM's access log: 1 (GET /customers/feed) · traceback: none
(13) the key table's rows not 0 (a key sent) exit 1 · FAIL S9.21: the key table's rows, read by a second client: 0 after the table, 0 at the end · traceback: none
(14) one row removed from the table exit 1 · FAIL the window holds the 36 requests, 4 addresses x 9 methods, in order (35 rows) · traceback: none
(15) the over-long request line added to the window exit 1 · FAIL the access log's window: 37 lines = the requests sent (36); the over-long request line is not sent (U03's) · traceback: none
(16) an unparseable listing line (the tracebacking checker) exit 1 · FAIL a request line the table reader cannot parse: '-- PATCH /customers => four-oh-five application/problem+json 111 (curl exit 0)'
(17) the PostgreSQL capture checked as H2 (a label swap) exit 1 · FAIL which database answered: the capture's head says h2 and Flyway's line says H2 2.5 · traceback: none
(18) the cross-database equality broken by one byte exit 1 · FAIL (f) PostgreSQL and H2: every HTTP column equal (status, content type, size_download, Allow as a set, Content-Length, access line, who 
(19) inert's cannot-fail detector: one boundary row moved exit 1 · FAIL (c) inert: the 36 rows (status, content type, size_download, Allow as a set, Content-Length) = the boundary's B8 census-mid tabl
== the views
(20) HEAD's post-handle equal to GET's (did not run) exit 1 · FAIL H2 HEAD /customers runs the GET handler TiffinBoxServer#customers: post-handle count 1 -> 1 · traceback: none
(21) TRACE's ERROR-dispatch line removed (who) exit 1 · FAIL H2: Tomcat alone (no witness line, an access-log line): CONNECT x5 · traceback: none
(22) TRACE's ERROR-dispatch line removed (trace) exit 1 · FAIL H2 TRACE /customers: ONE witness line, the ERROR dispatch, BasicErrorController#error, statements 0 - no request-dispatch line, no Tiffin
(23) a CONNECT row typed Spring MVC answered exit 1 · FAIL H2: Tomcat alone (no witness line, an access-log line): CONNECT x3 · traceback: none
== xhead, mockmvc, seven, surface, exercise
(24) -X HEAD typed exit 0 exit 1 · FAIL curl -X HEAD: the server answered 200 with Content-Length 282; curl exit 0 · traceback: none
(25) the 282 typed instead of derived (GET says 283) exit 1 · FAIL the control: curl -I -> 200, exit 0, Content-Length 282, 0 bytes · traceback: none
(28) the seven's md5 one character off exit 1 · FAIL the seven on after/ = the expected 466c20ed7e0d5439cb052f32ce09de1c (= U04's inert: seven=) · traceback: none
(29) the surface's md5 one character off exit 1 · FAIL the old surface on after/ = the expected 316a96370fe5c34f58fc6ecca8e9557c (13 requests, 83 lines; = U04's inert: surface=) · traceback: none
(30) a changed What it prints line exit 1 · FAIL README.md's What it prints = the broken run's output (Allow read as a set) · traceback: none
(31) the solution printed as the broken (solution = broken) exit 1 · FAIL solved under bash: curl exit 0 · Allow OPTIONS,POST · PASS · traceback: none
== the values block and the prose
(32) the Tomcat count typed 9 in the values block exit 1 · FAIL values: table.tomcat_refused = 9 (this run: 8) · traceback: none
(33) the request count typed 85 exit 1 · FAIL values: table.requests = 85 (this run: 36) · traceback: none
(34) a duration word in the README exit 1 · p.md line 1: dur8: a · traceback: none
(35) a duration word in the exercise exit 1 · p.md line 1: dur8: gi · traceback: none
(36) a status in digits in a spoken sentence exit 1 · p.md line 1: XU02: U0 · traceback: none
(37) U02 / XFAM_S9S1 / base: Spring never sees TRACE. exit 1 · p.md line 1: XU02: U0 · traceback: none
(38) U02 / XFAM_S9S1 / base: MockMvc is the same as a real request. exit 1 · p.md line 1: XU02: U0 · traceback: none
(39) U02 / XFAM_S9S1 / base: HEAD skips the handler. exit 1 · p.md line 1: XU02: U0 · traceback: none
(40) U02 / XFAM_S9S1 / base: OPTIONS lists every method. exit 1 · p.md line 1: XU02: U0 · traceback: none
(41) U02 / XFAM_S9S1 / base: HTTP has nine methods. exit 1 · p.md line 1: XU02: U0 · traceback: none
(42) U02 / XFAM_S9S1 / base: URIs must be nouns. exit 1 · p.md line 1: XU02: U0 · traceback: none
(43) U02 / XFAM_S9S1 / base: TRACE is disabled. exit 1 · p.md line 1: XU02: U0 · traceback: none
(44) U02 / XFAM_S9S1 / base: PATCH is not supported. exit 1 · p.md line 1: XU02: U0 · traceback: none
(45) U02 / XFAM_S9S1 / base: With curl -X HEAD, curl hangs. exit 1 · p.md line 1: XU02: U0 · traceback: none
(46) U02 / XFAM_S9S1 / base: The cache catches up. exit 1 · p.md line 1: XFAM_S9S · traceback: none
(47) U02 / XFAM_S9S1 / base: A 304 is faster. exit 1 · p.md line 1: dur8: fa · traceback: none
(48) U02 / XFAM_S9S1 / base: Most APIs do this. exit 1 · p.md line 1: XFAM_S9S · traceback: none
(49) U02 / XFAM_S9S1 / base: REST requires a key. exit 1 · p.md line 1: XFAM_S9S · traceback: none
(50) U02 / XFAM_S9S1 / base: A PUT is idempotent. exit 1 · p.md line 1: XFAM_S9S · traceback: none
(51) U02 / XFAM_S9S1 / base: The answer comes back at once. exit 1 · p.md line 1: R.388's · traceback: none
(52) U02 / XFAM_S9S1 / base: Bas yaar. exit 1 · p.md line 1: HINGLISH · traceback: none
(53) U02 / XFAM_S9S1 / base: An API: a set of routes. exit 1 · p.md line 1: XU02: U0 · traceback: none
== the receipt's own gates (receipts.sh on the plants mirror: each dies at its gate before any JVM)
(54) the gloss one word changed exit 1 · *** the gloss (SECTION SHAPE 02) must stand in README.md once, as a line of its own, byte for byte: A resource: anything with an address a client can · traceba
(55) a placeholder line in the README (a planted to-do word) exit 1 · *** a placeholder in this unit's prose or exercise: README.md:<line> *** · traceback: none
(56) the solution's block = the broken one (R.196) exit 1 · *** R.196: SOLUTION.md's block must be the README's with one line changed *** · traceback: none
(57) a key header on a request (S9.21) exit 1 · *** S9.21: a line of receipts.sh or the exercise names the key header (1) - unit 02 sends no key on any request *** · traceback: none
(58) a container removed without -v (R.387) exit 1 · *** R.387: receipts.sh removes a container without its volumes (found: dk rm -f|dk rm -fv) *** · traceback: none
(59) tree02's hash typed wrong in receipts.md5 exit 1 · *** receipts.md5's after-tree line (92 8761a535e4940fe7d5b0d9d0c7dea712) is not ../c9-unit04/receipts.md5's after-tree line (92 8761a535e4940fe7
(60) after's link text with a trailing slash exit 1 · *** after's link text is "../c9-unit04/after/", not ../c9-unit04/after *** · traceback: none
(61) before's link to ../c9-unit03/after exit 1 · *** before's link text is "../c9-unit03/after", not ../c9-unit04/after *** · traceback: none
(62) before changed to a copy exit 1 · *** before is not a link - unit 02 measures ../c9-unit04/after through a link, never a copy *** · traceback: none
(63) one byte changed in the scratch copy of c9-unit04/after exit 1 · *** R.211: before/'s tree is 92 5ec6fa0b5d02b7ebd81f14af5ea94851, the pin in receipts.md5 is 92 8761a535e4940fe7d5b0d9d0c7dea711 -
(64) a harness file not the published one exit 1 · *** harness/chk02.py is not the published file (md5 f99b8310ec6580a6cbd50530dca06733, receipts.md5 1db282b61bd9b3d20356dbb7e663c5f5) *** · traceback:
(26) MockMvc's TRACE row typed 405 (on the run's own capture) exit 1 · FAIL the voiced difference: TRACE through MockMvc -> 405 · traceback: none
(27) a listener on 20910-20919 during mockmvc exit 1 · FAIL socketless: no listener on 20910-20919 during the build (sampled) · traceback: none
(65) the harness test's TRACE assertion flipped (-Dprobe.flip=true, a real offline build, 0 downloads) mvn exit 1 · Surefire: Tests run: 1, Failures: 1 -- ProbeMethodTableTest.theMethodTableThroughMockMvc:61 [TRACE /customers] expected: 405 but was: 200
(66) a Course 8 port (20578) bound before the run, under DOCKER_HOST=tcp://127.0.0.1:1 exit 1 · *** something already listens on 20578 *** (docker info passed on the pinned socket first)
(67) a second receipt live (seen for real: a plant gate's receipts.sh ran beside the mid-mockmvc SIGINT run) exit 1 · *** S9.17: another receipt runs (… ./receipts.sh) before TiffinBox seven - this run stops; wait for it, never kill it ***
(68) the S9.14 self-test: in every run (surface's planted line: the seven unchanged, the surface moved, the feed 0 bytes, reader exit 3)
(69) the refused exercise "solutions" (ionly, custopts, headkept): in every run, each FAIL under bash and zsh
```

Not planted, named: a `Downloading from` line in a build log (`offl()` refuses one; every build log of every run has none) and the
container removed by a receipt run without `-v` at run time (plant (58) refuses the line statically, before any container exists).

## What differed from the brief

- (#1) Link form (flag 1): Course 8 U23's two links, as unit one did; read in SC :207-212 and U01's README.
- (#2) The hook (flag 2): RED-C9-S1 #4's `33` words (S1B :574), not the body's `Spring never sees it` (a plant here).
- (#3) The counts (flag 3): 36 requests and 8 refused by Tomcat, derived from this JVM's window; the 9th Tomcat answer and the over-long
   line are unit three's; never 76 / 85.
- (#4) The exercise (flag 4): S1B :258-260's sentence byte for byte, `wc -w` 24; no gate fired on it.
- (#5) Databases (flag 5): both, PostgreSQL first (#24), not "the default run (H2), no database-bound claim".
- (#6) Captures (flag 6): no `mappings` capture and no flag run (20915 never bound); `trace` added; the orchestrator's `inert` is the
   table's comparison with the boundary's plus the seven, the surface and the key table's rows; `cross` added for the column check.
- (#7) Ports (flag 7): 20916 asserted free and never bound.
- (#8) C9-9 (flag 8): unit 02's share paid (the MockMvc table, one difference voiced, three named); the ledger's owner column reads U21 —
   RED confirms. The ledger is not edited.
- (#9) The pinned sentence's md5 (flag 9): "its md5 = `pinned.txt`'s" read literally is the FILE's (`2a866987…`, with its newline); the
   ledger's (`726bd728…`) is the SENTENCE's. Both asserted by their definitions; RED or the contract picks one wording; the builder
   (`s902`) asserts the sentence's.
- (#10) PostgreSQL's start (flag 10): U04's landed shape (by digest, trust on the loopback, the jar's own driver); no password file.
- (#11) Test counts (flag 11): U04's `28` / `10` / `14` cited from its values block; only the harness's one test class runs.
- (#12) The warm cache (flag 12): U04's resolution copied — the kitchen's health reads the list, the cache that answers it from memory is
  the one *@Cacheable, @CacheEvict, @CachePut* put on it; measured here: empty after `Started`, one statement at the first health
  check, warm after.
- (#13) MockMvc's kinds (flag 13): four by the named rule; the raw lines (38 here, by this unit's per-column reading) printed beside.
- (#14) Who answered (flag 14): three classes by dispatch type. Finding: the ERROR dispatch's witness line names `GET /error`, not
  `TRACE`, and it carries `post-handle yes` (BasicErrorController's), not `no`: the hook's "no TiffinBox route runs" holds, the
  brief's expected "post-handle no" does not.
- (#15) The glosses (flag 15): the resource gloss byte-equal; the two others written here and labelled. Finding: the carried family base
  (Course 8's `XFAM_S5` "safety verdicts") refuses the word `safe` bare in any sentence, so the gloss line writes it in a code span;
  the script's spoken `safe` needs the contract's call (RED).
- (#16) The title (flag 16): the heading follows the registry ("URIs"); the spoken "U-R-Is" is the script's; the spelling gate ran over
  the three spoken lines, none holds a bare "URI".
- (#17) `Allow`'s order (not in the brief): a hash order that moved between JVM starts in these runs; captures hash the set.
- (#18) MockMvc's TRACE carries a `Content-Length` (the servlet's echo): the boundary's "no Content-Length on any MockMvc answer" holds
  for every row but TRACE's. The harness test's four assertions say so.
- (#19) The `405` bodies' author (S9.31): the run prints `handler none` and the body's text, not the exception class; the class is not named.
- (#20) `dur9`'s pin: `java9_series.DUR9_MD5` read at run time (`77d6fcf8…`, = `C9/_builders/dur9.py`'s and U04's copy); `ev04-prompt.md`'s
  typed value is stale.
- (#22) The anchor-today diff is a NOTE, not a gate (the orchestrator's correction, 10:58 CET): once unit 05 moves `c9-tiffinbox`,
  a fatal diff would stop this receipt at its start on every run after it. The form is Course 8's (`c8-unit04/receipts.sh:149-150`); U01's was
  fatal (the orchestrator fixes U01 and U04 apart). The fatal R.211 pins stay: `before-tree` / `after-tree` against
  `receipts.md5` and against `c9-unit04/receipts.md5`'s `after-tree` line.
- (#21) The MockMvc probe test's source: the copy filed by the orchestrator (`instruments/test-src/`, md5 asserted), not a scratch copy.

## For RED

- The hook, the pinned sentence and the exercise (above), and their captures: `trace` + `who` + `mockmvc` (the hook), `tablepg` /
  `table` row `PATCH /customers` (the pinned sentence), `xhead` + `exercise` (the exercise).
- What a script must not say: the refused list above; a statement count; the cap's value or any duration; the feed's listener note.
- The glosses: "a resource" (the brief's), and `safe` / `idempotent` (proposed here, labelled). Not glossed here: a constraint and a
  representation (unit one's), an idempotency key (unit four's), a status code, a validator, "an API" (Course 8's), "hypermedia".
- The call-backs, by title: *What Happens Between curl and Your Method*, *Actuator Mappings: Every Route Listed* (the route list
  lives in unit one's `mappings` capture — not measured here), *Testing the Web Layer* (its LIVE "no socket"), *What's Next: The API
  Other People Will Use* (the pinned sentence); handed on: *Testing Spring Apps* (MockMvc's other three kinds), *Idempotency, Safety
  and Retries* (POST's repeat, `idempotent` deepened), *Status Codes That Mean Something* (every other status; the over-long line).
- The warm-cache attribution (flag 12) and the pinned sentence's two md5 values (flag 9).
- The title's spoken form "Resources, U-R-Is and the Method Table" (#34).
- RED-C9-S1 #2 (the pinned line: true on this tree), #3 (36 / 8, derived), #4 (the hook), #20 (two witnesses: statements and the
  feed's listeners), #21 (the two `Allow` lines), #24 (both databases, PostgreSQL first), #34 (the title), #35 / #36 (`mappings` out,
  `trace` in), #37 (`ask.sh` ships its cap; the README names it only as "line 6").

## The ledger rows this unit pays

- Roadmap line `370` of `_briefs/TRACK-ROADMAP.md`: `the nine methods and what each one guarantees` — the table, `head`, `safe`.
- `C9-10a`: PAID (R.478) — the pinned sentence repeated byte for byte, true on this tree (`PATCH /customers` row).
- `C9-9`: unit 02's share paid (flag 8). `C9-13`: data on the routes that write, named for unit twenty-six (`safe` (iii)). `C9-3`:
  Section 1's share (the method table). `C9-11`: not re-paid (the seven and the surface shown equal). `C9-16`: untouched.

## The values the video may say

Thirty-six requests; eight refused by Tomcat before any TiffinBox route (four TRACE through Boot's error page, four CONNECT by
Tomcat alone); the hook's three claims; the pinned sentence; HEAD's `Content-Length` equal to the GET's and no body; `curl -X
HEAD` exit `28` beside `curl -I` exit `0`; MockMvc's TRACE `200`. Each line below is asserted equal to the run's own value at the
end of every run.

<!-- values: begin -->
- table.requests = 36 · .r-table.out the window (36 rows, the access log's window 36 lines), H2
- table.tomcat_refused = 8 · .r-table.out rows with no REQUEST witness line, H2
- table.spring = 28 · .r-table.out rows with a REQUEST witness line, H2
- table.s200 = 10 · .r-table.out (e) status distribution, H2
- table.s400 = 1 · the same
- table.s403 = 1 · the same
- table.s405 = 20 · the same
- table.s501 = 4 · the same
- table.allow_sets = 7 · .r-table.out (e) distinct Allow sets
- table.cl = 282/67/22 · .r-table.out GET rows' Content-Length (= HEAD's), H2
- table.pin = 405:GET,POST:application/problem+json · .r-table.out PATCH /customers row (the pinned sentence's facts), H2
- table.inert_moved = 0 · .r-table.out against B8/census-mid/census.txt's table, H2
- table.listeners = 0->1->1 · .r-table.out the feed's listeners (not voiced), H2
- table.st_revenue = 1 · .r-table.out GET /revenue witness line, H2 (not voiced)
- table.st_dashboard = 3 · .r-table.out dashjson-1 witness line, H2 (not voiced)
- tablepg.requests = 36 · .r-tablepg.out the window, PostgreSQL
- tablepg.tomcat_refused = 8 · .r-tablepg.out, PostgreSQL
- tablepg.pin = 405:GET,POST:application/problem+json · .r-tablepg.out PATCH /customers row, PostgreSQL
- tablepg.inert_moved = 0 · .r-tablepg.out against B8's table, PostgreSQL
- tablepg.listeners = 0->1->1 · .r-tablepg.out, PostgreSQL (not voiced)
- xhead.xhead_exit = 28 · .r-xhead.out curl -X HEAD line, H2
- xhead.xhead_wanted = 282 · .r-xhead.out curl's own line ("0 out of 282 bytes"), = the same JVM's GET
- xhead.i_exit = 0 · .r-xhead.out curl -I line
- head.head_ph = +1 · .r-head.out post-handle count GET -> HEAD, both databases
- head.revenue_head_pg = 1 · .r-head.out HEAD /revenue statements, PostgreSQL (not voiced)
- head.revenue_head_h2 = 1 · .r-head.out HEAD /revenue statements, H2 (not voiced)
- who.tomcat_alone = 4 · .r-who.out CONNECT rows, no witness line
- who.tomcat_error = 4 · .r-who.out TRACE rows, an ERROR-dispatch line only
- who.spring = 28 · .r-who.out REQUEST-dispatch rows
- trace.trace_bytes = 102 · .r-trace.out TRACE /customers, H2 (panel only)
- trace.error_dispatch_method = GET · .r-trace.out the ERROR dispatch's witness line
- cross.cross_http_diff = 0 · .r-cross.out PostgreSQL vs H2, every HTTP column
- cross.cross_stmt_diff = 0 · .r-cross.out the statement column
- mockmvc.mockmvc_lines = 36 · .r-mockmvc.out MOCKMVC lines
- mockmvc.mockmvc_kinds = 4 · .r-mockmvc.out the grouping rule
- mockmvc.mockmvc_raw = 38 · .r-mockmvc.out raw difference lines (beside the kinds)
- mockmvc.mockmvc_trace = 200 · .r-mockmvc.out MOCKMVC TRACE /customers
- mockmvc.tests_run = 1 · .r-mockmvc.out Surefire's line (the harness's test, never the anchor's count)
- seven.seven = 466c20ed7e0d5439cb052f32ce09de1b · .r-seven.out
- surface.surface = 316a96370fe5c34f58fc6ecca8e9557b · .r-surface.out
- surface.surface_plant = e6b8a52edf25a850d4ed8c18b38c3878 · .r-surface.out planted line
- exercise.exercise = broken-FAIL,solved-PASS,ionly-FAIL,custopts-FAIL,headkept-FAIL · .r-exercise.out, bash + zsh
- build.libs = 146 · BOOT-INF/lib of the built copy
- build.seed_files = 10068 · .m2-demo's file count (the seed copy)
<!-- values: end -->
