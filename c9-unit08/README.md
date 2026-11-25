# Course 9 · Unit 08 — springdoc-openapi and Swagger UI

**Course 9's fifth change to the anchor, and Section 2's second unit.** One `OpenAPI` bean (`TiffinBoxOpenApi`) gives the document
TiffinBox serves its own `info` - the title `TiffinBox` and the version `1.0`, where springdoc-openapi wrote `OpenAPI definition` and `v0` -
and the committed copy of the document (`tiffinbox-web/src/test/resources/openapi/tiffinbox.json`) is written again from the running
application in the same commit. `before` is a link to `../c9-unit07/after` (unit 07's tree); `after/` is a frozen copy of
`../c9-tiffinbox` after this unit's change. Every number below names its tree and is read by `harness/chk08.py` off a capture of
`receipts.sh`, never typed. The page itself (`/swagger-ui.html`) answered on unit 07's tree already; this unit measures it.

The hook, as the brief gives it (S2B :179), byte for byte:

Swagger UI loads in a browser that can reach nothing but TiffinBox, and the page asks for nothing else.

The unit's one gloss, typed once in `harness/chk08.py`:

Swagger UI: a page drawn from the document.

## Runs of record

Three runs, each launched below load1 `20` (R.480) with its load printed on its first line: bash `3.2.57` (`./receipts.sh`), bash
`5.3.9` (`bash receipts.sh`), and a sealed fresh clone of the repository in a folder whose name holds a space (R.129), run from that
clone. Every build says offline: yes (`Downloading from` `0` in every Maven log). Each run ends `every capture = published (18)`,
and `check_unit9.py 08 --runlog <log>` prints the run-log gate's PASS on each (the unit gate exits `2`, not judged, until unit 08's
script exists, as the prompt expects). The capture hashes are the `receipts.md5` lines; the loads are in the commit message. No
clock figure of a run is a measurement and none is said here.

## RE-MEASURE (settled first)

1. **The page and the addresses; the document's `info` before and after.** On `before` (unit 07's tree, H2, no harness) the five
   addresses answer as unit 07 left them: `GET /v3/api-docs`, `/v3/api-docs.yaml` and `/v3/api-docs/swagger-config` `200`,
   `GET /swagger-ui.html` `302` to `/swagger-ui/index.html`, which answers `200` `text/html` (`before`). The document's `info` there
   is `{"title": "OpenAPI definition", "version": "v0"}`; on `after/` it is `{"title": "TiffinBox", "version": "1.0"}`, on
   PostgreSQL `18.6` and on H2 alike (`after`). Course 8's line in What's Next: The API Other People Will Use - `The API docs route and the Swagger page answer four-oh-four: TiffinBox publishes no contract today.` - is read off the ledger (`C9-10d`); its
   four-oh-fours belong to unit 06's tree and unit 07 measured them (read, not run again here). Its second half is paid here:
   the page answers `200` and loads in the sealed browser (`redirect`, `sealed`).
2. **`info`, and nothing else.** The two documents (each from its own JVM without the harness, H2: `before` on `20976`, `after/`
   on `20970`), with `info` and `servers` removed and dumped again by the fixed rule, hash the same - ``eb08ed40`` on both,
   printed in the `info` capture and read back from it by `chk08.py`, which hashes the two saved documents again itself. The
   top-level member order is the same; one top-level member differs (`info`) and two of its members (`title`, `version`);
   `servers` is springdoc-openapi's own generated entry on both, equal once the port is masked; paths `11`, operations `13`, tags `6` on
   both. The YAML (`/v3/api-docs.yaml`) differs in exactly the `title:` and `version:` lines, two out and two in;
   `/v3/api-docs/swagger-config` is equal on both once the port is masked. The committed file's diff against unit 07's is the two
   `info` lines and no other hunk. With `info` removed, the two documents hash the same.
3. **The seal.** The page (`/swagger-ui/index.html` on `after/`, `20970`, no harness) in headless Chrome sealed with `c6-unit23`'s
   flags: BLUE's judge, `seal9.py cdp`, prints one host, `127.0.0.1:20970`, nine times, and its own line
   `CDP requests: 11 (9 to a socket, 2 data:/file: with no socket)` - nine requests, all to TiffinBox, and two inline images that
   are not requests; `0` `loadingFailed`; exit `0` (`sealed`). The planted page - the harness's route `/probe/u08/plant`, one
   stylesheet link to a font host - turns the same judge red: `CDP OUTBOUND: https://fonts.googleapis.com/css`, exit `1`, in every
   run of record; the probe's filed font run (`rdchrome/index-events.json`, md5 = the probe's `MD5SUMS` line) is red too, read and
   not produced here. The NetLog is a witness and is printed as found: every TCP connect went to this computer, the dead proxy
   included (`127.0.0.1:9` and TiffinBox's port); the UDP lines (to a public IPv6 address on port `443`, each with `net_error`
   `-109` and no bytes sent) and the addresses Chrome's own background asked for are printed as the run found them, and their
   counts are neither asserted nor said (yours will differ). The served `swagger-config` says `"validatorUrl":""`; the page shows
   no validator badge and CDP holds no event to the validator host. The bundle (`swagger-ui-bundle.js` in `swagger-ui-5.35.1.jar`)
   names ``20`` host names, the validator's three times - censused, not judged; in BLUE's form (the scheme kept) the list
   is BLUE's filed list line for line.
