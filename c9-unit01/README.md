# Course 9 · Unit 01 · What REST Actually Says — evidence

No anchor change. Unit 01 measures the tree unit 04 froze, `c9-unit04/after`, through two links, `before` and `after`, on the
default run (H2) and on PostgreSQL 18.6 for the statement column. Every number below names that tree: Spring Boot 4.1.3, Framework
7.0.11, Tomcat 11.0.29, the key filter present and inert without its header.

The hook, the dated note's sentence byte for byte (S1B, BLUE C9-CONTRACT; its words counted on the `mappings` capture; every gate 0):

TiffinBox came into this course with twelve routes. Exactly one answer says how long it may be kept, and it's the stylesheet.

"Routes" here means the handler methods of TiffinBox's own classes that existed when the course began: the mappings of `after`
minus the two unit 04 added, read two ways, both twelve.

The two glosses this unit owns (SECTION SHAPE 01), each on a line of its own:

A constraint: a rule an architecture style puts on how parts may talk.

A representation: the bytes a resource is sent as.

The README is read by RED; the spoken lines are the script's. The first spoken use of "a constraint" and "a representation" is the
script's, where the glosses above are said; in this README each word may appear before its gloss line.

## Runs of record

Three runs, each launched below load1 20 with the load printed on its first line, every build offline, `check_unit9.py 01 --runlog`
PASS on each run's log (the unit gate exits 2: no `01-*.md` script exists yet, expected):

```
bash 3.2.57  ./receipts.sh            see "c9-unit01 receipts ·" first line of the log: load at launch; last line "every capture = published (9)"
bash 5.3.9   bash receipts.sh         the same
sealed clone (git clone of the pushed tree into a path with a space; the seed copied in; bash 3.2.57)
```

The loads and end lines of the three runs are in the report-back of this evidence (the commit message carries them too).

## RE-MEASURE (settled first)

1. **The hook's count on `after`.** The flag run's handler-method table (`mappings`, H2, never shipped) gives TiffinBox's own
   methods, the set-up filter's twelve, and U04's two. Both derivations agree; "thirteen" is refused by `chk01.py` and `s901.py`.
2. **The LIVE line of *Static Resources and Cache Headers*, on Framework 7.0.11.** That lesson says "And the ETag Spring MVC sends here
   matches nothing." (its script, line 194). Measured here: `If-None-Match` with the stylesheet's own weak ETag answers `200` with
   the whole stylesheet, on both databases. **Still true on Framework 7.0.11.** `If-Modified-Since` with its own date answers `304`.
3. **The seven and the old surface on `after`.** Each equal to the value U04 holds for `after` (its `.r-inert.out`), and to the
   boundary's re-baseline for the surface, read by a count condition.

```
(a) TiffinBox's handler methods on after/: 14
(b) the set-up filter (the classes holding a handler method at the set-up commit: CustomerFeed, CustomerImport, DashboardPage, TiffinBoxServer): 12
(c) the mappings minus what U04 adds (CustomerPauses, 2): 14 - 2 = 12
(d) the set-up filter's split: GET 8 · POST 4
(e) the others (Actuator + BasicErrorController): 7
(f) the "dev" routes by the sources only (@Profile("dev") classes of after/, not started): 5
If-None-Match: W/"<the stylesheet's ETag>" -> 200 text/css (both databases)   ·   If-Modified-Since: <its Last-Modified> -> 304, body 0 B, 0 statements
the seven 466c20ed7e0d5439cb052f32ce09de1b = c7-unit31's S466 = U04's after/   ·   the old surface 316a96370fe5c34f58fc6ecca8e9557b (13 requests, 83 lines) = U04's after/
```

The split (d) agrees with *What's Next: The API Other People Will Use* (Course 8), which said twelve handler methods of TiffinBox's
own, eight for a GET and four for a POST: the same count, re-measured on 4.1.3.

## The change: none

```
git diff --stat HEAD -- c9-tiffinbox c9-unit04      (empty)
```

No anchor path changes, so no builder is grepped for changed paths (R.211 / R.331): there is no changed path to look for.
`c9-tiffinbox` equals `c9-unit04/after` (`diff -rq`, `.m2-demo` `target` `secrets` `.harness` left out) at the start and at the end
of every run.

