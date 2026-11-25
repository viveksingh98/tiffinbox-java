# Course 9 · Unit 10 — Code Generation From the Contract

**Course 9's seventh change to the anchor, Section 2's fourth unit, and the anchor's first new module.** The parent's `<modules>` gains
`tiffinbox-client`, and the parent gains one property, `openapi-generator.version` `7.27.0`. The new module has no hand-written main
code: Open A-P-I Generator (its Maven build step, generator `spring`, library `spring-http-interface`) writes the whole main source tree
at `generate-sources` from the committed file the web module's `OpenApiSpecTest` already guards
(`tiffinbox-web/src/test/resources/openapi/tiffinbox.json`), read in place - the application is not started for it. One test binds the
generated interface to Spring's `MockRestServiceServer` and ends in `verify()`. `before` is a link to `../c9-unit09/after` (unit 09's
tree); `after/` is a frozen copy of `../c9-tiffinbox` after this unit's change. Every number below names its tree and is read by
`harness/chk10.py` off a capture of `receipts.sh`, never typed. No browser runs in this unit, and no PostgreSQL capture: H2 only.

The unit's one gloss, typed once in `harness/chk10.py`:

Code generation: source written by a tool from the spec.

The hook, as the brief gives it (S2B's Unit 10 Hook line), byte for byte; it passes every gate of `harness/s910.py`:

The client generated from TiffinBox's own spec reads Ravi, and binds to Spring's mock server unchanged.

## Runs of record

Three runs, each launched below load1 `20` (R.480) with its load printed on its first line: bash `3.2.57` (`./receipts.sh`), bash
`5.3.9` (`bash receipts.sh`), and a sealed fresh clone in a folder whose name holds a space (R.129), run from that clone. Every build
says offline: yes (`Downloading from` `0` in every Maven log). Each run ends `every capture = published (18)`, and
`check_unit9.py 10 --runlog <log>` prints the run-log gate's PASS on each (the unit gate exits `2` until unit 10's script exists, as
the prompt expects). The capture hashes are the `receipts.md5` lines; the loads are in the commit message. No clock figure of a run is a
measurement and none is said here.

## RE-MEASURE (settled first)

1. **`tests`** - the whole reactor at `mvn -o clean package`: the parent and three modules, each `SUCCESS`; `tiffinbox-web` `49` tests
   (unit 09's, re-measured), `tiffinbox-client` `1` (`TiffinBoxClientTest`), run, none skipped; the Docker-free twin the same; `verify`
   on the whole reactor: the five ITs, `14` tests, five `IT BINDINGS` lines, every entry on `127.0.0.1`; the client has no IT. The
   hand-built form units 01-09 run (`-pl tiffinbox-web -am`) prints the same web counts and builds no client. `BOOT-INF/lib` `157`
   before and after, no jar name moved.
2. **`census`** - one flag start of `after/`: `17` TiffinBox handler methods, the document's `13` operations in `11` paths; the
   generator wrote `13` `@HttpExchange` methods, one per operation, none missing, none extra. The form page `/customers/new` has no
   generated constant; `/dashboard` has one, the JSON operation's (DashboardPage's handlers share its method and path and have no
   operation of their own). The web jars hold `0` entries named `com/tiffinbox/client`.
3. **`modules`** - the parent's `<modules>`: `2` (`tiffinbox-core`, `tiffinbox-web`) before, `3` after (`tiffinbox-client` added after
   `tiffinbox-web`), the parent pom's diff additions only. Every earlier commit that touched `c9-tiffinbox/` is a row with the modules it
   changed (the set-up, then units 04-09); none touched a client module, and unit 10 is the first to add one.
4. **`generate`** - the generator's run alone (`-pl tiffinbox-client -am clean generate-sources`): exit `0`, offline, nothing listening
   on 20400-21299 before or after, no web module built. Its `.openapi-generator/FILES` lists `10` Java files - six interfaces, grouped by
   the first path segment (`ApiApi` for everything under `/api/v1`, `CustomersApi`, `DashboardApi`, `KitchenApi`, `RevenueApi`,
   `ShutdownApi`), three models (`Customer`, `ProblemDetail`, `SseEmitter`) and the configurator - and `VERSION` `7.27.0` equals the
   parent's property. The generated set, `@Generated(date = ...)` masked, hashes the same in the generator's run and in the full build.
   One description changed in a scratch mirror's committed file moves exactly the two generated files that name it. Another copy of
   the file inside the module (measured, not shipped): the web test goes red, and the client still generates the old set from the copy.
