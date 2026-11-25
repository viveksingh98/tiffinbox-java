# Course 9 · Unit 09 — Documenting Errors, Examples and Security

**Course 9's sixth change to the anchor, and Section 2's third unit.** The served document now says, per operation, the error answers
TiffinBox sends - each with Framework's `ProblemDetail` schema and one example equal to an answer the wire sent - on exactly the
operations a command derives from the handlers, the advice and the key filter; the not-found problem carries a type of its own,
`tag:tiffinbox.example,2026:customer-not-found`, on every route that throws `CustomerNotFound`, the old `GET /customers/{name}` included;
four new tests read that `type`; and the committed copy of the document (`tiffinbox-web/src/test/resources/openapi/tiffinbox.json`) is
written again from the running application in the same commit. `before` is a link to `../c9-unit08/after` (unit 08's tree); `after/`
is a frozen copy of `../c9-tiffinbox` after this unit's change. Every number below names its tree and is read by `harness/chk09.py` off
a capture of `receipts.sh`, never typed. No browser runs in this unit.

The unit's one gloss, typed once in `harness/chk09.py`:

A problem type: the U-R-I that names an error's kind.

The hook, as the brief gives it (S2B's Unit 09 Hook line), byte for byte, in a fence because the carried prose base refuses it (filed
under What differed):

```
One line on TiffinBox's error advice, and spring doc promises a four oh four on every documented route, the revenue included.
```

## Runs of record

Three runs, each launched below load1 `20` (R.480) with its load printed on its first line: bash `3.2.57` (`./receipts.sh`), bash
`5.3.9` (`bash receipts.sh`), and a sealed fresh clone of the repository in a folder whose name holds a space (R.129), run from that
clone. Every build says offline: yes (`Downloading from` `0` in every Maven log). Each run ends `every capture = published (16)`, and
`check_unit9.py 09 --runlog <log>` prints the run-log gate's PASS on each (the unit gate exits `2`, not judged, until unit 09's script
exists, as the prompt expects). The capture hashes are the `receipts.md5` lines; the loads are in the commit message. No clock figure
of a run is a measurement and none is said here.

## RE-MEASURE (settled first)

1. **`none` - unit 08's tree.** On `before` (H2, no harness) the document is `TiffinBox` / `1.0`, `11` paths, `13` operations, `6`
   tags, schemas `Customer` and `SseEmitter`, and every operation documents `200` alone: error responses `0`, the key header named `0`
   times, no `securitySchemes`, no `security` member - equal to unit 08's values block (`errors_documented=0 key_named=0`). The five
   `Nobody` requests: the old read, the public read and the PATCH answer `404` `application/problem+json`, title `Customer not found`,
   the member `name`, and no `type` member (that is `about:blank`); the pause GET answers its own `404` with no `name`; the pause POST
   without a key is the filter's `400` (`…-missing`) before the route runs.