4. **What the page shows, and what the jar holds.** The page's title block reads `TiffinBox 1.0 OAS 3.1` on `after/` and
   `OpenAPI definition v0 OAS 3.1` on `before` - the change the page shows; `13` operations in `6` tags, the tags the document's,
   none of `DashboardPage`'s and none of the harness's (`ops`). The handler methods: `17` → `13` operations (`DashboardPage`'s three
   absent, the two PATCH handlers one operation), equal on both trees, springdoc-openapi's four rows equal, the bean adding none; the five
   dev mappings are not in the default run (their classes are the dev profile's), and each built jar holds `0` entries named
   `probe/` (`census`).
5. **Try it out.** The operation is `customer-reads-one` (read off the served document). Opened from a closed state, the first
   click - on `.opblock-summary-control` - opened it (`click 1 outcome: opened`, the state line after it filed), so the arrow was
   not clicked (`click 2 (.opblock-control-arrow): not clicked - click 1 opened the operation`): both outcomes are in `tryit`, in
   every run. Try it out, `Ravi`, Execute: exactly one request after the click, `GET /api/v1/customers/Ravi`, `accept: */*`, the
   page as its Referer, answered `200` `application/json`; the body CDP read is the body a `curl` of the same address gets (the same
   md5); the access log grew by one line, `GET /api/v1/customers/Ravi- 200 67`. The page shows `200` in the response row's cell.
   The failure receipt, three lines side by side: the document says `*/*` for that operation's `200`, the page asks for `*/*`, and
   TiffinBox answers `application/json` - the page asks for what the document says. On PostgreSQL the same click sends the same
   request and gets the same answer, md5 for md5, and `psql` reads Ravi's row (`tryitpg`).
6. **The committed file.** `9843` bytes by `wc -c` - unit 07's `9851`, the title nine characters fewer and the version one
   more, as the arithmetic predicts; no `servers`; written by the fixed rule; equal to the served document with `servers` removed
   on both databases. `OpenApiSpecTest` (not edited) passes on it in `package` and in the Docker-free twin. The stale file - the
   shipped bean with unit 07's file, nothing else - fails it (`expected … but was …`, the report naming the two titles); a copy with
   `required` widened to four fails it; the record's `@Size(max = 60)` made `61` fails it. In the same run in which the test
   passes, `diff` prints its rows: the test is code against the committed file, never the document against the wire (`committed`).
7. **`diff`.** `specwire9.py` on `after/` (H2, the harness joined, a fresh database): `7` kinds and `16` rows without the third
   argument, `8` and `17` with the probe's filed generated source - unit 07's values block, read at run time; the plant moves each
   by one, the empty wire folder is refused (exit `2`). The bean moved no row.
8. **`moved`.** Fourteen requests on each tree (unit 07's twelve, the YAML and `swagger-config`): every line equal but two - the
   document and its YAML, whose bodies (size and md5) moved and whose status and type did not: moved, compatible (the document's
   `info`), named in this unit. A PATCH to slash customers answers four-oh-five with `Allow` `GET`, `POST` on both trees.
9. **Tests per runner.** `mvn package`: ``45`` tests (unit 07's `45`, read off its values block, plus `0`: no new class), the
   Docker-free twin the same; `mvn verify`: the five ITs, `14` tests, each container bound on `127.0.0.1` alone
   (`21280`-`21284`); no IT wait timed out; `BOOT-INF/lib` `157` jars on both trees, no name moved (`tests`).
10. **The seven and the old surface** answer on both trees byte for byte as unit 07's values block says (its `seven` and `surface` lines). They do not reach the change, so they stay equal: the requests that can reach it are the ones springdoc-openapi's
   handlers and the page's file handler answer (the document, its YAML, `swagger-config`, the page and its files - `info`,
   `redirect`, `sealed`, `moved`).

## The change, file by file, and every README/Javadoc sentence it rewrote or noted (R.250/R.453)

Changed in `c9-tiffinbox/` (`git status --short c9-tiffinbox`: one new, two modified):
- `tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxOpenApi.java` (new): package-private, `final`,
  `@Configuration(proxyBeanMethods = false)`, one `@Bean OpenAPI openApi()` returning `new OpenAPI().info(new Info().title("TiffinBox").version("1.0"))`.
  Its Javadoc says what it does, what it does not (no server, tag, error response or security scheme), that `info.version` is the
  document's version and not a route's, and that `OpenApiSpecTest` fails until the committed file is written again.
- `tiffinbox-web/src/test/resources/openapi/tiffinbox.json`: written once, from a start of the changed tree without the harness
  (H2), `GET /v3/api-docs`, `servers` removed, `json.dump(indent=2, ensure_ascii=False)` and a final newline; `receipts.sh` only
  asserts it.
- `README.md`: the header's *Course 9, unit 08* note and a `## Course 9 · unit 08` card.

Not changed (asserted byte-equal to unit 07's): the three POMs, `OpenApiSpecTest.java`, every property file and migration.

The stale-sentence hunt over `after/README.md` (`info`, `OpenAPI definition`, `v0`, `swagger`, `api-docs`, `springdoc`,
`BOOT-INF/lib`, `157`, `45`), each hit decided: the unit 07 card's "no `OpenAPI` info bean, no annotation" is unit 07's own dated
history and stays as written; its "with the document's `info`" is true and now paid; the header's unit 07 note and the set-up's
`146` stay as the starting point, kept as written. `OpenApiSpecTest`'s Javadoc - an info bean makes the test fail until the file is
written again - is true and stays (the test file is not edited). No sentence says the title is `OpenAPI definition` as current.

The earlier units' receipts (R.211/R.331): the bean's path, `openapi/tiffinbox.json` and `c9-tiffinbox/README.md` searched over
`c9-unit01`…`c9-unit07`'s `receipts.sh` and `harness/`, `C9/_builders/*.py` and the series tools. Hits: unit 07's `receipts.sh` and
`chk07.py` name the committed file - each reads its own frozen `after/`, never the live anchor; units 01-04 and 07 compare their
`after/` with `../c9-tiffinbox` in the note form (they will print that the anchor moved); unit 03's
`instance` view greps the live anchor's main sources for `setInstance` and `ProblemDetail.forStatus`, and the bean holds neither.
No `die` reads the live anchor.

## Which tree, which profile

`before` = unit 07's `after`: Spring Boot `4.1.3`, Framework `7.0.11`, Tomcat `11.0.29`, springdoc-openapi `3.2.1`, Swagger UI
`5.35.1`, `17` handler methods, `45` tests at `package`, `157` jars, the committed file `9851` bytes with springdoc-openapi's `info`.
`after/` = that tree plus this unit's change. The default profile everywhere; H2 in memory unless a line says PostgreSQL `18.6`
(the image by its digest, `127.0.0.1:20971` alone, a fresh database per JVM). Two kinds of start, never mixed: every claim about the
document or the page is read from a start without the harness (a start that joins it documents the harness's routes too - the `diff`
capture counts them); the second client (the key table, the customer rows) exists only on a start that joins it (`diff`, the plant
page's start). The page's starts have no second client; their witness is the access log.

## Unit 08's section

The spine, against S2B :177-:178: the same document, drawn. Swagger UI is a page TiffinBox serves from its own jar (`redirect`:
the page and its files, every one from `/swagger-ui/`), and a sealed browser shows it asks for nothing but TiffinBox (`sealed`: the
judge's green line beside the plant's red). Try it out sends a real request - one line in TiffinBox's access log, the same answer
`curl` gets (`tryit`). It is pinned to the versions this run printed, and recorded to be re-recorded (`versions`). The hook (`19`
words), the exercise (`17` words) and the gloss (`8` words) pass every gate (`s908.py`, dur9, the status gate, the spelling gate, the
Hinglish list). The failure receipt is `tryit`'s three lines (the document's `*/*`, the request's `accept: */*`, the answer's
`application/json`); the unsealed control is not run (S9.5). The hazards, each with its capture: the bundle names the validator's
host three times and the served configuration leaves the validator address empty (`sealed`); the expand click, measured both ways
(`tryit`); `oauth2RedirectUrl` in `swagger-config` carries the port and is masked (`after`, `info`); the two `data:` images are not
requests (`sealed`). The hand-off of S1B §Q-d (RED #15): the dev five are absent from the default run and the harness's routes are
never in the jar (`census`).

## Version-bound: what to re-record

A move of springdoc-openapi, Swagger UI or Chrome invalidates `sealed`, `ops`, `tryit`, `tryitpg`, `versions`, `redirect` and the committed
file (springdoc-openapi writes the document; Swagger UI draws the page and names its files; Chrome makes the requests); it does not touch
`seven`, `surface` or `moved`'s old routes, which do not reach springdoc-openapi's handlers. As the run printed them, and recorded to be
re-recorded: springdoc-openapi `3.2.1`, swagger-core `3.0.0`, Swagger UI `5.35.1`, Spring Boot `4.1.3`, Chrome `158.0.8127.37` (yours will differ). Chrome's version is the one the run printed, and yours will differ.

## The captures — what each one shows

### tests — the counts per runner, the jars
`mvn -o clean package` on a copy of `after/`, its Docker-free twin and `mvn -o clean verify` on a third copy: Surefire's XML per
class, the five `IT BINDINGS` lines, `BOOT-INF/lib` on both trees and the names that moved (none).

### census — handlers, operations, the jar
The two flag starts' `/actuator/mappings` (`after/` on `20973`, `before` on `20976`): TiffinBox's `17` rows and springdoc-openapi's `4`
equal on both trees; the partition by commit (`git grep`, the dev classes apart); the handlers against the document's operations;
`unzip -l` of each jar (`0` `probe/` entries) and the plant jar.

### after, before — the five addresses and the document
Each tree on its own start without the harness: status, type and `Location` of the five addresses; the document's facts; the body
hashed masked and with `servers` removed (the latter equal on both databases and equal to the committed file).

### redirect — the page's address and its files
`/swagger-ui.html` → `302` → `/swagger-ui/index.html` `200` `text/html`, then every file the page names (read off its own `href=`
and `src=`), each `200`; the same lines on PostgreSQL, H2 and `before`.

### info — the bean moved `info` and nothing else
The two documents compared by `chk08.py infodiff`: `info` before and after, the two hashes with `info` and `servers` removed (read
back), the member order, what differs, `servers` masked, the counts; the YAML's two lines; `swagger-config` masked; the three plants,
the empty input, the two typed strings.

The code panel - the bean's head, and the committed file's diff against unit 07's:

```
@Configuration(proxyBeanMethods = false)
final class TiffinBoxOpenApi {

    @Bean
    OpenAPI openApi() {
        return new OpenAPI().info(new Info().title("TiffinBox").version("1.0"));
    }
}
```

```
-    "title": "OpenAPI definition",
-    "version": "v0"
+    "title": "TiffinBox",
+    "version": "1.0"
```

### sealed — the page asks only TiffinBox
One sealed headless Chrome per page: its flags printed, the dead proxy refused before it starts, `cdp.mjs open`, `seal9.py cdp`
host by host, every CDP request with its answer, the validator three ways, the NetLog through `seal9.py netlog` and `chk08.py`'s own
read; the plant page on its own start; the probe's filed run; the empty, off-by-one and planted inputs; `before`'s page; the bundle.

The host table and the requests, as the run printed them:

```
CDP request host 127.0.0.1:20970                          x9
CDP requests: 11 (9 to a socket, 2 data:/file: with no socket)
CDP verdict: the page asked nothing but 127.0.0.1
CDP request GET http://127.0.0.1:<port>/swagger-ui/index.html -> 200 text/html
CDP request GET http://127.0.0.1:<port>/swagger-ui/swagger-ui.css -> 200 text/css
CDP request GET http://127.0.0.1:<port>/swagger-ui/index.css -> 200 text/css
CDP request GET http://127.0.0.1:<port>/swagger-ui/swagger-ui-bundle.js -> 200 text/javascript
CDP request GET http://127.0.0.1:<port>/swagger-ui/swagger-ui-standalone-preset.js -> 200 text/javascript
CDP request GET http://127.0.0.1:<port>/swagger-ui/swagger-initializer.js -> 200 text/javascript
CDP request GET http://127.0.0.1:<port>/v3/api-docs/swagger-config -> 200 application/json
CDP request GET http://127.0.0.1:<port>/swagger-ui/favicon-32x32.png -> 200 image/png
CDP request GET http://127.0.0.1:<port>/v3/api-docs -> 200 application/json
CDP request Image: (inline, data: - no socket, not a request to any host)
CDP request Image: (inline, data: - no socket, not a request to any host)
```

The plant, red:

```
CDP request host 127.0.0.1:20975                          x2
CDP request host fonts.googleapis.com:443                 x1
CDP requests: 3 (3 to a socket, 0 data:/file: with no socket)
CDP OUTBOUND: https://fonts.googleapis.com/css
CDP verdict: the page asked 1 request(s) elsewhere
```

The NetLog of one run of this receipt, as found (its TCP lines are asserted; the rest is printed, never counted in a sentence):

```
NetLog TCP connect 127.0.0.1:20970                      x10
NetLog TCP connect 127.0.0.1:9                          x30
NetLog UDP connect [2001:4860:4860::8888]:443           x4
NetLog URL asked   127.0.0.1                     x11
NetLog URL asked   clients2.google.com           x1
NetLog URL asked   accounts.google.com          x2
NetLog URL asked   content-autofill.googleapis.com x14
NetLog URL asked   www.google.com               x1
NetLog URL asked   www.gstatic.com              x1
chk08's read: UDP connects 4 ([2001:4860:4860::8888]:443) · their net_error values {-109: 4} · UDP_BYTES_SENT 0 - printed as found, not asserted, never voiced
chk08's read: TCP connect addresses 127.0.0.1:20970,127.0.0.1:9 · every TCP connect to loopback: yes
```

### ops — what the page shows
Through `cdp9.mjs eval` once the operations' count held on two polls: the title block, every operation's id, the tags against the
document's, the Servers control (masked), on `after/` and on `before`; the detector on the plant page.

### tryit, tryitpg — one request, the answer, the access-log line
The operation id read off the document; every step's state before and after; the request CDP saw, its answer and body md5 beside a
`curl` of the same address; the page's shown status, URL and curl line; the access log before, after and its new line; the
document's media types for the operation. On PostgreSQL the same, and `psql`'s row. As the run printed them (H2):

```
the access log before the click: 10 lines
state before: {"open":false,"tryout":false,"input":false,"execute":false,"liveRows":0,"status":null}
click 1 (.opblock-summary-control), state after: {"open":true,"tryout":false,"input":false,"execute":false,"liveRows":0,"status":null}
click 1 outcome: opened
click 2 (.opblock-control-arrow): not clicked - click 1 opened the operation
requests after the click: 1
request: GET http://127.0.0.1:<port>/api/v1/customers/Ravi · accept */* · Referer http://127.0.0.1:<port>/swagger-ui/index.html · user agent ... HeadlessChrome/158.0.0.0 ...
response: 200 · Content-Type application/json · body 67 B md5 5394e0ebc1b6958ada589aa5314f5316
the page shows: status "200" · request URL "http://127.0.0.1:<port>/api/v1/customers/Ravi" · curl "curl -X 'GET' \\ 'http://127.0.0.1:<port>/api/v1/customers/Ravi' \\ -H 'accept: */*'"
the access log after the click: 11 lines (+1)
access: GET /api/v1/customers/Ravi- 200 67
the document's response media types for customer-reads-one: 200 */*
```

### versions — each from its witness
The jar names in `BOOT-INF/lib`, Boot's banner, the webjar's `pom.properties`, the page's `window.versions`, Chrome's
`Browser.getVersion`, node and java.

### committed — the file, the test, the stale file, two drifts
The file's bytes against the arithmetic, the fixed rule, the equality with the served documents, its diff; `OpenApiSpecTest` in
`package` and the twin; the stale file, the drifted file, the drifted code - each a Maven run on a scratch mirror, its FAIL line kept.

### diff — the spec against the wire
`specwire9.py send` and `diff` (a) and (b) on a start that joins the harness, the plant, the empty refusal, the request witness on
the five addresses and `/nowhere`, the second client's rows, unit 07's values beside.

### moved, seven, surface — what the bean could have moved
Fourteen requests on each tree (`moved`), the seven and the old surface by count, each tree its own JVM; the S9.14 self-test.

### inert — the key header and the key table
Every request block's key line, the filed requests, the key table on every start that joins the harness, and the page's sessions
read off the access log (every request a GET).

### exercise — under bash and zsh
`check.sh` on the broken state and on the solution (`apply.sh` in a headless sealed Chrome) under bash then `zsh -f`; the refused
"solutions" (a `curl` of Ravi, Meera, two requests, the page opened with nothing executed) and the old route's near miss, under bash.

## Measured, not shipped

The exposure flag (`--management.endpoints.web.exposure.include=health,prometheus,mappings`, the two census starts only); the harness
classes (`probe.*`, `/probe/**` - the plant page among them), the request witness's logging, the access log's pattern (the receipt's
starts, and the exercise's `%{Referer}i` on its own start); the sealed Chrome, its profile and `cdp9.mjs`; the stale file, the
drifted file and code (scratch mirrors under `.harness/`); the shallow ETag plant; the exercise's solution and its refused variants.

## Refused, named

Each `XU08` reading in `harness/s908.py` (twenty-two families, each with its plant and its near miss, listed in that file and run by
its self-test before any prose is judged). Not run: the unsealed control (S9.5). Not
done here, by its lesson: error responses and a security scheme (*Documenting Errors, Examples and Security*), the generated client
(*Code Generation From the Contract*), the HTML page REST Docs writes (*Spring REST Docs*), versioned routes (*Versioning Strategies*).
No clock figure is used as a number.

## The repository, and the network

`D` = `tiffinbox-java`, HEAD `bf9b296` at the start, clean, `0 0` against `origin/main`; one commit for `c9-unit08/` and the three
paths of `c9-tiffinbox/`, then one push. Every Maven build is offline (`-o`) from a `cp -c` copy of `_research/m2-seed-c9-s2`
(`11004` files, `876159996` bytes, `_remote.repositories` naming central-only: `0`); no pull, no image pulled. The only network a
run touches is Chrome's own, which the seal refuses and the NetLog prints. The advisories are today's filed read
(`_research/docs-2026-11-24/advisories/`, fetched at `2026-11-24T20:36:35Z`), not read again: Tomcat's section for `11.0.30` and
OSV's "none" for the springdoc-openapi coordinates; no pin is affected.

## The folders, the harness and the ports

`harness/`: `chk08.py`, `s908.py` (its self-test first), `tree08.py` (`tree07.py`'s code), `dur9.py` (as shipped), and the
instruments of the probe and BLUE - `specwire9.py` and `seal9.py` (BLUE's, byte-equal, md5 `330f73f5…` and `d34433ab…`), `cdp.mjs`
(`c6-unit23`'s, byte-equal, md5 `481f4836…`), `cdp9.mjs` (the S2 probe's `cdp9probe.mjs`, md5 `09018a79…`, reviewed and edited:
its fixed waits became polls on counted conditions with a deadline, the fill is typed keyboard input and the field is left so the
page takes it, the expand control is measured both ways, the status is read from the response row's cell - its md5 is in
`receipts.md5`, its diff against the probe's is counted on every run) - and `src/probe/`: `Witness`, `Http`, `Routes`, `Etag` copied
from unit 07's harness (`c9-unit07/harness/src/probe`, md5 = its `receipts.md5` lines) and `u08/U08Probe` (the second client's reads
and the plant page). Read in place, not copied: `c6-unit23`'s `netlog.py` (md5 `869caa7d…`), the probe's `rdchrome/index-events.json`
and generated source, BLUE's bundle host list. Not used: BLUE's `loc9.py`, `gates9b.py`, `ttag.diff`, `RestDocsProbeTest-blue.java`.
Ports: `20970` `after/` on H2 · `20971` PostgreSQL `c9u08-pg` · `20972` `after/` on PostgreSQL · `20973` the flag start · `20974` the
S9.14 plant · `20975` the plant page's start · `20976` `before` · `20977` Chrome's DevTools · `20978` the exercise · `20979` never
bound; `21280`-`21284` during `verify` only; the dead proxy `127.0.0.1:9` is a connect target, never bound.

## Masks, filters and hygiene

The log mask (a Started line's figures, Maven's and Boot's clock figures, Boot's `/error` `timestamp`, the folders, the home) and the
header mask (`Date`, the session cookie, a port, `Expires`, `Keep-Alive`) each pass a self-test; a third masks `servers[0].url`'s
port; `oauth2RedirectUrl`'s port and the page's Servers control are masked in every line that prints them. The NetLog's UDP lines,
its URL lines and its TCP counts are printed and kept out of the capture hashes (Chrome's background: never asserted). The bundle's
hosts are printed as bare names. CDP's timing fields are never printed. The document's `"timeout"` (`SseEmitter`, `tiffinbox.json`)
appears only in the file, never here; dur9 over this README and the exercise: `0`. Every container is removed with its volumes;
images and volumes are equal on each run's first and last lines; each Chrome is stopped by `Browser.close`, its pid gone, its
profile folder removed, and the other Chrome processes on the machine are listed at the start and at the end, the same.

## Interrupted

Seven interrupted runs of this `receipts.sh`, each started with SIGINT at its default (`perl -e '$SIG{INT}="DEFAULT"; exec …'`: a
background job starts with it ignored, and bash cannot trap a signal ignored at entry), the signal sent to the script's own pid -
recorded at its launch, never found by a name - when its point's line appeared in that run's own log or raw capture files (the last
run's raw files removed first). Points: mid-build, mid-harness (a JVM up on `20970`), mid-container (PostgreSQL up), mid-TiffinBox on
PostgreSQL (`20972`), mid-Chrome (a headless Chrome live on `20977` with the page loaded), mid-`verify` (a Testcontainers container
live), mid-exercise. Each left nothing: no JVM, no Chrome of the run (its pid gone, its profile folder removed), no container,
volumes and images as before, `20970`-`20979` and `21280`-`21284` free, no `.r-lock`, no `.r-*.new`, no exercise file, the captures
and the anchor as before. The lines, as the interrupting script printed them, are in the commit message.

## Planted faults — each caught

Each made to fail first, on a scratch copy or in the run's own scratch files (never on `c9-unit01`…`c9-unit07` or the live anchor),
shown with its gate, removed after. The ones the receipt plants itself run in every run of record:

- `info`: the bean also adding a `servers` entry, an `externalDocs`, a tag (three scratch documents) → `infodiff` exit `1`, naming
  the member; an empty input → exit `2`; "Tiffinbox" or "1" typed as the expected strings → the exact-string check refuses, exit `1`.
- `sealed`: the harness's plant page → `seal9.py cdp` exit `1` (`CDP OUTBOUND: https://fonts.googleapis.com/css`); the probe's filed
  font run → exit `1`; an empty events file → exit `2`; the TiffinBox port typed one off (`20971`) → exit `1`; one validator event
  planted in a copy of the events → the `0` check fails on it; one non-loopback TCP connect planted in a copy of the NetLog → the
  TCP verdict says no; a host printed with its scheme → refused; `c6-unit23`'s `netlog.py` on the plant's NetLog → exit `0`, shown as
  the check that cannot fail here.
- `ops` / `tryit`: the detector "the page shows `13` operations" on the plant page's DOM (`0` operations) → fails; the status reader
  pointed at the table's header → reads `Code` → fails (RED #13's defect); the operation already open → `cdp9.mjs` exit `3`; a counted
  condition never met (the plant page, `rendered`) → exit `4` with the state printed.
- `census`: one `probe/` class added to a scratch copy of the jar → the `0` check fails on it.
- `committed`: the stale file → `OpenApiSpecTest` fails; a drifted file and drifted code → it fails (all three shown, exit `1`).
- `diff`: the plant (`mealType` → `meal_type`) moves (a) and (b) by one kind and one row; the empty wire folder → exit `2`.
- `surface`: the S9.14 self-test (the harness's shallow ETag filter): the seven equal, the surface moved, the feed silent.
- `exercise`: the broken state and four refused "solutions" fail by clause.

Planted once by hand, before the runs of record, each shown failing with its gate and removed:

```
the hook one word changed (spoken) -> exit 1 · FAIL the hook is S2B :179's, byte for byte (extracted at run time = typed once here)
the exercise one byte changed, "200" in digits (spoken) -> exit 1 · FAIL the exercise's line is S2B :187's, byte for byte (extracted at run time = typed once here) FAIL the exercise: 18 words (wc -w; the brief's 17; <=
26 words typed as <= 25 (spoken) -> exit 1 · FAIL the exercise's line is S2B :187's, byte for byte (extracted at run time = typed once here)
a README line starting "A contract:" (gloss) -> exit 1 · FAIL README.md carries no line starting "A contract:" (U06's, not re-glossed) [12]
the Swagger UI gloss typed twice (gloss) -> exit 1 · FAIL README.md carries exactly one line starting "Swagger UI:", the gloss byte for byte ([5, 12])
README sentence "Nothing leaves the machine." (s908.py) -> exit 1 · refused 1: XU08: U08: nothing leaves the machine / 0 outbound / 127.0.0.1 only / zero, of the NetLog
README sentence "The NetLog shows 0 outbound." (s908.py) -> exit 1 · refused 1: XU08: U08: nothing leaves the machine / 0 outbound / 127.0.0.1 only / zero, of the NetLog
README sentence "The page asks for nothing else." (s908.py) -> exit 1 · refused 1: XU08: U08: the page asks for nothing else, without the judge's green line and the plant's red line
README sentence "It loads eleven requests." (s908.py) -> exit 1 · refused 1: XU08: U08: eleven requests
README sentence "Try it out is read-only." (s908.py) -> exit 1 · refused 1: XU08: U08: Try it out read-only / safe / harmless
README sentence "The info bean changes nothing else." (s908.py) -> exit 1 · refused 1: XU08: U08: the info bean changes nothing else, without the re-read hashes
README sentence "The seven are unchanged." (s908.py) -> exit 1 · refused 1: XU08: U08: unchanged / untouched / re-measured of what the bean cannot reach
README sentence "The expand click works." (s908.py) -> exit 1 · refused 1: XU08: U08: the expand click works, without the filed state line
README sentence "It runs in Chrome 158." (s908.py) -> exit 1 · refused 2: XU08: U08: Chrome's version without "yours will differ"
README sentence "The page answers 404." (s908.py) -> exit 1 · refused 1: XU08: U08: a status said as digits or in the hundred form
README sentence "It reads the OpenAPI document." (s908.py) -> exit 1 · refused 1: XU08: U08: bare OpenAPI / springdoc in a spoken line
README sentence "The validator is turned off." (s908.py) -> exit 1 · refused 1: XU08: U08: the validator turned off by a setting
README sentence "TiffinBox answers in a moment." (s908.py) -> exit 1 · refused 3: R.388's family: a moment
near miss "Open A-P-I and spring doc read the same document." (s908.py) -> exit 0 · self-test: 479 cases · XFAM_S9S1 9 families · U08 22 families · refused: 0
near miss "Nine requests, all to TiffinBox, and two inline images that are not requests." (s908.py) -> exit 0 · self-test: 479 cases · XFAM_S9S1 9 families · U08 22 families · refused: 0
a stale sentence left in unit 08's card (static) -> exit 1 · FAIL the stale hunt: unit 08's card says nothing as current that the change makes false (['title is \\"OpenAPI definition\\"'])
a pom line added (static (iii)) -> exit 1 · FAIL no other file differs between before and after/ (before 98 files, after/ 99) ['tiffinbox-web/pom.xml'] FAIL (iii)-(v) byte-equal to before (U07's
the file committed with servers (static) -> exit 1 · FAIL the committed file: no servers, written by the fixed rule FAIL the committed file with info removed: byte-equal to unit 07's, the member order eq
the bean given a description (static) -> exit 1 · FAIL ONE @Bean OpenAPI, info = title "TiffinBox" and version "1.0", nothing else FAIL the bean's code names no description
the test edited at all (static (v)) -> exit 1 · FAIL no other file differs between before and after/ (before 98 files, after/ 99) ['tiffinbox-web/src/test/java/com/tiffinbox/web/OpenApiSpecTest.java
45 + 0 made 45 + 1 (tests) -> exit 1 · FAIL pkg: 46 = U07's 45 (its README values block; re-measured) + 0 (no new class); OpenApiSpecTest 1
an IT BINDINGS line removed (tests) -> exit 1 · FAIL IT BINDINGS: classes 5 (found 4)
an IT's address 127.0.0.2 (tests) -> exit 1 · FAIL IT BINDINGS: entries 5 · not 127.0.0.1: 1
an IT's port one off (tests) -> exit 1 · FAIL RedisDatastoreIT on 127.0.0.1:21282
one more jar moved (tests) -> exit 1 · FAIL BOOT-INF/lib 157 -> 157 (U07's 157), no jar's name moved
the seven's md5 one character off (seven) -> exit 1 · FAIL before: the seven = 466c20ed
two requests after the click (tryit) -> exit 1 · FAIL a tryit line this checker cannot parse: '  request: GET http://127.0.0.1:<port>/api/v1/customers/Ravi · accept junk · accept */* · Referer htt
the access-log count not +1 (tryit) -> exit 1 · FAIL h2: the access log +1 line
a POST from the page (tryit) -> exit 1 · FAIL h2: the request: GET .../api/v1/customers/Ravi
a listing line chk08 cannot parse (tryit) -> exit 1 · FAIL a tryit line this checker cannot parse: '  access: GET /api/v1 a line that cannot parse x y z' · traceback: 0
the TiffinBox port typed one off in the host table (sealed) -> exit 1 · FAIL the host table: 127.0.0.1:20970 only (x9)
the receipt holding the green line only (sealed) -> exit 1 · FAIL the plant (the harness's page): seal9.py cdp exit 1, CDP OUTBOUND: https://fonts.googleapis.com/css
a swagger-config with a non-empty validatorUrl (sealed) -> exit 1 · FAIL the served swagger-config: validatorUrl ""
a bundle host printed with its scheme (sealed) -> exit 1 · FAIL the bundle's hosts: 20 distinct, printed bare (no scheme)
a non-loopback TCP line in the capture (sealed: a STOP line) -> exit 1 · FAIL the NetLog's TCP lines: 127.0.0.1:20970, 10.0.0.9:443
a probe/ class in the shipped jar (census) -> exit 1 · FAIL the jars: 0 entries named probe/ on both (the harness's routes never in the jar)
a mapping line moved (an absent handler counted, census) -> exit 1 · FAIL absent: DashboardPage's three
a request with the key header outside pause-key (inert) -> exit 1 · FAIL .r-after.new: no curl request sent the key header (10 sent none)
```

## What differed from the brief

Each flagged contradiction of the prompt, the pick, and what the run did with it. `[ORCH 2026-11-25]` marks the orchestrator's picks,
bound and kept.

- `1`. The anchor change [ORCH (1)]: the bean, kept. Measured: it moved `info` and nothing else (`info`). One thing the prompt did not
   name: the bean's method was first called `tiffinBoxOpenApi`, the same name as its class's own bean, and the application refused to
   start (`BeanDefinitionOverrideException`); the method is `openApi()`. The class name, `TiffinBoxOpenApi`, is this unit's.
- `2`. `before` is the link `../c9-unit07/after`; its tree pin is `c9-unit07/receipts.md5`'s `after-tree` line, read at run time.
- `3`. "Only `info` moved": (a)-(e) in `info`, (f) in `sealed` (vii), (g) in `diff`. The bean's possible `servers` entry is caught by
   its own line (servers equal after the port mask), since (b) removes `servers` from both sides; the three plants fail by name.
- `4`. The committed file, written once from a start of the changed tree without the harness, on H2; `9843` bytes = the arithmetic's
   prediction; its diff the two `info` lines.
- `5`. Tests stay `45` + `0`: S9.11 is met by unit 07's `OpenApiSpecTest`, red on the stale file, green on the regenerated one.
- `6`. The count of every CDP event: CDP's count is printed as the tool prints it (`11 (9 to a socket, 2 data:/file: with no socket)`); the
   sentence the video may say is "nine requests, all to TiffinBox, and two inline images that are not requests".
- `7`. The planted red request rides the harness's page `/probe/u08/plant` on its own start (`20975`, the harness joined); the probe's
   filed font run is the second red, read.
- `8`. `20977` is the DevTools port only; the dead proxy is `127.0.0.1:9`, refused (curl exit `7`) and never bound, before every Chrome.
- `9`. The NetLog is printed by its own names; the TCP lines are asserted (all to this computer); the UDP and URL lines are printed as
   found, not counted in a sentence. The probe's reading holds on this run: the UDP connects go to a public IPv6 address on port
   `443`, not to the proxy.
- `10`. The hook is kept as the brief gives it; RED is handed the question which half is measured (For RED).
- `11`. `validatorUrl` from the served `swagger-config` and `0` CDP events to the validator: asserted. The bundle is censused. BLUE's md5
   `43c1e572…` could not be reproduced as written (BLUE's filed list is sorted by count; its own file's md5 is another), so the
   receipt compares the list line for line against BLUE's filed file instead - equal. The optional second validator plant (the
   property set to the public validator) was NOT run (dropped: time), "not captured, not said".
- `12`. The expand click [ORCH (2)]: measured from a closed state in every run; the summary control's click opened the operation, so
   the arrow was not clicked - the reverse of the probe's note (NOTES :127-:128, whose failing draft is not filed). Both outcomes
   are in `tryit`. `cdp9.mjs` needed two more edits the prompt did not name, each measured first: the fill must be typed keyboard
   input (`Input.insertText`) and the field left (`blur`) - a value set by script and a fill without leaving the field both left
   Swagger UI saying "Required field is not provided" and sent no request.
- `13`. `tryit` measures `customer-reads-one`; the old route's read by name is run once as the near miss; the exercise accepts either.
- `14`. The exercise: `sealed.sh` added to `exercise/`; `check.sh` reads its own start's access log with the Referer. The PostgreSQL run
   of the exercise was not made (H2 only), so the exercise says nothing about PostgreSQL.
- `15`. No unsealed control [ORCH (5)].
- `16`. One gloss line, `Swagger UI: a page drawn from the document.`; no `A contract:` line; unit 06's gloss line byte-equal.
- `17`. The hook (`19` words) and the exercise (`17`) extracted from the brief at run time and gated; "Swagger" and "UI" pass bare.
- `18`. The spec's `timeout` is not quoted in this README.
- `19`. Ports as the prompt picked them.
- `20`. PostgreSQL: `after`, `redirect` and `tryitpg` run on both databases; unit 07's `diffpg` is not run again.
- `21`. The census line in `census`, by the anchored grep and the flag starts; `0` `probe/` entries in each jar.
- `22`. `versions`: each from its witness; the page's own version string (`window.versions`) is printed.
- `23`. Instruments as listed in "The folders, the harness and the ports".
- `24`. The stale-sentence hunt, decided line by line.
- `25`. The earlier receipts' grep: no `die` on the live anchor.
- `26`. Two lines in `C9/FACTORY-NEXT.md`.
- `27`. `0 0` → `0 1` → `0 0`.
- `28`. specwire9's rows `7` / `16` and `8` / `17`, equal to unit 07's values block.
- `moved` runs its two JVMs without the harness (unit 07's `c_moved` form, copied), where the prompt said harness-joined companions:
  a harness-joined start documents the harness's routes, so its `/v3/api-docs` would not be the document either tree serves.
- The `c6-unit23` `netlog.py` demonstration runs on the plant page's NetLog, once per run.

## For RED

- **The hook's "can reach nothing but TiffinBox"** against the NetLog: every TCP connect went to this computer, the dead proxy
  included, but the NetLog also holds UDP connect lines (each `net_error` `-109`, no bytes sent) and addresses Chrome's own
  background asked for. The hook's second half is what the judge measures (green, with the plant red in the same receipt);
  "a browser that can reach nothing but TiffinBox" rests on the resolver rule and the dead proxy, as found on this machine. The
  smallest alternative this unit would gate: "Swagger UI loads in a sealed browser, and the page asks for nothing but TiffinBox."
  (counted and gated here, not shipped).
- **CDP's `11` against "nine and two"**: CDP's `11` counts every `requestWillBeSent`; the video's sentence is the nine and the two.
- **The gloss line** `Swagger UI: a page drawn from the document.` (`8` words) beside the brief's parenthetical (`6` words): the
  scripts stage decides the sentence.
- **The hook and the exercise**: `19` and `17` words, every gate `0`, the extracted list's md5 in `static`'s output.
- **The exercise's two GET-by-name operations**: the check passes on either (the old route's is run once as the near miss).
- **The file's size**: `9843` bytes by `wc -c`, the arithmetic's prediction from unit 07's `9851`; the socket's answer carries a
  five-digit port and is never voiced.
- **The `info` hashes**: printed in `info` and read back by `chk08.py`, which hashes the two saved documents itself.
- **The seven and the surface**: equal, and not witnesses for this change (they do not reach it).
- **The expand click**: the summary control opened the operation in every run; the arrow was never needed - the opposite of the
  probe's note.
- **The validator plant** (the property set to the public validator) was not run: what Swagger UI would do then is unmeasured.
- **`tryitpg`**: measured; the same request and answer as H2's.
- **The advisories' age**: today's filed read, fetched `2026-11-24T20:36:35Z`, read the evening before this run.
- **The earlier receipts** (flag 25): no `die` reads the live anchor; their note form will print that the anchor moved.
- **dur9**: `harness/dur9.py` = `java9_series.DUR9_MD5` and units 01-07's copies.
- RED2 #4 (the judge host by host, the NetLog as what it prints, `c6-unit23`'s `netlog.py` cannot fail - shown), #13 (the expand click
  exercised; the status read from the response row - the header plant reads `Code` and fails), #14 (the bundle's hosts censused,
  `validatorUrl` empty, `0` validator requests), #15 (the dev five, the jar), #33 (nine to TiffinBox, two `data:`, one GET with
  `accept: */*`).

## The ledger rows this unit pays

- `TRACK-ROADMAP.md:378` - "springdoc-openapi and Swagger UI — the live UI on TiffinBox.": the page, loaded in the sealed browser,
  thirteen operations, Try it out measured (`sealed`, `ops`, `tryit`).
- **`C9-10d`, the second half** (LED :44): "the Swagger page answer four-oh-four" → the page answers `200` and loads in the sealed
  browser; the first half was unit 07's.
- **C9-11**: the seven and the old surface run again at this anchor change, equal on both trees.
- C9-3: the hook's and the exercise's lines byte for byte with the brief's; C9-13: nothing owed here.

## The values the video may say

Each with its capture, its database and its witness; every one is in the values block below, which `chk08.py values` asserts
equal to each run's own:
- the document's title and version, "TiffinBox" and "one point oh" (`after`, `info`; PostgreSQL and H2; the served document), where
  springdoc-openapi wrote "`OpenAPI` definition" and "v0" (`before`; H2) - said as "Open A-P-I definition" when spoken;
- with the document's `info` removed, the two documents hash the same (`info`; H2; the two hashes, read back);
- nine requests, all to TiffinBox, and two inline images that are not requests (`sealed`; H2; CDP's events through `seal9.py`);
- the judge red on the planted font request (`sealed`; the harness's page);
- thirteen operations in six tags on the page (`ops`; H2; the page's DOM), seventeen handler methods, thirteen operations
  (`census`; the flag starts);
- Try it out sent one GET for Ravi, asked for any type, and got two hundred, `application/json`; the access log holds its one line
  (`tryit`; H2 and PostgreSQL; CDP and Tomcat's access log);
- the committed file `9843` bytes (`committed`; `wc -c`);
- forty-five tests at `package`, fourteen in containers (`tests`);
- the seven and the old surface equal on both trees (`seven`, `surface`; H2);
- springdoc-openapi `3.2.1`, Swagger UI `5.35.1`, Spring Boot `4.1.3`, and the Chrome version the run printed - yours will differ
  (`versions`).

<!-- values: begin -->
```
tests: tests=45 tests_u07=45 tests_k=0 its=14 it_entries=5 lib=157->157
census: annotations=22 dev_mappings=5 handlers=17 handlers_u08=0 operations=13 paths=11 absent=3 merged=1 springdoc_rows=4 probe_in_jar=0
after: openapi=3.1.0 info=TiffinBox/1.0 paths=11 operations=13 tags=6 schemas=Customer,SseEmitter socket_bytes_not_voiced=4349 spec_md5=36cd86c7 validatorUrl=empty pg_equal=yes
redirect: redirect=302->index.html static_files=7
tryitpg: pg=measured
before: before_info=OpenAPI_definition/v0
info: info_rest_md5=eb08ed40 info_moved=title+version rest_equal=yes
sealed: cdp_socket=9 cdp_inline=2 bundle_hosts_bare=20 bundle_lines_blue_form=21 bundle_validator=3 judge=green plant=red second_red=red validator_events=0 validator_badges=0
ops: page_title=TiffinBox/1.0 page_ops=13 page_tags=6 before_title=OpenAPI_definition/v0
tryit: pg_equal=yes status=200 type=application/json body_md5=5394e0eb click1=opened requests=1 accept=any
versions: springdoc=3.2.1 swagger_core=3.0.0 swagger_ui=5.35.1 boot=4.1.3 chrome=158.0.8127.37
committed: spec_bytes=9843 spec_md5=36cd86c7 test=PASS stale=FAIL drift_file=FAIL drift_code=FAIL
diff: kinds_b=8 rows_b=17 kinds_a=7 rows_a=16 required=2/4 star=12/13 errors_documented=0 key_named=0 witness=/nowhere
moved: asked=14 moved=2 unmoved=12 patch_customers=405:GET+POST
seven: seven=466c20ed
surface: surface=316a9637
inert: keyed=pause-key key_rows=0/1 page_requests=GET_only
exercise: exercise=broken-FAIL1,solved-PASS,refused-4-FAIL,oldroute-PASS,bash+zsh,h2
static: xfam_s9s1_md5=1f5217a0 files_new=1 files_changed=2 spec_bytes=9843 spec_bytes_u07=9851
gloss: gloss=Swagger_UI_one_line
spoken: hook_words=19 exercise_words=17 gloss_words=8
build: seed_files=11004 seed_bytes=876159996 central_only=0
```
<!-- values: end -->