5. **`jackson`** - the client's resolved list (`mvn -o dependency:list`): Jackson 3's databind once, Jackson 2's databind `0`,
   `jackson-databind-nullable` `0`, `httpclient5` `0`, and `jackson-annotations` `2.21` once - the annotation package Jackson 3 keeps on
   purpose. The generated sources import Jackson's annotation package and neither mapper; the compiled classes' constant pools name
   `com/fasterxml/jackson/databind` `0` times. The web jar keeps its `157`, Jackson 2's databind among them as unit 07 found it.
6. **`committed`** - the file this build reads is unit 09's, byte for byte (`20306` B, the md5 unit 09's values block gives), equal to the served document
   with `servers` removed; `OpenApiSpecTest` passes in the package run and its twin.
7. **`call`** - the generated `one("Ravi")` against `after/` on H2: `200`, the generated `Customer`, its members equal to curl's body
   key for key. The `RestClient` is the runner's, `RestClient.builder()`, and its factory on the client's class path is
   `JdkClientHttpRequestFactory`; its converter is Jackson 3's `JacksonJsonHttpMessageConverter`; the access log's line gives the
   request's real `User-Agent`, the JDK client's. With HttpClient 5 put on the runner's class path (measured, not shipped) the same
   builder picks `HttpComponentsClientHttpRequestFactory`. A finding: the generated call sends `Accept: */*, application/problem+json`,
   and TiffinBox answers the customer with the content type `application/problem+json`; curl with `Accept: application/json` gets
   `application/json`. Nobody through the generated call: `HttpClientErrorException.NotFound`; its body read as the generated
   `ProblemDetail` keeps `type`, `title`, `status`, `detail` and `instance`, and the wire's `name` member lands nowhere.