2. **`perop` - the documented set, and what moved.** The set is derived, never typed, in three printed parts (`census`): part (1), the
   `{name}` operations of the served document - `5` of `13`, as the run prints it (the five RED #16 named); part (2), the filter's
   `GUARDED` table - `2` (`POST /customers`, the key optional; the pause POST, required); the union - `6` operations. On `after/` exactly
   those six gained responses (the table in `perop`: `11` added responses), every other operation's responses are byte-equal, and each
   operation keeps its `200` first, as before. With `info`, `servers`, the added responses and the `ProblemDetail` schema removed, the
   two documents hash the same (the `rest_md5` value, the same as unit 08's `info_rest_md5`), the hashes read back by `chk09.py`
   from the two saved documents. `components` gains `ProblemDetail` and nothing else; `info` stays `TiffinBox` / `1.0`; swagger-config is
   equal after the port mask; the YAML only gains lines. The mechanism: `@ApiResponse` on the handler methods (A); its first form,
   with the error responses alone, made spring doc drop each annotated handler's generated `200` - measured during the build of the
   change, not shipped - so each annotated handler also names its `200` (`description = "OK"`), and the document with the additions
   removed is unit 08's.
3. **`blanket` - the failure receipt.** One `@ResponseStatus(HttpStatus.NOT_FOUND)` line on the advice's handler (a scratch mirror of
   `before`, the probe's `t09-plant.diff` as the draft) documents a `404` on `13` of `13` operations, `GET /revenue`, `GET /kitchen` and
   `POST /shutdown` among them; the same mirror's wire answers `/revenue` and `/kitchen` `200` and `Nobody` `404`: the document promises
   what the code does not do. The anchor carries no such line: `@ResponseStatus` in `after/`'s main sources is `DishWrite.java:32` alone
   (a `@Profile("dev")` route), nothing in `TiffinBoxErrors.java` - checked file by file.
4. **`shape` - the schema against the wire, and the examples.** Every example in the document (`12`) equals a body the wire sent and
   this run filed, key for key and value (the outstanding one answered a planted in-flight claim, the harness's row). The `ProblemDetail` schema
   lists `type`, `title`, `status`, `detail`, `instance` and `properties`; the wire sends `name` at the top level, which the schema
   does not list, and never sends `properties` (the documented problems' bodies; the create's own refusal, not documented here, also
   sends `errors`). This ships and is named; whether a
   TiffinBox schema should list `name` is not measured here.
5. **`types` - the type, the old route, the key, the SHOULD, the write routes.** On `after/` the old read, the public read, the PATCH
   and the keyed pause POST to `Nobody` answer `404` with `"type":"tag:tiffinbox.example,2026:customer-not-found"` and every other
   member byte-equal (S9.37: before and after printed whole); the pause GET's own `404` stays `about:blank`. The key's problems from the
   wire: no key `400` `…-missing`, an unquoted key `400` `…-malformed`, the reused pair `201` then `422` `…-reused`, and a request under a planted in-flight claim
   with the same fingerprint `409` `…-outstanding`; the key table reads `0` after the keyed `Nobody` POST (the error answer deleted its
   claim), `1` after the reused pair and `2` with the harness's planted row. RFC 9457's SHOULD (section
   4.2.1, quoted only from the filed copy: with `about:blank` the title SHOULD be the status phrase): of the `12` bodies this run
   filed, `8` carry a type of their own and `4` are `about:blank` - `2` keep the phrase (the pause GET's `Not Found`, `/shutdown`'s
   `Forbidden`) and `2` do not (the create's and the PATCH's `Invalid customer`: named, not changed here). Unit 06's R2 counted four
   error bodies, one typed (the key filter's); on this tree the same four have two typed - the not-found one moved, the two `Invalid
   customer` bodies still break the SHOULD. The write handler methods by
   the anchored grep: `7` (Q-d's `7`); the document's write operations: `5`.
6. **`scheme` - none yet.** The harness's copy of the spec (a document customizer, `probe.u09.SchemeCopy`, on `20985`) declares
   `components.securitySchemes.bearer` and a global `security` requirement; `GET /api/v1/customers/Ravi` with no credential and with
   `Bearer not-a-token` both answer `200`, both bodies equal to `after/`'s own. GET only. The shipped document declares no scheme.
7. **The committed file and its test.** `20306` bytes (`wc -c`); its diff against unit 08's file is additions only; with the added
   responses and `ProblemDetail` removed it is unit 08's file byte for byte. `OpenApiSpecTest`, byte-equal to unit 08's, passes on it in `package`
   and the Docker-free twin; it fails on the stale file (unit 08's file beside this code), on a drifted copy, on drifted code and on
   the documented `404` moved to another code.
8. **`diff` - specwire9's rows move.** (a) `7` kinds / `16` rows on `before` (unit 08's values block) -> `6` / `9` on `after/`, the
   error-responses kind gone; (b) `8` / `17` -> `7` / `10`. The required-header row stays: the key is still not a documented header.
9. **`moved` - what the change could have moved.** Of the nineteen requests (unit 08's fourteen and five `Nobody` requests), five
   moved, each named: the document and its YAML (additions), and the three `CustomerNotFound` bodies a harness-free start reaches (the
   old read, the public read, the PATCH: `+"type"`). The pause POST without a key and the pause GET are equal; the pinned sentence (a
   PATCH to `/customers` answers `405`, `Allow` `GET`, `POST`) holds on both trees.
10. **Tests per runner.** `mvn package`: unit 08's `45` + `4` = `49` (the four new `aNameNobodyHasIsTyped`); the twin the same; `mvn
    verify`: the five ITs, `14`, each bound to `127.0.0.1`; `BOOT-INF/lib` `157` on both trees, no jar's name moved.
11. **The seven and the old surface.** Equal to unit 08's on both trees (the values block's `seven` and `surface`). Not witnesses for this change: the
    seven send no `Nobody` request and reach no spring doc address, and neither does the old surface, so they stay equal.

## The change, file by file, and every README/Javadoc sentence it rewrote or noted (R.250/R.453)

The changed files, derived by `chk09.py static` from the two trees (`11`): `TiffinBoxErrors.java`, `TiffinBoxServer.java`,
`CustomerReads.java`, `CustomerPatches.java`, `CustomerPauses.java` under `tiffinbox-web/src/main`; `TiffinBoxWebTest.java`,
`CustomerReadsTest.java`, `CustomerPatchesTest.java`, `IdempotencyKeyTest.java` under the tests; the committed file; the README. No new
file. `src/main`'s diff holds only annotation lines, comments, imports, the constant and the one `setType` line (checked line by line);
the POMs, `TiffinBoxOpenApi.java`, `IdempotencyKeyFilter.java` and `OpenApiSpecTest.java` are byte-equal to unit 08's.

The stale hunt over `c9-tiffinbox/README.md`: unit 08's card ("no error response and no security scheme", "no problem type moves",
"no test is added") and unit 07's card are dated history of their own changes and stay as written, as unit 08's card kept unit 07's;
a *Course 9, unit 09* note goes under the header's unit 08 note, and unit 09's card follows unit 08's. `TiffinBoxErrors`' Javadoc
gains a unit 09 paragraph (the type, `about:blank` kept for the other problems); `TiffinBoxOpenApi`'s Javadoc ("no error response")
is true of the bean and stays; `OpenApiSpecTest`'s Javadoc ("documented errors ... fails until the file is written again") is true,
now paid. The grep of the changed paths over the earlier units' receipts and the builders is under What differed (flag 27).

## Which tree, which profile

Every claim about the document and every `Nobody` body is read from a start without the harness (`after`, `none`, `blanket`, `types`,
`moved`): a start that joins the harness documents the harness's routes too. The second client (the key table, the customer rows)
exists only on a harness-joined start: `diff`, the keyed companion in `types`, `scheme`. H2 in memory everywhere but `after`'s
PostgreSQL `18.6` start, a fresh database per JVM.

## Unit 09's section

The spine against the brief: TiffinBox answers problem codes its spec did not list (`none`); one annotation on the advice promises a
not-found on every operation (`blanket`); done per operation, with Framework's `ProblemDetail` and TiffinBox's own types, the spec says
what the wire does (`perop`, `shape`) - and where the shape differs, the receipt says that too (`properties` against the top-level
`name`); and the security part says what the anchor has: none yet (`scheme`). The failure receipt is `blanket` beside `perop`; `shape` is the
second. The exercise: one documented not-found on the public read and nowhere else (`exercise/`). The hazards, each measured: the
advice-level line's breadth, the schema against the wire, the declared scheme that enforces nothing, and a type that is a `tag:` with
no host.

## The captures — what each one shows

### tests, census — the counts, the set
`tests`: Surefire's XML per class, the twin, the ITs and their bindings, the new tests read off the trees' diff. `census`: the
mappings on both trees (equal), the handlers against the operations (`17` -> `13`), flag 3's three parts, every problem TiffinBox
constructs with its file and line and whether it is typed, the write handlers beside the document's write operations, `0` `probe/`
entries in either jar.

### after, none — the document on each tree
The three addresses, the document's facts and every operation's response codes, on `after/` (PostgreSQL and H2, equal, equal to the
committed file with `servers` removed) and on `before`.

### blanket, perop, shape — the documented errors
The code panel: on `CustomerReads.one`, `@ApiResponse(responseCode = "200", description = "OK")` and `@ApiResponse(responseCode =
"404", description = "Customer not found", content = @Content(mediaType = "application/problem+json", schema = @Schema(implementation
= ProblemDetail.class), examples = @ExampleObject(...)))`; in `TiffinBoxErrors.notFound`, `problem.setType(CUSTOMER_NOT_FOUND);`.

### types, scheme — the answers
The old route's body before and after, the key's problems, the SHOULD table, the write routes; the scheme copy's two anonymous answers.

### committed, diff, moved, seven, surface, inert, exercise
As unit 08's, with this unit's drift (the moved `404`) and this unit's moved lines.

## Measured, not shipped

The `blanket` line (a scratch mirror only); mechanism B (`.harness/loser`); the `wide` plant (`.harness/wide`: the seven equal, the
old surface moved); the probe's second `OpenAPI` bean (it does not start); the first form of mechanism A (the error responses without the `200` line: the generated
`200` dropped on the annotated operations); the scheme copy (`probe.u09.SchemeCopy`, never under `c9-tiffinbox/`); the `setType` line
reverted (the four new tests fail); the drifted files and code.

## Refused, named

Every `XU09` verdict word (see `harness/s909.py`); an error response said of an operation outside the derived set; a scheme in the
anchor; the key's header as a documented parameter (U10's failure receipt rests on it being unnamed); another gloss line; a clock figure under load.

## The repository, and the network

`D` at `4725421` (unit 08's commit, on `origin/main`, `0 0`), clean at the start. Every build offline from a `cp -c` copy of the seed
`m2-seed-c9-s2` (`11004` files, `876159996` bytes, `central-only` `0`); no download, no new dependency (the annotations come from
`swagger-annotations-3.0.0`, one of the `157` jars). No network but the final `git push`.

## The folders, the harness and the ports

`harness/`: `chk09.py`, `s909.py` (the family base and `XFAM_S9S1` byte for byte from unit 08's `s908.py`, and `XU09`), `tree09.py`
(`tree08.py`'s code), `dur9.py` and `specwire9.py` (copied from U08's harness, byte-equal, asserted against `../c9-unit08/receipts.md5`),
`src/probe/{Witness,Http,Etag,Routes}.java` (copied from U08's harness, asserted), `src/probe/u09/U09Probe.java` (the second client's
routes and the planted in-flight row, the harness's), `src/probe/u09/SchemeCopy.java` (the harness's copy of the spec) and
`src/mirror/TiffinBoxErrorDocs.java` (mechanism B, copied into a scratch mirror of `before` only). No `cdp.mjs`, `cdp9.mjs` or
`seal9.py`. Read, not copied: BLUE's `ttag.diff`, the probe's `t09-plant.diff`, and the probe's `DeclaredScheme.java` (compiled from
its filed place into `.harness/` and started once per run). Ports `20980`-`20989` as the header of
`receipts.sh` lists them; `21280`-`21284` during `verify` only.

## Masks, filters and hygiene

`Date`, Boot's `/error` `timestamp`, every port and `servers[0].url`'s port are masked by self-tested masks. The document's
`SseEmitter` member `timeout` appears only inside the committed file and the fenced captures, never in a spoken line.

## Interrupted

SIGINT at 8 points, each a development run of `receipts.sh` started under `perl -e '$SIG{INT}="DEFAULT"; exec ...'` by a
driver that stops it by the pid it recorded (never a name); the point is the line the run printed, read live (the build, the
container) or off the capture's own raw file (a JVM up, verify started, the exercise started):

- `mid-build`: exit `130`; after it: java `0`, listeners `0`, containers `0` + `0`, images `9` -> `9`, volumes `315` -> `315`, `.r-lock` none, `.r-*.new` `0`, the anchor equal to `after/`: yes.
- `mid-harness`: exit `130`; after it: java `0`, listeners `0`, containers `0` + `0`, images `9` -> `9`, volumes `315` -> `315`, `.r-lock` none, `.r-*.new` `0`, the anchor equal to `after/`: yes.
- `mid-container`: exit `130`; after it: java `0`, listeners `0`, containers `0` + `0`, images `9` -> `9`, volumes `315` -> `315`, `.r-lock` none, `.r-*.new` `0`, the anchor equal to `after/`: yes.
- `mid-pg-tiffinbox`: exit `130`; after it: java `0`, listeners `0`, containers `0` + `0`, images `9` -> `9`, volumes `315` -> `315`, `.r-lock` none, `.r-*.new` `0`, the anchor equal to `after/`: yes.
- `mid-scheme-copy`: exit `130`; after it: java `0`, listeners `0`, containers `0` + `0`, images `9` -> `9`, volumes `315` -> `315`, `.r-lock` none, `.r-*.new` `0`, the anchor equal to `after/`: yes.
- `mid-verify`: exit `130`; after it: java `0`, listeners `0`, containers `0` + `0`, images `9` -> `9`, volumes `315` -> `315`, `.r-lock` none, `.r-*.new` `0`, the anchor equal to `after/`: yes.
- `mid-exercise`: exit `130`; after it: java `0`, listeners `0`, containers `0` + `0`, images `9` -> `9`, volumes `315` -> `315`, `.r-lock` none, `.r-*.new` `0`, the anchor equal to `after/`: yes.
- `mid-verify-tc`: exit `130`; after it: java `0`, listeners `0`, containers `0` + `0`, images `9` -> `9`, volumes `315` -> `315`, `.r-lock` none, `.r-*.new` `0`, the anchor equal to `after/`: yes.

Live at the signal: a JVM at `mid-harness`, `mid-pg-tiffinbox`, `mid-scheme-copy` and `mid-exercise`; the PostgreSQL container at
`mid-container`; Maven and its test JVM at `mid-verify` (no Testcontainers container yet) and, at `mid-verify-tc`, a Testcontainers
container as well. A first pass read three of the points off the run's printed log, which a capture prints only when it ends, and
its driver broke on an edit made while it ran (the development run it had started finished on its own, its trap cleaning up); those
points were run again as listed.

## Planted faults — each caught

Each plant ends with its FAIL line or its non-zero exit, on a scratch copy: `perop`'s extra description, extra schema,
`securitySchemes` member and empty input; `shape`'s renamed member (each count moves by one), an example's `status` one off, an empty
input; `blanket` itself; the `setType` revert (exactly the four new tests fail); `committed`'s stale file, drifted file, drifted code and
moved `404`; `diff`'s `mealType` rename (kinds and rows move by one) and empty wire folder; the `probe/` class in a scratch jar; the
S9.14 ETag filter (the seven equal, the surface moves); the exercise's refused variants.

Not run as plants (not said as caught): the prompt's prose and static plants - the hook or the exercise line changed by a byte, a
another gloss line, a stale sentence left in unit 09's card, a non-empty `security` in the committed file, a dead browser subcommand,
the tree pin typed wrong, a `path` variable under zsh, `45 + k` typed one more, an `IT BINDINGS` line removed. The gates that would
catch them run on every run (static, gloss, spoken, the prose gate, the tree pins, the tests check); no planted copy was made of them.

## What differed from the brief

Each flag of the prompt, one line: what the brief or the prompt said, what this unit did, why. The orchestrator's picks for this unit
(`[ORCH 2026-11-25]`, FACTORY-NEXT's line of that night) bind and are kept: the anchor change is the documented errors and the not-found
type with the file regenerated in the same commit; no `securitySchemes` in the anchor (the scheme is the harness's copy); the exercise's
solution measured before it was written; the hook spoken as RED #7 fixed it, the ProblemDetail lesson named once, RED #23 a NOTE, no
browser in this unit.

- `1`. The anchor change: the orchestrator's three parts in one commit (the documented errors, the not-found type, the regenerated file),
   no POM line needed - the annotations come from `swagger-annotations-3.0.0`, already one of the `157` jars; the key filter,
   `TiffinBoxOpenApi` and `OpenApiSpecTest` byte-equal (static).
- `2`. "TiffinBox's own problems on ALL routes" read as every route that throws `CustomerNotFound` (the census lists the four); every
   other problem TiffinBox writes keeps `about:blank`, listed with file and line by `census` - named, not changed here. The `wide` plant
   (a scratch mirror with a type on `/shutdown`'s `403`): the seven do NOT move - their two `/shutdown` requests are a GET (`405`) and a
   POST with the token (`200`), so no seven request meets the `403`; the prompt's premise (the seven carry that `403`), measured false.
   The old surface moves on it (its last request, a POST with no token): the surface is the witness a wider change would reach.
- `3`. The brief's count of the `{name}` operations is part (1)'s printed size, `5`; the documented set is the printed union, `6` (part (2) adds `POST /customers`). The pause
   POST's `400` carries two named examples (missing, malformed) under one code - the prompt's "one example per problem", not per code.
   `POST /customers` documents the key's `400`, `409` and `422` only; its own `400` (`Invalid customer`) and `409` (a taken name) share
   those codes and are not documented here - a question for RED.
- `4`. The mechanism: A (`@ApiResponse` on the handlers) shipped. Its first form - the error responses alone - dropped each annotated
   handler's generated `200` from the document (measured on the change's own build, not shipped); the shipped form names the `200`
   (`description = "OK"`), and the document minus the additions is unit 08's. B (an `OperationCustomizer` and the schema added by
   swagger-core's converter, a scratch mirror of `before`, `harness/src/mirror/TiffinBoxErrorDocs.java`) was measured on every run: its
   responses equal A's, and its document differs from A's in the `ProblemDetail` schema's own members and the schemas' order (`perop`
   prints each difference) - the pre-stated test ships A.
- `5`. `shape` ships the mismatch and names it: the schema lists `properties`, the wire sends `name` at the top level.
- `6`. Examples: one named example per documented problem, each equal to a body this run filed; no request example, nor an example on
   a schema.
- `7`. Tests: `k` = `4` new `@Test` methods (`aNameNobodyHasIsTyped`), one per `CustomerNotFound` route's class; existing tests edited `0`;
   `45` + `4` as the run prints it. The revert plant: exactly the four fail.
- `8`. `blanket` on a scratch mirror only; the anchor's `@ResponseStatus` checked file by file (`DishWrite.java:32` alone, dev profile).
- `9`. What moved, three claims, each from the saved documents; the YAML and swagger-config compared (additions only; equal).
- `10`. The committed file written once from a harness-free start of the changed tree (the change's build, H2), the fixed rule; the stale
    file, a drifted file, drifted code and the moved `404` (to `410` in code) each FAIL the test; it passes on the shipped tree.
- `11`. The `tag:` constant read off the source; RFC 4151 and RFC 2606 are not filed - RED #23's reading is cited as RED's. The URL gate
    sketch of the `tag:` string through `check_unit9.py` was not run separately (the constant carries no `//`, printed).
- `12`. The hook: extracted from the brief at run time, `21` words, the status, spelling, Hinglish and dur9 gates `0`, XU09 `0` - and the
    carried base's `XU19` (a Course 8 rule on revenue wording) refuses it in s909. Filed for RED and the scripts stage; the brief's line is
    not edited, and in this README it stands in a fence. The brief's "BLUE §B7" citation is a mis-cite of NOTES's B4 (filed).
- `13`. The hook's two claims: `blanket`'s `13` of `13` operations, and `GET /revenue`'s entry beside the wire's `200`.
- `14`. The SHOULD table: from the filed RFC copy's lines `498`-`515` and the bodies this run filed, including R2's re-sent bodies.
- `15`. The write routes: `7` handler methods by the anchored grep (Q-d's `7`), `5` write operations in the document.
- `16`. The scheme copy is a document customizer on `20985`, never one more `OpenAPI` bean. The probe's own `DeclaredScheme` joined to
    `after/`'s jar (compiled from its filed source, every run): the application does NOT start - spring doc's document builder needs a
    single `OpenAPI` bean and finds two (`openApi` and `declaredButUnenforced`), the start's own lines printed in `scheme`.
- `17`. The exercise: broken (`before`) and solved under bash and `zsh -f`, every run; the refused variants (blanket, the old route, both,
    the pause read, the four-oh-four with its content bare, the file not rewritten, the file hand-edited) in the first run of record only (the cap's order: the refused variants once).
- `18`. The gloss: `A problem type: the U-R-I that names an error's kind.` (`10` words); the brief's parenthetical as written has a bare
    `URI`, which the spelling gate refuses - the spelled form passes.
- `19`. The key's four problem responses are documented on the two keyed operations and the header is NOT added as a parameter (U10's
    pause-call receipt rests on it); specwire9's required-header row stays. A cross-unit decision for the orchestrator. The outstanding
    answer is SENT here, not cited: unit 04's filed body lives in a file the repository ignores, which a fresh clone does not hold, so
    the keyed companion plants an in-flight claim (the harness's row, as `IdempotencyKeyTest` plants one) and the next request answers it.
- `20`. specwire9: the rows MOVE - the printed counts and the delta are in the values block; nothing typed.
- `21`. `s909.py`: the base and `XFAM_S9S1` byte for byte; `XFAM_S9S2` does not exist yet - nothing to assert XU09 against.
- `22`. The committed file's `timeout` member is never spoken; it stands in the file and in fenced captures only.
- `23`. PostgreSQL: the document on PostgreSQL `18.6` equals H2's and the committed file (`after`); `typespg` was dropped first under the
    cap's order: the `Nobody` bodies are H2 only; PostgreSQL not measured for `types`.
- `24`. `moved`: nineteen requests; five moved, named. The keyed pause POST's `404` is not in `moved` (a harness-free start sends no key):
    it is measured in `types`' keyed companion - so `moved` names five moves where the prompt expected six.
- `25`. Instruments: copied byte-equal and asserted (dur9, specwire9, the four probe classes); read, not copied (the probe's plant diff
    and `DeclaredScheme`, BLUE's `ttag.diff`); not used (seal9, loc9, gates9b, the browser scripts).
- `26`. Ports as assigned; `20987` the scratch mirror (blanket); `20989` never bound.
- `27`. The grep of the changed anchor paths over `c9-unit01`-`c9-unit08`'s receipts and harnesses, `C9/_builders` and the tool scripts:
    hits in unit 04's `chk04.py` (`IdempotencyKeyTest`), unit 05's and unit 06's checkers (`CustomerPatches`, `CustomerReads` and their
    tests), unit 07's `receipts.sh` (`TiffinBoxServer`, on its own mirror) and units 07-08's committed-file checks - each reads its own
    `after/` or a mirror, not the live anchor: a NOTE. Unit 03's `instance` view greps the LIVE anchor: `setInstance` still `0`, and its
    `ProblemDetail.forStatus` line numbers move (`TiffinBoxServer.java:295`/`:306` -> `:311`/`:322`, `TiffinBoxErrors.java:25` -> `:35`,
    `CustomerPatches.java:203` -> `:215`): that view's printed line moves on a re-run from this commit - a finding for the orchestrator,
    not a stop.
- `28`. The stale hunt: unit 08's card stays as history; a unit 09 note and card added.
- `29`. Nothing was pending: `0 0` at the start.
- `30`. FACTORY-NEXT: two lines, STARTED and LANDED.

## For RED

- Flag 2: "ALL routes" read as the `CustomerNotFound` routes; the wider reading would type `/shutdown`'s `403`, which the seven never
  meet (measured: `wide`) and the old surface does.
- The brief's count of the `{name}` operations: part (1) prints `5`; the documented union prints `6`. Which number the video says is the scripts stage's.
- The title's "Examples": paid by one example per documented problem, each equal to a filed wire body; a request example is not
  measured.
- `properties` against the top-level `name`: should a TiffinBox schema list `name`? Not measured.
- The key's header across U09 and U10: documented problems, no header parameter; the smaller alternative (one `@Parameter` on the two
  keyed operations) is not measured.
- The hook: the carried `XU19` refuses it; the brief's "BLUE §B7" is B4.
- The gloss: the brief's parenthetical has a bare `URI`; the spelled form is the passing one.
- `POST /customers`: its own `400` and `409` share the key's codes and are not documented.
- The mechanism's loser (B): its schema differs from spring doc's in its own members; whether that matters to a client is not measured.
- RFC 4151 / RFC 2606 (RED #23): cited as RED's; neither is filed.
- Unit 03's `instance` view prints the live anchor's `ProblemDetail.forStatus` lines, whose numbers this change moves (What differed, `27`).
- RED2 #6 (the type reaches the old route - measured, S9.37), #7 (the hook's spelling - passes; XU19 filed), #15 (the SHOULD and the
  write routes - `types` / `census`), #16 (five `{name}` operations - printed), #22 (the ProblemDetail lesson's title, said once -
  the scripts stage's), #23 (a NOTE), #25 (spelled forms pass, bare forms refuse - `spoken`).

- `typespg` was dropped first under the cap's order (the `Nobody` bodies are H2 only); the document on PostgreSQL is `after`'s.
- The advisories are the filed read of the evening before (`fetched-at` printed on every run, inside the age the run asserts); no other advisory cited.
- The specwire9 delta (`-1` kind / `-7` rows in (a)): whether the video says a kind count is the scripts stage's (unit 08 said none).
- The committed file's size by `wc -c` is the one a video may say; the socket's answer carries the port and is never voiced.

## Hand-offs

*Code Generation From the Contract* (unit 10): the committed file is its input and now carries the error responses and the
`ProblemDetail` schema; the pause call still names no key header (no parameter was added here). *Spring REST Docs* (unit 11): a driven
test against these documented errors. *Versioning Strategies* (unit 12): `info.version` against the routes' versions, and the
not-found `type` under a versioned route (not measured here). Course 10's *The Threat Model First*: no scheme in the anchor. The
scripts stage: the values block, For RED, the spoken forms, the hook's `XU19` refusal, the gloss, the S9.37 sentence. The orchestrator:
unit 03's `instance` view (What differed `27`), the key-header decision across units 09 and 10.

## The ledger rows this unit pays

`TRACK-ROADMAP.md:379` ("the `ProblemDetail` shapes in the spec"): the documented errors with Framework's `ProblemDetail` schema.
C9-18: unit 04's problem-type scheme adopted by the not-found problem, and unit 04's four key types documented on the keyed operations
(the route's own `409` stays `about:blank`). C9-13: security "none yet" (the shipped document declares no scheme; the harness's copy
answers anonymous GETs) and the `7` write routes. C9-11: the seven and the old surface re-run at this anchor change, equal. C9-3:
the course's name and its four topics - this unit is one of the units that carry the contract topic.

## The values the video may say

Each value below is read by `harness/chk09.py` off a capture of this unit's runs (the capture's name leads its line), equal on the three
runs of record; H2 unless the line says PostgreSQL. A value not here is not said.

- `perop` / `census`: the `{name}` operations of the document - `5` of `13` (part (1)); the keyed operations - `2` (part (2)); the
  documented set - `6` of `13` (the union); responses added - `11`. Witness: the served document on a harness-free start, H2 (and
  PostgreSQL in `after`).
- `blanket`: one line on the advice documents a four-oh-four on `13` of `13` operations; `GET /revenue` answers `200` on the same mirror.
- `shape`: examples `12`, every one equal to a body the wire sent; the wire's top-level member the schema does not list: `name`; the
  schema's member the wire never sends: `properties`.
- `types`: the not-found answer's type `tag:tiffinbox.example,2026:customer-not-found` on `4` routes; the pause GET's own four-oh-four
  stays `about:blank`; write handler methods `7`, write operations in the document `5`.
- `committed`: the file `20306` bytes (`wc -c`; unit 08's `9843`), additions only.
- `tests`: `45` + `4` = `49` at `mvn package`; ITs `14`; `BOOT-INF/lib` `157`.
- `diff`: specwire9 (a) `6` kinds / `9` rows (was `7` / `16`), (b) `7` / `10` (was `8` / `17`).
- `scheme`: the copy declares a bearer scheme; an anonymous GET and a GET with a bad token both answer `200`; the shipped document
  declares none.
- `seven`, `surface`: equal to unit 08's on both trees.

<!-- values: begin -->
```
tests: tests=49 tests_u08=45 tests_k=4 its=14 it_entries=5 lib=157->157
census: annotations=22 dev_mappings=5 handlers=17 operations=13 paths=11 part1=5 part2=2 union=6 problem_sites=23 problem_sites_blank=17 write_handlers=7 write_ops=5
after: openapi=3.1.0 info=TiffinBox/1.0 paths=11 operations=13 tags=6 error_responses=11 pg_equal=yes
none: before_errors=0
blanket: blanket=13/13 revenue_wire=200
perop: loser_bytes=DIFFER loser_json=DIFFER added_responses=11 rest_md5=eb08ed40 ops_moved=6 ops_equal=7
types: should_rows=12 should_blank=4 should_blank_not_phrase=2 should_typed=8 type=customer-not-found routes_typed=4 revert_fail=4
shape: examples=12 wire_not_schema=name schema_not_wire=properties
committed: spec_bytes=20306 spec_md5=e715f47c spec_bytes_u08=9843 lines_added=275 test=PASS stale=FAIL drift_file=FAIL drift_code=FAIL drift_moved404=FAIL
diff: kinds_a=6 rows_a=9 kinds_b=7 rows_b=10 delta_a=-1/-7 delta_b=-1/-7 key_named=0
scheme: declared_scheme_start=refused anon=200 bearer=200 body_md5=5394e0eb shipped=none
moved: asked=19 moved=5 unmoved=14
seven: seven=466c20ed
surface: wide_seven=equal wide_surface=moved surface=316a9637
inert: keyed=pause-key+companion5
exercise: exercise=broken-FAIL1,solved-PASS,refused-7,bash+zsh,h2
static: xfam_s9s1_md5=1f5217a0 files_changed=11 files_main=5 files_new=0 k=4 spec_bytes=20306 spec_bytes_u08=9843 added_responses=11
gloss: gloss=problem_type_one_line
spoken: hook_words=21 exercise_words=15 gloss_words=10
build: seed_files=11004 seed_bytes=876159996 central_only=0
```
<!-- values: end -->
