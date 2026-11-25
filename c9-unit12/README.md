# Course 9 · Unit 12 — Versioning Strategies

**Course 9's ninth change to the anchor, Section 2's sixth and last unit, the anchor's first change to `tiffinbox-web/src/main` since
unit 09 and its first change to how a request is routed.** The web module gains one configuration class, `TiffinBoxApiVersioning`
(`usePathSegment(1, ...)` restricted to paths under `/api/`, `setVersionRequired(false)`, `addSupportedVersions("1.0")`), and one test
class, `ApiVersionTest`, with two tests in the default run. No pom moves; the five literal `/api/v1/...` mappings keep their strings.
`before` is a link to `../c9-unit11/after` (unit 11's tree); `after/` is a frozen copy of `../c9-tiffinbox` after this unit's change.
Every number below names its tree and is read by `harness/chk12.py` off a capture of `receipts.sh`, never typed. No Chrome runs in this
unit. No PostgreSQL capture: H2 only (`callpg` dropped first, as the drop order says).

The unit's one gloss, typed once in `harness/chk12.py`:

A version carrier: where the version travels.

The hook, as the brief gives it (S2B's Unit 12 Hook line), byte for byte; it passes every gate of `harness/s912.py`:

Ask for version two in the media type, and a header-versioned server with a default answers version one, labelled two.

That hook is about a loser, the header carrier with a default (`default`, below), not about TiffinBox: TiffinBox's own carrier is the
path segment under `/api/`.

## Runs of record

Three runs, each launched below load1 `20` (R.480) with its load printed on its first line: bash `3.2.57` (`./receipts.sh`), bash
`5.3.9` (`bash receipts.sh`), and a sealed fresh clone in a folder whose name holds a space (R.129), run from that clone. Every build
says offline: yes (`Downloading from` `0` in every Maven log). Each run ends `every capture = published (19)`, and
`check_unit9.py 12 --runlog <log>` prints the run-log gate's PASS on each (the unit gate exits `2` until unit 12's script exists, as the
prompt expects). The capture hashes are the `receipts.md5` lines; the loads are in the commit message. No clock figure of a run is a
measurement and none is said here.

## RE-MEASURE (settled first)


- **`choose`** - the path strategy on `/api/`, sent before any sentence, on `before` (21016) and `after` (21010), each its own JVM,
   H2, no harness. `GET /api/v1/customers/Ravi` answers `200` `application/json`, Ravi's four members, on both trees. `GET
   /api/1.0/customers/Ravi` answers `404` `application/problem+json`, `No static resource api/1.0/customers/Ravi.`, on both trees: the
   five routes are literal strings, so the second spelling of version one names a path no handler maps. The same is true of `/api/v3/`,
   `/api/2.0/`, `/api/customers/Ravi`, `/api/v1/nowhere`, `/api` and `/api/`: each `404` on both trees, the static handler's not-found.
   A version under `/api/` is read only when a mapping's pattern matches the path; on TiffinBox's literal routes only `v1` matches. The
   wrong carriers (`API-Version: 2.0`, `Accept: application/json;version=2.0`, `?version=2.0`) are ignored by the path strategy: the
   old address answers Ravi, and the media-type request gets its parameter echoed in the `Content-Type`, on both trees alike. `OPTIONS`
   and `HEAD` answer as before. The fourteen lines are equal on `before` and `after`: `0` moved. The seven answer
   the expected md5 on both trees, and the old surface its expected md5 on both (`seven`, `surface`; the values block names both). The planted variant
   (`harness/mirror/required.diff`: `setVersionRequired(false)` removed) runs the same list once per run on 21014: the unversioned old
   route `/customers/Ravi` answers `400` `API version is required.`, the seven move to `7d36b99e...` (the probe's
   required-variant seven), and `ApiVersionTest` on that mirror goes red - the check that can fail does.

- **`tests`** - the whole reactor at `mvn -o clean package`: the parent and three modules, each `SUCCESS`; `tiffinbox-web` `52` tests
   (unit 11's `50` and the `2` this change adds), `ApiVersionTest` `2` run, `0` failures, `0` skipped; `tiffinbox-client` `1`; the
   Docker-free twin the same; `verify` on the whole reactor: the five ITs, `14` tests, five `IT BINDINGS` lines, every entry on
   `127.0.0.1`. The test classes that send `/api/v1/` (`ApiVersionTest`, `CustomerPatchesTest`, `CustomerReadsTest`, `IdempotencyKeyTest`,
   `TiffinBoxRestDocsTest`, by `grep -l`) all pass: the configurer broke no existing test. The hand-built form (`-pl tiffinbox-web -am`) prints the same web counts.
   `BOOT-INF/lib` `157` before and after, no jar name moved.

- **`change`** - the parent's `<modules>` `3` before and `3` after; the four poms byte-identical; the derived changed list is the README,
   the new class and the new test. The five mappings under `src/main` are literal (`CustomerReads`, `CustomerPauses` twice,
   `CustomerPatches` twice), none with a version attribute or `{version}`. The web jar runs `spring-webmvc-7.0.11.jar`.

- **`four`** - the carrier mirror (`harness/mirror/nover.diff`: the shipped class deleted, the harness's `Versioning12` the JVM's one
   configurer, its route pair `/vapi/customers` and `/vapi/{v}/customers`), one JVM at a time on 21013. H (a required header), Q (a
   required query parameter) and M (a required media-type parameter) each answer their own carrier and refuse every other one with
   `400` `API version is required.`; each refuses the old routes `/customers/Ravi` and `/api/v1/customers/Ravi` the same way; each moves
   the seven to `7d36b99e...`. P (the path segment under `/vapi/` only, not required) answers `/vapi/1.0/` and `/vapi/2.0/` with their
   handlers, refuses `/vapi/customers` with `Invalid API version: 'customers'.`, and leaves the old routes and the seven
   (the expected md5) alone. Version three prints as `3.0.0`. M's hazard is measured: a `Content-Type: application/json;version=2.0` on a GET
   is read as the version and version two answers.

- **`required`** - two witnesses of one claim: the harness's H on its own route and the planted shipped-class twin on TiffinBox's
   `/customers/Ravi`, each `400` `API version is required.`, each with the seven at `7d36b99e...`.

- **`default`** - HD (a header with a default of `1.0`), trap 4: `Accept: application/json;version=2.0` answers `200` with the
   `Content-Type` `application/json;version=2.0` and the body `{"handler":"1.0"}` - the body says `1.0`; the header says `2.0`. The right
   carrier (`API-Version: 2.0`) answers `2.0`; no carrier answers `1.0`. Both ways: the same Accept against H is `400`, the header client
   against M is `400`. HD's seven the expected md5: a default makes the unversioned routes answer.

- **`newest`** - HN (a header, not required, no default): no version answers `{"handler":"2.0"}`, the newest; the seven the expected md5.

- **`deprecate`** - the shipped class with a deprecation handler for `1.0` (`harness/mirror/deprecate.diff`, the probe's dates and
   link). Stamped with `Deprecation`, `Sunset` and `Link` (`rel="deprecation"`): the real `/api/v1/customers/Ravi`, and on a
   harness-joined start of the same jar the harness's `/api/1.0/u12/handler` and `/api/v1/u12/handler`. Not stamped: `/api/1.0/customers/Ravi`
   (a `404`: no route), the harness's `/api/2.0/u12/handler`, `/u12/plain`, `/customers/Ravi`, `/customers`, `/revenue`, `/nowhere`. The
   answers stay as they were; the seven the expected md5. Python read the `Sunset` value's day field: `2` digits.

- **`retire`** - the PATH carrier (`harness/mirror/retire.diff`: `addSupportedVersions("2.0")` in place of `"1.0"`): `GET
   /api/v1/customers/Ravi` answers `400` `application/problem+json` `Invalid API version: '1.0.0'.`; the Nobody request the same
   sentence; `/api/2.0/customers/Ravi` is `404` (no route maps it); `/customers/Ravi` still `200`; the seven the expected md5. The
   retired version's handlers are still mapped: `/actuator/mappings`, with the harness's exposure flag, lists
   `/api/v1/customers/{name}` and both pause patterns while the request answers `400`. The HEADER carrier, once (HR): `API-Version: 1.0`
   answers `400` `Invalid API version: '1.0.0'.`, `2.0` answers `200`, the seven `7d36b99e...` (a required header). The two carriers
   name the retired version in the same sentence.

- **`type`** - the Nobody not-found under the versioned route: `GET /api/v1/customers/Nobody` answers `404` on both trees with the
   same members (`detail`, `instance`, `status`, `title`, `type`, `name`), `type` `tag:tiffinbox.example,2026:customer-not-found` (the
   committed file's example), `instance` `/api/v1/customers/Nobody`; the old `/customers/Nobody` and the merge PATCH unmoved. On the
   retired mirror the same request answers the retirement's `400`, with no `type` member: a retired version hides the not-found.

- **`client`** - unit 10's generated client, not regenerated: `.openapi-generator/FILES` lists `10` Java files; the generated
   `ApiApi` names only literal `/api/v1/...` paths, `0` with `{version}`. Driven by unit 10's runner (`probe.u10.Caller`, byte-equal;
   its `RestClient` the runner's, `JdkClientHttpRequestFactory`) against `after/`: Ravi `200` read as `Customer` (the answer's
   `Content-Type` `application/problem+json`, under the generated Accept); Nobody `HttpClientErrorException$NotFound` with the type;
   the pause call's `400` `idempotency-key-missing`. Against the retired mirror: `HttpClientErrorException$BadRequest`, `400`,
   `Invalid API version: '1.0.0'.` for both calls - what the generated client gets when version one is retired.

- **`restdocs`** - unit 11's `TiffinBoxRestDocsTest` alone on `after/` and on `before` (MockMvc: no socket, no HTTP client): it passes
   on both, and its `8` snippets are equal file by file. `http-request.adoc` documents `GET /api/v1/customers/Ravi`; `path-parameters.adoc`
   names `name` only: REST Docs documents the path the test wrote, and the version is a literal segment of it, not a parameter. The
   documented `Content-Type` is `application/json`, the answer to the Accept the test sent (none).

- **`replay`** - on a harness-joined start (21015, a fresh database): the keyed pause under `/api/v1/` answers `201` twice with the
   four parts equal (status, `Location`, `Content-Type`, body), the key table `0` then `1` then `1`. The same key under the other
   spelling, `POST /api/1.0/customers/Ravi/pauses`, answers `404`: no route maps that spelling, the filter claims no key (`1` row
   after). The spelling note holds for TiffinBox's routes as found: a `422` would need a route that maps the second spelling.

- **`callpg`** - dropped first (the drop order): H2 only; PostgreSQL not measured for `replay`.

- **`committed`** - the committed file `20306` B, its md5 unit 11's, byte-identical to unit 11's, no `servers`, `git diff 197ff80`
   empty; the served document with `servers` removed is the committed file byte for byte: not regenerated. `OpenApiSpecTest` passes in
   the package run and its twin. `info.version` is `1.0`; the three path keys under `/api/` say `v1`: two spellings of version one, not
   the same string. On a harness-joined start with the harness's route pair (`/api/{v}/u12/handler`, `version` `1.0` and `2.0`), spring
   doc `3.2.1` answers `200` with a valid document (`openapi` `3.1.0`) and lists the versioned route as two path items, `/api/1.0/u12/handler`
   and `/api/2.0/u12/handler`, one operation each; the JVM's log holds no exception. On that start `/api/3.0/u12/handler` is refused
   `400` `Invalid API version: '3.0.0'.` - a version is checked where a pattern can carry it.

- **`moved`** - unit 11's nineteen requests on `before` and `after`: `0` moved. The web jar's md5 differs; per entry, `after/` has one
   entry `before` lacks, `BOOT-INF/classes/com/tiffinbox/web/TiffinBoxApiVersioning.class`, and no shared entry's CRC moved.

- **the seven and the old surface (R.511)** - equal on both trees, and not witnesses for the `/api/` routes: the seven send
   `/customers`, `/revenue`, `/dashboard`, `/kitchen`, `/nowhere` and `/shutdown`, none under `/api/`. They witness that the path strategy
   leaves the unversioned routes alone; `choose`'s and `moved`'s requests under `/api/v1/` witness that it leaves the versioned routes
   alone; the planted `required.diff` shows the seven can see a configurer that breaks the unversioned routes.

- **`exercise`** - the retired tree's answer to the old request, measured before written: `400`,
   `Invalid API version: '1.0.0'.`. `check.sh` fails the broken tree (no answer saved), passes the solution under bash and `zsh -f`,
   and refuses a typed not-found, a pasted unretired answer, the answer to `/api/2.0/`, a reworded `detail` and a tree with `"1.0"` put
   back.

## The change, file by file, and every README/Javadoc sentence it rewrote or noted (R.250/R.453)

- `tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApiVersioning.java` (new): the configurer above; its Javadoc says what it
  does and what it does not (no default, no deprecation, no retirement - measured on mirrors here).
- `tiffinbox-web/src/test/java/com/tiffinbox/web/ApiVersionTest.java` (new): `theOldAddressAnswersAsBefore` (Ravi through
  `/api/v1/`, the stored version `1.0.0`, and the unversioned `/customers/Ravi` with the same body) and
  `aVersionNoRouteCarriesIsNotFound` (`/api/v3/customers/Ravi`: not found, the stored holder carrying no version and no error).
- `README.md` (the anchor's): a `## Course 9 · unit 12` card; a *Course 9, unit 12* note under the unit 11 note. The opening
  paragraph's "no versioning" is the set-up's starting point and stays as written, noted. The unit 08-11 cards' "Not fixed here ...
  (*Versioning Strategies*)" lines are dated history and stay; unit 12's card says what it pays and what it leaves. The unit 04-06
  cards' "literal `/api/v1/...`" wording is still true; the note says that since unit 12 the second segment is also the version. The
  web module's test count `50` appears only as unit 11's.

## Which tree, which profile

Every capture runs on H2 in memory (`jdbc:h2:mem:tiffinbox`), the default run, a fresh database per JVM start. `before` is unit 11's
tree; `after/` is this unit's. The mirrors are scratch copies of `after/` under `.harness/`, each with one patch of `harness/mirror/`;
every line they print is the harness's.

## Unit 12's section

The spine [S2B]: a required version breaks every old route (`required`, `four`'s H, Q, M); a default hides the wrong carrier
(`default`, trap 4); no default hands an old client the newest (`newest`); the path under `/api/` keeps the old routes as they were and
makes the version visible (`choose`, `four`'s P); retirement is a deprecation, a sunset date, and then a four hundred that names the
version (`deprecate`, `retire`) - what an old client gets, shown (`client`, `exercise`). The failure receipt is trap 4, measured
(`default`). The hazards, each with its capture: versions parse as semantic versions (`four`); a `Content-Type` parameter on a GET is
read as the version (`four`'s M); the response `Content-Type` echoes the requested parameter while another version answered
(`default`); a removed version's handler stays mapped and unreachable (`retire`). The earlier course's lesson on the traps is named
once, by its title, in the block below; the prose gate refuses that course's number beside a title its list lacks, and the spelling gate
refuses the title's bare acronym in a spoken line, so the scripts stage chooses the spoken form (for RED).

```
Course 6: API Versioning in Framework 7
```

## The captures — what each one shows

### choose
The fourteen requests per tree and the planted variant, the seven in each JVM, and `ApiVersionTest` on the planted mirror.

### tests, change
The reactor's counts per runner, the ITs' bindings, the changed list and the class, printed whole:

```
@Configuration(proxyBeanMethods = false)
class TiffinBoxApiVersioning implements WebMvcConfigurer {
    static boolean underApi(RequestPath p) {
        return p.pathWithinApplication().value().startsWith("/api/");
    }
    @Override
    public void configureApiVersioning(ApiVersionConfigurer c) {
        c.usePathSegment(1, TiffinBoxApiVersioning::underApi).setVersionRequired(false).addSupportedVersions("1.0");
    }
}
```

### four, required, default, newest
Each variant's thirteen requests and its seven, the variant's `VER12` line beside. The trap's two lines:

```
trap 4 | request Accept: application/json;version=2.0 | status 200 | Content-Type application/json;version=2.0 | body handler 1.0
H | GET /vapi/customers [Accept: application/json;version=2.0] -> 400 ... "API version is required."
```

### deprecate, retire
The two one-line patches beside their answers:

```
retire.diff    -  ...setVersionRequired(false).addSupportedVersions("1.0");
               +  ...setVersionRequired(false).addSupportedVersions("2.0");
ret | GET /api/v1/customers/Ravi -> 400 application/problem+json · {"detail":"Invalid API version: '1.0.0'.", ...}
deprecate.diff +  ...addSupportedVersions("1.0").setDeprecationHandler(deprecations());
dep | GET /api/v1/customers/Ravi -> 200 · Deprecation: @<masked> · Sunset: <masked> · Link: <http://127.0.0.1/docs/customers-1.0>; rel="deprecation"
```

### type, client, restdocs, replay, committed, moved, seven, surface, inert, exercise
Each as its RE-MEASURE item says; `inert` reads every request line of the run for the key header (`0` outside `replay`'s three named
requests) and the key table on `replay`'s start.

## Measured, not shipped

The four mirrors (`nover`, `required`, `deprecate`, `retire`) and the harness's route pair; two configurers in one JVM (the shipped
class beside the harness's H, shown once in `four`: the old routes answered, which is why the carrier mirror deletes the shipped
class). The `rewrite` mirror (the five routes as `/api/{version}/...`) and the `restdocs12` mirror were dropped at the cap: not captured,
not said.

## Refused, named

Every `XU12` reading in `harness/s912.py`, each with its plant and its near miss: versioning protecting old clients with no strategy
named; the seven as a witness for the `/api/` routes; a retired version gone, or answering a not-found; the header carrier with a
default called sound; no default handing old clients the old version; deprecation breaking clients; the `Sunset` day as a defect; a ranking word
between carriers; the document and the route agreeing; the generated client following the version; REST Docs documenting the version;
an unsupported version refused with a four hundred on TiffinBox's own routes; another gloss line; a count typed; a status in digits.

## The repository, and the network

This unit adds no artifact: Framework `7.0.11`'s versioning is `spring-webmvc`'s, already in the Section 2 seed, copied to
`.m2-demo` (`11004` files, `876159996` B, `0` naming `central-only`). Framework's own advisories are cleared by Spring's page as the probe
read it (its rows name no Spring Framework entry); anything else is not read. The spring doc pin is `3.2.1`, its parent line Boot
`4.2.0`'s; `3.1.0` and `3.1.1` are in the sweep's metadata and were never weighed; no network act. The one capture that could have
contradicted the pin, the versioned harness route's document, answered `200`.

## The folders, the harness and the ports

`README.md after before exercise harness receipts.md5 receipts.sh`; `harness/`: `chk12.py dur9.py mirror s912.py specwire9.py src
tree12.py`; `harness/mirror/`: `deprecate.diff nover.diff required.diff retire.diff`; `harness/src/probe/`: `Etag.java Http.java
Routes.java Witness.java` (unit 11's), `u10/Caller.java` (unit 10's), `u12/U12Probe.java U12Routes.java Versioning12.java`. Copied
byte-equal and asserted each run: `dur9.py`, `specwire9.py` (copied, not run by a capture of this unit), the four probe classes,
`Caller.java`. Adapted with a named diff: `s912.py`, `chk12.py`, `tree12.py`, `U12Probe.java`, `Versioning12.java` (the probe's
`Versioning2.java`, its HE variant removed). Read, not copied: the probe's `ver.log`, its `ver/*.seven`, `ver.sh`, `lib.sh`. Not used:
`seal9.py`, `cdp.mjs`, `cdp9.mjs`, `loc9.py`. Ports: 21010 `after/`, 21013 the mirrors one at a time, 21014 the planted mirror, 21015
the harness-joined starts, 21016 `before`, 21018 the exercise; 21011, 21012, 21017 and 21019 never bound; 21280-21284 during `verify`
only.

## Masks, filters and hygiene

The log mask and the header mask of unit 11, each self-tested, plus the `Deprecation` and `Sunset` values masked in every hashed line;
`Date`, Boot's `timestamp`, every port and `Keep-Alive` masked. Every JVM stopped by `POST /shutdown` or by its recorded pid (a
required-version JVM refuses the shutdown request too); no kill by name; every docker call on the pinned socket; no image pulled; the
Testcontainers containers removed with their volumes.

## Interrupted

Three of the prompt's seven points, after the three runs of record, each a run under `perl -e '$SIG{INT}="DEFAULT"; exec ...'`
stopped by the driver with SIGINT to the pid it recorded: mid-build (`after/`'s reactor build), mid-harness (`before`'s JVM up on
21016), mid-mirror (variant H's JVM up on 21013, its own `Started` line). Each exits `130`, leaves no JVM of the run, nothing listening
on 21010-21019 or 21280-21284, no Testcontainers container, the volumes at the start's count, no `.r-lock` and no unpublished capture.
Not done (the cap): mid-verify and mid-exercise. Not applicable: mid-container and mid-PostgreSQL (`callpg` dropped).

## Planted faults — each caught

The planted `required.diff` on every run (red: the old route, the seven, `ApiVersionTest`); `chk12.py plants` (a fully qualified
`@org.junit.jupiter.api.condition.EnabledIfSystemProperty`, a simple `@EnabledIf`, a fully qualified `@Disabled`, a third `@Test`, a
port literal, a request line one byte off - each refused, no traceback); `s912.py`'s self-test (every `XU12` plant refused, every near
miss passed); the exercise's five refused answers.

## What differed from the brief

- `ApiVersionTest`'s second test: the brief bound "an unsupported version under `/api/` is refused `400`". Measured: on the shipped
  literal routes a version nobody supports answers `404` (no mapping matches the path, so the version is never checked). The test pins
  the measurement, `aVersionNoRouteCarriesIsNotFound`; the `400` is measured only where a pattern can carry a version (the harness's
  route pair, the retired mirror).
- `/api/1.0/customers/Ravi`: `404` on both trees, as found. S1's "both spellings resolve 1.0" holds on the harness's route pair only.
- `deprecate` stamps the real `/api/v1/` answer and the harness's `/api/1.0/` and `/api/v1/` pair; neither "only `/api/1.0/`" nor
  "only `/api/v1/`" is typed.
- `theOldAddressAnswersAsBefore` also sends the unversioned `/customers/Ravi`: without it the planted required variant left the test
  green (measured in the first development run).
- Dropped at the cap: `callpg`, the `rewrite` and `restdocs12` mirrors, the S9.14 plant slot, two of the SIGINT points
  (mid-verify, mid-exercise). This section and the Interrupted one were written after the three runs, which gated the earlier text.
- The seven run inside `choose`'s JVMs after its fourteen requests; the `seven` capture reads them.

## For RED

The literal routes make D2 wire-invisible on TiffinBox: no request's answer moved, and an unsupported version is a not-found, not a four
hundred - the brief's "unsupported version refused" sentence is the harness's, not TiffinBox's. spring doc lists a versioned pattern as
one concrete path per version. The planted required variant leaves `/api/v1/` answering (the path still carries `v1`); it breaks the
unversioned routes. The earlier course's title fails the spelling gate as a spoken line, and its course number the call-back gate.

## The ledger rows this unit pays

`TRACK-ROADMAP.md:382`; C9-2 (a version deprecated, sunset, retired, and what an old client then gets: "How to retire a version is
Course nine's Versioning Strategies."); C9-6 (the traps on this pin: a required version breaks old routes, a default answers the wrong
version, no default gives the newest); C9-14 (a versioned API's tests: `ApiVersionTest` and the REST Docs read); C9-20 (the replay's four
parts under the versioned route, the spelling note); C9-11 (the seven and the old surface at this anchor change). The ledger is not
edited.

## The values the video may say

<!-- values: begin -->
```
choose: v1=200 spell10=404 v3=404 moved=0 seven=466c20ed planted_seven=7d36b99e planted_old=400 planted_test_red=1
tests: web_before=50 web_tests=52 new_tests=2 apiversion_skipped=0 client_tests=1 its=14 it_classes=5 lib=157 reactor=4 sends_v1_classes=5
change: modules=3 mappings=5 webmvc=7.0.11
four: H_old=400 P_old=200 token3=3.0.0 seven_HQM=7d36b99e seven_P=466c20ed M_content_type_get=200
required: required_old=400 required_seven=7d36b99e
default: trap4_status=200 trap4_body=1.0 trap4_header=2.0 seven_HD=466c20ed
newest: newest=2.0 seven_HN=466c20ed
deprecate: stamped=4 unstamped=7 sunset_day_digits=2 seven_dep=466c20ed
retire: retire_path=400 retire_token=1.0.0 retire_header=400 seven_ret=466c20ed seven_HR=7d36b99e
type: type=customer-not-found retired_nobody=400
client: files=10 generated_v1_lines=4
restdocs: snippets=8 snippets_equal=8 path_parameters=name documented_ct=application/json
replay: replay_status=201 other_spelling=404 keys_after3=1
committed: file_bytes=20306 spec_md5=e715f47c info_version=1.0 path_token=v1 api_paths=3 versioned_doc=200 versioned_paths=3
moved: requests=19 moved=0 v1_requests=7 jar_new_entries=1 jar_crc_moved=0
seven: seven=466c20ed
surface: surface=316a9637 surface_requests=13
inert: captures_read=9
exercise: retired_status=400 solved=pass variants=5
static: xfam_s9s1_md5=1f5217a0 changed_files=3
gloss: gloss=a_version_carrier_one_line
spoken: hook_words=20 exercise_words=15 gloss_words=7
build: seed_files=11004 seed_bytes=876159996 central_only=0
```
<!-- values: end -->