## Which tree, which profile

`before` and `after` are both links whose text is exactly `../c9-unit04/after` (Course 8 U23's two-link form). `receipts.md5`'s
`before-tree` and `after-tree` lines equal `c9-unit04/receipts.md5`'s `after-tree` line; `receipts.sh` reads that line at run time
and `harness/tree01.py` (`tree04.py`'s code, its docstring changed) hashes through each link. The `anchor` form of Course 8's finale
and harness units is the alternative the contract does not use for units 01-03.

The measured tree is a copy of `after` under `.harness/`, built once per run offline (`mvn -o -B -DskipTests clean package -pl
tiffinbox-web -am`, `maven.repo.local` an absolute `cp -c` copy of `m2-seed-c9-u04`); no test is run. Unit 04's tests are cited by
name, not re-run: `18 + 10` at `package`, `28 + 14` at `verify` (its README). The version lines, printed from every JVM:

```
Starting Servlet engine: [Apache Tomcat/11.0.29] · HHH000001: Hibernate ORM core version 7.4.15.Final · Boot 4.1.3 · Framework 7.0.11
BOOT-INF/lib: 146 jars (tomcat-embed-core/el/websocket 11.0.29, netty-common 4.2.20.Final, jackson-databind 3.1.8, spring-core 7.0.11, postgresql 42.7.14)
Database: H2 2.5 (the default run)  ·  Database: PostgreSQL 18.6 (the census's first JVM, by digest)
```

Each equals U04's README. The census runs once per database, PostgreSQL's JVM first, then H2's: every HTTP column is asserted equal
across the two, the statement column is printed on both and was equal request by request. No statement count is voiced: the two
spoken lines say none; the column is evidence for RED and for unit 02.

## The captures — what each one shows

### mappings (the flag run, H2, LABELLED: never shipped)

The exposure flag is set for this one JVM. The default run answers `404` for the mappings endpoint (the census asks it). Rows, as
read by the boundary's rule (every `dispatcherServlets` entry with a handler method):

```
TiffinBoxServer 7 (customers, customer, add, revenue, dashboard, kitchen, shutdown) · DashboardPage 3 (page, form, add) · CustomerImport 1 · CustomerFeed 1
CustomerPauses 2 (U04's: POST /api/v1/customers/{name}/pauses, GET .../pauses/{id})
others 7: OperationHandler x4 (health, health/**, mappings, prometheus) · WebMvcLinksHandler · BasicErrorController x2
```

### censuspg, then census — every route once, one JVM per database

The order: the cache's keys once the `Started` line is printed, one health check, every route, the stylesheet's two conditional
requests, the JSON POST, the stateless pair, the import, the shutdown without its token, the actuator rows, then U04's routes,
labelled. Each request has two witnesses: curl's own headers and body files (both reset before the request), and the server's
`PROBE-REQ` line, plus Tomcat's access log at the end. The cache: `customers []` after `Started`, `customers [SimpleKey []]` after
the one health check (one statement), then the first list read sends none.

Who answered: the twelve handler methods, the static handler (the stylesheet; `/nowhere`; the default run's mappings path), Actuator,
and for the unkeyed pause POST, U04's key filter itself (its `400`, no handler). The coverage check: every TiffinBox row of the flag
run is asked, and every request other than the two not-found answers, the static handler's and Actuator's maps to a row.

The access log holds a `500` for `GET /customers/feed`: the census's own feed request, read to its first event and closed by the
reader. Tomcat logs it when the next add's event cannot reach the closed answer. It is named here; it is not a finding about TiffinBox.
`hashable` sorts the access lines before the md5 (their order is timing, their set is not).

The code panel — the stylesheet's three header lines and the problem body the links count reads:

```
Cache-Control: max-age=<the value: line "Cache-Control:" of the css request in .r-census.out>
Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT          (the build's project.build.outputTimestamp)
ETag: W/"<the file's own md5>"                          (weak; its value = the fingerprint in the file's name = md5 -q of the file)
{"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"}
```

### stateless — Fielding §5.1.3, `Set-Cookie` per route (THE FAILURE RECEIPT)

`Set-Cookie` appears on 1 route of the 14 the census asks, the form POST's `302` (`JSESSIONID=<masked>; Path=/; HttpOnly`), on
both databases; no JSON answer carries one. The failure: the same form POST with curl's cookie jar shows the note on the next
dashboard page; without the jar, the page shows no note; with a jar again, under a fresh name, the note is back. The notes counted:
1 / 0 / 1. Both POSTs answer `302`, both pages `200`, no exception: the server kept something for one client, and the request
without the cookie got nothing of it (*Sessions, Cookies and Flash Attributes*). curl writes the HttpOnly cookie as a
line starting `#HttpOnly_`; the reader strips that prefix before it reads the name (a naive reader sees no cookie: the brief's hazard).

Fielding's section 5.1.3 (`fielding-dissertation-ch5-rest_arch_style.htm`, anchor `sec_5_1_3`) says each request "cannot take
advantage of any stored context on the server". The page flow's session breaks that by design; the JSON routes keep none.

### cache — Fielding §5.1.4, lifetimes and validators per answer

An answer is counted per route (method + pattern). One route of the 14 carries a lifetime (`Cache-Control: max-age` or `Expires`):
the stylesheet's, its `200` and its `304` counted as one. The same route alone carries validators (`ETag`, `Last-Modified`). No API
answer carries `Cache-Control`, `ETag`, `Last-Modified`, `Expires` or `Pragma`; no answer says `no-store` or `no-cache`.

So an API answer here has no explicit lifetime or validator. That does not make it uncacheable: RFC 9110 labels some answers
heuristically cacheable when nothing explicit is sent, among them a `200` (its section 15.3.1, line 6953 of the filed
`rfc9110.txt`) and a `405` (section 15.5.6, line 7609). Unit 01 says "no explicit validator or lifetime", never "uncacheable".

The stylesheet's own validators and the names Course 7's *Optimistic Locking with @Version* pinned for Course 9 are handed to
*ETags and Conditional GET* by title: `@Version` and its column are never claimed here as an HTTP validator.

### links — Fielding §5.1.5, links and forms per representation

Counted with Python's `html.parser` (never a regex on the whole page) and, for JSON, by its keys (`_links`, `links`, `href`) and the
`Link` header: the dashboard page 3 links, the form page 3 links and 1 form, every JSON answer 0. The split, said honestly: each
page's 3 is 2 navigation links (`<a href>`) and 1 stylesheet link (`<link rel=stylesheet>`). "Links and a form drive the next request"
is made of the `<a>` and the `<form>` only. A JSON answer's one link is the `Location` of its `201`; a problem body's `instance` is an
identifier, not a control: printed as present, counted 0.

### Which constraints TiffinBox breaks, and when that is fine

| constraint (chapter 5) | on TiffinBox | measured here |
|---|---|---|
| client-server (§5.1.2) | cited from the chapter | no capture |
| stateless (§5.1.3) | the page flow's session, by design | `stateless` |
| cache (§5.1.4) | the stylesheet labelled; API answers carry no explicit label | `cache` |
| uniform interface (§5.1.5) | the pages carry links and a form; the JSON answers carry none | `links` |
| layered system (§5.1.6) | cited from the chapter | no capture |
| code on demand (§5.1.7, the optional one) | cited from the chapter | no capture |

Five constraints and one optional. No TiffinBox capture exists for client-server, layered system and code on demand: they are cited
by section, never measured. Links skipped in JSON are handed to *HATEOAS: The Argument* by title; when that is fine is that unit's
argument, not measured here.

### seven and surface (measured, not paid again)

The seven (`c5-unit11/curlset.sh`) and the old surface, each in its own JVM on H2 with no key sent: the same hashes U04 holds for
`after`, so the key filter stays inert on every old route of the tree this unit stands on. The self-test (S9.14, the harness's
plant, labelled): a `ShallowEtagHeaderFilter` on every path leaves the seven unchanged, moves the surface, and the feed answers
nothing by the count reader (its exit 3 at the alarm).

```
the seven 466c20ed7e0d5439cb052f32ce09de1b (7 lines) · the old surface 316a96370fe5c34f58fc6ecca8e9557b (13 requests, 83 lines)
planted: the seven unchanged · the old surface e6b8a52edf25a850d4ed8c18b38c3878 (moved) · the feed: 0 bytes, reader exit 3
```

### exercise

`exercise/README.md` carries the spoken line (its words counted by `receipts.sh`); `post.sh` as shipped keeps no cookie jar; `SOLUTION.md` sets `JAR=jar.txt` (one line).
Run from `after`'s jar alone on its own port, outside the harness, `env -i`, under bash and under `/bin/zsh -f`: the broken form
prints `FAIL`, the solution `PASS`; a jar written but not sent with the GET fails (cookie present, no note), and an empty jar sent
fails (no cookie, no note). `check.sh` reads the saved page and the jar, never re-asks the dashboard (the note is shown once), and
needs this try's fresh name in the note.

## Measured, not shipped

The flag run's exposure flag; the harness's classes, joined by `--spring.main.sources` and never in the jar: the statement witness
and the request witness (`Witness.java`, `Http.java`, U04's byte for byte, md5-asserted), the ShallowEtag plant (`Etag.java`,
U04's), and two read-only routes of this unit's own (`probe/u01/U01Probe.java`: the cache's keys, the key table's rows on H2).

## Refused, named

Every REST verdict word (`RESTful`, `truly REST`, `not REST at all`, `the right way`); `six constraints` without `one optional`;
`uncacheable` of an API answer; a route count of `thirteen`; `hypermedia` glossed here (that gloss is *HATEOAS: The Argument*'s);
`a validator` re-glossed (the gloss of *Static Resources and Cache Headers*); `an API` re-glossed (Course 8's); a `before` JVM of its own (one tree: none started); the feed's
listener note voiced (it belongs to unit 02); every duration word (dur9 over this README and the exercise: 0).

## The repository, and the network

```
D = _deliverables/tiffinbox-java · HEAD at the start a0a0151 (unit 04's commit; the set-up commit 80f7839 its ancestor) · origin/main...main 0 0
git log --oneline -3 at the start: a0a0151 Course 9 unit 04 … · 80f7839 Course 9 set-up … · 7698e93 Course 8 unit 28 …
one commit: c9-unit01/ alone, then git push (0 1 -> 0 0). No network otherwise: no pull, no fetch, every build offline (Downloading from: 0)
```

## The folders, the harness and the ports

```
c9-unit01/  README.md receipts.sh receipts.md5 harness/ exercise/ before -> ../c9-unit04/after  after -> ../c9-unit04/after
harness/    chk01.py s901.py tree01.py dur9.py src/probe/{Witness,Http,Etag}.java src/probe/u01/U01Probe.java
exercise/   README.md SOLUTION.md post.sh check.sh
ports 20900 census H2, seven, surface · 20901 PostgreSQL c9u01-pg · 20902 census PostgreSQL · 20903-20904 free · 20905 the flag run
      20906 never bound (no before/ JVM) · 20907 free (no browser) · 20908 the exercise · 20909 never bound · 20578 20615 21280-21284 never bound
```

`harness/` has no `logback.xml`: U04's harness has none either, and the access log needs none (Tomcat's valve, its pattern on the
command line).

## Masks, filters and hygiene

Masked: `Date`, `Expires`, the session cookie's value, any port, Boot's `/error` timestamp, the folders and the home; each mask
self-tested on a planted unmasked line before any capture. The stylesheet's `ETag` value and `max-age` value stay printed on the
capture blocks and are never spoken (dur9). Docker: the pinned socket on every call, `--pull never`, the image by digest present
at the start, the container removed with `rm -fv`; images and volumes equal at the start and the end of every run. Every JVM and
build runs under a `perl` alarm; every wait is a count condition under a bound.

## Interrupted

A `SIGINT` at each of: mid-build, mid-harness (a JVM live on the H2 census port), mid-container (PostgreSQL up), mid-TiffinBox on
PostgreSQL, mid-exercise — each run ended with exit 130 and left nothing: no JVM, no container of this unit, images and volumes at
the start's counts, the unit's ports free, the captures unchanged, `c9-tiffinbox` = `c9-unit04/after`. All five were done, on the
scratch mirror (this folder beside a copy of `c9-unit04`), the run started under `perl -e '$SIG{INT}="DEFAULT"; exec ...'` (a
background job of a script starts with SIGINT ignored, and bash cannot trap a signal ignored at entry: the first try, without the
reset, ran to its end and was discarded). Each left `.r-lock` gone and no `.r-*.new`.

```
build      exit 130 · java 0 · c9u01 containers 0 · volumes 315 · images 9 · listeners 20900-20909 0 · captures unchanged · anchor = c9-unit04/after
container  exit 130 · the same
pg         exit 130 · the same
harness    exit 130 · the same
exercise   exit 130 · the same
```

`DOCKER_HOST=tcp://127.0.0.1:1` in the environment: the receipt unsets it and reaches its port check on the pinned socket (images
and volumes read through `-H`).

## Planted faults — each caught

Each made to fail first on a scratch mirror (this folder beside a COPY of `c9-unit04`, never the repository's), then removed; each
ended with its FAIL line, exit 1, no traceback (every one; the count is the list below). The plant, its gate, and the gate's own line:

```
1. hook says thirteen (README) -> receipts' byte-equal hook gate -> *** a refused word or reading in this unit's prose:   README.md line 9: XU01: U01: a route count other than the derived twelve;  REA
2. a scratch hook says thirteen -> s901 XU01 route count -> p-hook.md line 1: XU01: U01: a route count other
3. chk01 spoken: the hook with thirteen -> FAIL the hook is the dated note's (S1B), byte for byte
4. mappings capture with the number word thirteen -> FAIL the hook says "twelve" and (b) spelled out is "twelve"
5. Cache-Control max-age on GET /customers (scratch census) -> exactly one lifetime route -> FAIL a lifetime (Cache-Control max-age / s-maxage or Expires) on exactly one route, the stylesheet's: ['Tif
6. Set-Cookie on GET /revenue (scratch census) -> stateless check -> FAIL no JSON answer carries Set-Cookie: ['revenue']
7. _links/href in a JSON body (scratch census, the counter's 2) -> links check -> FAIL every JSON answer: 0 link keys (['ravi'])
8. Link header on GET /kitchen (scratch census) -> links check -> FAIL no answer carries a Link header: ['kitchen']
9. the stylesheet's md5 one character off (values block) -> FAIL values: build.css_md5 = 10ba2401fd96e2e382866a731d207fc5 (this run: 10ba2401fd96e2e382866a731d207fc4)
10. the old surface's md5 one character off (values block) -> FAIL values: surface.surface = 316a96370fe5c34f58fc6ecca8e9557c (this run: 316a96370fe5c34f58fc6ecca8e9557b)
11. the seven's md5 one character off (values block) -> FAIL values: seven.seven = 466c20ed7e0d5439cb052f32ce09de1c (this run: 466c20ed7e0d5439cb052f32ce09de1b)
12. the seven's capture moved one character -> FAIL = U04's after/ capture
13. after-tree typed wrong in receipts.md5 -> anchortree -> *** receipts.md5's after-tree line (92 8761a535e4940fe7d5b0d9d0c7dea712) is not ../c9-unit04/receipts.md5's after-tree line (92 8761a535e494
14. before/ a copy, not a link -> the link gate -> *** before is not a link - unit 01 measures ../c9-unit04/after through a link, never a copy ***
15. after's link text ../c9-unit04/after/ (a slash) -> the link gate -> *** after's link text is "../c9-unit04/after/", not ../c9-unit04/after ***
16. after -> ../c9-unit03/after -> the link gate -> *** after's link text is "../c9-unit03/after", not ../c9-unit04/after ***
17. one byte added to the scratch copy of c9-unit04/after -> the pin -> *** R.211: before/'s tree is 92 ebd64899a4490f1c8e0075ba37a52882, the pin in receipts.md5 is 92 8761a535e4940fe7d5b0d9d0c7dea711
18. README: the stylesheet is kept for a year -> s901 (dur9 + XU01) -> README.md line 339: XU01: U01: a configured lifetime with a duration unit outside its code span
19. exercise/README.md: a duration word -> s901 (dur9) -> exercise/README.md line 28: XFAM_S4B: S4B: singular time words (RED S4B #4)
20. a spoken line with four hundred and five -> chk01 spoken -> FAIL the exercise: the status gate 0
21. a sentence with 405 -> s901's status gate -> p-st.md line 1: XU01: U01: a status said as digi
22. the hook one byte changed -> byte-equal hook -> *** README.md: the hook (S1B's dated note), byte for byte ***
23. a gloss one word changed -> byte-equal gloss -> *** the gloss (SECTION SHAPE 01) must stand in README.md once, as a line of its own, byte for byte: A representation: the bytes a resource is sent a
24. s901: "REST is six constraints." -> p-ph.md line 1: XU01: U01: six constraints witho
25. s901: "TiffinBox is RESTful." -> p-ph.md line 1: XU01: U01: a REST verdict
26. s901: "Fielding says you must send links." -> p-ph.md line 1: XU01: U01: Fielding obeyed, not 
27. s901: "The JSON answers lack HATEOAS." -> p-ph.md line 1: XU01: U01: hypermedia or HATEOAS
28. s901: "An API answer is uncacheable." -> p-ph.md line 1: XU01: U01: uncacheable, without 
29. s901: "The cached list is faster." -> p-ph.md line 1: XFAM_S9S1: S9S1: faster / cheape
30. s901: "That is the right way." -> p-ph.md line 1: XU01: U01: a REST verdict
31. s901: "Most APIs do this." -> p-ph.md line 1: XFAM_S9S1: S9S1: every API, most
32. s901: "Spring caches the stylesheet." -> p-ph.md line 1: XU01: U01: Spring caches / handl
33. receipts.sh: a stray key on GET /kitchen -> the key-header gate -> *** S9.21: the key header is written by keyh() alone (1) and sent once, by the labelled extra (2) ***
34. the key table holds 2 rows after the census (a stray key) -> inertness count -> FAIL the key table's rows after the census: [2] = the requests that carried a key (1) - every other route left it as
35. GET /kitchen removed from the census -> coverage (a row nobody asked) -> FAIL coverage: every TiffinBox mapping row of the flag run is asked at least once (14 rows; missed ['TiffinBoxServer#kitche
36. a request answered by Mystery#revenue -> coverage (no mapping explains it) -> FAIL coverage: every other request maps to a mapping row (['revenue'])
37. mapread on the default run's 404 (the flag missing) -> FAIL the mappings answer is not Actuator's mappings document (KeyError) - is the endpoint exposed? (the flag run's flag)
38. the PostgreSQL census read as H2's (a label swap) -> which database answered -> FAIL which database answered: ['PostgreSQL'] (Flyway's own line; the capture's label says h2)
39. chk01 mappings on an empty capture -> FAIL no GET/POST split line
40. chk01 censuspg on an empty capture -> FAIL the key table's rows after the census: [] = the requests that carried a key (0) - every other route left it as it was
41. chk01 census on an empty capture -> FAIL the key table's rows after the census: [] = the requests that carried a key (0) - every other route left it as it was
42. chk01 stateless on an empty capture -> FAIL Set-Cookie on 1 route of None: the form POST, on both databases
43. chk01 cache on an empty capture -> FAIL If-Modified-Since -> 304, 0 statements
44. chk01 links on an empty capture -> FAIL the pages: navigation 2 + stylesheet 1; the form page + 1 form
45. chk01 seven on an empty capture -> FAIL no 'the seven:' line
46. chk01 surface on an empty capture -> FAIL no 'the old surface:' line
47. chk01 exercise on an empty capture -> FAIL four tries x two shells: 0
48. chk01 stateless on the cache capture -> FAIL Set-Cookie on 1 route of 14: the form POST, on both databases
49. chk01 exercise on the surface capture -> FAIL four tries x two shells: 0
50. census: a request line it cannot parse -> FAIL an indented line outside a request block: '     body: [{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mea'
51. mappings: a row line it cannot parse -> FAIL a row line the reader cannot parse: '  row | broken'
52. values: a line it cannot parse -> FAIL a values line the reader cannot parse: '- links.nav 2 .r-links.out RESULT dashboard_nav'
53. a placeholder word (the three capital letters) appended to README.md -> *** a placeholder in this unit's prose or exercise: README.md:339 ***
54. exercise: a changed What it prints line -> FAIL README.md's What it prints = the broken run's output
55. R.196: SOLUTION.md's block = the broken one -> *** R.196: SOLUTION.md's block must be the README's with one line changed ***
56. R.344: a bare docker call in receipts.sh -> *** R.344: receipts.sh calls docker without the pinned socket: 353:docker ps > /dev/null ***
57. R.387: dk rm -f without -v -> *** R.387: receipts.sh removes a container without its volumes (found: dk rm -f|dk rm -fv) ***
58. a Downloading from line in a build log -> offl -> *** p-build.log: Maven's log says it downloaded 
59. 20578 bound before the run -> dies before any container (0 container lines) -> *** something already listens on 20578 - this unit's ports must be free ***
60. another receipts.sh live -> the guard (S9.17), the other left running: yes -> *** S9.17: another receipt runs (95761 /bin/sh ./receipts.sh) before the build of after/ - this run stops; wait for it
```

The S9.14 plant (a `ShallowEtagHeaderFilter` on every path) runs inside every run's `surface` capture; the refused "solutions" of the
exercise (a jar written and not sent, an empty jar) inside every run's `exercise` capture.

## What differed from the brief

- The link form: Course 8 U23's two links (`before` = `after` = `../c9-unit04/after`), not the finales' `anchor` form.
- 20906 dropped: the brief's ports line gives a `before` JVM; `before` and `after` are one tree, so none is started.
- The exercise's spoken line counts `21` words (RED-C9-S1 #37), not the brief's `(20 words)`.
- The hook is the dated note's ("came into this course with twelve routes"), not the body's first wording.
- "Five constraints and one optional", not "six constraints".
- Both databases for the census (BLUE C9-S1 #24), not "no database-bound claim"; PostgreSQL first.
- Capture names follow the brief; the orchestrator's `uniform` is `links`, its `inert` is `surface`'s self-test plus the key table's
  row count after the census (one row: the labelled extra's key, the only request that sent one).
- dur9's pin is the registry's live value, read at run time; the older value typed in `ev04-prompt.md` is stale.
- U04's `receipts.md5` has no harness lines: the copied classes are asserted byte-equal to U04's files themselves.
- The PostgreSQL driver is the jar's own (U04 found the dev profile's driver in `BOOT-INF/lib`), and PostgreSQL trusts the loopback
  (U04's form): no password file exists to write.
- RFC 9110's heuristic label is cited for a `200` (section 15.3.1) beside the brief's `405` (section 15.5.6): the API answers here are `200` but for the errors.
- The S9.14 plant runs in every run (two more JVMs) and is labelled; it is not hashed apart from the `surface` capture it closes.
- Every number moved from 4.1.2: none moved. The census, the cookies, the validators, the links, the statements and the seven equal
  the boundary's on 4.1.2 and U04's on 4.1.3.

## For RED

- The hook and the exercise (above), and their captures: `mappings` (the count), `cache` (the one lifetime), `stateless` (the note).
- What a script must not say: the refused list above; a statement count (none is voiced); the `max-age` value or any duration.
- The glosses: "a constraint", "a representation" (unit 01's first spoken use). Not glossed here: a resource and `safe` / `idempotent`
  (unit 02), "a validator" (Course 6), "an API" (Course 8), "hypermedia" (*HATEOAS: The Argument*), "a status code" (Course 6).
- The call-backs, by title: *What Happens Between curl and Your Method*, *Static Resources and Cache Headers*, *Sessions, Cookies and
  Flash Attributes*, *Optimistic Locking with @Version*, *What's Next: The API Other People Will Use*; handed on: *HATEOAS: The
  Argument*, *ETags and Conditional GET*.
- The warm-cache attribution, decided: the `findAll()` in the kitchen's health is the indicator's own read, older than Course 8; the
  CACHE that answers it from memory is the one *@Cacheable, @CacheEvict, @CachePut* put on `findAll` (`@Cacheable("customers")`);
  the NOTE that the health stays up while the list is cached is the one *Redis Data Structures From Java* measured under "dev". So the
  cause every receipt names is that cache plus the health route, and *Redis Data Structures From Java* is the right call-back only for
  that note.
- The stylesheet-link split (2 navigation + 1 stylesheet per page) and the problem body's `instance`, counted 0: RED's question.
- The lifetime rule for "exactly one answer": per route, the stylesheet's `200` and `304` one route.
- The census's `500` in the access log: its own abandoned feed request, named.
- RED-C9-SETUP #10 (links: the pages are the hypermedia, the stylesheet link split out), #23 (when that is fine: handed to
  *HATEOAS: The Argument*); RED-C9-S1 #1 (the count derived, not typed), #24 (both databases, PostgreSQL first), #32 ("five
  constraints and one optional"; the implicit label named), #37 (`21` words).

## The ledger rows this unit pays

- `C9-3` (Section 1's share): roadmap line `369` of `_briefs/TRACK-ROADMAP.md`, "Fielding's constraints plainly; which ones your API
  breaks and when that is fine" — the table above.
- `C9-4` and `C9-8`: NAMED, handed to *ETags and Conditional GET* by title (the LIVE line is still true on 7.0.11: the hand-off stands).
- `C9-10d`: it agrees (the twelve, eight and four re-measured).
- `C9-11`: not re-paid (the seven and the surface shown equal, not paid again). `C9-16`: untouched.

## The values the video may say

The twelve (routes); `Set-Cookie` on one route (the form POST); a lifetime on one route (the stylesheet), with its three headers
present; links 3 / 3 and a form / 0; the note with the cookie and none without it. Each line below is asserted equal to the run's
own value at the end of every run.

<!-- values: begin -->
- mappings.setup_filter = 12 · .r-mappings.out "(b) the set-up filter" line, H2 flag run
- mappings.minus_u04 = 12 · .r-mappings.out "(c)" line
- mappings.tb_methods = 14 · .r-mappings.out "(a)" line
- mappings.u04_added = 2 · (a) - (c)
- mappings.get = 8 · .r-mappings.out "(d)" line
- mappings.post = 4 · .r-mappings.out "(d)" line
- mappings.others = 7 · .r-mappings.out "(e)" line
- mappings.dev = 5 · .r-mappings.out "(f)" line, the sources of after/
- mappings.hook_word = twelve · .r-mappings.out "(g)" line
- stateless.setcookie_routes = 1 · .r-stateless.out RESULT line, both databases
- stateless.routes = 14 · .r-stateless.out RESULT line
- cache.lifetime_routes = 1 · .r-cache.out RESULT line, both databases
- cache.cssinm = 200 · .r-cache.out RESULT css304 line (If-None-Match with its own ETag)
- cache.css_etag_eq_name = yes · .r-cache.out RESULT css_name_md5 line
- cache.max_age = 31536000 · .r-cache.out RESULT css_cc (on the panel only, never spoken)
- links.nav = 2 · .r-links.out RESULT dashboard_nav
- links.stylesheet_links = 1 · .r-links.out RESULT dashboard_stylesheet
- links.form_forms = 1 · .r-links.out RESULT form_forms
- links.json_answers = 18 · .r-links.out RESULT json_answers (each with 0 links)
- census.dash_links = 3 · .r-census.out dashhtml links line, H2
- census.form_links = 3 · .r-census.out form links line, H2
- census.notes = 1/0/1 · .r-census.out "the note" lines, H2
- censuspg.notes = 1/0/1 · .r-censuspg.out "the note" lines, PostgreSQL
- census.keyrows = 1 · .r-census.out "key table rows after the census", H2 (the harness's JdbcTemplate)
- censuspg.keyrows = 1 · .r-censuspg.out the same line, PostgreSQL (psql)
- census.st_dashboard = 3 · .r-census.out dashjson server line (not voiced)
- seven.seven = 466c20ed7e0d5439cb052f32ce09de1b · .r-seven.out
- surface.surface = 316a96370fe5c34f58fc6ecca8e9557b · .r-surface.out
- surface.surface_plant = e6b8a52edf25a850d4ed8c18b38c3878 · .r-surface.out planted line
- build.libs = 146 · BOOT-INF/lib of the built copy
- build.css_md5 = 10ba2401fd96e2e382866a731d207fc4 · md5 -q of the built stylesheet
<!-- values: end -->