8. **`pause`** - the failure receipt. The generated pause method is `add1(String name, Integer days)`: no key parameter. Every line of
   the generated sources that names the key is a comment line (the documented responses' descriptions); the one header parameter the
   generator wrote is `/shutdown`'s token. Sent on a fresh H2 start without the key, the call throws `HttpClientErrorException.BadRequest`
   with `application/problem+json`, and the body equals the committed file's `idempotency-key-missing` example key for key and value.
   On a harness-joined companion the key table reads `0` before and after the refused call. The printed alternative (not shipped, not a
   test): the same call through a builder with the key as a default header answers `201` and the key table reads `1`.
9. **`mock`** - `readsRaviThroughTheMockServer` passes in the package run and its twin; its factory is
   `MockRestServiceServer$MockClientHttpRequestFactory`; the generated `ApiApi.class` it loaded has the same md5 as the real call's and
   as the jar's entry. Plants: the expectation on the old address fails; another expectation the call does not meet fails with `verify()`
   and passes with `verify()` removed - the line that shows `verify()` is what catches it.
10. **`default`** - the generator's default library (`java` / `restclient`) on a scratch mirror only: it builds offline, its compile
    prints `2` removal warnings (`MappingJackson2HttpMessageConverter`, and `RestClient.Builder.messageConverters(Consumer)`), its
    sources import Jackson 2's databind, and its `ApiClient` puts Jackson 2's converter first. The anchor's poms name it `0` times.
11. **`counts`** - one counter, `loc9.py`, over four roots in one call; its printed lines are the counts the video may say (the values
    block). An empty root is refused; a root one level too deep moves the lines.
12. **`location`** - not here, because the generated pause call has no key parameter, so it cannot add the pause whose address R1
    renames away; the rename is *API Design Review*'s measurement and the keyed caller is the caller-side lesson's
    (`Timeouts and Retries From the Caller's Side`).
    The generated create call returns `ResponseEntity<Object>` and shows its `Location`: `201` with `Location`, as curl's create.
13. **`diff`** - specwire9 on H2: (a) `6` kinds and `9` rows, unit 09's, unmoved; (b) with this run's generated sources, `7` kinds and
    `10` rows, the seventh kind the generated client's ("generated client cannot send"). The plant moves each count by one; the empty
    wire folder is refused.
14. **`moved`** - unit 09's nineteen requests on `before` and `after/`, each its own start: `0` moved. The web jar's md5 is the same on
    both trees.
15. **The seven and the old surface** - the expected hashes on both trees, read off unit 09's values block; not witnesses for the
    client, only for "adding the module moved no answer of TiffinBox". The S9.14 plant leaves the seven equal and moves the surface.

## The change, file by file, and every README/Javadoc sentence it rewrote or noted (R.250/R.453)

Four paths of `c9-tiffinbox/` change, the derived list `chk10.py static` prints: the parent `pom.xml` (one `<module>`, one property and
its comment), the new `tiffinbox-client/pom.xml`, the new `TiffinBoxClientTest.java`, and `README.md` (a header note and unit 10's card).
Nothing under `tiffinbox-web/` or `tiffinbox-core/` moves. The README's earlier cards keep their "Not fixed here ... the generated client"
lines as dated history; the header gains a *Course 9, unit 10* note under unit 09's; the `Dockerfile` and `compose.yaml` copy the web jar
alone and do not move. The client's pom names its input through `project.baseUri`: given as a plain path, the generator fails to
resolve the file's own references when the folder's name holds a space, which this repository's does (a finding, below).

## Which tree, which profile

`before` = unit 09's `after` (two modules). `after/` = this unit's tree (three modules). Every TiffinBox start is H2 in memory on the
default profile. A start that joins the harness documents the harness's routes too, so every document claim and every real call is
read from a harness-free start; the second client exists only on a harness-joined start.

## Unit 10's section

The spine, against the brief: the committed spec is an input, and the generator turns it into `@HttpExchange` interfaces; a few lines
of the runner make one a client that reads Ravi (`call`). The same spec through the generator's default library, on the scratch mirror,
brings Jackson 2 beside Jackson 3 and the two removal warnings (`default`). The generated client shows exactly what the code exposes: the pause
call has no place for the key (`pause`). The failure receipt is `pause`; the absent form page is a census line. The exercise is the
wrong address.

## The captures — what each one shows

### tests, census, modules
The reactor's counts per runner, the handlers against the operations and the generated methods, the module table.

### generate, jackson, committed, counts
The generator's run and its input, the generated names and their md5, the Jackson read, the file as unit 09 left it, the harness's counter's lines. The
code panel (the generated public read, date masked) is in `generate`'s block of `.r-generate.out`.

### call, pause, mock, default, location
The runner's `CLIENT` lines beside curl's and the access log's, the mock test's lines, the loser.

### diff, moved, seven, surface, inert, exercise
The spec against the wire, the old routes on both trees, the key's census, the exercise's measured runs.

## Measured, not shipped

The generator's default library on its scratch mirror; HttpClient 5 on the runner's class path; another copy of the spec inside the module; the wrong-body
stub; `verify()` removed. Spring doc's Maven build route (it starts the application in `pre-integration-test`) is named, not measured.

## Refused, named

`the client cannot send the key` (the builder can carry it: the printed alternative); a count the harness's counter did not print; a
Jackson claim without its print; `the generated client just works` without its factory and class path.

## The repository, and the network

One commit for `c9-unit10/` and the changed paths of `c9-tiffinbox/`; the only network act is the push. Every build is offline from a
copy of the Section 2 seed.

## The folders, the harness and the ports

`harness/`: `chk10.py`, `s910.py`, `tree10.py` (this unit's), `dur9.py`, `specwire9.py`, `loc9.py` (copied, md5-asserted),
`mirror/default.diff` (the loser's one patch), `src/probe/{Etag,Http,Routes,Witness}.java` (unit 09's), `src/probe/u10/U10Probe.java` and
`src/probe/u10/Caller.java` (the runner). Ports: `20990` after/ harness-free, `20993` the flag start and the harness-joined starts,
`20994` the S9.14 plant, `20996` before, `20997` the plants' stub, `20998` the exercise; `20991`, `20992`, `20995`, `20999` never bound;
21280-21284 during `verify` only.

## Masks, filters and hygiene

The log mask (times, folders, the home, `@Generated` dates, reactor times), the header mask, the generated-sources mask, each self-tested
at every run; every JVM stopped by its recorded pid; every container of the ITs removed with its volumes.

## Interrupted

SIGINT, each run started by perl with the default handler for the signal, the driver stopping the run by the pid it recorded: mid-build (the
three-module build of `after/`), mid-harness (a JVM live on `20990`), mid-verify (Testcontainers alive), mid-exercise (the exercise's
jar live on `20998`): each exit `130`, then no JVM, no listener in the band, no Testcontainers container, volumes and images at the
start's counts, the captures as they were, no `.r-lock` and no `.r-*.new`, `c9-tiffinbox` equal to `after/`. Mid-mirror was tried
twice and the driver's condition did not catch the mirror's build (each run ended on its own, nothing left): not done. Mid-container
and mid-PostgreSQL do not apply (no PostgreSQL capture).

## Planted faults — each caught

The census's scratch jar, the stub, nothing listening, the three mock plants, the counter's too-deep root and empty root, the
specwire9 plant and empty folder, the S9.14 plant, the exercise's refused variants, and the static checks' guards.

## What differed from the brief

Each of the prompt's thirty flags is answered in the report. The ones that moved from the writer's picks: the module ships one test, the
mock binding, run at every package (the orchestrator's override A); the real call and the key-less pause call are receipts driven by the
harness's runner. The input is named through `project.baseUri` (a plain path breaks under a folder name with a space). The generated
sources name the key in comment lines only, so the count of the word is not `0`; the count of key header parameters is. The generator's
own sha256 record is not the file's sha256 (both printed). The generated sources carry the documented problem responses in comments
and in the `accept` list, so "the generated source names no error" is not said. HttpClient 5 is shown on the runner's class path, not
by a mirror with its own pom; the default library's `new ApiClient()` factory and its real call were not run. `callpg` dropped: H2 only. The
location capture: one create through the generated call and one by curl, two names, on one start. The exercise's moved-mapping variant fails
clause 1, not clause 3: the served document renames its operations.

## For RED

The generated `Accept` header and the customer answered as `application/problem+json`; the generated `ProblemDetail` without `name`;
the space in the folder name; the moved mapping that renames operation `one`.

## The ledger rows this unit pays

`TRACK-ROADMAP.md:380` (a client generated and used); C9-10e, first payment (a program that is not TiffinBox calls its routes); C9-14
(`MockRestServiceServer` named at point of use; the ledger's owner cell lacks U10, filed for the orchestrator); C9-11; C9-3; and
`TIFFINBOX_MODULES`, closed by `modules`' table as a finding.

## The values the video may say

<!-- values: begin -->
```
tests: web_tests=49 client_tests=1 client_skipped=0 its=14 it_classes=5 lib=157 reactor=4
census: handlers=17 operations=13 generated_methods=13
modules: modules_before=2 modules_after=3 commits=7
generate: gen_record=1cec2c10 gen_java_files=10 gen_md5=7f082458 version=7.27.0 onebyte_moved=2
jackson: databind2=0 nullable=0 hc5=0 annotation_imports=6 classes=10
committed: file_bytes=20306 spec_md5=e715f47c
call: call_status=200 factory=JdkClientHttpRequestFactory factory_hc5=HttpComponentsClientHttpRequestFactory ua=Java-http-client/25.0.4.1 ua_hc5=Apache-HttpClient/5.6.5 call_ct=application/problem+json
pause: pause_status=400 idem_comment_lines=6 request_header=1 key_header_params=0 example=idempotency-key-missing keyed=201
mock: mock_md5=21ea1a92 verify=passed noverify_plant=passes
default: warnings=2 loser_databind_imports=6
counts: gen_files=10 gen_lines=479 loser_files=22 loser_lines=1787 web_files=40 web_lines=1767
location: create_status=201 create_location=present
diff: kinds_a=6 rows_a=9 kinds_b=7 rows_b=10
moved: requests=19 moved=0 jar=equal
seven: seven=466c20ed
surface: surface=316a9637
inert: 
exercise: broken=404 solved=200 variants=3
static: xfam_s9s1_md5=1f5217a0 changed_files=4
gloss: gloss=code_generation_one_line
spoken: hook_words=16 exercise_words=17 gloss_words=10
build: seed_files=11004 seed_bytes=876159996 central_only=0
```
<!-- values: end -->
